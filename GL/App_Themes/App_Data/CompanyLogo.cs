using System;
using System.Configuration;
using System.IO;
using System.Text.RegularExpressions;
using System.Web;

namespace PMS
{
    /// <summary>
    /// Resolves a company's logo for the login page and the site header.
    /// 1. The file the Add Company form saves in ~/wwwroot/CompanyImages (path kept in sys_Companys.ImageURL).
    /// 2. Otherwise the active theme's own logo (~/wwwroot/THEME_xxx/images/...), so every theme falls back to its own branding.
    /// </summary>
    public static class CompanyLogo
    {
        public const string FolderUrl = "~/wwwroot/CompanyImages/";

        private const string FallbackTheme = "THEME_TIBBIT";

        // where a theme may keep its logo, best match first
        private static readonly string[] ThemeLogoFolders = { "images/LOGOS", "images/CompanyImages", "images/Standard_icons", "images/AsiratIcons" };
        private static readonly string[] LogoExtensions = { "png", "jpg", "jpeg", "svg", "webp", "gif" };

        private static readonly Regex SafeFileName =
            new Regex(@"^[\w\- ]+\.(png|jpg|jpeg|gif|webp)$", RegexOptions.IgnoreCase | RegexOptions.Compiled);
        private static readonly Regex ThemeInMaster =
            new Regex(@"wwwroot/(THEME_[A-Za-z0-9_]+)/", RegexOptions.Compiled);

        private static string _detectedTheme;

        /// <summary>
        /// Active theme folder name. Web.config appSettings "Theme" wins if set; otherwise it is read from the
        /// theme path used by Site.Master, so changing the theme there changes the fallback logo as well.
        /// </summary>
        public static string ThemeName
        {
            get
            {
                string configured = ConfigurationManager.AppSettings["Theme"];
                if (!string.IsNullOrWhiteSpace(configured)) return configured.Trim();

                if (_detectedTheme == null)
                {
                    string found = FallbackTheme;
                    try
                    {
                        string master = File.ReadAllText(HttpContext.Current.Server.MapPath("~/Site.Master"));
                        Match m = ThemeInMaster.Match(master);
                        if (m.Success) found = m.Groups[1].Value;
                    }
                    catch { }
                    _detectedTheme = found;
                }
                return _detectedTheme;
            }
        }

        /// <summary>App-relative URL of the company's uploaded logo, or null if there is none.</summary>
        public static string GetUrlOrNull(int companyId)
        {
            if (companyId <= 0) return null;
            try
            {
                string savedPath = DBClass.getField("Select ImageURL From sys_Companys Where Company_ID=" + companyId);
                // only the file name is trusted; the folder is fixed
                string fileName = Path.GetFileName((savedPath ?? string.Empty).Trim());
                if (!SafeFileName.IsMatch(fileName)) return null;

                string physical = HttpContext.Current.Server.MapPath(FolderUrl + fileName);
                if (!File.Exists(physical)) return null;

                // version the URL so a re-uploaded logo (same file name) is not served from cache
                return FolderUrl + fileName + "?v=" + File.GetLastWriteTimeUtc(physical).Ticks;
            }
            catch
            {
                return null;
            }
        }

        /// <summary>
        /// The active theme's own logo. With wide = true a "logo-16x9" file is preferred (sharper in the
        /// login page's 16:9 plate); both fall back to the plain "logo" file.
        /// </summary>
        public static string GetDefaultUrl(bool wide)
        {
            string theme = ThemeName;
            string[] baseNames = wide ? new[] { "logo-16x9", "logo" } : new[] { "logo" };
            try
            {
                HttpServerUtility server = HttpContext.Current.Server;
                foreach (string baseName in baseNames)
                    foreach (string folder in ThemeLogoFolders)
                        foreach (string ext in LogoExtensions)
                        {
                            string url = "~/wwwroot/" + theme + "/" + folder + "/" + baseName + "." + ext;
                            if (File.Exists(server.MapPath(url))) return url;
                        }
            }
            catch { }
            return "~/wwwroot/" + theme + "/images/LOGOS/logo.png";
        }

        /// <summary>Company logo, else the active theme's logo (site header).</summary>
        public static string GetUrl(int companyId)
        {
            return GetUrlOrNull(companyId) ?? GetDefaultUrl(false);
        }
    }
}
