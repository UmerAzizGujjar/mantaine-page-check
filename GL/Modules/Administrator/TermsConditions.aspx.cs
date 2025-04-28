using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
//using Infragistics.WebUI.WebHtmlEditor;
using System.Text.RegularExpressions;

namespace PMS
{
    public partial class TermsConditions : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Request.QueryString["ID"] != null)
                {
                    PopulateEmployeeData(Convert.ToInt32(Request.QueryString["ID"]));
                }
                else
                    txtTerm_ID.Text = "(New)";
            }
        }

        private void PopulateEmployeeData(int Term_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            Terms_and_condition term = (from tbl in db.Terms_and_conditions
                                        where tbl.Term_ID == Term_ID
                                    select tbl).FirstOrDefault();
            if (term != null)
            {
                txtTerm_ID.Text = term.Term_ID.ToString();
                txtTerm_Name.Text = term.Term_Name;
                txtTerm_Description.Text = term.Term_Description;
                btnSave.Text = "Update";
            }
        }

        public static string RemoveHTMLTags(string content)
        {
            var cleaned = string.Empty;
            try
            {
                string textOnly = string.Empty;
                Regex tagRemove = new Regex(@"<[^>]*(>|$)");
                Regex compressSpaces = new Regex(@"[\s\r\n]+");
                textOnly = tagRemove.Replace(content, string.Empty);
                textOnly = compressSpaces.Replace(textOnly, " ");
                cleaned = textOnly;
            }
            catch
            {
                //A tag is probably not closed. fallback to regex string clean.
            }

            return cleaned;
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                if (!Page.IsValid)
                    return;

                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                Terms_and_condition term;
                if (btnSave.Text == "Save")
                {
                    term = new Terms_and_condition();
                    term.Created_By = AppConfig.UserID;
                    term.Created_Time = DateTime.Now;
                }
                else
                {
                    term = (from tbl in db.Terms_and_conditions
                                where tbl.Term_ID == Convert.ToInt32(txtTerm_ID.Text)
                                select tbl).FirstOrDefault();
                    term.Updated_By = AppConfig.UserID;
                    term.Updated_Time = DateTime.Now;
                }
                    term.Term_Name = txtTerm_Name.Text;
                    term.Term_Description = Server.HtmlDecode(txtTerm_Description.Text);
                    //term.Term_Description = RemoveHTMLTags(txtTerm_Description.Text);
                    term.Company_ID = AppConfig.Company_ID;

                    if (btnSave.Text == "Save")
                    {
                        db.Terms_and_conditions.InsertOnSubmit(term);
                        lblMessage.CssClass = "Data Inserted Successfully";
                    }
                    else
                    {
                        lblMessage.CssClass = "Data Updated Successfully";
                    }
                    db.SubmitChanges();
                    Response.Redirect("~/TermsConditionsView.aspx", false);
                }

            
            catch (Exception ex)
            {
                throw;
            }
        }
    }
}