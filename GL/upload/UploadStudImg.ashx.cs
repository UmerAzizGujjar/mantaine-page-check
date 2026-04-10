using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;

namespace PMS
{
    /// <summary>
    /// Summary description for UploadStudImg
    /// </summary>
    public class UploadStudImg : IHttpHandler
    {

        public void ProcessRequest(HttpContext context)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            Reg_Student obj = new Reg_Student();
            int Studid = Convert.ToInt32(context.Request.Form["ID"]);

            context.Response.ContentType = "text/plain";

            try
            {
                string dirFullPath = context.Server.MapPath("~../../../../wwwroot/images/StudentImages/");

                if (!Directory.Exists(dirFullPath))
                {
                    Directory.CreateDirectory(dirFullPath);
                }

                string str_image = "";
                string image_path = "";

                var query = db.Reg_Students.FirstOrDefault(x => x.Student_Id == Studid);
                if (query == null)
                {
                    context.Response.Write("Student not found");
                    return;
                }

                string oldpath = query.Picture;

                foreach (string s in context.Request.Files)
                {
                    HttpPostedFile file = context.Request.Files[s];
                    string fileName = file.FileName;
                    if (!string.IsNullOrEmpty(fileName))
                    {
                        string fileExtension = Path.GetExtension(fileName);
                        str_image = $"{Studid}{fileExtension}";
                        string pathToSave = Path.Combine(dirFullPath, str_image);
                        image_path = $"~../../../../wwwroot/images/StudentImages/{str_image}";

                        if (!string.IsNullOrEmpty(oldpath))
                        {
                            string oldFilePath = context.Server.MapPath("~" + oldpath);
                            if (File.Exists(oldFilePath))
                            {
                                File.Delete(oldFilePath);
                            }
                        }

                        file.SaveAs(pathToSave);

                        query.Picture = image_path;
                    }
                }

                db.SubmitChanges();

                context.Response.Write(str_image);
            }
            catch (Exception ex)
            {
                context.Response.Write("Error: " + ex.Message);
            }
        }



        public bool IsReusable
        {
            get
            {
                return false;
            }
        }
    }
}