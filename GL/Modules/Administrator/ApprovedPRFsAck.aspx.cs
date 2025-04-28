using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class ApprovedPRFsAck : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!Page.IsPostBack)
            {
                BindGridView();
                CheckUserRights();
            }
        }
        private void BindGridView()
        {
            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                var userDepartments = db.Department_Wise_User_Details
                      .Where(dept => dept.User_Id == AppConfig.UserID)
                      .Select(dept => dept.Department)
                      .ToList();
                var qry = from a in db.Purchase_Requisitions
                          where a.Status == "Approved" && a.IsNotificationViewed==false&&a.IsDeleted == false && userDepartments.Contains(a.Department)
                          orderby a.PR_Id ascending
                          select new
                          {
                              a.PR_Id,
                              a.PR_Num,
                              a.Remarks,
                              a.Status,
                              Creator = db.aspnet_Users.Where(x => x.UserId == (a.Created_By ?? Guid.Empty)).Select(x => x.UserName).FirstOrDefault(),
                              PRDate = a.PR_Date,
                              Approve_By = string.Join(", ", (from SAL in db.Sys_Approval_Logs
                                                              join user in db.aspnet_Users on SAL.Approve_By equals user.UserId into userGroup
                                                              from usr in userGroup.DefaultIfEmpty()
                                                              where a.PR_Id == SAL.Entry_ID && SAL.Form_ID == 1
                                                              select usr.UserName ?? "").Distinct()),
                              Department = db.GetDataValueName("Department", a.Department),                             
                          };

                var formattedQuery = qry.AsEnumerable().Select(x => new
                {
                    x.PR_Id,
                    x.PR_Num,
                    x.Remarks,
                    x.Status,
                    x.Creator,
                    PRDate = Convert.ToDateTime(x.PRDate).ToString("dd-MMM-yyyy"),
                    x.Approve_By,
                    x.Department,                    
                });               
                GridView1.DataSource = formattedQuery;
                GridView1.DataBind();
            }
        }

        private void CheckUserRights()
        {
            bool hasEntryRights = false;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var user_id = AppConfig.UserID;
                hasEntryRights = (from us in db.aspnet_Users                                  
                                  where us.UserId == user_id && us.IsNotificationViewed == true
                                  select us).Any();
            }
            btnPRNotify.Visible = hasEntryRights;
        }


        protected void btnPRNotify_Click(object sender, EventArgs e)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            foreach (GridViewRow row in GridView1.Rows)
            {
                CheckBox chk = row.FindControl("chkSelect") as CheckBox;
                Label pr_id = row.FindControl("lblPR_ID") as Label;
                if (chk.Checked)
                {
                    var user_id = AppConfig.UserID;
                    Purchase_Requisition PR = (from tbl in db.Purchase_Requisitions
                                               where tbl.PR_Id == Convert.ToInt32(pr_id.Text) && tbl.IsNotificationViewed==false && tbl.Status=="Approved"
                                               select tbl).SingleOrDefault();
                    if (PR != null)
                    {                               
                        PR.IsNotificationViewed = true;
                        db.SubmitChanges();
                    }
                    else
                    {
                        string alertMessage = $"PR: ({pr_id}) Already Acknowledged";
                        ClientScript.RegisterStartupScript(this.GetType(), "alert", $"alert('{alertMessage}');", true);
                        return;
                    }
                }
            }
            Response.Redirect(Request.RawUrl);
        }   
    }
}