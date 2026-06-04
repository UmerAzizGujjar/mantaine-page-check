<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ApproveGoodsReturn.aspx.cs" Inherits="PMS.Modules.Administrator.ApproveGoodsReturn" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />
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
           var url = __appRoot + 'Modules/Inventory/GoodsReturnNote.aspx?SR_ID=' + id;
           window.open(url, '_blank');
       }

       function CheckUserRights() {
           $.ajax({
               type: "POST",
               url: __appRoot + "Modules/Administrator/ApproveGoodsReturn.aspx/CheckUserRights",
               contentType: "application/json; charset=utf-8",
               dataType: "json",
               success: function (response) {
                   console.log("CheckUserRights Response:", response);
                   if (response.d === false) {
                       $('#btnApproveHide').hide();
                   }
               },
               error: function (xhr, status, error) {
                   console.error("CheckUserRights Error:", error);
                   console.error("Response:", xhr.responseText);
               }
           });
       }

       function ApproveSelectedIds() {
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
                   timer: 2000
               });
               return;
           }

           Swal.fire({
               title: 'Are you sure?',
               text: "You want to approve the selected Store Return Notes?",
               icon: 'warning',
               showCancelButton: true,
               confirmButtonColor: '#3085d6',
               cancelButtonColor: '#d33',
               confirmButtonText: 'Yes, approve them!'
           }).then((result) => {
               if (result.isConfirmed) {
                   $.ajax({
                       type: "POST",
                       url: __appRoot + "Modules/Administrator/ApproveGoodsReturn.aspx/ApproveSelectedGRVs",
                       contentType: "application/json; charset=utf-8",
                       data: JSON.stringify({ GRVIds: selectedIds }),
                       beforeSend: function () {
                           console.log("Approving IDs:", selectedIds);
                       },
                       success: function (response) {
                           console.log("Approve Success:", response);
                           Swal.fire({
                               icon: 'success',
                               title: 'Success!',
                               text: 'Store Return Notes approved successfully.',
                               showConfirmButton: false,
                               timer: 2500
                           });
                           setTimeout(function () {
                               location.reload();
                           }, 2500);
                       },
                       error: function (xhr, status, error) {
                           console.error("Approve Error:", error);
                           console.error("Response:", xhr.responseText);
                           Swal.fire({
                               icon: 'error',
                               title: 'Error!',
                               text: 'Failed to approve Store Return Notes',
                               showConfirmButton: true
                           });
                       }
                   });
               }
           });
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
                   timer: 2000
               });
               return;
           }

           Swal.fire({
               title: 'Are you sure?',
               text: "You want to reject the selected Store Return Notes?",
               icon: 'warning',
               showCancelButton: true,
               confirmButtonColor: '#d33',
               cancelButtonColor: '#3085d6',
               confirmButtonText: 'Yes, reject them!'
           }).then((result) => {
               if (result.isConfirmed) {
                   $.ajax({
                       type: "POST",
                       url: __appRoot + "Modules/Administrator/ApproveGoodsReturn.aspx/RejectSelectedGRVs",
                       contentType: "application/json; charset=utf-8",
                       data: JSON.stringify({ GRVIds: selectedIds }),
                       beforeSend: function () {
                           console.log("Rejecting IDs:", selectedIds);
                       },
                       success: function (response) {
                           console.log("Reject Success:", response);
                           Swal.fire({
                               icon: 'success',
                               title: 'Success!',
                               text: 'Store Return Notes rejected successfully.',
                               showConfirmButton: false,
                               timer: 2500
                           });
                           setTimeout(function () {
                               location.reload();
                           }, 2500);
                       },
                       error: function (xhr, status, error) {
                           console.error("Reject Error:", error);
                           console.error("Response:", xhr.responseText);
                           Swal.fire({
                               icon: 'error',
                               title: 'Error!',
                               text: 'Failed to reject Store Return Notes',
                               showConfirmButton: true
                           });
                       }
                   });
               }
           });
       }

       function LoadPage() {
           console.log("Loading DataTable...");
           $("#tblResult").DataTable({
               "processing": true,
               "serverSide": true,
               "dom": 'lBfrtip',
               "lengthChange": true,
               "buttons": [
                   {
                       text: 'Reject Returns',
                       className: 'dt-button buttons-copy buttons-html5',
                       action: function () {
                           RejectSelectedIds();
                       }
                   },
                   {
                       text: 'Approve Returns',
                       className: 'dt-button buttons-copy buttons-html5',
                       //attr: {
                       //    id: 'btnApproveHide'
                       //},
                       action: function () {
                           ApproveSelectedIds();
                       }
                   },
                   'copy', 'excel', 'pdf'
               ],
               "filter": true,
               "ajax": {
                   type: "POST",
                   url: __appRoot + "Modules/Administrator/ApproveGoodsReturn.aspx/ViewList",
                   contentType: "application/json; charset=utf-8",
                   dataType: "json",
                   data: function (d) {
                       return JSON.stringify({
                           draw: d.draw,
                           start: d.start,
                           length: d.length,
                           sortColumn: d.columns[d.order[0].column].data,
                           sortColumnDirection: d.order[0].dir,
                           searchValue: d.search.value
                       });
                   },
                   dataSrc: function (json) {
                       console.log("DataTable Response:", json);
                       return json.d.data;
                   },
                   error: function (xhr, status, error) {
                       console.error("DataTable Error:", error);
                       console.error("Response:", xhr.responseText);
                   }
               },
               "columns": [
                   {
                       data: null,
                       render: function (data, type, full, meta) {
                           return '<span style="display:inline-block;width:30px;">' +
                               '<input type="checkbox" class="rowCheck" data-id="' + full.SRID + '">' +
                               '</span>';
                       },
                       "width": "2%",
                       "orderable": false
                   },
                   { "data": "SRID", "visible": false, "width": "0%", "orderable": false },
                   { "data": "SRNO", "name": "sr_no_sequence", "width": "8%", "orderable": true },
                   { "data": "Department", "width": "13%", "orderable": false },
                   { "data": "CREATOR", "width": "13%", "orderable": false },
                   { "data": "STATUS", "width": "10%", "orderable": false },
                   { "data": "APPROVEBY", "width": "10%", "orderable": false },
                   {
                       data: null,
                       render: function (data, type, full) {
                           return '<a href="#" onclick="editOpen(' + full.SRID + '); return false;" class="editListBtn" style="border-radius: 4px;padding: 5px 8px;"><i class="fa fa-pencil"></i></a>';
                       },
                       "width": "7%",
                       "orderable": false
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
    <div class="container-fluid" style="padding: 20px;">        
        <div class="table-container col-lg-12 col-md-12 col-sm-10">
            <table class="table table-hover table-striped table-bordered" id="tblResult" style="width:100%;">
                <thead id="ihead">
                    <tr>
                        <th><input id="checkAll" type="checkbox"/></th>
                        <th style="display: none;">Return ID</th>
                        <th>Return No.</th>
                        <th>Department</th>
                        <th>Creator</th>
                        <th>Status</th>
                        <th>Approve By</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody id="ibody">
                </tbody>
            </table>
        </div>
    </div>
</asp:Content>
