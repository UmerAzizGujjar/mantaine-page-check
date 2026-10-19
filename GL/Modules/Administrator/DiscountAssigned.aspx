<%@ Page EnableSessionState="ReadOnly" Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="DiscountAssigned.aspx.cs" Inherits="PMS.DiscountAssigned" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
     <link href="Styles/jquery.ptTimeSelect.css" rel="stylesheet" />
    <script type="text/javascript" src="Scripts/jquery.ptTimeSelect.js"></script>
    <script type="text/javascript" src="../Scripts/jquery.tokeninput.js"></script>
    
<script type="text/javascript" src="Scripts/jquery.tokeninput.js"></script>
   
    <script type="text/javascript">
        $(function () {
            Sys.WebForms.PageRequestManager.getInstance().add_pageLoaded(function (evt, args) {
                $("#ctl00_MainContent_txtValid_date").datepicker({ dateFormat: 'mm/dd/yy' });
             
               /* $("#ctl00_MainContent_txtValid_date").ptTimeSelect({});*/

               
            });
        });
        function LoadDiscountAssignedDetail(id)
        {
           
            $.ajax({
                type: "POST",
                url: "DiscountAssigned.aspx/LoadDiscountAssignedDetail",
                data: JSON.stringify({
                    "id": id
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
             
                success: OnSuccessdts,
                failure: function (response) {
                    alert(response.d);
                }
            });
        }
        function GivenDiscount(row)
        {
            var value = $(row).closest('tr').find('td input[name="disPer"]').val();
            //localStorage.Discount = data.Discount;
            //localStorage.Discount_Amt = data.Discount_Amt;
            if (parseInt(value) > parseInt(localStorage.Discount))
            {
               alert("this user has only limit of " + parseInt(localStorage.Discount) + "%");
                $(row).closest('tr').find('td input[name="disPer"]').val(0);

            }

        } 
        function Print() {
            var id = '<%=Request.QueryString["ID"]%>';
            window.open('ReportViewer.aspx?ReportName=DiscountAssignedDetail&ReportTitle=Discount Assigned Detail Print' +'&Discount_Assigned_Patient_Id=' + id);
        }

        function GivenDiscountAmt(row) {
            var Dis_amt = 0;
            var value = $(row).closest('tr').find('td input[name="disAmount"]').val();
            $('#tableDis tr:gt(0)').each(function () {
                var Dis_amt_value = $(this).find('td input[name="disAmount"]').val();
                if (Dis_amt_value == "") Dis_amt_value = 0;
                Dis_amt += parseInt(Dis_amt_value);

            });
            //localStorage.Discount = data.Discount;
            //localStorage.Discount_Amt = data.Discount_Amt;
            if (parseInt(Dis_amt) > parseInt(localStorage.Discount_Amt)) {
                alert("this user has only limit of " + parseInt(localStorage.Discount_Amt) + "");
                $(row).closest('tr').find('td input[name="disAmount"]').val(0);

            }

        }
        function OnSuccessdts(dataa) {

            var parsed_Data = JSON.parse(dataa.d);
            var pat_id = parsed_Data[0].Patient_Id;

            var tokendata = httpGet("json.aspx?Table=PatientsFetchByID&q=" + pat_id);

            $('#txtMRNo').tokenInput("add", { id: JSON.parse(tokendata)[0].id, name: JSON.parse(tokendata)[0].name, readonly: true });

            LoadPatientDetails();
            $('#btnSave').val('Update');
           /* $('#btnSave').hide();*/
            $('#ctl00_MainContent_ddlDiscountCAtegory').val(parsed_Data[0].Discount_Category_Id);
            $('#form_No').val(parsed_Data[0].Form_no);
            $('#txtempCode').val(parsed_Data[0].Code);
            var date_valid = $.datepicker.formatDate('dd M yy', new Date(parseInt(parsed_Data[0].discount_validity_date.substring(6, 19))));
            $('#ctl00_MainContent_txtValid_date').val(date_valid);

            $('#txtEmpname').val(parsed_Data[0].Emp_Name);
            $('#Remarks').val(parsed_Data[0].Remarks);
            $('#ddlCat').val(parsed_Data[0].Category)
            if (parsed_Data.length > 0)
            {
                $('#tableDis tr:gt(0)').each(function (key, value) {
                    $(this).find('td').find('input[name="disPer"]').val(parsed_Data[key].Discount_Percentage);
                    $(this).find('td').find('input[name="disAmount"]').val(parsed_Data[key].Discount_Amount);
                    var DT = $.datepicker.formatDate('dd M yy', new Date(parseInt(parsed_Data[key].Valid_for.substring(6, 19))));
                  
                    $(this).find('td').find('input[name="ExpiredDays"]').val(parsed_Data[key].Expired_Days);
                    $(this).find('td').find('input[name="validfor"]').val(DT);
                    if (parsed_Data[key].Remaining_Amount == null) parsed_Data[key].Remaining_Amount = 0;
                    var dis_amt=   $(this).find('td').find('input[name="disAmount"]').val();
                    if (dis_amt == "" || dis_amt == "0") parsed_Data[key].Remaining_Amount = 0;
                    $(this).find('td').find('input[name="RemainAmount"]').val(parsed_Data[key].Remaining_Amount);


                });
            }
            
            else ("")
            {

            }
        }
        function httpGet(theUrl) {
            var xmlHttp = null;
            xmlHttp = new XMLHttpRequest();
            xmlHttp.open("GET", theUrl, false);
            xmlHttp.send(null);
            return xmlHttp.responseText;
        }
        function checkRepeat()
        {
            var Patient_ID = $('#hdfPatient_ID').val();
            $.ajax({
                type: "POST",
                url: "DiscountAssigned.aspx/IsPatientExists",
                data: "{'PatientID':" + Patient_ID + "}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async:false,
                success: function (response)
                {
                    if (response.d == "true" || response.d == "True" | response.d == true)
                    {
                        alert("Patient has already existed");
                        location.href = "DiscountAssigned.aspx";

                    }


                },
                failure: function (response) {
                    alert(response.d);
                }
            });


        }
        function LoadPatientDetails() {
            var Patient_ID = $('#hdfPatient_ID').val();

            $.ajax({
                type: "POST",
                url: "DiscountAssigned.aspx/GetPatientDetails",
                data: "{'PatientID':" + Patient_ID + "}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: OnSuccess,
                failure: function (response) {
                    alert(response.d);
                }
            });
        }


        function LoadDiscountDetail(id) {
            

            $.ajax({
                type: "POST",
                url: "DiscountAssigned.aspx/GetDiscount_Detail",
                data:JSON.stringify({
                    "id": id
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: OnSuccessdt,
                failure: function (response) {
                    alert(response.d);
                }
            });
        }



        function ReplaceNullWith_Space(Data) {
            if (Data == "null")
                return " ";
            else
                return Data;
        }

        function OnSuccessdt(dataa) {

            var parsed_Data = JSON.parse(dataa.d);
            if (parsed_Data.length > 0)
            {
             
                $('#tableDis tr:gt(0)').each(function (key, value)
                {

                    $(this).find('td').find('input[name="disPer"]').val(parsed_Data[key].Discount_Percentage);
                    $(this).find('td').find('input[name="disAmount"]').val(parsed_Data[key].Discount_Amount);
                    var DT = $.datepicker.formatDate('dd M yy', new Date());
                    $(this).find('td').find('input[name="ExpiredDays"]').val(parsed_Data[key].Expired_Days);
                    if (IPD != 0) {
                        var current_Date = $.datepicker.formatDate('dd M yy', new Date());



                        var date = new Date(current_Date);
                        var newdate = new Date(date);

                        newdate.setDate(newdate.getDate() + 3);

                        var dd = newdate.getDate();
                        var mm = month[newdate.getMonth() + 1];
                        var y = newdate.getFullYear();
                        var someFormattedDate = dd + ' ' + mm + ' ' + y;
                        $('input[name="validfor"]').val(someFormattedDate);

                    }
                    else {
                        $(this).find('td').find('input[name="validfor"]').val(DT);
                    }
                    $(this).find('td').find('input[name="RemainAmount"]').val(0);

                });
            }
            else
            {
                $('input[name="disPer"]').val(0);
                $('input[name="disAmount"]').val(0);
                //$('input[name="validfor"]').val('');
            }
        }



        function ddlchange() {

            //var chkdll = $('#ctl00_MainContent_ddlDiscountCAtegory :selected').find('option:selected').text();
            var id = $('#ctl00_MainContent_ddlDiscountCAtegory').val();
            if (id == "02")
            {
                LoadDiscountDetail(id);
                $('#form_No').show();
                $('#lblform').show();

                $('#lblcategry').hide();

                $('#ddlCat').hide();

                $('#lblremark').show();

                $('#Remarks').show();

                $('#divname').show();
                $('#divtxtname').show();
                $('#lblform').text('Form No');
                $('#lblempCode').show();
                $('#txtempCode').show();
                $('#lblstdRoll').hide();

                $('#lblempName').show();
                $('#lblempCode').text('Employee Code')
                $('#txtEmpname').show();
            }
           else if (id == "03") {

                LoadDiscountDetail(id);
                $('#form_No').show();
                $('#lblform').show();
                $('#lblform').text('Form No');
                $('#lblempCode').text('Student Roll No')
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
            else
           {
               LoadDiscountDetail(id);
                $('#form_No').show();
                $('#lblform').show();
                $('#lblform').text('ATM Form No');
                $('#lblcategry').show();
                $('#ddlCat').show();
                $('#lblcategry').text('Trust Discount Category');
                $('#lblremark').show();
                $('#Remarks').show();
                $('#lblempCode').hide();
                $('#txtempCode').hide();
                $('#lblstdRoll').hide();
                $('#lblempName').hide();
                $('#txtEmpname').hide();
                $('#divname').hide()
                $('#divtxtname').hide();

            }
           
        }
  




        var IPD = 0;
        var month = new Array();
        month[1] = "Jan";
        month[2] = "Feb";
        month[3] = "Mar";
        month[4] = "Apr";
        month[5] = "May";
        month[6] = "Jun";
        month[7] = "Jul";
        month[8] = "Aug";
        month[9] = "Sep";
        month[10] = "Oct";
        month[11] = "Nov";
        month[12] = "Dec";
        function OnSuccess(data) {
            var roomward = "";
            if (data.d != '')
            {
               
                var mydate = new Date(Date.parse(data.d.Entry_Date));
                var dateR = mydate.toLocaleDateString();


                $('#lblAgeYears').text(ReplaceNullWith_Space(data.d.Age));
                $('#lblGender').text(ReplaceNullWith_Space(data.d.Gender));
                $('#lblRegDate').text(dateR);
                $('#lblAddress').text(ReplaceNullWith_Space(data.d.Address));
                $('#lblContactNo').text(ReplaceNullWith_Space(data.d.Mobile));
                $('#lblDepartment').text(ReplaceNullWith_Space(data.d.department));
                $('#lblPatientCategory').text(ReplaceNullWith_Space(data.d.Patient_Type));
                $('#lblPatienName').text(ReplaceNullWith_Space(data.d.Name));
                IPD = data.d.In_patient_ID;
                if (IPD != 0)
                {
                    var current_Date = $.datepicker.formatDate('dd M yy', new Date());
               
                   

                    var date = new Date(current_Date);
                    var newdate = new Date(date);

                    newdate.setDate(newdate.getDate() + 3);

                    var dd = newdate.getDate();
                    var mm = month[newdate.getMonth()+1];
                    var y = newdate.getFullYear();
                    var someFormattedDate = dd + ' ' + mm + ' ' + y;
                    $('input[name="validfor"]').val(someFormattedDate);

                }
                
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
                                    var id = '<%=Request.QueryString["ID"]%>';
                                    if (id != "") {
                                    }
                                    else
                                    {
                                        checkRepeat();
                                    }

                                   
                                    LoadPatientDetails();
                                    LoadDiscountDetail();
                                }


                            }
                            catch (err) {
                                alert(err.message);
                            }

                        }
                });
        }


        function FillTokenInputForMRNo() {

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

        function ddlchangeS()
        {
           
        
            var id = $('#ctl00_MainContent_ddlDiscountCAtegory').val();
      
            if (id == "02") {
              
                $('#form_No').show();
                $('#lblform').show();

                $('#lblcategry').hide();

                $('#ddlCat').hide();

                $('#lblremark').show();

                $('#Remarks').show();

                $('#divname').show();
                $('#divtxtname').show();
                $('#lblform').text('Form No');
                $('#lblempCode').show();
                $('#txtempCode').show();
                $('#lblstdRoll').hide();

                $('#lblempName').show();
                $('#lblempCode').text('Employee Code')
                $('#txtEmpname').show();
            }
            else if (id == "03") {

              
                $('#form_No').show();
                $('#lblform').show();
                $('#lblform').text('Form No');
                $('#lblempCode').text('Student Roll No')
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
            else {
                $('#form_No').show();
                $('#lblform').show();
                $('#lblform').text('ATM Form No');
                $('#lblcategry').show();
                $('#ddlCat').show();
                $('#lblcategry').text('Trust Discount Category');
                $('#lblremark').show();
                $('#Remarks').show();
                $('#lblempCode').hide();
                $('#txtempCode').hide();
                $('#lblstdRoll').hide();
                $('#lblempName').hide();
                $('#txtEmpname').hide();
                $('#divname').hide()
                $('#divtxtname').hide();
            }

        }
        function DiscountUserWise()
        {
            $.ajax({
                type: "Post",
                contentType: "application/json; charset=utf-8",
                url: "DiscountAssigned.aspx/GetDiscount",
                data: "",
                async:false,
                success: function (response) {
                    var data = JSON.parse(response.d);

                    localStorage.Discount = data.Discount;
                    localStorage.Discount_Amt = data.Discount_Amt;
                },
                error: function () {


                }
            });
        }
       
        localStorage.Discount = 0;
        localStorage.Discount_Amt = 0;
        function LoadDiscountCategory()
        {
            PageMethods.LoadDiscountCategory(function (Dosage)
            {
                    var options = '<option value=""> Select</option>'
                    $.each(JSON.parse(Dosage), function (key,value)
                    {
                        options += '<option value="' + value.DataValue_Name + '"> ' + value.DataValue_Description + ' </option>';
                    });
                 
                    $('#ddlCat').html(options);
                });
          
    
        }
        $(document).ready(function ()
        {
         
            var current_Date = $.datepicker.formatDate('dd M yy', new Date());
       
            $('input[name="validfor"]').val(current_Date);
            DiscountUserWise();
            $('#btnlist').on('click', function () {

                window.location.href = "DiscountAssigned_List.aspx";

            });
          
              $('#btnSave').on('click', function ()
            {
                  var patient_Id = $('#txtMRNo').val();
                  if (patient_Id == "") {
                      alert("Please Enter Mr No");
                      return;
                  }
                  var trusted = $('#ctl00_MainContent_ddlDiscountCAtegory').val();

                  if (localStorage.Discount == "0.00" && localStorage.Discount_Amt == "0.00")
                  {

                      alert("You Dont Have rights to give discount");
                      return;
                  }
                var discount_Categ = $('#ctl00_MainContent_ddlDiscountCAtegory').val();
                var form_no = $('#form_No').val();
                var code = $('#txtempCode').val();
                var txtvalid_date = $('#ctl00_MainContent_txtValid_date').val();
                var name = $('#txtEmpname').val();
                var remarks = $('#Remarks').val();
                var ddlCat = $('#ddlCat').val();
                var btnSave = $('#btnSave').val();
                var List = [];
                var table = $('#tableDis');
                  var id = '<%=Request.QueryString["ID"]%>';
                table.find('tbody tr').each(function (key, value)
                {
                    List.push({
                        'DepartName': $($(value).find("td")[1]).find("input[name=Department_name]").val(),
                        'DepartType': $($(value).find("td")[1]).find("input[name=ItemType]").val(),
                        'DepartId': $($(value).find("td")[1]).find("input[name=ItemID]").val(),
                        'Exp_Days': $($(value).find("td")[1]).find("input[name=ExpiredDays]").val(),
                        'Percentage': $($(value).find("td")[2]).find("input[name=disPer]").val(),
                        'Amount': $($(value).find("td")[3]).find("input[name=disAmount]").val(),
                        'validfor': $($(value).find("td")[4]).find("input[name=validfor]").val(),
                        'RemainAmount': $($(value).find("td")[5]).find("input[name=RemainAmount]").val(),

                    });

                });
                   var patID = $('#txtMRNo').val();
                   var Details = {
                       patient_Id: patient_Id,
                       discount_Categ: discount_Categ,
                       form_no: form_no,
                       code: code,
                       txtvalid_date: txtvalid_date,
                       name: name,
                       remarks: remarks,
                       ddlCat:ddlCat,
                      List: List
                   };
                   if (id == "") id=0
                   PageMethods.SaveDicountAssigned(btnSave, id, JSON.stringify(Details), function (response)
                   {
                       alert("Data Save Successfully");
                       window.location.href = "DiscountAssigned.aspx?ID=" + response;

                   });

            });
                FillTokenInputForMRNo();
               
            $('input[name="validfor"]').datepicker({
                dateFormat: 'dd M yy',
                onSelect: function (dateText, inst) {
                    var date = $(this).val();

                    var start = new Date(date);
                    var end = new Date();
                    var diff = new Date(start - end);
                    var days = diff / 1000 / 60 / 60 / 24;
                    $(this).closest('tr').find('input[name="ExpiredDays"]').val(parseInt(days));

                }
            })
            var ddlchk = $('#ctl00_MainContent_ddlDiscountCAtegory').val();
            if (ddlchk == "0")
            {
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
            LoadDiscountCategory();
                var id = '<%=Request.QueryString["ID"]%>';
        if (id != "")
        {
            $('#ctl00_MainContent_ddlDiscountCAtegory').attr('disabled',true)
            LoadDiscountAssignedDetail(id);
            setTimeout(function () {

                ddlchangeS();
            }, 2000);
           

        }
        });


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

     <div id="header">
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
                        <input type="text" id="txtMRNo"  />

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

                    <td>
                        <label>Department  :	</label>
                    </td>
                    <td>
                        <label id="lblDepartment"></label>
                    </td>
                </tr>
                <tr>

                </tr>
 
                <tr>


                </tr>
                <tr>

                </tr>
                <tr>
                    <td>Discount Category</td>
                    <td>
                        <asp:DropDownList ID="ddlDiscountCAtegory" onchange="ddlchange()" runat="server" Width="167px" AppendDataBoundItems="true" TabIndex="21">
                                </asp:DropDownList>
                    </td>
                    <td>Discount Validity Date</td>
                    <td>
                         <asp:TextBox ID="txtValid_date" runat="server"></asp:TextBox>
                    </td>
                </tr>
            </table>
        </div>
      <div style="margin-top: 30px;" class="row" >

    <div class="col-md-1">
        <label id="lblform" style="width: 90px;display: inline-block;">Form No</label>
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
                    <th>Valid For</th>
                    <th>Consumed Amount</th>
                    <th style="display:none;">Action</th>

                </tr>
                
            </thead>
            <tbody>
                <tr>
                    <td style="width: 60px;">1</td>
                    <td style="width: 287px;">Hospital Services<input type="hidden" name="Department_name" value="Hospital Services"/><input type="hidden" name="ItemType" value="Item"/><input type="hidden" name="ItemID" value="" /><input type="hidden" name="ExpiredDays" value="" /></td>
                    <td style="width: 1%;"><input type="text" style="width:62px !important;" name="disPer" class="disper" onkeyup="GivenDiscount(this);"/></td>
                   
                    <td style="width: 1%;"><input type="text" name="disAmount" onkeyup="GivenDiscountAmt(this);" /></td>
                    <td style="width: 1%;"><input type="text" name="validfor"/></td>

                    <td style="width: 1%;"><input type="text" name="RemainAmount" disabled /></td>
                    <td style="width: 55px;display:none;">Edit</td>

                </tr>
                     <tr>
                    <td style="width: 60px;">2</td>
                    <td style="width: 287px;">Procedure<input type="hidden" name="Department_name" value="Procedure"/><input type="hidden" name="ItemType" value="Procedure"/><input type="hidden" name="ItemID" value="" /><input type="hidden" name="ExpiredDays" value="" /></td>
                    <td style="width: 1%;"><input type="text" style="width:62px !important;" name="disPer" class="disper" onkeyup="GivenDiscount(this);"/></td>
                   
                    <td style="width: 1%;"><input type="text" name="disAmount" onkeyup="GivenDiscountAmt(this);"/></td>
                    <td style="width: 1%;"><input type="text" name="validfor"/></td>
                           <td style="width: 1%;"><input type="text" name="RemainAmount" disabled /></td>
                    <td style="width: 55px;display:none;">Edit</td>

                </tr>
                     <tr>
                    <td style="width: 60px;">3</td>
                    <td style="width: 287px;">Lab <input type="hidden" name="Department_name" value="Lab"/><input type="hidden" name="ItemType" value="Test"/><input type="hidden" name="ItemID" value="001" /><input type="hidden" name="ExpiredDays" value="" /></td>
                     <td style="width: 1%;"><input type="text" style="width:62px !important;" name="disPer" class="disper" onkeyup="GivenDiscount(this);" /></td>
                   
                    <td style="width: 1%;"><input type="text" name="disAmount" onkeyup="GivenDiscountAmt(this);"/></td>
                    <td style="width: 1%;"><input type="text" name="validfor"/></td>
                          <td style="width: 1%;"><input type="text" name="RemainAmount" disabled/></td>
                    <td style="width: 55px;display:none;">Edit</td>

                </tr>
                     <tr>
                    <td style="width: 60px;">4</td>
                    <td style="width: 287px;">UltraSound<input type="hidden" name="Department_name" value="UltraSound"/><input type="hidden" name="ItemType" value="Test"/><input type="hidden" name="ItemID" value="002" /><input type="hidden" name="ExpiredDays" value="" /></td>
                 <td style="width: 1%;"><input type="text" style="width:62px !important;" name="disPer" class="disper" onkeyup="GivenDiscount(this);"/></td>
                   
                    <td style="width: 1%;"><input type="text" name="disAmount" onkeyup="GivenDiscountAmt(this);"/></td>
                    <td style="width: 1%;"><input type="text" name="validfor"/></td>
                          <td style="width: 1%;"><input type="text" name="RemainAmount" disabled/></td>
                    <td style="width: 55px;display:none;">Edit</td>

                </tr>
                     <tr>
                    <td style="width: 60px;">5</td>
                    <td style="width: 287px;">X-Ray<input type="hidden" name="Department_name" value="X-Ray"/><input type="hidden" name="ItemType" value="Test"/><input type="hidden" name="ItemID" value="003" /><input type="hidden" name="ExpiredDays" value="" /></td>
                    <td style="width: 1%;"><input type="text" style="width:62px !important;" name="disPer" class="disper" onkeyup="GivenDiscount(this);"/></td>
                   
                    <td style="width: 1%;"><input type="text" name="disAmount" onkeyup="GivenDiscountAmt(this);"/></td>
                    <td style="width: 1%;"><input type="text" name="validfor"/></td>
                          <td style="width: 1%;"><input type="text" name="RemainAmount" disabled/></td>
                    <td style="width: 55px;display:none;">Edit</td>

                </tr>
                     <tr>
                    <td style="width: 60px;">6</td>
                    <td style="width: 287px;">CT-Scan<input type="hidden" name="Department_name" value="CT-Scan"/><input type="hidden" name="ItemType" value="Test"/><input type="hidden" name="ItemID" value="004" /><input type="hidden" name="ExpiredDays" value="" /></td>
                   <td style="width: 1%;"><input type="text" style="width:62px !important;" name="disPer" class="disper" onkeyup="GivenDiscount(this);"/></td>
                   
                    <td style="width: 1%;"><input type="text" name="disAmount" onkeyup="GivenDiscountAmt(this);"/></td>
                    <td style="width: 1%;"><input type="text" name="validfor"/></td>
                          <td style="width: 1%;"><input type="text" name="RemainAmount" disabled/></td>
                    <td style="width: 55px;display:none;">Edit</td>

                </tr>
                     <tr>
                    <td style="width: 60px;">7</td>
                    <td style="width: 287px;">Blood Bank<input type="hidden" name="Department_name" value="Blood Bank"/><input type="hidden" name="ItemType" value="Test"/><input type="hidden" name="ItemID" value="005" /><input type="hidden" name="ExpiredDays" value="" /></td>
                     <td style="width: 1%;"><input type="text" style="width:62px !important;" name="disPer" class="disper"onkeyup="GivenDiscount(this);" /></td>
                   
                    <td style="width: 1%;"><input type="text" name="disAmount" onkeyup="GivenDiscountAmt(this);"/></td>
                    <td style="width: 1%;"><input type="text" name="validfor"/></td>
                           <td style="width: 1%;"><input type="text" name="RemainAmount" disabled/></td>
                    <td style="width: 55px;display:none;">Edit</td>

                </tr>
                  <tr>
                    <td style="width: 60px;">8</td>
                    <td style="width: 287px;">Package<input type="hidden" name="Department_name" value="Package"/><input type="hidden" name="ItemType" value="Package"/><input type="hidden" name="ItemID" value="" /><input type="hidden" name="ExpiredDays" value="" /></td>
                     <td style="width: 1%;"><input type="text" style="width:62px !important;" name="disPer" class="disper"onkeyup="GivenDiscount(this);" /></td>
                   
                    <td style="width: 1%;"><input type="text" name="disAmount" onkeyup="GivenDiscountAmt(this);"/></td>
                    <td style="width: 1%;"><input type="text" name="validfor"/></td>
                           <td style="width: 1%;"><input type="text" name="RemainAmount" disabled/></td>
                    <td style="width: 55px;display:none;">Edit</td>

                </tr>


                </tbody>

        </table>
        <table>
            <tr>
                <td><input type="button" value="Save" id="btnSave" /></td>
                <td><input type="button" value="list" id="btnlist" /></td>
                 <td><input type="button" value="Print" id="btnPrint" onclick=" Print();"/></td>
            </tr>
        </table>

       <input type="hidden" id="hdfPatient_ID" />
    </div>


</asp:Content>
