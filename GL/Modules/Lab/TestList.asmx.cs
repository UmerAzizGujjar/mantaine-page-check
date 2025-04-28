//using System;
//using System.Collections.Generic;
//using System.Linq;
//using System.Web;
//using System.Web.Services;

//namespace PMS
//{
//    /// <summary>
//    /// Summary description for TestList
//    /// </summary>
//    [WebService(Namespace = "http://tempuri.org/")]
//    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
//    [System.ComponentModel.ToolboxItem(false)]
//    // To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
//    // [System.Web.Script.Services.ScriptService]
//    public class TestList : System.Web.Services.WebService
//    {

//        [WebMethod]
//        public List<Employee> FetchEmailList(string mail)
//        {
//            var emp = new Employee();
//            var fetchEmail = emp.GetEmployeeList()
//            .Where(m => m.Email.ToLower().StartsWith(mail.ToLower()));
//            return fetchEmail.ToList();
//        } 
//    }
//}
