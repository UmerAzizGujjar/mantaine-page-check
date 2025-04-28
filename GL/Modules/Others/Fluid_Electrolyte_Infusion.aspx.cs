using AjaxControlToolkit;
using System;
using System.Collections.Generic;
using System.Data;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
namespace PMS
{
    public partial class Fluid_Electrolyte_Infusion : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }


        [WebMethod]
        public static string ViewList()
        {
            string result = string.Empty;
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var query = (from a in db.Infusion_Orders



                             select new

                             {

                                 a.Infusion_Order_ID,
                                 a.Infusion_Fluid,
                                 Infusion_Fluidname = db.INV_Items.Where(x=>x.Item_ID == Convert.ToInt32(a.Infusion_Fluid)).Select(x=>x.Description).FirstOrDefault(),

                                 AdditiveName= db.INV_Items.Where(x => x.Item_ID == Convert.ToInt32(a.Additive)).Select(x => x.Description).FirstOrDefault(),
                                 a.Additive,
                                 a.Infusion_Rate,
                                 Infusion_RateName = db.GetDataValueName("Infusion Rate", a.Infusion_Rate),
                                a.Infusion_Volume,
                                 Infusion_VolumeName = db.GetDataValueName("Infusion Volume", a.Infusion_Volume),
                                 a.Additive_Dose,
                                 Additive_DoseName = db.GetDataValueName("Additive Dose", a.Additive_Dose),
                                 a.Route,
                                 RouteName= db.GetDataValueName("Routes",a.Route),
                                 a.Create_Time,
                               

                             }).ToList();
                result = (new JavaScriptSerializer()).Serialize(query).ToString();
            }
            return result;
        }

        //[WebMethod]

        //public static string LoadData(int Order_ID)
        //{
        //    DataBaseDataContext db = new DataBaseDataContext();
        //    var Details = db.sp_LoadInfusionData(Order_ID).FirstOrDefault();
        //    return (new JavaScriptSerializer()).Serialize(Details);
        //}



        [WebMethod]
        public static string InfusionVOL()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            List<ddlInsVol> listInfVOL = new List<ddlInsVol>();
            string data = string.Empty;
            listInfVOL = (from p in db.DataValues
                         join v in db.ValueSets on p.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Description == "Infusion Volume"
                         select new ddlInsVol
                         {
                             DataValueName = p.DataValue_Name,
                             DataValueDescription = p.DataValue_Description,
                         }).ToList();

            return (new JavaScriptSerializer()).Serialize(listInfVOL);
        }


        [WebMethod]
        public static string AdditiveDose()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            List<ddlAdd> listadd = new List<ddlAdd>();
            string data = string.Empty;
            listadd = (from p in db.DataValues
                         join v in db.ValueSets on p.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Description == "Additive Dose"
                         select new ddlAdd
                         {
                             DataValueName = p.DataValue_Name,
                             DataValueDescription = p.DataValue_Description,
                         }).ToList();

            return (new JavaScriptSerializer()).Serialize(listadd);
        }


        [WebMethod]
        public static string InfusionRate()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            List<ddlInsRate> listinfRate = new List<ddlInsRate>();
            string data = string.Empty;
            listinfRate = (from p in db.DataValues
                         join v in db.ValueSets on p.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Description == "Infusion Rate"
                         select new ddlInsRate
                         {
                             DataValueName = p.DataValue_Name,
                             DataValueDescription = p.DataValue_Description,
                         }).ToList();

            return (new JavaScriptSerializer()).Serialize(listinfRate);
        }


        [WebMethod]
        public static string Routes()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            List<ddlRoute> listRoute = new List<ddlRoute>();
            string data = string.Empty;
            listRoute = (from p in db.DataValues
                         join v in db.ValueSets on p.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Description == "Routes"
                         select new ddlRoute
                         {
                             DataValueName = p.DataValue_Name,
                             DataValueDescription = p.DataValue_Description,
                         }).ToList();

            return (new JavaScriptSerializer()).Serialize(listRoute);


            }


        [WebMethod]
        public static string InfussionPharmacy()
        {

            DataBaseDataContext dbs = new DataBaseDataContext();
            var infspharm = (from data in dbs.INV_Items
                     where (data.Pharmacy_Item == true && data.Infusion_Fluid == true)
                     select new {
                     data.Item_ID,
                     data.Description,
                     }).ToList();
              return (new JavaScriptSerializer()).Serialize(infspharm);

        }

        [WebMethod]
        public static string additive()
        {

            DataBaseDataContext dbs = new DataBaseDataContext();
            var add_ddl = (from data in dbs.INV_Items
                             where (data.Pharmacy_Item == true && data.Additive_Dose == true)
                             select new
                             {
                                 data.Item_ID,
                                 data.Description,
                             }).ToList();
            return (new JavaScriptSerializer()).Serialize(add_ddl);

        }

        [WebMethod]
        public static int SaveInfs(string btnSave, string AllItemDetail)
        {
            Infusion_Order obj = new Infusion_Order();
            string InfsID = "";
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            JavaScriptSerializer oJS = new JavaScriptSerializer();
            var record = oJS.Deserialize<MasterInfusion_Order>(AllItemDetail);


            if (btnSave == "Update")

                //if (editmode_ID != "")
            {

                var data = (from t in db.Infusion_Orders
                               where t.Infusion_Order_ID == int.Parse(record.Infusion_Order_ID)
                               select t).FirstOrDefault();



                data.Infusion_Fluid = record.Infusion_Fluid;
                data.Additive = record.Additive;
                data.Infusion_Volume = record.Infusion_Volume;
                data.Additive_Dose = record.Additive_Dose;
                data.Infusion_Rate = record.Infusion_Rate;
                data.Route = record.Route;
                data.Updated_Time = DateTime.Now;
                data.Updated_By = AppConfig.UserID;
                db.SubmitChanges();
                InfsID = data.Infusion_Order_ID.ToString();
            }
            else
            {


                obj.Infusion_Fluid = record.Infusion_Fluid;
                obj.Additive = record.Additive;
                obj.Infusion_Volume = record.Infusion_Volume;
                obj.Additive_Dose = record.Additive_Dose;
                obj.Infusion_Rate = record.Infusion_Rate;
                obj.Route = record.Route;
                
                obj.Create_Time = DateTime.Now;
                obj.Create_By = AppConfig.UserID;

                InfsID = obj.Infusion_Order_ID.ToString();
                db.Infusion_Orders.InsertOnSubmit(obj);
                db.SubmitChanges();
               
            }

            return int.Parse(InfsID);
        }

             public class MasterInfusion_Order
        {
            public string Infusion_Order_ID { get; set; }
            public string Infusion_Fluid { get; set; }
            public string Additive { get; set; }
            public string Infusion_Volume { get; set; }
            public string Additive_Dose { get; set; }
            public string Infusion_Rate { get; set; }
            public string Route { get; set; }
            public string Created_time { get; set; }
            public string Created_by { get; set; }
            public string Updated_time { get; set; }
            public string Updated_by { get; set; }
        }





        private class ddlInsVol
        {
            public string DataValueName;
            public string DataValueDescription;
            
        }


        private class ddlAdd
        {
            public string DataValueName;
            public string DataValueDescription;
           
        }

        private class ddlInsRate
        {
            public string DataValueName;
            public string DataValueDescription;
           
        }


        private class ddlRoute
        {
            public string DataValueName;
            public string DataValueDescription;
            
        }

    }
}