using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class DiscountDefination_List : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        
        
        
        
        [WebMethod]
        public static string Discount_Defination_list()
        {
            string result = string.Empty;
          
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = (from a in db.Discount_Definitions



                             select new

                             {
                                 a.Discount_Definition_Id,
                                 Discount_Category_Id=db.GetDataValueName("Discount Category",a.Discount_Category_Id),
                                 a.Created_Time,
                                 a.Discount_Definition_No
                   

                             }).ToList();
                result = (new JavaScriptSerializer()).Serialize(query).ToString();
            }

            return result;
        }


    }
}