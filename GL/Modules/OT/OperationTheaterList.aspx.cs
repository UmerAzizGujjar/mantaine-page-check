using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Net.NetworkInformation;
using System.Reflection;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class OperationTheaterList : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static string DeleteID(string OT_ID)
        {
            try
            {
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

                // Try to find the package by ID
                var package = db.Operation_Bookings.FirstOrDefault(p => p.Operation_Booking_ID.ToString() == OT_ID);

                if (package != null)
                {
                    package.isCancelled = true;
                    package.CancelledBy = AppConfig.UserID;
                    package.CancelledTime = DateTime.Now;
                    db.SubmitChanges();
                    return "Package cancelled successfully.";
                }
                else
                {
                    return "Package not found.";
                }
            }
            catch (Exception ex)
            {
                // Optional: Log the exception if needed
                return "Error occurred: " + ex.Message;
            }
        }
        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    string userId = HttpContext.Current.Session["UserId"].ToString();

                    var Total_Operation = _dbContext.Operation_Bookings.Count();
                    var Valuesetid = _dbContext.ValueSets.Where(x => x.ValueSet_Description.Contains("IPD Procedures")).FirstOrDefault().ValueSet_ID;

                    var Operation = from op in _dbContext.Operation_Bookings
                              join p in _dbContext.Reg_patients on op.Patient_ID equals p.pat_id
                              where op.OperationStatus == "done"
                             && (p.Patient_No.ToString().Contains(searchValue) || p.mr_no_sequence.ToString().Contains(searchValue) || p.Full_Name.Contains(searchValue) || _dbContext.GetDataValueName("Patient Main Category",op.DepartmentOf_Surgery).Contains(searchValue))
                                select new
                              {
                                  Operation_Booking_ID = op.Patient_ID,
                                  mr_no_sequence =    p.mr_no_sequence,
                                  Full_Name =         p.Full_Name,
                                  DoctorName = (from w in _dbContext.HR_Employees
                                                where w.IsDoctor == true && w.Emp_ID == Convert.ToInt32(op.DoctorName)
                                                select w.Emp_Name).FirstOrDefault(),

                                  ProcedureName = (op.ProcedureName != null && op.ProcedureName != "" && op.ProcedureName != "0") ?
                                  (from w in _dbContext.DataValues
                                   where w.ValueSet_ID == Valuesetid && w.DataValue_Name == op.ProcedureName
                                   select w.DataValue_Description).FirstOrDefault() : op.Patient_Procedure,
                                  Created_Time = op.OperationDate,
                                  Mobile  = p.Mobile1,
                                  Department = _dbContext.GetDataValueName("Patient Main Category", op.DepartmentOf_Surgery),

                                  OperationStatus = op.OperationStatus
                              };

                    var FilteredCount = Operation.Count();
                    switch (sortColumn)
                    {
                       
                        case "mr_no_sequence":
                            Operation = sortColumnDirection == "asc" ? Operation.OrderBy(a => a.mr_no_sequence) : Operation.OrderByDescending(a => a.mr_no_sequence);
                            break;
                        case "Created_Time":
                            Operation = sortColumnDirection == "asc" ? Operation.OrderBy(a => a.Created_Time) : Operation.OrderByDescending(a => a.Created_Time);
                            break;
                        default:
                            Operation = Operation.OrderByDescending(a => a.Operation_Booking_ID); 
                            break;
                    }


                    var patientList = Operation.Skip(start).Take(length).ToList();


                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Operation, data = patientList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching patient list", ex);
            }
        }
    }
}