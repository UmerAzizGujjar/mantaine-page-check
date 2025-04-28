using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace PMS
{
    public class PublicMethods
    {

        public const string DateFormat = "MM/dd/yyyy";
        public const string strAccountsSQL = "select Account_Id, Account_Code as [Account Code], Account_Name as [Account Name] from GL_Accounts where levels=4 order by Account_Code";
        public static string CompanyName;

        public static string LastDayOfMonth(DateTime pdtmDate)
        {
            DateTime dtmDate = new DateTime(pdtmDate.Year, pdtmDate.Month, 1);
            return dtmDate.AddMonths(1).AddDays(-1).Date.ToString("dd-MMM-yyyy");
        }
    }
}