using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;

namespace PMS.Modules.Dashboards
{
    public partial class PR_PO_IGP_Dashboard : System.Web.UI.Page
    {
        private const string MenuUrl = "~/Modules/Dashboards/PR_PO_IGP_Dashboard.aspx";

        protected void Page_Load(object sender, EventArgs e)
        {
        }

        private static bool HasAccess()
        {
            HttpContext context = HttpContext.Current;
            if (context == null || context.Session == null || context.Session["UserName"] == null)
                return false;

            string userName = context.Session["UserName"].ToString().Trim();
            if (string.IsNullOrEmpty(userName))
                return false;

            string[] roles = System.Web.Security.Roles.GetRolesForUser(userName);
            if (roles == null || roles.Length == 0)
                return false;

            var rolesUpper = roles.Select(r => r.ToUpper()).ToArray();

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var menuIds = db.Menus
                                .Where(m => m.URL == MenuUrl && m.IsActive == true)
                                .Select(m => m.Menu_ID)
                                .ToList();

                if (menuIds.Count == 0)
                    return false;

                return (from rm in db.aspnet_RolesInMenus
                        join r in db.aspnet_Roles on rm.RoleId equals r.RoleId
                        where rm.Menu_Id != null
                           && menuIds.Contains(rm.Menu_Id.Value)
                           && rm.Access == true
                           && rolesUpper.Contains(r.RoleName.ToUpper())
                        select rm.RoleMenuId).Any();
            }
        }

        [WebMethod]
        public static string GetPipeline(string sdate, string edate)
        {
            if (!HasAccess())
                return "{\"Denied\":true,\"Summary\":null,\"Rows\":[]}";

            return BuildPipeline(sdate, edate);
        }

        private class PrLine
        {
            public long PR_Detail_ID { get; set; }
            public int? PR_Id { get; set; }
            public int? PR_Num { get; set; }
            public DateTime? PR_Date { get; set; }
            public string Status { get; set; }
            public long? Item_ID { get; set; }
            public decimal Qty { get; set; }
        }

        private class PoLine
        {
            public int? PRDetailId { get; set; }
            public int PO_Item_ID { get; set; }
            public int? PO_ID { get; set; }
            public int? PO_No { get; set; }
            public string Status { get; set; }
            public decimal Qty { get; set; }
        }

        private class IgpLine
        {
            public int? PO_Item_ID { get; set; }
            public long? Igp_Id { get; set; }
            public int? Igp_num { get; set; }
            public DateTime? Igp_date { get; set; }
            public decimal IgpQty { get; set; }
        }

        private class ItemInfo
        {
            public int Item_ID { get; set; }
            public string Item_Code { get; set; }
            public string Description { get; set; }
        }

        private static string BuildPipeline(string sdate, string edate)
        {
            DateTime start, end;
            bool hasStart = DateTime.TryParse(sdate, CultureInfo.InvariantCulture, DateTimeStyles.None, out start);
            bool hasEnd = DateTime.TryParse(edate, CultureInfo.InvariantCulture, DateTimeStyles.None, out end);

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var prLines = (from d in db.Purchase_Requisition_Details
                               join h in db.Purchase_Requisitions on d.PR_ID equals (long?)h.PR_Id
                               where h.IsDeleted != true && h.Status != "Cancelled"
                               select new PrLine
                               {
                                   PR_Detail_ID = d.PR_Detail_ID,
                                   PR_Id = h.PR_Id,
                                   PR_Num = h.PR_Num,
                                   PR_Date = h.PR_Date,
                                   Status = h.Status,
                                   Item_ID = d.Item_ID,
                                   Qty = d.Qty ?? 0
                               }).ToList();

                var poLines = (from i in db.AP_Purchase_Order_Items
                               join o in db.AP_Purchase_Orders on i.PO_ID equals o.PO_ID
                               where o.IsDeleted != true && o.Status != "Cancelled"
                               select new PoLine
                               {
                                   PRDetailId = i.PRDetailId,
                                   PO_Item_ID = i.PO_Item_ID,
                                   PO_ID = i.PO_ID,
                                   PO_No = o.PO_No,
                                   Status = o.Status,
                                   Qty = i.Qty ?? 0
                               }).ToList();

                var igpLines = (from d in db.Igp_Details
                                join m in db.Igp_masters on d.Igp_Id equals m.Igp_Id
                                where m.IsDeleted != true && m.Status != "Cancelled"
                                select new IgpLine
                                {
                                    PO_Item_ID = d.PO_Item_ID,
                                    Igp_Id = m.Igp_Id,
                                    Igp_num = m.Igp_num,
                                    Igp_date = m.Igp_date,
                                    IgpQty = d.IGPQty ?? 0
                                }).ToList();

                var itemMap = db.INV_Items
                                .Select(i => new ItemInfo
                                {
                                    Item_ID = i.Item_ID,
                                    Item_Code = i.Item_Code,
                                    Description = i.Description
                                })
                                .ToList()
                                .GroupBy(x => x.Item_ID)
                                .ToDictionary(g => g.Key, g => g.First());

                var poByPr = poLines
                                .Where(x => x.PRDetailId.HasValue && x.PRDetailId.Value != 0)
                                .GroupBy(x => (long)x.PRDetailId.Value)
                                .ToDictionary(g => g.Key, g => g.ToList());

                var igpByPoItem = igpLines
                                .Where(x => x.PO_Item_ID.HasValue && x.PO_Item_ID.Value != 0)
                                .GroupBy(x => x.PO_Item_ID.Value)
                                .ToDictionary(g => g.Key, g => g.ToList());

                var linkedPoIds = new HashSet<int>(poLines
                                .Where(x => x.PRDetailId.HasValue && x.PRDetailId.Value != 0 && x.PO_ID.HasValue)
                                .Select(x => x.PO_ID.Value));

                var poHeads = db.AP_Purchase_Orders
                                .Where(o => o.IsDeleted != true && o.Status != "Cancelled")
                                .Select(o => o.PO_ID)
                                .ToList();

                int directPOs = poHeads.Count(pid => !linkedPoIds.Contains(pid));

                var rows = new List<object>();
                var prIdSet = new HashSet<int>();
                var poIdSet = new HashSet<int>();
                var igpIdSet = new HashSet<long>();

                int pendingApproval = 0, pendingPO = 0, pendingIGP = 0, partial = 0, completed = 0;

                foreach (var r in prLines)
                {
                    if (hasStart && (!r.PR_Date.HasValue || r.PR_Date.Value.Date < start.Date)) continue;
                    if (hasEnd && (!r.PR_Date.HasValue || r.PR_Date.Value.Date > end.Date)) continue;

                    var linked = poByPr.ContainsKey(r.PR_Detail_ID) ? poByPr[r.PR_Detail_ID] : null;

                    decimal poQty = 0, recvQty = 0;
                    var poNos = new List<int>();
                    var poStatuses = new List<string>();
                    var igpNos = new List<int>();
                    DateTime? lastIgpDate = null;

                    if (linked != null)
                    {
                        foreach (var p in linked)
                        {
                            poQty += p.Qty;
                            if (p.PO_No.HasValue) poNos.Add(p.PO_No.Value);
                            if (!string.IsNullOrEmpty(p.Status)) poStatuses.Add(p.Status);
                            if (p.PO_ID.HasValue) poIdSet.Add(p.PO_ID.Value);

                            List<IgpLine> igs;
                            if (igpByPoItem.TryGetValue(p.PO_Item_ID, out igs))
                            {
                                foreach (var g in igs)
                                {
                                    recvQty += g.IgpQty;
                                    if (g.Igp_num.HasValue) igpNos.Add(g.Igp_num.Value);
                                    if (g.Igp_Id.HasValue) igpIdSet.Add(g.Igp_Id.Value);
                                    if (g.Igp_date.HasValue && (lastIgpDate == null || g.Igp_date.Value > lastIgpDate.Value))
                                        lastIgpDate = g.Igp_date;
                                }
                            }
                        }
                    }

                    if (r.PR_Id.HasValue) prIdSet.Add(r.PR_Id.Value);

                    ItemInfo item = null;
                    if (r.Item_ID.HasValue && r.Item_ID.Value > 0 && r.Item_ID.Value <= int.MaxValue)
                        itemMap.TryGetValue((int)r.Item_ID.Value, out item);

                    string stage;
                    if (r.Status == "Created" || r.Status == "Pending")
                    {
                        stage = "Pending Approval";
                        pendingApproval++;
                    }
                    else if (linked == null || linked.Count == 0)
                    {
                        stage = "Pending PO";
                        pendingPO++;
                    }
                    else if (recvQty <= 0)
                    {
                        stage = "Pending IGP";
                        pendingIGP++;
                    }
                    else if (recvQty < poQty)
                    {
                        stage = "Partially Received";
                        partial++;
                    }
                    else
                    {
                        stage = "Completed";
                        completed++;
                    }

                    rows.Add(new
                    {
                        PR_No = r.PR_Num.HasValue ? r.PR_Num.Value.ToString() : "",
                        PR_Date = r.PR_Date.HasValue ? r.PR_Date.Value.ToString("dd-MMM-yyyy") : "",
                        PR_DateISO = r.PR_Date.HasValue ? r.PR_Date.Value.ToString("yyyy-MM-dd") : "",
                        PRStatus = r.Status ?? "",
                        Item_Code = item != null ? (item.Item_Code ?? "") : "",
                        Item_Desc = item != null ? (item.Description ?? "") : "",
                        Qty = r.Qty.ToString("0.####"),
                        PO_Nos = string.Join(", ", poNos.Distinct().OrderBy(x => x)),
                        PO_Status = string.Join("/", poStatuses.Distinct()),
                        IGP_Nos = string.Join(", ", igpNos.Distinct().OrderBy(x => x)),
                        IGP_Date = lastIgpDate.HasValue ? lastIgpDate.Value.ToString("dd-MMM-yyyy") : "",
                        Recv_Qty = recvQty.ToString("0.####"),
                        Stage = stage
                    });
                }

                var payload = new
                {
                    Summary = new
                    {
                        TotalItems = rows.Count,
                        PendingApproval = pendingApproval,
                        PendingPO = pendingPO,
                        PendingIGP = pendingIGP,
                        Partial = partial,
                        Completed = completed,
                        TotalPRs = prIdSet.Count,
                        TotalPOs = poIdSet.Count,
                        TotalIGPs = igpIdSet.Count,
                        DirectPOs = directPOs
                    },
                    Rows = rows
                };

                return (new JavaScriptSerializer()).Serialize(payload);
            }
        }
    }
}
