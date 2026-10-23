using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Data;
using System.Web.UI.WebControls;
using System.Data.SqlClient;
using System.Web.Services;
using System.Web.Script.Services;

namespace PMS.Modules.PatientManagement
{
    public partial class OPDView : System.Web.UI.Page
    {
        DataBaseDataContext db = new DataBaseDataContext();
        static string FilePath = "";
        protected void Page_Load(object sender, EventArgs e)
        {

        }



        [WebMethod]
        public static string EditPatient(string PatID)
        {
            // Get permission value from DB function (returns '0' or '1' as string)
            string allowValue = DBClass.getField(
                $"SELECT dbo.GetRights('AllowPatientEdit', '{AppConfig.UserID}')"
            );

            // Treat null/empty as '0' (not allowed) for safety
            if (Convert.ToBoolean(allowValue) == true)
            {
                return "Allowed";
            }
            else
            {
                return "NotAllowed";
            }
        }
        [WebMethod]
        public static string CancelPatient(string Patient_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            string status = "Allowdlt";
            string AllowPatientDelete = DBClass.getField("select dbo.GetRights('AllowPatientDelete','" + AppConfig.UserID + "')");

            if (Convert.ToBoolean(AllowPatientDelete) == true)
            {
                status = "Fail";
                var listReceitps = db.Receipts.Where(r => r.Patient_ID == Convert.ToInt64(Patient_ID) && r.isCancel == false).ToList();
                var listBillings = db.Ar_Billings.Where(b => b.Patient_ID == Convert.ToInt64(Patient_ID) && b.isCancel == false).ToList();

                if (listReceitps.Count == 0 && listBillings.Count == 0)
                {
                    Patient p = new Patient();
                    var query = db.Patients.SingleOrDefault(x => x.Patient_ID == Convert.ToInt32(Patient_ID));
                    if (query != null)
                    {
                        //query.CancelRemarks = reason;
                        query.isCancel = true;
                        db.SubmitChanges();
                        status = "success";
                    }
                }
                return status;
            }
            return status;
        }

        [WebMethod]
        public static string DeletePatient(string Patient_ID)
        {

            SqlTransaction tranObj = null;
            SqlConnection con = new SqlConnection(DBClass.ConnectionString());
            con.Open();
            tranObj = con.BeginTransaction();
            string GlReceiptVoucher_ID = DBClass.getField("select voucher_id from Patients Where Patient_ID=" + Convert.ToInt32(Patient_ID) + "").ToString();
            string GlPatientCardVoucher_ID = DBClass.getField("select PatientCard_VoucherID from Patients Where Patient_ID=" + Convert.ToInt32(Patient_ID) + "").ToString();
            try
            {
                bool rowDeleted = DBClass.exectueQuery("Delete Patients Where Patient_ID=" + Convert.ToInt32(Patient_ID) + "", tranObj, con);

                if (rowDeleted)
                {

                }
                tranObj.Commit();

                /********Deleting Gl Receipt Voucher Details*******/

                if (GlReceiptVoucher_ID != "")
                {
                    DataBaseDataContext db = new DataBaseDataContext();

                    List<GL_Voucher_Account> GlReceiptVoucher = db.GL_Voucher_Accounts.Where(v => v.Voucher_ID == Convert.ToInt32(GlReceiptVoucher_ID)).ToList();
                    db.GL_Voucher_Accounts.DeleteAllOnSubmit(GlReceiptVoucher);
                    db.SubmitChanges();

                    GL_Voucher voucherHeader = db.GL_Vouchers.Where(v => v.Voucher_ID == Convert.ToInt32(GlReceiptVoucher_ID)).FirstOrDefault();
                    if (voucherHeader != null)
                        db.GL_Vouchers.DeleteOnSubmit(voucherHeader);
                    db.SubmitChanges();
                }

                /********Deleting Gl Patient Card Voucher Details*******/

                if (GlPatientCardVoucher_ID != "")
                {
                    DataBaseDataContext db = new DataBaseDataContext();
                    List<GL_Voucher_Account> GlPatientCardVoucher = db.GL_Voucher_Accounts.Where(v => v.Voucher_ID == Convert.ToInt32(GlPatientCardVoucher_ID)).ToList();
                    db.GL_Voucher_Accounts.DeleteAllOnSubmit(GlPatientCardVoucher);
                    db.SubmitChanges();

                    GL_Voucher voucherHeader = db.GL_Vouchers.Where(v => v.Voucher_ID == Convert.ToInt32(GlPatientCardVoucher_ID)).FirstOrDefault();
                    if (voucherHeader != null)
                        db.GL_Vouchers.DeleteOnSubmit(voucherHeader);
                    db.SubmitChanges();
                }
            }
            catch (Exception exc)
            {
                if (tranObj != null)
                    tranObj.Rollback();
                throw new Exception(exc.Message);
            }
            finally
            {
                con.Close();
            }
            return "";
        }

        [WebMethod]
        public static string GetUserColumnPreferences()
        {
            try
            {
                string userId = AppConfig.UserID.ToString();
                string pageName = "OPDView";

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
                string pageName = "OPDView";

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
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue, string fromDate, string toDate)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    string userId = HttpContext.Current.Session["UserId"].ToString();

                    DateTime searchDate;
                    bool isDateSearch = DateTime.TryParse(searchValue, out searchDate);

                    var Total_pat = _dbContext.Patients.Count();
                    var pat = from p in _dbContext.Patients
                              join rg in _dbContext.Reg_patients on p.Reg_PatId equals rg.pat_id
                              where (p.Opd_No.ToString().Contains(searchValue) || rg.mr_no_sequence.Contains(searchValue) || rg.Full_Name.Contains(searchValue) || rg.NIC.Contains(searchValue) || rg.Mobile1.Contains(searchValue) || (from hr in _dbContext.HR_Employees where hr.Emp_ID == Convert.ToInt32(p.Doctor_ID) select hr.Emp_Name).FirstOrDefault().ToString().Contains(searchValue) || (isDateSearch && p.Created_Time >= searchDate && p.Created_Time < searchDate.AddDays(1)))
                              select new
                              {
                                  Opd_No = Convert.ToInt32(p.Opd_No),
                                  Patient_ID = p.Patient_ID,
                                  Created_Time = p.Created_Time,
                                  mr_no_sequence = rg.mr_no_sequence,
                                  Full_Name = rg.Full_Name,
                                  NIC = rg.NIC,
                                  Mobile1 = rg.Mobile1,
                                  Age = p.Age_years,
                                  Doctor_Id = (from hr in _dbContext.HR_Employees where hr.Emp_ID == Convert.ToInt32(p.Doctor_ID) select hr.Emp_Name).FirstOrDefault(),
                                  Department = _dbContext.GetDataValueName("Patient Main Category", p.Patient_Main_Category),
                                  Patient_Type = _dbContext.GetDataValueName("Patient Type", p.Patient_Type),
                                  Token_No  = p.Doc_Token,
                                  Dept_Token = p.Dept_Token,
                                  isCancel = p.isCancel ?? false
                              };



                    // Start / End date filter (yyyy-MM-dd). Blank = no filter (all data).
                    DateTime fromDt, toDt;
                    if (DateTime.TryParseExact(fromDate, "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out fromDt))
                    {
                        DateTime fromDateValue = fromDt.Date;
                        pat = pat.Where(a => a.Created_Time >= fromDateValue);
                    }
                    if (DateTime.TryParseExact(toDate, "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out toDt))
                    {
                        DateTime toDateExclusive = toDt.Date.AddDays(1);
                        pat = pat.Where(a => a.Created_Time < toDateExclusive);
                    }

                    var FilteredCount = pat.Count();
                    switch (sortColumn)
                    {
                        case "Opd_No":
                            pat = sortColumnDirection == "asc" ? pat.OrderBy(a => a.Opd_No) : pat.OrderByDescending(a => a.Opd_No);
                            break;
                        case "Patient_ID":
                            pat = sortColumnDirection == "asc" ? pat.OrderBy(a => a.Patient_ID) : pat.OrderByDescending(a => a.Patient_ID);
                            break;
                        case "Created_Time":
                            pat = sortColumnDirection == "asc" ? pat.OrderBy(a => a.Created_Time) : pat.OrderByDescending(a => a.Created_Time);
                            break;
                        case "mr_no_sequence":
                            pat = sortColumnDirection == "asc" ? pat.OrderBy(a => a.mr_no_sequence) : pat.OrderByDescending(a => a.mr_no_sequence);
                            break;
                        case "Age":
                            pat = sortColumnDirection == "asc" ? pat.OrderBy(a => a.Age) : pat.OrderByDescending(a => a.Age);
                            break;
                        default:
                            pat = pat.OrderByDescending(a => a.Created_Time);
                            break;
                    }


                    var patientList = pat.Skip(start).Take(length).ToList();


                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_pat, data = patientList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching patient list", ex);
            }
        }

        // Read-only detail of one OPD visit (row click on the list), with its billed services
        [WebMethod]
        public static object GetOPDDetail(int Patient_ID)
        {
            DataTable dtOpd = DBClass.getDataTable(@"
                SELECT p.Patient_ID, p.Opd_No, rg.mr_no_sequence, rg.Full_Name, rg.Father_Name, rg.Gender, p.Age_years, rg.NIC, rg.Mobile1,
                       rg.Permanent_Address, rg.Blood_Group, FORMAT(p.Created_Time, 'dd-MMM-yyyy hh:mm tt') AS Created_Time,
                       p.Doc_Token, p.Dept_Token,
                       dbo.GetDataValueName('Patient Main Category', p.Patient_Main_Category) AS Department,
                       dbo.GetDataValueName('Patient Type', p.Patient_Type) AS Patient_Type,
                       (SELECT TOP 1 hr.Emp_Name FROM HR_Employees hr WHERE CONVERT(varchar(20), hr.Emp_ID) = p.Doctor_ID) AS Doctor,
                       (SELECT TOP 1 hr.Emp_Name FROM HR_Employees hr WHERE hr.Emp_ID = p.opd_doc_reffered) AS Referred_By,
                       p.Receipt_Amount, p.discount_amt, ISNULL(p.free_check, 0) AS free_check, p.Status, p.Remarks,
                       ISNULL(p.isCancel, 0) AS isCancel, p.CancelRemarks, u.UserName AS Created_By
                FROM Patients p
                JOIN Reg_patient rg ON rg.pat_id = p.Reg_PatId
                LEFT JOIN aspnet_Users u ON u.UserId = p.Created_By
                WHERE p.Patient_ID = @Patient_ID",
                DBClass.Param("@Patient_ID", Patient_ID));

            DataTable dtServices = DBClass.getDataTable(@"
                SELECT b.Bill_No, d.Item_Name, d.Qty, d.Amount, d.Discount_Amount, d.Net_Amount, ISNULL(b.isCancel, 0) AS isCancel
                FROM Ar_Billings b
                JOIN Ar_Billing_Details d ON d.Bill_ID = b.Bill_ID
                WHERE b.Opd_Id = @Patient_ID
                ORDER BY b.Bill_ID, d.Bill_Details_ID",
                DBClass.Param("@Patient_ID", Patient_ID));

            return new { opd = ToRows(dtOpd).FirstOrDefault(), services = ToRows(dtServices) };
        }

        private static List<Dictionary<string, object>> ToRows(DataTable dt)
        {
            var rows = new List<Dictionary<string, object>>();
            foreach (DataRow dr in dt.Rows)
            {
                var row = new Dictionary<string, object>();
                foreach (DataColumn col in dt.Columns)
                {
                    row[col.ColumnName] = dr[col] == DBNull.Value ? null : dr[col];
                }
                rows.Add(row);
            }
            return rows;
        }
    }
}