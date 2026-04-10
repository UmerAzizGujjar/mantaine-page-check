using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;

namespace PMS
{
    public class UploadStudImg : IHttpHandler
    {
        public void ProcessRequest(HttpContext context)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            context.Response.ContentType = "text/plain";

            try
            {
                string studentIdStr = context.Request.Form["ID"];
                if (string.IsNullOrEmpty(studentIdStr))
                {
                    context.Response.Write("Error: Student ID is missing");
                    return;
                }

                int Studid = Convert.ToInt32(studentIdStr);
                string dirFullPath = context.Server.MapPath("~/wwwroot/images/StudentImages/");

                if (!Directory.Exists(dirFullPath))
                {
                    Directory.CreateDirectory(dirFullPath);
                }

                if (context.Request.Files.Count == 0)
                {
                    context.Response.Write("No file uploaded");
                    return;
                }

                string str_image = "";
                string image_path = "";
                bool fileSaved = false;

                var query = db.Reg_Students.FirstOrDefault(x => x.Student_Id == Studid);
                if (query == null)
                {
                    context.Response.Write("Error: Student not found");
                    return;
                }

                string oldpath = query.Picture;

                foreach (string s in context.Request.Files)
                {
                    HttpPostedFile file = context.Request.Files[s];
                    if (file != null && file.ContentLength > 0)
                    {
                        string fileName = file.FileName;
                        if (!string.IsNullOrEmpty(fileName))
                        {
                            string fileExtension = Path.GetExtension(fileName);
                            str_image = $"{Studid}{fileExtension}";
                            string pathToSave = Path.Combine(dirFullPath, str_image);
                            image_path = "/wwwroot/images/StudentImages/" + str_image;

                            if (!string.IsNullOrEmpty(oldpath))
                            {
                                try
                                {
                                    string cleanOldPath = oldpath.TrimStart('~', '/');
                                    string oldFilePath = context.Server.MapPath("~/" + cleanOldPath);
                                    if (File.Exists(oldFilePath))
                                    {
                                        File.Delete(oldFilePath);
                                    }
                                }
                                catch (Exception ex)
                                {
                                    context.Response.Write($"Warning: {ex.Message}\n");
                                }
                            }

                            file.SaveAs(pathToSave);
                            fileSaved = true;
                            if (File.Exists(pathToSave))
                            {
                                query.Picture = image_path;
                            }
                            else
                            {
                                context.Response.Write($"Error: File not saved at {pathToSave}");
                                return;
                            }
                        }
                    }
                }

                if (fileSaved)
                {
                    db.SubmitChanges();
                    context.Response.Write($"{Studid}|{str_image}");
                }
                else
                {
                    context.Response.Write("Error: No valid file processed");
                }
            }
            catch (Exception ex)
            {
                context.Response.Write($"Error: {ex.Message}");
            }
        }

        public bool IsReusable
        {
            get { return false; }
        }
    }
}