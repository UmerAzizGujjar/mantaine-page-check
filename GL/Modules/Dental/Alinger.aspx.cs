using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.SqlClient;
using System.Data;
using System.Web.Services;
using System.Web.Script.Serialization;
using System.IO;
using System.Security.Cryptography;

namespace PMS
{
    public partial class Alinger : System.Web.UI.Page
    {
        DataTable dt;
        DataBaseDataContext db = new DataBaseDataContext();
        public static int OutpatientID;
        protected void Page_Load(object sender, EventArgs e)
        {

           
                if (!Page.IsPostBack)
                {
                db = new DataBaseDataContext();
                BlankForm();
                    txtAlinger_ID.Text = "(New)";
                    BindingDropDown();
                    

                    if (Request.QueryString["ID"] != null)
                    {
                        FillOutPatientForm(Convert.ToInt32(Request.QueryString["ID"]));
                                           
                    }
                }

            
        }
        private void BindingDropDown()
        {
            object valueset;


            valueset = DBClass.GetValueSet("Indirect Veneers");
            ddlIndirectveneer.DataSource = valueset;
            ddlIndirectveneer.DataTextField = "DataValue_Description";
            ddlIndirectveneer.DataValueField = "DataValue_Name";
            ddlIndirectveneer.Items.Add(new ListItem("Please Select", "0"));
            ddlIndirectveneer.DataBind();

            valueset = DBClass.GetValueSet("Arch");
            ddlarch.DataSource = valueset;
            ddlarch.DataTextField = "DataValue_Description";
            ddlarch.DataValueField = "DataValue_Name";
            ddlarch.Items.Add(new ListItem("Please Select", "0"));
            ddlarch.DataBind();

            valueset = DBClass.GetValueSet("Crown And Bridge");
            ddlCrown_bridge.DataSource = valueset;
            ddlCrown_bridge.DataTextField = "DataValue_Description";
            ddlCrown_bridge.DataValueField = "DataValue_Name";
            ddlCrown_bridge.Items.Add(new ListItem("Please Select", "0"));
            ddlCrown_bridge.DataBind();

            valueset = DBClass.GetValueSet("Thicker of Alinger");
            ddlThicker.DataSource = valueset;
            ddlThicker.DataTextField = "DataValue_Description";
            ddlThicker.DataValueField = "DataValue_Name";
            ddlThicker.Items.Add(new ListItem("Please Select", "0"));
            ddlThicker.DataBind();

            valueset = DBClass.GetValueSet("Template of Alinger");
            ddlTemplate.DataSource = valueset;
            ddlTemplate.DataTextField = "DataValue_Description";
            ddlTemplate.DataValueField = "DataValue_Name";
            ddlTemplate.Items.Add(new ListItem("Please Select", "0"));
            ddlTemplate.DataBind();




            valueset = DBClass.GetValueSet("Type of Alinger");
            ddlType_of_Alinger.DataSource = valueset;
            ddlType_of_Alinger.DataTextField = "DataValue_Description";
            ddlType_of_Alinger.DataValueField = "DataValue_Name";
            ddlType_of_Alinger.Items.Add(new ListItem("Please Select", "0"));
            ddlType_of_Alinger.DataBind();

            valueset = DBClass.GetValueSet("Margin of Alinger");
            ddlMargin.DataSource = valueset;
            ddlMargin.DataTextField = "DataValue_Description";
            ddlMargin.DataValueField = "DataValue_Name";
            ddlMargin.Items.Add(new ListItem("Please Select", "0"));
            ddlMargin.DataBind();

            valueset = DBClass.GetValueSet("Material of Alinger");
            ddlMaterial.DataSource = valueset;
            ddlMaterial.DataTextField = "DataValue_Description";
            ddlMaterial.DataValueField = "DataValue_Name";
            ddlMaterial.Items.Add(new ListItem("Please Select", "0"));
            ddlMaterial.DataBind();

            valueset = DBClass.GetValueSet("No of Alinger");
            ddlno_of_alinger.DataSource = valueset;
            ddlno_of_alinger.DataTextField = "DataValue_Description";
            ddlno_of_alinger.DataValueField = "DataValue_Name";
            ddlno_of_alinger.Items.Add(new ListItem("Please Select", "0"));
            ddlno_of_alinger.DataBind();
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
            public string Patient_Type;

        }
        [WebMethod]
        public static string GetPatient_CategoryByPat(Int32 PatID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var pat = from p in db.Patients
                      where p.Patient_ID == PatID
                      select new { p.Patient_Type };
            return (new JavaScriptSerializer()).Serialize(pat);
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
               // pt.department = pat.Patient_Main_Category;
                pt.department = db.GetDataValueName("Patient Main Category", pat.Patient_Main_Category);
                pt.Gender = db.GetDataValueName("Gender", pat.Gender);
                pt.Patient_Type = db.GetDataValueName("Patient Type", pat.Patient_Type);
                var Patientno = pat.Patient_No.ToString();
                var count = (db.Patients.Where(v => v.Patient_No == Convert.ToInt32(Patientno)).ToList());
                pt.Follow = count.Count.ToString();
                return pt;
            }
            else
                return pt;
        }
        //[WebMethod]
        protected void FillOutPatientForm(int Out_Patient_id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
          var  AlingerID= ( from a in db.Alingers join
                         pt in db.Reg_patients on a.Patient_ID equals pt.pat_id
                 where a.Alinger_ID== Out_Patient_id
                 select new
                 {
                     pt.pat_id,
                     pt.Full_Name,
                     pt.Created_time,
                     pt.mr_no_sequence,
                     pt.Permanent_Address,
                     //pt.Patient_Main_Category,
                     pt.Mobile1,
                     pt.Gender,
                     pt.Age_years,
                     a.Alinger_ID,
                     a.chk_S1T1,
                     a.chk_S1T2,
                     a.chk_S1T3,
                     a.chk_S1T4,
                     a.chk_S1T5,
                     a.chk_S1T6,
                     a.chk_S1T7,
                     a.chk_S1T8,
                     a.chk_S2T1,
                     a.chk_S2T2,
                     a.chk_S2T3,
                     a.chk_S2T4,
                     a.chk_S2T5,
                     a.chk_S2T6,
                     a.chk_S2T7,
                     a.chk_S2T8,
                     a.chk_S3T1,
                     a.chk_S3T2,
                     a.chk_S3T3,
                     a.chk_S3T4,
                     a.chk_S3T5,
                     a.chk_S3T6,
                     a.chk_S3T7,
                     a.chk_S3T8,
                     a.chk_S4T1,
                     a.chk_S4T2,
                     a.chk_S4T3,
                     a.chk_S4T4,
                     a.chk_S4T5,
                     a.chk_S4T6,
                     a.chk_S4T7,
                     a.chk_S4T8
                 }).FirstOrDefault();
            if (AlingerID != null)
            {
                hdfPatient_ID.Value= AlingerID.pat_id.ToString();
                txtAlinger_ID.Text = AlingerID.Alinger_ID.ToString();
                txtPatient_ID.Text = AlingerID.pat_id.ToString();
                vlblPatients_Name.Text = AlingerID.Full_Name;
                vLbl_Age.Text = AlingerID.Age_years;
                vLbl_Gender.Text = AlingerID.Gender;
                vLbl_RegDate.Text = AlingerID.Created_time.Value.ToString(AppConfig.DateFormat);
               // vLbl_Adress.Text = AlingerID.Address;
                vLbl_Contact.Text = AlingerID.Mobile1;
                vLbl_PatientCategory.Text = AlingerID.Gender;
                CHK_S1T1.Checked = AlingerID.chk_S1T1 ?? false;             
                CHK_S1T2.Checked = AlingerID.chk_S1T2 ?? false;
                CHK_S1T3.Checked = AlingerID.chk_S1T3 ?? false;
                CHK_S1T4.Checked = AlingerID.chk_S1T4 ?? false;
                CHK_S1T5.Checked = AlingerID.chk_S1T5 ?? false;
                CHK_S1T6.Checked = AlingerID.chk_S1T6 ?? false;
                CHK_S1T7.Checked = AlingerID.chk_S1T7 ?? false;
                CHK_S1T8.Checked = AlingerID.chk_S1T8 ?? false;
                CHK_S2T1.Checked = AlingerID.chk_S2T1 ?? false;
                CHK_S2T2.Checked = AlingerID.chk_S2T2 ?? false;
                CHK_S2T3.Checked = AlingerID.chk_S2T3 ?? false;
                CHK_S2T4.Checked = AlingerID.chk_S2T4 ?? false;
                CHK_S2T5.Checked = AlingerID.chk_S2T5 ?? false;
                CHK_S2T6.Checked = AlingerID.chk_S2T6 ?? false;
                CHK_S2T7.Checked = AlingerID.chk_S2T7 ?? false;
                CHK_S2T8.Checked = AlingerID.chk_S2T8 ?? false;
                CHK_S3T1.Checked = AlingerID.chk_S3T1 ?? false;
                CHK_S3T2.Checked = AlingerID.chk_S3T2 ?? false;
                CHK_S3T3.Checked = AlingerID.chk_S3T3 ?? false;
                CHK_S3T4.Checked = AlingerID.chk_S3T4 ?? false;
                CHK_S3T5.Checked = AlingerID.chk_S3T5 ?? false;
                CHK_S3T6.Checked = AlingerID.chk_S3T6 ?? false;
                CHK_S3T7.Checked = AlingerID.chk_S3T7 ?? false;
                CHK_S3T8.Checked = AlingerID.chk_S3T8 ?? false;
                CHK_S4T1.Checked = AlingerID.chk_S4T1 ?? false;
                CHK_S4T2.Checked = AlingerID.chk_S4T2 ?? false;
                CHK_S4T3.Checked = AlingerID.chk_S4T3 ?? false;
                CHK_S4T4.Checked = AlingerID.chk_S4T4 ?? false;
                CHK_S4T5.Checked = AlingerID.chk_S4T5 ?? false;
                CHK_S4T6.Checked = AlingerID.chk_S4T6 ?? false;
                CHK_S4T7.Checked = AlingerID.chk_S4T7 ?? false;
                CHK_S4T8.Checked = AlingerID.chk_S4T8 ?? false;

                btnSave.Text = "Update";
            }
            // return (new JavaScriptSerializer()).Serialize(AlingerID);
        }

        [WebMethod]
        public static void DownloadImage(string imageId)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var image = db.Alinger_Images.FirstOrDefault(ai => ai.Image_Id == Convert.ToInt32(imageId));

            if (image != null && !string.IsNullOrEmpty(image.Image_Path))
            {
                string filePath = HttpContext.Current.Server.MapPath($"~/AlingerImages/{image.Image_Path}");
                if (System.IO.File.Exists(filePath))
                {
                    HttpContext.Current.Response.ContentType = "image/jpeg"; // Adjust content type based on your image type
                    HttpContext.Current.Response.AppendHeader("Content-Disposition", $"attachment; filename={image.Image_Path}");
                    HttpContext.Current.Response.TransmitFile(filePath);
                    HttpContext.Current.Response.End();
                }
            }
        }
        [WebMethod]
        public static string LoadAlingerImages(string Alinger_Id)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var data = (from op in db.Alingers
                       join ai in db.Alinger_Images 
                        on op.Alinger_ID equals ai.Alinger_Id
                        where  op.Alinger_ID == Convert.ToInt32(Alinger_Id)
                        select new
                        {
                            Image_ID = ai.Image_Id,
                            Alinger_id = ai.Alinger_Id,
                            Image_path = ai.Image_Path
                        }).ToList();
            return (new JavaScriptSerializer().Serialize(data));
        }

        [WebMethod]
        public static string DeleteImage(string imagSrc, string Alinger_Id, string patientId, string CF_Type)
        {
            string imageFilePath = HttpContext.Current.Server.MapPath(imagSrc);

            System.IO.File.Delete(imageFilePath);
            string splitedImageFilePAth = imagSrc.Split('/')[1];
            string sql = string.Empty;
            string status = string.Empty;
            if (CF_Type == "op")
            {
                sql = "update Operation_Booking set Upper_Image_1 = null where Alinger_Id='" + Convert.ToInt32(Alinger_Id) + "' and Patient_ID='" + Convert.ToInt32(patientId) + "'";
                status = "Success_op";
            }

            if (CF_Type == "at")
            {
                sql = "update Alinger set Upper_Image_1 = null where Alinger_Id='" + Convert.ToInt32(Alinger_Id) + "' and Patient_ID='" + Convert.ToInt32(patientId) + "'";
                status = "Success_at";

            }

            DBClass.executeNonQueryWithoutBegin(sql);
            //return "Success";
            return status;
        }
        public static int OP_Count = 0;
        public static int AT_Count = 0;
        public static int CT_Count = 0;

        [WebMethod]
        public void Save(string OPCount, string ATCount, string CTCount)
        {
            OP_Count = Convert.ToInt32(OPCount);
            AT_Count = Convert.ToInt32(ATCount);
            CT_Count = Convert.ToInt32(CTCount);
     
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            db = new DataBaseDataContext(DBClass.ConnectionString());
            int Alingerid = 0;

            try
            {
                Alinger alingers = new Alinger();

                if (btnSave.Text == "Save")
                {
                    alingers.Created_by = AppConfig.UserID;
                    alingers.Created_Time = DateTime.Now;
                    db.Alingers.InsertOnSubmit(alingers);
                    db.SubmitChanges();
                    Alingerid = alingers.Alinger_ID;
                }
                else
                {
                    Alingerid = Convert.ToInt32(txtAlinger_ID.Text);
                    alingers = (from tbl in db.Alingers
                                where tbl.Alinger_ID == Alingerid
                                select tbl).FirstOrDefault();

                    alingers.Updated_By = AppConfig.UserID;
                    alingers.Updated_Time = DateTime.Now;

                    db.SubmitChanges();
                }

                alingers.Patient_ID = Convert.ToInt32(txtPatient_ID.Text);
                alingers.chk_S1T1 = CHK_S1T1.Checked;
                alingers.chk_S1T2 = CHK_S1T2.Checked;
                alingers.chk_S1T3 = CHK_S1T3.Checked;
                alingers.chk_S1T4 = CHK_S1T4.Checked;
                alingers.chk_S1T5 = CHK_S1T5.Checked;
                alingers.chk_S1T6 = CHK_S1T6.Checked;
                alingers.chk_S1T7 = CHK_S1T7.Checked;
                alingers.chk_S1T8 = CHK_S1T8.Checked;
                alingers.chk_S2T1 = CHK_S2T1.Checked;
                alingers.chk_S2T2 = CHK_S2T2.Checked;
                alingers.chk_S2T3 = CHK_S2T3.Checked;
                alingers.chk_S2T4 = CHK_S2T4.Checked;
                alingers.chk_S2T5 = CHK_S2T5.Checked;
                alingers.chk_S2T6 = CHK_S2T6.Checked;
                alingers.chk_S2T7 = CHK_S2T7.Checked;
                alingers.chk_S2T8 = CHK_S2T8.Checked;
                alingers.chk_S3T1 = CHK_S3T1.Checked;
                alingers.chk_S3T2 = CHK_S3T2.Checked;
                alingers.chk_S3T3 = CHK_S3T3.Checked;
                alingers.chk_S3T4 = CHK_S3T4.Checked;
                alingers.chk_S3T5 = CHK_S3T5.Checked;
                alingers.chk_S3T6 = CHK_S3T6.Checked;
                alingers.chk_S3T7 = CHK_S3T7.Checked;
                alingers.chk_S3T8 = CHK_S3T8.Checked;
                alingers.chk_S4T1 = CHK_S4T1.Checked;
                alingers.chk_S4T2 = CHK_S4T2.Checked;
                alingers.chk_S4T3 = CHK_S4T3.Checked;
                alingers.chk_S4T4 = CHK_S4T4.Checked;
                alingers.chk_S4T5 = CHK_S4T5.Checked;
                alingers.chk_S4T6 = CHK_S4T6.Checked;
                alingers.chk_S4T7 = CHK_S4T7.Checked;
                alingers.chk_S4T8 = CHK_S4T8.Checked;

                db.SubmitChanges();
                List<Alinger_Detail> list = db.Alinger_Details.Where(p => p.Alinger_ID == 0 ).ToList();
                foreach (Alinger_Detail med in list)
                {
                    med.Alinger_ID = alingers.Alinger_ID;
                }
                List<Crown_Bridge> lists = db.Crown_Bridges.Where(p => p.Alinger_ID == 0).ToList();
                foreach (Crown_Bridge med in lists)
                {
                    med.Alinger_ID = alingers.Alinger_ID;
                }
                List<Indirect_Veneer> listss = db.Indirect_Veneers.Where(p => p.Alinger_ID == 0).ToList();
                foreach (Indirect_Veneer med in listss)
                {
                    med.Alinger_ID = alingers.Alinger_ID;
                }
                db.SubmitChanges();
                if (fileUpload_CF_OP.HasFile)
                {
                    SaveUploadedFiles(Request.Files, Alingerid,  "OP");
                }
                //if (fileUpload_CF_AT.HasFile)
                //{
                //    SaveUploadedFiles(Request.Files, Alingerid, "AT");
                //}
                //if (fileUpload_CF_CT.HasFile)
                //{
                //    SaveUploadedFiles(Request.Files, Alingerid, "CT");
                //}

                Response.Write("Data Successfully Saved");
            }
            catch (Exception ex)
            {
                Response.Write($"Error occurred: {ex.Message}");
            }
            Response.Redirect("~/Alinger.aspx", false);
            BlankForm();
        }
        private void SaveUploadedFiles(HttpFileCollection files, int Alingerid, string fileType)
        {
            try
            {
                int fileCount = files.Count;

                for (int i = 0; i < fileCount; i++)
                {
                    HttpPostedFile file = files[i];
                    if (file != null && file.ContentLength > 0) // Ensure the file has content
                    {
                        string extension = Path.GetExtension(file.FileName).ToLower();

                        string uniqueFileName = $"Alinger-{Alingerid}-{i}-{fileType}{extension}";
                        string savePath = Server.MapPath("~/AlingerImages/") + uniqueFileName;

                        if (File.Exists(savePath))
                        {
                            File.Delete(savePath);
                        }

                        file.SaveAs(savePath);

                        // Save the file path and other details to the Alinger_Images table
                        SaveFileToAlingerImagesTable(Alingerid, uniqueFileName);
                    }
                }
            }
            catch (Exception ex)
            {
                Response.Write($"Error saving files: {ex.Message}");
            }
        }

        private void SaveFileToAlingerImagesTable(int Alingerid, string filePath)
        {
            try
            {
                Alinger_Image newImage = new Alinger_Image()
                {
                    Alinger_Id = Alingerid,
                    Image_Path = filePath
                };

                db.Alinger_Images.InsertOnSubmit(newImage);
                db.SubmitChanges();
            }
            catch (Exception ex)
            {
                // Log error for database saving failure (can log this to a separate log if needed)
                Response.Write($"Error saving image reference in database: {ex.Message}");
            }
        }
    

        public void BlankForm()
        {
          //  txtPatient_ID.Text = "";        
            vLbl_Contact.Text = "";
            vLbl_RegDate.Text = "";
            vLbl_Age.Text = "";
            vLbl_Adress.Text = "";
            vLbl_Gender.Text = "";
            vlblPatients_Name.Text = "";
            lblDpt.Text = "";
            //lblFollow.Text = "";

        }
       
        public class Alingers
        {
            public int Alingerid { get; set; }
            public int PatientID { get; set; }
            public List<AlingerDetails> AlingerList { get; set; }
        }
        public class AlingerDetails
        {
            
            public string Alinger_Details_ID { get; set; }
            public string Material { get; set; }
            public string Type_of_Alinger { get; set; }
            public string Margin_of_Alinger { set; get; }
            public string No_Of_Alinger { set; get; }
            public string Arch { get; set; }
            public string Thicker_of_Alinger { get; set; }
            public string Template_of_Alinger { get; set; }
        } 
       
        [WebMethod]
        public static void Save_Alinger(string AlingerDetails)
        {
            try
            {
                JavaScriptSerializer js = new JavaScriptSerializer();
                var AlingerDetail = js.Deserialize<Alingers>(AlingerDetails);

                using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    
                    /********************Deleting Previous 0 Value Saved Rows.***********************************/
                    List<Alinger_Detail> Alinger_DetailList = db.Alinger_Details.Where(i => i.Alinger_ID == 0 ).ToList();
                    db.Alinger_Details.DeleteAllOnSubmit(Alinger_DetailList);
                    db.SubmitChanges();

                    int couterNewRecords = 0;

                    if (AlingerDetail.Alingerid != 0)
                    {
                        /*********************Deleting Previous Entry On Every Insert Or Update*************************/
                        List<Alinger_Detail> alingerlistn = db.Alinger_Details.Where(p => p.Alinger_ID == AlingerDetail.Alingerid).ToList();
                        if (alingerlistn != null)
                        {
                            db.Alinger_Details.DeleteAllOnSubmit(alingerlistn);
                            couterNewRecords++;
                        }
                    }
                    couterNewRecords = 0;
                    /*********************Inserting New Entry On Every Insert Or Update*************************/
                    foreach (AlingerDetails oAlingerDetaile in AlingerDetail.AlingerList)
                    {
                        Alinger_Detail oAlinger_Detail1 = new Alinger_Detail()
                        {

                            Patient_Id = Convert.ToInt32(AlingerDetail.PatientID),
                            Alinger_Details_ID = Convert.ToInt32(oAlingerDetaile.Alinger_Details_ID),
                            Alinger_ID = Convert.ToInt32(AlingerDetail.Alingerid),
                            Type_of_Alinger = oAlingerDetaile.Type_of_Alinger,
                            Material = oAlingerDetaile.Material,
                            Arch = oAlingerDetaile.Arch,
                            Margin_of_Alinger = oAlingerDetaile.Margin_of_Alinger,
                         
                            Thicker_of_Alinger = oAlingerDetaile.Thicker_of_Alinger,
                            
                            Template = oAlingerDetaile.Template_of_Alinger,
                            No_Of_Alinger = oAlingerDetaile.No_Of_Alinger,


                        };
                        db.Alinger_Details.InsertOnSubmit(oAlinger_Detail1);
                        couterNewRecords++;
                    }
                    db.SubmitChanges();

                }
            }
            catch (Exception ex)
            {
            }
            //return "";
            
        }
        public class CrownBridge
        {
            public int Alingerid { get; set; }
            public int PatientID { get; set; }
            public List<CrownBridgeDetails> CrownBridgeList { get; set; }
        }
        public class CrownBridgeDetails
        {

            public string Crown_Bridges_ID { get; set; }
            public string Crown_Bridges_Name { get; set; }
        }
        [WebMethod]
        public static string Save_CrownBridges(string SymtomsList)
        {
            try
            {
                JavaScriptSerializer js = new JavaScriptSerializer();
                var data = js.Deserialize<CrownBridge>(SymtomsList);
                using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    
                    int couterNewRecords = 0;
                    /*********************Deleting Previous Entry On Every Insert Or Update*************************/
                    List<Crown_Bridge> CrownBridgeLists = db.Crown_Bridges.Where(i => i.Alinger_ID == 0).ToList();
                    db.Crown_Bridges.DeleteAllOnSubmit(CrownBridgeLists);
                    db.SubmitChanges();

                    List<Crown_Bridge> CrownBridgeList = db.Crown_Bridges.Where(p => p.Alinger_ID == data.Alingerid).ToList();
                    if (CrownBridgeList != null)
                    {
                        db.Crown_Bridges.DeleteAllOnSubmit(CrownBridgeList);
                        couterNewRecords++;
                    }
                    couterNewRecords = 0;
                    /*********************Inserting New Entry On Every Insert Or Update*************************/

                    foreach (CrownBridgeDetails oCrownBridgeDetail in data.CrownBridgeList)
                    {
                        Crown_Bridge oSysmtopm = new Crown_Bridge()
                        {
                            Alinger_ID = data.Alingerid,
                            Patient_Id = data.PatientID,
                            Crown_Bridges_Name = oCrownBridgeDetail.Crown_Bridges_Name,
                            Crown_Bridges_ID =Convert.ToInt32(oCrownBridgeDetail.Crown_Bridges_ID),
                            
                        };
                        db.Crown_Bridges.InsertOnSubmit(oSysmtopm);
                        couterNewRecords++;
                    }
                    db.SubmitChanges();
                }
            }
            catch (Exception ex)
            {

            }
            return "";
        }       
        public class IndirectVeneer
        {
            public int Alingerid { get; set; }
            public int PatientID { get; set; }
            public List<Indirect_VeneerDetails> IndirectVeneerList { get; set; }
        }
        public class Indirect_VeneerDetails
        {
            public string Indirect_Veneers_Id { get; set; }
            public string Indirect_Veneers_Name { get; set; }
        }

        [WebMethod]
        public static string Save_Indirect_Veneer(string SymtomsList)
        {
            try
            {
                JavaScriptSerializer js = new JavaScriptSerializer();
                var data = js.Deserialize<IndirectVeneer>(SymtomsList);
                using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
                {
                    /*********************Deleting Previous Entry On Every Insert Or Update*************************/
                    List<Indirect_Veneer> IndirectVeneerLists = db.Indirect_Veneers.Where(i => i.Alinger_ID == 0).ToList();
                    db.Indirect_Veneers.DeleteAllOnSubmit(IndirectVeneerLists);
                    db.SubmitChanges();

                    int couterNewRecords = 0;
                    /*********************Deleting Previous Entry On Every Insert Or Update*************************/
                    List<Indirect_Veneer> IndirectVeneerList = db.Indirect_Veneers.Where(p => p.Alinger_ID == data.Alingerid).ToList();
                    if (IndirectVeneerList != null)
                    {
                        db.Indirect_Veneers.DeleteAllOnSubmit(IndirectVeneerList);
                        couterNewRecords++;
                    }
                    couterNewRecords = 0;
                    /*********************Inserting New Entry On Every Insert Or Update*************************/

                    foreach (Indirect_VeneerDetails oSymtomsList in data.IndirectVeneerList)
                    {
                        Indirect_Veneer oSysmtopm = new Indirect_Veneer()
                        {
                            Alinger_ID = data.Alingerid,
                            Patient_Id = data.PatientID,
                            Indirect_Veneers_Name = oSymtomsList.Indirect_Veneers_Name,
                            Indirect_Veneers_Id =Convert.ToInt32(oSymtomsList.Indirect_Veneers_Id),
                            
                        };
                        db.Indirect_Veneers.InsertOnSubmit(oSysmtopm);
                        couterNewRecords++;
                    }
                    db.SubmitChanges();
                }
            }
            catch (Exception ex)
            {

            }
            return "";
        }

        [WebMethod]
        public static string LoadAlinger(int AlingerID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                List<Alinger_Detail> AlingerList = db.Alinger_Details.Where(p => p.Alinger_ID == AlingerID).ToList();
                return (new JavaScriptSerializer()).Serialize(AlingerList);
            }
            return "";
        }
        [WebMethod]
        public static string LoadVeneer(int AlingerID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                List<Indirect_Veneer> VeneerList = db.Indirect_Veneers.Where(p => p.Alinger_ID == AlingerID).ToList();
                return (new JavaScriptSerializer()).Serialize(VeneerList);
            }
            return "";
        }  
        [WebMethod]
        public static string LoadCrownBrigdes(int AlingerID)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                List<Crown_Bridge> Crown_BridgeList = db.Crown_Bridges.Where(p => p.Alinger_ID == AlingerID).ToList();
                return (new JavaScriptSerializer()).Serialize(Crown_BridgeList);
            }
            return "";
        }
        public class MasterList
        {

            public string out_Patients_Id { get; set; }
            public int patid { get; set; }
            public bool CHK_S1T1 { get; set; }
            public bool CHK_S1T2 { get; set; }
            public bool CHK_S1T3 { get; set; }
            public bool CHK_S1T4 { get; set; }
            public bool CHK_S1T5 { get; set; }
            public bool CHK_S1T6 { get; set; }
            public bool CHK_S1T7 { get; set; }
            public bool CHK_S1T8 { get; set; }
            public bool CHK_S2T1 { get; set; }
            public bool CHK_S2T2 { get; set; }
            public bool CHK_S2T3 { get; set; }
            public bool CHK_S2T4 { get; set; }
            public bool CHK_S2T5 { get; set; }
            public bool CHK_S2T6 { get; set; }
            public bool CHK_S2T7 { get; set; }
            public bool CHK_S2T8 { get; set; }
            public bool CHK_S3T1 { get; set; }
            public bool CHK_S3T2 { get; set; }
            public bool CHK_S3T3 { get; set; }
            public bool CHK_S3T4 { get; set; }
            public bool CHK_S3T5 { get; set; }
            public bool CHK_S3T6 { get; set; }
            public bool CHK_S3T7 { get; set; }
            public bool CHK_S3T8 { get; set; }
            public bool CHK_S4T1 { get; set; }
            public bool CHK_S4T2 { get; set; }
            public bool CHK_S4T3 { get; set; }
            public bool CHK_S4T4 { get; set; }
            public bool CHK_S4T5 { get; set; }
            public bool CHK_S4T6 { get; set; }
            public bool CHK_S4T7 { get; set; }
            public bool CHK_S4T8 { get; set; }
            public string fileUpload_CF_OP { get; set; }
        }
    }

    internal class Alinger_Images
    {
        public string Image_Path { get; set; }
        public int Alinger_Id { get; set; }

    }
}