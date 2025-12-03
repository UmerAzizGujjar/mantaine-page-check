using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.PatientManagement
{
    public partial class OPD_Refund : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
            
        

        
        
        [WebMethod]
        public static string GetPatientByOPDNo(string opdNo)
        {
            if (string.IsNullOrWhiteSpace(opdNo) || !long.TryParse(opdNo, out long opd))
                return new JavaScriptSerializer().Serialize(new List<object>());

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                try
                {
                    var query = from pat in db.Patients
                                where pat.Opd_No == opd
                                select new
                                {
                                    pat.Opd_No,
                                    pat.Patient_ID,
                                    pat.Patient_No,
                                    pat.Full_Name,
                                    pat.Father_Name,
                                    pat.NIC,
                                    pat.Gender,
                                    pat.Mobile1,
                                    pat.Permanent_Address,
                                    pat.Age_years,
                                    Created_Time = pat.Created_Time,
                                    pat.Email,
                                    pat.City,
                                    pat.Province,
                                    pat.Profession,
                                    pat.Doctor_ID,
                                    pat.Doctor_Amount,
                                    pat.Hospital_share,
                                    pat.Actual_amount,
                                    Department = db.GetDataValueName("Patient Main Category", pat.Patient_Main_Category),
                                    Patient_Type = db.GetDataValueName("Patient Type", pat.Patient_Type)
                                };

                    var list = query.ToList();
                    var result = list.Select(p => new
                    {
                        p.Opd_No,
                        p.Patient_ID,
                        p.Patient_No,
                        p.Full_Name,
                        p.Father_Name,
                        p.NIC,
                        p.Gender,
                        p.Mobile1,
                        p.Permanent_Address,
                        p.Age_years,
                        p.Email,
                        p.City,
                        p.Province,
                        p.Profession,
                        p.Doctor_ID,
                        Doctor_Amount = p.Doctor_Amount?.ToString("0.00") ?? "0.00",
                        Hospital_share = p.Hospital_share?.ToString("0.00") ?? "0.00",
                        Actual_amount = p.Actual_amount?.ToString("0.00") ?? "0.00",

                        Creation_Date = p.Created_Time.HasValue
                            ? p.Created_Time.Value.ToString("dd-MMM-yyyy")
                            : "",
                        p.Department,
                        p.Patient_Type
                    }).ToList();

                    return new JavaScriptSerializer().Serialize(result);
                }
                catch (Exception ex)
                {
                    return new JavaScriptSerializer().Serialize(new List<object>());
                }
            }
        }

        //[WebMethod]
        //public static string SaveRefund(RefundModel data)
        //{
        //    try
        //    {
        //        DataBaseDataContext db = new DataBaseDataContext();
        //        {
        //            OPD_Refund refund = new OPD_Refund
        //            {
        //                OPD_No = Convert.ToInt64(data.OPD_No),
        //                pat_id = Convert.ToInt32(data.pat_id),
        //                Refund_Date = Convert.ToDateTime(data.Refund_Date),

        //                Hospital_Refund = data.Hospital_Refund,
        //                Doctor_Refund = data.Doctor_Refund,
        //                Refund_Amount = data.Hospital_Refund + data.Doctor_Refund,

        //                Remarks = data.Remarks,
        //                Created_By = AppConfig.UserID,
        //                Creation_Date = DateTime.Now
        //            };

        //            db.OPD_Refunds.InsertOnSubmit(refund);
        //            db.SubmitChanges();

        //            return "Success";
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        return "Error: " + ex.Message;
        //    }
        //}
        //public class RefundModel
        //{
        //    public string OPD_No { get; set; }
        //    public string pat_id { get; set; }
        //    public string Refund_Date { get; set; }
        //    public decimal Refund_Amount { get; set; }
        //    public decimal Doctor_Refund { get; set; }
        //    public decimal Hospital_Refund { get; set; }
        //    public string Remarks { get; set; }
        //}
    }
}