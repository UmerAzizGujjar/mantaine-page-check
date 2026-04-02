<%@ Page Title="Approved Tests" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ApproveTest.aspx.cs" Inherits="PMS.Modules.Lab.ApproveTest" ValidateRequest="false" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/Tibbit_theme/css/tablestyle.css" rel="stylesheet" />
    <style>
        .approved-table-container {
            margin-top: 20px;
            padding: 15px;
            background: #fff;
            border-radius: 5px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        h2 {
            color: #333;
            border-left: 4px solid #5bc0de;
            padding-left: 15px;
            margin-bottom: 20px;
        }
        .btn-preview {
            background-color: #5bc0de;
            color: white;
            border: none;
            padding: 5px 12px;
            border-radius: 3px;
            cursor: pointer;
        }
        .btn-preview:hover {
            background-color: #31b0d5;
        }
        .dataTables_wrapper .dt-buttons {
            margin-bottom: 10px;
        }
    </style>
    <script type="text/javascript">
        $(document).ready(function () {
            LoadPage();
        });

        function LoadPage() {
            $("#tblApprovedTests").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": [
                    {
                        text: 'Refresh',
                        className: 'dt-button buttons-copy buttons-html5',
                        action: function () {
                            $('#tblApprovedTests').DataTable().ajax.reload();
                        }
                    },
                    'copy',
                    'excel',
                    'pdf'
                ],
                "filter": true,
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "ApproveTest.aspx/ViewList",
                        data: JSON.stringify({
                            draw: data.draw,
                            start: data.start,
                            length: data.length,
                            sortColumn: data.columns[data.order[0].column].name,
                            sortColumnDirection: data.order[0].dir,
                            searchValue: data.search.value
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
                        }
                    });
                },
                "columns": [
                    { "data": null, "width": "4%", "orderable": false, "render": (data, type, full, meta) => meta.settings._iDisplayStart + meta.row + 1 },
                    { "data": "Bill_No", "name": "Bill_No", "width": "10%", "orderable": true },
                    { "data": "mr_no_sequence", "name": "mr_no_sequence", "width": "10%", "orderable": true },
                    { "data": "Full_Name", "name": "Full_Name", "width": "15%", "orderable": true },
                    { "data": "Test_Name", "name": "Test_Name", "width": "20%", "orderable": true },
                    { "data": "Test_Main_Department", "name": "Test_Main_Department", "width": "12%", "orderable": true },
                    { "data": "Approved_By", "name": "Approved_By", "width": "10%", "orderable": true },
                    {
                        "data": "Approved_Time", "name": "Approved_Time",
                        "render": (data, type, full) => moment(full.Approved_Time).format('DD-MMM-YYYY HH:mm'),
                        "width": "15%"
                    },
                    {
                        "render": (data, type, full) => {
                            return `<button type="button" class="btn-preview" onclick="PreviewReport(${full.Lab_Test_Detail_ID}, ${full.Lab_Test_ID}, '${full.Report_Colum}', ${full.Bill_Details_ID}, ${full.Test_ID})">Preview Report</button>`;
                        },
                        "width": "12%",
                        "orderable": false
                    }
                ],
                "initComplete": function (settings, json) {
                    var lengthContainer = document.querySelector('#tblApprovedTests_length');
                    var lengthDropdown = document.querySelector('#tblApprovedTests_length select');
                    var label = document.querySelector('#tblApprovedTests_length label');

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

        function PreviewReport(Lab_Test_Detail_ID, Lab_Test_ID, Report_Colum, Bill_Details_ID, Test_ID) {
            window.open('../../ReportViewer.aspx?ReportName=TestResultQ' +
                '&ReportTitle=Department Of Pathology' +
                '&Test_IDs=' + Test_ID +
                '&test_wise_ids=' + Lab_Test_ID +
                '&TransID=' + Lab_Test_ID +
                '&labTDetailsID=' + Lab_Test_Detail_ID +
                '&BillDetailID=' + Bill_Details_ID +
                '&ReportColumn=' + Report_Colum);
        }
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container-fluid">
        <h2>Approved Test Results</h2>
        
        <div class="approved-table-container">
            <div style="overflow-x: auto;">
                <table class="table table-hover table-striped table-bordered" id="tblApprovedTests" style="width: 100%;">
                    <thead>
                        <tr>
                            <th>Sr#</th>
                            <th>Bill No</th>
                            <th>MR No</th>
                            <th>Patient Name</th>
                            <th>Test Name</th>
                            <th>Department</th>
                            <th>Approved By</th>
                            <th>Approved Date/Time</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</asp:Content>