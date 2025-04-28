using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class DepartmentWiseUser : System.Web.UI.Page
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
        public class DepartmentDetail
        {
            public string userid { get; set; }
            public string dept { get; set; }

        }
        [WebMethod]

        public static string SaveSegment(string userid, string btnSave, int EditId, List<DepartmentDetail> AllItemDetail)
        {
            try
            {
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                JavaScriptSerializer oJS = new JavaScriptSerializer();
                Department_Wise_User Master;
                var max = 0;
                var getMaxVal = 0;
                int returned_data = 0;
                var user_ID = (from data in db.Department_Wise_Users.Where(x => x.Dept_Wise_User_Id == EditId)
                               select data.User_Id).FirstOrDefault();
                var query = (from data in db.Department_Wise_Users.Where(x => x.User_Id == user_ID)
                             select data).ToList();

                if (btnSave == "Save")
                {
                    Master = new Department_Wise_User();
                    Master.Created_By = AppConfig.UserID;
                    Master.Created_Time = DateTime.Now;
                }
                else
                {
                    Master = (from tbl in db.Department_Wise_Users
                              where tbl.Dept_Wise_User_Id == EditId
                              select tbl).FirstOrDefault();
                    Master.Updated_By = AppConfig.UserID;
                    Master.Updated_Time = DateTime.Now;

                }
                Master.User_Id = Guid.Parse(userid);
                if (btnSave == "Save")
                {

                    if (query.Count > 0)
                    {
                        returned_data = 1;
                    }
                    else
                    {
                        db.Department_Wise_Users.InsertOnSubmit(Master);
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
                        getMaxVal = Convert.ToInt32(DBClass.getField("exec spGetMax 'Department_Wise_User', 'Dept_Wise_User_Id'"));
                        max = Convert.ToInt32(getMaxVal) - 1;
                    }
                }
                else
                {
                    max = EditId;
                }
                masterID = max;
                Department_Wise_User_Detail est;
                if (btnSave == "Update")
                {
                    var querySubType =
                     from subtype in db.Department_Wise_User_Details
                     where
                       subtype.Dept_Wise_User_Id == EditId
                     select subtype;
                    foreach (var del in querySubType)
                    {
                        db.Department_Wise_User_Details.DeleteOnSubmit(del);
                    }
                    db.SubmitChanges();
                }
                if (masterID != -1)
                {
                    foreach (var acc in AllItemDetail)
                    {
                        est = new Department_Wise_User_Detail();
                        est.User_Id = Guid.Parse(userid);
                        est.Department = acc.dept;
                        est.Dept_Wise_User_Id = max;
                        db.Department_Wise_User_Details.InsertOnSubmit(est);
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
        [WebMethod]
        public static string LoadDetail(int id)
        {
            string result = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = (from data in db.Department_Wise_User_Details
                             where data.Dept_Wise_User_Id == id
                             select new
                             {
                                 data.Department,
                                 Department_name = db.GetDataValueName("Department", data.Department),
                                 data.User_Id,
                                 user_name = DBClass.getField("select username from aspnet_Users where UserId='" + data.User_Id + "'"),
                             }).ToList();
                result = (new JavaScriptSerializer()).Serialize(query);
            }
            return result;
        }
        [WebMethod]
        public static string fillDepartment()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var query = (from vs in db.ValueSets
                         join
                         dv in db.DataValues on vs.ValueSet_ID equals dv.ValueSet_ID
                         where vs.ValueSet_Description.Equals("Department")
                         select new
                         {
                             dv.DataValue_ID,
                             dv.DataValue_Name,
                             dv.DataValue_Description
                         }).ToList();
            return (new JavaScriptSerializer()).Serialize(query);
        }
    }
}