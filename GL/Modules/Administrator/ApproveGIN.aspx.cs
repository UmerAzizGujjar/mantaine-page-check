using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class ApproveGIN : System.Web.UI.Page
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
                var form_id = 6;
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
        public static string ApproveSelectedGINs(List<int> GINIds)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            foreach (int id in GINIds)
            {
                var user_id = AppConfig.UserID;
                var StoreIssue_id = id;
                var form_id = 6;

                Store_Issue SI = (from tbl in db.Store_Issues
                                  where tbl.Store_Issue_Id == Convert.ToInt32(StoreIssue_id )
                                  select tbl).SingleOrDefault();
                if (SI != null)
                {
                    var IsFinalApprovals = (from SASD in db.Sys_Approval_Stage_Details
                                            join SASM in db.Sys_Approval_Stage_Masters on SASD.Stage_ID equals SASM.Stage_ID
                                            join SATD in db.Sys_Approval_Tempelate_Detail_Stages on SASM.Stage_ID equals SATD.StageId
                                            join SATF in db.Sys_Approval_Tempelate_Detail_Forms on SATD.Tempelate_ID equals SATF.Tempelate_ID
                                            where SASD.UserId == user_id  && SASM.IsDeleted == false
                                            select new { SASM.IsFinalApproval, SATF.FormId }).ToList();

                    if (IsFinalApprovals.Any(approval => approval.IsFinalApproval == true && approval.FormId == form_id))
                    {
                        var Details = db.spApproveStore_Issue(Convert.ToInt32(SI.Store_Issue_Id), user_id);
                        db.SubmitChanges();


                        Sys_Approval_Stage_Detail SASD = (from tbl in db.Sys_Approval_Stage_Details
                                                          join SASM in db.Sys_Approval_Stage_Masters on tbl.Stage_ID equals SASM.Stage_ID
                                                          join SATD in db.Sys_Approval_Tempelate_Detail_Stages on SASM.Stage_ID equals SATD.StageId
                                                          join SATF in db.Sys_Approval_Tempelate_Detail_Forms on SATD.Tempelate_ID equals SATF.Tempelate_ID
                                                          where tbl.UserId == user_id && SASM.IsFinalApproval == true && SATF.FormId == form_id &&   SASM.IsDeleted == false
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
                                SAL.Entry_ID = SI.Store_Issue_Id;
                                SAL.Form_ID = form_id;
                                SAL.From_Name = "Goods Issuance Note";
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
                        SI.Status = "Pending";
                        SI.Approved_Time = DateTime.Now;
                        SI.Approved_By = user_id;
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
                                SAL.Entry_ID = SI.Store_Issue_Id;
                                SAL.Form_ID = form_id;
                                SAL.From_Name = "Goods Issuance Note";
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
        public static string RejectSelectedGINs(List<int> GINIds)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            foreach (int id in GINIds)
            {
                var user_id = AppConfig.UserID;
                 var StoreIssue_id = id;
                var form_id = 6;
                 Store_Issue SI = (from tbl in db.Store_Issues
                                  where tbl.Store_Issue_Id == Convert.ToInt32(StoreIssue_id)
                                  select tbl).SingleOrDefault();
                if (SI != null)
                {
                    SI.Status = "Cancelled";
                    SI.Deleted_By = Convert.ToString(user_id);
                    SI.Deleted_Date = DateTime.Now;
                    SI.IsDeleted = true;
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
                            SAL.Entry_ID = SI.Store_Issue_Id;
                            SAL.Form_ID = form_id;
                            SAL.From_Name = "Goods Issuance Note";
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
                    var Total_Data = db.Store_Issues.Count();


                    var userDepartmentIds = db.Department_Wise_User_Details
                 .Where(dept => dept.User_Id == AppConfig.UserID)
                .Select(dept => dept.Department) // assuming 'Department' here is the Department_Id (int or Guid)
                 .ToList();

                    // Apply filtering including user's departments
                    var formattedQuery = from a in db.Store_Issues
                                         where (a.Status == "Created" || a.Status == "Pending")
                                               && a.IsDeleted == false
                                              && userDepartmentIds.Contains(a.Department_Id)
                                               && (a.Store_Issue_No.ToString().Contains(searchValue)
                                                   || a.Status.ToString().Contains(searchValue))
                                         orderby a.Store_Issue_Id ascending
                                         select new
                                         {
                                             SIID = a.Store_Issue_Id,
                                             SINO = a.Store_Issue_No,
                                             STATUS = a.Status,
                                             CREATOR = db.aspnet_Users
                                                       .Where(x => x.UserId == (a.Created_by ?? Guid.Empty))
                                                       .Select(x => x.UserName)
                                                       .FirstOrDefault(),
                                             APPROVEBY = string.Join(", ", (from SAL in db.Sys_Approval_Logs
                                                                            join user in db.aspnet_Users on SAL.Approve_By equals user.UserId into userGroup
                                                                            from usr in userGroup.DefaultIfEmpty()
                                                                            where a.Store_Issue_Id == SAL.Entry_ID && SAL.Form_ID == 6
                                                                            select usr.UserName ?? "").Distinct()),
                                             Department = db.GetDataValueName("Department", a.Department_Id),
                                         };

                    var FilteredCount = formattedQuery.Count();
                    // Sorting
                    if (!string.IsNullOrEmpty(sortColumn) && !string.IsNullOrEmpty(sortColumnDirection))
                    {
                        switch (sortColumn)
                        {
                            
                            case "SINO":
                                formattedQuery = sortColumnDirection == "asc"
                                    ? formattedQuery.OrderBy(x => x.SINO)
                                    : formattedQuery.OrderByDescending(x => x.SINO);
                                break;

                           
                            default:
                                formattedQuery = formattedQuery.OrderByDescending(x => x.SINO);
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