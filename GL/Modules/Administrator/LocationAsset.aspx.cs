using GridMvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using Telerik.Pdf;

namespace PMS
{
    public partial class LocationAsset : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {                
            }
        }

        [WebMethod]
        public static int GetLocationNo()
        {
            int max = DBClass.getMaxEntry_No("Location", "Location_No");
            return max;
        }
        [WebMethod]
        public static string Savelocation( string Location_Code, string Location_Description, string btnValue)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            Location obj = new Location();
            Location query = new Location();
            var LocationNo = string.Empty;
            if (btnValue == "Save")
            {
                //obj.Location_No = Location_No;
                obj.Location_Code = Location_Code;
                obj.Location_Description = Location_Description;
                obj.Created_Time = DateTime.Now;
                obj.Created_By = AppConfig.UserID;
                obj.IsDeleted = false;
                db.Locations.InsertOnSubmit(obj);
            }
            //else
            //{
            //    query = (from data in db.Locations.Where(x => x.Location_No.Equals(Location_No))
            //             select data).FirstOrDefault();
            //    query.Location_Code = Location_Code;
            //    query.Location_Description = Location_Description;
            //    query.Updated_Time = DateTime.Now;
            //    query.Updated_By = AppConfig.UserID;

            //}
            try
            {
                db.SubmitChanges();
            }
            catch (Exception)
            {
                return "Error";
            }
            //LocationNo = Convert.ToString(obj.Location_No);
            //if (LocationNo == "0")
            //{
            //    LocationNo = Convert.ToString(query.Location_No);
            //}
            return "Success-" + LocationNo;
        }
        [WebMethod]
        public static string Loadlocation(int ID)
        {
            string result = string.Empty;
            if (ID > 0)
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var query = (from loc in db.Locations                                 
                                 //where loc.Location_No == ID && loc.IsDeleted == false
                                 select new
                                 {
                                     loc.Location_ID,
                                     //loc.Location_No,
                                     loc.Location_Code,
                                     loc.Location_Description,                                    
                                 }).FirstOrDefault();
                    result = (new JavaScriptSerializer()).Serialize(query).ToString();
                }
            }
            return result;
        }
    }
}