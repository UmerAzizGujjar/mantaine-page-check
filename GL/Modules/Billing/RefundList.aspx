<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="RefundList.aspx.cs" Inherits="PMS.RefundList" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />
        <script type="text/javascript">
            $(document).ready(function () {
                $('#ctl00_lblMessage').hide();
                LoadPage();


                $(document).on('change', '#header-check', function () {
                    var isChecked = $(this).prop('checked');
                    $('#tblAdvanceView tbody .refund-checkbox').prop('checked', isChecked);
                });

                $(document).on('change', '.refund-checkbox', function () {
                    var allChecked = $('#tblAdvanceView tbody .refund-checkbox:checked').length ===
                        $('#tblAdvanceView tbody .refund-checkbox').length;
                    $('#header-check').prop('checked', allChecked);
                });


            });
            function EditAdvance(advId) {
                debugger;
                window.open("Refund.aspx?advID=" + advId);
            }


            function PrintRefund(Refund_ID) {
                debugger;
                var locationInfo = window.location;
                var url = "/ReportViewer.aspx?ReportName=PrintRefundReport&Title=Refund Print &Refund_ID=" + Refund_ID;
                if (!locationInfo.origin.includes('localhost')) {
                    var urlInfo = window.location.href.split('/');
                    var ip = urlInfo[2];
                    var foldername = urlInfo[3];
                    url = 'http://' + ip + '/' + foldername + "/ReportViewer.aspx?ReportName=PrintRefundReport&Title=Refund Print &Refund_ID=" + Refund_ID;
                }
                window.open(url, '_blank');
            }

            function deleteConfirm(anchorTag) {
                var table = $('#tblAdvanceView').DataTable();
                var row = $(anchorTag).closest('tr');
                var rowData = table.row(row).data();
                var RefundID = rowData.Refund_ID;

                if (confirm('Are you sure you want to delete this record?')) {
                    PageMethods.DeleteRecord(RefundID, function (result) {
                        if (result) {
                            location.reload();
                        } else {
                            alert("This record is in use and cannot be deleted");
                        }
                    });
                }
            }

           
            function LoadPage() {
                let savedVisibility = null;

                $.ajax({
                    type: "POST",
                    url: "RefundList.aspx/GetUserColumnPreferences",
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
                                window.location = 'Refund.aspx';
                            }
                        },
                        {
                            text: '<i class="fa fa-check"></i> Approve',
                            className: 'dt-button buttons-copy buttons-html5',
                            action: function (e, dt, node, config) {
                                var selected = [];
                                $('#tblAdvanceView tbody .refund-checkbox:checked').each(function () {
                                    selected.push($(this).val());
                                });
                                if (selected.length === 0) {
                                    Swal.fire({
                                        icon: 'warning',
                                        title: 'No Selection',
                                        text: 'Please select at least one refund to approve.',
                                        confirmButtonColor: '#3085d6'
                                    });
                                    return;
                                }
                                Swal.fire({
                                    title: 'Approve Refunds?',
                                    text: "You are about to approve " + selected.length + " record(s).",
                                    icon: 'question',
                                    showCancelButton: true,
                                    confirmButtonColor: '#28a745',
                                    cancelButtonColor: '#d33',    
                                    confirmButtonText: 'Yes, Approve it!'
                                }).then((result) => {
                                    if (result.isConfirmed) {
                                        PageMethods.ApproveRefunds(selected,
                                            function (response) {
                                                var isSuccess = (typeof response.d !== 'undefined') ? response.d : response;

                                                if (isSuccess) {
                                                    Swal.fire({
                                                        icon: 'success',
                                                        title: 'Approved!',
                                                        text: 'Selected refunds have been approved successfully.',
                                                        timer: 2000,
                                                        showConfirmButton: false
                                                    }).then(() => {
                                                        $('#tblAdvanceView').DataTable().ajax.reload();
                                                        $('#header-check').prop('checked', false);
                                                    });
                                                } else {
                                                    Swal.fire({
                                                        icon: 'error',
                                                        title: 'Failed',
                                                        text: 'Approval failed. Some records may be locked or invalid.'
                                                    });
                                                }
                                            },
                                            function (error) {
                                                Swal.fire({
                                                    icon: 'error',
                                                    title: 'Error',
                                                    text: 'An error occurred: ' + (error.get_message ? error.get_message() : error)
                                                });
                                            }
                                        );
                                    }
                                });
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
                            url: "RefundList.aspx/ViewList",
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
                            "render": function (data, type, full) {
                                return '<input type="checkbox" class="refund-checkbox" value="' + full.Refund_ID + '" />';
                            },
                            "createdCell": function (td, cellData, rowData, row, col) {
                                $(td).css('text-align', 'center');
                            }
                        },
                        { "data": "Refund_ID", "visible": false, "width": "0%" },
                        { "data": "isCancelled", "visible": false, "orderable": false, "width": "0%" },
                        { "data": "Bill_ID", "name": "Bill_ID", "width": "8%", "orderable": true },
                        { "data": "Bill_No", "width": "8%", "orderable": false },
                        {
                            "data": "Refund_Date", "name": "Refund_Date",
                            "render": function (data, type, full) {
                                var date = full.Refund_Date;
                                date = moment(date).format('DD-MMM-YYYY');
                                return date;
                            },
                            "width": "10%",
                            "orderable": true
                        },
                        { "data": "Refund_Amount", "width": "8%", className: "text-right", "orderable": false },
                        { "data": "MrNo", "name": "MrNo", "width": "8%", "orderable": false },
                        { "data": "FullName", "name": "FullName", "width": "12%", "orderable": false },
                        { "data": "Test_Main_Department", "name": "Test_Main_Department", "width": "10%", "orderable": false },
                        { "data": "Remarks", "width": "14%", "orderable": false },
                        {
                            "data": "Status",
                            "width": "8%",
                            "orderable": true,
                            "render": function (data, type, full) {
                                if (data === "Approved") {
                                    return '<span class="badge badge-success" style="background-color: #28a745; padding: 5px 10px; border-radius: 4px; color: white;">Approved</span>';
                                } else if (data === "Rejected") {
                                    return '<span class="badge badge-danger" style="background-color: #dc3545; padding: 5px 10px; border-radius: 4px; color: white;">Rejected</span>';
                                } else {
                                    return '<span class="badge badge-warning" style="background-color: #ffc107; padding: 5px 10px; border-radius: 4px; color: #333;">Created</span>';
                                }
                            }
                        },
                        {
                            render: function (data, type, full) {
                                if (full.isCancelled === true) {
                                    return '<span style="color:#721c24; font-weight:bold;">Cancelled</span>';
                                }
                                // Only show Edit button if status is not Approved
                                var editBtn = '';
                                var Del = '';
                                var rejectBtn = '';
                                if (full.Status !== "Approved") {
                                    editBtn = '<a href="#" onclick="EditAdvance(' + full.Refund_ID + ')" class="editListBtn" style="border-radius: 4px;padding: 5px 8px 5px 8px;"><i class="fa fa-pencil"></i></a>';
                                    var Del = '<a class="delListBtn" href="#" style="border-radius: 4px;margin-left: 4px;padding: 5px 8px 5px 8px;" onclick=deleteConfirm(this)><i class="fa fa-trash" aria-hidden="true"></i></a>';

                                    rejectBtn = '<a class="rejectListBtn" href="#" style="border-radius: 4px;margin-left: 4px;padding: 5px 8px;background:#dc3545;color:white;" onclick="RejectRefund(' + full.Refund_ID + ')"><i class="fa fa-ban"></i></a>';

                                }
                                //var Del = '<a class="delListBtn" href="#" style="border-radius: 4px;margin-left: 4px;padding: 5px 8px 5px 8px;" onclick=deleteConfirm(this)><i class="fa fa-trash" aria-hidden="true"></i></a>';
                                var print = '<a class="printListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="PrintRefund(' + full.Refund_ID + ')" id="btnprint"><i class="fa fa-print"></i></a>';
                                var result = editBtn + Del + print + rejectBtn;
                                return result;
                            },
                            "width": "15%",
                            "orderable": false
                    }
                ],
                "createdRow": function (row, data, dataIndex) {
                    $(row).addClass('clickable-row');
                    $(row).attr('data-refund-id', data.Refund_ID);
                    if (data.isCancelled === true) {
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

                        var lengthContainer = document.querySelector('#tblAdvanceView_length');
                        var lengthDropdown = document.querySelector('#tblAdvanceView_length select');
                        var label = document.querySelector('#tblAdvanceView_length label');

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

            function RejectRefund(refundId) {
                Swal.fire({
                    title: 'Reject Refund?',
                    text: "Are You Sure to Rejected",
                    icon: 'warning',
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    },
                    showCancelButton: true,
                    confirmButtonColor: '#dc3545',
                    cancelButtonColor: '#6c757d',
                    confirmButtonText: 'Yes, Reject it!'
                }).then((result) => {
                    if (result.isConfirmed) {
                        PageMethods.RejectRefund(refundId,
                            function (response) {
                                var isSuccess = (typeof response.d !== 'undefined') ? response.d : response;
                                if (isSuccess) {
                                    Swal.fire({
                                        icon: 'success',
                                        title: 'Rejected!',
                                        text: 'Refund has been rejected successfully.',
                                        timer: 2000,
                                        showConfirmButton: false
                                    }).then(() => {
                                        $('#tblAdvanceView').DataTable().ajax.reload();
                                    });
                                } else {
                                    Swal.fire({
                                        icon: 'error',
                                        title: 'Failed',
                                        text: 'Rejection failed. Record may be locked or invalid.'
                                    });
                                }
                            },
                            function (error) {
                                Swal.fire({
                                    icon: 'error',
                                    title: 'Error',
                                    text: 'An error occurred: ' + (error.get_message ? error.get_message() : error)
                                });
                            }
                        );
                    }
                });
            }
        </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    

    <div>
     <table id="tblAdvanceView" class="table table-hover table-striped table-bordered">
    <thead>
        <tr>
            <th style="text-align:center;"><input type="checkbox" id="header-check" /></th>
            <th>Refund_ID</th>
            <th style="display:none">Is Cancel</th>
            <th>Bill_ID</th>
            <th>Bill No</th>
            <th>Refund_Date</th>
            <th>Refund_Amount</th>
            <th>Mr No#</th>
            <th>Name</th>
            <th>Main Department</th>
            <th>Remarks</th>
            <th>Status</th>
            <th>Action</th>
        </tr>
    </thead>
</table>
    </div>

</asp:Content>
           

       