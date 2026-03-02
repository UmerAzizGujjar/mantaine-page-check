using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class ApprovePI : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            
        }
        [WebMethod]
        public static bool CheckUserRights()
        {
            bool hasEntryRights = false;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var form_id = 10;
                var user_id = AppConfig.UserID;

                hasEntryRights = (from SASD in db.Sys_Approval_Stage_Details
                                  join SASM in db.Sys_Approval_Stage_Masters on SASD.Stage_ID equals SASM.Stage_ID
                                  join SATD in db.Sys_Approval_Tempelate_Detail_Stages on SASM.Stage_ID equals SATD.StageId
                                  join SATF in db.Sys_Approval_Tempelate_Detail_Forms on SATD.Tempelate_ID equals SATF.Tempelate_ID
                                  join SATM in db.Sys_Approval_Tempelate_Masters on SATD.Tempelate_ID equals SATM.Tempelate_ID
                                  where SASD.UserId == user_id && SATF.FormId == form_id && SATM.IsActive == true && SASM.IsDeleted == false
                                  select SASD).Any();
            }
            return hasEntryRights;
        }

        [WebMethod]
        public static string ApproveSelectedPIs(List<int> PIIds)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            foreach (int id in PIIds)
            {
                var user_id = AppConfig.UserID;

                var PUR_id = id;
                var form_id = 10;
                 
                Purchase_Invoice_Master PIM = (from tbl in db.Purchase_Invoice_Masters
                                               where tbl.PurchaseInvoiceId == Convert.ToInt32(PUR_id)
                                               select tbl).SingleOrDefault();
                if (PIM != null)
                {
                    var IsFinalApprovals = (from SASD in db.Sys_Approval_Stage_Details
                                            join SASM in db.Sys_Approval_Stage_Masters on SASD.Stage_ID equals SASM.Stage_ID
                                            join SATD in db.Sys_Approval_Tempelate_Detail_Stages on SASM.Stage_ID equals SATD.StageId
                                            join SATF in db.Sys_Approval_Tempelate_Detail_Forms on SATD.Tempelate_ID equals SATF.Tempelate_ID
                                            where SASD.UserId == user_id && SATF.FormId == form_id && SASM.IsDeleted == false
                                            select new { SASM.IsFinalApproval, SATF.FormId }).ToList();

                    if (IsFinalApprovals.Any(approval => approval.IsFinalApproval == true && approval.FormId == form_id))
                    {
                        var PICondition = (from sys in db.sys_Parms
                                           where sys.Name == "Direct PO ON Purchase Invoice"
                                           select sys.Code).FirstOrDefault();

                        if (PICondition == "01")
                        {
                            var Details = db.spApprovePurchaseInvoice_DirectFromPO(Convert.ToInt32(PIM.PurchaseInvoiceId), user_id);
                        }
                        else
                        {
                            var Details = db.spApprovePurchase(Convert.ToInt32(PIM.PurchaseInvoiceId), user_id);
                        }
                            

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
                                SAL.Entry_ID = Convert.ToInt32(PIM.PurchaseInvoiceId);
                                SAL.Form_ID = form_id;
                                SAL.From_Name = "Purchase Invoice";
                                SAL.Remarks = Convert.ToString(PIM.Remarks);
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
                        PIM.Status = "Pending";
                        PIM.Approved_Time = DateTime.Now;
                        PIM.Approved_By = user_id;
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
                                SAL.Entry_ID = Convert.ToInt32(PIM.PurchaseInvoiceId);
                                SAL.Form_ID = form_id;
                                SAL.From_Name = "Purchase Invoice";
                                SAL.Remarks = Convert.ToString(PIM.Remarks);
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
            return "1";
        }
        [WebMethod]
        public static string RejectSelectedPIs(List<int> PIIds)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            foreach (int id in PIIds)
            {
                var user_id = AppConfig.UserID;
                var PIM_id = id;
                var form_id = 10;
                Purchase_Invoice_Master PM = (from tbl in db.Purchase_Invoice_Masters
                                              where tbl.PurchaseInvoiceId == Convert.ToInt32(PIM_id)
                                              select tbl).SingleOrDefault();
                if (PM != null)
                {
                    PM.Status = "Cancelled";
                    PM.UpdatedBy = user_id;
                    PM.UpdatedDate = DateTime.Now;
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
                            SAL.Entry_ID = Convert.ToInt32(PM.PurchaseInvoiceId);
                            SAL.Form_ID = form_id;
                            SAL.From_Name = "Purchase Invoice";
                            SAL.Remarks = Convert.ToString(PM.Remarks);
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
            return "1";
        }
        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var db = new DataBaseDataContext())
                {

                    var Total_Data = db.Purchase_Invoice_Masters.Count();
                    var formattedQuery = from a in db.Purchase_Invoice_Masters
                              where a.Status == "Created" || a.Status == "Pending"
                              &&(a.InvoiceNum.ToString().Contains(searchValue) || a.Remarks.ToString().Contains(searchValue) ||
                              a.Status.ToString().Contains(searchValue) || a.InvoiceDate.ToString().Contains(searchValue))
                              orderby a.PurchaseInvoiceId ascending
                              select new
                              {
                                  PIID = a.PurchaseInvoiceId,
                                  PINO = a.InvoiceNum,
                                  REMARKS = a.Remarks,
                                  STATUS = a.Status,
                                  PIDATE = a.InvoiceDate,
                                  CREATOR  = db.aspnet_Users.Where(x => x.UserId == (a.CreatedBy ?? Guid.Empty) && (x.UserName.ToString().Contains(searchValue))).Select(x => x.UserName).FirstOrDefault(),
                                  APPROVEBY = string.Join(", ", (from SAL in db.Sys_Approval_Logs
                                                                  join user in db.aspnet_Users on SAL.Approve_By equals user.UserId into userGroup
                                                                  from usr in userGroup.DefaultIfEmpty()
                                                                  where a.PurchaseInvoiceId == SAL.Entry_ID && SAL.Form_ID == 10
                                                                  &&(usr.UserName.ToString().Contains(searchValue))

                                                                 select usr.UserName ?? "").Distinct())
                              };
                    var FilteredCount = formattedQuery.Count();
                    // Sorting
                    if (!string.IsNullOrEmpty(sortColumn) && !string.IsNullOrEmpty(sortColumnDirection))
                    {
                        switch (sortColumn)
                        {

                            case "PINO":
                                formattedQuery = sortColumnDirection == "asc"
                                    ? formattedQuery.OrderBy(x => x.PINO)
                                    : formattedQuery.OrderByDescending(x => x.PINO);
                                break;

                            case "PIDATE":
                                formattedQuery = sortColumnDirection == "asc"
                                    ? formattedQuery.OrderBy(x => x.PIDATE)
                                    : formattedQuery.OrderByDescending(x => x.PIDATE);
                                break;


                            default:
                                formattedQuery = formattedQuery.OrderByDescending(x => x.PINO);
                                break;
                        }
                    }




                    var DataList = formattedQuery.Skip(start).Take(length).ToList();


                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Data, data = DataList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching patient list", ex);
            }
        }



    }
}