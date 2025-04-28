using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Data.SqlClient;

namespace PMS
{
    public partial class OpenYear : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string year = DBClass.getField("select left(max(period_id),4) from GL_Periods where Company_ID=" + AppConfig.Company_ID);
                if (year != "There is no row at position 0." && year != "")
                    txtYear.Text = "" + (Convert.ToInt32(year) + 1);
            }
        }



        protected void btnOpenYear_Click(object sender, EventArgs e)
        {
            SqlTransaction tranObj = null;
            SqlConnection con = new SqlConnection(DBClass.ConnectionString());
            con.Open();
            tranObj = con.BeginTransaction();
            try
            {
                int year = Convert.ToInt32(txtYear.Text.Equals("") ? "0" : txtYear.Text);
                string msg = string.Empty;
                DataTable dtFiscal_Calender;
                string sSql = string.Empty;
                string monthLastDate;
                string oDate;
                sSql = "select * from Fiscal_Calender order by Fiscal_Period_ID;";
                dtFiscal_Calender = DBClass.getDataTable(sSql);
                sSql = string.Empty;
                dtFiscal_Calender.DefaultView.Sort = "Month_no ASC";
                dtFiscal_Calender = dtFiscal_Calender.DefaultView.ToTable();
                for (int i = 0; i <= dtFiscal_Calender.Rows.Count - 1; i++)
                {
                    if (Convert.ToInt32(dtFiscal_Calender.Rows[i]["Fiscal_Period_ID"]) <= 6)
                    {
                        // Jul to Dec → year - 1
                        oDate = "01-" + dtFiscal_Calender.Rows[i]["Month_name"] + "-" + year;
                        monthLastDate = PublicMethods.LastDayOfMonth(Convert.ToDateTime(oDate));

                        string checkSql = "SELECT COUNT(*) FROM GL_Periods WHERE Period_start_date = @startDate AND Period_end_date = @endDate AND Company_ID = @CompanyID";
                        SqlCommand cmd = new SqlCommand(checkSql, con, tranObj);
                        cmd.Parameters.AddWithValue("@startDate", oDate);
                        cmd.Parameters.AddWithValue("@endDate", monthLastDate);
                        cmd.Parameters.AddWithValue("@CompanyID", AppConfig.Company_ID);
                        int periodExists = (int)cmd.ExecuteScalar();

                        if (periodExists == 0)
                        {
                            sSql += " INSERT INTO GL_Periods (Period_ID,Period_start_date," +
                                    "Period_end_date,Period_Description,Period_Closed,Company_ID) " +
                                    " values('" + year + Convert.ToInt32(dtFiscal_Calender.Rows[i]["Fiscal_Period_ID"]).ToString("00") + "','" +
                                    oDate + "','" + monthLastDate + "','" +
                                    dtFiscal_Calender.Rows[i]["Month_Name"].ToString() + "-" + year + "'," +
                                    "'False'," + AppConfig.Company_ID + ");";
                        }
                    }
                    else
                    {
                        // Jan to Jun → current year
                        oDate = "01-" + dtFiscal_Calender.Rows[i]["Month_name"] + "-" + (year);
                        monthLastDate = PublicMethods.LastDayOfMonth(Convert.ToDateTime(oDate));
                        string checkSql = "SELECT COUNT(*) FROM GL_Periods WHERE Period_start_date = @startDate AND Period_end_date = @endDate AND Company_ID = @CompanyID";
                        SqlCommand cmd = new SqlCommand(checkSql, con, tranObj);
                        cmd.Parameters.AddWithValue("@startDate", oDate);
                        cmd.Parameters.AddWithValue("@endDate", monthLastDate);
                        cmd.Parameters.AddWithValue("@CompanyID", AppConfig.Company_ID);
                        int periodExists = (int)cmd.ExecuteScalar();

                        if (periodExists == 0)
                        {
                            sSql += " INSERT INTO GL_Periods (Period_ID,Period_start_date," +
                                    "Period_end_date,Period_Description,Period_Closed,Company_ID) " +
                                    " values('" + year + Convert.ToInt32(dtFiscal_Calender.Rows[i]["Fiscal_Period_ID"]).ToString("00") + "','" +
                                    "01-" + dtFiscal_Calender.Rows[i]["Month_name"] + "-" + (year) + "','" + monthLastDate + "'" +
                                    ",'" + dtFiscal_Calender.Rows[i]["Month_Name"].ToString() + "-" + (year) + "'," +
                                    "'False'," + AppConfig.Company_ID + ");";
                        }
                    }
                }


                DBClass.exectueQuery(sSql, tranObj, con);
                tranObj.Commit();
                lblMessage.CssClass = "sucessfullMessage";
                lblMessage.Text = "Year has been opened successfully.";
                btnOpenYear.Enabled = false;

            }
            catch (Exception ex)
            {
                if (tranObj != null)
                    tranObj.Rollback();
                lblMessage.Text = ex.Message;
                lblMessage.CssClass = "errorMessage";
            }

            finally
            {
                con.Close();
            }
        }


        //oldCode
        //protected void btnOpenYear_Click(object sender, EventArgs e)
        //{
        //    SqlTransaction tranObj = null;
        //    SqlConnection con = new SqlConnection(DBClass.ConnectionString());
        //    con.Open();
        //    tranObj = con.BeginTransaction();
        //    try
        //    {
        //        int year = Convert.ToInt32(txtYear.Text.Equals("") ? "0" : txtYear.Text);
        //        string msg = string.Empty;
        //        DataTable dtFiscal_Calender;
        //        string sSql = string.Empty;
        //        string monthLastDate;
        //        string oDate;
        //        sSql = "select * from Fiscal_Calender order by Fiscal_Period_ID;";
        //        dtFiscal_Calender = DBClass.getDataTable(sSql);
        //        sSql = string.Empty;
        //        for (int i = 0; i <= dtFiscal_Calender.Rows.Count - 1; i++)
        //        {
        //            if (Convert.ToInt32(dtFiscal_Calender.Rows[i]["Fiscal_Period_ID"]) <= 6 && Convert.ToInt32(dtFiscal_Calender.Rows[i]["Month_no"]) >= 6)
        //            {
        //                oDate = "01-" + dtFiscal_Calender.Rows[i]["Month_name"] + "-" + (year - 1);
        //                monthLastDate = PublicMethods.LastDayOfMonth(Convert.ToDateTime(oDate));

        //                string checkSql = "SELECT COUNT(*) FROM GL_Periods WHERE Period_start_date = @startDate AND Period_end_date = @endDate AND Company_ID = @CompanyID";
        //                SqlCommand cmd = new SqlCommand(checkSql, con, tranObj);
        //                cmd.Parameters.AddWithValue("@startDate", oDate);
        //                cmd.Parameters.AddWithValue("@endDate", monthLastDate);
        //                cmd.Parameters.AddWithValue("@CompanyID", AppConfig.Company_ID);
        //                int periodExists = (int)cmd.ExecuteScalar();

        //                if (periodExists == 0)
        //                {


        //                    sSql += " INSERT INTO GL_Periods (Period_ID,Period_start_date," +
        //                        "Period_end_date,Period_Description,Period_Closed,Company_ID)" +
        //                        " values('" + year + Convert.ToInt32(dtFiscal_Calender.Rows[i]["Fiscal_Period_ID"]).ToString("00") + "','" +
        //                        "01-" + dtFiscal_Calender.Rows[i]["Month_name"] + "-" + (year - 1) + "','" + monthLastDate + "'" +
        //                        ",'" + dtFiscal_Calender.Rows[i]["Month_Name"].ToString() + "-" + (year - 1) + "'," +
        //                        "'False'," + AppConfig.Company_ID + ");";
        //                }
        //            }
        //            else
        //            {
        //                oDate = "01-" + dtFiscal_Calender.Rows[i]["Month_name"] + "-" + (year);
        //                monthLastDate = PublicMethods.LastDayOfMonth(Convert.ToDateTime(oDate));
        //                string checkSql = "SELECT COUNT(*) FROM GL_Periods WHERE Period_start_date = @startDate AND Period_end_date = @endDate AND Company_ID = @CompanyID";
        //                SqlCommand cmd = new SqlCommand(checkSql, con, tranObj);
        //                cmd.Parameters.AddWithValue("@startDate", oDate);
        //                cmd.Parameters.AddWithValue("@endDate", monthLastDate);
        //                cmd.Parameters.AddWithValue("@CompanyID", AppConfig.Company_ID);
        //                int periodExists = (int)cmd.ExecuteScalar();

        //                if (periodExists == 0)
        //                {


        //                    sSql += " INSERT INTO GL_Periods (Period_ID,Period_start_date," +
        //                            "Period_end_date,Period_Description,Period_Closed,Company_ID) " +
        //                            " values('" + year + Convert.ToInt32(dtFiscal_Calender.Rows[i]["Fiscal_Period_ID"]).ToString("00") + "','" +
        //                            "01-" + dtFiscal_Calender.Rows[i]["Month_name"] + "-" + (year) + "','" + monthLastDate + "'" +
        //                            ",'" + dtFiscal_Calender.Rows[i]["Month_Name"].ToString() + "-" + (year) + "'," +
        //                            "'False'," + AppConfig.Company_ID + ");";
        //                }
        //            }
        //        }
        //        DBClass.exectueQuery(sSql, tranObj, con);
        //        tranObj.Commit();
        //        lblMessage.CssClass = "sucessfullMessage";
        //        lblMessage.Text = "Year has been opened successfully.";
        //        btnOpenYear.Enabled = false;

        //    }
        //    catch (Exception ex)
        //    {
        //        if (tranObj != null)
        //            tranObj.Rollback();
        //        lblMessage.Text = ex.Message;
        //        lblMessage.CssClass = "errorMessage";
        //    }

        //    finally
        //    {
        //        con.Close();
        //    }
        //}
        protected void btnReload_Click(object sender, EventArgs e)
        {
            Response.Redirect(Request.RawUrl);
        }
    }
}