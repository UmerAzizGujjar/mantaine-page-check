using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.Others
{
    public partial class CustomError : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Get the last error
            Exception ex = Server.GetLastError();

            if (ex != null)
            {
                // 🔒 LOG THE ERROR (Example: write to file or database)
                // ⚠️ NEVER show ex.ToString() to user!

                string logMessage = $"[{DateTime.Now}] Error: {ex.Message}\n{ex.StackTrace}\n\n";

                // Example: Log to a file (you can replace with DB, NLog, etc.)
                string logPath = Server.MapPath("~/App_Data/ErrorLog.txt");
                System.IO.File.AppendAllText(logPath, logMessage);

                // Clear the error so it doesn't bubble up
                Server.ClearError();
            }
        }
    }
}
