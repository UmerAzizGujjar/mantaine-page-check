<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ApproveIGP.aspx.cs" Inherits="PMS.ApproveIGP" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
      <link href="../../wwwroot/Tibbit_theme/css/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript"
>  $(document).ready(function () {
      $('#checkAll').on('change', function () {
          $('.rowCheck').prop('checked', this.checked);
      });
            LoadPage();
            CheckUserRights();


        });
        function editOpen(id) {
            window.open("/Modules/AP/InversionGatePass?PO_ID=" + id, "_blank");

        }
        function CheckUserRights() {
            $.ajax({
                type: "POST",
                url: "ApproveIGP.aspx/CheckUserRights",  // Update to match your page name
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
                url: "ApproveIGP.aspx/ApproveSelectedIGPs", // Update this
                contentType: "application/json; charset=utf-8",
                data: JSON.stringify({ IGPIds: selectedIds }),
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
                url: "ApproveIGP.aspx/RejectSelectedIGPs", // Update this
                contentType: "application/json; charset=utf-8",
                data: JSON.stringify({ IGPIds: selectedIds }),
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
                        text: 'Reject IGPs',
                        className: 'dt-button buttons-copy buttons-html5',
                        action: function () {
                            RejectSelectedIds();
                        }
                    },
                    {
                        text: 'Approve IGPs',
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
                        url: "ApproveIGP.aspx/ViewList",
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
                            var checkboxId = 'chkSelect_' + full.IGPID;
                            return '<span style="display:inline-block;width:30px;">' +
                                '<input id="' + checkboxId + '" type="checkbox" class="rowCheck" data-id="' + full.IGPID + '">' +
                                '</span>';
                        }, "width": "2%", "orderable": false
                    },
                    { "data": "IGPID", "visible": false, "width": "0%", "orderable": false },
                    { "data": "IGPNO", "name": "mr_no_sequence", "width": "8%", "orderable": true },
                    { "data": "IGPDATE", "name": "mr_no_sequence", "width": "8%", "orderable": true },
                    { "data": "DEPARTMENT", "name": "Opd_No", "width": "5%", "orderable": false },
                    { "data": "CREATOR", "width": "13%", "orderable": false },
                    { "data": "REMARKS", "width": "10%", "orderable": false },
                    { "data": "STATUS", "width": "10%", "orderable": false },
                    { "data": "INSPECTSTATUS", "width": "10%", "orderable": false },
                    { "data": "APPROVEBY", "width": "10%", "orderable": false },
                    {
                        render: function (data, type, full) {
                            return '<a href="#" onclick="editOpen(' + full.IGPID + ')" class="editListBtn" style="border-radius: 4px;padding: 5px 8px;"><i class="fa fa-pencil"></i></a>';
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
                <th><span style="display:inline-block;width:30px;"><input id="checkAll" type="checkbox"/></span></th>
                <th style="display: none;">IGP ID</th>
                <th>IGP No.</th>
                <th>PO Date</th>
                <th >Department</th>
                <th>Creator</th>
                
                <th>Remarks</th>
                <th>Status</th>
                <th>Inspec Status</th>
                <th>Approve By</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody id="ibody">
        </tbody>
    </table>
</div>  

</asp:Content>
