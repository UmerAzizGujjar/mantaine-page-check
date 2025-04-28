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
    public partial class BloodTransfusionForm : System.Web.UI.Page
    {
        protected static int lastId = -1;
        protected static int QueryString = -1;
        protected void Page_Load(object sender, EventArgs e)
        {
            QueryString =Convert.ToInt32(Request.QueryString["ID"]);
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
            if (pat != null)
            {
                pt.Name = pat.Full_Name;
                pt.Gender = pat.Gender;
                pt.Age = pat.Age_years.ToString();
                if (pat.Created_time.HasValue)
                    pt.Entry_Date = pat.Created_time.ToString();
                pt.Address = pat.Permanent_Address;
                pt.Mobile = pat.Mobile1;
                pt.Entry_Date = pat.Created_time.ToString();
                //pt.department = pat.Patient_Main_Category;
                //pt.department = DBClass.getPatientLatestDepartment(Convert.ToInt32(pat.Patient_No), true).ToString();
                //pt.Patient_type =  db.GetDataValueName("Patient Type", Type);
                pt.Gender = db.GetDataValueName("Gender", pat.Gender);
                var Patientno = pat.Patient_No.ToString();
                var count = (db.Reg_patients.Where(v => v.Patient_No == Convert.ToInt32(Patientno)).ToList());
                pt.Follow = count.Count.ToString();
                return pt;
            }
            else
                return pt;
        }

        [WebMethod]
        public static object GetTransfusion_Result(int id)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var query = db.sp_GetTransfusion_Result(id);

            return query;

        }

        [WebMethod]
        public static string appedddl()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Record = (from dv in db.DataValues
                          join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                          where vs.ValueSet_Name == "Component" 

                          select new
                          {
                              dv.DataValue_ID,
                              dv.DataValue_Description,
                              dv.DataValue_Name,
                              vs.ValueSet_Description
                          }).ToList();
            return (new JavaScriptSerializer()).Serialize(Record);
        }

        [System.Web.Services.WebMethod]
        public static string SaveAll(string btnSave, string Patient_id, bool ywristband, bool nwristband, bool ybenefits, bool nbenefits, bool ybloodbag, bool nbloodbag, bool yleakage, bool nleakage, bool yexpiry, bool nexpiry, bool yinstruction, bool ninstruction, bool yreaction, bool nreaction, bool ypregnancy, bool npregnancy, string component, string units, string Date, string Time, string sDoc, string indication, string id,string onDutyDoctor,string PatientGuardian,string WitnessSignature,string WitnessCnic,string WitnessName, List<CheckList> checkList)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            try
            {
                Blood_Transfusion DT;
                //Master
                if (btnSave == "Save")
                {
                    DT = new Blood_Transfusion();
                    DT.Created_By = AppConfig.UserID;
                    DT.Created_Time = DateTime.Now;

                }
                else 
                {
                    lastId = Convert.ToInt32(id);
                    DT = (from tbl in db.Blood_Transfusions
                          where tbl.BTR_Id ==Convert.ToInt32(id)
                          select tbl).FirstOrDefault();
            
                    DT.Update_By = AppConfig.UserID;
                    DT.Updated_Time = DateTime.Now;
                      
                
                }
                DT.BTR_benefitN = nbenefits;
                DT.BTR_benefitY = ybenefits;
                DT.BTR_bloodN = nbloodbag;
                DT.BTR_bloodY = ybloodbag;
                DT.BTR_components = component;
                DT.BTR_doctor = sDoc;
                DT.BTR_expN = nexpiry;
                DT.BTR_expY = yexpiry;
                DT.BTR_indication = indication;
                DT.BTR_insN = ninstruction;
                DT.BTR_insY = yinstruction;
                DT.BTR_leakageN = nleakage;
                DT.BTR_leakageY = yleakage;
                DT.BTR_pregN = npregnancy;
                DT.BTR_pregY = ypregnancy;
                DT.BTR_Transfusion_ReactionN = nreaction;
                DT.BTR_Transfusion_ReactionY = yreaction;
                DT.onDutyDoctor = onDutyDoctor;
                DT.PatientGuardian = PatientGuardian;
                DT.WitnessCnic = WitnessCnic;
                DT.WitnessName = WitnessName;
                DT.WitnessSignature = WitnessSignature;
                DT.BTR_units = units;
                if (Date == "")
                {
                
                }
                else
                {
                
                DT.BTR_what_Date = Convert.ToDateTime(Date);
                }

                if (Time == "")
                {
                }
                else
                {
                    DT.BTR_what_Time = Convert.ToDateTime(Time);
                }
               
                DT.BTR_wristN = nwristband;
                DT.BTR_wristY = ywristband;
                DT.Patient_Id =Convert.ToInt32(Patient_id);
                if (btnSave == "Save")
                {
                    db.Blood_Transfusions.InsertOnSubmit(DT);
                  
                }
                db.SubmitChanges();
                if (btnSave == "Save")
                {

                    var getMaxVal = (Convert.ToInt32(db.Blood_Transfusions.Max(p => p.BTR_Id)));
                    lastId = getMaxVal;
                }

                //Detail
                Blood_Transfusion_CheckList BTC;
                if (btnSave == "Update") 
                {
                    var Blood_Transfusion =
                        from Blood_Transfusion_CheckLists in db.Blood_Transfusion_CheckLists
                        where
                          Blood_Transfusion_CheckLists.BTR_Id == lastId
                        select Blood_Transfusion_CheckLists;
                    foreach (var del in Blood_Transfusion)
                    {
                        db.Blood_Transfusion_CheckLists.DeleteOnSubmit(del);
                    }
                    db.SubmitChanges();
                }
                foreach (var item in checkList)
                {
                    BTC = new Blood_Transfusion_CheckList();
                    BTC.BTR_Id = lastId;
                    BTC.Patient_Id = Convert.ToInt32(Patient_id);
                    BTC.Transfusion_CheckList_Value = item.value;
                    BTC.Transfusion_Heading = item.Header_Text;
                    BTC.Transfusion_Sub_List = item.checkList;
                    BTC.RowNumber = Convert.ToInt32(item.RowNumber);
                    db.Blood_Transfusion_CheckLists.InsertOnSubmit(BTC);
                    db.SubmitChanges();
                    
                }
              

            }
            catch (Exception ex) 
            {
            
            }
            return lastId.ToString();
          
        }
        public class CheckList
        {
            public string  Header_Text { get; set; }

            public string checkList { get; set; }
          
            public string value { get; set; }

            public string RowNumber { get; set; }
        }
        [System.Web.Services.WebMethod]
        public static string getRecords(string id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Result = (from records in db.Blood_Transfusions
                          where (records.BTR_Id.Equals(id))
                          select new
                          {
                               records.BTR_wristY,
                            records.BTR_wristN,
                    records.BTR_benefitY,
                    records.BTR_benefitN,
                   records.BTR_bloodY,
                 records.BTR_bloodN,
                    records.BTR_leakageY,
                    records.BTR_leakageN,
                records.BTR_expY,
                    records.BTR_expN,
                records.BTR_insY,
               records.BTR_insN,
                  records.BTR_Transfusion_ReactionY,
                    records.BTR_Transfusion_ReactionN,
                  records.BTR_pregY,
              records.BTR_pregN,
                   records.BTR_components,
                               records.BTR_what_Date,
                               BTR_what_Time = DBClass.getField("select  isnull(CONVERT(varchar(15),CAST('" + records.BTR_what_Time + "' AS TIME),100),'') from Blood_Transfusion where BTR_Id=" + id),
                   records.BTR_units,
                               records.BTR_doctor,
                               records.BTR_indication,
                               records.Patient_Id,
                               records.WitnessCnic,
                               records.WitnessName,
                               records.WitnessSignature,
                               records.onDutyDoctor,
                               records.PatientGuardian,
                          }).ToList();

            return (new JavaScriptSerializer()).Serialize(Result);
        }
    }
}