using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Services;
using System.Web.Script.Serialization;
using System.Text;
using System.Data;

namespace PMS
{
    public partial class Pharmacy_Users : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static int Save(string UserID, string btnsave, string UserCode, string Password, string Name, bool chkActive)
        {
            string userID = "";
            Pharmacy_User Obj = new Pharmacy_User();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            JavaScriptSerializer oJS = new JavaScriptSerializer();

            //if (btnSave == "Update")
            if (btnsave == "Update")
            {
                var Items = (from t in db.Pharmacy_Users
                             where t.UserID == int.Parse(UserID)
                             select t).FirstOrDefault();

                Items.User_Code = UserCode;
                Items.Password = Password;
                Items.UserName = Name;
                Items.IsActive = chkActive;

                db.SubmitChanges();
                userID = Items.UserID.ToString();

            }
            else
            {

                Obj.User_Code = UserCode;
                Obj.Password = Password;
                Obj.UserName = Name;
                Obj.IsActive = chkActive;
                userID = Obj.UserID.ToString();
                db.Pharmacy_Users.InsertOnSubmit(Obj);
                db.SubmitChanges();
            }

            return int.Parse(userID);
        }


        [WebMethod]
        public static string loadData(string ID)
        {
            string result = string.Empty;
            DataBaseDataContext db = new DataBaseDataContext();
            var itemsList = (from i in db.Pharmacy_Users
                             where i.UserID == Convert.ToInt32(ID)
                             select new
                             {
                                 i.UserID,
                                 i.User_Code,
                                 i.UserName,
                                 i.Password,
                                 i.IsActive

                             }).ToList();
            if (itemsList != null)
            {
                result = (new JavaScriptSerializer()).Serialize(itemsList);
            }
            return result;
        }


        [WebMethod]
        public static string GetAllCashierUsers()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var query = (from pds in db.Pharmacy_Users
                             //where pds.Item_ID.Equals(Item_ID)
                         select new
                         {

                             pds.User_Code

                         }).ToList();


            return (new JavaScriptSerializer()).Serialize(query);
        }


    }
}