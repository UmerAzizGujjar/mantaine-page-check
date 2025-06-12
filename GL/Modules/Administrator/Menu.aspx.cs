using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;
using System.Web.Script.Serialization;
using System.Web.Services;

namespace PMS
{
    public partial class Menu : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            
        }

        [WebMethod]
        public static string PopulateMenuData(int id)
        {
            DataTable dt = new DataTable();
            string qury = "select * from Menus where Menu_ID = " + id;
            dt = DBClass.getDataTable(qury);
            string data = string.Empty;

            var details = new
            {
                MenuName = dt.Rows[0]["Menu_Name"].ToString(),
                MenuDescription = dt.Rows[0]["Menu_Description"].ToString(),
                URL = dt.Rows[0]["URL"].ToString(),
                ParentID = dt.Rows[0]["Parent_ID"].ToString(),
                OrderBy = dt.Rows[0]["Order_By"].ToString(),
                IsActive = Convert.ToBoolean(dt.Rows[0]["IsActive"]),
                BtnText = "Update",
            };
            data = new JavaScriptSerializer().Serialize(details);
            return data;
        }

        [WebMethod]
        public static string BindParentMenu()
        {
            string data = string.Empty;
            DataTable dt = new DataTable();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var menu = (from tbl in db.Menus
                        select new
                        {
                            ParentID = tbl.Menu_ID,
                            ParentName = tbl.Menu_Description,
                        }).ToList();
            data = new JavaScriptSerializer().Serialize(menu);
            return data;

        }

        [WebMethod]

        public static string btnSave_Click(MenuData data)
        {


            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            Menus menu;

            if (data.BtnText == "Save")
            {
                menu = new Menus();
            }
            else
            {
                menu = (from tbl in db.Menus
                        where tbl.Menu_ID == Convert.ToInt32(data.updateID)
                        select tbl).FirstOrDefault();
            }

            menu.Menu_Name = data.MenuName;
            menu.Menu_Description = data.MenuDescription;
            menu.URL = data.URL;
            menu.Parent_ID = Convert.ToInt32(data.ParentID);
            menu.Order_By = Convert.ToInt32(data.OrderBy);
            if (data.IsActive == true)
                menu.IsActive = true;
            else
                menu.IsActive = false;

            if (data.BtnText == "Save")
            {
                db.Menus.InsertOnSubmit(menu);

            }

            db.SubmitChanges();

            return data.ParentID;



        }
        public class MenuData
        {
            public string MenuName { get; set; }
            public string MenuDescription { get; set; }
            public string URL { get; set; }
            public string ParentID { get; set; }
            public string OrderBy { get; set; }
            public bool IsActive { get; set; }
            public string BtnText { get; set; }
            public string updateID { get; set; }

        }
    }
}