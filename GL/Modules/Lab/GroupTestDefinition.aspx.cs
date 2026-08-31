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
    public partial class GroupTestDefinition : System.Web.UI.Page
    {
        public bool is_admin_Test_Rate = false;
        protected void Page_Load(object sender, EventArgs e)
        {
            is_admin_Test_Rate = Convert.ToBoolean(DBClass.getField("Select AllowTestRate from aspnet_Users where UserId='" + AppConfig.UserID + "'"));
        }

        [WebMethod]
        public static string GetPatientTypes()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var PatientsCategory = (from dv in db.DataValues
                                        join vs in db.ValueSets
                                        on dv.ValueSet_ID equals vs.ValueSet_ID
                                        where vs.ValueSet_Name == "Patient Type"
                                        select new
                                        {
                                            dv.DataValue_Name,
                                            dv.DataValue_Description
                                        }).ToList();

                return (new JavaScriptSerializer()).Serialize(PatientsCategory);
            }
        }

        [WebMethod]
        public static string GetMainDepartments()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var dep = from dv in db.DataValues
                      join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                      where vs.ValueSet_Name == "Main Test Departments"
                      select new { dv.DataValue_Name, dv.DataValue_Description };

            return (new JavaScriptSerializer()).Serialize(dep);
        }
        [WebMethod]
        public static string getSavedRates(int datavalueID,string patientType)
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var d = (from t in db.Test_Defination_Detail_Rates where t.Test_ID == datavalueID && t.Patient_Type == patientType select new { t.Patient_Category, t.Test_Rate }).ToList();
                if (d != null)
                {
                    data = (new JavaScriptSerializer()).Serialize(d);
                }
            }

            return data;
        }
        [WebMethod]
        public static string GetGroupDepartments()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var dep = from dv in db.DataValues
                      join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                      where vs.ValueSet_Name == "Test Departments"
                      select new { dv.DataValue_Name, dv.DataValue_Description };

            return (new JavaScriptSerializer()).Serialize(dep);
        }
        [WebMethod]
        public static bool saveData(int datavalueID, string datavalueName, string reportColums,string Main_Department, string reporthour, string[][] ipdRates, string[][] opdRates, string addOrEdit, string reportDay,bool FixedValue, bool Resultvalue, bool ListValue, bool ReqImage,string TestDeprtment,bool chkPayment,bool chkSpecial_Test, string machineName, string standardName,decimal TestRate)
        {
            bool status = false;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                string sql = string.Empty;
                int execute = 0;
                if (addOrEdit == "EDIT")
                {
                   
                       sql = "Delete Test_Defination_Detail_Rates where Test_ID = " + datavalueID + " and isnull(isGroupTest, 0) = 1;";
                    sql += " Update DataValues set DataValue_Description = '" + datavalueName + "', Segment1 = '" + TestRate + "', Segment2 = '" + reportColums + "', Segment3 = '" + reporthour + "', Segment4 = '" + reportDay + "' , division='"+ Main_Department + "' ,Fixed_Value='" + FixedValue + "' ,Result_Value='"+ Resultvalue + "' ,List_Value='"+ ListValue + "',Required_Value='"+ ReqImage + "',Segment5='" + chkPayment + "' ,Group_Depart='" + TestDeprtment + "',Special_Test='" + chkSpecial_Test + "' , machine_name='" + machineName + "', StandardName='" + standardName + "'where Datavalue_ID = " + datavalueID + "";
                    execute = DBClass.executeNonQueryWithoutBegin(sql);
                }
                else
                {
                    string dvName = Convert.ToInt32(DBClass.getField("select max(convert(bigint,Datavalue_Name)) + 1 from DataValues where ValueSet_ID = 70 ")).ToString("000");
                    sql = "insert into DataValues (ValueSet_ID, DataValue_Name, DataValue_Description, Segment1,Segment2, Segment3, Segment4,division,Fixed_Value,Result_Value,List_Value,Required_Value,Segment5,Group_Depart,Special_Test,machine_name,StandardName) values (70, '" + dvName + "', '" + datavalueName + "','" + TestRate + "','" + reportColums + "','" + reporthour + "','" + reportDay + "','"+ Main_Department + "','"+ FixedValue + "','"+ Resultvalue + "','"+ ListValue + "','"+ ReqImage + "',  '" + chkPayment + "'  ,'" + TestDeprtment + "','" + chkSpecial_Test + "','" + machineName + "','" + standardName + "')";
                    execute = DBClass.executeNonQueryWithoutBegin(sql);
                    datavalueID = (from m in db.DataValues where m.ValueSet_ID == 70 select m.DataValue_ID).Max();
                    if (datavalueID == null)
                        datavalueID = 1;
                }

                if (execute > 0)
                {
                    for (int i = 0; i < ipdRates.Length; i++)
                    {
                        if (ipdRates[i] != null)
                        {
                            Test_Defination_Detail_Rate tdr = new Test_Defination_Detail_Rate();
                            tdr.Test_ID = datavalueID;
                            tdr.Patient_Type = "IPD";
                            tdr.Patient_Category = ipdRates[i][0].ToString();
                            tdr.Test_Rate = Convert.ToInt32(ipdRates[i][1]);
                            tdr.isGroupTest = true;
                            tdr.Created_By = AppConfig.UserID.ToString();
                            tdr.Created_Time = System.DateTime.Now;

                            db.Test_Defination_Detail_Rates.InsertOnSubmit(tdr);
                            db.SubmitChanges();
                        }
                    }

                    for (int i = 0; i < opdRates.Length; i++)
                    {
                        if (opdRates[i] != null)
                        {
                            Test_Defination_Detail_Rate tdr = new Test_Defination_Detail_Rate();
                            tdr.Test_ID = datavalueID;
                            tdr.Patient_Type = "OPD";
                            tdr.Patient_Category = opdRates[i][0].ToString();
                            tdr.Test_Rate = Convert.ToInt32(opdRates[i][1]);
                            tdr.isGroupTest = true;
                            tdr.Created_By = AppConfig.UserID.ToString();
                            tdr.Created_Time = System.DateTime.Now;

                            db.Test_Defination_Detail_Rates.InsertOnSubmit(tdr);
                            db.SubmitChanges();
                        }
                    }
                    status = true;
                }
            }
            return status;
        }
    }
}