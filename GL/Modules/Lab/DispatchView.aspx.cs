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
    public partial class DispatchView : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static object GetDispatchList(int draw, int start, int length, string sortColumn,
                                              string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    var query = from sd in _dbContext.Sample_Details
                                join m in _dbContext.Sample_Masters on sd.Sample_ID equals m.Sample_ID
                                join p in _dbContext.Reg_patients on m.Patient_ID equals p.pat_id
                                join lt in _dbContext.Lab_Tests on sd.Test_ID equals lt.Test_ID
                                where sd.accession_no != null && sd.accession_no > 0
                                && sd.dispatch_status == "Dispatched"
                                select new
                                {
                                    Sample_Detail_ID = sd.Sample_Detail_ID,
                                    Accession_No = sd.accession_no,
                                    Sample_ID = m.Sample_ID,
                                    Sample_No = m.Sample_No,
                                    Sample_Collected_Date = m.Sample_Collected_Date,
                                    MR_No = p.Patient_No,
                                    Full_Name = p.Full_Name,
                                    Mobile1 = p.Mobile1,
                                    Test_Name = lt.Test_Name,
                                    OutSource = sd.OutSource,
                                    dispatch_status = sd.dispatch_status,
                                    dispatch_date = sd.dispatch_date,
                                    printed = sd.printed ?? false  // Add printed status
                                };

                    var Total_records = query.Count();

                    // Apply search filter
                    if (!string.IsNullOrEmpty(searchValue))
                    {
                        query = query.Where(x => x.Accession_No.ToString().Contains(searchValue) ||
                                                  x.Sample_No.ToString().Contains(searchValue) ||
                                                  x.MR_No.ToString().Contains(searchValue) ||
                                                  x.Full_Name.Contains(searchValue) ||
                                                  x.Test_Name.Contains(searchValue) ||
                                                  (x.OutSource != null && x.OutSource.Contains(searchValue)));
                    }

                    var FilteredCount = query.Count();

                    // Apply sorting
                    switch (sortColumn)
                    {
                        case "Accession_No":
                            query = sortColumnDirection == "asc" ? query.OrderBy(a => a.Accession_No) : query.OrderByDescending(a => a.Accession_No);
                            break;
                        case "Sample_No":
                            query = sortColumnDirection == "asc" ? query.OrderBy(a => a.Sample_No) : query.OrderByDescending(a => a.Sample_No);
                            break;
                        case "MR_No":
                            query = sortColumnDirection == "asc" ? query.OrderBy(a => a.MR_No) : query.OrderByDescending(a => a.MR_No);
                            break;
                        case "Full_Name":
                            query = sortColumnDirection == "asc" ? query.OrderBy(a => a.Full_Name) : query.OrderByDescending(a => a.Full_Name);
                            break;
                        case "Test_Name":
                            query = sortColumnDirection == "asc" ? query.OrderBy(a => a.Test_Name) : query.OrderByDescending(a => a.Test_Name);
                            break;
                        case "dispatch_date":
                            query = sortColumnDirection == "asc" ? query.OrderBy(a => a.dispatch_date) : query.OrderByDescending(a => a.dispatch_date);
                            break;
                        case "printed":
                            query = sortColumnDirection == "asc" ? query.OrderBy(a => a.printed) : query.OrderByDescending(a => a.printed);
                            break;
                        default:
                            query = query.OrderByDescending(a => a.dispatch_date);
                            break;
                    }

                    var accessionList = query.Skip(start).Take(length).ToList();

                    var jsonData = new
                    {
                        draw = draw,
                        recordsFiltered = FilteredCount,
                        recordsTotal = Total_records,
                        data = accessionList
                    };

                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching dispatch list", ex);
            }
        }

        [WebMethod]
        public static string MarkAsPrinted(int[] sampleDetailIds)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    foreach (var id in sampleDetailIds)
                    {
                        var sampleDetail = _dbContext.Sample_Details.FirstOrDefault(sd => sd.Sample_Detail_ID == id);
                        if (sampleDetail != null)
                        {
                            sampleDetail.printed = true;
                            //sampleDetail.printed_date = DateTime.Now;
                        }
                    }

                    _dbContext.SubmitChanges();
                    return "Success";
                }
            }
            catch (Exception ex)
            {
                return ex.Message;
            }
        }

        [WebMethod]
        public static string GetUserColumnPreferences()
        {
            try
            {
                if (HttpContext.Current.Session["DispatchColumnPreferences"] != null)
                {
                    return HttpContext.Current.Session["DispatchColumnPreferences"].ToString();
                }
                return "";
            }
            catch (Exception)
            {
                return "";
            }
        }

        [WebMethod]
        public static void SaveUserColumnPreferences(string preferences)
        {
            try
            {
                HttpContext.Current.Session["DispatchColumnPreferences"] = preferences;
            }
            catch (Exception)
            {
                // Handle error
            }
        }
    }
}