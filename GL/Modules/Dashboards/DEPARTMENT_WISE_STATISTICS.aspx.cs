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
    public partial class DEPARTMENT_WISE_STATISTICS : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static string GetTotalDepartment(string txt_sdate, string txt_edate,string Doctor)
        {
            string result = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.sp_loadPatientsDepartmentWise(Doctor,txt_sdate, txt_edate).ToList();


                result = (new JavaScriptSerializer()).Serialize(query);
            }

            return result;
        }
        [WebMethod]
        public static string LoadDepartmenr()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
           
         var  EmpList = (from tbl in db.ValueSets
                      join Dv in db.DataValues on
                      tbl.ValueSet_ID equals Dv.ValueSet_ID where
                      tbl.ValueSet_Description =="Patient Main Category"
                       select new
                       {
                           Dv.DataValue_Name,
                           Dv.DataValue_Description
                       } ).ToList();
            return (new JavaScriptSerializer().Serialize(EmpList));
        }
    }
}