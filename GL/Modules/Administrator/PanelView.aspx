<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="PanelView.aspx.cs" Inherits="PMS.PanelView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/StandardTheme/css/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">
        $(document).ready(function () {
            LoadPage();

        });
        function Edit(panel_id) {
            window.location.href = "panelagreement.aspx?ID=" + panel_id;
        }

        function Delete(anchorTag) {
            var panel_id = $(anchorTag).attr("data-id"); 
            $.ajax({
                type: "POST",
                url: "PanelView.aspx/Delete",
                data: JSON.stringify({ "panel_id": panel_id }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
                    if (response.d == "success") {
                        alert("Record has been deleted successfully");
                        window.location.href = "PanelView.aspx";
                    } else {
                        alert("Error deleting the record: " + response.d); 
                    }
                },
                error: function (xhr, status, error) {
                    alert("An error occurred while processing the request: " + error);
                }
            });
        }

        
        function LoadPage() {
            $('#tblPanel').DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": ['copy', 'excel', 'pdf'],
                "filter": true,
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "PanelView.aspx/ViewList",
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
                    { "data": "Panel_ID", "name": "Panel_ID", "visible": false, "width": "0%" },
                    { "data": "Company_Name", "orderable": false },
                    { "data": "No_Of_Employees", "name": "No_Of_Employees", "orderable": true },
                    { "data": "Email", "orderable": false },
                    { "data": "Contact_No", "orderable": false },
                    { "data": "Address", "orderable": false },
                    { "data": "Discount", "orderable": false },
                    {
                        render: function (data, type, full) {
                            debugger;
                            var res = '<a href="#" class="editListBtn"  onclick="Edit(\'' + full.Panel_ID + '\')" style="border-radius: 4px; margin-right: 4px; color: white; padding: 5px 8px;"><i style="color:white !important;" class="fa fa-pencil"></i></a>';
                            var Delete = '<a style="border-radius: 4px; background-color: #ad170c; margin-left: 4px; color: white; padding: 5px 8px;" href="#" data-id="' + full.Panel_ID + '" onclick="Delete(this)"><i class="fa fa-trash" style="color:white !important;"></i></a>';

                            var result;
                            result = res + Delete;
                            return result;
                        }, "width": "10%", "orderable": false
                    }

                ],
                "initComplete": function (settings, json) {
                    var lengthDropdown = document.querySelector('#tblPanel_length select');
                    var label = document.querySelector('#tblPanel_length label');
                    if (lengthDropdown && label) {
                        label.innerHTML = 'Show entries ';
                        label.appendChild(lengthDropdown);
                    } else {
                        console.log("Length dropdown or label not found");
                    }
                }
            });
        }

    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
   
   <div class="table-container">
       <table id="tblPanel" class="table table-hover table-bordered">
           <thead>
               <tr>
                   <th>Panel_ID</th>
                   <th>Customer Name</th>
                   <th>Employee #</th>
                   <th>Email</th>
                   <th>Contact No</th>
                   <th>Address</th>
                   <th>Discount</th>
                   <th>Action</th>
               </tr>
           </thead>
           <tbody></tbody>
       </table>
</div>
          
</asp:Content>
