<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="WardDefinitionView.aspx.cs" Inherits="PMS.WardDefinitionView" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/IITH_Theme/css/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">

        $(document).ready(function () {
            debugger;
            $('#ctl00_lblMessage').hide();
            LoadPage();


        });

        function LoadPage() {
            $('#example').DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": ['copy', 'excel', 'pdf'],
                "filter": true,
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "WardDefinitionView.aspx/ViewList",
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
                    { "data": "Ward_ID", visible: false },
                    { "data": "Ward_No", "name": "Ward_No", "orderable": true },
                    { "data": "Ward_Type", "orderable": false },
                    { "data": "Department", "orderable": false },
                    { "data": "No_Of_Beds", "orderable": false }, 
                    {
                        render: function (data, type, full) {
                            debugger;
                            var res = '<a class="editListBtn" href="#" onclick="Edit(' + full.Ward_ID + ')" style="border-radius: 4px;margin-right: 4px; color: white; padding: 5px 8px 5px 8px;"><i style="color:white !important;" class="fa fa-pencil"></i></a>'
                                ;

                            var result;
                            result = res;
                            return result;
                        }, "width": "10%", "orderable": false
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
        debugger;

        function Edit(ID) {
            debugger;
            window.location.href = "WardDefinition.aspx?ID=" + ID;

        }
        function redirecttonew() {
            window.location.href = "WardDefinition.aspx";
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <input type="button" onclick="redirecttonew()" class="btn-primry" value="Add New"  />  
    <br />
    <br />
    <div class="table-container">        
                <table id="example" class="table table-hover table-bordered">
                    <thead>
                        <tr>
                            <th>Ward ID</th>
                            <th>Ward No</th>
                            <th>Ward Type</th>
                            <th>Department</th>
                            <th>No of Beds</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody id="tblbody"></tbody>
                </table>    
                 </div>
</asp:Content>