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
    public partial class UltrasoundFooter : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static string LoadLabFooter()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from i in db.DataValues
                              where i.ValueSet_ID == 2126
                              select i.DataValue_Description).FirstOrDefault();
                return (new JavaScriptSerializer()).Serialize(result);
            }
        }
        [WebMethod]
        public static string LoadLabFooterTwo()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from i in db.DataValues
                              where i.ValueSet_ID == 2127
                              select i.DataValue_Description).FirstOrDefault();
                return (new JavaScriptSerializer()).Serialize(result);
            }
        }
        [WebMethod]
        public static string SaveLabFooter(string Labfooter, string LabfooterTwo)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            DataValue dt = new DataValue();
            string Query = "delete from DataValues where ValueSet_ID = 2126";
            DBClass.executeNonQueryWithoutBegin(Query);
            dt.ValueSet_ID = 2126;
            dt.DataValue_Name = "001";
            dt.DataValue_Description = Labfooter.ToString();
            db.DataValues.InsertOnSubmit(dt);
            db.SubmitChanges();
            string QueryFt = "delete from DataValues where ValueSet_ID = 2127";
            DBClass.executeNonQueryWithoutBegin(QueryFt);
            DataValue dtf = new DataValue();
            dtf.ValueSet_ID = 2127;
            dtf.DataValue_Name = "001";
            dtf.DataValue_Description = LabfooterTwo.ToString();
            db.DataValues.InsertOnSubmit(dtf);
            db.SubmitChanges();
            return "Successfull";
        }
    }
}