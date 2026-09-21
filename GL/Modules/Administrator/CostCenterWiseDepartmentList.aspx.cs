using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class CostCenterWiseDepartmentList : System.Web.UI.Page
    {
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
                    string userId = HttpContext.Current.Session["UserId"].ToString();

                    DateTime searchDate;
                    bool isDateSearch = DateTime.TryParse(searchValue, out searchDate);

                    var Total_CostCenter_Wise_Department = _dbContext.CostCenter_Wise_Departments.Count();
                    var CostCenterList = from CC in _dbContext.CostCenter_Wise_Departments
                                         where (
                                         CC.CostCenter.Contains(searchValue) || (isDateSearch && CC.Created_Time >= searchDate && CC.Created_Time < searchDate.AddDays(1)))
                                         select new
                                         {
                                             CostCenter_wise_Department_Id = CC.CostCenter_wise_Department_Id,
                                             CostCenter_name = _dbContext.GetDataValueName("Cost Center", CC.CostCenter),
                                             Created_Time = CC.Created_Time,
                                         };

                    var FilteredCount = CostCenterList.Count();
                    switch (sortColumn)
                    {
                        case "CostCenter_name":
                            CostCenterList = sortColumnDirection == "asc" ? CostCenterList.OrderBy(a => a.CostCenter_name) : CostCenterList.OrderByDescending(a => a.CostCenter_name);
                            break;
                        default:
                            CostCenterList = CostCenterList.OrderBy(a => a.CostCenter_wise_Department_Id);
                            break;
                    }

                    var CostCenterWiseList = CostCenterList.Skip(start).Take(length).ToList();

                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_CostCenter_Wise_Department, data = CostCenterWiseList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Cost Center Wise Department list", ex);
            }
        }

        [WebMethod]
        public static string DeleteRecord(string ID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var DeleteDetail = DBClass.getField("delete from CostCenter_Wise_Department_Detail where CostCenter_wise_Department_Id= '" + ID + "' ");
            var Delete = DBClass.getField("delete from CostCenter_Wise_Department where CostCenter_wise_Department_Id= '" + ID + "' ");
            return (Delete);
        }
    }
}
