using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;

namespace PMS
{
    public partial class LookupControl : System.Web.UI.UserControl
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                //GetAccounts(SqlCommand);
                //FillDropDownList();
                //BindGrid();
            }
            //string searchOn = ddlFields.SelectedItem.Text;
        }
        public void BindGrid()
        {
            DataTable tbl = DBClass.getDataTable(SqlCommand);
            if (tbl.Rows.Count == 0)
                throw new Exception();
            gvLookup.DataSource = tbl;
            gvLookup.DataBind();
            gvLookup.HeaderRow.Cells[1].Visible = false;
            foreach (GridViewRow gvr in gvLookup.Rows)
            {
                gvr.Cells[1].Visible = false;
            }
            Session["lookup"] = tbl;
            DataView dv = new DataView(tbl);
            Session["PaggingLookup"] = dv;
        }
        public void FillDropDownList()
        {
            if (SqlCommand == "")
                return;
            ddlFields.Items.Clear();
            DataTable dt = new DataTable();
            dt = DBClass.getDataTable(SqlCommand);
            int i = 1;
            foreach (DataColumn dc in dt.Columns)
            {
                if (dc.ColumnName != HideColumnName)
                {
                    ListItem li = new ListItem(dc.ColumnName, dc.DataType.Name + "." + i);
                    ddlFields.Items.Add(li);
                    i++;
                }
            }
            ddlFields.SelectedIndex = DefaultSearchColumnID;
            
        }
        private string _HideColumnName;
        public string HideColumnName
        {
            get { return _HideColumnName; }
            set { _HideColumnName = value; }
        }
        private int _ReturnColumnID;
        public int ReturnColumnID
        {
            get { return _ReturnColumnID; }
            set { _ReturnColumnID = value; }
        }
        private int _DefaultSearchColumnID;
        public int DefaultSearchColumnID
        {
            get { return _DefaultSearchColumnID; }
            set { _DefaultSearchColumnID = value; }
        }
        public string SqlCommand
        {
            get
            {
                return Convert.ToString(ViewState["Command"]);
            }
            set
            {
                ViewState.Remove("Command");
                ViewState.Add("Command", value);
            }
        }
        public string ReturnId
        {
            get
            {
                return ViewState["ReturnId"].ToString();
            }
            set
            {
                ViewState.Add("ReturnId", value);
            }
        }        
        public string TableName
        {
            get
            {
                return Convert.ToString(ViewState["TableName"]);
            }
            set
            {
                
                ViewState.Add("TableName", value);
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            try
            {
                string texttosearch = txtCodeSearch.Text;
                string cmd = SqlCommand;
                SearchRecords(cmd, texttosearch);
            }
            catch (Exception exc)
            {
                throw new Exception(exc.Message);
            }
        }
        //private int getReturnColumnIndex()
        //{
        //    for (int i = 0; i < gvLookup.Columns.Count; i++)
        //    {
        //        if (ReturnColumnName == gvLookup.Columns[i].HeaderText)
        //        {
        //            return i;                    
        //        }
        //    }
        //    return 1;  //default 1st column
        //}
        private void SearchRecords(string command, string text)
        {
            DataTable dtbl = ((System.Data.DataTable)Session["Lookup"]);
            DataView dv = new DataView(dtbl);
            string dataType = ddlFields.SelectedItem.Value;
            dataType = dataType.Substring(0,dataType.IndexOf("."));
            string searchOn = ddlFields.SelectedItem.Text;
            string filterExpression = string.Empty;
            string searchText = txtCodeSearch.Text;
            if (txtCodeSearch.Text == "")
                filterExpression = string.Empty;
            else
            {
                double result;
                //filter for numbers fields
                if (dataType == "Decimal" || dataType == "Int16" || dataType == "Int32" || dataType == "Int64")
                {
                    //now check if the value in the text is match with the datatype
                    if (double.TryParse(searchText, out result))
                    {
                       // filterExpression += "[" + searchOn + "] = " + searchText + "";
                        //"CONVERT("+colname+", System.String) LIKE '"+ condition+"%'"
                        filterExpression += "CONVERT(" + searchOn + ", System.String) LIKE '" + searchText + "%'";
                    }
                }
                else
                {
                    filterExpression += "[" + searchOn + "] like '%" + searchText + "%'";
                }
            }
            dv.RowFilter = filterExpression;
            gvLookup.DataSource = dv;
            gvLookup.DataBind();
            Session["PaggingLookup"] = dv;
            gvLookup.HeaderRow.Cells[1].Visible = false;
            foreach (GridViewRow gvr in gvLookup.Rows)
            {
                gvr.Cells[1].Visible = false;
            }
            txtCodeSearch.Focus();
            Account_ModalPopupExtender.Show();
        }

        protected void gvLookup_RowCreated(object sender, GridViewRowEventArgs e)
        {
        }

        protected void imgbtnCancel_Click(object sender, ImageClickEventArgs e)
        {
            Account_ModalPopupExtender.Hide();
            gvLookup.DataSource = null;
            gvLookup.DataBind();
        }

        protected void gvLookup_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            try
            {
                DataView dv = Session["PaggingLookup"] as DataView;

                if (e.CommandName == "Select")
                {
                    int indx = Convert.ToInt32(e.CommandArgument);
                    GridViewRow sr = gvLookup.Rows[indx];
                    string id = sr.Cells[1].Text;
                    this.Page.GetType().InvokeMember("fill", System.Reflection.BindingFlags.InvokeMethod, null, this.Page, new object[] { id, TableName });
                    gvLookup.DataSource = null;
                    gvLookup.DataBind();
                }

                else if (e.CommandName == "First")
                {
                    gvLookup.PageIndex = 0;
                    gvLookup.DataSource = dv;
                    gvLookup.DataBind();
                    Account_ModalPopupExtender.Show();
                }
                else if (e.CommandName == "Prev")
                {
                    int indx = gvLookup.PageIndex;
                    gvLookup.PageIndex = indx <= 0 ? 0 : indx - 1;
                    gvLookup.DataSource = dv;
                    gvLookup.DataBind();
                    Account_ModalPopupExtender.Show();
                }
                else if (e.CommandName == "Next")
                {
                    gvLookup.PageIndex += 1;
                    gvLookup.DataSource = dv;
                    gvLookup.DataBind();
                    Account_ModalPopupExtender.Show();
                }
                else if (e.CommandName == "Last")
                {
                    gvLookup.PageIndex = gvLookup.PageCount;
                    gvLookup.DataSource = dv;
                    gvLookup.DataBind();
                    Account_ModalPopupExtender.Show();
                }
            }
            catch (Exception exc)
            {
                throw new Exception(exc.Message);
            }
        }

        //protected void gvLookup_PageIndexChanging(object sender, GridViewPageEventArgs e)
        //{
        //    //gvLookup.PageIndex = e.NewPageIndex;
        //    //DataTable dt = Session["lookup"] as DataTable;
        //    //gvLookup.DataSource = dt;
        //    //gvLookup.DataBind();
        //    //gvLookup.HeaderRow.Cells[1].Visible = false;
        //    //foreach (GridViewRow gvr in gvLookup.Rows)
        //    //{
        //    //    gvr.Cells[1].Visible = false;
        //    //}
        //    //Account_ModalPopupExtender.Show();
        //}
    }
}