 <%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="OPDView.aspx.cs" Inherits="PMS.Modules.PatientManagement.OPDView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script src="../../wwwroot/THEME_TIBBIT/CustomJs/OPDView.js?v=<%= System.IO.File.GetLastWriteTimeUtc(Server.MapPath("~/wwwroot/THEME_TIBBIT/CustomJs/OPDView.js")).Ticks %>" type="text/javascript"></script>
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">
        $(document).ready(function () {
            $('#ctl00_lblMessage').hide();
            LoadPage();
            

        });
      


        function OPD_Form_Print(Patient_ID) {
            var locationInfo = window.location;
            var user_name = '<%= AppConfig.Company_Name %>';
    var reportPath;  // ✅ declared properly

    if (user_name == 'As-Siraat Serving Humanity') {
        reportPath = '../../ReportViewer.aspx';
    } else {
        reportPath = 'ReportViewer.aspx';
    }

    var url;

    if (!locationInfo.origin.includes('localhost')) {
        var urlInfo = window.location.href.split('/');
        var ip = urlInfo[2];
        var foldername = urlInfo[3];
        url = 'http://' + ip + '/' + foldername + '/' + reportPath +
            '?ReportName=OPD_Patient_Print&ReportTitle=OPD Bill Base Print&OPD_ID=' + Patient_ID;
    } else {
        url = '/' + reportPath +
            '?ReportName=OPD_Patient_Print&ReportTitle=OPD Bill Base Print&OPD_ID=' + Patient_ID;
    }

    window.open(url, '_blank');
}
       
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
                    });
                }
            });
        }
        function cancelPatient(patid, patname) {
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
                            if (typeof row !== 'undefined' && row && typeof row.remove === 'function') {
                                row.remove();
                            }
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

           
        }
        function LoadPage() {
            let savedVisibility = null;

            $.ajax({
                type: "POST",
                url: "OPDView.aspx/GetUserColumnPreferences",
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
            const table = $("#tblResult").DataTable({
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
                "columnDefs": savedVisibility ? [] : undefined, 
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
                    { "data": null, "width": "3%", "orderable": false, "render": (data, type, full, meta) => meta.settings._iDisplayStart + meta.row + 1 },
                    { "data": "Patient_ID", "visible": false, "width": "0%", "orderable": false },
                    { "data": "isCancel", "visible": false, "orderable": false, "width": "0%" },
                    { "data": "mr_no_sequence", "name": "mr_no_sequence", "width": "7%", "orderable": true },
                    { "data": "Opd_No", "name": "Opd_No", "width": "5%", "orderable": false },
                    { "data": "Token_No", "name": "Token_No", "width": "5%", "orderable": false },
                    { "data": "Dept_Token", "name": "Dept_Token", "width": "5%", "orderable": false },
                    { "data": "Full_Name", "width": "10%", "orderable": false },
                    { "data": "Patient_Type", "width": "6%", "orderable": false },
                    { "data": "Department", "width": "8%", "orderable": false },
                    { "data": "NIC", "width": "8%", "orderable": false },
                    { "data": "Mobile1", "width": "8%", "orderable": false },
                    { "data": "Age", "name": "Age", "width": "8%" },
                    { "data": "Doctor_Id", "width": "10%", "orderable": false },
                    {
                        "data": "Created_Time", "name": "Created_Time",
                        "render": (data, type, full) => moment(full.Created_Time).format('DD-MMM-YYYY'),
                        "width": "8%"
                    },
                    {
                        "render": (data, type, full) => {
                            if (full.isCancel === true) {
                                return '<span style="color:#721c24; font-weight:bold;">Cancelled</span>';
                            }
                            let res = `<a href="#" onclick="editOpen(${full.Patient_ID})" class="editListBtn" style="border-radius: 4px;padding: 5px 8px;"><i class="fa fa-pencil"></i></a>`;
                            let Del = `<a class="delListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px;" href="#" onclick="cancelPatient(${full.Patient_ID}, '${full.Full_Name.replace(/'/g, "\\'")}')"><i class="fa fa-trash"></i></a>`;
                            let print = `<a class="printListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px;" href="#" onclick="Print(${full.Patient_ID})"><i class="fa fa-print"></i></a>`;
                            let print2 = `<a class="printListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px;" href="#" onclick="OPD_Form_Print(${full.Patient_ID})"><i class="fa fa-print"></i></a>`;
                            return res + Del + print + print2;
                        },
                        "width": "15%",
                        "orderable": false
                    }
                ],
                "createdRow": function (row, data, dataIndex) {
                    $(row).addClass('clickable-row');
                    $(row).attr('data-patient-id', data.Patient_ID);
                    if (data.isCancel === true) {
                        $(row).attr('data-cancelled', '1');
                        $(row).css('background-color', '#f8d7da');
                        $(row).find('td').css('color', '#721c24');
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
                        <th style="width:2% !important;">Sr#</th>                
                        <th style="display: none;">Patient ID</th>    
                        <th style="display: none;">Is Cancel</th>
                        <th style="width: 8%;">MR No.</th>
                        <th style="width: 5%;">OPD</th>
                        <th style="width: 5%;">Token No</th>
                        <th style="width: 5%;">Dept Token</th>
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
