using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.Entity;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Windows;
using Telerik.Web;
using Telerik.Web.UI.ImageEditor;
using static PMS.Modules.Administrator.Doctor_Payable;

namespace PMS
{
    public partial class BillingProcess : System.Web.UI.Page
    {
        private static string RptTime;
        protected void Page_Load(object sender, EventArgs e)
        {
            BindingDropDown();
            SetFinalBillButtonVisibility();
        }

        private void SetFinalBillButtonVisibility()
        {
            btnIPDFinalPrint.Visible = false;
            btnEstimatedBill.Visible = false;
            long billId;
            if (long.TryParse(Request.QueryString["Bill_ID"], out billId) && billId > 0)
            {
                object flag = DBClass.getField("SELECT ISNULL(final_bill_ipd, 0) FROM Ar_Billings WHERE Bill_ID = " + billId);

                string flagStr = (flag == null || flag == DBNull.Value) ? "" : flag.ToString().Trim();
                bool isFinal = flagStr == "1" || flagStr.Equals("true", StringComparison.OrdinalIgnoreCase);

                btnIPDFinalPrint.Visible = isFinal;

                // Estimated bill only shows when final bill not saved yet for this bill
                // and the bill has an in-patient admission against it.
                object inPatient = DBClass.getField("SELECT ISNULL(In_Patient_ID, 0) FROM Ar_Billings WHERE Bill_ID = " + billId);

                string ipStr = (inPatient == null || inPatient == DBNull.Value) ? "0" : inPatient.ToString().Trim();
                long ipVal = 0;
                long.TryParse(ipStr, out ipVal);

                btnEstimatedBill.Visible = !isFinal && ipVal > 0;
            }
        }
        private void BindingDropDown()
        {
            object valueset;
            valueset = DBClass.GetValueSet("Procedure discription");
            ddlpro_dis.DataSource = valueset;
            ddlpro_dis.DataTextField = "DataValue_Description";
            ddlpro_dis.DataValueField = "DataValue_Name";
            ddlpro_dis.Items.Add(new ListItem("Please Select", "0"));
            ddlpro_dis.DataBind();
        }
        [WebMethod]
        public static string ApproveRegpatient(string Pat_Id)
        {
            var UserId = AppConfig.UserID;
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.sp_ApprovePatientCardFee(Convert.ToInt32(Pat_Id), UserId);
            return (new JavaScriptSerializer()).Serialize(Details);
        }
        [WebMethod]
        public static string fillSahreTypes()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var d = (from st in db.DataValues where st.ValueSet_ID == 1114 select new { st.DataValue_Name, st.DataValue_Description }).ToList();
                data = new JavaScriptSerializer().Serialize(d);
            }
            return data;
        }
        // First WebMethod: Check if Walkin Patient Reg Fee is active (Code = "01")
        [WebMethod]
        public static string IsWalkinPatientRegFeeActive()
        {
            try
            {
                using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    var code = (from tbl in db.sys_Parms
                                where tbl.Name == "Walkin Patient Reg Fee"
                                select tbl.Code)
                               .FirstOrDefault();

                    // Return "01" if active, otherwise "0"
                    return (code == "01") ? "01" : "0";
                }
            }
            catch (Exception ex)
            {
                return "0";
            }
        }

        // Second WebMethod: Get the actual fee amount
        [WebMethod]
        public static string GetWalkinPatientRegFee()
        {
            try
            {
                using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    var fee = (from tbl in db.sys_Parms
                               where tbl.Name == "OPD Fee"
                               select tbl.Code)
                              .FirstOrDefault();

                    return fee ?? "0";
                }
            }
            catch (Exception ex)
            {
                return "0";
            }
        }
        [WebMethod]
        public static string RightAppointmentBilling()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var dept = (from data in db.sys_Parms
                        where data.Name == "Appointment Billing"
                        select
                          data.Code
                        ).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(dept);
        }
        [WebMethod]
        public static string ReceiptsUpdateonBilling()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var dept = (from data in db.sys_Parms
                        where data.Name == "Receipts Update on Billing"
                        select
                          data.Code
                        ).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(dept);
        }
        [WebMethod]
        public static string CNICUpdateCondition()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var dept = (from data in db.sys_Parms
                        where data.Name == "CNIC Validation"
                        select
                          data.Code
                        ).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(dept);
        }
        [WebMethod]
        public static string BillingSaveButtonVisible()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var code = (from data in db.sys_Parms
                        where data.Name == "Billing Save Button"
                        select data.Code).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(code);
        }
        [WebMethod]
        public static string CheckBillingServicesDeptWise()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var dept = (from data in db.sys_Parms
                        where data.Name == "Billing Services Load Dept Wise"
                        select data.Code).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(dept ?? "0");
        }

        [WebMethod]
        public static string AllowDuplicateBillingItems()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var dept = (from data in db.sys_Parms
                        where data.Name == "Allow Duplicate Billing Items"
                        select data.Code).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(dept ?? "0");
        }

        [WebMethod]
        public static string GetCardioTests()
        {

            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var tests = from t in db.Lab_Tests
                        where t.Main_Department == "008" && t.Active == true
                        select new { t.Test_ID, Test_Name = t.Test_Name, t.Group_Category };
            List<TestIDsAndGroupCategory> listOfTest = new List<TestIDsAndGroupCategory>();
            int counter = 1;
            foreach (var test in tests)
            {
                TestIDsAndGroupCategory obj = new TestIDsAndGroupCategory();
                obj.TestID = test.Test_ID.ToString();
                obj.TestName = test.Test_Name.ToString() + (test.Group_Category != string.Empty ? " | " + DBClass.getField("select Datavalue_Description from Datavalues where Datavalue_Name = '" + test.Group_Category + "' and Valueset_ID = 70") : string.Empty);
                obj.SerialNo = counter.ToString();
                obj.IsGroupCategory = false;
                listOfTest.Add(obj);
                counter++;
            }

            var GroupCategories = from dv in db.DataValues
                                  join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                                  where vs.ValueSet_Name == "Test Groups" && dv.Division == "008"
                                  select new { dv.DataValue_Name, dv.DataValue_Description };

            foreach (var category in GroupCategories)
            {
                TestIDsAndGroupCategory obj = new TestIDsAndGroupCategory();
                obj.TestID = category.DataValue_Name.ToString();
                obj.TestName = category.DataValue_Description.ToString();
                obj.SerialNo = counter.ToString();
                obj.IsGroupCategory = true;
                obj.CategoryID = category.DataValue_Name;
                listOfTest.Add(obj);
                counter++;
            }

            return (new JavaScriptSerializer()).Serialize(listOfTest);
        }
        [WebMethod]
        public static string CheckEditRights()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var ups = (from St in db.aspnet_Users
                       where St.UserId == AppConfig.UserID
                       select St.Allow_bill_edit).FirstOrDefault();

            return (new JavaScriptSerializer()).Serialize(ups);
        }
        //[WebMethod]
        //public static string PendingPatients(string SearchString)
        //{
        //    string result;
        //    using (DataBaseDataContext db = new DataBaseDataContext())
        //    {
        //        var query = db.Sp_GetLast24Hours_Test(SearchString).ToList();
        //        result = (new JavaScriptSerializer()).Serialize(query).ToString();

        //    }
        //    return result;

        //}
        [WebMethod]
        public static string RejectLabTestDetail(string LabTestDetail_ID)
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    int labTestDetailId = Convert.ToInt32(LabTestDetail_ID);

                    // Get the Lab_Test_Detail record
                    var labTestDetail = db.Lab_Test_Details
                        .FirstOrDefault(ltd => ltd.Lab_Test_Detail_ID == labTestDetailId);

                    if (labTestDetail == null)
                    {
                        return new JavaScriptSerializer().Serialize(new
                        {
                            Success = false,
                            Message = "Lab test detail not found."
                        });
                    }

                    // Check if already closed
                    if (labTestDetail.is_Closed == true)
                    {
                        return new JavaScriptSerializer().Serialize(new
                        {
                            Success = false,
                            Message = "This test has already been rejected/closed."
                        });
                    }

                    // Set the rejection/close status using your columns
                    labTestDetail.is_Closed = true;           // Mark as closed
                    labTestDetail.Close_Status = "Closed";   // Set status to Rejected
                    labTestDetail.Close_by = AppConfig.UserID; // Set who closed it

                    // Optional: Store rejection reason if you have a column
                    // labTestDetail.Close_Remarks = RejectionReason;

                    // Optional: Add timestamp if you have a column for it
                    // labTestDetail.Close_Date = DateTime.Now;

                    db.SubmitChanges();

                    return new JavaScriptSerializer().Serialize(new
                    {
                        Success = true,
                        Message = "Test has been rejected successfully.",
                        LabTestDetail_ID = labTestDetailId
                    });
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new
                {
                    Success = false,
                    Message = ex.Message
                });
            }
        }
        [WebMethod]
        public static string PendingPatients(string SearchString)
        {
            string result;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                if (string.IsNullOrWhiteSpace(SearchString))
                {
                    SearchString = null;
                }

                var query = db.Sp_GetLast24Hours_Test(SearchString).ToList();

                result = (new JavaScriptSerializer()).Serialize(query).ToString();
            }
            return result;
        }

        [WebMethod]
        public static string GetDischargeRequests(string SearchString)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                if (string.IsNullOrWhiteSpace(SearchString))
                {
                    SearchString = null;
                }

                var query = from ip in db.In_Patients
                            join r in db.Reg_patients on ip.Patient_ID equals r.pat_id
                            where ip.Company_ID == AppConfig.Company_ID
                                  && ip.Discharge_Request == true
                                  && (ip.Discharge == null || ip.Discharge == false)
                                  && (ip.Final_Bill == null || ip.Final_Bill == false)
                                  && (SearchString == null
                                      || r.mr_no_sequence.Contains(SearchString)
                                      || r.Full_Name.Contains(SearchString))
                            orderby ip.Created_Time descending
                            select new
                            {
                                In_Patient_ID = ip.In_Patient_ID,
                                Reg_Patient_ID = r.pat_id,
                                MR_No = r.mr_no_sequence,
                                Full_Name = r.Full_Name,
                                Age = r.Age_years,
                                Gender = r.Gender,
                                Doctor = (from d in db.HR_Employees
                                          where d.Emp_ID == Convert.ToInt32(ip.Doctor)
                                          select d.Emp_Name).FirstOrDefault() ?? "",
                                Department = ip.Department,
                                Ward_Name = (from w in db.Ward_Definitions
                                             where w.Ward_ID == ip.Ward_ID
                                             select w.Ward_Type).FirstOrDefault() ?? "",
                                Bed_No = ip.Bed_No,
                                Admission_Date = (System.DateTime?)ip.Admission_Date
                            };

                return (new JavaScriptSerializer()).Serialize(query.ToList());
            }
        }

        // Info Desk button is shown only when sys_Parms has "Billing Info Desk" = "01" for the company
        public bool ShowInfoDesk
        {
            get
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    return db.sys_Parms.Any(p => p.Name == "Billing Info Desk" && p.Code == "01" && p.Company_ID == AppConfig.Company_ID);
                }
            }
        }

        [WebMethod]
        public static string GetAllTests()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = (from t in db.Lab_Tests
                             where t.Test_Name != null && t.Test_Name.Trim() != ""
                             orderby t.Test_Name
                             select new
                             {
                                 Test_ID = t.Test_ID,
                                 Test_Name = t.Test_Name,
                                 Main_Department = t.Main_Department,
                                 Main_Department_Name = db.GetDataValueName("Main Test Departments", t.Main_Department) ?? string.Empty,
                                 Group_Department_Name = db.GetDataValueName("Test Departments", t.Group_Department) ?? string.Empty,
                                 Genre_Name = db.GetDataValueName("Sample Genre", t.Genre) ?? string.Empty,
                                 Designation_Name = db.GetDataValueName("Designation", t.Test_Designation) ?? string.Empty,
                                 Qty = t.Qty,
                                 Reporting_Time = t.Reporting_Time,
                                 Reporting_Day = t.Reporting_Day,
                                 WaitingTime = t.WaitingTime,
                                 Rate = t.Rate
                             }).ToList();

                return (new JavaScriptSerializer()).Serialize(query);
            }
        }

        [WebMethod]
        public static string GetMainTestDepartments()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var dep = (from dv in db.DataValues
                           join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                           where vs.ValueSet_Name == "Main Test Departments"
                           select new { dv.DataValue_Name, dv.DataValue_Description }).ToList();

                return (new JavaScriptSerializer()).Serialize(dep);
            }
        }



        [WebMethod]
        public static string GetGLAccounts()
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var cashList = (from i in db.GL_Accounts
                            where i.Levels == 4 && i.Cash == true
                            select new
                            {
                                i.Account_ID,
                                name = i.Account_Code + "-" + i.Account_Name
                            }).ToList();

            var bankList = (from i in db.GL_Accounts
                            where i.Levels == 4 && i.Bank == true
                            select new
                            {
                                i.Account_ID,
                                name = i.Account_Code + "-" + i.Account_Name
                            }).ToList();

            var result = new
            {
                cash = cashList,
                bank = bankList
            };

            return new JavaScriptSerializer().Serialize(result);
        }
        [WebMethod]
        public static string EditPatient(string PatID)
        {
            // Get permission value from DB function (returns '0' or '1' as string)
            string allowValue = DBClass.getField(
                $"SELECT dbo.GetRights('AllowPatientEdit', '{AppConfig.UserID}')"
            );

            // Treat null/empty as '0' (not allowed) for safety
            if (Convert.ToBoolean(allowValue) == true)
            {
                return "Allowed";
            }
            else
            {
                return "NotAllowed";
            }
        }
        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static string AddAllowPatient()
        {
            DataBaseDataContext db = new DataBaseDataContext();

            try
            {
                // LINQ query to check if user has Add Patient permission
                var hasPermission = (from user in db.aspnet_Users
                                     where user.UserId == AppConfig.UserID
                                     select user.AllowAddPatient).FirstOrDefault();

                // If null or false, return NotAllowed
                if (hasPermission == null || hasPermission == false)
                {
                    return "NotAllowed";
                }

                return "Allowed";
            }
            catch (Exception ex)
            {
                // Log error if needed
                return "NotAllowed";
            }
        }
        [WebMethod]
        public static string CheckRecipeRights()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var ups = (from St in db.aspnet_Users
                       where St.UserId == AppConfig.UserID
                       select St.Allow_Recipe).FirstOrDefault();

            return (new JavaScriptSerializer()).Serialize(ups);
        }
        [WebMethod]
        public static string AllowEditRates()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var ups = (from St in db.aspnet_Users
                       where St.UserId == AppConfig.UserID
                       select St.AllowRateEdit).FirstOrDefault();

            return (new JavaScriptSerializer()).Serialize(ups);
        }

        [WebMethod]
        public static object GetBOMDetailsByProcedure(int procedureId)
        {
            if (procedureId <= 0)
                return new { success = false, message = "Invalid procedure ID." };

            using (var db = new DataBaseDataContext())
            {
                // Get BOM ID for the procedure
                var bomId = db.inv_boms
                              .Where(b => b.ProcedureID == procedureId)
                              .Select(b => b.BOMID)
                              .FirstOrDefault();

                if (bomId <= 0)
                    return new { success = false, message = "No BOM found for this procedure." };

                // Fetch BOM items + real-time weighted average cost
                var items = (from bd in db.inv_bom_details
                             join i in db.INV_Items on bd.ItemID equals i.Item_ID
                             where bd.BOMID == bomId
                             select new
                             {
                                 bd.BOMDetailID,
                                 bd.ItemID,
                                 ItemCode = i.Item_Code,
                                 Description = i.Description,
                                 Qty = bd.Qty,
                                 Unit = bd.Unit,
                                 RecipeCostPerUnit = bd.CostPerUnit,
                                 RecipeTotal = bd.Total,
                                 Batch_No = bd.Batch_No,
                                 BaseUnitQty = bd.BaseUnitQty,

                                 // ✅ REAL-TIME WEIGHTED AVERAGE COST (from your UDF)
                                 CurrentAvgCost = db.GetAvgAmount(bd.ItemID) ?? 0m,
                                 RuntimeCost = (db.GetAvgAmount(bd.ItemID) ?? 0m) * bd.Qty
                             })
                            .ToList();

                return new
                {
                    success = true,
                    procedureId,
                    bomId,
                    items
                };
            }
        }
        [WebMethod]
        public static object GetItemCodesforBOM(int Pat_id)  
        {
            try
            {
                using (var db = new DataBaseDataContext())
                {
                    var itemId = (from p in db.Reg_patients
                                  join vs in db.Patients on p.pat_id equals vs.Reg_PatId
                                  where vs.Reg_PatId == Pat_id
                                  && vs.Is_billed == false
                                  orderby vs.Created_Time descending   // 👈 sort newest first
                                  select vs.Service_id)
                                .FirstOrDefault();


                    if (itemId <= 0)
                        return null;
                    var item = db.INV_Items
                                 .Where(i => i.Item_ID == itemId)
                                 .Select(i => new
                                 {
                                     i.Item_ID,
                                     i.Item_Code,
                                     i.Description,
                                     i.UOM_Qty,
                                     i.Services,
                                     i.Purchase_Rate,
                                     Unit = db.GetDataValueName("UOM", i.Unit), 
                                     i.Sale_Rate,
                                     Procedure_types = i.Procedure_types 
                                 })
                                 .FirstOrDefault();

                    return item;
                }
            }
            catch (Exception ex)
            {
                // Log ex if needed
                return null;
            }
        }
        [WebMethod]
        public static string GetItemCodes(int Pat_id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var pat_ids = (from p in db.Reg_patients join vs in db.Out_Patients on p.pat_id equals vs.Reg_PatId where vs.Reg_PatId == Convert.ToInt32(Pat_id) select vs.Out_Patient_ID).FirstOrDefault();
            var itemCodes = (from op in db.Reg_patients
                             join ip in db.InPatientServices on op.pat_id equals ip.PatientId
                             where ip.Ou_Patient_Id == Convert.ToString(pat_ids) && ip.PatientType == "OutPatient"
                             && ip.isbilled == false
                             select ip.Service_ItemId).ToList();

            return (new JavaScriptSerializer()).Serialize(itemCodes); ;

        }
        [WebMethod]
        public static string GetItemCodesforipd(int pat_id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var pat_ids = (from p in db.Reg_patients join vs in db.In_Patients on p.pat_id equals vs.Patient_ID where vs.Patient_ID == Convert.ToInt32(pat_id) select vs.In_Patient_ID).FirstOrDefault();
            var itemCodes = (from op in db.Reg_patients
                             join ip in db.InPatientServices on op.pat_id equals ip.PatientId
                             where ip.PatientType == "IPD"
                               && ip.In_Patient_Id == pat_ids
                            && (ip.isbilled ?? false) == false
                             select ip.Service_ItemId).ToList();

            return (new JavaScriptSerializer()).Serialize(itemCodes); ;

        }


        [WebMethod]
        public static string GetItemCodesforEmergency(int Pat_id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var pat_ids = (from p in db.Reg_patients join vs in db.Emergency_Patients on p.pat_id equals vs.Patient_ID where vs.Patient_ID == Convert.ToInt32(Pat_id) select vs.Emergency_ID).FirstOrDefault();
            var itemCodes = (from op in db.Reg_patients
                             join ip in db.InPatientServices on op.pat_id equals ip.PatientId
                             where ip.EmergencyId == pat_ids
                             && ip.PatientType == "Emergency"
                            && (ip.isbilled ?? false) == false
                             select ip.Service_ItemId).ToList();

            return (new JavaScriptSerializer()).Serialize(itemCodes); ;

        }
        [WebMethod]
        public static string TotalAmountToday()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Amt = DBClass.getField("select isnull(sum(Received_Amount),0) as sum from Ar_Billings  where isnull(isCancel,'0')=0 and convert(varchar(10), Bill_Date, 102)= convert(varchar(10), getdate(), 102)");
            return Amt;
        }
        [WebMethod]
        public static string DeleteBillRights()
        {
            DataBaseDataContext db = new DataBaseDataContext();

            string DeleteBill = DBClass.getField("select dbo.GetRights('AllowBillDelete','" + AppConfig.UserID + "')");

            return (DeleteBill);
        }
        public class PatientsResult
        {
            public string Full_Name;
            public string NIC;
            public string Reg_Patient_ID;
            public string Age_years;
            public string Patient_No;
            public string Mobile1;
            public string Father_Name;

        }
        [WebMethod]
        public static List<PatientsResult> AddPatient(string SearchString)
        {

            string SearchSql = "";

            if (SearchString == "")

                SearchSql = "SELECT top 10 pat_id,isnull(mr_no_sequence,'')Patient_No,isnull(Full_Name,'')Full_Name,isnull(NIC,'')NIC,isnull(Mobile1,'') ContactNo,isnull(Father_Name,'')Father_Name FROM reg_patient where(1=1) and Patient_No<>0 and Patient_No is not null and isnull(isCancel,0)!=1 order by pat_id desc";
            else
                SearchSql = "SELECT top 200 pat_id,isnull(mr_no_sequence,'')Patient_No,isnull(Full_Name,'')Full_Name,isnull(NIC,'')NIC,isnull(Mobile1,'') ContactNo,isnull(Father_Name,'')Father_Name FROM reg_patient where(1=1) and Patient_No<>0 and Patient_No is not null and isnull(isCancel,0)!=1 and (LTRIM(RTRIM(patient_no)) like '%" + SearchString.Trim() + "%' or  LTRIM(RTRIM(full_name)) like '%" + SearchString.Trim() + "%' or LTRIM(RTRIM(mobile1))  like '%" + SearchString.Trim() + "%' or LTRIM(RTRIM(nic))  like '%" + SearchString.Trim() + "%') order by pat_id desc";

            DataTable dt = DBClass.getDataTable(SearchSql);

            List<PatientsResult> list = new List<PatientsResult>();

            foreach (DataRow dr in dt.Rows)
            {
                PatientsResult rslt = new PatientsResult()
                {
                    Reg_Patient_ID = dr[0] == DBNull.Value ? "" : (string)dr[0].ToString(),
                    Patient_No = dr[1] == DBNull.Value ? "" : (string)dr[1].ToString(),
                    Full_Name = dr[2] == DBNull.Value ? "" : (string)dr[2],
                    NIC = dr[3] == DBNull.Value ? "" : (string)dr[3],
                    Mobile1 = dr[4] == DBNull.Value ? "" : (string)dr[4],
                    Father_Name = dr[5] == DBNull.Value ? "" : (string)dr[5],
                };
                list.Add(rslt);

                int number;
                string value = "Hello";
                bool result = Int32.TryParse(value, out number);

            }
            return list;
        }
        [WebMethod]
        public static string Getmr_noss()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            Reg_patient pat = null;
            int? maxPatNo = db.Reg_patients.Max(p => (int?)p.Patient_No);
            int newPatNo = (maxPatNo.HasValue ? maxPatNo.Value : 0) + 1;

            return newPatNo.ToString();
        }
        public class PatientDetail_Reg
        {
            public string Name;
            public string Title;

            public string Gender;
            public string Age;
            public string DOB;

            public string Mobile;
            public string Address;

            public string Mr_No { get; set; }

            public string MaritalStatus { get; set; }

            public string FatherName { get; set; }

            public string Relation { get; set; }

            public string CNIC { get; set; }
            public string OtherCNIC { get; set; }


            public string Reg_PatientID { get; set; }




        }
        [WebMethod]
        public static PatientDetail_Reg GetEditPatientDetails(string Reg_Patient_ID)
        {
            PatientDetail_Reg pts = new PatientDetail_Reg();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            Reg_patient pat = new Reg_patient();
            pat = (from tbl in db.Reg_patients
                   where tbl.pat_id == Convert.ToInt32(Reg_Patient_ID)
                   orderby tbl.Created_time descending
                   select tbl).FirstOrDefault();

            if (pat != null)
            {


                string[] PatientName = pat.Full_Name.Split('.');
                pts.Title = PatientName[0] + ".";
                pts.Name = PatientName[PatientName.Length - 1];
                pts.FatherName = pat.Father_Name;
                pts.Gender = pat.Gender;
                pts.Relation = pat.Relation_prefix;
                //pts.DOB = Convert.ToDateTime(pat.DOB);
                if (pat.DOB != null)
                {
                    pts.DOB = Convert.ToDateTime(pat.DOB).ToString("dd/MM/yyyy");
                }
                else
                {
                    pts.DOB = "";
                };
                pts.Age = pat.Age_years.ToString();
                pts.MaritalStatus = pat.Martial_Status;
                //pt.Mr_No = Convert.ToString(pat.Patient_No);
                pts.Mr_No = Convert.ToString(pat.mr_no_sequence);
                pts.Address = pat.Permanent_Address;
                pts.Mobile = pat.Mobile1;
                pts.CNIC = pat.NIC;
                pts.OtherCNIC = pat.other_cnic;
                pts.Gender = pat.Gender;


                pts.Reg_PatientID = Reg_Patient_ID;
                return pts;
            }


            return pts;
        }
        [WebMethod]
        public static string SaveCNIC(string Patient_ID, string enteredCNIC)
        {
            try
            {
                DataBaseDataContext db = new DataBaseDataContext();

                int patId = Convert.ToInt32(Patient_ID);

                var patient = db.Reg_patients.SingleOrDefault(x => x.pat_id == patId);

                if (patient != null)
                {
                    patient.NIC = enteredCNIC;
                    db.SubmitChanges();

                    return "SUCCESS";
                }
                else
                {
                    return "PATIENT_NOT_FOUND";
                }
            }
            catch (Exception ex)
            {
                return "ERROR: " + ex.Message;
            }
        }
        [WebMethod]
        public static string PatientMonitoring(string Patient_ID)
        {
            try
            {
                DataBaseDataContext db = new DataBaseDataContext();

                int patId = Convert.ToInt32(Patient_ID);

                var patient = db.Reg_patients.SingleOrDefault(x => x.pat_id == patId);

                if (patient != null)
                {
                    patient.Monitoring = true;
                    db.SubmitChanges();

                    return "SUCCESS";
                }
                else
                {
                    return "PATIENT_NOT_FOUND";
                }
            }
            catch (Exception ex)
            {
                return "ERROR: " + ex.Message;
            }
        }


        [WebMethod]
        public static string SavePatientDetail(string Full_Name, string RelationType, string Relation, string Gender, string Mobile, string Date_Of_Birth, string CNIC, string OtherCNIC, string Address, string PatientID, string martail_status, string Age, string txtfees)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            JavaScriptSerializer JSS = new JavaScriptSerializer();
            Reg_patient pat = null;

            bool isNew = string.IsNullOrEmpty(PatientID) || PatientID == "0" || PatientID == "(New)";

            // CNIC VALIDATION CHECK - Only for new patients
            if (isNew && !string.IsNullOrWhiteSpace(CNIC))
            {
                var cnicValidation = db.sys_Parms.FirstOrDefault(p => p.Name == "CNIC Validation" && p.Code == "01");
                if (cnicValidation != null)
                {
                    var existingPatient = db.Reg_patients.FirstOrDefault(p => p.NIC == CNIC && p.iscancel == false);
                    if (existingPatient != null)
                    {
                        return "CNIC_EXISTS";
                    }
                }
            }
            // END OF CNIC VALIDATION

            if (!isNew)
            {
                pat = db.Reg_patients.Where(w => w.pat_id == Convert.ToInt32(PatientID)).FirstOrDefault();

                if (pat != null)
                {
                    pat.Relation_prefix = RelationType;
                    pat.Full_Name = Full_Name;
                    //pat.RelationType = RelationType;
                    pat.Father_Name = Relation;
                    pat.Gender = Gender;
                    pat.Mobile1 = Mobile;
                    pat.Age_years = Age;
                    string[] formats = { "dd/MM/yyyy", "MM/dd/yyyy" };
                    if (string.IsNullOrWhiteSpace(Date_Of_Birth))
                    {
                        pat.DOB = null;
                    }
                    else
                    {
                        if (!DateTime.TryParseExact(
                            Date_Of_Birth.Trim(),
                            "dd/MM/yyyy",
                            System.Globalization.CultureInfo.InvariantCulture,
                            System.Globalization.DateTimeStyles.None,
                            out DateTime dob))
                        {
                            return "ERROR: Date must be in dd/MM/yyyy format (e.g., 19/12/2000).";
                        }
                        pat.DOB = dob;
                    }
                    pat.NIC = CNIC;
                    pat.other_cnic = OtherCNIC;

                    pat.Permanent_Address = Address;
                    pat.Martial_Status = martail_status;
                    //pat.mr_no_sequence = db.GetSequentialMrNo();
                    pat.walkin = true;
                    pat.updated_by = AppConfig.UserID;
                    pat.updated_time = DateTime.Now;

                    var previousRegData = new
                    {
                        PatData = new
                        {
                            pat.Patient_No,
                            pat.mr_no_sequence,
                            CreationDate = pat.Created_time ?? DateTime.MinValue,
                            pat.Full_Name,
                            pat.Father_Name,
                            pat.Gender,
                            pat.Mobile1,
                            pat.Age_years,
                            pat.NIC,
                            pat.Permanent_Address,
                            pat.Martial_Status,
                            pat.Relation_prefix,
                            pat.walkin,
                            pat.city,
                            pat.val_city,
                            pat.val_area,
                            pat.area,
                            pat.Country,
                            pat.Province,
                            pat.Card_fee,
                            pat.other_cnic,
                            DOB = pat.DOB ?? DateTime.MinValue,

                        }

                    };

                    string masterLogJson = JSS.Serialize(previousRegData.PatData);
                    Reg_Patient_Log RegLog = new Reg_Patient_Log
                    {
                        Pat_Id = pat.pat_id,
                        Updated_data = masterLogJson,
                        Loged_Time = DateTime.Now,
                        Loged_by = AppConfig.UserID
                    };

                    db.Reg_Patient_Logs.InsertOnSubmit(RegLog);



                    db.SubmitChanges();
                }
            }
            else
            {
                pat = new Reg_patient();
                string PatientNumber = (DBClass.getMaxEntry_No("Reg_patient", "Patient_No")).ToString();
                pat.Patient_No = Convert.ToInt32(PatientNumber);
                //pat.Mr_No_seq = db.GetSequentialMrNo();
                pat.Full_Name = Full_Name;
                //pat.RelationType = RelationType;
                pat.Father_Name = Relation;
                pat.Relation_prefix = RelationType;
                pat.Gender = Gender;
                pat.Mobile1 = Mobile;
                pat.Age_years = Age;
                pat.NIC = CNIC;
                pat.other_cnic = OtherCNIC;
                pat.Permanent_Address = Address;
                pat.Created_time = DateTime.Now;
                pat.Created_by = AppConfig.UserID;
                pat.iscancel = false;
                pat.Martial_Status = martail_status;
              //  pat.Card_fee = Convert.ToDecimal(txtfees);
                if (string.IsNullOrWhiteSpace(Date_Of_Birth))
                {
                    pat.DOB = null;
                    pat.Age_years = null;
                }
                else
                {
                    if (!DateTime.TryParseExact(
                        Date_Of_Birth,
                        "dd/MM/yyyy",
                        System.Globalization.CultureInfo.InvariantCulture,
                        System.Globalization.DateTimeStyles.None,
                        out DateTime dob))
                    {
                        return "ERROR: Invalid date format. Use dd/MM/yyyy (e.g., 19/12/2000).";
                    }

                    pat.DOB = dob;
                    DateTime today = DateTime.Today;
                    int years = today.Year - dob.Year;
                    int months = today.Month - dob.Month;
                    int days = today.Day - dob.Day;

                    if (days < 0)
                    {
                        months--;
                        int prevMonth = today.Month == 1 ? 12 : today.Month - 1;
                        int prevYear = today.Month == 1 ? today.Year - 1 : today.Year;
                        days += DateTime.DaysInMonth(prevYear, prevMonth);
                    }
                    if (months < 0)
                    {
                        years--;
                        months += 12;
                    }

                    string formattedAge = "";
                    if (years > 0)
                    {
                        formattedAge = $"{years}Y";
                        if (months > 0) formattedAge += $" {months}M";
                        if (days > 0) formattedAge += $" {days}D";
                    }
                    else if (months > 0)
                    {
                        formattedAge = $"{months}M";
                        if (days > 0) formattedAge += $" {days}D";
                    }
                    else
                    {
                        formattedAge = $"{days}D";
                    }

                    pat.Age_years = formattedAge;
                }
                var companyID = AppConfig.Company_ID;
                var company = (from dt in db.sys_Companies
                               where dt.Company_ID == companyID
                               select dt).FirstOrDefault();
                string companyCode = company.CompanyCode;
                string MR_Sequence = string.IsNullOrWhiteSpace(companyCode) ? PatientNumber : $"{companyCode}-{PatientNumber}";

                pat.mr_no_sequence = MR_Sequence;
                pat.walkin = true;

                db.Reg_patients.InsertOnSubmit(pat);
                db.SubmitChanges();
            }
            return pat.pat_id.ToString();
        }
        [WebMethod]
        public static string GetChargePolicy()
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var Dis = (from d in db.DataValues
                       join v in db.ValueSets
                       on d.ValueSet_ID equals v.ValueSet_ID
                       where v.ValueSet_Name == "Charge Policy"
                       select new
                       {
                           d.DataValue_Name,
                           d.DataValue_Description
                       }).ToList();

            return (new JavaScriptSerializer().Serialize(Dis));
        }
        [WebMethod]
        public static string GetMainDepartment()
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var Dis = (from d in db.DataValues
                       join v in db.ValueSets
                       on d.ValueSet_ID equals v.ValueSet_ID
                       where v.ValueSet_Name == "Mode Of Registration"
                       select new
                       {
                           d.DataValue_Name,
                           d.DataValue_Description
                       }).ToList();

            return (new JavaScriptSerializer().Serialize(Dis));
        }
        [WebMethod]
        public static string GetSubdepartments()
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var Dis = (from d in db.DataValues
                       join v in db.ValueSets
                       on d.ValueSet_ID equals v.ValueSet_ID
                       where v.ValueSet_Name == "Patient Main Category"
                       select new
                       {
                           d.DataValue_Name,
                           d.DataValue_Description
                       }).ToList();

            return (new JavaScriptSerializer().Serialize(Dis));
        }

        [WebMethod]
        public static string GetCostCenter()
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var Dis = (from d in db.DataValues
                       join v in db.ValueSets
                       on d.ValueSet_ID equals v.ValueSet_ID
                       where v.ValueSet_Name == "Cost Center"
                       select new
                       {
                           d.DataValue_Name,
                           d.DataValue_Description
                       }).ToList();

            return (new JavaScriptSerializer().Serialize(Dis));
        }

        [WebMethod]
        public static string GetCostCenterByDepartment(string department)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var allCostCenters = (from d in db.DataValues
                                  join v in db.ValueSets
                                  on d.ValueSet_ID equals v.ValueSet_ID
                                  where v.ValueSet_Name == "Cost Center"
                                  select new
                                  {
                                      d.DataValue_Name,
                                      d.DataValue_Description
                                  }).ToList();

            var mapped = (from m in db.CostCenter_Wise_Departments
                          join dt in db.CostCenter_Wise_Department_Details
                              on m.CostCenter_wise_Department_Id equals dt.CostCenter_wise_Department_Id
                          where dt.Department == department
                          select m.CostCenter).Distinct().ToList();

            var Dis = mapped.Select(cc => new
            {
                DataValue_Name = cc,
                DataValue_Description = allCostCenters
                    .Where(c => c.DataValue_Name == cc)
                    .Select(c => c.DataValue_Description)
                    .FirstOrDefault() ?? cc
            }).ToList();

            return (new JavaScriptSerializer().Serialize(Dis));
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
                               && (dv.DataValue_Name == "01" || dv.DataValue_Name == "02")
                              select new
                              {
                                  dv.DataValue_Name,
                                  dv.DataValue_Description
                              }).ToList();
                data = new JavaScriptSerializer().Serialize(result);
            }
            return data;
        }

        //changes for opd
        [WebMethod]
        public static string FetchRecommendedDetails(int PatientID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var PatNo = (from r in db.Reg_patients
                         join p in db.Patients
                         on r.pat_id equals p.Reg_PatId
                         where p.Reg_PatId == PatientID
                         select p.Patient_No
                          ).FirstOrDefault();

            var testDetails = (from lbtM in db.Laboratory_Tests
                               join lbtD in db.Lab_Test_Details
                               on lbtM.Lab_Test_ID equals lbtD.Lab_Test_ID
                               join opat in db.Out_Patients
                               on lbtM.Patient_ID equals opat.Out_Patient_ID
                               join lbTDdef in db.Lab_Tests
                               on lbtD.Test_ID equals lbTDdef.Test_ID
                               join p in db.Patients
                               on opat.Patient_ID equals p.Patient_ID
                               where opat.Patient_ID == p.Patient_ID && p.Reg_PatId == Convert.ToInt32(PatientID) && (lbtD.IsBilled == null) && lbtM.Transaction_Type == "OutPatient" && (lbtD.is_Closed == false || lbtD.is_Closed == null)

                               select new
                               {
                                   lbtM.Lab_Test_ID,
                                   lbTDdef.Test_ID,
                                   Category_ID = lbTDdef.Group_Category,
                                   lbtD.Date,
                                   lbtD.Remark,
                                   lbTDdef.Test_Name,

                                   DepartmentName = (db.GetDataValueName("Main Test Departments", lbTDdef.Main_Department) == null ? "" : db.GetDataValueName("Main Test Departments", lbTDdef.Main_Department)),
                                   lbTDdef.Group_Category,
                                   lbTDdef.Main_Department,
                                   GroupName = db.GetDataValueName("Test Groups", lbTDdef.Group_Category),
                                   ParentTrans_ID = lbtD.Lab_Test_Detail_ID,
                                   ParentTrans_Type = "Test",
                                   lbtD.Dept_ID,
                                   Rate = (lbTDdef.Rate == 0) ? Convert.ToDecimal(DBClass.getField("select dbo.getTestRate('" + p.Patient_Type + "', " + lbTDdef.Test_ID + ", " + p.Patient_ID + ")")) : lbTDdef.Rate,
                                   lbtM.Created_Time

                               }

                ).ToList();

            // Fetching Grouped Categories....

            var testDetailsGroupswise = (from lbtM in db.Laboratory_Tests
                                         join lbtD in db.Lab_Test_Details
                                         on lbtM.Lab_Test_ID equals lbtD.Lab_Test_ID
                                         join opat in db.Out_Patients
                                         on lbtM.Patient_ID equals opat.Out_Patient_ID
                                         join p in db.Patients
                                         on opat.Patient_ID equals p.Patient_ID
                                         where opat.Patient_ID == p.Patient_ID && lbtD.Test_ID == 0 && p.Reg_PatId == Convert.ToInt32(PatientID) && lbtD.IsBilled == null
                                         && lbtM.Transaction_Type == "OutPatient" && (lbtD.is_Closed == false || lbtD.is_Closed == null)
                                         select new
                                         {
                                             lbtD.Lab_Test_ID,
                                             lbtD.Test_ID,
                                             lbtD.Catagory_ID,
                                             lbtD.Date,
                                             lbtD.Remark,
                                             Rate = (from dv in db.DataValues
                                                     join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                                                     where vs.ValueSet_Name == "Test Groups" && dv.DataValue_Name == lbtD.Catagory_ID
                                                     select dv.Segment1).FirstOrDefault(),
                                             Test_Name = db.GetDataValueName("Test Groups", lbtD.Catagory_ID),
                                             ParentTrans_ID = lbtD.Lab_Test_Detail_ID,
                                             ParentTrans_Type = "Test Group Category",
                                             lbtD.Dept_ID,
                                             lbtM.Created_Time
                                         }
                ).ToList();

            List<BillingProcessDetails> listRecommendedTests = new List<BillingProcessDetails>();

            foreach (var test in testDetails)
            {
                BillingProcessDetails RecommendedService = new BillingProcessDetails();
                RecommendedService.ParentTrans_ID = test.ParentTrans_ID;
                RecommendedService.ParentTrans_Type = "Test";
                RecommendedService.ItemID = test.Test_ID;
                RecommendedService.ItemName = test.Test_Name;
                RecommendedService.Remarks = test.Remark;
                RecommendedService.ItemType = "Test";
                RecommendedService.RecommendedByDoctor = true;
                RecommendedService.CategoryID = "0";
                RecommendedService.Amount = (test.Rate == null) ? 0 : (decimal)test.Rate;
                RecommendedService.MainDepartment = test.Dept_ID;
                RecommendedService.Test_CreatedDate = Convert.ToDateTime(test.Created_Time);
                listRecommendedTests.Add(RecommendedService);
            }

            if (testDetailsGroupswise.Count > 0)
            {
                foreach (var group in testDetailsGroupswise)
                {
                    BillingProcessDetails RecommendedService = new BillingProcessDetails();
                    RecommendedService.ParentTrans_ID = group.ParentTrans_ID;
                    RecommendedService.ParentTrans_Type = "Test Group Category";
                    RecommendedService.ItemID = group.Test_ID;
                    RecommendedService.ItemName = group.Test_Name;
                    RecommendedService.Remarks = group.Remark;
                    RecommendedService.ItemType = "Test";
                    RecommendedService.RecommendedByDoctor = true;
                    RecommendedService.CategoryID = group.Catagory_ID;
                    RecommendedService.MainDepartment = group.Dept_ID;
                    string rate = group.Rate.ToString();
                    if (rate == string.Empty)
                    {
                        rate = "0";
                    }
                    RecommendedService.Amount = (rate == null) ? 0 : Convert.ToDecimal(rate);
                    RecommendedService.Test_CreatedDate = Convert.ToDateTime(group.Created_Time);


                    listRecommendedTests.Add(RecommendedService);
                }
            }


            return (new JavaScriptSerializer()).Serialize(listRecommendedTests);
        }

        [WebMethod]
        public static string fetchServices(int itemId,int Pat_id)
        {
            string result = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.sp_fetch_Services(itemId,Pat_id).ToList();
                result = (new JavaScriptSerializer()).Serialize(query).ToString();
            }
            return result;
        }

        [WebMethod]
        public static string FetchRecommendedInPatientDetails(int PatientID)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var PatNo = (from p in db.Reg_patients
                         where p.pat_id == PatientID
                         select p.Patient_No).FirstOrDefault();

            // Get the current active inpatient record to check Panel_Company
            var inpatientData = (from ip in db.In_Patients
                                 where ip.Patient_ID == PatientID
                                       && (ip.Discharge == false || ip.Discharge == null)
                                 orderby ip.Created_Time descending
                                 select new { ip.In_Patient_ID, ip.Panel_Company, ip.Patient_Discount_Type })
                                 .FirstOrDefault();

            // Check if panel exists (not null, not 0, not empty)
            bool hasPanel = inpatientData != null
                            && !string.IsNullOrEmpty(inpatientData.Panel_Company)
                            && inpatientData.Panel_Company != "0"
                            && inpatientData.Panel_Company != "null";

            int? panelCompanyId = null;
            if (hasPanel && int.TryParse(inpatientData.Panel_Company, out int panelId))
            {
                panelCompanyId = panelId;
            }

            // Fetch individual test details
            var testDetails = (from lbtM in db.Laboratory_Tests
                               join lbtD in db.Lab_Test_Details
                               on lbtM.Lab_Test_ID equals lbtD.Lab_Test_ID
                               join opat in db.In_Patients
                               on lbtM.Patient_ID equals opat.In_Patient_ID
                               join lbTDdef in db.Lab_Tests
                               on lbtD.Test_ID equals lbTDdef.Test_ID
                               join p in db.Reg_patients
                               on opat.Patient_ID equals p.pat_id
                               where p.Patient_No == Convert.ToInt32(PatNo)
                                     && (lbtD.IsBilled == null || lbtD.IsBilled == false)
                                     && lbtM.Transaction_Type == "InPatient"
                                     && (opat.Discharge == false || opat.Discharge == null)
                                     && (lbtD.is_Closed == false || lbtD.is_Closed == null)
                               select new
                               {
                                   lbtM.Lab_Test_ID,
                                   lbTDdef.Test_ID,
                                   lbtD.Date,
                                   lbtD.Remark,
                                   lbTDdef.Test_Name,
                                   ParentTrans_ID = lbtD.Lab_Test_Detail_ID,
                                   ParentTrans_Type = "Test",
                                   lbtD.Dept_ID,
                                   Rate = (lbTDdef.Rate == 0) ? Convert.ToDecimal(DBClass.getField("select dbo.getTestRate('" + opat.Patient_Discount_Type + "', " + lbTDdef.Test_ID + ", " + p.pat_id + ")")) : lbTDdef.Rate,
                                   lbtM.Created_Time
                               }).ToList();

            // Fetch group test details
            var testDetailsGroupswise = (from lbtM in db.Laboratory_Tests
                                         join lbtD in db.Lab_Test_Details
                                         on lbtM.Lab_Test_ID equals lbtD.Lab_Test_ID
                                         join opat in db.In_Patients
                                         on lbtM.Patient_ID equals opat.In_Patient_ID
                                         join p in db.Reg_patients
                                         on opat.Patient_ID equals p.pat_id
                                         where opat.Patient_ID == p.pat_id
                                               && lbtD.Test_ID == 0
                                               && p.Patient_No == Convert.ToInt32(PatNo)
                                               && (lbtD.IsBilled == null || lbtD.IsBilled == false)
                                               && lbtM.Transaction_Type == "InPatient"
                                               && (opat.Discharge == false || opat.Discharge == null)
                                               && (lbtD.is_Closed == false || lbtD.is_Closed == null)
                                         select new
                                         {
                                             lbtD.Lab_Test_ID,
                                             lbtD.Test_ID,
                                             Catagory_ID = lbtD.Catagory_ID,
                                             lbtD.Date,
                                             lbtD.Remark,
                                             Rate = (from dv in db.DataValues
                                                     join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                                                     where vs.ValueSet_Name == "Test Groups" && dv.DataValue_Name == lbtD.Catagory_ID
                                                     select dv.Segment1).FirstOrDefault(),
                                             Test_Name = db.GetDataValueName("Test Groups", lbtD.Catagory_ID),
                                             ParentTrans_ID = lbtD.Lab_Test_Detail_ID,
                                             ParentTrans_Type = "Test Group Category",
                                             lbtD.Dept_ID,
                                             lbtM.Created_Time
                                         }).ToList();

            List<BillingProcessDetails> listRecommendedTests = new List<BillingProcessDetails>();

            // Process individual tests
            foreach (var test in testDetails)
            {
                decimal finalRate = Convert.ToDecimal(test.Rate);

                // If patient has panel, get rate from Panel_Detail_Services
                if (hasPanel && panelCompanyId.HasValue && panelCompanyId.Value > 0)
                {
                    var panelRate = (from pds in db.Panel_Detail_Services
                                     where pds.Panel_ID == panelCompanyId.Value
                                           && pds.Test_ID == test.Test_ID.ToString()
                                     select pds.Rate).FirstOrDefault();

                    if (panelRate.HasValue && panelRate.Value > 0)
                    {
                        finalRate = panelRate.Value;
                    }
                }

                BillingProcessDetails RecommendedService = new BillingProcessDetails();
                RecommendedService.ParentTrans_ID = test.ParentTrans_ID;
                RecommendedService.ParentTrans_Type = "Test";
                RecommendedService.ItemID = test.Test_ID;
                RecommendedService.ItemName = test.Test_Name;
                RecommendedService.Remarks = test.Remark;
                RecommendedService.ItemType = "Test";
                RecommendedService.RecommendedByDoctor = true;
                RecommendedService.MainDepartment = test.Dept_ID;
                RecommendedService.CategoryID = "0";
                RecommendedService.Amount = finalRate;
                RecommendedService.Test_CreatedDate = Convert.ToDateTime(test.Created_Time);
                listRecommendedTests.Add(RecommendedService);
            }

            // Process group tests
            foreach (var groups in testDetailsGroupswise)
            {
                decimal finalRate = (groups.Rate == null) ? 0 : Convert.ToDecimal(groups.Rate);

                // If patient has panel, get rate from Panel_Detail_Services for group category
                if (hasPanel && panelCompanyId.HasValue && panelCompanyId.Value > 0)
                {
                    var panelRate = (from pds in db.Panel_Detail_Services
                                     where pds.Panel_ID == panelCompanyId.Value
                                           && pds.GroupCategory == groups.Catagory_ID
                                     select pds.Rate).FirstOrDefault();

                    if (panelRate.HasValue && panelRate.Value > 0)
                    {
                        finalRate = panelRate.Value;
                    }
                }

                BillingProcessDetails RecommendedService = new BillingProcessDetails();
                RecommendedService.ParentTrans_ID = groups.ParentTrans_ID;
                RecommendedService.ParentTrans_Type = "Test Group Category";
                RecommendedService.ItemID = 0;
                RecommendedService.ItemName = groups.Test_Name;
                RecommendedService.Remarks = groups.Remark;
                RecommendedService.ItemType = "Test";
                RecommendedService.RecommendedByDoctor = true;
                RecommendedService.MainDepartment = groups.Dept_ID;
                RecommendedService.CategoryID = groups.Catagory_ID;
                RecommendedService.Amount = finalRate;
                RecommendedService.Test_CreatedDate = Convert.ToDateTime(groups.Created_Time);

                listRecommendedTests.Add(RecommendedService);
            }

            return (new JavaScriptSerializer()).Serialize(listRecommendedTests);
        }
        //[WebMethod]
        //public static string FetchRecommendedInPatientDetails(int PatientID)
        //{

        //    DataBaseDataContext db = new DataBaseDataContext();

        //    var PatNo = (from p in db.Reg_patients
        //                 where p.pat_id == PatientID
        //                 select p.Patient_No
        //                  ).FirstOrDefault();

        //    var testDetails = (from lbtM in db.Laboratory_Tests
        //                       join lbtD in db.Lab_Test_Details
        //                       on lbtM.Lab_Test_ID equals lbtD.Lab_Test_ID
        //                       join opat in db.In_Patients
        //                       on lbtM.Patient_ID equals opat.In_Patient_ID
        //                       join lbTDdef in db.Lab_Tests
        //                       on lbtD.Test_ID equals lbTDdef.Test_ID
        //                       join p in db.Reg_patients
        //                       on opat.Patient_ID equals p.pat_id
        //                       where p.Patient_No == Convert.ToInt32(PatNo) && (lbtD.IsBilled == null || lbtD.IsBilled == false)
        //                        && lbtM.Transaction_Type == "InPatient" && (opat.Discharge == false || opat.Discharge == null)
        //                       select new
        //                       {
        //                           lbtM.Lab_Test_ID,
        //                           lbTDdef.Test_ID,
        //                           Category_ID = lbTDdef.Group_Category,
        //                           lbtD.Date,
        //                           lbtD.Remark,
        //                           lbTDdef.Test_Name,
        //                           DepartmentName = (db.GetDataValueName("Main Test Departments", lbTDdef.Main_Department) == null ? "" : db.GetDataValueName("Main Test Departments",lbTDdef.Main_Department)),
        //                           lbTDdef.Group_Category,
        //                           GroupName = db.GetDataValueName("Test Groups", lbTDdef.Group_Category),
        //                           ParentTrans_ID = lbtD.Lab_Test_Detail_ID,
        //                           ParentTrans_Type = "Test",
        //                           lbtD.Dept_ID,
        //                           Rate = (lbTDdef.Rate == 0) ? Convert.ToDecimal(DBClass.getField("select dbo.getTestRate('" + opat.Patient_Discount_Type + "', " + lbTDdef.Test_ID + ", " + p.pat_id + ")")) : lbTDdef.Rate,
        //                           lbtM.Created_Time



        //                       }

        //        ).ToList();

        //    // Fetching Grouped Categories....

        //    var testDetailsGroupswise = (from lbtM in db.Laboratory_Tests
        //                                 join lbtD in db.Lab_Test_Details
        //                                 on lbtM.Lab_Test_ID equals lbtD.Lab_Test_ID
        //                                 join opat in db.In_Patients
        //                                 on lbtM.Patient_ID equals opat.In_Patient_ID
        //                                 join p in db.Reg_patients
        //                                  on opat.Patient_ID equals p.pat_id
        //                                 where opat.Patient_ID == p.pat_id && lbtD.Test_ID == 0 && p.Patient_No == Convert.ToInt32(PatNo) && (lbtD.IsBilled == null || lbtD.IsBilled == false) && lbtM.Transaction_Type == "InPatient"
        //                                 && (opat.Discharge == false || opat.Discharge == null)
        //                                 select new
        //                                 {
        //                                     lbtD.Lab_Test_ID,
        //                                     lbtD.Test_ID,
        //                                     lbtD.Catagory_ID,
        //                                     lbtD.Date,
        //                                     lbtD.Remark,
        //                                     Rate = (from dv in db.DataValues
        //                                             join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
        //                                             where vs.ValueSet_Name == "Test Groups" && dv.DataValue_Name == lbtD.Catagory_ID
        //                                             select dv.Segment1).FirstOrDefault(),

        //                                     Test_Name = db.GetDataValueName("Test Groups", lbtD.Catagory_ID),
        //                                     ParentTrans_ID = lbtD.Lab_Test_Detail_ID,
        //                                     ParentTrans_Type = "Test Group Category",
        //                                     lbtD.Dept_ID,
        //                                     lbtM.Created_Time
        //                                 }
        //        ).ToList();

        //    List<BillingProcessDetails> listRecommendedTests = new List<BillingProcessDetails>();

        //    foreach (var test in testDetails)
        //    {
        //        BillingProcessDetails RecommendedService = new BillingProcessDetails();
        //        RecommendedService.ParentTrans_ID = test.ParentTrans_ID;
        //        RecommendedService.ParentTrans_Type = "Test";
        //        RecommendedService.ItemID = test.Test_ID;
        //        RecommendedService.ItemName = test.Test_Name;
        //        RecommendedService.Remarks = test.Remark;
        //        RecommendedService.ItemType = "Test";
        //        RecommendedService.RecommendedByDoctor = true;
        //        RecommendedService.MainDepartment = test.Dept_ID;
        //        RecommendedService.CategoryID = "0";
        //        RecommendedService.Amount = (test.Rate == null) ? 0 : (decimal)test.Rate;
        //        RecommendedService.Test_CreatedDate = Convert.ToDateTime(test.Created_Time);
        //        listRecommendedTests.Add(RecommendedService);
        //    }

        //    if (testDetailsGroupswise.Count > 0)
        //    {
        //        foreach (var group in testDetailsGroupswise)
        //        {
        //            BillingProcessDetails RecommendedService = new BillingProcessDetails();
        //            RecommendedService.ParentTrans_ID = group.ParentTrans_ID;
        //            RecommendedService.ParentTrans_Type = "Test Group Category";
        //            RecommendedService.ItemID = group.Test_ID;
        //            RecommendedService.ItemName = group.Test_Name;
        //            RecommendedService.Remarks = group.Remark;
        //            RecommendedService.ItemType = "Test";
        //            RecommendedService.RecommendedByDoctor = true;
        //            RecommendedService.MainDepartment = group.Dept_ID;
        //            RecommendedService.CategoryID = group.Catagory_ID;
        //            RecommendedService.Amount = (group.Rate == null) ? 0 : Convert.ToDecimal(group.Rate);
        //            RecommendedService.Test_CreatedDate = Convert.ToDateTime(group.Created_Time);

        //            listRecommendedTests.Add(RecommendedService);
        //        }
        //    }
        //    return (new JavaScriptSerializer()).Serialize(listRecommendedTests);
        //}




        [WebMethod]
        public static string FetchRecommendedEmergencyDetails(int PatientID)
        {

            DataBaseDataContext db = new DataBaseDataContext();

            var PatNo = (from p in db.Reg_patients
                         where p.pat_id == PatientID
                         select p.Patient_No
                          ).FirstOrDefault();

            var testDetails = (from lbtM in db.Laboratory_Tests
                               join lbtD in db.Lab_Test_Details
                               on lbtM.Lab_Test_ID equals lbtD.Lab_Test_ID
                               join opat in db.Emergency_Patients
                               on lbtM.Patient_ID equals opat.Patient_ID
                               join lbTDdef in db.Lab_Tests
                               on lbtD.Test_ID equals lbTDdef.Test_ID
                               join p in db.Reg_patients
                               on opat.Patient_ID equals p.pat_id
                               where p.Patient_No == Convert.ToInt32(PatNo) && (lbtD.IsBilled == null || lbtD.IsBilled == false)
                                && lbtM.Transaction_Type == "Emergency Patient"
                                && (lbtD.is_Closed == false || lbtD.is_Closed == null)
                               select new
                               {
                                   lbtM.Lab_Test_ID,
                                   lbTDdef.Test_ID,
                                   Category_ID = lbTDdef.Group_Category,
                                   lbtD.Date,
                                   lbtD.Remark,
                                   lbTDdef.Test_Name,

                                   DepartmentName = (db.GetDataValueName("Main Test Departments", lbTDdef.Main_Department) == null ? "" : db.GetDataValueName("Main Test Departments",
            lbTDdef.Main_Department)),
                                   lbTDdef.Group_Category,
                                   GroupName = db.GetDataValueName("Test Groups", lbTDdef.Group_Category),
                                   ParentTrans_ID = lbtD.Lab_Test_Detail_ID,
                                   ParentTrans_Type = "Test",
                                   lbtD.Dept_ID,
                                   Rate = (lbTDdef.Rate == 0) ? Convert.ToDecimal(DBClass.getField("select dbo.getTestRate('" + opat.Patient_Discount_Type + "', " + lbTDdef.Test_ID + ", " + p.pat_id + ")")) : lbTDdef.Rate,
                                   lbtM.Created_Time



                               }

                ).ToList();

            // Fetching Grouped Categories....

            var testDetailsGroupswise = (from lbtM in db.Laboratory_Tests
                                         join lbtD in db.Lab_Test_Details
                                         on lbtM.Lab_Test_ID equals lbtD.Lab_Test_ID
                                         join opat in db.Emergency_Patients
                                         on lbtM.Patient_ID equals opat.Emergency_ID
                                         join p in db.Reg_patients
                                          on opat.Patient_ID equals p.pat_id
                                         where opat.Patient_ID == p.pat_id && lbtD.Test_ID == 0 && p.Patient_No == Convert.ToInt32(PatNo) && (lbtD.IsBilled == null || lbtD.IsBilled == false) && lbtM.Transaction_Type == "Emergency Patient"
                                         && (lbtD.is_Closed == false || lbtD.is_Closed == null)
                                         select new
                                         {
                                             lbtD.Lab_Test_ID,
                                             lbtD.Test_ID,
                                             lbtD.Catagory_ID,
                                             lbtD.Date,
                                             lbtD.Remark,
                                             Rate = (from dv in db.DataValues
                                                     join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                                                     where vs.ValueSet_Name == "Test Groups" && dv.DataValue_Name == lbtD.Catagory_ID
                                                     select dv.Segment1).FirstOrDefault(),

                                             Test_Name = db.GetDataValueName("Test Groups", lbtD.Catagory_ID),
                                             ParentTrans_ID = lbtD.Lab_Test_Detail_ID,
                                             ParentTrans_Type = "Test Group Category",
                                             lbtD.Dept_ID,
                                             lbtM.Created_Time
                                         }
                ).ToList();

            List<BillingProcessDetails> listRecommendedTests = new List<BillingProcessDetails>();

            foreach (var test in testDetails)
            {
                BillingProcessDetails RecommendedService = new BillingProcessDetails();
                RecommendedService.ParentTrans_ID = test.ParentTrans_ID;
                RecommendedService.ParentTrans_Type = "Test";
                RecommendedService.ItemID = test.Test_ID;
                RecommendedService.ItemName = test.Test_Name;
                RecommendedService.Remarks = test.Remark;
                RecommendedService.ItemType = "Test";
                RecommendedService.RecommendedByDoctor = true;
                RecommendedService.MainDepartment = test.Dept_ID;
                RecommendedService.CategoryID = "0";
                RecommendedService.Amount = (test.Rate == null) ? 0 : (decimal)test.Rate;
                RecommendedService.Test_CreatedDate = Convert.ToDateTime(test.Created_Time);
                listRecommendedTests.Add(RecommendedService);
            }

            if (testDetailsGroupswise.Count > 0)
            {
                foreach (var group in testDetailsGroupswise)
                {
                    BillingProcessDetails RecommendedService = new BillingProcessDetails();
                    RecommendedService.ParentTrans_ID = group.ParentTrans_ID;
                    RecommendedService.ParentTrans_Type = "Test Group Category";
                    RecommendedService.ItemID = group.Test_ID;
                    RecommendedService.ItemName = group.Test_Name;
                    RecommendedService.Remarks = group.Remark;
                    RecommendedService.ItemType = "Test";
                    RecommendedService.RecommendedByDoctor = true;
                    RecommendedService.MainDepartment = group.Dept_ID;
                    RecommendedService.CategoryID = group.Catagory_ID;
                    RecommendedService.Amount = (group.Rate == null) ? 0 : Convert.ToDecimal(group.Rate);
                    RecommendedService.Test_CreatedDate = Convert.ToDateTime(group.Created_Time);


                    listRecommendedTests.Add(RecommendedService);
                }
            }
            return (new JavaScriptSerializer()).Serialize(listRecommendedTests);
        }
        public class BillingProcessDetails
        {
            public int ParentTrans_ID { get; set; }
            public string ParentTrans_Name { get; set; }
            public string ParentTrans_Type { get; set; }
            public DateTime Test_CreatedDate { get; set; }
            public int ItemID { get; set; }
            public string CategoryID { get; set; }
            public string ItemName { get; set; }
            public string ItemType { get; set; }
            public bool RecommendedByDoctor { get; set; }
            public bool ExcludedFromPayment { get; set; }
            public bool SelectedForApproval { get; set; }
            public decimal Amount { get; set; }
            public decimal DisPer { get; set; }
            public decimal DisAmt { get; set; }
            public decimal Net_Amount { get; set; }
            public int Qty { get; set; }
            public string Remarks { get; set; }
            public decimal DocShare { get; set; }
            public decimal HosShare { get; set; }
            public string Doctor_Id { get; set; }
            public string MainDepartment { get; set; }
            public decimal Consumed_Lab { get; set; }
            public decimal Consumed_Ultra_Sound { get; set; }
            public decimal Consumed_Xray { get; set; }
            public decimal Consumed_Scan { get; set; }
            public decimal Consumed_Blood { get; set; }
            public decimal Consumed_Item { get; set; }
            public decimal Consumed_Procedure { get; set; }
            public decimal Consumed_Package { get; set; }
        }
        public class DoctorDistributionList
        {
            public int Doc_ID { get; set; }
            public string Share_type { get; set; }
            public decimal Doc_Amount { get; set; }
        }
        [WebMethod]
        public static string GetMartailStatus()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Marital Status"
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
        public static string GetUserAccount()
        {
            string data = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
              
                    var result = (from gl in db.aspnet_Users
                                  where gl.UserId == AppConfig.UserID
                                  select new
                                  {
                                      gl.cashier,
                                      Cashier_text = db.GetDataValueName("Casher", gl.cashier),
                                  }).ToList();
                    data = new JavaScriptSerializer().Serialize(result);
                
            }
            return data;
        }
        [WebMethod]
        public static string GetPanel()
        {
            string data = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
              
                    var result = (from gl in db.Panels
                                
                                  select new
                                  {
                                      gl.Panel_ID,
                                      gl.Company_Name,
                                  }).ToList();
                    data = new JavaScriptSerializer().Serialize(result);
                
            }
            return data;
        }
        [WebMethod]
        public static string GetCasher()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Casher"
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
        public static string GetGender()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Gender"
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
        public static string FillOtherTest()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var INV_Items = from itm in db.Lab_Tests

                            where itm.Main_Department == "007"
                            select new
                            {
                                itm.Main_Department,
                                itm.Test_ID,
                                itm.Test_Name,
                                Main_Department_Name = (db.GetDataValueName("Main Test Departments", itm.Main_Department))
                            };
            return (new JavaScriptSerializer().Serialize(INV_Items));
        }
        [WebMethod]
        public static string FillTestMainDepartment()
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var dpt = (from d in db.DataValues
                       join v in db.ValueSets
                       on d.ValueSet_ID equals v.ValueSet_ID
                       where v.ValueSet_Name == "Main Test Departments"
                       select new
                       {
                           d.DataValue_Name,
                           d.DataValue_Description
                       }).ToList();

            return (new JavaScriptSerializer().Serialize(dpt));
        }

        [WebMethod]
        public static string SaveBillRecord(string Parameters)
        {


            return SaveBill(Parameters);
        }

        [WebMethod]
        public static string GetDoctorCompulsoryItemIds()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var ids = (from i in db.INV_Items
                           where i.Doctor_Compulsory == true
                           select i.Item_ID).ToList();
                return new JavaScriptSerializer().Serialize(ids);
            }
        }

        public static string SaveBill(string Parameters)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            JavaScriptSerializer JSS = new JavaScriptSerializer();
            var data = JSS.Deserialize<Billings>(Parameters);

            if (data.Details == null || data.Details.Count == 0)
            {
                return JSS.Serialize(new
                {
                    success = false,
                    message = "Bill has no service details. Please add services and try again."
                });
            }

            // >>>>>>>>>>>>>>>>>> DETERMINE APPOINTMENT TYPE <<<<<<<<<<<<<<<<<<<<
            string appointmentType = null;

            if (data.Appointment_ID.HasValue && data.Appointment_ID.Value > 0)
            {
                var opdApt = db.Appointment_Forms.FirstOrDefault(a => a.Appointment_ID == data.Appointment_ID.Value);
                if (opdApt != null)
                {
                    appointmentType = "OPD";

                    if (data.hdn_docid == null || data.hdn_docid == 0)
                    {
                        data.hdn_docid = Convert.ToInt32(opdApt.Consultant_ID);
                    }
                }
                else
                {
                    var dermApt = db.Derma_Appointments.FirstOrDefault(a => a.Derma_Appointment_Id == data.Appointment_ID.Value);
                    if (dermApt != null)
                    {
                        appointmentType = "Derma";
                        if (data.hdn_docid == null || data.hdn_docid == 0 && !string.IsNullOrEmpty(dermApt.Doctor_Id))
                        {
                            if (int.TryParse(dermApt.Doctor_Id, out int dermaDocId))
                            {
                                data.hdn_docid = dermaDocId;
                            }
                        }
                    }
                }
            }
            // >>>>>>>>>>>>>>>>>> END APPOINTMENT TYPE LOGIC <<<<<<<<<<<<<<<<<<<<

            Ar_Billing newBill;

            if (data.Bill_ID == 0)
            {
                newBill = new Ar_Billing();
                newBill.Created_By = AppConfig.UserID;
                newBill.Creation_Date = DateTime.Now;
                newBill.Bill_No = DBClass.GetNewNumber("Bill_No", "Ar_Billings", "").ToString();
            }
            else
            {
                newBill = db.Ar_Billings
                    .Where(b => b.Bill_ID == data.Bill_ID)
                    .FirstOrDefault();

                if (newBill == null)
                    throw new Exception("Bill not found for update.");


                var existingDetails = db.Ar_Billing_Details
                    .Where(d => d.Bill_ID == data.Bill_ID)
                    .ToList();

                var previousBillData = new
                {
                    Bill = new
                    {
                        newBill.Bill_No,
                        newBill.Patient_ID,
                        Bill_Date = newBill.Bill_Date ?? DateTime.MinValue,
                        newBill.Cash_In_Hand,
                        newBill.Bank_Account,
                        newBill.Discount_Amount,
                        newBill.Total_Amount,
                        newBill.Net_Amount,
                        newBill.Received_Amount,
                        newBill.Balance_Amount,
                        newBill.Main_Department,
                        newBill.BillType,
                        newBill.In_Patient_ID,
                        newBill.Referred_By_Name,
                    },
                    Details = new
                    {
                        Billing_Details = existingDetails.Select(d => new
                        {
                            d.Bill_Details_ID,
                            d.Bill_ID,
                            d.Item_ID,
                            d.Item_Name,
                            d.Amount,
                            d.Net_Amount,
                            d.Discount_Amount,
                            d.Qty,
                            d.Item_Type,
                            d.Doctor_id,
                            d.Doctor_Share,
                            d.Hospital_Share
                        }).ToList()
                    }
                };

                string masterLogJson = JSS.Serialize(previousBillData.Bill);
                string detailsLogJson = JSS.Serialize(previousBillData.Details);

                Ar_Billing_Log billLog = new Ar_Billing_Log
                {
                    Bill_Id = newBill.Bill_ID,
                    Master_Log = masterLogJson,
                    Details_Log = detailsLogJson,
                    Log_Time = DateTime.Now,
                    Loged_By = AppConfig.UserID
                };

                db.Ar_Billing_Logs.InsertOnSubmit(billLog);

                newBill.Updated_By = AppConfig.UserID;
                newBill.Updation_Date = DateTime.Now;
            }

            newBill.Company_ID = AppConfig.Company_ID;
            newBill.Patient_ID = data.Patient_ID;
            newBill.Opd_Id = data.Opd_id;
            newBill.Bill_Date = DateTime.Now;
            newBill.Remarks = data.Remarks;
            newBill.Referred_By_Name = data.Referred_Doctor_Name;
            var opd_proc = data.opd_procedure;

            newBill.Appointment_id = data.Appointment_ID;
            newBill.Appointment_type = appointmentType;



            newBill.Discount_Percentage = data.Discount_Percentage;
            newBill.Discount_Amount = data.Discount_Amount;
            newBill.Total_Amount = data.TotalPayable;
            newBill.Net_Amount = data.Net_Amount;
            newBill.final_bill_ipd = data.finalbill || (newBill.final_bill_ipd ?? false);
            newBill.Received_Amount = data.Received_Amount;
            newBill.Balance_Amount = data.Balance_Amount;
            newBill.Charge_Policy = data.ChargePolicy;
            newBill.Referred_By = data.referred_by_doctor;
            newBill.Previous_Paid = data.Previous_Paid;
            newBill.Previous_Balance = data.Previous_Balance;
            newBill.Over_and_Above = data.Over_and_Above;
            newBill.Cash_In_Hand = data.Cash_In_Hand;
            newBill.Cash_In_Hand_Account = data.Cash_In_Hand_Account;
            newBill.Bank_Account = data.Bank_Account;
            newBill.Bank_Cash = data.Bank_Cash;
            newBill.Main_Department = data.Main_Department;
            newBill.Bill_Department = data.BillDepartment;
            newBill.Bill_Category = data.BillCategory;
            newBill.Cost_Center = data.CostCenter;
            newBill.CGS_Procedure_BOM = Convert.ToDecimal(data.bomTotalValue);
            newBill.Sales_Tax_ID = data.Sales_Tax_ID;
            newBill.Sales_Tax_Percentage = data.Sales_Tax_Percentage;
            newBill.Panel_Id = Convert.ToInt32(data.Panel_Id);
            newBill.Patient_Type = data.Patient_Type;

            if (data.finalbill == true)
            {
                newBill.IPD_BillNo = DBClass.GetNewNumber("IPD_BillNo", "Ar_Billings", "").ToString();
            }
            int? userBranchId = null;
            var branchValue = (from bwd in db.Branch_Wise_User_Details
                               where bwd.User_Id == AppConfig.UserID
                               select bwd.Brancg).FirstOrDefault();

            if (!string.IsNullOrEmpty(branchValue) && int.TryParse(branchValue, out int bid))
            {
                userBranchId = bid;
            }

            newBill.Branch_Id = userBranchId;

            var patient_no = DBClass.getField("select Patient_No from Reg_patient where pat_id=" + data.Patient_ID);
            var ipdid = DBClass.getField("select In_Patient_ID from In_Patient where Patient_ID=" + data.Patient_ID + " order by Created_Time desc");

            if (data.hdn_docid != 0)
            {
                newBill.Doctor_ID = data.hdn_docid;

                DateTime today = DateTime.Today;
                int maxToken = db.Ar_Billings
                    .Where(b =>
                        b.Doctor_ID == data.hdn_docid &&
                        b.Creation_Date.HasValue &&
                        b.Creation_Date.Value.Year == today.Year &&
                        b.Creation_Date.Value.Month == today.Month &&
                        b.Creation_Date.Value.Day == today.Day)
                    .Max(b => (int?)b.Doc_token) ?? 0;

                newBill.Doc_token = maxToken + 1;
            }
            else
            {
                newBill.Doc_token = null;
            }


            if (ipdid != "There is no row at position 0.")
            {
                newBill.In_Patient_ID = Convert.ToInt32(ipdid);
                var Ipd = (from ipd in db.In_Patients
                           where ipd.In_Patient_ID == Convert.ToInt32(ipdid)
                           orderby ipd.Created_Time descending
                           select ipd
                                ).FirstOrDefault();

                if (Ipd.Discharge_Request == true)
                {
                    newBill.Package_Type = data.PackageType;
                    newBill.Package_Name = data.PackageName;
                    if (data.PackageType == "01")
                    {
                        var shareType = (from Dp in db.DoctorPackages
                                         where Dp.Doc_Packages_ID == Convert.ToInt32(data.PackageName)
                                         select Dp.Share_type).FirstOrDefault();
                        newBill.Share_Type = shareType;
                    }
                    else if (data.PackageType == "02")
                    {
                        var shareType = (from Dp in db.DepartmentPackages
                                         where Dp.Dep_Packages_ID == Convert.ToInt32(data.PackageName)
                                         select Dp.Share_type).FirstOrDefault();
                        newBill.Share_Type = shareType;
                    }
                    else if (data.PackageType == "03")
                    {
                        var shareType = (from Dp in db.PanelPackages
                                         where Dp.Pan_Packages_ID == Convert.ToInt32(data.PackageName)
                                         select Dp.Share_type).FirstOrDefault();
                        newBill.Share_Type = shareType;
                    }
                    else
                    {
                        newBill.Share_Type = null;
                    }
                    Ipd.Final_Bill = true;
                }

            }
            else
            {
                newBill.In_Patient_ID = 0;
            }

            if (data.bomItems != null && data.bomItems.Count > 0)
            {
                foreach (var item in data.bomItems)
                {
                    if (item.ItemID <= 0 || item.Qty == null) continue;

                    decimal availableStock = db.GetInventoryItemTotalStock_BaseUnit(item.ItemID, "002") ?? 0;

                    if (item.Qty > availableStock)
                    {
                        return (new JavaScriptSerializer()).Serialize(new
                        {
                            success = false,
                            message = $"Stock not available for {item.ItemCode}"
                        });
                    }
                }
            }

            if (data.Bill_ID == 0)
            {
                db.Ar_Billings.InsertOnSubmit(newBill);
                db.SubmitChanges();
                if (opd_proc == "1")
                {
                    DBClass.executeNonQueryWithoutBegin("Update patients SET Is_billed ='1' WHERE patient_id=" + data.Opd_id);
                }
            }

            if (data.bomItems != null && data.bomItems.Count > 0)
            {
                var bomConsumptions = data.bomItems.Select(i => new Bill_BOM_Consumption
                {
                    Bill_ID = newBill.Bill_ID,
                    BOMDetailID = i.BOMDetailID,
                    ItemID = i.ItemID,
                    ItemCode = i.ItemCode,
                    Description = i.Description,
                    Qty = i.Qty,
                    Unit = i.Unit,
                    RecipeCostPerUnit = i.RecipeCostPerUnit,
                    AvgCostPerUnit = i.CurrentAvgCost,
                    TotalCost = i.RuntimeCost,
                    BaseUnitQty = i.BaseUnitQty,
                    CreatedBy = AppConfig.UserID
                }).ToList();

                db.Bill_BOM_Consumptions.InsertAllOnSubmit(bomConsumptions);
                db.SubmitChanges();
            }

            List<Ar_Billing_Detail> ListOfDetails = new List<Ar_Billing_Detail>();
            List<Ar_Billing_Detail> ListOfDetails_Previous = db.Ar_Billing_Details.Where(b => b.Bill_ID == data.Bill_ID).ToList();

            decimal sum = 0, sum_ultra = 0, sum_Xray = 0, sum_CTscan = 0, sum_Blood = 0, sum_Item = 0, sum_Procedure = 0, sum_Package = 0;

            foreach (BillingProcessDetails dtls in data.Details)
            {
                if (dtls.Test_CreatedDate == DateTime.MinValue)
                    dtls.Test_CreatedDate = DateTime.Now;

                Ar_Billing_Detail newBillDetails = new Ar_Billing_Detail
                {
                    Bill_ID = newBill.Bill_ID,
                    ParentTrans_ID = dtls.ParentTrans_ID,
                    ParentTrans_Name = dtls.ParentTrans_Name,
                    ParentTrans_Type = dtls.ParentTrans_Type,
                    Item_ID = dtls.ItemID,
                    Item_Name = dtls.ItemName,
                    Item_Type = dtls.ItemType,
                    RecommendedByDoctor = dtls.RecommendedByDoctor,
                    Amount = dtls.Amount,
                    Discount_Percentage = dtls.DisPer,
                    Discount_Amount = dtls.DisAmt,
                    Net_Amount = dtls.Net_Amount,
                    Qty = dtls.Qty,
                    Remarks = dtls.Remarks,
                    Doctor_Share = dtls.DocShare,
                    Hospital_Share = dtls.HosShare,
                    Doctor_id = dtls.Doctor_Id,
                    Category_ID = dtls.CategoryID,
                    Test_Main_Department = dtls.MainDepartment,
                    Service_Date = DateTime.Now,
                    Issue_Date = dtls.Test_CreatedDate,
                    Is_Approval = dtls.SelectedForApproval
                };

                if (dtls.MainDepartment == "001") sum = Convert.ToDecimal(dtls.Consumed_Lab);
                else if (dtls.MainDepartment == "002") sum_ultra = Convert.ToDecimal(dtls.Consumed_Ultra_Sound);
                else if (dtls.MainDepartment == "003") sum_Xray = Convert.ToDecimal(dtls.Consumed_Xray);
                else if (dtls.MainDepartment == "004") sum_CTscan = Convert.ToDecimal(dtls.Consumed_Scan);
                else if (dtls.MainDepartment == "005") sum_Blood = Convert.ToDecimal(dtls.Consumed_Blood);
                else if (dtls.Consumed_Procedure != 0) sum_Procedure = Convert.ToDecimal(dtls.Consumed_Procedure);
                else if (dtls.ItemType == "Item" || dtls.ItemType == "Service")
                {
                    if (dtls.ParentTrans_Type == "Package")
                        sum_Package = Convert.ToDecimal(dtls.Consumed_Package);
                    else
                        sum_Item = Convert.ToDecimal(dtls.Consumed_Item);
                }

                bool isGroupCategory = (dtls.ItemType == "Test" && dtls.ItemID == 0 && !string.IsNullOrWhiteSpace(dtls.CategoryID?.ToString()));
                newBillDetails.Is_Group_Category = isGroupCategory;

                ListOfDetails.Add(newBillDetails);
            }

            List<AR_Billing_Detail_Doctor_Share> ListOfshare = new List<AR_Billing_Detail_Doctor_Share>();
            foreach (DoctorDistributionList doc in data.Share)
            {
                ListOfshare.Add(new AR_Billing_Detail_Doctor_Share
                {
                    Bill_ID = newBill.Bill_ID,
                    Emp_ID = doc.Doc_ID,
                    Share_type = doc.Share_type,
                    Amount = doc.Doc_Amount
                });
            }

            if (data.Bill_ID != 0)
            {
                var itemsToUpdate = new List<Ar_Billing_Detail>();
                var itemsToInsert = new List<Ar_Billing_Detail>();
                var itemsToDelete = new List<Ar_Billing_Detail>();

                foreach (var newItem in ListOfDetails)
                {
                    var existing = ListOfDetails_Previous.FirstOrDefault(p =>
                        p.Item_ID == newItem.Item_ID &&
                        p.ParentTrans_ID == newItem.ParentTrans_ID);

                    if (existing != null)
                    {
                        existing.Amount = newItem.Amount;
                        existing.Discount_Percentage = newItem.Discount_Percentage;
                        existing.Discount_Amount = newItem.Discount_Amount;
                        existing.Net_Amount = newItem.Net_Amount;
                        existing.Qty = newItem.Qty;
                        existing.Remarks = newItem.Remarks;
                        existing.Doctor_Share = newItem.Doctor_Share;
                        existing.Hospital_Share = newItem.Hospital_Share;
                        existing.Doctor_id = newItem.Doctor_id;
                        existing.Category_ID = newItem.Category_ID;
                        existing.Test_Main_Department = newItem.Test_Main_Department;
                        existing.Service_Date = newItem.Service_Date;
                        existing.Issue_Date = newItem.Issue_Date;
                        existing.ParentTrans_Name = newItem.ParentTrans_Name;
                        existing.ParentTrans_Type = newItem.ParentTrans_Type;
                        existing.Item_Name = newItem.Item_Name;
                        existing.Item_Type = newItem.Item_Type;
                        existing.RecommendedByDoctor = newItem.RecommendedByDoctor;
                        existing.Is_Group_Category = newItem.Is_Group_Category;
                        existing.Is_Approval = newItem.Is_Approval;

                        itemsToUpdate.Add(existing);
                    }
                    else
                    {
                        newItem.Bill_ID = newBill.Bill_ID;
                        itemsToInsert.Add(newItem);
                    }
                }

                foreach (var oldItem in ListOfDetails_Previous)
                {
                    var stillExists = ListOfDetails.Any(n =>
                        n.Item_ID == oldItem.Item_ID &&
                        n.ParentTrans_ID == oldItem.ParentTrans_ID);

                    if (!stillExists)
                    {
                        itemsToDelete.Add(oldItem);

                        if (oldItem.Item_Type == "Test")
                        {
                            MarkTestAsExcludedFromPayment((int)oldItem.ParentTrans_ID);
                            MarkTestAsUnBilled((int)oldItem.ParentTrans_ID);
                        }
                    }
                }

                if (itemsToDelete.Any())
                    db.Ar_Billing_Details.DeleteAllOnSubmit(itemsToDelete);

                if (itemsToInsert.Any())
                    db.Ar_Billing_Details.InsertAllOnSubmit(itemsToInsert);

                var newGroups = (from t in itemsToInsert
                                 where t.Item_Type == "Test"
                                       && t.RecommendedByDoctor == false
                                       && t.ParentTrans_Type == "Test Group Category"
                                       && t.ParentTrans_ID == 0
                                 select t).ToList();

                var distinctCategories = newGroups.Select(t => t.Category_ID).Distinct().ToList();
                foreach (var catId in distinctCategories)
                {
                    var categoryTests = newGroups.Where(c => c.Category_ID == catId).ToList();
                    Laboratory_Test grpHeader = new Laboratory_Test
                    {
                        Patient_ID = newBill.Bill_ID,
                        Transaction_Type = "Front Desk",
                        Created_Time = DateTime.Now
                    };
                    db.Laboratory_Tests.InsertOnSubmit(grpHeader);
                    db.SubmitChanges();

                    Lab_Test_Detail grpdtl = new Lab_Test_Detail
                    {
                        Lab_Test_ID = grpHeader.Lab_Test_ID,
                        Patient_ID = newBill.Bill_ID,
                        Date = newBill.Creation_Date,
                        Test_ID = 0,
                        IsBilled = true,
                        Catagory_ID = catId,
                        Actual_Patient_ID = newBill.Patient_ID
                    };
                    db.Lab_Test_Details.InsertOnSubmit(grpdtl);
                    db.SubmitChanges();

                    grpHeader.Parent_Transaction_Type = "Front Desk";
                    grpHeader.Parent_Transaction_Type_ID = grpdtl.Lab_Test_Detail_ID;
                    db.SubmitChanges();

                    foreach (var test in categoryTests)
                    {
                        var detail = itemsToInsert.FirstOrDefault(d =>
                            d.Category_ID == catId &&
                            d.Item_Type == "Test" &&
                            d.RecommendedByDoctor == false &&
                            d.ParentTrans_Type == "Test Group Category");
                        if (detail != null)
                            detail.ParentTrans_ID = grpdtl.Lab_Test_Detail_ID;
                    }
                }

                var NewTests = (from t in itemsToInsert
                                where t.Item_Type == "Test"
                                      && t.RecommendedByDoctor == false
                                      && t.ParentTrans_Type != "Test Group Category"
                                      && t.ParentTrans_ID == 0
                                select t).ToList();

                if (NewTests.Any())
                {
                    Laboratory_Test lt = new Laboratory_Test
                    {
                        Patient_ID = newBill.Bill_ID,
                        Transaction_Type = "Front Desk",
                        Created_Time = DateTime.Now
                    };
                    db.Laboratory_Tests.InsertOnSubmit(lt);
                    db.SubmitChanges();

                    foreach (var test in NewTests)
                    {
                        Lab_Test_Detail ltd = new Lab_Test_Detail
                        {
                            Lab_Test_ID = lt.Lab_Test_ID,
                            Patient_ID = newBill.Bill_ID,
                            Date = newBill.Creation_Date,
                            Test_ID = (int)test.Item_ID,
                            Actual_Patient_ID = newBill.Patient_ID,
                            IsBilled = true
                        };
                        db.Lab_Test_Details.InsertOnSubmit(ltd);
                        db.SubmitChanges();

                        var detail = itemsToInsert.FirstOrDefault(d =>
                            d.Item_ID == test.Item_ID &&
                            d.Item_Type == "Test" &&
                            d.RecommendedByDoctor == false &&
                            d.ParentTrans_Type != "Test Group Category" &&
                            d.ParentTrans_ID == 0);
                        if (detail != null)
                            detail.ParentTrans_ID = ltd.Lab_Test_Detail_ID;
                    }
                }
            }
            // >>>>>>>>>>>>>>>>>> INSERT LOGIC (New Bill) <<<<<<<<<<<<<<<<<<<<
            else
            {
                foreach (var item in ListOfDetails.Where(t => t.Item_Type == "Test"))
                {
                    MarkTestAsBilled((int)item.ParentTrans_ID);
                }

                var opdGroups = (from t in ListOfDetails
                                 where t.Item_Type == "Test"
                                       && t.RecommendedByDoctor == true
                                       && t.ParentTrans_Type == "Test Group Category"
                                 select t).ToList();

                var opdCategories = opdGroups.Select(t => t.Category_ID).Distinct().ToList();
                foreach (var catId in opdCategories)
                {
                    var categoryTests = opdGroups.Where(c => c.Category_ID == catId).ToList();
                    MarkTestAsBilled((int)categoryTests.First().ParentTrans_ID);

                    Laboratory_Test lt = new Laboratory_Test
                    {
                        Patient_ID = newBill.Bill_ID,
                        Transaction_Type = "OutPatient",
                        Parent_Transaction_Type = "OutPatient",
                        Parent_Transaction_Type_ID = categoryTests.First().ParentTrans_ID,
                        Created_Time = DateTime.Now
                    };
                    db.Laboratory_Tests.InsertOnSubmit(lt);
                    db.SubmitChanges();

                    foreach (var test in categoryTests)
                    {
                        Lab_Test_Detail ltd = new Lab_Test_Detail
                        {
                            Lab_Test_ID = lt.Lab_Test_ID,
                            Patient_ID = newBill.Bill_ID,
                            Date = newBill.Creation_Date,
                            Test_ID = (int)test.Item_ID,
                            Actual_Patient_ID = newBill.Patient_ID,
                            Catagory_ID = test.Category_ID
                        };
                        db.Lab_Test_Details.InsertOnSubmit(ltd);
                        db.SubmitChanges();

                        var detail = ListOfDetails.FirstOrDefault(d =>
                            d.Item_ID == test.Item_ID &&
                            d.Item_Type == "Test" &&
                            d.RecommendedByDoctor == true &&
                            d.ParentTrans_Type == "Test Group Category");
                        if (detail != null)
                            detail.ParentTrans_ID = ltd.Lab_Test_Detail_ID;
                    }
                }

                var fdGroups = (from t in ListOfDetails
                                where t.Item_Type == "Test"
                                      && t.RecommendedByDoctor == false
                                      && t.ParentTrans_Type == "Test Group Category"
                                select t).ToList();

                foreach (var test in fdGroups)
                {
                    Laboratory_Test grpHeader = new Laboratory_Test
                    {
                        Patient_ID = newBill.Bill_ID,
                        Transaction_Type = "Front Desk",
                        Created_Time = DateTime.Now
                    };
                    db.Laboratory_Tests.InsertOnSubmit(grpHeader);
                    db.SubmitChanges();

                    Lab_Test_Detail grpdtl = new Lab_Test_Detail
                    {
                        Lab_Test_ID = grpHeader.Lab_Test_ID,
                        Patient_ID = newBill.Bill_ID,
                        Date = newBill.Creation_Date,
                        Test_ID = 0,
                        IsBilled = true,
                        Catagory_ID = test.Category_ID,
                        Actual_Patient_ID = newBill.Patient_ID
                    };
                    db.Lab_Test_Details.InsertOnSubmit(grpdtl);
                    db.SubmitChanges();

                    grpHeader.Parent_Transaction_Type = "Front Desk";
                    grpHeader.Parent_Transaction_Type_ID = grpdtl.Lab_Test_Detail_ID;
                    db.SubmitChanges();

                    var detail = ListOfDetails.FirstOrDefault(d =>
                        d.Category_ID == test.Category_ID &&
                        d.Item_Type == "Test" &&
                        d.RecommendedByDoctor == false &&
                        d.ParentTrans_Type == "Test Group Category");
                    if (detail != null)
                        detail.ParentTrans_ID = grpdtl.Lab_Test_Detail_ID;
                }

                foreach (var item in ListOfDetails.Where(t => t.Item_Type == "Test"))
                {
                    MarkTestAsBilled((int)item.ParentTrans_ID);
                }

                var NewTests = (from t in ListOfDetails
                                where t.Item_Type == "Test"
                                      && t.RecommendedByDoctor == false
                                      && t.ParentTrans_Type != "Test Group Category"
                                select t).ToList();

                var NewServices = (from t in ListOfDetails where t.Item_Type == "Service" select t).ToList();

                foreach (var serv in NewServices)
                {
                    var ipdservices = db.InPatientServices
                        .Where(b => b.PatientId == data.Patient_ID && b.Service_ItemId == serv.Item_ID.ToString())
                        .FirstOrDefault();
                    if (ipdservices != null)
                    {
                        ipdservices.isbilled = true;
                    }
                }

                if (NewTests.Any())
                {
                    Laboratory_Test lt = new Laboratory_Test
                    {
                        Patient_ID = newBill.Bill_ID,
                        Transaction_Type = "Front Desk",
                        Created_Time = DateTime.Now
                    };
                    db.Laboratory_Tests.InsertOnSubmit(lt);
                    db.SubmitChanges();

                    foreach (var test in NewTests)
                    {
                        Lab_Test_Detail ltd = new Lab_Test_Detail
                        {
                            Lab_Test_ID = lt.Lab_Test_ID,
                            Patient_ID = newBill.Bill_ID,
                            Date = newBill.Creation_Date,
                            Test_ID = (int)test.Item_ID,
                            Actual_Patient_ID = newBill.Patient_ID,
                            IsBilled = true
                        };
                        db.Lab_Test_Details.InsertOnSubmit(ltd);
                        db.SubmitChanges();

                        var detail = ListOfDetails.FirstOrDefault(d =>
                            d.Item_ID == test.Item_ID &&
                            d.Item_Type == "Test" &&
                            d.RecommendedByDoctor == false &&
                            d.ParentTrans_Type != "Test Group Category");
                        if (detail != null)
                            detail.ParentTrans_ID = ltd.Lab_Test_Detail_ID;
                    }
                }
            }

            // >>>>>>>>>>>>>>>>>> ✅ SAVE DETAILS & SHARES <<<<<<<<<<<<<<<<<<<<
            if (data.Bill_ID == 0)
            {
                // New Bill: Insert all details
                db.Ar_Billing_Details.InsertAllOnSubmit(ListOfDetails);
            }

            db.AR_Billing_Detail_Doctor_Shares.InsertAllOnSubmit(ListOfshare);
            db.SubmitChanges();

            var Bill_Detail_List = db.Ar_Billing_Details
                .Where(abd => abd.Bill_ID == newBill.Bill_ID && abd.ParentTrans_Type == "Test")
                .ToList();

            using (DataBaseDataContext dbContext = new DataBaseDataContext())
            {
                var Bill_Detail_Lists = dbContext.Ar_Billing_Details
                    .Where(abd => abd.Bill_ID == newBill.Bill_ID && abd.ParentTrans_Type == "Test Group Category")
                    .ToList();

                foreach (var billDetail in Bill_Detail_Lists)
                {
                    int? testId = null;
                    string categoryId = null;

                    if (billDetail.Item_ID != null && int.TryParse(billDetail.Item_ID.ToString(), out int parsedTestId))
                        testId = parsedTestId;

                    if (billDetail.Category_ID != null)
                        categoryId = billDetail.Category_ID.ToString().Trim();

                    string sqls = $@"
        UPDATE Lab_Test_Detail 
        SET BillDetailID = {billDetail.Bill_Details_ID} 
        WHERE Actual_Patient_ID = {(newBill.Patient_ID.HasValue ? newBill.Patient_ID.Value.ToString() : "NULL")}";

                    // Test_ID condition
                    if (testId.HasValue)
                        sqls += $" AND Test_ID = {testId.Value}";
                    else
                        sqls += " AND Test_ID IS NULL";

                    // Category_ID condition (STRING FIX)
                    if (!string.IsNullOrEmpty(categoryId))
                        sqls += $" AND Catagory_ID = '{categoryId}'";   // 👈 string must be in quotes
                    else
                        sqls += " AND (Catagory_ID IS NULL OR Catagory_ID = '')";

                    dbContext.ExecuteCommand(sqls);
                }
            }
           
            foreach (var billDetail in Bill_Detail_List)
            {
                var labTestDetails = db.Lab_Test_Details
                    .Where(ltd => ltd.Actual_Patient_ID == newBill.Patient_ID && ltd.Test_ID == billDetail.Item_ID)
                    .ToList();

                foreach (var ltd in labTestDetails)
                {
                    ltd.BillDetailID = billDetail.Bill_Details_ID;
                }
            }
            db.SubmitChanges();

            // Manage Receipts
            // var rcpt = db.Receipts.Where(r => r.Bill_ID == newBill.Bill_ID && (r.isCancel == false || r.isCancel == null)).ToList();

            var rcpt = (from r in db.Receipts where r.Bill_ID == newBill.Bill_ID && (r.isCancel == false || r.isCancel == null) orderby r.Receipt_ID descending select r).FirstOrDefault();

            if (rcpt != null)
            {
                //db.Receipts.DeleteAllOnSubmit(rcpt);
                rcpt.isCancel = true;
                rcpt.Cancel_Date = DateTime.Now;
                rcpt.Cancel_by = AppConfig.UserID;
                rcpt.CancelRemarks = "Cancelled due to bill update. Bill No: " + newBill.Bill_No;
                db.SubmitChanges();
            }
            if (newBill.Received_Amount >= 0)
            {
                Receipts.SaveRecord((int)0, (int)(newBill.Patient_ID), (DateTime)newBill.Bill_Date, (string)"Amount received while billing, Bill No:- " + newBill.Bill_No + "", (decimal)newBill.Received_Amount, (int)newBill.Bill_ID);
            }

            // Final updates
            string sql = $"UPDATE AR_Billing_Details SET Category_ID = '' WHERE Item_Type = 'Test' AND Item_ID IN (SELECT Test_ID FROM Lab_Tests) AND Bill_ID = {newBill.Bill_ID}";
            DBClass.executeNonQueryWithoutBegin(sql);

            string sql_query = $"SELECT TOP 1 Discount_Assigned_Patient_Id FROM Discount_Assigned_Patient WHERE Patient_Id = {newBill.Patient_ID}";
            var get = DBClass.getField(sql_query);
            if (get != "There is no row at position 0.")
            {
                var querys = db.Discount_Assigned_Patient_Details
                    .Where(datas => datas.Discount_Assigned_Patient_Id == Convert.ToInt32(get))
                    .ToList();

                foreach (var item in querys)
                {
                    var type = item.Department_Name;
                    var disamt = item.Discount_Amount;
                    if (disamt != 0)
                    {
                        var remain = item.Remaining_Amount;
                        switch (type)
                        {
                            case "Hospital Services": item.Remaining_Amount = sum_Item + remain; break;
                            case "Procedure": item.Remaining_Amount = sum_Procedure + remain; break;
                            case "Package": item.Remaining_Amount = sum_Package + remain; break;
                            case "Lab": item.Remaining_Amount = sum + remain; break;
                            case "UltraSound": item.Remaining_Amount = sum_ultra + remain; break;
                            case "X-Ray": item.Remaining_Amount = sum_Xray + remain; break;
                            case "CT-Scan": item.Remaining_Amount = sum_CTscan + remain; break;
                            case "Blood Bank": item.Remaining_Amount = sum_Blood + remain; break;
                        }
                    }
                }
                db.SubmitChanges();
            }

            DBClass.executeNonQueryWithoutBegin("exec spAutoGenerateLabTestEntry");

            if (data.Appointment_ID.HasValue && data.Appointment_ID.Value > 0 && !string.IsNullOrEmpty(appointmentType))
            {
                try
                {
                    if (appointmentType == "OPD")
                    {
                        DBClass.executeNonQueryWithoutBegin(
                            "UPDATE Appointment_Form SET Status='Visited' WHERE Appointment_ID=" + data.Appointment_ID.Value);
                    }
                    else if (appointmentType == "Derma")
                    {
                        DBClass.executeNonQueryWithoutBegin(
                            "UPDATE Derma_Appointment SET Status='Visited' WHERE Derma_Appointment_Id=" + data.Appointment_ID.Value);
                    }
                }
                catch (Exception ex)
                {
                    // Log error but don't fail the bill save
                    System.Diagnostics.Debug.WriteLine("Appointment status update failed: " + ex.Message);
                }
            }

            return newBill.Bill_ID.ToString();
        }

     
        public class Billings
        {
            public int Bill_ID { get; set; }
            public int Patient_ID { get; set; }
            public string SelectedBranchId { get; set; }
            public int Opd_id { get; set; }
            public string opd_procedure { get; set; }
            public string Panel_Id { get; set; }
            public string referred_by_doctor { get; set; }
            public string PackageName { get; set; }

            public string BillDepartment { get; set; }
            public string BillCategory { get; set; }
            public string CostCenter { get; set; }
            public string bomTotalValue { get; set; }
            public string PackageType { get; set; }
            public string Casher { get; set; }
            public DateTime Bill_Date { get; set; }
            public string Remarks { get; set; }
            public string Referred_Doctor_Name { get; set; }
            public decimal Discount_Percentage { get; set; }
            public decimal Previous_Balance { get; set; }
            public decimal Previous_Paid { get; set; }
            public decimal Total_Doctor_Share { get; set; }
            public decimal Over_and_Above { get; set; }
            public decimal Cash_In_Hand { get; set; }
            public string Bank_Account { get; set; }
            public decimal Discount_Amount { get; set; }
            public decimal TotalPayable { get; set; }
            public decimal Net_Amount { get; set; }
            public decimal Received_Amount { get; set; }
            public decimal Balance_Amount { get; set; }
            public string ChargePolicy { get; set; }
            public string Cash_In_Hand_Account { get; set; }
            public decimal Bank_Cash { get; set; }
            public int? hdn_docid { get; set; }
            public string Main_Department { get; set; }
            public bool finalbill { get; set; }

            public int? Sales_Tax_ID { get; set; }

            public int? Appointment_ID { get; set; }
            public string Appointment_Type { get; set; }

            public string Patient_Type { get; set; }

            public decimal? Sales_Tax_Percentage { get; set; }
            //public string Remarks { get; set; }
            public List<BillingProcessDetails> Details { get; set; }
            public List<DoctorDistributionList> Share { get; set; }
            public List<BOMItemDTO> bomItems { get; set; }
        }
        public class BOMItemDTO
        {
            public int BOMDetailID { get; set; }
            public int ItemID { get; set; }
            public string ItemCode { get; set; }
            public string Description { get; set; }
            public decimal Qty { get; set; }
            public string Unit { get; set; }
            public decimal RecipeCostPerUnit { get; set; }
            public decimal CurrentAvgCost { get; set; }
            public decimal RuntimeCost { get; set; }
            public string Batch_No { get; set; }
            public decimal? BaseUnitQty { get; set; }
            public string InventoryOrg { get; set; }
        }

        //Bilal
        [WebMethod]
        public static decimal GetTestRate(int Patient_ID, string Test_Name, string Patient_Category_Description)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var Patient_Category_Name = db.DataValues.Where(m => m.DataValue_Description.Equals(Patient_Category_Description) && m.ValueSet_ID == 26).Select(m => m.DataValue_Name).ToList();
                string[] nameArray = Test_Name.Split('|');
                var Test_ID = db.Lab_Tests.Where(m => m.Test_Name.Equals(nameArray[0])).Select(m => m.Test_ID).FirstOrDefault();
                if (Test_ID == 0)
                {
                    //fetch Test ID from Group Test
                    Test_ID = db.DataValues.Where(d => d.ValueSet_ID == 70 && d.DataValue_Description == Test_Name).Select(d => d.DataValue_ID).FirstOrDefault();
                }
                decimal Test_Rate = 0;
                Test_Rate = Convert.ToDecimal(DBClass.getField("select dbo.getTestRate('" + Patient_Category_Name[0] + "', " + Test_ID + ", " + Patient_ID + ")"));

                /*
                if (Test_ID.Count != 0)
                {
                    Test_Rate = Convert.ToDecimal(DBClass.getField("select dbo.getTestRate('" + Patient_Category_Name[0] + "', " + Test_ID[0] + ", " + Patient_ID + ")"));
                }
                else {
                    Test_Rate = Convert.ToDecimal(DBClass.getField("select dbo.getTestRate('" + Patient_Category_Name[0] + "', " + 0 + ", " + Patient_ID + ")"));
                }
                */
                return Test_Rate;
            }
        }
        [WebMethod]
        public static string GetDistinctDoctorsByBillId(string Bill_Id)
        {
            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                var result = (from bd in db.Ar_Billing_Details
                              where bd.Bill_ID == Convert.ToInt32(Bill_Id)
                                    && bd.Doctor_id != null
                                    && bd.Doctor_id != "0"
                                    && bd.Doctor_id != ""
                              select new
                              {
                                  Doctor_ID = bd.Doctor_id
                              })
                             .Distinct()
                             .ToList();

                return new JavaScriptSerializer().Serialize(result);
            }
        }
        [WebMethod]
        public static string checkRepeat(int PatientID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var inPatROomsList = (from rm in db.Ward_Allocations
                                      join op in db.In_Patients
                                      on rm.InPatient_ID equals op.In_Patient_ID.ToString()
                                      where op.Patient_ID == PatientID && op.Discharge_On == null
                                      select new
                                      {
                                          op.In_Patient_ID,
                                      }).ToList();
                return (new JavaScriptSerializer()).Serialize(inPatROomsList);
            }
            return "";
        }
        
        [WebMethod]
        public static string GetpanelServiceRate(int Panel_Id ,string Item_Id)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var PanelRate = (from p in db.Panels
                                      join pd in db.Panel_Detail_Services
                                      on p.Panel_ID equals pd.Panel_ID
                                      where p.Panel_ID == Panel_Id && pd.Item_ID == Item_Id
                                      select new
                                      {
                                          pd.Rate,
                                      }).FirstOrDefault();
                return (new JavaScriptSerializer()).Serialize(PanelRate);
            }
            return "";
        }
        
        [WebMethod]
        public static string GetpanelTestRate(int Panel_Id ,string Test_Id)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var PanelRate = (from p in db.Panels
                                      join pd in db.Panel_Detail_Services
                                      on p.Panel_ID equals pd.Panel_ID
                                      where p.Panel_ID == Panel_Id && pd.Test_ID == Test_Id
                                 select new
                                      {
                                          pd.Rate,
                                      }).FirstOrDefault();
                return (new JavaScriptSerializer()).Serialize(PanelRate);
            }
            return "";
        }
        
        [WebMethod]
        public static string GetpanelGroupTestRate(int Panel_Id ,string Test_Id)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var PanelRate = (from p in db.Panels
                                      join pd in db.Panel_Detail_Services
                                      on p.Panel_ID equals pd.Panel_ID
                                      where p.Panel_ID == Panel_Id && pd.Test_ID == Test_Id && pd.GroupCategory == Test_Id
                                 select new
                                      {
                                          pd.Rate,
                                      }).FirstOrDefault();
                return (new JavaScriptSerializer()).Serialize(PanelRate);
            }
            return "";
        }

        [WebMethod]
        public static string LoadBillHeader(int Bill_ID)
        {

            DataBaseDataContext db = new DataBaseDataContext();
            var query = from data in db.Ar_Billings.Where(x => x.Bill_ID == Bill_ID)
                        select new
                        {
                            data.Balance_Amount,
                            data.Bill_Date,
                            data.Bill_ID,
                            data.Bill_No,
                            data.Created_By,
                            data.Creation_Date,
                            data.Discount_Amount,
                            data.Discount_Percentage,
                            data.Net_Amount,
                            data.Patient_ID,
                            data.Received_Amount,
                            data.Charge_Policy,
                            data.Remarks,
                            data.Referred_By_Name,
                            data.Total_Amount,
                            data.Updated_By,
                            data.Updation_Date,
                            data.Casher,
                            data.Previous_Balance,
                            data.Previous_Paid,
                            data.Total_Doctor_Share,
                            data.Over_and_Above,
                            data.Cash_In_Hand,
                            data.Bank_Account,
                            data.Cash_In_Hand_Account,
                            data.Bank_Cash,
                            data.Main_Department,
                            data.Status,
                            data.Doctor_Share_Voucher_Status,
                            data.Voucher_ID,
                            data.In_Patient_ID,
                            data.Panel_Id,
                            data.Referred_By,
                            data.Bill_Category,
                            data.Bill_Department,
                            data.Cost_Center,
                            data.Refund_Amount,
                            data.Sales_Tax_ID,
                            data.Sales_Tax_Percentage,
                            data.Patient_Type,
                            Referred_By_Text = db.HR_Employees.Where(e => e.Emp_ID == (data.Referred_By != null ? Convert.ToInt32(data.Referred_By) : 0)).Select(e => e.Emp_Name).FirstOrDefault() ?? "",
                            Bill_Department_text = db.GetDataValueName("Patient Main Category", data.Bill_Department),
                            Bill_Category_text = db.GetDataValueName("Mode Of Registration", data.Bill_Category),
                            Patient_Discount_Type = (from tbl in db.In_Patients
                                                     where tbl.In_Patient_ID == data.In_Patient_ID

                                                     orderby tbl.Created_Time descending
                                                     select db.GetDataValueName("Patient Type", tbl.Patient_Discount_Type)).FirstOrDefault(),

                           
                        };
            //var Header = db.Ar_Billings.Where(bm => bm.Bill_ID == Bill_ID);
            return (new JavaScriptSerializer()).Serialize(query);
        }

        [WebMethod]
        public static string LoadBillDetails(int Bill_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = (from d in db.Ar_Billing_Details
                           join m in db.Ar_Billings
                            on d.Bill_ID equals m.Bill_ID
                           where m.Bill_ID == Bill_ID
                           select new
                           {
                               d.Amount,
                               d.Batch_No,
                               d.Bill_Details_ID,
                               d.Bill_ID,
                               d.Category_ID,
                               d.Discount_Amount,
                               d.Discount_Percentage,
                               d.Expiry_Date,
                               d.Item_ID,
                               d.Item_Name,
                               d.Net_Amount,
                               d.Item_Type,
                               d.ParentTrans_ID,
                               d.Test_Main_Department,
                               d.ParentTrans_Name,
                               d.ParentTrans_Type,
                               d.Qty,
                               d.Remarks,
                               Doctor_Share = d.Doctor_Share ?? 0,
                               //d.Hospital_Share,
                               Hospital_Share = d.Hospital_Share ?? 0,
                               d.Doctor_id,
                               d.RecommendedByDoctor,
                               m.Referred_By,
                               d.Is_Approval,
                               d.Issue_Date
                           }).ToList();


            return (new JavaScriptSerializer()).Serialize(Details);
        }

        [WebMethod]
        public static string LoadAllBillDetails(int in_pat)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            // If the final bill has already been made for this in-patient,
            // do not load any bills against it again.
            var isFinalBilled = (from ipd in db.In_Patients
                                 where ipd.In_Patient_ID == in_pat
                                       && ipd.Final_Bill == true
                                       
                                 select ipd.In_Patient_ID).Any();
            if (isFinalBilled)
                return "[]";

            var Details = (from d in db.Ar_Billing_Details
                           join m in db.Ar_Billings
                            on d.Bill_ID equals m.Bill_ID
                           where m.In_Patient_ID == in_pat
                           && (m.IsPharmacy == false || m.IsPharmacy == null)
                           select new
                           {
                               d.Amount,
                               d.Batch_No,
                               d.Bill_Details_ID,
                               d.Bill_ID,
                               d.Category_ID,
                               d.Discount_Amount,
                               d.Discount_Percentage,
                               d.Expiry_Date,
                               d.Item_ID,
                               d.Item_Name,
                               d.Net_Amount,
                               d.Item_Type,
                               d.ParentTrans_ID,
                               d.Test_Main_Department,
                               d.ParentTrans_Name,
                               d.ParentTrans_Type,
                               d.Qty,
                               d.Remarks,
                               d.Doctor_Share,
                               d.Hospital_Share,
                               d.Doctor_id,
                               d.RecommendedByDoctor,
                               m.Referred_By
                               ,d.Issue_Date
                               ,d.Is_Approval
                           }).ToList();


            return (new JavaScriptSerializer()).Serialize(Details);
        }


        [WebMethod]
        public static string GetPharmacyBillTotal(int in_pat)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var pharmacyBills = (from m in db.Ar_Billings
                                 where m.In_Patient_ID == in_pat
                                       && m.IsPharmacy == true
                                       && (m.isCancel == false || m.isCancel == null)
                                 select m).ToList();

            decimal total = pharmacyBills.Sum(m => m.Balance_Amount ?? 0);

            bool isOTPharmacy = pharmacyBills.Any(m => m.Ware_House == "004");

            INV_Item pharmacyItem = null;

            if (isOTPharmacy)
            {
                pharmacyItem = (from itm in db.INV_Items
                                where itm.IsCathBilling == true
                                select itm).FirstOrDefault();
            }

            if (pharmacyItem == null)
            {
                pharmacyItem = (from itm in db.INV_Items
                                where itm.IsPharmacyBilling == true
                                select itm).FirstOrDefault();
            }

            int itemId = 0;
            string itemName = "Pharmacy Bill";

            if (pharmacyItem != null)
            {
                itemId = pharmacyItem.Item_ID;
                itemName = pharmacyItem.Description ?? "Pharmacy Bill";
            }

            return (new JavaScriptSerializer()).Serialize(new
            {
                PharmacyTotal = total,
                BillCount = pharmacyBills.Count,
                ItemName = itemName,
                ItemId = itemId
            });
        }


        //[WebMethod]
        //public static string GetPharmacyBillTotal(int in_pat)
        //{
        //    DataBaseDataContext db = new DataBaseDataContext();
        //    var pharmacyBills = (from m in db.Ar_Billings
        //                         where m.In_Patient_ID == in_pat
        //                               && m.IsPharmacy == true
        //                               && (m.isCancel == false || m.isCancel == null)
        //                         select m).ToList();

        //    decimal total = pharmacyBills.Sum(m => m.Balance_Amount ?? 0);

        //    var pharmacyItem = (from itm in db.INV_Items
        //                        where itm.IsPharmacyBilling == true
        //                        select itm).FirstOrDefault();

        //    int itemId = 0;
        //    string itemName = "Pharmacy Bill";

        //    if (pharmacyItem != null)
        //    {
        //        itemId = pharmacyItem.Item_ID;
        //        itemName = pharmacyItem.Description ?? "Pharmacy Bill";
        //    }

        //    return (new JavaScriptSerializer()).Serialize(new
        //    {
        //        PharmacyTotal = total,
        //        BillCount = pharmacyBills.Count,
        //        ItemName = itemName,
        //        ItemId = itemId
        //    });
        //}
        // Agreements whose Start_Time/End_Time window contains 'now'. Handles overnight ranges (Start > End).
        // Agreements with NULL times (legacy rows) are always considered valid.
        private static IQueryable<Doctor_Agreement> AgreementsValidAt(DataBaseDataContext db, TimeSpan now)
        {
            return db.Doctor_Agreements.Where(a => a.Start_Time == null || a.End_Time == null
                || (a.Start_Time <= a.End_Time && now >= a.Start_Time && now <= a.End_Time)
                || (a.Start_Time > a.End_Time && (now >= a.Start_Time || now <= a.End_Time)));
        }

        [WebMethod]
        public static string GetDocAgreementValues(string doc_id, string test_id, string item_id, string item_name, string Aggreement_Type)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                bool isAgreementType03 = Aggreement_Type == "03"; // Moved outside for global access
                var validAgreements = AgreementsValidAt(db, DateTime.Now.TimeOfDay);

                // Check if the doctor exists in agreements
                var Check_Doc = (from data in validAgreements
                                 join dd in db.Doctor_agreement_details on data.Doc_agreemnt_id equals dd.Doc_agreement_id
                                 where data.Doctor == doc_id
                                 //&& dd.item_id.ToString() == item_id
                                 && dd.AgrementTypeId == Aggreement_Type
                                 && (dd.service_description.Contains(item_name) || dd.test_description.Contains(item_name))
                                 select new { dd.Doc_agreement_id}).FirstOrDefault();

                if (Check_Doc != null)
                {
                    var check = (from data in validAgreements
                                 join dd in db.Doctor_agreement_details on data.Doc_agreemnt_id equals dd.Doc_agreement_id
                                 where data.Doctor == doc_id
                                 && dd.item_id.ToString() == item_id
                                 && dd.item_id != 0
                                 && dd.test_id == 0
                                 && dd.services == "001"
                                 && dd.AgrementTypeId == Aggreement_Type
                                 && dd.service_description.Contains(item_name)
                                 select new { dd.services }).FirstOrDefault();

                    if (check != null && check.services == "001")
                    {
                        var serv = validAgreements
                                     .Join(db.Doctor_agreement_details,
                                           data => data.Doc_agreemnt_id,
                                           dd => dd.Doc_agreement_id,
                                           (data, dd) => new { dd , data })
                                     .Where(d => d.dd.services == "001"
                                              && d.dd.AgrementTypeId == Aggreement_Type
                                              && d.dd.isactive == true
                                              && d.dd.item_id.ToString() == item_id
                                              && d.data.Doctor.ToString() == doc_id)
                                     .Select(d => new { d.dd.doc_share, d.dd.hos_share })
                                     .FirstOrDefault();

                        return new JavaScriptSerializer().Serialize(serv);
                    }

                    var items = validAgreements
                                  .Join(db.Doctor_agreement_details,
                                        data => data.Doc_agreemnt_id,
                                        dd => dd.Doc_agreement_id,
                                        (data, dd) => new { dd, data })
                                  .Where(d => d.dd.AgrementTypeId == Aggreement_Type
                                           && d.dd.isactive == true
                                           && d.dd.services == null
                                           && d.dd.test_id == Convert.ToInt32(test_id)
                                           && d.dd.item_id == 0
                                          && d.data.Doctor.ToString() == doc_id)
                                  .Select(d => new { d.dd.doc_share, d.dd.hos_share })
                                  .FirstOrDefault();

                    return new JavaScriptSerializer().Serialize(items);
                }

                // If doctor does not exist, return default panel/service values
                if (isAgreementType03)
                {
                    var Panel_Test = db.Panel_Detail_Services
                                       .Where(d => d.Test_ID == test_id && d.Item_ID == null)
                                       .Select(d => new { doc_share = 0, hos_share = d.Rate })
                                       .FirstOrDefault();

                    if (Panel_Test == null)
                    {
                        var Panel_Service = db.Panel_Detail_Services
                                              .Where(d => d.Test_ID == null && d.Item_ID == item_id)
                                              .Select(d => new { doc_share = 0, hos_share = d.Rate })
                                              .FirstOrDefault();

                        return new JavaScriptSerializer().Serialize(Panel_Service);
                    }
                    return new JavaScriptSerializer().Serialize(Panel_Test);
                }
                else
                {
                    var Test_Id = db.Lab_Tests
                                    .Where(d => d.Test_ID == Convert.ToInt32(test_id) && d.Test_Name == item_name)
                                    .Select(d => new { doc_share = 0, hos_share = d.Rate })
                                    .FirstOrDefault();

                    if (Test_Id == null)
                    {
                        var Service = db.INV_Items
                                        .Where(inv => inv.Item_ID == Convert.ToInt32(item_id) && inv.Services == true && inv.Description == item_name)
                                        .Select(inv => new { doc_share = 0, hos_share = inv.Sale_Rate })
                                       // .Select(inv => new { doc_share = (inv.Doctor_Share / 100) * inv.Sale_Rate, hos_share = (inv.Hospital_Share / 100) * inv.Sale_Rate })
                                        .FirstOrDefault();
                        if(Service == null)
                        {
                            var Services = db.DataValues
                                       .Where(inv => inv.DataValue_Name == item_id && inv.DataValue_Description == item_name)
                                       .Select(inv => new { doc_share = 0, hos_share = inv.Segment1 })
                                       // .Select(inv => new { doc_share = (inv.Doctor_Share / 100) * inv.Sale_Rate, hos_share = (inv.Hospital_Share / 100) * inv.Sale_Rate })
                                       .FirstOrDefault();

                            return new JavaScriptSerializer().Serialize(Services);
                        }

                        return new JavaScriptSerializer().Serialize(Service);
                    }
                   

                    return new JavaScriptSerializer().Serialize(Test_Id);
                }
            }
        }


        //  [WebMethod]
        //  public static string approve_Bill(string BillId)
        //  {
        //      var user_id = AppConfig.UserID;
        //      DataBaseDataContext db = new DataBaseDataContext();
        ////      var Details = db.SpApproveBillingProcess(Convert.ToInt32(BillId), user_id);
        //      return (new JavaScriptSerializer()).Serialize(Details);
        //  }

        [WebMethod]
        public static string approve_Bill(string billid)
        {
            try
            {
                var user_id = AppConfig.UserID;
                int billId = Convert.ToInt32(billid);

                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    db.ExecuteCommand(
                        "EXEC dbo.SpApproveBillingProcess {0}, {1}",
                        billId,
                        user_id
                    );
                }

                return new JavaScriptSerializer().Serialize(new
                {
                    Success = true,
                    Message = "Bill approved successfully"
                });
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new
                {
                    Success = false,
                    Message = ex.Message
                });
            }
        }


        [WebMethod]
        public static string LoadDocShare(int Bill_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Share = (from d in db.AR_Billing_Detail_Doctor_Shares
                         join m in db.Ar_Billings
                          on d.Bill_ID equals m.Bill_ID
                         where m.Bill_ID == Bill_ID
                         select new
                         {
                             d.Emp_ID,
                             d.Share_type,
                             d.Amount
                         }).ToList();


            return (new JavaScriptSerializer()).Serialize(Share);
        }
        [WebMethod]
        public static string LoadBillPackagesDetails(int Bill_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var PackagesDetails = (from d in db.Ar_Billing_Details
                                   join m in db.Ar_Billings
                                    on d.Bill_ID equals m.Bill_ID
                                   join p in db.Ar_Billing_PackageDetails
                                   on d.Bill_Details_ID equals p.Bill_Details_ID
                                   where m.Bill_ID == Bill_ID
                                   select p).ToList();
            return (new JavaScriptSerializer()).Serialize(PackagesDetails);
        }
        [WebMethod]
        public static string GetBillingRecords(int Patient_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var PackagesDetails = (from
                                   m in db.Ar_Billings
                                   where m.Patient_ID == Patient_ID && (m.In_Patient_ID != null && m.In_Patient_ID != 0)
                                   select new
                                   {
                                       m.Bill_No,
                                       m.Bill_ID,
                                       m.Received_Amount,
                                       m.Discount_Amount,
                                       m.Total_Amount,
                                       m.Balance_Amount
                                   }).ToList();
            return (new JavaScriptSerializer()).Serialize(PackagesDetails);
        }
        [WebMethod]
        public static string GetBillingRecordsDetails(int Bill_Id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var PackagesDetails = (from m in db.Ar_Billings
                                   join d in db.Ar_Billing_Details
                                    on m.Bill_ID equals d.Bill_ID
                                   where m.Bill_ID == Bill_Id
                                   select new
                                   {
                                       m.Bill_No,
                                       d.Item_Name,
                                       d.Item_ID,
                                       d.Item_Type,
                                       d.Net_Amount,
                                       d.Qty,
                                       d.Amount,
                                       d.Discount_Amount
                                   }).ToList();
            return (new JavaScriptSerializer()).Serialize(PackagesDetails);
        }
        [System.Web.Services.WebMethod]
        public static PatientDetail GetPatientDetails(string PatientID)
        {
            int pat_id = 0;
            bool isExist_ipd = false;
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var walkin = (from tbl in db.Reg_patients
                          where tbl.pat_id == int.Parse(PatientID)
                          orderby tbl.Created_time descending
                          select tbl.walkin).FirstOrDefault();
            var query = (from data in db.In_Patients.Where(x => x.Patient_ID == Convert.ToInt32(PatientID) && x.Discharge == false) select data.Patient_ID).ToList();
            if (query.Count > 0 && walkin == false)
            {
                pat_id = DBClass.GetPat_ID_By_PatientID_reg(Convert.ToInt32(PatientID));
            }
            else
            {
                pat_id = DBClass.GetPat_ID_By_PatientID_reg(Convert.ToInt32(PatientID));
            }

            int Patien_No = DBClass.GetMRNOBy_PatientID_reg(Convert.ToInt32(PatientID));
            PatientDetail pt = new PatientDetail();

            Reg_patient pat = new Reg_patient();

            pat = (from tbl in db.Reg_patients
                   where tbl.Patient_No == Patien_No
                   orderby tbl.Created_time descending
                   select tbl).FirstOrDefault();

            var isPatient = (from tbl in db.In_Patients
                             where tbl.Patient_ID == int.Parse(PatientID)

                             orderby tbl.Created_Time descending
                             select tbl).FirstOrDefault();


            var OPD = (from tbl in db.Out_Patients
                       where tbl.Reg_PatId == int.Parse(PatientID)

                       orderby tbl.Created_Time descending
                       select tbl).FirstOrDefault();

            if (OPD != null)
            {


            }


            if (pat != null)
            {
               var patient = (from tbl in db.Patients 
                              where tbl.Reg_PatId == pat.pat_id
                              //&& (opd.Discharge == false || opd.Discharge == null)
                              orderby tbl.Patient_ID descending
                       select tbl).FirstOrDefault();
               var patientOPD = (from tbl in db.Patients join opd in db.Out_Patients
                              on tbl.Patient_ID equals opd.Patient_ID
                              where tbl.Reg_PatId == pat.pat_id
                              && (opd.Discharge == false || opd.Discharge == null)
                              orderby tbl.Patient_ID descending
                       select tbl).FirstOrDefault();


                var inpat = (from tbl in db.In_Patients
                             where tbl.Patient_ID == Convert.ToInt32(PatientID)
                             && (tbl.Discharge == null || tbl.Discharge == false)
                             orderby tbl.Created_Time descending
                             select tbl).FirstOrDefault();

                var Emer_Pat = (from tbl in db.Emergency_Patients
                             where tbl.Patient_ID == Convert.ToInt32(PatientID)
                             && (tbl.Discharge == null || tbl.Discharge == false)
                                orderby tbl.Created_Time descending
                             select tbl).FirstOrDefault();

                var DiscountAssignedPatient = (from tbl in db.Discount_Assigned_Patients
                                             where tbl.Patient_Id == Convert.ToInt32( PatientID) && (tbl.IsDischarge == null || tbl.IsDischarge == false)
                                             orderby tbl.Discount_Assigned_Patient_Id descending
                                             select tbl).FirstOrDefault();

                pt.Name = pat.Full_Name;
                pt.Gender = pat.Gender;
                pt.FatherName = pat.Father_Name;
                if(pat.Age_years == null)
                {
                    pt.Age = "";
                }
                else {
                    pt.Age = pat.Age_years.ToString();
                }
                    
                pt.Gender = db.GetDataValueName("Gender", pat.Gender);
                pt.Address = pat.Permanent_Address;
                pt.Mobile = pat.Mobile1;
                pt.NIC = pat.NIC;
                //pt.opdid = DBClass.getField("select Out_Patient_ID from Out_Patient where Patient_ID =" + pat_id);
                //pt.get_patientid = DBClass.getField("select Patient_ID from Patients where Reg_PatId =" + PatientID);
                //pt.refferedoc = DBClass.getField("select Doctor_ID from Out_Patient where Patient_id=" + pt.get_patientid + " order by Created_Time desc");
                pt.refferedoc = DBClass.getField($"SELECT TOP 1 Doctor_ID FROM Out_Patient WHERE Reg_PatId = {pat_id} ORDER BY Created_Time DESC");
                if (pat.Created_time.HasValue)
                {
                    pt.Entry_Date = pat.Created_time.ToString();
                }
                else
                {
                    pt.Entry_Date = pat.Created_time.ToString();
                }
        if (inpat != null)
                {
                    if (inpat.Discharge == null || inpat.Discharge == false)
                    {
                        var Ward = (from tbl in db.Ward_Definitions
                                    where tbl.Ward_ID == inpat.Ward_ID
                                    select tbl.Ward_Type).FirstOrDefault();
                        pt.Patient_Type = db.GetDataValueName("Patient Type", inpat.Patient_Discount_Type);
                        pt.Patient_Type_id = inpat.Patient_Discount_Type;
              
                        pt.IPD_Panel_ID = inpat.Panel_Company?.ToString();

                        // Get IPD panel name from Panels table
                        if (!string.IsNullOrEmpty(inpat.Panel_Company))
                        {
                            var ipdPanel = (from p in db.Panels
                                            where p.Panel_ID == Convert.ToInt32(inpat.Panel_Company)
                                            select p).FirstOrDefault();
                            if (ipdPanel != null)
                            {
                                pt.IPD_Panel_Name = ipdPanel.Company_Name;
                            }
                        }
                        if (inpat.Discharge_Request == true) {
                            pt.paid_amount = DBClass.getField("select sum(Received_Amount) from Ar_Billings where  In_Patient_ID =" + inpat.In_Patient_ID + " AND (isCancel = 0 OR isCancel IS NULL) AND ISNULL(IsPharmacy,0) = 0 AND IsNull(final_bill_ipd,0) = 0");
                           
                        }
                        pt.advance_amount = DBClass.getField("select sum(Advance_Amount) from AR_Advances where In_Patient_ID=" + inpat.In_Patient_ID + " AND (isCancelled = 0 OR isCancelled IS NULL)");
                        pt.Ward_Name = Ward;
                        pt.Admission_Date = Convert.ToString(inpat.Admission_Date);
                        pt.Discharge_On = Convert.ToString(inpat.Discharge_On);
                        pt.Bed_No = Convert.ToString(inpat.Bed_No);
                        pt.Department = db.GetDataValueName("Patient Main Category", inpat.Department);
                        pt.Bill_Department = inpat.Department;
                        pt.Cost_Center = inpat.Cost_Center;
                        pt.MainDepartment = "03";
                        pt.Package_Type = inpat.Package_Type_Id;
                        pt.Package_Name = inpat.Package_Name_Id;
                        pt.pkg_name = inpat.packagae_name;
                        pt.pkg_type = inpat.packagae_type;
                        pt.Request_Discharge = Convert.ToBoolean(inpat.Discharge_Request);
                        pt.In_Patient_ID = Convert.ToString(inpat.In_Patient_ID);
                        pt.InsuranceCardNo = inpat.InsuranceCardNo;

                    }
                }
                else if (Emer_Pat != null)
                {
                 if (Emer_Pat.Discharge == null || Emer_Pat.Discharge == false)
                    {
                        var Ward = (from tbl in db.Ward_Definitions
                                    where tbl.Ward_ID == Emer_Pat.Ward_ID
                                    select tbl.Ward_Type).FirstOrDefault();
                        pt.Ward_Name = Ward;
                        pt.Admission_Date = Convert.ToString(Emer_Pat.Admission_Date);
                        pt.Discharge_On = Convert.ToString(Emer_Pat.Discharge_On);
                        pt.Bed_No = Convert.ToString(Emer_Pat.Bed_No);
                        pt.MainDepartment = "02";
                        pt.Department = "";

                        // Priority 1: Department entered on Emergency Admission / Emergency Case (Emergency_Patient.Department)
                        if (!string.IsNullOrEmpty(Emer_Pat.Department))
                        {
                            pt.Bill_Department = Emer_Pat.Department;
                            pt.Department = db.GetDataValueName("Patient Main Category", Emer_Pat.Department);
                        }
                        else
                        {
                            // Fallback: Department saved on Emergency Form (Emergency.Patient_Main_Category)
                            var emer = (from tbl in db.Emergencies
                                        where tbl.Reg_PatId == pat.pat_id
                                        orderby tbl.Created_Time descending
                                        select tbl).FirstOrDefault();
                            if (emer != null)
                            {
                                pt.Bill_Department = emer.Patient_Main_Category;
                                pt.Cost_Center = emer.Cost_Center;
                                pt.Department = db.GetDataValueName("Patient Main Category", emer.Patient_Main_Category);
                            }
                        }
                    } 
                }
                else if (patientOPD != null)
                {
                    pt.Patient_Type = db.GetDataValueName("Patient Type", patientOPD.Patient_Type);
                    pt.Patient_Type_id = patientOPD.Patient_Type;
                    pt.Admission_Date = "";
                    pt.Discharge_On = "";
                    pt.Ward_Name = "";
                    pt.Bed_No = "";
                    pt.Room_Name = "";
                    pt.MainDepartment = "01";
                    pt.Bill_Department = patientOPD.Patient_Main_Category;
                    pt.Cost_Center = patientOPD.Cost_Center;
                    pt.Department = db.GetDataValueName("Patient Main Category", patientOPD.Patient_Main_Category);
                }
                else
                {
                   // pt.Patient_Type = db.GetDataValueName("Patient Type", patient.Patient_Type);
                   // pt.Patient_Type_id = patient.Patient_Type;
                    pt.Admission_Date = "";
                    pt.Discharge_On = "";
                    pt.Ward_Name = "";
                    pt.Bed_No = "";
                    pt.Room_Name = "";
                    pt.MainDepartment = "01";
                    if (patient != null)
                    {
                        pt.Bill_Department = patient.Patient_Main_Category;
                        pt.Cost_Center = patient.Cost_Center;
                        pt.Department = db.GetDataValueName("Patient Main Category", patient.Patient_Main_Category);
                    }
                }
                if (DiscountAssignedPatient != null)
                {
                    pt.IsDisountAvailable = "True";
                }
                else
                {
                    pt.IsDisountAvailable = "fasle";
                }

                var Patientno = pat.Patient_No.ToString();
                var count = (db.Patients.Where(v => v.Patient_No == Convert.ToInt32(Patientno)).ToList());
                pt.Follow = count.Count.ToString();



                return pt;
            }
            else
                return pt;
        }
        //[System.Web.Services.WebMethod]

        //public static PatientDetail GetPatientDetails(string PatientID)
        //{
        //    int pat_id = 0;
        //    bool isExist_ipd = false;
        //    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
        //    var walkin = (from tbl in db.Reg_patients
        //                  where tbl.pat_id == int.Parse(PatientID)
        //                  orderby tbl.Created_time descending
        //                  select tbl.walkin).FirstOrDefault();
        //    var query = (from data in db.In_Patients.Where(x => x.Patient_ID == Convert.ToInt32(PatientID) && x.Discharge == false) select data.Patient_ID).ToList();
        //    if (query.Count > 0 && walkin == false)
        //    {
        //        pat_id = DBClass.GetPat_ID_By_PatientID_reg(Convert.ToInt32(PatientID));
        //    }
        //    else
        //    {
        //        pat_id = DBClass.GetPat_ID_By_PatientID_reg(Convert.ToInt32(PatientID));
        //    }

        //    int Patien_No = DBClass.GetMRNOBy_PatientID_reg(Convert.ToInt32(PatientID));
        //    PatientDetail pt = new PatientDetail();

        //    Reg_patient pat = new Reg_patient();

        //    pat = (from tbl in db.Reg_patients
        //           where tbl.Patient_No == Patien_No
        //           orderby tbl.Created_time descending
        //           select tbl).FirstOrDefault();

        //    var isPatient = (from tbl in db.In_Patients
        //                     where tbl.Patient_ID == int.Parse(PatientID)

        //                     orderby tbl.Created_Time descending
        //                     select tbl).FirstOrDefault();


        //    var OPD = (from tbl in db.Out_Patients
        //               where tbl.Patient_ID == pat_id

        //               orderby tbl.Created_Time descending
        //               select tbl).FirstOrDefault();

        //    if (OPD != null)
        //    {


        //    }


        //    if (pat != null)
        //    {
        //        pt.Name = pat.Full_Name;
        //        pt.Gender = pat.Gender;
        //        pt.Age = pat.Age_years.ToString();

        //        if (pat.Created_time.HasValue)
        //        {
        //            pt.Entry_Date = pat.Created_time.ToString();
        //        }
        //        else
        //        {
        //            pt.Entry_Date = pat.Created_time.ToString();
        //        }
        //        pt.opdid = DBClass.getField("select Out_Patient_ID from Out_Patient where Reg_PatId =" + pat_id);
        //        // pt.opd_id = DBClass.getField("Select Patient_ID from Patients where Reg_PatId = " + pat_id + "order by Created_Time desc" );
        //        if (query.Count > 0 && walkin == false)
        //        {
        //            pt.pat_id = DBClass.getField("select Patient_ID from In_Patient where Patient_ID =" + pat_id);
        //        }
        //        else
        //        {
        //            pt.pat_id = DBClass.getField("select Reg_PatId from Out_Patient where Reg_PatId =" + pat_id);
        //        }
        //        pt.Patient_Type = db.GetDataValueName("Patient Type", DBClass.getField("select Patient_Type from Patients where  Reg_PatId =" + PatientID + "order by Created_Time desc"));
        //        pt.Patient_Type_id = DBClass.getField("select Patient_Type from Patients where  Reg_PatId =" + PatientID + "order by Created_Time desc");
        //        pt.IsDisountAvailable = DBClass.getField("select Discount_Assigned_Patient_Id from Discount_Assigned_Patient where ISNULL(IsDischarge,'0')=0 and Patient_Id =" + PatientID);
        //        pt.DiscountPercFromMaster = DBClass.getField("select Discount_Percentage from Discount_Assigned_Patient where ISNULL(IsDischarge,'0')=0 and Patient_Id =" + PatientID);


        //        // Fetch active inpatient ID (not discharged)
        //        var inpat_id = DBClass.getField(
        //            "select top 1 In_Patient_ID from In_Patient " +
        //            "where Patient_ID = " + PatientID +
        //            " and isNull(Discharge,0) = 0 " +
        //            "order by In_Patient_ID desc"
        //        );

        //        // Get latest discharge status
        //        pt.checkdischarge = DBClass.getField(
        //            "select top 1 isnull(Discharge,0) from In_Patient " +
        //            "where Patient_Id = " + PatientID +
        //            " order by Created_Time desc"
        //        );

        //        // Get Admission_Date (format: 2025-08-30 17:37:41.000)
        //        // Get Discharge_On from the most recent admission (latest In_Patient_ID)
        //        pt.Discharge_On = DBClass.getField(
        //            "SELECT TOP 1 Discharge_On " +
        //            "FROM In_Patient " +
        //            "WHERE Patient_ID = " + PatientID + " " +
        //            "ORDER BY In_Patient_ID DESC"
        //        )?.ToString() ?? "";
        //        var ipdAcc = DBClass.getField(
        //            "SELECT TOP 1 isNull(ispackagebilling,0) " +
        //            "FROM In_Patient " +
        //            "WHERE Patient_ID = " + PatientID + " " +
        //            "ORDER BY In_Patient_ID DESC"
        //        )?.ToString() ?? "";
        //        // Flag: was discharge done today?
        //        bool isdischargetoday = false;

        //        if (!string.IsNullOrEmpty(pt.Discharge_On))
        //        {
        //            if (DateTime.TryParse(pt.Discharge_On, out DateTime dischargedate))
        //            {
        //                if (dischargedate.Date == DateTime.Today)
        //                {
        //                    isdischargetoday = true;
        //                }
        //            }
        //        }
        //        pt.Package_Type = DBClass.getField("SELECT TOP 1 Package_type_id FROM In_Patient WHERE Patient_Id = " + PatientID + " ORDER BY Created_Time DESC")?.ToString() ?? "";
        //        pt.Package_Name = DBClass.getField("SELECT TOP 1 Package_Name_id FROM In_Patient WHERE Patient_Id = " + PatientID + " ORDER BY Created_Time DESC")?.ToString() ?? "";
        //        pt.pkg_namefordetails = DBClass.getField("SELECT TOP 1 packagae_name FROM In_Patient WHERE Patient_Id = " + PatientID + " ORDER BY Created_Time DESC")?.ToString() ?? "";
        //        pt.pkg_typefordetails = DBClass.getField("SELECT TOP 1 packagae_type FROM In_Patient WHERE Patient_Id = " + PatientID + " ORDER BY Created_Time DESC")?.ToString() ?? "";
        //        // Main condition: if NOT discharged OR discharged TODAY → show package data
        //        if (pt.checkdischarge == "false" || pt.checkdischarge == "0" || ipdAcc == "1"|| ipdAcc == "true")
        //        {
        //            // Patient is either still admitted OR was discharged today
        //            pt.pkg_name = DBClass.getField("SELECT TOP 1 packagae_name FROM In_Patient WHERE Patient_Id = " + PatientID + " AND Discharge = 1 ORDER BY Created_Time DESC")?.ToString() ?? "";

        //            pt.pkg_type = DBClass.getField("SELECT TOP 1 packagae_type FROM In_Patient WHERE Patient_Id = " + PatientID + " AND Discharge = 1 ORDER BY Created_Time DESC")?.ToString() ?? "";



        //            pt.In_Patient_Type = DBClass.getField("SELECT TOP 1 Patient_Discount_Type FROM In_Patient WHERE Patient_Id = " + PatientID + " ORDER BY Created_Time DESC")?.ToString() ?? "";



        //            pt.MainDepartment = "03";
        //        }
        //        else
        //        {
        //            // Patient was discharged on a previous day (not today)
        //            pt.Department = db.GetDataValueName("Patient Main Category",
        //                DBClass.getField("SELECT TOP 1 Patient_Main_Category FROM Patients WHERE Reg_PatId = " + PatientID + " ORDER BY Created_Time DESC")?.ToString() ?? "");

        //            if (pt.IsDisountAvailable.Contains("position"))
        //                pt.IsDisountAvailable = "false";

        //            pt.Address = pat.Permanent_Address;
        //            pt.Mobile = pat.Mobile1;
        //            pt.Admission_Date = "";
        //            pt.Discharge_On = "";
        //            pt.Ward_Name = "";
        //            pt.Bed_No = "";
        //            pt.Room_Name = "";
        //            pt.MainDepartment = "01";
        //        }



        //        var Emergency_Id = DBClass.getField("select Emergency_ID from Emergency_Patient where Patient_ID =" + PatientID + "and isNull(Discharge,0) = 0 order by Emergency_ID desc");
        //        var ipd_id = DBClass.getField("select In_Patient_ID from In_Patient where Patient_ID =" + PatientID + "and isNull(Discharge,0) = 1 order by In_Patient_ID desc");
        //        var ipd_ids = DBClass.getField("select In_Patient_ID from In_Patient where Patient_ID =" + PatientID + "and isNull(Discharge,0) = 0 order by In_Patient_ID desc");
        //        if (ipd_ids != "There is no row at position 0.")
        //        {
        //            pt.Ward_Name = DBClass.getField("Select Ward_Type from In_Patient ipd join Ward_Definition wd on ipd.Ward_ID = wd.Ward_ID where ipd.In_Patient_ID =" + ipd_ids);
        //            pt.Admission_Date = DBClass.getField("Select Admission_Date from In_Patient ipd  where ipd.In_Patient_ID =" + ipd_ids);
        //            pt.Bed_No = DBClass.getField("Select Bed_No from In_Patient ipd where ipd.In_Patient_ID =" + ipd_ids);
        //            pt.Department = db.GetDataValueName("Patient Main Category", DBClass.getField("select Department from In_Patient where  In_Patient_ID =" + ipd_ids + "order by Created_Time desc"));
        //            pt.advance_amount = DBClass.getField("select sum(Advance_Amount) from AR_Advances where In_Patient_ID=" + ipd_ids);
        //            pt.MainDepartment = "03";
        //        }

        //        else if (ipd_id != "There is no row at position 0." )
        //        {
        //            pt.PreviousTotalAmount = DBClass.getField("select sum(Net_Amount) from Ar_Billings where  In_Patient_ID =" + ipd_id);
        //            pt.paid_amount = DBClass.getField("select sum(Received_Amount) from Ar_Billings where  In_Patient_ID =" + ipd_id);
        //            pt.Balance = DBClass.getField("select sum(Previous_Balance) from Ar_Billings where  In_Patient_ID =" + ipd_id);
        //            pt.Ward_Name = DBClass.getField("Select Ward_Type from In_Patient ipd join Ward_Definition wd on ipd.Ward_ID = wd.Ward_ID where ipd.In_Patient_ID =" + ipd_id);
        //            pt.Admission_Date = DBClass.getField("Select Admission_Date from In_Patient ipd  where ipd.In_Patient_ID =" + ipd_id);
        //            pt.Discharge_On = DBClass.getField("Select Discharge_On from In_Patient ipd  where ipd.In_Patient_ID =" + ipd_id);
        //            pt.Bed_No = DBClass.getField("Select Bed_No from In_Patient ipd where ipd.In_Patient_ID =" + ipd_id);
        //            pt.Department = db.GetDataValueName("Patient Main Category", DBClass.getField("select Department from In_Patient where  In_Patient_ID =" + ipd_id + "order by Created_Time desc"));
        //            pt.advance_amount = DBClass.getField("select sum(Advance_Amount) from AR_Advances where In_Patient_ID=" + ipd_id);
        //            pt.pkg_name = DBClass.getField("SELECT TOP 1 packagae_name FROM In_Patient WHERE Patient_Id = " + PatientID + " AND Discharge = 1 ORDER BY Created_Time DESC")?.ToString() ?? "";

        //            pt.pkg_type = DBClass.getField("SELECT TOP 1 packagae_type FROM In_Patient WHERE Patient_Id = " + PatientID + " AND Discharge = 1 ORDER BY Created_Time DESC")?.ToString() ?? "";


        //        }

        //        else if (Emergency_Id != "There is no row at position 0.")
        //        {
        //            pt.Ward_Name = DBClass.getField("Select Ward_Type from Emergency_Patient ipd join Ward_Definition wd on ipd.Ward_ID = wd.Ward_ID where ipd.Emergency_ID =" + Emergency_Id);
        //            pt.Admission_Date = DBClass.getField("Select Admission_Date from Emergency_Patient ipd  where ipd.Emergency_ID =" + Emergency_Id);
        //            pt.Discharge_On = DBClass.getField("Select Discharge_On from Emergency_Patient ipd  where ipd.Emergency_ID =" + Emergency_Id);
        //            pt.Bed_No = DBClass.getField("Select Bed_No from Emergency_Patient ipd where ipd.Emergency_ID =" + Emergency_Id);
        //            pt.MainDepartment = "02";
        //            pt.Department = "";
        //        }

        //        var inpatient_ids = DBClass.getField(
        //            "select top 1 In_Patient_ID from In_Patient " +
        //            "where Patient_ID = " + PatientID +
        //            " and isNull(Discharge,0) = 0 " +
        //            "order by In_Patient_ID desc"
        //        );
        //        if (inpatient_ids != null || inpatient_ids != "" || inpatient_ids != "There is no row at position 0.")
        //        {
        //            string type  = DBClass.getField("SELECT TOP 1 Patient_Discount_Type FROM In_Patient WHERE Patient_Id = " + PatientID + " ORDER BY Created_Time DESC")?.ToString() ?? "";
        //            pt.In_Patient_Type = db.GetDataValueName("Patient Type", type);
        //        }
       
             

        //        pt.Gender = db.GetDataValueName("Gender", pat.Gender);
        //        var Patientno = pat.Patient_No.ToString();
        //        var count = (db.Patients.Where(v => v.Patient_No == Convert.ToInt32(Patientno)).ToList());
        //        pt.Follow = count.Count.ToString();



        //        return pt;
        //    }
        //    else
        //        return pt;
        //}

        [WebMethod]
        public static string loadbillbypatient_id(int pat_id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var inpatid = (from ipd in db.In_Patients where ipd.Patient_ID == pat_id orderby ipd.Created_Time descending select ipd.In_Patient_ID).FirstOrDefault();

            if (inpatid == 0)
            {

                var Details = (from d in db.Ar_Billing_Details
                               join m in db.Ar_Billings
                                on d.Bill_ID equals m.Bill_ID
                               where m.Patient_ID == pat_id
                               && m.isCancel == false
                               && m.In_Patient_ID != 0
                               //&& ( d.Item_Type == "Item" || d.Item_Type == "Service")
                               select new
                               {
                                   d.Amount,
                                   d.Batch_No,
                                   d.Bill_Details_ID,
                                   d.Bill_ID,
                                   d.Category_ID,
                                   d.Discount_Amount,
                                   d.Discount_Percentage,
                                   d.Expiry_Date,
                                   d.Item_ID,
                                   d.Item_Name,
                                   d.Net_Amount,
                                   d.Item_Type,
                                   d.ParentTrans_ID,
                                   d.ParentTrans_Name,
                                   d.ParentTrans_Type,
                                   d.Qty,
                                   d.Remarks,
                                   d.Doctor_Share,
                                   d.RecommendedByDoctor,
                                   d.Service_Date,
                                   d.Hospital_Share,
                                   IsShare = DBClass.getField("select isnull(Is_ShareService,'0') as Is_ShareService  from Inv_Items where Item_id=" + d.Item_ID),
                                   Procedure_Required = DBClass.getField("select isnull(Procedure_Required,'0') as Procedure_Required from Inv_Items where Item_id=" + d.Item_ID),
                                   IsOpenBill = DBClass.getField("select isnull(Is_OpenBill,'0') as Is_OpenBill from Inv_Items where Item_id=" + d.Item_ID),
                                   d.Test_Main_Department,
                                   d.Is_Approval,
                                   m.BillType

                                   //                               IsShare
                                   //Procedure_Required
                                   //IsOpenBill

                               }).ToList();
                return (new JavaScriptSerializer()).Serialize(Details);
            }

            else
            {
                var Details = (from d in db.Ar_Billing_Details
                               join m in db.Ar_Billings
                                on d.Bill_ID equals m.Bill_ID
                               where m.In_Patient_ID == inpatid
                               && (m.isCancel == false || m.isCancel == null)
                               && m.In_Patient_ID != 0
                               //&& ( d.Item_Type == "Item" || d.Item_Type == "Service")
                               select new
                               {
                                   d.Amount,
                                   d.Batch_No,
                                   d.Bill_Details_ID,
                                   d.Bill_ID,
                                   d.Category_ID,
                                   d.Discount_Amount,
                                   d.Discount_Percentage,
                                   d.Expiry_Date,
                                   d.Item_ID,
                                   d.Item_Name,
                                   d.Net_Amount,
                                   d.Item_Type,
                                   d.ParentTrans_ID,
                                   d.ParentTrans_Name,
                                   d.ParentTrans_Type,
                                   d.Qty,
                                   d.Remarks,
                                   d.Doctor_Share,
                                   d.RecommendedByDoctor,
                                   d.Service_Date,
                                   d.Hospital_Share,
                                   IsShare = DBClass.getField("select isnull(Is_ShareService,'0') as Is_ShareService  from Inv_Items where Item_id=" + d.Item_ID),
                                   Procedure_Required = DBClass.getField("select isnull(Procedure_Required,'0') as Procedure_Required from Inv_Items where Item_id=" + d.Item_ID),
                                   IsOpenBill = DBClass.getField("select isnull(Is_OpenBill,'0') as Is_OpenBill from Inv_Items where Item_id=" + d.Item_ID),
                                   d.Test_Main_Department,
                                   d.Is_Approval,
                                   m.BillType
                               }).ToList();
                return (new JavaScriptSerializer()).Serialize(Details);
            }


        }


        public class PatientDetail
        {
            public string Name;
            public string Gender;
            public string Age;
            public string Patient_Type;
            public string Patient_Discount_Type;
            public string Mobile;
            public string NIC;
            public string Address;
            public string Entry_Date;
            public string Follow;
            public string Created_Time;
            public string Bed_No;
            public string Ward_Name;
            public string Room_Name;
            public string Room_No;
            public string refferedoc;
            public bool Discharge { get; set; }
            public bool isInpatient { get; set; }
            public bool Request_Discharge { get; set; }

            public string get_patientid { get; set; }
            public string Previous_inpatient { get; set; }
            public string OPD_Panel_ID { get; set; }
            public string MainDepartment { get; set; }
            public string opdid { get; set; }
            public string pat_id { get; set; }
            public string In_Patient_ID { get; set; }

            public string Department { get; set; }

            public string Bill_Department { get; set; }

            public string Cost_Center { get; set; }

            public string Admission_Date { get; set; }
            public string Discharge_On { get; set; }
            public string IPD_Panel_ID { get; set; }

            public string OPD_Panel_Name { get; set; }

            public string IPD_Panel_Name { get; set; }

            public string IsDisountAvailable { get; set; }

            public string DiscountPercFromMaster { get; set; }

            public string DiscountAmountFromMaster { get; set; }
            public string checkdischarge { get; set; }
            public string pkg_type { get; set; }
            public string pkg_name { get; set; }
            public string pkg_typefordetails { get; set; }
            public string pkg_namefordetails { get; set; }
            public string Package_Type { get; set; }
            public string Patient_Type_id { get; set; }
            public string In_Patient_Type { get; set; }
            public string Package_Name { get; set; }
            public string advance_amount { get; set; }
            public string paid_amount { get; set; }
            public string Balance { get; set; }
            public string PreviousTotalAmount { get; set; }
            public string InsuranceCardNo { get; set; }
            public string FatherName { get; set; }


        }
        [WebMethod]
        public static string GetPanelRateAndDiscount(string Item_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var query = (from pds in db.Panel_Detail_Services
                         join panel in db.Panels
                           on pds.Panel_ID equals panel.Panel_ID
                         where pds.Item_ID.Equals(Item_ID)
                         select new
                         {

                             panel.Discount,
                             pds.Rate,

                         }).FirstOrDefault();


            return (new JavaScriptSerializer()).Serialize(query);
        }
        [WebMethod]
        public static string GetPanelRateAndDiscountComplete()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var query = (from pds in db.Panel_Detail_Services
                         join panel in db.Panels
                           on pds.Panel_ID equals panel.Panel_ID
                         //where pds.Item_ID.Equals(Item_ID)
                         select new
                         {

                             panel.Discount,
                             pds.Rate,
                             pds.Item_ID,
                             panel.Panel_ID,
                         }).ToList();


            return (new JavaScriptSerializer()).Serialize(query);
        }
        [WebMethod]
        public static string GetPackageDetails(string PackType, int packname)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            List<TestPackageDetials> listOfTest = new List<TestPackageDetials>();

            if (PackType == "01")
            {
                var doc_pack = (from m in db.DoctorPackages
                                join d in db.Doctor_Packages_Detail_Rates
                                  on m.Doc_Packages_ID equals d.Doc_Packages_ID
                                where m.Doc_Packages_ID == packname
                                select new
                                {
                                    ParentTrans_ID = m.Doc_Packages_ID,
                                    ParentTrans_Name = m.Package_Name,
                                    ParentTrans_Type = "Doctor Package",
                                    d.Item_Code,
                                    Item_Name = (d.Item_Type.ToString() == "Test"
                                 ? (from test in db.Lab_Tests
                                    where test.Test_ID == d.Item_Code
                                    select test.Test_Name).FirstOrDefault()
                                 : (from item in db.INV_Items
                                    where item.Item_ID == d.Item_Code
                                    select item.Description).FirstOrDefault()),
                                    d.Category_ID,
                                    GroupName = (from dt in db.DataValues where dt.DataValue_Name == d.Category_ID && dt.ValueSet_ID == 70 select dt.DataValue_Description).FirstOrDefault(),
                                    d.Item_Type,
                                    d.Amount,
                                    m.Share_type
                                }).ToList();
                return (new JavaScriptSerializer()).Serialize(doc_pack);
            }
            else if (PackType == "02")
            {
                var Dep_pack = (from m in db.DepartmentPackages
                                join d in db.Department_Packages_Detail_Rates
                                  on m.Dep_Packages_ID equals d.Dep_Packages_ID
                                where m.Dep_Packages_ID == packname
                                select new
                                {
                                    ParentTrans_ID = m.Dep_Packages_ID,
                                    ParentTrans_Name = m.Package_Name,
                                    ParentTrans_Type = "Department Package",
                                    d.Item_Code,
                                    Item_Name = (d.Item_Type.ToString() == "Test"
                                 ? (from test in db.Lab_Tests
                                    where test.Test_ID == d.Item_Code
                                    select test.Test_Name).FirstOrDefault()
                                 : (from item in db.INV_Items
                                    where item.Item_ID == d.Item_Code
                                    select item.Description).FirstOrDefault()),
                                    d.Category_ID,
                                    GroupName = (from dt in db.DataValues where dt.DataValue_Name == d.Category_ID && dt.ValueSet_ID == 70 select dt.DataValue_Description).FirstOrDefault(),
                                    d.Item_Type,
                                    d.Amount,
                                    m.Share_type
                                }).ToList();
                return (new JavaScriptSerializer()).Serialize(Dep_pack);
            }
            else if (PackType == "03")
            {
                var Panel_pack = (from m in db.PanelPackages
                                  join d in db.Panel_Packages_Detail_Rates
                                    on m.Pan_Packages_ID equals d.Pan_Packages_ID
                                  where m.Pan_Packages_ID == packname
                                  select new
                                  {
                                      ParentTrans_ID = m.Pan_Packages_ID,
                                      ParentTrans_Name = m.Package_Name,
                                      ParentTrans_Type = "Panel Package",
                                      d.Item_Code,
                                      Item_Name = (d.Item_Type.ToString() == "Test"
                                 ? (from test in db.Lab_Tests
                                    where test.Test_ID == d.Item_Code
                                    select test.Test_Name).FirstOrDefault()
                                 : (from item in db.INV_Items
                                    where item.Item_ID == d.Item_Code
                                    select item.Description).FirstOrDefault()),
                                      d.Category_ID,
                                      GroupName = (from dt in db.DataValues where dt.DataValue_Name == d.Category_ID && dt.ValueSet_ID == 70 select dt.DataValue_Description).FirstOrDefault(),
                                      d.Item_Type,
                                      d.Amount,
                                      m.Share_type
                                  }).ToList();
                return (new JavaScriptSerializer()).Serialize(Panel_pack);
            }
            else
            {
                return (new JavaScriptSerializer()).Serialize(new { Error = "Invalid PackType" });
            }
        }

        [WebMethod]
        public static string CheckItemsinPackages(int PackType, int packname, int itemid)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var result = new { ItemExists = false, ItemName = (string)null }; // Default result structure

            if (PackType == 01)
            {
                var doc_pack = (from m in db.DoctorPackages
                                join d in db.Doctor_Packages_Detail_Rates
                                  on m.Doc_Packages_ID equals d.Doc_Packages_ID
                                where m.Doc_Packages_ID == packname &&
                                      d.Item_Code == itemid
                                select new
                                {
                                    Item_Name = (d.Item_Type.ToString() == "Test"
                                        ? (from test in db.Lab_Tests
                                           where test.Test_ID == d.Item_Code
                                           select test.Test_Name).FirstOrDefault()
                                        : (from item in db.INV_Items
                                           where item.Item_ID == d.Item_Code
                                           select item.Description).FirstOrDefault())
                                }).FirstOrDefault();

                bool itemExists = doc_pack != null;
                string itemName = doc_pack?.Item_Name;

                result = new { ItemExists = itemExists, ItemName = itemName };
            }
            else if (PackType == 02)
            {
                var dep_pack = (from m in db.DepartmentPackages
                                join d in db.Department_Packages_Detail_Rates
                                  on m.Dep_Packages_ID equals d.Dep_Packages_ID
                                where m.Dep_Packages_ID == packname &&
                                      d.Item_Code == itemid
                                select new
                                {
                                    Item_Name = (d.Item_Type.ToString() == "Test"
                                        ? (from test in db.Lab_Tests
                                           where test.Test_ID == d.Item_Code
                                           select test.Test_Name).FirstOrDefault()
                                        : (from item in db.INV_Items
                                           where item.Item_ID == d.Item_Code
                                           select item.Description).FirstOrDefault())
                                }).FirstOrDefault();

                bool itemExists = dep_pack != null;
                string itemName = dep_pack?.Item_Name;

                result = new { ItemExists = itemExists, ItemName = itemName };
            }
            else if (PackType == 03)
            {
                var panel_pack = (from m in db.PanelPackages
                                  join d in db.Panel_Packages_Detail_Rates
                                    on m.Pan_Packages_ID equals d.Pan_Packages_ID
                                  where m.Pan_Packages_ID == packname &&
                                        d.Item_Code == itemid
                                  select new
                                  {
                                      Item_Name = (d.Item_Type.ToString() == "Test"
                                        ? (from test in db.Lab_Tests
                                           where test.Test_ID == d.Item_Code
                                           select test.Test_Name).FirstOrDefault()
                                        : (from item in db.INV_Items
                                           where item.Item_ID == d.Item_Code
                                           select item.Description).FirstOrDefault())
                                  }).FirstOrDefault();

                bool itemExists = panel_pack != null;
                string itemName = panel_pack?.Item_Name;

                result = new { ItemExists = itemExists, ItemName = itemName };
            }

            return (new JavaScriptSerializer()).Serialize(result);
        }




        public class TestPackageDetials
        {
            public string ParentTrans_ID { get; set; }
            public string ParentTrans_Name { get; set; }
            public string ParentTrans_Type { get; set; }
            public string Item_ID { get; set; }
            public string Item_Name { get; set; }
            public string Item_Type { get; set; }
            public string Amount { get; set; }
            public string GroupName { get; set; }
        }

        [WebMethod]
        public static void MarkTestAsBilled(int LabTestDetail_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var test = db.Lab_Test_Details.Where(t => t.Lab_Test_Detail_ID == LabTestDetail_ID).FirstOrDefault();
            if (test != null)
            {
                test.IsBilled = true;
                test.ExcludeFrom_Payment = true;
                db.SubmitChanges();
            }
        }

        [WebMethod]
        public static void MarkTestAsUnBilled(int LabTestDetail_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var test = db.Lab_Test_Details.Where(t => t.Lab_Test_Detail_ID == LabTestDetail_ID).FirstOrDefault();
            if (test != null)
                test.IsBilled = false;
            db.SubmitChanges();
        }

        [WebMethod]
        public static void MarkTestAsExcludedFromPayment(int LabTestDetail_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var test = db.Lab_Test_Details.Where(t => t.Lab_Test_Detail_ID == LabTestDetail_ID).FirstOrDefault();
            if (test != null)
                test.ExcludeFrom_Payment = true;
            db.SubmitChanges();
        }
        [WebMethod]
        public static string GetProcedure(string deptID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var tests = (from t in db.Lab_Tests
                         where t.Main_Department == deptID
                         select new
                         {
                             t.Test_ID,
                             TestName = t.Test_Name,
                         }).Distinct().ToList();
            List<TestIDsAndGroupCategory> listOfTest = new List<TestIDsAndGroupCategory>();
            int counter = 1;
            foreach (var test in tests)
            {
                TestIDsAndGroupCategory obj = new TestIDsAndGroupCategory();
                obj.TestID = test.Test_ID.ToString();
                obj.TestName = test.TestName.ToString();
                obj.SerialNo = counter.ToString();
                obj.IsGroupCategory = false;

                listOfTest.Add(obj);
                counter++;
            }

            var listNew = (from t in db.DataValues
                           where t.Division == "005" && t.ValueSet_ID == 70
                           select new
                           {
                               Test_ID = t.DataValue_Name,
                               Test_Name = t.DataValue_Description

                           }).ToList();
            foreach (var category in listNew)
            {
                TestIDsAndGroupCategory obj = new TestIDsAndGroupCategory();
                obj.TestID = category.Test_ID.ToString();
                obj.TestName = category.Test_Name.ToString();
                obj.SerialNo = counter.ToString();
                obj.IsGroupCategory = true;
                obj.CategoryID = category.Test_ID;
                listOfTest.Add(obj);
                counter++;
            }
            return (new JavaScriptSerializer().Serialize(listOfTest));
        }
        [WebMethod]
        public static string GetLabTests()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            List<TestIDsAndGroupCategory> listOfTest = new List<TestIDsAndGroupCategory>();
            int counter = 1;
            var groupTests = from t in db.Lab_Tests
                             where t.Main_Department == "001" && t.Active == true && t.Group_Category != ""
                             select new { t.Test_ID, t.Test_Name, t.Group_Category };

            foreach (var test in groupTests)
            {
                TestIDsAndGroupCategory obj = new TestIDsAndGroupCategory();
                obj.TestID = test.Test_ID.ToString();
                obj.TestName = test.Test_Name + " | " +
                               DBClass.getField("select DataValue_Description from DataValues where DataValue_Name = '" + test.Group_Category + "' and ValueSet_ID = 70");
                obj.SerialNo = counter.ToString();
                obj.IsGroupCategory = false;
                listOfTest.Add(obj);
                counter++;
            }
            var singleTests = from t in db.Lab_Tests
                              where t.Main_Department == "001" && t.Active == true && (t.Group_Category == "" || t.Group_Category == null)
                              select new { t.Test_ID, t.Test_Name };

            foreach (var test in singleTests)
            {
                TestIDsAndGroupCategory obj = new TestIDsAndGroupCategory();
                obj.TestID = test.Test_ID.ToString();
                obj.TestName = test.Test_Name;
                obj.SerialNo = counter.ToString();
                obj.IsGroupCategory = false;
                listOfTest.Add(obj);
                counter++;
            }

            var GroupCategories = from dv in db.DataValues
                                  join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                                  where vs.ValueSet_Name == "Test Groups" && dv.Division == "001"
                                  select new { dv.DataValue_Name, dv.DataValue_Description };

            foreach (var category in GroupCategories)
            {
                TestIDsAndGroupCategory obj = new TestIDsAndGroupCategory();
                obj.TestID = category.DataValue_Name;
                obj.TestName = category.DataValue_Description;
                obj.SerialNo = counter.ToString();
                obj.IsGroupCategory = true;
                obj.CategoryID = category.DataValue_Name;
                listOfTest.Add(obj);
                counter++;
            }

            return (new JavaScriptSerializer()).Serialize(listOfTest);
        }

        
        public class TestIDsAndGroupCategory
        {
            public string Rate { get; set; }
            public string TestID { get; set; }
            public string TestName { get; set; }
            public string SerialNo { get; set; }
            public string CategoryID { get; set; }
            public bool IsGroupCategory { get; set; }
            public string GroupName { get; set; }
            public string MainDepartmentName { get; set; }
        }

        [WebMethod]
        public static string FillTestsByCategory(string CategoryID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var tests = from t in db.Lab_Tests
                        where t.Main_Department == CategoryID && t.Active == true
                        select new { t.Test_ID, t.Test_Name };

            return (new JavaScriptSerializer()).Serialize(tests);
        }
        [WebMethod]
        public static string LoadITemsForPackage(string PatientID, string item_id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var query = (from t in db.Packages
                         where t.Packages_ID == Convert.ToInt32(item_id)
                         select new
                         {
                             Disc = DBClass.getField("select b.Discount_Percentage from Discount_Assigned_Patient a join Discount_Assigned_Patient_Detail b on a.Discount_Assigned_Patient_Id = b.Discount_Assigned_Patient_Id where a.Patient_Id = '" + PatientID + "' and b.Department_Type='Package'  and  CAST(b.Valid_for AS Datetime) >= CAST(GETDATE() AS Datetime) and isnull(isdischarge,0)=0"),
                             Total_Disc_Amt = DBClass.getField("select case when b.Remaining_Amount='0.00' then b.Discount_Amount else (b.Discount_Amount-b.Remaining_Amount) end from Discount_Assigned_Patient a join Discount_Assigned_Patient_Detail b on a.Discount_Assigned_Patient_Id = b.Discount_Assigned_Patient_Id where a.Patient_Id = '" + PatientID + "' and b.Department_Type='Package'  and  CAST(b.Valid_for AS Datetime) >= CAST(GETDATE() AS Datetime) and isnull(isdischarge,0)=0"),
                             Remaining_Amount = DBClass.getField("select b.Remaining_Amount from Discount_Assigned_Patient a join Discount_Assigned_Patient_Detail b on a.Discount_Assigned_Patient_Id = b.Discount_Assigned_Patient_Id where a.Patient_Id = '" + PatientID + "' and b.Department_Type='Package'  and convert(varchar, b.Valid_for, 1) >= convert(varchar, getdate(), 1) and isnull(isdischarge,0)=0"),
                         }).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(query);
        }
        [WebMethod]
        public static string LoadITemsForDiscount(string PatientID, string item_id)

        {
            DataBaseDataContext db = new DataBaseDataContext();
            var query = (from t in db.INV_Items
                         where t.Item_ID == Convert.ToInt32(item_id)
                         select new
                         {
                             t.Hospital_Services,
                             t.Procedure_types,
                             t.Services,

                             Disc = DBClass.getField("select b.Discount_Percentage from Discount_Assigned_Patient a join Discount_Assigned_Patient_Detail b on a.Discount_Assigned_Patient_Id = b.Discount_Assigned_Patient_Id where a.Patient_Id = '" + PatientID + "' and b.Department_Type='Item'  and  CAST(b.Valid_for AS Date) >= CAST(GETDATE() AS Date) and isnull(isdischarge,0)=0"),

                             Total_Disc_Amt = DBClass.getField("select case when b.Remaining_Amount='0.00' then b.Discount_Amount else (b.Discount_Amount-b.Remaining_Amount) end from Discount_Assigned_Patient a join Discount_Assigned_Patient_Detail b on a.Discount_Assigned_Patient_Id = b.Discount_Assigned_Patient_Id where a.Patient_Id = '" + PatientID + "' and b.Department_Type='Item'  and  CAST(b.Valid_for AS Date) >= CAST(GETDATE() AS Date) and isnull(isdischarge,0)=0"),

                             Disc_Pro = DBClass.getField("select b.Discount_Percentage from Discount_Assigned_Patient a join Discount_Assigned_Patient_Detail b on a.Discount_Assigned_Patient_Id = b.Discount_Assigned_Patient_Id where a.Patient_Id = '" + PatientID + "' and b.Department_Type='Procedure'  and  CAST(b.Valid_for AS Date) >= CAST(GETDATE() AS Date) and isnull(isdischarge,0)=0"),

                             Total_Disc_Amt_Pro = DBClass.getField("select case when b.Remaining_Amount='0.00' then b.Discount_Amount else (b.Discount_Amount-b.Remaining_Amount) end from Discount_Assigned_Patient a join Discount_Assigned_Patient_Detail b on a.Discount_Assigned_Patient_Id = b.Discount_Assigned_Patient_Id where a.Patient_Id = '" + PatientID + "' and b.Department_Type='Procedure'  and  CAST(b.Valid_for AS Date) >= CAST(GETDATE() AS Date) and isnull(isdischarge,0)=0"),

                             Remaining_Amount = DBClass.getField("select b.Remaining_Amount from Discount_Assigned_Patient a join Discount_Assigned_Patient_Detail b on a.Discount_Assigned_Patient_Id = b.Discount_Assigned_Patient_Id where a.Patient_Id = '" + PatientID + "' and b.Department_Type='Item'  and  CAST(b.Valid_for AS Date) >= CAST(GETDATE() AS Date) and isnull(isdischarge,0)=0"),


                         }).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(query);
        }
        [WebMethod]
        public static string GetTestMainDepartmentDetails(int TestID, string maindpt, string pat_id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var TestMainDepartmentName = (from t in db.Lab_Tests
                                          where t.Test_ID == TestID && t.Active == true
                                          select new
                                          {
                                              MainDepartment = db.GetDataValueName("Main Test Departments", t.Main_Department.ToString()).ToString(),
                                              Rate = ((from td in db.Lab_Tests where td.Test_ID == TestID select td.Rate).FirstOrDefault()),
                                              t.Test_Name,
                                              Category_ID = t.Group_Category,
                                              Disc = DBClass.getField("select b.Discount_Percentage from Discount_Assigned_Patient a join Discount_Assigned_Patient_Detail b on a.Discount_Assigned_Patient_Id = b.Discount_Assigned_Patient_Id where a.Patient_Id = '" + pat_id + "' and b.Department_Id ='" + maindpt + "' and  CAST(b.Valid_for AS Date) >= CAST(GETDATE() AS Date) and isnull(isdischarge,0)=0"),
                                              Total_Disc_Amt = DBClass.getField("select case when b.Remaining_Amount='0.00' then b.Discount_Amount else (b.Discount_Amount-b.Remaining_Amount) end  from Discount_Assigned_Patient a join Discount_Assigned_Patient_Detail b on a.Discount_Assigned_Patient_Id = b.Discount_Assigned_Patient_Id where a.Patient_Id = '" + pat_id + "' and b.Department_Id ='" + maindpt + "' and  CAST(b.Valid_for AS Date) >= CAST(GETDATE() AS Date) and isnull(isdischarge,0)=0"),
                                              Remaining_Amount = DBClass.getField("select b.Remaining_Amount  from Discount_Assigned_Patient a join Discount_Assigned_Patient_Detail b on a.Discount_Assigned_Patient_Id = b.Discount_Assigned_Patient_Id where a.Patient_Id = '" + pat_id + "' and b.Department_Id ='" + maindpt + "' and  CAST(b.Valid_for AS Date) >= CAST(GETDATE() AS Date) and isnull(isdischarge,0)=0"),
                                              Depart_ID = t.Main_Department
                                          }).ToList();
            return (new JavaScriptSerializer().Serialize(TestMainDepartmentName));
        }
        [WebMethod]
        public static bool IsPatientExistInOPD(string PatientID)
        {
            bool isExist = false;
            DataBaseDataContext db = new DataBaseDataContext();
            var query = (from data in db.Out_Patients.Where(x => x.Patient_ID == Convert.ToInt32(PatientID) && x.Discharge == false) select data.Patient_ID).ToList();
            if (query.Count > 0)
            {
                isExist = true;
            }
            else
            {
                isExist = false;
            }

            return isExist;

        }

        [WebMethod]
        public static string GetLabTestDDLDetails(string SerialNo, string maindpt, string pat_id)
        {
            string groupCategory = string.Empty;
            string testName = SerialNo;

            string[] testFullName = SerialNo.Split('|');
            if (testFullName.Length > 1)
            {
                testName = testFullName[0];
                groupCategory = DBClass.getField("select Datavalue_Name from Datavalues where valueset_ID = 70 and Datavalue_Description = '" + testFullName[1].Trim() + "'").ToString();
            }

            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var test = (from t in db.Lab_Tests
                        where t.Main_Department == maindpt && t.Test_Name == testName && t.Group_Category == groupCategory
                        select new
                        {
                            t.Test_ID,
                            t.Rate,
                            Test_Name = SerialNo,
                            t.Group_Category,
                            TestMainDepartmentName = db.GetDataValueName("Main Test Departments", t.Main_Department.ToString()).ToString(),
                            GroupCategoryName = db.GetDataValueName("Test Groups", t.Group_Category.ToString()).ToString(),
                            Disc = DBClass.getField("select b.Discount_Percentage from Discount_Assigned_Patient a join Discount_Assigned_Patient_Detail b on a.Discount_Assigned_Patient_Id = b.Discount_Assigned_Patient_Id where a.Patient_Id = '" + pat_id + "' and b.Department_Id ='" + maindpt + "' and  CAST(b.Valid_for AS Date) >= CAST(GETDATE() AS Date) and isnull(isdischarge,0)=0"),
                            Total_Disc_Amt = DBClass.getField("select case when b.Remaining_Amount='0.00' then b.Discount_Amount  else (b.Discount_Amount-b.Remaining_Amount) end  from Discount_Assigned_Patient a join Discount_Assigned_Patient_Detail b on a.Discount_Assigned_Patient_Id = b.Discount_Assigned_Patient_Id where a.Patient_Id = '" + pat_id + "' and b.Department_Id ='" + maindpt + "' and  CAST(b.Valid_for AS Date) >= CAST(GETDATE() AS Date) and isnull(isdischarge,0)=0"),
                            Remaining_Amount = DBClass.getField("select b.Remaining_Amount  from Discount_Assigned_Patient a join Discount_Assigned_Patient_Detail b on a.Discount_Assigned_Patient_Id = b.Discount_Assigned_Patient_Id where a.Patient_Id = '" + pat_id + "' and b.Department_Id ='" + maindpt + "' and  CAST(b.Valid_for AS Date) >= CAST(GETDATE() AS Date) and isnull(isdischarge,0)=0"),


                        }).ToList();
            var count = test.Count;

            if (count != 0)
            {

                return (new JavaScriptSerializer()).Serialize(test);

            }
            else
            {
                var GroupCategories = (from dv in db.DataValues
                                       join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                                       where vs.ValueSet_Name == "Test Groups" && dv.DataValue_Description == SerialNo
                                       select new
                                       {
                                           Test_ID = 0,
                                           Group_Category = dv.DataValue_Name,
                                           Test_Name = dv.DataValue_Description,
                                           TestMainDepartmentName = "Lab Test",
                                           Main_Department = "001",
                                           Rate = dv.Segment1,
                                           Disc = DBClass.getField("select  b.Discount_Percentage  from Discount_Assigned_Patient a join Discount_Assigned_Patient_Detail b on a.Discount_Assigned_Patient_Id = b.Discount_Assigned_Patient_Id where a.Patient_Id = '" + pat_id + "' and b.Department_Id ='" + maindpt + "' and  CAST(b.Valid_for AS Date) >= CAST(GETDATE() AS Date) and isnull(isdischarge,0)=0"),
                                           Total_Disc_Amt = DBClass.getField("select case when b.Remaining_Amount='0.00' then b.Discount_Amount else (b.Discount_Amount-b.Remaining_Amount) end from Discount_Assigned_Patient a join Discount_Assigned_Patient_Detail b on a.Discount_Assigned_Patient_Id = b.Discount_Assigned_Patient_Id where a.Patient_Id = '" + pat_id + "' and b.Department_Id ='" + maindpt + "' and  CAST(b.Valid_for AS Date) >= CAST(GETDATE() AS Date) and isnull(isdischarge,0)=0"),
                                           Remaining_Amount = DBClass.getField("select b.Remaining_Amount  from Discount_Assigned_Patient a join Discount_Assigned_Patient_Detail b on a.Discount_Assigned_Patient_Id = b.Discount_Assigned_Patient_Id where a.Patient_Id = '" + pat_id + "' and b.Department_Id ='" + maindpt + "' and  CAST(b.Valid_for AS Date) >= CAST(GETDATE() AS Date) and isnull(isdischarge,0)=0"),

                                       }).ToList();
                return (new JavaScriptSerializer()).Serialize(GroupCategories);
            }
        }

        [WebMethod]
        public static string PrintBillingDetail(int Bill_ID)
        {
            List<TestDetailsForOPDrpt> AlltestList = new List<TestDetailsForOPDrpt>();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var PatCase = (from billD in db.Ar_Billing_Details
                           where billD.Bill_ID == Bill_ID
                           select new
                           {

                               billD.Item_ID,
                               billD.Item_Name,
                               billD.Item_Type,
                               billD.Amount,
                               billD.Discount_Percentage,
                               billD.Discount_Amount,
                               billD.Net_Amount,
                               billD.ParentTrans_Name,
                               Lab_test = (from t in db.Lab_Tests where t.Test_ID == billD.Item_ID select t.Main_Department).FirstOrDefault(),
                               Group_Category = (from t in db.Lab_Tests where t.Test_ID == billD.Item_ID select t.Group_Category).FirstOrDefault(),
                               Report_Timing = (from t in db.Lab_Tests where t.Test_ID == billD.Item_ID select t.Reporting_Time).FirstOrDefault(),
                               Group_Report_Timing = (from dt in db.DataValues where dt.DataValue_Name == billD.Category_ID && dt.ValueSet_ID == 70 select dt.Segment3).FirstOrDefault(),
                               RptTime = (from t in db.Lab_Tests where t.Test_ID == billD.Item_ID select t.Reporting_Day).FirstOrDefault(),
                               Grouptime = DBClass.getField("select dt.DataValue_Description from DataValues dt where ValueSet_ID = 2124 and dt.DataValue_Name = (select dt.Segment4 from DataValues dt where ValueSet_ID = 70 and dt.DataValue_Name ='" + billD.Category_ID + "')"),
                               //TimeIndays = (from dt in db.DataValues where dt.DataValue_Name.Equals(RptTime) && dt.ValueSet_ID == 2124 select dt.DataValue_Description).FirstOrDefault(),
                               TimeIndays = DBClass.getField("select dt.DataValue_Description from DataValues dt where ValueSet_ID = 2124 and dt.DataValue_Name =(select Reporting_Day from Lab_Tests lt where  lt.test_id='" + billD.Item_ID + "')")


                           }).ToList();


            foreach (var item in PatCase)
            {
                TestDetailsForOPDrpt test = new TestDetailsForOPDrpt();
                test.Item_ID = item.Item_ID.ToString();
                test.Item_Name = item.Item_Name;
                test.Item_Type = item.Item_Type.ToString();
                test.ParentTrans_Name = item.ParentTrans_Name;
                test.Group_Category = item.Group_Category;
                test.MainDepartment = item.Lab_test;
                if (item.TimeIndays.Contains("position"))
                {
                    test.RptTime = "";
                }
                else
                {
                    test.RptTime = item.TimeIndays;
                }
                if (item.Grouptime.Contains("There is no row at position 0."))
                {
                    test.Grouptime = "";
                }
                else
                {
                    test.Grouptime = item.Grouptime;
                }

                if (item.Report_Timing != null)
                {
                    test.Report_Timing = item.Report_Timing.ToString() + '-' + test.RptTime.ToString();
                }
                else if (item.Report_Timing == null)
                {
                    test.Report_Timing = item.Group_Report_Timing + '-' + test.Grouptime.ToString();
                }
                else
                {
                    test.Report_Timing = "";
                }

                test.Amount = (decimal)item.Amount;
                test.Discount_Amount = (decimal)item.Discount_Amount;
                test.Net_Amount = (decimal)item.Net_Amount;

                AlltestList.Add(test);
            }

            List<TestDetailsForOPDrpt> AlltestListRefined = new List<TestDetailsForOPDrpt>();
            AlltestListRefined = AlltestList;

            var NoOfTestsCateWise = (from lbtsts in db.Lab_Tests
                                     where lbtsts.Group_Category != "" && lbtsts.Group_Category != null
                                     group lbtsts by lbtsts.Group_Category into g
                                     select new
                                     {
                                         CategoryID = g.Key,
                                         Category = db.GetDataValueName("Test Groups", g.Key),
                                         testsCount = g.Count(),
                                         MainDepartment = (from tbl in db.Lab_Tests
                                                           where tbl.Group_Category == g.Key
                                                           select new { DepartmentName = (db.GetDataValueName("Main Test Departments", tbl.Main_Department) == null ? "" : db.GetDataValueName("Main Test Departments", tbl.Main_Department)) }
                                                          ).FirstOrDefault().DepartmentName.ToString(),

                                     }
                      ).ToList();

            var NoOfPackges = (from pkg in db.Packages
                               select new
                               {
                                   pkg.Package_Name
                               }
                                ).ToList();

            foreach (var item in NoOfPackges)
            {
                int CatewisetestsCount = PatCase.Where(t => t.ParentTrans_Name == item.Package_Name).Count();
                if (CatewisetestsCount > 0)
                {
                    AlltestListRefined.RemoveAll(t => t.ParentTrans_Name == item.Package_Name);
                    AlltestListRefined.Add(new TestDetailsForOPDrpt()
                    {
                        Item_Name = item.Package_Name,
                        Item_Type = "Test",
                        Amount = (decimal)PatCase.Where(r => r.ParentTrans_Name == item.Package_Name).Sum(r => r.Amount),
                        Discount_Amount = (decimal)PatCase.Where(r => r.ParentTrans_Name == item.Package_Name).Sum(r => r.Discount_Amount),

                        Net_Amount = (decimal)PatCase.Where(r => r.ParentTrans_Name == item.Package_Name).Sum(r => r.Net_Amount)
                    });
                }
            }
            return ((new JavaScriptSerializer()).Serialize(AlltestListRefined));
        }
        public class
            TestDetailsForOPDrpt
        {
            public string Item_ID;
            public string Item_Name;
            public string Item_Type;
            public string ParentTrans_Name;
            public decimal Amount;
            public decimal Discount_Percentage;
            public decimal Discount_Amount;
            public decimal Net_Amount;
            public string RptTime;
            public string Grouptime;
            public string Group_Category { get; set; }
            public string Report_Timing { get; set; }
            public decimal Group_Report_Timing { get; set; }

            public string MainDepartment { get; set; }

        }

        //report code 
        [WebMethod]
        public static string GetRotationsCategoryWise(string testCategory)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var dep = from dv in db.DataValues
                      join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                      where vs.ValueSet_Name == testCategory
                      select new { dv.DataValue_Name, dv.DataValue_Description };

            return (new JavaScriptSerializer()).Serialize(dep);
        }
        [WebMethod]
        public static string GetOpdId(string Patient_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var OPd_Pat_Id = (from rg in db.Reg_patients
                              join p in db.Patients on rg.pat_id equals p.Reg_PatId
                              where rg.pat_id == Convert.ToInt32(Patient_ID)
                              orderby p.Created_Time descending
                              select new { p.Patient_ID }).Take(1).FirstOrDefault();

            return (new JavaScriptSerializer()).Serialize(OPd_Pat_Id);
        }


        #region "GL Voucher Entry"

        public class Detail
        {
            public int Item_ID;
            public string Item_Name;
            public string Item_Type;
            public decimal Amount;
            public decimal Discount_Percentage;
            public decimal Discount_Amount;
            public decimal Net_Amount;
            public bool RecommendedByDoctor;
            public int ParentTrans_ID;
            public string ParentTrans_Name;
            public string ParentTrans_Type;
            public bool Liability_Item;
            public bool LabOR_RadiologyCharges;
            public bool Services;
        }

        public static void InsertVoucher(int Bill_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            //Int32 Receivable_Account = DBClass.GetAccountIDFromCode(DBClass.getParameter("Receivable_Account"));

            var Header = db.Ar_Billings.Where(bm => bm.Bill_ID == Bill_ID).FirstOrDefault();

            var TestDetails = (from d in db.Ar_Billing_Details
                               join m in db.Ar_Billings
                                on d.Bill_ID equals m.Bill_ID
                               where m.Bill_ID == Bill_ID && d.Item_Type == "Test"
                               select new { d.Item_ID, d.Item_Name, d.Item_Type, d.Amount, d.Discount_Percentage, d.Discount_Amount, d.Net_Amount, d.RecommendedByDoctor, d.ParentTrans_ID, d.ParentTrans_Name, d.ParentTrans_Type, Liability_Item = false, LabOR_RadiologyCharges = false, Services = false }).ToList();

            var Details = (from d in db.Ar_Billing_Details
                           join m in db.Ar_Billings
                            on d.Bill_ID equals m.Bill_ID
                           join itms in db.INV_Items
                           on d.Item_ID equals itms.Item_ID
                           where m.Bill_ID == Bill_ID && d.Item_Type != "Test"
                           select new { d.Item_ID, d.Item_Name, d.Item_Type, d.Amount, d.Discount_Percentage, d.Discount_Amount, d.Net_Amount, d.RecommendedByDoctor, d.ParentTrans_ID, d.ParentTrans_Name, d.ParentTrans_Type, itms.Liability_Item, itms.LabOR_RadiologyCharges, itms.Services }).ToList();

            List<Detail> DetailsList = new List<Detail>();

            // Creating List Of Details For further use in voucher.

            foreach (var item in TestDetails)
            {
                Detail dtl = new Detail();
                dtl.Item_ID = (int)item.Item_ID;
                dtl.Item_Name = item.Item_Name;
                dtl.Item_Type = item.Item_Type;
                dtl.Amount = (decimal)item.Amount;
                dtl.Discount_Percentage = (decimal)item.Discount_Percentage;
                dtl.Discount_Amount = (decimal)item.Discount_Amount;
                dtl.Net_Amount = (decimal)item.Net_Amount;
                dtl.RecommendedByDoctor = (bool)item.RecommendedByDoctor;
                dtl.ParentTrans_ID = (int)item.ParentTrans_ID;
                dtl.ParentTrans_Name = item.ParentTrans_Name;
                dtl.ParentTrans_Type = item.ParentTrans_Type;
                dtl.Liability_Item = item.Liability_Item;
                dtl.LabOR_RadiologyCharges = item.LabOR_RadiologyCharges;
                dtl.Services = item.Services;
                DetailsList.Add(dtl);
            }

            foreach (var item in Details)
            {
                Detail dtl = new Detail();
                dtl.Item_ID = (int)item.Item_ID;
                dtl.Item_Name = item.Item_Name;
                dtl.Item_Type = item.Item_Type;
                dtl.Amount = (decimal)item.Amount;
                dtl.Discount_Percentage = (decimal)item.Discount_Percentage;
                dtl.Discount_Amount = (decimal)item.Discount_Amount;
                dtl.Net_Amount = (decimal)item.Net_Amount;
                dtl.RecommendedByDoctor = (bool)item.RecommendedByDoctor;
                dtl.ParentTrans_ID = (int)item.ParentTrans_ID;
                dtl.ParentTrans_Name = item.ParentTrans_Name;
                dtl.ParentTrans_Type = item.ParentTrans_Type;
                dtl.Liability_Item = (bool)item.Liability_Item;
                dtl.LabOR_RadiologyCharges = (bool)item.LabOR_RadiologyCharges;
                dtl.Services = (bool)item.Services;
                DetailsList.Add(dtl);
            }



            var PatientDetails = (from p in db.Patients
                                  where p.Patient_ID == Header.Patient_ID
                                  select p
                ).FirstOrDefault();

            var PatientDepartment = db.GetDataValueName("Patient Main Category", PatientDetails.Patient_Main_Category);

            var PatientType = db.GetDataValueName("Patient Type", PatientDetails.Patient_Type);

            string Remarks = "Auto General Ledger Entry for Bill No:- " + Header.Bill_No;

            GL_Voucher gvm;

            #region "Checking Voucher Header"

            if (Header.Voucher_ID != null)
            {
                gvm = (from vm in db.GL_Vouchers
                       where vm.Voucher_ID == Header.Voucher_ID
                       select vm).FirstOrDefault();
                if (gvm != null)
                {

                    gvm.Updated_By = AppConfig.UserID;
                    gvm.Update_Time = Convert.ToDateTime(DateTime.Now.ToString(AppConfig.DateFormat));
                    gvm.Approved_By = AppConfig.UserID;
                    gvm.Approved_Time = Convert.ToDateTime(DateTime.Now.ToString(AppConfig.DateFormat));
                }
                else
                {

                    /*******Inserting new Voucher Header*****************/

                    int VoucherNo = DBClass.GetNewVoucherNo("Bill", DateTime.Now);
                    string PeriodID = DBClass.getField("select Period_ID from GL_Periods where '" + DateTime.Now.ToString("yyyy-MM-dd") + "' between Period_start_date and Period_end_date").ToString();
                    gvm = new GL_Voucher();
                    gvm.Voucher_Type = "Bill";
                    gvm.Voucher_No = VoucherNo;
                    gvm.Remarks = Remarks;
                    gvm.Company_ID = AppConfig.Company_ID;
                    gvm.Period_ID = PeriodID;
                    gvm.Voucher_Status = "Approved";
                    gvm.Voucher_Date = Convert.ToDateTime(DateTime.Now.ToString("yyyy-MM-dd"));
                    gvm.Created_By = AppConfig.UserID;
                    gvm.Creation_Time = Convert.ToDateTime(DateTime.Now.ToString(AppConfig.DateFormat));
                    gvm.Updated_By = AppConfig.UserID;
                    gvm.Update_Time = Convert.ToDateTime(DateTime.Now.ToString(AppConfig.DateFormat));
                    gvm.Approved_By = AppConfig.UserID;
                    gvm.Approved_Time = Convert.ToDateTime(DateTime.Now.ToString(AppConfig.DateFormat));
                    gvm.Closing = false;
                    gvm.Cancel = false;
                    db.GL_Vouchers.InsertOnSubmit(gvm);
                    db.SubmitChanges();
                }
            }
            else
            {
                /*******Inserting new Voucher Header*****************/

                int VoucherNo = DBClass.GetNewVoucherNo("Bill", DateTime.Now);
                string PeriodID = DBClass.getField("select Period_ID from GL_Periods where '" + DateTime.Now.ToString("yyyy-MM-dd") + "' between Period_start_date and Period_end_date").ToString();
                gvm = new GL_Voucher();
                gvm.Voucher_Type = "Bill";
                gvm.Voucher_No = VoucherNo;
                gvm.Remarks = Remarks;
                gvm.Company_ID = AppConfig.Company_ID;
                gvm.Period_ID = PeriodID;
                gvm.Voucher_Status = "Approved";
                gvm.Voucher_Date = Convert.ToDateTime(DateTime.Now.ToString("yyyy-MM-dd"));
                gvm.Created_By = AppConfig.UserID;
                gvm.Creation_Time = Convert.ToDateTime(DateTime.Now.ToString(AppConfig.DateFormat));
                gvm.Updated_By = AppConfig.UserID;
                gvm.Update_Time = Convert.ToDateTime(DateTime.Now.ToString(AppConfig.DateFormat));
                gvm.Approved_By = AppConfig.UserID;
                gvm.Approved_Time = Convert.ToDateTime(DateTime.Now.ToString(AppConfig.DateFormat));
                gvm.Closing = false;
                gvm.Cancel = false;
                db.GL_Vouchers.InsertOnSubmit(gvm);
                db.SubmitChanges();
            }

            #endregion

            #region "Deleting Previous Details"
            if (Header != null)
            {
                List<GL_Voucher_Account> OldVoucherDetails = db.GL_Voucher_Accounts.Where(v => v.Voucher_ID == Convert.ToInt32(Header.Voucher_ID)).ToList();
                db.GL_Voucher_Accounts.DeleteAllOnSubmit(OldVoucherDetails);
                db.SubmitChanges();
            }
            #endregion

            /***Updating voucher id in Bill Header****/

            if (Header != null)
                Header.Voucher_ID = Convert.ToInt32(gvm.Voucher_ID);


            #region "Inserting Details in Different Departments and in Cash Account"

            decimal NetAmount = 0;
            decimal PoolShare = 0;

            foreach (var item in DetailsList)
            {
                NetAmount = 0;
                PoolShare = 0;

                if (item.ParentTrans_Type != "Package")
                {
                    #region "Entry for OPD / Front Desk Investigation"

                    // If the item is just investigation from OPD Or from front desk....

                    // Checking that is there is any share due for this Item Transaction.

                    bool IsRadialogyShare = true, IsPhysioShare = false, IsDentalShare = false, IsDermaShare = false;

                    var Radialogy_SharePercentage = DBClass.getParameter("Radialogy_Share_Percentage");

                    var PhysioShare_Percentage = DBClass.getParameter("Physio_Share_Percentage");
                    var DentalShare_Percentage = DBClass.getParameter("Dental_Share_Percentage");
                    var DermaShare_Percentage = DBClass.getParameter("Derma_Share_Percentage");

                    if (item.Item_Type == "Test")
                    {
                        var TestMainDepartment = (from tdfn in db.Lab_Tests
                                                  where tdfn.Test_ID == item.Item_ID
                                                  select tdfn.Main_Department).FirstOrDefault();


                        TestMainDepartment = db.GetDataValueName("Test Main Department", TestMainDepartment);
                        if (TestMainDepartment == null)
                        {
                            IsRadialogyShare = false;
                        }
                        if (TestMainDepartment == "Lab Test")
                        {
                            IsRadialogyShare = false;
                        }
                    }
                    else if (item.Item_Type != "Test")
                    {
                        var itemDetails = (from itm in db.INV_Items
                                           where itm.Item_ID == item.Item_ID
                                           select itm).FirstOrDefault();
                        IsPhysioShare = itemDetails.Physio_Item.Value;
                        IsDentalShare = itemDetails.Dental_Item.Value;
                        IsDermaShare = itemDetails.Derma_Item.Value;
                    }

                    if (item.Item_Type != "Test")
                        IsRadialogyShare = false;

                    // Receivable Entry Item Wise....

                    if (Convert.ToDecimal(item.Net_Amount) > 0)
                    {

                        //InsertVoucherLine(Convert.ToInt32(Header.Bill_No), Receivable_Account, Convert.ToDecimal(item.Net_Amount), 0, Convert.ToInt32(gvm.Voucher_ID), "Receivable Entry for " + item.Item_Name + "  " + Remarks.ToString(), Convert.ToInt32(item.Item_ID), item.Item_Type, "Bill", 0);
                    }

                    // Discount Entry....

                    if (Convert.ToDecimal(item.Discount_Amount) > 0)
                    {
                        //InsertVoucherLine(Convert.ToInt32(Header.Bill_No), GetAccountID(PatientType.ToString(), PatientDetails.Patient_Type, PatientDetails.Patient_Main_Category, Convert.ToInt32(item.Item_ID), item.Item_Type, false, false), Convert.ToDecimal(item.Discount_Amount), 0, Convert.ToInt32(gvm.Voucher_ID), "Discount Entry for " + item.Item_Name + "  " + Remarks.ToString(), Convert.ToInt32(item.Item_ID), item.Item_Type, "Bill", 0);
                    }

                    // Entry in Radiology Pool...
                    if (Convert.ToDecimal(item.Amount) > 0 && IsRadialogyShare && item.Item_Type == "Test")
                    {
                        NetAmount = Convert.ToDecimal(item.Amount - item.Discount_Amount);
                        PoolShare = NetAmount / 100 * Convert.ToDecimal(Radialogy_SharePercentage);

                        InsertVoucherLine(Convert.ToInt32(Header.Bill_No), GetSharedAccounts("Radialogy_Share"), 0, Convert.ToDecimal(PoolShare), Convert.ToInt32(gvm.Voucher_ID), "Radialogy Share Entry for " + item.Item_Name + "  " + Remarks.ToString(), Convert.ToInt32(item.Item_ID), item.Item_Type, "Bill", (int)Header.Doctor_ID);
                    }

                    // Entry in Department...
                    if (Convert.ToDecimal(item.Amount) > 0 && IsRadialogyShare && item.Item_Type == "Test")
                    {
                        NetAmount = Convert.ToDecimal(item.Amount - item.Discount_Amount);
                        PoolShare = NetAmount / 100 * Convert.ToDecimal(Radialogy_SharePercentage);

                        InsertVoucherLine(Convert.ToInt32(Header.Bill_No), GetAccountID(PatientType.ToString(), PatientDetails.Patient_Type, PatientDetails.Patient_Main_Category, Convert.ToInt32(item.Item_ID), item.Item_Type, false, false), 0, Convert.ToDecimal(item.Amount - PoolShare), Convert.ToInt32(gvm.Voucher_ID), "Cash Entry for " + item.Item_Name + "  " + Remarks.ToString(), Convert.ToInt32(item.Item_ID), item.Item_Type, "Bill", 0);
                    }

                    // Entry in Physio Pool...
                    if (Convert.ToDecimal(item.Amount) > 0 && IsPhysioShare)
                    {
                        NetAmount = Convert.ToDecimal(item.Amount - item.Discount_Amount);
                        PoolShare = NetAmount / 100 * Convert.ToDecimal(PhysioShare_Percentage);

                        InsertVoucherLine(Convert.ToInt32(Header.Bill_No), GetSharedAccounts("Physio_Share"), 0, Convert.ToDecimal(PoolShare), Convert.ToInt32(gvm.Voucher_ID), "Cash Entry for " + item.Item_Name + "  " + Remarks.ToString(), Convert.ToInt32(item.Item_ID), item.Item_Type, "Bill", 0);
                    }

                    // Entry in Department...
                    if (Convert.ToDecimal(item.Amount) > 0 && IsPhysioShare)
                    {
                        NetAmount = Convert.ToDecimal(item.Amount - item.Discount_Amount);
                        PoolShare = NetAmount / 100 * Convert.ToDecimal(PhysioShare_Percentage);

                        InsertVoucherLine(Convert.ToInt32(Header.Bill_No), GetAccountID(PatientType.ToString(), PatientDetails.Patient_Type, PatientDetails.Patient_Main_Category, Convert.ToInt32(item.Item_ID), item.Item_Type, false, false), 0, Convert.ToDecimal(item.Amount - PoolShare), Convert.ToInt32(gvm.Voucher_ID), "Cash Entry for " + item.Item_Name + "  " + Remarks.ToString(), Convert.ToInt32(item.Item_ID), item.Item_Type, "Bill", 0);
                    }

                    // Entry in Dental Pool...
                    if (Convert.ToDecimal(item.Amount) > 0 && IsDentalShare)
                    {
                        NetAmount = Convert.ToDecimal(item.Amount - item.Discount_Amount);
                        PoolShare = NetAmount / 100 * Convert.ToDecimal(DentalShare_Percentage);

                        InsertVoucherLine(Convert.ToInt32(Header.Bill_No), GetSharedAccounts("Dental_Share"), 0, Convert.ToDecimal(PoolShare), Convert.ToInt32(gvm.Voucher_ID), "Cash Entry for " + item.Item_Name + "  " + Remarks.ToString(), Convert.ToInt32(item.Item_ID), item.Item_Type, "Bill", 0);
                    }

                    // Entry in Department...
                    if (Convert.ToDecimal(item.Amount) > 0 && IsDentalShare)
                    {
                        NetAmount = Convert.ToDecimal(item.Amount - item.Discount_Amount);
                        PoolShare = NetAmount / 100 * Convert.ToDecimal(DentalShare_Percentage);

                        InsertVoucherLine(Convert.ToInt32(Header.Bill_No), GetAccountID(PatientType.ToString(), PatientDetails.Patient_Type, PatientDetails.Patient_Main_Category, Convert.ToInt32(item.Item_ID), item.Item_Type, false, false), 0, Convert.ToDecimal(item.Amount - PoolShare), Convert.ToInt32(gvm.Voucher_ID), "Cash Entry for " + item.Item_Name + "  " + Remarks.ToString(), Convert.ToInt32(item.Item_ID), item.Item_Type, "Bill", 0);
                    }
                    // Entry in Derma Pool...
                    if (Convert.ToDecimal(item.Amount) > 0 && IsDermaShare)
                    {
                        NetAmount = Convert.ToDecimal(item.Amount - item.Discount_Amount);
                        PoolShare = NetAmount / 100 * Convert.ToDecimal(DermaShare_Percentage);

                        InsertVoucherLine(Convert.ToInt32(Header.Bill_No), GetSharedAccounts("Derma_Share"), 0, Convert.ToDecimal(PoolShare), Convert.ToInt32(gvm.Voucher_ID), "Cash Entry for " + item.Item_Name + "  " + Remarks.ToString(), Convert.ToInt32(item.Item_ID), item.Item_Type, "Bill", 0);
                    }
                    // Entry in Department...
                    if (Convert.ToDecimal(item.Amount) > 0 && IsDermaShare)
                    {
                        NetAmount = Convert.ToDecimal(item.Amount - item.Discount_Amount);
                        PoolShare = NetAmount / 100 * Convert.ToDecimal(DermaShare_Percentage);

                        InsertVoucherLine(Convert.ToInt32(Header.Bill_No), GetAccountID(PatientType.ToString(), PatientDetails.Patient_Type, PatientDetails.Patient_Main_Category, Convert.ToInt32(item.Item_ID), item.Item_Type, false, false), 0, Convert.ToDecimal(item.Amount - PoolShare), Convert.ToInt32(gvm.Voucher_ID), "Cash Entry for " + item.Item_Name + "  " + Remarks.ToString(), Convert.ToInt32(item.Item_ID), item.Item_Type, "Bill", 0);
                    }

                    else if (Convert.ToDecimal(item.Amount) > 0 && !IsRadialogyShare && !IsPhysioShare && !IsDentalShare && !IsDermaShare)
                    {
                        InsertVoucherLine(Convert.ToInt32(Header.Bill_No), GetAccountID(PatientType.ToString(), PatientDetails.Patient_Type, PatientDetails.Patient_Main_Category, Convert.ToInt32(item.Item_ID), item.Item_Type, false, false), 0, Convert.ToDecimal(item.Amount), Convert.ToInt32(gvm.Voucher_ID), "Cash Entry for " + item.Item_Name + "  " + Remarks.ToString(), Convert.ToInt32(item.Item_ID), item.Item_Type, "Bill", 0);
                    }

                    #endregion
                }
                else if (item.ParentTrans_Type == "Package")
                {
                    #region "Entry for In Patient Pacakages"

                    // Receivable Entry Item Wise....

                    if (Convert.ToDecimal(item.Net_Amount) > 0)
                    {
                        //InsertVoucherLine(Convert.ToInt32(Header.Bill_No), Receivable_Account, Convert.ToDecimal(item.Net_Amount), 0, Convert.ToInt32(gvm.Voucher_ID), "Cash Entry for " + item.Item_Name + "  " + Remarks.ToString(), Convert.ToInt32(item.Item_ID), item.Item_Type, "Bill", 0);
                    }

                    // Discount Entry....

                    if (Convert.ToDecimal(item.Discount_Amount) > 0)
                    {
                        InsertVoucherLine(Convert.ToInt32(Header.Bill_No), GetAccountID(PatientType.ToString(), PatientDetails.Patient_Type, PatientDetails.Patient_Main_Category, Convert.ToInt32(item.Item_ID), item.Item_Type, (bool)item.Liability_Item, (bool)item.LabOR_RadiologyCharges), Convert.ToDecimal(item.Discount_Amount), 0, Convert.ToInt32(gvm.Voucher_ID), "Discount Entry for " + item.Item_Name + "  " + Remarks.ToString(), Convert.ToInt32(item.Item_ID), item.Item_Type, "Bill", 0);
                    }
                    // Entry in Department OR Pool...

                    if (Convert.ToDecimal(item.Amount) > 0)
                    {
                        InsertVoucherLine(Convert.ToInt32(Header.Bill_No), GetAccountID(PatientType.ToString(), PatientDetails.Patient_Type, PatientDetails.Patient_Main_Category, Convert.ToInt32(item.Item_ID), item.Item_Type, (bool)item.Liability_Item, (bool)item.LabOR_RadiologyCharges), 0, Convert.ToDecimal(item.Amount), Convert.ToInt32(gvm.Voucher_ID), "Cash Entry for " + item.Item_Name + "  " + Remarks.ToString(), Convert.ToInt32(item.Item_ID), item.Item_Type, "Bill", 0);
                    }

                    #endregion
                }
            }

            #endregion

            Header.Voucher_ID = Convert.ToInt32(gvm.Voucher_ID);
            db.SubmitChanges();
        }

        #endregion

        protected void btnPrint_Click(object sender, EventArgs e)
        {
            if (Request.QueryString["ID"] == "")
                return;

            string query = "ReportName=BillingProcess&BillNo=" + Convert.ToString(Request.QueryString["BillNo"]);
            string path = @"\ReportViewer.aspx?" + query;
            ScriptManager.RegisterStartupScript(this, typeof(string), "OPEN_WINDOW", "window.open('" + path + "');", true);
        }

        public static void InsertVoucherLine(int TransNo, int AccountID, decimal DrAmount, decimal CrAmount, int MasterVoucherID, string Remarks, int Item_ID, string Item_Type, string Trns_Type, int Doctor_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            GL_Voucher_Account gvc = new GL_Voucher_Account();
            gvc.Voucher_ID = MasterVoucherID;
            gvc.Cheque_No = TransNo.ToString();
            gvc.Narration = Remarks;
            gvc.DR = DrAmount;
            gvc.CR = CrAmount;
            gvc.Account_ID = AccountID;
            gvc.Item_ID = Item_ID;
            gvc.Item_Type = Item_Type;
            gvc.Transaction_Type = Trns_Type;
            gvc.Doctor_ID = Doctor_ID;
            db.GL_Voucher_Accounts.InsertOnSubmit(gvc);
            db.SubmitChanges();
        }
        public static int GetSharedAccounts(string ParameterName)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var AccountDetails = (from prms in db.sys_Parms
                                  where prms.Name == ParameterName
                                  select prms
                ).FirstOrDefault();

            var AccountID = (from a in db.GL_Accounts
                             where a.Account_Code == AccountDetails.Code.ToString()
                             select a).FirstOrDefault();
            return AccountID.Account_ID;
        }
        public static int GetAccountID(string PatientType, string PatientTypeID, string DepartmentID, int ItemID, string ItemType, bool Liability_Item, bool LabOR_RadiologyCharges)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            sys_Parm AccountDetails = new sys_Parm();

            if (Liability_Item)
            {
                if (PatientTypeID != "02")
                {
                    AccountDetails = (from prms in db.sys_Parms
                                      where prms.Name == Convert.ToString(ItemID) && prms.Segment1 == DepartmentID && prms.Segment2 == "01"
                                      && prms.Segment3 == "Is Liability Account"
                                      select prms
                        ).FirstOrDefault();
                }
                else
                {
                    AccountDetails = (from prms in db.sys_Parms
                                      where prms.Name == Convert.ToString(ItemID) && prms.Segment1 == DepartmentID && prms.Segment2 == PatientTypeID
                                      && prms.Segment3 == "Is Liability Account"
                                      select prms
                        ).FirstOrDefault();
                }
            }

            else if (!Liability_Item && LabOR_RadiologyCharges)
            {
                string LabOR_RadiologyCharges_Account = (PatientType == "General") ? "LabAndRadiologyCharges_GeneralAccount" : "LabAndRadiologyCharges_PrivateAccount";
                AccountDetails = (from prms in db.sys_Parms
                                  where prms.Name == LabOR_RadiologyCharges_Account
                                  select prms
                    ).FirstOrDefault();
            }
            // Department Entry............

            else if (!Liability_Item && !LabOR_RadiologyCharges)
                if (PatientTypeID != "02")
                {
                    AccountDetails = (from prms in db.sys_Parms
                                      where prms.Segment1 == DepartmentID && prms.Segment2 == "01" && prms.Segment3 == "Is Income Account"
                                      select prms
                                      ).FirstOrDefault();
                }
                else
                {

                    AccountDetails = (from prms in db.sys_Parms
                                      where prms.Segment1 == DepartmentID && prms.Segment2 == PatientTypeID && prms.Segment3 == "Is Income Account"
                                      select prms
                        ).FirstOrDefault();
                }


            if (ItemType == "Test")
            {
                var TestMainDepartment = (from tdfn in db.Lab_Tests
                                          where tdfn.Test_ID == ItemID
                                          select tdfn.Main_Department).FirstOrDefault();

                TestMainDepartment = db.GetDataValueName("Main Test Departments", TestMainDepartment);

                if (TestMainDepartment == null)
                {
                    TestMainDepartment = "Lab Test";
                }

                if (TestMainDepartment == "Lab Test")
                {
                    TestMainDepartment = "Lab Test";
                }
                else
                {

                    TestMainDepartment = "Radiology";
                }

                {
                    string Department_ID = "017";
                    if (TestMainDepartment != "Lab Test")
                        Department_ID = "018";
                    if (PatientTypeID != "02")
                    {
                        AccountDetails = (from prms in db.sys_Parms
                                          where prms.Segment1 == Department_ID && prms.Segment2 == "01" && prms.Segment3 == "Is Income Account"
                                          select prms
                                          ).FirstOrDefault();
                    }
                    else
                    {

                        AccountDetails = (from prms in db.sys_Parms
                                          where 1 == 1
                                          && prms.Segment2 == PatientTypeID
                                          && prms.Segment1 == Department_ID
                                          && prms.Segment3 == "Is Income Account"
                                          select prms
                                       ).FirstOrDefault();
                    }
                }
            }

            var AccountID = (from a in db.GL_Accounts
                             where a.Account_Code == AccountDetails.Code.ToString()
                             select a).FirstOrDefault();

            return Convert.ToInt32(AccountID.Account_ID);
        }
        [WebMethod]
        public static string GetDoctors()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var emps = (from emp in db.HR_Employees
                        where emp.IsDoctor == true
                        orderby emp.Emp_Name
                        select new { emp.Emp_ID, Emp_Name = emp.Emp_Name.Replace("Dr.", string.Empty).Replace("Prof.", string.Empty) }).ToList();
            //emps.Add(new HR_Employee() { Emp_ID = 0, Emp_Name = "Select Employee" });
            emps = emps.OrderBy(emp => emp.Emp_ID).ToList();
            return (new JavaScriptSerializer()).Serialize(emps);
        }
        [WebMethod]
        public static string CheckReceipts(int Bill_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            List<Receipt> rcpts = db.Receipts.Where(r => r.Bill_ID == Bill_ID && (r.isCancel == false || r.isCancel == null)).ToList();
            StringBuilder noList = new StringBuilder();
            if (rcpts.Count > 0)
            {
                foreach (var item in rcpts)
                {
                    noList.Append(item.Receipt_No);
                    noList.Append(",");
                }
            }
            return noList.ToString();
        }

        [WebMethod]
        public static string GetUserBranch()
        {
            using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                var branchIds = (from bwd in db.Branch_Wise_User_Details
                                 where bwd.User_Id == AppConfig.UserID
                                 select bwd.Brancg).ToList();

                if (!branchIds.Any())
                    return "null";

                var validBranches = new List<object>();

                foreach (var brancg in branchIds)
                {
                    if (int.TryParse(brancg, out int branchId))
                    {
                        var branch = db.Branches.FirstOrDefault(b => b.branch_ID == branchId);
                        if (branch != null)
                        {
                            validBranches.Add(new { branch_ID = branchId, branch_Name = branch.branch_Name });
                        }
                    }
                }

                if (!validBranches.Any())
                    return "null";
                
                return new JavaScriptSerializer().Serialize(validBranches);
            }
        }

        [WebMethod]
        public static string GetSalesTaxDefinitions()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var taxList = (from st in db.Sales_Taxes
                           where st.Active == true && st.IsBilling == true  
                           select new
                           {
                               st.Sales_Tax_ID,
                               st.Sales_Tax_Perc
                           }).ToList();
            return (new JavaScriptSerializer()).Serialize(taxList);
        }

        [WebMethod]
        public static List<Search_App> SearchAppointment(string SearchString)
        {
            string safeSearch = SearchString?.Replace("'", "''").Trim() ?? "";

            string opdQuery = @"
    SELECT 
        CAST(a.Appointment_ID AS VARCHAR) AS Appointment_ID,
        ISNULL(CAST(a.Appointment_No AS VARCHAR), '') AS Appointment_No,
        CONVERT(VARCHAR(11), a.App_Date, 106) AS App_Date,
        ISNULL(a.Patient_Name, '') AS Patient_Name,
        ISNULL(a.Consultant_ID, '') AS Consultant_ID,
        ISNULL(a.Age, '') AS Age,
        ISNULL(a.Phone, '') AS Phone,
        ISNULL((SELECT TOP 1 e.Emp_Name FROM HR_Employees e WHERE e.Emp_ID = a.Consultant_ID), '') AS Emp_name,
        ISNULL(CAST(a.Reg_id AS VARCHAR), '') AS pat_id,
        a.Appointment_ID AS SortOrderID
    FROM Appointment_Form a
    INNER JOIN Reg_patient r ON r.pat_id = a.Reg_id
    WHERE a.Appointment_No <> 0 
      AND a.Appointment_No IS NOT NULL 
      AND a.Status = 'Booked'";

            string dermaQuery = @"
    SELECT 
        CAST(d.Derma_Appointment_Id AS VARCHAR) AS Appointment_ID,
        ISNULL(CAST(d.Appointment_No AS VARCHAR), '') AS Appointment_No,
        CONVERT(VARCHAR(11), d.Appointment_Date, 106) AS App_Date,
        ISNULL(r.Full_Name, '') AS Patient_Name,
        ISNULL(d.Doctor_Id, '') AS Consultant_ID,
        ISNULL(CAST(r.Age_years AS VARCHAR), '') AS Age,
        ISNULL(r.Mobile1, '') AS Phone,
        ISNULL((SELECT TOP 1 e.Emp_Name FROM HR_Employees e WHERE e.Emp_ID = d.Doctor_Id), '') AS Emp_name,
        ISNULL(CAST(d.Patient_Id AS VARCHAR), '') AS pat_id,
        d.Derma_Appointment_Id AS SortOrderID
    FROM Derma_Appointment d
    INNER JOIN Reg_patient r ON r.pat_id = d.Patient_Id
    WHERE d.Status = 'Booked'";

            string unionQuery = $"({opdQuery}) UNION ALL ({dermaQuery})";

            string whereClause = "1=1";
            if (!string.IsNullOrEmpty(safeSearch))
            {
                whereClause += $@"
        AND (
            LTRIM(RTRIM(Appointment_No)) LIKE '%{safeSearch}%' OR
            LTRIM(RTRIM(Patient_Name)) LIKE '%{safeSearch}%' OR
            LTRIM(RTRIM(Consultant_ID)) LIKE '%{safeSearch}%' OR
            LTRIM(RTRIM(Age)) LIKE '%{safeSearch}%' OR
            LTRIM(RTRIM(Phone)) LIKE '%{safeSearch}%' OR
            Consultant_ID = ISNULL((SELECT TOP 1 Emp_ID FROM HR_Employees WHERE Emp_Name LIKE '%{safeSearch}%'), '0')
        )";
            }

            string finalQuery = $@"
    SELECT TOP 100
        Appointment_ID, Appointment_No, App_Date, Patient_Name, Consultant_ID, 
        Age, Phone, Emp_name, pat_id
    FROM (
        {unionQuery}
    ) AS Combined
    WHERE {whereClause}
    ORDER BY SortOrderID DESC";

            try
            {
                DataTable dt = DBClass.getDataTable(finalQuery);
                var list = new List<Search_App>();

                foreach (DataRow dr in dt.Rows)
                {
                    list.Add(new Search_App
                    {
                        Appointment_ID = dr["Appointment_ID"]?.ToString() ?? "",
                        Appointment_No = dr["Appointment_No"]?.ToString() ?? "",
                        App_Date = dr["App_Date"]?.ToString() ?? "",
                        Patient_Name = dr["Patient_Name"]?.ToString() ?? "",
                        Consultant_ID = dr["Consultant_ID"]?.ToString() ?? "",
                        Age = dr["Age"]?.ToString() ?? "",
                        Phone = dr["Phone"]?.ToString() ?? "",
                        Emp_name = dr["Emp_name"]?.ToString() ?? "",
                        pat_id = dr["pat_id"]?.ToString() ?? ""
                    });
                }
                return list;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Search Error: " + ex.Message);
                return new List<Search_App>();
            }
        }

        public class Search_App
        {
            public string Appointment_ID { get; set; }
            public string Appointment_No { get; set; }
            public string App_Date { get; set; }
            public string Patient_Name { get; set; }
            public string Consultant_ID { get; set; }
            public string Age { get; set; }
            public string Phone { get; set; }
            public string Emp_name { get; set; }
            public string pat_id { get; set; }
        }
        [WebMethod]
        public static string GetPackageItemPanelRate(string Panel_Id, string Item_Id, string Item_Type)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                decimal rate = 0;

                if (Item_Type == "Test")
                {
                    // For Test items
                    var panelRate = (from p in db.Panels
                                     join pd in db.Panel_Detail_Services
                                     on p.Panel_ID equals pd.Panel_ID
                                     where p.Panel_ID == Convert.ToInt32(Panel_Id)
                                           && pd.Test_ID == Item_Id
                                     select new { pd.Rate }).FirstOrDefault();

                    if (panelRate != null)
                    {
                        rate = panelRate.Rate ?? 0;
                    }
                }
                else
                {
                    // For Service/Item items
                    var panelRate = (from p in db.Panels
                                     join pd in db.Panel_Detail_Services
                                     on p.Panel_ID equals pd.Panel_ID
                                     where p.Panel_ID == Convert.ToInt32(Panel_Id)
                                           && pd.Item_ID == Item_Id
                                     select new { pd.Rate }).FirstOrDefault();

                    if (panelRate != null)
                    {
                        rate = panelRate.Rate ?? 0;
                    }
                }

                var result = new { Rate = rate };
                return new JavaScriptSerializer().Serialize(result);
            }
        }
        [WebMethod]
        public static string GetDermaAppointmentServices(int Appointment_ID)
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var appointmentData = (from da in db.Derma_Appointments
                                           where da.Derma_Appointment_Id == Appointment_ID
                                           select new
                                           {
                                               da.Derma_Appointment_Id,
                                               da.Appointment_No,
                                               da.Patient_Id,
                                               da.Procedure_Id,
                                               da.Doctor_Id,
                                               da.Appointment_Date,
                                               da.Status,
                                               Doctor_Name = (from e in db.HR_Employees
                                                              where (e.Emp_ID == Convert.ToInt32(da.Doctor_Id))
                                                              select e.Emp_Name).FirstOrDefault()
                                           }).FirstOrDefault();

                    int procedureId = 0;

                    if (!int.TryParse(appointmentData.Procedure_Id, out procedureId))
                    {
                        procedureId = 0;
                    }

                    var serviceDetails = (from item in db.INV_Items
                                          where item.Item_ID == Convert.ToInt32(appointmentData.Procedure_Id)
                                          select new
                                          {
                                              item.Item_ID,
                                              item.Item_Code,
                                              item.Description,
                                              item.Sale_Rate,
                                              item.Services,
                                              item.Procedure_types,
                                              Unit = db.GetDataValueName("UOM", item.Unit)
                                          }).FirstOrDefault();

                    if (serviceDetails == null)
                    {
                        return new JavaScriptSerializer().Serialize(new { success = false, message = "No service found for this procedure" });
                    }

                    var result = new
                    {
                        success = true,
                        appointment = appointmentData,
                        service = serviceDetails
                    };

                    return new JavaScriptSerializer().Serialize(result);
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new { success = false, message = ex.Message });
            }
        }

        //[WebMethod]
        //public static string AllowLineDiscount()
        //{
        //    try
        //    {
        //        using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
        //        {
        //            var linedisc = (from tbl in db.sys_Parms
        //                            where tbl.Name == "Allow Line Discount"
        //                            select tbl.Code)
        //                      .FirstOrDefault();

        //            return linedisc ?? "01";
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        return "0";
        //    }
        //}

        [WebMethod]
        public static bool AllowLineDiscount()
        {
            try
            {
                using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    // Get the current user's Allow_bill_edit permission
                    var userDiscountPermission = (from user in db.aspnet_Users
                                                  where user.UserId == AppConfig.UserID
                                                  select user.AllowLineDiscount) // This returns bool? (nullable boolean)
                                           .FirstOrDefault();

                    // Return true if permission is true, false otherwise
                    return userDiscountPermission == true;
                }
            }
            catch (Exception ex)
            {
                return false;
            }
        }

        [WebMethod]
        public static bool AllowApprovalitem()
        {
            try
            {
                using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    var userApprovalPermission = (from user in db.aspnet_Users
                                                  where user.UserId == AppConfig.UserID
                                                  select user.AllowApprovalitem)
                                           .FirstOrDefault();

                    return userApprovalPermission == true;
                }
            }
            catch (Exception ex)
            {
                return false;
            }
        }

        [WebMethod]
        public static string CNICValidation()
        {
            try
            {
                using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    var linedisc = (from tbl in db.sys_Parms
                                    where tbl.Name == "CNIC Validation"
                                    select tbl.Code)
                              .FirstOrDefault();

                    return linedisc ?? "01";
                }
            }
            catch (Exception ex)
            {
                return "0";
            }
        }

        [WebMethod]
        public static string ReamrksValidation()
        {
            try
            {
                using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    var linedisc = (from tbl in db.sys_Parms
                                    where tbl.Name == "Billing Remarks"
                                    select tbl.Code)
                              .FirstOrDefault();

                    return linedisc ?? "01";
                }
            }
            catch (Exception ex)
            {
                return "0";
            }
        }

        [WebMethod]
        public static string FinalBillButton()
        {
            try
            {
                using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    var FinalIPDBill = (from tbl in db.sys_Parms
                                    where tbl.Name == "IPD Final Bill"
                                    select tbl.Code)
                              .FirstOrDefault();

                    return FinalIPDBill ?? "01";
                }
            }
            catch (Exception ex)
            {
                return "0";
            }
        }
        [WebMethod]
        public static string GetAutoRecvOPD()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var dept = (from data in db.sys_Parms
                        where data.Name == "auto recvingopd"
                        select data.Code).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(dept);
        }
        [WebMethod]
        public static void IncrementReprintCount(int Bill_ID)
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var bill = db.Ar_Billings.FirstOrDefault(b => b.Bill_ID == Bill_ID);
                    if (bill != null)
                    {
                        // Increment the count (handles nulls just in case)
                        bill.Reprint_Count = bill.Reprint_Count + 1;
                        db.SubmitChanges();
                    }
                }
            }
            catch (Exception ex)
            {
                // Optional: Log the exception to your error log
                System.Diagnostics.Debug.WriteLine("Reprint Count Error: " + ex.Message);
            }
        }

    }
}