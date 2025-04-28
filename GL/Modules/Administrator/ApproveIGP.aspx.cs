using PMS.Inventory;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class ApproveIGP : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!Page.IsPostBack)
            {
                BindGridView();
                CheckUserRights();
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
                var qry = (from a in db.Igp_masters
                           join igpd in db.Igp_Details on a.Igp_Id equals igpd.Igp_Id
                           join apoi in db.AP_Purchase_Order_Items on Convert.ToInt32(igpd.PO_Item_ID) equals apoi.PO_Item_ID
                           join prd in db.Purchase_Requisition_Details on Convert.ToInt32(apoi.PRDetailId) equals prd.PR_Detail_ID
                           join pr in db.Purchase_Requisitions on prd.PR_ID equals pr.PR_Id
                           where (a.Inspec_Status==null || a.Inspec_Status=="Created" || a.Inspec_Status == "Pending") && a.IsDeleted == false && userDepartments.Contains(pr.Department)
                           group new { a, apoi, pr, prd } by new
                           {
                               a.Igp_Id,
                               a.Igp_num,
                               a.Remarks,
                               a.Status,
                               a.Igp_date,
                               a.Inspec_Status,
                               a.Created_By,
                               a.Approved_By,
                               Department = pr.Department
                           } into g
                           select new
                           {
                               g.Key.Igp_Id,
                               g.Key.Igp_num,
                               g.Key.Remarks,
                               g.Key.Status,
                               g.Key.Igp_date,
                               g.Key.Inspec_Status,
                               Creator = db.aspnet_Users.Where(x => x.UserId == (g.Key.Created_By ?? Guid.Empty)).Select(x => x.UserName).FirstOrDefault(),
                               Approve_By = string.Join(", ", (from SAL in db.Sys_Approval_Logs
                                                               join user in db.aspnet_Users on SAL.Approve_By equals user.UserId into userGroup
                                                               from usr in userGroup.DefaultIfEmpty()
                                                               where g.Key.Igp_Id == SAL.Entry_ID && SAL.Form_ID == 4
                                                               select usr.UserName ?? "").Distinct()),
                               Department = db.GetDataValueName("Department", g.Key.Department)
                           });

                var formattedQuery = qry.AsEnumerable().Select(x => new
                {
                    x.Igp_Id,
                    x.Igp_num,
                    x.Remarks,
                    x.Status,
                    x.Inspec_Status,
                    x.Creator,
                    Igp_date = Convert.ToDateTime(x.Igp_date).ToString("dd-MMM-yyyy"),
                    x.Approve_By,
                    x.Department
                });                

                GridView1.DataSource = qry;
                GridView1.DataBind();
            }
        }
      
        private void CheckUserRights()
        {
            bool hasEntryRights = false;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var form_id = 4;
                var user_id = AppConfig.UserID;

                hasEntryRights = (from SASD in db.Sys_Approval_Stage_Details
                                  join SASM in db.Sys_Approval_Stage_Masters on SASD.Stage_ID equals SASM.Stage_ID
                                  join SATD in db.Sys_Approval_Tempelate_Detail_Stages on SASM.Stage_ID equals SATD.StageId
                                  join SATF in db.Sys_Approval_Tempelate_Detail_Forms on SATD.Tempelate_ID equals SATF.Tempelate_ID
                                  join SATM in db.Sys_Approval_Tempelate_Masters on SATD.Tempelate_ID equals SATM.Tempelate_ID
                                  where SASD.UserId == user_id && SATF.FormId == form_id && SATM.IsActive == true
                                  select SASD).Any();
            }
            btnApprove.Visible = hasEntryRights;
        }     

        protected void GridView1_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            GridView1.PageIndex = e.NewPageIndex;
            BindGridView();
        }
        protected void btnApprove_Click(object sender, EventArgs e)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            foreach (GridViewRow row in GridView1.Rows)
            {
                CheckBox chk = row.FindControl("chkSelect") as CheckBox;
                Label IGP_id = row.FindControl("lblIGP_ID") as Label;
                if (chk.Checked)
                {
                    var user_id = AppConfig.UserID;
                    var form_id = 4;

                    Igp_master IGP = (from tbl in db.Igp_masters
                                      where tbl.Igp_Id == Convert.ToInt32(IGP_id.Text)
                                            select tbl).SingleOrDefault();
                    if (IGP != null)
                    {
                        var IsFinalApprovals = (from SASD in db.Sys_Approval_Stage_Details
                                                join SASM in db.Sys_Approval_Stage_Masters on SASD.Stage_ID equals SASM.Stage_ID
                                                join SATD in db.Sys_Approval_Tempelate_Detail_Stages on SASM.Stage_ID equals SATD.StageId
                                                join SATF in db.Sys_Approval_Tempelate_Detail_Forms on SATD.Tempelate_ID equals SATF.Tempelate_ID
                                                where SASD.UserId == user_id && SATF.FormId == form_id && SASM.IsDeleted == false
                                                select new { SASM.IsFinalApproval, SATF.FormId }).ToList();

                        if (IsFinalApprovals.Any(approval => approval.IsFinalApproval == true && approval.FormId == form_id))
                        {
                            if (IGP.Status!="Approved" && IGP.Inspec_Status!="Approved")
                            {
                                var Details = db.spApproveIgp(Convert.ToInt32(IGP.Igp_Id), user_id);
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
                                        SAL.Entry_ID = Convert.ToInt32(IGP.Igp_Id);
                                        SAL.Form_ID = form_id;
                                        SAL.From_Name = "Inward Gate Pass";
                                        SAL.Remarks = Convert.ToString(IGP.Remarks);
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
                            
                        }
                        else
                        {
                            IGP.Status = "Pending";
                            IGP.Approved_Time = DateTime.Now;
                            IGP.Approved_By = user_id;
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
                                    SAL.Entry_ID = Convert.ToInt32(IGP.Igp_Id);
                                    SAL.Form_ID = form_id;
                                    SAL.From_Name = "Inward Gate Pass";
                                    SAL.Remarks = Convert.ToString(IGP.Remarks);
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
                Label IGP_id = row.FindControl("lblIGP_ID") as Label;
                if (chk.Checked)
                {
                    var form_id = 4;
                    var user_id = AppConfig.UserID;
                    Igp_master IGP = (from tbl in db.Igp_masters
                                      where tbl.Igp_Id == Convert.ToInt32(IGP_id.Text)
                                            select tbl).SingleOrDefault();
                    if (IGP != null)
                    {
                        IGP.Status = "Cancelled";
                        IGP.DeletedBy = user_id;
                        IGP.Deleted_Time = DateTime.Now;
                        IGP.IsDeleted = true;
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
                                SAL.Entry_ID = Convert.ToInt32(IGP.Igp_Id);
                                SAL.Form_ID = form_id;
                                SAL.From_Name = "Inward Gate Pass";
                                SAL.Remarks = Convert.ToString(IGP.Remarks);
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
    }
}