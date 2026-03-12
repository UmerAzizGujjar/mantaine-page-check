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
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
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
                                        && (b.IsPharmacy == null || b.IsPharmacy == false)
                                  select new
                                  {
                                      Bill_No = b.Bill_No,
                                      Bill_Date = b.Creation_Date,
                                      Remarks = b.Remarks,
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
                                      Operator = u.UserName
                                  };

                    var Total_Billing = Billing.Count();

                    if (!string.IsNullOrWhiteSpace(searchValue))
                    {
                        searchValue = searchValue.Trim();
                        Billing = Billing.Where(x =>
                            x.Bill_No.ToString().Contains(searchValue) ||
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
                    var details = (from bd in db.Ar_Billing_Details
                                   where bd.Bill_ID == billId
                                   select bd).ToList();

                    var mappedDetails = details.Select((bd, index) => new
                    {
                        Bill_Detail_ID = index,
                        Item_Type = bd.Item_Type,
                        Item_Name = bd.Item_Name,
                        Amount = bd.Amount,
                        Discount_Amount = bd.Discount_Amount,
                        Net_Amount = bd.Net_Amount,
                        Test_Main_Department = bd.Test_Main_Department
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
                    if (billing == null)
                    {
                        return JsonConvert.SerializeObject(new { success = false, message = "Bill not found" });
                    }

                    var billDetails = db.Ar_Billing_Details
                        .Where(bd => bd.Bill_ID == billId)
                        .ToList();

                    if (billDetails.Count == 0 || selectedDetailIds.Count == 0)
                    {
                        return JsonConvert.SerializeObject(new { success = false, message = "No items selected" });
                    }

                    var selectedDetails = billDetails.Where((bd, index) => selectedDetailIds.Contains(index)).ToList();

                    FBRInvoiceMaster objInv = new FBRInvoiceMaster();
                    
                    objInv.InvoiceNumber = billing.Bill_No;
                    objInv.POSID = 818167;
                    objInv.USIN = "7BFE5BBD";
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
                    objInv.Items = BuildFBRItems(selectedDetails);

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

        private static List<FBRInvoiceDetail> BuildFBRItems(List<Ar_Billing_Detail> billDetails)
        {
            List<FBRInvoiceDetail> items = new List<FBRInvoiceDetail>();

            foreach (var detail in billDetails)
            {
                string hsCode = GetHsCodeByItemType(detail.Item_Type, detail.Test_Main_Department);
                
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
                        string fbrInfo = string.Format("FBR Invoice: {0}, QR Path: ~/wwwroot/QRCode/{1}, Posted: {2}", 
                            fbrInvoiceNo, fileName, DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));
                        billing.Remarks = (billing.Remarks ?? "") + " | " + fbrInfo;
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
