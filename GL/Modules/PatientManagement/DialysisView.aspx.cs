using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.PatientManagement
{
    public partial class DialysisView : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static string DeleteRecord(string DialysisID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            
            var removePreDialysis = (from r in db.Dialysis_PreDialysis
                          where r.Dialysis_ID == DialysisID
                          select r).FirstOrDefault();
            if (removePreDialysis != null)
            {
                db.Dialysis_PreDialysis.DeleteOnSubmit(removePreDialysis);
            }

            var removeDuringDialysis = (from r in db.Dialysis_DuringDialysis
                                       where r.Dialysis_ID == DialysisID
                                       select r).ToList();
            if (removeDuringDialysis.Any())
            {
                db.Dialysis_DuringDialysis.DeleteAllOnSubmit(removeDuringDialysis);
            }

            var removePostDialysis = (from r in db.Dialysis_PostDialysis
                                     where r.Dialysis_ID == DialysisID
                                     select r).FirstOrDefault();
            if (removePostDialysis != null)
            {
                db.Dialysis_PostDialysis.DeleteOnSubmit(removePostDialysis);
            }

            db.SubmitChanges();
            return "";
        }


        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    string userId = HttpContext.Current.Session["UserId"].ToString();

                    var Total_Dialysis = _dbContext.Dialysis_PreDialysis.Count();
                    
                    var DialysisRecords = from d in _dbContext.Dialysis_PreDialysis
                                          join p in _dbContext.Reg_patients on d.Patient_ID equals p.pat_id
                                          where (
                                              string.IsNullOrEmpty(searchValue) ||
                                              d.Dialysis_ID.Contains(searchValue) || 
                                              d.Dialysis_No.Contains(searchValue) || 
                                              p.mr_no_sequence.Contains(searchValue) || 
                                              p.Full_Name.Contains(searchValue))
                                          select new
                                          {
                                              Dialysis_ID = d.Dialysis_ID,
                                              Dialysis_No = d.Dialysis_No,
                                              MRNo = p.mr_no_sequence ?? "",
                                              Patient_Name = p.Full_Name ?? "",
                                              Created_Date = d.Created_Date
                                          };

                    var FilteredCount = DialysisRecords.Count();
                    
                    switch (sortColumn)
                    {
                        case "Dialysis_No":
                            DialysisRecords = sortColumnDirection == "asc" ? DialysisRecords.OrderBy(a => a.Dialysis_No) : DialysisRecords.OrderByDescending(a => a.Dialysis_No);
                            break;
                        case "MRNo":
                            DialysisRecords = sortColumnDirection == "asc" ? DialysisRecords.OrderBy(a => a.MRNo) : DialysisRecords.OrderByDescending(a => a.MRNo);
                            break;
                        case "Patient_Name":
                            DialysisRecords = sortColumnDirection == "asc" ? DialysisRecords.OrderBy(a => a.Patient_Name) : DialysisRecords.OrderByDescending(a => a.Patient_Name);
                            break;
                        default:
                            DialysisRecords = DialysisRecords.OrderByDescending(a => a.Dialysis_No);
                            break;
                    }

                    var DialysisList = DialysisRecords.Skip(start).Take(length).ToList()
                        .Select(d => new
                        {
                            d.Dialysis_ID,
                            d.Dialysis_No,
                            d.MRNo,
                            d.Patient_Name,
                            Date = d.Created_Date.HasValue ? d.Created_Date.Value.ToString("dd-MMM-yyyy") : ""
                        }).ToList();

                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Dialysis, data = DialysisList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Dialysis list", ex);
            }
        }
    }
}