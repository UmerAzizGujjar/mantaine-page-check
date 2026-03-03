using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.Services;
using System.Web.Script.Serialization;
using System.Data.Entity.Core.Mapping;


namespace PMS
{
    public partial class Receipts : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static int SaveRecord(int Receipt_ID, int Patient_ID, DateTime Receipt_Date, string Remarks, decimal Receipt_Amount, int Bill_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            Receipt rcpt = null;
            if (Receipt_ID == 0)
            {
                rcpt = new Receipt();
                rcpt.Created_By = AppConfig.UserID;
                rcpt.Creation_Date = DateTime.Now;
                rcpt.Receipt_No = DBClass.GetNewNumber("Receipt_No", "Receipts", "");
            }
            else
            {
                rcpt = db.Receipts.Where(r => r.Receipt_ID == Receipt_ID).FirstOrDefault();
                rcpt.Updated_By = AppConfig.UserID;
                rcpt.Updation_Date = DateTime.Now;
            }
            rcpt.Patient_ID = Patient_ID;
            rcpt.Receipt_Amount = Receipt_Amount;
            rcpt.Receipt_Date = Receipt_Date;
            rcpt.Posted = false;
            rcpt.Remarks = Remarks;
            rcpt.Discharge = false;
            rcpt.Discharge_Charges = (decimal)0.00;
            rcpt.Bill_ID = Bill_ID;

            if (Receipt_ID == 0)
                db.Receipts.InsertOnSubmit(rcpt);

            db.SubmitChanges();

            #region "Insert Voucher"


            GL_Voucher gvm;

            #region "Checking Voucher Header"


            #endregion

            #region "Deleting Previous Details"
            #endregion


            db.SubmitChanges();

            #endregion

            db.SubmitChanges();
            return rcpt.Receipt_ID;
        }
        public class BIllResult
        {

            public string Bill_ID;
            public string Bill_No;
            public string Bill_Date;
            public string Remarks;
            public string Total_Amount;

        }
        [WebMethod]
        public static string SaveReceipt(int Receipt_ID, int Patient_ID, DateTime Receipt_Date, string Remarks, decimal Receipt_Amount, int Bill_ID, bool Discharge, decimal Discharge_Amount)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var TotalReciept = "";
            int MR_NO = DBClass.GetMRNOBy_PatientID_reg(Patient_ID);
            var billsList = (from b in db.Ar_Billings
                             join p in db.Reg_patients
                             on b.Patient_ID equals p.pat_id
                             where p.Patient_No == MR_NO
                             && b.Balance_Amount > 0
                             && b.Bill_ID == Bill_ID
                             orderby b.Bill_ID descending
                             select new
                             {
                                 MR_NO = p.Patient_No,
                                 Patient_Name = p.Full_Name,
                                 b.Bill_ID,
                                 b.Bill_No,
                                 b.Bill_Date,
                                 Amount = b.Net_Amount,
                                 PackageName = (from pkg in db.Packages join bd in db.Ar_Billing_Details on pkg.Packages_ID equals bd.ParentTrans_ID where bd.Bill_ID == b.Bill_ID select pkg.Package_Name).Distinct().FirstOrDefault(),
                                 b.Received_Amount,
                                 b.Balance_Amount
                             }).ToList();
            var Bill_Remain = 0.0;
            var reciept_Remain = 0.00;
            foreach (var record in billsList)
            {
                Receipt rcpt = null;
                var FinalNetAMount = Receipt_Amount;
                var Bill_Amount = record.Balance_Amount;
                decimal OldReceipt_Amount = 0;
                if (Bill_Remain > 0)
                {

                    return TotalReciept;
                }
                if (reciept_Remain > 0)
                {
                    FinalNetAMount = Convert.ToDecimal(reciept_Remain);
                }

                Bill_Remain = 0.00;
                reciept_Remain = 0.00;


                if (Receipt_ID == 0)
                {
                    rcpt = new Receipt();
                    rcpt.Created_By = AppConfig.UserID;
                    rcpt.Creation_Date = DateTime.Now;
                    rcpt.Receipt_No = DBClass.GetNewNumber("Receipt_No", "Receipts", "");
                }
                else
                {
                    rcpt = db.Receipts.Where(r => r.Receipt_ID == Receipt_ID).FirstOrDefault();
                    rcpt.Updated_By = AppConfig.UserID;
                    rcpt.Updation_Date = DateTime.Now;
                    OldReceipt_Amount = Convert.ToDecimal(rcpt.Receipt_Amount);
                }
                if (FinalNetAMount < record.Balance_Amount)
                {
                    Bill_Remain = Convert.ToDouble(record.Balance_Amount - FinalNetAMount);
                    rcpt.Receipt_Amount = Convert.ToDecimal(FinalNetAMount);
                }
                else if (FinalNetAMount > record.Balance_Amount)
                {
                    reciept_Remain = Convert.ToDouble(FinalNetAMount - record.Balance_Amount);
                    rcpt.Receipt_Amount = Convert.ToDecimal(record.Balance_Amount);

                }
                else
                {

                    rcpt.Receipt_Amount = FinalNetAMount;
                    Bill_Remain = 1;


                }


                rcpt.Patient_ID = Patient_ID;

                rcpt.Discharge_Charges = (decimal)0.00;
                rcpt.Receipt_Date = Receipt_Date;
                rcpt.Posted = false;
                rcpt.Discharge = Discharge;
                rcpt.Remarks = Remarks;
                rcpt.Bill_ID = record.Bill_ID;
                if (Receipt_ID == 0)
                    db.Receipts.InsertOnSubmit(rcpt);
                db.SubmitChanges();

                var TReciept = rcpt.Receipt_ID.ToString();
                if (TotalReciept == "")
                    TotalReciept = TReciept;
                else
                    TotalReciept = TotalReciept + "," + TReciept;
                if (rcpt != null)
                    UpdateBill((int)rcpt.Bill_ID, (decimal)(Convert.ToDecimal(rcpt.Receipt_Amount)), OldReceipt_Amount);


            }
            return TotalReciept;
        }

        [WebMethod]
        public static void InsertVoucherForProfitORLoss_Lab(int DischargeID)
        {
            #region "Insert Voucher"


            GL_Voucher gvm;
            DataBaseDataContext db = new DataBaseDataContext();

            Discharge DischargeMaster = (from dsm in db.Discharges
                                         where dsm.Discharge_ID == DischargeID
                                         select dsm
                                           ).FirstOrDefault();
            List<Discharge_Detail> DischargeDetails = (from dsd in db.Discharge_Details
                                                       where dsd.Discharge_ID == DischargeID
                                                       select dsd
                                           ).ToList();
            decimal LabAmount = 0;

            LabAmount = Convert.ToDecimal((from dsd in db.Discharge_Details
                                           join dsm in db.Discharges
                                           on dsd.Discharge_ID equals dsm.Discharge_ID
                                           where dsd.Discharge_ID == DischargeID
                                           && dsd.Transaction_Type == "Test"
                                           select new { dsd }
                                             ).Distinct().Sum(a => a.dsd.Item_Amount));

            if (LabAmount == null)
                LabAmount = 0;

            Receipt Rcpt = (from rcpt in db.Receipts
                            where rcpt.Receipt_ID == DischargeMaster.Receipt_ID
                            select rcpt
                              ).FirstOrDefault();

            Reg_patient pat = (from p in db.Reg_patients
                           where p.pat_id == DischargeMaster.Patient_ID
                           select p).FirstOrDefault();

            #region "Checking Voucher Header"

            if (DischargeMaster.Lab_Voucehr_ID != null)
            {
                gvm = (from vm in db.GL_Vouchers
                       where vm.Voucher_ID == DischargeMaster.Lab_Voucehr_ID
                       select vm).FirstOrDefault();
                if (gvm != null)
                {
                    gvm.Updated_By = AppConfig.UserID;
                    gvm.Update_Time = Convert.ToDateTime(DateTime.Now.ToString(AppConfig.DateFormat));
                    gvm.Approved_By = AppConfig.UserID;
                    gvm.Approved_Time = Convert.ToDateTime(DateTime.Now.ToString(AppConfig.DateFormat));
                }
                else
                {


                    int VoucherNo = DBClass.GetNewVoucherNo("JV", DateTime.Now);
                    string PeriodID = DBClass.getField("select Period_ID from GL_Periods where '" + DateTime.Now.ToString("yyyy-MM-dd") + "' between Period_start_date and Period_end_date").ToString();
                    gvm = new GL_Voucher();
                    gvm.Voucher_Type = "JV";
                    gvm.Voucher_No = VoucherNo;
                    gvm.Remarks = Rcpt.Remarks + "Plus Discharge Amount:- " + LabAmount + " Receipt No:- " + Rcpt.Receipt_No;
                    gvm.Company_ID = AppConfig.Company_ID;
                    gvm.Period_ID = PeriodID;
                    gvm.Voucher_Status = "Approved";
                    gvm.Voucher_Date = Convert.ToDateTime(DateTime.Now.ToString("yyyy-MM-dd"));
                    gvm.Created_By = AppConfig.UserID;
                    gvm.Creation_Time = Convert.ToDateTime(DateTime.Now.ToString(AppConfig.DateFormat));
                    gvm.Updated_By = AppConfig.UserID;
                    gvm.Update_Time = Convert.ToDateTime(DateTime.Now.ToString(AppConfig.DateFormat));
                    gvm.Approved_By = AppConfig.UserID;
                    gvm.Approved_Time = Convert.ToDateTime(DateTime.Now.ToString(AppConfig.DateFormat));
                    gvm.Closing = false;
                    gvm.Cancel = false;
                    db.GL_Vouchers.InsertOnSubmit(gvm);
                    db.SubmitChanges();
                }
            }
            else
            {
                /*******Inserting new Voucher Header*****************/

                int VoucherNo = DBClass.GetNewVoucherNo("JV", DateTime.Now);
                string PeriodID = DBClass.getField("select Period_ID from GL_Periods where '" + DateTime.Now.ToString("yyyy-MM-dd") + "' between Period_start_date and Period_end_date").ToString();
                gvm = new GL_Voucher();
                gvm.Voucher_Type = "JV";
                gvm.Voucher_No = VoucherNo;
                gvm.Remarks = Rcpt.Remarks + "Plus Discharge Amount:- " + LabAmount + " Receipt No:- " + Rcpt.Receipt_No;
                gvm.Company_ID = AppConfig.Company_ID;
                gvm.Period_ID = PeriodID;
                gvm.Voucher_Status = "Approved";
                gvm.Voucher_Date = Convert.ToDateTime(DateTime.Now.ToString("yyyy-MM-dd"));
                gvm.Created_By = AppConfig.UserID;
                gvm.Creation_Time = Convert.ToDateTime(DateTime.Now.ToString(AppConfig.DateFormat));
                gvm.Updated_By = AppConfig.UserID;
                gvm.Update_Time = Convert.ToDateTime(DateTime.Now.ToString(AppConfig.DateFormat));
                gvm.Approved_By = AppConfig.UserID;
                gvm.Approved_Time = Convert.ToDateTime(DateTime.Now.ToString(AppConfig.DateFormat));
                gvm.Closing = false;
                gvm.Cancel = false;
                db.GL_Vouchers.InsertOnSubmit(gvm);
                db.SubmitChanges();
            }
            #endregion

            #region "Deleting Previous Details"
            if (DischargeMaster != null)
            {
                List<GL_Voucher_Account> OldVoucherDetails = db.GL_Voucher_Accounts.Where(v => v.Voucher_ID == Convert.ToInt32(DischargeMaster.Lab_Voucehr_ID)).ToList();
                db.GL_Voucher_Accounts.DeleteAllOnSubmit(OldVoucherDetails);
                db.SubmitChanges();
            }
            #endregion


            if (DischargeMaster != null)
                DischargeMaster.Lab_Voucehr_ID = Convert.ToInt32(gvm.Voucher_ID);

            //string PatientType = db.GetDataValueName("Patient Type", pat.Patient_Type);
            Int32 LabAccount = 0;
            //string LabOR_RadiologyCharges_Account = (PatientType == "General") ? "LabAndRadiologyCharges_GeneralAccount" : "LabAndRadiologyCharges_PrivateAccount";

            //sys_Parm AccountDetails = (from prms in db.sys_Parms
            //                           where prms.Name == LabOR_RadiologyCharges_Account
            //                           select prms
            //    ).FirstOrDefault();

            //var AccountID = (from a in db.GL_Accounts
            //                 where a.Account_Code == AccountDetails.Code.ToString()
            //                 select a).FirstOrDefault();

            //LabAccount = AccountID.Account_ID;


            if (Convert.ToDecimal(DischargeMaster.Investigation_Limit) > LabAmount)
            {
                InsertVoucherLine(Convert.ToInt32(Rcpt.Receipt_No), LabAccount, (Convert.ToDecimal(DischargeMaster.Investigation_Limit) - Convert.ToDecimal(LabAmount)), 0, Convert.ToInt32(gvm.Voucher_ID), Rcpt.Remarks + " Discharge Entry for Lab Amount:- " + LabAmount, 0, "", "Lab Profit and Loss Entry on Discharge", 0);

                InsertVoucherLine(Convert.ToInt32(Rcpt.Receipt_No), LabAccount, 0, Convert.ToDecimal(LabAmount) - Convert.ToDecimal(DischargeMaster.Investigation_Limit), Convert.ToInt32(gvm.Voucher_ID), Rcpt.Remarks + " Discharge Entry for Amount:- " + LabAmount, 0, "", "Lab Profit and Loss Entry on Discharge", 0);

            }

            db.SubmitChanges();

            #endregion
        }

        [WebMethod]
        public static void InsertDischargeVoucher(int DischargeID)
        {
            #region "Insert Voucher"


            GL_Voucher gvm;
            DataBaseDataContext db = new DataBaseDataContext();
            Discharge DischargeMaster = (from dsm in db.Discharges
                                         where dsm.Discharge_ID == DischargeID
                                         select dsm
                                           ).FirstOrDefault();

            List<Discharge_Detail> DischargeDetails = (from dsd in db.Discharge_Details
                                                       where dsd.Discharge_ID == DischargeID
                                                       select dsd
                                           ).ToList();
            decimal DischargeAmount = 0;

            DischargeAmount = Convert.ToDecimal((from dsd in db.Discharge_Details
                                                 join dsm in db.Discharges
                                                 on dsd.Discharge_ID equals dsm.Discharge_ID
                                                 where dsd.Discharge_ID == DischargeID
                                                 && dsd.Transaction_Type != "Test"
                                                 select new { dsm }
                                             ).Distinct().Sum(a => a.dsm.Net_Amount));

            if (DischargeAmount == null)
                DischargeAmount = 0;

            Receipt Rcpt = (from rcpt in db.Receipts
                            where rcpt.Receipt_ID == DischargeMaster.Receipt_ID
                            select rcpt
                              ).FirstOrDefault();

            Reg_patient pat = (from p in db.Reg_patients
                           where p.pat_id == DischargeMaster.Patient_ID
                           select p).FirstOrDefault();

            #region "Checking Voucher Header"

            if (DischargeMaster.Voucher_ID != null)
            {
                gvm = (from vm in db.GL_Vouchers
                       where vm.Voucher_ID == DischargeMaster.Voucher_ID
                       select vm).FirstOrDefault();
                if (gvm != null)
                {

                    gvm.Updated_By = AppConfig.UserID;
                    gvm.Update_Time = Convert.ToDateTime(DateTime.Now.ToString(AppConfig.DateFormat));
                    gvm.Approved_By = AppConfig.UserID;
                    gvm.Approved_Time = Convert.ToDateTime(DateTime.Now.ToString(AppConfig.DateFormat));
                }
                else
                {

                    /*******Inserting new Voucher Header*****************/

                    int VoucherNo = DBClass.GetNewVoucherNo("CRV", DateTime.Now);
                    string PeriodID = DBClass.getField("select Period_ID from GL_Periods where '" + DateTime.Now.ToString("yyyy-MM-dd") + "' between Period_start_date and Period_end_date").ToString();
                    gvm = new GL_Voucher();
                    gvm.Voucher_Type = "CRV";
                    gvm.Voucher_No = VoucherNo;
                    gvm.Remarks = Rcpt.Remarks + "Plus Discharge Amount:- " + DischargeAmount;
                    gvm.Company_ID = AppConfig.Company_ID;
                    gvm.Period_ID = PeriodID;
                    gvm.Voucher_Status = "Approved";
                    gvm.Voucher_Date = Convert.ToDateTime(DateTime.Now.ToString("yyyy-MM-dd"));
                    gvm.Created_By = AppConfig.UserID;
                    gvm.Creation_Time = Convert.ToDateTime(DateTime.Now.ToString(AppConfig.DateFormat));
                    gvm.Updated_By = AppConfig.UserID;
                    gvm.Update_Time = Convert.ToDateTime(DateTime.Now.ToString(AppConfig.DateFormat));
                    gvm.Approved_By = AppConfig.UserID;
                    gvm.Approved_Time = Convert.ToDateTime(DateTime.Now.ToString(AppConfig.DateFormat));
                    gvm.Closing = false;
                    gvm.Cancel = false;
                    db.GL_Vouchers.InsertOnSubmit(gvm);
                    db.SubmitChanges();
                }
            }
            else
            {
                /*******Inserting new Voucher Header*****************/

                int VoucherNo = DBClass.GetNewVoucherNo("CRV", DateTime.Now);
                string PeriodID = DBClass.getField("select Period_ID from GL_Periods where '" + DateTime.Now.ToString("yyyy-MM-dd") + "' between Period_start_date and Period_end_date").ToString();
                gvm = new GL_Voucher();
                gvm.Voucher_Type = "CRV";
                gvm.Voucher_No = VoucherNo;
                gvm.Remarks = Rcpt.Remarks + "Plus Discharge Amount:- " + DischargeAmount;
                gvm.Company_ID = AppConfig.Company_ID;
                gvm.Period_ID = PeriodID;
                gvm.Voucher_Status = "Approved";
                gvm.Voucher_Date = Convert.ToDateTime(DateTime.Now.ToString("yyyy-MM-dd"));
                gvm.Created_By = AppConfig.UserID;
                gvm.Creation_Time = Convert.ToDateTime(DateTime.Now.ToString(AppConfig.DateFormat));
                gvm.Updated_By = AppConfig.UserID;
                gvm.Update_Time = Convert.ToDateTime(DateTime.Now.ToString(AppConfig.DateFormat));
                gvm.Approved_By = AppConfig.UserID;
                gvm.Approved_Time = Convert.ToDateTime(DateTime.Now.ToString(AppConfig.DateFormat));
                gvm.Closing = false;
                gvm.Cancel = false;
                db.GL_Vouchers.InsertOnSubmit(gvm);
                db.SubmitChanges();
            }

            #endregion

            #region "Deleting Previous Details"
            if (DischargeMaster != null)
            {
                List<GL_Voucher_Account> OldVoucherDetails = db.GL_Voucher_Accounts.Where(v => v.Voucher_ID == Convert.ToInt32(DischargeMaster.Voucher_ID)).ToList();
                db.GL_Voucher_Accounts.DeleteAllOnSubmit(OldVoucherDetails);
                db.SubmitChanges();
            }
            #endregion


            if (DischargeMaster != null)
                DischargeMaster.Voucher_ID = Convert.ToInt32(gvm.Voucher_ID);

            //Int32 Receivable_Account = 0;
            //if (pat.Patient_Type != "02")
            //{

                //Receivable_Account = Convert.ToInt32((from prms in db.sys_Parms
                //                                      where prms.Segment1 == pat.Patient_Main_Category && prms.Segment2 == "01" && prms.Segment3 == "Is Income Account"
                //                                      select new { prms.Code }
                //        ).FirstOrDefault().Code);
            //}
            //else
            //{
                //Receivable_Account = Convert.ToInt32((from prms in db.sys_Parms
                //                                      where prms.Segment1 == pat.Patient_Main_Category && prms.Segment2 == pat.Patient_Type && prms.Segment3 == "Is Income Account"
                //                                      select new { prms.Code }
                //           ).FirstOrDefault().Code);
            //}

            //Receivable_Account = (int)(from a in db.GL_Accounts
            //                           where a.Account_Code == Receivable_Account.ToString()
            //                           select new { a.Account_ID }).FirstOrDefault().Account_ID;


            //InsertVoucherLine(Convert.ToInt32(Rcpt.Receipt_No), Receivable_Account, 0, Convert.ToDecimal(DischargeAmount), Convert.ToInt32(gvm.Voucher_ID), Rcpt.Remarks + " Discharge Entry for Amount:- " + DischargeAmount, 0, "", "Discharge", 0);

            db.SubmitChanges();

            #endregion
        }

        public static void InsertReceiptVoucher(int ReceiptID, decimal DischargeAmount)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            Receipt rcpt = db.Receipts.Where(r => r.Receipt_ID == ReceiptID).FirstOrDefault();

            #region "Insert Voucher"


            GL_Voucher gvm;

            #region "Checking Voucher Header"            

            if (DischargeAmount == null)
                DischargeAmount = 0;


            if (rcpt.voucher_ID != null)
            {
                gvm = (from vm in db.GL_Vouchers
                       where vm.Voucher_ID == rcpt.voucher_ID
                       select vm).FirstOrDefault();
                if (gvm != null)
                {

                    gvm.Updated_By = AppConfig.UserID;
                    gvm.Update_Time = Convert.ToDateTime(DateTime.Now.ToString(AppConfig.DateFormat));
                    gvm.Approved_By = AppConfig.UserID;
                    gvm.Approved_Time = Convert.ToDateTime(DateTime.Now.ToString(AppConfig.DateFormat));
                }
                else
                {

                    /*******Inserting new Voucher Header*****************/

                    int VoucherNo = DBClass.GetNewVoucherNo("CRV", DateTime.Now);
                    string PeriodID = DBClass.getField("select Period_ID from GL_Periods where '" + DateTime.Now.ToString("yyyy-MM-dd") + "' between Period_start_date and Period_end_date").ToString();
                    gvm = new GL_Voucher();
                    gvm.Voucher_Type = "CRV";
                    gvm.Voucher_No = VoucherNo;
                    gvm.Remarks = rcpt.Remarks;
                    gvm.Company_ID = AppConfig.Company_ID;
                    gvm.Period_ID = PeriodID;
                    gvm.Voucher_Status = "Approved";
                    gvm.Voucher_Date = Convert.ToDateTime(DateTime.Now.ToString("yyyy-MM-dd"));
                    gvm.Created_By = AppConfig.UserID;
                    gvm.Creation_Time = Convert.ToDateTime(DateTime.Now.ToString(AppConfig.DateFormat));
                    gvm.Updated_By = AppConfig.UserID;
                    gvm.Update_Time = Convert.ToDateTime(DateTime.Now.ToString(AppConfig.DateFormat));
                    gvm.Approved_By = AppConfig.UserID;
                    gvm.Approved_Time = Convert.ToDateTime(DateTime.Now.ToString(AppConfig.DateFormat));
                    gvm.Closing = false;
                    gvm.Cancel = false;
                    db.GL_Vouchers.InsertOnSubmit(gvm);
                    db.SubmitChanges();
                }
            }
            else
            {
                /*******Inserting new Voucher Header*****************/

                int VoucherNo = DBClass.GetNewVoucherNo("CRV", DateTime.Now);
                string PeriodID = DBClass.getField("select Period_ID from GL_Periods where '" + DateTime.Now.ToString("yyyy-MM-dd") + "' between Period_start_date and Period_end_date").ToString();
                gvm = new GL_Voucher();
                gvm.Voucher_Type = "CRV";
                gvm.Voucher_No = VoucherNo;
                gvm.Remarks = rcpt.Remarks;
                gvm.Company_ID = AppConfig.Company_ID;
                gvm.Period_ID = PeriodID;
                gvm.Voucher_Status = "Approved";
                gvm.Voucher_Date = Convert.ToDateTime(DateTime.Now.ToString("yyyy-MM-dd"));
                gvm.Created_By = AppConfig.UserID;
                gvm.Creation_Time = Convert.ToDateTime(DateTime.Now.ToString(AppConfig.DateFormat));
                gvm.Updated_By = AppConfig.UserID;
                gvm.Update_Time = Convert.ToDateTime(DateTime.Now.ToString(AppConfig.DateFormat));
                gvm.Approved_By = AppConfig.UserID;
                gvm.Approved_Time = Convert.ToDateTime(DateTime.Now.ToString(AppConfig.DateFormat));
                gvm.Closing = false;
                gvm.Cancel = false;
                db.GL_Vouchers.InsertOnSubmit(gvm);
                db.SubmitChanges();
            }

            #endregion

            #region "Deleting Previous Details"
            if (rcpt != null)
            {
                List<GL_Voucher_Account> OldVoucherDetails = db.GL_Voucher_Accounts.Where(v => v.Voucher_ID == Convert.ToInt32(rcpt.voucher_ID)).ToList();
                db.GL_Voucher_Accounts.DeleteAllOnSubmit(OldVoucherDetails);
                db.SubmitChanges();
            }
            #endregion


            if (rcpt != null)
                rcpt.voucher_ID = Convert.ToInt32(gvm.Voucher_ID);


            db.SubmitChanges();

            #endregion
        }

        public static void UpdateBill(int Bill_ID, decimal Amount, decimal OldReceiptAmount)
        {
            #region "Update the Bill"

            DataBaseDataContext db = new DataBaseDataContext();
            Ar_Billing bill = db.Ar_Billings.Where(b => b.Bill_ID == Bill_ID).FirstOrDefault();
            if (bill != null)
            {
                {
                    bill.Received_Amount -= OldReceiptAmount;
                    bill.Balance_Amount += OldReceiptAmount;
                }
                bill.Received_Amount += Amount;
                bill.Balance_Amount -= Amount;
            }
            db.SubmitChanges();
            #endregion
        }

        [WebMethod]
        public static string LoadRecord(string Receipt_ID)
        {
            string[] namesArray = Receipt_ID.Split(',');
            List<string> namesList = new List<string>(namesArray.Length);
            DataBaseDataContext db = new DataBaseDataContext();
            List<ReceiptDetail> list = new List<ReceiptDetail>();

            foreach (var ID in namesArray)
            {
                ReceiptDetail IST = new ReceiptDetail();

                var rcpt = (from r in db.Receipts
                            join ar in db.Ar_Billings
                            on r.Bill_ID equals ar.Bill_ID
                            where r.Receipt_ID == Convert.ToInt32(ID)
                            select new
                            {
                                r.Receipt_ID,
                                r.Receipt_No,
                                r.Receipt_Date,
                                r.Remarks,
                                r.Receipt_Amount,
                                r.Bill_ID,
                                ar.Bill_No,
                                r.Discharge_Charges,
                                r.Patient_ID,
                                r.Discharge,
                                ar.Net_Amount
                            }).FirstOrDefault();
                if (rcpt != null)
                {
                    IST.Receipt_ID = rcpt.Receipt_ID.ToString();
                    IST.Receipt_No = rcpt.Receipt_No.ToString();
                    IST.Receipt_Date = Convert.ToDateTime(rcpt.Receipt_Date);
                    IST.Remarks = rcpt.Remarks;
                    IST.Receipt_Amount = rcpt.Receipt_Amount.ToString();
                    IST.Bill_ID = rcpt.Bill_ID.ToString();
                    IST.Bill_No = rcpt.Bill_No.ToString();
                    IST.Discharge_Charges = rcpt.Discharge_Charges.ToString();
                    IST.Patient_ID = rcpt.Patient_ID.ToString();
                    IST.Discharge = Convert.ToBoolean(rcpt.Discharge);
                    IST.NetAmount = rcpt.Net_Amount.ToString();
                }
                list.Add(IST);
            }

            return (new JavaScriptSerializer()).Serialize(list);
        }

        public class ReceiptDetail
        {
            public DateTime Receipt_Date;
            public string Receipt_ID;
            public string Receipt_No;
            public string Remarks;
            public string Receipt_Amount;
            public string Bill_ID;
            public string Discharge_Charges;
            public string Patient_ID;
            public bool Discharge;
            public string NetAmount;
            public string Bill_No;
        }
        public class In_PatientDetail
        {
            public DateTime Admission_Date;
            public string Discharge_On;
            public string Bed_No;
            public string Ward_ID;
            public string Room_ID;
            public string Ward_Name;
            public string Room_Name;
        }
        [System.Web.Services.WebMethod]

        public static string LoadInPatientDetail(string PatientID)
        {

            int Patien_No = Convert.ToInt32(PatientID);
            In_PatientDetail pt = new In_PatientDetail();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            In_Patient pat = new In_Patient();
            var InPatient_ID = Convert.ToInt32(DBClass.getField("select (isnull(max(In_Patient_ID),0)) from In_Patient where Patient_ID=" + PatientID + "").ToString());
            var Inpat = (from tbl in db.In_Patients
                         where tbl.Patient_ID == Patien_No && tbl.In_Patient_ID == InPatient_ID
                         select new
                         {
                             tbl.Bed_No,
                             tbl.Ward_ID,
                             tbl.Room_ID,
                             tbl.Admission_Date,
                             tbl.Discharge_On,
                             Ward_Name = (from i in db.Ward_Definitions where i.Ward_ID == tbl.Ward_ID select i.Ward_No).FirstOrDefault(),
                             Room_Name = (from i in db.Rooms where i.Room_ID == tbl.Room_ID select i.Room_No).FirstOrDefault(),
                             tbl.Patient_Discount_Type,

                             Patient_Discount_Typename = db.GetDataValueName("Patient Type", tbl.Patient_Discount_Type),
                         }).FirstOrDefault();
            if (Inpat != null)
            {
                pt.Bed_No = Inpat.Bed_No.ToString();
                pt.Ward_Name = Convert.ToString(Inpat.Ward_Name);
                if (Inpat.Room_Name == null)
                {
                    pt.Room_Name = "";
                }
                else
                {
                    pt.Room_Name = Inpat.Room_Name.ToString();
                }
                
                pt.Admission_Date = Convert.ToDateTime(Inpat.Admission_Date);
                pt.Discharge_On = Inpat.Discharge_On.ToString();

            }
            return (new JavaScriptSerializer()).Serialize(Inpat);
        }


        [WebMethod]
        public static string LoadBills(int Patient_ID, string Bill_no)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            int MR_NO = DBClass.GetMRNOBy_PatientID_reg(Patient_ID);
            var billsList = (from b in db.Ar_Billings
                             join p in db.Reg_patients
                             on b.Patient_ID equals p.pat_id
                             where p.Patient_No == MR_NO
                             && b.Bill_ID == Convert.ToInt32(Bill_no)
                             orderby b.Bill_ID descending
                             select new
                             {
                                 MR_NO = p.Patient_No,
                                 Patient_Name = p.Full_Name,
                                 b.Bill_ID,
                                 b.Bill_No,
                                 b.Bill_Date,
                                 Amount = b.Net_Amount,
                                 PackageName = (from name in db.Ar_Billing_Details where name.Bill_ID == b.Bill_ID select name.Item_Name).Distinct().FirstOrDefault(),
                                 b.Received_Amount,
                                 b.Balance_Amount
                             }).ToList();


            return (new JavaScriptSerializer()).Serialize(billsList);
        }
        
        [WebMethod]
        public static string LoadAdvances(int Patient_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var AdvanceList = (from b in db.AR_Advances
                               join p in db.Reg_patients
                               on b.Patient_ID equals p.pat_id
                               where b.Patient_ID == Patient_ID
                               orderby b.Advance_ID descending
                               select new
                               {
                                   MR_NO = p.Patient_No,
                                   Patient_Name = p.Full_Name,
                                   b.Advance_ID,
                                   b.Advance_Date,
                                   Amount = b.Advance_Amount,
                                   b.Remarks
                               }).ToList();


            return (new JavaScriptSerializer()).Serialize(AdvanceList);
        }

        [WebMethod]
        public static string LoadReceipts(int BillID)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var receiptsList = (from r in db.Receipts
                                join b in db.Ar_Billings
                                on r.Bill_ID equals b.Bill_ID
                                where b.Bill_ID == BillID
                                && b.Balance_Amount > 0
                                orderby r.Receipt_ID descending
                                select new
                                {
                                    b.Bill_No,
                                    b.Balance_Amount,
                                    Receipt_ID = r.Receipt_ID,
                                    r.Receipt_No,
                                    r.Receipt_Date,
                                    Amount = r.Receipt_Amount,
                                    r.Remarks
                                }).ToList();
            if (receiptsList.Count > 0)
                return (new JavaScriptSerializer()).Serialize(receiptsList);
            else if (receiptsList.Count == 0)
            {
                var Balance_Amount = (from b in db.Ar_Billings where b.Bill_ID == BillID select b.Balance_Amount).FirstOrDefault().Value;
                return (new JavaScriptSerializer()).Serialize(Balance_Amount);
            }
            return (new JavaScriptSerializer()).Serialize(receiptsList);
        }
        public class TestDetail
        {
            public string Discharge_Test_Date { get; set; }
            public string Item_ID { get; set; }
            public string Discharge_Amount { get; set; }
            public string Transaction_Type { get; set; }
            public string Parent_Trans_ID { get; set; }
        }
        public class ServiceDetail
        {
            public string Discharge_Test_Date { get; set; }
            public string Item_ID { get; set; }
            public string Discharge_Amount { get; set; }

            public string Net_Amount { get; set; }
            public string Qty { get; set; }

            public string Transaction_Type { get; set; }
            public string Parent_Trans_ID { get; set; }
        }
        public class Service
        {
            public string Discharge_Date { get; set; }
            public string Receipt_ID { get; set; }
            public string Discharge_Amount { get; set; }
            public string Discount_Percentage { get; set; }
            public string Discount_Amount { get; set; }
            public string Net_Amount { get; set; }
            public string Discharge_Charges { get; set; }
            public string PatientID { get; set; }
            public int Discharge_ID { get; set; }
            public decimal Investigation_Limit { get; set; }
            public List<ServiceDetail> service_list { get; set; }
            public List<TestDetail> test_list { get; set; }
        }
        [WebMethod]
        public static string SaveServiceDetail(string servicelist)
        {
            string DischargeID = "";
            var ReceiptID = "";
            bool IsEdit = false;
            Discharge DischargeMaster = null;
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            JavaScriptSerializer oJS = new JavaScriptSerializer();
            var record = oJS.Deserialize<Service>(servicelist);
            string[] namesArray = record.Receipt_ID.Split(',');
            foreach (var ss in namesArray)
            {
                ReceiptID = ss;

            }
            List<string> namesList = new List<string>(namesArray.Length);
            var DiscahrgeReciept = (from t in db.Receipts
                                    where t.Receipt_ID == int.Parse(ReceiptID)
                                    select t).FirstOrDefault();
            if (DiscahrgeReciept != null)
            {
                DiscahrgeReciept.Discharge = true;
                DiscahrgeReciept.Discharge_Charges = Convert.ToDecimal(record.Discharge_Charges);
            }
            else
            {
                DiscahrgeReciept.Discharge_Charges = (decimal)0.00;
            }

            DischargeMaster = (from dschrg in db.Discharges where dschrg.Receipt_ID == Convert.ToInt32(ReceiptID) select dschrg).FirstOrDefault();

            if (DischargeMaster != null)
            {
                DischargeMaster.Update_By = AppConfig.UserID;
                DischargeMaster.Update_Time = DateTime.Now;
                IsEdit = true;
            }
            else
            {
                DischargeMaster = new Discharge();
                IsEdit = false;
            }

            DischargeMaster.Patient_ID = Convert.ToInt32(record.PatientID);
            if (record.Discharge_Amount == "")
                record.Discharge_Amount = "0.00";
            DischargeMaster.Discharge_Amount = Convert.ToDecimal(record.Discharge_Amount);
            if (record.Discount_Amount == "")
                record.Discount_Amount = "0.00";
            DischargeMaster.Discount_Amount = Convert.ToDecimal(record.Discount_Amount);
            if (record.Discount_Percentage == "")
                record.Discount_Percentage = "0.00";
            DischargeMaster.Discount_Percentage = Convert.ToDecimal(record.Discount_Percentage);
            DischargeMaster.Net_Amount = Convert.ToDecimal(record.Net_Amount);
            DischargeMaster.Receipt_ID = Convert.ToInt32(ReceiptID);
            DischargeMaster.Created_By = AppConfig.UserID;
            DischargeMaster.Creation_Time = DateTime.Now;
            DischargeMaster.Investigation_Limit = record.Investigation_Limit;

            if (!IsEdit)
                db.Discharges.InsertOnSubmit(DischargeMaster);

            db.SubmitChanges();
            var lstservisetDetails = db.Discharge_Details.Where(t => t.Discharge_ID == DischargeMaster.Discharge_ID).ToList();
            db.Discharge_Details.DeleteAllOnSubmit(lstservisetDetails);
            db.SubmitChanges();
            foreach (var test in record.service_list)
            {
                Discharge_Detail disDetail = new Discharge_Detail();
                disDetail.Discharge_ID = Convert.ToInt32(DischargeMaster.Discharge_ID);
                disDetail.Item_ID = test.Item_ID;
                disDetail.Transaction_Type = test.Transaction_Type;
                disDetail.Qty = Convert.ToInt32(test.Qty);
                disDetail.Item_NetAmount = Convert.ToDecimal(test.Net_Amount);

                disDetail.Item_Amount = Convert.ToDecimal(test.Discharge_Amount);
                db.Discharge_Details.InsertOnSubmit(disDetail);
                db.SubmitChanges();
            }
            foreach (var test in record.test_list)
            {
                Discharge_Detail disDetail = new Discharge_Detail();
                disDetail.Discharge_ID = Convert.ToInt32(DischargeMaster.Discharge_ID);
                disDetail.Item_ID = test.Item_ID;
                disDetail.Transaction_Type = test.Transaction_Type;
                disDetail.Parent_Trans_ID = Convert.ToInt32(test.Parent_Trans_ID);
                disDetail.Item_Amount = Convert.ToDecimal(test.Discharge_Amount);
                disDetail.Discharge_Test_Date = Convert.ToDateTime(test.Discharge_Test_Date);
                db.Discharge_Details.InsertOnSubmit(disDetail);

                Lab_Test_Detail investigation = db.Lab_Test_Details.Where(t => t.Lab_Test_Detail_ID == disDetail.Parent_Trans_ID).FirstOrDefault();
                if (investigation != null)
                {
                    investigation.Discharge = true;
                }
                db.SubmitChanges();
            }


            return "";
        }
        public class Result
        {

            public string Bill_ID;
            public string Bill_No;
            public string Bill_Date;
            public string Remarks;
            public string Total_Amount;
            public string Discount_Percentage;
            public string Discount_Amount;
            public string Net_Amount;
            public string Received_Amount;
            public string Balance_Amount;
            public string Creation_Date;
            public string Created_ByB;
            public string Voucher_ID;
            public string Advice;
            public string Follow_Up;
            public string Follow_Date;
            public string ProvisionalD;
            public string PrintedBy;
            public string Gender;
            public string ReceiptCharges;
            public string Full_Name;
            public string Birth_Date;
            public string NowDate;
            public string ContectNo;
            public string NIC;
            public string Blood_Group;
            public string Created_By;
            public string Token_No;
            public string Prisentation;
            public string RoomNo;
            public string ReceiptNo;
            public int follow;
            public string Pulse_Min;
            public string BP;
            public string Temp_C;
            public string Respiration_Min;
            public string Permanent_Address;
            public string MR_No;
            public string Printed_By;
            public string Patient_Type;
            public string Department;
            public string Age_years;
            public string Created_Time;
            public string Referring_Doctor;
            public string Province;
            public string Temporary_Address;

            public string Discount_AmountDischarge;
            public string Discount_PercentageDischarge;
            public string Net_AmountDischarge;
            public string Item_Amount;
            public string Item_ID;
            public string Investigation_Limit;
            public string Discharge_Charges;
            public string Tottal_Reciept;

        }
        [WebMethod]
        public static string PrintReceipt(int MRNo, string ReceiptNo)
        {

            string[] namesArray = ReceiptNo.Split(',');
            List<string> namesList = new List<string>(namesArray.Length);
            DataBaseDataContext db = new DataBaseDataContext();
            List<Result> list = new List<Result>();

            foreach (var ID in namesArray)
            {
                Result IST = new Result();

                var Data = (from tbl in db.Reg_patients
                            join rec in db.Receipts on tbl.pat_id equals rec.Patient_ID
                            where tbl.pat_id == rec.Patient_ID && rec.Receipt_ID == Convert.ToInt32(ID)
                            select new
                            {
                                tbl.Patient_No,
                                tbl.Full_Name,
                                tbl.Mobile1,
                                tbl.Created_time,
                                tbl.Gender,
                                tbl.NIC,
                                tbl.Age_years,
                                //Department = (db.GetDataValueName("Patient Main Category", tbl.Patient_Main_Category) == null ? "" : db.GetDataValueName("Patient Main Category", tbl.Patient_Main_Category)),
                                //Patient_Type = (db.GetDataValueName("Patient Type", tbl.Patient_Main_Category) == null ? "" : db.GetDataValueName("Patient Type", tbl.Patient_Main_Category)),
                                tbl.Permanent_Address,
                                //Temporary_Address = tbl.Temporary_Address == null ? "" : tbl.Temporary_Address,
                                tbl.city,
                                Province = tbl.Province == null ? "" : tbl.Province,
                                rec.Bill_ID,
                                rec.Receipt_No,
                                rec.Receipt_Amount,
                                Bill_No = ((from bill in db.Ar_Billings where bill.Bill_ID == rec.Bill_ID select bill.Bill_No)).FirstOrDefault(),
                                Total_Amount = (from bill in db.Ar_Billings join pat in db.In_Patients on bill.Patient_ID equals pat.Patient_ID where bill.Patient_ID == MRNo && pat.Discharge != true select bill).Sum(bill => bill.Total_Amount),
                                Tottal_Reciept = (from bill in db.Receipts join pat in db.In_Patients on bill.Patient_ID equals pat.Patient_ID where bill.Patient_ID == MRNo && pat.Discharge != true select bill).Sum(bill => bill.Receipt_Amount),
                            }

                    ).FirstOrDefault();

                IST.MR_No = Data.Patient_No.ToString();
                IST.Full_Name = Data.Full_Name;
                IST.Gender = Data.Gender.ToString();
                IST.ContectNo = Data.Mobile1.ToString();
                //IST.Department = Data.Department;
                //IST.Patient_Type = Data.Patient_Type;
                IST.NIC = Data.NIC;
                IST.Age_years = Data.Age_years;
                IST.Permanent_Address = Data.Permanent_Address.ToString();
                //IST.Temporary_Address = Data.Temporary_Address.ToString();
                IST.Province = Data.Province.ToString();
                IST.Created_Time = Convert.ToDateTime(Data.Created_time).ToString("MM-dd-yy hh:mm tt");
                IST.Bill_ID = Convert.ToInt32(Data.Bill_ID).ToString();
                IST.Bill_No = Data.Bill_No;
                IST.ReceiptNo = Data.Receipt_No.ToString();
                IST.Received_Amount = Data.Receipt_Amount.ToString();
                IST.Total_Amount = Data.Total_Amount.ToString();
                IST.Tottal_Reciept = Data.Tottal_Reciept.ToString();
                list.Add(IST);
            }
            return (new JavaScriptSerializer()).Serialize(list);
        }
        [WebMethod]
        public static Result PrintDischargeReceipt(int Bill_ID, int MRNo, int Receipt_ID)
        {
            Result recieptP = new Result();
            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                var Data = (from tbl in db.Reg_patients
                            join bill in db.Ar_Billings on tbl.pat_id equals bill.Patient_ID
                            join rec in db.Ar_Billing_Details on bill.Bill_ID equals rec.Bill_ID

                            where tbl.pat_id == MRNo && bill.Bill_ID == Bill_ID

                            select new
                            {
                                tbl.Patient_No,
                                tbl.Full_Name,
                                tbl.Mobile1,
                                tbl.Created_time,
                                tbl.Gender,
                                tbl.NIC,
                                tbl.Age_years,
                                //Department = (from d in db.DataValues join v in db.ValueSets on d.ValueSet_ID equals v.ValueSet_ID where v.ValueSet_Name == "Patient Main Category" && d.DataValue_Name == tbl.Patient_Main_Category select d.DataValue_Description).FirstOrDefault(),
                                //Patient_Type = (from d in db.DataValues join v in db.ValueSets on d.ValueSet_ID equals v.ValueSet_ID where v.ValueSet_Name == "Patient Type" && d.DataValue_Name == tbl.Patient_Type select d.DataValue_Description).FirstOrDefault(),
                                Printed_By = AppConfig.UserName,
                                tbl.Permanent_Address,
                                //tbl.Temporary_Address,
                                tbl.city,
                                tbl.Province,
                                bill.Bill_ID,
                                bill.Bill_No,
                                bill.Bill_Date,
                                bill.Remarks,
                                bill.Total_Amount,
                                bill.Discount_Percentage,
                                bill.Discount_Amount,
                                bill.Net_Amount,
                                bill.Received_Amount,
                                bill.Balance_Amount,
                                bill.Creation_Date,
                                bill.Created_By,
                                bill.Voucher_ID,

                            }

                    ).FirstOrDefault();
                if (Data != null)
                {
                    recieptP.MR_No = Data.Patient_No.ToString();
                    recieptP.Full_Name = Data.Full_Name;
                    recieptP.Gender = Data.Gender.ToString();
                    recieptP.ContectNo = Data.Mobile1.ToString();
                    //recieptP.Department = Data.Department;
                    //recieptP.Patient_Type = Data.Patient_Type;
                    recieptP.NIC = Data.NIC;
                    recieptP.Printed_By = Data.Printed_By;
                    recieptP.Age_years = Data.Age_years;
                    recieptP.Permanent_Address = Data.Permanent_Address.ToString();
                    //recieptP.Temporary_Address = Data.Temporary_Address.ToString();
                    recieptP.Province = Data.Province.ToString();
                    //recieptP.Created_Time = Convert.ToDateTime(Data.Created_Time).ToString("MM-dd-yy hh:mm tt");
                    recieptP.Bill_ID = Convert.ToInt32(Data.Bill_ID).ToString();
                    recieptP.Bill_No = Data.Bill_No;
                    recieptP.Remarks = Data.Remarks;
                    recieptP.Total_Amount = Convert.ToDecimal(Data.Total_Amount).ToString();
                    recieptP.Discount_Percentage = Convert.ToDecimal(Data.Discount_Percentage).ToString();
                    recieptP.Discount_Amount = Convert.ToDecimal(Data.Discount_Amount).ToString();
                    recieptP.Received_Amount = Convert.ToDecimal(Data.Received_Amount).ToString();
                    recieptP.Net_Amount = Convert.ToDecimal(Data.Net_Amount).ToString();
                    recieptP.Balance_Amount = Convert.ToDecimal(Data.Balance_Amount).ToString();
                    recieptP.Bill_Date = Convert.ToDateTime(Data.Bill_Date).ToString("MM-dd-yy hh:mm tt");
                    recieptP.Created_ByB = Data.Created_By.ToString();
                    recieptP.Voucher_ID = Data.Voucher_ID.ToString();

                }
            }

            return recieptP;

        }

        [WebMethod]
        public static string GetDischargeCharges(int Receipt_ID)
        {
            Result recieptsss = new Result();
            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {

                var allDepts = (from tbl in db.Discharges
                                where tbl.Receipt_ID == Receipt_ID
                                select new
                                {
                                    tbl.Discharge_Amount,
                                    tbl.Discount_Amount,
                                    tbl.Net_Amount

                                }
                ).ToList();
                return (new JavaScriptSerializer().Serialize(allDepts));


            }

            return "";

        }
        [WebMethod]
        public static string PrintBillingDetail(int BillID)
        {
            List<TestDetailsForOPDrpt> AlltestList = new List<TestDetailsForOPDrpt>();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var PatCase = (from billD in db.Ar_Billing_Details
                           where billD.Bill_ID == BillID
                           select new
                           {
                               billD.Item_ID,
                               billD.Item_Name,
                               billD.Item_Type,
                               billD.Amount,
                               billD.Discount_Percentage,
                               billD.Discount_Amount,
                               billD.Net_Amount,
                               billD.ParentTrans_Name,
                               Group_Category = (from t in db.Lab_Tests where t.Test_ID == billD.Item_ID select t.Group_Category).FirstOrDefault(),
                           }).ToList();
            foreach (var item in PatCase)
            {
                TestDetailsForOPDrpt test = new TestDetailsForOPDrpt();
                test.Item_ID = item.Item_ID.ToString();
                test.Item_Name = item.Item_Name;
                test.Item_Type = item.Item_Type.ToString();
                test.Group_Category = item.Group_Category;
                test.Amount = (decimal)item.Amount;
                test.ParentTrans_Name = item.ParentTrans_Name;
                test.Discount_Amount = (decimal)item.Discount_Amount;
                test.Net_Amount = (decimal)item.Net_Amount;
                AlltestList.Add(test);
            }

            List<TestDetailsForOPDrpt> AlltestListRefined = new List<TestDetailsForOPDrpt>();
            AlltestListRefined = AlltestList;
            var NoOfTestsCateWise = (from lbtsts in db.Lab_Tests
                                     where lbtsts.Group_Category != "" && lbtsts.Group_Category != null
                                     group lbtsts by lbtsts.Group_Category into g
                                     select new
                                     {
                                         CategoryID = g.Key,
                                         Category = db.GetDataValueName("Test Groups", g.Key),
                                         testsCount = g.Count(),
                                         MainDepartment = (from tbl in db.Lab_Tests
                                                           where tbl.Group_Category == g.Key
                                                           select new { DepartmentName = (db.GetDataValueName("Main Test Departments", tbl.Main_Department) == null ? "" : db.GetDataValueName("Main Test Departments", tbl.Main_Department)) }
                                                          ).FirstOrDefault().DepartmentName.ToString()
                                     }
                                  ).ToList();

            foreach (var item in NoOfTestsCateWise)
            {
                int CatewisetestsCount = PatCase.Where(t => t.Group_Category == item.CategoryID).Count();
                if (CatewisetestsCount == item.testsCount)
                {
                    AlltestListRefined.RemoveAll(t => t.Group_Category == item.CategoryID);
                    AlltestListRefined.Add(new TestDetailsForOPDrpt()
                    {
                        Item_Name = item.Category,
                        Item_Type = "Test",
                        Amount = (decimal)PatCase.Where(r => r.Group_Category == item.CategoryID).Sum(r => r.Amount),
                        Discount_Amount = (decimal)PatCase.Where(r => r.Group_Category == item.CategoryID).Sum(r => r.Discount_Amount),
                        Net_Amount = (decimal)PatCase.Where(r => r.Group_Category == item.CategoryID).Sum(r => r.Net_Amount)
                    });

                }
            }

            var NoOfPackges = (from pkg in db.Packages
                               select new
                               {
                                   pkg.Package_Name
                               }
                                ).ToList();

            foreach (var item in NoOfPackges)
            {
                int CatewisetestsCount = PatCase.Where(t => t.ParentTrans_Name == item.Package_Name).Count();
                if (CatewisetestsCount > 0)
                {
                    AlltestListRefined.RemoveAll(t => t.ParentTrans_Name == item.Package_Name);
                    AlltestListRefined.Add(new TestDetailsForOPDrpt()
                    {
                        Item_Name = item.Package_Name,
                        Item_Type = "Test",
                        Amount = (decimal)PatCase.Where(r => r.ParentTrans_Name == item.Package_Name).Sum(r => r.Amount),
                        Discount_Amount = (decimal)PatCase.Where(r => r.ParentTrans_Name == item.Package_Name).Sum(r => r.Discount_Amount),
                        Net_Amount = (decimal)PatCase.Where(r => r.ParentTrans_Name == item.Package_Name).Sum(r => r.Net_Amount)
                    });
                }
            }
            return ((new JavaScriptSerializer()).Serialize(AlltestListRefined));
        }
        public class TestDetailsForOPDrpt
        {
            public string Item_ID;
            public string Item_Name;
            public string Item_Type;
            public decimal Amount;
            public decimal Discount_Percentage;
            public decimal Discount_Amount;
            public decimal Net_Amount;
            public string ParentTrans_Name;
            public string Group_Category { get; set; }

        }

        [WebMethod]
        public static string PrintDischargeDetailrpt(int Receipt_ID, int Patient_ID)
        {
            List<TestDetailsForOPDrpt> AlltestList = new List<TestDetailsForOPDrpt>();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var PatCase = (from dis in db.Discharges
                           join disd in db.Discharge_Details
                           on dis.Discharge_ID equals disd.Discharge_ID
                           where dis.Receipt_ID == Receipt_ID && dis.Patient_ID == Patient_ID && disd.Transaction_Type == "Service"
                           select new
                           {
                               disd.Item_ID,
                               disd.Item_Amount,
                               disd.Transaction_Type,
                               Item_Name = db.GetDataValueName("Service Type", disd.Item_ID),
                               dis.Discount_Percentage,
                               disd.Item_NetAmount

                           }).ToList();
            return (new JavaScriptSerializer()).Serialize(PatCase);
        }

        [System.Web.Services.WebMethod]

        public static PatientDetail GetPatientDetails(string PatientID)
        {

            int Patien_No = DBClass.GetMRNOBy_PatientID_reg(Convert.ToInt32(PatientID));
            PatientDetail pt = new PatientDetail();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            Reg_patient pat = new Reg_patient();

            pat = (from tbl in db.Reg_patients
                   where tbl.Patient_No == Patien_No
                   orderby tbl.Created_time descending
                   select tbl).FirstOrDefault();
        
            if (pat != null)
            {
                pt.Name = pat.Full_Name;
                pt.Gender = pat.Gender;
                pt.Age = pat.Age_years.ToString();
                pt.Patient_No = pat.Patient_No.ToString();

                if (pat.Created_time.HasValue)
                    pt.Entry_Date = pat.Created_time.ToString();

                pt.Address = pat.Permanent_Address;
                pt.Mobile = pat.Mobile1;
                pt.Gender = db.GetDataValueName("Gender", pat.Gender);
                var Patientno = pat.Patient_No.ToString();


                return pt;
            }
            else
                return pt;
        }

        [WebMethod]
        public static decimal GetNetBalance(string TransType, int TransID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            decimal Balance_Amount = 0;
            int MRNO = 0;
            if (TransType == "Bill Balance")
            {
                Balance_Amount = (from bm in db.Ar_Billings
                                  join bd in db.Ar_Billing_Details
                                  on bm.Bill_ID equals bd.Bill_ID
                                  join pat in db.Reg_patients
                                  on bm.Patient_ID equals pat.pat_id
                                  where bm.Bill_ID == TransID
                                  select bm.Balance_Amount
                        ).Sum().Value;
            }
            else if (TransType == "Net Balance")
            {
                MRNO = DBClass.GetMRNOBy_PatientID(TransID);

                Balance_Amount = (from bm in db.Ar_Billings
                                  join bd in db.Ar_Billing_Details
                                  on bm.Bill_ID equals bd.Bill_ID
                                  join pat in db.Reg_patients
                                  on bm.Patient_ID equals pat.pat_id
                                  where pat.Patient_No == MRNO
                                  select bm.Balance_Amount
                        ).Sum().Value;
            }
            return Balance_Amount;
        }

        [WebMethod]
        public static string GetServices()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var data = from dv in db.DataValues
                       join vs in db.ValueSets
                       on dv.ValueSet_ID equals vs.ValueSet_ID
                       where vs.ValueSet_Name == "Service Type"
                       select new { dv.DataValue_Name, dv.DataValue_Description };
            return (new JavaScriptSerializer()).Serialize(data);
        }
        [WebMethod]
        public static decimal GetServiceDetails(int Bill_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            decimal Charges = 0;

            var BillDetails = (from m in db.Ar_Billings
                               join d in db.Ar_Billing_Details on m.Bill_ID equals d.Bill_ID
                               where m.Bill_ID == Bill_ID
                               select new
                               {
                                   m,
                                   d
                               }).ToList();

            var Pkg = (from pkg in db.Packages where pkg.Packages_ID == BillDetails[0].d.ParentTrans_ID select pkg).FirstOrDefault();

            int MRNo = DBClass.GetMRNOBy_RegID((int)BillDetails[0].m.Patient_ID);

            var data = (from pat in db.Reg_patients
                        join inPat in db.In_Patients
                        on pat.pat_id equals inPat.Patient_ID
                        where pat.Patient_No == MRNo
                        orderby inPat.Admission_Date descending
                        select inPat).FirstOrDefault();
            if (data != null)
            {

                TimeSpan hours = ((DateTime)data.Admission_Date - (DateTime)data.Discharge_On);

                Charges = ((decimal)Pkg.PerDay_Charges / 12) * (decimal)hours.TotalHours;
            }
            return Charges;

        }
        public class PatientDetail
        {
            public string Name;
            public string Gender;
            public string Age;
            public string Patient_Type;
            public string Mobile;
            public string Address;
            public string Entry_Date;
            public string department;
            public string Follow;
            public string Patient_Discount_Type;
            public string Patient_No;
        }

        public static void InsertVoucherLine(int TransNo, int AccountID, decimal DrAmount, decimal CrAmount, int MasterVoucherID, string Remarks, int Item_ID, string Item_Type, string Trns_Type, int Doctor_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            GL_Voucher_Account gvc = new GL_Voucher_Account();
            gvc.Voucher_ID = MasterVoucherID;
            gvc.Cheque_No = TransNo.ToString();
            gvc.Narration = Remarks;
            gvc.DR = DrAmount;
            gvc.CR = CrAmount;
            gvc.Account_ID = AccountID;
            gvc.Item_ID = Item_ID;
            gvc.Item_Type = Item_Type;
            gvc.Transaction_Type = Trns_Type;
            gvc.Doctor_ID = Doctor_ID;
            db.GL_Voucher_Accounts.InsertOnSubmit(gvc);
            db.SubmitChanges();
        }

        public class InvestigationDetails
        {
            public int ParentTrans_ID;
            public string Item_ID;
            public string Item_Name;
            public decimal Rate;
            public bool IsCategory;
            public DateTime Created_Time;
        }

        [WebMethod]
        public static string GetInvestigationDetails(int PatientID)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            int MRNO = DBClass.GetMRNOBy_RegID(PatientID);

            In_Patient InPatientDetails = (from inpat in db.In_Patients
                                           join pat in db.Reg_patients on inpat.Patient_ID equals pat.pat_id
                                           where pat.Patient_No == MRNO
                                           orderby inpat.In_Patient_ID descending
                                           select inpat).Take(1).FirstOrDefault();

            if (InPatientDetails != null)
            {
                var InvestigationDetails = (from lbm in db.Ar_Billings
                                            join lbd in db.Ar_Billing_Details
                                            on lbm.Bill_ID equals lbd.Bill_ID

                                            join inpat in db.In_Patients
                                            on lbm.Patient_ID equals inpat.In_Patient_ID
                                            join pat in db.Reg_patients
                                            on inpat.Patient_ID equals pat.pat_id
                                            where inpat.In_Patient_ID == InPatientDetails.In_Patient_ID 

                                            select new { lbd.Bill_Details_ID, Test_ID = lbd.Item_ID, Test_Name = lbd.Item_Name, lbd.Net_Amount, lbm.Creation_Date }
                                              ).ToList();


                return (new JavaScriptSerializer()).Serialize(InvestigationDetails);
            }
            return (new JavaScriptSerializer()).Serialize(new List<string>() { });
        }
        [WebMethod]
        public static string GetDischargeInvestigationDetails(int Receipt_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Serviceetails = (from dis in db.Discharges
                                 join disdetail in db.Discharge_Details on dis.Discharge_ID equals disdetail.Discharge_ID
                                 where dis.Receipt_ID == Receipt_ID && disdetail.Transaction_Type == "Test"
                                 select new
                                 {
                                     dis.Discharge_ID,
                                     dis.Discharge_Date,
                                     dis.Investigation_Limit,
                                     disdetail.Item_ID,
                                     Group_Name = db.GetDataValueName("Test Groups", disdetail.Item_ID),
                                     Item_Name = (from t in db.Lab_Tests where t.Test_ID == Convert.ToInt32(disdetail.Item_ID) select t.Test_Name).FirstOrDefault(),
                                     disdetail.Parent_Trans_ID,
                                     disdetail.Transaction_Type,
                                     disdetail.Item_Amount,
                                     disdetail.Discharge_Test_Date,
                                 }).ToList();

            return (new JavaScriptSerializer()).Serialize(Serviceetails);
        }
        [WebMethod]
        public static string GetDischargeServiceDetails(string Receipt_ID)
        {
            var ReceiptNo = "";
            DataBaseDataContext db = new DataBaseDataContext();
            string[] namesArray = Receipt_ID.Split(',');
            List<string> namesList = new List<string>(namesArray.Length);
            foreach (var id in namesArray)
            {
                ReceiptNo = (from td in db.Receipts where td.Receipt_No == Convert.ToInt32(id) select td.Receipt_ID).FirstOrDefault().ToString();

            }



            var Serviceetails = (from dis in db.Discharges
                                 join disdetail in db.Discharge_Details on dis.Discharge_ID equals disdetail.Discharge_ID
                                 where dis.Receipt_ID == Convert.ToInt32(ReceiptNo) && disdetail.Transaction_Type == "Service"
                                 select new
                                 {
                                     dis.Discharge_ID,
                                     dis.Discharge_Date,
                                     dis.Discount_Amount,
                                     dis.Discount_Percentage,
                                     dis.Net_Amount,
                                     dis.Discharge_Amount,
                                     disdetail.Item_ID,
                                     Item_Name = db.GetDataValueName("Service Type", disdetail.Item_ID),
                                     disdetail.Parent_Trans_ID,
                                     disdetail.Transaction_Type,
                                     disdetail.Item_Amount,
                                     disdetail.Item_NetAmount,
                                     disdetail.Qty
                                 }).ToList();
            return (new JavaScriptSerializer()).Serialize(Serviceetails);
        }

        [WebMethod]
        public static string GetInvestigationLimit(int Bill_ID)
        {

            DataBaseDataContext db = new DataBaseDataContext();

            var PackageDetails = (from bm in db.Ar_Billings
                                  join bd in db.Ar_Billing_Details
                                  on bm.Bill_ID equals bd.Bill_ID
                                  join pkgm in db.Packages
                                  on bd.ParentTrans_ID equals pkgm.Packages_ID
                                  join pkgd in db.Packages_Details
                                  on pkgm.Packages_ID equals pkgd.Packages_ID
                                  join itms in db.INV_Items
                                  on pkgd.Item_Code equals itms.Item_ID
                                  where bm.Bill_ID == Bill_ID && itms.Item_ID == 294 
                                  select new { pkgd.Amount }).FirstOrDefault();

            return (new JavaScriptSerializer()).Serialize(PackageDetails);
        }

        [WebMethod]
        public static string CheckPackages(int Patid)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var data = (from inpataient in db.In_Patients
                        join p in db.Reg_patients on inpataient.Patient_ID equals p.pat_id
                        from bill in db.Ar_Billings
                        join billd in db.Ar_Billing_Details
                        on bill.Bill_ID equals billd.Bill_ID
                        join pkg in db.Packages on billd.ParentTrans_ID equals pkg.Packages_ID
                        where inpataient.Patient_ID == Patid && inpataient.Patient_ID == bill.Patient_ID && inpataient.Discharge == false
                        select pkg.Package_Name).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(data);
        }

        [WebMethod]
        public static decimal GetTotalBillingsAmount()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            DateTime today = DateTime.Now.Date;
            decimal totalAmount = db.Ar_Billings
                .Where(b => b.Bill_Date.HasValue && b.Bill_Date.Value.Date == today)
                .Sum(b => (decimal?)b.Total_Amount) ?? 0;

            return totalAmount;
        }

        [WebMethod]
        public static decimal GetTotalDiscountAmount()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            DateTime today = DateTime.Now.Date;
            decimal totalAmount = db.Ar_Billings
                .Where(b => b.Bill_Date.HasValue && b.Bill_Date.Value.Date == today)
                .Sum(b => (decimal?)b.Discount_Amount) ?? 0;

            return totalAmount;
        }

        [WebMethod]
        public static decimal GetTotalNetAmount()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            DateTime today = DateTime.Now.Date;
            decimal totalAmount = db.Ar_Billings
                .Where(b => b.Bill_Date.HasValue && b.Bill_Date.Value.Date == today)
                .Sum(b => (decimal?)b.Received_Amount) ?? 0;

            return totalAmount;
        }

        [WebMethod]
        public static decimal GetTotalCashPaid()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            DateTime today = DateTime.Now.Date;
            decimal totalAmount = db.Receipts
                .Where(b => b.Receipt_Date.HasValue && b.Receipt_Date.Value.Date == today)
                .Sum(b => (decimal?)b.Receipt_Amount) ?? 0;

            return totalAmount;
        }

        [WebMethod]
        public static decimal GetTotalAdvance()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            DateTime today = DateTime.Now.Date;
            decimal totalAmount = db.AR_Advances
                .Where(b => b.Advance_Date.HasValue && b.Advance_Date.Value.Date == today)
                .Sum(b => (decimal?)b.Advance_Amount) ?? 0;

            return totalAmount;
        }

        [WebMethod]
        public static decimal GetTotalRefund()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            DateTime today = DateTime.Now.Date;
            decimal totalAmount = db.Refunds
                .Where(b => b.Refund_Date.HasValue && b.Refund_Date.Value.Date == today)
                .Sum(b => (decimal?)b.Refund_Amount) ?? 0;

            return totalAmount;
        }

        [WebMethod]
        public static decimal GetTotalActual()
        {
            DataBaseDataContext db = new DataBaseDataContext();

            DateTime today = DateTime.Now.Date;

            decimal totalReceived = db.Ar_Billings
                .Where(b => b.Bill_Date.HasValue && b.Bill_Date.Value.Date == today)
                .Sum(b => (decimal?)b.Received_Amount) ?? 0;

            decimal totalRefund = db.Ar_Billings
                .Where(b => b.Bill_Date.HasValue && b.Bill_Date.Value.Date == today)
                .Sum(b => (decimal?)b.Received_Amount) ?? 0;

            decimal actualAmount = totalReceived - totalRefund;

            return actualAmount;
        }

    }
}