<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="DiscountDefinition.aspx.cs" Inherits="PMS.DiscountDefinition" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    
    
<script type="text/javascript" src="Scripts/jquery.tokeninput.js"></script>
       
    <script type="text/javascript">
        function LoadPatientDetails() {
            var Patient_ID = $('#hdfPatient_ID').val();

            $.ajax({
                type: "POST",
                url: "DiscountDefinition.aspx/GetPatientDetails",
                data: "{'PatientID':" + Patient_ID + "}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: OnSuccess,
                failure: function (response) {
                    alert(response.d);
                }
            });
        }


        function ReplaceNullWith_Space(Data)
        {
            if (Data == "null")
                return " ";
            else
                return Data;
        }



        function OnSuccess(data) {
            var roomward = "";
            if (data.d != '') {
                var mydate = new Date(Date.parse(data.d.Entry_Date));
                var dateR = mydate.toLocaleDateString();
                //var isDisharge = ReplaceNullWith_Space(data.d.Discharge);
                //var isInpatient = ReplaceNullWith_Space(data.d.isInpatient);
                //is_Patient_Temp = isInpatient;
                $('#lblPatienName').text(ReplaceNullWith_Space(data.d.Name));
                $('#lblAgeYears').text(ReplaceNullWith_Space(data.d.Age));
                $('#lblGender').text(ReplaceNullWith_Space(data.d.Gender));
                $('#lblRegDate').text(dateR);
                $('#lblAddress').text(ReplaceNullWith_Space(data.d.Address));
                $('#lblContactNo').text(ReplaceNullWith_Space(data.d.Mobile));
                $('#lblDepartment').text(ReplaceNullWith_Space(data.d.department));
                $('#lblPatientCategory').text(ReplaceNullWith_Space(data.d.Patient_Type));
            }
        }


            function tokenInputs(textboxID, tblName, OnAddFun) {
                $('#' + textboxID).tokenInput("json.aspx?Table=" + tblName,
                    {
                        tokenLimit: 1,
                        onAdd:
                            function (item) {
                                try {

                                    if (tblName == 'Patients') {

                                        $("#hdfPatient_ID").val(item.id);
                                        LoadPatientDetails();
                                    }


                                }
                                catch (err) {
                                    alert(err.message);
                                }

                            }
                    });
            }


        function FillTokenInputForMRNo()
        {

                var PatientID = $('#hdfPatient_ID').val();

                if (PatientID == '') {
                    tokenInputs('txtMRNo', 'Patients');

                }
                else {

                    var tokendata = httpGet("json.aspx?Table=PatientsFetchByID&q=" + PatientID);

                    $('#txtMRNo').tokenInput("add", { id: JSON.parse(tokendata)[0].id, name: JSON.parse(tokendata)[0].name, readonly: true });

                    LoadPatientDetails();
                }
        }




        function ddlchange() {

            var ddlchk = $('#ctl00_MainContent_ddlDiscountCAtegory').find('option:selected').text();

            if (ddlchk == "Select") {

                $('#form_No').hide();
                $('#lblform').hide();

                $('#lblcategry').hide();

                $('#ddlCat').hide();

                $('#lblremark').hide();

                $('#Remarks').hide();

                $('#lblempCode').hide();
                $('#txtempCode').hide();
                $('#lblstdRoll').hide();

                $('#lblempName').hide();

                $('#txtEmpname').hide();


                $('#divname').hide();
                $('#divtxtname').hide();

            }


            if (ddlchk == "Trust Discount") {

                $('#form_No').show();
                $('#lblform').show();

                $('#lblcategry').show();

                $('#ddlCat').show();

                $('#lblremark').show();


                $('#Remarks').show();

                $('#divname').hide();
                $('#divtxtname').hide();

                $('#lblempCode').hide();
                $('#txtempCode').hide();
                $('#lblstdRoll').hide();

                $('#lblempName').hide();

                $('#txtEmpname').hide();

            }

            if (ddlchk == "Employee Discount") {

                $('#form_No').show();
                $('#lblform').show();

                $('#lblcategry').hide();

                $('#ddlCat').hide();

                $('#lblremark').show();

                $('#Remarks').show();

                $('#divname').show();
                $('#divtxtname').show();

                $('#lblempCode').show();
                $('#txtempCode').show();
                $('#lblstdRoll').hide();

                $('#lblempName').show();

                $('#txtEmpname').show();

            }

            if (ddlchk == "Student Discount") {

                $('#form_No').show();
                $('#lblform').show();

                $('#lblcategry').hide();

                $('#ddlCat').hide();

                $('#lblremark').show();

                $('#Remarks').show();

                $('#lblempCode').show();
                $('#txtempCode').show();
                $('#lblstdRoll').hide();

                $('#lblempName').hide();

                $('#txtEmpname').hide();


                $('#divname').hide();
                $('#divtxtname').hide();
            }
        }

        function LoadDiscountDetail(id) {
            var Patient_ID = $('#hdfPatient_ID').val();

            $.ajax({
                type: "POST",
                url: "DiscountDefinition.aspx/GetDiscount_Detail",
                data: "{'id':" + id + "}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async:false,
                success: OnSuccessdt,
                failure: function (response) {
                    alert(response.d);
                }
            });
        }
        function OnSuccessdt(dataa) {

            var parsed_Data = JSON.parse(dataa.d);
            $('#tableDis tr:gt(0)').each(function (key, value) {
                if (typeof parsed_Data[key] === 'undefined') {


                }
                else {
                    $(this).find('td').find('input[name="disPer"]').val(parsed_Data[key].Discount_Percentage);
                    $(this).find('td').find('input[name="disAmount"]').val(parsed_Data[key].Discount_Amount);
                    //var DT = $.datepicker.formatDate('dd M yy', new Date(parseInt(parsed_Data[key].Valid_for.substring(6, 19))));
                    $(this).find('td').find('input[name="ExpiredDays"]').val(parsed_Data[key].Expired_Days);
                    $(this).find('td').find('input[name="validfor"]').val('');
                }


            });
            $('#ctl00_MainContent_ddlDiscountCAtegory').val(parsed_Data[0].Discount_Category_Id);
            $('#btnSave').val('Update');
        }

        $(document).ready(function () {
             var id = '<%=Request.QueryString["ID"]%>';
        if (id != "")
        {

            LoadDiscountDetail(id);


        }
            $('#btnSave').on('click', function ()
            {
                var patient_Id = $('#txtMRNo').val();
                var discount_Categ = $('#ctl00_MainContent_ddlDiscountCAtegory').val();
                //var form_no = $('#form_No').val();
                //var code = $('#txtempCode').val();
                //var name = $('#txtEmpname').val();
                //var remarks = $('#Remarks').val();
                //var ddlCat = $('#ddlCat').val();
                var btnSave = $('#btnSave').val();
                var List = [];
                var table = $('#tableDis');
                  var id = '<%=Request.QueryString["ID"]%>';
                table.find('tbody tr').each(function (key, value)
                {
                    var dis_Amt = $($(value).find("td")[3]).find("input[name=disAmount]").val();
                    var dis_per = $($(value).find("td")[2]).find("input[name=disPer]").val();
                    if (dis_Amt == "") dis_Amt = 0;
                    if (dis_per == "") dis_per = 0;
                    List.push({
                        'DepartName': $($(value).find("td")[1]).find("input[name=Department_name]").val(),
                        'DepartType': $($(value).find("td")[1]).find("input[name=ItemType]").val(),
                        'DepartId': $($(value).find("td")[1]).find("input[name=ItemID]").val(),
                        'Exp_Days': $($(value).find("td")[1]).find("input[name=ExpiredDays]").val(),
                        'Percentage': dis_per,
                        'Amount': dis_Amt,
                        'validfor': $($(value).find("td")[4]).find("input[name=validfor]").val(),

                    });

                });
                   var patID = $('#txtMRNo').val();
                   var Details = {
                       patient_Id: patient_Id,
                       discount_Categ: discount_Categ,
                       //form_no: form_no,
                       //code: code,
                       //name: name,
                       //remarks: remarks,
                       //ddlCat:ddlCat,
                      List: List
                   };
                   if (id == "") id=0
                   PageMethods.SaveDicount(btnSave,id, JSON.stringify(Details), function (response)
                   {
                       window.location.href = "DiscountDefinition.aspx?ID=" + response;

                   });

            });
          //  FillTokenInputForMRNo();
            $('input[name="validfor"]').datepicker({
                dateFormat: 'dd M yy',
                onSelect: function (dateText, inst) {
                    var date = $(this).val();
                 
                    //var start = new Date(date);
                    //var end = new Date();
                    //var diff = new Date(start - end);
                    //var days = diff / 1000 / 60 / 60 / 24;
                  
                    var date1 = new Date(date);
                    var date2 = new Date(); //less than 1
                    var start = Math.floor(date1.getTime() / (3600 * 24 * 1000)); //days as integer from..
                    var end = Math.floor(date2.getTime() / (3600 * 24 * 1000)); //days as integer from..
                    var daysDiff = end - start; // exact dates
                    $(this).closest('tr').find('input[name="ExpiredDays"]').val(daysDiff);

                  
                }
            })


            var ddlchk = $('#ctl00_MainContent_ddlDiscountCAtegory').find('option:selected').text();
            if (ddlchk == "Select") {
                $('#form_No').hide();
                $('#lblform').hide();
                $('#lblcategry').hide();
                $('#ddlCat').hide();
                $('#lblremark').hide();
                $('#Remarks').hide();
                $('#lblempCode').hide();
                $('#txtempCode').hide();
                $('#lblstdRoll').hide();
                $('#lblempName').hide();
                $('#txtEmpname').hide();
            }

        });
    //    var start = new Date("2010-04-01"),
    //end = new Date(),
    //diff = new Date(end - start),
    //days = diff / 1000 / 60 / 60 / 24;
       



    </script>




<style type="text/css">

    .table > thead > tr {
    background-position: 0% 0%;
    color: #ffffff;
    font-size:14px;
    font-weight: normal;
    background-repeat: repeat-x;
    background-image: linear-gradient(to bottom, #438eb9 0, #438eb9 100%);
    background-color: #F2F2F2;
    background-attachment: scroll;
}

</style>


</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

          <div id="header" style="display:none;">
            <table style="width: 819px; height: 231px;">
                <tr style="display: none;">
                    <td>

                        <label>Date From :	</label>
                    </td>
                    <td>
                        <input type="text" id="txtDateFrom" />
                    </td>
                    <td>
                        <label>Date To :	</label>
                    </td>
                    <td>
                        <input type="text" id="txtDateTo" />
                    </td>
                </tr>
                <tr>
                    <td>
                        <label>
                            MR No *:
                        </label>
                    </td>
                    <td>
                        <input type="text" id="txtMRNo" onchange="FetchRecommendedDetails()" />

                    </td>
                  
                </tr>
                <tr>
                    <td>
                        <label>Patient Name :	</label>
                    </td>
                    <td>
                        <label id="lblPatienName"></label>
                    </td>
                    <td>
                        <label>Contact No :	</label>
                    </td>
                    <td>
                        <label id="lblContactNo"></label>
                    </td>
                </tr>
                <tr>
                    <td>
                        <label>Reg. Date :	</label>
                    </td>
                    <td>
                        <label id="lblRegDate"></label>
                    </td>
                    <td>
                        <label>Gender  :	</label>
                    </td>
                    <td>
                        <label id="lblGender"></label>
                    </td>
                </tr>
                <tr>
                    <td>
                        <label>Age Years :	</label>
                    </td>
                    <td>
                        <label id="lblAgeYears"></label>
                    </td>
                    <td>
                        <label>Address   :	</label>
                    </td>
                    <td>
                        <label id="lblAddress"></label>
                    </td>
                </tr>
                <tr>
                 <%--   <td>
                        <label>Patient Category :	</label>
                    </td>
                    <td>
                        <label id="lblPatientCategory"></label>
                    </td>--%>
                    <td>
                        <label>Department  :	</label>
                    </td>
                    <td>
                        <label id="lblDepartment"></label>
                    </td>
                </tr>
                <tr>
                  <%--  <td>
                    <label> OPD Panel Company :</label>
                        </td>
                    <td>
                        <label id="lblOPDpnl"></label>
                    </td>--%>

                </tr>
               <%-- <tr>
                     <td>
                        <label>InPatient Admit Catagory :</label>
                    </td>
                    <td>
                        <label id="lblPatientDiscountType" style="background-color:silver;"></label>
                    </td>
                    <td>
                        <label>Ward / Room :</label>
                    </td>
                    <td>
                        <label id="lblWardRoom" style="background-color:silver;"></label>
                    </td>
                </tr>--%>
             <%--   <tr>
                     <td>
                    <label> IPD Panel Company :</label>
                        </td>
                    <td>
                          <label id="lblIPDpnl"></label>
                    </td>
                </tr>--%>
                <tr>

              <%--      <td>
                        <label>Bill Date :	</label>
                    </td>
                    <td>
                        <input type="text" id="txtBillDate" disabled="disabled" />
                    </td>--%>
                   <%-- <td colspan="1">
                        <label>Remarks:</label>
                    </td>
                    <td>
                        <textarea id="txtRemarks" style="width: 168px; height: 57px;"></textarea>
                    </td>--%>
                </tr>
                <tr>
                    <%-- <td>Charge policy: *
                    </td>
                    <td>
                        <select  id="ddlChargePolicy"></select>
                    </td>--%>
                    <%--<td>Doctor:
                    </td>--%>
                   <%-- <td>
                        <select  id="ddlDoctor"></select>
                    </td>--%>
                </tr>
               
            </table>
        </div>
    <table>     <tr>
                    <td>Discount Category</td>
                    <td>
                        <asp:DropDownList ID="ddlDiscountCAtegory" onchange="ddlchange()" runat="server" Width="167px" AppendDataBoundItems="true" TabIndex="21">
                                </asp:DropDownList>
                    </td>
                </tr>
        </table>

    <div style="margin-top: 30px;display:none;" class="row" >

    <div class="col-md-1">
        <label id="lblform">Form No</label>
    </div>
    
    <div class="col-md-2">
       <input type="text" id="form_No" />
    </div>
    
       
    
    
    <div class="col-md-1">
        <label id="lblcategry">Category</label>
        <label id="lblempCode">Employee Code</label>

    </div>
    
    <div class="col-md-2">
  <select id="ddlCat">

  </select>
        <input type="text" id="txtempCode" />

    </div>
    
        
    <div id="divname" class="col-md-1">
        <label id="lblempName">Employee Name</label>
    </div>
    
    <div id="divtxtname" class="col-md-2">
       <input type="text" id="txtEmpname" />

    </div>
    
   
    
    <div class="col-md-1">
        <label id="lblremark">Remarks</label>
    </div>
    
    <div class="col-md-2">
       <input type="text" id="Remarks" />

    </div>


</div>









    <div style="margin-top: 40px;">
        <table class="table table-hover table-striped table-bordered" id="tableDis" style="width: 62%;">
            <thead id="ihead">
                <tr>
                    <th>SrNo</th>
                    <th>Department</th>
                    <th>Dis %</th>
                    <th>Dis Amount</th>
                    <th style="display:none;">Valid For</th>
                    <th style="display:none;">Action</th>

                </tr>
                
            </thead>
            <tbody>
                <tr>
                    <td style="width: 60px;">1</td>
                    <td style="width: 287px;">Hospital Services<input type="hidden" name="Department_name" value="Hospital Services"/><input type="hidden" name="ItemType" value="Item"/><input type="hidden" name="ItemID" value="" /><input type="hidden" name="ExpiredDays" value="" /></td>
                    <td style="width: 1%;"><input type="text" style="width:62px !important;" name="disPer" /></td>
                   
                    <td style="width: 1%;"><input type="text" name="disAmount" /></td>
                    <td style="width: 1%;display:none;"><input type="text" name="validfor"/></td>
                    <td style="width: 55px;display:none;">Edit</td>

                </tr>
                     <tr>
                    <td style="width: 60px;">2</td>
                    <td style="width: 287px;">Procedure<input type="hidden" name="Department_name" value="Procedure"/><input type="hidden" name="ItemType" value="Procedure"/><input type="hidden" name="ItemID" value="" /><input type="hidden" name="ExpiredDays" value="" /></td>
                    <td style="width: 1%;"><input type="text" style="width:62px !important;" name="disPer" /></td>
                   
                    <td style="width: 1%;"><input type="text" name="disAmount" /></td>
                    <td style="width: 1%;display:none;"><input type="text" name="validfor"/></td>
                    <td style="width: 55px;display:none;">Edit</td>

                </tr>
                     <tr>
                    <td style="width: 60px;">3</td>
                    <td style="width: 287px;">Lab <input type="hidden" name="Department_name" value="Lab"/><input type="hidden" name="ItemType" value="Test"/><input type="hidden" name="ItemID" value="001" /><input type="hidden" name="ExpiredDays" value="" /></td>
                     <td style="width: 1%;"><input type="text" style="width:62px !important;" name="disPer" /></td>
                   
                    <td style="width: 1%;"><input type="text" name="disAmount" /></td>
                    <td style="width: 1%;display:none;"><input type="text" name="validfor"/></td>
                    <td style="width: 55px;display:none;">Edit</td>

                </tr>
                     <tr>
                    <td style="width: 60px;">4</td>
                    <td style="width: 287px;">UltraSound<input type="hidden" name="Department_name" value="UltraSound"/><input type="hidden" name="ItemType" value="Test"/><input type="hidden" name="ItemID" value="002" /><input type="hidden" name="ExpiredDays" value="" /></td>
                 <td style="width: 1%;"><input type="text" style="width:62px !important;" name="disPer" /></td>
                   
                    <td style="width: 1%;"><input type="text" name="disAmount" /></td>
                    <td style="width: 1%;display:none;"><input type="text" name="validfor"/></td>
                    <td style="width: 55px;display:none;">Edit</td>

                </tr>
                     <tr>
                    <td style="width: 60px;">5</td>
                    <td style="width: 287px;">X-Ray<input type="hidden" name="Department_name" value="X-Ray"/><input type="hidden" name="ItemType" value="Test"/><input type="hidden" name="ItemID" value="003" /><input type="hidden" name="ExpiredDays" value="" /></td>
                    <td style="width: 1%;"><input type="text" style="width:62px !important;" name="disPer" /></td>
                   
                    <td style="width: 1%;"><input type="text" name="disAmount" /></td>
                    <td style="width: 1%;display:none;"><input type="text" name="validfor"/></td>
                    <td style="width: 55px;display:none;">Edit</td>

                </tr>
                     <tr>
                    <td style="width: 60px;">6</td>
                    <td style="width: 287px;">CT-Scan<input type="hidden" name="Department_name" value="CT-Scan"/><input type="hidden" name="ItemType" value="Test"/><input type="hidden" name="ItemID" value="004" /><input type="hidden" name="ExpiredDays" value="" /></td>
                   <td style="width: 1%;"><input type="text" style="width:62px !important;" name="disPer" /></td>
                   
                    <td style="width: 1%;"><input type="text" name="disAmount" /></td>
                    <td style="width: 1%;display:none;"><input type="text" name="validfor"/></td>
                    <td style="width: 55px;display:none;">Edit</td>

                </tr>
                     <tr>
                    <td style="width: 60px;">7</td>
                    <td style="width: 287px;">Blood Bank<input type="hidden" name="Department_name" value="Blood Bank"/><input type="hidden" name="ItemType" value="Test"/><input type="hidden" name="ItemID" value="005" /><input type="hidden" name="ExpiredDays" value="" /></td>
                     <td style="width: 1%;"><input type="text" style="width:62px !important;" name="disPer" /></td>
                   
                    <td style="width: 1%;"><input type="text" name="disAmount" /></td>
                    <td style="width: 1%;display:none;"><input type="text" name="validfor"/></td>
                    <td style="width: 55px;display:none;">Edit</td>

                </tr>
           <tr>
                    <td style="width: 60px;">8</td>
                    <td style="width: 287px;">Package<input type="hidden" name="Department_name" value="Package"/><input type="hidden" name="ItemType" value="Package"/><input type="hidden" name="ItemID" value="" /><input type="hidden" name="ExpiredDays" value="" /></td>
                     <td style="width: 1%;"><input type="text" style="width:62px !important;" name="disPer" /></td>
                   
                    <td style="width: 1%;"><input type="text" name="disAmount" /></td>
                    <td style="width: 1%;display:none;"><input type="text" name="validfor"/></td>
                    <td style="width: 55px;display:none;">Edit</td>

                </tr>






                </tbody>

        </table>
        <table>
            <tr>
                <td><input type="button" value="Save" id="btnSave" /></td>
            </tr>
        </table>

       <input type="hidden" id="hdfPatient_ID" />
    </div>
</asp:Content>
