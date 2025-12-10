using System;
using System.IO;
using System.Linq;
using System.Web;


namespace PMS
{
    /// <summary>
    /// Summary description for UploadVoucherFiles
    /// </summary>
    public class UploadVoucherFiles : IHttpHandler
    {

        public void ProcessRequest(HttpContext context)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var VID = Convert.ToInt32(context.Request.Form["ID"]);
            context.Response.ContentType = "text/plain";
            try
            {
                string dirFullPath = context.Server.MapPath("~/upload/UploadVouchersImages/");
                string[] files;
                files = System.IO.Directory.GetFiles(dirFullPath);
                string str_image = "";
                string image_path = "";
                var query = (from data in db.GL_Vouchers.Where(x => x.Voucher_ID.Equals(VID))
                             select data).FirstOrDefault();
                string oldpath = query.File_Path;
                string oldext = query.File_Path;
                foreach (string s in context.Request.Files)
                {
                    HttpPostedFile file = context.Request.Files[s];
                    string fileName = file.FileName;
                    string fileExtension = file.ContentType;
                    if (!string.IsNullOrEmpty(fileName))
                    {
                        fileExtension = Path.GetExtension(fileName);
                        str_image = VID.ToString() + fileExtension;
                        string pathToSave = context.Server.MapPath("~/upload/UploadVouchersImages/") + str_image;
                        image_path = "~/upload/UploadVouchersImages/" + str_image;

                        if (System.IO.File.Exists(context.Server.MapPath(oldpath)))
                        {
                            // file exist
                            string savePath = HttpContext.Current.Server.MapPath(oldpath);
                            System.IO.File.Delete(savePath);
                            string sql = "update GL_Vouchers set File_Path ='" + image_path + "' where Voucher_ID=" + VID;
                            DBClass.executeNonQueryWithoutBegin(sql);
                        }
                        file.SaveAs(pathToSave);
                        query.File_Path = fileExtension;
                        query.File_Path = image_path;
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