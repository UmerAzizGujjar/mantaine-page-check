using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
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
                                       Department_ID = dv.DataValue_ID,
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
            public int Department_ID { get; set; }
            public string Department_Name { get; set; }
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
                        var existing = db.Department_Assignments
                                          .FirstOrDefault(x => x.Dep_ID == policy.Dep_ID);

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
                            Department_Assignment newRecord = new Department_Assignment
                            {
                                Department_ID = policy.Department_ID,
                                Policy_ID = policy.Policy_ID,
                                Fees = policy.Fees,
                                Hospital_Share = policy.Hospital_Share,
                                Doctor_Share = policy.Doctor_Share,
                                Expiry_Date = policy.Expiry_Date,
                                IsActive = policy.IsActive,
                                Created_At = DateTime.Now,
                                Created_By = AppConfig.UserID
                            };
                            db.Department_Assignments.InsertOnSubmit(newRecord);
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
            public int Department_ID { get; set; }
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