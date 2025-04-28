using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;

namespace PMS
{
    public partial class VehicleRoute : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindingDropDown();
                if (Request.QueryString["ID"] != null)
                {
                    PopulateVehicleRouteData(Convert.ToInt32(Request.QueryString["ID"]));
                }
            }
        }

             public void BindingDropDown()
        {
            DataTable dtVehicles = new DataTable();
            dtVehicles = DBClass.getDataTable("Select Make, VID from Vehicles");

            ddlVehicle_Name.DataSource = dtVehicles;
            ddlVehicle_Name.DataTextField = "Make";
            ddlVehicle_Name.DataValueField = "VID";
            ddlVehicle_Name.Items.Add(new ListItem("Please Select", "0"));
            ddlVehicle_Name.DataBind();


            DataTable dtRoute = new DataTable();
            dtRoute = DBClass.getDataTable("Select Route_Name, Route_ID from Routes");
            ddlRoute_Name.DataSource = dtRoute;
            ddlRoute_Name.DataTextField = "Route_Name";
            ddlRoute_Name.DataValueField = "Route_ID";
            ddlRoute_Name.Items.Add(new ListItem("Please Select", "0"));
            ddlRoute_Name.DataBind();

            
        }

             private void PopulateVehicleRouteData(int vr_id)
             {
                 DataBaseDataContext db = new DataBaseDataContext();
                 Vehicle_Route VRoute = (from tbl in db.Vehicle_Routes
                                             where tbl.VR_ID == vr_id
                                             select tbl).FirstOrDefault();


                 ddlRoute_Name.SelectedValue = VRoute.Route_ID.ToString();
                 ddlVehicle_Name.SelectedValue = VRoute.VID.ToString();
                 

                 btnSave.Text = "Update";

             }


             protected void btnSave_Click(object sender, EventArgs e)
             {
                 if (!Page.IsValid)
                     return;

                 try
                 {
                     DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                     Vehicle_Route vrObj = new Vehicle_Route();
                     if (btnSave.Text == "Assign")
                     {
                         vrObj.Created_By = AppConfig.UserID;
                         vrObj.Created_Time = DateTime.Now;
                         vrObj.Book_ID = AppConfig.Book_ID;
                         vrObj.Company_ID = AppConfig.Company_ID;

                     }
                     else
                     {
                         vrObj = (from tbl in db.Vehicle_Routes
                                 where tbl.VR_ID == Convert.ToInt32(Request.QueryString["ID"])
                                 select tbl).FirstOrDefault();

                         vrObj.Updated_By = AppConfig.UserID;
                         vrObj.Updated_Time = DateTime.Now;
                     }


                     vrObj.VID = Convert.ToInt16(ddlVehicle_Name.SelectedValue);
                     vrObj.Route_ID = Convert.ToInt16(ddlRoute_Name.SelectedValue);
                    

                

                     if (btnSave.Text == "Assign")
                     {
                         db.Vehicle_Routes.InsertOnSubmit(vrObj);
                         lblMessage.CssClass = "Data Inserted Successfully";
                     }
                     else
                     {
                         lblMessage.CssClass = "Data Updated Successfully";
                     }

                     db.SubmitChanges();
                     lblMessage.CssClass = "sucessfullMessage";
                     clearForm();
                     Response.Redirect("~/VehicleRouteView.aspx", false);

                 }
                 catch (Exception ex)
                 {
                     lblMessage.CssClass = ex.Message;
                 }
             }

             public void clearForm()
             {
                 ddlRoute_Name.SelectedIndex = 0;
                 ddlVehicle_Name.SelectedIndex = 0;
                
             }

             protected void btnClear_Click(object sender, EventArgs e)
             {
                 clearForm();
             }
        }
    
}