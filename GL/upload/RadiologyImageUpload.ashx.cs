using System;
using System.IO;
using System.Web;
using System.Linq;

namespace PMS
{
    public class RadiologyImageUpload : IHttpHandler
    {
        public void ProcessRequest(HttpContext context)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            // Get ID from the FormData
            var detail_ID = context.Request.Form["lab_test_Detail_id"];

            if (context.Request.Files.Count > 0)
            {
                // Logic matched to your buttonimageuploadNotes_Click
                string dirFullPath = context.Server.MapPath("~/wwwroot/images/RadiologyTestImg/");

                if (!Directory.Exists(dirFullPath))
                {
                    Directory.CreateDirectory(dirFullPath);
                }

                for (int i = 0; i < context.Request.Files.Count; i++)
                {
                    HttpPostedFile fileUpload = context.Request.Files[i];

                    // Generate Image Number
                    int imageNo = Convert.ToInt32(DBClass.getField(
                        "SELECT ISNULL(MAX(Image_No),0) + 1 FROM Test_Image WHERE Lab_Test_Detail_ID = " + detail_ID));

                    string fileName = imageNo + "-" + detail_ID + ".png";
                    string physicalPath = Path.Combine(dirFullPath, fileName);

                    // Database Path String exactly as you requested
                    string image_Path = "~../../../../wwwroot/images/RadiologyTestImg/" + fileName;

                    if (File.Exists(physicalPath))
                    {
                        File.Delete(physicalPath);
                    }

                    // Save Physical File
                    fileUpload.SaveAs(physicalPath);

                    // Save to Database
                    Test_Image image = new Test_Image();
                    image.Image_No = imageNo;
                    image.Image_path = image_Path;
                    image.Lab_Test_Detail_ID = Convert.ToInt32(detail_ID);

                    db.Test_Images.InsertOnSubmit(image);
                    db.SubmitChanges();
                }
            }
            context.Response.ContentType = "text/plain";
            context.Response.Write("Success");
        }

        public bool IsReusable => false;
    }
}