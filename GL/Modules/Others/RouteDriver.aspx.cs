using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;

namespace PMS
{
    public partial class RouteDriver : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindingDropDown();
                if (Request.QueryString["ID"] != null)
                {
                     PopulateRouteDriverData(Convert.ToInt32(Request.QueryString["ID"]));
                }
            }
        }

        private void PopulateRouteDriverData(int _id)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            Route_Driver RouteDriver = (from tbl in db.Route_Drivers
                                        where tbl.RD_ID == _id
                                        select tbl).FirstOrDefault();


            ddlRoute_Name.SelectedValue = RouteDriver.Route_Name;
            ddlDriver.SelectedValue = RouteDriver.Driver_Name;
            ddlHelper.SelectedValue = RouteDriver.Helper_Name;
            

            btnSave.Text = "Update";

        }

        public void BindingDropDown()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            List<HR_Employee> DriverList = new List<HR_Employee>();
            DriverList = (from tbl in db.HR_Employees
                       where tbl.Designation == "006"
                       select tbl).ToList();


            ddlDriver.DataSource = DriverList;
            ddlDriver.DataTextField = "Emp_Name";
            ddlDriver.DataValueField = "Emp_ID";
            ddlDriver.Items.Add(new ListItem("Please Select", "0"));
            ddlDriver.DataBind();

            List<HR_Employee> HelperList = new List<HR_Employee>();

            DataTable Helpers = new DataTable();
            Helpers = DBClass.getDataTable("Select Emp.Emp_ID, Emp.Emp_Name From [dbo].[HR_Employees] As Emp Join [dbo].[DataValues] As DV On Emp.Designation = DV.DataValue_Name where DV.DataValue_Description = 'Helper'");
            ddlHelper.DataSource = Helpers;
            ddlHelper.DataTextField = "Emp_Name";
            ddlHelper.DataValueField = "Emp_ID";
            ddlHelper.Items.Add(new ListItem("Please Select", "0"));
            ddlHelper.DataBind();

            DataTable dtRoute = new DataTable();
            dtRoute = DBClass.getDataTable("Select Route_Name, Route_ID from Routes");
            ddlRoute_Name.DataSource = dtRoute;
            ddlRoute_Name.DataTextField = "Route_Name";
            ddlRoute_Name.DataValueField = "Route_ID";
            ddlRoute_Name.Items.Add(new ListItem("Please Select", "0"));
            ddlRoute_Name.DataBind();


        }
        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid)
                return;

            try
            {
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                Route_Driver rdObj = new Route_Driver();
                if (btnSave.Text == "Assign")
                {
                    rdObj.Created_By = AppConfig.UserID;
                    rdObj.Created_Time = DateTime.Now;
                    rdObj.Book_ID = AppConfig.Book_ID;
                    rdObj.Company_ID = AppConfig.Company_ID;

                }
                else
                {
                    rdObj = (from tbl in db.Route_Drivers
                             where tbl.RD_ID == Convert.ToInt32(Request.QueryString["ID"])
                             select tbl).FirstOrDefault();

                    rdObj.Updated_By = AppConfig.UserID;
                    rdObj.Updated_Time = DateTime.Now;
                }


                rdObj.Helper_Name = ddlDriver.SelectedValue;
                rdObj.Route_Name = ddlRoute_Name.SelectedValue;
                rdObj.Driver_Name = ddlHelper.SelectedValue;



                if (btnSave.Text == "Assign")
                {
                    db.Route_Drivers.InsertOnSubmit(rdObj);
                    lblMessage.CssClass = "Data Inserted Successfully";
                }
                else
                {
                    lblMessage.CssClass = "Data Updated Successfully";
                }

                db.SubmitChanges();
                lblMessage.CssClass = "sucessfullMessage";
                clearForm();
                Response.Redirect("~/RouteDriverView.aspx", false);

            }
            catch (Exception ex)
            {
                lblMessage.CssClass = ex.Message;
            }
        }
            public void clearForm()
             {
                 ddlRoute_Name.SelectedIndex = 0;
                 ddlDriver.SelectedIndex = 0;
                 ddlHelper.SelectedIndex = 0;
             }

            protected void btnClear_Click(object sender, EventArgs e)
            {
                clearForm();
            }
        
    }
}