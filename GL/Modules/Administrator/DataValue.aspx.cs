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
            GetNewValueSetName();
        }

        protected void btnAdd_Click(object sender, EventArgs e)
        {
            if (txtDataValue_Name.Text != "" && txtDataValue_Description.Text!="")
            {
                

                dt = (DataTable)Session["dtDataValue"];
                Boolean bol = Convert.ToBoolean(ViewState["check"]);
                int index = Convert.ToInt32(ViewState["Index"]);
                //int datavalue_id = Convert.ToInt32(ViewState["datavalue_id"]);
                if (bol == true)
                {
                    bol = false;
                    ViewState.Add("check", bol);
                    DataRow[] row = dt.Select("Index = '" + index + "'");
                    int datavalue_Id = Convert.ToInt32(row[0]["DataValue_ID"]);
                    row[0]["Index"] = index;
                    row[0]["DataValue_ID"] = datavalue_Id;
                    row[0]["DataValue_Name"] = txtDataValue_Name.Text;
                    row[0]["DataValue_Description"] = txtDataValue_Description.Text;
                    row[0]["Segment1"] = txtSegment1.Text;
                    row[0]["Segment2"] = txtSegment2.Text;
                    lblMessage.Text = "";
                }
                else
                {
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
                    }
                    

                    else
                    {
                        lblMessage.Text = "Value Name already exist!";
                    }
                }

                Session["dtDataValue"] = dt;
                GRD.DataSource = dt;
                GRD.DataBind();
                txtDataValue_Name.Text = "";
                txtDataValue_Description.Text = "";
                txtSegment1.Text = "";
                txtSegment2.Text = "";
                txtDataValue_Name.Focus();
                GetNewValueSetName();
            }
            else
            {
                lblMessage.Text = "Datavalue name and description both are require.";
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
            GRD.DataSource = null;
            GRD.DataBind();
            ddlValueSet_SelectedIndexChanged(sender, e);
        }

        protected void GRD_SelectedIndexChanging(object sender, GridViewSelectEventArgs e)
        {
            Boolean bol = true;
            ViewState.Add("check", bol);
            btnAdd.Text = "Update";
            var ValueSet = ddlValueSet.SelectedValue.ToString();

            if (ValueSet == "9")
            {
                roomNo.Text = "Room No";
            }
            else { roomNo.Text = "Segment 2"; }
           
            dt = (DataTable)Session["dtDataValue"];
            Label lblIndex = (Label)GRD.Rows[e.NewSelectedIndex].FindControl("lblIndex");
            int index = Convert.ToInt32(lblIndex.Text);
            ViewState.Add("Index", index);
            DataRow[] row = dt.Select("Index = '" + index + "'");
            int datavalue_Id = Convert.ToInt32(row[0]["DataValue_ID"]);
            string Name = Convert.ToString(row[0]["DataValue_Name"]);
            string description = Convert.ToString(row[0]["DataValue_Description"]);
            string segment1 = Convert.ToString(row[0]["Segment1"]);
            string segment2 = Convert.ToString(row[0]["Segment2"]);
            txtDataValue_Name.Text = Name;
            txtDataValue_Description.Text = description;
            txtSegment1.Text = segment1;
            txtSegment2.Text = segment2;
            lblMessage.Text = "";
            ViewState.Add("datavalue_id", datavalue_Id);
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
                lblMessage.Text = "This record is in used in form <b>" + TransType + "</b> in <b>" + TransName + "</b>";
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