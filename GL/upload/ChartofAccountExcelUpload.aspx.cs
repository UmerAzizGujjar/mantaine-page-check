using System.IO;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System;
using System.Web.UI;
using System.Xml.Linq;
using System.IO.Compression;
using System.Collections.Generic;
using System.Linq;

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

                    // Read Excel data — no OLEDB required
                    string extension = Path.GetExtension(FileUpload.PostedFile.FileName).ToLower();
                    DataTable dtExcelData = ReadExcelFile(excelPath, extension);

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

        private DataTable ReadExcelFile(string filePath, string extension)
        {
            if (extension == ".xlsx")
            {
                return ReadXlsxFile(filePath);
            }
            if (extension == ".xls")
            {
                // Old binary .xls format — try ACE OLEDB as fallback
                try
                {
                    return ReadXlsWithOleDb(filePath);
                }
                catch (Exception inner)
                {
                    throw new Exception(
                        "Failed to read .xls file. Please convert it to .xlsx format and try again, " +
                        "or install Microsoft Access Database Engine (matching your app pool bitness). " +
                        "Error: " + inner.Message);
                }
            }
            throw new Exception("Unsupported file format. Please upload .xls or .xlsx file.");
        }

        private static int ColumnIndexFromRef(string cellRef)
        {
            string colPart = "";
            foreach (char c in cellRef)
            {
                if (char.IsLetter(c))
                    colPart += c;
                else
                    break;
            }
            int index = 0;
            foreach (char c in colPart)
            {
                index = index * 26 + (char.ToUpper(c) - 'A' + 1);
            }
            return index - 1;
        }

        private DataTable ReadXlsxFile(string filePath)
        {
            DataTable dt = new DataTable();

            using (ZipArchive archive = new ZipArchive(File.OpenRead(filePath), ZipArchiveMode.Read))
            {
                // Load shared strings
                List<string> sharedStrings = new List<string>();
                ZipArchiveEntry ssEntry = archive.GetEntry("xl/sharedStrings.xml");
                if (ssEntry != null)
                {
                    using (Stream ssStream = ssEntry.Open())
                    {
                        XDocument ssDoc = XDocument.Load(ssStream);
                        XNamespace ns = "http://schemas.openxmlformats.org/spreadsheetml/2006/main";
                        foreach (var si in ssDoc.Descendants(ns + "si"))
                        {
                            var t = si.Element(ns + "t");
                            sharedStrings.Add(t != null ? t.Value : "");
                        }
                    }
                }

                // Find first worksheet via workbook.xml relationships
                ZipArchiveEntry sheetEntry = null;
                ZipArchiveEntry wbEntry = archive.GetEntry("xl/workbook.xml");
                if (wbEntry != null)
                {
                    XDocument wbDoc = XDocument.Load(wbEntry.Open());
                    XNamespace wbNs = "http://schemas.openxmlformats.org/spreadsheetml/2006/main";
                    XNamespace rNs = "http://schemas.openxmlformats.org/officeDocument/2006/relationships";

                    var sheets = wbDoc.Descendants(wbNs + "sheet").ToList();
                    if (sheets.Count > 0)
                    {
                        string firstSheetId = sheets[0].Attribute("sheetId")?.Value;
                        ZipArchiveEntry relsEntry = archive.GetEntry("xl/_rels/workbook.xml.rels");
                        if (relsEntry != null)
                        {
                            XDocument relsDoc = XDocument.Load(relsEntry.Open());
                            var rel = relsDoc.Descendants().FirstOrDefault(r =>
                                r.Attribute("Id")?.Value == "rId1" ||
                                (r.Attribute("Target")?.Value?.StartsWith("worksheets/") == true));
                            if (rel != null)
                            {
                                string target = rel.Attribute("Target")?.Value;
                                if (!string.IsNullOrEmpty(target))
                                    sheetEntry = archive.GetEntry("xl/" + target);
                            }
                        }
                    }
                }

                if (sheetEntry == null)
                {
                    // Fallback: try direct path
                    sheetEntry = archive.GetEntry("xl/worksheets/sheet1.xml");
                }
                if (sheetEntry == null)
                    throw new Exception("Could not find worksheet in the Excel file.");

                // Determine max column count from the header row
                int maxCols = 0;

                using (Stream sheetStream = sheetEntry.Open())
                {
                    XDocument sheetDoc = XDocument.Load(sheetStream);
                    XNamespace ns = "http://schemas.openxmlformats.org/spreadsheetml/2006/main";

                    var rows = sheetDoc.Descendants(ns + "row").ToList();
                    if (rows.Count == 0)
                        return dt;

                    // First pass: parse header row to build columns
                    var headerRow = rows[0];
                    int headerMaxCol = 0;
                    foreach (var cell in headerRow.Elements(ns + "c"))
                    {
                        string refStr = cell.Attribute("r")?.Value ?? "";
                        int colIdx = ColumnIndexFromRef(refStr);
                        string type = cell.Attribute("t")?.Value ?? "";
                        var v = cell.Element(ns + "v");
                        string val = "";
                        if (v != null)
                        {
                            if (type == "s")
                            {
                                int idx;
                                if (int.TryParse(v.Value, out idx) && idx >= 0 && idx < sharedStrings.Count)
                                    val = sharedStrings[idx];
                            }
                            else
                            {
                                val = v.Value;
                            }
                        }
                        if (colIdx >= headerMaxCol)
                            headerMaxCol = colIdx + 1;
                        while (dt.Columns.Count <= colIdx)
                            dt.Columns.Add("F" + dt.Columns.Count);
                        string colName = string.IsNullOrEmpty(val.Trim()) ? "F" + colIdx : val.Trim();
                        dt.Columns[colIdx].ColumnName = colName;
                    }
                    // Ensure at least as many columns as header indicates
                    maxCols = headerMaxCol;

                    // Data rows
                    for (int r = 1; r < rows.Count; r++)
                    {
                        var row = rows[r];
                        string[] values = new string[maxCols];
                        for (int i = 0; i < maxCols; i++)
                            values[i] = "";

                        foreach (var cell in row.Elements(ns + "c"))
                        {
                            string refStr = cell.Attribute("r")?.Value ?? "";
                            int colIdx = ColumnIndexFromRef(refStr);
                            if (colIdx >= maxCols)
                                continue;

                            string type = cell.Attribute("t")?.Value ?? "";
                            var v = cell.Element(ns + "v");
                            if (v != null)
                            {
                                if (type == "s")
                                {
                                    int idx;
                                    if (int.TryParse(v.Value, out idx) && idx >= 0 && idx < sharedStrings.Count)
                                        values[colIdx] = sharedStrings[idx];
                                }
                                else
                                {
                                    values[colIdx] = v.Value;
                                }
                            }
                        }

                        DataRow dr = dt.NewRow();
                        for (int i = 0; i < maxCols; i++)
                            dr[i] = values[i];
                        dt.Rows.Add(dr);
                    }
                }
            }

            return dt;
        }

        private DataTable ReadXlsWithOleDb(string filePath)
        {
            DataTable dt = new DataTable();
            string connStr = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=" + filePath +
                             ";Extended Properties='Excel 8.0;HDR=YES;IMEX=1';";

            using (System.Data.OleDb.OleDbConnection conn = new System.Data.OleDb.OleDbConnection(connStr))
            {
                conn.Open();
                string sheetName = conn.GetOleDbSchemaTable(System.Data.OleDb.OleDbSchemaGuid.Tables, null)
                    .Rows[0]["TABLE_NAME"].ToString();
                using (System.Data.OleDb.OleDbCommand cmd = new System.Data.OleDb.OleDbCommand(
                    "SELECT * FROM [" + sheetName + "]", conn))
                using (System.Data.OleDb.OleDbDataReader reader = cmd.ExecuteReader())
                {
                    dt.Load(reader);
                }
            }

            return dt;
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
