<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AdvanceList.aspx.cs" Inherits="PMS.AdvanceList" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
<script src="<%= Page.ResolveClientUrl("~/javascripts/stocktransfer.js") %>" type="text/javascript"></script>
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />

    <!-- SweetAlert CSS -->
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css" rel="stylesheet" />
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
  
    <script type="text/javascript">

        $(document).ready(function () {
            $('#ctl00_lblMessage').hide();
            LoadPage();
        });

        function PrintTest(id) {
            window.open('ReportViewer.aspx?ReportName=TestDefination&ReportTitle= Test Defination&Test_IDs=' + id);
        }

        function PrintReport(Advance_ID) {
            debugger;
            window.open('../../ReportViewer.aspx?ReportName=PrintAdvanceReport&ReportTitle= AdvancePrint&Adv_IDs=' + Advance_ID);
        }

        function EditAdvance(advId) {
            debugger;
            window.open("AddNewAdvance.aspx?advID=" + advId);
        }

        function DeleteAdv(advid) {
            debugger;
            if (confirm('Are you sure want to delete this record')) {
                PageMethods.DeleteRecord(advid, function (msg) {
                    debugger;
                    if (msg == true) {
                        $('#tblAdvanceView').DataTable().ajax.reload();
                    } else {
                        alert(msg);
                    }
                }, OnFail);
            }
        }

        function OnFail(exc) {
            alert(exc.get_message());
        }

        // Function to approve selected advances
        function ApproveSelected() {
            var selectedIds = [];
            $('.chkApprove:checked:not(:disabled)').each(function() {
                selectedIds.push($(this).val());
            });
            
            if (selectedIds.length === 0) {
                Swal.fire({
                    icon: 'warning',
                    title: 'No Selection',
                    text: 'Please select at least one record to approve'
                });
                return;
            }
            
            Swal.fire({
                title: 'Confirm Approval',
                text: 'Are you sure you want to approve ' + selectedIds.length + ' record(s)?',
                icon: 'question',
                showCancelButton: true,
                confirmButtonColor: '#28a745',
                cancelButtonColor: '#d33',
                confirmButtonText: 'Yes, Approve!',
                cancelButtonText: 'Cancel'
            }).then((result) => {
                if (result.isConfirmed) {
                    Swal.fire({
                        title: 'Processing...',
                        text: 'Please wait',
                        allowOutsideClick: false,
                        showConfirmButton: false,
                        didOpen: () => {
                            Swal.showLoading();
                        }
                    });
                    
                    PageMethods.ApproveAdvances(selectedIds.join(','), function (response) {
                        var result = JSON.parse(response);
                        
                        if (result.Success) {
                            let messageHtml = `<div style="text-align: left;">
                                <p><strong>Total Records:</strong> ${result.TotalRecords}</p>
                                <p><strong>Approved:</strong> ${result.ApprovedCount}</p>
                                <p><strong>Failed:</strong> ${result.FailedCount}</p>
                            </div>`;
                            
                            if (result.Details && result.Details.length > 0) {
                                messageHtml += `<hr><div style="max-height: 200px; overflow-y: auto;">`;
                                for (var i = 0; i < result.Details.length; i++) {
                                    var detail = result.Details[i];
                                    if (detail.Success) {
                                        messageHtml += `<p style="color: green;">✅ Advance #${detail.AdvanceID}: ${detail.Message}</p>`;
                                    } else {
                                        messageHtml += `<p style="color: red;">❌ Advance #${detail.AdvanceID}: ${detail.Message}</p>`;
                                    }
                                }
                                messageHtml += `</div>`;
                            }
                            
                            Swal.fire({
                                icon: 'success',
                                title: 'Approval Complete!',
                                html: messageHtml,
                                confirmButtonColor: '#28a745'
                            }).then(() => {
                                if (result.ApprovedCount > 0) {
                                    location.reload();
                                }
                            });
                        } else {
                            Swal.fire({
                                icon: 'error',
                                title: 'Approval Failed',
                                text: result.Message || 'Unknown error occurred',
                                confirmButtonColor: '#d33'
                            });
                        }
                    }, OnFail);
                }
            });
        }

        function LoadPage() {
            let savedVisibility = null;

            $.ajax({
                type: "POST",
                url: "AdvanceList.aspx/GetUserColumnPreferences",
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

            $("#tblAdvanceView").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                buttons: [
                    {
                        text: 'Add',
                        className: 'dt-button buttons-copy buttons-html5',
                        action: function () {
                            window.location = 'AddNewAdvance.aspx';
                        }
                    },
                    {
                        text: 'Approve Selected',
                        className: 'dt-button buttons-copy buttons-html5',
                        action: function () {
                            ApproveSelected();
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
                "filter": true,
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "AdvanceList.aspx/ViewList",
                        data: JSON.stringify({
                            draw: data.draw,
                            start: data.start,
                            length: data.length,
                            sortColumn: data.columns[data.order[0].column].name,
                            sortColumnDirection: data.order[0].dir,
                            searchValue: data.search.value,
                            patientStatusFilter: $('#ddlPatientStatusFilter').val() || 'all'
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
                        "render": function(data, type, full) {
                            // Disable checkbox if Status is Approved
                            if (full.Status === 'Approved') {
                                return '<input type="checkbox" class="chkApprove" value="' + full.Advance_ID + '" disabled="disabled" />';
                            } else {
                                return '<input type="checkbox" class="chkApprove" value="' + full.Advance_ID + '" />';
                            }
                        }
                    },
                    { "data": "Advance_ID", "visible": false, "width": "0%" },
                    { "data": "isCancelled", "visible": false, "orderable": false, "width": "0%" },
                    { "data": "MrNo", "name": "MrNo", "width": "10%", "orderable": true },
                    {
                        "data": "Advance_Date", "name": "Advance_Date",
                        "render": function (data, type, full) {
                            var date = full.Advance_Date;
                            date = moment(date).format('DD-MMM-YYYY');
                            return date;
                        }, "width": "15%", "orderable": true
                    },
                    { "data": "Advance_Amount", "width": "15%", className: "text-right", "orderable": false },
                    { "data": "Remarks", "width": "25%", "orderable": false },
                    { "data": "Status", "width": "10%", "orderable": false,
                        "render": function(data) {
                            if (data === "Approved") {
                                return '<span style="color: green; font-weight: bold;">Approved</span>';
                            } else if (data === "UnApproved") {
                                return '<span style="color: red; font-weight: bold;">UnApproved</span>';
                            } else {
                                return '<span style="color: orange; font-weight: bold;">Created</span>';
                            }
                        }
                    },
                    {
                        "data": "PatientStatus", "name": "PatientStatus", "width": "10%", "orderable": true,
                        "render": function (data) {
                            if (data === "Discharge") {
                                return '<span style="color: #dc3545; font-weight: bold;">Discharge</span>';
                            }
                            return '<span style="color: #28a745; font-weight: bold;">Admit</span>';
                        }
                    },
                    {
                        render: function (data, type, full) {
                            if (full.isCancelled === true) {
                                return '<span style="color:#721c24; font-weight:bold;">Cancelled</span>';
                            }
                            var res = '<a href="#" class="editListBtn" onclick="EditAdvance(' + full.Advance_ID + ')" style="border-radius: 4px;color: white; padding: 5px 8px 5px 8px; background-color: #007bff;"><i class="fa fa-pencil"></i></a>';
                            var Del = '<a class="delListBtn" href="#" style="border-radius: 4px;margin-left: 4px;padding: 5px 8px 5px 8px; background-color: #dc3545; color: white;" onclick="DeleteAdv(' + full.Advance_ID + ')"><i class="fa fa-trash" aria-hidden="true"></i></a>';

                            // Only show print button if Status is Approved
                            var print = '';
                            if (full.Status === 'Approved') {
                                print = '<a class="printListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px 5px 8px; background-color: #17a2b8;" href="#" onclick="PrintReport(' + full.Advance_ID + ')" id="btnprint"><i class="fa fa-print" ></i></a>';
                            }

                            return res + Del + print;
                        }, "width": "10%", "orderable": false
                    }
                ],
                "createdRow": function (row, data, dataIndex) {
                    $(row).addClass('clickable-row');
                    $(row).attr('data-advance-id', data.Advance_ID);
                    if (data.isCancelled === true) {
                        $(row).attr('data-cancelled', '1');
                        $(row).css('background-color', '#f8d7da');
                        $(row).find('td').css('color', '#721c24');
                    }
                },
                "initComplete": function (settings, json) {
                    const api = this.api();
                    
                    // Add Select All checkbox
                    $('.dataTables_length').after('<div style="float: left; margin: 17px 0 0 15px;"><label><input type="checkbox" id="chkSelectAll" /> Select All</label></div>');
                    
                    $('#chkSelectAll').on('click', function() {
                        // Only select enabled checkboxes, not disabled ones
                        $('.chkApprove:not(:disabled)').prop('checked', this.checked);
                        $('#chkSelectAllHeader').prop('checked', this.checked);
                    });
                    
                    if (savedVisibility && Array.isArray(savedVisibility)) {
                        if (savedVisibility.length === api.columns().count() - 1) {
                            api.columns().every(function (index) {
                                var savedIndex = index - 1;
                                if (savedIndex >= 0) {
                                    this.visible(savedVisibility[savedIndex]);
                                }
                            });
                        }
                    }
                    
                    api.on('column-visibility.dt', function (e, settings, column, state) {
                        let currentVis = [];
                        api.columns().every(function (index) {
                            if (index >= 1) {
                                currentVis.push(this.visible());
                            }
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

            $('#ddlPatientStatusFilter').select2({
                width: '180px',
                placeholder: 'Select status'
            });

            $('#ddlPatientStatusFilter').on('change', function () {
                $('#tblAdvanceView').DataTable().ajax.reload();
            });
        }
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div>
        <div class="col-lg-2" style="margin-bottom: 10px;">
            <label style="margin-right: 8px; font-weight: 600;">Patient Status:</label>
            <select id="ddlPatientStatusFilter" style="width: 180px;">
                <option value="all">All</option>
                <option value="admit">Admit</option>
                <option value="discharge">Discharge</option>
            </select>
        </div>
        <table id="tblAdvanceView" class="table table-hover table-striped table-bordered">
            <thead>
                <tr>
                     <th style="width:5%"><input type="checkbox" id="chkSelectAllHeader" /></th>
                     <th style="display:none">Advance_ID</th>
                     <th style="display:none">Is Cancel</th>
                     <th>Mr No#</th>
                     <th>Advance Date</th>
                     <th>Advance Amount</th>
                     <th>Remarks</th>
                     <th>Status</th>
                     <th>Patient Status</th>
                     <th>Action</th>
                  </tr>
                </thead>
                <tbody>
                </tbody>
            </table>
    </div>

    <script type="text/javascript">
        // Handle header checkbox
        $(document).on('click', '#chkSelectAllHeader', function() {
            var isChecked = $(this).prop('checked');
            // Only select enabled checkboxes, not disabled ones
            $('.chkApprove:not(:disabled)').prop('checked', isChecked);
            $('#chkSelectAll').prop('checked', isChecked);
        });
        
        // Sync header checkbox with individual checkboxes
        $(document).on('change', '.chkApprove', function() {
            var allChecked = $('.chkApprove:not(:disabled)').length === $('.chkApprove:checked:not(:disabled)').length;
            $('#chkSelectAllHeader').prop('checked', allChecked);
            $('#chkSelectAll').prop('checked', allChecked);
        });
    </script>
</asp:Content>