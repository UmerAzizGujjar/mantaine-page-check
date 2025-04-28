using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class Assign_Hostel_Room : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                txtFrom_Date.Text = DateTime.Now.Date.ToString(AppConfig.DateFormat);
                txtTo_Date.Text = DateTime.Now.Date.ToString(AppConfig.DateFormat);
                txtRoom_Assigned_ID.Text = "(New)";

                BindingDropDown();


                if (Request.QueryString["ID"] != null)
                {
                    PopulateData(Convert.ToInt32(Request.QueryString["ID"]));

                }
            }
        }

        private void BindingDropDown()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            var Hostel = (from tbl1 in db.Hostels
                          select new {tbl1.Hostel_ID, tbl1.Hostel_No}).ToList();

            ddlHostel_ID.DataSource = Hostel;
            ddlHostel_ID.DataTextField = "Hostel_No";
            ddlHostel_ID.DataValueField = "Hostel_ID";
            ddlHostel_ID.Items.Add(new ListItem("Please Select", "0"));
            ddlHostel_ID.DataBind();

            DataTable dtEmp = DBClass.getDataTable("Select Emp_ID, CONCAT(Emp_ID, ' - ', Emp_Name) As E_Name from HR_Employees");

            ddlAssigned_Employee.DataSource = dtEmp;
            ddlAssigned_Employee.DataTextField = "E_Name";
            ddlAssigned_Employee.DataValueField = "Emp_ID";
            ddlAssigned_Employee.Items.Add(new ListItem("Please Select", "0"));
            ddlAssigned_Employee.DataBind();

        }

        private void PopulateData(int AHR_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            Assign_Hostel_Room AHR = (from tbl in db.Assign_Hostel_Rooms
                                      where tbl.Assign_Hostel_Room_ID == AHR_ID
                                      select tbl).FirstOrDefault();

            if (AHR != null)
            {
                txtRoom_Assigned_ID.Text = AHR.Assign_Hostel_Room_ID.ToString();
                ddlHostel_ID.SelectedValue = AHR.Hostel_ID.ToString();
                txtFloor_No.Text = AHR.Floor_No.ToString();
                txtRoom_No.Text = AHR.Room_No;
                ddlAssigned_Employee.SelectedValue = AHR.Assigned_Employee.ToString();
                txtTo_Date.Text = AHR.To_Date.Value.ToString(AppConfig.DateFormat);
                txtFrom_Date.Text = AHR.From_Date.Value.ToString(AppConfig.DateFormat);
                
                btnSave.Text = "Update";
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid)
                return;

            try
            {
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                Assign_Hostel_Room AHR = new Assign_Hostel_Room();
                if (btnSave.Text == "Save")
                {
                    AHR.Created_By = AppConfig.UserID;
                    AHR.Created_Time = DateTime.Now;
                    AHR.Book_ID = AppConfig.Book_ID;
                    AHR.Company_ID = AppConfig.Company_ID;
                }
                else
                {
                    AHR = (from tbl in db.Assign_Hostel_Rooms
                               where tbl.Assign_Hostel_Room_ID == Convert.ToInt32(Request.QueryString["ID"])
                               select tbl).FirstOrDefault();

                    AHR.Updated_By = AppConfig.UserID;
                    AHR.Updated_Time = DateTime.Now;
                }

                AHR.Hostel_ID = Convert.ToInt32(ddlHostel_ID.SelectedValue);
                AHR.Floor_No = Convert.ToInt32(txtFloor_No.Text);
                AHR.Room_No = txtRoom_No.Text;
                AHR.Assigned_Employee = Convert.ToInt32(ddlAssigned_Employee.SelectedValue);
                AHR.To_Date = Convert.ToDateTime(txtTo_Date.Text);
                AHR.From_Date = Convert.ToDateTime(txtFrom_Date.Text);
                

                if (btnSave.Text == "Save")
                {
                    db.Assign_Hostel_Rooms.InsertOnSubmit(AHR);
                    lblMessage.CssClass = "Data Inserted Successfully";

                }
                else
                {
                    lblMessage.CssClass = "Data Updated Successfully";
                }

                db.SubmitChanges();

                Response.Redirect("~/Assign_Hostel_Room_View.aspx", false);
                lblMessage.CssClass = "sucessfullMessage";
            }


            catch (Exception ex)
            {
                throw;
            }
        }
    }
}