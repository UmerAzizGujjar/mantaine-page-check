using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.PatientManagement
{
    public partial class DoctorPayableView : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue, string startDate, string endDate, string packageType)
        {
            try
            {
                using (var db = new DataBaseDataContext()) // Replace with your actual DataContext
                {
                    // Base query with joins
                    var query = from dp in db.Doctor_Payableds
                                join d in db.HR_Employees on dp.Doctor_Id equals d.Emp_ID.ToString() // Assuming you have a Doctors table 
                                where dp.Created_Time != null
                                select new
                                {
                                    dp.Bill_Id,
                                    DoctorName = d.Emp_Name , // Adjust based on your Doctor table structure
                                    dp.Package_Name_ID,
                                    dp.Total_Bill_Amount,
                                    dp.Total_Expense,
                                    dp.After_Expense_Amount,
                                    dp.Doctor_Share,
                                    dp.Hospital_Share,
                                    dp.Amount_Assign_To_Doctor,
                                    dp.Created_Time
                                };

                    // Apply date filters
                    if (!string.IsNullOrEmpty(startDate))
                    {
                        DateTime startDateValue = DateTime.Parse(startDate);
                        query = query.Where(x => x.Created_Time >= startDateValue);
                    }

                    if (!string.IsNullOrEmpty(endDate))
                    {
                        DateTime endDateValue = DateTime.Parse(endDate).AddDays(1);
                        query = query.Where(x => x.Created_Time < endDateValue);
                    }

                    // Apply package type filter
                    if (!string.IsNullOrEmpty(packageType) && packageType != "All")
                    {
                        query = query.Where(x => x.Package_Name_ID == packageType);
                    }

                    // Apply search filter
                    if (!string.IsNullOrEmpty(searchValue))
                    {
                        query = query.Where(x =>
                            x.DoctorName.Contains(searchValue) ||
                            x.Package_Name_ID.Contains(searchValue) ||
                            x.Bill_Id.ToString().Contains(searchValue));
                    }

                    // Get total count before pagination
                    int totalRecords = query.Count();

                    // Apply sorting
                    if (!string.IsNullOrEmpty(sortColumn))
                    {
                        switch (sortColumn)
                        {
                            case "Bill_Id":
                                query = sortColumnDirection == "asc" ?
                                    query.OrderBy(x => x.Bill_Id) :
                                    query.OrderByDescending(x => x.Bill_Id);
                                break;
                            case "DoctorName":
                                query = sortColumnDirection == "asc" ?
                                    query.OrderBy(x => x.DoctorName) :
                                    query.OrderByDescending(x => x.DoctorName);
                                break;
                            case "Package_Name_ID":
                                query = sortColumnDirection == "asc" ?
                                    query.OrderBy(x => x.Package_Name_ID) :
                                    query.OrderByDescending(x => x.Package_Name_ID);
                                break;
                            case "Total_Bill_Amount":
                                query = sortColumnDirection == "asc" ?
                                    query.OrderBy(x => x.Total_Bill_Amount) :
                                    query.OrderByDescending(x => x.Total_Bill_Amount);
                                break;
                            // Add other sortable columns as needed
                            default:
                                query = query.OrderByDescending(x => x.Created_Time);
                                break;
                        }
                    }
                    else
                    {
                        query = query.OrderByDescending(x => x.Created_Time);
                    }

                    // Apply pagination
                    var data = query.Skip(start).Take(length).ToList();

                    // Transform to the required format
                    var result = data.Select(x => new
                    {
                        Bill_Id = x.Bill_Id,
                        DoctorName = x.DoctorName,
                        Package_Name_ID = x.Package_Name_ID,
                        Total_Bill_Amount = x.Total_Bill_Amount,
                        Total_Expense = x.Total_Expense,
                        After_Expense_Amount = x.After_Expense_Amount,
                        Doctor_Share = x.Doctor_Share,
                        Hospital_Share = x.Hospital_Share,
                        Amount_Assign_To_Doctor = x.Amount_Assign_To_Doctor
                    }).ToList();

                    return new
                    {
                        draw = draw,
                        recordsTotal = totalRecords,
                        recordsFiltered = totalRecords,
                        data = result
                    };
                }
            }
            catch (Exception ex)
            {
                // Log error (consider using a logging framework)
                return new
                {
                    draw = draw,
                    recordsTotal = 0,
                    recordsFiltered = 0,
                    data = new List<object>(),
                    error = ex.Message
                };
            }
        }
    }
}