using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.PatientManagement
{
    public partial class OPD_Refund_List : System.Web.UI.Page
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

                    var Total_Refunds = _dbContext.OPD_Refunds.Count();
                    var Refunds = from R in _dbContext.OPD_Refunds
                                  join reg in _dbContext.Reg_patients on R.Reg_PatId equals reg.pat_id
                                  where
                                       ((reg.Full_Name.ToString().Contains(searchValue) || R.Refund_Amount.ToString().Contains(searchValue) || R.OPD_No.ToString().Contains(searchValue)))
                                  select new
                                  {
                                      Refund_ID = R.Refund_ID,
                                      OPD_No = R.OPD_No,
                                      Full_Name = reg.Full_Name,
                                      Refund_Date = R.Refund_Date,
                                      Refund_Amount = R.Refund_Amount,
                                      Hospital_Refund = R.Hospital_Refund,
                                      Doctor_Refund = R.Doctor_Refund,
                                      Remarks = R.Remarks,
                                  };

                    var FilteredCount = Refunds.Count();
                    switch (sortColumn)
                    {
                        case "Refund_ID":
                            Refunds = sortColumnDirection == "asc" ? Refunds.OrderBy(a => a.Refund_ID) : Refunds.OrderByDescending(a => a.Refund_ID);
                            break;
                        case "Refund_Date":
                            Refunds = sortColumnDirection == "asc" ? Refunds.OrderBy(a => a.Refund_Date) : Refunds.OrderByDescending(a => a.Refund_Date);
                            break;
                        default:
                            Refunds = Refunds.OrderByDescending(a => a.Refund_ID);
                            break;
                    }

                    var RefundList = Refunds.Skip(start).Take(length).ToList();

                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Refunds, data = RefundList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching OPD Refund list", ex);
            }
        }      
    }
}