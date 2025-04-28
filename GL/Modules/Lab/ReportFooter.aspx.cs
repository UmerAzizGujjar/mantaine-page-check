using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Script.Serialization;
using System.Web.Script.Services;

namespace PMS
{
    public partial class ReportFooter : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static string Save(string Reportfooter, string ReportfooterTow)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            DataValue dt = new DataValue();
            string Query = "delete from DataValues where ValueSet_ID = 2121";
            DBClass.executeNonQueryWithoutBegin(Query);
            dt.ValueSet_ID = 2121;
            dt.DataValue_Name = "001";
            dt.DataValue_Description = Reportfooter.ToString();
            db.DataValues.InsertOnSubmit(dt);
            db.SubmitChanges();
            string QueryFt = "delete from DataValues where ValueSet_ID = 2122";
            DBClass.executeNonQueryWithoutBegin(QueryFt);
            DataValue dtf = new DataValue();
            dtf.ValueSet_ID = 2122;
            dtf.DataValue_Name = "001";
            dtf.DataValue_Description = ReportfooterTow.ToString();
            db.DataValues.InsertOnSubmit(dtf);
            db.SubmitChanges();

            return "Successfull";
        }
        [WebMethod]
        public static string LoadReportFooter()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Footer = DBClass.getField("select DataValue_Description from DataValues where ValueSet_ID = 2121").ToString();
            return (new JavaScriptSerializer()).Serialize(Footer);
        }
        [WebMethod]
        public static string LoadReportFooterTow()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var FooterTow = DBClass.getField("select DataValue_Description from DataValues where ValueSet_ID = 2122").ToString();

            return (new JavaScriptSerializer()).Serialize(FooterTow);
        }
    }
}