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






        //[WebMethod]
        //public static string GetRecord()
        //{
        //    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
        //    var Result = (from records in db.Donors
        //                  select new
        //                  {
        //                      records.Donor_Id,
        //                      // records.Donor_Name,
        //                      // records.Donor_No,
        //                      records.Donor_Name,
        //                      records.Donor_LastDonation,
        //                      Donation_Check = records.Donating_First_Time == true ? "First Time" : null,

        //                      records.Donor_Address,
        //                      ABO = db.GetDataValueName("ABO group", records.ABO),
        //                      RH_Type = records.Rh_Type == "01" ? "Positive" : (records.Rh_Type == "02" ? "Negative" : ""),
        //                      Mr_No = DBClass.GetMRNOBy_PatientID(Convert.ToInt32(records.Patient_Id)),

        //                      name = (from pt in db.Patients where pt.Patient_ID == records.Patient_Id select pt.Full_Name).FirstOrDefault(),
        //                      // Name = DBClass.getField("select full_name from patients where patient_id=" + records.Patient_Id),

        //                  }).OrderByDescending(x => x.Donor_Id).Take(200).ToList();

        //    return (new JavaScriptSerializer()).Serialize(Result);
        //}

    }
}