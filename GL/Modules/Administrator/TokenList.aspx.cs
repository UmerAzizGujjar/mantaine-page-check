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
    public partial class TokenList : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

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
        public static string PatientType()
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
        public static string LoadTokenPatient()
        {
            var user_id = AppConfig.UserID;
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.sp_token_list();
            return (new JavaScriptSerializer()).Serialize(Details);
        }
        [WebMethod]
        public static string LoadTokenPatientFilter(string patientType , string department)
        {
            var user_id = AppConfig.UserID;
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.sp_token_list_filter(patientType, department);
            return (new JavaScriptSerializer()).Serialize(Details);
        }

        [WebMethod]

        public static string getfilter()
        {
            var user_id = AppConfig.UserID;
            DataBaseDataContext db = new DataBaseDataContext();

            var WareHouse = db.Sp_GetWareHouseByBranchId(user_id);
            return (new JavaScriptSerializer()).Serialize(WareHouse);
        }
        [WebMethod]

        public static string getdoctor()
        {
            var user_id = AppConfig.UserID;
            DataBaseDataContext db = new DataBaseDataContext();

            var WareHouse = db.Sp_GetDoctorByUsingId(user_id);
            return (new JavaScriptSerializer()).Serialize(WareHouse);
        }
        [WebMethod]
        public static string LoadDocTokenPatient()
        {
            var user_id = AppConfig.UserID;
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.sp_token_doc_list(user_id);
            return (new JavaScriptSerializer()).Serialize(Details);
        }
        [WebMethod]
        public static bool isprivate()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var user_id = AppConfig.UserID;
            bool value = Convert.ToBoolean(DBClass.getField("select isnull(isprivate,0) from User_Branch where User_id ='" + user_id + "'"));
            return value;

        }


    }
}