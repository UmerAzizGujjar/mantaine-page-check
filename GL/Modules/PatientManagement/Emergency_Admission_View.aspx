<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Emergency_Admission_View.aspx.cs" Inherits="PMS.Modules.PatientManagement.Emergency_Admission_View" %>
 
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
     <script src="../../wwwroot/THEME_TIBBIT/CustomJs/OPDView.js?v=<%= System.IO.File.GetLastWriteTimeUtc(Server.MapPath("~/wwwroot/THEME_TIBBIT/CustomJs/OPDView.js")).Ticks %>" type="text/javascript"></script>
 <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />
 <style type="text/css">
     .opd-date-filter { display: flex; flex-wrap: wrap; align-items: center; gap: 10px 14px; margin-bottom: 10px; }
     .opd-date-filter label.fl { margin: 0; font-weight: 600; }
     .opd-date-filter input[type=date] { width: 160px; display: inline-block; }
     .opd-switch { position: relative; display: inline-block; width: 44px; height: 24px; margin: 0; }
     .opd-switch input { opacity: 0; width: 0; height: 0; }
     .opd-slider { position: absolute; cursor: pointer; inset: 0; background: #ccc; border-radius: 24px; transition: .2s; }
     .opd-slider:before { content: ""; position: absolute; height: 18px; width: 18px; left: 3px; top: 3px; background: #fff; border-radius: 50%; transition: .2s; }
     .opd-switch input:checked + .opd-slider { background: #2e7d32; }
     .opd-switch input:checked + .opd-slider:before { transform: translateX(20px); }
 </style>
 <script type="text/javascript">
     $(document).ready(function () {
         $('#ctl00_lblMessage').hide();
         initDateFilter();   // default: current month, filter ON
         LoadPage();


     });
   

    
     /* ---------- Start / End date filter (default = current month) ---------- */
     function pad2(n) { return n < 10 ? '0' + n : '' + n; }
     function fmtYMD(d) { return d.getFullYear() + '-' + pad2(d.getMonth() + 1) + '-' + pad2(d.getDate()); }

     function setCurrentMonthDates() {
         var now = new Date();
         $('#txtFromDate').val(fmtYMD(new Date(now.getFullYear(), now.getMonth(), 1)));
         $('#txtToDate').val(fmtYMD(new Date(now.getFullYear(), now.getMonth() + 1, 0)));
     }

     function reloadList() {
         if ($.fn.DataTable.isDataTable('#tblResult')) {
             $('#tblResult').DataTable().ajax.reload();
         }
     }

     function initDateFilter() {
         setCurrentMonthDates();
         $('#chkDateFilter').prop('checked', true);
         $('#lblDateFilterState').text('Current month');

         // Toggle: ON = date filter (current month), OFF = clear dates and show all data
         $('#chkDateFilter').on('change', function () {
             if (this.checked) {
                 setCurrentMonthDates();
                 $('#txtFromDate, #txtToDate').prop('disabled', false);
                 $('#lblDateFilterState').text('Current month');
             } else {
                 $('#txtFromDate, #txtToDate').val('').prop('disabled', true);
                 $('#lblDateFilterState').text('All data');
             }
             reloadList();
         });

         $('#txtFromDate, #txtToDate').on('change', function () {
             var f = $('#txtFromDate').val(), t = $('#txtToDate').val();
             if (f && t && f > t) {
                 Swal.fire({ icon: 'warning', title: 'Invalid Date Range', text: 'Start date cannot be after end date.' });
                 return;
             }
             $('#lblDateFilterState').text('Custom range');
             reloadList();
         });
     }

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
                         searchValue: data.search.value,
                         fromDate: $('#txtFromDate').val() || '',
                         toDate: $('#txtToDate').val() || ''
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
     <div class="row">
         <div class="col-lg-12 col-md-12 col-sm-12 opd-date-filter">
             <label class="fl" for="txtFromDate">Start Date</label>
             <input type="date" id="txtFromDate" class="form-control" />
             <label class="fl" for="txtToDate">End Date</label>
             <input type="date" id="txtToDate" class="form-control" />
             <label class="fl" for="chkDateFilter">Date Filter</label>
             <label class="opd-switch" title="Off = clear dates and show all data">
                 <input type="checkbox" id="chkDateFilter" checked="checked" />
                 <span class="opd-slider"></span>
             </label>
             <span id="lblDateFilterState" class="text-muted">Current month</span>
         </div>
     </div>
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
