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
    public partial class LabApproveTest : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

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
        public class ApprovedRow
        {
            public string Bill_No { get; set; }
            public int Bill_ID { get; set; }
            public string mr_no_sequence { get; set; }
            public int? pat_id { get; set; }
            public string Mobile1 { get; set; }
            public string Full_Name { get; set; }
            public string Father_Name { get; set; }
            public int? Bill_Details_ID { get; set; }
            public bool? Is_Refunded { get; set; }
            public int? Lab_Test_Detail_ID { get; set; }
            public int? Lab_Test_ID { get; set; }
            public int? Test_ID { get; set; }
            public string Test_Name { get; set; }
            public string Report_Colum { get; set; }
            public Guid? Approved_By { get; set; }
            public DateTime? Approved_Time { get; set; }
            public bool? isApproved { get; set; }
            public string Test_Main_Department { get; set; }
            public DateTime? Service_Date { get; set; }
            public DateTime? Bill_Date { get; set; }
            public decimal? Net_Amount { get; set; }
            public string Refer_Doctor { get; set; }
            public string Doctor_Name { get; set; }
            public string Approved_By_Name { get; set; }
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

                    var nonGroupQ = from lt in db.Laboratory_Tests
                                    join ltd in db.Lab_Test_Details on lt.Lab_Test_ID equals ltd.Lab_Test_ID
                                    join tdef in db.Lab_Tests on ltd.Test_ID equals tdef.Test_ID
                                    join pa in db.Reg_patients on lt.Patient_ID equals pa.pat_id
                                    join bd in db.Ar_Billing_Details on ltd.Bill_Details_ID equals bd.Bill_Details_ID
                                    join ar in db.Ar_Billings on bd.Bill_ID equals ar.Bill_ID
                                    where ltd.isApproved == true
                                        && (bd.Is_Group_Category == null || bd.Is_Group_Category == false)
                                        && (bd.Test_Main_Department == null || bd.Test_Main_Department == "001")
                                        && (ar.isCancel == false || ar.isCancel == null)
                                        && ar.Bill_Date >= startDate && ar.Bill_Date <= endDate
                                    select new ApprovedRow
                                    {
                                        Bill_No = ar.Bill_No,
                                        Bill_ID = ar.Bill_ID,
                                        mr_no_sequence = pa.mr_no_sequence,
                                        pat_id = pa.pat_id,
                                        Mobile1 = pa.Mobile1,
                                        Full_Name = pa.Full_Name,
                                        Father_Name = pa.Father_Name,
                                        Bill_Details_ID = bd.Bill_Details_ID,
                                        Is_Refunded = bd.Is_Refunded,
                                        Lab_Test_Detail_ID = ltd.Lab_Test_Detail_ID,
                                        Lab_Test_ID = ltd.Lab_Test_ID,
                                        Test_ID = ltd.Test_ID,
                                        Test_Name = tdef.Test_Name,
                                        Report_Colum = tdef.Report_Colum,
                                        Approved_By = ltd.Approved_By,
                                        Approved_Time = ltd.Approved_Time,
                                        isApproved = true,
                                        Test_Main_Department = db.GetDataValueName("Main Test Departments", bd.Test_Main_Department),
                                        Service_Date = bd.Service_Date,
                                        Bill_Date = ar.Bill_Date,
                                        Net_Amount = ar.Net_Amount,
                                        Refer_Doctor = ltd.Refer_Doctor,
                                        Doctor_Name = (from hr in db.HR_Employees
                                                       where hr.Emp_ID.ToString() == ltd.Refer_Doctor
                                                       select hr.Emp_Name).FirstOrDefault(),
                                        Approved_By_Name = ltd.Approved_By != null ? db.getUserName(ltd.Approved_By.ToString()) : null,
                                    };

                    if (!string.IsNullOrEmpty(doctorId) && doctorId != "0")
                        nonGroupQ = nonGroupQ.Where(x => x.Refer_Doctor == doctorId);

                    if (!string.IsNullOrEmpty(searchValue))
                        nonGroupQ = nonGroupQ.Where(x => (x.Full_Name ?? "").Contains(searchValue) ||
                                                          (x.mr_no_sequence ?? "").Contains(searchValue) ||
                                                          (x.Test_Name ?? "").Contains(searchValue) ||
                                                          (x.Bill_No ?? "").Contains(searchValue) ||
                                                          (x.Mobile1 ?? "").Contains(searchValue) ||
                                                          (x.Doctor_Name ?? "").Contains(searchValue));

                    var groupQ = db.ExecuteQuery<ApprovedRow>(@"
                        SELECT
                            MAX(ar.Bill_No) AS Bill_No,
                            ar.Bill_ID,
                            MAX(pa.mr_no_sequence) AS mr_no_sequence,
                            MAX(pa.pat_id) AS pat_id,
                            MAX(pa.Mobile1) AS Mobile1,
                            MAX(pa.Full_Name) AS Full_Name,
                            MAX(pa.Father_Name) AS Father_Name,
                            MIN(bd.Bill_Details_ID) AS Bill_Details_ID,
                            CAST(MAX(CAST(ISNULL(bd.Is_Refunded, 0) AS TINYINT)) AS BIT) AS Is_Refunded,
                            MIN(ld.Lab_Test_Detail_ID) AS Lab_Test_Detail_ID,
                            MIN(ld.Lab_Test_ID) AS Lab_Test_ID,
                            dv.DataValue_ID AS Test_ID,
                            lt.Group_Category,
                            dbo.GetDataValueName('Test Groups', lt.Group_Category) AS Test_Name,
                            MAX(lt.Report_Colum) AS Report_Colum,
                            ld.Approved_By,
                            (SELECT TOP 1 UserName FROM aspnet_Users u WHERE u.UserId = ld.Approved_By) AS Approved_By_Name,
                            MIN(ld.Approved_Time) AS Approved_Time,
                            CAST(MAX(CAST(ISNULL(ld.isApproved, 0) AS INT)) AS BIT) AS isApproved,
                            MIN(bd.Test_Main_Department) AS Test_Main_Department_Code,
                            dbo.GetDataValueName('Test Departments', lt.Group_Department) AS Test_Main_Department,
                            MIN(bd.Service_Date) AS Service_Date,
                            MAX(ar.Bill_Date) AS Bill_Date,
                            MAX(ar.Net_Amount) AS Net_Amount,
                            MIN(ld.Refer_Doctor) AS Refer_Doctor,
                            '' AS Doctor_Name,
                            ar.Branch_Id,
                            CONVERT(varchar(16), ld.Created_Time, 120) AS Test_Ready_On
                        FROM Lab_Test_Detail ld
                        JOIN Lab_Tests lt ON lt.Test_ID = ld.Test_ID
                        JOIN Laboratory_Test ltm ON ltm.Lab_Test_ID = ld.Lab_Test_ID
                        JOIN Reg_patient pa ON pa.pat_id = ltm.Patient_ID
                        JOIN AR_Billing_Details bd ON bd.Bill_Details_ID = ld.Bill_Details_ID
                        JOIN AR_Billings ar ON ar.Bill_ID = bd.Bill_ID
                        LEFT JOIN DataValues dv ON dv.DataValue_Name = lt.Group_Category AND dv.ValueSet_ID = 70
                        WHERE ld.isApproved = 1
                            AND ISNULL(bd.Is_Group_Category, 0) = 1
                            AND (bd.Test_Main_Department IS NULL OR bd.Test_Main_Department = '001')
                            AND ISNULL(ar.isCancel, 0) = 0
                            AND ar.Bill_Date >= {0} AND ar.Bill_Date <= {1}
                        GROUP BY ar.Bill_ID, lt.Group_Category, dv.Segment2, dv.DataValue_ID, ld.Approved_By, ar.Branch_Id, lt.Group_Department, CONVERT(varchar(16), ld.Created_Time, 120)
                    ", startDate, endDate).AsQueryable();

                    if (!string.IsNullOrEmpty(doctorId) && doctorId != "0")
                        groupQ = groupQ.Where(x => x.Refer_Doctor == doctorId);

                    if (!string.IsNullOrEmpty(searchValue))
                        groupQ = groupQ.Where(x => (x.Full_Name ?? "").Contains(searchValue) ||
                                                    (x.mr_no_sequence ?? "").Contains(searchValue) ||
                                                    (x.Test_Name ?? "").Contains(searchValue) ||
                                                    (x.Bill_No ?? "").Contains(searchValue) ||
                                                    (x.Mobile1 ?? "").Contains(searchValue));

                    var combined = nonGroupQ.ToList();
                    combined.AddRange(groupQ.ToList());

                    var TotalCount = combined.Count;

                    if (length == -1 || length > 100000)
                    {
                        start = 0;
                        length = TotalCount;
                    }

                    switch (sortColumn)
                    {
                        case "Bill_No":
                            combined = sortColumnDirection == "asc" ? combined.OrderBy(x => x.Bill_No).ToList() : combined.OrderByDescending(x => x.Bill_No).ToList();
                            break;
                        case "mr_no_sequence":
                            combined = sortColumnDirection == "asc" ? combined.OrderBy(x => x.mr_no_sequence).ToList() : combined.OrderByDescending(x => x.mr_no_sequence).ToList();
                            break;
                        case "Full_Name":
                            combined = sortColumnDirection == "asc" ? combined.OrderBy(x => x.Full_Name).ToList() : combined.OrderByDescending(x => x.Full_Name).ToList();
                            break;
                        case "Test_Name":
                            combined = sortColumnDirection == "asc" ? combined.OrderBy(x => x.Test_Name).ToList() : combined.OrderByDescending(x => x.Test_Name).ToList();
                            break;
                        case "Test_Main_Department":
                            combined = sortColumnDirection == "asc" ? combined.OrderBy(x => x.Test_Main_Department).ToList() : combined.OrderByDescending(x => x.Test_Main_Department).ToList();
                            break;
                        case "Doctor_Name":
                            combined = sortColumnDirection == "asc" ? combined.OrderBy(x => x.Doctor_Name).ToList() : combined.OrderByDescending(x => x.Doctor_Name).ToList();
                            break;
                        case "Approved_By":
                            combined = sortColumnDirection == "asc" ? combined.OrderBy(x => x.Approved_By_Name).ToList() : combined.OrderByDescending(x => x.Approved_By_Name).ToList();
                            break;
                        case "Approved_Time":
                            combined = sortColumnDirection == "asc" ? combined.OrderBy(x => x.Approved_Time).ToList() : combined.OrderByDescending(x => x.Approved_Time).ToList();
                            break;
                        default:
                            combined = combined.OrderByDescending(x => x.Approved_Time).ToList();
                            break;
                    }

                    var FilteredCount = combined.Count;
                    var paged = combined.Skip(start).Take(length).ToList();

                    foreach (var row in paged)
                    {
                        if (string.IsNullOrEmpty(row.Doctor_Name) && !string.IsNullOrEmpty(row.Refer_Doctor))
                            row.Doctor_Name = (from hr in db.HR_Employees
                                               where hr.Emp_ID.ToString() == row.Refer_Doctor
                                               select hr.Emp_Name).FirstOrDefault();

                        if (string.IsNullOrEmpty(row.Approved_By_Name) && row.Approved_By != null)
                            row.Approved_By_Name = db.getUserName(row.Approved_By.ToString());
                    }

                    var jsonData = paged.Select(r => new
                    {
                        r.Bill_No,
                        r.Bill_ID,
                        r.mr_no_sequence,
                        r.pat_id,
                        r.Mobile1,
                        r.Full_Name,
                        r.Father_Name,
                        r.Bill_Details_ID,
                        Is_Refunded = r.Is_Refunded == true ? 1 : 0,
                        r.Lab_Test_Detail_ID,
                        r.Lab_Test_ID,
                        r.Test_ID,
                        r.Test_Name,
                        r.Report_Colum,
                        r.Approved_Time,
                        r.isApproved,
                        r.Test_Main_Department,
                        r.Service_Date,
                        r.Bill_Date,
                        r.Net_Amount,
                        r.Doctor_Name,
                        r.Approved_By_Name,
                        r.Refer_Doctor
                    }).ToList();

                    return new
                    {
                        draw = draw,
                        recordsFiltered = FilteredCount,
                        recordsTotal = TotalCount,
                        data = jsonData
                    };
                }
            }
            catch (Exception ex)
            {
                string detail = ex.Message;
                if (ex.InnerException != null) detail += " | Inner: " + ex.InnerException.Message;
                throw new Exception("Error fetching approved tests list: " + detail, ex);
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