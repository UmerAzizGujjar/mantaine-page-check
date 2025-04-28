using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class VehicleRegistration : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindingDropDown();
                if (Request.QueryString["ID"] != null)
                {
                    PopulateVehiclesData(Convert.ToInt32(Request.QueryString["ID"]));

                }
            }
        }

        public void BindingDropDown()
        {
            object valueset;
            valueset = DBClass.GetValueSet("Vehicle Type");
            ddlVehicle_Type.DataSource = valueset;
            ddlVehicle_Type.DataTextField = "DataValue_Description";
            ddlVehicle_Type.DataValueField = "DataValue_Name";
            ddlVehicle_Type.Items.Add(new ListItem("Please Select", "0"));
            ddlVehicle_Type.DataBind();
        }

        private void PopulateVehiclesData(int vid)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            Vehicle vObj = (from tbl in db.Vehicles
                            where tbl.VID == vid
                            select tbl).FirstOrDefault();


            txtVehicle_Code.Text = vObj.V_Code;
            txtVIN.Text = vObj.VIN;
            txtRegistration_No.Text = vObj.Reg_No;
            txtRegistration_State.Text = vObj.Reg_State;
            txtEngin_No.Text = vObj.Engine_No;
            ddlVehicle_Type.SelectedValue = vObj.V_Type;
            txtTotal_Seats.Text = vObj.Total_Seats;
            txtMake.Text = vObj.Make;
            txtModel.Text = vObj.Model;
            txtColor.Text = vObj.Color;
            // img_Upload.v = "~/Patient_Images/" ;


            btnSave.Text = "Update";

        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid)
                return;

            try
            {
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                Vehicle vObj = new Vehicle();
                if (btnSave.Text == "Save")
                {
                    vObj.Created_By = AppConfig.UserID;
                    vObj.Created_Time = DateTime.Now;
                    vObj.Book_ID = AppConfig.Book_ID;
                    vObj.Company_ID = AppConfig.Company_ID;

                }
                else
                {
                    vObj = (from tbl in db.Vehicles
                            where tbl.VID == Convert.ToInt32(Request.QueryString["ID"])
                            select tbl).FirstOrDefault();

                    vObj.Updated_By = AppConfig.UserID;
                    vObj.Updated_Time = DateTime.Now;
                }


                vObj.V_Code = txtVehicle_Code.Text;
                vObj.VIN = txtVIN.Text;
                vObj.Reg_No = txtRegistration_No.Text;
                vObj.Reg_State = txtRegistration_State.Text;
                vObj.Engine_No = txtEngin_No.Text;
                vObj.V_Type = ddlVehicle_Type.SelectedValue;
                vObj.Total_Seats = txtTotal_Seats.Text;
                vObj.Make = txtMake.Text;
                vObj.Model = txtModel.Text;
                vObj.Color = txtColor.Text;

                if (img_Upload.HasFile)
                {

                    try
                    {
                        string fileName = Path.GetFileName(img_Upload.FileName);
                        img_Upload.SaveAs(Server.MapPath("~/Patient_Images/") + fileName);
                        vObj.V_Image = "~/Patient_Images/" + fileName;
                    }
                    catch (Exception ex)
                    {
                        lblMessage.CssClass = "Upload status: The file could not be uploaded. The following error occured: " + ex.Message;
                    }
                }


                if (btnSave.Text == "Save")
                {
                    db.Vehicles.InsertOnSubmit(vObj);
                    lblMessage.CssClass = "Data Inserted Successfully";
                }
                else
                {
                    lblMessage.CssClass = "Data Updated Successfully";
                }

                db.SubmitChanges();
                lblMessage.CssClass = "sucessfullMessage";
                clearForm();
                Response.Redirect("~/VehicleView.aspx", false);

            }
            catch (Exception ex)
            {
                lblMessage.CssClass = ex.Message;
            }
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            clearForm();
        }

        public void clearForm()
        {
            txtVehicle_Code.Text = "";
            txtVIN.Text = "";
            txtRegistration_No.Text = "";
            txtRegistration_State.Text = "";
            txtEngin_No.Text = "";
            ddlVehicle_Type.SelectedIndex = 0;
            txtTotal_Seats.Text = "";
            txtMake.Text = "";
            txtModel.Text = "";
            txtColor.Text = "";
        }
    }
}