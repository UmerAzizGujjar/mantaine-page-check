using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Text.RegularExpressions;
using System.Web.UI;
using System.Web.UI.WebControls;
using SheetRow = PMS.ExcelUploadHelper.SheetRow;

namespace PMS
{
    /// <summary>
    /// Bulk-creates AP_Vendors from an Excel sheet, the same way Modules/AP/Vendor.aspx saves one vendor:
    /// lookups are stored as DataValue_Name codes, Vendor_Code = Vendor_ID, and the payable GL account is
    /// either an existing level-4 account (Ismanual = 1) or a new child of "Trade &amp; Other Payables" (Ismanual = 0).
    /// </summary>
    public partial class VendorsUpload : System.Web.UI.Page
    {
        private const string PayablesParm = "Trade & Other Payables";

        private class ColumnDef
        {
            public string Key;
            public string Header;
            public int MaxLength;
            public bool Required;
            public string LookupSet;   // ValueSet_Description, null for free text
            public int Width;
            public string Note;
            public string[] Aliases;
        }

        private static readonly ColumnDef[] Columns =
        {
            new ColumnDef { Key = "Name", Header = "Vendor Name", MaxLength = 100, Required = true, Width = 34, Note = "Required. Vendors whose name already exists are skipped.", Aliases = new[] { "Supplier Name", "Vendor", "Supplier", "Name" } },
            new ColumnDef { Key = "Type", Header = "Vendor Type", MaxLength = 50, Required = true, LookupSet = "Vendor Type", Width = 16, Note = "Required. Pick from the list (name or code from the Lookups sheet).", Aliases = new[] { "Supplier Type", "Type" } },
            new ColumnDef { Key = "Address", Header = "Address", MaxLength = 250, Width = 40 },
            new ColumnDef { Key = "CreditDays", Header = "Credit Days", MaxLength = 50, Width = 12, Note = "Whole number of days." },
            new ColumnDef { Key = "Country", Header = "Country", MaxLength = 30, Width = 14 },
            new ColumnDef { Key = "Region", Header = "Region", MaxLength = 50, LookupSet = "Region", Width = 14 },
            new ColumnDef { Key = "City", Header = "City", MaxLength = 10, Width = 14, Note = "Max 10 characters." },
            new ColumnDef { Key = "Mobile", Header = "Mobile No", MaxLength = 50, Width = 16, Aliases = new[] { "Mobile", "Cell No", "Mob No" } },
            new ColumnDef { Key = "Phone", Header = "Phone No", MaxLength = 50, Width = 16, Aliases = new[] { "Phone", "Ph No", "Phone 1" } },
            new ColumnDef { Key = "DrugLicence", Header = "Drug Licence No", MaxLength = 500, Width = 18, Aliases = new[] { "Drug License No", "Drug Licence", "Drug License" } },
            new ColumnDef { Key = "Stn", Header = "STN", MaxLength = 50, Width = 16, Aliases = new[] { "Sales Tax No", "STN No" } },
            new ColumnDef { Key = "Ntn", Header = "NTN", MaxLength = 50, Width = 16, Aliases = new[] { "NTN No" } },
            new ColumnDef { Key = "Cnic", Header = "CNIC", MaxLength = 50, Width = 18, Aliases = new[] { "CNIC No" } },
            new ColumnDef { Key = "Email", Header = "Email", MaxLength = 100, Width = 26, Aliases = new[] { "E-mail", "Email Address" } },
            new ColumnDef { Key = "Focal", Header = "Focal Person", MaxLength = 100, Width = 20, Aliases = new[] { "Contact Person" } },
            new ColumnDef { Key = "TaxType", Header = "Tax Payer Type", MaxLength = 50, LookupSet = "Tax Payer Type", Width = 16, Aliases = new[] { "Tax Type" } },
            new ColumnDef { Key = "CompanyType", Header = "Company Type", MaxLength = 50, LookupSet = "Company Type", Width = 16 },
            new ColumnDef { Key = "Manufacturer", Header = "Manufacturer", MaxLength = 300, LookupSet = "Manufacture Company", Width = 18, Aliases = new[] { "Manufacture Company", "Manufacturer Company" } },
            new ColumnDef { Key = "PayableCode", Header = "Payable Account Code", MaxLength = 10, Width = 22, Note = "Blank = auto-create the vendor's GL account under Trade & Other Payables. Otherwise an existing level-4 account code.", Aliases = new[] { "Payable Code", "Account Code", "GL Account Code" } },
            new ColumnDef { Key = "Active", Header = "Active", MaxLength = 10, Width = 10, Note = "Yes or No. Blank = Yes.", Aliases = new[] { "Is Active" } },
        };

        private class Lookup
        {
            public string Set;
            public List<KeyValuePair<string, string>> Items = new List<KeyValuePair<string, string>>(); // code, description
            public Dictionary<string, string> ByKey = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);

            public void Add(string code, string description)
            {
                code = (code ?? "").Trim();
                description = (description ?? "").Trim();
                Items.Add(new KeyValuePair<string, string>(code, description));
                if (description != "" && !ByKey.ContainsKey(description)) ByKey[description] = code;
                if (code != "" && !ByKey.ContainsKey(code)) ByKey[code] = code;
                int n;
                if (int.TryParse(code, out n) && !ByKey.ContainsKey(n.ToString())) ByKey[n.ToString()] = code; // "002" typed as 2
            }

            public string Resolve(string value)
            {
                string code;
                if (ByKey.TryGetValue(value.Trim(), out code)) return code;
                decimal d;
                if (decimal.TryParse(value, NumberStyles.Number, CultureInfo.InvariantCulture, out d) && d == Math.Floor(d)
                    && ByKey.TryGetValue(((long)d).ToString(), out code)) return code;
                return null;
            }
        }

        private class VendorRow
        {
            public int RowNo;
            public Dictionary<string, string> Values = new Dictionary<string, string>();
            public List<string> Errors = new List<string>();
            public string SkipReason;
            public Dictionary<string, string> Codes = new Dictionary<string, string>();
            public int? ManualAccountId;
            public bool IsActive = true;
            public string VendorCode = "";
            public string AccountCode = "";

            public string Get(string key)
            {
                string v;
                return Values.TryGetValue(key, out v) ? v : "";
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void btnUpload_Click(object sender, EventArgs e)
        {
            pnlResult.Visible = false;
            if (!FileUpload.HasFile)
            {
                ShowMessage("Please select a file to upload.", "warning");
                return;
            }

            if (!ExcelUploadHelper.IsSupported(FileUpload.PostedFile.FileName))
            {
                ShowMessage("Unsupported file type. Please upload an .xlsx, .xls or .csv file.", "warning");
                return;
            }

            List<SheetRow> sheet;
            try
            {
                sheet = ExcelUploadHelper.Read(FileUpload, "Vendors");
            }
            catch (Exception ex)
            {
                ShowMessage("Could not read the file: " + ex.Message, "error");
                return;
            }

            // Header = first non-empty row
            int headerIndex = sheet.FindIndex(r => !r.IsBlank);
            if (headerIndex < 0)
            {
                ShowMessage("The file is empty.", "warning");
                return;
            }

            Dictionary<string, int> columnIndex = MapColumns(sheet[headerIndex].Cells);
            List<string> missing = Columns.Where(c => c.Required && !columnIndex.ContainsKey(c.Key)).Select(c => c.Header).ToList();
            if (missing.Count > 0)
            {
                ShowMessage("Required column(s) not found: " + string.Join(", ", missing) + ". Please use the sample file.", "error");
                return;
            }

            List<VendorRow> rows = new List<VendorRow>();
            for (int i = headerIndex + 1; i < sheet.Count; i++)
            {
                SheetRow sr = sheet[i];
                if (sr.IsBlank)
                    continue;
                VendorRow row = new VendorRow { RowNo = sr.Number };
                foreach (ColumnDef col in Columns)
                {
                    int idx;
                    string val = columnIndex.TryGetValue(col.Key, out idx) && idx < sr.Cells.Length ? sr.Cells[idx] : "";
                    row.Values[col.Key] = Regex.Replace((val ?? "").Trim(), @"\s+", " ");
                }
                rows.Add(row);
            }

            if (rows.Count == 0)
            {
                ShowMessage("No vendor rows found under the header row.", "warning");
                return;
            }

            int companyId = AppConfig.Company_ID;
            int bookId = AppConfig.Book_ID;
            Guid userId = AppConfig.UserID;

            using (SqlConnection con = new SqlConnection(DBClass.ConnectionString()))
            {
                con.Open();
                Dictionary<string, Lookup> lookups = LoadLookups(con, null);
                ValidateRows(con, rows, lookups, companyId, bookId);

                List<VendorRow> toInsert = rows.Where(r => r.Errors.Count == 0 && r.SkipReason == null).ToList();
                int errorCount = rows.Count(r => r.Errors.Count > 0);
                int skipCount = rows.Count(r => r.Errors.Count == 0 && r.SkipReason != null);

                if (errorCount > 0)
                {
                    BindResult(rows, false);
                    SetSummary(string.Format("<span class='label label-danger'>Nothing saved</span> {0} of {1} row(s) have errors. Fix the rows marked in red and upload again.", errorCount, rows.Count));
                    ShowMessage(errorCount + " row(s) have errors. Nothing was saved. See the list below.", "error");
                    return;
                }
                if (toInsert.Count == 0)
                {
                    BindResult(rows, false);
                    SetSummary(string.Format("<span class='label label-warning'>Nothing to save</span> All {0} vendor(s) already exist or are duplicates.", rows.Count));
                    ShowMessage("Nothing to save: all vendors in the file already exist.", "warning");
                    return;
                }

                int current = 0;
                using (SqlTransaction tran = con.BeginTransaction())
                {
                    try
                    {
                        AutoAccount auto = null;
                        if (toInsert.Any(r => r.ManualAccountId == null))
                            auto = GetAutoAccountParent(con, tran, companyId, bookId);

                        foreach (VendorRow row in toInsert)
                        {
                            current = row.RowNo;
                            InsertVendor(con, tran, row, auto, companyId, bookId, userId);
                        }
                        tran.Commit();
                    }
                    catch (Exception ex)
                    {
                        try { tran.Rollback(); } catch { }
                        foreach (VendorRow r in toInsert) { r.VendorCode = ""; r.AccountCode = ""; }
                        BindResult(rows, false);
                        string msg = (current > 0 ? "Row " + current + ": " : "") + ex.Message;
                        SetSummary("<span class='label label-danger'>Nothing saved</span> " + Server.HtmlEncode(msg));
                        ShowMessage("Upload failed, nothing was saved. " + msg, "error");
                        return;
                    }
                }

                BindResult(rows, true);
                SetSummary(string.Format("<span class='label label-success'>Saved</span> {0} vendor(s) created{1}.",
                    toInsert.Count, skipCount > 0 ? ", " + skipCount + " skipped" : ""));
                ShowMessage(toInsert.Count + " vendor(s) uploaded successfully." + (skipCount > 0 ? " " + skipCount + " skipped (already exist)." : ""), "success");
            }
        }

        #region Validation

        private Dictionary<string, int> MapColumns(string[] header)
        {
            Dictionary<string, int> map = new Dictionary<string, int>();
            for (int i = 0; i < header.Length; i++)
            {
                string h = ExcelUploadHelper.NormalizeHeader(header[i]);
                if (h == "") continue;
                foreach (ColumnDef col in Columns)
                {
                    if (map.ContainsKey(col.Key)) continue;
                    bool match = ExcelUploadHelper.NormalizeHeader(col.Header) == h
                        || (col.Aliases != null && col.Aliases.Any(a => ExcelUploadHelper.NormalizeHeader(a) == h));
                    if (match)
                    {
                        map[col.Key] = i;
                        break;
                    }
                }
            }
            return map;
        }

        private void ValidateRows(SqlConnection con, List<VendorRow> rows, Dictionary<string, Lookup> lookups, int companyId, int bookId)
        {
            HashSet<string> existing = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            using (SqlCommand cmd = new SqlCommand("SELECT LTRIM(RTRIM(Vendor_Name)) FROM dbo.AP_Vendors WHERE Company_ID = @Company_ID AND Vendor_Name IS NOT NULL", con))
            {
                cmd.Parameters.AddWithValue("@Company_ID", companyId);
                using (SqlDataReader dr = cmd.ExecuteReader())
                    while (dr.Read()) existing.Add(Regex.Replace(dr.GetString(0), @"\s+", " "));
            }

            Dictionary<string, int?> accountCache = new Dictionary<string, int?>(StringComparer.OrdinalIgnoreCase);
            Dictionary<string, int> seenInFile = new Dictionary<string, int>(StringComparer.OrdinalIgnoreCase);
            Regex email = new Regex(@"^[^@\s]+@[^@\s]+\.[^@\s]+$");

            foreach (VendorRow row in rows)
            {
                foreach (ColumnDef col in Columns)
                {
                    string val = row.Get(col.Key);
                    if (val == "")
                    {
                        if (col.Required) row.Errors.Add(col.Header + " is required.");
                        continue;
                    }
                    if (col.LookupSet != null)
                    {
                        string code = lookups.ContainsKey(col.LookupSet) ? lookups[col.LookupSet].Resolve(val) : null;
                        if (code == null)
                            row.Errors.Add(col.Header + " '" + val + "' is not in the list.");
                        else
                            row.Codes[col.Key] = code;
                    }
                    else if (val.Length > col.MaxLength)
                    {
                        row.Errors.Add(col.Header + " is longer than " + col.MaxLength + " characters.");
                    }
                }

                string credit = row.Get("CreditDays");
                int days;
                if (credit != "" && (!int.TryParse(credit, out days) || days < 0))
                    row.Errors.Add("Credit Days must be a whole number.");

                string mail = row.Get("Email");
                if (mail != "" && !email.IsMatch(mail))
                    row.Errors.Add("Email '" + mail + "' is not valid.");

                string active = row.Get("Active").ToLowerInvariant();
                if (active == "" || active == "yes" || active == "y" || active == "true" || active == "1" || active == "active")
                    row.IsActive = true;
                else if (active == "no" || active == "n" || active == "false" || active == "0" || active == "inactive")
                    row.IsActive = false;
                else
                    row.Errors.Add("Active must be Yes or No.");

                string payable = row.Get("PayableCode");
                if (payable != "")
                {
                    int? accountId;
                    if (!accountCache.TryGetValue(payable, out accountId))
                    {
                        accountId = FindPayableAccount(con, payable, bookId);
                        accountCache[payable] = accountId;
                    }
                    if (accountId == null)
                        row.Errors.Add("Payable Account Code '" + payable + "' is not an active level-4 account.");
                    else
                        row.ManualAccountId = accountId;
                }

                string name = row.Get("Name");
                if (name != "")
                {
                    int firstRow;
                    if (existing.Contains(name))
                        row.SkipReason = "Vendor already exists.";
                    else if (seenInFile.TryGetValue(name, out firstRow))
                        row.SkipReason = "Same vendor name as row " + firstRow + ".";
                    else
                        seenInFile[name] = row.RowNo;
                }
            }
        }

        private static int? FindPayableAccount(SqlConnection con, string code, int bookId)
        {
            using (SqlCommand cmd = new SqlCommand(
                "SELECT TOP 1 Account_ID FROM dbo.GL_Accounts WHERE Account_Code = @Account_Code AND Book_ID = @Book_ID AND Levels = 4 AND ISNULL(Active, 1) = 1 AND ISNULL(isCancel, 0) = 0", con))
            {
                cmd.Parameters.AddWithValue("@Account_Code", code);
                cmd.Parameters.AddWithValue("@Book_ID", bookId);
                object o = cmd.ExecuteScalar();
                return o == null || o == DBNull.Value ? (int?)null : Convert.ToInt32(o);
            }
        }

        private static Dictionary<string, Lookup> LoadLookups(SqlConnection con, SqlTransaction tran)
        {
            string[] sets = Columns.Where(c => c.LookupSet != null).Select(c => c.LookupSet).Distinct().ToArray();
            Dictionary<string, Lookup> result = sets.ToDictionary(s => s, s => new Lookup { Set = s }, StringComparer.OrdinalIgnoreCase);
            using (SqlCommand cmd = new SqlCommand(
                "SELECT v.ValueSet_Description, p.DataValue_Name, p.DataValue_Description FROM dbo.DataValues p " +
                "INNER JOIN dbo.ValueSet v ON p.ValueSet_ID = v.ValueSet_ID " +
                "WHERE v.ValueSet_Description IN (" + string.Join(",", sets.Select((s, i) => "@s" + i)) + ") " +
                "ORDER BY v.ValueSet_Description, p.DataValue_Name", con, tran))
            {
                for (int i = 0; i < sets.Length; i++)
                    cmd.Parameters.AddWithValue("@s" + i, sets[i]);
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        Lookup lk;
                        if (result.TryGetValue(dr.GetString(0), out lk))
                            lk.Add(dr.IsDBNull(1) ? "" : dr.GetValue(1).ToString(), dr.IsDBNull(2) ? "" : dr.GetValue(2).ToString());
                    }
                }
            }
            return result;
        }

        #endregion

        #region Save

        private class AutoAccount
        {
            public int ParentId;
            public string ParentCode;
            public int Level;
            public int NextSerial;
        }

        private static AutoAccount GetAutoAccountParent(SqlConnection con, SqlTransaction tran, int companyId, int bookId)
        {
            AutoAccount auto = new AutoAccount();
            using (SqlCommand cmd = new SqlCommand(
                "SELECT TOP 1 a.Account_ID, a.Account_Code, ISNULL(a.Levels, 3) FROM dbo.sys_Parms p " +
                "INNER JOIN dbo.GL_Accounts a ON a.Account_Code = p.Code AND a.Book_ID = @Book_ID " +
                "WHERE p.Name = @Name ORDER BY CASE WHEN p.Company_ID = @Company_ID THEN 0 ELSE 1 END", con, tran))
            {
                cmd.Parameters.AddWithValue("@Name", PayablesParm);
                cmd.Parameters.AddWithValue("@Book_ID", bookId);
                cmd.Parameters.AddWithValue("@Company_ID", companyId);
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    if (!dr.Read())
                        throw new Exception("The '" + PayablesParm + "' account is not set in sys_Parms (or not found in the Chart of Accounts). Set it, or fill Payable Account Code for every vendor.");
                    auto.ParentId = dr.GetInt32(0);
                    auto.ParentCode = dr.GetString(1).Trim();
                    auto.Level = Convert.ToInt32(dr.GetValue(2)) + 1;
                }
            }

            // Same numbering as Vendor.aspx LoadNewAccountToCreate: max numeric child serial + 1. Lock the range so
            // a vendor saved from the form at the same moment cannot take the same code.
            using (SqlCommand cmd = new SqlCommand(
                "SELECT ISNULL(MAX(CASE WHEN Account_Serial NOT LIKE '%[^0-9]%' AND LEN(Account_Serial) BETWEEN 1 AND 9 " +
                "THEN CONVERT(int, Account_Serial) END), 0) FROM dbo.GL_Accounts WITH (UPDLOCK, HOLDLOCK) WHERE Parent_Code = @Parent_Code", con, tran))
            {
                cmd.Parameters.AddWithValue("@Parent_Code", auto.ParentId);
                auto.NextSerial = Convert.ToInt32(cmd.ExecuteScalar()) + 1;
            }
            return auto;
        }

        private static void InsertVendor(SqlConnection con, SqlTransaction tran, VendorRow row, AutoAccount auto, int companyId, int bookId, Guid userId)
        {
            int accountId;
            bool isManual = row.ManualAccountId != null;
            if (isManual)
            {
                accountId = row.ManualAccountId.Value;
                row.AccountCode = row.Get("PayableCode");
            }
            else
            {
                string serial, code;
                while (true)
                {
                    serial = auto.NextSerial.ToString("000");
                    code = auto.ParentCode + serial;
                    if (serial.Length > 5 || code.Length > 10)
                        throw new Exception("No free account code left under " + auto.ParentCode + ".");
                    using (SqlCommand chk = new SqlCommand("SELECT COUNT(*) FROM dbo.GL_Accounts WHERE Account_Code = @Account_Code AND Book_ID = @Book_ID", con, tran))
                    {
                        chk.Parameters.AddWithValue("@Account_Code", code);
                        chk.Parameters.AddWithValue("@Book_ID", bookId);
                        if (Convert.ToInt32(chk.ExecuteScalar()) == 0) break;
                    }
                    auto.NextSerial++;
                }
                auto.NextSerial++;

                using (SqlCommand cmd = new SqlCommand(
                    "INSERT INTO dbo.GL_Accounts (Account_Code, Account_Serial, Account_Name, Levels, Parent_Code, Active, Cash, Bank, Book_ID, Created_By, Created_Time) " +
                    "VALUES (@Account_Code, @Account_Serial, @Account_Name, @Levels, @Parent_Code, 1, 0, 0, @Book_ID, @Created_By, GETDATE()); " +
                    "SELECT CAST(SCOPE_IDENTITY() AS int);", con, tran))
                {
                    cmd.Parameters.AddWithValue("@Account_Code", code);
                    cmd.Parameters.AddWithValue("@Account_Serial", serial);
                    cmd.Parameters.AddWithValue("@Account_Name", row.Get("Name"));
                    cmd.Parameters.AddWithValue("@Levels", auto.Level);
                    cmd.Parameters.AddWithValue("@Parent_Code", auto.ParentId);
                    cmd.Parameters.AddWithValue("@Book_ID", bookId);
                    cmd.Parameters.AddWithValue("@Created_By", userId);
                    accountId = Convert.ToInt32(cmd.ExecuteScalar());
                }
                row.AccountCode = code;
            }

            using (SqlCommand cmd = new SqlCommand(
                "INSERT INTO dbo.AP_Vendors (Vendor_Name, VendorType, Vendor_Address, CreditDays, Country, Region, City, MobNo, Vendor_Phone1, " +
                "DrugLicenceNo, Vendor_STN, Vendor_NTN, Cnic, Vendor_Email, Contact_Person, Account_ID, TaxPayerTyp, CompanyType_Id, manufacture_id, " +
                "Company_ID, Book_ID, IsActive, Ismanual) " +
                "VALUES (@Vendor_Name, @VendorType, @Vendor_Address, @CreditDays, @Country, @Region, @City, @MobNo, @Vendor_Phone1, " +
                "@DrugLicenceNo, @Vendor_STN, @Vendor_NTN, @Cnic, @Vendor_Email, @Contact_Person, @Account_ID, @TaxPayerTyp, @CompanyType_Id, @manufacture_id, " +
                "@Company_ID, @Book_ID, @IsActive, @Ismanual); " +
                "DECLARE @id int = CAST(SCOPE_IDENTITY() AS int); " +
                "UPDATE dbo.AP_Vendors SET Vendor_Code = @id WHERE Vendor_ID = @id; " +
                "SELECT @id;", con, tran))
            {
                // Empty text and "0" for unselected lookups, as the Vendor form stores them
                cmd.Parameters.AddWithValue("@Vendor_Name", row.Get("Name"));
                cmd.Parameters.AddWithValue("@VendorType", Code(row, "Type"));
                cmd.Parameters.AddWithValue("@Vendor_Address", row.Get("Address"));
                cmd.Parameters.AddWithValue("@CreditDays", row.Get("CreditDays"));
                cmd.Parameters.AddWithValue("@Country", row.Get("Country"));
                cmd.Parameters.AddWithValue("@Region", Code(row, "Region"));
                cmd.Parameters.AddWithValue("@City", row.Get("City"));
                cmd.Parameters.AddWithValue("@MobNo", row.Get("Mobile"));
                cmd.Parameters.AddWithValue("@Vendor_Phone1", row.Get("Phone"));
                cmd.Parameters.AddWithValue("@DrugLicenceNo", row.Get("DrugLicence"));
                cmd.Parameters.AddWithValue("@Vendor_STN", row.Get("Stn"));
                cmd.Parameters.AddWithValue("@Vendor_NTN", row.Get("Ntn"));
                cmd.Parameters.AddWithValue("@Cnic", row.Get("Cnic"));
                cmd.Parameters.AddWithValue("@Vendor_Email", row.Get("Email"));
                cmd.Parameters.AddWithValue("@Contact_Person", row.Get("Focal"));
                cmd.Parameters.AddWithValue("@Account_ID", accountId);
                cmd.Parameters.AddWithValue("@TaxPayerTyp", Code(row, "TaxType"));
                cmd.Parameters.AddWithValue("@CompanyType_Id", Code(row, "CompanyType"));
                cmd.Parameters.AddWithValue("@manufacture_id", Code(row, "Manufacturer"));
                cmd.Parameters.AddWithValue("@Company_ID", companyId);
                cmd.Parameters.AddWithValue("@Book_ID", bookId);
                cmd.Parameters.AddWithValue("@IsActive", row.IsActive);
                cmd.Parameters.AddWithValue("@Ismanual", isManual);
                row.VendorCode = Convert.ToString(cmd.ExecuteScalar());
            }
        }

        private static string Code(VendorRow row, string key)
        {
            string code;
            return row.Codes.TryGetValue(key, out code) ? code : "0";
        }

        #endregion

        #region Result display

        private void BindResult(List<VendorRow> rows, bool saved)
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("Row");
            dt.Columns.Add("Vendor Name");
            dt.Columns.Add("Vendor Type");
            dt.Columns.Add("Status");
            dt.Columns.Add("Message");
            dt.Columns.Add("Vendor Code");
            dt.Columns.Add("Account Code");

            foreach (VendorRow r in rows.OrderBy(x => x.Errors.Count > 0 ? 0 : x.SkipReason != null ? 1 : 2).ThenBy(x => x.RowNo))
            {
                string status, message;
                if (r.Errors.Count > 0) { status = "Error"; message = string.Join(" ", r.Errors); }
                else if (r.SkipReason != null) { status = "Skipped"; message = r.SkipReason; }
                else if (saved) { status = "Saved"; message = r.ManualAccountId != null ? "Linked to existing account." : "New GL account created."; }
                else { status = "Valid"; message = "Not saved because of errors in other rows."; }

                dt.Rows.Add(r.RowNo, r.Get("Name"), r.Get("Type"), status, message, r.VendorCode, saved ? r.AccountCode : "");
            }
            gvResult.DataSource = dt;
            gvResult.DataBind();
            pnlResult.Visible = true;
        }

        protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType != DataControlRowType.DataRow) return;
            string status = Convert.ToString(DataBinder.Eval(e.Row.DataItem, "Status"));
            e.Row.CssClass = status == "Saved" ? "vu-ok" : status == "Skipped" ? "vu-skip" : status == "Error" ? "vu-err" : "";
        }

        private void SetSummary(string html)
        {
            litSummary.Text = html;
            pnlResult.Visible = true;
        }

        private void ShowMessage(string message, string icon)
        {
            ExcelUploadHelper.ShowMessage(this, message, icon);
        }

        #endregion

        #region Sample workbook

        protected void btnDownloadSample_Click(object sender, EventArgs e)
        {
            Dictionary<string, Lookup> lookups;
            using (SqlConnection con = new SqlConnection(DBClass.ConnectionString()))
            {
                con.Open();
                lookups = LoadLookups(con, null);
            }
            ExcelUploadHelper.SendFile(this, BuildSampleWorkbook(lookups), "VendorsUploadSample.xlsx");
        }

        private static byte[] BuildSampleWorkbook(Dictionary<string, Lookup> lookups)
        {
            List<ColumnDef> lookupCols = Columns.Where(c => c.LookupSet != null).ToList();

            // Vendors: header + text-formatted columns + drop-downs pointing at the Lookups sheet
            ExcelUploadHelper.SampleSheet vendors = new ExcelUploadHelper.SampleSheet
            {
                Name = "Vendors",
                TextColumns = true,
                FreezeHeader = true,
                Widths = Columns.Select(c => c.Width).ToArray()
            };
            vendors.Rows.Add(Columns.Select(c => c.Header + (c.Required ? " *" : "")).ToArray());
            for (int i = 0; i < Columns.Length; i++)
            {
                if (Columns[i].LookupSet != null)
                {
                    int count = lookups[Columns[i].LookupSet].Items.Count;
                    if (count == 0) continue;
                    string col = ExcelUploadHelper.ColumnName(lookupCols.IndexOf(Columns[i]) * 2);
                    vendors.ListValidations[i] = "Lookups!$" + col + "$2:$" + col + "$" + (count + 1);
                }
                else if (Columns[i].Key == "Active")
                {
                    vendors.ListValidations[i] = "\"Yes,No\"";
                }
            }

            ExcelUploadHelper.SampleSheet help = new ExcelUploadHelper.SampleSheet { Name = "Instructions", Widths = new[] { 24, 10, 12, 90 } };
            help.Rows.Add(new[] { "Column", "Required", "Max Length", "Notes" });
            foreach (ColumnDef c in Columns)
                help.Rows.Add(new[] { c.Header, c.Required ? "Yes" : "No", c.LookupSet != null ? "" : c.MaxLength.ToString(),
                    c.Note ?? (c.LookupSet != null ? "Pick from the list (name or code from the Lookups sheet)." : "") });

            // Lookups: description + code pairs
            ExcelUploadHelper.SampleSheet lk = new ExcelUploadHelper.SampleSheet
            {
                Name = "Lookups",
                Widths = lookupCols.SelectMany(c => new[] { 22, 8 }).ToArray()
            };
            int maxItems = lookupCols.Count == 0 ? 0 : lookupCols.Max(c => lookups[c.LookupSet].Items.Count);
            for (int r = 0; r <= maxItems; r++)
            {
                string[] row = new string[lookupCols.Count * 2];
                for (int i = 0; i < lookupCols.Count; i++)
                {
                    List<KeyValuePair<string, string>> items = lookups[lookupCols[i].LookupSet].Items;
                    if (r == 0) { row[i * 2] = lookupCols[i].Header; row[i * 2 + 1] = "Code"; }
                    else if (r - 1 < items.Count)
                    {
                        row[i * 2] = items[r - 1].Value == "" ? items[r - 1].Key : items[r - 1].Value;
                        row[i * 2 + 1] = items[r - 1].Key;
                    }
                }
                lk.Rows.Add(row);
            }

            return ExcelUploadHelper.BuildWorkbook(new[] { vendors, help, lk });
        }

        #endregion
    }
}
