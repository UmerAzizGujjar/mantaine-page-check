using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using static Telerik.Web.UI.ComboBox.ComboBoxStyles;

namespace PMS.Modules.StudentAffair
{
    public partial class StudentReceipt : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static string ApproveReceipt(string RecptID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.spApproveStudentReceipt(Convert.ToInt32(RecptID));
            return (new JavaScriptSerializer()).Serialize(Details);
        }

        [WebMethod]
        public static string GetStud_RollNos()

        {
            DataBaseDataContext db = new DataBaseDataContext();
            var query = (from a in db.Reg_Students
                         select new
                         {
                             a.Roll_No,
                             a.Student_Id,
                         }).ToList();
            string data = string.Empty;
            return (new JavaScriptSerializer()).Serialize(query);
        }

        [WebMethod]
        public static string UnApproveReceipt(string RecptID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.spUnApproveStudentReceipt(Convert.ToInt32(RecptID));
            return (new JavaScriptSerializer()).Serialize(Details);
        }


        [WebMethod]
        public static string LoadStudentChildDataEditMode(int RecptID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.sp_StudentReceiptDetail(RecptID);
            return (new JavaScriptSerializer()).Serialize(Details);
        }


        [WebMethod]
        public static string LoadHeaderData(string RecptID)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var decription = (from a in db.Student_Receipts
                              join s in db.Reg_Students on a.Student_ID equals s.Student_Id
                              join f in db.Student_Fees on s.Student_Id equals Convert.ToInt32(f.Roll_No)
                              where a.Student_Receipt_ID == Convert.ToInt32(RecptID)
                              select new
                              {
                                  s.Full_Name,
                                  s.Roll_No,
                                  s.Father_Name,
                                  s.Student_Contact_No,
                                  Program = db.GetDataValueName("Admission_Category", s.Program),
                                  //s.Admission_Category,
                                  s.Sesion,
                                  f.Student_Class,
                                  StuClass_Text = db.GetDataValueName("Student Class", s.Class),
                                  a.Student_Receipt_ID,
                                  a.Class,
                                  a.Student_Receipt_No,
                                  a.Student_ID,
                                  a.Student_Receipt_Date,
                                  a.Remarks,
                                  a.Account_ID,
                                  Accountid_text = (from acc in db.GL_Accounts where acc.Account_ID == Convert.ToInt32(a.Account_ID) select acc.Account_Name).FirstOrDefault(),
                                  a.Total_Payable,
                                  a.Disc_Perc,
                                  a.Disc_Amount,
                                  a.Net_Payable,
                                  a.Amount_Received,
                                  a.Balance,
                                  a.Status,
                                  a.Doc_No


                              }).FirstOrDefault();


            return (new JavaScriptSerializer()).Serialize(decription);
        }




        [WebMethod]
        public static int SaveStudentReceipt(string btnSave, string AllItemDetail)
        {
            string StudentReceiptID = "";
            Student_Receipt stu = new Student_Receipt();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            JavaScriptSerializer oJS = new JavaScriptSerializer();
            var record = oJS.Deserialize<MasterStudentReceipt>(AllItemDetail);
            //var lstItem = (from t in db.Student_Receipts
            //               where t.Student_Receipt_No == int.Parse(record.Stu_recptNo)
            //               select t).FirstOrDefault();
            if (btnSave == "Update")
            {
                var lstItem = (from t in db.Student_Receipts
                               where t.Student_Receipt_No == int.Parse(record.Stu_recptNo)
                               select t).FirstOrDefault();


                lstItem.Student_Receipt_No = Convert.ToInt32(record.Stu_recptNo);
                lstItem.Student_ID = Convert.ToInt32(record.studentid);
                lstItem.Student_Receipt_Date = Convert.ToDateTime(record.txtReceiptDate);
                lstItem.Remarks = record.txtRemarks;
                lstItem.Updated_By = AppConfig.UserID;
                lstItem.Update_Time = DateTime.Now;
                lstItem.Account_ID = Convert.ToInt32(record.ddl_bankCash);
                lstItem.Status = record.txtStatus;
                lstItem.Doc_No = record.txt_DocNo;
                lstItem.Class = record.Class;


                if (record.txtTotalPayable != "")
                {


                    lstItem.Total_Payable = Convert.ToDecimal(record.txtTotalPayable);
                }

                if (record.txtDisPer != "")
                {

                    lstItem.Disc_Perc = Convert.ToDecimal(record.txtDisPer);
                }

                if (record.txtDisAmt != "")
                {
                    lstItem.Disc_Amount = Convert.ToDecimal(record.txtDisAmt);
                }

                if (record.txtNetPayable != "")
                {

                    lstItem.Net_Payable = Convert.ToDecimal(record.txtNetPayable);
                }

                if (record.txtAmountReceived != "")
                {

                    lstItem.Amount_Received = Convert.ToDecimal(record.txtAmountReceived);
                }

                if (record.txtBalances != "")
                {
                    lstItem.Balance = Convert.ToDecimal(record.txtBalances);
                }


                db.SubmitChanges();
                StudentReceiptID = lstItem.Student_Receipt_ID.ToString();

            }
            else
            {

                var New_RecptNo = DBClass.GetNewNumber("Student_Receipt_No", "Student_Receipt", "");

                stu.Student_Receipt_No = New_RecptNo;
                stu.Student_ID = Convert.ToInt32(record.studentid);
                stu.Student_Receipt_Date = Convert.ToDateTime(record.txtReceiptDate);
                stu.Remarks = record.txtRemarks;
                stu.Created_By = AppConfig.UserID;
                stu.Creation_Time = DateTime.Now;
                stu.Account_ID = Convert.ToInt32(record.ddl_bankCash);
                stu.Status = record.txtStatus;
                stu.Doc_No = record.txt_DocNo;
                stu.Class = record.Class;
                //stu.isCancel = false;


                if (record.txtTotalPayable != "")
                {


                    stu.Total_Payable = Convert.ToDecimal(record.txtTotalPayable);
                }

                if (record.txtDisPer != "")
                {

                    stu.Disc_Perc = Convert.ToDecimal(record.txtDisPer);
                }

                if (record.txtDisAmt != "")
                {
                    stu.Disc_Amount = Convert.ToDecimal(record.txtDisAmt);
                }

                if (record.txtNetPayable != "")
                {

                    stu.Net_Payable = Convert.ToDecimal(record.txtNetPayable);
                }

                if (record.txtAmountReceived != "")
                {

                    stu.Amount_Received = Convert.ToDecimal(record.txtAmountReceived);
                }

                if (record.txtBalances != "")
                {
                    stu.Balance = Convert.ToDecimal(record.txtBalances);
                }


                db.Student_Receipts.InsertOnSubmit(stu);
                db.SubmitChanges();
                StudentReceiptID = stu.Student_Receipt_ID.ToString();

            }

            ///**********Deleting Previous details**************/

            if (btnSave == "Update")
            {
                List<Student_Receipt_Detail> lstStudentDetails = db.Student_Receipt_Details.Where(t => t.Student_Receipt_ID == int.Parse(StudentReceiptID)).ToList();
                db.Student_Receipt_Details.DeleteAllOnSubmit(lstStudentDetails);
                db.SubmitChanges();
            }

            foreach (var a in record.ItemList)
            {
                Student_Receipt_Detail ltd = new Student_Receipt_Detail();

                ltd.Student_Receipt_ID = Convert.ToInt32(StudentReceiptID);
                ltd.Fee_Type = a.feetypeid;
                ltd.Account_ID = Convert.ToInt32(a.txt_AccountID);

                if (a.txtamount != "")
                {


                    ltd.Amount = Convert.ToDecimal(a.txtamount);
                }

                else
                {


                    ltd.Amount = 0;
                }


                if (a.txtdiscamount != "")
                {

                    ltd.Disc_Amount = Convert.ToDecimal(a.txtdiscamount);
                }


                else
                {

                    ltd.Disc_Amount = 0;
                }



                if (a.txtnetamount != "")
                {

                    ltd.Net_Amount = Convert.ToDecimal(a.txtnetamount);
                }


                else
                {

                    ltd.Net_Amount = 0;
                }

                if (a.txtrecamount != "")
                {


                    ltd.Rec_Amount = Convert.ToDecimal(a.txtrecamount);
                }


                else
                {


                    ltd.Rec_Amount = 0;
                }

                if (a.txtbal_amount != "")
                {

                    ltd.Balance_Amount = Convert.ToDecimal(a.txtbal_amount);
                }


                else
                {

                    ltd.Balance_Amount = 0;
                }


                if (a.txtfeeno != "")
                {

                    ltd.Fee_No = Convert.ToInt32(a.txtfeeno);
                }


                else
                {

                    ltd.Fee_No = 0;
                }


                if (a.stu_fee_childID != "")
                {

                    ltd.Student_Fee_Detail_ID = Convert.ToInt32(a.stu_fee_childID);
                }



                db.Student_Receipt_Details.InsertOnSubmit(ltd);
                db.SubmitChanges();

            }


            return int.Parse(StudentReceiptID);
        }


        [WebMethod]
        public static string LoadStudentChilds(int StudentID,int ClassID) 
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.sp_StudentDetailonReceipt(StudentID, ClassID).ToList();
            return (new JavaScriptSerializer()).Serialize(Details);
        }

        [WebMethod]
        public static string GetStudentClasses(int StudentID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var studentClasses = (from sf in db.Student_Fees
                                  join stu in db.Reg_Students on sf.Roll_No equals stu.Student_Id.ToString() 
                                  where stu.Student_Id == StudentID
                                  select new
                                  {
                                      ClassID = sf.Student_Class,
                                      ClassName = db.GetDataValueName("Student Class", sf.Student_Class)
                                  }).Distinct().ToList();

            return (new JavaScriptSerializer()).Serialize(studentClasses);
        }


        [WebMethod]
        public static string GetBank()
        {
            string result = string.Empty;
            DataBaseDataContext db = new DataBaseDataContext();
            var itemsList = (from i in db.GL_Accounts where i.Levels == 4 && (i.Bank == true || i.Cash == true) select new { i.Account_ID, name = i.Account_Code.ToString() + '-' + i.Account_Name }).ToList();
            if (itemsList != null)
            {
                result = (new JavaScriptSerializer()).Serialize(itemsList);
            }
            return result;


        }

        [WebMethod]
        public static string FillChallanNo(string stu_ID)
        {
            string result = string.Empty;
            DataBaseDataContext db = new DataBaseDataContext();
            //var itemsList = DBClass.getField("select Seq_Challan_No from Challan_Amounts where Student_ID ="+ stu_ID);
            var itemsList = (from a in db.Challan_Amounts
                             where a.Student_ID == Convert.ToInt32(stu_ID)
                             select new
                             {
                                 a.Seq_Challan_No

                             }).ToList();

            if (itemsList != null)
            {
                result = (new JavaScriptSerializer()).Serialize(itemsList);
            }
            return result;

        }



        [WebMethod]
        public static string GetStudentDetails(string StudentID)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var decription = (from a in db.Reg_Students
                              join v in db.Student_Fees
                              on a.Student_Id equals Convert.ToInt32(v.Roll_No)
                              where a.Student_Id == Convert.ToInt32(StudentID)
                              select new
                              {

                                  a.Student_Id,
                                  a.Full_Name,
                                  a.Father_Name,
                                  a.Student_Contact_No,
                                  v.Student_Class,
                                  a.Sesion,
                                  Program = db.GetDataValueName("Admission Category", a.Program),
                                  StuClass = db.GetDataValueName("Student Class", v.Student_Class),
                                  a.Account_id,
                                  Accountid_text = (from acc in db.GL_Accounts where acc.Account_ID == Convert.ToInt32(a.Account_id) select acc.Account_Name).FirstOrDefault(),



                              }).FirstOrDefault();

            return (new JavaScriptSerializer()).Serialize(decription);
        }

        public class MasterStudentReceipt
        {
            public string Stu_recptNo { get; set; }
            public string studentid { get; set; }
            public string txtReceiptDate { get; set; }
            public string txtRemarks { get; set; }
            public string txtStatus { get; set; }
            public string ddl_bankCash { get; set; }
            public string txtTotalPayable { get; set; }
            public string txtDisPer { get; set; }
            public string txtDisAmt { get; set; }
            public string txtNetPayable { get; set; }
            public string txtAmountReceived { get; set; }
            public string txtBalances { get; set; }
            public string txt_DocNo { get; set; }
            public string Class { get; set; }
            public List<StudentReceiptDetailList> ItemList { get; set; }
        }
        public class StudentReceiptDetailList
        {
            public string txtamount { get; set; }
            public string txtdiscamount { get; set; }
            public string txtnetamount { get; set; }
            public string txtrecamount { get; set; }
            public string txtbal_amount { get; set; }
            public string feetypeid { get; set; }
            public string txt_AccountID { get; set; }
            public string txtfeeno { get; set; }
            public string stu_fee_childID { get; set; }




        }

    }
}