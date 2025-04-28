using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Data;
namespace PMS
{
    public class GL_Accounts
    {
        public DataTable getGL_Accounts(string book_Id)
        {
            string query = "SELECT Account_ID,Account_Code + ' - ' + Account_Name as Account_Name from GL_Accounts Where Levels=4 and Book_ID=" + book_Id + " Order by Account_Code;";
            DataTable dt = DBClass.getDataTable(query);
            return dt;

        }
    }
}