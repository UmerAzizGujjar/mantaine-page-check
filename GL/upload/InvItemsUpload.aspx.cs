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
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class InvItemsUpload : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
            }
        }
        protected void btnUpload_Click(object sender, EventArgs e)
        {
            string filePath = string.Empty;

            if (!FileUpload.HasFile || (Path.GetExtension(FileUpload.FileName) != ".xls" && Path.GetExtension(FileUpload.FileName) == ".xlsx"))
            {
                try
                {
                    string fileName = Path.GetFileName(FileUpload.PostedFile.FileName);
                    string fileExtension = Path.GetExtension(fileName);
                    string folderPath = Server.MapPath("~/ExcelFiles/");

                    // Create folder if not exists
                    if (!Directory.Exists(folderPath))
                        Directory.CreateDirectory(folderPath);

                    filePath = folderPath + fileName;
                    FileUpload.SaveAs(filePath);

                    string conString = "";
                    string extension = Path.GetExtension(filePath);

                    // Choose correct connection string
                    switch (extension)
                    {
                        case ".xls": // Excel 97-03
                            conString = ConfigurationManager.ConnectionStrings["Excel03ConString"].ConnectionString;
                            break;

                        case ".xlsx": // Excel 07+
                            conString = ConfigurationManager.ConnectionStrings["Excel07ConString"].ConnectionString;
                            break;

                        default:
                            throw new Exception("Unsupported file type");
                    }

                    conString = string.Format(conString, filePath);
                    using (OleDbConnection excelCon = new OleDbConnection(conString))
                    {
                        excelCon.Open();
                        DataTable dtSchema;
                        dtSchema = excelCon.GetOleDbSchemaTable(OleDbSchemaGuid.Tables, null);

                        if (dtSchema == null || dtSchema.Rows.Count == 0)
                            throw new Exception("No worksheet found");

                        string sheetName = dtSchema.Rows[0]["TABLE_NAME"].ToString();
                        string query = "SELECT * FROM [" + sheetName + "]";
                        OleDbDataAdapter da = new OleDbDataAdapter(query, excelCon);
                        DataTable dtExcelData = new DataTable();
                        da.Fill(dtExcelData);

                        // Optional: Bind to grid for preview
                        // GridView1.DataSource = dtExcelData;
                        // GridView1.DataBind();

                        // Process your data as needed here
                        // Example: Loop through rows
                        foreach (DataRow row in dtExcelData.Rows)
                        {
                            string name = row["Name"].ToString();
                            string email = row["Email"].ToString();
                            // Do your DB insert here
                        }

                        ShowMessage("File uploaded and processed successfully.", "success");
                    }
                }
                catch (Exception ex)
                {
                    ShowMessage("Error: " + ex.Message, "error");
                }
            }
            else
            {
                ShowMessage("Please select a file.", "warning");
            }
        }

        private void ShowMessage(string message, string icon)
        {
            ScriptManager.RegisterStartupScript(this, GetType(), "swal", $@"
        <script>
        Swal.fire({{
            title: '{(icon == "success" ? "Success" : icon == "error" ? "Error" : "Notice")}',
            text: '{message.Replace("'", "").Replace(Environment.NewLine, " ")}',
            icon: '{icon}',
            confirmButtonText: 'OK'
        }});
        </script>", false);
        }
        protected void btnDownloadSample_Click(object sender, EventArgs e)
        {
            string filePath = Server.MapPath("~/upload/ExcelUploadSamples/InvItemsUploadSample.xlsx");
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
                // Handle file not found scenario
                Response.Write("<script>alert('Item Upload Sample File Not Found.');</script>");
            }
        }
    }
}