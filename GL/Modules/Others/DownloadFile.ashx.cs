using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;

namespace PMS
{
    /// <summary>
    /// Summary description for DownloadFile
    /// </summary>
    public class DownloadFile : IHttpHandler
    {
        public void ProcessRequest(HttpContext context)
        {
            // Get the ID from the query string
            string id = context.Request.QueryString["ID"];

            // Validate the ID (e.g., check for null or empty)
            if (string.IsNullOrEmpty(id))
            {
                context.Response.StatusCode = 400; // Bad Request
                context.Response.Write("ID parameter is missing or invalid.");
                return;
            }

            // Assuming you have a method to retrieve the file path based on the ID
            string filePath = GetFilePathByID(id);

            if (string.IsNullOrEmpty(filePath))
            {
                context.Response.StatusCode = 404; // Not Found
                context.Response.Write("File not found.");
                return;
            }

            try
            {
                // Transmit the file to the client
                context.Response.ContentType = "application/octet-stream";
                context.Response.AddHeader("Content-Disposition", "attachment; filename=\"" + Path.GetFileName(filePath) + "\"");
                context.Response.TransmitFile(filePath);
            }
            catch (Exception ex)
            {
                context.Response.StatusCode = 500; // Internal Server Error
                context.Response.Write("An error occurred while downloading the file: " + ex.Message);
            }
        }

        private string GetFilePathByID(string id)
        {
            // Perform a database query to retrieve the file path based on the provided ID
            // string connectionString = "ASPGLConnectionString";
            string connectionString = ConfigurationManager.ConnectionStrings["ASPGLConnectionString"].ConnectionString;
            string query = "SELECT PDF_File FROM Out_Patient WHERE Out_Patient_ID = " + id;

            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                SqlCommand command = new SqlCommand(query, connection);
                command.Parameters.AddWithValue("@ID", id);

                connection.Open();
                object result = command.ExecuteScalar();

                // Check if the result is null
                if (result != null)
                {
                    // Convert the result to a string and return it
                    return result.ToString();
                }
                else
                {
                    // Return null if the ID is not found
                    return null;
                }
            }
        }


        public bool IsReusable
        {
            get { return false; }
        }
    }
}