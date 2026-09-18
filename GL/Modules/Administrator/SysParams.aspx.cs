using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Script.Serialization;
using System.Web.Services;

namespace PMS
{
    public partial class SysParams : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadData();
            }
        }
        public void LoadData()
        {
            txt_inpatient_fee.Text = LoadParametersData("In Patient Fee");
            txtopdfee.Text = LoadParametersData("OPD Fee");
            txt_emergecny_fee.Text = LoadParametersData("Emergency Fee");
            txtGLCashAccount.Text = LoadParametersData("GL_Cash_Account");
            txtDentalShare.Text = LoadParametersData("Dental_Share");
            txtRadialogyShare.Text = LoadParametersData("Radialogy_Share");
            txtPhysioShare.Text = LoadParametersData("Physio_Share");
            txtDentalSharePercentage.Text = LoadParametersData("Dental_Share_Percentage");
            txtRadialogySharePercentage.Text = LoadParametersData("Radialogy_Share_Percentage");
            txtPhysioSharePercentage.Text = LoadParametersData("Physio_Share_Percentage");
            txtLabAndRadiologyCharges_GeneralAccount.Text = LoadParametersData("LabAndRadiologyCharges_GeneralAccount");
            txtLabAndRadiologyCharges_PrivateAccount.Text = LoadParametersData("LabAndRadiologyCharges_PrivateAccount");
            txtDermaShare.Text = LoadParametersData("Derma_Share");
            txtDermaSharePercentage.Text = LoadParametersData("Derma_Share_Percentage");
            txtReceivableAccount.Text = LoadParametersData("Receivable_Account");
            txtMiscellenousIncomeAccount.Text = LoadParametersData("Miscelleneous_Income_Account");
            txtMiscellenousLossAccount.Text = LoadParametersData("Miscelleneous_Loss_Account");
            txtPatientCardAmount.Text = LoadParametersData("Patient Card No");

            txtDI_PostUrl.Text = LoadParam("FBR_DI_PostUrl", "https://gw.fbr.gov.pk/di_data/v1/di/postinvoicedata_sb");
            txtDI_ValidateUrl.Text = LoadParam("FBR_DI_ValidateUrl", "https://gw.fbr.gov.pk/di_data/v1/di/validateinvoicedata_sb");
            txtDI_Token.Text = LoadParam("FBR_DI_Token");
            txtDI_SellerNTN.Text = LoadParam("FBR_DI_SellerNTN");
            txtDI_SellerName.Text = LoadParam("FBR_DI_SellerName");
            txtDI_SellerProvince.Text = LoadParam("FBR_DI_SellerProvince");
            txtDI_SellerAddress.Text = LoadParam("FBR_DI_SellerAddress");
            txtDI_RegistrationType.Text = LoadParam("FBR_DI_RegistrationType", "Registered");
            txtDI_ScenarioId.Text = LoadParam("FBR_DI_ScenarioId", "SN001");
            txtDI_InvoiceType.Text = LoadParam("FBR_DI_InvoiceType", "Sale Invoice");
            txtDI_Rate.Text = LoadParam("FBR_DI_Rate", "18%");
            txtDI_SaleType.Text = LoadParam("FBR_DI_SaleType", "Services at standard rate");
        }

        public void Save()
        {
            SaveData("In Patient Fee", txt_inpatient_fee.Text.Trim());
            SaveData("OPD Fee", txtopdfee.Text.Trim());
            SaveData("Emergency Fee", txt_emergecny_fee.Text.Trim());
            SaveData("GL_Cash_Account", txtGLCashAccount.Text);
            SaveData("Dental_Share", txtDentalShare.Text);
            SaveData("Radialogy_Share", txtRadialogyShare.Text);
            SaveData("Physio_Share", txtPhysioShare.Text);
            SaveData("Dental_Share_Percentage", txtDentalSharePercentage.Text);
            SaveData("Radialogy_Share_Percentage", txtRadialogySharePercentage.Text);
            SaveData("Physio_Share_Percentage", txtPhysioSharePercentage.Text);
            SaveData("LabAndRadiologyCharges_GeneralAccount", txtLabAndRadiologyCharges_GeneralAccount.Text);
            SaveData("LabAndRadiologyCharges_PrivateAccount", txtLabAndRadiologyCharges_PrivateAccount.Text);
            SaveData("Derma_Share", txtDermaShare.Text);
            SaveData("Derma_Share_Percentage", txtDermaSharePercentage.Text);
            SaveData("Receivable_Account", txtReceivableAccount.Text);
            SaveData("Miscelleneous_Income_Account", txtMiscellenousIncomeAccount.Text);
            SaveData("Miscelleneous_Loss_Account", txtMiscellenousLossAccount.Text);
            SaveData("Patient Card No", txtPatientCardAmount.Text);

            SaveParam("FBR_DI_PostUrl", txtDI_PostUrl.Text.Trim());
            SaveParam("FBR_DI_ValidateUrl", txtDI_ValidateUrl.Text.Trim());
            SaveParam("FBR_DI_Token", txtDI_Token.Text.Trim());
            SaveParam("FBR_DI_SellerNTN", txtDI_SellerNTN.Text.Trim());
            SaveParam("FBR_DI_SellerName", txtDI_SellerName.Text.Trim());
            SaveParam("FBR_DI_SellerProvince", txtDI_SellerProvince.Text.Trim());
            SaveParam("FBR_DI_SellerAddress", txtDI_SellerAddress.Text.Trim());
            SaveParam("FBR_DI_RegistrationType", txtDI_RegistrationType.Text.Trim());
            SaveParam("FBR_DI_ScenarioId", txtDI_ScenarioId.Text.Trim());
            SaveParam("FBR_DI_InvoiceType", txtDI_InvoiceType.Text.Trim());
            SaveParam("FBR_DI_Rate", txtDI_Rate.Text.Trim());
            SaveParam("FBR_DI_SaleType", txtDI_SaleType.Text.Trim());
        }

        public string LoadParam(string ParameterName, string DefaultValue = "")
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var p = db.sys_Parms.FirstOrDefault(x => x.Name == ParameterName && x.Company_ID == AppConfig.Company_ID);
                if (p == null || string.IsNullOrEmpty(p.Segment1))
                    return DefaultValue;
                return p.Segment1;
            }
        }

        public void SaveParam(string ParameterName, string ParameterValue)
        {
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                var p = db.sys_Parms.FirstOrDefault(x => x.Name == ParameterName && x.Company_ID == AppConfig.Company_ID);
                if (p == null)
                {
                    p = new sys_Parm();
                    p.Name = ParameterName;
                    p.Company_ID = AppConfig.Company_ID;
                    db.sys_Parms.InsertOnSubmit(p);
                }
                p.Segment1 = ParameterValue;
                db.SubmitChanges();
            }
        }

        public void SaveData(string ParameterName, string ParameterValue)
        {
            DBClass.executeNonQueryWithoutBegin("update sys_Parms set code='" + ParameterValue + "' where name='" + ParameterName + "'");
        }

        public string LoadParametersData(string ParameterName)
        {
            return DBClass.getParameter(ParameterName).ToString();
        }

        [WebMethod]
        public static void SaveLiabilities(string data)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            JavaScriptSerializer js = new JavaScriptSerializer();
            var dta = js.Deserialize<AccountCategory>(data);

            foreach (AccountsList item in dta.AccountsList)
            {
                sys_Parm osys_Parm_Detail = new sys_Parm();
                osys_Parm_Detail.Name = item.Name;
                osys_Parm_Detail.Segment1 = item.Department;
                osys_Parm_Detail.Segment2 = item.Type;
                if (item.Code.ToString() != "")
                    osys_Parm_Detail.Code = item.Code;
                osys_Parm_Detail.Segment3 = "Is Liability Account";
                osys_Parm_Detail.Company_ID = AppConfig.Company_ID;
                db.sys_Parms.InsertOnSubmit(osys_Parm_Detail);
            }

            // Deleting previously saved accountns....

            var details = db.sys_Parms.Where(a => a.Segment3 == "Is Liability Account").ToList();

            if (details.Count > 0)
            {
                db.sys_Parms.DeleteAllOnSubmit(details);
            }
            db.SubmitChanges();
        }

        [WebMethod]
        public static void SaveIncomes(string data)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            JavaScriptSerializer js = new JavaScriptSerializer();
            var dta = js.Deserialize<AccountCategory>(data);

            foreach (AccountsList item in dta.AccountsList)
            {
                sys_Parm osys_Parm_Detail = new sys_Parm();
                //osys_Parm_Detail.Name = item.Name;
                osys_Parm_Detail.Segment1 = item.Department;
                osys_Parm_Detail.Segment2 = item.Type;
                if (item.Code.ToString() != "")
                    osys_Parm_Detail.Code = item.Code;
                osys_Parm_Detail.Segment3 = "Is Income Account";
                osys_Parm_Detail.Company_ID = AppConfig.Company_ID;
                db.sys_Parms.InsertOnSubmit(osys_Parm_Detail);
            }

            // Deleting previously saved accountns....

            var details = db.sys_Parms.Where(a => a.Segment3 == "Is Income Account").ToList();

            if (details.Count > 0)
            {
                db.sys_Parms.DeleteAllOnSubmit(details);
            }
            db.SubmitChanges();
        }

        public class AccountsList
        {
            public string Department { get; set; }
            public string Name { get; set; }
            public string Type { get; set; }
            public string Code { get; set; }
        }
        public class AccountCategory
        {
            public List<AccountsList> AccountsList { get; set; }
            public int CategoryID { get; set; }
            public string CategoryName { get; set; }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            Save();
        }

        [WebMethod]
        public static List<DataValues> GetDepartments()
        {
            DataBaseDataContext db = new DataBaseDataContext();

            var depts = (from d in db.DataValues
                         join v in db.ValueSets
                         on d.ValueSet_ID equals v.ValueSet_ID
                         where v.ValueSet_Name == "Patient Main Category"
                         select d).ToList();
            List<DataValues> list = new List<DataValues>();
            foreach (var item in depts)
            {
                DataValues dv = new DataValues();
                dv.DataValueName = item.DataValue_Name;
                dv.DataValueDescription = item.DataValue_Description;
                list.Add(dv);
            }
            return list;
        }

        public class DataValues
        {
            public string DataValueName { get; set; }
            public string DataValueDescription { get; set; }
        }

        [WebMethod]
        public static List<INV_Item> GetLiabilities()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            List<INV_Item> itemsList = (from itms in db.INV_Items
                                        where itms.Liability_Item == true
                                        select itms).ToList();
            return itemsList;
        }
        [WebMethod]
        public static string GetPatientTypes()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var dvsList = (from d in db.DataValues
                           join v in db.ValueSets
                           on d.ValueSet_ID equals v.ValueSet_ID
                           where v.ValueSet_Name == "Patient Type"
                           select new { d.DataValue_Name, d.DataValue_Description }).ToList();
            return (new JavaScriptSerializer()).Serialize(dvsList);
        }

        [WebMethod]
        public static List<sys_Parm> GetAccounts(string Type)
        {
            DataBaseDataContext db = new DataBaseDataContext();
            List<sys_Parm> details = db.sys_Parms.Where(a => a.Segment3 == Type).ToList();
            return details;
        }

        static List<GL_Account> glAccList;
        [WebMethod]
        public static bool ValidateAccount(string AccountCode)
        {
            if (glAccList == null)
            {
                DataBaseDataContext db = new DataBaseDataContext();
                glAccList = db.GL_Accounts.Where(acc => acc.Levels == 4).ToList();
            }

            GL_Account ga = glAccList.Where(a => a.Account_Code == AccountCode).FirstOrDefault();
            if (ga != null)
                return true;
            else
                return false;
        }

        #region "Go Through All Form Controls"

        public void LoadParameters(ControlCollection cntrls)
        {
            //foreach (Control ctrl in cntrls)
            //{
            //    if (ctrl is TextBox)
            //    {
            //        ((TextBox)ctrl).Text = LoadParametersData(((TextBox)ctrl).ID.ToString());
            //    }
            //    if (ctrl is DropDownList)
            //    {
            //        ((DropDownList)ctrl).SelectedValue = LoadParametersData(((DropDownList)ctrl).ID.ToString());
            //    }
            //    if (ctrl is CheckBox)
            //    {
            //        ((CheckBox)ctrl).Checked = LoadParametersData(((CheckBox)ctrl).ID.ToString()) == "True" ? true : false;
            //    }

            //    LoadParameters(ctrl.Controls);
            //}        
        }

        public void SaveChanges(ControlCollection cntrls)
        {
            //foreach (Control ctrl in cntrls)
            //{
            //    if (ctrl is TextBox)
            //    {
            //        SaveData(((TextBox)ctrl).ID.ToString(), ((TextBox)ctrl).Text.ToString());
            //    }
            //    if (ctrl is DropDownList)
            //    {
            //        SaveData(((DropDownList)ctrl).ID.ToString(), ((DropDownList)ctrl).SelectedValue.ToString());
            //    }
            //    if (ctrl is CheckBox)
            //    {
            //        SaveData(((CheckBox)ctrl).ID.ToString(), ((CheckBox)ctrl).Checked.ToString());
            //    }

            //    SaveChanges(ctrl.Controls);
            //}

        }

        //protected void btnSave_Click(object sender, EventArgs e)
        //{
        //    //SaveChanges(Page.Controls);
        //    //LoadParameters(Page.Controls);   
        //    Save();
        //    Load(); 
        //}

        #endregion
    }
}

