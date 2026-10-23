using System;
using System.Linq;
using System.Text;
using static PMS.Modules.Lab.HistoryFormPrint;

namespace PMS.Modules.Lab
{
    /// <summary>A4 print of one X-Ray History form, laid out like the paper form.</summary>
    public partial class XRayHistoryPrint : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            Response.ContentType = "text/html";
            int id;
            if (!int.TryParse(Request.QueryString["ID"], out id)) { Response.Write(Message("Invalid record number")); return; }
            if (!SessionAlive(Session)) { Response.Write(Message("Your session has expired. Please log in again and reopen the print.")); return; }

            using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                int companyId = AppConfig.Company_ID;
                var r = db.Lab_XRay_Histories.FirstOrDefault(x => x.XRay_ID == id && x.Company_ID == companyId);
                if (r == null) { Response.Write(Message("X-ray history record not found")); return; }

                var p = db.Reg_patients.Where(x => x.pat_id == r.Patient_ID).Select(x => new { x.Full_Name, x.mr_no_sequence, x.Gender }).FirstOrDefault();
                string gender = p == null ? "" : (db.ExecuteQuery<string>("select dbo.GetDataValueName('Gender', {0})", p.Gender ?? "").FirstOrDefault() ?? p.Gender ?? "");
                string technician = r.Technician_ID == null ? "" : db.HR_Employees.Where(x => x.Emp_ID == r.Technician_ID).Select(x => x.Emp_Name).FirstOrDefault();
                string company, phone;
                Company(db, out company, out phone);

                // registration stores M/F or Male/Female; anything else counts as Other
                string g = (gender ?? "").Trim().ToUpperInvariant();
                bool male = g == "M" || g == "MALE", female = g == "F" || g == "FEMALE";

                var b = new StringBuilder();
                b.Append(Header(company, phone, "X-Ray History Form"));

                b.Append("<div class=\"sec\">Patient Information:</div>");
                b.Append("<div class=\"row\">" + Line("Full Name:", p == null ? "" : p.Full_Name, 300) + "</div>");
                b.Append("<div class=\"row\"><b>Gender:</b> " + Check("Male", male) + Check("Female", female) + Check("Other", !male && !female && g != "") + "</div>");
                b.Append("<div class=\"row\">" + Line("Patient ID/MR Number:", p == null ? "" : p.mr_no_sequence, 200) + "</div>");
                b.Append("<div class=\"row\"><b>Pregnancy Status</b> " + YesNo(r.Is_Pregnant) + "</div>");

                b.Append("<div class=\"sec\">Referring Physician:</div>");
                b.Append("<div class=\"row\">" + Line("Name:", r.Referring_Doctor, 330) + "</div>");
                b.Append("<div class=\"row\">" + Line("Specialty:", r.Referring_Specialty, 310) + "</div>");

                b.Append("<div class=\"sec\">Reason for X-ray:</div>");
                b.Append("<div style=\"margin-left:4px;line-height:2\">" +
                         Check("Pain/Discomfort", r.Reason_Pain) + "<br>" + Check("Injury", r.Reason_Injury) + "<br>" +
                         Check("Follow-up of Previous Condition", r.Reason_FollowUp) + "<br>" + Check("Pre-surgical Imaging", r.Reason_PreSurgical) + "<br>" +
                         Check("Routine Screening", r.Reason_Screening) + "<br>" +
                         "<span class=\"ck\">" + Box(!string.IsNullOrEmpty(r.Reason_Other)) + " Other: <span class=\"ul\" style=\"min-width:230px\">" + E(r.Reason_Other) + "</span></span></div>");

                b.Append("<div class=\"row\" style=\"margin-top:14px\"><b>Have you had any X-rays or similar imaging tests in the past?</b> " + YesNo(r.Previous_Imaging) + "</div>");

                b.Append("<div class=\"row\" style=\"margin-top:22px\">" + Line("Technician's Name:", technician, 260) + Line("Date:", D(r.Exam_Date), 120) + "</div>");
                b.Append("<div class=\"row\" style=\"flex-wrap:nowrap\"><b style=\"white-space:nowrap\">Comments/Notes:</b><span class=\"ul\" style=\"flex:1\">" + Multi(r.Comments) + "</span></div>");

                Response.Write(Document("X-Ray History - " + (p == null ? "" : p.Full_Name), b.ToString()));
            }
        }
    }
}
