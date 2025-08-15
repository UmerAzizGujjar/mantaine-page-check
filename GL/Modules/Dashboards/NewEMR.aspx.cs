using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using Telerik.Web.Data.Extensions;

namespace PMS.Modules.Dashboards
{
    public partial class NewEMR : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static string getAppoitnmentInfo(int Patient_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var query = (from app in db.Appointment_Forms
                         where app.Reg_id == Patient_ID
                         && app.Status == "Booked"
                         orderby app.App_Date ascending
                         select new
                         {

                             AppointmentDate = app.App_Date,
                             doctor = (from emp in db.HR_Employees where emp.Emp_ID == Convert.ToInt32(app.Consultant_ID) select new { emp.Emp_Name }).FirstOrDefault()

                         }).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(query);
        }
        [WebMethod]
        public static string GetLastAppointmentVisit(int Patient_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var query = (from app in db.Appointment_Forms
                         where app.Reg_id == Patient_ID
                         && app.Status == "Visited"
                         orderby app.App_Date descending
                         select new
                         {
                             AppointmentDate = app.App_Date,
                             doctor = (from emp in db.HR_Employees
                                       where emp.Emp_ID == Convert.ToInt32(app.Consultant_ID)
                                       select new { emp.Emp_Name }).FirstOrDefault(),
                             Department = db.GetDataValueName("Patient Main Category", app.Sub_Department)
                         }).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(query);
        }
        [WebMethod]
        public static string GetBasicInfo(int Patient_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var query = (from rg in db.Reg_patients
                         where rg.Patient_No == Patient_ID
                         select new
                         {

                             Name = rg.Full_Name,
                             FatherName = rg.Father_Name,
                             Relation = rg.Relation_prefix,
                             Gender = rg.Gender,
                             DOB = rg.DOB,
                             Age = rg.Age_years,
                             MaritalStatus = rg.Martial_Status,
                             Mr_No = rg.mr_no_sequence,
                             pat_no = rg.Patient_No,
                             Address = rg.Permanent_Address /*"H# " + rg.House_No + " " + rg.stno_mno + " " + rg.area + " " + rg.city*/,
                             Mobile = rg.Mobile1,
                             CNIC = rg.NIC,
                             HouseNo = rg.House_No,
                             Area = rg.area,
                             StreetNo = rg.stno_mno,
                             City = rg.city,
                             ValArea = rg.val_area,
                             ValCity = rg.val_city,
                             Reg_PatientID = rg.pat_id,
                             opdCount = db.Patients.Count(count => count.Reg_PatId == Patient_ID)

                         }).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(query);
        }
        [WebMethod]
        public static string GetPatients(string searchValue)
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var patients = (from p in db.Reg_patients
                                    where (p.Patient_No != null && p.Patient_No.ToString().Contains(searchValue))
                                          || (p.Full_Name != null && p.Full_Name.Contains(searchValue))
                                    select new
                                    {
                                        PatientNo = p.Patient_No,
                                        FullName = p.Full_Name,
                                    }).Take(5).ToList();

                    return new JavaScriptSerializer().Serialize(patients);
                }
            }
            catch (Exception ex)
            {
                // Log error if needed
                return new JavaScriptSerializer().Serialize(new { error = ex.Message });
            }
        }
    }
}