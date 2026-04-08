using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class MedicineTemplate : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static string getpharmacyitems(string searchString)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var pharmacyItems = (from d in db.INV_Items
                                     where d.IsPharmacyItem == true && d.Description.Contains(searchString)
                                     orderby d.Item_ID descending
                                     select new
                                     {
                                         d.Item_ID,
                                         Description = d.Description
                                     }).Take(20).ToList();

                return (new JavaScriptSerializer().Serialize(pharmacyItems));
            }
        }

        [WebMethod]
        public static string loadtemplate(int temp_id)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                List<Medicines_Template> medicines_Templates = db.Medicines_Templates.Where(p => p.template_id == temp_id && p.Transaction_Type == "OutPatient").ToList();
                return (new JavaScriptSerializer()).Serialize(medicines_Templates);
            }
            return "";
        }
        [WebMethod]
        public static string FillPharmacyItemDropDown()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Routes = (from d in db.INV_Items

                          where d.Pharmacy_Item == true
                          orderby d.Item_ID descending
                          select new
                          {
                              d.Item_ID,
                              Description = d.Description,
                          }).ToList().Take(20);

            return (new JavaScriptSerializer().Serialize(Routes));
        }
        [WebMethod]
        public static string FillDosageQty()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Routes = from d in db.DataValues
                         join v in db.ValueSets
                         on d.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Name == "Dosage Quantity"
                         select new
                         {
                             d.DataValue_Name,
                             d.DataValue_Description,

                         };
            return (new JavaScriptSerializer().Serialize(Routes));
        }
       [WebMethod]
        public static string FillDosageDropDown()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Routes = from d in db.DataValues
                         join v in db.ValueSets
                         on d.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Name == "Dosage Form"
                         select new
                         {
                             d.DataValue_Name,
                             d.DataValue_Description,

                         };
            return (new JavaScriptSerializer().Serialize(Routes));
        }
        [WebMethod]
        public static string FillFrequencyDropDown()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Routes = from d in db.DataValues
                         join v in db.ValueSets
                         on d.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Name == "Frequency"
                         select new
                         {
                             d.DataValue_Name,
                             d.DataValue_Description,
                             d.Segment1
                         };
            return (new JavaScriptSerializer().Serialize(Routes));
        }
        [WebMethod]
        public static string FillRoutesDropDown()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Routes = from d in db.DataValues
                         join v in db.ValueSets
                         on d.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Name == "Routes"
                         select new
                         {
                             d.DataValue_Name,
                             d.DataValue_Description
                         };
            return (new JavaScriptSerializer().Serialize(Routes));
        }
        [WebMethod]
        public static string FillOtherInstruction()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Routes = from d in db.DataValues
                         join v in db.ValueSets
                         on d.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Name == "Other Instruction"
                         select new
                         {
                             d.DataValue_Name,
                             DataValue_Description = d.Segment1,

                         };
            return (new JavaScriptSerializer().Serialize(Routes));
        }
        [WebMethod]
        public static string CheckMedicineTemplateExists(string itemcode)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var inPatROomsList = (from op in db.Medicines_Templates

                                      where op.Item_Code == itemcode
                                     

                                      select new
                                      {
                                          op.Item_Code,

                                      }).Any();
                return (new JavaScriptSerializer()).Serialize(inPatROomsList);
            }
            return "";
        }
        [WebMethod]
        public static string SaveMedicines(string MedicineDetails)
        {
            try
            {
                JavaScriptSerializer js = new JavaScriptSerializer();
                var MedicineDetail = js.Deserialize<Medicine>(MedicineDetails);

                using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    /********************Deleting Previous 0 Value Saved Rows.***********************************/
                    List<Medicines_Template> medicineDetails = db.Medicines_Templates.Where(i => i.template_id == 0).ToList();
                    db.Medicines_Templates.DeleteAllOnSubmit(medicineDetails);
                    db.SubmitChanges();

                    int couterNewRecords = 0;

                   if (MedicineDetail.Medicine_Id != 0)
                    {
                        /*********************Deleting Previous Entry On Every Insert Or Update*************************/
                        List<Medicines_Template> medicines_Templates = db.Medicines_Templates.Where(p => p.template_id == MedicineDetail.Medicine_Id).ToList();
                        if (medicines_Templates != null)
                        {
                            db.Medicines_Templates.DeleteAllOnSubmit(medicines_Templates);
                            couterNewRecords++;
                        }
                    }
                    couterNewRecords = 0;
                    /*********************Inserting New Entry On Every Insert Or Update*************************/
                    foreach (MedicineDetails oIn_Patient_Medicine in MedicineDetail.MedicineList)
                    {
                        Medicines_Template oIn_Patient_Medicine1 = new Medicines_Template()
                        {
                            Item_Code = oIn_Patient_Medicine.ItemCode,
                            Medicine_Name = oIn_Patient_Medicine.Medicine_Name,
                            Transaction_Type = "OutPatient",
                            Medicine_Date = oIn_Patient_Medicine.Medicine_Date,
                            Oral = oIn_Patient_Medicine.Oral,
                            Injections = oIn_Patient_Medicine.Injection,
                            Dosage_From = oIn_Patient_Medicine.Dosage_From,
                            Frequency = oIn_Patient_Medicine.Frequency,
                            Dosage_Qty = oIn_Patient_Medicine.Dosage_Qty,
                            AttendingParamedical_Staff = oIn_Patient_Medicine.AttendingParamedical_Staff,
                            Other_Instruction = oIn_Patient_Medicine.Other_Instruction
                        };

                        db.Medicines_Templates.InsertOnSubmit(oIn_Patient_Medicine1);
                        couterNewRecords++;
                    }

                    db.SubmitChanges();
                }
            }
            catch (Exception ex)
            {
            }
            return "";
        }
        public class Medicine
        {
            public int? Medicine_Id { get; set; }

            public List<MedicineDetails> MedicineList { get; set; }
        }
        public class MedicineDetails
        {
            public DateTime Medicine_Date { get; set; }
            public string Medicine_Name { get; set; }
            public string Recomended_Dosage { get; set; }
            public string Dosage_From { get; set; }
            public string Oral { get; set; }
            public string Injection { get; set; }
            public string AttendingParamedical_Staff { get; set; }
          
            public string Frequency { set; get; }
            public string ItemCode { get; set; }
            public string Dosage_Qty ;
            public string Other_Instruction;
        }
    }
}