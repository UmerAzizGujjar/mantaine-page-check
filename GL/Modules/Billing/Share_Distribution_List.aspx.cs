using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.Billing
{
    public partial class Share_Distribution_List : System.Web.UI.Page
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

                    var Total_Billing = _dbContext.IPD_Distribution_Masters.Count();
                    var Billing = from b in _dbContext.IPD_Distribution_Masters
                                  join p in _dbContext.Reg_patients on b.Patient_Id equals p.pat_id
                                  join u in _dbContext.Ar_Billings on b.Bill_Id equals u.Bill_ID
                                  where ( b.IsCancel == false || b.IsCancel == null ) && (
                                        (u.Bill_No.ToString().Contains(searchValue) || p.Full_Name.Contains(searchValue) || p.mr_no_sequence.Contains(searchValue)))
                                  select new
                                  {
                                      Bill_No = u.Bill_No,
                                      Bill_Date = b.Distribution_Date,
                                      Remarks = b.Remarks,
                                      Total_Amount = b.Total_Amount, 
                                      MrNo = p.mr_no_sequence,
                                      Full_Name = p.Full_Name,
                                      Bill_ID = u.Bill_ID,
                                      Distribution_Id = b.Distribution_Id,
                                      Status = b.Voucher_Status
                                  };

                    var FilteredCount = Billing.Count();
                    switch (sortColumn)
                    {
                        case "Bill_No":
                            Billing = sortColumnDirection == "asc" ? Billing.OrderBy(a => a.Bill_No) : Billing.OrderByDescending(a => a.Bill_No);
                            break;
                        case "Bill_Date":
                            Billing = sortColumnDirection == "asc" ? Billing.OrderBy(b => b.Bill_Date) : Billing.OrderByDescending(a => a.Bill_Date);
                            break;
                        case "MrNo":
                            Billing = sortColumnDirection == "asc" ? Billing.OrderBy(a => a.MrNo) : Billing.OrderByDescending(a => a.MrNo);
                            break;
                        default:
                            Billing = Billing.OrderByDescending(a => a.Bill_No);
                            break;
                    }

                    var patientList = Billing.Skip(start).Take(length).ToList();

                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Billing, data = patientList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching patient list", ex);
            }
        }
        [WebMethod]
        public static string CancelPatient(int Bill_No)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            int billPK_ID = (from b in db.Ar_Billings where b.Bill_No == Convert.ToString(Bill_No) select b.Bill_ID).FirstOrDefault();
            string status = "Allowdlt";
            string AllowPatientDelete = DBClass.getField("select dbo.GetRights('AllowBillDelete','" + AppConfig.UserID + "')");

            if (Convert.ToBoolean(AllowPatientDelete) == true)
            {
                status = "Fail";
               
                    Ar_Billing p = new Ar_Billing();
                    var query = db.IPD_Distribution_Masters.SingleOrDefault(x => x.Distribution_Id == (Bill_No));
                    if (query != null)
                    {
                        query.IsCancel = true;
                        query.Cancel_By = AppConfig.UserID;
                        query.Cancel_Time = DateTime.Now;
                        db.SubmitChanges();
                        status = "success";
                    }
                
                return status;
            }
            return status;
        }
    }
}