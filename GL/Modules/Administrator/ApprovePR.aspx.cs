using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Remoting.Contexts;
using System.Security.Cryptography;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Telerik.Web;
using static Telerik.Web.UI.OrgChartStyles;

namespace PMS
{
    public partial class ApprovePR : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!Page.IsPostBack)
            {
                BindGridView();
                CheckUserRights();
                //BindPager();
            }
        }
        private void BindGridView()
        {
            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                var userDepartments = db.Department_Wise_User_Details
                      .Where(dept => dept.User_Id == AppConfig.UserID)
                      .Select(dept => dept.Department)
                      .ToList();
                var qry = from a in db.Purchase_Requisitions
                          where (a.Status == "Created" || a.Status == "Pending") && a.IsDeleted == false && userDepartments.Contains(a.Department)
                          orderby a.PR_Id ascending
                          select new
                          {
                              a.PR_Id,
                              a.PR_Num,
                              a.Remarks,
                              a.Status,
                              Creator = db.aspnet_Users.Where(x => x.UserId == (a.Created_By ?? Guid.Empty)).Select(x => x.UserName).FirstOrDefault(),
                              PRDate = a.PR_Date,
                              Approve_By = string.Join(", ", (from SAL in db.Sys_Approval_Logs
                                                              join user in db.aspnet_Users on SAL.Approve_By equals user.UserId into userGroup
                                                              from usr in userGroup.DefaultIfEmpty()
                                                              where a.PR_Id == SAL.Entry_ID && SAL.Form_ID == 1
                                                              select usr.UserName ?? "").Distinct()),
                              Department = db.GetDataValueName("Department", a.Department),
                              TotalPRAmount = (from prd in db.Purchase_Requisition_Details
                                               join pr in db.Purchase_Requisitions on prd.PR_ID equals pr.PR_Id
                                               where pr.Status == "Approved" && pr.Department == a.Department
                                               select (decimal?)prd.EstimateCost).Sum() ?? 0m,
                              TotalBudget = (from ba in db.Budget_Accounts
                                             join b in db.Budgets on ba.Budget_ID equals b.Budget_ID
                                             where b.Budget_Status == "Approved" && ba.DepartmentId == a.Department
                                             select (decimal?)ba.DR).Sum() ?? 0m,
                              RemainingAmount = ((from ba in db.Budget_Accounts
                                                  join b in db.Budgets on ba.Budget_ID equals b.Budget_ID
                                                  where b.Budget_Status == "Approved" && ba.DepartmentId == a.Department
                                                  select (decimal?)ba.DR).Sum() ?? 0m) - ((from prd in db.Purchase_Requisition_Details
                                                                                           join pr in db.Purchase_Requisitions on prd.PR_ID equals pr.PR_Id
                                                                                           where pr.Status == "Approved" && pr.Department == a.Department
                                                                                           select (decimal?)prd.EstimateCost).Sum() ?? 0m)
                          };

                var formattedQuery = qry.AsEnumerable().Select(x => new
                {
                    x.PR_Id,
                    x.PR_Num,
                    x.Remarks,
                    x.Status,
                    x.Creator,
                    PRDate = Convert.ToDateTime(x.PRDate).ToString("dd-MMM-yyyy"),
                    x.Approve_By,
                    x.Department,
                    x.TotalPRAmount,
                    x.TotalBudget,
                    x.RemainingAmount
                });

                bool hasEntryBudgetViewBtnRights = false;
                var uid = AppConfig.UserID;
                hasEntryBudgetViewBtnRights = (from us in db.aspnet_Users
                                               where us.UserId == uid && us.IsShowBudget == true
                                               select us).Any();
                if (hasEntryBudgetViewBtnRights)
                {
                    GridView1.Columns[9].Visible = true;
                    GridView1.Columns[10].Visible = true;
                    GridView1.Columns[11].Visible = true;
                    GridView1.Columns[12].Visible = true;
                }
                GridView1.DataSource = qry;
                GridView1.DataBind();
            }
        }
        //protected void GridView1_PageIndexChanging(object sender, GridViewPageEventArgs e)
        //{
        //    GridView1.PageIndex = e.NewPageIndex;
        //    BindGridView();
        //}



        protected void BindPager()
        {
            List<object> pager = new List<object>();

            for (int i = 1; i <= GridView1.PageCount; i++)
            {
                pager.Add(new { Text = i.ToString(), Value = i - 1 });
            }


        }
        protected void ChangePage(object sender, CommandEventArgs e)
        {
            if (e.CommandArgument.ToString() == "Prev" && GridView1.PageIndex > 0)
            {
                GridView1.PageIndex--;
            }
            else if (e.CommandArgument.ToString() == "Next" && GridView1.PageIndex < GridView1.PageCount - 1)
            {
                GridView1.PageIndex++;
            }
            else
            {
                GridView1.PageIndex = Convert.ToInt32(e.CommandArgument);
            }

            BindGridView();
            BindPager();
        }

        private void CheckUserRights()
        {
            bool hasEntryRights = false;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var form_id = 1;
                var user_id = AppConfig.UserID;

                hasEntryRights = (from SASD in db.Sys_Approval_Stage_Details
                                  join SASM in db.Sys_Approval_Stage_Masters on SASD.Stage_ID equals SASM.Stage_ID
                                  join SATD in db.Sys_Approval_Tempelate_Detail_Stages on SASM.Stage_ID equals SATD.StageId
                                  join SATF in db.Sys_Approval_Tempelate_Detail_Forms on SATD.Tempelate_ID equals SATF.Tempelate_ID
                                  join SATM in db.Sys_Approval_Tempelate_Masters on SATD.Tempelate_ID equals SATM.Tempelate_ID
                                  where SASD.UserId == user_id && SATF.FormId == form_id && SATM.IsActive == true && SASM.IsDeleted == false
                                  select SASD).Any();
            }
            btnApprove.Visible = hasEntryRights;
        }


        protected void btnApprove_Click(object sender, EventArgs e)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            foreach (GridViewRow row in GridView1.Rows)
            {
                CheckBox chk = row.FindControl("chkSelect") as CheckBox;
                Label pr_id = row.FindControl("lblPR_ID") as Label;
                Label remainingAmtLabel = row.FindControl("lblRemainingAmount") as Label;
                if (chk.Checked)
                {
                    TextBox txtApprovalRemarks = row.FindControl("txtApproval_RejectionRemarks") as TextBox;
                    string approvalRemarks = txtApprovalRemarks?.Text;
                    var user_id = AppConfig.UserID;
                    var form_id = 1;

                    Purchase_Requisition PR = (from tbl in db.Purchase_Requisitions
                                               where tbl.PR_Id == Convert.ToInt32(pr_id.Text)
                                               select tbl).SingleOrDefault();
                    if (PR != null && remainingAmtLabel != null)
                    {
                        decimal remainingAmount = Convert.ToDecimal(remainingAmtLabel.Text);

                        var TotalPRAmount = (from prd in db.Purchase_Requisition_Details
                                             join pr in db.Purchase_Requisitions on prd.PR_ID equals pr.PR_Id
                                             where pr.PR_Id == Convert.ToInt32(pr_id.Text)
                                             select (decimal?)prd.EstimateCost).Sum() ?? 0m;

                        if (TotalPRAmount > remainingAmount)
                        {
                            string alertMessage = $"Total PR Amount: ({TotalPRAmount}) exceeds the Remaining Amount: ({remainingAmount}).";
                            ClientScript.RegisterStartupScript(this.GetType(), "alert", $"alert('{alertMessage}');", true);
                            return;
                        }

                        var IsFinalApprovals = (from SASD in db.Sys_Approval_Stage_Details
                                                join SASM in db.Sys_Approval_Stage_Masters on SASD.Stage_ID equals SASM.Stage_ID
                                                join SATD in db.Sys_Approval_Tempelate_Detail_Stages on SASM.Stage_ID equals SATD.StageId
                                                join SATF in db.Sys_Approval_Tempelate_Detail_Forms on SATD.Tempelate_ID equals SATF.Tempelate_ID
                                                where SASD.UserId == user_id && SATF.FormId == form_id && SASM.IsDeleted == false
                                                select new { SASM.IsFinalApproval, SATF.FormId }).ToList();

                        if (IsFinalApprovals.Any(approval => approval.IsFinalApproval == true && approval.FormId == form_id))
                        {
                            var Details = db.spApprovePurchaseRequisition(Convert.ToInt32(PR.PR_Id), user_id);
                            db.SubmitChanges();

                            Sys_Approval_Stage_Detail SASD = (from tbl in db.Sys_Approval_Stage_Details
                                                              join SASM in db.Sys_Approval_Stage_Masters on tbl.Stage_ID equals SASM.Stage_ID
                                                              join SATDS in db.Sys_Approval_Tempelate_Detail_Stages on SASM.Stage_ID equals SATDS.StageId
                                                              join SATF in db.Sys_Approval_Tempelate_Detail_Forms on SATDS.Tempelate_ID equals SATF.Tempelate_ID
                                                              where tbl.UserId == user_id && SASM.IsFinalApproval == true && SATF.FormId == form_id && SASM.IsDeleted == false
                                                              select tbl).FirstOrDefault();

                            if (SASD != null)
                            {
                                Sys_Approval_Tempelate_Detail_Stage SATDS = (from tbl in db.Sys_Approval_Tempelate_Detail_Stages
                                                                             join SATF in db.Sys_Approval_Tempelate_Detail_Forms on tbl.Tempelate_ID equals SATF.Tempelate_ID
                                                                             where tbl.StageId == SASD.Stage_ID && SATF.FormId == form_id
                                                                             select tbl).FirstOrDefault();
                                if (SATDS != null)
                                {
                                    Sys_Approval_Log SAL = new Sys_Approval_Log();
                                    SAL.Approval_Template_ID = SATDS.Tempelate_ID;
                                    SAL.Approval_Stage_ID = SASD.Stage_ID;
                                    SAL.Entry_ID = PR.PR_Id;
                                    SAL.Form_ID = form_id;
                                    SAL.From_Name = "Purcahse Requisition";
                                    SAL.Remarks = Convert.ToString(PR.Remarks);
                                    SAL.Company_ID = AppConfig.Company_ID;
                                    SAL.IsFinalAprroval = true;
                                    SAL.Entry_Status = "Approved";
                                    SAL.Approve_By = user_id;
                                    SAL.Approve_Date = DateTime.Now;
                                    SAL.IsRejected = false;
                                    SAL.Approval_Remarks = approvalRemarks;
                                    db.Sys_Approval_Logs.InsertOnSubmit(SAL);
                                    db.SubmitChanges();
                                }
                            }
                        }
                        else
                        {
                            PR.Status = "Pending";
                            PR.Approved_Time = DateTime.Now;
                            PR.Approved_By = user_id;
                            db.SubmitChanges();

                            Sys_Approval_Stage_Detail SASD = (from tbl in db.Sys_Approval_Stage_Details
                                                              join SASM in db.Sys_Approval_Stage_Masters on tbl.Stage_ID equals SASM.Stage_ID
                                                              join SATDS in db.Sys_Approval_Tempelate_Detail_Stages on SASM.Stage_ID equals SATDS.StageId
                                                              join SATF in db.Sys_Approval_Tempelate_Detail_Forms on SATDS.Tempelate_ID equals SATF.Tempelate_ID
                                                              where tbl.UserId == user_id && SASM.IsFinalApproval == false && SATF.FormId == form_id && SASM.IsDeleted == false
                                                              select tbl).FirstOrDefault();

                            if (SASD != null)
                            {
                                Sys_Approval_Tempelate_Detail_Stage SATDS = (from tbl in db.Sys_Approval_Tempelate_Detail_Stages
                                                                             join SATF in db.Sys_Approval_Tempelate_Detail_Forms on tbl.Tempelate_ID equals SATF.Tempelate_ID
                                                                             where tbl.StageId == SASD.Stage_ID && SATF.FormId == form_id
                                                                             select tbl).FirstOrDefault();
                                if (SATDS != null)
                                {
                                    Sys_Approval_Log SAL = new Sys_Approval_Log();
                                    SAL.Approval_Template_ID = SATDS.Tempelate_ID;
                                    SAL.Approval_Stage_ID = SASD.Stage_ID;
                                    SAL.Entry_ID = PR.PR_Id;
                                    SAL.Form_ID = form_id;
                                    SAL.Remarks = Convert.ToString(PR.Remarks);
                                    SAL.Company_ID = AppConfig.Company_ID;
                                    SAL.IsFinalAprroval = false;
                                    SAL.Entry_Status = "Pending";
                                    SAL.Approve_By = user_id;
                                    SAL.Approve_Date = DateTime.Now;
                                    SAL.IsRejected = false;
                                    SAL.Approval_Remarks = approvalRemarks;
                                    db.Sys_Approval_Logs.InsertOnSubmit(SAL);
                                    db.SubmitChanges();
                                }
                            }
                        }
                        db.SubmitChanges();
                    }
                }
            }
            Response.Redirect(Request.RawUrl);
        }
        protected void btnCancel_Click(object sender, EventArgs e)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            foreach (GridViewRow row in GridView1.Rows)
            {
                CheckBox chk = row.FindControl("chkSelect") as CheckBox;
                Label pr_id = row.FindControl("lblPR_ID") as Label;
                var form_id = 1;
                var user_id = AppConfig.UserID;
                if (chk.Checked)
                {
                    TextBox txtrejectionRemarks = row.FindControl("txtApproval_RejectionRemarks") as TextBox;
                    string rejectionRemarks = txtrejectionRemarks?.Text;
                    Purchase_Requisition PR = (from tbl in db.Purchase_Requisitions
                                               where tbl.PR_Id == Convert.ToInt32(pr_id.Text)
                                               select tbl).SingleOrDefault();
                    if (PR != null)
                    {
                        PR.Status = "Cancelled";
                        PR.Deleted_By = user_id;
                        PR.Deleted_Date = DateTime.Now;
                        PR.IsDeleted = true;
                        db.SubmitChanges();

                        Sys_Approval_Stage_Detail SASD = (from tbl in db.Sys_Approval_Stage_Details
                                                          join SASM in db.Sys_Approval_Stage_Masters on tbl.Stage_ID equals SASM.Stage_ID
                                                          join SATDS in db.Sys_Approval_Tempelate_Detail_Stages on SASM.Stage_ID equals SATDS.StageId
                                                          join SATF in db.Sys_Approval_Tempelate_Detail_Forms on SATDS.Tempelate_ID equals SATF.Tempelate_ID
                                                          where tbl.UserId == user_id && SATF.FormId == form_id && SASM.IsDeleted == false
                                                          select tbl).FirstOrDefault();
                        if (SASD != null)
                        {
                            Sys_Approval_Tempelate_Detail_Stage SATDS = (from tbl in db.Sys_Approval_Tempelate_Detail_Stages
                                                                         join SATF in db.Sys_Approval_Tempelate_Detail_Forms on tbl.Tempelate_ID equals SATF.Tempelate_ID
                                                                         where tbl.StageId == SASD.Stage_ID && SATF.FormId == form_id
                                                                         select tbl).FirstOrDefault();
                            if (SATDS != null)
                            {
                                Sys_Approval_Log SAL = new Sys_Approval_Log();
                                SAL.Approval_Template_ID = SATDS.Tempelate_ID;
                                SAL.Approval_Stage_ID = SASD.Stage_ID;
                                SAL.Entry_ID = PR.PR_Id;
                                SAL.Form_ID = form_id;
                                SAL.From_Name = "Purcahse Requisition";
                                SAL.Remarks = Convert.ToString(PR.Remarks);
                                SAL.Company_ID = AppConfig.Company_ID;
                                SAL.Entry_Status = "Rejected";
                                SAL.IsRejected = true;
                                SAL.Rejected_By = user_id;
                                SAL.Rejected_Date = DateTime.Now;
                                SAL.Rejection_Remarks = rejectionRemarks;
                                db.Sys_Approval_Logs.InsertOnSubmit(SAL);
                                db.SubmitChanges();
                            }
                        }
                    }
                }
            }
            Response.Redirect(Request.RawUrl);
        }

        protected void GridView1_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            GridView1.PageIndex = e.NewPageIndex;
            BindGridView();
        }
    }
}



