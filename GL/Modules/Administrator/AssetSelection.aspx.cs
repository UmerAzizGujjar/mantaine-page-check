using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class AssetSelection : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Binding();

                if (Request.QueryString["ID"] != null)
                {
                    PopulateAstSlctData(Convert.ToInt32(Request.QueryString["ID"]));
                }
            }
        }
        public class Detail
        {
            public int subCatID;
            public string subCatName;
        }

        [System.Web.Services.WebMethod]
        public static List<Detail> GetSubCategory(int AssetCategoryID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            List<Detail> list = new List<Detail>();
            Detail rslt = new Detail();
            var rslt2 = (from tbl in db.Asset_SubCategories
                         where tbl.Asset_Cat_ID == AssetCategoryID
                         select new
                         {
                             tbl.Asset_SubCat_ID,
                             tbl.Asset_SubCat_Name
                         }).ToList();

            foreach (var obj in rslt2)
            {
                rslt.subCatID = obj.Asset_SubCat_ID;
                rslt.subCatName = obj.Asset_SubCat_Name;
                list.Add(rslt);
            }

            return list;
        }

        private void Binding()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            List<Asset_Category> CtgList = new List<Asset_Category>();
            CtgList = (from tbl in db.Asset_Categories
                       select tbl).ToList();
            ddlAsset_Cat.DataSource = CtgList;
            ddlAsset_Cat.DataTextField = "Asset_Cat_Name";
            ddlAsset_Cat.DataValueField = "Asset_Category_Id";
            ddlAsset_Cat.Items.Add(new ListItem("Please Select", "0"));
            ddlAsset_Cat.DataBind();
            ddlAsset_SubCat.Items.Add(new ListItem("Please Select", "0"));
            ddlAsset_SubCat.Enabled = false;

            DataTable dtLocation = new DataTable();
            dtLocation = DBClass.getDataTable("Select Location_ID, Location_Description From [dbo].[Location]");
            ddlLocation_ID.DataSource = dtLocation;
            ddlLocation_ID.DataTextField = "Location_Description";
            ddlLocation_ID.DataValueField = "Location_ID";
            ddlLocation_ID.Items.Add(new ListItem("Please Select", "0"));
            ddlLocation_ID.DataBind();

            sys_Company Comp = new sys_Company();
            Comp = (from tbl in db.sys_Companies
                       where tbl.Company_ID == 1
                       select tbl).FirstOrDefault();
            txtCompany_ID.Text = Comp.Company_Name;
        }

        private void PopulateAstSlctData(int astSlc_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            Asset_Selection astSlct = (from tbl in db.Asset_Selections
                                       where tbl.Asset_Selection_ID == astSlc_ID
                                       select tbl).FirstOrDefault();

            ddlAsset_SubCat.Enabled = true;
            List<Asset_SubCategory> SubCtgList = new List<Asset_SubCategory>();
            SubCtgList = (from tbl in db.Asset_SubCategories
                          where tbl.Asset_Cat_ID == astSlct.Asset_Cat_ID
                          select tbl).ToList();

            ddlAsset_SubCat.DataSource = SubCtgList;
            ddlAsset_SubCat.Items.Add(new ListItem("Please Select", "0"));
            ddlAsset_SubCat.DataTextField = "Asset_SubCat_Name";
            ddlAsset_SubCat.DataValueField = "Asset_SubCat_ID";
            ddlAsset_SubCat.DataBind();

            if (astSlct != null)
            {
                txtAsset_Selection_ID.Text = astSlct.Asset_Selection_ID.ToString();
                ddlLocation_ID.SelectedValue = astSlct.Location_ID.ToString();
                ddlAsset_Cat.SelectedValue = astSlct.Asset_Cat_ID.ToString();
                ddlAsset_SubCat.SelectedValue = astSlct.Asset_SubCat_ID.ToString();
                txtItem_Serial.Text = astSlct.Item_Serial;
                btnSave.Text = "Update";
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid)
                return;

            try
            {
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                Asset_Selection astSlct = new Asset_Selection();
                if (btnSave.Text == "Save")
                {
                    astSlct.Created_By = AppConfig.UserID;
                    astSlct.Created_Time = DateTime.Now;
                    astSlct.Book_ID = AppConfig.Book_ID;
                    astSlct.Company_ID = AppConfig.Company_ID;
                    astSlct.IsDeleted = false;
                }
                else
                {
                    astSlct = (from tbl in db.Asset_Selections
                                 where tbl.Asset_Selection_ID == Convert.ToInt32(Request.QueryString["ID"])
                                 select tbl).FirstOrDefault();

                    astSlct.Updated_By = AppConfig.UserID;
                    astSlct.Updated_Time = DateTime.Now;
                }

                astSlct.Location_ID = Convert.ToInt32(ddlLocation_ID.SelectedValue);
                astSlct.Asset_Cat_ID = Convert.ToInt32(ddlAsset_Cat.SelectedValue);
                
                if (!string.IsNullOrEmpty(ddlAsset_SubCat.SelectedValue))
                astSlct.Asset_SubCat_ID = Convert.ToInt32(ddlAsset_SubCat.SelectedValue);
                
                astSlct.Item_Serial = txtItem_Serial.Text;

                if (btnSave.Text == "Save")
                {
                    db.Asset_Selections.InsertOnSubmit(astSlct);
                    lblMessage.CssClass = "Data Inserted Successfully";
                }
                else
                {
                    lblMessage.CssClass = "Data Updated Successfully";
                }
                db.SubmitChanges();
                Response.Redirect("~/AssetSelectionView.aspx", false);
                lblMessage.CssClass = "sucessfullMessage";
            }
            catch (Exception ex)
            {
                throw;
            }
        }

        protected void ddlAsset_Cat_SelectedIndexChanged(object sender, EventArgs e)
        {
            ddlAsset_SubCat.Items.Clear();
            if (ddlAsset_Cat.SelectedIndex == 0)
            {
                ddlAsset_SubCat.Items.Add(new ListItem("Please Select", "0"));
                ddlAsset_SubCat.SelectedIndex = 0;
                ddlAsset_SubCat.Enabled = false;
                ddlAsset_SubCat.CausesValidation = false;
            }
            else
            {
                ddlAsset_SubCat.Enabled = true;
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                List<Asset_SubCategory> SubCtgList = new List<Asset_SubCategory>();
                SubCtgList = (from tbl in db.Asset_SubCategories
                              where tbl.Asset_Cat_ID == Convert.ToInt32(ddlAsset_Cat.SelectedValue)
                              select tbl).ToList();

                ddlAsset_SubCat.DataSource = SubCtgList;
                ddlAsset_SubCat.Items.Add(new ListItem("Please Select", "0"));
                ddlAsset_SubCat.DataTextField = "Asset_SubCat_Name";
                ddlAsset_SubCat.DataValueField = "Asset_SubCat_ID";
                ddlAsset_SubCat.DataBind();
            }
        } 
    }
}