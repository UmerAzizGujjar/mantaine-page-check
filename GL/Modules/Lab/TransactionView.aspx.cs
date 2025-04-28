using System;
using System.Collections.Generic;
using System.Data.Linq.Mapping;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.SqlClient;

namespace PMS
{
    public partial class TransactionView : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static string GetColumns(string Tag)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            string val="yes";
                if (Tag.Equals("OutSourceTestStatusList"))
                {
                   
                    var TableData = db.sp_OutSourceTestList2().ToList();

                    if (TableData.Count != 0)
                    {
                        var FirstRow = TableData.First();

                        var ColumnsName = (from pro in FirstRow.GetType().GetProperties()
                                           select pro.Name).ToList();
                        return (new JavaScriptSerializer().Serialize(ColumnsName));
                     
                    }
                    else
                    {
                        val = "No";
                        return val;
                    }
                }
                if (Tag.Equals("SampleView"))
                {
                    var TableData = db.sp_Sample_View().ToList();
                    if (TableData.Count != 0)
                    {
                        var FirstRecord = TableData.First();

                        var ColumnNames = (from pro in FirstRecord.GetType().GetProperties()
                                           select pro.Name).ToList();

                        return (new JavaScriptSerializer().Serialize(ColumnNames));
                    }

                    else
                    {
                        val = "No";
                        return val;
                    }
                }
                return val;
        
         
        }
       


        [WebMethod]
        public static bool proceed(string testStatus, string[][] dataList)
        {
            bool status = false;

            #region'Pending'
            if (testStatus == "Pending")
            {
                for (int i = 0; i < dataList.Length; i++)
                {
                    if (dataList[i] != null)
                    {
                        string testDetailID = dataList[i][0].ToString().Trim();
                        string dispatchDate = dataList[i][1].ToString().Trim();
                        string receivedDate = dataList[i][2].ToString().Trim();

                        string[] dDate = dispatchDate.Split('/');
                        string[] rDate = receivedDate.Split('/');

                        dispatchDate = dDate[2] + "-" + dDate[1] + "-" + dDate[0];
                        receivedDate = rDate[2] + "-" + rDate[1] + "-" + rDate[0];

                        using (DataBaseDataContext db = new DataBaseDataContext())
                        {
                            Lab_Test_Detail ltd = new Lab_Test_Detail();
                            ltd = (from p in db.Lab_Test_Details where p.Lab_Test_Detail_ID == int.Parse(testDetailID) select p).FirstOrDefault();
                            ltd.Dispatch_Date = Convert.ToDateTime(dispatchDate);
                            ltd.Received_Date = Convert.ToDateTime(receivedDate);

                            db.SubmitChanges();
                        }
                    }
                }
            }
            #endregion

            #region'Dispatched Test List'
            else if (testStatus == "DispatchedTestList")
            {
                for (int i = 0; i < dataList.Length; i++)
                {
                    string testDetailID = dataList[i][0].ToString().Trim();
                    using (DataBaseDataContext db = new DataBaseDataContext())
                    {
                        Lab_Test_Detail ltd = new Lab_Test_Detail();
                        ltd = (from p in db.Lab_Test_Details where p.Lab_Test_Detail_ID == int.Parse(testDetailID) select p).FirstOrDefault();
                        ltd.Received = true;
                        db.SubmitChanges();
                    }
                }
            }
            #endregion

            return status;
        }
        [WebMethod]
        public static string btnsearch(int patient_No)
        {
            
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var gettime = db.sp_OutSourceTestList(patient_No);
               
                return (new JavaScriptSerializer().Serialize(gettime));
           
            }
           
        }
        [WebMethod]
        public static string GetData(string Tag)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())

            {
                if (Tag.Equals("SampleView"))
                {
                    JavaScriptSerializer serl = new JavaScriptSerializer();
                    serl.MaxJsonLength = 2147483647;
                    var TableData = db.sp_Sample_View().ToList();
                    return (serl.Serialize(TableData));
                }
               
                if (Tag.Equals("OutSourceTestStatusList"))
                {
                    var TableData = db.sp_OutSourceTestList2().ToList();
                    return (new JavaScriptSerializer().Serialize(TableData));
                }
               

                return "";
            }
        }

        //
        [WebMethod]
        public static bool DeleteRecord(int ID, string Tag)
        {
            var isDelete = false;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                if (Tag.Equals("SampleView"))
                {
                    var SampleMaster = (from SM in db.Sample_Masters
                                        where SM.Sample_ID == ID
                                        select SM).FirstOrDefault();

                    db.Sample_Masters.DeleteOnSubmit(SampleMaster);

                    var SampleDetail = (from SD in db.Sample_Details
                                        where SD.Sample_ID == ID
                                        select SD).ToList();

                    db.Sample_Details.DeleteAllOnSubmit(SampleDetail);
                    db.SubmitChanges();
                    isDelete = true;

                }
                
                       
                        return isDelete;
                    }
                  return isDelete;
                
            }
        }
    }

