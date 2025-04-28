using System;
using System.Data;
using System.Linq;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI.WebControls;



namespace PMS
{
    public partial class AddStudent : System.Web.UI.Page
    {

        protected System.Web.UI.HtmlControls.HtmlInputFile fileupload;
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static string GetPrograms()
        {
            DataBaseDataContext db = new DataBaseDataContext();

            string data = string.Empty;
            var listItems = (from p in db.DataValues
                             join v in db.ValueSets on p.ValueSet_ID equals v.ValueSet_ID
                             where v.ValueSet_Description == "Admission Category"
                             select new
                             {
                                 DataValueName = p.DataValue_Name,
                                 DataValueDescription = p.DataValue_Description,
                             }).ToList();

            return (new JavaScriptSerializer()).Serialize(listItems);
        } 
        [WebMethod]
        public static string GetGl_Accounts()
        {
            DataBaseDataContext db = new DataBaseDataContext();

            string data = string.Empty;
            var listItems = (from p in db.GL_Accounts
                             where p.Levels == 4
                             select new
                             {
                                 DataValueName = p.Account_ID,
                                 DataValueDescription = p.Account_Name,
                             }).ToList();

            return (new JavaScriptSerializer()).Serialize(listItems);
        }

        [WebMethod]
        public static string LoadStudentData(int Stu_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var StudentData = (from a in db.Reg_Students
                               where a.Student_Id == Stu_ID
                               select new
                               {
                                   a.Student_Id,
                                   a.Roll_No,
                                   a.Admission,
                                   a.Full_Name,
                                   a.Father_Name,
                                   a.Guardian_Name,
                                   a.Current_Adress,
                                   a.Student_Contact_No,
                                   a.Father_Contact_No,
                                   a.Permanent_Address,
                                   a.DOB,
                                   a.Email_Adress,
                                   a.Student_CNIC,
                                   a.BloodGroup,
                                   a.Domicile,
                                   a.Father_CNIC,
                                   a.Chronic_disease_Allergy,
                                   a.Studies_Status,
                                   a.Program,
                                   a.Batch,
                                   a.Groups,
                                   a.Whole_Class,
                                   a.Class,
                                   a.Sesion,
                                   a.Is_Active,
                                   a.Picture,
                                   a.CreatedTime,
                                   a.CreatedBy,
                                   a.AdmissionDate,
                                   a.UpdatedBy,
                                   a.UpdateTime,
                                   a.Account_id,

                               }).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(StudentData);
        }
        [WebMethod]
        public static string GetStudentClass()
        {
            DataBaseDataContext db = new DataBaseDataContext();
         
            string data = string.Empty;
            var listItems = (from p in db.DataValues
                             join v in db.ValueSets on p.ValueSet_ID equals v.ValueSet_ID
                             where v.ValueSet_Description == "Student Class"
                             select new
                             {
                                 DataValueName = p.DataValue_Name,
                                 DataValueDescription = p.DataValue_Description,
                             }).ToList();

            return (new JavaScriptSerializer()).Serialize(listItems);
        }
        //getbacth
        [WebMethod]
        public static string StudentBatch()
        {
            DataBaseDataContext db = new DataBaseDataContext();
      
            string data = string.Empty;
            var listItems = (from p in db.DataValues
                             join v in db.ValueSets on p.ValueSet_ID equals v.ValueSet_ID
                             where v.ValueSet_Description == "Batch"
                             select new
                             {
                                 DataValueName = p.DataValue_Name,
                                 DataValueDescription = p.DataValue_Description,
                             }).ToList();

            return (new JavaScriptSerializer()).Serialize(listItems);
        }
        [WebMethod]
        public static string StudentGroup()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var valuset = DBClass.GetValueSet("Group");


            return (new JavaScriptSerializer()).Serialize(valuset);
        }
        [WebMethod]
        public static string BloodGroup()

        {
            DataBaseDataContext db = new DataBaseDataContext();
            //List<ddlListItems> listItems = new List<ddlListItems>();
            string data = string.Empty;
            var listItems = (from p in db.DataValues
                             join v in db.ValueSets on p.ValueSet_ID equals v.ValueSet_ID
                             where v.ValueSet_Description == "Blood Group"
                             select new
                             {
                                 DataValueName = p.DataValue_Name,
                                 DataValueDescription = p.DataValue_Description,
                             }).ToList();

            return (new JavaScriptSerializer()).Serialize(listItems);
        }
        [WebMethod]
        public static string SaveStudentData(string btnsave, string AllItemDetail)
        {
            string studentRegId = "";
            Reg_Student stud = new Reg_Student();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            JavaScriptSerializer serialize = new JavaScriptSerializer();
            var record = serialize.Deserialize<MasterList>(AllItemDetail);

            if (btnsave == "Update")
            {

                var lstItem = (from a in db.Reg_Students
                               where a.Student_Id == Convert.ToInt32(record.Student_Id)
                               select a).FirstOrDefault();

                lstItem.UpdatedBy = AppConfig.UserID;
                lstItem.UpdateTime = DateTime.Now;
                lstItem.Roll_No = record.Rollnum;
                lstItem.Admission = record.admission;
                lstItem.Full_Name = record.fullname;
                lstItem.Father_Name = record.Father_Name;
                lstItem.Guardian_Name = record.Guard_Name;
                lstItem.Current_Adress = record.Cust_Address;
                lstItem.Account_id = record.Gl_code;
                lstItem.Student_Contact_No = record.StdCntct_No;
                lstItem.Father_Contact_No = record.Fcntc_No;
                lstItem.Permanent_Address = record.Per_Address;
                lstItem.Email_Adress = record.EmailAdrr;
                lstItem.DOB = Convert.ToDateTime(record.txt_Date);
                lstItem.AdmissionDate = Convert.ToDateTime(record.txtadmDate);
                lstItem.Student_CNIC = record.St_CNIC;
                lstItem.BloodGroup = record.Bld_group;
                lstItem.Domicile = record.Domicile;
                lstItem.Father_CNIC = record.Ft_CNIC;
                lstItem.Chronic_disease_Allergy = record.txtDisease_alergy;
                lstItem.Studies_Status = record.Std_Status;
                lstItem.Program = record.ddlProgram;
                lstItem.Batch = record.ddlBatch;
                lstItem.Groups = record.ddlGroup;
                lstItem.Whole_Class = Convert.ToBoolean(record.txt_WholeClass);
                lstItem.Class = record.ddlClass;
                lstItem.Sesion = record.txtSession;
                lstItem.Is_Active = Convert.ToBoolean(record.Is_Active);
                db.SubmitChanges();
                studentRegId = lstItem.Student_Id.ToString();

            }
            else
            {
                stud.Roll_No = record.Rollnum;
                stud.Admission = record.admission;
                stud.Full_Name = record.fullname;
                stud.Father_Name = record.Father_Name;
                stud.Guardian_Name = record.Guard_Name;
                stud.Current_Adress = record.Cust_Address;
                stud.Student_Contact_No = record.StdCntct_No;
                stud.Account_id = record.Gl_code;
                stud.Father_Contact_No = record.Fcntc_No;
                stud.Permanent_Address = record.Per_Address;
                stud.Email_Adress = record.EmailAdrr;
                stud.DOB = Convert.ToDateTime(record.txt_Date);
                stud.AdmissionDate = Convert.ToDateTime(record.txtadmDate);
                stud.Student_CNIC = record.St_CNIC;
                stud.BloodGroup = record.Bld_group;
                stud.Domicile = record.Domicile;
                stud.Father_CNIC = record.Ft_CNIC;
                stud.Chronic_disease_Allergy = record.txtDisease_alergy;
                stud.Studies_Status = record.Std_Status;
                stud.Program = record.ddlProgram;
                stud.Batch = record.ddlBatch;
                stud.Groups = record.ddlGroup;
                stud.Whole_Class = Convert.ToBoolean(record.txt_WholeClass);
                stud.Class = record.ddlClass;
                stud.Sesion = record.txtSession;
                stud.Is_Active = Convert.ToBoolean(record.Is_Active);
                stud.CreatedBy = AppConfig.UserID;
                stud.CreatedTime = DateTime.Now;
                db.Reg_Students.InsertOnSubmit(stud);
                db.SubmitChanges();
                studentRegId = stud.Student_Id.ToString();
            }

            return studentRegId;
        }

        public class MasterList
        {
            public string Student_Id { get; set; }
            public string Rollnum { get; set; }
            public string admission { get; set; }
            public string fullname { get; set; }
            public string Father_Name { get; set; }
            public string Guard_Name { get; set; }
            public string Cust_Address { get; set; }
            public string StdCntct_No { get; set; }
            public string Fcntc_No { get; set; }
            public string Per_Address { get; set; }
            public string EmailAdrr { get; set; }
            public DateTime txt_Date { get; set; }
            public DateTime txtadmDate { get; set; }
            public string St_CNIC { get; set; }
            public string Bld_group { get; set; }
            public string Domicile { get; set; }
            public string Ft_CNIC { get; set; }
            public string txtDisease_alergy { get; set; }
            public string Std_Status { get; set; }
            public string ddlProgram { get; set; }
            public string ddlBatch { get; set; }
            public string ddlGroup { get; set; }
            public bool txt_WholeClass { get; set; }
            public string ddlClass { get; set; }
            public string txtSession { get; set; }
            public int Gl_code { get; set; }
            public bool Is_Active { get; set; }
        }
    }
}
