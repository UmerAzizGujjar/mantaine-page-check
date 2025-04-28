using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Account
{
    public partial class UserDoctorControl : System.Web.UI.Page
    {
        protected static int masterID = -1;
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static string FillUsers()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var query = (from users in db.aspnet_Users
                         select new
                         {
                             users.UserId,
                             users.UserName
                         }).ToList();

            return (new JavaScriptSerializer()).Serialize(query);
        }
        [WebMethod]
        public static string filldoctor()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var query = (from users in db.HR_Employees
                         where users.IsDoctor == true
                         select new
                         {
                             users.Emp_ID,
                             users.Emp_Name
                         }).ToList();

            return (new JavaScriptSerializer()).Serialize(query);
        }

       
        public class SubTypeData
        {
            public List<SubTypeList> SegmentList { get; set; }
        }


        public class SubTypeList
        {
            public string userid { get; set; }
            public string Branch_id { get; set; }
            public string ware_house { get; set; }
        }
        [WebMethod]
        public static string LoadDetails(int id)
        {
            string result = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = (from data in db.User_Branches
                             where data.User_Branch_Master_Id == id
                             select new
                             {
                                 data.ware_house_id,
                                 warehouse_name = db.HR_Employees
                                    .Where(a => a.Emp_ID ==Convert.ToInt32(data.ware_house_id))
                                    .Select(a => a.Emp_Name)
                                    .FirstOrDefault(),

                                 data.User_id,

                                 user_name = DBClass.getField("select username from aspnet_Users where UserId='" + data.User_id + "'"),




                             }).ToList();
                result = (new JavaScriptSerializer()).Serialize(query);
            }

            return result;
        }

        [WebMethod]

        public static string SaveSegments(string userid, string btnSave, int EditId, List<SubTypeList> AllItemDetail)
        {
            try
            {
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                JavaScriptSerializer oJS = new JavaScriptSerializer();
                User_Branch_Master Master;
                var max = 0;
                var getMaxVal = 0;
                int returned_data = 0;
                var user_ID = (from data in db.User_Branch_Masters.Where(x => x.User_Branch_Master_Id == EditId)
                               select data.user_id).FirstOrDefault();
                var query = (from data in db.User_Branch_Masters.Where(x => x.user_id == user_ID)
                             select data).ToList();

                if (btnSave == "Save")
                {
                    Master = new User_Branch_Master();

                    Master.Created_By = AppConfig.UserID;
                    Master.Created_Time = DateTime.Now;
                    Master.isprivate = true;

                }
                else
                {
                    Master = (from tbl in db.User_Branch_Masters
                              where tbl.User_Branch_Master_Id == EditId
                              select tbl).FirstOrDefault();
                    Master.Updated_by = AppConfig.UserID;
                    Master.Updated_Time = DateTime.Now;
                    Master.isprivate = true;

                }
                Master.user_id = Guid.Parse(userid);
                if (btnSave == "Save")
                {

                    if (query.Count > 0)
                    {
                        returned_data = 1;
                    }
                    else
                    {
                        db.User_Branch_Masters.InsertOnSubmit(Master);
                        db.SubmitChanges();
                    }
                }

                if (btnSave == "Save")
                {
                    if (query.Count > 0)
                    {
                        returned_data = -1;
                        max = returned_data;
                    }
                    else
                    {
                        getMaxVal = Convert.ToInt32(DBClass.getField("exec spGetMax 'User_Branch_Master', 'User_Branch_Master_Id'"));
                        max = Convert.ToInt32(getMaxVal) - 1;
                    }
                }
                else
                {
                    max = EditId;
                }
                masterID = max;
                User_Branch est;
                if (btnSave == "Update")
                {
                    var querySubType =
                     from subtype in db.User_Branches
                     where
                       subtype.User_Branch_Master_Id == EditId
                     select subtype;
                    foreach (var del in querySubType)
                    {
                        db.User_Branches.DeleteOnSubmit(del);
                    }
                    db.SubmitChanges();
                }
                if (masterID != -1)
                {
                    foreach (var acc in AllItemDetail)
                    {
                        est = new User_Branch();
                        est.Branch_Id = Convert.ToInt32(acc.Branch_id);
                        est.ware_house_id = acc.ware_house;
                        est.isprivate = true;
                        est.User_id = Guid.Parse(userid);
                        est.User_Branch_Master_Id = max;
                        db.User_Branches.InsertOnSubmit(est);

                        db.SubmitChanges();

                    }
                }
                return masterID.ToString();
            }
            catch (Exception ex)
            {

                return "Error";
            }

        }
    }
}