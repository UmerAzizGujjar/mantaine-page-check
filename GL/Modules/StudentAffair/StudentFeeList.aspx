<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="StudentFeeList.aspx.cs" Inherits="PMS.Modules.StudentAffair.StudentFeeList" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
     <link href="../../wwwroot/Tibbit_theme/css/tablestyle.css" rel="stylesheet" />
 <script type="text/javascript">

     $(document).ready(function () {
         $('#ctl00_lblMessage').hide();
         LoadPage();

     });


     function Edit(ID) {
         debugger;
         window.location.href = "StudentFeeDefinition.aspx?Fee_ID=" + ID;
     }
     function PrintTest(id) {
         window.open('ReportViewer.aspx?ReportName=TestDefination&ReportTitle= Test Defination&Test_IDs=' + id);
     }
     function LoadPage() {
         $("#tbl").DataTable({
             "processing": true,
             "serverSide": true,
             "dom": 'lBfrtip',
             "lengthChange": true,
             "buttons": [{ text: 'Add', className: 'dt-button buttons-copy buttons-html5', action: function () { window.location = 'StudentFeeDefinition.aspx'; } }, 'copy', 'excel', 'pdf'],
             "filter": true,
             "ajax": function (data, callback, settings) {
                 $.ajax({
                     type: "POST",
                     url: "StudentFeeList.aspx/ViewList",
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
                 { "data": "Fee_ID", "visible": false, "width": "0%" },
                 { "data": "Fee_No", "width": "10%", "orderable": true },
                 { "data": "Roll_No", "width": "15%", "orderable": true },
                 { "data": "Student_Name", "name": "Student_Name", "width": "10%", "orderable": false },
                 { "data": "Father_Name", "width": "10%", "orderable": false },
                 { "data": "Total_Amount", "width": "10%", "orderable": false },
                 { "data": "Status", "width": "10%", "orderable": false },
                 { "data": "StudentClass", "width": "10%", "orderable": false },
                 {
                     render: function (data, type, full) {
                         debugger;
                         var res = '<a class="editListBtn" href="#" onclick="Edit(' + full.Fee_ID + ')" style="border-radius: 4px; color: white; padding: 5px 8px 5px 8px;"><i style="color:white !important;" class="fa fa-pencil"></i></a>'

                         var Del = '<a href="#" style="border-radius: 4px; background-color: #ad170c;margin-left: 4px; color: white; padding: 5px 8px;" onclick="cancelFee(' + full.Fee_ID + ')"><i class="fa fa-trash"></i></a>';
                         var print = '<a style="border-radius: 4px;background-color:#387024;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="PrintTest(' + full.Test_ID + ')" id="btnprint"><i class="fa fa-print" style="color:white !important;"></i></a>';
                         var result;
                         result = res + Del + print;
                         return result;
                     }, "width": "10%", "orderable": false
                 }
             ],
             "initComplete": function (settings, json) {
                 var lengthContainer = document.querySelector('#tbl_length');
                 var lengthDropdown = document.querySelector('#tbl_length select');
                 var label = document.querySelector('#tbl_length label');

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


     function cancelFee(FeeId) {
         debugger;
         if (confirm("Are you sure you want to cancel this Fee?")) {
             $.ajax({
                 type: "POST",
                 url: "StudentFeeList.aspx/CancelFee",
                 data: JSON.stringify({ FeeId: FeeId }),
                 contentType: "application/json; charset=utf-8",
                 dataType: "json",
                 success: function (response) {
                     if (response.d) {
                         alert("Fee cancelled successfully!");
                         $('#tbl').DataTable().ajax.reload();
                     } else {
                         alert("Failed to cancel the Fee.");
                     }
                 },
                 error: function (xhr, status, error) {
                     console.log(xhr.responseText);
                 }
             });
         }
     }



 </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
        <div class="row">
    <div class="table-container">
        <table id="tbl" class="table table-bordered table-hover table-striped">
            <thead id="ihead">
                <tr>
                    <th style="display:none;">Fee_ID</th>
                    <th>Fee No</th>
                    <th>Roll_No</th>
                    <th>Student Name</th>
                    <th>Father Name</th>
                    <th>Total Amount</th>
                    <th>Status</th>
                    <th>Student Class</th>
                    <th>View</th>                      
                </tr>
            </thead>
            <tbody id="tbody">
            </tbody>
        </table>
    </div>
</div>
</asp:Content>
