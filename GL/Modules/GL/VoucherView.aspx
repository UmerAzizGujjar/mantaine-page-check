<%@ Page EnableSessionState="ReadOnly" Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="VoucherView.aspx.cs" Inherits="PMS.VoucherView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />
    <style type="text/css">
      
    .cancelled-row {
        background-color: #dc3545 !important;
        color: white !important;
    }
    .cancelled-row td {
        color: white !important;
    }
</style>

    <script type="text/javascript">

var year = false; 

$(document).ready(function () {
    var date = '<%= DateTime.Now %>';
    
    $("#txt_date").datepicker({
        changeMonth: true,
        changeYear: true,
        showButtonPanel: true,
        dateFormat: 'MM yy',
        onClose: function (dateText, inst) {
            $(this).datepicker('setDate', new Date(inst.selectedYear, inst.selectedMonth, 1));
            LoadPage(); 
        }
    });

    $('#txt_date').val('');

    var getype = '<%= Request.QueryString["VoucherType"]%>';
    if (getype === 'OPDJV') {
        $('#btn_AddNew').hide();
    }

    initDateFilter();
    LoadPage();
});

        /* ---------- Start / End date filter (default = current month) ---------- */
        function pad2(n) { return n < 10 ? '0' + n : '' + n; }
        function fmtYMD(d) { return d.getFullYear() + '-' + pad2(d.getMonth() + 1) + '-' + pad2(d.getDate()); }

        function setCurrentMonthDates() {
            var now = new Date();
            $('#txtFromDate').val(fmtYMD(new Date(now.getFullYear(), now.getMonth(), 1)));
            $('#txtToDate').val(fmtYMD(new Date(now.getFullYear(), now.getMonth() + 1, 0)));
        }

        function reloadList() {
            if ($.fn.DataTable.isDataTable('#example')) {
                $('#example').DataTable().ajax.reload();
            }
        }

        function initDateFilter() {
            setCurrentMonthDates();
            $('#chkDateFilter').prop('checked', true);
            $('#lblDateFilterState').text('Current month');

            // Toggle: ON = date filter (current month), OFF = clear dates and show all data
            $('#chkDateFilter').on('change', function () {
                if (this.checked) {
                    setCurrentMonthDates();
                    $('#txtFromDate, #txtToDate').prop('disabled', false);
                    $('#lblDateFilterState').text('Current month');
                } else {
                    $('#txtFromDate, #txtToDate').val('').prop('disabled', true);
                    $('#lblDateFilterState').text('All data');
                }
                reloadList();
            });

            $('#txtFromDate, #txtToDate').on('change', function () {
                var f = $('#txtFromDate').val(), t = $('#txtToDate').val();
                if (f && t && f > t) {
                    Swal.fire({ icon: 'warning', title: 'Invalid Date Range', text: 'Start date cannot be after end date.' });
                    return;
                }
                $('#lblDateFilterState').text('Custom range');
                reloadList();
            });
        }

        function LoadPage() {
            let savedVisibility = null;

            $.ajax({
                type: "POST",
                url: "VoucherView.aspx/GetUserColumnPreferences",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                success: function (response) {
                    if (response.d && response.d !== "") {
                        try {
                            savedVisibility = JSON.parse(response.d);
                        } catch (e) {
                            console.warn("Invalid column visibility JSON");
                        }
                    }
                },
                error: function () {
                    console.error("Failed to load column preferences");
                }
            });

            if ($.fn.DataTable.isDataTable('#example')) {
                $('#example').DataTable().clear().destroy();
            }

            $("#example").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                buttons: [
                    'copy',
                    'excel',
                    'pdf',
                    {
                        extend: 'colvis',
                        text: '<i class="fa fa-columns"></i> Columns',
                        className: 'dt-button buttons-colvis',
                        collectionLayout: 'fixed two-column',
                        postfixButtons: ['colvisRestore']
                    }
                ],
                "filter": true,
                "ajax": function (data, callback, settings) {
                    var getquerytype = '<%= Request.QueryString["VoucherType"]%>';
            var titleText = '';
            switch (getquerytype) {
                case 'CPV': titleText = 'Cash Payment Voucher'; break;
                case 'CRV': titleText = 'Cash Receipt Voucher'; break;
                case 'BPV': titleText = 'Bank Payment Voucher'; break;
                case 'BRV': titleText = 'Bank Receipt Voucher'; break;
                case 'JV': titleText = 'Journal Voucher'; break;
                case 'DPV': titleText = 'Doctor Payment Voucher'; break;
                case 'OPDJV': titleText = 'OPD Journal Voucher'; break;
                case 'ACCRCV': titleText = 'Accounts Receivable Voucher'; break;
            }
            $('#ctl00_lbl1').text(titleText);

            var getdate = $('#txt_date').val();
            var getmonth = "", getyear = "";
            if (getdate) {
                var array = getdate.split(" ");
                getmonth = array[0];
                getyear = array[1];
                var monthsMap = {
                    "January": "01", "February": "02", "March": "03", "April": "04",
                    "May": "05", "June": "06", "July": "07", "August": "08",
                    "September": "09", "October": "10", "November": "11", "December": "12"
                };
                getmonth = monthsMap[getmonth] || "";
            }

            var monthToSend = year ? "" : getmonth;

            $.ajax({
                type: "POST",
                url: "VoucherView.aspx/VoucherViewList",
                data: JSON.stringify({
                    draw: data.draw,
                    start: data.start,
                    length: data.length,
                    sortColumn: data.columns[data.order[0].column].name,
                    sortColumnDirection: data.order[0].dir,
                    searchValue: data.search.value,
                    vouchertype: getquerytype,
                    voucheryear: getyear,
                    vouchermonth: monthToSend,
                    fromDate: $('#txtFromDate').val() || '',
                    toDate: $('#txtToDate').val() || ''
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    try {
                        if (response.d && typeof response.d === 'object') {
                            var jsondata = response.d;
                            callback({
                                draw: jsondata.draw,
                                recordsTotal: jsondata.recordsTotal,
                                recordsFiltered: jsondata.recordsFiltered,
                                data: jsondata.data
                            });
                        } else {
                            console.error("Invalid response structure: ", response);
                            alert("Failed to load data. Please check the server response.");
                        }
                    } catch (e) {
                        console.error("Error processing the response: ", e);
                        alert("Error while processing the server response.");
                    }
                },
                error: function (xhr, status, error) {
                    console.log("Error: " + xhr.responseText);
                    alert("Error fetching data from server: " + xhr.responseText);
                }
            });
        },
        "columns": [
            { "data": "Voucher_ID", visible: false },
            { "data": "Voucher_No", "name": "Voucher_No", width: "7%" },
            {
                "data": "Voucher_Date",
                "name": "Voucher_Date",
                "render": function (data, type, full) {
                    return moment(full.Voucher_Date).format('D-MMM-YYYY');
                }, width: "17%"
            },
            {
                "data": "Creation_Time",
                "name": "Creation_Time",
                "render": function (data, type, full) {
                    return moment(full.Creation_Time).format('D-MMM-YYYY');
                }, width: "10%"
            },
            { "data": "Ref_Num", width: "13%" },
            { "data": "Remarks", width: "25%" },
            { "data": "TotalDebtAmt", width: "11%" },
            { "data": "Voucher_Status", width: "10%" },
            { "data": "Created_By", width: "10%" },
            { "data": "Approved_By", width: "10%" },
            {
                "render": function (data, type, full) {

                    var getquerytype = '<%= Request.QueryString["VoucherType"]%>';

                    var actionButtons = `
<a href="#" class="viewListBtn" onclick="ViewVoucher(${full.Voucher_ID}, '${full.Voucher_No}')" style="border-radius: 4px; background-color: var(--theme-accent, #EFA63E); color: var(--theme-on-accent, #fff); padding: 5px 8px;">
    <i class="fa fa-eye"></i>
</a>`;
                    if (getquerytype !== 'DPV') {
                        actionButtons += `
<a href="#" class="editListBtn" onclick="Edit(${full.Voucher_ID})" style="border-radius: 4px; background-color: #007bff; color: white; padding: 5px 8px;">
    <i class="fa fa-pencil"></i>
</a>`;
                    }

                    actionButtons += `
<a class="printListBtn" style="border-radius: 4px; background-color: #28a745; color: white; padding: 5px 8px;" href="#" onclick="PrintReport(${full.Voucher_ID})">
    <i class="fa fa-print"></i>
</a>`;

                    if (full.Voucher_Status === 'CREATED') {
                        actionButtons += `
<a href="#" class="delListBtn" onclick="deleteConfirm(${full.Voucher_ID})" style="border-radius: 4px; background-color: #dc3545; color: white; padding: 5px 8px;">
    <i class="fa fa-trash-o"></i>
</a>`;
                    }

                    return actionButtons;
                },
                width: "30%"
            }
        ],
        "createdRow": function (row, data) {
            // click anywhere on the row (not on a button) to open the voucher
            $(row).css('cursor', 'pointer');
            $(row).off('click.vview').on('click.vview', function (e) {
                if ($(e.target).closest('a, button, input').length) { return; }
                ViewVoucher(data.Voucher_ID, data.Voucher_No);
            });
        },
        "rowCallback": function (row, data, index) {
            const status = (data.Voucher_Status || '').trim();
            if (status === 'Cancalled') {
                $(row).addClass('cancelled-row');
            } else {
                $(row).removeClass('cancelled-row');
            }
        },
                "initComplete": function (settings, json) {
                    const api = this.api();
                    if (savedVisibility && Array.isArray(savedVisibility)) {
                        if (savedVisibility.length === api.columns().count()) {
                            api.columns().every(function (index) {
                                this.visible(savedVisibility[index]);
                            });
                        }
                    }
                    api.on('column-visibility.dt', function (e, settings, column, state) {
                        let currentVis = [];
                        api.columns().every(function () {
                            currentVis.push(this.visible());
                        });
                        PageMethods.SaveUserColumnPreferences(
                            JSON.stringify(currentVis),
                            function () {
                                console.log("Column preferences saved");
                            },
                            function (error) {
                                console.error("Failed to save preferences:", error);
                            }
                        );
                    });

                    var lengthContainer = document.querySelector('#example_length');
                    var lengthDropdown = document.querySelector('#example_length select');
                    var label = document.querySelector('#example_length label');

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
                }
    });
  }

function LoadPageByYear() {
    year = true;
    LoadPage();
}

 // GL lines and bills of one voucher, shown in a popup (same view as Pharmacy Pending Bills)
function vEsc(v) {
    if (v === null || v === undefined) { return ''; }
    return String(v)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#39;');
}

function vMoney(v) {
    return Number(v || 0).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
}

function ViewVoucher(id, no) {
    $.ajax({
        type: 'POST',
        url: 'VoucherView.aspx/GetVoucherDetail',
        data: JSON.stringify({ voucherId: String(id) }),
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        success: function (response) {
            var d = JSON.parse(response.d);
            if (d.status !== 'Approved') {
                Swal.fire({ icon: 'info', title: 'Voucher No ' + no, text: 'Only approved vouchers can be viewed. Status: ' + (d.status || 'unknown') });
                return;
            }

            var billRows = (d.bills || []).map(function (b) {
                return '<tr><td>' + vEsc(b.Seq_InvoiceNo) + '</td><td>' + vEsc(b.Customer_Name) + '</td>' +
                       '<td style="text-align:right;">' + vMoney(b.Total_Amount) + '</td>' +
                       '<td style="text-align:right;">' + vMoney(b.Discount_Amount) + '</td>' +
                       '<td style="text-align:right;">' + vMoney(b.Received_Amount) + '</td>' +
                       '<td style="text-align:right;">' + vMoney(b.Balance_Amount) + '</td></tr>';
            }).join('');

            var lineRows = (d.lines || []).map(function (l) {
                return '<tr><td>' + vEsc(l.Account_Code) + '</td><td>' + vEsc(l.Account_Name) + '</td>' +
                       '<td>' + vEsc(l.Narration) + '</td>' +
                       '<td style="text-align:right;">' + vMoney(l.DR) + '</td>' +
                       '<td style="text-align:right;">' + vMoney(l.CR) + '</td></tr>';
            }).join('');

            var billPart = billRows
                ? '<table class="table table-bordered table-condensed"><thead><tr><th>Bill No</th><th>Customer</th>' +
                  '<th style="text-align:right;">Total</th><th style="text-align:right;">Discount</th>' +
                  '<th style="text-align:right;">Received</th><th style="text-align:right;">Balance</th></tr></thead>' +
                  '<tbody>' + billRows + '</tbody></table>'
                : '<p class="text-muted">No bills are linked to this voucher.</p>';

            var html =
                '<h4 style="text-align:left;">Bills in this voucher</h4>' + billPart +
                '<h4 style="text-align:left;">GL lines</h4>' +
                '<table class="table table-bordered table-condensed"><thead><tr><th>Account Code</th><th>Account</th>' +
                '<th>Narration</th><th style="text-align:right;">DR</th><th style="text-align:right;">CR</th></tr></thead>' +
                '<tbody>' + lineRows + '</tbody></table>';

            Swal.fire({ title: 'Voucher No ' + no, html: html, width: 960, confirmButtonText: 'Close' });
        },
        error: function () {
            Swal.fire('Error', 'Failed to load the voucher.', 'error');
        }
    });
}

function PrintReport(ID) {
    var getype = '<%= Request.QueryString["VoucherType"]%>'
    var locationInfo = window.location;
    var user_name = '<% =AppConfig.Company_Name %>';
    if (user_name == 'As-Siraat Serving Humanity') {
        reportPath = '../../ReportViewer.aspx';
    } else {
        reportPath = 'ReportViewer.aspx'; // same folder
    }

     var url = '/ReportViewer.aspx?ReportName=Voucher&TransID=' + ID + '&TransType=' + getype;
    if (!locationInfo.origin.includes('localhost')) {
        var urlInfo = window.location.href.split('/');
        var ip = urlInfo[2];
        var foldername = urlInfo[3];

        url = 'http://' + ip + '/' + foldername + '/' + reportPath + '?ReportName=Voucher&TransID=' + ID + '&TransType=' + getype;
    }
    //window.location.href = url;
    window.open(url, '_blank');
}

function Edit(ID) {
    var getype = '<%= Request.QueryString["VoucherType"]%>'
    
    window.location.href = "Voucher.aspx?VoucherType=" + getype + "&VID=" + ID;
}

function deleteConfirm(ID) {
    var VOUCHERID = ID;
    if (confirm('Are you sure want to delete this record')) {
        PageMethods.DeleteRecord(VOUCHERID, function (msg) {
            location.reload();
        });
    }
}

function redirecttonew() {
    var getype = '<%= Request.QueryString["VoucherType"]%>'
    window.location.href = "Voucher.aspx?VoucherType=" + getype;
}

    </script>


</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
        <div class="col-lg-12 col-md-12 col-sm-12 opd-date-filter" style="margin-bottom: 15px;">
            <label class="fl" for="txtFromDate">Start Date</label>
            <input type="date" id="txtFromDate" class="form-control" />
            <label class="fl" for="txtToDate">End Date</label>
            <input type="date" id="txtToDate" class="form-control" />
            <label class="fl" for="chkDateFilter">Date Filter</label>
            <label class="opd-switch" title="Off = clear dates and show all data">
                <input type="checkbox" id="chkDateFilter" checked="checked" />
                <span class="opd-slider"></span>
            </label>
            <span id="lblDateFilterState" class="text-muted">Current month</span>
        </div>
    </div>
    <div class="row">
        <div class="col-lg-9 col-md-8 col-sm-8">
            <div class="row">
                <div class="col-lg-2 col-md-4 col-sm-6">
                    <input type="text" id="txt_date" style="width: 100% !important" />
                </div>
                <div class="col-lg-8-col-md-8 col-sm-8">
                    <div class="col-lg-2 col-md-4 col-sm-6">
                        <input type="button" class="btn btn-primry" onclick="LoadPageByYear()" value="Year" style="width: 100% !important" />
                    </div>
                    <div class="col-lg-2 col-md-4 col-sm-6" style="margin-bottom: 1%">
                        <input type="button" id="btn_AddNew" class="btn btn-primry" onclick="redirecttonew()" value="Add New" style="width: 100% !important;" />
                    </div>
                </div>
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
                    <th>Refer Num</th>
                    <th id="th-descptn">Description</th>
                    <th>Amount</th>
                    <th>Status</th>
                    <th>Created By</th>
                    <th>Approved By</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody id="tblbody">
            </tbody>
        </table>
    </div>

</asp:Content>
