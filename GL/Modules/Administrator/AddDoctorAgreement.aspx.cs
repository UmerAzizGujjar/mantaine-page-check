using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Inventory
{
    public partial class AddDoctorAgreement : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        [WebMethod]
        public static string editMaster(int doc_ids)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var obj = db.Doctor_Agreements.FirstOrDefault(r => r.Doc_agreemnt_id == doc_ids);
            return (new JavaScriptSerializer().Serialize(obj));
        }
        [WebMethod]
        public static string LoaddoctorInfo(string doctor_id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var decription = (from p in db.HR_Employees
                              where p.Emp_ID == Convert.ToInt32(doctor_id)
                              select new
                              {
                                  p.Emp_Name,
                                  p.Account_ID,
                                  accountname = DBClass.getField("select Account_Name from GL_Accounts where Account_ID =" + p.Account_ID),
                              }
                              ).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(decription);
        }
        public class DocagreemnetMaster
        {
            public int? doc_idss { get; set; }
            public string ddlDoctor { get; set; }
            public string doc_account { get; set; }
            public string ddllabtest { get; set; }
            public string ddl_xray { get; set; }
            public string ddl_ultrasound { get; set; }
            public string ddl_CTScan { get; set; }
            public string ddl_bloodbank { get; set; }
            public string ddl_Service { get; set; }
            public string ddl_mir { get; set; }
            public bool Is_Active { get; set; }
            public List<Detaillist> Save_list { get; set; }
            public List<save_opdlist> save_opd { get; set; }
            public List<x_raylist> save_ultra { get; set; }
            public List<ultra_list> save_xray { get; set; }
            public List<Ct_Scan_list> save_Ct_Scan { get; set; }
            public List<MIR_list> save_mri { get; set; }
            public List<Blood_bank_list> save_blood_bank { get; set; }
            public List<Services_list> save_Services { get; set; }
        }

        public class save_opdlist
        {
            public int hdn_test_id { get; set; }
            public string Description { get; set; }
            public int item_id { get; set; }
            public string service_Desc { get; set; }
            public decimal test_Rate { get; set; }
            public decimal Discount { get; set; }
            public decimal Net_amount { get; set; }
            public decimal txt_Doc_share { get; set; }
            public decimal txt_hos_share { get; set; }
            public string txtdep { get; set; }
            public bool active { get; set; }
            public string hdn_agremntDeptId { get; set; }
            public string hdn_agremntTypeId { get; set; }

        }
        public class Detaillist
        {
            public int hdn_test_id { get; set; }
            public string Description { get; set; }
            public int item_id { get; set; }
            public string service_Desc { get; set; }
            public decimal test_Rate { get; set; }
            public decimal Discount { get; set; }
            public decimal Net_amount { get; set; }
            public decimal txt_Doc_share { get; set; }
            public decimal txt_hos_share { get; set; }
            public string txtdep { get; set; }
            public bool active { get; set; }
            public string hdn_agremntDeptId { get; set; }
            public string hdn_agremntTypeId { get; set; }

        }
        public class ultra_list
        {
            public int hdn_test_id { get; set; }
            public string Description { get; set; }
            public int item_id { get; set; }
            public string service_Desc { get; set; }
            public decimal test_Rate { get; set; }
            public decimal Discount { get; set; }
            public decimal Net_amount { get; set; }
            public decimal txt_Doc_share { get; set; }
            public decimal txt_hos_share { get; set; }
            public string txtdep_xray { get; set; }
            public bool active { get; set; }
            public string hdn_agremntDeptId { get; set; }
            public string hdn_agremntTypeId { get; set; }

        }
        public class x_raylist
        {
            public int hdn_test_id { get; set; }
            public string Description { get; set; }

            public int item_id { get; set; }
            public string service_Desc { get; set; }
            public decimal test_Rate { get; set; }
            public decimal Discount { get; set; }
            public decimal Net_amount { get; set; }
            public decimal txt_Doc_share { get; set; }
            public decimal txt_hos_share { get; set; }
            public string txtdep_ultra { get; set; }
            public bool active { get; set; }
            public string hdn_agremntDeptId { get; set; }
            public string hdn_agremntTypeId { get; set; }
        }
        public class Blood_bank_list
        {
            public int hdn_test_id { get; set; }
            public string Description { get; set; }
            public int item_id { get; set; }
            public string service_Desc { get; set; }
            public decimal test_Rate { get; set; }
            public decimal Discount { get; set; }
            public decimal Net_amount { get; set; }
            public decimal txt_Doc_share { get; set; }
            public decimal txt_hos_share { get; set; }
            public string txtdep_bloodbank { get; set; }
            public bool active { get; set; }
            public string hdn_agremntDeptId { get; set; }
            public string hdn_agremntTypeId { get; set; }
        }
        public class Ct_Scan_list
        {
            public int hdn_test_id { get; set; }
            public string Description { get; set; }
            public int item_id { get; set; }
            public string service_Desc { get; set; }
            public decimal test_Rate { get; set; }
            public decimal Discount { get; set; }
            public decimal Net_amount { get; set; }
            public decimal txt_Doc_share { get; set; }
            public decimal txt_hos_share { get; set; }
            public string txtdep_ctscan { get; set; }
            public bool active { get; set; }
            public string hdn_agremntDeptId { get; set; }
            public string hdn_agremntTypeId { get; set; }
        }

        public class MIR_list
        {
            public int hdn_test_id { get; set; }
            public string Description { get; set; }
            public int item_id { get; set; }
            public string service_Desc { get; set; }
            public decimal test_Rate { get; set; }
            public decimal Discount { get; set; }
            public decimal Net_amount { get; set; }
            public decimal txt_Doc_share { get; set; }
            public decimal txt_hos_share { get; set; }
            public string txtdep_mir { get; set; }
            public bool active { get; set; }
            public string hdn_agremntDeptId { get; set; }
            public string hdn_agremntTypeId { get; set; }
        }
        public class Services_list
        {
            public int hdn_test_id { get; set; }
            public string Description { get; set; }
            public int item_id { get; set; }
            public string service_Desc { get; set; }
            public decimal test_Rate { get; set; }
            public decimal Discount { get; set; }
            public decimal Net_amount { get; set; }
            public decimal txt_Doc_share { get; set; }
            public decimal txt_hos_share { get; set; }
            public string hdn_services { get; set; }
            public bool active { get; set; }
            public string hdn_agremntDeptId { get; set; }
            public string hdn_agremntTypeId { get; set; }
        }
        [WebMethod]
        public static string SaveDocagreement(string AllRecords, string btnsaves)
        {
            string doc_id = "";
            Doctor_Agreement doc_agr = new Doctor_Agreement();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            JavaScriptSerializer serialize = new JavaScriptSerializer();
            var doc_agremment = serialize.Deserialize<DocagreemnetMaster>(AllRecords);
            var x_ray = serialize.Deserialize<DocagreemnetMaster>(AllRecords);
            var save_opd = serialize.Deserialize<DocagreemnetMaster>(AllRecords);
            var ultra_sound = serialize.Deserialize<DocagreemnetMaster>(AllRecords);
            var CT_Scan = serialize.Deserialize<DocagreemnetMaster>(AllRecords);
            var Blood_bank = serialize.Deserialize<DocagreemnetMaster>(AllRecords);
            var service = serialize.Deserialize<DocagreemnetMaster>(AllRecords);
            var MIR = serialize.Deserialize<DocagreemnetMaster>(AllRecords);

            if (btnsaves == "Update")
            {
                var lstItem = (from a in db.Doctor_Agreements
                               where a.Doc_agreemnt_id == Convert.ToInt32(doc_agremment.doc_idss)
                               select a).FirstOrDefault();
                lstItem.Update_By = AppConfig.UserID;
                lstItem.Update_Time = DateTime.Now;
                lstItem.Doctor = doc_agremment.ddlDoctor;
                lstItem.labtest_dep = doc_agremment.ddllabtest;
                lstItem.x_ray = doc_agremment.ddl_xray;
                lstItem.MIR = doc_agremment.ddl_mir;
                lstItem.CT_Scan = doc_agremment.ddl_CTScan;
                lstItem.ultra_sound = doc_agremment.ddl_ultrasound;
                lstItem.blood_bank = doc_agremment.ddl_bloodbank;
                lstItem.Services = doc_agremment.ddl_Service;
                lstItem.Is_Active = doc_agremment.Is_Active;
                lstItem.Doc_account = doc_agremment.doc_account;
                db.SubmitChanges();
                doc_id = lstItem.Doc_agreemnt_id.ToString();
            }
            else if (btnsaves == "Save")
            {
                doc_agr.Doctor = doc_agremment.ddlDoctor;
                doc_agr.Is_Active = doc_agremment.Is_Active;
                doc_agr.Doc_account = doc_agremment.doc_account;
                doc_agr.labtest_dep = doc_agremment.ddllabtest;
                doc_agr.x_ray = doc_agremment.ddl_xray;
                doc_agr.CT_Scan = doc_agremment.ddl_CTScan;
                doc_agr.ultra_sound = doc_agremment.ddl_ultrasound;
                doc_agr.blood_bank = doc_agremment.ddl_bloodbank;
                doc_agr.Services = doc_agremment.ddl_Service;
                doc_agr.MIR = doc_agremment.ddl_mir;
                doc_agr.Created_By = AppConfig.UserID;
                doc_agr.Created_Time = DateTime.Now;
                db.Doctor_Agreements.InsertOnSubmit(doc_agr);
                db.SubmitChanges();
                doc_id = doc_agr.Doc_agreemnt_id.ToString();
            }

            if (btnsaves == "Update")
            {
                List<Doctor_agreement_detail> lstItemDetails = db.Doctor_agreement_details.Where(t => t.Doc_agreement_id == int.Parse(doc_id)).ToList();
                db.Doctor_agreement_details.DeleteAllOnSubmit(lstItemDetails);
                db.SubmitChanges();
            }
            if (btnsaves == "Update" || btnsaves == "Save")
            {

                if (doc_agremment.Save_list != null && doc_agremment.Save_list.Count > 0)
                {
                    foreach (var record in doc_agremment.Save_list)
                    {
                        Doctor_agreement_detail std = new Doctor_agreement_detail();
                        std.Doc_agreement_id = int.Parse(doc_id);
                        std.test_id = record.hdn_test_id;
                        std.Department = record.txtdep;
                        std.test_description = record.Description;
                        std.Actual_amount = record.test_Rate;
                        std.Net_amount = record.Net_amount;
                        std.dicount = record.Discount;
                        std.hos_share = record.txt_hos_share;
                        std.doc_share = record.txt_Doc_share;
                        std.service_description = "";
                        std.isactive = true;
                        std.item_id = 0;
                        std.AgrementTypeId = record.hdn_agremntTypeId;
                        std.AgrementDepartmentId = record.hdn_agremntDeptId;
                        db.Doctor_agreement_details.InsertOnSubmit(std);
                        db.SubmitChanges();
                    }
                }
                if (doc_agremment.save_opd != null && doc_agremment.save_opd.Count > 0)
                {
                    foreach (var record in doc_agremment.save_opd)
                    {
                        Doctor_agreement_detail std = new Doctor_agreement_detail();
                        std.Doc_agreement_id = int.Parse(doc_id);
                        std.test_id = record.hdn_test_id;
                        std.Department = record.txtdep;
                        std.test_description = record.Description;
                        std.Actual_amount = record.test_Rate;
                        std.Net_amount = record.Net_amount;
                        std.dicount = record.Discount;
                        std.hos_share = record.txt_hos_share;
                        std.doc_share = record.txt_Doc_share;
                        std.service_description = "";
                        std.isactive = true;
                        std.item_id = 0;
                        std.AgrementTypeId = record.hdn_agremntTypeId;
                        std.AgrementDepartmentId = record.hdn_agremntDeptId;
                        db.Doctor_agreement_details.InsertOnSubmit(std);
                        db.SubmitChanges();
                    }
                }

                if (x_ray.save_xray != null && x_ray.save_xray.Count > 0)
                {
                    foreach (var record in x_ray.save_xray)
                    {
                        Doctor_agreement_detail std = new Doctor_agreement_detail();
                        std.Doc_agreement_id = int.Parse(doc_id);
                        std.test_id = record.hdn_test_id;
                        std.Department = record.txtdep_xray;
                        std.test_description = record.Description;
                        std.Actual_amount = record.test_Rate;
                        std.Net_amount = record.Net_amount;
                        std.dicount = record.Discount;
                        std.hos_share = record.txt_hos_share;
                        std.doc_share = record.txt_Doc_share;
                        std.service_description = "";
                        std.item_id = 0;
                        std.isactive = true;
                        std.AgrementTypeId = record.hdn_agremntTypeId;
                        std.AgrementDepartmentId = record.hdn_agremntDeptId;
                        db.Doctor_agreement_details.InsertOnSubmit(std);
                        db.SubmitChanges();
                    }
                }
                if (ultra_sound.save_ultra != null && ultra_sound.save_ultra.Count > 0)
                {
                    foreach (var record in ultra_sound.save_ultra)
                    {
                        Doctor_agreement_detail std = new Doctor_agreement_detail();
                        std.Doc_agreement_id = int.Parse(doc_id);
                        std.test_id = record.hdn_test_id;
                        std.Department = record.txtdep_ultra;
                        std.test_description = record.Description;
                        std.Actual_amount = record.test_Rate;
                        std.Net_amount = record.Net_amount;
                        std.dicount = record.Discount;
                        std.hos_share = record.txt_hos_share;
                        std.doc_share = record.txt_Doc_share;
                        std.service_description = "";
                        std.item_id = 0;
                        std.isactive = true;
                        std.AgrementTypeId = record.hdn_agremntTypeId;
                        std.AgrementDepartmentId = record.hdn_agremntDeptId;
                        db.Doctor_agreement_details.InsertOnSubmit(std);
                        db.SubmitChanges();
                    }
                }
                if (CT_Scan.save_Ct_Scan != null && CT_Scan.save_Ct_Scan.Count > 0)
                {
                    foreach (var record in CT_Scan.save_Ct_Scan)
                    {
                        Doctor_agreement_detail std = new Doctor_agreement_detail();
                        std.Doc_agreement_id = int.Parse(doc_id);
                        std.test_id = record.hdn_test_id;
                        std.Department = record.txtdep_ctscan;
                        std.test_description = record.Description;
                        std.Actual_amount = record.test_Rate;
                        std.Net_amount = record.Net_amount;
                        std.dicount = record.Discount;
                        std.hos_share = record.txt_hos_share;
                        std.doc_share = record.txt_Doc_share;
                        std.service_description = "";
                        std.item_id = 0;
                        std.isactive = true;
                        std.AgrementTypeId = record.hdn_agremntTypeId;
                        std.AgrementDepartmentId = record.hdn_agremntDeptId;
                        db.Doctor_agreement_details.InsertOnSubmit(std);
                        db.SubmitChanges();
                    }
                }
                if (MIR.save_mri != null && MIR.save_mri.Count > 0)
                {
                    foreach (var record in MIR.save_mri)
                    {
                        Doctor_agreement_detail std = new Doctor_agreement_detail();
                        std.Doc_agreement_id = int.Parse(doc_id);
                        std.test_id = record.hdn_test_id;
                        std.Department = record.txtdep_mir;
                        std.test_description = record.Description;
                        std.Actual_amount = record.test_Rate;
                        std.Net_amount = record.Net_amount;
                        std.dicount = record.Discount;
                        std.hos_share = record.txt_hos_share;
                        std.doc_share = record.txt_Doc_share;
                        std.service_description = "";
                        std.item_id = 0;
                        std.isactive = true;
                        std.AgrementTypeId = record.hdn_agremntTypeId;
                        std.AgrementDepartmentId = record.hdn_agremntDeptId;
                        db.Doctor_agreement_details.InsertOnSubmit(std);
                        db.SubmitChanges();
                    }
                }
                if (Blood_bank.save_blood_bank != null && Blood_bank.save_blood_bank.Count > 0)
                {
                    foreach (var record in Blood_bank.save_blood_bank)
                    {
                        Doctor_agreement_detail std = new Doctor_agreement_detail();
                        std.Doc_agreement_id = int.Parse(doc_id);
                        std.test_id = record.hdn_test_id;
                        std.Department = record.txtdep_bloodbank;
                        std.test_description = record.Description;
                        std.Actual_amount = record.test_Rate;
                        std.Net_amount = record.Net_amount;
                        std.dicount = record.Discount;
                        std.hos_share = record.txt_hos_share;
                        std.doc_share = record.txt_Doc_share;
                        std.service_description = "";
                        std.item_id = 0;
                        std.isactive = true;
                        std.AgrementTypeId = record.hdn_agremntTypeId;
                        std.AgrementDepartmentId = record.hdn_agremntDeptId;
                        db.Doctor_agreement_details.InsertOnSubmit(std);
                        db.SubmitChanges();
                    }
                }
                if (service.save_Services != null && service.save_Services.Count > 0)
                {
                    foreach (var record in service.save_Services)
                    {
                        Doctor_agreement_detail std = new Doctor_agreement_detail();
                        std.Doc_agreement_id = int.Parse(doc_id);
                        std.item_id = record.hdn_test_id;
                        std.services = record.hdn_services;
                        std.service_description = record.Description;
                        std.Actual_amount = record.test_Rate;
                        std.Net_amount = record.Net_amount;
                        std.dicount = record.Discount;
                        std.hos_share = record.txt_hos_share;
                        std.doc_share = record.txt_Doc_share;
                        std.test_description = "";
                        std.test_id = 0;
                        std.isactive = true;
                        std.AgrementTypeId = record.hdn_agremntTypeId;
                        std.AgrementDepartmentId = record.hdn_agremntDeptId;
                        db.Doctor_agreement_details.InsertOnSubmit(std);
                        db.SubmitChanges();
                    }
                }
            }
            return doc_id;
        }

        [WebMethod]
        public static string EditDetail(string doc_ids)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = (from d in db.Doctor_agreement_details
                           where d.Doc_agreement_id == Convert.ToInt64(doc_ids)
                           select new
                           {
                               d.Doc_agreement_id,
                               d.item_id,
                               d.test_id,
                               d.test_description,
                               d.service_description,
                               d.Actual_amount,
                               d.Net_amount,
                               d.dicount,
                               d.hos_share,
                               d.doc_share,
                               d.Department,
                               d.services,
                               d.isactive,
                               d.AgrementTypeId,
                               AgrementType = db.GetDataValueName("Agrement Type", d.AgrementTypeId),
                               d.AgrementDepartmentId,
                               AgrementDepartment = db.GetDataValueName("Agrement Department", d.AgrementDepartmentId)
                           }).ToList();
            return (new JavaScriptSerializer()).Serialize(Details);
        }

        [WebMethod]
        public static string LoadLabTests()
        {
            string result = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = (from data in db.Lab_Tests
                             where data.Main_Department == "001"
                             && data.Active == true
                             orderby data.Test_ID descending
                             select new
                             {
                                 data.Test_Name,
                                 data.Rate,
                                 data.Test_ID,
                                 data.Main_Department
                             }).ToList();
                result = (new JavaScriptSerializer()).Serialize(query).ToString();
            }
            return result;
        }
        [WebMethod]
        public static string Load_MRI()
        {
            string result = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = (from data in db.Lab_Tests
                             where data.Main_Department == "006"
                             orderby data.Test_ID descending
                             select new
                             {
                                 data.Test_Name,
                                 data.Rate,
                                 data.Test_ID,
                                 data.Main_Department
                             }).ToList();
                result = (new JavaScriptSerializer()).Serialize(query).ToString();
            }
            return result;
        }

        [WebMethod]
        public static string LoadLabTests_xray()
        {
            string result = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = (from data in db.Lab_Tests
                             where data.Main_Department == "003"
                             orderby data.Test_ID descending
                             select new
                             {
                                 data.Test_Name,
                                 data.Rate,
                                 data.Test_ID,
                                 data.Main_Department,
                             }).ToList();
                result = (new JavaScriptSerializer()).Serialize(query).ToString();
            }
            return result;
        }
        [WebMethod]
        public static string Load_Bloodbank()
        {
            string result = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = (from data in db.Lab_Tests
                             where data.Main_Department == "005"
                             orderby data.Test_ID descending
                             select new
                             {
                                 data.Test_Name,
                                 data.Rate,
                                 data.Test_ID,
                                 data.Main_Department,
                             }).ToList();
                result = (new JavaScriptSerializer()).Serialize(query).ToString();
            }
            return result;
        }

        [WebMethod]
        public static string load_Opd()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Agrement Department" && dv.DataValue_Description == "OPD"
                              select new
                              {
                                  dv.DataValue_Name,
                                  dv.DataValue_Description
                              }).ToList();
                data = new JavaScriptSerializer().Serialize(result);
            }
            return data;
        }

        [WebMethod]
        public static string Load_ultrasound()
        {
            string result = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = (from data in db.Lab_Tests
                             where data.Main_Department == "002"
                             orderby data.Test_ID descending
                             select new
                             {
                                 data.Test_Name,
                                 data.Rate,
                                 data.Test_ID,
                                 data.Main_Department,
                             }).ToList();
                result = (new JavaScriptSerializer()).Serialize(query).ToString();
            }
            return result;
        }

        [WebMethod]
        public static string Load_CTScan()
        {
            string result = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = (from data in db.Lab_Tests
                             where data.Main_Department == "004"
                             orderby data.Test_ID descending
                             select new
                             {
                                 data.Test_Name,
                                 data.Rate,
                                 data.Test_ID,
                                 data.Main_Department,
                             }).ToList();
                result = (new JavaScriptSerializer()).Serialize(query).ToString();
            }
            return result;
        }
        [WebMethod]
        public static string Load_Services()
        {
            string result = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = (from data in db.INV_Items
                             where data.Item_Type == "002"
                             orderby data.Item_ID descending
                             select new
                             {
                                 data.Description,
                                 data.Sale_Rate,
                                 data.Item_ID,
                                 data.Item_Type,
                             }).ToList();
                result = (new JavaScriptSerializer()).Serialize(query).ToString();
            }
            return result;
        }

        [WebMethod]
        public static string GetDoctorName()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var query = (from hr in db.HR_Employees
                         select new
                         {
                             hr.Emp_ID,
                             hr.Emp_Name,
                         }).ToList();
            string data = string.Empty;
            return (new JavaScriptSerializer()).Serialize(query);
        }
        private class ddlListItems
        {
            public string DataValueName;
            public string DataValueDescription;
            public string Type;
        }
        [WebMethod]
        public static string FillAgrementdept()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            List<ddlListItems> listItems = new List<ddlListItems>();
            string data = string.Empty;
            listItems = (from p in db.DataValues
                         join v in db.ValueSets on p.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Description == "Agrement Department"
                         select new ddlListItems
                         {
                             DataValueName = p.DataValue_Name,
                             DataValueDescription = p.DataValue_Description,
                         }).ToList();
            return (new JavaScriptSerializer()).Serialize(listItems);
        }
        [WebMethod]
        public static string FillAgrementType()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            List<ddlListItems> listItems = new List<ddlListItems>();
            string data = string.Empty;
            listItems = (from p in db.DataValues
                         join v in db.ValueSets on p.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Description == "Agrement Type"
                         select new ddlListItems
                         {
                             DataValueName = p.DataValue_Name,
                             DataValueDescription = p.DataValue_Description,
                         }).ToList();
            return (new JavaScriptSerializer()).Serialize(listItems);
        }
    }
}