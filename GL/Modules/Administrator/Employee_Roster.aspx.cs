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
    public partial class Employee_Roster : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static string LoadRousterDetailsData(int Rouster_id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Header = (from m in db.Doctor_Rouster_Details
                          where m.Rouster_id == Rouster_id
                          select new
                          {
                              m.Rouster_Date,
                              m.Time_In,
                              m.Time_Out,
                              m.Slot,
                              m.Week_Days
                          }).ToList();
            return (new JavaScriptSerializer()).Serialize(Header);
        }
        [WebMethod]
        public static string getMonth()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Header = (from m in db.GL_Periods
                          where m.Period_Closed == false
                          orderby m.Period_ID descending
                          select new
                          {
                              m.Period_ID,
                              m.Period_start_date,
                              m.Period_end_date,
                              m.Period_Description
                          }).ToList();
            return (new JavaScriptSerializer()).Serialize(Header);
        }



        [WebMethod]
        public static string LoadRousterData(int Rouster_id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Header = (from m in db.Doctor_Rouster_Masters
                          where m.Rouster_id == Rouster_id
                          select new
                          {
                              m.Doctor_Id,
                              m.Rouster_Month,
                              m.Period_Id
                          }).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(Header);
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
        public class Roster
        {
            public int Rouster_Id { get; set; }
            public int Emp_Id { get; set; }
            public string Month { get; set; }
            public string Period_id { get; set; }
            public List<RosterDetails> Details { get; set; }
        }
        public class RosterDetails
        {
            public int Rouster_Detail_Id { get; set; }
            public int Rouster_Id { get; set; }
            public string Time_In { get; set; }
            public string Time_Out { get; set; }
            public string Slot { get; set; }
            public string dayLabel { get; set; }
            public DateTime dateLabel { get; set; }
        }


        [WebMethod]
        public static bool CheckDoctorRoster(string Emp_id, int Period_Id)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                // Check if any roster exists for the given doctor and month
                bool exists = db.Doctor_Rouster_Masters
                                .Any(emp => emp.Doctor_Id == Convert.ToInt32(Emp_id) && emp.Period_Id == Period_Id);

                return exists;
            }
        }

        [WebMethod]
        public static string SaveRecord(string AllRecord)
        {
            string survId = "";
            Doctor_Rouster_Master newBill = new Doctor_Rouster_Master();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            JavaScriptSerializer serialize = new JavaScriptSerializer();
            var data = serialize.Deserialize<Roster>(AllRecord);
            if (data.Rouster_Id == 0)
            {
                newBill = new Doctor_Rouster_Master();
                newBill.Created_By = AppConfig.UserID;
                newBill.Created_Time = DateTime.Now;
                newBill.Rouster_Month = data.Month;
                newBill.Period_Id = Convert.ToInt32(data.Period_id);
                newBill.Doctor_Id = data.Emp_Id;
                db.Doctor_Rouster_Masters.InsertOnSubmit(newBill);
                db.SubmitChanges();
                survId = newBill.Rouster_id.ToString();
            }
            else
            {
                var list = db.Doctor_Rouster_Masters.Where(b => b.Rouster_id == data.Rouster_Id).FirstOrDefault();
                list.Updated_By = AppConfig.UserID;
                list.Updated_Time = DateTime.Now;
                list.Rouster_Month = data.Month;
                list.Period_Id = Convert.ToInt32(data.Period_id);
                list.Doctor_Id = data.Emp_Id;
                db.SubmitChanges();
                survId = list.Rouster_id.ToString();
            }
            newBill.Rouster_Month = data.Month;
            newBill.Doctor_Id = data.Emp_Id;
            if (data.Rouster_Id != 0)
            {
                List<Doctor_Rouster_Detail> lstPOItemDetails = db.Doctor_Rouster_Details.Where(t => t.Rouster_id == data.Rouster_Id).ToList(); db.Doctor_Rouster_Details.DeleteAllOnSubmit(lstPOItemDetails);
                db.SubmitChanges();
            }
            foreach (RosterDetails dtls in data.Details)
            {
                TimeSpan timeIn = DateTime.Parse(dtls.Time_In).TimeOfDay;
                TimeSpan timeOut = DateTime.Parse(dtls.Time_Out).TimeOfDay;

                string minutes = dtls.Slot;
                //TimeSpan slot = TimeSpan.FromMinutes(minutes);
                DateTime Rouster_Date = dtls.dateLabel;

                Doctor_Rouster_Detail newBillDetails = new Doctor_Rouster_Detail
                {
                    Rouster_id = Convert.ToInt32(survId),
                    Rouster_Date = Rouster_Date,
                    Time_In = timeIn,
                    Time_Out = timeOut,
                    Slot = minutes,
                    Week_Days = dtls.dayLabel,

                };
                db.Doctor_Rouster_Details.InsertOnSubmit(newBillDetails);
                db.SubmitChanges();
            }
            return newBill.Rouster_id.ToString();
        }
    }
}