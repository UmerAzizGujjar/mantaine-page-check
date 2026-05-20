using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using static PMS.panelagreement;

namespace PMS.GL
{
    public partial class ApprovalStages : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static string loadData(int StageID)
        {
            string data = string.Empty;
            DataBaseDataContext db = new DataBaseDataContext();
            List<ApprovalHierarchyDetail> listObj = new List<ApprovalHierarchyDetail>();

            var result = (from pds in db.Sys_Approval_Stage_Details
                          where pds.Stage_ID == StageID
                          select pds).ToList();
            int counter = 1;
            foreach (var res in result)
            {
                ApprovalHierarchyDetail obj = new ApprovalHierarchyDetail();
                obj.Stage_ID = res.Stage_ID.ToString();
                obj.User_Id = Convert.ToString(res.UserId);
                obj.MaxApprovalLimit = (int?)res.MaxApprovalLimit;
                listObj.Add(obj);
                counter++;
            }
            data = (new JavaScriptSerializer()).Serialize(listObj);
            return data;
        }

        [WebMethod]
        public static string Save(string btnValue, string id, string txtStageName, string txtStageDescription, string txtNoOfApproval, string txtNoOfUnApproval, bool chkFinalApproval, string[][] approvalDetail)
        {
            int lstid = 0;
            Sys_Approval_Stage_Master appp;
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            if (btnValue == "Save")
            {
                appp = new Sys_Approval_Stage_Master();
            }
            else
            {
                appp = (from tbl in db.Sys_Approval_Stage_Masters
                        where tbl.Stage_ID == Convert.ToInt32(id)
                        select tbl).FirstOrDefault();
                appp.Stage_Name = txtStageName;
                appp.Stage_Description = txtStageDescription;
                //appp.NoOfApprovalRequire=Convert.ToInt32(txtNoOfApproval);
                //appp.NoOfUnApprovalRequire=Convert.ToInt32(txtNoOfUnApproval);
                if (!string.IsNullOrEmpty(txtNoOfApproval) && int.TryParse(txtNoOfApproval, out int approvalCount))
                {
                    appp.NoOfApprovalRequire = approvalCount;
                }
                else
                {
                    appp.NoOfApprovalRequire = 0;
                }
                if (!string.IsNullOrEmpty(txtNoOfUnApproval) && int.TryParse(txtNoOfUnApproval, out int unApprovalCount))
                {
                    appp.NoOfUnApprovalRequire = unApprovalCount;
                }
                else
                {
                    appp.NoOfUnApprovalRequire = 0;
                }
                appp.IsFinalApproval = Convert.ToBoolean(chkFinalApproval);
                appp.Updated_By = AppConfig.UserID;
                appp.Updated_Date = DateTime.Now;
                db.SubmitChanges();
            }
            if (btnValue == "Save")
            {
                appp.Stage_Name = txtStageName;
                appp.Stage_Description = txtStageDescription;
                //appp.NoOfApprovalRequire = Convert.ToInt32(txtNoOfApproval);
                //appp.NoOfUnApprovalRequire = Convert.ToInt32(txtNoOfUnApproval);
                if (!string.IsNullOrEmpty(txtNoOfApproval) && int.TryParse(txtNoOfApproval, out int approvalCount))
                {
                    appp.NoOfApprovalRequire = approvalCount;
                }
                else
                {
                    appp.NoOfApprovalRequire = 0;
                }
                if (!string.IsNullOrEmpty(txtNoOfUnApproval) && int.TryParse(txtNoOfUnApproval, out int unApprovalCount))
                {
                    appp.NoOfUnApprovalRequire = unApprovalCount;
                }
                else
                {
                    appp.NoOfUnApprovalRequire = 0;
                }
                appp.IsFinalApproval = Convert.ToBoolean(chkFinalApproval);
                appp.Creation_Date = DateTime.Now;
                appp.Created_By = AppConfig.UserID;
                appp.Company_ID = AppConfig.Company_ID;
                appp.IsDeleted = false;
                db.Sys_Approval_Stage_Masters.InsertOnSubmit(appp);
                db.SubmitChanges();
            }
            else
            {
                string sql = "Delete from Sys_Approval_Stage_Detail where Stage_ID = " + appp.Stage_ID + "";
                DBClass.executeNonQueryWithoutBegin(sql);
            }
            for (int i = 1; i < approvalDetail.Length; i++)
            {
                Sys_Approval_Stage_Detail apdetail = new Sys_Approval_Stage_Detail();
                apdetail.Stage_ID = appp.Stage_ID;
                var a = approvalDetail[i][0].ToString();
                if (Guid.TryParse(approvalDetail[i][0], out Guid userId))
                {
                    apdetail.UserId = userId;
                }
                if (!string.IsNullOrWhiteSpace(approvalDetail[i][1]) &&
                    int.TryParse(approvalDetail[i][1], out int maxApprovalLimit))
                {
                    apdetail.MaxApprovalLimit = maxApprovalLimit;
                }
                db.Sys_Approval_Stage_Details.InsertOnSubmit(apdetail);
            }
            db.SubmitChanges();
            if (btnValue == "Save")
            {
                lstid = appp.Stage_ID;
            }
            else
            {
                lstid = Convert.ToInt32(id);
            }
            return lstid.ToString();
        }
        [WebMethod]
        public static string loadUser()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var listItems = (from a in db.aspnet_Users
                             select new
                             {
                                 a.UserId,
                                 a.UserName
                             }).ToList();

            return (new JavaScriptSerializer()).Serialize(listItems);
        }
        [WebMethod]
        public static string LoadDetails(int id)
        {
            List<ApprovalHierarchyDetail> detail = new List<ApprovalHierarchyDetail>();
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                detail = (from m in db.Sys_Approval_Stage_Details
                          where m.Stage_ID == id
                          select new ApprovalHierarchyDetail
                          {
                              Stage_ID = m.Stage_ID.ToString(),
                              User_Id = m.UserId.ToString(),
                              MaxApprovalLimit = (int?)m.MaxApprovalLimit
                          }).ToList();
            }
            return (new JavaScriptSerializer()).Serialize(detail);
        }
        [WebMethod]
        public static string LoadMasterData(string id)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var query = (from data in db.Sys_Approval_Stage_Masters.Where(x => x.Stage_ID == Convert.ToInt32(id)) select data).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(query);
        }
        public class ApprovalHierarchyDetail
        {
            public string Stage_ID { get; set; }
            public string User_Id { get; set; }
            public int? MaxApprovalLimit { get; set; }
        }
    }
}