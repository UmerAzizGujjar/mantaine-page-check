using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Account
{
    public partial class UserDoctorControlList : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static string LoadMaster()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var query = (from data in db.User_Branch_Masters
                         where data.user_id != null && data.user_id != null
                         && data.isprivate == true
                         select new
                         {
                             data.Created_Time,
                             data.User_Branch_Master_Id,
                             data.user_id,
                             user_name = DBClass.getField("select username from aspnet_Users where UserId='" + data.user_id + "'")
                         }).ToList();

            return (new JavaScriptSerializer()).Serialize(query);

        }
        [WebMethod]
        public static bool DeleteRecord(string Id)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            User_Branch_Master st = new User_Branch_Master();
            User_Branch stkItem = new User_Branch();

            SqlTransaction tranObj = null;
            SqlConnection con = new SqlConnection(DBClass.ConnectionString());
            con.Open();
            tranObj = con.BeginTransaction();
            try
            {
                var MainId = (from itm in db.User_Branch_Masters
                              where (itm.User_Branch_Master_Id == int.Parse(Id))
                              select itm.User_Branch_Master_Id).FirstOrDefault();
                if (MainId != 0)
                {
                    DBClass.exectueQuery("delete User_Branch  where User_Branch_Master_Id =" + MainId, tranObj, con);
                    DBClass.exectueQuery("delete User_Branch_Master where User_Branch_Master_Id =" + MainId, tranObj, con);


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