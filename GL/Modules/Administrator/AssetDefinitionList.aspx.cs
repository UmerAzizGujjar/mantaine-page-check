using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using Telerik.Web.UI.PivotGrid.Core.Groups;

namespace PMS
{
    public partial class AssetDefinitionList : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }



        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    string userId = HttpContext.Current.Session["UserId"].ToString();

                    var Asset_Definitions = _dbContext.Asset_Definitions.Count();
                    var Asset_Definition = (from records in _dbContext.Asset_Definitions
                                            join category in _dbContext.Asset_Categories
                                            on Convert.ToInt32(records.Asset_Cat_id) equals category.Asset_Category_Id into catGroup
                                            from category in catGroup.DefaultIfEmpty()

                                            join subCategory in _dbContext.Asset_SubCategories
                                                on Convert.ToInt32(records.Asset_SubCat_Id) equals subCategory.Asset_SubCat_ID into subCatGroup
                                            from subCategory in subCatGroup.DefaultIfEmpty()

                                            join location in _dbContext.Locations
                                                on records.Location_ID equals location.Location_ID into locGroup
                                            from location in locGroup.DefaultIfEmpty()
                                            where (subCategory.Asset_SubCat_Name.ToString().Contains(searchValue) || category.Asset_Cat_Name.Contains(searchValue) || location.Location_Description.Contains(searchValue))
                                            select new
                                            {
                                                records.Asset_Definition_Id,
                                                AssetCategory = category != null ? category.Asset_Cat_Name : null,
                                                AssetSubCategory = subCategory != null ? subCategory.Asset_SubCat_Name : null,
                                                Location = location != null ? location.Location_Description : null,
                                                records.Item_Description

                                            });



                    var FilteredCount = Asset_Definition.Count();
                    switch (sortColumn)
                    {
                        case "AssetCategory":
                            Asset_Definition = sortColumnDirection == "asc" ? Asset_Definition.OrderBy(a => a.AssetCategory) : Asset_Definition.OrderByDescending(a => a.AssetCategory);
                            break;
                        case "AssetSubCategory":
                            Asset_Definition = sortColumnDirection == "asc" ? Asset_Definition.OrderBy(a => a.AssetSubCategory) : Asset_Definition.OrderByDescending(a => a.AssetSubCategory);
                            break;
                        case "Location":
                            Asset_Definition = sortColumnDirection == "asc" ? Asset_Definition.OrderBy(a => a.Location) : Asset_Definition.OrderByDescending(a => a.Location);
                            break;
                        default:
                            Asset_Definition = Asset_Definition.OrderByDescending(a => a.Asset_Definition_Id);
                            break;
                    }


                    var Asset_Definitionlist = Asset_Definition.Skip(start).Take(length).ToList();


                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Asset_Definitions, data = Asset_Definitionlist };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching patient list", ex);
            }
        }

        [WebMethod]
        public static bool Delete(string Id)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());


            SqlTransaction tranObj = null;
            SqlConnection con = new SqlConnection(DBClass.ConnectionString());
            con.Open();
            tranObj = con.BeginTransaction();
            try
            {
                var MainId = (from itm in db.Asset_Definitions
                              where (itm.Asset_Definition_Id == int.Parse(Id))
                              select itm.Asset_Definition_Id).FirstOrDefault();
                if (MainId != 0)
                {
                    DBClass.exectueQuery("delete Asset_Definition where Asset_Definition_Id =" + MainId, tranObj, con);
                    DBClass.exectueQuery("delete Asset_Definition_Cost_Fill where Asset_Definition_Id =" + MainId, tranObj, con);
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
    }
}