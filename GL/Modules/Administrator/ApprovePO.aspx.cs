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

        }
        [WebMethod]
        public static bool CheckUserRights()
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
            return hasEntryRights;
        }

        [WebMethod]
        public static string ApproveSelectedPOs(List<int> POIds)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            foreach (int id in POIds)
            {
                var user_id = AppConfig.UserID;
                var form_id = 3;
                var PO_id = id;
                AP_Purchase_Order PO = (from tbl in db.AP_Purchase_Orders
                                        where tbl.PO_ID == Convert.ToInt32(PO_id)
                                        select tbl).SingleOrDefault();
                if (PO != null)
                {
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
            return "1";
        }
        [WebMethod]
        public static string RejectSelectedPOs(List<int> POIds)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            foreach (int id in POIds)
            {
                var user_id = AppConfig.UserID;
                var form_id = 3;
                var PO_id = id;
                AP_Purchase_Order PO = (from tbl in db.AP_Purchase_Orders
                                        where tbl.PO_ID == Convert.ToInt32(PO_id)
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
            return "1";
        }
        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var db = new DataBaseDataContext())
                {
                    var Total_Data = db.AP_Purchase_Orders.Count();


                    var userDepartments = db.Department_Wise_User_Details
                    .Where(dept => dept.User_Id == AppConfig.UserID)
                    .Select(dept => dept.Department)
                    .ToList();
                    var qry = (from a in db.AP_Purchase_Orders
                               join apoi in db.AP_Purchase_Order_Items on a.PO_ID equals apoi.PO_ID
                               join prd in db.Purchase_Requisition_Details on Convert.ToInt32(apoi.PRDetailId) equals prd.PR_Detail_ID
                               join pr in db.Purchase_Requisitions on prd.PR_ID equals pr.PR_Id
                               where (a.Status == "Created" || a.Status == "Pending") && a.IsDeleted == false && userDepartments.Contains(pr.Department)
                               && (a.PO_No.ToString().Contains(searchValue) || a.Remarks.Contains(searchValue) || a.Status.ToString().Contains(searchValue) || a.Created_By.ToString().Contains(searchValue))
                               group new { a, apoi, pr, prd } by new
                               {
                                   a.PO_ID,
                                   a.PO_No,
                                   a.Remarks,
                                   a.Status,
                                   a.PO_Date,
                                   a.Created_By,
                                   Department = pr.Department
                               } into g
                               select new
                               {
                                   g.Key.PO_ID,
                                   g.Key.PO_No,
                                   g.Key.Remarks,
                                   g.Key.Status,
                                   g.Key.PO_Date,
                                   Creator = db.aspnet_Users.Where(x => x.UserId == (g.Key.Created_By ?? Guid.Empty)).Select(x => x.UserName).FirstOrDefault(),
                                   Approve_By = string.Join(", ", (from SAL in db.Sys_Approval_Logs
                                                                   join user in db.aspnet_Users on SAL.Approve_By equals user.UserId into userGroup
                                                                   from usr in userGroup.DefaultIfEmpty()
                                                                   where g.Key.PO_ID == SAL.Entry_ID && SAL.Form_ID == 3
                                                                   select usr.UserName ?? "").Distinct()),
                                   Department = db.GetDataValueName("Department", g.Key.Department),

                               });

                    var formattedQuery = qry.AsEnumerable().Select(x => new
                    {
                        POID = x.PO_ID,
                        PONO = x.PO_No.ToString(),
                        REMARKS = x.Remarks,
                        STATUS = x.Status,
                        CREATOR = x.Creator,
                        PODATE = Convert.ToDateTime(x.PO_Date).ToString("dd-MMM-yyyy"),
                        APPROVEBY = x.Approve_By,
                        DEPARTMENT = x.Department,
                    });






                    var FilteredCount = qry.Count();
                    // Sorting
                    if (!string.IsNullOrEmpty(sortColumn) && !string.IsNullOrEmpty(sortColumnDirection))
                    {
                        switch (sortColumn)
                        {
                            case "POID":
                                formattedQuery = sortColumnDirection == "asc"
                                    ? formattedQuery.OrderBy(x => x.POID)
                                    : formattedQuery.OrderByDescending(x => x.POID);
                                break;

                            case "PONO":
                                formattedQuery = sortColumnDirection == "asc"
                                    ? formattedQuery.OrderBy(x => x.PONO)
                                    : formattedQuery.OrderByDescending(x => x.PONO);
                                break;

                            case "PODATE":
                                formattedQuery = sortColumnDirection == "asc"
                                    ? formattedQuery.OrderBy(x => x.PODATE)
                                    : formattedQuery.OrderByDescending(x => x.PODATE);
                                break;

                            case "CREATOR":
                                formattedQuery = sortColumnDirection == "asc"
                                    ? formattedQuery.OrderBy(x => x.CREATOR)
                                    : formattedQuery.OrderByDescending(x => x.CREATOR);
                                break;

                            case "DEPARTMENT":
                                formattedQuery = sortColumnDirection == "asc"
                                    ? formattedQuery.OrderBy(x => x.DEPARTMENT)
                                    : formattedQuery.OrderByDescending(x => x.DEPARTMENT);
                                break;

                            case "REMARKS":
                                formattedQuery = sortColumnDirection == "asc"
                                    ? formattedQuery.OrderBy(x => x.REMARKS)
                                    : formattedQuery.OrderByDescending(x => x.REMARKS);
                                break;

                            case "STATUS":
                                formattedQuery = sortColumnDirection == "asc"
                                    ? formattedQuery.OrderBy(x => x.STATUS)
                                    : formattedQuery.OrderByDescending(x => x.STATUS);
                                break;

                            case "APPROVEBY":
                                formattedQuery = sortColumnDirection == "asc"
                                    ? formattedQuery.OrderBy(x => x.APPROVEBY)
                                    : formattedQuery.OrderByDescending(x => x.APPROVEBY);
                                break;

                            default:
                                formattedQuery = formattedQuery.OrderByDescending(x => x.PONO);
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