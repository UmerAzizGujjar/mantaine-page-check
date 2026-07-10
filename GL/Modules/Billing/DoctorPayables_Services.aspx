
<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="DoctorPayables_Services.aspx.cs" Inherits="PMS.Modules.Billing.DoctorPayables_Services" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
        <%--<link href="../../wwwroot/THEME_IITH/CustomCSS/tablestyle.css" rel="stylesheet" />--%>
            <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/Billing.css" rel="stylesheet" />
    <script src="https://cdn.datatables.net/buttons/2.4.2/js/buttons.colVis.min.js"></script>
    

    <style type="text/css">

        .table th 
        {
            border: 1px solid #FFF;
            background-color: #438eb9;
            color: #FFF;
            position: sticky;
            top: -1px; 
            
        }
        #Emp_name 
        {
            font-size: 28px;
            color: #2385bd;
            background-color: #e0dfdf;
        }
        .table-striped > tbody > tr:nth-child(odd) > td 
        {
            background-color: #dfe9f1;
        }

        .widthdate {
            width:20% !important;
        }

        .btnwidth {
            width:20% !important;
        }
        </style>
    <script type="text/javascript">
        var _global_payable = '';
        var DocId = "<%= Request.QueryString["ID"] %>";
        $(document).ready(function () {
            LoadPage(DocId);
            loadacc();
            loadAccounts()
            $("#myInput").on("keyup", function () {
                var value = $(this).val().toLowerCase();
                $("#tbody tr").filter(function () {
                    $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1)
                });
            });
            $('#ddlpayment_method').on('change', function () {
                var val = $(this).val();

                $('.ddlname').each(function () {
                    $(this).val(val).trigger('change');
                });
            });
            var date;
            $("#txt_dateto").datepicker({ dateFormat: 'mm/dd/yy' }).attr('readonly', 'readonly');
            date = moment(date).format('L');
            $("#txt_dateto").val("");
            var date;
            $("#txt_datefrom").datepicker({ dateFormat: 'mm/dd/yy' }).attr('readonly', 'readonly');
            date = moment(date).format('L');
            $("#txt_datefrom").val("");
            var checkeditmode_startdate = '<%= Request.QueryString["stDate"]%>';
            var checkeditmode_enddate = '<%= Request.QueryString["endDate"]%>'
            if (checkeditmode_startdate != '') {
                $('#txt_datefrom').val(checkeditmode_startdate);
            }
            if (checkeditmode_enddate != '') {
                $('#txt_dateto').val(checkeditmode_enddate);
            }
            $('#btnSearch').click(function () {
                LoadPage(DocId);
            });
            $('[id*=chckHead]').on('click', function () {
                var isTrue = $('#chckHead').is(':checked');
                if (isTrue) {
                    $('.chcktbl').prop('checked', true);
                    calculateSum();
                }
                else {
                    $('.chcktbl').prop('checked', false);
                    calculateSum();
                }
            });
        });
        function loadacc() {
            var optionsDepth = '';
            $.ajax({
                type: "post",
                url: "DoctorPayables_Services.aspx/loadAccount",
                dataType: 'JSON',
                contentType: "application/json; charset=utf-8",
                async: false,
                success: function (msg) {
                    var data = JSON.parse(msg.d);
                    $.each(data, function (key, value) {
                        optionsDepth += '<option value="' + value.Account_ID + '" >' + value.name + '</option>';
                    });
                    _global_payable = optionsDepth;
                },
            });
        }
        var sumTotal;
        function calculateSum() {
            sumTotal = 0;
            $('table tbody tr').each(function () {
                var $tr = $(this);
                if ($tr.find('input[type="checkbox"]').is(':checked') && $($tr).is(':visible')) {
                    var $txtamount = $tr.closest('tr').find('td input[name="txt_Doctorshare"]').val();
                    sumTotal += parseInt($txtamount);
                }
            });
            $("#price").val(sumTotal);
            $('#price').text(sumTotal.toLocaleString('en'));
        }
        function addCommas(nStr) {
            nStr += '';
            x = nStr.split('.');
            x1 = x[0];
            x2 = x.length > 1 ? '.' + x[1] : '';
            var rgx = /(\d+)(\d{3})/;
            while (rgx.test(x1)) {
                x1 = x1.replace(rgx, '$1' + ',' + '$2');
            }
            return x1 + x2;
        }
        var totalCr = 0;
        function getTotal_CR_DR() {
            var crside = 0;
            var table = $('#tbody');
            table.find('tr input[type=checkbox]:checked:visible').each(function (key, value) {
                crside = $(value).closest('tr').find('td input[name=txt_Doctorshare]').val();
                totalCr += parseFloat(crside);
            });
        }
        var CrAccountID = 0;
        function TranferShares() {
            debugger;
            getTotal_CR_DR();
            var btnSave = 'Save';
            var Distri_No = 1;
            var table = $('#tbody');
            var Item_list = [];
            table.find('tr input[type=checkbox]:checked:visible').each(function (key, value) {
                debugger;
                CrAccountID = $(value).closest('tr').find('td select[name=ddlname] :selected').val();
                var $row = $(this).closest('tr');
                var shareAmount = $row.find('td input[name="txt_Doctorshare"]').val();
                var accountId = $row.find('td input[name="TxtAccountID"]').val();
                var sourceType = $row.find('td input[name="txt_SourceType"]').val();
                var billId = null;
                var billDetailId = null;
                var patientId = null;
              

                if (sourceType === 'Billing') {
                    billDetailId = $row.find('td input[name="txt_BilldetID"]').val();
                } else if (sourceType === 'Patient') {
                    patientId = $row.find('td input[name="txt_MRNo"]').val();
                } else if (sourceType === 'IPD_Share_Distribution') {
                    billId = $row.find('td input[name="txt_BillNo"]').val();
                }
                Item_list.push({
                    'Source_Type': sourceType,
                    'Bill_Detail_ID': billDetailId,
                    'Patient_ID': patientId,
                    'Bill_ID': billId,                 // ← new
                    'AccountID': accountId,
                    'shareAmount': shareAmount
                });
            });
            debugger;
            var AllItemDetail = {
                'Distri_No': Distri_No,
                'totalCr': totalCr,
                'CrAccountID': CrAccountID,
                'ItemList': Item_list
            };
            PageMethods.TranferShares(btnSave, JSON.stringify(AllItemDetail), function (res) {
                Swal.fire({
                    title: 'Data Transfer!',
                    icon: 'success',
                    showConfirmButton: false,
                    timer: 2000
                });
                setTimeout(function () {
                    window.location = "DoctorPayables_Services.aspx?ID=" + DocId;
                }, 500);
            });
        }
        function UpdateData() {
            var table = $('#tbody');
            var Update_list = [];
            var ListTransID = '';
            table.find('tr input[type=checkbox]:checked:visible').each(function (key, value) {
                Update_list.push({
                    'txt_billdetail_id': $(value).closest('tr').find('td input[name=txt_BilldetID]').val(),
                });
            });

            $.ajax({
                type: "post",
                url: "DoctorPayables_Services.aspx/Update",

                data: JSON.stringify({
                    "Update_list": Update_list,
                }),
                dataType: 'JSON',
                contentType: "application/json; charset=utf-8",
                success: function (msg) {
                    debugger;
                    Swal.fire({
                        title: 'Data Successfully Saved!',
                        icon: 'success',
                        showConfirmButton: false,
                        timer: 2000
                    });
                    setTimeout(function () {
                        location.reload();
                    }, 500);
                },
                error: function (err) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error',
                        text: err.d
                    });
                }
            });
            table.find('tr input[type=checkbox]:checked:visible').each(function (key, value) {
                debugger;
                var transIds = $(value).closest('tr').find('td input[name=txt_BilldetID]').val();
                ListTransID += ', ' + transIds;
            });
            ListTransID = ListTransID.replace(', ', '');
            var id = '<%= Request.QueryString["ID"]%>';
            if (id != "") {
                var url = 'ReportViewer.aspx?ReportName=DoctorBaseReport&ReportTitle=Doctor Share Base  Report&Doctor_ID=' + id + '&Bill_Details_ID=' + ListTransID;
                window.open(url, '_blank');
            }
        }
        function myFunction() {
            debugger;
            var input, filter, table, tr, td, i, txtValue;
            input = document.getElementById("DepSearch");
            filter = input.value.toUpperCase();
            table = document.getElementById("tbl");
            tr = table.getElementsByTagName("tr");
            for (i = 0; i < tr.length; i++) {
                td = tr[i].getElementsByTagName("td")[8];
                if (td) {
                    txtValue = td.textContent || td.innerText;
                    if (txtValue.toUpperCase().indexOf(filter) > -1) {
                        tr[i].style.display = "";
                    } else {
                        tr[i].style.display = "none";
                    }
                }
            }
        }
        var abc = false;
        function testddlchange() {
            debugger;
            var Dep = $('#ddlDepartment').find('option:selected').text();
            if (Dep == "All") {
                $("#txt_dateto").val("");
                $("#txt_datefrom").val("");
                abc = true;
                LoadPage(DocId);
            }
            else {
                var tbl = document.getElementById('tbl');
                if (Dep.trim() != '') {

                    for (var i = 1; i < tbl.rows.length; i++) {
                        if (tbl.rows[i].cells[7].innerText != Dep) {
                            var row = tbl.rows[i];
                            row.style.display = 'none';
                        }
                        else {
                            var row = tbl.rows[i];
                            row.style.display = '';
                        }
                    }
                }
                else {
                    for (var i = 1; i < tbl.rows.length; i++) {
                        var row = tbl.rows[i];
                        row.style.display = '';
                    }
                }
            }

        }
        var DocName;
        function LoadPage(DocId) {
            var stDate;
            var endDate;

            if (stDate == null) {

                var getstDate = $('#txt_datefrom').val();
                stDate = getstDate;
            }
            else {
                stDate = stDate;
            }
            if (endDate == null) {
                endDate = $('#txt_dateto').val();
            }
            else {
                endDate = endDate;
            }
            var Statusddl = $('#ddlDepartment').find('option:selected').text();
            if (Statusddl == "All" && abc == true) {

            }

            $.ajax({

                type: "POST",
                url: "DoctorPayables_Services.aspx/ViewList",
                data: JSON.stringify({
                    "DocId": DocId,
                    "startDate": stDate,
                    "endDate": endDate,
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (newdata) {
                    var data = JSON.parse(newdata.d);
                    $('#tbl tr:gt(0)').remove();
                    table = $('#tbody');
                    var totalshareAmount = 0;
                    $("#lbl_TotalAmount").html("");
                    $.each(data, function (key, value) {
                        totalshareAmount += value.Doctor_Share;
                        DocName = value.Emp_Name;
                        var BillType = value.BillType;
                        if (BillType == 01 || BillType == "01" || BillType == '01') {
                            BillType = "Private";
                        }
                        else if (BillType == 02 || BillType == "02" || BillType == '02') {
                            BillType = "Panel";
                        }
                        else {
                            BillType = "";
                        }
                        var BillDate = value.Bill_Date;
                        BillDate = moment(BillDate).format('L');
                        if (value.Department == "null" || value.Department == null || value.Department == "") {
                            value.Department = "";
                        }
                        var department = value.In_Patient_ID;
                        if (department == "null" || department == null || department == 'null' || department == "") {
                            department = "OPD";
                        }
                        else {
                            department = "IPD";
                            value.Department = "All Department";
                        }
                        var AdmissionDate = value.Admission_Date;
                        AdmissionDate = moment(AdmissionDate).format('L');
                        if (AdmissionDate == "null" || AdmissionDate == "Invalid date" || AdmissionDate == null || AdmissionDate == 'null') {
                            AdmissionDate = "";
                        }
                        var DischargeDate = value.Discharge_Date;
                        DischargeDate = moment(DischargeDate).format('L');
                        if (DischargeDate == "null" || DischargeDate == "Invalid date" || DischargeDate == null || DischargeDate == 'null') {
                            DischargeDate = "";
                        }
                        var displayBillNo = value.SourceType === 'Patient' ? value.Patient_No : value.Bill_No;
                        var hiddenBillId = value.SourceType === 'Patient' ? value.Patient_ID : value.Bill_ID;
                        var serviceName = value.Item_Name || 'Consultation Fee';
                        $("#tbody").append(
                            "<tr>" +
                            '<td><input type="checkbox" class ="chcktbl" id = "chcktbl" onchange="calculateSum()"  name="chkReport' + (key + 1) + '" value="false"/></td><td>' + (key + 1) + '</td>' +
                            '<td><input type="hidden" id="txt_BillNo' + (key + 1) + '" name="txt_BillNo" value="' + (hiddenBillId || '') + '"/>' + (displayBillNo || '') + '</td>' +
                            '<td><input type="hidden" id="txt_BillDate' + (key + 1) + '" name="txt_BillDate" value="' + BillDate + '"/>' + BillDate + '</td>' +
                            '<td style="display:none"><input type="hidden" id="txt_BilldetID' + (key + 1) + '" name="txt_BilldetID" value="' + (value.Bill_Details_ID || '') + '"/>' + (value.Bill_Details_ID || '') + '</td>' +
                            '<td><input type="hidden" id="txt_MRNo' + (key + 1) + '" name="txt_MRNo" value="' + (value.Patient_ID || '') + '"/>' + (value.Patient_No || '') + '</td>' +
                            '<td><input type="hidden" id="txt_patientName' + (key + 1) + '" name="txt_patientName" value="' + (value.Patient_ID || '') + '"/>' + (value.Full_Name || '') + '</td>' +
                            '<td><input type="hidden" id="txt_Dept' + (key + 1) + '" name="txt_Dept" value="' + (value.In_Patient_ID || '') + '"/>' + value.Test_Department + '</td>' +
                            '<td><input type="hidden" id="txt_SubDept' + (key + 1) + '" name="txt_SubDept" value="' + value.Department + '"/>' + value.Department + '</td>' +
                            '<td><input type="hidden" id="txt_AdmDate' + (key + 1) + '" name="txt_AdmDate" value="' + AdmissionDate + '"/>' + AdmissionDate + '</td>' +
                            '<td><input type="hidden" id="txtDisDate' + (key + 1) + '" name="txtDisDate" value="' + DischargeDate + '"/>' + DischargeDate + '</td>' +
                            '<td><input type="hidden" id="txt_BillType' + (key + 1) + '" name="txt_BillType" value="' + (value.BillType || '') + '"/>' + BillType + '</td>' +
                            '<td><input type="hidden" id="txt_services' + (key + 1) + '" name="txt_services" value="' + (value.Item_ID || '') + '"/>' + serviceName + '</td>' +
                            '<td style="text-align:right;"><input type="hidden" id="txt_Doctorshare' + (key + 1) + '" name="txt_Doctorshare" value="' + value.Doctor_Share + '"/>' + (addCommas(value.Doctor_Share)) + '</td>' +
                            '<td style="display:none"><input type="hidden" id="TxtAccountID' + (key + 1) + '" name="TxtAccountID" value="' + (value.Account_Id || '') + '"/>' + (value.Account_Id || '') + '</td>' +
                            '<td style="display:none"><input type="hidden" id="txt_SourceType' + (key + 1) + '" name="txt_SourceType" value="' + (value.SourceType || '') + '"/></td>' +
                            '<td><select class="ddlname" id="ddlitmeCode' + (key + 1) + '" name="ddlname"> ' + _global_payable + ' </select></td>' +
                            "</tr>");
                        if (value.isPayable == true) {
                            calculateSum();
                        }
                        else {
                            $('input[name=chkReport' + (key + 1) + ']').prop('checked', false);
                            calculateSum();
                        }
                        length++;
                    });
                    $("#lbl_TotalAmount").html(totalshareAmount.toLocaleString('en'));
                    $('#Emp_name').html(DocName);
                    $("select[name='ddlname']").select2();
                }
            });
        }
        function loadAccounts() {
            var options = ""
            $.ajax({
                type: "post",
                url: "DoctorPayables_Services.aspx/loadAccount",
                dataType: 'JSON',
                contentType: "application/json; charset=utf-8",
                async: false,
                success: function (msg) {
                    options = '<option value="0">Please Select</option>';
                    var data = JSON.parse(msg.d);
                    $.each(data, function (key, value) {
                        options += '<option value="' + value.Account_ID + '" >' + value.name + '</option>';
                    });
                    $("#ddlpayment_method").append(options);
                    $("#ddlpayment_method").select2();
                },
            });
        }
        function togglePaymentMethod() {
            var isChecked = document.getElementById("chckAccount").checked;
            document.getElementById("ddlpayment_method").disabled = !isChecked;
        }


    </Script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="row">
        <div class="col-lg-3 col-md-8 col-sm-12" style="display: flex; align-items: center; gap: 0.5rem; flex-wrap: nowrap; white-space: nowrap;">
            <label>From</label>
            <input type="text" id="txt_datefrom" style="flex: 1; min-width: 0;" />
            <label>To</label>
            <input type="text" id="txt_dateto" style="flex: 1; min-width: 0;" />
        </div>
        <div class="col-lg-1 col-md-2 col-sm-12">
            <input type="button" id="btnSearch" class="btn-primry" value="Search" />
        </div>
        <div class="col-lg-5 col-md-2 col-sm-12"></div>
        <div class="col-lg-1 col-md-4 col-sm-12">
            <input type="button" id="BtnPaid" onclick="TranferShares()" value="Paid" class="btn-primry" />
        </div>
        <div class="col-lg-1 col-md-2 col-sm-12">
            <input type="button" id="BtnSave" onclick="UpdateData();" value="Save & Print" class="btn-primry" style="display: none" />
        </div>
    </div>
    
    <div class="row">
        <div class="col-lg-2 col-md-6 col-sm-12" style="display: flex; align-items: center; gap: 0.5rem; white-space: nowrap;">
            <label for="chckAccount" style="margin: 0; cursor: pointer;">Select Account</label>
            <input type="checkbox" id="chckAccount" onclick="togglePaymentMethod()"  />
        </div>     
          <div class="col-md-2">
              <select id="ddlpayment_method" disabled="disabled"  >
              </select>
         </div>          
    </div>

    
    <div class="row" style="margin-top:15px;">        
        <div class="col-lg-3 col-md-9 col-sm-12">
            <label id="Emp_name"></label>
        </div>
        <div class="col-lg-2 col-md-6 col-sm-12"></div>
           <div class="col-lg-1 col-md-6 col-sm-12" >
            <select id ="ddlDepartment" onchange="testddlchange()">
                <option>All</option>
                <option>IPD</option>
                <option>OPD</option>
            </select>
        </div>       
        <div class="col-lg-2 col-md-6 col-sm-12">
            <input id="DepSearch" type="text" placeholder="Sub Department" onkeyup="myFunction()"/>
        </div>
        <div class="col-lg-2 col-md-6 col-sm-12">
            <input id="myInput" type="text" placeholder="Table Search.." />
        </div>
        <div class="col-lg-2 col-md-6 col-sm-12">
            <label class="sty" style="color: #438eb9; font-size: 28px;">Total:</label>&nbsp
        <label class="sty" style="background-color: yellow; font-size: 28px;" id="price" for="fname"></label>
        </div>
    </div>

    <div class="row" style="overflow:scroll;">
        <table class="table" id="tbl" style="overflow: scroll; height: auto; position:relative;">
            <thead>
                <tr >
                    <th>
                        <input type="checkbox" id="chckHead" name="chkReport" /></th>
                    <th>Sr No</th>
                    <th style="width:100px !important">Bill/OPD No</th>
                    <th>Bill Date</th>
                    <th>Mr No</th>
                    <th>Patient Name</th>
                    <th>Department</th>
                    <th>Sub Department</th>
                   <%-- <th>Test Department</th>--%>
                    <th>Date Of Admission</th>
                    <th>Date Of Discharge</th>
                    <th>Bill Type</th>
                    <th>Service Name </th>
                    <th>Doctor Share</th>
                    <th style="z-index:1;">Payment Through</th>
                </tr>
            </thead>
            <tbody id="tbody" class="font-weight-bold">
            </tbody>
        </table>
    </div>

    <div class="col-xs-12 col-sm-12 col-lg-12 col-md-12" style="text-align: right;">
        <label style="font-size: 28px; margin-left: -32px; background-color: #cecccc;">Total:</label>
        <label id="lbl_TotalAmount" style="font-size: 28px; margin-left: 20px; margin-right: 15px; background-color: #cecccc;"></label>
    </div>

</asp:Content>