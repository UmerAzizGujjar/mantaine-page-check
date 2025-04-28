using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;



namespace PMS.Modules.Lab
{
    public partial class SampleView : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    string userId = HttpContext.Current.Session["UserId"].ToString();

                    var Total_Sample = _dbContext.Sample_Masters.Count();
                    var Sample = from SM in _dbContext.Sample_Masters
                                 join P in _dbContext.Patients on SM.Patient_ID equals P.Patient_ID
                                 where
                                      ((SM.Sample_No.ToString().Contains(searchValue) || P.Full_Name.ToString().Contains(searchValue) || P.mr_no_sequence.ToString().Contains(searchValue)))
                                 select new
                                 {
                                     Sample_ID = SM.Sample_ID,
                                     Sample_No = SM.Sample_No,
                                     Sample_Collected_Date = SM.Sample_Collected_Date,
                                     Expected_Result_Date = SM.Expected_Result_Date,
                                     Patient_No = P.Patient_No,
                                     Full_Name = P.Full_Name,
                                     mr_no_sequence = P.mr_no_sequence,
                                 };

                    var FilteredCount = Sample.Count();
                    switch (sortColumn)
                    {
                        case "Sample_No":
                            Sample = sortColumnDirection == "asc" ? Sample.OrderBy(a => a.Sample_No) : Sample.OrderByDescending(a => a.Sample_No);
                            break;
                        case "mr_no_sequence":
                            Sample = sortColumnDirection == "asc" ? Sample.OrderBy(b => b.mr_no_sequence) : Sample.OrderByDescending(a => a.mr_no_sequence);
                            break;
                        default:
                            Sample = Sample.OrderBy(a => a.Sample_No);
                            break;
                    }

                    var SampleList = Sample.Skip(start).Take(length).ToList();

                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Sample, data = SampleList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Sample list", ex);
            }
        }
    }
}