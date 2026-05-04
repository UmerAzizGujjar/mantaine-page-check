using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class SubjectList : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue, string filterClass, string filterBlock, string filterModule)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {

                    var Total_Subject = _dbContext.Subject_Definitions.Count();

                    var SubjectQuery = from S in _dbContext.Subject_Definitions
                                       select new
                                       {
                                           subject_Id = S.subject_Id,
                                           ProgramName = _dbContext.GetDataValueName("Admission Category", S.Program),
                                           ClassName = _dbContext.GetDataValueName("Student Class", S.Class),
                                           BlockName = _dbContext.GetDataValueName("Academic Block", S.Block),
                                           ModuleName = _dbContext.GetDataValueName("Academic Module", S.Module),
                                           RawClass = S.Class,
                                           RawBlock = S.Block,
                                           RawModule = S.Module
                                       };

                    if (!string.IsNullOrEmpty(searchValue))
                    {
                        SubjectQuery = SubjectQuery.Where(S =>
                            S.subject_Id.ToString().Contains(searchValue) ||
                            S.ProgramName.Contains(searchValue) ||
                            S.ClassName.Contains(searchValue) ||
                            S.BlockName.Contains(searchValue) ||
                            S.ModuleName.Contains(searchValue)
                        );
                    }

                    if (!string.IsNullOrEmpty(filterClass) && filterClass != "All")
                    {
                        SubjectQuery = SubjectQuery.Where(S => S.ClassName == filterClass);
                    }

                    if (!string.IsNullOrEmpty(filterBlock) && filterBlock != "All")
                    {
                        SubjectQuery = SubjectQuery.Where(S => S.BlockName == filterBlock);
                    }

                    if (!string.IsNullOrEmpty(filterModule) && filterModule != "All")
                    {
                        SubjectQuery = SubjectQuery.Where(S => S.ModuleName == filterModule);
                    }

                    var FilteredCount = SubjectQuery.Count();

                    switch (sortColumn)
                    {
                        case "Program":
                            SubjectQuery = sortColumnDirection == "asc" ? SubjectQuery.OrderBy(a => a.ProgramName) : SubjectQuery.OrderByDescending(a => a.ProgramName);
                            break;
                        case "Class":
                            SubjectQuery = sortColumnDirection == "asc" ? SubjectQuery.OrderBy(a => a.ClassName) : SubjectQuery.OrderByDescending(a => a.ClassName);
                            break;
                        case "Block":
                            SubjectQuery = sortColumnDirection == "asc" ? SubjectQuery.OrderBy(a => a.BlockName) : SubjectQuery.OrderByDescending(a => a.BlockName);
                            break;
                        case "Module":
                            SubjectQuery = sortColumnDirection == "asc" ? SubjectQuery.OrderBy(a => a.ModuleName) : SubjectQuery.OrderByDescending(a => a.ModuleName);
                            break;
                        default:
                            SubjectQuery = SubjectQuery.OrderByDescending(a => a.subject_Id);
                            break;
                    }

                    var SubjectList = SubjectQuery.Skip(start).Take(length).ToList();

                    var finalData = SubjectList.Select(s => new {
                        subject_Id = s.subject_Id,
                        Program = s.ProgramName,
                        Class = s.ClassName,
                        Block = s.BlockName,
                        Module = s.ModuleName
                    }).ToList();

                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Subject, data = finalData };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Student list: " + ex.Message);
            }
        }

        [WebMethod]
        public static object GetFilterOptions()
        {
            using (var _dbContext = new DataBaseDataContext())
            {
                var classes = _dbContext.Subject_Definitions
                    .Select(s => _dbContext.GetDataValueName("Student Class", s.Class))
                    .Distinct()
                    .OrderBy(c => c)
                    .ToList();
                var blocks = _dbContext.Subject_Definitions
                    .Select(s => _dbContext.GetDataValueName("Academic Block", s.Block))
                    .Distinct()
                    .OrderBy(b => b)
                    .ToList();

                var modules = _dbContext.Subject_Definitions
                    .Select(s => _dbContext.GetDataValueName("Academic Module", s.Module))
                    .Distinct()
                    .OrderBy(m => m)
                    .ToList();

                return new { Classes = classes, Blocks = blocks, Modules = modules };
            }
        }

        [WebMethod]
        public static string DeleteSubject(int Id)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var Delete = DBClass.getField("delete from Subject_Definition_List where subject_Id= '" + Id + "' ");
            var DeleteMaster = DBClass.getField("delete from Subject_Definition where subject_Id= '" + Id + "' ");
            return (Delete);
        }
    }
}