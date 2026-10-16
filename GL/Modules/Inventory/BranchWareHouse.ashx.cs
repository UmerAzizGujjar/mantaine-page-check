using System;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.SessionState;

namespace PMS.Modules.Inventory
{
    /// <summary>
    /// Feeds wwwroot/lib/theme/branch-warehouse.js.
    /// sys_Parms "Branch Wise Ware House": Code = "01" -> warehouse dropdowns list only the
    /// warehouses mapped to the selected branch (Branch_Wise_WareHouse); anything else -> old behaviour.
    /// GET ?branchId=N  ->  { enabled: bool, items: [{ value, text }] }
    /// </summary>
    public class BranchWareHouse : IHttpHandler, IReadOnlySessionState
    {
        public const string ParamName = "Branch Wise Ware House";

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json";
            context.Response.Cache.SetCacheability(HttpCacheability.NoCache);

            if (context.Session == null || context.Session["Company_ID"] == null)
            {
                context.Response.StatusCode = 401;
                return;
            }

            int branchId;
            int.TryParse(context.Request.QueryString["branchId"], out branchId);

            using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                int companyId = AppConfig.Company_ID;
                bool enabled = db.sys_Parms.Any(p => p.Name == ParamName && p.Code == "01" && p.Company_ID == companyId);

                object items = new object[0];
                if (enabled && branchId > 0)
                {
                    items = (from bw in db.Branch_Wise_WareHouses
                             join p in db.DataValues on bw.WareHouse equals p.DataValue_Name
                             join v in db.ValueSets on p.ValueSet_ID equals v.ValueSet_ID
                             where bw.Branch_ID == branchId && bw.Company_ID == companyId && v.ValueSet_Description == "Ware House"
                             orderby p.DataValue_Description
                             select new { value = p.DataValue_Name, text = p.DataValue_Description }).ToList();
                }

                context.Response.Write(new JavaScriptSerializer().Serialize(new { enabled, items }));
            }
        }

        public bool IsReusable
        {
            get { return false; }
        }
    }
}
