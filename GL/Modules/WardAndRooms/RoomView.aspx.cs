using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class RoomView : System.Web.UI.Page
    {

        protected override void OnInit(EventArgs e)
        {
            if (Session["Company_ID"] != null)
            {
                base.OnInit(e);
                string qury = "SELECT Room_ID,Room_No, Name,dbo.GetDataValueName('Building Type', Building_Type) As Building_Type, dbo.GetDataValueName('Room Type', Room_Type) As Room_Type,Floor_No,Location, (Select Emp_Name from HR_Employees where HR_Employees.Emp_ID = Rooms.Warden )as Warden From Rooms ";
                sqlList.SelectCommand = qury;
                this.sqlList.ConnectionString = DBClass.ConnectionString();
            }
            else
            {
                Session.Abandon();
                Response.Redirect("~/Account/Login.aspx", true);
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void whdgList_ItemCommand(object sender, Infragistics.Web.UI.GridControls.HandleCommandEventArgs e)
        {
            if (e.CommandName == "Remove")
            {
                SqlTransaction tranObj = null;
                SqlConnection con = new SqlConnection(DBClass.ConnectionString());
                con.Open();
                tranObj = con.BeginTransaction();
                try
                {
                    bool rowDeleted = DBClass.exectueQuery("Delete Rooms Where Room_ID=" + Convert.ToInt32(e.CommandArgument) + "", tranObj, con);
                    if (rowDeleted)
                    {
                        Response.Redirect(Request.RawUrl, false);
                        upList.Update();
                    }
                    tranObj.Commit();
                }
                catch (Exception exc)
                {
                    if (tranObj != null)
                        tranObj.Rollback();
                    throw new Exception(exc.Message);
                }
                finally
                {
                    con.Close();
                }
            }
        }

        protected void whdgList_RowIslandsPopulating(object sender, Infragistics.Web.UI.GridControls.ContainerRowCancelEventArgs e)
        {
            //this.whdgList.RowIslandDataBinding += new RowIslandEventHandler(whdgList_RowIslandDataBinding);
        }

    }
}