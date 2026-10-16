using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Script.Serialization;
using System.Web.Services;

namespace PMS.Modules.Administrator
{
    public partial class BranchWiseWareHouse : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        [WebMethod]
        public static string fillBranch()
        {
            using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                var branches = db.Branches
                    .OrderBy(b => b.branch_Name)
                    .Select(b => new { Branch_ID = b.branch_ID, Branch_Name = b.branch_Name })
                    .ToList();
                return new JavaScriptSerializer().Serialize(branches);
            }
        }

        [WebMethod]
        public static string fillWareHouse()
        {
            using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                var wareHouses = (from p in db.DataValues
                                  join v in db.ValueSets on p.ValueSet_ID equals v.ValueSet_ID
                                  where v.ValueSet_Description == "Ware House"
                                  orderby p.DataValue_Description
                                  select new { WareHouse = p.DataValue_Name, WareHouse_Name = p.DataValue_Description }).ToList();
                return new JavaScriptSerializer().Serialize(wareHouses);
            }
        }

        [WebMethod]
        public static string LoadDetail(int branchId)
        {
            using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                var wareHouseNames = WareHouseNames(db);
                var branchName = db.Branches.Where(b => b.branch_ID == branchId).Select(b => b.branch_Name).FirstOrDefault();

                var rows = db.Branch_Wise_WareHouses
                    .Where(x => x.Branch_ID == branchId && x.Company_ID == AppConfig.Company_ID)
                    .OrderBy(x => x.Branch_WareHouse_Id)
                    .Select(x => x.WareHouse)
                    .ToList()
                    .Select(w => new
                    {
                        Branch_Name = branchName,
                        WareHouse = w,
                        WareHouse_Name = wareHouseNames.ContainsKey(w) ? wareHouseNames[w] : w
                    });

                return new JavaScriptSerializer().Serialize(rows);
            }
        }

        [WebMethod]
        public static string SaveRecord(int branchId, bool isEdit, List<string> wareHouses)
        {
            try
            {
                wareHouses = (wareHouses ?? new List<string>()).Where(w => !string.IsNullOrWhiteSpace(w)).Distinct().ToList();
                if (branchId <= 0) return "Please Select Branch";
                if (wareHouses.Count == 0) return "Please Add Ware House";

                using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    int companyId = AppConfig.Company_ID;
                    var existing = db.Branch_Wise_WareHouses
                        .Where(x => x.Branch_ID == branchId && x.Company_ID == companyId)
                        .ToList();

                    if (!isEdit && existing.Any())
                        return "Ware houses are already defined for this branch. Use Edit from the list.";

                    // A ware house can belong to one branch only
                    var takenElsewhere = db.Branch_Wise_WareHouses
                        .Where(x => x.Branch_ID != branchId && x.Company_ID == companyId && wareHouses.Contains(x.WareHouse))
                        .Select(x => x.WareHouse)
                        .ToList();
                    if (takenElsewhere.Any())
                    {
                        var names = WareHouseNames(db);
                        return "Already assigned to another branch: " +
                               string.Join(", ", takenElsewhere.Select(w => names.ContainsKey(w) ? names[w] : w));
                    }

                    db.Branch_Wise_WareHouses.DeleteAllOnSubmit(existing.Where(x => !wareHouses.Contains(x.WareHouse)));

                    foreach (var wareHouse in wareHouses.Where(w => !existing.Any(x => x.WareHouse == w)))
                    {
                        db.Branch_Wise_WareHouses.InsertOnSubmit(new Branch_Wise_WareHouse
                        {
                            Branch_ID = branchId,
                            WareHouse = wareHouse,
                            Company_ID = companyId,
                            Book_ID = AppConfig.Book_ID,
                            Created_By = AppConfig.UserID,
                            Created_Time = DateTime.Now
                        });
                    }

                    foreach (var kept in existing.Where(x => wareHouses.Contains(x.WareHouse)))
                    {
                        kept.Updated_By = AppConfig.UserID;
                        kept.Updated_Time = DateTime.Now;
                    }

                    db.SubmitChanges();
                    return "OK";
                }
            }
            catch (Exception ex)
            {
                return "Error while saving: " + ex.Message;
            }
        }

        private static Dictionary<string, string> WareHouseNames(DataBaseDataContext db)
        {
            return (from p in db.DataValues
                    join v in db.ValueSets on p.ValueSet_ID equals v.ValueSet_ID
                    where v.ValueSet_Description == "Ware House" && p.DataValue_Name != null
                    select new { p.DataValue_Name, p.DataValue_Description })
                   .ToList()
                   .GroupBy(x => x.DataValue_Name)
                   .ToDictionary(g => g.Key, g => g.First().DataValue_Description);
        }
    }
}
