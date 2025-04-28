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
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    string userId = HttpContext.Current.Session["UserId"].ToString();

                    var Total_Vendors = _dbContext.AP_Vendors.Count();
                    var Vendors = from V in _dbContext.AP_Vendors
                                  where
                                       ((V.Vendor_ID.ToString().Contains(searchValue) || V.Vendor_Name.ToString().Contains(searchValue) || V.Vendor_Phone1.ToString().Contains(searchValue) || V.Contact_Person.ToString().Contains(searchValue) || V.Vendor_Address.ToString().Contains(searchValue) || V.City.ToString().Contains(searchValue) || V.Vendor_NTN.ToString().Contains(searchValue)))
                                  select new
                                  {
                                      Vendor_ID = V.Vendor_ID,
                                      Vendor_Name = V.Vendor_Name,
                                      Contact_Person = V.Contact_Person,
                                      Vendor_Phone1 = V.Vendor_Phone1,
                                      Vendor_Address = V.Vendor_Address,                                     
                                      City = V.City,
                                      Vendor_NTN = V.Vendor_NTN,
                                  };

                    var FilteredCount = Vendors.Count();
                    switch (sortColumn)
                    {
                        case "Vendor_ID":
                            Vendors = sortColumnDirection == "asc" ? Vendors.OrderBy(a => a.Vendor_ID) : Vendors.OrderByDescending(a => a.Vendor_ID);
                            break;
                        case "Vendor_Phone1":
                            Vendors = sortColumnDirection == "asc" ? Vendors.OrderBy(b => b.Vendor_Phone1) : Vendors.OrderByDescending(a => a.Vendor_Phone1);
                            break;
                        case "Vendor_Name":
                            Vendors = sortColumnDirection == "asc" ? Vendors.OrderBy(b => b.Vendor_Name) : Vendors.OrderByDescending(a => a.Vendor_Name);
                            break;
                        case "Contact_Person":
                            Vendors = sortColumnDirection == "asc" ? Vendors.OrderBy(b => b.Contact_Person) : Vendors.OrderByDescending(a => a.Contact_Person);
                            break;
                        case "City":
                            Vendors = sortColumnDirection == "asc" ? Vendors.OrderBy(b => b.City) : Vendors.OrderByDescending(a => a.City);
                            break;
                        case "Vendor_NTN":
                            Vendors = sortColumnDirection == "asc" ? Vendors.OrderBy(b => b.Vendor_NTN) : Vendors.OrderByDescending(a => a.Vendor_NTN);
                            break;
                        default:
                            Vendors = Vendors.OrderBy(a => a.Vendor_ID);
                            break;
                    }

                    var VendorList = Vendors.Skip(start).Take(length).ToList();

                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Vendors, data = VendorList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Item list", ex);
            }
        }
    }
}

   

      