using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.GL
{
    public partial class Inv_OriginatorTempelates : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!this.IsPostBack)
            {
                this.PopulatePurchases();
                this.PopulateInventory();
                this.PopulateAccountpayble();
            }
        }
        private void PopulatePurchases()
        {
            string query = "SELECT Form_ID, Form_Name FROM Sys_Forms Where IsListed=1 and IsDeleted=0 and Head_Name='Purchase';";
            string constr = ConfigurationManager.ConnectionStrings["ASPGLConnectionString"].ConnectionString;
            using (SqlConnection con = new SqlConnection(constr))
            {
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    con.Open();
                    using (SqlDataReader sdr = cmd.ExecuteReader())
                    {
                        int index = 0;
                        while (sdr.Read())
                        {
                            // Generate Generic Purchase hidden field for each Form_ID
                            HiddenField hiddenField = new HiddenField();
                            hiddenField.ID = "PurchasehidFormID_" + index;
                            hiddenField.Value = sdr["Form_ID"].ToString();
                            PurchasehiddenFieldsContainer.Controls.Add(hiddenField);

                            ListItem item = new ListItem();
                            item.Text = sdr["Form_Name"].ToString();
                            item.Value = sdr["Form_ID"].ToString();
                            chkPurchases.Items.Add(item);
                            index++;
                        }
                    }
                    con.Close();
                }
            }
        }

        private void PopulateInventory()
        {
            string query = "SELECT Form_ID, Form_Name FROM Sys_Forms Where IsListed=1 and IsDeleted=0 and Head_Name='Inventory';";
            string constr = ConfigurationManager.ConnectionStrings["ASPGLConnectionString"].ConnectionString;
            using (SqlConnection con = new SqlConnection(constr))
            {
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    con.Open();
                    using (SqlDataReader sdr = cmd.ExecuteReader())
                    {
                        int index = 0;
                        while (sdr.Read())
                        {
                            // Generate Generic Purchase hidden field for each Form_ID
                            HiddenField hiddenField = new HiddenField();
                            hiddenField.ID = "InventoryhidFormID_" + index;
                            hiddenField.Value = sdr["Form_ID"].ToString();
                            InventoryhiddenFieldsContainer.Controls.Add(hiddenField);

                            ListItem item = new ListItem();
                            item.Text = sdr["Form_Name"].ToString();
                            item.Value = sdr["Form_ID"].ToString();
                            chkInventory.Items.Add(item);
                            index++;
                        }
                    }
                    con.Close();
                }
            }
        }

        private void PopulateAccountpayble()
        {
            string query = "SELECT Form_ID, Form_Name FROM Sys_Forms Where IsListed=1 and IsDeleted=0 and Head_Name='Account Payable';";
            string constr = ConfigurationManager.ConnectionStrings["ASPGLConnectionString"].ConnectionString;
            using (SqlConnection con = new SqlConnection(constr))
            {
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    con.Open();
                    using (SqlDataReader sdr = cmd.ExecuteReader())
                    {
                        int index = 0;
                        while (sdr.Read())
                        {
                            // Generate Generic Account Payable hidden field for each Form_ID
                            HiddenField hiddenField = new HiddenField();
                            hiddenField.ID = "AccountPayablehidFormID_" + index;
                            hiddenField.Value = sdr["Form_ID"].ToString();
                            AccountPayablehiddenFieldsContainer.Controls.Add(hiddenField);

                            ListItem item = new ListItem();
                            item.Text = sdr["Form_Name"].ToString();
                            item.Value = sdr["Form_ID"].ToString();
                            chkAccountPayable.Items.Add(item);
                            index++;
                        }
                    }
                    con.Close();
                }
            }
        }
        [WebMethod]
        public static string Save(string btnValue, string id, string txttempelateName, string txttempelateDescription, bool chkIsActive, string[][] UserDetail, string[] CheckedPurchasesFormIDs, string[] CheckedPurchasesCheckBoxIDs, string[] CheckedInventoryFormIDs, string[] CheckedInventoryCheckBoxIDs, string[] CheckedAccountPayableFormIDs, string[] CheckedAccountPayableCheckBoxIDs)
        {
            int lstid = 0;
            Sys_Inv_OrignatorTempelate_Master apptemp;
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            if (btnValue == "Save")
            {
                apptemp = new Sys_Inv_OrignatorTempelate_Master();
            }
            else
            {
                apptemp = (from tbl in db.Sys_Inv_OrignatorTempelate_Masters
                           where tbl.OrignatorTempelate_ID == Convert.ToInt32(id)
                           select tbl).FirstOrDefault();
                apptemp.OrignatorTempelate_Name = txttempelateName;
                apptemp.OrignatorTempelate_Description = txttempelateDescription;
                apptemp.IsActive = Convert.ToBoolean(chkIsActive);
                apptemp.Updated_By = AppConfig.UserID;
                apptemp.Updated_Date = DateTime.Now;
                db.SubmitChanges();
            }
            if (btnValue == "Save")
            {
                apptemp.OrignatorTempelate_Name = txttempelateName;
                apptemp.OrignatorTempelate_Description = txttempelateDescription;
                apptemp.IsActive = Convert.ToBoolean(chkIsActive);
                apptemp.Creation_Date = DateTime.Now;
                apptemp.Created_By = AppConfig.UserID;
                apptemp.Company_ID = AppConfig.Company_ID;
                apptemp.IsDeleted = false;
                db.Sys_Inv_OrignatorTempelate_Masters.InsertOnSubmit(apptemp);
                db.SubmitChanges();
            }
            else
            {
                string sqlorignator = "Delete from Sys_Inv_OrignatorTempelate_Detail where OrignatorTempelate_ID = " + apptemp.OrignatorTempelate_ID + "";
                DBClass.executeNonQueryWithoutBegin(sqlorignator);

                string sqlforms = "Delete from Sys_Inv_OrignatorTempelate_Detail_Forms where OrignatorTempelate_ID = " + apptemp.OrignatorTempelate_ID + "";
                DBClass.executeNonQueryWithoutBegin(sqlforms);
            }

            for (int i = 1; i < UserDetail.Length; i++)
            {
                Sys_Inv_OrignatorTempelate_Detail aporignator = new Sys_Inv_OrignatorTempelate_Detail();
                aporignator.OrignatorTempelate_ID = apptemp.OrignatorTempelate_ID;
                var a = UserDetail[i][0].ToString();
                if (Guid.TryParse(UserDetail[i][0], out Guid userId))
                {
                    aporignator.UserId = userId;
                }
                db.Sys_Inv_OrignatorTempelate_Details.InsertOnSubmit(aporignator);
            }
            for (int i = 0; i < CheckedPurchasesFormIDs.Length; i++)
            {
                Sys_Inv_OrignatorTempelate_Detail_Form apforms = new Sys_Inv_OrignatorTempelate_Detail_Form();
                apforms.OrignatorTempelate_ID = apptemp.OrignatorTempelate_ID;
                var a = CheckedPurchasesCheckBoxIDs[i].ToString();
                apforms.CheckBoxId = CheckedPurchasesCheckBoxIDs[i].ToString();
                apforms.FormId = Convert.ToInt32(CheckedPurchasesFormIDs[i].ToString());
                db.Sys_Inv_OrignatorTempelate_Detail_Forms.InsertOnSubmit(apforms);
            }
            for (int i = 0; i < CheckedInventoryFormIDs.Length; i++)
            {
                Sys_Inv_OrignatorTempelate_Detail_Form apforms = new Sys_Inv_OrignatorTempelate_Detail_Form();
                apforms.OrignatorTempelate_ID = apptemp.OrignatorTempelate_ID;
                var a = CheckedInventoryCheckBoxIDs[i].ToString();
                apforms.CheckBoxId = CheckedInventoryCheckBoxIDs[i].ToString();
                apforms.FormId = Convert.ToInt32(CheckedInventoryFormIDs[i].ToString());
                db.Sys_Inv_OrignatorTempelate_Detail_Forms.InsertOnSubmit(apforms);
            }
            for (int i = 0; i < CheckedAccountPayableFormIDs.Length; i++)
            {
                Sys_Inv_OrignatorTempelate_Detail_Form apforms = new Sys_Inv_OrignatorTempelate_Detail_Form();
                apforms.OrignatorTempelate_ID = apptemp.OrignatorTempelate_ID;
                var a = CheckedAccountPayableCheckBoxIDs[i].ToString();
                apforms.CheckBoxId = CheckedAccountPayableCheckBoxIDs[i].ToString();
                apforms.FormId = Convert.ToInt32(CheckedAccountPayableFormIDs[i].ToString());
                db.Sys_Inv_OrignatorTempelate_Detail_Forms.InsertOnSubmit(apforms);
            }            

            db.SubmitChanges();
            if (btnValue == "Save")
            {
                lstid = apptemp.OrignatorTempelate_ID;
            }
            else
            {
                lstid = Convert.ToInt32(id);
            }
            return lstid.ToString();
        }

        [WebMethod]
        public static string LoadMasterData(string id)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            var query = (from data in db.Sys_Inv_OrignatorTempelate_Masters.Where(x => x.OrignatorTempelate_ID == Convert.ToInt32(id)) select data).FirstOrDefault();
            return (new JavaScriptSerializer()).Serialize(query);
        }
        [WebMethod]
        public static string LoadOriginators(int id)
        {
            List<string> detail = new List<string>();
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                detail = (from m in db.Sys_Inv_OrignatorTempelate_Details
                          where m.OrignatorTempelate_ID == id
                          select m.UserId.ToString()).ToList();
            }
            return (new JavaScriptSerializer()).Serialize(detail);
        }
        [WebMethod]
        public static string LoadFormIds(int id)
        {
            List<string> detail = new List<string>();
            using (DataBaseDataContext db = new DataBaseDataContext())
            {
                detail = (from m in db.Sys_Inv_OrignatorTempelate_Detail_Forms
                          where m.OrignatorTempelate_ID == id
                          select m.CheckBoxId.ToString()).ToList();
            }
            return (new JavaScriptSerializer()).Serialize(detail);
        }      
        [WebMethod]
        public static string loadUser()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var listItems = (from a in db.aspnet_Users
                             select new
                             {
                                 a.UserId,
                                 a.UserName
                             }).ToList();

            return (new JavaScriptSerializer()).Serialize(listItems);
        }
    }
}