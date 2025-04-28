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
    public partial class Donors : System.Web.UI.Page
    {
        protected static int lastId = -1;
        protected static int QueryString = -1;
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        public class Detail
        {
            public string Name;
            public string Gender;
            public string Age;
            public string Mobile;
            public string Address;
            public string Entry_Date;
            public string department;
            public string Follow;
            public string Patient_type;

        }

        

        [WebMethod]
        public static string appedddl()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Record = (from dv in db.DataValues
                                   join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                                   where (vs.ValueSet_Name == "HBS"  || vs.ValueSet_Name == "HCV"  ||
vs.ValueSet_Name == "HIV" || vs.ValueSet_Name == "VDRL" || vs.ValueSet_Name == "MP" || vs.ValueSet_Name == "ABO group" || vs.ValueSet_Name == "Rh Type"

)

                                   select new
                                   {
                                      dv.DataValue_ID,
                                      dv.DataValue_Description,
                                      dv.DataValue_Name,
                                      vs.ValueSet_Description
                                   }).ToList();
            return (new JavaScriptSerializer()).Serialize(Record);
        }

        [WebMethod]
        public static string SaveFirstTab(string Patient_id, bool yheartdis, bool nheartdis, bool ytattoo, bool ntattoo, bool yimprison, bool nimprison, bool yepi, bool nepi, bool yacu, bool nacu, bool ymal, bool nmal, bool yhyper, bool nhyper, bool yenp, bool nenp, bool ytuber, bool ntuber, bool ysyn, bool nsyn, bool yrh, bool nrh, bool ydiabetes, bool ndiabetes, bool yjaun, bool njaun, bool yvisit, bool nvisit, bool ybleed, bool nbleed, bool yprevious, bool nprevious, bool yaddi, bool naddi, bool yasthma, bool nasthma, bool yrs, bool nrs, bool yusp, bool nusp, bool yimmu, bool nimmu, bool ytooth, bool ntooth, bool yfood, bool nfood, bool yallergies, bool nallergies,string others, string sign, string cell, string id, string donor_name, string relation, string address, string age, string occupation, string statehealth, string datedonation, string center, string donr_no, string bagqty, string cnic,string isUpdateValue,bool first_time_Blood)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            try
            {
                Donor DT;
                if (isUpdateValue == "0")
                {
                    DT = new Donor();
                    DT.Created_By = AppConfig.UserID;
                    DT.Created_Time = DateTime.Now;

                }
                else
                {
                    lastId = Convert.ToInt32(id);
                    if (lastId == 0) lastId = Convert.ToInt32(isUpdateValue);
                    DT = (from tbl in db.Donors
                          where tbl.Donor_Id == lastId

                          select tbl).FirstOrDefault();

                    DT.Updated_By = AppConfig.UserID;
                    DT.Updated_Time = DateTime.Now;
                }
                DT.Book_Id = AppConfig.Book_ID;
                DT.Company_Id = AppConfig.Company_ID;
                DT.D_yacu = yacu;
                DT.D_nacu = nacu;
                DT.D_yaddi = yaddi;
                DT.D_naddi = naddi;
                DT.D_yallergies = yallergies;
                DT.D_nallergies = nallergies;
                DT.D_yasthma = yasthma;
                DT.D_nasthma = nasthma;
                DT.D_ybleed = ybleed;
                DT.D_nbleed = nbleed;
                DT.D_ydiabetes = ydiabetes;
                DT.D_ndiabetes = ndiabetes;
                DT.D_yenp = yenp;
                DT.D_nenp = nenp;
                DT.D_yepi = yepi;
                DT.D_nepi = nepi;
                DT.D_yfood = yfood;
                DT.D_nfood = nfood;
                DT.D_yheartdis = yheartdis;
                DT.D_nheartdis = nheartdis;
              
                DT.D_yhyper = yhyper;
                DT.D_nhyper = nhyper;
                DT.D_yimmu = yimmu;
                DT.D_nimmu = nimmu;
                DT.D_yimprison = yimprison;
                DT.D_nimprison = nimprison;

                DT.D_yjaund = yjaun;
                DT.D_njaund = njaun;

                DT.D_ymal = ymal;
                DT.D_nmal = nmal;
                DT.D_yprevious = yprevious;
                DT.D_nprevious = nprevious;
                DT.D_yrh = yrh;
                DT.D_nrh = nrh;
                DT.D_yrsurgery = yrs;
                DT.D_nrsurgery = nrs;
                DT.D_ysyn = ysyn;
                DT.D_nsyn = nsyn;
                DT.D_ytattoo = ytattoo;
                DT.D_ntattoo = ntattoo;
                DT.D_ytooth = ytooth;
                DT.D_ntooth = ntooth;
                DT.D_ytuber = ytuber;
                DT.D_ntuber = ntuber;
                DT.D_yusp = yusp;
                DT.D_nusp = nusp;
                DT.D_yvisit = yvisit;
                DT.D_nvisit = nvisit;
                DT.Donor_Name = donor_name;
                DT.Donor_Address = address;
                DT.Donor_Age = age;
                DT.Donor_CenterDonation = center;
                DT.CNIC = cnic;
                DT.D_Others = others;
                DT.D_sign = sign;
                DT.D_Cell = cell;
                DT.Donating_First_Time = first_time_Blood;
                DT.Bag_Qty =Convert.ToInt32(bagqty);
                if (datedonation == "")
                {
                }
                else
                {
                    DT.Donor_LastDonation = Convert.ToDateTime(datedonation);
                }

                DT.Donor_Occupation = occupation;
                DT.Donor_StateHealth = statehealth;
                DT.Donor_relationship = relation;
                DT.Donor_No = donr_no;
                if (Patient_id == "")
                {

                    Patient_id = Convert.ToString(0);
                }

                DT.Patient_Id = Convert.ToInt32(Patient_id);
                if (isUpdateValue == "0")
                {
                    db.Donors.InsertOnSubmit(DT);

                }
                db.SubmitChanges();
                if (isUpdateValue == "0")
                {

                    var getMaxVal = (Convert.ToInt32(db.Donors.Max(p => p.Donor_Id)));
                    lastId = getMaxVal;
                }
            } catch (Exception ex)
            {


            }
          
            return lastId.ToString();
        }

        [WebMethod]
        public static string SaveTabSecond(string Patient_id, string pulse, string bp, string emp, string hb, string hbs, string hcv, string hiv, string drl, string mp, string date, string txtfoodtime, string txtBlood, bool fit, bool unfit, string bdrawn, string signature, string bgno, string signbto, string id, string abo, string rh, string donr_no, string isUpdateValue)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            try
            {
                Donor DT;
             
                if (isUpdateValue == "0")
                {
                    DT = new Donor();
                    DT.Created_By = AppConfig.UserID;
                    DT.Created_Time = DateTime.Now;

                }
                else
                {
                    lastId = Convert.ToInt32(id);
                    if (lastId == 0) lastId = Convert.ToInt32(isUpdateValue);
                    DT = (from tbl in db.Donors
                          where tbl.Donor_Id == lastId 

                          select tbl).FirstOrDefault();
                }
                DT.Updated_By = AppConfig.UserID;
                    DT.Updated_Time = DateTime.Now;
                    DT.D_bagno = bgno;
                    DT.D_Blood = txtBlood;
                    DT.D_blooddrawn = bdrawn;
                    DT.D_bp = bp;
                    DT.D_pulse = pulse;
              
                    DT.D_temp = emp;
                    DT.D_hb = hb;
                    DT.D_hbsAG = hbs;
                    DT.D_HCV = hcv;
                    DT.D_HIV = hiv;
                    DT.D_VDRL = drl;
                    DT.D_MP = mp;
                  
                    DT.D_Signature = signature; ///1
                    DT.D_signbto = signbto;
                DT.D_foodtime = txtfoodtime;
                DT.D_fit = fit;
                DT.D_unfit = unfit;
                if (date == "")
                    {

                    }
                    else
                    {

                        DT.D_Date = Convert.ToDateTime(date);
                    }
                    DT.ABO = abo;
                    DT.Rh_Type = rh;
                    DT.Donor_No = donr_no;
                    if (Patient_id == "")
                    {

                        Patient_id = Convert.ToString(0);
                    }

                    DT.Patient_Id = Convert.ToInt32(Patient_id);
                    if (Patient_id == "")
                    {

                        Patient_id = Convert.ToString(0);
                    }

                    DT.Patient_Id = Convert.ToInt32(Patient_id);
                    if (isUpdateValue == "0")
                    {
                        db.Donors.InsertOnSubmit(DT);

                    }
                    db.SubmitChanges();
                    if (isUpdateValue == "0")
                    {

                        var getMaxVal = (Convert.ToInt32(db.Donors.Max(p => p.Donor_Id)));
                        lastId = getMaxVal;
                    }
                }
           
            catch (Exception ex)
            {


            }
            return lastId.ToString();
        }


        [WebMethod]
        public static string SaveAll(string btnSave, string Patient_id, bool yheartdis, bool nheartdis, bool ytattoo, bool ntattoo, bool yimprison, bool nimprison, bool yepi, bool nepi, bool yacu, bool nacu, bool ymal, bool nmal, bool yhyper, bool nhyper, bool yenp, bool nenp, bool ytuber, bool ntuber, bool ysyn, bool nsyn, bool yrh, bool nrh, bool ydiabetes, bool ndiabetes, bool yjaun, bool njaun, bool yvisit, bool nvisit, bool ybleed, bool nbleed, bool yprevious, bool nprevious, bool yaddi, bool naddi, bool yasthma, bool nasthma, bool yrs, bool nrs, bool yusp, bool nusp, bool yimmu, bool nimmu, bool ytooth, bool ntooth, bool yfood, bool nfood, bool yallergies, bool nallergies, string pulse, string bp, string emp, string hb, string hbs, string hcv, string hiv, string drl, string mp, string others, string txtfoodtime, string txtBlood, bool fit, bool unfit, string bdrawn, string sign, string cell, string signature, string date, string bgno, string signbto, string id, string donor_name, string relation, string address, string age, string occupation, string statehealth, string datedonation, string center, string abo, string rh, string donr_no, string bagqty,string cnic)
                  
        { 

            DataBaseDataContext db = new DataBaseDataContext();
            try
            {
                Donor DT;
                if (btnSave == "Save")
                {
                    DT = new Donor();
                    DT.Created_By = AppConfig.UserID;
                    DT.Created_Time = DateTime.Now;

                }
                else
                {
                    lastId = Convert.ToInt32(id);
                    DT = (from tbl in db.Donors
                          where tbl.Donor_Id == lastId
                      
                          select tbl).FirstOrDefault();
               
                    DT.Updated_By = AppConfig.UserID;
                    DT.Updated_Time = DateTime.Now;
                }

                DT.Bag_Qty = Convert.ToInt32(bagqty);
               
               
                DT.Book_Id = AppConfig.Book_ID;
                DT.Company_Id = AppConfig.Company_ID;
                DT.D_bagno = bgno;
                DT.D_Blood = txtBlood;
                DT.D_blooddrawn = bdrawn;
                DT.D_bp = bp;
                DT.D_pulse = pulse;
                DT.D_sign = sign; //2
                DT.D_temp = emp;
                DT.D_hb = hb;
                DT.D_hbsAG = hbs;
                DT.D_HCV = hcv;
                DT.D_HIV = hiv;
                DT.D_VDRL=drl;
                DT.D_MP = mp;
                DT.D_Others = others;
                DT.D_Signature = signature; ///1
                DT.D_signbto = signbto;
                DT.D_Cell = cell;
                if (date == "")
                {
                
                }
                else
                {
                
                DT.D_Date =Convert.ToDateTime(date);
                }
                DT.D_fit = fit;
                DT.D_unfit = unfit;
                DT.D_VDRL = drl;
                DT.D_yacu = yacu;
                DT.D_nacu = nacu;
                DT.D_yaddi = yaddi;
                DT.D_naddi = naddi;
                DT.D_yallergies = yallergies;
                DT.D_nallergies = nallergies;
                DT.D_yasthma = yasthma;
                DT.D_nasthma = nasthma;
                DT.D_ybleed = ybleed;
                DT.D_nbleed = nbleed;
                DT.D_ydiabetes = ydiabetes;
                DT.D_ndiabetes = ndiabetes;
                DT.D_yenp = yenp;
                DT.D_nenp = nenp;
                DT.D_yepi = yepi;
                DT.D_nepi = nepi;
                DT.D_yfood = yfood;
                DT.D_nfood = nfood;
                DT.D_yheartdis = yheartdis;
                DT.D_nheartdis = nheartdis;
                DT.D_foodtime = txtfoodtime;
                DT.D_yhyper = yhyper;
                DT.D_nhyper = nhyper;
                DT.D_yimmu = yimmu;
                DT.D_nimmu = nimmu;
                DT.D_yimprison = yimprison;
                DT.D_nimprison = nimprison;

                DT.D_yjaund = yjaun;
                DT.D_njaund = njaun;

                DT.D_ymal = ymal;
                DT.D_nmal = nmal;
                DT.D_yprevious = yprevious;
                DT.D_nprevious = nprevious;
                DT.D_yrh = yrh;
                DT.D_nrh = nrh;
                DT.D_yrsurgery = yrs;
                DT.D_nrsurgery = nrs;
                DT.D_ysyn = ysyn;
                DT.D_nsyn = nsyn;
                DT.D_ytattoo = ytattoo;
                DT.D_ntattoo = ntattoo;
                DT.D_ytooth = ytooth;
                DT.D_ntooth = ntooth;
                DT.D_ytuber = ytuber;
                DT.D_ntuber = ntuber;
                DT.D_yusp = yusp;
                DT.D_nusp = nusp;
                DT.D_yvisit = yvisit;
                DT.D_nvisit = nvisit;
                DT.Donor_Name=donor_name;
                DT.Donor_Address = address;
                DT.Donor_Age = age;
                DT.Donor_CenterDonation = center;
                DT.CNIC = cnic;
                if (datedonation == "")
                {
                }
                else
                {
                    DT.Donor_LastDonation = Convert.ToDateTime(datedonation);
                }
             
                DT.Donor_Occupation = occupation;
                DT.Donor_StateHealth = statehealth;
                DT.Donor_relationship = relation;
                DT.ABO = abo;
                DT.Rh_Type = rh;
                DT.Donor_No = donr_no;
                if (Patient_id == "")
                {

                    Patient_id = Convert.ToString(0);
                }

                DT.Patient_Id = Convert.ToInt32(Patient_id);
                if (btnSave == "Save")
                {
                    db.Donors.InsertOnSubmit(DT);

                }
                db.SubmitChanges();
                if (btnSave == "Save")
                {

                    var getMaxVal = (Convert.ToInt32(db.Donors.Max(p => p.Donor_Id)));
                    lastId = getMaxVal;
                }
               

            }catch(Exception ex)
            {
            
            
            }
            return lastId.ToString();
        }
        [System.Web.Services.WebMethod]
        public static bool CheckDuplicate(string Bag_No)
        {
            bool isProceed = true;
            DataBaseDataContext db = new DataBaseDataContext();
            if (Bag_No == "")
            {

            }
            else
            {

           
            var row_count = DBClass.getDataTable("select D_bagno from donor where D_bagno='" + Bag_No + "'");
            if (row_count.Rows.Count > 0)
               {
                    isProceed = false;
                   
                }
          }
            return isProceed;
        }

        [System.Web.Services.WebMethod]
        public static bool CheckExitsBag(string id)
        {
            bool isBagUpdated = false;
            var isExist= DBClass.getField("select D_bagno from donor where donor_id='" + id + "'");
            if (isExist == "" || isExist.Contains("Error"))
            {
                isBagUpdated = true;
            }
                return isBagUpdated;
        }
        [System.Web.Services.WebMethod]
        public static bool CheckExitsDonor(string id)
        {

            bool isDonorUpdated = false;
            var isExist = DBClass.getField("select Donor_No from donor where donor_id='" + id + "'");
            if (isExist == "" || isExist.Contains("Error"))
            {
                isDonorUpdated = true;
            }
            return isDonorUpdated;
        }
        [System.Web.Services.WebMethod]
        public static bool CheckDuplicateDonor(string donr_no)
        {
            bool isProceed = true;
            DataBaseDataContext db = new DataBaseDataContext();
            if (donr_no == "")
            {

            }
            else
            {

                var row_count = DBClass.getDataTable("select Donor_No from donor where Donor_No='" + donr_no + "'");
                if (row_count.Rows.Count > 0)
                {

                    isProceed = false;
                }
            }
            return isProceed;
        }

        [System.Web.Services.WebMethod]
        public static string getRecords(string id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var Result = (from records in db.Donors
                          where (records.Donor_Id.Equals(id))
                          select records).ToList();

            return (new JavaScriptSerializer()).Serialize(Result);
        }

        [System.Web.Services.WebMethod]
        public static Detail GetDetail(string PatientID)
        {
            int Patien_No = DBClass.GetMRNOBy_PatientID(Convert.ToInt32(PatientID));
            Detail pt = new Detail();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            Patient pat = new Patient();
            pat = (from tbl in db.Patients
                   where tbl.Patient_No == Patien_No
                   orderby tbl.Entry_Date descending

                   select tbl).FirstOrDefault();
            if (pat != null)
            {
                pt.Name = pat.Full_Name;
                pt.Gender = pat.Gender;
                pt.Age = pat.Age_years.ToString();
                if (pat.Entry_Date.HasValue)
                    pt.Entry_Date = pat.Entry_Date.ToString();
                pt.Address = pat.Permanent_Address;
                pt.Mobile = pat.Mobile1;
                pt.Entry_Date = pat.Created_Time.ToString();
                pt.department = pat.Patient_Main_Category;
                pt.department = DBClass.getPatientLatestDepartment(Convert.ToInt32(pat.Patient_No), true).ToString();
                pt.Patient_type = db.GetDataValueName("Patient Type", pat.Patient_Type);
                pt.Gender = db.GetDataValueName("Gender", pat.Gender);
                var Patientno = pat.Patient_No.ToString();
                var count = (db.Patients.Where(v => v.Patient_No == Convert.ToInt32(Patientno)).ToList());
                pt.Follow = count.Count.ToString();
                return pt;
            }
            else
                return pt;
        }

    }
}