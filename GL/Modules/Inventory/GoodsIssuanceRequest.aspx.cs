using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Inventory
{
    public partial class GoodsIssuanceRequest : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            HyperLink1.Visible = false;
            if (!IsPostBack)
            {
                if (Request.QueryString["ID"] != null)
                {
                    DataBaseDataContext db = new DataBaseDataContext();
                    var getID = Request.QueryString["ID"];
                    var gettype = (from a in db.MaterialIssueRequests where a.MaterialRequest_Id == Convert.ToInt32(getID) select a.FilePath).FirstOrDefault();
                    if (!string.IsNullOrEmpty(gettype))
                    {
                        HyperLink1.NavigateUrl = gettype;
                        HyperLink1.Visible = true;
                    }

                }
            }

        }
       
        [WebMethod]
        public static string filldepartments()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var dept = (from data in db.Department_Wise_User_Details
                        where data.User_Id == AppConfig.UserID
                        select new
                        {
                            DataValueName = data.Department,
                            DataValueDescription = db.GetDataValueName("Department", data.Department),
                        }).ToList();
            return (new JavaScriptSerializer()).Serialize(dept);
        }
        [WebMethod]
        public static string getwarehouseLlist()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var warehouse = (from data in db.WareHouse_Wise_User_Details
                             where data.User_Id == AppConfig.UserID
                             select new
                             {
                                 DataValueName= data.WareHouse,
                                 DataValueDescription = db.GetDataValueName("Ware House", data.WareHouse),
                             }).ToList();
            return (new JavaScriptSerializer()).Serialize(warehouse);
        }       

        [WebMethod]
        public static bool UserEntryRights()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var uid = AppConfig.UserID;
                var hasEntryRights = db.Sys_Inv_OrignatorTempelate_Masters
                                   .Join(db.Sys_Inv_OrignatorTempelate_Detail_Forms,
                                         SATM => SATM.OrignatorTempelate_ID,
                                         SATDF => SATDF.OrignatorTempelate_ID,
                                         (SATM, SATDF) => new { SATM, SATDF })
                                   .Join(db.Sys_Inv_OrignatorTempelate_Details,
                                         temp => temp.SATM.OrignatorTempelate_ID,
                                         SATDO => SATDO.OrignatorTempelate_ID,
                                         (temp, SATDO) => new { temp.SATM, temp.SATDF, SATDO })
                                   .Any(temp => temp.SATM.IsActive == true && temp.SATM.IsDeleted == false && temp.SATDF.FormId == 5 && temp.SATDO.UserId == uid);

                return hasEntryRights;
            }
        }

        [WebMethod]
        public static bool UserUnApproveEntryRights()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var userPermissions = (from data in db.aspnet_Users
                                       where data.UserId == AppConfig.UserID
                                       select new
                                       {
                                           data.IsInventoryUnApprove
                                       }).FirstOrDefault();
                bool UnApproveRight = userPermissions?.IsInventoryUnApprove ?? false;
                return UnApproveRight;
            }
        }

        [WebMethod]
        public static int GetRequestNo()
        {

            int max = DBClass.getMaxEntry_No("MaterialIssueRequest", "Request_No");
            return max;
        }

        [WebMethod]
        public static string GetEmployee()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var getEmployee = (from p in db.HR_Employees
                               where p.IsDoctor == false
                               select new
                               {
                                   p.Emp_ID,
                                   p.Emp_Name
                               }).ToList(); ;

            return (new JavaScriptSerializer()).Serialize(getEmployee);
        }


        [WebMethod]
        public static String Getitem(int ItemID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var itemDetail = db.spGetitemsDetails(ItemID).ToList();
                return (new JavaScriptSerializer()).Serialize(itemDetail);
            }
        }

        [WebMethod]

        public static string SaveMIR(int MIRId, string MIRNum, string MIRDate, string Pirority, string dept, string remarks, string WareHouse, string btnValue)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            PMS.MaterialIssueRequest obj = new PMS.MaterialIssueRequest();
            var MIRid = string.Empty;
            if (btnValue == "Save")
            {
                obj.Request_No = DBClass.getMaxEntry_No("MaterialIssueRequest", "Request_No");
                obj.MIRDate = Convert.ToDateTime(MIRDate);
                obj.Priority = Pirority;
                obj.InventoryOrganization = WareHouse;
                obj.Department = dept;
                obj.Remarks = remarks;
                obj.Creation_Date = DateTime.Now;
                obj.Created_By = AppConfig.UserID;
                obj.Company_ID = AppConfig.Company_ID;
                obj.Status = "Created";
                db.MaterialIssueRequests.InsertOnSubmit(obj);
            }
            else
            {
                obj = (from data in db.MaterialIssueRequests.Where(x => x.MaterialRequest_Id.Equals(MIRId)) select data).FirstOrDefault();
                obj.Request_No = Convert.ToInt32(MIRNum);
                obj.MIRDate = Convert.ToDateTime(MIRDate);
                obj.Priority = Pirority;
                obj.InventoryOrganization = WareHouse;
                obj.Department = dept;
                obj.Remarks = remarks;
                obj.Update_Date = DateTime.Now;
                obj.Updated_By = AppConfig.UserID;
            }
            try
            {
                db.SubmitChanges();
            }
            catch (Exception)
            {

                return "Error";
            }
            MIRid = Convert.ToString(obj.MaterialRequest_Id);
            if (MIRid == "0")
            {
                MIRid = Convert.ToString(obj.MaterialRequest_Id);
            }
            return "Success-" + MIRid;
        }

        [WebMethod]
        public static string SaveMIRDetails(int MIRId, string btnValue, List<MIRDetail> MIRDetails)
        {
            System.Data.DataTable dtOldImagesInfo = DBClass.getDataTable("Select MaterialRequestDetail_Id, FilePath from MaterialIssueRequest_Detail pd where pd.MaterialRequest_Id = " + MIRId + " order by MaterialRequestDetail_Id");
            string filename = string.Empty;
            string s2 = string.Empty;
            DataBaseDataContext db = new DataBaseDataContext();
            if (btnValue == "Update")            {
                var MIRList = from MIR in db.MaterialIssueRequest_Details where MIR.MaterialRequest_Id == MIRId select MIR;
                foreach (var del in MIRList)
                {
                    string image_Path = "~/MaterialIssueDetailImages/" + del.MaterialRequestDetail_Id + del.File_Type;
                    if (System.IO.File.Exists(HttpContext.Current.Server.MapPath(image_Path)))
                    {
                        var name = Path.GetFileName(image_Path);
                        filename += "," + name;
                        string d = filename;
                        s2 = d.TrimStart(',');
                        string savePath = HttpContext.Current.Server.MapPath(image_Path);
                    }
                }
                foreach (var del in MIRList)
                {
                    db.MaterialIssueRequest_Details.DeleteOnSubmit(del);
                }
                db.SubmitChanges();
            }
            bool proceed = true;
            foreach (var item in MIRDetails)
            {
                MaterialIssueRequest_Detail obj = new MaterialIssueRequest_Detail();
                obj.Item_Id = Convert.ToInt32(item.itemId);
                obj.MaterialRequest_Id = Convert.ToInt64(item.MIRId);
                obj.MIRQty = Convert.ToDecimal(item.MIRQty);
                obj.Remarks = item.remarks;
                db.MaterialIssueRequest_Details.InsertOnSubmit(obj);
                try
                {
                    db.SubmitChanges();
                    var max = db.MaterialIssueRequest_Details.Max(x => x.MaterialRequestDetail_Id);
                }
                catch (Exception ex)
                {
                    proceed = true;
                    return "Error";
                }
            }
            if (proceed)
            {
                System.Data.DataTable dtMIRDetailData = DBClass.getDataTable("Select MaterialRequestDetail_Id, FilePath from MaterialIssueRequest_Detail pd where pd.MaterialRequest_Id = " + MIRId + " order by MaterialRequestDetail_Id");
                for (int i = 0; i < dtOldImagesInfo.Rows.Count; i++)
                {
                    string oldFile = HttpContext.Current.Server.MapPath(dtOldImagesInfo.Rows[i]["FilePath"].ToString());
                    FileInfo fInfo = new FileInfo(oldFile);
                    string extension = fInfo.Extension;
                    string newFileName = dtMIRDetailData.Rows[i]["MaterialRequestDetail_Id"].ToString().Trim() + extension;
                    string pathToSave = "~/MaterialIssueDetailImages/" + newFileName;
                    string query = "update MaterialIssueRequest_Detail set FilePath='" + pathToSave + "' , File_type='" + extension + "' where MaterialRequestDetail_Id=" + dtMIRDetailData.Rows[i]["MaterialRequestDetail_Id"].ToString();
                    DBClass.executeNonQueryWithoutBegin(query);
                    if (File.Exists(oldFile))
                    {
                        if (oldFile.Contains("Inventory"))
                        {
                        }
                        else
                        {
                            fInfo.MoveTo(HttpContext.Current.Server.MapPath("~/Old/" + newFileName));
                        }
                        File.Delete(oldFile);
                    }
                }
            }
            return "Success-" + MIRId;
        }

        [WebMethod]
        public static string LoadMIR(int ID)
        {
            string result = string.Empty;
            if (ID > 0)
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    var query = (from data in db.MaterialIssueRequests
                                 where data.MaterialRequest_Id == ID
                                 select new
                                 {
                                     data.MaterialRequest_Id,
                                     data.Request_No,
                                     data.Priority,
                                     data.Department,
                                     data.InventoryOrganization,
                                     data.Remarks,
                                     data.Employee,
                                     data.MIRDate,
                                     data.Status,
                                 }).FirstOrDefault();
                    result = (new JavaScriptSerializer()).Serialize(query).ToString();
                }
            }
            return result;
        }
        [WebMethod]
        public static string LoadMIRDetail(int ID)
        {
            List<MIRDetail> listItems = new List<MIRDetail>();
            string result = string.Empty;
            if (ID > 0)
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    listItems = (from data in db.MaterialIssueRequest_Details
                                 join inv in db.INV_Items
                                 on data.Item_Id equals inv.Item_ID
                                 where data.MaterialRequest_Id == ID
                                 select new MIRDetail
                                 {
                                     MIR_Detail_ID = Convert.ToString(data.MaterialRequestDetail_Id),
                                     itemCode = Convert.ToString(inv.Item_Code),
                                     Description = Convert.ToString(inv.Description),
                                     Unit = db.GetDataValueName("UOM", inv.Unit),
                                     itemId = Convert.ToString(data.Item_Id),
                                     MIRId = Convert.ToString(data.MaterialRequest_Id),
                                     MIRQty = Convert.ToString(data.MIRQty),
                                     remarks = data.Remarks,
                                 }).ToList();
                    result = (new JavaScriptSerializer()).Serialize(listItems).ToString();
                }
            }
            return result;
        }      
        [WebMethod]
        public static string ApproveMIR(string MIRId, Guid user_id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.spApproveMIR(Convert.ToInt32(MIRId), user_id);
            return (new JavaScriptSerializer()).Serialize(Details);
        }
        [WebMethod]
        public static string UnApproveMIR(string MIRId)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.spUnApproveMIR(Convert.ToInt32(MIRId));
            return (new JavaScriptSerializer()).Serialize(Details);
        }
        public class MIRDetail
        {
            public string MIRQty { get; set; }
            public string remarks { get; set; }
            public string MIRId { get; set; }
            public string itemId { get; set; }
            public string MIR_Detail_ID { get; set; }
            public string itemCode { get; set; }
            public string Description { get; set; }
            public string Unit { get; set; }
        }
    }
}