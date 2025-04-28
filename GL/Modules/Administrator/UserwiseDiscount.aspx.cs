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
    public partial class UserwiseDiscount : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static string FillUsers()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var query = (from users in db.aspnet_Users
                         select new
                         {
                             users.UserId,
                             users.UserName,
                             Discount=DBClass.getField("select Discount from aspnet_Users where UserId='" + users.UserId + "'"),
                             Discount_Amt = DBClass.getField("select Discount_Amount from aspnet_Users where UserId='" + users.UserId + "'"),

                         }).ToList();

            return (new JavaScriptSerializer()).Serialize(query);
        }
        [WebMethod]
        public static string Save(string User_Id, string Discount,string Discount_Amt)
        {
            int result = DBClass.executeNonQueryWithoutBegin("update aspnet_Users set Discount='" + Discount + "',Discount_Amount='" + Discount_Amt + "' where UserId='" + User_Id+"'");
            if (result == 1)
            {
                return "success";
            }
            else
            {
                return "error";
            }
        }

        }
}