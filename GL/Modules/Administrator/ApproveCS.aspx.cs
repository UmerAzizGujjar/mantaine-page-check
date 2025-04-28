using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class ApproveCS : System.Web.UI.Page
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
                var qry = (from a in db.CS_Vendor_Masters
                           join apoi in db.CS_Vendors on a.CS_Ven_Master_ID equals apoi.CS_Master_ID
                           join prd in db.Purchase_Requisition_Details on Convert.ToInt32(apoi.PR_Detail_ID) equals prd.PR_Detail_ID
                           join pr in db.Purchase_Requisitions on prd.PR_ID equals pr.PR_Id
                           where (a.Status == "Created" || a.Status == "Pending") && a.IsDeleted == false && userDepartments.Contains(pr.Department)
                           group new { a, apoi, pr, prd } by new
                           {

                               a.CS_Ven_Master_ID,
                               a.CS_Ven_No,
                               a.Remarks,
                               a.Status,
                               a.CS_Date,
                               a.Created_By,
                               a.Approved_By,
                               Department = pr.Department
                           } into g
                           select new
                           {
                               g.Key.CS_Ven_Master_ID,
                               g.Key.CS_Ven_No,
                               g.Key.Remarks,
                               g.Key.Status,
                               g.Key.CS_Date,
                               Creator = db.aspnet_Users.Where(x => x.UserId == (g.Key.Created_By ?? Guid.Empty)).Select(x => x.UserName).FirstOrDefault(),
                               Approve_By = string.Join(", ", (from SAL in db.Sys_Approval_Logs
                                                               join user in db.aspnet_Users on SAL.Approve_By equals user.UserId into userGroup
                                                               from usr in userGroup.DefaultIfEmpty()
                                                               where g.Key.CS_Ven_Master_ID == SAL.Entry_ID && SAL.Form_ID == 2
                                                               select usr.UserName ?? "").Distinct()),
                               Department = db.GetDataValueName("Department", g.Key.Department)                             
                           });

                var formattedQuery = qry.AsEnumerable().Select(x => new
                {
                    x.CS_Ven_Master_ID,
                    x.CS_Ven_No,
                    x.Remarks,
                    x.Status,
                    x.Creator,
                    CS_Date = Convert.ToDateTime(x.CS_Date).ToString("dd-MMM-yyyy"),
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
                var form_id = 2;
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
            var form_id = 2;
            var user_id = AppConfig.UserID;
            foreach (GridViewRow row in GridView1.Rows)
            {
                CheckBox chk = row.FindControl("chkSelect") as CheckBox;
                Label Cs_id = row.FindControl("lblCS_Ven_Master_ID") as Label;
                if (chk.Checked)
                {
                    TextBox txtApprovalRemarks = row.FindControl("txtApproval_RejectionRemarks") as TextBox;
                    string approvalRemarks = txtApprovalRemarks?.Text;

                    int cs_id = Convert.ToInt32(Cs_id.Text);
                    CS_Vendor_Master cs = db.CS_Vendor_Masters.FirstOrDefault(tbl => tbl.CS_Ven_Master_ID == cs_id);
                    if (cs != null)
                    {
                        var vendorList = db.CS_Vendors.Where(tbl => tbl.CS_Master_ID == cs_id).ToList();
                        if (vendorList.Any())
                        {
                            foreach (var cv in vendorList)
                            {
                                Purchase_Requisition_Detail PRD = db.Purchase_Requisition_Details.FirstOrDefault(tbl => tbl.PR_Detail_ID == cv.PR_Detail_ID);
                                if (PRD == null)
                                {
                                    ScriptManager.RegisterStartupScript(this, GetType(), "alertMessage", "alert('Error: PR Detail record not found.');", true);
                                    return;
                                }
                                decimal totalprQty = PRD.Qty ?? 0;
                                decimal sumOfQuantities = 0;
                                if (cv.Vendor_bit_1 == true)
                                    sumOfQuantities += cv.Qty1 ?? 0;
                                if (cv.Vendor_bit_2 == true)
                                    sumOfQuantities += cv.Qty2 ?? 0;
                                if (cv.Vendor_bit_3 == true)
                                    sumOfQuantities += cv.Qty3 ?? 0;
                                if (cv.Vendor_bit_4 == true)
                                    sumOfQuantities += cv.Qty4 ?? 0;
                                if (cv.Vendor_bit_5 == true)
                                    sumOfQuantities += cv.Qty5 ?? 0;
                                if (sumOfQuantities > totalprQty)
                                {
                                    ScriptManager.RegisterStartupScript(this, GetType(), "alertMessage", "alert('Sum of Vendors Item Quantities must be less than or equal to Total PR Quantity.');", true);
                                    return;
                                }

                                int vendorCount = 0;
                                if (cv.Vendor1 != null && cv.Vendor1 != "0")
                                    vendorCount++;
                                if (cv.Vendor2 != null && cv.Vendor2 != "0")
                                    vendorCount++;
                                if (cv.Vendor3 != null && cv.Vendor3 != "0")
                                    vendorCount++;
                                if (cv.Vendor4 != null && cv.Vendor4 != "0")
                                    vendorCount++;
                                if (cv.Vendor5 != null && cv.Vendor5 != "0")
                                    vendorCount++;

                                if (vendorCount < 2)
                                {
                                    ScriptManager.RegisterStartupScript(this, GetType(), "alertMessage", "alert('Please Select at least 2 Vendors before approval');", true);
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
                                var Details = db.spApproveCs(Convert.ToInt32(cs.CS_Ven_Master_ID), user_id);
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
                                        SAL.Entry_ID = cs.CS_Ven_Master_ID;
                                        SAL.Form_ID = form_id;
                                        SAL.From_Name = "Comparative Statement";
                                        SAL.Remarks = Convert.ToString(cs.Remarks);
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
                                cs.Status = "Pending";
                                cs.Approved_Time = DateTime.Now;
                                cs.Approved_By = user_id;
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
                                        SAL.Entry_ID = cs.CS_Ven_Master_ID;
                                        SAL.Form_ID = form_id;
                                        SAL.From_Name = "Comparative Statement";
                                        SAL.Remarks = Convert.ToString(cs.Remarks);
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
                        }
                        else
                        {
                            ScriptManager.RegisterStartupScript(this, GetType(), "alertMessage", "alert('Error: No associated Vendors found.');", true);
                            return;
                        }
                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, GetType(), "alertMessage", "alert('Error: CS_Vendor_Master record not found.');", true);
                        return;
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
                Label cs_id = row.FindControl("lblCS_Ven_Master_ID") as Label;
                if (chk.Checked)
                {
                    TextBox txtrejectionRemarks = row.FindControl("txtApproval_RejectionRemarks") as TextBox;
                    string rejectionRemarks = txtrejectionRemarks?.Text;
                    var form_id = 2;
                    var user_id = AppConfig.UserID;
                    CS_Vendor_Master cs = (from tbl in db.CS_Vendor_Masters
                                           where tbl.CS_Ven_Master_ID == Convert.ToInt32(cs_id.Text)
                                           select tbl).SingleOrDefault();
                    if (cs != null)
                    {
                        cs.Status = "Cancelled";
                        cs.Deleted_By = user_id;
                        cs.Deleted_Time = DateTime.Now;
                        cs.IsDeleted = true;
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
                                SAL.Entry_ID = cs.CS_Ven_Master_ID;
                                SAL.Form_ID = form_id;
                                SAL.From_Name = "Comparative Statement";
                                SAL.Remarks = Convert.ToString(cs.Remarks);
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
    }
}