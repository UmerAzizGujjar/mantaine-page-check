using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class BloodBank : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            
        }

        private class ddlListItems
        {
            public string DataValueName;
            public string DataValueDescription;
            public string Type;
        }


        [WebMethod]
        public static string updatebloodbottles(string bloodid)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Details = db.sp_updatebloodbottles(Convert.ToInt32(bloodid));
            return (new JavaScriptSerializer()).Serialize(Details);
        }





        [WebMethod]
        public static string Getnewbloodid()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var bloodno = DBClass.GetNewNumber("Blood_ID", "Blood_Bank", "");
            return bloodno.ToString();
        }

        [WebMethod]
        public static string loadheaderdata(int ID)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Header = (from m in db.Blood_Banks
                          where m.Blood_ID == ID
                          select new
                          {
                              m.Blood_ID,
                              m.Patient_ID,
                              m.Receiving_Date,
                              m.Blood_Group,
                              m.Blood_Charges,
                              m.No_Of_Bags,
                              m.Expiry_Date,
                              m.Walk_In_Customer,
                              m.RH_Type,
                              m.Received_Bag,
                              m.Bag_No,
                              m.Available_Blood,
                              m.Component,
                              m.Received_By,
                              m.OutDoor_Person_Name,
                              m.Donation
                              
                          }).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(Header);
        }





        [WebMethod]
        public static string savedata(string btnSave, string AllItemDetail)
        {
            string bloodid = "";
            Blood_Bank bb = new Blood_Bank();
            Blood_Bank lstItem;
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            JavaScriptSerializer oJS = new JavaScriptSerializer();
            var record = oJS.Deserialize<MasterInoviceList>(AllItemDetail);
           
            lstItem = (from t in db.Blood_Banks
                           where t.Blood_ID == int.Parse(record.txtBlood_ID)
                           select t).FirstOrDefault();
            if (lstItem == null)
            {
                lstItem = new Blood_Bank();
            }
            if (btnSave == "Update")
            {


                if (record.txtPatient_ID != "")
                {

                    lstItem.Patient_ID = Convert.ToInt32(record.txtPatient_ID);
                }
                if (record.txtReceiving_Date == "") { }
                else
                {
                    lstItem.Receiving_Date = Convert.ToDateTime(record.txtReceiving_Date);
                }
                lstItem.Blood_Group = record.ddlBlood_Group;
                lstItem.Received_By = record.txtBlood_Charges;
                lstItem.No_Of_Bags = Convert.ToInt32(record.txtNo_Of_Bags);
                lstItem.OutDoor_Person_Name = record.name;
                if (record.isBagFree == true)
                {
                    lstItem.Empty_Bag_Receiving_Date = DateTime.Now;
                    lstItem.Empty_Bag_Receiving_By = AppConfig.UserID;
                }
                else
                 {
                    lstItem.Component = record.components;

                }
                if (record.txtExpiry_Date == "")
                {

                }
                else
                {
                    lstItem.Expiry_Date = Convert.ToDateTime(record.txtExpiry_Date);
                }
                lstItem.Received_Bag = Convert.ToBoolean(record.bagrecv_chck);
                lstItem.Walk_In_Customer = Convert.ToBoolean(record.chkCustomer);
                lstItem.Bag_No = record.dllbagnum;
                lstItem.RH_Type = record.ddlrhtype;
                lstItem.Available_Blood = Convert.ToInt32(record.txtAvailableBlood);
               
                lstItem.Company_ID = AppConfig.Company_ID;
         
                lstItem.Updated_By = AppConfig.UserID;
                lstItem.Updated_Time = DateTime.Now;
                lstItem.Book_ID = AppConfig.Book_ID;
                lstItem.Donation = record.donation;
                db.SubmitChanges();
                bloodid = lstItem.Blood_ID.ToString();
            }
            else
            {
                bb.Patient_ID = Convert.ToInt32(record.txtPatient_ID);
                if (record.txtReceiving_Date == "") { }
                else
                {
                    bb.Receiving_Date = Convert.ToDateTime(record.txtReceiving_Date);
                }
                bb.Blood_Group = record.ddlBlood_Group;
                bb.Received_By = record.txtBlood_Charges;
                bb.No_Of_Bags = Convert.ToInt32(record.txtNo_Of_Bags);
                bb.OutDoor_Person_Name = record.name;
                if (record.isBagFree == true)
                {
                    bb.Empty_Bag_Receiving_Date = DateTime.Now;
                    lstItem.Empty_Bag_Receiving_By = AppConfig.UserID;
                }
                if (record.txtExpiry_Date == "")
                {

                }
                else
                {
                    bb.Expiry_Date = Convert.ToDateTime(record.txtExpiry_Date);
                }
                bb.Received_Bag = Convert.ToBoolean(record.bagrecv_chck);
                bb.Walk_In_Customer = Convert.ToBoolean(record.chkCustomer);
                bb.Available_Blood = Convert.ToInt32(record.txtAvailableBlood);
                bb.Bag_No = record.dllbagnum;
                bb.RH_Type = record.ddlrhtype;
                bb.Component = record.components;
                bb.Company_ID = AppConfig.Company_ID;
                bb.Created_By = AppConfig.UserID;
                bb.Created_Time = DateTime.Now;
          
                bb.Book_ID = AppConfig.Book_ID;
                bb.Donation = record.donation;
                db.Blood_Banks.InsertOnSubmit(bb);
                db.SubmitChanges();
                bloodid = bb.Blood_ID.ToString();
            }

            return bloodid;
        }



        [WebMethod]
        public static string fillabotype()

        {
            DataBaseDataContext db = new DataBaseDataContext();
            List<ddlListItems> listItems = new List<ddlListItems>();
            string data = string.Empty;
            listItems = (from p in db.DataValues
                         join v in db.ValueSets on p.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Description == "ABO group"
                         select new ddlListItems
                         {
                             DataValueName = p.DataValue_Name,
                             DataValueDescription = p.DataValue_Description,
                           
                         }).ToList();

            return (new JavaScriptSerializer()).Serialize(listItems);
        }

        [WebMethod]
        public static string fillrhtype()

        {
            DataBaseDataContext db = new DataBaseDataContext();
            List<ddlListItems> listItems = new List<ddlListItems>();
            string data = string.Empty;
            listItems = (from p in db.DataValues
                         join v in db.ValueSets on p.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Description == "RH Type"
                         select new ddlListItems
                         {
                             DataValueName = p.DataValue_Name,
                             DataValueDescription = p.DataValue_Description,
                         
                         }).ToList();

            return (new JavaScriptSerializer()).Serialize(listItems);
        }

        [WebMethod]
        public static string fillDoantion()

        {
            DataBaseDataContext db = new DataBaseDataContext();
            List<ddlListItems> listItems = new List<ddlListItems>();
            string data = string.Empty;
            listItems = (from p in db.DataValues
                         join v in db.ValueSets on p.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Description == "Donation"
                         select new ddlListItems
                         {
                             DataValueName = p.DataValue_Name,
                             DataValueDescription = p.DataValue_Description,
                           
                         }).ToList();

            return (new JavaScriptSerializer()).Serialize(listItems);
        }


      

        [WebMethod]
        public static string getbagnumbygroup(string abotype, string rhtype)
        {

            DataBaseDataContext db = new DataBaseDataContext();
           
            var Header = (from m in db.Donors join d in db.Blood_Divisions on m.Donor_Id equals d.Donor_Id
                          where m.ABO == abotype && m.Rh_Type == rhtype &&(m.isWholeBagReceived==null || m.isWholeBagReceived==false) && d.isExpired==false
                          select new
                          {
       SumQty=DBClass.getField("select sum(Qty) from Blood_Division_Type where Blood_Division_Id='"+ d.Blood_Division_Id+ "'"),
       TotalRecords= DBClass.getField("select count(Blood_Division_Type_Id) from Blood_Division_Type where Blood_Division_Id='" + d.Blood_Division_Id + "'"),
       IsExpiredCount = DBClass.getField("select count(isExpired) from Blood_Division_Type where Blood_Division_Id='" + d.Blood_Division_Id + "' and isnull(isExpired,0)=1"),
                              d.Expiry_Date,
                              m.D_bagno,
                          }).ToList();
            return (new JavaScriptSerializer()).Serialize(Header);
        }

        [WebMethod]
        public static string getbagnumbygroupEdit(string abotype, string rhtype)
        {

            DataBaseDataContext db = new DataBaseDataContext();

            var Header = (from m in db.Donors
                          join d in db.Blood_Divisions on m.Donor_Id equals d.Donor_Id
                          where m.ABO == abotype && m.Rh_Type == rhtype && d.isExpired == false
                          select new
                          {
                              SumQty = DBClass.getField("select sum(Qty) from Blood_Division_Type where Blood_Division_Id='" + d.Blood_Division_Id + "'"),
                              TotalRecords = DBClass.getField("select count(Blood_Division_Type_Id) from Blood_Division_Type where Blood_Division_Id='" + d.Blood_Division_Id + "'"),
                              IsExpiredCount = DBClass.getField("select count(isExpired) from Blood_Division_Type where Blood_Division_Id='" + d.Blood_Division_Id + "' and isnull(isExpired,0)=1"),
                              d.Expiry_Date,
                              m.D_bagno,
                          }).ToList();
            return (new JavaScriptSerializer()).Serialize(Header);
        }


       

        [WebMethod]
        public static string getsumofblood(string abotype, string rhtype)
        {

            DataBaseDataContext db = new DataBaseDataContext();
            var Header = (from m in db.Donors
                          where m.ABO == abotype && m.Rh_Type == rhtype && m.IsIssue == false
                          select new
                          {

                              m.Bag_Qty,
                          }).Sum(x=>x.Bag_Qty);
            return (new JavaScriptSerializer()).Serialize(Header);
        }

        [WebMethod]
        public static string getexpiryofblood(string bagnum)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Header = (from m in db.Donors join e in db.Blood_Divisions on m.Donor_Id equals e.Donor_Id
                          where m.D_bagno == bagnum && (m.IsBagFree==null || m.IsBagFree==false)
                          select new
                          {
                              e.Expiry_Date,
                              m.D_Date,

                          }).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(Header);
        }
        [WebMethod]
        public static string getExpiryDate(string id,string bagnum)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Header = (from m in db.Donors
                          join e in db.Blood_Divisions on m.Donor_Id equals e.Donor_Id
                          join type in db.Blood_Division_Types on e.Blood_Division_Id equals type.Blood_Division_Id
                          where m.D_bagno == bagnum && type.Blood_Platelets_Id==id
                          select new
                          {
                           type.Expiry_Date,

                          }).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(Header);
        }
        [WebMethod]
        public static string getComponents(string bagnum)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Header = (from m in db.Donors join d in db.Blood_Divisions
                                              on m.Donor_Id equals d.Donor_Id
                                              join bdt in db.Blood_Division_Types on d.Blood_Division_Id equals bdt.Blood_Division_Id
                          where m.D_bagno == bagnum
                          select new
                          {
                              d.Whole_Blood,
                              d.Blood_Division_Id,
                            Components=(from data in db.Blood_Division_Types where data.Blood_Division_Id.Equals(d.Blood_Division_Id) && data.isExpired==false
                                        select new{
                                        data.Blood_Platelets_Id,
                                        data.Blood_Platelets_Name,
                                        data.Qty,
                                       
                                        
                                        }).ToList(),

                          }).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(Header);
        }




        public class MasterInoviceList
        {
            public string bagrecv_chck { get; set; }
            public string chkCustomer { get; set; }
            public string txtNo_Of_Bags { get; set; }
            public string txtReceiving_Date { get; set; }
            public string ddlrhtype { get; set; }
            public string dllbagnum { get; set; }
            public string txtExpiry_Date { get; set; }
            public string txtAvailableBlood { get; set; }
            public string ddlBlood_Group { get; set; }
            public string txtBlood_Charges { get; set; }
            public string txtBlood_ID { get; set; }
            public string txtPatient_ID { get; set; }
            public string components { get; set; }
            public string name { get; set; }

            public string donation { get; set; }

            public bool isBagFree { get; set; }

        }



    }
}