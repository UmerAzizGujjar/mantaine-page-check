<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Emergency_Admission_View.aspx.cs" Inherits="PMS.Modules.PatientManagement.Emergency_Admission_View" %>
 
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
     <script src="../../wwwroot/THEME_TIBBIT/CustomJs/OPDView.js" type="text/javascript"></script>
 <link href="../../wwwroot/THEME_TIBBIT/css/tablestyle.css" rel="stylesheet" />
 <script type="text/javascript">
     $(document).ready(function () {
         $('#ctl00_lblMessage').hide();
         LoadPage();


     });
   

    
     function editOpen(id) {
         PageMethods.EditPatient(id, function (msg) {
             if (msg === "NotAllowed") {
                 Swal.fire({
                     icon: 'error',
                     title: 'Access Denied',
                     text: 'You do not have permission to edit this admission.'
                 });
             } else if (msg === "Allowed") {
                 window.location = "EmergencyAdmission.aspx?Emergency_ID=" + id;
             }
         });
     }
     function LoadPage() {
         const table = $("#tblResult").DataTable({
             "processing": true,
             "serverSide": true,
             "dom": 'lBfrtip',
             "lengthChange": true,
             "buttons": [
                 {
                     text: 'Add',
                     className: 'dt-button buttons-copy buttons-html5',
                     action: function () {
                         window.location = 'EmergencyAdmission.aspx';
                     }
                 },
                 'copy',
                 'excel',
                 'pdf'
             ],
             "filter": true,
             "ajax": function (data, callback, settings) {
                 $.ajax({
                     type: "POST",
                     url: "Emergency_Admission_View.aspx/ViewList",
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
                 { "data": null, "width": "4%", "orderable": false, "render": (data, type, full, meta) => meta.settings._iDisplayStart + meta.row + 1 },
                 { "data": "Emergency_ID", "name": "Emergency_ID", "visible": false, "width": "0%", "orderable": false },
                 { "data": "Emergency_No", "name": "Emergency_No", "width": "10%", "orderable": true },
                 { "data": "mr_no_sequence", "name": "mr_no_sequence", "width": "12%", "orderable": true },
                 { "data": "Full_Name", "name": "Full_Name", "width": "18%", "orderable": true },
                 {
                     "data": "Admission_Date", "name": "Admission_Date",
                     "render": (data) => data ? moment(data).format('DD-MMM-YYYY') : '',
                     "width": "10%"
                 },
                 { "data": "Admit_To", "name": "Admit_To", "width": "12%", "orderable": true },
                 { "data": "Ward_Name", "name": "Ward_Name", "width": "14%", "orderable": true },
                 { "data": "Bed_No", "name": "Bed_No", "width": "8%", "orderable": true },
                 {
                     "render": (data, type, full) => {
                         return `<a href="#" onclick="editOpen(${full.Emergency_ID})" class="editListBtn" style="border-radius: 4px;padding: 5px 8px;"><i class="fa fa-pencil"></i></a>`;
                     },
                     "width": "12%",
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
                 }
             }
         });
     }
 </script>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
     <div id="POdetails" style="margin-top: 15px;">
         <div class="row">
             <div class="table-container col-lg-12 col-md-12 col-sm-10">
                 <table class="table table-hover table-striped table-bordered" id="tblResult" style="overflow: scroll; height: auto;">
               <thead id="ihead">
                 <tr>
                     <th style="width:4% !important;">Sr#</th>                
                     <th style="display: none;">Emergency ID</th>
                     <th style="width: 10%;">Emergency No.</th>
                     <th style="width: 12%;">MR No.</th>
                     <th style="width: 18%;">Name</th>
                     <th style="width: 10%;">Adm Date</th>
                     <th style="width: 12%;">Admit To</th>
                     <th style="width: 14%;">Ward Name</th>
                     <th style="width: 8%;">Bed No</th>
                     <th style="width: 12% !important;">Actions</th>
                 </tr>
             </thead>
                     <tbody id="ibody">
                     </tbody>
                 </table>
             </div>
         </div>
 </div>
</asp:Content>
