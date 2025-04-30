using Infragistics.Web.UI.GridControls;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class DonorReceivingList : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static bool DeleteStock(string id)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            Blood_Division st = new Blood_Division();
            Blood_Division_Type stkItem = new Blood_Division_Type();

            SqlTransaction tranObj = null;
            SqlConnection con = new SqlConnection(DBClass.ConnectionString());
            con.Open();
            tranObj = con.BeginTransaction();
            try
            {
                var stockMainId = (from itm in db.Blood_Divisions
                                   where (itm.Blood_Division_Id == int.Parse(id))
                                   select itm.Blood_Division_Id).FirstOrDefault();
                var Donor_Id = (from itm in db.Blood_Divisions
                                where (itm.Blood_Division_Id == int.Parse(id))
                                select itm.Donor_Id).FirstOrDefault();
                if (stockMainId != 0)
                {
                    DBClass.exectueQuery("delete Blood_Division_Type where Blood_Division_Id =" + stockMainId, tranObj, con);
                    DBClass.exectueQuery("delete Blood_Division where Blood_Division_Id =" + stockMainId, tranObj, con);
                    DBClass.exectueQuery("update Donor set IsBloodDivisoned=0 where donor_id =" + Donor_Id, tranObj, con);
                    tranObj.Commit();
                }
                else
                {
                    tranObj.Rollback();
                    return false;
                }
            }
#pragma warning disable CS0168 // The variable 'ex' is declared but never used
            catch (Exception ex)
#pragma warning restore CS0168 // The variable 'ex' is declared but never used
            {
                if (tranObj != null)
                    tranObj.Rollback();
                return false;
            }
            return true;
        }

        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    var Total_Blood_Division = _dbContext.Blood_Divisions.Count();
                    var Blood_Division = from b in _dbContext.Blood_Divisions
                                 where (b.Blood_Division_Id.ToString().Contains(searchValue) || _dbContext.Donors.Where(d => d.Donor_Id == b.Donor_Id).Select(d => d.Donor_Name).FirstOrDefault().Contains(searchValue) || _dbContext.Donors.Where(d => d.Donor_Id == b.Donor_Id).Select(d => d.Donor_No).FirstOrDefault().Contains(searchValue))
                                 select new
                                 {
                                     Blood_Division_Id = b.Blood_Division_Id,
                                     Whole_Blood = b.Whole_Blood,
                                     Donor_No = _dbContext.Donors.Where(d => d.Donor_Id == b.Donor_Id).Select(d => d.Donor_No).FirstOrDefault(),
                                     donor_name = _dbContext.Donors.Where(d => d.Donor_Id == b.Donor_Id).Select(d => d.Donor_Name).FirstOrDefault(),
                                     Bag_Number = _dbContext.Donors.Where(d => d.Donor_Id == b.Donor_Id).Select(d => d.D_bagno).FirstOrDefault(),
                                     WholeBlood_Expiry = _dbContext.Blood_Division_Types.Where(t => t.Blood_Platelets_Id == "01" && t.Blood_Division_Id == b.Blood_Division_Id).OrderBy(t => t.Expiry_Date).Select(t => t.Expiry_Date).FirstOrDefault(),
                                     PCVExpiry = _dbContext.Blood_Division_Types.Where(t => t.Blood_Platelets_Id == "02" && t.Blood_Division_Id == b.Blood_Division_Id).OrderBy(t => t.Expiry_Date).Select(t => t.Expiry_Date).FirstOrDefault(),
                                     FFPsExpiry = _dbContext.Blood_Division_Types.Where(t => t.Blood_Platelets_Id == "03" && t.Blood_Division_Id == b.Blood_Division_Id).OrderBy(t => t.Expiry_Date)
                                     .Select(t => t.Expiry_Date)
                                     .FirstOrDefault(),
                                     Platelets_Expiry = _dbContext.Blood_Division_Types.Where(t => t.Blood_Platelets_Id == "04" && t.Blood_Division_Id == b.Blood_Division_Id).OrderBy(t => t.Expiry_Date).Select(t => t.Expiry_Date).FirstOrDefault()

                                 };



                    var FilteredCount = Blood_Division.Count();
                    switch (sortColumn)
                    {
                        case "Donor_No":
                            Blood_Division = sortColumnDirection == "asc" ? Blood_Division.OrderBy(a => a.Donor_No) : Blood_Division.OrderByDescending(a => a.Donor_No);
                            break;
                        case "WholeBlood_Expiry":
                            Blood_Division = sortColumnDirection == "asc" ? Blood_Division.OrderBy(a => a.WholeBlood_Expiry) : Blood_Division.OrderByDescending(a => a.WholeBlood_Expiry);
                            break;
                        case "PCVExpiry":
                            Blood_Division = sortColumnDirection == "asc" ? Blood_Division.OrderBy(a => a.PCVExpiry) : Blood_Division.OrderByDescending(a => a.PCVExpiry);
                            break;
                        default:
                            Blood_Division = Blood_Division.OrderByDescending(a => a.Blood_Division_Id);
                            break;
                    }


                    var Blood_Division_List = Blood_Division.Skip(start).Take(length).ToList();


                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Blood_Division, data = Blood_Division_List };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Blood Division list", ex);
            }
        }

        //  [WebMethod]

        //  public static string GetRecord(string Blood_Division, string  DonorID, string Donor_Name, string BagNo)
        //{
        //      string result = string.Empty;

        //      using (DataBaseDataContext db = new DataBaseDataContext())
        //      {
        //          var query = db.Blood_ProcessingList(Convert.ToInt32(Blood_Division),Convert.ToInt32(DonorID), Donor_Name, BagNo).ToList();


        //          result = (new JavaScriptSerializer()).Serialize(query).ToString();
        //      }
        //      return result;
        //  }


        //public static string GetRecord()
        //{
        //    List<object> list = new List<object>();

        //    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
        //    var Result = (from records in db.Blood_Divisions
        //            orderby records.Blood_Division_Id descending
        //                  //join Bdt in db.Blood_Division_Types
        //                  //on records.Blood_Division_Id equals Bdt.Blood_Division_Id
        //                  select new
        //                  {
        //                      Blood_Division_Id = records.Blood_Division_Id,
        //                      Donor_Id = records.Donor_Id,
        //                      Whole_Blood = records.Whole_Blood,
        //                      //records.Expiry_Date,
        //                      WholeBlood_Expiry = DBClass.getField("select top 1 Expiry_Date from Blood_Division_Type where Blood_Platelets_Id='01' and Blood_Division_Id=" + records.Blood_Division_Id),
        //                      // Mr_No=DBClass.GetMRNOBy_PatientID(Convert.ToInt32(records.Patient_Id)),
        //                      donor_name = DBClass.getField("select Donor_Name from donor where Donor_Id=" + records.Donor_Id),
        //                      Bag_Number = DBClass.getField("select D_bagno from donor where Donor_Id=" + records.Donor_Id),

        //                      // WholeBlood_Expiry = DBClass.getField("select top 1 Expiry_Date from Blood_Division_Type where Blood_Division_Id=" + Bdt.Blood_Division_Id),
        //                      PCVExpiry = DBClass.getField("select top 1 Expiry_Date from Blood_Division_Type where Blood_Platelets_Id='02' and Blood_Division_Id=" + records.Blood_Division_Id),

        //                      FFPsExpiry = DBClass.getField("select top 1 Expiry_Date from Blood_Division_Type where Blood_Platelets_Id='03' and Blood_Division_Id=" + records.Blood_Division_Id),

        //                      Platelets_Expiry = DBClass.getField("select top 1 Expiry_Date from Blood_Division_Type where  Blood_Platelets_Id='04' and Blood_Division_Id=" + records.Blood_Division_Id),
        //                      //Platelets_Expiry = DBClass.getField("select top 1 Expiry_Date from Blood_Division_Type where Blood_Platelets_Id='04' and Blood_Division_Id=" + Bdt.Blood_Division_Id)

        //                  }).Take(100).ToList();


        //    //foreach (var item in Result)
        //    //{
        //    //    list.Add(item);
        //    //}



        //    //var Result2 = (from Bdt in db.Blood_Division_Types
        //    //               select new
        //    //               {
        //    //                   Blood_Division_Id = Bdt.Blood_Division_Id,
        //    //                   Donor_Id = DBClass.getField("select Donor_Id from Blood_Division where Blood_Division_Id=" + Bdt.Blood_Division_Id),
        //    //                   // Whole_Blood = DBClass.getField("select case when (select count(*) from Blood_Division_Type where Blood_Platelets_Id='01' and Blood_Division_Type_Id= " + Bdt.Blood_Division_Type_Id + ") = 1 then cast('true' as bit) else cast('false' as bit) end "),
        //    //                   Whole_Blood = DBClass.getField("IF EXISTS (select * from Blood_Division_Type where Blood_Platelets_Id='01' and Blood_Division_Type_Id=" + Bdt.Blood_Division_Type_Id + ") BEGIN select cast('true' as bit) END ELSE BEGIN select cast('false' as bit) END"),

        //    //                   WholeBlood_Expiry = DBClass.getField("select isnull(Expiry_Date, '') from Blood_Division_Type where Blood_Platelets_Id='01' and Blood_Division_Type_Id=" + Bdt.Blood_Division_Type_Id), // Bdt.Expiry_Date,

        //    //                   // Mr_No=DBClass.GetMRNOBy_PatientID(Convert.ToInt32(records.Patient_Id)),
        //    //                   donor_name = DBClass.getField("select Donor_Name from donor where Donor_Id=(select isnull(Donor_Id, 0) from Blood_Division where Blood_Division_Id=" + Bdt.Blood_Division_Id + ")"),

        //    //                   Bag_Number = DBClass.getField("select D_bagno from donor where Donor_Id=(select isnull(Donor_Id, 0) from Blood_Division where Blood_Division_Id=" + Bdt.Blood_Division_Id + ")"),

        //    //                   // WholeBlood_Expiry = DBClass.getField("select top 1 Expiry_Date from Blood_Division_Type where Blood_Division_Id=" + Bdt.Blood_Division_Id),

        //    //                   PCVExpiry = DBClass.getField("select isnull(Expiry_Date, '') from Blood_Division_Type where Blood_Platelets_Id='02' and Blood_Division_Type_Id=" + Bdt.Blood_Division_Type_Id),

        //    //                   FFPsExpiry = DBClass.getField("select isnull(Expiry_Date, '') from Blood_Division_Type where Blood_Platelets_Id='03' and Blood_Division_Type_Id=" + Bdt.Blood_Division_Type_Id),

        //    //                   Platelets_Expiry = DBClass.getField("select isnull(Expiry_Date, '') from Blood_Division_Type where Blood_Platelets_Id='04' and Blood_Division_Type_Id=" + Bdt.Blood_Division_Type_Id)


        //    //               }).ToList();


        //    ////foreach (var item in Result2)
        //    ////{
        //    ////    list.Add(item);
        //    ////}

        //    //// var combined_Lists = Result.Cast<object>().Union(Result2.Cast<object>());
        //    //var combined_Lists = Result.Union(Result2.Cast<object>());

        //    return (new JavaScriptSerializer()).Serialize(Result);
        //}

        // [WebMethod]
        //public static string GetRecord()
        //{
        //    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
        //    var Result = (from records in db.Blood_Divisions
        //                  select new
        //                  {
        //                      records.Blood_Division_Id,
        //                      records.Donor_Id,
        //                      records.Whole_Blood,
        //                      records.Expiry_Date,
        //                      //Mr_No=DBClass.GetMRNOBy_PatientID(Convert.ToInt32(records.Patient_Id)),
        //                      donor_name = DBClass.getField("select Donor_Name from donor where Donor_Id=" + records.Donor_Id),
        //                      Bag_Number = DBClass.getField("select D_bagno from donor where Donor_Id=" + records.Donor_Id),



        //                  }).ToList().OrderByDescending(x=>x.Blood_Division_Id);

        //    return (new JavaScriptSerializer()).Serialize(Result);
        //}

        //FFPsExpiry = DBClass.getField("select top 1 Expiry_Date from Blood_Division_Type where Blood_Platelets_Id='03' and Blood_Division_Id=" + Bdt.Blood_Division_Id),

        //Platelets_Expiry = DBClass.getField("select top 1 Expiry_Date from Blood_Division_Type where Blood_Platelets_Id='04' and Blood_Division_Id=" + Bdt.Blood_Division_Id)

    }
}