using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;

namespace PMS
{
    public partial class WebForm1 : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        

        protected void btn1_Click(object sender, EventArgs e)
        {
        //{
        //    DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());

        //    var qry = from t in db.Temp_Tables
        //              select t;
        //    db.Temp_Tables.DeleteAllOnSubmit(qry);

        //    for (int i = 100; i < 500; i++)
        //    {
        //        Temp_Table tbl = new Temp_Table();
        //        tbl.Description = i.ToString();
        //        db.Temp_Tables.InsertOnSubmit(tbl);                
        //    }

        //    var qry2 = from t in db.Temp_Table2s
        //               select t;
        //    db.Temp_Table2s.DeleteAllOnSubmit(qry2);

        //    for (int i = 100; i < 500; i++)
        //    {
        //        Temp_Table2 tbl = new Temp_Table2();
        //        tbl.Temp_ID2 = i.ToString();
        //        //db.Temp_Table2s.InsertOnSubmit(tbl);
        //    }

        //    db.SubmitChanges();
        }

        protected void btnToggleCheckBox_Click(object sender, EventArgs e)
        {
            bool isCheck = checkbox1.Checked;
            checkbox1.Checked = !isCheck;
        }
    }
}