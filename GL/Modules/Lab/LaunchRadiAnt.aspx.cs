using System;
using System.Web;

namespace PMS.Modules.Lab
{
    public partial class LaunchRadiAnt : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            string uid = Request.QueryString["uid"];
            if (string.IsNullOrWhiteSpace(uid))
            {
                Response.Status = "400 Bad Request";
                Response.End();
                return;
            }

            string encodedUid = HttpUtility.UrlEncode(uid);
            string radiantUrl = "radiant://?n=paet&v=VISIONPLUS&n=pstv&v=0020000D&v=%22"
                                + encodedUid + "%22";

            Response.Clear();
            Response.Status = "302 Found";
            Response.AddHeader("Location", radiantUrl);
            Response.End();
        }
    }
}
