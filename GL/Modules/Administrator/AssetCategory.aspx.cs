using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using static PMS.AP.PurchaseRequistion;

namespace PMS
{
    public partial class AssetCategory : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
            }
        }
        [WebMethod]
        public static string filldepreciationMethods()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            string data = string.Empty;
            var result = (from p in db.DataValues
                          join v in db.ValueSets on p.ValueSet_ID equals v.ValueSet_ID
                          where v.ValueSet_Description == "Depreciation Method"
                          select new
                          {
                              DataValueName = p.DataValue_Name,
                              DataValueDescription = p.DataValue_Description,
                          }).ToList();
            return (new JavaScriptSerializer()).Serialize(result);
        }


        //private class ddlListItems
        //{
        //    public string DataValueName;
        //    public string DataValueDescription;
        //}

        //[WebMethod]
        //public static string LoadDetailAssetCategory()
        //{
        //    List<AssetCategoryDetailDTO> listItems = new List<AssetCategoryDetailDTO>();
        //    string result = string.Empty;

        //    using (DataBaseDataContext db = new DataBaseDataContext())
        //    {
        //        listItems = (from data in db.Asset_Categories
        //                     select new AssetCategoryDetailDTO
        //                     {
        //                         Asset_Category_Id = data.Asset_Category_Id,
        //                         Asset_Cat_Name = data.Asset_Cat_Name,
        //                         Depreciation_Method_Name = data.Depreciation_Method_Name,
        //                         Depreciation_Method_Id = data.Depreciation_Method_Id,
        //                         Depreciation_Percentage = Convert.ToDecimal(data.Depreciation_Percentage)
        //                     }).ToList();

        //        result = (new JavaScriptSerializer()).Serialize(listItems);
        //    }

        //    return result;
        //}
        //[WebMethod]
        //public static string SaveAssetCategoryDetails(List<AssetCategoryDetailDTO> AssetCategoryDetails)
        //{
        //    using (DataBaseDataContext db = new DataBaseDataContext())
        //    {
        //        try
        //        {
        //            var existingDetails = db.Asset_Categories.ToList();
        //            if (existingDetails.Any())
        //            {
        //                db.Asset_Categories.DeleteAllOnSubmit(existingDetails);
        //                db.SubmitChanges();
        //            }
        //            foreach (var item in AssetCategoryDetails)
        //            {
        //                Asset_Category newDetail = new Asset_Category
        //                {
        //                    Asset_Cat_Name = item.Asset_Cat_Name,
        //                    Depreciation_Method_Id = item.Depreciation_Method_Id,
        //                    Depreciation_Method_Name = item.Depreciation_Method_Name,
        //                    Depreciation_Percentage = item.Depreciation_Percentage
        //                };
        //                db.Asset_Categories.InsertOnSubmit(newDetail);
        //            }
        //            db.SubmitChanges();
        //            return "Success: Data inserted successfully.";
        //        }
        //        catch (Exception ex)
        //        {
        //            return "Error: " + ex.Message;
        //        }
        //    }
        //}

        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    string userId = HttpContext.Current.Session["UserId"].ToString();

                    var Total_Categories = _dbContext.Asset_Categories.Count();
                    var Categories = from AC in _dbContext.Asset_Categories
                                   where
                                       (AC.Depreciation_Method_Name.ToString().Contains(searchValue) || AC.Depreciation_Percentage.ToString().Contains(searchValue) || AC.Asset_Category_Id.ToString().Contains(searchValue))
                                   select new
                                   {
                                       Asset_Category_Id = AC.Asset_Category_Id,
                                       Asset_Cat_Name = AC.Asset_Cat_Name,
                                       Depreciation_Method_Name = AC.Depreciation_Method_Name,
                                       Depreciation_Percentage = AC.Depreciation_Percentage,
                                   };

                    var FilteredCount = Categories.Count();
                    switch (sortColumn)
                    {
                        case "Depreciation_Method_Name":
                            Categories = sortColumnDirection == "asc" ? Categories.OrderBy(b => b.Depreciation_Method_Name) : Categories.OrderByDescending(a => a.Depreciation_Method_Name);
                            break;
                        case "Depreciation_Percentage":
                            Categories = sortColumnDirection == "asc" ? Categories.OrderBy(b => b.Depreciation_Percentage) : Categories.OrderByDescending(a => a.Depreciation_Percentage);
                            break;
                        default:
                            Categories = Categories.OrderByDescending(a => a.Asset_Category_Id);
                            break;
                    }
                    var AssetCategoriesList = Categories.Skip(start).Take(length).ToList();

                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Categories, data = AssetCategoriesList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Asset Categories list", ex);
            }
        }

        [WebMethod]
        public static string SaveAsset(string Asset_Category_Id, string Asset_Cat_Name, string Depreciation_Method_Id, string Depreciation_Method_Name, int Depreciation_Percentage, string btnValue)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            Asset_Category obj = null;

            try
            {
                if (btnValue == "Save")
                {
                    if (string.IsNullOrEmpty(Asset_Category_Id) || Asset_Category_Id == "0")
                    {
                        obj = new Asset_Category
                        {
                            Asset_Cat_Name = Asset_Cat_Name,
                            Depreciation_Method_Id = Depreciation_Method_Id,
                            Depreciation_Method_Name = Depreciation_Method_Name,
                            Depreciation_Percentage = Depreciation_Percentage,
                        };
                        db.Asset_Categories.InsertOnSubmit(obj);
                    }
                    else
                    {
                        return "Error: Invalid operation for saving a new record.";
                    }
                }
                else if (btnValue == "Update")
                {
                    obj = db.Asset_Categories.FirstOrDefault(x => x.Asset_Category_Id == Convert.ToInt32(Asset_Category_Id));
                    if (obj == null)
                    {
                        return "Error: Asset Category not found.";
                    }
                    obj.Asset_Cat_Name = Asset_Cat_Name;
                    obj.Depreciation_Method_Id = Depreciation_Method_Id;
                    obj.Depreciation_Method_Name = Depreciation_Method_Name;
                    obj.Depreciation_Percentage = Depreciation_Percentage;
                }

                db.SubmitChanges();
            }
            catch (Exception ex)
            {
                return "Error: " + ex.Message;
            }

            return "Success-" + (obj?.Asset_Category_Id.ToString() ?? "0");
        }


        //public class AssetCategoryDetailDTO
        //{
        //    public int Asset_Category_Id { get; set; }
        //    public string Asset_Cat_Name { get; set; }
        //    public string Depreciation_Method_Name { get; set; }
        //    public string Depreciation_Method_Id { get; set; }
        //    public decimal Depreciation_Percentage { get; set; }
        //}
    }
}