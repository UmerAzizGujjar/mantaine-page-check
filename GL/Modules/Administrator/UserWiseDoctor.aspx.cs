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

                    // Get or create master record for this user
                    var existingMaster = db.User_Wise_Templates
                        .FirstOrDefault(x => x.User_Id == userGuid && x.is_cancel == false);

                    if (existingMaster != null)
                    {
                        masterID = existingMaster.User_Wise_Template_Id;
                    }
                    else
                    {
                        // Create new master record
                        var master = new User_Wise_Template
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

                    // Now insert ALL items as new details (no department uniqueness check)
                    foreach (var item in AllItemDetail)
                    {
                        // Always insert new detail record - allowing multiple templates per department
                        db.User_Wise_Template_Details.InsertOnSubmit(new User_Wise_Template_Detail
                        {
                            User_Wise_Template_Id = masterID,
                            User_Id = userGuid,
                            DataValue_ID = item.templateId,
                            Department = item.department
                        });
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
                                   DepartmentCode = detail.Department  // This is "002", "003", etc.
                               }).ToList();

                var result = new List<object>();

                foreach (var detail in details)
                {
                    // First convert department code to actual department name
                    string departmentName = GetDepartmentNameFromCode(db, detail.DepartmentCode);

                    // Now get template description using the actual department name
                    string templateDescription = GetTemplateDescription(db, departmentName, detail.TemplateId);

                    result.Add(new
                    {
                        User_Id = detail.User_Id,
                        user_name = detail.user_name,
                        Template_Id = detail.TemplateId,
                        Template_Description = templateDescription,
                        Department = departmentName,  // Send actual name for display
                        DepartmentCode = detail.DepartmentCode  // Keep code if needed
                    });
                }

                return new JavaScriptSerializer().Serialize(result);
            }
        }

        // New method to convert department code to actual department name
        private static string GetDepartmentNameFromCode(DataBaseDataContext db, string departmentCode)
        {
            var department = db.DataValues
                .FirstOrDefault(dv => dv.ValueSet_ID == 72 && dv.DataValue_Name == departmentCode);

            return department != null ? department.DataValue_Description : departmentCode;
        }

        private static string GetTemplateDescription(DataBaseDataContext db, string departmentName, string templateId)
        {
            string valueSetName = "";

            switch (departmentName)  // Now this receives actual names like "X-Ray", "MRI", etc.
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