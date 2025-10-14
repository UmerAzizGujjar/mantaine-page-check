using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;

namespace PMS
{

    public class UploadEmergency : IHttpHandler
    {

        public void ProcessRequest(HttpContext context)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            AP_Purchase_Order obj = new AP_Purchase_Order();
            var emergency_id = Convert.ToInt32(context.Request.Form["ID"]);
            context.Response.ContentType = "text/plain";
            try
            {
                string dirFullPath = context.Server.MapPath("../upload/EmergencyFiles/");
                string[] files;
                files = System.IO.Directory.GetFiles(dirFullPath);
                string str_image = "";
                var query = (from data in db.Emergency_Patients.Where(x => x.Emergency_ID.Equals(emergency_id))
                             select data).FirstOrDefault();
                foreach (string s in context.Request.Files)
                {
                    HttpPostedFile file = context.Request.Files[s];
                    string fileName = file.FileName;
                    string fileExtension = file.ContentType;
                    if (!string.IsNullOrEmpty(fileName))
                    {
                        fileExtension = Path.GetExtension(fileName);
                        str_image = emergency_id.ToString() + fileExtension;
                        string pathToSave = context.Server.MapPath("../upload/EmergencyFiles/") + str_image;
                        string image_path = "../../upload/EmergencyFiles/" + str_image;
                        if (System.IO.File.Exists(context.Server.MapPath(image_path)))
                        {
                            // file exist
                            string savePath = HttpContext.Current.Server.MapPath(image_path);
                            System.IO.File.Delete(savePath);
                            string sql = "update Emergency_Patient set emergecny_pat_file ='" + image_path + "' where Emergency_ID=" + emergency_id;
                            DBClass.executeNonQueryWithoutBegin(sql);
                        }
                        file.SaveAs(pathToSave);
                        query.emergecny_pat_file = image_path;
                        
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