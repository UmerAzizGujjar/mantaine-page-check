using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;


namespace PMS
{
    /// <summary>
    /// Summary description for UploadPurchaseInvoice
    /// </summary>
    public class UploadPurchaseInvoice : IHttpHandler
    {

        public void ProcessRequest(HttpContext context)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            Purchase_Invoice_Master obj = new Purchase_Invoice_Master();
            var InvID = Convert.ToInt32(context.Request.Form["ID"]);
            context.Response.ContentType = "text/plain";
            try
            {
                string dirFullPath = context.Server.MapPath("~/upload/PurchaseInvoiceImages/");
                string[] files;
                files = System.IO.Directory.GetFiles(dirFullPath);
                string str_image = "";
                var query = (from data in db.Purchase_Invoice_Masters.Where(x => x.PurchaseInvoiceId.Equals(InvID))
                             select data).FirstOrDefault();
                foreach (string s in context.Request.Files)
                {
                    HttpPostedFile file = context.Request.Files[s];
                    string fileName = file.FileName;
                    string fileExtension = file.ContentType;
                    if (!string.IsNullOrEmpty(fileName))
                    {
                        fileExtension = Path.GetExtension(fileName);
                        str_image = InvID.ToString() + fileExtension;
                        string pathToSave = context.Server.MapPath("~/upload/PurchaseInvoiceImages/") + str_image;
                        string image_path = "~/upload/PurchaseInvoiceImages/" + str_image;
                        if (System.IO.File.Exists(context.Server.MapPath(image_path)))
                        {
                            // file exist
                            string savePath = HttpContext.Current.Server.MapPath(image_path);
                            System.IO.File.Delete(savePath);
                            string sql = "delete from Purchase_Invoice_Master where File_Path ='" + image_path + "'";
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