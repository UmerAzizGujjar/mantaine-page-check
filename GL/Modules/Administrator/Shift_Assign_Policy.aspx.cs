using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
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
        public static string SaveMultiplePolicies(List<PolicyDetailDTO> policies)
        {
            try
            {
                DataBaseDataContext db = new DataBaseDataContext();

                foreach (var item in policies)
                {
                    Policy_Detail policy = new Policy_Detail
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
                        Created_By = AppConfig.UserID,
                        Created_At = DateTime.Now
                    };

                    db.Policy_Details.InsertOnSubmit(policy);
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
        }

    }
}