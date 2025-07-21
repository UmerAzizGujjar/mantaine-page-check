using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;

namespace PMS
{
    /// <summary>
    /// Summary description for UploadIGP
    /// </summary>
    public class UploadIGP : IHttpHandler
    {

        public void ProcessRequest(HttpContext context)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            AP_Purchase_Order obj = new AP_Purchase_Order();
            var IgpId = Convert.ToInt32(context.Request.Form["ID"]);
            context.Response.ContentType = "text/plain";
            try
            {
                string dirFullPath = context.Server.MapPath("~/upload/IGPFileImages/");
                string[] files;
                files = System.IO.Directory.GetFiles(dirFullPath);
                string str_image = "";
                var query = (from data in db.Igp_masters.Where(x => x.Igp_Id.Equals(IgpId))
                             select data).FirstOrDefault();
                foreach (string s in context.Request.Files)
                {
                    HttpPostedFile file = context.Request.Files[s];
                    string fileName = file.FileName;
                    string fileExtension = file.ContentType;
                    if (!string.IsNullOrEmpty(fileName))
                    {
                        fileExtension = Path.GetExtension(fileName);
                        str_image = IgpId.ToString() + fileExtension;
                        string pathToSave = context.Server.MapPath("~/upload/IGPFileImages/") + str_image;
                        string image_path = "~/upload/IGPFileImages/" + str_image;
                        if (System.IO.File.Exists(context.Server.MapPath(image_path)))
                        {
                            // file exist
                            string savePath = HttpContext.Current.Server.MapPath(image_path);
                            System.IO.File.Delete(savePath);
                            string sql = "update Igp_master set File_Path ='" + image_path + "' where Igp_Id="+IgpId;
                            DBClass.executeNonQueryWithoutBegin(sql);
                        }
                        file.SaveAs(pathToSave);
                        query.File_Path = image_path;
                        query.File_Type = fileExtension;
                    }
                }
                try
                {
                    db.SubmitChanges();
                }
                catch (Exception)
                {

                    throw;
                }
                context.Response.Write(str_image);
            }
#pragma warning disable CS0168 // The variable 'ac' is declared but never used
            catch (Exception ac)
#pragma warning restore CS0168 // The variable 'ac' is declared but never used
            {

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