using CrystalDecisions.CrystalReports.Engine;
using System;
using System.IO;
using System.Security.Principal;
using System.Web;
using System.Web.Security;
using System.Web.SessionState;

namespace PMS
{
    public class Global : System.Web.HttpApplication
    {
        void Application_Start(object sender, EventArgs e)
        {
            // Code that runs on application startup
            // Example: Initialize cache, app settings, etc.
        }

        void Application_End(object sender, EventArgs e)
        {
            // Code that runs on application shutdown
        }
    //    void Application_BeginRequest(object sender, EventArgs e)
    //    {
    //        var context = HttpContext.Current;
    //        if (context == null) return;

    //        // 🎯 CONFIGURE YOUR LOGIN PATH(S) HERE 👇
    //        string[] protectedPaths = {
    //    "~/login.aspx",
    //    "~/account/login.aspx"
    //    // Add more if needed
    //};

    //        string currentPath = context.Request.AppRelativeCurrentExecutionFilePath.ToLower();
    //        bool isProtectedPath = Array.Exists(protectedPaths, path => currentPath == path.ToLower());
    //        if (!isProtectedPath) return;

    //        // ✅ GET CLIENT IP — HANDLE PROXIES
    //        string ip = context.Request.Headers["X-Forwarded-For"] ?? context.Request.UserHostAddress;
    //        if (string.IsNullOrEmpty(ip) || ip == "::1" || ip.ToLower().StartsWith("::ffff:"))
    //            ip = "127.0.0.1"; // Fallback for localhost

    //        string cacheKey = $"LoginRateLimit_{ip}";
    //        int requestCount = HttpRuntime.Cache[cacheKey] as int? ?? 0;

    //        // ⚠️ CHECK IF THIS IS A POST WITH CREDENTIALS (UserName + Password)
    //        bool isCredentialPost = context.Request.HttpMethod == "POST" &&
    //                                !string.IsNullOrEmpty(context.Request.Form["ctl00$MainContent$UserLogin$UserName"]) &&
    //                                !string.IsNullOrEmpty(context.Request.Form["ctl00$MainContent$UserLogin$Password"]);

    //        // 🔒 BLOCK NON-CREDENTIAL REQUESTS IF OVER LIMIT (e.g., bots, empty form spam)
    //        if (requestCount >= 5 && !isCredentialPost)
    //        {
    //            bool isAjax = context.Request.Headers["X-Requested-With"] == "XMLHttpRequest" ||
    //                          context.Request.Headers["X-MicrosoftAjax"] == "Delta=true";

    //            if (isAjax)
    //            {
    //                context.Response.Clear();
    //                context.Response.StatusCode = 200;
    //                context.Response.ContentType = "application/json";
    //                context.Response.Write("{ \"isRateLimited\": true, \"message\": \"Too many login attempts. Please wait 1 minute.\" }");
    //                context.ApplicationInstance.CompleteRequest();
    //                return;
    //            }
    //            else
    //            {
    //                HttpContext.Current.Items["LoginRateLimited"] = true;
    //                HttpContext.Current.Items["LoginRateLimitMessage"] = "Too many login attempts. Please wait 1 minute.";
    //                context.Response.StatusCode = 429;
    //                context.Response.TrySkipIisCustomErrors = true;
    //                return;
    //            }
    //        }

    //        // ✅ ALLOW CREDENTIAL POSTS EVEN IF OVER LIMIT — BUT STILL COUNT THEM
    //        int newCount = requestCount + 1;
    //        HttpRuntime.Cache.Insert(
    //            cacheKey,
    //            newCount,
    //            null,
    //            DateTime.Now.AddMinutes(1),
    //            System.Web.Caching.Cache.NoSlidingExpiration
    //        );

    //        // ⚠️ IF OVER LIMIT AND CREDENTIAL POST → FLAG FOR WARNING (but allow processing)
    //        if (newCount > 5 && isCredentialPost)
    //        {
    //            context.Items["LoginRateLimited"] = true;
    //            context.Items["LoginRateLimitMessage"] = "Too many login attempts. Please slow down.";
    //            // Let request continue → LoginButton_Click will handle password validation + lockout
    //        }
    //    }
        void Application_Error(object sender, EventArgs e)
        {
            // 🔒 UNIVERSAL ERROR HANDLER — CATCHES EVERYTHING

            Exception ex = Server.GetLastError();

            // 🧾 Generate unique error reference ID for tracking
            string errorId = Guid.NewGuid().ToString("N").Substring(0, 8);

            // 📝 FAILSAFE LOGGING — never crash due to logging failure
            try
            {
                if (ex != null)
                {
                    string logMessage = $"[ERROR:{errorId} {DateTime.Now}]\n" +
                                        $"Type: {ex.GetType().Name}\n" +
                                        $"Message: {ex.Message}\n" +
                                        $"Stack Trace: {ex.StackTrace}\n" +
                                        $"Source: {ex.Source}\n" +
                                        $"URL: {Request?.Url}\n" +
                                        $"User: {User?.Identity?.Name ?? "Anonymous"}\n\n";

                    string logPath = Server.MapPath("~/App_Data/GlobalErrorLog.txt");
                    string logDir = Path.GetDirectoryName(logPath);

                    // Ensure App_Data folder exists
                    if (!Directory.Exists(logDir))
                        Directory.CreateDirectory(logDir);

                    File.AppendAllText(logPath, logMessage);
                }
            }
            catch { /* Silent fail — never break error handling */ }

            // ✅ CLEAR ERROR — prevent YSOD (Yellow Screen of Death)
            Server.ClearError();

            var context = HttpContext.Current;

            if (context == null) return;

            try
            {
                // 🔄 ONLY redirect for real server errors — not for JS/client issues
                if (context.Request.Headers["X-Requested-With"] == "XMLHttpRequest")
                {
                    // For AJAX — return error info, let JS decide to redirect or show toast
                    context.Response.Clear();
                    context.Response.ContentType = "application/json";

                    // Only send redirect if it's a FATAL error (you can customize logic)
                    bool isFatal = ex != null && !(ex is ArgumentNullException || ex is ArgumentException);

                    if (isFatal)
                    {
                        context.Response.Write($"{{ \"redirect\": \"/Modules/Others/CustomError.aspx\", \"errorId\": \"{errorId}\", \"fatal\": true }}");
                    }
                    else
                    {
                        context.Response.Write($"{{ \"message\": \"{ex?.Message ?? "Unknown error"}\", \"errorId\": \"{errorId}\", \"fatal\": false }}");
                    }

                    context.Response.End();
                }
                else
                {
                    if (context.Response.IsClientConnected)
                    {
                        context.Response.Redirect("/Modules/Others/CustomError.aspx", false);
                        context.ApplicationInstance.CompleteRequest();
                    }
                }
            }
            catch { /* Silent fail */ }
        }

        void Session_Start(object sender, EventArgs e)
        {
            // Code that runs when a new session is started
        }

        void Session_End(object sender, EventArgs e)
        {
            // ✅ CLEANUP CRYSTAL REPORTS OBJECTS
            ReportDocument reportdocument = Session["report"] as ReportDocument;
            if (reportdocument != null)
            {
                try
                {
                    reportdocument.Close();
                    reportdocument.Dispose();
                }
                catch (Exception ex)
                {
                    // Log silently — don't break session end
                    try
                    {
                        string logPath = Server.MapPath("~/App_Data/SessionCleanupLog.txt");
                        File.AppendAllText(logPath, $"[SESSION CLEANUP ERROR {DateTime.Now}] {ex.Message}\n\n");
                    }
                    catch { }
                }
                finally
                {
                    Session["report"] = null;
                    GC.Collect(); // Optional: Force garbage collection
                }
            }

            // Note: Session_End only fires if sessionState mode="InProc"
        }

        protected void Application_AuthenticateRequest(Object sender, EventArgs e)
        
        {
            if (HttpContext.Current?.User != null)
            {
                if (HttpContext.Current.User.Identity.IsAuthenticated)
                {
                    if (HttpContext.Current.User.Identity is FormsIdentity formsIdentity)
                    {
                        FormsAuthenticationTicket ticket = formsIdentity.Ticket;

                        // Get roles from UserData (assumes comma-separated roles in ticket)
                        string userData = ticket.UserData;
                        string[] roles = !string.IsNullOrEmpty(userData) ? userData.Split(',') : new string[0];

                        // Attach roles to current principal
                        HttpContext.Current.User = new GenericPrincipal(formsIdentity, roles);
                    }
                }
            }
        }
    }
}