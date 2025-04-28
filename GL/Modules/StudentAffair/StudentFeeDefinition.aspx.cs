using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.StudentAffair
{
    public partial class StudentFeeDefinition : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        private class ddlListItems
        {
            public string DataValueName;
            public string DataValueDescription;
            public string Segment;
            public string Type;
        }



        [WebMethod]
        public static string loadAccountList()
        {
            string result = string.Empty;
            DataBaseDataContext db = new DataBaseDataContext();
            var itemsList = (from i in db.GL_Accounts where i.Levels == 4 select new { i.Account_ID, name = i.Account_Code.ToString() + '-' + i.Account_Name }).ToList();
            if (itemsList != null)
            {
                result = (new JavaScriptSerializer()).Serialize(itemsList);
            }
            return result;
        }


        [WebMethod]
        public static string loadfeedetails(string DataName)

        {
            DataBaseDataContext db = new DataBaseDataContext();
            List<ddlListItems> listItems = new List<ddlListItems>();
            string data = string.Empty;
            listItems = (from p in db.DataValues
                         join v in db.ValueSets on p.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Description == "Fee Type" && p.DataValue_Name == DataName
                         select new ddlListItems
                         {
                             Segment = p.Segment2,
                         }).ToList();

            return (new JavaScriptSerializer()).Serialize(listItems);
        }






        [WebMethod]
        public static string loadstudentinfoss(string ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var decription = (from a in db.Reg_Students
                              where a.Student_Id == Convert.ToInt32(ID)
                              select new
                              {
                                  a.Full_Name,
                                  a.Father_Name,
                                  a.Account_id,
                                  session = a.Sesion /*db.GetDataValueName("Session", a.s)*/



                              }
                              ).FirstOrDefault();


            return (new JavaScriptSerializer()).Serialize(decription);
        }
        [WebMethod]
        public static string GetStudentRollNos()

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
        public static string GetFeeTypes()

        {
            DataBaseDataContext db = new DataBaseDataContext();
            List<ddlListItems> listItems = new List<ddlListItems>();
            string data = string.Empty;
            listItems = (from p in db.DataValues
                         join v in db.ValueSets on p.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Description == "Fee Type"
                         select new ddlListItems
                         {
                             DataValueName = p.DataValue_Name,
                             DataValueDescription = p.DataValue_Description,
                         }).ToList();

            return (new JavaScriptSerializer()).Serialize(listItems);
        }





        [WebMethod]
        public static string LoadStudentData(int FeeID)
        {

            string getsessionid = "";

            DataBaseDataContext db = new DataBaseDataContext();
            var loadstudent = (from a in db.Student_Fees
                               where a.Fee_ID == FeeID
                               select new
                               {


                                   a.Fee_ID,
                                   a.Fee_No,
                                   a.Roll_No,
                                   a.Student_Name,
                                   a.Father_Name,
                                   a.Student_Class,
                                   a.Session,
                                   a.Total_Amount,
                                   a.Student_Account_ID,
                                   a.Status,
                                   a.Challan_No,
                                   a.Issue_Date,
                                   a.Due_Date,
                                   a.Date,
                                   getsessionid = (from v in db.Students where v.Student_ID == Convert.ToInt32(a.Roll_No) select v.Session),
                                   session = db.GetDataValueName("Session", getsessionid),
                                   a.Approved_Time

                               }).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(loadstudent);

        }

        [WebMethod]
        public static string LoadAutoChildData()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Header = db.sp_StudentFeeCategoryDetails().ToList();
            return (new JavaScriptSerializer()).Serialize(Header);
        }

        [WebMethod]
        public static string LoadChildData(int Fee_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Header = (from a in db.Student_Fee_Details
                          where a.Student_Fee_ID == Fee_ID
                          select new
                          {

                              a.Account_ID,
                              a.Fee_Type,
                              a.Payable_Fee,
                              a.Accrued_Income_Acc_ID,
                              a.NetIncome_Acc_ID,
                              AccruedIncomeAccName = DBClass.getField("select CONCAT(Account_Code, '-', Account_Name) from GL_Accounts where Account_ID =" + a.Accrued_Income_Acc_ID),
                              NetIncomeAccName = DBClass.getField("select CONCAT(Account_Code, '-', Account_Name) from GL_Accounts where Account_ID =" + a.NetIncome_Acc_ID),



                          }).ToList();
            return (new JavaScriptSerializer()).Serialize(Header);


        }




        [WebMethod]
        public static string GetStudentClass()

        {
            DataBaseDataContext db = new DataBaseDataContext();
            List<ddlListItems> listItems = new List<ddlListItems>();
            string data = string.Empty;
            listItems = (from p in db.DataValues
                         join v in db.ValueSets on p.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Description == "Student Class"
                         select new ddlListItems
                         {
                             DataValueName = p.DataValue_Name,
                             DataValueDescription = p.DataValue_Description,
                         }).ToList();

            return (new JavaScriptSerializer()).Serialize(listItems);


        }


        [WebMethod]
        public static string NewChallanNo()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var ChallanNo = db.GetSequentialChallanNo();
            return ChallanNo.ToString();
        }



        [WebMethod]
        public static string Getnewfeeno()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var GRN_No = DBClass.GetNewNumber("Fee_No", "Student_Fee", "");
            return GRN_No.ToString();
        }


        [WebMethod]
        public static string ApproveStudent(string FeeID, string FeeDate)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            DateTime? date = DateTime.Now;
            if (FeeDate == null || FeeDate == "")
            {

            }
            else
            {
                date = DateTime.Parse(FeeDate);
            }
            var Details = db.spApproveStudentFee(Convert.ToInt32(FeeID), date);
            return (new JavaScriptSerializer()).Serialize(Details);
        }
        [WebMethod]
        public static string UnApproveStudent(string FeeID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.spUnApproveStudentFee(Convert.ToInt32(FeeID));
            return (new JavaScriptSerializer()).Serialize(Details);
        }


        [WebMethod]
        public static int SaveStudentFee(string btnSave, string AllItemDetail)
        {
            string StudentMasterID = "";
            Student_Fee obj = new Student_Fee();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            JavaScriptSerializer oJS = new JavaScriptSerializer();
            var record = oJS.Deserialize<MasterList>(AllItemDetail);

            if (btnSave == "Update")
            {


                var lstItem = (from t in db.Student_Fees
                               where t.Fee_No == int.Parse(record.txt_feecode)
                               select t).FirstOrDefault();

                lstItem.Fee_No = Convert.ToInt32(record.txt_feecode);
                lstItem.Date = Convert.ToDateTime(record.txt_feedate);
                lstItem.Roll_No = record.ddl_rollno;
                lstItem.Student_Name = record.txt_studentname;
                lstItem.Father_Name = record.txt_fname;
                lstItem.Student_Class = record.ddlstu_class;
                lstItem.Status = record.txt_status;
                lstItem.Updated_By = AppConfig.UserID;
                lstItem.Update_Time = DateTime.Now;

                var b = record.txt_st_gl_Acc;
                if (b == null || b == "")
                {
                    lstItem.Student_Account_ID = 0;
                }
                else
                {
                    lstItem.Student_Account_ID = Convert.ToInt32(record.txt_st_gl_Acc);
                }


                lstItem.Student_Account_ID = Convert.ToInt32(record.txt_st_gl_Acc);
              
                lstItem.Total_Amount = Convert.ToDecimal(record.txt_Total_amount);
                db.SubmitChanges();
                StudentMasterID = lstItem.Fee_ID.ToString();
            }
            else
            {



                obj.Fee_No = Convert.ToInt32(record.txt_feecode);
                obj.Roll_No = record.ddl_rollno;
                obj.Student_Name = record.txt_studentname;
                obj.Date = Convert.ToDateTime(record.txt_feedate);
                obj.Father_Name = record.txt_fname;
                obj.Student_Class = record.ddlstu_class;
                obj.Status = record.txt_status;
                obj.Created_By = AppConfig.UserID;
                obj.Creation_Time = DateTime.Now;
                obj.IsCancel = false;

                var b = record.txt_st_gl_Acc;
                if (b == null || b == "")
                {
                    obj.Student_Account_ID = 0;
                }
                else
                {
                    obj.Student_Account_ID = Convert.ToInt32(record.txt_st_gl_Acc);
                }
                obj.Total_Amount = Convert.ToDecimal(record.txt_Total_amount);
                db.Student_Fees.InsertOnSubmit(obj);
                db.SubmitChanges();
                StudentMasterID = obj.Fee_ID.ToString();

            }


            if (btnSave == "Update")
            {
                List<Student_Fee_Detail> lststudentfeedetail = db.Student_Fee_Details.Where(t => t.Student_Fee_ID == int.Parse(StudentMasterID)).ToList();
                db.Student_Fee_Details.DeleteAllOnSubmit(lststudentfeedetail);
                db.SubmitChanges();
            }

            foreach (var a in record.ItemList)
            {

                Student_Fee_Detail ltd = new Student_Fee_Detail();

                ltd.Student_Fee_ID = Convert.ToInt32(StudentMasterID);
             
                ltd.Fee_Type = a.ddl_feetype;
                ltd.Payable_Fee = Convert.ToDecimal(a.txt_fee);
                ltd.Accrued_Income_Acc_ID = Convert.ToInt32(a.accruedincome_ID);
                ltd.NetIncome_Acc_ID = Convert.ToInt32(a.netincome_ID);

                db.Student_Fee_Details.InsertOnSubmit(ltd);
                db.SubmitChanges();
            }

            return int.Parse(StudentMasterID);

        }

     


        public class MasterList
        {
          
            public string txt_feecode { get; set; }
            public string ddl_rollno { get; set; }
            public string txt_studentname { get; set; }
            public string txt_fname { get; set; }
            public string ddlstu_class { get; set; }
            //            public string ddl_session { get; set; }
            public string txt_Total_amount { get; set; }
            public string txt_status { get; set; }
            public string txt_st_gl_Acc { get; set; }
            public string txt_feedate { get; set; }
            public List<AccountList> ItemList { get; set; }

        }


        public class AccountList
        {
            public string ddl_payablecode { get; set; }
            public string accruedincome_ID { get; set; }
            public string netincome_ID { get; set; }
            public string ddl_feetype { get; set; }
            public string txt_fee { get; set; }

        }



    }
}