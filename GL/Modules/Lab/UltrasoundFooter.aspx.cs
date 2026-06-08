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
    public partial class UltrasoundFooter : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static string GetDoctors()
        {
            var db = new DataBaseDataContext();
            var userId = Convert.ToString(AppConfig.UserID);

            // Check permission
            var canSeeAllDoctors = db.aspnet_Users
                .Any(u => u.UserId == AppConfig.UserID && u.All_doctor_template == true);

            // Get doctors
            var doctors = db.HR_Employees
                .Where(e => e.IsDoctor == true && (canSeeAllDoctors || e.userid == userId))
                .OrderBy(e => e.Emp_Name)
                .Select(e => new
                {
                    e.Emp_ID,
                    Emp_Name = e.Emp_Name.Replace("Dr.", "").Replace("Prof.", "")
                })
                .ToList();

            return new JavaScriptSerializer().Serialize(doctors);
        }

        [WebMethod]
        public static string LoadLabFooterTEmandid(string id)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from i in db.DataValues
                              where (i.ValueSet_ID == 2126 || i.ValueSet_ID == 2127)  && i.DataValue_Name == id
                              select new
                              {
                                  
                                  DoctorId = i.DataValue_Name,
                                  TemplateName = i.Segment2
                              }).FirstOrDefault();
                return (new JavaScriptSerializer()).Serialize(result);
            }
        }
        [WebMethod]
        public static string LoadLabFooter(string id)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from i in db.DataValues
                              where i.ValueSet_ID == 2126 && i.DataValue_Name == id
                              select new
                              {
                                  i.DataValue_Description,
                        
                              }).FirstOrDefault();
                return (new JavaScriptSerializer()).Serialize(result);
            }
        }
        [WebMethod]
        public static string LoadLabFooterTwo(string id)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from i in db.DataValues
                              where i.ValueSet_ID == 2127 && i.DataValue_Name == id
                              select i.DataValue_Description).FirstOrDefault();
                return (new JavaScriptSerializer()).Serialize(result);
            }
        }
        [WebMethod]
        public static string SaveLabFooter(string Labfooter, string LabfooterTwo, string DoctorName, string DoctorId, string TemplateName)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            DataValue dt = new DataValue();
            //string Query = "delete from DataValues where ValueSet_ID = 2126 and DataValue_Name ='"+ DoctorId + "';
            string Query = "DELETE FROM DataValues WHERE ValueSet_ID = 2126 AND DataValue_Name = '" + DoctorId + "'" ;
            DBClass.executeNonQueryWithoutBegin(Query);
            dt.ValueSet_ID = 2126;
            dt.DataValue_Name = DoctorId;
            dt.DataValue_Description = Labfooter.ToString();
            dt.Segment1 = DoctorName;
            dt.Segment2 = TemplateName;
           // dt.Segment3 = LabfooterTwo.ToString(); 
            db.DataValues.InsertOnSubmit(dt);
            db.SubmitChanges();
           // string QueryFt = "delete from DataValues where ValueSet_ID = 2127";
            string QueryFt = "DELETE FROM DataValues WHERE ValueSet_ID = 2127 AND DataValue_Name = '" + DoctorId + "'";
            DBClass.executeNonQueryWithoutBegin(QueryFt);
            DataValue dtf = new DataValue();
            dtf.ValueSet_ID = 2127;
            dtf.DataValue_Name = DoctorId;
            dtf.Segment1 = DoctorName;
            dtf.Segment2 = TemplateName;
            dtf.DataValue_Description = LabfooterTwo.ToString();
            db.DataValues.InsertOnSubmit(dtf);
            db.SubmitChanges();
            return "Successfull";
        }
    }
}