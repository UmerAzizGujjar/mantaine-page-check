using System;
using System.Linq;
using System.Web;

namespace PMS.Modules.Lab
{
    /// <summary>
    /// Shared pieces for the paper-style history form prints (Mammography, CT):
    /// grey hospital band, boxed title, underlined fill-in lines and tick boxes, sized for A4.
    /// </summary>
    public static class HistoryFormPrint
    {
        public static string E(string s) { return HttpUtility.HtmlEncode(s ?? ""); }
        public static string Multi(string s) { return E(s).Replace("\r\n", "<br>").Replace("\n", "<br>"); }
        public static string D(DateTime? d) { return d.HasValue ? d.Value.ToString("dd-MMM-yyyy") : ""; }
        public static string DT(DateTime? d) { return d.HasValue ? d.Value.ToString("dd-MMM-yyyy hh:mm tt") : ""; }

        /// <summary>Label followed by the value written on an underline, like a filled paper form.</summary>
        public static string Line(string label, string value, int minWidth = 160)
        {
            return "<span class=\"fl\"><b>" + label + "</b> <span class=\"ul\" style=\"min-width:" + minWidth + "px\">" + E(value) + "</span></span>";
        }

        public static string Box(bool on) { return "<span class=\"cb" + (on ? " on" : "") + "\">" + (on ? "&#10003;" : "") + "</span>"; }

        /// <summary>A tick box with its caption.</summary>
        public static string Check(string caption, bool? on) { return "<span class=\"ck\">" + Box(on == true) + " " + caption + "</span>"; }

        /// <summary>Yes [ ] No [ ] with the saved answer ticked; nothing ticked when unanswered.</summary>
        public static string YesNo(bool? v, string yes = "Yes", string no = "No")
        {
            return "<span class=\"yn\">" + yes + " " + Box(v == true) + " &nbsp;" + no + " " + Box(v == false) + "</span>";
        }

        public static string Header(string company, string phone, string title)
        {
            return "<div class=\"band\"><div class=\"cn\">" + E(company) + "</div>" +
                   (string.IsNullOrWhiteSpace(phone) ? "" : "<div class=\"tel\">Tel : " + E(phone) + "</div>") + "</div>" +
                   "<div class=\"title\">" + E(title) + "</div>";
        }

        /// <param name="compact">Tighter spacing so a long form still fits on one A4 page.</param>
        public static string Document(string title, string body, bool compact = false)
        {
            return "<!DOCTYPE html><html><head><meta charset=\"utf-8\"><title>" + E(title) + "</title><style>" + Css + "</style></head><body>" +
                   "<div class=\"toolbar\"><button onclick=\"window.print()\">Print</button><button onclick=\"window.close()\">Close</button><span>" + E(title) + "</span></div>" +
                   "<div class=\"sheet" + (compact ? " compact" : "") + "\">" + body + "</div><script>" + FitScript + "</script></body></html>";
        }

        /// <summary>After an app restart the login cookie survives but the session (company, book) is empty.</summary>
        public static bool SessionAlive(System.Web.SessionState.HttpSessionState session)
        {
            return session != null && session["Company_ID"] != null && session["Book_ID"] != null;
        }

        public static string Message(string text)
        {
            return "<!DOCTYPE html><html><body style=\"font-family:Segoe UI,Arial;padding:40px\"><h3>" + E(text) + "</h3></body></html>";
        }

        /// <summary>Company name and phone from the company record (falls back to the session's company name).</summary>
        public static void Company(DataBaseDataContext db, out string name, out string phone)
        {
            var c = db.ExecuteQuery<CompanyRow>("select Company_Name, Company_Phone1 from sys_Companys where Company_ID = {0}", AppConfig.Company_ID).FirstOrDefault();
            name = c != null && !string.IsNullOrWhiteSpace(c.Company_Name) ? c.Company_Name : AppConfig.Company_Name;
            phone = c == null ? "" : (c.Company_Phone1 ?? "");
        }

        public class CompanyRow
        {
            public string Company_Name { get; set; }
            public string Company_Phone1 { get; set; }
        }

        // Just before printing, lay the sheet out at the printed width and shrink it only if it would not fit
        // one page (long answers, a printer's fallback fonts or Letter paper), so nothing spills onto page 2.
        private const string FitScript =
            "function fitOnePage(){var s=document.querySelector('.sheet'),cs=s.getAttribute('style');" +
            "s.style.width='190mm';s.style.padding='0';s.style.margin='0';s.style.minHeight='0';s.style.zoom='1';" +
            "var mm=s.getBoundingClientRect().height*25.4/96;s.setAttribute('style',cs||'');" +
            "var max=255;document.documentElement.style.setProperty('--fit',mm>max?(max/mm).toFixed(3):'1');}" +
            "window.addEventListener('beforeprint',fitOnePage);";

        private const string Css =
            "@page{size:A4;margin:10mm}" +
            "*{box-sizing:border-box}" +
            "body{margin:0;background:#e9ecef;font-family:Calibri,'Segoe UI',Arial,sans-serif;font-size:13.5px;color:#000}" +
            ".toolbar{position:sticky;top:0;z-index:2;display:flex;gap:8px;align-items:center;padding:8px 14px;background:#2b3a4a;color:#fff;font-size:13px}" +
            ".toolbar button{padding:5px 16px;font-weight:700;border:0;border-radius:4px;cursor:pointer;background:#fff;color:#2b3a4a}" +
            ".sheet{width:190mm;min-height:270mm;margin:14px auto;padding:8mm 9mm;background:#fff;box-shadow:0 2px 12px rgba(0,0,0,.15)}" +
            ".band{position:relative;padding:6px 10px 18px;text-align:center;background:#bfbfbf;border:1px solid #555}" +
            ".band .cn{font-family:Cambria,'Times New Roman',serif;font-size:27px;letter-spacing:.5px}" +
            ".band .tel{position:absolute;left:90px;bottom:2px;font-family:Cambria,serif;font-size:12px}" +
            ".title{padding:4px;text-align:center;font-weight:700;font-size:16px;text-transform:uppercase;border:1px solid #555;border-top:0;margin-bottom:12px}" +
            ".row{display:flex;flex-wrap:wrap;align-items:flex-end;gap:6px 26px;margin:9px 0}" +
            ".fl{display:inline-flex;align-items:flex-end;gap:6px}" +
            ".ul{display:inline-block;min-height:18px;padding:0 4px;border-bottom:1.3px solid #000;font-weight:400}" +
            ".cb{display:inline-flex;align-items:center;justify-content:center;width:15px;height:15px;border:1.2px solid #333;font-size:12px;font-weight:700;line-height:1;vertical-align:middle}" +
            ".cb.on{background:#f1f1f1}" +
            ".yn{white-space:nowrap}" +
            ".ck{display:inline-block;margin:3px 18px 3px 0;white-space:nowrap}" +
            ".grid2{display:grid;grid-template-columns:1fr 1fr;border:1px solid #555;margin:12px 0}" +
            ".grid2>div{padding:8px 10px;font-family:Cambria,'Times New Roman',serif;font-size:14px}" +
            ".grid2>div+div{border-left:1px solid #555}" +
            ".q{margin:0 0 10px}" +
            ".q .ans{margin:3px 0 0 16px;min-height:52px;font-family:Calibri,Arial,sans-serif;font-size:13px}" +
            ".q.bul::before{content:'\\2022';margin-right:10px}" +
            ".small{font-size:12px;font-style:italic}" +
            ".sec{margin:14px 0 6px;font-weight:700}" +
            ".boxhd{margin:18px 0 10px;padding:4px;text-align:center;font-weight:700;font-size:16px;border:1px solid #555}" +
            ".dash{margin:18px 0 4px;border-top:1px dashed #777}" +
            ".note{font-style:italic;font-size:12px}" +
            "table.t{width:100%;border-collapse:collapse;margin:8px 0}" +
            "table.t th,table.t td{padding:5px 6px;text-align:center;border:1px solid #555}" +
            "table.t th{font-weight:700;background:#f2f2f2}" +
            ".compact{font-size:13px}" +
            ".compact .band{padding:5px 10px 16px}.compact .band .cn{font-size:25px}" +
            ".compact .title{font-size:15px;margin-bottom:9px}" +
            ".compact .row{margin:6px 0;gap:4px 24px}" +
            ".compact .cb{width:14px;height:14px}" +
            ".compact .ck{margin:2px 16px 2px 0}" +
            ".compact .sec{margin:9px 0 4px}" +
            ".compact table.t{margin:6px 0}.compact table.t th,.compact table.t td{padding:4px 6px}" +
            "@media print{html,body{height:auto}body{background:#fff}.toolbar{display:none}.sheet{width:auto;min-height:0;margin:0;padding:0;box-shadow:none;zoom:var(--fit,1);break-after:avoid;page-break-after:avoid}.band,.cb.on,table.t th{-webkit-print-color-adjust:exact;print-color-adjust:exact}}";
    }
}
