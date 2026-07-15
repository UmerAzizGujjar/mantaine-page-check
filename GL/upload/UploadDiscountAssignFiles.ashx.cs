using System;
using System.IO;
using System.Linq;
using System.Web;

namespace PMS
{
    public class UploadDiscountAssignFiles : IHttpHandler
    {

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "text/plain";
            try
            {
                DataBaseDataContext db = new DataBaseDataContext();
                var discountID = Convert.ToInt32(context.Request.Form["ID"]);

                var query = db.Discount_Assign_Bills
                    .Where(x => x.Discount_Assign_ID == discountID)
                    .FirstOrDefault();
                if (query == null)
                {
                    context.Response.Write("ERROR: Discount record not found");
                    return;
                }

                string dirFullPath = context.Server.MapPath("~/upload/UploadDiscountAssignImages/");
                if (!Directory.Exists(dirFullPath))
                {
                    Directory.CreateDirectory(dirFullPath);
                }

                string str_image = "";
                string image_path = "";
                string oldpath = query.File_Path;

                foreach (string s in context.Request.Files)
                {
                    HttpPostedFile file = context.Request.Files[s];
                    string fileName = file.FileName;
                    if (!string.IsNullOrEmpty(fileName))
                    {
                        string fileExtension = Path.GetExtension(fileName);
                        str_image = discountID.ToString() + fileExtension;
                        string pathToSave = Path.Combine(dirFullPath, str_image);
                        image_path = "~/upload/UploadDiscountAssignImages/" + str_image;

                        if (!string.IsNullOrEmpty(oldpath))
                        {
                            string oldPhysicalPath = context.Server.MapPath(oldpath);
                            if (File.Exists(oldPhysicalPath))
                            {
                                File.Delete(oldPhysicalPath);
                            }
                        }
                        file.SaveAs(pathToSave);
                        query.File_Path = image_path;
                        query.File_Type = fileExtension;
                    }
                }

                db.SubmitChanges();
                context.Response.Write(str_image);
            }
            catch (Exception ex)
            {
                context.Response.Write("ERROR: " + ex.Message);
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
