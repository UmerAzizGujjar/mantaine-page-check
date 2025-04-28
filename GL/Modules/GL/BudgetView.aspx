<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="BudgetView.aspx.cs" Inherits="PMS.BudgetView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link rel="stylesheet" href="../../wwwroot/table-style/bootstrap.css">
    <link rel="stylesheet" href="../../wwwroot/table-style/jquery-ui.css">
    <link rel="stylesheet" href="../../wwwroot/table-style/dataTables.jqueryui.min.css">
    <link rel="stylesheet" href="../../wwwroot/table-style/bootstrap.css">
    <link rel="stylesheet" href="../../wwwroot/table-style/jquery-ui.css">
    <link rel="stylesheet" href="../../wwwroot/table-style/dataTables.jqueryui.min.css">
    <script src="../../wwwroot/table-style/jquery.dataTables.min.js"></script>
    <script src="../../wwwroot/table-style/dataTables.jqueryui.min.js"></script>
    <script src="../../wwwroot/table-style/datatables.buttons.min.js"></script>
    <script src="../../wwwroot/table-style/buttons.jqueryui.min.js"></script>
    <script src="../../wwwroot/table-style/jszip.min.js"></script>
    <script src="../../wwwroot/table-style/pdfmake.min.js"></script>
    <script src="https://cdn.datatables.net/buttons/2.2.3/js/datatables.buttons.min.js"></script>
    <script src="../../wwwroot/table-style/vfs_fonts.js"></script>
    <script src="../../wwwroot/table-style/buttons.html5.min.js"></script>
    <script src="../../wwwroot/table-style/buttons.print.min.js"></script>
    <script src="../../wwwroot/table-style/buttons.colvis.min.js"></script>
    <script src="../../wwwroot/table-style/buttons.print.min.js"></script>
    <style type="text/css">
        input {
            width: auto !important;
        }

        .sidebar.h-sidebar .nav-list > li > a {
            text-align: center !important;
            line-height: 22px !important;
            height: auto !important;
            font-family: Arial, sans-serif !important;
            padding: 10px 14px !important;
            font-weight: bold !important;
        }

        #th-brnch {
            width: 200px !important;
        }

        .nav-list > li .submenu > li.hover > a {
            font-size: 13px !important;
            font-family: Arial, sans-serif !important;
            font-weight: bold !important;
        }

        .table {
            width: 100%;
            font-size: small;
            line-height: 1.5px;
            font-weight: 400 !important;
        }

            .table > tbody > tr > td {
                line-height: 0.75;
            }

            .table > thead > tr > th {
                line-height: 0.75;
            }

        .dataTables_wrapper .dataTables_paginate {
            font-size: small;
            width: 300px;
        }



        .buttons-copy {
            width: 20%;
            border-radius: 12px;
            background-color: #8b8f8c !important;
            color: white !important;
        }

        .buttons-excel {
            width: 20%;
            border-radius: 12px;
            background-color: #5e8a6a !important;
            color: white !important;
        }

        .buttons-pdf {
            width: 20%;
            border-radius: 12px;
            background-color: #e04343 !important;
            color: white !important;
        }

        .buttons-colvis {
            width: 38%;
            border-radius: 12px;
            background-color: #4052a1 !important;
            color: white !important;
        }

        div.dt-buttons {
            position: relative;
            float: left;
            width: 34%;
        }

        .ui-button-text-only .ui-button-text {
            font-weight: 900;
        }

        .dataTables_info {
            font-size: 14px;
            font-weight: 700 !important;
        }

        .dataTables_wrapper .ui-toolbar {
            padding: 3px;
        }

        table.dataTable thead th div.DataTables_sort_wrapper span {
            display: none;
        }

        #txt_date {
            height: 32px;
        }

        #check {
            width: 5% !important;
        }



        .dataTables_filter input {
            border-radius: 15px !important;
        }

        body {
            font-weight: 700;
        }

        #ui-datepicker-div {
            width: 20% !important;
        }

        .main input {
            margin-bottom: 6px !important;
            margin-top: 5px !important;
        }

        .fa-pencil {
            color: green !important;
        }

        .fa-print {
            color: darkblue !important;
        }

        td {
            line-height: 15px !important;
        }

        #th-descptn {
            width: 200px !important;
        }
    </style>

    <script type="text/javascript">
        var year = false;
        debugger;
        function LoadPage() {
            var tablesss;
            tablesss = $('#example').DataTable();
            tablesss.clear();
            var getdate = $('#txt_date').val();
            var str = getdate;
            var array = str.split(" ");
            var getmonth = array[0];
            var getyear = array[1];
            if (getmonth == "January" || getmonth == "") {
                getmonth = "01"
            }
            if (getmonth == "February") {
                getmonth = "02"
            }
            if (getmonth == "March") {
                getmonth = "03"
            }
            if (getmonth == "April") {
                getmonth = "04"
            }
            if (getmonth == "May") {
                getmonth = "05"
            }
            if (getmonth == "June") {
                getmonth = "06"
            }
            if (getmonth == "July") {
                getmonth = "07"
            }
            if (getmonth == "August") {
                getmonth = "08"
            }
            if (getmonth == "September") {
                getmonth = "09"
            }
            if (getmonth == "October") {
                getmonth = "10"
            }
            if (getmonth == "November") {
                getmonth = "11"
            }
            if (getmonth == "December") {
                getmonth = "12"
            }
            debugger;
            $.ajax({
                type: "POST",
                url: "BudgetView.aspx/VoucherViewList",
                data: JSON.stringify({
                    "month": getmonth,
                    "year": getyear,
                    "checkyear": year

                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    var table;
                    table = $('#example').DataTable();
                    var length = $("#example tr:gt(0)").length;
                    if (data != '') {
                        var data = JSON.parse(data.d);
                        var abc = '<td><i class="ace-icon fa fa-pencil bigger-130"></i><i class="ace-icon fa fa-trash bigger-130" onclick="deleteConfirm(this)" id="btnDel"></i><i class="ace-icon fa fa-print bigger-130" id="btnprint"></i></td>'
                        $.each(data, function (i, item) {
                            debugger;
                            var vdate = new Date(parseInt(data[i].Budget_Date.substr(6)));
                            vdate = moment(vdate).format('L');
                            var cDate = new Date(parseInt(data[i].Creation_Time.substr(6)));
                            var months = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"];
                            var monthName = months[cDate.getMonth()];
                            var yearName = cDate.getFullYear();
                            var c_year = yearName;
                            cDate = moment(cDate).format('L');
                            var c_month = monthName;
                            var voucherStatus = data[i].Budget_Status;
                            var rowColor = '';
                            if (voucherStatus === "Cancelled") {
                                rowColor = '#ffcccc';
                            }
                            var row = table.row.add([
                                length, data[i].Budget_No + "-" + monthName + "-" + yearName, vdate, cDate, data[i].Remarks, data[i].Total_Debit, data[i].Budget_Status,
                                '<td><a href="#" onclick="Edit(' + data[i].Budget_ID + ')" style="border-radius: 4px; background-color: #d4b7e7; color: black; padding: 4px 11px;">View</a><a style="border-radius: 4px;background-color: #e98383;color: white;padding: 4px 11px;" href="#" onclick="PrintReport(' + data[i].Budget_ID + ')" id="btnprint' + (i + 1) + '" name="btnprint">Print</a><a href="#" onclick="deleteConfirm(' + data[i].Budget_ID + ')" id="btnDel' + (i + 1) + '" name="btnDel" style="border-radius: 4px;background-color: #e98383;color: white;padding: 4px 11px;">Delete</a><a href="#" onclick="ApproveBudget(' + data[i].Budget_ID + ')" id="btnApprove' + (i + 1) + '" name="btnApprove" style="border-radius: 4px;background-color: #519e7e;color: white;padding: 4px 11px;">Approve</a></td>'
                            ]).node();
                            $(row).css('background-color', rowColor);
                            length++;
                        });
                        table.draw();
                    }
                    else {
                        $('#example').html('<h3>No users are available</h3>');
                    }
                    year = false;
                    debugger;
                    $.each(data, function (key, value) {
                        debugger;
                        if (data[key].Budget_Status != "Created") {
                            debugger;
                            $('#btnDel' + (key + 1) + '').hide();
                            $('#btnApprove' + (key + 1) + '').hide();
                        }
                        if (data[key].Budget_Status == "Created") {
                            $('#btnprint' + (key + 1) + '').hide();
                            $('#btnApprove' + (key + 1) + '').show();
                        }
                    });
                }
            });
        }
        var globalvalue = 0;
        function addCommas(num) {
            globalvalue = 0;
            debugger;
            var str = num.toString().split('.');
            if (str[0].length >= 4) {
                str[0] = str[0].replace(/(\d)(?=(\d{3})+$)/g, '$1,');
            }
            globalvalue = str.join('.');
        }
        function LoadPageByYear() {
            year = true;
            LoadPage();
        }
        $(document).ready(function () {
            var date = '<%= DateTime.Now%>';
            $("#txt_date").datepicker({
                changeMonth: true,
                changeYear: true,
                showButtonPanel: true,
                dateFormat: 'MM yy',
                onClose: function (dateText, inst) {
                    $(this).datepicker('setDate', new Date(inst.selectedYear, inst.selectedMonth, 1));
                }
            });
            date = moment(date).format('MMMM YYYY');
            $('#txt_date').val(date)

            $('#ctl00_lblMessage').hide();
            var table = $('#example').DataTable({
                lengthChange: false,
                buttons: ['copy', 'excel', 'pdf']
            });
            table.buttons().container()
                .insertBefore('#example_filter');
            LoadPage();
            var date = '<%= DateTime.Now%>';
            $("#txt_date").datepicker({ dateFormat: 'mm/dd/yy' }).attr('readonly', 'readonly');
            date = moment(date).format('L');
            $('#txt_date').val(date)
        });
        function PrintReport(ID) {
            var locationInfo = window.location;
            var url = '/ReportViewer.aspx?ReportName=Budget_Voucher&Budget_ID=' + ID;
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];

                url = 'http://' + ip + '/' + foldername + '/ReportViewer.aspx?ReportName=Budget_Voucher&Budget_ID=' + ID;
            }
            window.location.href = url;
        }
        function Edit(ID) {
            window.location.href = "Budget.aspx?VID=" + ID;
        }
        function deleteConfirm(ID) {
            debugger;
            var BugetID = ID;
            if (confirm('Are you sure want to delete this record')) {
                PageMethods.DeleteRecord(BugetID, function (msg) {
                    debugger;
                    location.reload();
                });
            }
        }

        function ApproveBudget(ID) {
            debugger;
            var BugetID = ID;
            PageMethods.ApproveRecord(BugetID, function (msg) {
                debugger;
                if (msg) {
                    alert("Approved successfully");
                    location.reload();
                } else {
                    alert("Approval failed. Please try again.");
                }
            }, function (error) {
                debugger;
                alert("An error occurred: " + error.get_message());
            });
        }
        function redirecttonew() {
            window.location.href = "Budget.aspx";
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
        <div class="col-lg-9">
            <div class="col-lg-2 col-md-4 col-sm-12">
                <input type="button" class="btn btn-primry" onclick="redirecttonew()" value="Add New"/>
            </div>
            <div class="col-lg-3 col-md-4 col-sm-12">
                <input type="text" id="txt_date" />
            </div>
            <div class="col-lg-2 col-md-4 col-sm-12">
                <input type="button" class="btn btn-primry" onclick="LoadPage()" value="Month"/>
            </div>
            <div class="col-lg-2 col-md-4 col-sm-12">
                <input type="button" class="btn btn-primry" onclick="LoadPageByYear()" value="Year"/>
            </div>
        </div>
    </div>

    <div class="table-container">
        <table id="example" class="table table-hover table-bordered">
            <thead>
                <tr>
                    <th>SR#</th>
                    <th>Voucher No</th>
                    <th>Voucher Date</th>
                    <th>Creation Date</th>
                    <th id="th-descptn">Description</th>
                    <th>Amount</th>
                    <th>Status</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody id="tblbody">
            </tbody>
        </table>
    </div>
</asp:Content>
