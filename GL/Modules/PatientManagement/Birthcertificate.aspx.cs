using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.PatientManagement
{
    public partial class Birthcertificate : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            //if (!IsPostBack)
            //{
            //    var id = Request.Url.PathAndQuery;
            //var s = Request.QueryString;
            //if (Request.QueryString["BC_ID"] != null)
            //{
            //    string QS = id.Split('=')[1];
            //    PopulateInPatientData(Convert.ToInt32(QS));
            //    //InPatient_Case_id = Convert.ToInt32(QS)/*;*/
            //}
            
             
            //}
        }
        private void PopulateInPatientData(int InPatient_ID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var data = (from bc in db.Birth_Certificates where bc.Birth_Certificate_ID == InPatient_ID select bc).FirstOrDefault();
                hdfPatient_IDs.Value = data.Patient_ID.ToString();

            }
        }

        public class Detail
        {
            public string Name;
            public string PatientType;
            public string Gender;
            public string Age;
            public string Mobile;
            public string NIC;
            public string Address;
            public string Entry_Date;
            public string AdvanceAmount;
            public string RevisitMsg { get; set; }
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
        [System.Web.Services.WebMethod]
        public static Detail GetDetail(string PatientID)
        {
            int Patien_No = DBClass.GetMRNOBy_RegID(Convert.ToInt32(PatientID));

            Detail pt = new Detail();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            Reg_patient pat = new Reg_patient();
            pat = (from tbl in db.Reg_patients
                   where tbl.Patient_No == Patien_No
                   orderby tbl.Created_time descending
                   select tbl).FirstOrDefault();
            var Type = (from tbl in db.In_Patients
                        where tbl.Patient_ID == int.Parse(PatientID)
                        && tbl.Discharge != true
                        orderby tbl.Created_Time descending
                        select tbl.Patient_Discount_Type).FirstOrDefault();
            var discharge_InPatient = db.In_Patients.Where(w => w.Patient_ID == pat.pat_id && w.Discharge == true && w.Discharge_On != null).OrderByDescending(w => w.Admission_Date).FirstOrDefault();

            if (pat != null)
            {
                pt.Name = pat.Full_Name;
                pt.Gender = pat.Gender;
                pt.Age = pat.Age_years.ToString();
                if (pat.Created_time.HasValue)
                    pt.Entry_Date = pat.Created_time.ToString();
                pt.Address = pat.Permanent_Address;
                pt.Mobile = pat.Mobile1;
                pt.NIC = pat.NIC;
                pt.Gender = db.GetDataValueName("Gender", pat.Gender);
                Type = db.GetDataValueName("Patient Type", Type);
                var inpatid = DBClass.getField("select In_Patient_ID from AR_Advances where Patient_ID=" + PatientID + "order by Advance_ID desc");

                return pt;
            }
            else
                return pt;
        }
        [WebMethod]
        public static string SavePatientDetail(string Full_Name, string RelationType, string Relation, string Gender, string Mobile, string Date_Of_Birth, string CNIC, string OtherCNIC, string Address, string PatientID, string martail_status, string Age, string txtfees)
        {
            DataBaseDataContext db = new DataBaseDataContext();
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
                    pat.Father_Name = Relation;
                    pat.Gender = Gender;
                    pat.Mobile1 = Mobile;
                    pat.Age_years = Age;
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
                    ;
                    pat.NIC = CNIC;
                    pat.other_cnic = OtherCNIC;
                    pat.Permanent_Address = Address;
                    pat.Martial_Status = martail_status;
                    pat.walkin = true;
                    pat.updated_by = AppConfig.UserID;
                    pat.updated_time = DateTime.Now;
                    db.SubmitChanges();
                }
            }
            else
            {
                pat = new Reg_patient();
                string PatientNumber = (DBClass.getMaxEntry_No("Reg_patient", "Patient_No")).ToString();
                pat.Patient_No = Convert.ToInt32(PatientNumber);
                pat.Full_Name = Full_Name;
                pat.Father_Name = Relation;
                pat.Relation_prefix = RelationType;
                pat.Gender = Gender;
                pat.Mobile1 = Mobile;
                pat.Age_years = Age;
                //pat.DOB = Convert.ToDateTime(Date_Of_Birth);
                pat.NIC = CNIC;
                pat.other_cnic = OtherCNIC;
                pat.Permanent_Address = Address;
                pat.Created_time = DateTime.Now;
                pat.Created_by = AppConfig.UserID;
                pat.iscancel = false;
                pat.Martial_Status = martail_status;
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
                pat.Card_fee = Convert.ToDecimal(txtfees);
                pat.walkin = true;
                db.Reg_patients.InsertOnSubmit(pat);
                db.SubmitChanges();
            }
            return pat.pat_id.ToString();
        }
        [WebMethod]
        public static string GetBirthCertificate(int Birth_Certificate_ID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var data = db.Birth_Certificates
                    .Where(x => x.Birth_Certificate_ID == Birth_Certificate_ID)
                    .Select(x => new
                    {
                        x.Birth_Certificate_ID,
                        x.Patient_ID,
                        x.Birth_Certificate_No,

                        // Child Information
                        x.Child_Name,
                        x.Gender,
                        x.Date_of_Birth,
                        x.Time_of_Birth,
                        x.Place_of_Birth,
                        x.Birth_Weight,
                        x.Birth_Type,
                        x.Birth_Order,

                        // Father Information
                        x.Father_Name,
                        x.Father_CNIC,
                        x.Father_Occupation,
                        x.Father_Nationality,

                        // Mother Information
                        x.Mother_Name,
                        x.Mother_CNIC,
                        x.Mother_Occupation,
                        x.Mother_Nationality,

                        // Registration Information
                        x.Registration_Number,
                        x.Registration_Date,
                        x.Registrar_Name,
                        x.Union_Council,

                        // Address Information
                        x.Address,
                        x.City,
                        x.Province,
                        x.Postal_Code,

                        // Additional Information
                        x.Religion,
                        x.Birth_Attendant,
                        x.Remarks,
                        x.IsGenerated
                    })
                    .FirstOrDefault();

                // Format Dates AFTER fetching from DB
                var result = new
                {
                    data.Birth_Certificate_ID,
                    data.Patient_ID,
                    data.Birth_Certificate_No,

                    // Child Information
                    data.Child_Name,
                    data.Gender,

                    Date_of_Birth = data.Date_of_Birth == null
                        ? ""
                        : Convert.ToDateTime(data.Date_of_Birth).ToString("MM/dd/yyyy"),

                    data.Time_of_Birth,
                    data.Place_of_Birth,
                    data.Birth_Weight,
                    data.Birth_Type,
                    data.Birth_Order,

                    // Father Information
                    data.Father_Name,
                    data.Father_CNIC,
                    data.Father_Occupation,
                    data.Father_Nationality,

                    // Mother Information
                    data.Mother_Name,
                    data.Mother_CNIC,
                    data.Mother_Occupation,
                    data.Mother_Nationality,

                    // Registration Information
                    data.Registration_Number,

                    Registration_Date = data.Registration_Date == null
                        ? ""
                        : Convert.ToDateTime(data.Registration_Date).ToString("MM/dd/yyyy"),

                    data.Registrar_Name,
                    data.Union_Council,

                    // Address Information
                    data.Address,
                    data.City,
                    data.Province,
                    data.Postal_Code,

                    // Additional Information
                    data.Religion,
                    data.Birth_Attendant,
                    data.Remarks,
                    data.IsGenerated
                };

                return Newtonsoft.Json.JsonConvert.SerializeObject(result);
            }
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
        public static string GetBirthType()
        {
            string data = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Birth Type"
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
        public static string GetProvince()
        {
            string data = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Province"
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
        public static string GetNationality()
        {
            string data = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Nationality"
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
        public static string GetReligion()
        {
            string data = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Religion"
                              select new
                              {
                                  dv.DataValue_Name,
                                  dv.DataValue_Description
                              }).ToList();
                data = new JavaScriptSerializer().Serialize(result);
            }
            return data;
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
            public string Reg_PatientID { get; set; }
        }

        [WebMethod]
        public static string CheckPatientDischarge(int patientId)
        {
            using (var db = new DataBaseDataContext())
            {
                var latestOutPatientDischarge = (
                    from op in db.Out_Patients
                    where op.Reg_PatId == patientId
                    orderby op.Created_Time descending
                    select op.Discharge
                ).FirstOrDefault();

                // Get latest emergency patient where Admission_Date is NOT null
                var latestEmergency = (
                    from ep in db.Emergency_Patients
                    where ep.Patient_ID == patientId && ep.Admission_Date != null
                    orderby ep.Admission_Date descending
                    select ep
                ).FirstOrDefault();

                bool blockedOpd = latestOutPatientDischarge == false;

                // Only block emergency if:
                // 1. There is an emergency record with Admission_Date NOT null, AND
                // 2. Discharge is false (or null treated as false/not discharged)
                bool blockedEmerg = false;
                if (latestEmergency != null)
                {
                    // If Discharge is false or null, patient is still admitted
                    blockedEmerg = latestEmergency.Discharge == false || latestEmergency.Discharge == null;
                }

                if (blockedOpd && blockedEmerg)
                {
                    return "{\"Status\":\"BLOCK\",\"Reason\":\"OPD_AND_EMERGENCY\"}";
                }
                if (blockedOpd)
                {
                    return "{\"Status\":\"BLOCK\",\"Reason\":\"OPD\"}";
                }
                if (blockedEmerg)
                {
                    return "{\"Status\":\"BLOCK\",\"Reason\":\"EMERGENCY\"}";
                }

                return "{\"Status\":\"ALLOW\",\"Reason\":\"NONE\"}";
            }
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
                }
                ;
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
        public static string SaveAllRecord(
int Patient_ID,
int Birth_Id,
string btnsave,
string BirthChildName,
string BirthGender,
string BirthDate,
string BirthTime,
string BirthPlace,
string BirthWeight,
string BirthType,
string BirthOrder,
string BirthFatherName,
string BirthFatherCNIC,
string BirthFatherOccupation,
string BirthFatherNationality,
string BirthMotherName,
string BirthMotherCNIC,
string BirthMotherOccupation,
string BirthMotherNationality,
string BirthRegNumber,
string BirthRegDate,
string BirthRegistrar,
string BirthUnionCouncil,
string BirthAddress,
string BirthCity,
string BirthProvince,
string BirthPostalCode,
string BirthReligion,
string BirthAttendant,
string BirthRemarks,
bool isCertificateGenrate)
        {
            Birth_Certificate OPD = null;

            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                int BirthCertificateID = 0;

                try
                {
                    // SAVE
                    if (btnsave == "Save")
                    {
                        OPD = new Birth_Certificate();

                        OPD.Patient_ID = Patient_ID;

                        OPD.Birth_Certificate_No = Convert.ToInt32(
                            DBClass.getMaxEntry_No("Birth_Certificate", "Birth_Certificate_No")
                        );

                        OPD.Created_By = AppConfig.UserID;
                        OPD.Created_Time = DateTime.Now;

                        db.Birth_Certificates.InsertOnSubmit(OPD);
                    }
                    // UPDATE
                    else
                    {
                        OPD = db.Birth_Certificates
                                .FirstOrDefault(x => x.Birth_Certificate_ID == Birth_Id);

                        if (OPD == null)
                        {
                            return "RECORD_NOT_FOUND";
                        }

                        OPD.Updated_By = AppConfig.UserID;
                        OPD.Updated_Time = DateTime.Now;
                    }

                    // =========================
                    // Child Information
                    // =========================

                    OPD.Child_Name = string.IsNullOrWhiteSpace(BirthChildName)
                        ? null
                        : BirthChildName.Trim();

                    OPD.Gender = string.IsNullOrWhiteSpace(BirthGender)
                        ? null
                        : BirthGender.Trim();

                    DateTime dob;
                    if (DateTime.TryParse(BirthDate, out dob))
                        OPD.Date_of_Birth = dob;
                    else
                        OPD.Date_of_Birth = null;

                    OPD.Time_of_Birth = string.IsNullOrWhiteSpace(BirthTime)
                        ? null
                        : BirthTime.Trim();

                    OPD.Place_of_Birth = string.IsNullOrWhiteSpace(BirthPlace)
                        ? null
                        : BirthPlace.Trim();

                    decimal weight;
                    if (decimal.TryParse(BirthWeight, out weight))
                        OPD.Birth_Weight = weight;
                    else
                        OPD.Birth_Weight = null;

                    OPD.Birth_Type = string.IsNullOrWhiteSpace(BirthType)
                        ? null
                        : BirthType.Trim();

                    OPD.Birth_Order = string.IsNullOrWhiteSpace(BirthOrder)
                        ? null
                        : BirthOrder.Trim();

                    // =========================
                    // Father Information
                    // =========================

                    OPD.Father_Name = string.IsNullOrWhiteSpace(BirthFatherName)
                        ? null
                        : BirthFatherName.Trim();

                    OPD.Father_CNIC = string.IsNullOrWhiteSpace(BirthFatherCNIC)
                        ? null
                        : BirthFatherCNIC.Trim();

                    OPD.Father_Occupation = string.IsNullOrWhiteSpace(BirthFatherOccupation)
                        ? null
                        : BirthFatherOccupation.Trim();

                    OPD.Father_Nationality = string.IsNullOrWhiteSpace(BirthFatherNationality)
                        ? null
                        : BirthFatherNationality.Trim();

                    // =========================
                    // Mother Information
                    // =========================

                    OPD.Mother_Name = string.IsNullOrWhiteSpace(BirthMotherName)
                        ? null
                        : BirthMotherName.Trim();

                    OPD.Mother_CNIC = string.IsNullOrWhiteSpace(BirthMotherCNIC)
                        ? null
                        : BirthMotherCNIC.Trim();

                    OPD.Mother_Occupation = string.IsNullOrWhiteSpace(BirthMotherOccupation)
                        ? null
                        : BirthMotherOccupation.Trim();

                    OPD.Mother_Nationality = string.IsNullOrWhiteSpace(BirthMotherNationality)
                        ? null
                        : BirthMotherNationality.Trim();

                    // =========================
                    // Registration Information
                    // =========================

                    OPD.Registration_Number = string.IsNullOrWhiteSpace(BirthRegNumber)
                        ? null
                        : BirthRegNumber.Trim();

                    DateTime regDate;
                    if (DateTime.TryParse(BirthRegDate, out regDate))
                        OPD.Registration_Date = regDate;
                    else
                        OPD.Registration_Date = null;

                    OPD.Registrar_Name = string.IsNullOrWhiteSpace(BirthRegistrar)
                        ? null
                        : BirthRegistrar.Trim();

                    OPD.Union_Council = string.IsNullOrWhiteSpace(BirthUnionCouncil)
                        ? null
                        : BirthUnionCouncil.Trim();

                    // =========================
                    // Address Information
                    // =========================

                    OPD.Address = string.IsNullOrWhiteSpace(BirthAddress)
                        ? null
                        : BirthAddress.Trim();

                    OPD.City = string.IsNullOrWhiteSpace(BirthCity)
                        ? null
                        : BirthCity.Trim();

                    OPD.Province = string.IsNullOrWhiteSpace(BirthProvince)
                        ? null
                        : BirthProvince.Trim();

                    OPD.Postal_Code = string.IsNullOrWhiteSpace(BirthPostalCode)
                        ? null
                        : BirthPostalCode.Trim();

                    // =========================
                    // Additional Information
                    // =========================

                    OPD.Religion = string.IsNullOrWhiteSpace(BirthReligion)
                        ? null
                        : BirthReligion.Trim();

                    OPD.Birth_Attendant = string.IsNullOrWhiteSpace(BirthAttendant)
                        ? null
                        : BirthAttendant.Trim();

                    OPD.Remarks = string.IsNullOrWhiteSpace(BirthRemarks)
                        ? null
                        : BirthRemarks.Trim();

                    OPD.IsGenerated = isCertificateGenrate;

                    // =========================
                    // SAVE CHANGES
                    // =========================

                    db.SubmitChanges();

                    // =========================
                    // NADRA Integration
                    // =========================

                    if (isCertificateGenrate)
                    {
                       // SendBirthCertificateToNadra(db, OPD);
                        db.SubmitChanges();
                    }

                    BirthCertificateID = OPD.Birth_Certificate_ID;

                    return BirthCertificateID.ToString();
                }
                catch (Exception ex)
                {
                    return ex.Message;
                }
            }
        }


        private static void SendBirthCertificateToNadra(DataBaseDataContext db, Birth_Certificate patient)
        {
            if (db == null || patient == null)
                return;

            Func<string, string> normalizeGender = g =>
            {
                var value = (g ?? string.Empty).Trim().ToLowerInvariant();
                if (value == "m" || value == "male") return "male";
                if (value == "f" || value == "female") return "female";
                return value;
            };

            string baseUrl = DBClass.getField("SELECT Code FROM sys_Parms WHERE Name = 'NADRA_API_BaseUrl'");
            string username = DBClass.getField("SELECT Code FROM sys_Parms WHERE Name = 'NADRA_API_Username'");
            string password = DBClass.getField("SELECT Code FROM sys_Parms WHERE Name = 'NADRA_API_Password'");
            string hospitalName = DBClass.getField("SELECT Code FROM sys_Parms WHERE Name = 'NADRA_API_HospitalName'");
            string hospitalAddress = DBClass.getField("SELECT Code FROM sys_Parms WHERE Name = 'NADRA_API_HospitalAddress'");

            if (string.IsNullOrWhiteSpace(baseUrl) || string.IsNullOrWhiteSpace(username) || string.IsNullOrWhiteSpace(password))
                return;

            baseUrl = baseUrl.Trim().TrimEnd('/');

            var authPayload = new
            {
                username = username,
                password = password
            };

            string fatherIdentity = string.IsNullOrWhiteSpace(patient.Father_CNIC) ? "" : patient.Father_CNIC.Trim();
            string motherIdentity = string.IsNullOrWhiteSpace(patient.Mother_CNIC) ? "" : patient.Mother_CNIC.Trim();

            string contactNumber = "";
            var regPatient = db.Reg_patients.FirstOrDefault(r => r.pat_id == patient.Patient_ID);
            if (regPatient != null && !string.IsNullOrWhiteSpace(regPatient.Mobile1))
            {
                contactNumber = regPatient.Mobile1;
            }

            string doctorName = "";
            int doctorId;
            //if (!string.IsNullOrWhiteSpace(patient.Doctor) && int.TryParse(patient.Doctor, out doctorId))
            //{
            //    doctorName = db.HR_Employees.Where(e => e.Emp_ID == doctorId).Select(e => e.Emp_Name).FirstOrDefault();
            //}

            var birthData = new
            {
                BirthData = new
                {
                    refNumber = string.IsNullOrWhiteSpace(patient.Registrar_Name) ? patient.Birth_Certificate_ID.ToString() : patient.Registration_Number,
                    hospitalName = string.IsNullOrWhiteSpace(hospitalName) ? "" : hospitalName,
                    hospitalAddress = string.IsNullOrWhiteSpace(hospitalAddress) ? "" : hospitalAddress,
                    issuanceDate = DateTime.Now.ToString("dd/MM/yyyy"),
                    childName = patient.Child_Name ?? "",
                    childDateofBirth = patient.Date_of_Birth.HasValue
                        ? patient.Date_of_Birth.Value.ToString("d/M/yyyy", CultureInfo.InvariantCulture)
                        : DateTime.Now.ToString("d/M/yyyy", CultureInfo.InvariantCulture),
                    childGender = normalizeGender(patient.Gender),
                    placeofOccurrence = "hospital",
                    placeofBirth = patient.Place_of_Birth ?? "",
                    districtofBirth = patient.City ?? "",
                    typeofBirth = string.IsNullOrWhiteSpace(patient.Birth_Type) ? "Single" : patient.Birth_Type,
                    disability = "N",
                    fatherName = patient.Father_Name ?? "",
                    motherName = patient.Mother_Name ?? "",
                    FatherIdentityType = "cnic",
                    FatherIdentityValue = fatherIdentity,
                    MotherIdentityType = "cnic",
                    MotherIdentityValue = motherIdentity,
                    motherBloodGroup = "",
                    childBloodGroup = "",
                    contactNumber = contactNumber ?? "",
                    doctorName = doctorName ?? "",
                    registrationNo = ""
                }
            };

            using (var client = new HttpClient())
            {
                var authJson = new JavaScriptSerializer().Serialize(authPayload);
                var authContent = new StringContent(authJson, Encoding.UTF8, "application/json");
                var authResponse = client.PostAsync(baseUrl + "/User/Authenticate", authContent).Result;
                var authResponseString = authResponse.Content.ReadAsStringAsync().Result;
                var authResult = new JavaScriptSerializer().Deserialize<Dictionary<string, object>>(authResponseString);

                string token = authResult != null && authResult.ContainsKey("token") && authResult["token"] != null
                    ? authResult["token"].ToString()
                    : "";

                if (string.IsNullOrWhiteSpace(token))
                    return;

                client.DefaultRequestHeaders.Clear();
                client.DefaultRequestHeaders.Add("Authorization", "Bearer " + token);

                var birthJson = new JavaScriptSerializer().Serialize(birthData);
                var birthContent = new StringContent(birthJson, Encoding.UTF8, "application/json");
                var birthResponse = client.PostAsync(baseUrl + "/HealthUnits/BirthData/Save", birthContent).Result;
                var birthResponseString = birthResponse.Content.ReadAsStringAsync().Result;
                var birthResult = new JavaScriptSerializer().Deserialize<Dictionary<string, object>>(birthResponseString);

                string code = birthResult != null && birthResult.ContainsKey("code") && birthResult["code"] != null
                    ? birthResult["code"].ToString()
                    : "";

                string trackingId = birthResult != null && birthResult.ContainsKey("trackingId") && birthResult["trackingId"] != null
                    ? birthResult["trackingId"].ToString()
                    : "";

                if (string.IsNullOrWhiteSpace(trackingId))
                {
                    throw new Exception("NADRA error: trackingId is null or empty.");
                }

                patient.NADRA_Response = birthResponseString;

                if (code == "100" || code == "200")
                {
                    patient.Is_Sent_To_NADRA = true;
                    patient.Sent_Date = DateTime.Now;
                }

                patient.Tracking_ID = trackingId; 
            }
        }
    }
}