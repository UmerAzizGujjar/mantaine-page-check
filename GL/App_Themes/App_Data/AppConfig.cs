using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Configuration;

/// <summary>
/// Summary description for AppConfig
/// </summary>
public class AppConfig
{
	public AppConfig()
	{
		//
		// TODO: Add constructor logic here
		//
	}
    public static string UserName
    {
        get { return HttpContext.Current.Session["UserName"].ToString(); }
    }
    public static Guid UserID
    {
        get { return new Guid(HttpContext.Current.Session["UserID"].ToString()); }
    }
    public static string Company_Name
    {
        get { return HttpContext.Current.Session["Company_Name"].ToString(); }
    }
    public static Int32 Company_ID
    {
        get { return Convert.ToInt32(HttpContext.Current.Session["Company_ID"].ToString()); }
    }
    public static int Book_ID
    {
        get { return Convert.ToInt32(HttpContext.Current.Session["Book_ID"].ToString()); }
    }
    public static string DateFormat
    {
        get { return "MM/dd/yyyy"; }
    }
    public static string userDesignationDegree = string.Empty;
    public static bool AllowToAccessAllTest = false;
}