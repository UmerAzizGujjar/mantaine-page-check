using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.SqlClient;

namespace PMS
{
    public partial class ShiftView : System.Web.UI.Page
    {
        protected override void OnInit(EventArgs e)
        {
            if (Session["Company_ID"] != null)
            {
                base.OnInit(e);
                string qury = "SELECT Shift_Assign.Shift_Assign_ID, CONCAT(HR_Employees.Emp_ID, ' - ', HR_Employees.Emp_Name) As Nurse, HR_Shifts.Shift_Name ,Shift_Assign.Employee, HR_Shifts.Time_From, HR_Shifts.Time_To,Shift_Assign.Remark,  Shift_Assign.From_Date ,  Shift_Assign.To_Date  FROM  Shift_Assign JOIN HR_Shifts ON Shift_Assign.Shift_ID = HR_Shifts.Shift_ID JOIN HR_Employees ON Shift_Assign.Employee = HR_Employees.Emp_ID";
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
                    bool rowDeleted = DBClass.exectueQuery("Delete Shift_Assign Where Shift_Assign_ID =" + Convert.ToInt32(e.CommandArgument) + "", tranObj, con);
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
    }
}