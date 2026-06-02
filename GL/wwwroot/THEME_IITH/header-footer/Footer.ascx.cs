using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.wwwroot.IITH_Theme.header_footer
{
    public partial class Footer : System.Web.UI.UserControl
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            mbl_no.InnerText = (from a in db.aspnet_Users where a.UserId == AppConfig.UserID select a.mobileno).FirstOrDefault();
            email.InnerText = (from a in db.aspnet_Memberships where a.UserId == AppConfig.UserID select a.Email).FirstOrDefault();
        }
    }
}