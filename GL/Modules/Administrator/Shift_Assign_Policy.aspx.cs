using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.Administrator
{
    public partial class Shift_Assign_Policy : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        public class PolicyDropdownDTO
        {
            public int Policy_ID { get; set; }
            public string Policy_Name { get; set; }
        }

        [WebMethod]
        public static List<PolicyDropdownDTO> GetAllPolicies()
        {
            try
            {
                DataBaseDataContext db = new DataBaseDataContext();

                var policies = (from p in db.Policies
                                select new PolicyDropdownDTO
                                {
                                    Policy_ID = p.Policy_ID,
                                    Policy_Name = p.Policy_Name
                                }).ToList();

                return policies;
            }
            catch
            {
                return new List<PolicyDropdownDTO>();
            }
        }

        [WebMethod]
        public static string GetPolicies(string policy_id)
        {
            try
            {
                if (string.IsNullOrEmpty(policy_id))
                {
                    return new JavaScriptSerializer().Serialize(new List<object>());
                }

                using (var db = new DataBaseDataContext())
                {
                    var policies = db.Policy_Details
                                     .Where(p => p.Policy_ID.ToString() == policy_id)
                                     .ToList()
                                     .Select(p => new
                                     {
                                         Policy_Detail_ID = p.Policy_Detail_ID,
                                         Policy_ID = p.Policy_ID,
                                         Policy_Name = p.Policy_Name,
                                         Fees = p.Fees,
                                         Hospital_Share = p.Hospital_Share ?? 0,
                                         Doctor_Share = p.Doctor_Share ?? 0,
                                         Expiry_Date = p.Expiry_Date.HasValue ? p.Expiry_Date.Value.ToString("dd MMM yyyy") : "",
                                         IsTime = p.IsTime ?? false,
                                         Start_Time = p.Start_Time.HasValue ? p.Start_Time.Value.ToString(@"hh\:mm") : "",
                                         End_Time = p.End_Time.HasValue ? p.End_Time.Value.ToString(@"hh\:mm") : "",
                                         Next_Day = p.Next_Day ?? false
                                     })
                                     .ToList();

                    return new JavaScriptSerializer().Serialize(policies);
                }
            }
            catch (Exception)
            {
                return new JavaScriptSerializer().Serialize(new List<object>());
            }
        }




        [WebMethod]
        public static string SaveMultiplePolicies(List<PolicyDetailDTO> policies)
        {
            try
            {
                DataBaseDataContext db = new DataBaseDataContext();

                foreach (var item in policies)
                {
                    if (item.Policy_Detail_ID > 0)
                    {
                        var existingPolicy = db.Policy_Details.FirstOrDefault(p => p.Policy_Detail_ID == item.Policy_Detail_ID);

                        if (existingPolicy != null)
                        {
                            existingPolicy.Policy_ID = item.Policy_ID;
                            existingPolicy.Policy_Name = item.Policy_Name;
                            existingPolicy.Fees = item.Fees;
                            existingPolicy.Hospital_Share = item.Hospital_Share;
                            existingPolicy.Doctor_Share = item.Doctor_Share;
                            existingPolicy.Expiry_Date = item.Expiry_Date;
                            existingPolicy.IsTime = item.IsTime;
                            existingPolicy.Start_Time = string.IsNullOrEmpty(item.Start_Time) ? (TimeSpan?)null : TimeSpan.Parse(item.Start_Time);
                            existingPolicy.End_Time = string.IsNullOrEmpty(item.End_Time) ? (TimeSpan?)null : TimeSpan.Parse(item.End_Time);
                            existingPolicy.Next_Day = item.Next_Day;
                            existingPolicy.Updated_By = AppConfig.UserID;
                            existingPolicy.Updated_At = DateTime.Now;
                        }
                    }
                    else
                    {
                        Policy_Detail newPolicy = new Policy_Detail
                        {
                            Policy_ID = item.Policy_ID,
                            Policy_Name = item.Policy_Name,
                            Fees = item.Fees,
                            Hospital_Share = item.Hospital_Share,
                            Doctor_Share = item.Doctor_Share,
                            Expiry_Date = item.Expiry_Date,
                            IsTime = item.IsTime,
                            Start_Time = string.IsNullOrEmpty(item.Start_Time) ? (TimeSpan?)null : TimeSpan.Parse(item.Start_Time),
                            End_Time = string.IsNullOrEmpty(item.End_Time) ? (TimeSpan?)null : TimeSpan.Parse(item.End_Time),
                            Next_Day = item.Next_Day,
                            Is_Cancel = false,
                            Created_By = AppConfig.UserID,
                            Created_At = DateTime.Now
                        };

                        db.Policy_Details.InsertOnSubmit(newPolicy);
                    }
                }

                db.SubmitChanges();
                return "All policies saved successfully!";
            }
            catch (Exception ex)
            {
                return "Error: " + ex.Message;
            }
        }


        public class PolicyDetailDTO
        {
            public int? Policy_Detail_ID { get; set; }
            public int? Policy_ID { get; set; }
            public string Policy_Name { get; set; }
            public decimal? Fees { get; set; }
            public int? Hospital_Share { get; set; }           
            public int? Doctor_Share { get; set; }
            public DateTime? Expiry_Date { get; set; }
            public bool IsTime { get; set; }
            public string Start_Time { get; set; }
            public string End_Time { get; set; }
            public bool Next_Day { get; set; }
            public bool Is_Cancel { get; set; }
        }

    }
}