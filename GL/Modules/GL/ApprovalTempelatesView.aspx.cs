using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.GL
{
    public partial class ApprovalTempelatesView : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }
        [WebMethod]
        public static string LoadApprovalData()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

            var query = (from dataa in db.Sys_Approval_Tempelate_Masters
                         where dataa.IsDeleted == false
                         orderby dataa.Tempelate_ID descending
                         select new
                         {
                             TempelateID = dataa.Tempelate_ID,
                             TempelateName = dataa.Tempelate_Name,
                             TempelateDescription = dataa.Tempelate_Description,
                             Company_ID = dataa.Company_ID,
                         }).ToList();

            var result = query.Select(item => new
            {
                TempelateID = item.TempelateID,
                TempelateName = item.TempelateName,
                TempelateDescription = item.TempelateDescription,
                CompanyName = item.Company_ID != null ? GetCompanyName(item.Company_ID) : "N/A",
            }).ToList();

            return (new JavaScriptSerializer()).Serialize(result);
        }
        public static string GetCompanyName(int? companyId)
        {
            if (companyId == null)
                return "N/A";

            return DBClass.getField("Select Company_Name from sys_Companys where Company_ID =" + companyId);
        }
        [WebMethod]
        public static string Delete(string id)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            try
            {
                var userid = AppConfig.UserID;
                DBClass.executeNonQueryWithoutBegin("Update Sys_Approval_Tempelate_Master set IsDeleted=1,Deleted_Date=GetDate(),Deleted_By='" + userid + "' where Tempelate_ID=" + id);
                return "success";
            }
            catch (Exception ex)
            {
                return "Error";
            }
        }
    }
}