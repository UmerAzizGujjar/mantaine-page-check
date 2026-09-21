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
    public partial class CostCenterWiseDepartment : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static string SaveSegment(string costcenter, string btnSave, int EditId, List<DepartmentDetail> AllItemDetail)
        {
            try
            {
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

                CostCenter_Wise_Department Master;
                int masterId = 0;

                if (btnSave == "Save")
                {
                    bool alreadyExists = db.CostCenter_Wise_Departments.Any(x => x.CostCenter == costcenter);
                    if (alreadyExists)
                    {
                        return "-1";
                    }

                    Master = new CostCenter_Wise_Department();
                    Master.CostCenter = costcenter;
                    Master.Created_By = AppConfig.UserID;
                    Master.Created_Time = DateTime.Now;

                    db.CostCenter_Wise_Departments.InsertOnSubmit(Master);
                    db.SubmitChanges();

                    masterId = Master.CostCenter_wise_Department_Id;
                }
                else
                {
                    Master = (from tbl in db.CostCenter_Wise_Departments
                              where tbl.CostCenter_wise_Department_Id == EditId
                              select tbl).FirstOrDefault();

                    if (Master != null)
                    {
                        Master.CostCenter = costcenter;
                        Master.Updated_By = AppConfig.UserID;
                        Master.Updated_Time = DateTime.Now;

                        var querySubType = from subtype in db.CostCenter_Wise_Department_Details
                                           where subtype.CostCenter_wise_Department_Id == EditId
                                           select subtype;
                        foreach (var del in querySubType)
                        {
                            db.CostCenter_Wise_Department_Details.DeleteOnSubmit(del);
                        }
                        db.SubmitChanges();
                    }

                    masterId = EditId;
                }

                if (masterId > 0)
                {
                    foreach (var acc in AllItemDetail)
                    {
                        CostCenter_Wise_Department_Detail est = new CostCenter_Wise_Department_Detail();
                        est.CostCenter_wise_Department_Id = masterId;
                        est.Department = acc.department;
                        db.CostCenter_Wise_Department_Details.InsertOnSubmit(est);
                        db.SubmitChanges();
                    }
                }

                return masterId.ToString();
            }
            catch (Exception)
            {
                return "Error";
            }
        }

        [WebMethod]
        public static string FillCostCenter()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            List<ddlListItems> listItems = new List<ddlListItems>();
            listItems = (from p in db.DataValues
                         join v in db.ValueSets on p.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Description == "Cost Center"
                         select new ddlListItems
                         {
                             DataValueName = p.DataValue_Name,
                             DataValueDescription = p.DataValue_Description,
                         }).ToList();
            return (new JavaScriptSerializer()).Serialize(listItems);
        }

        [WebMethod]
        public static string fillDepartment()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            List<ddlListItems> listItems = new List<ddlListItems>();
            listItems = (from p in db.DataValues
                         join v in db.ValueSets on p.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Description == "Patient Main Category"
                         select new ddlListItems
                         {
                             DataValueName = p.DataValue_Name,
                             DataValueDescription = p.DataValue_Description,
                         }).ToList();
            return (new JavaScriptSerializer()).Serialize(listItems);
        }

        [WebMethod]
        public static string LoadDetail(int id)
        {
            string result = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = (from data in db.CostCenter_Wise_Department_Details
                             where data.CostCenter_wise_Department_Id == id
                             select new
                             {
                                 data.CostCenter_wise_Department_Id,
                                 data.Department,
                                 Department_name = db.GetDataValueName("Patient Main Category", data.Department),
                                 CostCenter = db.CostCenter_Wise_Departments
                                     .Where(m => m.CostCenter_wise_Department_Id == data.CostCenter_wise_Department_Id)
                                     .Select(m => m.CostCenter).FirstOrDefault(),
                             }).ToList();
                result = (new JavaScriptSerializer()).Serialize(query);
            }
            return result;
        }

        public class DepartmentDetail
        {
            public string costcenter { get; set; }
            public string department { get; set; }
        }

        private class ddlListItems
        {
            public string DataValueName;
            public string DataValueDescription;
            public string Type;
        }
    }
}
