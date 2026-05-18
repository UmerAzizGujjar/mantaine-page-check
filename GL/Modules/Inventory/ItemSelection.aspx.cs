using PMS.Inventory;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;

namespace PMS.Modules.Inventory
{
    public partial class ItemSelection : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
           
        }

        [WebMethod]
        public static string GetGRNList()
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var eligibleGRNs = db.GRN_Masters.Where(gm => gm.Status == "Approved").OrderByDescending(gm => gm.GRN_Num).ToList();

                    var grnList = new List<GRNListDto>();
                    foreach (var gm in eligibleGRNs)
                    {
                        string vendorName = "Unknown";

                        if (!string.IsNullOrEmpty(gm.VendorId))
                        {
                            int vendorIdInt = 0;
                            if (int.TryParse(gm.VendorId, out vendorIdInt) && vendorIdInt > 0)
                            {
                                var vendor = db.AP_Vendors.FirstOrDefault(v => v.Vendor_ID == vendorIdInt);
                                if (vendor != null)
                                {
                                    vendorName = vendor.Vendor_Name;
                                }
                            }
                        }

                        grnList.Add(new GRNListDto
                        {
                            GRN_ID = gm.GRN_ID,
                            GRN_Num = Convert.ToString(gm.GRN_Num),
                            VendorName = vendorName
                        });
                    }

                    return new JavaScriptSerializer().Serialize(new
                    {
                        Success = true,
                        Data = grnList
                    });
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new
                {
                    Success = false,
                    Message = ex.Message
                });
            }
        }

        [WebMethod]
        public static string GetGRNDetails(int grnId)
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var grnMaster = db.GRN_Masters.FirstOrDefault(gm => gm.GRN_ID == grnId);

                    if (grnMaster == null)
                    {
                        return new JavaScriptSerializer().Serialize(new
                        {
                            Success = false,
                            Message = "GRN not found"
                        });
                    }

                    GRNDetailsDto result = new GRNDetailsDto
                    {
                        GRN_ID = grnMaster.GRN_ID,
                        GRN_Num = grnMaster.GRN_Num?.ToString() ?? "",
                        VendorName = GetVendorName(db, grnMaster.VendorId),
                        InvOrgId = grnMaster.InvOrgId,
                        WarehouseName = db.GetDataValueName("Ware House", grnMaster.InvOrgId),
                        Items = new List<GRNItemDto>()
                    };

                    var grnDetails = db.GRN_Details.Where(gd => gd.GRNId == grnId).ToList();

                    foreach (var detail in grnDetails)
                    {
                        string itemName = "";
                        string unitName = "";
                        decimal currentStock = 0;

                        var item = db.INV_Items.FirstOrDefault(i => i.Item_ID == detail.Item_Id);
                        if (item != null)
                        {
                            itemName = item.Description;
                            unitName = db.GetDataValueName("UOM", item.Unit);

                            string inventoryOrg = grnMaster.InvOrgId;
                            currentStock = db.GetInvenrtoryItemUomTotalStock(detail.Item_Id ?? 0,Convert.ToString(inventoryOrg)) ?? 0;
                        }

                        result.Items.Add(new GRNItemDto
                        {
                            GRN_Detail_Id = detail.GRN_detail_Id,
                            GRN_ID = detail.GRNId ?? 0,
                            ItemCode = detail.ItemCode ?? "",
                            Item_Id = detail.Item_Id ?? 0,
                            GRNQty = detail.GRNQty ?? 0,
                            BatchNum = detail.BatchNum ?? "",
                            Rate = detail.Rate ?? 0,
                            ItemName = itemName,
                            Unit = unitName,
                            CurrentStock = currentStock
                        });
                    }

                    return new JavaScriptSerializer().Serialize(new
                    {
                        Success = true,
                        Data = result
                    });
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new
                {
                    Success = false,
                    Message = ex.Message
                });
            }
        }

        private static string GetVendorName(DataBaseDataContext db, string vendorId)
        {
            if (string.IsNullOrEmpty(vendorId))
                return "Unknown";

            if (int.TryParse(vendorId, out int vendorIdInt))
            {
                var vendor = db.AP_Vendors.FirstOrDefault(v => v.Vendor_ID == vendorIdInt);
                return vendor != null ? (vendor.Vendor_Name ?? "Unknown") : "Unknown";
            }

            return "Unknown";
        }

        private static string GetWarehouseName(DataBaseDataContext db, int? invOrgId)
        {
            if (!invOrgId.HasValue || invOrgId.Value == 0)
                return "";

            var warehouse = (from dv in db.DataValues  
                             where dv.DataValue_Description == "Ware House" && dv.DataValue_Name == invOrgId.Value.ToString()
                             select dv.DataValue_Name).FirstOrDefault();


            return warehouse ?? "";
        }

        [WebMethod]
        public static string SaveSelection(string selectionDate, int grnId, string remarks, List<SelectedItemDto> selectedItems)
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var grnMaster = db.GRN_Masters.FirstOrDefault(g => g.GRN_ID == grnId);
                    if (grnMaster == null)
                    {
                        return new JavaScriptSerializer().Serialize(new
                        {
                            Success = false,
                            Message = "GRN not found"
                        });
                    }

                    string vendorName = "Unknown";
                    if (!string.IsNullOrEmpty(grnMaster.VendorId))
                    {
                        if (int.TryParse(grnMaster.VendorId, out int vendorIdInt))
                        {
                            var vendor = db.AP_Vendors.FirstOrDefault(v => v.Vendor_ID == vendorIdInt);
                            if (vendor != null)
                            {
                                vendorName = vendor.Vendor_Name;
                            }
                        }
                    }

                    string warehouseName = db.GetDataValueName("Ware House", grnMaster.InvOrgId);

                    string selectionNum = GenerateSelectionNumber(db);

                    Guid currentUserId = GetCurrentUserId(db);

                    ItemSelection_Master selection = new ItemSelection_Master
                    {
                        Selection_Num = selectionNum,
                        Selection_Date = DateTime.Parse(selectionDate),
                        GRN_ID = grnId,
                        GRN_Num = Convert.ToString(grnMaster.GRN_Num),
                        VendorId = !string.IsNullOrEmpty(grnMaster.VendorId) ? Convert.ToInt32(grnMaster.VendorId) : 0,
                        VendorName = vendorName,
                        WarehouseId = grnMaster.InvOrgId,
                        WarehouseName = warehouseName,
                        Remarks = remarks ?? "",
                        Status = "Created",
                        Total_Items = selectedItems.Count,
                        Total_Barcodes = 0,
                        Created_By = currentUserId,
                        Creation_Date = DateTime.Now,
                        Company_ID = grnMaster.Company_ID ?? 1
                    };

                    db.ItemSelection_Masters.InsertOnSubmit(selection);
                    db.SubmitChanges();

                    int totalSelectedQty = 0;

                    foreach (var selectedItem in selectedItems)
                    {
                        var grnDetail = db.GRN_Details.FirstOrDefault(gd => gd.GRN_detail_Id == selectedItem.GRN_Detail_Id);
                        var item = db.INV_Items.FirstOrDefault(i => i.Item_ID == selectedItem.Item_Id);

                        if (grnDetail != null)
                        {
                            string unitName = db.GetDataValueName("UOM", item?.Unit);

                            ItemSelection_Detail detail = new ItemSelection_Detail
                            {
                                Selection_ID = selection.Selection_ID,
                                GRN_Detail_Id = selectedItem.GRN_Detail_Id,
                                GRN_ID = grnId,
                                ItemCode = grnDetail.ItemCode ?? "",
                                Item_Id = selectedItem.Item_Id,
                                ItemName = item != null ? item.Description : "",
                                GRN_Qty = selectedItem.Max_Qty,
                                Selected_Qty = selectedItem.Selected_Qty,
                                BatchNum = grnDetail.BatchNum ?? "",
                                Unit = unitName,
                                Rate = grnDetail.Rate ?? 0
                            };

                            db.ItemSelection_Details.InsertOnSubmit(detail);
                            totalSelectedQty += (int)selectedItem.Selected_Qty;
                        }
                    }

                    db.SubmitChanges();

                    return new JavaScriptSerializer().Serialize(new
                    {
                        Success = true,
                        Data = new
                        {
                            SelectionID = selection.Selection_ID,
                            SelectionNum = selectionNum,
                            TotalItems = selectedItems.Count,
                            TotalSelectedQty = totalSelectedQty
                        }
                    });
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new
                {
                    Success = false,
                    Message = ex.Message
                });
            }
        }

        [WebMethod]
        public static string GenerateBarcodes(int selectionId)
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var selection = db.ItemSelection_Masters.FirstOrDefault(s => s.Selection_ID == selectionId);
                    if (selection == null)
                    {
                        return new JavaScriptSerializer().Serialize(new
                        {
                            Success = false,
                            Message = "Selection not found"
                        });
                    }

                    var details = db.ItemSelection_Details.Where(d => d.Selection_ID == selectionId).ToList();

                    if (details == null || !details.Any())
                    {
                        return new JavaScriptSerializer().Serialize(new
                        {
                            Success = false,
                            Message = "No items found in this selection"
                        });
                    }

                    List<BarcodeDto> generatedBarcodes = new List<BarcodeDto>();
                    int serialCounter = GetLastSerialNumber(db, selectionId) + 1;

                    foreach (var detail in details)
                    {
                        int quantityToGenerate = (int)detail.Selected_Qty;

                        if (quantityToGenerate <= 0)
                            continue;

                        for (int i = 1; i <= quantityToGenerate; i++)
                        {
                            string barcodeNumber = GenerateUniqueBarcode(selectionId, detail.Selection_Detail_Id, serialCounter);

                            string insertSql = @"
                        INSERT INTO ItemSelection_Barcode 
                        (Selection_ID, Selection_Detail_Id, GRN_ID, GRN_Detail_Id, Item_Id, 
                         ItemCode, ItemName, Barcode_Number, Serial_Number, Quantity, 
                         IsUsed, Generation_Date)
                        VALUES 
                        ({0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11})";

                            db.ExecuteCommand(insertSql,
                                selectionId,
                                detail.Selection_Detail_Id,
                                selection.GRN_ID,
                                detail.GRN_Detail_Id,
                                detail.Item_Id,
                                detail.ItemCode ?? "",
                                detail.ItemName ?? "",
                                barcodeNumber,
                                serialCounter,
                                1,
                                0,  
                                DateTime.Now
                            );
                            // inserting new ID 
                            int newBarcodeId = db.ItemSelection_Barcodes
                            .Where(b => b.Barcode_Number == barcodeNumber)
                            .Select(b => b.Barcode_ID)
                            .FirstOrDefault();
                            // inserting new ID 

                            generatedBarcodes.Add(new BarcodeDto
                            {
                                Barcode_ID = newBarcodeId,
                                Barcode_Number = barcodeNumber,
                                Serial_Number = serialCounter,
                                ItemCode = detail.ItemCode,
                                ItemName = detail.ItemName,
                                Quantity = 1,
                                Generation_Date = DateTime.Now,
                                GRN_ID = selection.GRN_ID,
                                GRN_Num = selection.GRN_Num
                            });

                            serialCounter++;
                        }
                    }

                    selection.Status = "Barcodes Generated";
                    selection.Total_Barcodes = generatedBarcodes.Count;
                    db.SubmitChanges();

                    return new JavaScriptSerializer().Serialize(new
                    {
                        Success = true,
                        Data = new
                        {
                            TotalBarcodes = generatedBarcodes.Count,
                            Barcodes = generatedBarcodes
                        }
                    });
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new
                {
                    Success = false,
                    Message = ex.Message
                });
            }
        }

        private static int GetLastSerialNumber(DataBaseDataContext db, int selectionId)
        {
            var lastBarcode = db.ItemSelection_Barcodes
                .Where(b => b.Selection_ID == selectionId)
                .OrderByDescending(b => b.Serial_Number)
                .FirstOrDefault();

            return lastBarcode != null ? lastBarcode.Serial_Number : 0;
        }

        [WebMethod]
        public static string GetBarcodesByGRN(int grnId)
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var barcodes = (from b in db.ItemSelection_Barcodes
                                    where b.GRN_ID == grnId
                                    orderby b.Generation_Date descending
                                    select new BarcodeDto
                                    {
                                        Barcode_Number = b.Barcode_Number,
                                        Serial_Number = b.Serial_Number,
                                        ItemCode = b.ItemCode,
                                        ItemName = b.ItemName,
                                        Quantity = Convert.ToInt32(b.Quantity),
                                        Generation_Date = Convert.ToDateTime(b.Generation_Date),
                                        IsUsed = Convert.ToBoolean(b.IsUsed),
                                        GRN_ID = b.GRN_ID
                                    }).ToList();

                    return new JavaScriptSerializer().Serialize(new
                    {
                        Success = true,
                        Data = barcodes
                    });
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new
                {
                    Success = false,
                    Message = ex.Message
                });
            }
        }

        [WebMethod]
        public static string MarkBarcodeAsUsed(string barcodeNumber)
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var barcode = db.ItemSelection_Barcodes.FirstOrDefault(b => b.Barcode_Number == barcodeNumber);
                    if (barcode == null)
                    {
                        return new JavaScriptSerializer().Serialize(new
                        {
                            Success = false,
                            Message = "Barcode not found"
                        });
                    }

                    if (barcode.IsUsed == true)
                    {
                        return new JavaScriptSerializer().Serialize(new
                        {
                            Success = false,
                            Message = "Barcode already used"
                        });
                    }

                    barcode.IsUsed = true;
                    barcode.Used_Date = DateTime.Now;
                    barcode.Used_By = GetCurrentUserId(db);
                    db.SubmitChanges();

                    return new JavaScriptSerializer().Serialize(new
                    {
                        Success = true,
                        Message = "Barcode marked as used successfully"
                    });
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new
                {
                    Success = false,
                    Message = ex.Message
                });
            }
        }

        [WebMethod]
        public static string GetBarcodeUsageReport(int grnId)
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var report = (from b in db.ItemSelection_Barcodes
                                  where b.GRN_ID == grnId
                                  group b by new { b.ItemCode, b.ItemName, b.IsUsed } into g
                                  select new
                                  {
                                      ItemCode = g.Key.ItemCode,
                                      ItemName = g.Key.ItemName,
                                      Status = g.Key.IsUsed == true? "Used": g.Key.IsUsed == false? "Not Used": "Unknown",
                                      Count = g.Count()
                                  }).ToList();

                    return new JavaScriptSerializer().Serialize(new
                    {
                        Success = true,
                        Data = report
                    });
                }
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new
                {
                    Success = false,
                    Message = ex.Message
                });
            }
        }

        private static string GenerateSelectionNumber(DataBaseDataContext db)
        {
            int maxId = db.ItemSelection_Masters.Any()
                ? db.ItemSelection_Masters.Max(s => s.Selection_ID)
                : 0;

            return (maxId + 1).ToString();
        }

        private static string GenerateUniqueBarcode(int selectionId, int detailId, int serialNumber)
        {
            Random random = new Random();
            int randomNum = random.Next(1000, 9999);
            return $"BC-{selectionId}-{detailId}-{serialNumber}-{randomNum}";
        }

        private static Guid GetCurrentUserId(DataBaseDataContext db)
        {
            string userId = System.Web.HttpContext.Current.User.Identity.Name ?? "System";

            var user = db.aspnet_Users.FirstOrDefault(u => u.UserName == userId);
            if (user != null)
            {
                return user.UserId;
            }

            return new Guid("2B7EC93C-C751-4538-A5CA-2EAD11D65023");
        }
    }

    public class GRNListDto
    {
        public int GRN_ID { get; set; }
        public string GRN_Num { get; set; }
        public string VendorName { get; set; }
    }

    public class GRNDetailsDto
    {
        public int GRN_ID { get; set; }
        public string GRN_Num { get; set; }
        public string VendorName { get; set; }
        public string InvOrgId { get; set; }
        public string WarehouseName { get; set; }
        public List<GRNItemDto> Items { get; set; }
    }

    public class GRNItemDto
    {
        public int GRN_Detail_Id { get; set; }
        public int GRN_ID { get; set; }
        public string ItemCode { get; set; }
        public int Item_Id { get; set; }
        public decimal GRNQty { get; set; }
        public string BatchNum { get; set; }
        public decimal Rate { get; set; }
        public string ItemName { get; set; }
        public string Unit { get; set; }
        public decimal CurrentStock { get; set; }
    }

    public class SelectedItemDto
    {
        public int GRN_Detail_Id { get; set; }
        public int Item_Id { get; set; }
        public decimal Selected_Qty { get; set; }
        public decimal Max_Qty { get; set; }
    }

    public class BarcodeDto
    {
        public int Barcode_ID { get; set; }
        public string Barcode_Number { get; set; }
        public int Serial_Number { get; set; }
        public string ItemCode { get; set; }
        public string ItemName { get; set; }
        public decimal Quantity { get; set; }
        public DateTime Generation_Date { get; set; }
        public bool IsUsed { get; set; }
        public int GRN_ID { get; set; }
        public string GRN_Num { get; set; }
        public DateTime? Used_Date { get; set; }
    }

    public class ItemSelection_Barcode
    {
        [Key]
        public int Barcode_ID { get; set; }
        public int Selection_ID { get; set; }
        public int Selection_Detail_Id { get; set; }
        public int GRN_ID { get; set; }  
        public int GRN_Detail_Id { get; set; }  
        public int Item_Id { get; set; }
        public string ItemCode { get; set; }
        public string ItemName { get; set; }
        public string Barcode_Number { get; set; }
        public int Serial_Number { get; set; }
        public decimal Quantity { get; set; }
        public bool IsUsed { get; set; }
        public DateTime? Used_Date { get; set; }  
        public Guid? Used_By { get; set; }  
        public DateTime Generation_Date { get; set; }
    }
}