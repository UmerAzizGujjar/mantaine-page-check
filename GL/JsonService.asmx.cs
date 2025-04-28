using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Script.Services;
using System.Web.Services;

namespace PMS
{
    /// <summary>
    /// Summary description for JsonService
    /// </summary>
    [WebService(Namespace = "http://tempuri.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [System.ComponentModel.ToolboxItem(false)]
    // To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
    // [System.Web.Script.Services.ScriptService]
    public class JsonService : System.Web.Services.WebService
    {
        DataBaseDataContext db = new DataBaseDataContext();
        JavaScriptSerializer js = new JavaScriptSerializer();

        [WebMethod]
        public void GetEmployees()
        {
                List<HR_Employee> lst= db.HR_Employees.ToList();
                Context.Response.Clear();
                Context.Response.ContentType = "application/json";
                Context.Response.Write(js.Serialize(lst));
        }

        [WebMethod]
        public void GetInPatients()
        {
            List<In_Patient> lst = db.In_Patients.ToList();
            Context.Response.Clear();
            Context.Response.ContentType = "application/json";
            Context.Response.Write(js.Serialize(lst));
        }

        [WebMethod]
        public void GetPatients()
        {
            List<Patient> lst = db.ExecuteQuery<Patient>("SELECT Patient_ID,Patient_No,First_Name,Full_Name,Last_Name,Birth_Date,dbo.GetDataValueName('Gender',Gender)as Gender,dbo.GetDataValueName('City',City)as City" +
                                ",dbo.GetDataValueName('Blood Group',Blood_Group) as Blood_Group" +
                                ",dbo.GetDataValueName('Marital Status',Marital_Status) as Marital_Status,dbo.GetDataValueName('Religion',Religion) as Religion " +
                                " FROM Patients", "").ToList();
            Context.Response.Clear();
            Context.Response.ContentType = "application/json";
            Context.Response.Write(js.Serialize(lst));

            var Query = (from v in db.ValueSets
                         join d in db.DataValues
                         on v.ValueSet_ID equals d.ValueSet_ID
                         where d.DataValue_Name == "01" && v.ValueSet_Name == "Blood Group"
                         select new
                         {
                             d.DataValue_Description
                         }).ToList();
                      
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public void DeleteInPatient(string testt)
        {
            //db.In_Patients.DeleteOnSubmit(inPatient);
            //db.SubmitChanges();
            Context.Response.Write(js.Serialize(new { Message = "Deleted Successfully." }));
        }
    }
}
