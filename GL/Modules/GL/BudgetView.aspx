<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="BudgetView.aspx.cs" Inherits="PMS.BudgetView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
     <link href="../../wwwroot/css/tablestyle.css" rel="stylesheet" />
    

    <script type="text/javascript">
        var year = false;
        debugger;

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

                    // Get date input and extract month/year
                    var getdate = $('#txt_date').val(); // e.g., "May 2025"
                    var array = getdate.split(" ");
                    var getmonthText = array[0];
                    var getyear = array[1];

                    var monthsMap = {
                        "January": "01", "February": "02", "March": "03", "April": "04",
                        "May": "05", "June": "06", "July": "07", "August": "08",
                        "September": "09", "October": "10", "November": "11", "December": "12"
                    };
                    var getmonth = monthsMap[getmonthText] || "01";

                    var checkyear = $("#chkyear").is(":checked"); // checkbox for year-only filter

                    $.ajax({
                        type: "POST",
                        url: "BudgetView.aspx/VoucherViewList",
                        data: JSON.stringify({
                            draw: data.draw,
                            start: data.start,
                            length: data.length,
                            sortColumn: data.columns[data.order[0].column].name,
                            sortColumnDirection: data.order[0].dir,
                            searchValue: data.search.value,
                            month: getmonth,
                            year: getyear,
                            checkyear: checkyear
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
                    { "data": "Budget_ID", visible: false },
                    { "data": "Budget_No", "name": "Voucher_No", width: "12%" },
                    {
                        "data": "Budget_Date",
                        "render": function (data, type, full) {
                            return moment(full.Budget_Date).format('D-MMM-YYYY');
                        }, width: "17%"
                    },
                    {
                        "data": "Creation_Time",
                        "render": function (data, type, full) {
                            return moment(full.Creation_Time).format('D-MMM-YYYY');
                        }, width: "17%"
                    },
                    { "data": "Remarks", width: "13%" },
                    { "data": "Budget_Status", width: "25%" },
                    { "data": "TotalDebtAmt", width: "13%" },
                    {
                        "render": function (data, type, full) {
                            var actionButtons = `
                        <a href="#" class="editListBtn" onclick="Edit(${full.Budget_ID})" style="border-radius: 4px; color: white; padding: 5px 8px 5px 8px;"><i class="fa fa-pencil" style="color:white !important;"></i></a>
                        <a style="border-radius: 4px; background-color:#387024; color: white; padding: 5px 8px 5px 8px;" href="#" onclick="PrintReport(${full.Budget_ID})"><i class="fa fa-print" style="color:white !important;"></i></a>`;
                            if (full.Voucher_Status === 'CREATED') {
                                actionButtons += `
                            <a href="#" onclick="deleteConfirm(${full.Budget_ID})" style="border-radius: 4px; background-color: red; color: white; padding: 5px 8px;"><i class="fa fa-trash-o" style="color:white !important;"></i></a>`;
                            }
                            return actionButtons;
                        }, width: "15%"
                    }
                ],
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

        //function LoadPage() {
        //    var tablesss;
        //    tablesss = $('#example').DataTable();
        //    tablesss.clear();
        //    var getdate = $('#txt_date').val();
        //    var str = getdate;
        //    var array = str.split(" ");
        //    var getmonth = array[0];
        //    var getyear = array[1];
        //    if (getmonth == "January" || getmonth == "") {
        //        getmonth = "01"
        //    }
        //    if (getmonth == "February") {
        //        getmonth = "02"
        //    }
        //    if (getmonth == "March") {
        //        getmonth = "03"
        //    }
        //    if (getmonth == "April") {
        //        getmonth = "04"
        //    }
        //    if (getmonth == "May") {
        //        getmonth = "05"
        //    }
        //    if (getmonth == "June") {
        //        getmonth = "06"
        //    }
        //    if (getmonth == "July") {
        //        getmonth = "07"
        //    }
        //    if (getmonth == "August") {
        //        getmonth = "08"
        //    }
        //    if (getmonth == "September") {
        //        getmonth = "09"
        //    }
        //    if (getmonth == "October") {
        //        getmonth = "10"
        //    }
        //    if (getmonth == "November") {
        //        getmonth = "11"
        //    }
        //    if (getmonth == "December") {
        //        getmonth = "12"
        //    }
        //    debugger;
        //    $.ajax({
        //        type: "POST",
        //        url: "BudgetView.aspx/VoucherViewList",
        //        data: JSON.stringify({
        //            "month": getmonth,
        //            "year": getyear,
        //            "checkyear": year

        //        }),
        //        contentType: "application/json; charset=utf-8",
        //        dataType: "json",
        //        success: function (data) {
        //            var table;
        //            table = $('#example').DataTable();
        //            var length = $("#example tr:gt(0)").length;
        //            if (data != '') {
        //                var data = JSON.parse(data.d);
        //                var abc = '<td><i class="ace-icon fa fa-pencil bigger-130"></i><i class="ace-icon fa fa-trash bigger-130" onclick="deleteConfirm(this)" id="btnDel"></i><i class="ace-icon fa fa-print bigger-130" id="btnprint"></i></td>'
        //                $.each(data, function (i, item) {
        //                    debugger;
        //                    var vdate = new Date(parseInt(data[i].Budget_Date.substr(6)));
        //                    vdate = moment(vdate).format('L');
        //                    var cDate = new Date(parseInt(data[i].Creation_Time.substr(6)));
        //                    var months = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"];
        //                    var monthName = months[cDate.getMonth()];
        //                    var yearName = cDate.getFullYear();
        //                    var c_year = yearName;
        //                    cDate = moment(cDate).format('L');
        //                    var c_month = monthName;
        //                    var voucherStatus = data[i].Budget_Status;
        //                    var rowColor = '';
        //                    if (voucherStatus === "Cancelled") {
        //                        rowColor = '#ffcccc';
        //                    }
        //                    var row = table.row.add([
        //                        length, data[i].Budget_No + "-" + monthName + "-" + yearName, vdate, cDate, data[i].Remarks, data[i].Total_Debit, data[i].Budget_Status,
        //                        '<td><a href="#" onclick="Edit(' + data[i].Budget_ID + ')" style="border-radius: 4px; background-color: #d4b7e7; color: black; padding: 4px 11px;">View</a><a style="border-radius: 4px;background-color: #e98383;color: white;padding: 4px 11px;" href="#" onclick="PrintReport(' + data[i].Budget_ID + ')" id="btnprint' + (i + 1) + '" name="btnprint">Print</a><a href="#" onclick="deleteConfirm(' + data[i].Budget_ID + ')" id="btnDel' + (i + 1) + '" name="btnDel" style="border-radius: 4px;background-color: #e98383;color: white;padding: 4px 11px;">Delete</a><a href="#" onclick="ApproveBudget(' + data[i].Budget_ID + ')" id="btnApprove' + (i + 1) + '" name="btnApprove" style="border-radius: 4px;background-color: #519e7e;color: white;padding: 4px 11px;">Approve</a></td>'
        //                    ]).node();
        //                    $(row).css('background-color', rowColor);
        //                    length++;
        //                });
        //                table.draw();
        //            }
        //            else {
        //                $('#example').html('<h3>No users are available</h3>');
        //            }
        //            year = false;
        //            debugger;
        //            $.each(data, function (key, value) {
        //                debugger;
        //                if (data[key].Budget_Status != "Created") {
        //                    debugger;
        //                    $('#btnDel' + (key + 1) + '').hide();
        //                    $('#btnApprove' + (key + 1) + '').hide();
        //                }
        //                if (data[key].Budget_Status == "Created") {
        //                    $('#btnprint' + (key + 1) + '').hide();
        //                    $('#btnApprove' + (key + 1) + '').show();
        //                }
        //            });
        //        }
        //    });
        //}
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
        <div class="col-lg-8 col-md-8 col-sm-8">
            <div class="row">
                <div class="col-lg-2 col-md-4 col-sm-6">
                    <input type="text" style="width: 100% !important" id="txt_date" />
                </div>
                <div class="col-lg-8 col-md-4 col-sm-6" style="margin-left: -16px">
                    <div class="col-lg-2 col-md-4 col-sm-6">
                        <input type="button" class="btn btn-primry" style="width: 100% !important" onclick="LoadPage()" value="Month" />
                    </div>
                    <div class="col-lg-2 col-md-4 col-sm-6">
                        <input type="button" class="btn btn-primry" style="width: 100% !important" onclick="LoadPageByYear()" value="Year" />
                    </div>
                    <div class="col-lg-2 col-md-4 col-sm-6">
                        <input type="button" class="btn btn-primry" style="width: 100% !important" onclick="redirecttonew()" value="Add New" />
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
