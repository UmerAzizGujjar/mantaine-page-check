using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.Administrator
{
    public partial class AssetSubsequentExpenseView : System.Web.UI.Page
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
                    string userId = HttpContext.Current.Session["UserId"].ToString();

                    var Total_Expense = _dbContext.Asset_Expenses.Count();
                    var Expense = from a in _dbContext.Asset_Expenses
                              join b in _dbContext.Asset_Expense_details
                              on a.Asset_Expense_ID equals b.Asset_Expense_ID
                              where (
                                    (a.Asset_ID.ToString().Contains(searchValue) || a.Asset_Value.Contains(searchValue) || a.Remarks.Contains(searchValue)))
                              select new
                              {
                                  Asset_Expense_ID = a.Asset_Expense_ID,
                                  Asset_ID = a.Asset_ID,
                                  Date = a.Date,
                                  Asset_Value = a.Asset_Value,
                                  Expense_Amount = b.Expense_Amount,
                                  Remarks = a.Remarks,
                              };

                    var FilteredCount = Expense.Count();
                    switch (sortColumn)
                    {
                        case "Asset_ID":
                            Expense = sortColumnDirection == "asc" ? Expense.OrderBy(a => a.Asset_ID) : Expense.OrderByDescending(a => a.Asset_ID);
                            break;
                        case "Expense_Amount":
                            Expense = sortColumnDirection == "asc" ? Expense.OrderBy(a => a.Expense_Amount) : Expense.OrderByDescending(a => a.Expense_Amount);
                            break;
                        default:
                            Expense = Expense.OrderByDescending(a => a.Asset_ID);
                            break;
                    }


                    var ExpenseList = Expense.Skip(start).Take(length).ToList();


                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Expense, data = ExpenseList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Expense list", ex);
            }
        }

    }
}