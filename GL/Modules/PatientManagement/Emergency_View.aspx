<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Emergency_View.aspx.cs" Inherits="PMS.Modules.PatientManagement.Emergency_View" %>
 
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
 <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />
 <script type="text/javascript">
     $(document).ready(function () {
         debugger;
         $('#ctl00_lblMessage').hide();
         LoadPage();


     });
   

    
     function editOpen(id) {
         Swal.fire({
             title: 'Are you sure?',
             text: `You are about to edit emergency patient`,
             icon: 'warning',
             showCancelButton: true,
             confirmButtonText: 'Yes, edit it!',
             cancelButtonText: 'Cancel',
             reverseButtons: true
         }).then((result) => {
             if (result.isConfirmed) {
                 PageMethods.EditPatient(id, function (msg) {
                     if (msg === "NotAllowed") {
                         Swal.fire({
                             icon: 'error',
                             title: 'Access Denied',
                             text: 'You do not have permission to edit this patient.'
                         });
                     } else if (msg === "Allowed") {
                         window.open("EmergencyForm.aspx?EMERID=" + id, "_blank");
                     }
                 });
             }
         });
     }
     function cancelPatient(emerid, patname) {
         debugger;
         var EmerID = emerid;
         var PatName = patname;

         Swal.fire({
             title: 'Are you sure?',
             text: 'Are you sure want to Cancel:- ' + PatName,
             icon: 'warning',
             showCancelButton: true,
             confirmButtonText: 'Yes, cancel it!',
             cancelButtonText: 'No, keep it',
             reverseButtons: true
         }).then((result) => {
             if (result.isConfirmed) {
                 PageMethods.CancelPatient(EmerID, function (msg) {
                     if (msg == "Allowdlt") {
                         Swal.fire({
                             icon: 'error',
                             title: 'Permission Denied',
                             text: 'You have no right to Cancel.'
                         });
                     }
                     else if (msg == "success") {
                         if (typeof row !== 'undefined' && row && typeof row.remove === 'function') {
                             row.remove();
                         }
                         window.location.href = "Emergency_View.aspx";
                     }
                     else {
                         Swal.fire({
                             icon: 'warning',
                             title: 'Cancel Failed',
                             text: 'Unable to Cancel this patient, because this patient has uncanceled Reciept and Bills'
                         });
                     }
                 });
             }
         });

        
     }
     function Print(Emer_id) {
         debugger;
         var url = '../../ReportViewer.aspx?ReportName=Emergency_Patient_Print&Title=Emergency Print&Emergency_Id=' + Emer_id;
         window.open(url, '_blank');

     }
     function PrintLTR(Emer_id) {
         debugger;
         var url = '../../ReportViewer.aspx?ReportName=Emergency_Patient_Print_LTR&Title=Emergency Print&Emergency_Id=' + Emer_id;
         window.open(url, '_blank');

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
                         window.location = 'EmergencyForm.aspx';
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
                     url: "Emergency_View.aspx/ViewList",
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
                  { "data": "Emer_id", "name": "Emer_id", "visible": false, "width": "0%", "orderable": false },
                  { "data": "isCancel", "visible": false, "orderable": false, "width": "0%" },
                  { "data": "Emergency_No", "name": "Emergency_No", "width": "4%", "orderable": true },
                 { "data": "mr_no_sequence", "name": "mr_no_sequence", "width": "8%", "orderable": true },
           
                 { "data": "Full_Name", "width": "16%", "orderable": false },
                 { 
                     "data": "Amount", 
                     "name": "Amount", 
                     "width": "9%", 
                     "orderable": true,
                     "render": (data, type, full) => data ? parseFloat(data).toFixed(2) : "0.00"
                 },
                 { 
                     "data": "balance_amount", 
                     "name": "balance_amount", 
                     "width": "4%", 
                     "orderable": true,
                     "render": (data, type, full) => data ? parseFloat(data).toFixed(2) : "0.00"
                 },

                 { "data": "Type", "width": "10%", "orderable": false },
                 { "data": "Patient_Type", "width": "6%", "orderable": false },
                 { "data": "NIC", "width": "10%", "orderable": false },
                 { "data": "Mobile1", "width": "10%", "orderable": false },
                 {
                     "data": "Created_Time", "name": "Created_Time",
                     "render": (data, type, full) => moment(full.Created_Time).format('DD-MMM-YYYY'),
                     "width": "10%"
                 },
                  {
                      "render": (data, type, full) => {
                          if (full.isCancel === true) {
                              return '<span style="color:#721c24; font-weight:bold;">Cancelled</span>';
                          }
                          let res = `<a href="#" onclick="editOpen(${full.Emer_id})" class="editListBtn" style="border-radius: 4px;padding: 5px 8px;"><i class="fa fa-pencil"></i></a>`;
                          let Del = `<a class="delListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px;" href="#" onclick="cancelPatient(${full.Emer_id}, '${full.Full_Name.replace(/'/g, "\\'")}')"><i class="fa fa-trash"></i></a>`;
                          let print = `<a class="printListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px;" href="#" onclick="Print(${full.Emer_id})"><i class="fa fa-print"></i></a>`;
                          let btnprint = `<a class="printBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px;" href="#" onclick="PrintLTR(${full.Emer_id})"><i class="fa fa-print"></i></a>`;
                          return res + Del + print + btnprint;
                      },
                      "width": "20%",
                      "orderable": false
                  }
              ],
              "createdRow": function (row, data, dataIndex) {
                  if (data.isCancel === true) {
                      $(row).css('background-color', '#f8d7da');
                      $(row).find('td').css('color', '#721c24');
                  }
              },
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
                      <th style="display: none;">Is Cancel</th>
                           <th style="6%">Emr No.</th>
                     <th style="width: 12%;">MR No.</th>
                
                     <th style="width: 17%;">Name</th>
                     <th style="width: 12%;">Amount</th>
                     <th style="width: 12%;">Balance Amount</th>
                     <th style="width: 12%;">Department</th>
                     <th style="width: 12%;">Patient Type</th>
                     <th style="width: 12%;">CNIC</th>
                     <th style="width: 12%;">Mobile</th>
                     <th style="width: 10%;">Date</th>
                     <th style="width: 18% !important;">Actions</th>
                 </tr>
             </thead>
                     <tbody id="ibody">
                     </tbody>
                 </table>
             </div>
         </div>
 </div>
</asp:Content>
