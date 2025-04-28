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
    public partial class Pharmacy_UserView : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }



        [WebMethod]
        public static string ViewList()
        {
            string result = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = (from ph in db.Pharmacy_Users

                             select new
                             {
                                 ph.UserID,
                                 ph.User_Code,
                                 ph.UserName
                             }).ToList();
                result = new JavaScriptSerializer().Serialize(query).ToString();

            }
            return result;
        }



    }
}