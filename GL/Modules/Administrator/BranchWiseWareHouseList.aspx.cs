using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Services;

namespace PMS.Modules.Administrator
{
    public partial class BranchWiseWareHouseList : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        public class BranchRow
        {
            public int Branch_ID { get; set; }
            public string Branch_Name { get; set; }
            public string WareHouses { get; set; }
            public int WareHouse_Count { get; set; }
            public DateTime? Created_Time { get; set; }
        }

        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                int companyId = AppConfig.Company_ID;
                searchValue = (searchValue ?? "").Trim();

                var wareHouseNames = (from p in db.DataValues
                                      join v in db.ValueSets on p.ValueSet_ID equals v.ValueSet_ID
                                      where v.ValueSet_Description == "Ware House" && p.DataValue_Name != null
                                      select new { p.DataValue_Name, p.DataValue_Description })
                                     .ToList()
                                     .GroupBy(x => x.DataValue_Name)
                                     .ToDictionary(g => g.Key, g => g.First().DataValue_Description);

                // One row per branch; table is small (branches x ware houses), so group in memory
                var rows = (from bw in db.Branch_Wise_WareHouses
                            join br in db.Branches on bw.Branch_ID equals br.branch_ID
                            where bw.Company_ID == companyId
                            select new { bw.Branch_ID, br.branch_Name, bw.WareHouse, bw.Created_Time })
                           .ToList()
                           .GroupBy(x => new { x.Branch_ID, x.branch_Name })
                           .Select(g => new BranchRow
                           {
                               Branch_ID = g.Key.Branch_ID,
                               Branch_Name = g.Key.branch_Name,
                               WareHouses = string.Join(", ", g.Select(x => wareHouseNames.ContainsKey(x.WareHouse) ? wareHouseNames[x.WareHouse] : x.WareHouse)),
                               WareHouse_Count = g.Count(),
                               Created_Time = g.Min(x => x.Created_Time)
                           })
                           .ToList();

                int totalRecords = rows.Count;

                IEnumerable<BranchRow> query = rows;
                if (searchValue != "")
                {
                    query = rows.Where(x => (x.Branch_Name ?? "").IndexOf(searchValue, StringComparison.OrdinalIgnoreCase) >= 0 ||
                                            x.WareHouses.IndexOf(searchValue, StringComparison.OrdinalIgnoreCase) >= 0);
                }

                bool asc = sortColumnDirection == "asc";
                switch (sortColumn)
                {
                    case "WareHouse_Count":
                        query = asc ? query.OrderBy(x => x.WareHouse_Count) : query.OrderByDescending(x => x.WareHouse_Count);
                        break;
                    case "Created_Time":
                        query = asc ? query.OrderBy(x => x.Created_Time) : query.OrderByDescending(x => x.Created_Time);
                        break;
                    default:
                        query = asc ? query.OrderBy(x => x.Branch_Name) : query.OrderByDescending(x => x.Branch_Name);
                        break;
                }

                var filtered = query.ToList();
                var data = filtered.Skip(start).Take(length > 0 ? length : filtered.Count).ToList();

                return new
                {
                    draw,
                    recordsTotal = totalRecords,
                    recordsFiltered = filtered.Count,
                    data
                };
            }
        }

        [WebMethod]
        public static bool DeleteRecord(int Id)
        {
            try
            {
                using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    var rows = db.Branch_Wise_WareHouses.Where(x => x.Branch_ID == Id && x.Company_ID == AppConfig.Company_ID);
                    db.Branch_Wise_WareHouses.DeleteAllOnSubmit(rows);
                    db.SubmitChanges();
                    return true;
                }
            }
            catch (Exception)
            {
                return false;
            }
        }
    }
}
