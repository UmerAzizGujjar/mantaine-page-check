<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="OPDView.aspx.cs" Inherits="PMS.Modules.PatientManagement.OPDView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

    <link href="../../wwwroot/StandardTheme/css/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">
        $(document).ready(function () {
            debugger;
            $('#ctl00_lblMessage').hide();
            LoadPage();


        });

        function editOpen(id) {

            window.open("OPD.aspx?OPDID=" + id + "");
        }

        function cancelPatient(patid, patname) {
            debugger;
            var PatID = patid;
            var PatNo = patname;

            if (confirm('Are you sure want to Cancel Mr No:- ' + PatNo)) {
                PageMethods.CancelPatient(PatID, function (msg) {
                    if (msg == "Allowdlt") {
                        alert('You have no right to Cancel. ')

                    }
                    else if (msg == "success") {

                        row.remove();
                    }
                    else {
                        alert('Unable to Cancel this patient, because this patient has uncanceled Reciept and Bills ')
                    }
                },


                );
            }

            window.location.href = "OPDView.aspx";
        }
        function LoadPage() {
            $("#tblResult").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": ['copy', 'excel', 'pdf'],
                "filter": true,
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "OPDView.aspx/ViewList",
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
                    { "data": "Patient_ID", "visible": false, "width": "0%", "orderable": false },
                    { "data": "mr_no_sequence", "name": "mr_no_sequence", "width": "8%", "orderable": true },
                    { "data": "Opd_No", "name": "Opd_No", "width": "5%", "orderable": false },
                    { "data": "Full_Name", "width": "15%", "orderable": false },
                    { "data": "Patient_Type", "width": "10%", "orderable": false },
                    { "data": "Department", "width": "10%", "orderable": false },
                    { "data": "NIC", "width": "10%", "orderable": false },
                    { "data": "Mobile1", "width": "10%", "orderable": false },
                    { "data": "Age", "name": "Age", "width": "5%" },
                    { "data": "Doctor_Id", "width": "10%", "orderable": false },
                    {
                        "data": "Created_Time", "name": "Created_Time",
                        "render": function (data, type, full) {
                            debugger;
                            var date = full.Created_Time;
                            date = moment(date).format('DD-MMM-YYYY');
                            return date;
                        }, "width": "10%"
                    },
                    {
                        render: function (data, type, full) {
                            debugger;
                            var res = '<a href="#" onclick="editOpen(' + full.Patient_ID + ')" class="editListBtn" style="border-radius: 4px;color: white; padding: 5px 8px 5px 8px;"><i style="color:white !important;" class="fa fa-pencil"></i></a>'
                            var Del = '<a style="border-radius: 4px;background-color:#ad170c;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" data-id="' + full.Patient_ID + '" onclick="cancelPatient( ' + full.Patient_ID + ', \'' + full.Full_Name + '\')"><i class="fa fa-trash" style="color:white !important;"></i></a>';

                            var result;
                            result = res + Del;
                            return result;
                        }, "width": "100%", "orderable": false
                    }
                ],
                "initComplete": function (settings, json) {
                    var lengthContainer = document.querySelector('#tblResult_length');
                    var lengthDropdown = document.querySelector('#tblResult_length select');
                    var label = document.querySelector('#tblResult_length label');

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
    <div class="row">
        <div class="col-lg-2 col-md-4 col-sm-6">
            <input type="button" class="btn-primry mrg" value="Add New" onclick="window.location = 'OPD.aspx'" />
        </div>
    </div>
    <div id="POdetails" style="margin-top: 15px;">

            <div class="row">
                <div class="table-container col-lg-12 col-md-12 col-sm-10">
                    <table class="table table-hover table-striped table-bordered" id="tblResult" style="overflow: scroll; height: auto;">
                        <thead id="ihead">
                            <tr>
                                <th style="display: none;">Patient ID</th>
                                <th>MR No.</th>
                                <th>OPD</th>
                                <th>Name</th>
                                <th>Category</th>
                                <th>Department</th>
                                <th>CNIC</th>
                                <th>Mobile</th>
                                <th>Age</th>
                                <th>Doctor</th>
                                <th>Date</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody id="ibody">
                        </tbody>
                    </table>
                </div>
            </div>
    </div>
</asp:Content>
