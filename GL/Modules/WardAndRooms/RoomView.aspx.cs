using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class RoomView : System.Web.UI.Page
    {

        

        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static object ViewRoomList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            using (var db = new DataBaseDataContext())
            {
                var roomsQuery = from r in db.Rooms
                                 select new
                                 {
                                     Room_ID = r.Room_ID,
                                     Room_No = r.Room_No,
                                     Name = r.Name,
                                     Building_Type = r.Building_Type,
                                     Room_Type = r.Room_Type,
                                     Floor_No = r.Floor_No,
                                     Location = r.Location,
                                     Warden = r.Warden,
                                     Charges_Per_Day = r.Room_Charges,
                                     Beds = r.No_Of_Beds,
                                     Is_Multiple_Beds = r.Is_Multiple_Beds,
                                     Per_Bed_Charge = (r.Is_Multiple_Beds == true && r.No_Of_Beds > 0) ? (r.Room_Charges / r.No_Of_Beds) : r.Room_Charges
                                 };

                if (!string.IsNullOrEmpty(searchValue))
                {
                    roomsQuery = roomsQuery.Where(r =>
                        r.Room_No.ToString().Contains(searchValue) ||
                        r.Name.Contains(searchValue) ||
                        r.Building_Type.Contains(searchValue) ||
                        r.Room_Type.Contains(searchValue) ||
                        r.Floor_No.ToString().Contains(searchValue) ||
                        r.Location.Contains(searchValue) ||
                        r.Warden.Contains(searchValue)
                    );
                }

                int recordsTotal = db.Rooms.Count();
                int recordsFiltered = roomsQuery.Count();

                switch (sortColumn)
                {
                    case "Room_No":
                        roomsQuery = sortColumnDirection == "asc" ? roomsQuery.OrderBy(r => r.Room_No) : roomsQuery.OrderByDescending(r => r.Room_No);
                        break;
                    case "Name":
                        roomsQuery = sortColumnDirection == "asc" ? roomsQuery.OrderBy(r => r.Name) : roomsQuery.OrderByDescending(r => r.Name);
                        break;
                    default:
                        roomsQuery = roomsQuery.OrderBy(r => r.Room_ID);
                        break;
                }

                var roomsList = roomsQuery.Skip(start).Take(length).ToList();

                return new
                {
                    draw = draw,
                    recordsTotal = recordsTotal,
                    recordsFiltered = recordsFiltered,
                    data = roomsList
                };
            }
        }

        [WebMethod]
        public static string GetUserColumnPreferences()
        {
            try
            {
                string userId = AppConfig.UserID.ToString();
                string pageName = "RoomView";

                using (var db = new DataBaseDataContext())
                {
                    var pref = db.UserDataTablePreferences
                                  .FirstOrDefault(p => p.UserID == userId && p.PageName == pageName);

                    if (pref != null)
                        return pref.ColumnVisibility;
                    else
                        return "";
                }
            }
            catch (Exception ex)
            {
                return "";
            }
        }

        [WebMethod]
        public static void SaveUserColumnPreferences(string visibilityJson)
        {
            try
            {
                string userId = AppConfig.UserID.ToString();
                string pageName = "RoomView";

                using (var db = new DataBaseDataContext())
                {
                    var existing = db.UserDataTablePreferences
                                     .FirstOrDefault(p => p.UserID == userId && p.PageName == pageName);

                    if (existing != null)
                    {
                        existing.ColumnVisibility = visibilityJson;
                    }
                    else
                    {
                        db.UserDataTablePreferences.InsertOnSubmit(new UserDataTablePreference
                        {
                            UserID = userId,
                            PageName = pageName,
                            ColumnVisibility = visibilityJson
                        });
                    }

                    db.SubmitChanges();
                }
            }
            catch (Exception ex)
            {
                throw;
            }
        }

        [WebMethod]
        public static string DeleteRoom(int RoomID)
        {
            using (var db = new DataBaseDataContext())
            {
                var room = db.Rooms.FirstOrDefault(r => r.Room_ID == RoomID);
                if (room != null)
                {
                    db.Rooms.DeleteOnSubmit(room);
                    db.SubmitChanges();
                    return "success";
                }
                return "error";
            }
        }

    }
}