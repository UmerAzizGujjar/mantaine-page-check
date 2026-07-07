using System;
using System.IO;
using System.Linq;
using System.Web;

namespace PMS
{
    public class UploadMIRDetailFiles : IHttpHandler
    {
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "text/plain";
            try
            {
                var MIRId = Convert.ToInt32(context.Request.Form["MIRId"]);
                var rowIndex = Convert.ToInt32(context.Request.Form["rowIndex"]);

                string dirFullPath = context.Server.MapPath("~/MaterialIssueDetailImages/");
                if (!Directory.Exists(dirFullPath))
                    Directory.CreateDirectory(dirFullPath);

                foreach (string s in context.Request.Files)
                {
                    HttpPostedFile file = context.Request.Files[s];
                    string fileName = file.FileName;
                    if (string.IsNullOrEmpty(fileName)) continue;

                    string fileExtension = Path.GetExtension(fileName);

                    DataBaseDataContext db = new DataBaseDataContext();
                    var detail = (from d in db.MaterialIssueRequest_Details
                                  where d.MaterialRequest_Id == MIRId
                                  orderby d.MaterialRequestDetail_Id
                                  select d).Skip(rowIndex).FirstOrDefault();

                    if (detail == null) continue;

                    string str_image = detail.MaterialRequestDetail_Id + fileExtension;
                    string pathToSave = dirFullPath + str_image;
                    string image_path = "~/MaterialIssueDetailImages/" + str_image;

                    string oldpath = detail.FilePath;
                    if (!string.IsNullOrEmpty(oldpath) && System.IO.File.Exists(context.Server.MapPath(oldpath)))
                    {
                        System.IO.File.Delete(context.Server.MapPath(oldpath));
                    }

                    string sql = "update MaterialIssueRequest_Detail set FilePath='" + image_path + "', File_type='" + fileExtension + "' where MaterialRequestDetail_Id=" + detail.MaterialRequestDetail_Id;
                    DBClass.executeNonQueryWithoutBegin(sql);

                    file.SaveAs(pathToSave);
                    detail.FilePath = image_path;
                    detail.File_Type = fileExtension;
                    db.SubmitChanges();

                    context.Response.Write(str_image);
                }
            }
            catch (Exception)
            {
            }
        }

        public bool IsReusable
        {
            get { return false; }
        }
    }
}
