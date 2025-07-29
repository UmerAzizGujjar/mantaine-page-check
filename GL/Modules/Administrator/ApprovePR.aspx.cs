using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Remoting.Contexts;
using System.Security.Cryptography;
using System.Web;
using System.Web.Services;
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

        }
        [WebMethod]
        public static bool CheckUserRights()
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
            return hasEntryRights;
        }
        [WebMethod]
        public static string RejectSelectedPRs(List<PRItem> PRItems)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            foreach (var item in PRItems)
            {
                string rejectionRemarks = item.DecisionRemarks;
                var pr_id = item.PRId;
                var form_id = 1;
                var user_id = AppConfig.UserID;
                Purchase_Requisition PR = (from tbl in db.Purchase_Requisitions
                                           where tbl.PR_Id == Convert.ToInt32(pr_id)
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
            return "1";

        }

        [WebMethod]
        public static string ApproveSelectedPRs(List<PRItem> PRItems)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            foreach (var item in PRItems)
            {
                string approvalRemarks = item.DecisionRemarks;
                var pr_id = item.PRId;
                var form_id = 1;
                var user_id = AppConfig.UserID;

                Purchase_Requisition PR = (from tbl in db.Purchase_Requisitions
                                           where tbl.PR_Id == Convert.ToInt32(pr_id)
                                           select tbl).SingleOrDefault();
                if (PR != null)
                {

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
                                SAL.From_Name = "Purcahse Requisition";
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
                    var qry = from a in db.Purchase_Requisitions
                              where (a.Status == "Created" || a.Status == "Pending") && a.IsDeleted == false && userDepartments.Contains(a.Department)
                                                             && (a.PR_Num.ToString().Contains(searchValue) || a.Remarks.Contains(searchValue) || a.Status.ToString().Contains(searchValue) || a.Created_By.ToString().Contains(searchValue))

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
                                                                  && (usr.UserName.ToString().Contains(searchValue))
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
                        PRDATE = Convert.ToDateTime(x.PRDate).ToString("dd-MMM-yyyy"),
                        APPROVEBY = x.Approve_By,
                        DEPARTMENT = x.Department,
                    });







                    var FilteredCount = qry.Count();
                    // Sorting
                    if (!string.IsNullOrEmpty(sortColumn) && !string.IsNullOrEmpty(sortColumnDirection))
                    {
                        switch (sortColumn)
                        {
                            case "PRID":
                                formattedQuery = sortColumnDirection == "asc"
                                    ? formattedQuery.OrderBy(x => x.PRID)
                                    : formattedQuery.OrderByDescending(x => x.PRID);
                                break;

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


        public class PRItem
        {
            public int PRId { get; set; }
            public string DecisionRemarks { get; set; }
        }
    }
}