using PMS.Inventory;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class ApproveIGP : System.Web.UI.Page
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
            return hasEntryRights;

        }
        [WebMethod]
        public static string ApproveSelectedIGPs(List<int> IGPIds)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            foreach (int id in IGPIds)
            {
                var user_id = AppConfig.UserID;
                
                var IGP_id = id;
                
               
                    var form_id = 4;

                    Igp_master IGP = (from tbl in db.Igp_masters
                                      where tbl.Igp_Id == Convert.ToInt32(IGP_id)
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
                            if (IGP.Status != "Approved" && IGP.Inspec_Status != "Approved")
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
            return "1";
        }
        [WebMethod]
        public static string RejectSelectedIGPs(List<int> IGPIds)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            foreach (int id in IGPIds)
            {
                var user_id = AppConfig.UserID;
                
                var IGP_id = id;
                
                
                    var form_id = 4;
                    
                    Igp_master IGP = (from tbl in db.Igp_masters
                                      where tbl.Igp_Id == Convert.ToInt32(IGP_id)
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
            return "1";
        }
        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var db = new DataBaseDataContext())
                {
                    var Total_Data = db.Igp_Details.Count();


                    var userDepartments = db.Department_Wise_User_Details
                      .Where(dept => dept.User_Id == AppConfig.UserID)
                      .Select(dept => dept.Department)
                      .ToList();
                    var qry = (from a in db.Igp_masters
                               join igpd in db.Igp_Details on a.Igp_Id equals igpd.Igp_Id
                               join apoi in db.AP_Purchase_Order_Items on Convert.ToInt32(igpd.PO_Item_ID) equals apoi.PO_Item_ID
                               join prd in db.Purchase_Requisition_Details on Convert.ToInt32(apoi.PRDetailId) equals prd.PR_Detail_ID
                               join pr in db.Purchase_Requisitions on prd.PR_ID equals pr.PR_Id
                               where (a.Inspec_Status == null || a.Inspec_Status == "Created" || a.Inspec_Status == "Pending") && a.IsDeleted == false && userDepartments.Contains(pr.Department)
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
                        IGPID = x.Igp_Id,
                        IGPNO = x.Igp_num,
                        REMARKS = x.Remarks,
                        STATUS = x.Status,
                        INSPECTSTATUS = x.Inspec_Status,
                        CREATOR = x.Creator,
                        IGPDATE = Convert.ToDateTime(x.Igp_date).ToString("dd-MMM-yyyy"),
                        APPROVEBY= x.Approve_By,
                        DEPARTMENT = x.Department
                    });



                    var FilteredCount = qry.Count();
                    // Sorting
                    if (!string.IsNullOrEmpty(sortColumn) && !string.IsNullOrEmpty(sortColumnDirection))
                    {
                        switch (sortColumn)
                        {
                            case "IGPID":
                                formattedQuery = sortColumnDirection == "asc"
                                    ? formattedQuery.OrderBy(x => x.IGPID)
                                    : formattedQuery.OrderByDescending(x => x.IGPID);
                                break;

                            case "IGPNO":
                                formattedQuery = sortColumnDirection == "asc"
                                    ? formattedQuery.OrderBy(x => x.IGPNO)
                                    : formattedQuery.OrderByDescending(x => x.IGPNO);
                                break;

                            case "DEPARTMENT":
                                formattedQuery = sortColumnDirection == "asc"
                                    ? formattedQuery.OrderBy(x => x.DEPARTMENT)
                                    : formattedQuery.OrderByDescending(x => x.DEPARTMENT);
                                break;

                            case "CREATOR":
                                formattedQuery = sortColumnDirection == "asc"
                                    ? formattedQuery.OrderBy(x => x.CREATOR)
                                    : formattedQuery.OrderByDescending(x => x.CREATOR);
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
                                formattedQuery = formattedQuery.OrderByDescending(x => x.IGPNO);
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