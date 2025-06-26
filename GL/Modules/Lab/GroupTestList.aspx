<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="GroupTestList.aspx.cs" Inherits="PMS.GroupTestList" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/Pakred/css/tablestyle.css" rel="stylesheet" />
         <script type="text/javascript">
             $(document).ready(function () {
                 LoadPage();
             });

             

             function LoadPage() {
                 $('#Data').DataTable({
                     "processing": true,
                     "serverSide": true,
                     "dom": 'lBfrtip',
                     "lengthChange": true,
                     "buttons": ['copy', 'excel', 'pdf'],
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
                                     '&List_Value=' + full.List_Value + '&Required_Value=' + full.Required_Value + '&chkPayment=' + full.Segment5 + '&Group_Depart=' + full.Group_Depart + '&Special_Test=' + full.Special_Test +  '" style="border-radius: 4px; margin-right: 4px;  color: white; padding: 5px 8px;" class="editListBtn"><i style="color:white !important;" class="fa fa-pencil"></i></a>';
                                 
                                 var result;
                                 result = res;
                                 return result;
                             }, "width": "5%", "orderable": false
                         }
                     ],
                     "initComplete": function (settings, json) {
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
                         } else {
                             console.log("Length dropdown, label, or container not found");
                         }
                     }
                 });
             }

             
         </script>

</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server"> 
    <div id="MainDiv">
         <div class="row">
     <div class="col-lg-2 col-md-4 col-m-6" style="margin-bottom:1%">
         <input type="button" value="Add New" class="btn btn-primry"  onclick=" window.location.href = 'GroupTestDefinition.aspx'"  />
         </div>
             </div>
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
