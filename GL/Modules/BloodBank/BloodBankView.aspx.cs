
using Infragistics.Web.UI.GridControls;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Runtime.Remoting.Contexts;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class BloodBankView : System.Web.UI.Page
    {


        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    var Total_Blood_Bank = _dbContext.Blood_Banks.Count();
                    var Blood_Bank = from bb in _dbContext.Blood_Banks
                                     join pat in _dbContext.Patients on bb.Patient_ID equals pat.Patient_ID into patJoin
                                     from pat in patJoin.DefaultIfEmpty()
                                     where (bb.isCancel == false || bb.isCancel == null) &&
                                           (bb.Blood_ID.ToString().Contains(searchValue) || _dbContext.GetDataValueName("ABO group", bb.Blood_Group).Contains(searchValue) || pat.mr_no_sequence.ToString().Contains(searchValue))
                                     select new
                                         {
                                             Blood_ID = bb.Blood_ID,
                                             Receiving_Date = bb.Receiving_Date,
                                             Blood_Group = _dbContext.GetDataValueName("ABO group", bb.Blood_Group),
                                             RH_Type = bb.RH_Type == "01" ? "Positive" : bb.RH_Type == "02" ? "Negative" : "",
                                             Empty_Bag_Status = bb.Received_Bag == true ? "Yes" : bb.Received_Bag == false ? "No" : "No",
                                             Blood_Issuance_Date_Time = bb.Updated_Time,
                                             No_Of_Bags = bb.No_Of_Bags,
                                             Expiry_Date = bb.Expiry_Date,
                                             Patient_Name = pat.Full_Name,
                                             Bag_No = bb.Bag_No,
                                             Mrno = pat.mr_no_sequence
                                         };



                    var FilteredCount = Blood_Bank.Count();
                    switch (sortColumn)
                    {
                        case "Mrno":
                            Blood_Bank = sortColumnDirection == "asc" ? Blood_Bank.OrderBy(a => a.Mrno) : Blood_Bank.OrderByDescending(a => a.Mrno);
                            break;
                        case "Receiving_Date":
                            Blood_Bank = sortColumnDirection == "asc" ? Blood_Bank.OrderBy(a => a.Receiving_Date) : Blood_Bank.OrderByDescending(a => a.Receiving_Date);
                            break;
                        default:
                            Blood_Bank = Blood_Bank.OrderByDescending(a => a.Blood_ID);
                            break;
                    }


                    var Blood_Bank_List = Blood_Bank.Skip(start).Take(length).ToList();


                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Blood_Bank, data = Blood_Bank_List };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Blood Bank list", ex);
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {

        }

        //protected void whdgList_ItemCommand(object sender, Infragistics.Web.UI.GridControls.HandleCommandEventArgs e)
        //{

        //    if (e.CommandName == "Remove")
        //    {
        //        SqlTransaction tranObj = null;
        //        SqlConnection con = new SqlConnection(DBClass.ConnectionString());
        //        con.Open();
        //        tranObj = con.BeginTransaction();
        //        try
        //        {

        //            bool rowDeleted = DBClass.exectueQuery("Delete Blood_Bank Where Blood_ID=" + Convert.ToInt32(e.CommandArgument) + "", tranObj, con);
        //            if (rowDeleted)
        //            {
        //                Response.Redirect(Request.RawUrl, false);
        //                upList.Update();
        //            }
        //            tranObj.Commit();
        //        }
        //        catch (Exception exc)
        //        {
        //            if (tranObj != null)
        //                tranObj.Rollback();
        //            throw new Exception(exc.Message);
        //        }
        //        finally
        //        {
        //            con.Close();
        //        }
        //    }
        //    if (e.CommandName == "Cancel")
        //    {

        //        var bagname = e.CommandArgument.ToString().Split('-')[0];
        //        var blood_Id = e.CommandArgument.ToString().Split('-')[1];
        //        var Platelets = e.CommandArgument.ToString().Split('-')[2];
        //        var query = DBClass.getField("select top 1 Donor_Id from Donor where D_bagno='" + bagname + "'  order by Donor_Id desc");
        //        if (query.Contains("position"))
        //        {

        //        }
        //        else
        //        {
        //            var Division_Id = DBClass.getField("select Blood_Division_Id from Blood_Division where Donor_Id=" + query);
        //            DBClass.executeNonQueryWithoutBegin("update Blood_Bank set isCancel=1  where Blood_ID=" + blood_Id);
        //            if (Platelets == "")
        //            {
        //                DBClass.executeNonQueryWithoutBegin("update donor set IsIssue=0 , IsBagFree = 0 ,isWholeBagReceived =0 where donor_id=" + query);
        //            }
        //            else
        //            {
        //                var Division_type_id = DBClass.getField("select Blood_Division_Type_Id from Blood_Division_Type where Blood_Division_Id = '" + Division_Id + "' and Blood_Platelets_Id = " + Platelets);


        //                var Qty = DBClass.getField("select Qty from Blood_Division_Type where Blood_Division_Id = '" + Division_Id + "' and Blood_Platelets_Id = " + Platelets);
        //                var issue_Qty = DBClass.getField("select Issue_qty from Blood_Division_Type where Blood_Division_Id = '" + Division_Id + "' and Blood_Platelets_Id = " + Platelets);

        //                DBClass.executeNonQueryWithoutBegin("update Blood_Division_Type set Qty = '" + Qty + "' + 1 where Blood_Division_Id = '" + Division_Id + "' and Blood_Division_Type_Id = '" + Division_type_id + "'  and Blood_Platelets_Id = " + Platelets);
        //                DBClass.executeNonQueryWithoutBegin("update Blood_Division_Type set Issue_qty = '" + issue_Qty + "' - 1 where Blood_Division_Id = '" + Division_Id + "' and Blood_Division_Type_Id = '" + Division_type_id + "'  and Blood_Platelets_Id = " + Platelets);
        //                DBClass.executeNonQueryWithoutBegin("update donor set IsIssue=0 , IsBagFree = 0 ,isWholeBagReceived =0 where donor_id=" + query);
        //            }
        //        }
        //    }
        //    Response.Redirect("BloodBankView.aspx");
        //}

        //protected void whdgList_RowIslandsPopulating(object sender, Infragistics.Web.UI.GridControls.ContainerRowCancelEventArgs e)
        //{
        //    this.whdgList.RowIslandDataBinding += new RowIslandEventHandler(whdgList_RowIslandDataBinding);
        //}

        //protected void whdgList_RowIslandDataBinding(object sender, RowIslandEventArgs e)
        //{
           
        //    if (e.RowIsland.DataMember == "whdsList")
        //    {
        //        Sorting sort = e.RowIsland.Behaviors.Sorting;
        //        sort.SortedColumns.Add("ItemName", Infragistics.Web.UI.SortDirection.Descending);
        //    }

           
        //    if (e.RowIsland.DataMember == "whdsList"
        //       && e.RowIsland.ParentRow == this.whdgList.GridView.Rows[1])
        //    {
        //        Sorting sort = e.RowIsland.Behaviors.Sorting;
        //        sort.SortedColumns.Add(e.RowIsland.Columns[1], Infragistics.Web.UI.SortDirection.Ascending);
        //    }
        //}
    }
}