using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using static PMS.ApprovePR;

namespace PMS
{
    public partial class ApproveCS : System.Web.UI.Page
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
        public static string RejectSelectedCSs(List<CSItem> CSItems)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            foreach (var item in CSItems)
            {
                string rejectionRemarks = item.DecisionRemarks;
                var cs_id = item.CSId;
                var user_id = AppConfig.UserID;
                var form_id = 2;
                CS_Vendor_Master cs = (from tbl in db.CS_Vendor_Masters
                                       where tbl.CS_Ven_Master_ID == Convert.ToInt32(cs_id)
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
            return "1";

        }

        [WebMethod]
        public static string ApproveSelectedCSs(List<CSItem> CSItems)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            foreach (var item in CSItems)
            {
                string approvalRemarks = item.DecisionRemarks;
                var cs_id = item.CSId;
                var form_id = 2;
                var user_id = AppConfig.UserID;
                var error = "";
                

           
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
                                error = "Error: PR Detail record not found.";
                                return error;
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
                                error = "Sum of Vendors Item Quantities must be less than or equal to Total PR Quantity.";
                                 return error;
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
                                error = "Please Select at least 2 Vendors before approval.";
                                return error;
                                 
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
                        error = "Error: No associated Vendors found.";
                         return error;
                    }
                }
                else
                {
                    error = "Error: CS_Vendor_Master record not found";
                     return error;
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
                    var Total_Data = db.CS_Vendor_Masters.Count();


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
                        CSID = x.CS_Ven_Master_ID,
                        CSNO = x.CS_Ven_No,
                        REMARKS = x.Remarks,
                        STATUS = x.Status,
                        CREATOR = x.Creator,
                        CSDATE =  Convert.ToDateTime(x.CS_Date).ToString("dd-MMM-yyyy"),
                        APPROVEBY = x.Approve_By,
                        DEPARTMENT = x.Department
                    });


                    if (!string.IsNullOrEmpty(searchValue))
                    {
                        searchValue = searchValue.ToLower();
                        formattedQuery = formattedQuery.Where(x =>
                            (x.CSNO != null && x.CSNO.ToString().ToLower().Contains(searchValue)) ||
                            (x.CSDATE != null && x.CSDATE.ToString().ToLower().Contains(searchValue)) ||
                            (x.CREATOR != null && x.CREATOR.ToLower().Contains(searchValue)) ||
                            (x.REMARKS != null && x.REMARKS.ToLower().Contains(searchValue)) ||
                            (x.STATUS != null && x.STATUS.ToLower().Contains(searchValue)) ||
                            (x.APPROVEBY != null && x.APPROVEBY.ToLower().Contains(searchValue)) ||
                            (x.DEPARTMENT != null && x.DEPARTMENT.ToLower().Contains(searchValue))
                        );
                    }




                    var FilteredCount = qry.Count();
                    // Sorting
                    if (!string.IsNullOrEmpty(sortColumn) && !string.IsNullOrEmpty(sortColumnDirection))
                    {
                        switch (sortColumn)
                        {
                           
                            case "CSNO":
                                formattedQuery = sortColumnDirection == "asc"
                                    ? formattedQuery.OrderBy(x => x.CSNO)
                                    : formattedQuery.OrderByDescending(x => x.CSNO);
                                break;

                            case "CSDATE":
                                formattedQuery = sortColumnDirection == "asc"
                                    ? formattedQuery.OrderBy(x => x.CSDATE)
                                    : formattedQuery.OrderByDescending(x => x.CSDATE);
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

                            default:
                                formattedQuery = formattedQuery.OrderByDescending(x => x.CSNO);
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


        public class CSItem
        {
            public int CSId { get; set; }
            public string DecisionRemarks { get; set; }
        }
    }
}