using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class RoomAllocation : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                txtTo_Date.Text = DateTime.Now.Date.ToString(AppConfig.DateFormat);
                txtFrom_Date.Text = DateTime.Now.Date.ToString(AppConfig.DateFormat);
                BindDropDownlist();

                if (Request.QueryString["ID"] != null)
                {
                    LoadRoomAllocationData(Convert.ToInt32(Request.QueryString["ID"]));

                }
            }
        }

        private void BindDropDownlist()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var dt = (from tbl in db.Rooms
                      select new
                      {
                          tbl.Room_ID,
                          tbl.Room_No
                      }).ToList();

            ddlRoom_No.DataSource = dt;
            ddlRoom_No.DataTextField = "Room_No";
            ddlRoom_No.DataValueField = "Room_ID";
            ddlRoom_No.Items.Add(new ListItem("Please Select", "0"));
            ddlRoom_No.DataBind();

        }

        private void LoadRoomAllocationData(int Room_Allocation_id)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            Room_Allocation roomAllocatoion = (from tbl in db.Room_Allocations
                                               where tbl.Room_Allocation_ID == Room_Allocation_id
                                                select tbl).FirstOrDefault();

            if (roomAllocatoion != null)
            {
                txtRoom_Allocation_ID.Text = roomAllocatoion.Room_Allocation_ID.ToString();
                hdfPatient_ID.Value = roomAllocatoion.Patient_ID.ToString();
                txtPatient_ID.Text = roomAllocatoion.Patient_ID.ToString();

                if (roomAllocatoion.Room_ID != null)
                {
                    ddlRoom_No.SelectedValue = roomAllocatoion.Room_ID.ToString();

                    var RoomTypeQry = (from rm in db.Rooms
                                           where rm.Room_ID == roomAllocatoion.Room_ID
                                           select new{
                                               rm.Room_ID,
                                               Room_Type = db.GetDataValueName("Room Type", rm.Room_Type),
                                               rm.Room_Charges
                                           }).FirstOrDefault();
                    if (RoomTypeQry != null)
                    {
                        txtRoom_Type.Text = RoomTypeQry.Room_Type;

                        if (RoomTypeQry.Room_Charges != null)
                            txtRoom_Charges.Text = RoomTypeQry.Room_Charges.ToString();
                    }
                }

                if (roomAllocatoion.To_Date != null)
                    txtTo_Date.Text = roomAllocatoion.To_Date.Value.ToString(AppConfig.DateFormat);

                if (roomAllocatoion.From_Date != null)
                    txtFrom_Date.Text = roomAllocatoion.From_Date.Value.ToString(AppConfig.DateFormat);
                
                txtRemarks.Text = roomAllocatoion.Remarks;

                btnSave.Text = "Update";
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                DataBaseDataContext db = new DataBaseDataContext();
                Room_Allocation roomAllocatoion = new Room_Allocation();
                Room_Allocatrion_History Room_History = new Room_Allocatrion_History();

                if (btnSave.Text == "Save")
                {
                    roomAllocatoion.Created_By = AppConfig.UserID;
                    roomAllocatoion.Created_Time = DateTime.Now;
                    roomAllocatoion.Book_ID = AppConfig.Book_ID;
                    roomAllocatoion.Company_ID = AppConfig.Company_ID;
                }
                else
                {
                    roomAllocatoion = (from tbl in db.Room_Allocations
                                  where tbl.Room_Allocation_ID == Convert.ToInt32(Request.QueryString["ID"])
                                  select tbl).FirstOrDefault();

                    roomAllocatoion.Updated_By = AppConfig.UserID;
                    roomAllocatoion.Updated_Time = DateTime.Now;
                }

                if (!string.IsNullOrEmpty(txtPatient_ID.Text))
                    roomAllocatoion.Patient_ID = Convert.ToInt32(txtPatient_ID.Text);

                if (!string.IsNullOrEmpty(ddlRoom_No.SelectedValue))
                    roomAllocatoion.Room_ID = Convert.ToInt32(ddlRoom_No.SelectedValue);

                if (!string.IsNullOrEmpty(txtFrom_Date.Text))
                    roomAllocatoion.From_Date = Convert.ToDateTime(txtFrom_Date.Text);

                if (!string.IsNullOrEmpty(txtTo_Date.Text))
                    roomAllocatoion.To_Date = Convert.ToDateTime(txtTo_Date.Text);

                roomAllocatoion.Remarks = txtRemarks.Text;

                if (btnSave.Text == "Save")
                {
                    db.Room_Allocations.InsertOnSubmit(roomAllocatoion);
                    db.SubmitChanges();
                    lblMessage.CssClass = "Data Inserted Successfully";



                    db = new DataBaseDataContext(DBClass.ConnectionString());
                    var countOfRows = db.Room_Allocatrion_Histories.Where(m => m.Patient_ID == Convert.ToInt32(txtPatient_ID.Text)).Count();

                    if (countOfRows > 0)
                    {
                        var lastRow = db.Room_Allocatrion_Histories.Where(m => m.Patient_ID == Convert.ToInt32(txtPatient_ID.Text)).Skip(countOfRows - 1).FirstOrDefault();

                        if (lastRow.To_Date == null)
                        {
                            lastRow.To_Date = DateTime.Now;
                            Room_Allocatrion_History Room_History_Edition = (from rmAlHst in db.Room_Allocatrion_Histories
                                                                             where rmAlHst.Room_Allocatrion_History_ID == lastRow.Room_Allocatrion_History_ID
                                                                             select rmAlHst).FirstOrDefault();

                            Room_History_Edition.To_Date = DateTime.Now;
                        }
                    }

                    Room_History = new Room_Allocatrion_History();
                    Room_History.Room_Allocation_ID = roomAllocatoion.Room_Allocation_ID;

                    if (!string.IsNullOrEmpty(txtPatient_ID.Text))
                        Room_History.Patient_ID = Convert.ToInt32(txtPatient_ID.Text);

                    if (!string.IsNullOrEmpty(ddlRoom_No.SelectedValue))
                        Room_History.Room_ID = Convert.ToInt32(ddlRoom_No.SelectedValue);

                    if (!string.IsNullOrEmpty(txtFrom_Date.Text))
                        Room_History.From_Date = Convert.ToDateTime(txtFrom_Date.Text);

                    if (!string.IsNullOrEmpty(txtTo_Date.Text))
                        Room_History.To_Date = Convert.ToDateTime(txtTo_Date.Text);

                    Room_History.Created_By = AppConfig.UserID;
                    Room_History.Created_Time = DateTime.Now;
                    Room_History.Book_ID = AppConfig.Book_ID;
                    Room_History.Company_ID = AppConfig.Company_ID;

                    db.Room_Allocatrion_Histories.InsertOnSubmit(Room_History);
                }
                else
                {
                    lblMessage.CssClass = "Data Updated Successfully";


                    Room_History = new Room_Allocatrion_History();
                    Room_History = (from tbl in db.Room_Allocatrion_Histories
                                       where tbl.Room_Allocation_ID == Convert.ToInt32(Request.QueryString["ID"])
                                       select tbl).FirstOrDefault();

                    if (!string.IsNullOrEmpty(txtPatient_ID.Text))
                        Room_History.Patient_ID = Convert.ToInt32(txtPatient_ID.Text);

                    if (!string.IsNullOrEmpty(ddlRoom_No.SelectedValue))
                        Room_History.Room_ID = Convert.ToInt32(ddlRoom_No.SelectedValue);

                    if (!string.IsNullOrEmpty(txtFrom_Date.Text))
                        Room_History.From_Date = Convert.ToDateTime(txtFrom_Date.Text);

                    if (!string.IsNullOrEmpty(txtTo_Date.Text))
                        Room_History.To_Date = Convert.ToDateTime(txtTo_Date.Text);

                    Room_History.Updated_By = AppConfig.UserID;
                    Room_History.Updated_Time = DateTime.Now;
                }

                db.SubmitChanges();

                Response.Redirect("~/RoomAllocationView.aspx", false);
                lblMessage.CssClass = "sucessfullMessage";
            }


            catch (Exception ex)
            {
                throw;
            }
        }

        protected void ddlRoom_No_SelectedIndexChanged(object sender, EventArgs e)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var room_Specs = (from tbl_room in db.Rooms
                              where tbl_room.Room_ID == Convert.ToInt32(ddlRoom_No.SelectedValue)
                              select new
                              {
                                  Room_Type = db.GetDataValueName("Room Type", tbl_room.Room_Type),
                                  tbl_room.Room_Charges
                              }).FirstOrDefault();

            if (room_Specs != null)
            {
                txtRoom_Type.Text = room_Specs.Room_Type;

                if (room_Specs.Room_Charges != null)
                    txtRoom_Charges.Text = room_Specs.Room_Charges.ToString();
            }
        }

        protected void btnAllocatedRoomChkTriggerBtn_Click(object sender, EventArgs e)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var countOfRows = db.Room_Allocatrion_Histories.Where(m => m.Patient_ID == Convert.ToInt32(txtPatient_ID.Text)).Count();

            if (countOfRows > 0)
            {
                var lastRow = db.Room_Allocatrion_Histories.Where(m => m.Patient_ID == Convert.ToInt32(txtPatient_ID.Text)).Skip(countOfRows - 1).FirstOrDefault();

                if (lastRow != null)
                {
                    var rmNo = (from rm_tbl in db.Rooms
                                where rm_tbl.Room_ID == lastRow.Room_ID
                                select rm_tbl.Room_No).FirstOrDefault();
                    txtCurrent_Allocated_Room.Text = rmNo.ToString();
                    vlblCurrent_Allocated_Room.Text = "";
                    vlblCurrent_Allocated_Room.CssClass = "Success";
                }
                //else
                //{
                //    txtCurrent_Allocated_Room.Text = "";
                //    vlblCurrent_Allocated_Room.Text = "No Room Assigned.";
                //    vlblCurrent_Allocated_Room.CssClass = "Error";
                //}
            }
            else
            {
                txtCurrent_Allocated_Room.Text = "";
                vlblCurrent_Allocated_Room.Text = "No Room Assigned.";
                vlblCurrent_Allocated_Room.CssClass = "Error";
            }
        }
    }
}