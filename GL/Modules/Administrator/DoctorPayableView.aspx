<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="DoctorPayableView.aspx.cs" Inherits="PMS.Modules.Administrator.DoctorPayableView" %>
 
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
       <link href="../../wwwroot/lib/sweetalert/tablestyle.css" rel="stylesheet" />
   <script type="text/javascript">
        
       function LoadPage() {
           var Packagetype = $("#ddlPackageType").val();

           $("#example").DataTable({
               "processing": true,
               "serverSide": true,
               "destroy": true,
               "dom": 'lBfrtip',
               "lengthChange": true,
               "buttons": ['copy', 'excel', 'pdf'],
               "filter": true,
               "ajax": function (data, callback, settings) {
                   $.ajax({
                       type: "POST",
                       url: "DoctorPayableView.aspx/ViewList",
                       data: JSON.stringify({
                           draw: data.draw,
                           start: data.start,
                           length: data.length,
                           sortColumn: data.columns[data.order[0].column].data,
                           sortColumnDirection: data.order[0].dir,
                           searchValue: data.search.value,
                           startDate: $("#StartDate").val(),
                           endDate: $("#EndDate").val(),
                           packageType: Packagetype
                       }),
                       contentType: "application/json; charset=utf-8",
                       dataType: "json",
                       success: function (response) {
                           if (response.d.error) {
                               console.error("Error:", response.d.error);
                               alert("Error loading data: " + response.d.error);
                               callback({
                                   draw: data.draw,
                                   recordsTotal: 0,
                                   recordsFiltered: 0,
                                   data: []
                               });
                           } else {
                               callback({
                                   draw: response.d.draw,
                                   recordsTotal: response.d.recordsTotal,
                                   recordsFiltered: response.d.recordsFiltered,
                                   data: response.d.data
                               });
                           }
                       },
                       error: function (xhr, status, error) {
                           console.log("AJAX Error:", xhr.responseText);
                           alert("Error loading data. Please check console for details.");
                           callback({
                               draw: data.draw,
                               recordsTotal: 0,
                               recordsFiltered: 0,
                               data: []
                           });
                       }
                   });
               },
               "columns": [
                   { "data": "Bill_Id", "name": "Bill_Id", "orderable": true, "title": "Bill ID" },
                   { "data": "DoctorName", "name": "DoctorName", "orderable": true, "title": "Doctor Name" },
                   { "data": "Package_Name_ID", "name": "Package_Name_ID", "orderable": true, "title": "Package Name" },
                   {
                       "data": "Total_Bill_Amount", "name": "Total_Bill_Amount", "orderable": true, "title": "Total Bill Amount",
                       "render": function (data) { return formatCurrency(data); }
                   },
                   {
                       "data": "Total_Expense", "name": "Total_Expense", "orderable": true, "title": "Total Expense",
                       "render": function (data) { return formatCurrency(data); }
                   },
                   {
                       "data": "After_Expense_Amount", "name": "After_Expense_Amount", "orderable": true, "title": "After Expense Amount",
                       "render": function (data) { return formatCurrency(data); }
                   },
                   {
                       "data": "Doctor_Share", "name": "Doctor_Share", "orderable": true, "title": "Doctor Share",
                       "render": function (data) { return formatCurrency(data); }
                   },
                   {
                       "data": "Hospital_Share", "name": "Hospital_Share", "orderable": true, "title": "Hospital Share",
                       "render": function (data) { return formatCurrency(data); }
                   },
                   {
                       "data": "Amount_Assign_To_Doctor", "name": "Amount_Assign_To_Doctor", "orderable": true, "title": "Amount Assign To Doctor",
                       "render": function (data) { return formatCurrency(data); }
                   }
               ],
               "order": [[0, 'desc']],
               "initComplete": function (settings, json) {
                   // Customize the length menu
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
                   }
               }
           });
       }

       // Helper function to format currency
       function formatCurrency(value) {
           if (value === null || value === undefined) return '-';
           return 'Rs' + parseFloat(value).toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,');
       }

       // Call LoadPage when document is ready
       $(document).ready(function () {
           LoadPage();

           // Add event listeners for filters
           $("#StartDate, #EndDate, #ddlPackageType").change(function () {
               $("#example").DataTable().ajax.reload();
           });
       });
   </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row mb-3">
    <div class="col-md-2">
        <label>Start Date:</label>
        <input type="date" id="StartDate" class="form-control" />
    </div>
    <div class="col-md-2">
        <label>End Date:</label>
        <input type="date" id="EndDate" class="form-control" />
    </div>
    <div style="display:none" class="col-md-3">
        <label>Package Type:</label>
        <select id="ddlPackageType" class="form-control">
            <option value="">All</option>
            <!-- Add your package type options here -->
        </select>
    </div>
     
</div>

<table id="example" class="table table-hover table-bordered" style="width:100% !important">
    <thead>
        <tr>
            <th>Bill ID</th>
            <th>Doctor Name</th>
            <th>Package Name</th>
            <th>Total Bill Amount</th>
            <th>Total Expense</th>
            <th>After Expense Amount</th>
            <th>Doctor Share</th>
            <th>Hospital Share</th>
            <th>Amount Assign To Doctor</th>
        </tr>
    </thead>
</table>
</asp:Content>
