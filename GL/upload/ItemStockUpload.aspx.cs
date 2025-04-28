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
    public partial class ItemStockUpload : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
            }
        }
        protected void btnUpload_Click(object sender, EventArgs e)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            db.Connection.Open();
            db.Transaction = db.Connection.BeginTransaction();
            try
            {
                if (!FileUpload.HasFile || (Path.GetExtension(FileUpload.FileName) != ".xls" && Path.GetExtension(FileUpload.FileName) != ".xlsx"))
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "swal", @"
                                                                          <script type='text/javascript'>
                                                                              Swal.fire({
                                                                                  title: 'Error',
                                                                                  text: 'Please select an Excel file!',
                                                                                  icon: 'error',                                                                                 
                                                                                  width: '521px',
                                                                                  heightAuto: false,
                                                                                  height: '305px'
                                                                              }).then(function() {
                                                                                  window.location.href = '" + Request.RawUrl + @"';                                                 
                                                                              });
                                                                          </script>", false);
                    return;
                }
                if (FileUpload.HasFile)
                {
                    string excelPath = Server.MapPath("~/upload/UploadItemsStock/") + Path.GetFileName(FileUpload.PostedFile.FileName);
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
                            int companyId = AppConfig.Company_ID;
                            var createdBy = AppConfig.UserID;
                            DateTime creationTime = DateTime.Now;
                            var maxAdjNo = 0;
                            var maxAdjNoQuery = db.INV_Stock_Adjustments.Select(item => item.Adjustment_No);
                            if (maxAdjNoQuery.Any())
                            {
                                 maxAdjNo = (Convert.ToInt32(maxAdjNoQuery.Max()) + 1);
                            }
                            else
                            {
                                 maxAdjNo = 1;
                            }

                            foreach (DataRow row in dtExcelData.Rows)
                            {
                                string itemCode = Convert.ToString(row["Item_Code"]);
                                var itemdata = from item in db.INV_Items
                                                  where item.Item_Code == itemCode
                                                  select item.Item_ID;
                                int? itemId = itemdata.FirstOrDefault();
                                if (itemId != null)
                                {
                                    using (SqlCommand cmd = new SqlCommand("INSERT INTO dbo.INV_Stock_Adjustment (Adjustment_No,Adjustment_Date,Item_Code, Item_Id,Qty,Rate,Amount,Ware_House,Expire_Date,Batch_No,Remarks,Status,Created_By,Creation_Time,Book_ID,Company_ID) " +
                                                                       "VALUES (@Adjustment_No,@Adjustment_Date,@Item_Code,@Item_Id,@Qty,@Rate,@Amount,@Ware_House,@Expire_Date,@Batch_No,@Remarks,@Status,@Created_By,@Creation_Time,@Book_ID,@Company_ID)", con))
                                    {
                                        cmd.Parameters.AddWithValue("@Adjustment_No", maxAdjNo);
                                        cmd.Parameters.AddWithValue("@Adjustment_Date", Convert.ToDateTime(creationTime));
                                        cmd.Parameters.AddWithValue("@Item_Code", itemCode);
                                        cmd.Parameters.AddWithValue("@Item_Id", itemId);
                                        cmd.Parameters.AddWithValue("@Qty", Convert.ToDecimal(row["Qty"]));
                                        cmd.Parameters.AddWithValue("@Rate", Convert.ToDecimal(row["Rate"]));
                                        cmd.Parameters.AddWithValue("@Amount", Convert.ToDecimal(row["Amount"]));
                                        cmd.Parameters.AddWithValue("@Ware_House", row["Ware_House"]);
                                        cmd.Parameters.AddWithValue("@Expire_Date", row["Expire_Date"]);
                                        cmd.Parameters.AddWithValue("@Batch_No", row["Batch_No"]);
                                        cmd.Parameters.AddWithValue("@Remarks", row["Remarks"]);
                                        cmd.Parameters.AddWithValue("@Status", "Created");
                                        cmd.Parameters.AddWithValue("@Created_By", createdBy);
                                        cmd.Parameters.AddWithValue("@Creation_Time", creationTime);
                                        cmd.Parameters.AddWithValue("@Book_ID", bookId);
                                        cmd.Parameters.AddWithValue("@Company_ID", companyId);
                                        cmd.ExecuteNonQuery();
                                        maxAdjNo++;
                                    }
                                }
                                else
                                {
                                    Console.WriteLine($"Item with code '{itemCode}' not found in Inv_Items table.");
                                }
                            }
                            db.SubmitChanges();
                            db.Transaction.Commit();
                            string script = @"<script type='text/javascript'>
                                             Swal.fire({
                                                 title: 'Success',
                                                 text: 'Data inserted successfully!',
                                                 icon: 'success',
                                                 width: '521px',
                                                 heightAuto: false,
                                                 height: '305px'
                                             }).then(function() {                                                 
                                                 window.location.href = '/Modules/Inventory/StockAdjustmentView.aspx';
                                             });
                                            </script>";
                            ScriptManager.RegisterStartupScript(this, GetType(), "swal", script, false);
                            con.Close();
                        }
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
        }
        protected void btnDownloadSample_Click(object sender, EventArgs e)
        {
            string filePath = Server.MapPath("~/upload/ExcelUploadSamples/StockUploadSample.xlsx");
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
                Response.Write("<script>alert('Stock Upload Sample File Not Found.');</script>");
            }
        }
    }
}