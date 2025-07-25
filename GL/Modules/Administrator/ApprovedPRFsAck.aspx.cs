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
    public partial class ApprovedPRFsAck : System.Web.UI.Page
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
                var form_id = 11;
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
        public static string ApproveSelectedPRs(List<int> PRIds)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            foreach (int id in PRIds)
            {
                var user_id = AppConfig.UserID;

                var pr_id = id;
                

                 Purchase_Requisition PR = (from tbl in db.Purchase_Requisitions
                                           where tbl.PR_Id == Convert.ToInt32(pr_id) && tbl.IsNotificationViewed == false && tbl.Status == "Approved"
                                           select tbl).SingleOrDefault();
                if (PR != null)
                {
                    PR.IsNotificationViewed = true;
                    db.SubmitChanges();
                }
                else
                {
                    string alertMessage = $"PR: ({pr_id}) Already Acknowledged";
                     return alertMessage;
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

                    var Total_Data = db.Purchase_Requisitions.Count();
                    var userDepartments = db.Department_Wise_User_Details
                      .Where(dept => dept.User_Id == AppConfig.UserID)
                      .Select(dept => dept.Department)
                      .ToList();
                    var qry = from a in db.Purchase_Requisitions
                              where a.Status == "Approved" && a.IsNotificationViewed == false && a.IsDeleted == false && userDepartments.Contains(a.Department)
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
                              };

                    var formattedQuery = qry.AsEnumerable().Select(x => new
                    {
                        PRID = x.PR_Id,
                        PRNO = x.PR_Num,
                        REMARKS = x.Remarks,
                        STATUS = x.Status,
                        CREATOR = x.Creator,
                        PRDATE =x.PRDate,
                        APPROVEBY = x.Approve_By,
                        DEPARTMENT = x.Department,
                    });
                    var FilteredCount = formattedQuery.Count();
                    // Sorting
                    if (!string.IsNullOrEmpty(sortColumn) && !string.IsNullOrEmpty(sortColumnDirection))
                    {
                        switch (sortColumn)
                        {

                            case "PRNO":
                                formattedQuery = sortColumnDirection == "asc"
                                    ? formattedQuery.OrderBy(x => x.PRNO)
                                    : formattedQuery.OrderByDescending(x => x.PRNO);
                                break;

                            case "PRDATE":
                                formattedQuery = sortColumnDirection == "asc"
                                    ? formattedQuery.OrderBy(x => x.PRDATE)
                                    : formattedQuery.OrderByDescending(x => x.PRDATE);
                                break;


                            default:
                                formattedQuery = formattedQuery.OrderByDescending(x => x.PRNO);
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