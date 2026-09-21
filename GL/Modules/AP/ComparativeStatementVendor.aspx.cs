using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.AP
{
    public partial class ComparativeStatementVendor : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            hyperlink1.Visible = false;
            if (!IsPostBack)
            {
                //LoadPRNum();
                BindTerm();
                if (Request.QueryString["CM_ID"] != null)
                {
                    DataBaseDataContext db = new DataBaseDataContext();
                    var getID = Request.QueryString["CM_ID"];
                    var gettype = (from a in db.CS_Vendor_Masters where a.CS_Ven_Master_ID == Convert.ToInt32(getID) select a.File_Path).FirstOrDefault();
                    if (!string.IsNullOrEmpty(gettype))
                    {
                        hyperlink1.NavigateUrl = gettype;
                        hyperlink1.Visible = true;
                    }
                }
            }       
        }
        private void BindTerm()
        {
            #region "Bind Terms and Conditions"
            object valueset = DBClass.GetValueSet("Terms and Conditions");
            ddlterms.DataSource = valueset;
            ddlterms.DataTextField = "DataValue_Description";
            ddlterms.DataValueField = "DataValue_Name";
            ddlterms.DataBind(); // Bind the data first
            ddlterms.Items.Insert(0, new ListItem("Please Select", "0")); // Insert at index 0
            #endregion
        }
        [WebMethod]
        public static string getPRByID(string PRID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            int PRId = Convert.ToInt32(PRID);
            var listPRDetails = db.sp_GetPRDetailByPRID(PRId).ToList();
            return (new JavaScriptSerializer()).Serialize(listPRDetails);
        }
        [WebMethod]
        public static bool UserEntryRights()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var uid = AppConfig.UserID;              
                var hasEntryRights = db.Sys_Inv_OrignatorTempelate_Masters
                                  .Join(db.Sys_Inv_OrignatorTempelate_Detail_Forms,
                                        SATM => SATM.OrignatorTempelate_ID,
                                        SATDF => SATDF.OrignatorTempelate_ID,
                                        (SATM, SATDF) => new { SATM, SATDF })
                                  .Join(db.Sys_Inv_OrignatorTempelate_Details,
                                        temp => temp.SATM.OrignatorTempelate_ID,
                                        SATDO => SATDO.OrignatorTempelate_ID,
                                        (temp, SATDO) => new { temp.SATM, temp.SATDF, SATDO })
                                  .Any(temp => temp.SATM.IsActive == true && temp.SATM.IsDeleted == false && temp.SATDF.FormId == 2 && temp.SATDO.UserId == uid);

                return hasEntryRights;
            }
        }

        [WebMethod]
        public static bool UserUnApproveEntryRights()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var userPermissions = (from data in db.aspnet_Users
                                       where data.UserId == AppConfig.UserID
                                       select new
                                       {
                                           data.PurchaseUnApprove
                                       }).FirstOrDefault();
                bool UnApproveRight = userPermissions?.PurchaseUnApprove ?? false;
                return UnApproveRight;
            }
        }
        [WebMethod]
        public static string LoadVenHeader(int CM_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.sp_LoadVenDetails(CM_ID).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(Details);
        }
        [WebMethod]
        public static string LoadVenDetail(int CM_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.sp_LoadVenChildDetails(CM_ID).ToList();
            return (new JavaScriptSerializer()).Serialize(Details);
        }

        [WebMethod]
        public static string fillWarehouse()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            List<ddlListItems> listItems = new List<ddlListItems>();
            string data = string.Empty;
            listItems = (from p in db.DataValues
                         join v in db.ValueSets on p.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Description == "Ware House"
                         select new ddlListItems
                         {
                             DataValueName = p.DataValue_Name,
                             DataValueDescription = p.DataValue_Description,
                         }).ToList();
            return (new JavaScriptSerializer()).Serialize(listItems);
        }

        [WebMethod]
        public static string GetUserBranch()
        {
            using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                var branchIds = (from bwd in db.Branch_Wise_User_Details
                                 where bwd.User_Id == AppConfig.UserID
                                 select bwd.Brancg).ToList();

                if (!branchIds.Any())
                    return "null";

                var validBranches = new List<object>();

                foreach (var brancg in branchIds)
                {
                    if (int.TryParse(brancg, out int branchId))
                    {
                        var branch = db.Branches.FirstOrDefault(b => b.branch_ID == branchId);
                        if (branch != null)
                        {
                            validBranches.Add(new { branch_ID = branchId, branch_Name = branch.branch_Name });
                        }
                    }
                }

                if (!validBranches.Any())
                    return "null";

                return new JavaScriptSerializer().Serialize(validBranches);
            }
        }

        [WebMethod]
        public static string GetCSBranch(int CM_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var branch = (from m in db.CS_Vendor_Masters
                          where m.CS_Ven_Master_ID == CM_ID
                          select m.Branch_Id).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(branch);
        }

        [WebMethod]
        public static string SaveCSData(string btnSave, string AllItemDetail)
        {
            string cmid = "";
            CS_Vendor_Master CM = new CS_Vendor_Master();
            CS_Vendor obj = new CS_Vendor();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            JavaScriptSerializer oJS = new JavaScriptSerializer();
            var record = oJS.Deserialize<MasterCSList>(AllItemDetail);
            var lstItem = (from t in db.CS_Vendor_Masters
                           where t.CS_Ven_No == int.Parse(record.csno)
                           select t).FirstOrDefault();

            var count_grn = record.GRNItem_list.Count;
            if (btnSave == "Update")
            {

                lstItem.Company_ID = AppConfig.Company_ID;
                lstItem.Update_Time = DateTime.Now;
                lstItem.Updated_By = AppConfig.UserID;
                lstItem.CS_Ven_No = Convert.ToInt32(record.csno);
                lstItem.CS_Validity = record.csvalidity;
                lstItem.Remarks = record.remarks;
                lstItem.Ware_House = record.WareHouse;
                lstItem.Branch_Id = string.IsNullOrEmpty(record.Branch) ? (int?)null : Convert.ToInt32(record.Branch);
                lstItem.Term_Id = record.Term_Id;

                if (record.date != "")
                {
                    lstItem.CS_Date = Convert.ToDateTime(record.date);
                }
                db.SubmitChanges();

                cmid = lstItem.CS_Ven_Master_ID.ToString();
                List<CS_Vendor> lstcsvendor = db.CS_Vendors.Where(t => t.CS_Master_ID == int.Parse(cmid)).ToList();
                db.CS_Vendors.DeleteAllOnSubmit(lstcsvendor);
                db.SubmitChanges();

                bool bBreak = false;
                int loop = 0;
                int loopGrn = 0;
                string[] arr;
                List<string> lst = new List<string>();
                List<string> code = new List<string>();

                for (int i = 0; i < record.Item_list1.Count; i++)
                {

                    obj = new CS_Vendor();
                    obj.CS_Master_ID = Convert.ToInt32(cmid);
                    obj.Vendor1 = record.txt_vendorName_vendor1;
                    obj.Payment_Terms1 = record.txt_paymentTerms_vendor1;
                    obj.Delivery_Terms1 = record.txt_DeliveryTerms_vendor1;
                    obj.TotalSalesTax1 = record.TotalSalesTax1;
                    if (record.txt_amount_vendor1 != "")
                    {
                        obj.Amount1 = Convert.ToDecimal(record.txt_amount_vendor1);
                    }
                    if (record.txt_Freight_vendor1 != "")
                    {
                        obj.Freight1 = Convert.ToDecimal(record.txt_Freight_vendor1);
                    }
                    if (record.txt_TotalAmount_vendor1 != "")
                    {
                        obj.Total_Amount1 = Convert.ToDecimal(record.txt_TotalAmount_vendor1);
                    }
                    obj.Vendor_bit_1 = Convert.ToBoolean(record.Item_list1[loop].vendbit1);
                    if (i == record.Item_list1.Count)
                    {
                        break;
                    }
                    obj.Item_ID = Convert.ToInt32(record.Item_list1[loop].itemid);
                    obj.Item_Code = record.Item_list1[loop].itemcode;
                    obj.PRID = Convert.ToInt32(record.Item_list1[loop].prid);                    

                    obj.PRNUM = Convert.ToInt32(record.Item_list1[loop].prno);
                    obj.ReqDate = Convert.ToDateTime(record.Item_list1[loop].reqdate);
                    if (record.Item_list1[loop].qty1 != "")
                    {
                        obj.Qty1 = Convert.ToDecimal(record.Item_list1[loop].qty1);
                    }
                    if (record.Item_list1[loop].rate1 != "")
                    {
                        obj.Rate1 = Convert.ToDecimal(record.Item_list1[i].rate1);
                    }
                    if (record.Item_list1[loop].salesperc1 != "" || record.Item_list1[loop].salesperc1 != "0")
                    {
                        obj.SalesTaxPer1 = Convert.ToInt32(record.Item_list1[i].salesperc1);
                    }
                    if (record.Item_list1[loop].vendoramount1 != "")
                    {
                        obj.Vendor_Amount1 = Convert.ToDecimal(record.Item_list1[loop].vendoramount1);
                    }
                    if (record.Item_list1[loop].prdet_id != "")
                    {
                        obj.PR_Detail_ID = Convert.ToInt32(record.Item_list1[loop].prdet_id);
                    }


                    bBreak = false;
                    for (int x = 0; x < record.Item_list2.Count; x++)
                    {
                        if (bBreak)
                            break;
                        obj.Vendor2 = record.txt_vendorName_vendor2;
                        obj.Payment_Terms2 = record.txt_paymentTerms_vendor2;
                        obj.Delivery_Terms2 = record.txt_DeliveryTerms_vendor2;
                        obj.TotalSalesTax2 = record.TotalSalesTax2;
                        if (record.txt_amount_vendor2 != "")
                        {
                            obj.Amount2 = Convert.ToDecimal(record.txt_amount_vendor2);
                        }
                        if (record.txt_Freight_vendor2 != "")
                        {
                            obj.Freight2 = Convert.ToDecimal(record.txt_Freight_vendor2);
                        }
                        if (record.txt_TotalAmount_vendor2 != "")
                        {
                            obj.Total_Amount2 = Convert.ToDecimal(record.txt_TotalAmount_vendor2);
                        }
                        obj.Vendor_bit_2 = Convert.ToBoolean(record.Item_list2[loop].vendbit2);
                        if (record.Item_list2[loop].qty2 != "")
                        {
                            obj.Qty2 = Convert.ToDecimal(record.Item_list2[loop].qty2);
                        }
                        if (record.Item_list2[loop].rate2 != "")
                        {
                            obj.Rate2 = Convert.ToDecimal(record.Item_list2[loop].rate2);
                        }
                        if (record.Item_list2[loop].salesperc2 != "" || record.Item_list2[loop].salesperc2 != "0")
                        {
                            obj.SalesTaxPer2 = Convert.ToInt32(record.Item_list2[i].salesperc2);
                        }
                        if (record.Item_list2[loop].vendoramount2 != "")
                        {
                            obj.Vendor_Amount2 = Convert.ToDecimal(record.Item_list2[loop].vendoramount2);
                        }



                        for (int z = 0; z < record.Item_list3.Count; z++)
                        {
                            if (bBreak)
                                break;
                            obj.Vendor3 = record.txt_vendorName_vendor3;
                            obj.Payment_Terms3 = record.txt_paymentTerms_vendor3;
                            obj.Delivery_Terms3 = record.txt_DeliveryTerms_vendor3;
                            obj.TotalSalesTax3 = record.TotalSalesTax3;
                            if (record.txt_amount_vendor3 != "")
                            {
                                obj.Amount3 = Convert.ToDecimal(record.txt_amount_vendor3);
                            }
                            if (record.txt_Freight_vendor3 != "")
                            {
                                obj.Freight3 = Convert.ToDecimal(record.txt_Freight_vendor3);
                            }
                            if (record.txt_TotalAmount_vendor3 != "")
                            {
                                obj.Total_Amount3 = Convert.ToDecimal(record.txt_TotalAmount_vendor3);
                            }
                            obj.Vendor_bit_3 = Convert.ToBoolean(record.Item_list3[loop].vendbit3);
                            if (record.Item_list3[loop].qty3 != "")
                            {
                                obj.Qty3 = Convert.ToDecimal(record.Item_list3[loop].qty3);
                            }
                            if (record.Item_list3[loop].rate3 != "")
                            {
                                obj.Rate3 = Convert.ToDecimal(record.Item_list3[loop].rate3);
                            }
                            if (record.Item_list3[loop].salesperc3 != "" || record.Item_list3[loop].salesperc3 != "0")
                            {
                                obj.SalesTaxPer3 = Convert.ToInt32(record.Item_list3[i].salesperc3);
                            }
                            if (record.Item_list3[loop].vendoramount3 != "")
                            {
                                obj.Vendor_Amount3 = Convert.ToDecimal(record.Item_list3[loop].vendoramount3);
                            }
                            for (int y = 0; y < record.Item_list4.Count; y++)
                            {
                                if (bBreak)
                                    break;
                                obj.Vendor4 = record.txt_vendorName_vendor4;
                                obj.Payment_Terms4 = record.txt_paymentTerms_vendor4;
                                obj.Delivery_Terms4 = record.txt_DeliveryTerms_vendor4;
                                obj.TotalSalesTax4 = record.TotalSalesTax4;
                                if (record.txt_amount_vendor4 != "")
                                {
                                    obj.Amount4 = Convert.ToDecimal(record.txt_amount_vendor4);
                                }
                                if (record.txt_Freight_vendor4 != "")
                                {
                                    obj.Freight4 = Convert.ToDecimal(record.txt_Freight_vendor4);
                                }
                                if (record.txt_TotalAmount_vendor4 != "")
                                {
                                    obj.Total_Amount4 = Convert.ToDecimal(record.txt_TotalAmount_vendor4);
                                }
                                obj.Vendor_bit_4 = Convert.ToBoolean(record.Item_list4[loop].vendbit4);
                                if (record.Item_list4[loop].qty4 != "")
                                {
                                    obj.Qty4 = Convert.ToDecimal(record.Item_list4[loop].qty4);
                                }
                                if (record.Item_list4[loop].rate4 != "")
                                {
                                    obj.Rate4 = Convert.ToDecimal(record.Item_list4[loop].rate4);
                                }
                                if (record.Item_list4[loop].salesperc4 != "" || record.Item_list4[loop].salesperc4 != "0")
                                {
                                    obj.SalesTaxPer4 = Convert.ToInt32(record.Item_list4[i].salesperc4);
                                }
                                if (record.Item_list4[loop].vendoramount4 != "")
                                {
                                    obj.Vendor_Amount4 = Convert.ToDecimal(record.Item_list4[loop].vendoramount4);
                                }

                                for (int zi = 0; zi < record.Item_list5.Count; zi++)
                                {
                                    if (bBreak)
                                        break;
                                    obj.Vendor5 = record.txt_vendorName_vendor5;
                                    obj.Payment_Terms5 = record.txt_paymentTerms_vendor5;
                                    obj.Delivery_Terms5 = record.txt_DeliveryTerms_vendor5;
                                    obj.TotalSalesTax5 = record.TotalSalesTax5;
                                    if (record.txt_amount_vendor5 != "")
                                    {
                                        obj.Amount5 = Convert.ToDecimal(record.txt_amount_vendor5);
                                    }
                                    if (record.txt_Freight_vendor5 != "")
                                    {
                                        obj.Freight5 = Convert.ToDecimal(record.txt_Freight_vendor5);
                                    }
                                    if (record.txt_TotalAmount_vendor5 != "")
                                    {
                                        obj.Total_Amount5 = Convert.ToDecimal(record.txt_TotalAmount_vendor5);
                                    }
                                    obj.Vendor_bit_5 = Convert.ToBoolean(record.Item_list5[loop].vendbit5);
                                    if (record.Item_list5[loop].qty5 != "")
                                    {
                                        obj.Qty5 = Convert.ToDecimal(record.Item_list5[loop].qty5);
                                    }
                                    if (record.Item_list5[loop].rate5 != "")
                                    {
                                        obj.Rate5 = Convert.ToDecimal(record.Item_list5[loop].rate5);
                                    }
                                    if (record.Item_list5[loop].salesperc5 != "" || record.Item_list5[loop].salesperc5 != "0")
                                    {
                                        obj.SalesTaxPer5 = Convert.ToInt32(record.Item_list5[i].salesperc5);
                                    }
                                    if (record.Item_list5[loop].vendoramount5 != "")
                                    {
                                        obj.Vendor_Amount5 = Convert.ToDecimal(record.Item_list5[loop].vendoramount5);
                                    }
                                    db.CS_Vendors.InsertOnSubmit(obj);
                                    db.SubmitChanges();
                                    lst.Add(obj.CS_Ven_ID.ToString());
                                    code.Add(obj.Item_Code);
                                    bBreak = true;
                                    loop++;
                                    break;
                                }
                            }
                        }
                    }
                }
                for (int i = 0; i < record.GRNItem_list.Count; i++)
                {
                    var id = lst[i];
                    var itcode = code[i];
                    if (record.GRNItem_list[i].grnappamount != "")
                    {
                        DBClass.executeNonQueryWithoutBegin("update CS_Vendor set Total_App_Amount=" + record.GRNItem_list[i].grnappamount + " where CS_Ven_id=" + id);
                    }
                    if (record.GRNItem_list[i].lastgrnnumber != "")
                    {
                        DBClass.executeNonQueryWithoutBegin("update CS_Vendor set Last_GRN_No=" + record.GRNItem_list[i].lastgrnnumber + " where CS_Ven_id=" + id);
                    }
                    if (record.GRNItem_list[i].lastgrnrate != "")
                    {
                        DBClass.executeNonQueryWithoutBegin("update CS_Vendor set Last_GRN_Rate =" + record.GRNItem_list[i].lastgrnrate + " where CS_Ven_id=" + id);
                    }
                }
            }

            else
            {
                CM.CS_Ven_No = Convert.ToInt32(record.csno);
                CM.CS_Validity = record.csvalidity;
                CM.Status = record.txtstatus;
                CM.Company_ID = AppConfig.Company_ID;
                CM.Creation_Time = DateTime.Now;
                CM.Created_By = AppConfig.UserID;
                CM.IsAutoGenerate = false;
                CM.IsDeleted = false;
                CM.Remarks = record.remarks;
                CM.Ware_House = record.WareHouse;
                CM.Branch_Id = string.IsNullOrEmpty(record.Branch) ? (int?)null : Convert.ToInt32(record.Branch);
                CM.Term_Id = record.Term_Id;
                if (record.date != "")
                {
                    CM.CS_Date = Convert.ToDateTime(record.date);
                }
                db.CS_Vendor_Masters.InsertOnSubmit(CM);
                db.SubmitChanges();
                cmid = CM.CS_Ven_Master_ID.ToString();


                bool bBreak = false;
                int loop = 0;
                int loopGrn = 0;
                string[] arr;
                List<string> lst = new List<string>();
                List<string> code = new List<string>();
                for (int i = 0; i < record.Item_list1.Count; i++)
                {
                    obj = new CS_Vendor();
                    obj.CS_Master_ID = Convert.ToInt32(cmid);
                    obj.Vendor1 = record.txt_vendorName_vendor1;
                    obj.Payment_Terms1 = record.txt_paymentTerms_vendor1;
                    obj.Delivery_Terms1 = record.txt_DeliveryTerms_vendor1;
                    obj.TotalSalesTax1 = record.TotalSalesTax1;

                    if (record.txt_amount_vendor1 != "")
                    {
                        obj.Amount1 = Convert.ToDecimal(record.txt_amount_vendor1);
                    }
                    if (record.txt_Freight_vendor1 != "")
                    {
                        obj.Freight1 = Convert.ToDecimal(record.txt_Freight_vendor1);
                    }
                    if (record.txt_TotalAmount_vendor1 != "")
                    {
                        obj.Total_Amount1 = Convert.ToDecimal(record.txt_TotalAmount_vendor1);
                    }
                    obj.Vendor_bit_1 = Convert.ToBoolean(record.Item_list1[loop].vendbit1);
                    if (i == record.Item_list1.Count)
                    {
                        break;
                    }
                    obj.Item_ID = Convert.ToInt32(record.Item_list1[loop].itemid);
                    obj.Item_Code = record.Item_list1[loop].itemcode;
                    obj.PRID = Convert.ToInt32(record.Item_list1[loop].prid);  

                    obj.PRNUM = Convert.ToInt32(record.Item_list1[loop].prno);
                    obj.ReqDate = Convert.ToDateTime(record.Item_list1[loop].reqdate);
                    if (record.Item_list1[loop].qty1 != "")
                    {
                        obj.Qty1 = Convert.ToDecimal(record.Item_list1[loop].qty1);
                    }
                    if (record.Item_list1[loop].rate1 != "")
                    {
                        obj.Rate1 = Convert.ToDecimal(record.Item_list1[i].rate1);
                    }
                    if (record.Item_list1[loop].salesperc1 != "" || record.Item_list1[loop].salesperc1 != "0")
                    {
                        obj.SalesTaxPer1 = Convert.ToInt32(record.Item_list1[i].salesperc1);
                    }

                    if (record.Item_list1[loop].vendoramount1 != "")
                    {
                        obj.Vendor_Amount1 = Convert.ToDecimal(record.Item_list1[loop].vendoramount1);
                    }
                    if (record.Item_list1[loop].prdet_id != "")
                    {
                        obj.PR_Detail_ID = Convert.ToInt32(record.Item_list1[loop].prdet_id);
                    }
                    bBreak = false;


                    for (int x = 0; x < record.Item_list2.Count; x++)
                    {
                        if (bBreak)
                            break;
                        obj.Vendor2 = record.txt_vendorName_vendor2;
                        obj.Payment_Terms2 = record.txt_paymentTerms_vendor2;
                        obj.Delivery_Terms2 = record.txt_DeliveryTerms_vendor2;
                        obj.TotalSalesTax2 = record.TotalSalesTax2;

                        if (record.txt_amount_vendor2 != "")
                        {
                            obj.Amount2 = Convert.ToDecimal(record.txt_amount_vendor2);
                        }
                        if (record.txt_Freight_vendor2 != "")
                        {
                            obj.Freight2 = Convert.ToDecimal(record.txt_Freight_vendor2);
                        }
                        if (record.txt_TotalAmount_vendor2 != "")
                        {
                            obj.Total_Amount2 = Convert.ToDecimal(record.txt_TotalAmount_vendor2);
                        }
                        obj.Vendor_bit_2 = Convert.ToBoolean(record.Item_list2[loop].vendbit2);
                        if (record.Item_list2[loop].qty2 != "")
                        {
                            obj.Qty2 = Convert.ToDecimal(record.Item_list2[loop].qty2);
                        }
                        if (record.Item_list2[loop].rate2 != "")
                        {
                            obj.Rate2 = Convert.ToDecimal(record.Item_list2[loop].rate2);
                        }
                        if (record.Item_list2[loop].salesperc2 != "" || record.Item_list2[loop].salesperc2 != "0")
                        {
                            obj.SalesTaxPer2 = Convert.ToInt32(record.Item_list2[i].salesperc2);
                        }
                        if (record.Item_list2[loop].vendoramount2 != "")
                        {
                            obj.Vendor_Amount2 = Convert.ToDecimal(record.Item_list2[loop].vendoramount2);
                        }


                        for (int z = 0; z < record.Item_list3.Count; z++)
                        {
                            if (bBreak)
                                break;
                            obj.Vendor3 = record.txt_vendorName_vendor3;
                            obj.Payment_Terms3 = record.txt_paymentTerms_vendor3;
                            obj.Delivery_Terms3 = record.txt_DeliveryTerms_vendor3;
                            obj.TotalSalesTax3 = record.TotalSalesTax3;

                            if (record.txt_amount_vendor3 != "")
                            {
                                obj.Amount3 = Convert.ToDecimal(record.txt_amount_vendor3);
                            }
                            if (record.txt_Freight_vendor3 != "")
                            {
                                obj.Freight3 = Convert.ToDecimal(record.txt_Freight_vendor3);
                            }
                            if (record.txt_TotalAmount_vendor3 != "")
                            {
                                obj.Total_Amount3 = Convert.ToDecimal(record.txt_TotalAmount_vendor3);
                            }
                            obj.Vendor_bit_3 = Convert.ToBoolean(record.Item_list3[loop].vendbit3);
                            if (record.Item_list3[loop].qty3 != "")
                            {
                                obj.Qty3 = Convert.ToDecimal(record.Item_list3[loop].qty3);
                            }
                            if (record.Item_list3[loop].rate3 != "")
                            {
                                obj.Rate3 = Convert.ToDecimal(record.Item_list3[loop].rate3);
                            }
                            if (record.Item_list3[loop].salesperc3 != "" || record.Item_list3[loop].salesperc3 != "0")
                            {
                                obj.SalesTaxPer3 = Convert.ToInt32(record.Item_list3[i].salesperc3);
                            }
                            if (record.Item_list3[loop].vendoramount3 != "")
                            {
                                obj.Vendor_Amount3 = Convert.ToDecimal(record.Item_list3[loop].vendoramount3);
                            }

                            for (int y = 0; y < record.Item_list4.Count; y++)
                            {
                                if (bBreak)
                                    break;
                                obj.Vendor4 = record.txt_vendorName_vendor4;
                                obj.Payment_Terms4 = record.txt_paymentTerms_vendor4;
                                obj.Delivery_Terms4 = record.txt_DeliveryTerms_vendor4;
                                obj.TotalSalesTax4 = record.TotalSalesTax4;

                                if (record.txt_amount_vendor4 != "")
                                {
                                    obj.Amount4 = Convert.ToDecimal(record.txt_amount_vendor4);
                                }
                                if (record.txt_Freight_vendor4 != "")
                                {
                                    obj.Freight4 = Convert.ToDecimal(record.txt_Freight_vendor4);
                                }
                                if (record.txt_TotalAmount_vendor4 != "")
                                {
                                    obj.Total_Amount4 = Convert.ToDecimal(record.txt_TotalAmount_vendor4);
                                }
                                obj.Vendor_bit_4 = Convert.ToBoolean(record.Item_list4[loop].vendbit4);
                                if (record.Item_list4[loop].qty4 != "")
                                {
                                    obj.Qty4 = Convert.ToDecimal(record.Item_list4[loop].qty4);
                                }
                                if (record.Item_list4[loop].rate4 != "")
                                {
                                    obj.Rate4 = Convert.ToDecimal(record.Item_list4[loop].rate4);
                                }
                                if (record.Item_list4[loop].salesperc4 != "" || record.Item_list4[loop].salesperc4 != "0")
                                {
                                    obj.SalesTaxPer4 = Convert.ToInt32(record.Item_list4[i].salesperc4);
                                }
                                if (record.Item_list4[loop].vendoramount4 != "")
                                {
                                    obj.Vendor_Amount4 = Convert.ToDecimal(record.Item_list4[loop].vendoramount4);
                                }

                                for (int zi = 0; zi < record.Item_list5.Count; zi++)
                                {
                                    if (bBreak)
                                        break;
                                    obj.Vendor5 = record.txt_vendorName_vendor5;
                                    obj.Payment_Terms5 = record.txt_paymentTerms_vendor5;
                                    obj.Delivery_Terms5 = record.txt_DeliveryTerms_vendor5;
                                    obj.TotalSalesTax5 = record.TotalSalesTax5;

                                    if (record.txt_amount_vendor5 != "")
                                    {
                                        obj.Amount5 = Convert.ToDecimal(record.txt_amount_vendor5);
                                    }
                                    if (record.txt_Freight_vendor5 != "")
                                    {
                                        obj.Freight5 = Convert.ToDecimal(record.txt_Freight_vendor5);
                                    }
                                    if (record.txt_TotalAmount_vendor5 != "")
                                    {
                                        obj.Total_Amount5 = Convert.ToDecimal(record.txt_TotalAmount_vendor5);
                                    }
                                    obj.Vendor_bit_5 = Convert.ToBoolean(record.Item_list5[loop].vendbit5);
                                    if (record.Item_list5[loop].qty5 != "")
                                    {
                                        obj.Qty5 = Convert.ToDecimal(record.Item_list5[loop].qty5);
                                    }
                                    if (record.Item_list5[loop].rate5 != "")
                                    {
                                        obj.Rate5 = Convert.ToDecimal(record.Item_list5[loop].rate5);
                                    }
                                    if (record.Item_list5[loop].salesperc5 != "" || record.Item_list5[loop].salesperc5 != "0")
                                    {
                                        obj.SalesTaxPer5 = Convert.ToInt32(record.Item_list5[i].salesperc5);
                                    }
                                    if (record.Item_list5[loop].vendoramount5 != "")
                                    {
                                        obj.Vendor_Amount5 = Convert.ToDecimal(record.Item_list5[loop].vendoramount5);
                                    }
                                    db.CS_Vendors.InsertOnSubmit(obj);
                                    db.SubmitChanges();
                                    lst.Add(obj.CS_Ven_ID.ToString());
                                    code.Add(obj.Item_Code);
                                    bBreak = true;
                                    loop++;
                                    break;

                                }
                            }
                        }
                    }
                }
                for (int i = 0; i < record.GRNItem_list.Count; i++)
                {
                    var id = lst[i];
                    var itcode = code[i];
                    if (record.GRNItem_list[i].grnappamount != "")
                    {
                        DBClass.executeNonQueryWithoutBegin("update CS_Vendor set Total_App_Amount=" + record.GRNItem_list[i].grnappamount + " where CS_Ven_id=" + id);
                    }
                    if (record.GRNItem_list[i].lastgrnnumber != "")
                    {
                        DBClass.executeNonQueryWithoutBegin("update CS_Vendor set Last_GRN_No=" + record.GRNItem_list[i].lastgrnnumber + " where CS_Ven_id=" + id);
                    }
                    if (record.GRNItem_list[i].lastgrnrate != "")
                    {
                        DBClass.executeNonQueryWithoutBegin("update CS_Vendor set Last_GRN_Rate =" + record.GRNItem_list[i].lastgrnrate + " where CS_Ven_id=" + id);
                    }
                }
            }
            return cmid;
        }
        [WebMethod]
        public static string GetNewCSNo()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var CS_NO = DBClass.GetNewNumber("CS_Ven_No", "CS_Vendor_Master", "");
            return CS_NO.ToString();
        }
        private class ddlListItems
        {
            public string DataValueName;
            public string DataValueDescription;
            public string Type;
        }
        [WebMethod]
        public static string GetSalesTax()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var query = (from a in db.Sales_Taxes
                         select new
                         {
                             a.Sales_Tax_ID,
                             a.Sales_Tax_Perc,
                         }).ToList();
            string data = string.Empty;
            return (new JavaScriptSerializer()).Serialize(query);
        }



        [WebMethod]
        public static string GetDeliveryTerms()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            List<ddlListItems> listItems = new List<ddlListItems>();
            string data = string.Empty;
            listItems = (from p in db.DataValues
                         join v in db.ValueSets on p.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Description == "DeliveryTerms"
                         select new ddlListItems
                         {
                             DataValueName = p.DataValue_Name,
                             DataValueDescription = p.DataValue_Description,
                         }).ToList();
            return (new JavaScriptSerializer()).Serialize(listItems);
        }
         [WebMethod]
        public static string GetWareHouseCondition()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var dept = (from data in db.sys_Parms
                        where data.Name == "WareHouse For PO"
                        select
                          data.Code
                        ).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(dept);
        }
        [WebMethod]
        public static string GetPaymentTerms()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            List<ddlListItems> listItems = new List<ddlListItems>();
            string data = string.Empty;
            listItems = (from p in db.DataValues
                         join v in db.ValueSets on p.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Description == "PaymentTerms"
                         select new ddlListItems
                         {
                             DataValueName = p.DataValue_Name,
                             DataValueDescription = p.DataValue_Description,
                         }).ToList();
            return (new JavaScriptSerializer()).Serialize(listItems);
        }

      
        [WebMethod]
        public static string GetPRNoByWarehouse_CS(string Warehouse)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var RFQ = db.sp_LoadPRNumOnCS(Warehouse);
            return (new JavaScriptSerializer()).Serialize(RFQ);
        }
        [WebMethod]
        public static string getVendorDDLlist()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            AP_Vendor obj = new AP_Vendor();
            var listItems = (from a in db.AP_Vendors where a.IsActive==true
                             select new
                             {
                                 a.Vendor_ID,
                                 a.Vendor_Name,
                             }).ToList();
            return (new JavaScriptSerializer()).Serialize(listItems);
        }
        [WebMethod]
        public static string Approvecsven(string cm_id)
        {
            var userid = AppConfig.UserID;
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.spApproveCs(Convert.ToInt32(cm_id), userid);
            return (new JavaScriptSerializer()).Serialize(Details);
        }
        [WebMethod]
        public static string UnApprovecsven(string cm_id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.spUnApproveCs(Convert.ToInt32(cm_id));
            return (new JavaScriptSerializer()).Serialize(Details);
        }
        [WebMethod]
        public static string CancelEntry(string CS_ID)
        {
            try
            {
                var userid = Convert.ToString(AppConfig.UserID);
                DataBaseDataContext db = new DataBaseDataContext();
                var result = db.spCancelCs(Convert.ToInt32(CS_ID), userid);
                var resultList = result.ToList();
                if (resultList.Any())
                {
                    var serializedResult = (new JavaScriptSerializer()).Serialize(resultList);
                    return serializedResult;
                }
                else
                {
                    return "{ 'error': 'No data returned from the stored procedure.' }";
                }
            }
            catch (Exception ex)
            {
                return "{ 'error': '" + ex.Message + "' }";
            }
        }

        [WebMethod]
        public static string gettaxtype()

        {
            DataBaseDataContext db = new DataBaseDataContext();
            var query = (from a in db.Sales_Taxes
                         select new
                         {
                             a.Sales_Tax_ID,
                             a.Sales_Tax_Perc,
                         }).ToList();
            string data = string.Empty;
            return (new JavaScriptSerializer()).Serialize(query);
        }
        public class MasterCSList
        {
            public string txtstatus { get; set; }
            public string csno { get; set; }
            public string WareHouse { get; set; }
            public string Branch { get; set; }
            public string date { get; set; }
            public string csvalidity { get; set; }
            public string remarks { get; set; }
            public string Term_Id { get; set; }

            public string txt_vendorName_vendor1 { get; set; }
            public string txt_vendorName_vendor2 { get; set; }
            public string txt_vendorName_vendor3 { get; set; }
            public string txt_vendorName_vendor4 { get; set; }
            public string txt_vendorName_vendor5 { get; set; }

            public string txt_paymentTerms_vendor1 { get; set; }
            public string txt_paymentTerms_vendor2 { get; set; }
            public string txt_paymentTerms_vendor3 { get; set; }
            public string txt_paymentTerms_vendor4 { get; set; }
            public string txt_paymentTerms_vendor5 { get; set; }

            public string txt_DeliveryTerms_vendor1 { get; set; }
            public string txt_DeliveryTerms_vendor2 { get; set; }
            public string txt_DeliveryTerms_vendor3 { get; set; }
            public string txt_DeliveryTerms_vendor4 { get; set; }
            public string txt_DeliveryTerms_vendor5 { get; set; }

            public string TotalSalesTax1 { get; set; }
            public string TotalSalesTax2 { get; set; }
            public string TotalSalesTax3 { get; set; }
            public string TotalSalesTax4 { get; set; }
            public string TotalSalesTax5 { get; set; }

            public string txt_amount_vendor1 { get; set; }
            public string txt_amount_vendor2 { get; set; }
            public string txt_amount_vendor3 { get; set; }
            public string txt_amount_vendor4 { get; set; }
            public string txt_amount_vendor5 { get; set; }

            public string txt_Freight_vendor1 { get; set; }
            public string txt_Freight_vendor2 { get; set; }
            public string txt_Freight_vendor3 { get; set; }
            public string txt_Freight_vendor4 { get; set; }
            public string txt_Freight_vendor5 { get; set; }

            public string txt_TotalAmount_vendor1 { get; set; }
            public string txt_TotalAmount_vendor2 { get; set; }
            public string txt_TotalAmount_vendor3 { get; set; }
            public string txt_TotalAmount_vendor4 { get; set; }
            public string txt_TotalAmount_vendor5 { get; set; }

            public List<VendorList1> Item_list1 { get; set; }
            public List<VendorList2> Item_list2 { get; set; }
            public List<VendorList3> Item_list3 { get; set; }
            public List<VendorList4> Item_list4 { get; set; }
            public List<VendorList5> Item_list5 { get; set; }
            public List<GRNTableList> GRNItem_list { get; set; }
        }
        public class VendorList1
        {
            public string vendbit1 { get; set; }
            public string prdet_id { get; set; }
            public string itemid { get; set; }
            public string prid { get; set; }
            public string prno { get; set; }
            public string reqdate { get; set; }
            public string itemcode { get; set; }

            public string qty1 { get; set; }
            public string rate1 { get; set; }
            public string salesperc1 { get; set; }
            public string vendoramount1 { get; set; }
        }

        public class VendorList2
        {
            public string vendbit2 { get; set; }
            public string qty2 { get; set; }
            public string rate2 { get; set; }
            public string salesperc2 { get; set; }
            public string vendoramount2 { get; set; }
        }

        public class VendorList3
        {
            public string vendbit3 { get; set; }
            public string qty3 { get; set; }
            public string rate3 { get; set; }
            public string salesperc3 { get; set; }
            public string vendoramount3 { get; set; }
        }
        public class VendorList4
        {
            public string vendbit4 { get; set; }
            public string qty4 { get; set; }
            public string rate4 { get; set; }
            public string salesperc4 { get; set; }
            public string vendoramount4 { get; set; }
        }

        public class VendorList5
        {
            public string vendbit5 { get; set; }
            public string qty5 { get; set; }
            public string rate5 { get; set; }
            public string salesperc5 { get; set; }
            public string vendoramount5 { get; set; }

        }
        public class listGrn
        {
            public int ItemCode { get; set; }
            public int CSMaster_id { get; set; }
        }

        public class GRNTableList
        {
            public string ItemCode { get; set; }
            public string lastgrnnumber { get; set; }
            public string lastgrnrate { get; set; }
            public string grnappamount { get; set; }
        }

        [WebMethod]
        public static bool CheckCSApprovalRights()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var form_id = 1;
                var user_id = AppConfig.UserID;

                return (from SASD in db.Sys_Approval_Stage_Details
                        join SASM in db.Sys_Approval_Stage_Masters on SASD.Stage_ID equals SASM.Stage_ID
                        join SATD in db.Sys_Approval_Tempelate_Detail_Stages on SASM.Stage_ID equals SATD.StageId
                        join SATF in db.Sys_Approval_Tempelate_Detail_Forms on SATD.Tempelate_ID equals SATF.Tempelate_ID
                        join SATM in db.Sys_Approval_Tempelate_Masters on SATD.Tempelate_ID equals SATM.Tempelate_ID
                        where SASD.UserId == user_id && SATF.FormId == form_id && SATM.IsActive == true && SASM.IsDeleted == false
                        select SASD).Any();
            }
        }

        [WebMethod]
        public static string GetCSApprovalInfo(string CMId)
        {
            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                var cmId = Convert.ToInt32(CMId);
                var user_id = AppConfig.UserID;
                var form_id = 1;

                var cs = db.CS_Vendor_Masters
                    .Where(c => c.CS_Ven_Master_ID == cmId)
                    .FirstOrDefault();

                if (cs == null)
                    return (new JavaScriptSerializer()).Serialize(new { CanApprove = false, MaxApprovalLimit = 0m, Amount = 0m });

                var maxApprovalLimit = db.ExecuteQuery<decimal?>(
                    "SELECT MAX(SASD.MaxApprovalLimit) " +
                    "FROM Sys_Approval_Stage_Detail SASD " +
                    "INNER JOIN Sys_Approval_Stage_Master SASM ON SASD.Stage_ID = SASM.Stage_ID " +
                    "INNER JOIN Sys_Approval_Tempelate_Detail_Stages SATD ON SASM.Stage_ID = SATD.StageId " +
                    "INNER JOIN Sys_Approval_Tempelate_Detail_Forms SATF ON SATD.Tempelate_ID = SATF.Tempelate_ID " +
                    "INNER JOIN Sys_Approval_Tempelate_Master SATM ON SATD.Tempelate_ID = SATM.Tempelate_ID " +
                    "WHERE SASD.UserId = {0} AND SATF.FormId = {1} AND SATM.IsActive = 1 AND SASM.IsDeleted = 0",
                    user_id, form_id).FirstOrDefault() ?? 0m;

                var canApprove = maxApprovalLimit == -1m;

                var result = new
                {
                    CanApprove = canApprove,
                    MaxApprovalLimit = maxApprovalLimit,
                    Amount = 0m
                };

                return (new JavaScriptSerializer()).Serialize(result);
            }
        }

        [WebMethod]
        public static string ApproveSingleCS(string CMId, string approvalRemarks)
        {
            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                var cmId = Convert.ToInt32(CMId);
                var user_id = AppConfig.UserID;
                var form_id = 1;

                var cs = db.CS_Vendor_Masters
                    .Where(c => c.CS_Ven_Master_ID == cmId)
                    .SingleOrDefault();

                if (cs == null)
                    return "Error: Comparative Statement not found";

                var isFinalApprovals = (from SASD in db.Sys_Approval_Stage_Details
                                        join SASM in db.Sys_Approval_Stage_Masters on SASD.Stage_ID equals SASM.Stage_ID
                                        join SATD in db.Sys_Approval_Tempelate_Detail_Stages on SASM.Stage_ID equals SATD.StageId
                                        join SATF in db.Sys_Approval_Tempelate_Detail_Forms on SATD.Tempelate_ID equals SATF.Tempelate_ID
                                        where SASD.UserId == user_id && SATF.FormId == form_id && SASM.IsDeleted == false
                                        select new { SASM.IsFinalApproval, SATF.FormId }).ToList();

                if (isFinalApprovals.Any(a => a.IsFinalApproval == true && a.FormId == form_id))
                {
                    var Details = db.spApproveCs(cs.CS_Ven_Master_ID, user_id);
                    db.SubmitChanges();

                    var sasd = (from tbl in db.Sys_Approval_Stage_Details
                                join SASM in db.Sys_Approval_Stage_Masters on tbl.Stage_ID equals SASM.Stage_ID
                                join SATDS in db.Sys_Approval_Tempelate_Detail_Stages on SASM.Stage_ID equals SATDS.StageId
                                join SATF in db.Sys_Approval_Tempelate_Detail_Forms on SATDS.Tempelate_ID equals SATF.Tempelate_ID
                                where tbl.UserId == user_id && SASM.IsFinalApproval == true && SATF.FormId == form_id && SASM.IsDeleted == false
                                select tbl).FirstOrDefault();

                    if (sasd != null)
                    {
                        var satds = (from tbl in db.Sys_Approval_Tempelate_Detail_Stages
                                     join SATF in db.Sys_Approval_Tempelate_Detail_Forms on tbl.Tempelate_ID equals SATF.Tempelate_ID
                                     where tbl.StageId == sasd.Stage_ID && SATF.FormId == form_id
                                     select tbl).FirstOrDefault();

                        if (satds != null)
                        {
                            var log = new Sys_Approval_Log();
                            log.Approval_Template_ID = satds.Tempelate_ID;
                            log.Approval_Stage_ID = sasd.Stage_ID;
                            log.Entry_ID = cs.CS_Ven_Master_ID;
                            log.Form_ID = form_id;
                            log.From_Name = "Comparative Statement";
                            log.Remarks = cs.Remarks;
                            log.Company_ID = AppConfig.Company_ID;
                            log.IsFinalAprroval = true;
                            log.Entry_Status = "Approved";
                            log.Approve_By = user_id;
                            log.Approve_Date = DateTime.Now;
                            log.IsRejected = false;
                            log.Approval_Remarks = approvalRemarks;
                            db.Sys_Approval_Logs.InsertOnSubmit(log);
                            db.SubmitChanges();
                        }
                    }
                }
                else
                {
                    cs.Status = "Pending";
                    cs.Approved_Time = DateTime.Now;
                    cs.Approved_By = user_id;
                    db.SubmitChanges();

                    var sasd = (from tbl in db.Sys_Approval_Stage_Details
                                join SASM in db.Sys_Approval_Stage_Masters on tbl.Stage_ID equals SASM.Stage_ID
                                join SATDS in db.Sys_Approval_Tempelate_Detail_Stages on SASM.Stage_ID equals SATDS.StageId
                                join SATF in db.Sys_Approval_Tempelate_Detail_Forms on SATDS.Tempelate_ID equals SATF.Tempelate_ID
                                where tbl.UserId == user_id && SASM.IsFinalApproval == false && SATF.FormId == form_id && SASM.IsDeleted == false
                                select tbl).FirstOrDefault();

                    if (sasd != null)
                    {
                        var satds = (from tbl in db.Sys_Approval_Tempelate_Detail_Stages
                                     join SATF in db.Sys_Approval_Tempelate_Detail_Forms on tbl.Tempelate_ID equals SATF.Tempelate_ID
                                     where tbl.StageId == sasd.Stage_ID && SATF.FormId == form_id
                                     select tbl).FirstOrDefault();

                        if (satds != null)
                        {
                            var log = new Sys_Approval_Log();
                            log.Approval_Template_ID = satds.Tempelate_ID;
                            log.Approval_Stage_ID = sasd.Stage_ID;
                            log.Entry_ID = cs.CS_Ven_Master_ID;
                            log.Form_ID = form_id;
                            log.From_Name = "Comparative Statement";
                            log.Remarks = cs.Remarks;
                            log.Company_ID = AppConfig.Company_ID;
                            log.IsFinalAprroval = false;
                            log.Entry_Status = "Pending";
                            log.Approve_By = user_id;
                            log.Approve_Date = DateTime.Now;
                            log.IsRejected = false;
                            log.Approval_Remarks = approvalRemarks;
                            db.Sys_Approval_Logs.InsertOnSubmit(log);
                            db.SubmitChanges();
                        }
                    }
                }
                db.SubmitChanges();
                return "Success";
            }
        }
    }
}