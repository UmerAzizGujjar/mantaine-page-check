using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.Dashboards
{
    public partial class Biodatadashboard : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static string GetCity()
        {
            string data = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "City"
                              select new
                              {
                                  dv.DataValue_Name,
                                  dv.DataValue_Description
                              }).ToList();
                data = new JavaScriptSerializer().Serialize(result);
            }
            return data;
        }
        [WebMethod]
        public static string Getsymptoms()
        {
            string data = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Symtoms"
                              select new
                              {
                                  dv.DataValue_Name,
                                  dv.DataValue_Description
                              }).ToList();
                data = new JavaScriptSerializer().Serialize(result);
            }
            return data;
        }
        [WebMethod]
        public static string GetArea()
        {
            string data = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Area"
                              select new
                              {
                                  dv.DataValue_Name,
                                  dv.DataValue_Description
                              }).ToList();
                data = new JavaScriptSerializer().Serialize(result);
            }
            return data;
        }

        [WebMethod]
        public static string GetGender()
        {
            string data = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Gender"
                              select new
                              {
                                  dv.DataValue_Name,
                                  dv.DataValue_Description
                              }).ToList();
                data = new JavaScriptSerializer().Serialize(result);
            }
            return data;
        }

        [WebMethod]
        public static string LoadPaiDashboard(string startdate, string enddate, string gender, string symptoms, string city, string area)
        {
            string result = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = db.sp_GetTopSymptoms(startdate, enddate, gender, symptoms, city, area).ToList();
                result = (new JavaScriptSerializer()).Serialize(query);
            }
            return result;
        }

        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue, string txt_sdate, string txt_edate, string gender, string symptoms, string city, string area)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var all = db.sp_Bio_Data_Dashborad(txt_sdate, txt_edate, gender, symptoms, city, area).ToList();

                if (!string.IsNullOrEmpty(searchValue))
                {
                    string sv = searchValue.ToLower();
                    all = all.Where(x =>
                        (x.mr_no_sequence ?? "").ToLower().Contains(sv) ||
                        (x.Full_Name ?? "").ToLower().Contains(sv) ||
                        (x.Mobile1 ?? "").ToLower().Contains(sv) ||
                        (x.Symptoms ?? "").ToLower().Contains(sv)).ToList();
                }

                if (!string.IsNullOrEmpty(sortColumn))
                {
                    if (sortColumnDirection == "desc")
                    {
                        switch (sortColumn)
                        {
                            case "mrNo": all = all.OrderByDescending(x => x.mr_no_sequence).ToList(); break;
                            case "name": all = all.OrderByDescending(x => x.Full_Name).ToList(); break;
                            case "age": all = all.OrderByDescending(x => x.Age_years).ToList(); break;
                            case "gender": all = all.OrderByDescending(x => x.Gender).ToList(); break;
                            case "address": all = all.OrderByDescending(x => x.Patient_Address).ToList(); break;
                            case "phone": all = all.OrderByDescending(x => x.Mobile1).ToList(); break;
                            case "diagnosis": all = all.OrderByDescending(x => x.Symptoms).ToList(); break;
                        }
                    }
                    else
                    {
                        switch (sortColumn)
                        {
                            case "mrNo": all = all.OrderBy(x => x.mr_no_sequence).ToList(); break;
                            case "name": all = all.OrderBy(x => x.Full_Name).ToList(); break;
                            case "age": all = all.OrderBy(x => x.Age_years).ToList(); break;
                            case "gender": all = all.OrderBy(x => x.Gender).ToList(); break;
                            case "address": all = all.OrderBy(x => x.Patient_Address).ToList(); break;
                            case "phone": all = all.OrderBy(x => x.Mobile1).ToList(); break;
                            case "diagnosis": all = all.OrderBy(x => x.Symptoms).ToList(); break;
                        }
                    }
                }

                int totalRecords = all.Count;
                var page = all.Skip(start).Take(length).ToList();

                var data = page.Select((x, i) => new
                {
                    srNo = start + i + 1,
                    mrNo = x.mr_no_sequence ?? "",
                    regDate = x.Created_time.HasValue ? x.Created_time.Value.ToString("dd/MM/yyyy hh:mm tt") : "",
                    name = x.Full_Name ?? "",
                    age = x.Age_years ?? "",
                    gender = x.Gender ?? "",
                    address = x.Patient_Address ?? "",
                    phone = x.Mobile1 ?? "",
                    diagnosis = x.Symptoms ?? ""
                }).ToList();

                return new
                {
                    draw,
                    recordsTotal = totalRecords,
                    recordsFiltered = totalRecords,
                    data
                };
            }
        }
    }
}
