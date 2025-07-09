<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="OperationTheaterList.aspx.cs" Inherits="PMS.OperationTheaterList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/Tibbit_theme/css/tablestyle.css" rel="stylesheet" />

    <script type="text/javascript">
        $(document).ready(function () {
            debugger;
            $('#ctl00_lblMessage').hide();
            LoadPage();


        });

        function editOpen(id) {
            debugger;
            window.open("OperationBooking.aspx?ID=" + id + "");
        }

        function PrintTest(id) {
            window.open('ReportViewer.aspx?ReportName=TestDefination&ReportTitle= Test Defination&Test_IDs=' + id);
        }
        function LoadPage() {
            $("#patientOT").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": [{ text: 'Add', className: 'dt-button buttons-copy buttons-html5', action: function () { window.location = 'OperationBooking.aspx'; } }, 'copy', 'excel', 'pdf'],
                "filter": true,
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "OperationTheaterList.aspx/ViewList",
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
                    { "data": "Operation_Booking_ID", "visible": false, "width": "0%" },
                    { "data": "mr_no_sequence", "name": "mr_no_sequence", "width": "5%", "orderable": true },
                    { "data": "Full_Name", "width": "10%", "orderable": false },
                    { "data": "DoctorName", "width": "10%", "orderable": false },
                    { "data": "ProcedureName", "width": "15%", "orderable": false },
                    { "data": "Mobile", "width": "10%", "orderable": false },
                    { "data": "Department", "width": "10%", "orderable": false },
                    {
                        "data": "Created_Time", "name": "Created_Time",
                        "render": function (data, type, full) {
                            debugger;
                            var date = full.Created_Time;
                            date = moment(date).format('DD-MMM-YYYY');
                            return date;
                        }, "width": "10%", "orderable": true
                    },
                    {
                        render: function (data, type, full) {
                            debugger;
                            var res = '<a href="#" class="editListBtn" onclick="editOpen(' + full.Operation_Booking_ID + ')" style="border-radius: 4px;padding: 5px 8px 5px 8px;"><i class="fa fa-pencil"></i></a>'

                            var print = '<a class="printListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="PrintTest(' + full.Operation_Booking_ID + ')" id="btnprint"><i class="fa fa-print" ></i></a>';
                            var result;
                            result = res + print;
                            return result;

                        }, "width": "5%"
                    }
                ],
                "initComplete": function (settings, json) {
                    var lengthContainer = document.querySelector('#patientOT_length');
                    var lengthDropdown = document.querySelector('#patientOT_length select');
                    var label = document.querySelector('#patientOT_length label');

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
                    } else {
                        console.log("Length dropdown, label, or container not found");
                    }
                }
            });
        }



    </script>

</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
   

    <div id="divOT" class="table-container">
        <table class="table table-hover table-striped table-bordered" id="patientOT">
            <thead>
                <tr>
                    <th style="display: none;">Mr ID</th>
                    <th>Mr No</th>
                    <th>Patient Name</th>
                    <th>Doctor</th>
                    <th>Procedure Name</th>
                    <th>Mobile</th>
                   <th>Patient Type</th>
                    <th>Operation Date</th>
                    <th>Action</th>
                </tr>
            </thead>
        </table>
    </div>


</asp:Content>
