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
    public partial class DiscountAssigned_List : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }


        [WebMethod]
        public static string Discount_Assigned_list()
        {
            string result = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = (from a in db.Discount_Assigned_Patients
                          


                             select new

                             {
                                 a.Discount_Assigned_Patient_Id,
                                 a.Patient_Id,
                                 Discount_Category_Id = db.GetDataValueName("Discount Category", a.Discount_Category_Id),
                                 a.Created_Time,
                                 Patient_No = (from data in db.Patients where data.Patient_ID == Convert.ToInt32(a.Patient_Id) select data.Patient_No).FirstOrDefault(),
                                 Patient_Name = (from data in db.Patients where data.Patient_ID == Convert.ToInt32(a.Patient_Id) select data.Full_Name).FirstOrDefault(),


                             }).ToList().OrderByDescending(x=>x.Discount_Assigned_Patient_Id);
                result = (new JavaScriptSerializer()).Serialize(query).ToString();
            }

            return result;
        }

    }
}