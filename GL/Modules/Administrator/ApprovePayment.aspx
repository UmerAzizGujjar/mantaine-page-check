<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ApprovePayment.aspx.cs" Inherits="PMS.ApprovePayment" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
                <link href="../../wwwroot/lib/sweetalert/tablestyle.css" rel="stylesheet" />
<script type="text/javascript">  
    $(document).ready(function () {
        $('#checkAll').on('change', function () {
            $('.rowCheck').prop('checked', this.checked);
        });
        LoadPage();
        CheckUserRights();


    });
    var __appRoot = '<%= ResolveUrl("~/") %>';
    function editOpen(id) {
        var url = __appRoot + 'Modules/Inventory/AddPaymentInvoice.aspx?Inv_ID=' + id;
        window.open(url, '_blank');
    }
    function CheckUserRights() {
        $.ajax({
            type: "POST",
            url: "ApprovePayment.aspx/CheckUserRights",  // Update to match your page name
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (response) {
                if (response.d === false) {

                    $('#btnApproveHide').hide();

                }
            },
            error: function (xhr, status, error) {
                console.error("AJAX error:", error);
            }
        });
    }
    function ApproveSelectedIds() {
        var selectedIds = [];

        $('#tblResult input[type="checkbox"].rowCheck:checked').each(function () {
            var id = $(this).data('id');
            selectedIds.push(id);
        });
        console.log(selectedIds);
        if (selectedIds.length === 0) {
            Swal.fire({
                icon: 'error',
                title: 'Error!',
                text: 'Please select at least one row',
                showConfirmButton: false,
                timer: 2000,
                customClass: {
                    popup: 'swal-big-popup',
                    title: 'swal-big-title',
                    htmlContainer: 'swal-big-text'
                }
            });
            
            return;
        }

        // Send to backend via AJAX
        $.ajax({
            type: "POST",
            url: "ApprovePayment.aspx/ApproveSelectedPAYMENTs", // Update this
            contentType: "application/json; charset=utf-8",
            data: JSON.stringify({ PAYMENTIds: selectedIds }),
            success: function (response) {
                Swal.fire({
                    icon: 'success',
                    title: 'Success!',
                    text: 'Data saved successfully.',
                    showConfirmButton: false,
                    timer: 2500,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });
             },
            error: function (xhr, status, error) {
                alert("Error: " + error);
            }
        });
        setTimeout(function () {
            location.reload();
        }, 2500);
    }
    function RejectSelectedIds() {
        var selectedIds = [];

        $('#tblResult input[type="checkbox"].rowCheck:checked').each(function () {
            var id = $(this).data('id');
            selectedIds.push(id);
        });

        if (selectedIds.length === 0) {
            Swal.fire({
                icon: 'error',
                title: 'Error!',
                text: 'Please select at least one row',
                showConfirmButton: false,
                timer: 2000,
                customClass: {
                    popup: 'swal-big-popup',
                    title: 'swal-big-title',
                    htmlContainer: 'swal-big-text'
                }
            });
             return;
        }

        // Send to backend via AJAX
        $.ajax({
            type: "POST",
            url: "ApprovePayment.aspx/RejectSelectedPAYMENTs", // Update this
            contentType: "application/json; charset=utf-8",
            data: JSON.stringify({ PAYMENTIds: selectedIds }),
            success: function (response) {
                Swal.fire({
                    icon: 'success',
                    title: 'Success!',
                    text: 'Data saved successfully.',
                    showConfirmButton: false,
                    timer: 2500,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });
             },
            error: function (xhr, status, error) {
                alert("Error: " + error);
            }
        });
        setTimeout(function () {
            location.reload();
        }, 2500);
    }
    function LoadPage() {
        $("#tblResult").DataTable({
            "processing": true,
            "serverSide": true,
            "dom": 'lBfrtip',
            "lengthChange": true,
            "buttons": [
                {
                    text: 'Reject PAYMENTs',
                    className: 'dt-button buttons-copy buttons-html5',
                    action: function () {
                        RejectSelectedIds();
                    }
                },
                {
                    text: 'Approve PAYMENTs',
                    className: 'dt-button buttons-copy buttons-html5',
                    attr: {
                        id: 'btnApproveHide'
                    },
                    action: function () {
                        ApproveSelectedIds();
                    }
                },
                'copy', 'excel', 'pdf',
            ],
            "filter": true,
            "ajax": function (data, callback, settings) {
                $.ajax({
                    type: "POST",
                    url: "ApprovePayment.aspx/ViewList",
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
                    render: function (data, type, full, meta) {
                        var checkboxId = 'chkSelect_' + full.PAYMENTID;
                        return '<span style="display:inline-block;width:30px;">' +
                            '<input id="' + checkboxId + '" type="checkbox" class="rowCheck" data-id="' + full.PAYMENTID + '">' +
                            '</span>';
                    }, "width": "2%", "orderable": false
                },
                { "data": "PAYMENTID", "visible": false, "width": "0%", "orderable": false },
                { "data": "PAYMENTNO", "name": "mr_no_sequence", "width": "8%", "orderable": true },
                {
                    "data": "PAYMENTDATE", "name": "PAYMENTDATE",
                    "render": function (data, type, full) {
                        debugger;
                        var date = full.PAYMENTDATE;
                        date = moment(date).format('DD-MMM-YYYY');
                        return date;
                    }, "width": "9%"
                },
                 { "data": "CREATOR", "width": "13%", "orderable": false },
                 { "data": "REMARKS", "width": "10%", "orderable": false },
                { "data": "STATUS", "width": "10%", "orderable": false },
                { "data": "APPROVEBY", "width": "10%", "orderable": false },
                {
                    render: function (data, type, full) {
                        return '<a href="#" onclick="editOpen(' + full.PAYMENTID + ')" class="editListBtn" style="border-radius: 4px;padding: 5px 8px;"><i class="fa fa-pencil"></i></a>';
                    }, "width": "7%", "orderable": false
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
            },
            createdRow: function (row, data, dataIndex) {
                if (data.STATUS && data.STATUS.toString().toLowerCase().trim() === 'pending') {
                    $(row).css('background-color', '#ffe066');
                }
            }

        });
    }
</script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
         <div class="table-container col-lg-12 col-md-12 col-sm-10">
    <table class="table table-hover table-striped table-bordered" id="tblResult" style="overflow: scroll; height: auto;">
        <thead id="ihead">
            <tr>
                <th><span style="display:inline-block;width:30px;"><input id="checkAll" type="checkbox"/></span></th>
                <th style="display: none;">PAYMENT ID</th>
                <th>PAYMENT No.</th>
                <th>PAYMENT Date</th>
                <th>Creator</th>
                <th>Remarks</th>
                <th>Status</th>
                <th>Approve By</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody id="ibody">
        </tbody>
    </table>
</div>



</asp:Content>
