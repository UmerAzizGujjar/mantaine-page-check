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
                                    pat_id = pat.Reg_PatId,
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
                        pat_id = p.pat_id, 
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

        [WebMethod]
        public static string SaveRefund(RefundModel data)
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    decimal totalRefund = data.Hospital_Refund + data.Doctor_Refund;
                    DateTime refundDate;

                    if (string.IsNullOrWhiteSpace(data.Refund_Date) ||
                        !DateTime.TryParse(data.Refund_Date, out refundDate))
                    {
                        refundDate = DateTime.Now;
                    }

                    if (string.IsNullOrEmpty(data.Refund_ID))
                    {
                        PMS.OPD_Refund refund = new PMS.OPD_Refund
                        {
                            OPD_No = string.IsNullOrEmpty(data.OPD_No) ? 0 : Convert.ToInt64(data.OPD_No),
                            pat_id = string.IsNullOrEmpty(data.pat_id) ? 0 : Convert.ToInt32(data.pat_id),
                            Refund_Date = refundDate,
                            Hospital_Refund = data.Hospital_Refund,
                            Doctor_Refund = data.Doctor_Refund,
                            Refund_Amount = totalRefund,
                            Remarks = data.Remarks,
                            Created_By = AppConfig.UserID,
                            Creation_Date = DateTime.Now
                        };

                        db.OPD_Refunds.InsertOnSubmit(refund);
                    }
                    else
                    {
                        if (!int.TryParse(data.Refund_ID, out int refundId))
                            return "Error: Invalid refund ID.";

                        var refund = db.OPD_Refunds.FirstOrDefault(r => r.Refund_ID == refundId);
                        if (refund == null)
                            return "Error: Refund record not found.";

                        refund.OPD_No = string.IsNullOrEmpty(data.OPD_No) ? 0 : Convert.ToInt64(data.OPD_No);
                        refund.pat_id = string.IsNullOrEmpty(data.pat_id) ? 0 : Convert.ToInt32(data.pat_id);
                        refund.Refund_Date = refundDate;
                        refund.Hospital_Refund = data.Hospital_Refund;
                        refund.Doctor_Refund = data.Doctor_Refund;
                        refund.Refund_Amount = totalRefund;
                        refund.Remarks = data.Remarks;
                        refund.Update_By = AppConfig.UserID;
                        refund.Update_Time = DateTime.Now;
                    }

                    db.SubmitChanges();
                    return "Success";
                }
            }
            catch (Exception ex)
            {
                return "Error: " + ex.Message;
            }
        }

        public class RefundModel
        {
            public string Refund_ID { get; set; }
            public string OPD_No { get; set; }
            public string pat_id { get; set; }
            public string Refund_Date { get; set; }
            public decimal Refund_Amount { get; set; }
            public decimal Doctor_Refund { get; set; }
            public decimal Hospital_Refund { get; set; }
            public string Remarks { get; set; }
        }

        [WebMethod]
        public static string GetOPDPatient(string refundID)
        {
            if (string.IsNullOrWhiteSpace(refundID) || !int.TryParse(refundID, out int refundId))
                return new JavaScriptSerializer().Serialize(new { });

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var refund = db.OPD_Refunds
                              .Where(r => r.Refund_ID == refundId)
                              .FirstOrDefault();

                if (refund == null)
                    return new JavaScriptSerializer().Serialize(new { });

                var patient = (from pat in db.Patients
                               where pat.Reg_PatId == refund.pat_id
                               select new
                               {
                                   Patient_ID = refund.pat_id, 
                                   Patient_No = pat.Patient_No,
                                   Full_Name = pat.Full_Name,
                                   Mobile1 = pat.Mobile1,
                                   Gender = pat.Gender,
                                   Age_years = pat.Age_years,
                                   Address = pat.Permanent_Address,
                                   Entry_Date = pat.Created_Time,
                                   department = db.GetDataValueName("Patient Main Category", pat.Patient_Main_Category),
                                   Patient_Main_Category = db.GetDataValueName("Patient Type", pat.Patient_Type),
                                   OPD_No = pat.Opd_No,
                                   Doctor_Amount = pat.Doctor_Amount,
                                   Hospital_share = pat.Hospital_share,
                                   Actual_amount = pat.Actual_amount
                               }).FirstOrDefault();

                var result = new
                {
                    Refund_ID = refund.Refund_ID,
                    Patient_ID = refund.pat_id,
                    Patient_No = patient?.Patient_No,
                    Full_Name = patient?.Full_Name ?? "Unknown Patient",
                    Mobile1 = patient?.Mobile1 ?? "",
                    Gender = patient?.Gender ?? "",
                    Age_years = patient?.Age_years,
                    Address = patient?.Address ?? "",
                    Entry_Date = refund.Refund_Date ?? refund.Creation_Date, 
                    department = patient?.department ?? "",
                    Patient_Main_Category = patient?.Patient_Main_Category ?? "",
                    Remarks = refund.Remarks ?? "",
                    Advance_Date = refund.Refund_Date ?? refund.Creation_Date,
                    Advance_Amount = refund.Refund_Amount,
                    OPD_No = refund.OPD_No,
                    Hospital_Refund = refund.Hospital_Refund,
                    Doctor_Refund = refund.Doctor_Refund,
                    Doctor_Amount = patient?.Doctor_Amount,
                    Hospital_share = patient?.Hospital_share,
                    Actual_amount = patient?.Actual_amount
                };

                return new JavaScriptSerializer().Serialize(result);
            }
        }
    }
}