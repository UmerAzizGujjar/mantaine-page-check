using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Data.OracleClient;
using System.Net;
using System.IO;
using System.Text;
using DB;
/// <summary>
/// Summary description for Class1
/// </summary>
/// 
namespace PMS
{
    public static class DBClass
    {
        public static string Maskings;
        private static DataBaseDataContext dbContext = new DataBaseDataContext();
        public static DataTable getDataTable(string strSQL)
        {
            try
            {
                DataTable dt = new DataTable();
                SqlDataAdapter da = new SqlDataAdapter(strSQL, ConnectionString());
                da.SelectCommand.CommandTimeout = 999999999;
                da.Fill(dt);
                return dt;
            }
            catch (Exception ex)
            {

                throw ex;
            }

        }

        public static string getParameter(string ParameterName)
        {
            string ParameterValue = getField("Select code from sys_parms where company_id=" + AppConfig.Company_ID + " and Name='" + ParameterName + "'").ToString();
            return ParameterValue;
        }
        public static string GetInPatientIdBy_PatientId(int PatientID)
        {
            return getField("select In_Patient_ID from In_Patient where Patient_ID = " + PatientID);
        }
        public static int Getpatid_by_PatientID_reg(int Reg_Patient_ID)
        {
            if (Reg_Patient_ID != 0)
            {
                return Convert.ToInt32((getField("select p.Patient_id from Reg_patient rg inner join patients p on rg.pat_id = p.Reg_PatId left join Out_Patient op on op.Patient_ID = p.Patient_ID where rg.pat_id = " + Reg_Patient_ID + " ORDER BY p.Patient_id DESC")));
            }

            return 0;
        }   
        public static int GetMRNOBy_PatientID_reg(int Reg_Patient_ID)
        {
            if (Reg_Patient_ID != 0)
            {
                return Convert.ToInt32((getField("select Patient_No from Reg_patient where pat_id=" + Reg_Patient_ID)));
            }

            return 0;
        }
        public static int GetPat_ID_By_PatientID_reg(int Reg_Patient_ID)
        {
            if (Reg_Patient_ID != 0)
            {
                return Convert.ToInt32((getField("select pat_id from Reg_patient where pat_id=" + Reg_Patient_ID)));
            }

            return 0;
        }
        public static decimal getMedicineBatchBalance(string batchNum, string item_Code, string invOrg)
        {
            decimal stock = 0M;
            DataBaseDataContext db = new DataBaseDataContext();
            var itemId = DBClass.getField("Select Item_ID from INV_Items where Item_Code='" + item_Code + "'");
            stock = Convert.ToDecimal((batchNum == string.Empty || batchNum == "0") ? 0M : db.GetItemBatchStock(Convert.ToInt64(itemId), batchNum, invOrg));

            return stock;
        }
        public static string GetOutnPatientIdBy_PatientId(int PatientID)
        {
            return getField("select Out_Patient_ID from Out_Patient where Patient_ID = " + PatientID);
        }
        public static string getPatientLatestDepartment(int PatientNo, bool byName)
        {
            string department = string.Empty;

            department = (from p in dbContext.Patients where p.Patient_No == PatientNo orderby p.Patient_ID descending select p.Patient_Main_Category).FirstOrDefault();
            if (byName)
                department = dbContext.GetDataValueName("Patient Main Category", department).ToString();

            return department;
        }

        public static bool IsAdministrator()
        {
            string result = getField("select RoleId from aspnet_UsersInRoles where UserId = '" + AppConfig.UserID.ToString() + "' and RoleId in (select RoleId from aspnet_Roles where rolename = 'administrator')");
            if (result != "There is no row at position 0.")
                return true;
            else
                return false;
        }

        internal static bool exectueQueryWithTransaction(string strSQL, SqlTransaction tranObj, SqlConnection con)
        {
            int queryResult = 0;
            SqlCommand sqlcmd = new SqlCommand(strSQL, con);
          
            sqlcmd.Transaction = tranObj;
            queryResult = sqlcmd.ExecuteNonQuery();
            return queryResult > 0;
        }


       


        public static string getField(string strSQL)
        {
            try
            {
                string sReturnVal;
                DataTable dt = new DataTable();
                SqlDataAdapter da = new SqlDataAdapter(strSQL, ConnectionString());
                da.Fill(dt);
                sReturnVal = dt.Rows[0][0].ToString();
                return sReturnVal;
            }
            catch (Exception exc)
            {

                return exc.Message;
            }

        }


        public static string newgetField(string strSQL, int count)
        {
            try
            {
                string sReturnVal;
                DataTable dt = new DataTable();
                SqlDataAdapter da = new SqlDataAdapter(strSQL, ConnectionString());
                da.Fill(dt);
                sReturnVal = dt.Rows[count][0].ToString();
                return sReturnVal;
            }
            catch (Exception exc)
            {

                return exc.Message;
            }

        }


        public static int ExecuteNonQuerySCOPE_IDENTITY(string strSQL, SqlTransaction tranObj, SqlConnection con)
        {
            int result = 0;
            SqlCommand Comm = new SqlCommand(strSQL, con);
            Comm.Transaction = tranObj;
            Comm.CommandText = strSQL;
            result = Convert.ToInt32(Comm.ExecuteScalar());
            return result;
        }
        public static int exectueQueryWithParms(SqlParameter[] sqlparms, string strSQL)
        {

            int queryResult = 0;
            SqlConnection con = new SqlConnection(ConnectionString());
            SqlCommand sqlcmd = new SqlCommand(strSQL, con);
            sqlcmd.Parameters.AddRange(sqlparms);
            con.Open();
            queryResult = sqlcmd.ExecuteNonQuery();
            con.Close();
            return queryResult;
              
        }
    
        public static SqlDataReader dataReader(string strSQL)
        {
            SqlDataReader sdr;
            SqlConnection con = new SqlConnection(ConnectionString());
            con.Open();
            SqlCommand cmd = new SqlCommand(strSQL, con);
            sdr = cmd.ExecuteReader();
            con.Close();
            return sdr;
        }
        public static string ConnectionString()
        {
            string constring = ConfigurationManager.ConnectionStrings["ASPGLConnectionString"].ConnectionString;
            return constring;
        }
        public static string OracleConnectionString()
        {
            string constring = ConfigurationManager.ConnectionStrings["ERPConnectionString"].ConnectionString;
            return constring;
        }
        public static string OracleConnectionTest()
        {
            try
            {
                OracleConnection con = new OracleConnection(OracleConnectionString());
                con.Open();
                con.Close();
                return "";  //connection openned successfully 

            }
            catch (Exception exc)
            {
                return exc.Message;
            }

        }

        public static string OracleExecuteQuery(string sql)
        {
            string returnVal = "";
            OracleConnection con = new OracleConnection(OracleConnectionString());
            con.Open();
            OracleCommand cmd = new OracleCommand(sql, con);

            OracleParameter outParam = new OracleParameter();
            outParam.ParameterName = ":LASTID";
            outParam.Direction = ParameterDirection.Output;
            outParam.Size = 20;
            cmd.Parameters.Add(outParam);

            cmd.ExecuteNonQuery();
            returnVal = outParam.Value.ToString();
            con.Close();
            return returnVal;
        }
        public static DataTable OracleGetDataTable(string sql)
        {
            DataTable dt = new DataTable();
            OracleDataAdapter da = new OracleDataAdapter(sql, OracleConnectionString());
            da.SelectCommand.CommandTimeout = 999999999;
            da.Fill(dt);
            return dt;
        }
        public static int OracleGLAccountID(string AccountCode)
        {
            int returnVal = 0;
            DataTable dt = new DataTable();
            string sql = "SELECT CHART_OF_ACCOUNT_ID FROM GL_CHART_OF_ACCOUNTS WHERE CHART_OF_ACCOUNT_CODE='" + AccountCode + "'";
            OracleDataAdapter da = new OracleDataAdapter(sql, OracleConnectionString());
            da.SelectCommand.CommandTimeout = 999999999;
            da.Fill(dt);

            if (dt.Rows.Count != 0)
            {
                returnVal = Convert.ToInt32(dt.Rows[0][0].ToString());
            }
            return returnVal;
        }
        public static object GetValueSet(string ValueSetName)
        {
            DataBaseDataContext db = new DataBaseDataContext(ConnectionString());
            var qry = from d in db.DataValues
                      join v in db.ValueSets on
                      d.ValueSet_ID equals v.ValueSet_ID
                      where v.ValueSet_Name == ValueSetName && (d.System_Value == false || d.System_Value == null)
                      select new { d.DataValue_Name, d.DataValue_Description };
            return qry;
        }
        public static int GetPatientID(string PatientNo)
        {
            string sSQL = "";
            DataTable dt;
            sSQL = "Select Patient_ID from Patients Where Patient_No='" + PatientNo + "'";
            dt = getDataTable(sSQL);
            if (dt.Rows.Count == 0)
                return -1;
            else
                return Convert.ToInt32(dt.Rows[0]["Patient_ID"]);
        }
        public static DataTable ConvertToDataTable(DataBaseDataContext db, object LinqQuery)
        {
            SqlCommand command = db.GetCommand(LinqQuery as IQueryable) as SqlCommand;
            DataTable dt = new DataTable();
            SqlDataAdapter da = new SqlDataAdapter(command);
            da.Fill(dt);
            return dt;
        }
        //public static int GetNewVoucherNo(string voucherType, DateTime voucherDate)
        //{
        //    int number;
        //    string strSQL = "Select Isnull(Max(Voucher_No)+1,1) From GL_Vouchers Where Voucher_Type='" + voucherType + "' and Month(voucher_date)=" + voucherDate.Month + " and Year(voucher_date)=" + voucherDate.Year + " and voucher_status<>'Canceled'and Company_ID=" + AppConfig.Company_ID;
        //    number = Convert.ToInt32(getField(strSQL));
        //    return number;
        //}
        public static int GetNewVoucherNo(string voucherType, DateTime voucherDate)
        {
            using (SqlConnection con = new SqlConnection(DBClass.ConnectionString()))
            {
                con.Open();
                string strSQL = "SELECT dbo.GetNewVoucherNo(@voucherType, @voucherDate)";
                using (SqlCommand cmd = new SqlCommand(strSQL, con))
                {
                    cmd.Parameters.AddWithValue("@voucherType", voucherType);
                    cmd.Parameters.AddWithValue("@voucherDate", voucherDate.Date);

                    object result = cmd.ExecuteScalar();

                    if (result == null || result == DBNull.Value)
                        return 1;

                    return Convert.ToInt32(result);
                }
            }
        }
        public static int GetNewSalesOrPurchaseVoucherNo(string voucherType, DateTime voucherDate)
        {
            int number;
            string strSQL = "Select Isnull(Max(Voucher_No)+1,1) From GL_Vouchers Where Voucher_Type='" + voucherType + "' and Year(voucher_date)=" + voucherDate.Year + " and voucher_status<>'Canceled' and Company_ID=" + AppConfig.Company_ID;
            number = Convert.ToInt32(getField(strSQL));
            return number;
        }
        public static int GetNewInvoiceNo()
        {
            int number;
            string strSQL = "Select Isnull(Max(Invoice_No)+1,1) From AR_Sales  where Company_ID=" + AppConfig.Company_ID;
            number = Convert.ToInt32(getField(strSQL));
            return number;
        }
        public static int GetNewPurchasesNo()
        {
            int number;
            string strSQL = "Select Isnull(Max(Purchases_No)+1,1) From AP_Purchases where Company_ID=" + AppConfig.Company_ID;
            number = Convert.ToInt32(getField(strSQL));
            return number;
        }
        public static int GetNewPaymentNo()
        {
            int number;
            string strSQL = "Select Isnull(Max(Payment_No)+1,1) From Plot_Payments";
            number = Convert.ToInt32(getField(strSQL));
            return number;
        }
        public static int GetNewReceiptNo()
        {
            int number;
            string strSQL = "Select Isnull(Max(Receipt_No)+1,1) From Plot_Receipts";
            number = Convert.ToInt32(getField(strSQL));
            return number;
        }
        public static int GetNewNumber(string columnName, string tableName, string condition)
        {
            int number;
            string strSQL = "select case when (max(convert(int,isnull(" + columnName + ",0)))+1) is null then 1 else (max(convert(int,isnull(" + columnName + ",0)))+1) end As NewNo From " + tableName + " " + condition;
            number = Convert.ToInt32(getField(strSQL));
            return number;
        }
      
        internal static bool exectueQuery(string strSQL, SqlTransaction tranObj, SqlConnection con)
        {
            int queryResult = 0;
            SqlCommand sqlcmd = new SqlCommand(strSQL, con);
            sqlcmd.Transaction = tranObj;
            queryResult = sqlcmd.ExecuteNonQuery();
            return queryResult > 0;
        }
        public static string DataBaseName()
        {
            string dbName = "";
            string ConnectionString = DBClass.ConnectionString();
            SqlConnectionStringBuilder builder = new SqlConnectionStringBuilder(ConnectionString);
            return dbName = builder.InitialCatalog;
        }
        public static String GetPeriod_ID(DateTime selectedDate)
        {
            string periodID = getField("select period_id from gl_periods where company_id=" + AppConfig.Company_ID + " and '" + selectedDate + "' between period_start_date and period_end_date and period_closed='False'").ToString();
            return periodID;
        }
        public static int executeNonQueryWithoutBegin(string sSql)
        {
            SqlConnection con = new SqlConnection(ConnectionString());
            con.Open();
            int result = 0;
            try
            {
                SqlCommand Comm = con.CreateCommand();
                Comm.CommandText = sSql;
                Comm.CommandTimeout = 280;
                result = Comm.ExecuteNonQuery();

            }
            catch (Exception e)
            {
                throw new Exception(e.Message);
            }
            finally
            {
                con.Dispose();
            }
            return result;
        }

        public static System.Data.DataSet GetDataSet(string sSql, string sTableName, DataSet ds)
        {
            SqlDataAdapter da = new SqlDataAdapter(sSql, ConnectionString());
            try
            {
                if (sTableName == null)
                    da.Fill(ds);
                else
                    da.Fill(ds, sTableName);
            }
            catch (Exception ex)
            {

            }
            return ds;
        }

        public static int GetMRNOBy_PatientID(int PatientID)
        {
            if (PatientID != 0)
            {
                return Convert.ToInt32((getField("select Patient_No from patients where patient_id=" + PatientID)));
            }

            return 0;
        }
        public static int GetMRNOBy_RegID(int PatientID)
        {
            if (PatientID != 0)
            {
                return Convert.ToInt32((getField("select Patient_No from Reg_patient where pat_id=" + PatientID)));
            }

            return 0;
        }
        public static int GetMRNOBy_RgPatientID(int PatientID)
        {
            if (PatientID != 0)
            {
                return Convert.ToInt32((getField("select rp.Patient_No from patients p join Reg_patient rp  on p.Reg_PatId = rp.pat_id  where patient_id=" + PatientID)));
            }

            return 0;
        }
        public static int GetMRNOBy_PatientNo(int MRno)
        {
            return Convert.ToInt32((getField("select max(Patient_ID) from patients where Patient_No=" + MRno)));
        }
        public static int getMaxEntry_No(string tableName, string colName)
        {
            return Convert.ToInt32(getField("exec spGetMax '" + tableName + "', '" + colName + "'"));
        }
        public static bool sendSMS(string CellNumber, string SMS_Contant, out string msg, string DocumentName, string Patient_No)
        {
            var CurrentDate = DateTime.Now;
            var UserID = AppConfig.UserID;
            string session = "";
            Maskings = "AMTH.";
            bool sentStatus = false;
            string statusMsg = string.Empty;
            MyWebRequest myRequest = new MyWebRequest("https://connect.jazzcmt.com/sendsms_url.html?Username=03066402916&Password=Pakistan@123&From="+Maskings+ "&To=" + CellNumber + "&Message=" + SMS_Contant + "");
            string s = myRequest.GetResponse();
            session = s;
            if (session.Contains("Message Sent"))
            {
                sentStatus = true;
                session = "SMS Sent Successfully";
            }
            else
            {
                session = "Error";
                sentStatus = false;
            }
            msg = statusMsg;

            var Log = getField("insert into Sys_MsgLogs Values ('" + CellNumber + "',N'" + SMS_Contant + "','" + DocumentName + "','" + Patient_No + "','" + session + "','" + UserID + "','" + CurrentDate + "','" + s + "')");

            return sentStatus;

        }
      
    }
}