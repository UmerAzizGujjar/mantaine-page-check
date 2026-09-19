using System;
using System.Collections.Generic;
using System.Globalization;
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
        public string ReplicateCode { get; set; }
        protected void Page_Load(object sender, EventArgs e)
        {
            HyperLink1.Visible = false;
            if (!IsPostBack)
            {
                DataBaseDataContext db = new DataBaseDataContext();
                var code = db.sys_Parms.Where(x => x.Name == "Replicate").Select(x => x.Code).FirstOrDefault();
                ReplicateCode = code ?? "";
                if (Request.QueryString["ID"] != null)
                {
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
        public static string GetWareHouseCondition()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var dept = (from data in db.sys_Parms
                        where data.Name == "WareHouse For PO"
                        select
                          data.Code
                        ).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(dept);
        }
        [WebMethod]
        public static string GetReplicateParm()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var code = (from data in db.sys_Parms
                        where data.Name == "Replicate"
                        select data.Code).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(code ?? "");
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


        //[WebMethod]
        //public static String Getitem(int ItemID)
        //{
        //    using (DataBaseDataContext db = new DataBaseDataContext())
        //    {
        //        var itemDetail = db.spGetitemsDetails(ItemID).ToList();
        //        return (new JavaScriptSerializer()).Serialize(itemDetail);
        //    }
        //}

        [WebMethod]
        public static String Getitem(int ItemID, string DeptID) 
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var itemDetail = db.spGetitemsDetails(ItemID, DeptID).ToList();
                return (new JavaScriptSerializer()).Serialize(itemDetail);
            }
        }

        // ================= GIR CHANGE LOG SNAPSHOT HELPERS =================

        private static string StrVal(object v)
        {
            if (v == null) return "";
            return Convert.ToString(v, CultureInfo.InvariantCulture);
        }

        private static string NumVal(object v)
        {
            if (v == null) return "";
            try { return Convert.ToDecimal(v).ToString("0.##", CultureInfo.InvariantCulture); }
            catch { return ""; }
        }

        private static string DateVal(object v)
        {
            if (v == null) return "";
            try { return Convert.ToDateTime(v).ToString("yyyy-MM-dd", CultureInfo.InvariantCulture); }
            catch { return ""; }
        }

        private static Dictionary<string, string> BuildGIRMasterSnapshot(PMS.MaterialIssueRequest gir, DataBaseDataContext dbc)
        {
            string deptName = "";
            if (!string.IsNullOrEmpty(gir.Department))
            {
                try { deptName = dbc.GetDataValueName("Department", gir.Department) ?? ""; }
                catch { deptName = ""; }
            }

            string warehouseName = "";
            if (!string.IsNullOrEmpty(gir.InventoryOrganization))
            {
                try { warehouseName = dbc.GetDataValueName("Ware House", gir.InventoryOrganization) ?? ""; }
                catch { warehouseName = ""; }
            }

            var snap = new Dictionary<string, string>();
            snap["Gir_No"] = StrVal(gir.Request_No);
            snap["Gir_Date"] = DateVal(gir.MIRDate);
            snap["Priority"] = gir.Priority == "1" ? "High" : "Low";
            snap["Department"] = deptName;
            snap["Warehouse"] = warehouseName;
            snap["Remarks"] = StrVal(gir.Remarks);
            snap["Status"] = StrVal(gir.Status);
            snap["Closing_Remarks"] = StrVal(gir.Closing_Remarks);
            snap["Is_Closed"] = gir.Is_Closed_GIR.HasValue && gir.Is_Closed_GIR.Value ? "Yes" : "No";
            return snap;
        }

        private static object BuildGIRDetailSnapshot(DataBaseDataContext dbc, long girId)
        {
            var rows = dbc.MaterialIssueRequest_Details.Where(t => t.MaterialRequest_Id == girId).ToList();

            var ids = rows.Where(r => r.Item_Id.HasValue).Select(r => (int)r.Item_Id.Value).Distinct().ToList();
            var itemNames = new Dictionary<int, string>();
            var itemCodes = new Dictionary<int, string>();
            foreach (var id in ids)
            {
                var itm = dbc.INV_Items.Where(x => x.Item_ID == id)
                                       .Select(x => new { x.Description, x.Item_Code })
                                       .FirstOrDefault();
                itemNames[id] = itm != null ? (itm.Description ?? "") : "";
                itemCodes[id] = itm != null ? (itm.Item_Code ?? "") : "";
            }

            return new
            {
                Items = rows.Select(i =>
                {
                    string name = "";
                    string code = "";
                    if (i.Item_Id.HasValue)
                    {
                        int key = (int)i.Item_Id.Value;
                        if (itemNames.ContainsKey(key)) name = itemNames[key];
                        if (itemCodes.ContainsKey(key)) code = itemCodes[key];
                    }

                    return new
                    {
                        Item_Name = name,
                        Item_Code = code,
                        MIRQty = NumVal(i.MIRQty),
                        Last_MIR_Qty = NumVal(i.Last_MIR_Qty),
                        Last_SIN_Qty = NumVal(i.Last_SIN_Qty),
                        Remarks = StrVal(i.Remarks),
                        Last_GIR_Date = DateVal(i.Last_GIR_Date)
                    };
                }).ToList()
            };
        }

        private static void WriteGIRChangeLog(DataBaseDataContext dbc, PMS.MaterialIssueRequest gir, JavaScriptSerializer serializer)
        {
            long girId = gir.MaterialRequest_Id;

            GIR_Log log = new GIR_Log
            {
                Gir_Id = girId,
                Master_Log = serializer.Serialize(BuildGIRMasterSnapshot(gir, dbc)),
                Details_Log = serializer.Serialize(BuildGIRDetailSnapshot(dbc, girId)),
                Loged_By = AppConfig.UserID,
                Log_Time = DateTime.Now
            };

            dbc.GIR_Logs.InsertOnSubmit(log);
        }

        [WebMethod]

        public static string SaveMIR(int MIRId, string MIRNum, string MIRDate, string Pirority, string dept, string remarks, string WareHouse, string btnValue)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            JavaScriptSerializer oJS = new JavaScriptSerializer();
            PMS.MaterialIssueRequest obj = new PMS.MaterialIssueRequest();
            var MIRid = string.Empty;
            if (btnValue == "Save" || btnValue == "Replicate")
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
                WriteGIRChangeLog(db, obj, oJS);

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
                if(item.Last_MIR_Qty != "null")
                {
                    obj.Last_MIR_Qty = Convert.ToDecimal(item.Last_MIR_Qty);
                }
                else
                {
                    obj.Last_MIR_Qty = 0;
                }
                if(item.Last_SIN_Qty != "null")
                {
                    obj.Last_SIN_Qty = Convert.ToDecimal(item.Last_SIN_Qty);
                }
                else
                {
                    obj.Last_SIN_Qty = 0;
                }
                if (!string.IsNullOrEmpty(item.Last_GIR_Date) && item.Last_GIR_Date != "null")
                {
                    try
                    {
                        DateTime parsedDate;
                        if (DateTime.TryParse(item.Last_GIR_Date, out parsedDate))
                        {
                            obj.Last_GIR_Date = parsedDate;
                        }
                        else
                        {
                            obj.Last_GIR_Date = null;
                        }
                    }
                    catch
                    {
                        obj.Last_GIR_Date = null;
                    }
                }
                else
                {
                    obj.Last_GIR_Date = null;
                }

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
                                     Last_MIR_Qty = Convert.ToString(data.Last_MIR_Qty),
                                     Last_SIN_Qty = Convert.ToString(data.Last_SIN_Qty),
                                     Last_GIR_Date = Convert.ToString(data.Last_GIR_Date),
                                     //Last_GIR_Date = data.Last_GIR_Date.HasValue ? data.Last_GIR_Date.Value.ToString("dd-MMM-yyyy") : "",
                                     remarks = data.Remarks,
                                      UOM_Qty = Convert.ToString(inv.UOM_Qty ?? 0),
                                      FilePath = data.FilePath,

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
            public string Last_MIR_Qty { get; set; }
            public string Last_SIN_Qty { get; set; }
            public string Last_GIR_Date { get; set; }
            public string remarks { get; set; }
            public string MIRId { get; set; }
            public string itemId { get; set; }
            public string MIR_Detail_ID { get; set; }
            public string itemCode { get; set; }
            public string Description { get; set; }
            public string Unit { get; set; }
            public string UOM_Qty { get; set; }
            public string Last_MIR_Date { get; set; }
            public string FilePath { get; set; }
        }

        [WebMethod]
        public static bool CheckGIRApprovalRights()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var form_id = 5;
                var user_id = AppConfig.UserID;

                return (from SASD in db.Sys_Approval_Stage_Details
                        join SASM in db.Sys_Approval_Stage_Masters on SASD.Stage_ID equals SASM.Stage_ID
                        join SATD in db.Sys_Approval_Tempelate_Detail_Stages on SASM.Stage_ID equals SATD.StageId
                        join SATF in db.Sys_Approval_Tempelate_Detail_Forms on SATD.Tempelate_ID equals SATF.Tempelate_ID
                        join SATM in db.Sys_Approval_Tempelate_Masters on SATD.Tempelate_ID equals SATM.Tempelate_ID
                        where SASD.UserId == user_id && SATF.FormId == form_id && SATM.IsActive == true && SASM.IsDeleted == false
                        select SASD).Any();
            }
        }

        [WebMethod]
        public static string GetGIRApprovalInfo(string GIRId)
        {
            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                var girId = Convert.ToInt32(GIRId);
                var user_id = AppConfig.UserID;
                var form_id = 5;

                var gir = db.MaterialIssueRequests
                    .Where(m => m.MaterialRequest_Id == girId)
                    .FirstOrDefault();

                if (gir == null)
                    return (new JavaScriptSerializer()).Serialize(new { CanApprove = false, MaxApprovalLimit = 0m, Amount = 0m });

                var maxApprovalLimit = db.ExecuteQuery<decimal?>(
                    "SELECT MAX(SASD.MaxApprovalLimit) " +
                    "FROM Sys_Approval_Stage_Detail SASD " +
                    "INNER JOIN Sys_Approval_Stage_Master SASM ON SASD.Stage_ID = SASM.Stage_ID " +
                    "INNER JOIN Sys_Approval_Tempelate_Detail_Stages SATD ON SASM.Stage_ID = SATD.StageId " +
                    "INNER JOIN Sys_Approval_Tempelate_Detail_Forms SATF ON SATD.Tempelate_ID = SATF.Tempelate_ID " +
                    "INNER JOIN Sys_Approval_Tempelate_Master SATM ON SATD.Tempelate_ID = SATM.Tempelate_ID " +
                    "WHERE SASD.UserId = {0} AND SATF.FormId = {1} AND SATM.IsActive = 1 AND SASM.IsDeleted = 0",
                    user_id, form_id).FirstOrDefault() ?? 0m;

                var canApprove = maxApprovalLimit == -1m;

                var result = new
                {
                    CanApprove = canApprove,
                    MaxApprovalLimit = maxApprovalLimit,
                    Amount = 0m
                };

                return (new JavaScriptSerializer()).Serialize(result);
            }
        }

        [WebMethod]
        public static string ApproveSingleGIR(string GIRId, string approvalRemarks)
        {
            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                var girId = Convert.ToInt32(GIRId);
                var user_id = AppConfig.UserID;
                var form_id = 5;

                var MIR = db.MaterialIssueRequests
                    .Where(m => m.MaterialRequest_Id == girId)
                    .SingleOrDefault();

                if (MIR == null)
                    return "Error: Goods Issuance Request not found";

                var isFinalApprovals = (from SASD in db.Sys_Approval_Stage_Details
                                        join SASM in db.Sys_Approval_Stage_Masters on SASD.Stage_ID equals SASM.Stage_ID
                                        join SATD in db.Sys_Approval_Tempelate_Detail_Stages on SASM.Stage_ID equals SATD.StageId
                                        join SATF in db.Sys_Approval_Tempelate_Detail_Forms on SATD.Tempelate_ID equals SATF.Tempelate_ID
                                        where SASD.UserId == user_id && SATF.FormId == form_id && SASM.IsDeleted == false
                                        select new { SASM.IsFinalApproval, SATF.FormId }).ToList();

                if (isFinalApprovals.Any(a => a.IsFinalApproval == true && a.FormId == form_id))
                {
                    var Details = db.spApproveMIR((int)MIR.MaterialRequest_Id, user_id);
                    db.SubmitChanges();

                    var sasd = (from tbl in db.Sys_Approval_Stage_Details
                                join SASM in db.Sys_Approval_Stage_Masters on tbl.Stage_ID equals SASM.Stage_ID
                                join SATDS in db.Sys_Approval_Tempelate_Detail_Stages on SASM.Stage_ID equals SATDS.StageId
                                join SATF in db.Sys_Approval_Tempelate_Detail_Forms on SATDS.Tempelate_ID equals SATF.Tempelate_ID
                                where tbl.UserId == user_id && SASM.IsFinalApproval == true && SATF.FormId == form_id && SASM.IsDeleted == false
                                select tbl).FirstOrDefault();

                    if (sasd != null)
                    {
                        var satds = (from tbl in db.Sys_Approval_Tempelate_Detail_Stages
                                     join SATF in db.Sys_Approval_Tempelate_Detail_Forms on tbl.Tempelate_ID equals SATF.Tempelate_ID
                                     where tbl.StageId == sasd.Stage_ID && SATF.FormId == form_id
                                     select tbl).FirstOrDefault();

                        if (satds != null)
                        {
                            var log = new Sys_Approval_Log();
                            log.Approval_Template_ID = satds.Tempelate_ID;
                            log.Approval_Stage_ID = sasd.Stage_ID;
                            log.Entry_ID = (int)MIR.MaterialRequest_Id;
                            log.Form_ID = form_id;
                            log.From_Name = "Goods Issuance Request";
                            log.Remarks = MIR.Remarks;
                            log.Company_ID = AppConfig.Company_ID;
                            log.IsFinalAprroval = true;
                            log.Entry_Status = "Approved";
                            log.Approve_By = user_id;
                            log.Approve_Date = DateTime.Now;
                            log.IsRejected = false;
                            log.Approval_Remarks = approvalRemarks;
                            db.Sys_Approval_Logs.InsertOnSubmit(log);
                            db.SubmitChanges();
                        }
                    }
                }
                else
                {
                    MIR.Status = "Pending";
                    MIR.Approved_Time = DateTime.Now;
                    MIR.Approved_By = user_id;
                    db.SubmitChanges();

                    var sasd = (from tbl in db.Sys_Approval_Stage_Details
                                join SASM in db.Sys_Approval_Stage_Masters on tbl.Stage_ID equals SASM.Stage_ID
                                join SATDS in db.Sys_Approval_Tempelate_Detail_Stages on SASM.Stage_ID equals SATDS.StageId
                                join SATF in db.Sys_Approval_Tempelate_Detail_Forms on SATDS.Tempelate_ID equals SATF.Tempelate_ID
                                where tbl.UserId == user_id && SASM.IsFinalApproval == false && SATF.FormId == form_id && SASM.IsDeleted == false
                                select tbl).FirstOrDefault();

                    if (sasd != null)
                    {
                        var satds = (from tbl in db.Sys_Approval_Tempelate_Detail_Stages
                                     join SATF in db.Sys_Approval_Tempelate_Detail_Forms on tbl.Tempelate_ID equals SATF.Tempelate_ID
                                     where tbl.StageId == sasd.Stage_ID && SATF.FormId == form_id
                                     select tbl).FirstOrDefault();

                        if (satds != null)
                        {
                            var log = new Sys_Approval_Log();
                            log.Approval_Template_ID = satds.Tempelate_ID;
                            log.Approval_Stage_ID = sasd.Stage_ID;
                            log.Entry_ID = (int)MIR.MaterialRequest_Id;
                            log.Form_ID = form_id;
                            log.From_Name = "Goods Issuance Request";
                            log.Remarks = MIR.Remarks;
                            log.Company_ID = AppConfig.Company_ID;
                            log.IsFinalAprroval = false;
                            log.Entry_Status = "Pending";
                            log.Approve_By = user_id;
                            log.Approve_Date = DateTime.Now;
                            log.IsRejected = false;
                            log.Approval_Remarks = approvalRemarks;
                            db.Sys_Approval_Logs.InsertOnSubmit(log);
                            db.SubmitChanges();
                        }
                    }
                }
                db.SubmitChanges();
                return "Success";
            }
        }
    }
}