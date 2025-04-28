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
    public partial class AssetSubCategory : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
            }
        }
        [WebMethod]
        public static string fillAssetSubCategories()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            List<ddlListItems> listItems = new List<ddlListItems>();
            string data = string.Empty;

            listItems = (from tbl in db.Asset_Categories
                      select new ddlListItems
                      {
                          Asset_Category_Id = tbl.Asset_Category_Id,
                          Asset_Cat_Name = tbl.Asset_Cat_Name,
                      }).ToList();

            return (new JavaScriptSerializer()).Serialize(listItems);
        }

        private class ddlListItems
        {
            public int Asset_Category_Id;
            public string Asset_Cat_Name;
        }
        [WebMethod]
        public static string LoadDetailAssetSubCategories()
        {
            List<AssetSubCategoryDetailDTO> listItems = new List<AssetSubCategoryDetailDTO>();
            string result = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                listItems = (from subCat in db.Asset_SubCategories
                             join cat in db.Asset_Categories on subCat.Asset_Cat_ID equals cat.Asset_Category_Id
                             select new AssetSubCategoryDetailDTO
                             {
                                 Asset_SubCat_ID = subCat.Asset_SubCat_ID,
                                 Asset_Cat_ID = Convert.ToInt32(subCat.Asset_Cat_ID),
                                 Asset_Cat_Name = cat.Asset_Cat_Name,
                                 Asset_SubCat_Name = subCat.Asset_SubCat_Name,
                                 Asset_SubCat_Description = subCat.Asset_SubCat_Description,
                             }).ToList();

                result = (new JavaScriptSerializer()).Serialize(listItems);
            }

            return result;
        }

        [WebMethod]
        public static string SaveAssetSubCategoryDetails(List<AssetSubCategoryDetailDTO> AssetSubCategoryDetails)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                try
                {
                    var existingDetails = db.Asset_SubCategories.ToList();
                    if (existingDetails.Any())
                    {
                        db.Asset_SubCategories.DeleteAllOnSubmit(existingDetails);
                        db.SubmitChanges();
                    }
                    foreach (var item in AssetSubCategoryDetails)
                    {
                        Asset_SubCategory newDetail = new Asset_SubCategory
                        {
                            Asset_Cat_ID = item.Asset_Cat_ID,
                            Asset_SubCat_Name = item.Asset_SubCat_Name,
                            Asset_SubCat_Description = item.Asset_SubCat_Description
                        };
                        db.Asset_SubCategories.InsertOnSubmit(newDetail);
                    }
                    db.SubmitChanges();
                    return "Success: Data inserted successfully.";
                }
                catch (Exception ex)
                {
                    return "Error: " + ex.Message;
                }
            }
        }

        public class AssetSubCategoryDetailDTO
        {
            public int Asset_SubCat_ID { get; set; }
            public int Asset_Cat_ID { get; set; }
            public string Asset_Cat_Name { get; set; }
            public string Asset_SubCat_Name { get; set; }
            public string Asset_SubCat_Description { get; set; }
        }
    }
}