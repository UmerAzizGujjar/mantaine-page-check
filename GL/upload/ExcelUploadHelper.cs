using System;
using System.Collections.Generic;
using System.Data;
using System.Data.OleDb;
using System.Globalization;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Security;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

namespace PMS
{
    /// <summary>
    /// Shared plumbing for the Excel Uploads pages: reads .xlsx (no driver needed), .csv and .xls (ACE OLEDB)
    /// into rows of strings, builds sample .xlsx workbooks with drop-downs, and shows SweetAlert messages.
    /// </summary>
    public static class ExcelUploadHelper
    {
        public class SheetRow
        {
            public int Number;      // Excel row number, for messages
            public string[] Cells;

            public bool IsBlank { get { return !Cells.Any(c => !string.IsNullOrWhiteSpace(c)); } }
        }

        public class SampleSheet
        {
            public string Name;
            public List<string[]> Rows = new List<string[]>();     // Rows[0] = header (bold)
            public int[] Widths;
            public bool TextColumns;                                // format columns as Text so leading zeros survive
            public bool FreezeHeader;
            public Dictionary<int, string> ListValidations = new Dictionary<int, string>(); // column index -> list formula
        }

        #region Reading

        /// <summary>Reads the uploaded file. Picks the sheet named <paramref name="preferredSheet"/> if present, else the first.</summary>
        public static List<SheetRow> Read(FileUpload upload, string preferredSheet)
        {
            string extension = Path.GetExtension(upload.PostedFile.FileName).ToLowerInvariant();
            if (extension == ".xlsx")
            {
                using (MemoryStream ms = new MemoryStream(upload.FileBytes))
                    return ReadXlsx(ms, preferredSheet);
            }
            if (extension == ".csv")
            {
                using (MemoryStream ms = new MemoryStream(upload.FileBytes))
                    return ReadCsv(ms);
            }
            if (extension == ".xls")
            {
                // ACE OLEDB reads from a file. Use the system temp folder: creating folders inside the site can
                // restart the app and drop every user's session.
                string path = Path.Combine(Path.GetTempPath(), "ExcelUpload_" + Guid.NewGuid().ToString("N") + ".xls");
                try
                {
                    upload.SaveAs(path);
                    return ReadXlsWithOleDb(path, preferredSheet);
                }
                catch (Exception ex)
                {
                    throw new Exception("Failed to read .xls file. Please save it as .xlsx (Excel Workbook) and upload again. (" + ex.Message + ")");
                }
                finally
                {
                    try { if (File.Exists(path)) File.Delete(path); } catch { }
                }
            }
            throw new Exception("Unsupported file type. Please upload an .xlsx, .xls or .csv file.");
        }

        public static bool IsSupported(string fileName)
        {
            string extension = Path.GetExtension(fileName ?? "").ToLowerInvariant();
            return extension == ".xlsx" || extension == ".xls" || extension == ".csv";
        }

        /// <summary>Header text compared without case, spaces, punctuation or the "*" required marker.</summary>
        public static string NormalizeHeader(string s)
        {
            return new string((s ?? "").Where(char.IsLetterOrDigit).ToArray()).ToLowerInvariant();
        }

        public static List<SheetRow> ReadXlsx(Stream stream, string preferredSheet)
        {
            XNamespace ns = "http://schemas.openxmlformats.org/spreadsheetml/2006/main";
            XNamespace rNs = "http://schemas.openxmlformats.org/officeDocument/2006/relationships";
            List<SheetRow> result = new List<SheetRow>();

            ZipArchive zip;
            try { zip = new ZipArchive(stream, ZipArchiveMode.Read); }
            catch { throw new Exception("The file is not a valid .xlsx workbook."); }

            using (zip)
            {
                List<string> shared = new List<string>();
                ZipArchiveEntry ssEntry = zip.GetEntry("xl/sharedStrings.xml");
                if (ssEntry != null)
                {
                    using (Stream s = ssEntry.Open())
                    {
                        foreach (XElement si in XDocument.Load(s).Root.Elements(ns + "si"))
                            shared.Add(string.Concat(si.Descendants(ns + "t").Where(t => t.Parent.Name != ns + "rPh").Select(t => t.Value)));
                    }
                }

                ZipArchiveEntry sheetEntry = null;
                ZipArchiveEntry wbEntry = zip.GetEntry("xl/workbook.xml");
                ZipArchiveEntry relsEntry = zip.GetEntry("xl/_rels/workbook.xml.rels");
                if (wbEntry != null && relsEntry != null)
                {
                    XDocument wb, rels;
                    using (Stream s = wbEntry.Open()) wb = XDocument.Load(s);
                    using (Stream s = relsEntry.Open()) rels = XDocument.Load(s);
                    List<XElement> sheets = wb.Descendants(ns + "sheet").ToList();
                    XElement chosen = sheets.FirstOrDefault(x => string.Equals((string)x.Attribute("name"), preferredSheet, StringComparison.OrdinalIgnoreCase))
                                      ?? sheets.FirstOrDefault();
                    if (chosen != null)
                    {
                        string rid = (string)chosen.Attribute(rNs + "id");
                        XElement rel = rels.Root.Elements().FirstOrDefault(x => (string)x.Attribute("Id") == rid);
                        string target = rel == null ? null : (string)rel.Attribute("Target");
                        if (!string.IsNullOrEmpty(target))
                            sheetEntry = zip.GetEntry(target.StartsWith("/") ? target.TrimStart('/') : "xl/" + target);
                    }
                }
                if (sheetEntry == null)
                    sheetEntry = zip.GetEntry("xl/worksheets/sheet1.xml");
                if (sheetEntry == null)
                    throw new Exception("No worksheet found in the file.");

                XDocument sheetDoc;
                using (Stream s = sheetEntry.Open()) sheetDoc = XDocument.Load(s);
                XElement sheetData = sheetDoc.Root.Element(ns + "sheetData");
                if (sheetData == null) return result;

                int rowSeq = 0;
                foreach (XElement row in sheetData.Elements(ns + "row"))
                {
                    int rowNo;
                    rowSeq = int.TryParse((string)row.Attribute("r"), out rowNo) ? rowNo : rowSeq + 1;
                    List<string> cells = new List<string>();
                    int colSeq = -1;
                    foreach (XElement c in row.Elements(ns + "c"))
                    {
                        string cellRef = (string)c.Attribute("r");
                        colSeq = string.IsNullOrEmpty(cellRef) ? colSeq + 1 : ColumnIndex(cellRef);
                        while (cells.Count <= colSeq) cells.Add("");
                        cells[colSeq] = CellValue(c, ns, shared);
                    }
                    result.Add(new SheetRow { Number = rowSeq, Cells = cells.ToArray() });
                }
            }
            return result;
        }

        private static string CellValue(XElement c, XNamespace ns, List<string> shared)
        {
            string type = (string)c.Attribute("t") ?? "";
            if (type == "inlineStr")
            {
                XElement inline = c.Element(ns + "is");
                return inline == null ? "" : string.Concat(inline.Descendants(ns + "t").Select(t => t.Value));
            }
            XElement v = c.Element(ns + "v");
            if (v == null) return "";
            switch (type)
            {
                case "s":
                    int idx;
                    return int.TryParse(v.Value, out idx) && idx >= 0 && idx < shared.Count ? shared[idx] : "";
                case "b":
                    return v.Value == "1" ? "TRUE" : "FALSE";
                case "e":
                    return "";
                case "str":
                    return v.Value;
                default:
                    // Numbers: show 3001234567 instead of 3.001234567E+9
                    double d;
                    if (double.TryParse(v.Value, NumberStyles.Float, CultureInfo.InvariantCulture, out d))
                    {
                        if (Math.Abs(d) < 1e15 && d == Math.Floor(d)) return ((long)d).ToString(CultureInfo.InvariantCulture);
                        return d.ToString("0.##########", CultureInfo.InvariantCulture);
                    }
                    return v.Value;
            }
        }

        private static int ColumnIndex(string cellRef)
        {
            int index = 0;
            foreach (char ch in cellRef)
            {
                if (!char.IsLetter(ch)) break;
                index = index * 26 + (char.ToUpperInvariant(ch) - 'A' + 1);
            }
            return index - 1;
        }

        public static List<SheetRow> ReadCsv(Stream stream)
        {
            List<SheetRow> result = new List<SheetRow>();
            string text;
            using (StreamReader reader = new StreamReader(stream, Encoding.UTF8, true))
                text = reader.ReadToEnd();

            List<string> cells = new List<string>();
            StringBuilder cell = new StringBuilder();
            bool quoted = false;
            int rowNo = 1;
            for (int i = 0; i < text.Length; i++)
            {
                char ch = text[i];
                if (quoted)
                {
                    if (ch == '"' && i + 1 < text.Length && text[i + 1] == '"') { cell.Append('"'); i++; }
                    else if (ch == '"') quoted = false;
                    else cell.Append(ch);
                }
                else if (ch == '"') quoted = true;
                else if (ch == ',') { cells.Add(cell.ToString()); cell.Clear(); }
                else if (ch == '\r' || ch == '\n')
                {
                    if (ch == '\r' && i + 1 < text.Length && text[i + 1] == '\n') i++;
                    cells.Add(cell.ToString()); cell.Clear();
                    result.Add(new SheetRow { Number = rowNo++, Cells = cells.ToArray() });
                    cells = new List<string>();
                }
                else cell.Append(ch);
            }
            if (cell.Length > 0 || cells.Count > 0)
            {
                cells.Add(cell.ToString());
                result.Add(new SheetRow { Number = rowNo, Cells = cells.ToArray() });
            }
            return result;
        }

        private static List<SheetRow> ReadXlsWithOleDb(string filePath, string preferredSheet)
        {
            List<SheetRow> result = new List<SheetRow>();
            string connStr = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=" + filePath + ";Extended Properties='Excel 8.0;HDR=NO;IMEX=1';";
            using (OleDbConnection conn = new OleDbConnection(connStr))
            {
                conn.Open();
                DataTable schema = conn.GetOleDbSchemaTable(OleDbSchemaGuid.Tables, null);
                List<string> names = schema.Rows.Cast<DataRow>().Select(r => r["TABLE_NAME"].ToString()).Where(n => n.TrimEnd('\'').EndsWith("$")).ToList();
                if (names.Count == 0) throw new Exception("No worksheet found in the file.");
                string sheet = names.FirstOrDefault(n => n.Trim('\'').Equals(preferredSheet + "$", StringComparison.OrdinalIgnoreCase)) ?? names[0];

                DataTable dt = new DataTable();
                using (OleDbCommand cmd = new OleDbCommand("SELECT * FROM [" + sheet + "]", conn))
                using (OleDbDataReader reader = cmd.ExecuteReader())
                    dt.Load(reader);

                int rowNo = 1;
                foreach (DataRow r in dt.Rows)
                    result.Add(new SheetRow { Number = rowNo++, Cells = r.ItemArray.Select(x => x == DBNull.Value ? "" : Convert.ToString(x, CultureInfo.InvariantCulture)).ToArray() });
            }
            return result;
        }

        #endregion

        #region Sample workbook

        private const string MainNs = "http://schemas.openxmlformats.org/spreadsheetml/2006/main";
        private const string RelNs = "http://schemas.openxmlformats.org/officeDocument/2006/relationships";

        public static byte[] BuildWorkbook(IList<SampleSheet> sheets)
        {
            using (MemoryStream ms = new MemoryStream())
            {
                using (ZipArchive zip = new ZipArchive(ms, ZipArchiveMode.Create, true))
                {
                    StringBuilder types = new StringBuilder();
                    StringBuilder wbSheets = new StringBuilder();
                    StringBuilder wbRels = new StringBuilder();
                    for (int i = 0; i < sheets.Count; i++)
                    {
                        types.Append("<Override PartName=\"/xl/worksheets/sheet" + (i + 1) + ".xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml\"/>");
                        wbSheets.Append("<sheet name=\"" + SecurityElement.Escape(sheets[i].Name) + "\" sheetId=\"" + (i + 1) + "\" r:id=\"rId" + (i + 1) + "\"/>");
                        wbRels.Append("<Relationship Id=\"rId" + (i + 1) + "\" Type=\"" + RelNs + "/worksheet\" Target=\"worksheets/sheet" + (i + 1) + ".xml\"/>");
                        AddEntry(zip, "xl/worksheets/sheet" + (i + 1) + ".xml", Worksheet(sheets[i], i == 0));
                    }

                    AddEntry(zip, "[Content_Types].xml",
                        "<Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\">" +
                        "<Default Extension=\"rels\" ContentType=\"application/vnd.openxmlformats-package.relationships+xml\"/>" +
                        "<Default Extension=\"xml\" ContentType=\"application/xml\"/>" +
                        "<Override PartName=\"/xl/workbook.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml\"/>" +
                        "<Override PartName=\"/xl/styles.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml\"/>" +
                        types + "</Types>");
                    AddEntry(zip, "_rels/.rels",
                        "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\">" +
                        "<Relationship Id=\"rId1\" Type=\"" + RelNs + "/officeDocument\" Target=\"xl/workbook.xml\"/></Relationships>");
                    AddEntry(zip, "xl/workbook.xml",
                        "<workbook xmlns=\"" + MainNs + "\" xmlns:r=\"" + RelNs + "\"><sheets>" + wbSheets + "</sheets></workbook>");
                    AddEntry(zip, "xl/_rels/workbook.xml.rels",
                        "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\">" + wbRels +
                        "<Relationship Id=\"rId" + (sheets.Count + 1) + "\" Type=\"" + RelNs + "/styles\" Target=\"styles.xml\"/></Relationships>");
                    // Style 0 = normal, 1 = text (@) so phone/CNIC/codes keep leading zeros, 2 = bold header
                    AddEntry(zip, "xl/styles.xml",
                        "<styleSheet xmlns=\"" + MainNs + "\">" +
                        "<fonts count=\"2\"><font><sz val=\"11\"/><name val=\"Calibri\"/></font><font><b/><sz val=\"11\"/><name val=\"Calibri\"/></font></fonts>" +
                        "<fills count=\"3\"><fill><patternFill patternType=\"none\"/></fill><fill><patternFill patternType=\"gray125\"/></fill>" +
                        "<fill><patternFill patternType=\"solid\"><fgColor rgb=\"FFD9E1F2\"/><bgColor indexed=\"64\"/></patternFill></fill></fills>" +
                        "<borders count=\"1\"><border><left/><right/><top/><bottom/><diagonal/></border></borders>" +
                        "<cellStyleXfs count=\"1\"><xf numFmtId=\"0\" fontId=\"0\" fillId=\"0\" borderId=\"0\"/></cellStyleXfs>" +
                        "<cellXfs count=\"3\"><xf numFmtId=\"0\" fontId=\"0\" fillId=\"0\" borderId=\"0\" xfId=\"0\"/>" +
                        "<xf numFmtId=\"49\" fontId=\"0\" fillId=\"0\" borderId=\"0\" xfId=\"0\" applyNumberFormat=\"1\"/>" +
                        "<xf numFmtId=\"49\" fontId=\"1\" fillId=\"2\" borderId=\"0\" xfId=\"0\" applyNumberFormat=\"1\" applyFont=\"1\" applyFill=\"1\"/></cellXfs>" +
                        "<cellStyles count=\"1\"><cellStyle name=\"Normal\" xfId=\"0\" builtinId=\"0\"/></cellStyles>" +
                        "</styleSheet>");
                }
                return ms.ToArray();
            }
        }

        private static string Worksheet(SampleSheet sheet, bool selected)
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("<worksheet xmlns=\"" + MainNs + "\" xmlns:r=\"" + RelNs + "\">");
            sb.Append("<sheetViews><sheetView" + (selected ? " tabSelected=\"1\"" : "") + " workbookViewId=\"0\">");
            if (sheet.FreezeHeader)
                sb.Append("<pane ySplit=\"1\" topLeftCell=\"A2\" activePane=\"bottomLeft\" state=\"frozen\"/>");
            sb.Append("</sheetView></sheetViews>");

            if (sheet.Widths != null && sheet.Widths.Length > 0)
            {
                sb.Append("<cols>");
                for (int i = 0; i < sheet.Widths.Length; i++)
                    sb.AppendFormat("<col min=\"{0}\" max=\"{0}\" width=\"{1}\"{2} customWidth=\"1\"/>", i + 1, sheet.Widths[i], sheet.TextColumns ? " style=\"1\"" : "");
                sb.Append("</cols>");
            }

            sb.Append("<sheetData>");
            for (int r = 0; r < sheet.Rows.Count; r++)
            {
                sb.Append("<row r=\"" + (r + 1) + "\">");
                string[] cells = sheet.Rows[r];
                for (int c = 0; c < cells.Length; c++)
                {
                    if (string.IsNullOrEmpty(cells[c])) continue;
                    int style = r == 0 ? 2 : sheet.TextColumns ? 1 : 0;
                    sb.Append("<c r=\"" + ColumnName(c) + (r + 1) + "\" t=\"inlineStr\"" + (style > 0 ? " s=\"" + style + "\"" : "") +
                              "><is><t xml:space=\"preserve\">" + SecurityElement.Escape(cells[c]) + "</t></is></c>");
                }
                sb.Append("</row>");
            }
            sb.Append("</sheetData>");

            if (sheet.ListValidations.Count > 0)
            {
                sb.Append("<dataValidations count=\"" + sheet.ListValidations.Count + "\">");
                foreach (KeyValuePair<int, string> v in sheet.ListValidations)
                {
                    string range = ColumnName(v.Key) + "2:" + ColumnName(v.Key) + "5000";
                    sb.Append("<dataValidation type=\"list\" allowBlank=\"1\" showInputMessage=\"1\" showErrorMessage=\"1\" errorStyle=\"warning\" sqref=\"" + range + "\"><formula1>" +
                              SecurityElement.Escape(v.Value) + "</formula1></dataValidation>");
                }
                sb.Append("</dataValidations>");
            }
            sb.Append("</worksheet>");
            return sb.ToString();
        }

        public static string ColumnName(int index)
        {
            string name = "";
            index++;
            while (index > 0)
            {
                int rem = (index - 1) % 26;
                name = (char)('A' + rem) + name;
                index = (index - 1) / 26;
            }
            return name;
        }

        private static void AddEntry(ZipArchive zip, string name, string xml)
        {
            ZipArchiveEntry entry = zip.CreateEntry(name, CompressionLevel.Optimal);
            using (StreamWriter w = new StreamWriter(entry.Open(), new UTF8Encoding(false)))
            {
                w.Write("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\r\n");
                w.Write(xml);
            }
        }

        #endregion

        #region Page helpers

        public static void SendFile(Page page, byte[] file, string fileName)
        {
            HttpResponse response = page.Response;
            response.Clear();
            response.ContentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
            response.AddHeader("Content-Disposition", "attachment; filename=" + fileName);
            response.AddHeader("Content-Length", file.Length.ToString());
            response.BinaryWrite(file);
            response.Flush();
            HttpContext.Current.ApplicationInstance.CompleteRequest();
            response.SuppressContent = true;
        }

        public static void ShowMessage(Page page, string message, string icon)
        {
            string title = icon == "success" ? "Success" : icon == "error" ? "Error" : "Notice";
            JavaScriptSerializer js = new JavaScriptSerializer();
            string script = string.Format(
                "window.addEventListener('load', function () {{ if (window.Swal) {{ Swal.fire({{ title: {0}, text: {1}, icon: {2}, confirmButtonText: 'OK' }}); }} else {{ alert({1}); }} }});",
                js.Serialize(title), js.Serialize(message), js.Serialize(icon));
            ScriptManager.RegisterStartupScript(page, page.GetType(), "excelUploadMsg", script, true);
        }

        #endregion
    }
}
