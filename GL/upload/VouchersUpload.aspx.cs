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
    public partial class VouchersUpload : System.Web.UI.Page
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
                    string excelPath = Server.MapPath("~/upload/UploadVouchers/") + Path.GetFileName(FileUpload.PostedFile.FileName);
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
                            int companyId = AppConfig.Company_ID;
                            var createdBy = AppConfig.UserID;
                            DateTime creationTime = DateTime.Now;
                            decimal totaldebitsum = 0;
                            decimal totalcreditsum = 0;
                            //Group rows by Voucher_No and Voucher_Type and Voucher_Date to make Single Header
                            var groupedRows = dtExcelData.AsEnumerable().GroupBy(row => new { VoucherNo = row["Voucher_No"], VoucherType = row["Voucher_Type"], VoucherDate = row["Voucher_Date"] });
                            string unbalancedDetails = "";
                            foreach (var group in groupedRows)
                            {
                                var row = group.First();
                                using (SqlCommand cmd = new SqlCommand("INSERT INTO dbo.Gl_Vouchers (Voucher_No,Voucher_Date,Voucher_Type,Remarks,Voucher_Status,Company_ID,Created_By,Creation_Time,Period_ID,IsDeleted) " +
                                                                           "VALUES (@Voucher_No,@Voucher_Date,@Voucher_Type,@Remarks,@Voucher_Status,@Company_ID,@Created_By,@Creation_Time,@Period_ID,@IsDeleted); SELECT SCOPE_IDENTITY()", con))
                                {
                                    cmd.Parameters.AddWithValue("@Voucher_No", row["Voucher_No"]);
                                    cmd.Parameters.AddWithValue("@Voucher_Date", row["Voucher_Date"]);
                                    cmd.Parameters.AddWithValue("@Voucher_Type", row["Voucher_Type"]);
                                    cmd.Parameters.AddWithValue("@Remarks", row["Remarks"]);
                                    cmd.Parameters.AddWithValue("@Voucher_Status", "Created");
                                    cmd.Parameters.AddWithValue("@Company_ID", companyId);
                                    cmd.Parameters.AddWithValue("@Created_By", createdBy);
                                    cmd.Parameters.AddWithValue("@Creation_Time", creationTime);
                                    cmd.Parameters.AddWithValue("@Period_ID", Convert.ToInt32(GetPeriodID(row["Voucher_Date"].ToString(), companyId)));
                                    cmd.Parameters.AddWithValue("@IsDeleted", Convert.ToBoolean(0));
                                    int voucherId = Convert.ToInt32(cmd.ExecuteScalar());

                                    decimal totaldr = 0;
                                    decimal totalcr = 0;
                                    foreach (DataRow detailRow in group)
                                    {
                                        if (detailRow["Voucher_No"].ToString() == row["Voucher_No"].ToString())
                                        {
                                            using (SqlCommand detailCmd = new SqlCommand("INSERT INTO dbo.GL_Voucher_Accounts (Voucher_ID,Cost_Center,Account_ID, Narration, DR, CR,DepartmentId) " +
                                                                              "VALUES (@Voucher_ID, @Cost_Center, @Account_ID, @Narration, @DR, @CR,@DepartmentId)", con))
                                            {
                                                detailCmd.Parameters.AddWithValue("@Voucher_ID", voucherId);
                                                detailCmd.Parameters.AddWithValue("@Cost_Center", detailRow["Cost_Center"]);
                                                detailCmd.Parameters.AddWithValue("@Account_ID", GetAccountId(detailRow["Account_Code"].ToString()));
                                                detailCmd.Parameters.AddWithValue("@Narration", detailRow["Description"].ToString());
                                                detailCmd.Parameters.AddWithValue("@DR", Convert.ToDecimal(detailRow["Debit"]));
                                                detailCmd.Parameters.AddWithValue("@CR", Convert.ToDecimal(detailRow["Credit"]));
                                                detailCmd.Parameters.AddWithValue("@DepartmentId", detailRow["Departement"]);
                                                detailCmd.ExecuteNonQuery();
                                                totaldr += Convert.ToDecimal(detailRow["Debit"]);
                                                totalcr += Convert.ToDecimal(detailRow["Credit"]);
                                            }
                                        }
                                    }
                                    totaldebitsum += totaldr;
                                    totalcreditsum += totalcr;
                                    if (totaldr == totalcr)
                                    {
                                        using (SqlCommand updateCmd = new SqlCommand("UPDATE dbo.Gl_Vouchers SET Total_Amount = @Total_Amount,Total_Debit=@Total_Debit,Total_Credit=@Total_Credit WHERE Voucher_ID = @Voucher_ID", con))
                                        {
                                            updateCmd.Parameters.AddWithValue("@Total_Amount", totaldr);
                                            updateCmd.Parameters.AddWithValue("@Total_Debit", totaldr);
                                            updateCmd.Parameters.AddWithValue("@Total_Credit", totalcr);
                                            updateCmd.Parameters.AddWithValue("@Voucher_ID", voucherId);
                                            updateCmd.ExecuteNonQuery();
                                        }
                                    }
                                    else
                                    {
                                        using (SqlCommand glvoucherdetail = new SqlCommand("DELETE FROM dbo.GL_Voucher_Accounts WHERE Voucher_ID = @Voucher_ID", con))
                                        {
                                            glvoucherdetail.Parameters.AddWithValue("@Voucher_ID", voucherId);
                                            glvoucherdetail.ExecuteNonQuery();
                                        }
                                        using (SqlCommand glvoucher = new SqlCommand("DELETE FROM dbo.Gl_Vouchers WHERE Voucher_ID = @Voucher_ID", con))
                                        {
                                            glvoucher.Parameters.AddWithValue("@Voucher_ID", voucherId);
                                            glvoucher.ExecuteNonQuery();
                                        }
                                        unbalancedDetails += $"Voucher with Voucher No: {row["Voucher_No"]} has total debit of {totaldr} and total credit of {totalcr}, Voucher Type: {row["Voucher_Type"]}, Voucher Date: {row["Voucher_Date"]}\n";
                                    }
                                }
                            }
                            if (totaldebitsum == totalcreditsum)
                            {
                                string script = @"<script type='text/javascript'>
                                             Swal.fire({
                                                 title: 'Success',
                                                 text: 'Data Inserted Successfully!',
                                                 icon: 'success',
                                                 width: '521px',
                                                 heightAuto: false,
                                                 height: '305px'
                                             }).then(function() {                                     
                                                window.location.href = '/Modules/GL/PostVouchers.aspx';
                                             });
                                            </script>";
                                ScriptManager.RegisterStartupScript(this, GetType(), "swal", script, false);
                            }
                            else
                            {
                                string balanceMessage = $@"
                                                        <script type='text/javascript'>
                                                            console.log('Voucher Not Balance Message');
                                                            console.log('{unbalancedDetails.Replace("\n", "\\n")}');
                                                        </script>";
                                ScriptManager.RegisterStartupScript(this, GetType(), "VoucherNotBalanceMessage", balanceMessage, false);
                                string script = @"<script type='text/javascript'>
                                             Swal.fire({
                                                 title: 'Warning',
                                                 text: 'Data Inserted Successfully! But Some Vouchers are UnBalance Please Check Console for Details',
                                                 icon: 'warning',
                                                 height: '305px',
                                                 width: '521px',
                                                 heightAuto: false                                                
                                             }).then(function() {
                                             });
                                            </script>";
                                ScriptManager.RegisterStartupScript(this, GetType(), "swal", script, false);
                            }
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
                db.Connection.Close();
                if (db.Connection != null && db.Connection.State == ConnectionState.Open)
                {
                    db.Connection.Close();
                }
            }
        }
        private int GetAccountId(string code)
        {
            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                var account = db.GL_Accounts.FirstOrDefault(a => a.Account_Code == code);
                return account != null ? account.Account_ID : 0;
            }
        }
        private int GetPeriodID(string voucherDate, int companyId)
        {
            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                DateTime date = Convert.ToDateTime(voucherDate);
                var period = db.GL_Periods.FirstOrDefault(a => a.Company_ID == companyId && a.Period_start_date <= date && a.Period_end_date >= date);
                return period != null ? Convert.ToInt32(period.Period_ID) : 0;
            }
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            Response.Redirect(Request.RawUrl);
        }
        protected void btnDownloadSample_Click(object sender, EventArgs e)
        {
            string filePath = Server.MapPath("~/upload/ExcelUploadSamples/VoucherUploadSample.xlsx");
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
                Response.Write("<script>alert('Voucher Upload Sample File Not Found.');</script>");
            }
        }
    }
}