<%@ Page Title="Zakat Donation Records" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ZakatDonationList.aspx.cs" Inherits="PMS.Modules.Billing.ZakatDonationList" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/lib/sweetalert/tablestyle.css" rel="stylesheet" />
    <style>
        .table-container {
            margin-top: 20px;
        }
        .action-buttons a {
            margin: 0 4px;
        }
        .status-badge {
            padding: 5px 10px;
            border-radius: 4px;
            font-size: 12px;
        }
        .editListBtn,
        .printListBtn {
            border-radius: 4px;
            margin-left: 4px;
            color: white;
            padding: 5px 8px 5px 8px;
            display: inline-block;
            background: transparent;
        }
        .editListBtn:hover,
        .printListBtn:hover {
            background: #000 !important;
        }
        .editListBtn:hover i,
        .printListBtn:hover i {
            color: #fff !important;
        }
    </style>
    <script type="text/javascript">
        $(document).ready(function () {
            LoadDonationList();
        });

        function LoadDonationList() {
            let savedVisibility = null;
            
            $.ajax({
                type: "POST",
                url: "ZakatDonationList.aspx/GetUserColumnPreferences",
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

            var table = $("#donationTable").DataTable({
                processing: true,
                serverSide: true,
                destroy: true,
                dom: 'lBfrtip',
                lengthChange: true,
                columnDefs: savedVisibility ? [] : [
                    { targets: [0], visible: false },
                    { targets: [9], className: "noVis" }
                ],

                buttons: [
                    {
                        text: 'Add New',
                        className: 'dt-button buttons-excel',
                        action: function () {
                            window.location = 'ZakatDonationForm.aspx';
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

                order: [[1, "desc"], [2, "asc"]],

                ajax: function (data, callback) {
                    $.ajax({
                        type: "POST",
                        url: "ZakatDonationList.aspx/GetDonationList",
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
                        error: function () {
                            callback({
                                draw: data.draw,
                                recordsTotal: 0,
                                recordsFiltered: 0,
                                data: []
                            });
                        }
                    });
                },

                columns: [
                    { data: "RecordID", visible: false, orderable: false },
                    { data: "TransactionDateTime", name: "TransactionDateTime", 
                      render: function (data) {
                          return data ? moment(data).format('DD-MMM-YYYY HH:mm') : '';
                      }
                    },
                    { data: "DonorID", name: "DonorID" },
                    { data: "DonorReceiptNo", name: "DonorReceiptNo" },
                    { data: "DonorName", name: "DonorName" },
                    { data: "PhoneNo", name: "PhoneNo" },
                    { data: "ProjectName", name: "ProjectName" },
                    { data: "DonationType", name: "DonationType" },
                    { data: "ReceiptAmount", name: "ReceiptAmount",
                      render: function (data) {
                          return 'Rs. ' + parseFloat(data).toFixed(2);
                      }
                    },
                    { data: "PaymentType", name: "PaymentType" },
                    {
                        data: null,
                        orderable: false,
                        searchable: false,
                        render: function (data, type, full) {
                            return `
      <a href="#" onclick="editDonation(${full.RecordID})" class="editListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" title="Edit">
          <i class="fa fa-pencil" style="color: #667eea;"></i>
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
                                } else if (index === 10) { // Actions column
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

                    var lengthContainer = document.querySelector('#donationTable_length');
                    var lengthDropdown = document.querySelector('#donationTable_length select');
                    var label = document.querySelector('#donationTable_length label');

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

        function editDonation(recordId) {
            window.location = 'ZakatDonationForm.aspx?recordId=' + recordId;
        }

        function deleteDonation(recordId) {
            Swal.fire({
                title: 'Delete Donation?',
                text: 'Are you sure you want to delete this donation record? This action cannot be undone.',
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#d33',
                confirmButtonText: 'Yes, delete it!',
                cancelButtonText: 'Cancel',
                reverseButtons: true
            }).then((result) => {
                if (result.isConfirmed) {
                    $.ajax({
                        type: "POST",
                        url: "ZakatDonationList.aspx/DeleteDonation",
                        data: JSON.stringify({ recordId: recordId }),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (response) {
                            if (response.d && response.d.Success) {
                                Swal.fire({
                                    title: 'Deleted!',
                                    text: 'Donation record has been deleted.',
                                    icon: 'success'
                                }).then(() => {
                                    $('#donationTable').DataTable().ajax.reload();
                                });
                            } else {
                                Swal.fire({
                                    title: 'Error!',
                                    text: response.d.Message || 'Failed to delete record',
                                    icon: 'error'
                                });
                            }
                        },
                        error: function () {
                            Swal.fire({
                                title: 'Error!',
                                text: 'An error occurred while deleting the record',
                                icon: 'error'
                            });
                        }
                    });
                }
            });
        }

        function viewDetails(recordId) {
            $.ajax({
                type: "POST",
                url: "ZakatDonationList.aspx/GetDonationDetails",
                data: JSON.stringify({ recordId: recordId }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response.d) {
                        var d = response.d;
                        var html = `
                            <strong>Donor Information:</strong><br/>
                            <b>Name:</b> ${escapeHtml(d.DonorName)}<br/>
                            <b>Phone:</b> ${d.PhoneNo || 'N/A'}<br/>
                            <b>Address:</b> ${escapeHtml(d.DonorAddress) || 'N/A'}<br/>
                            <hr/>
                            <strong>Donation Details:</strong><br/>
                            <b>Type:</b> ${d.DonationType}<br/>
                            <b>Project:</b> ${escapeHtml(d.ProjectName)}<br/>
                            <b>Amount:</b> Rs. ${parseFloat(d.ReceiptAmount).toFixed(2)}<br/>
                            <b>Payment Type:</b> ${d.PaymentType}<br/>
                            ${d.PaymentType === 'Cheque' ? '<b>Cheque No:</b> ' + d.ChequeNo + '<br/>' : ''}
                            <b>Date/Time:</b> ${moment(d.TransactionDateTime).format('DD-MMM-YYYY HH:mm')}<br/>
                            ${d.DonorDetail ? '<hr/><b>Notes:</b> ' + escapeHtml(d.DonorDetail) : ''}
                        `;
                        Swal.fire({
                            title: 'Donation Details',
                            html: html,
                            icon: 'info',
                            confirmButtonText: 'Close'
                        });
                    }
                },
                error: function () {
                    Swal.fire({
                        title: 'Error!',
                        text: 'Failed to load donation details',
                        icon: 'error'
                    });
                }
            });
        }

        function escapeHtml(text) {
            if (!text) return '';
            return $('<div>').text(text).html();
        }
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
      
        <div class="table-container col-lg-12 col-md-12 col-sm-12">
            <table id="donationTable" class="table table-striped table-bordered display" style="width:100%">
                <thead>
                    <tr>
                        <th>RecordID</th>
                        <th>Transaction Date</th>
                        <th>Donor ID</th>
                        <th>Receipt No</th>
                        <th>Donor Name</th>
                        <th>Phone</th>
                        <th>Project Name</th>
                        <th>Donation Type</th>
                        <th>Amount</th>
                        <th>Payment Type</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody></tbody>
            </table>
        </div>
    </div>
</asp:Content>