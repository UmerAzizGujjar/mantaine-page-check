<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Define_Policy_View.aspx.cs" Inherits="PMS.Modules.Administrator.Define_Policy_View" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
     <link href="../../wwwroot/THEME_TIBBIT/css/tablestyle.css" rel="stylesheet" />

     <script type="text/javascript">
         $(document).ready(function () {
             debugger;
             $('#ctl00_lblMessage').hide();
             LoadPage();
         });

         function LoadPage() {
             $("#example").DataTable({
                 "processing": true,
                 "serverSide": true,
                 "dom": 'lBfrtip',
                 "lengthChange": true,
                 "buttons": [
                     {
                         text: 'Add',
                         className: 'dt-button buttons-copy buttons-html5',
                         action: function () {
                             window.location = 'Define_Policy.aspx';
                         }
                     },
                     'copy', 'excel', 'pdf',
                     {
                         extend: 'colvis',
                         text: '<i class="fa fa-columns"></i> Columns',
                         className: 'dt-button buttons-colvis',
                         collectionLayout: 'fixed two-column',
                         postfixButtons: ['colvisRestore']
                     }
                 ],
                 "filter": true,
                 "order": [[1, "asc"]],
                 "ajax": function (data, callback, settings) {
                     $.ajax({
                         type: "POST",
                         url: "Define_Policy_View.aspx/ViewList",
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
                     { "data": "Policy_ID", "visible": false, "width": "0%", "orderable": false },
                     { "data": "Policy_Name", "name": "Policy_Name", "width": "8%", "orderable": true },
                     { "data": "Policy_Description", "width": "15%", "orderable": false },
                     {
                         render: function (data, type, full) {
                             var res = '<a href="#" class="editListBtn" onclick="editOpen(' + full.Policy_ID + ')" style="border-radius: 4px;   padding: 5px 8px 5px 8px;"><i  class="fa fa-pencil"></i></a>';

                             var deleteBtn = '<a href="#" class="delListBtn" ' + 'onclick="cancelPolicy(' + full.Policy_ID + ')" ' + 'style="border-radius: 4px; margin-left: 4px; color: white; background-color: red; padding: 5px 8px;">' + '<i class="fa fa-trash"></i></a>';



                             var result;
                             result = res + deleteBtn;
                             return result;
                         }, "width": "8%", "orderable": false
                     }
                 ],
                 "initComplete": function (settings, json) {
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
                     } else {
                         console.log("Length dropdown, label, or container not found");
                     }
                 }


             });
         }

         function cancelPolicy(policyId) {
             Swal.fire({
                 title: 'Are you sure?',
                 text: 'Do you want to delete this policy?',
                 icon: 'warning',
                 showCancelButton: true,
                 confirmButtonText: 'Yes, delete it!',
                 cancelButtonText: 'Cancel',
                 customClass: {
                     popup: 'swal-big-popup',
                     title: 'swal-big-title',
                     htmlContainer: 'swal-big-text'
                 }
             }).then((result) => {
                 if (result.isConfirmed) {
                     $.ajax({
                         type: "POST",
                         url: "Define_Policy_View.aspx/CancelPolicy",
                         data: JSON.stringify({ policyId: policyId }),
                         contentType: "application/json; charset=utf-8",
                         dataType: "json",
                         success: function () {
                             Swal.fire({
                                 icon: 'success',
                                 title: 'Deleted!',
                                 text: 'The policy has been canceled.',
                                 showConfirmButton: false,
                                 timer: 2500,
                                 customClass: {
                                     popup: 'swal-big-popup',
                                     title: 'swal-big-title',
                                     htmlContainer: 'swal-big-text'
                                 }
                             });
                             $('#example').DataTable().ajax.reload();
                         },
                         error: function (xhr, status, error) {
                             Swal.fire({
                                 icon: 'error',
                                 title: 'Error!',
                                 text: 'Failed to delete policy: ' + xhr.responseText,
                                 showConfirmButton: false,
                                 timer: 2000,
                                 customClass: {
                                     popup: 'swal-big-popup',
                                     title: 'swal-big-title',
                                     htmlContainer: 'swal-big-text'
                                 }
                             });
                         }
                     });
                 }
             });
         }






         function editOpen(id) {
             window.open("Define_Policy.aspx?Policy_ID=" + id);
         }

     </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
    <div class="table-container col-lg-12 col-md-12 col-sm-12">
        <table id="example" class="table table-striped table-bordered display">
            <thead>
                <tr>
                    <th style="display: none; width: 0%;">Policy ID</th>
                    <th>Policy Name</th>
                    <th>Description</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody id="tblbody">
            </tbody>
        </table>
    </div>
</div>

</asp:Content>
