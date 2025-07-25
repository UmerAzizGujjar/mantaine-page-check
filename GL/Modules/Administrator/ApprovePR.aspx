<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ApprovePR.aspx.cs" Inherits="PMS.ApprovePR" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
      <link href="../../wwwroot/Tibbit_theme/css/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">        
        $(document).ready(function () {
            LoadPage(); 
            CheckUserRights();
        });
        function editOpen(id) {
            window.open("/Modules/AP/PurchaseRequistion.aspx?PO_ID=" + id, "_blank");

        }
        function CheckUserRights() {
            $.ajax({
                type: "POST",
                url: "ApprovePR.aspx/CheckUserRights",  // Update to match your page name
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

                selectedData.push({ PRId: id, DecisionRemarks: inputVal });
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
                url: "ApprovePR.aspx/ApproveSelectedPRs",
                contentType: "application/json; charset=utf-8",
                data: JSON.stringify({ PRItems: selectedData }),
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
        }
        function ApproveSelectedIds() {
            var selectedData = [];

            $('#tblResult input[type="checkbox"].rowCheck:checked').each(function () {
                var id = $(this).data('id');

                // Assuming input is in the same row as checkbox
                var inputVal = $(this).closest('tr').find('input.rowInput').val();

                selectedData.push({ PRId: id, DecisionRemarks: inputVal });
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
                url: "ApprovePR.aspx/ApproveSelectedPRs",
                contentType: "application/json; charset=utf-8",
                data: JSON.stringify({ PRItems: selectedData }),
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
        }
        function LoadPage() {
            $("#tblResult").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": [
                    {
                        text: 'Reject PRs',
                        className: 'dt-button buttons-copy buttons-html5',
                        action: function () {
                            RejectSelectedIds();
                        }
                    },
                    {
                        text: 'Approve PRs',
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
                        url: "ApprovePR.aspx/ViewList",
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
                            var checkboxId = 'chkSelect_' + full.PRID;
                            return '<span style="display:inline-block;width:30px;">' +
                                '<input id="' + checkboxId + '" type="checkbox" class="rowCheck" data-id="' + full.PRID + '">' +
                                '</span>';
                        }, "width": "2%", "orderable": false
                    },
                    { "data": "PRID", "visible": false, "width": "0%", "orderable": false },
                    { "data": "PRNO", "name": "mr_no_sequence", "width": "8%", "orderable": true },
                    { "data": "PRDATE", "name": "Opd_No", "width": "5%", "orderable": false },
                    { "data": "CREATOR", "width": "13%", "orderable": false },
                    { "data": "DEPARTMENT", "visible": false, "width": "10%", "orderable": false },
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
                            return '<a href="#" onclick="editOpen(' + full.PRID + ')" class="editListBtn" style="border-radius: 4px;padding: 5px 8px;"><i class="fa fa-pencil"></i></a>';
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
                <th>Select</th>
                <th style="display: none;">Company ID</th>
                <th>PR No.</th>
                <th>PR Date</th>
                <th>Creator</th>
                <th style="display: none;">Department</th>
                <th>Remarks</th>
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
