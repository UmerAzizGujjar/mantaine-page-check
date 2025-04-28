using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Configuration;
using System.Data;

namespace PMS
{
    public partial class Company : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
         
            lblMessage.Text = "";
            if (!IsPostBack)
            {
                BindSetOfBook();
                if (Request.QueryString["ID"] != null)
                {
                    PopulateCompanyData(Convert.ToInt32(Request.QueryString["ID"]));
                }
                else
                    txtCompany_ID.Text = "(New)";
            }
        }

        private void BindSetOfBook()
        {
            DataTable dtbSetOfBooks = new DataTable();
            dtbSetOfBooks = DBClass.getDataTable("Select * from GL_SetOfBook");
            ddlSetOfBookID.DataSource = dtbSetOfBooks;

            ddlSetOfBookID.DataTextField = "Name";
            ddlSetOfBookID.DataValueField = "Book_ID";
            ddlSetOfBookID.Items.Add(new ListItem("Please Select", "0"));
            ddlSetOfBookID.DataBind();
        }

        private void PopulateCompanyData(int Company_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            sys_Company company = (from tbl in db.sys_Companies
                                   where tbl.Company_ID == Company_ID
                                   select tbl).FirstOrDefault();
            if (company != null)
            {
                txtCompany_Email.Text = company.Company_Email;
                txtCompany_Address.Text = company.Company_Address;
                txtCompany_Fax.Text = txtCompany_Fax.Text;
                txtCompany_ID.Text = company.Company_ID.ToString();
                txtCompany_Name.Text = company.Company_Name;
                txtCompany_Phone1.Text = company.Company_Phone1;
                txtCompany_Phone2.Text = company.Company_Phone2;
                txtCompany_UserField1.Text = company.Company_UserField1;
                txtCompany_UserField2.Text = company.Company_UserField2;
                txtCompany_UserField3.Text = company.Company_UserField3;
                txtCompany_SalesTax_No.Text = company.Company_SalesTax_No;
                txtCompany_NTN_No.Text = company.Company_NTN_No;
                txtCompany_Fical_Year.Text = company.Company_Fiscal_Year;
                if (company.Auto_Posting == true)
                    cbAutoPosting.Checked = true;
                if (company.Company_Image != null)
                {
                    imgCompany_Image.ImageUrl = "~/ImageHandler.ashx?ID=" + company.Company_ID;
                    ViewState["Company_Image"] = company.Company_Image;
                }
                if (ddlSetOfBookID.Items.FindByValue(Convert.ToString(company.Book_ID)) != null)
                    ddlSetOfBookID.SelectedValue = Convert.ToString(company.Book_ID);
                btnSave.Text = "Update";
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid)
                return;

            try
            {
                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                    sys_Company company;
                    if (btnSave.Text == "Save")
                    {
                        company = new sys_Company();
                    }
                    else
                    {
                        company = (from tbl in db.sys_Companies
                                   where tbl.Company_ID == Convert.ToInt32(txtCompany_ID.Text)
                                   select tbl).FirstOrDefault();
                    }
                    company.Company_Address = txtCompany_Address.Text;
                    company.Company_Email = txtCompany_Email.Text;
                    company.Company_Fax = txtCompany_Fax.Text;
                    company.Company_Name = txtCompany_Name.Text;
                    company.Company_Phone1 = txtCompany_Phone1.Text;
                    company.Company_Phone2 = txtCompany_Phone2.Text;
                    company.Company_UserField1 = txtCompany_UserField1.Text;
                    company.Company_UserField2 = txtCompany_UserField2.Text;
                    company.Company_UserField3 = txtCompany_UserField3.Text;
                    company.Company_SalesTax_No = txtCompany_SalesTax_No.Text;
                    company.Company_NTN_No = txtCompany_NTN_No.Text;
                    company.Company_Fiscal_Year = txtCompany_Fical_Year.Text;
                    if (cbAutoPosting.Checked == true)
                        company.Auto_Posting = true;
                    else
                        company.Auto_Posting = false;

                    FileUpload img = (FileUpload)fluImage;
                    Byte[] imgByte = null;
                    if (img.HasFile && img.PostedFile != null)
                    {
                        HttpPostedFile File = fluImage.PostedFile;
                        imgByte = new Byte[File.ContentLength];
                        File.InputStream.Read(imgByte, 0, File.ContentLength);
                    }
                    if (ddlSetOfBookID.SelectedValue != "0")
                        company.Book_ID = Convert.ToInt32(ddlSetOfBookID.SelectedValue);
                    if (btnSave.Text == "Save")
                    {
                        if (fluImage.HasFile)
                            company.Company_Image = imgByte;
                        db.sys_Companies.InsertOnSubmit(company);
                        lblMessage.Text = "Data has been save sucessfully";
                    }
                    else
                    {
                        if (fluImage.HasFile)
                            company.Company_Image = imgByte;
                        else if (ViewState["Company_Image"] != null)
                            company.Company_Image = (System.Data.Linq.Binary)ViewState["Company_Image"];
                        lblMessage.Text = "Data has been update sucessfully";
                    }
                    db.SubmitChanges();
                    lblMessage.CssClass = "sucessfullMessage";
                    Response.Redirect("~/CompanyView.aspx", false);
            }
            catch (Exception ex)
            {
                throw;
            }
        }
    }
}