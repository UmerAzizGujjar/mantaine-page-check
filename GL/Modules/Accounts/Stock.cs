using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace PMS
{
    public class Stock
    {
        public int stockTransferId { get; set; }
        public int stockTransferNo { get; set; }
        public DateTime stockTransferDate { get; set; }
        public string wareHouseFrom { get; set; }
        public string wareHouseTo { get; set; }
        public string createdBy { get; set; }
        public DateTime creationTime { get; set; }
        public string updatedBy { get; set; }
        public DateTime updatedTime { get; set; }
        public string approvedBy { get; set; }
        public DateTime approvedTime { get; set; }
        public string stnStatus { get; set; }
        public int stockTransferItemId { get; set; }
        public string itemCode { get; set; }
        public string batchNo { get; set; }
        public int quantity { get; set; }
        public decimal Rate { get; set; }
        public decimal Amount { get; set; }
        public string description { get; set; }
        public string expiryDate { get; set; }
        public string remarks { get; set; }
        public string Transfer_Status { get; set; }
        public decimal stockAvailable { get; set; }
    }
}