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
        public static string FillTestMainDepartment()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var dpt = (from d in db.DataValues
                       join v in db.ValueSets
                       on d.ValueSet_ID equals v.ValueSet_ID
                       where v.ValueSet_Name == "Main Test Departments"
                       where d.DataValue_Description == "X-Ray"
                          || d.DataValue_Description == "MRI"
                          || d.DataValue_Description == "CT Scan"
                          || d.DataValue_Description == "Ultrasound"
                       select new
                       {
                           d.DataValue_Name,
                           d.DataValue_Description
                       }).ToList();

            return (new JavaScriptSerializer().Serialize(dpt));
        }

        [WebMethod]
        public static string LoadTemplatesByDepartment(string department)
        {
            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                string valueSetName = "";

                switch (department)
                {
                    case "X-Ray":
                        valueSetName = "X-Ray Format";
                        break;
                    case "MRI":
                        valueSetName = "MRI Format";
                        break;
                    case "CT Scan":
                        valueSetName = "CTScan Format";
                        break;
                    case "Ultrasound":
                        valueSetName = "Ultrasound level"; 
                        break;
                    default:
                        return new JavaScriptSerializer().Serialize(new List<object>());
                }

                var templateList = (from dv in db.DataValues
                                    join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                                    where vs.ValueSet_Name == valueSetName
                                    select new
                                    {
                                        TemplateValue = dv.DataValue_Name,
                                        DataValue_Description = dv.DataValue_Description
                                    }).ToList();

                return new JavaScriptSerializer().Serialize(templateList);
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
                                        TemplateValue = dv.DataValue_Name,
                                        DataValue_Description = dv.DataValue_Description
                                    }).ToList();

                return new JavaScriptSerializer().Serialize(templateList);
            }
        }

        public class TemplateDetailItem
        {
            public string userid { get; set; }
            public string templateId { get; set; }
            public string department { get; set; }
        }

        [WebMethod]
        public static string SaveSegment(string userid, string btnSave, int EditId, List<TemplateDetailItem> AllItemDetail)
        {
            try
            {
                using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    Guid userGuid = Guid.Parse(userid);

                    User_Wise_Template master;

                    if (btnSave == "Save")
                    {
                        // Check if user already has a master record
                        var existingUserMaster = db.User_Wise_Templates
                            .FirstOrDefault(x => x.User_Id == userGuid && x.is_cancel == false);

                        if (existingUserMaster != null)
                        {
                            // User already has a master record, check if they're trying to add same department
                            var existingDepts = db.User_Wise_Template_Details
                                .Where(x => x.User_Wise_Template_Id == existingUserMaster.User_Wise_Template_Id)
                                .Select(x => x.Department)
                                .Distinct()
                                .ToList();

                            // Check if any of the new departments already exist
                            foreach (var newItem in AllItemDetail)
                            {
                                if (existingDepts.Contains(newItem.department))
                                {
                                    return "DepartmentExists"; // Return specific error for duplicate department
                                }
                            }

                            // Update existing master
                            master = existingUserMaster;
                            master.Updated_By = AppConfig.UserID;
                            master.Updated_Time = DateTime.Now;
                            db.SubmitChanges();
                            masterID = master.User_Wise_Template_Id;
                        }
                        else
                        {
                            // Create new master record
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
                    }
                    else // Update mode
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

                    var newItemsSet = new HashSet<string>(AllItemDetail.Select(x => $"{x.templateId}_{x.department}"));

                    var toDelete = existingDetails
                        .Where(ed => !string.IsNullOrEmpty(ed.DataValue_ID) &&
                                    !newItemsSet.Contains($"{ed.DataValue_ID}_{ed.Department}"))
                        .ToList();

                    if (toDelete.Any())
                    {
                        db.User_Wise_Template_Details.DeleteAllOnSubmit(toDelete);
                    }

                    foreach (var newItem in AllItemDetail)
                    {
                        var existing = existingDetails
                            .FirstOrDefault(ed => ed.DataValue_ID == newItem.templateId && ed.Department == newItem.department);

                        if (existing != null)
                        {
                            existing.User_Id = userGuid;
                            existing.Department = newItem.department;
                        }
                        else
                        {
                            db.User_Wise_Template_Details.InsertOnSubmit(new User_Wise_Template_Detail
                            {
                                User_Wise_Template_Id = masterID,
                                User_Id = userGuid,
                                DataValue_ID = newItem.templateId,
                                Department = newItem.department
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
                var details = (from detail in db.User_Wise_Template_Details
                               join usr in db.aspnet_Users on detail.User_Id equals usr.UserId
                               where detail.User_Wise_Template_Id == id
                                     && detail.DataValue_ID != null
                                     && detail.DataValue_ID != ""
                               select new
                               {
                                   detail.User_Id,
                                   user_name = usr.UserName,
                                   TemplateId = detail.DataValue_ID,
                                   Department = detail.Department
                               }).ToList();

                var result = new List<object>();

                foreach (var detail in details)
                {
                    string templateDescription = GetTemplateDescription(db, detail.Department, detail.TemplateId);

                    result.Add(new
                    {
                        User_Id = detail.User_Id,
                        user_name = detail.user_name,
                        Template_Id = detail.TemplateId,
                        Template_Description = templateDescription,
                        Department = detail.Department
                    });
                }

                return new JavaScriptSerializer().Serialize(result);
            }
        }

        private static string GetTemplateDescription(DataBaseDataContext db, string department, string templateId)
        {
            string valueSetName = "";

            switch (department)
            {
                case "X-Ray":
                    valueSetName = "X-Ray Format";
                    break;
                case "MRI":
                    valueSetName = "MRI Format";
                    break;
                case "CT Scan":
                    valueSetName = "CTScan Format";
                    break;
                case "Ultrasound":
                    valueSetName = "Ultrasound level";  
                    break;
                default:
                    return "";
            }

            var template = (from dv in db.DataValues
                            join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                            where vs.ValueSet_Name == valueSetName && dv.DataValue_Name == templateId
                            select dv.DataValue_Description).FirstOrDefault();

            return template ?? "";
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
                                  on uwtDetail.DataValue_ID equals xr.Levels
                              where uwt.User_Id == currentUserIdGuid
                                    && uwtDetail.User_Id == currentUserIdGuid
                                    && uwt.is_cancel == false
                                    && !string.IsNullOrEmpty(uwtDetail.DataValue_ID)
                                    && uwtDetail.Department == "X-Ray"
                              select new
                              {
                                  xr.XRayLevel_ID,
                                  xr.Levels,
                                  xr.FixValues
                              }).Distinct().ToList();

                return (new JavaScriptSerializer()).Serialize(levels);
            }
        }

        [WebMethod]
        public static string GetAll_UltrasoundLevel()
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
                              join us in db.UltraSoundLevels  
                                  on uwtDetail.DataValue_ID equals us.Levels
                              where uwt.User_Id == currentUserIdGuid
                                    && uwtDetail.User_Id == currentUserIdGuid
                                    && uwt.is_cancel == false
                                    && !string.IsNullOrEmpty(uwtDetail.DataValue_ID)
                                    && uwtDetail.Department == "Ultrasound"
                              select new
                              {
                                  us.UltraSoundLevel_ID,
                                  us.Levels,
                                  us.FixValues
                              }).Distinct().ToList();

                return (new JavaScriptSerializer()).Serialize(levels);
            }
        }
    }
}