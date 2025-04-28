using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.Administrator
{
    public partial class API : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static string SaveApiCredentials(string username, string password)
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    ApiCredential api = new ApiCredential(); 
                    api.UserName = username;
                    api.Password = password;
                    api.created_time = DateTime.Now;
                    api.created_by = AppConfig.UserID;
                    db.ApiCredentials.InsertOnSubmit(api); 
                    db.SubmitChanges();

                    return api.API_ID.ToString();
                }
            }
            catch (Exception ex)
            {
               
                return "Error: " + ex.Message;
            }
        }


    }
}