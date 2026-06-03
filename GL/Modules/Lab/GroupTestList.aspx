<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="GroupTestList.aspx.cs" Inherits="PMS.GroupTestList" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />
         <script type="text/javascript">
             $(document).ready(function () {
                 LoadPage();
             });
             function PrintTest(id) {
                 window.open('ReportViewer.aspx?ReportName=TestDefination&ReportTitle= Test Defination&Test_IDs=' + id);
             }
             

             function LoadPage() {
                 let savedVisibility = null;

                 $.ajax({
                     type: "POST",
                     url: "GroupTestList.aspx/GetUserColumnPreferences",
                     contentType: "application/json; charset=utf-8",
                     dataType: "json",
                     async: false,
                     success: function (response) {
                         if (response.d && response.d !== "") {
                             try {
                                 savedVisibility = JSON.parse(response.d);
                             } catch (e) {
                                 console.warn("Invalid column visibility JSON");
                             }
                         }
                     },
                     error: function () {
                         console.error("Failed to load column preferences");
                     }
                 });
                 $('#Data').DataTable({
                     "processing": true,
                     "serverSide": true,
                     "dom": 'lBfrtip',
                     "lengthChange": true,
                     buttons: [
                         {
                             text: 'Add',
                             className: 'dt-button buttons-copy buttons-html5',
                             action: function () {
                                 window.location = 'GroupTestDefinition.aspx';
                             }
                         },
                         'copy',
                         'excel',
                         'pdf',
                         {
                             extend: 'colvis',
                             text: '<i class="fa fa-columns"></i> Columns',
                             className: 'dt-button buttons-colvis',
                             collectionLayout: 'fixed two-column',
                             postfixButtons: ['colvisRestore']
                         }
                     ],
                     "filter": true,
                     "ajax": function (data, callback, settings) {
                         $.ajax({
                             type: "POST",
                             url: "GroupTestList.aspx/ViewList",
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
                         { "data": "DataValue_ID", "name": "DataValue_ID", visible: false, "width": "0%" },
                         {
                             "data": null,
                             "width": "10%", "orderable": false,
                             render: function (data, type, row, meta) {
                                 return meta.row + meta.settings._iDisplayStart + 1;
                             }
                         },
                         { "data": "DataValue_Description", "name": "DataValue_Description", "orderable": true },                        
                         {
                             render: function (data, type, full) {
                                 debugger;
                                 var res = '<a href="GroupTestDefinition.aspx?DataValue_ID=' + full.DataValue_ID + '&DataValue_Description=' + full.DataValue_Description + '&Segment2=' + full.Segment2 + '&Segment3=' + full.Segment3 + '&Segment4=' + full.Segment4 + '&Division=' + full.Division + '&Fixed_Value=' + full.Fixed_Value + '&Result_Value=' + full.Result_Value +
                                     '&List_Value=' + full.List_Value + '&Required_Value=' + full.Required_Value + '&chkPayment=' + full.Segment5 + '&Group_Depart=' + full.Group_Depart + '&Special_Test=' + full.Special_Test + '" style="border-radius: 4px; margin-right: 4px;padding: 5px 8px;" class="editListBtn"><i class="fa fa-pencil"></i></a>';

                                 var print = '<a class="printListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="PrintTest(' + full.Test_ID + ')" id="btnprint"><i class="fa fa-print"></i></a>';
                                 var result;
                                 result = res + print;
                                 return result;
                             }, "width": "10%", "orderable": false
                         }
                     ],
                     "initComplete": function (settings, json) {
                         const api = this.api();
                         if (savedVisibility && Array.isArray(savedVisibility)) {
                             if (savedVisibility.length === api.columns().count()) {
                                 api.columns().every(function (index) {
                                     this.visible(savedVisibility[index]);
                                 });
                             }
                         }
                         api.on('column-visibility.dt', function (e, settings, column, state) {
                             let currentVis = [];
                             api.columns().every(function () {
                                 currentVis.push(this.visible());
                             });
                             PageMethods.SaveUserColumnPreferences(
                                 JSON.stringify(currentVis),
                                 function () {
                                     console.log("Column preferences saved");
                                 },
                                 function (error) {
                                     console.error("Failed to save preferences:", error);
                                 }
                             );
                         });

                         var lengthContainer = document.querySelector('#Data_length');
                         var lengthDropdown = document.querySelector('#Data_length select');
                         var label = document.querySelector('#Data_length label');

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

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server"> 
    <div id="MainDiv">
         
    <table class="table table-hover table-striped table-bordered" id="Data" >
      <thead>
        <tr>
            <th>ID</th>
            <th>Sr #</th>
            <th>Group Test Name</th>
            <th>Actions</th>
        </tr>
             </thead>
    </table>
    </div>
</asp:Content>
