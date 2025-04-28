using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Net;
using System.Data.SqlClient;

using System.Web.Services;

namespace PMS
{
    public partial class Doctor_Apointment : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            txtAppointmentDate.Text = DateTime.Today.ToString("M/dd/yyyy");
        }


        public string LookupResultsToOption(List<KeyValuePair<int, string>> data)
        {
            StringBuilder html = new StringBuilder();
            foreach (KeyValuePair<int, string> kvp in data)
            {
                html.Append("<option value=\"" + kvp.Key.ToString() + "\">" + kvp.Value + "</option>");
            }
            return html.ToString();
        }
        public List<KeyValuePair<int, string>> GetWareHouse(string type)
        {
            List<KeyValuePair<int, string>> data = new List<KeyValuePair<int, string>>();


            SqlConnection cnn = new SqlConnection(DBClass.ConnectionString());
            SqlCommand cmd = new SqlCommand("select dv.* from ValueSet vs, DataValues dv where vs.ValueSet_ID = dv.ValueSet_ID and vs.ValueSet_Name=@type order by DataValue_Name ASC", cnn);
            cmd.Parameters.AddWithValue("@type", type);

            cnn.Open();
            SqlDataReader res = cmd.ExecuteReader();
            if (res.HasRows)
            {
                while (res.Read())
                {
                    if (res["DataValue_Name"] != DBNull.Value)
                    {
                        KeyValuePair<int, string> kvp = new KeyValuePair<int, string>((int)res["DataValue_ID"], (string)res["DataValue_Description"]);
                        data.Add(kvp);
                    }
                }
            }
            res.Close();
            cnn.Close();

            return data;
        }
    }
        //public static int AddHeader(string type, string warehouse, DateTime reqDate, string reqclass, string department, string status, string reqtype, string totalamount, string remarks)
        //{
        //    DataBaseDataContext db = new DataBaseDataContext();
        //    if (type == "Save")
        //    {
        //        Doctor_Apointment list = new Doctor_Apointment();

        //        list.Created_By = AppConfig.UserID;
        //        list.Creation_Date = DateTime.Now;
        //        list.Book_ID = AppConfig.Book_ID;
        //        list.Company_ID = AppConfig.Company_ID;

        //        list.Ware_House = warehouse;
        //        list.Requisition_Date = reqDate;

        //        list.Requisition_Type = reqtype;

        //        list.Requisition_Class = reqclass;
        //        Reqlist.Department = department;
        //        Reqlist.Status = status;

        //        Reqlist.Total_Amount = Convert.ToDecimal(totalamount);
        //        Reqlist.Remarks = remarks;
        //        db.Inv_Requisition_Requests.InsertOnSubmit(Reqlist);
        //        db.SubmitChanges();
        //        int idd = Reqlist.Requisition_No;
        //        return idd;
        //    }
        //    else
        //    {
        //        var data = (from tbl in db.Inv_Requisition_Requests
        //                    where tbl.Requisition_No == ReqNo
        //                    select tbl).FirstOrDefault();
        //        data.Last_Update_By = AppConfig.UserID;
        //        data.Last_Update_Date = DateTime.Now;

        //        data.Book_ID = AppConfig.Book_ID;
        //        data.Company_ID = AppConfig.Company_ID;
        //        data.Ware_House = warehouse;
        //        data.Requisition_Date = reqDate;
        //        data.Requisition_Type = reqtype;
        //        data.Requisition_Class = reqclass;
        //        data.Department = department;
        //        data.Status = status;
        //        data.Total_Amount = Convert.ToDecimal(totalamount);
        //        data.Remarks = remarks;
        //        db.SubmitChanges();
        //        return ReqNo;
        //    }
        //}
    
}