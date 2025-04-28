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
    public partial class EndoscopyList : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static string GetEndoscopies()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var endoscopies = (from e in db.PT_Endoscopies
                               select e);
            return (new JavaScriptSerializer()).Serialize(endoscopies);
        }

        [WebMethod]
        public static void DeleteEndoscopy(int id)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var endoscopy = (from e in db.PT_Endoscopies
                             where e.Endoscopy_ID == id
                             select e).FirstOrDefault();
            db.PT_Endoscopies.DeleteOnSubmit(endoscopy);
            db.SubmitChanges();

            var gastros = (from g in db.EN_Gastros
                           where g.Endoscopy_ID == id
                           select g).ToList();
            db.EN_Gastros.DeleteAllOnSubmit(gastros);
            db.SubmitChanges();

            var colonos = (from c in db.EN_Colonos
                           where c.Endoscopy_ID == id
                           select c).ToList();
            db.EN_Colonos.DeleteAllOnSubmit(colonos);
            db.SubmitChanges();
        }
    }
}