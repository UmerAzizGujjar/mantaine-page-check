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
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class PatientsDepartmentWise : System.Web.UI.Page
    {
        string PageTitle;
        public bool AllowPatientRecord = false;
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
                    lblPatientType.Visible = false;
                    optRw.Visible = false;
                    trDoctor.Visible = false;
                    lblMainDepartment.Visible = false;
                    ddlShift.Visible = false;
                    lbShift.Visible = false;
                    tr_Export.Visible = false;
                    dpROw.Visible = false;
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
                else if (this.PageTitle == "OPD_Department_Wise_Report")
                {
                    string x = "Department Wise Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr1MedicalSubsidy.Visible = false;
                    dpROw.Visible = true;
                    tr_Summary.Visible = false;      // changed
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
                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    object valusetss = from d in db.aspnet_Users
                                       select new { d.UserName, d.UserId };
                    ddlPatientType.DataSource = valusetss;
                    ddlPatientType.DataTextField = "UserName";
                    ddlPatientType.DataValueField = "UserId";
                    ddlPatientType.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlPatientType.DataBind();

                    //lbShift.Visible = true;
                    //ddlShift.Visible = true;
                    //DataTable shift = DBClass.getDataTable("select * from HR_Shifts");
                    //ddlShift.DataSource = shift;
                    //ddlShift.DataValueField = "Shift_ID";
                    //ddlShift.DataTextField = "Shift_Name";
                    //ddlShift.Items.Add(new ListItem() { Value = "0", Text = "All" });
                    //ddlShift.DataBind();
                    lboperator.Visible = false;
                    ddloprators.Visible = false;

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
                }
                if (PageTitle == "PCRS")
                {

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
                //else if (this.PageTitle == "Counsltant_Day_Wise_report")
                //{
                //    string x = "Consultant Day Wise Report";
                //    Master.Label2.Text = x;
                //    Master.GetMenuName();
                //    tr1MedicalSubsidy.Visible = false;
                //    dpROw.Visible = false;
                //    tr_Summary.Visible = false;      // changed
                //    lblMultiSelect.Visible = false;
                //    DateDiv.Visible = true;
                //    Time_Row.Visible = true;
                //    op_PanelCompany.Visible = false;
                //    optRw.Visible = false;


                //    trDoctor.Visible = true;

                //    DataTable dt = DBClass.getDataTable("select * from HR_Employees where IsDoctor=1");
                //    ddlDoctor.DataSource = dt;
                //    ddlDoctor.DataValueField = "Emp_ID";
                //    ddlDoctor.DataTextField = "Emp_Name";
                //    ddlDoctor.Items.Add(new ListItem() { Value = "0", Text = "All Doctors" });
                //    ddlDoctor.DataBind();
                //    lblMultiSelect.Visible = false;

                //}
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
                    tr1MedicalSubsidy.Visible = false;
                    dpROw.Visible = false;
                    tr_Summary.Visible = false;      // changed
                    lblMultiSelect.Visible = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    op_PanelCompany.Visible = false;
                    optRw.Visible = false;

                    lboperator.Visible = false;
                    ddloprators.Visible = false;


                    trDoctor.Visible = true;

                    DataTable dt = DBClass.getDataTable("select * from HR_Employees where IsDoctor=1");
                    ddlDoctor.DataSource = dt;
                    ddlDoctor.DataValueField = "Emp_ID";
                    ddlDoctor.DataTextField = "Emp_Name";
                    ddlDoctor.Items.Add(new ListItem() { Value = "0", Text = "All Doctors" });
                    ddlDoctor.DataBind();
                    lblMultiSelect.Visible = false;

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
                    tr_Export.Visible = false;
                    trDoctor.Visible = false;
                    tr_Summary.Visible = false;
                    Time_Row.Visible = false;
                    DateDiv.Visible = true;
                    op_FilterClinic.Visible = false;
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
                }
                else if (this.PageTitle == "Dischare_Revd")
                {
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
                    valuset = DBClass.GetValueSet("Ware house");
                    ddlwareHouse.DataSource = valuset;
                    ddlwareHouse.DataTextField = "DataValue_Description";
                    ddlwareHouse.DataValueField = "DataValue_Name";
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
                    tr_Export.Visible = false;
                    DateDiv.Visible = true;
                    sttDate.Text = "End Date";
                    txtStart_Date.Visible = true;
                    endDate.Visible = false;
                    txtEnd_Date.Visible = false;
                }
                else if (this.PageTitle == "IWPOS")
                {

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
                    tr_Export.Visible = false;

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
                    valusets = DBClass.GetValueSet("Ware house");
                    ddlwareHouse.DataSource = valusets;
                    ddlwareHouse.DataTextField = "DataValue_Description";
                    ddlwareHouse.DataValueField = "DataValue_Name";
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
                    tr_Export.Visible = false;
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
                    valusets = DBClass.GetValueSet("Ware house");
                    ddlwareHouse.DataSource = valusets;
                    ddlwareHouse.DataTextField = "DataValue_Description";
                    ddlwareHouse.DataValueField = "DataValue_Name";
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
                    tr_Export.Visible = false;
                }
                else if (this.PageTitle == "MIR_summary")
                {
                    string x = "MIR Summary";
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
                else if (this.PageTitle == "Vendor_Wise_Payment_Summary")
                {
                    string x = "Vendor Wise Payment Summary";
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
                else if (this.PageTitle == "VPDR")
                {
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
                else if (this.PageTitle == "BER")
                {
                    string x = "Batch Expiry Report";
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
                else if (PageTitle == "SehatSahulatWiseExpensive")
                {
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
                if (this.PageTitle == "TimeAndMotion")
                {

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
                    valuset = DBClass.GetValueSet("Ware house");
                    ddlwareHouse.DataSource = valuset;
                    ddlwareHouse.DataTextField = "DataValue_Description";
                    ddlwareHouse.DataValueField = "DataValue_Name";
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
                if (this.PageTitle == "Physiotherapy_Cash_Collection")
                {

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

                    trSearch1.Visible = true;

                    object valuset;
                    valuset = DBClass.GetValueSet("Ware house");
                    ddlwareHouse.DataSource = valuset;
                    ddlwareHouse.DataTextField = "DataValue_Description";
                    ddlwareHouse.DataValueField = "DataValue_Name";
                    ddlwareHouse.Items.Clear();
                    ddlwareHouse.Items.Add(new ListItem() { Text = "All", Value = "0" });
                    ddlwareHouse.DataBind();
                    Stock_Movement.Visible = true;


                    ddlwareHouse.Visible = true;
                    lblWarehouse.Visible = true;

                    lbItemCategory.Visible = false;
                    ddlItemCategory.Visible = false;


                }
                if (this.PageTitle == "Item_Wise_Purchase_Report")
                {

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

                    trSearch1.Visible = true;

                    object valuset;
                    valuset = DBClass.GetValueSet("Ware house");
                    ddlwareHouse.DataSource = valuset;
                    ddlwareHouse.DataTextField = "DataValue_Description";
                    ddlwareHouse.DataValueField = "DataValue_Name";
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

                    // Get Cardiology Tests (Main_Department = '004')
                    DataTable tests = DBClass.getDataTable(@"
        SELECT Test_ID, Test_Name 
        FROM Lab_Tests 
        WHERE Main_Department = '004' AND Active = 1
    ");

                    // Get Group Categories (ValueSet_ID = 70, Division = '004')
                    DataTable groups = DBClass.getDataTable(@"
        SELECT DataValue_Name, DataValue_Description 
        FROM DataValues 
        WHERE ValueSet_ID = 70 AND Division = '004'
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


                    DataTable Tests = DBClass.getDataTable("select Test_ID,Test_Name from Lab_Tests where main_department in ('002','003')");
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
                if (this.PageTitle == "AnalysisReport")
                {

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


                }
                if (this.PageTitle == "Pharmacy_Profit_and_Loss_Report")
                {

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
                if (this.PageTitle == "Head_Wise_Discount_Report")
                {

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
                else if (this.PageTitle == "OPD_Time_Line" || this.PageTitle == "IPD_Time_Line" || this.PageTitle == "Discharge_Time_Line" || this.PageTitle == "Ward_Allocation_Time_Line" || this.PageTitle == "Procedure_Time_Line" || this.PageTitle == "Bed_Occupancy" || this.PageTitle == "AverageLengthOfStay" || this.PageTitle == "DepartmentWiseProcedureTimeLine")
                {
                    dpROw.Visible = false;

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


                    if (this.PageTitle == "AverageLengthOfStay")
                    {
                        ddlMedicalSubsidy.Items.Clear();
                        //ddlMedicalSubsidy.Items.Add("Annually");
                        ddlMedicalSubsidy.Items.Add("Annually with Stay Days");
                        ddlMedicalSubsidy.Items.Add("Annually with Stay Days Summary");
                    }
                    else if (this.PageTitle == "Bed_Occupancy")
                    {
                        ddlMedicalSubsidy.Items.Clear();
                        ddlMedicalSubsidy.Items.Add("Annually With Stay Days");
                        ddlMedicalSubsidy.Items.Add("Annually With Stay Days Summary");
                    }

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
                    object valusets;
                    lblMainDepartment.Visible = false;
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
                    lblMedical.Text = "Test Main Departments";
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
                    ddlProcedure.Visible = true;
                    ddlProcedure.Items.Clear();
                    ddlProcedure.Items.Add(new ListItem() { Text = "All ", Value = "0" });
                    ddlProcedure.Items.Add(new ListItem() { Text = "OPD", Value = "OPD" });
                    ddlProcedure.Items.Add(new ListItem() { Text = "IPD", Value = "IPD" });

                    ddlProcedure.DataBind();

                }
                else if (PageTitle == "TestsRateList")
                {
                    object valusets;
                    lblMainDepartment.Visible = false;
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

                    lblDepartment.Text = "Department";

                    DataBaseDataContext dbase = new DataBaseDataContext(DBClass.ConnectionString());


                    valusets = (from p in dbase.DataValues where p.ValueSet_ID == 67 select new { p.DataValue_Name, p.DataValue_Description }).ToList();
                    ddlDepartments.DataSource = valusets;
                    ddlDepartments.DataTextField = "DataValue_Description";
                    ddlDepartments.DataValueField = "DataValue_Name";
                    ddlDepartments.Items.Add(new ListItem() { Text = "All", Value = "0" });
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

                    lblDepartment.Text = "Department";

                    DataBaseDataContext dbase = new DataBaseDataContext(DBClass.ConnectionString());


                    valusets = (from p in dbase.DataValues where p.ValueSet_ID == 67 select new { p.DataValue_Name, p.DataValue_Description }).ToList();
                    ddlDepartments.DataSource = valusets;
                    ddlDepartments.DataTextField = "DataValue_Description";
                    ddlDepartments.DataValueField = "DataValue_Name";
                    ddlDepartments.Items.Add(new ListItem() { Text = "All", Value = "0" });
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


                    valusets = (from p in dbase.DataValues where p.ValueSet_ID == 67 select new { p.DataValue_Name, p.DataValue_Description }).ToList();
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
                    tr_Export.Visible = false;
                    ddlPatientType.Visible = true;
                    lblMultiSelect.Visible = false;
                    GetLabTests();
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

                //else if (this.PageTitle == "Lab_Test_Wise_Summary")
                //{
                //    string x = "Lab Test Wise Summary";
                //    Master.Label2.Text = x;
                //    Master.GetMenuName();
                //    dpROw.Visible = false;
                //    ddlPatientType.Visible = false;

                //    tr_Summary.Visible = false;

                //    AllowPatientRecord = false;

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

                //    //lblPatientType.Visible = true;
                //    //lblMultiSelect.Visible = true;
                //    SetDepartent();
                //}


                //else if (this.PageTitle == "Lab_Test_Wise_Summary")
                //{
                //    dptROw.Visible = false;
                //    ddlPatientType.Visible = false;

                //    trSummary.Visible = false;
                //    trAllPatients.Visible = false;
                //    AllowPatientRecord = false;

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
                //    object valusets;
                //    trProcedure.Visible = true;
                //    lblProcedure.InnerText = "Test Departments";
                //    oprtRw.Visible = false;

                //    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                //    valusets = from d in db.DataValues
                //               where d.ValueSet_ID == 67
                //               select new { d.DataValue_Name, d.DataValue_Description };
                //    ddlProcedure.Items.Clear();
                //    ddlProcedure.DataSource = valusets;
                //    ddlProcedure.DataTextField = "DataValue_Description";
                //    ddlProcedure.DataValueField = "DataValue_Name";
                //    ddlProcedure.Items.Add(new ListItem() { Text = "All", Value = "0" });
                //    ddlProcedure.DataBind();

                //    //lblMainDepartment.Visible = true;
                //    //ddlDepartments.Visible = true;

                //    //object valusets;
                //    valusets = DBClass.GetValueSet("Patient Type");
                //    lblMultiSelect.DataSource = valusets;
                //    lblMultiSelect.DataTextField = "DataValue_Description";
                //    lblMultiSelect.DataValueField = "DataValue_Name";
                //    lblMultiSelect.Items.Add(new ListItem() { Text = "All", Value = "All" });
                //    lblMultiSelect.DataBind();

                //    //lblPatientType.Visible = true;
                //    //lblMultiSelect.Visible = true;
                //    SetDepartent();
                //}

                else if (this.PageTitle == "Lab_Department_Wise_Summary")
                {
                    dpROw.Visible = false;
                    ddlPatientType.Visible = false;
                    tr_Summary.Visible = false;

                    AllowPatientRecord = false;
                    DateDiv.Visible = true;
                    Time_Row.Visible = true;
                    trTestResult1.Visible = false;
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
                    /*SetDepartent();*/
                }
                else if (this.PageTitle == "Test_Result_Status")
                {
                    dpROw.Visible = false;
                    ddlPatientType.Visible = false;
                    tr_Summary.Visible = false;
                    AllowPatientRecord = false;
                    trTestResult1.Visible = true;
                }
                else if (PageTitle == "Procedure_List")
                {

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
                    Response.Redirect("ReportViewer.aspx?ReportName=AdmitPatientList");
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
                    }
                    trDoctor.Visible = false;

                    SetDepartent();

                }
                else if (PageTitle == "AdvanceReport")
                {
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

                else if (PageTitle == "CancelBill")
                {
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
                }
                //else if (PageTitle == "Pharmacy_Profit_and_Loss_Report")
                //{
                //    optRw.Visible = false;
                //    tr_Summary.Visible = false;
                //    ddlDepartments.Visible = false;
                //    ddlDoctor.Visible = false;
                //    trDoctor.Visible = false;
                //    lbservieType.Visible = false;
                //    DateDiv.Visible = true;
                //    ddlReportType.Visible = false;
                //    dpROw.Visible = false;
                //    Time_Row.Visible = true;

                //}

                else if (this.PageTitle == "ChargePolicyWiseSummary")
                {
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
                else if (PageTitle == "Patient_Trans_Detail")
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
                    DateDiv.Visible = false;
                    Time_Row.Visible = false;
                }
                if (this.PageTitle == "OutSourceTestDetail")
                {
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
                if (this.PageTitle == "DoctorShare_Report")
                {
                    string x = "Doctor Share ";
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
                    ddlMedicalSubsidy.Visible = false;

                    object valusets;
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
                        tr1MedicalSubsidy.Visible = true;
                    }

                    //----- end update
                }
                if (this.PageTitle == "Procedure_Time_Line_Detail")
                {
                    string x = "Procedure Time Line Detail";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    lblMainDepartment.Visible = false;
                    ddlDepartments.Visible = false;
                    lblPatientType.Visible = false;
                    lblMultiSelect.Visible = false;
                    ddlPatientType.Visible = false;
                    optRw.Visible = false;
                    trDoctor.Visible = false;
                    tr1MedicalSubsidy.Visible = true;
                    tr_Summary.Visible = false;

                    AllowPatientRecord = false;

                    lblMedical.Text = "Patient Type";
                    ddlMedicalSubsidy.Items.Clear();
                    ddlMedicalSubsidy.Items.Add(new ListItem() { Text = "All", Value = "All" });
                    ddlMedicalSubsidy.Items.Add(new ListItem() { Text = "General", Value = "1" });
                    ddlMedicalSubsidy.Items.Add(new ListItem() { Text = "Private", Value = "2" });
                    ddlMedicalSubsidy.DataBind();
                    SetDepartent();
                    trProcedure1.Visible = true;
                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    var serviceList = (from sl in db.INV_Items
                                       where
                                       sl.Procedure_types.Length > 1
                                       select new { sl.Item_ID, sl.Description }).ToList();

                    ddlProcedure.DataSource = serviceList;
                    ddlProcedure.DataValueField = "Item_ID";
                    ddlProcedure.DataTextField = "Description";
                    ddlProcedure.Items.Add(new ListItem() { Text = "All", Value = "All" });
                    ddlProcedure.DataBind();
                }
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
                    string x = "Advance Detail";
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
                    string x = "Stokc in Hand Detail";
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
                    string x = "Receiving Item Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr_Summary.Visible = false;

                    Time_Row.Visible = false;
                    dpROw.Visible = false;
                    lblMultiSelect.Visible = false;
                    trDoctor.Visible = false;
                }
                if (PageTitle == "StockBalnce_Report")
                {
                    string x = "Item Wise Stock Balance Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    tr_Summary.Visible = false;

                    Time_Row.Visible = false;
                    dpROw.Visible = false;
                    lblMultiSelect.Visible = false;
                    trDoctor.Visible = false;
                }
                if (PageTitle == "Oppening_Report")
                {
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
                if (PageTitle == "Doctotr_Receipts")
                {
                    string x = "Doctor Receipts";
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



                    DataTable dt = DBClass.getDataTable("select * from HR_Employees where IsDoctor=1");
                    ddlDoctor.DataSource = dt;
                    ddlDoctor.DataValueField = "Emp_ID";
                    ddlDoctor.DataTextField = "Emp_Name";
                    ddlDoctor.Items.Add(new ListItem() { Value = "0", Text = "All Doctors" });
                    ddlDoctor.DataBind();
                    lblMultiSelect.Visible = false;
                    trDoctor.Visible = true;
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
                if (PageTitle == "AllCash_Report")
                {
                    string x = "All Cash Report";
                    Master.Label2.Text = x;
                    Master.GetMenuName();
                    object valusets;
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
                        where t.Main_Department == "004" && t.Active == true
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