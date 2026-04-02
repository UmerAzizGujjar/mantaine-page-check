using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.Lab
{
    public partial class ApproveTest : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue, string startdate, string endtdate, string doctorId)
        {
            try
            {
                using (var db = new DataBaseDataContext())
                {
                    db.CommandTimeout = 180;

                    DateTime startDate = Convert.ToDateTime(startdate).Date;
                    DateTime endDate = Convert.ToDateTime(endtdate).Date.AddDays(1).AddTicks(-1);

                    var TotalCount = (from lt in db.Laboratory_Tests
                                      join ltd in db.Lab_Test_Details on lt.Lab_Test_ID equals ltd.Lab_Test_ID
                                      join tdef in db.Lab_Tests on ltd.Test_ID equals tdef.Test_ID
                                      join pa in db.Reg_patients on lt.Patient_ID equals pa.pat_id
                                      join bd in db.Ar_Billing_Details on ltd.Bill_Details_ID equals bd.Bill_Details_ID
                                      join ar in db.Ar_Billings on bd.Bill_ID equals ar.Bill_ID
                                      where ltd.isApproved == true
                                          && (bd.Is_Group_Category == null || bd.Is_Group_Category == false)
                                          && (bd.Test_Main_Department == null || bd.Test_Main_Department != "001")
                                          && (ar.isCancel == false || ar.isCancel == null)
                                          && ltd.Approved_Time >= startDate
                                          && ltd.Approved_Time <= endDate
                                          && !db.Refunds.Any(r => r.Bill_ID == ar.Bill_ID)
                                      select ltd).Count();

                    var query = from lt in db.Laboratory_Tests
                                join ltd in db.Lab_Test_Details on lt.Lab_Test_ID equals ltd.Lab_Test_ID
                                join tdef in db.Lab_Tests on ltd.Test_ID equals tdef.Test_ID
                                join pa in db.Reg_patients on lt.Patient_ID equals pa.pat_id
                                join bd in db.Ar_Billing_Details on ltd.Bill_Details_ID equals bd.Bill_Details_ID
                                join ar in db.Ar_Billings on bd.Bill_ID equals ar.Bill_ID
                                where ltd.isApproved == true
                                    && (bd.Is_Group_Category == null || bd.Is_Group_Category == false)
                                    && (bd.Test_Main_Department == null || bd.Test_Main_Department != "001")
                                    && (ar.isCancel == false || ar.isCancel == null)
                                    && ltd.Approved_Time >= startDate
                                    && ltd.Approved_Time <= endDate
                                    && !db.Refunds.Any(r => r.Bill_ID == ar.Bill_ID)
                                select new
                                {
                                    ar.Bill_No,
                                    ar.Bill_ID,
                                    pa.mr_no_sequence,
                                    pa.pat_id,
                                    pa.Full_Name,
                                    pa.Father_Name,
                                    bd.Bill_Details_ID,
                                    ltd.Lab_Test_Detail_ID,
                                    ltd.Lab_Test_ID,
                                    ltd.Test_ID,
                                    tdef.Test_Name,
                                    tdef.Report_Colum,
                                    ltd.Approved_By,
                                    ltd.Approved_Time,
                                    ltd.isApproved,
                                    Test_Main_Department = db.GetDataValueName("Main Test Departments", bd.Test_Main_Department),
                                    bd.Service_Date,
                                    ar.Bill_Date,
                                    Refer_Doctor = ltd.Refer_Doctor,
                                    Doctor_Name = (from hr in db.HR_Employees
                                                   where hr.Emp_ID.ToString() == ltd.Refer_Doctor
                                                   select hr.Emp_Name).FirstOrDefault()
                                };

                    // Apply doctor filter
                    if (!string.IsNullOrEmpty(doctorId) && doctorId != "0")
                    {
                        query = query.Where(x => x.Refer_Doctor == doctorId);
                    }

                    // Apply search filter
                    if (!string.IsNullOrEmpty(searchValue))
                    {
                        query = query.Where(x => x.Full_Name.Contains(searchValue) ||
                                                  x.mr_no_sequence.Contains(searchValue) ||
                                                  x.Test_Name.Contains(searchValue) ||
                                                  x.Bill_No.Contains(searchValue));
                    }

                    var FilteredCount = query.Count();

                    // Apply sorting
                    switch (sortColumn)
                    {
                        case "Bill_No":
                            query = sortColumnDirection == "asc" ? query.OrderBy(x => x.Bill_No) : query.OrderByDescending(x => x.Bill_No);
                            break;
                        case "mr_no_sequence":
                            query = sortColumnDirection == "asc" ? query.OrderBy(x => x.mr_no_sequence) : query.OrderByDescending(x => x.mr_no_sequence);
                            break;
                        case "Full_Name":
                            query = sortColumnDirection == "asc" ? query.OrderBy(x => x.Full_Name) : query.OrderByDescending(x => x.Full_Name);
                            break;
                        case "Test_Name":
                            query = sortColumnDirection == "asc" ? query.OrderBy(x => x.Test_Name) : query.OrderByDescending(x => x.Test_Name);
                            break;
                        case "Test_Main_Department":
                            query = sortColumnDirection == "asc" ? query.OrderBy(x => x.Test_Main_Department) : query.OrderByDescending(x => x.Test_Main_Department);
                            break;
                        case "Doctor_Name":
                            query = sortColumnDirection == "asc" ? query.OrderBy(x => x.Doctor_Name) : query.OrderByDescending(x => x.Doctor_Name);
                            break;
                        case "Approved_By":
                            query = sortColumnDirection == "asc" ? query.OrderBy(x => x.Approved_By) : query.OrderByDescending(x => x.Approved_By);
                            break;
                        case "Approved_Time":
                            query = sortColumnDirection == "asc" ? query.OrderBy(x => x.Approved_Time) : query.OrderByDescending(x => x.Approved_Time);
                            break;
                        default:
                            query = query.OrderByDescending(x => x.Approved_Time);
                            break;
                    }

                    var approvedList = query.Skip(start).Take(length).ToList();

                    var jsonData = new
                    {
                        draw = draw,
                        recordsFiltered = FilteredCount,
                        recordsTotal = TotalCount,
                        data = approvedList
                    };

                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching approved tests list", ex);
            }
        }
    }
}