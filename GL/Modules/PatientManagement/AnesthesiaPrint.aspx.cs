using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;

namespace PMS.Modules.PatientManagement
{
    /// <summary>
    /// Compact A4 print of one anesthesia record: Pre-op Assessment, Intra-operative Sheet and Operation Notes
    /// (only the steps that are saved). Company logo top-left, company name in the centre of every sheet.
    /// </summary>
    public partial class AnesthesiaPrint : System.Web.UI.Page
    {
        private static readonly Regex IdFormat = new Regex(@"^ANE-\d{8}-\d{4}$", RegexOptions.Compiled);

        protected void Page_Load(object sender, EventArgs e)
        {
            Response.ContentType = "text/html";
            string id = (Request.QueryString["ID"] ?? "").Trim();
            if (!IdFormat.IsMatch(id)) { Response.Write(Message("Invalid record number")); return; }

            using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                int companyId = AppConfig.Company_ID;
                var pre = db.Anesthesia_PreOps.FirstOrDefault(x => x.Anesthesia_ID == id && x.Company_ID == companyId);
                if (pre == null) { Response.Write(Message("Anesthesia record not found")); return; }
                var intra = db.Anesthesia_IntraOps.FirstOrDefault(x => x.Anesthesia_ID == id);
                var notes = db.Anesthesia_OpNotes.FirstOrDefault(x => x.Anesthesia_ID == id);
                var history = db.Anesthesia_Histories.Where(x => x.Anesthesia_ID == id).OrderBy(x => x.History_ID).ToList();
                var vitals = db.Anesthesia_IntraOp_Vitals.Where(x => x.Anesthesia_ID == id).OrderBy(x => x.Chart_Time).ThenBy(x => x.Vital_ID).ToList();

                var p = db.Reg_patients.Where(x => x.pat_id == pre.Patient_ID)
                          .Select(x => new { x.Full_Name, x.mr_no_sequence, x.Age_years, x.Gender }).FirstOrDefault();
                string gender = p == null ? "" : (db.ExecuteQuery<string>("select dbo.GetDataValueName('Gender', {0})", p.Gender ?? "").FirstOrDefault() ?? p.Gender ?? "");
                var adm = pre.In_Patient_ID == null ? null
                        : db.In_Patients.Where(x => x.In_Patient_ID == pre.In_Patient_ID).Select(x => new { x.Admission_Date, x.File_No }).FirstOrDefault();

                var empIds = new[] { pre.Anaesthetist_ID, pre.Assessed_By_ID, intra == null ? null : intra.Surgeon_ID, intra == null ? null : intra.Anaesthetist_ID,
                                     notes == null ? null : notes.Surgeon_ID, notes == null ? null : notes.Anaesthetist_ID, notes == null ? null : notes.Scrub_Nurse_ID }
                                  .Where(x => x != null).Select(x => x.Value).Distinct().ToList();
                var emp = db.HR_Employees.Where(x => empIds.Contains(x.Emp_ID)).ToDictionary(x => x.Emp_ID, x => x.Emp_Name);

                var ctx = new Ctx
                {
                    // read from the company record, so a name changed in Company setup shows without logging in again
                    Company = db.ExecuteQuery<string>("select Company_Name from sys_Companys where Company_ID = {0}", companyId).FirstOrDefault() ?? AppConfig.Company_Name,
                    Logo = ResolveUrl(CompanyLogo.GetUrl(companyId)),
                    Id = id,
                    PatientName = p == null ? "" : (p.Full_Name ?? ""),
                    MR = p == null ? "" : (p.mr_no_sequence ?? ""),
                    Age = p == null ? "" : (p.Age_years ?? ""),
                    Gender = gender,
                    Admission = adm == null ? "" : ("#" + pre.In_Patient_ID + (adm.Admission_Date.HasValue ? " / " + adm.Admission_Date.Value.ToString("dd-MMM-yyyy") : "")),
                    Emp = emp
                };

                var sb = new StringBuilder();
                sb.Append(Head(ctx));
                sb.Append(PreOpSheet(ctx, pre, history));
                if (intra != null) sb.Append(IntraSheet(ctx, intra, vitals));
                if (notes != null) sb.Append(NotesSheet(ctx, notes));
                sb.Append("</body></html>");
                Response.Write(sb.ToString());
            }
        }

        private class Ctx
        {
            public string Company, Logo, Id, PatientName, MR, Age, Gender, Admission;
            public Dictionary<int, string> Emp;
            public string EmpName(int? id) { string n; return id != null && Emp.TryGetValue(id.Value, out n) ? n : ""; }
        }

        // ---------- small helpers ----------
        private static string E(string s) { return HttpUtility.HtmlEncode(s ?? ""); }
        private static string Multi(string s) { return E(s).Replace("\r\n", "<br>").Replace("\n", "<br>"); }
        private static string D(DateTime? d) { return d.HasValue ? d.Value.ToString("dd-MMM-yyyy") : ""; }
        private static string T(TimeSpan? t) { return t.HasValue ? t.Value.ToString(@"hh\:mm") : ""; }
        private static string N(decimal? d) { return d.HasValue ? d.Value.ToString("0.##", CultureInfo.InvariantCulture) : ""; }
        private static string N(int? d) { return d.HasValue ? d.Value.ToString(CultureInfo.InvariantCulture) : ""; }

        private static string F(string label, string valueHtml, int span)
        {
            return "<div class=\"f s" + span + "\"><span class=\"l\">" + label + "</span><span class=\"v\">" + valueHtml + "</span></div>";
        }
        private static string FT(string label, string text, int span) { return F(label, E(text), span); }
        private static string Box(string label, string text, int span, bool tall = false)
        {
            return "<div class=\"bx s" + span + (tall ? " tall" : "") + "\"><span class=\"l\">" + label + "</span><div class=\"bv\">" + Multi(text) + "</div></div>";
        }
        private static string Pills(string selected, params string[] opts)
        {
            return string.Join(" ", opts.Select(o => "<span class=\"pill" + (string.Equals(o, selected, StringComparison.OrdinalIgnoreCase) ? " sel" : "") + "\">" + E(o) + "</span>"));
        }

        private static string SheetOpen(Ctx c, string title)
        {
            return "<section class=\"sheet\">" +
                "<header class=\"hd\"><div class=\"hl\"><img src=\"" + E(c.Logo) + "\" alt=\"\"></div>" +
                "<div class=\"hc\"><div class=\"cn\">" + E(c.Company) + "</div><div class=\"st\">" + E(title) + "</div></div>" +
                "<div class=\"hr\"><b>" + E(c.Id) + "</b><br>Printed " + DateTime.Now.ToString("dd-MMM-yyyy HH:mm") + "</div></header>" +
                "<div class=\"grid pt\">" +
                F("Patient", "<b>" + E(c.PatientName) + "</b>", 5) + F("MR / Reg #", E(c.MR), 3) + F("Age", E(c.Age), 2) + F("Gender", E(c.Gender), 2) + F("Admission (In-Patient # / date)", E(c.Admission), 12) +
                "</div>";
        }
        private const string SheetClose = "</section>";

        private static string Message(string text)
        {
            return "<!DOCTYPE html><html><body style=\"font-family:Segoe UI,Arial;padding:40px\"><h3>" + E(text) + "</h3></body></html>";
        }

        private static string Head(Ctx c)
        {
            return "<!DOCTYPE html><html><head><meta charset=\"utf-8\"><title>Anesthesia Record " + E(c.Id) + "</title><style>" + Css + "</style></head><body>" +
                "<div class=\"toolbar\"><button onclick=\"window.print()\">Print</button><button onclick=\"window.close()\">Close</button>" +
                "<span>Anesthesia record " + E(c.Id) + " &middot; compact A4 print</span></div>";
        }

        // ---------- sheet 1: pre-op ----------
        private static string PreOpSheet(Ctx c, Anesthesia_PreOp r, List<Anesthesia_History> hist)
        {
            var sb = new StringBuilder(SheetOpen(c, "Pre-op Assessment"));
            sb.Append("<div class=\"grid\">" +
                FT("Date of Procedure", D(r.Procedure_Date), 3) + FT("Procedure", r.Procedure_Name, 6) + FT("Anaesthetist", c.EmpName(r.Anaesthetist_ID), 3) +
                FT("Weight (kg)", N(r.Weight_Kg), 2) + FT("Height (cm)", N(r.Height_Cm), 2) + FT("Pulse", N(r.Pulse), 1) + FT("SpO2 %", N(r.SpO2), 2) + FT("B.P", r.BP, 2) + FT("Temp &deg;F", N(r.Temp_F), 2) + FT("R/R", N(r.Resp_Rate), 1) +
                "</div><div class=\"two\"><div class=\"col\">");

            // history
            sb.Append("<div class=\"h\">History</div><table class=\"hx\">");
            string[] items = { "Previous Anesthesia", "HTN", "IHD", "Asthma", "COPD", "Hepatic", "Neurological", "Renal", "Epilepsy", "Other", "Allergic", "Physical Activity / APD" };
            foreach (string it in items)
            {
                var h = hist.FirstOrDefault(x => x.Item_Name == it);
                bool on = h != null && (h.Is_Present ?? false);
                sb.Append("<tr><td class=\"cb\">" + (on ? "&#9745;" : "&#9744;") + "</td><td class=\"nm\">" + E(it) + "</td><td class=\"nt\">" + (h == null ? "" : E(h.Notes)) + "</td></tr>");
            }
            sb.Append("</table><div class=\"grid\">" + FT("Family History", r.Family_History, 12) + FT("Phys Exam", r.Phys_Exam, 12) + FT("Resp", r.Resp_Exam, 12) + FT("CVS", r.CVS_Exam, 12) + FT("Other", r.Other_Exam, 12) + "</div>");

            sb.Append("<div class=\"h\">Airway Assessment</div><div class=\"grid\">" +
                F("Mallampati Grade", Pills(r.Mallampati_Grade, "I", "II", "III", "IV"), 12) + F("Mandibular Protrusion", Pills(r.Mandibular_Protrusion, "A", "B", "C"), 12) +
                FT("Atlantooccipital Ext.", r.Atlantooccipital_Ext, 6) + FT("Neck Circumference", r.Neck_Circumference, 6) + FT("Thyromental Distance", r.Thyromental_Distance, 6) + FT("Teeth", r.Teeth, 6) + FT("Others", r.Airway_Others, 12) + "</div>");

            sb.Append("<div class=\"h\">Medication &amp; Advice</div><div class=\"grid\">" +
                FT("Routine Medication (if any)", r.Routine_Medication, 12) + FT("Advised Rx: Night before Surgery", r.Advised_Rx_Night, 12) + FT("on Morning of Surgery", r.Advised_Rx_Morning, 12) + FT("Pre-medication", r.Pre_Medication, 12) + "</div>");

            sb.Append("</div><div class=\"col\"><div class=\"h\">Investigations</div><div class=\"grid\">" +
                FT("Blood Group", r.Blood_Group, 12) + FT("Hb", r.Hb, 4) + FT("PLT", r.PLT, 4) + FT("WBC", r.WBC, 4) + FT("BSL", r.BSL, 6) + FT("RETS", r.RETS, 6) + FT("CXR", r.CXR, 12) + FT("ECG", r.ECG, 12) + FT("Others", r.Investigations_Others, 12) + "</div>");
            sb.Append("<div class=\"grid\">" + F("ASA Status", Pills(r.ASA_Status, "I", "II", "III", "IV", "V", "E"), 12) + "</div>");
            sb.Append(Box("Anticipated Problems", r.Anticipated_Problems, 12, true) + Box("Consultant Advice", r.Consultant_Advice, 12, true) + Box("Anesthetic Plan", r.Anesthetic_Plan, 12, true));
            sb.Append("<div class=\"grid\">" + FT("Doctor's Name", c.EmpName(r.Assessed_By_ID), 12) + FT("Date of Assessment", D(r.Assessment_Date), 12) + "</div>");
            sb.Append("</div></div>" + SheetClose);
            return sb.ToString();
        }

        // ---------- sheet 2: intra-op ----------
        private static string IntraSheet(Ctx c, Anesthesia_IntraOp r, List<Anesthesia_IntraOp_Vital> vit)
        {
            var sb = new StringBuilder(SheetOpen(c, "Intra-Operative Anesthesia Sheet"));
            sb.Append("<div class=\"grid\">" +
                FT("Age / Wt.", r.Age_Weight, 2) + FT("Date", D(r.Op_Date), 2) + FT("Bed No.", r.Bed_No, 2) + FT("Room / Ward", r.Room_Ward, 2) + FT("Hemoglobin", r.Hemoglobin, 2) + FT("Blood No.", r.Blood_No, 2) +
                FT("Anesthetist", c.EmpName(r.Anaesthetist_ID), 4) + FT("Surgeon", c.EmpName(r.Surgeon_ID), 4) + FT("Blood Pressure", r.Blood_Pressure, 2) + FT("Time Given", T(r.Time_Given), 2) +
                FT("Premedication", r.Premedication, 4) + FT("Diagnosis", r.Diagnosis, 4) + FT("Operation", r.Operation, 4) + FT("Pt. I.D Verified By", r.Id_Verified_By, 6) +
                "</div><div class=\"h\">Pre-induction &mdash; Re-evaluation of Patient</div><div class=\"grid\">" +
                FT("Type of Anesthesia", r.Type_Of_Anesthesia, 4) + FT("Preoperative Condition", r.Preop_Condition, 4) + F("ASA", Pills(r.ASA_Status, "I", "II", "III", "IV", "V", "E"), 4) + FT("Drugs", r.Drugs, 12) + "</div>");

            sb.Append("<div class=\"two\"><div class=\"col\">");
            sb.Append("<div class=\"h\">Induction</div><div class=\"grid\">" + FT("Induction", r.Induction_Notes, 12) + F("Halo / Iso / Ent / Sevo", Pills(r.Inhalation_Agent, "Halo", "Iso", "Ent", "Sevo"), 12) + FT("I.V.", r.IV_Drugs, 12) + "</div>");
            sb.Append("<div class=\"h\">Airway</div><div class=\"grid\">" + FT("Mask", r.Airway_Mask, 4) + FT("LMA", r.Airway_LMA, 4) + FT("Tube", r.Airway_Tube, 4) +
                F("Oral / Nasal", Pills(r.Airway_Route, "Oral", "Nasal"), 12) + FT("Size", r.Airway_Size, 6) + FT("Cuff / Pack", r.Airway_Cuff_Pack, 6) + FT("Position", r.Airway_Position, 12) + "</div>");
            sb.Append("<div class=\"h\">Maintenance</div><div class=\"grid\">" + F("Mode", Pills(r.Maintenance_Mode, "Spontaneous", "Controlled"), 12) +
                FT("O&#8322;", r.Maint_O2, 4) + FT("N&#8322;O", r.Maint_N2O, 4) + FT("VI", r.Maint_VI, 4) + FT("RR", r.Maint_RR, 6) + FT("Airway Pressure", r.Airway_Pressure, 6) + "</div>");
            sb.Append("</div><div class=\"col\"><div class=\"h\">Monitoring</div><table class=\"vt\"><tr><th>Time</th><th>Sys</th><th>Dia</th><th>Pulse</th><th>SpO2</th><th>RR</th><th>Drug / Event</th></tr>");
            foreach (var v in vit)
                sb.Append("<tr><td>" + T(v.Chart_Time) + "</td><td>" + N(v.BP_Sys) + "</td><td>" + N(v.BP_Dias) + "</td><td>" + N(v.Pulse) + "</td><td>" + N(v.SpO2) + "</td><td>" + N(v.Resp_Rate) + "</td><td class=\"nt\">" + E(v.Drug_Event) + "</td></tr>");
            if (vit.Count == 0) sb.Append("<tr><td colspan=\"7\">&nbsp;</td></tr>");
            sb.Append("</table>" + ChartSvg(vit) +
                "<div class=\"grid\">" + FT("Blood Loss", r.Total_Blood_Loss, 6) + FT("Urine Output", r.Total_Urine_Output, 6) + "</div></div></div>");

            sb.Append("<div class=\"grid\">" + Box("Recovery from anesthesia while shifting from O.T. to Recovery Room", r.Recovery_Notes, 12) +
                Box("Comments while shifting from O.T. to Recovery Room", r.Comments_OT_To_RR, 6) + Box("Notes on shifting from R.R. to Patient Room", r.Notes_RR_To_Room, 6) +
                FT("Name &amp; Sign of Anesthetist", r.Anesthetist_Sign, 8) + FT("Time", T(r.Sign_Time), 4) + "</div>");
            sb.Append(SheetClose);
            return sb.ToString();
        }

        // Monitoring chart on the paper sheet's 10-190 scale: systolic (down triangle), diastolic (up triangle), pulse (dot).
        private static string ChartSvg(List<Anesthesia_IntraOp_Vital> rows)
        {
            const int W = 380, H = 168, L = 26, R = 6, Tp = 6, B = 16;
            Func<double, double> y = v => Tp + (H - Tp - B) * (1 - (Math.Max(10, Math.Min(190, v)) - 10) / 180.0);
            var sb = new StringBuilder("<svg class=\"chart\" viewBox=\"0 0 " + W + " " + H + "\" xmlns=\"http://www.w3.org/2000/svg\">");
            for (int g = 10; g <= 190; g += 20)
            {
                sb.Append("<line x1=\"" + L + "\" x2=\"" + (W - R) + "\" y1=\"" + y(g).ToString("0.#", CultureInfo.InvariantCulture) + "\" y2=\"" + y(g).ToString("0.#", CultureInfo.InvariantCulture) + "\" stroke=\"#c9ced6\" stroke-width=\".6\"/>");
                if ((g - 10) % 40 == 0) sb.Append("<text x=\"" + (L - 3) + "\" y=\"" + (y(g) + 2.5).ToString("0.#", CultureInfo.InvariantCulture) + "\" font-size=\"7\" fill=\"#555\" text-anchor=\"end\">" + g + "</text>");
            }
            int n = rows.Count;
            Func<int, double> x = i => n <= 1 ? (L + W - R) / 2.0 : L + 14 + (W - L - R - 28) * i / (double)(n - 1);
            Func<int, string> X = i => x(i).ToString("0.#", CultureInfo.InvariantCulture);
            Func<double, string> Y = v => y(v).ToString("0.#", CultureInfo.InvariantCulture);
            Action<Func<Anesthesia_IntraOp_Vital, int?>, string, string> series = (sel, color, shape) =>
            {
                var pts = new List<string>(); var marks = new StringBuilder();
                for (int i = 0; i < n; i++)
                {
                    int? v = sel(rows[i]); if (v == null) continue;
                    string px = X(i), py = Y(v.Value); double fy = y(v.Value);
                    pts.Add(px + "," + py);
                    if (shape == "dn") marks.Append("<path d=\"M" + (x(i) - 3.5).ToString("0.#", CultureInfo.InvariantCulture) + "," + (fy - 3.5).ToString("0.#", CultureInfo.InvariantCulture) + " L" + (x(i) + 3.5).ToString("0.#", CultureInfo.InvariantCulture) + "," + (fy - 3.5).ToString("0.#", CultureInfo.InvariantCulture) + " L" + px + "," + (fy + 3.5).ToString("0.#", CultureInfo.InvariantCulture) + " Z\" fill=\"" + color + "\"/>");
                    else if (shape == "up") marks.Append("<path d=\"M" + (x(i) - 3.5).ToString("0.#", CultureInfo.InvariantCulture) + "," + (fy + 3.5).ToString("0.#", CultureInfo.InvariantCulture) + " L" + (x(i) + 3.5).ToString("0.#", CultureInfo.InvariantCulture) + "," + (fy + 3.5).ToString("0.#", CultureInfo.InvariantCulture) + " L" + px + "," + (fy - 3.5).ToString("0.#", CultureInfo.InvariantCulture) + " Z\" fill=\"" + color + "\"/>");
                    else marks.Append("<circle cx=\"" + px + "\" cy=\"" + py + "\" r=\"2.8\" fill=\"" + color + "\"/>");
                }
                if (pts.Count > 1) sb.Append("<polyline points=\"" + string.Join(" ", pts) + "\" fill=\"none\" stroke=\"" + color + "\" stroke-width=\"1\"/>");
                sb.Append(marks.ToString());
            };
            series(v => v.BP_Sys, "#b91c1c", "dn"); series(v => v.BP_Dias, "#1d4e89", "up"); series(v => v.Pulse, "#15803d", "dot");
            for (int i = 0; i < n; i++)
                if (rows[i].Chart_Time.HasValue) sb.Append("<text x=\"" + X(i) + "\" y=\"" + (H - 4) + "\" font-size=\"6.5\" fill=\"#555\" text-anchor=\"middle\">" + T(rows[i].Chart_Time) + "</text>");
            sb.Append("<text x=\"" + (W - R) + "\" y=\"8\" font-size=\"6.5\" text-anchor=\"end\" fill=\"#333\">&#9660; Sys  &#9650; Dia  &#9679; Pulse</text></svg>");
            return sb.ToString();
        }

        // ---------- sheet 3: operation notes ----------
        private static string NotesSheet(Ctx c, Anesthesia_OpNote r)
        {
            var sb = new StringBuilder(SheetOpen(c, "Operation Notes"));
            sb.Append("<div class=\"grid\">" +
                FT("Bed / Room No.", r.Bed_Room_No, 4) + FT("Date of Operation", D(r.Op_Date), 4) + FT("Time", T(r.Op_Time), 4) +
                FT("Pre-op Diagnosis", r.PreOp_Dx, 6) + FT("Post-op Diagnosis", r.PostOp_Dx, 6) +
                FT("Surgeon Name", c.EmpName(r.Surgeon_ID), 6) + FT("Assistants", r.Assistants, 6) +
                FT("Anaesthetist Name", c.EmpName(r.Anaesthetist_ID), 6) + FT("Type of Anaesthesia", r.Type_Of_Anaesthesia, 6) +
                FT("Name of Procedure", r.Procedure_Name, 8) + FT("Duration of Procedure", r.Duration, 4) + "</div>");
            sb.Append("<div class=\"h\">Threads Used</div><div class=\"grid\">" + FT("1 - Catgut", r.Thread_Catgut, 3) + FT("2 - Vicryl", r.Thread_Vicryl, 3) + FT("3 - Proline", r.Thread_Proline, 3) + FT("4 - Silk", r.Thread_Silk, 3) + "</div>");
            sb.Append("<div class=\"h\">Procedure Notes</div><div class=\"notes\">" + Multi(r.Procedure_Notes) + "</div>");
            sb.Append("<div class=\"h\">Scrub Nurse Notes</div><div class=\"grid\">" + FT("Blood Loss", r.Blood_Loss, 4) + FT("Intra-operative I.V Fluids", r.IV_Fluids, 4) + FT("Blood Transfused", r.Blood_Transfused, 4) +
                FT("Intra-operative Urine Output", r.Urine_Output, 6) + FT("Swab / Instrument Counting", r.Swab_Instrument_Count, 6) + "</div>");
            sb.Append("<div class=\"sign\"><div><span class=\"line\">" + E(c.EmpName(r.Surgeon_ID)) + "</span>Surgeon Name &amp; Sign</div><div><span class=\"line\">" + E(c.EmpName(r.Scrub_Nurse_ID)) + "</span>Scrub Nurse Name &amp; Sign</div></div>");
            sb.Append(SheetClose);
            return sb.ToString();
        }

        private const string Css = @"
*{box-sizing:border-box}
@page{size:A4;margin:7mm}
body{margin:0;background:#e9ecef;font-family:'Segoe UI',Arial,sans-serif;font-size:9pt;line-height:1.22;color:#111}
.toolbar{position:sticky;top:0;z-index:5;padding:8px 14px;background:#1e2a3a;color:#fff;display:flex;gap:8px;align-items:center}
.toolbar button{padding:5px 16px;border:0;border-radius:4px;background:#f39c3d;color:#fff;font-weight:700;cursor:pointer}
.toolbar span{margin-left:8px;opacity:.85;font-size:12px}
.sheet{width:196mm;min-height:282mm;margin:10px auto;padding:5mm 6mm;background:#fff;border:1px solid #d5d9de;page-break-after:always;overflow:hidden}
.sheet:last-of-type{page-break-after:auto}
.hd{display:grid;grid-template-columns:34mm 1fr 34mm;align-items:center;gap:4mm;padding-bottom:2mm;border-bottom:1.6px solid #111}
.hl img{max-height:15mm;max-width:32mm;display:block}
.hc{text-align:center}.cn{font-size:14pt;font-weight:800;letter-spacing:.2px}.st{font-size:9.5pt;font-weight:700;margin-top:1px;text-transform:uppercase;letter-spacing:.6px}
.hr{text-align:right;font-size:7pt;color:#333}
.grid{display:grid;grid-template-columns:repeat(12,1fr);gap:1px 6px;margin:1.2mm 0}
.pt{background:#f3f5f7;border:1px solid #d5d9de;padding:1mm 1.5mm;margin-top:1.5mm}
.f{display:flex;gap:4px;align-items:baseline;border-bottom:1px solid #9aa1ab;min-height:4.6mm;padding-bottom:.4mm}
.l{font-size:7pt;color:#444;white-space:nowrap}.v{font-weight:600;overflow-wrap:anywhere}
.s1{grid-column:span 1}.s2{grid-column:span 2}.s3{grid-column:span 3}.s4{grid-column:span 4}.s5{grid-column:span 5}.s6{grid-column:span 6}.s7{grid-column:span 7}.s8{grid-column:span 8}.s12{grid-column:span 12}
.f.s12,.f.s8{align-items:flex-start}
.h{margin:2mm 0 .8mm;padding:.4mm 2mm;background:#1e2a3a;color:#fff;font-size:7.6pt;font-weight:700;letter-spacing:.7px;text-transform:uppercase}
.two{display:grid;grid-template-columns:1fr 1fr;gap:0 6mm}.col{min-width:0}
table{width:100%;border-collapse:collapse}
.hx td{border-bottom:1px solid #cdd2d8;padding:.5mm 1mm;vertical-align:top}.hx .cb{width:5mm;font-size:10pt;line-height:1}.hx .nm{width:34%;font-weight:700}.hx .nt{font-weight:600}
.vt th{background:#eef0f3;border:1px solid #9aa1ab;font-size:7pt;padding:.5mm 1mm;text-align:center}.vt td{border:1px solid #9aa1ab;padding:.4mm 1mm;text-align:center;font-weight:600}.vt td.nt{text-align:left}
.chart{display:block;width:100%;height:auto;margin:1mm 0;border:1px solid #9aa1ab}
.pill{display:inline-block;white-space:nowrap;min-width:5.5mm;padding:0 1.6mm;margin-right:1mm;border:1px solid #777;border-radius:8px;text-align:center;font-size:7.6pt;color:#555;font-weight:600}
.pill.sel{background:#111;color:#fff;border-color:#111}
.bx{margin:1mm 0;border:1px solid #9aa1ab;border-radius:2px;padding:.6mm 1.5mm;min-height:11mm}.bx.tall{min-height:19mm}.bx .l{display:block}.bv{font-weight:600;overflow-wrap:anywhere}
.grid .bx{margin:0}
.notes{min-height:112mm;border:1px solid #9aa1ab;padding:1.5mm 2mm;font-weight:500;font-size:9pt;line-height:1.35;overflow-wrap:anywhere}
.sign{display:grid;grid-template-columns:1fr 1fr;gap:12mm;margin-top:14mm}.sign div{text-align:center;font-size:8pt;font-weight:700}.sign .line{display:block;min-height:6mm;border-bottom:1px solid #111;margin-bottom:1mm;font-weight:600}
@media print{body{background:#fff}.toolbar{display:none}.sheet{margin:0;border:0;width:auto;min-height:0;padding:0}}
";
    }
}
