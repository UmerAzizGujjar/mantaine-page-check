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
    public partial class DonorReceivingForm : System.Web.UI.Page
    {
        protected static int lastId = -1;
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        public class Main
        {
            public string donor_id { get; set; }
            public bool blood_check { get; set; }
            public string Expiry_date { get; set; }
            public string btnValue { get; set; }
            public string id { get; set; }

            public bool isExpiredMain { get; set; }

            public string comment { get; set; }
            public List<Detail> arr { get; set; }
        }

        public class Detail
        {
            public string Type_id { get; set; }
            public string Platelets { get; set; }
            public string Qty { get; set; }
            public string Exp_date { get; set; }

            public bool IsExpired { get; set; }

            public string Comment { get; set; }

            public string OrgnlQty { get; set; }

            public string issueQty { get; set; }

            public string issueDate { get; set; }

            public string ExpiredDate { get; set; }
        }

        [WebMethod]
        public static string Save(string data)
        {
            JavaScriptSerializer js = new JavaScriptSerializer();
            var Details = js.Deserialize<Main>(data);
            DataBaseDataContext db = new DataBaseDataContext();
            Blood_Division BD;
            Blood_Division_Type BDGT;
            if (Details.btnValue == "Save")
            {
                BD = new Blood_Division();
                BD.Company_Id = AppConfig.Company_ID;
                BD.Created_By = AppConfig.UserID;
                BD.Created_Time = DateTime.Now;
                BD.Donor_Id = Convert.ToInt32(Details.donor_id);
                BD.Whole_Blood = Details.blood_check;
                BD.isExpired = Details.isExpiredMain;

                BD.Comment = Details.comment;
                if (Details.Expiry_date == "")
                {

                }
                else
                {
                    BD.Expiry_Date = Convert.ToDateTime(Details.Expiry_date);
                }

                db.Blood_Divisions.InsertOnSubmit(BD);
                db.SubmitChanges();
                lastId = (int)BD.Blood_Division_Id;
            }
            else
            {
                BD = (from query in db.Blood_Divisions.Where(x => x.Blood_Division_Id == Convert.ToInt32(Details.id))
                      select query).FirstOrDefault();
                BD.Updated_By = AppConfig.UserID;
                BD.Updated_Time = DateTime.Now;
                BD.Whole_Blood = Details.blood_check;
                BD.isExpired = Details.isExpiredMain;
               
                BD.Comment = Details.comment;
                if (Details.Expiry_date == "")
                {

                }
                else
                {
                    BD.Expiry_Date = Convert.ToDateTime(Details.Expiry_date);
                }


                db.SubmitChanges();
                lastId = Convert.ToInt32(Details.id);

            }

            if (Details.btnValue == "Update")
            {
                
                List<Blood_Division_Type> list = db.Blood_Division_Types.Where(i => i.Blood_Division_Id == Convert.ToInt32(Details.id)).ToList();
                db.Blood_Division_Types.DeleteAllOnSubmit(list);
                db.SubmitChanges();
            }
            foreach (var Blood_Division_type in Details.arr)
            {
                BDGT = new Blood_Division_Type();
                BDGT.Blood_Division_Id = lastId;
                BDGT.Blood_Platelets_Id = Blood_Division_type.Type_id;
                BDGT.Blood_Platelets_Name = Blood_Division_type.Platelets;
                BDGT.Qty = Convert.ToInt32(Blood_Division_type.Qty);
                BDGT.Original_Qty = Convert.ToInt32(Blood_Division_type.OrgnlQty);
                BDGT.issue_Qty = Convert.ToInt32(Blood_Division_type.issueQty);
                BDGT.isExpired = Blood_Division_type.IsExpired;
                BDGT.Comment = Blood_Division_type.Comment;
                var da = Blood_Division_type.ExpiredDate;
                if (Blood_Division_type.IsExpired == true)
                {
                    if (Blood_Division_type.ExpiredDate == "null")
                    {
                        BDGT.Expired_Division_Date = DateTime.Now;
                    }
                    else
                    {
                        BDGT.Expired_Division_Date = Convert.ToDateTime(da);
                    }
                }
                if (Blood_Division_type.Exp_date == "")
                {

                }
                else
                {
                    BDGT.Expiry_Date = Convert.ToDateTime(Blood_Division_type.Exp_date);
                }

                
                db.Blood_Division_Types.InsertOnSubmit(BDGT);
                db.SubmitChanges();
            }
           
            DBClass.executeNonQueryWithoutBegin("update Donor set IsBloodDivisoned=1 where Donor_Id=" + Details.donor_id);
            return lastId.ToString();
        }


        [WebMethod]
        public static string GetDonorDivisionID(int Donor_ID)
        {
            string Donor_id = DBClass.getField("select Blood_division_Id from Blood_Division where Donor_Id =" + Donor_ID);
          
            return Donor_id ;
        }


        [WebMethod]
        public static string GetDonorID(int id)
        {
            string Donor_id = DBClass.getField("select Donor_Id from Blood_Division where Blood_division_Id=" + id);
            string WholeBlood = DBClass.getField("select Whole_Blood from Blood_Division where Blood_division_Id=" + id);
            string Exp_date = DBClass.getField("select CONVERT(varchar, Expiry_Date, 106) from Blood_Division where Blood_division_Id=" + id);
            string isExpired = DBClass.getField("select isExpired from Blood_Division where Blood_division_Id=" + id);
            string Comment = DBClass.getField("select isnull(comment,'') as comment from Blood_Division where Blood_division_Id=" + id);
            string Created_Date = DBClass.getField("select Created_Time from Blood_Division where Blood_division_Id=" + id);
            return Donor_id + '-' + WholeBlood + '-' + Exp_date + '-' + isExpired + '-' + Comment + '-' + Created_Date;
        }

        [WebMethod]
        public static string GetPlatelets(int id)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var query = (from data in db.Blood_Division_Types.Where(x => x.Blood_Division_Id.Equals(id)) select data).ToList();
            return (new JavaScriptSerializer()).Serialize(query);
        }

        [WebMethod]
        public static string GetDonorList()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var query = (from data in db.Donors.Where(x => x.IsBloodDivisoned == false || x.IsBloodDivisoned == null && x.D_bagno != "")
                         select new
                         {
                             data.Donor_Id,
                             data.Donor_No,
                             data.Donor_Name,
                             data.Donor_Occupation,
                             data.Donor_Age,
                             ABO = db.GetDataValueName("ABO group", data.ABO),
                             Rh = db.GetDataValueName("Rh Type", data.Rh_Type),
                             data.D_bagno,


                         }).ToList();
            return (new JavaScriptSerializer()).Serialize(query);
        }

        [WebMethod]
        public static string appedddl()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Record = (from dv in db.DataValues
                          join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                          where vs.ValueSet_Name == "Blood Division"

                          select new
                          {
                              dv.DataValue_ID,
                              dv.DataValue_Description,
                              dv.DataValue_Name,
                              vs.ValueSet_Description,
                              dv.Segment1
                          }).ToList();
            return (new JavaScriptSerializer()).Serialize(Record);
        }

        [WebMethod]
        public static string GetDetail(string Donor_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var query = (from data in db.Donors.Where(x => x.Donor_Id == Convert.ToInt32(Donor_ID))
                         select new
                         {
                             data.Donor_Id,
                             data.Donor_Name,
                             data.Donor_Occupation,
                             data.Donor_Age,
                             data.Donor_relationship,
                             data.Donor_Address,
                             data.Donor_StateHealth,
                             data.Donor_LastDonation,
                             data.Donor_CenterDonation,
                             ABO = db.GetDataValueName("ABO group", data.ABO),
                             Rh = db.GetDataValueName("Rh Type", data.Rh_Type),
                             data.Expiry_Date,
                             data.D_bagno,
                         }).ToList();
            return (new JavaScriptSerializer()).Serialize(query);
        }

    }
}