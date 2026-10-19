using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;

namespace PMS.Modules.Dashboards
{
    public partial class PR_To_IGP_Dashboard : System.Web.UI.Page
    {
        private const string MenuUrl = "~/Modules/Dashboards/PR_To_IGP_Dashboard.aspx";

        protected void Page_Load(object sender, EventArgs e)
        {
        }

        // Same menu/role gate used by PR_PO_IGP_Dashboard.
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

        private static string Json(object o)
        {
            return new JavaScriptSerializer { MaxJsonLength = int.MaxValue }.Serialize(o);
        }

        private const string Denied = "{\"Denied\":true}";

        // ---------------------------------------------------------------- lookups

        [WebMethod]
        public static string GetLookups()
        {
            if (!HasAccess()) return Denied;

            DataTable dept = DBClass.getDataTable(
                "SELECT v.DataValue_Name AS Id, v.Datavalue_description AS Name FROM datavalues v " +
                "JOIN valueset s ON s.ValueSet_ID = v.valueset_id WHERE s.valueset_name = 'Department' " +
                "AND (v.System_Value = 0 OR v.System_Value IS NULL) ORDER BY v.Datavalue_description");
            DataTable wh = DBClass.getDataTable(
                "SELECT v.DataValue_Name AS Id, v.Datavalue_description AS Name FROM datavalues v " +
                "JOIN valueset s ON s.ValueSet_ID = v.valueset_id WHERE s.valueset_name = 'Ware House' " +
                "AND (v.System_Value = 0 OR v.System_Value IS NULL) ORDER BY v.Datavalue_description");
            DataTable ven = DBClass.getDataTable(
                "SELECT Vendor_ID AS Id, Vendor_Name AS Name FROM AP_Vendors WHERE ISNULL(IsActive, 1) = 1 ORDER BY Vendor_Name");

            return Json(new { Departments = ToList(dept), Warehouses = ToList(wh), Vendors = ToList(ven) });
        }

        [WebMethod]
        public static string SearchItems(string term)
        {
            if (!HasAccess()) return Denied;
            term = (term ?? "").Trim();
            if (term.Length < 2) return Json(new object[0]);

            DataTable dt = DBClass.getDataTable(
                "SELECT TOP 30 Item_ID AS Id, Item_Code AS Code, Description AS Name FROM INV_Items " +
                "WHERE Item_Code LIKE @t OR Description LIKE @t ORDER BY Description",
                DBClass.Param("@t", "%" + term + "%"));
            return Json(ToList(dt));
        }

        private static List<Dictionary<string, object>> ToList(DataTable dt)
        {
            var list = new List<Dictionary<string, object>>();
            foreach (DataRow r in dt.Rows)
            {
                var d = new Dictionary<string, object>();
                foreach (DataColumn c in dt.Columns)
                    d[c.ColumnName] = r[c] == DBNull.Value ? "" : r[c];
                list.Add(d);
            }
            return list;
        }

        // -------------------------------------------------------------- dashboard

        private class Line
        {
            public long PrId, DetailId;
            public int PrNo;
            public DateTime? PrDate;
            public string Dept, Wh, PrStatus, ItemCode, ItemName, Proc, PoState, IgpState;
            public decimal Req, Appr, Ord, Rcv, Grn, RemOrder, RemReceive;
            public List<string[]> PoDocs, IgpDocs;   // [id, no, state(A/D)]
        }

        private static decimal Dec(DataRow r, string c)
        {
            return r[c] == DBNull.Value ? 0m : Convert.ToDecimal(r[c]);
        }

        private static string Str(DataRow r, string c)
        {
            return r[c] == DBNull.Value ? "" : Convert.ToString(r[c]);
        }

        private static List<string[]> Docs(string s)
        {
            var list = new List<string[]>();
            if (string.IsNullOrEmpty(s)) return list;
            foreach (string part in s.Split(','))
            {
                string[] p = part.Split(':');
                if (p.Length >= 3) list.Add(p);
            }
            return list;
        }

        private static DateTime? ParseDate(string s)
        {
            DateTime d;
            if (DateTime.TryParse(s, CultureInfo.InvariantCulture, DateTimeStyles.None, out d)) return d;
            return null;
        }

        private static int ToInt(string s)
        {
            int v;
            return int.TryParse(s, out v) ? v : 0;
        }

        [WebMethod]
        public static string GetDashboard(string sdate, string edate, string prNo, string dept, string warehouse,
                                          string itemId, string vendorId, string prStatus, string poStatus, string igpStatus,
                                          string procStatus, bool pendingOnly)
        {
            if (!HasAccess()) return Denied;

            DataSet ds = new DataSet();
            using (SqlConnection con = new SqlConnection(DBClass.ConnectionString()))
            using (SqlCommand cmd = new SqlCommand("dbo.spProc_PR_To_IGP_Items", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandTimeout = 120;
                cmd.Parameters.Add(DBClass.Param("@FromDate", ParseDate(sdate)));
                cmd.Parameters.Add(DBClass.Param("@ToDate", ParseDate(edate)));
                cmd.Parameters.Add(DBClass.Param("@PRNo", ToInt(prNo)));
                cmd.Parameters.Add(DBClass.Param("@Department", string.IsNullOrEmpty(dept) ? null : dept));
                cmd.Parameters.Add(DBClass.Param("@Warehouse", string.IsNullOrEmpty(warehouse) ? null : warehouse));
                cmd.Parameters.Add(DBClass.Param("@ItemId", (long)ToInt(itemId)));
                cmd.Parameters.Add(DBClass.Param("@VendorId", ToInt(vendorId)));
                cmd.Parameters.Add(DBClass.Param("@PRStatus", string.IsNullOrEmpty(prStatus) ? null : prStatus));
                cmd.Parameters.Add(DBClass.Param("@POStatus", string.IsNullOrEmpty(poStatus) ? null : poStatus));
                cmd.Parameters.Add(DBClass.Param("@IGPStatus", string.IsNullOrEmpty(igpStatus) ? null : igpStatus));
                cmd.Parameters.Add(DBClass.Param("@UserId", AppConfig.UserID));
                cmd.Parameters.Add(DBClass.Param("@ProcStatus", string.IsNullOrEmpty(procStatus) ? null : procStatus));
                cmd.Parameters.Add(DBClass.Param("@PendingOnly", pendingOnly));
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    da.Fill(ds);
            }

            var lines = new List<Line>();
            foreach (DataRow r in ds.Tables[0].Rows)
            {
                lines.Add(new Line
                {
                    PrId = Convert.ToInt64(r["PR_Id"]),
                    DetailId = Convert.ToInt64(r["PR_Detail_ID"]),
                    PrNo = r["PR_Num"] == DBNull.Value ? 0 : Convert.ToInt32(r["PR_Num"]),
                    PrDate = r["PR_Date"] == DBNull.Value ? (DateTime?)null : Convert.ToDateTime(r["PR_Date"]),
                    Dept = Str(r, "DepartmentName"),
                    Wh = Str(r, "WarehouseName"),
                    PrStatus = Str(r, "PRStatus"),
                    ItemCode = Str(r, "Item_Code"),
                    ItemName = Str(r, "Item_Name"),
                    Proc = Str(r, "ProcStatus"),
                    PoState = Str(r, "POStatus"),
                    IgpState = Str(r, "IGPStatus"),
                    Req = Dec(r, "ReqQty"),
                    Appr = Dec(r, "ApprQty"),
                    Ord = Dec(r, "OrdQty"),
                    Rcv = Dec(r, "RcvQty"),
                    Grn = Dec(r, "GrnQty"),
                    RemOrder = Dec(r, "RemOrder"),
                    RemReceive = Dec(r, "RemReceive"),
                    PoDocs = Docs(Str(r, "PODocs")),
                    IgpDocs = Docs(Str(r, "IGPDocs"))
                });
            }

            var live = lines.Where(l => l.PrStatus != "Cancelled").ToList();
            var approvedLines = live.Where(l => l.PrStatus == "Approved").ToList();

            // ---- PO level (one row per PO; PO lines are unique per PO item so no fan-out)
            var poLines = ds.Tables[1].Rows.Cast<DataRow>().Select(r => new
            {
                DetailId = Convert.ToInt64(r["PRDetailId"]),
                PoId = Convert.ToInt32(r["PO_ID"]),
                PoNo = r["PO_No"] == DBNull.Value ? 0 : Convert.ToInt32(r["PO_No"]),
                PoDate = r["PO_Date"] == DBNull.Value ? (DateTime?)null : Convert.ToDateTime(r["PO_Date"]),
                Vendor = Str(r, "Vendor_Name"),
                State = Str(r, "PoState"),
                Ord = Dec(r, "OrdQty"),
                Rcv = Dec(r, "RcvQty")
            }).ToList();

            var lineById = lines.ToDictionary(l => l.DetailId, l => l);
            var pos = poLines.GroupBy(p => p.PoId).Select(g =>
            {
                decimal ord = g.Sum(x => x.Ord), rcv = g.Sum(x => x.Rcv);
                bool draft = g.First().State == "Draft";
                string st = draft ? "Draft" : (rcv <= 0 ? "Pending IGP" : (rcv < ord ? "Partially Received" : "Completed"));
                var prNos = g.Select(x => lineById.ContainsKey(x.DetailId) ? lineById[x.DetailId] : null)
                             .Where(x => x != null).Select(x => new[] { x.PrId.ToString(), x.PrNo.ToString() })
                             .GroupBy(x => x[0]).Select(x => x.First()).ToList();
                return new
                {
                    PoId = g.Key,
                    PoNo = g.First().PoNo,
                    PoDate = g.First().PoDate.HasValue ? g.First().PoDate.Value.ToString("yyyy-MM-dd") : "",
                    Vendor = g.First().Vendor,
                    Status = st,
                    Items = g.Count(),
                    ItemsPending = draft ? 0 : g.Count(x => x.Ord > x.Rcv),
                    Ord = ord,
                    Rcv = rcv,
                    Remaining = draft ? 0m : Math.Max(ord - rcv, 0m),
                    PRs = prNos
                };
            }).OrderByDescending(p => p.PoNo).ToList();

            var approvedPos = pos.Where(p => p.Status != "Draft").ToList();
            var igpIds = new HashSet<string>(live.SelectMany(l => l.IgpDocs).Select(d => d[0]));
            var igpApproved = new HashSet<string>(live.SelectMany(l => l.IgpDocs).Where(d => d[2] == "A").Select(d => d[0]));

            Func<IEnumerable<Line>, int> prCount = e => e.Select(x => x.PrId).Distinct().Count();

            var summary = new
            {
                TotalPRs = lines.Select(l => l.PrId).Distinct().Count(),
                ApprovedPRs = prCount(approvedLines),
                PendingPRs = prCount(live.Where(l => l.PrStatus == "Pending")),
                CancelledPRs = prCount(lines.Where(l => l.PrStatus == "Cancelled")),
                PRsPendingPO = prCount(approvedLines.Where(l => l.RemOrder > 0 && l.Proc != "Cancelled/Closed")),
                PRItemsPendingPO = approvedLines.Count(l => l.RemOrder > 0 && l.Proc != "Cancelled/Closed"),
                TotalPOs = approvedPos.Count,
                DraftPOs = pos.Count(p => p.Status == "Draft"),
                POsPendingIGP = approvedPos.Count(p => p.Status != "Completed"),
                POItemsPendingIGP = approvedPos.Sum(p => p.ItemsPending),
                CompletedPOs = approvedPos.Count(p => p.Status == "Completed"),
                CompletedPOItems = live.Count(l => l.Proc == "Fully Received"),
                ItemsRequested = live.Sum(l => l.Req),
                ItemsOrdered = live.Sum(l => l.Ord),
                ItemsReceived = live.Sum(l => l.Rcv),
                ItemLines = live.Count
            };

            // ---- funnel (docs / distinct PR items / qty / conversion vs previous stage)
            var stages = new List<Dictionary<string, object>>();
            Action<string, int, int, decimal> addStage = (name, docs, items, qty) =>
            {
                var s = new Dictionary<string, object> { { "Stage", name }, { "Docs", docs }, { "Items", items }, { "Qty", qty } };
                if (stages.Count > 0)
                {
                    var p = stages[stages.Count - 1];
                    int pd = (int)p["Docs"], pi = (int)p["Items"];
                    s["DocPct"] = pd > 0 ? Math.Round(docs * 100.0 / pd, 1) : 0.0;
                    s["ItemPct"] = pi > 0 ? Math.Round(items * 100.0 / pi, 1) : 0.0;
                }
                stages.Add(s);
            };
            addStage("PR Created", prCount(live), live.Count, live.Sum(l => l.Req));
            addStage("PR Approved", prCount(approvedLines), approvedLines.Count, approvedLines.Sum(l => l.Appr));
            addStage("PO Created", approvedPos.Count, live.Count(l => l.Ord > 0), live.Sum(l => l.Ord));
            addStage("IGP Created", igpIds.Count, live.Count(l => l.IgpDocs.Count > 0), live.Sum(l => l.Rcv));
            addStage("Fully Received", approvedPos.Count(p => p.Status == "Completed"),
                     live.Count(l => l.Proc == "Fully Received"), live.Where(l => l.Proc == "Fully Received").Sum(l => l.Rcv));

            // ---- trend (by PR date)
            var dated = live.Where(l => l.PrDate.HasValue).ToList();
            string grain = "yyyy-MM";
            if (dated.Count > 0)
            {
                double span = (dated.Max(l => l.PrDate.Value) - dated.Min(l => l.PrDate.Value)).TotalDays;
                grain = span <= 62 ? "yyyy-MM-dd" : (span <= 800 ? "yyyy-MM" : "yyyy");
            }
            var trend = dated.GroupBy(l => l.PrDate.Value.ToString(grain)).OrderBy(g => g.Key)
                             .Select(g => new
                             {
                                 Period = g.Key,
                                 Created = g.Select(x => x.PrId).Distinct().Count(),
                                 Approved = g.Where(x => x.PrStatus == "Approved").Select(x => x.PrId).Distinct().Count()
                             }).ToList();

            // ---- pending by department
            var deptPending = live.GroupBy(l => string.IsNullOrEmpty(l.Dept) ? "(none)" : l.Dept)
                .Select(g => new
                {
                    Dept = g.Key,
                    PendingApproval = prCount(g.Where(x => x.PrStatus == "Pending")),
                    PendingPO = prCount(g.Where(x => x.PrStatus == "Approved" && x.RemOrder > 0 && x.Proc != "Cancelled/Closed"))
                })
                .Where(x => x.PendingApproval + x.PendingPO > 0)
                .OrderByDescending(x => x.PendingApproval + x.PendingPO).Take(15).ToList();

            decimal apprTotal = approvedLines.Sum(l => l.Appr);
            decimal received = approvedLines.Sum(l => Math.Min(l.Rcv, l.Appr));

            var statusCounts = live.Concat(lines.Where(l => l.PrStatus == "Cancelled")).GroupBy(l => l.Proc)
                                   .ToDictionary(g => g.Key, g => g.Count());

            var rows = lines.Select(l => new
            {
                l.PrId, l.DetailId, l.PrNo,
                PrDate = l.PrDate.HasValue ? l.PrDate.Value.ToString("yyyy-MM-dd") : "",
                l.PrStatus, l.Dept, l.Wh, l.ItemCode, l.ItemName,
                l.Req, l.Appr, l.Ord, l.Rcv, l.Grn, l.RemOrder, l.RemReceive,
                l.Proc, l.PoState, l.IgpState, l.PoDocs, l.IgpDocs
            }).ToList();

            return Json(new
            {
                Summary = summary,
                Funnel = stages,
                Trend = trend,
                TrendGrain = grain,
                DeptPending = deptPending,
                StatusCounts = statusCounts,
                Completion = apprTotal > 0 ? Math.Round(received * 100m / apprTotal, 1) : 0m,
                Rows = rows,
                POs = pos
            });
        }
    }
}
