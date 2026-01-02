using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.Services;
using System.Web.Script.Serialization;
using System.Data.Entity.Core.Mapping;


namespace PMS
{
    public partial class BillApproval : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        [WebMethod]
        public static string ApproveBill(string billid)
        {
            try
            {
                var user_id = AppConfig.UserID;
                int billId = Convert.ToInt32(billid);

                using (DataBaseDataContext db = new DataBaseDataContext())
                {
                    db.ExecuteCommand(
                        "EXEC dbo.SpApproveBillingProcess {0}, {1}",
                        billId,
                        user_id
                    );
                }

                return new JavaScriptSerializer().Serialize(new
                {
                    Success = true,
                    Message = "Bill approved successfully"
                });
            }
            catch (Exception ex)
            {
                return new JavaScriptSerializer().Serialize(new
                {
                    Success = false,
                    Message = ex.Message
                });
            }
        }

        [WebMethod]
        public static string LoadBillsToApprove(string search)
        {
            if (search.Trim() == "" || search.Trim() == null)
            {


                DataBaseDataContext db = new DataBaseDataContext();
                var Details = db.spLoadBillingInfo(search);
                return (new JavaScriptSerializer()).Serialize(Details);

            }
            else
            {
                DataBaseDataContext db = new DataBaseDataContext();
                var Details = db.spLoadBillingInfo(search).ToList().Where(x => x.mr_no_sequence.ToLower().Contains(search.ToLower()) || x.Status.ToLower().Contains(search.ToLower()) || x.Full_Name.ToLower().Contains(search.ToLower()));
                return (new JavaScriptSerializer()).Serialize(Details);
            }



        }
        [WebMethod]
        public static string PatientType()
        {
            string data = string.Empty;

            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var result = (from dv in db.DataValues
                              join ds in db.ValueSets
                              on dv.ValueSet_ID equals ds.ValueSet_ID
                              where ds.ValueSet_Name == "Patient Type"
                              select new
                              {
                                  dv.DataValue_Name,
                                  dv.DataValue_Description
                              }).ToList();
                data = new JavaScriptSerializer().Serialize(result);
            }
            return data;
        }
        public class check
        {

            public bool? chdeck { get; set; }

        }
    }
}