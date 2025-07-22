using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;

namespace PMS
{
    /// <summary>
    /// Summary description for UploadPurchaseRequsitionDetail
    /// </summary>
    public class UploadPurchaseRequsitionDetail : IHttpHandler
    {

        public void ProcessRequest(HttpContext context)
        {
            string addOrEdit = "EDIT";
            DataBaseDataContext db = new DataBaseDataContext();
            var PRId = Convert.ToInt32(context.Request.Form["ID"]);
            if (PRId == 0)
            {
                addOrEdit = "ADD";
                PRId = Convert.ToInt32(DBClass.getField("(select isnull(max(PR_ID),0) from Purchase_Requisition)"));
            }
            string str_image = "";
            if (context.Request.Files.Count > 0)
            {
                System.Data.DataTable dtPRItems = new System.Data.DataTable();
                if (addOrEdit == "ADD")
                {
                    dtPRItems = DBClass.getDataTable("select * from [Purchase_Requisition_Detail] where PR_ID =  " + PRId + " order by PR_Detail_ID");
                }
                else
                {
                    dtPRItems = DBClass.getDataTable("select * from [Purchase_Requisition_Detail] where PR_ID =  " + PRId + " and File_Path is null order by PR_Detail_ID");
                    if (dtPRItems.Rows.Count == 0) 
                    {
                        dtPRItems = DBClass.getDataTable("select * from [Purchase_Requisition_Detail] where PR_ID =  " + PRId + " order by PR_Detail_ID");
            
                    }
                }
              


                HttpFileCollection files = context.Request.Files;
                for (int i = 0; i < files.Count; i++)
                {
                    string PRDetailID = dtPRItems.Rows[i]["PR_Detail_ID"].ToString().Trim();
                    string filePath = dtPRItems.Rows[i]["File_Path"].ToString().Trim();
                    HttpPostedFile file = files[i];
                    string fileName = file.FileName;
                    string fileExtension = file.ContentType;
                    fileExtension = Path.GetExtension(fileName);
                    var guid = Guid.NewGuid();
                    string fname = context.Server.MapPath("~/upload/PurchaseRequistionDetailImages/" + PRDetailID + fileExtension);
                    str_image = guid.ToString() + fileExtension;
                    string image_Path = "~/upload/PurchaseRequistionDetailImages/" + PRDetailID + fileExtension;
                    string image_Path_without_ext = "~/upload/PurchaseRequistionDetailImages/" + PRDetailID;
                    if (System.IO.File.Exists(context.Server.MapPath(image_Path)))
                    {
                        // file exist
                        string savePath = HttpContext.Current.Server.MapPath(image_Path);
                        System.IO.File.Delete(savePath);
                       
                    }
                    file.SaveAs(fname);
                        
                        //var query = (from data in db.Purchase_Requisition_Details.Where(x => x.PR_Detail_ID.Equals(PRDetailID))
                        //             select data).FirstOrDefault();
                        //query.File_Path = image_Path;
                        //query.File_Type = fileExtension;
                        db.SubmitChanges();
                }
            }
            context.Response.ContentType = "text/plain";
            context.Response.Write("data has been saved successfully");
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