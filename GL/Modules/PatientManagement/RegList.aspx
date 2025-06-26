<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="RegList.aspx.cs" Inherits="PMS.RegList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/Pakred/css/tablestyle.css" rel="stylesheet" />


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
                "buttons": [
                    {
                        text: 'Add',
                        className: 'dt-button buttons-copy buttons-html5',
                        action: function () {
                            window.location = 'RegisterPatient.aspx';
                        }
                    },
                    'copy', 'excel', 'pdf',
                ],
                "filter": true,
                "order": [[1, "asc"]], 
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "RegList.aspx/ViewList",
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
                    { "data": "pat_id", "visible": false, "width": "0%", "orderable": false }, 
                    { "data": "MRNO", "name": "MRNO", "width": "8%", "orderable": true }, 
                    { "data": "Full_Name", "width": "15%", "orderable": false },
                    { "data": "Age_years", "name": "Age_years", "width": "8%", "orderable": true }, 
                    { "data": "NIC", "width": "15%", "orderable": false }, 
                    { "data": "Mobile1", "width": "10%", "orderable": false }, 
                    { "data": "Permanent_Address", "width": "30%", "orderable": false }, 
                    {
                        render: function (data, type, full) {
                            var res = '<a href="#" class="editListBtn" onclick="editOpen(' + full.pat_id + ')" style="border-radius: 4px;  color: white; padding: 5px 8px 5px 8px;"><i style="color:white !important;" class="fa fa-pencil"></i></a>';
                            return res;
                        }, "width": "4%", "orderable": false 
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
            window.open("RegisterPatient.aspx?Reg_id=" + id + "");
        }
    </script>
</asp:Content>
<%--kk--%>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
        <div class="col-lg-1 col-md-2 col-sm-3">
            <input type="button" class="btn-primry mrg" onclick="window.location ='RegisterPatient.aspx'" value="Add New" />
        </div>
    </div>
    <br />
    <div class="row">
        <div class="table-container col-lg-12 col-md-12 col-sm-12">
            <table id="example" class="table table-striped table-bordered display">
                <thead>
                    <tr>
                        <th style="display: none; width: 0%;">Pat ID</th>
                        <th>MR No.</th>
                        <th>Name</th>
                        <th>Age</th>
                        <th>CNIC</th>
                        <th>Phone Number</th>
                        <th>Address</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody id="tblbody">
                </tbody>
            </table>
        </div>
    </div>
</asp:Content>
