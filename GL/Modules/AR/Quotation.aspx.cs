using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Configuration;
using System.Data.SqlClient;
namespace PMS
{
    public partial class WebForm7 : System.Web.UI.Page
    {
        DataTable dt;
        DataBaseDataContext db;
        string connectionString = ConfigurationManager.ConnectionStrings["ASPGLConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!Page.IsPostBack)
            {
                BlankForm();
                BindDropDownList();
               
               txtQuotation_No.Text = "(New)";
               TxtQuotation_Status.Text = "Created";
             
                if (Request.QueryString["ID"] != null)
                {
                    fill(Request.QueryString["ID"]);
                }
                else
                {
                    txtQuotation_Date.Text = DateTime.Now.ToString(AppConfig.DateFormat);
            }

            }
            else
            {
                dt = Session["QuotationTable"] as DataTable;
                GRD.DataSource = dt;
                GRD.DataBind();
            }
        }
        private void BlankForm()
        {
            //Grid part
            dt = new DataTable();
            Session["QuotationTable"] = dt;
            DataColumn[] keys = new DataColumn[1];
            DataColumn index = new DataColumn("Index", Type.GetType("System.Int32"));
            DataColumn item_ID = new DataColumn("Item_ID", Type.GetType("System.Int32"));
            DataColumn item_Description = new DataColumn("Item_Description", Type.GetType("System.String"));
            DataColumn stock_Status = new DataColumn("Stock_Status", Type.GetType("System.String"));
            DataColumn qty = new DataColumn("Qty", Type.GetType("System.Double"));
            DataColumn rate = new DataColumn("Rate", Type.GetType("System.Double"));
            DataColumn amount = new DataColumn("Amount", Type.GetType("System.Double"));
            dt.Columns.Add(index);
            dt.Columns.Add(item_ID);
            dt.Columns.Add(item_Description);
            dt.Columns.Add(stock_Status);
            dt.Columns.Add(qty);
            dt.Columns.Add(rate);
            dt.Columns.Add(amount);
            keys[0] = index;
            dt.PrimaryKey = keys;
            GRD.DataSource = dt;
            GRD.DataBind();
        }
        private void BindDropDownList()
        {
            DataTable dtCustomer = new DataTable();
            dtCustomer = DBClass.getDataTable("select Customer_ID,Customer_Name from Ar_Customers");

            ddlCustomer.DataSource = dtCustomer;
            ddlCustomer.DataTextField = "Customer_Name";
            ddlCustomer.DataValueField = "Customer_ID";
            ddlCustomer.Items.Add(new ListItem("Please Select", "0"));
            ddlCustomer.DataBind();

            DataTable dtTerm_Contion = new DataTable();
            dtTerm_Contion = DBClass.getDataTable("select  Term_ID,Term_Name from Terms_and_conditions ");

            ddlTerm_and_Condition.DataSource = dtTerm_Contion;
            ddlTerm_and_Condition.DataTextField = "Term_Name";
            ddlTerm_and_Condition.DataValueField = "Term_ID";
            ddlTerm_and_Condition.Items.Add(new ListItem("Please Select", "0"));
            ddlTerm_and_Condition.DataBind();


        }

        protected void btnAdd_Click(object sender, EventArgs e)
        {
            try
            {

                //btnAdd.Enabled = false;
                // string temp = txtDebit.Text;
               

                Boolean bol = Convert.ToBoolean(ViewState["check"]);                
                int Index = Convert.ToInt32(ViewState["Index"]);
                string itemID = hdfItem_ID.Value;
                string itemDescription = hdfItem_Description.Value;

                if (itemID != "")
                {
                    if (bol == true)
                    {
                        bol = false;
                        //DataRow[] row = dt.Select("Account_Id = '" + Accountid + "'");
                       
                        DataRow[] row = dt.Select("Index = '" + Index + "'");
                        row[0]["Index"] = Index;
                        row[0]["Item_ID"] = itemID;
                        row[0]["Item_Description"] = itemDescription;
                        row[0]["Stock_Status"] = txtStock_Status.Text;
                        row[0]["Qty"] = txtQty.Text;
                        row[0]["Rate"] = txtRate.Text;
                        row[0]["Amount"] = Math.Round(Convert.ToDouble(txtQty.Text) * Convert.ToDouble(txtRate.Text), 2); ;                                              
                        ViewState.Remove("check");
                        ViewState.Add("check", bol);
                        btnAdd.Text = "Add";
                    }
                    else
                    {
                            DataRow row = dt.NewRow();
                            string index;
                            index = Convert.ToString(dt.Compute("Max(Index)", ""));
                            if (index != "")
                                index = Convert.ToString(Convert.ToInt32(index) + 1);
                            else
                                index = "0";
                            row["Index"] = index;
                            row["Item_ID"] = itemID;
                            row["Item_Description"] = itemDescription;
                            row["Stock_Status"] = txtStock_Status.Text;
                            row["Qty"] = txtQty.Text;
                            row["Rate"] = txtRate.Text;
                            row["Amount"] = Math.Round(Convert.ToDouble(txtQty.Text) * Convert.ToDouble(txtRate.Text), 2); //txtAmount.Text;   
                            dt.Rows.Add(row);
                        }
                    }
               // }
                else
                {
                    //for (int i = 0; i < Account_IDs.Count(); i++)
                    //{
                    if (bol == true)
                    {
                        bol = false;
                        //DataRow[] row = dt.Select("Account_Id = '" + Accountid + "'");
                        DataRow[] row = dt.Select("Index = '" + Index + "'");
                        row[0]["Index"] = Index;
                        row[0]["Item_ID"] = itemID;
                        row[0]["Item_Description"] = itemDescription;
                        row[0]["Stock_Status"] = txtStock_Status.Text;
                        row[0]["Qty"] = txtQty.Text;
                        row[0]["Rate"] = txtRate.Text;
                        row[0]["Amount"] = Math.Round(Convert.ToDouble(txtQty.Text) * Convert.ToDouble(txtRate.Text), 2);   
                        ViewState.Remove("check");
                        ViewState.Add("check", bol);
                    }
                    else
                    {
                        if (txtRate.Text == "" || txtQty.Text == "")
                        {
                            lblValidation.Text = "Rate and Qty fields are required.";
                            return;
                        }
                        else
                        {
                            DataRow row = dt.NewRow();
                            string index;
                            index = Convert.ToString(dt.Compute("Max(Index)", ""));
                            if (index != "")
                                index = Convert.ToString(Convert.ToInt32(index) + 1);
                            else
                                index = "0";
                            row["Index"] = Index;
                            row["Item_ID"] = itemID;
                            row["Item_Description"] = itemDescription;
                            row["Stock_Status"] = txtStock_Status.Text;
                            row["Qty"] = txtQty.Text;
                            row["Rate"] = txtRate.Text;
                            row["Amount"] = Math.Round(Convert.ToDouble(txtQty.Text) * Convert.ToDouble(txtRate.Text), 2);   
                            dt.Rows.Add(row);
                        }
                        // }
                    }
                }

                decimal subTotal = 0M;
                if (dt.Rows.Count == 0)
                    subTotal = 0;
                else
                    subTotal = Convert.ToDecimal(dt.Compute("Sum(Amount)", ""));
                txtSub_Total.Text = subTotal.ToString();
              
                ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "", " NetAmount();", true);
                ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "addToken", "loadtokenInputsDefault();", true);
                ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "clearToken", "$('#ctl00_MainContent_txtItem_Description').tokenInput('clear');", true);
                GRD.DataSource = dt;
                GRD.DataBind();
                Cleartxt();
                //btnAdd.Enabled = true;
            }
            catch (Exception exc)
            {
                lblValidation.Text = exc.Message;
            }
        }

        private void Cleartxt()
        {
            txtQty.Text = "";
            txtAmount.Text = "";
            txtRate.Text = "";
            hdfItem_Description.Value = "";
            hdfItem_ID.Value = "";
            txtStock_Status.Text = "";
            txtItem_Description.Text = "";
        }

        protected void BtnDelete_Click(object sender, EventArgs e)
        {

            Boolean bol = Convert.ToBoolean(ViewState["check"]);
            int Index = Convert.ToInt32(ViewState["Index"]);

            if (bol == true)
            {
                bol = false;
                //DataRow[] dr = dt.Select("Account_Id = '" + Accountid + "'");
                DataRow[] dr = dt.Select("Index = '" + Index + "'");
                dt.Rows.Remove(dr[0]);
                dt.AcceptChanges();
                Session["QuotationTable"] = dt;
                ViewState.Remove("check");
                ViewState.Add("check", bol);
                ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "clearToken", "$('#ctl00_MainContent_txtAccountName').tokenInput('clear');", true);
                Cleartxt();
                GRD.DataSource = dt;
                GRD.DataBind();

                decimal subTotal = 0M;
                 if (dt.Rows.Count == 0)
                    subTotal = 0;
                else
                     subTotal = Convert.ToDecimal(dt.Compute("Sum(Amount)", ""));
                 txtSub_Total.Text = subTotal.ToString();

                 var Quotation_Amount = Convert.ToDecimal((txtSub_Total.Text == "" ? "0" : txtSub_Total.Text))
                     + Convert.ToDecimal((txtImport_Frieght_Charges.Text == "" ? "0" : txtImport_Frieght_Charges.Text))
                     + Convert.ToDecimal((txtExport_Frieght_Charges.Text == "" ? "0" : txtExport_Frieght_Charges.Text))
                     + Convert.ToDecimal((txtDel_Charges.Text == "" ? "0" : txtDel_Charges.Text))
                     + Convert.ToDecimal((txtBank_TT_Charges.Text == "" ? "0" : txtBank_TT_Charges.Text))
                     + Convert.ToDecimal((txtCutom_DOC_Charges.Text == "" ? "0" : txtCutom_DOC_Charges.Text))
                     - Convert.ToDecimal((txtDiscount.Text == "" ? "0" : txtDiscount.Text));

                 TxtQuotation_Amount.Text = Quotation_Amount.ToString();
                 
                btnAdd.Text = "Add";
            }
        }

        protected void GRD_SelectedIndexChanging(object sender, GridViewSelectEventArgs e)
        {
            btnAdd.Text = "Update";
            Boolean bol = true;
            ViewState.Remove("check");
            ViewState.Add("check", bol);
            Label lblItem_ID = (Label)GRD.Rows[e.NewSelectedIndex].FindControl("lblItem_ID");
            Label lblIndex = (Label)GRD.Rows[e.NewSelectedIndex].FindControl("lblIndex");
            int ItemID = Convert.ToInt32(lblItem_ID.Text);
            int Index = Convert.ToInt32(lblIndex.Text);
            ViewState.Add("Item_ID", ItemID);
            ViewState.Add("Index", Index);
            //DataRow[] row = dt.Select("Account_Id = '" + Accountid + "'");
            DataRow[] row = dt.Select("Index = '" + Index + "'");

            //int id = Convert.ToInt32(row[0]["Account_Id"]);
            string itemDescription = Convert.ToString(row[0]["Item_Description"]);
            string stockStatus = Convert.ToString(row[0]["Stock_Status"]);
            string qty = Convert.ToString(row[0]["Qty"]);
            string rate = Convert.ToString(row[0]["Rate"]);
            string amount = Convert.ToString(row[0]["Amount"]);

            txtQty.Text = qty;
            txtRate.Text = rate;
            txtAmount.Text = amount;
            txtStock_Status.Text = stockStatus;
            hdfItem_ID.Value = ItemID.ToString();
            hdfItem_Description.Value = itemDescription;

            ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "addToken", "loadtokenInputsDefault();", true);
            string inputString = String.Format(@"id:" + ItemID + @",name: '{0}'", itemDescription);
            if (hdfItem_Description.Value != "")
                ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "clearToken", "$('#ctl00_MainContent_txtItem_Description').tokenInput('clear');", true);
            ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "tmp", "$('#ctl00_MainContent_txtItem_Description').tokenInput('add', { " + inputString + " });", true);
            


            e.NewSelectedIndex = -1;
            e.Cancel = true;
            upQuotationForm.Update();
        }
        protected void GRD_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            //if (e.Row.RowType == DataControlRowType.Footer)
            //{
            //    Label lblDebitTotal = e.Row.FindControl("lbl") as Label;
            //    Label lblCreditTotal = e.Row.FindControl("lblCreditTotal") as Label;
            //    decimal debit = 0M;
            //    decimal credit = 0M;
            //    debit = Convert.ToDecimal(dt.Compute("Sum(Debit)", ""));
            //    credit = Convert.ToDecimal(dt.Compute("Sum(Credit)", ""));
            //    lblDebitTotal.Text = debit.ToString("n2");
            //    lblCreditTotal.Text = credit.ToString("n2");
            //}
            //else if (e.Row.RowType == DataControlRowType.DataRow)
            //{
            //    Label lblCost_Center = e.Row.FindControl("lblCost_Center") as Label;
            //    if (lblCost_Center != null && ddlCostCenter.Items.FindByValue(lblCost_Center.Text) != null)
            //        lblCost_Center.Text = ddlCostCenter.Items.FindByValue(lblCost_Center.Text).Text;
            //}
        }

       
            protected void btnSave_Click(object sender, EventArgs e)
        {

            AR_Quotation Q;
            db = new DataBaseDataContext(connectionString);
            int count = dt.Rows.Count;
            if (count == 0)
            {
                lblMessage.Text = "Please Add Atlest One Item";
            }
            else
            {
                try
                {
                    if (btnSave.Text == "Save")
                    {
                        #region "New Quotation"
                         Q = new AR_Quotation();

                        int NewID = DBClass.GetNewNumber("Quotation_No", "AR_Quotations", "Where Company_ID=" + AppConfig.Company_ID + "");
                        txtQuotation_No.Text = NewID.ToString();

                       
                        
                        #endregion
                    }
                    else
                    {
                        #region "Edit voucher"
                        int Quote_ID = Convert.ToInt32(Request.QueryString["ID"]);
                       Q = (from tbl in db.AR_Quotations
                            where tbl.Quotation_ID == Quote_ID
                                        select tbl).SingleOrDefault();

                      


                       Q.Updated_By = AppConfig.UserID;
                       Q.Update_Time = DateTime.Now;
                     

                        
                        #endregion
                    }

                    Q.Quotation_Date = Convert.ToDateTime((txtQuotation_Date.Text).ToString());
                    Q.Quotation_No = Convert.ToInt32(txtQuotation_No.Text);
                    Q.Ref_No = txtRef_No.Text;
                    Q.Customer_ID = Convert.ToInt32(ddlCustomer.SelectedValue);
                    Q.Quotation_Status = TxtQuotation_Status.Text;
                    Q.Remarks = txtRemarks.Text;
                    Q.Sub_Total = Convert.ToDecimal(txtSub_Total.Text);
                    Q.Discount = Convert.ToDecimal(txtDiscount.Text);
                    Q.Import_Freight_Charges = Convert.ToDecimal(txtImport_Frieght_Charges.Text);
                    Q.Export_Frieght_Charges = Convert.ToDecimal(txtExport_Frieght_Charges.Text);
                    Q.Local_Del_Charges = Convert.ToDecimal(txtDel_Charges.Text);
                    Q.Bank_TT_Charges = Convert.ToDecimal(txtBank_TT_Charges.Text);
                    Q.Customer_Docs_Charges = Convert.ToDecimal(txtCutom_DOC_Charges.Text);

                    Q.Term_ID = Convert.ToInt32(ddlTerm_and_Condition.SelectedValue);

                    var Quotation_Amount = Convert.ToDecimal((txtSub_Total.Text == "" ? "0" : txtSub_Total.Text))
                    + Convert.ToDecimal((txtImport_Frieght_Charges.Text == "" ? "0" : txtImport_Frieght_Charges.Text))
                    + Convert.ToDecimal((txtExport_Frieght_Charges.Text == "" ? "0" : txtExport_Frieght_Charges.Text))
                    + Convert.ToDecimal((txtDel_Charges.Text == "" ? "0" : txtDel_Charges.Text))
                    + Convert.ToDecimal((txtBank_TT_Charges.Text == "" ? "0" : txtBank_TT_Charges.Text))
                    + Convert.ToDecimal((txtCutom_DOC_Charges.Text == "" ? "0" : txtCutom_DOC_Charges.Text))
                    - Convert.ToDecimal((txtDiscount.Text == "" ? "0" : txtDiscount.Text));

                    Q.Quotation_Amount = Convert.ToDecimal(Quotation_Amount);
                    Q.Created_By = AppConfig.UserID;
                    Q.Creation_Time = DateTime.Now;
                    Q.Company_ID = AppConfig.Company_ID;
                   
                    int quotationID;
                    if (btnSave.Text == "Save")
                    {
                        db.AR_Quotations.InsertOnSubmit(Q);
                        db.SubmitChanges();
                        quotationID = Q.Quotation_ID;
                    }
                        
                    
                    else
                    {
                        quotationID = Q.Quotation_ID;
                        var QT_item = (from item in db.AR_Quotation_Items
                                       where item.Quotation_ID == quotationID
                                       select item);
                        db.AR_Quotation_Items.DeleteAllOnSubmit(QT_item);
                    }
                    DataRow[] rows = dt.Select();
                    for (int i = 0; i < count; i++)
                    {
                        int Item_ID = Convert.ToInt32(rows[i]["Item_ID"]);
                        string Stock_Status = Convert.ToString(rows[i]["Stock_Status"]);
                        string Qty = Convert.ToString(rows[i]["Qty"]);
                        string Rate = Convert.ToString(rows[i]["Rate"]);
                        string Amount = Convert.ToString(rows[i]["Amount"]);


                        AR_Quotation_Item Quot_Item = new AR_Quotation_Item();
                        
                        Quot_Item.Quotation_ID = quotationID;
                        Quot_Item.Item_ID = Item_ID;
                        Quot_Item.Stock_Status = Stock_Status;
                        Quot_Item.Qty = (Qty == "") ? 0 : Convert.ToDecimal(Qty);
                        Quot_Item.Rate = (Rate == "") ? 0 : Convert.ToDecimal(Rate);
                        Quot_Item.Amount = (Amount == "") ? 0 : Convert.ToDecimal(Amount);



                        db.AR_Quotation_Items.InsertOnSubmit(Quot_Item);
                        db.SubmitChanges();
                    }

                    if (btnSave.Text == "Save")
                    {
                        
                        lblMessage.CssClass = "SuccessfullMessage";
                        lblMessage.Text = "Quotation has been successfully saved";
                    }
                    else
                    {
                        lblMessage.CssClass = "SuccessfullMessage";
                        lblMessage.Text = "Quotation has been successfully Updated";
                    }

                    db.SubmitChanges();
                    Response.Redirect("~/AR/QuotationView.aspx", true);

                    
                   }

                catch (Exception exc)
                {
                    lblMessage.CssClass = "errorMessage";
                    lblMessage.Text = exc.Message;
                }

              
            }
        }


            public void fill(string id)
            {
                try
                {

                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());



                    AR_Quotation Quote = (from tbl in db.AR_Quotations
                                          where tbl.Quotation_ID == Convert.ToInt32(id)
                                          select tbl).FirstOrDefault();

                    txtQuotation_No.Text = Quote.Quotation_No.ToString();
                    TxtQuotation_Status.Text = Quote.Quotation_Status;
                    txtRef_No.Text = Quote.Ref_No;
                    txtQuotation_Date.Text = Quote.Quotation_Date.Value.ToString(AppConfig.DateFormat);
                    txtRemarks.Text = Quote.Remarks;
                    txtSub_Total.Text = Quote.Sub_Total.ToString();
                    txtDiscount.Text = Quote.Discount.ToString();
                    txtImport_Frieght_Charges.Text = Quote.Import_Freight_Charges.ToString();
                    txtExport_Frieght_Charges.Text = Quote.Export_Frieght_Charges.ToString();
                    txtDel_Charges.Text = Quote.Local_Del_Charges.ToString();
                    txtBank_TT_Charges.Text = Quote.Bank_TT_Charges.ToString();
                    txtCutom_DOC_Charges.Text = Quote.Customer_Docs_Charges.ToString();
                    TxtQuotation_Amount.Text = Quote.Quotation_Amount.ToString();
                    ddlCustomer.SelectedValue = Quote.Customer_ID.ToString();
                    ddlTerm_and_Condition.SelectedValue = Quote.Term_ID.ToString();
                      
                        //load Item detail
                        var qry = (from tbl in db.AR_Quotation_Items
                                   join INV in db.INV_Items
                               on tbl.Item_ID equals INV.Item_ID
                                    where tbl.Quotation_ID == Convert.ToInt32(id)
                                   select new
                                   {
                                       tbl.Quotation_ID,
                                       tbl.Item_ID,
                                       tbl.Stock_Status,
                                       tbl.Qty,
                                       tbl.Rate,
                                       tbl.Amount,
                                       INV.Item_Code,
                                       INV.Description
                                      
                                   }).ToList();
                        Int32 index = 0;
                        dt.Rows.Clear();
                        foreach (var item in qry)
                        {
                            
                            DataRow row = dt.NewRow();
                            row["Index"] = index;
                            row["Item_ID"] = item.Quotation_ID;
                            row["Item_Description"] = item.Item_Code +"-"+ item.Description;
                            row["Stock_Status"] = item.Stock_Status;
                            row["Qty"] = item.Qty;
                            row["Rate"] = item.Rate;
                            row["Amount"] = item.Amount;
                           
                            dt.Rows.Add(row);
                            index++;
                        }
                        GRD.DataSource = dt;
                        GRD.DataBind();

                    

                }
                catch (Exception ex)
                {
                    lblMessage.CssClass = "errorMessage";
                    lblMessage.Text = ex.Message;
                }

                btnSave.Text = "Update";
            }


        }


        


    }
     
