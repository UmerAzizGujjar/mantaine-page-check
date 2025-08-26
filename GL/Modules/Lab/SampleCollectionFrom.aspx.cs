using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class SampleCollectionFrom : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static String GetPatient(int PatientID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var PatientDetail = db.sp_GetPatientByID(PatientID).ToList();
                return (new JavaScriptSerializer()).Serialize(PatientDetail);
            }
        }

        [WebMethod]
        public static string GetPatientInfo(int PatientID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var PatientDetail = (from p in db.Reg_patients where p.pat_id == PatientID select p).FirstOrDefault();
                return (new JavaScriptSerializer()).Serialize(PatientDetail);
            }
        }
        [WebMethod]
        public static string LoadPatRange()
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var dpt = (from d in db.DataValues
                       join v in db.ValueSets
                       on d.ValueSet_ID equals v.ValueSet_ID
                       where v.ValueSet_Name == "Test Patient Types"
                       select new
                       {
                           d.DataValue_Name,
                           d.DataValue_Description
                       }).ToList();

            return (new JavaScriptSerializer().Serialize(dpt));
        }



        [WebMethod]
        public static string PendingSampleList()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var TableData = db.sp_GetPenidngSample_List().ToList();
            return (new JavaScriptSerializer().Serialize(TableData));


        }
        [WebMethod]
        public static String GetTestDetail(int MRNo, int[] Ids)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                //To convert list of int in string to pass store procedure
                string TempArray = String.Empty;
                for (int i = 0; i < Ids.Length; i++)
                {
                    if (i == 0)
                        TempArray = Ids[i] + "";
                    else
                        TempArray = TempArray + "," + Ids[i];
                }

               

                var TestDetail = db.sp_GetTestDetail(MRNo, TempArray).ToList();

                return (new JavaScriptSerializer()).Serialize(TestDetail);
            }

        }

        [WebMethod]
        public static String GetPatientDep(int PateintNo)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
               
                string PatientDep = DBClass.getField("select dbo.getPatientMain_Category(" + PateintNo + ")");
               

                return (new JavaScriptSerializer().Serialize(PatientDep));
            }
        }

        [WebMethod]
        public static String GetSampleSequenceId()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var Y = DateTime.Now.Year;
                var SampleNo = DBClass.getField("select isnull(max(Sample_ID),0) + 1 from Sample_Master where year(Sample_Collected_Date) = " + Y + "");

                return (new JavaScriptSerializer()).Serialize(Convert.ToInt32(SampleNo));
            }
        }

        [WebMethod]
        public static String GetSampleNo()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var SampleNo = db.Sample_Masters.DefaultIfEmpty().Max(p => p == null ? 0 : p.Sample_No + 1);
               

                if (SampleNo == 0)
                {
                    SampleNo = 1;
                }
               

                return (new JavaScriptSerializer()).Serialize(SampleNo);
            }
        }

        [WebMethod]
        public static String GetEmployeeNames()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var EmployeeNames = (from e in db.HR_Employees
                                     where e.IsDoctor == true
                                     select new
                                     {
                                         e.Emp_ID,
                                         e.Emp_Name

                                     }).ToList();

                return (new JavaScriptSerializer()).Serialize(EmployeeNames);
            }


        }

        [WebMethod]
        public static String SaveTest(DateTime CollectedDate,string ddlPat_type, /*DateTime ResultDate,*/ int PatientID, string[][] SaveCheckedTest, int EmployeeID, string[][] rem)
        {
            
            var sampleid = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var SampleNo = db.Sample_Masters.DefaultIfEmpty().Max(p => p == null ? 0 : p.Sample_No + 1);
               
                if (SampleNo == 0)
                {
                    SampleNo = 1;
                }
                Sample_Master SMObj = new Sample_Master()
                {
                    Sample_No = SampleNo,
                    patient_type_range = ddlPat_type,
                    Sample_Collected_Date = CollectedDate,
                    Patient_ID = PatientID,
                    Collected_Emp_ID = EmployeeID,
                    Created_By = AppConfig.UserID,
                    Created_Time = DateTime.Now
                };

                for (int i = 0; i < SaveCheckedTest.Length; i++)
                {
                    #region 'Comment Aera'
                    //for (int b = 0; b < rem.Length; b++)
                    //{
                    //    var Gener = (from lb in db.Lab_Tests
                    //                 where lb.Test_ID == Convert.ToInt32(SaveCheckedTest[i][1])
                    //                 select lb.Genre).FirstOrDefault();

                    //    if (Gener == null)
                    //    {
                    //        Gener = "0";
                    //    }

                    //    Sample_Detail SDObj = new Sample_Detail()
                    //    {
                    //        Test_ID = Convert.ToInt32(SaveCheckedTest[i][1]),
                    //        //Test_Detail_ID = Convert.ToInt32(SampleCollected[i][1]),
                    //        Bill_Detail_ID = Convert.ToInt32(SaveCheckedTest[i][2]),
                    //        Dept = SaveCheckedTest[i][3],
                    //        //Sample_Collected = true,
                    //        Genre = Gener,
                    //        Qty = SaveCheckedTest[i][5],

                    //        Remarks = rem[b][0].ToString(),
                    //        Sample_Collected = System.Convert.ToBoolean(rem[b][1]),

                    //    };

                    //    SMObj.Sample_Details.Add(SDObj);
                    //}
                    #endregion

                    var Gener = (from lb in db.Lab_Tests
                                 where lb.Test_ID == Convert.ToInt32(SaveCheckedTest[i][1])
                                 select lb.Genre).FirstOrDefault();

                    if (Gener == null)
                    {
                        Gener = "0";
                    }

                    Sample_Detail SDObj = new Sample_Detail()
                    {
                        Test_ID = Convert.ToInt32(SaveCheckedTest[i][1]),
                       
                        Bill_Detail_ID = Convert.ToInt32(SaveCheckedTest[i][2]),
                        Dept = SaveCheckedTest[i][3],
                      
                        Genre = Gener,
                        Qty = SaveCheckedTest[i][5],

                        Remarks = rem[i][0].ToString(),
                        Sample_Collected = System.Convert.ToBoolean(rem[i][1]),

                    };

                    SMObj.Sample_Details.Add(SDObj);
                }

                

                db.Sample_Masters.InsertOnSubmit(SMObj);
                try
                {
                    db.SubmitChanges();
                    sampleid = Convert.ToString(SMObj.Sample_ID);
                }
                catch (Exception ex)
                {
                    return "Problem in save tests";
                }

                return "Save-" + sampleid;
            }
        }
        [WebMethod]
        public static String GetTestDetailBill(int BillId, int[] Ids)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                
                string TempArray = String.Empty;
                for (int i = 0; i < Ids.Length; i++)
                {
                    if (i == 0)
                        TempArray = Ids[i] + "";
                    else
                        TempArray = TempArray + "," + Ids[i];
                }



                var TestDetail = db.sp_GetTestDetailBill(BillId, TempArray).ToList();

                return (new JavaScriptSerializer()).Serialize(TestDetail);
            }

        }
        [WebMethod]
        public static String UpdateTest(DateTime CollectedDate,string ddlPat_type, string[][] SaveCheckedTest, int EmployeeID, int SampleID, string[][] rem)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var SampleMaster = (from SM in db.Sample_Masters
                                    where SM.Sample_ID == SampleID
                                    select SM).FirstOrDefault();

                SampleMaster.Sample_Collected_Date = CollectedDate;
                SampleMaster.Collected_Emp_ID = EmployeeID;
                SampleMaster.patient_type_range = ddlPat_type;
                SampleMaster.Updated_By = AppConfig.UserID;
                SampleMaster.Updated_Time = DateTime.Now;

                

                var SampleDetail = (from SD in db.Sample_Details
                                    where SD.Sample_ID == SampleID
                                    select SD).ToList();

                db.Sample_Details.DeleteAllOnSubmit(SampleDetail);

               

                for (int i = 0; i < SaveCheckedTest.Length; i++)
                {
                   
                        var Gener = (from lb in db.Lab_Tests
                                     where lb.Test_ID == Convert.ToInt32(SaveCheckedTest[i][1])
                                     select lb.Genre).ToList();


                        Sample_Detail SDObj = new Sample_Detail()
                        {
                            Test_ID = Convert.ToInt32(SaveCheckedTest[i][1]),
                           
                            Bill_Detail_ID = Convert.ToInt32(SaveCheckedTest[i][2]),
                            Dept = SaveCheckedTest[i][3],
                           
                            Genre = string.Empty,
                            Qty = SaveCheckedTest[i][5],

                            Remarks = rem[i][0].ToString(),
                            Sample_Collected = System.Convert.ToBoolean(rem[i][1]),
                        };

                        SampleMaster.Sample_Details.Add(SDObj);
                    
                }

                try
                {
                    db.SubmitChanges();
                    return "Update";
                }
                catch (Exception ex)
                {
                    return (new JavaScriptSerializer().Serialize(ex.Message));
                }
            }
        }
        [WebMethod]
        public static string GetSampleCode(int SampleID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            string billid = DBClass.getField(" select Bill_Detail_ID from Sample_Detail where Sample_ID='" + SampleID + "'");
            var sampleCode = db.getSampleIdentity(Convert.ToInt32(billid));
            return sampleCode;



        }
        [WebMethod]
        public static String LoadSampleHeader(int SampleID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                try
                {
                    var SampleHeader = db.sp_Sample_Header_Load(SampleID).ToList();
                    return (new JavaScriptSerializer().Serialize(SampleHeader));
                }
                catch (Exception ex)
                {
                    return (new JavaScriptSerializer().Serialize(ex.Message));
                }
            }
        }

        [WebMethod]
        public static String LoadSampleDetail(int SampleID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                try
                {
                    var SampleDetail = db.sp_Sample_Detail_Load(SampleID).ToList();
                    return (new JavaScriptSerializer().Serialize(SampleDetail));
                }
                catch (Exception ex)
                {
                    return (new JavaScriptSerializer().Serialize(ex.Message));
                }
            }
        }
    }
}