using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace PMS
{
    /// <summary>
    /// Summary description for ImageUpload
    /// </summary>
    public class ImageUpload : IHttpHandler
    {

        public void ProcessRequest(HttpContext context)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var detail_ID = context.Request.Form["lab_test_Detail_id"];
            if (context.Request.Files.Count > 0)
            {
                HttpFileCollection files = context.Request.Files;
                for (int i = 0; i < files.Count; i++)
                {
                    HttpPostedFile file = files[i];
                    Test_Image image = new Test_Image();
                    int imageNo = Convert.ToInt32(DBClass.getField("Select isnull(Max(Image_No),0) + 1 from Test_Image where Lab_Test_Detail_ID = " + detail_ID + ""));
                    string fname = context.Server.MapPath("~/LabTestImg/" + imageNo + "-" + detail_ID + ".png");

                    string image_Path = "~/LabTestImg/" + imageNo + "-" + detail_ID + ".png";
                    if (System.IO.File.Exists(context.Server.MapPath(image_Path)))
                    {
                        // file exist
                        string savePath = HttpContext.Current.Server.MapPath(image_Path);
                        System.IO.File.Delete(savePath);
                        string sql = "delete from Test_Image where Image_path ='" + image_Path + "'";
                        DBClass.executeNonQueryWithoutBegin(sql);
                    }
                   
                        file.SaveAs(fname);
                        image.Image_No = imageNo;
                    image.Image_path = image_Path;
                    image.Lab_Test_Detail_ID = Convert.ToInt32(detail_ID);
                    db.Test_Images.InsertOnSubmit(image);
                    db.SubmitChanges();



                }
            }
            context.Response.ContentType = "text/plain";
            context.Response.Write("Saved");
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