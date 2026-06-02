<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="RegList.aspx.cs" Inherits="PMS.RegList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/css/tablestyle.css" rel="stylesheet" /> 
    <script type="text/javascript">
        $(document).ready(function () {
            $('#ctl00_lblMessage').hide();
            LoadPage();
        });

        function PrintReceipt(pat_id) {
            var locationInfo = window.location;
            var url = "/ReportViewer.aspx?ReportName=Reg_Patient_Print&Title=Register Patient Print &Patient_ID=" + pat_id;

            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + "/ReportViewer.aspx?ReportName=Reg_Patient_Print&Title=Register Patient Print &Patient_ID=" + pat_id;
            }
            window.open(url, '_blank');
        }
        function editOpen(id) {
            Swal.fire({
                title: 'Are you sure?',
                text: `You are about to edit this patient`,
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
                            window.open("RegisterPatient.aspx?Reg_id=" + id, "_blank");
                        }
                    });
                }
            });
        }

        function LoadPage() {
            let savedVisibility = null;
            $.ajax({
                type: "POST",
                url: "RegList.aspx/GetUserColumnPreferences",
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

            var table = $("#example").DataTable({
                processing: true,
                serverSide: true,
                destroy: true,
                dom: 'lBfrtip',
                lengthChange: true,
                columnDefs: savedVisibility ? [] : [
                    { targets: [0], visible: false },
                    { targets: [8], className: "noVis" }
                ],

                buttons: [
                    {
                        text: '<i class="fa fa-plus"></i> Add',
                        className: 'dt-button buttons-copy buttons-html5',
                        action: function () {
                            window.location = 'RegisterPatient.aspx';
                        }
                    },
                    {
                        extend: 'copy',
                        text: '<i class="fa fa-copy"></i> Copy',
                        className: 'dt-button buttons-copy'
                    },
                    {
                        extend: 'excel',
                        text: '<i class="fa fa-file-excel"></i> Excel',
                        className: 'dt-button buttons-excel'
                    },
                    {
                        extend: 'pdf',
                        text: '<i class="fa fa-file-pdf"></i> PDF',
                        className: 'dt-button buttons-pdf'
                    },
                    {
                        extend: 'colvis',
                        text: '<i class="fa fa-columns"></i> Columns',
                        className: 'dt-button buttons-colvis',
                        collectionLayout: 'fixed two-column',
                        postfixButtons: ['colvisRestore']
                    }
                ],

                order: [[1, "asc"]],

                ajax: function (data, callback) {
                    $.ajax({
                        type: "POST",
                        url: "RegList.aspx/ViewList",
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
                        }
                    });
                },

                columns: [
                    { data: "pat_id", visible: false, orderable: false },
                    { data: "MRNO", name: "MRNO" },
                    { data: "Full_Name" },
                    { data: "Age_years", name: "Age_years" },
                    {
                        data: "Created_time",
                        name: "Created_time",
                        render: function (data) {
                            return moment(data).format('DD-MMM-YYYY');
                        }
                    },
                    { data: "NIC" },
                    { data: "Mobile1" },
                    { data: "Permanent_Address" },
                    {
                        data: null,
                        orderable: false,
                        searchable: false,
                        render: function (data, type, full) {
                            return `
       <a href="#" onclick="editOpen(${full.pat_id})" class="editListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" title="Edit">
           <i class="fa fa-pencil" style="color: #667eea;"></i>
       </a>
       <a href="#" class="printListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;"  onclick="PrintReceipt(${full.pat_id})" class="printListBtn" title="Print">
           <i class="fa fa-print"></i>
       </a>`;
                        }
                    }
                ],

                initComplete: function (settings, json) {
                    const api = this.api();
                    if (savedVisibility && Array.isArray(savedVisibility)) {
                        if (savedVisibility.length === api.columns().count()) {
                            api.columns().every(function (index) {
                                if (index === 0) {
                                    this.visible(false); 
                                } else if (index === 8) {
                                    this.visible(true); 
                                } else {
                                    this.visible(savedVisibility[index]);
                                }
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

                drawCallback: function () {
                    var api = this.api();
                    updateColumnHeaders(api);
                }
            });

            table.on('column-visibility.dt', function (e, settings, column, state) {
                setTimeout(function () {
                    updateColumnHeaders(table);
                }, 100);
            });
        }

        function updateColumnHeaders(table) {
            var api = table;
            var headers = api.columns().header();

            api.columns().every(function (index) {
                var column = api.column(index);
                var header = $(headers[index]);
                var isVisible = column.visible();

                if (isVisible) {
                    header.removeClass('hidden-col');
                } else {
                    header.addClass('hidden-col');
                }
            });
        }
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <br />
  
    <div class="row">
        <div class="table-container col-lg-12 col-md-12 col-sm-12">
            <table id="example" class="table table-striped table-bordered display" style="width:100%">
                <thead>
                    <tr>
                        <th>Pat ID</th>
                        <th>MR No.</th>
                        <th>Name</th>
                        <th>Age</th>
                        <th>Created Date</th>
                        <th>CNIC</th>
                        <th>Phone Number</th>
                        <th>Address</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody></tbody>
            </table>
        </div>
    </div>
</asp:Content>