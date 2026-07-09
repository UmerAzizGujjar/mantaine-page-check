<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="DoctorPayables_Services.aspx.cs" Inherits="PMS.Modules.Billing.DoctorPayables_Services" %>



<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />
    <link href="../../../wwwroot/THEME_TIBBIT/CustomCSS/Billing.css" rel="stylesheet" />

    <style type="text/css">
        #tbl { width: 100% !important; }

        #tbl_wrapper .dataTables_filter label::before {
            content: none !important;
        }

        #tbl thead th {
            background-color: #EFA63E !important;
            color: #fff !important;
            border: 1px solid #e8972e !important;
            white-space: nowrap;
            vertical-align: middle;
            text-align: center;
            font-weight: 700;
            font-size: 13px;
        }

        #tbl tbody td {
            font-size: 12px;
            vertical-align: middle;
            padding: 6px 4px;
        }

        #tbl tbody tr:hover {
            background-color: #fff8e5 !important;
        }

        .selected-badge {
            background-color: #EFA63E;
            color: #fff;
            padding: 6px 16px;
            border-radius: 6px;
            font-weight: 700;
            font-size: 15px;
            display: inline-block;
        }

        .selected-badge .selected-amount {
            font-weight: 800;
            font-size: 17px;
        }

        .grand-badge {
            background-color: #444;
            color: #fff;
            padding: 6px 20px;
            border-radius: 6px;
            font-weight: 700;
            font-size: 16px;
            display: inline-block;
        }

        .grand-badge .grand-amount {
            font-weight: 800;
            font-size: 18px;
        }

        #chckAccount {
            width: 18px !important;
            height: 18px;
            cursor: pointer;
        }

        .widthdate {
            width: 100% !important;
            border-radius: 5px !important;
        }

        .filter-row {
            margin-bottom: 10px;
            align-items: center;
        }

        .filter-row label {
            font-weight: 600;
            font-size: 13px;
            color: #555;
            margin-bottom: 2px;
        }
    </style>

    <script type="text/javascript">
        var _global_payable = '';
        var DocId = "<%= Request.QueryString["ID"] %>";
        var oTable;
        var DocName;

        $(document).ready(function () {
            LoadPage(DocId);
            loadacc();
            loadAccounts();

            $('#ddlpayment_method').on('change', function () {
                var val = $(this).val();
                $('.ddlname').each(function () {
                    $(this).val(val).trigger('change');
                });
            });

            $("#txt_dateto").datepicker({ dateFormat: 'mm/dd/yy' }).attr('readonly', 'readonly');
            $("#txt_datefrom").datepicker({ dateFormat: 'mm/dd/yy' }).attr('readonly', 'readonly');

            var checkeditmode_startdate = '<%= Request.QueryString["stDate"]%>';
            var checkeditmode_enddate = '<%= Request.QueryString["endDate"]%>';
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
                if (oTable) {
                    oTable.rows({ search: 'applied' }).every(function () {
                        var $row = $(this.node());
                        $row.find('input[type="checkbox"]').prop('checked', isTrue);
                    });
                }
                calculateSum();
            });
        });

        function initSelect2() {
            $("select[name='ddlname']").each(function () {
                if (!$(this).data('select2')) {
                    $(this).select2();
                }
            });
        }

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
            if (oTable) {
                oTable.rows({ search: 'applied' }).every(function () {
                    var $row = $(this.node());
                    if ($row.find('input[type="checkbox"]').is(':checked')) {
                        var $txtamount = $row.find('td input[name="txt_Doctorshare"]').val();
                        sumTotal += parseInt($txtamount) || 0;
                    }
                });
            }
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
            totalCr = 0;
            if (oTable) {
                oTable.rows({ search: 'applied' }).every(function () {
                    var $row = $(this.node());
                    if ($row.find('input[type="checkbox"]').is(':checked')) {
                        var crside = $row.find('td input[name=txt_Doctorshare]').val();
                        totalCr += parseFloat(crside) || 0;
                    }
                });
            }
        }

        var CrAccountID = 0;
        function TranferShares() {
            getTotal_CR_DR();
            var btnSave = 'Save';
            var Distri_No = 1;
            var Item_list = [];
            if (oTable) {
                oTable.rows({ search: 'applied' }).every(function () {
                    var $row = $(this.node());
                    if ($row.find('input[type="checkbox"]').is(':checked')) {
                        CrAccountID = $row.find('td select[name=ddlname] :selected').val();
                        var shareAmount = $row.find('td input[name="txt_Doctorshare"]').val();
                        var accountId = $row.find('td input[name="TxtAccountID"]').val();
                        var sourceType = $row.find('td input[name="txt_SourceType"]').val();
                        var billDetailId = null;
                        var patientId = null;
                        if (sourceType === 'Billing') {
                            billDetailId = $row.find('td input[name="txt_BilldetID"]').val();
                        } else if (sourceType === 'Patient') {
                            patientId = $row.find('td input[name="txt_MRNo"]').val();
                        }
                        Item_list.push({
                            'Source_Type': sourceType,
                            'Bill_Detail_ID': billDetailId,
                            'Patient_ID': patientId,
                            'AccountID': accountId,
                            'shareAmount': shareAmount
                        });
                    }
                });
            }
            var AllItemDetail = {
                'Distri_No': Distri_No,
                'totalCr': totalCr,
                'CrAccountID': CrAccountID,
                'ItemList': Item_list
            };
            PageMethods.TranferShares(btnSave, JSON.stringify(AllItemDetail), function (res) {
                Swal.fire({
                    title: "Data Transfer!",
                    icon: "success",
                    showConfirmButton: false,
                });
                window.location = "DoctorPayables_Services.aspx?ID=" + DocId;
            });
        }

        function UpdateData() {
            var Update_list = [];
            var ListTransID = '';
            if (oTable) {
                oTable.rows({ search: 'applied' }).every(function () {
                    var $row = $(this.node());
                    if ($row.find('input[type="checkbox"]').is(':checked')) {
                        Update_list.push({
                            'txt_billdetail_id': $row.find('td input[name=txt_BilldetID]').val(),
                        });
                        var transIds = $row.find('td input[name=txt_BilldetID]').val();
                        ListTransID += ', ' + transIds;
                    }
                });
            }
            ListTransID = ListTransID.replace(', ', '');
            $.ajax({
                type: "post",
                url: "DoctorPayables_Services.aspx/Update",
                data: JSON.stringify({ "Update_list": Update_list }),
                dataType: 'JSON',
                contentType: "application/json; charset=utf-8",
                success: function (msg) {
                    Swal.fire({
                        title: "Data Successfully Save!",
                        icon: "success",
                        showConfirmButton: false,
                    });
                    location.reload();
                },
                error: function (err) {
                    Swal.fire({
                        title: "Error",
                        text: err.d,
                        icon: "error",
                    });
                }
            });
            var id = '<%= Request.QueryString["ID"]%>';
            if (id != "") {
                var url = 'ReportViewer.aspx?ReportName=DoctorBaseReport&ReportTitle=Doctor Share Base  Report&Doctor_ID=' + id + '&Bill_Details_ID=' + ListTransID;
                window.open(url, '_blank');
            }
        }

        function testddlchange() {
            var Dep = $('#ddlDepartment').find('option:selected').text();
            if (Dep == "All") {
                if (oTable) oTable.column(7).search('').draw();
            } else {
                if (oTable) oTable.column(7).search(Dep).draw();
            }
        }

        function LoadPage(DocId) {
            var stDate = $('#txt_datefrom').val();
            var endDate = $('#txt_dateto').val();

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

                    if (oTable) {
                        oTable.destroy();
                        $('#tbody').empty();
                    }

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
                            '<td><input type="hidden" id="txt_Dept' + (key + 1) + '" name="txt_Dept" value="' + (value.In_Patient_ID || '') + '"/>' + department + '</td>' +
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
                            $('input[name=chkReport' + (key + 1) + ']').prop('checked', true);
                        } else {
                            $('input[name=chkReport' + (key + 1) + ']').prop('checked', false);
                        }
                    });

                    $("#lbl_TotalAmount").html(totalshareAmount.toLocaleString('en'));
                    $('#Emp_name').html(DocName);

                    oTable = $('#tbl').DataTable({
                        "dom": 'lBfrtip',
                        "buttons": [
                            'copy', 'excel', 'pdf',
                            {
                                extend: 'colvis',
                                text: '<i class="fa fa-columns"></i> Columns',
                                className: 'dt-button buttons-colvis',
                                collectionLayout: 'fixed two-column',
                                postfixButtons: ['colvisRestore']
                            }
                        ],
                        "columnDefs": [
                            { "targets": 0, "orderable": false, "searchable": false, "width": "3%" },
                            { "targets": 1, "width": "3%", "className": "text-center" },
                            { "targets": 2, "width": "5%" },
                            { "targets": 3, "width": "7%" },
                            { "targets": 4, "visible": false, "searchable": false },
                            { "targets": 5, "width": "4%" },
                            { "targets": 6, "width": "12%" },
                            { "targets": 7, "width": "4%" },
                            { "targets": 8, "width": "6%" },
                            { "targets": 9, "width": "6%" },
                            { "targets": 10, "width": "6%" },
                            { "targets": 11, "width": "5%" },
                            { "targets": 12, "width": "10%" },
                            { "targets": 13, "width": "6%", "className": "text-right" },
                            { "targets": 14, "visible": false, "searchable": false },
                            { "targets": 15, "visible": false, "searchable": false },
                            { "targets": 16, "width": "10%" }
                        ],
                        "paging": true,
                        "pageLength": 25,
                        "ordering": true,
                        "order": [[3, 'desc']],
                        "language": {
                            "search": "",
                            "searchPlaceholder": "Search..."
                        },
                        "initComplete": function (settings, json) {
                            initSelect2();
                            var lengthContainer = document.querySelector('#tbl_length');
                            var lengthDropdown = document.querySelector('#tbl_length select');
                            var label = document.querySelector('#tbl_length label');
                            if (lengthDropdown && label && lengthContainer) {
                                var labelText = document.createElement('span');
                                labelText.textContent = 'Show entries ';
                                labelText.style.marginTop = '10px';
                                labelText.style.display = 'inline-block';
                                lengthDropdown.style.width = '60px';
                                label.innerHTML = '';
                                label.style.display = 'inline-flex';
                                label.style.marginTop = '17px';
                                label.appendChild(labelText);
                                label.appendChild(lengthDropdown);
                            }
                        },
                        "drawCallback": function () {
                            initSelect2();
                            calculateSum();
                        }
                    });

                    calculateSum();
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
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="row filter-row">
        <div class="col-lg-1 col-md-2 col-sm-3">
            <label>Dept</label>
            <select id="ddlDepartment" onchange="testddlchange()" style="width:100%;">
                <option>All</option>
                <option>IPD</option>
                <option>OPD</option>
            </select>
        </div>
        <div class="col-lg-2 col-md-3 col-sm-4">
            <label>From</label>
            <input type="text" id="txt_datefrom" class="widthdate" />
        </div>
        <div class="col-lg-2 col-md-3 col-sm-4">
            <label>To</label>
            <input type="text" id="txt_dateto" class="widthdate" />
        </div>
        <div class="col-lg-1 col-md-3 col-sm-3" style="margin-top:22px;">
            <input type="button" id="btnSearch" class="btn-primry" value="Search" style="padding:7px 14px;font-size:13px;" />
        </div>
        <div class="col-lg-1 col-md-3 col-sm-3" style="margin-top:22px;">
            <input type="button" id="BtnPaid" onclick="TranferShares()" value="Paid" class="btn-primry" style="padding:7px 14px;font-size:13px;" />
        </div>
        <div class="col-lg-1 col-md-3 col-sm-3" style="margin-top:22px;display:none;">
            <input type="button" id="BtnSave" onclick="UpdateData();" value="Save &amp; Print" class="btn-primry" style="padding:7px 14px;font-size:13px;" />
        </div>
    </div>

    <div class="row filter-row">
        <div class="col-lg-8 col-md-12" style="display:flex;align-items:center;gap:10px;flex-wrap:wrap;">
            <span style="font-weight:700;font-size:16px;color:#EFA63E;" id="Emp_name"></span>
           
        </div>
        <div class="col-lg-4 col-md-12 text-right">
            <span class="selected-badge">
                Selected: <span class="selected-amount" id="price">0</span>
            </span>
        </div>
    </div>
    <div class="row">
         <div style="display:flex;align-items:center;gap:5px;margin-left: 12px;">
     <input type="checkbox" id="chckAccount" onclick="togglePaymentMethod()" />
     <label for="chckAccount" style="margin:0;font-weight:600;font-size:13px;cursor:pointer;white-space:nowrap;">Select Account</label>
 </div>
        <div class="col-lg-4 col-md-12" style="margin-top:10px">
 <select id="ddlpayment_method" disabled="disabled" ></select>
            </div>
    </div>

    <div class="row">
        <div class="col-lg-12">
            <table class="table table-hover table-striped table-bordered" id="tbl" style="width:100%;">
                <thead>
                    <tr>
                        <th><input type="checkbox" id="chckHead" name="chkReport" /></th>
                        <th>Sr No</th>
                        <th>Bill/OPD No</th>
                        <th>Bill Date</th>
                        <th style="display:none;">Bill Detail ID</th>
                        <th>Mr No</th>
                        <th>Patient Name</th>
                        <th>Department</th>
                        <th>Sub Department</th>
                        <th>Admission Date</th>
                        <th>Discharge Date</th>
                        <th>Bill Type</th>
                        <th>Service Name</th>
                        <th>Doctor Share</th>
                        <th style="display:none;">Account ID</th>
                        <th style="display:none;">Source Type</th>
                        <th>Payment Through</th>
                    </tr>
                </thead>
                <tbody id="tbody" class="font-weight-bold">
                </tbody>
            </table>
        </div>
    </div>

    <div class="row" style="margin-top:10px;">
        <div class="col-lg-12 text-right">
            <span class="grand-badge">
                Grand Total: <span class="grand-amount" id="lbl_TotalAmount">0</span>
            </span>
        </div>
    </div>

</asp:Content>
