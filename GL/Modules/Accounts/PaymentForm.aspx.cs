using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class PaymentForm : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        public class PatientDetail
        {
            public string Name;
            public string Gender;
            public string Age;
            public string Patient_Type;
            public string Patient_Discount_Type;
            public string Mobile;
            public string Address;
            public string Entry_Date;
            public string department;
            public string Follow;
            public string Created_Time;
            public string Bed_No;
            public string Ward_Name;
            public string Room_Name;
            public string Room_No;
            public bool Discharge { get; set; }
            public bool isInpatient { get; set; }

            public string Previous_inpatient { get; set; }
            public string OPD_Panel_ID { get; set; }

            public string IPD_Panel_ID { get; set; }

            public string OPD_Panel_Name { get; set; }

            public string IPD_Panel_Name { get; set; }

            public string Admission_type { get; set; }

            public string Sehat_Card_No { get; set; }

            public string Visit_Id { get; set; }

        }
        public class PaymenFormEntities
        {
            public int Transaction_ID { get; set; }
            public int Patient_ID { get; set; }
            //public int Doctor_ID { get; set; }
            public DateTime Transaction_ID_Date { get; set; }
            public string Remarks { get; set; }
            public decimal Discount_Percentage { get; set; }
            public decimal Discount_Amount { get; set; }
            public decimal TotalPayable { get; set; }
            public decimal Net_Amount { get; set; }
            public decimal Received_Amount { get; set; }
            public decimal Balance_Amount { get; set; }
            public string ChargePolicy { get; set; }
            //public string Remarks { get; set; }
            public List<PaymenFormEntitiesDetails> Details { get; set; }
           
        }
        public class PaymenFormEntitiesDetails
        {
            public int ParentTrans_ID { get; set; }
            public string ParentTrans_Name { get; set; }
            public string ParentTrans_Type { get; set; }
            public int ItemID { get; set; }
            public string CategoryID { get; set; }
            public string ItemName { get; set; }
            public string ItemType { get; set; }
            public bool RecommendedByDoctor { get; set; }
            public bool ExcludedFromPayment { get; set; }
            public decimal Amount { get; set; }
            public decimal DisPer { get; set; }
            public decimal DisAmt { get; set; }
            public decimal Net_Amount { get; set; }
            public int Qty { get; set; }
            public string Remarks { get; set; }
            public decimal DocShare { get; set; }
            public string MainDepartment { get; set; }


        }
        [WebMethod]
        public static string SaveRecord(string Parameters)
        {


            return (new JavaScriptSerializer()).Serialize(Save(Parameters));
        }
        public static string Save(string Parameters)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            JavaScriptSerializer JSS = new JavaScriptSerializer();
            var data = JSS.Deserialize<PaymenFormEntities>(Parameters);

            Ar_PaymentForm newBill;

            if (data.Transaction_ID == 0)
            {
                newBill = new Ar_PaymentForm();
                newBill.Created_By = AppConfig.UserID;
                newBill.Creation_Date = DateTime.Now;
                newBill.PaymentForm_No = DBClass.GetNewNumber("PaymentForm_No", "Ar_PaymentForm", "").ToString();

            }
            else
            {
                newBill = db.Ar_PaymentForms.Where(b => b.PaymentForm_ID == data.Transaction_ID).FirstOrDefault();
                newBill.Updated_By = AppConfig.UserID;
                newBill.Updation_Date = DateTime.Now;
            }

            newBill.Patient_ID = data.Patient_ID;
            newBill.PaymentForm_Date = DateTime.Now;
            newBill.Remarks = data.Remarks;
            //newBill.Discount_Percentage = data.Discount_Percentage;
            //newBill.Discount_Amount = data.Discount_Amount;
            newBill.Total_Amount = data.TotalPayable;
            newBill.Net_Amount = data.Net_Amount;
            newBill.Received_Amount = data.Received_Amount;
            newBill.Balance_Amount = data.Balance_Amount;
         //   newBill.Charge_Policy = data.ChargePolicy;
            //newBill.Doctor_ID = data.Doctor_ID;

            var inpatient_ID = db.In_Patients.Where(m => m.Patient_ID.Equals(data.Patient_ID)).Select(m => m.In_Patient_ID).ToList();
            if (inpatient_ID.Count != 0)
            {
                var inpatient = (from inPat in db.In_Patients
                                 where inPat.Patient_ID == data.Patient_ID
                                 && inPat.Discharge == false
                                 orderby inPat.Admission_Date descending
                                 select new
                                 {
                                     inPat.In_Patient_ID
                                 }).FirstOrDefault();
                if (inpatient != null)
                    newBill.In_Patient_ID = Convert.ToInt32(inpatient.In_Patient_ID);
            }
            else
            {
                var patient_no = DBClass.getField("select Patient_No from patients where Patient_ID=" + data.Patient_ID);
                //var patient_no = DBClass.GetMRNOBy_PatientID(data.Patient_ID);
                var patient_Admit_Category_For_Revisit_Case = (from p in db.Patients
                                                               where p.Patient_No == Convert.ToInt32(patient_no)
                                                               orderby p.Patient_ID ascending
                                                               select p).ToList();
                var Previous_inpatient = "0";
                newBill.In_Patient_ID = 0;
                foreach (var item in patient_Admit_Category_For_Revisit_Case)
                {

                    var In_Patient_ID = DBClass.getField("select  In_Patient_ID from In_Patient where discharge=0 and Patient_ID=" + item.Patient_ID);
                    if (In_Patient_ID.Contains("position"))
                    {
                        //  pt.Previous_inpatient = Previous_inpatient;
                    }
                    else
                    {
                        newBill.In_Patient_ID = Convert.ToInt32(In_Patient_ID);
                    }
                }

            }
            // Insert or Upate Bill Header

            if (data.Transaction_ID == 0)
                db.Ar_PaymentForms.InsertOnSubmit(newBill);
            db.SubmitChanges();

            List<Ar_PaymentForm_Detail> ListOfDetails = new List<Ar_PaymentForm_Detail>();


            // Inserting or Updating Bill Details
            List<Ar_PaymentForm_Detail> Details = db.Ar_PaymentForm_Details.Where(v => v.PaymentForm_ID == Convert.ToInt32(data.Transaction_ID)).ToList();
            db.Ar_PaymentForm_Details.DeleteAllOnSubmit(Details);
            db.SubmitChanges();

            foreach (PaymenFormEntitiesDetails dtls in data.Details)
            {
                Ar_PaymentForm_Detail newBillDetails = new Ar_PaymentForm_Detail();

                newBillDetails.PaymentForm_ID = newBill.PaymentForm_ID;
                newBillDetails.ParentTrans_ID = dtls.ParentTrans_ID;
                newBillDetails.ParentTrans_Name = dtls.ParentTrans_Name;
                newBillDetails.ParentTrans_Type = dtls.ParentTrans_Type;
                newBillDetails.Item_ID = dtls.ItemID;
                newBillDetails.Item_Name = dtls.ItemName;
                newBillDetails.Item_Type = dtls.ItemType;
              //  newBillDetails.RecommendedByDoctor = dtls.RecommendedByDoctor;
                newBillDetails.Amount = dtls.Amount;
                //newBillDetails.Discount_Percentage = dtls.DisPer;
                //newBillDetails.Discount_Amount = dtls.DisAmt;
                //newBillDetails.Net_Amount = dtls.Net_Amount;
                newBillDetails.Qty = dtls.Qty;
                newBillDetails.Remarks = dtls.Remarks;
                //newBillDetails.Doctor_Share = dtls.DocShare;
                newBillDetails.Category_ID = dtls.CategoryID;
                newBillDetails.Test_Main_Department = dtls.MainDepartment;
                newBillDetails.Service_Date = DateTime.Now;

                bool isGroupCategory = false;
                if (dtls.ItemType == "Test" && dtls.ItemID == 0)
                {
                    if (dtls.CategoryID != null)
                    {
                        if (dtls.CategoryID.ToString().Trim() != string.Empty)
                        {
                            isGroupCategory = true;
                        }
                    }
                }
                newBillDetails.Is_Group_Category = isGroupCategory;

                ListOfDetails.Add(newBillDetails);
            }

            
            db.Ar_PaymentForm_Details.InsertAllOnSubmit(ListOfDetails);
        
            db.SubmitChanges();
          
            //bypass X-Ray etc
        
            //end
            return newBill.PaymentForm_ID.ToString();
        }
        [WebMethod]
        public static string LoadTransactionHeader(int ID)
        {

            DataBaseDataContext db = new DataBaseDataContext();
            var query = from data in db.Ar_PaymentForms.Where(x => x.PaymentForm_ID == ID)
                        select new
                        {
                            data.Balance_Amount,
                            data.PaymentForm_Date,
                            data.PaymentForm_ID,
                            data.PaymentForm_No,
                            data.Created_By,
                            data.Creation_Date,
                            //data.Discount_Amount,
                            //data.Discount_Percentage,
                            //data.Doctor_ID,
                            data.Net_Amount,
                            data.Patient_ID,
                            data.Received_Amount,
                          //  data.Charge_Policy,
                            data.Remarks,
                            data.Total_Amount,
                            data.Updated_By,
                            data.Updation_Date,
                            data.Voucher_ID,
                        };
            //var Header = db.Ar_Billings.Where(bm => bm.Bill_ID == Bill_ID);
            return (new JavaScriptSerializer()).Serialize(query);
        }
        [WebMethod]
        public static string LoadTransactionDetails(int ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = (from d in db.Ar_PaymentForm_Details
                           join m in db.Ar_PaymentForms
                            on d.PaymentForm_ID equals m.PaymentForm_ID
                           where m.PaymentForm_ID == ID
                           select new
                           {
                               d.Amount,
                              

                               d.PaymentForm_Details_ID,
                               d.PaymentForm_ID,
                               d.Category_ID,
                               Discount_Amount="0",
                               Discount_Percentage="0",
                               d.Expiry_Date,
                               d.Item_ID,
                               d.Item_Name,
                               Net_Amount="0",
                               d.Item_Type,
                               d.ParentTrans_ID,
                               d.ParentTrans_Name,
                               d.ParentTrans_Type,
                               d.Qty,
                               d.Remarks,
                           



                           }).ToList();


            return (new JavaScriptSerializer()).Serialize(Details);
        }
        [WebMethod]
        public static string GetProcedure(string deptID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var tests = (from t in db.Lab_Tests
                         where t.Main_Department == "005" && t.Payment == true
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
            //var listNew = (from t in db.Lab_Tests
            //               where t.Group_Department == "008" && t.Group_Category != "" && t.Main_Department == "005"
            //               select new
            //               {
            //                   Test_ID = t.Group_Category,
            //                   Test_Name= DBClass.getField("select Datavalue_Description from Datavalues where Datavalue_Name = '" + t.Group_Category + "' and  Valueset_ID = 70 and division='005'"),
            //                 //TestName = db.GetDataValueName("Test Groups", t.Group_Category),

            //               }).Distinct().ToList();
            var listNew = (from t in db.DataValues
                           where t.Division == "005" && t.ValueSet_ID == 70 && t.Segment5 == true
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
                //obj.TestName  = category.Test_Name.ToString() + (category.Group_Category != string.Empty ? " | " + DBClass.getField("select Datavalue_Description from Datavalues where Datavalue_Name = '" + category.Group_Category + "' and Valueset_ID = 70 and division='005'") : string.Empty);
                obj.SerialNo = counter.ToString();
                obj.IsGroupCategory = true;
                obj.CategoryID = category.Test_ID;
                listOfTest.Add(obj);
                counter++;
            }

            return (new JavaScriptSerializer().Serialize(listOfTest));


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
        public static string GetLabTests()
        {

            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var tests = from t in db.Lab_Tests
                        where t.Main_Department == "001" && t.Active == true && t.Payment == true
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
                                  where vs.ValueSet_Name == "Test Groups" && dv.Division == "001" && dv.Segment5==true
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
        public static string GetLabTestDDLDetails(string SerialNo, string maindpt)
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
                        where t.Main_Department == maindpt && t.Test_Name == testName && t.Group_Category == groupCategory && t.Payment==true
                        select new { t.Test_ID, t.Rate, /*= DBClass.getField(""),t.Test_Name*/ Test_Name = SerialNo, t.Group_Category, TestMainDepartmentName = db.GetDataValueName("Main Test Departments", t.Main_Department.ToString()).ToString(), GroupCategoryName = db.GetDataValueName("Test Groups", t.Group_Category.ToString()).ToString() }).ToList();
            var count = test.Count;

            if (count != 0)
            {
                return (new JavaScriptSerializer()).Serialize(test);
            }
            else
            {
                var GroupCategories = (from dv in db.DataValues
                                       join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                                       where vs.ValueSet_Name == "Test Groups" && dv.DataValue_Description == SerialNo && dv.Segment5 == true
                                       select new { Test_ID = 0, Group_Category = dv.DataValue_Name, Test_Name = dv.DataValue_Description, TestMainDepartmentName = "Lab Test", Main_Department = "001", Rate = dv.Segment1 }).ToList();
                return (new JavaScriptSerializer()).Serialize(GroupCategories);
            }
        }
        [WebMethod]
        public static string GetTestMainDepartmentDetails(int TestID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var TestMainDepartmentName = (from t in db.Lab_Tests
                                          where t.Test_ID == TestID && t.Active == true &&  t.Payment == true 
                                          select new
                                          {
                                              MainDepartment = db.GetDataValueName("Main Test Departments", t.Main_Department.ToString()).ToString(),
                                              Rate = ((from td in db.Lab_Tests where td.Test_ID == TestID select td.Rate).FirstOrDefault()),
                                              t.Test_Name,
                                              Category_ID = t.Group_Category
                                          }).ToList();
            return (new JavaScriptSerializer().Serialize(TestMainDepartmentName));
        }
        [WebMethod]
        public static string FillTestsByCategory(string CategoryID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var tests = from t in db.Lab_Tests
                        where t.Main_Department == CategoryID && t.Active == true && t.Payment == true
                        select new { t.Test_ID, t.Test_Name };

            return (new JavaScriptSerializer()).Serialize(tests);
        }
        [WebMethod]
        public static string GetRotationsCategoryWise(string testCategory)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var dep = from dv in db.DataValues
                      join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                      where vs.ValueSet_Name == testCategory && dv.Segment5 == true
                      select new { dv.DataValue_Name, dv.DataValue_Description };

            return (new JavaScriptSerializer()).Serialize(dep);
        }

        [System.Web.Services.WebMethod]

        public static PatientDetail GetPatientDetails(string PatientID)
        {

            int Patien_No = DBClass.GetMRNOBy_PatientID(Convert.ToInt32(PatientID));
            PatientDetail pt = new PatientDetail();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            Patient pat = new Patient();

            pat = (from tbl in db.Patients
                   where tbl.Patient_No == Patien_No
                   orderby tbl.Created_Time descending
                   select tbl).FirstOrDefault();
            var Type = (from tbl in db.In_Patients
                        where tbl.Patient_ID == int.Parse(PatientID)
                        && tbl.Discharge != true
                        orderby tbl.Created_Time descending
                        select tbl).FirstOrDefault();
            var isPatient = (from tbl in db.In_Patients
                             where tbl.Patient_ID == int.Parse(PatientID)

                             orderby tbl.Created_Time descending
                             select tbl).FirstOrDefault();


            var OPD = (from tbl in db.Out_Patients
                       where tbl.Patient_ID == int.Parse(PatientID)

                       orderby tbl.Created_Time descending
                       select tbl).FirstOrDefault();
           
            if (OPD != null)
            {


            }


            if (pat != null)
            {
                pt.Name = pat.Full_Name;
                pt.Gender = pat.Gender;
                pt.Age = pat.Age_years.ToString();

                if (pat.Entry_Date.HasValue)
                {
                    pt.Entry_Date = pat.Entry_Date.ToString();
                }
                else
                {
                    pt.Entry_Date = pat.Created_Time.ToString();
                }

                pt.Address = pat.Permanent_Address;
                pt.Mobile = pat.Mobile1;
                pt.department = pat.Patient_Main_Category;
                pt.department = DBClass.getPatientLatestDepartment(Convert.ToInt32(pat.Patient_No), true).ToString();
                // pt.department = db.GetDataValueName("Patient Main Category", pat.Patient_Main_Category);
                pt.Patient_Type = db.GetDataValueName("Patient Type", pat.Patient_Type);
                pt.Gender = db.GetDataValueName("Gender", pat.Gender);
                var Patientno = pat.Patient_No.ToString();
                var count = (db.Patients.Where(v => v.Patient_No == Convert.ToInt32(Patientno)).ToList());
                pt.Follow = count.Count.ToString();
                pt.OPD_Panel_ID = pat.Panel_Companies;
                if (pat.Panel_Companies == null || pat.Panel_Companies == "null") pat.Panel_Companies = "0";
                pt.OPD_Panel_Name = DBClass.getField("select Company_Name from Panel where Panel_ID=" + pat.Panel_Companies);
                var patient_Admit_Category_For_Revisit_Case = (from p in db.Patients
                                                               where p.Patient_No == Convert.ToInt32(Patientno)
                                                               orderby p.Patient_ID ascending
                                                               select p).ToList();
                var Previous_inpatient = "0";
                pt.Previous_inpatient = "0";
                foreach (var item in patient_Admit_Category_For_Revisit_Case)
                {
                    var discount_type = DBClass.getField("select  Patient_Discount_Type from In_Patient where discharge=0 and Patient_ID=" + item.Patient_ID);
                    var Patient_ID = DBClass.getField("select  Patient_ID from In_Patient where discharge=0 and Patient_ID=" + item.Patient_ID);
                    if (discount_type.Contains("position"))
                    {
                        //  pt.Previous_inpatient = Previous_inpatient;
                    }
                    else
                    {
                        Previous_inpatient = discount_type;
                        pt.Previous_inpatient = Patient_ID;
                    }
                }

                pt.Patient_Discount_Type = db.GetDataValueName("Patient Type", Previous_inpatient.ToString());
                pt.isInpatient = false;

                if (Type != null)
                {
                    pt.isInpatient = true;
                    pt.Patient_Discount_Type = db.GetDataValueName("Patient Type", Type.Patient_Discount_Type);
                    pt.Discharge = Convert.ToBoolean(Type.Discharge);
                    pt.Ward_Name = (from wd in db.Ward_Definitions where wd.Ward_ID == Type.Ward_ID select wd.Ward_No).FirstOrDefault();
                    pt.Bed_No = Type.Bed_No.ToString();
                    pt.Room_Name = (from rm in db.Rooms where rm.Room_ID == Type.Room_ID select rm.Name).FirstOrDefault();
                    pt.Room_No = Convert.ToString((from rm in db.Rooms where rm.Room_ID == Type.Room_ID select rm.Room_No).FirstOrDefault());
                    pt.IPD_Panel_ID = Type.Panel_Company;
                    if (Type.Panel_Company == null || Type.Panel_Company == "null") Type.Panel_Company = "0";
                    pt.IPD_Panel_Name = DBClass.getField("select Company_Name from Panel where Panel_ID=" + Type.Panel_Company);
                    pt.Admission_type = db.GetDataValueName("Sehat Sahulat Admission Type", Type.AdmissionType);
                    pt.Sehat_Card_No = Type.SehatCardNo;
                    pt.Visit_Id = Type.VisitId;
                }

                return pt;
            }
            else
                return pt;
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
    }
}