using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class AddNewAdvance : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [System.Web.Services.WebMethod]

        public static string GetPatientAndAdvanceDetail(string AdvanceId)
        {
              DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
              int patientid =Convert.ToInt32(db.AR_Advances.Where(x => x.Advance_ID.Equals(AdvanceId)).Select(x => x.Patient_ID).FirstOrDefault());
              int Patien_No = DBClass.GetMRNOBy_RegID(Convert.ToInt32(patientid));
              var InPatientId = db.In_Patients.Where(m => m.Patient_ID.Equals(patientid) && m.Discharge == false).OrderByDescending(m => m.Admission_Date).Select(m => m.In_Patient_ID).FirstOrDefault();
             
              var Type = (from tbl in db.In_Patients
                          where tbl.Patient_ID == Convert.ToInt32(patientid)
                          && tbl.Discharge != true
                          orderby tbl.Created_Time descending
                          select tbl.Patient_Discount_Type).FirstOrDefault();
              var query = (from data in db.AR_Advances
                           join pat in db.Reg_patients on data.Patient_ID equals pat.pat_id
                           where pat.pat_id == Convert.ToInt32(patientid) orderby data.Advance_ID descending
                           select new 
                           {
                           pat.Full_Name,
                           pat.Mobile1,
                           pat.Created_time,
                           pat.Gender,
                           pat.Age_years,
                           pat.Permanent_Address,
                           //pat.Patient_Main_Category,
                           pat.pat_id,
                         
                         /*department = db.GetDataValueName("Patient Main Category", pat.Patient_Main_Category),*/ //updated info

                           Patient_Discount_Type = db.GetDataValueName("Patient Type", Type),
                           data.Remarks,
                           data.Advance_Date,
                          data.Advance_Amount,
                           Balance = Convert.ToInt32(db.getAdvance_Balance(Convert.ToInt32(InPatientId), "In_Patient"))
                           }).FirstOrDefault();

              return (new JavaScriptSerializer()).Serialize(query);
        }

        [WebMethod]
        public static PatientDetail LoadPatientDetails(string PatientID)
        {

            int Patien_No = DBClass.GetMRNOBy_PatientID_reg(Convert.ToInt32(PatientID));
            PatientDetail pt = new PatientDetail();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            var pat = (from tbl in db.Reg_patients
                   where tbl.Patient_No == Patien_No
                   orderby tbl.Created_time descending
                   select new
                {
                    tbl.Full_Name,
                    tbl.Gender,
                    tbl.Age_years,
                    tbl.Created_time,
                    tbl.Permanent_Address,
                    tbl.Mobile1,
                    //tbl.Patient_Main_Category,
                    //tbl.Patient_Type,
                    tbl.Patient_No,
                }).FirstOrDefault();

            var Type = (from tbl in db.In_Patients
                        where tbl.Patient_ID == int.Parse(PatientID)
                        && tbl.Discharge != true
                        orderby tbl.Created_Time descending
                        select tbl.Patient_Discount_Type).FirstOrDefault();

            if (pat != null)
            {
                pt.Name = pat.Full_Name;
                pt.Gender = pat.Gender;
                pt.Age = pat.Age_years.ToString();

                if (pat.Created_time.HasValue)
                    pt.Entry_Date = pat.Created_time.ToString();
                pt.Address = pat.Permanent_Address;
                pt.Mobile = pat.Mobile1;
                //pt.department = pat.Patient_Main_Category; //pat.Patient_Main_Category to pat.Department
                //pt.department = db.GetDataValueName("Patient Main Category", pat.Patient_Main_Category); //updated info

                var ptID = int.Parse(PatientID);
                var InPatientdat = (from inv in db.In_Patients
                                    join p in db.Reg_patients
                                    on inv.Patient_ID equals p.pat_id
                                    where p.Patient_No == Patien_No && inv.Patient_ID == ptID
                                    orderby inv.Created_Time descending
                                    select inv.Department).FirstOrDefault();
                if (InPatientdat != null)
                    pt.department = db.GetDataValueName("Patient Main Category", InPatientdat);


                //pt.Patient_Type = db.GetDataValueName("Patient Type", pat.Patient_Type);
                pt.Gender = db.GetDataValueName("Gender", pat.Gender);
                var Patientno = pat.Patient_No.ToString();
                var count = (db.Reg_patients.Where(v => v.Patient_No == Convert.ToInt32(Patientno)).ToList());
                pt.Follow = count.Count.ToString();
                pt.Patient_Discount_Type = db.GetDataValueName("Patient Type", Type);
                var InPatientId = db.In_Patients.Where(m => m.Patient_ID.Equals(PatientID) && m.Discharge == false).OrderByDescending(m => m.Admission_Date).Select(m => m.In_Patient_ID).FirstOrDefault();
                pt.Balance = Convert.ToInt32(db.getAdvance_Balance(Convert.ToInt32(InPatientId), "In_Patient"));
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
            public int Balance;
        }

        [WebMethod]
        public static string CheckExistInPatient(int PatientID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext()) 
            {
                var Check = (from inPat in db.In_Patients
                            where inPat.Patient_ID == PatientID
                            && inPat.Discharge == false
                            orderby inPat.Admission_Date descending
                            select new
                            {
                                inPat.In_Patient_ID
                            }).FirstOrDefault();
                return (new JavaScriptSerializer().Serialize(Check));                
            }
        }
        [WebMethod]
        public static string Approve_Advance(string advanceid)
        {
            var user_id = AppConfig.UserID;

            try
            {
                string message = "";
                int voucherId = 0;

                using (var db = new DataBaseDataContext())
                {
                    using (var conn = new SqlConnection(db.Connection.ConnectionString))
                    {
                        using (var cmd = new SqlCommand("SpApprove_Advance", conn))
                        {
                            cmd.CommandType = CommandType.StoredProcedure;
                            cmd.Parameters.AddWithValue("@advanceid", Convert.ToInt32(advanceid));
                            cmd.Parameters.AddWithValue("@user_id", user_id);

                            conn.Open();

                            using (var reader = cmd.ExecuteReader())
                            {
                                if (reader.Read())
                                {
                                    message = reader["Message"].ToString();
                                    voucherId = Convert.ToInt32(reader["Voucher_ID"]);
                                }
                            }
                        }
                    }
                }

                var response = new
                {
                    Message = message,
                    Voucher_ID = voucherId,
                    Success = voucherId > 0
                };

                return new JavaScriptSerializer().Serialize(response);
            }
            catch (Exception ex)
            {
                var errorResponse = new
                {
                    Message = ex.Message,
                    Voucher_ID = 0,
                    Success = false
                };
                return new JavaScriptSerializer().Serialize(errorResponse);
            }
        }
        [WebMethod]
        public static string SaveAdvance(int PatientID, int AdvanceAmount, DateTime AdvanceDate, string Remarks, int InPatientID, string SaveVal, int AdvID)
        {
            string value = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext()) 
            {
                if (SaveVal == "Save")
                {
                    AR_Advance AdvanceObj = new AR_Advance()
                    {
                        Patient_ID = PatientID,
                        Advance_Amount = AdvanceAmount,
                        Advance_Date = AdvanceDate,
                        Remarks = Remarks,
                        Creation_Date = DateTime.Now,
                        In_Patient_ID = InPatientID,
                        Created_By = AppConfig.UserID
                    };
                    db.AR_Advances.InsertOnSubmit(AdvanceObj);
                    db.SubmitChanges();
                    //value = "Save";
                    value =  Convert.ToString(AdvanceObj.Advance_ID);
                }
                else 
                {
                    //var p = from data in db.AR_Advances.Where(x => x.Advance_ID.Equals(AdvID))
                    //        select data;
                   
                    //    AR_Advance obj = new AR_Advance();
                       
                    //    obj.Remarks = item.Remarks;






                    AR_Advance ArObj = db.AR_Advances.First(m => m.Advance_ID.Equals(AdvID));

                    ArObj.Advance_Amount = AdvanceAmount;
                    ArObj.Remarks = Remarks;
                    //value="Update";
                    value = Convert.ToString(ArObj.Advance_ID);
                    db.SubmitChanges();
                }


              

                try
                {
                    //db.SubmitChanges();

                    return value;
                }
                catch(Exception ex)
                {
                    return ex.Message;
                }
            }
        }
    }
}