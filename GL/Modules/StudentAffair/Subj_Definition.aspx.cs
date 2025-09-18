using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.StudentAffair
{
    public partial class Subj_Definition : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static string GetPrograms()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Admission Category"
                              select new
                              {
                                  dv.DataValue_Name,
                                  dv.DataValue_Description
                              }).ToList();

                return new JavaScriptSerializer().Serialize(result);
            }
        }

        [WebMethod]
        public static string GetStudentClass()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Student Class"
                              select new
                              {
                                  dv.DataValue_Name,
                                  dv.DataValue_Description
                              }).ToList();

                return new JavaScriptSerializer().Serialize(result);
            }
        }

        [WebMethod]
        public static string GetAcademicBlock()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Academic Block"
                              select new
                              {
                                  dv.DataValue_Name,
                                  dv.DataValue_Description
                              }).ToList();

                return new JavaScriptSerializer().Serialize(result);
            }
        }

        [WebMethod]
        public static string GetAcademicModule()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Academic Module"
                              select new
                              {
                                  dv.DataValue_Name,
                                  dv.DataValue_Description
                              }).ToList();

                return new JavaScriptSerializer().Serialize(result);
            }
        }

        [WebMethod]
        public static string SaveSubjectDefinition(string btnsave, string AllItemDetail)
        {
            try
            {
                if (string.IsNullOrEmpty(AllItemDetail))
                    return "0";

                JavaScriptSerializer serializer = new JavaScriptSerializer();
                var record = serializer.Deserialize<SubjectDefinitionDTO>(AllItemDetail);

                if (record == null || string.IsNullOrEmpty(record.Program) ||
                    string.IsNullOrEmpty(record.StudentClass) ||
                    record.Subjects == null || !record.Subjects.Any())
                    return "0";

                using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    if (btnsave == "Update" && !string.IsNullOrEmpty(record.SubjectId))
                    {
                        if (!int.TryParse(record.SubjectId, out int masterId))
                            return "0";

                        var master = db.Subject_Definitions.FirstOrDefault(x => x.subject_Id == masterId);
                        if (master == null)
                            return "0";

                        master.Program = record.Program;
                        master.Class = record.StudentClass;
                        master.Block = string.IsNullOrEmpty(record.Block) ? null : record.Block;
                        master.Module = string.IsNullOrEmpty(record.Module) ? null : record.Module;
                        master.Update_Time = DateTime.Now;
                        master.Update_By = AppConfig.UserID;

                        var existingDetails = db.Subject_Definition_Lists.Where(x => x.Subject_ID == masterId).ToList();
                        if (existingDetails.Any())
                        {
                            db.Subject_Definition_Lists.DeleteAllOnSubmit(existingDetails);
                        }

                        foreach (var subject in record.Subjects)
                        {
                            if (string.IsNullOrWhiteSpace(subject?.SubjectName)) continue;

                            var newDetail = new Subject_Definition_List
                            {
                                Subject_ID = masterId,
                                Subject_Name = subject.SubjectName.Trim(),
                                IS_Active = subject.IsActive,
                                Created_Time = DateTime.Now,
                                Created_By = AppConfig.UserID,
                                Update_Time = DateTime.Now,
                                Update_By = AppConfig.UserID
                            };
                            db.Subject_Definition_Lists.InsertOnSubmit(newDetail);
                        }

                        db.SubmitChanges();
                        return masterId.ToString();
                    }
                    else
                    {
                        var newMaster = new Subject_Definition
                        {
                            Program = record.Program,
                            Class = record.StudentClass,
                            Block = string.IsNullOrEmpty(record.Block) ? null : record.Block,
                            Module = string.IsNullOrEmpty(record.Module) ? null : record.Module,
                            Created_Time = DateTime.Now,
                            Created_By = AppConfig.UserID,
                            Update_Time = null,
                            Update_By = null
                        };

                        db.Subject_Definitions.InsertOnSubmit(newMaster);
                        db.SubmitChanges();

                        foreach (var subject in record.Subjects)
                        {
                            if (string.IsNullOrWhiteSpace(subject?.SubjectName)) continue;

                            var newDetail = new Subject_Definition_List
                            {
                                Subject_ID = newMaster.subject_Id,
                                Subject_Name = subject.SubjectName.Trim(),
                                IS_Active = subject.IsActive,
                                Created_Time = DateTime.Now,
                                Created_By = AppConfig.UserID,
                                Update_Time = null,
                                Update_By = null
                            };
                            db.Subject_Definition_Lists.InsertOnSubmit(newDetail);
                        }

                        db.SubmitChanges();
                        return newMaster.subject_Id.ToString();
                    }
                }
            }
            catch (Exception ex)
            {
                // Log exception
                return "0";
            }
        }

        public class SubjectDefinitionDTO
        {
            public string SubjectId { get; set; }
            public string Program { get; set; }
            public string StudentClass { get; set; }
            public string Block { get; set; }
            public string Module { get; set; }
            public List<SubjectItem> Subjects { get; set; }
        }

        public class SubjectItem
        {
            public string SubjectName { get; set; }
            public bool IsActive { get; set; }
        }


        [WebMethod]
        public static string GetSubjectDefinitionById(string id)
        {
            try
            {
                if (string.IsNullOrEmpty(id) || !int.TryParse(id, out int subjectId))
                    return null;

                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var master = db.Subject_Definitions.FirstOrDefault(x => x.subject_Id == subjectId);
                    if (master == null)
                        return null;
                    var details = db.Subject_Definition_Lists
                                     .Where(x => x.Subject_ID == subjectId)
                                     .Select(x => new {
                                         SubjectName = x.Subject_Name,
                                         IsActive = x.IS_Active == null ? true : x.IS_Active
                                     }).ToList();

                    var result = new
                    {
                        SubjectId = master.subject_Id.ToString(),
                        Program = master.Program,
                        Program_Text = db.GetDataValueName("Admission Category", master.Program),
                        StudentClass = master.Class,
                        StudentClass_Text = db.GetDataValueName("Student Class", master.Class),
                        Block = master.Block,
                        Block_Text = db.GetDataValueName("Academic Block", master.Block),
                        Module = master.Module,
                        Module_Text = db.GetDataValueName("Academic Module", master.Module),
                        Subjects = details
                    };

                    return new JavaScriptSerializer().Serialize(result);
                }
            }
            catch
            {
                return null;
            }
        }
    }
}