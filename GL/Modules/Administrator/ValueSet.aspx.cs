using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.Administrator
{
    public partial class ValueSet : System.Web.UI.Page
    {
        DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!Page.IsPostBack)
            {
                BindGrid();
                ClearForm();
            }
        }

        private void BindGrid()
        {
            var list = db.ValueSets
                .OrderByDescending(v => v.ValueSet_ID)
                .Select(v => new
                {
                    v.ValueSet_ID,
                    v.ValueSet_Name,
                    v.ValueSet_Description,
                    v.Max_Length,
                    v.Data_Type,
                    v.Active
                })
                .ToList();

            GRD.DataSource = list;
            GRD.DataBind();
        }

        private void ClearForm()
        {
            hfValueSet_ID.Value = "";
            hfSystem.Value = "false";
            txtName.Text = "";
            txtDescription.Text = "";
            txtMaxLength.Text = "";
            ddlDataType.SelectedValue = "Numeric";
            chkActive.Checked = true;
            btnSave.Text = "Save";
            lblMessage.Text = "";
            txtName.Focus();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtName.Text) ||
                string.IsNullOrWhiteSpace(txtDescription.Text) ||
                string.IsNullOrWhiteSpace(txtMaxLength.Text))
            {
                ShowSwal("warning", "Name, Description and Max Length are required");
                lblMessage.Text = "Please fill all required fields.";
                return;
            }

            int maxLen;
            if (!int.TryParse(txtMaxLength.Text.Trim(), out maxLen) || maxLen < 1)
            {
                ShowSwal("warning", "Max Length must be a positive number");
                lblMessage.Text = "Max Length must be a positive number.";
                return;
            }

            string name = txtName.Text.Trim();
            string desc = txtDescription.Text.Trim();
            string dtype = ddlDataType.SelectedValue;
            bool active = chkActive.Checked;

            if (string.IsNullOrWhiteSpace(hfValueSet_ID.Value))
            {
                var dup = db.ValueSets.FirstOrDefault(v =>
                    v.ValueSet_Name != null &&
                    v.ValueSet_Name.ToLower() == name.ToLower());
                if (dup != null)
                {
                    ShowSwal("error", "A value set with this name already exists");
                    lblMessage.Text = "Name already exists.";
                    return;
                }

                PMS.ValueSet newRec = new PMS.ValueSet
                {
                    ValueSet_Name = name,
                    ValueSet_Description = desc,
                    Max_Length = maxLen,
                    Data_Type = dtype,
                    System = false,
                    Active = active
                };
                db.ValueSets.InsertOnSubmit(newRec);
                db.SubmitChanges();
                ShowSwal("success", "Value set added");
            }
            else
            {
                int id = Convert.ToInt32(hfValueSet_ID.Value);
                var rec = db.ValueSets.FirstOrDefault(v => v.ValueSet_ID == id);
                if (rec == null)
                {
                    ShowSwal("error", "Record not found");
                    return;
                }
                rec.ValueSet_Name = name;
                rec.ValueSet_Description = desc;
                rec.Max_Length = maxLen;
                rec.Data_Type = dtype;
                rec.Active = active;
                db.SubmitChanges();
                ShowSwal("success", "Value set updated");
            }

            BindGrid();
            ClearForm();
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ClearForm();
        }

        protected void GRD_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandArgument == null) return;
            int id;
            if (!int.TryParse(e.CommandArgument.ToString(), out id)) return;

            if (e.CommandName == "EditRec")
            {
                LoadValueSet(id);
            }
            else if (e.CommandName == "InactiveRec")
            {
                InactiveValueSet(id);
            }
            else if (e.CommandName == "ReactivateRec")
            {
                ReactivateValueSet(id);
            }
        }

        private void LoadValueSet(int id)
        {
            var rec = db.ValueSets.FirstOrDefault(v => v.ValueSet_ID == id);
            if (rec == null)
            {
                ShowSwal("error", "Record not found");
                return;
            }

            hfValueSet_ID.Value = rec.ValueSet_ID.ToString();
            txtName.Text = rec.ValueSet_Name ?? "";
            txtDescription.Text = rec.ValueSet_Description ?? "";
            txtMaxLength.Text = rec.Max_Length.HasValue ? rec.Max_Length.Value.ToString() : "";
            if (!string.IsNullOrEmpty(rec.Data_Type))
            {
                if (ddlDataType.Items.FindByValue(rec.Data_Type) != null)
                    ddlDataType.SelectedValue = rec.Data_Type;
            }
            chkActive.Checked = rec.Active ?? false;
            btnSave.Text = "Update";
            lblMessage.Text = "";
            ShowSwal("info", "Editing record - " + (rec.ValueSet_Name ?? ""));
            txtName.Focus();
        }

        private void InactiveValueSet(int id)
        {
            var rec = db.ValueSets.FirstOrDefault(v => v.ValueSet_ID == id);
            if (rec == null)
            {
                ShowSwal("error", "Record not found");
                return;
            }

            if (rec.Active == false)
            {
                ShowSwal("warning", "Already inactive");
                return;
            }

            rec.Active = false;
            db.SubmitChanges();
            BindGrid();
            ShowSwal("success", "Value set marked inactive - " + (rec.ValueSet_Name ?? ""));
        }

        private void ReactivateValueSet(int id)
        {
            var rec = db.ValueSets.FirstOrDefault(v => v.ValueSet_ID == id);
            if (rec == null)
            {
                ShowSwal("error", "Record not found");
                return;
            }

            if (rec.Active == true)
            {
                ShowSwal("warning", "Already active");
                return;
            }

            rec.Active = true;
            db.SubmitChanges();
            BindGrid();
            ShowSwal("success", "Value set reactivated - " + (rec.ValueSet_Name ?? ""));
        }

        private void ShowSwal(string icon, string title)
        {
            string safe = title.Replace("'", "\\'");
            string js = "showVsToast('" + icon + "', '" + safe + "');";
            ScriptManager.RegisterStartupScript(this, this.GetType(),
                "vsSwal_" + Guid.NewGuid().ToString("N"), js, true);
        }
    }
}
