using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class ConsultationBookingView : System.Web.UI.Page
    {
        protected override void OnInit(EventArgs e)
        {
            if (Session["Company_ID"] != null)
            {
                base.OnInit(e);

                string qury = @"Select Consultation_B_ID,Patient_ID, Consultation_Charges, Date, dbo.GetDataValueName('Medical Test', Recommended_Test) As Recommended_Test, dbo.GetDataValueName('Consultation Type', Consultation_Type) As Consultation_Type, Emp.Emp_Name As Doctor_Name
                                From Consultation_Booking As CB 
                                    Join HR_Employees As Emp 
                                    On CB.Doctor_Name=Emp.Emp_ID";
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
                    bool rowDeleted = DBClass.exectueQuery("Delete Consultation_Booking Where Consultation_B_ID=" + Convert.ToInt32(e.CommandArgument) + "", tranObj, con);
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
           // this.whdgList.RowIslandDataBinding += new RowIslandEventHandler(whdgList_RowIslandDataBinding);
        }
        //protected void whdgList_RowIslandDataBinding(object sender, RowIslandEventArgs e)
        //{
        //    // Sort a Column in PARENT BAND
        //    if (e.RowIsland.DataMember == "whdsList")
        //    {
        //        Sorting sort = e.RowIsland.Behaviors.Sorting;
        //        sort.SortedColumns.Add("ItemName", Infragistics.Web.UI.SortDirection.Descending);
        //    }

        //    // Sort a Column in CHILD BAND
        //    if (e.RowIsland.DataMember == "whdsList"
        //       && e.RowIsland.ParentRow == this.whdgList.GridView.Rows[1])
        //    {
        //        Sorting sort = e.RowIsland.Behaviors.Sorting;
        //        sort.SortedColumns.Add(e.RowIsland.Columns[1], Infragistics.Web.UI.SortDirection.Ascending);
        //    }
        //}
    }
}