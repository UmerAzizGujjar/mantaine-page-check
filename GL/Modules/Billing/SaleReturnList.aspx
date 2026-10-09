<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="SaleReturnList.aspx.cs" Inherits="PMS.Modules.Billing.SaleReturnList" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">

        $(document).ready(function () {
            $('#ctl00_lblMessage').hide();
            LoadPage();

            $(document).on('change', '#header-check', function () {
                $('#tbl tbody .issue-checkbox:not(:disabled)').prop('checked', $(this).prop('checked'));
            });

            $(document).on('change', '.issue-checkbox', function () {
                var total = $('#tbl tbody .issue-checkbox:not(:disabled)').length;
                var checked = $('#tbl tbody .issue-checkbox:checked:not(:disabled)').length;
                $('#header-check').prop('checked', total > 0 && total === checked);
            });
        });

        function ApproveSelected() {
            var selectedIds = [];
            $('#tbl tbody .issue-checkbox:checked:not(:disabled)').each(function () {
                selectedIds.push($(this).val());
            });

            if (selectedIds.length === 0) {
                Swal.fire({
                    icon: 'warning',
                    title: 'No Selection',
                    text: 'Please select at least one record to approve (only Created records can be approved).',
                    confirmButtonColor: '#3085d6'
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
                if (!result.isConfirmed) return;

                Swal.fire({
                    title: 'Processing...',
                    text: 'Please wait',
                    allowOutsideClick: false,
                    showConfirmButton: false,
                    didOpen: () => { Swal.showLoading(); }
                });

                var successCount = 0, failedCount = 0, processed = 0, failedDetails = [];

                function finalizeApproval() {
                    if (processed !== selectedIds.length) return;
                    var html = '<div style="text-align: left;">' +
                        '<p><strong>Total Selected:</strong> ' + selectedIds.length + '</p>' +
                        '<p style="color: green;"><strong>Approved:</strong> ' + successCount + '</p>' +
                        '<p style="color: red;"><strong>Failed:</strong> ' + failedCount + '</p>';
                    if (failedDetails.length > 0) {
                        html += '<hr><div style="max-height: 150px; overflow-y: auto; font-size: 12px;">';
                        for (var i = 0; i < failedDetails.length; i++) {
                            html += '<p style="color: red;">' + failedDetails[i] + '</p>';
                        }
                        html += '</div>';
                    }
                    html += '</div>';

                    Swal.fire({
                        icon: successCount > 0 ? 'success' : 'error',
                        title: 'Approval Complete',
                        html: html,
                        confirmButtonColor: '#28a745'
                    }).then(() => {
                        $('#tbl').DataTable().ajax.reload();
                        $('#header-check').prop('checked', false);
                    });
                }

                selectedIds.forEach(function (returnId) {
                    $.ajax({
                        type: "POST",
                        url: "SaleReturnList.aspx/ApproveReturn",
                        data: JSON.stringify({ returnId: String(returnId) }),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (response) {
                            processed++;
                            var res = {};
                            try { res = JSON.parse(response.d); } catch (e) { }
                            if (res.Success === true) {
                                successCount++;
                            } else {
                                failedCount++;
                                failedDetails.push('Return #' + returnId + ': ' + (res.Message || 'Unknown response'));
                            }
                            finalizeApproval();
                        },
                        error: function (xhr, status, error) {
                            processed++;
                            failedCount++;
                            failedDetails.push('Return #' + returnId + ': ' + (error || 'Unknown error'));
                            finalizeApproval();
                        }
                    });
                });
            });
        }

       
        function PrintInvoice(key) {
            //var BillId = $('#BillId' + key).val();
            window.open('../../ReportViewer.aspx?ReportName=PharmacyReturnSlip&ReportTitle=PharmacySlip&Return_ID=' + key);

        }


        function LoadPage() {
            $("#tbl").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                buttons: [
                    {
                        text: '<i class="fa fa-check"></i> Approve Selected',
                        className: 'dt-button buttons-copy buttons-html5',
                        action: function () { ApproveSelected(); }
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
                        url: "SaleReturnList.aspx/ViewList",
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
                            if (full.Status === "Approved") {
                                return '<input type="checkbox" class="issue-checkbox" disabled />';
                            }
                            return '<input type="checkbox" class="issue-checkbox" value="' + full.Return_ID + '" />';
                        },
                        "createdCell": function (td) { $(td).css('text-align', 'center'); }
                    },
                    { "data": "Return_ID", "visible": false, "width": "0%" },                                                    
                    {
                        "data": "Created_Date", "name": "Created_Date",
                        "render": function (data, type, full) {
                            var date = full.Created_Date;
                            date = moment(date).format('DD-MMM-YYYY');
                            return date;
                        }, "width": "15%"
                    },
                    { "data": "Seq_InvoiceNo", "width": "10%" }, 
                    { "data": "TotalDisc_Amount", "width": "15%", },
                    { "data": "Net_Amount", "name": "Net_Amount", "width": "10%" },                    
                    { "data": "Total_Amount", "width": "10%", },
                    { "data": "UserName", "width": "10%", },
                    {
                        "data": "Status",
                        "width": "8%",
                        "orderable": false,
                        "render": function (data) {
                            if (data === "Approved") {
                                return '<span style="background-color: #28a745; padding: 4px 8px; border-radius: 4px; color: white; font-size: 11px; font-weight: bold;">Approved</span>';
                            }
                            return '<span style="background-color: #ffc107; padding: 4px 8px; border-radius: 4px; color: #333; font-size: 11px; font-weight: bold;">Created</span>';
                        }
                    },
                    {
                        render: function (data, type, full) {
                            var res = '<a href="#" onclick="PrintInvoice(' + full.Return_ID + ')" style="border-radius: 4px; background-color: #1f1fe3; color: white; padding: 5px 8px 5px 8px;"><i style="color:white !important;" class="fa fa-upload"></i></a>'
                      
                            var result;
                            result = res;
                            return result;
                        }, "width": "10%"
                    }
                ],
                "initComplete": function (settings, json) {
                    var lengthDropdown = document.querySelector('#tbl_length select');
                    var label = document.querySelector('#tbl_length label');
                    if (lengthDropdown && label) {
                        label.innerHTML = 'Show entries ';
                        label.appendChild(lengthDropdown);
                    } else {
                        console.log("Length dropdown or label not found");
                    }
                }
            });
        }
        
    </script>



</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
        <div class="table-container">
            <table id="tbl" class="table table-bordered table-hover table-striped">
                <thead id="ihead">
                    <tr>
                        <th style="text-align:center;"><input type="checkbox" id="header-check" /></th>
                        <th style="display:none;">Return_ID</th>
                        <th>Return Date</th>
                        <th>Inv No</th>
                        <th>Total Discount</th>
                        <th>Net Amount</th>
                        <th>Total Amount</th>
                        <th>Operator</th>
                        <th>Status</th>
                        <th>Action</th>                      
                    </tr>
                </thead>
                <tbody id="tbody">
                </tbody>
            </table>
        </div>
    </div>

</asp:Content>
