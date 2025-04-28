using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class About : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public void DeleteInPatient()
        {
            //db.In_Patients.DeleteOnSubmit(inPatient);
            //db.SubmitChanges();
            //Context.Response.Write(js.Serialize(new { Message = "Deleted Successfully." }));
        }
    }
}
