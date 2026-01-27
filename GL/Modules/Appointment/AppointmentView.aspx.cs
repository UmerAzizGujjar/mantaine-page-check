using Infragistics.Web.UI.GridControls;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Linq.SqlClient;
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
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue,
       string doctorId = null, string deptId = null, string status = null, string appDate = null)
        {
            try
            {
                // 🔽 Default to latest-first if no sort is specified
                if (string.IsNullOrWhiteSpace(sortColumn))
                {
                    sortColumn = "created_time"; // Must match column name expected by your stored procedure
                    sortColumnDirection = "desc";
                }
                else
                {
                    // Normalize sort direction to 'asc' or 'desc'
                    sortColumnDirection = sortColumnDirection?.ToLower() == "desc" ? "desc" : "asc";
                }

                using (var _dbContext = new DataBaseDataContext())
                {
                    if (_dbContext.Connection.State != ConnectionState.Open)
                    {
                        _dbContext.Connection.Open();
                    }

                    var cmd = _dbContext.Connection.CreateCommand();
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.CommandText = "sp_get_appointment_view";

                    cmd.Parameters.Add(new SqlParameter("@searchValue", (object)searchValue ?? DBNull.Value));
                    cmd.Parameters.Add(new SqlParameter("@sortColumn", (object)sortColumn ?? "created_time"));
                    cmd.Parameters.Add(new SqlParameter("@sortDirection", (object)sortColumnDirection ?? "desc"));
                    cmd.Parameters.Add(new SqlParameter("@doctorId", (object)doctorId ?? DBNull.Value));
                    cmd.Parameters.Add(new SqlParameter("@deptId", (object)deptId ?? DBNull.Value));
                    cmd.Parameters.Add(new SqlParameter("@status", (object)status ?? DBNull.Value));
                    cmd.Parameters.Add(new SqlParameter("@appDate", (object)appDate ?? DBNull.Value));

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
                            });
                        }

                        int totalRecords = AppointmentList.Count;
                        int filteredCount = AppointmentList.Count;

                        // Apply pagination
                        var paginatedList = AppointmentList.Skip(start).Take(length).ToList();

                        var jsonData = new
                        {
                            draw = draw,
                            recordsFiltered = filteredCount,
                            recordsTotal = totalRecords,
                            data = paginatedList
                        };

                        return jsonData;
                    }
                }
            }
            catch (Exception ex)
            {
                // Log exception if you have logging (recommended)
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
        public class DoctorItem
        {
            public int Emp_ID { get; set; }
            public string Emp_Name { get; set; }
        }

        [WebMethod]
        public static List<DoctorItem> GetDoctors()
        {
            try
            {
                using (var db = new DataBaseDataContext())
                {
                    return (from emp in db.HR_Employees
                            where emp.IsDoctor == true
                            orderby emp.Emp_Name
                            select new DoctorItem
                            {
                                Emp_ID = emp.Emp_ID,
                                Emp_Name = emp.Emp_Name
                            }).ToList();
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching doctors", ex);
            }
        }
        public class DeptDropdownItem
        {
            public string DeptId { get; set; }
            public string DeptName { get; set; }
        }

        [WebMethod]
        public static List<DeptDropdownItem> GetDepartments()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                              where vs.ValueSet_Name == "Patient Main Category"
                              select new DeptDropdownItem
                              {
                                  DeptId = dv.DataValue_Name,          
                                  DeptName = dv.DataValue_Description 
                              }).ToList();

                return result;
            }
        }
    }
    
}