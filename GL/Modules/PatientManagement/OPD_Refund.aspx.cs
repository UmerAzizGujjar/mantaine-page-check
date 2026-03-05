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
                                    Patient_ID = pat.Patient_ID,      
                                    Reg_PatId = pat.Reg_PatId,
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
                                    pat.doc_share,
                                    pat.Hospital_share,
                                    pat.Actual_amount,
                                    Department = db.GetDataValueName("Patient Main Category", pat.Patient_Main_Category),
                                    Patient_Type = db.GetDataValueName("Patient Type", pat.Patient_Type)
                                };

                    var list = query.ToList();

                    var result = list.Select(p => new
                    {
                        p.Opd_No,
                        Patient_ID = p.Patient_ID,
                        Reg_PatId = p.Reg_PatId,
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
                        Doctor_Amount = p.doc_share ?? "0.00",
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
                    long opdNo = string.IsNullOrEmpty(data.OPD_No) ? 0 : Convert.ToInt64(data.OPD_No);
                    if (string.IsNullOrWhiteSpace(data.Patient_ID))
                        return "Error: OPD Patient is required.";
                    int patientID = Convert.ToInt32(data.Patient_ID);
                    if (string.IsNullOrWhiteSpace(data.Reg_PatId))
                        return "Error: Registered Patient ID is required.";
                    int regPatId = Convert.ToInt32(data.Reg_PatId);
                    var regPatient = db.Reg_patients.FirstOrDefault(r => r.pat_id == regPatId);
                    if (regPatient == null)
                        return $"Error: Registered Patient with ID {regPatId} does not exist.";
                    DateTime refundDate = DateTime.Now;
                    if (!string.IsNullOrWhiteSpace(data.Refund_Date))
                        DateTime.TryParse(data.Refund_Date, out refundDate);
                    decimal totalRefund = data.Hospital_Refund + data.Doctor_Refund;

                    if (string.IsNullOrEmpty(data.Refund_ID))
                    {
                        PMS.OPD_Refund refund = new PMS.OPD_Refund
                        {
                            OPD_No = opdNo,
                            pat_id = patientID,
                            Reg_PatId = regPatId,
                            Refund_Date = refundDate,
                            Hospital_Refund = data.Hospital_Refund,
                            Doctor_Refund = data.Doctor_Refund,
                            Refund_Amount = totalRefund,
                            Remarks = data.Remarks,
                            Created_By = AppConfig.UserID,
                            Creation_Date = DateTime.Now
                        };
                        db.OPD_Refunds.InsertOnSubmit(refund);
                        db.SubmitChanges();

                        Guid userId = AppConfig.UserID;
                        var result = db.SpApprove_OPDRefund(patientID, userId).FirstOrDefault();

                        if (result != null && !string.IsNullOrEmpty(result.Message))
                        {
                            if (!result.Message.Contains("successfully"))
                            {
                                return "Refund saved, but voucher issue: " + result.Message;
                            }
                        }
                    }
                    else
                    {
                        if (!int.TryParse(data.Refund_ID, out int refundId))
                            return "Error: Invalid refund ID.";

                        var refund = db.OPD_Refunds.FirstOrDefault(r => r.Refund_ID == refundId);
                        if (refund == null)
                            return "Error: Refund not found.";

                        refund.OPD_No = opdNo;
                        refund.pat_id = patientID;
                        refund.Reg_PatId = regPatId;
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
            public string Patient_ID { get; set; }
            public string Reg_PatId { get; set; }
            public string Refund_Date { get; set; }
            public decimal Hospital_Refund { get; set; }
            public decimal Doctor_Refund { get; set; }
            public string Remarks { get; set; }
            public static Guid UserID { get; set; }
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
                               where pat.Patient_ID == refund.pat_id  
                               select new
                               {
                                   pat.Patient_No,
                                   pat.Full_Name,
                                   pat.Mobile1,
                                   pat.Gender,
                                   pat.Age_years,
                                   pat.Permanent_Address,
                                   pat.Created_Time,
                                   department = db.GetDataValueName("Patient Main Category", pat.Patient_Main_Category),
                                   Patient_Main_Category = db.GetDataValueName("Patient Type", pat.Patient_Type),
                                   pat.Opd_No,
                                   pat.Doctor_Amount,
                                   pat.Hospital_share,
                                   pat.Actual_amount
                               }).FirstOrDefault();

                var result = new
                {
                    Refund_ID = refund.Refund_ID,
                    Patient_ID = refund.pat_id,    
                    Reg_PatId = refund.Reg_PatId,     
                    Patient_No = patient?.Patient_No,
                    Full_Name = patient?.Full_Name ?? "Unknown Patient",
                    Mobile1 = patient?.Mobile1 ?? "",
                    Gender = patient?.Gender ?? "",
                    Age_years = patient?.Age_years,
                    Address = patient?.Permanent_Address ?? "",
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