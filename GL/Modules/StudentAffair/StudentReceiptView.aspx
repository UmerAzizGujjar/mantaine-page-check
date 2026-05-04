<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="StudentReceiptView.aspx.cs" Inherits="PMS.Modules.StudentAffair.StudentReceiptView" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
     <link href="../../wwwroot/Tibbit_theme/css/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">

        $(document).ready(function () {
            $('#ctl00_lblMessage').hide();
            //LoadPage();

            loadClassOptions();

        });

        function loadClassOptions() {
            $.ajax({
                type: "POST",
                url: "StudentReceiptView.aspx/GetClassOptions",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var options = response.d || response;
                    populateDropdown('#ddlFilterClass', options.Classes);
                    initSelect2();
                    LoadPage(); 
                },
                error: function (xhr, status, error) {
                    console.log("Error loading class options:", error);
                    initSelect2();
                    LoadPage();
                }
            });
        }

        function populateDropdown(selector, data) {
            var $select = $(selector);
            $select.empty();
            $select.append('<option value="">All Classes</option>');
            if (data && data.length > 0) {
                $.each(data, function (index, item) {
                    if (item) $select.append('<option value="' + item + '">' + item + '</option>');
                });
            }
        }

        function initSelect2() {
            $('#ddlFilterClass').select2({
                placeholder: "Select Class...",
                allowClear: true,
                width: 'resolve'
            });

            $('#ddlFilterClass').on('select2:select select2:unselect', function () {
                if (dataTable) dataTable.ajax.reload();
            });
        }

        function PrintTest(id) {
            window.open('ReportViewer.aspx?ReportName=TestDefination&ReportTitle= Test Defination&Test_IDs=' + id);
        }

        function Edit(ID, StuID) {
            debugger;
            window.location.href = "StudentReceipt.aspx?Stu_RecptID=" + ID + "&Stu_ID=" + StuID;

        }

        function PrintVoucher(Student_Receipt_ID) {
            debugger
            var locationInfo = window.location;
            var url = '/ReportViewer.aspx?ReportName=Voucher&ReportTitle=SRV Voucher&TransID=' + Student_Receipt_ID + '&TransType=SRV';
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + '/ReportViewer.aspx?ReportName=Voucher&ReportTitle=SRV Voucher&TransID=' + Student_Receipt_ID + '&TransType=SRV';
            }
            //  window.location.href = url;
            window.open(url, '_blank');

        }
               
        function LoadPage() {
            if ($.fn.DataTable.isDataTable('#tbl')) return;

            dataTable = $("#tbl").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": [{ text: 'Add', className: 'dt-button buttons-copy buttons-html5', action: function () { window.location = 'StudentReceipt.aspx'; } }, 'copy', 'excel', 'pdf'],
                "filter": true,
                "ajax": function (data, callback, settings) {
                    var filterClass = $('#ddlFilterClass').val() || "";

                    $.ajax({
                        type: "POST",
                        url: "StudentReceiptView.aspx/ViewList",
                        data: JSON.stringify({
                            draw: data.draw,
                            start: data.start,
                            length: data.length,
                            sortColumn: data.columns[data.order[0].column].name,
                            sortColumnDirection: data.order[0].dir,
                            searchValue: data.search.value,
                            filterClass: filterClass
                        }),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (response) {
                            callback({
                                draw: response.d.draw,
                                recordsTotal: response.d.recordsTotal,
                                recordsFiltered: response.d.recordsFiltered,
                                data: response.d.data
                            });
                        },
                        error: function (xhr, status, error) {
                            console.log(xhr.responseText);
                            callback({ data: [] });
                        }
                    });
                },
                "columns": [
                    { "data": "Student_Receipt_ID", "visible": false, "width": "0%" },
                    { "data": "Student_Receipt_No", "name": "Student_Receipt_No", "width": "8%", "orderable": true },
                    {
                        "data": "Student_Receipt_Date", "name": "Student_Receipt_Date",
                        "render": function (data, type, full) {
                            if (!full.Student_Receipt_Date) return '';
                            return moment(full.Student_Receipt_Date).format('DD-MMM-YYYY');
                        }, "width": "10%", "orderable": true
                    },
                    { "data": "Full_Name", "name": "Full_Name", "width": "8%", "orderable": true },
                    { "data": "Class", "name": "Class", "width": "8%", "orderable": true },
                    { "data": "Status", "width": "8%", "orderable": false },
                    { "data": "RollNo", "width": "8%", "orderable": false },
                    { "data": "Net_Payable", "width": "8%", "orderable": false },
                    { "data": "Amount_Received", "width": "8%", "orderable": false },
                    { "data": "Balance", "width": "8%", "orderable": false },
                    { "data": "Remarks", "width": "8%", "orderable": false },
                    {
                        render: function (data, type, full) {
                            var res = '<a class="editListBtn" href="#" onclick="Edit(' + full.Student_Receipt_ID + ', ' + full.Student_ID + ')" style="border-radius: 4px; color: white; padding: 5px 8px; text-decoration: none; display: inline-block;"><i class="fa fa-pencil" style="color:white !important;"></i></a>';
                            var Del = '<a href="#" style="border-radius: 4px; background-color: #ad170c;margin-left: 4px; color: white; padding: 5px 8px;" onclick="cancelReceipt(' + full.Student_Receipt_ID + ')"><i class="fa fa-trash"></i></a>';
                            var print = '<a style="border-radius: 4px;background-color:#387024;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="PrintVoucher(' + full.Student_Receipt_ID + ')" id="btnprint"><i class="fa fa-print" style="color:white !important;"></i></a>';
                            return res + Del + print;
                        }, "width": "10%", "orderable": false
                    }
                ],
                "initComplete": function (settings, json) {
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
                }
            });
        }


        function cancelReceipt(ReceiptId) {
            debugger;
            if (confirm("Are you sure you want to cancel this Receipt?")) {
                $.ajax({
                    type: "POST",
                    url: "StudentReceiptView.aspx/CancelReceipt",
                    data: JSON.stringify({ ReceiptId: ReceiptId }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        if (response.d) {
                            alert("Receipt cancelled successfully!");
                            $('#tbl').DataTable().ajax.reload();
                        } else {
                            alert("Failed to cancel the Receipt.");
                        }
                    },
                    error: function (xhr, status, error) {
                        console.log(xhr.responseText);
                    }
                });
            }
        }


    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
     <div class="filter-container">
        <div class="row">
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label class="filter-label" for="ddlFilterClass">Filter by Class:</label>
                <select id="ddlFilterClass" class="form-control">
                    <option value="">All Classes</option>
                </select>
            </div>
        </div>
    </div>
    <div class="row">
        <div class="table-container">
            <table id="tbl" class="table table-bordered table-hover table-striped">
                <thead id="ihead">
                    <tr>
                        <th style="display: none;">Student_Receipt_ID</th>
                        <th>Receipt No</th>
                        <th>Receipt Date</th>
                        <th>Student Name</th>
                        <th>Class</th>
                        <th>Status</th>
                        <th>Roll No</th>
                        <th>Net Payable</th>
                        <th>Received Amount</th>
                        <th>Balance</th>
                        <th>Remarks</th>
                        <th>View</th>
                    </tr>
                </thead>
                <tbody id="tbody">
                </tbody>
            </table>
        </div>
    </div>


</asp:Content>
