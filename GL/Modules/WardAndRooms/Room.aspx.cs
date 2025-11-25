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
    public partial class Room : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BlankForm();
                BindDropDownlist();
                
                if (Request.QueryString["ID"] != null)
                {
                    LoadRoomData(Convert.ToInt32(Request.QueryString["ID"]));

                }
            }
        }

        private void BindDropDownlist()
        {
            object valueset;

            valueset = DBClass.GetValueSet("Building Type");
            
            ddlBuildingType.DataSource = valueset;
            ddlBuildingType.DataTextField = "DataValue_Description";
            ddlBuildingType.DataValueField = "DataValue_Name";
            ddlBuildingType.Items.Add(new ListItem("Please Select", "0"));
            ddlBuildingType.DataBind();

            valueset = DBClass.GetValueSet("Room Type");
           
            ddlRoomType.DataSource=valueset;
            ddlRoomType.DataTextField = "DataValue_Description";
            ddlRoomType.DataValueField = "DataValue_Name";
            ddlRoomType.Items.Add(new ListItem("Please Select", "0"));
            ddlRoomType.DataBind();


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
            txtRoom_ID.Text = "(New)";
            txtRoom_No.Text = "";
            txtName.Text = "";
            txtRoom_Charges.Text = "";
            ddlBuildingType.SelectedIndex = 0;
            ddlRoomType.SelectedIndex = 0;
            txtFloorNo.Text = "";
            txtLocation.Text = "";
            ddlWarden.SelectedIndex = 0;
        }

        private void LoadRoomData(int Rm_id)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            Room rm = (from tbl in db.Rooms
                           where tbl.Room_ID == Rm_id
                           select tbl).FirstOrDefault();
            if (rm != null)
            {
                txtRoom_ID.Text = rm.Room_ID.ToString();
                txtRoom_No.Text = Convert.ToString(rm.Room_No);
                txtName.Text = rm.Name;
                ddlBuildingType.SelectedValue = rm.Building_Type;
                ddlRoomType.SelectedValue = rm.Room_Type;
                txtFloorNo.Text = Convert.ToString(rm.Floor_No);
                txtLocation.Text = rm.Location;
                txtRoom_Charges.Text = Convert.ToString(rm.Room_Charges);
                ddlWarden.SelectedValue = rm.Warden;

                btnSave.Text = "Update";
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {

            try
            {
                DataBaseDataContext db = new DataBaseDataContext();
                if (btnSave.Text == "Save")
                {
                    Room rm = new  Room();

                    rm.Room_No = Convert.ToString(txtRoom_No.Text);
                    rm.Name = txtName.Text;
                    rm.Building_Type = ddlBuildingType.SelectedValue;
                    rm.Room_Type = ddlRoomType.SelectedValue;
                    rm.Floor_No = Convert.ToInt32(txtFloorNo.Text);
                    rm.Location = txtLocation.Text;
                    rm.Warden = ddlWarden.SelectedValue;
                    rm.Room_Charges = Convert.ToDecimal(txtRoom_Charges.Text);
                    rm.Created_By = AppConfig.UserID;
                    rm.Created_Time = DateTime.Now;
                    rm.Book_ID = AppConfig.Book_ID;
                    rm.Company_ID = AppConfig.Company_ID;


                    db.Rooms.InsertOnSubmit(rm);
                    db.SubmitChanges();
                    BlankForm();
                }
                else
                {
                    if (Request.QueryString["ID"] != null)
                    {
                        int id = Convert.ToInt32(Request.QueryString["ID"]);
                        Room rm = new Room();
                        rm = (from tbl in db.Rooms
                                where tbl.Room_ID == id
                                select tbl).FirstOrDefault();

                        rm.Room_No = Convert.ToString(txtRoom_No.Text);
                        rm.Name = txtName.Text;
                        rm.Building_Type = ddlBuildingType.SelectedValue;
                        rm.Room_Type = ddlRoomType.SelectedValue;
                        rm.Floor_No = Convert.ToInt32(txtFloorNo.Text);
                        rm.Location = txtLocation.Text;
                        rm.Warden = ddlWarden.SelectedValue;
                        rm.Room_Charges = Convert.ToDecimal(txtRoom_Charges.Text);

                        rm.Updated_By = AppConfig.UserID;
                        rm.Updated_Time = DateTime.Now;

                        //db.HR_Shifts.InsertOnSubmit(shft);

                        db.SubmitChanges();
                        BlankForm();
                    }
                }

                Response.Redirect(ResolveUrl("~/Modules/WardAndRooms/RoomView.aspx"));

            }
            catch (Exception ex)
            {
                throw;
            }

        }

        protected void ddlRoomType_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (ddlRoomType.SelectedIndex == 0)
            {
                txtRoom_Charges.ReadOnly = true;
                txtRoom_Charges.Text = "";
            }
            else
            {
                txtRoom_Charges.ReadOnly = false;

                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                var charges = (from tbl in db.DataValues
                               where tbl.DataValue_Description == ddlRoomType.SelectedItem.ToString()
                               select tbl.Segment1).FirstOrDefault();

                txtRoom_Charges.Text = charges.ToString();

            }
            ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "bindDate", "bindDate();", true);
        }

        protected void btnBack_Click(object sender, EventArgs e)
        {
            Response.Redirect("RoomView.aspx");
        }
    }
}