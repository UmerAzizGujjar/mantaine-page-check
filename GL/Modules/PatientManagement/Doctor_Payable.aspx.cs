using Infragistics.Web.UI.GridControls;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using static PMS.BillingProcess;
using static PMS.Modules.PatientManagement.Doctor_Payable;

namespace PMS.Modules.PatientManagement
{
    public partial class Doctor_Payable : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static string GetPackageType()
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var Dis = (from d in db.DataValues
                       join v in db.ValueSets
                       on d.ValueSet_ID equals v.ValueSet_ID
                       where v.ValueSet_Name == "IPD PacakgeType"
                       select new
                       {
                           d.DataValue_Name,
                           d.DataValue_Description
                       }).ToList();

            return (new JavaScriptSerializer().Serialize(Dis));
        }
        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue, string startDate, string endDate, string packageType)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    if (_dbContext.Connection.State != ConnectionState.Open)
                    {
                        _dbContext.Connection.Open();
                    }

                    var cmd = _dbContext.Connection.CreateCommand();
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.CommandText = "sp_GetPostsharingBill";

                    // Add required parameters
                    cmd.Parameters.Add(new System.Data.SqlClient.SqlParameter("@StartDate", string.IsNullOrEmpty(startDate) ? (object)DBNull.Value : DateTime.Parse(startDate)));
                    cmd.Parameters.Add(new System.Data.SqlClient.SqlParameter("@EndDate", string.IsNullOrEmpty(endDate) ? (object)DBNull.Value : DateTime.Parse(endDate)));
                    cmd.Parameters.Add(new System.Data.SqlClient.SqlParameter("@PackageType", string.IsNullOrEmpty(packageType) ? (object)DBNull.Value : packageType));

                    var BillList = new List<BillInfo>();

                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            BillList.Add(new BillInfo
                            {
                                Bill_ID = reader["Bill_ID"] != DBNull.Value ? Convert.ToInt32(reader["Bill_ID"]) : 0,
                                Bill_No = reader["Bill_No"]?.ToString(),
                                Full_Name = reader["Full_Name"]?.ToString(),
                                MR_No = reader["mr_no_sequence"]?.ToString(),
                                DoctorName = reader["DoctorName"]?.ToString(),
                                Doctorid = reader["Doctor"]?.ToString(),
                                Package_Name = reader["Package_Name_Id"]?.ToString(),
                                Package_Type = reader["Package_Type_Id"]?.ToString(),
                                Package_Name_Id = reader["Package_Name"]?.ToString(),
                                Package_Type_Id = reader["Package_Type"]?.ToString(),
                                Services_Tests = reader["Services_Tests"]?.ToString(),
                                Creation_Date = reader["Creation_Date"] != DBNull.Value ? Convert.ToDateTime(reader["Creation_Date"]).ToString("yyyy-MM-dd") : "",
                                Bill_Net_Amount = reader["Bill_Net_Amount"] != DBNull.Value ? Convert.ToDecimal(reader["Bill_Net_Amount"]) : 0,
                                Doctor_Share = reader["Doctor_Share"] != DBNull.Value ? Convert.ToDecimal(reader["Doctor_Share"]) : 0,
                                Hospital_Share = reader["Hospital_Share"] != DBNull.Value ? Convert.ToDecimal(reader["Hospital_Share"]) : 0,
                                Total_Expense = reader["Total_Expense"] != DBNull.Value ? Convert.ToDecimal(reader["Total_Expense"]) : 0,
                                Discount_Amount = reader["Discount_Amount"] != DBNull.Value ? Convert.ToDecimal(reader["Discount_Amount"]) : 0,
                                Net_Amount = reader["Net_Amount"] != DBNull.Value ? Convert.ToDecimal(reader["Net_Amount"]) : 0
                            });
                        }
                    }

                    int totalRecords = BillList.Count;
                    int filteredRecords = totalRecords;

                    // Apply search filter
                    if (!string.IsNullOrEmpty(searchValue))
                    {
                        BillList = BillList
                            .Where(x => (x.Full_Name?.IndexOf(searchValue, StringComparison.OrdinalIgnoreCase) >= 0)
                                     || (x.Bill_No?.IndexOf(searchValue, StringComparison.OrdinalIgnoreCase) >= 0)
                                     || (x.DoctorName?.IndexOf(searchValue, StringComparison.OrdinalIgnoreCase) >= 0))
                            .ToList();

                        filteredRecords = BillList.Count;
                    }

                    // Apply sorting dynamically
                    if (!string.IsNullOrEmpty(sortColumn))
                    {
                        var propertyInfo = typeof(BillInfo).GetProperty(sortColumn);
                        if (propertyInfo != null)
                        {
                            BillList = (sortColumnDirection == "asc")
                                ? BillList.OrderBy(x => propertyInfo.GetValue(x, null)).ToList()
                                : BillList.OrderByDescending(x => propertyInfo.GetValue(x, null)).ToList();
                        }
                    }

                    var paginatedList = BillList.Skip(start).Take(length).ToList();

                    return new
                    {
                        draw = draw,
                        recordsFiltered = filteredRecords,
                        recordsTotal = totalRecords,
                        data = paginatedList
                    };
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching billing list: " + ex.Message, ex);
            }
        }
        public class BillInfo
        {
            public int Bill_ID { get; set; }
            public string Bill_No { get; set; }
            public string Full_Name { get; set; }
            public string MR_No { get; set; }
            public string DoctorName { get; set; }
            public string Doctorid { get; set; }
            public string Package_Name { get; set; }
            public string Package_Type { get; set; }
            public string Package_Name_Id { get; set; }
            public string Services_Tests { get; set; }
            public string Package_Type_Id { get; set; }
            public string Creation_Date { get; set; }
            public decimal Total_Amount { get; set; }
            public decimal Bill_Net_Amount { get; set; }
            public decimal Net_Amount { get; set; }
            public decimal Total_Expense { get; set; }
            public decimal Doctor_Share { get; set; }
            public decimal Hospital_Share { get; set; }
            public decimal Discount_Amount { get; set; }
        }

        [WebMethod]
        public static string GetBillDetailPackageWise(string Bill_Id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            // Fetch Package_Type and Package_Name for the given Bill_ID
            var billInfo = (from b in db.Ar_Billings
                                where b.Bill_ID ==Convert.ToInt32( Bill_Id)
                                select new
                                {
                                    b.Package_Type,
                                    b.Package_Name
                                }).FirstOrDefault();

                if (billInfo == null)
                    return null;

                string packageType = billInfo.Package_Type;
                int packageName =Convert.ToInt32(billInfo.Package_Name);

                object result = null;

                if (packageType == "02") // Department Package
                {

                    result = (from ab in db.Ar_Billings
                              join abd in db.Ar_Billing_Details on ab.Bill_ID equals abd.Bill_ID
                              join dp in db.DepartmentPackages on Convert.ToInt32(ab.Package_Name) equals dp.Dep_Packages_ID
                              join dpr in db.Department_Packages_Detail_Rates on dp.Dep_Packages_ID equals dpr.Dep_Packages_ID
                              where abd.Item_ID == dpr.Item_Code
                                    && abd.Item_Type == dpr.Item_Type
                                    && dp.Dep_Packages_ID == packageName
                                    && ab.Bill_ID == Convert.ToInt32(Bill_Id)
                              select new
                              {
                                  ab.Bill_No,
                                  ab.Bill_ID,
                                  ab.Patient_ID,
                                  abd.Item_ID,
                                  abd.Item_Name,
                                  abd.Item_Type,
                                  abd.Amount,
                                  abd.Discount_Amount,
                                  abd.Net_Amount,
                                  dpr.is_expense,
                                  dp.Doctor_Share,
                                  dp.Hospital_Share,
                                  Doctor_Id = (from ipd in db.In_Patients where ipd.In_Patient_ID == ab.In_Patient_ID orderby ipd.In_Patient_ID descending select ipd.Doctor).FirstOrDefault()
                              }).ToList();
                }
                else if (packageType == "01") // Doctor Package
                {
                    result = (from ab in db.Ar_Billings
                              join abd in db.Ar_Billing_Details on ab.Bill_ID equals abd.Bill_ID
                              join dp in db.DoctorPackages on Convert.ToInt32(ab.Package_Name) equals dp.Doc_Packages_ID
                              join dpr in db.Doctor_Packages_Detail_Rates on dp.Doc_Packages_ID equals dpr.Doc_Packages_ID
                              where abd.Item_ID == dpr.Item_Code
                                    && abd.Item_Type == dpr.Item_Type
                                    && dp.Doc_Packages_ID == packageName
                                    && ab.Bill_ID == Convert.ToInt32(Bill_Id)
                              select new
                              {
                                  ab.Bill_No,
                                  abd.Item_ID,
                                  ab.Bill_ID,
                                  ab.Patient_ID,
                                  abd.Item_Name,
                                  abd.Item_Type,
                                  abd.Amount,
                                  abd.Discount_Amount,
                                  abd.Net_Amount,
                                  dpr.is_expense,
                                  dp.Doctor_Share,
                                  dp.Hospital_Share,
                                  Doctor_Id = (from ipd in db.In_Patients where ipd.In_Patient_ID == ab.In_Patient_ID orderby ipd.In_Patient_ID descending select ipd.Doctor).FirstOrDefault()
                              }).ToList();
                }
                else if (packageType == "03") // Panel Package
                {
                    result = (from ab in db.Ar_Billings
                              join abd in db.Ar_Billing_Details on ab.Bill_ID equals abd.Bill_ID
                              join dp in db.PanelPackages on Convert.ToInt32(ab.Package_Name) equals dp.Pan_Packages_ID
                              join dpr in db.Panel_Packages_Detail_Rates on dp.Pan_Packages_ID equals dpr.Pan_Packages_ID
                              where abd.Item_ID == dpr.Item_Code
                                    && abd.Item_Type == dpr.Item_Type
                                    && dp.Pan_Packages_ID == packageName
                                    && ab.Bill_ID == Convert.ToInt32(Bill_Id)
                              select new
                              {
                                  ab.Bill_No,
                                  ab.Bill_ID,
                                  ab.Patient_ID,
                                  abd.Item_ID,
                                  abd.Item_Name,
                                  abd.Item_Type,
                                  abd.Amount,
                                  abd.Discount_Amount,
                                  abd.Net_Amount,
                                  dpr.is_expense,
                                  dp.Doctor_Share,
                                  dp.Hospital_Share,
                                  Doctor_Id = (from ipd in db.In_Patients where ipd.In_Patient_ID == ab.In_Patient_ID orderby ipd.In_Patient_ID descending select ipd.Doctor).FirstOrDefault()
                              }).ToList();
                }

                return Newtonsoft.Json.JsonConvert.SerializeObject(result);

        }
        [WebMethod]
        public static string SaveShare(string PatientID, string Doctor_ID, string Bill_Id, string Total_Bill_Amount, string Total_Expense, string Aftre_Expense_Amount, string DoctorShare, string HospitalShare, string AssignAmount)
        {
            try
            {
                DataBaseDataContext db = new DataBaseDataContext();
                Doctor_Payabled doc = new Doctor_Payabled();

                doc.Patient_Id = Convert.ToInt32(PatientID);
                doc.Doctor_Id = Doctor_ID;
                doc.Bill_Id = Convert.ToInt32(Bill_Id);
                doc.Total_Bill_Amount = Convert.ToDecimal(Total_Bill_Amount);
                doc.Total_Expense = Convert.ToDecimal(Total_Expense);
                doc.After_Expense_Amount = Convert.ToDecimal(Aftre_Expense_Amount);
                doc.Doctor_Share = Convert.ToDecimal(DoctorShare);
                doc.Hospital_Share = Convert.ToDecimal(HospitalShare);
                doc.Amount_Assign_To_Doctor = Convert.ToDecimal(AssignAmount);
                doc.Created_By = AppConfig.UserID;
                doc.Created_Time = DateTime.Now;

                db.Doctor_Payableds.InsertOnSubmit(doc);
                db.SubmitChanges();
                decimal DocShar = Convert.ToDecimal(DoctorShare);
                decimal Assignamount = Convert.ToDecimal(AssignAmount);

                if (DocShar == Assignamount)
                {
                    Ar_Billing p = new Ar_Billing();
                    var query = db.Ar_Billings.SingleOrDefault(x => x.Bill_ID == Convert.ToInt32(Bill_Id));
                    if (query != null)
                    {
                        query.IsAssign_Doctor = true;
                        db.SubmitChanges();
                    }
                }


                return "success";
             }
             catch (Exception ex)
             {
                return "error: " + ex.Message;
             }
        }

    }
}