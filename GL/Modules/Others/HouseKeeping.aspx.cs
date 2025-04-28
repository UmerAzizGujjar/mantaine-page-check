using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class HouseKeeping : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                txtFrom_Date.Text = DateTime.Now.ToString(AppConfig.DateFormat);
                txtTo_Date.Text = DateTime.Now.ToString(AppConfig.DateFormat);
                BindingDropDown();

                if (Request.QueryString["ID"] != null)
                {
                    PopulateHouseKeepingData(Convert.ToInt32(Request.QueryString["ID"]));
                }
            }
        }

        public void BindingDropDown()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            var house_Keepers = (from tblEmp in db.HR_Employees
                           join tblDv in db.DataValues
                           on tblEmp.Designation equals tblDv.DataValue_Name
                           where tblDv.DataValue_Description == "House Keeper"
                           select new
                           {
                               tblEmp.Emp_ID,
                               tblEmp.Emp_Name
                           }).ToList();

            ddlHouse_Keeper.DataSource = house_Keepers;
            ddlHouse_Keeper.DataTextField = "Emp_Name";
            ddlHouse_Keeper.DataValueField = "Emp_ID";
            ddlHouse_Keeper.Items.Add(new ListItem("Please Select", "0"));
            ddlHouse_Keeper.DataBind();

            var supervisors = (from tblEmp in db.HR_Employees
                           join tblDv in db.DataValues
                           on tblEmp.Designation equals tblDv.DataValue_Name
                               where tblDv.DataValue_Description == "House Keeping Supervisor"
                           select new
                           {
                               tblEmp.Emp_ID,
                               tblEmp.Emp_Name
                           }).ToList();

            ddlSupervisor.DataSource = supervisors;
            ddlSupervisor.DataTextField = "Emp_Name";
            ddlSupervisor.DataValueField = "Emp_ID";
            ddlSupervisor.Items.Add(new ListItem("Please Select", "0"));
            ddlSupervisor.DataBind();

            List<HR_Shift> shifts = (from tbl in db.HR_Shifts
                            select tbl).ToList();

            ddlShift.DataSource = shifts;
            ddlShift.DataTextField = "Shift_Name";
            ddlShift.DataValueField = "Shift_ID";
            ddlShift.Items.Add(new ListItem("Please Select", "0"));
            ddlShift.DataBind();

            var workType = (from Vs in db.ValueSets
                                join Dv in db.DataValues
                                on Vs.ValueSet_ID equals Dv.ValueSet_ID
                                where Vs.ValueSet_Description == "House Keeping Work Type"
                                select new
                                {
                                    Dv.DataValue_Name,
                                    Dv.DataValue_Description
                                }).ToList();

            ddlHouse_Keeping_Work_Type.DataSource = workType;
            ddlHouse_Keeping_Work_Type.DataTextField = "DataValue_Description";
            ddlHouse_Keeping_Work_Type.DataValueField = "DataValue_Name";
            ddlHouse_Keeping_Work_Type.Items.Add(new ListItem("Please Select", "0"));
            ddlHouse_Keeping_Work_Type.DataBind();

            var workArea = (from Vs in db.ValueSets
                            join Dv in db.DataValues
                            on Vs.ValueSet_ID equals Dv.ValueSet_ID
                            where Vs.ValueSet_Description == "Working Area"
                            select new
                            {
                                Dv.DataValue_Name,
                                Dv.DataValue_Description
                            }).ToList();

            ddlWorking_Area.DataSource = workArea;
            ddlWorking_Area.DataTextField = "DataValue_Description";
            ddlWorking_Area.DataValueField = "DataValue_Name";
            ddlWorking_Area.Items.Add(new ListItem("Please Select", "0"));
            ddlWorking_Area.DataBind();
        }

        private void PopulateHouseKeepingData(int house_Keeping_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            House_Keeping house_Keeping = (from tbl in db.House_Keepings
                                             where tbl.House_Keeping_ID == house_Keeping_ID
                                             select tbl).FirstOrDefault();

            if (house_Keeping != null)
            {
                txtHouse_Keeping_ID.Text = house_Keeping.House_Keeping_ID.ToString();
                ddlHouse_Keeper.SelectedValue = house_Keeping.House_Keeper.ToString();
                ddlHouse_Keeping_Work_Type.SelectedValue = house_Keeping.House_Keeping_Work_Type;
                ddlShift.SelectedValue = house_Keeping.Shift.ToString();
                txtFrom_Date.Text = house_Keeping.From_Date.Value.ToString(AppConfig.DateFormat);
                txtTo_Date.Text = house_Keeping.To_Date.Value.ToString(AppConfig.DateFormat);
                ddlWorking_Area.SelectedValue = house_Keeping.Working_Area;
                ddlSupervisor.SelectedValue = house_Keeping.Supervisor.ToString();
                txtRemarks.Text = house_Keeping.Remarks;

                btnSave.Text = "Update";
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                House_Keeping house_kpng = new House_Keeping();

                if (btnSave.Text == "Save")
                {
                    house_kpng.Created_By = AppConfig.UserID;
                    house_kpng.Created_Time = DateTime.Now;
                    house_kpng.Book_ID = AppConfig.Book_ID;
                    house_kpng.Company_ID = AppConfig.Company_ID;
                }
                else
                {
                    house_kpng = (from tbl in db.House_Keepings
                               where tbl.House_Keeping_ID == Convert.ToInt32(Request.QueryString["ID"])
                               select tbl).FirstOrDefault();

                    house_kpng.Updated_By = AppConfig.UserID;
                    house_kpng.Updated_Time = DateTime.Now;
                }

                house_kpng.House_Keeper = Convert.ToInt32(ddlHouse_Keeper.SelectedValue);
                house_kpng.House_Keeping_Work_Type = ddlHouse_Keeping_Work_Type.SelectedValue;
                house_kpng.Shift = Convert.ToInt32(ddlShift.SelectedValue);
                house_kpng.From_Date = Convert.ToDateTime(txtFrom_Date.Text);
                house_kpng.To_Date = Convert.ToDateTime(txtTo_Date.Text);
                house_kpng.Working_Area = ddlWorking_Area.SelectedValue;
                house_kpng.Supervisor = Convert.ToInt32(ddlSupervisor.SelectedValue);
                house_kpng.Remarks = txtRemarks.Text;

                if (btnSave.Text == "Save")
                {
                    db.House_Keepings.InsertOnSubmit(house_kpng);
                    lblMessage.CssClass = "Data Inserted Successfully";

                }
                else
                {
                    lblMessage.CssClass = "Data Updated Successfully";
                }

                db.SubmitChanges();

                Response.Redirect("~/HouseKeepingView.aspx", false);
                lblMessage.CssClass = "sucessfullMessage";
            }


            catch (Exception ex)
            {
                throw;
            }
        }
    }
}