using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;
using System.Web.UI;
using System.Web.UI.WebControls;
using SheetRow = PMS.ExcelUploadHelper.SheetRow;

namespace PMS
{
    /// <summary>
    /// Bulk-creates login users the same way Modules/Accounts/RegisterUser.aspx does: aspnet_Users + aspnet_Membership
    /// with the SHA1(password + salt) hash that Login.aspx checks (not the stock Membership provider hash), plus
    /// optional roles in aspnet_UsersInRoles (AllCompany = 1, like ManageRoles.aspx). Every user gets DefaultPassword.
    /// </summary>
    public partial class UsersUpload : System.Web.UI.Page
    {
        private const string DefaultPassword = "123456";
        private static readonly DateTime NeverDate = new DateTime(1754, 1, 1);

        private class ColumnDef
        {
            public string Key;
            public string Header;
            public int MaxLength;
            public bool Required;
            public int Width;
            public string Note;
            public string[] Aliases;
        }

        private static readonly ColumnDef[] Columns =
        {
            new ColumnDef { Key = "UserName", Header = "User Name", MaxLength = 256, Required = true, Width = 26, Note = "Required. The login name. User names that already exist are skipped.", Aliases = new[] { "Username", "Login", "Login Name", "User" } },
            new ColumnDef { Key = "Email", Header = "Email", MaxLength = 256, Width = 30, Note = "Optional. Must not be used by another user.", Aliases = new[] { "E-mail", "Email Address" } },
            new ColumnDef { Key = "Mobile", Header = "Mobile No", MaxLength = 50, Width = 16, Note = "Optional. Used for OTP users.", Aliases = new[] { "Mobile", "Cell No", "Mob No" } },
            new ColumnDef { Key = "EmpCode", Header = "Employee Code", MaxLength = 50, Width = 16, Aliases = new[] { "Emp Code", "Employee No", "Emp No" } },
            new ColumnDef { Key = "Roles", Header = "Role", MaxLength = 2000, Width = 30, Note = "Optional. Role name from the Roles sheet; several roles can be separated by commas.", Aliases = new[] { "Roles", "Role Name", "User Role" } },
        };

        private class UserRow
        {
            public int RowNo;
            public Dictionary<string, string> Values = new Dictionary<string, string>();
            public List<string> Errors = new List<string>();
            public string SkipReason;
            public List<Guid> RoleIds = new List<Guid>();
            public List<string> RoleNames = new List<string>();

            public string Get(string key)
            {
                string v;
                return Values.TryGetValue(key, out v) ? v : "";
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            litPassword.Text = DefaultPassword;
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
                sheet = ExcelUploadHelper.Read(FileUpload, "Users");
            }
            catch (Exception ex)
            {
                ShowMessage("Could not read the file: " + ex.Message, "error");
                return;
            }

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

            List<UserRow> rows = new List<UserRow>();
            for (int i = headerIndex + 1; i < sheet.Count; i++)
            {
                SheetRow sr = sheet[i];
                if (sr.IsBlank) continue;
                UserRow row = new UserRow { RowNo = sr.Number };
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
                ShowMessage("No user rows found under the header row.", "warning");
                return;
            }

            using (SqlConnection con = new SqlConnection(DBClass.ConnectionString()))
            {
                con.Open();
                Guid appId = GetApplicationId(con, null);
                ValidateRows(con, rows, appId);

                List<UserRow> toInsert = rows.Where(r => r.Errors.Count == 0 && r.SkipReason == null).ToList();
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
                    SetSummary(string.Format("<span class='label label-warning'>Nothing to save</span> All {0} user(s) already exist or are duplicates.", rows.Count));
                    ShowMessage("Nothing to save: all users in the file already exist.", "warning");
                    return;
                }

                int current = 0;
                using (SqlTransaction tran = con.BeginTransaction())
                {
                    try
                    {
                        List<string> bitColumns = GetUserFlagColumns(con, tran);
                        foreach (UserRow row in toInsert)
                        {
                            current = row.RowNo;
                            InsertUser(con, tran, row, appId, bitColumns);
                        }
                        tran.Commit();
                    }
                    catch (Exception ex)
                    {
                        try { tran.Rollback(); } catch { }
                        BindResult(rows, false);
                        string msg = (current > 0 ? "Row " + current + ": " : "") + ex.Message;
                        SetSummary("<span class='label label-danger'>Nothing saved</span> " + Server.HtmlEncode(msg));
                        ShowMessage("Upload failed, nothing was saved. " + msg, "error");
                        return;
                    }
                }

                BindResult(rows, true);
                SetSummary(string.Format("<span class='label label-success'>Saved</span> {0} user(s) created{1}. Password for all of them: <b>{2}</b>",
                    toInsert.Count, skipCount > 0 ? ", " + skipCount + " skipped" : "", DefaultPassword));
                ShowMessage(toInsert.Count + " user(s) created with password " + DefaultPassword + "." + (skipCount > 0 ? " " + skipCount + " skipped (already exist)." : ""), "success");
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
                    if (ExcelUploadHelper.NormalizeHeader(col.Header) == h
                        || (col.Aliases != null && col.Aliases.Any(a => ExcelUploadHelper.NormalizeHeader(a) == h)))
                    {
                        map[col.Key] = i;
                        break;
                    }
                }
            }
            return map;
        }

        private static Guid GetApplicationId(SqlConnection con, SqlTransaction tran)
        {
            using (SqlCommand cmd = new SqlCommand("SELECT TOP 1 ApplicationId FROM dbo.aspnet_Applications WHERE LoweredApplicationName = '/'", con, tran))
            {
                object o = cmd.ExecuteScalar();
                if (o == null || o == DBNull.Value)
                    throw new Exception("Application '/' not found in aspnet_Applications.");
                return (Guid)o;
            }
        }

        private static Dictionary<string, Guid> LoadRoles(SqlConnection con, SqlTransaction tran, Guid appId)
        {
            Dictionary<string, Guid> roles = new Dictionary<string, Guid>(StringComparer.OrdinalIgnoreCase);
            using (SqlCommand cmd = new SqlCommand("SELECT RoleName, RoleId FROM dbo.aspnet_Roles WHERE ApplicationId = @ApplicationId ORDER BY RoleName", con, tran))
            {
                cmd.Parameters.AddWithValue("@ApplicationId", appId);
                using (SqlDataReader dr = cmd.ExecuteReader())
                    while (dr.Read())
                    {
                        string name = dr.GetString(0).Trim();
                        if (!roles.ContainsKey(name)) roles[name] = dr.GetGuid(1);
                    }
            }
            return roles;
        }

        private static HashSet<string> LoadSet(SqlConnection con, string sql)
        {
            HashSet<string> set = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                using (SqlDataReader dr = cmd.ExecuteReader())
                    while (dr.Read())
                        if (!dr.IsDBNull(0)) set.Add(dr.GetString(0).Trim());
            }
            return set;
        }

        private void ValidateRows(SqlConnection con, List<UserRow> rows, Guid appId)
        {
            // Not filtered by application: Login.aspx and RegisterUser.aspx look users and emails up across all of them
            HashSet<string> existingUsers = LoadSet(con, "SELECT UserName FROM dbo.aspnet_Users");
            HashSet<string> existingEmails = LoadSet(con, "SELECT LoweredEmail FROM dbo.aspnet_Membership WHERE ISNULL(LoweredEmail, '') <> ''");
            Dictionary<string, Guid> roles = LoadRoles(con, null, appId);

            Dictionary<string, int> namesInFile = new Dictionary<string, int>(StringComparer.OrdinalIgnoreCase);
            Dictionary<string, int> emailsInFile = new Dictionary<string, int>(StringComparer.OrdinalIgnoreCase);
            Regex email = new Regex(@"^[^@\s]+@[^@\s]+\.[^@\s]+$");

            foreach (UserRow row in rows)
            {
                foreach (ColumnDef col in Columns)
                {
                    string val = row.Get(col.Key);
                    if (val == "" && col.Required) row.Errors.Add(col.Header + " is required.");
                    else if (val.Length > col.MaxLength) row.Errors.Add(col.Header + " is longer than " + col.MaxLength + " characters.");
                }

                string mail = row.Get("Email");
                if (mail != "")
                {
                    int firstRow;
                    if (!email.IsMatch(mail)) row.Errors.Add("Email '" + mail + "' is not valid.");
                    else if (existingEmails.Contains(mail)) row.Errors.Add("Email '" + mail + "' is already used by another user.");
                    else if (emailsInFile.TryGetValue(mail, out firstRow)) row.Errors.Add("Email '" + mail + "' is also used in row " + firstRow + ".");
                    else emailsInFile[mail] = row.RowNo;
                }

                foreach (string roleName in row.Get("Roles").Split(new[] { ',', ';' }, StringSplitOptions.RemoveEmptyEntries).Select(r => r.Trim()).Where(r => r != ""))
                {
                    Guid roleId;
                    if (!roles.TryGetValue(roleName, out roleId))
                        row.Errors.Add("Role '" + roleName + "' does not exist.");
                    else if (!row.RoleIds.Contains(roleId))
                    {
                        row.RoleIds.Add(roleId);
                        row.RoleNames.Add(roleName);
                    }
                }

                string name = row.Get("UserName");
                if (name != "")
                {
                    int firstRow;
                    if (existingUsers.Contains(name)) row.SkipReason = "User already exists.";
                    else if (namesInFile.TryGetValue(name, out firstRow)) row.SkipReason = "Same user name as row " + firstRow + ".";
                    else namesInFile[name] = row.RowNo;
                }
            }
        }

        #endregion

        #region Save

        // The permission check-boxes of Register User are nullable bit columns on aspnet_Users; an unticked box saves 0.
        private static List<string> GetUserFlagColumns(SqlConnection con, SqlTransaction tran)
        {
            List<string> cols = new List<string>();
            using (SqlCommand cmd = new SqlCommand(
                "SELECT name FROM sys.columns WHERE object_id = OBJECT_ID('dbo.aspnet_Users') AND system_type_id = 104 AND is_nullable = 1 AND is_computed = 0", con, tran))
            using (SqlDataReader dr = cmd.ExecuteReader())
                while (dr.Read()) cols.Add(dr.GetString(0));
            return cols;
        }

        private static void InsertUser(SqlConnection con, SqlTransaction tran, UserRow row, Guid appId, List<string> bitColumns)
        {
            Guid userId = Guid.NewGuid();
            string userName = row.Get("UserName");
            string mobile = row.Get("Mobile");
            string mail = row.Get("Email");

            string flagCols = string.Concat(bitColumns.Select(c => ", [" + c.Replace("]", "]]") + "]"));
            string flagVals = string.Concat(bitColumns.Select(c => ", 0"));
            using (SqlCommand cmd = new SqlCommand(
                "INSERT INTO dbo.aspnet_Users (ApplicationId, UserId, UserName, LoweredUserName, IsAnonymous, LastActivityDate, mobileno, Emp_Code, Gl_Account, cashier" + flagCols + ") " +
                "VALUES (@ApplicationId, @UserId, @UserName, @LoweredUserName, 0, @Never, @mobileno, @Emp_Code, '0', '0'" + flagVals + ")", con, tran))
            {
                cmd.Parameters.AddWithValue("@ApplicationId", appId);
                cmd.Parameters.AddWithValue("@UserId", userId);
                cmd.Parameters.AddWithValue("@UserName", userName);
                cmd.Parameters.AddWithValue("@LoweredUserName", userName.ToLowerInvariant());
                cmd.Parameters.AddWithValue("@Never", NeverDate);
                cmd.Parameters.AddWithValue("@mobileno", mobile == "" ? (object)DBNull.Value : mobile);
                cmd.Parameters.AddWithValue("@Emp_Code", row.Get("EmpCode") == "" ? (object)DBNull.Value : row.Get("EmpCode"));
                cmd.ExecuteNonQuery();
            }

            string salt = GenerateSalt();
            using (SqlCommand cmd = new SqlCommand(
                "INSERT INTO dbo.aspnet_Membership (ApplicationId, UserId, Password, PasswordFormat, PasswordSalt, Email, LoweredEmail, IsApproved, IsLockedOut, " +
                "CreateDate, LastLoginDate, LastPasswordChangedDate, LastLockoutDate, FailedPasswordAttemptCount, FailedPasswordAttemptWindowStart, " +
                "FailedPasswordAnswerAttemptCount, FailedPasswordAnswerAttemptWindowStart, mobileno) " +
                "VALUES (@ApplicationId, @UserId, @Password, 1, @PasswordSalt, @Email, @LoweredEmail, 1, 0, " +
                "GETDATE(), @Never, GETDATE(), @Never, 0, @Never, 0, @Never, @mobileno)", con, tran))
            {
                cmd.Parameters.AddWithValue("@ApplicationId", appId);
                cmd.Parameters.AddWithValue("@UserId", userId);
                cmd.Parameters.AddWithValue("@Password", EncryptPassword(DefaultPassword, salt));
                cmd.Parameters.AddWithValue("@PasswordSalt", salt);
                cmd.Parameters.AddWithValue("@Email", mail == "" ? (object)DBNull.Value : mail);
                cmd.Parameters.AddWithValue("@LoweredEmail", mail == "" ? (object)DBNull.Value : mail.ToLowerInvariant());
                cmd.Parameters.AddWithValue("@Never", NeverDate);
                cmd.Parameters.AddWithValue("@mobileno", mobile == "" ? (object)DBNull.Value : mobile);
                cmd.ExecuteNonQuery();
            }

            foreach (Guid roleId in row.RoleIds)
            {
                using (SqlCommand cmd = new SqlCommand(
                    "INSERT INTO dbo.aspnet_UsersInRoles (UserId, RoleId, AllCompany, Company_ID) VALUES (@UserId, @RoleId, 1, 0)", con, tran))
                {
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    cmd.Parameters.AddWithValue("@RoleId", roleId);
                    cmd.ExecuteNonQuery();
                }
            }
        }

        // Same hashing as RegisterUser.aspx.cs / Login.aspx.cs
        private static string GenerateSalt()
        {
            byte[] saltBytes = new byte[16];
            using (RNGCryptoServiceProvider rng = new RNGCryptoServiceProvider())
                rng.GetBytes(saltBytes);
            return Convert.ToBase64String(saltBytes);
        }

        private static string EncryptPassword(string password, string salt)
        {
            using (SHA1 sha1 = SHA1.Create())
                return Convert.ToBase64String(sha1.ComputeHash(Encoding.UTF8.GetBytes(password + salt)));
        }

        #endregion

        #region Result display

        private void BindResult(List<UserRow> rows, bool saved)
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("Row");
            dt.Columns.Add("User Name");
            dt.Columns.Add("Email");
            dt.Columns.Add("Role");
            dt.Columns.Add("Status");
            dt.Columns.Add("Message");

            foreach (UserRow r in rows.OrderBy(x => x.Errors.Count > 0 ? 0 : x.SkipReason != null ? 1 : 2).ThenBy(x => x.RowNo))
            {
                string status, message;
                if (r.Errors.Count > 0) { status = "Error"; message = string.Join(" ", r.Errors); }
                else if (r.SkipReason != null) { status = "Skipped"; message = r.SkipReason; }
                else if (saved) { status = "Saved"; message = "Login created. Password: " + DefaultPassword; }
                else { status = "Valid"; message = "Not saved because of errors in other rows."; }

                dt.Rows.Add(r.RowNo, r.Get("UserName"), r.Get("Email"), string.Join(", ", r.RoleNames), status, message);
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
            List<string> roleNames;
            using (SqlConnection con = new SqlConnection(DBClass.ConnectionString()))
            {
                con.Open();
                roleNames = LoadRoles(con, null, GetApplicationId(con, null)).Keys.OrderBy(r => r).ToList();
            }

            ExcelUploadHelper.SampleSheet users = new ExcelUploadHelper.SampleSheet
            {
                Name = "Users",
                TextColumns = true,
                FreezeHeader = true,
                Widths = Columns.Select(c => c.Width).ToArray()
            };
            users.Rows.Add(Columns.Select(c => c.Header + (c.Required ? " *" : "")).ToArray());
            if (roleNames.Count > 0)
                users.ListValidations[Array.FindIndex(Columns, c => c.Key == "Roles")] = "Roles!$A$2:$A$" + (roleNames.Count + 1);

            ExcelUploadHelper.SampleSheet help = new ExcelUploadHelper.SampleSheet { Name = "Instructions", Widths = new[] { 18, 10, 12, 90 } };
            help.Rows.Add(new[] { "Column", "Required", "Max Length", "Notes" });
            foreach (ColumnDef c in Columns)
                help.Rows.Add(new[] { c.Header, c.Required ? "Yes" : "No", c.MaxLength.ToString(), c.Note ?? "" });
            help.Rows.Add(new string[0]);
            help.Rows.Add(new[] { "Password", "", "", "Every uploaded user gets the password " + DefaultPassword + "." });

            ExcelUploadHelper.SampleSheet rolesSheet = new ExcelUploadHelper.SampleSheet { Name = "Roles", Widths = new[] { 34 } };
            rolesSheet.Rows.Add(new[] { "Role" });
            foreach (string r in roleNames) rolesSheet.Rows.Add(new[] { r });

            ExcelUploadHelper.SendFile(this, ExcelUploadHelper.BuildWorkbook(new[] { users, help, rolesSheet }), "UsersUploadSample.xlsx");
        }

        #endregion
    }
}
