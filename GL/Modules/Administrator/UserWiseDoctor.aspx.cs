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
                var templateList = (from dv in db.DataValues
                                    join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                                    where vs.ValueSet_Name == "X-Ray Format"
                                    select new
                                    {
                                        TemplateValue = dv.DataValue_Name,  // "001", "002" as string
                                        DataValue_Description = dv.DataValue_Description
                                    }).ToList();

                return new JavaScriptSerializer().Serialize(templateList);
            }
        }

        public class TemplateDetailItem
        {
            public string userid { get; set; }
            public string templateId { get; set; }  // Will receive "001", "002"
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

                    var newTemplateIds = new HashSet<string>(AllItemDetail.Select(x => x.templateId));

                    // Delete removed templates
                    var toDelete = existingDetails
                        .Where(ed => !string.IsNullOrEmpty(ed.DataValue_ID) && !newTemplateIds.Contains(ed.DataValue_ID))
                        .ToList();

                    if (toDelete.Any())
                    {
                        db.User_Wise_Template_Details.DeleteAllOnSubmit(toDelete);
                    }

                    foreach (var newItem in AllItemDetail)
                    {
                        var existing = existingDetails
                            .FirstOrDefault(ed => ed.DataValue_ID == newItem.templateId);

                        if (existing != null)
                        {
                            existing.User_Id = userGuid;
                        }
                        else
                        {
                            // Save DataValue_Name directly as string
                            db.User_Wise_Template_Details.InsertOnSubmit(new User_Wise_Template_Detail
                            {
                                User_Wise_Template_Id = masterID,
                                User_Id = userGuid,
                                DataValue_ID = newItem.templateId  // Saves "001", "002"
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
                // Get all X-Ray Format DataValues
                var allTemplates = (from dv in db.DataValues
                                    join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                                    where vs.ValueSet_Name == "X-Ray Format"
                                    select new
                                    {
                                        TemplateId = dv.DataValue_Name,  // "001", "002"
                                        TemplateDescription = dv.DataValue_Description
                                    }).ToList();

                // Get saved details - remove IsNullOrEmpty, use != null and != ""
                var details = (from detail in db.User_Wise_Template_Details
                               join usr in db.aspnet_Users on detail.User_Id equals usr.UserId
                               where detail.User_Wise_Template_Id == id
                                     && detail.DataValue_ID != null
                                     && detail.DataValue_ID != ""
                               select new
                               {
                                   detail.User_Id,
                                   user_name = usr.UserName,
                                   SavedValue = detail.DataValue_ID  // Gets "001", "002"
                               }).ToList();

                // Join to get template descriptions
                var result = (from d in details
                              join t in allTemplates on d.SavedValue equals t.TemplateId
                              select new
                              {
                                  User_Id = d.User_Id,
                                  user_name = d.user_name,
                                  Template_Id = t.TemplateId,  // "001", "002"
                                  Template_Description = t.TemplateDescription
                              }).ToList();

                return new JavaScriptSerializer().Serialize(result);
            }
        }

        [WebMethod]
        public static string GetAll_XRayLevel()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                if (AppConfig.UserID == Guid.Empty)
                {
                    return (new JavaScriptSerializer()).Serialize(new List<object>());
                }

                Guid currentUserIdGuid = AppConfig.UserID;

                var levels = (from uwt in db.User_Wise_Templates
                              join uwtDetail in db.User_Wise_Template_Details
                                  on uwt.User_Wise_Template_Id equals uwtDetail.User_Wise_Template_Id
                              join xr in db.XRayLevels
                                  on uwtDetail.DataValue_ID equals xr.Levels  // "001" = "001"
                              where uwt.User_Id == currentUserIdGuid
                                    && uwtDetail.User_Id == currentUserIdGuid
                                    && uwt.is_cancel == false
                                    && !string.IsNullOrEmpty(uwtDetail.DataValue_ID)
                              select new
                              {
                                  xr.XRayLevel_ID,
                                  xr.Levels,
                                  xr.FixValues
                              }).Distinct().ToList();

                return (new JavaScriptSerializer()).Serialize(levels);
            }
        }
    }
}