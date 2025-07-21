using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;

namespace PMS
{
    /// <summary>
    /// Summary description for UploadPurchaseOrder
    /// </summary>
    public class UploadPurchaseOrder : IHttpHandler
    {

        public void ProcessRequest(HttpContext context)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            AP_Purchase_Order obj = new AP_Purchase_Order();
            var POID = Convert.ToInt32(context.Request.Form["ID"]);
            context.Response.ContentType = "text/plain";
            try
            {
                string dirFullPath = context.Server.MapPath("~/upload/PurchaseOrderImages/");
                string[] files;
                files = System.IO.Directory.GetFiles(dirFullPath);
                string str_image = "";
                var query = (from data in db.AP_Purchase_Orders.Where(x => x.PO_ID.Equals(POID))
                          select data).FirstOrDefault();
                foreach (string s in context.Request.Files)
                {
                    HttpPostedFile file = context.Request.Files[s];
                    string fileName = file.FileName;
                    string fileExtension = file.ContentType;
                    if (!string.IsNullOrEmpty(fileName))
                    {
                        fileExtension = Path.GetExtension(fileName);
                        str_image = POID.ToString() + fileExtension;
                        string pathToSave = context.Server.MapPath("~/upload/PurchaseOrderImages/") + str_image;
                        string image_path = "~/upload/PurchaseOrderImages/" + str_image;
                        if (System.IO.File.Exists(context.Server.MapPath(image_path)))
                        {
                            // file exist
                            string savePath = HttpContext.Current.Server.MapPath(image_path);
                            System.IO.File.Delete(savePath);
                            string sql = "delete from AP_Purchase_Orders where File_Path ='" + image_path + "'";
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