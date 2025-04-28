using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Data.SqlClient;

namespace PMS
{
    public partial class Hospital : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindDropDownlist();
                BlankForm();

                if (Request.QueryString["ID"] != null)
                {
                    LoadHostelsData(Convert.ToInt32(Request.QueryString["ID"]));

                }
            }
           
        }

        private void BindDropDownlist()
        {
            object valueset;

            valueset = DBClass.GetValueSet("Building Type");

            ddlBuildingType.DataSource=valueset;
            ddlBuildingType.DataTextField = "DataValue_Description";
            ddlBuildingType.DataValueField = "DataValue_Name";
            ddlBuildingType.Items.Add(new ListItem("Please Select", "0"));
            ddlBuildingType.DataBind();


            
            valueset = DBClass.GetValueSet("Hostel Type");

            ddlHostelType.DataSource = valueset;
            ddlHostelType.DataTextField = "DataValue_Description";
            ddlHostelType.DataValueField = "DataValue_Name";
            ddlHostelType.Items.Add(new ListItem("Please Select", "0"));
            ddlHostelType.DataBind();

            DataBaseDataContext db = new DataBaseDataContext();
            DataTable dt = new DataTable();
            dt = DBClass.getDataTable("select Emp_ID,Emp_name from HR_Employees join DataValues on DataValues.DataValue_Description = 'Warden' where HR_Employees.Designation = DataValues.DataValue_Name");
            
            ddlWarden.DataSource = dt;
            ddlWarden.DataTextField = "Emp_name";
            ddlWarden.DataValueField = "Emp_ID";
            ddlWarden.Items.Add(new ListItem("Please Select", "0"));
            ddlWarden.DataBind();

        }

        private void BlankForm()
        {
            txtHostel_ID.Text="(New)";
            txtHostel_No.Text="";
            txtName.Text="";
            ddlBuildingType.SelectedIndex=0;
            ddlHostelType.SelectedIndex=0;
            txtFloor.Text="";
            txtRooms.Text="";
            txtLocation.Text="";
            ddlWarden.SelectedIndex=0;

        }

        private void LoadHostelsData(int Hstl_id)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            Hostel hstl = (from tbl in db.Hostels
                             where tbl.Hostel_ID == Hstl_id
                             select tbl).FirstOrDefault();
            txtHostel_No.Text =Convert.ToString( hstl.Hostel_No);
            txtName.Text = hstl.Name;
            ddlBuildingType.SelectedValue = hstl.Building_Type;
            ddlHostelType.SelectedValue = hstl.Hostel_Type;
            txtFloor.Text =Convert.ToString( hstl.No_of_Floors);
            txtRooms.Text = Convert.ToString(hstl.No_of_Rooms);
            txtLocation.Text = hstl.Location;
            ddlWarden.SelectedValue = hstl.Warden;

            btnSave.Text = "Update";
        }

        protected void btnBack_Click(object sender, EventArgs e)
        {
            Response.Redirect("HostelView.aspx");
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                DataBaseDataContext db = new DataBaseDataContext();
                if (btnSave.Text == "Save")
                {
                    Hostel hstl = new Hostel();

                    if (txtHostel_No.Text != "")
                    {
                        hstl.Hostel_No = Convert.ToInt32(txtHostel_No.Text);

                    }
                    hstl.Name = txtName.Text;
                    hstl.Building_Type = ddlBuildingType.SelectedValue;
                    hstl.Hostel_Type = ddlHostelType.SelectedValue;
                    if (txtFloor.Text != "")
                    {
                        hstl.No_of_Floors = Convert.ToInt32(txtFloor.Text);
                    }
                    if (txtRooms.Text != "")
                    {
                        hstl.No_of_Rooms = Convert.ToInt32(txtRooms.Text);
                    }
                    hstl.Location = txtLocation.Text;
                    hstl.Warden = ddlWarden.SelectedValue;


                    hstl.Created_By = AppConfig.UserID;
                    hstl.Created_Time = DateTime.Now;
                    hstl.Book_ID = AppConfig.Book_ID;
                    hstl.Company_ID = AppConfig.Company_ID;
                   

                    db.Hostels.InsertOnSubmit(hstl);
                    db.SubmitChanges();
                    BlankForm();
                }
                else
                {
                    if (Request.QueryString["ID"] != null)
                    {
                        int id = Convert.ToInt32(Request.QueryString["ID"]);
                        Hostel hstl = new Hostel();
                        hstl = (from tbl in db.Hostels
                                where tbl.Hostel_ID == id
                                select tbl).FirstOrDefault();
                      
                        hstl.Hostel_No = Convert.ToInt32(txtHostel_No.Text);
                        hstl.Name = txtName.Text;
                        hstl.Building_Type = ddlBuildingType.SelectedValue;
                        hstl.Hostel_Type = ddlHostelType.SelectedValue;
                        hstl.No_of_Floors = Convert.ToInt32(txtFloor.Text);
                        hstl.No_of_Rooms = Convert.ToInt32(txtRooms.Text);
                        hstl.Location = txtLocation.Text;
                        hstl.Warden = ddlWarden.SelectedValue;

                        hstl.Updated_By = AppConfig.UserID;
                        hstl.Updated_Time = DateTime.Now;

                        //db.HR_Shifts.InsertOnSubmit(shft);
                        db.SubmitChanges();
                        BlankForm();
                    }
                }

                Response.Redirect("HostelView.aspx");

            }
            catch (Exception ex)
            {
                throw;
            }
        }
    }
}