using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Net;
using System.Data.SqlClient;
using System.IO;
using System.Web.Services;
using System.Drawing.Printing;
using CrystalDecisions.CrystalReports.Engine;
using System.Configuration;
using CrystalDecisions.Shared;
using System.Web.Script.Serialization;

namespace PMS
{
    public partial class ReceiptsView : System.Web.UI.Page
    {
        DataBaseDataContext db = new DataBaseDataContext();
        public static string GetQoute()
        {
            return @"""";
        }

        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static void Delete(int ReceiptID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var rcpt = db.Receipts.Where(r => r.Receipt_ID == ReceiptID).FirstOrDefault();

            //Mark Test as a Un-Discharge

            List<Discharge_Detail> Discharge_DetailList = (from m in db.Discharges
                                                           join d in db.Discharge_Details on m.Discharge_ID equals d.Discharge_ID
                                                           where m.Receipt_ID == ReceiptID
                                                           && d.Transaction_Type == "Test"
                                                           select d
                                                             ).ToList();
            foreach (var item in Discharge_DetailList)
            {
                Lab_Test_Detail investigation = db.Lab_Test_Details.Where(t => t.Lab_Test_Detail_ID == item.Parent_Trans_ID).FirstOrDefault();
                if (investigation != null)
                {
                    investigation.Discharge = false;
                }
            }

            // Deleting details in dischage table.

            Discharge_DetailList = (from m in db.Discharges
                                    join d in db.Discharge_Details on m.Discharge_ID equals d.Discharge_ID
                                    where m.Receipt_ID == ReceiptID
                                    select d
                                                             ).ToList();

            Discharge DischargeMaster = (from m in db.Discharges
                                         join d in db.Discharge_Details on m.Discharge_ID equals d.Discharge_ID
                                         where m.Receipt_ID == ReceiptID
                                         select m
                                                 ).FirstOrDefault();

            decimal DischargeAmount = 0;

            DischargeAmount = (decimal)(from m in db.Discharges
                                        join d in db.Discharge_Details on m.Discharge_ID equals d.Discharge_ID
                                        where m.Receipt_ID == ReceiptID
                                        && d.Transaction_Type != "Test"
                                        select new { m.Net_Amount }
                                                             ).ToList().Distinct().Sum(s => s.Net_Amount);

            // Updating bill...

            if (rcpt != null)
            {
                Ar_Billing bill = db.Ar_Billings.Where(b => b.Bill_ID == rcpt.Bill_ID).FirstOrDefault();
                if (bill != null)
                {
                    bill.Received_Amount -= Convert.ToDecimal(rcpt.Receipt_Amount) - DischargeAmount;
                    bill.Balance_Amount += Convert.ToDecimal(rcpt.Receipt_Amount) - DischargeAmount;
                }
            }

            // Deleting Gl Voucher..

            List<GL_Voucher_Account> voucherList = db.GL_Voucher_Accounts.Where(acc => acc.Voucher_ID == rcpt.voucher_ID).ToList();
            if (voucherList.Count > 0)
                db.GL_Voucher_Accounts.DeleteAllOnSubmit(voucherList);
            if (rcpt != null)
                db.Receipts.DeleteOnSubmit(rcpt);

            // Deleting Discharge Voucher...

            if (DischargeMaster != null)
            {
                GL_Voucher gm = db.GL_Vouchers.Where(a => a.Voucher_ID == DischargeMaster.Voucher_ID).FirstOrDefault();
                if (gm != null)
                    db.GL_Vouchers.DeleteOnSubmit(gm);
                List<GL_Voucher_Account> DischargevoucherList = db.GL_Voucher_Accounts.Where(acc => acc.Voucher_ID == DischargeMaster.Voucher_ID).ToList();
                if (DischargevoucherList.Count > 0)
                    db.GL_Voucher_Accounts.DeleteAllOnSubmit(DischargevoucherList);
            }

            // Deleting Discharge Lab Voucher...

            if (DischargeMaster != null)
            {
                GL_Voucher gm = db.GL_Vouchers.Where(a => a.Voucher_ID == DischargeMaster.Lab_Voucehr_ID).FirstOrDefault();
                if (gm != null)
                    db.GL_Vouchers.DeleteOnSubmit(gm);
                List<GL_Voucher_Account> DischargevoucherList = db.GL_Voucher_Accounts.Where(acc => acc.Voucher_ID == DischargeMaster.Lab_Voucehr_ID).ToList();
                if (DischargevoucherList.Count > 0)
                    db.GL_Voucher_Accounts.DeleteAllOnSubmit(DischargevoucherList);
            }

            if (Discharge_DetailList.Count > 0)
                db.Discharge_Details.DeleteAllOnSubmit(Discharge_DetailList);
            if (DischargeMaster != null)
                db.Discharges.DeleteOnSubmit(DischargeMaster);
            db.SubmitChanges();
        }


        [WebMethod]
        public static string CancelPatient(int Receipt_ID, string reason)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            string status = "Allowdlt";
            string AllowPatientDelete = DBClass.getField("select dbo.GetRights('AllowPatientDelete','" + AppConfig.UserID + "')");

            if (Convert.ToBoolean(AllowPatientDelete) == true)
            {
                status = "Fail";
                Receipt p = new Receipt();
                var query = db.Receipts.SingleOrDefault(x => x.Receipt_ID == Receipt_ID);
                if (query != null)
                {
                    query.CancelRemarks = reason;
                    query.isCancel = true;
                    db.SubmitChanges();
                    status = "success";
                }

                return status;
            }
            return status;
        }

        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    string userId = HttpContext.Current.Session["UserId"].ToString();

                    var Total_Receipts = _dbContext.Receipts.Count();
                    var Receipts = from r in _dbContext.Receipts
                                   join u in _dbContext.aspnet_Users on r.Created_By equals u.UserId
                                   join p in _dbContext.Reg_patients on r.Patient_ID equals p.pat_id
                                   where (r.isCancel == null || r.isCancel == false) &&
                                 (r.Receipt_ID.ToString().Contains(searchValue) || r.Receipt_No.ToString().Contains(searchValue) || p.mr_no_sequence.ToString().Contains(searchValue) || p.Full_Name.Contains(searchValue) || u.UserName.Contains(searchValue))
                                   select new
                                {
                                    Receipt_ID = r.Receipt_ID,
                                    Receipt_No = r.Receipt_No,
                                    Receipt_Date = r.Receipt_Date,
                                    Receipt_Amount = r.Receipt_Amount,
                                    Remarks = r.Remarks,
                                    mr_no_sequence = p.mr_no_sequence,
                                    Full_Name = p.Full_Name,
                                    Creation_Date = r.Creation_Date,
                                    UserName = u.UserName,

                                };

                    var FilteredCount = Receipts.Count();
                    switch (sortColumn)
                    {
                        case "Receipt_Date":
                            Receipts = sortColumnDirection == "asc" ? Receipts.OrderBy(a => a.Receipt_Date) : Receipts.OrderByDescending(a => a.Receipt_Date);
                            break;
                        case "Receipt_No":
                            Receipts = sortColumnDirection == "asc" ? Receipts.OrderBy(b => b.Receipt_No) : Receipts.OrderByDescending(a => a.Receipt_No);
                            break;
                        default:
                            Receipts = Receipts.OrderByDescending(a => a.Receipt_No);
                            break;
                    }

                    var patientList = Receipts.Skip(start).Take(length).ToList();

                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Receipts, data = patientList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Item list", ex);
            }
        }
    }
}
