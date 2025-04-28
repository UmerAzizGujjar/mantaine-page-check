using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;

namespace PMS
{
    /// <summary>
    /// Summary description for UploadPaymentInvoice
    /// </summary>
    public class UploadPaymentInvoice : IHttpHandler
    {

        public void ProcessRequest(HttpContext context)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            Payment_Invoice obj = new Payment_Invoice();
            var PID = Convert.ToInt32(context.Request.Form["ID"]);
            context.Response.ContentType = "text/plain";
            try
            {
                string dirFullPath = context.Server.MapPath("~/PaymentInvoiceImages/");
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
                        string pathToSave = context.Server.MapPath("~/PaymentInvoiceImages/") + str_image;
                        image_path = "~/PaymentInvoiceImages/" + str_image;

                        if (System.IO.File.Exists(context.Server.MapPath(oldpath)))
                        {
                            // file exist
                            string savePath = HttpContext.Current.Server.MapPath(oldpath);
                            System.IO.File.Delete(savePath);
                            string sql = "update  Payment_Invoice set FilePath ='" + image_path + "' where PaymentInvoiceId=" + PID;
                            string ext = "update  Payment_Invoice set FileType ='" + fileExtension + "' where PaymentInvoiceId=" + PID;
                            DBClass.executeNonQueryWithoutBegin(sql);
                            DBClass.executeNonQueryWithoutBegin(ext);
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