using GridMvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class ApprovePO : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!Page.IsPostBack)
            {
                BindGridView();
                CheckUserRights();
                BindPager();

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
                var userId = AppConfig.UserID;
                var formId = 3;
                var maxApprovalLimit = db.ExecuteQuery<decimal?>(
                    "SELECT MAX(SASD.MaxApprovalLimit) " +
                    "FROM Sys_Approval_Stage_Detail SASD " +
                    "INNER JOIN Sys_Approval_Stage_Master SASM ON SASD.Stage_ID = SASM.Stage_ID " +
                    "INNER JOIN Sys_Approval_Tempelate_Detail_Stages SATD ON SASM.Stage_ID = SATD.StageId " +
                    "INNER JOIN Sys_Approval_Tempelate_Detail_Forms SATF ON SATD.Tempelate_ID = SATF.Tempelate_ID " +
                    "INNER JOIN Sys_Approval_Tempelate_Master SATM ON SATD.Tempelate_ID = SATM.Tempelate_ID " +
                    "WHERE SASD.UserId = {0} AND SATF.FormId = {1} AND SATM.IsActive = 1 AND SASM.IsDeleted = 0",
                    userId,
                    formId).FirstOrDefault();
                ViewState["MaxApprovalLimit"] = maxApprovalLimit;

                var qry = (from a in db.AP_Purchase_Orders
                           join apoi in db.AP_Purchase_Order_Items
                                on a.PO_ID equals apoi.PO_ID
                           join prd in db.Purchase_Requisition_Details
                                on Convert.ToInt32(apoi.PRDetailId) equals prd.PR_Detail_ID into prdGroup
                           from prd in prdGroup.DefaultIfEmpty()
                           join pr in db.Purchase_Requisitions
                                on prd.PR_ID equals pr.PR_Id into prGroup
                           from pr in prGroup.DefaultIfEmpty()
                           where (a.Status == "Created" || a.Status == "Pending")
                                 && a.IsDeleted == false
                                 && (pr == null || userDepartments.Contains(pr.Department))

                       group new { a, apoi, pr, prd } by new
                       {
                           a.PO_ID,
                           a.PO_No,
                           a.Remarks,
                           a.Status,
                           a.PO_Date,
                           a.Created_By,
                           a.Ware_House,
                           Department = pr != null ? pr.Department : null
                       } into g

                       select new
                       {
                           g.Key.PO_ID,
                           g.Key.PO_No,
                           g.Key.Remarks,
                           g.Key.Status,
                           g.Key.PO_Date,
                           PO_Amount = g.Sum(x => (decimal?)x.apoi.Amount) ?? 0m,

                           Creator = db.aspnet_Users
                               .Where(x => x.UserId == (g.Key.Created_By ?? Guid.Empty))
                               .Select(x => x.UserName)
                               .FirstOrDefault(),

                           //Approve_By = string.Join(", ",
                           //    (from SAL in db.Sys_Approval_Logs
                           //     join user in db.aspnet_Users on SAL.Approve_By equals user.UserId into userGroup
                           //     from usr in userGroup.DefaultIfEmpty()
                           //     where g.Key.PO_ID == SAL.Entry_ID && SAL.Form_ID == 3
                           //     select usr.UserName ?? "").Distinct()),

                        Approve_By = string.Join(", ",
                        (from SAL in db.Sys_Approval_Logs
                         join user in db.aspnet_Users on SAL.Approve_By equals user.UserId into userGroup
                         from usr in userGroup.DefaultIfEmpty()
                         where g.Key.PO_ID == SAL.Entry_ID
                            && SAL.Form_ID == 3
                            && SAL.Entry_Status != "Created" 
                            && !SAL.From_Name.Contains("Editable setting updated")
                         select usr.UserName ?? "").Distinct()),

                           Ware_House = db.GetDataValueName("Ware House", g.Key.Ware_House),

                           Department = db.GetDataValueName("Department", g.Key.Department),

                           TotalPRAmount = (from prd_inner in db.Purchase_Requisition_Details
                                            join pr_inner in db.Purchase_Requisitions on prd_inner.PR_ID equals pr_inner.PR_Id
                                            where pr_inner.Status == "Approved" && pr_inner.Department == g.Key.Department
                                            select (decimal?)prd_inner.EstimateCost).Sum() ?? 0m,

                           TotalBudget = (from ba in db.Budget_Accounts
                                          join b in db.Budgets on ba.Budget_ID equals b.Budget_ID
                                          where b.Budget_Status == "Approved" && ba.DepartmentId == g.Key.Department
                                          select (decimal?)ba.DR).Sum() ?? 0m,

                           RemainingAmount = ((from ba in db.Budget_Accounts
                                               join b in db.Budgets on ba.Budget_ID equals b.Budget_ID
                                               where b.Budget_Status == "Approved" && ba.DepartmentId == g.Key.Department
                                               select (decimal?)ba.DR).Sum() ?? 0m)
                                             -
                                             ((from prd_inner in db.Purchase_Requisition_Details
                                               join pr_inner in db.Purchase_Requisitions on prd_inner.PR_ID equals pr_inner.PR_Id
                                               where pr_inner.Status == "Approved" && pr_inner.Department == g.Key.Department
                                               select (decimal?)prd_inner.EstimateCost).Sum() ?? 0m),

                                                   IsEditableAfterApproval = db.Sys_Approval_Logs
                                                    .Where(sal => sal.Entry_ID == g.Key.PO_ID && sal.Form_ID == 3)
                                                    .OrderByDescending(sal => sal.Approve_Date)
                                                    .Select(sal => sal.IsEditableAfterApproval)
                                                    .FirstOrDefault() ?? false
                       })
                       .OrderByDescending(x => x.PO_No); // Added OrderByDescending to sort by PO_Number descending

                 bool hasEntryBudgetViewBtnRights = false;
                var uid = AppConfig.UserID;
                hasEntryBudgetViewBtnRights = (from us in db.aspnet_Users
                                               where us.UserId == uid && us.IsShowBudget == true
                                               select us).Any();
                if (hasEntryBudgetViewBtnRights)
                {
                    GridView1.Columns[10].Visible = true;
                    GridView1.Columns[11].Visible = true;
                    GridView1.Columns[12].Visible = true;
                    GridView1.Columns[13].Visible = true;
                }
                ;
                GridView1.DataSource = qry;
                GridView1.DataBind();
            }
        }
        protected void GridView1_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            GridView1.PageIndex = e.NewPageIndex;
            BindGridView();
        }

        protected void GridView1_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType != DataControlRowType.DataRow)
            {
                return;
            }

            var chkSelect = e.Row.FindControl("chkSelect") as CheckBox;
            if (chkSelect == null)
            {
                return;
            }

            var poAmountObj = DataBinder.Eval(e.Row.DataItem, "PO_Amount");
            decimal poAmount = 0m;
            if (poAmountObj != null)
            {
                decimal.TryParse(poAmountObj.ToString(), out poAmount);
            }

            var maxApprovalLimit = ViewState["MaxApprovalLimit"] != null
                ? (decimal?)ViewState["MaxApprovalLimit"]
                : null;

            //if (maxApprovalLimit.HasValue && poAmount >= maxApprovalLimit.Value)
            //{
            //    chkSelect.Visible = false;
            //}
        }



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
                var form_id = 3;
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
                Label PO_id = row.FindControl("lblPO_ID") as Label;
                Label remainingAmtLabel = row.FindControl("lblRemainingAmount") as Label;
                if (chk.Checked)
                {
                    var user_id = AppConfig.UserID;
                    var form_id = 3;

                    AP_Purchase_Order PO = (from tbl in db.AP_Purchase_Orders
                                            where tbl.PO_ID == Convert.ToInt32(PO_id.Text)
                                            select tbl).SingleOrDefault();
                    if (PO != null && remainingAmtLabel != null)
                    {

                        decimal remainingAmount = Convert.ToDecimal(remainingAmtLabel.Text);

                        var poAmount = (from apoi in db.AP_Purchase_Order_Items
                                        join apo in db.AP_Purchase_Orders on apoi.PO_ID equals apo.PO_ID
                                        where apo.PO_ID == Convert.ToInt32(PO_id.Text)
                                        select (decimal?)apoi.Amount).Sum() ?? 0m;




                        var Budget = (from s in db.sys_Parms
                                      where s.Name == "Budget Working"
                                      select s.Code).FirstOrDefault();

                        if (Budget == "01")
                        {
                            if (poAmount > remainingAmount)
                            {
                                string alertMessage = $"Total PO Amount: ({poAmount}) exceeds the Remaining Amount: ({remainingAmount}).";
                                ClientScript.RegisterStartupScript(this.GetType(), "alert", $"alert('{alertMessage}');", true);
                                return;
                            }
                        }
                        var IsFinalApprovals = (from SASD in db.Sys_Approval_Stage_Details
                                                join SASM in db.Sys_Approval_Stage_Masters on SASD.Stage_ID equals SASM.Stage_ID
                                                join SATD in db.Sys_Approval_Tempelate_Detail_Stages on SASM.Stage_ID equals SATD.StageId
                                                join SATF in db.Sys_Approval_Tempelate_Detail_Forms on SATD.Tempelate_ID equals SATF.Tempelate_ID
                                                where SASD.UserId == user_id && SATF.FormId == form_id && SASM.IsDeleted == false
                                                select new { SASM.IsFinalApproval, SATF.FormId }).ToList();

                        if (IsFinalApprovals.Any(approval => approval.IsFinalApproval == true && approval.FormId == form_id))
                        {
                            var Details = db.spApprovePurchaseOrder(Convert.ToInt32(PO.PO_ID), user_id);
                            db.SubmitChanges();

                            Sys_Approval_Stage_Detail SASD = (from tbl in db.Sys_Approval_Stage_Details
                                                              join SASM in db.Sys_Approval_Stage_Masters on tbl.Stage_ID equals SASM.Stage_ID
                                                              join SATD in db.Sys_Approval_Tempelate_Detail_Stages on SASM.Stage_ID equals SATD.StageId
                                                              join SATF in db.Sys_Approval_Tempelate_Detail_Forms on SATD.Tempelate_ID equals SATF.Tempelate_ID
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
                                    SAL.Entry_ID = PO.PO_ID;
                                    SAL.Form_ID = form_id;
                                    SAL.From_Name = "Purchase Order";
                                    SAL.Remarks = Convert.ToString(PO.Remarks);
                                    SAL.Company_ID = AppConfig.Company_ID;
                                    SAL.IsFinalAprroval = true;
                                    SAL.Entry_Status = "Approved";
                                    SAL.Approve_By = user_id;
                                    SAL.Approve_Date = DateTime.Now;
                                    SAL.IsRejected = false;
                                    db.Sys_Approval_Logs.InsertOnSubmit(SAL);
                                    db.SubmitChanges();
                                }
                            }
                        }
                        else
                        {
                            PO.Status = "Pending";
                            PO.Approved_Time = DateTime.Now;
                            PO.Approved_By = user_id;
                            db.SubmitChanges();
                            Sys_Approval_Stage_Detail SASD = (from tbl in db.Sys_Approval_Stage_Details
                                                              join SASM in db.Sys_Approval_Stage_Masters on tbl.Stage_ID equals SASM.Stage_ID
                                                              join SATD in db.Sys_Approval_Tempelate_Detail_Stages on SASM.Stage_ID equals SATD.StageId
                                                              join SATF in db.Sys_Approval_Tempelate_Detail_Forms on SATD.Tempelate_ID equals SATF.Tempelate_ID
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
                                    SAL.Entry_ID = PO.PO_ID;
                                    SAL.Form_ID = form_id;
                                    SAL.From_Name = "Purchase Order";
                                    SAL.Remarks = Convert.ToString(PO.Remarks);
                                    SAL.Company_ID = AppConfig.Company_ID;
                                    SAL.IsFinalAprroval = false;
                                    SAL.Entry_Status = "Pending";
                                    SAL.Approve_By = user_id;
                                    SAL.Approve_Date = DateTime.Now;
                                    SAL.IsRejected = false;
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
                Label PO_id = row.FindControl("lblPO_ID") as Label;
                if (chk.Checked)
                {
                    var form_id = 3;
                    var user_id = AppConfig.UserID;
                    AP_Purchase_Order PO = (from tbl in db.AP_Purchase_Orders
                                            where tbl.PO_ID == Convert.ToInt32(PO_id.Text)
                                            select tbl).SingleOrDefault();
                    if (PO != null)
                    {
                        PO.Status = "Cancelled";
                        PO.DeletedBy = user_id;
                        PO.Deleted_Time = DateTime.Now;
                        PO.IsDeleted = true;
                        db.SubmitChanges();
                        Sys_Approval_Stage_Detail SASD = (from tbl in db.Sys_Approval_Stage_Details
                                                          join SASM in db.Sys_Approval_Stage_Masters on tbl.Stage_ID equals SASM.Stage_ID
                                                          join SATD in db.Sys_Approval_Tempelate_Detail_Stages on SASM.Stage_ID equals SATD.StageId
                                                          join SATF in db.Sys_Approval_Tempelate_Detail_Forms on SATD.Tempelate_ID equals SATF.Tempelate_ID
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
                                SAL.Entry_ID = PO.PO_ID;
                                SAL.Form_ID = form_id;
                                SAL.From_Name = "Purchase Order";
                                SAL.Remarks = Convert.ToString(PO.Remarks);
                                SAL.Company_ID = AppConfig.Company_ID;
                                SAL.Entry_Status = "Rejected";
                                SAL.IsRejected = true;
                                SAL.Rejected_By = user_id;
                                SAL.Rejected_Date = DateTime.Now;
                                db.Sys_Approval_Logs.InsertOnSubmit(SAL);
                                db.SubmitChanges();
                            }
                        }
                    }
                }
            }
            Response.Redirect(Request.RawUrl);
        }

        // Add this WebMethod at the end of your class
        [WebMethod]
        public static string SaveEditableSettings(string poIds, string checkValues)
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    if (string.IsNullOrEmpty(poIds) || string.IsNullOrEmpty(checkValues))
                    {
                        return "Error: No data provided";
                    }

                    string[] poIdArray = poIds.Split(',');
                    string[] checkValueArray = checkValues.Split(',');

                    if (poIdArray.Length != checkValueArray.Length)
                    {
                        return "Error: Data mismatch";
                    }

                    for (int i = 0; i < poIdArray.Length; i++)
                    {
                        int poId = Convert.ToInt32(poIdArray[i].Trim());
                        bool isEditable = Convert.ToBoolean(checkValueArray[i].Trim());

                        var po = db.AP_Purchase_Orders
                            .Where(p => p.PO_ID == poId && (p.Status == "Created" || p.Status == "Pending"))
                            .FirstOrDefault();

                        if (po == null) continue;

                        var existingLog = db.Sys_Approval_Logs
                            .Where(sal => sal.Entry_ID == poId && sal.Form_ID == 3)
                            .OrderByDescending(sal => sal.Approve_Date)
                            .FirstOrDefault();

                        if (existingLog != null)
                        {
                            existingLog.IsEditableAfterApproval = isEditable;
                        }
                        else
                        {
                            var user_id = AppConfig.UserID;
                            var SASD = (from tbl in db.Sys_Approval_Stage_Details
                                        join SASM in db.Sys_Approval_Stage_Masters on tbl.Stage_ID equals SASM.Stage_ID
                                        join SATD in db.Sys_Approval_Tempelate_Detail_Stages on SASM.Stage_ID equals SATD.StageId
                                        join SATF in db.Sys_Approval_Tempelate_Detail_Forms on SATD.Tempelate_ID equals SATF.Tempelate_ID
                                        where tbl.UserId == user_id && SATF.FormId == 3 && SASM.IsDeleted == false
                                        select tbl).FirstOrDefault();

                            if (SASD != null)
                            {
                                Sys_Approval_Log SAL = new Sys_Approval_Log();
                                SAL.Approval_Template_ID = SASD.Stage_ID;
                                SAL.Approval_Stage_ID = SASD.Stage_ID;
                                SAL.Entry_ID = poId;
                                SAL.Form_ID = 3;
                                SAL.From_Name = "Purchase Order";
                                SAL.Remarks = "Editable setting updated via Save Editable Settings button";
                                SAL.Company_ID = AppConfig.Company_ID;
                                SAL.IsFinalAprroval = false;
                                SAL.Entry_Status = po.Status;
                                SAL.Approve_By = user_id;
                                SAL.Approve_Date = DateTime.Now;
                                SAL.IsRejected = false;
                                SAL.IsEditableAfterApproval = isEditable;
                                db.Sys_Approval_Logs.InsertOnSubmit(SAL);
                            }
                        }
                    }

                    db.SubmitChanges();
                    return "Success";
                }
            }
            catch (Exception ex)
            {
                return "Error: " + ex.Message;
            }
        }

        [WebMethod]
        public static string fillWarehouse()
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    var listItems = (from p in db.DataValues
                                     join v in db.ValueSets on p.ValueSet_ID equals v.ValueSet_ID
                                     where v.ValueSet_Description == "Ware House"
                                     orderby p.DataValue_Name
                                     select new
                                     {
                                         DataValueName = p.DataValue_Name,
                                         DataValueDescription = p.DataValue_Description
                                     }).ToList();
                    return (new System.Web.Script.Serialization.JavaScriptSerializer()).Serialize(listItems);
                }
            }
            catch (Exception ex)
            {
                return "[]";
            }
        }
    }
}