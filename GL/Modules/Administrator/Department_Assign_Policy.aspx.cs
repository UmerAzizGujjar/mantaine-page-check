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
    public partial class Department_Assign_Policy : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static List<PolicyModel> GetAllPolicies()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var policies = db.Policies
                                 .Where(p => p.Active == true && p.Is_Cancel == false)
                                 .Select(p => new PolicyModel
                                 {
                                     Policy_ID = p.Policy_ID,
                                     Policy_Name = p.Policy_Name
                                 })
                                 .ToList();

                return policies;
            }
        }

        [WebMethod]
        public static List<DepartmentModel> GetAllDepartments()
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var departments = (from dv in db.DataValues
                                   join ds in db.ValueSets
                                       on dv.ValueSet_ID equals ds.ValueSet_ID
                                   where ds.ValueSet_Name == "Patient Main Category"
                                   select new DepartmentModel
                                   {
                                       Department_ID = dv.DataValue_Name,
                                       Department_Name = dv.DataValue_Description
                                   }).ToList();

                return departments;
            }
        }
        public class PolicyModel
        {
            public int Policy_ID { get; set; }
            public string Policy_Name { get; set; }
        }

        public class DepartmentModel
        {
            public string Department_ID { get; set; }
            public string Department_Name { get; set; }
        }

        [WebMethod]
        public static string GetDepartmentAssignments(string dep_id)
        {
            try
            {
                if (string.IsNullOrEmpty(dep_id))
                    return new JavaScriptSerializer().Serialize(new List<object>());

                using (var db = new DataBaseDataContext())
                {
                    var assignments = db.Policy_Department_Assignments
                        .Where(d => d.Policy_Assign_Dep_id.ToString() == dep_id)
                        .ToList()
                        .Select(d => new
                        {
                            Dep_ID = d.Policy_Assign_Dep_id,
                            Department_ID = d.Department_ID,
                            Policy_ID = d.Policy_ID,
                            Fees = d.Fees,
                            Hospital_Share = d.Hospital_Share ?? 0,
                            Doctor_Share = d.Doctor_Share ?? 0,
                            Expiry_Date = d.Expiry_Date.HasValue ? d.Expiry_Date.Value.ToString("dd MMM yyyy") : "",
                            IsActive = d.IsActive ?? false
                        })
                        .ToList();

                    return new JavaScriptSerializer().Serialize(assignments);
                }
            }
            catch (Exception)
            {
                return new JavaScriptSerializer().Serialize(new List<object>());
            }
        }





        [WebMethod]
        public static string SaveMultipleDepartmentPolicies(List<DepartmentPolicyModel> departmentPolicies)
        {
            try
            {
                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    foreach (var policy in departmentPolicies)
                    {
                        var existing = db.Policy_Department_Assignments
                                          .FirstOrDefault(x => x.Policy_Assign_Dep_id == policy.Dep_ID);

                        if (existing != null)
                        {
                            existing.Department_ID = policy.Department_ID;
                            existing.Policy_ID = policy.Policy_ID;
                            existing.Fees = policy.Fees;
                            existing.Hospital_Share = policy.Hospital_Share;
                            existing.Doctor_Share = policy.Doctor_Share;
                            existing.Expiry_Date = policy.Expiry_Date;
                            existing.IsActive = policy.IsActive;
                            existing.Updated_At = DateTime.Now;
                            existing.Updated_By = AppConfig.UserID;
                        }
                        else
                        {
                            Policy_Department_Assignment newRecord = new Policy_Department_Assignment
                            {
                                Department_ID = policy.Department_ID,
                                Policy_ID = policy.Policy_ID,
                                Fees = policy.Fees,
                                Hospital_Share = policy.Hospital_Share,
                                Doctor_Share = policy.Doctor_Share,
                                Expiry_Date = policy.Expiry_Date,
                                IsActive = policy.IsActive,
                                Created_At = DateTime.Now,
                                Is_Cancel = false,
                                Created_By = AppConfig.UserID
                            };
                            db.Policy_Department_Assignments.InsertOnSubmit(newRecord);
                        }
                    }

                    db.SubmitChanges();
                }

                return "Records saved/updated successfully.";
            }
            catch (Exception ex)
            {
                return "Error: " + ex.Message;
            }
        }

        public class DepartmentPolicyModel
        {
            public int? Dep_ID { get; set; }
            public string Department_ID { get; set; }
            public int Policy_ID { get; set; }
            public decimal Fees { get; set; }
            public int Hospital_Share { get; set; }
            public int Doctor_Share { get; set; }
            public DateTime? Expiry_Date { get; set; }
            public bool IsActive { get; set; }
            public string Created_By { get; set; }
            public string Updated_By { get; set; }
        }
    }
}