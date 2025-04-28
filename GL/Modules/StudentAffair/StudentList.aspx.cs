using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.StudentAffair
{
    public partial class StudentList : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static string Student_Master()
        {
            string result = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = (from a in db.Students
                             select new
                             {
                                 a.Student_ID,
                                 a.Student_Code,
                                 a.Student_Name,
                                 a.Roll_No,
                                 a.Phone,
                                 a.Address,
                                 a.Date,

                             }).ToList().Distinct();
                result = (new JavaScriptSerializer()).Serialize(query).ToString();
            }
            return result;
        }

        [WebMethod]
        public static bool DeleteRecord(string stuid)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            SqlTransaction tranObj = null;
            SqlConnection con = new SqlConnection(DBClass.ConnectionString());
            con.Open();
            tranObj = con.BeginTransaction();
            try
            {
                var Stu_ID = (from itm in db.Students
                              where (itm.Student_ID == int.Parse(stuid))
                              select itm.Student_ID).FirstOrDefault();
                if (Stu_ID != 0)
                {
                    //                    DBClass.exectueQuery("delete Purchase_Invoice_Detail where PurchaseInvoiceId =" + Stu_ID, tranObj, con);
                    DBClass.exectueQuery("delete Student where Student_ID =" + Stu_ID, tranObj, con);
                    tranObj.Commit();
                }
                else
                {
                    tranObj.Rollback();
                    return false;
                }
            }
#pragma warning disable CS0168 // The variable 'ex' is declared but never used
            catch (Exception ex)
#pragma warning restore CS0168 // The variable 'ex' is declared but never used
            {
                if (tranObj != null)
                    tranObj.Rollback();
                return false;
            }
            return true;
        }

    }
}