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
    public partial class EmergencyRefund : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static string GetPatientByEmergencyNo(string emergencyNo)
        {
            if (string.IsNullOrWhiteSpace(emergencyNo) || !long.TryParse(emergencyNo, out long emergency))
                return new JavaScriptSerializer().Serialize(new List<object>());

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                try
                {
                    // Get data from Emergency table and join with Patient table
                    var query = from emg in db.Emergencies
                                join pat in db.Reg_patients on emg.Reg_PatId equals pat.pat_id
                                where emg.Emergency_No == emergency
                                select new
                                {
                                    emg.Emergency_No,
                                    emg.Emer_id,
                                    emg.Reg_PatId,
                                    emg.Doctor_Amount,
                                    emg.Hospital_share,
                                    emg.Actual_amount,
                                    emg.Is_Refund,
                                    emg.Doctor_ID,
                                    pat.Patient_No,
                                    pat.Full_Name,
                                    pat.Gender,
                                    pat.Mobile1,
                                    pat.Permanent_Address,
                                    pat.Age_years,
                                    emg.Created_Time,
                                    emg.Patient_Main_Category,
                                    emg.Patient_Type
                                };

                    var list = query.ToList();

                    var result = list.Select(p => new
                    {
                        p.Emergency_No,
                        Reg_PatId = p.Reg_PatId,
                        p.Patient_No,
                        p.Full_Name,
                        p.Gender,
                        p.Mobile1,
                        p.Permanent_Address,
                        p.Age_years,
                        Doctor_Amount = p.Doctor_Amount?.ToString("0.00") ?? "0.00",
                        Hospital_share = p.Hospital_share?.ToString("0.00") ?? "0.00",
                        Actual_amount = p.Actual_amount?.ToString("0.00") ?? "0.00",
                        Creation_Date = p.Created_Time.HasValue
                            ? p.Created_Time.Value.ToString("dd-MMM-yyyy")
                            : "",
                        Department = db.GetDataValueName("Patient Main Category", p.Patient_Main_Category),
                        Patient_Type = db.GetDataValueName("Patient Type", p.Patient_Type),
                        Is_Refund = p.Is_Refund ?? false
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
                    long emergencyNo = string.IsNullOrEmpty(data.Emergency_No) ? 0 : Convert.ToInt64(data.Emergency_No);

                    if (string.IsNullOrWhiteSpace(data.Patient_ID))
                        return "Error: Patient ID is required.";
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
                        // Create new Emergency Refund
                        PMS.Emergency_refund refund = new PMS.Emergency_refund
                        {
                            emergency_No = emergencyNo,
                            pat_id = regPatId,
                            
                            Refund_Date = refundDate,
                            Hospital_Refund = data.Hospital_Refund,
                            Doctor_Refund = data.Doctor_Refund,
                            Refund_Amount = totalRefund,
                            Remarks = data.Remarks,
                            Created_By = AppConfig.UserID,
                            Creation_Date = DateTime.Now
                        };

                        // Update emergency record refund status
                        var emergency = db.Emergencies.FirstOrDefault(e => e.Emergency_No == emergencyNo);
                        if (emergency != null)
                        {
                            emergency.Is_Refund = true;
                        }

                        db.Emergency_refunds.InsertOnSubmit(refund);
                        db.SubmitChanges();

                        // Call stored procedure for voucher generation if needed
                        //Guid userId = AppConfig.UserID;
                        //var result = db.SpApprove_EmergencyRefund(patientID, emergencyNo, userId).FirstOrDefault();

                        //if (result != null && !string.IsNullOrEmpty(result.Message))
                        //{
                        //    if (!result.Message.Contains("successfully"))
                        //    {
                        //        return "Refund saved, but voucher issue: " + result.Message;
                        //    }
                        //}
                    }
                    else
                    {
                        // Update existing refund
                        if (!int.TryParse(data.Refund_ID, out int refundId))
                            return "Error: Invalid refund ID.";

                        var refund = db.Emergency_refunds.FirstOrDefault(r => r.Refund_ID == refundId);
                        if (refund == null)
                            return "Error: Refund not found.";

                        refund.emergency_No = emergencyNo;
                        refund.pat_id = regPatId;
                     
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
            public string Emergency_No { get; set; }
            public string Patient_ID { get; set; }
            public string Reg_PatId { get; set; }
            public string Refund_Date { get; set; }
            public decimal Hospital_Refund { get; set; }
            public decimal Doctor_Refund { get; set; }
            public string Remarks { get; set; }
        }

        [WebMethod]
        public static string GetEmergencyPatient(string refundID)
        {
            if (string.IsNullOrWhiteSpace(refundID) || !int.TryParse(refundID, out int refundId))
                return new JavaScriptSerializer().Serialize(new { });

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var refund = db.Emergency_refunds
                              .Where(r => r.Refund_ID == refundId)
                              .FirstOrDefault();

                if (refund == null)
                    return new JavaScriptSerializer().Serialize(new { });

                // Get data from Emergency table
                var emergency = (from emg in db.Emergencies
                                 join pat in db.Reg_patients on emg.Reg_PatId equals pat.pat_id
                                 where emg.Emergency_No == refund.emergency_No
                                 select new
                                 {
                                     emg.Emergency_No,
                                     emg.Reg_PatId,
                                     emg.Emer_id,
                                     emg.Doctor_Amount,
                                     emg.Hospital_share,
                                     emg.Actual_amount,
                                     pat.Patient_No,
                                     pat.Full_Name,
                                     pat.Mobile1,
                                     pat.Gender,
                                     pat.Age_years,
                                     pat.Permanent_Address,
                                     emg.Created_Time,
                                     emg.Patient_Main_Category,
                                     emg.Patient_Type
                                 }).FirstOrDefault();

                var result = new
                {
                    Refund_ID = refund.Refund_ID,
                    Patient_ID = refund.pat_id,
                    Reg_PatId = refund.pat_id,
                    Patient_No = emergency?.Patient_No,
                    Full_Name = emergency?.Full_Name ?? "Unknown Patient",
                    Mobile1 = emergency?.Mobile1 ?? "",
                    Gender = emergency?.Gender ?? "",
                    Age_years = emergency?.Age_years,
                    Address = emergency?.Permanent_Address ?? "",
                    Entry_Date = refund.Refund_Date ?? refund.Creation_Date,
                    department = db.GetDataValueName("Patient Main Category", emergency?.Patient_Main_Category),
                    Patient_Main_Category = db.GetDataValueName("Patient Type", emergency?.Patient_Type),
                    Remarks = refund.Remarks ?? "",
                    Refund_Date = refund.Refund_Date ?? refund.Creation_Date,
                    Refund_Amount = refund.Refund_Amount,
                    Emergency_No = refund.emergency_No,
                    Hospital_Refund = refund.Hospital_Refund,
                    Doctor_Refund = refund.Doctor_Refund,
                    Doctor_Amount = emergency?.Doctor_Amount,
                    Hospital_share = emergency?.Hospital_share,
                    Actual_amount = emergency?.Actual_amount
                };

                return new JavaScriptSerializer().Serialize(result);
            }
        }
    }
}