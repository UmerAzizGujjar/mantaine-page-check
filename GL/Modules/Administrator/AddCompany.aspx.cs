using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.Administrator
{
    public partial class AddCompany : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Request.HttpMethod == "POST" && Request.Files.Count > 0)
            {
                DataBaseDataContext db = new DataBaseDataContext();
                int maxNo = (from dt in db.sys_Companies
                             select dt.Company_ID).Max();
                
                HttpPostedFile file = Request.Files["file"];
                if (file != null && file.ContentLength > 0)
                {
                    string foldercomph = Server.MapPath("~/wwwroot/Tibbit_theme/images/CompanyImages");
                    if (!Directory.Exists(foldercomph))
                        Directory.CreateDirectory(foldercomph);


                    string fileName = "companyImage" + maxNo.ToString() + ".PNG";
                    string URL = "~/wwwroot/Tibbit_theme/images/CompanyImages/" + fileName;
                    string fullcomph = Path.Combine(foldercomph, fileName);
                    file.SaveAs(fullcomph);
                    var company = (from dt in db.sys_Companies
                                   where dt.Company_ID == maxNo
                                   select dt).FirstOrDefault();
                    company.ImageURL = URL;
                    db.SubmitChanges();


                    Response.Write("File uploaded successfully");
                    Response.End();
                }
            }
        }
        [WebMethod]
        public static string SaveCompany(CompanyInfo companyData)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            sys_Company newCompany = new sys_Company();
            if(companyData != null)
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

            return "";
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