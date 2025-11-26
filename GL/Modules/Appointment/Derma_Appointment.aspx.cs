using PMS.Modules.Dashboards;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
namespace PMS
{
    public partial class Derma_Appointment : System.Web.UI.Page
    {

        protected void Page_Load()
        {
            if (!IsPostBack)
            {
                //BindDropDownList();
            }
        }



        [WebMethod]
        public static string GetCity()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "City"
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
        public static string GetArea()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Area"
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
        public static string getlist(string startDate, string endDate)
        {
            string result = string.Empty;
            DateTime dTimestDate;
            DateTime dTimeenDate;

            if (startDate == "" || endDate == "")
            {



                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    DateTime last24Hours = DateTime.Now.AddHours(-24);

                    var query = (from a in db.Appointment_Forms
                                 where a.App_Date >= last24Hours && a.App_Date <= DateTime.Now
                                 select new
                                 {
                                     a.Appointment_ID,
                                     a.Patient_Name,
                                     a.Phone,
                                     a.Age,
                                     a.Consultant_ID,
                                     a.Appointment_No,
                                     a.Appointment_Code,
                                     a.App_Date,
                                     a.Time,
                                     a.Status,
                                     a.cancelAppointment,
                                     a.created_time,
                                     emp_name = (from data in db.HR_Employees where data.Emp_ID == Convert.ToInt32(a.Consultant_ID) select data.Emp_Name).FirstOrDefault(),
                                 }).ToList().OrderByDescending(x => x.created_time);

                    result = (new JavaScriptSerializer()).Serialize(query).ToString();
                }


            }
            else
            {

                dTimestDate = Convert.ToDateTime(startDate);
                dTimeenDate = Convert.ToDateTime(endDate);
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var query = (from a in db.Appointment_Forms
                                 where a.App_Date.Value.Date >= dTimestDate && a.App_Date.Value.Date <= dTimeenDate

                                 select new
                                 {
                                     a.Appointment_ID,
                                     a.Patient_Name,
                                     a.Phone,
                                     a.Age,
                                     a.Consultant_ID,
                                     a.Appointment_No,
                                     a.Appointment_Code,
                                     a.App_Date,
                                     a.Time,
                                     a.Status,
                                     emp_name = (from data in db.HR_Employees where data.Emp_ID == Convert.ToInt32(a.Consultant_ID) select data.Emp_Name).FirstOrDefault(),
                                 }).ToList().OrderByDescending(x => x.App_Date);
                    result = (new JavaScriptSerializer()).Serialize(query).ToString();
                }
            }


            return result;
        }

        [WebMethod]
        public static string GetAvailableDatesAndTimes(int doc_id, string txt_date, string procTimeSlot)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                DateTime selectedDate;
                if (!DateTime.TryParse(txt_date, out selectedDate))
                    return new JavaScriptSerializer().Serialize(new { error = "Invalid date" });

                var doctor = (from hr in db.HR_Employees
                              where hr.Emp_ID == doc_id && hr.IsDoctor == true
                              select new
                              {
                                  hr.Off_Days_Names,
                                  hr.Timings_In,
                                  hr.Timings_Out
                              }).FirstOrDefault();

                if (doctor == null)
                    return new JavaScriptSerializer().Serialize(new { error = "Doctor not found" });

                string dayName = selectedDate.ToString("ddd");
                var offDays = doctor.Off_Days_Names?.Split(',') ?? new string[0];

                if (offDays.Contains(dayName, StringComparer.OrdinalIgnoreCase))
                    return new JavaScriptSerializer().Serialize(new { error = "Doctor not available" });

                var lastAppointmentEnd = (from ap in db.Derma_Appointments
                                          where ap.Doctor_Id == Convert.ToString(doc_id)
                                          && ap.Appointment_Date == selectedDate.Date
                                          orderby ap.Doctor_End_Time descending
                                          select ap.Doctor_End_Time).FirstOrDefault();

                TimeSpan availableStart;

                if (lastAppointmentEnd.HasValue)
                {
                    availableStart = lastAppointmentEnd.Value;
                }
                else
                {
                    availableStart = doctor.Timings_In ?? TimeSpan.Zero;
                }

                // -------------------------------
                // NEW LOGIC: Apply procTimeSlot
                // -------------------------------
                int slotMinutes = 15; // default slot

                if (!string.IsNullOrEmpty(procTimeSlot))
                {
                    int parsedSlot;
                    if (int.TryParse(procTimeSlot, out parsedSlot) && parsedSlot > 0)
                    {
                        slotMinutes = parsedSlot;
                    }
                }

                TimeSpan availableEnd = availableStart.Add(TimeSpan.FromMinutes(slotMinutes));

                if (doctor.Timings_Out.HasValue && availableEnd > doctor.Timings_Out.Value)
                {
                    availableEnd = doctor.Timings_Out.Value;
                }

                return new JavaScriptSerializer().Serialize(new
                {
                    TimeIn = availableStart.ToString(@"hh\:mm"),
                    TimeOut = availableEnd.ToString(@"hh\:mm")
                });
            }
        }

        [WebMethod]
        public static string CheckMachineAvailability(string Mch_Id, string txt_date, TimeSpan MachineTimeIn, TimeSpan MachineTimeOut)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                if (!DateTime.TryParse(txt_date, out DateTime selectedDate))
                    return new JavaScriptSerializer().Serialize(new { error = "Invalid date" });
                var overlapping = (from ap in db.Derma_Appointments
                                   where ap.Machine_Id == Mch_Id
                                   && ap.Appointment_Date == selectedDate.Date
                                   && (
                                           (MachineTimeIn >= ap.Machine_Start_Time && MachineTimeIn < ap.Machine_End_Time) ||
                                           (MachineTimeOut > ap.Machine_Start_Time && MachineTimeOut <= ap.Machine_End_Time) ||
                                           (MachineTimeIn <= ap.Machine_Start_Time && MachineTimeOut >= ap.Machine_End_Time)
                                       )
                                   select ap).Any();

                if (overlapping)
                {
                    return new JavaScriptSerializer().Serialize(new
                    {
                        error = "Machine already has an appointment in this time"
                    });
                }

                return new JavaScriptSerializer().Serialize(new
                {
                    success = "Machine is Available"
                });
            }
        }

        [WebMethod]
        public static string CheckRoomsAvailability(string Room_Id, string txt_date, TimeSpan RoomTimeIn, TimeSpan RoomTimeOut)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                if (!DateTime.TryParse(txt_date, out DateTime selectedDate))
                    return new JavaScriptSerializer().Serialize(new { error = "Invalid date" });
                var overlapping = (from ap in db.Derma_Appointments
                                   where ap.Room_Id == Room_Id
                                   && ap.Appointment_Date == selectedDate.Date
                                   && (
                                           (RoomTimeIn >= ap.Room_Start_Time && RoomTimeIn < ap.Room_End_Time) ||
                                           (RoomTimeOut > ap.Room_Start_Time && RoomTimeOut <= ap.Room_End_Time) ||
                                           (RoomTimeIn <= ap.Room_Start_Time && RoomTimeOut >= ap.Room_End_Time)
                                       )
                                   select ap).Any();

                if (overlapping)
                {
                    return new JavaScriptSerializer().Serialize(new
                    {
                        error = "Room already has an appointment in this time"
                    });
                }

                return new JavaScriptSerializer().Serialize(new
                {
                    success = "Room is Available"
                });
            }
        }
        [WebMethod]
        public static string CheckHelperAvailability(int Emp_Id, string txt_date, TimeSpan helperTimeIn, TimeSpan helperTimeOut)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                DateTime selectedDate;
                if (!DateTime.TryParse(txt_date, out selectedDate))
                    return new JavaScriptSerializer().Serialize(new { error = "Invalid date" });

                var helper = (from hr in db.HR_Employees
                              where hr.Emp_ID == Emp_Id && hr.is_Employee == true
                              select new
                              {
                                  hr.Off_Days_Names,
                                  hr.Timings_In,     
                                  hr.Timings_Out     
                              }).FirstOrDefault();

                if (helper == null)
                    return new JavaScriptSerializer().Serialize(new { error = "Helper not found" });

                string dayName = selectedDate.ToString("ddd");
                var offDays = helper.Off_Days_Names?.Split(',') ?? new string[0];

                if (offDays.Contains(dayName, StringComparer.OrdinalIgnoreCase))
                    return new JavaScriptSerializer().Serialize(new { error = "Helper is OFF today" });
                TimeSpan shiftStart = helper.Timings_In ?? TimeSpan.Zero;
                TimeSpan shiftEnd = helper.Timings_Out ?? TimeSpan.Zero;
                if (helperTimeIn < shiftStart || helperTimeOut > shiftEnd)
                {
                    return new JavaScriptSerializer().Serialize(new
                    {
                        error = "Helper time is outside working hours"
                    });
                }
                var overlapping = (from ap in db.Derma_Appointments
                                   where ap.Helper_Id == Emp_Id.ToString()
                                   && ap.Appointment_Date == selectedDate.Date
                                   && (
                                           (helperTimeIn >= ap.Helper_Start_Time && helperTimeIn < ap.Helper_End_Time) ||
                                           (helperTimeOut > ap.Helper_Start_Time && helperTimeOut <= ap.Helper_End_Time) ||
                                           (helperTimeIn <= ap.Helper_Start_Time && helperTimeOut >= ap.Helper_End_Time)
                                       )
                                   select ap).Any();

                if (overlapping)
                {
                    return new JavaScriptSerializer().Serialize(new
                    {
                        error = "Helper already has an appointment in this time"
                    });
                }

                return new JavaScriptSerializer().Serialize(new
                {
                    success = "Helper is Available"
                });
            }
        }

        [WebMethod]
        public static string CheckDays(string ddl_colstnts, DateTime date)
        {
            string result;


            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = (from a in db.HR_Employees
                             join DM in db.Doctor_Rouster_Masters
   on a.Emp_ID equals DM.Doctor_Id
                             join DD in db.Doctor_Rouster_Details
on DM.Rouster_id equals DD.Rouster_id
                             where a.Emp_ID == Convert.ToInt32(ddl_colstnts) && DD.Rouster_Date == date
                             select new
                             {

                                 a.Off_Days_Names,
                                 DD.Time_In,
                                 DD.Time_Out

                             }).FirstOrDefault();
                result = (new JavaScriptSerializer()).Serialize(query).ToString();


            }
            return result;
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
        public static string GetPAtType()
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
        public static string SavePatientDetails(string Full_Name, string RelationType, string Relation, string Gender, string Mobile, string Date_Of_Birth, string CNIC, string Address, string PatientID, string martail_status, string Age, string houseno, string stno, string city, string area, string city_val, string area_val)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            Reg_patient pat = null;
            if (!string.IsNullOrEmpty(PatientID) && PatientID != "0" && PatientID != "(New)")
            {
                pat = db.Reg_patients.Where(w => w.pat_id == Convert.ToInt32(PatientID)).FirstOrDefault();

                if (pat != null)
                {
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
                    pat.Permanent_Address = houseno;
                    pat.stno_mno = stno;
                    pat.city = city;
                    pat.area = area;
                    pat.val_city = city_val;
                    pat.val_area = area_val;


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
                pat.Gender = Gender;
                pat.Mobile1 = Mobile;
                pat.Age_years = Age;
                pat.DOB = DateTime.ParseExact(Date_Of_Birth, "dd/MM/yyyy", System.Globalization.CultureInfo.InvariantCulture);
                pat.NIC = CNIC;
                pat.Permanent_Address = Address;
                pat.Created_time = DateTime.Now;
                pat.Created_by = AppConfig.UserID;
                pat.iscancel = false;
                pat.Martial_Status = martail_status;
                var companyID = AppConfig.Company_ID;
                var company = (from dt in db.sys_Companies
                               where dt.Company_ID == companyID
                               select dt).FirstOrDefault();
                string companyCode = company.CompanyCode;
                string MR_Sequence = companyCode + "-" + PatientNumber;
                pat.mr_no_sequence = MR_Sequence;
                pat.Permanent_Address = houseno;
                pat.stno_mno = stno;
                pat.city = city;
                pat.area = area;
                pat.val_city = city_val;
                pat.val_area = area_val;
                db.Reg_patients.InsertOnSubmit(pat);
                db.SubmitChanges();
            }
            return pat.pat_id.ToString();
        }
        //Load  doc and  increment appcode
        [WebMethod]
        public static string loadApp_data(string reg_id)
        {
            string result = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = (from a in db.Reg_patients
                             where a.pat_id == Convert.ToInt32(reg_id)

                             select new
                             {
                                 a.Patient_No,
                                 a.Full_Name,
                                 a.Gender,
                                 a.Mobile1,
                                 a.Age_years,
                                 a.pat_id,
                                 //a.Consultant_ID,

                             }).FirstOrDefault();
                result = (new JavaScriptSerializer()).Serialize(query).ToString();
            }
            return result;
        }
        [WebMethod]
        public static string GetAppNo()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var Appointment_ID = DBClass.GetNewNumber("Appointment_Code", "", "Appointment_Form");
            return Appointment_ID.ToString();
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
        public static string Getmr()
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
        public static List<PatientsResult> SearchPatients(string SearchString)
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
        //appointment no auto generate by doc id and datewise

        [WebMethod]
        public static string GetAppNoByDoctor(string doctorID, string checkdate)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            if (doctorID == null)
            {
                return "";
            }


            var getmaxno = DBClass.getField("Select isnull(MAX(cast(Appointment_No as int)),0)+1 from appointment_form where Consultant_ID =" + doctorID + "  And App_Date ='" + checkdate + "'");

            return getmaxno.ToString();
        }
        [WebMethod]
        public static string CancelAppointment(string appointmentId)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var cancelbooking = DBClass.getField("UPDATE appointment_form SET cancelAppointment = 1, Time = NULL WHERE Appointment_ID = " + appointmentId);
            return cancelbooking.ToString();

        }


        [WebMethod]

        public static string loadAppData(int appID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.sp_loadAppointment(appID).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(Details);
        }

        [WebMethod]

        public static string loadAppData_edit(int App_id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.sp_loadAppointment(App_id).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(Details);
        }
        [WebMethod]
        public static string GetSubDepartmentByDoctor(string doctor_Id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var records = (from data in db.HR_Employees
                           where data.Emp_ID == Convert.ToInt32(doctor_Id)
                           select new
                           {
                               data.Department,

                               Departments = db.GetDataValueName("Patient Main Category", data.Department),


                           }).Distinct().ToList();
            return (new JavaScriptSerializer()).Serialize(records);
        }

        [WebMethod]
        public static string GetDepartment()
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

        [WebMethod]
        public static string GetMachine()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Machine"
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
        public static string GetDoctors()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var emps = (from emp in db.HR_Employees
                                      where emp.IsDoctor == true
                        select new
                        {
                            DataValue_Name = emp.Emp_ID.ToString(),
                            DataValue_Description = emp.Emp_Name
                        }).ToList();

            return (new JavaScriptSerializer()).Serialize(emps);
        }


        [WebMethod]
        public static string GetHelper()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var emps = (from emp in db.HR_Employees
                        where emp.is_Employee == true
                        select new
                        {
                            DataValue_Name = emp.Emp_ID.ToString(),
                            DataValue_Description = emp.Emp_Name
                        }).ToList();

            return (new JavaScriptSerializer()).Serialize(emps);
        }

        [WebMethod]
        public static string GetRooms()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var emps = (from emp in db.Rooms
                               select new
                               {
                                   DataValue_Name = emp.Room_ID.ToString(),
                                   DataValue_Description = emp.Room_No.ToString()
                               }).ToList();

            return (new JavaScriptSerializer()).Serialize(emps);
        }

        [WebMethod]
        public static string GetServices()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var record = (from tbl in db.INV_Items
                          where (tbl.Procedure_Required == true && tbl.Hospital_Services == true)
                          select tbl).ToList();

            return (new JavaScriptSerializer()).Serialize(record);
        }

        [WebMethod]
        public static string GetProcedureTime(int procid)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var record = (from tbl in db.INV_Items
                          where tbl.Item_ID == procid
                          select tbl.Procedure_Time).FirstOrDefault();

            return (new JavaScriptSerializer()).Serialize(record);
        }

        [WebMethod]
        public static string CheckDoctorAvailability(string doctorId, DateTime appointmentDate, DateTime appointmentTime, string aptid)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                string Message = string.Empty;
                if (aptid == null || aptid == "")
                {

                    var checkCount = db.Appointment_Forms.DefaultIfEmpty()
                   .Where(w => w.Consultant_ID == doctorId
                   && w.App_Date == appointmentDate.Date
                   && w.Time.Value == appointmentTime.TimeOfDay).Count();

                    if (checkCount > 0)
                    {
                        Message = "Doctor not Available";
                    }
                    else
                    {
                        Message = "Doctor Available";
                    }

                }
                else
                {
                    Message = "Doctor Available";
                }

                return Message;


            }

        }

        // For save Data With button
        [WebMethod]
        public static int SaveAppointment(string btnsave, string AllItemDetail, string editmode_ID)
        {
            string AppID = "";
            Derma_Appointment Obj = new Derma_Appointment();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            JavaScriptSerializer oJS = new JavaScriptSerializer();
            var record = oJS.Deserialize<MasterAppointment>(AllItemDetail);



            if (btnsave == "Update")
            // if (editmode_ID != "")
            {
                var Items = (from t in db.Derma_Appointments
                             where t.Derma_Appointment_Id == Convert.ToInt32(record.txt_ID)
                             select t).FirstOrDefault();

                Items.Patient_Id = record.reg_id;
                Items.Status = "Booked";
                Items.Doctor_Id = record.ddl_colstnt;
                Items.Room_Id = record.ddlRoom;
                Items.Helper_Id = record.ddl_helper;
                Items.Machine_Id = record.ddlMachine;
                Items.Appointment_No = Convert.ToInt32(record.txt_apt_no);
                Items.Appointment_Date = Convert.ToDateTime(record.txt_date);
                Items.Doctor_Start_Time = record.Doc_Start_Time;
                Items.Doctor_End_Time = record.Doc_End_Time;
                Items.Helper_Start_Time = record.Helper_Start_Time;
                Items.Helper_End_Time = record.Hepler_End_Time;
                Items.Machine_Start_Time = record.Machine_Start_Time;
                Items.Machine_End_Time = record.Machine_End_Time;
                Items.Room_Start_Time = record.Room_Start_Time;
                Items.Room_End_Time = record.Room_End_Time;
                Items.Procedure_Id = record.item_id;

                Items.Updated_By = AppConfig.UserID;
                Items.Updated_Date = DateTime.Now;
                db.SubmitChanges();
                AppID = Items.Derma_Appointment_Id.ToString();

            }
            else
            {

                Obj.Patient_Id = record.reg_id;
                Obj.Status = "Booked";
                Obj.Doctor_Id = record.ddl_colstnt;
                Obj.Room_Id = record.ddlRoom;
                Obj.Helper_Id = record.ddl_helper;
                Obj.Machine_Id = record.ddlMachine;
                Obj.Appointment_No = Convert.ToInt32(record.txt_apt_no);
                Obj.Appointment_Date = Convert.ToDateTime(record.txt_date);
                Obj.Doctor_Start_Time = record.Doc_Start_Time;
                Obj.Doctor_End_Time = record.Doc_End_Time;
                Obj.Helper_Start_Time = record.Helper_Start_Time;
                Obj.Helper_End_Time = record.Hepler_End_Time;
                Obj.Machine_Start_Time = record.Machine_Start_Time;
                Obj.Machine_End_Time = record.Machine_End_Time;
                Obj.Room_Start_Time = record.Room_Start_Time;
                Obj.Room_End_Time = record.Room_End_Time;
                Obj.Procedure_Id = record.item_id;
                AppID = Obj.Derma_Appointment_Id.ToString();
                Obj.Created_By  = AppConfig.UserID;
                Obj.Created_Date = DateTime.Now;
                db.Derma_Appointments.InsertOnSubmit(Obj);
                db.SubmitChanges();

            }


            if (btnsave == "Save And Send Message")
            {
                string Doctor_Name = DBClass.getField("select dbo.GetDoctorName(" + record.ddl_colstnt + ")");

                string Patient_No = record.txt_ID;
                string DocumentName = "Appointment Form";
                string SMS_Contant = "Dear Patient,\n\nYou have been scheduled for an appointment with " + Doctor_Name + " at " + record.txt_time + "\n\nDate: " + record.txt_date;
                string msg = "";
                string CellNumber = record.txt_phone_no;
                bool Send_Status = DBClass.sendSMS(CellNumber, SMS_Contant, out msg, DocumentName, Patient_No);
            }


            return int.Parse(AppID);
        }
        [WebMethod]
        public static string ViewList(int doc_id)
        {
            string result = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                DateTime currentDate = DateTime.Today;

                var query = (from a in db.HR_Employees
                             where a.Emp_ID == doc_id
                             select new
                             {
                                 a.Emp_Name,
                                 Designation = db.GetDataValueName("Designation", a.Designation),
                                 a.Govt_Hospital,
                                 Patient_Type = db.GetDataValueName("Patient Type", a.Patient_Type),
                                 a.Consultant_Charges,
                                 a.Timings_In,
                                 a.Timings_Out,
                                 a.Patient_Time,
                                 a.Off_Days_Names,
                                 a.Mobile,
                                 a.Room_No,
                                 a.Floor_No,
                                 a.Extension_No,
                                 a.Emp_ID,
                                 a.Remarks,
                                 a.TodayStatus,

                             }).FirstOrDefault();
                DateTime currentDateStart = new DateTime(currentDate.Year, currentDate.Month, currentDate.Day, 0, 0, 0);
                DateTime currentDateEnd = currentDateStart.AddDays(1).AddTicks(-1);
                var appointments = (from app in db.Appointment_Forms
                                    where app.Consultant_ID == Convert.ToString(doc_id)
                                          && app.created_time >= currentDateStart
                                          && app.created_time <= currentDateEnd
                                    select new
                                    {
                                        StartTime = app.Time,
                                    }).ToList();

                var response = new
                {
                    DoctorData = query,
                    Appointments = appointments
                };
                result = (new JavaScriptSerializer()).Serialize(response);
            }

            return result;
        }



        [WebMethod]
        public static string ViewLists(int doc_id, DateTime specificDate)
        {
            string result = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                int specificMonth = specificDate.Month;
                int specificDay = specificDate.Day;

                var query = (from a in db.HR_Employees
                             join Dm in db.Doctor_Rouster_Masters on a.Emp_ID equals Dm.Doctor_Id
                             join dd in db.Doctor_Rouster_Details on Dm.Rouster_id equals dd.Rouster_id
                             where a.Emp_ID == doc_id
                                 && dd.Rouster_Date == specificDate.Date
                             select new
                             {
                                 a.Emp_Name,
                                 Designation = db.GetDataValueName("Designation", a.Designation),
                                 a.Govt_Hospital,
                                 Patient_Type = db.GetDataValueName("Patient Type", a.Patient_Type),
                                 a.Consultant_Charges,
                                 a.Timings_In,
                                 a.Off_Days_Names,
                                 dd.Time_In,
                                 dd.Time_Out,
                                 dd.Slot,
                                 a.Timings_Out,
                                 a.Patient_Time,
                                 a.Mobile,
                                 a.Room_No,
                                 a.Floor_No,
                                 a.Extension_No,
                                 a.Emp_ID,
                                 a.Remarks,
                                 a.TodayStatus,
                                 // Calculate number of slots
                                 Slots = CalculateSlots(dd.Time_In, dd.Time_Out, Convert.ToInt32(dd.Slot))
                             }).FirstOrDefault();
                DateTime specificDateStart = new DateTime(specificDate.Year, specificDate.Month, specificDate.Day, 0, 0, 0);
                DateTime specificDateEnd = specificDateStart.AddDays(1).AddTicks(-1);


                var appointments = (from app in db.Appointment_Forms
                                    where app.Consultant_ID == Convert.ToString(doc_id)
                                          && app.App_Date >= specificDateStart
                                          && app.App_Date <= specificDateEnd
                                    select new
                                    {
                                        StartTime = app.Time, // Extract time part only
                                    }).ToList();

                var response = new
                {
                    DoctorData = query,
                    Appointments = appointments
                };

                // Serialize the query result including the slots and appointments
                result = (new JavaScriptSerializer()).Serialize(response);
            }

            return result;
        }

        private static List<(TimeSpan, TimeSpan)> CalculateSlots(TimeSpan? timeIn, TimeSpan? timeOut, int? patientTime)
        {
            List<(TimeSpan, TimeSpan)> slotsList = new List<(TimeSpan, TimeSpan)>();

            if (timeIn.HasValue && timeOut.HasValue && patientTime.HasValue)
            {
                TimeSpan currentSlotStartTime = timeIn.Value;
                TimeSpan patientTimeSpan = TimeSpan.FromMinutes(patientTime.Value);

                while (currentSlotStartTime < timeOut)
                {
                    TimeSpan currentSlotEndTime = currentSlotStartTime.Add(patientTimeSpan);
                    if (currentSlotEndTime > timeOut.Value)
                    {
                        currentSlotEndTime = timeOut.Value;
                    }
                    slotsList.Add((currentSlotStartTime, currentSlotEndTime));
                    currentSlotStartTime = currentSlotEndTime;
                }
            }

            return slotsList;
        }
        [WebMethod]
        public static string GetCountry()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Country"
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
        public class MasterAppointment
        {


            public string txt_ID { get; set; }
            public string PatientTitle { get; set; }
            public string txt_pt_name { get; set; }
            public string txt_phone_no { get; set; }
            public string txt_age { get; set; }
            public string ddl_colstnt { get; set; }
            public string ddl_helper { get; set; }
            public string ddlMachine { get; set; }
            public string ddlRoom { get; set; }
            public string txt_apt_no { get; set; }
            public string type { get; set; }
            public string txt_date { get; set; }
            public TimeSpan txt_time { get; set; }
            public TimeSpan Doc_Start_Time { get; set; }
            public TimeSpan Doc_End_Time { get; set; }
            public TimeSpan Helper_Start_Time { get; set; }
            public TimeSpan Machine_Start_Time { get; set; }
            public TimeSpan Room_Start_Time { get; set; }
            public TimeSpan Room_End_Time { get; set; }
            public TimeSpan Hepler_End_Time { get; set; }
            public TimeSpan Machine_End_Time { get; set; }
            public string txt_Status { get; set; }
            public string subdepartment { get; set; }
            public string item_id { get; set; }
            public string remarks { get; set; }
            public int reg_id { get; set; }

        }
        //[WebMethod]
        //public static string SendWhatsAppToPatient(string to, string patientName, string doctorName, string date, string time)
        //{
        //    try
        //    {
        //        // === Replace with your real credentials from Meta Dashboard ===
        //        string WHATSAPP_TOKEN = "EAAUgSr2OlMwBPqfHyPL6RJ1AHn8Oz9QyH9ci49qCrBMSYXPco266qHGwcWomD3nuFnaK2ZASsdpK1biEUEl2EvAA9HUhAYoSVOuHNaJfDZC4SMHs0EUZAHOuiRa0B3ZB3b3oXEP3pwz8ZAwf5wp1lwR3bWwLEVhkWme0ZBQsekheg1Gu6WmVO3zRp7whWAXTdocZCy1LuzhcjZAcsCCA6bCPfxZC8muM2IPCKu3gzJCtLuTBRJQZDZD"; // ← Get this from Meta Developer Dashboard
        //        string PHONE_NUMBER_ID = "03174836373"; 

        //        string url = $"https://graph.facebook.com/v20.0/{PHONE_NUMBER_ID}/messages";

        //        // Build JSON for template message
        //        string json = $@"{{
        //    ""messaging_product"": ""whatsapp"",
        //    ""to"": ""{to}"",
        //    ""type"": ""template"",
        //    ""template"": {{
        //        ""name"": ""appointment_confirmation"",
        //        ""language"": {{ ""code"": ""en"" }},
        //        ""components"": [{{
        //            ""type"": ""body"",
        //            ""parameters"": [
        //                {{ ""type"": ""text"", ""text"": ""{patientName}"" }},
        //                {{ ""type"": ""text"", ""text"": ""{doctorName}"" }},
        //                {{ ""type"": ""text"", ""text"": ""{date}"" }},
        //                {{ ""type"": ""text"", ""text"": ""{time}"" }}
        //            ]
        //        }}]
        //    }}
        //}}";

        //        using (var client = new HttpClient())
        //        {
        //            client.DefaultRequestHeaders.Add("Authorization", $"Bearer {WHATSAPP_TOKEN}");
        //            var content = new StringContent(json, Encoding.UTF8, "application/json");
        //            var response = client.PostAsync(url, content).Result;

        //            return response.IsSuccessStatusCode ? "sent" : "failed: " + response.ReasonPhrase;
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        return "error: " + ex.Message;
        //    }
        //}

    }

}