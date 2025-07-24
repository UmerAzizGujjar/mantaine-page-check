using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using Telerik.Web;
using static PMS.Vendor;

namespace PMS
{
    public partial class Vendor : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static String Getitem(int ItemID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var itemDetail = db.spGetitemsDetails(ItemID).ToList();
                return (new JavaScriptSerializer()).Serialize(itemDetail);
            }


        }

        [WebMethod]
        public static string GetNewVendorNo()
        {

            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var PO_No = DBClass.GetNewNumber("Vendor_ID", "AP_Vendors", "");
            return PO_No.ToString();
        }


        [WebMethod]
        public static string loadPharmacyItemList()
        {
            string result = string.Empty;
            DataBaseDataContext db = new DataBaseDataContext();
            var itemsList = (from i in db.INV_Items where i.Pharmacy_Item == true && i.IsPharmacyItem == true && i.Services!=true && i.Hospital_Services == false && i.Book_ID == 1 select new { i.Item_ID, name = i.Item_Code.ToString() + '-' + i.Description }).ToList();
            if (itemsList != null)
            {
                result = (new JavaScriptSerializer()).Serialize(itemsList);
            }
            return result;
        }
        [WebMethod]
        public static string loadGeneralItemList()
        {
            string result = string.Empty;
            DataBaseDataContext db = new DataBaseDataContext();
            var itemsList = (from i in db.INV_Items where i.Pharmacy_Item == false && i.IsPharmacyItem == false && i.Hospital_Services == false && i.Services != true && i.Book_ID == 1 select new { i.Item_ID, name = i.Item_Code.ToString() + '-' + i.Description }).ToList();
            if (itemsList != null)
            {
                result = (new JavaScriptSerializer()).Serialize(itemsList);
            }
            return result;
        }

        [WebMethod]

        public static string loadPayableCode()
        {
            string result = string.Empty;
            DataBaseDataContext db = new DataBaseDataContext();
            var itemsList = (from i in db.GL_Accounts where i.Levels == 4 select new { i.Account_ID, name = i.Account_Code.ToString() + '-' + i.Account_Name }).ToList();
            if (itemsList != null)
            {
                result = (new JavaScriptSerializer()).Serialize(itemsList);
            }
            return result;
        }
        public static string LoadAutoAccount(bool Ismanual)
        {
            string sql = "";
            string accountID = "0";
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            sys_Parm AccountPram = new sys_Parm();
            if (Ismanual == false)
            {
                AccountPram = (from a in db.sys_Parms
                               where a.Name == "Auto Vendor Code" && a.Company_ID == AppConfig.Company_ID
                               select a).FirstOrDefault();
                sql = "Select account_id from gl_Accounts where Account_Code='" + AccountPram.Code + "' and Book_ID=" + AppConfig.Book_ID;
                string value = DBClass.getField(sql);
                if (value == "There is no row at position 0.ERROR")
                {
                    accountID = "ERROR";
                    return "0";
                }
                else
                {
                    accountID = value;
                }                   
            }
            return accountID;
        }
        [WebMethod]
        public static string LoadNewAccountToCreate()
        {
            string sql = "";
            string[] accountLength;
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            sys_Parm AccountPram = new sys_Parm();
            AccountPram = (from tbl in db.sys_Parms
                           where tbl.Name == "Trade & Other Payables"

                           select tbl).FirstOrDefault();
            if (AccountPram != null && AccountPram.Code != null)
            {
                GL_Account account = new GL_Account();

                var tbl = (from config in db.Configurations
                           where config.Configuration_Name == "Chart of Accounts Level"
                           select config).SingleOrDefault();
                accountLength = tbl.Configuration_Value.Split(',');
                sql = "Select account_id from gl_Accounts where Account_Code='" + AccountPram.Code + "' and Book_ID=" + AppConfig.Book_ID;
                string value = DBClass.getField(sql);
                var NewhdfParent_Code = "";
                if (value == "There is no row at position 0.")
                {
                    NewhdfParent_Code = AccountPram.Code.ToString();
                }
                else
                {
                    NewhdfParent_Code = value;
                }

                sql = "Select isNUll(MAX(Convert(int, Account_Serial)),0) from gl_accounts where parent_code=" + value;
                string maxcode = DBClass.getField(sql);
                int newcode = Convert.ToInt32(maxcode);
                newcode += 1;
                string newAccountcode = newcode.ToString("000");
                var NewhdfAccount_Code = AccountPram.Code + newAccountcode;
                var NewhdfAccount_Serial = newAccountcode;
                var NewhdfLevel = "4";

                var result = new
                {
                    NewhdfParent_Code,
                    NewhdfAccount_Code,
                    NewhdfAccount_Serial,
                    NewhdfLevel,

                };


                JavaScriptSerializer js = new JavaScriptSerializer();
                return js.Serialize(result);
            }
            else
            {
                var Newlblmessage = "Please assign Customers account in sys_Params table.";
                var result = new
                {
                    Newlblmessage,

                };


                JavaScriptSerializer js = new JavaScriptSerializer();
                return js.Serialize(result);
            }

        }


        [WebMethod]
        public static string SaveVendor(string btnSave, string AllItemDetail)
        {
            AP_Vendor obj = new AP_Vendor();
            string VendorId = "";
            AP_Vendor lstItem = new AP_Vendor();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            JavaScriptSerializer oJS = new JavaScriptSerializer();
            GL_Account accounts = new GL_Account();
            int accountID = 0;
            var record = oJS.Deserialize<VendorList>(AllItemDetail);
            if (record.VendorId != "")
            {
                lstItem = (from t in db.AP_Vendors
                           where t.Vendor_ID == int.Parse(record.VendorId)
                           select t).FirstOrDefault();
            }
            if (btnSave == "Update")
            {
                lstItem.Vendor_Name = record.VendorName;
                lstItem.VendorType = record.VendorType;
                lstItem.Vendor_Address = record.Address;
                lstItem.CreditDays = record.CreditDays;
                lstItem.Country = record.Country;
                lstItem.Region = record.Region;
                lstItem.City = record.City;
                lstItem.MobNo = record.MobNo;
                lstItem.Vendor_Phone1 = record.PhnNo;
                lstItem.DrugLicenceNo = record.DrugLicenceNo;
                lstItem.Vendor_STN = record.Stn;
                lstItem.Vendor_NTN = record.Ntn;
                lstItem.Cnic = record.Cnic;
                lstItem.Vendor_Email = record.Email;
                lstItem.Contact_Person = record.FocalPerson;
                if (record.PayablCode != "0" && record.Ismanual == "True")
                {
                    lstItem.Account_ID = Convert.ToInt32(record.PayablCode);
                }
                if (record.Ismanual == "False" || record.Ismanual == null)
                {
                    if (record.hdfAccount_ID != "")
                    {
                        accountID = Convert.ToInt32(record.hdfAccount_ID);
                        accounts = (from tbl in db.GL_Accounts
                                    where tbl.Account_ID == accountID
                                    select tbl).FirstOrDefault();
                        accounts.Account_Name = record.VendorName;
                        db.SubmitChanges();
                    }
                }
                lstItem.TaxPayerTyp = record.TaxTyp;
                lstItem.Company_ID = Convert.ToInt32(record.CompanyTyp);
                lstItem.IsActive = Convert.ToBoolean(record.IsActive);
                lstItem.Ismanual = Convert.ToBoolean(record.Ismanual);
                lstItem.Vendor_Code = Convert.ToInt32(record.VendorCode);
                db.SubmitChanges();
                VendorId = lstItem.Vendor_ID.ToString();
            }
            else
            {
                obj.Vendor_Name = record.VendorName;
                obj.VendorType = record.VendorType;
                obj.Vendor_Address = record.Address;
                obj.CreditDays = record.CreditDays;
                obj.Country = record.Country;
                obj.Region = record.Region;
                obj.City = record.City;
                obj.MobNo = record.MobNo;
                obj.Vendor_Phone1 = record.PhnNo;
                obj.DrugLicenceNo = record.DrugLicenceNo;
                obj.Vendor_STN = record.Stn;
                obj.Vendor_NTN = record.Ntn;
                obj.Cnic = record.Cnic;
                obj.Vendor_Email = record.Email;
                obj.Contact_Person = record.FocalPerson;
                if (record.PayablCode != "0" && record.Ismanual == "True")
                {
                    obj.Account_ID = Convert.ToInt32(record.PayablCode);
                }
                else
                    {

                        if (record.hdfParent_Code == "")
                        {
                            return "";
                        }

                        accounts.Account_Name = record.VendorName;
                        accounts.Account_Code = record.hdfAccount_Code;
                        accounts.Parent_Code = Convert.ToInt32(record.hdfParent_Code);
                        accounts.Levels = Convert.ToInt32(record.hdfLevel);
                        accounts.Account_Serial = record.hdfAccount_Serial;
                        accounts.Active = true;
                        accounts.Book_ID = AppConfig.Book_ID;
                        db.GL_Accounts.InsertOnSubmit(accounts);
                        db.SubmitChanges();
                        accountID = accounts.Account_ID;
                    }
                
                obj.TaxPayerTyp = record.TaxTyp;
                obj.CompanyType_Id =record.CompanyTyp;
                obj.Company_ID = AppConfig.Company_ID;
                obj.Book_ID = AppConfig.Book_ID;
                obj.IsActive = Convert.ToBoolean(record.IsActive);
                obj.Ismanual = Convert.ToBoolean(record.Ismanual);
                obj.Vendor_Code = Convert.ToInt32(record.VendorCode);
                db.AP_Vendors.InsertOnSubmit(obj);
                db.SubmitChanges();
                VendorId = obj.Vendor_ID.ToString();
            }
            ///**********Deleting Previous details**************/

            if (btnSave == "Update")
            {

                List<AP_Vendors_Person> lstPersonDetails = db.AP_Vendors_Persons.Where(t => t.VendorId == int.Parse(VendorId)).ToList();
                db.AP_Vendors_Persons.DeleteAllOnSubmit(lstPersonDetails); 

                List<AP_Vendor_General_Item> lstGeneralItemDetails = db.AP_Vendor_General_Items.Where(t => t.Vendor_Id == int.Parse(VendorId)).ToList();
                db.AP_Vendor_General_Items.DeleteAllOnSubmit(lstGeneralItemDetails);

                List<AP_Vendor_Pharmacy_Item> lstPharmcyItemDetails = db.AP_Vendor_Pharmacy_Items.Where(t => t.Vendor_Id == int.Parse(VendorId)).ToList();
                db.AP_Vendor_Pharmacy_Items.DeleteAllOnSubmit(lstPharmcyItemDetails);

                List<AP_Vendor_Company> lstCompaniesItemDetails = db.AP_Vendor_Companies.Where(t => t.Vendor_Id == int.Parse(VendorId)).ToList();
                db.AP_Vendor_Companies.DeleteAllOnSubmit(lstCompaniesItemDetails);

                db.SubmitChanges();
            }

            foreach (var VenGeneralitem in record.GeneralItemlist)
            {
                AP_Vendor_General_Item ltd = new AP_Vendor_General_Item();
                ltd.Rate = Convert.ToDecimal(VenGeneralitem.Rate);
                ltd.Ref_num = VenGeneralitem.RefNo;               
                ltd.remarks = VenGeneralitem.Remarks;
                ltd.Vendor_Id = Convert.ToInt32(VendorId);
                ltd.IsGeneralItem = true;
                ltd.ItemId = Convert.ToInt32(VenGeneralitem.ItemId);
                db.AP_Vendor_General_Items.InsertOnSubmit(ltd);
                db.SubmitChanges();
            }

            foreach (var VenPharmcyitem in record.PharmacyItemlist)
            {
                AP_Vendor_Pharmacy_Item ltd = new AP_Vendor_Pharmacy_Item();
                ltd.Rate = Convert.ToDecimal(VenPharmcyitem.Rate);
                ltd.Ref_num = VenPharmcyitem.RefNo;
                ltd.remarks = VenPharmcyitem.Remarks;
                ltd.Vendor_Id = Convert.ToInt32(VendorId);
                ltd.IsPharmacyItem = true;
                ltd.ItemId = Convert.ToInt32(VenPharmcyitem.ItemId);
                db.AP_Vendor_Pharmacy_Items.InsertOnSubmit(ltd);
                db.SubmitChanges();
            }

            foreach (var VenCompany in record.Companylist)
            {
                AP_Vendor_Company ltd = new AP_Vendor_Company();
                ltd.Company_Name = VenCompany.CompanyName;
                ltd.SR_No = Convert.ToInt32(VenCompany.SRNo);
                ltd.Vendor_Id = Convert.ToInt32(VendorId);
                db.AP_Vendor_Companies.InsertOnSubmit(ltd);
                db.SubmitChanges();
            }           

            foreach (var Peritem in record.PersonList)
            {
                AP_Vendors_Person ltd = new AP_Vendors_Person();
                ltd.Person_Name = Peritem.PersonName;
                ltd.Designation = Peritem.Designation;
                ltd.cell_no = Peritem.CellNo;
                ltd.Phone_no = Peritem.PhnNo;
                ltd.Ext_no = Peritem.ExtNo;
                ltd.VendorId = Convert.ToInt32(VendorId);
                db.AP_Vendors_Persons.InsertOnSubmit(ltd);
                db.SubmitChanges();
            }

            return (VendorId);
        }

        [WebMethod]
        public static string LoadVendorDetail(int VenId)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Header = (from m in db.AP_Vendors
                          where m.Vendor_ID == VenId
                          select new
                          {
                              m.Vendor_ID,
                              m.Vendor_Name,
                              m.VendorType,
                              m.Vendor_Address,
                              m.CreditDays,
                              m.Country,
                              m.Region,
                              m.City,
                              m.Vendor_Phone1,
                              m.MobNo,
                              m.Vendor_STN,
                              m.Vendor_NTN,
                              m.Cnic,
                              m.Vendor_Email,
                              m.Contact_Person,
                              m.Account_ID,
                              m.TaxPayerTyp,
                              m.CompanyType_Id,
                              m.DrugLicenceNo,
                              m.IsActive,
                              m.Ismanual,

                          }).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(Header);
        }


        [WebMethod]

        public static string LoadVendorPerson(int VenId)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Header = (from m in db.AP_Vendors_Persons
                          where m.VendorId == VenId
                          select new
                          {
                              m.Person_Name,
                              m.Designation,
                              m.Phone_no,
                              m.cell_no,
                              m.Ext_no,
                          }).ToList();
            return (new JavaScriptSerializer()).Serialize(Header);
        }
        [WebMethod]
        public static string LoadVendorGeneralItems(int VenId)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Header = (from m in db.AP_Vendor_General_Items
                          join item in db.INV_Items on m.ItemId equals item.Item_ID
                          where m.Vendor_Id == VenId
                          select new
                          {
                              item.Item_ID,
                              item.Item_Code,
                              item.Description,
                              item.Unit,
                              m.Ref_num,
                              m.Rate,
                              m.remarks,
                          }).ToList();
            return (new JavaScriptSerializer()).Serialize(Header);
        }
        [WebMethod]
        public static string LoadVendorPharmacyItems(int VenId)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Header = (from m in db.AP_Vendor_Pharmacy_Items
                          join item in db.INV_Items on m.ItemId equals item.Item_ID
                          where m.Vendor_Id == VenId
                          select new
                          {
                              item.Item_ID,
                              item.Item_Code,
                              item.Description,
                              item.Unit,
                              m.Ref_num,
                              m.Rate,
                              m.remarks,
                          }).ToList();
            return (new JavaScriptSerializer()).Serialize(Header);
        }
        [WebMethod]
        public static string LoadVendorCompanies(int VenId)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Header = (from m in db.AP_Vendor_Companies                         
                          where m.Vendor_Id == VenId
                          select new
                          {                             
                              m.Company_Name,
                              m.SR_No,
                          }).ToList();
            return (new JavaScriptSerializer()).Serialize(Header);
        }

        [WebMethod]
        public static string getDDLlist()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            List<ddlListItems> listItems = new List<ddlListItems>();
            string data = string.Empty;
            listItems = (from p in db.DataValues
                         join v in db.ValueSets on p.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Description == "Region" || v.ValueSet_Description == "Tax Payer Type" || v.ValueSet_Description == "Vendor Type" || v.ValueSet_Description == "Company Type"
                         select new ddlListItems
                         {
                             DataValueName = p.DataValue_Name,
                             DataValueDescription = p.DataValue_Description,
                             Type = v.ValueSet_Description == "Region" ? "Reg" : v.ValueSet_Description == "Tax Payer Type" ? "Taxtyp" : v.ValueSet_Description == "Vendor Type" ? "Ventyp" : "ComTyp"
                         }).ToList();
            return (new JavaScriptSerializer()).Serialize(listItems);
        }
        private class ddlListItems
        {
            public string DataValueName;
            public string DataValueDescription;
            public string Type;
        }
        public class VendorList
        {
            public string VendorId { get; set; }
            public string VendorName { get; set; }
            public string VendorType { get; set; }
            public string Address { get; set; }
            public string CreditDays { get; set; }
            public string Country { get; set; }
            public string Region { get; set; }
            public string City { get; set; }
            public string MobNo { get; set; }
            public string PhnNo { get; set; }
            public string DrugLicenceNo { get; set; }
            public string Stn { get; set; }
            public string Ntn { get; set; }
            public string Cnic { get; set; }
            public string Email { get; set; }
            public string SupplierTyp { get; set; }
            public string FocalPerson { get; set; }
            public string PayablCode { get; set; }
            public string TaxTyp { get; set; }
            public string CompanyTyp { get; set; }
            public string IsActive { get; set; }
            public string Ismanual { get; set; }
            public string VendorCode { get; set; }
            public string hdfAccount_ID { get; set; }
            public string hdfParent_Code { get; set; }
            public string hdfAccount_Serial { get; set; }
            public string hdfLevel { get; set; }
            public string hdfAccount_Code { get; set; }
            public List<PersonList> PersonList { get; set; }
            public List<GeneralItemlist> GeneralItemlist { get; set; }
            public List<PharmacyItemlist> PharmacyItemlist { get; set; }
            public List<Companylist> Companylist { get; set; }
        }

        public class PersonList
        {
            public string PersonName { get; set; }
            public string Designation { get; set; }
            public string PhnNo { get; set; }
            public string ExtNo { get; set; }
            public string CellNo { get; set; }
        }
        public class GeneralItemlist
        {
            public string Rate { get; set; }
            public string RefNo { get; set; }
            public string Remarks { get; set; }
            public string ItemId { get; set; }
        }
        public class PharmacyItemlist
        {
            public string Rate { get; set; }
            public string RefNo { get; set; }
            public string Remarks { get; set; }
            public string ItemId { get; set; }
        }
        public class Companylist
        {            
            public string CompanyName { get; set; }
            public string SRNo { get; set; }
        }
    }
}