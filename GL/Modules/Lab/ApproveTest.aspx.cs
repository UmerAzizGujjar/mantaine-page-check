using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
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

        //[WebMethod]
        //public static object GetDoctors()
        //{
        //    try
        //    {
        //        DataBaseDataContext db = new DataBaseDataContext();
        //        var DocUserid = AppConfig.UserID;
        //        bool testList = (from hr in db.aspnet_Users where hr.UserId == DocUserid select hr.AllowTestlistDoctor).FirstOrDefault()

        //        //using (var db = new DataBaseDataContext())
        //        if (testList == true)
        //        {
        //            var doctors = (from emp in db.HR_Employees
        //                           where emp.IsDoctor == true
        //                           select new
        //                           {
        //                               id = emp.Emp_ID,
        //                               text = emp.Emp_Name
        //                           }).ToList();
        //            return doctors;
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        return new List<object>();
        //    }
        //}
        [WebMethod]
        public static object GetDoctors()
        {
            try
            {
                using (var db = new DataBaseDataContext())
                {
                    var docUserId = AppConfig.UserID;

                    bool testList = (from hr in db.aspnet_Users
                                     where hr.UserId == docUserId
                                     select hr.AllowTestlistDoctor).FirstOrDefault() ?? false;

                    if (testList)
                    {
                        var doctors = (from emp in db.HR_Employees
                                       where emp.IsDoctor == true
                                       select new
                                       {
                                           id = emp.Emp_ID,
                                           text = emp.Emp_Name
                                       }).ToList();

                        return doctors;
                    }
                    else
                    {
                        var doctors = (from emp in db.HR_Employees
                                       where emp.IsDoctor == true
                                             && emp.userid == Convert.ToString(docUserId)
                                       select new
                                       {
                                           id = emp.Emp_ID,
                                           text = emp.Emp_Name
                                       }).ToList();

                        return doctors;
                    }
                }
            }
            catch (Exception)
            {
                return new List<object>();
            }
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
                                           // && ltd.Approved_Time >= startDate
                                           //&& ltd.Approved_Time <= endDate
&& ar.Bill_Date >= startDate
                                           && ar.Bill_Date <= endDate
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
                                    //&& ltd.Approved_Time >= startDate
                                    //&& ltd.Approved_Time <= endDate
                                    && ar.Bill_Date >= startDate
                                    && ar.Bill_Date <= endDate
                                select new
                                {
                                    ar.Bill_No,
                                    ar.Bill_ID,
                                    mr_no_sequence = pa.mr_no_sequence,
                                    pa.pat_id,
                                    pa.Mobile1,
                                    pa.Full_Name,
                                    pa.Father_Name,
                                    bd.Bill_Details_ID,
                                    bd.Is_Refunded,
                                    ltd.Lab_Test_Detail_ID,
                                    ltd.Lab_Test_ID,
                                    ltd.Test_ID,
                                    tdef.Test_Name,
                                    tdef.Report_Colum,
                                    Approved_By_Name = ltd.Approved_By != null ? db.getUserName(ltd.Approved_By.ToString()) : null,
                                    ltd.Approved_Time,
                                    ltd.isApproved,
                                    Test_Main_Department = db.GetDataValueName("Main Test Departments", bd.Test_Main_Department),
                                    bd.Service_Date,
                                    ar.Bill_Date,
                                    ar.Net_Amount,
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
                                                  x.Bill_No.Contains(searchValue) ||
                                                  x.Mobile1.Contains(searchValue) ||
                                                   x.Doctor_Name.Contains(searchValue)); 
                                                  
                    }

                    var FilteredCount = query.Count();

                    if (length == -1)
                    {
                        start = 0;
                        length = FilteredCount; 
                    }
                    else if (length > 100000)
                    {
                        start = 0;
                        length = FilteredCount;
                    }

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
                            query = sortColumnDirection == "asc" ? query.OrderBy(x => x.Approved_By_Name) : query.OrderByDescending(x => x.Approved_By_Name);
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

        [WebMethod]
        public static string GetDynamicReportHTML(string Test_IDs, string Trans_IDs, int Patient_ID, string Bill_Details_IDs)
        {
            try
            {
                DataBaseDataContext db = new DataBaseDataContext();

                var reportData = db.spLabReportQN(Test_IDs, Trans_IDs, Patient_ID, Bill_Details_IDs).ToList();

                if (reportData == null || reportData.Count == 0)
                    return "{\"error\":\"No data found\"}";

                var data = reportData.First();

                // Get the raw path from GetCompanyLogo (e.g. "C:\Projects\Images\11414.png")
                // Get physical path from Segment1 + CompanyID + .png
                string physicalFolder = DBClass.getField(
                    "SELECT Segment1 FROM Sys_Parms WHERE Name = 'Project Image File Path'"
                )?.ToString() ?? "";

                string logoWebPath = "";
                if (!string.IsNullOrEmpty(physicalFolder))
                {
                    try
                    {
                        string companyID = "11414";
                        string fullImagePath = System.IO.Path.Combine(
                            physicalFolder.TrimEnd('\\'),
                            companyID + ".png"
                        );

                        // Read file and convert to Base64
                        if (System.IO.File.Exists(fullImagePath))
                        {
                            byte[] imageBytes = System.IO.File.ReadAllBytes(fullImagePath);
                            string base64String = Convert.ToBase64String(imageBytes);

                            // Detect image type from extension
                            string ext = System.IO.Path.GetExtension(fullImagePath)
                                             .ToLower()
                                             .TrimStart('.');
                            string mimeType = ext == "png" ? "image/png"
                                            : ext == "jpg" || ext == "jpeg" ? "image/jpeg"
                                            : ext == "gif" ? "image/gif"
                                            : "image/png";

                            // Embed as data URI — works everywhere, no IIS config needed
                            logoWebPath = "data:" + mimeType + ";base64," + base64String;
                        }
                    }
                    catch
                    {
                        logoWebPath = "";
                    }
                }

                var result = new
                {
                    Company_Name = DBClass.getField("SELECT TOP 1 Company_Name FROM sys_Companys WHERE Company_ID = 1")?.ToString() ?? "National Hospital & Medical Centre",
                    Company_Address = DBClass.getField("SELECT TOP 1 Company_Address FROM sys_Companys WHERE Company_ID = 1")?.ToString() ?? "",
                    Company_Logo_Path = logoWebPath,

                    // Test
                    Test_Name = data.Test_Name ?? data.Group_Department ?? "Radiology Report",
                    Fixed_Value = data.Fixed_Value ?? "",
                    Addendum_Template = data.Addendum_Template ?? "",
                    Lab_Test_Detail_Id = data.Lab_Test_Detail_ID.ToString(),

                    // Patient
                    Full_Name = data.Full_Name ?? "",
                    Age_years = data.Age_years?.ToString() ?? "",
                    Gender = data.Gender ?? "",
                    Patient_No = data.Patient_No?.ToString() ?? "",
                    REg_Date = data.REg_Date.ToString() ?? "",
                    Mobile1 = data.Mobile1 ?? "",
                    NIC = data.NIC ?? "",
                    Patient_Type = data.Patient_Type ?? "",
                    ReferredByDoctor = data.ReferredByDoctor ?? "",
                    Bill_No = data.Bill_No ?? "",
                    Department = data.DepartMent ?? "",
                    Billing_Date = data.Billing_Date?.ToString() ?? "",
                    Approved_Time = data.Approved_Time?.ToString() ?? "",

                    // Footer
                    Report_Footer = data.Report_Footer ?? "",
                    Report_Footer_tow = data.Report_Footer_tow ?? "",
                    Report_Footer1 = data.Report_Footer1 ?? "",
                    Report_Footer_tow1 = data.Report_Footer_tow1 ?? "",

                    // Doctors
                    Test_Approved_By_Doctor_name = data.Test_Approved_By_Doctor_name ?? "",
                    Test_Approved_By_Doctor_qualification = data.Test_Approved_By_Doctor_qualification ?? "",
                    Test_Performed_By_Doctor_name = data.Test_Performed_By_Doctor_name ?? "",
                    Test_Performed_By_Doctor_qualification = data.Test_Performed_By_Doctor_qualification ?? "",
                    Test_Ready_On = data.Test_Ready_On?.ToString() ?? "",
                };

                return new JavaScriptSerializer().Serialize(result);
            }
            catch (Exception ex)
            {
                // Return clean error — no path mapping calls here
                return "{\"error\":\"" + ex.Message.Replace("\"", "'").Replace("\r", " ").Replace("\n", " ") + "\"}";
            }
        }
    }
}