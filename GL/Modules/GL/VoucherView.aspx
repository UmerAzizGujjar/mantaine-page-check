<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="VoucherView.aspx.cs" Inherits="PMS.VoucherView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/Tibbit_theme/css/tablestyle.css" rel="stylesheet" />
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
    LoadPage();
});

function LoadPage() {
    if ($.fn.DataTable.isDataTable('#example')) {
        $('#example').DataTable().clear().destroy();
    }

    $("#example").DataTable({
        "processing": true,
        "serverSide": true,
        "dom": 'lBfrtip',
        "lengthChange": true,
        "buttons": ['copy', 'excel', 'pdf'],
        "filter": true,
        "ajax": function (data, callback, settings) {
            var getquerytype = '<%= Request.QueryString["VoucherType"]%>';
            var titleText = '';
            switch(getquerytype) {
                case 'CPV': titleText = 'Cash Payment Voucher'; break;
                case 'CRV': titleText = 'Cash Receipt Voucher'; break;
                case 'BPV': titleText = 'Bank Payment Voucher'; break;
                case 'BRV': titleText = 'Bank Receipt Voucher'; break;
                case 'JV': titleText = 'Journal Voucher'; break;
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
                    vouchermonth: monthToSend
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
                    var actionButtons = `
<a href="#" class="editListBtn" onclick="Edit(${full.Voucher_ID})" style="border-radius: 4px; background-color: #007bff; color: white; padding: 5px 8px;"><i class="fa fa-pencil"></i></a>
<a class="printListBtn" style="border-radius: 4px; background-color: #28a745; color: white; padding: 5px 8px;" href="#" onclick="PrintReport(${full.Voucher_ID})"><i class="fa fa-print"></i></a>`;

                    if (full.Voucher_Status === 'CREATED') {
                        actionButtons += `
<a href="#" class="delListBtn" onclick="deleteConfirm(${full.Voucher_ID})" style="border-radius: 4px; background-color: #dc3545; color: white; padding: 5px 8px;"><i class="fa fa-trash-o"></i></a>`;
                    }

                    return actionButtons;
                }, width: "30%"
            }
        ],
        "rowCallback": function (row, data, index) {
            const status = (data.Voucher_Status || '').trim();
            if (status === 'Cancalled') {
                $(row).addClass('cancelled-row');
            } else {
                $(row).removeClass('cancelled-row');
            }
        },
        "initComplete": function (settings, json) {
            var lengthContainer = document.querySelector('#example_length');
            var lengthDropdown = document.querySelector('#example_length select');
            var label = document.querySelector('#example_length label');

            if (lengthDropdown && label && lengthContainer) {
                var labelText = document.createElement('span');
                labelText.textContent = 'Show entries';
                labelText.style.marginLeft = '5px';
                labelText.style.marginTop = '10px';
                labelText.style.display = 'inline-block';

                lengthDropdown.style.width = '60px';

                label.innerHTML = '';
                label.style.display = 'inline-flex';
                label.style.alignItems = 'center';
                label.style.marginTop = '17px';
                label.appendChild(labelText);
                label.appendChild(lengthDropdown);
            } else {
                console.log("Length dropdown, label, or container not found");
            }
        }
    });
}

function LoadPageByYear() {
    year = true;
    LoadPage();
}

function PrintReport(ID) {
    var locationInfo = window.location;
    var user_name = '<% =AppConfig.Company_Name %>';
    if (user_name == 'As-Siraat Serving Humanity') {
        reportPath = '../../ReportViewer.aspx';
    } else {
        reportPath = 'ReportViewer.aspx'; // same folder
    }

    var url = '/ReportViewer.aspx?ReportName=Voucher_GL&Voucher_ID=' + ID;
    if (!locationInfo.origin.includes('localhost')) {
        var urlInfo = window.location.href.split('/');
        var ip = urlInfo[2];
        var foldername = urlInfo[3];

        url = 'http://' + ip + '/' + foldername + '/' + reportPath +  '?ReportName=Voucher_GL&Voucher_ID=' + ID;
    }
    window.location.href = url;
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
                        <input type="button" class="btn btn-primry" onclick="redirecttonew()" value="Add New" style="width: 100% !important;" />
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
