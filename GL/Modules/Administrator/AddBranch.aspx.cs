using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Security.Policy;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using static PMS.DonorReceivingForm;

namespace PMS.Modules.Administrator
{
    public partial class AddBranch : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            
        }
        [WebMethod]
        public static string SaveBranch(CompanyInfo companyData)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            if(companyData.urlID != "")
            {
                var company = (from dt in db.Branches
                               where dt.branch_ID.ToString() ==  companyData.urlID
                               select dt).FirstOrDefault();
                company.branch_Name = companyData.companyName;
                company.branch_Address = companyData.address;
                company.branch_Email = companyData.companyEmail;
                company.branch_Phone1 = companyData.phone1;
               
                db.SubmitChanges();
            }
            else
            {
                Branch newCompany = new Branch();
                if (companyData != null)
                {
                    newCompany.branch_Name = companyData.companyName;
                    newCompany.branch_Address = companyData.address;
                    newCompany.branch_Email = companyData.companyEmail;
                    newCompany.branch_Phone1 = companyData.phone1;
                   

                }
                db.Branches.InsertOnSubmit(newCompany);
                db.SubmitChanges();
            }
                

            return "";
        }
        [WebMethod]
        public static string DeleteCompany(int ID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.Branches.FirstOrDefault(p => p.branch_ID == ID);

                if (query != null)
                {
                    //string fileName = Path.GetFileName(query.ImageURL);

                    //string imagePath = HttpContext.Current.Server.MapPath("~/wwwroot/CompanyImages/" + fileName);

                    db.Branches.DeleteOnSubmit(query);
                    db.SubmitChanges();
                    //if (File.Exists(imagePath))
                    //{
                    //    File.Delete(imagePath);
                    //}

                    return "1";
                }
                else
                {
                    return "0";
                }
            }
        }


        [WebMethod]
        public static string GetBranchDetail(int ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var query = (from p in db.Branches
                         where p.branch_ID == ID
                         select new
                         {

                             companyName = p.branch_Name,
                             companyEmail = p.branch_Email,
                             phone1 = p.branch_Phone1,
                             address = p.branch_Address,
                      
                             


                         }).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(query);
        }
        [WebMethod]

        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    string userId = HttpContext.Current.Session["UserId"].ToString();

                    DateTime searchDate;
                    bool isDateSearch = DateTime.TryParse(searchValue, out searchDate);

                    var Total_companies = _dbContext.Branches.Count();
                    var comp = (from p in _dbContext.Branches
                                where (
                                      p.branch_Name.ToString().Contains(searchValue) ||
                                      p.branch_Email.Contains(searchValue) ||
                                      p.branch_Phone1.Contains(searchValue)
                                  )
                                  select new
                                  {
                                      
                                      p.branch_ID,
                                      p.branch_Name,
                                      p.branch_Email,
                                      p.branch_Phone1
                                  });




                    var FilteredCount = comp.Count();
                    switch (sortColumn)
                    {
                        case "comp_ID":
                            comp = sortColumnDirection == "asc" ? comp.OrderBy(a => a.branch_ID) : comp.OrderByDescending(a => a.branch_ID);
                            break;
                        case "CompName":
                            comp = sortColumnDirection == "asc" ? comp.OrderBy(a => a.branch_Name) : comp.OrderByDescending(a => a.branch_Name);
                            break;
                        case "CompEmail":
                            comp = sortColumnDirection == "asc" ? comp.OrderBy(a => a.branch_Email) : comp.OrderByDescending(a => a.branch_Email);
                            break;
                        case "CompCode":
                            comp = sortColumnDirection == "asc" ? comp.OrderBy(a => a.branch_Phone1) : comp.OrderByDescending(a => a.branch_Phone1);
                            break;
                        
                    }


                    var compientList = comp.Skip(start).Take(length).ToList();


                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_companies, data = compientList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching compient list", ex);
            }
        }


        public class CompanyInfo
        {
            public string urlID { get; set; }
            public string companyName { get; set; }
            public string companyEmail { get; set; }
            public string phone1 { get; set; }

            public string address { get; set; }
            
        }
    }
}