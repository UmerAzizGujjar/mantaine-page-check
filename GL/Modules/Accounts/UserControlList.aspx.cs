using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Account
{
    public partial class UserControlList : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    var templates = _dbContext.Medicines_Templates.Count();

                    var branch = from a in _dbContext.User_Branch_Masters
                                 join u in _dbContext.aspnet_Users 
                                 on a.user_id equals u.UserId
                                 where u.UserName.Contains(searchValue) || a.user_id.ToString().Contains(searchValue)
                                 select new
                                 {
                                     Created_Time = a.Created_Time,
                                     user_name = u.UserName, 
                                     User_Branch_Master_Id = a.User_Branch_Master_Id
                                 };
                    var FilteredCount = branch.Count();
                    switch (sortColumn)
                    {
                        case "user_name":
                            branch = sortColumnDirection == "asc" ? branch.OrderBy(a => a.user_name) : branch.OrderByDescending(a => a.user_name);
                            break;

                    }


                    var userbranchlist = branch.Skip(start).Take(length).ToList();


                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = templates, data = userbranchlist };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching patient list", ex);
            }
        }
        [WebMethod]
        public static bool DeleteRecord(string Id)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            User_Branch_Master st = new User_Branch_Master();
            User_Branch stkItem = new User_Branch();

            SqlTransaction tranObj = null;
            SqlConnection con = new SqlConnection(DBClass.ConnectionString());
            con.Open();
            tranObj = con.BeginTransaction();
            try
            {
                var MainId = (from itm in db.User_Branch_Masters
                              where (itm.User_Branch_Master_Id == int.Parse(Id))
                              select itm.User_Branch_Master_Id).FirstOrDefault();
                if (MainId != 0)
                {
                    DBClass.exectueQuery("delete User_Branch  where User_Branch_Master_Id =" + MainId, tranObj, con);
                    DBClass.exectueQuery("delete User_Branch_Master where User_Branch_Master_Id =" + MainId, tranObj, con);


                    tranObj.Commit();
                }
                else
                {
                    tranObj.Rollback();
                    return false;
                }
            }
#pragma warning disable CS0168 // The variable 'ex' is declared but never used
            catch (Exception ex)
#pragma warning restore CS0168 // The variable 'ex' is declared but never used
            {
                if (tranObj != null)
                    tranObj.Rollback();
                return false;
            }
            return true;
        }
    }
}