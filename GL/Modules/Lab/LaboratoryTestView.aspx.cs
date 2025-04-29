using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Net;
using System.Data.SqlClient;
using System.IO;
using System.Web.Services;
using System.Drawing.Printing;
using CrystalDecisions.CrystalReports.Engine;
using System.Configuration;
using CrystalDecisions.Shared;
using System.Web.Script.Serialization;
namespace PMS
{
    public partial class LaboratoryTestView : System.Web.UI.Page
    {
        protected override void OnInit(EventArgs e)
        {
            if (Session["Company_ID"] != null)
            {
               
            }
           
        }

        protected void Page_Load(object sender, EventArgs e)
        {

        }
       
        [WebMethod]
        public static string DeleteRecord(string labID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var remove = (from aremove in db.Laboratory_Tests
                          where aremove.Lab_Test_ID == Convert.ToInt32(labID)

                          select aremove).FirstOrDefault();
            db.Laboratory_Tests.DeleteOnSubmit(remove);


            var removedetail = (from aremove in db.Lab_Test_Details
                                where aremove.Lab_Test_ID == Convert.ToInt32(labID)

                                select aremove).ToList();
            db.Laboratory_Tests.DeleteOnSubmit(remove);
            db.SubmitChanges();
            return "";

        }

        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    string userId = HttpContext.Current.Session["UserId"].ToString();

                    var Total_tests = _dbContext.Laboratory_Tests.Count();
                    var Tests = from lb in _dbContext.Laboratory_Tests
                                join rp in _dbContext.Reg_patients on lb.Patient_ID equals rp.pat_id
                                where lb.Parent_Transaction_Type != ""
                                &&
                             ((lb.Lab_Test_ID.ToString().Contains(searchValue) || rp.mr_no_sequence.Contains(searchValue) || rp.Full_Name.Contains(searchValue) || rp.Patient_No.ToString().Contains(searchValue)))
                                    select new
                                    {
                                        Patient_ID = lb.Patient_ID,
                                        Lab_Test_ID = lb.Lab_Test_ID,
                                        mr_no_sequence = rp.mr_no_sequence,
                                        Patient_No  = rp.Patient_No,
                                        Full_Name = rp.Full_Name,
                                        Transaction_Type = lb.Parent_Transaction_Type,
                                        Created_Time = lb.Created_Time,
                                    };

                    var FilteredCount = Tests.Count();
                    switch (sortColumn)
                    {
                        case "Lab_Test_ID":
                            Tests = sortColumnDirection == "asc" ? Tests.OrderBy(a => a.Lab_Test_ID) : Tests.OrderByDescending(a => a.Lab_Test_ID);
                            break;
                        case "mr_no_sequence":
                            Tests = sortColumnDirection == "asc" ? Tests.OrderBy(b => b.mr_no_sequence) : Tests.OrderByDescending(a => a.mr_no_sequence);
                            break;
                        default:
                            Tests = Tests.OrderByDescending(a => a.Lab_Test_ID);
                            break;
                    }

                    var patientList = Tests.Skip(start).Take(length).ToList();

                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_tests, data = patientList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching patient list", ex);
            }
        }
    }
}