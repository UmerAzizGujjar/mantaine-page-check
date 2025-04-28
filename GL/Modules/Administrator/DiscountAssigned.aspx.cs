using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Services;
using System.Web.Script.Serialization;
using System.Text;
namespace PMS
{
    public partial class DiscountAssigned : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

            if (!IsPostBack)
            {
                txtValid_date.Text = DateTime.Now.Date.ToString(AppConfig.DateFormat);
               
                BindingDropDown();
            }
        }

        private void BindingDropDown()
        {
            object valueset;
            valueset = DBClass.GetValueSet("Discount Category");
            ddlDiscountCAtegory.DataSource = valueset;
            ddlDiscountCAtegory.DataTextField = "DataValue_Description";
            ddlDiscountCAtegory.DataValueField = "DataValue_Name";
            ddlDiscountCAtegory.Items.Add(new ListItem("Select", "0"));
            ddlDiscountCAtegory.DataBind();

        }
        [WebMethod]
        public static string LoadDiscountCategory()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var Routes = from d in db.DataValues
                         join v in db.ValueSets
                         on d.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Name == "Category Discount Type"
                         select new
                         {
                             d.DataValue_Name,
                             d.DataValue_Description,

                         };
            return (new JavaScriptSerializer().Serialize(Routes));
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
            public string existing { get; set; }

            public int Discount_Definition_Id { get; set; }
            public string In_patient_ID { get; set; }


        }
        public class Details
        {
            public int patient_Id { get; set; }
            public string discount_Categ { get; set; }
            public string form_no { get; set; }
            public string code { get; set; }
            public string name { get; set; }
            public string remarks { get; set; }
            public DateTime txtvalid_date;

            public string ddlCat { get; set; }
            public List<List> List { get; set; }
        }
        public class List
        {
            public string DepartName { get; set; }

            public string DepartType { get; set; }
            public string DepartId { get; set; }
            public string Exp_Days { get; set; }
            public string Percentage { get; set; }
            public string Amount { get; set; }

            public string validfor { get; set; }

            public string RemainAmount { get; set; }

        }

        [WebMethod]
        public static string LoadDiscountAssignedDetail(string id)
        {

            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());


            var query = (from tbl in db.Discount_Assigned_Patients
                         join tbl2 in db.Discount_Assigned_Patient_Details on tbl.Discount_Assigned_Patient_Id equals tbl2.Discount_Assigned_Patient_Id
                         where tbl.Discount_Assigned_Patient_Id == Convert.ToInt32(id)
                         select new
                         {
                             tbl.Discount_Category_Id,
                             tbl2.Department_Id,
                             tbl2.Department_Name,
                             tbl2.Department_Type,
                             tbl2.Discount_Assigned_Patient_Id,
                             tbl2.Discount_Amount,
                             tbl2.Discount_Percentage,
                             tbl2.Valid_for,
                             tbl2.Expired_Days,
                             tbl.Patient_Id,
                             tbl.Form_no,
                             tbl.Emp_Name,
                             tbl.discount_validity_date,
                             tbl.Code,
                             tbl.Remarks,
                             tbl2.Remaining_Amount,
                            tbl.Category,
                         }).ToList();



            return (new JavaScriptSerializer().Serialize(query));

        }
        [WebMethod]
        public static string GetDiscount()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var query = (from users in db.aspnet_Users.Where(x=>x.UserId==AppConfig.UserID)
                         select new
                         {
                             users.UserId,
                             users.UserName,
                             Discount = DBClass.getField("select Discount from aspnet_Users where UserId='" + users.UserId + "'"),
                             Discount_Amt = DBClass.getField("select Discount_Amount from aspnet_Users where UserId='" + users.UserId + "'"),
                         }).FirstOrDefault();
            return (new JavaScriptSerializer().Serialize(query));
        }
        [WebMethod]
        public static string SaveDicountAssigned(string btnSave, string id, string Details)
        {
            var primary_id = 0;
            DataBaseDataContext db = new DataBaseDataContext();
            JavaScriptSerializer js = new JavaScriptSerializer();
            var ServiceDetailList = js.Deserialize<Details>(Details);
            if (btnSave == "Save")
            {
                Discount_Assigned_Patient DD = new Discount_Assigned_Patient();
                DD.Discount_Category_Id = ServiceDetailList.discount_Categ;
                DD.Category = ServiceDetailList.ddlCat;
                DD.Code = ServiceDetailList.code;
                DD.Created_by = AppConfig.UserID;
                DD.Created_Time = DateTime.Now;
                DD.Emp_Name = ServiceDetailList.name;
                if (ServiceDetailList.form_no == "" || ServiceDetailList.form_no == null)
                {

                }
                else
                {
                    DD.Form_no = Convert.ToInt32(ServiceDetailList.form_no);
                }
              //  DD.Form_no = Convert.ToInt32(ServiceDetailList.form_no);
                DD.Remarks = ServiceDetailList.remarks;
                DD.discount_validity_date = ServiceDetailList.txtvalid_date;
                DD.Patient_Id = ServiceDetailList.patient_Id;
               
                db.Discount_Assigned_Patients.InsertOnSubmit(DD);
                db.SubmitChanges();
                primary_id = DD.Discount_Assigned_Patient_Id;
                //DBClass.getMaxEntry_No("Discount_Definition", "discount_Definition_Id");

            }
            else
            {
                var data = (from s in db.Discount_Assigned_Patients.Where(s => s.Discount_Assigned_Patient_Id == Convert.ToInt32(id)) select s).FirstOrDefault();
                data.Category = ServiceDetailList.ddlCat;
                data.Code = ServiceDetailList.code;
                data.Created_by = AppConfig.UserID;
                data.Created_Time = DateTime.Now;
                data.Emp_Name = ServiceDetailList.name;
                data.Discount_Category_Id = ServiceDetailList.discount_Categ;
                data.discount_validity_date = ServiceDetailList.txtvalid_date;

                if (ServiceDetailList.form_no == "" || ServiceDetailList.form_no == null)
                {
                }
                else
                {
                    data.Form_no = Convert.ToInt32(ServiceDetailList.form_no);
                }
                data.Remarks = ServiceDetailList.remarks;
                data.Patient_Id = ServiceDetailList.patient_Id;
                db.SubmitChanges();
                primary_id = Convert.ToInt32(data.Discount_Assigned_Patient_Id);
                //var datas = (from s in db.Discount_Definition_Details.Where(s => s.Discount_Definition_Id == Convert.ToInt32(id)) select s).ToList();
                //foreach (var item in ServiceDetailList.List)
                //{

                //}


            }
            if (btnSave == "Update")
            {
                var datas = (from s in db.Discount_Assigned_Patient_Details.Where(s => s.Discount_Assigned_Patient_Id == Convert.ToInt32(id)) select s).ToList();
                db.Discount_Assigned_Patient_Details.DeleteAllOnSubmit(datas);
                db.SubmitChanges();


            }
            var Primary_id = primary_id;
            foreach (var item in ServiceDetailList.List)
            {
                Discount_Assigned_Patient_Detail ipser = new PMS.Discount_Assigned_Patient_Detail();
                ipser.Department_Id = item.DepartId;
                ipser.Department_Name = item.DepartName;
                ipser.Department_Type = item.DepartType;
                if (item.Percentage == "") item.Percentage = "0.00";
                ipser.Discount_Percentage = Convert.ToDecimal(item.Percentage);
                if (item.Amount == "") item.Amount = "0.00";
                ipser.Discount_Amount = Convert.ToDecimal(item.Amount);
                ipser.Expired_Days = item.Exp_Days;
                if (item.RemainAmount == "") item.RemainAmount = "0.00";
                ipser.Remaining_Amount = Convert.ToDecimal(item.RemainAmount);
                ipser.Discount_Assigned_Patient_Id = primary_id;
                if (item.validfor == null || item.validfor == "")
                {
                }
                else
                {
                    ipser.Valid_for = Convert.ToDateTime(item.validfor);
                }
                ipser.Discount_Assigned_Patient_Id = Primary_id;
                db.Discount_Assigned_Patient_Details.InsertOnSubmit(ipser);
                db.SubmitChanges();
            }

            return primary_id.ToString();

        }

        //     [WebMethod]
        //public static bool IsPatientExists(string PatientID)
        //{  DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
        //    bool isexist = false;
        //    var result = (from data in db.Discount_Assigned_Patients.Where(x => x.Patient_Id.Equals(PatientID)) select data.Patient_Id).FirstOrDefault();
        //    if (result == null)
        //    {

        //        isexist = false;
        //    }
        //    else 
        //    {
        //        isexist = true;
        //    }
        //    return isexist;
        //     }

        [WebMethod]
        public static bool IsPatientExists(string PatientID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            bool isexist = false;
            DateTime currentDate = DateTime.Now;
            //DateTime discountValidityDate = DateTime.ParseExact("2023-10-03 00:00:00.000", "yyyy-MM-dd HH:mm:ss.fff", CultureInfo.InvariantCulture);
            var result = (
                from data in db.Discount_Assigned_Patients
                where data.Patient_Id == Convert.ToInt32(PatientID) && data.discount_validity_date >= currentDate
                select data.Patient_Id
            ).FirstOrDefault();

            if (result == null)
            {
                isexist = false;
            }
            else
            {
                isexist = true;
            }

            return isexist;
        }

        [WebMethod]
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
                if (Type == null)
                {
                    pt.In_patient_ID = "0";
                }
                else
                {
                    pt.In_patient_ID = Type.In_Patient_ID.ToString();
                }
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
                //pt.OPD_Panel_ID = pat.Panel_Companies;
                //if (pat.Panel_Companies == null || pat.Panel_Companies == "null") pat.Panel_Companies = "0";
                //pt.OPD_Panel_Name = DBClass.getField("select Company_Name from Panel where Panel_ID=" + pat.Panel_Companies);
                //var patient_Admit_Category_For_Revisit_Case = (from p in db.Patients
                //                                               where p.Patient_No == Convert.ToInt32(Patientno)
                //                                               orderby p.Patient_ID ascending
                //                                               select p).ToList();
                //var Previous_inpatient = "0";
                //pt.Previous_inpatient = "0";
                //foreach (var item in patient_Admit_Category_For_Revisit_Case)
                //{
                //    var discount_type = DBClass.getField("select  Patient_Discount_Type from In_Patient where discharge=0 and Patient_ID=" + item.Patient_ID);
                //    var Patient_ID = DBClass.getField("select  Patient_ID from In_Patient where discharge=0 and Patient_ID=" + item.Patient_ID);
                //    if (discount_type.Contains("position"))
                //    {
                //        //  pt.Previous_inpatient = Previous_inpatient;
                //    }
                //    else
                //    {
                //        Previous_inpatient = discount_type;
                //        pt.Previous_inpatient = Patient_ID;
                //    }
                //}

                //  pt.Patient_Discount_Type = db.GetDataValueName("Patient Type", Previous_inpatient.ToString());
                // pt.isInpatient = false;

                if (Type != null)
                {

                }

                return pt;
            }
            else
                return pt;
        }





        [WebMethod]
        public static string GetDiscount_Detail(string id)
        {
            
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
         

          var query = (from tbl in db.Discount_Definitions
                   join tbl2 in db.Discount_Definition_Details on tbl.Discount_Definition_Id equals tbl2.Discount_Definition_Id
                   where tbl.Discount_Category_Id == id
                       select new
                   {
                           tbl.Discount_Category_Id,
                           tbl2.Department_Id,
                           tbl2.Department_Name,
                           tbl2.Department_Type,
                           tbl2.Discount_Definition_Detail_id,
                           tbl2.Discount_Amount,
                           tbl2.Discount_Percentage,
                           tbl2.Valid_for,
                           tbl2.Expired_Days,
                           

                       }).ToList();



            return (new JavaScriptSerializer().Serialize(query));

        }


    }

}