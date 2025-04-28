using System;
using System.IO;
using System.Linq;
using System.Web;

namespace PMS
{
    public class UploadPaymentFiles : IHttpHandler
    {

        public void ProcessRequest(HttpContext context)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var PID = Convert.ToInt32(context.Request.Form["ID"]);
            context.Response.ContentType = "text/plain";
            try
            {
                string dirFullPath = context.Server.MapPath("~/UploadPaymentFilesImages/");
                string[] files;
                files = System.IO.Directory.GetFiles(dirFullPath);
                string str_image = "";
                string image_path = "";
                var query = (from data in db.Payment_Invoices.Where(x => x.PaymentInvoiceId.Equals(PID))
                             select data).FirstOrDefault();
                string oldpath = query.FilePath;
                string oldext = query.FileType;
                foreach (string s in context.Request.Files)
                {
                    HttpPostedFile file = context.Request.Files[s];
                    string fileName = file.FileName;
                    string fileExtension = file.ContentType;
                    if (!string.IsNullOrEmpty(fileName))
                    {
                        fileExtension = Path.GetExtension(fileName);
                        str_image = PID.ToString() + fileExtension;
                        string pathToSave = context.Server.MapPath("~/UploadPaymentFilesImages/") + str_image;
                        image_path = "~/UploadPaymentFilesImages/" + str_image;

                        if (System.IO.File.Exists(context.Server.MapPath(oldpath)))
                        {
                            // file exist
                            string savePath = HttpContext.Current.Server.MapPath(oldpath);
                            System.IO.File.Delete(savePath);
                            string sql = "update Payment_Invoices set FilePath ='" + image_path + "' where PaymentInvoiceId=" + PID;
                            DBClass.executeNonQueryWithoutBegin(sql);
                        }
                        file.SaveAs(pathToSave);
                        query.FilePath = image_path;
                        query.FileType = fileExtension;
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