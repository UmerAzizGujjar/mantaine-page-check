using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class Customer : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
          
            if (!IsPostBack)
            {
                BuindeCity();
                BuindeCountry();
                ClearForm();
                if (Request.QueryString["ID"] != null)
                {
                    FillCustomerForm(Convert.ToInt32(Request.QueryString["ID"]));
                    //LoadGLAccount(Convert.ToInt32(Request.QueryString["ID"]));
                }
                //else
                //{
                //    LoadNewAccountToCreate();
                //}
            }
            lblMessage.Text = "";
        }

        private void LoadGLAccount(int? AccountID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var qury = (from a in db.GL_Accounts
                        where a.Account_ID == AccountID
                        select a).FirstOrDefault();
            if (qury != null)
            {
                hdfAccount_Serial.Value = qury.Account_Serial;
                hdfLevel.Value = qury.Levels.ToString();
                hdfParent_Code.Value = qury.Parent_Code.ToString();
                hdfAccount_Code.Value = qury.Account_Code;
                hdfAccount_Name.Value = qury.Account_Name;
                hdfAccount_ID.Value = qury.Account_ID.ToString();                
                //chbManually.Checked = true;
               
                
                //txtAccount_Code_Name.Text = qury.Account_ID.ToString();

                string Account_CodeAndName = qury.Account_Code.Trim() + " - " + qury.Account_Name.Trim();
                string inputString = String.Format(@"id:" + qury.Account_ID + @",name: '{0}'", Account_CodeAndName);

                //ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "clearToken", "$('#ctl00_MainContent_txtAccount_Code_Name').tokenInput('clear');", true);                
                //ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "tmp", "$('#ctl00_MainContent_txtAccount_Code_Name').tokenInput('jason.aspx',{prePopulate: [{id:68767,name:'atif test'}]});", true);                
                //ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "tmp", "$('#ctl00_MainContent_txtAccount_Code_Name').tokenInput('add', { " + inputString + " }); ", true);
                //ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "script", "$(function () { setvalue(); });", true);

                //hdfAccountExists.Value = "1";
            }
        }

        private void LoadNewAccountToCreate()
        {
            string sql = "";
            int level;
            string[] accountLength;
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            sys_Parm AccountPram = new sys_Parm();
            AccountPram = (from tbl in db.sys_Parms
                           where tbl.Name == "Customer" && tbl.Company_ID == AppConfig.Company_ID
                           select tbl).FirstOrDefault();
            if (AccountPram != null && AccountPram.Code != null)
            {
                GL_Account account = new GL_Account();

                var tbl = (from config in db.Configurations
                           where config.Configuration_Name == "Chart of Accounts Level"
                           select config).SingleOrDefault();
                accountLength = tbl.Configuration_Value.Split(',');
                sql = "Select account_id from gl_Accounts where  Account_Code='" + AccountPram.Code + "' and Book_ID=" + AppConfig.Book_ID;
                string value = DBClass.getField(sql);
                if (value == "There is no row at position 0.")
                {
                    hdfParent_Code.Value = AccountPram.Code.ToString();
                    lblMessage.Text = "No control node present for this customer in 'Chart of Accounts'.";

                }
                else
                    hdfParent_Code.Value = value;
                sql = "Select isNUll(MAX(Convert(int, Account_Serial)),0) from gl_accounts where parent_code=" + value;
                string maxcode = DBClass.getField(sql);
                int newcode = Convert.ToInt32(maxcode);
                newcode += 1;
                if (newcode > 999)
                {
                    hdfParent_Code.Value = "";
                    lblMessage.Text = "Create new control account for customers.";
                    return;
                }
                /*
                sql = "";
                sql = "Select isnull(Levels,0) from gl_Accounts where left(Account_Code,4)=" + AccountPram.Code;
                int LeveloFPerent = Convert.ToInt32(DBClass.getField(sql));
                level = LeveloFPerent + 1; //because the next level will be selected level +1
                 * */
                string newAccountcode = newcode.ToString("000");
                hdfAccount_Code.Value = AccountPram.Code + newAccountcode;
                hdfAccount_Serial.Value = newAccountcode;
                hdfLevel.Value = "4";
                //sql = "Select isNUll(MAX(Convert(int, Account_Serial)),0) from gl_accounts where left(Account_Code,4)=" + AccountPram.Code;
                //string maxcode = DBClass.getField(sql);
                //int newcode = Convert.ToInt32(maxcode);
                //newcode += 1;
                //sql = "";
                //sql = "Select isnull(Levels,0) from gl_Accounts where left(Account_Code,4)=" + AccountPram.Code;
                //int LeveloFPerent = Convert.ToInt32(DBClass.getField(sql));
                //level = LeveloFPerent + 1; //because the next level will be selected level +1
                //string newAccountcode = newcode.ToString(accountLength[level - 1]);
                //hdfAccount_Code.Value = AccountPram.Code + newAccountcode;
                //hdfAccount_Serial.Value = newAccountcode;
                //hdfLevel.Value = level.ToString();
                //sql = "Select parent_Code from gl_Accounts where levels=" + level + "AND left(Account_Code,4)=" + AccountPram.Code;
                //string value = DBClass.getField(sql);
                //if (value == "There is no row at position 0.")
                //{
                //    hdfParent_Code.Value = AccountPram.Code.ToString();
                //}
                //else
                //    hdfParent_Code.Value = value;
            }
            else
            {
                lblMessage.Text = "Please assign Customers account in sys_Params table.";
                lblMessage.CssClass = "errorMessage";
            }
        }

        private void BuindeCity()
        {
            object valueset;
            valueset = DBClass.GetValueSet("City");
            ddlCity.DataSource = valueset;
            ddlCity.DataTextField = "DataValue_Description";
            ddlCity.DataValueField = "DataValue_Name";
            ddlCity.DataBind();
            ddlCity.Items.Add(new ListItem("Please Select", "0"));

           
           
        }

        private void BuindeCountry()
        {
            object valueset; //declare a single object for all valueset
            valueset = DBClass.GetValueSet("Country");
            ddlCountry.DataSource = valueset;
            ddlCountry.DataTextField = "DataValue_Description";
            ddlCountry.DataValueField = "DataValue_Name";
            ddlCountry.DataBind();
            ddlCountry.Items.Add(new ListItem("Please Select", "0"));
        }

        private void ClearForm()
        {
            txtCustomer_ID.Text = "(New)";
            txtCustomer_Name.Text = "";
            txtFather_Name.Text = "";
            txtCustomer_Address.Text = "";
            txtCustomer_Permanent_Address.Text = "";
            txtCustoemer_Email.Text = "";
            txtCustoemer_Office_No.Text = "";
            txtCustoemer_Resident_No.Text = "";
            txtCustoemer_Email.Text = "";
            txtCustoemer_Fax_No.Text = "";
            txtCustoemer_CNIC.Text = "";
            txtCustomer_Mobile_No.Text = "";
            txtCustoemer_Occupation.Text = "";
            txtJob_Title.Text = "";
            txtCustomer_Website.Text = "";
            txtRemarks.Text = "";
            ddlCity.SelectedValue = "0";
            ddlCountry.SelectedValue = "0";
            btnSave.Text = "Save";
        }

        

        private void FillCustomerForm(int Customer_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            Ar_Customer customer = new Ar_Customer();

            customer = (from tbl in db.Ar_Customers
                        where tbl.Customer_ID == Customer_ID
                        select tbl).FirstOrDefault();
            if (customer != null)
            {
                txtCustomer_ID.Text = Convert.ToString(Customer_ID);
                txtCustomer_Name.Text = customer.Customer_Name;
                txtFather_Name.Text = customer.Father_Name;
                txtCustomer_Address.Text = customer.Customer_Address;
                txtCustomer_Permanent_Address.Text = customer.Custoemer_Permanet_Address;
                txtJob_Title.Text = customer.Customer_Job_Title;
                txtCustoemer_Email.Text = customer.Customer_Email;

                if (customer.City != null && ddlCity.Items.FindByValue(Convert.ToString(customer.City)) != null)
                    ddlCity.SelectedValue = Convert.ToString(customer.City);

                if (customer.Country != null && ddlCountry.Items.FindByValue(Convert.ToString(customer.Country)) != null)
                    ddlCountry.SelectedValue = Convert.ToString(customer.Country);

                txtCustoemer_Office_No.Text = customer.Custoemer_Office_Number;
                txtCustoemer_Resident_No.Text = customer.Custoemer_Resident_Number;
                txtCustomer_Mobile_No.Text = customer.Customer_Mobile_Number;
                txtCustoemer_Email.Text = customer.Customer_Email;
                txtCustomer_Website.Text = customer.Customer_Website;
                txtRemarks.Text = customer.Remarks;
                txtCustoemer_Fax_No.Text = customer.Customer_Fax_Number;
                txtCustoemer_CNIC.Text = customer.Customer_CNIC;
                txtCustoemer_Occupation.Text = customer.Customer_Occupation;

                if (customer.Account_ID != null)
                {
                    LoadGLAccount(customer.Account_ID);
                }
                btnSave.Text = "Update";
            }
        }
        protected void btnSave_Click(object sender, EventArgs e)
        {
            lblMessage.Text = "";
            int accountID = 0;
            //if (txtAccountName.Text != "")
            //    accountID = Convert.ToInt32(txtAccountName.Text);
            if (!Page.IsValid)
                return;
            using(DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                Ar_Customer customer;
                GL_Account accounts = new GL_Account();
                if (btnSave.Text == "Save")
                {
                    customer = new Ar_Customer();
                }
                else
                {
                    customer = (from tbl in db.Ar_Customers
                                where tbl.Customer_ID == Convert.ToInt32(txtCustomer_ID.Text)
                                select tbl).FirstOrDefault();
                }

                try
                {
                    //LoadNewAccountToCreate();
                }
                catch
                {
                    return;
                }
                if (hdfAccount_Code.Value != "")
                {
                    /*
                    accountID = Convert.ToInt32(hdfAccount_ID.Value);
                    accounts = (from tbl in db.GL_Accounts
                                where tbl.Account_ID == accountID
                                select tbl).FirstOrDefault();
                    accounts.Account_Name = txtCustomer_Name.Text;
                    db.SubmitChanges();*/
                    accountID = Convert.ToInt32(hdfAccount_ID.Value);
                }
                else
                {
                    LoadNewAccountToCreate();
                    if (hdfParent_Code.Value == "")
                        return;
                    accounts.Account_Name = txtCustomer_Name.Text;
                    accounts.Account_Code = hdfAccount_Code.Value;
                    accounts.Parent_Code = Convert.ToInt32(hdfParent_Code.Value);
                    accounts.Levels = Convert.ToInt32(hdfLevel.Value);
                    accounts.Account_Serial = hdfAccount_Serial.Value;
                    accounts.Active = true;
                    accounts.Book_ID = AppConfig.Book_ID;
                    db.GL_Accounts.InsertOnSubmit(accounts);
                    db.SubmitChanges();
                    accountID = accounts.Account_ID;
                }

                customer.Book_ID = AppConfig.Book_ID;
                customer.Company_ID = AppConfig.Company_ID;
                customer.Customer_Name = txtCustomer_Name.Text;
                customer.Father_Name = txtFather_Name.Text;
                customer.Customer_Address = txtCustomer_Address.Text;
                customer.Custoemer_Permanet_Address = txtCustomer_Permanent_Address.Text;
                customer.Customer_Job_Title = txtJob_Title.Text;
                customer.Custoemer_Office_Number = txtCustoemer_Office_No.Text;
                customer.Custoemer_Resident_Number = txtCustoemer_Resident_No.Text;
                customer.Customer_Mobile_Number = txtCustomer_Mobile_No.Text;
                customer.Customer_Fax_Number = txtCustoemer_Fax_No.Text;
                customer.Customer_Email = txtCustoemer_Email.Text;
                customer.Customer_Website = txtCustomer_Website.Text;
                customer.Customer_Occupation = txtCustoemer_Occupation.Text;
                customer.Customer_CNIC = txtCustoemer_CNIC.Text;
                customer.Remarks = txtRemarks.Text;

                customer.Account_ID = accountID;
                if (ddlCity.SelectedValue != "0")
                    customer.City = ddlCity.SelectedValue;
                if (ddlCountry.SelectedValue != "0")
                    customer.Country = ddlCountry.SelectedValue;
                if (btnSave.Text == "Save")
                {
                    db.Ar_Customers.InsertOnSubmit(customer);
                    lblMessage.Text = "Data has been save sucessfully";
                }
                else
                {
                    lblMessage.Text = "Data has been update sucessfully";
                }
                db.SubmitChanges();
            }
            ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "clearToken", "$('#ctl00_MainContent_txtAccount_Code_Name').tokenInput('clear');", true);
            ClearForm();
            Response.Redirect("~/AR/CustomerView.aspx", true);
            lblMessage.CssClass = "sucessfullMessage";
        }
    }
}