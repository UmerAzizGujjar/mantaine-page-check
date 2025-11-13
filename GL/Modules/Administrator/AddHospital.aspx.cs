using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.Administrator
{
    
        public partial class AddHospital : System.Web.UI.Page
        {
            protected void Page_Load(object sender, EventArgs e)
            {
                // Add any page load logic here if needed
            }

            [WebMethod]
            public static string SaveHospital(HospitalData data)
            {
                try
                {
                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

                    // Check for duplicate hospital name (excluding current record if editing)
                    bool hospitalExists = (from h in db.HospitalDetails
                                           where h.HospitalName.ToLower() == data.HospitalName.ToLower()
                                           && h.Id != data.Id
                                           select h).Any();

                    if (hospitalExists)
                    {
                        return "Hospital Name Already Exists";
                    }

                    // Get current user
                    string currentUser = HttpContext.Current.User.Identity.Name;

                    if (data.Id > 0)
                    {
                        // Update existing hospital
                        var hospital = (from h in db.HospitalDetails
                                        where h.Id == data.Id
                                        select h).FirstOrDefault();

                        if (hospital != null)
                        {
                            hospital.HospitalName = data.HospitalName;
                            hospital.ServerName = data.ServerName;
                            hospital.DatabaseName = data.DatabaseName;
                            hospital.UserID = data.UserID;

                            // Only update password if provided
                            if (!string.IsNullOrEmpty(data.Password))
                            {
                                string salt = GenerateSalt();
                                string hashedPassword = HashPassword(data.Password, salt);
                                hospital.Password = hashedPassword;
                                hospital.PasswordSalt = salt;
                            }

                            hospital.IsActive = data.IsActive;
                            hospital.UpdatedBy = currentUser;
                            hospital.UpdatedTime = DateTime.Now;

                            db.SubmitChanges();
                            return "success";
                        }
                        else
                        {
                            return "Hospital not found";
                        }
                    }
                    else
                    {
                        // Create new hospital
                        string salt = GenerateSalt();
                        string hashedPassword = HashPassword(data.Password, salt);

                        HospitalDetail newHospital = new HospitalDetail
                        {
                            HospitalName = data.HospitalName,
                            ServerName = data.ServerName,
                            DatabaseName = data.DatabaseName,
                            UserID = data.UserID,
                            Password = hashedPassword,
                            PasswordSalt = salt,
                            IsActive = data.IsActive,
                            CreatedBy = currentUser,
                            CreatedTime = DateTime.Now
                        };

                        db.HospitalDetails.InsertOnSubmit(newHospital);
                        db.SubmitChanges();
                        return "success";
                    }
                }
                catch (Exception ex)
                {
                    return "Error: " + ex.Message;
                }
            }

            [WebMethod]
            public static HospitalData GetHospitalById(HospitalIdRequest data)
            {
                try
                {
                    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

                    var hospital = (from h in db.HospitalDetails
                                    where h.Id == int.Parse(data.hospitalId)
                                    select new HospitalData
                                    {
                                        Id = h.Id,
                                        HospitalName = h.HospitalName,
                                        ServerName = h.ServerName,
                                        DatabaseName = h.DatabaseName,
                                        UserID = h.UserID,
                                        IsActive = h.IsActive ?? true,
                                        Password = "" // Don't send password to client
                                    }).FirstOrDefault();

                    return hospital;
                }
                catch (Exception ex)
                {
                    return null;
                }
            }

            [WebMethod]
            public static string TestDatabaseConnection(ConnectionTestData data)
            {
                try
                {
                    string connectionString = $"Server={data.ServerName};Database={data.DatabaseName};User Id={data.UserID};Password={data.Password};";

                    using (SqlConnection connection = new SqlConnection(connectionString))
                    {
                        connection.Open();
                        // If we reach here, connection is successful
                        return "success";
                    }
                }
                catch (SqlException ex)
                {
                    return "Connection Failed: " + ex.Message;
                }
                catch (Exception ex)
                {
                    return "Error: " + ex.Message;
                }
            }

            private static string GenerateSalt()
            {
                byte[] saltBytes = new byte[16];
                using (var rng = new RNGCryptoServiceProvider())
                {
                    rng.GetBytes(saltBytes);
                }
                return Convert.ToBase64String(saltBytes);
            }

            private static string HashPassword(string password, string salt)
            {
                var combinedPasswordSalt = password + salt;

                using (SHA256 sha256 = SHA256.Create())
                {
                    byte[] bytes = Encoding.UTF8.GetBytes(combinedPasswordSalt);
                    byte[] hash = sha256.ComputeHash(bytes);

                    return Convert.ToBase64String(hash);
                }
            }

            public class HospitalData
            {
                public int Id { get; set; }
                public string HospitalName { get; set; }
                public string ServerName { get; set; }
                public string DatabaseName { get; set; }
                public string UserID { get; set; }
                public string Password { get; set; }
                public bool IsActive { get; set; }
            }

            public class HospitalIdRequest
            {
                public string hospitalId { get; set; }
            }

            public class ConnectionTestData
            {
                public string ServerName { get; set; }
                public string DatabaseName { get; set; }
                public string UserID { get; set; }
                public string Password { get; set; }
            }
        }
    }
