using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using Telerik.Web.UI;

namespace PMS
{
    public partial class TemplateList : System.Web.UI.Page
    {
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


                    var templates = _dbContext.Medicines_Templates.Count();
                    var tmp = from a in _dbContext.Medicines_Templates
                              where (a.Medicine_Name.ToString().Contains(searchValue) || a.Dosage_Qty.Contains(searchValue) || a.Other_Instruction.Contains(searchValue) )
                              select new 
                              {
                                  TemplateID = a.template_id,
                                  ItemCode = a.Item_Code,
                                  MedicineName = a.Medicine_Name,
                                  Frequency = a.Frequency,
                                  Oral = a.Oral,
                                  TransactionType = a.Transaction_Type,
                                  DosageFrom = a.Dosage_From,
                                  Dosage_Qty = a.Dosage_Qty,
                                  AttendingParamedical_Staff = a.AttendingParamedical_Staff,

                              };
                    var FilteredCount = tmp.Count();
                    switch (sortColumn)
                    {
                        case "Medicine_Name":
                            tmp = sortColumnDirection == "asc" ? tmp.OrderBy(a => a.MedicineName) : tmp.OrderByDescending(a => a.MedicineName);
                            break;
                        case "ItemCode":
                            tmp = sortColumnDirection == "asc" ? tmp.OrderBy(a => a.ItemCode) : tmp.OrderByDescending(a => a.ItemCode);
                            break;

                    }


                    var templatelist = tmp.Skip(start).Take(length).ToList();


                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = templates, data = templatelist };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Medicine Template list", ex);
            }
        }
     
        [WebMethod]
        public static bool DeleteRecord(string itemID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                try
                {
                    int id = int.Parse(itemID);
                    var item = db.INV_Items.SingleOrDefault(i => i.Item_ID == id);

                    if (item != null)
                    {
                        db.INV_Items.DeleteOnSubmit(item);
                        db.SubmitChanges();
                        return true;
                    }
                    return false;
                }
                catch (Exception)
                {
                    return false;
                }
            }
        }
    }

 
}
