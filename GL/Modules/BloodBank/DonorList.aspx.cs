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
    public partial class DonorList : System.Web.UI.Page
    {

        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static string CancelPatient(string Donor_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var isProceed = true;
            string status = "Allowdlt";
            //string AllowPatientDelete = DBClass.getField("select dbo.GetRights('AllowPatientDelete','" + AppConfig.UserID + "')");

            //if (Convert.ToBoolean(AllowPatientDelete) == true)
            //{

            var row_count = DBClass.getField("select D_bagno from donor where donor_id='" + Donor_ID + "'");

            //var donor = from data in db.Donors where (data.Donor_Id.Equals(Donor_ID)) select data.D_bagno.FirstOrDefault();
            if (row_count == null || row_count == "null" || row_count == "")
            {
                DBClass.executeNonQueryWithoutBegin("update donor set IsCancel=1 where donor_id='" + Donor_ID + "'");
                isProceed = true;
                status = "success";
            }
            else
            {
                isProceed = false;
                status = "Fail";
            }


            return status;

        }

        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    var Total_Donors = _dbContext.Donors.Count();
                    var Donors = from D in _dbContext.Donors
                                 join P in _dbContext.Patients
                                            on D.Patient_Id equals P.Patient_ID
                                            where (D.Donor_Id.ToString().Contains(searchValue) || P.mr_no_sequence.Contains(searchValue) || P.Full_Name.Contains(searchValue) || D.Donor_Name.Contains(searchValue))
                                            select new
                                            {
                                                Donor_Id = D.Donor_Id,
                                                mr_no_sequence = P.mr_no_sequence,
                                                Full_Name = P.Full_Name,
                                                Donor_Name = D.Donor_Name,
                                                D_Date = D.D_Date,
                                                Donor_Address = D.Donor_Address,
                                                D_Cell = D.D_Cell,
                                                ABO = _dbContext.GetDataValueName("ABO group", D.ABO),
                                                RH_Type = D.Rh_Type == "01" ? "Positive" : (D.Rh_Type == "02" ? "Negative" : ""),

                                            };



                    var FilteredCount = Donors.Count();
                    switch (sortColumn)
                    {
                        case "mr_no_sequence":
                            Donors = sortColumnDirection == "asc" ? Donors.OrderBy(a => a.mr_no_sequence) : Donors.OrderByDescending(a => a.mr_no_sequence);
                            break;
                        case "D_Date":
                            Donors = sortColumnDirection == "asc" ? Donors.OrderBy(a => a.D_Date) : Donors.OrderByDescending(a => a.D_Date);
                            break;
                        default:
                            Donors = Donors.OrderByDescending(a => a.Donor_Id);
                            break;
                    }


                    var Donors_List = Donors.Skip(start).Take(length).ToList();


                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Donors, data = Donors_List };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Donors list", ex);
            }
        }

        [WebMethod]
        public static string GetUserColumnPreferences()
        {
            try
            {
                string userId = AppConfig.UserID.ToString();
                string pageName = "DonorList";

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
                string pageName = "DonorList";

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