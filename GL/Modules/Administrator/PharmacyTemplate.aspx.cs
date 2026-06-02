using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using static PMS.panelagreement;

namespace PMS.GL
{
    public partial class PharmacyTemplate : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        
        [WebMethod]
        public static string Save(string btnValue, string id, string templateName, List<TemplateDetail> details)
        {
            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                int templateId;
                int? parsedId = null;
                if (!string.IsNullOrWhiteSpace(id) && int.TryParse(id, out templateId))
                {
                    parsedId = templateId;
                }

                var existsQuery = db.Pharmacy_Template_Masters.Where(x => x.TemplateName == templateName && !x.IsCancel);
                if (parsedId.HasValue)
                {
                    existsQuery = existsQuery.Where(x => x.ID != parsedId.Value);
                }
                bool exists = existsQuery.Any();
                if (exists)
                {
                    return "EXISTS";
                }

                Pharmacy_Template_Master master;
                if (btnValue == "Save")
                {
                    master = new Pharmacy_Template_Master
                    {
                        TemplateName = templateName,
                        CreatedBy = AppConfig.UserID,
                        CreatedTime = DateTime.Now,
                        IsCancel = false
                    };
                    db.Pharmacy_Template_Masters.InsertOnSubmit(master);
                    db.SubmitChanges();
                }
                else
                {
                    if (!parsedId.HasValue)
                    {
                        return "0";
                    }
                    master = db.Pharmacy_Template_Masters.FirstOrDefault(x => x.ID == parsedId.Value);
                    if (master == null)
                    {
                        return "0";
                    }
                    master.TemplateName = templateName;
                    master.UpdatedBy = AppConfig.UserID;
                    master.UpdatedTime = DateTime.Now;
                    db.SubmitChanges();
                }

                foreach (var detail in details ?? new List<TemplateDetail>())
                {
                    if (detail.IsDeleted && detail.DetailId > 0)
                    {
                        var existingDetail = db.Pharmacy_Template_Details.FirstOrDefault(x => x.ID == detail.DetailId);
                        if (existingDetail != null && !existingDetail.IsDeleted)
                        {
                            existingDetail.IsDeleted = true;
                            existingDetail.DeletedBy = AppConfig.UserID;
                            existingDetail.DeletedTime = DateTime.Now;
                        }
                        continue;
                    }

                    if (detail.DetailId > 0)
                    {
                        var existingDetail = db.Pharmacy_Template_Details.FirstOrDefault(x => x.ID == detail.DetailId);
                        if (existingDetail != null)
                        {
                            existingDetail.ItemID = detail.ItemId;
                            existingDetail.ItemName = detail.ItemName;
                            existingDetail.IsDeleted = false;
                            existingDetail.UpdatedBy = AppConfig.UserID;
                            existingDetail.UpdatedTime = DateTime.Now;
                        }
                    }
                    else
                    {
                        var newDetail = new Pharmacy_Template_Detail
                        {
                            Pharmacy_Template_Master_ID = master.ID,
                            ItemID = detail.ItemId,
                            ItemName = detail.ItemName,
                            CreatedBy = AppConfig.UserID,
                            CreatedTime = DateTime.Now,
                            IsDeleted = false
                        };
                        db.Pharmacy_Template_Details.InsertOnSubmit(newDetail);
                    }
                }

                db.SubmitChanges();
                return master.ID.ToString();
            }
        }

        [WebMethod]
        public static string CheckTemplateNameExists(string templateName, string id)
        {
            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                int templateId;
                int? parsedId = null;
                if (!string.IsNullOrWhiteSpace(id) && int.TryParse(id, out templateId))
                {
                    parsedId = templateId;
                }

                var existsQuery = db.Pharmacy_Template_Masters.Where(x => x.TemplateName == templateName && !x.IsCancel);
                if (parsedId.HasValue)
                {
                    existsQuery = existsQuery.Where(x => x.ID != parsedId.Value);
                }
                bool exists = existsQuery.Any();
                return (new JavaScriptSerializer()).Serialize(exists);
            }
        }

        [WebMethod]
        public static string LoadDetails(int id)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var detail = (from d in db.Pharmacy_Template_Details
                              where d.Pharmacy_Template_Master_ID == id && !d.IsDeleted
                              select new TemplateDetail
                              {
                                  DetailId = d.ID,
                                  ItemId = d.ItemID ?? 0,
                                  ItemName = d.ItemName
                              }).ToList();
                return (new JavaScriptSerializer()).Serialize(detail);
            }
        }

        [WebMethod]
        public static string LoadMasterData(string id)
        {
            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                int templateId;
                if (!int.TryParse(id, out templateId))
                {
                    return (new JavaScriptSerializer()).Serialize(null);
                }
                var query = db.Pharmacy_Template_Masters.FirstOrDefault(x => x.ID == templateId && !x.IsCancel);
                return (new JavaScriptSerializer()).Serialize(query);
            }
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
        public static object getpharmacyitems(string searchString)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var pharmacyItems = (from d in db.INV_Items
                                     where d.IsPharmacyItem == true && d.Description.Contains(searchString)
                                     orderby d.Item_ID descending
                                     select new
                                     {
                                         d.Item_ID,
                                         Description = d.Description.Replace("\r", "").Replace("\n", "").Replace("\t", "").Trim()
                                     }).Take(20).ToList();

                return pharmacyItems;
            }
        }

        private static string SanitizeControlChars(string value)
        {
            if (string.IsNullOrEmpty(value))
            {
                return value;
            }

            var filtered = value.Where(ch => !char.IsControl(ch) || ch == '\r' || ch == '\n' || ch == '\t').ToArray();
            return new string(filtered);
        }

        public class TemplateDetail
        {
            public int DetailId { get; set; }
            public int ItemId { get; set; }
            public string ItemName { get; set; }
            public bool IsDeleted { get; set; }
        }
    }
}