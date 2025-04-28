using Infragistics.Documents.Reports.Report.Segment;
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
    public partial class GroupTestList : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static object ViewList(int draw, int start, int length, string sortColumn, string sortColumnDirection, string searchValue)
        {
            try
            {
                using (var _dbContext = new DataBaseDataContext())
                {
                    string userId = HttpContext.Current.Session["UserId"].ToString();

                    var Total_Grouptest = _dbContext.DataValues.Count();
                    var Grouptest = from D in _dbContext.DataValues
                                    where D.ValueSet_ID == 70
                                    && (
                                          D.DataValue_Description.Contains(searchValue))
                                    select new
                                    {
                                        DataValue_ID =    D.DataValue_ID,
                                        DataValue_Description = D.DataValue_Description,
                                        Segment2 = D.Segment2,
                                        Segment3 = D.Segment3,
                                        Segment4 = D.Segment4,
                                        Division = D.Division,
                                        Fixed_Value = D.Fixed_Value,
                                        Result_Value = D.Result_Value,
                                        List_Value = D.List_Value,
                                        Required_Value = D.Required_Value,
                                        Group_Depart =  D.Group_Depart,
                                        Segment5 =     D.Segment5,
                                        Special_Test = D.Special_Test
                                    };

                    var FilteredCount = Grouptest.Count();
                    switch (sortColumn)
                    {
                        case "DataValue_Description":
                            Grouptest = sortColumnDirection == "asc" ? Grouptest.OrderBy(a => a.DataValue_Description) : Grouptest.OrderByDescending(a => a.DataValue_Description);
                            break;
                        default:
                            Grouptest = Grouptest.OrderBy(a => a.DataValue_ID);
                            break;
                    }


                    var GroupTestList = Grouptest.Skip(start).Take(length).ToList();


                    var jsonData = new { draw = draw, recordsFiltered = FilteredCount, recordsTotal = Total_Grouptest, data = GroupTestList };
                    return jsonData;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching Group Test list", ex);
            }
        }
    }
}