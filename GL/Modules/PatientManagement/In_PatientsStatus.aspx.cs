using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class In_PatientsStatus : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            object valusets;
            valusets = DBClass.GetValueSet("Patient Main Category");
            ddlDepartments.DataSource = valusets;
            ddlDepartments.DataTextField = "DataValue_Description";
            ddlDepartments.DataValueField = "DataValue_Name";
            ddlDepartments.Items.Add(new ListItem() { Text = "All Departments", Value = "0" });
            ddlDepartments.DataBind();

        }
    }
}