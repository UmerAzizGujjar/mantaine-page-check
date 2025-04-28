using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class PackaageView : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        public class Result
        {
            public string Packages_ID;
            public string Package_Name;
            public string Package_Type;
            public string Department;
            public string Duration;
            public string Remarks;
         
            //public string Item_Type; 
        }

        [WebMethod]
        public static List<Result> Search()
        {
            string SearchSql = "select Packages_ID,Package_Name,isnull(dbo.GetDataValueName('Package Type',Package_Type),'') as Package_Type,isnull(dbo.GetDataValueName('Patient Main Category',Department),'') as Department,Duration,Remarks from Packages   order by 1 desc";

            DataTable dt = DBClass.getDataTable(SearchSql);

            List<Result> list = new List<Result>();

            foreach (DataRow dr in dt.Rows)
            {
                Result rslt = new Result()
                {
                    Packages_ID = dr[0] == DBNull.Value ? "" : (string)dr[0].ToString(),
                    Package_Name = dr[1] == DBNull.Value ? "" : dr[1].ToString(),
                    Package_Type = dr[2] == DBNull.Value ? "" : dr[2].ToString(),
                    Department = dr[3] == DBNull.Value ? "" : dr[3].ToString(),


                    Duration = dr[4] == DBNull.Value ? "" : dr[4].ToString(),
                    Remarks = dr[5] == DBNull.Value ? "" : dr[5].ToString(),
                    
                    // Manufacture_Part_No = dr[10] == DBNull.Value ? "" : dr[10].ToString(),

                    // Birth_Date = ""                    
                };
                list.Add(rslt);
            }
            return list;
        }
        [WebMethod]
        public static void DeleteRecord(int PakgID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            Packages_Detail PKGD = db.Packages_Details.Where(p => p.Packages_ID== PakgID).FirstOrDefault();
            if (PKGD!=null)
            db.Packages_Details.DeleteOnSubmit(PKGD);

            Package PKGM = db.Packages.Where(p => p.Packages_ID == PakgID).FirstOrDefault();
            if (PKGM != null)
            db.Packages.DeleteOnSubmit(PKGM);
            db.SubmitChanges();
        }

    }
}