using System;
using System.Linq;
using System.Text;
using static PMS.Modules.Lab.HistoryFormPrint;

namespace PMS.Modules.Lab
{
    /// <summary>A4 print of one Mammography Patient History form, laid out like the paper form.</summary>
    public partial class MammographyHistoryPrint : System.Web.UI.Page
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
                var r = db.Lab_Mammography_Histories.FirstOrDefault(x => x.Mammo_ID == id && x.Company_ID == companyId);
                if (r == null) { Response.Write(Message("Mammography record not found")); return; }

                var p = db.Reg_patients.Where(x => x.pat_id == r.Patient_ID).Select(x => new { x.Full_Name, x.mr_no_sequence, x.Age_years, x.Gender }).FirstOrDefault();
                string gender = p == null ? "" : (db.ExecuteQuery<string>("select dbo.GetDataValueName('Gender', {0})", p.Gender ?? "").FirstOrDefault() ?? p.Gender ?? "");
                string technologist = r.Technologist_ID == null ? "" : db.HR_Employees.Where(x => x.Emp_ID == r.Technologist_ID).Select(x => x.Emp_Name).FirstOrDefault();
                string company, phone;
                Company(db, out company, out phone);

                var b = new StringBuilder();
                b.Append(Header(company, phone, "Mammography Patient History Form"));
                b.Append("<div class=\"row\" style=\"justify-content:flex-end;margin-top:-4px\">" + Line("Medical Record #:", p == null ? "" : p.mr_no_sequence, 150) + "</div>");
                b.Append("<div class=\"row\">" + Line("Name:", p == null ? "" : p.Full_Name, 260) + Line("Age:", p == null ? "" : p.Age_years, 70) + "</div>");
                b.Append("<div class=\"row\">" + Line("Gender:", gender, 80) + Line("Referring Dr.:", r.Referring_Doctor, 260) + "</div>");
                b.Append("<div class=\"row\" style=\"justify-content:space-between\"><span><b>Any chance you are pregnant?</b> " + YesNo(r.Is_Pregnant) + "</span>" +
                         "<span><b>Married:</b> " + YesNo(r.Is_Married) + "</span></div>");
                b.Append("<div class=\"row\" style=\"justify-content:space-between\">" + Line("How many children?", r.No_Of_Children.HasValue ? r.No_Of_Children.Value.ToString() : "", 110) +
                         "<span><b>Are you breastfeeding?</b> " + YesNo(r.Is_Breastfeeding) + "</span></div>");

                b.Append("<div class=\"sec\">Why are you having this mammogram?</div>");
                string pain = r.Reason_Pain == true && !string.IsNullOrEmpty(r.Pain_Type) ? " &ndash; " + E(r.Pain_Type) : "";
                b.Append("<table class=\"t\" style=\"text-align:left\"><tbody>" +
                         Pair(Check("Screening", r.Reason_Screening), Check("3 or 6 Months Follow-Up", r.Reason_FollowUp)) +
                         Pair(Check("Lump or Thickening", r.Reason_Lump), Check("Nipple Discharge", r.Reason_Nipple_Discharge) + " (color of discharge " + Underline(r.Nipple_Discharge_Color, 80) + ")") +
                         Pair(Check("Skin Changes or Retraction", r.Reason_Skin_Changes), Check("Breast Implant problem", r.Reason_Implant)) +
                         Pair(Check("Pain (Chronic or New)", r.Reason_Pain) + pain, "<span class=\"ck\">" + Box(!string.IsNullOrEmpty(r.Reason_Other)) + " Other (please specify " + Underline(r.Reason_Other, 150) + ")</span>") +
                         "</tbody></table>");

                b.Append("<div style=\"display:flex;gap:16px;align-items:flex-start\"><div style=\"flex:1\">");
                b.Append("<div class=\"row\"><b>Have you ever had a mammogram?</b> " + YesNo(r.Previous_Mammogram, "YES", "NO") + "</div>");
                b.Append("<div class=\"row\"><b>Have you ever been diagnosed with breast cancer?</b> " + YesNo(r.Diagnosed_Breast_Cancer, "YES", "NO") + "</div>");
                b.Append("<div class=\"row\"><b>Have your family been diagnosed with breast cancer?</b> " + YesNo(r.Family_Breast_Cancer, "YES", "NO") + "</div>");
                b.Append("</div><div style=\"width:190px;padding:6px 10px;border:1px solid #555\"><b>Menstrual History</b>" +
                         "<div class=\"row\">" + Line("LMP", D(r.LMP), 110) + "</div><div class=\"row\">" + Line("Menopause", r.Menopause, 80) + "</div></div></div>");

                b.Append("<table class=\"t\"><thead><tr><th></th><th>Myself</th><th>Mother</th><th>Sister</th><th>Daughter</th><th>Aunt</th><th>Grandmother</th></tr></thead><tbody>" +
                         "<tr><td style=\"text-align:left\"><b>Diagnosed</b></td>" + Cell(r.Ca_Myself) + Cell(r.Ca_Mother) + Cell(r.Ca_Sister) + Cell(r.Ca_Daughter) + Cell(r.Ca_Aunt) + Cell(r.Ca_Grandmother) + "</tr>" +
                         "<tr><td style=\"text-align:left\"><b>At What Age?</b></td><td>" + E(r.Ca_Myself_Age) + "</td><td>" + E(r.Ca_Mother_Age) + "</td><td>" + E(r.Ca_Sister_Age) + "</td><td>" +
                         E(r.Ca_Daughter_Age) + "</td><td>" + E(r.Ca_Aunt_Age) + "</td><td>" + E(r.Ca_Grandmother_Age) + "</td></tr></tbody></table>");

                b.Append("<div class=\"row\"><b>Have you ever had a breast surgery or treatment?</b> " + YesNo(r.Breast_Surgery, "YES", "NO") + "</div>");
                b.Append("<div class=\"row\"><b>If yes then:</b> " + Check("Mastectomy", r.Surgery_Mastectomy) + Check("Lumpectomy", r.Surgery_Lumpectomy) + "</div>");
                bool right = r.Surgery_Side == "Right" || r.Surgery_Side == "Both", left = r.Surgery_Side == "Left" || r.Surgery_Side == "Both";
                b.Append("<table class=\"t\" style=\"width:60%\"><thead><tr><th colspan=\"2\">MASTECTOMY / LUMPECTOMY</th></tr></thead><tbody>" +
                         "<tr><td>Right breast " + Box(right) + "</td><td>Left breast " + Box(left) + "</td></tr></tbody></table>");

                b.Append("<div class=\"row\"><b>Do you, or have you used hormones replacement therapy?</b> " + YesNo(r.HRT_Used, "YES", "NO") + "</div>");
                b.Append("<div class=\"row\" style=\"margin-left:16px\">" + Check("Estrogen", r.HRT_Estrogen) + Check("Provera", r.HRT_Provera) + Check("Premarin", r.HRT_Premarin) +
                         Check("Prempro", r.HRT_Prempro) + Check("Tamoxifen", r.HRT_Tamoxifen) +
                         "<span class=\"ck\">" + Box(!string.IsNullOrEmpty(r.HRT_Other)) + " Other " + Underline(r.HRT_Other, 120) + "</span></div>");

                b.Append("<div class=\"row\"><b>Would you like referrer to a surgeon?</b> " + YesNo(r.Refer_To_Surgeon) + "</div>");
                b.Append("<div class=\"row\"><b>Would you like a reminder for next mammogram?</b> " + YesNo(r.Reminder_Next) + "</div>");
                b.Append("<div class=\"row\"><b>Phone number / email:</b> " + YesNo(r.Contact_By_Phone_Email) + "</div>");
                b.Append("<div class=\"row\" style=\"justify-content:space-between\">" + Line("Phone Number:", r.Contact_Phone, 180) + Line("Email:", r.Contact_Email, 220) + "</div>");
                if (!string.IsNullOrWhiteSpace(r.Remarks))
                    b.Append("<div class=\"row\"><b>Remarks:</b> <span>" + Multi(r.Remarks) + "</span></div>");
                b.Append("<div class=\"row\" style=\"justify-content:space-between;margin-top:14px\">" + Line("Technologist:", technologist, 240) + Line("Date:", D(r.Exam_Date), 140) + "</div>");

                Response.Write(Document("Mammography Patient History - " + (p == null ? "" : p.Full_Name), b.ToString(), true));
            }
        }

        private static string Pair(string a, string b) { return "<tr><td style=\"text-align:left;width:50%\">" + a + "</td><td style=\"text-align:left\">" + b + "</td></tr>"; }
        private static string Cell(bool? on) { return "<td>" + Box(on == true) + "</td>"; }
        private static string Underline(string v, int w) { return "<span class=\"ul\" style=\"min-width:" + w + "px\">" + E(v) + "</span>"; }
    }
}
