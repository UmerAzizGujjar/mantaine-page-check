<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Doctor_Packages_List.aspx.cs" Inherits="PMS.Modules.Inventory.Doctor_Packages_List" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

<link href="../../wwwroot/Tibbit_theme/css/tablestyle.css" rel="stylesheet" />
<script type="text/javascript">
    $(document).ready(function () {
        debugger;
        $('#ctl00_lblMessage').hide();
        LoadPage();
    });
    function LoadPage() {
        $("#example").DataTable({
            "processing": true,
            "serverSide": true,
            "dom": 'lBfrtip',
            "lengthChange": true,
            "buttons": ['copy', 'excel', 'pdf'],
            "filter": true,
            "ajax": function (data, callback, settings) {
                $.ajax({
                    type: "POST",
                    url: "Doctor_Packages_List.aspx/ViewList",
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
                { "data": "Package_ID", "name": "Package_ID", "orderable": true },
                { "data": "Package_name", "name": "Package_name", "orderable": false },
                { "data": "Doctorname", "name": "Doctorname", "orderable": true },
                { "data": "Department", "name": "Department", "orderable": false },
                { "data": "Duration", "orderable": false },
                { "data": "Remarks", "orderable": false },                
                {
                    render: function (data, type, full) {
                        debugger;
                        var res = '<a href="#" onclick="editOpen(' + full.Package_ID + ')" class="editListBtn" style="border-radius: 4px;  color: white; padding: 5px 8px 5px 8px;"><i style="color:white !important;" class="fa fa-pencil"></i></a>'
                        var result;
                        result = res;
                        return result;
                    }, "orderable": false
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
    function editOpen(id) {
        window.open("AddDoctor_Packages.aspx?Doc_Package_id=" + id + "");
    }
</script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="row">
        <div class="col-lg-1 col-md-2 col-sm-3">
            <input type="button" class="btn-primry mrg" onclick="window.location ='AddDoctor_Packages.aspx'" value="Add New" />
        </div>
    </div>
<br />
     <div class="table-container">
            <table id="example" class="table table-hover table-bordered" style="width:100% !important">
                <thead>
                    <tr>
                        <th>Package Id</th>
                        <th>Package Name</th>
                        <th>Doctor Name</th>
                        <th>Department</th>
                        <th>Duration</th>
                        <th>Remarks</th>
                        <th>Action</th>                          
                    </tr>
                </thead>
                <tbody id="tblbody">
                </tbody>
            </table>
    </div>
</asp:Content>
