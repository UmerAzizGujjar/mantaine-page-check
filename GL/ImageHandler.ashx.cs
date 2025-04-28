using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

namespace PMS
{
    /// <summary>
    /// Summary description for ImageHandler
    /// </summary>
    public class ImageHandler : IHttpHandler
    {

        public void ProcessRequest(HttpContext context)
        {
            byte[] buffer = null;
            string querySqlStr = "";
            if (context.Request.QueryString["ID"] != null)
            {
                querySqlStr = "select * from sys_Companys where company_ID=" + context.Request.QueryString["ID"];
            }
            else
                return;
            SqlConnection con = new SqlConnection(DBClass.ConnectionString());
            SqlCommand cmd = new SqlCommand(querySqlStr, con);
            SqlDataReader reader = null;
            try
            {
                con.Open();
                reader = cmd.ExecuteReader();
                while (reader.Read())
                {                  
                    buffer = (byte[])reader["Company_Image"];
                    context.Response.Clear();
                    context.Response.BinaryWrite(buffer);
                    context.Response.Flush();
                    context.Response.Close();
                }
                reader.Close();
            }
            finally
            {
                con.Close();
            }
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