using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Net;
using System.Reflection;
using System.Security.Cryptography;
using System.Security.Policy;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.MobileControls.Adapters;
using System.Web.UI.WebControls;
using static PMS.WebForm11;

namespace PMS
{
    public partial class WebForm11 : System.Web.UI.Page
    {
        DataBaseDataContext db = new DataBaseDataContext();
        public static int OutpatientID;
        protected void Page_Load(object sender, EventArgs e)
        {
            txtDate.Text = DateTime.Now.Date.ToString(AppConfig.DateFormat);
            FollowNoDate.Text = DateTime.Now.Date.ToString(AppConfig.DateFormat);
            if (!Page.IsPostBack)
            {
                txtDate.Text = DateTime.Now.Date.ToString(AppConfig.DateFormat);
                FollowNoDate.Text = DateTime.Now.Date.ToString(AppConfig.DateFormat);
                BindDropDownList();
                txtOut_Patient_ID.Text = "(New)";

                if (Request.QueryString["ID"] != null)
                {
                    FillOutPatientForm(Convert.ToInt32(Request.QueryString["ID"]));
                    OutpatientID = Convert.ToInt32(Request.QueryString["ID"]);
                }
            }
        }

        [WebMethod]
        public static string LoadimagesDetail(string TestDetailID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var data = (from td in db.Test_Images

                        where td.Lab_Test_Detail_ID == int.Parse(TestDetailID)
                        select new
                        {
                            td.Image_path,
                            td.Lab_Test_ID,
                        }).ToList();
            return (new JavaScriptSerializer().Serialize(data));
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
        public static string GetCardioDDLDetails(string SerialNo, string maindpt)
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
                            t.Rate, /*= DBClass.getField(""),t.Test_Name*/
                            Test_Name = SerialNo,
                            t.Group_Category,
                            t.Main_Department,
                            TestMainDepartmentName = db.GetDataValueName("Main Test Departments", t.Main_Department.ToString()).ToString(),
                            GroupCategoryName = db.GetDataValueName("Test Groups", t.Group_Category.ToString()).ToString(),


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
                                           TestMainDepartmentName = "Cardiology",
                                           Main_Department = "008",
                                           Rate = dv.Segment1,


                                       }).ToList();
                return (new JavaScriptSerializer()).Serialize(GroupCategories);

            }
        }
        [WebMethod]
        public static string loadtemplate(string item_id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var data = (from td in db.Medicines_Templates
                        where td.Item_Code == Convert.ToString(item_id)
                        select new
                        {
                            td.Dosage_From,
                            td.Dosage_Qty,
                            td.Oral,
                            td.Other_Instruction,
                            td.Frequency,
                            td.Injections,
                            td.AttendingParamedical_Staff

                        }).ToList();
            return (new JavaScriptSerializer().Serialize(data));
        }
        [WebMethod]
        public static string GetAvailableDates(int DocID)
        {
            List<string> availableDates = new List<string>();

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                // First get DateTime list from DB (no formatting in SQL)
                var rawDates = (from r in db.Doctor_Rouster_Masters
                                join d in db.Doctor_Rouster_Details
                                on r.Rouster_id equals d.Rouster_id
                                where r.Doctor_Id == DocID
                                && d.Rouster_Date >= DateTime.Today
                                select d.Rouster_Date.Value).Distinct().ToList();

                // Format in C#
                availableDates = rawDates.Select(d => d.ToString("yyyy-MM-dd")).ToList();
            }

            return new JavaScriptSerializer().Serialize(availableDates);
        }
        [WebMethod]
        public static string SaveMedicines(string MedicineDetails)
        {
            try
            {
                JavaScriptSerializer js = new JavaScriptSerializer();
                var MedicineDetail = js.Deserialize<Medicine>(MedicineDetails);

                using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    /********************Deleting Previous 0 Value Saved Rows.***********************************/
                    List<In_Patient_Medicine> In_Patient_MedicineList = db.In_Patient_Medicines.Where(i => i.Patient_ID == 0 && i.Transaction_Type == "OutPatient").ToList();
                    db.In_Patient_Medicines.DeleteAllOnSubmit(In_Patient_MedicineList);
                    db.SubmitChanges();

                    int couterNewRecords = 0;

                    if (MedicineDetail.PatientID != 0)
                    {
                        /*********************Deleting Previous Entry On Every Insert Or Update*************************/
                        List<In_Patient_Medicine> inPatmedicineList = db.In_Patient_Medicines.Where(p => p.Patient_ID == MedicineDetail.PatientID && p.Transaction_Type == "OutPatient").ToList();
                        if (inPatmedicineList != null)
                        {
                            db.In_Patient_Medicines.DeleteAllOnSubmit(inPatmedicineList);
                            couterNewRecords++;
                        }
                    }
                    couterNewRecords = 0;
                    /*********************Inserting New Entry On Every Insert Or Update*************************/
                    foreach (MedicineDetails oIn_Patient_Medicine in MedicineDetail.MedicineList)
                    {
                        In_Patient_Medicine oIn_Patient_Medicine1 = new In_Patient_Medicine()
                        {

                            Patient_ID = Convert.ToInt32(MedicineDetail.PatientID),
                            Item_Code = oIn_Patient_Medicine.ItemCode,
                            Medicine_Name = oIn_Patient_Medicine.Medicine_Name,
                            Transaction_Type = "OutPatient",
                            Medicine_Date = oIn_Patient_Medicine.Medicine_Date,
                            Oral = oIn_Patient_Medicine.Oral,
                            Injections = oIn_Patient_Medicine.Injection,
                            Dosage_From = oIn_Patient_Medicine.Dosage_From,
                            AttendingParamedical_Staff = oIn_Patient_Medicine.AttendingParamedical_Staff,
                            Frequency = oIn_Patient_Medicine.Frequency,
                            Dosage_Qty = oIn_Patient_Medicine.Dosage_Qty,
                            Other_Instruction = oIn_Patient_Medicine.Other_Instruction

                        };
                        db.In_Patient_Medicines.InsertOnSubmit(oIn_Patient_Medicine1);
                        couterNewRecords++;
                    }
                    db.SubmitChanges();
                }
            }
            catch (Exception ex)
            {
            }
            return "";
        }


        [WebMethod]
        public static string LoadServicesDetails(string patients_id)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                List<ServiceDetails> list = new List<ServiceDetails>();
                var InpatientServices = db.InPatientServices.DefaultIfEmpty().Where(w => w.Ou_Patient_Id == patients_id/* && w.In_Patient_Id == in_PatientId*/).OrderByDescending(x => x.CreatedDate).ToList();

                if (InpatientServices.Count > 0 && InpatientServices != null)
                {
                 
                    foreach (var item in InpatientServices)
                    {
                        ServiceDetails sd = new ServiceDetails();
                        sd.Service_ProcedureName = item.Services_Procedure_ItemName;
                        sd.ServiceItemType = item.ServiceType;
                        sd.ServiceItemId = item.Service_ItemId;
                        sd.ServiceItemAmount = Convert.ToString(item.ServiceAmount);
                        sd.PatientType = item.PatientType;
                        sd.ServiceDate = item.CreatedDate == null ? DateTime.Now : item.CreatedDate;
                        sd.UserName = item.UserName;
                        sd.isbilled = Convert.ToBoolean(item.isbilled);
                        list.Add(sd);
                    }
                }

                return (new JavaScriptSerializer().Serialize(list));
            }

        }
        [WebMethod]
        public static string LoadServicesDetailforHistory(int PatientId, int in_PatientId)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                List<ServiceDetails> list = new List<ServiceDetails>();

                var pat_ids = (from p in db.Reg_patients join vs in db.Patients on p.pat_id equals vs.Reg_PatId where vs.Patient_ID == Convert.ToInt32(PatientId) select p.pat_id).FirstOrDefault();

                var InpatientServices = db.InPatientServices.DefaultIfEmpty().Where(w => w.PatientId == pat_ids/* && w.In_Patient_Id == in_PatientId*/).OrderByDescending(x => x.CreatedDate).ToList();

                if (InpatientServices.Count > 0 && InpatientServices != null)
                {
                   
                    foreach (var item in InpatientServices)
                    {
                        ServiceDetails sd = new ServiceDetails();
                        sd.Service_ProcedureName = item.Services_Procedure_ItemName;
                        sd.ServiceItemType = item.ServiceType;
                        sd.ServiceItemId = item.Service_ItemId;
                        sd.ServiceItemAmount = Convert.ToString(item.ServiceAmount);
                        sd.PatientType = item.PatientType;
                        sd.ServiceDate = item.CreatedDate == null ? DateTime.Now : item.CreatedDate;
                        sd.UserName = item.UserName;
                        sd.isbilled = Convert.ToBoolean(item.isbilled);
                        list.Add(sd);
                    }
                }

                return (new JavaScriptSerializer().Serialize(list));
            }

        }
        public class ServiceDetails
        {
            public DateTime? ServiceDate { get; set; }
            public string Service_ProcedureName { get; set; }
            public string ServiceItemId { get; set; }
            public string ServiceItemAmount { get; set; }
            public string ServiceItemType { get; set; }
            public string PatientType { get; set; }
            public string UserName { get; set; }
            public Boolean isbilled { get; set; }
        }

        [WebMethod]
        public static string checkDepartment(int PatientID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var inPatROomsList = (from op in db.Previous_Dpts

                                      where op.Patient_ID == PatientID

                                      select new
                                      {
                                          op.Perivious_Dpt_Name,

                                          DepartmentName = db.GetDataValueName("Patient Main Category", op.Perivious_Dpt_Name),
                                          op.Created_Time,
                                          op.Segment1,

                                      }).ToList();
                return (new JavaScriptSerializer()).Serialize(inPatROomsList);
            }
            return "";
        }
        [WebMethod]
        public static string checkOPD_tabs()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var ups = (from St in db.aspnet_Users
                       where St.UserName == AppConfig.UserName
                       select St.OpdAllow).FirstOrDefault();

            return (new JavaScriptSerializer()).Serialize(ups);
        }
        [WebMethod]
        public static string checkRepeat(int PatientID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var inPatROomsList = (from op in db.Out_Patients

                                      where op.Patient_ID == PatientID                                    
                                      select new
                                      {
                                          op.Out_Patient_ID,

                                      }).ToList();
                return (new JavaScriptSerializer()).Serialize(inPatROomsList);
            }
            return "";
        }
        public class Orthor
        {
            public int outPatientID { get; set; }
            public int Pat { get; set; }
            public List<OrthoDetails> OrthoList { get; set; }
        }
        public class OrthoDetails
        {
            public DateTime Date { get; set; }
            public string Organ_Name { get; set; }
            public string Organ_Side { get; set; }
            public string Ortho_History { get; set; }
            public string DM { get; set; }
            public string HTN { set; get; }
            public string IHD { get; set; }
            public string Look { set; get; }
            public string Feel { set; get; }
            public string Move { get; set; }
            public string Special_Tests { set; get; }
            public string Sensory { set; get; }
            public string Motor { get; set; }
            public string Reflexes { set; get; }
            public string Vascular_Status { set; get; }
            public string Others { set; get; }
        }
        [WebMethod]
        public static string SaveOrthoDetail(string btnsave, string OrthoDetails)
        {
            try
            {
                JavaScriptSerializer js = new JavaScriptSerializer();
                var OrthoDetail = js.Deserialize<Orthor>(OrthoDetails);
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                if (btnsave == "Update")
                {
                    List<Ortho> InPatient_Instruction = db.Orthos.Where(i => i.Transaction_ID == OrthoDetail.outPatientID && i.Patient_Type == "OutPatient").ToList();
                    db.Orthos.DeleteAllOnSubmit(InPatient_Instruction);
                    db.SubmitChanges();
                }

                foreach (var test in OrthoDetail.OrthoList)
                {
                    Ortho oInPatient_Ortho = new PMS.Ortho();
                    oInPatient_Ortho.Transaction_ID = OrthoDetail.outPatientID;
                    oInPatient_Ortho.Patient_Type = "OutPatient";
                    oInPatient_Ortho.Organ_Name = test.Organ_Name;
                    oInPatient_Ortho.Organ_Side = test.Organ_Side;                 
                    oInPatient_Ortho.Ortho_History = test.Ortho_History;
                    oInPatient_Ortho.DM = test.DM;
                    oInPatient_Ortho.HTN = test.HTN;

                    oInPatient_Ortho.IHD = test.IHD;
                    oInPatient_Ortho.Look = test.Look;

                    oInPatient_Ortho.Feel = test.Feel;
                    oInPatient_Ortho.Move = test.Move;

                    oInPatient_Ortho.Special_Tests = test.Special_Tests;
                    oInPatient_Ortho.Sensory = test.Sensory;

                    oInPatient_Ortho.Motor = test.Motor;
                    oInPatient_Ortho.Reflexes = test.Reflexes;
                    oInPatient_Ortho.Vascular_Status = test.Vascular_Status;
                    oInPatient_Ortho.Others = test.Others;
                    db.Orthos.InsertOnSubmit(oInPatient_Ortho);
                    db.SubmitChanges();
                }
            }
            //}
            catch (Exception ex)
            {

            }
            return "";
        }

        [WebMethod]
        public static string LoadOrthoDetail(int PatientID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var inPatmedicineList = (from pm in db.Orthos
                                         join op in db.Out_Patients
                                         on pm.Transaction_ID equals op.Out_Patient_ID

                                         where op.Out_Patient_ID == PatientID && pm.Patient_Type == "OutPatient"

                                         select new
                                         {
                                             pm.Organ_Name,
                                             pm.Organ_Side,
                                             pm.Ortho_History,
                                             pm.DM,
                                             pm.HTN,
                                             pm.IHD,
                                             pm.Look,
                                             pm.Feel,
                                             pm.Move,
                                             pm.Special_Tests,
                                             pm.Sensory,
                                             pm.Motor,
                                             pm.Reflexes,
                                             pm.Vascular_Status,
                                             pm.Others
                                         }).ToList();

                return (new JavaScriptSerializer()).Serialize(inPatmedicineList);
            }
            return "";
        }

        [WebMethod]
        public static string LoadMedicinesForHistoryrpt(int PatientID, int oUTID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var inPatmedicineList = (from pm in db.In_Patient_Medicines
                                         join op in db.Out_Patients
                                         on pm.Patient_ID equals op.Out_Patient_ID
                                         where op.Patient_ID == PatientID && pm.Transaction_Type == "OutPatient" && pm.Patient_ID == oUTID

                                         select new { pm.AttendingParamedical_Staff, pm.Frequency, pm.In_Patient_Medicine_ID, pm.Injections, pm.Medicine_Date, pm.Medicine_Name, pm.Oral, pm.Patient_ID, pm.Recomended_Dosage, op.Created_Time, pm.Dosage_From, pm.Dosage_Qty, pm.Other_Instruction }).ToList();

                return (new JavaScriptSerializer()).Serialize(inPatmedicineList);
            }
            return "";
        }
        [WebMethod]
        public static string LoadRecommendedTest(int PatientID, int oUTID)
        {

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var List = (from pm in db.Lab_Test_Details
                            join op in db.Out_Patients
                            on pm.Actual_Patient_ID equals op.Patient_ID
                            where pm.Actual_Patient_ID == PatientID && pm.Test_Description != null

                            select new { pm.Test_Description }).ToList();

                return (new JavaScriptSerializer()).Serialize(List);
            }
            return "";
        }
        [WebMethod]
        public static string LoadSymptom(int PatientID, int oUTID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var List = (from pm in db.Sysmtopms
                            join op in db.Out_Patients
                            on pm.Out_Patient_ID equals op.Out_Patient_ID
                            where pm.Out_Patient_ID == oUTID

                            select new
                            {
                                pm.Duration
                                ,
                                pm.Remarks
                                ,
                                Symtom_Description = db.GetDataValueName("Symtoms", pm.Symtom_ID)
                                ,
                                DaysMonth = db.GetDataValueName("Days_Years_Months", pm.Days_Years_Months)
                            }).ToList();

                return (new JavaScriptSerializer()).Serialize(List);
            }
            return "";
        }
        public class Service
        {
            public int PatId { get; set; }
            public int opdid { get; set; }

            public List<ServiceDetails> ServicesList { get; set; }
        }

        public class ServiceDetailss
        {
            public DateTime? ServiceDate { get; set; }
            public string Service_ProcedureName { get; set; }
            public string ServiceItemId { get; set; }
            public string ServiceItemAmount { get; set; }
            public string ServiceItemType { get; set; }
            public string PatientType { get; set; }
            public string UserName { get; set; }
        }
        [WebMethod]
        public static string SaveServicesDetail(string btnSave, string ServiceDetailss)
        {
            try
            {
                JavaScriptSerializer js = new JavaScriptSerializer();
                var ServiceDetailList = js.Deserialize<Service>(ServiceDetailss);
             
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    
                    var pat_id = (from p in db.Reg_patients
                                  join vs in db.Patients on p.pat_id equals vs.Reg_PatId
                                  where vs.Patient_ID == Convert.ToInt32(ServiceDetailList.PatId)
                                  select p.pat_id).FirstOrDefault();

                    if (btnSave == "Update")
                    {
                        List<InPatientService> inPatientServices = db.InPatientServices.Where(w => w.Ou_Patient_Id == Convert.ToString(ServiceDetailList.opdid)).ToList();
                        db.InPatientServices.DeleteAllOnSubmit(inPatientServices);
                        db.SubmitChanges(); 
                    }

                 
                    foreach (var item in ServiceDetailList.ServicesList)
                    {
                        InPatientService ipser = new InPatientService
                        {
                            PatientId = pat_id,
                            EmergencyId = 0,
                            PatientType = item.ServiceItemType,
                            Services_Procedure_ItemName = item.Service_ProcedureName,
                            Service_ItemId = item.ServiceItemId,
                            Ou_Patient_Id = Convert.ToString(ServiceDetailList.opdid),
                            ServiceType = item.ServiceItemType,
                            ServiceAmount = Convert.ToDecimal(item.ServiceItemAmount),
                            CreatedDate = item.ServiceDate,
                            UserName = item.UserName,
                            isbilled = false
                        };

                        db.InPatientServices.InsertOnSubmit(ipser);
                    }

                    db.SubmitChanges(); 
                }
            }
            catch (Exception ex)
            {
              
                Console.WriteLine(ex.Message); 
                return "Error: " + ex.Message; 
            }

            return "Success";
        }
        public class Proto
        {
            public int PatId { get; set; }
            public int opdid { get; set; }

            public List<ProtoDetailss> ProtoList { get; set; }
        }

        public class ProtoDetailss
        {
            public string ProtoId { get; set; }
            public string Proto_Description { get; set; }
        }
        [WebMethod]
        public static string LoadProtoDetails(string patients_id)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                List<ProtoDetailss> list = new List<ProtoDetailss>();
                var OutPatients_Proto = db.OutPatients_Protos.DefaultIfEmpty().Where(w => w.Outpatient_id == Convert.ToInt32(patients_id)).ToList();

                if (OutPatients_Proto.Count > 0 && OutPatients_Proto != null)
                {
                    //ServiceDetails sd = new ServiceDetails();
                    //    sd.Service_ProcedureName=
                    foreach (var item in OutPatients_Proto)
                    {
                        ProtoDetailss sd = new ProtoDetailss();
                        sd.ProtoId = item.ProtoId;
                        sd.Proto_Description = item.Proto_Description;

                        list.Add(sd);
                    }
                }

                return (new JavaScriptSerializer().Serialize(list));
            }

        }
        [WebMethod]
        public static string SaveProto(string btnSave, string ProtoDetailss)
        {
            try
            {
                JavaScriptSerializer js = new JavaScriptSerializer();
                var ProtDetailList = js.Deserialize<Proto>(ProtoDetailss);

                using (DataBaseDataContext db = new DataBaseDataContext())
                {

                    var pat_id = (from p in db.Reg_patients
                                  join vs in db.Patients on p.pat_id equals vs.Reg_PatId
                                  where vs.Patient_ID == Convert.ToInt32(ProtDetailList.PatId)
                                  select p.pat_id).FirstOrDefault();

                    if (btnSave == "Update")
                    {
                        List<OutPatients_Proto> outpatient_protos = db.OutPatients_Protos.Where(w => w.Outpatient_id == ProtDetailList.opdid).ToList();
                        db.OutPatients_Protos.DeleteAllOnSubmit(outpatient_protos);
                        db.SubmitChanges();
                    }
                    foreach (var item in ProtDetailList.ProtoList)
                    {
                        OutPatients_Proto ipser = new OutPatients_Proto
                        {
                            Patient_Id = pat_id,
                            ProtoId = item.ProtoId,
                            Outpatient_id = ProtDetailList.opdid,
                            Proto_Description = item.Proto_Description
                        };

                        db.OutPatients_Protos.InsertOnSubmit(ipser);
                    }

                    db.SubmitChanges();
                }
            }
            catch (Exception ex)
            {

                Console.WriteLine(ex.Message);
                return "Error: " + ex.Message;
            }

            return "Success";
        }




        [WebMethod]
        public static string SaveTest(string tlist)
        {
            string LabtestID = "";
            Laboratory_Test lt = new Laboratory_Test();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            JavaScriptSerializer oJS = new JavaScriptSerializer();
            var record = oJS.Deserialize<LabTest>(tlist);
            /********************Deleting Previous 0 Value Saved Rows.***********************************/
            List<Laboratory_Test> Laboratory_TestList = db.Laboratory_Tests.Where(i => i.Patient_ID == 0 && i.Transaction_Type == "OutPatient").ToList();
            db.Laboratory_Tests.DeleteAllOnSubmit(Laboratory_TestList);
            db.SubmitChanges();

            if (record.PatientID != null && record.PatientID != "(New)")
            {
                var lstTests = (from t in db.Laboratory_Tests
                                where t.Patient_ID == int.Parse(record.PatientID) && t.Transaction_Type == "OutPatient"
                                select t).FirstOrDefault();
                if (lstTests != null)
                {
                    lstTests.Created_Time = DateTime.Now;
                    LabtestID = lstTests.Lab_Test_ID.ToString();
                    lt.Patient_ID = Convert.ToInt32(record.PatientID);
                }
                else
                {
                    lt.Patient_ID = Convert.ToInt32(record.PatientID);
                    lt.Transaction_Type = "OutPatient";
                    lt.Created_Time = DateTime.Now;
                    db.Laboratory_Tests.InsertOnSubmit(lt);
                    db.SubmitChanges();
                    LabtestID = lt.Lab_Test_ID.ToString();
                }
            }
            else
            {
                lt.Patient_ID = Convert.ToInt32(record.PatientID);
                lt.Transaction_Type = "OutPatient";
                lt.Created_Time = DateTime.Now;
                db.Laboratory_Tests.InsertOnSubmit(lt);
                db.SubmitChanges();
                LabtestID = lt.Lab_Test_ID.ToString();
            }
            /**********Getting Previous details to delete**************/
            var lstTestDetails = db.Lab_Test_Details.Where(t => t.Lab_Test_ID == int.Parse(LabtestID)).ToList();
            var labID = int.Parse(LabtestID);
            DBClass.executeNonQueryWithoutBegin("delete from Lab_Test_Detail where Actual_Patient_ID='" + record.PatID + "'");
            foreach (var test in record.TestList)
            {
                Lab_Test_Detail ltd = new Lab_Test_Detail();

                ltd.Lab_Test_ID = labID;
                ltd.Patient_ID = Convert.ToInt32(record.PatientID);
                var reg_id = (from rg in db.Reg_patients
                              join p in db.Patients on rg.pat_id equals p.Reg_PatId
                              where p.Patient_ID == int.Parse(record.PatID)
                              orderby p.Reg_PatId descending
                              select p.Reg_PatId).FirstOrDefault();


                //ltd.Actual_Patient_ID = Convert.ToInt32(record.PatID);

                ltd.Date = DateTime.Now;
                //ltd.Date = Convert.ToDateTime(test.Date);
                ltd.Test_ID = Convert.ToInt32(test.TestID);
                ltd.Rotation_ID = test.RotationID;
                ltd.L_R_Rotation_ID = test.L_R_Rotation_ID;
                ltd.Catagory_ID = test.Catagory_ID;
                ltd.Dept_ID = test.Dept_ID;
                ltd.Actual_Patient_ID = reg_id;
                ltd.Special_Tests = test.Special_Tests;
                ltd.Area_Of_Interest = test.Area_Of_Interest;
                ltd.Test_Description = test.rotation;
                ltd.showTestDescription = test.showTestDescription;
                bool Duplicate = false;
                Lab_Test_Detail chkasTest = lstTestDetails.Where(tst => tst.Test_ID == ltd.Test_ID && tst.Test_ID != 0).FirstOrDefault();
                if (chkasTest != null)
                {
                    ltd.Recieved_ID = chkasTest.Recieved_ID;
                    ltd.IsBilled = chkasTest.IsBilled;
                    ltd.Is_Result = chkasTest.Is_Result;
                    db.Lab_Test_Details.InsertOnSubmit(ltd);
                    db.SubmitChanges();
                    Duplicate = true;
                }

                if (chkasTest == null)
                {
                    var chkasCategory = lstTestDetails.Where(tst => tst.Catagory_ID == ltd.Catagory_ID && tst.Test_ID == 0).FirstOrDefault();
                    if (chkasCategory != null)
                    {
                        ltd.Recieved_ID = chkasCategory.Recieved_ID;
                        ltd.IsBilled = chkasCategory.IsBilled;
                        ltd.Is_Result = chkasCategory.Is_Result;
                        Duplicate = true;
                        if (chkasCategory != null)
                        {
                            var PrntID = db.Laboratory_Tests.Where(t => t.Parent_Transaction_Type_ID == chkasCategory.Lab_Test_Detail_ID).FirstOrDefault();
                            db.Lab_Test_Details.InsertOnSubmit(ltd);
                            db.SubmitChanges();
                            if (PrntID != null)
                            {
                                PrntID.Parent_Transaction_Type_ID = ltd.Lab_Test_Detail_ID;
                                db.SubmitChanges();
                            }
                        }
                    }
                }
                if (!Duplicate)
                {
                    db.Lab_Test_Details.InsertOnSubmit(ltd);
                    db.SubmitChanges();
                }

            }
            /**********Deleting Previous details**************/
            db.Lab_Test_Details.DeleteAllOnSubmit(lstTestDetails);
            db.SubmitChanges();
            return "";
        }
        [WebMethod]
        public static string GetGroupDepartments()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var dep = from dv in db.DataValues
                      join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                      where vs.ValueSet_Name == "Test Departments"
                      select new { dv.DataValue_Name, dv.DataValue_Description };
            return (new JavaScriptSerializer()).Serialize(dep);
        }
        [WebMethod]
        public static string GetMainDepartments()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var dep = from dv in db.DataValues
                      join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                      where vs.ValueSet_Name == "Main Test Departments"
                      select new { dv.DataValue_Name, dv.DataValue_Description };
            return (new JavaScriptSerializer()).Serialize(dep);
        }
        [WebMethod]
        public static string FillGroupDpte(string maindpt)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            var test = (from i in db.Lab_Tests
                        where i.Main_Department == maindpt.ToString()
                        select new
                        {
                            i.Group_Department,
                            Referring_Doctor = (from dv in db.DataValues where i.Group_Department == dv.DataValue_Name && dv.ValueSet_ID == 67 select dv.DataValue_Description).FirstOrDefault(),
                        }).Distinct().ToList();
            return (new JavaScriptSerializer()).Serialize(test);
        }
        [WebMethod]
        public static string FillCategory(string Grpdpt)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            var test = (from i in db.Lab_Tests
                        where i.Group_Department == Grpdpt.ToString()
                        select new
                        {
                            i.Group_Category,
                            Referring_Doctor = (from dv in db.DataValues where i.Group_Category == dv.DataValue_Name && dv.ValueSet_ID == 70 select dv.DataValue_Description).FirstOrDefault(),
                        }).Distinct().ToList();

            return (new JavaScriptSerializer()).Serialize(test);
        }
        [WebMethod]
        public static string FillTestName(string Cat)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            var test = (from i in db.Lab_Tests
                        where i.Group_Category == Cat.ToString()
                        select new
                        {
                            i.Test_Name,
                            Test_ID = (from dv in db.Lab_Tests where dv.Test_Name == i.Test_Name select dv.Test_ID).FirstOrDefault(),
                        }).Distinct().ToList();

            return (new JavaScriptSerializer()).Serialize(test);
        }

        [WebMethod]
        public static string LoadControlHistory(int PatientID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            int Patien_No = DBClass.GetMRNOBy_RgPatientID(Convert.ToInt32(PatientID));

            var data = (from op in db.Out_Patients
                        join p in db.Patients
                       on op.Patient_ID equals p.Patient_ID
                        join rp in db.Reg_patients
                       on p.Reg_PatId equals rp.pat_id
                        where rp.Patient_No == Patien_No
                        select new
                        {
                            Doctor_Name = (from d in db.HR_Employees
                                           where d.Emp_ID == Convert.ToInt32(op.Doctor_ID)
                                           select d.Emp_Name).FirstOrDefault(),
                            Doctor_ID = op.Doctor_ID,
                            Admission = db.GetDataValueName("Laundary From To", op.Administration),
                            Designation = op.Designation,
                            Discharge = op.Discharge,
                            op.Created_Time,
                            Follow_Up = db.GetDataValueName("FollowUp", op.Follow_Up),
                            op.Folllow_Date,
                            Advice = op.Advice,
                            FinalDiagnosis = op.Final_Diagnosis,
                            Next_Plan = op.NextPlan,
                            op.Updated_Time
                        }).ToList();
            return (new JavaScriptSerializer()).Serialize(data);
        }
        private void BindDropDownList()
        {
            object valueset;   //declare a single object for all valueset            
            valueset = DBClass.GetValueSet("Patient Status");
            db = new DataBaseDataContext(DBClass.ConnectionString());
            List<HR_Employee> EmpList = new List<HR_Employee>();
            EmpList = (from tbl in db.HR_Employees
                       where tbl.IsDoctor == true
                       select tbl).ToList();

            valueset = DBClass.GetValueSet("Laundary From To");
            ddlIssuance_Of.DataSource = valueset;
            ddlIssuance_Of.DataTextField = "DataValue_Description";
            ddlIssuance_Of.DataValueField = "DataValue_Name";
            ddlIssuance_Of.Items.Add(new ListItem("Please Select", "0"));
            ddlIssuance_Of.DataBind();

            valueset = DBClass.GetValueSet("Apgar Score");
            ddlPeads_apgerScore1min.DataSource = valueset;
            ddlPeads_apgerScore1min.DataTextField = "DataValue_Description";
            ddlPeads_apgerScore1min.DataValueField = "DataValue_Name";
            ddlPeads_apgerScore1min.Items.Add(new ListItem("Select Score", "0"));
            ddlPeads_apgerScore1min.DataBind();

            valueset = DBClass.GetValueSet("Apgar Score");
            ddlPeads_apgerScore5min.DataSource = valueset;
            ddlPeads_apgerScore5min.DataTextField = "DataValue_Description";
            ddlPeads_apgerScore5min.DataValueField = "DataValue_Name";
            ddlPeads_apgerScore5min.Items.Add(new ListItem("Select Score", "0"));
            ddlPeads_apgerScore5min.DataBind();

            valueset = DBClass.GetValueSet("Ortho Examination");
            ddlOrthoType.DataSource = valueset;
            ddlOrthoType.DataTextField = "DataValue_Description";
            ddlOrthoType.DataValueField = "DataValue_Name";
            ddlOrthoType.Items.Add(new ListItem("Please Select", "0"));
            ddlOrthoType.DataBind();
            ddlOrthoSide.Items.Add(new ListItem("Please Select", "0"));
            ddlOrthoSide.Items.Add(new ListItem("Left", "Left"));
            ddlOrthoSide.Items.Add(new ListItem("Right", "Right"));
            ddlOrthoSide.DataBind();

            valueset = DBClass.GetValueSet("Patient Main Category");
            ddlPatient_Main_Category.DataSource = valueset;
            ddlPatient_Main_Category.DataTextField = "DataValue_Description";
            ddlPatient_Main_Category.DataValueField = "DataValue_Name";
            ddlPatient_Main_Category.Items.Add(new ListItem("Please Select", "0"));
            ddlPatient_Main_Category.DataBind();

            valueset = DBClass.GetValueSet("FollowUp");
            ddlFOllowUp.DataSource = valueset;
            ddlFOllowUp.DataTextField = "DataValue_Description";
            ddlFOllowUp.DataValueField = "DataValue_Name";
            ddlFOllowUp.Items.Add(new ListItem("Please Select", "0"));
            ddlFOllowUp.DataBind();

            valueset = DBClass.GetValueSet("Proto");
            ddlProto.DataSource = valueset;
            ddlProto.DataTextField = "DataValue_Description";
            ddlProto.DataValueField = "DataValue_Name";
            ddlProto.Items.Add(new ListItem("Please Select", "0"));
            ddlProto.DataBind();

        }

        [WebMethod]
        public static string SyptumNew(string syptum)
        {
            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                DataValue data = new DataValue();
                var CountRepeat = db.DataValues.Where(i => i.DataValue_Description == syptum && i.ValueSet_ID == 1083).ToList();

                if (CountRepeat.Count == 0)
                {
                    data.ValueSet_ID = 1083;
                    var sQuery =
                                  (from staff in db.DataValues
                                   orderby staff.DataValue_Name ascending
                                   select staff.DataValue_Name).Distinct().ToList();
                    var snumber = Convert.ToInt32(DBClass.getField("select (isnull(max(convert(int,DataValue_Name)),0)+1) from DataValues where                                      ValueSet_ID=1083").ToString());
                    //int counter = sQuery.Count;
                    //int snumber = counter + 1;
                    data.DataValue_Name = Convert.ToInt32(snumber).ToString();
                    data.DataValue_Description = syptum;
                    db.DataValues.InsertOnSubmit(data);
                    db.SubmitChanges();
                }
            }
            return "";

        }
        [WebMethod]
        public static string GeMedicineNew(string medicine)
        {
            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                DataValue data = new DataValue();
                data.ValueSet_ID = 83;
                var MaxDataValuename = Convert.ToInt32(DBClass.getField("select (isnull(max(convert(int,DataValue_Name)),0)+1) from DataValues where                                      ValueSet_ID=83").ToString());
                data.DataValue_Name = MaxDataValuename.ToString();
                data.DataValue_Description = medicine;
                data.System_Value = false;
                db.DataValues.InsertOnSubmit(data);
                db.SubmitChanges();
            }
            return "";
        }

        [WebMethod]
        public static string loadEyeHistory()
        {
            string data = string.Empty;



            return data;
        }

        [WebMethod]
        public static string SaveRecord(PatientVisitData data, List<OutPatientEyeInfo> eyeInfos)
        {
            try
            {
                var id = "";
                using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
                {

                    Out_Patient OPD;
                  
                        if (data.btnsave == "Save" && data.btnsaveVital == "Save Vital")
                        {

                            OPD = new Out_Patient();
                            OPD.Patient_ID = Convert.ToInt32(data.Patient_ID);
                            OPD.Reg_PatId = Convert.ToInt32(data.reg_ID);
                        }
                        else
                        {
                            OPD = (from tbl in db.Out_Patients
                                   where tbl.Out_Patient_ID == Convert.ToInt32(data.Out_Patient_ID)
                                   select tbl).FirstOrDefault();
                            OPD.Updated_By = AppConfig.UserID;
                            OPD.Updated_Time = DateTime.Now;
                        }
                        OPD.L_M_P = data.L_M_P;
                        OPD.spo2 = data.SPO2;
                        OPD.EDD = data.Edd;
                        OPD.BSR = data.Bsr;
                        OPD.BMI = data.Bmi;
                        OPD.pulse_Min = data.pulse_Min;
                        OPD.BP_mm_Hg = data.BP_mm_Hg;
                        OPD.Temp_C = data.Temp_C;
                        OPD.Respiration_Min = data.Respiration_Min;
                        OPD.Height_Cm = data.Height_Cm;
                        OPD.Weight_Kg = data.Weight_Kg;
                        OPD.MUAC = data.MUAC;
                        OPD.OFC = data.OFC;
                        OPD.ProvisionalDiagnosis = data.Provisional_Diagnosis;
                        OPD.HistoryOfPeresentIllness = data.HistoryOfPeresentIllness;
                        OPD.HistoryOfFamily = data.HistoryOfFamily;
                        OPD.HistoryOfPastIllness = data.HistoryOfPastIllness;
                        OPD.DevelopmentHistory = data.DevelopmentHistory;
                        OPD.VaccinationHistory = data.VaccinationHistory;
                        OPD.NutritionHistory = data.NutritionHistory;
                        OPD.CVS = data.CVS;
                        OPD.GIT = data.GIT;
                        OPD.RESP = data.RESP;
                        OPD.AllergiesHistory = data.AllergiesHistory;
                        OPD.TreatmentHistory = data.TreatmentHistory;
                        OPD.SocioEconomicHistory = data.SocioEconomicHistory;
                        OPD.CNS = data.CNS;
                        OPD.URG = data.URG;
                        OPD.GYNAE = data.GYNAE;
                        OPD.Local = data.Local;
                        OPD.Mucculor = data.Mucculor;
                        OPD.ObstetricHistory = data.ObstetricHistory;
                        OPD.txtRemarksHistory = data.txtRemarksHistory;
                        OPD.chkJVP = data.chkJVP;
                        OPD.chkPallor = data.chkPallor;
                        OPD.chkaganoris = data.chkaganoris;
                        OPD.chkunconceed = data.chkunconceed;
                        OPD.chkjaundice = data.chkjaundice;
                        OPD.hydration = data.hydration;
                        OPD.edema = data.edema;
                        OPD.chk1 = data.chk1;
                        OPD.chk2 = data.chk2;
                        OPD.chk3 = data.chk3;
                        OPD.chk4 = data.chk4;
                        OPD.chk5 = data.chk5;
                        OPD.Discharge = data.Discharged;
                        OPD.No_medicine = data.No_Medicine;
                        OPD.No_LabTest = data.No_LabTest;
                        OPD.txtInputBox1 = data.Other;
                        if (data.Discharged == true)
                        {
                            OPD.discharge_date = DateTime.Now;
                        }
                        //OPD.Doctor_ID = Convert.ToString(AppConfig.UserID);
                        OPD.Doctor_ID = data.Doctor_ID;
                        OPD.Designation = data.Designation;
                        OPD.Final_Rec = data.Final_Rec;
                        OPD.Final_Diagnosis = data.FinalDiagnosis;
                        OPD.Administration = data.Administration.ToString(); ;
                        OPD.Control_Date = Convert.ToDateTime(DateTime.Now);
                        OPD.Follow_Up = data.Follow_Up.ToString();
                        OPD.Proto = data.Proto.ToString();
                        OPD.Folllow_Date = Convert.ToDateTime(data.Follow_Date);
                        OPD.Advice = data.Advice;
                        OPD.Special_Test = data.Special_Test;
                        OPD.Area_Of_Interest = data.Area_Of_Interest;
                        OPD.Birth_History = data.Birth_History;
                        if (data.Reffer_To != "")
                        {
                            var P = (from tbl in db.Patients
                                     where tbl.Patient_ID == data.Patient_ID
                                     select tbl).FirstOrDefault();

                           // P.Patient_Main_Category = data.Reffer_To;
                          //  db.SubmitChanges();

                            var D = (from tbl in db.Previous_Dpts
                                     where tbl.Patient_ID == data.Patient_ID && tbl.Perivious_Dpt_Name == data.Reffer_To
                                     select tbl).FirstOrDefault();
                            if (D == null)
                            {
                                Previous_Dpt Previous_Dpt = new Previous_Dpt();
                                Previous_Dpt.Patient_ID = data.Patient_ID;
                                Previous_Dpt.Perivious_Dpt_Name = data.Reffer_To;
                                Previous_Dpt.Created_Time = DateTime.Now;
                                db.Previous_Dpts.InsertOnSubmit(Previous_Dpt);
                                db.SubmitChanges();
                            }
                        }
                        OPD.Reffer_To = data.Reffer_To.ToString();
                        OPD.Reffer_No = data.Reffer_No;
                        OPD.reffer_doc = Convert.ToInt32(data.Reffer_doc);
                        OPD.Drug_History = data.Drug_History;
                        OPD.Personal_History = data.Personal_History;
                        OPD.ENT_Throat_IDL = data.ENT_Throat_IDL.ToString();
                        OPD.ENT_Throat_Nose = data.ENT_Throat_Nose.ToString();
                        OPD.ENT_Ear_Right = data.ENT_Ear_Right.ToString();
                        OPD.Ent_Ear_Left = data.Ent_Ear_Left.ToString();
                        OPD.ENT_Rinnes_Right_PosNeg = data.ENT_Rinnes_Right_PosNeg;
                        OPD.ENT_Rinnes_Lft_PosNeg = data.ENT_Rinnes_Lft_PosNeg;
                        OPD.ENT_Rinnes_Right_FalseNeg = data.ENT_Rinnes_Right_FalseNeg;
                        OPD.ENT_Rinnes_Lft_FalseNeg = data.ENT_Rinnes_Lft_FalseNeg;
                        OPD.ENT_Webber_Central = data.ENT_Webber_Central;
                        OPD.ENT_Webber_Lateralized = data.ENT_Webber_Lateralized;
                        OPD.ENT_Investigation_PTA = data.ENT_Investigation_PTA;
                        OPD.ENT_Investigation_Tympanometry = data.ENT_Investigation_Tympanometry;
                        OPD.ENT_Rinnes_Right_Neg = data.ENT_Rinnes_Right_Neg;
                        OPD.ENT_Rinnes_Lft_Neg = data.ENT_Rinnes_Lft_Neg;
                        OPD.ENT_Rinnes_Right_FNeg = data.ENT_Rinnes_Right_FNeg;
                        OPD.ENT_Rinnes_Lft_FNeg = data.ENT_Rinnes_Lft_FNeg;

                        OPD.Ent_Com_Right_pos = data.ComRightPos.ToString();
                        OPD.Ent_Com_Left_pos = data.ComLeftPos.ToString();
                        OPD.Ent_Com_Right_Neg = data.ComRightNeg.ToString();
                        OPD.Ent_Com_Left_Neg = data.ComLeftNeg.ToString();
                        OPD.Ent_Com_Right_False = data.ComRightF.ToString();
                        OPD.Ent_Com_Left_False = data.ComLeftF.ToString();
                        OPD.Ent_Com_Right_False_Neg = data.ComRightFNeg.ToString();
                        OPD.Ent_Com_Left_False_Neg = data.ComLeftFNeg.ToString();
                        OPD.Ent_Com_Central = data.ComCentral.ToString();
                        OPD.Ent_Com_Lateralized = data.ComLateralized.ToString();
                        OPD.Ent_Com_PTA = data.ComPTA.ToString();
                        OPD.Ent_Com_Tympanometry = data.ComTympanometry.ToString();

                        OPD.Psychiatry_Informant = data.txtInformant;
                        OPD.Psychiatry_Source_Referral = data.txtSourceOfReferral;
                        OPD.Psychiatry_Neck_Holding = data.chkNeckHolding;
                        OPD.Psychiatry_Walking = data.chkWalking;
                        OPD.Psychiatry_Talking = data.chkTalking;
                        OPD.Psychiatry_Others = data.chkOthers;
                        OPD.Psychiatry_Menarche = data.txtMenarche;
                        OPD.Psychiatry_Menstrual = data.txtMenstrual;
                        OPD.Psychiatry_Attachment_Separation = data.txtAttachmentSeparationfromParents;
                        OPD.Psychiatry_Health = data.txtHealth;
                        OPD.Psychiatry_Nail_Biting = data.chkNailBiting.ToString();
                        OPD.Psychiatry_Temper_Tantrums = data.chkTemperTantrums.ToString();
                        OPD.Psychiatry_Bed_Wetting = data.chkBedWetting.ToString();
                        OPD.Psychiatry_Academics = data.txtAcademics;
                        OPD.Psychiatry_Peer_Relationship = data.txtPeerRelationship;
                        OPD.Psychiatry_Behaviour = data.txtBehaviour;
                        OPD.Psychiatry_Occupational_History = data.txtOccupationalHistory;
                        OPD.Psychiatry_Sexual_History = data.txtMaritalRelationshipSexualHistory;
                        OPD.Psychiatry_Substance_Use = data.txtSubstanceUse;
                        OPD.Psychiatry_Forensic_Use = data.txtForensicUse;
                        OPD.Psychiatry_Relationship = data.txtRelationship;
                        OPD.Psychiatry_Leisure_Activities = data.txtLeisureActivities;
                        OPD.Psychiatry_Attitude_Standards = data.txtAttitudetoSelfandStandards;
                        OPD.Psychiatry_Prevalling_Mood = data.txtPrevallingMood;
                        OPD.Psychiatry_Reaction_Stress = data.txtReactionPattrentoStress;
                        OPD.Psychiatry_Religious_Practices = data.txtReligiousPracticesAttitute;
                        OPD.Psychiatry_Father = data.txtFather;
                        OPD.Psychiatry_Mother = data.txtMother;
                        OPD.Psychiatry_Siblings = data.txtSiblings;
                        OPD.Psychiatry_Home_Atmosphere = data.txtHomeAtmosphererelationshipsocialclass;
                        OPD.Psychiatry_Familial_Illness = data.txtFamilialIllness;
                        OPD.Psychiatry_Actual_age = data.txtActualandapparentage;
                        OPD.Psychiatry_Race = data.txtRace;
                        OPD.Psychiatry_Tattoos_body_scars = data.txtTattoosbodypiercingandscars;
                        OPD.Psychiatry_Body_Habitus = data.txtBodyHabitus;
                        OPD.Psychiatry_Dress = data.txtDress;
                        OPD.Psychiatry_Hygiene = data.txtHygiene;
                        OPD.Psychiatry_Psychomotor_Activity = data.txtPsychomotorActivity;
                        OPD.Psychiatry_Involuntary_movements = data.txtInvoluntarymovements;
                        OPD.Psychiatry_Dystonia_EPS = data.txtDystoniaEPS;
                        OPD.Psychiatry_Tardive_dyskinesia = data.txtTardivedyskinesia;
                        OPD.Psychiatry_Tics = data.txtTics;
                        OPD.Psychiatry_Tremors = data.txtTremors;
                        OPD.Psychiatry_Attentiveness_interview = data.txtAttentivenesstointerview;
                        OPD.Psychiatry_Eye_Contact = data.txtEyeContact;
                        OPD.Psychiatry_Level_Consciousness = data.txtLevelofConsciousness;
                        OPD.Psychiatry_Rate = data.txtRate;
                        OPD.Psychiatry_Rhythm = data.txtRhythm;
                        OPD.Psychiatry_Volume = data.txtVolume;
                        OPD.Psychiatry_Tone = data.txtTone;
                        OPD.Psychiatry_Modulation = data.txtModulation;
                        OPD.Psychiatry_Depressed = data.txtDepressed;
                        OPD.Psychiatry_Elated = data.txtElated;
                        OPD.Psychiatry_Irritable = data.txtIrritable;
                        OPD.Psychiatry_Labile = data.txtLabile;
                        OPD.Psychiatry_Incongruent = data.txtIncongruent;
                        OPD.Psychiatry_Blunting_Flattening_Apathy = data.txtbluntingflatteningapathy;
                        OPD.Psychiatry_Thinking = data.txtThinkingPremeditation;
                        OPD.Psychiatry_Plans = data.txtPlans;
                        OPD.NextPlan = data.txtNextPlan;
                        OPD.Psychiatry_Actions = data.txtActions;
                        OPD.Psychiatry_Preservative = data.txtPreservative;
                        OPD.Psychiatry_LoosAssociation = data.txtLoosAssociation;
                        OPD.Psychiatry_Tangentiaility = data.txtTangentiaility;
                        OPD.Psychiatry_Circumstantiality = data.txtCircumstantiality;
                        OPD.Psychiatry_Flight_Ideas = data.txtFlightofIdeas;
                        OPD.Psychiatry_Thought_Insertion = data.txtThoughtInsertion;
                        OPD.Psychiatry_Thought_Withdrawal = data.txtThoughtWithdrawal;
                        OPD.Psychiatry_Thought_Broadcasting = data.txtThoughBroadcasting;
                        OPD.Psychiatry_Thought_Control = data.txtThoughControl;
                        OPD.Psychiatry_Dellusion = data.txtDellusion;
                        OPD.Psychiatry_Overvalued_Ideas = data.txtovervaluedideas;
                        OPD.Psychiatry_Depresonalization = data.txtDepresonalization;
                        OPD.Psychiatry_Derealization = data.txtDerealization;
                        OPD.Psychiatry_Obsession = data.txtthrougObsession;
                        OPD.Psychiatry_Phobies = data.txtthrougPhobies;
                        OPD.Psychiatry_Homocidial_Ideas = data.txtthrougHomocidialIdeas;
                        OPD.Psychiatry_Illusion = data.txtillusion;
                        OPD.Psychiatry_Hallucination = data.txtHallucinationAuditoryVisualOlfactoryGustatoryTactile;
                        OPD.Psychiatry_Orientation_Time = data.txtorientationtime;
                        OPD.Psychiatry_Place = data.txtplace;
                        OPD.Psychiatry_Person = data.txtperson;
                        OPD.Psychiatry_Attention_Concentration = data.txtAttentionConcentrationSerial7Test;
                        OPD.Psychiatry_Days_Week = data.txtOrDaysOfWeekReverseOrder;
                        OPD.Psychiatry_Immediate_Memory = data.txtImmediatememory;
                        OPD.Psychiatry_Recent_Events = data.txtshorttermrecentevents;
                        OPD.Psychiatry_Adress_Recall_Two = data.txtadressrecallafter2minutes;
                        OPD.Psychiatry_Remote_Events = data.txtlongtermremoteevents;
                        OPD.Psychiatry_Adress_Recall_Five = data.txtadressrecallafter5minues;
                        OPD.Psychiatry_General_knowledge = data.txtgeneralknowledgequestion;
                        OPD.Psychiatry_Arthemetic_Calculation = data.txtsimplearthemeticcalculation;
                        OPD.Psychiatry_Abstraction = data.txtabstrationconcertethinking;
                        OPD.Psychiatry_Insight = data.txtinsight;

                        OPD.DermaFace = data.DermaFace;
                        OPD.DermaNeck = data.DermaNeck;
                        OPD.DermaTrunk = data.DermaTrunk;
                        OPD.DermaUpperLimb = data.DermaUpperLimb;
                        OPD.DermaLowerLimb = data.DermaLowerLimb;
                        OPD.DermaFlexures = data.DermaFlexures;
                        OPD.DermaGenitalias = data.DermaGenitalias;
                        OPD.DermaHair = data.DermaHair;
                        OPD.DermaNail = data.DermaNail;
                        OPD.DermaMucousMembrane = data.DermaMucousMembrane;
                        OPD.DermaEyes = data.DermaEyes;
                        OPD.DermaEars = data.DermaEars;
                        OPD.DermaNose = data.DermaNose;
                        OPD.DermaLips = data.DermaLips;
                        OPD.Psychiatry_HBM_Problem = data.HBM_Problem;
                        OPD.Psychiatry_HBM_Caused = data.HBM_Caused;
                        OPD.Psychiatry_HBM_Started = data.HBM_Started;
                        OPD.Psychiatry_HBM_Course = data.HBM_Course;
                        OPD.Psychiatry_HBM_Treatment = data.HBM_Treatment;
                        OPD.Psychiatry_HBM_Effects = data.HBM_Effects;
                        OPD.Psychiatry_PE_Pluse = data.PE_Pluse;
                        OPD.Psychiatry_PE_BP = data.PE_BP;
                        OPD.Psychiatry_PE_Temperature = data.PE_Temperature;
                        OPD.Psychiatry_PE_Weight = data.PE_Weight;
                        OPD.Psychiatry_PE_RespiratoryRate = data.PE_RespiratoryRate;
                        OPD.Psychiatry_PE_Jaundice = data.PE_Jaundice;
                        OPD.Psychiatry_PE_Anemia = data.PE_Anemia;
                        OPD.Psychiatry_PE_Cyanosis = data.PE_Cyanosis;
                        OPD.Psychiatry_PE_Clubbing = data.PE_Clubbing;
                        OPD.Psychiatry_PE_JVP = data.PE_JVP;
                        OPD.Psychiatry_PE_LymphNodes = data.PE_LymphNodes;
                        OPD.Psychiatry_PE_Edema = data.PE_Edema;
                        OPD.Psychiatry_PE_Respiratory = data.PE_Respiratory;
                        OPD.Psychiatry_PE_Cardiovascular = data.PE_Cardiovascular;
                        OPD.Psychiatry_PE_Gastro_Intestinal = data.PE_Gastro_Intestinal;
                        OPD.Psychiatry_PE_Observation = data.PE_Observation;
                        OPD.Psychiatry_PE_Cranial_Nerves = data.PE_Cranial_Nerves;
                        OPD.Psychiatry_PE_Limb_Strength = data.PE_Limb_Strength;
                        OPD.Psychiatry_PE_Spasticity = data.PE_Spasticity;
                        OPD.Psychiatry_PE_Position = data.PE_Position;
                        OPD.Psychiatry_PE_Vibration = data.PE_Vibration;
                        OPD.Psychiatry_PE_Stereognosis = data.PE_Stereognosis;
                        OPD.Psychiatry_PE_Pain = data.PE_Pain;
                        OPD.Psychiatry_PE_Biceps = data.PE_Biceps;
                        OPD.Psychiatry_PE_Triceps = data.PE_Triceps;
                        OPD.Psychiatry_PE_Brachioradialis = data.PE_Brachioradialis;
                        OPD.Psychiatry_PE_Quadriceps = data.PE_Quadriceps;
                        OPD.Psychiatry_PE_Patellar = data.PE_Patellar;
                        OPD.Psychiatry_PE_Achilles = data.PE_Achilles;
                        OPD.Psychiatry_PE_Extensor = data.PE_Extensor;
                        OPD.Psychiatry_PE_Frontal = data.PE_Frontal;
                        OPD.Psychiatry_PE_Finger = data.PE_Finger;
                        OPD.Psychiatry_PE_Heel = data.PE_Heel;
                        OPD.Psychiatry_PE_Movements = data.PE_Movements;
                        OPD.Psychiatry_PE_Gait = data.PE_Gait;
                        OPD.Psychiatry_PE_Neck_Rigidity = data.PE_Neck_Rigidity;
                        OPD.Psychiatry_PE_Kerning_Sign = data.PE_Kerning_Sign;
                        OPD.Psychiatry_PE_Brudzinki_Sign = data.PE_Brudzinki_Sign;
                        OPD.Psychiatry_For_Summary = data.For_Summary;
                        OPD.Psychiatry_For_Diagnosis = data.For_Diagnosis;
                        OPD.Psychiatry_For_AxisI = data.For_AxisI;
                        OPD.Psychiatry_For_AxisII = data.For_AxisII;
                        OPD.Psychiatry_For_AxisIII = data.For_AxisIII;
                        OPD.Psychiatry_For_AxisIV = data.For_AxisIV;
                        OPD.Psychiatry_For_AxisV = data.For_AxisV;
                        OPD.Psychiatry_For_PredisposingFactors = data.For_PredisposingFactors;
                        OPD.Psychiatry_For_PrecipitatingFactors = data.For_PrecipitatingFactors;
                        OPD.Psychiatry_For_PrepetuatingFactors = data.For_PrepetuatingFactors;
                        OPD.Psychiatry_For_Investigation = data.For_Investigation;
                        OPD.Psychiatry_For_Medical = data.For_Medical;
                        OPD.Psychiatry_For_Psychological = data.For_Psychological;
                        OPD.Psychiatry_Major_Issues = data.For_Major_Issues;
                        OPD.Psychiatry_For_Strengths = data.For_Strengths;
                        OPD.Psychiatry_For_Goals = data.For_Goals;
                        OPD.Psychiatry_For_Strategies = data.For_Strategies;

                        OPD.Peads_weight = data.txtPeads_weight;
                        OPD.Peads_Length = data.txtPeads_Length;
                        OPD.Peads_HC = data.txtPeads_HC;
                        OPD.Peads_General_Appearance = data.txtPeads_General_Appearance;
                        OPD.Peads_Cyanosis = data.chkPeads_Cyanosis;
                        OPD.Peads_Jaundice = data.chkPeads_Jaundice;
                        OPD.Peads_Lethargy = data.chkPeads_Lethargy;
                        OPD.Peads_Rash = data.chkPeads_Rash;
                        OPD.Peads_Others = data.txtPeads_Others;
                        OPD.Peads_Caput = data.chkPeads_Caput;
                        OPD.Peads_Cephalhematoma = data.chkPeads_Cephalhematoma;
                        OPD.Peads_Anterioropen = data.rdbPeads_Anterioropen;
                        OPD.Peads_AnteriorClose = data.rdbPeads_AnteriorClose;
                        OPD.Peads_Dextrocardia = data.chkPeads_Dextrocardia;
                        OPD.Peads_Bulging = data.chkPeads_Bulging;
                        OPD.Peads_Murmur = data.chkPeads_Murmur;
                        OPD.Peads_HeartSound = data.txtPeads_HeartSound;
                        OPD.Peads_Nasal = data.chkPeads_Nasal;
                        OPD.Peads_Recessions = data.chkPeads_Recessions;
                        OPD.Peads_AddedSounds = data.txtPeads_AddedSounds;
                        OPD.Peads_Flat = data.rdbPeads_Flat;
                        OPD.Peads_Distended = data.rdbPeads_Distended;
                        OPD.Peads_Scaphoid = data.rdbPeads_Scaphoid;
                        OPD.Peads_Liver = data.chkPeads_Liver;
                        OPD.Peads_Spleen = data.chkPeads_Spleen;
                        OPD.Peads_GITOthers = data.txtPeads_GITOthers;
                        OPD.Peads_Sucking = data.chkPeads_Sucking;
                        OPD.Peads_Rooting = data.chkPeads_Rooting;
                        OPD.Peads_Moro = data.chkPeads_Moro;
                        OPD.Peads_CNSOthers = data.txtPeads_CNSOthers;
                        OPD.Peads_FullTerm = data.chkPeads_FullTerm;
                        OPD.Peads_PreTerm = data.chkPeads_PreTerm;
                        if (!string.IsNullOrEmpty(data.txtPeads_DateOfDelivery))
                            OPD.Peads_DateOfDelivery = Convert.ToDateTime(data.txtPeads_DateOfDelivery);
                        OPD.Peads_TimeOfDelivery = data.txtPeads_TimeOfDelivery;
                        OPD.Peads_Booked = data.rdbPeads_Booked;
                        OPD.Peads_UnBooked = data.rdbPeads_UnBooked;
                        OPD.Peads_DAIHandling = data.chkPeads_DAIHandling;
                        OPD.Peads_ANTURash = data.chkPeads_ANTURash;
                        OPD.Peads_PIH = data.chkPeads_PIH;
                        OPD.Peads_GDM = data.chkPeads_GDM;
                        OPD.Peads_Vacinated = data.chkPeads_Vacinated;
                        OPD.Peads_ANTOthers = data.txtPeads_ANTOthers;
                        OPD.Peads_SVD = data.rdbPeads_SVD;
                        OPD.Peads_LSCS = data.rdbPeads_LSCS;
                        OPD.Peads_Emergency = data.rdbPeads_Emergency;
                        OPD.Peads_Elective = data.rdbPeads_Elective;
                        OPD.Peads_PlaceOfDelivery = data.txtPeads_PlaceOfDelivery;
                        OPD.Peads_IndicationForLSCS = data.txtPeads_IndicationForLSCS;
                        OPD.Peads_apgerScore1min = data.Peads_apgerScore1min;
                        OPD.Peads_apgerScore5min = data.Peads_apgerScore5min;
                        OPD.Peads_Resuscitation = data.chkPeads_Resuscitation;
                        OPD.Peads_NatalOthers = data.txtPeads_NatalOthers;
                        OPD.Peads_Moaning = data.chkPeads_Moaning;
                        OPD.Peads_RespDistress = data.chkPeads_RespDistress;
                        OPD.Peads_PostNATALCyanosis = data.chkPeads_PostNATALCyanosis;
                        OPD.Peads_Fits = data.chkPeads_Fits;
                        OPD.Peads_ReluctanceToFeed = data.chkPeads_ReluctanceToFeed;
                        OPD.Peads_PostNatalOthers = data.txtPeads_PostNatalOthers;
                        OPD.DRE = data.chkdre;
                        OPD.Heptomology = data.Heptomology;
                        OPD.Splenomegaly = data.Splenomegaly;
                        OPD.Proctoscopy = data.chkProctoscopy;
                        OPD.Abdominal = data.Abdominal;
                        OPD.PA_Gynae = data.Pa_gynae;
                        OPD.PS_Gynae = data.ps_gynae;
                        OPD.Uterus = data.uterus;
                        OPD.FX = data.fx;
                        OPD.PS_Obs = data.ps_obs;
                        OPD.PV_Obs = data.pv_obs;
                        OPD.SFH = data.sfh;
                        OPD.LIE = data.lie;
                        OPD.Presentation = data.presentation;
                        OPD.FHR = data.fhr;
                        OPD.Engagement = data.engagement;
                        if (data.btnsave == "Save" && data.btnsaveVital == "Save Vital")
                        {
                            OPD.Book_ID = AppConfig.Book_ID;
                            OPD.Created_By = AppConfig.UserID;
                            OPD.Created_Time = DateTime.Now;
                            OPD.Company_ID = AppConfig.Company_ID;
                            db.Out_Patients.InsertOnSubmit(OPD);


                            string SMS_Contant = "عارف میموریل ہسپتال پر اعتماد کرنے کا شکریہ۔صحت کارڈ پر مریضوں کا علاج تسلی بخش کیا جارہاہے۔مریضوں کو کھانا بھی دیا جاتاہے۔سہولیات کی بہتری کےلیےاس نمبرپررابط کریں۔03366581000";

                            string msg = "";
                            // string CellNumber = txtMobile1.Text;
                            string CellNumber = (from tbl in db.Patients
                                                 where tbl.Patient_ID == data.Patient_ID
                                                 select tbl.Mobile1).FirstOrDefault();

                        }
                        db.SubmitChanges();

                        #region 'Eye Info region'
                        string sql = string.Empty;
                        if (data.btnsave.Trim() == "Update")
                        {
                            sql = "Delete from Out_Patient_Eye_Info where Out_Patient_ID = " + OPD.Out_Patient_ID + " ";
                            sql += " Delete from Out_Patient_Slit_Lamp_Exam where Out_Patient_ID = " + OPD.Out_Patient_ID + "";
                            DBClass.executeNonQueryWithoutBegin(sql);
                        }
                        /*
                         * [0] : Type
                         * [1] : Right Eye
                         * [2] : Left Eye
                         */
                        foreach (var info in eyeInfos)
                        {
                            Out_Patient_Eye_Info opdEye = new Out_Patient_Eye_Info();
                            opdEye.Out_Patient_ID = info.Out_Patient_ID;
                            opdEye.Patient_ID = info.Patient_ID;
                            opdEye.Info_Type = info.Info_Type.Trim().ToUpper();
                            opdEye.Right_Eye = info.Right_Eye;
                            opdEye.Left_Eye = info.Left_Eye;
                            
                            db.Out_Patient_Eye_Infos.InsertOnSubmit(opdEye);
                        }
                        
                        #endregion

                        #region 'Slit Lamp Exam'
                        /*
                         * [0] : Right Eye
                         * [1] : Left Eye
                         */
                        Out_Patient_Slit_Lamp_Exam opdSlitLamp = new Out_Patient_Slit_Lamp_Exam();
                        opdSlitLamp.Interior_Right = data.Interior_Right;
                        opdSlitLamp.Interior_Left = data.Interior_Left;
                        opdSlitLamp.Posterior_Right = data.Posterior_Right;
                        opdSlitLamp.Posterior_Left = data.Posterior_Left;

                        opdSlitLamp.Patient_ID = OPD.Patient_ID;
                        opdSlitLamp.Out_Patient_ID = OPD.Out_Patient_ID;

                        db.Out_Patient_Slit_Lamp_Exams.InsertOnSubmit(opdSlitLamp);

                        #endregion

                        /***********Setting 0 patient id inserted medicine to current out patient id****************/

                        List<In_Patient_Medicine> list = db.In_Patient_Medicines.Where(p => p.Patient_ID == 0 && p.Transaction_Type == "OutPatient").ToList();
                        foreach (In_Patient_Medicine med in list)
                        {
                            med.Patient_ID = OPD.Out_Patient_ID;
                        }
                        /***********Setting 0 patient id inserted eyes to current out patient id****************/

                        List<PMS.EyeDetail> eyelist = db.EyeDetails.Where(t => t.TransactionType == "OutPatient" && t.TransactionID == 0).ToList();
                        foreach (PMS.EyeDetail eye in eyelist)
                        {
                            eye.TransactionID = OPD.Out_Patient_ID;
                        }
                        /***********Setting 0 patient id inserted test to current out patient id****************/

                        Laboratory_Test test = db.Laboratory_Tests.Where(p => p.Patient_ID == 0 && p.Transaction_Type == "OutPatient").FirstOrDefault();
                        if (test != null)
                            test.Patient_ID = OPD.Out_Patient_ID;



                        /***********Setting 0 patient id inserted Ortho to current out patient id****************/
                        List<PMS.Ortho> ortholist = db.Orthos.Where(t => t.Patient_Type == "OutPatient" && t.Transaction_ID == 0).ToList();
                        foreach (PMS.Ortho orth in ortholist)
                        {
                            orth.Transaction_ID = OPD.Out_Patient_ID;
                        }
                        db.SubmitChanges();
                         id = OPD.Out_Patient_ID.ToString();
                     }
                
                return id.ToString();
            }
            catch (Exception ex)
            {
                return ex.Message.ToString();
            }
        }

        [WebMethod]
        public static string loadEyeHistory(int Out_Patient_ID)
        {
            string data = string.Empty;

            DataBaseDataContext db = new DataBaseDataContext();
            var d = db.sp_Out_Patient_Eye_History(Out_Patient_ID);
            if (d != null)
            {
                data = (new JavaScriptSerializer()).Serialize(d);
            }

            return data;
        }

        [WebMethod]
        public static string getSlitInfo(int Out_Patient_ID)
        {
            string data = string.Empty;
            DataBaseDataContext db = new DataBaseDataContext();

            var d = (from e in db.Out_Patient_Slit_Lamp_Exams where e.Out_Patient_ID == Out_Patient_ID select e).ToList();
            if (d != null)
            {
                data = (new JavaScriptSerializer()).Serialize(d);
            }

            return data;
        }

        [WebMethod]
        public static string getEyeInfo(int Out_Patient_ID)
        {
            string data = string.Empty;
            DataBaseDataContext db = new DataBaseDataContext();

            var d = (from e in db.Out_Patient_Eye_Infos where e.Out_Patient_ID == Out_Patient_ID select e).ToList();
            if (d != null)
            {
                data = (new JavaScriptSerializer()).Serialize(d);
            }

            return data;
        }

        private void FillOutPatientForm(int PatientID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            Out_Patient OPD = new Out_Patient();
            var qry = db.sp_FillOutPatientForm(PatientID).FirstOrDefault();


            if (qry.DRE.HasValue == true)
                chkDRE.Checked = qry.DRE.Value;
            else
                chkDRE.Checked = false;

            if (qry.Proctoscopy.HasValue == true)
                chkProctoscopy.Checked = qry.Proctoscopy.Value;
            else
                chkProctoscopy.Checked = false;
            txtAbdomin.Text = qry.Abdominal;
            txtPA_Gynae.Text = qry.PA_Gynae;
            txtPS_Gynae.Text = qry.PS_Gynae;
            txtUterus.Text = qry.Uterus;
            txtFX.Text = qry.FX;
            txtPS_OBS.Text = qry.PS_Obs;
            txtPV.Text = qry.PV_Obs;
            txtSFH.Text = qry.SFH;
            txtLIE.Text = qry.LIE;
            txtPresentation.Text = qry.Presentation;
            txtFHR.Text = qry.FHR;
            txtEngagement.Text = qry.Engagement;
            Final_Rec.Text = qry.Final_Rec;
            vlblPatients_Name.Text = qry.Full_Name;
            txtOut_Patient_ID.Text = PatientID.ToString();
            hdfPatient_ID.Value = qry.Patient_ID.ToString();
            hdfReg_ID.Value = qry.Reg_PatId.ToString();
            txtPatient_ID.Text = qry.Patient_ID.ToString();
            if (qry.Entry_Date != null)
                vLbl_RegDate.Text = qry.Entry_Date.Value.ToString(AppConfig.DateFormat);
            vlblPatients_Name.Text = qry.Full_Name;
            vLbl_Age.Text = qry.Age_years;
            vLbl_Contact.Text = qry.Mobile1;
            vLbl_Adress.Text = qry.Permanent_Address;
            vLbl_Gender.Text = db.GetDataValueName("Gender", qry.Gender);
            txtPuls.Text = qry.pulse_Min;
             txtBP.Text = qry.BP_mm_Hg;
              txtTemp.Text = qry.Temp_C;
            txtRespiration.Text = qry.Respiration_Min;
            txtHeight.Text = qry.Height_Cm;
            txtWeight.Text = qry.Weight_Kg;
            txtRefer_To_Hospital.Text = qry.Refer_To_Hospital;
            txtLMP.Text = qry.L_M_P;
            txtspo2.Text = qry.spo2;
            txtedd.Text = qry.EDD;
            txtBMI.Text = qry.BMI;
            TxtBSR.Text = qry.BSR;
            txtMUAC.Text = qry.MUAC;
            txtOFC.Text = qry.OFC;
            txtDevelopmentHistory.Text = qry.DevelopmentHistory;
            txtVaccinationHistory.Text = qry.VaccinationHistory;
            txtNutritionHistory.Text = qry.NutritionHistory;
            txtHeptomogy.Text = qry.Heptomology;
            txtsplenomegaly.Text = qry.Splenomegaly;
            // txtAreaOfInterest.Text = qry.Area_Of_Interest;
            // txtSpecialTests.Text = qry.Special_Test;
            txtHistoryOfPeresentIllness.Text = qry.HistoryOfPeresentIllness;
            txtHistoryOfFamily.Text = qry.HistoryOfFamily;
            txtHistoryOfPastIllness.Text = qry.HistoryOfPastIllness;
            txtCVS.Text = qry.CVS;
            txtGIT.Text = qry.GIT;
            txtRESP.Text = qry.RESP;
            txtSocioEconomicHistory.Text = qry.SocioEconomicHistory;
            txtCNS.Text = qry.CNS;
            txtGYNAE.Text = qry.GYNAE;
            txtUGS.Text = qry.URG;
            txtLocal.Text = qry.Local;
            txtMucculor.Text = qry.Mucculor;
            txtObstetricHistory.Text = qry.ObstetricHistory;
            txtAllergiesHistory.Text = qry.AllergiesHistory;
            txtProvisionalDiagnosis.Text = qry.ProvisionalDiagnosis;
            txtTreatmentHistory.Text = qry.TreatmentHistory;
            txtRemarksHistory.Text = qry.txtRemarksHistory;
            chkPallor.Checked = qry.chkPallor.Value;
            chkJVP.Checked = qry.chkJVP.Value;
            chkaganoris.Checked = qry.chkaganoris.Value;
            chkunconceed.Checked = qry.chkunconceed.Value;
            chkjaundice.Checked = qry.chkjaundice.Value;
            hydration.Checked = qry.hydration.Value;
            //chkNo_Medicine.Checked = qry.No_medicine.Value;
            //chkNo_Test.Checked = qry.No_LabTest.Value;
            edema.Checked = qry.edema.Value;
            chk1.Checked = qry.chk1.Value;
            chk2.Checked = qry.chk2.Value;
            chk3.Checked = qry.chk3.Value;
            ns.Checked = qry.chk4.Value;
            sl.Checked = qry.chk5.Value;
            //ddlDoctorName.SelectedValue = (from e in db.HR_Employees where e.Emp_ID == Convert.ToInt32( qry.Doctor_ID) select e.Emp_Name).FirstOrDefault();
            txtDesignation.Text = qry.Designation;
            txtFinalDiagnosis.Text = qry.Final_Diagnosis;
            ddlIssuance_Of.SelectedValue = qry.Administration;
            ddlFOllowUp.SelectedValue = qry.Follow_Up;
            ddlProto.SelectedValue = qry.Proto;

            if (qry.Folllow_Date != null)
                FollowNoDate.Text = qry.Folllow_Date.Value.ToString(AppConfig.DateFormat);

            txtAdvice.Text = qry.Advice;
            CheckBox1.Checked = qry.Discharge.Value;
            chkNo_Medicine.Checked = qry.No_medicine.Value;
            chkNo_Test.Checked = qry.No_LabTest.Value;
            txtInputBox1.Text = qry.txtInputBox1;
            txtBirthHistory.Text = qry.Birth_History;
            ddlPatient_Main_Category.SelectedValue = qry.Reffer_To;
            //fileupload.Text = qry.PDF_File;
            txtRefferNote.Text = qry.Reffer_No;
            txtDrugHistory.Text = qry.Drug_History;
            txtPersonalHistory.Text = qry.Personal_History;
            txtmidl.Text = qry.ENT_Throat_IDL;
            txtmNose.Text = qry.ENT_Throat_Nose;
            txtmRight.Text = qry.ENT_Ear_Right;
            txtmLeft.Text = qry.Ent_Ear_Left;
            mchkRightPos.Checked = qry.ENT_Rinnes_Right_PosNeg.Value;
            mchkLeftPos.Checked = qry.ENT_Rinnes_Lft_PosNeg.Value;
            mchkRightF.Checked = qry.ENT_Rinnes_Right_FalseNeg.Value;
            mchkLeftF.Checked = qry.ENT_Rinnes_Lft_FalseNeg.Value;
            mchkcentral.Checked = qry.ENT_Webber_Central.Value;
            mchkLateralized.Checked = qry.ENT_Webber_Lateralized.Value;
            mchkPTA.Checked = qry.ENT_Investigation_PTA.Value;
            mchkTympanometry.Checked = qry.ENT_Investigation_Tympanometry.Value;
            mchkRightNeg.Checked = qry.ENT_Rinnes_Right_Neg.Value;
            mchkLeftNeg.Checked = qry.ENT_Rinnes_Lft_Neg.Value;
            mchkRightFNeg.Checked = qry.ENT_Rinnes_Right_FNeg.Value;
            mchkLeftFNeg.Checked = qry.ENT_Rinnes_Lft_FNeg.Value;
            txtInformant.Text = qry.Psychiatry_Informant;
            txtSourceOfReferral.Text = qry.Psychiatry_Source_Referral;
            chkNeckHolding.Checked = Convert.ToBoolean(qry.Psychiatry_Neck_Holding);

            ComRightPos.Text = qry.Ent_Com_Right_pos;
            ComRightNeg.Text = qry.Ent_Com_Right_Neg;
            ComRightF.Text = qry.Ent_Com_Right_False;
            ComRightFNeg.Text = qry.Ent_Com_Right_False_Neg;
            ComCentral.Text = qry.Ent_Com_Central;
            ComPTA.Text = qry.Ent_Com_PTA;
            ComLeftPos.Text = qry.Ent_Com_Left_pos;
            ComLeftNeg.Text = qry.Ent_Com_Left_Neg;
            ComLeftF.Text = qry.Ent_Com_Left_False;
            ComLeftFNeg.Text = qry.Ent_Com_Left_Neg;
            ComLateralized.Text = qry.Ent_Com_Lateralized;
            ComTympanometry.Text = qry.Ent_Com_Tympanometry;

            chkWalking.Checked = qry.Psychiatry_Walking.Value;
            chkTalking.Checked = qry.Psychiatry_Talking.Value;
            chkOthers.Checked = qry.Psychiatry_Others.Value;
            txtMenarche.Text = qry.Psychiatry_Menarche;
            txtMenstrual.Text = qry.Psychiatry_Menstrual;
            txtAttachmentSeparationfromParents.Text = qry.Psychiatry_Attachment_Separation;
            txtHealth.Text = qry.Psychiatry_Health;
            chkNailBiting.Checked = qry.Psychiatry_Nail_Biting?.ToLower() == "true";
            chkTemperTantrums.Checked = qry.Psychiatry_Temper_Tantrums?.ToLower() == "true";
            chkBedWetting.Checked = qry.Psychiatry_Bed_Wetting?.ToLower() == "true";
           
            txtAcademics.Text = qry.Psychiatry_Academics;
            txtPeerRelationship.Text = qry.Psychiatry_Peer_Relationship;
            txtBehaviour.Text = qry.Psychiatry_Behaviour;
            txtOccupationalHistory.Text = qry.Psychiatry_Occupational_History;
            txtMaritalRelationshipSexualHistory.Text = qry.Psychiatry_Sexual_History;
            txtSubstanceUse.Text = qry.Psychiatry_Substance_Use;
            txtForensicUse.Text = qry.Psychiatry_Forensic_Use;
            txtRelationship.Text = qry.Psychiatry_Relationship;
            txtLeisureActivities.Text = qry.Psychiatry_Leisure_Activities;
            txtAttitudetoSelfandStandards.Text = qry.Psychiatry_Attitude_Standards;
            txtPrevallingMood.Text = qry.Psychiatry_Prevalling_Mood;
            txtReactionPattrentoStress.Text = qry.Psychiatry_Reaction_Stress;
            txtReligiousPracticesAttitute.Text = qry.Psychiatry_Religious_Practices;
            txtFather.Text = qry.Psychiatry_Father;
            txtMother.Text = qry.Psychiatry_Mother;
            txtSiblings.Text = qry.Psychiatry_Siblings;
            txtHomeAtmosphererelationshipsocialclass.Text = qry.Psychiatry_Home_Atmosphere;
            txtFamilialIllness.Text = qry.Psychiatry_Familial_Illness;
            txtActualandapparentage.Text = qry.Psychiatry_Actual_age;
            txtRace.Text = qry.Psychiatry_Race;
            txtTattoosbodypiercingandscars.Text = qry.Psychiatry_Tattoos_body_scars;
            txtBodyHabitus.Text = qry.Psychiatry_Body_Habitus;
            txtDress.Text = qry.Psychiatry_Dress;
            txtHygiene.Text = qry.Psychiatry_Hygiene;
            txtPsychomotorActivity.Text = qry.Psychiatry_Psychomotor_Activity;
            txtInvoluntarymovements.Text = qry.Psychiatry_Involuntary_movements;
            txtDystoniaEPS.Text = qry.Psychiatry_Dystonia_EPS;
            txtTardivedyskinesia.Text = qry.Psychiatry_Tardive_dyskinesia;
            txtTics.Text = qry.Psychiatry_Tics;
            txtTremors.Text = qry.Psychiatry_Tremors;
            txtAttentivenesstointerview.Text = qry.Psychiatry_Attentiveness_interview;
            txtEyeContact.Text = qry.Psychiatry_Eye_Contact;
            txtLevelofConsciousness.Text = qry.Psychiatry_Level_Consciousness;
            txtRate.Text = qry.Psychiatry_Rate;
            txtRhythm.Text = qry.Psychiatry_Rhythm;
            txtVolume.Text = qry.Psychiatry_Volume;
            txtTone.Text = qry.Psychiatry_Tone;

            txtModulationvar.Text = qry.Psychiatry_Modulation;

            txtDepressed.Text = qry.Psychiatry_Depressed;

            txtElated.Text = qry.Psychiatry_Elated;


            txtIrritable.Text = qry.Psychiatry_Irritable;

            txtLabile.Text = qry.Psychiatry_Labile;



            txtIncongruent.Text = qry.Psychiatry_Incongruent;

            txtBluntingFlatteningApathy.Text = qry.Psychiatry_Blunting_Flattening_Apathy;

            txtThinkingPremeditation.Text = qry.Psychiatry_Thinking;

            txtPlans.Text = qry.Psychiatry_Plans;
            txtNextPlan.Text = qry.NextPlan;


            txtActions.Text = qry.Psychiatry_Actions;

            txtPreservative.Text = qry.Psychiatry_Preservative;

            txtLoosAssociation.Text = qry.Psychiatry_LoosAssociation;

            txtTangentiaility.Text = qry.Psychiatry_Tangentiaility;

            txtCircumstantiality.Text = qry.Psychiatry_Circumstantiality;


            txtFlightofIdeas.Text = qry.Psychiatry_Flight_Ideas;

            txtThoughtInsertion.Text = qry.Psychiatry_Thought_Insertion;

            txtThoughtWithdrawal.Text = qry.Psychiatry_Thought_Withdrawal;

            txtThoughBroadcasting.Text = qry.Psychiatry_Thought_Broadcasting;

            txtThoughControl.Text = qry.Psychiatry_Thought_Control;

            txtDellusion.Text = qry.Psychiatry_Dellusion;

            txtovervaluedideas.Text = qry.Psychiatry_Overvalued_Ideas;

            txtDepresonalization.Text = qry.Psychiatry_Depresonalization;

            txtDerealization.Text = qry.Psychiatry_Derealization;

            txtthrougObsession.Text = qry.Psychiatry_Informant;

            txtthrougPhobies.Text = qry.Psychiatry_Phobies;

            txtthrougObsession.Text = qry.Psychiatry_Obsession;
            txtthrougHomocidialIdeas.Text = qry.Psychiatry_Homocidial_Ideas;

            txtillusion.Text = qry.Psychiatry_Illusion;

            txtHallucinationAuditoryVisualOlfactoryGustatoryTactile.Text = qry.Psychiatry_Hallucination;
            txtorientationtime.Text = qry.Psychiatry_Orientation_Time;

            txtplace.Text = qry.Psychiatry_Place;

            txtperson.Text = qry.Psychiatry_Person;

            txtAttentionConcentrationSerial7Test.Text = qry.Psychiatry_Attention_Concentration;

            txtOrDaysOfWeekReverseOrder.Text = qry.Psychiatry_Days_Week;

            txtImmediatememory.Text = qry.Psychiatry_Immediate_Memory;

            txtshorttermrecentevents.Text = qry.Psychiatry_Recent_Events;

            txtadressrecallafter2minutes.Text = qry.Psychiatry_Adress_Recall_Two;

            longtermremoteevents.Text = qry.Psychiatry_Remote_Events;

            txtadressrecallafter5minues.Text = qry.Psychiatry_Adress_Recall_Five;

            txtgeneralknowledgequestion.Text = qry.Psychiatry_General_knowledge;

            txtsimplearthemeticcalculation.Text = qry.Psychiatry_Arthemetic_Calculation;

            txtabstrationconcertethinking.Text = qry.Psychiatry_Abstraction;

            txtinsight.Text = qry.Psychiatry_Insight;

            txtDermaFace.Text = qry.DermaFace;
            txtDermaNeck.Text = qry.DermaNeck;
            txtDermaTrunk.Text = qry.DermaTrunk;
            txtDermaUpperLimb.Text = qry.DermaUpperLimb;
            txtDermaLowerLimb.Text = qry.DermaLowerLimb;
            txtDermaFlexures.Text = qry.DermaFlexures;
            txtDermaGenitalias.Text = qry.DermaGenitalias;
            txtDermaHair.Text = qry.DermaHair;
            txtDermaNail.Text = qry.DermaNail;
            txtDermaMucousMembrane.Text = qry.DermaMucousMembrane;
            txtDermaEyes.Text = qry.DermaEyes;
            txtDermaEars.Text = qry.DermaEars;
            txtDermaNose.Text = qry.DermaNose;
            txtDermaLips.Text = qry.DermaLips;
            txtHBM_Problem.Text = qry.Psychiatry_HBM_Problem;
            txtHBM_Caused.Text = qry.Psychiatry_HBM_Caused;
            txtHBM_Started.Text = qry.Psychiatry_HBM_Started;
            txtHBM_Course.Text = qry.Psychiatry_HBM_Course;
            txtHBM_Treatment.Text = qry.Psychiatry_HBM_Treatment;
            txtHBM_Effects.Text = qry.Psychiatry_HBM_Effects;
            txtPE_Pluse.Text = qry.Psychiatry_PE_Pluse;
            txtPE_BP.Text = qry.Psychiatry_PE_BP;
            txtPE_Temperature.Text = qry.Psychiatry_PE_Temperature;
            txtPE_Weight.Text = qry.Psychiatry_PE_Weight;
            txtPE_RespiratoryRate.Text = qry.Psychiatry_PE_RespiratoryRate;
            txtPE_Jaundice.Text = qry.Psychiatry_PE_Jaundice;
            txtPE_Anemia.Text = qry.Psychiatry_PE_Anemia;
            txtPE_Cyanosis.Text = qry.Psychiatry_PE_Cyanosis;
            txtPE_Clubbing.Text = qry.Psychiatry_PE_Clubbing;
            txtPE_JVP.Text = qry.Psychiatry_PE_JVP;
            txtPE_LymphNodes.Text = qry.Psychiatry_PE_LymphNodes;
            txtPE_Edema.Text = qry.Psychiatry_PE_Edema;
            txtPE_Respiratory.Text = qry.Psychiatry_PE_Respiratory;
            txtPE_Cardiovascular.Text = qry.Psychiatry_PE_Cardiovascular;
            txtPE_Gastro_Intestinal.Text = qry.Psychiatry_PE_Gastro_Intestinal;
            txtPE_Observation.Text = qry.Psychiatry_PE_Observation;
            txtPE_Cranial_Nerves.Text = qry.Psychiatry_PE_Cranial_Nerves;
            txtPE_Limb_Strength.Text = qry.Psychiatry_PE_Limb_Strength;
            txtPE_Spasticity.Text = qry.Psychiatry_PE_Spasticity;
            txtPE_Position.Text = qry.Psychiatry_PE_Position;
            txtPE_Vibration.Text = qry.Psychiatry_PE_Vibration;
            txtPE_Stereognosis.Text = qry.Psychiatry_PE_Stereognosis;
            txtPE_Pain.Text = qry.Psychiatry_PE_Pain;
            txtPE_Biceps.Text = qry.Psychiatry_PE_Biceps;
            txtPE_Triceps.Text = qry.Psychiatry_PE_Triceps;
            txtPE_Brachioradialis.Text = qry.Psychiatry_PE_Brachioradialis;
            txtPE_Quadriceps.Text = qry.Psychiatry_PE_Quadriceps;
            txtPE_Patellar.Text = qry.Psychiatry_PE_Patellar;
            txtPE_Achilles.Text = qry.Psychiatry_PE_Achilles;
            txtPE_Extensor.Text = qry.Psychiatry_PE_Extensor;
            txtPE_Frontal.Text = qry.Psychiatry_PE_Frontal;
            txtPE_Finger.Text = qry.Psychiatry_PE_Finger;
            txtPE_Heel.Text = qry.Psychiatry_PE_Heel;
            txtPE_Movements.Text = qry.Psychiatry_PE_Movements;
            txtPE_Gait.Text = qry.Psychiatry_PE_Gait;
            if (qry.Psychiatry_PE_Neck_Rigidity == null)
                chkPE_Neck_Rigidity.Checked = false;
            else
                chkPE_Neck_Rigidity.Checked = qry.Psychiatry_PE_Neck_Rigidity.Value;
            if (qry.Psychiatry_PE_Kerning_Sign == null)
                chkPE_Kerning_Sign.Checked = false;
            else
                chkPE_Kerning_Sign.Checked = qry.Psychiatry_PE_Kerning_Sign.Value;
            if (qry.Psychiatry_PE_Brudzinki_Sign == null)
                chkPE_Brudzinki_Sign.Checked = false;
            else
                chkPE_Brudzinki_Sign.Checked = qry.Psychiatry_PE_Brudzinki_Sign.Value;
            txtFor_Summary.Text = qry.Psychiatry_For_Summary;
            txtFor_Diagnosis.Text = qry.Psychiatry_For_Diagnosis;
            txtFor_AxisI.Text = qry.Psychiatry_For_AxisI;
            txtFor_AxisIII.Text = qry.Psychiatry_For_AxisIII;
            txtFor_AxisII.Text = qry.Psychiatry_For_AxisII;
            //     For_AxisII.Text=qry.psychiatr_For,
            txtFor_AxisIV.Text = qry.Psychiatry_For_AxisIV;
            txtFor_AxisV.Text = qry.Psychiatry_For_AxisV;
            txtFor_PredisposingFactors.Text = qry.Psychiatry_For_PredisposingFactors;
            txtFor_PrecipitatingFactors.Text = qry.Psychiatry_For_PrecipitatingFactors;
            txtFor_PrepetuatingFactors.Text = qry.Psychiatry_For_PrepetuatingFactors;
            txtFor_Investigation.Text = qry.Psychiatry_For_Investigation;
            txtFor_Medical.Text = qry.Psychiatry_For_Medical;
            txtFor_Psychological.Text = qry.Psychiatry_For_Psychological;
            txtFor_Major_Issues.Text = qry.Psychiatry_Major_Issues;
            txtFor_Strengths.Text = qry.Psychiatry_For_Strengths;
            txtFor_Goals.Text = qry.Psychiatry_For_Goals;
            txtFor_Strategies.Text = qry.Psychiatry_For_Strategies;
            txtPeads_weight.Text = qry.Peads_weight;
            txtPeads_Length.Text = qry.Peads_Length;
            txtPeads_HC.Text = qry.Peads_HC;
            txtPeads_General_Appearance.Text = qry.Peads_General_Appearance;
            if (qry.Peads_Cyanosis != null)
                chkPeads_Cyanosis.Checked = qry.Peads_Cyanosis.Value;
            if (qry.Peads_Jaundice != null)
                chkPeads_Jaundice.Checked = qry.Peads_Jaundice.Value;
            if (qry.Peads_Lethargy != null)
                chkPeads_Lethargy.Checked = qry.Peads_Lethargy.Value;
            if (qry.Peads_Lethargy != null)
                chkPeads_Rash.Checked = qry.Peads_Lethargy.Value;
            txtPeads_Others.Text = qry.Peads_Others;
            if (qry.Peads_Caput != null)
                chkPeads_Caput.Checked = qry.Peads_Caput.Value;
            if (qry.Peads_Cephalhematoma != null)
                chkPeads_Cephalhematoma.Checked = qry.Peads_Cephalhematoma.Value;
            if (qry.Peads_Anterioropen != null)

                rdbPeads_Anterioropen.Checked = qry.Peads_Anterioropen.Value;
            if (qry.Peads_AnteriorClose != null)
                rdbPeads_AnteriorClose.Checked = qry.Peads_AnteriorClose.Value;
            if (qry.Peads_Dextrocardia != null)
                chkPeads_Dextrocardia.Checked = qry.Peads_Dextrocardia.Value;
            if (qry.Peads_Bulging != null)
                chkPeads_Bulging.Checked = qry.Peads_Bulging.Value;
            if (qry.Peads_Murmur != null)
                chkPeads_Murmur.Checked = qry.Peads_Murmur.Value;
            if (qry.Peads_HeartSound != null)
                txtPeads_HeartSound.Text = qry.Peads_HeartSound;
            chkPeads_Nasal.Checked = qry.Peads_Nasal.Value;
            if (qry.Peads_Recessions != null)
                chkPeads_Recessions.Checked = qry.Peads_Recessions.Value;
            if (qry.Peads_Lethargy != null)
                txtPeads_AddedSounds.Text = qry.Peads_AddedSounds;

            rdbPeads_Flat.Checked = qry.Peads_Flat.Value;

            rdbPeads_Distended.Checked = qry.Peads_Distended.Value;

            rdbPeads_Scaphoid.Checked = qry.Peads_Scaphoid.Value;

            chkPeads_Liver.Checked = qry.Peads_Liver.Value;

            chkPeads_Spleen.Checked = qry.Peads_Spleen.Value;

            txtPeads_GITOthers.Text = qry.Peads_GITOthers;
            chkPeads_Sucking.Checked = qry.Peads_Sucking.Value;
            if (qry.Discharge == true)
            {
                hdfdhischarge.Value = Convert.ToString("true");
            }
            else
            {
                hdfdhischarge.Value = Convert.ToString("false");
            }

            chkPeads_Rooting.Checked = qry.Peads_Rooting.Value;

            chkPeads_Moro.Checked = qry.Peads_Moro.Value;
            txtPeads_CNSOthers.Text = qry.Peads_CNSOthers;
            chkPeads_FullTerm.Checked = qry.Peads_FullTerm.Value;
            chkPeads_PreTerm.Checked = qry.Peads_PreTerm.Value;
            if (qry.Peads_DateOfDelivery != null)
                txtPeads_DateOfDelivery.Text = qry.Peads_DateOfDelivery.Value.ToString(AppConfig.DateFormat);
            txtPeads_TimeOfDelivery.Text = qry.Peads_TimeOfDelivery;
            rdbPeads_Booked.Checked = qry.Peads_Booked.Value;
            rdbPeads_UnBooked.Checked = qry.Peads_UnBooked.Value;
            chkPeads_DAIHandling.Checked = qry.Peads_DAIHandling.Value;
            chkPeads_ANTURash.Checked = qry.Peads_ANTURash.Value;
            chkPeads_PIH.Checked = qry.Peads_PIH.Value;
            chkPeads_GDM.Checked = qry.Peads_GDM.Value;
            chkPeads_Vacinated.Checked = qry.Peads_Vacinated.Value;
            txtPeads_ANTOthers.Text = qry.Peads_ANTOthers;
            rdbPeads_SVD.Checked = qry.Peads_SVD.Value;
            rdbPeads_LSCS.Checked = qry.Peads_LSCS.Value;
            rdbPeads_Emergency.Checked = qry.Peads_Emergency.Value;
            rdbPeads_Elective.Checked = qry.Peads_Elective.Value;
            txtPeads_PlaceOfDelivery.Text = qry.Peads_PlaceOfDelivery;
            txtPeads_IndicationForLSCS.Text = qry.Peads_IndicationForLSCS;
            ddlPeads_apgerScore1min.SelectedValue = qry.Peads_apgerScore1min;
            ddlPeads_apgerScore5min.SelectedValue = qry.Peads_apgerScore5min;
            chkPeads_Resuscitation.Checked = qry.Peads_Resuscitation.Value;
            txtPeads_NatalOthers.Text = qry.Peads_NatalOthers;
            chkPeads_Moaning.Checked = qry.Peads_Moaning.Value;
            chkPeads_RespDistress.Checked = qry.Peads_RespDistress.Value;
            chkPeads_PostNATALCyanosis.Checked = qry.Peads_PostNATALCyanosis.Value;
            chkPeads_Fits.Checked = qry.Peads_Fits.Value;
            chkPeads_ReluctanceToFeed.Checked = qry.Peads_ReluctanceToFeed.Value;
            txtPeads_PostNatalOthers.Text = qry.Peads_PostNatalOthers;
        }
        public class Detail
        {
            public string Name;
            public string Gender;
            public string Age;
            public string Mobile;
            public string Address;
            public string Entry_Date;
            public string department;
            public string Follow;
            public string Patient_type;
            public string dotorname;

        }
        [System.Web.Services.WebMethod]
        public static Detail GetDetail(string PatientID)
        {
            int Patien_No = DBClass.GetMRNOBy_PatientID(Convert.ToInt32(PatientID));
            Detail pt = new Detail();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            Patient pat = new Patient();
            pat = (from tbl in db.Patients
                   where tbl.Patient_No == Patien_No
                   orderby tbl.Entry_Date descending

                   select tbl).FirstOrDefault();
            if (pat != null)
            {
                pt.Name = pat.Full_Name;
                pt.Gender = pat.Gender;
                pt.Age = pat.Age_years.ToString();
                if (pat.Entry_Date.HasValue)
                    pt.Entry_Date = pat.Entry_Date.ToString();
                pt.Address = pat.Permanent_Address;
                pt.Mobile = pat.Mobile1;
                pt.Entry_Date = pat.Created_Time.ToString();
                pt.department = db.GetDataValueName("Patient Main Category", pat.Patient_Main_Category);
                HR_Employee doctor = null;

                if (!string.IsNullOrEmpty(pat.Doctor_ID))
                {
                    doctor = db.HR_Employees.FirstOrDefault(e => e.Emp_ID == Convert.ToInt32(pat.Doctor_ID));
                }
                pt.dotorname = doctor != null ? doctor.Emp_Name : "";
                pt.Patient_type = db.GetDataValueName("Patient Type", pat.Patient_Type);
                pt.Gender = db.GetDataValueName("Gender", pat.Gender);
                var Patientno = pat.Patient_No.ToString();
                var count = (db.Patients.Where(v => v.Patient_No == Convert.ToInt32(Patientno)).ToList());
                pt.Follow = count.Count.ToString();
                return pt;
            }
            else
                return pt;
        }
        [WebMethod]
        public static string FillDepts()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var depts = (from d in db.DataValues
                         join v in db.ValueSets
                         on d.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Name == "Patient Main Category"
                         select new { d.DataValue_Name, d.DataValue_Description }
                       ).ToList();
            return (new JavaScriptSerializer()).Serialize(depts);
        }



        [WebMethod]
        public static string GetTestMainDepartmentDetails(int TestID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var TestMainDepartmentName = (from t in db.Lab_Tests
                                          where t.Test_ID == TestID
                                          select new
                                          {
                                              TestMainDepartmentName123 = db.GetDataValueName("Main Test Departments", t.Main_Department.ToString()).ToString(),
                                              estMainDepartmen = t.Main_Department
                                          }).ToList();
            return (new JavaScriptSerializer().Serialize(TestMainDepartmentName));
        }
        [WebMethod]
        public static string PendingPatients(string filterDepartment, string doc_name)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var data = (from p in db.Patients
                        join u in db.aspnet_Users
                        on p.Created_By equals u.UserId
                        where Convert.ToDateTime(p.Created_Time).Month == DateTime.Now.Month &&
                              Convert.ToDateTime(p.Created_Time).Year == DateTime.Now.Year &&
                              Convert.ToDateTime(p.Created_Time).Day == DateTime.Now.Day 
                              //p.Patient_Type == "01"

                        select new
                        {
                            p.Patient_ID,
                            p.Reg_PatId,
                            Patient_No = p.Opd_No,
                            p.Full_Name,
                            p.NIC,
                            DoctorName = (from d in db.HR_Employees
                                          where d.Emp_ID == Convert.ToInt32(p.Doctor_ID)
                                          select d.Emp_Name).FirstOrDefault(),
                            Department = db.GetDataValueName("Patient Main Category", p.Patient_Main_Category),
                            FilterClinic = db.GetDataValueName("Filter Clinic", p.filter_clinic),
                            Gender = db.GetDataValueName("Gender", p.Gender),
                            p.Created_Time,
                            u.UserName,
                            p.Age_years,
                            p.Patient_Type,
                            p.Doctor_ID,
                            Checked = ((from op in db.Out_Patients
                                        where op.Patient_ID == p.Patient_ID
                                        && op.Doctor_ID != null && op.Doctor_ID != ""
                                        select op.Doctor_ID).FirstOrDefault()),        
                            Token_No = (from t in db.Patients
                                        where t.Patient_ID < p.Patient_ID 
                                           && t.Created_Time.Value.Date == p.Created_Time.Value.Date
                                           && t.Created_Time.Value.Month == p.Created_Time.Value.Month
                                           && t.Created_Time.Value.Year == p.Created_Time.Value.Year
                                           && t.Patient_Main_Category == p.Patient_Main_Category
                                        select t).Count() + 1
                        });

            if (!string.IsNullOrEmpty(filterDepartment) && filterDepartment != "0" && doc_name=="0")
            {
                data = data.Where(p => p.Department == db.GetDataValueName("Patient Main Category", filterDepartment));
            }

            else if (!string.IsNullOrEmpty(filterDepartment) && filterDepartment != "0" && !string.IsNullOrEmpty(doc_name))
            {
                data = data.Where(p => p.Department == db.GetDataValueName("Patient Main Category", filterDepartment) &&  p.Doctor_ID == doc_name);
            }

            else if (!string.IsNullOrEmpty(doc_name) && (string.IsNullOrEmpty(filterDepartment) || filterDepartment == "0"))
            {
                data = data.Where(p => p.Doctor_ID == doc_name);
            }

            var result = data.ToList();
            return (new JavaScriptSerializer()).Serialize(result);
        }




        [WebMethod]
        public static string RemoveExtraDepts(Guid UserID)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var selectedDepts = (from u in db.aspnet_Users
                                 join ur in db.aspnet_UsersInRoles
                                 on u.UserId equals ur.UserId
                                 join r in db.aspnet_Roles
                                 on ur.RoleId equals r.RoleId
                                 where u.UserId == UserID && r.Department_ID != null
                                 select new
                                 {
                                     r.Department_ID,
                                     Department_Name = (db.GetDataValueName("Patient Main Category", r.Department_ID))
                                 }
                     ).ToList();

            foreach (var datarow in selectedDepts)
            {
                if (datarow.Department_ID == "All_Departments")
                {
                    var allDepts = (from d in db.DataValues
                                    join v in db.ValueSets
                                    on d.ValueSet_ID equals v.ValueSet_ID
                                    where v.ValueSet_Name == "Patient Main Category"
                                    select new { Department_ID = d.DataValue_Name, Department_Name = d.DataValue_Description }
                       ).ToList();
                    return (new JavaScriptSerializer().Serialize(allDepts));
                }
            }
            return (new JavaScriptSerializer().Serialize(selectedDepts));
        }
        [WebMethod]
        public static string FillRoutesDropDown()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Routes = from d in db.DataValues
                         join v in db.ValueSets
                         on d.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Name == "Routes"
                         select new
                         {
                             d.DataValue_Name,
                             d.DataValue_Description
                         };
            return (new JavaScriptSerializer().Serialize(Routes));
        }
        [WebMethod]
        public static string FillMedicineDropDown()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Routes = (from d in db.DataValues
                          join v in db.ValueSets
                          on d.ValueSet_ID equals v.ValueSet_ID
                          where v.ValueSet_Name == "Medicine"
                          select new
                          {
                              d.DataValue_Name,
                              d.DataValue_Description

                          }).ToList();

            return (new JavaScriptSerializer().Serialize(Routes));
        }
        [WebMethod]
        public static string getpharmacyitems(string searchString)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var pharmacyItems = (from d in db.INV_Items
                                     where d.IsPharmacyItem == true && d.Description.Contains(searchString)
                                     orderby d.Item_ID descending
                                     select new
                                     {
                                         d.Item_Code,
                                         Description = d.Description
                                     }).Take(20).ToList();

                return (new JavaScriptSerializer().Serialize(pharmacyItems));
            }
        }

        [WebMethod]
        public static string FillPharmacyItemDropDown()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Routes = (from d in db.INV_Items

                          where d.Pharmacy_Item == true
                          orderby d.Item_ID descending
                          select new
                          {
                              d.Item_Code,
                              Description = d.Description,
                          }).ToList().Take(20);

            return (new JavaScriptSerializer().Serialize(Routes));
        }
        [WebMethod]
        public static string GetProcedure(string dpt)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var INV_Items = from itm in db.Lab_Tests

                            where itm.Main_Department == dpt
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
        public static string FillFrequencyDropDown()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Routes = from d in db.DataValues
                         join v in db.ValueSets
                         on d.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Name == "Frequency"
                         select new
                         {
                             d.DataValue_Name,
                             d.DataValue_Description,
                             d.Segment1
                         };
            return (new JavaScriptSerializer().Serialize(Routes));
        }
        [WebMethod]
        public static string FillDosageDropDown()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Routes = from d in db.DataValues
                         join v in db.ValueSets
                         on d.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Name == "Dosage Form"
                         select new
                         {
                             d.DataValue_Name,
                             d.DataValue_Description,

                         };
            return (new JavaScriptSerializer().Serialize(Routes));
        }
        [WebMethod]
        public static string FillDosageQty()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Routes = from d in db.DataValues
                         join v in db.ValueSets
                         on d.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Name == "Dosage Quantity"
                         select new
                         {
                             d.DataValue_Name,
                             d.DataValue_Description,

                         };
            return (new JavaScriptSerializer().Serialize(Routes));
        }
        [WebMethod]
        public static string FillOtherInstruction()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Routes = from d in db.DataValues
                         join v in db.ValueSets
                         on d.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Name == "Other Instruction"
                         select new
                         {
                             d.DataValue_Name,
                             DataValue_Description = d.Segment1,

                         };
            return (new JavaScriptSerializer().Serialize(Routes));
        }
        [WebMethod]
        public static string LoadMedicines(int PatientID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                List<In_Patient_Medicine> inPatmedicineList = db.In_Patient_Medicines.Where(p => p.Patient_ID == PatientID && p.Transaction_Type == "OutPatient").ToList();
                return (new JavaScriptSerializer()).Serialize(inPatmedicineList);
            }
            return "";
        }
        public class MadicationClass
        {
            public string chkDiccharge;
            public string AttendingParamedical_Staff;
            public string Frequency;
            public string In_Patient_Medicine_ID;
            public DateTime Medicine_Date;
            public string Injections;
            public string Medicine_Name;
            public string Oral;
            public int Patient_ID;
            public string Recomended_Dosage;
            public string Dosage_From;
            public string Created_Time;
            public string Doctor_ID;
            public string DoctorName;
            public string Status;
            public string Dosage_Qty;
            public string Other_Instruction;


        }
        [WebMethod]
        public static string LoadMedicinesForHistory(int PatientID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {

                int Patien_No = DBClass.GetMRNOBy_RgPatientID(Convert.ToInt32(PatientID));

                var inPatmedicineList = (from pm in db.In_Patient_Medicines
                                         join op in db.In_Patients
                                         on pm.Patient_ID equals op.In_Patient_ID
                                         join p in db.Patients
                                         on op.Patient_ID equals p.Patient_ID
                                         where p.Patient_No == Patien_No && pm.Transaction_Type == "InPatient"
                                         select new { pm.chkDiccharge, pm.AttendingParamedical_Staff, pm.Frequency, pm.Other_Instruction, pm.Dosage_Qty, pm.Dosage_From, pm.In_Patient_Medicine_ID, pm.Injections, pm.Medicine_Date, pm.Medicine_Name, pm.Oral, pm.Patient_ID, pm.Recomended_Dosage, op.Created_Time, pm.Doctor_ID, DoctorName = (from d in db.HR_Employees where d.Emp_ID == Convert.ToInt32(pm.Doctor_ID) select d.Emp_Name).FirstOrDefault() }).ToList();


                var OutPatmedicineList = (from pm in db.In_Patient_Medicines
                                          join op in db.Out_Patients
                                          on pm.Patient_ID equals op.Out_Patient_ID
                                          join p in db.Patients
                                          on op.Patient_ID equals p.Patient_ID
                                          join rp in db.Reg_patients
                                          on p.Reg_PatId equals rp.pat_id
                                          where rp.Patient_No == Patien_No && pm.Transaction_Type == "OutPatient"
                                          select new { op.No_LabTest, op.No_medicine, pm.chkDiccharge, pm.AttendingParamedical_Staff, pm.Frequency, pm.Other_Instruction, pm.Dosage_Qty, pm.Dosage_From, pm.In_Patient_Medicine_ID, pm.Injections, pm.Medicine_Date, pm.Medicine_Name, pm.Oral, pm.Patient_ID, pm.Recomended_Dosage, op.Created_Time, pm.Doctor_ID, DoctorName = (from d in db.HR_Employees where d.Emp_ID == Convert.ToInt32(pm.Doctor_ID) select d.Emp_Name).FirstOrDefault() }).ToList();


                List<MadicationClass> list = new List<MadicationClass>();
                foreach (var item in inPatmedicineList)
                {
                    MadicationClass obj = new MadicationClass();

                    obj.AttendingParamedical_Staff = item.AttendingParamedical_Staff;
                    obj.Frequency = item.Frequency;
                    obj.Medicine_Date = Convert.ToDateTime(item.Medicine_Date);
                    obj.Injections = item.Injections;

                    obj.Medicine_Name = item.Medicine_Name;
                    obj.Oral = item.Oral;
                    obj.Other_Instruction = item.Other_Instruction;
                    obj.Dosage_Qty = item.Dosage_Qty;
                    obj.Dosage_From = item.Dosage_From;
                    obj.Recomended_Dosage = item.Recomended_Dosage;
                    //  obj.DoctorName = item.DoctorName.ToString();
                    obj.Status = "InPatient";

                    list.Add(obj);
                }
                foreach (var item in OutPatmedicineList)
                {
                    MadicationClass obj = new MadicationClass();

                    obj.AttendingParamedical_Staff = item.AttendingParamedical_Staff;
                    obj.Frequency = item.Frequency;
                    obj.Medicine_Date = Convert.ToDateTime(item.Medicine_Date);
                    obj.Injections = item.Injections;

                    obj.Medicine_Name = item.Medicine_Name;
                    obj.Oral = item.Oral;
                    obj.Other_Instruction = item.Other_Instruction;
                    obj.Dosage_Qty = item.Dosage_Qty;
                    obj.Dosage_From = item.Dosage_From;

                    obj.Recomended_Dosage = item.Recomended_Dosage;
                    //obj.DoctorName = item.Doctor_ID;
                    obj.Status = "OutPatient";
                    list.Add(obj);
                }
                return (new JavaScriptSerializer()).Serialize(list);
            }
            return "";
        }
        public class Medicine
        {
            public int Pat { get; set; }
            public int PatientID { get; set; }
            public List<MedicineDetails> MedicineList { get; set; }
        }
        public class MedicineDetails
        {
            public DateTime Medicine_Date { get; set; }
            public string Medicine_Name { get; set; }
            public string Recomended_Dosage { get; set; }
            public string Dosage_From { get; set; }
            public string Oral { get; set; }
            public string Injection { get; set; }
            public string AttendingParamedical_Staff { set; get; }
            public string Frequency { set; get; }
            public string ItemCode { get; set; }
            public string Dosage_Qty;
            public string Other_Instruction;
        }

        [WebMethod]
        public static string SaveSymtoms(string SymtomsList)
        {
            try
            {
                JavaScriptSerializer js = new JavaScriptSerializer();
                var data = js.Deserialize<Symtom>(SymtomsList);
                using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    if (data.OutPatientID == 0)
                        data.OutPatientID = Convert.ToInt32(DBClass.getField("select (isnull(max(Out_Patient_id),0)+1) from Out_Patient").ToString());
                    int couterNewRecords = 0;
                    /*********************Deleting Previous Entry On Every Insert Or Update*************************/
                    List<Sysmtopm> SysmtopmList = db.Sysmtopms.Where(p => p.Out_Patient_ID == data.OutPatientID).ToList();
                    if (SysmtopmList != null)
                    {
                        db.Sysmtopms.DeleteAllOnSubmit(SysmtopmList);
                        couterNewRecords++;
                    }
                    couterNewRecords = 0;
                    /*********************Inserting New Entry On Every Insert Or Update*************************/

                    foreach (SymtomsList oSymtomsList in data.SymtomsList)
                    {
                        Sysmtopm oSysmtopm = new Sysmtopm()
                        {
                            Out_Patient_ID = data.OutPatientID,
                            Symtom_ID = oSymtomsList.SymtomID.Replace(" ", ""),
                            Duration = oSymtomsList.Duration,
                            Days_Years_Months = oSymtomsList.DayYearMonth,
                            Remarks = oSymtomsList.Remarks
                        };
                        db.Sysmtopms.InsertOnSubmit(oSysmtopm);
                        couterNewRecords++;
                    }
                    db.SubmitChanges();
                }
            }
            catch (Exception ex)
            {

            }
            return "";
        }
       
        [WebMethod]
        public static string GetTests()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var test = (from t in db.Lab_Tests
                        select new { t.Test_ID, t.Test_Name }).ToList();

            return (new JavaScriptSerializer()).Serialize(test);
        }
        public class TestValue
        {
            public string Date { get; set; }
            public string TestID { get; set; }
            public string RotationID { get; set; }
            public string L_R_Rotation_ID { get; set; }
            public string Catagory_ID { get; set; }
            public string Dept_ID { get; set; }
            public string Special_Tests { get; set; }
            public string Area_Of_Interest { get; set; }
            public string rotation { get; set; }
            public bool showTestDescription { get; set; }
        }
        public class LabTest
        {
            public string PatientID { get; set; }
            public string PatID { get; set; }
            public List<TestValue> TestList { get; set; }
        }
        [WebMethod]
        public static string LoadPeadsHistory(int PatientID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            int Patien_No = DBClass.GetMRNOBy_RgPatientID(Convert.ToInt32(PatientID));

            var PatCase = (from op in db.Out_Patients
                           join p in db.Patients
                          on op.Patient_ID equals p.Patient_ID
                           join rp in db.Reg_patients
on p.Reg_PatId equals rp.pat_id
                           where rp.Patient_No == Patien_No
                           select new
                           {
                               op.Peads_weight,
                               op.Peads_Length,
                               op.Peads_HC,
                               op.Peads_General_Appearance,
                               op.Peads_Cyanosis,
                               op.Peads_Jaundice,
                               op.Peads_Lethargy,
                               op.Peads_Rash,
                               op.Peads_Others,
                               op.Peads_Caput,
                               op.Peads_Cephalhematoma,
                               op.Peads_Anterioropen,
                               op.Peads_AnteriorClose,
                               op.Peads_Dextrocardia,
                               op.Peads_Bulging,
                               op.Peads_Murmur,
                               op.Peads_HeartSound,
                               op.Peads_Nasal,
                               op.Peads_Recessions,
                               op.Peads_AddedSounds,
                               op.Peads_Flat,
                               op.Peads_Distended,
                               op.Peads_Scaphoid,
                               op.Peads_Liver,
                               op.Peads_Spleen,
                               op.Peads_GITOthers,
                               op.Peads_Sucking,
                               op.Peads_Rooting,
                               op.Peads_Moro,
                               op.Peads_CNSOthers,
                               op.Peads_FullTerm,
                               op.Peads_PreTerm,
                               op.Peads_DateOfDelivery,
                               op.Peads_TimeOfDelivery,
                               op.Peads_Booked,
                               op.Peads_UnBooked,
                               op.Peads_DAIHandling,
                               op.Peads_ANTURash,
                               op.Peads_PIH,
                               op.Peads_GDM,
                               op.Peads_Vacinated,
                               op.Peads_ANTOthers,
                               op.Peads_SVD,
                               op.Peads_LSCS,
                               op.Peads_Emergency,
                               op.Peads_Elective,
                               op.Peads_PlaceOfDelivery,
                               op.Peads_IndicationForLSCS,
                               op.Peads_apgerScore1min,
                               op.Peads_apgerScore5min,
                               op.Peads_Resuscitation,
                               op.Peads_NatalOthers,
                               op.Peads_Moaning,
                               op.Peads_RespDistress,
                               op.Peads_PostNATALCyanosis,
                               op.Peads_Fits,
                               op.Peads_ReluctanceToFeed,
                               op.Peads_PostNatalOthers,
                               op.Created_Time
                           }).ToList();
            return ((new JavaScriptSerializer()).Serialize(PatCase));
        }
        [WebMethod]
        public static string LoadPeadsHistoryInpat(int PatientID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            int Patien_No = DBClass.GetMRNOBy_PatientID(Convert.ToInt32(PatientID));

            var PatCase = (from ip in db.In_Patients
                           join p in db.Patients
                          on ip.Patient_ID equals p.Patient_ID
                           where p.Patient_No == Patien_No
                           select new
                           {
                               ip.Peads_weight,
                               ip.Peads_Length,
                               ip.Peads_HC,
                               ip.Peads_General_Appearance,
                               ip.Peads_Cyanosis,
                               ip.Peads_Jaundice,
                               ip.Peads_Lethargy,
                               ip.Peads_Rash,
                               ip.Peads_Others,
                               ip.Peads_Caput,
                               ip.Peads_Cephalhematoma,
                               ip.Peads_Anterioropen,
                               ip.Peads_AnteriorClose,
                               ip.Peads_Dextrocardia,
                               ip.Peads_Bulging,
                               ip.Peads_Murmur,
                               ip.Peads_HeartSound,
                               ip.Peads_Nasal,
                               ip.Peads_Recessions,
                               ip.Peads_AddedSounds,
                               ip.Peads_Flat,
                               ip.Peads_Distended,
                               ip.Peads_Scaphoid,
                               ip.Peads_Liver,
                               ip.Peads_Spleen,
                               ip.Peads_GITOthers,
                               ip.Peads_Sucking,
                               ip.Peads_Rooting,
                               ip.Peads_Moro,
                               ip.Peads_CNSOthers,
                               ip.Peads_FullTerm,
                               ip.Peads_PreTerm,
                               ip.Peads_DateOfDelivery,
                               ip.Peads_TimeOfDelivery,
                               ip.Peads_Booked,
                               ip.Peads_UnBooked,
                               ip.Peads_DAIHandling,
                               ip.Peads_ANTURash,
                               ip.Peads_PIH,
                               ip.Peads_GDM,
                               ip.Peads_Vacinated,
                               ip.Peads_ANTOthers,
                               ip.Peads_SVD,
                               ip.Peads_LSCS,
                               ip.Peads_Emergency,
                               ip.Peads_Elective,
                               ip.Peads_PlaceOfDelivery,
                               ip.Peads_IndicationForLSCS,
                               ip.Peads_apgerScore1min,
                               ip.Peads_apgerScore5min,
                               ip.Peads_Resuscitation,
                               ip.Peads_NatalOthers,
                               ip.Peads_Moaning,
                               ip.Peads_RespDistress,
                               ip.Peads_PostNATALCyanosis,
                               ip.Peads_Fits,
                               ip.Peads_ReluctanceToFeed,
                               ip.Peads_PostNatalOthers,
                               ip.Created_Time
                           }).ToList();
            return ((new JavaScriptSerializer()).Serialize(PatCase));
        }
        [WebMethod]
        public static string GetTestList(int id)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var testDetailst = (from lbtM in db.Laboratory_Tests
                                join lbtD in db.Lab_Test_Details
                                on lbtM.Lab_Test_ID equals lbtD.Lab_Test_ID
                                join outpat in db.Out_Patients
                                on lbtM.Patient_ID equals outpat.Out_Patient_ID
                                where outpat.Out_Patient_ID == id && lbtM.Transaction_Type == "OutPatient"
                                select new
                                {
                                    lbtD.Lab_Test_Detail_ID,
                                    lbtD.Date,
                                    lbtD.Remark,
                                    lbtD.Catagory_ID,
                                    lbtM.Lab_Test_ID,
                                    lbtD.Test_ID,
                                    lbtD.Dept_ID,
                                    lbtD.L_R_Rotation_ID,
                                    Test_Name = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Test_Name).FirstOrDefault(),
                                    Value_Type = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Value_Type).FirstOrDefault(),
                                    Value_TypeGroup = (from t in db.Lab_Tests where t.Group_Category == lbtD.Catagory_ID select t.Value_Type).FirstOrDefault(),
                                    Group_Department = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Group_Department).FirstOrDefault(),
                                    Group_Category = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Group_Category).FirstOrDefault(),
                                    DepartmentName = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select db.GetDataValueName("Main Test Departments", t.Main_Department)).FirstOrDefault(),
                                    Department_ID = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Main_Department).FirstOrDefault(),
                                    GroupName = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select db.GetDataValueName("Test Groups", t.Group_Category)).FirstOrDefault(),
                                    Group_Name = db.GetDataValueName("Test Groups", lbtD.Catagory_ID),
                                    lbtD.Rotation_ID,
                                    Rotation = ((from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select db.GetDataValueName("Main Test Departments", t.Main_Department)).FirstOrDefault()) == "X-Ray" ? db.GetDataValueName("Test XRay Rotations", lbtD.Rotation_ID) : db.GetDataValueName("Test CT Scan Rotations", lbtD.Rotation_ID),
                                    DataValue_Description = (from dv in db.DataValues
                                                             join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                                                             where vs.ValueSet_Name == ("Test XRay Rotations").ToString() && dv.DataValue_Name == lbtD.Rotation_ID
                                                             select dv.DataValue_Description).FirstOrDefault(),
                                    lbtD.Special_Tests,
                                    lbtD.Area_Of_Interest,
                                    lbtD.Recieved_ID,
                                    lbtD.Is_Result,

                                }
                ).ToList();
            return (new JavaScriptSerializer()).Serialize(testDetailst);
        }
        public class LabTestClass
        {
            public string chkPackages;
            public bool IsBilled;
            public string Lab_Test_Detail_ID;
            public string L_R_Rotation_ID;
            public DateTime Date;
            public string Remark;
            public string Catagory_ID;
            public string Lab_Test_ID;
            public int Test_ID;
            public string Dept_ID;

            public string Recieved_ID;
            public string Parent_Transaction_Type;
            public string Parent_Transaction_Type_ID;
            public string Transaction_Type;
            public string Doctor_ID;
            public int Patient_No;
            public string Patient_ID;
            public string Name;
            public string Out_Patient_ID;
            public string Special_Tests;
            public string Area_Of_Interest;
            public int In_Patient_ID;
            public string Value_Type;
            public string Value_TypeGroup;
            public string Test_Name;
            public string Group_Department;
            public string Group_Category;
            public string DepartmentName;
            public string Department_ID;
            public string GroupName;
            public string Group_Name;
            public string Rotation_ID;
            public string DoctorName;
            public string DataValue_Description;
            public bool Is_Result;
            public string Rotation;
            public string Doctor;
            public string Status;

        }

        [WebMethod]
        public static string GetTestListForHistory(int id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            int Patien_No = DBClass.GetMRNOBy_RgPatientID(Convert.ToInt32(id));

            var InPatienttestilst = (from lbtM in db.Laboratory_Tests
                                     join lbtD in db.Lab_Test_Details
                                     on lbtM.Lab_Test_ID equals lbtD.Lab_Test_ID
                                     join outpat in db.In_Patients
                                     on lbtM.Patient_ID equals outpat.In_Patient_ID
                                     join p in db.Patients
                                     on outpat.Patient_ID equals p.Patient_ID
                                     join rp in db.Reg_patients
                                     on p.Reg_PatId equals rp.pat_id
                                     where rp.Patient_No == Patien_No && lbtM.Transaction_Type == "InPatient"


                                     select new
                                     {
                                         outpat.In_Patient_ID,
                                         lbtD.Lab_Test_Detail_ID,
                                         lbtD.Date,
                                         lbtD.Remark,
                                         lbtD.Catagory_ID,
                                         lbtM.Lab_Test_ID,
                                         lbtD.Test_ID,
                                         lbtD.Dept_ID,
                                         lbtD.L_R_Rotation_ID,
                                         Value_Type = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Value_Type).FirstOrDefault(),
                                         Value_TypeGroup = (from t in db.Lab_Tests where t.Group_Category == lbtD.Catagory_ID select t.Value_Type).FirstOrDefault(),
                                         Test_Name = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Test_Name).FirstOrDefault(),
                                         Group_Department = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Group_Department).FirstOrDefault(),
                                         Group_Category = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Group_Category).FirstOrDefault(),
                                         DepartmentName = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select db.GetDataValueName("Main Test                 Departments", t.Main_Department)).FirstOrDefault(),
                                         Department_ID = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Main_Department).FirstOrDefault(),
                                         GroupName = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select db.GetDataValueName("Test Groups", t.Group_Category)).FirstOrDefault(),
                                         Group_Name = db.GetDataValueName("Test Groups", lbtD.Catagory_ID),
                                         lbtD.Rotation_ID,
                                         Rotation = ((from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select db.GetDataValueName("Main Test Departments", t.Main_Department)).FirstOrDefault()) == "X-Ray" ? db.GetDataValueName("Test XRay Rotations", lbtD.Rotation_ID) : db.GetDataValueName("Test CT Scan Rotations", lbtD.Rotation_ID),
                                         DataValue_Description = (from dv in db.DataValues
                                                                  join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                                                                  where vs.ValueSet_Name == ("Test XRay Rotations").ToString() && dv.DataValue_Name == lbtD.Rotation_ID
                                                                  select dv.DataValue_Description).FirstOrDefault(),

                                         lbtD.Special_Tests,
                                         lbtD.Area_Of_Interest,
                                         lbtD.Doctor,
                                         lbtD.Recieved_ID,
                                         Is_Result = (from t in db.Lab_Test_Details where t.BillDetailID == lbtD.BillDetailID orderby t.Lab_Test_Detail_ID descending select t.isApproved).FirstOrDefault(),
                                         Doctor_ID = outpat.Doctor
                                     }
                ).ToList();



            var OutPatienttestilst = (
                                        from lbtM in db.Laboratory_Tests
                                        join lbtD in db.Lab_Test_Details
                                        on lbtM.Lab_Test_ID equals lbtD.Lab_Test_ID
                                        join outpat in db.Out_Patients
                                        on lbtM.Patient_ID equals outpat.Out_Patient_ID
                                        join p in db.Patients
                                        on outpat.Patient_ID equals p.Patient_ID
                                        join rp in db.Reg_patients
                                        on p.Reg_PatId equals rp.pat_id
                                        where rp.Patient_No == Patien_No && lbtM.Transaction_Type == "OutPatient"


                                        select new
                                        {

                                            outpat.Out_Patient_ID,
                                            lbtD.Lab_Test_Detail_ID,
                                            lbtD.Date,
                                            lbtD.Remark,
                                            lbtD.Catagory_ID,
                                            lbtM.Lab_Test_ID,
                                            lbtD.Test_ID,
                                            lbtD.Dept_ID,
                                            lbtD.L_R_Rotation_ID,
                                            Value_Type = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Value_Type).FirstOrDefault(),
                                            Value_TypeGroup = (from t in db.Lab_Tests where t.Group_Category == lbtD.Catagory_ID select t.Value_Type).FirstOrDefault(),
                                            Test_Name = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Test_Name).FirstOrDefault(),
                                            Group_Department = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Group_Department).FirstOrDefault(),
                                            Group_Category = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Group_Category).FirstOrDefault(),
                                            DepartmentName = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select db.GetDataValueName("Main Test                 Departments", t.Main_Department)).FirstOrDefault(),
                                            Department_ID = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Main_Department).FirstOrDefault(),
                                            GroupName = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select db.GetDataValueName("Test Groups", t.Group_Category)).FirstOrDefault(),
                                            Group_Name = db.GetDataValueName("Test Groups", lbtD.Catagory_ID),
                                            lbtD.Rotation_ID,
                                            Rotation = ((from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select db.GetDataValueName("Main Test Departments", t.Main_Department)).FirstOrDefault()) == "X-Ray" ? db.GetDataValueName("Test XRay Rotations", lbtD.Rotation_ID) : db.GetDataValueName("Test CT Scan Rotations", lbtD.Rotation_ID),
                                            DataValue_Description = (from dv in db.DataValues
                                                                     join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                                                                     where vs.ValueSet_Name == ("Test XRay Rotations").ToString() && dv.DataValue_Name == lbtD.Rotation_ID
                                                                     select dv.DataValue_Description).FirstOrDefault(),

                                            lbtD.Special_Tests,
                                            lbtD.Area_Of_Interest,
                                            lbtD.Doctor,
                                            lbtD.Recieved_ID,
                                            Is_Result = (from t in db.Lab_Test_Details where t.BillDetailID == lbtD.BillDetailID orderby t.Lab_Test_Detail_ID descending select t.isApproved).FirstOrDefault(),
                                            outpat.Doctor_ID
                                        }
               ).ToList();


            List<LabTestClass> list = new List<LabTestClass>();

            foreach (var item in InPatienttestilst)
            {
                LabTestClass obj = new LabTestClass();

                //// obj.IsBilled = (bool)item.IsBilled;
                obj.Lab_Test_Detail_ID = item.Lab_Test_Detail_ID.ToString();
                obj.Date = Convert.ToDateTime(item.Date);
                obj.Remark = item.Remark;
                obj.Catagory_ID = item.Catagory_ID;
                obj.Lab_Test_ID = item.Lab_Test_ID.ToString();
                obj.Test_ID = item.Test_ID;
                obj.Dept_ID = item.Dept_ID;
                obj.L_R_Rotation_ID = item.L_R_Rotation_ID;

                obj.In_Patient_ID = item.In_Patient_ID;

                obj.Value_Type = item.Value_Type;
                obj.Value_TypeGroup = item.Value_TypeGroup;
                obj.Test_Name = item.Test_Name;
                obj.Group_Department = item.Group_Department;
                obj.Group_Category = item.Group_Category;
                obj.DepartmentName = item.DepartmentName;
                //obj.Lab_Test_Detail_ID = item.Lab_Test_Detail_ID.ToString();
                obj.Department_ID = item.Department_ID;
                obj.GroupName = item.GroupName;
                obj.Group_Name = item.Group_Name;
                obj.Rotation_ID = item.Rotation_ID;
                obj.Rotation = item.Rotation;
                obj.DataValue_Description = item.DataValue_Description;
                obj.Special_Tests = item.Special_Tests;
                obj.Area_Of_Interest = item.Area_Of_Interest;
                obj.Doctor = item.Doctor;
                obj.Recieved_ID = item.Recieved_ID;
                if (item.Is_Result == null)
                    obj.Is_Result = false;
                else
                    obj.Is_Result = (bool)item.Is_Result;
                obj.Status = "InPatient";
                //obj.DoctorName = item.DoctorName;
                list.Add(obj);
            }

            foreach (var item in OutPatienttestilst)
            {
                LabTestClass obj = new LabTestClass();

                //// obj.IsBilled = (bool)item.IsBilled;
                obj.Lab_Test_Detail_ID = item.Lab_Test_Detail_ID.ToString();
                obj.Date = Convert.ToDateTime(item.Date);
                obj.Remark = item.Remark;
                obj.Catagory_ID = item.Catagory_ID;
                obj.Lab_Test_ID = item.Lab_Test_ID.ToString();
                obj.Test_ID = item.Test_ID;
                obj.Dept_ID = item.Dept_ID;
                obj.L_R_Rotation_ID = item.L_R_Rotation_ID;

                obj.In_Patient_ID = item.Out_Patient_ID;

                obj.Value_Type = item.Value_Type;
                obj.Value_TypeGroup = item.Value_TypeGroup;
                obj.Test_Name = item.Test_Name;
                obj.Group_Department = item.Group_Department;
                obj.Group_Category = item.Group_Category;
                obj.DepartmentName = item.DepartmentName;
                //obj.Lab_Test_Detail_ID = item.Lab_Test_Detail_ID.ToString();
                obj.Department_ID = item.Department_ID;
                obj.GroupName = item.GroupName;
                obj.Group_Name = item.Group_Name;
                obj.Rotation_ID = item.Rotation_ID;
                obj.Rotation = item.Rotation;
                obj.DataValue_Description = item.DataValue_Description;
                obj.Special_Tests = item.Special_Tests;
                obj.Area_Of_Interest = item.Area_Of_Interest;
                obj.Doctor = item.Doctor;
                obj.Recieved_ID = item.Recieved_ID;

                if (item.Is_Result == null)
                    obj.Is_Result = false;
                else
                    obj.Is_Result = (bool)item.Is_Result;
                obj.DoctorName = item.Doctor_ID;
                obj.Status = "OutPatient";
                list.Add(obj);
            }

            return (new JavaScriptSerializer()).Serialize(list);
        }
        public class TestDetail
        {
            public string TestName;
            public string Department;
            public string Main;
            public string Image_path;
            public string Group;
            public bool? Status;
            public string ValueType;
            public string Template;
            public string Diagnosiss;
            public string notes;
        }
        [WebMethod]
        public static TestDetail GetTestDetail(string TestDetailID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var data = (from td in db.Lab_Test_Details
                        join t in db.Lab_Tests
                        on td.Test_ID equals t.Test_ID
                        where td.Lab_Test_Detail_ID == int.Parse(TestDetailID)
                        select new TestDetail
                        {
                            TestName = t.Test_Name,
                            Department = db.GetDataValueName("Test Departments", t.Group_Department),
                            Main = db.GetDataValueName("Main Test Departments", t.Main_Department),
                            Group = db.GetDataValueName("Test Groups", t.Group_Category),
                            Status = td.Status,
                            ValueType = t.Value_Type,
                            Template = t.Fixed_Value,
                            Image_path = td.Image_path,
                            Diagnosiss = td.Diagnosis,
                            notes = td.Notes
                        }).FirstOrDefault();
            return data;
        }
        [WebMethod]
        public static string GetTestResultList(int id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Pat_id = (from p in db.Reg_patients join pat in db.Patients on p.pat_id equals pat.Reg_PatId where pat.Patient_ID == Convert.ToInt32(id) select p.pat_id).FirstOrDefault();
            // var patientIDs = (from p in db.Reg_patients where p.Patient_No == patientNo select p.pat_id).ToList();
            //Individual Tests
            var data = (from lt in db.Laboratory_Tests
                        join ltd in db.Lab_Test_Details on lt.Lab_Test_ID equals ltd.Lab_Test_ID
                        join tdef in db.Lab_Tests on ltd.Test_ID equals tdef.Test_ID
                        join pa in db.Reg_patients on lt.Patient_ID equals pa.pat_id
                        join bd in db.Ar_Billing_Details on ltd.Bill_Details_ID equals bd.Bill_Details_ID
                        join img in db.Test_Images on ltd.Lab_Test_Detail_ID equals img.Lab_Test_Detail_ID into imgJoin
                        from imgLeftJoin in imgJoin.DefaultIfEmpty()
                        where pa.pat_id == Convert.ToInt32(Convert.ToString(Pat_id))
                                && (bd.Is_Group_Category == null ? false : bd.Is_Group_Category) == false
                                && bd.Is_Group_Category == false
                        select new
                        {
                            lt.Parent_Transaction_Type,
                            lt.Parent_Transaction_Type_ID,
                            lt.Lab_Test_ID,
                            tdef.Test_ID,
                            ltd.Date,
                            ltd.Test_Ready_On,
                            ltd.Test_Collected_By,
                            ltd.Lab_Test_Detail_ID,
                            tdef.Test_Name,
                            ltd.Rotation_ID,
                            ltd.Emergancy,
                            ltd.L_R_Rotation_ID,
                            tdef.Group_Category,
                            //Image_ID = imgLeftJoin != null ? imgLeftJoin.Image_ID : null,
                            Image_ID = imgLeftJoin != null ? imgLeftJoin.Image_ID : (int?)null,
                            DepartmentName = (db.GetDataValueName("Main Test Departments", tdef.Main_Department) == null ? "" : db.GetDataValueName("Main Test Departments", tdef.Main_Department)),
                            GroupName = (db.GetDataValueName("Test Groups", tdef.Group_Category) == null ? "" : db.GetDataValueName("Test Groups", tdef.Group_Category)),
                            Rotation = db.GetDataValueName("Test XRay Rotations", ltd.Rotation_ID),
                            Unit_Name = (db.GetDataValueName("Test Units", tdef.Unit) == null ? "" : db.GetDataValueName("Test Units", tdef.Unit)),
                            tdef.Value_Type,
                            Status = ltd.Status == null ? false : true,
                            Image_path = imgLeftJoin != null ? imgLeftJoin.Image_path : null,
                            ltd.Is_Result,
                            ltd.Bill_Details_ID,
                            ltd.Rejected_Reason,
                            tdef.Report_Colum,
                            bd.Service_Date,
                            ltd.isApproved,
                            lt.Patient_ID
                        }).ToList();


            List<Test> AlltestList = new List<Test>();
            List<Test> AlltestListRefined = new List<Test>();
            // Populate Test in list (Single Test)
            foreach (var item in data)
            {
                Test test = new Test();
                test.Lab_Test_Detail_ID = item.Lab_Test_Detail_ID.ToString();
                test.Lab_Test_ID = item.Lab_Test_ID.ToString();
                test.Test_ID = item.Test_ID.ToString();
                test.Test_Name = item.Test_Name;
                test.DepartmentName = item.DepartmentName;
                test.Group_Category = item.Group_Category;
                test.GroupName = item.GroupName;
                test.Test_Collected_By = item.Test_Collected_By;
                if (item.Is_Result != null)
                {
                    test.Is_Result = (bool)item.Is_Result;
                }
                else
                {
                    test.Is_Result = false;
                }
                if (item.Emergancy != null)
                {

                    test.Emergancy = (bool)item.Emergancy;
                }
                else
                {
                    test.Emergancy = false;
                }
                test.Rotation_ID = item.Rotation_ID;
                test.ImagePath = item.Image_path;
                test.Image_ID = Convert.ToString(item.Image_ID);
                test.Rotation = item.Rotation;
                test.Unit_Name = item.Unit_Name;
                test.ValueType = item.Value_Type;
                test.Status = (bool)item.Status;
                test.Parent_Transaction_Type = item.Parent_Transaction_Type;
                test.Parent_Transaction_Type_ID = Convert.ToInt32(item.Parent_Transaction_Type_ID);
                test.Bill_Details_ID = item.Bill_Details_ID.ToString();
                test.Rejected_Reason = item.Rejected_Reason;
                test.Report_Colum = item.Report_Colum;
                test.Service_Date = item.Service_Date.ToString();
                test.Test_Collected_On = item.Date.ToString();
                test.Test_Ready_On = item.Test_Ready_On.ToString();
                test.Service_Date = item.Service_Date.ToString();
                if (item.isApproved != null)
                {
                    test.Is_Approve = (bool)item.isApproved;
                }
                else
                {
                    test.Is_Approve = false;
                }
                test.patient_ID = Convert.ToString(item.Patient_ID);
                AlltestList.Add(test);
            }

            AlltestListRefined = AlltestList;
            // For Group Tests
            DataTable GroupTest = DBClass.getDataTable("Select Distinct ld.Lab_Test_ID,(select Segment2 from Datavalues where Datavalue_Name = (Select Group_Category from Lab_TEsts where TEst_ID = ld.Test_ID) and ValueSet_ID = 70) as [Segment2] ,(select Datavalue_ID from Datavalues where Datavalue_Name = (Select Group_Category from Lab_TEsts where TEst_ID = ld.Test_ID) and ValueSet_ID = 70) as [Test_ID], (Select Group_Category from Lab_TEsts where TEst_ID = ld.Test_ID) as [Group_Category], dbo.GetDataValueName('Test Groups', (Select Group_Category from Lab_TEsts where TEst_ID = ld.Test_ID)) as [Group_Test_Name], bd.Bill_Details_ID,ld.Is_Result,ld.Rejected_Reason,bd.Service_Date ,isnull(ld.isApproved,'') as IsApproved,ltm.patient_id,FORMAT(ld.date, 'yyyy-MM-dd HH:mm') AS Test_Collected_On,FORMAT(ld.Test_Ready_On, 'yyyy-MM-dd HH:mm') AS Test_Ready_On,isNull(ld.Test_Collected_By,'') as Test_Collected_By,dbo.GetDataValueName('Main Test Departments',lt.Main_Department) as DepartmentName from Lab_Test_Detail ld, Lab_Tests lt, Laboratory_Test ltm, AR_Billing_Details bd, Reg_patient pat where bd.Bill_Details_ID = ld.Bill_Details_ID and isnull(bd.Is_Group_Category,0) = 1 and ld.Patient_ID = pat.pat_id  and pat.pat_id = (case when " + Pat_id + " = 0 then pat.pat_id else " + Pat_id + " end) and lt.Test_ID = ld.Test_ID and ltm.Lab_Test_ID = ld.Lab_Test_ID");


            foreach (DataRow item in GroupTest.Rows)
            {
                Test TestObj = new Test()
                {
                    Lab_Test_ID = item[0] == DBNull.Value ? "" : item[0].ToString(),
                    Report_Colum = item[1] == DBNull.Value ? "" : item[1].ToString(),
                    Test_ID = item[2] == DBNull.Value ? "" : item[2].ToString(),
                    Group_Category = item[3] == DBNull.Value ? "" : item[3].ToString(),
                    Test_Name = item[4] == DBNull.Value ? "" : item[4].ToString(),
                    Bill_Details_ID = item[5] == DBNull.Value ? "" : item[5].ToString(),
                    Is_Result = Convert.ToBoolean(item[6] == DBNull.Value ? "" : item[6]),
                    Rejected_Reason = item[7] == DBNull.Value ? "" : item[7].ToString(),
                    Service_Date = item[8] == DBNull.Value ? "" : item[8].ToString(),
                    Is_Approve = Convert.ToBoolean(item[9] == DBNull.Value ? "" : item[9]),
                    patient_ID = item[10] == DBNull.Value ? "" : item[10].ToString(),
                    Test_Collected_On = item[11] == DBNull.Value ? "" : item[11].ToString(),
                    Test_Ready_On = item[12] == DBNull.Value ? "" : item[12].ToString(),
                    Test_Collected_By = item[13] == DBNull.Value ? "" : item[13].ToString(),
                    DepartmentName = item[14] == DBNull.Value ? "" : item[14].ToString(),

                };

                TestObj.ListOfTestIDs = DBClass.getField("select dbo.[GetGroupSubTests]('" + TestObj.Group_Category + "')");

                AlltestListRefined.Add(TestObj);
            }
            return (new JavaScriptSerializer()).Serialize(AlltestListRefined);
        }
        public class Test
        {
            public string Lab_Test_Detail_ID { get; set; }
            public DateTime Date { get; set; }
            public string Remark { get; set; }
            public string Lab_Test_ID { get; set; }
            public string Test_ID { get; set; }
            public string Test_Name { get; set; }
            public string Group_Department { get; set; }
            public string DepartmentName { get; set; }
            public string Test_Collected_By { get; set; }
            public string Group_Category { get; set; }
            public string GroupName { get; set; }
            public string Rotation_ID { get; set; }
            public string Rotation { get; set; }
            public string GroupCategory_ID { get; set; }
            public string Unit { get; set; }
            public string Unit_Name { get; set; }
            public string ValueType { get; set; }
            public bool Status { get; set; }
            public string ImagePath { get; set; }
            public string Result_ID { get; set; }
            public string Parent_Transaction_Type { get; set; }
            public int Parent_Transaction_Type_ID { get; set; }
            public bool Is_Result { get; set; }
            public bool Emergancy { get; set; }
            public string ListOfTestIDs { get; set; }
            public string Bill_Details_ID { get; set; }
            public string patient_ID { get; set; }

            public string Rejected_Reason { get; set; }

            public string Report_Colum { get; set; }
            public string Service_Date { get; set; }
            public string Test_Ready_On { get; set; }
            public string Test_Collected_On { get; set; }

            public bool Is_Approve { get; set; }
            public string Image_ID { get; set; }
        }


        [WebMethod]
        public static string LoadAllTestResultCatagory(string LabDTestID, string CatID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var LabTestID = (from pat in db.Lab_Test_Details where pat.Lab_Test_Detail_ID == Convert.ToInt32(LabDTestID) select pat.Lab_Test_ID).FirstOrDefault();

            var inPatmedicineList = (from lbtM in db.Laboratory_Tests
                                     join lbtD in db.Lab_Test_Details
                                     on lbtM.Lab_Test_ID equals lbtD.Lab_Test_ID
                                     join t in db.Lab_Tests
                                     on lbtD.Test_ID equals t.Test_ID
                                     where lbtD.Lab_Test_ID == Convert.ToInt32(LabTestID)
                                     select new
                                     {
                                         lbtM.Lab_Test_ID,
                                         lbtD.Lab_Test_Detail_ID,
                                         lbtD.Test_ID,
                                         Test_Name = ((from pat in db.Lab_Tests where pat.Test_ID == lbtD.Test_ID select pat.Test_Name).FirstOrDefault()),
                                         lbtD.IsBilled,
                                         lbtD.Catagory_ID,
                                     }).ToList();

            return (new JavaScriptSerializer()).Serialize(inPatmedicineList);
        }
        [WebMethod]
        public static string LoadAllTestCatagory(string LabDTestID, string CatID, string GroupCat)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            if (CatID != "0")
            {
                //Group Tests
                var inPatmedicineList = (from lbtM in db.Laboratory_Tests
                                         join lbtD in db.Lab_Test_Details
                                         on lbtM.Lab_Test_ID equals lbtD.Lab_Test_ID
                                         join t in db.Lab_Tests
                                         on lbtD.Test_ID equals t.Test_ID
                                         where lbtD.Lab_Test_ID == Convert.ToInt32(LabDTestID) && t.Group_Category == CatID
                                         select new
                                         {
                                             lbtD.Bill_Details_ID,
                                             lbtM.Lab_Test_ID,
                                             lbtD.Lab_Test_Detail_ID,
                                             lbtD.Test_ID,
                                             Test_Name = ((from pat in db.Lab_Tests where pat.Test_ID == lbtD.Test_ID select pat.Test_Name).FirstOrDefault()),
                                             t.Report_Colum,
                                             lbtD.IsBilled,
                                             lbtD.Catagory_ID,

                                         }).ToList();
                return (new JavaScriptSerializer()).Serialize(inPatmedicineList);
            }
            else
            {
                if (GroupCat == "")
                {
                    //Single Tests
                    var inPatmedicineList = (from lbtM in db.Laboratory_Tests
                                             join lbtD in db.Lab_Test_Details
                                             on lbtM.Lab_Test_ID equals lbtD.Lab_Test_ID
                                             join t in db.Lab_Tests
                                             on lbtD.Test_ID equals t.Test_ID
                                             join b in db.Ar_Billing_Details
                                             on lbtD.Bill_Details_ID equals b.Bill_Details_ID
                                             where lbtD.Lab_Test_ID == Convert.ToInt32(LabDTestID)
                                             && t.Group_Category == ""
                                             select new
                                             {
                                                 lbtM.Lab_Test_ID,
                                                 lbtD.Lab_Test_Detail_ID,
                                                 lbtD.Test_ID,
                                                 Test_Name = ((from pat in db.Lab_Tests where pat.Test_ID == lbtD.Test_ID select pat.Test_Name).FirstOrDefault()),
                                                 lbtD.IsBilled,
                                                 lbtD.Catagory_ID,
                                                 b.Bill_Details_ID,
                                                 t.Report_Colum
                                             }).ToList();
                    return (new JavaScriptSerializer()).Serialize(inPatmedicineList);
                }
                else
                {
                    //Group Single Test
                    var inPatmedicineList = (from lbtM in db.Laboratory_Tests
                                             join lbtD in db.Lab_Test_Details
                                             on lbtM.Lab_Test_ID equals lbtD.Lab_Test_ID
                                             join t in db.Lab_Tests
                                             on lbtD.Test_ID equals t.Test_ID
                                             where lbtD.Lab_Test_ID == Convert.ToInt32(LabDTestID)
                                             && t.Group_Category == GroupCat
                                             select new
                                             {
                                                 lbtM.Lab_Test_ID,
                                                 lbtD.Lab_Test_Detail_ID,
                                                 lbtD.Test_ID,
                                                 Test_Name = ((from pat in db.Lab_Tests where pat.Test_ID == lbtD.Test_ID select pat.Test_Name).FirstOrDefault()),
                                                 lbtD.IsBilled,
                                                 lbtD.Catagory_ID,
                                                 t.Report_Colum
                                             }).ToList();
                    return (new JavaScriptSerializer()).Serialize(inPatmedicineList);
                }
            }
        }

        [WebMethod]
        public static string FillDays_Years_MonthsDropDown()
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var Routes = from d in db.DataValues
                         join v in db.ValueSets
                         on d.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Name == "Days_Years_Months"
                         select new
                         {
                             d.DataValue_Name,
                             d.DataValue_Description
                         };

            return (new JavaScriptSerializer().Serialize(Routes));
        }

        public class Symtom
        {
            public int OutPatientID { get; set; }
            public List<SymtomsList> SymtomsList { get; set; }
        }
        public class SymtomsList
        {
            public string SymtomID { get; set; }
            public string Duration { get; set; }
            public string DayYearMonth { get; set; }
            public string Remarks { get; set; }
        }
        [WebMethod]
        public static string LoadENTHistory(int PatientID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            int Patien_No = DBClass.GetMRNOBy_PatientID(Convert.ToInt32(PatientID));

            var InPatCase = (from op in db.In_Patients
                             join p in db.Patients
                             on op.Patient_ID equals p.Patient_ID
                             where p.Patient_No == Patien_No

                             select new
                             {
                                 op.ENT_Throat_IDL,
                                 op.ENT_Throat_Nose,
                                 op.ENT_Ear_Right,
                                 op.Ent_Ear_Left,
                                 op.ENT_Rinnes_Right_PosNeg,
                                 op.ENT_Rinnes_Right_Neg,
                                 op.ENT_Rinnes_Right_FalseNeg,
                                 op.ENT_Rinnes_Right_FNeg,
                                 op.ENT_Rinnes_Lft_PosNeg,
                                 op.ENT_Rinnes_Lft_Neg,
                                 op.ENT_Rinnes_Lft_FalseNeg,
                                 op.ENT_Rinnes_Lft_FNeg,
                                 op.ENT_Webber_Central,
                                 op.ENT_Webber_Lateralized,
                                 op.ENT_Investigation_PTA,
                                 op.ENT_Investigation_Tympanometry,
                                 op.Created_Time
                             }).ToList();


            var OutPatCase = (from op in db.Out_Patients
                              join p in db.Patients
                              on op.Patient_ID equals p.Patient_ID
                              where p.Patient_No == Patien_No

                              select new
                              {
                                  op.ENT_Throat_IDL,
                                  op.ENT_Throat_Nose,
                                  op.ENT_Ear_Right,
                                  op.Ent_Ear_Left,
                                  op.ENT_Rinnes_Right_PosNeg,
                                  op.ENT_Rinnes_Right_Neg,
                                  op.ENT_Rinnes_Right_FalseNeg,
                                  op.ENT_Rinnes_Right_FNeg,
                                  op.ENT_Rinnes_Lft_PosNeg,
                                  op.ENT_Rinnes_Lft_Neg,
                                  op.ENT_Rinnes_Lft_FalseNeg,
                                  op.ENT_Rinnes_Lft_FNeg,
                                  op.ENT_Webber_Central,
                                  op.ENT_Webber_Lateralized,
                                  op.ENT_Investigation_PTA,
                                  op.ENT_Investigation_Tympanometry,
                                  op.Created_Time
                              }).ToList();


            List<ENTDetailClass> list = new List<ENTDetailClass>();

            foreach (var item in InPatCase)
            {
                ENTDetailClass obj = new ENTDetailClass();

                obj.ENT_Throat_IDL = item.ENT_Throat_IDL;
                obj.ENT_Throat_Nose = item.ENT_Throat_Nose;
                obj.Created_Time = Convert.ToDateTime(item.Created_Time);
                obj.ENT_Ear_Right = item.ENT_Ear_Right;
                obj.Ent_Ear_Left = item.Ent_Ear_Left;
                obj.ENT_Rinnes_Right_PosNeg = item.ENT_Rinnes_Right_PosNeg.ToString();
                obj.ENT_Rinnes_Right_Neg = item.ENT_Rinnes_Right_Neg.ToString();

                obj.ENT_Rinnes_Right_FalseNeg = item.ENT_Rinnes_Right_FalseNeg.ToString();
                obj.ENT_Rinnes_Right_FNeg = item.ENT_Rinnes_Right_FNeg.ToString();
                obj.ENT_Rinnes_Lft_PosNeg = item.ENT_Rinnes_Lft_PosNeg.ToString();
                obj.ENT_Rinnes_Lft_Neg = item.ENT_Rinnes_Lft_Neg.ToString();
                obj.ENT_Rinnes_Lft_FNeg = item.ENT_Rinnes_Lft_FNeg.ToString();
                obj.ENT_Webber_Central = item.ENT_Webber_Central.ToString();
                obj.ENT_Investigation_PTA = item.ENT_Investigation_PTA.ToString();
                obj.ENT_Investigation_Tympanometry = item.ENT_Investigation_Tympanometry.ToString();
                obj.ENT_Rinnes_Lft_FalseNeg = item.ENT_Rinnes_Lft_FalseNeg.ToString();
                obj.ENT_Webber_Lateralized = item.ENT_Webber_Lateralized.ToString();
                obj.ENT_Rinnes_Lft_FNeg = item.ENT_Rinnes_Lft_FNeg.ToString();
                obj.Status = "InPatient";
                list.Add(obj);
            }
            foreach (var item in OutPatCase)
            {
                ENTDetailClass obj = new ENTDetailClass();

                obj.ENT_Throat_IDL = item.ENT_Throat_IDL;
                obj.ENT_Throat_Nose = item.ENT_Throat_Nose;
                obj.Created_Time = Convert.ToDateTime(item.Created_Time);
                obj.ENT_Ear_Right = item.ENT_Ear_Right;
                obj.Ent_Ear_Left = item.Ent_Ear_Left;
                obj.ENT_Rinnes_Right_PosNeg = item.ENT_Rinnes_Right_PosNeg.ToString();
                obj.ENT_Rinnes_Right_Neg = item.ENT_Rinnes_Right_Neg.ToString();

                obj.ENT_Rinnes_Right_FalseNeg = item.ENT_Rinnes_Right_FalseNeg.ToString();
                obj.ENT_Rinnes_Right_FNeg = item.ENT_Rinnes_Right_FNeg.ToString();
                obj.ENT_Rinnes_Lft_PosNeg = item.ENT_Rinnes_Lft_PosNeg.ToString();
                obj.ENT_Rinnes_Lft_Neg = item.ENT_Rinnes_Lft_Neg.ToString();
                obj.ENT_Rinnes_Lft_FNeg = item.ENT_Rinnes_Lft_FNeg.ToString();
                obj.ENT_Webber_Central = item.ENT_Webber_Central.ToString();
                obj.ENT_Investigation_PTA = item.ENT_Investigation_PTA.ToString();
                obj.ENT_Investigation_Tympanometry = item.ENT_Investigation_Tympanometry.ToString();
                obj.ENT_Rinnes_Lft_FalseNeg = item.ENT_Rinnes_Lft_FalseNeg.ToString();
                obj.ENT_Webber_Lateralized = item.ENT_Webber_Lateralized.ToString();
                obj.ENT_Rinnes_Lft_FNeg = item.ENT_Rinnes_Lft_FNeg.ToString();
                obj.Status = "OutPatient";
                list.Add(obj);
            }
            return ((new JavaScriptSerializer()).Serialize(list));
        }
        public class ENTDetailClass
        {
            //public string Status;
            public string ENT_Throat_IDL;
            public string ENT_Throat_Nose;
            public string ENT_Ear_Right;
            public string Ent_Ear_Left;
            public DateTime Medicine_Date;
            public string ENT_Rinnes_Right_PosNeg;
            public string ENT_Rinnes_Right_Neg;
            public string Status;
            public string ENT_Rinnes_Right_FalseNeg;
            public string ENT_Rinnes_Right_FNeg;
            public string ENT_Rinnes_Lft_PosNeg;
            public string ENT_Rinnes_Lft_Neg;
            public DateTime Created_Time;
            public string ENT_Rinnes_Lft_FalseNeg;
            public string ENT_Rinnes_Lft_FNeg;
            public string ENT_Webber_Central;
            public string ENT_Webber_Lateralized;
            public string ENT_Investigation_PTA;
            public string ENT_Investigation_Tympanometry;
            //public DateTime Medicine_Date;
            //public string ENT_Rinnes_Lft_FalseNeg;
            // public string ENT_Rinnes_Lft_FNeg;
        }
        public class DermaDetailClass
        {
            public string DermaFace;
            public string DermaNeck;
            public string DermaUpperLimb;
            public string DermaTrunk;
            public DateTime Medicine_Date;
            public string DermaLowerLimb;
            public string DermaFlexures;
            public string Status;
            public string DermaGenitalias;
            public string DermaHair;
            public string DermaNail;
            public string DermaMucousMembrane;
            public DateTime Created_Time;
            public string DermaEyes;
            public string DermaEars;
            public string DermaNose;
            public string DermaLips;

        }

        [WebMethod]
        public static string LoadDermaHistory(int PatientID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            int Patien_No = DBClass.GetMRNOBy_RgPatientID(Convert.ToInt32(PatientID));

            var InPatCase = (from op in db.In_Patients
                             join p in db.Patients
                             on op.Patient_ID equals p.Patient_ID
                             where p.Patient_No == Patien_No

                             select new
                             {
                                 op.DermaFace,
                                 op.DermaNeck,
                                 op.DermaTrunk,
                                 op.DermaUpperLimb,
                                 op.DermaLowerLimb,
                                 op.DermaFlexures,
                                 op.DermaGenitalias,
                                 op.DermaHair,
                                 op.DermaNail,
                                 op.DermaMucousMembrane,
                                 op.DermaEyes,
                                 op.DermaEars,
                                 op.DermaNose,
                                 op.DermaLips,
                                 op.Created_Time
                             }).ToList();


            var OutPatCase = (from op in db.Out_Patients
                              join p in db.Patients
                             on op.Patient_ID equals p.Patient_ID
                              join rp in db.Reg_patients
                              on p.Reg_PatId equals rp.pat_id
                              where rp.Patient_No == Patien_No

                              select new
                              {
                                  op.DermaFace,
                                  op.DermaNeck,
                                  op.DermaTrunk,
                                  op.DermaUpperLimb,
                                  op.DermaLowerLimb,
                                  op.DermaFlexures,
                                  op.DermaGenitalias,
                                  op.DermaHair,
                                  op.DermaNail,
                                  op.DermaMucousMembrane,
                                  op.DermaEyes,
                                  op.DermaEars,
                                  op.DermaNose,
                                  op.DermaLips,
                                  op.Created_Time
                              }).ToList();
            List<DermaDetailClass> list = new List<DermaDetailClass>();

            foreach (var item in InPatCase)
            {
                DermaDetailClass obj = new DermaDetailClass();

                obj.DermaFace = item.DermaFace;
                obj.DermaNeck = item.DermaNeck;

                obj.DermaTrunk = item.DermaTrunk;
                obj.DermaUpperLimb = item.DermaUpperLimb;
                obj.DermaLowerLimb = item.DermaLowerLimb.ToString();
                obj.DermaFlexures = item.DermaFlexures.ToString();

                obj.DermaGenitalias = item.DermaGenitalias.ToString();
                obj.DermaHair = item.DermaHair.ToString();
                obj.DermaNail = item.DermaNail.ToString();
                obj.DermaMucousMembrane = item.DermaMucousMembrane.ToString();
                obj.DermaEyes = item.DermaEyes.ToString();
                obj.DermaEars = item.DermaEars.ToString();
                obj.DermaNose = item.DermaNose.ToString();
                obj.Created_Time = Convert.ToDateTime(item.Created_Time);

                obj.DermaLips = item.DermaLips.ToString();
                obj.Status = "InPatient";
                list.Add(obj);
            }
            foreach (var item in OutPatCase)
            {
                DermaDetailClass obj = new DermaDetailClass();



                obj.DermaFace = item.DermaFace;
                obj.DermaNeck = item.DermaNeck;
                obj.DermaTrunk = item.DermaTrunk;
                obj.DermaUpperLimb = item.DermaUpperLimb;
                obj.DermaLowerLimb = item.DermaLowerLimb.ToString();
                obj.DermaFlexures = item.DermaFlexures.ToString();
                obj.DermaGenitalias = item.DermaGenitalias.ToString();
                obj.DermaHair = item.DermaHair.ToString();
                obj.DermaNail = item.DermaNail.ToString();
                obj.DermaMucousMembrane = item.DermaMucousMembrane.ToString();
                obj.DermaEyes = item.DermaEyes.ToString();
                obj.DermaEars = item.DermaEars.ToString();
                obj.DermaNose = item.DermaNose.ToString();
                obj.DermaLips = item.DermaLips.ToString();
                obj.Created_Time = Convert.ToDateTime(item.Created_Time);
                obj.Status = "OutPatient";
                list.Add(obj);
            }
            return ((new JavaScriptSerializer()).Serialize(list));
        }
        [WebMethod]
        public static string LoadPsychiatryHistoryInpat(int PatientID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            int Patien_No = DBClass.GetMRNOBy_PatientID(Convert.ToInt32(PatientID));

            var PatCase = (from op in db.In_Patients
                           join p in db.Patients
                          on op.Patient_ID equals p.Patient_ID
                           where p.Patient_No == Patien_No
                           select new
                           {

                               op.Psychiatry_Informant,

                               op.Psychiatry_Source_Referral,
                               op.Psychiatry_Neck_Holding,
                               op.Psychiatry_Walking,
                               op.Psychiatry_Talking,
                               op.Psychiatry_Others,
                               op.Psychiatry_Menarche,
                               op.Psychiatry_Menstrual,
                               op.Psychiatry_Attachment_Separation,
                               op.Psychiatry_Health,

                               op.Psychiatry_Nail_Biting,
                               op.Psychiatry_Temper_Tantrums,
                               op.Psychiatry_Bed_Wetting,
                               op.Psychiatry_Academics,

                               op.Psychiatry_Peer_Relationship,
                               op.Psychiatry_Behaviour,
                               op.Psychiatry_Occupational_History,
                               op.Psychiatry_Sexual_History,
                               op.Psychiatry_Substance_Use,
                               op.Psychiatry_Forensic_Use,
                               op.Psychiatry_Relationship,
                               op.Psychiatry_Leisure_Activities,
                               op.Psychiatry_Attitude_Standards,
                               op.Psychiatry_Prevalling_Mood,
                               op.Psychiatry_Reaction_Stress,
                               op.Psychiatry_Religious_Practices,
                               op.Psychiatry_Father,
                               op.Psychiatry_Mother,

                               op.Psychiatry_Siblings,
                               op.Psychiatry_Home_Atmosphere,
                               op.Psychiatry_Familial_Illness,
                               // op.Psychiatry_Rel,
                               op.Psychiatry_Actual_age,
                               op.Psychiatry_Race,
                               op.Psychiatry_Tattoos_body_scars,
                               op.Psychiatry_Body_Habitus,
                               op.Psychiatry_Dress,
                               op.Psychiatry_Hygiene,
                               op.Psychiatry_Psychomotor_Activity,
                               op.Psychiatry_Involuntary_movements,
                               op.Psychiatry_Dystonia_EPS,
                               op.Psychiatry_Tardive_dyskinesia,

                               op.Psychiatry_Tics,
                               op.Psychiatry_Tremors,
                               op.Psychiatry_Attentiveness_interview,
                               op.Psychiatry_Eye_Contact,
                               op.Psychiatry_Level_Consciousness,
                               op.Psychiatry_Rate,
                               op.Psychiatry_Rhythm,
                               op.Psychiatry_Volume,
                               op.Psychiatry_Tone,
                               op.Psychiatry_Modulation,
                               op.Psychiatry_Depressed,
                               op.Psychiatry_Elated,

                               op.Psychiatry_Irritable,
                               op.Psychiatry_Labile,
                               op.Psychiatry_Incongruent,
                               op.Psychiatry_Blunting_Flattening_Apathy,
                               op.Psychiatry_Thinking,
                               op.Psychiatry_Plans,
                               op.Psychiatry_Actions,
                               op.Psychiatry_Preservative,
                               op.Psychiatry_LoosAssociation,
                               op.Psychiatry_Tangentiaility,
                               op.Psychiatry_Circumstantiality,
                               op.Psychiatry_Flight_Ideas,
                               op.Psychiatry_Thought_Insertion,
                               op.Psychiatry_Thought_Withdrawal,
                               op.Psychiatry_Thought_Broadcasting,
                               op.Psychiatry_Thought_Control,
                               op.Psychiatry_Dellusion,
                               op.Psychiatry_Overvalued_Ideas,
                               op.Psychiatry_Depresonalization,
                               op.Psychiatry_Derealization,

                               op.Psychiatry_Obsession,
                               op.Psychiatry_Phobies,
                               op.Psychiatry_Homocidial_Ideas,
                               op.Psychiatry_Illusion,
                               op.Psychiatry_Hallucination,
                               op.Psychiatry_Orientation_Time,
                               op.Psychiatry_Place,
                               op.Psychiatry_Person,
                               op.Psychiatry_Attention_Concentration,
                               op.Psychiatry_Days_Week,
                               op.Psychiatry_Immediate_Memory,
                               op.Psychiatry_Recent_Events,
                               op.Psychiatry_Adress_Recall_Two,
                               op.Psychiatry_Remote_Events,
                               op.Psychiatry_Adress_Recall_Five,
                               op.Psychiatry_General_knowledge,
                               op.Psychiatry_Arthemetic_Calculation,
                               op.Psychiatry_Abstraction,
                               op.Psychiatry_Insight,
                               op.Created_Time,
                               op.Psychiatry_HBM_Problem,
                               op.Psychiatry_HBM_Caused,
                               op.Psychiatry_HBM_Started,
                               op.Psychiatry_HBM_Course,
                               op.Psychiatry_HBM_Treatment,
                               op.Psychiatry_HBM_Effects,
                               op.Psychiatry_PE_Pluse,
                               op.Psychiatry_PE_BP,
                               op.Psychiatry_PE_Temperature,
                               op.Psychiatry_PE_Weight,
                               op.Psychiatry_PE_RespiratoryRate,
                               op.Psychiatry_PE_Jaundice,
                               op.Psychiatry_PE_Anemia,
                               op.Psychiatry_PE_Cyanosis,
                               op.Psychiatry_PE_Clubbing,
                               op.Psychiatry_PE_JVP,
                               op.Psychiatry_PE_LymphNodes,
                               op.Psychiatry_PE_Edema,
                               op.Psychiatry_PE_Respiratory,
                               op.Psychiatry_PE_Cardiovascular,
                               op.Psychiatry_PE_Gastro_Intestinal,
                               op.Psychiatry_PE_Observation,
                               op.Psychiatry_PE_Cranial_Nerves,
                               op.Psychiatry_PE_Limb_Strength,
                               op.Psychiatry_PE_Spasticity,
                               op.Psychiatry_PE_Position,
                               op.Psychiatry_PE_Vibration,
                               op.Psychiatry_PE_Stereognosis,
                               op.Psychiatry_PE_Pain,
                               op.Psychiatry_PE_Biceps,
                               op.Psychiatry_PE_Triceps,
                               op.Psychiatry_PE_Brachioradialis,
                               op.Psychiatry_PE_Quadriceps,
                               op.Psychiatry_PE_Patellar,
                               op.Psychiatry_PE_Achilles,
                               op.Psychiatry_PE_Extensor,
                               op.Psychiatry_PE_Frontal,
                               op.Psychiatry_PE_Finger,
                               op.Psychiatry_PE_Heel,
                               op.Psychiatry_PE_Movements,
                               op.Psychiatry_PE_Gait,
                               op.Psychiatry_PE_Neck_Rigidity,
                               op.Psychiatry_PE_Kerning_Sign,
                               op.Psychiatry_PE_Brudzinki_Sign,
                               op.Psychiatry_For_Summary,
                               op.Psychiatry_For_Diagnosis,
                               op.Psychiatry_For_AxisI,
                               op.Psychiatry_For_AxisIII,
                               op.Psychiatry_For_AxisII,
                               op.Psychiatry_For_AxisIV,
                               op.Psychiatry_For_AxisV,
                               op.Psychiatry_For_PredisposingFactors,
                               op.Psychiatry_For_PrecipitatingFactors,
                               op.Psychiatry_For_PrepetuatingFactors,
                               op.Psychiatry_For_Investigation,
                               op.Psychiatry_For_Medical,
                               op.Psychiatry_For_Psychological,
                               op.Psychiatry_Major_Issues,
                               op.Psychiatry_For_Strengths,
                               op.Psychiatry_For_Goals,
                               op.Psychiatry_For_Strategies,
                           }).ToList();
            return ((new JavaScriptSerializer()).Serialize(PatCase));
        }
        [WebMethod]
        public static string LoadPsychiatryHistory(int PatientID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            int Patien_No = DBClass.GetMRNOBy_RgPatientID(Convert.ToInt32(PatientID));

            var PatCase = (from op in db.Out_Patients
                           join p in db.Patients
                          on op.Patient_ID equals p.Patient_ID
                           join rp in db.Reg_patients
on p.Reg_PatId equals rp.pat_id
                           where rp.Patient_No == Patien_No
                           select new
                           {

                               op.Psychiatry_Informant,

                               op.Psychiatry_Source_Referral,
                               op.Psychiatry_Neck_Holding,
                               op.Psychiatry_Walking,
                               op.Psychiatry_Talking,
                               op.Psychiatry_Others,
                               op.Psychiatry_Menarche,
                               op.Psychiatry_Menstrual,
                               op.Psychiatry_Attachment_Separation,
                               op.Psychiatry_Health,

                               op.Psychiatry_Nail_Biting,
                               op.Psychiatry_Temper_Tantrums,
                               op.Psychiatry_Bed_Wetting,
                               op.Psychiatry_Academics,

                               op.Psychiatry_Peer_Relationship,
                               op.Psychiatry_Behaviour,
                               op.Psychiatry_Occupational_History,
                               op.Psychiatry_Sexual_History,
                               op.Psychiatry_Substance_Use,
                               op.Psychiatry_Forensic_Use,
                               op.Psychiatry_Relationship,
                               op.Psychiatry_Leisure_Activities,
                               op.Psychiatry_Attitude_Standards,
                               op.Psychiatry_Prevalling_Mood,
                               op.Psychiatry_Reaction_Stress,
                               op.Psychiatry_Religious_Practices,
                               op.Psychiatry_Father,
                               op.Psychiatry_Mother,

                               op.Psychiatry_Siblings,
                               op.Psychiatry_Home_Atmosphere,
                               op.Psychiatry_Familial_Illness,
                               // op.Psychiatry_Rel,
                               op.Psychiatry_Actual_age,
                               op.Psychiatry_Race,
                               op.Psychiatry_Tattoos_body_scars,
                               op.Psychiatry_Body_Habitus,
                               op.Psychiatry_Dress,
                               op.Psychiatry_Hygiene,
                               op.Psychiatry_Psychomotor_Activity,
                               op.Psychiatry_Involuntary_movements,
                               op.Psychiatry_Dystonia_EPS,
                               op.Psychiatry_Tardive_dyskinesia,

                               op.Psychiatry_Tics,
                               op.Psychiatry_Tremors,
                               op.Psychiatry_Attentiveness_interview,
                               op.Psychiatry_Eye_Contact,
                               op.Psychiatry_Level_Consciousness,
                               op.Psychiatry_Rate,
                               op.Psychiatry_Rhythm,
                               op.Psychiatry_Volume,
                               op.Psychiatry_Tone,
                               op.Psychiatry_Modulation,
                               op.Psychiatry_Depressed,
                               op.Psychiatry_Elated,

                               op.Psychiatry_Irritable,
                               op.Psychiatry_Labile,
                               op.Psychiatry_Incongruent,
                               op.Psychiatry_Blunting_Flattening_Apathy,
                               op.Psychiatry_Thinking,
                               op.Psychiatry_Plans,
                               op.Psychiatry_Actions,
                               op.Psychiatry_Preservative,
                               op.Psychiatry_LoosAssociation,
                               op.Psychiatry_Tangentiaility,
                               op.Psychiatry_Circumstantiality,
                               op.Psychiatry_Flight_Ideas,
                               op.Psychiatry_Thought_Insertion,
                               op.Psychiatry_Thought_Withdrawal,
                               op.Psychiatry_Thought_Broadcasting,
                               op.Psychiatry_Thought_Control,
                               op.Psychiatry_Dellusion,
                               op.Psychiatry_Overvalued_Ideas,
                               op.Psychiatry_Depresonalization,
                               op.Psychiatry_Derealization,

                               op.Psychiatry_Obsession,
                               op.Psychiatry_Phobies,
                               op.Psychiatry_Homocidial_Ideas,
                               op.Psychiatry_Illusion,
                               op.Psychiatry_Hallucination,
                               op.Psychiatry_Orientation_Time,
                               op.Psychiatry_Place,
                               op.Psychiatry_Person,
                               op.Psychiatry_Attention_Concentration,
                               op.Psychiatry_Days_Week,
                               op.Psychiatry_Immediate_Memory,
                               op.Psychiatry_Recent_Events,
                               op.Psychiatry_Adress_Recall_Two,
                               op.Psychiatry_Remote_Events,
                               op.Psychiatry_Adress_Recall_Five,
                               op.Psychiatry_General_knowledge,
                               op.Psychiatry_Arthemetic_Calculation,
                               op.Psychiatry_Abstraction,
                               op.Psychiatry_Insight,
                               op.Created_Time,
                               op.Psychiatry_HBM_Problem,
                               op.Psychiatry_HBM_Caused,
                               op.Psychiatry_HBM_Started,
                               op.Psychiatry_HBM_Course,
                               op.Psychiatry_HBM_Treatment,
                               op.Psychiatry_HBM_Effects,
                               op.Psychiatry_PE_Pluse,
                               op.Psychiatry_PE_BP,
                               op.Psychiatry_PE_Temperature,
                               op.Psychiatry_PE_Weight,
                               op.Psychiatry_PE_RespiratoryRate,
                               op.Psychiatry_PE_Jaundice,
                               op.Psychiatry_PE_Anemia,
                               op.Psychiatry_PE_Cyanosis,
                               op.Psychiatry_PE_Clubbing,
                               op.Psychiatry_PE_JVP,
                               op.Psychiatry_PE_LymphNodes,
                               op.Psychiatry_PE_Edema,
                               op.Psychiatry_PE_Respiratory,
                               op.Psychiatry_PE_Cardiovascular,
                               op.Psychiatry_PE_Gastro_Intestinal,
                               op.Psychiatry_PE_Observation,
                               op.Psychiatry_PE_Cranial_Nerves,
                               op.Psychiatry_PE_Limb_Strength,
                               op.Psychiatry_PE_Spasticity,
                               op.Psychiatry_PE_Position,
                               op.Psychiatry_PE_Vibration,
                               op.Psychiatry_PE_Stereognosis,
                               op.Psychiatry_PE_Pain,
                               op.Psychiatry_PE_Biceps,
                               op.Psychiatry_PE_Triceps,
                               op.Psychiatry_PE_Brachioradialis,
                               op.Psychiatry_PE_Quadriceps,
                               op.Psychiatry_PE_Patellar,
                               op.Psychiatry_PE_Achilles,
                               op.Psychiatry_PE_Extensor,
                               op.Psychiatry_PE_Frontal,
                               op.Psychiatry_PE_Finger,
                               op.Psychiatry_PE_Heel,
                               op.Psychiatry_PE_Movements,
                               op.Psychiatry_PE_Gait,
                               op.Psychiatry_PE_Neck_Rigidity,
                               op.Psychiatry_PE_Kerning_Sign,
                               op.Psychiatry_PE_Brudzinki_Sign,
                               op.Psychiatry_For_Summary,
                               op.Psychiatry_For_Diagnosis,
                               op.Psychiatry_For_AxisI,
                               op.Psychiatry_For_AxisIII,
                               op.Psychiatry_For_AxisII,
                               op.Psychiatry_For_AxisIV,
                               op.Psychiatry_For_AxisV,
                               op.Psychiatry_For_PredisposingFactors,
                               op.Psychiatry_For_PrecipitatingFactors,
                               op.Psychiatry_For_PrepetuatingFactors,
                               op.Psychiatry_For_Investigation,
                               op.Psychiatry_For_Medical,
                               op.Psychiatry_For_Psychological,
                               op.Psychiatry_Major_Issues,
                               op.Psychiatry_For_Strengths,
                               op.Psychiatry_For_Goals,
                               op.Psychiatry_For_Strategies,

                           }).ToList();
            return ((new JavaScriptSerializer()).Serialize(PatCase));
        }
        [WebMethod]
        public static string LoadSymtomps(int outPatID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var list = (
                 from s in db.Sysmtopms
                 where s.Out_Patient_ID == outPatID
                 select new { s.Symtom_ID, Symtom_Name = (DBClass.getField("select Datavalue_Description from ValueSet vs,DataValues dv where vs.ValueSet_ID=dv.ValueSet_ID and vs.ValueSet_Name='Symtoms' and dv.DataValue_Name='" + s.Symtom_ID + "'").ToString()), s.Duration, Days_Years_Months = db.GetDataValueName("Days_Years_Months", s.Days_Years_Months), s.Remarks }
                 ).ToList();

            return (new JavaScriptSerializer().Serialize(list));
        }
        public class SysmtopmsHistoryClass
        {
            public string Symtom_ID;
            public string Symtom_Name;
            public string Duration;
            public string Days_Years_Months;
            public DateTime Created_Time;

            public string Remarks;
            public string Status;


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
        public static string LoadSymtompsHistory(int PatID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            int Patien_No = DBClass.GetMRNOBy_PatientID(Convert.ToInt32(PatID));

            var InPatientlist = (
                 from s in db.Sysmtopms
                 join o in db.In_Patients
                 on s.In_Patient_ID equals o.In_Patient_ID
                 join p in db.Patients
                  on o.Patient_ID equals p.Patient_ID
                 where p.Patient_No == Patien_No
                 select new { s.Symtom_ID, Symtom_Name = (DBClass.getField("select Datavalue_Description from ValueSet vs,DataValues dv where                                            vs.ValueSet_ID=dv.ValueSet_ID and vs.ValueSet_Name='Symtoms' and dv.DataValue_Name='" + s.Symtom_ID + "'").ToString()), s.Duration, Days_Years_Months = db.GetDataValueName("Days_Years_Months", s.Days_Years_Months), s.Remarks }
                 ).ToList();


            var OutPatientlist = (
                from s in db.Sysmtopms
                join o in db.Out_Patients
                on s.Out_Patient_ID equals o.Out_Patient_ID
                join p in db.Patients
                 on o.Patient_ID equals p.Patient_ID
                where p.Patient_No == Patien_No
                select new { s.Symtom_ID, Symtom_Name = (DBClass.getField("select Datavalue_Description from ValueSet vs,DataValues dv where                                            vs.ValueSet_ID=dv.ValueSet_ID and vs.ValueSet_Name='Symtoms' and dv.DataValue_Name='" + s.Symtom_ID + "'").ToString()), s.Duration, Days_Years_Months = db.GetDataValueName("Days_Years_Months", s.Days_Years_Months), s.Remarks }
                ).ToList();


            List<SysmtopmsHistoryClass> list = new List<SysmtopmsHistoryClass>();
            foreach (var item in InPatientlist)
            {
                SysmtopmsHistoryClass obj = new SysmtopmsHistoryClass();

                obj.Symtom_ID = item.Symtom_ID;
                obj.Duration = item.Duration;
                obj.Symtom_Name = item.Symtom_Name;
                obj.Days_Years_Months = item.Days_Years_Months;
                obj.Remarks = item.Remarks;
                obj.Status = "InPatient";
                list.Add(obj);
            }

            foreach (var item in OutPatientlist)
            {
                SysmtopmsHistoryClass obj = new SysmtopmsHistoryClass();

                obj.Symtom_ID = item.Symtom_ID;
                obj.Duration = item.Duration;
                obj.Symtom_Name = item.Symtom_Name;
                obj.Days_Years_Months = item.Days_Years_Months;
                obj.Remarks = item.Remarks;
                obj.Status = "OutPatient";
                list.Add(obj);
            }
            return (new JavaScriptSerializer().Serialize(list));
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
        public static string GetRotations()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var dep = from dv in db.DataValues
                      join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                      where vs.ValueSet_Name == "Rotations"
                      select new { dv.DataValue_Name, dv.DataValue_Description };

            return (new JavaScriptSerializer()).Serialize(dep);
        }

        [WebMethod]
        public static string GetPatient_Category()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var dep = from dv in db.DataValues
                      join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                      where vs.ValueSet_Name == "Patient Type"
                      select new { dv.DataValue_Name, dv.DataValue_Description };

            return (new JavaScriptSerializer()).Serialize(dep);
        }

        [WebMethod]
        public static string GetPatient_CategoryByPat(Int32 PatID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var pat = from p in db.Patients
                      where p.Patient_ID == PatID
                      select new { p.Patient_Type };
            return (new JavaScriptSerializer()).Serialize(pat);
        }
        [WebMethod]
        public static string GetFollowNo(Int32 PatID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var count = (db.Patients.Where(v => v.Patient_No == Convert.ToInt32(PatID)).Where(p => p.Company_ID == AppConfig.Company_ID).Count());
            //lblFollowNo.InnerHtml = Follow.ToString();
            return (new JavaScriptSerializer()).Serialize(count);
        }
        public class VitalParameterClass
        {
            public int Out_Patient_ID;
            public string Pulse_Min;
            public string BP_mm_Hg;
            public string Weight_Kg;
            public string Height_Cm;
            public DateTime Created_Time;
            public string Respiration_Min;
            public string Temp_C;
            public string L_M_P;
            public string SPO2;
            public string Test_ID;
            public DateTime Receiving_date;
            public string RN_Special_Instruction;
            public string RN_Patient_General_Condition;
            public string Status;
            public string EDD { get; set; }
            public string BSR { get; set; }
            public string BMI { get; set; }
            public string MUAC { get; set; }
            public string OFC { get; set; }



        }
        [WebMethod]
        public static string LoadVitalParametersHistory(int PatientID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            int Patien_No = DBClass.GetMRNOBy_RgPatientID(Convert.ToInt32(PatientID));

            var Inpatientlist = (from op in db.In_Patients
                                 join p in db.Patients
                                on op.Patient_ID equals p.Patient_ID
                                 where p.Patient_No == Patien_No

                                 select new
                                 {
                                     op.Pulse_Min,
                                     op.BP_mm_Hg,
                                     op.Weight_Kg,
                                     op.Height_Cm,
                                     op.Respiration_Min,
                                     op.Temp_C,
                                     op.L_M_P,
                                     //op.sp,
                                     op.Receiving_date,
                                     op.RN_Special_Instruction,
                                     op.RN_Patient_General_Condition,
                                     op.Created_Time
                                 }).ToList();

            var outpatientlist = (from op in db.Out_Patients
                                  join p in db.Patients
                                 on op.Patient_ID equals p.Patient_ID
                                  join rp in db.Reg_patients
on p.Reg_PatId equals rp.pat_id
                                  where rp.Patient_No == Patien_No

                                  select new
                                  {
                                      op.Out_Patient_ID,
                                      op.pulse_Min,
                                      op.BP_mm_Hg,
                                      op.Weight_Kg,
                                      op.Height_Cm,
                                      op.Respiration_Min,
                                      op.Temp_C,
                                      op.L_M_P,
                                      op.spo2,
                                      op.BSR,
                                      op.EDD,
                                      op.BMI,
                                      op.MUAC,
                                      op.OFC,
                                      //op.Receiving_date,
                                      //op.RN_Special_Instruction,
                                      //op.RN_Patient_General_Condition,
                                      op.Created_Time
                                  }).ToList();
            List<VitalParameterClass> list = new List<VitalParameterClass>();
            foreach (var item in outpatientlist)
            {
                VitalParameterClass obj = new VitalParameterClass();
                obj.Pulse_Min = item.pulse_Min;
                obj.Out_Patient_ID = item.Out_Patient_ID;
                obj.BP_mm_Hg = item.BP_mm_Hg;
                obj.Weight_Kg = item.Weight_Kg;
                obj.Height_Cm = item.Height_Cm;
                obj.Respiration_Min = item.Respiration_Min;
                obj.Temp_C = item.Temp_C;
                obj.L_M_P = item.L_M_P;
                obj.SPO2 = item.spo2;
                obj.BMI = item.BMI;
                obj.MUAC = item.MUAC;
                obj.OFC = item.OFC;
                obj.Receiving_date = DateTime.Now;
                obj.RN_Special_Instruction = "";
                obj.RN_Patient_General_Condition = "";
                obj.Created_Time = Convert.ToDateTime(item.Created_Time);
                obj.BSR = (item.BSR != null) ? item.BSR : "";
                obj.EDD = (item.EDD != null) ? item.EDD : "";
                obj.BMI = (item.BMI != null) ? item.BMI : "";
                obj.Status = "OutPatient";

                list.Add(obj);
            }

            foreach (var item in Inpatientlist)
            {
                VitalParameterClass obj = new VitalParameterClass();
                obj.Pulse_Min = item.Pulse_Min;
                obj.BP_mm_Hg = item.BP_mm_Hg;
                obj.Weight_Kg = item.Weight_Kg;
                obj.Height_Cm = item.Height_Cm;
                obj.Respiration_Min = item.Respiration_Min;
                obj.Temp_C = item.Temp_C;
                obj.L_M_P = item.L_M_P;
                //obj.SPO2 = item.spo2;
                obj.Receiving_date = Convert.ToDateTime(item.Receiving_date);
                obj.RN_Special_Instruction = item.RN_Special_Instruction;
                obj.RN_Patient_General_Condition = item.RN_Patient_General_Condition;
                obj.Created_Time = Convert.ToDateTime(item.Created_Time);
                obj.Status = "InPatient";
                list.Add(obj);
            }
            return (new JavaScriptSerializer()).Serialize(list);
        }
        [WebMethod]
        public static string LoadVitalFromhistory(int opdid)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            var opd = (from op in db.Out_Patients
                       where op.Out_Patient_ID == opdid
                       select new
                       {
                           op.pulse_Min,
                           op.BP_mm_Hg,
                           op.Weight_Kg,
                           op.Height_Cm,
                           op.Respiration_Min,
                           op.Temp_C,
                           op.L_M_P,
                           op.spo2,
                           op.BSR,
                           op.EDD,
                           op.BMI,
                           op.MUAC,
                           op.OFC,
                           op.Created_Time,
                           op.HistoryOfPeresentIllness,
                           op.HistoryOfPastIllness,
                           op.HistoryOfFamily,
                           op.SocioEconomicHistory,
                           op.Birth_History,
                           op.Drug_History,
                           op.DevelopmentHistory,
                           op.VaccinationHistory,
                           op.NutritionHistory,
                           op.Personal_History,
                           op.ObstetricHistory,
                           op.AllergiesHistory,
                           op.TreatmentHistory,
                           //op.Created_Time,
                           op.GIT,
                           op.GYNAE,
                           op.URG,
                           op.RESP,
                           op.CNS,
                           CVS = op.CVS.Replace("null", " "),
                           op.ProvisionalDiagnosis,
                           op.txtRemarksHistory,
                           op.Reffer_No,
                           Reffer_To = db.GetDataValueName("Patient Main Category", op.Reffer_To),
                           op.txtInputBox1,
                           op.Local,
                           op.Mucculor,
                           op.Abdominal,
                           op.PA_Gynae,
                           op.PS_Gynae,
                           op.Uterus,
                           op.FX,
                           op.PS_Obs,
                           op.PV_Obs,
                           op.SFH,
                           op.LIE,
                           op.Presentation,
                           op.FHR,
                           op.Engagement

                       }).ToList();
            return (new JavaScriptSerializer()).Serialize(opd);
        }
        public class PatientHistoryClass
        {
            public string HistoryOfPeresentIllness;
            public int Out_Patient_Id;
            public string HistoryOfPastIllness;
            public string SocioEconomicHistory;
            public string Birth_History;
            public DateTime Created_Time;
            public string Reffer_No;
            public string Reffer_To;
            public string txtInputBox1;
            public string Local;
            public string Mucculor;
            public string GIT;
            public string GYNAE;
            public string URG;
            public string RESP;
            public string CNS;
            public string CVS;
            public string ProvisionalDiagnosis;
            public string txtRemarksHistory;
            public string HistoryOfFamily;
            public string Drug_History;
            public string Personal_History;
            public string ObstetricHistory;
            public string AllergiesHistory;
            public string TreatmentHistory;
            public string Status;
            public bool DRE { get; set; }
            public bool Proctoscopy { get; set; }
            public string Abdominal { get; set; }
            public string PAGynae { get; set; }
            public string PSGynae { get; set; }
            public string Uterus { get; set; }
            public string FX { get; set; }
            public string PSObs { get; set; }
            public string PVObs { get; set; }
            public string SFH { get; set; }
            public string LIE { get; set; }
            public string Presentation { get; set; }
            public string FHR { get; set; }
            public string Engagement { get; set; }
            public string DevelopmentHistory { get; set; }
            public string VaccinationHistory { get; set; }
            public string NutritionHistory { get; set; }
        }
        [WebMethod]
        public static string LoadHistoryTabHistory(int PatientID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            int Patien_No = DBClass.GetMRNOBy_RgPatientID(Convert.ToInt32(PatientID));

            var InPatCase = (from op in db.In_Patients
                             join p in db.Patients
                             on op.Patient_ID equals p.Patient_ID
                             where p.Patient_No == Patien_No

                             select new
                             {
                                 op.HistoryOfPeresentIllness,
                                 op.HistoryOfPastIllness,
                                 op.HistoryOfFamily,
                                 op.SocioEconomicHistory,
                                 op.Birth_History,
                                 op.Drug_History,
                                 op.Personal_History,
                                 op.ObstetricHistory,
                                 op.AllergiesHistory,
                                 op.TreatmentHistory,
                                 op.Created_Time,
                                 op.GIT,
                                 op.GYNAE,
                                 op.RESP,
                                 op.CNS,
                                 CVS = op.CVS.Replace("null", " "),
                                 op.ProvisionalDiagnosis,
                                 op.txtRemarksHistory,
                                 op.Reffer_No,
                                 Reffer_To = db.GetDataValueName("Patient Main Category", op.Reffer_To),
                                 op.txtInputBox1,
                                 op.Local,
                                 op.Mucculor
                             }).ToList();



            var OutPatCase = (from op in db.Out_Patients
                              join p in db.Patients
                             on op.Patient_ID equals p.Patient_ID
                              join rp in db.Reg_patients
on p.Reg_PatId equals rp.pat_id
                              where rp.Patient_No == Patien_No

                              select new
                              {
                                  op.Out_Patient_ID,
                                  op.HistoryOfPeresentIllness,
                                  op.HistoryOfPastIllness,
                                  op.HistoryOfFamily,
                                  op.SocioEconomicHistory,
                                  op.Birth_History,
                                  op.Drug_History,
                                  op.DevelopmentHistory,
                                  op.VaccinationHistory,
                                  op.NutritionHistory,
                                  op.Personal_History,
                                  op.ObstetricHistory,
                                  op.AllergiesHistory,
                                  op.TreatmentHistory,
                                  op.Created_Time,
                                  op.GIT,
                                  op.GYNAE,
                                  op.URG,
                                  op.RESP,
                                  op.CNS,
                                  CVS = op.CVS.Replace("null", " "),
                                  op.ProvisionalDiagnosis,
                                  op.txtRemarksHistory,
                                  op.Reffer_No,
                                  Reffer_To = db.GetDataValueName("Patient Main Category", op.Reffer_To),
                                  op.txtInputBox1,
                                  op.Local,
                                  op.Mucculor,
                                  op.Abdominal,
                                  op.PA_Gynae,
                                  op.PS_Gynae,
                                  op.Uterus,
                                  op.FX,
                                  op.PS_Obs,
                                  op.PV_Obs,
                                  op.SFH,
                                  op.LIE,
                                  op.Presentation,
                                  op.FHR,
                                  op.Engagement
                              }).ToList();



            List<PatientHistoryClass> list = new List<PatientHistoryClass>();
            foreach (var item in InPatCase)
            {
                PatientHistoryClass obj = new PatientHistoryClass();

                obj.CVS = item.CVS;
                obj.ProvisionalDiagnosis = item.ProvisionalDiagnosis;
                obj.txtRemarksHistory = item.txtRemarksHistory;
                obj.Reffer_No = item.Reffer_No;
                obj.txtInputBox1 = item.txtInputBox1;
                obj.Local = item.Local;
                obj.Mucculor = item.Mucculor;

                obj.ObstetricHistory = item.ObstetricHistory;
                obj.AllergiesHistory = item.AllergiesHistory;
                obj.TreatmentHistory = item.TreatmentHistory;
                obj.GIT = item.GIT;
                obj.GYNAE = item.GYNAE;

                obj.RESP = item.RESP;
                obj.CNS = item.CNS;
                obj.HistoryOfPeresentIllness = item.HistoryOfPeresentIllness;
                obj.HistoryOfPastIllness = item.HistoryOfPastIllness;
                obj.HistoryOfFamily = item.HistoryOfFamily;
                obj.SocioEconomicHistory = item.SocioEconomicHistory;
                obj.Birth_History = item.Birth_History;
                obj.Drug_History = item.Drug_History;
                obj.Personal_History = item.Personal_History;


                obj.Created_Time = Convert.ToDateTime(item.Created_Time);
                obj.Status = "InPatient";

                list.Add(obj);
            }

            foreach (var item in OutPatCase)
            {
                PatientHistoryClass obj = new PatientHistoryClass();

                obj.CVS = item.CVS;
                obj.Out_Patient_Id = item.Out_Patient_ID;
                obj.ProvisionalDiagnosis = item.ProvisionalDiagnosis;
                obj.txtRemarksHistory = item.txtRemarksHistory;
                obj.Reffer_No = item.Reffer_No;
                obj.txtInputBox1 = item.txtInputBox1;
                obj.Local = item.Local;
                obj.Mucculor = item.Mucculor;
                obj.DevelopmentHistory = item.DevelopmentHistory;
                obj.VaccinationHistory = item.VaccinationHistory;
                obj.NutritionHistory = item.NutritionHistory;

                obj.ObstetricHistory = item.ObstetricHistory;
                obj.AllergiesHistory = item.AllergiesHistory;
                obj.TreatmentHistory = item.TreatmentHistory;
                obj.GIT = item.GIT;
                obj.GYNAE = item.GYNAE;
                obj.URG = item.URG;
                obj.RESP = item.RESP;
                obj.CNS = item.CNS;
                obj.HistoryOfPeresentIllness = item.HistoryOfPeresentIllness;
                obj.HistoryOfPastIllness = item.HistoryOfPastIllness;
                obj.HistoryOfFamily = item.HistoryOfFamily;
                obj.SocioEconomicHistory = item.SocioEconomicHistory;
                obj.Birth_History = item.Birth_History;
                obj.Drug_History = item.Drug_History;
                obj.Personal_History = item.Personal_History;
                obj.Abdominal = item.Abdominal;
                obj.PAGynae = item.PA_Gynae;
                obj.PSGynae = item.PS_Gynae;
                obj.Uterus = item.Uterus;
                obj.FX = item.FX;
                obj.PSObs = item.PS_Obs;
                obj.PVObs = item.PV_Obs;
                obj.SFH = item.SFH;
                obj.LIE = item.LIE;
                obj.Presentation = item.Presentation;
                obj.FHR = item.FHR;
                obj.Engagement = item.Engagement;

                obj.Created_Time = Convert.ToDateTime(item.Created_Time);
                obj.Status = "OutPatient";

                list.Add(obj);
            }
            return ((new JavaScriptSerializer()).Serialize(list));
        }

        [WebMethod]
        public static ResultP PrintInPatientReceipt(int InPatientID, int OUTPatientID)
        {
            ResultP recieptP = new ResultP();
            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                var Data = (from tbl in db.Patients
                            join outP in db.Out_Patients on tbl.Patient_ID equals outP.Patient_ID
                            where tbl.Patient_ID == InPatientID

                            select new
                            {
                                tbl.Patient_No,
                                tbl.Full_Name,
                                tbl.Father_Name,
                                tbl.NIC,
                                tbl.Gender,
                                tbl.Mobile1,
                                Department = (from d in db.DataValues join v in db.ValueSets on d.ValueSet_ID equals v.ValueSet_ID where v.ValueSet_Name == "Patient Main Category" && d.DataValue_Name == tbl.Patient_Main_Category select d.DataValue_Description).FirstOrDefault(),
                                Patient_Type = (from d in db.DataValues join v in db.ValueSets on d.ValueSet_ID equals v.ValueSet_ID where v.ValueSet_Name == "Patient Type" && d.DataValue_Name == tbl.Patient_Type select d.DataValue_Description).FirstOrDefault(),
                                tbl.Age_years,


                                tbl.Permanent_Address,
                                tbl.Temporary_Address,
                                tbl.City,
                                tbl.Province,
                                //outP.Doctor_ID,
                                Doctor_ID = (from emp in db.HR_Employees where emp.Emp_ID == Convert.ToInt32(outP.Doctor_ID) select emp.Emp_Name).FirstOrDefault(),
                                /// pat.In_Patient_ID,
                                Referring_Doctor = (from i in db.In_Patients where i.Patient_ID == tbl.Patient_ID select i.Referring_Doctor).FirstOrDefault(),
                                ptientNO = (from i in db.Patients where i.Patient_ID == tbl.Patient_ID select i.Patient_No).FirstOrDefault(),
                                //var count = (db.Patients.Where(v => v.Patient_No == Convert.ToInt32(ptientNO)).ToList());

                                outP.Created_Time,
                                outP.Updated_Time,
                                outP.Special_Test,
                                outP.Area_Of_Interest,
                                outP.Advice,
                                Room_No = (from d in db.DataValues join v in db.ValueSets on d.ValueSet_ID equals v.ValueSet_ID where v.ValueSet_Name == "Patient Main Category" && d.DataValue_Name == tbl.Patient_Main_Category select d.Segment2).FirstOrDefault(),
                                Receipt_No = tbl.Patient_No,
                                Mode_Of_Presentation = (from d in db.DataValues join v in db.ValueSets on d.ValueSet_ID equals v.ValueSet_ID where v.ValueSet_Name == "Mode Of Registration" && d.DataValue_Name == tbl.Mode_Of_Registration select d.DataValue_Description).FirstOrDefault(),
                                //Printed_By = AppConfig.UserName,
                                Printed_By = (from us in db.aspnet_Users where us.UserId == outP.Created_By select us.UserName).FirstOrDefault(),
                                Pulse_Min = (from i in db.Out_Patients where i.Patient_ID == tbl.Patient_ID select i.pulse_Min).FirstOrDefault(),
                                Respiration_Min = (from i in db.Out_Patients where i.Patient_ID == tbl.Patient_ID select i.Respiration_Min).FirstOrDefault(),
                                Temp_C = (from i in db.Out_Patients where i.Patient_ID == tbl.Patient_ID select i.Temp_C).FirstOrDefault(),
                                BP = (from i in db.Out_Patients where i.Patient_ID == tbl.Patient_ID select i.BP_mm_Hg).FirstOrDefault(),
                                Weight = (from i in db.Out_Patients where i.Patient_ID == tbl.Patient_ID select i.Weight_Kg).FirstOrDefault(),
                                HistoryOfPastIllness = (from i in db.Out_Patients where i.Patient_ID == tbl.Patient_ID select i.HistoryOfPeresentIllness).FirstOrDefault(),
                                ObstetricHistory = (from i in db.Out_Patients where i.Patient_ID == tbl.Patient_ID select i.ObstetricHistory).FirstOrDefault(),
                                drug_History = (from i in db.Out_Patients where i.Patient_ID == tbl.Patient_ID select i.Drug_History).FirstOrDefault(),

                                Symtom = (from sp in db.Sysmtopms where sp.Out_Patient_ID == OUTPatientID select db.GetDataValueName("Symtoms", sp.Symtom_ID)).FirstOrDefault(),
                                SPdaysYear = (from sp in db.Sysmtopms where sp.Out_Patient_ID == OUTPatientID select db.GetDataValueName("Days_Years_Months", sp.Days_Years_Months)).FirstOrDefault(),
                                Duration = (from sp in db.Sysmtopms where sp.Out_Patient_ID == OUTPatientID select sp.Duration).FirstOrDefault(),
                                SPRemarks = (from sp in db.Sysmtopms where sp.Out_Patient_ID == OUTPatientID select sp.Remarks).FirstOrDefault(),
                                ReceiptCharges = tbl.Receipt_Amount,
                                TokenNo = (from t in db.Patients
                                           where t.Patient_Main_Category == tbl.Patient_Main_Category
                                           && t.Patient_No < Convert.ToInt32(tbl.Patient_No)
                                           && Convert.ToDateTime(t.Created_Time).Year == DateTime.Now.Date.Year
                                           && Convert.ToDateTime(t.Created_Time).Month == DateTime.Now.Date.Month
                                           && Convert.ToDateTime(t.Created_Time).Day == DateTime.Now.Date.Day
                                           select t).Count() + 1,
                                Provisional = (from i in db.Out_Patients where i.Patient_ID == tbl.Patient_ID select i.ProvisionalDiagnosis).FirstOrDefault(),

                                Follow_UpR = (from sp in db.Out_Patients where sp.Out_Patient_ID == OUTPatientID select db.GetDataValueName("FollowUp", sp.Follow_Up)).FirstOrDefault(),
                                FinalDiagnosis = (from i in db.Out_Patients where i.Patient_ID == tbl.Patient_ID select i.Final_Diagnosis).FirstOrDefault(),



                                FollowDate = (from i in db.Out_Patients where i.Patient_ID == tbl.Patient_ID && i.Out_Patient_ID == OUTPatientID && Convert.ToDateTime(i.Created_Time).Month == DateTime.Now.Month && Convert.ToDateTime(i.Created_Time).Year == DateTime.Now.Year && Convert.ToDateTime(i.Created_Time).Day == DateTime.Now.Day select i.Folllow_Date).FirstOrDefault(),



                            }

                    ).FirstOrDefault();
                if (Data != null)
                {
                    recieptP.MR_No = Data.Patient_No.ToString();
                    recieptP.Token_No = Data.TokenNo.ToString();

                    recieptP.Full_Name = Data.Full_Name;
                    recieptP.Father_Name = Data.Father_Name;
                    recieptP.Doctor_ID = Data.Doctor_ID;




                    recieptP.NIC = Data.NIC.ToString();

                    var Gender = Data.Gender.ToString();
                    if (Gender == "F")
                    {
                        recieptP.Gender = "Female";
                    }
                    else if (Gender == "M")
                    {
                        recieptP.Gender = "Male";
                    }
                    else
                    {
                        recieptP.Gender = "";
                    }
                    recieptP.ContectNo = Data.Mobile1.ToString();

                    recieptP.Department = Data.Department;

                    recieptP.Patient_Type = Data.Patient_Type;

                    recieptP.Age_years = Data.Age_years;

                    recieptP.Permanent_Address = Data.Permanent_Address.ToString();
                    recieptP.Temporary_Address = Data.Temporary_Address.ToString();
                    recieptP.Province = Data.Province.ToString();

                    recieptP.Referring_Doctor = Data.Referring_Doctor;
                    if (Data.Updated_Time != null)
                    {
                        recieptP.Created_Time = Convert.ToDateTime(Data.Updated_Time).ToString("MM-dd-yy hh:mm tt");
                    }
                    else
                        recieptP.Created_Time = Convert.ToDateTime(Data.Created_Time).ToString("MM-dd-yy hh:mm tt");
                    recieptP.RoomNo = Data.Room_No;
                    recieptP.ReceiptCharges = Data.ReceiptCharges.ToString();
                    recieptP.PrintedBy = Data.Printed_By;

                    recieptP.Prisentation = Data.Mode_Of_Presentation;
                    recieptP.Pulse_Min = Data.Pulse_Min;
                    recieptP.Respiration_Min = Data.Respiration_Min;
                    recieptP.Temp_C = Data.Temp_C;
                    recieptP.BP = Data.BP;
                    recieptP.Weight = Data.Weight;
                    var count = (db.Patients.Where(v => v.Patient_No == Convert.ToInt32(Data.ptientNO)).ToList());
                    var Follow = count.Count;
                    recieptP.follow = Follow;
                    recieptP.Follow_Up = Data.Follow_UpR;
                    recieptP.Final_Diagnosis = Data.FinalDiagnosis;
                    recieptP.Follow_Date = Convert.ToDateTime(Data.FollowDate).ToString("MM/dd/yy");
                    recieptP.ProvisionalD = Data.Provisional;
                    recieptP.Advice = Data.Advice;
                    recieptP.Special_Test = Data.Special_Test;
                    recieptP.Area_Of_Interest = Data.Area_Of_Interest;
                    recieptP.HistoryOfPastIllness = Data.HistoryOfPastIllness;
                    recieptP.ObstetricHistory = Data.ObstetricHistory;
                    recieptP.drug_History = Data.drug_History;
                    recieptP.Symptom = Data.Symtom;
                    recieptP.Dur = Data.Duration;
                    recieptP.DayMonth = Data.SPdaysYear;
                    recieptP.SpRemarks = Data.SPRemarks;
                }
            }

            return recieptP;

        }
        List<Med> mdddddcns;
        public class Med
        {
            public string Medicine_Name;

        }

        public class ResultP
        {


            public List<Med> Medicene;
            public string Advice;
            public string Follow_Up;
            public string Follow_Date;
            public string ProvisionalD;

            public string PrintedBy;
            public string Gender;
            public string ReceiptCharges;
            public string Full_Name;
            public string Father_Name;
            public string Birth_Date;
            public string NowDate;
            public string ContectNo;
            public string NIC;
            public string Blood_Group;
            public string Created_By;
            public string Token_No;
            public string Prisentation;
            public string RoomNo;
            public string ReceiptNo;
            public int follow;
            public string Pulse_Min;
            public string BP;
            public string Temp_C;
            public string Respiration_Min;
            public string Permanent_Address;
            public string MR_No;
            public string Printed_By;
            public string Patient_Type;
            public string Department;
            public string Age_years;
            public string Created_Time;
            public string Referring_Doctor;
            public string Province;
            public string Temporary_Address;
            public string Doctor_ID;
            public string Weight;
            public string Symptom;
            public string Dur;
            public string DayMonth;
            public string SpRemarks;
            public string HistoryOfPastIllness;
            public string ObstetricHistory;
            public string drug_History;
            public string Final_Diagnosis;
            public string Special_Test;
            public string Area_Of_Interest;
            //public string Advice;





        }

        public static string FollowUp { get; set; }

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
            public string TestID { get; set; }
            public string TestName { get; set; }
            public string SerialNo { get; set; }
            public string CategoryID { get; set; }
            public bool IsGroupCategory { get; set; }
            public string GroupName { get; set; }
            public string MainDepartmentName { get; set; }
        }

        public class TestGroupCategory
        {
            public string TestID { get; set; }
            public string TestName { get; set; }
            public string SerialNo { get; set; }
            public string CategoryID { get; set; }
            public bool IsGroupCategory { get; set; }
            public string GroupName { get; set; }
            public string MainDepartmentName { get; set; }
        }


        [WebMethod]
        public static string ShowCatagory(string name)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var testDetailst = (from t in db.Lab_Tests
                                where t.Test_Name == name.ToString()

                                select new
                                {
                                    t.Group_Category,
                                }

                ).FirstOrDefault();





            return (new JavaScriptSerializer()).Serialize(testDetailst);
        }

        public class TestDetailsForOPDrpt
        {
            public string Lab_Test_Detail_ID { get; set; }
            public DateTime Date { get; set; }
            public string Remark { get; set; }
            public string Lab_Test_ID { get; set; }
            public string Test_ID { get; set; }
            public string Test_Name { get; set; }
            public string Group_Department { get; set; }
            public string DepartmentName { get; set; }
            public string Group_Category { get; set; }
            public string GroupName { get; set; }
            public string Rotation_ID { get; set; }
            public string Rotation { get; set; }
            public string GroupCategory_ID { get; set; }
        }

        [WebMethod]
        public static string LoadTestrpt(int PatientID, int oUTID)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var testDetailst = (from lbtM in db.Laboratory_Tests
                                join lbtD in db.Lab_Test_Details
                                on lbtM.Lab_Test_ID equals lbtD.Lab_Test_ID
                                join outpat in db.Out_Patients
                                on lbtM.Patient_ID equals outpat.Out_Patient_ID

                                where outpat.Out_Patient_ID == oUTID && lbtM.Transaction_Type == "OutPatient"

                                select new
                                {
                                    lbtD.Lab_Test_Detail_ID,
                                    lbtD.Date,
                                    lbtD.Remark,
                                    lbtD.Catagory_ID,
                                    lbtM.Lab_Test_ID,
                                    lbtD.Test_ID,
                                    CatDepartmentName = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select db.GetDataValueName("Main Test Departments", t.Group_Category)).FirstOrDefault(),

                                    Test_Name = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Test_Name).FirstOrDefault(),

                                    Group_Department = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Group_Department).FirstOrDefault(),
                                    Group_Category = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Group_Category).FirstOrDefault(),
                                    DepartmentName = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select db.GetDataValueName("Main Test Departments", t.Main_Department)).FirstOrDefault(),
                                    Department_ID = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select t.Main_Department).FirstOrDefault(),

                                    GroupName = (from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select db.GetDataValueName("Test Groups", t.Group_Category)).FirstOrDefault(),
                                    Group_Name = db.GetDataValueName("Test Groups", lbtD.Catagory_ID),
                                    Rotation_ID = lbtD.Rotation_ID,
                                    Rotation = ((from t in db.Lab_Tests where t.Test_ID == lbtD.Test_ID select db.GetDataValueName("Main Test Departments", t.Main_Department)).FirstOrDefault()) == "X-Ray" ? db.GetDataValueName("Test XRay Rotations", lbtD.Rotation_ID) : db.GetDataValueName("Test CT Scan Rotations", lbtD.Rotation_ID),
                                    lbtD.Special_Tests,
                                    lbtD.Area_Of_Interest
                                }
                ).ToList();

            return (new JavaScriptSerializer()).Serialize(testDetailst);
        }

        [WebMethod]
        public static string GetBBDDLDetails(string SerialNo)
        {

            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var test = (from t in db.Lab_Tests
                        where t.Main_Department == "005" && t.Test_Name == SerialNo
                        select new { t.Test_ID, t.Test_Name, t.Group_Category, TestMainDepartmentName = db.GetDataValueName("Main Test Departments", t.Main_Department.ToString()).ToString(), GroupCategoryName = db.GetDataValueName("Test Groups", t.Group_Category.ToString()).ToString() }).ToList();
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
                                       select new { Test_ID = 0, Group_Category = dv.DataValue_Name, Test_Name = dv.DataValue_Description, TestMainDepartmentName = "Blood Bank", Main_Department = "005" }).ToList();
                return (new JavaScriptSerializer()).Serialize(GroupCategories);
            }

        }


        [WebMethod]
        public static string GetlabDetailByCategory(string test_id, string CategoryID)
        {
            string groupCategory = string.Empty;
            string testName = test_id;

            string[] testFullName = test_id.Split('|');
            if (testFullName.Length > 1)
            {
                testName = testFullName[0];
                groupCategory = DBClass.getField("select Datavalue_Name from Datavalues where valueset_ID = 70 and Datavalue_Description = '" + testFullName[1].Trim() + "'").ToString();
            }

            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var test = (from t in db.Lab_Tests
                        where t.Main_Department == CategoryID && t.Test_Name == testName && t.Group_Category == groupCategory
                        select new
                        {
                            t.Test_ID,
                            t.Rate, /*= DBClass.getField(""),t.Test_Name*/
                            Test_Name = test_id,
                            t.Group_Category,
                            TestMainDepartmentName = db.GetDataValueName("Main Test Departments", t.Main_Department.ToString()).ToString(),
                            GroupCategoryName = db.GetDataValueName("Test Groups", t.Group_Category.ToString()).ToString(),


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
                                       where vs.ValueSet_Name == "Test Groups" && dv.DataValue_Description == test_id
                                       select new
                                       {
                                           Test_ID = 0,
                                           Group_Category = dv.DataValue_Name,
                                           Test_Name = dv.DataValue_Description,
                                           TestMainDepartmentName = "Lab Test",
                                           Main_Department = "001",
                                           Rate = dv.Segment1,


                                       }).ToList();
                return (new JavaScriptSerializer()).Serialize(GroupCategories);

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
                        where t.Main_Department == maindpt && t.Test_Name == testName && t.Group_Category == groupCategory
                        select new
                        {
                            t.Test_ID,
                            t.Rate, /*= DBClass.getField(""),t.Test_Name*/
                            Test_Name = SerialNo,
                            t.Group_Category,
                            TestMainDepartmentName = db.GetDataValueName("Main Test Departments", t.Main_Department.ToString()).ToString(),
                            GroupCategoryName = db.GetDataValueName("Test Groups", t.Group_Category.ToString()).ToString(),


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


                                       }).ToList();
                return (new JavaScriptSerializer()).Serialize(GroupCategories);

            }
        }






        //////////////// Template Working /////////////////

        [WebMethod]
        public static string GetTemplateTest(int Templateid)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var dpt = (from dt in db.Doctor_Template_Masters
                       join dtm in db.Doctor_Template_Tests
                       on dt.Template_Id equals dtm.Template_Id

                       where dt.Template_Id == Templateid
                       select new
                       {
                           dtm.Department_id,
                           dtm.Test_Id,
                           dtm.Test_Name,
                           dtm.Rotation_Id,
                       }).ToList();

            return (new JavaScriptSerializer().Serialize(dpt));
        }

        [WebMethod]
        public static string GetTemplateMedicine(int Templateid)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var dpt = (from dt in db.Doctor_Template_Masters
                       join dtm in db.Doctor_Template_Medicines
                       on dt.Template_Id equals dtm.Template_Id
                       join mt in db.Medicines_Templates
                       on dtm.Medicine_id equals mt.Item_Code
                       where dt.Template_Id == Templateid
                       select new
                       {
                           mt.Medicine_Date,
                           mt.Medicine_Name,
                           mt.Dosage_From,
                           mt.Dosage_Qty,
                           mt.AttendingParamedical_Staff,
                           mt.Item_Code,
                           mt.Other_Instruction,
                           mt.Frequency,
                           mt.Injections,
                           mt.Oral,
                       }).ToList();

            return (new JavaScriptSerializer().Serialize(dpt));
        }
        [WebMethod]
        public static string GetTemplate()
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var dpt = (from d in db.Doctor_Template_Masters
                       join hr in db.HR_Employees
on d.Doctor_Id equals hr.Emp_ID
                       where hr.userid == Convert.ToString(AppConfig.UserID) && d.isActive == true
                       select new
                       {
                           d.Template_Id,
                           d.Template_Name
                       }).ToList();

            return (new JavaScriptSerializer().Serialize(dpt));
        }
        [WebMethod]
        public static string GetTemProcedure(string CheckTest)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var INV_Items = (from itm in db.Lab_Tests

                             where itm.Test_Name == CheckTest && itm.Main_Department == "006"
                             select new
                             {
                                 itm.Main_Department,
                                 itm.Test_ID,
                                 itm.Test_Name,
                                 Main_Department_Name = (db.GetDataValueName("Main Test Departments", itm.Main_Department))
                             }).ToList();
            return (new JavaScriptSerializer().Serialize(INV_Items));
        }

        //////////////// Template Working /////////////////
        [WebMethod]
        public static string Getdoctors()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from hr in db.HR_Employees
                              where hr.IsDoctor == true && hr.userid == Convert.ToString(AppConfig.UserID)

                              select new
                              {
                                  hr.Emp_ID,
                                  hr.Emp_Name
                              }).ToList();
                data = new JavaScriptSerializer().Serialize(result);
            }
            return data;
        }

        //[WebMethod]
        //public static string GetfilterClinic()
        //{
        //    string data = string.Empty;

        //    using (DataBaseDataContext db = new DataBaseDataContext())
        //    {
        //        var result = (from dv in db.DataValues
        //                      join ds in db.ValueSets
        //                      on dv.ValueSet_ID equals ds.ValueSet_ID
        //                      where ds.ValueSet_Name == "Filter Clinic"
        //                      select new
        //                      {
        //                          dv.DataValue_Name,
        //                          dv.DataValue_Description
        //                      }).ToList();
        //        data = new JavaScriptSerializer().Serialize(result);
        //    }
        //    return data;
        //}
        //Load Department Name
        [WebMethod]
        public static string GetAllDeparmtent()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Patient Main Category"
                              select new
                              {
                                  dv.DataValue_Name,
                                  dv.DataValue_Description
                              }).ToList();
                data = new JavaScriptSerializer().Serialize(result);
            }
            return data;
        }

        public class EyeDetail
        {
            public string EyeMainTypeID { get; set; }
            public string EyeSubTypeID { get; set; }
            public string RightEye { get; set; }
            public string LeftEye { get; set; }
        }
        public class EyeHeader
        {
            public string TransactionID { get; set; }
            public List<EyeDetail> EyeDetails { get; set; }
        }
        [WebMethod]
        public static string SaveEyeList(string data)
        {
            JavaScriptSerializer js = new JavaScriptSerializer();
            var Details = js.Deserialize<EyeHeader>(data);
            DataBaseDataContext db = new DataBaseDataContext();
            var PreviousEyeDetails = db.EyeDetails.Where(t => t.TransactionID == Convert.ToInt32(Details.TransactionID) && t.TransactionType == "OutPatient").ToList();
            db.EyeDetails.DeleteAllOnSubmit(PreviousEyeDetails);
            db.SubmitChanges();

            // Insert New

            foreach (EyeDetail eye in Details.EyeDetails)
            {
                db.EyeDetails.InsertOnSubmit(new PMS.EyeDetail() { TransactionID = Convert.ToInt32(Details.TransactionID), EyeMainTypeID = eye.EyeMainTypeID, EyeSubTypeID = eye.EyeSubTypeID, RightEye = eye.RightEye, LeftEye = eye.LeftEye, TransactionType = "OutPatient" });
            }
            db.SubmitChanges();

            return "";
        }

        [WebMethod]
        public static string GetEyeList(int id)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var EyeList = (from e in db.EyeDetails
                           where e.TransactionType == "OutPatient" && e.TransactionID == id
                           select new
                           {

                               e.EyeMainTypeID,
                               e.EyeSubTypeID,
                               e.RightEye,
                               e.LeftEye
                           }
                );

            return (new JavaScriptSerializer()).Serialize(EyeList);
        }
        [WebMethod]
        public static string GetEyeMainType()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var dep = from Eye in db.EyeMainTypes_Definitions
                      select new { DataValue_Name = Eye.MainTypeID, DataValue_Description = Eye.MainTypeName };

            return (new JavaScriptSerializer()).Serialize(dep);
        }
        [WebMethod]
        public static string GetEyeSubType(int MainTypeID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            var dep = from Eye in db.EyeSubTypes_Definitions
                      where Eye.MainTypeID == MainTypeID
                      select new { DataValue_Name = Eye.SubTypeID, DataValue_Description = Eye.SubTypeName, Eye.MainTypeID };

            return (new JavaScriptSerializer()).Serialize(dep);
        }
        [WebMethod]
        public static string LoadDoctor()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var doctor = (from emp in db.HR_Employees

                              where emp.Resign_Date == null && emp.IsDoctor == true
                              select new { emp.Emp_ID, emp.Emp_Name }).ToList();
                return (new JavaScriptSerializer()).Serialize(doctor);
            }
            return "";
        }
        [WebMethod]
        public static string LoadDoctor_bydep(string depart)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var doctor = (from emp in db.HR_Employees

                              where emp.Department == depart && emp.IsDoctor == true
                              select new { emp.Emp_ID, emp.Emp_Name }).ToList();
                return (new JavaScriptSerializer()).Serialize(doctor);
            }
            return "";
        }
        [WebMethod]
        public static string LoadDesignation(int DocID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var Designation = (from emp in db.HR_Employees

                                   where emp.Emp_ID == DocID && emp.Resign_Date == null && emp.IsDoctor == true
                                   select new { Emp_designatin = db.GetDataValueName("Designation", emp.Designation), }).FirstOrDefault();
                return (new JavaScriptSerializer()).Serialize(Designation);
            }
            return "";
        }

        [WebMethod]
        public static string GetAllServices(string searchText)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var itemDetail = db.spGetAllServices(searchText).ToList();
                return (new JavaScriptSerializer()).Serialize(itemDetail);
            }
        }
        [WebMethod]
        public static string GetAllTest(string CategoryID, string searchTexttest)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var itemDetail = db.sp_FillTestsByCategory(CategoryID, searchTexttest).ToList();
                return (new JavaScriptSerializer()).Serialize(itemDetail);
            }
        }


        [WebMethod]
        public static string GetEyeListHistory(int PatientID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            int Patien_No = DBClass.GetMRNOBy_PatientID(Convert.ToInt32(PatientID));

            var InPatEyeList = (from e in db.EyeDetails
                                join o in db.In_Patients
                                on e.TransactionID equals o.In_Patient_ID
                                join p in db.Patients
                               on o.Patient_ID equals p.Patient_ID
                                where p.Patient_No == Patien_No && e.TransactionType == "InPatient"
                                select new
                                {

                                    e.EyeMainTypeID,
                                    e.EyeSubTypeID,
                                    e.RightEye,
                                    e.LeftEye
                                }
                ).ToList();



            var OutPatEyeList = (from e in db.EyeDetails
                                 join o in db.Out_Patients
                                 on e.TransactionID equals o.Out_Patient_ID
                                 join p in db.Patients
                                on o.Patient_ID equals p.Patient_ID
                                 where p.Patient_No == Patien_No && e.TransactionType == "OutPatient"
                                 select new
                                 {

                                     e.EyeMainTypeID,
                                     e.EyeSubTypeID,
                                     e.RightEye,
                                     e.LeftEye
                                 }
               ).ToList();

            List<EyeDetailClass> list = new List<EyeDetailClass>();

            foreach (var item in OutPatEyeList)
            {
                EyeDetailClass obj = new EyeDetailClass();


                obj.EyeMainTypeID = item.EyeMainTypeID;
                obj.EyeSubTypeID = item.EyeSubTypeID;
                obj.LeftEye = item.LeftEye;
                obj.RightEye = item.RightEye;
                obj.Status = "OutPatient";
                list.Add(obj);
            }
            foreach (var item in InPatEyeList)
            {
                EyeDetailClass obj = new EyeDetailClass();


                obj.EyeMainTypeID = item.EyeMainTypeID;
                obj.EyeSubTypeID = item.EyeSubTypeID;
                obj.LeftEye = item.LeftEye;
                obj.RightEye = item.RightEye;
                obj.Status = "InPatient";
                list.Add(obj);
            }

            return (new JavaScriptSerializer()).Serialize(list);
        }


        public class EyeDetailClass
        {
            public string EyeMainTypeName;
            public string EyeSubTypeName;
            public string EyeMainTypeID;
            public string EyeSubTypeID;
            public DateTime Medicine_Date;
            public string LeftEye;
            public string RightEye;
            public string Status;
        }
        public class PatientVisitData
        {
            public int Patient_ID { get; set; }
            public int reg_ID { get; set; }
            public string btnsave { get; set; }
            public string btnsaveVital { get; set; }

            public bool Discharged { get; set; }
            public bool No_Medicine { get; set; }
            public bool No_LabTest { get; set; }

            public string Doctor_ID { get; set; }
            public string Follow_Up { get; set; }
            public string Proto { get; set; }
            public string Follow_Date { get; set; }

            public string pulse_Min { get; set; }
            public string L_M_P { get; set; }
            public string SPO2 { get; set; }
            public string BP_mm_Hg { get; set; }
            public string MUAC { get; set; }
            public string OFC { get; set; }
            public string Temp_C { get; set; }
            public string Respiration_Min { get; set; }
            public string Height_Cm { get; set; }
            public string Weight_Kg { get; set; }
            public string Refer_To_Hospital { get; set; }

            public string Reffer_To { get; set; }
            public string Reffer_doc { get; set; }

            public string Provisional_Diagnosis { get; set; }
            public string HistoryOfPeresentIllness { get; set; }
            public string HistoryOfFamily { get; set; }
            public string HistoryOfPastIllness { get; set; }

            public string CVS { get; set; }
            public string GIT { get; set; }
            public string RESP { get; set; }
            public string SocioEconomicHistory { get; set; }
            public string CNS { get; set; }
            public string GYNAE { get; set; }
            public string Mucculor { get; set; }
            public string Local { get; set; }

            public string Advice { get; set; }
            public string Special_Test { get; set; }
            public string Area_Of_Interest { get; set; }
            public string Birth_History { get; set; }
            public string Reffer_No { get; set; }

            public string Drug_History { get; set; }
            public string Personal_History { get; set; }
            public string txtRemarksHistory { get; set; }
            public string ObstetricHistory { get; set; }
            public string AllergiesHistory { get; set; }
            public string TreatmentHistory { get; set; }
            public string DevelopmentHistory { get; set; }
            public string VaccinationHistory { get; set; }
            public string NutritionHistory { get; set; }

            public bool chkPallor { get; set; }
            public bool chkJVP { get; set; }
            public bool chkaganoris { get; set; }
            public bool chkunconceed { get; set; }
            public bool chkjaundice { get; set; }
            public bool hydration { get; set; }
            public bool edema { get; set; }
            public bool chk1 { get; set; }
            public bool chk2 { get; set; }
            public bool chk3 { get; set; }
            public bool chk4 { get; set; }
            public bool chk5 { get; set; }

            // Text fields
            public string Other { get; set; }
            public string Designation { get; set; }
            public string FinalDiagnosis { get; set; }
            public string Final_Rec { get; set; }
            public string Administration { get; set; }

            // ENT Fields
            public string ENT_Throat_IDL { get; set; }
            public string ENT_Throat_Nose { get; set; }
            public string ENT_Ear_Right { get; set; }
            public string Ent_Ear_Left { get; set; }

            public string ComRightPos { get; set; }
            public string ComLeftPos { get; set; }
            public string ComRightNeg { get; set; }
            public string ComLeftNeg { get; set; }
            public string ComRightF { get; set; }
            public string ComLeftF { get; set; }
            public string ComRightFNeg { get; set; }
            public string ComLeftFNeg { get; set; }
            public string ComCentral { get; set; }
            public string ComLateralized { get; set; }
            public string ComPTA { get; set; }
            public string ComTympanometry { get; set; }

            // ENT Checkboxes
            public bool ENT_Rinnes_Right_PosNeg { get; set; }
            public bool ENT_Rinnes_Lft_PosNeg { get; set; }
            public bool ENT_Rinnes_Right_FalseNeg { get; set; }
            public bool ENT_Rinnes_Lft_FalseNeg { get; set; }
            public bool ENT_Webber_Central { get; set; }
            public bool ENT_Webber_Lateralized { get; set; }
            public bool ENT_Investigation_PTA { get; set; }
            public bool ENT_Investigation_Tympanometry { get; set; }
            public bool ENT_Rinnes_Right_Neg { get; set; }
            public bool ENT_Rinnes_Lft_Neg { get; set; }
            public bool ENT_Rinnes_Right_FNeg { get; set; }
            public bool ENT_Rinnes_Lft_FNeg { get; set; }

            // Informants & Referral
            public string txtInformant { get; set; }
            public string txtSourceOfReferral { get; set; }

            // Development & Milestones
            public bool chkNeckHolding { get; set; }
            public bool chkWalking { get; set; }
            public bool chkTalking { get; set; }
            public bool chkOthers { get; set; }
            public string txtMenarche { get; set; }
            public string txtMenstrual { get; set; }

            // Child/Adolescent Psych
            public string txtAttachmentSeparationfromParents { get; set; }
            public string txtHealth { get; set; }
            public bool chkNailBiting { get; set; }
            public bool chkTemperTantrums { get; set; }
            public bool chkBedWetting { get; set; }
            public string txtAcademics { get; set; }
            public string txtPeerRelationship { get; set; }
            public string txtBehaviour { get; set; }

            // Adult Psych & Social
            public string txtOccupationalHistory { get; set; }
            public string txtMaritalRelationshipSexualHistory { get; set; }
            public string txtSubstanceUse { get; set; }
            public string txtForensicUse { get; set; }
            public string txtRelationship { get; set; }
            public string txtLeisureActivities { get; set; }
            public string txtAttitudetoSelfandStandards { get; set; }
            public string txtPrevallingMood { get; set; }
            public string txtReactionPattrentoStress { get; set; }
            public string txtReligiousPracticesAttitute { get; set; }

            // Family Info
            public string txtFather { get; set; }
            public string txtMother { get; set; }
            public string txtSiblings { get; set; }
            public string txtHomeAtmosphererelationshipsocialclass { get; set; }
            public string txtFamilialIllness { get; set; }
            public string txtActualandapparentage { get; set; }
            public string txtRace { get; set; }
            public string txtTattoosbodypiercingandscars { get; set; }
            public string txtBodyHabitus { get; set; }
            public string txtDress { get; set; }
            public string txtHygiene { get; set; }
            public string txtPsychomotorActivity { get; set; }
            public string txtInvoluntarymovements { get; set; }
            public string txtDystoniaEPS { get; set; }
            public string txtTardivedyskinesia { get; set; }
            public string txtTics { get; set; }
            public string txtTremors { get; set; }
            public string txtAttentivenesstointerview { get; set; }
            public string txtEyeContact { get; set; }
            public string txtLevelofConsciousness { get; set; }
            public string txtRate { get; set; }
            public string txtRhythm { get; set; }
            public string txtVolume { get; set; }
            public string txtTone { get; set; }
            public string txtModulation { get; set; }
            public string txtDepressed { get; set; }
            public string txtElated { get; set; }
            public string txtIrritable { get; set; }
            public string txtLabile { get; set; }
            public string txtIncongruent { get; set; }
            public string txtbluntingflatteningapathy { get; set; }
            public string txtThinkingPremeditation { get; set; }
            public string txtPlans { get; set; }
            public string txtNextPlan { get; set; }
            public string txtActions { get; set; }
            public string txtPreservative { get; set; }
            public string txtLoosAssociation { get; set; }
            public string txtTangentiaility { get; set; }
            public string txtCircumstantiality { get; set; }
            public string txtFlightofIdeas { get; set; }
            public string txtThoughtInsertion { get; set; }
            public string txtThoughtWithdrawal { get; set; }
            public string txtThoughBroadcasting { get; set; }
            public string txtThoughControl { get; set; }
            public string txtDellusion { get; set; }
            public string txtovervaluedideas { get; set; }
            public string txtDepresonalization { get; set; }
            public string txtDerealization { get; set; }
            public string txtthrougObsession { get; set; }
            public string txtthrougPhobies { get; set; }
            public string txtthrougHomocidialIdeas { get; set; }
            public string txtillusion { get; set; }
            public string txtHallucinationAuditoryVisualOlfactoryGustatoryTactile { get; set; }
            public string txtorientationtime { get; set; }
            public string txtplace { get; set; }
            public string txtperson { get; set; }
            public string txtAttentionConcentrationSerial7Test { get; set; }
            public string txtOrDaysOfWeekReverseOrder { get; set; }
            public string txtImmediatememory { get; set; }
            public string txtshorttermrecentevents { get; set; }
            public string txtadressrecallafter2minutes { get; set; }
            public string txtlongtermremoteevents { get; set; }
            public string txtadressrecallafter5minues { get; set; }
            public string txtgeneralknowledgequestion { get; set; }
            public string txtsimplearthemeticcalculation { get; set; }
            public string txtabstrationconcertethinking { get; set; }
            public string txtinsight { get; set; }
            public string DermaFace { get; set; }
            public string DermaNeck { get; set; }
            public string DermaTrunk { get; set; }
            public string DermaUpperLimb { get; set; }
            public string DermaLowerLimb { get; set; }
            public string DermaFlexures { get; set; }
            public string DermaGenitalias { get; set; }
            public string DermaHair { get; set; }
            public string DermaNail { get; set; }
            public string DermaMucousMembrane { get; set; }
            public string DermaEyes { get; set; }
            public string DermaEars { get; set; }
            public string DermaNose { get; set; }
            public string DermaLips { get; set; }
            public string Out_Patient_ID { get; set; }

            public string Interior_Right { get; set; }
            public string Interior_Left { get; set; }
            public string Posterior_Right { get; set; }
            public string Posterior_Left { get; set; }

            public string PE_Pluse { get; set; }
            public string PE_BP { get; set; }
            public string PE_Temperature { get; set; }
            public string PE_Weight { get; set; }
            public string PE_RespiratoryRate { get; set; }
            public string PE_Jaundice { get; set; }
            public string PE_Anemia { get; set; }
            public string PE_Cyanosis { get; set; }
            public string PE_Clubbing { get; set; }
            public string PE_JVP { get; set; }
            public string PE_LymphNodes { get; set; }
            public string PE_Edema { get; set; }
            public string PE_Respiratory { get; set; }
            public string PE_Cardiovascular { get; set; }
            public string PE_Gastro_Intestinal { get; set; }
            public string PE_Observation { get; set; }
            public string PE_Cranial_Nerves { get; set; }
            public string PE_Limb_Strength { get; set; }
            public string PE_Spasticity { get; set; }
            public string PE_Position { get; set; }
            public string PE_Vibration { get; set; }
            public string PE_Stereognosis { get; set; }
            public string PE_Pain { get; set; }
            public string PE_Biceps { get; set; }
            public string PE_Triceps { get; set; }
            public string PE_Brachioradialis { get; set; }
            public string PE_Quadriceps { get; set; }
            public string PE_Patellar { get; set; }
            public string PE_Achilles { get; set; }
            public string PE_Extensor { get; set; }
            public string PE_Frontal { get; set; }
            public string PE_Finger { get; set; }
            public string PE_Heel { get; set; }
            public string PE_Movements { get; set; }
            public string PE_Gait { get; set; }

            public string HBM_Problem { get; set; }
            public string HBM_Caused { get; set; }
            public string HBM_Started { get; set; }
            public string HBM_Course { get; set; }
            public string HBM_Treatment { get; set; }
            public string HBM_Effects { get; set; }

            public bool PE_Neck_Rigidity { get; set; }
            public bool PE_Kerning_Sign { get; set; }
            public bool PE_Brudzinki_Sign { get; set; }

            public string For_Summary { get; set; }
            public string For_Diagnosis { get; set; }
            public string For_AxisI { get; set; }
            public string For_AxisII { get; set; }
            public string For_AxisIII { get; set; }
            public string For_AxisIV { get; set; }
            public string For_AxisV { get; set; }
            public string For_PredisposingFactors { get; set; }
            public string For_PrecipitatingFactors { get; set; }
            public string For_PrepetuatingFactors { get; set; }
            public string For_Investigation { get; set; }
            public string For_Medical { get; set; }
            public string For_Psychological { get; set; }
            public string For_Major_Issues { get; set; }
            public string For_Strengths { get; set; }
            public string For_Goals { get; set; }
            public string For_Strategies { get; set; }

            public string Heptomology { get; set; }
            public string Splenomegaly { get; set; }

            public string txtPeads_weight { get; set; }
            public string txtPeads_Length { get; set; }
            public string txtPeads_HC { get; set; }
            public string txtPeads_General_Appearance { get; set; }
            public bool chkPeads_Cyanosis { get; set; }
            public bool chkPeads_Jaundice { get; set; }
            public bool chkPeads_Lethargy { get; set; }
            public bool chkPeads_Rash { get; set; }
            public string txtPeads_Others { get; set; }
            public bool chkPeads_Caput { get; set; }
            public bool chkPeads_Cephalhematoma { get; set; }
            public bool rdbPeads_Anterioropen { get; set; }
            public bool rdbPeads_AnteriorClose { get; set; }
            public bool chkPeads_Dextrocardia { get; set; }
            public bool chkPeads_Bulging { get; set; }
            public bool chkPeads_Murmur { get; set; }
            public string txtPeads_HeartSound { get; set; }
            public bool chkPeads_Nasal { get; set; }
            public bool chkPeads_Recessions { get; set; }
            public string txtPeads_AddedSounds { get; set; }
            public bool rdbPeads_Flat { get; set; }
            public bool rdbPeads_Distended { get; set; }
            public bool rdbPeads_Scaphoid { get; set; }
            public bool chkPeads_Liver { get; set; }
            public bool chkPeads_Spleen { get; set; }
            public string txtPeads_GITOthers { get; set; }
            public bool chkPeads_Sucking { get; set; }
            public bool chkPeads_Rooting { get; set; }
            public bool chkPeads_Moro { get; set; }
            public string txtPeads_CNSOthers { get; set; }
            public bool chkPeads_FullTerm { get; set; }
            public bool chkPeads_PreTerm { get; set; }
            public string txtPeads_DateOfDelivery { get; set; }
            public string txtPeads_TimeOfDelivery { get; set; }
            public bool rdbPeads_Booked { get; set; }
            public bool rdbPeads_UnBooked { get; set; }
            public bool chkPeads_DAIHandling { get; set; }
            public bool chkPeads_ANTURash { get; set; }
            public bool chkPeads_PIH { get; set; }
            public bool chkPeads_GDM { get; set; }
            public bool chkPeads_Vacinated { get; set; }
            public string txtPeads_ANTOthers { get; set; }
            public bool rdbPeads_SVD { get; set; }
            public bool rdbPeads_LSCS { get; set; }
            public bool rdbPeads_Emergency { get; set; }
            public bool rdbPeads_Elective { get; set; }
            public string txtPeads_PlaceOfDelivery { get; set; }
            public string txtPeads_IndicationForLSCS { get; set; }
            public bool chkPeads_Resuscitation { get; set; }
            public string txtPeads_NatalOthers { get; set; }
            public bool chkPeads_Moaning { get; set; }
            public bool chkPeads_RespDistress { get; set; }
            public bool chkPeads_PostNATALCyanosis { get; set; }
            public bool chkPeads_Fits { get; set; }
            public bool chkPeads_ReluctanceToFeed { get; set; }
            public string txtPeads_PostNatalOthers { get; set; }
            public string Edd { get; set; }
            public string Bsr { get; set; }
            public string Bmi { get; set; }
            public string URG { get; set; }
            public bool chkdre { get; set; }
            public bool chkProctoscopy { get; set; }
            public string Abdominal { get; set; }
            public string Pa_gynae { get; set; }
            public string ps_gynae { get; set; }
            public string uterus { get; set; }
            public string ps_obs { get; set; }
            public string pv_obs { get; set; }
            public string fx { get; set; }
            public string sfh { get; set; }
            public string lie { get; set; }
            public string presentation { get; set; }
            public string fhr { get; set; }
            public string engagement { get; set; }
            public string Peads_apgerScore1min { get; set; }
            public string Peads_apgerScore5min { get; set; }
        }
        public class OutPatientEyeInfo
        {
            public string Info_Type { get; set; }
            public string Right_Eye { get; set; }
            public string Left_Eye { get; set; }
            public int Out_Patient_ID { get; set; }
            public int Patient_ID { get; set; }
        }
    }

    }
