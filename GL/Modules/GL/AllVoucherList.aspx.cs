using System;
using System.Linq;
using System.Web.Script.Serialization;
using System.Web.Services;

namespace PMS.Modules.GL
{
    public partial class AllVoucherList : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e) { }

        [WebMethod]
        public static object AllVoucherListData(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue, string voucherTypeFilter, string voucherNameFilter)
        {
            try
            {
                using (var db = new DataBaseDataContext())
                {
                    int total = db.GL_Vouchers.Count();
                    string s = searchValue ?? "";
                    string vt = voucherTypeFilter ?? "";
                    string vn = voucherNameFilter ?? "";

                    var agg = from ac in db.GL_Voucher_Accounts
                              where ac.Voucher_ID != null
                              group ac by ac.Voucher_ID into g
                              select new
                              {
                                  Voucher_ID = g.Key,
                                  Narration = g.Where(x => x.Narration != null)
                                               .OrderBy(x => x.Serial_No)
                                               .Select(x => x.Narration).FirstOrDefault(),
                                  TotalDR = g.Sum(x => (decimal?)x.DR) ?? 0,
                                  TotalCR = g.Sum(x => (decimal?)x.CR) ?? 0
                              };

                    var q = from v in db.GL_Vouchers
                            join t in db.GL_Voucher_Types on v.Voucher_Type equals t.Voucher_Type
                            join a in agg on v.Voucher_ID equals a.Voucher_ID into ag
                            from a in ag.DefaultIfEmpty()
                            where v.Voucher_No.ToString().Contains(s)
                               || (v.Voucher_Type != null && v.Voucher_Type.Contains(s))
                               || (t.Voucher_Name != null && t.Voucher_Name.Contains(s))
                               || (a != null && a.Narration != null && a.Narration.Contains(s))
                            select new
                            {
                                v.Voucher_ID,
                                v.Voucher_No,
                                v.Voucher_Type,
                                
                                Narration = a != null ? a.Narration : null,
                                t.Voucher_Name,
                                TotalDR = a != null ? a.TotalDR : 0,
                                TotalCR = a != null ? a.TotalCR : 0
                            };

                    if (vt.Length > 0) q = q.Where(x => x.Voucher_Type == vt);
                    if (vn.Length > 0) q = q.Where(x => x.Voucher_Name == vn);

                    var qForCount = from v in db.GL_Vouchers
                                    join t in db.GL_Voucher_Types on v.Voucher_Type equals t.Voucher_Type
                                    select new { v.Voucher_ID, v.Voucher_Type, t.Voucher_Name };
                    if (s.Length > 0) qForCount = qForCount.Where(x => x.Voucher_Type != null && x.Voucher_Type.Contains(s) || x.Voucher_Name != null && x.Voucher_Name.Contains(s));
                    if (vt.Length > 0) qForCount = qForCount.Where(x => x.Voucher_Type == vt);
                    if (vn.Length > 0) qForCount = qForCount.Where(x => x.Voucher_Name == vn);
                    int filtered = qForCount.Count();

                    switch (sortColumn)
                    {
                        case "Voucher_No": q = sortColumnDirection == "asc" ? q.OrderBy(x => x.Voucher_No) : q.OrderByDescending(x => x.Voucher_No); break;
                        case "Voucher_Type": q = sortColumnDirection == "asc" ? q.OrderBy(x => x.Voucher_Type) : q.OrderByDescending(x => x.Voucher_Type); break;
                        case "Voucher_Name": q = sortColumnDirection == "asc" ? q.OrderBy(x => x.Voucher_Name) : q.OrderByDescending(x => x.Voucher_Name); break;
                        case "TotalDR": q = sortColumnDirection == "asc" ? q.OrderBy(x => x.TotalDR) : q.OrderByDescending(x => x.TotalDR); break;
                        case "TotalCR": q = sortColumnDirection == "asc" ? q.OrderBy(x => x.TotalCR) : q.OrderByDescending(x => x.TotalCR); break;
                        default: q = q.OrderByDescending(x => x.Voucher_ID); break;
                    }

                    var data = q.Skip(start).Take(length).ToList();
                    return new { draw, recordsTotal = total, recordsFiltered = filtered, data };
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching voucher list: " + ex.Message, ex);
            }
        }

        [WebMethod]
        public static object GetVoucherTypes()
        {
            using (var db = new DataBaseDataContext())
            {
                return db.GL_Voucher_Types
                          .Select(x => new { x.Voucher_Type, x.Voucher_Name })
                          .OrderBy(x => x.Voucher_Name)
                          .ToList();
            }
        }
    }
}
