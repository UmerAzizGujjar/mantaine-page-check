using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Net.Http;
using System.Net.Http.Headers;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Text;
using System.Drawing;
using System.IO;
using System.Web.Hosting;
using QRCoder;
using System.Globalization;

namespace PMS
{
    public partial class DIBillingView : System.Web.UI.Page
    {
        // FBR Digital Invoicing (DI) payload - property names are the exact camelCase keys required by the DI API.
        public class DIInvoiceItem
        {
            public string hsCode { get; set; }
            public string productDescription { get; set; }
            public double quantity { get; set; }
            public string uoM { get; set; }
            public string rate { get; set; }
            public double valueSalesExcludingST { get; set; }
            public double salesTaxApplicable { get; set; }
            public double totalValues { get; set; }
            public double discount { get; set; }
            public string saleType { get; set; }
            public string sroScheduleNo { get; set; }
            public string sroItemSerialNo { get; set; }
            public double salesTaxWithheldAtSource { get; set; }
            public double extraTax { get; set; }
            public double furtherTax { get; set; }
            public double fedPayable { get; set; }
            public double fixedNotifiedValueOrRetailPrice { get; set; }
        }

        public class DIInvoiceMaster
        {
            public string invoiceType { get; set; }
            public string invoiceDate { get; set; }
            public string sellerNTNCNIC { get; set; }
            public string sellerBusinessName { get; set; }
            public string sellerProvince { get; set; }
            public string sellerAddress { get; set; }
            public string buyerNTNCNIC { get; set; }
            public string buyerBusinessName { get; set; }
            public string buyerProvince { get; set; }
            public string buyerAddress { get; set; }
            public string buyerRegistrationType { get; set; }
            public string invoiceRefNo { get; set; }
            public string scenarioId { get; set; }
            public List<DIInvoiceItem> items { get; set; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue, string startDate, string endDate)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    string userId = HttpContext.Current.Session["UserId"].ToString();

                    var Billing = from b in _dbContext.Ar_Billings
                                  join p in _dbContext.Reg_patients on b.Patient_ID equals p.pat_id
                                  join u in _dbContext.aspnet_Users on b.Created_By equals u.UserId
                                  where (b.Total_Amount != null || b.Discount_Amount != null)
                                        && (b.isCancel == null || b.isCancel == false)
                                        && (b.IsCathLab == null || b.IsCathLab == false)
                                  select new
                                  {
                                      Bill_No = b.Bill_No,
                                      Bill_Date = b.Creation_Date,
                                      Remarks = b.Remarks,
                                      BillType = b.IsPharmacy == true ? "Pharmacy" : "Basic",
                                      Total_Amount = b.Total_Amount,
                                      Discount_Amount = b.Discount_Amount,
                                      Discount_Percentage = b.Total_Amount.HasValue && b.Total_Amount.Value > 0
                                          ? Math.Round((b.Discount_Amount ?? 0) / b.Total_Amount.Value * 100, 2, MidpointRounding.AwayFromZero)
                                          : 0,
                                      Net_Amount = b.Net_Amount,
                                      Received_Amount = b.Received_Amount,
                                      Balance_Amount = b.Balance_Amount,
                                      MrNo = p.mr_no_sequence,
                                      Full_Name = p.Full_Name,
                                      Bill_ID = b.Bill_ID,
                                      Operator = u.UserName,
                                      FBR_No = b.FBR_No,
                                      QrCode_path = b.QrCode_path,
                                      IsPosted = b.FBR_No != null && b.FBR_No != ""
                                  };

                    DateTime parsedStartDate;
                    DateTime parsedEndDate;
                    var formats = new[] { "yyyy-MM-ddTHH:mm", "yyyy-MM-ddTHH:mm:ss", "yyyy-MM-dd HH:mm:ss", "yyyy-MM-dd" };

                    if (!string.IsNullOrWhiteSpace(startDate) && DateTime.TryParseExact(startDate, formats, CultureInfo.InvariantCulture, DateTimeStyles.None, out parsedStartDate))
                    {
                        Billing = Billing.Where(x => x.Bill_Date.HasValue && x.Bill_Date.Value >= parsedStartDate);
                    }

                    if (!string.IsNullOrWhiteSpace(endDate) && DateTime.TryParseExact(endDate, formats, CultureInfo.InvariantCulture, DateTimeStyles.None, out parsedEndDate))
                    {
                        var endDateExclusive = parsedEndDate.Date.AddDays(1);
                        Billing = Billing.Where(x => x.Bill_Date.HasValue && x.Bill_Date.Value < endDateExclusive);
                    }

                    var Total_Billing = Billing.Count();

                    if (!string.IsNullOrWhiteSpace(searchValue))
                    {
                        searchValue = searchValue.Trim();
                        Billing = Billing.Where(x =>
                            x.Bill_No.ToString().Contains(searchValue) ||
                            (x.BillType != null && x.BillType.Contains(searchValue)) ||
                            (x.Full_Name != null && x.Full_Name.Contains(searchValue)) ||
                            (x.MrNo != null && x.MrNo.Contains(searchValue)) ||
                            (x.Operator != null && x.Operator.Contains(searchValue))
                        );
                    }

                    var FilteredCount = Billing.Count();
                    Billing = Billing.OrderByDescending(a => a.Bill_ID);
                    var patientList = Billing.Skip(start).Take(length).ToList();

                    var jsonData = new
                    {
                        draw = draw,
                        recordsFiltered = FilteredCount,
                        recordsTotal = Total_Billing,
                        data = patientList
                    };

                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching patient list", ex);
            }
        }

        [WebMethod]
        public static string GetBillDetails(int billId)
        {
            try
            {
                using (var db = new DataBaseDataContext())
                {
                    var billDetails = db.Ar_Billing_Details
                        .Where(bd => bd.Bill_ID == billId)
                        .ToList();

                    var itemIds = billDetails
                        .Where(x => x.Item_ID.HasValue)
                        .Select(x => x.Item_ID.Value)
                        .Distinct()
                        .ToList();

                    var isFbrLookup = db.INV_Items
                        .Where(i => itemIds.Contains(i.Item_ID))
                        .Select(i => new { i.Item_ID, Is_Fbr = i.Is_Fbr == true })
                        .ToDictionary(i => i.Item_ID, i => i.Is_Fbr);

                    var postedDetailLookup = GetPostedDetailLookup(db, billId);

                    var mappedDetails = billDetails.Select(bd => new
                    {
                        Bill_Detail_ID = bd.Bill_Details_ID,
                        Item_Type = bd.Item_Type,
                        Item_Name = bd.Item_Name,
                        Amount = bd.Amount,
                        Discount_Amount = bd.Discount_Amount,
                        Net_Amount = bd.Net_Amount,
                        Test_Main_Department = bd.Test_Main_Department,
                        Is_Fbr = bd.Item_ID.HasValue
                            && isFbrLookup.ContainsKey(bd.Item_ID.Value)
                            && isFbrLookup[bd.Item_ID.Value],
                        IsDIPosted = postedDetailLookup.ContainsKey(bd.Bill_Details_ID)
                            && postedDetailLookup[bd.Bill_Details_ID]
                    }).ToList();

                    return JsonConvert.SerializeObject(mappedDetails);
                }
            }
            catch (Exception ex)
            {
                return JsonConvert.SerializeObject(new { error = ex.Message });
            }
        }

        [WebMethod]
        public static string PostToDI(int billId, List<int> selectedDetailIds)
        {
            try
            {
                using (var db = new DataBaseDataContext())
                {
                    var billing = db.Ar_Billings.FirstOrDefault(b => b.Bill_ID == billId);
                    if (billing == null)
                    {
                        return JsonConvert.SerializeObject(new { success = false, message = "Bill not found" });
                    }

                    if (!string.IsNullOrWhiteSpace(billing.FBR_No))
                    {
                        return JsonConvert.SerializeObject(new { success = false, message = "Bill already posted to Digital Invoicing" });
                    }

                    string postUrl = DiParam(db, "FBR_DI_PostUrl");
                    string token = DiParam(db, "FBR_DI_Token");
                    string sellerNtn = DiParam(db, "FBR_DI_SellerNTN");
                    string sellerName = DiParam(db, "FBR_DI_SellerName");
                    string sellerProvince = DiParam(db, "FBR_DI_SellerProvince");
                    string sellerAddress = DiParam(db, "FBR_DI_SellerAddress");
                    string configuredRegType = DiParam(db, "FBR_DI_RegistrationType");
                    string scenarioId = DiParam(db, "FBR_DI_ScenarioId");
                    string invoiceType = DiParam(db, "FBR_DI_InvoiceType");
                    string rate = DiParam(db, "FBR_DI_Rate");
                    string saleType = DiParam(db, "FBR_DI_SaleType");

                    if (string.IsNullOrWhiteSpace(postUrl))
                        return JsonConvert.SerializeObject(new { success = false, message = "DI Post URL not configured. Set it under Administrator > Sys Params > Digital Invoicing." });
                    if (string.IsNullOrWhiteSpace(token))
                        return JsonConvert.SerializeObject(new { success = false, message = "DI Security Token not configured." });
                    if (string.IsNullOrWhiteSpace(sellerNtn))
                        return JsonConvert.SerializeObject(new { success = false, message = "DI Seller NTN/CNIC not configured." });

                    if (string.IsNullOrWhiteSpace(invoiceType)) invoiceType = "Sale Invoice";
                    if (string.IsNullOrWhiteSpace(rate)) rate = "18%";
                    if (string.IsNullOrWhiteSpace(saleType)) saleType = "Services at standard rate";

                    var billDetails = db.Ar_Billing_Details
                        .Where(bd => bd.Bill_ID == billId)
                        .ToList();

                    if (billDetails.Count == 0 || selectedDetailIds == null || selectedDetailIds.Count == 0)
                    {
                        return JsonConvert.SerializeObject(new { success = false, message = "No items selected" });
                    }

                    var selectedDetails = billDetails
                        .Where(bd => selectedDetailIds.Contains(bd.Bill_Details_ID))
                        .ToList();

                    if (selectedDetails.Count == 0)
                    {
                        return JsonConvert.SerializeObject(new { success = false, message = "No valid bill items selected" });
                    }

                    var patient = db.Reg_patients.FirstOrDefault(p => p.pat_id == billing.Patient_ID);
                    string buyerId = NormalizeTaxId(patient != null ? patient.NIC : "");
                    string buyerRegType = string.IsNullOrWhiteSpace(buyerId)
                        ? "Unregistered"
                        : (string.IsNullOrWhiteSpace(configuredRegType) ? "Registered" : configuredRegType);

                    DIInvoiceMaster objInv = new DIInvoiceMaster();
                    objInv.invoiceType = invoiceType;
                    objInv.invoiceDate = (billing.Creation_Date ?? DateTime.Now).ToString("yyyy-MM-dd");
                    objInv.sellerNTNCNIC = sellerNtn;
                    objInv.sellerBusinessName = sellerName;
                    objInv.sellerProvince = sellerProvince;
                    objInv.sellerAddress = sellerAddress;
                    objInv.buyerNTNCNIC = buyerId;
                    objInv.buyerBusinessName = patient != null ? (patient.Full_Name ?? "") : "";
                    objInv.buyerProvince = patient != null && !string.IsNullOrWhiteSpace(patient.Province) ? patient.Province : sellerProvince;
                    objInv.buyerAddress = patient != null ? (patient.Permanent_Address ?? "") : "";
                    objInv.buyerRegistrationType = buyerRegType;
                    objInv.invoiceRefNo = "";
                    objInv.scenarioId = scenarioId;
                    objInv.items = BuildDIItems(selectedDetails, db, rate, saleType);

                    System.Net.ServicePointManager.SecurityProtocol =
                        System.Net.SecurityProtocolType.Tls12 | System.Net.SecurityProtocolType.Tls13;
                    System.Net.ServicePointManager.ServerCertificateValidationCallback = delegate { return true; };

                    string result;
                    int statusCode;
                    using (HttpClient client = new HttpClient())
                    {
                        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);
                        StringContent content = new StringContent(JsonConvert.SerializeObject(objInv), Encoding.UTF8, "application/json");

                        HttpResponseMessage response = client.PostAsync(postUrl, content).Result;
                        statusCode = (int)response.StatusCode;
                        result = response.Content.ReadAsStringAsync().Result;
                    }

                    System.Diagnostics.Debug.WriteLine("FBR DI POST " + postUrl + " -> " + statusCode + " : " + result);

                    string validationStatus = null;
                    string fbrError = null;
                    string fbrErrorCode = null;
                    string invoiceNo = null;

                    try
                    {
                        var jo = JObject.Parse(result);
                        var vr = jo["validationResponse"];
                        if (vr != null)
                        {
                            validationStatus = (string)vr["status"];
                            fbrError = (string)vr["error"];
                            fbrErrorCode = (string)vr["errorCode"];
                        }
                        invoiceNo = (string)(jo["invoiceNumber"] ?? jo["InvoiceNumber"] ?? jo["invoiceNo"]);
                    }
                    catch
                    {
                        fbrError = result;
                    }

                    if (string.Equals(validationStatus, "Valid", StringComparison.OrdinalIgnoreCase)
                        && !string.IsNullOrWhiteSpace(invoiceNo))
                    {
                        bool isQrGenerated = GenerateQRCode(invoiceNo, billId, billing.Bill_No);
                        MarkDetailsAsPosted(db, selectedDetails.Select(x => x.Bill_Details_ID).ToList());

                        return JsonConvert.SerializeObject(new
                        {
                            success = true,
                            message = string.Format("Bill {0} posted to Digital Invoicing successfully. Invoice No: {1}", billing.Bill_No, invoiceNo)
                        });
                    }

                    if (string.IsNullOrWhiteSpace(fbrError))
                    {
                        fbrError = "FBR did not accept the invoice. HTTP " + statusCode + ". " + result;
                    }
                    else if (!string.IsNullOrWhiteSpace(fbrErrorCode))
                    {
                        fbrError = string.Format("FBR rejected the invoice ({0}): {1}", fbrErrorCode, fbrError);
                    }

                    return JsonConvert.SerializeObject(new { success = false, message = fbrError });
                }
            }
            catch (Exception ex)
            {
                return JsonConvert.SerializeObject(new { success = false, message = ex.Message });
            }
        }

        private static string DiParam(DataBaseDataContext db, string name)
        {
            var p = db.sys_Parms.FirstOrDefault(x => x.Name == name);
            return p != null && p.Segment1 != null ? p.Segment1 : "";
        }

        private static string NormalizeTaxId(string taxId)
        {
            if (string.IsNullOrWhiteSpace(taxId))
                return "";

            var digits = new string(taxId.Where(char.IsDigit).ToArray());
            if (digits.Length == 13 || digits.Length == 7)
                return digits;

            return "";
        }

        private static double ParseRatePercent(string rate)
        {
            if (string.IsNullOrWhiteSpace(rate))
                return 0;

            var cleaned = rate.Replace("%", "").Trim();
            double value;
            return double.TryParse(cleaned, NumberStyles.Any, CultureInfo.InvariantCulture, out value) ? value : 0;
        }

        private static List<DIInvoiceItem> BuildDIItems(List<Ar_Billing_Detail> billDetails, DataBaseDataContext db, string rate, string saleType)
        {
            List<DIInvoiceItem> items = new List<DIInvoiceItem>();
            double ratePercent = ParseRatePercent(rate);

            var itemIds = billDetails
                .Where(x => x.Item_ID.HasValue)
                .Select(x => x.Item_ID.Value)
                .Distinct()
                .ToList();

            var itemCodeLookup = db.INV_Items
                .Where(i => itemIds.Contains(i.Item_ID))
                .Select(i => new { i.Item_ID, i.FBR_Code })
                .ToDictionary(i => i.Item_ID, i => i.FBR_Code);

            foreach (var detail in billDetails)
            {
                string hsCode = GetHsCodeByItemType(detail.Item_Type, detail.Test_Main_Department);
                var normalizedType = (detail.Item_Type ?? string.Empty).Trim().ToLower();

                if ((normalizedType == "service" || normalizedType == "services")
                    && detail.Item_ID.HasValue
                    && itemCodeLookup.ContainsKey(detail.Item_ID.Value)
                    && !string.IsNullOrWhiteSpace(itemCodeLookup[detail.Item_ID.Value]))
                {
                    hsCode = itemCodeLookup[detail.Item_ID.Value];
                }

                double discount = Convert.ToDouble(detail.Discount_Amount ?? 0);
                double taxableValue = Convert.ToDouble(detail.Net_Amount ?? 0);
                double salesTax = Math.Round(taxableValue * ratePercent / 100.0, 2);

                items.Add(new DIInvoiceItem
                {
                    hsCode = hsCode,
                    productDescription = detail.Item_Name ?? "Service",
                    quantity = 1,
                    uoM = "Nos",
                    rate = rate,
                    valueSalesExcludingST = taxableValue,
                    salesTaxApplicable = salesTax,
                    totalValues = taxableValue + salesTax,
                    discount = discount,
                    saleType = saleType,
                    sroScheduleNo = "",
                    sroItemSerialNo = "",
                    salesTaxWithheldAtSource = 0,
                    extraTax = 0,
                    furtherTax = 0,
                    fedPayable = 0,
                    fixedNotifiedValueOrRetailPrice = 0
                });
            }

            return items;
        }

        private static string GetHsCodeByItemType(string itemType, string testMainDepartment)
        {
            if (string.IsNullOrWhiteSpace(itemType))
                return "9815.0000";

            var normalizedType = itemType.Trim().ToLower();

            if (normalizedType == "services")
                return "9821.0000";
            else if (normalizedType == "test")
            {
                if (testMainDepartment == "001")
                    return "9816.0000";
                else
                    return "9817.0000";
            }
            else if (normalizedType == "pharmacy")
                return "9018.1100";
            else if (normalizedType == "consultation")
                return "9815.0000";
            else
                return "9815.0000";
        }

        private class DetailPostedStatus
        {
            public int Bill_Details_ID { get; set; }
            public bool IsFBRPosted { get; set; }
        }

        private static bool HasIsFbrPostedColumn(DataBaseDataContext db)
        {
            var exists = db.ExecuteQuery<int>("SELECT CASE WHEN COL_LENGTH('dbo.Ar_Billing_Details','IsFBRPosted') IS NULL THEN 0 ELSE 1 END").FirstOrDefault();
            return exists == 1;
        }

        private static Dictionary<int, bool> GetPostedDetailLookup(DataBaseDataContext db, int billId)
        {
            if (!HasIsFbrPostedColumn(db))
                return new Dictionary<int, bool>();

            var rows = db.ExecuteQuery<DetailPostedStatus>(
                "SELECT Bill_Details_ID, CAST(ISNULL(IsFBRPosted, 0) AS bit) AS IsFBRPosted FROM dbo.Ar_Billing_Details WHERE Bill_ID = {0}",
                billId).ToList();

            return rows.ToDictionary(x => x.Bill_Details_ID, x => x.IsFBRPosted);
        }

        private static void MarkDetailsAsPosted(DataBaseDataContext db, List<int> detailIds)
        {
            if (detailIds == null || detailIds.Count == 0)
                return;

            if (!HasIsFbrPostedColumn(db))
                return;

            foreach (var detailId in detailIds)
            {
                db.ExecuteCommand("UPDATE dbo.Ar_Billing_Details SET IsFBRPosted = 1 WHERE Bill_Details_ID = {0}", detailId);
            }
        }

        private static bool GenerateQRCode(string fbrInvoiceNo, int billId, string billNo)
        {
            try
            {
                QRCodeGenerator qrGenerator = new QRCodeGenerator();
                QRCodeData qrCodeData = qrGenerator.CreateQrCode(fbrInvoiceNo, QRCodeGenerator.ECCLevel.Q);
                QRCode qrCode = new QRCode(qrCodeData);
                Bitmap qrCodeImage = qrCode.GetGraphic(20);

                string webRootPath = HostingEnvironment.MapPath("~/wwwroot");

                if (!Directory.Exists(webRootPath))
                {
                    Directory.CreateDirectory(webRootPath);
                }

                string qrCodePath = Path.Combine(webRootPath, "QRCode");
                if (!Directory.Exists(qrCodePath))
                {
                    Directory.CreateDirectory(qrCodePath);
                }

                string fileName = string.Format("DIQRCode{0}.png", billId);
                string fullPath = Path.Combine(qrCodePath, fileName);
                qrCodeImage.Save(fullPath);

                using (var db = new DataBaseDataContext())
                {
                    var billing = db.Ar_Billings.FirstOrDefault(b => b.Bill_ID == billId);
                    if (billing != null)
                    {
                        billing.FBR_No = fbrInvoiceNo;
                        billing.QrCode_path = string.Format("~/wwwroot/QRCode/{0}", fileName);
                        db.SubmitChanges();
                    }
                }

                return true;
            }
            catch (Exception)
            {
                return false;
            }
        }

        [WebMethod]
        public static string GetUserColumnPreferences()
        {
            try
            {
                string userId = AppConfig.UserID.ToString();
                string pageName = "DIBillingView";

                using (var db = new DataBaseDataContext())
                {
                    var pref = db.UserDataTablePreferences
                                  .FirstOrDefault(p => p.UserID == userId && p.PageName == pageName);

                    if (pref != null)
                        return pref.ColumnVisibility;
                    else
                        return "";
                }
            }
            catch (Exception)
            {
                return "";
            }
        }

        [WebMethod]
        public static void SaveUserColumnPreferences(string visibilityJson)
        {
            try
            {
                string userId = AppConfig.UserID.ToString();
                string pageName = "DIBillingView";

                using (var db = new DataBaseDataContext())
                {
                    var existing = db.UserDataTablePreferences
                                     .FirstOrDefault(p => p.UserID == userId && p.PageName == pageName);

                    if (existing != null)
                    {
                        existing.ColumnVisibility = visibilityJson;
                    }
                    else
                    {
                        db.UserDataTablePreferences.InsertOnSubmit(new UserDataTablePreference
                        {
                            UserID = userId,
                            PageName = pageName,
                            ColumnVisibility = visibilityJson
                        });
                    }

                    db.SubmitChanges();
                }
            }
            catch (Exception)
            {
                throw;
            }
        }
    }
}
