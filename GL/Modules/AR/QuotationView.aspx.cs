using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class WebForm8 : System.Web.UI.Page
    {
        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);


            string qury = "SELECT  Quotation_No, Quotation_ID, Convert(Varchar(11),Quotation_Date,106) as Quotation_Date, Ref_No,Customer_Name,AR_Quotations.Remarks,Quotation_Status,Quotation_Amount " +
                            " FROM AR_Quotations "+
                            " inner join Ar_Customers "+
                                 " ON Ar_Customers.Customer_ID =AR_Quotations.Customer_ID";
               
            sqlList.SelectCommand = qury;
                this.sqlList.ConnectionString = DBClass.ConnectionString();
            
        }
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        protected void btnNew_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/AR/Quotation.aspx");
        }
    }
}