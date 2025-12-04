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
                                  join reg in _dbContext.Reg_patients on R.pat_id equals reg.pat_id
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

        [WebMethod]
        public static object GetRefundByID(string refundID)
        {
            if (string.IsNullOrWhiteSpace(refundID) || !int.TryParse(refundID, out int id))
                return null;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var refund = db.OPD_Refunds
                               .Where(r => r.Refund_ID == id)
                               .Select(r => new
                               {
                                   r.Refund_ID,
                                   r.OPD_No,
                                   r.pat_id,
                                   Refund_Date = r.Refund_Date.HasValue
                                                 ? r.Refund_Date.Value.ToString("MM/dd/yyyy")
                                                 : "",
                                   r.Hospital_Refund,
                                   r.Doctor_Refund,
                                   r.Refund_Amount,
                                   r.Remarks
                               })
                               .FirstOrDefault();

                if (refund == null)
                    return null;

                var patient = (from pat in db.Patients
                               where pat.Reg_PatId == refund.pat_id
                               select new
                               {
                                   pat.Opd_No,
                                   pat.Patient_No,
                                   pat.Full_Name,
                                   pat.Father_Name,
                                   pat.NIC,
                                   pat.Gender,
                                   pat.Mobile1,
                                   pat.Permanent_Address,
                                   pat.Age_years,
                                   Created_Time = pat.Created_Time,
                                   pat.Email,
                                   pat.City,
                                   pat.Province,
                                   pat.Profession,
                                   pat.Doctor_ID,
                                   pat.Doctor_Amount,
                                   pat.Hospital_share,
                                   pat.Actual_amount,
                                   Department = db.GetDataValueName("Patient Main Category", pat.Patient_Main_Category),
                                   Patient_Type = db.GetDataValueName("Patient Type", pat.Patient_Type)
                               }).FirstOrDefault();

                return new
                {
                    Refund = refund,
                    Patient = patient
                };
            }
        }

    }
}