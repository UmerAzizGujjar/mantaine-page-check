using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class ApproveGIR : System.Web.UI.Page
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
                    var qry = from a in db.MaterialIssueRequests
                              where a.Status == "Created" || a.Status == "Pending" 
                              orderby a.MaterialRequest_Id ascending
                              select new
                              {
                                  a.MaterialRequest_Id,
                                  a.Request_No,
                                  a.Remarks,
                                  a.Status,
                                  a.MIRDate,
                                  Creator = db.aspnet_Users.Where(x => x.UserId == (a.Created_By ?? Guid.Empty)).Select(x => x.UserName).FirstOrDefault(),
                                  Approve_By = string.Join(", ", (from SAL in db.Sys_Approval_Logs
                                                                  join user in db.aspnet_Users on SAL.Approve_By equals user.UserId into userGroup
                                                                  from usr in userGroup.DefaultIfEmpty()
                                                                  where a.MaterialRequest_Id == SAL.Entry_ID && SAL.Form_ID==5
                                                                  select usr.UserName ?? "").Distinct())
                              };
                    GridView1.DataSource = qry;
                    GridView1.DataBind();
                }
            }
       
        private void CheckUserRights()
        {
            bool hasEntryRights = false;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var form_id = 5;
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
                    Label MAT_id = row.FindControl("lblMAT_ID") as Label;
                    if (chk.Checked)
                    {
                    var user_id = AppConfig.UserID;
                    var form_id = 5;
                    MaterialIssueRequest MIR = (from tbl in db.MaterialIssueRequests
                                                where tbl.MaterialRequest_Id == Convert.ToInt32(MAT_id.Text)
                                                select tbl).SingleOrDefault();
                        if (MIR != null)
                        {
                        var IsFinalApprovals = (from SASD in db.Sys_Approval_Stage_Details
                                                join SASM in db.Sys_Approval_Stage_Masters on SASD.Stage_ID equals SASM.Stage_ID
                                                join SATD in db.Sys_Approval_Tempelate_Detail_Stages on SASM.Stage_ID equals SATD.StageId
                                                join SATF in db.Sys_Approval_Tempelate_Detail_Forms on SATD.Tempelate_ID equals SATF.Tempelate_ID
                                                where SASD.UserId == user_id && SATF.FormId == form_id && SASM.IsDeleted == false
                                                select new { SASM.IsFinalApproval, SATF.FormId }).ToList();

                        if (IsFinalApprovals.Any(approval => approval.IsFinalApproval == true && approval.FormId == form_id))
                        {
                            var Details = db.spApproveMIR(Convert.ToInt32(MIR.MaterialRequest_Id), user_id);
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
                                    SAL.Entry_ID = Convert.ToInt32(MIR.MaterialRequest_Id);
                                    SAL.Form_ID = 5;
                                    SAL.From_Name = "Goods Issuance Request";
                                    SAL.Remarks = Convert.ToString(MIR.Remarks);
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
                                MIR.Status = "Pending";
                                MIR.Approved_Time = DateTime.Now;
                                MIR.Approved_By = user_id;
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
                                    SAL.Entry_ID = Convert.ToInt32(MIR.MaterialRequest_Id);
                                    SAL.Form_ID = form_id;
                                    SAL.From_Name = "Goods Issuance Request";
                                    SAL.Remarks = Convert.ToString(MIR.Remarks);
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
                    Label MIR_id = row.FindControl("lblMAT_ID") as Label;
                    if (chk.Checked)
                    {
                    var form_id = 5;
                    var user_id = AppConfig.UserID;
                    MaterialIssueRequest MIR = (from tbl in db.MaterialIssueRequests
                                                where tbl.MaterialRequest_Id == Convert.ToInt32(MIR_id.Text)
                                                select tbl).SingleOrDefault();
                    if (MIR != null)
                    {
                        MIR.Status = "Cancelled";
                        MIR.Updated_By = user_id;
                        MIR.Update_Date = DateTime.Now;
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
                                SAL.Entry_ID = Convert.ToInt32(MIR.MaterialRequest_Id);
                                SAL.Form_ID = form_id;
                                SAL.From_Name = "Goods Issuance Request";
                                SAL.Remarks = Convert.ToString(MIR.Remarks);
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