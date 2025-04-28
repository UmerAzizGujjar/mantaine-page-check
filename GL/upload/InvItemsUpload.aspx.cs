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
                    string excelPath = Server.MapPath("~/upload/UploadInvItems/") + Path.GetFileName(FileUpload.PostedFile.FileName);
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
                            var maxItemCode = db.INV_Items.Select(item => Convert.ToInt32(item.Item_Code)).Max();
                            if (maxItemCode != 0)
                            {
                                maxItemCode = maxItemCode + 1;
                            }
                            else
                            {
                                maxItemCode = 1;
                            }
                            foreach (DataRow row in dtExcelData.Rows)
                            {
                                using (SqlCommand cmd = new SqlCommand("INSERT INTO dbo.INV_Items (Item_Code,Description,Item_Type, Item_Account_category,Purchase_Rate,Sale_Rate,Mini_Stock,Max_Stock,Reorder_Stock,IsBill_Item,Hospital_Services,Services,IsPharmacyItem,Pharmacy_Item,Unit,UOM_Qty,IsBatch,Refigrator,Locator,locatorAddress,InventoryOrg,Saleable,Purchaseable,Isfixasset,Procedure_Type,Notes,DepartmentId,Is_Active,Active,Created_By,Created_Time,Book_ID,Company_ID) " +
                                                                       "VALUES (@Item_Code,@Description,@Item_Type,@Item_Account_category,@Purchase_Rate,@Sale_Rate,@Mini_Stock,@Max_Stock,@Reorder_Stock,@IsBill_Item,@Hospital_Services,@Services,@IsPharmacyItem,@Pharmacy_Item,@Unit,@UOM_Qty,@IsBatch,@Refigrator,@Locator,@locatorAddress,@InventoryOrg,@Saleable,@Purchaseable,@Isfixasset,@Procedure_Type,@Notes,@DepartmentId,@Is_Active,@Active,@Created_By,@Created_Time,@Book_ID,@Company_ID)", con))
                                {
                                    cmd.Parameters.AddWithValue("@Item_Code", maxItemCode);
                                    cmd.Parameters.AddWithValue("@Description", row["Description"]);
                                    cmd.Parameters.AddWithValue("@Item_Type", row["Item_Type"]);
                                    cmd.Parameters.AddWithValue("@Item_Account_category", Convert.ToInt32(row["Item_Account_category"]));
                                    cmd.Parameters.AddWithValue("@Purchase_Rate", Convert.ToDecimal(row["Purchase_Rate"]));
                                    cmd.Parameters.AddWithValue("@Sale_Rate", Convert.ToDecimal(row["Sale_Rate"]));
                                    cmd.Parameters.AddWithValue("@Mini_Stock", row["Mini_Stock"]);
                                    cmd.Parameters.AddWithValue("@Max_Stock", row["Max_Stock"]);
                                    cmd.Parameters.AddWithValue("@Reorder_Stock", row["Reorder_Stock"]);
                                    cmd.Parameters.AddWithValue("@IsBill_Item", Convert.ToBoolean(Convert.ToInt32(row["IsBill_Item"])));
                                    cmd.Parameters.AddWithValue("@Hospital_Services", Convert.ToBoolean(Convert.ToInt32(row["Hospital_Services"])));
                                    cmd.Parameters.AddWithValue("@Services", Convert.ToBoolean(Convert.ToInt32(row["Hospital_Services"])));
                                    cmd.Parameters.AddWithValue("@IsPharmacyItem", Convert.ToBoolean(Convert.ToInt32(row["IsPharmacyItem"])));
                                    cmd.Parameters.AddWithValue("@Pharmacy_Item", Convert.ToBoolean(Convert.ToInt32(row["IsPharmacyItem"])));
                                    cmd.Parameters.AddWithValue("@Unit", row["Unit"]);
                                    cmd.Parameters.AddWithValue("@UOM_Qty", Convert.ToDecimal(row["UOM_Qty"]));
                                    cmd.Parameters.AddWithValue("@IsBatch", Convert.ToBoolean(Convert.ToInt32(row["IsBatch"])));
                                    cmd.Parameters.AddWithValue("@Refigrator", Convert.ToBoolean(Convert.ToInt32(row["Refigrator"])));
                                    cmd.Parameters.AddWithValue("@Locator", Convert.ToBoolean(Convert.ToInt32(row["Locator"])));
                                    cmd.Parameters.AddWithValue("@locatorAddress", row["locatorAddress"]);
                                    cmd.Parameters.AddWithValue("@InventoryOrg", row["InventoryOrg"]);
                                    cmd.Parameters.AddWithValue("@Saleable", Convert.ToBoolean(Convert.ToInt32(row["Saleable"])));
                                    cmd.Parameters.AddWithValue("@Purchaseable", Convert.ToBoolean(Convert.ToInt32(row["Purchaseable"])));
                                    cmd.Parameters.AddWithValue("@Isfixasset", Convert.ToBoolean(Convert.ToInt32(row["Isfixasset"])));
                                    cmd.Parameters.AddWithValue("@Procedure_Type", Convert.ToBoolean(Convert.ToInt32(row["Procedure_Type"])));
                                    cmd.Parameters.AddWithValue("@DepartmentId", row["DepartmentId"]);
                                    cmd.Parameters.AddWithValue("@Notes", row["Notes"]);
                                    cmd.Parameters.AddWithValue("@Is_Active", Convert.ToBoolean(Convert.ToInt32(row["Is_Active"])));
                                    cmd.Parameters.AddWithValue("@Active", Convert.ToBoolean(Convert.ToInt32(row["Is_Active"])));
                                    cmd.Parameters.AddWithValue("@Created_By", createdBy);
                                    cmd.Parameters.AddWithValue("@Created_Time", creationTime);
                                    cmd.Parameters.AddWithValue("@Book_ID", bookId);
                                    cmd.Parameters.AddWithValue("@Company_ID", companyId);
                                    cmd.ExecuteNonQuery();
                                    maxItemCode++;
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
                                                 window.location.href = '/Modules/Inventory/ProductsView.aspx';
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