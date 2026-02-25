<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="TimeTableList.aspx.cs" Inherits="PMS.TimeTableList" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">   
    <link href="../../wwwroot/Tibbit_theme/css/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">
        $(document).ready(function () {
            $('#ctl00_lblMessage').hide();
            LoadPage();
        });

        function PrintTest(id) {
            window.open('/ReportViewer.aspx?ReportName=TestDefination&ReportTitle=Test Defination&Test_IDs=' + id);
        }

        function LoadPage() {
            $("#example").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": [
                    {
                        text: 'Add',
                        className: 'dt-button buttons-copy buttons-html5',
                        action: function () {
                            window.location = 'StudentTimeTable.aspx';
                        }
                    },
                    'copy', 'excel', 'pdf'
                ],
                "filter": true,
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "TimeTableList.aspx/ViewList",
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
                    { "data": "St_id", "visible": false, "width": "0%" },
                    { "data": null, "orderable": false, "width": "08%" },
                    { "data": "Classname", "name": "Classname", "width": "12%", "orderable": true },
                    { "data": "ProgramName", "name": "ProgramName", "width": "10%", "orderable": true },
                    { "data": "WeekName", "name": "WeekName", "width": "10%", "orderable": true },
                    {
                        "data": "",
                        "name": "DateRange",  
                        "render": function (data, type, full) {
                            if (!full.FirstDate || !full.LastDate) return "";

                            var firstDate = moment(full.FirstDate).format('DD-MMM-YYYY');
                            var lastDate = moment(full.LastDate).format('DD-MMM-YYYY');
                            return firstDate + ' - ' + lastDate;
                        },
                        "width": "20%",
                        "orderable": true
                    },
                    { "data": "Block", "name": "Block", "width": "10%", "orderable": false },
                    { "data": "Module", "name": "Module", "width": "10%", "orderable": false }, 
                    {
                        "render": function (data, type, full) {
                            var res = '<a class="editListBtn" href="#" onclick="editOpen(' + full.St_id + ')" style="border-radius: 4px; color: white; padding: 5px 8px 5px 8px;"><i style="color:white !important;" class="fa fa-pencil"></i></a>';
                            var Del = '<a style="border-radius: 4px;background-color:#ad170c;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" data-id="' + full.St_id + '" onclick="DeleteData(' + full.St_id + ', \'' + full.St_id + '\')"><i class="fa fa-trash" style="color:white !important;"></i></a>';
                            //var print = '<a style="border-radius: 4px;background-color:#387024;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="PrintTest(' + full.Test_ID + ')" id="btnprint"><i class="fa fa-print" style="color:white !important;"></i></a>';
                            return res + Del;
                        },
                        "width": "10%",
                        "orderable": false
                    }
                ],
                "initComplete": function (settings, json) {
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
                },
                "createdRow": function (row, data, dataIndex) {
                    $(row).find('td:eq(0)').html(dataIndex + 1);
                }
            });
        }

        function editOpen(id) {
            window.location.href = "StudentTimeTable.aspx?ID=" + id;
        }

        function DeleteData(id) {
            if (!confirm("Are you sure you want to delete this timetable?")) return;
            $.ajax({
                url: 'TimeTableList.aspx/DeleteRecord',
                type: 'post',
                contentType: 'application/json;charset=utf-8',
                data: JSON.stringify({ "Id": id }),
                success: function (res) {
                    alert("Deleted successfully!");
                    $('#example').DataTable().ajax.reload();
                },
                error: function () {
                    alert('Delete failed!');
                }
            });
        }

        function FormOpen() {
            window.location.href = "StudentTimeTable.aspx";
        }
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
    <div class="table-container col-lg-12 col-md-12 col-sm-10">
    <table id="example" class="table table-hover table-striped table-bordered">
        <thead>
            <tr>
                <th>St_id</th>
                <th>Sr#</th>
                <th>Class</th>
                <th>Program</th>
                <th>Week</th>
                <th>Date </th>
                <th>Block </th>
                <th>Module </th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody></tbody>
    </table> 
        </div>
        </div>
</asp:Content>