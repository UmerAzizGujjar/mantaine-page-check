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
    public partial class MR_Receipts : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string billNo = Request.QueryString["Bill_No"];
                string billId = Request.QueryString["Bill_ID"];

                if (!string.IsNullOrEmpty(billNo))
                {
                    // Store in session or ViewState for JavaScript to access
                    ViewState["AutoLoadBillNo"] = billNo;
                    ViewState["AutoLoadBillId"] = billId;

                    // Register startup script to auto-load the bill
                    string script = $@"
                <script type='text/javascript'>
                    $(document).ready(function() {{
                        setTimeout(function() {{
                            var billNo = '{billNo}';
                            var billId = '{billId}';
                            if (billNo && billNo !== '') {{
                                // Auto-select the bill
                                if (typeof AutoLoadBill === 'function') {{
                                    AutoLoadBill(billNo, billId);
                                }}
                            }}
                        }}, 500);
                    }});
                </script>";
                    ClientScript.RegisterStartupScript(this.GetType(), "AutoLoadBill", script);
                }
            }
        }
        [WebMethod]
        public static string GetBillByNumber(string billNo, string billId)
        {
            try
            {
                using (var db = new DataBaseDataContext())
                {
                    // Find the bill by Bill_No
                    var bill = (from b in db.Ar_Billings
                                join p in db.Reg_patients on b.Patient_ID equals p.pat_id
                                where b.Bill_No == billNo
                                select new
                                {
                                    id = b.Bill_ID,
                                    name = b.Bill_No + " - " + p.Full_Name,
                                    type = p.pat_id,
                                    patientId = p.pat_id,
                                    patientName = p.Full_Name,
                                    mrNo = p.Patient_No,
                                    billId = b.Bill_ID
                                }).FirstOrDefault();

                    if (bill != null)
                    {
                        return new JavaScriptSerializer().Serialize(bill);
                    }

                    // If not found by Bill_No, try by Bill_ID
                    if (!string.IsNullOrEmpty(billId) && billId != "0")
                    {
                        int id = Convert.ToInt32(billId);
                        var billById = (from b in db.Ar_Billings
                                        join p in db.Reg_patients on b.Patient_ID equals p.pat_id
                                        where b.Bill_ID == id
                                        select new
                                        {
                                            id = b.Bill_ID,
                                            name = b.Bill_No + " - " + p.Full_Name,
                                            type = p.pat_id,
                                            patientId = p.pat_id,
                                            patientName = p.Full_Name,
                                            mrNo = p.Patient_No,
                                            billId = b.Bill_ID
                                        }).FirstOrDefault();

                        if (billById != null)
                        {
                            return new JavaScriptSerializer().Serialize(billById);
                        }
                    }

                    return "";
                }
            }
            catch (Exception ex)
            {
                return "";
            }
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
                pt.Age = pat.Age_years?.ToString() ?? ""; 
                pt.Patient_No = pat.Patient_No.ToString();

                if (pat.Created_time.HasValue)
                    pt.Entry_Date = pat.Created_time.ToString();

                pt.Address = pat.Permanent_Address;
                pt.Mobile = pat.Mobile1;
                pt.Gender = db.GetDataValueName("Gender", pat.Gender);

                var inpat = (from tbl in db.In_Patients
                             where tbl.Patient_ID == Convert.ToInt32(PatientID)
                             && (tbl.Discharge == null || tbl.Discharge == false)
                             orderby tbl.Created_Time descending
                             select tbl).FirstOrDefault();

                var patientOPD = (from tbl in db.Patients
                                  join opd in db.Out_Patients
                                  on tbl.Patient_ID equals opd.Patient_ID
                                  where tbl.Reg_PatId == int.Parse(PatientID)
                                  && (opd.Discharge == null || opd.Discharge == false)
                                  orderby tbl.Patient_ID descending
                                  select tbl).FirstOrDefault();

                if (inpat != null)
                {
                    pt.Patient_Type = db.GetDataValueName("Patient Type", inpat.Patient_Discount_Type);
                    pt.department = db.GetDataValueName("Patient Main Category", inpat.Department);
                }
                else if (patientOPD != null)
                {
                    pt.Patient_Type = db.GetDataValueName("Patient Type", patientOPD.Patient_Type);
                }

                var Patientno = pat.Patient_No.ToString();


                return pt;
            }
            else
                return pt;
        }

        [WebMethod]
        public static string GetBillEntriesByPatient(int PatientID)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var ipdIds = db.In_Patients
                .Where(ip => ip.Patient_ID == PatientID && ip.Discharge == false)
                .Select(ip => ip.In_Patient_ID)
                .ToList()
                .Select(id => (long)id)
                .ToList();

            var bills = (from b in db.Ar_Billings
                         where b.Patient_ID == PatientID
                         && b.In_Patient_ID != null
                         && ipdIds.Contains(b.In_Patient_ID.Value)
                         && (b.isCancel == null || b.isCancel == false)
                         orderby b.Bill_Date descending
                          select new
                          {
                              b.Bill_ID,
                              b.Bill_No,
                              b.Bill_Date,
                              b.In_Patient_ID,
                              b.Net_Amount,
                              b.Received_Amount,
                              b.Balance_Amount,
                              b.Total_Amount,
                              Description = b.Remarks ?? ""
                          }).ToList();

            return (new JavaScriptSerializer()).Serialize(bills);
        }

        [WebMethod]
        public static string PayDischargeBills(string billIds, int patientId, string remarks)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var ids = billIds.Split(',').Select(int.Parse).ToList();

                foreach (var billId in ids)
                {
                    var bill = db.Ar_Billings.FirstOrDefault(b => b.Bill_ID == billId);
                    if (bill == null || bill.Balance_Amount == null || bill.Balance_Amount == 0)
                        continue;

                    var bal = bill.Balance_Amount.Value;

                    bill.Received_Amount = (bill.Received_Amount ?? 0) + bal;
                    bill.Balance_Amount = 0;

                    Receipt rcpt = new Receipt();
                    rcpt.Receipt_No = DBClass.GetNewNumber("Receipt_No", "Receipts", "");
                    rcpt.Patient_ID = patientId;
                    rcpt.Receipt_Date = DateTime.Now;
                    rcpt.Receipt_Amount = bal;
                    rcpt.Remarks = remarks + ", Bill No:- " + bill.Bill_No;
                    rcpt.Posted = false;
                    rcpt.Creation_Date = DateTime.Now;
                    rcpt.Created_By = AppConfig.UserID;
                    rcpt.Bill_ID = billId;
                    rcpt.Discharge = true;
                    rcpt.Discharge_Charges = 0;
                    db.Receipts.InsertOnSubmit(rcpt);
                    db.SubmitChanges();
                }
            }
            return "ok";
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
        public static string GetAutoFillReceiptSetting()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var setting = (from sp in db.sys_Parms
                           where sp.Name == "AutoFillReceiptAmount"
                           select sp.Code).FirstOrDefault();

            return setting ?? "0";
        }

    }
}