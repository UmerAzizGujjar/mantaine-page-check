using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class ApproveGIR : System.Web.UI.Page
    {

        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static string ApproveSelectedGIRs(List<int> REQIDs)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            foreach (int id in REQIDs)
            {
                var user_id = AppConfig.UserID;

                var GIR_id = id;



                var form_id = 5;
                MaterialIssueRequest MIR = (from tbl in db.MaterialIssueRequests
                                            where tbl.MaterialRequest_Id == Convert.ToInt32(GIR_id)
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
            return "1";
        }
        [WebMethod]
        public static string RejectSelectedGIRs(List<int> REQIDs)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            foreach (int id in REQIDs)
            {
                var user_id = AppConfig.UserID;

                var GIR_id = id;


                var form_id = 5;

                MaterialIssueRequest MIR = (from tbl in db.MaterialIssueRequests
                                            where tbl.MaterialRequest_Id == Convert.ToInt32(GIR_id)
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
            return "1";
        }
        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var db = new DataBaseDataContext())
                {
                    var Total_Data = db.MaterialIssueRequests.Count();


                    var formattedQuery = from a in db.MaterialIssueRequests
                                         where a.Status == "Created" || a.Status == "Pending"
                                         && (a.Request_No.ToString().Contains(searchValue) || a.Remarks.Contains(searchValue) || a.Status.ToString().Contains(searchValue) || a.Created_By.ToString().Contains(searchValue))
                                         orderby a.MaterialRequest_Id ascending
                                         select new
                                         {
                                             REQID = a.MaterialRequest_Id,
                                             REQNO = a.Request_No,
                                             REMARKS = a.Remarks,
                                             STATUS = a.Status,
                                             MIRDATE = a.MIRDate,
                                             CREATOR = db.aspnet_Users.Where(x => x.UserId == (a.Created_By ?? Guid.Empty)).Select(x => x.UserName).FirstOrDefault(),
                                             APPROVEBY = string.Join(", ", (from SAL in db.Sys_Approval_Logs
                                                                            join user in db.aspnet_Users on SAL.Approve_By equals user.UserId into userGroup
                                                                            from usr in userGroup.DefaultIfEmpty()
                                                                            where a.MaterialRequest_Id == SAL.Entry_ID && SAL.Form_ID == 5
                                                                            select usr.UserName ?? "").Distinct())
                                         };

              



                    var FilteredCount = formattedQuery.Count();
                    // Sorting
                    if (!string.IsNullOrEmpty(sortColumn) && !string.IsNullOrEmpty(sortColumnDirection))
                    {
                        switch (sortColumn)
                        {


                            case "REQNO":
                                formattedQuery = sortColumnDirection == "asc"
                                    ? formattedQuery.OrderBy(x => x.REQNO)
                                    : formattedQuery.OrderByDescending(x => x.REQNO);
                                break;



                            case "STATUS":
                                formattedQuery = sortColumnDirection == "asc"
                                    ? formattedQuery.OrderBy(x => x.STATUS)
                                    : formattedQuery.OrderByDescending(x => x.STATUS);
                                break;



                            default:
                                formattedQuery = formattedQuery.OrderByDescending(x => x.REQNO);
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

    }
}