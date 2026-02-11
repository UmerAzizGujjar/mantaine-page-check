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
    public partial class BloodTransfusionList : System.Web.UI.Page
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
                    var Total_BloodTransfusion = _dbContext.Blood_Transfusions.Count();
                    var Blood_Transfusion = from BT in _dbContext.Blood_Transfusions
                                            join P in _dbContext.Reg_patients
                                            on BT.Patient_Id equals P.pat_id
                                            where (BT.BTR_Id.ToString().Contains(searchValue) || P.mr_no_sequence.Contains(searchValue) || P.Full_Name.Contains(searchValue))
                                            select new
                                            {
                                                BTR_Id = BT.BTR_Id,
                                                Mr_No = P.mr_no_sequence,
                                                Name = P.Full_Name,
                                                Age = P.Age_years,
                                            };



                    var FilteredCount = Blood_Transfusion.Count();
                    switch (sortColumn)
                    {
                        case "Mr_No":
                            Blood_Transfusion = sortColumnDirection == "asc" ? Blood_Transfusion.OrderBy(a => a.Mr_No) : Blood_Transfusion.OrderByDescending(a => a.Mr_No);
                            break;
                        default:
                            Blood_Transfusion = Blood_Transfusion.OrderByDescending(a => a.BTR_Id);
                            break;
                    }


                    var Blood_Transfusion_List = Blood_Transfusion.Skip(start).Take(length).ToList();


                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_BloodTransfusion, data = Blood_Transfusion_List };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Blood Transfusion list", ex);
            }
        }

        [WebMethod]
        public static string GetUserColumnPreferences()
        {
            try
            {
                string userId = AppConfig.UserID.ToString();
                string pageName = "BloodTransfusionList";

                using (var db = new DataBaseDataContext())
                {
                    var pref = db.UserDataTablePreferences
                                  .FirstOrDefault(p => p.UserID == userId && p.PageName == pageName);

                    if (pref != null)
                        return pref.ColumnVisibility;
                    else
                        return "";
                }
            }
            catch (Exception ex)
            {
                return "";
            }
        }

        [WebMethod]
        public static void SaveUserColumnPreferences(string visibilityJson)
        {
            try
            {
                string userId = AppConfig.UserID.ToString();
                string pageName = "BloodTransfusionList";

                using (var db = new DataBaseDataContext())
                {
                    var existing = db.UserDataTablePreferences
                                     .FirstOrDefault(p => p.UserID == userId && p.PageName == pageName);

                    if (existing != null)
                    {
                        existing.ColumnVisibility = visibilityJson;
                    }
                    else
                    {
                        db.UserDataTablePreferences.InsertOnSubmit(new UserDataTablePreference
                        {
                            UserID = userId,
                            PageName = pageName,
                            ColumnVisibility = visibilityJson
                        });
                    }

                    db.SubmitChanges();
                }
            }
            catch (Exception ex)
            {
                throw;
            }
        }

    }
}