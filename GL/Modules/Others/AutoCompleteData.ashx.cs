using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI.MobileControls;

namespace PMS
{
    /// <summary>
    /// Summary description for AutoCompleteData
    /// </summary>
    public class AutoCompleteData : IHttpHandler
    {

        public void ProcessRequest(HttpContext context)
        {
            // Note the query strings passed by jquery autocomplete:
            //QueryString: {q=a&limit=150&timestamp=1227198175320}


        }
        public List<sys_Company> FetchTagList(string SearchText)
        {
            SqlConnection con = new SqlConnection(DBClass.ConnectionString());
            DataSet ds = new DataSet();
            DataTable dt = new DataTable();
            string query = "select * from sys_Company Where Company_Name like '@myParameter'";
            SqlCommand cmd = new SqlCommand(query, con);
            cmd.Parameters.AddWithValue("@myParameter", "%" + SearchText + "%");
            try
            {
                con.Open();
                cmd.ExecuteNonQuery();
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                da.Fill(ds);
            }
            catch (SqlException excp)
            {

            }
            finally
            {
                con.Close();
            }
            dt = ds.Tables[0];

            List<sys_Company> Items = new List<sys_Company>();

            sys_Company obj;

            foreach (DataRow row in dt.Rows)
            {
                obj = new sys_Company();
                //String From DataBase(dbValues)
                obj.Company_Name = row["Company_Name"].ToString();
                obj.Company_ID = Convert.ToInt32(row["Company_ID"].ToString());

                Items.Add(obj);
            }
            return Items;
        } 
        public bool IsReusable
        {
            get
            {
                return false;
            }
        }
    }
}