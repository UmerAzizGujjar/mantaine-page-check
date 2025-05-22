<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AppointmentView.aspx.cs" Inherits="PMS.AppointmentView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/Pakred/css/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">
        $(document).ready(function () {
            LoadPage();
        });

        function LoadPage() {
            $("#example").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": ['copy', 'excel', 'pdf'],
                "filter": true,
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "AppointmentView.aspx/ViewList",
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
                    { "data": "Appointment_ID", "visible": false, "width": "0%" },
                    { "data": "Appointment_No", "name": "Appointment_No" },
                    { "data": "Patient_Name", "name": "Patient_Name" },
                    { "data": "Age", "name": "Age" },
                    { "data": "Phone", "name": "Phone" },
                    { "data": "Appointed_Doctor", "name": "Appointed_Doctor" },
                    { "data": "Department", "name": "Department" },
                    {
                        "data": "App_Date",
                        "render": function (data, type, full) {
                            return moment(full.App_Date).format('D-MMM-YYYY');
                        }
                    },
                    {
                        "data": "Start_Time",
                        "render": function (data, type, full) {
                            return moment(full.Start_Time).format('h:mm a');
                        }
                    },
                    {
                        "data": "Created_Time",
                        "render": function (data, type, full) {
                            return moment(full.Created_Time).format('D-MMM-YYYY');
                        }
                    },
                    { "data": "Username", "name": "Username" },
                    { "data": "Status", "name": "Status" },
                    //{ "data": "Referred", "name": "Referred" },
                    {
                        "render": function (data, type, full) {
                            return '<a href="#" class="editListBtn" onclick="editOpen(' + full.Appointment_ID + ')" style="border-radius: 4px;margin-right: 4px; color: white; padding: 5px 8px 5px 8px;"><i style="color:white !important;" class="fa fa-pencil"></i></a>';
                        }
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
                    } else {
                        console.log("Length dropdown, label, or container not found");
                    }
                }
            }); 
        }
            
       



        function editOpen(id) {

            window.open("Appointment.aspx?APPID=" + id + "");

        }
        debugger;
        function deleteConfirm(anchorTag) {
            debugger;


            var row = $(anchorTag).parents('tr')[0];

            var AppID = $($(row).find('td')[0]).text();


            if (confirm('Are you sure want to delete this record')) {
                PageMethods.DeleteRecord(AppID, function (msg) {
                    row.remove();
                }, OnFail);
            }
        }

    </script>


</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
     <div class="row">
        <div class="col-lg-2 col-md-4 col-sm-6">
            <input type="button" class="btn-primry mrg" value="Add New" onclick="window.location = 'Appointment.aspx'"  />
        </div>
    </div>
    <div class="table-container" style="margin-top: 15px;">
  
            <table id="example" class="table-responsive table table-striped table-bordered display">
                <thead>
                    <tr>
                        <th>App No</th>
                        <th>App No.</th>
                        <th>Name</th>
                        <th>Age</th>
                        <th>Phone</th>
                        <th>Doctor</th>
                        <th>Department</th>
                        <th>App Date</th>
                        <th>App Time</th>
                        <th>Created Date</th>
                        <th>User Name</th>
                        <th>Status</th>
                        <%--<th>Reffered</th>--%>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody id="tblbody">
                </tbody>
            </table>
     
    </div>



</asp:Content>
