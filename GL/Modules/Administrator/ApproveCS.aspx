<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ApproveCS.aspx.cs" Inherits="PMS.ApproveCS" %>

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

    var appRoot = '<%= ResolveUrl("~/") %>';
    function editOpen(id) {
        window.open(appRoot + 'Modules/AP/ComparativeStatementVendor.aspx?CM_ID=' + id, '_blank');
    }
    function CheckUserRights() {
        $.ajax({
            type: "POST",
            url: "ApproveCS.aspx/CheckUserRights",  // Update to match your page name
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
    function RejectSelectedIds() {
        var selectedData = [];

        $('#tblResult input[type="checkbox"].rowCheck:checked').each(function () {
            var id = $(this).data('id');

            // Assuming input is in the same row as checkbox
            var inputVal = $(this).closest('tr').find('input.rowInput').val();

            selectedData.push({ CSId: id, DecisionRemarks: inputVal });
        });

        console.log(selectedData);

        if (selectedData.length === 0) {
            Swal.fire({
                icon: 'error',
                title: 'Error!',
                text: 'Failed to select Patient',
                showConfirmButton: false,
                timer: 2000,
                customClass: {
                    popup: 'swal-big-popup',
                    title: 'swal-big-title',
                    htmlContainer: 'swal-big-text'
                }
            });
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

        $.ajax({
            type: "POST",
            url: "ApproveCS.aspx/ApproveSelectedCSs",
            contentType: "application/json; charset=utf-8",
            data: JSON.stringify({ CSItems: selectedData }),
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
    function ApproveSelectedIds() {
        var selectedData = [];

        $('#tblResult input[type="checkbox"].rowCheck:checked').each(function () {
            var id = $(this).data('id');

            // Assuming input is in the same row as checkbox
            var inputVal = $(this).closest('tr').find('input.rowInput').val();

            selectedData.push({ CSId: id, DecisionRemarks: inputVal });
        });

        console.log(selectedData);

        if (selectedData.length === 0) {
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

        $.ajax({
            type: "POST",
            url: "ApproveCS.aspx/ApproveSelectedCSs",
            contentType: "application/json; charset=utf-8",
            data: JSON.stringify({ CSItems: selectedData }),
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
                    text: 'Reject CSs',
                    className: 'dt-button buttons-copy buttons-html5',
                    action: function () {
                        RejectSelectedIds();
                    }
                },
                {
                    text: 'Approve CSs',
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
                    url: "ApproveCS.aspx/ViewList",
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
                        var checkboxId = 'chkSelect_' + full.CSID;
                        return '<span style="display:inline-block;width:30px;">' +
                            '<input id="' + checkboxId + '" type="checkbox" class="rowCheck" data-id="' + full.CSID + '">' +
                            '</span>';
                    }, "width": "2%", "orderable": false
                },
                { "data": "CSID", "visible": false, "width": "0%", "orderable": false },
                { "data": "CSNO", "name": "mr_no_sequence", "width": "8%", "orderable": true },
                { "data": "CSDATE", "name": "Opd_No", "width": "5%", "orderable": false },
                { "data": "DEPARTMENT", "visible": false, "width": "10%", "orderable": false },
                
                { "data": "CREATOR", "width": "13%", "orderable": false },
                
                { "data": "REMARKS", "width": "10%", "orderable": false },
                { "data": "STATUS", "width": "10%", "orderable": false },
                { "data": "APPROVEBY", "width": "10%", "orderable": false },
                {
                    render: function (data, type, full, meta) {
                        
                        return  '<input type="text" class="rowInput">';
                    }, "width": "2%", "orderable": false
                },
                {
                    render: function (data, type, full) {
                        return '<a href="#" onclick="editOpen(' + full.CSID + ')" class="editListBtn" style="border-radius: 4px;padding: 5px 8px;"><i class="fa fa-pencil"></i></a>';
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
                <th style="display: none;">CS ID</th>
                <th>CS No.</th>
                <th>CS Date</th>
                <th>Department</th>
                <th>Creator</th>
                 <th>CS Remarks</th>
                <th>Status</th>
                <th>Approve By</th>
                <th>Decision Remarks</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody id="ibody">
        </tbody>
    </table>
</div>
</asp:Content>
