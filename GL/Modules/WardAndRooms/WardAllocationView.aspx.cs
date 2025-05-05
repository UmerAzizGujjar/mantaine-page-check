using Infragistics.Web.UI.GridControls;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class WardAllocationView : System.Web.UI.Page
    {
        
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static string DeleteRecord(string AppID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var remove = (from aremove in db.Ward_Allocations
                          where aremove.Ward_Allocation_ID == Convert.ToInt32(AppID)

                          select aremove).FirstOrDefault();
            db.Ward_Allocations.DeleteOnSubmit(remove);

            db.SubmitChanges();
            return "";

        }


        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    string userId = HttpContext.Current.Session["UserId"].ToString();

                    DateTime searchDate;
                    bool isDateSearch = DateTime.TryParse(searchValue, out searchDate);

                    var Total_Ward_Allocation = _dbContext.Ward_Allocations.Count();
                    var Ward = from wa in _dbContext.Ward_Allocations
                               join wd in _dbContext.Ward_Definitions on wa.Ward_ID equals wd.Ward_ID
                               join pt in _dbContext.Patients on wa.Patient_ID equals pt.Patient_ID
                               where (
                               pt.Full_Name.Contains(searchValue) || _dbContext.GetDataValueName("Ward Type", wd.Ward_Type).Contains(searchValue) || wa.Bed_No_Assigned.ToString().Contains(searchValue)
                               ||  (isDateSearch && wa.From_TimeDate >= searchDate && wa.From_TimeDate < searchDate.AddDays(1)))
                               select new
                               {
                                   Ward_Allocation_ID = wa.Ward_Allocation_ID,
                                   Full_Name = pt.Full_Name,
                                   Ward = _dbContext.GetDataValueName("Ward Type", wd.Ward_Type),
                                   Bed_No_Assigned = wa.Bed_No_Assigned,
                                   From_TimeDate = wa.From_TimeDate,
                                   To_TimeDate = wa.To_TimeDate,
                                   Ward_ID = wa.Ward_ID,
                                   Ward_No = wd.Ward_No,
                               };

                    var FilteredCount = Ward.Count();
                    switch (sortColumn)
                    {
                        case "Ward_No":
                            Ward = sortColumnDirection == "asc" ? Ward.OrderBy(a => a.Ward_No) : Ward.OrderByDescending(a => a.Ward_No);
                            break;
                        case "Bed_No_Assigned":
                            Ward = sortColumnDirection == "asc" ? Ward.OrderBy(b => b.Bed_No_Assigned) : Ward.OrderByDescending(a => a.Bed_No_Assigned);
                            break;
                        default:
                            Ward = Ward.OrderByDescending(a => a.Ward_Allocation_ID);
                            break;
                    }


                    var WardList = Ward.Skip(start).Take(length).ToList();


                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Ward_Allocation, data = WardList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Ward list", ex);
            }
        }
    }
}
