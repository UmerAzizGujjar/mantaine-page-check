<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AssetDepreciationView.aspx.cs" Inherits="PMS.Modules.Administrator.AssetDepreciationView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/css/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">
        $(document).ready(function () {
            debugger;
            $('#ctl00_lblMessage').hide();
            LoadPage();
        });
        function PrintTest(id) {
            window.open('ReportViewer.aspx?ReportName=TestDefination&ReportTitle= Test Defination&Test_IDs=' + id);
        }

        function LoadPage() {
            $("#example").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": [{ text: 'Add', className: 'dt-button buttons-copy buttons-html5', action: function () { window.location = 'AssetDepereciation.aspx'; } }, 'copy', 'excel', 'pdf'],
                "filter": true,
                "order": [[1, "asc"]],
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "AssetDepreciationView.aspx/ViewList",
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
                    { "data": "Asset_Dep_ID", "visible": false, "width": "0%", "orderable": false },
                    { "data": "Asset_description", "name": "Asset_description", "width": "12%", "orderable": false },
                    { "data": "Trans_type", "width": "15%", "orderable": false },
                    { "data": "Dep_Cost", "name": "Dep_Cost", "width": "8%", "orderable": false },
                    { "data": "Depereciation_Amount_charge", "width": "15%", "orderable": false },
                    {
                        "data": "created_time", "name": "created_time",
                        "render": function (data, type, full) {
                            debugger;
                            var date = full.created_time;
                            date = moment(date).format('DD-MMM-YYYY');
                            return date;
                        }, "width": "10%", "orderable": true
                    },
                    {
                        render: function (data, type, full) {
                            var res = '<a href="#" class="editListBtn" onclick="editOpen(' + full.Asset_Dep_ID + ')" style="border-radius: 4px;padding: 5px 8px 5px 8px;"><i class="fa fa-pencil"></i></a>';

                            var print = '<a class="printListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="PrintTest(' + full.Test_ID + ')" id="btnprint"><i class="fa fa-print"></i></a>';
                            var result;
                            result = res  + print;
                            return result;
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
            window.open("AssetDepereciation.aspx?ID=" + id);
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    
    <div class="row">
        <div class="table-container col-lg-12 col-md-12 col-sm-12">
            <table id="example" class="table table-striped table-bordered display">
                <thead>
                    <tr>
                        <th style="display: none; width: 0%;">Pat ID</th>
                        <th>Asset Description</th>
                        <th>Trans Type</th>
                        <th>Depereciation Cost</th>
                        <th>Depereciation Amount Charge</th>
                        <th>Created Time</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody id="tblbody">
                </tbody>
            </table>
        </div>
    </div>
</asp:Content>
