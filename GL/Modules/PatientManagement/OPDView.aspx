 <%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="OPDView.aspx.cs" Inherits="PMS.Modules.PatientManagement.OPDView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script src="../../wwwroot/Tibbit_theme/CustomJs/OPDView.js" type="text/javascript"></script>
    <link href="../../wwwroot/Tibbit_theme/css/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">
        $(document).ready(function () {
            debugger;
            $('#ctl00_lblMessage').hide();
            LoadPage();


        });
      

       
        function editOpen(id) {
            Swal.fire({
                title: 'Are you sure?',
                text: `You are about to edit patient`,
                icon: 'warning',
                showCancelButton: true,
                confirmButtonText: 'Yes, edit it!',
                cancelButtonText: 'Cancel',
                reverseButtons: true
            }).then((result) => {
                if (result.isConfirmed) {
                    PageMethods.EditPatient(id, function (msg) {
                        if (msg === "NotAllowed") {
                            Swal.fire({
                                icon: 'error',
                                title: 'Access Denied',
                                text: 'You do not have permission to edit this patient.'
                            });
                        } else if (msg === "Allowed") {
                            window.open("OPD.aspx?OPDID=" + id, "_blank");
                        }
                        // No third condition — so no else needed
                    });
                }
            });
        }
        function cancelPatient(patid, patname) {
            debugger;
            var PatID = patid;
            var PatNo = patname;

            Swal.fire({
                title: 'Are you sure?',
                text: 'Are you sure want to Cancel:- ' + PatNo,
                icon: 'warning',
                showCancelButton: true,
                confirmButtonText: 'Yes, cancel it!',
                cancelButtonText: 'No, keep it',
                reverseButtons: true
            }).then((result) => {
                if (result.isConfirmed) {
                    PageMethods.CancelPatient(PatID, function (msg) {
                        if (msg == "Allowdlt") {
                            Swal.fire({
                                icon: 'error',
                                title: 'Permission Denied',
                                text: 'You have no right to Cancel.'
                            });
                        }
                        else if (msg == "success") {
                            // Assuming 'row' is defined in outer scope (e.g., via closure or global)
                            if (typeof row !== 'undefined' && row && typeof row.remove === 'function') {
                                row.remove();
                            }
                            // Note: You may want to reload or redirect AFTER success
                            window.location.href = "OPDView.aspx";
                        }
                        else {
                            Swal.fire({
                                icon: 'warning',
                                title: 'Cancel Failed',
                                text: 'Unable to Cancel this patient, because this patient has uncanceled Reciept and Bills'
                            });
                        }
                    });
                }
            });

            // ⚠️ This line runs IMMEDIATELY after showing the alert — likely NOT what you want!
           
        }
        function LoadPage() {
            $("#tblResult").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": [
                    {
                    text: 'Add',
                    className: 'dt-button buttons-copy buttons-html5',
                    action: function () {
                        window.location = 'OPD.aspx';
                    }
                },
                    'copy', 'excel', 'pdf',
                ],
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
                    {
                        "data": null,
                        "width": "5%",
                        "orderable": false,
                        "render": function (data, type, full, meta) {
                            // Calculate serial number based on current page
                            return meta.settings._iDisplayStart + meta.row + 1;
                        }
                    },
                    { "data": "Patient_ID", "visible": false, "width": "0%", "orderable": false },
                    { "data": "mr_no_sequence", "name": "mr_no_sequence", "width": "8%", "orderable": true },
                    { "data": "Opd_No", "name": "Opd_No", "width": "5%", "orderable": false },
                    { "data": "Full_Name", "width": "13%", "orderable": false },
                    { "data": "Patient_Type", "width": "10%", "orderable": false },
                    { "data": "Department", "width": "10%", "orderable": false },
                    { "data": "NIC", "width": "10%", "orderable": false },
                    { "data": "Mobile1", "width": "10%", "orderable": false },
                    { "data": "Age", "name": "Age", "width": "5%" },
                    { "data": "Doctor_Id", "width": "10%", "orderable": false },
                    {
                        "data": "Created_Time", "name": "Created_Time",
                        "render": function (data, type, full) {
                            var date = full.Created_Time;
                            return moment(date).format('DD-MMM-YYYY');
                        }, "width": "9%"
                    },
                    {
                        "render": function (data, type, full) {
                            var res = '<a href="#" onclick="editOpen(' + full.Patient_ID + ')" class="editListBtn" style="border-radius: 4px;padding: 5px 8px 5px 8px;"><i class="fa fa-pencil"></i></a>';
                            var Del = '<a class="delListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" data-id="' + full.Patient_ID + '" onclick="cancelPatient(' + full.Patient_ID + ', \'' + full.Full_Name + '\')"><i class="fa fa-trash"></i></a>';
                            var print = '<a class="printListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="Print(' + full.Patient_ID + ')"><i class="fa fa-print"></i></a>';
                            return res + Del + print;
                        },
                        "width": "17%",
                        "orderable": false
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
   
    <div id="POdetails" style="margin-top: 15px;">
            <div class="row">
                <div class="table-container col-lg-12 col-md-12 col-sm-10">
                    <table class="table table-hover table-striped table-bordered" id="tblResult" style="overflow: scroll; height: auto;">
                  <thead id="ihead">
                    <tr>
                        <th style="width:2% !important;">Sr#</th>                 <!-- 1st: Sr# -->
                        <th style="display: none;">Patient ID</th>      <!-- 2nd: Hidden -->
                        <th style="width: 8%;">MR No.</th>
                        <th style="width: 5%;">OPD</th>
                        <th style="width: 13%;">Name</th>
                        <th style="width: 10%;">Category</th>
                        <th style="width: 10%;">Department</th>
                        <th style="width: 10%;">CNIC</th>
                        <th style="width: 10%;">Mobile</th>
                        <th style="width: 5%;">Age</th>
                        <th style="width: 10%;">Doctor</th>
                        <th style="width: 9%;">Date</th>
                        <th style="width: 20% !important;">Actions</th>
                    </tr>
                </thead>
                        <tbody id="ibody">
                        </tbody>
                    </table>
                </div>
            </div>
    </div>
</asp:Content>
