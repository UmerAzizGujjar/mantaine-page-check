using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Services;
using System.Web.Script.Serialization;
using System.Text;
using System.Data;
using Telerik.Web;

namespace PMS
{
    public partial class BillingProcess : System.Web.UI.Page
    {
        private static string RptTime;
        protected void Page_Load(object sender, EventArgs e)
        {
            BindingDropDown();
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

     
        [WebMethod]
        public static string GetGLAccounts()
        {
            string result = string.Empty;
            DataBaseDataContext db = new DataBaseDataContext();
            var itemsList = (from i in db.GL_Accounts where i.Levels == 4 && (i.Bank == true || i.Cash == true) select new { i.Account_ID, name = i.Account_Code.ToString() + '-' + i.Account_Name }).ToList();
            if (itemsList != null)
            {
                result = (new JavaScriptSerializer()).Serialize(itemsList);
            }
            return result;
            // db.GL_Accounts.Where(x => x.Cash == true || x.Bank == true).ToList();
        }
        [WebMethod]
        public static string GetItemCodes(int Pat_id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var pat_ids = (from p in db.Reg_patients join vs in db.Out_Patients on p.pat_id equals vs.Reg_PatId where vs.Reg_PatId == Convert.ToInt32(Pat_id) select vs.Out_Patient_ID).FirstOrDefault();
            var itemCodes = (from op in db.Reg_patients
                             join ip in db.InPatientServices on op.pat_id equals ip.PatientId
                             where ip.Ou_Patient_Id == Convert.ToString(pat_ids)
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
                             where ip.PatientId == pat_ids
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
                SearchSql = "SELECT pat_id,isnull(mr_no_sequence,'')Patient_No,isnull(Full_Name,'')Full_Name,isnull(NIC,'')NIC,isnull(Mobile1,'') ContactNo,isnull(Father_Name,'')Father_Name FROM reg_patient where(1=1) and Patient_No<>0 and Patient_No is not null and isnull(isCancel,0)!=1 and (LTRIM(RTRIM(patient_no)) like '%" + SearchString.Trim() + "%' or  LTRIM(RTRIM(full_name)) like '%" + SearchString.Trim() + "%' or LTRIM(RTRIM(mobile1))  like '%" + SearchString.Trim() + "%' or LTRIM(RTRIM(nic))  like '%" + SearchString.Trim() + "%') order by pat_id desc";

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
            public DateTime DOB;

            public string Mobile;
            public string Address;

            public string Mr_No { get; set; }

            public string MaritalStatus { get; set; }

            public string FatherName { get; set; }

            public string Relation { get; set; }

            public string CNIC { get; set; }


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
                pts.DOB = Convert.ToDateTime(pat.DOB);
                pts.Age = pat.Age_years.ToString();
                pts.MaritalStatus = pat.Martial_Status;
                //pt.Mr_No = Convert.ToString(pat.Patient_No);
                pts.Mr_No = Convert.ToString(pat.mr_no_sequence);
                pts.Address = pat.Permanent_Address;
                pts.Mobile = pat.Mobile1;
                pts.CNIC = pat.NIC;
                pts.Gender = pat.Gender;


                pts.Reg_PatientID = Reg_Patient_ID;
                return pts;
            }


            return pts;
        }
        [WebMethod]
        public static string SavePatientDetail(string Full_Name, string RelationType, string Relation, string Gender, string Mobile, string Date_Of_Birth, string CNIC, string Address, string PatientID, string martail_status, string Age)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            Reg_patient pat = null;
            if (!string.IsNullOrEmpty(PatientID) && PatientID != "0" && PatientID != "(New)")
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
                    pat.DOB = Convert.ToDateTime(Date_Of_Birth);
                    pat.NIC = CNIC;
                    pat.Permanent_Address = Address;
                    pat.Martial_Status = martail_status;
                    //pat.mr_no_sequence = db.GetSequentialMrNo();
                    pat.walkin = true;




                    db.SubmitChanges();
                }
            }
            else
            {
                pat = new Reg_patient();
                pat.Patient_No = DBClass.getMaxEntry_No("Reg_patient", "Patient_No");
                //pat.Mr_No_seq = db.GetSequentialMrNo();
                pat.Full_Name = Full_Name;
                //pat.RelationType = RelationType;
                pat.Father_Name = Relation;
                pat.Relation_prefix = RelationType;
                pat.Gender = Gender;
                pat.Mobile1 = Mobile;
                pat.Age_years = Age;
                pat.DOB = Convert.ToDateTime(Date_Of_Birth);
                pat.NIC = CNIC;
                pat.Permanent_Address = Address;
                pat.Created_time = DateTime.Now;
                pat.Created_by = AppConfig.UserID;
                pat.iscancel = false;
                pat.Martial_Status = martail_status;
                pat.mr_no_sequence = db.GetSequentialMrNo();
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
                               where opat.Patient_ID == p.Patient_ID && p.Reg_PatId == Convert.ToInt32(PatientID) && (lbtD.IsBilled == null) && lbtM.Transaction_Type == "OutPatient"

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
                                   GroupName = db.GetDataValueName("Test Groups", lbTDdef.Group_Category),
                                   ParentTrans_ID = lbtD.Lab_Test_Detail_ID,
                                   ParentTrans_Type = "Test",
                                   lbtD.Dept_ID,

                                   Rate = (lbTDdef.Rate == 0) ? Convert.ToDecimal(DBClass.getField("select dbo.getTestRate('" + p.Patient_Type + "', " + lbTDdef.Test_ID + ", " + p.Patient_ID + ")")) : lbTDdef.Rate

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
                                         && lbtM.Transaction_Type == "OutPatient"
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
                                             lbtD.Dept_ID
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


                    listRecommendedTests.Add(RecommendedService);
                }
            }


            return (new JavaScriptSerializer()).Serialize(listRecommendedTests);
        }

        [WebMethod]
        public static string fetchServices(int itemId)
        {
            string result = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.sp_fetch_Services(itemId).ToList();
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
                         select p.Patient_No
                          ).FirstOrDefault();

            var testDetails = (from lbtM in db.Laboratory_Tests
                               join lbtD in db.Lab_Test_Details
                               on lbtM.Lab_Test_ID equals lbtD.Lab_Test_ID
                               join opat in db.In_Patients
                               on lbtM.Patient_ID equals opat.In_Patient_ID
                               join lbTDdef in db.Lab_Tests
                               on lbtD.Test_ID equals lbTDdef.Test_ID
                               join p in db.Reg_patients
                               on opat.Patient_ID equals p.pat_id
                               where p.Patient_No == Convert.ToInt32(PatNo) && (lbtD.IsBilled == null || lbtD.IsBilled == false)
                                && lbtM.Transaction_Type == "InPatient" && (opat.Discharge == false || opat.Discharge == null)
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
                                   Rate = (lbTDdef.Rate == 0) ? Convert.ToDecimal(DBClass.getField("select dbo.getTestRate('" + opat.Patient_Discount_Type + "', " + lbTDdef.Test_ID + ", " + p.pat_id + ")")) : lbTDdef.Rate



                               }

                ).ToList();

            // Fetching Grouped Categories....

            var testDetailsGroupswise = (from lbtM in db.Laboratory_Tests
                                         join lbtD in db.Lab_Test_Details
                                         on lbtM.Lab_Test_ID equals lbtD.Lab_Test_ID
                                         join opat in db.In_Patients
                                         on lbtM.Patient_ID equals opat.In_Patient_ID
                                         join p in db.Reg_patients
                                          on opat.Patient_ID equals p.pat_id
                                         where opat.Patient_ID == p.pat_id && lbtD.Test_ID == 0 && p.Patient_No == Convert.ToInt32(PatNo) && (lbtD.IsBilled == null || lbtD.IsBilled == false) && lbtM.Transaction_Type == "InPatient"
                                         && (opat.Discharge == false || opat.Discharge == null)
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
                                             ParentTrans_Type = "Test Group Category"
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
                    RecommendedService.Amount = (group.Rate == null) ? 0 : Convert.ToDecimal(group.Rate);


                    listRecommendedTests.Add(RecommendedService);
                }
            }
            return (new JavaScriptSerializer()).Serialize(listRecommendedTests);
        }


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
                                   Rate = (lbTDdef.Rate == 0) ? Convert.ToDecimal(DBClass.getField("select dbo.getTestRate('" + opat.Patient_Discount_Type + "', " + lbTDdef.Test_ID + ", " + p.pat_id + ")")) : lbTDdef.Rate



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
                                             ParentTrans_Type = "Test Group Category"
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
                    RecommendedService.Amount = (group.Rate == null) ? 0 : Convert.ToDecimal(group.Rate);


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


            return (new JavaScriptSerializer()).Serialize(SaveBill(Parameters));
        }



        public static string SaveBill(string Parameters)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            JavaScriptSerializer JSS = new JavaScriptSerializer();
            var data = JSS.Deserialize<Billings>(Parameters);

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
                newBill = db.Ar_Billings.Where(b => b.Bill_ID == data.Bill_ID).FirstOrDefault();
                newBill.Updated_By = AppConfig.UserID;
                newBill.Updation_Date = DateTime.Now;
            }

            newBill.Patient_ID = data.Patient_ID;
            newBill.Opd_Id = data.Opd_id;
            newBill.Bill_Date = DateTime.Now;
            newBill.Remarks = data.Remarks;
            newBill.Discount_Percentage = data.Discount_Percentage;
            newBill.Discount_Amount = data.Discount_Amount;
            newBill.Total_Amount = data.TotalPayable;
            newBill.Net_Amount = data.Net_Amount;
            newBill.Received_Amount = data.Received_Amount;
            newBill.Balance_Amount = data.Balance_Amount;
            newBill.Charge_Policy = data.ChargePolicy;
            newBill.Referred_By = data.referred_by_doctor;
            newBill.Casher = data.Casher;

            var patient_no = DBClass.getField("select Patient_No from Reg_patient where pat_id=" + data.Patient_ID);
            var inpatient_ID = db.In_Patients.Where(m => m.Patient_ID.Equals(data.Patient_ID)).Select(m => m.In_Patient_ID).ToList();
            var ipdid = DBClass.getField("select In_Patient_ID from In_Patient where Patient_ID=" + data.Patient_ID + "order by Created_Time desc");

            if (ipdid != "There is no row at position 0.")
            {
                newBill.In_Patient_ID = Convert.ToInt32(ipdid);
            }
            else
            {
                newBill.In_Patient_ID = 0;
            }


            // Insert or Upate Bill Header

            if (data.Bill_ID == 0)
            {
                db.Ar_Billings.InsertOnSubmit(newBill);
                db.SubmitChanges();
            }


            List<Ar_Billing_Detail> ListOfDetails = new List<Ar_Billing_Detail>();
            List<Ar_Billing_Detail> ListOfDetails_Previous = db.Ar_Billing_Details.Where(b => b.Bill_ID == data.Bill_ID).ToList();

            // Inserting or Updating Bill Details
            decimal sum = 0;
            decimal sum_ultra = 0;
            decimal sum_Xray = 0;
            decimal sum_CTscan = 0;
            decimal sum_Blood = 0;
            decimal sum_Item = 0;
            decimal sum_Procedure = 0;
            decimal sum_Package = 0;
            foreach (BillingProcessDetails dtls in data.Details)
            {
                Ar_Billing_Detail newBillDetails = new Ar_Billing_Detail();

                newBillDetails.Bill_ID = newBill.Bill_ID;
                newBillDetails.ParentTrans_ID = dtls.ParentTrans_ID;
                newBillDetails.ParentTrans_Name = dtls.ParentTrans_Name;
                newBillDetails.ParentTrans_Type = dtls.ParentTrans_Type;
                newBillDetails.Item_ID = dtls.ItemID;
                newBillDetails.Item_Name = dtls.ItemName;
                newBillDetails.Item_Type = dtls.ItemType;
                newBillDetails.RecommendedByDoctor = dtls.RecommendedByDoctor;
                newBillDetails.Amount = dtls.Amount;
                newBillDetails.Discount_Percentage = dtls.DisPer;
                newBillDetails.Discount_Amount = dtls.DisAmt;
                newBillDetails.Net_Amount = (dtls.Net_Amount);
                newBillDetails.Qty = dtls.Qty;
                newBillDetails.Remarks = dtls.Remarks;
                newBillDetails.Doctor_Share = dtls.DocShare;
                newBillDetails.Hospital_Share = dtls.HosShare;
                newBillDetails.Doctor_id = dtls.Doctor_Id;
                newBillDetails.Category_ID = dtls.CategoryID;
                newBillDetails.Test_Main_Department = dtls.MainDepartment;
                newBillDetails.Service_Date = DateTime.Now;
                if (dtls.MainDepartment == "001")
                {
                    sum = Convert.ToDecimal(dtls.Consumed_Lab);
                }
                if (dtls.MainDepartment == "002")
                {
                    sum_ultra = Convert.ToDecimal(dtls.Consumed_Ultra_Sound);
                }
                if (dtls.MainDepartment == "003")
                {
                    sum_Xray = Convert.ToDecimal(dtls.Consumed_Xray);
                }
                if (dtls.MainDepartment == "004")
                {
                    sum_CTscan = Convert.ToDecimal(dtls.Consumed_Scan);
                }
                if (dtls.MainDepartment == "005")
                {
                    sum_Blood = Convert.ToDecimal(dtls.Consumed_Blood);
                }
                if (dtls.Consumed_Procedure != 0)
                {
                    sum_Procedure = Convert.ToDecimal(dtls.Consumed_Procedure);
                }


                else if (dtls.ItemType == "Item" || dtls.ItemType == "Service")
                {
                    if (dtls.ParentTrans_Type == "Package")
                    {
                        sum_Package = Convert.ToDecimal(dtls.Consumed_Package);
                    }
                    else
                    {
                        sum_Item = Convert.ToDecimal(dtls.Consumed_Item);
                    }
                }
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

            List<AR_Billing_Detail_Doctor_Share> ListOfshare = new List<AR_Billing_Detail_Doctor_Share>();
            foreach (DoctorDistributionList doc in data.Share)
            {
                AR_Billing_Detail_Doctor_Share share = new AR_Billing_Detail_Doctor_Share();
                share.Bill_ID = newBill.Bill_ID;
                share.Emp_ID = doc.Doc_ID;
                share.Share_type = doc.Share_type;
                share.Amount = doc.Doc_Amount;
                ListOfshare.Add(share);
            }

            #region "Edit"

            if (data.Bill_ID != 0)
            {
                foreach (var newItem in ListOfDetails)
                {
                    foreach (var PreviousItem in ListOfDetails_Previous)
                    {
                        if (newItem.Item_ID == PreviousItem.Item_ID)
                        {
                            newItem.ParentTrans_ID = PreviousItem.ParentTrans_ID;
                        }
                    }
                }

                if (ListOfDetails_Previous.Count > 0)
                {
                    // Deleting Previous Details...

                    db.Ar_Billing_Details.DeleteAllOnSubmit(ListOfDetails_Previous);
                    var deletedTests = (from old in ListOfDetails_Previous
                                        where !(from newRcd in ListOfDetails select newRcd.ParentTrans_ID).Contains(old.ParentTrans_ID)
                                        && old.Item_Type == "Test"
                                        select old.ParentTrans_ID).ToList();
                    if (deletedTests != null)
                    {
                        foreach (var item in deletedTests)
                        {
                            MarkTestAsExcludedFromPayment((int)item);
                            MarkTestAsUnBilled((int)item);
                        }
                    }
                }

                #region "Entry of newly entered group tests from front desk coutner in databse."

                // Entry of newly entered group tests from front desk coutner in databse.

                var newGroups = (from t in ListOfDetails where t.Item_Type == "Test" && t.RecommendedByDoctor == false && t.ParentTrans_Type == "Test Group Category" && t.ParentTrans_ID == 0 select t).ToList();

                var distinctCategories = newGroups.Select(t => t.Category_ID).Distinct().ToList();

                int typesOfGroups = distinctCategories.Count();

                string[] CategoryIDs = new string[typesOfGroups];

                int counter = 0;

                foreach (var item in distinctCategories)
                {
                    CategoryIDs[counter] = item;
                    counter++;
                }

                for (int i = 0; i < CategoryIDs.Length; i++)
                {
                    var Category = newGroups.Where(c => c.Category_ID == CategoryIDs[i]).ToList();

                    // Entry with 0 values for inserting group...

                    Laboratory_Test grpHeader = new Laboratory_Test();

                    grpHeader.Patient_ID = Convert.ToInt32(ListOfDetails[0].Bill_ID);
                    grpHeader.Transaction_Type = "Front Desk";
                    db.Laboratory_Tests.InsertOnSubmit(grpHeader);
                    db.SubmitChanges();

                    Lab_Test_Detail grpdtl = new Lab_Test_Detail();
                    grpdtl.Lab_Test_ID = grpHeader.Lab_Test_ID;
                    grpdtl.Patient_ID = Convert.ToInt32(ListOfDetails[0].Bill_ID);
                    grpdtl.Date = newBill.Creation_Date;
                    grpdtl.Test_ID = 0;
                    grpdtl.IsBilled = true;
                    grpdtl.Catagory_ID = Category[0].Category_ID;
                    //grpdtl.Dept_ID = Category[0].t.Main_Department;
                    db.Lab_Test_Details.InsertOnSubmit(grpdtl);
                    db.SubmitChanges();
                    grpHeader.Parent_Transaction_Type = "Front Desk";
                    grpHeader.Parent_Transaction_Type_ID = grpdtl.Lab_Test_Detail_ID;
                    db.SubmitChanges();
                    var Item = (from d in ListOfDetails
                                where d.Category_ID == Category[0].Category_ID && d.Item_Type == "Test" && d.RecommendedByDoctor == false && d.ParentTrans_Type == "Test Group Category"
                                select d).FirstOrDefault();

                    if (Item != null)

                        ListOfDetails.Where(d => d.Category_ID == Category[0].Category_ID && d.Item_Type == "Test" && d.RecommendedByDoctor == false && d.ParentTrans_Type == "Test Group Category").FirstOrDefault().ParentTrans_ID = grpdtl.Lab_Test_Detail_ID;


                }
                #endregion

                #region "Entry of newly entered individual tests from front desk coutner in databse."

                // Entry of newly entered individual tests from front desk coutner in databse.

                var NewTests = (from t in ListOfDetails where t.Item_Type == "Test" && t.RecommendedByDoctor == false && t.ParentTrans_Type != "Test Group Category" && t.ParentTrans_ID == 0 select t).ToList();

                if (NewTests.Count > 0)
                {

                    Laboratory_Test lt = new Laboratory_Test();

                    lt.Patient_ID = Convert.ToInt32(ListOfDetails[0].Bill_ID);
                    lt.Transaction_Type = "Front Desk";
                    lt.Created_Time = DateTime.Now;
                    db.Laboratory_Tests.InsertOnSubmit(lt);
                    db.SubmitChanges();

                    foreach (var test in NewTests)
                    {
                        Lab_Test_Detail ltd = new Lab_Test_Detail();
                        ltd.Lab_Test_ID = lt.Lab_Test_ID;
                        ltd.Patient_ID = Convert.ToInt32(ListOfDetails[0].Bill_ID);
                        ltd.Date = newBill.Creation_Date;
                        ltd.Test_ID = (int)test.Item_ID;
                        db.Lab_Test_Details.InsertOnSubmit(ltd);
                        db.SubmitChanges();

                        var Item = (from d in ListOfDetails
                                    where d.Item_ID == ltd.Test_ID && d.Item_Type == "Test" && d.RecommendedByDoctor == false && d.ParentTrans_Type != "Test Group Category" && d.ParentTrans_ID == 0
                                    select d).FirstOrDefault();

                        if (Item != null)

                            ListOfDetails.Where(d => d.Item_ID == ltd.Test_ID && d.Item_Type == "Test" && d.RecommendedByDoctor == false && d.ParentTrans_Type != "Test Group Category" && d.ParentTrans_ID == 0).FirstOrDefault().ParentTrans_ID = ltd.Lab_Test_Detail_ID;
                    }
                }

                #endregion
            }
            #endregion

            #region "Save & Print"
            else
            {
                #region "Entry of group tests from OPD."

                foreach (var item in (from t in ListOfDetails where t.Item_Type == "Test" select t))
                {
                    MarkTestAsBilled((int)(item.ParentTrans_ID));
                }


                // Entry of group tests from OPD.

                var newGroups = (from t in ListOfDetails where t.Item_Type == "Test" && t.RecommendedByDoctor == true && t.ParentTrans_Type == "Test Group Category" select t).ToList();

                var distinctCategories = newGroups.Select(t => t.Category_ID).Distinct().ToList();

                int typesOfGroups = distinctCategories.Count();

                string[] CategoryIDs = new string[typesOfGroups];

                int counter = 0;

                foreach (var item in distinctCategories)
                {
                    CategoryIDs[counter] = item;
                    counter++;
                }

                for (int i = 0; i < CategoryIDs.Length; i++)
                {
                    var Category = newGroups.Where(c => c.Category_ID == CategoryIDs[i]).ToList();

                    MarkTestAsBilled((int)Category[0].ParentTrans_ID);

                    Laboratory_Test lt = new Laboratory_Test();

                    lt.Patient_ID = Convert.ToInt32(ListOfDetails[0].Bill_ID);
                    lt.Transaction_Type = "OutPatient";
                    lt.Parent_Transaction_Type = "OutPatient";
                    lt.Created_Time = DateTime.Now;
                    lt.Parent_Transaction_Type_ID = Category[0].ParentTrans_ID;
                    db.Laboratory_Tests.InsertOnSubmit(lt);
                    db.SubmitChanges();

                    foreach (var item in Category)
                    {
                        Lab_Test_Detail ltd = new Lab_Test_Detail();
                        ltd.Lab_Test_ID = lt.Lab_Test_ID;
                        ltd.Patient_ID = Convert.ToInt32(ListOfDetails[0].Bill_ID);
                        ltd.Date = newBill.Creation_Date;
                        ltd.Test_ID = (int)item.Item_ID;
                        ltd.Actual_Patient_ID = newBill.Patient_ID;
                        ltd.Catagory_ID = item.Category_ID;
                        //ltd.Dept_ID = item.Main_Department;
                        db.Lab_Test_Details.InsertOnSubmit(ltd);
                        db.SubmitChanges();

                        var Item = (from d in ListOfDetails
                                    where d.Item_ID == ltd.Test_ID && d.Item_Type == "Test" && d.RecommendedByDoctor == true && d.ParentTrans_Type == "Test Group Category"
                                    select d).FirstOrDefault();

                        if (Item != null)

                            ListOfDetails.Where(d => d.Item_ID == ltd.Test_ID && d.Item_Type == "Test" && d.RecommendedByDoctor == true && d.ParentTrans_Type == "Test Group Category").FirstOrDefault().ParentTrans_ID = ltd.Lab_Test_Detail_ID;
                    }
                }

                #endregion

                #region "Entry of newly entered group tests from front desk coutner in databse."

                // Entry of newly entered group tests from front desk coutner in databse.

                newGroups = (from t in ListOfDetails where t.Item_Type == "Test" && t.RecommendedByDoctor == false && t.ParentTrans_Type == "Test Group Category" select t).ToList();

                distinctCategories = newGroups.Select(t => t.Category_ID).Distinct().ToList();

                typesOfGroups = distinctCategories.Count();

                CategoryIDs = new string[typesOfGroups];

                counter = 0;

                foreach (var item in distinctCategories)
                {
                    CategoryIDs[counter] = item;
                    counter++;
                }
                foreach (var test in newGroups)

                {
                    //var Category = newGroups.Where(c => c.Category_ID == CategoryIDs[i]).ToList();

                    // Entry with 0 values for inserting group...

                    Laboratory_Test grpHeader = new Laboratory_Test();

                    grpHeader.Patient_ID = Convert.ToInt32(ListOfDetails[0].Bill_ID);
                    grpHeader.Transaction_Type = "Front Desk";
                    grpHeader.Created_Time = DateTime.Now;
                    db.Laboratory_Tests.InsertOnSubmit(grpHeader);
                    db.SubmitChanges();

                    Lab_Test_Detail grpdtl = new Lab_Test_Detail();
                    grpdtl.Lab_Test_ID = grpHeader.Lab_Test_ID;
                    grpdtl.Patient_ID = Convert.ToInt32(ListOfDetails[0].Bill_ID);
                    grpdtl.Date = newBill.Creation_Date;
                    grpdtl.Test_ID = 0;
                    grpdtl.IsBilled = true;
                    grpdtl.Catagory_ID = test.Category_ID;
                    grpdtl.Actual_Patient_ID = newBill.Patient_ID;
                    //grpdtl.Dept_ID = Category[0].t.Main_Department;
                    db.Lab_Test_Details.InsertOnSubmit(grpdtl);
                    db.SubmitChanges();
                    grpHeader.Parent_Transaction_Type = "Front Desk";
                    grpHeader.Parent_Transaction_Type_ID = grpdtl.Lab_Test_Detail_ID;
                    db.SubmitChanges();
                    var Item = (from d in ListOfDetails
                                where d.Category_ID == test.Category_ID && d.Item_Type == "Test" && d.RecommendedByDoctor == false && d.ParentTrans_Type == "Test Group Category"
                                select d).FirstOrDefault();

                    if (Item != null)

                        ListOfDetails.Where(d => d.Category_ID == test.Category_ID && d.Item_Type == "Test" && d.RecommendedByDoctor == false && d.ParentTrans_Type == "Test Group Category").FirstOrDefault().ParentTrans_ID = grpdtl.Lab_Test_Detail_ID;

                }
                #endregion

                #region "Entry of newly entered individual tests from front desk coutner in databse."

                // Entry of newly entered individual tests from front desk coutner in databse.
                foreach (var item in (from t in ListOfDetails where t.Item_Type == "Test" select t))
                {
                    MarkTestAsBilled((int)(item.ParentTrans_ID));
                }
                var NewTests = (from t in ListOfDetails where t.Item_Type == "Test" && t.RecommendedByDoctor == false && t.ParentTrans_Type != "Test Group Category" select t).ToList();

                //var checkid = (from a in db.InPatientServices)



                var NewServices = (from t in ListOfDetails where t.Item_Type == "Service" select t).ToList();
                if (NewServices.Count > 0)
                {
                    foreach (var servs in NewServices)
                    {
                        var ipdservices = db.InPatientServices.Where(b => b.PatientId == data.Patient_ID && b.Service_ItemId == Convert.ToString(servs.Item_ID)).FirstOrDefault();
                        if (ipdservices != null)
                        {
                            ipdservices.isbilled = true;
                            db.SubmitChanges();
                        }


                    }

                }

                if (NewTests.Count > 0)
                {

                    Laboratory_Test lt = new Laboratory_Test();

                    lt.Patient_ID = Convert.ToInt32(ListOfDetails[0].Bill_ID);
                    lt.Transaction_Type = "Front Desk";
                    lt.Created_Time = DateTime.Now;
                    db.Laboratory_Tests.InsertOnSubmit(lt);
                    db.SubmitChanges();

                    foreach (var test in NewTests)
                    {
                        Lab_Test_Detail ltd = new Lab_Test_Detail();
                        ltd.Lab_Test_ID = lt.Lab_Test_ID;
                        ltd.Patient_ID = Convert.ToInt32(ListOfDetails[0].Bill_ID);
                        ltd.Date = newBill.Creation_Date;
                        ltd.Test_ID = (int)test.Item_ID;
                        ltd.Actual_Patient_ID = newBill.Patient_ID;
                        ltd.IsBilled = true;
                        db.Lab_Test_Details.InsertOnSubmit(ltd);
                        db.SubmitChanges();

                        var Item = (from d in ListOfDetails
                                    where d.Item_ID == ltd.Test_ID && d.Item_Type == "Test" && d.RecommendedByDoctor == false && d.ParentTrans_Type != "Test Group Category"
                                    select d).FirstOrDefault();

                        var ItemInPat = (from d in ListOfDetails
                                         where d.Item_ID == ltd.Test_ID && d.Item_Type == "Test" && d.RecommendedByDoctor == false && d.ParentTrans_Type != "Test Group Category" && d.ParentTrans_ID != 0
                                         select d).FirstOrDefault();
                        if (ItemInPat == null)
                        {

                            if (Item != null)
                                ListOfDetails.Where(d => d.Item_ID == ltd.Test_ID && d.Item_Type == "Test" && d.RecommendedByDoctor == false && d.ParentTrans_Type != "Test Group Category" && d.ParentTrans_ID == 0).FirstOrDefault().ParentTrans_ID = ltd.Lab_Test_Detail_ID;
                        }
                        else
                        {
                            ListOfDetails.Where(d => d.Item_ID == ltd.Test_ID && d.Item_Type == "Test" && d.RecommendedByDoctor == false && d.ParentTrans_Type != "Test Group Category").FirstOrDefault().ParentTrans_ID = ltd.Lab_Test_Detail_ID;
                        }
                    }

                }

                #endregion

            }
            #endregion

            // Marking that test is Billed in Lab Test Details.
            db.Ar_Billing_Details.InsertAllOnSubmit(ListOfDetails);
            db.AR_Billing_Detail_Doctor_Shares.InsertAllOnSubmit(ListOfshare);
            db.SubmitChanges();

            var Bill_Detail_List = db.Ar_Billing_Details
               .Where(abd => abd.Bill_ID == ListOfDetails[0].Bill_ID && (abd.ParentTrans_Type == "Test"))
               .ToList();

            var Bill_Detail_Lists = db.Ar_Billing_Details
              .Where(abd => abd.Bill_ID == ListOfDetails[0].Bill_ID && (abd.ParentTrans_Type == "Test Group Category"))
              .ToList();

            foreach (var billDetailss in Bill_Detail_Lists)
            {
                int billDetailIDs = billDetailss.Bill_Details_ID;

                // Update matching Lab_Test_Details rows using raw SQL
                db.ExecuteCommand(@"
                UPDATE Lab_Test_Detail 
                 SET BillDetailID = {0} 
                 WHERE Actual_Patient_ID = {1} 
                 AND Test_ID = {2} 
                 AND Catagory_ID = {3}",
                    billDetailIDs,
                    newBill.Patient_ID,
                    billDetailss.Item_ID,
                    billDetailss.Category_ID);
            }
            //To Update The latest Billing Entry
            foreach (var billDetail in Bill_Detail_List)
            {
                int billDetailID = billDetail.Bill_Details_ID;
                var labTestDetail = db.Lab_Test_Details
                    .FirstOrDefault(ltd => ltd.Patient_ID == billDetail.Bill_ID && ltd.Test_ID == billDetail.Item_ID);

                if (labTestDetail != null)
                {
                    labTestDetail.BillDetailID = billDetailID;

                    db.SubmitChanges();
                }
            }
            //To Update The OutPatient Billing Entry
            foreach (var billDetails in Bill_Detail_List)
            {
                int billDetailID = billDetails.Bill_Details_ID;

                var labTestDetails = db.Lab_Test_Details
                    .Where(ltd => ltd.Actual_Patient_ID == newBill.Patient_ID && ltd.Test_ID == billDetails.Item_ID)
                    .ToList(); // Get all matching rows

                foreach (var labTestDetail in labTestDetails)
                {
                    labTestDetail.BillDetailID = billDetailID;

                }

                db.SubmitChanges();
            }


                //bypass X-Ray etc

                #region"Deleting previous receipt and insert new according to bill."

                List<Receipt> rcpt = db.Receipts.Where(r => r.Bill_ID == newBill.Bill_ID).ToList();
            if (rcpt != null)
                db.Receipts.DeleteAllOnSubmit(rcpt);
            db.SubmitChanges();
            if (newBill.Received_Amount >= 0)
            {
                Receipts.SaveRecord((int)0, (int)(newBill.Patient_ID), (DateTime)newBill.Bill_Date, (string)"Amount received while billing, Bill No:- " + newBill.Bill_No + "", (decimal)newBill.Received_Amount, (int)newBill.Bill_ID);
            }

            #endregion

            #region "Billing Segment"

            // Inserting Voucher
            //     InsertVoucher(newBill.Bill_ID);



            #endregion

            string sql = "Update AR_Billing_Details set Category_ID = '' where Item_Type = 'Test' and Item_ID in (Select Test_ID from Lab_Tests) and Bill_ID = " + newBill.Bill_ID + "";
            //string sqls = "Update InPatientServices set isbilled =1 where PatientId =" + newBill.Patient_ID + "";
            bool status = DBClass.executeNonQueryWithoutBegin(sql) > 0 ? true : false;
            string sql_query = "select top 1 Discount_Assigned_Patient_Id from Discount_Assigned_Patient where Patient_Id=" + newBill.Patient_ID;
            var get = DBClass.getField(sql_query);
            if (get.Equals("There is no row at position 0."))
            {


            }
            else
            {
                var querys = (from datas in db.Discount_Assigned_Patient_Details where datas.Discount_Assigned_Patient_Id == Convert.ToInt32(get) select datas).ToList();
                //decimal sum_ultra = 0;
                //decimal sum_Xray = 0;
                //decimal sum_CTscan = 0;
                //decimal sum_Blood = 0;
                //decimal sum_Item = 0;
                //decimal sum_Procedure = 0;
                foreach (var item in querys)
                {
                    var type = item.Department_Name;
                    if (type == "Hospital Services")
                    {
                        var disamt = item.Discount_Amount;
                        if (disamt == Convert.ToDecimal("0.0000"))
                        {

                        }
                        else
                        {
                            var Remain = item.Remaining_Amount;
                            item.Remaining_Amount = sum_Item + Remain;
                        }
                    }
                    else if (type == "Procedure")
                    {
                        var disamt = item.Discount_Amount;
                        if (disamt == Convert.ToDecimal("0.0000"))
                        {

                        }
                        else
                        {
                            var Remain = item.Remaining_Amount;
                            item.Remaining_Amount = sum_Procedure + Remain;
                        }
                    }
                    else if (type == "Package")
                    {
                        var disamt = item.Discount_Amount;
                        if (disamt == Convert.ToDecimal("0.0000"))
                        {

                        }
                        else
                        {
                            var Remain = item.Remaining_Amount;
                            item.Remaining_Amount = sum_Package + Remain;
                        }

                    }
                    else if (type == "Lab")
                    {
                        var disamt = item.Discount_Amount;
                        if (disamt == Convert.ToDecimal("0.0000"))
                        {

                        }
                        else
                        {
                            var Remain = item.Remaining_Amount;
                            item.Remaining_Amount = sum + Remain;
                        }


                    }
                    else if (type == "UltraSound")
                    {
                        var disamt = item.Discount_Amount;
                        if (disamt == Convert.ToDecimal("0.0000"))
                        {

                        }
                        else
                        {
                            var Remain = item.Remaining_Amount;
                            item.Remaining_Amount = sum_ultra + Remain;
                        }
                    }
                    else if (type == "X-Ray")
                    {
                        var disamt = item.Discount_Amount;
                        if (disamt == Convert.ToDecimal("0.0000"))
                        {

                        }
                        else
                        {
                            var Remain = item.Remaining_Amount;
                            item.Remaining_Amount = sum_Xray + Remain;
                        }
                    }
                    else if (type == "CT-Scan")
                    {
                        var disamt = item.Discount_Amount;
                        if (disamt == Convert.ToDecimal("0.0000"))
                        {

                        }
                        else
                        {
                            var Remain = item.Remaining_Amount;
                            item.Remaining_Amount = sum_CTscan + Remain;
                        }
                    }
                    else if (type == "Blood Bank")
                    {
                        var disamt = item.Discount_Amount;
                        if (disamt == Convert.ToDecimal("0.0000"))
                        {

                        }
                        else
                        {
                            var Remain = item.Remaining_Amount;
                            item.Remaining_Amount = sum_Blood + Remain;
                        }
                    }
                    db.SubmitChanges();
                }
            }

            sql = "exec spAutoGenerateLabTestEntry";
            DBClass.executeNonQueryWithoutBegin(sql);
            //DBClass.executeNonQueryWithoutBegin(sqls);
            //end
            return newBill.Bill_ID.ToString();
        }

        public class Billings
        {
            public int Bill_ID { get; set; }
            public int Patient_ID { get; set; }
            public int Opd_id { get; set; }
            public string referred_by_doctor { get; set; }
            public string Casher { get; set; }
            public DateTime Bill_Date { get; set; }
            public string Remarks { get; set; }
            public decimal Discount_Percentage { get; set; }
            public decimal Discount_Amount { get; set; }
            public decimal TotalPayable { get; set; }
            public decimal Net_Amount { get; set; }
            public decimal Received_Amount { get; set; }
            public decimal Balance_Amount { get; set; }
            public string ChargePolicy { get; set; }
            //public string Remarks { get; set; }
            public List<BillingProcessDetails> Details { get; set; }
            public List<DoctorDistributionList> Share { get; set; }
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
                            data.Total_Amount,
                            data.Updated_By,
                            data.Updation_Date,
                            data.Casher,
                            data.Voucher_ID,
                            data.In_Patient_ID,
                            data.Referred_By,
                            Patient_Discount_Type = (from tbl in db.In_Patients
                                                     where tbl.In_Patient_ID == data.In_Patient_ID

                                                     orderby tbl.Created_Time descending
                                                     select db.GetDataValueName("Patient Type", tbl.Patient_Discount_Type)).FirstOrDefault(),

                            //Reffer_By_Doc = (from tbl in db.HR_Employees
                            //                         where tbl.Emp_ID == Convert.ToInt32(data.Referred_By)
                            //                         select tbl.Emp_Name).FirstOrDefault()
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
                               d.Doctor_Share,
                               d.Hospital_Share,
                               d.Doctor_id,
                               d.RecommendedByDoctor,
                               m.Referred_By
                           }).ToList();


            return (new JavaScriptSerializer()).Serialize(Details);
        }
        //[WebMethod]
        //public static string GetDocAgreementValues(string doc_id, string test_id, string item_id, string item_name, string Aggreement_Type)
        //{
        //    using (DataBaseDataContext db = new DataBaseDataContext())
        //    {
        //        // for services check other wis eif it is test than go to else part

        //        var check = (from data in db.Doctor_Agreements
        //                     join dd in db.Doctor_agreement_details on data.Doc_agreemnt_id equals dd.Doc_agreement_id
        //                     where data.Doctor == doc_id
        //                     && item_id == Convert.ToString(dd.item_id)
        //                     && dd.item_id != 0
        //                     && dd.test_id == 0
        //                     && dd.services == "002"
        //                     && dd.AgrementTypeId == Aggreement_Type
        //                     && dd.service_description.Contains(item_name)
        //                     //&& dd.isactive == true
        //                     //orderby dd.doc_detail_id descending
        //                     select new
        //                     {
        //                         data.Doctor,
        //                         dd.services,
        //                     }).FirstOrDefault();

        //        if (Aggreement_Type == "03")
        //        {
        //            if (check != null)
        //            {
        //                if (check.services == "002")
        //                {
        //                    var serv = (from data in db.Doctor_Agreements
        //                                join dd in db.Doctor_agreement_details on data.Doc_agreemnt_id equals dd.Doc_agreement_id
        //                                where dd.services == "002"
        //                                && data.Doctor == doc_id
        //                                && item_id == Convert.ToString(dd.item_id)
        //                                && dd.AgrementTypeId == Aggreement_Type
        //                                && dd.isactive == true
        //                                //orderby dd.doc_detail_id descending
        //                                select new
        //                                {
        //                                    dd.doc_share,
        //                                    dd.hos_share,
        //                                }).FirstOrDefault();

        //                    if (serv == null)
        //                    {
        //                        var inactive_srv = (from data in db.Panels
        //                                            join dd in db.Panel_Detail_Services on data.Panel_ID equals dd.Panel_ID
        //                                            where dd.Item_Code != 0
        //                                            && item_id == Convert.ToString(dd.Item_ID)
        //                                            select new
        //                                            {
        //                                                doc_share = 0,
        //                                                hos_share = dd.Rate,

        //                                            }).FirstOrDefault();
        //                        return (new JavaScriptSerializer()).Serialize(inactive_srv);
        //                    }
        //                    return (new JavaScriptSerializer()).Serialize(serv);
        //                }
        //                else
        //                {
        //                    var items = (from data in db.Doctor_Agreements
        //                                 join dd in db.Doctor_agreement_details on data.Doc_agreemnt_id equals dd.Doc_agreement_id
        //                                 where data.Doctor == doc_id && dd.services == null && dd.test_id == Convert.ToInt32(test_id) && dd.item_id == 0
        //                                 && dd.isactive == true
        //                                 select new
        //                                 {
        //                                     dd.doc_share,
        //                                     dd.hos_share,
        //                                 }).FirstOrDefault();
        //                    return (new JavaScriptSerializer()).Serialize(items);
        //                }
        //            }
        //            else
        //            {
        //                var items = (from data in db.Doctor_Agreements
        //                             join dd in db.Doctor_agreement_details on data.Doc_agreemnt_id equals dd.Doc_agreement_id
        //                             where data.Doctor == doc_id && dd.services == null && dd.test_id == Convert.ToInt32(test_id) && dd.item_id == 0 && dd.AgrementTypeId == Aggreement_Type
        //                              && dd.isactive == true
        //                             select new
        //                             {
        //                                 dd.doc_share,
        //                                 dd.hos_share,
        //                             }).FirstOrDefault();
        //                if (items == null)
        //                {
        //                    var inactive_item = (from data in db.Panels
        //                                         join dd in db.Panel_Detail_Services on data.Panel_ID equals dd.Panel_ID
        //                                         where dd.Item_Code == 0
        //                                         && item_id == Convert.ToString(dd.Test_ID)
        //                                         select new
        //                                         {
        //                                             doc_share = 0,
        //                                             hos_share = dd.Rate,
        //                                         }).FirstOrDefault();
        //                    return (new JavaScriptSerializer()).Serialize(inactive_item);
        //                }
        //                return (new JavaScriptSerializer()).Serialize(items);
        //            }
        //        }
        //        else
        //        {
        //            if (check != null)
        //            {
        //                if (check.services == "002")
        //                {
        //                    var serv = (from data in db.Doctor_Agreements
        //                                join dd in db.Doctor_agreement_details on data.Doc_agreemnt_id equals dd.Doc_agreement_id
        //                                where dd.services == "002"
        //                                && data.Doctor == doc_id
        //                                && item_id == Convert.ToString(dd.item_id)
        //                                && dd.AgrementTypeId == Aggreement_Type
        //                                && dd.isactive == true
        //                                //orderby dd.doc_detail_id descending
        //                                select new
        //                                {
        //                                    dd.doc_share,
        //                                    dd.hos_share,
        //                                }).FirstOrDefault();

        //                    if (serv == null)
        //                    {
        //                        var inactive_srv = (from data in db.Doctor_Agreements
        //                                            join dd in db.Doctor_agreement_details on data.Doc_agreemnt_id equals dd.Doc_agreement_id
        //                                            where dd.services == "002"
        //                                            && item_id == Convert.ToString(dd.item_id)
        //                                             && data.Doctor == doc_id
        //                                             && dd.AgrementTypeId == Aggreement_Type
        //                                            && dd.isactive == false
        //                                            select new
        //                                            {
        //                                                doc_share = 0,
        //                                                hos_share = dd.Actual_amount,
        //                                            }).FirstOrDefault();
        //                        return (new JavaScriptSerializer()).Serialize(inactive_srv);
        //                    }

        //                    return (new JavaScriptSerializer()).Serialize(serv);
        //                }
        //                else
        //                {
        //                    var items = (from data in db.Doctor_Agreements
        //                                 join dd in db.Doctor_agreement_details on data.Doc_agreemnt_id equals dd.Doc_agreement_id
        //                                 where data.Doctor == doc_id && dd.services == null && dd.test_id == Convert.ToInt32(test_id) && dd.item_id == 0
        //                                 && dd.isactive == true
        //                                 select new
        //                                 {
        //                                     dd.doc_share,
        //                                     dd.hos_share,
        //                                 }).FirstOrDefault();
        //                    return (new JavaScriptSerializer()).Serialize(items);
        //                }

        //            }
        //            else
        //            {
        //                var items = (from data in db.Doctor_Agreements
        //                             join dd in db.Doctor_agreement_details on data.Doc_agreemnt_id equals dd.Doc_agreement_id
        //                             where data.Doctor == doc_id && dd.services == null && dd.test_id == Convert.ToInt32(test_id) && dd.item_id == 0 && dd.AgrementTypeId == Aggreement_Type
        //                              && dd.isactive == true
        //                             select new
        //                             {
        //                                 dd.doc_share,
        //                                 dd.hos_share,
        //                             }).FirstOrDefault();
        //                if (items == null)
        //                {
        //                    var inactive_item = (from data in db.Lab_Tests
        //                                         where data.Test_ID == Convert.ToInt32(test_id)
        //                                         select new
        //                                         {
        //                                             doc_share = 0,
        //                                             hos_share = data.Rate,

        //                                         }).FirstOrDefault();
        //                    return (new JavaScriptSerializer()).Serialize(inactive_item);
        //                }
        //                return (new JavaScriptSerializer()).Serialize(items);
        //            }
        //        }
        //    }
        //}
        [WebMethod]
        public static string GetDocAgreementValues(string doc_id, string test_id, string item_id, string item_name, string Aggreement_Type)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                bool isAgreementType03 = Aggreement_Type == "03"; // Moved outside for global access

                // Check if the doctor exists in agreements
                var Check_Doc = (from data in db.Doctor_Agreements
                                 join dd in db.Doctor_agreement_details on data.Doc_agreemnt_id equals dd.Doc_agreement_id
                                 where data.Doctor == doc_id
                                 && dd.item_id.ToString() == item_id
                                 && dd.AgrementTypeId == Aggreement_Type
                                 && (dd.service_description.Contains(item_name) || dd.test_description.Contains(item_name))
                                 select new { dd.services }).FirstOrDefault();

                if (Check_Doc != null)
                {
                    var check = (from data in db.Doctor_Agreements
                                 join dd in db.Doctor_agreement_details on data.Doc_agreemnt_id equals dd.Doc_agreement_id
                                 where data.Doctor == doc_id
                                 && dd.item_id.ToString() == item_id
                                 && dd.item_id != 0
                                 && dd.test_id == 0
                                 && dd.services == "002"
                                 && dd.AgrementTypeId == Aggreement_Type
                                 && dd.service_description.Contains(item_name)
                                 select new { dd.services }).FirstOrDefault();

                    if (check != null && check.services == "002")
                    {
                        var serv = db.Doctor_Agreements
                                     .Join(db.Doctor_agreement_details,
                                           data => data.Doc_agreemnt_id,
                                           dd => dd.Doc_agreement_id,
                                           (data, dd) => new { dd })
                                     .Where(d => d.dd.services == "002"
                                              && d.dd.AgrementTypeId == Aggreement_Type
                                              && d.dd.isactive == true
                                              && d.dd.item_id.ToString() == item_id
                                              && d.dd.Doc_agreement_id.ToString() == doc_id)
                                     .Select(d => new { d.dd.doc_share, d.dd.hos_share })
                                     .FirstOrDefault();

                        return new JavaScriptSerializer().Serialize(serv);
                    }

                    var items = db.Doctor_Agreements
                                  .Join(db.Doctor_agreement_details,
                                        data => data.Doc_agreemnt_id,
                                        dd => dd.Doc_agreement_id,
                                        (data, dd) => new { dd })
                                  .Where(d => d.dd.AgrementTypeId == Aggreement_Type
                                           && d.dd.isactive == true
                                           && d.dd.services == null
                                           && d.dd.test_id == Convert.ToInt32(test_id)
                                           && d.dd.item_id == 0
                                           && d.dd.Doc_agreement_id.ToString() == doc_id)
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
                                    .Where(d => d.Test_ID == Convert.ToInt32(test_id))
                                    .Select(d => new { doc_share = 0, hos_share = d.Rate })
                                    .FirstOrDefault();

                    if (Test_Id == null)
                    {
                        var Service = db.INV_Items
                                        .Where(inv => inv.Item_ID == Convert.ToInt32(item_id) && inv.Services == true)
                                        .Select(inv => new { doc_share = (inv.Doctor_Share / 100) * inv.Sale_Rate, hos_share = (inv.Hospital_Share / 100) * inv.Sale_Rate })
                                        .FirstOrDefault();

                        return new JavaScriptSerializer().Serialize(Service);
                    }

                    return new JavaScriptSerializer().Serialize(Test_Id);
                }
            }
        }
        //[WebMethod]
        //public static string GetDocAgreementValues(string doc_id, string test_id, string item_id, string item_name, string Aggreement_Type)
        //{
        //    using (DataBaseDataContext db = new DataBaseDataContext())
        //    {
        //        // for services check other wis eif it is test than go to else part


        //        var Check_Doc = (from data in db.Doctor_Agreements
        //                         where data.Doctor == doc_id
        //                         select new
        //                         {
        //                             data.Doctor
        //                         }).FirstOrDefault();

        //        if (Check_Doc != null)
        //        {

        //            var check = (from data in db.Doctor_Agreements
        //                         join dd in db.Doctor_agreement_details on data.Doc_agreemnt_id equals dd.Doc_agreement_id
        //                         where data.Doctor == doc_id
        //                         && item_id == Convert.ToString(dd.item_id)
        //                         && dd.item_id != 0
        //                         && dd.test_id == 0
        //                         && dd.services == "002"
        //                         && dd.AgrementTypeId == Aggreement_Type
        //                         && dd.service_description.Contains(item_name)

        //                         select new
        //                         {
        //                             data.Doctor,
        //                             dd.services,
        //                         }).FirstOrDefault();

        //            if (Aggreement_Type == "03")
        //            {
        //                if (check != null)
        //                {
        //                    if (check.services == "002")
        //                    {
        //                        var serv = (from data in db.Doctor_Agreements
        //                                    join dd in db.Doctor_agreement_details on data.Doc_agreemnt_id equals dd.Doc_agreement_id
        //                                    where dd.services == "002"
        //                                    && data.Doctor == doc_id
        //                                    && item_id == Convert.ToString(dd.item_id)
        //                                    && dd.AgrementTypeId == Aggreement_Type
        //                                    && dd.isactive == true
        //                                    select new
        //                                    {
        //                                        dd.doc_share,
        //                                        dd.hos_share,
        //                                    }).FirstOrDefault();


        //                        return (new JavaScriptSerializer()).Serialize(serv);
        //                    }

        //                }
        //                else
        //                {
        //                    var items = (from data in db.Doctor_Agreements
        //                                 join dd in db.Doctor_agreement_details on data.Doc_agreemnt_id equals dd.Doc_agreement_id
        //                                 where data.Doctor == doc_id && dd.services == null && dd.test_id == Convert.ToInt32(test_id) && dd.item_id == 0 && dd.AgrementTypeId == Aggreement_Type
        //                                  && dd.isactive == true
        //                                 select new
        //                                 {
        //                                     dd.doc_share,
        //                                     dd.hos_share,
        //                                 }).FirstOrDefault();

        //                    return (new JavaScriptSerializer()).Serialize(items);
        //                }
        //            }
        //            else
        //            {
        //                if (check != null)
        //                {
        //                    if (check.services == "002")
        //                    {
        //                        var serv = (from data in db.Doctor_Agreements
        //                                    join dd in db.Doctor_agreement_details on data.Doc_agreemnt_id equals dd.Doc_agreement_id
        //                                    where dd.services == "002"
        //                                    && data.Doctor == doc_id
        //                                    && item_id == Convert.ToString(dd.item_id)
        //                                    && dd.AgrementTypeId == Aggreement_Type
        //                                    && dd.isactive == true
        //                                    //orderby dd.doc_detail_id descending
        //                                    select new
        //                                    {
        //                                        dd.doc_share,
        //                                        dd.hos_share,
        //                                    }).FirstOrDefault();


        //                        return (new JavaScriptSerializer()).Serialize(serv);
        //                    }

        //                }
        //                else
        //                {
        //                    var items = (from data in db.Doctor_Agreements
        //                                 join dd in db.Doctor_agreement_details on data.Doc_agreemnt_id equals dd.Doc_agreement_id
        //                                 where data.Doctor == doc_id && dd.services == null && dd.test_id == Convert.ToInt32(test_id) && dd.item_id == 0 && dd.AgrementTypeId == Aggreement_Type
        //                                  && dd.isactive == true
        //                                 select new
        //                                 {
        //                                     dd.doc_share,
        //                                     dd.hos_share,
        //                                 }).FirstOrDefault();
        //                    return (new JavaScriptSerializer()).Serialize(items);
        //                }
        //            }
        //        }
        //        if (Check_Doc == null)
        //        {
        //            if (Aggreement_Type == "03")
        //            {
        //                var Panel_Test = (from data in db.Panel_Detail_Services
        //                                     where data.Test_ID == test_id && data.Item_ID == null
        //                                     select new
        //                                     {
        //                                         doc_share = 0,
        //                                         hos_share = data.Rate,

        //                                     }).FirstOrDefault();

        //                if(Panel_Test == null)
        //                {
        //                    var Panel_Service = (from data in db.Panel_Detail_Services
        //                                         where data.Test_ID == null && data.Item_ID == item_id
        //                                         select new
        //                                         {
        //                                             doc_share = 0,
        //                                             hos_share = data.Rate,

        //                                         }).FirstOrDefault();
        //                    return (new JavaScriptSerializer()).Serialize(Panel_Service);

        //                }
        //                return (new JavaScriptSerializer()).Serialize(Panel_Test);
        //            }
        //            else
        //            {
        //                var Test_Id = (from data in db.Lab_Tests
        //                                     where data.Test_ID == Convert.ToInt32(test_id)
        //                                     select new
        //                                     {
        //                                         doc_share = 0,
        //                                         hos_share = data.Rate,

        //                                     }).FirstOrDefault();
        //                if(Test_Id == null)
        //                {
        //                    var Service = (from inv in db.INV_Items
        //                                   where inv.Item_ID ==Convert.ToInt32(item_id) && inv.Item_Type == "002"
        //                                   select new
        //                                   {
        //                                       doc_share = 0,
        //                                       hos_share = inv.Hospital_Share

        //                                   }).FirstOrDefault();
        //                    return (new JavaScriptSerializer()).Serialize(Service);
        //                }

        //                return (new JavaScriptSerializer()).Serialize(Test_Id);

        //            }
        //        }
        //    }
        //}

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
                                       m.Net_Amount,
                                       m.Discount_Amount,
                                       m.Total_Amount
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
                       where tbl.Patient_ID == pat_id

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

                if (pat.Created_time.HasValue)
                {
                    pt.Entry_Date = pat.Created_time.ToString();
                }
                else
                {
                    pt.Entry_Date = pat.Created_time.ToString();
                }
                pt.opdid = DBClass.getField("select Out_Patient_ID from Out_Patient where Reg_PatId =" + pat_id);
                // pt.opd_id = DBClass.getField("Select Patient_ID from Patients where Reg_PatId = " + pat_id + "order by Created_Time desc" );
                if (query.Count > 0 && walkin == false)
                {
                    pt.pat_id = DBClass.getField("select Patient_ID from In_Patient where Patient_ID =" + pat_id);
                }
                else
                {
                    pt.pat_id = DBClass.getField("select Reg_PatId from Out_Patient where Reg_PatId =" + pat_id);
                }
                pt.Patient_Type = db.GetDataValueName("Patient Type", DBClass.getField("select Patient_Type from Patients where  Reg_PatId =" + PatientID + "order by Created_Time desc"));
                pt.Patient_Type_id = DBClass.getField("select Patient_Type from Patients where  Reg_PatId =" + PatientID + "order by Created_Time desc");
                pt.IsDisountAvailable = DBClass.getField("select Discount_Assigned_Patient_Id from Discount_Assigned_Patient where ISNULL(IsDischarge,'0')=0 and Patient_Id =" + PatientID);
                pt.DiscountPercFromMaster = DBClass.getField("select Discount_Percentage from Discount_Assigned_Patient where ISNULL(IsDischarge,'0')=0 and Patient_Id =" + PatientID);
                pt.DiscountAmountFromMaster = DBClass.getField("select Discount_Amount from Discount_Assigned_Patient where ISNULL(IsDischarge,'0')=0 and Patient_Id =" + PatientID);
                pt.pkg_name = DBClass.getField("select top 1 packagae_name from In_Patient where Patient_Id =" + PatientID + " and Discharge = 1 order by Created_Time desc");
                pt.pkg_type = DBClass.getField("select top 1 packagae_type from In_Patient where Patient_Id =" + PatientID + " and Discharge = 1 order by Created_Time desc");
                pt.pkg_namefordetails = DBClass.getField("select top 1 packagae_name from In_Patient where Patient_Id =" + PatientID + "  order by Created_Time desc");
                pt.pkg_typefordetails = DBClass.getField("select top 1 packagae_type from In_Patient where Patient_Id =" + PatientID + "  order by Created_Time desc");
                pt.In_Patient_Type = DBClass.getField("select top 1 Patient_Discount_Type from In_Patient where Patient_Id =" + PatientID + "  order by Created_Time desc");
                pt.Package_Type = DBClass.getField("select top 1 Package_type_id from In_Patient where Patient_Id =" + PatientID + "order by Created_Time desc");
                pt.Package_Name = DBClass.getField("select top 1 Package_Name_id from In_Patient where Patient_Id =" + PatientID + "order by Created_Time desc");
                if (pt.IsDisountAvailable.Contains("position")) pt.IsDisountAvailable = "false";
                pt.Address = pat.Permanent_Address;
                pt.Mobile = pat.Mobile1;
                var inpatid_adv = DBClass.getField("select In_Patient_ID from AR_Advances where Patient_ID=" + PatientID + "order by Advance_ID desc");
                if (inpatid_adv != "There is no row at position 0.")
                {
                    pt.advance_amount = DBClass.getField("select sum(Advance_Amount) from AR_Advances where In_Patient_ID=" + inpatid_adv);
                }

                var ipd_id = DBClass.getField("select In_Patient_ID from In_Patient where Patient_ID =" + PatientID + " order by In_Patient_ID desc");

                if (ipd_id != "There is no row at position 0.")
                {
                    pt.paid_amount = DBClass.getField("select sum(Received_Amount) from Ar_Billings where In_Patient_ID =" + ipd_id);
                    pt.Balance = DBClass.getField("select sum(Balance_Amount) from Ar_Billings where In_Patient_ID =" + ipd_id);
                }

                pt.Gender = db.GetDataValueName("Gender", pat.Gender);
                var Patientno = pat.Patient_No.ToString();
                var count = (db.Patients.Where(v => v.Patient_No == Convert.ToInt32(Patientno)).ToList());
                pt.Follow = count.Count.ToString();



                return pt;
            }
            else
                return pt;
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
            public string opdid { get; set; }
            public string pat_id { get; set; }

            public string IPD_Panel_ID { get; set; }

            public string OPD_Panel_Name { get; set; }

            public string IPD_Panel_Name { get; set; }

            public string IsDisountAvailable { get; set; }

            public string DiscountPercFromMaster { get; set; }

            public string DiscountAmountFromMaster { get; set; }
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
        public static string GetPackageDetails(int PackType, int packname)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            List<TestPackageDetials> listOfTest = new List<TestPackageDetials>();

            if (PackType == 01)
            {
                var doc_pack = (from m in db.DoctorPackages
                                join d in db.Doc_Packages_Details
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
                                }).ToList();
                return (new JavaScriptSerializer()).Serialize(doc_pack);
            }
            else if (PackType == 02)
            {
                var Dep_pack = (from m in db.DepartmentPackages
                                join d in db.Dep_Packages_Details
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
                                }).ToList();
                return (new JavaScriptSerializer()).Serialize(Dep_pack);
            }
            else if (PackType == 03)
            {
                var Panel_pack = (from m in db.PanelPackages
                                  join d in db.Pan_Packages_Details
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
                                join d in db.Doc_Packages_Details
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
                                join d in db.Dep_Packages_Details
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
                                  join d in db.Pan_Packages_Details
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
                         where t.Main_Department == "005"
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
            var tests = from t in db.Lab_Tests
                        where t.Main_Department == "001" && t.Active == true
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
                                  where vs.ValueSet_Name == "Test Groups" && dv.Division == "001"
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
            List<Receipt> rcpts = db.Receipts.Where(r => r.Bill_ID == Bill_ID).ToList();
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
    }
}