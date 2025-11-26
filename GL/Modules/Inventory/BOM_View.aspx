<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="BOM_View.aspx.cs" Inherits="PMS.Modules.Inventory.BOM_View" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/Tibbit_theme/css/tablestyle.css" rel="stylesheet" />
       <script type="text/javascript">

       $(document).ready(function () {
           LoadPage();
       });
       function PrintTest(id) {
           window.open('ReportViewer.aspx?ReportName=TestDefination&ReportTitle= Test Defination&Test_IDs=' + id);
       }
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
                   { "data": "Category", "name": "Category", "orderable": true,"width": "5%" },
                   { "data": "TotalCost", "name": "TotalCost", "orderable": false, "width": "18%" },
                   { "data": "itemName", "name": "itemName", "orderable": true, "width": "5%" },
                   { "data": "Qty", "name": "Qty", "orderable": false, "width": "5%" },
                   { "data": "Unit", "name": "Unit", "orderable": false, "width": "7%" },
                   { "data": "Total", "name": "Total", "orderable": false, "width": "12%" },            
                   {
                       "render": function (data, type, full) {
                           var res = '<a class="editListBtn" href="#" onclick="Edit(' + full.BOMID + ')" style="border-radius: 4px;margin-right: 4px; padding: 5px 8px 5px 8px;"><i class="fa fa-pencil"></i></a>';

                           
                           var result;
                           result = res;
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
       
       
       </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="table-container">
    <table id="example" class="table table-hover table-bordered">
        <thead>
            <tr style="position: sticky; top: 0px; z-index: 10;">
                <th>BOMID</th>                                       
                <th>Category</th>
                <th>Total Cost</th>
                <th>item Name</th>
                <th>Qty</th>
                <th>Unit</th>
                <th>Total</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody id="tblbody"></tbody>
    </table>
</div>

</asp:Content>
