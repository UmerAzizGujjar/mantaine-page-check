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
    public partial class AddCompany : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Request.HttpMethod == "POST" && Request.Files.Count > 0)
            {
               
                DataBaseDataContext db = new DataBaseDataContext();
                
                
                HttpPostedFile file = Request.Files["file"];
                if (file != null && file.ContentLength > 0)
                {
                    string id = Request.QueryString["ID"];
                    int maxNo = (from dt in db.sys_Companies
                                 select dt.Company_ID).Max();
                    string foldercomph = Server.MapPath("~/wwwroot/CompanyImages");
                    if (!string.IsNullOrEmpty(id))
                    {

                        string filename = "companyImage" + id + ".png";
                        string URL1 = "../../wwwroot/CompanyImages/" + filename;
                        string fullcomph1 = Path.Combine(foldercomph, filename);
                        file.SaveAs(fullcomph1);
                        var company = (from dt in db.sys_Companies
                                       where dt.Company_ID.ToString() == id
                                       select dt).FirstOrDefault();
                        company.ImageURL = URL1;
                        db.SubmitChanges();
                    }
                    else
                    {
                        string fileName = "companyImage" + maxNo.ToString() + ".png";
                        string URL = "../../wwwroot/CompanyImages/" + fileName;
                        string fullcomph = Path.Combine(foldercomph, fileName);
                        file.SaveAs(fullcomph);
                        var company = (from dt in db.sys_Companies
                                       where dt.Company_ID == maxNo
                                       select dt).FirstOrDefault();
                        company.ImageURL = URL;
                        db.SubmitChanges();
                    }


                        


                    Response.Write("File uploaded successfully");
                    Response.End();
                }
            }
        }
        [WebMethod]
        public static string SaveCompany(CompanyInfo companyData)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            if(companyData.urlID != "")
            {
                var company = (from dt in db.sys_Companies
                               where dt.Company_ID.ToString() ==  companyData.urlID
                               select dt).FirstOrDefault();
                company.Company_Name = companyData.companyName;
                company.Company_Address = companyData.address;
                company.Company_Email = companyData.companyEmail;
                company.Company_Phone1 = companyData.phone1;
                company.Company_Phone2 = companyData.phone2;
                company.Company_SalesTax_No = companyData.salesTax;
                company.Company_NTN_No = companyData.ntn;
                company.Company_Fiscal_Year = companyData.fiscalYear;
                company.CompanyCode = companyData.companyCode;
                db.SubmitChanges();
            }
            else
            {
                sys_Company newCompany = new sys_Company();
                if (companyData != null)
                {
                    newCompany.Company_Name = companyData.companyName;
                    newCompany.Company_Address = companyData.address;
                    newCompany.Company_Email = companyData.companyEmail;
                    newCompany.Company_Phone1 = companyData.phone1;
                    newCompany.Company_Phone2 = companyData.phone2;
                    newCompany.Company_SalesTax_No = companyData.salesTax;
                    newCompany.Company_NTN_No = companyData.ntn;
                    newCompany.Company_Fiscal_Year = companyData.fiscalYear;
                    newCompany.CompanyCode = companyData.companyCode;

                }
                db.sys_Companies.InsertOnSubmit(newCompany);
                db.SubmitChanges();
            }
                

            return "";
        }
        [WebMethod]
        public static string DeleteCompany(int ID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.sys_Companies.FirstOrDefault(p => p.Company_ID == ID);

                if (query != null)
                {
                    string fileName = Path.GetFileName(query.ImageURL);

                    string imagePath = HttpContext.Current.Server.MapPath("~/wwwroot/CompanyImages/" + fileName);

                    db.sys_Companies.DeleteOnSubmit(query);
                    db.SubmitChanges();
                    if (File.Exists(imagePath))
                    {
                        File.Delete(imagePath);
                    }

                    return "1";
                }
                else
                {
                    return "0";
                }
            }
        }


        [WebMethod]
        public static string GetCompanyDetail(int ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var query = (from p in db.sys_Companies
                         where p.Company_ID == ID
                         select new
                         {

                             companyName = p.Company_Name,
                             companyEmail = p.Company_Email,
                             phone1 = p.Company_Phone1,
                             phone2 = p.Company_Phone2,
                             salesTax = p.Company_SalesTax_No,
                             ntn = p.Company_NTN_No,
                             fiscalYear = p.Company_Fiscal_Year,
                             companyCode = p.CompanyCode,
                             address = p.Company_Address,
                             imageURL = p.ImageURL,
                             


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

                    var Total_companies = _dbContext.sys_Companies.Count();
                    var comp = (from p in _dbContext.sys_Companies
                                  where (
                                      p.Company_Name.ToString().Contains(searchValue) ||
                                      p.Company_Email.Contains(searchValue) ||
                                      p.CompanyCode.Contains(searchValue)
                                  )
                                  select new
                                  {
                                      
                                      p.Company_ID,
                                      p.Company_Name,
                                      p.Company_Email,
                                      p.CompanyCode
                                  });




                    var FilteredCount = comp.Count();
                    switch (sortColumn)
                    {
                        case "comp_ID":
                            comp = sortColumnDirection == "asc" ? comp.OrderBy(a => a.Company_ID) : comp.OrderByDescending(a => a.Company_ID);
                            break;
                        case "CompName":
                            comp = sortColumnDirection == "asc" ? comp.OrderBy(a => a.Company_Name) : comp.OrderByDescending(a => a.Company_Name);
                            break;
                        case "CompEmail":
                            comp = sortColumnDirection == "asc" ? comp.OrderBy(a => a.Company_Email) : comp.OrderByDescending(a => a.Company_Email);
                            break;
                        case "CompCode":
                            comp = sortColumnDirection == "asc" ? comp.OrderBy(a => a.CompanyCode) : comp.OrderByDescending(a => a.CompanyCode);
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
            public string phone2 { get; set; }
            public string salesTax { get; set; }
            public string ntn { get; set; }
            public string fiscalYear { get; set; }
            public string companyCode { get; set; }
            public string address { get; set; }
            
        }
    }
}