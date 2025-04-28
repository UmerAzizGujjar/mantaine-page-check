using Infragistics.Web.UI.GridControls;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class AppointmentView : System.Web.UI.Page
    {
        protected override void OnInit(EventArgs e)
        {
            if (Session["Company_ID"] != null)
            {
             
            }
            else
            {
                Session.Abandon();
                Response.Redirect("~/Modules/Account/Login.aspx", true);
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    if (_dbContext.Connection.State != ConnectionState.Open)
                    {
                        _dbContext.Connection.Open();
                    }

                    var cmd = _dbContext.Connection.CreateCommand();
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.CommandText = "sp_get_appointment_view";

                    // Add search value parameter
                    var searchParameter = cmd.CreateParameter();
                    searchParameter.ParameterName = "@searchValue";
                    searchParameter.Value = searchValue ?? (object)DBNull.Value;
                    cmd.Parameters.Add(searchParameter);

                    // Add sorting parameters
                    var sortColumnParameter = cmd.CreateParameter();
                    sortColumnParameter.ParameterName = "@sortColumn";
                    sortColumnParameter.Value = sortColumn ?? "Appointment_ID"; // Default column
                    cmd.Parameters.Add(sortColumnParameter);

                    var sortDirectionParameter = cmd.CreateParameter();
                    sortDirectionParameter.ParameterName = "@sortDirection";
                    sortDirectionParameter.Value = sortColumnDirection ?? "asc"; // Default direction
                    cmd.Parameters.Add(sortDirectionParameter);

                    using (var reader = cmd.ExecuteReader())
                    {
                        var AppointmentList = new List<dynamic>();

                        while (reader.Read())
                        {
                            AppointmentList.Add(new
                            {
                                Appointment_ID = reader["Appointment_ID"],
                                Department = reader["Department"],
                                Appointed_Doctor = reader["Appointed_Doctor"],
                                App_Date = reader["App_Date"],
                                Start_Time = reader["Start_Time"],
                                Appointment_No = reader["Appointment_No"],
                                Phone = reader["Phone"],
                                Patient_Name = reader["Patient_Name"],
                                Age = reader["Age"],
                                Created_Time = reader["created_time"],
                                Username = reader["username"],
                                Status = reader["status"],
                                //Referred = reader["referred"],
                            });
                        }

                        int Total_Records = AppointmentList.Count;
                        int FilteredCount = AppointmentList.Count;

                        // Paginate the list
                        var paginatedList = AppointmentList.Skip(start).Take(length).ToList();

                        var jsonData = new
                        {
                            draw = draw,
                            recordsFiltered = FilteredCount,
                            recordsTotal = Total_Records,
                            data = paginatedList
                        };

                        return jsonData;
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching appointment list", ex);
            }
        }

        [WebMethod]
        public static void DeleteRecord(int AppID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var list = db.Appointment_Forms.Where(ap => ap.Appointment_ID == AppID).ToList();
            db.Appointment_Forms.DeleteAllOnSubmit(list);
            db.SubmitChanges();
        }
    }
}