using System;
using System.IO;
using System.Linq;
using System.Web;

namespace PMS
{
    public class UploadGRNFiles : IHttpHandler
    {

        public void ProcessRequest(HttpContext context)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var GRNID = Convert.ToInt32(context.Request.Form["ID"]);
            context.Response.ContentType = "text/plain";
            try
            {
                string dirFullPath = context.Server.MapPath("~/upload/UploadGRNFilesImages/");
                string[] files;
                files = System.IO.Directory.GetFiles(dirFullPath);
                string str_image = "";
                string image_path = "";
                var query = (from data in db.GRN_Masters.Where(x => x.GRN_ID.Equals(GRNID))
                             select data).FirstOrDefault();
                string oldpath = query.File_Path;
                string oldext = query.File_Type;
                foreach (string s in context.Request.Files)
                {
                    HttpPostedFile file = context.Request.Files[s];
                    string fileName = file.FileName;
                    string fileExtension = file.ContentType;
                    if (!string.IsNullOrEmpty(fileName))
                    {
                        fileExtension = Path.GetExtension(fileName);
                        str_image = GRNID.ToString() + fileExtension;
                        string pathToSave = context.Server.MapPath("~/upload/UploadGRNFilesImages/") + str_image;
                        image_path = "~/upload/UploadGRNFilesImages/" + str_image;

                        if (System.IO.File.Exists(context.Server.MapPath(oldpath)))
                        {
                            string savePath = HttpContext.Current.Server.MapPath(oldpath);
                            System.IO.File.Delete(savePath);
                            string sql = "update GRN_Master set File_Path ='" + image_path + "' where GRN_ID=" + GRNID;
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
#pragma warning disable CS0168
            catch (Exception ac)
#pragma warning restore CS0168
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
