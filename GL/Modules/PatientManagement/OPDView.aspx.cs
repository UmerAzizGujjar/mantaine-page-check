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
                $"SELECT dbo.GetRights('AllowPatientDelete', '{AppConfig.UserID}')"
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
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    // Use compiled query for better performance
                    string userId = HttpContext.Current.Session["UserId"]?.ToString() ?? "";

                    DateTime searchDate;
                    bool isDateSearch = DateTime.TryParse(searchValue, out searchDate);

                    // Get total count first (faster than Count() on filtered query)
                    var Total_pat = _dbContext.Patients.Count(p => p.isCancel == false || p.isCancel == null);

                    // Build query with proper filtering
                    var patQuery = from p in _dbContext.Patients
                                   join rg in _dbContext.Reg_patients on p.Reg_PatId equals rg.pat_id
                                   where (p.isCancel == false || p.isCancel == null)
                                   select new
                                   {
                                       p.Opd_No,
                                       p.Patient_ID,
                                       p.Created_Time,
                                       rg.mr_no_sequence,
                                       rg.Full_Name,
                                       rg.NIC,
                                       rg.Mobile1,
                                       p.Age_years,
                                       p.Doctor_ID,
                                       p.Patient_Main_Category,
                                       p.Patient_Type
                                   };

                    // Apply search filter
                    if (!string.IsNullOrEmpty(searchValue))
                    {
                        patQuery = patQuery.Where(p =>
                            p.Opd_No.ToString().Contains(searchValue) ||
                            p.mr_no_sequence.Contains(searchValue) ||
                            p.Full_Name.Contains(searchValue) ||
                            p.NIC.Contains(searchValue) ||
                            _dbContext.GetDataValueName("Patient Main Category", p.Patient_Main_Category).Contains(searchValue) ||
                            _dbContext.GetDataValueName("Patient Type", p.Patient_Type).Contains(searchValue) ||
                            (from hr in _dbContext.HR_Employees where hr.Emp_ID == Convert.ToInt32(p.Doctor_ID) select hr.Emp_Name).FirstOrDefault().ToString().Contains(searchValue) ||
                            (isDateSearch && p.Created_Time >= searchDate && p.Created_Time < searchDate.AddDays(1))
                        );
                    }

                    var FilteredCount = patQuery.Count();

                    // Apply sorting
                    switch (sortColumn)
                    {
                        case "Opd_No":
                            patQuery = sortColumnDirection == "asc"
                                ? patQuery.OrderBy(a => a.Opd_No)
                                : patQuery.OrderByDescending(a => a.Opd_No);
                            break;
                        case "Patient_ID":
                            patQuery = sortColumnDirection == "asc"
                                ? patQuery.OrderBy(a => a.Patient_ID)
                                : patQuery.OrderByDescending(a => a.Patient_ID);
                            break;
                        case "Created_Time":
                            patQuery = sortColumnDirection == "asc"
                                ? patQuery.OrderBy(a => a.Created_Time)
                                : patQuery.OrderByDescending(a => a.Created_Time);
                            break;
                        case "mr_no_sequence":
                            patQuery = sortColumnDirection == "asc"
                                ? patQuery.OrderBy(a => a.mr_no_sequence)
                                : patQuery.OrderByDescending(a => a.mr_no_sequence);
                            break;
                        case "Age":
                            patQuery = sortColumnDirection == "asc"
                                ? patQuery.OrderBy(a => a.Age_years)
                                : patQuery.OrderByDescending(a => a.Age_years);
                            break;
                        default:
                            patQuery = patQuery.OrderByDescending(a => a.Created_Time);
                            break;
                    }

                    // Use Take/Skip for pagination (more efficient)
                    var patientList = patQuery
                        .Skip(start)
                        .Take(length)
                        .AsEnumerable() // Materialize query before projection
                        .Select(p => new
                        {
                            Opd_No = Convert.ToInt32(p.Opd_No),
                            Patient_ID = p.Patient_ID,
                            Created_Time = p.Created_Time,
                            mr_no_sequence = p.mr_no_sequence,
                            Full_Name = p.Full_Name,
                            NIC = p.NIC,
                            Mobile1 = p.Mobile1,
                            Age = p.Age_years,
                            Doctor_Id = (from hr in _dbContext.HR_Employees where hr.Emp_ID == Convert.ToInt32(p.Doctor_ID) select hr.Emp_Name).FirstOrDefault() ?? "",
                            Department = _dbContext.GetDataValueName("Patient Main Category", p.Patient_Main_Category),
                            Patient_Type = _dbContext.GetDataValueName("Patient Type", p.Patient_Type)
                        })
                        .ToList();

                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_pat, data = patientList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                // Log error for debugging
                System.Diagnostics.Debug.WriteLine("Error in ViewList: " + ex.Message);
                throw new Exception("Error fetching patient list", ex);
            }
        }
        //[WebMethod]
        //public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        //{
        //    try
        //    {
        //        using (var _dbContext = new DataBaseDataContext())
        //        {
        //            string userId = HttpContext.Current.Session["UserId"].ToString();

        //            DateTime searchDate;
        //            bool isDateSearch = DateTime.TryParse(searchValue, out searchDate);

        //            var Total_pat = _dbContext.Patients.Count();
        //            var pat = from p in _dbContext.Patients
        //                      join rg in _dbContext.Reg_patients on p.Reg_PatId equals rg.pat_id
        //                      where (p.isCancel == false || p.isCancel == null) &&
        //                            (p.Opd_No.ToString().Contains(searchValue) || rg.mr_no_sequence.Contains(searchValue)  || rg.Full_Name.Contains(searchValue) || rg.NIC.Contains(searchValue) || _dbContext.GetDataValueName("Patient Main Category", p.Patient_Main_Category).Contains(searchValue) || _dbContext.GetDataValueName("Patient Type", p.Patient_Type).Contains(searchValue) || (from hr in _dbContext.HR_Employees where hr.Emp_ID == Convert.ToInt32(p.Doctor_ID) select hr.Emp_Name).FirstOrDefault().ToString().Contains(searchValue) || (isDateSearch && p.Created_Time >= searchDate && p.Created_Time < searchDate.AddDays(1)))
        //                      select new
        //                      {
        //                          Opd_No = Convert.ToInt32(p.Opd_No),
        //                          Patient_ID = p.Patient_ID,
        //                          Created_Time = p.Created_Time,
        //                          mr_no_sequence = rg.mr_no_sequence,
        //                          Full_Name = rg.Full_Name,
        //                          NIC = rg.NIC,
        //                          Mobile1 = rg.Mobile1,
        //                          Age = p.Age_years,
        //                          Doctor_Id = (from hr in _dbContext.HR_Employees where hr.Emp_ID == Convert.ToInt32(p.Doctor_ID) select hr.Emp_Name).FirstOrDefault(),
        //                          Department = _dbContext.GetDataValueName("Patient Main Category", p.Patient_Main_Category),
        //                          Patient_Type = _dbContext.GetDataValueName("Patient Type", p.Patient_Type)
        //                      };



        //            var FilteredCount = pat.Count();
        //            switch (sortColumn)
        //            {
        //                case "Opd_No":
        //                    pat = sortColumnDirection == "asc" ? pat.OrderBy(a => a.Opd_No) : pat.OrderByDescending(a => a.Opd_No);
        //                    break;
        //                case "Patient_ID":
        //                    pat = sortColumnDirection == "asc" ? pat.OrderBy(a => a.Patient_ID) : pat.OrderByDescending(a => a.Patient_ID);
        //                    break;
        //                case "Created_Time":
        //                    pat = sortColumnDirection == "asc" ? pat.OrderBy(a => a.Created_Time) : pat.OrderByDescending(a => a.Created_Time);
        //                    break;
        //                case "mr_no_sequence":
        //                    pat = sortColumnDirection == "asc" ? pat.OrderBy(a => a.mr_no_sequence) : pat.OrderByDescending(a => a.mr_no_sequence);
        //                    break;
        //                case "Age":
        //                    pat = sortColumnDirection == "asc" ? pat.OrderBy(a => a.Age) : pat.OrderByDescending(a => a.Age);
        //                    break;
        //                default:
        //                    pat = pat.OrderByDescending(a => a.Created_Time); 
        //                    break;
        //            }


        //            var patientList = pat.Skip(start).Take(length).ToList();


        //            var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_pat, data = patientList };
        //            return jsonData;
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        throw new Exception("Error fetching patient list", ex);
        //    }
        //}

    }
}