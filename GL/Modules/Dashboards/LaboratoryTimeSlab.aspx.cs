using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.Dashboards
{
    public partial class LaboratoryTimeSlab : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        public class LabTimeSlabDTO
        {
            public string MR_No { get; set; }
            public string Patient_Name { get; set; }
            public string Bill_Date { get; set; }
            public string Sample_Date { get; set; }
            public string Lab_Date { get; set; }
            public string Report_Date { get; set; }
            public string Approve_Date { get; set; }
            public int Total_Time_Spent_Minutes { get; set; }
            public string Total_Time_Spent { get; set; }
        }

        [WebMethod]
        public static string ViewList(string txt_sdate, string txt_edate)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                string query = "EXEC [dbo].[sp_GetLaboratoryTimeSlab_Details] @StartDate = {0}, @EndDate = {1}";

                
                var result = db.ExecuteQuery<LabTimeSlabDTO>(query, txt_sdate, txt_edate).ToList();

                var serializer = new JavaScriptSerializer();
                serializer.MaxJsonLength = int.MaxValue;

                return serializer.Serialize(result);
            }
        }
    }
}