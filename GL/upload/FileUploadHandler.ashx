<%@ WebHandler Language="C#" Class="FileUploadHandler" %>

using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Configuration;
using System.IO;
using System.Web.Script.Serialization;

public class FileUploadHandler : IHttpHandler
{
    public void ProcessRequest(HttpContext context)
    {
        try
        {
            if (context.Request.QueryString["upload"] != null)
            {
                string pathrefer = context.Request.UrlReferrer.ToString();
                string Serverpath = HttpContext.Current.Server.MapPath("LabTestImg");

                var postedFile = context.Request.Files[0];

                string file;
                

                //For IE to get file name
                if (HttpContext.Current.Request.Browser.Browser.ToUpper() == "IE")
                {
                    string[] files = postedFile.FileName.Split(new char[] { '\\' });
                    file = files[files.Length - 1];
                }
                else
                {
                    file = postedFile.FileName;
                }


                if (!Directory.Exists(Serverpath))
                    Directory.CreateDirectory(Serverpath);

                string fileDirectory = Serverpath;
                if (context.Request.QueryString["fileName"] != null)
                {

                    file = context.Request.QueryString["fileName"];
                    
                    if (File.Exists(fileDirectory + "\\" + file))
                    {
                        File.Delete(fileDirectory + "\\" + file);
                    }
                }

                string ext = Path.GetExtension(fileDirectory + "\\" + file);
                string dateTime = DateTime.Now.ToString("MM/dd/yyyy hh:mm").Replace("/", "").Replace(" ", "").Replace(":", "");
                string filenameWithoutExt = System.IO.Path.GetFileNameWithoutExtension(file);
                
                string filename = System.IO.Path.GetFileName(file);
                string fileFullName = filenameWithoutExt + "_" + dateTime + ext;
               // fileFullName = Guid.NewGuid() + ext;

                fileDirectory = Serverpath + "\\" + fileFullName;

             
                
                
                
                
                postedFile.SaveAs(fileDirectory);

                context.Response.AddHeader("Vary", "Accept");
                try
                {
                    if (context.Request["HTTP_ACCEPT"].Contains("application/json"))
                        context.Response.ContentType = "application/json";
                    else
                        context.Response.ContentType = "text/plain";
                }
                catch
                {
                    context.Response.ContentType = "text/plain";
                }
                context.Response.Write(postedFile.FileName + ":" + fileFullName);
                
                //context.Response.Write("Success");
            }
        }
        catch (Exception exp)
        {
            context.Response.Write(exp.Message);
        }
        //try
        //{
        //    if (context.Request.QueryString["Documentupload"] != null)
        //    {
        //        string pathrefer = context.Request.UrlReferrer.ToString();
        //        string Serverpath = HttpContext.Current.Server.MapPath("Documentuploads");

        //        var postedFile = context.Request.Files[0];

        //        string file;


        //        //For IE to get file name
        //        if (HttpContext.Current.Request.Browser.Browser.ToUpper() == "IE")
        //        {
        //            string[] files = postedFile.FileName.Split(new char[] { '\\' });
        //            file = files[files.Length - 1];
        //        }
        //        else
        //        {
        //            file = postedFile.FileName;
        //        }


        //        if (!Directory.Exists(Serverpath))
        //            Directory.CreateDirectory(Serverpath);

        //        string fileDirectory = Serverpath;
        //        if (context.Request.QueryString["fileName"] != null)
        //        {

        //            file = context.Request.QueryString["fileName"];

        //            if (File.Exists(fileDirectory + "\\" + file))
        //            {
        //                File.Delete(fileDirectory + "\\" + file);
        //            }
        //        }

        //        string ext = Path.GetExtension(fileDirectory + "\\" + file);
        //        file = Guid.NewGuid() + ext;

        //        fileDirectory = Serverpath + "\\" + file;

        //        postedFile.SaveAs(fileDirectory);

        //        context.Response.AddHeader("Vary", "Accept");
        //        try
        //        {
        //            if (context.Request["HTTP_ACCEPT"].Contains("application/json"))
        //                context.Response.ContentType = "application/json";
        //            else
        //                context.Response.ContentType = "text/plain";
        //        }
        //        catch
        //        {
        //            context.Response.ContentType = "text/plain";
        //        }
        //        context.Response.Write(postedFile.FileName + ":" + file);
        //        //context.Response.Write("Success");
        //    }
        //}
        //catch (Exception exp)
        //{
        //    context.Response.Write(exp.Message);
        //}


        //try
        //{
        //    if (context.Request.QueryString["imeges"] != null)
        //    {
        //        string pathrefer = context.Request.UrlReferrer.ToString();
        //        string Serverpath = HttpContext.Current.Server.MapPath("images/employees/");

        //        var postedFile = context.Request.Files[0];

        //        string file;


        //        //For IE to get file name
        //        if (HttpContext.Current.Request.Browser.Browser.ToUpper() == "IE")
        //        {
        //            string[] files = postedFile.FileName.Split(new char[] { '\\' });
        //            file = files[files.Length - 1];
        //        }
        //        else
        //        {
        //            file = postedFile.FileName;
        //        }


        //        if (!Directory.Exists(Serverpath))
        //            Directory.CreateDirectory(Serverpath);

        //        string fileDirectory = Serverpath;
        //        if (context.Request.QueryString["fileName"] != null)
        //        {

        //            file = context.Request.QueryString["fileName"];

        //            if (File.Exists(fileDirectory + "\\" + file))
        //            {
        //                File.Delete(fileDirectory + "\\" + file);
        //            }
        //        }

        //        string ext = Path.GetExtension(fileDirectory + "\\" + file);
               

        //        fileDirectory = Serverpath + "\\" + file;

        //        postedFile.SaveAs(fileDirectory);

        //        context.Response.AddHeader("Vary", "Accept");
        //        try
        //        {
        //            if (context.Request["HTTP_ACCEPT"].Contains("application/json"))
        //                context.Response.ContentType = "application/json";
        //            else
        //                context.Response.ContentType = "text/plain";
        //        }
        //        catch
        //        {
        //            context.Response.ContentType = "text/plain";
        //        }
        //        context.Response.Write(postedFile.FileName);
        //        //context.Response.Write("Success");
        //    }
        //}
        //catch (Exception exp)
        //{
        //    context.Response.Write(exp.Message);
        //}




        //try
        //{
        //    if (context.Request.QueryString["Pic"] != null)
        //    {
        //        string pathrefer = context.Request.UrlReferrer.ToString();
        //        string Serverpath = HttpContext.Current.Server.MapPath("images/employees/");

        //        var postedFile = context.Request.Files[0];

        //        string file;


        //        //For IE to get file name
        //        if (HttpContext.Current.Request.Browser.Browser.ToUpper() == "IE")
        //        {
        //            string[] files = postedFile.FileName.Split(new char[] { '\\' });
        //            file = files[files.Length - 1];
        //        }
        //        else
        //        {
        //            file = postedFile.FileName;
        //        }


        //        if (!Directory.Exists(Serverpath))
        //            Directory.CreateDirectory(Serverpath);

        //        string fileDirectory = Serverpath;
        //        if (context.Request.QueryString["fileName"] != null)
        //        {

        //            file = context.Request.QueryString["fileName"];

        //            if (File.Exists(fileDirectory + "\\" + file))
        //            {
        //                File.Delete(fileDirectory + "\\" + file);
        //            }
        //        }

        //        string ext = Path.GetExtension(fileDirectory + "\\" + file);


        //        fileDirectory = Serverpath + "\\" + file;

        //        postedFile.SaveAs(fileDirectory);

        //        context.Response.AddHeader("Vary", "Accept");
        //        try
        //        {
        //            if (context.Request["HTTP_ACCEPT"].Contains("application/json"))
        //                context.Response.ContentType = "application/json";
        //            else
        //                context.Response.ContentType = "text/plain";
        //        }
        //        catch
        //        {
        //            context.Response.ContentType = "text/plain";
        //        }
        //        context.Response.Write(postedFile.FileName);
        //        //context.Response.Write("Success");
        //    }
        //}
        //catch (Exception exp)
        //{
        //    context.Response.Write(exp.Message);
        //}
        
        
        
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }
}

