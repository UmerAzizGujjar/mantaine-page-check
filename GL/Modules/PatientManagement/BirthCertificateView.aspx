<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="BirthCertificateView.aspx.cs" Inherits="PMS.Modules.PatientManagement.BirthCertificateView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
        <link href="../../wwwroot/lib/sweetalert/tablestyle.css" rel="stylesheet" />
        <script type="text/javascript">
            $(document).ready(function () {
                $('#ctl00_lblMessage').hide();
                LoadPage();
              
            });

            function PrintBirthCertificate(In_Patient_ID) {
                debugger;
                var url = '../../ReportViewer.aspx?ReportName=Birth_Certificate&ReportTitle=Admission Slip Report&Inpatient_ID=' + In_Patient_ID;
                window.open(url, '_blank');

            }
            function LoadPage() {
                let savedVisibility = null;
                $.ajax({
                    type: "POST",
                    url: "BirthCertificateView.aspx/GetUserColumnPreferences",
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
                $("#tblResult").DataTable({
                    "processing": true,
                    "serverSide": true,
                    "dom": 'lBfrtip',
                    "lengthChange": true,
                    "buttons": [
                        {
                            text: 'Add',
                            className: 'dt-button buttons-copy buttons-html5 btn-primary',
                            action: function () {
                                window.location = 'InPatientsAdmission.aspx';
                            }
                        },
                        {
                            text: 'Discharge',
                            className: 'dt-button buttons-copy buttons-html5 btn-warning',
                            action: function () {
                                dischargeSelected();
                            }
                        },
                        'copy', 'excel', 'pdf',
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
                            url: "BirthCertificateView.aspx/ViewList",
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
                       
                        { "data": "In_Patient_ID", "visible": false, "width": "0%" },
                        {
                            "data": "Admission_Date", "name": "Admission_Date",
                            "render": function (data, type, full) {
                                return moment(full.Admission_Date).format('DD-MMM-YYYY');
                            }, "width": "7%", "orderable": true
                        },
                        { "data": "mr_no_sequence", "name": "mr_no_sequence", "width": "8%", "orderable": true },
                        { "data": "Full_Name", "name": "Full_Name", "width": "10%", "orderable": false },
                        { "data": "Father_Name", "width": "10%", "orderable": false },

                        //{
                        //    "data": "Discharge_ON",
                        //    "render": function (data, type, full) {
                        //        return data ? moment(data).format('DD-MMM-YYYY') : '';
                        //    },
                        //    "width": "10%", "orderable": false
                        //},
                        { "data": "Created_by", "name": "Created_by", "width": "10%", "orderable": true },
                        
                        {
                            "render": function (data, type, full) {
                                var res = '<a href="#" onclick="editOpen(' + full.In_Patient_ID + ')" class="editListBtn" style="border-radius: 4px;padding: 5px 8px;"><i class="fa fa-pencil"></i></a>';
                                var Del = '<a class="delListBtn" href="#" style="border-radius: 4px;margin-left: 4px;color:white;padding: 5px 8px;" onclick="deleteConfirm(this)"><i class="fa fa-trash"></i></a>';
                               // var print = '<a class="printListBtn" style="border-radius: 4px;margin-left: 4px;color:white;padding: 5px 8px;" href="#" onclick="PrintSlip(' + full.In_Patient_ID + ')"><i class="fa fa-print"></i></a>';
                                if (full.Birth_Date) {
                                    printBtn = '<a class="printListBtn" href="#" style="border-radius: 4px; margin-left: 4px; color: white; padding: 5px 8px;" onclick="PrintBirthCertificate(' + full.In_Patient_ID + ')"><i class="fa fa-print"></i></a>';
                                }
                                return res + Del  + printBtn;
                            },
                            "width": "13%", "orderable": false
                        }
                    ],
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

            function editOpen(id) {
                window.open("Birthcertificate.aspx?BC_ID=" + id, "_blank");
            }

        </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
       <div id="POdetails" style="margin-top: 15px;">
       <div>
      <table class="table table-hover table-striped table-bordered" id="tblResult" style="overflow:scroll; height:auto;">
           <thead id="ihead">
               <tr>
                  
                   <th>Certificate ID</th>
                   <th>Date</th>
                   <th>MR No.</th>
                   <th>Patient Name</th> 
                   <th>Father/Husband Name</th>                              
                   <th>Created By</th>                              
                   <th>Actions</th>
               </tr>
           </thead>
           <tbody id="ibody">
           </tbody>
       </table>
</div>
        </div>

</asp:Content>
