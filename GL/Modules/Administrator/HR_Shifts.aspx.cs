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
    public partial class HR_Shift : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BlankForm();

                if (Request.QueryString["ID"] != null)
                {
                    LoadHR_ShiftsData(Convert.ToInt32(Request.QueryString["ID"]));

                }
            }
        }

        private void BlankForm()
        {
            txtShift__ID.Text = "(New)";
            txtShiftName.Text = "";
            txtFromShift.Text = DateTime.Now.ToShortTimeString();
            txtToShift.Text = DateTime.Now.ToShortTimeString();
            txtFromBreak.Text = DateTime.Now.ToShortTimeString();
            txtToBreak.Text = DateTime.Now.ToShortTimeString();
            //lblmsg.Text = "";
            CheckBox1.Checked = false;
        }

        private void LoadHR_ShiftsData(int Shift_id)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            HR_Shift shft = (from tbl in db.HR_Shifts
                             where tbl.Shift_ID == Shift_id
                             select tbl).FirstOrDefault();
            txtShiftName.Text = shft.Shift_Name;
            txtFromShift.Text = shft.Time_From;
            txtToShift.Text = shft.Time_To;
            txtFromBreak.Text = shft.Break_Time_From;
            txtToBreak.Text = shft.Break_Time_To;
            if (shft.Shift_Next_Day == true)
                CheckBox1.Checked = true;
            else
                CheckBox1.Checked = false;

            btnSave.Text = "Update";
        }
        //private static string DateFormat()
        //{
        //    return "MM/dd/yyyy";
        //}
        //private static string TimeFormat()
        //{
        //    return "HH:mm:ss";
        //}

        protected void btnBack_Click(object sender, EventArgs e)
        {
            Response.Redirect("HR_Shifts_View.aspx");
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {

            try
            {
                DataBaseDataContext db = new DataBaseDataContext();
                if (btnSave.Text == "Save")
                {
                    HR_Shift shft = new HR_Shift();
                    shft.Shift_Name = txtShiftName.Text;
                    shft.Time_From = Convert.ToString(txtFromShift.Text);
                    shft.Time_To = Convert.ToString(txtToShift.Text);
                    shft.Break_Time_From = Convert.ToString(txtFromBreak.Text);
                    shft.Break_Time_To = Convert.ToString(txtToBreak.Text);
                    if (CheckBox1.Checked == true)
                        shft.Shift_Next_Day = true;
                    else
                        shft.Shift_Next_Day = false;

                    shft.Created_By = AppConfig.UserID;
                    shft.Created_Time = DateTime.Now;
                    shft.Book_ID = AppConfig.Book_ID;
                    shft.Company_ID = AppConfig.Company_ID;

                    db.HR_Shifts.InsertOnSubmit(shft);
                    db.SubmitChanges();
                    BlankForm();
                }
                else
                {
                    if (Request.QueryString["ID"] != null)
                    {
                        int id = Convert.ToInt32(Request.QueryString["ID"]);
                        HR_Shift shft = new HR_Shift();
                        shft = (from tbl in db.HR_Shifts
                                where tbl.Shift_ID == id
                                select tbl).FirstOrDefault();

                        shft.Shift_Name = txtShiftName.Text;
                        shft.Time_From = Convert.ToString(txtFromShift.Text);
                        shft.Time_To = Convert.ToString(txtToShift.Text);
                        shft.Break_Time_From = Convert.ToString(txtFromBreak.Text);
                        shft.Break_Time_To = Convert.ToString(txtToBreak.Text);
                        if (CheckBox1.Checked == true)
                            shft.Shift_Next_Day = true;
                        else
                            shft.Shift_Next_Day = false;

                        shft.Updated_By = AppConfig.UserID;
                        shft.Updated_Time = DateTime.Now;

                        //db.HR_Shifts.InsertOnSubmit(shft);
                        db.SubmitChanges();
                        BlankForm();
                    }
                }
                Response.Redirect("HR_Shifts_View.aspx");
            }
            catch (Exception ex)
            {
                throw;
            }
        }
    }
}