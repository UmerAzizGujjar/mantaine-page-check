using Infragistics.Web.UI.GridControls;
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
using System.Text;
using System.Drawing;
using System.IO;
using System.Web.Hosting;
using QRCoder;
using System.Globalization;

namespace PMS
{
    public partial class FBRBillingView : System.Web.UI.Page
    {
        public class FBRInvoiceDetail
        {
            public string ItemCode { get; set; }
            public string ItemName { get; set; }
            public string PCTCode { get; set; }
            public double Quantity { get; set; }
            public double TaxRate { get; set; }
            public double SaleValue { get; set; }
            public double Discount { get; set; }
            public double FurtherTax { get; set; }
            public double TaxCharged { get; set; }
            public double TotalAmount { get; set; }
            public int InvoiceType { get; set; }
            public string RefUSIN { get; set; }
            public string HsCode { get; set; }
            public string ProductDescription { get; set; }
            public double Rate { get; set; }
            public string UOM { get; set; }
        }

        public class FBRInvoiceMaster
        {
            public string InvoiceNumber { get; set; }
            public int POSID { get; set; }
            public string USIN { get; set; }
            public string RefUSIN { get; set; }
            public DateTime DateTime { get; set; }
            public string BuyerPNTN { get; set; }
            public string BuyerName { get; set; }
            public string BuyerNTN { get; set; }
            public string BuyerCNIC { get; set; }
            public string BuyerPhoneNumber { get; set; }
            public double TotalSaleValue { get; set; }
            public double TotalTaxCharged { get; set; }
            public double TotalQuantity { get; set; }
            public double Discount { get; set; }
            public double FurtherTax { get; set; }
            public double TotalBillAmount { get; set; }
            public int PaymentMode { get; set; }
            public int InvoiceType { get; set; }
            public List<FBRInvoiceDetail> Items { get; set; }
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
                        IsFBRPosted = postedDetailLookup.ContainsKey(bd.Bill_Details_ID)
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
        public static string PostToFBR(int billId, List<int> selectedDetailIds)
        {
            try
            {
                using (var db = new DataBaseDataContext())
                {
                    var billing = db.Ar_Billings.FirstOrDefault(b => b.Bill_ID == billId);
                    var URL = db.sys_Parms.FirstOrDefault(p => p.Name == "FBR Credentials")?.Segment1;
                    var POSID = db.sys_Parms.FirstOrDefault(p => p.Name == "FBR Credentials")?.Code;
                    var USIN = db.sys_Parms.FirstOrDefault(p => p.Name == "FBR Credentials")?.Segment2;
                    if (billing == null)
                    {
                        return JsonConvert.SerializeObject(new { success = false, message = "Bill not found" });
                    }

                    if (!string.IsNullOrWhiteSpace(billing.FBR_No))
                    {
                        return JsonConvert.SerializeObject(new { success = false, message = "Bill already posted to FBR" });
                    }

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

                    FBRInvoiceMaster objInv = new FBRInvoiceMaster();
                    
                    objInv.InvoiceNumber = billing.Bill_No;
                    objInv.POSID = Convert.ToInt32(POSID);
                    objInv.USIN = USIN;
                    objInv.DateTime = billing.Creation_Date ?? DateTime.Now;
                    objInv.BuyerNTN = "";
                    objInv.BuyerCNIC = "";
                    objInv.BuyerName = "";
                    objInv.BuyerPhoneNumber = "";
                    
                    var totalAmount = selectedDetails.Sum(bd => bd.Amount ?? 0);
                    var totalDiscount = selectedDetails.Sum(bd => bd.Discount_Amount ?? 0);
                    var netAmount = totalAmount - totalDiscount;
                    
                    objInv.TotalBillAmount = Convert.ToDouble(netAmount);
                    objInv.TotalQuantity = Convert.ToDouble(selectedDetails.Count);
                    objInv.TotalSaleValue = Convert.ToDouble(totalAmount);
                    objInv.TotalTaxCharged = 0;
                    objInv.Discount = Convert.ToDouble(totalDiscount);
                    objInv.FurtherTax = 0;
                    objInv.PaymentMode = 1;
                    objInv.RefUSIN = "";
                    objInv.InvoiceType = 1;
                    objInv.Items = BuildFBRItems(selectedDetails, db);

                    HttpClient client = new HttpClient();
                    string Token = "";
                    string apiUrl = "http://localhost:8524/api/IMSFiscal/GetInvoiceNumberByModel";
                    
                    client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", Token);
                    StringContent content = new StringContent(JsonConvert.SerializeObject(objInv), Encoding.UTF8, "application/json");
                    
                    System.Net.ServicePointManager.ServerCertificateValidationCallback = delegate { return true; };
                    
                    HttpResponseMessage response = client.PostAsync(apiUrl, content).Result;

                    if (response.IsSuccessStatusCode)
                    {
                        string result = response.Content.ReadAsStringAsync().Result;
                        char[] separator = { '"' };
                        String[] strlist = result.Split(separator, StringSplitOptions.RemoveEmptyEntries);

                        string FBR_Invoice_No = strlist.Length > 3 ? strlist[3] : string.Empty;
                        string FbrError = strlist.Length > 15 ? strlist[15] : string.Empty;

                        if (!string.IsNullOrEmpty(FBR_Invoice_No) && FBR_Invoice_No != "Not Available")
                        {
                            bool IsQRGenerated = GenerateQRCode(FBR_Invoice_No, billId, billing.Bill_No);
                            if (IsQRGenerated)
                            {
                                MarkDetailsAsFbrPosted(db, selectedDetails.Select(x => x.Bill_Details_ID).ToList());

                                return JsonConvert.SerializeObject(new 
                                { 
                                    success = true, 
                                    message = string.Format("Bill {0} posted to FBR successfully. Invoice No: {1}", billing.Bill_No, FBR_Invoice_No)
                                });
                            }
                            else
                            {
                                return JsonConvert.SerializeObject(new { success = false, message = "QR Code Generation Failed" });
                            }
                        }
                        else
                        {
                            return JsonConvert.SerializeObject(new { success = false, message = FbrError });
                        }
                    }
                    else
                    {
                        return JsonConvert.SerializeObject(new { success = false, message = "FBR API Response Failed: " + response.StatusCode });
                    }
                }
            }
            catch (Exception ex)
            {
                return JsonConvert.SerializeObject(new { success = false, message = ex.Message });
            }
        }

        private static List<FBRInvoiceDetail> BuildFBRItems(List<Ar_Billing_Detail> billDetails, DataBaseDataContext db)
        {
            List<FBRInvoiceDetail> items = new List<FBRInvoiceDetail>();

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
                
                items.Add(new FBRInvoiceDetail
                {
                    ItemCode = "ITEM001",
                    ItemName = detail.Item_Name ?? "Service",
                    Quantity = 1,
                    PCTCode = hsCode,
                    HsCode = hsCode,
                    TaxRate = 18,
                    SaleValue = Convert.ToDouble(detail.Amount ?? 0),
                    TotalAmount = Convert.ToDouble(detail.Net_Amount ?? 0),
                    TaxCharged = 0,
                    Discount = Convert.ToDouble(detail.Discount_Amount ?? 0),
                    FurtherTax = 0,
                    InvoiceType = 1,
                    RefUSIN = "",
                    ProductDescription = detail.Item_Name ?? "Service",
                    Rate = Convert.ToDouble(detail.Amount ?? 0),
                    UOM = "PCS"
                });
            }

            return items;
        }

        private static string GetHsCodeByItemType(string itemType, string testMainDepartment)
        {
            if (string.IsNullOrWhiteSpace(itemType))
                return "9815-101";

            var normalizedType = itemType.Trim().ToLower();

            if (normalizedType == "services")
                return "9821-101";
            else if (normalizedType == "test")
            {
                if (testMainDepartment == "001")
                    return "9816-101";
                else
                    return "9817-101";
            }
            else if (normalizedType == "pharmacy")
                return "9018-110";
            else if (normalizedType == "consultation")
                return "9815-101";
            else
                return "9815-101";
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

        private static void MarkDetailsAsFbrPosted(DataBaseDataContext db, List<int> detailIds)
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

                string fileName = string.Format("QRCode{0}.png", billId);
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
            catch (Exception ex)
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
                string pageName = "FBRBillingView";

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
            catch (Exception ex)
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
                string pageName = "FBRBillingView";

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
            catch (Exception ex)
            {
                throw;
            }
        }
    }
}
