<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="BOM_View.aspx.cs" Inherits="PMS.Modules.Inventory.BOM_View" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />
       <script type="text/javascript">

       $(document).ready(function () {
           LoadPage();
       });
       
       function Edit(ID) {
        window.location.href = "BOM.aspx?ID=" + ID;
       }
       function deleteConfirm(ID) {
           debugger;
           var itemID = ID;
           if (confirm('Are you sure want to delete this record')) {
               PageMethods.DeleteRecord(itemID, function (msg) {
                   debugger;
                   location.reload();
               });
           }
       }
       function redirecttonew() {
           window.location.href = "BOM_View.aspx";
       }


       function LoadPage() {
           $("#example").DataTable({
               "processing": true,
               "serverSide": true,
               "dom": 'lBfrtip',
               "lengthChange": true,
               "buttons": [{ text: 'Add', className: 'dt-button buttons-copy buttons-html5', action: function () { window.location = 'BOM.aspx'; } }, 'copy', 'excel', 'pdf'],
               "filter": true,
               "ajax": function (data, callback, settings) {
                   $.ajax({
                       type: "POST",
                       url: "BOM_View.aspx/ViewList",
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
                   { "data": "BOMID", "visible": false, "width": "0%" },
                   { "data": "ProcedureName", "name": "ProcedureName", "orderable": true,"width": "5%" },
                   { "data": "Category", "name": "Category", "orderable": false, "width": "18%" },                             
                   { "data": "TotalCost", "name": "TotalCost", "orderable": false, "width": "18%" },                             
                   {
                       "render": function (data, type, full) {
                           var res = '<a class="editListBtn" href="#" onclick="Edit(' + full.BOMID + ')" style="border-radius: 4px;margin-right: 4px; padding: 5px 8px 5px 8px;"><i class="fa fa-pencil"></i></a>';

                           var cancelBtn = '<a href="#" class="delListBtn" ' + 'onclick="cancelBOM(' + full.BOMID + ')" ' +
                               'style="border-radius: 4px; margin-left: 4px; color: white; background-color: red; padding: 5px 8px; text-decoration: none;">' +
                               '<i class="fa fa-trash"></i></a>';
                           
                           var result;
                           result = res + cancelBtn;
                           return result;
                       }, "orderable": false, "width": "7%"
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


           function cancelBOM(bomId) {
               Swal.fire({
                   title: 'Are you sure?',
                   text: 'Do you want to cancel this BOM?',
                   icon: 'warning',
                   showCancelButton: true,
                   confirmButtonText: 'Yes, cancel it!',
                   cancelButtonText: 'No, keep it',
                   customClass: {
                       popup: 'swal-big-popup',
                       title: 'swal-big-title',
                       htmlContainer: 'swal-big-text'
                   }
               }).then((result) => {
                   if (result.isConfirmed) {
                       $.ajax({
                           type: "POST",
                           url: "BOM_View.aspx/CancelBOM",  
                           data: JSON.stringify({ bomId: bomId }),
                           contentType: "application/json; charset=utf-8",
                           dataType: "json",
                           success: function (response) {
                               var resultText = response.d;
                               if (resultText && resultText.startsWith("Error")) {
                                   Swal.fire({
                                       icon: 'error',
                                       title: 'Failed!',
                                       text: resultText,
                                       timer: 2500,
                                       customClass: {
                                           popup: 'swal-big-popup',
                                           title: 'swal-big-title',
                                           htmlContainer: 'swal-big-text'
                                       }
                                   });
                               } else {
                                   Swal.fire({
                                       icon: 'success',
                                       title: 'Canceled!',
                                       text: 'The BOM has been canceled.',
                                       timer: 2000,
                                       customClass: {
                                           popup: 'swal-big-popup',
                                           title: 'swal-big-title',
                                           htmlContainer: 'swal-big-text'
                                       }
                                   });
                                   $('#example').DataTable().ajax.reload(); // Refresh table
                               }
                           },
                           error: function (xhr, status, error) {
                               Swal.fire({
                                   icon: 'error',
                                   title: 'Error!',
                                   text: 'AJAX call failed. Check console.',
                                   timer: 2000
                               });
                               console.error("Cancel BOM error:", error, xhr.responseText);
                           }
                       });
                   }
               });
           }
       
       </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="table-container">
    <table id="example" class="table table-hover table-bordered">
        <thead>
            <tr style="position: sticky; top: 0px; z-index: 10;">
                <th>BOMID</th>                                       
                <th>ProcedureName</th>
                <th>Category</th>
                <th>Total Cost</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody id="tblbody"></tbody>
    </table>
</div>

</asp:Content>
