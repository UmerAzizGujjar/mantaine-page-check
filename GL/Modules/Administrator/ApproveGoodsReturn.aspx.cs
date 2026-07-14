using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.Administrator
{
    public partial class ApproveGoodsReturn : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static bool CheckUserRights()
        {
            try
            {
                Debug.WriteLine("=== CheckUserRights Called ===");
                Debug.WriteLine("User ID: " + AppConfig.UserID);

                bool hasEntryRights = false;
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var form_id = 7;
                    var user_id = AppConfig.UserID;

                    hasEntryRights = (from SASD in db.Sys_Approval_Stage_Details
                                      join SASM in db.Sys_Approval_Stage_Masters on SASD.Stage_ID equals SASM.Stage_ID
                                      join SATD in db.Sys_Approval_Tempelate_Detail_Stages on SASM.Stage_ID equals SATD.StageId
                                      join SATF in db.Sys_Approval_Tempelate_Detail_Forms on SATD.Tempelate_ID equals SATF.Tempelate_ID
                                      join SATM in db.Sys_Approval_Tempelate_Masters on SATD.Tempelate_ID equals SATM.Tempelate_ID
                                      where SASD.UserId == user_id
                                            && SATF.FormId == form_id
                                            && SATM.IsActive == true
                                            && SASM.IsDeleted == false
                                      select SASD).Any();

                    Debug.WriteLine("Has Rights: " + hasEntryRights);
                }
                return hasEntryRights;
            }
            catch (Exception ex)
            {
                Debug.WriteLine("CheckUserRights Error: " + ex.ToString());
                return false;
            }
        }

        [WebMethod]
        public static string ApproveSelectedGRVs(List<int> GRVIds)
        {
            try
            {
                Debug.WriteLine("=== ApproveSelectedGRVs Called ===");
                Debug.WriteLine("IDs to approve: " + string.Join(", ", GRVIds));


                using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    var user_id = AppConfig.UserID;
                    var form_id = 7;

                    foreach (int id in GRVIds)
                    {
                        Debug.WriteLine("\n--- Processing GRN ID: " + id + " ---");

                        Goods_Return_Note GRN = db.Goods_Return_Notes
                            .FirstOrDefault(x => x.Store_Return_Id == id && x.isDeleted == false);

                        if (GRN != null)
                        {
                            Debug.WriteLine("GRN Found: Return No. " + GRN.Store_Return_NO);
                            Debug.WriteLine("Current Status: " + GRN.Status);

                            try
                            {
                                // Execute stored procedure to create GL vouchers and approve
                                Debug.WriteLine("Executing spApproveStore_Return for ID: " + id);
                                var result = db.spApproveStore_Return(id, user_id);
                                db.SubmitChanges();

                                // Refresh entity to get updated values from SP
                                db.Refresh(System.Data.Linq.RefreshMode.OverwriteCurrentValues, GRN);

                                Debug.WriteLine("✓ Stored procedure executed successfully");
                                Debug.WriteLine("✓ Updated Status: " + GRN.Status);
                                Debug.WriteLine("✓ Voucher ID: " + GRN.Voucher_Id);
                                Debug.WriteLine("✓ Approved By: " + GRN.Approved_By);
                                Debug.WriteLine("✓ Approved Date: " + GRN.Approved_Date);

                                // Log the approval
                                LogApproval(db, id, form_id, user_id, true, "Approved", false);

                                Debug.WriteLine("✓ Approval logged successfully");
                            }
                            catch (Exception ex)
                            {
                                Debug.WriteLine("✗ Error executing stored procedure: " + ex.Message);
                                Debug.WriteLine("✗ Stack Trace: " + ex.StackTrace);

                                // Rollback status if SP fails
                                GRN.Status = "Created";
                                db.SubmitChanges();

                                throw new Exception("Approval failed: " + ex.Message);
                            }
                        }
                        else
                        {
                            Debug.WriteLine("✗ GRN not found or deleted for ID: " + id);
                        }
                    }
                }

                Debug.WriteLine("\n=== ApproveSelectedGRVs Completed Successfully ===");
                return "1";
            }
            catch (Exception ex)
            {
                Debug.WriteLine("\n=== ApproveSelectedGRVs ERROR ===");
                Debug.WriteLine("Message: " + ex.Message);
                Debug.WriteLine("Stack Trace: " + ex.StackTrace);
                throw;
            }
        }

        [WebMethod]
        public static string RejectSelectedGRVs(List<int> GRVIds)
        {
            try
            {
                Debug.WriteLine("=== RejectSelectedGRVs Called ===");
                Debug.WriteLine("IDs to reject: " + string.Join(", ", GRVIds));

                using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    var user_id = AppConfig.UserID;
                    var form_id = 7;

                    foreach (int id in GRVIds)
                    {
                        Debug.WriteLine("Processing GRN ID: " + id);

                        Goods_Return_Note GRN = db.Goods_Return_Notes
                            .FirstOrDefault(x => x.Store_Return_Id == id && x.isDeleted == false);

                        if (GRN != null)
                        {
                            Debug.WriteLine("GRN Found: " + GRN.Store_Return_NO);

                            GRN.Status = "Cancelled";
                            GRN.isDeleted = true;
                            GRN.Deleted_By = user_id;
                            GRN.Deleted_Date = DateTime.Now;
                            db.SubmitChanges();

                            Debug.WriteLine("✓ GRN rejected successfully");

                            LogApproval(db, id, form_id, user_id, false, "Rejected", true);
                        }
                        else
                        {
                            Debug.WriteLine("✗ GRN not found for ID: " + id);
                        }
                    }
                }

                Debug.WriteLine("=== RejectSelectedGRVs Completed Successfully ===");
                return "1";
            }
            catch (Exception ex)
            {
                Debug.WriteLine("=== RejectSelectedGRVs ERROR ===");
                Debug.WriteLine(ex.ToString());
                throw;
            }
        }

        private static void LogApproval(DataBaseDataContext db, int entryId, int formId, Guid userId,
                                       bool isFinalApproval, string status, bool isRejected)
        {
            try
            {
                var SASD = (from tbl in db.Sys_Approval_Stage_Details
                            join SASM in db.Sys_Approval_Stage_Masters on tbl.Stage_ID equals SASM.Stage_ID
                            join SATD in db.Sys_Approval_Tempelate_Detail_Stages on SASM.Stage_ID equals SATD.StageId
                            join SATF in db.Sys_Approval_Tempelate_Detail_Forms on SATD.Tempelate_ID equals SATF.Tempelate_ID
                            where tbl.UserId == userId
                                  && SATF.FormId == formId
                                  && SASM.IsDeleted == false
                            select tbl).FirstOrDefault();

                if (SASD != null)
                {
                    var SATDS = (from tbl in db.Sys_Approval_Tempelate_Detail_Stages
                                 join SATF in db.Sys_Approval_Tempelate_Detail_Forms on tbl.Tempelate_ID equals SATF.Tempelate_ID
                                 where tbl.StageId == SASD.Stage_ID && SATF.FormId == formId
                                 select tbl).FirstOrDefault();

                    if (SATDS != null)
                    {
                        Sys_Approval_Log SAL = new Sys_Approval_Log
                        {
                            Approval_Template_ID = SATDS.Tempelate_ID,
                            Approval_Stage_ID = SASD.Stage_ID,
                            Entry_ID = entryId,
                            Form_ID = formId,
                            From_Name = "Goods Return Note",
                            Company_ID = AppConfig.Company_ID,
                            IsFinalAprroval = isFinalApproval,
                            Entry_Status = status,
                            Approve_By = userId,
                            Approve_Date = DateTime.Now,
                            IsRejected = isRejected
                        };

                        if (isRejected)
                        {
                            SAL.Rejected_By = userId;
                            SAL.Rejected_Date = DateTime.Now;
                        }

                        db.Sys_Approval_Logs.InsertOnSubmit(SAL);
                        db.SubmitChanges();

                        Debug.WriteLine("Approval logged successfully for Entry ID: " + entryId);
                    }
                }
            }
            catch (Exception ex)
            {
                Debug.WriteLine("LogApproval Error: " + ex.Message);
            }
        }

        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                Debug.WriteLine("=== ViewList Called ===");
                Debug.WriteLine($"draw: {draw}, start: {start}, length: {length}, sortColumn: {sortColumn}, direction: {sortColumnDirection}, search: {searchValue}");

                using (var db = new DataBaseDataContext())
                {
                    var userDepartmentIds = db.Department_Wise_User_Details
                        .Where(dept => dept.User_Id == AppConfig.UserID)
                        .Select(dept => dept.Department)
                        .ToList();

                    Debug.WriteLine("User Departments: " + string.Join(", ", userDepartmentIds));

                    var query = from grn in db.Goods_Return_Notes
                                where (grn.Status == "Created" || grn.Status == "Pending")
                                      && grn.isDeleted == false
                                      && userDepartmentIds.Contains(grn.Department_Id)
                                select grn;

                    Debug.WriteLine("Base query count: " + query.Count());

                    if (!string.IsNullOrEmpty(searchValue))
                    {
                        searchValue = searchValue.ToLower();
                        query = query.Where(x =>
                            x.Store_Return_NO.ToString().Contains(searchValue) ||
                            x.Status.ToLower().Contains(searchValue)
                        );
                        Debug.WriteLine("After search filter count: " + query.Count());
                    }

                    var recordsTotal = db.Goods_Return_Notes.Count(x => x.isDeleted == false);
                    var recordsFiltered = query.Count();

                    Debug.WriteLine($"recordsTotal: {recordsTotal}, recordsFiltered: {recordsFiltered}");

                    if (!string.IsNullOrEmpty(sortColumn) && !string.IsNullOrEmpty(sortColumnDirection))
                    {
                        switch (sortColumn.ToLower())
                        {
                            case "srno":
                                query = sortColumnDirection == "asc"
                                    ? query.OrderBy(x => x.Store_Return_NO)
                                    : query.OrderByDescending(x => x.Store_Return_NO);
                                break;
                            case "department":
                                query = sortColumnDirection == "asc"
                                    ? query.OrderBy(x => x.Department_Id)
                                    : query.OrderByDescending(x => x.Department_Id);
                                break;
                            case "status":
                                query = sortColumnDirection == "asc"
                                    ? query.OrderBy(x => x.Status)
                                    : query.OrderByDescending(x => x.Status);
                                break;
                            case "creator":
                                query = sortColumnDirection == "asc"
                                    ? query.OrderBy(x => x.Created_BY)
                                    : query.OrderByDescending(x => x.Created_BY);
                                break;
                            default:
                                query = query.OrderByDescending(x => x.Store_Return_Id);
                                break;
                        }
                    }
                    else
                    {
                        query = query.OrderByDescending(x => x.Store_Return_Id);
                    }

                    var dataList = query.Skip(start).Take(length)
                        .Select(grn => new
                        {
                            SRID = grn.Store_Return_Id,
                            SRNO = grn.Store_Return_NO,
                            Department = db.GetDataValueName("Department", grn.Department_Id),
                            CREATOR = db.aspnet_Users
                                .Where(u => u.UserId == grn.Created_BY)
                                .Select(u => u.UserName)
                                .FirstOrDefault() ?? "Unknown",
                            STATUS = grn.Status,
                            APPROVEBY = string.Join(", ",
                                db.Sys_Approval_Logs
                                    .Where(log => log.Entry_ID == grn.Store_Return_Id && log.Form_ID == 7)
                                    .Join(db.aspnet_Users,
                                        log => log.Approve_By,
                                        user => user.UserId,
                                        (log, user) => user.UserName ?? "")
                                    .Distinct())
                        })
                        .ToList();

                    Debug.WriteLine("DataList count: " + dataList.Count);

                    var result = new
                    {
                        draw = draw,
                        recordsTotal = recordsTotal,
                        recordsFiltered = recordsFiltered,
                        data = dataList
                    };

                    return result;
                }
            }
            catch (Exception ex)
            {
                Debug.WriteLine("=== ViewList ERROR ===");
                Debug.WriteLine(ex.ToString());
                throw;
            }
        }
    }
}