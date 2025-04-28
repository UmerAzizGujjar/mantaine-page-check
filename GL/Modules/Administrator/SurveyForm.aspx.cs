using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.Administrator
{
    public partial class SurveyForm : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static string LoadSurveyData(int Stu_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var SurveyData = (from a in db.Surve_Forms
                              where a.Survey_Id == Stu_ID
                              select new
                              {
                                  a.Survey_Id,
                                  a.CHKQ_1_1,
                                  a.CHKQ_1_2,
                                  a.CHKQ_1_3,
                                  a.CHKQ_1_4,
                                  a.CHKQ_1_5,
                                  a.CHKQ_2_1,
                                  a.CHKQ_2_2,
                                  a.CHKQ_2_3,
                                  a.CHKQ_2_4,
                                  a.CHKQ_2_5,
                                  a.CHKQ_3_1,
                                  a.CHKQ_3_2,
                                  a.CHKQ_3_3,
                                  a.CHKQ_3_4,
                                  a.CHKQ_3_5,
                                  a.CHKQ_4_1,
                                  a.CHKQ_4_2,
                                  a.CHKQ_4_3,
                                  a.CHKQ_4_4,
                                  a.CHKQ_4_5,
                                  a.CHKQ_5_1,
                                  a.CHKQ_5_2,
                                  a.CHKQ_5_3,
                                  a.CHKQ_5_4,
                                  a.CHKQ_5_5,
                                  a.CHKQ_6_1,
                                  a.CHKQ_6_2,
                                  a.CHKQ_6_3,
                                  a.CHKQ_6_4,
                                  a.CHKQ_6_5,
                                  a.CHKQ_7_1,
                                  a.CHKQ_7_2,
                                  a.CHKQ_7_3,
                                  a.CHKQ_7_4,
                                  a.CHKQ_7_5,
                                  a.CHKQ_8_1,
                                  a.CHKQ_8_2,
                                  a.CHKQ_8_3,
                                  a.CHKQ_8_4,
                                  a.CHKQ_8_5,
                                  a.CHKQ_9_1,
                                  a.CHKQ_9_2,
                                  a.CHKQ_9_3,
                                  a.CHKQ_9_4,
                                  a.CHKQ_9_5,
                                  a.CHKQ_10_1,
                                  a.CHKQ_10_2,
                                  a.CHKQ_10_3,
                                  a.CHKQ_10_4,
                                  a.CHKQ_10_5,
                                  a.CHKQ_11_1,
                                  a.CHKQ_11_2,
                                  a.CHKQ_11_3,
                                  a.CHKQ_11_4,
                                  a.CHKQ_11_5,
                                  a.CHKQ_12_1,
                                  a.CHKQ_12_2,
                                  a.CHKQ_12_3,
                                  a.CHKQ_12_4,
                                  a.CHKQ_12_5,
                                  a.CHKQ_13_1,
                                  a.CHKQ_13_2,
                                  a.CHKQ_13_3,
                                  a.CHKQ_13_4,
                                  a.CHKQ_13_5,
                                  a.CHKQ_14_1,
                                  a.CHKQ_14_2,
                                  a.CHKQ_14_3,
                                  a.CHKQ_14_4,
                                  a.CHKQ_14_5,
                                  a.CHKQ_15_1,
                                  a.CHKQ_15_2,
                                  a.CHKQ_15_3,
                                  a.CHKQ_15_4,
                                  a.CHKQ_15_5,
                                  a.CHKQ_16_1,
                                  a.CHKQ_16_2,
                                  a.CHKQ_16_3,
                                  a.CHKQ_16_4,
                                  a.CHKQ_16_5,
                                  a.CHKQ_17_1,
                                  a.CHKQ_17_2,
                                  a.CHKQ_17_3,
                                  a.CHKQ_17_4,
                                  a.CHKQ_17_5,
                                  a.CHKQ_18_1,
                                  a.CHKQ_18_2,
                                  a.CHKQ_18_3,
                                  a.CHKQ_18_4,
                                  a.CHKQ_18_5,
                                  a.CHKQ_19_1,
                                  a.CHKQ_19_2,
                                  a.CHKQ_19_3,
                                  a.CHKQ_19_4,
                                  a.CHKQ_19_5,
                                  a.Comments,
                                  a.Name,
                                  a.pat_no
                              }).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(SurveyData);
        }
        [WebMethod]
        public static string getname(string pat_id)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var decription = (from p in db.Reg_patients

                              where p.pat_id == Convert.ToInt32(pat_id)
                              select new
                              {
                                  p.Full_Name,
                              }
                              ).FirstOrDefault();


            return (new JavaScriptSerializer()).Serialize(decription);
        }
        [WebMethod]
        public static string Getpat_no()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            string data = string.Empty;
            var listItems = (from p in db.Reg_patients
                             select new
                             {
                                 pat_id = p.pat_id,
                                 pat_no = p.mr_no_sequence,
                             }).ToList();

            return (new JavaScriptSerializer()).Serialize(listItems);
        }
        [WebMethod]
        public static string SaveStudentData(string btnSave, string AllItemDetail)
        {
            string survId = "";
            Surve_Form stud = new Surve_Form();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            JavaScriptSerializer serialize = new JavaScriptSerializer();
            var record = serialize.Deserialize<MasterList>(AllItemDetail);
            if (btnSave == "Update")
            {

                var lstItem = (from a in db.Surve_Forms
                               where a.Survey_Id == Convert.ToInt32(record.Survey_Id)
                               select a).FirstOrDefault();
                lstItem.Updated_By = AppConfig.UserID;
                lstItem.Updated_Time = DateTime.Now;
                lstItem.CHKQ_1_1 = Convert.ToBoolean(record.CHKQ_1_1);
                lstItem.CHKQ_1_2 = Convert.ToBoolean(record.CHKQ_1_2);
                lstItem.CHKQ_1_3 = Convert.ToBoolean(record.CHKQ_1_3);
                lstItem.CHKQ_1_4 = Convert.ToBoolean(record.CHKQ_1_4);
                lstItem.CHKQ_1_5 = Convert.ToBoolean(record.CHKQ_1_5);
                lstItem.CHKQ_2_1 = Convert.ToBoolean(record.CHKQ_2_1);
                lstItem.CHKQ_2_2 = Convert.ToBoolean(record.CHKQ_2_2);
                lstItem.CHKQ_2_3 = Convert.ToBoolean(record.CHKQ_2_3);
                lstItem.CHKQ_2_4 = Convert.ToBoolean(record.CHKQ_2_4);
                lstItem.CHKQ_2_5 = Convert.ToBoolean(record.CHKQ_2_5);
                lstItem.CHKQ_3_1 = Convert.ToBoolean(record.CHKQ_3_1);
                lstItem.CHKQ_3_2 = Convert.ToBoolean(record.CHKQ_3_2);
                lstItem.CHKQ_3_3 = Convert.ToBoolean(record.CHKQ_3_3);
                lstItem.CHKQ_3_4 = Convert.ToBoolean(record.CHKQ_3_4);
                lstItem.CHKQ_3_5 = Convert.ToBoolean(record.CHKQ_3_5);
                lstItem.CHKQ_4_1 = Convert.ToBoolean(record.CHKQ_4_1);
                lstItem.CHKQ_4_2 = Convert.ToBoolean(record.CHKQ_4_2);
                lstItem.CHKQ_4_3 = Convert.ToBoolean(record.CHKQ_4_3);
                lstItem.CHKQ_4_4 = Convert.ToBoolean(record.CHKQ_4_4);
                lstItem.CHKQ_4_5 = Convert.ToBoolean(record.CHKQ_4_5);
                lstItem.CHKQ_5_1 = Convert.ToBoolean(record.CHKQ_5_1);
                lstItem.CHKQ_5_2 = Convert.ToBoolean(record.CHKQ_5_2);
                lstItem.CHKQ_5_3 = Convert.ToBoolean(record.CHKQ_5_3);
                lstItem.CHKQ_5_4 = Convert.ToBoolean(record.CHKQ_5_4);
                lstItem.CHKQ_5_5 = Convert.ToBoolean(record.CHKQ_5_5);
                lstItem.CHKQ_6_1 = Convert.ToBoolean(record.CHKQ_6_1);
                lstItem.CHKQ_6_2 = Convert.ToBoolean(record.CHKQ_6_2);
                lstItem.CHKQ_6_3 = Convert.ToBoolean(record.CHKQ_6_3);
                lstItem.CHKQ_6_4 = Convert.ToBoolean(record.CHKQ_6_4);
                lstItem.CHKQ_6_5 = Convert.ToBoolean(record.CHKQ_6_5);
                lstItem.CHKQ_7_1 = Convert.ToBoolean(record.CHKQ_7_1);
                lstItem.CHKQ_7_2 = Convert.ToBoolean(record.CHKQ_7_2);
                lstItem.CHKQ_7_3 = Convert.ToBoolean(record.CHKQ_7_3);
                lstItem.CHKQ_7_4 = Convert.ToBoolean(record.CHKQ_7_4);
                lstItem.CHKQ_7_5 = Convert.ToBoolean(record.CHKQ_7_5);
                lstItem.CHKQ_8_1 = Convert.ToBoolean(record.CHKQ_8_1);
                lstItem.CHKQ_8_2 = Convert.ToBoolean(record.CHKQ_8_2);
                lstItem.CHKQ_8_3 = Convert.ToBoolean(record.CHKQ_8_3);
                lstItem.CHKQ_8_4 = Convert.ToBoolean(record.CHKQ_8_4);
                lstItem.CHKQ_8_5 = Convert.ToBoolean(record.CHKQ_8_5);
                lstItem.CHKQ_9_1 = Convert.ToBoolean(record.CHKQ_9_1);
                lstItem.CHKQ_9_2 = Convert.ToBoolean(record.CHKQ_9_2);
                lstItem.CHKQ_9_3 = Convert.ToBoolean(record.CHKQ_9_3);
                lstItem.CHKQ_9_4 = Convert.ToBoolean(record.CHKQ_9_4);
                lstItem.CHKQ_9_5 = Convert.ToBoolean(record.CHKQ_9_5);
                lstItem.CHKQ_10_1 = Convert.ToBoolean(record.CHKQ_10_1);
                lstItem.CHKQ_10_2 = Convert.ToBoolean(record.CHKQ_10_2);
                lstItem.CHKQ_10_3 = Convert.ToBoolean(record.CHKQ_10_3);
                lstItem.CHKQ_10_4 = Convert.ToBoolean(record.CHKQ_10_4);
                lstItem.CHKQ_10_5 = Convert.ToBoolean(record.CHKQ_10_5);
                lstItem.CHKQ_11_1 = Convert.ToBoolean(record.CHKQ_11_1);
                lstItem.CHKQ_11_2 = Convert.ToBoolean(record.CHKQ_11_2);
                lstItem.CHKQ_11_3 = Convert.ToBoolean(record.CHKQ_11_3);
                lstItem.CHKQ_11_4 = Convert.ToBoolean(record.CHKQ_11_4);
                lstItem.CHKQ_11_5 = Convert.ToBoolean(record.CHKQ_11_5);
                lstItem.CHKQ_12_1 = Convert.ToBoolean(record.CHKQ_12_1);
                lstItem.CHKQ_12_2 = Convert.ToBoolean(record.CHKQ_12_2);
                lstItem.CHKQ_12_3 = Convert.ToBoolean(record.CHKQ_12_3);
                lstItem.CHKQ_12_4 = Convert.ToBoolean(record.CHKQ_12_4);
                lstItem.CHKQ_12_5 = Convert.ToBoolean(record.CHKQ_12_5);
                lstItem.CHKQ_13_1 = Convert.ToBoolean(record.CHKQ_13_1);
                lstItem.CHKQ_13_2 = Convert.ToBoolean(record.CHKQ_13_2);
                lstItem.CHKQ_13_3 = Convert.ToBoolean(record.CHKQ_13_3);
                lstItem.CHKQ_13_4 = Convert.ToBoolean(record.CHKQ_13_4);
                lstItem.CHKQ_13_5 = Convert.ToBoolean(record.CHKQ_13_5);
                lstItem.CHKQ_14_1 = Convert.ToBoolean(record.CHKQ_14_1);
                lstItem.CHKQ_14_2 = Convert.ToBoolean(record.CHKQ_14_2);
                lstItem.CHKQ_14_3 = Convert.ToBoolean(record.CHKQ_14_3);
                lstItem.CHKQ_14_4 = Convert.ToBoolean(record.CHKQ_14_4);
                lstItem.CHKQ_14_5 = Convert.ToBoolean(record.CHKQ_14_5);
                lstItem.CHKQ_15_1 = Convert.ToBoolean(record.CHKQ_15_1);
                lstItem.CHKQ_15_2 = Convert.ToBoolean(record.CHKQ_15_2);
                lstItem.CHKQ_15_3 = Convert.ToBoolean(record.CHKQ_15_3);
                lstItem.CHKQ_15_4 = Convert.ToBoolean(record.CHKQ_15_4);
                lstItem.CHKQ_15_5 = Convert.ToBoolean(record.CHKQ_15_5);
                lstItem.CHKQ_16_1 = Convert.ToBoolean(record.CHKQ_16_1);
                lstItem.CHKQ_16_2 = Convert.ToBoolean(record.CHKQ_16_2);
                lstItem.CHKQ_16_3 = Convert.ToBoolean(record.CHKQ_16_3);
                lstItem.CHKQ_16_4 = Convert.ToBoolean(record.CHKQ_16_4);
                lstItem.CHKQ_16_5 = Convert.ToBoolean(record.CHKQ_16_5);
                lstItem.CHKQ_17_1 = Convert.ToBoolean(record.CHKQ_17_1);
                lstItem.CHKQ_17_2 = Convert.ToBoolean(record.CHKQ_17_2);
                lstItem.CHKQ_17_3 = Convert.ToBoolean(record.CHKQ_17_3);
                lstItem.CHKQ_17_4 = Convert.ToBoolean(record.CHKQ_17_4);
                lstItem.CHKQ_17_5 = Convert.ToBoolean(record.CHKQ_17_5);
                lstItem.CHKQ_18_1 = Convert.ToBoolean(record.CHKQ_18_1);
                lstItem.CHKQ_18_2 = Convert.ToBoolean(record.CHKQ_18_2);
                lstItem.CHKQ_18_3 = Convert.ToBoolean(record.CHKQ_18_3);
                lstItem.CHKQ_18_4 = Convert.ToBoolean(record.CHKQ_18_4);
                lstItem.CHKQ_18_5 = Convert.ToBoolean(record.CHKQ_18_5);
                lstItem.CHKQ_19_1 = Convert.ToBoolean(record.CHKQ_19_1);
                lstItem.CHKQ_19_2 = Convert.ToBoolean(record.CHKQ_19_2);
                lstItem.CHKQ_19_3 = Convert.ToBoolean(record.CHKQ_19_3);
                lstItem.CHKQ_19_4 = Convert.ToBoolean(record.CHKQ_19_4);
                lstItem.CHKQ_19_5 = Convert.ToBoolean(record.CHKQ_19_5);
                lstItem.Comments = record.comments;
                lstItem.Name = record.txtname;
                lstItem.pat_no = record.ddlpat_no;

                db.SubmitChanges();
                survId = lstItem.Survey_Id.ToString();

            }
            else
            {
                stud.Created_BY = AppConfig.UserID;
                stud.Created_Time = DateTime.Now;
                stud.CHKQ_1_1 = Convert.ToBoolean(record.CHKQ_1_1);
                stud.CHKQ_1_2 = Convert.ToBoolean(record.CHKQ_1_2);
                stud.CHKQ_1_3 = Convert.ToBoolean(record.CHKQ_1_3);
                stud.CHKQ_1_4 = Convert.ToBoolean(record.CHKQ_1_4);
                stud.CHKQ_1_5 = Convert.ToBoolean(record.CHKQ_1_5);
                stud.CHKQ_2_1 = Convert.ToBoolean(record.CHKQ_2_1);
                stud.CHKQ_2_2 = Convert.ToBoolean(record.CHKQ_2_2);
                stud.CHKQ_2_3 = Convert.ToBoolean(record.CHKQ_2_3);
                stud.CHKQ_2_4 = Convert.ToBoolean(record.CHKQ_2_4);
                stud.CHKQ_2_5 = Convert.ToBoolean(record.CHKQ_2_5);
                stud.CHKQ_3_1 = Convert.ToBoolean(record.CHKQ_3_1);
                stud.CHKQ_3_2 = Convert.ToBoolean(record.CHKQ_3_2);
                stud.CHKQ_3_3 = Convert.ToBoolean(record.CHKQ_3_3);
                stud.CHKQ_3_4 = Convert.ToBoolean(record.CHKQ_3_4);
                stud.CHKQ_3_5 = Convert.ToBoolean(record.CHKQ_3_5);
                stud.CHKQ_4_1 = Convert.ToBoolean(record.CHKQ_4_1);
                stud.CHKQ_4_2 = Convert.ToBoolean(record.CHKQ_4_2);
                stud.CHKQ_4_3 = Convert.ToBoolean(record.CHKQ_4_3);
                stud.CHKQ_4_4 = Convert.ToBoolean(record.CHKQ_4_4);
                stud.CHKQ_4_5 = Convert.ToBoolean(record.CHKQ_4_5);
                stud.CHKQ_5_1 = Convert.ToBoolean(record.CHKQ_5_1);
                stud.CHKQ_5_2 = Convert.ToBoolean(record.CHKQ_5_2);
                stud.CHKQ_5_3 = Convert.ToBoolean(record.CHKQ_5_3);
                stud.CHKQ_5_4 = Convert.ToBoolean(record.CHKQ_5_4);
                stud.CHKQ_5_5 = Convert.ToBoolean(record.CHKQ_5_5);
                stud.CHKQ_6_1 = Convert.ToBoolean(record.CHKQ_6_1);
                stud.CHKQ_6_2 = Convert.ToBoolean(record.CHKQ_6_2);
                stud.CHKQ_6_3 = Convert.ToBoolean(record.CHKQ_6_3);
                stud.CHKQ_6_4 = Convert.ToBoolean(record.CHKQ_6_4);
                stud.CHKQ_6_5 = Convert.ToBoolean(record.CHKQ_6_5);
                stud.CHKQ_7_1 = Convert.ToBoolean(record.CHKQ_7_1);
                stud.CHKQ_7_2 = Convert.ToBoolean(record.CHKQ_7_2);
                stud.CHKQ_7_3 = Convert.ToBoolean(record.CHKQ_7_3);
                stud.CHKQ_7_4 = Convert.ToBoolean(record.CHKQ_7_4);
                stud.CHKQ_7_5 = Convert.ToBoolean(record.CHKQ_7_5);
                stud.CHKQ_8_1 = Convert.ToBoolean(record.CHKQ_8_1);
                stud.CHKQ_8_2 = Convert.ToBoolean(record.CHKQ_8_2);
                stud.CHKQ_8_3 = Convert.ToBoolean(record.CHKQ_8_3);
                stud.CHKQ_8_4 = Convert.ToBoolean(record.CHKQ_8_4);
                stud.CHKQ_8_5 = Convert.ToBoolean(record.CHKQ_8_5);
                stud.CHKQ_9_1 = Convert.ToBoolean(record.CHKQ_9_1);
                stud.CHKQ_9_2 = Convert.ToBoolean(record.CHKQ_9_2);
                stud.CHKQ_9_3 = Convert.ToBoolean(record.CHKQ_9_3);
                stud.CHKQ_9_4 = Convert.ToBoolean(record.CHKQ_9_4);
                stud.CHKQ_9_5 = Convert.ToBoolean(record.CHKQ_9_5);
                stud.CHKQ_10_1 = Convert.ToBoolean(record.CHKQ_10_1);
                stud.CHKQ_10_2 = Convert.ToBoolean(record.CHKQ_10_2);
                stud.CHKQ_10_3 = Convert.ToBoolean(record.CHKQ_10_3);
                stud.CHKQ_10_4 = Convert.ToBoolean(record.CHKQ_10_4);
                stud.CHKQ_10_5 = Convert.ToBoolean(record.CHKQ_10_5);
                stud.CHKQ_11_1 = Convert.ToBoolean(record.CHKQ_11_1);
                stud.CHKQ_11_2 = Convert.ToBoolean(record.CHKQ_11_2);
                stud.CHKQ_11_3 = Convert.ToBoolean(record.CHKQ_11_3);
                stud.CHKQ_11_4 = Convert.ToBoolean(record.CHKQ_11_4);
                stud.CHKQ_11_5 = Convert.ToBoolean(record.CHKQ_11_5);
                stud.CHKQ_12_1 = Convert.ToBoolean(record.CHKQ_12_1);
                stud.CHKQ_12_2 = Convert.ToBoolean(record.CHKQ_12_2);
                stud.CHKQ_12_3 = Convert.ToBoolean(record.CHKQ_12_3);
                stud.CHKQ_12_4 = Convert.ToBoolean(record.CHKQ_12_4);
                stud.CHKQ_12_5 = Convert.ToBoolean(record.CHKQ_12_5);
                stud.CHKQ_13_1 = Convert.ToBoolean(record.CHKQ_13_1);
                stud.CHKQ_13_2 = Convert.ToBoolean(record.CHKQ_13_2);
                stud.CHKQ_13_3 = Convert.ToBoolean(record.CHKQ_13_3);
                stud.CHKQ_13_4 = Convert.ToBoolean(record.CHKQ_13_4);
                stud.CHKQ_13_5 = Convert.ToBoolean(record.CHKQ_13_5);
                stud.CHKQ_14_1 = Convert.ToBoolean(record.CHKQ_14_1);
                stud.CHKQ_14_2 = Convert.ToBoolean(record.CHKQ_14_2);
                stud.CHKQ_14_3 = Convert.ToBoolean(record.CHKQ_14_3);
                stud.CHKQ_14_4 = Convert.ToBoolean(record.CHKQ_14_4);
                stud.CHKQ_14_5 = Convert.ToBoolean(record.CHKQ_14_5);
                stud.CHKQ_15_1 = Convert.ToBoolean(record.CHKQ_15_1);
                stud.CHKQ_15_2 = Convert.ToBoolean(record.CHKQ_15_2);
                stud.CHKQ_15_3 = Convert.ToBoolean(record.CHKQ_15_3);
                stud.CHKQ_15_4 = Convert.ToBoolean(record.CHKQ_15_4);
                stud.CHKQ_15_5 = Convert.ToBoolean(record.CHKQ_15_5);
                stud.CHKQ_16_1 = Convert.ToBoolean(record.CHKQ_16_1);
                stud.CHKQ_16_2 = Convert.ToBoolean(record.CHKQ_16_2);
                stud.CHKQ_16_3 = Convert.ToBoolean(record.CHKQ_16_3);
                stud.CHKQ_16_4 = Convert.ToBoolean(record.CHKQ_16_4);
                stud.CHKQ_16_5 = Convert.ToBoolean(record.CHKQ_16_5);
                stud.CHKQ_17_1 = Convert.ToBoolean(record.CHKQ_17_1);
                stud.CHKQ_17_2 = Convert.ToBoolean(record.CHKQ_17_2);
                stud.CHKQ_17_3 = Convert.ToBoolean(record.CHKQ_17_3);
                stud.CHKQ_17_4 = Convert.ToBoolean(record.CHKQ_17_4);
                stud.CHKQ_17_5 = Convert.ToBoolean(record.CHKQ_17_5);
                stud.CHKQ_18_1 = Convert.ToBoolean(record.CHKQ_18_1);
                stud.CHKQ_18_2 = Convert.ToBoolean(record.CHKQ_18_2);
                stud.CHKQ_18_3 = Convert.ToBoolean(record.CHKQ_18_3);
                stud.CHKQ_18_4 = Convert.ToBoolean(record.CHKQ_18_4);
                stud.CHKQ_18_5 = Convert.ToBoolean(record.CHKQ_18_5);
                stud.CHKQ_19_1 = Convert.ToBoolean(record.CHKQ_19_1);
                stud.CHKQ_19_2 = Convert.ToBoolean(record.CHKQ_19_2);
                stud.CHKQ_19_3 = Convert.ToBoolean(record.CHKQ_19_3);
                stud.CHKQ_19_4 = Convert.ToBoolean(record.CHKQ_19_4);
                stud.CHKQ_19_5 = Convert.ToBoolean(record.CHKQ_19_5);
                stud.Comments = record.comments;
                stud.Name = record.txtname;
                stud.pat_no = record.ddlpat_no;
                stud.IsCencal = false;
                db.Surve_Forms.InsertOnSubmit(stud);
                db.SubmitChanges();
                survId = stud.Survey_Id.ToString();



            }
            return survId;
        }
        public class MasterList
        {
            public string txtname { get; set; }
            public string ddlpat_no { get; set; }
            public string Survey_Id { get; set; }
            public string comments { get; set; }
            public bool CHKQ_1_1 { get; set; }
            public bool CHKQ_1_2 { get; set; }
            public bool CHKQ_1_3 { get; set; }
            public bool CHKQ_1_4 { get; set; }
            public bool CHKQ_1_5 { get; set; }
            public bool CHKQ_2_1 { get; set; }
            public bool CHKQ_2_2 { get; set; }
            public bool CHKQ_2_3 { get; set; }
            public bool CHKQ_2_4 { get; set; }
            public bool CHKQ_2_5 { get; set; }
            public bool CHKQ_3_1 { get; set; }
            public bool CHKQ_3_2 { get; set; }
            public bool CHKQ_3_3 { get; set; }
            public bool CHKQ_3_4 { get; set; }
            public bool CHKQ_3_5 { get; set; }
            public bool CHKQ_4_1 { get; set; }
            public bool CHKQ_4_2 { get; set; }
            public bool CHKQ_4_3 { get; set; }
            public bool CHKQ_4_4 { get; set; }
            public bool CHKQ_4_5 { get; set; }
            public bool CHKQ_5_1 { get; set; }
            public bool CHKQ_5_2 { get; set; }
            public bool CHKQ_5_3 { get; set; }
            public bool CHKQ_5_4 { get; set; }
            public bool CHKQ_5_5 { get; set; }
            public bool CHKQ_6_1 { get; set; }
            public bool CHKQ_6_2 { get; set; }
            public bool CHKQ_6_3 { get; set; }
            public bool CHKQ_6_4 { get; set; }
            public bool CHKQ_6_5 { get; set; }
            public bool CHKQ_7_1 { get; set; }
            public bool CHKQ_7_2 { get; set; }
            public bool CHKQ_7_3 { get; set; }
            public bool CHKQ_7_4 { get; set; }
            public bool CHKQ_7_5 { get; set; }
            public bool CHKQ_8_1 { get; set; }
            public bool CHKQ_8_2 { get; set; }
            public bool CHKQ_8_3 { get; set; }
            public bool CHKQ_8_4 { get; set; }
            public bool CHKQ_8_5 { get; set; }
            public bool CHKQ_9_1 { get; set; }
            public bool CHKQ_9_2 { get; set; }
            public bool CHKQ_9_3 { get; set; }
            public bool CHKQ_9_4 { get; set; }
            public bool CHKQ_9_5 { get; set; }
            public bool CHKQ_10_1 { get; set; }
            public bool CHKQ_10_2 { get; set; }
            public bool CHKQ_10_3 { get; set; }
            public bool CHKQ_10_4 { get; set; }
            public bool CHKQ_10_5 { get; set; }
            public bool CHKQ_11_1 { get; set; }
            public bool CHKQ_11_2 { get; set; }
            public bool CHKQ_11_3 { get; set; }
            public bool CHKQ_11_4 { get; set; }
            public bool CHKQ_11_5 { get; set; }
            public bool CHKQ_12_1 { get; set; }
            public bool CHKQ_12_2 { get; set; }
            public bool CHKQ_12_3 { get; set; }
            public bool CHKQ_12_4 { get; set; }
            public bool CHKQ_12_5 { get; set; }
            public bool CHKQ_13_1 { get; set; }
            public bool CHKQ_13_2 { get; set; }
            public bool CHKQ_13_3 { get; set; }
            public bool CHKQ_13_4 { get; set; }
            public bool CHKQ_13_5 { get; set; }
            public bool CHKQ_14_1 { get; set; }
            public bool CHKQ_14_2 { get; set; }
            public bool CHKQ_14_3 { get; set; }
            public bool CHKQ_14_4 { get; set; }
            public bool CHKQ_14_5 { get; set; }
            public bool CHKQ_15_1 { get; set; }
            public bool CHKQ_15_2 { get; set; }
            public bool CHKQ_15_3 { get; set; }
            public bool CHKQ_15_4 { get; set; }
            public bool CHKQ_15_5 { get; set; }
            public bool CHKQ_16_1 { get; set; }
            public bool CHKQ_16_2 { get; set; }
            public bool CHKQ_16_3 { get; set; }
            public bool CHKQ_16_4 { get; set; }
            public bool CHKQ_16_5 { get; set; }
            public bool CHKQ_17_1 { get; set; }
            public bool CHKQ_17_2 { get; set; }
            public bool CHKQ_17_3 { get; set; }
            public bool CHKQ_17_4 { get; set; }
            public bool CHKQ_17_5 { get; set; }
            public bool CHKQ_18_1 { get; set; }
            public bool CHKQ_18_2 { get; set; }
            public bool CHKQ_18_3 { get; set; }
            public bool CHKQ_18_4 { get; set; }
            public bool CHKQ_18_5 { get; set; }
            public bool CHKQ_19_1 { get; set; }
            public bool CHKQ_19_2 { get; set; }
            public bool CHKQ_19_3 { get; set; }
            public bool CHKQ_19_4 { get; set; }
            public bool CHKQ_19_5 { get; set; }
        }
    }
}