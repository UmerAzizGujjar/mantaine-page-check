using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Data.SqlClient;


namespace PMS
{
    public partial class AddRoute : System.Web.UI.Page
    {
        DataTable dt = new DataTable();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                txtStart_Time.Text = DateTime.Now.ToShortTimeString();
                txtEnd_Time.Text = DateTime.Now.ToShortTimeString();

                dt.Columns.AddRange(new DataColumn[2] { new DataColumn("Stop_Name"), new DataColumn("Stop_Time") });
                ViewState["BusStop"] = dt;
                this.BindGrid();

                BindingDropDown();
                if (Request.QueryString["ID"] != null)
                {
                    PopulateRoutesData(Convert.ToInt32(Request.QueryString["ID"]));

                }
            }
        }


        private void BindingDropDown()
        {
            object valueset;
            valueset = DBClass.GetValueSet("Route Type");
            ddlRoute_Type.DataSource = valueset;
            ddlRoute_Type.DataTextField = "DataValue_Description";
            ddlRoute_Type.DataValueField = "DataValue_Name";
            ddlRoute_Type.Items.Add(new ListItem("Please Select", "0"));
            ddlRoute_Type.DataBind();



        }


        private void PopulateRoutesData(int rid)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            Route rObj = (from tbl in db.Routes
                            where tbl.Route_ID == rid
                            select tbl).FirstOrDefault();

            txtRoute_Name.Text = rObj.Route_Name;
            txtDestination.Text = rObj.Destination;
            ddlRoute_Type.SelectedValue = rObj.Route_Type;
            txtStart_Time.Text = rObj.Start_Time.Value.ToString();
            txtEnd_Time.Text = rObj.End_Time.Value.ToString();


                //Bus_Stop dsb = (from u in db.Bus_Stops where rid ==  u.Route_ID select u).First();
                //List<Bus_Stop> myList = new List<Bus_Stop>();
                //myList.Add(dsb);
                
                //GRD.DataSource = myList;
                //GRD.DataBind();
                btnSave.Text = "Update";
                

                SqlConnection con = new SqlConnection(DBClass.ConnectionString());
                DataTable dt = new DataTable();
                SqlDataAdapter sda = new SqlDataAdapter("select Bus_Stop.Stop_Name, Bus_Stop.Stop_Time from Bus_Stop where Bus_Stop.Route_ID = '"+rid+"'", con);
                sda.Fill(dt);
                GRD.DataSource = dt;
                ViewState["BusStop"] = dt;
                GRD.DataBind();

        }

        protected void btnAdd_Stop_Click(object sender, EventArgs e)
        {
            if (txtStop_Name.Text != null)
            { 
                dt = (DataTable)ViewState["BusStop"];
                dt.Rows.Add(txtStop_Name.Text.Trim(), txtStop_Time.Text.Trim());
                ViewState["BusStop"] = dt;
                this.BindGrid();
                txtStop_Name.Text = string.Empty;
                txtStop_Time.Text = string.Empty;
            }
            else {
                lblMessage.CssClass = "Stop Name required!";
            }
    
        }

        protected void BindGrid()
        {
            GRD.DataSource = (DataTable)ViewState["BusStop"];
            GRD.DataBind();
        }

        protected void GRD_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                string item = e.Row.Cells[0].Text;
                foreach (Button button in e.Row.Cells[0].Controls.OfType<Button>())
                {
                    if (button.CommandName == "Delete")
                    {
                        button.Attributes["onclick"] = "if(!confirm('Do you want to delete " + item + "?')){ return false; };";
                    }
                }
            }
        }

        protected void GRD_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            int index = Convert.ToInt32(e.RowIndex);
            dt = ViewState["BusStop"] as DataTable;
            dt.Rows[index].Delete();
            ViewState["BusStop"] = dt;
            BindGrid();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {

            if (!Page.IsValid)
                return;

            try
            {
                //geting incremented value of Route_ID
                SqlConnection con = new SqlConnection(DBClass.ConnectionString());
                con.Open();
                string s = "SELECT IDENT_CURRENT('[Routes]')+1";
                SqlCommand cmd = new SqlCommand(s, con);  
                SqlDataReader dr = cmd.ExecuteReader();
                dr.Read();
                //int i = Convert.ToInt16(dr["Route_ID"].ToString());
                lblRoute_ID.Text = dr.GetValue(0).ToString();


                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                Route busRoutes = new Route();
                if (btnSave.Text == "Add Route")
                {
                    busRoutes.Created_By = AppConfig.UserID;
                    busRoutes.Created_Time = DateTime.Now;
                    busRoutes.Book_ID = AppConfig.Book_ID;
                    busRoutes.Company_ID = AppConfig.Company_ID;

                }
                else
                {
                    busRoutes = (from tbl in db.Routes
                                   where tbl.Route_ID == Convert.ToInt32(Request.QueryString["ID"])
                                   select tbl).FirstOrDefault();

                    busRoutes.Updated_By = AppConfig.UserID;
                    busRoutes.Updated_Time = DateTime.Now;
                }
              
                 busRoutes.Route_Name = txtRoute_Name.Text;
                 busRoutes.Destination = txtDestination.Text;
                 busRoutes.Route_Type = ddlRoute_Type.SelectedValue;
                 busRoutes.Start_Time = DateTime.Parse(txtStart_Time.Text).TimeOfDay;
                 busRoutes.End_Time = DateTime.Parse(txtEnd_Time.Text).TimeOfDay;
                 Bus_Stop stop = new Bus_Stop();
                 
                 dt = (DataTable)ViewState["BusStop"];
                 int count = dt.Rows.Count;
                 if (count < 1)
                 { }
                 else   
                 {
                     foreach (GridViewRow row in this.GRD.Rows)
                     {
                         if (row.RowType == DataControlRowType.DataRow)
                         {
                             // GridViewRow row;

                             string stopName = Convert.ToString(row.Cells[1].Text);
                             string stopTime = Convert.ToString(row.Cells[2].Text);

                             
                             stop.Route_ID = Convert.ToInt16(lblRoute_ID.Text);
                             stop.Stop_Name = stopName;
                             if (stopTime == "")
                                 stop.Stop_Time = null;
                             else
                                 stop.Stop_Time = DateTime.Parse(stopTime).TimeOfDay;

                             stop.Created_By = AppConfig.UserID;
                             stop.Created_Time = DateTime.Now;
                             stop.Book_ID = AppConfig.Book_ID;
                             stop.Company_ID = AppConfig.Company_ID;


                             db.SubmitChanges();
                         }
                     }

                 }
                 
                    
                if (btnSave.Text == "Add Route")
                {
                    db.Routes.InsertOnSubmit(busRoutes);
                    db.Bus_Stops.InsertOnSubmit(stop);
                    lblMessage.CssClass = "Data Inserted Successfully";

                }
                else
                {
                    lblMessage.CssClass = "Data Updated Successfully";
                }

                db.SubmitChanges();

                // Response.Redirect("~/.aspx", false);
                lblMessage.CssClass = "sucessfullMessage";
                //ClearForm();
            }
            catch (Exception ex)
            {
                lblMessage.CssClass = ex.Message;
            }

        }

        private void ClearForm()
        {

            txtRoute_Name.Text = "";
            txtDestination.Text = "";
            ddlRoute_Type.SelectedIndex = 0;
            txtStart_Time.Text = DateTime.Now.ToShortTimeString();
            txtEnd_Time.Text = DateTime.Now.ToShortTimeString();           
            GRD.DataSource = null;
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ClearForm();
        }
    }
}