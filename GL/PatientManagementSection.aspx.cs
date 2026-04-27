using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class PatientManagementSection : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        public class TillActionResult
        {
            public bool IsSuccess { get; set; }
            public bool IsActive { get; set; }
            public bool HideButton { get; set; }
            public bool IsTillEnabled { get; set; }
            public string Message { get; set; }
            public string StartedAt { get; set; }
            public string EndedAt { get; set; }
        }

        private static bool IsTillEnabledForCurrentUser()
        {
            if (HttpContext.Current == null || HttpContext.Current.Session == null || HttpContext.Current.Session["UserID"] == null)
            {
                return false;
            }

            string userId = HttpContext.Current.Session["UserID"].ToString();
            string allowTill = DBClass.getField("select isnull(user_till,0) from aspnet_Users where UserId='" + userId + "'");
            bool enabled = allowTill == "1" || allowTill.Equals("true", StringComparison.OrdinalIgnoreCase);
            HttpContext.Current.Session["AllowTill"] = enabled;
            return enabled;
        }

        [WebMethod(EnableSession = true)]
        public static TillActionResult GetTillStatus()
        {
            var result = new TillActionResult
            {
                IsSuccess = true,
                IsActive = false,
                HideButton = false,
                IsTillEnabled = false,
                Message = string.Empty,
                StartedAt = string.Empty,
                EndedAt = string.Empty
            };

            try
            {
                if (HttpContext.Current == null || HttpContext.Current.Session == null || HttpContext.Current.Session["UserID"] == null)
                {
                    result.IsSuccess = false;
                    result.HideButton = true;
                    result.Message = "Session expired.";
                    return result;
                }

                bool tillEnabled = IsTillEnabledForCurrentUser();
                result.IsTillEnabled = tillEnabled;
                if (!tillEnabled)
                {
                    result.IsActive = true;
                    result.HideButton = true;
                    return result;
                }

                bool isActiveFromSession = HttpContext.Current.Session["TillIsActive"] != null && Convert.ToBoolean(HttpContext.Current.Session["TillIsActive"]);
                bool isEndedFromSession = HttpContext.Current.Session["TillEnded"] != null && Convert.ToBoolean(HttpContext.Current.Session["TillEnded"]);
                string startedAtFromSession = HttpContext.Current.Session["TillStartedAt"] != null ? Convert.ToString(HttpContext.Current.Session["TillStartedAt"]) : string.Empty;
                string endedAtFromSession = HttpContext.Current.Session["TillEndedAt"] != null ? Convert.ToString(HttpContext.Current.Session["TillEndedAt"]) : string.Empty;

                result.IsActive = isActiveFromSession;
                result.HideButton = isEndedFromSession;
                result.StartedAt = startedAtFromSession;
                result.EndedAt = endedAtFromSession;

                // Uncomment when table exists
                string userId = HttpContext.Current.Session["UserID"].ToString();
                string scheduleDate = DateTime.Now.ToString("yyyy-MM-dd");
                string sql = "SELECT TOP 1 start_time, close_time FROM user_tills WHERE user_id='" + userId + "' AND schedule_date='" + scheduleDate + "' ORDER BY id DESC";
                DataTable dt = DBClass.getDataTable(sql);
                if (dt.Rows.Count > 0)
                {
                    bool hasClose = dt.Rows[0]["close_time"] != DBNull.Value && dt.Rows[0]["close_time"].ToString() != "";
                    result.IsActive = !hasClose;
                    result.HideButton = hasClose;
                    result.StartedAt = dt.Rows[0]["start_time"].ToString();
                    result.EndedAt = hasClose ? dt.Rows[0]["close_time"].ToString() : string.Empty;
                }
                else
                {
                    result.IsActive = false;
                    result.HideButton = false;
                }

                if (result.HideButton)
                {
                    result.Message = "You have already completed your till for today.";
                }
                else if (!result.IsActive)
                {
                    result.Message = "Please start your till to access forms.";
                }
            }
            catch (Exception ex)
            {
                result.IsSuccess = false;
                result.Message = ex.Message;
            }

            return result;
        }

        [WebMethod(EnableSession = true)]
        public static TillActionResult StartTill()
        {
            var result = new TillActionResult
            {
                IsSuccess = true,
                IsActive = true,
                HideButton = false,
                IsTillEnabled = true,
                Message = "Till started.",
                StartedAt = DateTime.Now.ToString("dd/MM/yyyy hh:mm:ss tt"),
                EndedAt = string.Empty
            };

            try
            {
                if (HttpContext.Current == null || HttpContext.Current.Session == null || HttpContext.Current.Session["UserID"] == null)
                {
                    result.IsSuccess = false;
                    result.IsActive = false;
                    result.HideButton = true;
                    result.Message = "Session expired.";
                    return result;
                }

                if (!IsTillEnabledForCurrentUser())
                {
                    result.IsTillEnabled = false;
                    result.IsActive = true;
                    result.HideButton = true;
                    result.Message = string.Empty;
                    return result;
                }

                string userId = HttpContext.Current.Session["UserID"].ToString();
                string scheduleDate = DateTime.Now.ToString("yyyy-MM-dd");
                string startTime = DateTime.Now.ToString("HH:mm:ss");



                // Uncomment when table exists
                string insertSql = "INSERT INTO user_tills (user_id, schedule_date, start_time, close_time) " +
                     "VALUES ('" + userId + "', '" + scheduleDate + "', '" + startTime + "', NULL)";
                DBClass.getDataTable(insertSql);
            }
            catch (Exception ex)
            {
                result.IsSuccess = false;
                result.IsActive = false;
                result.Message = ex.Message;
            }

            return result;
        }

        [WebMethod(EnableSession = true)]
        public static TillActionResult EndTill()
        {
            var result = new TillActionResult
            {
                IsSuccess = true,
                IsActive = false,
                HideButton = true,
                IsTillEnabled = true,
                Message = "Till ended.",
                StartedAt = HttpContext.Current != null && HttpContext.Current.Session != null && HttpContext.Current.Session["TillStartedAt"] != null
                    ? Convert.ToString(HttpContext.Current.Session["TillStartedAt"])
                    : string.Empty,
                EndedAt = DateTime.Now.ToString("dd/MM/yyyy hh:mm:ss tt")
            };

            try
            {
                if (HttpContext.Current == null || HttpContext.Current.Session == null || HttpContext.Current.Session["UserID"] == null)
                {
                    result.IsSuccess = false;
                    result.HideButton = true;
                    result.Message = "Session expired.";
                    return result;
                }

                if (!IsTillEnabledForCurrentUser())
                {
                    result.IsTillEnabled = false;
                    result.IsActive = true;
                    result.HideButton = true;
                    result.Message = string.Empty;
                    return result;
                }

                string userId = HttpContext.Current.Session["UserID"].ToString();
                string scheduleDate = DateTime.Now.ToString("yyyy-MM-dd");
                string closeTime = DateTime.Now.ToString("HH:mm:ss");



                // Uncomment when table exists
                string updateSql = "UPDATE user_tills SET close_time='" + closeTime + "' " +
                   "WHERE id=(SELECT TOP 1 id FROM user_tills WHERE user_id='" + userId + "' " +
                   "AND schedule_date='" + scheduleDate + "' AND close_time IS NULL ORDER BY id DESC)";
                DBClass.getDataTable(updateSql);
            }
            catch (Exception ex)
            {
                result.IsSuccess = false;
                result.HideButton = false;
                result.Message = ex.Message;
            }

            return result;
        }
        [WebMethod]
        public static string GetDashBoardDetails()
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var Menus = (from usrinRoles in db.aspnet_UsersInRoles
                         join usrs in db.aspnet_Users
                         on usrinRoles.UserId equals usrs.UserId
                         join rolesinMenus in db.aspnet_RolesInMenus
                         on usrinRoles.RoleId equals rolesinMenus.RoleId
                         join m in db.Menus
                         on rolesinMenus.Menu_Id equals m.Menu_ID
                         where m.IsActive == true
                         && usrs.UserId == AppConfig.UserID
                         select m
                      ).Distinct().ToList();
            return (new JavaScriptSerializer().Serialize(Menus));
        }
    }
}