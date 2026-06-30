using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Caching;
using System.Web.Services;
using System.Web.UI.WebControls;
using System.Windows;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using static PMS.DonorReceivingForm;

namespace PMS
{
    public partial class RadiologyResultsPreview : System.Web.UI.Page
    {
        private class OrthancStudyInfo
        {
            public bool Exists { get; set; }
            public string OrthancStudyId { get; set; }
            public string StudyInstanceUID { get; set; }
            public string StudyDate { get; set; }
            public string StudyTime { get; set; }
        }

        private static readonly object OrthancUrlCacheLock = new object();
        private const string OrthancBaseUrlCacheKey = "PACS_URL_BASE_URL";

        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static object GetRadiologyAcknowledgment(int draw, int start, int length, string sortColumn, string sortDirection, string searchValue, string mainDepartmentFilter, string statusFilter, string ddlDoctorFilter, string mainTestDepartmentFilter)
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var query = from pat in db.Reg_patients
                        join bill in db.Ar_Billings on pat.pat_id equals bill.Patient_ID
                        join bill_details in db.Ar_Billing_Details on bill.Bill_ID equals bill_details.Bill_ID
                        join labtest_detail in db.Lab_Test_Details on bill_details.Bill_Details_ID equals labtest_detail.Bill_Details_ID
                        join lbt in db.Laboratory_Tests on labtest_detail.Lab_Test_ID equals lbt.Lab_Test_ID
                        where lbt.System_Generated == true
                              && bill_details.Test_Main_Department != "001"
                              && (bill.isCancel == false || bill.isCancel == null)
                              && !db.Refunds.Any(r => r.Bill_ID == bill.Bill_ID)

                        orderby bill.Bill_Date descending
                        let dept = (from ipd in db.In_Patients
                                    where ipd.Patient_ID == pat.pat_id
                                    orderby ipd.In_Patient_ID descending
                                    select ipd.Department).FirstOrDefault()
                                  ?? (from emg in db.Emergency_Patients
                                      where emg.Patient_ID == pat.pat_id
                                      orderby emg.Emergency_ID descending
                                      select emg.Department).FirstOrDefault()
                                  ?? (from p2 in db.Patients
                                      where p2.Patient_ID == pat.pat_id
                                      select p2.Patient_Main_Category).FirstOrDefault()

                        let emergencyRec = (from emg in db.Emergency_Patients
                                            where emg.Patient_ID == pat.pat_id
                                            orderby emg.Emergency_ID descending
                                            select emg).FirstOrDefault()
                        let inPatientRec = (from ipd in db.In_Patients
                                            where ipd.Patient_ID == pat.pat_id
                                            orderby ipd.In_Patient_ID descending
                                            select ipd).FirstOrDefault()
                        let activeWardId = (emergencyRec != null ? (int?)emergencyRec.Ward_ID : (inPatientRec != null ? (int?)inPatientRec.Ward_ID : null))
                        let activeBedNo = (emergencyRec != null ? (int?)emergencyRec.Bed_No : (inPatientRec != null ? (int?)inPatientRec.Bed_No : null))
                        let wardName = (activeWardId != null ? (from w in db.Ward_Definitions where w.Ward_ID == activeWardId select w.Ward_Type).FirstOrDefault() : null)
                        select new
                        {
                            bill.Bill_Date,
                            bill.Bill_No,
                            bill.Bill_ID,
                            bill_details.Item_Name,
                            pat.Full_Name,
                            pat.mr_no_sequence,
                            bill_details.Bill_Details_ID,
                            Main_Test_Departments = db.GetDataValueName("Main Test Departments", bill_details.Test_Main_Department),
                            labtest_detail.Lab_Test_Detail_ID,
                            Department = db.GetDataValueName("Patient Main Category", dept),
                            bill_details.ParentTrans_Name,
                            DoctorID = labtest_detail.DoctorID ?? (bill_details.Doctor_id != null && bill_details.Doctor_id != "" ? Convert.ToInt32(bill_details.Doctor_id) : 0),
                            LabTest_DoctorID = labtest_detail.DoctorID ?? 0,
                            Billing_DoctorID = (bill_details.Doctor_id != null && bill_details.Doctor_id != "" ? Convert.ToInt32(bill_details.Doctor_id) : 0),
                            IsAcknowledge = labtest_detail.IsAcknowledge ?? false,
                            IsApproved = labtest_detail.isApproved ?? false,
                            History = labtest_detail.History,
                            Priorities = labtest_detail.Priorities,
                            WardName = wardName ?? "",
                            BedNo = (activeBedNo != null ? activeBedNo.Value.ToString() : ""),
                            RawTestDeptCode = bill_details.Test_Main_Department
                        };

            var queryList = query.OrderByDescending(x => x.Bill_Date).ToList();

            if (!string.IsNullOrEmpty(ddlDoctorFilter) && ddlDoctorFilter != "0")
            {
                queryList = queryList.Where(x => x.Billing_DoctorID == Convert.ToInt32(ddlDoctorFilter) ||  x.LabTest_DoctorID == Convert.ToInt32(ddlDoctorFilter)).ToList();
            }
   
            if (!string.IsNullOrEmpty(mainDepartmentFilter) && mainDepartmentFilter != "All")
            {
                queryList = queryList.Where(x => x.ParentTrans_Name == mainDepartmentFilter || (string.IsNullOrEmpty(x.ParentTrans_Name) && mainDepartmentFilter == "WalkIn")).ToList();
            }

            if (!string.IsNullOrEmpty(statusFilter) && statusFilter != "All")
            {
                if (statusFilter == "Approved")
                {
                    queryList = queryList.Where(x => x.IsApproved == true).ToList();
                }
                else if (statusFilter == "NotApproved")
                {
                    queryList = queryList.Where(x => x.IsApproved == false || x.IsApproved == null).ToList();
                }
                else if (statusFilter == "Acknowledged")
                {
                    queryList = queryList.Where(x => x.IsAcknowledge == true && (x.IsApproved == false || x.IsApproved == null)).ToList();
                }
            }

            if (!string.IsNullOrEmpty(mainTestDepartmentFilter) && mainTestDepartmentFilter != "All")
            {
                queryList = queryList.Where(x => x.RawTestDeptCode == mainTestDepartmentFilter).ToList();
            }

            if (!string.IsNullOrEmpty(searchValue))
            {
                queryList = queryList.Where(x =>
                    x.Full_Name.Contains(searchValue) ||
                    x.Bill_No.Contains(searchValue) ||
                    x.mr_no_sequence.Contains(searchValue) ||
                    x.Item_Name.Contains(searchValue)
                ).ToList();
            }

            switch (sortColumn)
            {
                case "Bill_No":
                    queryList = sortDirection == "asc" ? queryList.OrderBy(x => x.Bill_No).ToList() : queryList.OrderByDescending(x => x.Bill_No).ToList();
                    break;
                case "Full_Name":
                    queryList = sortDirection == "asc" ? queryList.OrderBy(x => x.Full_Name).ToList() : queryList.OrderByDescending(x => x.Full_Name).ToList();
                    break;
                case "mr_no_sequence":
                    queryList = sortDirection == "asc" ? queryList.OrderBy(x => x.mr_no_sequence).ToList() : queryList.OrderByDescending(x => x.mr_no_sequence).ToList();
                    break;
                case "Bill_Date":
                    queryList = sortDirection == "asc" ? queryList.OrderByDescending(x => x.Bill_Date).ToList() : queryList.OrderBy(x => x.Bill_Date).ToList();
                    break;
                case "Department":
                    queryList = sortDirection == "asc" ? queryList.OrderBy(x => x.Department).ToList() : queryList.OrderByDescending(x => x.Department).ToList();
                    break;
                default:
                    queryList = queryList.OrderByDescending(x => x.Bill_Date).ToList();
                    break;
            }

            int totalRecords = queryList.Count();
            var finalList = queryList.Skip(start).Take(length).ToList();

            return new
            {
                draw = draw,
                recordsTotal = totalRecords,
                recordsFiltered = totalRecords,
                data = finalList
            };
        }

        [WebMethod]
        public static string GetDoctors()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var doctorList = (from emp in db.HR_Employees
                                  where emp.Resign_Date == null && emp.IsDoctor == true
                                  select new { emp.Emp_ID, emp.Emp_Name }).ToList();
                return (new JavaScriptSerializer()).Serialize(doctorList);
            }
        }
        [WebMethod]
        public static string loadDoctorsforFilter()
        {
            string result = string.Empty;
            DataBaseDataContext db = new DataBaseDataContext();
            var itemsList = (from i in db.HR_Employees select new { i.Emp_ID, name = i.Emp_Name.ToString() }).ToList();
            if (itemsList != null)
            {
                result = (new JavaScriptSerializer()).Serialize(itemsList);
            }
            return result;
        }
        public class Testlist
        {
            public string status { get; set; }
            public string Lab_Test_Detail_ID { get; set; }
            public int Doctor_ID { get; set; }
            public string History { get; set; }
        }

  

        [WebMethod]
        public static string FillTestMainDepartment()
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var dpt = (from d in db.DataValues
                       join v in db.ValueSets
                       on d.ValueSet_ID equals v.ValueSet_ID
                       where v.ValueSet_Name == "Main Test Departments"
                       select new
                       {
                           d.DataValue_Name,
                           d.DataValue_Description
                       }).ToList();

            return (new JavaScriptSerializer().Serialize(dpt));
        }

        private static string GetOrthancBaseUrl()
        {
            using (var db = new DataBaseDataContext())
            {
                var baseUrl = db.ExecuteQuery<string>("SELECT Segment1 FROM sys_Parms WHERE Name = 'PACS_URL'").FirstOrDefault();
                baseUrl = (baseUrl ?? string.Empty).Trim().TrimEnd('/');

                return baseUrl;
            }
        }

        [WebMethod]
        public static object CheckOrthancStudiesBatch(List<string> accessionNumbers)
        {
            var studies = new Dictionary<string, OrthancStudyInfo>(StringComparer.OrdinalIgnoreCase);
            var baseUrl = GetOrthancBaseUrl();

            if (string.IsNullOrWhiteSpace(baseUrl) || accessionNumbers == null || accessionNumbers.Count == 0)
            {
                return new { BaseUrl = baseUrl, Studies = studies };
            }

            using (var client = new HttpClient())
            {
                client.Timeout = TimeSpan.FromSeconds(15);

                foreach (var accessionNumber in accessionNumbers.Where(x => !string.IsNullOrWhiteSpace(x)).Distinct())
                {
                    var result = new OrthancStudyInfo { Exists = false };

                    try
                    {
                        var payload = new
                        {
                            Level = "Study",
                            Query = new { AccessionNumber = accessionNumber },
                            Expand = true
                        };

                        var content = new StringContent(JsonConvert.SerializeObject(payload), Encoding.UTF8, "application/json");
                        var response = client.PostAsync(baseUrl + "/tools/find", content).GetAwaiter().GetResult();

                        if (response.IsSuccessStatusCode)
                        {
                            var responseBody = response.Content.ReadAsStringAsync().GetAwaiter().GetResult();
                            var studiesArray = string.IsNullOrWhiteSpace(responseBody) ? null : JArray.Parse(responseBody);
                            var first = studiesArray?.FirstOrDefault() as JObject;

                            var orthancStudyId = first?["ID"]?.ToString();
                            var mainDicomTags = first?["MainDicomTags"] as JObject;
                            var studyInstanceUid = mainDicomTags?["StudyInstanceUID"]?.ToString();
                            var studyDate = mainDicomTags?["StudyDate"]?.ToString();
                            var studyTime = mainDicomTags?["StudyTime"]?.ToString();

                            if (!string.IsNullOrWhiteSpace(orthancStudyId))
                            {
                                result.Exists = true;
                                result.OrthancStudyId = orthancStudyId;
                                result.StudyInstanceUID = studyInstanceUid;
                                result.StudyDate = studyDate;
                                result.StudyTime = studyTime;
                            }
                        }
                    }
                    catch
                    {
                    }

                    studies[accessionNumber] = result;
                }
            }

            return new { BaseUrl = baseUrl, Studies = studies };
        }

        [WebMethod]
        public static object GetStudyDetailsAndSeries(string orthancStudyId)
        {
            if (string.IsNullOrWhiteSpace(orthancStudyId))
            {
                return new { Success = false, Message = "Invalid Orthanc study id.", Study = (object)null, Series = new object[0] };
            }

            var baseUrl = GetOrthancBaseUrl();
            if (string.IsNullOrWhiteSpace(baseUrl))
            {
                return new { Success = false, Message = "PACS URL is not configured.", Study = (object)null, Series = new object[0] };
            }

            try
            {
                using (var client = new HttpClient())
                {
                    client.Timeout = TimeSpan.FromSeconds(20);

                    var studyResponse = client.GetAsync(baseUrl + "/studies/" + orthancStudyId).GetAwaiter().GetResult();
                    var seriesResponse = client.GetAsync(baseUrl + "/studies/" + orthancStudyId + "/series").GetAwaiter().GetResult();

                    if (!studyResponse.IsSuccessStatusCode)
                    {
                        return new { Success = false, Message = "Unable to load study details.", Study = (object)null, Series = new object[0] };
                    }

                    var studyJson = studyResponse.Content.ReadAsStringAsync().GetAwaiter().GetResult();
                    var study = JObject.Parse(studyJson);
                    var studyTags = study["MainDicomTags"] as JObject ?? new JObject();

                    var seriesItems = new List<object>();
                    if (seriesResponse.IsSuccessStatusCode)
                    {
                        var seriesJson = seriesResponse.Content.ReadAsStringAsync().GetAwaiter().GetResult();
                        var seriesArray = string.IsNullOrWhiteSpace(seriesJson) ? new JArray() : JArray.Parse(seriesJson);

                        foreach (var item in seriesArray.OfType<JObject>())
                        {
                            var seriesTags = item["MainDicomTags"] as JObject ?? new JObject();
                            var instancesArray = item["Instances"] as JArray;

                            seriesItems.Add(new
                            {
                                OrthancSeriesId = item["ID"]?.ToString(),
                                SeriesNumber = seriesTags["SeriesNumber"]?.ToString(),
                                SeriesDescription = seriesTags["SeriesDescription"]?.ToString(),
                                InstancesCount = instancesArray != null ? instancesArray.Count : 0,
                                BodyPartExamined = seriesTags["BodyPartExamined"]?.ToString()
                            });
                        }
                    }

                    return new
                    {
                        Success = true,
                        BaseUrl = baseUrl,
                        Study = new
                        {
                            OrthancStudyId = orthancStudyId,
                            AccessionNumber = studyTags["AccessionNumber"]?.ToString(),
                            StudyDate = studyTags["StudyDate"]?.ToString(),
                            StudyTime = studyTags["StudyTime"]?.ToString(),
                            RequestingPhysicianName = studyTags["RequestingPhysician"]?.ToString() ?? studyTags["ReferringPhysicianName"]?.ToString(),
                            StudyDescription = studyTags["StudyDescription"]?.ToString()
                        },
                        Series = seriesItems
                    };
                }
            }
            catch
            {
                return new { Success = false, Message = "Unable to load study details.", Study = (object)null, Series = new object[0] };
            }
        }

        [WebMethod]
        public static string CheckOrthancStudy(string accessionNumber)
        {
            if (string.IsNullOrWhiteSpace(accessionNumber)) return "[]";

            try
            {
                var payload = new
                {
                    Level = "Study",
                    Query = new { AccessionNumber = accessionNumber },
                    Expand = true
                };

                string payloadJson = JsonConvert.SerializeObject(payload);

                using (var client = new HttpClient())
                {
                    // Set a timeout so it doesn't hang forever if the tunnel is down
                    client.Timeout = TimeSpan.FromSeconds(10);

                    var content = new StringContent(payloadJson, Encoding.UTF8, "application/json");

                    // We use .Result and .GetAwaiter().GetResult() to prevent the Deadlock
                    var baseUrl = GetOrthancBaseUrl();
                    if (string.IsNullOrWhiteSpace(baseUrl))
                    {
                        return "[]";
                    }

                    var response = client.PostAsync(baseUrl + "/tools/find", content).GetAwaiter().GetResult();

                    if (response.IsSuccessStatusCode)
                    {
                        return response.Content.ReadAsStringAsync().GetAwaiter().GetResult();
                    }
                }
            }
            catch (Exception ex)
            {
                // For debugging, you can check ex.Message here
                return "[]";
            }

            return "[]";
        }

        [WebMethod]
        public static object LaunchRadiAnt(string studyInstanceUID)
        {
            if (string.IsNullOrWhiteSpace(studyInstanceUID))
                return new { Success = false, Message = "Empty StudyInstanceUID." };

            if (!System.Text.RegularExpressions.Regex.IsMatch(studyInstanceUID, @"^[0-9.]+$"))
                return new { Success = false, Message = "Invalid StudyInstanceUID format." };

            try
            {
                var url = "radiant://?n=paet&v=VISIONPLUS&n=pstv&v=0020000D&v=\"" + studyInstanceUID + "\"";
                System.Diagnostics.Process.Start(url);
                return new { Success = true };
            }
            catch (Exception ex)
            {
                return new { Success = false, Message = ex.Message };
            }
        }
    }
}