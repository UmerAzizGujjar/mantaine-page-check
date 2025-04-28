using Infragistics.Web.UI.GridControls;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class BillingView : System.Web.UI.Page
    {
        protected override void OnInit(EventArgs e)
        {
            if (Session["Company_ID"] != null)
            {
                base.OnInit(e);

                string qury = "Select PBD.Patient_Bill_Dtl_ID, PBD.Patient_ID, PAT.Full_Name, PAT.Patient_Total_Bill From Patient_Billing_Dtl As PBD Join Patients As PAT On PBD.Patient_ID = PAT.Patient_ID";
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
                SqlTransaction tranObj2 = null;
                SqlConnection con = new SqlConnection(DBClass.ConnectionString());
                SqlConnection con2 = new SqlConnection(DBClass.ConnectionString());
                con.Open();
                con2.Open();
                tranObj = con.BeginTransaction();
                tranObj2 = con2.BeginTransaction();
                try
                {
                    bool rowDeleted = DBClass.exectueQuery("Delete Patient_Billing_Dtl Where Patient_ID=" + Convert.ToInt32(e.CommandArgument) + "", tranObj, con);
                    bool rowUpdated = DBClass.exectueQuery("UPDATE Patients SET Patient_Total_Bill=null WHERE Patient_ID=" + Convert.ToInt32(e.CommandArgument) + "", tranObj2, con2);
                    
                    if (rowDeleted && rowUpdated)
                    {
                        Response.Redirect(Request.RawUrl, false);
                        upList.Update();
                    }
                    tranObj.Commit();
                    tranObj2.Commit();
                }
                catch (Exception exc)
                {
                    if (tranObj != null)
                        tranObj.Rollback();
                    if (tranObj2 != null)
                        tranObj2.Rollback();
                    throw new Exception(exc.Message);
                }
                finally
                {
                    con.Close();
                    con2.Close();
                }
            }
        }

        protected void whdgList_RowIslandsPopulating(object sender, Infragistics.Web.UI.GridControls.ContainerRowCancelEventArgs e)
        {
            this.whdgList.RowIslandDataBinding += new RowIslandEventHandler(whdgList_RowIslandDataBinding);
        }

        protected void whdgList_RowIslandDataBinding(object sender, RowIslandEventArgs e)
        {
            // Sort a Column in PARENT BAND
            if (e.RowIsland.DataMember == "whdsList")
            {
                Sorting sort = e.RowIsland.Behaviors.Sorting;
                sort.SortedColumns.Add("ItemName", Infragistics.Web.UI.SortDirection.Descending);
            }

            // Sort a Column in CHILD BAND
            if (e.RowIsland.DataMember == "whdsList"
               && e.RowIsland.ParentRow == this.whdgList.GridView.Rows[1])
            {
                Sorting sort = e.RowIsland.Behaviors.Sorting;
                sort.SortedColumns.Add(e.RowIsland.Columns[1], Infragistics.Web.UI.SortDirection.Ascending);
            }
        }
    }
}