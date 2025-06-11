using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class WardAllocation : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindingDropDown();

                if (Request.QueryString["ID"] != null)
                {
                    PopulateWardAllocationData(Convert.ToInt32(Request.QueryString["ID"]));
                }
            }
        }

        public void BindingDropDown()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var WardTbl = (from tbl in db.Ward_Definitions
                           join tbl2 in db.DataValues on tbl.Ward_Type equals tbl2.DataValue_Name
                           join tbl3 in db.ValueSets on tbl2.ValueSet_ID equals tbl3.ValueSet_ID
                           where tbl3.ValueSet_Name == "Ward Type"
                           select new
                           {
                               tbl.Ward_ID,
                               Ward = tbl.Ward_No + " - " + tbl2.DataValue_Description
                           }).ToList();

            ddlWard_ID.DataSource = WardTbl;
            ddlWard_ID.DataTextField = "Ward";
            ddlWard_ID.DataValueField = "Ward_ID";
            ddlWard_ID.Items.Add(new ListItem("Please Select", "0"));
            ddlWard_ID.DataBind();

            
            List<HR_Employee> Doctors = new List<HR_Employee>();
            Doctors = (from tbl in db.HR_Employees
                       where tbl.IsDoctor == true
                       select tbl).ToList();

            ddlDoctor_Assigned.DataSource = Doctors;
            ddlDoctor_Assigned.DataTextField = "Emp_Name";
            ddlDoctor_Assigned.DataValueField = "Emp_ID";
            ddlDoctor_Assigned.Items.Add(new ListItem("Please Select", "0"));
            ddlDoctor_Assigned.DataBind();


            List<HR_Employee> Nurses = new List<HR_Employee>();
            Nurses = (from tbl in db.HR_Employees
                      join tbl2 in db.DataValues on tbl.Designation equals tbl2.DataValue_Name
                      join tbl3 in db.ValueSets on tbl2.ValueSet_ID equals tbl3.ValueSet_ID
                      where tbl2.DataValue_Description == "Nurse" 
                       select tbl).ToList();

            ddlNurse_Assigned.DataSource = Nurses;
            ddlNurse_Assigned.DataTextField = "Emp_Name";
            ddlNurse_Assigned.DataValueField = "Emp_ID";
            ddlNurse_Assigned.Items.Add(new ListItem("Please Select", "0"));
            ddlNurse_Assigned.DataBind();
        }

        private void PopulateWardAllocationData(int ward_Aloct_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            var ward_aloct = (from tbl in db.Ward_Allocations
                                          join tbl2 in db.Ward_Definitions on tbl.Ward_ID equals tbl2.Ward_ID
                                          where tbl.Ward_Allocation_ID == ward_Aloct_ID
                                          select new {
                                              tbl.Ward_Allocation_ID,
                                              tbl.Patient_ID,
                                              tbl.Ward_ID,
                                              tbl2.No_Of_Beds,
                                              tbl.Bed_No_Assigned,
                                              tbl.From_TimeDate,
                                              tbl.To_TimeDate,
                                              tbl.Doctor_Assigned,
                                              tbl.Nurse_Assigned,
                                              tbl.Remarks
                                          }).FirstOrDefault();

            if (ward_aloct != null)
            {
                txtWard_Allocation_ID.Text = ward_aloct.Ward_Allocation_ID.ToString();
                txtPatient_ID.Text = ward_aloct.Patient_ID.ToString();
                hdfPatient_ID.Value = ward_aloct.Patient_ID.ToString();
                ddlWard_ID.SelectedValue = ward_aloct.Ward_ID.ToString();

                if (ward_aloct.No_Of_Beds != null)
                txtTotal_Beds.Text = ward_aloct.No_Of_Beds.ToString();

                txtBed_No_Assigned.Text = ward_aloct.Bed_No_Assigned.ToString();
                txtFrom_TimeDate.Text = ward_aloct.From_TimeDate.Value.ToString(AppConfig.DateFormat);
                txtTo_TimeDate.Text = ward_aloct.To_TimeDate.Value.ToString(AppConfig.DateFormat);
                ddlDoctor_Assigned.SelectedValue = ward_aloct.Doctor_Assigned.ToString();
                ddlNurse_Assigned.SelectedValue = ward_aloct.Nurse_Assigned.ToString();
                txtRemarks.Text = ward_aloct.Remarks;

                btnSave.Text = "Update";
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                Ward_Allocation ward_aloct = new Ward_Allocation();
                Ward_Allocatrion_History Ward_History = new Ward_Allocatrion_History();

                if (btnSave.Text == "Save")
                {
                    ward_aloct.Created_By = AppConfig.UserID;
                    ward_aloct.Created_Time = DateTime.Now;
                    ward_aloct.Book_ID = AppConfig.Book_ID;
                    ward_aloct.Company_ID = AppConfig.Company_ID;
                }
                else
                {
                    ward_aloct = (from tbl in db.Ward_Allocations
                               where tbl.Ward_Allocation_ID == Convert.ToInt32(Request.QueryString["ID"])
                               select tbl).FirstOrDefault();

                    ward_aloct.Updated_By = AppConfig.UserID;
                    ward_aloct.Updated_Time = DateTime.Now;
                }

                ward_aloct.Patient_ID = Convert.ToInt32(txtPatient_ID.Text);
                ward_aloct.Ward_ID = Convert.ToInt32(ddlWard_ID.SelectedValue);
                ward_aloct.Bed_No_Assigned = Convert.ToInt32(txtBed_No_Assigned.Text);
                ward_aloct.From_TimeDate = Convert.ToDateTime(txtFrom_TimeDate.Text);
                ward_aloct.To_TimeDate = Convert.ToDateTime(txtTo_TimeDate.Text);
                ward_aloct.Doctor_Assigned = Convert.ToInt32(ddlDoctor_Assigned.SelectedValue);
                ward_aloct.Nurse_Assigned = Convert.ToInt32(ddlNurse_Assigned.SelectedValue);
                ward_aloct.Remarks = txtRemarks.Text;

                if (btnSave.Text == "Save")
                {
                    db.Ward_Allocations.InsertOnSubmit(ward_aloct);
                    db.SubmitChanges();
                    lblMessage.CssClass = "Data Inserted Successfully";



                    db = new DataBaseDataContext(DBClass.ConnectionString());
                    var countOfRows = db.Ward_Allocatrion_Histories.Where(m => m.Patient_ID == Convert.ToInt32(txtPatient_ID.Text)).Count();

                    if (countOfRows > 0)
                    {
                        var lastRow = db.Ward_Allocatrion_Histories.Where(m => m.Patient_ID == Convert.ToInt32(txtPatient_ID.Text)).Skip(countOfRows - 1).FirstOrDefault();

                        if (lastRow.To_Date == null)
                        {
                            lastRow.To_Date = DateTime.Now;
                            Ward_Allocatrion_History Ward_History_Edition = (from wrdAlHst in db.Ward_Allocatrion_Histories
                                                                             where wrdAlHst.Ward_Allocatrion_History_ID == lastRow.Ward_Allocatrion_History_ID
                                                                             select wrdAlHst).FirstOrDefault();

                            Ward_History_Edition.To_Date = DateTime.Now;
                        }
                    }




                    Ward_History = new Ward_Allocatrion_History();
                    Ward_History.Ward_Allocation_ID = ward_aloct.Ward_Allocation_ID;

                    if (!string.IsNullOrEmpty(txtPatient_ID.Text))
                        Ward_History.Patient_ID = Convert.ToInt32(txtPatient_ID.Text);

                    if (!string.IsNullOrEmpty(ddlWard_ID.SelectedValue))
                        Ward_History.Ward_ID = Convert.ToInt32(ddlWard_ID.SelectedValue);

                    if (!string.IsNullOrEmpty(txtBed_No_Assigned.Text))
                        Ward_History.Bed_No = Convert.ToInt32(txtBed_No_Assigned.Text);

                    if (!string.IsNullOrEmpty(txtFrom_TimeDate.Text))
                        Ward_History.From_Date = Convert.ToDateTime(txtFrom_TimeDate.Text);

                    if (!string.IsNullOrEmpty(txtTo_TimeDate.Text))
                        Ward_History.To_Date = Convert.ToDateTime(txtTo_TimeDate.Text);

                    Ward_History.Created_By = AppConfig.UserID;
                    Ward_History.Created_Time = DateTime.Now;
                    Ward_History.Book_ID = AppConfig.Book_ID;
                    Ward_History.Company_ID = AppConfig.Company_ID;

                    db.Ward_Allocatrion_Histories.InsertOnSubmit(Ward_History);

                }
                else
                {
                    lblMessage.CssClass = "Data Updated Successfully";

                    Ward_History = new Ward_Allocatrion_History();
                    Ward_History = (from tbl in db.Ward_Allocatrion_Histories
                                    where tbl.Ward_Allocation_ID == Convert.ToInt32(Request.QueryString["ID"])
                                    select tbl).FirstOrDefault();

                    if (!string.IsNullOrEmpty(txtPatient_ID.Text))
                        Ward_History.Patient_ID = Convert.ToInt32(txtPatient_ID.Text);

                    if (!string.IsNullOrEmpty(ddlWard_ID.SelectedValue))
                        Ward_History.Ward_ID = Convert.ToInt32(ddlWard_ID.SelectedValue);

                    if (!string.IsNullOrEmpty(txtBed_No_Assigned.Text))
                        Ward_History.Bed_No = Convert.ToInt32(txtBed_No_Assigned.Text);

                    if (!string.IsNullOrEmpty(txtFrom_TimeDate.Text))
                        Ward_History.From_Date = Convert.ToDateTime(txtFrom_TimeDate.Text);

                    if (!string.IsNullOrEmpty(txtTo_TimeDate.Text))
                        Ward_History.To_Date = Convert.ToDateTime(txtTo_TimeDate.Text);

                    Ward_History.Updated_By = AppConfig.UserID;
                    Ward_History.Updated_Time = DateTime.Now;
                }

                db.SubmitChanges();

                Response.Redirect("~/Modules/WardAndRooms/WardAllocationView.aspx", false);
                lblMessage.CssClass = "sucessfullMessage";
            }


            catch (Exception ex)
            {
                throw;
            }
        }

        protected void ddlWard_ID_SelectedIndexChanged(object sender, EventArgs e)
        {
            txtTotal_Beds.Text="";
            txtBed_No_Assigned.Text = "";

            if (ddlWard_ID.SelectedIndex == 0)
            {
                txtTotal_Beds.Text = "";
                txtBed_No_Assigned.ReadOnly = true;
            }
            else
            {
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                var Beds_Qty = (from tbl in db.Ward_Definitions
                                where tbl.Ward_ID == Convert.ToInt32(ddlWard_ID.SelectedValue)
                                select new {
                                    tbl.No_Of_Beds
                                }).FirstOrDefault();

                txtTotal_Beds.Text = Beds_Qty.No_Of_Beds.ToString();
                txtBed_No_Assigned.ReadOnly = false;
            }
        }

        private int? TryPrs(string s)
        {
            int i = 1;
            if (!int.TryParse(s, out i))
            {
                return null;
            }
            else
            {
                return i;
            }
        }

        protected void btnTrigger_Click(object sender, EventArgs e)
        {
            if (TryPrs(txtBed_No_Assigned.Text) != null)
            {
                int bed_No = Convert.ToInt32(txtBed_No_Assigned.Text);
                int bed_Entry = 0;

                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                bed_Entry = (from tbl in db.Ward_Allocations
                             where tbl.Ward_ID == Convert.ToInt32(ddlWard_ID.SelectedValue) && tbl.Bed_No_Assigned == bed_No
                             select tbl).Count();

                var Max_Ward_Beds = (from tbl in db.Ward_Definitions
                                     where tbl.Ward_ID == Convert.ToInt32(ddlWard_ID.SelectedValue)
                                     select tbl.No_Of_Beds).SingleOrDefault();

                if (bed_Entry == 0 && Convert.ToInt32(Max_Ward_Beds) >= bed_No)
                {
                    lblChk.Text = "Bed No." + bed_No + " is Available in this Ward";
                    lblChk.CssClass = "Success";
                }
                else
                {
                    lblChk.Text = "Bed No." + bed_No + " is Not Available in this Ward";
                    txtBed_No_Assigned.Text = "";
                    lblChk.CssClass = "Error";
                }
            }
            else
            {
                lblChk.Text = "Enter the Bed No. only in positive integers";
                txtBed_No_Assigned.Text = "";
                lblChk.CssClass = "Error";
            }
        }

        protected void btnAllocatedWardChkTrigger_Click(object sender, EventArgs e)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var countOfRows = db.Ward_Allocations.Where(m => m.Patient_ID == Convert.ToInt32(txtPatient_ID.Text)).Count();

            if (countOfRows > 0)
            {
                var lastRow = db.Ward_Allocations.Where(m => m.Patient_ID == Convert.ToInt32(txtPatient_ID.Text)).Skip(countOfRows - 1).FirstOrDefault();

                if (lastRow != null)
                {
                    var wardInfo = (from tblWrd in db.Ward_Definitions
                                    join tbl2 in db.DataValues on tblWrd.Ward_Type equals tbl2.DataValue_Name
                                    join tbl3 in db.ValueSets on tbl2.ValueSet_ID equals tbl3.ValueSet_ID
                                    where tbl3.ValueSet_Name == "Ward Type" && tblWrd.Ward_ID == lastRow.Ward_ID
                                    select new
                                    {
                                        tblWrd.Ward_ID,
                                        Ward = tblWrd.Ward_No + " - " + tbl2.DataValue_Description
                                    }).FirstOrDefault();

                    txtCurrent_Allocated_Ward.Text = wardInfo.Ward.ToString();
                    txtCurrent_Allocated_Bed.Text = lastRow.Bed_No_Assigned.ToString();
                    vlblCurrent_Allocated_Ward.Text = "";
                    vlblCurrent_Allocated_Ward.CssClass = "Success";
                }
                //else
                //{
                //    txtCurrent_Allocated_Room.Text = "";
                //    vlblCurrent_Allocated_Room.Text = "No Room Assigned.";
                //    vlblCurrent_Allocated_Room.CssClass = "Error";
                //}
            }
            else
            {
                txtCurrent_Allocated_Ward.Text = "";
                txtCurrent_Allocated_Bed.Text = "";
                vlblCurrent_Allocated_Ward.Text = "No Ward Assigned.";
                vlblCurrent_Allocated_Ward.CssClass = "Error";
            }
        }
    }
}