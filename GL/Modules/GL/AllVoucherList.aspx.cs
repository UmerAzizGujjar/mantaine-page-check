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
                System.Data.DataTable dt = DBClass.getDataTable("EXEC dbo.spGL_AllVoucherList @CompanyID,@Start,@Length,@SortColumn,@SortDir,@Search,@VoucherType,@VoucherName",
                    DBClass.Param("@CompanyID", AppConfig.Company_ID),
                    DBClass.Param("@Start", start < 0 ? 0 : start),
                    DBClass.Param("@Length", length <= 0 ? int.MaxValue : length),
                    DBClass.Param("@SortColumn", sortColumn ?? ""),
                    DBClass.Param("@SortDir", sortColumnDirection ?? "desc"),
                    DBClass.Param("@Search", (searchValue ?? "").Trim()),
                    DBClass.Param("@VoucherType", voucherTypeFilter ?? ""),
                    DBClass.Param("@VoucherName", voucherNameFilter ?? ""));

                int total = 0, filtered = 0;
                var data = new System.Collections.Generic.List<object>();
                foreach (System.Data.DataRow r in dt.Rows)
                {
                    total = Convert.ToInt32(r["RecordsTotal"]);
                    filtered = Convert.ToInt32(r["RecordsFiltered"]);
                    data.Add(new
                    {
                        Voucher_ID = Convert.ToInt64(r["Voucher_ID"]),
                        Voucher_No = Convert.ToInt32(r["Voucher_No"]),
                        Voucher_Type = r["Voucher_Type"] as string,
                        Narration = r["Narration"] as string,
                        Voucher_Name = r["Voucher_Name"] as string,
                        TotalDR = Convert.ToDecimal(r["TotalDR"]),
                        TotalCR = Convert.ToDecimal(r["TotalCR"])
                    });
                }
                return new { draw, recordsTotal = total, recordsFiltered = filtered, data };
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching voucher list: " + ex.Message, ex);
            }
        }

        // Status, GL lines and linked bills of one voucher, for the View popup (shared helper).
        [WebMethod]
        public static string GetVoucherDetail(string voucherId)
        {
            return VoucherDetail.GetJson(voucherId);
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
