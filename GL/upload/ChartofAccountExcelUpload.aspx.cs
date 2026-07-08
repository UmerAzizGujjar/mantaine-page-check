using System.IO;
using System.Data;
using System.Data.OleDb;
using System.Data.SqlClient;
using System.Configuration;
using System;
using System.Web.UI;
namespace PMS
{
    public partial class ChartofAccountExcelUpload : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }
        protected void btnUpload_Click(object sender, EventArgs e)
        {
            if (!FileUpload.HasFile)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('Please select a file to upload.');", true);
                return;
            }

            string consString = ConfigurationManager.ConnectionStrings["ASPGLConnectionString"].ConnectionString;
            using (SqlConnection con = new SqlConnection(consString))
            {
                con.Open();
                SqlTransaction transaction = con.BeginTransaction();
                try
                {
                    // Delete existing accounts
                    using (SqlCommand cmd = new SqlCommand("DELETE FROM dbo.Gl_Accounts", con, transaction))
                    {
                        cmd.ExecuteNonQuery();
                    }

                    // Save uploaded file
                    string uploadDir = Server.MapPath("~/upload/UploadCA/");
                    if (!Directory.Exists(uploadDir))
                    {
                        Directory.CreateDirectory(uploadDir);
                    }
                    string excelPath = uploadDir + Path.GetFileName(FileUpload.PostedFile.FileName);
                    FileUpload.SaveAs(excelPath);

                    // Get connection string based on file extension
                    string extConString = string.Empty;
                    string extension = Path.GetExtension(FileUpload.PostedFile.FileName);
                    switch (extension)
                    {
                        case ".xls":
                            extConString = ConfigurationManager.ConnectionStrings["Excel03ConString"].ConnectionString;
                            break;
                        case ".xlsx":
                            extConString = ConfigurationManager.ConnectionStrings["Excel07+ConString"].ConnectionString;
                            break;
                        default:
                            throw new Exception("Unsupported file format. Please upload .xls or .xlsx file.");
                    }
                    extConString = string.Format(extConString, excelPath);

                    // Read Excel data
                    DataTable dtExcelData = new DataTable();
                    using (OleDbConnection excel_con = new OleDbConnection(extConString))
                    {
                        excel_con.Open();
                        string sheet1 = excel_con.GetOleDbSchemaTable(OleDbSchemaGuid.Tables, null).Rows[0]["TABLE_NAME"].ToString();
                        using (OleDbCommand cmd = new OleDbCommand($"SELECT * FROM [{sheet1}]", excel_con))
                        {
                            using (OleDbDataReader reader = cmd.ExecuteReader())
                            {
                                dtExcelData.Load(reader);
                            }
                        }
                    }

                    // Insert data using the same connection and transaction
                    int bookId = AppConfig.Book_ID;
                    var createdBy = AppConfig.UserID;
                    DateTime creationTime = DateTime.Now;

                    foreach (DataRow row in dtExcelData.Rows)
                    {
                        using (SqlCommand cmd = new SqlCommand("INSERT INTO dbo.Gl_Accounts (Account_Code, Account_Serial, Account_Name, Levels, Active, Cash, Bank, Book_ID, Created_By, Created_Time) " +
                                                               "VALUES (@Account_Code, @Account_Serial, @Account_Name, @Levels, @Active, @Cash, @Bank, @Book_ID, @Created_By, @Created_Time)", con, transaction))
                        {
                            cmd.Parameters.AddWithValue("@Account_Code", row["Account_Code"]?.ToString().Trim());
                            cmd.Parameters.AddWithValue("@Account_Serial", row["Account_Serial"]);
                            cmd.Parameters.AddWithValue("@Account_Name", row["Account_Name"]);
                            cmd.Parameters.AddWithValue("@Levels", Convert.ToInt32(row["Levels"]));
                            cmd.Parameters.AddWithValue("@Active", Convert.ToBoolean(Convert.ToInt32(row["Active"])));
                            cmd.Parameters.AddWithValue("@Cash", Convert.ToBoolean(Convert.ToInt32(row["Cash"])));
                            cmd.Parameters.AddWithValue("@Bank", Convert.ToBoolean(Convert.ToInt32(row["Bank"])));
                            cmd.Parameters.AddWithValue("@Book_ID", bookId);
                            cmd.Parameters.AddWithValue("@Created_By", createdBy);
                            cmd.Parameters.AddWithValue("@Created_Time", creationTime);
                            cmd.ExecuteNonQuery();
                        }
                    }

                    // Set parent codes using the same connection and transaction
                    using (SqlCommand cmd = new SqlCommand(@"
                        UPDATE c SET Parent_Code = cte.rn
                        FROM dbo.Gl_Accounts c
                        INNER JOIN (
                            SELECT Account_ID, ROW_NUMBER() OVER (ORDER BY Account_ID) AS rn
                            FROM dbo.Gl_Accounts WHERE Levels = 1
                        ) cte ON c.Account_ID = cte.Account_ID
                        WHERE c.Levels = 1", con, transaction))
                    {
                        cmd.ExecuteNonQuery();
                    }

                    using (SqlCommand cmd = new SqlCommand(@"
                        UPDATE c SET c.Parent_Code = p.Account_ID
                        FROM dbo.Gl_Accounts c
                        INNER JOIN dbo.Gl_Accounts p ON p.Levels = 1 AND c.Account_Code LIKE p.Account_Code + '%'
                        WHERE c.Levels = 2", con, transaction))
                    {
                        cmd.ExecuteNonQuery();
                    }

                    using (SqlCommand cmd = new SqlCommand(@"
                        UPDATE c SET c.Parent_Code = p.Account_ID
                        FROM dbo.Gl_Accounts c
                        INNER JOIN dbo.Gl_Accounts p ON p.Levels = 2 AND c.Account_Code LIKE p.Account_Code + '%'
                        WHERE c.Levels = 3", con, transaction))
                    {
                        cmd.ExecuteNonQuery();
                    }

                    using (SqlCommand cmd = new SqlCommand(@"
                        UPDATE c SET c.Parent_Code = p.Account_ID
                        FROM dbo.Gl_Accounts c
                        INNER JOIN dbo.Gl_Accounts p ON p.Levels = 3 AND c.Account_Code LIKE p.Account_Code + '%'
                        WHERE c.Levels = 4", con, transaction))
                    {
                        cmd.ExecuteNonQuery();
                    }

                    transaction.Commit();
                    Response.Redirect("~/Modules/Gl/ChartofAccounts.aspx", false);
                }
                catch (Exception ex)
                {
                    transaction.Rollback();
                    ScriptManager.RegisterStartupScript(this, GetType(), "alert", $"alert('Error uploading file: {ex.Message.Replace("'", "\\'")}');", true);
                }
            }
        }
        protected void btnDownloadSample_Click(object sender, EventArgs e)
        {
            string filePath = Server.MapPath("~/upload/ExcelUploadSamples/COAExcelUploadSample.xlsx");
            FileInfo file = new FileInfo(filePath);

            if (file.Exists)
            {
                Response.Clear();
                Response.AddHeader("Content-Disposition", "attachment; filename=" + file.Name);
                Response.AddHeader("Content-Length", file.Length.ToString());
                Response.ContentType = "application/octet-stream";
                Response.WriteFile(file.FullName);
                Response.End();
            }
            else
            {
                Response.Write("<script>alert('Chart of Account Upload Sample File Not Found.');</script>");
            }
        }
    }
}
