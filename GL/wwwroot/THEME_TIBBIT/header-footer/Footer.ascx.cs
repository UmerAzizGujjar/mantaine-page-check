using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.wwwroot.Tibbit_theme.header_footer
{
    public partial class Footer : System.Web.UI.UserControl
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            DataBaseDataContext db = new DataBaseDataContext();
             mbl_no.InnerText = (from a in db.sys_Companies  select a.Company_Phone1).FirstOrDefault();
             email.InnerText = (from a in db.sys_Companies  select a.Company_Email).FirstOrDefault();
        }
    }
}