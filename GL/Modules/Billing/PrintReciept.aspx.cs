using CrystalDecisions.CrystalReports.Engine;
using CrystalDecisions.Shared;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class WebForm10 : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
 
        }

        [WebMethod]
        public static ResultP PrintPatientReceipt(int PatientID)
        {
            ResultP recieptP = new ResultP();
            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {

                var Data = (from tbl in db.Patients


                            where tbl.Patient_ID == PatientID
                            select new
                            {
                                tbl.Patient_No,
                                tbl.Full_Name,
                                tbl.Father_Name,
                                tbl.NIC,
                                tbl.Gender,
                                tbl.Mobile1,
                                //Department = (from d in db.DataValues join v in db.ValueSets on d.ValueSet_ID equals v.ValueSet_ID where v.ValueSet_Name == "Patient Main Category" && d.DataValue_Name == tbl.Patient_Main_Category select d.DataValue_Description).FirstOrDefault(),
                                Department = db.GetDataValueName("Patient Main Category", tbl.Patient_Main_Category),
                                Patient_Type = (from d in db.DataValues join v in db.ValueSets on d.ValueSet_ID equals v.ValueSet_ID where v.ValueSet_Name == "Patient Type" && d.DataValue_Name == tbl.Patient_Type select d.DataValue_Description).FirstOrDefault(),
                                Marital_Status = (from d in db.DataValues join v in db.ValueSets on d.ValueSet_ID equals v.ValueSet_ID where v.ValueSet_Name == "Marital Status" && d.DataValue_Name == tbl.Marital_Status select d.DataValue_Description).FirstOrDefault(),
                                tbl.Age_years,

                                tbl.Permanent_Address,
                                Referring_Doctor = (from i in db.In_Patients where i.Patient_ID == tbl.Patient_ID select i.Referring_Doctor).FirstOrDefault(),
                                ptientNO = (from i in db.Patients where i.Patient_ID == tbl.Patient_ID select i.Patient_No).FirstOrDefault(),

                                //Created_Time = (tbl.Updated_Time == null ? tbl.Created_Time : tbl.Updated_Time),
                                tbl.Created_Time,
                                tbl.Updated_Time,

                                Room_No = (from d in db.DataValues join v in db.ValueSets on d.ValueSet_ID equals v.ValueSet_ID where v.ValueSet_Name == "Patient Main Category" && d.DataValue_Name == tbl.Patient_Main_Category select d.Segment2).FirstOrDefault(), /*Have to Test*/
                                Receipt_No = tbl.Patient_No,
                                Mode_Of_Presentation = (from d in db.DataValues join v in db.ValueSets on d.ValueSet_ID equals v.ValueSet_ID where v.ValueSet_Name == "Mode Of Registration" && d.DataValue_Name == tbl.Mode_Of_Registration select d.DataValue_Description).FirstOrDefault(),
                                Printed_By = AppConfig.UserName,
                                Pulse_Min = (from i in db.Out_Patients where i.Patient_ID == tbl.Patient_ID select i.pulse_Min).FirstOrDefault(),
                                Respiration_Min = (from i in db.Out_Patients where i.Patient_ID == tbl.Patient_ID select i.Respiration_Min).FirstOrDefault(),
                                Temp_C = (from i in db.Out_Patients where i.Patient_ID == tbl.Patient_ID select i.Temp_C).FirstOrDefault(),
                                BP = (from i in db.Out_Patients where i.Patient_ID == tbl.Patient_ID select i.BP_mm_Hg).FirstOrDefault(),
                                ReceiptCharges = tbl.Receipt_Amount,
                                tbl.Doctor_Amount,
                                Doctor_Name = (from i in db.HR_Employees where i.Emp_ID == Convert.ToInt32(tbl.Doctor_ID) select i.Emp_Name).FirstOrDefault(),
                                TokenNo = (from t in db.Patients
                                           where t.Patient_Main_Category == tbl.Patient_Main_Category
                                           && t.Patient_No < Convert.ToInt32(tbl.Patient_No)
                                           && Convert.ToDateTime(t.Created_Time).Year == DateTime.Now.Date.Year
                                           && Convert.ToDateTime(t.Created_Time).Month == DateTime.Now.Date.Month
                                           && Convert.ToDateTime(t.Created_Time).Day == DateTime.Now.Date.Day
                                           select t).Count() + 1
                            }

                    ).FirstOrDefault();
                recieptP.MR_No = Data.Patient_No.ToString();
                recieptP.Full_Name = Data.Full_Name;
                recieptP.FatherName = Data.Father_Name;
                recieptP.Marital_Status = Data.Marital_Status;
                recieptP.NIC = Data.NIC.ToString();
                recieptP.Gender = Data.Gender.ToString();
                recieptP.ContectNo = Data.Mobile1.ToString();
                recieptP.Department = Data.Department;
                recieptP.Patient_Type = Data.Patient_Type;
                recieptP.Age_years = Data.Age_years;
                recieptP.Permanent_Address = Data.Permanent_Address.ToString();
                recieptP.Referring_Doctor = Data.Referring_Doctor;
                if (Data.Updated_Time != null)
                {
                    recieptP.Created_Time = Convert.ToDateTime(Data.Updated_Time).ToString("MM-dd-yy hh:mm tt");
                }
                else
                    recieptP.Created_Time = Convert.ToDateTime(Data.Created_Time).ToString("MM-dd-yy hh:mm tt");
                // recieptP.Created_Time = Convert.ToDateTime(Data.Created_Time).ToString("MM-dd-yy hh:mm tt");
                recieptP.TokenNo = Data.TokenNo.ToString();
                recieptP.RoomNo = Data.Room_No;
                recieptP.ReceiptCharges = Data.ReceiptCharges.ToString();
                recieptP.Doctor_Amount = Data.Doctor_Amount.ToString();
                recieptP.PrintedBy = Data.Printed_By;
                recieptP.Doctor_Name = Data.Doctor_Name;
                recieptP.Prisentation = Data.Mode_Of_Presentation;
                recieptP.Pulse_Min = Data.Pulse_Min;
                recieptP.Respiration_Min = Data.Respiration_Min;
                recieptP.Temp_C = Data.Temp_C;
                recieptP.BP = Data.BP;
                var count = (db.Patients.Where(v => v.Patient_No == Convert.ToInt32(Data.ptientNO)).ToList());
                var Follow = count.Count;
                recieptP.follow = Follow;
            }
            return recieptP;

        }

        public struct ResultP
        {
            public string PrintedBy;
            public string Gender;
            public string ReceiptCharges;
            public string Full_Name;
            public string FatherName;
            public string Marital_Status;
            public string Birth_Date;
            public string NowDate;
            public string ContectNo;
            public string NIC;
            public string Blood_Group;
            public string Created_By;
            public string TokenNo;
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
            public string Doctor_Amount;
            public string Doctor_Name;
        }

        [WebMethod]
        public static Result PrintBillingReceipt(int ID, int PatID)
        {

            Result recieptP = new Result();
            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {

                var Data = (from tbl in db.Patients
                            join bill in db.Ar_Billings on tbl.Patient_ID equals bill.Patient_ID
                            where tbl.Patient_ID == PatID && bill.Bill_ID == ID

                            select new
                            {
                                tbl.Patient_No,
                                tbl.Full_Name,
                                tbl.Mobile1,
                                tbl.Created_Time,
                                tbl.Gender,
                                tbl.NIC,
                                tbl.Age_years,
                                Department = (from d in db.DataValues join v in db.ValueSets on d.ValueSet_ID equals v.ValueSet_ID where v.ValueSet_Name == "Patient Main Category" && d.DataValue_Name == tbl.Patient_Main_Category select d.DataValue_Description).FirstOrDefault(),
                                Patient_Type = (from d in db.DataValues join v in db.ValueSets on d.ValueSet_ID equals v.ValueSet_ID where v.ValueSet_Name == "Patient Type" && d.DataValue_Name == tbl.Patient_Type select d.DataValue_Description).FirstOrDefault(),
                                Printed_By = AppConfig.UserName,
                                tbl.Permanent_Address,
                                tbl.Temporary_Address,
                                tbl.City,
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
                                Charge_Policy = db.GetDataValueName("Charge Policy", bill.Charge_Policy),
                                Patient_Discount_Type = (from tbl in db.In_Patients
                                                         where tbl.Patient_ID == PatID
                                                         orderby tbl.Created_Time descending
                                                         select db.GetDataValueName("Patient Type", tbl.Patient_Discount_Type)).FirstOrDefault(),

                            }
                    ).FirstOrDefault();

                var Type = (from tbl in db.In_Patients
                            where tbl.Patient_ID == PatID
                            && tbl.Discharge != true
                            orderby tbl.Created_Time descending
                            select new
                            {
                                Ward_Name = (from wd in db.Ward_Definitions where wd.Ward_ID == tbl.Ward_ID select wd.Ward_No).FirstOrDefault(),
                                Bed_No = tbl.Bed_No.ToString(),
                                Room_Name = (from rm in db.Rooms where rm.Room_ID == tbl.Room_ID select rm.Name).FirstOrDefault(),
                                Room_No = Convert.ToString((from rm in db.Rooms where rm.Room_ID == tbl.Room_ID select rm.Room_No).FirstOrDefault()),
                            }
                            ).FirstOrDefault();
                

                if (Data != null)
                {
                    recieptP.MR_No = Data.Patient_No.ToString();
                    recieptP.Full_Name = Data.Full_Name;
                    recieptP.Gender = Data.Gender.ToString();
                    recieptP.ContectNo = Data.Mobile1.ToString();
                    recieptP.Department = Data.Department;
                    recieptP.Patient_Type = Data.Patient_Type;
                    recieptP.NIC = Data.NIC;
                    recieptP.Printed_By = Data.Printed_By;
                    recieptP.Age_years = Data.Age_years;
                    recieptP.Permanent_Address = Data.Permanent_Address.ToString();
                    recieptP.Temporary_Address = Data.Temporary_Address.ToString();
                    recieptP.Province = Data.Province.ToString();
                    recieptP.Created_Time = Convert.ToDateTime(Data.Created_Time).ToString("MM-dd-yy hh:mm tt");
                    recieptP.Bill_ID = Convert.ToInt32(Data.Bill_ID).ToString();
                    recieptP.Bill_No = Data.Bill_No;
                    recieptP.Remarks = Data.Remarks;
                    recieptP.Total_Amount = Convert.ToDecimal(Data.Total_Amount).ToString();
                    recieptP.Discount_Percentage = Convert.ToDecimal(Data.Discount_Percentage).ToString();
                    recieptP.Discount_Amount = Convert.ToDecimal(Data.Discount_Amount).ToString();
                    recieptP.Received_Amount = Convert.ToDecimal(Data.Received_Amount).ToString();
                    recieptP.Net_Amount = Convert.ToDecimal(Data.Net_Amount).ToString();
                    recieptP.Balance_Amount = Convert.ToDecimal(Data.Balance_Amount).ToString();
                    recieptP.Bill_Date = Convert.ToDateTime(Data.Creation_Date).ToString("MM-dd-yy hh:mm tt");
                    recieptP.Created_ByB = Data.Created_By.ToString();
                    recieptP.Voucher_ID = Data.Voucher_ID.ToString();
                    recieptP.ChargePolicy = Data.Charge_Policy.ToString();
                    if(Data.Patient_Discount_Type != null)
                    {
                        recieptP.InPatientCat = Data.Patient_Discount_Type.ToString();
                    }
                    

                    if (Type != null)
                    {
                        if (Type.Ward_Name != null)
                        {
                            recieptP.Ward_Name = (Type.Ward_Name + ',' + Type.Bed_No).ToString();
                        }
                        else
                        {
                            recieptP.Ward_Name = "";
                        }

                        if (Type.Room_Name != null)
                        {
                            recieptP.Room_Name = (Type.Room_Name + ',' + Type.Room_No).ToString();
                        }
                        else
                        {
                            recieptP.Room_Name = "";
                        }
                    }
                   

                }
            }

            return recieptP;
        }

        [WebMethod]
        public static string PrintBillingDetail(int Bill_ID)
        {
            List<TestDetailsForOPDrpt> AlltestList = new List<TestDetailsForOPDrpt>();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var PatCase = (from billD in db.Ar_Billing_Details
                           //join t in db.Lab_Tests
                           //on billD.Item_ID equals t.Test_ID
                           where billD.Bill_ID == Bill_ID
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
                               Lab_test = (from t in db.Lab_Tests where t.Test_ID == billD.Item_ID select t.Main_Department).FirstOrDefault(),
                               Group_Category = (from t in db.Lab_Tests where t.Test_ID == billD.Item_ID select t.Group_Category).FirstOrDefault(),
                               Report_Timing = (from t in db.Lab_Tests where t.Test_ID == billD.Item_ID select t.Reporting_Time).FirstOrDefault(),
                           }).ToList();
            foreach (var item in PatCase)
            {
                TestDetailsForOPDrpt test = new TestDetailsForOPDrpt();
                test.Item_ID = item.Item_ID.ToString();
                test.Item_Name = item.Item_Name;
                test.Item_Type = item.Item_Type.ToString();
                test.ParentTrans_Name = item.ParentTrans_Name;
                test.Group_Category = item.Group_Category;
                test.MainDepartment = item.Lab_test;
                if (item.Report_Timing != null)
                {
                    test.Report_Timing = (decimal)item.Report_Timing;
                }
                else
                {
                    test.Report_Timing = 0;
                }
                
                test.Amount = (decimal)item.Amount;
                //test.Amount = Convert.ToDecimal(item.Amount);
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
            public string ParentTrans_Name;
            public decimal Amount;
            public decimal Discount_Percentage;
            public decimal Discount_Amount;
            public decimal Net_Amount;
            public string Group_Category { get; set; }
            public decimal Report_Timing { get; set; }
            public string MainDepartment { get; set; }
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
            public string Ward_Name;
            public string Room_Name;
            public string ChargePolicy;
            public string InPatientCat;
        }

    }
}