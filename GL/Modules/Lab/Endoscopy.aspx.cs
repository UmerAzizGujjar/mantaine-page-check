using CrystalDecisions.CrystalReports.Engine;
using CrystalDecisions.Shared;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class Endoscopy : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Request.QueryString["ID"] != null)
                {
                }
            }       
        }

        public class Detail
        {
            public string Name;
            public string Gender;
            public string Age;
            public string Mobile;
            public string Address;
            public string Entry_Date;
            public string Patient_Category;
            public string Mode_Of_Registration;
        }

        [System.Web.Services.WebMethod]

        public static Detail GetDetail(string PatientID)
        {
            int Patien_No = Convert.ToInt32(PatientID);
            Detail pt = new Detail();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            Patient pat = new Patient();
            pat = (from tbl in db.Patients
                   where tbl.Patient_ID == Patien_No
                   select tbl).FirstOrDefault();
            if (pat != null)
            {
                pt.Name = pat.Full_Name;
                pt.Gender = pat.Gender;
                pt.Age = pat.Age_years.ToString();
                if (pat.Entry_Date.HasValue)
                pt.Entry_Date = pat.Entry_Date.ToString();
                pt.Address = pat.Address;
                pt.Mobile = pat.Mobile;
                pt.Mode_Of_Registration = db.GetDataValueName("Mode Of Registration", pat.Mode_Of_Registration);
                pt.Patient_Category = db.GetDataValueName("Patient Main Category", pat.Patient_Main_Category);
                pt.Gender = db.GetDataValueName("Gender", pat.Gender);
                return pt;
            }
            else
                return pt;
        }

        [System.Web.Services.WebMethod]
        public static string GetEndoscopy(string id)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var end = (from e in db.PT_Endoscopies
                      where e.Endoscopy_ID == Convert.ToInt32(id)
                      select e).FirstOrDefault();

            if (end.Type == "Gastro")
            {
                var egastro = (from e in db.PT_Endoscopies
                                 join g in db.EN_Gastros
                                 on e.Endoscopy_ID equals g.Endoscopy_ID
                                 where e.Endoscopy_ID == Convert.ToInt32(id)
                                 select new { e, g }).FirstOrDefault();
                return (new JavaScriptSerializer()).Serialize(egastro);
            }
            else
            {
                var ecolono = (from e in db.PT_Endoscopies
                                 join c in db.EN_Colonos
                                 on e.Endoscopy_ID equals c.Endoscopy_ID
                                 where e.Endoscopy_ID == Convert.ToInt32(id)
                                 select new { e, c }).FirstOrDefault();
                return (new JavaScriptSerializer()).Serialize(ecolono);
            }
        }

        public class EndoscopyData
        {
            public string Endoscopy_ID;
            public string Patient_ID;
            public string Consultant;
            public string GI_Fellow;
            public string Performed;
            public string Reported;
            public string Type;
            public Gastro Gastro;
            public Colono Colono;
        }

        public class Colono
        {
            public string Medicine;
            public string Qty;
            public string Instrument;
            public string Biopsy;
            public string Remarks;
            public string Short_History;
            public string Findings;
            public string Rectum;
            public string Sigmoid;
            public string Descending_Colon;
            public string Transverse_Colon;
            public string Acending_Colon;
            public string Ileo_Cecal_Valve;
            public string Ileum;
            public string Therapeutic_Procedure;
            public string Impression;
            public string Repeat_Procedure;
            public string Recommendation;
        }

        public class Gastro
        {
            public string Medicine;
            public string Qty;
            public string Instrument;
            public string Biopsy;
            public string Remarks;
            public string Short_History;
            public string Oesophagus;
            public string Contents;
            public string Cardia;
            public string Fundus;
            public string Body;
            public string Antrum;
            public string Pylorus;
            public string D1;
            public string D2;
            public string Therapeutic_Procedure;
            public string Impression;
            public string Repeat_Procedure;
            public string Recommendation;
        }

        //public static string Get_
        [WebMethod]
        public static string GetInstruments()
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var inst = from dv in db.DataValues
                      join vs in db.ValueSets on dv.ValueSet_ID equals vs.ValueSet_ID
                      where vs.ValueSet_Name == "Endoscopy Instruments"
                      select new { dv.DataValue_Name, dv.DataValue_Description };

            return (new JavaScriptSerializer()).Serialize(inst);

        }

        [WebMethod]
        public static string SaveEndoscopy(string data)
        {
            Laboratory_Test lt = new Laboratory_Test();
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            JavaScriptSerializer oJS = new JavaScriptSerializer();
            var record = oJS.Deserialize<EndoscopyData>(data);
            int endoscopy_id;

            if (record.Endoscopy_ID != "")
            {
                var endoscopy = (from e in db.PT_Endoscopies
                                 where e.Endoscopy_ID == int.Parse(record.Endoscopy_ID)
                                 select e).FirstOrDefault();
                endoscopy.Consultant = record.Consultant;
                endoscopy.GI_Fellow = record.GI_Fellow;
                endoscopy.Performed = Convert.ToDateTime(record.Performed);
                endoscopy.Reported = Convert.ToDateTime(record.Reported);
                endoscopy.Type = record.Type;
                db.SubmitChanges();

                endoscopy_id = endoscopy.Endoscopy_ID;

                var gastro = (from g in db.EN_Gastros
                              where g.Endoscopy_ID == endoscopy_id
                              select g).ToList();
                db.EN_Gastros.DeleteAllOnSubmit(gastro);
                db.SubmitChanges();

                var colono = (from c in db.EN_Colonos
                              where c.Endoscopy_ID == endoscopy_id
                              select c).ToList();
                db.EN_Colonos.DeleteAllOnSubmit(colono);
                db.SubmitChanges();
            }
            else
            {
                PT_Endoscopy endoscopy = new PT_Endoscopy();
                endoscopy.Patient_ID = int.Parse(record.Patient_ID);
                endoscopy.Consultant = record.Consultant;
                endoscopy.GI_Fellow = record.GI_Fellow;
                endoscopy.Performed = Convert.ToDateTime(record.Performed);
                endoscopy.Reported = Convert.ToDateTime(record.Reported);
                endoscopy.Type = record.Type;
                db.PT_Endoscopies.InsertOnSubmit(endoscopy);
                db.SubmitChanges();
                endoscopy_id = endoscopy.Endoscopy_ID;
            }

            if (record.Type == "Gastro")
            {
                EN_Gastro gastro = new EN_Gastro();
                gastro.Endoscopy_ID = endoscopy_id;
                gastro.Patient_ID = int.Parse(record.Patient_ID);
                gastro.Medicine = record.Gastro.Medicine;
                gastro.Qty = record.Gastro.Qty;
                gastro.Instrument = record.Gastro.Instrument;
                gastro.Biopsy = record.Gastro.Biopsy;
                gastro.Remarks = record.Gastro.Remarks;
                gastro.Short_History = record.Gastro.Short_History;
                gastro.Oesophagus = record.Gastro.Oesophagus;
                gastro.Contents = record.Gastro.Contents;
                gastro.Cardia = record.Gastro.Cardia;
                gastro.Fundus = record.Gastro.Fundus;
                gastro.Body = record.Gastro.Body;
                gastro.Antrum = record.Gastro.Antrum;
                gastro.Pylorus = record.Gastro.Pylorus;
                gastro.D1 = record.Gastro.D1;
                gastro.D2 = record.Gastro.D2;
                gastro.Therapeutic_Procedure = record.Gastro.Therapeutic_Procedure;
                gastro.Impression = record.Gastro.Impression;
                gastro.Repeat_Procedure = record.Gastro.Repeat_Procedure;
                gastro.Recommendation = record.Gastro.Recommendation;

                db.EN_Gastros.InsertOnSubmit(gastro);
                db.SubmitChanges();
            }
            else if (record.Type == "Colono")
            {
                EN_Colono colono = new EN_Colono();
                colono.Endoscopy_ID = endoscopy_id;
                colono.Patient_ID = int.Parse(record.Patient_ID);
                colono.Medicine = record.Colono.Medicine;
                colono.Qty = record.Colono.Qty;
                colono.Instrument = record.Colono.Instrument;
                colono.Biopsy = record.Colono.Biopsy;
                colono.Remarks = record.Colono.Remarks;
                colono.Short_History = record.Colono.Short_History;
                colono.Findings = record.Colono.Findings;
                colono.Rectum = record.Colono.Rectum;
                colono.Sigmoid = record.Colono.Sigmoid;
                colono.Descending_Colon = record.Colono.Descending_Colon;
                colono.Transverse_Colon = record.Colono.Transverse_Colon;
                colono.Acending_Colon = record.Colono.Acending_Colon;
                colono.Ileo_Cecal_Valve = record.Colono.Ileo_Cecal_Valve;
                colono.Ileum = record.Colono.Ileum;
                colono.Therapeutic_Procedure = record.Colono.Therapeutic_Procedure;
                colono.Impression = record.Colono.Impression;
                colono.Repeat_Procedure = record.Colono.Repeat_Procedure;
                colono.Recommendation = record.Colono.Recommendation;
                db.EN_Colonos.InsertOnSubmit(colono);
                db.SubmitChanges();
            }
            return "";
        }
    }
}