using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;

namespace PMS
{
    /// <summary>
    /// Summary description for UploadPurchaseRequsition
    /// </summary>
    public class UploadPurchaseRequsition : IHttpHandler
    {

        public void ProcessRequest(HttpContext context)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            Purchase_Requisition obj = new Purchase_Requisition();
            var PRID = Convert.ToInt32(context.Request.Form["ID"]);
            context.Response.ContentType = "text/plain";
            try
            {                
                string dirFullPath = context.Server.MapPath("~/PurchaseRequistionImages/");
                string[] files;
                files = System.IO.Directory.GetFiles(dirFullPath);
                string str_image = "";
                 string image_path="";
                var query = (from data in db.Purchase_Requisitions.Where(x => x.PR_Id.Equals(PRID))
                                select data).FirstOrDefault();
                //string oldpath = query.File_Path;
                //string oldext = query.File_Type;
                foreach (string s in context.Request.Files)
                {
                    HttpPostedFile file = context.Request.Files[s];
                    string fileName = file.FileName;
                    string fileExtension = file.ContentType;
                    if (!string.IsNullOrEmpty(fileName))
                    {
                        fileExtension = Path.GetExtension(fileName);
                        str_image =  PRID.ToString() + fileExtension;
                        string pathToSave = context.Server.MapPath("~/PurchaseRequistionImages/") + str_image;
                        image_path = "~/PurchaseRequistionImages/" + str_image;

                        //if (System.IO.File.Exists(context.Server.MapPath(oldpath)))
                        //{
                        //    // file exist
                        //    string savePath = HttpContext.Current.Server.MapPath(oldpath);
                        //    System.IO.File.Delete(savePath);
                        //    string sql = "update  Purchase_Requisition set File_Path ='" + image_path + "' where PR_id=" + PRID;
                        //    DBClass.executeNonQueryWithoutBegin(sql);
                        //}
                        //file.SaveAs(pathToSave);
                        //query.File_Path = image_path;
                        //query.File_Type = fileExtension;                      
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