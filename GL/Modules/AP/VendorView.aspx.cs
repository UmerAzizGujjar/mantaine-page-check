using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.AP
{
    public partial class VendorView : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static bool isDeleteAllow()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            bool value = Convert.ToBoolean(DBClass.getField("select  isnull(AllowPatientDelete,0) from aspnet_users where username='" + AppConfig.UserName + "'"));
            return value;

        }

        [WebMethod]
        public static bool DeleteRecord(string Vendor_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            SqlTransaction tranObj = null;
            SqlConnection con = new SqlConnection(DBClass.ConnectionString());
            con.Open();
            tranObj = con.BeginTransaction();
            try
            {
                var Igp_Id = (from itm in db.AP_Vendors
                              where (itm.Vendor_ID == int.Parse(Vendor_ID))
                              select itm.Vendor_ID).FirstOrDefault();
                if (Igp_Id != 0)
                {
                    DBClass.exectueQuery("delete AP_Vendors where Vendor_ID =" + Igp_Id, tranObj, con);
                    // DBClass.exectueQuery("delete Igp_master where Igp_Id =" + Igp_Id, tranObj, con);
                    tranObj.Commit();
                }
                else
                {
                    tranObj.Rollback();
                    return false;
                }
            }
#pragma warning disable CS0168 // The variable 'ex' is declared but never used
            catch (Exception ex)
#pragma warning restore CS0168 // The variable 'ex' is declared but never used
            {
                if (tranObj != null)
                    tranObj.Rollback();
                return false;
            }
            return true;
        }


        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue, string filterStatus = "all")
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    string userId = HttpContext.Current.Session["UserId"].ToString();

                    var Total_Vendors = _dbContext.AP_Vendors.Count();

                    // Start with base query
                    var VendorsQuery = from V in _dbContext.AP_Vendors
                                       select new
                                       {
                                           Vendor_ID = V.Vendor_ID,
                                           Vendor_Name = V.Vendor_Name,
                                           Contact_Person = V.Contact_Person,
                                           Vendor_Phone1 = V.Vendor_Phone1,
                                           Vendor_Address = V.Vendor_Address,
                                           City = V.City,
                                           Vendor_NTN = V.Vendor_NTN,
                                           Account_ID = V.Account_ID, 
                                           AccountID = (from a in _dbContext.GL_Accounts
                                                        where a.Account_ID == V.Account_ID
                                                        select new { Account = a.Account_Name }).FirstOrDefault().Account.ToString(),
                                       };

                    if (filterStatus == "mapped")
                    {
                        VendorsQuery = VendorsQuery.Where(v => v.Account_ID != null && v.Account_ID > 0);
                    }
                    else if (filterStatus == "unmapped")
                    {
                        VendorsQuery = VendorsQuery.Where(v => v.Account_ID == null || v.Account_ID == 0);
                    }
                    if (!string.IsNullOrEmpty(searchValue))
                    {
                        VendorsQuery = VendorsQuery.Where(v =>
                            v.Vendor_ID.ToString().Contains(searchValue) ||
                            v.Vendor_Name.ToString().Contains(searchValue) ||
                            v.Vendor_Phone1.ToString().Contains(searchValue) ||
                            v.Contact_Person.ToString().Contains(searchValue) ||
                            v.Vendor_Address.ToString().Contains(searchValue) ||
                            v.City.ToString().Contains(searchValue) ||
                            v.Vendor_NTN.ToString().Contains(searchValue));
                    }

                    var FilteredCount = VendorsQuery.Count();

                    if (length == -1 || length > 100000)
                    {
                        start = 0;
                        length = FilteredCount;
                    }
                    switch (sortColumn)
                    {
                        case "Vendor_Name":
                            VendorsQuery = sortColumnDirection == "asc" ? VendorsQuery.OrderBy(b => b.Vendor_Name) : VendorsQuery.OrderByDescending(a => a.Vendor_Name);
                            break;
                        default:
                            VendorsQuery = VendorsQuery.OrderByDescending(a => a.Vendor_ID);
                            break;
                    }

                    var VendorList = VendorsQuery.Skip(start).Take(length).ToList();

                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Vendors, data = VendorList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Item list", ex);
            }
        }

        [WebMethod]
        public static string GetUserColumnPreferences()
        {
            try
            {
                string userId = AppConfig.UserID.ToString();
                string pageName = "VendorsView";

                using (var db = new DataBaseDataContext())
                {
                    var pref = db.UserDataTablePreferences
                                  .FirstOrDefault(p => p.UserID == userId && p.PageName == pageName);

                    if (pref != null)
                        return pref.ColumnVisibility;
                    else
                        return "";
                }
            }
            catch (Exception ex)
            {
                return "";
            }
        }

        [WebMethod]
        public static void SaveUserColumnPreferences(string visibilityJson)
        {
            try
            {
                string userId = AppConfig.UserID.ToString();
                string pageName = "VendorsView";

                using (var db = new DataBaseDataContext())
                {
                    var existing = db.UserDataTablePreferences
                                     .FirstOrDefault(p => p.UserID == userId && p.PageName == pageName);

                    if (existing != null)
                    {
                        existing.ColumnVisibility = visibilityJson;
                    }
                    else
                    {
                        db.UserDataTablePreferences.InsertOnSubmit(new UserDataTablePreference
                        {
                            UserID = userId,
                            PageName = pageName,
                            ColumnVisibility = visibilityJson
                        });
                    }

                    db.SubmitChanges();
                }
            }
            catch (Exception ex)
            {
                throw;
            }
        }

        [WebMethod]
        public static void SavePageState(int pageIndex)
        {
            if (HttpContext.Current.Session != null)
            {
                HttpContext.Current.Session["VendorView_PageIndex"] = pageIndex;
            }
        }

        [WebMethod]
        public static int GetPageState()
        {
            if (HttpContext.Current.Session != null && HttpContext.Current.Session["VendorView_PageIndex"] != null)
            {
                return Convert.ToInt32(HttpContext.Current.Session["VendorView_PageIndex"]);
            }
            return 0; // Default to first page
        }
    }
}

   

      