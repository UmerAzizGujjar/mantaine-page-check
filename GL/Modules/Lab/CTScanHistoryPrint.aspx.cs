using System;
using System.Linq;
using System.Text;
using static PMS.Modules.Lab.HistoryFormPrint;

namespace PMS.Modules.Lab
{
    /// <summary>A4 print of one CT Patient History form, laid out like the paper form.</summary>
    public partial class CTScanHistoryPrint : System.Web.UI.Page
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
                var r = db.Lab_CT_Histories.FirstOrDefault(x => x.CT_ID == id && x.Company_ID == companyId);
                if (r == null) { Response.Write(Message("CT history record not found")); return; }

                var p = db.Reg_patients.Where(x => x.pat_id == r.Patient_ID).Select(x => new { x.Full_Name, x.mr_no_sequence, x.Gender }).FirstOrDefault();
                string gender = p == null ? "" : (db.ExecuteQuery<string>("select dbo.GetDataValueName('Gender', {0})", p.Gender ?? "").FirstOrDefault() ?? p.Gender ?? "");
                string radiologist = r.Radiologist_ID == null ? "" : db.HR_Employees.Where(x => x.Emp_ID == r.Radiologist_ID).Select(x => x.Emp_Name).FirstOrDefault();
                string company, phone;
                Company(db, out company, out phone);

                var b = new StringBuilder();
                b.Append(Header(company, phone, "CT Patient History Form"));
                b.Append("<div class=\"row\">" + Line("Name:", p == null ? "" : p.Full_Name, 190) + Line("Gender:", gender, 70) + Line("Medical Record #:", p == null ? "" : p.mr_no_sequence, 150) + "</div>");
                b.Append("<div class=\"row\">" + Line("Referring Dr.:", r.Referring_Doctor, 190) + Line("Date:", D(r.Exam_Date), 100) + "</div>");
                b.Append("<div class=\"row\"><span><b>Any chance, you are pregnant?</b> " + YesNo(r.Is_Pregnant) + "</span>" + Line("LMP:", D(r.LMP), 170) + "</div>");

                b.Append("<div class=\"grid2\"><div>");
                b.Append(Question("Chief complaint:", r.Chief_Complaint));
                b.Append(Question("Prior radiological study:", r.Prior_Radiological_Study));
                b.Append(Question("Surgical history:", r.Surgical_History));
                b.Append(Question("Medications you&rsquo;re taking:", r.Medications));
                b.Append("</div><div>");
                b.Append("<div class=\"q bul\">Do you have or have you ever had cancer?<div style=\"margin:3px 0 0 16px\">" + YesNo(r.Had_Cancer) + "</div></div>");
                b.Append("<div class=\"q\">If yes, what type of treatment did you receive?<div style=\"margin:4px 0 0 8px\">" +
                         Check("Chemotherapy", r.Tx_Chemotherapy) + Check("Operation", r.Tx_Operation) + "<br>" + Check("Radiation Therapy", r.Tx_Radiation) + "</div></div>");
                b.Append("<div class=\"q\">Are you finished with treatment? " + YesNo(r.Treatment_Finished) + "</div>");
                b.Append("<div class=\"q bul\">Do you have any electronic medical device?<div style=\"margin:3px 0 0 16px\">" + YesNo(r.Has_Electronic_Device) + "</div></div>");
                b.Append("<div class=\"q small\">(Ex: Pacemaker, Defibrillator, Neuro-stimulator, Retinal implant, Drug infusion pump, Insulin pump, Cochlear implant, etc.)</div>");
                b.Append("<div class=\"q\">If yes enlist them:<div class=\"ans\" style=\"min-height:34px\">" + Multi(r.Electronic_Devices) + "</div></div>");
                b.Append("<div class=\"q bul\">Do you have asthma? &nbsp; " + YesNo(r.Has_Asthma) + "</div>");
                b.Append("<div class=\"q bul\">Do you have allergies? &nbsp; " + YesNo(r.Has_Allergies) + "</div>");
                b.Append("<div class=\"q bul\">Smoke? " + YesNo(r.Is_Smoker) + "<div class=\"small\" style=\"margin-left:16px;font-style:normal\">If yes, details: " + E(r.Smoke_Details) + "</div></div>");
                b.Append("</div></div>");

                b.Append("<div class=\"row\" style=\"justify-content:space-between\">" + Line("Name:", r.Patient_Sign_Name, 230) + Line("Signature:", "", 220) + "</div>");

                b.Append("<div class=\"boxhd\">RADIOLOGIST</div>");
                b.Append("<div class=\"row\" style=\"flex-wrap:nowrap\"><b style=\"white-space:nowrap\">Additional Notes:</b><span class=\"ul\" style=\"flex:1\">" + Multi(r.Radiologist_Notes) + "</span></div>");
                b.Append("<div class=\"row\" style=\"justify-content:space-between\">" + Line("Name:", radiologist, 150) + Line("Signature:", "", 140) + Line("Date/Time:", DT(r.Radiologist_Date), 200) + "</div>");

                b.Append("<div class=\"dash\"></div><div class=\"note\">Consultant use only</div>");
                b.Append("<div class=\"row\"><b>Report correlate to clinical diagnosis:</b> " +
                         Check("Yes/concordant", r.Report_Correlation == "Concordant") + Check("No/discordant", r.Report_Correlation == "Discordant") + "</div>");

                Response.Write(Document("CT Patient History - " + (p == null ? "" : p.Full_Name), b.ToString()));
            }
        }

        private static string Question(string label, string answer)
        {
            return "<div class=\"q bul\">" + label + "<div class=\"ans\">" + Multi(answer) + "</div></div>";
        }
    }
}
