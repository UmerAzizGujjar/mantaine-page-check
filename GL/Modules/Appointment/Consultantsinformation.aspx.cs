using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class Consultantsinformation : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                ChangeDoctorStatus();
            }

        }

        private void ChangeDoctorStatus()
        {

            //DateTime time1 = DateTime.Parse("11:00 PM");
            //var Sample1 = time1.ToString("HH:mm");

            //DateTime time2 = DateTime.Parse("11:59 PM");
            //var Sample2 = time2.ToString("HH:mm");


            //TimeSpan end = new TimeSpan(12, 0, 0); //12 o'clock
            //TimeSpan start = DateTime.Now.TimeOfDay;
            //if ((start > end))
            //{
            //    //match found
            //}


            //DateTime t1 = DateTime.Parse("23:59:00.000");
            //DateTime t2 = DateTime.Parse("15:03:00.000");

            //DateTime t1 = DateTime.Parse("23:59:00");
            // DateTime t2 = DateTime.Parse("10:03:00");

            DateTime maturityTime = DateTime.Parse("23:00:00.000");
            // DateTime sample1 = DateTime.Parse("23:59:00.000");
            //DateTime sample2 = DateTime.Parse("00:00:00.000");


            DateTime currentTime = DateTime.Now;

            if (currentTime.TimeOfDay > maturityTime.TimeOfDay)
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var empList = db.HR_Employees.Where(w => w.TodayStatus == "Absent" || w.TodayStatus == "Present").ToList();
                    if (empList != null)
                    {
                        foreach (var item in empList)
                        {
                            item.TodayStatus = null;
                        }
                    }
                    db.SubmitChanges();

                }

            }


            //DateTime dt2 = new DateTime();

            //int compareResult = dt.CompareTo(dt2);

            //// var day = value.Date; // a DateTime that will just be whole days
            //var time2 = dt2.TimeOfDay; // a TimeSpan that is the duration into the day           

            //if (compareResult < 0)
            //    Console.WriteLine("First date is earlier");
            //else if (compareResult == 0)
            //    Console.WriteLine("Both dates are same");
            //else
            //    Console.WriteLine("First date is later");


        }

        [WebMethod]
        public static string SaveRemarks(string remarks, string doctor_id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var result = "failure";
            var record = (from data in db.HR_Employees.Where(x => x.Emp_ID.Equals(doctor_id)) select data).FirstOrDefault();
            if (record != null)
            {
                record.Remarks = remarks;
                db.SubmitChanges();
                result = "success";
            }
            return result;
        }

        [WebMethod]
        public static string SaveDoctorStatus(string present_Status, string doctor_Id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var result = "failure";

            var doctor = db.HR_Employees.Where(w => w.Emp_ID.Equals(doctor_Id)).FirstOrDefault();

            if (doctor != null)
            {
                doctor.TodayStatus = present_Status;
                db.SubmitChanges();
                result = "success";
            }
            return result;

        }



        [WebMethod]
        public static string ViewList()
        {
            string result = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = (from a in db.HR_Employees

                             select new
                             {
                                 a.Emp_Name,
                                 Designation = db.GetDataValueName("Designation", a.Designation),
                                 a.Govt_Hospital,
                                 Patient_Type = db.GetDataValueName("Patient Type", a.Patient_Type),
                                 a.Consultant_Charges,
                                 a.Timings_In,
                                 a.Timings_Out,
                                 a.Off_Days_Names,
                                 a.Mobile,
                                 a.Room_No,
                                 a.Floor_No,
                                 a.Extension_No,
                                 a.Emp_ID,
                                 a.Remarks,
                                 a.TodayStatus

                             }).ToList();

                result = (new JavaScriptSerializer()).Serialize(query).ToString();
            }
            return result;
        }
    }
}