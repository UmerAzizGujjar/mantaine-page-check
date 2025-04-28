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
    public partial class AddStudentChallan : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static decimal checkrecvablefee(string Student_ID)
        {

            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            //var query = (from a in db.Student_Fees where a.Roll_No == Student_ID select a.Total_Amount).FirstOrDefault();

            var query = DBClass.getField("select top 1 a.Total_Amount from Student_Fee a where a.Roll_No =" + Student_ID + "  order by Fee_ID desc");

            if (query == null)

            {
                query = Convert.ToString(0);
            }

            return Convert.ToDecimal(query);

            //return int.Parse(query);

        }



        [WebMethod]
        public static int CheckStudentExist(string Student_ID)
        {

            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var query = (from a in db.Student_Fees where a.Roll_No == Student_ID select a.Roll_No).FirstOrDefault();

            if (query == null)

            {
                query = Convert.ToString(0);

            }

            return int.Parse(query);

        }



        [WebMethod]
        public static string GetHiddenChallanNos()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var ChallanNo = DBClass.GetNewNumber("Challan_No", "Challan_Amounts", "");
            return ChallanNo.ToString();
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
        public static string NewChallanNo()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var ChallanNo = db.GetSequentialChallanNo();
            return ChallanNo.ToString();
        }




        [WebMethod]
        public static int SaveChallanAmount(string btnsave, string AllItemDetail)
        {
            string ChallanID = "";
            Challan_Amount obj = new Challan_Amount();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            JavaScriptSerializer oJS = new JavaScriptSerializer();
            var record = oJS.Deserialize<ChallanAmountList>(AllItemDetail);

            if (btnsave == "Update")
            {


                var lstItem = (from t in db.Challan_Amounts
                               where t.Challan_ID == int.Parse(record.Challan_ID)
                               select t).FirstOrDefault();

                lstItem.Student_ID = Convert.ToInt32(record.Student_ID);
                lstItem.Challan_No = Convert.ToInt32(record.txthiddenchallanno);
                lstItem.Seq_Challan_No = record.txt_challanNo;
                lstItem.IssueDate = Convert.ToDateTime(record.txt_issueDate);
                lstItem.DueDate = Convert.ToDateTime(record.txt_dueDate);

                if (record.Admission_Fee != "")
                {

                    lstItem.Admission_Fee = Convert.ToDecimal(record.Admission_Fee);

                }

                if (record.Tuition_Fee != "")
                {

                    lstItem.Tuition_Fee = Convert.ToDecimal(record.Tuition_Fee);

                }

                if (record.Library_Magazine_Fund != "")
                {

                    lstItem.Library_Magazine_Fund = Convert.ToDecimal(record.Library_Magazine_Fund);

                }

                if (record.Reg_Fee != "")
                {

                    lstItem.Reg_Fee = Convert.ToDecimal(record.Reg_Fee);

                }

                if (record.Degree_Fee != "")
                {

                    lstItem.Degree_Fee = Convert.ToDecimal(record.Degree_Fee);

                }

                if (record.Security_Fee != "")
                {

                    lstItem.Security_Fee = Convert.ToDecimal(record.Security_Fee);

                }

                if (record.Hostel_Fee != "")
                {

                    lstItem.Hostel_Fee = Convert.ToDecimal(record.Hostel_Fee);

                }

                if (record.Examination_Fee != "")
                {

                    lstItem.Examination_Fee = Convert.ToDecimal(record.Examination_Fee);

                }

                if (record.Remaining_Tuition_Fee != "")
                {

                    lstItem.Remaining_Tuition_Fee = Convert.ToDecimal(record.Remaining_Tuition_Fee);

                }

                if (record.Other_Fee != "")
                {

                    lstItem.Other_Fee = Convert.ToDecimal(record.Other_Fee);

                }

                if (record.Student_Card_Fee != "")
                {

                    lstItem.Student_Card_Fee = Convert.ToDecimal(record.Student_Card_Fee);

                }

                if (record.Remaining_Hostel_Fee != "")
                {

                    lstItem.Remaining_Hostel_Fee = Convert.ToDecimal(record.Remaining_Hostel_Fee);

                }

                if (record.Prospectus_Fee != "")
                {

                    lstItem.Prospectus_Fee = Convert.ToDecimal(record.Prospectus_Fee);

                }

                if (record.Test_Fee != "")
                {

                    lstItem.Test_Fee = Convert.ToDecimal(record.Test_Fee);

                }

                if (record.Misc_Fee != "")
                {

                    lstItem.Misc_Fee = Convert.ToDecimal(record.Misc_Fee);

                }

                db.SubmitChanges();
                ChallanID = lstItem.Challan_ID.ToString();
            }
            else
            {


                obj.Student_ID = Convert.ToInt32(record.Student_ID);
                obj.Challan_No = Convert.ToInt32(record.txthiddenchallanno);
                obj.Seq_Challan_No = record.txt_challanNo;
                obj.IssueDate = Convert.ToDateTime(record.txt_issueDate);
                obj.DueDate = Convert.ToDateTime(record.txt_dueDate);
                obj.isCancel = false;

                if (record.Admission_Fee != "")
                {

                    obj.Admission_Fee = Convert.ToDecimal(record.Admission_Fee);

                }

                if (record.Tuition_Fee != "")
                {

                    obj.Tuition_Fee = Convert.ToDecimal(record.Tuition_Fee);

                }

                if (record.Library_Magazine_Fund != "")
                {

                    obj.Library_Magazine_Fund = Convert.ToDecimal(record.Library_Magazine_Fund);

                }

                if (record.Reg_Fee != "")
                {

                    obj.Reg_Fee = Convert.ToDecimal(record.Reg_Fee);

                }

                if (record.Degree_Fee != "")
                {

                    obj.Degree_Fee = Convert.ToDecimal(record.Degree_Fee);

                }

                if (record.Security_Fee != "")
                {

                    obj.Security_Fee = Convert.ToDecimal(record.Security_Fee);

                }

                if (record.Hostel_Fee != "")
                {

                    obj.Hostel_Fee = Convert.ToDecimal(record.Hostel_Fee);

                }

                if (record.Examination_Fee != "")
                {

                    obj.Examination_Fee = Convert.ToDecimal(record.Examination_Fee);

                }

                if (record.Remaining_Tuition_Fee != "")
                {

                    obj.Remaining_Tuition_Fee = Convert.ToDecimal(record.Remaining_Tuition_Fee);

                }

                if (record.Other_Fee != "")
                {

                    obj.Other_Fee = Convert.ToDecimal(record.Other_Fee);

                }

                if (record.Student_Card_Fee != "")
                {

                    obj.Student_Card_Fee = Convert.ToDecimal(record.Student_Card_Fee);

                }

                if (record.Remaining_Hostel_Fee != "")
                {

                    obj.Remaining_Hostel_Fee = Convert.ToDecimal(record.Remaining_Hostel_Fee);

                }

                if (record.Prospectus_Fee != "")
                {

                    obj.Prospectus_Fee = Convert.ToDecimal(record.Prospectus_Fee);

                }

                if (record.Test_Fee != "")
                {

                    obj.Test_Fee = Convert.ToDecimal(record.Test_Fee);

                }

                if (record.Misc_Fee != "")
                {

                    obj.Misc_Fee = Convert.ToDecimal(record.Misc_Fee);

                }


                db.Challan_Amounts.InsertOnSubmit(obj);
                db.SubmitChanges();
                ChallanID = obj.Challan_ID.ToString();

            }

            return int.Parse(ChallanID);

        }




        [WebMethod]

        public static string LoadChallan(int ChallanID)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var Details = (from a in db.Challan_Amounts
                           where a.Challan_ID == ChallanID
                           select new
                           {

                               a.Challan_ID,
                               a.Challan_No,
                               a.Seq_Challan_No,
                               a.Student_ID,
                               a.Admission_Fee,
                               a.Tuition_Fee,
                               a.Library_Magazine_Fund,
                               a.Reg_Fee,
                               a.Degree_Fee,
                               a.Security_Fee,
                               a.Hostel_Fee,
                               a.Examination_Fee,
                               a.Remaining_Tuition_Fee,
                               a.Other_Fee,
                               a.Student_Card_Fee,
                               a.Remaining_Hostel_Fee,
                               a.Prospectus_Fee,
                               a.Test_Fee,
                               a.Misc_Fee,
                               a.IssueDate,
                               a.DueDate,





                           }).FirstOrDefault();


            //            var Details = db.sp_loadAdvancePaymentHeader(ChallanID).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(Details);
        }





        public class ChallanAmountList

        {
            public string Challan_ID { get; set; }
            public string txt_challanNo { get; set; }
            public string txthiddenchallanno { get; set; }
            public string txt_issueDate { get; set; }
            public string txt_dueDate { get; set; }
            public string Student_ID { get; set; }
            public string Admission_Fee { get; set; }
            public string Tuition_Fee { get; set; }
            public string Library_Magazine_Fund { get; set; }
            public string Reg_Fee { get; set; }
            public string Degree_Fee { get; set; }
            public string Security_Fee { get; set; }
            public string Hostel_Fee { get; set; }
            public string Examination_Fee { get; set; }
            public string Remaining_Tuition_Fee { get; set; }
            public string Other_Fee { get; set; }
            public string Student_Card_Fee { get; set; }
            public string Remaining_Hostel_Fee { get; set; }
            public string Prospectus_Fee { get; set; }
            public string Test_Fee { get; set; }
            public string Misc_Fee { get; set; }

        }



    }
}