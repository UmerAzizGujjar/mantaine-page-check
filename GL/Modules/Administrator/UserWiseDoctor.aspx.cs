using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.Administrator
{
    public partial class UserWiseDoctor : System.Web.UI.Page
    {
        static int masterID = 0;
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static string FillUsers()
        {
            using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                var users = db.aspnet_Users.Select(u => new { u.UserId, u.UserName }).ToList();
                return new JavaScriptSerializer().Serialize(users);
            }
        }

        [WebMethod]
        public static string LoadTemplates()
        {
            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                var templateList = (from xr in db.XRayLevels
                                    where xr.Levels != null && xr.FixValues != null
                                    select new
                                    {
                                        TemplateValue = xr.XRayLevel_ID,  
                                        DataValue_Description = xr.Levels  
                                    }).ToList();

                return new JavaScriptSerializer().Serialize(templateList);
            }
        }

        public class TemplateDetailItem
        {
            public string userid { get; set; }
            public int templateId { get; set; } 
        }

        [WebMethod]
        public static string SaveSegment(string userid, string btnSave, int EditId, List<TemplateDetailItem> AllItemDetail)
        {
            try
            {
                using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    Guid userGuid = Guid.Parse(userid);

                    if (btnSave == "Save")
                    {
                        var existingUserEntry = db.User_Wise_Templates
                            .FirstOrDefault(x => x.User_Id == userGuid && x.is_cancel == false);
                        if (existingUserEntry != null) return "-1";
                    }

                    User_Wise_Template master;
                    if (btnSave == "Save")
                    {
                        master = new User_Wise_Template
                        {
                            User_Id = userGuid,
                            Created_By = AppConfig.UserID,
                            Created_Time = DateTime.Now,
                            is_cancel = false
                        };
                        db.User_Wise_Templates.InsertOnSubmit(master);
                        db.SubmitChanges();
                        masterID = master.User_Wise_Template_Id;
                    }
                    else
                    {
                        master = db.User_Wise_Templates.FirstOrDefault(x => x.User_Wise_Template_Id == EditId);
                        if (master == null) return "-1";

                        master.User_Id = userGuid;
                        master.Updated_By = AppConfig.UserID;
                        master.Updated_Time = DateTime.Now;
                        db.SubmitChanges();
                        masterID = EditId;
                    }

                    var existingDetails = db.User_Wise_Template_Details
                        .Where(x => x.User_Wise_Template_Id == masterID)
                        .ToList();

                    var newTemplateIds = new HashSet<int>(AllItemDetail.Select(x => x.templateId));

                    var toDelete = existingDetails
                        .Where(ed => ed.DataValue_ID.HasValue && !newTemplateIds.Contains(ed.DataValue_ID.Value))
                        .ToList();

                    if (toDelete.Any())
                    {
                        db.User_Wise_Template_Details.DeleteAllOnSubmit(toDelete);
                    }

                    foreach (var newItem in AllItemDetail)
                    {
                        var existing = existingDetails
                            .FirstOrDefault(ed => ed.DataValue_ID.HasValue && ed.DataValue_ID.Value == newItem.templateId);

                        if (existing != null)
                        {
                            existing.User_Id = userGuid;
                        }
                        else
                        {
                            db.User_Wise_Template_Details.InsertOnSubmit(new User_Wise_Template_Detail
                            {
                                User_Wise_Template_Id = masterID,
                                User_Id = userGuid,
                                DataValue_ID = newItem.templateId  // Stores XRayLevel_ID
                            });
                        }
                    }

                    db.SubmitChanges();
                    return masterID.ToString();
                }
            }
            catch (Exception ex)
            {
                return "Error: " + ex.Message;
            }
        }

        [WebMethod]
        public static string LoadDetail(int id)
        {
            using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                // Get all X-Ray Levels from XRayLevels table
                var allTemplates = (from xr in db.XRayLevels
                                    select new
                                    {
                                        TemplateId = xr.XRayLevel_ID,
                                        Levels = xr.Levels,
                                        FixValues = xr.FixValues
                                    }).ToList();

                // Get saved details from User_Wise_Template_Details
                var details = (from detail in db.User_Wise_Template_Details
                               join usr in db.aspnet_Users on detail.User_Id equals usr.UserId
                               where detail.User_Wise_Template_Id == id
                                     && detail.DataValue_ID.HasValue
                               select new
                               {
                                   detail.User_Id,
                                   user_name = usr.UserName,
                                   SavedValue = detail.DataValue_ID.Value
                               }).ToList();

                // Join in memory: match SavedValue (XRayLevel_ID) with TemplateId
                var result = (from d in details
                              join t in allTemplates on d.SavedValue equals t.TemplateId
                              select new
                              {
                                  User_Id = d.User_Id,
                                  user_name = d.user_name,
                                  Template_Id = t.TemplateId,
                                  Template_Description = t.Levels  // Show Levels as template name
                              }).ToList();

                return new JavaScriptSerializer().Serialize(result);
            }
        }
    }
}