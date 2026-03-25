using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.Accounts
{
    public partial class ClinicalFinancial : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
       
        [WebMethod]
        public static List<RowData> loadSavedRowsOPD()
        {
            using (var db = new DataBaseDataContext())
            {
                var data = (from x in db.ClinicalAccountCategories
                            where x.IsCancel == false && x.Fn_Department == "001"
                            select new RowData
                            {
                                categoryname = x.CategoryName,
                                cashinhand = x.CashInHand.ToString(),
                                discount = x.Discount.ToString(),
                                revenue = x.Revenue.ToString(),
                                financialdepartment = x.Fn_Department
                            }).ToList();

                return data;
            }
        }
       
        [WebMethod]
        public static List<RowData> loadSavedRowsOPDShare()
        {
            using (var db = new DataBaseDataContext())
            {
                var data = (from x in db.ClinicalAccountCategories
                            where x.IsCancel == false && x.Fn_Department == "010"
                            select new RowData
                            {
                                categoryname = x.CategoryName,
                                cashinhand = x.CashInHand.ToString(),
                                discount = x.Discount.ToString(),
                                revenue = x.Revenue.ToString(),
                                financialdepartment = x.Fn_Department
                            }).ToList();

                return data;
            }
        }
       
        [WebMethod]
        public static List<RowData> loadSavedRowsIPD()
        {
            using (var db = new DataBaseDataContext())
            {
                var data = (from x in db.ClinicalAccountCategories
                            where x.IsCancel == false && x.Fn_Department == "011"
                            select new RowData
                            {
                                categoryname = x.CategoryName,
                                cashinhand = x.CashInHand.ToString(),
                                discount = x.Discount.ToString(),
                                revenue = x.Revenue.ToString(),
                                financialdepartment = x.Fn_Department
                            }).ToList();

                return data;
            }
        }
       
        [WebMethod]
        public static List<RowData> loadSavedRowsReg()
        {
            using (var db = new DataBaseDataContext())
            {
                var data = (from x in db.ClinicalAccountCategories
                            where x.IsCancel == false && x.Fn_Department == "009"
                            select new RowData
                            {
                                categoryname = x.CategoryName,
                                cashinhand = x.CashInHand.ToString(),
                                discount = x.Discount.ToString(),
                                revenue = x.Revenue.ToString(),
                                financialdepartment = x.Fn_Department
                            }).ToList();

                return data;
            }
        }
        [WebMethod]
        public static List<RowData> loadSavedRowsDiagnostic()
        {
            using (var db = new DataBaseDataContext())
            {
                var data = (from x in db.ClinicalAccountCategories
                            where x.IsCancel == false && x.Fn_Department == "002"
                            select new RowData
                            {
                                categoryname = x.CategoryName,
                                cashinhand = x.CashInHand.ToString(),
                                discount = x.Discount.ToString(),
                                revenue = x.Revenue.ToString(),
                                financialdepartment = x.Fn_Department
                            }).ToList();

                return data;
            }
        }
        [WebMethod]
        public static List<RowData> loadSavedRowsDiagnosticShare()
        {
            using (var db = new DataBaseDataContext())
            {
                var data = (from x in db.ClinicalAccountCategories
                            where x.IsCancel == false && x.Fn_Department == "008"
                            select new RowData
                            {
                                categoryname = x.CategoryName,
                                cashinhand = x.CashInHand.ToString(),
                                discount = x.Discount.ToString(),
                                revenue = x.Revenue.ToString(),
                                financialdepartment = x.Fn_Department
                            }).ToList();

                return data;
            }
        }
        [WebMethod]
        public static List<RowData> loadSavedRowsEMERGENCY()
        {
            using (var db = new DataBaseDataContext())
            {
                var data = (from x in db.ClinicalAccountCategories
                            where x.IsCancel == false && x.Fn_Department == "003"
                            select new RowData
                            {
                                categoryname = x.CategoryName,
                                cashinhand = x.CashInHand.ToString(),
                                discount = x.Discount.ToString(),
                                revenue = x.Revenue.ToString(),
                                financialdepartment = x.Fn_Department
                            }).ToList();

                return data;
            }
        }
        [WebMethod]
        public static List<RowData> loadSavedRowsSERVICE()
        {
            using (var db = new DataBaseDataContext())
            {
                var data = (from x in db.ClinicalAccountCategories
                            where x.IsCancel == false && x.Fn_Department == "004"
                            select new RowData
                            {
                                categoryname = x.CategoryName,
                                cashinhand = x.CashInHand.ToString(),
                                discount = x.Discount.ToString(),
                                revenue = x.Revenue.ToString(),
                                financialdepartment = x.Fn_Department
                            }).ToList();

                return data;
            }
        }
        [WebMethod]
        public static List<RowData> loadSavedRowsPHARMACY()
        {
            using (var db = new DataBaseDataContext())
            {
                var data = (from x in db.ClinicalAccountCategories
                            where x.IsCancel == false && x.Fn_Department == "005"
                            select new RowData
                            {
                                categoryname = x.CategoryName,
                                cashinhand = x.CashInHand.ToString(),
                                discount = x.Discount.ToString(),
                                revenue = x.Revenue.ToString(),
                                financialdepartment = x.Fn_Department
                            }).ToList();

                return data;
            }
        }
        [WebMethod]
        public static List<RowData> loadSavedRowsSpecialService()
        {
            using (var db = new DataBaseDataContext())
            {
                var data = (from x in db.ClinicalAccountCategories
                            where x.IsCancel == false && x.Fn_Department == "006"
                            select new RowData
                            {
                                categoryname = x.CategoryName,
                                cashinhand = x.CashInHand.ToString(),
                                discount = x.Discount.ToString(),
                                revenue = x.Revenue.ToString(),
                                financialdepartment = x.Fn_Department
                            }).ToList();

                return data;
            }
        }
        [WebMethod]
        public static List<RowData> loadSavedRowsProcedure()
        {
            using (var db = new DataBaseDataContext())
            {
                var data = (from x in db.ClinicalAccountCategories
                            where x.IsCancel == false && x.Fn_Department == "007"
                            select new RowData
                            {
                                categoryname = x.CategoryName,
                                cashinhand = x.CashInHand.ToString(),
                                discount = x.Discount.ToString(),
                                revenue = x.Revenue.ToString(),
                                financialdepartment = x.Fn_Department
                            }).ToList();

                return data;
            }
        }
    
        [WebMethod]
        public static string ClinicalFinancialDepartmentDropdown()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Clinical Financial Department"
                              select new
                              {
                                  dv.DataValue_Name,
                                  dv.DataValue_Description
                              }).ToList();
                data = new JavaScriptSerializer().Serialize(result);
            }
            return data;
        }
        [WebMethod]
        public static string PatientType()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Patient Type"
                              select new
                              {
                                  dv.DataValue_Name,
                                  dv.DataValue_Description
                              }).ToList();
                data = new JavaScriptSerializer().Serialize(result);
            }
            return data;
        }
        [WebMethod]
        public static string MainTestDepartments()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Main Test Departments"
                              select new
                              {
                                  dv.DataValue_Name,
                                  dv.DataValue_Description
                              }).ToList();
                data = new JavaScriptSerializer().Serialize(result);
            }
            return data;
        }
        [WebMethod]
        public static string SpecialServices()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.INV_Items
                              where dv.IsSpecialService == true
                              select new
                              {
                                 DataValue_Name = dv.Item_ID ,
                                 DataValue_Description = dv.Description
                              }).ToList();
                data = new JavaScriptSerializer().Serialize(result);
            }
            return data;
        }
        [WebMethod]
        public static string filldropdowns()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var query = (from account in db.GL_Accounts
                         where account.Levels == 4
                         select new
                         {
                             account.Account_Code,
                             account.Account_ID,
                             account.Account_Name
                         }).ToList();
            string data = string.Empty;
            return (new JavaScriptSerializer()).Serialize(query);
        }
        [WebMethod]
        public static void InsertData(List<RowData> rows)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            // Delete existing records
            db.ClinicalAccountCategories.DeleteAllOnSubmit(db.ClinicalAccountCategories);
            db.SubmitChanges();

            // Reset identity
            db.ExecuteCommand("DBCC CHECKIDENT ('ClinicalAccountCategory', RESEED, 0)");

            foreach (RowData row in rows)
            {
                string category = row.categoryname;
                string financialDept = row.financialdepartment;
                string financialDept_name = (from dv in db.DataValues
                                             join ds in db.ValueSets
                                             on dv.ValueSet_ID equals ds.ValueSet_ID
                                             where ds.ValueSet_Name == "Clinical Financial Department" && dv.DataValue_Name == financialDept
                                             select dv.DataValue_Description).FirstOrDefault();

                int cash = 0, discount = 0, revenue = 0;

                // Parse values
                int.TryParse(row.cashinhand, out cash);
                int.TryParse(row.discount, out discount);
                int.TryParse(row.revenue, out revenue);

                // For Advance tab, Dr is stored in CashInHand and Cr in Revenue
                // For other tabs, they are used normally

                ClinicalAccountCategory table = new ClinicalAccountCategory
                {
                    Fn_Department = financialDept,
                    Fn_Department_Name = financialDept_name,
                    CategoryName = category,
                    CashInHand = cash,
                    Discount = discount,
                    Revenue = revenue,
                    CreatedBy = AppConfig.UserID,
                    CreatedDate = DateTime.Now,
                    IsCancel = false
                };

                db.ClinicalAccountCategories.InsertOnSubmit(table);
            }

            db.SubmitChanges();
        }
        [WebMethod]
        public static List<RowData> loadSavedRowsAdvance()
        {
            using (var db = new DataBaseDataContext())
            {
                var data = (from x in db.ClinicalAccountCategories
                            where x.IsCancel == false && x.Fn_Department == "012"
                            select new RowData
                            {
                                categoryname = x.CategoryName,
                                dr = x.CashInHand.HasValue ? x.CashInHand.Value.ToString() : "",  // Map CashInHand to Dr
                                cr = x.Revenue.HasValue ? x.Revenue.Value.ToString() : "",        // Map Revenue to Cr
                                financialdepartment = x.Fn_Department
                            }).ToList();

                return data;
            }
        }

        [WebMethod]
        public static string AdvanceCategories()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Advance Categories"
                              select new
                              {
                                  dv.DataValue_Name,
                                  dv.DataValue_Description
                              }).ToList();
                data = new JavaScriptSerializer().Serialize(result);
            }
            return data;
        }

        // Create a class to receive row data

        public class RowData
        {
            public string financialdepartment_name { get; set; }
            public string financialdepartment { get; set; }
            public string categoryname { get; set; }
            public string cashinhand { get; set; }
            public string discount { get; set; }
            public string revenue { get; set; }
            public string dr { get; set; }  // Add this line
            public string cr { get; set; }  // Add this line
        }
    }
}