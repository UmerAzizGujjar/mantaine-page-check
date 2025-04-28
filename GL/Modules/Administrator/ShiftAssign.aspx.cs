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
    public partial class ShiftAssign : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

            if (!IsPostBack)
            {
                txtFrom_Date.Text = DateTime.Now.Date.ToString(AppConfig.DateFormat);
                txtTo_Date.Text = DateTime.Now.Date.ToString(AppConfig.DateFormat);
                BindingDropDown();
                if (Request.QueryString["ID"] != null)
                {
                    PopulateShiftData(Convert.ToInt32(Request.QueryString["ID"]));

                }
            }
        }

        public void BindingDropDown()
        {

            DataTable dtNurse= new DataTable();
            dtNurse = DBClass.getDataTable("select Emp.Emp_ID, CONCAT(Emp.Emp_ID, ' - ', Emp.Emp_name) As Emp_name from HR_Employees As Emp join DataValues As DV on DV.DataValue_Description = 'Nurse' where Emp.Designation = DV.DataValue_Name");
            ddlEmployee.DataSource = dtNurse;
            ddlEmployee.DataTextField = "Emp_Name";
            ddlEmployee.DataValueField = "Emp_ID";
            ddlEmployee.Items.Add(new ListItem("Please Select", "0"));
            ddlEmployee.DataBind();

            DataTable dtShift = new DataTable();
            dtShift = DBClass.getDataTable("Select Shift_Name,Shift_ID from HR_Shifts");
            ddlShiftName.DataSource = dtShift;
            ddlShiftName.DataTextField = "Shift_Name";
            ddlShiftName.DataValueField = "Shift_ID";
            ddlShiftName.Items.Add(new ListItem("Please Select", "0"));
            ddlShiftName.DataBind();

            object valueset;
            valueset = DBClass.GetValueSet("Assigned To");
            ddlAssigned_To.DataSource = valueset;
            ddlAssigned_To.DataTextField = "DataValue_Description";
            ddlAssigned_To.DataValueField = "DataValue_Name";
            //ddlAssigned_To.Items.Add(new ListItem("Please Select", "0"));
            ddlAssigned_To.DataBind();

            valueset = new object();
            valueset = DBClass.GetValueSet("Duty Type");
            ddlDuty_Type.DataSource = valueset;
            ddlDuty_Type.DataTextField = "DataValue_Description";
            ddlDuty_Type.DataValueField = "DataValue_Name";
            //ddlDuty_Type.Items.Add(new ListItem("Please Select", "0"));
            ddlDuty_Type.DataBind();

        }

            protected void btnSave_Click(object sender, EventArgs e)
            {
                if (!Page.IsValid)
                    return;

                try
                {
                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    Shift_Assign shiftAssign = new Shift_Assign();
                    if (btnSave.Text == "Save")
                    {
                        shiftAssign.Created_By = AppConfig.UserID;
                        shiftAssign.Created_Time = DateTime.Now;
                        shiftAssign.Book_ID = AppConfig.Book_ID;
                        shiftAssign.Company_ID = AppConfig.Company_ID;
                      
                    }
                    else
                    {
                        shiftAssign = (from tbl in db.Shift_Assigns
                                            where tbl.Shift_Assign_ID == Convert.ToInt32(Request.QueryString["ID"])
                                            select tbl).FirstOrDefault();

                        shiftAssign.Updated_By = AppConfig.UserID;
                        shiftAssign.Updated_Time = DateTime.Now;
                    }


                    shiftAssign.Shift_ID = Convert.ToInt32(ddlShiftName.SelectedValue);
                    shiftAssign.To_Date = Convert.ToDateTime(txtTo_Date.Text);
                    shiftAssign.From_Date = Convert.ToDateTime(txtFrom_Date.Text);
                    shiftAssign.Employee = ddlEmployee.SelectedValue;
                    shiftAssign.Remark = txtRemark.Text;
                    shiftAssign.Assigned_To = ddlAssigned_To.SelectedValue;
                    shiftAssign.Duty_Type = ddlDuty_Type.SelectedValue;

                    if (txtNursing_Charges.Text != "")
                    shiftAssign.Nursing_Charges = Convert.ToDecimal(txtNursing_Charges.Text);

                    if (txtRoom_No.Text != "")
                    shiftAssign.Room_No = txtRoom_No.Text;

                    if (txtPatient_No.Text != "")
                    shiftAssign.Patient_ID = Convert.ToInt32(txtPatient_No.Text);

                    //shiftAssigoperationBooking.Date = Convert.ToDateTime(txtDate_Operation.Text);
                    

                    if (btnSave.Text == "Save")
                    {
                        db.Shift_Assigns.InsertOnSubmit(shiftAssign);
                        lblMessage.CssClass = "Data Inserted Successfully";

                    }
                    else
                    {
                        lblMessage.CssClass = "Data Updated Successfully";
                    }

                    db.SubmitChanges();

                    Response.Redirect("~/ShiftView.aspx", false);
                    lblMessage.CssClass = "sucessfullMessage";
                    ClearForm();
                }
                catch (Exception ex)
                {
                    lblMessage.CssClass = ex.Message;
                }

            }

            private void PopulateShiftData(int Shift_Assign_id)
            {
                DataBaseDataContext db = new DataBaseDataContext();

                Shift_Assign shiftAssign = (from tbl in db.Shift_Assigns
                                     where tbl.Shift_Assign_ID == Shift_Assign_id
                                 select tbl).FirstOrDefault();

                txtShift_Assign_ID.Text = shiftAssign.Shift_Assign_ID.ToString();
                txtTo_Date.Text = shiftAssign.To_Date.Value.Date.ToString(AppConfig.DateFormat);
                txtFrom_Date.Text = shiftAssign.From_Date.Value.Date.ToString(AppConfig.DateFormat);
                ddlEmployee.SelectedValue = shiftAssign.Employee.ToString();
                txtRemark.Text = shiftAssign.Remark.ToString();
                ddlAssigned_To.SelectedValue = shiftAssign.Assigned_To;
                ddlDuty_Type.SelectedValue = shiftAssign.Duty_Type;
                ddlShiftName.SelectedValue = shiftAssign.Shift_ID.ToString();

                if (!string.IsNullOrEmpty(shiftAssign.Nursing_Charges.ToString()) || !string.IsNullOrEmpty(shiftAssign.Patient_ID.ToString()) || !string.IsNullOrEmpty(shiftAssign.Room_No))
                {
                    txtNursing_Charges.ReadOnly = false;
                    txtRoom_No.ReadOnly = false;
                    txtPatient_No.ReadOnly = false;

                    txtNursing_Charges.Text = shiftAssign.Nursing_Charges.ToString();
                    txtRoom_No.Text = shiftAssign.Room_No;
                    txtPatient_No.Text = shiftAssign.Patient_ID.ToString();
                }

                btnSave.Text = "Update";
                     
            }

            private void ClearForm()
            {
                txtShift_Assign_ID.Text = "(New)";
                txtTo_Date.Text = DateTime.Now.Date.ToString(AppConfig.DateFormat);
                txtFrom_Date.Text = DateTime.Now.Date.ToString(AppConfig.DateFormat);
                ddlEmployee.SelectedIndex = 0;
                ddlShiftName.SelectedIndex = 0;
                txtRemark.Text = "";
                ddlAssigned_To.SelectedIndex=0;
                ddlDuty_Type.SelectedIndex = 0;
                txtNursing_Charges.Text = "";
                txtRoom_No.Text = "";
                txtPatient_No.Text = "";
            }

        
    }
}