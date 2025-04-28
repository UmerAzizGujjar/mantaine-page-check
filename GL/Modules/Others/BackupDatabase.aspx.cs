using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class BackupDatabase : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                SqlTransaction tranObj = null;
                SqlConnection con = new SqlConnection(DBClass.ConnectionString());
                con.Open();
                tranObj = con.BeginTransaction();
                try
                {
                    string DB_BackUp = DBClass.DataBaseName();
                    if (!System.IO.Directory.Exists(Server.MapPath("~/App_Data/DB_BackUp")))
                    {
                        System.IO.Directory.CreateDirectory(Server.MapPath("~/App_Data/DB_BackUp"));
                    }
                    string completePath = Server.MapPath("~/App_Data/DB_BackUp"); //this.Server.MapPath(this.Request.ApplicationPath).Replace("/", "\\");

                    string destdir = completePath; //+ "DB_BackUp";
                    string query = "Backup Database " + DB_BackUp + " To Disk='" + destdir + "\\" + DB_BackUp + "_" + DateTime.Now.ToString("dd-MM-yyy") + ".bak'";

                    //DBClass.exectueQuery(query, tranObj, con);
                    DBClass.executeNonQueryWithoutBegin(query);
                    //tranObj.Commit();
                    lblMessage.Text = "Backup Database is created successfully. ";
                    lblMessage.CssClass = "sucessfullMessage";
                }
                catch (Exception ex)
                {
                    if (tranObj != null)
                        tranObj.Rollback();
                    lblMessage.Text = ex.Message;
                    lblMessage.CssClass = "errorMessage";
                }
                finally
                {
                    con.Close();
                }
            }
        }
    }
}