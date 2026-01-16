using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.Administrator
{
    public partial class User_BranchWise : System.Web.UI.Page
    {
        protected static int masterID = -1;

        protected void Page_Load(object sender, EventArgs e)
        {
        }

        [WebMethod]
        public static string FillUsers()
        {
            using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                var users = db.aspnet_Users.Select(u => new { u.UserId, u.UserName }).ToList();
                return new JavaScriptSerializer().Serialize(users);
            }
        }

        public class BranchDetail
        {
            public string userid { get; set; }
            public string branch { get; set; }
        }

        [WebMethod]
        public static string SaveSegment(string userid, string btnSave, int EditId, List<BranchDetail> AllItemDetail)
        {
            try
            {
                using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    Guid userGuid = Guid.Parse(userid);
                    if (btnSave == "Save")
                    {
                        var existingUserEntry = db.Branch_Wise_Users
                            .FirstOrDefault(x => x.User_Id == userGuid);
                        if (existingUserEntry != null)
                        {
                            return "-1"; 
                        }
                    }

                    Branch_Wise_User master;
                    if (btnSave == "Save")
                    {
                        master = new Branch_Wise_User
                        {
                            User_Id = userGuid,
                            Created_By = AppConfig.UserID,
                            Created_Time = DateTime.Now,
                            is_cancel = false
                        };
                        db.Branch_Wise_Users.InsertOnSubmit(master);
                        db.SubmitChanges();
                        masterID = master.Branch_wise_User_Id;
                    }
                    else
                    {
                        master = db.Branch_Wise_Users.FirstOrDefault(x => x.Branch_wise_User_Id == EditId);
                        if (master == null) return "-1";

                        master.User_Id = userGuid;
                        master.Updated_By = AppConfig.UserID;
                        master.Updated_Time = DateTime.Now;
                        db.SubmitChanges();
                        masterID = EditId;
                    }

                    var existingDetails = db.Branch_Wise_User_Details
                        .Where(x => x.Branch_wise_User_Id == masterID)
                        .ToList();

                    var newBranchIds = new HashSet<string>(AllItemDetail.Select(x => x.branch));

                    var toDelete = existingDetails
                        .Where(ed => !newBranchIds.Contains(ed.Brancg))
                        .ToList();

                    var toKeepBranchIds = new HashSet<string>();

                    foreach (var newItem in AllItemDetail)
                    {
                        var existing = existingDetails.FirstOrDefault(ed => ed.Brancg == newItem.branch);
                        if (existing != null)
                        {
                            existing.User_Id = userGuid;
                            toKeepBranchIds.Add(newItem.branch);
                        }
                        else
                        {
                            db.Branch_Wise_User_Details.InsertOnSubmit(new Branch_Wise_User_Detail
                            {
                                Branch_wise_User_Id = masterID,
                                User_Id = userGuid,
                                Brancg = newItem.branch
                            });
                        }
                    }

                    if (toDelete.Any())
                    {
                        db.Branch_Wise_User_Details.DeleteAllOnSubmit(toDelete);
                    }

                    db.SubmitChanges();
                    return masterID.ToString();
                }
            }
            catch (Exception ex)
            {
                return "Error";
            }
        }

        [WebMethod]
        public static string LoadDetail(int id)
        {
            using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                var query = from detail in db.Branch_Wise_User_Details
                            join usr in db.aspnet_Users on detail.User_Id equals usr.UserId
                            join br in db.Branches on detail.Brancg equals br.branch_ID.ToString()
                            where detail.Branch_wise_User_Id == id
                            select new
                            {
                                User_Id = detail.User_Id,
                                user_name = usr.UserName,
                                Branch = detail.Brancg,         
                                Branch_name = br.branch_Name
                            };

                return new JavaScriptSerializer().Serialize(query.ToList());
            }
        }

        [WebMethod]
        public static string fillBranch()
        {
            using (var db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                var branches = from b in db.Branches
                               select new
                               {
                                   DataValue_ID = b.branch_ID,   
                                   DataValue_Name = b.branch_ID.ToString(), 
                                   DataValue_Description = b.branch_Name  
                               };

                return new JavaScriptSerializer().Serialize(branches.ToList());
            }
        }
    }
}