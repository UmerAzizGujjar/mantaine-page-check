using System;
using System.Data.SqlClient;

namespace PMS
{
    public partial class HostelsView : System.Web.UI.Page
    {
        protected override void OnInit(EventArgs e)
        {
            if (Session["Company_ID"] != null)
            {
                base.OnInit(e);
                string qury = "SELECT Hostel_ID,Hostel_No, Name,dbo.GetDataValueName('Building Type', Building_Type) As Building_Type, dbo.GetDataValueName('Hostel Type', Hostel_Type) As Hostel_Type,No_of_Floors,No_of_Rooms,Location, (Select Emp_Name from HR_Employees where HR_Employees.Emp_ID = Hostels.Warden )as Warden From Hostels ";
                //string qury = "select * from Hostels";
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
                    bool rowDeleted = DBClass.exectueQuery("Delete Hostels Where Hostel_ID=" + Convert.ToInt32(e.CommandArgument) + "", tranObj, con);
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