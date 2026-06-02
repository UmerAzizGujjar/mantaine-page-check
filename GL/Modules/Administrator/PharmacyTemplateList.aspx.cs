using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using Telerik.Web.UI;

namespace PMS
{
    public partial class PharmacyTemplateList : System.Web.UI.Page
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
                    var query = _dbContext.Pharmacy_Template_Masters.Where(x => !x.IsCancel);
                    if (!string.IsNullOrWhiteSpace(searchValue))
                    {
                        query = query.Where(x => x.TemplateName.Contains(searchValue));
                    }

                    var totalCount = _dbContext.Pharmacy_Template_Masters.Count(x => !x.IsCancel);
                    var filteredCount = query.Count();

                    switch (sortColumn)
                    {
                        case "TemplateName":
                            query = sortColumnDirection == "asc" ? query.OrderBy(a => a.TemplateName) : query.OrderByDescending(a => a.TemplateName);
                            break;
                        case "MedicineCount":
                            query = sortColumnDirection == "asc" ? query.OrderBy(a => a.ID) : query.OrderByDescending(a => a.ID);
                            break;
                        case "CreatedTime":
                            query = sortColumnDirection == "asc" ? query.OrderBy(a => a.CreatedTime) : query.OrderByDescending(a => a.CreatedTime);
                            break;
                        case "UpdatedTime":
                            query = sortColumnDirection == "asc" ? query.OrderBy(a => a.UpdatedTime) : query.OrderByDescending(a => a.UpdatedTime);
                            break;
                    }

                    var pagedTemplates = query.Skip(start).Take(length).ToList();
                    var masterIds = pagedTemplates.Select(t => t.ID).ToList();
                    var userIds = pagedTemplates.Select(t => t.CreatedBy)
                        .Concat(pagedTemplates.Select(t => t.UpdatedBy))
                        .Where(id => id.HasValue)
                        .Select(id => id.Value)
                        .Distinct()
                        .ToList();

                    var userLookup = _dbContext.aspnet_Users
                        .Where(u => userIds.Contains(u.UserId))
                        .ToDictionary(u => u.UserId, u => u.UserName);

                    var detailLookup = _dbContext.Pharmacy_Template_Details
                        .Where(d => masterIds.Contains(d.Pharmacy_Template_Master_ID) && !d.IsDeleted)
                        .ToList()
                        .GroupBy(d => d.Pharmacy_Template_Master_ID)
                        .ToDictionary(g => g.Key, g => g.ToList());

                    var templatelist = pagedTemplates.Select(t => new
                    {
                        TemplateID = t.ID,
                        TemplateName = t.TemplateName,
                        MedicineCount = detailLookup.ContainsKey(t.ID) ? detailLookup[t.ID].Count : 0,
                        CreatedByName = t.CreatedBy.HasValue && userLookup.ContainsKey(t.CreatedBy.Value) ? userLookup[t.CreatedBy.Value] : string.Empty,
                        CreatedTime = t.CreatedTime,
                        UpdatedByName = t.UpdatedBy.HasValue && userLookup.ContainsKey(t.UpdatedBy.Value) ? userLookup[t.UpdatedBy.Value] : string.Empty,
                        UpdatedTime = t.UpdatedTime,
                        Items = detailLookup.ContainsKey(t.ID) ? detailLookup[t.ID].Select(d => d.ItemName).ToList() : new List<string>()
                    }).ToList();

                    var jsonData = new { draw = draw, recordsFiltered = filteredCount, recordsTotal = totalCount, data = templatelist };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Medicine Template list", ex);
            }
        }
     
        [WebMethod]
        public static bool DeleteRecord(string itemID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                try
                {
                    int id = int.Parse(itemID);
                    var item = db.Pharmacy_Template_Masters.SingleOrDefault(i => i.ID == id);

                    if (item == null)
                    {
                        return false;
                    }

                    item.IsCancel = true;
                    item.CancelledBy = AppConfig.UserID;
                    item.CancelTime = DateTime.Now;
                    db.SubmitChanges();
                    return true;
                }
                catch (Exception)
                {
                    return false;
                }
            }
        }
    }

 
}
