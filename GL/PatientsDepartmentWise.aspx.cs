using CrystalDecisions.CrystalReports.Engine;
using CrystalDecisions.Shared;
using Infragistics.Documents.Reports.HTML;
using Infragistics.Documents.Reports.RTF;
using Infragistics.Web.UI.GridControls;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Runtime.InteropServices.ComTypes;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.MobileControls.Adapters;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class PatientsDepartmentWise : System.Web.UI.Page
    {
        string PageTitle;
        public bool AllowPatientRecord = false;

        private DataTable GetUserWarehouses()
        {
            if (DBClass.IsAdministrator())
            {
                return DBClass.getDataTable(@"
                    SELECT DataValue_Name AS Value, DataValue_Description AS Text
                    FROM DataValues
                    WHERE ValueSet_ID = 8
                    ORDER BY CASE WHEN DataValue_Name = '0' THEN 0 ELSE 1 END, DataValue_Description");
            }
            return DBClass.getDataTable(@"
    SELECT DISTINCT dv.DataValue_Name AS Value, dv.DataValue_Description AS Text
    FROM WareHouse_Wise_User wu
    INNER JOIN WareHouse_Wise_User_Detail wud ON wu.WareHouse_wise_User_Id = wud.WareHouse_wise_User_Id
    INNER JOIN DataValues dv ON wud.WareHouse = dv.DataValue_Name
    WHERE wu.User_Id = '" + AppConfig.UserID.ToString() + @"'
      AND dv.ValueSet_ID = 8
    ORDER BY dv.DataValue_Description");
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!Page.IsPostBack)
            {

                AllowPatientRecord = Convert.ToBoolean(DBClass.getField("Select AllPatientRecords from aspnet_Users where UserId='" + AppConfig.UserID + "'"));
                PageTitle = Request.QueryString["rptTitle"];

                #region Patients
                if (PageTitle == "Departmentwisestats")
                {
                    optRw.Visible = false;
                    tr_Summary.Visible = false;
                    ddlDepartments.Visible = false;
                    tr_Export.Visible = false;
                    dpROw.Visible = false;

                }
                else if (PageTitle == "Consultant_Day_Wise_report")
                {
                    string x = "Consultant Day Wise Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    optRw.Visible = false;
                    Time_Row.Visible = true;
                    DateDiv.Visible = true;
                    tr_Summary.Visible = false;
                    ddlDepartments.Visible = false;
                    ddlDoctor.Visible = true;
                    trDoctor.Visible = true;
                    tr_Export.Visible = false;
                    lbservieType.Visible = false;
                    ddlReportType.Visible = false;
                    dpROw.Visible = false;
                    DataTable dt = DBClass.getDataTable("select * from HR_Employees where IsDoctor=1");
                    ddlDoctor.DataSource = dt;
                    ddlDoctor.DataValueField = "Emp_ID";
                    ddlDoctor.DataTextField = "Emp_Name";
                    ddlDoctor.Items.Add(new ListItem() { Value = "0", Text = "All Doctors" });
                    ddlDoctor.DataBind();

                }
                else if (PageTitle == "Hospital_Cash_Report")
                {
                    string x = "Hospital Cash Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = true;
                    ddlDepartments.Visible = true;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    lblDepartment.Visible = true;
                    lblDepartment.Text = "Patient Type";
                    object valusets;
                    valusets = DBClass.GetValueSet("Patient Type");
                    ddlDepartments.DataSource = valusets;
                    ddlDepartments.DataTextField = "DataValue_Description";
                    ddlDepartments.DataValueField = "DataValue_Name";
                    ddlDepartments.Items.Add(new ListItem() { Text = "Please Select", Value = "0" });
                    ddlDepartments.DataBind();
                    optRw.Visible = false;
                    trDoctor.Visible = false;
                    lblMainDepartment.Visible = false;
                    ddlShift.Visible = false;
                    lbShift.Visible = false;
                    tr_Export.Visible = false;
                    dpROw.Visible = true;
                    tr_Summary.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    if (AllowPatientRecord)
                    {
                        optRw.Visible = true;
                        DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                        valusets = from d in db.aspnet_Users
                                   select new { d.UserName, d.UserId };
                        ddloprators.DataSource = valusets;
                        ddloprators.DataTextField = "UserName";
                        ddloprators.DataValueField = "UserId";
                        ddloprators.Items.Add(new ListItem() { Text = "All", Value = "0" });
                        ddloprators.DataBind();
                    }
                }
                else if (this.PageTitle == "OPD_Detail_Report")
                {
                    string x = "OPD Detail Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr1MedicalSubsidy.Visible = false;
                    dpROw.Visible = true;
                    trDoctor.Visible = true;
                    tr_Summary.Visible = true;
                    lblMultiSelect.Visible = false;
                    tr_Export.Visible = true;
                    lblPatientType.Text = "Operators";
                    object valusets;
                    valusets = DBClass.GetValueSet("Patient Main Category");
                    ddlDepartments.DataSource = valusets;
                    ddlDepartments.DataTextField = "DataValue_Description";
                    ddlDepartments.DataValueField = "DataValue_Name";
                    ddlDepartments.Items.Add(new ListItem() { Text = "Please Select", Value = "0" });
                    ddlDepartments.DataBind();
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    op_PanelCompany.Visible = false;
                    optRw.Visible = false;
                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    object valusetss = from d in db.aspnet_Users
                                       select new { d.UserName, d.UserId };
                    ddlPatientType.DataSource = valusetss;
                    ddlPatientType.DataTextField = "UserName";
                    ddlPatientType.DataValueField = "UserId";
                    ddlPatientType.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlPatientType.DataBind();

                    DataBaseDataContext db1 = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = (from p in db1.DataValues where p.ValueSet_ID == 3162 orderby p.DataValue_Description select new { p.DataValue_Name, p.DataValue_Description }).ToList();
                    ddlFilterClinic.DataSource = valusets;
                    ddlFilterClinic.DataTextField = "DataValue_Description";
                    ddlFilterClinic.DataValueField = "DataValue_Name";
                    ddlFilterClinic.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlFilterClinic.DataBind();
                    op_FilterClinic.Visible = true;

                    DataTable dt = DBClass.getDataTable("select * from HR_Employees where IsDoctor=1");
                    ddlDoctor.DataSource = dt;
                    ddlDoctor.DataValueField = "Emp_ID";
                    ddlDoctor.DataTextField = "Emp_Name";
                    ddlDoctor.Items.Add(new ListItem() { Value = "0", Text = "All Doctors" });
                    ddlDoctor.DataBind();

                }
                else if (this.PageTitle == "Emergency_Detail_Report")
                {
                    string x = "Emergency Detail Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();

                    tr1MedicalSubsidy.Visible = false;
                    dpROw.Visible = true;
                    trDoctor.Visible = true;
                    tr_Summary.Visible = true;
                    lblMultiSelect.Visible = false;
                    tr_Export.Visible = true;

                    lblPatientType.Text = "Operators";
                    object valusets;
                    valusets = DBClass.GetValueSet("Patient Main Category");

                    ddlDepartments.DataSource = valusets;
                    ddlDepartments.DataTextField = "DataValue_Description";
                    ddlDepartments.DataValueField = "DataValue_Name";
                    ddlDepartments.Items.Add(new ListItem() { Text = "Please Select", Value = "0" });
                    ddlDepartments.DataBind();

                    DateDiv.Visible = true;
                    Time_Row.Visible = true;

                    op_PanelCompany.Visible = false;
                    optRw.Visible = false;
                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

                    var valusetss = from d in db.aspnet_Users
                                    select new { d.UserName, d.UserId };

                    ddlPatientType.DataSource = valusetss;
                    ddlPatientType.DataTextField = "UserName";
                    ddlPatientType.DataValueField = "UserId";
                    ddlPatientType.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlPatientType.DataBind();
                    op_FilterClinic.Visible = false;
                    DataTable dt = DBClass.getDataTable("select * from HR_Employees where IsDoctor=1");

                    ddlDoctor.DataSource = dt;
                    ddlDoctor.DataValueField = "Emp_ID";
                    ddlDoctor.DataTextField = "Emp_Name";
                    ddlDoctor.Items.Add(new ListItem() { Value = "0", Text = "All Doctors" });
                    ddlDoctor.DataBind();
                }
                else if (this.PageTitle == "OPD_Department_Wise_Report")
                {
                    string x = "Department Wise Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr1MedicalSubsidy.Visible = false;
                    dpROw.Visible = true;
                    tr_Summary.Visible = false;      // changed
                    tr_Export.Visible = true;
                    lblMultiSelect.Visible = false;
                    object valusets;
                    valusets = DBClass.GetValueSet("Patient Main Category");
                    ddlDepartments.DataSource = valusets;
                    ddlDepartments.DataTextField = "DataValue_Description";
                    ddlDepartments.DataValueField = "DataValue_Name";
                    ddlDepartments.Items.Add(new ListItem() { Text = "Please Select", Value = "0" });
                    ddlDepartments.DataBind();
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    op_PanelCompany.Visible = false;
                    optRw.Visible = true;
                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    object valusetss = from d in db.aspnet_Users
                                       select new { d.UserName, d.UserId };
                    ddloprators.DataSource = valusetss;
                    ddloprators.DataTextField = "UserName";
                    ddloprators.DataValueField = "UserId";
                    ddloprators.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddloprators.DataBind();

                    //lbShift.Visible = true;
                    //ddlShift.Visible = true;
                    //DataTable shift = DBClass.getDataTable("select * from HR_Shifts");
                    //ddlShift.DataSource = shift;
                    //ddlShift.DataValueField = "Shift_ID";
                    //ddlShift.DataTextField = "Shift_Name";
                    //ddlShift.Items.Add(new ListItem() { Value = "0", Text = "All" });
                    //ddlShift.DataBind();


                    lbShift.Visible = true;
                    ddlShift.Visible = true;
                    ddlShift.Items.Clear();
                    ddlShift.Items.Add(new ListItem("All", "0"));
                    ddlShift.Items.Add(new ListItem("Morning", "2"));
                    ddlShift.Items.Add(new ListItem("Evening", "3"));
                    ddlShift.Items.Add(new ListItem("Night", "4"));

                    trDoctor.Visible = true;

                    DataTable dt = DBClass.getDataTable("select * from HR_Employees where IsDoctor=1");
                    ddlDoctor.DataSource = dt;
                    ddlDoctor.DataValueField = "Emp_ID";
                    ddlDoctor.DataTextField = "Emp_Name";
                    ddlDoctor.Items.Add(new ListItem() { Value = "0", Text = "All Doctors" });
                    ddlDoctor.DataBind();
                    lblMultiSelect.Visible = false;

                    lblPatientType.Visible = true;
                    lblPatientType.Text = "Patient Type";
                    object valusests;
                    valusests = DBClass.GetValueSet("Mode Of Registration");
                    ddlPatientType.DataSource = valusests;
                    ddlPatientType.DataTextField = "DataValue_Description";
                    ddlPatientType.DataValueField = "DataValue_Name";
                    ddlPatientType.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlPatientType.DataBind();
                    ddlPatientType.Visible = true;


                }
                //else if (this.PageTitle == "OPD_Department_Wise_Report")
                //{
                //    string x = "Department Wise Report";
                //    Master.Label2.Text = x;
                //    Master.GetMenuName();
                //    tr1MedicalSubsidy.Visible = false;
                //    dpROw.Visible = true;
                //    tr_Summary.Visible = false;      // changed
                //    lblMultiSelect.Visible = false;
                //    lblPatientType.Text = "Operators";

                //    DateDiv.Visible = true;
                //    Time_Row.Visible = true;
                //    op_PanelCompany.Visible = false;
                //    optRw.Visible = true;
                //    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                //    object valusetss = from d in db.aspnet_Users
                //                      select new { d.UserName, d.UserId };
                //    ddlPatientType.DataSource = valusetss;
                //    ddlPatientType.DataTextField = "UserName";
                //    ddlPatientType.DataValueField = "UserId";
                //    ddlPatientType.Items.Add(new ListItem() { Text = "All", Value = "0" });
                //    ddlPatientType.DataBind();

                //    //lbShift.Visible = true;
                //    //ddlShift.Visible = true;
                //    //DataTable shift = DBClass.getDataTable("select * from HR_Shifts");
                //    //ddlShift.DataSource = shift;
                //    //ddlShift.DataValueField = "Shift_ID";
                //    //ddlShift.DataTextField = "Shift_Name";
                //    //ddlShift.Items.Add(new ListItem() { Value = "0", Text = "All" });
                //    //ddlShift.DataBind();
                //    lboperator.Visible = false;
                //    ddloprators.Visible = false;

                //    lbShift.Visible = true;
                //    ddlShift.Visible = true;
                //    ddlShift.Items.Clear();
                //    ddlShift.Items.Add(new ListItem("All", "0"));
                //    ddlShift.Items.Add(new ListItem("Morning", "2"));
                //    ddlShift.Items.Add(new ListItem("Evening", "3"));
                //    ddlShift.Items.Add(new ListItem("Night", "4"));

                //    trDoctor.Visible = true;

                //    DataTable dt = DBClass.getDataTable("select * from HR_Employees where IsDoctor=1");
                //    ddlDoctor.DataSource = dt;
                //    ddlDoctor.DataValueField = "Emp_ID";
                //    ddlDoctor.DataTextField = "Emp_Name";
                //    ddlDoctor.Items.Add(new ListItem() { Value = "0", Text = "All Doctors" });
                //    ddlDoctor.DataBind();
                //    lblMultiSelect.Visible = false;

                //}
                if (PageTitle == "PCRS")
                {
                    string x = "PCRS";
                    Master.Label2.Text = x;
                    Master.GetMenuName();

                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    tr1MedicalSubsidy.Visible = true;
                    dpROw.Visible = true;
                    ddlDepartments.Visible = true;
                    lblDepartment.Visible = true;
                    lblDepartment.Text = "Company";
                    ddlMedicalSubsidy.Visible = false;
                    lblMedical.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlShift.Visible = false;
                    lbShift.Visible = false;

                    MainDeptDiv.Visible = true;
                    lblPatientType.Visible = false;
                    lblPatientType.Text = "Patient Type";
                    ddlDoctor.Visible = false;
                    ddlPatientType.Visible = false;
                    ddlReportType.Visible = false;
                    ddlMainDepartment.Visible = true;
                    lblMainDepartment.Visible = true;
                    lblMainDepartment.Text = "Item Name";
                    object valusets;
                    DataBaseDataContext dbd = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = from d in dbd.INV_Items
                               where d.IsPharmacyItem == true
                               select new { d.Item_Code, d.Description };
                    ddlMainDepartment.DataSource = valusets;
                    ddlMainDepartment.Items.Clear();
                    ddlMainDepartment.DataTextField = "Description";
                    ddlMainDepartment.DataValueField = "Item_Code";
                    ddlMainDepartment.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlMainDepartment.DataBind();

                    object valusets1;
                    DataBaseDataContext dd = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets1 = (from p in dd.DataValues where p.ValueSet_ID == 7 orderby p.DataValue_Description select new { p.DataValue_Name, p.DataValue_Description }).ToList();
                    ddlDepartments.DataSource = valusets1;
                    ddlDepartments.Items.Clear();
                    ddlDepartments.DataTextField = "DataValue_Description";
                    ddlDepartments.DataValueField = "DataValue_Name";
                    ddlDepartments.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlDepartments.DataBind();

                    optRw.Visible = true;
                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = from pu in db.Pharmacy_Users
                               select new { pu.UserName, pu.UserID };
                    ddloprators.DataSource = valusets;
                    ddloprators.DataTextField = "UserName";
                    ddloprators.DataValueField = "UserId";
                    ddloprators.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddloprators.DataBind();


                    //ADDING NEW WAREHOUSE

                    object valuset;
                    ddlwareHouse.DataSource = GetUserWarehouses();
                    ddlwareHouse.DataTextField = "Text";
                    ddlwareHouse.DataValueField = "Value";
                    ddlwareHouse.Items.Clear();
                    ddlwareHouse.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlwareHouse.DataBind();
                    Stock_Movement.Visible = true;


                    ddlwareHouse.Visible = true;
                    lblWarehouse.Visible = true;

                    lbItemCategory.Visible = false;
                    ddlItemCategory.Visible = false;
                }
                else if (this.PageTitle == "Consultant_Wise_Statistics")
                {
                    string x = "Consultant Wise Statistics";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr1MedicalSubsidy.Visible = false;
                    dpROw.Visible = false;
                    tr_Summary.Visible = false;      // changed
                    lblMultiSelect.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    op_PanelCompany.Visible = false;
                    optRw.Visible = false;


                    trDoctor.Visible = true;

                    DataTable dt = DBClass.getDataTable("select * from HR_Employees where IsDoctor=1");
                    ddlDoctor.DataSource = dt;
                    ddlDoctor.DataValueField = "Emp_ID";
                    ddlDoctor.DataTextField = "Emp_Name";
                    ddlDoctor.Items.Add(new ListItem() { Value = "0", Text = "All Doctors" });
                    ddlDoctor.DataBind();
                    lblMultiSelect.Visible = false;

                }
                else if (this.PageTitle == "Counsltant_Day_Wise_report")
                {
                    string x = "Consultant Day Wise Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr1MedicalSubsidy.Visible = false;
                    dpROw.Visible = false;
                    tr_Summary.Visible = false;      // changed
                    lblMultiSelect.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    op_PanelCompany.Visible = false;
                    optRw.Visible = false;


                    trDoctor.Visible = true;

                    DataTable dt = DBClass.getDataTable("select * from HR_Employees where IsDoctor=1");
                    ddlDoctor.DataSource = dt;
                    ddlDoctor.DataValueField = "Emp_ID";
                    ddlDoctor.DataTextField = "Emp_Name";
                    ddlDoctor.Items.Add(new ListItem() { Value = "0", Text = "All Doctors" });
                    ddlDoctor.DataBind();
                    lblMultiSelect.Visible = false;

                }
                else if (this.PageTitle == "Department_Wise_Statistics")
                {
                    string x = "Department Wise Statistics";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr1MedicalSubsidy.Visible = false;
                    dpROw.Visible = false;
                    tr_Summary.Visible = false;      // changed
                    lblMultiSelect.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    op_PanelCompany.Visible = false;
                    optRw.Visible = false;


                }

                else if (this.PageTitle == "DoctorWiseUltrasoundReport")
                {
                    string x = "Radiology Statistics Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;

                    lbShift.Visible = false;
                    ddlShift.Visible = false;
                    optRw.Visible = true;
                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    object valusetss = from d in db.aspnet_Users
                                       select new { d.UserName, d.UserId };
                    ddloprators.DataSource = valusetss;
                    ddloprators.DataTextField = "UserName";
                    ddloprators.DataValueField = "UserId";
                    ddloprators.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddloprators.DataBind();
                }

                else if (this.PageTitle == "Over_Summary_Shift_Wise")
                {
                    string x = "Over Summary Shift Wise Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr1MedicalSubsidy.Visible = false;
                    dpROw.Visible = true;
                    trDoctor.Visible = false;
                    tr_Summary.Visible = false;
                    lblMultiSelect.Visible = false;
                    lblPatientType.Text = "Operators";
                    object valusets;
                    valusets = DBClass.GetValueSet("Patient Main Category");
                    ddlDepartments.DataSource = valusets;
                    ddlDepartments.DataTextField = "DataValue_Description";
                    ddlDepartments.DataValueField = "DataValue_Name";
                    ddlDepartments.Items.Add(new ListItem() { Text = "Please Select", Value = "0" });
                    ddlDepartments.DataBind();
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    op_PanelCompany.Visible = false;
                    optRw.Visible = true;
                    lboperator.Visible = false;
                    ddloprators.Visible = false;
                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    object valusetss = from d in db.aspnet_Users
                                       select new { d.UserName, d.UserId };
                    ddlPatientType.DataSource = valusetss;
                    ddlPatientType.DataTextField = "UserName";
                    ddlPatientType.DataValueField = "UserId";
                    ddlPatientType.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlPatientType.DataBind();

                    // 👇 Replace HR_Shifts with static shift options
                    lbShift.Visible = true;
                    ddlShift.Visible = true;
                    ddlShift.Items.Clear();
                    ddlShift.Items.Add(new ListItem("All", "0"));
                    ddlShift.Items.Add(new ListItem("Morning", "2"));
                    ddlShift.Items.Add(new ListItem("Evening", "3"));
                    ddlShift.Items.Add(new ListItem("Night", "4"));
                }
                else if (this.PageTitle == "ActiveItems")
                {
                    string x = "Active Inventory Items Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr1MedicalSubsidy.Visible = false;
                    dpROw.Visible = false;
                    trDoctor.Visible = false;
                    tr_Summary.Visible = false;
                    tr_Export.Visible = true;
                    lblMultiSelect.Visible = false;
                    lblPatientType.Text = "Operators";
                    DateDiv.Visible = false;
                    Time_Row.Visible = false;
                    op_PanelCompany.Visible = false;
                    optRw.Visible = false;
                    lboperator.Visible = false;
                    ddloprators.Visible = false;
                    trStatus.Visible = true;
                    trItemFilter.Visible = true;
                }

                if (this.PageTitle == "DepartmentWiseReport")
                {
                    string x = "Department Wise Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    object valusets;
                    //lblMainDepartment.Visible = true;
                    lblPatientType.Visible = true;
                    lblMultiSelect.Visible = true;
                    dpROw.Visible = true;
                    ddlPatientType.Visible = true;
                    //ddlDepartments.Visible = true;
                    lblMainDepartment.Visible = true;
                    lblMainDepartment.Visible = true;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    tr1MedicalSubsidy.Visible = true;
                    //dpROw.Visible = true;
                    lblMainDepartment.Visible = true;
                    // SetDepartent();  
                    ddlMedicalSubsidy.Visible = true;
                    //fillshiftdropdown
                    optRw.Visible = true;
                    lblMedical.Text = "Discount Detail";
                    //lboperator.Visible = true;
                    //ddloprators.Visible = true;
                    lbShift.Visible = true;
                    ddlShift.Visible = true;
                    DataTable shift = DBClass.getDataTable("select * from HR_Shifts");
                    ddlShift.DataSource = shift;
                    ddlShift.DataValueField = "Shift_ID";
                    ddlShift.DataTextField = "Shift_Name";
                    ddlShift.Items.Add(new ListItem() { Value = "0", Text = "All" });
                    ddlShift.DataBind();
                    trDoctor.Visible = true;
                    ddlReportType.Visible = false;

                    DataTable dt = DBClass.getDataTable("select * from HR_Employees where IsDoctor=1");
                    ddlDoctor.DataSource = dt;
                    ddlDoctor.DataValueField = "Emp_ID";
                    ddlDoctor.DataTextField = "Emp_Name";
                    ddlDoctor.Items.Add(new ListItem() { Value = "0", Text = "All Doctors" });
                    ddlDoctor.DataBind();

                    //
                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    var qry = (from p in db.aspnet_Roles
                               join roles in db.aspnet_UsersInRoles
                               on p.RoleId equals roles.RoleId
                               join users in db.aspnet_Users on roles.UserId equals users.UserId
                               where users.UserId == AppConfig.UserID
                               select p).FirstOrDefault();


                    if (qry.Department_ID == "All_Departments")
                    {
                        var records = (from data in db.ValueSets
                                       join d in db.DataValues on data.ValueSet_ID equals d.ValueSet_ID
                                       where data.ValueSet_Description.Equals("Patient Main Category")
                                       select new
                                       {
                                           d.DataValue_Name,
                                           d.DataValue_Description

                                       }).ToList();
                        ddlDepartments.DataSource = records;
                        ddlDepartments.DataTextField = "DataValue_Description";
                        ddlDepartments.DataValueField = "DataValue_Name";
                        ddlDepartments.Items.Add(new ListItem() { Text = "All", Value = "All" });
                        ddlDepartments.DataBind();
                    }
                    else
                    {
                        var signledepartment = (from data in db.ValueSets
                                                join d in db.DataValues on data.ValueSet_ID equals d.ValueSet_ID
                                                where data.ValueSet_Description.Equals("Patient Main Category") && d.DataValue_Name == qry.Department_ID
                                                select new
                                                {
                                                    d.DataValue_Name,
                                                    d.DataValue_Description


                                                }).ToList();
                        ddlDepartments.DataSource = signledepartment;
                        ddlDepartments.DataTextField = "DataValue_Description";
                        ddlDepartments.DataValueField = "DataValue_Name";
                        //ddlDepartments.Items.Add(new ListItem() { Text = "All", Value = "All" });
                        ddlDepartments.DataBind();

                    }

                }

                else if (this.PageTitle == "IPD_Detail_Report")
                {
                    string x = "IPD Detail Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr1MedicalSubsidy.Visible = false;
                    dpROw.Visible = true;
                    trDoctor.Visible = false;
                    tr_Summary.Visible = true;
                    lblMultiSelect.Visible = false;
                    lblPatientType.Text = "Operators";
                    object valusets;
                    valusets = DBClass.GetValueSet("Patient Main Category");
                    ddlDepartments.DataSource = valusets;
                    ddlDepartments.DataTextField = "DataValue_Description";
                    ddlDepartments.DataValueField = "DataValue_Name";
                    ddlDepartments.Items.Add(new ListItem() { Text = "Please Select", Value = "0" });
                    ddlDepartments.DataBind();
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    tr_Export.Visible = true;
                    op_PanelCompany.Visible = false;
                    optRw.Visible = false;
                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    object valusetss = from d in db.aspnet_Users
                                       select new { d.UserName, d.UserId };
                    ddlPatientType.DataSource = valusetss;
                    ddlPatientType.DataTextField = "UserName";
                    ddlPatientType.DataValueField = "UserId";
                    ddlPatientType.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlPatientType.DataBind();
                }

                else if (this.PageTitle == "Emer_Detail_Report")
                {
                    string x = "Emergency Detail Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr1MedicalSubsidy.Visible = false;
                    tr_Export.Visible = true;
                    dpROw.Visible = false;
                    trDoctor.Visible = false;
                    tr_Summary.Visible = true;
                    lblMultiSelect.Visible = false;
                    lblPatientType.Text = "Operators";


                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    op_PanelCompany.Visible = false;
                    lbShift.Visible = false;
                    ddlShift.Visible = false;
                    optRw.Visible = true;
                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    object valusetss = from d in db.aspnet_Users
                                       select new { d.UserName, d.UserId };
                    ddloprators.DataSource = valusetss;
                    ddloprators.DataTextField = "UserName";
                    ddloprators.DataValueField = "UserId";
                    ddloprators.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddloprators.DataBind();
                }
                else if (this.PageTitle == "Emergency_Reg_Report")
                {
                    string x = "Registered Emergency Detail Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr1MedicalSubsidy.Visible = false;
                    tr_Export.Visible = true;
                    dpROw.Visible = false;
                    trDoctor.Visible = false;
                    tr_Summary.Visible = true;
                    lblMultiSelect.Visible = false;
                    lblPatientType.Text = "Operators";


                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    op_PanelCompany.Visible = false;
                    lbShift.Visible = false;
                    ddlShift.Visible = false;
                    optRw.Visible = true;
                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    object valusetss = from d in db.aspnet_Users
                                       select new { d.UserName, d.UserId };
                    ddloprators.DataSource = valusetss;
                    ddloprators.DataTextField = "UserName";
                    ddloprators.DataValueField = "UserId";
                    ddloprators.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddloprators.DataBind();
                }

                //else if (this.PageTitle == "OPD_Time_Line")
                //{

                //    dpROw.Visible = false;

                //    tr1MedicalSubsidy.Visible = true;
                //    lblMedical.Text = "Time Line";

                //    lblMultiSelect.Visible = false;
                //    lblPatientType.Visible = false;
                //    Time_Row.Visible = true;
                //    tr_Summary.Visible = false;
                //    optRw.Visible = true;
                //    AllowPatientRecord = false;

                //    ddlMedicalSubsidy.Items.Clear();
                //    if (this.PageTitle == "OPD_Time_Line")
                //    {
                //        ddlMedicalSubsidy.Items.Add("Weekly");
                //    }
                //    ddlMedicalSubsidy.Items.Add("Monthly");
                //    ddlMedicalSubsidy.Items.Add("Annually");

                //    lblMainDepartment.Visible = false;
                //    ddlDepartments.Visible = false;
                //    tr1MedicalSubsidy.Visible = true;
                //    lblMedical.Text = "Time Line";
                //    ddlMedicalSubsidy.Items.Add("Weekly");
                //    ddlMedicalSubsidy.Items.Add("Monthly");
                //    ddlMedicalSubsidy.Items.Add("Annually");
                //    lblPatientType.Visible = false;
                //    lblMultiSelect.Visible = false;
                //    ddlPatientType.Visible = false;
                //    optRw.Visible = false;
                //    trDoctor.Visible = false;
                //    tr_Summary.Visible = false;
                //    ddlMedicalSubsidy.Items.Clear();
                //    lblMainDepartment.Visible = false;
                //    dpROw.Visible = false;
                //    AllowPatientRecord = false;
                //}
                #endregion
                #region Inventory

                #endregion
                #region Operations Reports
                //Active Patient List
                if (this.PageTitle == "APL")
                {
                    string x = "APL";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    Time_Row.Visible = true;
                    DateDiv.Visible = true;
                    tr1MedicalSubsidy.Visible = true;
                    dpROw.Visible = true;
                    SetDepartent();
                    ddlMedicalSubsidy.Visible = false;
                    lblMedical.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlShift.Visible = false;
                    lbShift.Visible = false;
                    tr_Export.Visible = false;
                    trDoctor.Visible = false;
                    tr_Summary.Visible = false;
                    lblPatientType.Visible = true;
                    lblPatientType.Text = "Patient Type";
                    object valusets;
                    valusets = DBClass.GetValueSet("Patient Type");
                    ddlPatientType.DataSource = valusets;
                    ddlPatientType.DataTextField = "DataValue_Description";
                    ddlPatientType.DataValueField = "DataValue_Name";
                    ddlPatientType.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlPatientType.DataBind();
                    ddlPatientType.Visible = true;

                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = (from p in db.DataValues where p.ValueSet_ID == 3162 orderby p.DataValue_Description select new { p.DataValue_Name, p.DataValue_Description }).ToList();
                    ddlFilterClinic.DataSource = valusets;
                    ddlFilterClinic.DataTextField = "DataValue_Description";
                    ddlFilterClinic.DataValueField = "DataValue_Name";
                    ddlFilterClinic.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlFilterClinic.DataBind();
                    op_FilterClinic.Visible = true;
                    ddlReportType.Visible = false;
                    lbservieType.Visible = false;
                }
                //Active Patient List Summary
                if (this.PageTitle == "APLS")
                {
                    string x = "APLS";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    Time_Row.Visible = true;
                    DateDiv.Visible = true;
                    tr1MedicalSubsidy.Visible = true;
                    dpROw.Visible = true;
                    SetDepartent();
                    ddlMedicalSubsidy.Visible = false;
                    lblMultiSelect.Visible = false;
                    lblMedical.Visible = false;
                    ddlShift.Visible = false;
                    lbShift.Visible = false;
                    tr_Export.Visible = false;
                    lblPatientType.Text = "Patient Type";
                    object valusets;
                    valusets = DBClass.GetValueSet("Patient Type");
                    ddlPatientType.DataSource = valusets;
                    ddlPatientType.DataTextField = "DataValue_Description";
                    ddlPatientType.DataValueField = "DataValue_Name";
                    ddlPatientType.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlPatientType.DataBind();
                    ddlPatientType.Visible = true;
                    trDoctor.Visible = true;
                    tr_Summary.Visible = false;
                    DataTable dt = DBClass.getDataTable("select * from HR_Employees where IsDoctor=1");
                    ddlDoctor.DataSource = dt;
                    ddlDoctor.DataValueField = "Emp_ID";
                    ddlDoctor.DataTextField = "Emp_Name";
                    ddlDoctor.Items.Add(new ListItem() { Value = "0", Text = "All Doctors" });
                    ddlDoctor.DataBind();
                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = (from p in db.DataValues where p.ValueSet_ID == 3162 orderby p.DataValue_Description select new { p.DataValue_Name, p.DataValue_Description }).ToList();
                    ddlFilterClinic.DataSource = valusets;
                    ddlFilterClinic.DataTextField = "DataValue_Description";
                    ddlFilterClinic.DataValueField = "DataValue_Name";
                    ddlFilterClinic.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlFilterClinic.DataBind();
                    op_FilterClinic.Visible = true;
                    ddlReportType.Visible = false;
                    lbservieType.Visible = false;
                }
                //Appointment List
                if (this.PageTitle == "AL")
                {

                    string x = "Appointment List";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr1MedicalSubsidy.Visible = true;
                    dpROw.Visible = false;
                    SetDepartent();
                    ddlDepartments.Visible = false;
                    lblDepartment.Visible = false;
                    ddlMedicalSubsidy.Visible = false;
                    lblMedical.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlShift.Visible = false;
                    lbShift.Visible = false;
                    tr_Export.Visible = false;
                    trDoctor.Visible = true;
                    tr_Summary.Visible = false;
                    lblPatientType.Visible = false;
                    lblPatientType.Text = "Patient Type";
                    object valusets;
                    DataTable dt = DBClass.getDataTable("select * from HR_Employees where IsDoctor=1");
                    ddlDoctor.DataSource = dt;
                    ddlDoctor.DataValueField = "Emp_ID";
                    ddlDoctor.DataTextField = "Emp_Name";
                    ddlDoctor.Items.Add(new ListItem() { Value = "0", Text = "All Doctors" });
                    ddlDoctor.DataBind();
                    ddlPatientType.Visible = false;
                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = (from p in db.DataValues where p.ValueSet_ID == 3162 orderby p.DataValue_Description select new { p.DataValue_Name, p.DataValue_Description }).ToList();
                    ddlFilterClinic.DataSource = valusets;
                    ddlFilterClinic.DataTextField = "DataValue_Description";
                    ddlFilterClinic.DataValueField = "DataValue_Name";
                    ddlFilterClinic.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlFilterClinic.DataBind();
                    op_FilterClinic.Visible = false;
                    ddlReportType.Visible = false;
                    lbservieType.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                }
                //Patient Ledger
                if (this.PageTitle == "PatientLedger")
                {
                    string x = "Patient Ledger Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr1MedicalSubsidy.Visible = true;
                    dpROw.Visible = true;
                    Time_Row.Visible = true;
                    SetDepartent();
                    ddlMedicalSubsidy.Visible = false;
                    lblMultiSelect.Visible = false;
                    DateDiv.Visible = true;
                    lblMedical.Visible = false;
                    ddlShift.Visible = false;
                    lbShift.Visible = false;
                    tr_Export.Visible = false;
                    lblPatientType.Text = "Patient Type";
                    object valusets;
                    valusets = DBClass.GetValueSet("Patient Type");
                    ddlPatientType.DataSource = valusets;
                    ddlPatientType.DataTextField = "DataValue_Description";
                    ddlPatientType.DataValueField = "DataValue_Name";
                    ddlPatientType.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlPatientType.DataBind();
                    ddlPatientType.Visible = true;
                    trDoctor.Visible = true;
                    tr_Summary.Visible = false;


                    DataTable dt = DBClass.getDataTable("select * from HR_Employees where IsDoctor=1");
                    ddlDoctor.DataSource = dt;
                    ddlDoctor.DataValueField = "Emp_ID";
                    ddlDoctor.DataTextField = "Emp_Name";
                    ddlDoctor.Items.Add(new ListItem() { Value = "0", Text = "All Doctors" });
                    ddlDoctor.DataBind();
                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = (from p in db.DataValues where p.ValueSet_ID == 3162 orderby p.DataValue_Description select new { p.DataValue_Name, p.DataValue_Description }).ToList();
                    ddlFilterClinic.DataSource = valusets;
                    ddlFilterClinic.DataTextField = "DataValue_Description";
                    ddlFilterClinic.DataValueField = "DataValue_Name";
                    ddlFilterClinic.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlFilterClinic.DataBind();
                    op_FilterClinic.Visible = true;
                    ddlReportType.Visible = false;
                    lbservieType.Visible = false;
                }

                // Single Patient Ledger


                if (this.PageTitle == "SinglePatientLedger")
                {
                    string x = "Single Patient Ledger Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr1MedicalSubsidy.Visible = true;
                    dpROw.Visible = false;
                    MRDiv.Visible = true;
                    lblMRNo.Visible = true;
                    txtMRNo.Visible = true;
                    ddlDepartments.Visible = false;
                    lblDepartment.Visible = false;
                    lblPatientType.Visible = false;
                    ddlMedicalSubsidy.Visible = false;
                    lblMultiSelect.Visible = false;
                    lblMedical.Visible = false;
                    ddlShift.Visible = false;


                    //lblShift.Visible = false;

                    //lblPatientType.Text = "Patient Type";
                    //object valusets;
                    //valusets = DBClass.GetValueSet("Patient Type");
                    //ddlPatientType.DataSource = valusets;
                    //ddlPatientType.DataTextField = "DataValue_Description";
                    //ddlPatientType.DataValueField = "DataValue_Name";
                    //ddlPatientType.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    //ddlPatientType.DataBind();
                    //ddlPatientType.Visible = false;
                    ////trDoctors.Visible = false;
                    ////trSummary.Visible = false;
                    //DataTable dt = DBClass.getDataTable("select * from HR_Employees where IsDoctor=1");
                    //ddlDoctor.DataSource = dt;
                    //ddlDoctor.DataValueField = "Emp_ID";
                    //ddlDoctor.DataTextField = "Emp_Name";
                    //ddlDoctor.Items.Add(new ListItem() { Value = "0", Text = "All Doctors" });
                    //ddlDoctor.DataBind();
                    //DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    //valusets = (from p in db.DataValues where p.ValueSet_ID == 3162 orderby p.DataValue_Description select new { p.DataValue_Name, p.DataValue_Description }).ToList();
                    //ddlFilterClinic.DataSource = valusets;
                    //ddlFilterClinic.DataTextField = "DataValue_Description";
                    //ddlFilterClinic.DataValueField = "DataValue_Name";
                    //ddlFilterClinic.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    //ddlFilterClinic.DataBind();
                    //opFilterClinic.Visible = false;
                    ddlReportType.Visible = false;
                    //lblservieType.Visible = false;
                }

                if (this.PageTitle == "SinglePatientLedger1")
                {
                    string x = "Single Patient Ledger1 Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();

                    PatientDiv.Visible = true;



                    tr1MedicalSubsidy.Visible = true;
                    dpROw.Visible = true;
                    MRDiv.Visible = true;
                    lblMRNo.Visible = true;
                    txtMRNo.Visible = true;
                    ddlDepartments.Visible = false;
                    DateDiv.Visible = false;
                    Time_Row.Visible = false;
                    lblDepartment.Visible = false;
                    lblPatientType.Visible = false;
                    ddlMedicalSubsidy.Visible = false;
                    lblMultiSelect.Visible = false;
                    lblMedical.Visible = false;
                    ddlShift.Visible = false;
                    lbShift.Visible = false;
                    tr_Export.Visible = false;
                    //lblPatientType.Visible = true;   // added 
                    //lblPatientType.Text = "Patient Type";
                    //object valusets;



                    //valusets = DBClass.GetValueSet("Patient Type");
                    //ddlPatientType.DataSource = valusets;
                    //ddlPatientType.DataTextField = "DataValue_Description";
                    //ddlPatientType.DataValueField = "DataValue_Name";
                    //ddlPatientType.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    //ddlPatientType.DataBind();
                    //ddlPatientType.Visible = true;


                    //DataTable dtb = DBClass.getDataTable("SELECT pat_id, full_name, patient_no FROM reg_patient");
                    //ddlPatient.DataSource = dtb;
                    //ddlPatient.DataTextField = "full_name";
                    //ddlPatient.DataValueField = "pat_id";
                    //ddlPatient.DataBind();

                    //trDoctor.Visible = false;
                    //tr_Summary.Visible = false;



                    //DataTable dt = DBClass.getDataTable("select * from HR_Employees where IsDoctor=1");
                    //ddlDoctor.DataSource = dt;
                    //ddlDoctor.DataValueField = "Emp_ID";
                    //ddlDoctor.DataTextField = "Emp_Name";
                    //ddlDoctor.Items.Add(new ListItem() { Value = "0", Text = "All Doctors" });
                    //ddlDoctor.DataBind();
                    //DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    //valusets = (from p in db.DataValues where p.ValueSet_ID == 3162 orderby p.DataValue_Description select new { p.DataValue_Name, p.DataValue_Description }).ToList();
                    //ddlFilterClinic.DataSource = valusets;
                    //ddlFilterClinic.DataTextField = "DataValue_Description";
                    //ddlFilterClinic.DataValueField = "DataValue_Name";
                    //ddlFilterClinic.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    //ddlFilterClinic.DataBind();
                    //op_FilterClinic.Visible = false;
                    //ddlReportType.Visible = false;
                    //lbservieType.Visible = false;
                }
                //Revenue - Department Wise Total Patient
                if (PageTitle == "RDW")
                {
                    string x = "Revenue Department Wise Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = true;
                    ddlDepartments.Visible = true;
                    lblPatientType.Visible = true;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    lblDepartment.Visible = true;
                    lblDepartment.Text = "Patient Type";
                    object valusets;
                    valusets = DBClass.GetValueSet("Patient Type");
                    ddlDepartments.DataSource = valusets;
                    ddlDepartments.DataTextField = "DataValue_Description";
                    ddlDepartments.DataValueField = "DataValue_Name";
                    ddlDepartments.Items.Add(new ListItem() { Text = "Please Select", Value = "0" });
                    ddlDepartments.DataBind();
                    lblPatientType.Visible = false;
                    optRw.Visible = false;
                    trDoctor.Visible = false;
                    tr_Summary.Visible = true;
                    valusets = DBClass.GetValueSet("Casher");
                    ddlcashier.DataSource = valusets;
                    ddlcashier.DataTextField = "DataValue_Description";
                    ddlcashier.DataValueField = "DataValue_Name";
                    ddlcashier.Items.Add(new ListItem() { Text = "Please Select", Value = "0" });
                    ddlcashier.DataBind();
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    lblMainDepartment.Visible = false;
                    ddlShift.Visible = false;
                    ddlcashier.Visible = true;
                    CashierRow.Visible = true;
                    lbShift.Visible = false;
                    tr_Export.Visible = false;
                    dpROw.Visible = true;
                    tr_Summary.Visible = false;
                    if (AllowPatientRecord)
                    {
                        optRw.Visible = true;
                        DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                        valusets = from d in db.aspnet_Users
                                   select new { d.UserName, d.UserId };
                        ddloprators.DataSource = valusets;
                        ddloprators.DataTextField = "UserName";
                        ddloprators.DataValueField = "UserId";
                        ddloprators.Items.Add(new ListItem() { Text = "All", Value = "0" });
                        ddloprators.DataBind();
                    }
                }
                //Revenue - Department Wise Summary
                if (PageTitle == "RevenuseSummary")
                {
                    string x = "Revenue Department Summary Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr1MedicalSubsidy.Visible = true;
                    dpROw.Visible = false;
                    SetDepartent();
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    ddlDepartments.Visible = false;
                    lblDepartment.Visible = false;
                    ddlMedicalSubsidy.Visible = false;
                    lblMedical.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlShift.Visible = false;
                    lbShift.Visible = false;
                    tr_Export.Visible = false;
                    trDoctor.Visible = false;
                    tr_Summary.Visible = false;
                    lblPatientType.Visible = false;
                    lblPatientType.Text = "Patient Type";
                    object valusets;
                    DataTable dt = DBClass.getDataTable("select * from HR_Employees where IsDoctor=1");
                    ddlDoctor.DataSource = dt;
                    ddlDoctor.DataValueField = "Emp_ID";
                    ddlDoctor.DataTextField = "Emp_Name";
                    ddlDoctor.Items.Add(new ListItem() { Value = "0", Text = "All Doctors" });
                    ddlDoctor.DataBind();
                    ddlDoctor.Visible = false;
                    ddlPatientType.Visible = false;
                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = (from p in db.DataValues where p.ValueSet_ID == 3162 orderby p.DataValue_Description select new { p.DataValue_Name, p.DataValue_Description }).ToList();
                    ddlFilterClinic.DataSource = valusets;
                    ddlFilterClinic.DataTextField = "DataValue_Description";
                    ddlFilterClinic.DataValueField = "DataValue_Name";
                    ddlFilterClinic.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlFilterClinic.DataBind();
                    op_FilterClinic.Visible = false;
                    ddlReportType.Visible = false;
                    lbservieType.Visible = false;
                }
                //Pharmacy Cash Report
                if (PageTitle == "PCR")
                {
                    string x = "Pharmacy Cash Report";
                    Master.Label2.Text = x;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    Master.GetMenuName();
                    tr1MedicalSubsidy.Visible = true;
                    dpROw.Visible = false;
                    ddlDepartments.Visible = false;
                    lblDepartment.Visible = false;
                    ddlMedicalSubsidy.Visible = false;
                    lblMedical.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlShift.Visible = false;
                    lbShift.Visible = false;
                    tr_Export.Visible = false;
                    trDoctor.Visible = false;
                    tr_Summary.Visible = false;
                    lblPatientType.Visible = false;
                    lblPatientType.Text = "Patient Type";
                    ddlDoctor.Visible = false;
                    ddlPatientType.Visible = false;
                    op_FilterClinic.Visible = false;
                    ddlReportType.Visible = false;
                    lbservieType.Visible = false;

                    MRDiv.Visible = true;
                    lblMRNo.Visible = true;
                    txtMRNo.Visible = true;


                    //ADDING NEW WAREHOUSE

                    object valuset;
                    ddlwareHouse.DataSource = GetUserWarehouses();
                    ddlwareHouse.DataTextField = "Text";
                    ddlwareHouse.DataValueField = "Value";
                    ddlwareHouse.Items.Clear();
                    ddlwareHouse.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlwareHouse.DataBind();
                    Stock_Movement.Visible = true;


                    ddlwareHouse.Visible = true;
                    lblWarehouse.Visible = true;

                    lbItemCategory.Visible = false;
                    ddlItemCategory.Visible = false;
                }

                //Pharmacy Cash Report Summary
                //if (PageTitle == "PCRS")
                //{
                //    string x = "Pharmacy Cash Report Summary";
                //    Master.Label2.Text = x;
                //    Master.GetMenuName();
                //    DateDiv.Visible = true;
                //    Time_Row.Visible = true;
                //    tr1MedicalSubsidy.Visible = true;
                //    dpROw.Visible = false;
                //    ddlDepartments.Visible = false;
                //    lblDepartment.Visible = false;
                //    ddlMedicalSubsidy.Visible = false;
                //    lblMedical.Visible = false;
                //    lblMultiSelect.Visible = false;
                //    ddlShift.Visible = false;
                //    lbShift.Visible = false;
                //    tr_Export.Visible = false;
                //    trDoctor.Visible = false;
                //    tr_Summary.Visible = false;
                //    lblPatientType.Visible = false;
                //    lblPatientType.Text = "Patient Type";
                //    ddlDoctor.Visible = false;
                //    ddlPatientType.Visible = false;
                //    op_FilterClinic.Visible = false;
                //    ddlReportType.Visible = false;
                //    lbservieType.Visible = false;
                //}
                //Doctor wise Sale Cash Report
                if (this.PageTitle == "DoctorMS")
                {
                    string x = "Doctor Wise Sale Cash Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr1MedicalSubsidy.Visible = true;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    dpROw.Visible = false;
                    SetDepartent();
                    ddlDepartments.Visible = false;
                    lblDepartment.Visible = false;
                    ddlMedicalSubsidy.Visible = false;
                    lblMedical.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlShift.Visible = false;
                    lbShift.Visible = false;
                    tr_Export.Visible = false;
                    trDoctor.Visible = true;
                    tr_Summary.Visible = false;
                    lblPatientType.Visible = false;
                    lblPatientType.Text = "Patient Type";
                    object valusets;
                    DataTable dt = DBClass.getDataTable("select * from HR_Employees where IsDoctor=1");
                    ddlDoctor.DataSource = dt;
                    ddlDoctor.DataValueField = "Emp_ID";
                    ddlDoctor.DataTextField = "Emp_Name";
                    ddlDoctor.Items.Add(new ListItem() { Value = "0", Text = "All Doctors" });
                    ddlDoctor.DataBind();
                    ddlPatientType.Visible = false;
                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = (from p in db.DataValues where p.ValueSet_ID == 3162 orderby p.DataValue_Description select new { p.DataValue_Name, p.DataValue_Description }).ToList();
                    ddlFilterClinic.DataSource = valusets;
                    ddlFilterClinic.DataTextField = "DataValue_Description";
                    ddlFilterClinic.DataValueField = "DataValue_Name";
                    ddlFilterClinic.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlFilterClinic.DataBind();
                    op_FilterClinic.Visible = false;
                    ddlReportType.Visible = false;
                    lbservieType.Visible = false;
                }
                //Doctor wise sales Cash Report Summary
                if (this.PageTitle == "DoctorMSS")
                {
                    string x = "Doctor Wise Sale Cash Summary Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr1MedicalSubsidy.Visible = true;
                    dpROw.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    SetDepartent();
                    ddlDepartments.Visible = false;
                    lblDepartment.Visible = false;
                    ddlMedicalSubsidy.Visible = false;
                    lblMedical.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlShift.Visible = false;
                    lbShift.Visible = false;
                    tr_Export.Visible = false;
                    trDoctor.Visible = true;
                    tr_Summary.Visible = false;
                    lblPatientType.Visible = false;
                    lblPatientType.Text = "Patient Type";
                    object valusets;
                    DataTable dt = DBClass.getDataTable("select * from HR_Employees where IsDoctor=1");
                    ddlDoctor.DataSource = dt;
                    ddlDoctor.DataValueField = "Emp_ID";
                    ddlDoctor.DataTextField = "Emp_Name";
                    ddlDoctor.Items.Add(new ListItem() { Value = "0", Text = "All Doctors" });
                    ddlDoctor.DataBind();
                    ddlPatientType.Visible = false;
                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = (from p in db.DataValues where p.ValueSet_ID == 3162 orderby p.DataValue_Description select new { p.DataValue_Name, p.DataValue_Description }).ToList();
                    ddlFilterClinic.DataSource = valusets;
                    ddlFilterClinic.DataTextField = "DataValue_Description";
                    ddlFilterClinic.DataValueField = "DataValue_Name";
                    ddlFilterClinic.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlFilterClinic.DataBind();
                    op_FilterClinic.Visible = false;
                    ddlReportType.Visible = false;
                    lbservieType.Visible = false;
                }
                //Department Cash Report
                if (this.PageTitle == "DMS")
                {
                    string x = "Deparment Cash Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr1MedicalSubsidy.Visible = true;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    dpROw.Visible = false;
                    SetDepartent();
                    ddlDepartments.Visible = true;
                    lblDepartment.Visible = true;
                    ddlMedicalSubsidy.Visible = false;
                    lblMedical.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlShift.Visible = false;
                    lbShift.Visible = false;
                    tr_Export.Visible = false;
                    trDoctor.Visible = false;
                    tr_Summary.Visible = false;
                    lblPatientType.Visible = false;
                    lblPatientType.Text = "Patient Type";
                    ddlDoctor.Visible = false;
                    ddlPatientType.Visible = false;
                    op_FilterClinic.Visible = false;
                    ddlReportType.Visible = false;
                    lbservieType.Visible = false;
                }
                //Department Cash Report Summary
                if (this.PageTitle == "DMSS")
                {
                    string x = "Department Cash Report Summary";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr1MedicalSubsidy.Visible = true;
                    dpROw.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    SetDepartent();
                    ddlDepartments.Visible = true;
                    lblDepartment.Visible = true;
                    ddlMedicalSubsidy.Visible = false;
                    lblMedical.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlShift.Visible = false;
                    lbShift.Visible = false;
                    tr_Export.Visible = false;
                    trDoctor.Visible = false;
                    tr_Summary.Visible = false;
                    lblPatientType.Visible = false;
                    lblPatientType.Text = "Patient Type";
                    ddlDoctor.Visible = false;
                    ddlPatientType.Visible = false;
                    op_FilterClinic.Visible = false;
                    ddlReportType.Visible = false;
                    lbservieType.Visible = false;
                }
                if (this.PageTitle == "ITR")
                {
                    string x = "Inventory Track Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr1MedicalSubsidy.Visible = true;
                    dpROw.Visible = false;
                    LoadForm();
                    tr_Inv.Visible = true;
                    ddlDepartments.Visible = false;
                    lblDepartment.Visible = false;
                    ddlInvForm.Visible = true;
                    ddlMedicalSubsidy.Visible = false;
                    lblMedical.Visible = false;
                    lblMultiSelect.Visible = false;
                    lbnvNo.Visible = true;
                    ddlInvNo.Visible = true;
                    ddlShift.Visible = false;
                    lbShift.Visible = false;
                    tr_Export.Visible = false;
                    trDoctor.Visible = false;
                    tr_Summary.Visible = false;
                    lblPatientType.Visible = false;
                    lblPatientType.Text = "Patient Type";
                    ddlDoctor.Visible = false;
                    ddlPatientType.Visible = false;
                    op_FilterClinic.Visible = false;
                    ddlReportType.Visible = false;
                    lbservieType.Visible = false;
                    Time_Row.Visible = false;
                    DateDiv.Visible = false;
                }
                if (this.PageTitle == "MER")
                {
                    string x = "Medicine Expiry Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr1MedicalSubsidy.Visible = false;
                    dpROw.Visible = false;
                    lblMultiSelect.Visible = false;
                    tr_Export.Visible = true;
                    trDoctor.Visible = false;
                    tr_Summary.Visible = false;
                    Time_Row.Visible = true;  // could be problematic
                    DateDiv.Visible = true;
                    trSearch1.Visible = true;

                    op_FilterClinic.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;

                    trSearch1.Visible = true;
                    dpROw.Visible = true;

                    lblDepartment.Text = "Vendor";
                    DataTable dtPanel = DBClass.getDataTable("select Vendor_ID,Vendor_Name from AP_Vendors where IsActive=1");
                    ddlDepartments.DataSource = dtPanel;
                    ddlDepartments.DataTextField = "Vendor_Name";
                    ddlDepartments.DataValueField = "Vendor_ID";
                    ddlDepartments.Items.Clear();
                    ddlDepartments.Items.Add(new ListItem("Please Select", "0"));
                    ddlDepartments.DataBind();


                    //ADDING NEW WAREHOUSE

                    object valuset;
                    ddlwareHouse.DataSource = GetUserWarehouses();
                    ddlwareHouse.DataTextField = "Text";
                    ddlwareHouse.DataValueField = "Value";
                    ddlwareHouse.Items.Clear();
                    ddlwareHouse.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlwareHouse.DataBind();
                    Stock_Movement.Visible = true;


                    ddlwareHouse.Visible = true;
                    lblWarehouse.Visible = true;

                    lbItemCategory.Visible = false;
                    ddlItemCategory.Visible = false;

                    DataBaseDataContext dbs = new DataBaseDataContext(DBClass.ConnectionString());
                    var serviceList = (from sl in dbs.INV_Items
                                       where sl.Active == true
                                       select new { sl.Item_ID, sl.Description }).ToList();

                    ddlItemName.DataSource = serviceList;
                    ddlItemName.DataValueField = "Item_ID";
                    ddlItemName.DataTextField = "Description";
                    ddlItemName.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlItemName.DataBind();


                }
                if (this.PageTitle == "CathLab_MER")
                {
                    string x = "Cath Lab Medicine Expiry Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr1MedicalSubsidy.Visible = false;
                    dpROw.Visible = false;
                    lblMultiSelect.Visible = false;
                    tr_Export.Visible = true;
                    trDoctor.Visible = false;
                    tr_Summary.Visible = false;
                    Time_Row.Visible = true;  // could be problematic
                    DateDiv.Visible = true;
                    trSearch1.Visible = true;

                    op_FilterClinic.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;

                    trSearch1.Visible = true;
                    dpROw.Visible = true;

                    lblDepartment.Text = "Vendor";
                    DataTable dtPanel = DBClass.getDataTable("select Vendor_ID,Vendor_Name from AP_Vendors where IsActive=1");
                    ddlDepartments.DataSource = dtPanel;
                    ddlDepartments.DataTextField = "Vendor_Name";
                    ddlDepartments.DataValueField = "Vendor_ID";
                    ddlDepartments.Items.Clear();
                    ddlDepartments.Items.Add(new ListItem("Please Select", "0"));
                    ddlDepartments.DataBind();


                    //ADDING NEW WAREHOUSE

                    object valuset;
                    ddlwareHouse.DataSource = GetUserWarehouses();
                    ddlwareHouse.DataTextField = "Text";
                    ddlwareHouse.DataValueField = "Value";
                    ddlwareHouse.Items.Clear();
                    ddlwareHouse.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlwareHouse.DataBind();
                    Stock_Movement.Visible = true;


                    ddlwareHouse.Visible = true;
                    lblWarehouse.Visible = true;

                    lbItemCategory.Visible = false;
                    ddlItemCategory.Visible = false;

                    DataBaseDataContext dbs = new DataBaseDataContext(DBClass.ConnectionString());
                    var serviceList = (from sl in dbs.INV_Items
                                       where sl.Active == true
                                       select new { sl.Item_ID, sl.Description }).ToList();

                    ddlItemName.DataSource = serviceList;
                    ddlItemName.DataValueField = "Item_ID";
                    ddlItemName.DataTextField = "Description";
                    ddlItemName.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlItemName.DataBind();


                }
                if (this.PageTitle == "StockValuationReport")
                {
                    string x = "Stock Valuation Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr1MedicalSubsidy.Visible = false;
                    dpROw.Visible = true;
                    lblMultiSelect.Visible = false;
                    tr_Export.Visible = true;
                    trDoctor.Visible = false;
                    tr_Summary.Visible = false;
                    Time_Row.Visible = true;  // could be problematic
                    DateDiv.Visible = true;
                    trSearch1.Visible = true;

                    op_FilterClinic.Visible = false;
                    lblMultiSelect.Visible = false;

                    trSearch1.Visible = true;


                    lblDepartment.Text = "Vendor";
                    DataTable dtPanel = DBClass.getDataTable("select Vendor_ID,Vendor_Name from AP_Vendors where IsActive=1");
                    ddlDepartments.DataSource = dtPanel;
                    ddlDepartments.DataTextField = "Vendor_Name";
                    ddlDepartments.DataValueField = "Vendor_ID";
                    ddlDepartments.Items.Clear();
                    ddlDepartments.Items.Add(new ListItem("Please Select", "0"));
                    ddlDepartments.DataBind();


                    //ADDING NEW WAREHOUSE

                    object valuset;
                    ddlwareHouse.DataSource = GetUserWarehouses();
                    ddlwareHouse.DataTextField = "Text";
                    ddlwareHouse.DataValueField = "Value";
                    ddlwareHouse.Items.Clear();
                    ddlwareHouse.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlwareHouse.DataBind();
                    Stock_Movement.Visible = true;


                    ddlwareHouse.Visible = true;
                    lblWarehouse.Visible = true;

                    lbItemCategory.Visible = false;
                    ddlItemCategory.Visible = false;

                    object valusets;
                    lblPatientType.Text = "Item Group";
                    DataBaseDataContext dbase = new DataBaseDataContext(DBClass.ConnectionString());

                    valusets = (from p in dbase.DataValues where p.ValueSet_ID == 3166 select new { p.DataValue_Name, p.DataValue_Description }).ToList();
                    ddlPatientType.DataSource = valusets;
                    ddlPatientType.DataTextField = "DataValue_Description";
                    ddlPatientType.DataValueField = "DataValue_Name";
                    ddlPatientType.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlPatientType.DataBind();

                    lblPatientType.Visible = true;
                    ddlPatientType.Visible = true;


                    DataBaseDataContext dbs = new DataBaseDataContext(DBClass.ConnectionString());
                    var serviceList = (from sl in dbs.INV_Items
                                       where sl.Active == true
                                       select new { sl.Item_ID, sl.Description }).ToList();

                    ddlItemName.DataSource = serviceList;
                    ddlItemName.DataValueField = "Item_ID";
                    ddlItemName.DataTextField = "Description";
                    ddlItemName.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlItemName.DataBind();


                }
                if (this.PageTitle == "IGP_Report")
                {
                    string x = "Gate Pass Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr1MedicalSubsidy.Visible = false;
                    dpROw.Visible = true;
                    lblMultiSelect.Visible = false;
                    tr_Export.Visible = true;
                    trDoctor.Visible = false;
                    tr_Summary.Visible = false;
                    Time_Row.Visible = true;  // could be problematic
                    DateDiv.Visible = true;

                    op_FilterClinic.Visible = false;
                    lblMultiSelect.Visible = false;
                    trSearch1.Visible = true;



                    lblDepartment.Text = "Vendor";
                    DataTable dtPanel = DBClass.getDataTable("select Vendor_ID,Vendor_Name from AP_Vendors where IsActive=1");
                    ddlDepartments.DataSource = dtPanel;
                    ddlDepartments.DataTextField = "Vendor_Name";
                    ddlDepartments.DataValueField = "Vendor_ID";
                    ddlDepartments.Items.Clear();
                    ddlDepartments.Items.Add(new ListItem("Please Select", "0"));
                    ddlDepartments.DataBind();


                    //ADDING NEW WAREHOUSE

                    object valuset;
                    ddlwareHouse.DataSource = GetUserWarehouses();
                    ddlwareHouse.DataTextField = "Text";
                    ddlwareHouse.DataValueField = "Value";
                    ddlwareHouse.Items.Clear();
                    ddlwareHouse.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlwareHouse.DataBind();
                    Stock_Movement.Visible = true;


                    ddlwareHouse.Visible = true;
                    lblWarehouse.Visible = true;

                    lbItemCategory.Visible = false;
                    ddlItemCategory.Visible = false;

                    lblPatientType.Visible = false;
                    ddlPatientType.Visible = false;


                    DataBaseDataContext dbs = new DataBaseDataContext(DBClass.ConnectionString());
                    var serviceList = (from sl in dbs.INV_Items
                                       where sl.Active == true
                                       select new { sl.Item_ID, sl.Description }).ToList();

                    ddlItemName.DataSource = serviceList;
                    ddlItemName.DataValueField = "Item_ID";
                    ddlItemName.DataTextField = "Description";
                    ddlItemName.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlItemName.DataBind();

                }
                if (this.PageTitle == "Asset_Register_Report")
                {
                    string x = "Asset Register Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr1MedicalSubsidy.Visible = false;
                    dpROw.Visible = true;
                    lblMultiSelect.Visible = false;
                    tr_Export.Visible = true;
                    trDoctor.Visible = false;
                    tr_Summary.Visible = false;
                    Time_Row.Visible = true;  // could be problematic
                    DateDiv.Visible = true;
                    trSearch1.Visible = false;
                    trProcedure1.Visible = true;
                    op_FilterClinic.Visible = false;
                    lblMultiSelect.Visible = false;

                    lblDepartment.Text = "Department";
                    DataTable dtPanel = DBClass.getDataTable("select Datavalue_name,datavalue_description from datavalues where valueset_id = 18");
                    ddlDepartments.DataSource = dtPanel;
                    ddlDepartments.DataTextField = "datavalue_description";
                    ddlDepartments.DataValueField = "Datavalue_name";
                    ddlDepartments.Items.Clear();
                    ddlDepartments.Items.Add(new ListItem("All", "0"));
                    ddlDepartments.DataBind();

                    DataTable dbPanel = DBClass.getDataTable("select Asset_Category_Id, Asset_Cat_Name from Asset_Category");
                    ddlwareHouse.DataSource = dbPanel;
                    ddlwareHouse.DataTextField = "Asset_Cat_Name";
                    ddlwareHouse.DataValueField = "Asset_Category_Id";
                    ddlwareHouse.Items.Clear();
                    ddlwareHouse.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlwareHouse.DataBind();
                    Stock_Movement.Visible = true;

                    ddlwareHouse.Visible = true;
                    lblWarehouse.Visible = true;
                    lblWarehouse.Text = "Cateogory";

                    lbItemCategory.Visible = false;
                    ddlItemCategory.Visible = false;

                    lblPatientType.Visible = false;
                    ddlPatientType.Visible = false;

                    lbProcedure.Text = "Asset Name";
                    DataTable dsPanel = DBClass.getDataTable(
                    "SELECT asset_definition_id, " +
                    "ISNULL(item_serial, '') + ' - ' + ISNULL(item_description, '') AS item_display, " +
                    "item_serial " +
                    "FROM Asset_Definition " +
                    "ORDER BY item_serial");
                    ddlProcedure.DataSource = dsPanel;
                    ddlProcedure.DataTextField = "item_display";        // Shows: "ASDAS-FF-GF-MS-125 - MS Storage Rack"
                    ddlProcedure.DataValueField = "asset_definition_id"; // Passes asset_definition_id to backend
                    ddlProcedure.Items.Clear();
                    ddlProcedure.Items.Add(new ListItem() { Text = "Please Select", Value = "0" });
                    ddlProcedure.DataBind();

                }
                if (this.PageTitle == "Asset_Ageing_Report")
                {
                    string x = "Asset Register Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr1MedicalSubsidy.Visible = false;
                    dpROw.Visible = true;
                    lblMultiSelect.Visible = false;
                    tr_Export.Visible = true;
                    trDoctor.Visible = false;
                    tr_Summary.Visible = false;
                    Time_Row.Visible = true;  // could be problematic
                    DateDiv.Visible = true;
                    trSearch1.Visible = false;
                    trProcedure1.Visible = true;
                    op_FilterClinic.Visible = false;
                    lblMultiSelect.Visible = false;

                    lblDepartment.Text = "Status";

                    ddlDepartments.Items.Clear();
                    ddlDepartments.Items.Add(new ListItem() { Text = "All ", Value = "All" });
                    ddlDepartments.Items.Add(new ListItem() { Text = "No Life Data", Value = "No Life Data" });
                    ddlDepartments.Items.Add(new ListItem() { Text = "Fully Depreciated", Value = "Fully Depreciated" });
                    ddlDepartments.Items.Add(new ListItem() { Text = "Near End-of-Life", Value = "Near End-of-Life" });
                    ddlDepartments.Items.Add(new ListItem() { Text = "Old", Value = "Old" });
                    ddlDepartments.Items.Add(new ListItem() { Text = "Active", Value = "Active" });
                    ddlDepartments.DataBind();


                    DataTable dbPanel = DBClass.getDataTable("select Asset_Category_Id, Asset_Cat_Name from Asset_Category");
                    ddlwareHouse.DataSource = dbPanel;
                    ddlwareHouse.DataTextField = "Asset_Cat_Name";
                    ddlwareHouse.DataValueField = "Asset_Category_Id";
                    ddlwareHouse.Items.Clear();
                    ddlwareHouse.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlwareHouse.DataBind();
                    Stock_Movement.Visible = true;

                    ddlwareHouse.Visible = true;
                    lblWarehouse.Visible = true;
                    lblWarehouse.Text = "Cateogory";

                    lbItemCategory.Visible = false;
                    ddlItemCategory.Visible = false;

                    lblPatientType.Visible = false;
                    ddlPatientType.Visible = false;

                    lbProcedure.Text = "Asset Name";
                    DataTable dsPanel = DBClass.getDataTable(
                    "SELECT asset_definition_id, " +
                    "ISNULL(item_serial, '') + ' - ' + ISNULL(item_description, '') AS item_display, " +
                    "item_serial " +
                    "FROM Asset_Definition " +
                    "ORDER BY item_serial");
                    ddlProcedure.DataSource = dsPanel;
                    ddlProcedure.DataTextField = "item_display";        // Shows: "ASDAS-FF-GF-MS-125 - MS Storage Rack"
                    ddlProcedure.DataValueField = "asset_definition_id"; // Passes asset_definition_id to backend
                    ddlProcedure.Items.Clear();
                    ddlProcedure.Items.Add(new ListItem() { Text = "Please Select", Value = "0" });
                    ddlProcedure.DataBind();

                }
                if (this.PageTitle == "Asset_Depreciation_Report")
                {
                    string x = "Asset Depreciation Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr1MedicalSubsidy.Visible = false;
                    dpROw.Visible = false;
                    lblMultiSelect.Visible = false;
                    tr_Export.Visible = true;
                    trDoctor.Visible = false;
                    tr_Summary.Visible = false;
                    Time_Row.Visible = true;  // could be problematic
                    DateDiv.Visible = true;
                    trSearch1.Visible = false;
                    trProcedure1.Visible = true;
                    op_FilterClinic.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlDepartments.Visible = false;
                    lblDepartment.Visible = false;

                    //lblDepartment.Text = "Department";
                    //DataTable dtPanel = DBClass.getDataTable("select Datavalue_name,datavalue_description from datavalues where valueset_id = 18");
                    //ddlDepartments.DataSource = dtPanel;
                    //ddlDepartments.DataTextField = "datavalue_description";
                    //ddlDepartments.DataValueField = "Datavalue_name";
                    //ddlDepartments.Items.Clear();
                    //ddlDepartments.Items.Add(new ListItem("All", "0"));
                    //ddlDepartments.DataBind();

                    DataTable dbPanel = DBClass.getDataTable("select Asset_Category_Id, Asset_Cat_Name from Asset_Category");
                    ddlwareHouse.DataSource = dbPanel;
                    ddlwareHouse.DataTextField = "Asset_Cat_Name";
                    ddlwareHouse.DataValueField = "Asset_Category_Id";
                    ddlwareHouse.Items.Clear();
                    ddlwareHouse.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlwareHouse.DataBind();
                    Stock_Movement.Visible = true;

                    ddlwareHouse.Visible = true;
                    lblWarehouse.Visible = true;
                    lblWarehouse.Text = "Cateogory";

                    lbItemCategory.Visible = false;
                    ddlItemCategory.Visible = false;

                    lblPatientType.Visible = false;
                    ddlPatientType.Visible = false;

                    lbProcedure.Text = "Asset Name";
                    DataTable dsPanel = DBClass.getDataTable(
                    "SELECT asset_definition_id, " +
                    "ISNULL(item_serial, '') + ' - ' + ISNULL(item_description, '') AS item_display, " +
                    "item_serial " +
                    "FROM Asset_Definition " +
                    "ORDER BY item_serial");
                    ddlProcedure.DataSource = dsPanel;
                    ddlProcedure.DataTextField = "item_display";        // Shows: "ASDAS-FF-GF-MS-125 - MS Storage Rack"
                    ddlProcedure.DataValueField = "asset_definition_id"; // Passes asset_definition_id to backend
                    ddlProcedure.Items.Clear();
                    ddlProcedure.Items.Add(new ListItem() { Text = "Please Select", Value = "0" });
                    ddlProcedure.DataBind();

                }
                if (this.PageTitle == "Asset_Acquisition_Report")
                {
                    string x = "Asset Acquisition Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr1MedicalSubsidy.Visible = false;
                    dpROw.Visible = false;
                    lblMultiSelect.Visible = false;
                    tr_Export.Visible = true;
                    trDoctor.Visible = false;
                    tr_Summary.Visible = false;
                    Time_Row.Visible = true;  // could be problematic
                    DateDiv.Visible = true;
                    trSearch1.Visible = false;
                    trProcedure1.Visible = true;
                    op_FilterClinic.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlDepartments.Visible = false;
                    lblDepartment.Visible = false;

                    DataTable dbPanel = DBClass.getDataTable("select Asset_Category_Id, Asset_Cat_Name from Asset_Category");
                    ddlwareHouse.DataSource = dbPanel;
                    ddlwareHouse.DataTextField = "Asset_Cat_Name";
                    ddlwareHouse.DataValueField = "Asset_Category_Id";
                    ddlwareHouse.Items.Clear();
                    ddlwareHouse.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlwareHouse.DataBind();
                    Stock_Movement.Visible = true;

                    ddlwareHouse.Visible = true;
                    lblWarehouse.Visible = true;
                    lblWarehouse.Text = "Cateogory";

                    lbItemCategory.Visible = false;
                    ddlItemCategory.Visible = false;

                    lblPatientType.Visible = false;
                    ddlPatientType.Visible = false;

                    lbProcedure.Text = "Asset Name";
                    DataTable dsPanel = DBClass.getDataTable(
                    "SELECT asset_definition_id, " +
                    "ISNULL(item_serial, '') + ' - ' + ISNULL(item_description, '') AS item_display, " +
                    "item_serial " +
                    "FROM Asset_Definition " +
                    "ORDER BY item_serial");
                    ddlProcedure.DataSource = dsPanel;
                    ddlProcedure.DataTextField = "item_display";
                    ddlProcedure.DataValueField = "asset_definition_id";
                    ddlProcedure.Items.Clear();
                    ddlProcedure.Items.Add(new ListItem() { Text = "Please Select", Value = "0" });
                    ddlProcedure.DataBind();

                }
                if (this.PageTitle == "Stock_Transfer_Report")
                {
                    string x = "Stock Transfer Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr1MedicalSubsidy.Visible = false;
                    optRw.Visible = true;
                    lblMultiSelect.Visible = false;
                    tr_Export.Visible = true;
                    trDoctor.Visible = false;
                    tr_Summary.Visible = false;
                    Time_Row.Visible = true;  // could be problematic
                    DateDiv.Visible = true;

                    op_FilterClinic.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlShift.Visible = false;
                    lbShift.Visible = false;

                    trSearch1.Visible = true;


                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    object valusetss = from d in db.aspnet_Users
                                       select new { d.UserName, d.UserId };
                    ddloprators.DataSource = valusetss;
                    ddloprators.DataTextField = "UserName";
                    ddloprators.DataValueField = "UserId";
                    ddloprators.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddloprators.DataBind();

                    trProcedure1.Visible = false;
                    ddlProcedure.Visible = false;


                    // ✅ ADD THIS CODE TO POPULATE ITEM DROPDOWN:
                    td11.Text = "Item Name";
                    td11.Visible = true;
                    ddlItemName.Visible = true;

                    DataBaseDataContext dbs = new DataBaseDataContext(DBClass.ConnectionString());
                    var serviceList = (from sl in dbs.INV_Items
                                       where sl.Active == true
                                       select new { sl.Item_ID, sl.Description }).ToList();

                    ddlItemName.DataSource = serviceList;
                    ddlItemName.DataValueField = "Item_ID";
                    ddlItemName.DataTextField = "Description";
                    ddlItemName.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlItemName.DataBind();

                    //ADDING NEW WAREHOUSE

                    object valuset;
                    ddlwareHouse.DataSource = GetUserWarehouses();
                    ddlwareHouse.DataTextField = "Text";
                    ddlwareHouse.DataValueField = "Value";
                    ddlwareHouse.Items.Clear();
                    ddlwareHouse.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlwareHouse.DataBind();
                    Stock_Movement.Visible = true;


                    ddlwareHouse.Visible = true;
                    lblWarehouse.Text = "From Warehouse";

                    lbItemCategory.Text = "To Warehouse";
                    //ADDING NEW WAREHOUSE

                    object valusetz;
                    ddlItemCategory.DataSource = GetUserWarehouses();
                    ddlItemCategory.DataTextField = "Text";
                    ddlItemCategory.DataValueField = "Value";
                    ddlItemCategory.Items.Clear();
                    ddlItemCategory.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlItemCategory.DataBind();

                }
                if (this.PageTitle == "PurchaseReturnReport")
                {
                    string x = "Purchase Return Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr1MedicalSubsidy.Visible = false;
                    dpROw.Visible = true;
                    lblMultiSelect.Visible = false;
                    tr_Export.Visible = true;
                    trDoctor.Visible = false;
                    tr_Summary.Visible = false;
                    Time_Row.Visible = true;  // could be problematic
                    DateDiv.Visible = true;
                    trSearch1.Visible = true;

                    op_FilterClinic.Visible = false;
                    lblMultiSelect.Visible = false;

                    trSearch1.Visible = true;


                    lblDepartment.Text = "Vendor";
                    DataTable dtPanel = DBClass.getDataTable("select Vendor_ID,Vendor_Name from AP_Vendors where IsActive=1");
                    ddlDepartments.DataSource = dtPanel;
                    ddlDepartments.DataTextField = "Vendor_Name";
                    ddlDepartments.DataValueField = "Vendor_ID";
                    ddlDepartments.Items.Clear();
                    ddlDepartments.Items.Add(new ListItem("Please Select", "0"));
                    ddlDepartments.DataBind();
                    lblPatientType.Visible = false;
                    ddlPatientType.Visible = false;
                    lblMultiSelect.Visible = false;

                    //ADDING NEW WAREHOUSE

                    object valuset;
                    ddlwareHouse.DataSource = GetUserWarehouses();
                    ddlwareHouse.DataTextField = "Text";
                    ddlwareHouse.DataValueField = "Value";
                    ddlwareHouse.Items.Clear();
                    ddlwareHouse.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlwareHouse.DataBind();
                    Stock_Movement.Visible = true;


                    ddlwareHouse.Visible = true;
                    lblWarehouse.Visible = true;

                    lbItemCategory.Visible = false;
                    ddlItemCategory.Visible = false;

                    DataBaseDataContext dbs = new DataBaseDataContext(DBClass.ConnectionString());
                    var serviceList = (from sl in dbs.INV_Items
                                       where sl.Active == true
                                       select new { sl.Item_ID, sl.Description }).ToList();

                    ddlItemName.DataSource = serviceList;
                    ddlItemName.DataValueField = "Item_ID";
                    ddlItemName.DataTextField = "Description";
                    ddlItemName.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlItemName.DataBind();
                }
                #endregion
                #region General Patient Modules
                else if (this.PageTitle == "TotalOpdDischargeReport")
                {
                    string x = "OPD Discharge Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    DateDiv.Visible = true;
                    tr_Export.Visible = true;
                    tr_Summary.Visible = false;
                    lblMainDepartment.Visible = false;
                    dpROw.Visible = false;
                    AllowPatientRecord = false;
                    Time_Row.Visible = false;
                    lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                }
                //Total Patients and Revisit Patients
                else if (this.PageTitle == "TotalpatientsandRevisitpatientsreport")
                {
                    string x = "Total Patients & Revisit Patients Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    dpROw.Visible = false;
                    tr1MedicalSubsidy.Visible = false;
                    lblMultiSelect.Visible = false;
                    lblPatientType.Visible = false;
                    Time_Row.Visible = false;
                    tr_Summary.Visible = false;
                    optRw.Visible = false;
                    AllowPatientRecord = false;
                    tr_Export.Visible = false;
                    DateDiv.Visible = true;
                    ddlMedicalSubsidy.Items.Clear();

                }
                //Total Patients Register
                else if (this.PageTitle == "TotalPatientRegsreport")
                {
                    string x = "Total Patient Reg Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr_Export.Visible = true;
                    tr_Summary.Visible = false;
                    lblMainDepartment.Visible = false;
                    dpROw.Visible = false;
                    AllowPatientRecord = false;
                    Time_Row.Visible = true;
                    DateDiv.Visible = true;
                    lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                }
                else if (this.PageTitle == "Lab_Test_Detail")
                {
                    string x = "Lab Test Detail";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    dpROw.Visible = true;
                    lblDepartment.Visible = true;
                    ddlDepartments.Visible = true;
                    tr_Summary.Visible = true;
                    tr_Export.Visible = true;
                    AllowPatientRecord = true;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    lblMultiSelect.Visible = false;
                    DataTable Tests = DBClass.getDataTable("select Test_ID,Test_Name from Lab_Tests");
                    DataTable TestCategories = (DataTable)DBClass.getDataTable("select dv.DataValue_Name,dv.DataValue_Description from ValueSet vs,DataValues dv where vs.ValueSet_ID=dv.ValueSet_ID and vs.ValueSet_Name='Test Groups'");

                    foreach (DataRow dr in TestCategories.Rows)
                    {
                        DataRow newdr = Tests.NewRow();
                        newdr["Test_ID"] = dr["DataValue_Name"].ToString();
                        newdr["Test_Name"] = dr["DataValue_Description"].ToString();
                        Tests.Rows.Add(newdr);
                        Tests.AcceptChanges();
                    }
                    trTestResult1.Visible = true;
                    ddlTestName.DataSource = Tests;
                    ddlTestName.DataTextField = "Test_Name";
                    ddlTestName.DataValueField = "Test_ID";
                    ddlTestName.Items.Add(new ListItem() { Text = "All", Value = "All" });
                    ddlTestName.DataBind();

                    object valusets;
                    valusets = DBClass.GetValueSet("Patient Type");
                    ddlPatientType.DataSource = valusets;
                    ddlPatientType.DataTextField = "DataValue_Description";
                    ddlPatientType.DataValueField = "DataValue_Name";
                    ddlPatientType.Items.Add(new ListItem() { Text = "All", Value = "All" });
                    ddlPatientType.DataBind();
                    SetDepartent();

                    optRw.Visible = true;
                    ddlShift.Visible = false;
                    lbShift.Visible = false;
                    object valusetss;
                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    valusetss = from d in db.aspnet_Users
                                select new { d.UserName, d.UserId };
                    ddloprators.DataSource = valusetss;
                    ddloprators.DataTextField = "UserName";
                    ddloprators.DataValueField = "UserId";
                    ddloprators.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddloprators.DataBind();

                }
                //else if (this.PageTitle == "RadiologyReport")
                //{
                //    string x = "Radiology Report";
                //    Master.Label2.Text = x;
                //    Master.GetMenuName();
                //    lblDepartment.Visible = false;
                //    tr_Summary.Visible = false;
                //    DateDiv.Visible = true;
                //    Time_Row.Visible = true;
                //    lblMultiSelect.Visible = false;

                //    optRw.Visible = false;

                //    lboperator.Visible = true;
                //    ddloprators.Visible = true; 

                //    MainDeptDiv.Visible = true;
                //    lblMainDepartment.Visible = true;
                //    lblMainDepartment.Text = "Radiology Name";
                //    ddlMainDepartment.Visible = true;
                //    ddlMainDepartment.Items.Clear();
                //    ddlMainDepartment.Items.Add(new ListItem() { Text = "All", Value = "0" });
                //    ddlMainDepartment.Items.Add(new ListItem() { Text = "Ultrasound", Value = "002" });
                //    ddlMainDepartment.Items.Add(new ListItem() { Text = "X-Ray", Value = "003" });
                //    ddlMainDepartment.DataBind();


                //    DataTable Tests = DBClass.getDataTable("select Test_ID,Test_Name from Lab_Tests where main_department in ('002','003')");
                //    DataTable TestCategories = (DataTable)DBClass.getDataTable("select dv.DataValue_Name,dv.DataValue_Description from ValueSet vs,DataValues dv where vs.ValueSet_ID=dv.ValueSet_ID and vs.ValueSet_Name='Test Groups'");

                //    foreach (DataRow dr in TestCategories.Rows)
                //    {
                //        DataRow newdr = Tests.NewRow();
                //        newdr["Test_ID"] = dr["DataValue_Name"].ToString();
                //        newdr["Test_Name"] = dr["DataValue_Description"].ToString();
                //        Tests.Rows.Add(newdr);
                //        Tests.AcceptChanges();
                //    }
                //    trTestResult1.Visible = true;
                //    ddlTestName.DataSource = Tests;
                //    ddlTestName.DataTextField = "Test_Name";
                //    ddlTestName.DataValueField = "Test_ID";
                //    ddlTestName.Items.Add(new ListItem() { Text = "All", Value = "All" });
                //    ddlTestName.DataBind();

                //    ddlPatientType.Visible = true;
                //    object valusets;
                //    valusets = DBClass.GetValueSet("Patient Type");
                //    ddlPatientType.DataSource = valusets;
                //    ddlPatientType.DataTextField = "DataValue_Description";
                //    ddlPatientType.DataValueField = "DataValue_Name";
                //    ddlPatientType.Items.Add(new ListItem() { Text = "All", Value = "0" });
                //    ddlPatientType.DataBind();
                //    SetDepartent();


                //    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                //    valusets = from d in db.aspnet_Users
                //               select new { d.UserName, d.UserId };
                //    ddloprators.DataSource = valusets;
                //    ddloprators.DataTextField = "UserName";
                //    ddloprators.DataValueField = "UserId";
                //    ddloprators.Items.Add(new ListItem() { Text = "All", Value = "0" });
                //    ddloprators.DataBind();


                //    ddlDepartments.Visible = false;
                //    lbShift.Visible = false;
                //    ddlShift.Visible = false;


                //}           // latest insert 
                else if (this.PageTitle == "Lab_Test_Wise_Summary")
                {
                    string x = "Lab Test Wise Summary";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    dpROw.Visible = true;
                    lblDepartment.Visible = true;
                    ddlDepartments.Visible = true;
                    tr_Summary.Visible = true;
                    tr_Export.Visible = true;
                    AllowPatientRecord = true;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    lblMultiSelect.Visible = false;
                    DataTable Tests = DBClass.getDataTable("select Test_ID,Test_Name from Lab_Tests");
                    DataTable TestCategories = (DataTable)DBClass.getDataTable("select dv.DataValue_Name,dv.DataValue_Description from ValueSet vs,DataValues dv where vs.ValueSet_ID=dv.ValueSet_ID and vs.ValueSet_Name='Test Groups'");

                    foreach (DataRow dr in TestCategories.Rows)
                    {
                        DataRow newdr = Tests.NewRow();
                        newdr["Test_ID"] = dr["DataValue_Name"].ToString();
                        newdr["Test_Name"] = dr["DataValue_Description"].ToString();
                        Tests.Rows.Add(newdr);
                        Tests.AcceptChanges();
                    }
                    trTestResult1.Visible = true;
                    ddlTestName.DataSource = Tests;
                    ddlTestName.DataTextField = "Test_Name";
                    ddlTestName.DataValueField = "Test_ID";
                    ddlTestName.Items.Add(new ListItem() { Text = "All", Value = "All" });
                    ddlTestName.DataBind();

                    object valusets;
                    valusets = DBClass.GetValueSet("Patient Type");
                    ddlPatientType.DataSource = valusets;
                    ddlPatientType.DataTextField = "DataValue_Description";
                    ddlPatientType.DataValueField = "DataValue_Name";
                    ddlPatientType.Items.Add(new ListItem() { Text = "All", Value = "All" });
                    ddlPatientType.DataBind();
                    SetDepartent();

                }
                else if (this.PageTitle == "Patient_Wise_Lab_Test_Summary")
                {
                    string x = "Patient Wise Lab Test Summary";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    dpROw.Visible = true;
                    MRDiv.Visible = true;
                    lblMRNo.Visible = true;
                    txtMRNo.Visible = true;
                    ddlPatientType.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    lblDepartment.Visible = true;
                    ddlDepartments.Visible = true;
                    tr_Export.Visible = true;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    DataTable Tests = DBClass.getDataTable("select Test_ID,Test_Name from Lab_Tests");
                    DataTable TestCategories = (DataTable)DBClass.getDataTable("select dv.DataValue_Name,dv.DataValue_Description from ValueSet vs,DataValues dv where vs.ValueSet_ID=dv.ValueSet_ID and vs.ValueSet_Name='Test Groups'");

                    foreach (DataRow dr in TestCategories.Rows)
                    {
                        DataRow newdr = Tests.NewRow();
                        newdr["Test_ID"] = dr["DataValue_Name"].ToString();
                        newdr["Test_Name"] = dr["DataValue_Description"].ToString();
                        Tests.Rows.Add(newdr);
                        Tests.AcceptChanges();
                    }
                    trTestResult1.Visible = true;
                    ddlTestName.DataSource = Tests;
                    ddlTestName.DataTextField = "Test_Name";
                    ddlTestName.DataValueField = "Test_ID";
                    ddlTestName.Items.Add(new ListItem() { Text = "All", Value = "All" });
                    ddlTestName.DataBind();

                    SetDepartent();

                }
                else if (this.PageTitle == "Radiology_Test_Wise_Summary")
                {
                    string x = "Radiology Test Wise Summary";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    dpROw.Visible = false;

                    tr_Summary.Visible = true;
                    tr_Export.Visible = true;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;

                    MainDeptDiv.Visible = true;
                    lblMainDepartment.Visible = true;
                    lblMainDepartment.Text = "Radiology Name";
                    ddlMainDepartment.Visible = true;
                    ddlMainDepartment.Items.Clear();
                    object valuset;
                    valuset = DBClass.GetValueSet("Main Test Departments");
                    ddlMainDepartment.DataSource = valuset;
                    ddlMainDepartment.DataTextField = "DataValue_Description";
                    ddlMainDepartment.DataValueField = "DataValue_Name";
                    ddlMainDepartment.Items.Clear();
                    ddlMainDepartment.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlMainDepartment.DataBind();


                    DataTable Tests = DBClass.getDataTable("select Test_id ,Test_Name from Lab_Tests where main_department in ('003')");
                    DataTable TestCategories = (DataTable)DBClass.getDataTable("select dv.DataValue_Name,dv.DataValue_Description from ValueSet vs,DataValues dv where vs.ValueSet_ID=dv.ValueSet_ID and vs.ValueSet_Name='Test Groups'");

                    foreach (DataRow dr in TestCategories.Rows)
                    {
                        DataRow newdr = Tests.NewRow();
                        newdr["Test_ID"] = dr["DataValue_Name"].ToString();
                        newdr["Test_Name"] = dr["DataValue_Description"].ToString();
                        Tests.Rows.Add(newdr);
                        Tests.AcceptChanges();
                    }
                    trTestResult1.Visible = true;
                    ddlTestName.DataSource = Tests;
                    ddlTestName.DataTextField = "Test_Name";
                    ddlTestName.DataValueField = "Test_Name";
                    ddlTestName.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlTestName.DataBind();




                    lblMultiSelect.Visible = false;
                    //ddlPatientType.Visible = true;
                    //lblPatientType.Visible = true;
                    //object valusets;
                    //valusets = DBClass.GetValueSet("Patient Type");
                    //ddlPatientType.DataSource = valusets;
                    //ddlPatientType.DataTextField = "DataValue_Description";
                    //ddlPatientType.DataValueField = "DataValue_Name";
                    //ddlPatientType.Items.Add(new ListItem() { Text = "All", Value = "All" });
                    //ddlPatientType.DataBind();

                }
                else if (this.PageTitle == "Lab_Test_Patient_Wise")
                {
                    string x = "Patients Test Detail";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    dpROw.Visible = true;
                    lblDepartment.Visible = true;
                    ddlDepartments.Visible = true;
                    ddlPatientType.Visible = false;
                    lblPatientType.Visible = false;
                    tr_Summary.Visible = true;
                    tr_Export.Visible = true;
                    AllowPatientRecord = true;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    lblMultiSelect.Visible = false;
                    DataTable Tests = DBClass.getDataTable("select Test_ID,Test_Name from Lab_Tests");
                    DataTable TestCategories = (DataTable)DBClass.getDataTable("select dv.DataValue_Name,dv.DataValue_Description from ValueSet vs,DataValues dv where vs.ValueSet_ID=dv.ValueSet_ID and vs.ValueSet_Name='Test Groups'");

                    foreach (DataRow dr in TestCategories.Rows)
                    {
                        DataRow newdr = Tests.NewRow();
                        newdr["Test_ID"] = dr["DataValue_Name"].ToString();
                        newdr["Test_Name"] = dr["DataValue_Description"].ToString();
                        Tests.Rows.Add(newdr);
                        Tests.AcceptChanges();
                    }
                    trTestResult1.Visible = true;
                    ddlTestName.DataSource = Tests;
                    ddlTestName.DataTextField = "Test_Name";
                    ddlTestName.DataValueField = "Test_ID";
                    ddlTestName.Items.Add(new ListItem() { Text = "All", Value = "All" });
                    ddlTestName.DataBind();

                    object valusets;
                    valusets = DBClass.GetValueSet("Patient Type");
                    ddlPatientType.DataSource = valusets;
                    ddlPatientType.DataTextField = "DataValue_Description";
                    ddlPatientType.DataValueField = "DataValue_Name";
                    ddlPatientType.Items.Add(new ListItem() { Text = "All", Value = "All" });
                    ddlPatientType.DataBind();
                    SetDepartent();

                }
                //else if (this.PageTitle == "PharmacySaleReport")
                //{
                //    string x = "Pharmacy Sale Report";
                //    Master.Label2.Text = x;
                //    Master.GetMenuName();
                //    lblMainDepartment.Visible = false;
                //    ddlDepartments.Visible = false;
                //    lblPatientType.Visible = false;
                //    lblMultiSelect.Visible = false;
                //    ddlPatientType.Visible = false;
                //    optRw.Visible = false;
                //    trDoctor.Visible = false;
                //    tr_Summary.Visible = true;
                //    trSearch1.Visible = true;
                //    lblMainDepartment.Visible = false;
                //    dpROw.Visible = false;
                //    ddlReportType.Visible = false;
                //    txtMRNo.Visible = false;
                //    lblMRNo.Visible = false;
                //    tr_Export.Visible = false;
                //    ddlShift.Visible = false;
                //    lbShift.Visible = false;
                //    DateDiv.Visible = true;
                //    Time_Row.Visible = true;
                //    if (AllowPatientRecord)
                //    {
                //        optRw.Visible = true;
                //        DataTable dt1 = DBClass.getDataTable("select * from Pharmacy_Users where isActive=1");
                //        ddloprators.DataSource = dt1;
                //        ddloprators.DataTextField = "UserName";
                //        ddloprators.DataValueField = "UserID";
                //        ddloprators.Items.Add(new ListItem() { Text = "All", Value = "0" });
                //        ddloprators.DataBind();
                //    }
                //}
                else if (this.PageTitle == "Dischare_Revd")
                {
                    string x = "Discharge Received Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    trDoctor.Visible = true;
                    tr1MedicalSubsidy.Visible = false;
                    dpROw.Visible = false;
                    lbservieType.Visible = false;
                    ddlReportType.Visible = false;
                    lboperator.Visible = true;
                    ddloprators.Visible = true;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    DataTable dt = DBClass.getDataTable("select * from HR_Employees where IsDoctor=1");
                    ddlDoctor.DataSource = dt;
                    ddlDoctor.DataValueField = "Emp_ID";
                    ddlDoctor.DataTextField = "Emp_Name";
                    ddlDoctor.Items.Add(new ListItem() { Value = "0", Text = "All Doctors" });
                    ddlDoctor.DataBind();
                    DataTable shift = DBClass.getDataTable("select * from HR_Shifts");
                    ddlShift.DataSource = shift;
                    ddlShift.DataValueField = "Shift_ID";
                    ddlShift.DataTextField = "Shift_Name";
                    ddlShift.Items.Add(new ListItem() { Value = "0", Text = "All" });
                    ddlShift.DataBind();


                    tr_Summary.Visible = false;
                    AllowPatientRecord = false;
                    optRw.Visible = true;
                    lboperator.Text = "Procedures";
                    object valusets;
                    valusets = DBClass.GetValueSet("IPD Procedures");
                    ddloprators.DataSource = valusets;
                    ddloprators.DataTextField = "DataValue_Description";
                    ddloprators.DataValueField = "DataValue_Name";
                    ddloprators.Items.Add(new ListItem() { Text = "Please Select", Value = "0" });
                    ddloprators.DataBind();





                }
                #endregion
                #region Inventory Modules Report Menus
                else if (this.PageTitle == "STM")
                {
                    string x = "Stock Balance Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    object valuset;
                    ddlwareHouse.DataSource = GetUserWarehouses();
                    ddlwareHouse.DataTextField = "Text";
                    ddlwareHouse.DataValueField = "Value";
                    ddlwareHouse.Items.Clear();
                    ddlwareHouse.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlwareHouse.DataBind();
                    Stock_Movement.Visible = true;
                    tr_Summary.Visible = false;

                    DataBaseDataContext dbd = new DataBaseDataContext(DBClass.ConnectionString());
                    valuset = (from p in dbd.Account_Categories
                               select new
                               {
                                   p.Account_Category_Id,
                                   p.CategoryName
                               }).ToList();
                    ddlItemCategory.DataSource = valuset;
                    ddlItemCategory.Items.Clear();
                    ddlItemCategory.DataTextField = "CategoryName";
                    ddlItemCategory.DataValueField = "Account_Category_Id";
                    ddlItemCategory.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlItemCategory.DataBind();
                    ddlItemCategory.Visible = true;
                    ddlMainDepartment.Visible = false;
                    lblMainDepartment.Visible = false;
                    Time_Row.Visible = false;
                    dpROw.Visible = false;
                    lblMultiSelect.Visible = false;
                    trDoctor.Visible = false;
                    tr_Export.Visible = true;
                    DateDiv.Visible = true;
                    sttDate.Text = "End Date";
                    txtStart_Date.Visible = true;
                    endDate.Visible = false;
                    txtEnd_Date.Visible = false;
                }
                else if (this.PageTitle == "IWPOS")
                {
                    string x = "Inventory Wise Purchase Order Summary Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    ddlPatientType.Visible = false;
                    tr_Summary.Visible = false;

                    lblMultiSelect.Visible = false;
                    lblMedical.Text = "Item Group";
                    tr1MedicalSubsidy.Visible = true;
                    lblPatientType.Visible = true;
                    lblTestName.Visible = true;
                    lblTestName.Text = "Vendor Name";
                    ddlDepartments.Visible = false;
                    ddlTestName.Visible = true;
                    lblMainDepartment.Visible = true;
                    lblMainDepartment.Text = "Items";
                    ddlMainDepartment.Visible = true;
                    tr_Export.Visible = false;

                    object valusets;
                    DataBaseDataContext dbd = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = from d in dbd.INV_Items
                               where d.Item_Type == "001"
                               select new { d.Item_Code, d.Description, Complete = d.Item_Code + '-' + d.Description };
                    ddlMainDepartment.DataSource = valusets;
                    ddlMainDepartment.Items.Clear();
                    ddlMainDepartment.DataTextField = "Description";
                    ddlMainDepartment.DataValueField = "Item_Code";
                    ddlMainDepartment.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlMainDepartment.DataBind();

                    optRw.Visible = false;
                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = from d in db.AP_Vendors
                               select new { d.Vendor_ID, d.Vendor_Name, Complete = d.Vendor_ID + '-' + d.Vendor_Name };
                    ddlTestName.DataSource = valusets;

                    ddlTestName.DataTextField = "Vendor_Name";
                    ddlTestName.DataValueField = "Vendor_ID";
                    ddlTestName.Items.Clear();
                    ddlTestName.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlTestName.DataBind();
                    valusets = DBClass.GetValueSet("Item Group");
                    ddlMedicalSubsidy.DataSource = valusets;
                    ddlMedicalSubsidy.DataTextField = "DataValue_Description";
                    ddlMedicalSubsidy.DataValueField = "DataValue_Name";
                    ddlMedicalSubsidy.Items.Clear();
                    ddlMedicalSubsidy.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlMedicalSubsidy.DataBind();
                    AllowPatientRecord = false;
                    dpROw.Visible = false;
                    Time_Row.Visible = false;
                    tr_Export.Visible = false;

                }
                else if (this.PageTitle == "GRN_and_Item_Wise_Report")
                {
                    string x = "GRN And Item Wise Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    ddlDepartments.Visible = true;
                    dpROw.Visible = true;
                    tr1MedicalSubsidy.Visible = false;
                    lblMultiSelect.Visible = false;
                    lblPatientType.Visible = false;
                    DateDiv.Visible = false;
                    Time_Row.Visible = false;
                    tr_Summary.Visible = false;
                    optRw.Visible = false;
                    AllowPatientRecord = false;
                    ddlPatientType.Visible = false;
                    tr_Export.Visible = true;

                    object valusets;
                    DataBaseDataContext dbase = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = (from p in dbase.GRN_Masters select new { p.GRN_ID, p.GRN_Num }).ToList();
                    ddlDepartments.DataSource = valusets;
                    ddlDepartments.DataTextField = "GRN_Num";
                    ddlDepartments.DataValueField = "GRN_ID";
                    ddlDepartments.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlDepartments.DataBind();
                    ddlMedicalSubsidy.Items.Clear();
                }

                else if (PageTitle == "SIN_summary")
                {
                    string x = "SIN Summary Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    object valusets;
                    tr_Summary.Visible = false;
                    Time_Row.Visible = false;
                    dpROw.Visible = true;
                    lblMultiSelect.Visible = false;
                    lblMedical.Visible = false;
                    tr1MedicalSubsidy.Visible = false;
                    DateDiv.Visible = true;
                    trDoctor.Visible = false;
                    ddlwareHouse.DataSource = GetUserWarehouses();
                    ddlwareHouse.DataTextField = "Text";
                    ddlwareHouse.DataValueField = "Value";
                    ddlwareHouse.Items.Clear();
                    ddlwareHouse.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlwareHouse.DataBind();
                    DataBaseDataContext dbd = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = (from p in dbd.Account_Categories
                                select new
                                {
                                    p.Account_Category_Id,
                                    p.CategoryName
                                }).ToList();
                    ddlItemCategory.DataSource = valusets;
                    ddlItemCategory.Items.Clear();
                    ddlItemCategory.DataTextField = "CategoryName";
                    ddlItemCategory.DataValueField = "Account_Category_Id";
                    ddlItemCategory.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlItemCategory.DataBind();
                    ddlItemCategory.Visible = true;
                    Stock_Movement.Visible = true;
                    ddlwareHouse.Visible = true;
                    lblItemCode.Visible = false;
                    txtItemCode.Visible = false;
                    lbItemCategory.Text = "Item Category";
                    lblPatientType.Text = "Items";
                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    var serviceList = (from sl in db.INV_Items
                                       where sl.Active == true
                                           && sl.Services == false
                                       select new { sl.Item_ID, sl.Description }).ToList();

                    ddlPatientType.DataSource = serviceList;

                    ddlPatientType.DataValueField = "Item_ID";
                    ddlPatientType.DataTextField = "Description";
                    ddlPatientType.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlPatientType.DataBind();

                    DataBaseDataContext dbas = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = (from p in dbas.DataValues where p.ValueSet_ID == 18 select new { p.DataValue_Name, p.DataValue_Description }).ToList();
                    ddlDepartments.DataSource = valusets;
                    ddlDepartments.DataTextField = "DataValue_Description";
                    ddlDepartments.DataValueField = "DataValue_Name";
                    ddlDepartments.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlDepartments.DataBind();
                    tr_Export.Visible = true;
                }
                else if (PageTitle == "MSR")
                {
                    string x = "Minimum Stock Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    object valusets;
                    tr_Summary.Visible = false;
                    Time_Row.Visible = false;
                    dpROw.Visible = true;
                    lblMultiSelect.Visible = false;
                    lblMedical.Visible = false;
                    tr1MedicalSubsidy.Visible = false;
                    trDoctor.Visible = false;
                    ddlwareHouse.DataSource = GetUserWarehouses();
                    ddlwareHouse.DataTextField = "Text";
                    ddlwareHouse.DataValueField = "Value";
                    ddlwareHouse.Items.Clear();
                    ddlwareHouse.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlwareHouse.DataBind();
                    DataBaseDataContext dbd = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = (from p in dbd.Account_Categories
                                select new
                                {
                                    p.Account_Category_Id,
                                    p.CategoryName
                                }).ToList();
                    ddlItemCategory.DataSource = valusets;
                    ddlItemCategory.Items.Clear();
                    ddlItemCategory.DataTextField = "CategoryName";
                    ddlItemCategory.DataValueField = "Account_Category_Id";
                    ddlItemCategory.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlItemCategory.DataBind();
                    ddlItemCategory.Visible = true;
                    Stock_Movement.Visible = true;
                    ddlwareHouse.Visible = true;
                    DateDiv.Visible = false;
                    lblItemCode.Visible = false;
                    txtItemCode.Visible = false;
                    lbItemCategory.Text = "Item Category";
                    lblPatientType.Text = "Items";
                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    var serviceList = (from sl in db.INV_Items
                                       where sl.Active == true
                                           && sl.Services == false
                                       select new { sl.Item_ID, sl.Description }).ToList();

                    ddlwareHouse.DataSource = serviceList;

                    ddlwareHouse.DataValueField = "Item_ID";
                    ddlwareHouse.DataTextField = "Description";
                    ddlwareHouse.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlwareHouse.DataBind();
                    ddlwareHouse.Visible = true;
                    lblPatientType.Visible = false;
                    ddlPatientType.Visible = false;
                    DataBaseDataContext dbas = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = (from p in dbas.DataValues where p.ValueSet_ID == 18 select new { p.DataValue_Name, p.DataValue_Description }).ToList();
                    ddlDepartments.DataSource = valusets;
                    ddlDepartments.DataTextField = "DataValue_Description";
                    ddlDepartments.DataValueField = "DataValue_Name";
                    ddlDepartments.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlDepartments.DataBind();
                    ddlDepartments.Visible = false;
                    lblDepartment.Visible = false;
                    tr_Export.Visible = true;
                }
                else if (this.PageTitle == "MIR_summary")
                {
                    string x = "MIR Summary";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    object valusets;
                    tr_Summary.Visible = false;
                    tr_Export.Visible = true;
                    DateDiv.Visible = true;
                    Time_Row.Visible = false;
                    lblMultiSelect.Visible = false;
                    trDoctor.Visible = false;
                    AllowPatientRecord = false;
                    dpROw.Visible = true;
                    lblPatientType.Text = "Items";
                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    var serviceList = (from sl in db.INV_Items
                                       where
                                       sl.Active == true
                                       && sl.Item_Type == "001"
                                       && sl.Hospital_Services == false
                                       select new { sl.Item_ID, sl.Description }).ToList();

                    ddlPatientType.DataSource = serviceList;

                    ddlPatientType.DataValueField = "Item_ID";
                    ddlPatientType.DataTextField = "Description";
                    ddlPatientType.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlPatientType.DataBind();

                    DataBaseDataContext dbas = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = (from p in dbas.DataValues where p.ValueSet_ID == 18 select new { p.DataValue_Name, p.DataValue_Description }).ToList();
                    ddlDepartments.DataSource = valusets;
                    ddlDepartments.DataTextField = "DataValue_Description";
                    ddlDepartments.DataValueField = "DataValue_Name";
                    ddlDepartments.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlDepartments.DataBind();
                }
                #endregion
                #region Purchase
                else if (this.PageTitle == "VendorLedger")
                {
                    string x = "Vendor Ledger";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    object valusets;
                    tr_Summary.Visible = false;
                    tr_Export.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = false;
                    lblMultiSelect.Visible = false;
                    trDoctor.Visible = false;
                    AllowPatientRecord = false;
                    dpROw.Visible = true;
                    lblPatientType.Text = "Items";
                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    var serviceList = (from sl in db.INV_Items
                                       where
                                       sl.Active == true
                                       && sl.Hospital_Services == false
                                       && sl.Services == false
                                       select new { sl.Item_ID, sl.Description }).ToList();

                    ddlPatientType.DataSource = serviceList;

                    ddlPatientType.DataValueField = "Item_ID";
                    ddlPatientType.DataTextField = "Description";
                    ddlPatientType.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlPatientType.DataBind();
                    ddlPatientType.Visible = false;
                    lblPatientType.Visible = false;
                    lblDepartment.Text = "Vendor";
                    DataTable dtPanel = DBClass.getDataTable("select Vendor_ID,Vendor_Name from AP_Vendors where IsActive=1");
                    ddlDepartments.DataSource = dtPanel;
                    ddlDepartments.DataTextField = "Vendor_Name";
                    ddlDepartments.DataValueField = "Vendor_ID";
                    ddlDepartments.Items.Clear();
                    ddlDepartments.Items.Add(new ListItem("Please Select", "0"));
                    ddlDepartments.DataBind();
                }
                else if (this.PageTitle == "Vendor_Wise_Transaction_Detail")
                {
                    string x = "Vendor Wise Transaction Detail";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    object valusets;
                    tr_Summary.Visible = false;
                    tr_Export.Visible = true;
                    DateDiv.Visible = true;
                    Time_Row.Visible = false;
                    lblMultiSelect.Visible = false;
                    trDoctor.Visible = false;
                    AllowPatientRecord = false;
                    dpROw.Visible = true;
                    lblPatientType.Text = "Items";
                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    var serviceList = (from sl in db.INV_Items
                                       where
                                       sl.Active == true
                                       && sl.Hospital_Services == false
                                       && sl.Services == false
                                       select new { sl.Item_ID, sl.Description }).ToList();

                    ddlPatientType.DataSource = serviceList;

                    ddlPatientType.DataValueField = "Item_ID";
                    ddlPatientType.DataTextField = "Description";
                    ddlPatientType.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlPatientType.DataBind();
                    ddlPatientType.Visible = false;
                    lblPatientType.Visible = false;
                    lblDepartment.Text = "Vendor";
                    DataTable dtPanel = DBClass.getDataTable("select Vendor_ID,Vendor_Name from AP_Vendors where IsActive=1");
                    ddlDepartments.DataSource = dtPanel;
                    ddlDepartments.DataTextField = "Vendor_Name";
                    ddlDepartments.DataValueField = "Vendor_ID";
                    ddlDepartments.Items.Clear();
                    ddlDepartments.Items.Add(new ListItem("Please Select", "0"));
                    ddlDepartments.DataBind();


                    object valuset;
                    ddlwareHouse.DataSource = GetUserWarehouses();
                    ddlwareHouse.DataTextField = "Text";
                    ddlwareHouse.DataValueField = "Value";
                    ddlwareHouse.Items.Clear();
                    ddlwareHouse.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlwareHouse.DataBind();
                    Stock_Movement.Visible = true;


                    ddlwareHouse.Visible = true;
                    lblWarehouse.Visible = true;

                    lbItemCategory.Visible = false;
                    ddlItemCategory.Visible = false;

                }
                else if (this.PageTitle == "Vendor_Wise_Payment_Summary")
                {
                    string x = "Vendor Wise Payment Summary";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    object valusets;
                    tr_Summary.Visible = false;
                    tr_Export.Visible = true;
                    DateDiv.Visible = true;
                    Time_Row.Visible = false;
                    lblMultiSelect.Visible = false;
                    trDoctor.Visible = false;
                    AllowPatientRecord = false;
                    dpROw.Visible = true;
                    lblPatientType.Text = "Items";
                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    var serviceList = (from sl in db.INV_Items
                                       where
                                       sl.Active == true
                                       && sl.Hospital_Services == false
                                       && sl.Services == false
                                       select new { sl.Item_ID, sl.Description }).ToList();

                    ddlPatientType.DataSource = serviceList;

                    ddlPatientType.DataValueField = "Item_ID";
                    ddlPatientType.DataTextField = "Description";
                    ddlPatientType.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlPatientType.DataBind();
                    ddlPatientType.Visible = false;
                    lblPatientType.Visible = false;
                    lblDepartment.Text = "Vendor";
                    DataTable dtPanel = DBClass.getDataTable("select Vendor_ID,Vendor_Name from AP_Vendors where IsActive=1");
                    ddlDepartments.DataSource = dtPanel;
                    ddlDepartments.DataTextField = "Vendor_Name";
                    ddlDepartments.DataValueField = "Vendor_ID";
                    ddlDepartments.Items.Clear();
                    ddlDepartments.Items.Add(new ListItem("Please Select", "0"));
                    ddlDepartments.DataBind();
                }
                else if (this.PageTitle == "Bonus_Medicine_Detail_Report")
                {
                    string x = "Bonus Medicine Detail Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    object valusets;
                    tr_Summary.Visible = false;
                    tr_Export.Visible = true;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    lblMultiSelect.Visible = false;
                    trDoctor.Visible = false;
                    AllowPatientRecord = false;
                    dpROw.Visible = true;
                    lblPatientType.Text = "Items";
                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    var serviceList = (from sl in db.INV_Items
                                       where
                                       sl.Active == true
                                       && sl.Hospital_Services == false
                                       && sl.Services == false
                                       select new { sl.Item_ID, sl.Description }).ToList();

                    ddlPatientType.DataSource = serviceList;

                    ddlPatientType.DataValueField = "Item_ID";
                    ddlPatientType.DataTextField = "Description";
                    ddlPatientType.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlPatientType.DataBind();
                    ddlPatientType.Visible = false;
                    lblPatientType.Visible = false;
                    lblDepartment.Text = "Vendor";
                    DataTable dtPanel = DBClass.getDataTable("select Vendor_ID,Vendor_Name from AP_Vendors where IsActive=1");
                    ddlDepartments.DataSource = dtPanel;
                    ddlDepartments.DataTextField = "Vendor_Name";
                    ddlDepartments.DataValueField = "Vendor_ID";
                    ddlDepartments.Items.Clear();
                    ddlDepartments.Items.Add(new ListItem("Please Select", "0"));
                    ddlDepartments.DataBind();


                    //ADDING NEW WAREHOUSE

                    object valuset;
                    ddlwareHouse.DataSource = GetUserWarehouses();
                    ddlwareHouse.DataTextField = "Text";
                    ddlwareHouse.DataValueField = "Value";
                    ddlwareHouse.Items.Clear();
                    ddlwareHouse.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlwareHouse.DataBind();
                    Stock_Movement.Visible = true;


                    ddlwareHouse.Visible = true;
                    lblWarehouse.Visible = true;

                    lbItemCategory.Visible = false;
                    ddlItemCategory.Visible = false;
                }
                else if (this.PageTitle == "GRN_Report")
                {
                    string x = "GRN Detail Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr_Summary.Visible = false;
                    tr_Export.Visible = true;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    lblMultiSelect.Visible = false;
                    trDoctor.Visible = false;
                    AllowPatientRecord = false;
                    dpROw.Visible = true;
                    ddlPatientType.Visible = false;
                    lblPatientType.Visible = false;

                    Stock_Movement.Visible = true;

                    ddlItemCategory.Visible = false;
                    lbItemCategory.Visible = false;
                    lblItemCode.Visible = false;
                    txtItemCode.Visible = false;

                    object valuset;
                    ddlwareHouse.DataSource = GetUserWarehouses();
                    ddlwareHouse.DataTextField = "Text";
                    ddlwareHouse.DataValueField = "Value";
                    ddlwareHouse.Items.Clear();
                    ddlwareHouse.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlwareHouse.DataBind();

                    lblDepartment.Text = "Vendor";
                    DataTable dtPanel = DBClass.getDataTable("select Vendor_ID,Vendor_Name from AP_Vendors where IsActive=1");
                    ddlDepartments.DataSource = dtPanel;
                    ddlDepartments.DataTextField = "Vendor_Name";
                    ddlDepartments.DataValueField = "Vendor_ID";
                    ddlDepartments.Items.Clear();
                    ddlDepartments.Items.Add(new ListItem("Please Select", "0"));
                    ddlDepartments.DataBind();

                }
                else if (this.PageTitle == "GRN_PO_Reconciliation_Report")
                {
                    string x = "GRN vs PO Reconciliation Detail Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr_Summary.Visible = false;
                    tr_Export.Visible = true;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    lblMultiSelect.Visible = false;
                    trDoctor.Visible = false;
                    AllowPatientRecord = false;
                    dpROw.Visible = true;
                    ddlPatientType.Visible = false;
                    lblPatientType.Visible = false;

                    Stock_Movement.Visible = true;

                    ddlItemCategory.Visible = false;
                    lbItemCategory.Visible = false;
                    lblItemCode.Visible = false;
                    txtItemCode.Visible = false;

                    object valuset;
                    ddlwareHouse.DataSource = GetUserWarehouses();
                    ddlwareHouse.DataTextField = "Text";
                    ddlwareHouse.DataValueField = "Value";
                    ddlwareHouse.Items.Clear();
                    ddlwareHouse.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlwareHouse.DataBind();

                    lblDepartment.Text = "Vendor";
                    DataTable dtPanel = DBClass.getDataTable("select Vendor_ID,Vendor_Name from AP_Vendors where IsActive=1");
                    ddlDepartments.DataSource = dtPanel;
                    ddlDepartments.DataTextField = "Vendor_Name";
                    ddlDepartments.DataValueField = "Vendor_ID";
                    ddlDepartments.Items.Clear();
                    ddlDepartments.Items.Add(new ListItem("Please Select", "0"));
                    ddlDepartments.DataBind();

                }
                else if (this.PageTitle == "Inventory_Reconciliation_Report")
                {
                    string x = "Inventory Reconciliation Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr_Summary.Visible = false;
                    tr_Export.Visible = true;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    lblMultiSelect.Visible = false;
                    trDoctor.Visible = false;
                    AllowPatientRecord = false;
                    dpROw.Visible = true;
                    ddlPatientType.Visible = false;
                    lblPatientType.Visible = false;

                    Stock_Movement.Visible = true;

                    ddlItemCategory.Visible = false;
                    lbItemCategory.Visible = false;
                    lblItemCode.Visible = false;
                    txtItemCode.Visible = false;

                    object valuset;
                    ddlwareHouse.DataSource = GetUserWarehouses();
                    ddlwareHouse.DataTextField = "Text";
                    ddlwareHouse.DataValueField = "Value";
                    ddlwareHouse.Items.Clear();
                    ddlwareHouse.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlwareHouse.DataBind();

                    lblDepartment.Text = "Vendor";
                    DataTable dtPanel = DBClass.getDataTable("select Vendor_ID,Vendor_Name from AP_Vendors where IsActive=1");
                    ddlDepartments.DataSource = dtPanel;
                    ddlDepartments.DataTextField = "Vendor_Name";
                    ddlDepartments.DataValueField = "Vendor_ID";
                    ddlDepartments.Items.Clear();
                    ddlDepartments.Items.Add(new ListItem("Please Select", "0"));
                    ddlDepartments.DataBind();

                }
                else if (this.PageTitle == "Death_Certificate_Detail_Report")
                {
                    string x = "Death Certificate Detail Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr_Summary.Visible = false;
                    tr_Export.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    lblMultiSelect.Visible = false;
                    trDoctor.Visible = false;
                    AllowPatientRecord = false;
                    dpROw.Visible = false;
                    ddlPatientType.Visible = false;
                    lblPatientType.Visible = false;

                }
                else if (this.PageTitle == "Birth_Certificate_Detail_Report")
                {
                    string x = "Birth Certificate Detail Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    AllowPatientRecord = false;

                }
                else if (this.PageTitle == "Patient_Quality_Check_Report")
                {
                    string x = "Patient Quality Check Detail Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    AllowPatientRecord = false;
                    MRDiv.Visible = true;

                }
                else if (this.PageTitle == "LCP")
                {
                    string x = "LCP Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    AllowPatientRecord = false;

                }
                else if (this.PageTitle == "Gir_To_Po_Heirarchy")
                {
                    string x = "Gir To Po Heirarchy Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    AllowPatientRecord = false;
                    MRDiv.Visible = false;

                }
                else if (this.PageTitle == "Cath_Lab_Billing_Detail_Report")
                {
                    string x = "Cath Lab Billing Detail Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    trDoctor.Visible = true;
                    optRw.Visible = true;
                    AllowPatientRecord = false;

                    MRDiv.Visible = true;
                    lblMRNo.Visible = true;
                    txtMRNo.Visible = true;


                    DataTable dt = DBClass.getDataTable("select * from HR_Employees where IsDoctor=1");
                    ddlDoctor.DataSource = dt;
                    ddlDoctor.DataValueField = "Emp_ID";
                    ddlDoctor.DataTextField = "Emp_Name";
                    ddlDoctor.Items.Add(new ListItem() { Value = "0", Text = "All Doctors" });
                    ddlDoctor.DataBind();
                    ddlReportType.Visible = false;
                    lbservieType.Visible = false;


                    object valusets;
                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = from d in db.aspnet_Users
                               select new { d.UserName, d.UserId };
                    ddloprators.DataSource = valusets;
                    ddloprators.DataTextField = "UserName";
                    ddloprators.DataValueField = "UserId";
                    ddloprators.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddloprators.DataBind();
                    ddlShift.Visible = false;
                    lbShift.Visible = false;

                    DataBaseDataContext dbs = new DataBaseDataContext(DBClass.ConnectionString());
                    var serviceList = (from sl in dbs.INV_Items
                                       where sl.Active == true
                                       select new { sl.Item_ID, sl.Description }).ToList();

                    ddlItemName.DataSource = serviceList;
                    ddlItemName.DataValueField = "Item_ID";
                    ddlItemName.DataTextField = "Description";
                    ddlItemName.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlItemName.DataBind();

                    trSearch1.Visible = true;



                    lbItemCategory.Visible = false;
                    ddlItemCategory.Visible = false;

                }
                else if (this.PageTitle == "Cath_Lab_Billing_Detail_Vendor_Wise_Report")
                {
                    string x = "Cath Lab Billing Detail Vendor Wise Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    trDoctor.Visible = true;
                    optRw.Visible = true;
                    AllowPatientRecord = false;

                    MRDiv.Visible = true;
                    lblMRNo.Visible = true;
                    txtMRNo.Visible = true;


                    DataTable dt = DBClass.getDataTable("select * from HR_Employees where IsDoctor=1");
                    ddlDoctor.DataSource = dt;
                    ddlDoctor.DataValueField = "Emp_ID";
                    ddlDoctor.DataTextField = "Emp_Name";
                    ddlDoctor.Items.Add(new ListItem() { Value = "0", Text = "All Doctors" });
                    ddlDoctor.DataBind();
                    ddlReportType.Visible = false;
                    lbservieType.Visible = false;


                    object valusets;
                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = from d in db.aspnet_Users
                               select new { d.UserName, d.UserId };
                    ddloprators.DataSource = valusets;
                    ddloprators.DataTextField = "UserName";
                    ddloprators.DataValueField = "UserId";
                    ddloprators.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddloprators.DataBind();
                    ddlShift.Visible = false;
                    lbShift.Visible = false;

                    DataBaseDataContext dbs = new DataBaseDataContext(DBClass.ConnectionString());
                    var serviceList = (from sl in dbs.INV_Items
                                       where sl.Active == true
                                       select new { sl.Item_ID, sl.Description }).ToList();

                    ddlItemName.DataSource = serviceList;
                    ddlItemName.DataValueField = "Item_ID";
                    ddlItemName.DataTextField = "Description";
                    ddlItemName.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlItemName.DataBind();

                    trSearch1.Visible = true;

                    row_Vendor.Visible = true;
                    DataTable dtPanel = DBClass.getDataTable("select Vendor_ID,Vendor_Name from AP_Vendors where IsActive=1");
                    ddlVendor.DataSource = dtPanel;
                    ddlVendor.DataTextField = "Vendor_Name";
                    ddlVendor.DataValueField = "Vendor_ID";
                    ddlVendor.Items.Clear();
                    ddlVendor.Items.Add(new ListItem("Please Select", "0"));
                    ddlVendor.DataBind();



                }
                else if (this.PageTitle == "High_Risk_Medicine_Report")
                {
                    string x = "High Risk Medicine Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    AllowPatientRecord = false;
                }
                else if (this.PageTitle == "Narcotic_Medicine_Report")
                {
                    string x = "Narcotic Medicine Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    AllowPatientRecord = false;
                }
                else if (this.PageTitle == "Lab_Test_Result_Culture")
                {
                    string x = "Lab Test Result Culture Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    AllowPatientRecord = false;
                    dpROw.Visible = true;

                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;

                    object valusets;
                    DataBaseDataContext dbase = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = (from p in dbase.DataValues where p.ValueSet_ID == 67 select new { p.DataValue_Name, p.DataValue_Description }).ToList();
                    ddlDepartments.DataSource = valusets;
                    ddlDepartments.DataTextField = "DataValue_Description";
                    ddlDepartments.DataValueField = "DataValue_Name";
                    ddlDepartments.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlDepartments.DataBind();
                }
                else if (this.PageTitle == "Purchase_Order_Report")
                {
                    string x = "Purchase Order Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr_Summary.Visible = false;
                    tr_Export.Visible = true;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    lblMultiSelect.Visible = false;
                    trDoctor.Visible = false;
                    AllowPatientRecord = false;
                    dpROw.Visible = true;
                    ddlPatientType.Visible = false;
                    lblPatientType.Visible = false;
                    trStatus.Visible = true;

                    Stock_Movement.Visible = true;

                    ddlItemCategory.Visible = false;
                    lbItemCategory.Visible = false;
                    lblItemCode.Visible = false;
                    txtItemCode.Visible = false;

                    object valuset;
                    ddlwareHouse.DataSource = GetUserWarehouses();
                    ddlwareHouse.DataTextField = "Text";
                    ddlwareHouse.DataValueField = "Value";
                    ddlwareHouse.Items.Clear();
                    ddlwareHouse.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlwareHouse.DataBind();

                    lblDepartment.Text = "Vendor";
                    DataTable dtPanel = DBClass.getDataTable("select Vendor_ID,Vendor_Name from AP_Vendors where IsActive=1");
                    ddlDepartments.DataSource = dtPanel;
                    ddlDepartments.DataTextField = "Vendor_Name";
                    ddlDepartments.DataValueField = "Vendor_ID";
                    ddlDepartments.Items.Clear();
                    ddlDepartments.Items.Add(new ListItem("Please Select", "0"));
                    ddlDepartments.DataBind();

                    lblStatus.Text = "Status";
                    ddlStatus.Visible = true;
                    ddlStatus.Items.Clear();
                    ddlStatus.Items.Add(new ListItem() { Text = "All ", Value = "All" });
                    ddlStatus.Items.Add(new ListItem() { Text = "Complete", Value = "Complete" });
                    ddlStatus.Items.Add(new ListItem() { Text = "Partial", Value = "Partial" });
                    ddlStatus.Items.Add(new ListItem() { Text = "Pending", Value = "Pending" });
                    ddlStatus.DataBind();
                }
                else if (this.PageTitle == "Payment_to_Supplier_Report")
                {
                    string x = "Payment to Supplier Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr_Summary.Visible = false;
                    tr_Export.Visible = true;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    lblMultiSelect.Visible = false;
                    trDoctor.Visible = false;
                    AllowPatientRecord = false;
                    dpROw.Visible = true;
                    ddlPatientType.Visible = false;
                    lblPatientType.Visible = false;

                    Stock_Movement.Visible = false;

                    ddlItemCategory.Visible = false;
                    lbItemCategory.Visible = false;
                    lblItemCode.Visible = false;
                    txtItemCode.Visible = false;


                    lblDepartment.Text = "Vendor";
                    DataTable dtPanel = DBClass.getDataTable("select Vendor_ID,Vendor_Name from AP_Vendors where IsActive=1");
                    ddlDepartments.DataSource = dtPanel;
                    ddlDepartments.DataTextField = "Vendor_Name";
                    ddlDepartments.DataValueField = "Vendor_ID";
                    ddlDepartments.Items.Clear();
                    ddlDepartments.Items.Add(new ListItem("Please Select", "0"));
                    ddlDepartments.DataBind();

                }
                else if (this.PageTitle == "Purchase_Register_Report")
                {
                    string x = "Purchase Register Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr_Summary.Visible = false;
                    tr_Export.Visible = true;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    lblMultiSelect.Visible = false;
                    trDoctor.Visible = false;
                    AllowPatientRecord = false;
                    dpROw.Visible = true;
                    ddlPatientType.Visible = false;
                    lblPatientType.Visible = false;

                    Stock_Movement.Visible = false;

                    ddlItemCategory.Visible = false;
                    lbItemCategory.Visible = false;
                    lblItemCode.Visible = false;
                    txtItemCode.Visible = false;


                    lblDepartment.Text = "Vendor";
                    DataTable dtPanel = DBClass.getDataTable("select Vendor_ID,Vendor_Name from AP_Vendors where IsActive=1");
                    ddlDepartments.DataSource = dtPanel;
                    ddlDepartments.DataTextField = "Vendor_Name";
                    ddlDepartments.DataValueField = "Vendor_ID";
                    ddlDepartments.Items.Clear();
                    ddlDepartments.Items.Add(new ListItem("Please Select", "0"));
                    ddlDepartments.DataBind();

                }
                else if (this.PageTitle == "Pending_Payment_Request_Report")
                {
                    string x = "Pending Payment Request Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr_Summary.Visible = false;
                    tr_Export.Visible = true;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    lblMultiSelect.Visible = false;
                    trDoctor.Visible = false;
                    AllowPatientRecord = false;
                    dpROw.Visible = false;
                    ddlPatientType.Visible = false;
                    lblPatientType.Visible = false;

                    Stock_Movement.Visible = false;

                    ddlItemCategory.Visible = false;
                    lbItemCategory.Visible = false;
                    lblItemCode.Visible = false;
                    txtItemCode.Visible = false;
                }
                else if (this.PageTitle == "VPDR")
                {
                    string x = "VPDR";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr_Summary.Visible = false;
                    tr_Export.Visible = false;
                    DateDiv.Visible = false;
                    Time_Row.Visible = false;
                    lblMultiSelect.Visible = false;
                    trDoctor.Visible = false;
                    AllowPatientRecord = false;
                    dpROw.Visible = true;
                    optRw.Visible = true;
                    lblPatientType.Text = "Items";
                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    var serviceList = (from sl in db.INV_Items
                                       where
                                       sl.Active == true
                                       && sl.Hospital_Services == false
                                       && sl.Services == false
                                       select new { sl.Item_ID, sl.Description }).ToList();

                    ddlPatientType.DataSource = serviceList;

                    ddlPatientType.DataValueField = "Item_ID";
                    ddlPatientType.DataTextField = "Description";
                    ddlPatientType.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlPatientType.DataBind();
                    ddlPatientType.Visible = false;
                    lblPatientType.Visible = false;
                    lblDepartment.Text = "Vendor Name";
                    DataTable dtPanel = DBClass.getDataTable("select Vendor_ID,Vendor_Name from AP_Vendors where IsActive=1");
                    ddlDepartments.DataSource = dtPanel;
                    ddlDepartments.DataTextField = "Vendor_Name";
                    ddlDepartments.DataValueField = "Vendor_ID";
                    ddlDepartments.Items.Clear();
                    ddlDepartments.Items.Add(new ListItem("Please Select", "0"));
                    ddlDepartments.DataBind();
                    lbShift.Visible = false;
                    ddlShift.Visible = false;
                    lboperator.Text = "Status";
                    ddloprators.Visible = true;
                    ddloprators.Items.Clear();
                    ddloprators.Items.Add(new ListItem() { Text = "All ", Value = "2" });
                    ddloprators.Items.Add(new ListItem() { Text = "Active", Value = "1" });
                    ddloprators.Items.Add(new ListItem() { Text = "In Active", Value = "0" });
                    ddloprators.DataBind();
                }
                else if (this.PageTitle == "VendorWiseLedger")
                {
                    string x = "Vendor Wise Ledger Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr_Summary.Visible = false;
                    DateDiv.Visible = true;
                    sttDate.Visible = true;
                    txtStart_Date.Visible = true;
                    endDate.Visible = true;
                    txtEnd_Date.Visible = true;
                    Time_Row.Visible = false;
                    lblMultiSelect.Visible = false;
                    trDoctor.Visible = false;
                    AllowPatientRecord = false;
                    dpROw.Visible = true;
                    lblPatientType.Text = "Items";
                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    var serviceList = (from sl in db.INV_Items
                                       where
                                       sl.Active == true
                                       && sl.Hospital_Services == false
                                       && sl.Services == false
                                       select new { sl.Item_ID, sl.Description }).ToList();

                    ddlPatientType.DataSource = serviceList;

                    ddlPatientType.DataValueField = "Item_ID";
                    ddlPatientType.DataTextField = "Description";
                    ddlPatientType.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlPatientType.DataBind();
                    ddlPatientType.Visible = false;
                    lblPatientType.Visible = false;
                    lblDepartment.Text = "Vendor";
                    DataTable dtPanel = DBClass.getDataTable("select Vendor_ID,Vendor_Name from AP_Vendors where IsActive=1");
                    ddlDepartments.DataSource = dtPanel;
                    ddlDepartments.DataTextField = "Vendor_Name";
                    ddlDepartments.DataValueField = "Vendor_ID";
                    ddlDepartments.Items.Clear();
                    ddlDepartments.Items.Add(new ListItem("Please Select", "0"));
                    ddlDepartments.DataBind();
                }
                else if (this.PageTitle == "BER")
                {
                    string x = "Batch Expiry Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    object valusets;
                    tr_Summary.Visible = false;
                    tr_Export.Visible = true;
                    DateDiv.Visible = true;
                    Time_Row.Visible = false;
                    lblMultiSelect.Visible = false;
                    trDoctor.Visible = false;
                    AllowPatientRecord = false;
                    dpROw.Visible = true;
                    lblPatientType.Text = "Items Name";
                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    var serviceList = (from sl in db.INV_Items
                                       where
                                       sl.Active == true
                                       && sl.Hospital_Services == false
                                       && sl.Services == false
                                       select new { sl.Item_ID, sl.Description }).ToList();

                    ddlPatientType.DataSource = serviceList;
                    ddlPatientType.DataValueField = "Item_ID";
                    ddlPatientType.DataTextField = "Description";
                    ddlPatientType.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlPatientType.DataBind();
                    ddlPatientType.Visible = true;
                    lblPatientType.Visible = true;
                    lblDepartment.Text = "Ware House";
                    valusets = DBClass.GetValueSet("Ware House");
                    ddlDepartments.DataSource = valusets;
                    ddlDepartments.Items.Clear();
                    ddlDepartments.DataTextField = "DataValue_Description";
                    ddlDepartments.DataValueField = "DataValue_Name";
                    ddlDepartments.Items.Clear();
                    ddlDepartments.Items.Add(new ListItem("Please Select", "0"));
                    ddlDepartments.DataBind();
                }
                else if (this.PageTitle == "InvoiceAging")
                {
                    string x = "Invoice Aging";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr_Summary.Visible = false;
                    tr_Export.Visible = false;
                    DateDiv.Visible = true;
                    sttDate.Text = "End Date";
                    sttDate.Visible = true;
                    txtStart_Date.Visible = true;
                    endDate.Visible = false;
                    txtEnd_Date.Visible = false;
                    Time_Row.Visible = false;
                    lblMultiSelect.Visible = false;
                    trDoctor.Visible = false;
                    AllowPatientRecord = false;
                    dpROw.Visible = true;
                    ddlPatientType.Visible = false;
                    lblPatientType.Visible = false;
                    lblDepartment.Text = "Vendor Name";
                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    var serviceList = (from sl in db.AP_Vendors
                                       where
                                       sl.IsActive == true
                                       select new { sl.Vendor_ID, sl.Vendor_Name }).ToList();

                    ddlDepartments.DataSource = serviceList;
                    ddlDepartments.DataValueField = "Vendor_ID";
                    ddlDepartments.DataTextField = "Vendor_Name";
                    ddlDepartments.Items.Clear();
                    ddlDepartments.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlDepartments.DataBind();
                }
                else if (this.PageTitle == "ApAgingDetail")
                {
                    string x = "Ap Aging";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr_Summary.Visible = false;
                    tr_Export.Visible = false;
                    DateDiv.Visible = true;
                    sttDate.Text = "Start Date";
                    sttDate.Visible = true;
                    txtStart_Date.Visible = true;
                    endDate.Visible = false;
                    txtEnd_Date.Visible = false;
                    Time_Row.Visible = false;
                    lblMultiSelect.Visible = false;
                    trDoctor.Visible = false;
                    AllowPatientRecord = false;
                    dpROw.Visible = true;
                    ddlPatientType.Visible = false;
                    lblPatientType.Visible = false;
                    lblDepartment.Text = "Vendor Name";
                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    var serviceList = (from sl in db.AP_Vendors
                                       where
                                       sl.IsActive == true
                                       select new { sl.Vendor_ID, sl.Vendor_Name }).ToList();

                    ddlDepartments.DataSource = serviceList;
                    ddlDepartments.DataValueField = "Vendor_ID";
                    ddlDepartments.DataTextField = "Vendor_Name";
                    ddlDepartments.Items.Clear();
                    ddlDepartments.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlDepartments.DataBind();
                }
                else if (this.PageTitle == "ApAgingSummary")
                {
                    string x = "Ap Aging Summary";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr_Summary.Visible = false;
                    tr_Export.Visible = false;
                    DateDiv.Visible = true;
                    sttDate.Text = "Start Date";
                    sttDate.Visible = true;
                    txtStart_Date.Visible = true;
                    endDate.Visible = false;
                    txtEnd_Date.Visible = false;
                    Time_Row.Visible = false;
                    lblMultiSelect.Visible = false;
                    trDoctor.Visible = false;
                    AllowPatientRecord = false;
                    dpROw.Visible = true;
                    ddlPatientType.Visible = false;
                    lblPatientType.Visible = false;
                    lblDepartment.Text = "Vendor Name";
                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    var serviceList = (from sl in db.AP_Vendors
                                       where
                                       sl.IsActive == true
                                       select new { sl.Vendor_ID, sl.Vendor_Name }).ToList();

                    ddlDepartments.DataSource = serviceList;
                    ddlDepartments.DataValueField = "Vendor_ID";
                    ddlDepartments.DataTextField = "Vendor_Name";
                    ddlDepartments.Items.Clear();
                    ddlDepartments.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlDepartments.DataBind();
                }
                #endregion
                else if (PageTitle == "SehatSahulatWise")
                {
                    string x = "Sehat Sahulat Wise Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    object valusets;
                    dpROw.Visible = true;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    optRw.Visible = false;

                    trDoctor.Visible = false;
                    tr_Summary.Visible = false;

                    lblMainDepartment.Visible = false;
                    tr1MedicalSubsidy.Visible = false;
                    valusets = DBClass.GetValueSet("Patient Main Category");
                    ddlDepartments.DataSource = valusets;
                    ddlDepartments.Items.Clear();
                    ddlDepartments.DataTextField = "DataValue_Description";
                    ddlDepartments.DataValueField = "DataValue_Name";
                    ddlDepartments.Items.Clear();
                    ddlDepartments.Items.Add(new ListItem("Please Select", "0"));
                    ddlDepartments.DataBind();
                    AllowPatientRecord = false;
                }

                else if (this.PageTitle == "PARLR")
                {
                    string x = "Par and ReOrder Level Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    MainDeptDiv.Visible = true;
                    trTestResult1.Visible = true;
                    ddlPatientType.Visible = false;
                    tr_Summary.Visible = false;
                    tr_Export.Visible = true;
                    lblMultiSelect.Visible = false;
                    lblMedical.Text = "Item Group";
                    lblMedical.Visible = false;
                    tr1MedicalSubsidy.Visible = false;
                    lblPatientType.Visible = false;
                    lblTestName.Visible = true;
                    lblTestName.Text = "Account Category";
                    ddlDepartments.Visible = false;
                    ddlTestName.Visible = true;
                    lblMainDepartment.Visible = true;
                    lblMainDepartment.Text = "Items Name";
                    ddlMainDepartment.Visible = true;
                    object valusets;
                    DataBaseDataContext dbd = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = from d in dbd.INV_Items
                               where d.Item_Type == "001"
                               select new { d.Item_Code, d.Description, Complete = d.Item_Code + '-' + d.Description };
                    ddlMainDepartment.DataSource = valusets;
                    ddlMainDepartment.Items.Clear();
                    ddlMainDepartment.DataTextField = "Description";
                    ddlMainDepartment.DataValueField = "Item_Code";
                    ddlMainDepartment.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlMainDepartment.DataBind();

                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = from d in db.Account_Categories
                               select new { d.Account_Category_Id, d.CategoryName };
                    ddlTestName.DataSource = valusets;
                    ddlTestName.Items.Clear();
                    ddlTestName.DataTextField = "CategoryName";
                    ddlTestName.DataValueField = "Account_Category_Id";
                    ddlTestName.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlTestName.DataBind();
                    Stock_Movement.Visible = true;
                    object valuset;
                    ddlwareHouse.DataSource = GetUserWarehouses();
                    ddlwareHouse.DataTextField = "Text";
                    ddlwareHouse.DataValueField = "Value";
                    ddlwareHouse.Items.Clear();
                    ddlwareHouse.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlwareHouse.DataBind();
                    sttDate.Visible = false;
                    lbItemCategory.Visible = false;
                    ddlItemCategory.Visible = false;
                    txtStart_Date.Visible = false;
                    endDate.Visible = false;
                    txtEnd_Date.Visible = false;
                    optRw.Visible = false;
                    AllowPatientRecord = false;
                    dpROw.Visible = false;
                    Time_Row.Visible = false;
                    trZeroRecord.Visible = true;
                }
                else if (PageTitle == "SIH")
                {
                    string x = "Stock In Hand";
                    Master.Label2.Text = x;
                    Master.GetMenuName();

                    rowStock.Visible = true;
                    tr_Export.Visible = true;

                    txtStart_Date.Visible = false;
                    txtEnd_Date.Visible = false;


                    //ADDING NEW WAREHOUSE

                    object valuset;
                    ddlwareHouse.DataSource = GetUserWarehouses();
                    ddlwareHouse.DataTextField = "Text";
                    ddlwareHouse.DataValueField = "Value";
                    ddlwareHouse.Items.Clear();
                    ddlwareHouse.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlwareHouse.DataBind();
                    Stock_Movement.Visible = true;


                    ddlwareHouse.Visible = true;
                    lblWarehouse.Visible = true;

                    lbItemCategory.Visible = false;
                    ddlItemCategory.Visible = false;

                }
                else if (PageTitle == "Overall_Stock_Consumption_Details")
                {

                    string x = "Stock Consumption Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();

                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    rowStock.Visible = true;
                    //ADDING NEW WAREHOUSE

                    object valuset;
                    ddlwareHouse.DataSource = GetUserWarehouses();
                    ddlwareHouse.DataTextField = "Text";
                    ddlwareHouse.DataValueField = "Value";
                    ddlwareHouse.Items.Clear();
                    ddlwareHouse.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlwareHouse.DataBind();
                    Stock_Movement.Visible = true;


                    ddlwareHouse.Visible = true;
                    lblWarehouse.Visible = true;

                    lbItemCategory.Visible = false;
                    ddlItemCategory.Visible = false;
                }
                else if (PageTitle == "SAR")
                {
                    string x = "Stock Adjustment Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    dpROw.Visible = true;
                    Time_Row.Visible = false;
                    DateDiv.Visible = true;
                    sttDate.Visible = true;
                    txtStart_Date.Visible = true;
                    endDate.Visible = true;
                    txtEnd_Date.Visible = true;
                    tr_Export.Visible = false;
                    tr_Summary.Visible = false;
                    tr_Export.Visible = true;

                    object valusets;
                    lblDepartment.Text = "Reason";

                    DataBaseDataContext dbase = new DataBaseDataContext(DBClass.ConnectionString());


                    valusets = (from p in dbase.DataValues where p.ValueSet_ID == 3161 select new { p.DataValue_Name, p.DataValue_Description }).ToList();
                    ddlDepartments.DataSource = valusets;
                    ddlDepartments.DataTextField = "DataValue_Description";
                    ddlDepartments.DataValueField = "DataValue_Name";
                    ddlDepartments.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlDepartments.DataBind();


                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    lblPatientType.Visible = false;

                    //ADDING NEW WAREHOUSE

                    object valuset;
                    ddlwareHouse.DataSource = GetUserWarehouses();
                    ddlwareHouse.DataTextField = "Text";
                    ddlwareHouse.DataValueField = "Value";
                    ddlwareHouse.Items.Clear();
                    ddlwareHouse.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlwareHouse.DataBind();
                    Stock_Movement.Visible = true;


                    ddlwareHouse.Visible = true;
                    lblWarehouse.Visible = true;

                    lbItemCategory.Visible = false;
                    ddlItemCategory.Visible = false;


                }
                else if (PageTitle == "SehatSahulatWiseExpensive")
                {
                    string x = "Sehat Sahulat Wise Expense";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    object valusets;
                    dpROw.Visible = true;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    optRw.Visible = false;

                    trDoctor.Visible = false;
                    tr_Summary.Visible = false;

                    lblMainDepartment.Visible = false;
                    tr1MedicalSubsidy.Visible = false;
                    valusets = DBClass.GetValueSet("Patient Main Category");
                    ddlDepartments.DataSource = valusets;
                    ddlDepartments.Items.Clear();
                    ddlDepartments.DataTextField = "DataValue_Description";
                    ddlDepartments.DataValueField = "DataValue_Name";
                    ddlDepartments.Items.Clear();
                    ddlDepartments.Items.Add(new ListItem("Please Select", "0"));
                    ddlDepartments.DataBind();
                    AllowPatientRecord = false;
                }
                else if (PageTitle == "Patient_Trans_Detail_Type")
                {
                    string x = "Patient Trans Detail";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    //tblParameters.Visible = false;
                    lblMRNo.Visible = true;
                    txtMRNo.Visible = true;

                    lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    optRw.Visible = false;
                    trDoctor.Visible = false;
                    tr_Summary.Visible = false;

                    lblMainDepartment.Visible = false;
                    dpROw.Visible = false;
                }

                if (this.PageTitle == "Total_Income")
                {
                    string x = "Total Income";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr_Summary.Visible = false;
                    tr1MedicalSubsidy.Visible = false;
                    lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    optRw.Visible = false;
                    trDoctor.Visible = false;
                    AllowPatientRecord = false;
                    lblMainDepartment.Visible = false;
                    lblMedical.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    SetDepartent();
                    dpROw.Visible = false;
                }
                if (this.PageTitle == "Lab_Log_Report")
                {
                    string x = "Log Report Radiology";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr_Summary.Visible = false;
                    tr_Export.Visible = true;
                    tr1MedicalSubsidy.Visible = false;
                    lblMultiSelect.Visible = false;
                    CashierRow.Visible = true;
                    optRw.Visible = true;
                    trDoctor.Visible = true;
                    AllowPatientRecord = false;
                    lblMedical.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    SetDepartent();
                    dpROw.Visible = true;


                    object valusets;
                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = from d in db.aspnet_Users
                               select new { d.UserName, d.UserId };
                    ddloprators.DataSource = valusets;
                    ddloprators.DataTextField = "UserName";
                    ddloprators.DataValueField = "UserId";
                    ddloprators.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddloprators.DataBind();



                    lbShift.Visible = false;
                    ddlShift.Visible = false;

                    lblDoctor.Text = "Final Sign By";
                    object valuset;

                    DataTable dy = DBClass.getDataTable("select * from HR_Employees where IsDoctor=1");
                    ddlDoctor.DataSource = dy;
                    ddlDoctor.DataValueField = "Emp_ID";
                    ddlDoctor.DataTextField = "Emp_Name";
                    ddlDoctor.Items.Add(new ListItem() { Value = "0", Text = "All Doctors" });
                    ddlDoctor.DataBind();

                    lblCashier.Text = "Performing Doctor";
                    DataTable dt = DBClass.getDataTable("select * from HR_Employees where IsDoctor=1");
                    ddlcashier.DataSource = dt;
                    ddlcashier.DataValueField = "Emp_ID";
                    ddlcashier.DataTextField = "Emp_Name";
                    ddlcashier.Items.Add(new ListItem() { Value = "0", Text = "All Doctors" });
                    ddlcashier.DataBind();


                    MainDeptDiv.Visible = true;
                    lblMainDepartment.Text = "Category";
                    object valusetss;
                    valusetss = DBClass.GetValueSet("Mode Of Registration");
                    ddlMainDepartment.DataSource = valusetss;
                    ddlMainDepartment.DataTextField = "DataValue_Description";
                    ddlMainDepartment.DataValueField = "DataValue_Name";
                    ddlMainDepartment.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlMainDepartment.DataBind();


                    ddlPatientType.Visible = true;
                    lblPatientType.Visible = true;
                    lblPatientType.Text = "Billing Doctor";

                    DataTable du = DBClass.getDataTable("select * from HR_Employees where IsDoctor=1");
                    ddlPatientType.DataSource = du;
                    ddlPatientType.DataValueField = "Emp_ID";
                    ddlPatientType.DataTextField = "Emp_Name";
                    ddlPatientType.Items.Add(new ListItem() { Value = "0", Text = "All Doctors" });
                    ddlPatientType.DataBind();

                    ddlDepartments.Visible = true;
                    lblDepartment.Visible = true;
                    lblDepartment.Text = "Acknowledged By";
                    DataBaseDataContext dv = new DataBaseDataContext(DBClass.ConnectionString());
                    valuset = from d in dv.aspnet_Users
                              select new { d.UserName, d.UserId };
                    ddlDepartments.DataSource = valusets;
                    ddlDepartments.DataTextField = "UserName";
                    ddlDepartments.DataValueField = "UserId";
                    ddlDepartments.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlDepartments.DataBind();


                    test_Cat.Visible = true;
                    ddlcatagory.Visible = true;
                    lblTestCategory.Visible = true;
                    lblTestCategory.Text = "Prelim By";

                    DataTable dw = DBClass.getDataTable("select * from HR_Employees where IsDoctor=1");
                    ddlcatagory.DataSource = dw;
                    ddlcatagory.DataValueField = "Emp_Name";
                    ddlcatagory.DataTextField = "Emp_Name";
                    ddlcatagory.Items.Add(new ListItem() { Value = "0", Text = "All Doctors" });
                    ddlcatagory.DataBind();

                    ddlReportType.Visible = true;
                    lbservieType.Visible = true;
                    lbservieType.Text = "Referring Consultant";

                    DataTable dx = DBClass.getDataTable("select * from HR_Employees where IsDoctor=1");
                    ddlReportType.DataSource = dx;
                    ddlReportType.DataValueField = "Emp_ID";
                    ddlReportType.DataTextField = "Emp_Name";
                    ddlReportType.Items.Add(new ListItem() { Value = "0", Text = "All Doctors" });
                    ddlReportType.DataBind();


                    SubDepartment.Visible = true;
                    lblSubDepartment.Text = "Department";
                    object valuset1;
                    valuset1 = DBClass.GetValueSet("Main Test Departments");
                    ddlSubDepartment.DataSource = valuset1;
                    ddlSubDepartment.DataTextField = "DataValue_Description";
                    ddlSubDepartment.DataValueField = "DataValue_Name";
                    ddlSubDepartment.Items.Clear();
                    ddlSubDepartment.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlSubDepartment.DataBind();

                }



                if (this.PageTitle == "Student_Fee_Details_Report")
                {
                    string x = "Student Fee Details Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr_Summary.Visible = false;
                    tr1MedicalSubsidy.Visible = false;
                    lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    optRw.Visible = true;
                    trDoctor.Visible = false;
                    AllowPatientRecord = false;
                    lblMainDepartment.Visible = false;
                    lblMedical.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    SetDepartent();
                    dpROw.Visible = false;



                    DataBaseDataContext dbs = new DataBaseDataContext(DBClass.ConnectionString());
                    var valusets = (from p in dbs.Reg_Students
                                    orderby p.Roll_No
                                    select new
                                    {
                                        p.Roll_No,
                                        p.Full_Name,
                                        Complete = p.Roll_No + "-" + p.Full_Name
                                    }).ToList();

                    ddloprators.DataSource = valusets;
                    ddloprators.DataTextField = "Complete";
                    ddloprators.DataValueField = "Roll_No";
                    ddloprators.DataBind();
                    ddloprators.Items.Insert(0, new ListItem() { Text = "All", Value = "0" });
                    lboperator.Text = "Student";

                    lbShift.Visible = false;
                    ddlShift.Visible = false;

                }
                if (this.PageTitle == "Student_Fee_Details_Class_Report")
                {
                    string x = "Student Fee Receivable Details Class Wise Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr_Summary.Visible = false;
                    tr1MedicalSubsidy.Visible = false;
                    lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    optRw.Visible = true;
                    trDoctor.Visible = false;
                    AllowPatientRecord = false;
                    lblMainDepartment.Visible = false;
                    lblMedical.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    SetDepartent();
                    dpROw.Visible = false;


                    object valuset;
                    valuset = DBClass.GetValueSet("Student Class");
                    ddloprators.DataSource = valuset;
                    ddloprators.DataTextField = "DataValue_Description";
                    ddloprators.DataValueField = "DataValue_Name";
                    ddloprators.Items.Clear();
                    ddloprators.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddloprators.DataBind();
                    lboperator.Text = "Class";


                    lbShift.Visible = false;
                    ddlShift.Visible = false;

                }
                if (this.PageTitle == "Student_Fee_Details_Session_Report")
                {
                    string x = "Student Fee Details Session Wise Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr_Summary.Visible = false;
                    tr1MedicalSubsidy.Visible = false;
                    lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    optRw.Visible = true;
                    trDoctor.Visible = false;
                    AllowPatientRecord = false;
                    lblMainDepartment.Visible = false;
                    lblMedical.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    SetDepartent();
                    dpROw.Visible = false;


                    object valuset;
                    valuset = DBClass.GetValueSet("Session");
                    ddloprators.DataSource = valuset;
                    ddloprators.DataTextField = "DataValue_Description";
                    ddloprators.DataValueField = "DataValue_Name";
                    ddloprators.Items.Clear();
                    ddloprators.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddloprators.DataBind();
                    lboperator.Text = "Session";


                    lbShift.Visible = false;
                    ddlShift.Visible = false;

                }
                if (this.PageTitle == "Student_Receipt_Details_Report_Received")
                {
                    string x = "Student Fee Receipts Details";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr_Summary.Visible = false;
                    tr1MedicalSubsidy.Visible = false;
                    lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    optRw.Visible = true;
                    trDoctor.Visible = false;
                    AllowPatientRecord = false;
                    lblMainDepartment.Visible = false;
                    lblMedical.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    SetDepartent();
                    dpROw.Visible = false;


                    DataBaseDataContext dbs = new DataBaseDataContext(DBClass.ConnectionString());
                    var valusets = (from p in dbs.Reg_Students
                                    orderby p.Roll_No
                                    select new
                                    {
                                        p.Roll_No,
                                        p.Full_Name,
                                        Complete = p.Roll_No + "-" + p.Full_Name
                                    }).ToList();

                    ddloprators.DataSource = valusets;
                    ddloprators.DataTextField = "Complete";
                    ddloprators.DataValueField = "Roll_No";
                    ddloprators.DataBind();
                    ddloprators.Items.Insert(0, new ListItem() { Text = "All", Value = "0" });
                    lboperator.Text = "Student";


                    lbShift.Visible = false;
                    ddlShift.Visible = false;

                }
                if (this.PageTitle == "Student_Receipt_Details_Report_Balance")
                {
                    string x = "Student Receipt Details Balance";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr_Summary.Visible = false;
                    tr1MedicalSubsidy.Visible = false;
                    lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    optRw.Visible = true;
                    trDoctor.Visible = false;
                    AllowPatientRecord = false;
                    lblMainDepartment.Visible = false;
                    lblMedical.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    SetDepartent();
                    dpROw.Visible = false;


                    DataBaseDataContext dbs = new DataBaseDataContext(DBClass.ConnectionString());
                    var valusets = (from p in dbs.Reg_Students
                                    orderby p.Roll_No
                                    select new
                                    {
                                        p.Roll_No,
                                        p.Full_Name,
                                        Complete = p.Roll_No + "-" + p.Full_Name
                                    }).ToList();

                    ddloprators.DataSource = valusets;
                    ddloprators.DataTextField = "Complete";
                    ddloprators.DataValueField = "Roll_No";
                    ddloprators.DataBind();
                    ddloprators.Items.Insert(0, new ListItem() { Text = "All", Value = "0" });
                    lboperator.Text = "Student";


                    lbShift.Visible = false;
                    ddlShift.Visible = false;

                }
                if (this.PageTitle == "Student_Receipt_Class_Details_Report_Received")
                {
                    string x = "Student Receipt Class Wise Details Received";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr_Summary.Visible = false;
                    tr1MedicalSubsidy.Visible = false;
                    lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    optRw.Visible = true;
                    trDoctor.Visible = false;
                    AllowPatientRecord = false;
                    lblMainDepartment.Visible = false;
                    lblMedical.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    SetDepartent();
                    dpROw.Visible = false;


                    object valuset;
                    valuset = DBClass.GetValueSet("Student Class");
                    ddloprators.DataSource = valuset;
                    ddloprators.DataTextField = "DataValue_Description";
                    ddloprators.DataValueField = "DataValue_Name";
                    ddloprators.Items.Clear();
                    ddloprators.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddloprators.DataBind();
                    lboperator.Text = "Class";


                    lbShift.Visible = false;
                    ddlShift.Visible = false;

                }
                if (this.PageTitle == "Student_Receipt_Class_Details_Report_Balance")
                {
                    string x = "Student Receipt Class Wise Details Balance";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr_Summary.Visible = false;
                    tr1MedicalSubsidy.Visible = false;
                    lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    optRw.Visible = true;
                    trDoctor.Visible = false;
                    AllowPatientRecord = false;
                    lblMainDepartment.Visible = false;
                    lblMedical.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    SetDepartent();
                    dpROw.Visible = false;


                    object valuset;
                    valuset = DBClass.GetValueSet("Student Class");
                    ddloprators.DataSource = valuset;
                    ddloprators.DataTextField = "DataValue_Description";
                    ddloprators.DataValueField = "DataValue_Name";
                    ddloprators.Items.Clear();
                    ddloprators.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddloprators.DataBind();
                    lboperator.Text = "Class";


                    lbShift.Visible = false;
                    ddlShift.Visible = false;

                }
                if (this.PageTitle == "Student_Receipt_Session_Details_Report_Received")
                {
                    string x = "Student Receipt Session Wise Details Received";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr_Summary.Visible = false;
                    tr1MedicalSubsidy.Visible = false;
                    lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    optRw.Visible = true;
                    trDoctor.Visible = false;
                    AllowPatientRecord = false;
                    lblMainDepartment.Visible = false;
                    lblMedical.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    SetDepartent();
                    dpROw.Visible = false;


                    object valuset;
                    valuset = DBClass.GetValueSet("Session");
                    ddloprators.DataSource = valuset;
                    ddloprators.DataTextField = "DataValue_Description";
                    ddloprators.DataValueField = "DataValue_Name";
                    ddloprators.Items.Clear();
                    ddloprators.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddloprators.DataBind();
                    lboperator.Text = "Session";


                    lbShift.Visible = false;
                    ddlShift.Visible = false;

                }
                if (this.PageTitle == "Student_Receipt_Session_Details_Report_Balance")
                {
                    string x = "Student Receipt Session Wise Details Balance";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr_Summary.Visible = false;
                    tr1MedicalSubsidy.Visible = false;
                    lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    optRw.Visible = true;
                    trDoctor.Visible = false;
                    AllowPatientRecord = false;
                    lblMainDepartment.Visible = false;
                    lblMedical.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    SetDepartent();
                    dpROw.Visible = false;


                    object valuset;
                    valuset = DBClass.GetValueSet("Session");
                    ddloprators.DataSource = valuset;
                    ddloprators.DataTextField = "DataValue_Description";
                    ddloprators.DataValueField = "DataValue_Name";
                    ddloprators.Items.Clear();
                    ddloprators.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddloprators.DataBind();
                    lboperator.Text = "Session";


                    lbShift.Visible = false;
                    ddlShift.Visible = false;

                }
                if (this.PageTitle == "TimeAndMotion")
                {
                    string x = "Time and Motion Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr_Summary.Visible = false;
                    tr1MedicalSubsidy.Visible = false;
                    lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    optRw.Visible = false;
                    trDoctor.Visible = false;
                    AllowPatientRecord = false;
                    lblMainDepartment.Visible = false;
                    lblMedical.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    SetDepartent();
                    dpROw.Visible = false;

                }
                if (this.PageTitle == "DailySaleSummary")
                {
                    string x = "Daily Sale Summary";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr_Summary.Visible = false;
                    tr1MedicalSubsidy.Visible = false;
                    lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    optRw.Visible = false;
                    trDoctor.Visible = false;
                    AllowPatientRecord = false;
                    lblMainDepartment.Visible = false;
                    lblMedical.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    SetDepartent();
                    dpROw.Visible = false;
                    tr_Export.Visible = true;

                    //ADDING NEW WAREHOUSE

                    object valuset;
                    ddlwareHouse.DataSource = GetUserWarehouses();
                    ddlwareHouse.DataTextField = "Text";
                    ddlwareHouse.DataValueField = "Value";
                    ddlwareHouse.Items.Clear();
                    ddlwareHouse.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlwareHouse.DataBind();
                    Stock_Movement.Visible = true;


                    ddlwareHouse.Visible = true;
                    lblWarehouse.Visible = true;

                    lbItemCategory.Visible = false;
                    ddlItemCategory.Visible = false;

                }
                if (this.PageTitle == "Item_Wise_Gross_Profit_Report")
                {
                    string x = "Item Wise Gross Profit Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr_Summary.Visible = false;
                    tr1MedicalSubsidy.Visible = false;
                    lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    optRw.Visible = false;
                    trDoctor.Visible = false;
                    AllowPatientRecord = false;
                    lblMainDepartment.Visible = false;
                    lblMedical.Visible = false;
                    DateDiv.Visible = true;
                    tr_Export.Visible = true;
                    Time_Row.Visible = true;
                    SetDepartent();
                    dpROw.Visible = false;

                    td11.Text = "Item Name";
                    td11.Visible = true;
                    ddlItemName.Visible = true;
                    trSearch1.Visible = true;

                    DataBaseDataContext dbs = new DataBaseDataContext(DBClass.ConnectionString());
                    var serviceList = (from sl in dbs.INV_Items
                                       where sl.Active == true
                                       select new { sl.Item_ID, sl.Description }).ToList();

                    ddlItemName.DataSource = serviceList;
                    ddlItemName.DataValueField = "Item_ID";
                    ddlItemName.DataTextField = "Description";
                    ddlItemName.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlItemName.DataBind();


                    object valuset;
                    ddlwareHouse.DataSource = GetUserWarehouses();
                    ddlwareHouse.DataTextField = "Text";
                    ddlwareHouse.DataValueField = "Value";
                    ddlwareHouse.Items.Clear();
                    ddlwareHouse.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlwareHouse.DataBind();
                    Stock_Movement.Visible = true;


                    ddlwareHouse.Visible = true;
                    lblWarehouse.Visible = true;

                    lbItemCategory.Visible = false;
                    ddlItemCategory.Visible = false;


                }
                if (this.PageTitle == "Category_Wise_Profitability_Report")
                {
                    string x = "Category Wise Profitability";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr_Summary.Visible = false;
                    tr_Export.Visible = true;
                    tr1MedicalSubsidy.Visible = false;
                    lblMainDepartment.Visible = true;
                    ddlDepartments.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    optRw.Visible = false;
                    trDoctor.Visible = false;
                    AllowPatientRecord = false;
                    lblMedical.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    SetDepartent();
                    dpROw.Visible = false;
                    MainDeptDiv.Visible = true;
                    lblMainDepartment.Text = "Category";
                    object valusets;
                    valusets = DBClass.GetValueSet("Item Group");
                    ddlMainDepartment.DataSource = valusets;
                    ddlMainDepartment.DataTextField = "DataValue_Description";
                    ddlMainDepartment.DataValueField = "DataValue_Name";
                    ddlMainDepartment.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlMainDepartment.DataBind();


                    //ADDING NEW WAREHOUSE

                    object valuset;
                    ddlwareHouse.DataSource = GetUserWarehouses();
                    ddlwareHouse.DataTextField = "Text";
                    ddlwareHouse.DataValueField = "Value";
                    ddlwareHouse.Items.Clear();
                    ddlwareHouse.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlwareHouse.DataBind();
                    Stock_Movement.Visible = true;

                    ddlwareHouse.Visible = true;
                    lblWarehouse.Visible = true;

                    lbItemCategory.Visible = false;
                    ddlItemCategory.Visible = false;


                }
                if (this.PageTitle == "Fast_Slow_Non_Moving_Stock")
                {
                    string x = "Fast Slow Moving Stock Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();

                    tr_Export.Visible = true;
                    //tr_Summary.Visible = false;
                    //tr1MedicalSubsidy.Visible = false;
                    //ddlDepartments.Visible = false;
                    //lblPatientType.Visible = false;
                    //lblMultiSelect.Visible = false;
                    //ddlPatientType.Visible = false;
                    //optRw.Visible = false;
                    //trDoctor.Visible = false;
                    //AllowPatientRecord = false;
                    //lblMainDepartment.Visible = false;
                    //lblMedical.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    dpROw.Visible = false;

                    MainDeptDiv.Visible = true;
                    ddlMainDepartment.Visible = true;
                    lblMainDepartment.Visible = true;
                    lblMainDepartment.Text = "Item Name";
                    object valusets;
                    DataBaseDataContext dbd = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = from d in dbd.INV_Items
                               where d.IsPharmacyItem == true
                               select new { d.Item_Code, d.Description };
                    ddlMainDepartment.DataSource = valusets;
                    ddlMainDepartment.Items.Clear();
                    ddlMainDepartment.DataTextField = "Description";
                    ddlMainDepartment.DataValueField = "Item_Code";
                    ddlMainDepartment.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlMainDepartment.DataBind();

                    trMovementType.Visible = true;

                    //ADDING NEW WAREHOUSE

                    object valuset;
                    ddlwareHouse.DataSource = GetUserWarehouses();
                    ddlwareHouse.DataTextField = "Text";
                    ddlwareHouse.DataValueField = "Value";
                    ddlwareHouse.Items.Clear();
                    ddlwareHouse.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlwareHouse.DataBind();
                    Stock_Movement.Visible = true;


                    ddlwareHouse.Visible = true;
                    lblWarehouse.Visible = true;

                    lbItemCategory.Visible = false;
                    ddlItemCategory.Visible = false;


                }
                if (this.PageTitle == "Patient_Trans_Detail")
                {
                    string x = "Patient Transaction Detail";
                    Master.Label2.Text = x;
                    Master.GetMenuName();

                    tr_Summary.Visible = false;
                    tr1MedicalSubsidy.Visible = false;
                    lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    optRw.Visible = false;
                    trDoctor.Visible = false;
                    AllowPatientRecord = false;
                    lblMainDepartment.Visible = false;
                    lblMedical.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    SetDepartent();
                    dpROw.Visible = false;
                    MRDiv.Visible = true;
                    lblMRNo.Visible = true;
                    txtMRNo.Visible = true;
                }
                if (this.PageTitle == "PharmacyStockDetail")
                {
                    string x = "Pharmacy Stock Detail Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();

                    tr_Summary.Visible = false;
                    tr1MedicalSubsidy.Visible = false;
                    lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    optRw.Visible = false;
                    trDoctor.Visible = false;
                    AllowPatientRecord = false;
                    lblMainDepartment.Visible = false;
                    lblMedical.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    SetDepartent();
                    dpROw.Visible = false;
                    object valuset;
                    ddlwareHouse.DataSource = GetUserWarehouses();
                    ddlwareHouse.DataTextField = "Text";
                    ddlwareHouse.DataValueField = "Value";
                    ddlwareHouse.Items.Clear();
                    ddlwareHouse.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlwareHouse.DataBind();


                    ddlwareHouse.Visible = true;
                    lblWarehouse.Visible = true;


                    Stock_Movement.Visible = true;


                    ddlwareHouse.Visible = true;
                    lblWarehouse.Visible = true;

                    lbItemCategory.Visible = false;
                    ddlItemCategory.Visible = false;

                }
                if (this.PageTitle == "Pharmacy_Customer_Report")
                {
                    string x = "Customer Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();

                    tr_Summary.Visible = false;
                    tr_Export.Visible = true;
                    tr1MedicalSubsidy.Visible = false;
                    lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    optRw.Visible = false;
                    trDoctor.Visible = false;
                    AllowPatientRecord = false;
                    lblMainDepartment.Visible = false;
                    lblMedical.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    SetDepartent();
                    dpROw.Visible = false;

                    // ADDING NEW WAREHOUSE


                    //ADDING NEW WAREHOUSE

                    object valuset;
                    ddlwareHouse.DataSource = GetUserWarehouses();
                    ddlwareHouse.DataTextField = "Text";
                    ddlwareHouse.DataValueField = "Value";
                    ddlwareHouse.Items.Clear();
                    ddlwareHouse.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlwareHouse.DataBind();
                    Stock_Movement.Visible = true;


                    ddlwareHouse.Visible = true;
                    lblWarehouse.Visible = true;

                    lbItemCategory.Visible = false;
                    ddlItemCategory.Visible = false;
                }
                else if (PageTitle == "StudentAttendanceList")
                {
                    string x = "Student Attendance List";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;


                    lblMainDepartment.Visible = true;
                    lblMainDepartment.Text = "Program";
                    ddlMainDepartment.Visible = true;

                    lblMedical.Text = "Class";
                    tr1MedicalSubsidy.Visible = true;

                    ddlTestName.Visible = true;
                    ddlTestName.Text = "Batch";

                    AllowPatientRecord = false;

                    lblMultiSelect.Visible = false;
                    lblPatientType.Visible = false;
                    ddlPatientType.Visible = false;

                    MainDeptDiv.Visible = true;

                    object valusets;

                    DataBaseDataContext dbd = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = from d in dbd.DataValues
                               where d.ValueSet_ID == 3188
                               select new { d.DataValue_Description, d.DataValue_Name };
                    ddlMainDepartment.DataSource = valusets;
                    ddlMainDepartment.Items.Clear();
                    ddlMainDepartment.DataTextField = "DataValue_Description";
                    ddlMainDepartment.DataValueField = "DataValue_Name";
                    ddlMainDepartment.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlMainDepartment.DataBind();


                    DataBaseDataContext dbb = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = from d in dbb.DataValues
                               where d.ValueSet_ID == 3187
                               select new { d.DataValue_Description, d.DataValue_Name };
                    ddlMedicalSubsidy.DataSource = valusets;
                    ddlMedicalSubsidy.Items.Clear();
                    ddlMedicalSubsidy.DataTextField = "DataValue_Description";
                    ddlMedicalSubsidy.DataValueField = "DataValue_Name";
                    ddlMedicalSubsidy.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlMedicalSubsidy.DataBind();

                    trServiceName.Visible = true;

                    lblService.Text = "Batch";

                    valusets = DBClass.GetValueSet("Batch");
                    //DataTable dt = DBClass.getDataTable("Select DataValue_Name,DataValue_Description from DataValues Where ValueSet_ID=20");
                    ddlTestResult.DataSource = valusets;
                    ddlTestResult.Items.Clear();
                    ddlTestResult.DataValueField = "DataValue_Name";
                    ddlTestResult.DataTextField = "DataValue_Description";
                    ddlTestResult.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlTestResult.DataBind();

                    trProcedure1.Visible = true;
                    lbProcedure.Text = "Group";

                    DataBaseDataContext dbbb = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = from d in dbbb.DataValues
                               where d.ValueSet_ID == 3177
                               select new { d.DataValue_Description, d.DataValue_Name };
                    ddlProcedure.DataSource = valusets;
                    ddlProcedure.Items.Clear();
                    ddlProcedure.DataTextField = "DataValue_Description";
                    ddlProcedure.DataValueField = "DataValue_Name";
                    ddlProcedure.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlProcedure.DataBind();


                    var program = ddlMainDepartment.SelectedValue;
                    var classs = ddlMedicalSubsidy.SelectedValue;

                    dpROw.Visible = true;
                    lblDepartment.Text = "Subject";

                    DataBaseDataContext db1 = new DataBaseDataContext(DBClass.ConnectionString());
                    var listItems = (from s in db1.Subject_Definitions
                                     join sd in db1.Subject_Definition_Lists
                                     on s.subject_Id equals sd.Subject_ID
                                     select new
                                     {
                                         sd.Subject_Detail_ID,
                                         sd.Subject_Name

                                     }).ToList();
                    ddlDepartments.DataSource = listItems;
                    ddlDepartments.DataTextField = "Subject_Name";
                    ddlDepartments.DataValueField = "Subject_Detail_ID";
                    ddlDepartments.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlDepartments.DataBind();







                    var Subject = ddlDepartments.SelectedValue;


                    optRw.Visible = true;
                    lboperator.Text = "Sub Subject";

                    valusets = DBClass.GetValueSet("Subject Type");
                    ddloprators.DataSource = valusets;
                    ddloprators.Items.Clear();
                    ddloprators.DataValueField = "DataValue_Name";
                    ddloprators.DataTextField = "DataValue_Description";
                    ddloprators.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddloprators.DataBind();


                    lbShift.Visible = false;
                    ddlShift.Visible = false;

                }
                else if (PageTitle == "SubjectWiseAttendance")
                {
                    string x = "Subject Wise Attendance";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;


                    lblMainDepartment.Visible = true;
                    lblMainDepartment.Text = "Program";
                    ddlMainDepartment.Visible = true;

                    lblMedical.Text = "Class";
                    tr1MedicalSubsidy.Visible = true;

                    ddlTestName.Visible = true;
                    ddlTestName.Text = "Batch";

                    AllowPatientRecord = false;

                    lblMultiSelect.Visible = false;
                    lblPatientType.Visible = false;
                    ddlPatientType.Visible = false;

                    MainDeptDiv.Visible = true;

                    object valusets;

                    DataBaseDataContext dbd = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = from d in dbd.DataValues
                               where d.ValueSet_ID == 3188
                               select new { d.DataValue_Description, d.DataValue_Name };
                    ddlMainDepartment.DataSource = valusets;
                    ddlMainDepartment.Items.Clear();
                    ddlMainDepartment.DataTextField = "DataValue_Description";
                    ddlMainDepartment.DataValueField = "DataValue_Name";
                    ddlMainDepartment.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlMainDepartment.DataBind();


                    DataBaseDataContext dbb = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = from d in dbb.DataValues
                               where d.ValueSet_ID == 3187
                               select new { d.DataValue_Description, d.DataValue_Name };
                    ddlMedicalSubsidy.DataSource = valusets;
                    ddlMedicalSubsidy.Items.Clear();
                    ddlMedicalSubsidy.DataTextField = "DataValue_Description";
                    ddlMedicalSubsidy.DataValueField = "DataValue_Name";
                    ddlMedicalSubsidy.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlMedicalSubsidy.DataBind();

                    trServiceName.Visible = true;

                    lblService.Text = "Batch";

                    valusets = DBClass.GetValueSet("Batch");
                    //DataTable dt = DBClass.getDataTable("Select DataValue_Name,DataValue_Description from DataValues Where ValueSet_ID=20");
                    ddlTestResult.DataSource = valusets;
                    ddlTestResult.Items.Clear();
                    ddlTestResult.DataValueField = "DataValue_Name";
                    ddlTestResult.DataTextField = "DataValue_Description";
                    ddlTestResult.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlTestResult.DataBind();

                    trProcedure1.Visible = true;
                    lbProcedure.Text = "Group";

                    DataBaseDataContext dbbb = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = from d in dbbb.DataValues
                               where d.ValueSet_ID == 3177
                               select new { d.DataValue_Description, d.DataValue_Name };
                    ddlProcedure.DataSource = valusets;
                    ddlProcedure.Items.Clear();
                    ddlProcedure.DataTextField = "DataValue_Description";
                    ddlProcedure.DataValueField = "DataValue_Name";
                    ddlProcedure.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlProcedure.DataBind();


                    var program = ddlMainDepartment.SelectedValue;
                    var classs = ddlMedicalSubsidy.SelectedValue;

                    dpROw.Visible = true;
                    lblDepartment.Text = "Subject";

                    DataBaseDataContext db1 = new DataBaseDataContext(DBClass.ConnectionString());
                    var listItems = (from s in db1.Subject_Definitions
                                     join sd in db1.Subject_Definition_Lists
                                     on s.subject_Id equals sd.Subject_ID
                                     select new
                                     {
                                         sd.Subject_Detail_ID,
                                         sd.Subject_Name

                                     }).ToList();
                    ddlDepartments.DataSource = listItems;
                    ddlDepartments.DataTextField = "Subject_Name";
                    ddlDepartments.DataValueField = "Subject_Detail_ID";
                    ddlDepartments.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlDepartments.DataBind();







                    var Subject = ddlDepartments.SelectedValue;


                    optRw.Visible = true;
                    lboperator.Text = "Sub Subject";

                    valusets = DBClass.GetValueSet("Subject Type");
                    ddloprators.DataSource = valusets;
                    ddloprators.Items.Clear();
                    ddloprators.DataValueField = "DataValue_Name";
                    ddloprators.DataTextField = "DataValue_Description";
                    ddloprators.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddloprators.DataBind();


                    lbShift.Visible = false;
                    ddlShift.Visible = false;

                }
                else if (PageTitle == "AttendancePercentage")
                {
                    string x = "Attendance Percentage";
                    Master.Label2.Text = x;
                    Master.GetMenuName();

                    DateDiv.Visible = true;
                    Time_Row.Visible = true;


                    lblMainDepartment.Visible = true;
                    lblMainDepartment.Text = "Program";
                    ddlMainDepartment.Visible = true;

                    lblMedical.Text = "Class";
                    tr1MedicalSubsidy.Visible = true;

                    ddlTestName.Visible = true;
                    ddlTestName.Text = "Batch";

                    AllowPatientRecord = false;

                    lblMultiSelect.Visible = false;
                    lblPatientType.Visible = false;
                    ddlPatientType.Visible = false;

                    MainDeptDiv.Visible = true;

                    object valusets;

                    DataBaseDataContext dbd = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = from d in dbd.DataValues
                               where d.ValueSet_ID == 3188
                               select new { d.DataValue_Description, d.DataValue_Name };
                    ddlMainDepartment.DataSource = valusets;
                    ddlMainDepartment.Items.Clear();
                    ddlMainDepartment.DataTextField = "DataValue_Description";
                    ddlMainDepartment.DataValueField = "DataValue_Name";
                    ddlMainDepartment.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlMainDepartment.DataBind();


                    DataBaseDataContext dbb = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = from d in dbb.DataValues
                               where d.ValueSet_ID == 3187
                               select new { d.DataValue_Description, d.DataValue_Name };
                    ddlMedicalSubsidy.DataSource = valusets;
                    ddlMedicalSubsidy.Items.Clear();
                    ddlMedicalSubsidy.DataTextField = "DataValue_Description";
                    ddlMedicalSubsidy.DataValueField = "DataValue_Name";
                    ddlMedicalSubsidy.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlMedicalSubsidy.DataBind();

                    trServiceName.Visible = true;

                    lblService.Text = "Batch";

                    valusets = DBClass.GetValueSet("Batch");
                    //DataTable dt = DBClass.getDataTable("Select DataValue_Name,DataValue_Description from DataValues Where ValueSet_ID=20");
                    ddlTestResult.DataSource = valusets;
                    ddlTestResult.Items.Clear();
                    ddlTestResult.DataValueField = "DataValue_Name";
                    ddlTestResult.DataTextField = "DataValue_Description";
                    ddlTestResult.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlTestResult.DataBind();

                    trProcedure1.Visible = true;
                    lbProcedure.Text = "Group";

                    DataBaseDataContext dbbb = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = from d in dbbb.DataValues
                               where d.ValueSet_ID == 3177
                               select new { d.DataValue_Description, d.DataValue_Name };
                    ddlProcedure.DataSource = valusets;
                    ddlProcedure.Items.Clear();
                    ddlProcedure.DataTextField = "DataValue_Description";
                    ddlProcedure.DataValueField = "DataValue_Name";
                    ddlProcedure.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlProcedure.DataBind();


                    var program = ddlMainDepartment.SelectedValue;
                    var classs = ddlMedicalSubsidy.SelectedValue;

                    dpROw.Visible = true;
                    lblDepartment.Text = "Subject";

                    DataBaseDataContext db1 = new DataBaseDataContext(DBClass.ConnectionString());
                    var listItems = (from s in db1.Subject_Definitions
                                     join sd in db1.Subject_Definition_Lists
                                     on s.subject_Id equals sd.Subject_ID
                                     select new
                                     {
                                         sd.Subject_Detail_ID,
                                         sd.Subject_Name

                                     }).ToList();
                    ddlDepartments.DataSource = listItems;
                    ddlDepartments.DataTextField = "Subject_Name";
                    ddlDepartments.DataValueField = "Subject_Detail_ID";
                    ddlDepartments.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlDepartments.DataBind();







                    var Subject = ddlDepartments.SelectedValue;


                    optRw.Visible = true;
                    lboperator.Text = "Sub Subject";

                    valusets = DBClass.GetValueSet("Subject Type");
                    ddloprators.DataSource = valusets;
                    ddloprators.Items.Clear();
                    ddloprators.DataValueField = "DataValue_Name";
                    ddloprators.DataTextField = "DataValue_Description";
                    ddloprators.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddloprators.DataBind();


                    lbShift.Visible = false;
                    ddlShift.Visible = false;

                }

                if (this.PageTitle == "Physiotherapy_Cash_Collection")
                {
                    string x = "Physiotherapy Cash Collection";
                    Master.Label2.Text = x;
                    Master.GetMenuName();


                    tr_Summary.Visible = false;
                    tr1MedicalSubsidy.Visible = false;
                    lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    optRw.Visible = false;
                    trDoctor.Visible = false;
                    AllowPatientRecord = false;
                    lblMainDepartment.Visible = false;
                    lblMedical.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    SetDepartent();
                    dpROw.Visible = false;

                }
                if (this.PageTitle == "Item_Wise_Margin_Report")
                {
                    string x = "Item Wise Margin Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr_Summary.Visible = false;
                    tr1MedicalSubsidy.Visible = false;
                    lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    optRw.Visible = false;
                    trDoctor.Visible = false;
                    AllowPatientRecord = false;
                    lblMainDepartment.Visible = false;
                    lblMedical.Visible = false;
                    tr_Export.Visible = true;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    SetDepartent();
                    dpROw.Visible = false;

                    trSearch1.Visible = true;

                    object valuset;
                    ddlwareHouse.DataSource = GetUserWarehouses();
                    ddlwareHouse.DataTextField = "Text";
                    ddlwareHouse.DataValueField = "Value";
                    ddlwareHouse.Items.Clear();
                    ddlwareHouse.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlwareHouse.DataBind();
                    Stock_Movement.Visible = true;


                    ddlwareHouse.Visible = true;
                    lblWarehouse.Visible = true;

                    lbItemCategory.Visible = false;
                    ddlItemCategory.Visible = false;

                    DataBaseDataContext dbs = new DataBaseDataContext(DBClass.ConnectionString());
                    var serviceList = (from sl in dbs.INV_Items
                                       where sl.Active == true
                                       select new { sl.Item_ID, sl.Description }).ToList();

                    ddlItemName.DataSource = serviceList;
                    ddlItemName.DataValueField = "Item_ID";
                    ddlItemName.DataTextField = "Description";
                    ddlItemName.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlItemName.DataBind();

                }
                if (this.PageTitle == "Item_Wise_Purchase_Report")
                {

                    string x = "Item Wise Purchase Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr_Summary.Visible = false;
                    tr1MedicalSubsidy.Visible = false;
                    lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    optRw.Visible = false;
                    trDoctor.Visible = false;
                    AllowPatientRecord = false;
                    lblMainDepartment.Visible = false;
                    tr_Export.Visible = true;
                    lblMedical.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    SetDepartent();
                    dpROw.Visible = false;

                    trSearch1.Visible = true;

                    object valuset;
                    ddlwareHouse.DataSource = GetUserWarehouses();
                    ddlwareHouse.DataTextField = "Text";
                    ddlwareHouse.DataValueField = "Value";
                    ddlwareHouse.Items.Clear();
                    ddlwareHouse.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlwareHouse.DataBind();
                    Stock_Movement.Visible = true;


                    ddlwareHouse.Visible = true;
                    lblWarehouse.Visible = true;

                    lbItemCategory.Visible = false;
                    ddlItemCategory.Visible = false;

                    DataBaseDataContext dbs = new DataBaseDataContext(DBClass.ConnectionString());
                    var serviceList = (from sl in dbs.INV_Items
                                       where sl.Active == true
                                       select new { sl.Item_ID, sl.Description }).ToList();

                    ddlItemName.DataSource = serviceList;
                    ddlItemName.DataValueField = "Item_ID";
                    ddlItemName.DataTextField = "Description";
                    ddlItemName.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlItemName.DataBind();

                }
                if (this.PageTitle == "YearlyPharmacyOverallSummary")
                {

                    string x = "Yearly Overall Pharmacy Summary";
                    Master.Label2.Text = x;
                    Master.GetMenuName();

                    tr_Summary.Visible = false;
                    tr1MedicalSubsidy.Visible = false;
                    lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    optRw.Visible = false;
                    trDoctor.Visible = false;
                    AllowPatientRecord = false;
                    lblMainDepartment.Visible = false;
                    lblMedical.Visible = false;
                    dpROw.Visible = false;
                    YearDiv.Visible = true;
                    tr_Export.Visible = true;

                    //ADDING NEW WAREHOUSE

                    object valuset;
                    ddlwareHouse.DataSource = GetUserWarehouses();
                    ddlwareHouse.DataTextField = "Text";
                    ddlwareHouse.DataValueField = "Value";
                    ddlwareHouse.Items.Clear();
                    ddlwareHouse.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlwareHouse.DataBind();
                    Stock_Movement.Visible = true;


                    ddlwareHouse.Visible = true;
                    lblWarehouse.Visible = true;

                    lbItemCategory.Visible = false;
                    ddlItemCategory.Visible = false;

                }
                if (this.PageTitle == "DailyPharmacyOverallSummary")
                {

                    string x = "Daily Pharmacy Summary";
                    Master.Label2.Text = x;
                    Master.GetMenuName();

                    dpROw.Visible = false;
                    YearDiv.Visible = true;
                    MonthDiv.Visible = true;
                    tr_Export.Visible = true;

                    //ADDING NEW WAREHOUSE  

                    object valuset;
                    ddlwareHouse.DataSource = GetUserWarehouses();
                    ddlwareHouse.DataTextField = "Text";
                    ddlwareHouse.DataValueField = "Value";
                    ddlwareHouse.Items.Clear();
                    ddlwareHouse.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlwareHouse.DataBind();
                    Stock_Movement.Visible = true;

                    ddlwareHouse.Visible = true;
                    lblWarehouse.Visible = true;
                    lbItemCategory.Visible = false;
                    ddlItemCategory.Visible = false;
                }

                else if (this.PageTitle == "Cardiology_Cash_Collection")
                {
                    string x = "Cardiology Cash Collection";
                    Master.Label2.Text = x;
                    Master.GetMenuName();

                    // Show needed controls
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    tr_Export.Visible = true;
                    dpROw.Visible = true;

                    // Hide irrelevant controls
                    tr_Summary.Visible = false;
                    lblPatientType.Visible = false;
                    ddlPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    optRw.Visible = false;
                    trDoctor.Visible = false;
                    lblMainDepartment.Visible = false;
                    tr1MedicalSubsidy.Visible = false;

                    // Configure dropdown
                    lblDepartment.Visible = true;
                    lblDepartment.Text = "Test / Group";
                    ddlDepartments.Visible = true;
                    ddlDepartments.Items.Clear();

                    // Get Cardiology Tests (Main_Department = '008')
                    DataTable tests = DBClass.getDataTable(@"
        SELECT Test_ID, Test_Name 
        FROM Lab_Tests 
        WHERE Main_Department = '008' AND Active = 1
    ");

                    // Get Group Categories (ValueSet_ID = 70, Division = '004')
                    DataTable groups = DBClass.getDataTable(@"
        SELECT DataValue_Name, DataValue_Description 
        FROM DataValues 
        WHERE ValueSet_ID = 70 AND Division = '008'
    ");

                    // Combine
                    DataTable combined = new DataTable();
                    combined.Columns.Add("Value", typeof(string));   // ← This will store the NAME
                    combined.Columns.Add("Text", typeof(string));    // ← This is what user sees

                    // Add "All"
                    combined.Rows.Add("All", "All");

                    // Add Group Categories → use DataValue_Description as VALUE
                    foreach (DataRow row in groups.Rows)
                    {
                        string groupName = row["DataValue_Description"].ToString();
                        combined.Rows.Add(groupName, groupName); // Value = Text = Name
                    }

                    // Add Individual Tests → use Test_Name as VALUE
                    foreach (DataRow row in tests.Rows)
                    {
                        string testName = row["Test_Name"].ToString();
                        combined.Rows.Add(testName, testName);
                    }

                    ddlDepartments.DataSource = combined;
                    ddlDepartments.DataTextField = "Text";   // What user sees
                    ddlDepartments.DataValueField = "Value"; // What gets sent (now the NAME)
                    ddlDepartments.DataBind();
                }

                if (this.PageTitle == "RadiologyReport")
                {
                    string x = "Radiology Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();

                    tr_Summary.Visible = false;
                    tr1MedicalSubsidy.Visible = false;
                    lblMainDepartment.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    optRw.Visible = true;
                    trDoctor.Visible = false;
                    AllowPatientRecord = false;
                    lblMainDepartment.Visible = false;
                    lblMedical.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    SetDepartent();
                    dpROw.Visible = false;



                    MainDeptDiv.Visible = true;
                    lblMainDepartment.Visible = true;
                    lblMainDepartment.Text = "Radiology Name";
                    ddlMainDepartment.Visible = true;
                    ddlMainDepartment.Items.Clear();
                    ddlMainDepartment.Items.Add(new ListItem() { Text = "All", Value = "All" });
                    ddlMainDepartment.Items.Add(new ListItem() { Text = "Ultrasound", Value = "Ultrasound" });
                    ddlMainDepartment.Items.Add(new ListItem() { Text = "X-Ray", Value = "X-Ray" });
                    ddlMainDepartment.DataBind();


                    DataTable Tests = DBClass.getDataTable("select Test_id ,Test_Name from Lab_Tests where main_department in ('002','003')");
                    DataTable TestCategories = (DataTable)DBClass.getDataTable("select dv.DataValue_Name,dv.DataValue_Description from ValueSet vs,DataValues dv where vs.ValueSet_ID=dv.ValueSet_ID and vs.ValueSet_Name='Test Groups'");

                    foreach (DataRow dr in TestCategories.Rows)
                    {
                        DataRow newdr = Tests.NewRow();
                        newdr["Test_ID"] = dr["DataValue_Name"].ToString();
                        newdr["Test_Name"] = dr["DataValue_Description"].ToString();
                        Tests.Rows.Add(newdr);
                        Tests.AcceptChanges();
                    }
                    trTestResult1.Visible = true;
                    ddlTestName.DataSource = Tests;
                    ddlTestName.DataTextField = "Test_Name";
                    ddlTestName.DataValueField = "Test_Name";
                    ddlTestName.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlTestName.DataBind();

                    lblPatientType.Visible = true;
                    ddlPatientType.Visible = true;
                    object valusets;
                    valusets = DBClass.GetValueSet("Patient Type");
                    ddlPatientType.DataSource = valusets;
                    ddlPatientType.DataTextField = "DataValue_Description";
                    ddlPatientType.DataValueField = "DataValue_Name";
                    ddlPatientType.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlPatientType.DataBind();
                    SetDepartent();


                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = from d in db.aspnet_Users
                               select new { d.UserName, d.UserId };
                    ddloprators.DataSource = valusets;
                    ddloprators.DataTextField = "UserName";
                    ddloprators.DataValueField = "UserId";
                    ddloprators.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddloprators.DataBind();


                    lblMainDepartment.Visible = true;
                    ddlMainDepartment.Visible = true;
                    lboperator.Visible = true;
                    ddloprators.Visible = true;
                    lblDepartment.Visible = false;
                    ddlDepartments.Visible = false;

                    ddlShift.Visible = false;
                    lbShift.Visible = false;


                }
                if (this.PageTitle == "Extended_RadiologyReport")
                {
                    string x = "Radiology Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();

                    tr_Summary.Visible = false;
                    tr1MedicalSubsidy.Visible = false;
                    lblMainDepartment.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    optRw.Visible = true;
                    trDoctor.Visible = false;
                    AllowPatientRecord = false;
                    lblMainDepartment.Visible = false;
                    lblMedical.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    SetDepartent();
                    dpROw.Visible = false;



                    MainDeptDiv.Visible = true;
                    lblMainDepartment.Visible = true;
                    lblMainDepartment.Text = "Radiology Name";
                    ddlMainDepartment.Visible = true;
                    ddlMainDepartment.Items.Clear();
                    object valuset;
                    valuset = DBClass.GetValueSet("Main Test Departments");
                    ddlMainDepartment.DataSource = valuset;
                    ddlMainDepartment.DataTextField = "DataValue_Description";
                    ddlMainDepartment.DataValueField = "DataValue_Name";
                    ddlMainDepartment.Items.Clear();
                    ddlMainDepartment.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlMainDepartment.DataBind();



                    DataTable Tests = DBClass.getDataTable("select Test_id ,Test_Name from Lab_Tests where main_department in ('002','003','006','004','009','010')");
                    DataTable TestCategories = (DataTable)DBClass.getDataTable("select dv.DataValue_Name,dv.DataValue_Description from ValueSet vs,DataValues dv where vs.ValueSet_ID=dv.ValueSet_ID and vs.ValueSet_Name='Test Groups'");

                    foreach (DataRow dr in TestCategories.Rows)
                    {
                        DataRow newdr = Tests.NewRow();
                        newdr["Test_ID"] = dr["DataValue_Name"].ToString();
                        newdr["Test_Name"] = dr["DataValue_Description"].ToString();
                        Tests.Rows.Add(newdr);
                        Tests.AcceptChanges();
                    }
                    trTestResult1.Visible = true;
                    ddlTestName.DataSource = Tests;
                    ddlTestName.DataTextField = "Test_Name";
                    ddlTestName.DataValueField = "Test_Name";
                    ddlTestName.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlTestName.DataBind();

                    lblPatientType.Visible = true;
                    ddlPatientType.Visible = true;
                    object valusets;
                    valusets = DBClass.GetValueSet("Patient Type");
                    ddlPatientType.DataSource = valusets;
                    ddlPatientType.DataTextField = "DataValue_Description";
                    ddlPatientType.DataValueField = "DataValue_Name";
                    ddlPatientType.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlPatientType.DataBind();
                    SetDepartent();


                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = from d in db.aspnet_Users
                               select new { d.UserName, d.UserId };
                    ddloprators.DataSource = valusets;
                    ddloprators.DataTextField = "UserName";
                    ddloprators.DataValueField = "UserId";
                    ddloprators.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddloprators.DataBind();


                    lblMainDepartment.Visible = true;
                    ddlMainDepartment.Visible = true;
                    lboperator.Visible = true;
                    ddloprators.Visible = true;
                    lblDepartment.Visible = false;
                    ddlDepartments.Visible = false;

                    ddlShift.Visible = false;
                    lbShift.Visible = false;



                }
                if (this.PageTitle == "Extended_RadiologyReport_Panel")
                {
                    string x = "Radiology Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();

                    tr_Summary.Visible = false;
                    tr1MedicalSubsidy.Visible = false;
                    lblMainDepartment.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    optRw.Visible = true;
                    trDoctor.Visible = false;
                    AllowPatientRecord = false;
                    lblMainDepartment.Visible = false;
                    lblMedical.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    SetDepartent();
                    dpROw.Visible = true;



                    MainDeptDiv.Visible = true;
                    lblMainDepartment.Visible = true;
                    lblMainDepartment.Text = "Radiology Name";
                    ddlMainDepartment.Visible = true;
                    ddlMainDepartment.Items.Clear();
                    object valuset;
                    valuset = DBClass.GetValueSet("Main Test Departments");
                    ddlMainDepartment.DataSource = valuset;
                    ddlMainDepartment.DataTextField = "DataValue_Description";
                    ddlMainDepartment.DataValueField = "DataValue_Name";
                    ddlMainDepartment.Items.Clear();
                    ddlMainDepartment.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlMainDepartment.DataBind();



                    DataTable Tests = DBClass.getDataTable("select Test_id ,Test_Name from Lab_Tests where main_department in ('002','003','006','004','009','010')");
                    DataTable TestCategories = (DataTable)DBClass.getDataTable("select dv.DataValue_Name,dv.DataValue_Description from ValueSet vs,DataValues dv where vs.ValueSet_ID=dv.ValueSet_ID and vs.ValueSet_Name='Test Groups'");

                    foreach (DataRow dr in TestCategories.Rows)
                    {
                        DataRow newdr = Tests.NewRow();
                        newdr["Test_ID"] = dr["DataValue_Name"].ToString();
                        newdr["Test_Name"] = dr["DataValue_Description"].ToString();
                        Tests.Rows.Add(newdr);
                        Tests.AcceptChanges();
                    }
                    trTestResult1.Visible = true;
                    ddlTestName.DataSource = Tests;
                    ddlTestName.DataTextField = "Test_Name";
                    ddlTestName.DataValueField = "Test_Name";
                    ddlTestName.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlTestName.DataBind();

                    lblPatientType.Visible = true;
                    ddlPatientType.Visible = true;
                    object valusets;
                    valusets = DBClass.GetValueSet("Patient Type");
                    ddlPatientType.DataSource = valusets;
                    ddlPatientType.DataTextField = "DataValue_Description";
                    ddlPatientType.DataValueField = "DataValue_Name";
                    ddlPatientType.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlPatientType.DataBind();
                    SetDepartent();


                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = from d in db.aspnet_Users
                               select new { d.UserName, d.UserId };
                    ddloprators.DataSource = valusets;
                    ddloprators.DataTextField = "UserName";
                    ddloprators.DataValueField = "UserId";
                    ddloprators.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddloprators.DataBind();


                    lblMainDepartment.Visible = true;
                    ddlMainDepartment.Visible = true;
                    lboperator.Visible = true;
                    ddloprators.Visible = true;
                    lblDepartment.Text = "Panel";
                    DataTable dtPanel = DBClass.getDataTable("select panel_id,Company_Name from Panel");
                    ddlDepartments.DataSource = dtPanel;
                    ddlDepartments.DataTextField = "Company_Name";
                    ddlDepartments.DataValueField = "panel_id";
                    ddlDepartments.Items.Clear();
                    ddlDepartments.Items.Add(new ListItem("Please Select", "0"));
                    ddlDepartments.DataBind();

                    ddlShift.Visible = false;
                    lbShift.Visible = false;


                }

                if (this.PageTitle == "Panel_wise_Billing_Report")
                {
                    string x = "Panelized Billing Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();

                    tr_Summary.Visible = false;
                    tr1MedicalSubsidy.Visible = false;
                    lblMainDepartment.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    optRw.Visible = true;
                    trDoctor.Visible = false;
                    AllowPatientRecord = false;
                    lblMainDepartment.Visible = false;
                    lblMedical.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    SetDepartent();
                    dpROw.Visible = true;



                    MainDeptDiv.Visible = true;
                    lblMainDepartment.Visible = true;
                    lblMainDepartment.Text = "Department Name";
                    ddlMainDepartment.Visible = true;
                    ddlMainDepartment.Items.Clear();
                    object valuset;
                    valuset = DBClass.GetValueSet("Main Test Departments");
                    ddlMainDepartment.DataSource = valuset;
                    ddlMainDepartment.DataTextField = "DataValue_Description";
                    ddlMainDepartment.DataValueField = "DataValue_Name";
                    ddlMainDepartment.Items.Clear();
                    ddlMainDepartment.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlMainDepartment.DataBind();



                    DataTable Tests = DBClass.getDataTable("select Test_id ,Test_Name from Lab_Tests where main_department in ('002','003','006','004','009','010')");
                    DataTable TestCategories = (DataTable)DBClass.getDataTable("select dv.DataValue_Name,dv.DataValue_Description from ValueSet vs,DataValues dv where vs.ValueSet_ID=dv.ValueSet_ID and vs.ValueSet_Name='Test Groups'");

                    foreach (DataRow dr in TestCategories.Rows)
                    {
                        DataRow newdr = Tests.NewRow();
                        newdr["Test_ID"] = dr["DataValue_Name"].ToString();
                        newdr["Test_Name"] = dr["DataValue_Description"].ToString();
                        Tests.Rows.Add(newdr);
                        Tests.AcceptChanges();
                    }
                    trTestResult1.Visible = true;
                    ddlTestName.DataSource = Tests;
                    ddlTestName.DataTextField = "Test_Name";
                    ddlTestName.DataValueField = "Test_Name";
                    ddlTestName.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlTestName.DataBind();


                    object valusets;



                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = from d in db.aspnet_Users
                               select new { d.UserName, d.UserId };
                    ddloprators.DataSource = valusets;
                    ddloprators.DataTextField = "UserName";
                    ddloprators.DataValueField = "UserId";
                    ddloprators.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddloprators.DataBind();


                    lblMainDepartment.Visible = true;
                    ddlMainDepartment.Visible = true;
                    lboperator.Visible = true;
                    ddloprators.Visible = true;
                    lblDepartment.Text = "Panel";
                    DataTable dtPanel = DBClass.getDataTable("select panel_id,Company_Name from Panel");
                    ddlDepartments.DataSource = dtPanel;
                    ddlDepartments.DataTextField = "Company_Name";
                    ddlDepartments.DataValueField = "panel_id";
                    ddlDepartments.Items.Clear();
                    ddlDepartments.Items.Add(new ListItem("Please Select", "0"));
                    ddlDepartments.DataBind();

                    ddlShift.Visible = false;
                    lbShift.Visible = false;


                }




                if (this.PageTitle == "AnalysisReport")
                {
                    string x = "Analysis Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();

                    tr_Summary.Visible = false;
                    tr1MedicalSubsidy.Visible = false;
                    lblMainDepartment.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    optRw.Visible = true;
                    trDoctor.Visible = false;
                    AllowPatientRecord = false;
                    lblMainDepartment.Visible = false;
                    lblMedical.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    SetDepartent();
                    dpROw.Visible = false;


                    //DataTable Tests = DBClass.getDataTable("select Test_ID,Test_Name from Lab_Tests where main_department in ('001','002','003')");

                    //trTestResult1.Visible = true;
                    //ddlTestName.DataSource = Tests;
                    //ddlTestName.DataTextField = "Test_Name";
                    //ddlTestName.DataValueField = "Test_Name";
                    //ddlTestName.Items.Add(new ListItem() { Text = "All", Value = "All" });
                    //ddlTestName.DataBind();



                    // latest logic for combining tests

                    // Step 1: Get individual lab tests
                    DataTable Tests = DBClass.getDataTable(@"
        SELECT Test_ID, Test_Name 
        FROM Lab_Tests 
        WHERE main_department IN ('001','002','003')
    ");

                    // Step 2: Get test group categories (ValueSet_ID = 70, Division in 001-003)
                    DataTable TestCategories = DBClass.getDataTable(@"
        SELECT DataValue_Name, DataValue_Description 
        FROM DataValues 
        WHERE ValueSet_ID = 70 
          AND Division IN ('001','002','003')
    ");

                    // Step 3: Merge categories into the same DataTable
                    foreach (DataRow dr in TestCategories.Rows)
                    {
                        DataRow newdr = Tests.NewRow();
                        newdr["Test_ID"] = dr["DataValue_Name"].ToString();           // ← Value to pass to backend
                        newdr["Test_Name"] = dr["DataValue_Description"].ToString(); // ← Display text
                        Tests.Rows.Add(newdr);
                    }

                    // Step 4: Bind to dropdown
                    trTestResult1.Visible = true;
                    ddlTestName.DataSource = Tests;
                    ddlTestName.DataTextField = "Test_Name";   // What user sees
                    ddlTestName.DataValueField = "Test_Name";    // What gets sent (ID or group name)
                    ddlTestName.Items.Clear();
                    ddlTestName.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlTestName.AppendDataBoundItems = true; // Critical!
                    ddlTestName.DataBind();

                    object valusets;
                    SetDepartent();


                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = from d in db.aspnet_Users
                               select new { d.UserName, d.UserId };
                    ddloprators.DataSource = valusets;
                    ddloprators.DataTextField = "UserName";
                    ddloprators.DataValueField = "UserId";
                    ddloprators.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddloprators.DataBind();


                    lblMainDepartment.Visible = true;
                    ddlMainDepartment.Visible = true;
                    lboperator.Visible = true;
                    ddloprators.Visible = true;
                    lblDepartment.Visible = false;
                    ddlDepartments.Visible = false;

                    ddlShift.Visible = false;
                    lbShift.Visible = false;

                }

                if (this.PageTitle == "Sale_Return_Report")
                {
                    string x = "Sale Return Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();

                    tr_Summary.Visible = false;
                    tr1MedicalSubsidy.Visible = false;
                    lblMainDepartment.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    optRw.Visible = true;
                    trDoctor.Visible = false;
                    AllowPatientRecord = false;
                    lblMainDepartment.Visible = false;
                    lblMedical.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    SetDepartent();
                    dpROw.Visible = false;

                    object valusets;

                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = from d in db.aspnet_Users
                               select new { d.UserName, d.UserId };
                    ddloprators.DataSource = valusets;
                    ddloprators.DataTextField = "UserName";
                    ddloprators.DataValueField = "UserId";
                    ddloprators.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddloprators.DataBind();

                    lblMainDepartment.Visible = true;
                    ddlMainDepartment.Visible = true;
                    lboperator.Visible = true;
                    ddloprators.Visible = true;
                    lblDepartment.Visible = false;
                    ddlDepartments.Visible = false;

                    ddlShift.Visible = false;
                    lbShift.Visible = false;

                    // ADDING NEW WAREHOSUE

                    object valuset;
                    ddlwareHouse.DataSource = GetUserWarehouses();
                    ddlwareHouse.DataTextField = "Text";
                    ddlwareHouse.DataValueField = "Value";
                    ddlwareHouse.Items.Clear();
                    ddlwareHouse.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlwareHouse.DataBind();
                    Stock_Movement.Visible = true;


                    ddlwareHouse.Visible = true;
                    lblWarehouse.Visible = true;

                    lbItemCategory.Visible = false;
                    ddlItemCategory.Visible = false;
                    tr_Export.Visible = true;

                }

                if (this.PageTitle == "Bed_Occupancy")
                {
                    string x = "Bed Occupancy Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    dpROw.Visible = false;

                    tr1MedicalSubsidy.Visible = true;
                    lblMedical.Text = "Time Line";
                    tr_Export.Visible = true;
                    lblMultiSelect.Visible = false;
                    lblPatientType.Visible = false;
                    Time_Row.Visible = true;
                    tr_Summary.Visible = false;
                    optRw.Visible = false;
                    AllowPatientRecord = false;
                    dpROw.Visible = false;

                    lblMedical.Text = "Time Line";

                    lblMultiSelect.Visible = false;
                    lblPatientType.Visible = false;
                    Time_Row.Visible = true;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    tr_Summary.Visible = false;
                    AllowPatientRecord = false;

                    ddlMedicalSubsidy.Items.Clear();
                    ddlMedicalSubsidy.Items.Add("Annually With Stay Days");
                    ddlMedicalSubsidy.Items.Add("Annually With Stay Days Summary");
                    ddlMedicalSubsidy.Items.Add("Monthly");
                    ddlMedicalSubsidy.Items.Add("Annually");

                }
                if (this.PageTitle == "Procedure_Time_Line")
                {

                    string x = "Procedure Time Line";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    dpROw.Visible = false;

                    tr1MedicalSubsidy.Visible = true;
                    lblMedical.Text = "Time Line";
                    tr_Export.Visible = true;
                    lblMultiSelect.Visible = false;
                    lblPatientType.Visible = false;
                    Time_Row.Visible = true;
                    tr_Summary.Visible = false;
                    optRw.Visible = false;
                    AllowPatientRecord = false;
                    dpROw.Visible = false;

                    lblMedical.Text = "Time Line";

                    lblMultiSelect.Visible = false;
                    lblPatientType.Visible = false;
                    Time_Row.Visible = true;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    tr_Summary.Visible = false;
                    AllowPatientRecord = false;
                    ddlMedicalSubsidy.Items.Clear();
                    ddlMedicalSubsidy.Items.Add("Monthly");
                    ddlMedicalSubsidy.Items.Add("Annually");

                }
                if (this.PageTitle == "Procedure_Time_Line_Detail")
                {
                    string x = "Procedure Time Line Detail";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    dpROw.Visible = false;
                    trProcedure1.Visible = true;

                    tr1MedicalSubsidy.Visible = false;
                    tr_Export.Visible = true;
                    lblMultiSelect.Visible = false;

                    tr_Summary.Visible = false;
                    optRw.Visible = false;
                    AllowPatientRecord = false;
                    dpROw.Visible = true;
                    lblMultiSelect.Visible = false;
                    Time_Row.Visible = true;
                    DateDiv.Visible = true;
                    tr_Summary.Visible = false;
                    AllowPatientRecord = false;

                    lblPatientType.Text = "Patient Type";
                    object valusetS;
                    valusetS = DBClass.GetValueSet("Patient Type");
                    ddlPatientType.DataSource = valusetS;
                    ddlPatientType.DataTextField = "DataValue_Description";
                    ddlPatientType.DataValueField = "DataValue_Name";
                    ddlPatientType.Items.Clear();
                    ddlPatientType.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlPatientType.DataBind();

                    trSearch1.Visible = true;
                    lblDepartment.Visible = false;
                    ddlDepartments.Visible = false;

                    DataTable dt = DBClass.getDataTable("select * from inv_items");
                    ddlItemName.DataSource = dt;
                    ddlItemName.DataValueField = "Item_ID";
                    ddlItemName.DataTextField = "Description";
                    ddlItemName.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlItemName.DataBind();

                    td11.Text = "Procedure Name";

                    object valuset;
                    valuset = DBClass.GetValueSet("Procedure Types");
                    ddlProcedure.DataSource = valuset;
                    ddlProcedure.DataTextField = "DataValue_Description";
                    ddlProcedure.DataValueField = "DataValue_Name";
                    ddlProcedure.Items.Clear();
                    ddlProcedure.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlProcedure.DataBind();

                    lbProcedure.Text = "Procedure Type";

                    // appending the OPD IPD 
                    //trDepartmentType.Visible = true;
                    //ddOPDIPDdiv.Visible = true;
                    //lblDepartmentDiv.Visible = true;


                }
                if (this.PageTitle == "AverageLengthOfStay")
                {
                    string x = "Average Length Of Stay";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    dpROw.Visible = false;

                    tr1MedicalSubsidy.Visible = true;
                    lblMedical.Text = "Time Line";
                    tr_Export.Visible = true;
                    lblMultiSelect.Visible = false;
                    lblPatientType.Visible = false;
                    Time_Row.Visible = true;
                    tr_Summary.Visible = false;
                    optRw.Visible = false;
                    AllowPatientRecord = false;
                    dpROw.Visible = false;

                    lblMedical.Text = "Time Line";

                    lblMultiSelect.Visible = false;
                    lblPatientType.Visible = false;
                    Time_Row.Visible = true;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    tr_Summary.Visible = false;
                    AllowPatientRecord = false;

                    ddlMedicalSubsidy.Items.Clear();
                    //ddlMedicalSubsidy.Items.Add("Annually");
                    ddlMedicalSubsidy.Items.Add("Annually with Stay Days");
                    ddlMedicalSubsidy.Items.Add("Annually with Stay Days Summary");
                    ddlMedicalSubsidy.Items.Add("Annually");

                }
                if (this.PageTitle == "Sale_Report_Summary")
                {

                    string x = "Sale Report Summary";
                    Master.Label2.Text = x;
                    Master.GetMenuName();

                    tr_Summary.Visible = false;
                    tr1MedicalSubsidy.Visible = false;
                    lblMainDepartment.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    optRw.Visible = true;
                    trDoctor.Visible = false;
                    AllowPatientRecord = false;
                    lblMainDepartment.Visible = false;
                    lblMedical.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    SetDepartent();
                    dpROw.Visible = false;

                    object valusets;

                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = from d in db.aspnet_Users
                               select new { d.UserName, d.UserId };
                    ddloprators.DataSource = valusets;
                    ddloprators.DataTextField = "UserName";
                    ddloprators.DataValueField = "UserId";
                    ddloprators.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddloprators.DataBind();

                    lblMainDepartment.Visible = true;
                    ddlMainDepartment.Visible = true;
                    lboperator.Visible = true;
                    ddloprators.Visible = true;
                    lblDepartment.Visible = false;
                    ddlDepartments.Visible = false;

                    ddlShift.Visible = false;
                    lbShift.Visible = false;


                    // ADDING NEW  WAREHOUSE
                    object valuset;
                    ddlwareHouse.DataSource = GetUserWarehouses();
                    ddlwareHouse.DataTextField = "Text";
                    ddlwareHouse.DataValueField = "Value";
                    ddlwareHouse.Items.Clear();
                    ddlwareHouse.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlwareHouse.DataBind();
                    Stock_Movement.Visible = true;


                    ddlwareHouse.Visible = true;
                    lblWarehouse.Visible = true;

                    lbItemCategory.Visible = false;
                    ddlItemCategory.Visible = false;
                    tr_Export.Visible = true;
                }
                if (this.PageTitle == "Pharmacy_Profit_and_Loss_Report")
                {
                    string x = "Pharmacy Profit and Loss Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr_Summary.Visible = false;
                    tr1MedicalSubsidy.Visible = false;
                    lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    optRw.Visible = false;
                    trDoctor.Visible = false;
                    AllowPatientRecord = false;
                    lblMainDepartment.Visible = false;
                    lblMedical.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    SetDepartent();
                    dpROw.Visible = false;


                    //ADDING NEW WAREHOUSE

                    object valuset;
                    ddlwareHouse.DataSource = GetUserWarehouses();
                    ddlwareHouse.DataTextField = "Text";
                    ddlwareHouse.DataValueField = "Value";
                    ddlwareHouse.Items.Clear();
                    ddlwareHouse.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlwareHouse.DataBind();
                    Stock_Movement.Visible = true;


                    ddlwareHouse.Visible = true;
                    lblWarehouse.Visible = true;

                    lbItemCategory.Visible = false;
                    ddlItemCategory.Visible = false;
                    tr_Export.Visible = true;

                }
                if (this.PageTitle == "Head_Wise_Discount_Report")
                {
                    string x = "Head Wise Discount Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr_Summary.Visible = false;
                    tr1MedicalSubsidy.Visible = false;
                    lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    optRw.Visible = false;
                    trDoctor.Visible = false;
                    AllowPatientRecord = false;
                    lblMainDepartment.Visible = false;
                    lblMedical.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    SetDepartent();
                    dpROw.Visible = false;
                }

                else if (PageTitle == "PatientsTypesDetails")
                {
                    string x = "Patient Types Details";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    object valusets;
                    valusets = DBClass.GetValueSet("Patient Main Category");
                    ddlDepartments.DataSource = valusets;
                    ddlDepartments.DataTextField = "DataValue_Description";
                    ddlDepartments.DataValueField = "DataValue_Name";
                    ddlDepartments.Items.Add(new ListItem() { Text = "Please Select", Value = "0" });
                    ddlDepartments.DataBind();

                    valusets = DBClass.GetValueSet("Patient Type");
                    ddlPatientType.DataSource = valusets;
                    ddlPatientType.DataTextField = "DataValue_Description";
                    ddlPatientType.DataValueField = "DataValue_Name";
                    ddlPatientType.Items.Add(new ListItem() { Text = "Please Select", Value = "0" });
                    ddlPatientType.DataBind();


                    valusets = DBClass.GetValueSet("Patient Type");
                    lblMultiSelect.DataSource = valusets;
                    lblMultiSelect.DataTextField = "DataValue_Description";
                    lblMultiSelect.DataValueField = "DataValue_Name";
                    lblMultiSelect.Items.Add(new ListItem() { Text = "Please Select", Value = "0" });
                    lblMultiSelect.DataBind();

                    //----update


                    //----- end update

                    AllowPatientRecord = false;
                    tr_Summary.Visible = false;
                    lblMultiSelect.Visible = true;
                    ddlPatientType.Visible = false;
                    //Mohsin
                    DateDiv.Visible = true;
                    sttDate.Text = "Admission Date";
                    Time_Row.Visible = true;
                    endDate.Text = "Discharge Date";
                    sttTime.Text = "Admission Time";
                    endTime.Text = "Discharge Time";

                    //Mohsin

                }
                else if (this.PageTitle == "OutPatientsINP")
                {
                    string x = "Out Patient";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    optRw.Visible = false;
                    trDoctor.Visible = false;
                    tr_Summary.Visible = false;

                    lblMainDepartment.Visible = false;
                    dpROw.Visible = false;
                    AllowPatientRecord = false;
                }
                else if (PageTitle == "Patient_Trans_SehatSahulatCard")
                {
                    string x = "Patient Transaction";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    //tblParameters.Visible = false;
                    lblMRNo.Visible = true;
                    txtMRNo.Visible = true;

                    lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    optRw.Visible = false;
                    trDoctor.Visible = false;
                    tr_Summary.Visible = false;

                    lblMainDepartment.Visible = false;
                    dpROw.Visible = false;
                }
                else if (this.PageTitle == "OPD_Time_Line" || this.PageTitle == "Emergency_Time_Line" || this.PageTitle == "IPD_Time_Line" || this.PageTitle == "Discharge_Time_Line" || this.PageTitle == "Ward_Allocation_Time_Line" || this.PageTitle == "DepartmentWiseProcedureTimeLine")
                {
                    tr1MedicalSubsidy.Visible = true;
                    lblMedical.Text = "Time Line";

                    lblMultiSelect.Visible = false;
                    lblPatientType.Visible = false;
                    Time_Row.Visible = true;
                    tr_Summary.Visible = false;
                    optRw.Visible = false;
                    AllowPatientRecord = false;
                    dpROw.Visible = false;

                    lblMedical.Text = "Time Line";

                    lblMultiSelect.Visible = false;
                    lblPatientType.Visible = false;
                    Time_Row.Visible = true;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    tr_Summary.Visible = false;
                    AllowPatientRecord = false;

                    ddlMedicalSubsidy.Items.Clear();
                    if (this.PageTitle == "OPD_Time_Line")
                    {
                        ddlMedicalSubsidy.Items.Add("Weekly");
                    }
                    ddlMedicalSubsidy.Items.Add("Monthly");
                    ddlMedicalSubsidy.Items.Add("Annually");
                    if (this.PageTitle == "OPD_Time_Line")
                    {
                        string x = "OPD Time Line";
                        Master.Label2.Text = x;
                        Master.GetMenuName();
                    }
                    if (this.PageTitle == "Emergency_Time_Line")
                    {
                        ddlMedicalSubsidy.Items.Clear();
                        ddlMedicalSubsidy.Items.Add("Weekly");
                        ddlMedicalSubsidy.Items.Add("Monthly");
                        ddlMedicalSubsidy.Items.Add("Annually");
                        string x = "Emergency Time Line";
                        Master.Label2.Text = x;
                        Master.GetMenuName();
                    }
                    if (this.PageTitle == "IPD_Time_Line")
                    {
                        string x = "IPD Time Line";
                        Master.Label2.Text = x;
                        Master.GetMenuName();
                    }
                    if (this.PageTitle == "Discharge_Time_Line")
                    {
                        string x = "Discharge Time Line";
                        Master.Label2.Text = x;
                        Master.GetMenuName();
                    }
                    if (this.PageTitle == "Ward_Allocation_Time_Line")
                    {
                        string x = "Ward Allocation Time Line";
                        Master.Label2.Text = x;
                        Master.GetMenuName();
                    }


                    //if (this.PageTitle == "AverageLengthOfStay")
                    //{
                    //    ddlMedicalSubsidy.Items.Clear();
                    //    //ddlMedicalSubsidy.Items.Add("Annually");
                    //    ddlMedicalSubsidy.Items.Add("Annually with Stay Days");
                    //    ddlMedicalSubsidy.Items.Add("Annually with Stay Days Summary");
                    //}
                    //else if (this.PageTitle == "Bed_OccupancyBed_OccupancyBed_OccupancyBed_OccupancyBed_Occupancy")
                    //{
                    //    ddlMedicalSubsidy.Items.Clear();
                    //    ddlMedicalSubsidy.Items.Add("Annually With Stay Days");
                    //    ddlMedicalSubsidy.Items.Add("Annually With Stay Days Summary");
                    //}

                    if (AllowPatientRecord)
                    {
                        optRw.Visible = true;
                        DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                        object valusets = from d in db.aspnet_Users
                                          select new { d.UserName, d.UserId };
                        ddloprators.DataSource = valusets;
                        ddloprators.DataTextField = "UserName";
                        ddloprators.DataValueField = "UserId";
                        ddloprators.Items.Add(new ListItem() { Text = "All", Value = "0" });
                        ddloprators.DataBind();
                    }
                }


                else if (this.PageTitle == "TestWiseMonthly")
                {
                    string x = "Test Wise Monthly";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    dpROw.Visible = false;
                    tr1MedicalSubsidy.Visible = false;
                    lblMultiSelect.Visible = false;
                    lblPatientType.Visible = false;
                    Time_Row.Visible = false;
                    tr_Summary.Visible = false;
                    optRw.Visible = false;
                    AllowPatientRecord = false;

                    ddlMedicalSubsidy.Items.Clear();

                }
                else if (this.PageTitle == "BloodBankStockLedger")
                {
                    string x = "Blood Bank Stock Ledger";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    optRw.Visible = false;
                    trDoctor.Visible = false;
                    tr_Summary.Visible = false;

                    lblMainDepartment.Visible = false;
                    dpROw.Visible = false;
                    AllowPatientRecord = false;
                    DateDiv.Visible = false;
                    Time_Row.Visible = false;
                    tr_Summary.Visible = false;
                }

                else if (this.PageTitle == "ComponentBloodBankStockLedger")
                {
                    string x = "Blood Bank";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    optRw.Visible = false;
                    trDoctor.Visible = false;
                    tr_Summary.Visible = false;

                    lblMainDepartment.Visible = false;
                    dpROw.Visible = false;
                    AllowPatientRecord = false;
                    DateDiv.Visible = false;
                    Time_Row.Visible = false;
                    tr_Summary.Visible = false;
                    lblMainDepartment.Visible = true;
                    ddlMainDepartment.Visible = true;
                    lblMainDepartment.Text = "Blood Division";
                    object valusets;
                    valusets = DBClass.GetValueSet("Blood Division");
                    ddlMainDepartment.DataSource = valusets;
                    ddlMainDepartment.DataTextField = "DataValue_Description";
                    ddlMainDepartment.DataValueField = "DataValue_Name";
                    ddlMainDepartment.DataBind();

                    dpROw.Visible = false;
                    AllowPatientRecord = false;
                }

                else if (this.PageTitle == "CBloodBankStockLedger")
                {
                    string x = "Blood";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    ddlDepartments.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    optRw.Visible = false;
                    trDoctor.Visible = false;
                    tr_Summary.Visible = false;

                    dpROw.Visible = false;
                    AllowPatientRecord = false;
                    DateDiv.Visible = false;
                    Time_Row.Visible = false;
                    tr_Summary.Visible = false;
                    lblMainDepartment.Visible = true;
                    ddlMainDepartment.Visible = true;
                    lblMainDepartment.Text = "Blood Division";
                    object valusets;
                    valusets = DBClass.GetValueSet("Blood Division");
                    ddlMainDepartment.DataSource = valusets;
                    ddlMainDepartment.DataTextField = "DataValue_Description";
                    ddlMainDepartment.DataValueField = "DataValue_Name";
                    ddlMainDepartment.Items.Clear();
                    ddlMainDepartment.Items.Add(new ListItem("All", "0"));
                    ddlMainDepartment.DataBind();

                    dpROw.Visible = false;
                    AllowPatientRecord = false;
                }
                else if (PageTitle == "GroupTestsRateList")
                {
                    string x = "Group Test Rate List";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr_Export.Visible = true;

                    dpROw.Visible = true;
                    DateDiv.Visible = false;
                    Time_Row.Visible = false;
                    lblDepartment.Text = "Test Main Departments";
                    lblMultiSelect.Visible = false;

                    object valusets;
                    valusets = DBClass.GetValueSet("Main Test Departments");
                    ddlDepartments.DataSource = valusets;
                    ddlDepartments.Items.Clear();
                    ddlDepartments.DataTextField = "DataValue_Description";
                    ddlDepartments.DataValueField = "DataValue_Name";
                    ddlDepartments.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlDepartments.DataBind();

                    object valusetss;
                    valusetss = DBClass.GetValueSet("Patient Type");
                    ddlPatientType.DataSource = valusetss;
                    ddlPatientType.DataTextField = "DataValue_Description";
                    ddlPatientType.DataValueField = "DataValue_Name";
                    ddlPatientType.Items.Add(new ListItem() { Text = "Select Type", Value = "0" });
                    ddlPatientType.DataBind();

                    //ddlProcedure.Visible = true;
                    //ddlProcedure.Items.Clear();
                    //ddlProcedure.Items.Add(new ListItem() { Text = "All ", Value = "0" });
                    //ddlProcedure.Items.Add(new ListItem() { Text = "OPD", Value = "OPD" });
                    //ddlProcedure.Items.Add(new ListItem() { Text = "IPD", Value = "IPD" });


                }
                else if (PageTitle == "TestsRateList")
                {
                    string x = "Tests Rate List";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    object valusets;
                    lblMainDepartment.Visible = false;
                    tr_Export.Visible = true;
                    ddlDepartments.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    optRw.Visible = false;
                    trDoctor.Visible = false;
                    trProcedure1.Visible = true;

                    tr_Summary.Visible = false;
                    dpROw.Visible = false;
                    DateDiv.Visible = false;
                    Time_Row.Visible = false;
                    lbProcedure.Visible = true;
                    lbProcedure.Text = "OPD / IPD";
                    ddlMainDepartment.Visible = false;

                    lblMainDepartment.Visible = false;
                    tr1MedicalSubsidy.Visible = true;
                    ddlProcedure.Visible = true;
                    valusets = DBClass.GetValueSet("Main Test Departments");
                    ddlMedicalSubsidy.DataSource = valusets;
                    ddlMedicalSubsidy.Items.Clear();
                    ddlMedicalSubsidy.DataTextField = "DataValue_Description";
                    ddlMedicalSubsidy.DataValueField = "DataValue_Name";
                    ddlMedicalSubsidy.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlMedicalSubsidy.DataBind();

                    ddlProcedure.Items.Clear();
                    ddlProcedure.Items.Add(new ListItem() { Text = "All ", Value = "0" });
                    ddlProcedure.Items.Add(new ListItem() { Text = "OPD", Value = "OPD" });
                    ddlProcedure.Items.Add(new ListItem() { Text = "IPD", Value = "IPD" });

                    ddlProcedure.DataBind();

                }
                else if (PageTitle == "Patient_Wise_Panel")
                {
                    string x = "Patient Wise Panel";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    object valusets;
                    dpROw.Visible = true;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    optRw.Visible = false;

                    trDoctor.Visible = false;
                    tr_Summary.Visible = false;

                    lblMainDepartment.Visible = false;
                    tr1MedicalSubsidy.Visible = true;
                    lblMedical.Text = "Insurance Companies";
                    // dpROw.Visible = false;
                    DataTable dtPanel = DBClass.getDataTable("Select Panel_ID,Company_Name from Panel");
                    ddlMedicalSubsidy.DataSource = dtPanel;
                    ddlMedicalSubsidy.DataTextField = "Company_Name";
                    ddlMedicalSubsidy.DataValueField = "Panel_ID";
                    ddlMedicalSubsidy.Items.Clear();
                    ddlMedicalSubsidy.Items.Add(new ListItem("Please Select", "0"));
                    ddlMedicalSubsidy.DataBind();

                    valusets = DBClass.GetValueSet("Patient Main Category");
                    ddlDepartments.DataSource = valusets;
                    ddlDepartments.Items.Clear();
                    ddlDepartments.DataTextField = "DataValue_Description";
                    ddlDepartments.DataValueField = "DataValue_Name";
                    ddlDepartments.Items.Clear();
                    ddlDepartments.Items.Add(new ListItem("Please Select", "0"));
                    ddlDepartments.DataBind();


                    AllowPatientRecord = false;
                }
                else if (PageTitle == "BloodResultPending")
                {

                    string x = "Blood Result Pending";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    optRw.Visible = false;
                    dpROw.Visible = false;
                    trDoctor.Visible = false;

                    tr_Summary.Visible = false;

                    AllowPatientRecord = false;
                    lblMainDepartment.Visible = false;
                    tr1MedicalSubsidy.Visible = true;
                    lblMedical.Text = "Reports";
                    ddlMedicalSubsidy.Items.Clear();
                    ddlMedicalSubsidy.Items.Add(new ListItem() { Text = "Approved", Value = "0" });
                    ddlMedicalSubsidy.Items.Add(new ListItem() { Text = "Pending", Value = "1" });
                    ddlMedicalSubsidy.DataBind();
                }
                else if (PageTitle == "Procedure_Service_List")
                {
                    string x = "Procedure Service List";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    //stDate.Visible = false;
                    //enDate.Visible = true;
                    //object valusets;

                    lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    optRw.Visible = false;
                    trDoctor.Visible = false;
                    ddlDoctor.Visible = false;


                    lblMainDepartment.Visible = false;
                    dpROw.Visible = false;
                    tr_Summary.Visible = false;
                    DateDiv.Visible = false;
                    Time_Row.Visible = false;
                    AllowPatientRecord = false;
                    tr1ChkOPD.Visible = false;
                    tr1ChkIPD.Visible = false;
                    tr1ShowRate.Visible = false;
                    tr1MedicalSubsidy.Visible = true;
                    lblMedical.Visible = true;
                    ddlMedicalSubsidy.Visible = true;

                    lblMedical.Text = "Service/Procedure";
                    ddlMedicalSubsidy.Items.Clear();
                    ddlMedicalSubsidy.Items.Add(new ListItem() { Text = "Service", Value = "01" });
                    ddlMedicalSubsidy.Items.Add(new ListItem() { Text = "Procedure", Value = "02" });
                    ddlMedicalSubsidy.DataBind();
                    lblMainDepartment.Text = "Companies";
                    lblMainDepartment.Visible = false;
                    compDiv.Visible = true;
                    ddlCompdrop.Visible = true;


                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    var floors = (from sl in db.Panels
                                  select new { sl.Panel_ID, sl.Company_Name }).ToList();
                    if (floors != null)
                    {

                        ddlCompdrop.DataSource = floors;
                        ddlCompdrop.DataValueField = "Panel_ID";
                        ddlCompdrop.DataTextField = "Company_Name";
                        ddlCompdrop.DataBind();
                    }
                    ddlCompdrop.Visible = true;



                }
                else if (PageTitle == "Services_List")
                {
                    string x = "Services List";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    optRw.Visible = false;
                    trDoctor.Visible = false;
                    ddlDoctor.Visible = false;


                    lblMainDepartment.Visible = false;
                    dpROw.Visible = false;
                    tr_Summary.Visible = false;
                    Time_Row.Visible = false;
                    DateDiv.Visible = false;
                    AllowPatientRecord = false;
                    tr1ChkOPD.Visible = false;
                    tr1ChkIPD.Visible = false;
                    tr1ShowRate.Visible = true;
                    tr1MedicalSubsidy.Visible = true;
                    lblMedical.Visible = true;
                    ddlMedicalSubsidy.Visible = true;

                    lblMedical.Text = "Services";
                    ddlMedicalSubsidy.Items.Clear();
                    ddlMedicalSubsidy.Items.Add(new ListItem() { Text = "Services", Value = "0" });
                    ddlMedicalSubsidy.DataBind();
                }
                else if (this.PageTitle == "Blood_Bank_Lab_Test_Details")
                {
                    string x = "Blood Bank Test Details";
                    Master.Label2.Text = x;
                    Master.GetMenuName();

                    dpROw.Visible = false;
                    ddlPatientType.Visible = false;

                    tr_Summary.Visible = false;

                    AllowPatientRecord = false;

                    DataTable Tests = DBClass.getDataTable("select Test_ID,Test_Name from Lab_Tests");
                    DataTable TestCategories = (DataTable)DBClass.getDataTable("select dv.DataValue_Name,dv.DataValue_Description from ValueSet vs,DataValues dv where vs.ValueSet_ID=dv.ValueSet_ID and vs.ValueSet_Name='Test Groups'");

                    foreach (DataRow dr in TestCategories.Rows)
                    {
                        DataRow newdr = Tests.NewRow();
                        newdr["Test_ID"] = dr["DataValue_Name"].ToString();
                        newdr["Test_Name"] = dr["DataValue_Description"].ToString();
                        Tests.Rows.Add(newdr);
                        Tests.AcceptChanges();
                    }

                    ddlTestName.DataSource = Tests;
                    ddlTestName.DataTextField = "Test_Name";
                    ddlTestName.DataValueField = "Test_ID";
                    ddlTestName.Items.Add(new ListItem() { Text = "All", Value = "All" });
                    ddlTestName.DataBind();
                    ddlTestName.Visible = true;
                    lblTestName.Visible = true;

                    //lblMainDepartment.Visible = true;
                    //ddlDepartments.Visible = true;
                    object valusets;
                    //object valusets;
                    valusets = DBClass.GetValueSet("Patient Type");
                    lblMultiSelect.DataSource = valusets;
                    lblMultiSelect.DataTextField = "DataValue_Description";
                    lblMultiSelect.DataValueField = "DataValue_Name";
                    lblMultiSelect.Items.Add(new ListItem() { Text = "All", Value = "All" });
                    lblMultiSelect.DataBind();

                    //lblPatientType.Visible = true;
                    //lblMultiSelect.Visible = true;
                    SetDepartent();
                }
                else if (this.PageTitle == "Blood_Bank_Cash_Collection_Details")
                {
                    string x = "Blood Bank Cash Collection";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    dpROw.Visible = false;
                    ddlPatientType.Visible = false;
                    tr_Summary.Visible = true;
                    DataTable Tests = DBClass.getDataTable("select Test_ID,Test_Name from Lab_Tests");
                    DataTable TestCategories = (DataTable)DBClass.getDataTable("select dv.DataValue_Name,dv.DataValue_Description from ValueSet vs,DataValues dv where vs.ValueSet_ID=dv.ValueSet_ID and vs.ValueSet_Name='Test Groups'");

                    foreach (DataRow dr in TestCategories.Rows)
                    {
                        DataRow newdr = Tests.NewRow();
                        newdr["Test_ID"] = dr["DataValue_Name"].ToString();
                        newdr["Test_Name"] = dr["DataValue_Description"].ToString();
                        Tests.Rows.Add(newdr);
                        Tests.AcceptChanges();
                    }

                    ddlTestName.DataSource = Tests;
                    ddlTestName.DataTextField = "Test_Name";
                    ddlTestName.DataValueField = "Test_ID";
                    ddlTestName.Items.Add(new ListItem() { Text = "All", Value = "All" });
                    ddlTestName.DataBind();
                    ddlTestName.Visible = true;
                    lblTestName.Visible = true;
                    //lblMainDepartment.Visible = true;
                    //ddlDepartments.Visible = true;
                    object valusets;
                    //object valusets;
                    valusets = DBClass.GetValueSet("Patient Type");
                    lblMultiSelect.DataSource = valusets;
                    lblMultiSelect.DataTextField = "DataValue_Description";
                    lblMultiSelect.DataValueField = "DataValue_Name";
                    lblMultiSelect.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    lblMultiSelect.DataBind();

                    //lblPatientType.Visible = true;
                    //lblMultiSelect.Visible = true;
                    SetDepartent();
                }
                else if (this.PageTitle == "Non_Cash_Blood_Bank_Revenue")
                {
                    string x = "Blood";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    dpROw.Visible = false;
                    ddlPatientType.Visible = false;
                    tr_Summary.Visible = false;
                    //lblMainDepartment.Visible = true;
                    //ddlDepartments.Visible = true;
                    tr1MedicalSubsidy.Visible = true;
                    lblMedical.Visible = true;
                    ddlMedicalSubsidy.Visible = true;

                    AllowPatientRecord = false;



                    object valusets;
                    //object valusets;
                    valusets = DBClass.GetValueSet("Patient Type");
                    lblMultiSelect.DataSource = valusets;
                    lblMultiSelect.DataTextField = "DataValue_Description";
                    lblMultiSelect.DataValueField = "DataValue_Name";
                    lblMultiSelect.Items.Add(new ListItem() { Text = "All", Value = "All" });
                    lblMultiSelect.DataBind();
                    optRw.Visible = true;
                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = from d in db.aspnet_Users
                               select new { d.UserName, d.UserId };
                    ddloprators.DataSource = valusets;
                    ddloprators.DataTextField = "UserName";
                    ddloprators.DataValueField = "UserId";
                    ddloprators.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddloprators.DataBind();

                    //lblPatientType.Visible = true;
                    //lblMultiSelect.Visible = true;
                    SetDepartent();
                }
                //else if (this.PageTitle == "TestWiseMonthlyLabTestDepartment")
                //{
                //    ddlDepartments.Visible = true;
                //    dptROw.Visible = true;
                //    trMedicalSubsidy.Visible = false;
                //    lblMultiSelect.Visible = false;
                //    lblPatientType.Visible = false;
                //    TimeRow.Visible = false;
                //    trSummary.Visible = false;
                //    //oprtRw.Visible = false;
                //    AllowPatientRecord = false;
                //    ddlPatientType.Visible = false;

                //    txtStart_Date.Visible = true;
                //    txtEnd_Date.Visible = true;
                //    ddlDepartments.Visible = true;
                //    dpROw.Visible = true;
                //    tr1MedicalSubsidy.Visible = false;
                //    lblMultiSelect.Visible = false;
                //    lblPatientType.Visible = false;
                //    Time_Row.Visible = false;
                //    tr_Summary.Visible = false;
                //    optRw.Visible = false;
                //    AllowPatientRecord = false;
                //    ddlPatientType.Visible = false;
                //    object valusets;
                //    DataBaseDataContext dbase = new DataBaseDataContext(DBClass.ConnectionString());
                //    valusets = (from p in dbase.DataValues where p.ValueSet_ID == 67 select new { p.DataValue_Name, p.DataValue_Description }).ToList();
                //    ddlDepartments.DataSource = valusets;
                //    ddlDepartments.DataTextField = "DataValue_Description";
                //    ddlDepartments.DataValueField = "DataValue_Name";
                //    ddlDepartments.Items.Add(new ListItem() { Text = "All", Value = "0" });
                //    ddlDepartments.DataBind();
                //    ddlMedicalSubsidy.Items.Clear();
                //}
                else if (PageTitle == "Blood_Bank_Cash_Collection")
                {
                    string x = "Blood Bank Cash Collection";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    dpROw.Visible = false;
                    ddlPatientType.Visible = false;
                    tr_Summary.Visible = true;
                    //lblMainDepartment.Visible = true;
                    //ddlDepartments.Visible = true;
                    tr1MedicalSubsidy.Visible = true;
                    lblMedical.Visible = true;
                    ddlMedicalSubsidy.Visible = true;

                    object valusets;
                    //object valusets;
                    valusets = DBClass.GetValueSet("Patient Type");
                    lblMultiSelect.DataSource = valusets;
                    lblMultiSelect.DataTextField = "DataValue_Description";
                    lblMultiSelect.DataValueField = "DataValue_Name";
                    lblMultiSelect.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    lblMultiSelect.DataBind();
                    optRw.Visible = true;
                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = from d in db.aspnet_Users
                               select new { d.UserName, d.UserId };
                    ddloprators.DataSource = valusets;
                    ddloprators.DataTextField = "UserName";
                    ddloprators.DataValueField = "UserId";
                    ddloprators.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddloprators.DataBind();

                    //lblPatientType.Visible = true;
                    //lblMultiSelect.Visible = true;
                    SetDepartent();
                }
                else if (PageTitle == "LabResultPending")
                {
                    string x = "Lab Result Pending";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    object valusets;
                    lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = true;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    optRw.Visible = false;
                    trDoctor.Visible = false;

                    tr_Summary.Visible = false;


                    lblMainDepartment.Visible = false;
                    tr1MedicalSubsidy.Visible = true;


                    DataBaseDataContext dbase = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = (from p in dbase.DataValues where p.ValueSet_ID == 67 select new { p.DataValue_Name, p.DataValue_Description }).ToList();
                    ddlDepartments.DataSource = valusets;
                    ddlDepartments.DataTextField = "DataValue_Description";
                    ddlDepartments.DataValueField = "DataValue_Name";
                    ddlDepartments.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlDepartments.DataBind();
                    lblMedical.Text = "Reports";
                    ddlMedicalSubsidy.Items.Clear();
                    ddlMedicalSubsidy.Items.Add(new ListItem() { Text = "Approved", Value = "0" });
                    ddlMedicalSubsidy.Items.Add(new ListItem() { Text = "Pending", Value = "1" });
                    ddlMedicalSubsidy.DataBind();
                }

                else if (this.PageTitle == "Lab_Test_Investigation_Delay")
                {
                    string x = "Lab Test Investigation Delay";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    AllowPatientRecord = false;
                    dpROw.Visible = true;

                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;

                    object valusets;
                    DataBaseDataContext dbase = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = (from p in dbase.DataValues where p.ValueSet_ID == 67 select new { p.DataValue_Name, p.DataValue_Description }).ToList();
                    ddlDepartments.DataSource = valusets;
                    ddlDepartments.DataTextField = "DataValue_Description";
                    ddlDepartments.DataValueField = "DataValue_Name";
                    ddlDepartments.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlDepartments.DataBind();
                }
                else if (this.PageTitle == "Radiology_Investigation_Delay")
                {
                    string x = "Radiology Investigation Delay";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    dpROw.Visible = true;
                    optRw.Visible = false;
                    tr_Summary.Visible = false;
                    tr1MedicalSubsidy.Visible = false;
                    lblMedical.Visible = false;
                    ddlMedicalSubsidy.Visible = false;
                    ddlPatientType.Visible = false;
                    object valusets;
                    valusets = DBClass.GetValueSet("Patient Type");
                    ddlPatientType.DataSource = valusets;
                    ddlPatientType.DataTextField = "DataValue_Description";
                    ddlPatientType.DataValueField = "DataValue_Name";
                    ddlPatientType.Items.Add(new ListItem() { Text = "Select Type", Value = "All" });
                    ddlPatientType.DataBind();

                    lblDepartment.Text = "Radiology Departments";

                    DataBaseDataContext dbase = new DataBaseDataContext(DBClass.ConnectionString());

                    valusets = (from p in dbase.DataValues
                                where p.ValueSet_ID == 72
                                   && (p.DataValue_Name == "002"
                                    || p.DataValue_Name == "003"
                                    || p.DataValue_Name == "004"
                                    || p.DataValue_Name == "006")
                                select new
                                {
                                    p.DataValue_Name,
                                    p.DataValue_Description
                                }).ToList();

                    ddlDepartments.DataSource = valusets;
                    ddlDepartments.DataTextField = "DataValue_Description";
                    ddlDepartments.DataValueField = "DataValue_Name";
                    ddlDepartments.Items.Add(new ListItem { Text = "All", Value = "0" });
                    ddlDepartments.DataBind();

                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = from d in db.aspnet_Users
                               select new { d.UserName, d.UserId };
                    ddlShift.Visible = false;
                    lbShift.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    tr_Summary.Visible = false;
                    tr_Export.Visible = false;
                    lblMultiSelect.Visible = false;
                    lblPatientType.Visible = false;
                    tr_Summary.Visible = false;
                    GetLabTests();
                }
                else if (this.PageTitle == "Lab_Cash_Collection")
                {
                    string x = "Lab Cash Collection";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    dpROw.Visible = true;
                    tr_Summary.Visible = false;
                    tr1MedicalSubsidy.Visible = false;
                    lblMedical.Visible = false;
                    ddlMedicalSubsidy.Visible = false;

                    object valusets;
                    valusets = DBClass.GetValueSet("Patient Type");
                    ddlPatientType.DataSource = valusets;
                    ddlPatientType.DataTextField = "DataValue_Description";
                    ddlPatientType.DataValueField = "DataValue_Name";
                    ddlPatientType.Items.Add(new ListItem() { Text = "Select Type", Value = "All" });
                    ddlPatientType.DataBind();
                    optRw.Visible = true;
                    lblDepartment.Text = "Department";

                    DataBaseDataContext dbase = new DataBaseDataContext(DBClass.ConnectionString());


                    valusets = (from p in dbase.DataValues where p.ValueSet_ID == 67 select new { p.DataValue_Name, p.DataValue_Description }).ToList();
                    ddlDepartments.DataSource = valusets;
                    ddlDepartments.DataTextField = "DataValue_Description";
                    ddlDepartments.DataValueField = "DataValue_Name";
                    ddlDepartments.Items.Add(new ListItem() { Text = "All", Value = "All" });
                    ddlDepartments.DataBind();

                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = from d in db.aspnet_Users
                               select new { d.UserName, d.UserId };
                    ddloprators.DataSource = valusets;
                    ddloprators.DataTextField = "UserName";
                    ddloprators.DataValueField = "UserId";
                    ddloprators.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddloprators.DataBind();
                    ddlShift.Visible = false;
                    lbShift.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    tr_Summary.Visible = false;
                    tr_Export.Visible = false;
                    ddlPatientType.Visible = true;
                    lblMultiSelect.Visible = false;
                    tr_Summary.Visible = false;
                    GetLabTests();
                }
                else if (this.PageTitle == "Service_Wise_Summary_Report")
                {
                    string x = "Service Wise Summary";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    dpROw.Visible = true;
                    tr_Summary.Visible = false;
                    tr1MedicalSubsidy.Visible = false;
                    lblMedical.Visible = false;
                    ddlMedicalSubsidy.Visible = false;

                    object valusets;
                    optRw.Visible = true;
                    lblDepartment.Text = "Department";

                    DataBaseDataContext dbase = new DataBaseDataContext(DBClass.ConnectionString());


                    valusets = (from p in dbase.DataValues where p.ValueSet_ID == 72 select new { p.DataValue_Name, p.DataValue_Description }).ToList();
                    ddlDepartments.DataSource = valusets;
                    ddlDepartments.DataTextField = "DataValue_Description";
                    ddlDepartments.DataValueField = "DataValue_Name";
                    ddlDepartments.Items.Add(new ListItem() { Text = "All", Value = "All" });
                    ddlDepartments.DataBind();
                    ddlShift.Visible = false;
                    lbShift.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    tr_Summary.Visible = false;
                    tr_Export.Visible = false;
                    ddlPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    lblPatientType.Visible = false;
                    tr_Summary.Visible = false;
                    ddloprators.Visible = false;
                    lboperator.Visible = false;
                    GetLabTests();
                }
                else if (this.PageTitle == "Receipt_Operator_Wise_Report")
                {
                    //                    string x = "Lab Cash Collection";
                    string x = "Operator Wise Receipts";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    dpROw.Visible = true;
                    tr_Summary.Visible = true;
                    tr1MedicalSubsidy.Visible = false;
                    lblMedical.Visible = false;
                    ddlMedicalSubsidy.Visible = false;

                    object valusets;
                    valusets = DBClass.GetValueSet("Patient Type");
                    ddlPatientType.DataSource = valusets;
                    ddlPatientType.DataTextField = "DataValue_Description";
                    ddlPatientType.DataValueField = "DataValue_Name";
                    ddlPatientType.Items.Add(new ListItem() { Text = "Select Type", Value = "All" });
                    ddlPatientType.DataBind();
                    optRw.Visible = true;
                    lblDepartment.Text = "Department";

                    DataBaseDataContext dbase = new DataBaseDataContext(DBClass.ConnectionString());


                    valusets = (from p in dbase.DataValues where p.ValueSet_ID == 67 select new { p.DataValue_Name, p.DataValue_Description }).ToList();
                    ddlDepartments.DataSource = valusets;
                    ddlDepartments.DataTextField = "DataValue_Description";
                    ddlDepartments.DataValueField = "DataValue_Name";
                    ddlDepartments.Items.Add(new ListItem() { Text = "All", Value = "All" });
                    ddlDepartments.DataBind();

                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = from d in db.aspnet_Users
                               select new { d.UserName, d.UserId };
                    ddloprators.DataSource = valusets;
                    ddloprators.DataTextField = "UserName";
                    ddloprators.DataValueField = "UserId";
                    ddloprators.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddloprators.DataBind();
                    ddlShift.Visible = false;
                    lbShift.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    tr_Export.Visible = true;
                    ddlPatientType.Visible = true;
                    lblMultiSelect.Visible = false;
                    GetLabTests();
                    tr_AllPatientRecord.Visible = true;
                    lblAllPatientRecord.Text = "Detailed Summary";
                    //Label lblAllPatientRecord = tr_AllPatientRecord.FindControl("lblAllPatientRecord") as Label;
                    //if (lblAllPatientRecord != null)
                    //{
                    //    lblAllPatientRecord.Text = "Detailed Summary";
                    //}

                }
                else if (this.PageTitle == "Operator_Wise_Billing_Report")
                {
                    //                    string x = "Lab Cash Collection";
                    string x = "Operator Wise Billing";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    dpROw.Visible = true;
                    tr_Summary.Visible = true;
                    tr1MedicalSubsidy.Visible = false;
                    lblMedical.Visible = false;
                    ddlMedicalSubsidy.Visible = false;

                    object valusets;
                    valusets = DBClass.GetValueSet("Patient Type");
                    ddlPatientType.DataSource = valusets;
                    ddlPatientType.DataTextField = "DataValue_Description";
                    ddlPatientType.DataValueField = "DataValue_Name";
                    ddlPatientType.Items.Add(new ListItem() { Text = "Select Type", Value = "All" });
                    ddlPatientType.DataBind();
                    optRw.Visible = true;
                    lblDepartment.Text = "Department";

                    DataBaseDataContext dbase = new DataBaseDataContext(DBClass.ConnectionString());


                    valusets = (from p in dbase.DataValues where p.ValueSet_ID == 67 select new { p.DataValue_Name, p.DataValue_Description }).ToList();
                    ddlDepartments.DataSource = valusets;
                    ddlDepartments.DataTextField = "DataValue_Description";
                    ddlDepartments.DataValueField = "DataValue_Name";
                    ddlDepartments.Items.Add(new ListItem() { Text = "All", Value = "All" });
                    ddlDepartments.DataBind();

                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = from d in db.aspnet_Users
                               select new { d.UserName, d.UserId };
                    ddloprators.DataSource = valusets;
                    ddloprators.DataTextField = "UserName";
                    ddloprators.DataValueField = "UserId";
                    ddloprators.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddloprators.DataBind();
                    ddlShift.Visible = false;
                    lbShift.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    tr_Export.Visible = true;
                    ddlPatientType.Visible = true;
                    lblMultiSelect.Visible = false;
                    GetLabTests();
                    tr_AllPatientRecord.Visible = true;
                    lblAllPatientRecord.Text = "Detailed Summary";
                    //Label lblAllPatientRecord = tr_AllPatientRecord.FindControl("lblAllPatientRecord") as Label;
                    //if (lblAllPatientRecord != null)
                    //{
                    //    lblAllPatientRecord.Text = "Detailed Summary";
                    //}

                }



                //else if (this.PageTitle == "Lab_Test_Detail")
                //{
                //    dpROw.Visible = false;
                //    ddlPatientType.Visible = false;
                //    tr_Summary.Visible = true;
                //    DataTable Tests = DBClass.getDataTable("select Test_ID,Test_Name from Lab_Tests");
                //    DataTable TestCategories = (DataTable)DBClass.getDataTable("select dv.DataValue_Name,dv.DataValue_Description from ValueSet vs,DataValues dv where vs.ValueSet_ID=dv.ValueSet_ID and vs.ValueSet_Name='Test Groups'");

                //    foreach (DataRow dr in TestCategories.Rows)
                //    {
                //        DataRow newdr = Tests.NewRow();
                //        newdr["Test_ID"] = dr["DataValue_Name"].ToString();
                //        newdr["Test_Name"] = dr["DataValue_Description"].ToString();
                //        Tests.Rows.Add(newdr);
                //        Tests.AcceptChanges();
                //    }

                //    ddlTestName.DataSource = Tests;
                //    ddlTestName.DataTextField = "Test_Name";
                //    ddlTestName.DataValueField = "Test_ID";
                //    ddlTestName.Items.Add(new ListItem() { Text = "All", Value = "All" });
                //    ddlTestName.DataBind();
                //    ddlTestName.Visible = true;
                //    lblTestName.Visible = true;
                //    //lblMainDepartment.Visible = true;
                //    //ddlDepartments.Visible = true;
                //    object valusets;
                //    //object valusets;
                //    valusets = DBClass.GetValueSet("Patient Type");
                //    lblMultiSelect.DataSource = valusets;
                //    lblMultiSelect.DataTextField = "DataValue_Description";
                //    lblMultiSelect.DataValueField = "DataValue_Name";
                //    lblMultiSelect.Items.Add(new ListItem() { Text = "All", Value = "All" });
                //    lblMultiSelect.DataBind();
                //    trAllPatients.Visible = true;
                //    //lblPatientType.Visible = true;
                //    //lblMultiSelect.Visible = true;
                //    SetDepartent();
                //}
                else if (this.PageTitle == "BloodIssuance")
                {
                    string x = "Blood Issuance";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    optRw.Visible = false;
                    trDoctor.Visible = false;
                    tr_Summary.Visible = false;

                    lblMainDepartment.Visible = false;
                    dpROw.Visible = false;
                    AllowPatientRecord = false;
                }


                else if (this.PageTitle == "ComponentBloodStockLedger")
                {
                    string x = "Blood";
                    Master.Label2.Text = x;
                    Master.GetMenuName();

                    ddlDepartments.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    optRw.Visible = false;
                    trDoctor.Visible = false;
                    tr_Summary.Visible = false;
                    txtEnd_Date.Visible = false;
                    Time_Row.Visible = false;
                    endDate.Visible = false;
                    sttDate.Text = "Date";
                    lblMainDepartment.Visible = true;
                    ddlMainDepartment.Visible = true;
                    lblMainDepartment.Text = "Blood Division";
                    object valusets;
                    valusets = DBClass.GetValueSet("Blood Division");
                    ddlMainDepartment.DataSource = valusets;
                    ddlMainDepartment.DataTextField = "DataValue_Description";
                    ddlMainDepartment.DataValueField = "DataValue_Name";
                    ddlMainDepartment.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlMainDepartment.DataBind();

                    dpROw.Visible = false;
                    AllowPatientRecord = false;
                }
                else if (this.PageTitle == "WholeBloodStockLedger")
                {
                    string x = "Blood";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    optRw.Visible = false;
                    trDoctor.Visible = false;
                    tr_Summary.Visible = false;

                    lblMainDepartment.Visible = false;
                    dpROw.Visible = false;
                    AllowPatientRecord = false;
                }



                else if (this.PageTitle == "Lab_Department_Wise_Summary")
                {
                    string x = "Lab Department Wise Summary";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    dpROw.Visible = true;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    lblMultiSelect.Visible = false;

                    object valusets;
                    DataBaseDataContext dbase = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = (from p in dbase.DataValues where p.ValueSet_ID == 67 select new { p.DataValue_Name, p.DataValue_Description }).ToList();
                    ddlDepartments.DataSource = valusets;
                    ddlDepartments.DataTextField = "DataValue_Description";
                    ddlDepartments.DataValueField = "DataValue_Name";
                    ddlDepartments.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlDepartments.DataBind();

                    object valuesets;
                    valuesets = DBClass.GetValueSet("Patient Type");
                    ddlPatientType.DataSource = valuesets;
                    ddlPatientType.DataTextField = "DataValue_Description";
                    ddlPatientType.DataValueField = "DataValue_Name";
                    ddlPatientType.Items.Add(new ListItem() { Text = "Please Select", Value = "0" });
                    ddlPatientType.DataBind();

                }
                else if (this.PageTitle == "Test_Result_Status")
                {
                    string x = "Test Result Status";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    dpROw.Visible = false;
                    ddlPatientType.Visible = false;
                    tr_Summary.Visible = false;
                    AllowPatientRecord = false;
                    trTestResult1.Visible = true;
                }
                else if (PageTitle == "Procedure_List")
                {
                    string x = "Procedure List";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    optRw.Visible = false;
                    trDoctor.Visible = false;
                    ddlDoctor.Visible = false;


                    lblMainDepartment.Visible = false;
                    dpROw.Visible = false;
                    tr_Summary.Visible = false;
                    Time_Row.Visible = false;
                    DateDiv.Visible = false;

                    AllowPatientRecord = false;
                    tr1ChkOPD.Visible = false;
                    tr1ChkIPD.Visible = false;
                    tr1ShowRate.Visible = true;
                    tr1MedicalSubsidy.Visible = true;
                    lblMedical.Visible = true;
                    ddlMedicalSubsidy.Visible = true;

                    lblMedical.Text = "Procedures";
                    ddlMedicalSubsidy.Items.Clear();
                    ddlMedicalSubsidy.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlMedicalSubsidy.Items.Add(new ListItem() { Text = "Major", Value = "03" });
                    ddlMedicalSubsidy.Items.Add(new ListItem() { Text = "Medium", Value = "02" });
                    ddlMedicalSubsidy.Items.Add(new ListItem() { Text = "Minor", Value = "01" });
                    ddlMedicalSubsidy.DataBind();

                }

                else if (PageTitle == "AdmitPatientList")
                {

                    string x = "Admit Patient List";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr_Summary.Visible = false;
                    tr_Export.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;

                    trDoctor.Visible = false;
                    AllowPatientRecord = false;

                    dpROw.Visible = true;
                    lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = false;
                    lblDepartment.Visible = false;
                    lblPatientType.Visible = true;
                    ddlPatientType.Visible = true;
                    lblMultiSelect.Visible = false;

                    Stock_Movement.Visible = false;

                    ddlItemCategory.Visible = false;
                    lbItemCategory.Visible = false;
                    lblItemCode.Visible = false;
                    txtItemCode.Visible = false;

                    object valusets;
                    valusets = DBClass.GetValueSet("Patient Type");
                    ddlPatientType.DataSource = valusets;
                    ddlPatientType.DataTextField = "DataValue_Description";
                    ddlPatientType.DataValueField = "DataValue_Name";
                    ddlPatientType.Items.Add(new ListItem() { Text = "Please Select", Value = "0" });
                    ddlPatientType.DataBind();



                    //Response.Redirect("ReportViewer.aspx?ReportName=AdmitPatientList");
                }
                else if (this.PageTitle == "Daily_Revenue" || this.PageTitle == "Service_Charges_Detail" || this.PageTitle == "Department_Wise_Cash_Summary")
                {
                    object valusets;
                    //object valusets;
                    valusets = DBClass.GetValueSet("Patient Type");
                    lblMultiSelect.DataSource = valusets;
                    lblMultiSelect.DataTextField = "DataValue_Description";
                    lblMultiSelect.DataValueField = "DataValue_Name";
                    lblMultiSelect.Items.Add(new ListItem() { Text = "All", Value = "All" });
                    lblMultiSelect.DataBind();

                    lblPatientType.Visible = true;
                    lblMultiSelect.Visible = true;
                    if (this.PageTitle == "Service_Charges_Detail")
                    {
                        string x = "Service Charges Detail";
                        Master.Label2.Text = x;
                        Master.GetMenuName();
                        tr1MedicalSubsidy.Visible = true;
                        lblMainDepartment.Visible = true;
                        ddlDepartments.Visible = true;
                        lblTestName.Visible = false;
                        ddlTestName.Visible = false;
                        tr_Summary.Visible = true;
                        DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                        var serviceList = (from sl in db.INV_Items
                                           where
                                               /*For Admission Charges*/ sl.Item_ID == 293 ||
                                               /*For Nursery Well Charges*/sl.Item_ID == 12345
                                           select new { sl.Item_ID, sl.Description }).ToList();

                        ddlTestName.DataSource = serviceList;

                        ddlTestName.DataValueField = "Item_ID";
                        ddlTestName.DataTextField = "Description";

                        ddlShift.Visible = false;
                        lbShift.Visible = false;
                        DateDiv.Visible = true;
                        Time_Row.Visible = true;
                        dpROw.Visible = true;
                        optRw.Visible = true;
                        tr_Summary.Visible = false;
                        ddlTestName.DataBind();
                    }
                    if (this.PageTitle == "Daily_Revenue")
                    {
                        string x = "Daily Revenue";
                        Master.Label2.Text = x;
                        Master.GetMenuName();
                        tr_Summary.Visible = false;
                    }
                    lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = true;

                    ddlPatientType.Visible = false;
                    optRw.Visible = false;
                    trDoctor.Visible = false;


                    if (AllowPatientRecord)
                    {
                        optRw.Visible = true;
                    }
                    else
                    {
                        optRw.Visible = false;
                    }

                    DataBaseDataContext dbase = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = from d in dbase.aspnet_Users
                               select new { d.UserName, d.UserId };
                    ddloprators.DataSource = valusets;
                    ddloprators.DataTextField = "UserName";
                    ddloprators.DataValueField = "UserId";
                    ddloprators.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddloprators.DataBind();

                    if (this.PageTitle == "Department_Wise_Cash_Summary")
                    {
                        string x = "Department Wise Cash Summary";
                        Master.Label2.Text = x;
                        Master.GetMenuName();
                        tr_Summary.Visible = false;
                    }
                    lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = true;

                    ddlPatientType.Visible = false;
                    optRw.Visible = false;
                    trDoctor.Visible = false;

                    object valusetss;
                    valusetss = DBClass.GetValueSet("Patient Type");
                    ddlPatientType.DataSource = valusetss;
                    ddlPatientType.DataTextField = "DataValue_Description";
                    ddlPatientType.DataValueField = "DataValue_Name";
                    ddlPatientType.Items.Add(new ListItem() { Text = "Select Type", Value = "All" });
                    ddlPatientType.DataBind();
                    if (AllowPatientRecord)
                    {
                        optRw.Visible = true;
                    }
                    else
                    {
                        optRw.Visible = false;
                    }

                    valusets = (from p in dbase.DataValues where p.ValueSet_ID == 9 select new { p.DataValue_Name, p.DataValue_Description }).ToList();
                    ddlDepartments.DataSource = valusets;
                    ddlDepartments.DataTextField = "DataValue_Description";
                    ddlDepartments.DataValueField = "DataValue_Name";
                    ddlDepartments.Items.Add(new ListItem() { Text = "All", Value = "All" });
                    ddlDepartments.DataBind();

                }

                else if (this.PageTitle == "OPDPrivateDetail" || this.PageTitle == "HospitalServices")
                {
                    tr1MedicalSubsidy.Visible = false;
                    lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = true;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    optRw.Visible = false;
                    ddlShift.Visible = false;
                    lbShift.Visible = false;
                    tr_Export.Visible = false;
                    tr_Summary.Visible = false;
                    if (this.PageTitle == "HospitalServices")
                    {
                        string x = "Hospital Services";
                        Master.Label2.Text = x;
                        Master.GetMenuName();
                        object valusets;
                        valusets = DBClass.GetValueSet("Patient Type");
                        ddlDepartments.DataSource = valusets;
                        ddlDepartments.DataTextField = "DataValue_Description";
                        ddlDepartments.DataValueField = "DataValue_Name";
                        ddlDepartments.Items.Add(new ListItem() { Text = "All", Value = "All" });
                        ddlDepartments.DataBind();
                        ddlDepartments.Visible = true;
                        lblDepartment.Visible = true;
                        lblDepartment.Text = "Patient Type";
                        lblTestName.Visible = false;
                        ddlTestName.Visible = false;
                        lblMultiSelect.Visible = false;
                        optRw.Visible = true;
                        DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                        valusets = from d in db.aspnet_Users
                                   select new { d.UserName, d.UserId };
                        ddloprators.DataSource = valusets;
                        ddloprators.DataTextField = "UserName";
                        ddloprators.DataValueField = "UserId";
                        ddloprators.Items.Add(new ListItem() { Text = "All", Value = "0" });
                        ddloprators.DataBind();
                        DateDiv.Visible = true;
                        Time_Row.Visible = true;
                        lblPatientType.Visible = true;
                        lblPatientType.Text = "Test Name";
                        ddlPatientType.Visible = true;
                        var serviceList = (from sl in db.INV_Items
                                           where
                                           sl.Services == true
                                           select new { sl.Item_ID, sl.Description }).ToList();

                        ddlPatientType.DataSource = serviceList;
                        ddlPatientType.DataValueField = "Item_ID";
                        ddlPatientType.DataTextField = "Description";
                        ddlPatientType.Items.Add(new ListItem() { Text = "All", Value = "0" });
                        ddlPatientType.DataBind();
                        tr_Export.Visible = true;
                    }
                    trDoctor.Visible = false;

                    SetDepartent();

                }
                else if (PageTitle == "AdvanceReport")
                {
                    string x = "Advance Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    optRw.Visible = false;
                    trDoctor.Visible = false;
                    tr_Summary.Visible = false;
                    lblMainDepartment.Visible = false;
                    dpROw.Visible = false;
                    AllowPatientRecord = false;
                    ddlShift.Visible = false;
                    lbShift.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                }

                else if (PageTitle == "RefundReport")
                {
                    string x = "Refund Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    trDoctor.Visible = true;
                    tr_Summary.Visible = false;
                    ddlReportType.Visible = false;
                    lbservieType.Visible = false;
                    lblMainDepartment.Visible = false;
                    dpROw.Visible = false;
                    AllowPatientRecord = false;
                    optRw.Visible = true;
                    ddlShift.Visible = false;
                    lbShift.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;

                    tr1MedicalSubsidy.Visible = true;
                    lblMedical.Text = "Department";
                    ddlMedicalSubsidy.Items.Clear();
                    ddlMedicalSubsidy.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlMedicalSubsidy.Items.Add("OPD");
                    ddlMedicalSubsidy.Items.Add("Billing");

                    object valusets;
                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = from d in db.aspnet_Users
                               select new { d.UserName, d.UserId };
                    ddloprators.DataSource = valusets;
                    ddloprators.DataTextField = "UserName";
                    ddloprators.DataValueField = "UserId";
                    ddloprators.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddloprators.DataBind();


                    DataTable dt = DBClass.getDataTable("select * from HR_Employees where IsDoctor=1");
                    ddlDoctor.DataSource = dt;
                    ddlDoctor.DataValueField = "Emp_ID";
                    ddlDoctor.DataTextField = "Emp_Name";
                    ddlDoctor.Items.Add(new ListItem() { Value = "0", Text = "All Doctors" });
                    ddlDoctor.DataBind();

                }

                else if (PageTitle == "CancelBill")
                {
                    string x = "Cancel Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    optRw.Visible = false;
                    trDoctor.Visible = false;
                    tr_Summary.Visible = false;
                    lblMainDepartment.Visible = false;
                    dpROw.Visible = false;
                    AllowPatientRecord = false;
                    ddlShift.Visible = false;
                    lbShift.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                }

                else if (PageTitle == "ReceiptCollectionReport")
                {
                    string x = "Receipt Colletion Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    optRw.Visible = false;
                    trDoctor.Visible = false;
                    tr_Summary.Visible = false;
                    lblMainDepartment.Visible = false;
                    dpROw.Visible = false;
                    AllowPatientRecord = false;
                    ddlShift.Visible = false;
                    lbShift.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                }
                else if (this.PageTitle == "PharmacySaleReport_PaymentWise")
                {
                    string x = "Pharmacy Sale Report Payment Type Wise";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    optRw.Visible = false;
                    trDoctor.Visible = false;
                    trSearch1.Visible = true;
                    lblMainDepartment.Visible = false;
                    dpROw.Visible = false;
                    ddlReportType.Visible = false;
                    txtMRNo.Visible = false;
                    lblMRNo.Visible = false;
                    tr_Export.Visible = false;
                    ddlShift.Visible = false;
                    lbShift.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    if (AllowPatientRecord)
                    {
                        optRw.Visible = true;
                        DataTable dt1 = DBClass.getDataTable("select * from Pharmacy_Users where isActive=1");
                        ddloprators.DataSource = dt1;
                        ddloprators.DataTextField = "UserName";
                        ddloprators.DataValueField = "UserID";
                        ddloprators.Items.Add(new ListItem() { Text = "All", Value = "0" });
                        ddloprators.DataBind();
                    }
                    // ADDING NEW WAREHOUSE
                    object valuset;
                    ddlwareHouse.DataSource = GetUserWarehouses();
                    ddlwareHouse.DataTextField = "Text";
                    ddlwareHouse.DataValueField = "Value";
                    ddlwareHouse.Items.Clear();
                    ddlwareHouse.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlwareHouse.DataBind();
                    Stock_Movement.Visible = true;


                    ddlwareHouse.Visible = true;
                    lblWarehouse.Visible = true;

                    lbItemCategory.Visible = false;
                    ddlItemCategory.Visible = false;




                    DataBaseDataContext dbs = new DataBaseDataContext(DBClass.ConnectionString());
                    var serviceList = (from sl in dbs.INV_Items
                                       where sl.Active == true && sl.IsPharmacyItem == true
                                       select new { sl.Item_ID, sl.Description }).ToList();
                    ddlItemName.DataSource = serviceList;
                    ddlItemName.DataValueField = "Item_ID";
                    ddlItemName.DataTextField = "Description";
                    ddlItemName.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlItemName.DataBind();


                    trPayment.Visible = true;
                    ddlPaymentType.Items.Clear();
                    ddlPaymentType.Items.Add(new ListItem("All", "0"));
                    ddlPaymentType.Items.Add(new ListItem("Cash", "1"));
                    ddlPaymentType.Items.Add(new ListItem("Credit", "2"));
                    ddlPaymentType.Items.Add(new ListItem("Panel", "3"));

                }
                else if (this.PageTitle == "PharmacySaleReport")
                {
                    string x = "Pharmacy Sale Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    optRw.Visible = false;
                    trDoctor.Visible = false;
                    tr_Summary.Visible = true;
                    trSearch1.Visible = true;
                    lblMainDepartment.Visible = false;
                    dpROw.Visible = false;
                    ddlReportType.Visible = false;
                    txtMRNo.Visible = false;
                    lblMRNo.Visible = false;
                    tr_Export.Visible = true;
                    ddlShift.Visible = false;
                    lbShift.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    if (AllowPatientRecord)
                    {
                        optRw.Visible = true;
                        DataTable dt1 = DBClass.getDataTable("select * from Pharmacy_Users where isActive=1");
                        ddloprators.DataSource = dt1;
                        ddloprators.DataTextField = "UserName";
                        ddloprators.DataValueField = "UserID";
                        ddloprators.Items.Add(new ListItem() { Text = "All", Value = "0" });
                        ddloprators.DataBind();
                    }
                    // ADDING NEW WAREHOUSE
                    object valuset;
                    ddlwareHouse.DataSource = GetUserWarehouses();
                    ddlwareHouse.DataTextField = "Text";
                    ddlwareHouse.DataValueField = "Value";
                    ddlwareHouse.Items.Clear();
                    ddlwareHouse.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlwareHouse.DataBind();
                    Stock_Movement.Visible = true;


                    ddlwareHouse.Visible = true;
                    lblWarehouse.Visible = true;

                    lbItemCategory.Visible = false;
                    ddlItemCategory.Visible = false;



                    DataBaseDataContext dbs = new DataBaseDataContext(DBClass.ConnectionString());
                    var serviceList = (from sl in dbs.INV_Items
                                       where sl.Active == true && sl.IsPharmacyItem == true
                                       select new { sl.Item_ID, sl.Description }).ToList();

                    ddlItemName.DataSource = serviceList;
                    ddlItemName.DataValueField = "Item_ID";
                    ddlItemName.DataTextField = "Description";
                    ddlItemName.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlItemName.DataBind();


                }
                else if (this.PageTitle == "CathLabStockInHand")
                {
                    string x = "Cath Lab Stock in Hand Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();

                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    rowStock.Visible = true;

                    // ADDING NEW WAREHOUSE
                    DataBaseDataContext dbs = new DataBaseDataContext(DBClass.ConnectionString());
                    var allowedWarehouses = new List<string> { "009", "010" };
                    var valueSet = (from dv in dbs.DataValues
                                    where dv.ValueSet_ID == 8 && allowedWarehouses.Contains(dv.DataValue_Name)
                                    select new { dv.DataValue_Name, dv.DataValue_Description }).ToList();
                    ddlwareHouse.DataSource = valueSet;
                    ddlwareHouse.DataValueField = "DataValue_Name";
                    ddlwareHouse.DataTextField = "DataValue_Description";
                    ddlwareHouse.Items.Clear();
                    ddlwareHouse.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlwareHouse.DataBind();


                    Stock_Movement.Visible = true;

                    ddlwareHouse.Visible = true;
                    lblWarehouse.Visible = true;

                    lbItemCategory.Visible = false;
                    ddlItemCategory.Visible = false;
                }

                else if (this.PageTitle == "ChargePolicyWiseSummary")
                {
                    string x = "Charge Policy Summary";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    //lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    optRw.Visible = false;
                    lblMainDepartment.Visible = true;
                    ddlMainDepartment.Visible = true;
                    lblMainDepartment.Text = "Charge Policy";
                    trDoctor.Visible = false;
                    tr_Summary.Visible = false;

                    dpROw.Visible = false;
                    AllowPatientRecord = false;
                    object valusets;

                    tr1MedicalSubsidy.Visible = false;
                    valusets = DBClass.GetValueSet("Charge Policy");
                    ddlMainDepartment.DataSource = valusets;
                    ddlMainDepartment.DataTextField = "DataValue_Description";
                    ddlMainDepartment.DataValueField = "DataValue_Name";
                    ddlMainDepartment.Items.Add(new ListItem() { Text = "All", Value = "All" });
                    ddlMainDepartment.DataBind();

                }
                else if (PageTitle == "ConsolidateMedicalSubsidy")
                {
                    string x = "Consolidate Medical Subsidy";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr1MedicalSubsidy.Visible = true;
                    lblMedical.Visible = true;
                    ddlMedicalSubsidy.Visible = true;
                    lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = true;
                    lblPatientType.Visible = true;
                    ddlPatientType.Visible = false;
                    optRw.Visible = false;
                    trDoctor.Visible = false;
                    object valusets;
                    valusets = DBClass.GetValueSet("Patient Type");
                    lblMultiSelect.DataSource = valusets;
                    lblMultiSelect.DataTextField = "DataValue_Description";
                    lblMultiSelect.DataValueField = "DataValue_Name";
                    lblMultiSelect.Items.Add(new ListItem() { Text = "Please Select", Value = "0" });
                    lblMultiSelect.DataBind();
                    //
                    lblTestName.Visible = true;
                    ddlTestName.Visible = true;
                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    var serviceList = (from sl in db.INV_Items
                                       where
                                       sl.Hospital_Services == true
                                       select new { sl.Item_ID, sl.Description }).ToList();

                    ddlTestName.DataSource = serviceList;

                    ddlTestName.DataValueField = "Item_ID";
                    ddlTestName.DataTextField = "Description";
                    ddlTestName.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlTestName.DataBind();
                    SetDepartent();

                }
                //else if (PageTitle == "Patient_Trans_Detail")
                //{
                //    string x = "Patient Trans Detail";
                //    Master.Label2.Text = x;
                //    Master.GetMenuName();
                //    //tblParameters.Visible = false;
                //    MRDiv.Visible = true;
                //    lblMRNo.Visible = true;
                //    txtMRNo.Visible = true;
                //    DateDiv.Visible = true;
                //    Time_Row.Visible = true;
                //    lblMainDepartment.Visible = false;
                //    ddlDepartments.Visible = false;
                //    lblPatientType.Visible = false;
                //    lblMultiSelect.Visible = false;
                //    ddlPatientType.Visible = false;
                //    optRw.Visible = false;
                //    trDoctor.Visible = false;
                //    tr_Summary.Visible = false;

                //    lblMainDepartment.Visible = false;
                //    dpROw.Visible = false;
                //}
                if (PageTitle == "Departmentwise_Cash_Summary")
                {
                    string x = "Department Cash Summary";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    optRw.Visible = false;
                    trDoctor.Visible = false;
                    tr_Summary.Visible = false;

                    lblMainDepartment.Visible = false;
                    dpROw.Visible = false;
                }
                if (PageTitle == "Lab_Test_Investigation")
                {
                    string x = "Lab Test Investigation";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    object valusets;
                    lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = true;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    optRw.Visible = false;
                    trDoctor.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    tr_Summary.Visible = false;
                    lblMainDepartment.Visible = false;
                    tr1MedicalSubsidy.Visible = false;
                    lblMedical.Visible = false;
                    AllowPatientRecord = false;
                    ddlMedicalSubsidy.Visible = false;
                    test_Cat.Visible = true;
                    dpROw.Visible = true;
                    tr_Export.Visible = true;
                    DataBaseDataContext dbase = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = (from p in dbase.DataValues where p.ValueSet_ID == 67 select new { p.DataValue_Name, p.DataValue_Description }).ToList();
                    ddlDepartments.DataSource = valusets;
                    ddlDepartments.DataTextField = "DataValue_Description";
                    ddlDepartments.DataValueField = "DataValue_Name";
                    ddlDepartments.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlDepartments.DataBind();

                    valusets = DBClass.GetValueSet("Test Catagory");
                    ddlcatagory.DataSource = valusets;
                    ddlcatagory.DataTextField = "DataValue_Description";
                    ddlcatagory.DataValueField = "DataValue_Name";
                    ddlcatagory.Items.Add(new ListItem() { Text = "Please Select", Value = "0" });
                    ddlcatagory.DataBind();

                    lblMedical.Text = "Result";
                    ddlMedicalSubsidy.Items.Clear();
                    ddlMedicalSubsidy.Items.Add(new ListItem() { Text = "All", Value = "All" });
                    ddlMedicalSubsidy.Items.Add(new ListItem() { Text = "Yes", Value = "1" });
                    ddlMedicalSubsidy.Items.Add(new ListItem() { Text = "No", Value = "0" });
                    ddlMedicalSubsidy.DataBind();
                }




                if (this.PageTitle == "Bed_Allocation_Report")
                {
                    string x = "Bed Allocation Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    optRw.Visible = false;
                    trDoctor.Visible = false;
                    tr_Summary.Visible = false;
                    tr_Export.Visible = true;

                    lblMainDepartment.Visible = false;
                    dpROw.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = false;
                    txtStart_Date.Visible = false;
                    sttDate.Visible = false;
                    Time_Row.Visible = false;
                }
                if (this.PageTitle == "OutSourceTestDetail")
                {
                    string x = "Outsource Detail";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    dpROw.Visible = false;
                    lblMainDepartment.Text = "Out Source Labs";
                    ddlTestName.Visible = false;
                    lblTestName.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    trDoctor.Visible = false;
                    Time_Row.Visible = false;
                    tr_Summary.Visible = false;
                }
                if (this.PageTitle == "Discharge_Detail" || this.PageTitle == "Discharge_Time_Line_Detail")
                {
                    object valusets;
                    lblMainDepartment.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    ddlDepartments.Visible = false;
                    lblMainDepartment.Visible = false;
                    trDoctor.Visible = false;

                    lblMainDepartment.Visible = false;


                    if (this.PageTitle == "Discharge_Detail")
                    {
                        string x = "Dischare Detail";
                        Master.Label2.Text = x;
                        Master.GetMenuName();
                        tr1MedicalSubsidy.Visible = true;
                        dpROw.Visible = true;
                        ddlShift.Visible = false;
                        lbShift.Visible = false;
                        tr_Summary.Visible = true;
                        tr_Export.Visible = true;
                        lblMainDepartment.Visible = false;
                        ddlDepartments.Visible = true;
                        lblPatientType.Visible = true;
                        ddlPatientType.Visible = true;
                        lblMultiSelect.Visible = false;
                        DateDiv.Visible = true;
                        Time_Row.Visible = true;
                        valusets = DBClass.GetValueSet("Patient Type");
                        ddlPatientType.DataSource = valusets;
                        ddlPatientType.DataTextField = "DataValue_Description";
                        ddlPatientType.DataValueField = "DataValue_Name";
                        ddlPatientType.Items.Add(new ListItem() { Text = "Please Select", Value = "0" });
                        ddlPatientType.DataBind();
                        DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                        valusets = (from p in db.DataValues where p.ValueSet_ID == 9 select new { p.DataValue_Name, p.DataValue_Description }).ToList();
                        ddlDepartments.DataSource = valusets;
                        ddlDepartments.DataTextField = "DataValue_Description";
                        ddlDepartments.DataValueField = "DataValue_Name";
                        ddlDepartments.Items.Add(new ListItem() { Text = "Please Select", Value = "0" });
                        ddlDepartments.DataBind();
                    }

                    //else if (this.PageTitle == "OPD_Detail_Report")
                    //{
                    //    string x = "OPD Detail Report";
                    //    Master.Label2.Text = x;
                    //    Master.GetMenuName();
                    //    tr1MedicalSubsidy.Visible = true;
                    //    dpROw.Visible = true;
                    //    SetDepartent();
                    //    ddlMedicalSubsidy.Visible = false;
                    //    lblMedical.Visible = false;
                    //    ddlShift.Visible = false;
                    //    lbShift.Visible = false;
                    //    tr_Export.Visible = false;
                    //    trDoctor.Visible = false;
                    //    tr_Summary.Visible = false;
                    //    DataTable dt = DBClass.getDataTable("select * from HR_Employees where IsDoctor=1");
                    //    ddlDoctor.DataSource = dt;
                    //    ddlDoctor.DataValueField = "Emp_ID";
                    //    ddlDoctor.DataTextField = "Emp_Name";
                    //    ddlDoctor.Items.Add(new ListItem() { Value = "0", Text = "All Doctors" });
                    //    ddlDoctor.DataBind();

                    //    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    //    valusets = (from p in db.DataValues where p.ValueSet_ID == 3162 orderby p.DataValue_Description select new { p.DataValue_Name, p.DataValue_Description }).ToList();
                    //    ddlFilterClinic.DataSource = valusets;
                    //    ddlFilterClinic.DataTextField = "DataValue_Description";
                    //    ddlFilterClinic.DataValueField = "DataValue_Name";
                    //    ddlFilterClinic.Items.Add(new ListItem() { Text = "Please Select", Value = "0" });
                    //    ddlFilterClinic.DataBind();
                    //    op_FilterClinic.Visible = true;
                    //    ddlReportType.Visible = false;
                    //    lbservieType.Visible = false;
                    //    optRw.Visible = false;
                    //    ddloprators.Visible = false;
                    //    lboperator.Visible = false;
                    //    ddlPatientType.Visible = true;
                    //    lblPatientType.Visible = true;
                    //    lblPatientType.Text = "Operators";
                    //    if (AllowPatientRecord)
                    //    {
                    //        valusets = null;

                    //        valusets = from d in db.aspnet_Users
                    //                   select new { d.UserName, d.UserId };
                    //        ddlPatientType.DataSource = valusets;
                    //        ddlPatientType.DataTextField = "UserName";
                    //        ddlPatientType.DataValueField = "UserId";
                    //        ddlPatientType.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    //        ddlPatientType.DataBind();
                    //    }
                    //}


                    else if (this.PageTitle == "Discharge_Time_Line_Detail")
                    {
                        string x = "Discharge TimeLine";
                        Master.Label2.Text = x;
                        Master.GetMenuName();
                        tr1MedicalSubsidy.Visible = false;
                        optRw.Visible = false;
                        tr_Summary.Visible = false;

                        AllowPatientRecord = false;
                        ddlDepartments.Visible = true;


                        DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                        valusets = (from p in db.DataValues where p.ValueSet_ID == 9 orderby p.DataValue_Description select new { p.DataValue_Name, p.DataValue_Description }).ToList();
                        ddlDepartments.DataSource = valusets;
                        ddlDepartments.DataTextField = "DataValue_Description";
                        ddlDepartments.DataValueField = "DataValue_Name";
                        ddlDepartments.Items.Add(new ListItem() { Text = "Please Select", Value = "0" });
                        ddlDepartments.DataBind();
                    }

                    if (AllowPatientRecord)
                    {
                        valusets = null;
                        optRw.Visible = true;
                        DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                        valusets = from d in db.aspnet_Users
                                   select new { d.UserName, d.UserId };
                        ddloprators.DataSource = valusets;
                        ddloprators.DataTextField = "UserName";
                        ddloprators.DataValueField = "UserId";
                        ddloprators.Items.Add(new ListItem() { Text = "All", Value = "0" });
                        ddloprators.DataBind();
                    }
                }
                if (this.PageTitle == "IPDDoctorShareReport")
                {
                    string x = "IPD Doctor Share Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr1MedicalSubsidy.Visible = true;
                    dpROw.Visible = true;
                    ddlShift.Visible = false;
                    lbShift.Visible = false;
                    tr_Summary.Visible = false;
                    tr_Export.Visible = true;
                    lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = true;
                    lblPatientType.Visible = true;
                    ddlPatientType.Visible = true;
                    lblMultiSelect.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    tr1MedicalSubsidy.Visible = false;
                    ddlMedicalSubsidy.Visible = false;
                    optRw.Visible = true;
                    object valuesets;

                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    valuesets = from d in db.aspnet_Users
                                select new { d.UserName, d.UserId };
                    ddloprators.DataSource = valuesets;
                    ddloprators.DataTextField = "UserName";
                    ddloprators.DataValueField = "UserId";
                    ddloprators.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddloprators.DataBind();

                    object valusets;
                    DataBaseDataContext dc = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = (from p in dc.DataValues where p.ValueSet_ID == 9 select new { p.DataValue_Name, p.DataValue_Description }).ToList();
                    ddlDepartments.DataSource = valusets;
                    ddlDepartments.DataTextField = "DataValue_Description";
                    ddlDepartments.DataValueField = "DataValue_Name";
                    ddlDepartments.Items.Add(new ListItem() { Text = "Please Select", Value = "0" });
                    ddlDepartments.DataBind();

                    DataTable dt = DBClass.getDataTable("select * from HR_Employees where IsDoctor=1");
                    ddlDoctor.DataSource = dt;
                    ddlDoctor.DataValueField = "Emp_ID";
                    ddlDoctor.DataTextField = "Emp_Name";
                    ddlDoctor.Items.Add(new ListItem() { Value = "0", Text = "All Doctors" });
                    ddlDoctor.DataBind();
                    lblMultiSelect.Visible = false;
                    trDoctor.Visible = true;

                    lblPatientType.Visible = true;
                    lblPatientType.Text = "Patient Type";
                    //object valusests;
                    //valusests = DBClass.GetValueSet("Mode Of Registration");
                    //ddlPatientType.DataSource = valusests;
                    //ddlPatientType.DataTextField = "DataValue_Description";
                    //ddlPatientType.DataValueField = "DataValue_Name";
                    //ddlPatientType.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    //ddlPatientType.DataBind();
                    //ddlPatientType.Visible = true;
                    object valusests;
                    ddlPatientType.Items.Clear();
                    ddlPatientType.Items.Add(new ListItem("IPD", "03"));
                    ddlPatientType.SelectedValue = "03";
                    ddlPatientType.Enabled = false;   // Optional: prevent user from changing it
                    ddlPatientType.Visible = true;
                }
                if (this.PageTitle == "DoctorShare_Report")
                {
                    string x = "Doctor Share Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr1MedicalSubsidy.Visible = true;
                    dpROw.Visible = true;
                    ddlShift.Visible = false;
                    lbShift.Visible = false;
                    tr_Summary.Visible = true;
                    tr_Export.Visible = true;
                    lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = true;
                    lblPatientType.Visible = true;
                    ddlPatientType.Visible = true;
                    lblMultiSelect.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    tr1MedicalSubsidy.Visible = false;
                    ddlMedicalSubsidy.Visible = false;
                    optRw.Visible = true;
                    object valuesets;

                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    valuesets = from d in db.aspnet_Users
                                select new { d.UserName, d.UserId };
                    ddloprators.DataSource = valuesets;
                    ddloprators.DataTextField = "UserName";
                    ddloprators.DataValueField = "UserId";
                    ddloprators.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddloprators.DataBind();

                    object valusets;
                    valusets = DBClass.GetValueSet("Patient Type");
                    ddlPatientType.DataSource = valusets;
                    ddlPatientType.DataTextField = "DataValue_Description";
                    ddlPatientType.DataValueField = "DataValue_Name";
                    ddlPatientType.Items.Add(new ListItem() { Text = "Please Select", Value = "0" });
                    ddlPatientType.DataBind();

                    DataBaseDataContext dc = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = (from p in dc.DataValues where p.ValueSet_ID == 9 select new { p.DataValue_Name, p.DataValue_Description }).ToList();
                    ddlDepartments.DataSource = valusets;
                    ddlDepartments.DataTextField = "DataValue_Description";
                    ddlDepartments.DataValueField = "DataValue_Name";
                    ddlDepartments.Items.Add(new ListItem() { Text = "Please Select", Value = "0" });
                    ddlDepartments.DataBind();

                    DataTable dt = DBClass.getDataTable("select * from HR_Employees where IsDoctor=1");
                    ddlDoctor.DataSource = dt;
                    ddlDoctor.DataValueField = "Emp_ID";
                    ddlDoctor.DataTextField = "Emp_Name";
                    ddlDoctor.Items.Add(new ListItem() { Value = "0", Text = "All Doctors" });
                    ddlDoctor.DataBind();
                    lblMultiSelect.Visible = false;
                    trDoctor.Visible = true;
                }


                if (this.PageTitle == "Package_Detail")
                {
                    string x = "Package Detail";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr1MedicalSubsidy.Visible = true;
                    lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    optRw.Visible = false;
                    trDoctor.Visible = false;

                    lblMainDepartment.Visible = false;
                    dpROw.Visible = false;
                }
                if (this.PageTitle == "Procedure_Detail" || this.PageTitle == "Private_Procedure_Detail")
                {

                    lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    optRw.Visible = false;
                    trDoctor.Visible = false;

                    SetDepartent();
                    //----update

                    object valusets;
                    if (AllowPatientRecord)
                    {
                        optRw.Visible = true;
                        DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                        valusets = from d in db.aspnet_Users
                                   select new { d.UserName, d.UserId };
                        ddloprators.DataSource = valusets;
                        ddloprators.DataTextField = "UserName";
                        ddloprators.DataValueField = "UserId";
                        ddloprators.Items.Add(new ListItem() { Text = "All", Value = "0" });
                        ddloprators.DataBind();
                    }
                    if (this.PageTitle == "Procedure_Detail")
                    {
                        string x = "Procedure Detail";
                        Master.Label2.Text = x;
                        Master.GetMenuName();
                        tr1MedicalSubsidy.Visible = true;
                    }

                    //----- end update
                }
                //if (this.PageTitle == "Procedure_Time_Line_Detail")
                //{
                //    string x = "Procedure Time Line Detail";
                //    Master.Label2.Text = x;
                //    Master.GetMenuName();
                //    lblMainDepartment.Visible = false;
                //    Time_Row.Visible = true;
                //    DateDiv.Visible = true;
                //    trProcedure1.Visible = true;
                //    ddlDepartments.Visible = false;
                //    lblPatientType.Visible = false;
                //    lblMultiSelect.Visible = false;
                //    ddlPatientType.Visible = false;
                //    optRw.Visible = false;
                //    trDoctor.Visible = false;
                //    tr1MedicalSubsidy.Visible = true;
                //    tr_Summary.Visible = false;

                //    AllowPatientRecord = false;

                //    lblMedical.Text = "Patient Type";
                //    ddlMedicalSubsidy.Items.Clear();
                //    ddlMedicalSubsidy.Items.Add(new ListItem() { Text = "All", Value = "All" });
                //    ddlMedicalSubsidy.Items.Add(new ListItem() { Text = "General", Value = "1" });
                //    ddlMedicalSubsidy.Items.Add(new ListItem() { Text = "Private", Value = "2" });
                //    ddlMedicalSubsidy.DataBind();
                //    SetDepartent();
                //    trSearch1.Visible = true;

                //    DataTable dt = DBClass.getDataTable("select * from inv_items");
                //    ddlItemName.DataSource = dt;
                //    ddlItemName.DataValueField = "Item_ID";
                //    ddlItemName.DataTextField = "Description";
                //    ddlItemName.Items.Add(new ListItem() { Text = "All", Value = "0" });
                //    ddlItemName.DataBind();

                //    object valuset;
                //    valuset = DBClass.GetValueSet("Procedure Types");
                //    ddlProcedure.DataSource = valuset;
                //    ddlProcedure.DataTextField = "DataValue_Description";
                //    ddlProcedure.DataValueField = "DataValue_Name";
                //    ddlProcedure.Items.Clear();
                //    ddlProcedure.Items.Add(new ListItem() { Text = "All", Value = "0" });
                //    ddlProcedure.DataBind();

                //    // appending the OPD IPD 
                //    ddOPDIPDdiv.Visible = true;


                //}
                if (this.PageTitle == "PrivateAdmition_Detail")
                {
                    string x = "Private Admition Detail";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    trDoctor.Visible = false;

                    lblMainDepartment.Visible = false;
                    dpROw.Visible = false;
                    SetDepartent();
                }

                if (this.PageTitle == "Advance_Detail")
                {
                    string x = "Advance Detail";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    lblMultiSelect.Visible = false;
                    lblPatientType.Visible = true;
                    ddlPatientType.Visible = true;
                    optRw.Visible = false;
                    trDoctor.Visible = false;

                    lblMainDepartment.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    tr_Summary.Visible = false;
                    object valusets;
                    dpROw.Visible = true;
                    tr_Export.Visible = true;
                    ddlDepartments.Visible = true;

                    valusets = DBClass.GetValueSet("Patient Type");
                    ddlPatientType.DataSource = valusets;
                    ddlPatientType.DataTextField = "DataValue_Description";
                    ddlPatientType.DataValueField = "DataValue_Name";
                    ddlPatientType.Items.Add(new ListItem() { Text = "Please Select", Value = "0" });
                    ddlPatientType.DataBind();

                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = (from p in db.DataValues where p.ValueSet_ID == 9 select new { p.DataValue_Name, p.DataValue_Description }).ToList();
                    ddlDepartments.DataSource = valusets;
                    ddlDepartments.DataTextField = "DataValue_Description";
                    ddlDepartments.DataValueField = "DataValue_Name";
                    ddlDepartments.Items.Add(new ListItem() { Text = "Please Select", Value = "0" });
                    ddlDepartments.DataBind();
                }
                if (this.PageTitle == "ReportVoucher")
                {
                    string x = "Report Voucher Detail";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    lblMultiSelect.Visible = false;
                    lblPatientType.Visible = false;
                    ddlPatientType.Visible = false;   // turned it into false 
                    optRw.Visible = false;
                    trDoctor.Visible = false;

                    lblMainDepartment.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    tr_Summary.Visible = false;
                    object valusets;
                    dpROw.Visible = true;
                    tr_Export.Visible = true;
                    ddlDepartments.Visible = true;

                    valusets = DBClass.GetValueSet("Patient Type");
                    ddlPatientType.DataSource = valusets;
                    ddlPatientType.DataTextField = "DataValue_Description";
                    ddlPatientType.DataValueField = "DataValue_Name";
                    ddlPatientType.Items.Add(new ListItem() { Text = "Please Select", Value = "0" });
                    ddlPatientType.DataBind();

                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = (from p in db.DataValues where p.ValueSet_ID == 9 select new { p.DataValue_Name, p.DataValue_Description }).ToList();
                    ddlDepartments.DataSource = valusets;
                    ddlDepartments.DataTextField = "DataValue_Description";
                    ddlDepartments.DataValueField = "DataValue_Name";
                    ddlDepartments.Items.Add(new ListItem() { Text = "Please Select", Value = "0" });
                    ddlDepartments.DataBind();
                }
                if (this.PageTitle == "Patient_Count_Department_Wise")
                {
                    string x = "Patients Department Wise Detail";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    lblMultiSelect.Visible = false;
                    lblPatientType.Visible = false;
                    ddlPatientType.Visible = false;   // turned it into false 
                    optRw.Visible = false;
                    trDoctor.Visible = false;

                    lblMainDepartment.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    tr_Summary.Visible = false;
                    object valusets;
                    dpROw.Visible = true;
                    tr_Export.Visible = true;
                    ddlDepartments.Visible = false;

                    valusets = DBClass.GetValueSet("Patient Type");
                    ddlPatientType.DataSource = valusets;
                    ddlPatientType.DataTextField = "DataValue_Description";
                    ddlPatientType.DataValueField = "DataValue_Name";
                    ddlPatientType.Items.Add(new ListItem() { Text = "Please Select", Value = "0" });
                    ddlPatientType.DataBind();

                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = (from p in db.DataValues where p.ValueSet_ID == 9 select new { p.DataValue_Name, p.DataValue_Description }).ToList();
                    ddlDepartments.DataSource = valusets;
                    ddlDepartments.DataTextField = "DataValue_Description";
                    ddlDepartments.DataValueField = "DataValue_Name";
                    ddlDepartments.Items.Add(new ListItem() { Text = "Please Select", Value = "0" });
                    ddlDepartments.DataBind();
                }
                if (this.PageTitle == "TestWiseMonthlyLabTestDepartment")
                {
                    string x = "Test Wise Monthly Department Detail";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    lblMultiSelect.Visible = false;
                    lblPatientType.Visible = false;
                    ddlPatientType.Visible = false;   // turned it into false 
                    optRw.Visible = false;
                    trDoctor.Visible = false;

                    lblMainDepartment.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    tr_Summary.Visible = false;
                    object valusets;
                    dpROw.Visible = true;
                    tr_Export.Visible = true;
                    ddlDepartments.Visible = true;

                    valusets = DBClass.GetValueSet("Patient Type");
                    ddlPatientType.DataSource = valusets;
                    ddlPatientType.DataTextField = "DataValue_Description";
                    ddlPatientType.DataValueField = "DataValue_Name";
                    ddlPatientType.Items.Add(new ListItem() { Text = "Please Select", Value = "0" });
                    ddlPatientType.DataBind();

                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = (from p in db.DataValues where p.ValueSet_ID == 9 select new { p.DataValue_Name, p.DataValue_Description }).ToList();
                    ddlDepartments.DataSource = valusets;
                    ddlDepartments.DataTextField = "DataValue_Description";
                    ddlDepartments.DataValueField = "DataValue_Name";
                    ddlDepartments.Items.Add(new ListItem() { Text = "Please Select", Value = "0" });
                    ddlDepartments.DataBind();
                }
                if (this.PageTitle == "Stock_In_Hand_Detail")
                {
                    string x = "Stock in Hand Detail";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    lblMultiSelect.Visible = false;
                    lblPatientType.Visible = false;
                    ddlPatientType.Visible = false;   // turned it into false 
                    optRw.Visible = false;
                    trDoctor.Visible = false;

                    lblMainDepartment.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    tr_Summary.Visible = false;
                    object valusets;
                    dpROw.Visible = true;
                    tr_Export.Visible = true;
                    ddlDepartments.Visible = true;

                    //valusets = DBClass.GetValueSet("Patient Type");
                    //ddlPatientType.DataSource = valusets;
                    //ddlPatientType.DataTextField = "DataValue_Description";
                    //ddlPatientType.DataValueField = "DataValue_Name";
                    //ddlPatientType.Items.Add(new ListItem() { Text = "Please Select", Value = "0" });
                    //ddlPatientType.DataBind();

                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = (from p in db.DataValues where p.ValueSet_ID == 9 select new { p.DataValue_Name, p.DataValue_Description }).ToList();
                    ddlDepartments.DataSource = valusets;
                    ddlDepartments.DataTextField = "DataValue_Description";
                    ddlDepartments.DataValueField = "DataValue_Name";
                    ddlDepartments.Items.Add(new ListItem() { Text = "Please Select", Value = "0" });
                    ddlDepartments.DataBind();
                }

                if (PageTitle == "Admission_Detail")
                {
                    string x = "Admission Detail";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    lbProcedure.Visible = true;
                    lbProcedure.Text = "Patient Type";
                    ddlProcedure.Visible = true;
                    trProcedure1.Visible = true;
                    optRw.Visible = false;
                    trDoctor.Visible = false;
                    tr_Summary.Visible = true;
                    tr_Export.Visible = true;
                    ddlShift.Visible = false;
                    lbShift.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    lblMainDepartment.Visible = false;
                    dpROw.Visible = false;
                    object valusets;
                    valusets = DBClass.GetValueSet("Patient Type");
                    ddlProcedure.DataSource = valusets;
                    ddlProcedure.DataTextField = "DataValue_Description";
                    ddlProcedure.DataValueField = "DataValue_Name";
                    ddlProcedure.Items.Add(new ListItem() { Text = "All", Value = "All" });
                    ddlProcedure.DataBind();

                    //----update

                    //object valusets;
                    if (AllowPatientRecord)
                    {
                        optRw.Visible = true;
                        DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                        valusets = from d in db.aspnet_Users
                                   select new { d.UserName, d.UserId };
                        ddloprators.DataSource = valusets;
                        ddloprators.DataTextField = "UserName";
                        ddloprators.DataValueField = "UserId";
                        ddloprators.Items.Add(new ListItem() { Text = "All", Value = "0" });
                        ddloprators.DataBind();
                    }
                    //----- end update
                }

                if (PageTitle == "VandorWise_Report")
                {
                    string x = "Vendor Wise Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr_Summary.Visible = false;

                    Time_Row.Visible = false;
                    dpROw.Visible = false;
                    lblMultiSelect.Visible = false;
                    trDoctor.Visible = false;
                    tr_Export.Visible = true;
                }
                if (PageTitle == "StockBalnce_Report")
                {
                    string x = "Stock Balance Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr_Summary.Visible = false;

                    Time_Row.Visible = false;
                    dpROw.Visible = false;
                    lblMultiSelect.Visible = false;
                    trDoctor.Visible = false;
                    tr_Export.Visible = true;
                }
                if (PageTitle == "Oppening_Report")
                {
                    string x = "Opening Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr_Summary.Visible = false;
                    Time_Row.Visible = false;
                    dpROw.Visible = false;
                    lblMultiSelect.Visible = false;
                    trDoctor.Visible = false;
                }
                //if (PageTitle == "DoctorShare_Report")
                //{
                //    string x = "Doctor Share Report";
                //    Master.Label2.Text = x;
                //    Master.GetMenuName();
                //    object valusets;
                //    valusets = DBClass.GetValueSet("Patient Main Category");
                //    ddlDepartments.DataSource = valusets;
                //    ddlDepartments.DataTextField = "DataValue_Description";
                //    ddlDepartments.DataValueField = "DataValue_Name";
                //    ddlDepartments.Items.Add(new ListItem() { Text = "Please Select", Value = "0" });
                //    ddlDepartments.DataBind();

                //    valusets = DBClass.GetValueSet("Share Type");
                //    ddlReportType.DataSource = valusets;
                //    ddlReportType.DataTextField = "DataValue_Description";
                //    ddlReportType.DataValueField = "DataValue_Name";
                //    ddlReportType.Items.Add(new ListItem() { Text = "Please Select", Value = "0" });
                //    ddlReportType.DataBind();

                //    valusets = DBClass.GetValueSet("Patient Type");
                //    ddlPatientType.DataSource = valusets;
                //    ddlPatientType.DataTextField = "DataValue_Description";
                //    ddlPatientType.DataValueField = "DataValue_Name";
                //    ddlPatientType.Items.Add(new ListItem() { Text = "Please Select", Value = "0" });
                //    ddlPatientType.DataBind();



                //    DataTable dt = DBClass.getDataTable("select * from HR_Employees where IsDoctor=1");
                //    ddlDoctor.DataSource = dt;
                //    ddlDoctor.DataValueField = "Emp_ID";
                //    ddlDoctor.DataTextField = "Emp_Name";
                //    ddlDoctor.Items.Add(new ListItem() { Value = "0", Text = "All Doctors" });
                //    ddlDoctor.DataBind();
                //    lblMultiSelect.Visible = false;
                //    trDoctor.Visible = true;
                //    if (AllowPatientRecord)
                //    {
                //        optRw.Visible = true;
                //        DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                //        valusets = from d in db.aspnet_Users
                //                   select new { d.UserName, d.UserId };
                //        ddloprators.DataSource = valusets;
                //        ddloprators.DataTextField = "UserName";
                //        ddloprators.DataValueField = "UserId";
                //        ddloprators.Items.Add(new ListItem() { Text = "All", Value = "0" });
                //        ddloprators.DataBind();
                //    }
                //}
                //if (PageTitle == "Doctotr_Receipts")
                //{
                //    string x = "Doctor Receipts";
                //    Master.Label2.Text = x;
                //    Master.GetMenuName();
                //    tr_Export.Visible = true;
                //    tr_AllPatientRecord.Visible = true;
                //    DateDiv.Visible = true;
                //    Time_Row.Visible = true;
                //    dpROw.Visible = true;

                //    object valusets;
                //    valusets = DBClass.GetValueSet("Patient Main Category");
                //    ddlDepartments.DataSource = valusets;
                //    ddlDepartments.DataTextField = "DataValue_Description";
                //    ddlDepartments.DataValueField = "DataValue_Name";
                //    ddlDepartments.Items.Add(new ListItem() { Text = "Please Select", Value = "0" });
                //    ddlDepartments.DataBind();

                //    valusets = DBClass.GetValueSet("Patient Type");
                //    ddlPatientType.DataSource = valusets;
                //    ddlPatientType.DataTextField = "DataValue_Description";
                //    ddlPatientType.DataValueField = "DataValue_Name";
                //    ddlPatientType.Items.Add(new ListItem() { Text = "Please Select", Value = "0" });
                //    ddlPatientType.DataBind();



                //    DataTable dt = DBClass.getDataTable("select * from HR_Employees where IsDoctor=1");
                //    ddlDoctor.DataSource = dt;
                //    ddlDoctor.DataValueField = "Emp_ID";
                //    ddlDoctor.DataTextField = "Emp_Name";
                //    ddlDoctor.Items.Add(new ListItem() { Value = "0", Text = "All Doctors" });
                //    ddlDoctor.DataBind();
                //    lblMultiSelect.Visible = false;
                //    trDoctor.Visible = true;
                //    if (AllowPatientRecord)
                //    {
                //        optRw.Visible = true;
                //        DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                //        valusets = from d in db.aspnet_Users
                //                   select new { d.UserName, d.UserId };
                //        ddloprators.DataSource = valusets;
                //        ddloprators.DataTextField = "UserName";
                //        ddloprators.DataValueField = "UserId";
                //        ddloprators.Items.Add(new ListItem() { Text = "All", Value = "0" });
                //        ddloprators.DataBind();
                //        lbShift.Visible = false;
                //        ddlShift.Visible = false;
                //    }


                //}
                if (PageTitle == "AllCash_Report")
                {
                    string x = "All Cash Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    dpROw.Visible = false;
                    lblMultiSelect.Visible = false;
                    trDoctor.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    tr_Summary.Visible = false;
                    tr_Export.Visible = true;
                    tr_AllPatientRecord.Visible = true;
                }

                if (PageTitle == "Patients_Receipts")
                {
                    string x = "Patient Department & Type Wise";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    object valusets;
                    valusets = DBClass.GetValueSet("Patient Main Category");
                    ddlDepartments.DataSource = valusets;
                    ddlDepartments.DataTextField = "DataValue_Description";
                    ddlDepartments.DataValueField = "DataValue_Name";
                    ddlDepartments.Items.Add(new ListItem() { Text = "Please Select", Value = "0" });
                    ddlDepartments.DataBind();
                    dpROw.Visible = true;
                    tr_Summary.Visible = true;
                    tr_Export.Visible = true;
                    tr_AllPatientRecord.Visible = true;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    ddlShift.Visible = true;   //turned it on
                    lbShift.Visible = true;    //turned it on
                    valusets = DBClass.GetValueSet("Patient Type");
                    ddlPatientType.DataSource = valusets;
                    ddlPatientType.DataTextField = "DataValue_Description";
                    ddlPatientType.DataValueField = "DataValue_Name";
                    ddlPatientType.Items.Add(new ListItem() { Text = "Please Select", Value = "0" });
                    ddlPatientType.DataBind();

                    DataTable shift = DBClass.getDataTable("select * from HR_Shifts");
                    ddlShift.DataSource = shift;
                    ddlShift.DataValueField = "Shift_ID";
                    ddlShift.DataTextField = "Shift_Name";
                    ddlShift.Items.Add(new ListItem() { Value = "0", Text = "All" });
                    ddlShift.DataBind();

                    DataTable dt = DBClass.getDataTable("select * from HR_Employees where IsDoctor=1");
                    ddlDoctor.DataSource = dt;
                    ddlDoctor.DataValueField = "Emp_ID";
                    ddlDoctor.DataTextField = "Emp_Name";
                    ddlDoctor.Items.Add(new ListItem() { Value = "0", Text = "All Doctors" });
                    ddlDoctor.DataBind();
                    lblMultiSelect.Visible = false;
                    trDoctor.Visible = true;

                    optRw.Visible = true;

                    if (AllowPatientRecord)
                    {
                        optRw.Visible = true;
                        DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                        valusets = from d in db.aspnet_Users
                                   select new { d.UserName, d.UserId };
                        ddloprators.DataSource = valusets;
                        ddloprators.DataTextField = "UserName";
                        ddloprators.DataValueField = "UserId";
                        ddloprators.Items.Add(new ListItem() { Text = "All", Value = "0" });
                        ddloprators.DataBind();
                    }
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = true;
                }
                if (PageTitle == "Doctotr_Receipts")
                {
                    string x = "Doctor Wise Patients";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    object valusets;
                    valusets = DBClass.GetValueSet("Patient Main Category");
                    ddlDepartments.DataSource = valusets;
                    ddlDepartments.DataTextField = "DataValue_Description";
                    ddlDepartments.DataValueField = "DataValue_Name";
                    ddlDepartments.Items.Add(new ListItem() { Text = "Please Select", Value = "0" });
                    ddlDepartments.DataBind();
                    dpROw.Visible = true;
                    tr_Summary.Visible = true;
                    tr_Export.Visible = true;
                    tr_AllPatientRecord.Visible = true;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    ddlShift.Visible = true;   //turned it on
                    lbShift.Visible = true;    //turned it on
                    valusets = DBClass.GetValueSet("Patient Type");
                    ddlPatientType.DataSource = valusets;
                    ddlPatientType.DataTextField = "DataValue_Description";
                    ddlPatientType.DataValueField = "DataValue_Name";
                    ddlPatientType.Items.Add(new ListItem() { Text = "Please Select", Value = "0" });
                    ddlPatientType.DataBind();

                    DataTable shift = DBClass.getDataTable("select * from HR_Shifts");
                    ddlShift.DataSource = shift;
                    ddlShift.DataValueField = "Shift_ID";
                    ddlShift.DataTextField = "Shift_Name";
                    ddlShift.Items.Add(new ListItem() { Value = "0", Text = "All" });
                    ddlShift.DataBind();

                    DataTable dt = DBClass.getDataTable("select * from HR_Employees where IsDoctor=1");
                    ddlDoctor.DataSource = dt;
                    ddlDoctor.DataValueField = "Emp_ID";
                    ddlDoctor.DataTextField = "Emp_Name";
                    ddlDoctor.Items.Add(new ListItem() { Value = "0", Text = "All Doctors" });
                    ddlDoctor.DataBind();
                    lblMultiSelect.Visible = false;
                    trDoctor.Visible = true;

                    optRw.Visible = true;

                    if (AllowPatientRecord)
                    {
                        optRw.Visible = true;
                        DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                        valusets = from d in db.aspnet_Users
                                   select new { d.UserName, d.UserId };
                        ddloprators.DataSource = valusets;
                        ddloprators.DataTextField = "UserName";
                        ddloprators.DataValueField = "UserId";
                        ddloprators.Items.Add(new ListItem() { Text = "All", Value = "0" });
                        ddloprators.DataBind();
                    }
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = true;
                }
                else if (PageTitle == "Patients_Cards")
                {
                    string x = "Patient Card";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    object valusets;
                    valusets = DBClass.GetValueSet("Patient Main Category");
                    ddlDepartments.DataSource = valusets;
                    ddlDepartments.DataTextField = "DataValue_Description";
                    ddlDepartments.DataValueField = "DataValue_Name";
                    ddlDepartments.Items.Add(new ListItem() { Text = "Please Select", Value = "0" });
                    ddlDepartments.DataBind();

                    valusets = DBClass.GetValueSet("Patient Type");
                    ddlPatientType.DataSource = valusets;
                    ddlPatientType.DataTextField = "DataValue_Description";
                    ddlPatientType.DataValueField = "DataValue_Name";
                    ddlPatientType.Items.Add(new ListItem() { Text = "Please Select", Value = "0" });
                    ddlPatientType.DataBind();
                    //----update

                    if (AllowPatientRecord)
                    {
                        optRw.Visible = true;
                        DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                        valusets = from d in db.aspnet_Users
                                   select new { d.UserName, d.UserId };
                        ddloprators.DataSource = valusets;
                        ddloprators.DataTextField = "UserName";
                        ddloprators.DataValueField = "UserId";
                        ddloprators.Items.Add(new ListItem() { Text = "All", Value = "0" });
                        ddloprators.DataBind();
                    }
                    //----- end update

                    lblMultiSelect.Visible = false;
                }
                else if (PageTitle == "Patients_Investigation")
                {
                    string x = "Patient Investigation";
                    Master.Label2.Text = x;
                    Master.GetMenuName();

                    object valusets;

                    valusets = DBClass.GetValueSet("Main Test Departments");
                    ddlMainDepartment.DataSource = valusets;
                    ddlMainDepartment.DataTextField = "DataValue_Description";
                    ddlMainDepartment.DataValueField = "DataValue_Name";
                    ddlMainDepartment.Items.Add(new ListItem() { Text = "All Department", Value = "0" });
                    ddlMainDepartment.DataBind();
                    lblMultiSelect.Visible = false;
                    ddlMainDepartment.Visible = true;
                    lblMainDepartment.Visible = true;

                    DataTable Tests = DBClass.getDataTable("select Test_ID,Test_Name from Lab_Tests");
                    DataTable TestCategories = (DataTable)DBClass.getDataTable("select dv.DataValue_Name,dv.DataValue_Description from ValueSet vs,DataValues dv where vs.ValueSet_ID=dv.ValueSet_ID and vs.ValueSet_Name='Test Groups'");

                    foreach (DataRow dr in TestCategories.Rows)
                    {
                        DataRow newdr = Tests.NewRow();
                        newdr["Test_ID"] = dr["DataValue_Name"].ToString();
                        newdr["Test_Name"] = dr["DataValue_Description"].ToString();
                        Tests.Rows.Add(newdr);
                        Tests.AcceptChanges();
                    }

                    ddlTestName.DataSource = Tests;
                    ddlTestName.DataTextField = "Test_Name";
                    ddlTestName.DataValueField = "Test_ID";
                    ddlTestName.Items.Add(new ListItem() { Text = "All Tests", Value = "0" });
                    ddlTestName.DataBind();

                    ddlTestName.Visible = true;
                    lblTestName.Visible = true;

                    valusets = DBClass.GetValueSet("Patient Main Category");
                    ddlDepartments.DataSource = valusets;
                    ddlDepartments.DataTextField = "DataValue_Description";
                    ddlDepartments.DataValueField = "DataValue_Name";
                    ddlDepartments.Items.Add(new ListItem() { Text = "All Department", Value = "0" });
                    ddlDepartments.DataBind();


                    lblPatientType.Text = "Department Type";

                    ddlPatientType.Items.Add(new ListItem() { Text = "All Department", Value = "0" });
                    ddlPatientType.Items.Add(new ListItem() { Text = "Out Patients", Value = "OutPatient" });
                    ddlPatientType.Items.Add(new ListItem() { Text = "In Patients Patients", Value = "InPatient" });
                    ddlPatientType.Items.Add(new ListItem() { Text = "Front Desk", Value = "Direct From Billing Counter" });
                    ddlPatientType.DataBind();

                    DataTable dt = DBClass.getDataTable("select * from HR_Employees where IsDoctor=1");
                    ddlDoctor.DataSource = dt;
                    ddlDoctor.DataValueField = "Emp_ID";
                    ddlDoctor.DataTextField = "Emp_Name";
                    ddlDoctor.Items.Add(new ListItem() { Value = "0", Text = "All Doctors" });
                    ddlDoctor.DataBind();

                    trDoctor.Visible = true;

                    //
                    tr_Summary.Visible = true;
                    //----update

                    if (AllowPatientRecord)
                    {
                        // optRw.Visible = true;
                        DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                        valusets = from d in db.aspnet_Users
                                   select new { d.UserName, d.UserId };
                        ddloprators.DataSource = valusets;
                        ddloprators.DataTextField = "UserName";
                        ddloprators.DataValueField = "UserId";
                        ddloprators.Items.Add(new ListItem() { Text = "All", Value = "0" });
                        ddloprators.DataBind();
                    }
                    //----- end update
                }
                else if (PageTitle == "InPatients_Detail")
                {
                    string x = "In Patient Detail";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    object valusets;
                    valusets = DBClass.GetValueSet("Main Test Departments");
                    ddlMainDepartment.DataSource = valusets;
                    ddlMainDepartment.DataTextField = "DataValue_Description";
                    ddlMainDepartment.DataValueField = "DataValue_Name";
                    ddlMainDepartment.Items.Add(new ListItem() { Text = "All Department", Value = "0" });
                    ddlMainDepartment.DataBind();
                    lblMultiSelect.Visible = false;
                    //ddlMainDepartment.Visible = true;
                    //lblMainDepartment.Visible = true;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    ddlShift.Visible = false;
                    lbShift.Visible = false;
                    tr_AllPatientRecord.Visible = true;
                    dpROw.Visible = true;


                    DataTable Tests = DBClass.getDataTable("select Test_ID,Test_Name from Lab_Tests");
                    DataTable TestCategories = (DataTable)DBClass.getDataTable("select dv.DataValue_Name,dv.DataValue_Description from ValueSet vs,DataValues dv where vs.ValueSet_ID=dv.ValueSet_ID and vs.ValueSet_Name='Test Groups'");

                    foreach (DataRow dr in TestCategories.Rows)
                    {
                        DataRow newdr = Tests.NewRow();
                        newdr["Test_ID"] = dr["DataValue_Name"].ToString();
                        newdr["Test_Name"] = dr["DataValue_Description"].ToString();
                        Tests.Rows.Add(newdr);
                        Tests.AcceptChanges();
                    }

                    ddlTestName.DataSource = Tests;
                    ddlTestName.DataTextField = "Test_Name";
                    ddlTestName.DataValueField = "Test_ID";
                    ddlTestName.Items.Add(new ListItem() { Text = "All Tests", Value = "0" });
                    ddlTestName.DataBind();

                    //ddlTestName.Visible = true;
                    //lblTestName.Visible = true;


                    valusets = DBClass.GetValueSet("Patient Main Category");
                    ddlDepartments.DataSource = valusets;
                    ddlDepartments.DataTextField = "DataValue_Description";
                    ddlDepartments.DataValueField = "DataValue_Name";
                    ddlDepartments.Items.Add(new ListItem() { Text = "Please Select", Value = "0" });
                    ddlDepartments.DataBind();

                    ddlDepartments.Visible = true;

                    valusets = DBClass.GetValueSet("Patient Type");
                    ddlPatientType.DataSource = valusets;
                    ddlPatientType.DataTextField = "DataValue_Description";
                    ddlPatientType.DataValueField = "DataValue_Name";
                    ddlPatientType.Items.Add(new ListItem() { Text = "Please Select", Value = "0" });
                    ddlPatientType.DataBind();


                    lblPatientType.Text = "Department Type";

                    ddlPatientType.Items.Add(new ListItem() { Text = "All Department", Value = "0" });
                    ddlPatientType.Items.Add(new ListItem() { Text = "Out Patients", Value = "OutPatient" });
                    ddlPatientType.Items.Add(new ListItem() { Text = "In Patients Patients", Value = "InPatient" });
                    ddlPatientType.Items.Add(new ListItem() { Text = "Front Desk", Value = "Direct From Billing Counter" });
                    ddlPatientType.DataBind();

                    DataTable dt = DBClass.getDataTable("select * from HR_Employees where IsDoctor=1");
                    ddlDoctor.DataSource = dt;
                    ddlDoctor.DataValueField = "Emp_ID";
                    ddlDoctor.DataTextField = "Emp_Name";
                    ddlDoctor.Items.Add(new ListItem() { Value = "0", Text = "All Doctors" });
                    ddlDoctor.DataBind();

                    //ddlPatientType.Visible = true;
                    //trDoctor.Visible = true;

                    //
                    //tr_Summary.Visible = false;
                    //----update

                    if (AllowPatientRecord)
                    {
                        optRw.Visible = true;
                        DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                        valusets = from d in db.aspnet_Users
                                   select new { d.UserName, d.UserId };
                        ddloprators.DataSource = valusets;
                        ddloprators.DataTextField = "UserName";
                        ddloprators.DataValueField = "UserId";
                        ddloprators.Items.Add(new ListItem() { Text = "All", Value = "0" });
                        ddloprators.DataBind();
                    }
                    //----- end update
                }
                else if (PageTitle == "GOP_Patient_Detail")
                {
                    string x = "GOP Patient Detail";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    dpROw.Visible = false;
                    Time_Row.Visible = false;
                    tr_Summary.Visible = false;

                    //----update

                    if (AllowPatientRecord)
                    {
                        object valusets;
                        optRw.Visible = true;
                        DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                        valusets = from d in db.aspnet_Users
                                   select new { d.UserName, d.UserId };
                        ddloprators.DataSource = valusets;
                        ddloprators.DataTextField = "UserName";
                        ddloprators.DataValueField = "UserId";
                        ddloprators.Items.Add(new ListItem() { Text = "All", Value = "0" });
                        ddloprators.DataBind();
                    }
                    //----- end update
                    //
                }
                else if (PageTitle == "GOP_Patient_Summary")
                {
                    string x = "GOP Patient Summary";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    dpROw.Visible = false;
                    Time_Row.Visible = false;
                    tr_Summary.Visible = false;

                    //----update

                    if (AllowPatientRecord)
                    {
                        object valusets;
                        optRw.Visible = true;
                        DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                        valusets = from d in db.aspnet_Users
                                   select new { d.UserName, d.UserId };
                        ddloprators.DataSource = valusets;
                        ddloprators.DataTextField = "UserName";
                        ddloprators.DataValueField = "UserId";
                        ddloprators.Items.Add(new ListItem() { Text = "All", Value = "0" });
                        ddloprators.DataBind();
                    }
                    //----- end update
                }
                else if (this.PageTitle == "Department_Conversion")
                {
                    string x = "Department Conversion";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    object valusets;
                    //dpROw.Visible = false;

                    dpROw.Visible = true;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = true;
                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = (from p in db.DataValues where p.ValueSet_ID == 9 select new { p.DataValue_Name, p.DataValue_Description }).ToList();
                    ddlDepartments.DataSource = valusets;
                    ddlDepartments.DataTextField = "DataValue_Description";
                    ddlDepartments.DataValueField = "DataValue_Name";
                    ddlDepartments.Items.Add(new ListItem() { Text = "Please Select", Value = "0" });
                    ddlDepartments.DataBind();
                }
                else if (this.PageTitle == "Lab_Cash_Receiving_Collection")
                {
                    string x = "Lab Cash Receiving";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    dpROw.Visible = false;
                    ddlPatientType.Visible = false;
                    tr_Summary.Visible = true;
                    //lblMainDepartment.Visible = true;
                    //ddlDepartments.Visible = true;
                    tr1MedicalSubsidy.Visible = true;
                    lblMedical.Visible = true;
                    ddlMedicalSubsidy.Visible = true;

                    object valusets;
                    //object valusets;
                    valusets = DBClass.GetValueSet("Patient Type");
                    lblMultiSelect.DataSource = valusets;
                    lblMultiSelect.DataTextField = "DataValue_Description";
                    lblMultiSelect.DataValueField = "DataValue_Name";
                    lblMultiSelect.Items.Add(new ListItem() { Text = "All", Value = "All" });
                    lblMultiSelect.DataBind();
                    optRw.Visible = true;
                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    valusets = from d in db.aspnet_Users
                               select new { d.UserName, d.UserId };
                    ddloprators.DataSource = valusets;
                    ddloprators.DataTextField = "UserName";
                    ddloprators.DataValueField = "UserId";
                    ddloprators.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddloprators.DataBind();

                    //lblPatientType.Visible = true;
                    //lblMultiSelect.Visible = true;
                    SetDepartent();
                }

                if (AllowPatientRecord)
                {
                    //trAllPatients.Visible = true;
                }
                else
                {

                }
            }
        }

        [WebMethod]
        public static string LoadDoctor(string dpt)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                if (dpt == "All")
                {
                    var inPatmedicineList = (from emp in db.HR_Employees

                                             where emp.IsDoctor == true
                                             select new { emp.Emp_ID, emp.Emp_Name }).ToList();
                    return (new JavaScriptSerializer()).Serialize(inPatmedicineList);
                }
                else
                {
                    var inPatmedicineList = (from emp in db.HR_Employees

                                             where emp.Department == dpt & emp.IsDoctor == true
                                             select new { emp.Emp_ID, emp.Emp_Name }).ToList();
                    return (new JavaScriptSerializer()).Serialize(inPatmedicineList);
                }
            }
            return "";
        }

        private void SetDepartent()
        {
            object valusets;
            dpROw.Visible = true;
            ddlDepartments.Visible = true;
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            valusets = (from p in db.DataValues where p.ValueSet_ID == 9 select new { p.DataValue_Name, p.DataValue_Description }).ToList();
            ddlDepartments.DataSource = valusets;
            ddlDepartments.DataTextField = "DataValue_Description";
            ddlDepartments.DataValueField = "DataValue_Name";
            ddlDepartments.Items.Add(new ListItem() { Text = "All", Value = "All" });
            ddlDepartments.DataBind();
        }
        private void SetWarehouse()
        {
            Stock_Movement.Visible = true;
            ddlwareHouse.Visible = true;
            ddlwareHouse.DataSource = GetUserWarehouses();
            ddlwareHouse.DataTextField = "Text";
            ddlwareHouse.DataValueField = "Value";
            ddlwareHouse.Items.Clear();
            ddlwareHouse.Items.Add(new ListItem() { Text = "All", Value = "0" });
            ddlwareHouse.DataBind();
        }
        private void LoadForm()
        {
            object valusets;
            dpROw.Visible = true;
            //lblMainDepartment.Visible = true;
            ddlInvForm.Visible = true;
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            valusets = (from p in db.DataValues where p.ValueSet_ID == 3169 select new { p.DataValue_Name, p.DataValue_Description }).ToList();
            ddlInvForm.DataSource = valusets;
            ddlInvForm.DataTextField = "DataValue_Description";
            ddlInvForm.DataValueField = "DataValue_Name";
            ddlInvForm.Items.Add(new ListItem() { Text = "All", Value = "All" });
            ddlInvForm.DataBind();
        }
        [WebMethod]
        public static string GetCardioTests()
        {

            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var tests = from t in db.Lab_Tests
                        where t.Main_Department == "008" && t.Active == true
                        select new { t.Test_ID, Test_Name = t.Test_Name, t.Group_Category };
            List<TestIDsAndGroupCategory> listOfTest = new List<TestIDsAndGroupCategory>();
            int counter = 1;
            foreach (var test in tests)
            {
                TestIDsAndGroupCategory obj = new TestIDsAndGroupCategory();
                obj.TestID = test.Test_ID.ToString();
                obj.TestName = test.Test_Name.ToString() + (test.Group_Category != string.Empty ? " | " + DBClass.getField("select Datavalue_Description from Datavalues where Datavalue_Name = '" + test.Group_Category + "' and Valueset_ID = 70") : string.Empty);
                obj.SerialNo = counter.ToString();
                obj.IsGroupCategory = false;
                listOfTest.Add(obj);
                counter++;
            }

            var GroupCategories = from dv in db.DataValues
                                  join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                                  where vs.ValueSet_Name == "Test Groups" && dv.Division == "004"
                                  select new { dv.DataValue_Name, dv.DataValue_Description };

            foreach (var category in GroupCategories)
            {
                TestIDsAndGroupCategory obj = new TestIDsAndGroupCategory();
                obj.TestID = category.DataValue_Name.ToString();
                obj.TestName = category.DataValue_Description.ToString();
                obj.SerialNo = counter.ToString();
                obj.IsGroupCategory = true;
                obj.CategoryID = category.DataValue_Name;
                listOfTest.Add(obj);
                counter++;
            }

            return (new JavaScriptSerializer()).Serialize(listOfTest);
        }
        [WebMethod]
        public static string LoadFormNo(string inv_form)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                if (inv_form == "01")
                {
                    var GIR_NO = (from gir in db.MaterialIssueRequests
                                  select new { ID = gir.MaterialRequest_Id, NO = gir.Request_No }).ToList();
                    return (new JavaScriptSerializer()).Serialize(GIR_NO);
                }
                else if (inv_form == "02")
                {
                    var SIN_NO = (from sin in db.Store_Issues
                                  select new { ID = sin.Store_Issue_Id, NO = sin.Store_Issue_No }).ToList();
                    return (new JavaScriptSerializer()).Serialize(SIN_NO);
                }
                else if (inv_form == "03")
                {
                    var PR_NO = (from pr in db.Purchase_Requisitions
                                 select new { ID = pr.PR_Id, NO = pr.PR_Num }).ToList();
                    return (new JavaScriptSerializer()).Serialize(PR_NO);
                }
                else if (inv_form == "04")
                {
                    var RFQ_NO = (from rfq in db.AP_RequestForQuotations
                                  select new { ID = rfq.RFQ_ID, NO = rfq.RFQ_No }).ToList();
                    return (new JavaScriptSerializer()).Serialize(RFQ_NO);
                }
                else if (inv_form == "05")
                {
                    var CS_NO = (from cs in db.CS_Vendor_Masters
                                 select new { ID = cs.CS_Ven_Master_ID, NO = cs.CS_Ven_No }).ToList();
                    return (new JavaScriptSerializer()).Serialize(CS_NO);
                }
                else if (inv_form == "06")
                {
                    var PO_NO = (from po in db.AP_Purchase_Orders
                                 select new { ID = po.PO_ID, NO = po.PO_No }).ToList();
                    return (new JavaScriptSerializer()).Serialize(PO_NO);
                }
                else if (inv_form == "07")
                {
                    var IGP_NO = (from igp in db.Igp_masters
                                  select new { ID = igp.Igp_Id, NO = igp.Igp_num }).ToList();
                    return (new JavaScriptSerializer()).Serialize(IGP_NO);
                }
                else if (inv_form == "08")
                {
                    var GRN_NO = (from grn in db.GRN_Masters
                                  select new { ID = grn.GRN_ID, NO = grn.GRN_Num }).ToList();
                    return (new JavaScriptSerializer()).Serialize(GRN_NO);
                }
                else if (inv_form == "09")
                {
                    var Pur_NO = (from pur in db.Purchase_Invoice_Masters
                                  select new { ID = pur.PurchaseInvoiceId, NO = pur.InvoiceNum }).ToList();
                    return (new JavaScriptSerializer()).Serialize(Pur_NO);
                }
                else if (inv_form == "10")
                {
                    var Pay_NO = (from pay in db.Payment_Invoices
                                  select new { ID = pay.PaymentInvoiceId, NO = pay.PaymentNum }).ToList();
                    return (new JavaScriptSerializer()).Serialize(Pay_NO);
                }
                else
                {
                    return "";
                }
            }
            return "";
        }
        [WebMethod]
        public static string loadMedicine(string ItemName)
        {
            string result = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.Medicines(ItemName).ToList();
                result = (new JavaScriptSerializer()).Serialize(query).ToString();
            }
            return result;
        }
        [WebMethod]
        public static string GetLabTestsForAnalysis()
        {

            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var tests = from t in db.Lab_Tests
                        where (t.Main_Department == "001" || t.Main_Department == "002" || t.Main_Department == "003") && t.Active == true
                        select new { t.Test_ID, Test_Name = t.Test_Name, t.Group_Category };
            List<TestIDsAndGroupCategory> listOfTest = new List<TestIDsAndGroupCategory>();
            int counter = 1;
            foreach (var test in tests)
            {
                TestIDsAndGroupCategory obj = new TestIDsAndGroupCategory();
                obj.TestID = test.Test_ID.ToString();
                obj.TestName = test.Test_Name.ToString() + (test.Group_Category != string.Empty ? " | " + DBClass.getField("select Datavalue_Description from Datavalues where Datavalue_Name = '" + test.Group_Category + "' and Valueset_ID = 70") : string.Empty);
                obj.SerialNo = counter.ToString();
                obj.IsGroupCategory = false;
                listOfTest.Add(obj);
                counter++;
            }

            var GroupCategories = from dv in db.DataValues
                                  join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                                  where vs.ValueSet_Name == "Test Groups" && (dv.Division == "001" || dv.Division == "002" || dv.Division == "003")
                                  select new { dv.DataValue_Name, dv.DataValue_Description };

            foreach (var category in GroupCategories)
            {
                TestIDsAndGroupCategory obj = new TestIDsAndGroupCategory();
                obj.TestID = category.DataValue_Name.ToString();
                obj.TestName = category.DataValue_Description.ToString();
                obj.SerialNo = counter.ToString();
                obj.IsGroupCategory = true;
                obj.CategoryID = category.DataValue_Name;
                listOfTest.Add(obj);
                counter++;
            }

            return (new JavaScriptSerializer()).Serialize(listOfTest);
        }
        [WebMethod]
        public static string GetLabTests()
        {

            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var tests = from t in db.Lab_Tests
                        where t.Main_Department == "001" && t.Active == true
                        select new { t.Test_ID, Test_Name = t.Test_Name, t.Group_Category };
            List<TestIDsAndGroupCategory> listOfTest = new List<TestIDsAndGroupCategory>();
            int counter = 1;
            foreach (var test in tests)
            {
                TestIDsAndGroupCategory obj = new TestIDsAndGroupCategory();
                obj.TestID = test.Test_ID.ToString();
                obj.TestName = test.Test_Name.ToString() + (test.Group_Category != string.Empty ? " | " + DBClass.getField("select Datavalue_Description from Datavalues where Datavalue_Name = '" + test.Group_Category + "' and Valueset_ID = 70") : string.Empty);
                obj.SerialNo = counter.ToString();
                obj.IsGroupCategory = false;
                listOfTest.Add(obj);
                counter++;
            }

            var GroupCategories = from dv in db.DataValues
                                  join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                                  where vs.ValueSet_Name == "Test Groups" && dv.Division == "001"
                                  select new { dv.DataValue_Name, dv.DataValue_Description };

            foreach (var category in GroupCategories)
            {
                TestIDsAndGroupCategory obj = new TestIDsAndGroupCategory();
                obj.TestID = category.DataValue_Name.ToString();
                obj.TestName = category.DataValue_Description.ToString();
                obj.SerialNo = counter.ToString();
                obj.IsGroupCategory = true;
                obj.CategoryID = category.DataValue_Name;
                listOfTest.Add(obj);
                counter++;
            }

            return (new JavaScriptSerializer()).Serialize(listOfTest);
        }
        public class TestIDsAndGroupCategory
        {
            public string Rate { get; set; }
            public string TestID { get; set; }
            public string TestName { get; set; }
            public string SerialNo { get; set; }
            public string CategoryID { get; set; }
            public bool IsGroupCategory { get; set; }
            public string GroupName { get; set; }
            public string MainDepartmentName { get; set; }
        }
    }
}