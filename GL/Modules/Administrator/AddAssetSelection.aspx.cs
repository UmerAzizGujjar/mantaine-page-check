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
    public partial class AddAssetSelection : System.Web.UI.Page
    {
        protected static int lastId = -1;
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static string LoadDepartments()
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var dpt = (from d in db.DataValues
                       join v in db.ValueSets
                       on d.ValueSet_ID equals v.ValueSet_ID
                       where v.ValueSet_Name == "Department"
                       select new
                       {
                           d.DataValue_Name,
                           d.DataValue_Description
                       }).ToList();

            return (new JavaScriptSerializer().Serialize(dpt));
        }
        [WebMethod]
        public static string LoadAsssetType()
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var dpt = (from d in db.DataValues
                       join v in db.ValueSets
                       on d.ValueSet_ID equals v.ValueSet_ID
                       where v.ValueSet_Name == "Asset Type"
                       select new
                       {
                           d.DataValue_Name,
                           d.DataValue_Description
                       }).ToList();

            return (new JavaScriptSerializer().Serialize(dpt));
        }
        [WebMethod]
        public static string LoadDepreciation()
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var LoadDepreciation = (from d in db.DataValues
                                    join v in db.ValueSets
                                    on d.ValueSet_ID equals v.ValueSet_ID
                                    where v.ValueSet_Name == "Depreciation Type"
                                    select new
                                    {
                                        d.DataValue_Name,
                                        d.DataValue_Description
                                    }).ToList();

            return (new JavaScriptSerializer().Serialize(LoadDepreciation));
        }
        [WebMethod]
        public static string LoadAcctCategory()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            //var LoadAcctCategory = (from p in db.FixedAsset_Acc_Categories
            //                        select new
            //                        {
            //                            p.Account_Category_Id,
            //                            p.CategoryName

            //                        }).ToList();
            var LoadAcctCategory = "";
            return (new JavaScriptSerializer()).Serialize(LoadAcctCategory);
        }
        [WebMethod]
        public static string LoadAssetCategory()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var LoadAssetCategory = (from p in db.Asset_Categories
                                     select new
                                     {
                                         p.Asset_Category_Id,
                                         p.Asset_Cat_Name

                                     }).ToList();
            return (new JavaScriptSerializer()).Serialize(LoadAssetCategory);
        }
        [WebMethod]
        public static string LoadAssetSubCategory(string asset_sub)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var LoadAssetSubCategory = (from p in db.Asset_SubCategories.Where(x => x.Asset_Cat_ID.Equals(asset_sub))
                                        select new
                                        {
                                            p.Asset_SubCat_ID,
                                            p.Asset_SubCat_Name

                                        }).ToList();
            return (new JavaScriptSerializer()).Serialize(LoadAssetSubCategory);
        }


        [WebMethod]
        public static string Load_Location()
        {
            string result = string.Empty;
            DataBaseDataContext db = new DataBaseDataContext();
            var Load_location = (from i in db.Locations
                                 select new { 
                                     
                                     i.Location_ID, 
                                     i.Location_Description

                                 }).ToList();


            return (new JavaScriptSerializer()).Serialize(Load_location);
        }
        [WebMethod]
        public static string Load_Accumlate_Acc()
        {
            string result = string.Empty;
            DataBaseDataContext db = new DataBaseDataContext();
            var Load_Accumlate = (from i in db.GL_Accounts
                              where i.Levels == 4
                                 select new { 
                                     
                                     i.Account_ID, 
                                     i.Account_Name

                                 }).ToList();


            return (new JavaScriptSerializer()).Serialize(Load_Accumlate);
        }  [WebMethod]
        public static string Load_Depreciation_Acc()
        {
            string result = string.Empty;
            DataBaseDataContext db = new DataBaseDataContext();
            var Load_Depreciation = (from i in db.GL_Accounts
                              where i.Levels == 4
                                 select new { 
                                     
                                     i.Account_ID, 
                                     i.Account_Name

                                 }).ToList();


            return (new JavaScriptSerializer()).Serialize(Load_Depreciation);
        }
        [WebMethod]
        public static string LoadAssetAccounts()
        {
            string result = string.Empty;
            DataBaseDataContext db = new DataBaseDataContext();
            var Load_Asset = (from i in db.GL_Accounts
                              where i.Levels == 4
                                 select new { 
                                     
                                     i.Account_ID, 
                                     i.Account_Name

                                 }).ToList();


            return (new JavaScriptSerializer()).Serialize(Load_Asset);
        }


        [WebMethod]
        public static string LoadVendors()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var LoadVendors = (from p in db.AP_Vendors
                               select new
                               {
                                   p.Vendor_ID,
                                   p.Vendor_Name

                               }).ToList();
            return (new JavaScriptSerializer()).Serialize(LoadVendors);
        }
        [WebMethod]
        public static string GetDefination_Result(string id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var LoadAssetSubCategory = (from p in db.Asset_Definition_Cost_Fills.Where(x => x.Asset_Definition_Id.Equals(id))
                                        select new
                                        {
                                            p.Amount,
                                            Definition_Date = p.Date,
                                            p.Grn_Date,
                                            p.Mir_Date,
                                            p.Grn_no,
                                            p.Mir_No,
                                            p.Ref_No

                                        }).ToList();
            return (new JavaScriptSerializer()).Serialize(LoadAssetSubCategory);
        }
        [WebMethod]
        public static string SaveRecord(string department_id, string slct_vendor, string ast_ctgry, string sub_ctgry, string act_ctgry,string txt_iserial, bool moveable, bool active, string txt_idesp, string acq_cost, string acq_date, string capt_date, string Capt_cost,string mfactur, string ast_life, string tdate,string location,string dprctin, string slct_dprctin, string slvg_value, string txt_land_area, string txt_ld_acq_frm, string txt_lnd_ksra,string txt_lnd_ktoni,string Asset_Acc, string Accumulate_Acc, string Depreciation_Acc, string txt_lnd_khwt, string txt_bld_rms, string txt_bld_cvr, string txt_plot_no, string txt_capacty,string txt_model, string txt_per_kva, string txt_convrsin_rate, string txt_srl_no, string txt_make, string txt_curncy, string txt_pwr_hp,string txt_mchn_cost, string slct_plnt_typ, string txt_reg_no, string txt_reg_date, string txt_vmodel, string txt_eng_no, string slct_vtype,string txt_vcolor, string txt_vmake,string Fur_capacity, string txt_convertable, string txt_usage, string txt_lenght, string txt_width, string txt_cd, string txt_board, string txt_ram, string txt_procser, string txt_disk, string txt_comp_name, string txt_chse_no, string asst_type, string btnSave, string id, List<CostFill> list)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            try
            {
                Asset_Definition DT;
                //Master
                if (btnSave == "Save")
                {
                    DT = new Asset_Definition();
                    DT.Created_by = AppConfig.UserID;
                    DT.Created_time = DateTime.Now;

                }
                else
                {
                    DT = (from tbl in db.Asset_Definitions
                          where tbl.Asset_Definition_Id == Convert.ToInt32(id)
                          select tbl).FirstOrDefault();
                    lastId = Convert.ToInt32(id);
                    DT.Updated_By = AppConfig.UserID;
                    DT.Update_Time = DateTime.Now;
                }
               
                DT.Acc_Categ_id = act_ctgry;

                if (acq_cost == "" || acq_cost == null)
                {
                }
                else 
                {
                    DT.Acq_Cost = Convert.ToDecimal(acq_cost); 
                }

                if(Capt_cost == "" || Capt_cost == null)
                {

                }
                else
                {
                    DT.Capitilization_Cost = Convert.ToDecimal(Capt_cost);
                }
                if (acq_date == "" || acq_date == null)
                {
                }
                else
                {
                    DT.Acq_Date = Convert.ToDateTime(acq_date);
                }
                if (capt_date == "" || capt_date == null)
                {
                }
                else
                {
                    DT.Capitilization_Date = Convert.ToDateTime(capt_date);
                }




                DT.Asset_Cat_id = ast_ctgry;

                DT.Location_ID = Convert.ToInt32(location);
                DT.Asset_Account = Convert.ToInt32(Asset_Acc);
                DT.Acc_Depreciation_Acc = Convert.ToInt32(Accumulate_Acc);
                DT.Depreciation_Acc = Convert.ToInt32(Depreciation_Acc);


                if (ast_life == "" || ast_life == null)
                {
                }
                else
                {
                    DT.Asset_lifeDays = ast_life;
                }

     
                DT.Asset_SubCat_Id = sub_ctgry;



                if (txt_board == "" || txt_board == null)
                {
                }
                else
                {
                    DT.Board = txt_board;
                }

                if (txt_bld_cvr == "" || txt_bld_cvr == null)
                {
                }
                else
                {
                    DT.Building_COvered_Are = txt_bld_cvr;
                }



                DT.Book_Id = AppConfig.Book_ID;


                if (txt_bld_rms == "" || txt_bld_cvr == null)
                { 
                }
                else 
                {
                    DT.Builing_No_Rooms = txt_bld_rms; 
                }


                if (txt_capacty == "" || txt_capacty == null)
                {
                }
                else
                {
                    DT.Capacity = txt_capacty;
                }



                if (txt_cd == "" || txt_cd == null)
                {
                }
                else
                {
                    DT.CD = txt_cd;
                }



                if (txt_chse_no == "" || txt_chse_no == null)
                {
                }
                else
                {
                    DT.Chasis_No = txt_chse_no;
                }




                if (asst_type == "" || asst_type == null)
                {
                }
                else
                {

                    DT.Asset_Type = asst_type;
                }




                if (txt_vcolor == "" || txt_vcolor == null)
                {
                }
                else
                {
                    DT.Color = txt_vcolor;
                }

                

                
                DT.Company_Id = AppConfig.Company_ID;
                



                if (txt_convrsin_rate == "") txt_convrsin_rate = "0";
                DT.Conversion_Rate = Convert.ToDecimal(txt_convrsin_rate);



                if (txt_curncy == "" || txt_curncy == null)
                {
                }
                else
                {
                    DT.Currency = txt_curncy;
                }
             
                DT.Departmet_id = department_id;


                if (dprctin == "" || dprctin == null)
                {
                }
                else
                {
                    DT.Depreciation = dprctin;
                }


                if (slct_dprctin == "" || slct_dprctin == null)
                {
                }
                else
                {
                    DT.Depreciation_type = slct_dprctin;
                }



                if (txt_eng_no == "" || txt_eng_no == null)
                {
                }
                else
                {
                    DT.Engine_No = txt_eng_no;
                }



                if (txt_mchn_cost == "" || txt_mchn_cost == null)
                {
                }
                else
                {
                    DT.FC = txt_mchn_cost;
                }



                if (txt_disk == "" || txt_disk == null)
                {
                }
                else
                {
                    DT.Hard_Disk = txt_disk;
                }




                if (txt_pwr_hp == "" || txt_pwr_hp == null)
                {
                }
                else
                {

                    DT.HP = txt_pwr_hp;

                }




                if (txt_idesp == "" || txt_idesp == null)
                {
                }
                else
                {
                    DT.Item_Description = txt_idesp;

                }



                if (txt_iserial == "" || txt_iserial == null)
                {
                }
                else
                {
                    DT.Item_Serial = txt_iserial;

                }


                if (txt_per_kva == "" || txt_per_kva == null)
                {
                }
                else
                {
                    DT.KVA = txt_per_kva;

                }




                if (txt_ld_acq_frm == "" || txt_ld_acq_frm == null)
                {
                }
                else
                {
                    DT.Land_Acq_from = txt_ld_acq_frm;

                }


                if (txt_land_area == "" || txt_land_area == null)
                {
                }
                else
                {
                    DT.Land_Area = txt_land_area;

                }


                if (txt_lnd_ktoni == "" || txt_lnd_ktoni == null)
                {
                }
                else
                {

                    DT.Land_Katoni_No = txt_lnd_ktoni;


                }



                if (txt_lnd_ksra == "" || txt_lnd_ksra == null)
                {
                }
                else
                {

                    DT.Land_Kesra_No = txt_lnd_ksra;

                }

                if (txt_lnd_khwt == "" || txt_lnd_khwt == null)
                {
                }
                else
                {
                    DT.Land_Khawet_No = txt_lnd_khwt;
                }



                if (txt_make == "" || txt_make == null)
                {
                }
                else
                {
                    DT.Make = txt_make;
                }





                if (mfactur == "" || mfactur == null)
                {
                }
                else
                {
                    DT.Manyfacturer = mfactur;
                }


                if (txt_vmodel == "" || txt_vmodel == null)
                {
                }
                else
                {
                    DT.Model = txt_vmodel;
                }

                if (txt_model == "" || txt_model == null)
                {
                }
                else
                {
                    DT.M_Model = txt_model;
                }
                
                DT.Moveable = moveable;
                DT.isactive = active;



                if (txt_comp_name == "" || txt_comp_name == null)
                {
                }
                else
                {
                    DT.Name = txt_comp_name;
                }


                  DT.Plant_type = slct_plnt_typ;
                


                if (txt_plot_no == "" || txt_plot_no == null)
                {
                }
                else
                {
                    DT.Plot_No = txt_plot_no;
                }


                if (txt_procser == "" || txt_procser == null)
                {
                }
                else
                {

                    DT.Processor = txt_procser;
                }


                if (txt_ram == "" || txt_ram == null)
                {
                }
                else
                {
                    DT.Ram = txt_ram;

                }

                if (txt_reg_date == "" || txt_reg_date == null)
                {
                }
                else
                {
                    DT.Reg_Date = Convert.ToDateTime(txt_reg_date);
                }



                if (txt_reg_no == "" || txt_reg_no == null)
                {
                }
                else
                {
                    DT.Registeraion_no = txt_reg_no;
                }


                if (Fur_capacity == "" || Fur_capacity == null)
                {
                }
                else
                {
                    DT.Fur_Capacity = Fur_capacity;
                }


                if (txt_convertable == "" || txt_convertable == null)
                {
                }
                else
                {
                    DT.Convertable = txt_convertable;
                }



                if (txt_usage == "" || txt_usage == null)
                {
                }
                else
                {
                    DT.Usage = txt_usage;
                }

                if (txt_lenght == "" || txt_lenght == null)
                {
                }
                else
                {
                    DT.Lenght = txt_lenght;
                }

                if (txt_width == "" || txt_width == null)
                {
                }
                else
                {
                    DT.Width = txt_width;
                }


                if (slvg_value == "" || slvg_value == null)
                {
                }
                else
                {
                    DT.Salvage_Value = slvg_value;
                }


                if (txt_srl_no == "" || txt_srl_no == null)
                {
                }
                else
                {
                    DT.Serial_No = txt_srl_no;
                }


                if (tdate == "" || tdate == null)
                {
                }
                else
                {
                    DT.Transfer_Date = tdate;
                }


                if (slct_vtype == "" || slct_vtype == null)
                {
                }
                else
                {
                    DT.Vehicle_Type = slct_vtype;
                }



                if (txt_vmake == "" || txt_vmake == null)
                {
                }
                else
                {
                    DT.Make = txt_vmake;
                }


                if (slct_vendor == "" || slct_vendor == null)
                {
                }
                else
                {
                    DT.Vendor_id = Convert.ToInt32(slct_vendor);
                }

                

                if (btnSave == "Save")
                {
                    db.Asset_Definitions.InsertOnSubmit(DT);

                }
                db.SubmitChanges();
                if (btnSave == "Save")
                {

                    var getMaxVal = (Convert.ToInt32(db.Asset_Definitions.Max(p => p.Asset_Definition_Id)));
                    lastId = getMaxVal;
                }
                Asset_Definition_Cost_Fill BTC;
                if (btnSave == "Update")
                {
                    var Asset_Definition_Cost =
                        from Asset_Definition_Costs in db.Asset_Definition_Cost_Fills
                        where
                          Asset_Definition_Costs.Asset_Definition_Id == lastId
                        select Asset_Definition_Costs;
                    foreach (var del in Asset_Definition_Cost)
                    {
                        db.Asset_Definition_Cost_Fills.DeleteOnSubmit(del);
                    }
                    db.SubmitChanges();
                }
                foreach (var item in list)
                {
                    BTC = new Asset_Definition_Cost_Fill();
                    BTC.Asset_Definition_Id = lastId;
                    if (item.amount == "") item.amount = "0";
                    BTC.Amount = Convert.ToDecimal(item.amount);
                    BTC.Date = Convert.ToDateTime(item.Date);
                    BTC.Grn_Date = Convert.ToDateTime(item.grn_date);
                    BTC.Grn_no = item.grn_no;
                    BTC.Mir_Date = Convert.ToDateTime(item.mir_date);
                    BTC.Mir_No = item.mir_no;
                    BTC.Ref_No = item.refnce;
                    db.Asset_Definition_Cost_Fills.InsertOnSubmit(BTC);
                    db.SubmitChanges();

                }
            }
            catch (Exception ex)
            {

            }

            return lastId.ToString();
        }
        [WebMethod]
        public static int GetassetDefinition()
        {

            int max = DBClass.getMaxEntry_No("Asset_Definition", "Asset_Definition_Id");
            return max;
        }
        [System.Web.Services.WebMethod]
        public static string getRecords(string id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            int assetId = Convert.ToInt32(id);

            var result = (from asset in db.Asset_Definitions
                          where asset.Asset_Definition_Id == assetId
                          select new
                          {
                              asset.Asset_Definition_Id,
                              asset.Item_Serial,
                              asset.Moveable,
                              asset.isactive,
                              asset.Item_Description,
                              asset.Acq_Cost,
                              Capitilization_Cost = asset.Capitilization_Cost +
                                                    (db.Asset_Expense_details
                                                       .Where(e => e.Asset_ID == asset.Asset_Definition_Id)
                                                       .Sum(e => (decimal?)e.Expense_Amount) ?? 0),
                              asset.Acq_Date,
                              asset.Capitilization_Date,
                              asset.Manyfacturer,
                              asset.Asset_lifeDays,
                              //Asset_lifeDays = asset.Asset_lifeDays +
                              //                      (db.Asset_Expense_details
                              //                         .Where(e => e.Asset_ID == asset.Asset_Definition_Id)
                              //                         .Sum(e => (decimal?)e.IncreaseInLife) ?? 0),
                              asset.Transfer_Date,
                              asset.Depreciation,
                              asset.Depreciation_type,
                              asset.Salvage_Value,
                              asset.Fur_Capacity,
                              asset.Convertable,
                              asset.Usage,
                              asset.Lenght,
                              asset.Width,
                              asset.Location_ID,
                              asset.Asset_Account,
                              asset.Acc_Depreciation_Acc,
                              asset.Depreciation_Acc,
                              asset.Land_Area,
                              asset.Land_Acq_from,
                              asset.Land_Kesra_No,
                              asset.Land_Katoni_No,
                              asset.Land_Khawet_No,
                              asset.Builing_No_Rooms,
                              asset.Building_COvered_Are,
                              asset.Plot_No,
                              asset.Capacity,
                              asset.M_Model,
                              asset.Chasis_No,
                              asset.KVA,
                              asset.Conversion_Rate,
                              asset.Serial_No,
                              asset.Make,
                              asset.Currency,
                              asset.HP,
                              asset.FC,
                              asset.Plant_type,
                              asset.Registeraion_no,
                              asset.Reg_Date,
                              asset.Model,
                              asset.Engine_No,
                              asset.Vehicle_Type,
                              asset.Color,
                              asset.CD,
                              asset.Board,
                              asset.Ram,
                              asset.Processor,
                              asset.Hard_Disk,
                              asset.Name,
                              asset.Asset_Cat_id,
                              asset.Acc_Categ_id,
                              asset.Vendor_id,
                              asset.Asset_Type,
                              asset.Asset_SubCat_Id,
                              asset.Departmet_id
                          }).ToList();

            return (new JavaScriptSerializer()).Serialize(result);
        }

        public class CostFill
        {
            public string Date
            {
                get;
                set;
            }
            public string refnce
            {
                get;
                set;
            }
            public string amount
            {
                get;
                set;
            }
            public string grn_no
            {
                get;
                set;
            }
            public string grn_date
            {
                get;
                set;
            }
            public string mir_no
            {
                get;
                set;
            }
            public string mir_date
            {
                get;
                set;
            }

        }
    }
}