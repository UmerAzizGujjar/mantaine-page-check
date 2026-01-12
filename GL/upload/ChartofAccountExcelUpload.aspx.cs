using System.IO;
using System.Data;
using System.Data.OleDb;
using System.Data.SqlClient;
using System.Configuration;
using System;
using System.Linq;
using System.Web.UI;
using PMS.GL;
using System.Collections.Generic;
namespace PMS
{
    public partial class ChartofAccountExcelUpload : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }
        protected void btnUpload_Click(object sender, EventArgs e)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            db.Connection.Open();
            db.Transaction = db.Connection.BeginTransaction();
            try
            {
                var gl_accounts = (from tbl in db.GL_Accounts select tbl).ToList();
                if (gl_accounts != null)
                {
                    db.GL_Accounts.DeleteAllOnSubmit(gl_accounts);
                    db.SubmitChanges();
                }
                string excelPath = Server.MapPath("~/upload/UploadCA/") + Path.GetFileName(FileUpload.PostedFile.FileName);
                FileUpload.SaveAs(excelPath);
                string conString = string.Empty;
                string extension = Path.GetExtension(FileUpload.PostedFile.FileName);
                switch (extension)
                {
                    case ".xls": // Excel 97-03
                        conString = ConfigurationManager.ConnectionStrings["Excel03ConString"].ConnectionString;
                        break;
                    case ".xlsx": // Excel 07 or higher
                        conString = ConfigurationManager.ConnectionStrings["Excel07+ConString"].ConnectionString;
                        break;
                }
                conString = string.Format(conString, excelPath);
                using (OleDbConnection excel_con = new OleDbConnection(conString))
                {
                    excel_con.Open();
                    string sheet1 = excel_con.GetOleDbSchemaTable(OleDbSchemaGuid.Tables, null).Rows[0]["TABLE_NAME"].ToString();
                    DataTable dtExcelData = new DataTable();
                    using (OleDbCommand cmd = new OleDbCommand($"SELECT * FROM [{sheet1}]", excel_con))
                    {
                        using (OleDbDataReader reader = cmd.ExecuteReader())
                        {
                            dtExcelData.Load(reader);
                        }
                    }
                    string consString = ConfigurationManager.ConnectionStrings["ASPGLConnectionString"].ConnectionString;
                    using (SqlConnection con = new SqlConnection(consString))
                    {
                        con.Open();

                        int bookId = AppConfig.Book_ID;
                        var createdBy = AppConfig.UserID;
                        DateTime creationTime = DateTime.Now;

                        foreach (DataRow row in dtExcelData.Rows)
                        {
                            using (SqlCommand cmd = new SqlCommand("INSERT INTO dbo.Gl_Accounts (Account_Code, Account_Serial, Account_Name, Levels, Active, Cash, Bank, Book_ID, Created_By, Created_Time) " +
                                                                   "VALUES (@Account_Code, @Account_Serial, @Account_Name, @Levels, @Active, @Cash, @Bank, @Book_ID, @Created_By, @Created_Time)", con))
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
                        var Levelone = db.GL_Accounts.Where(tbl => tbl.Levels == 1).ToList();
                        int parentCodeCounter = 1;
                        foreach (var item in Levelone)
                        {
                            item.Parent_Code = parentCodeCounter++;
                            db.SubmitChanges();
                        }
                        var firstLevel = db.GL_Accounts.Where(tbl => tbl.Levels == 1).ToList();
                        foreach (var item in firstLevel)
                        {
                            var childCode = item.Account_Code;
                            var child = db.GL_Accounts.Where(tbl => tbl.Levels == 2 && tbl.Account_Code.StartsWith(childCode)).ToList();
                            foreach (var childItem in child)
                            {
                                childItem.Parent_Code = item.Account_ID;
                            }
                        }
                        var secondLevel = db.GL_Accounts.Where(tbl => tbl.Levels == 2).ToList();
                        foreach (var item in secondLevel)
                        {
                            var childCode = item.Account_Code;
                            var child = db.GL_Accounts.Where(tbl => tbl.Levels == 3 && tbl.Account_Code.StartsWith(childCode)).ToList();
                            foreach (var childItem in child)
                            {
                                childItem.Parent_Code = item.Account_ID;
                            }
                        }
                        var thirdLevel = db.GL_Accounts.Where(tbl => tbl.Levels == 3).ToList();
                        foreach (var item in thirdLevel)
                        {
                            var childCode = item.Account_Code;
                            var child = db.GL_Accounts.Where(tbl => tbl.Levels == 4 && tbl.Account_Code.StartsWith(childCode)).ToList();
                            foreach (var childItem in child)
                            {
                                childItem.Parent_Code = item.Account_ID;
                            }
                        }
                        db.SubmitChanges();
                        db.Transaction.Commit();
                        Response.Redirect(Request.RawUrl, false);
                        con.Close();
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
                db.Transaction.Rollback();
            }
            finally
            {
                db.Connection.Close(); if (db.Connection != null && db.Connection.State == ConnectionState.Open)
                {
                    db.Connection.Close();
                }
            }
            Response.Redirect("~/Modules/Gl/ChartofAccounts.aspx");
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
