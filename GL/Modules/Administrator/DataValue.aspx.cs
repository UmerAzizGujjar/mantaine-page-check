using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.HtmlControls;

namespace PMS
{
    public partial class DataValue : System.Web.UI.Page
    {
        DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
        DataTable dt;
        protected void Page_Load(object sender, EventArgs e)
        {
         
            Page.Form.DefaultButton = btnAdd.UniqueID;
            btnAdd.Text = "Add";
            if (!Page.IsPostBack)
            {
                var valueset = from v in db.ValueSets
                               where v.System == false && v.Active == true
                               select new { v.ValueSet_ID, v.ValueSet_Name };
                               
                ddlValueSet.DataTextField = "ValueSet_Name";
                ddlValueSet.DataValueField = "ValueSet_ID";
                ddlValueSet.DataSource = valueset;
                ddlValueSet.DataBind();
                ddlValueSet_SelectedIndexChanged(sender, e);
            }
            
        }
        public int GetIndex
        {
            get
            {
                return Convert.ToInt32(ViewState["GetIndex"]);
            }
            set
            {
                ViewState.Add("GetIndex", value);
            }
        }

        protected void ddlValueSet_SelectedIndexChanged(object sender, EventArgs e)
        {
            var Value = ddlValueSet.SelectedValue.ToString();

            if (Value == "9")
            {
                GRD.Columns[6].HeaderText = "Room No";
            }
            else { GRD.Columns[6].HeaderText = "Segment 2"; }
            //Set max length and data type from selected value
            var valueset = (from v in db.ValueSets
                            where v.ValueSet_ID == Convert.ToInt32(ddlValueSet.SelectedValue)
                            select v).SingleOrDefault();
            HfMax_Length.Value = valueset.Max_Length.Value.ToString();
            hfData_Type.Value = valueset.Data_Type.ToString();
            txtDataValue_Name.MaxLength = valueset.Max_Length.Value;

            dt = new DataTable();
            dt.Columns.Add("Index", Type.GetType("System.Int32"));
            dt.Columns.Add("DataValue_ID", Type.GetType("System.Int32"));
            dt.Columns.Add("DataValue_Name", Type.GetType("System.String"));
            dt.Columns.Add("DataValue_Description", Type.GetType("System.String"));
            dt.Columns.Add("Segment1", Type.GetType("System.String"));
            dt.Columns.Add("Segment2", Type.GetType("System.String"));
            dt.Columns["DataValue_Name"].Unique = true;

            var datavalue = from d in db.DataValues
                            where d.ValueSet_ID == Convert.ToInt32(ddlValueSet.SelectedValue) && d.DataValue_Name != null && (d.System_Value==false ||d.System_Value==null)
                            select new { d.DataValue_ID, d.DataValue_Name, d.DataValue_Description, d.Segment1 ,d.Segment2};
            foreach (var item in datavalue)
            {
                DataRow dr = dt.NewRow();
                dr["Index"] = GetIndex;
                dr["DataValue_ID"] = item.DataValue_ID;
                dr["DataValue_Name"] = item.DataValue_Name;
                dr["DataValue_Description"] = item.DataValue_Description;
                dr["Segment1"] = item.Segment1;
                dr["Segment2"] = item.Segment2;
                dt.Rows.Add(dr);
                GetIndex++;
            }
            lblMessage.Text = "";
            GRD.DataSource = dt;
            GRD.DataBind();
            Session["dtDataValue"] = dt;
            btnAdd.Text = "Add";
            GetNewValueSetName();
        }

        private void ShowSwal(string icon, string title)
        {
            string safe = title.Replace("'", "\\'");
            string js = "showDvToast('" + icon + "', '" + safe + "');";
            ScriptManager.RegisterStartupScript(this, this.GetType(), "dvSwal_" + Guid.NewGuid().ToString("N"), js, true);
        }

        protected void btnAdd_Click(object sender, EventArgs e)
        {
            if (txtDataValue_Name.Text != "" && txtDataValue_Description.Text!="")
            {
                dt = (DataTable)Session["dtDataValue"];

                if (!string.IsNullOrEmpty(hfDataValue_ID.Value))
                {
                    // UPDATE branch
                    int datavalue_Id = Convert.ToInt32(hfDataValue_ID.Value);
                    bool found = false;
                    foreach (DataRow row in dt.Rows)
                    {
                        if (Convert.ToInt32(row["DataValue_ID"]) == datavalue_Id)
                        {
                            row["DataValue_Name"] = txtDataValue_Name.Text;
                            row["DataValue_Description"] = txtDataValue_Description.Text;
                            row["Segment1"] = txtSegment1.Text;
                            row["Segment2"] = txtSegment2.Text;
                            found = true;
                            break;
                        }
                    }
                    if (found)
                    {
                        lblMessage.Text = "";
                        ShowSwal("success", "Item updated in staging");
                    }
                }
                else
                {
                    // INSERT branch
                    bool val = true;
                    foreach (DataRow row in dt.Rows)
                    {
                        string DataValue_Name = Convert.ToString(row["DataValue_Name"]).ToUpper();
                        string Value = txtDataValue_Name.Text.ToUpper();
                        if (DataValue_Name == Value)
                        {
                            val = false;
                        }
                    }
                    if (val == true)
                    {
                        DataRow dr = dt.NewRow();
                        dr["Index"] = GetIndex;
                        dr["DataValue_ID"] = "-1";
                        dr["DataValue_Name"] = txtDataValue_Name.Text;
                        dr["DataValue_Description"] = txtDataValue_Description.Text;
                        dr["Segment1"] = txtSegment1.Text;
                        dr["Segment2"] = txtSegment2.Text;
                        dt.Rows.Add(dr);
                        lblMessage.Text = "";
                        ShowSwal("success", "Item added to staging");
                    }
                    else
                    {
                        lblMessage.Text = "Value Name already exist!";
                        ShowSwal("error", "Value Name already exists");
                    }
                }

                Session["dtDataValue"] = dt;
                GRD.DataSource = dt;
                GRD.DataBind();

                // Only clear form after INSERT — keep populated for Update
                if (string.IsNullOrEmpty(hfDataValue_ID.Value))
                {
                    txtDataValue_Name.Text = "";
                    txtDataValue_Description.Text = "";
                    txtSegment1.Text = "";
                    txtSegment2.Text = "";
                }
                txtDataValue_Name.Focus();
                GetNewValueSetName();
            }
            else
            {
                lblMessage.Text = "Datavalue name and description both are require.";
                ShowSwal("warning", "Name and Description are required");
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            
            //IDbTransaction dbtrans = db.Connection.BeginTransaction();            
            dt = (DataTable)Session["dtDataValue"];
            List<int> ids = Session["ids"] as List<int>;
            if (ids != null)
            {
                int count = ids.Count;
                for (int i = 0; i < count; i++)
                {
                    var del = (from data in db.DataValues
                                 where data.DataValue_ID == ids[i]
                                 select data).FirstOrDefault();
                    db.DataValues.DeleteOnSubmit(del);
                    db.SubmitChanges();
                }
            }
            Session["ids"] = null;
            foreach (DataRow row in dt.Rows)
            {
                var table = (from data in db.DataValues
                             where data.DataValue_ID == (int)row["DataValue_ID"]
                             select data).FirstOrDefault();
                
                if (row["DataValue_ID"].ToString() == "-1")
                {
                    //insert data
                    table = new DataValue();
                    table.ValueSet_ID = Convert.ToInt32(ddlValueSet.SelectedValue);
                    table.DataValue_Name = row["DataValue_Name"].ToString();
                    table.DataValue_Description = row["DataValue_Description"].ToString();
                    table.Segment1 = row["Segment1"].ToString();
                    table.Segment2 = row["Segment2"].ToString();
                    db.DataValues.InsertOnSubmit(table);
                }
                else
                {
                    table.DataValue_Name = row["DataValue_Name"].ToString();
                    table.DataValue_Description = row["DataValue_Description"].ToString();
                    table.Segment1 = row["Segment1"].ToString();
                    table.Segment2 = row["Segment2"].ToString();
                }
                //update
                db.SubmitChanges();
            }
            //dbtrans.Commit();
            dt = null;
            Session["dtDataValue"] = dt;
            lblMessage.Text = "";
            btnAdd.Text = "Add";
            GRD.DataSource = null;
            GRD.DataBind();
            ddlValueSet_SelectedIndexChanged(sender, e);
            ShowSwal("success", "Saved successfully");
        }

        protected void GRD_SelectedIndexChanging(object sender, GridViewSelectEventArgs e)
        {
            dt = (DataTable)Session["dtDataValue"];
            if (dt == null)
            {
                ShowSwal("warning", "Please select a value set first");
                return;
            }
            if (e.NewSelectedIndex < 0 || e.NewSelectedIndex >= dt.Rows.Count) return;

            DataRow row = dt.Rows[e.NewSelectedIndex];

            var ValueSet = ddlValueSet.SelectedValue.ToString();
            if (ValueSet == "9")
            {
                roomNo.Text = "Room No";
            }
            else { roomNo.Text = "Segment 2"; }

            txtDataValue_Name.Text = Convert.ToString(row["DataValue_Name"]);
            txtDataValue_Description.Text = Convert.ToString(row["DataValue_Description"]);
            txtSegment1.Text = Convert.ToString(row["Segment1"]);
            txtSegment2.Text = Convert.ToString(row["Segment2"]);

            hfDataValue_ID.Value = Convert.ToString(row["DataValue_ID"]);
            btnAdd.Text = "Update";
            lblMessage.Text = "";
            ShowSwal("info", "Editing record - " + Convert.ToString(row["DataValue_Name"]));
            txtDataValue_Name.Focus();
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            dt = (DataTable)Session["dtDataValue"];
            Boolean bol = Convert.ToBoolean(ViewState["check"]);
            int index = Convert.ToInt32(ViewState["Index"]);
            int datavalue_Id = Convert.ToInt32(ViewState["datavalue_id"]);


            DataTable record = new DataTable();
            record = DBClass.getDataTable("select Trans_Type,Trans_Name from vw_DataValues_Validation where DataValue_ID='" + txtDataValue_Name.Text + "'");
            if (record.Rows.Count > 0)
            {
                string TransType = record.Rows[0]["Trans_Type"].ToString();
                string TransName = record.Rows[0]["Trans_Name"].ToString();
                lblMessage.Text = "This record is in used in form " + TransType + " in " + TransName;
                ShowSwal("error", "Record in use: " + TransType + " / " + TransName);
                return;
            }


            if (datavalue_Id > 0)
            {
                List<int> ids;
                if (Session["ids"] == null)
                {
                    ids = new List<int>();
                    ids.Add(datavalue_Id);
                    Session.Add("ids", ids);
                }
                else
                {
                    ids = Session["ids"] as List<int>;
                    ids.Add(datavalue_Id);
                    Session.Add("ids", ids);
                }
            }
            if (bol == true)
            {
                bol = false;
                ViewState.Add("check", bol);
                DataRow[] row = dt.Select("Index = '" + index + "'");
                dt.Rows.Remove(row[0]);
                dt.AcceptChanges();
                Session["dtDataValue"] = dt;
                GRD.DataSource = dt;
                GRD.DataBind();
                txtDataValue_Name.Text = "";
                txtDataValue_Description.Text = "";
                txtSegment1.Text = "";
                txtSegment2.Text = "";
                txtDataValue_Name.Focus();
                lblMessage.Text = "";
            }

            else
            {
                lblMessage.Text = "Select any record before deletion...!";
                ShowSwal("warning", "Select a record first");
            }
        }
        private void GetNewValueSetName()
        {

            if (ddlValueSet.SelectedValue == "83")
            {
                var MaxDataValuename = Convert.ToInt32(DBClass.getField("select (isnull(max(convert(int,DataValue_Name)),0)+1) from DataValues where                                      ValueSet_ID=83").ToString());
                txtDataValue_Name.Text = MaxDataValuename.ToString();
            }
            else
            {
                if (hfData_Type.Value == "Numeric")
                {
                    //var query = (from d in db.DataValues
                    //where d.ValueSet_ID == Convert.ToInt32(ddlValueSet.SelectedValue)
                    //select d.DataValue_Name).Max();
                    DataTable dt = Session["dtDataValue"] as DataTable;
                    string query = Convert.ToString(dt.Compute("Max(DataValue_Name)", ""));
                    int value;
                    if (int.TryParse(query.ToString(), out value))
                    {
                        value += 1;
                        if (HfMax_Length.Value == "1")
                            txtDataValue_Name.Text = value.ToString("0");
                        else if (HfMax_Length.Value == "2")
                            txtDataValue_Name.Text = value.ToString("00");
                        else if (HfMax_Length.Value == "3")
                            txtDataValue_Name.Text = value.ToString("000");
                        else if (HfMax_Length.Value == "4")
                            txtDataValue_Name.Text = value.ToString("0000");
                    }
                    else
                    {
                        if (HfMax_Length.Value == "1")
                            txtDataValue_Name.Text = "1";
                        else if (HfMax_Length.Value == "2")
                            txtDataValue_Name.Text = "01";
                        else if (HfMax_Length.Value == "3")
                            txtDataValue_Name.Text = "001";
                        else if (HfMax_Length.Value == "4")
                            txtDataValue_Name.Text = "0001";
                    }
                }
                else
                    txtDataValue_Name.Text = "";
            }
        }
    }
}