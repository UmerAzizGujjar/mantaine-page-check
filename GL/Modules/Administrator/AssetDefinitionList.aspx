<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AssetDefinitionList.aspx.cs" Inherits="PMS.AssetDefinitionList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/Tibbit_theme/css/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">

        $(document).ready(function () {
            debugger;
            $('#ctl00_lblMessage').hide();
            LoadPage();


        });

        function DeleteStock(Id) {
            if (!confirm("Are you sure you want to delete"))
                return;
            else {
                debugger;

                $.ajax({
                    type: "POST",
                    contentType: "application/json; charset=utf-8",
                    url: "AssetDefinitionList.aspx/Delete",
                    data: JSON.stringify({
                        'Id': Id,
                    }),
                    dataType: "json",
                    success: function (data) {
                        if (data) {
                            alert('Successfully Deleted.');
                            $("#" + stId).remove();
                        }
                        else
                            alert('Could not deleted.');
                    },
                    error: function (result) {
                        alert("Could not be deleted.");
                    }
                });
            }

        }
        function Edit(ID) {
            window.location.href = "AddAssetSelection.aspx?ID=" + ID;
        }
        function LoadPage() {
            $("#tblResult").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": [{ text: 'Add', className: 'dt-button buttons-copy buttons-html5', action: function () { window.location = 'AddAssetSelection.aspx'; } }, 'copy', 'excel', 'pdf'],
                "filter": true,
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "AssetDefinitionList.aspx/ViewList",
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
                    { "data": "Asset_Definition_Id", "visible": false, "width": "0%" },
                    { "data": null, "orderable": false, "width": "8%" },
                    { "data": "AssetCategory", "name": "AssetCategory", "width": "20%", "orderable": true },
                    { "data": "AssetSubCategory", "name": "AssetSubCategory", "width": "20%", "orderable": true },
                    { "data": "Location", "name": "Location", "width": "15%", "orderable": false },
                    { "data": "Item_Description", "name": "Item_Description", "width": "15%","orderable": false },

                    {
                        render: function (data, type, full) {
                            debugger;
                            var res = '<a class="editListBtn" href="#" onclick="Edit(' + full.Asset_Definition_Id + ')" style="border-radius: 4px; color: white; padding: 5px 8px 5px 8px;"><i style="color:white !important;" class="fa fa-pencil"></i></a>'


                            var result;
                            result = res;
                            return result;
                        }, "width": "10%", "orderable": false
                    }
                ],
                "createdRow": function (row, data, dataIndex) {
                    $(row).find('td:eq(0)').html(dataIndex + 1);
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
                    } else {
                        console.log("Length dropdown, label, or container not found");
                    }
                }
            });
        }
    </script>
</asp:Content>
  <asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    
    <div style="margin-top: 15px;">

        <div class="row">
            <div class="table-container col-lg-12 col-md-12 col-sm-10">
                <table class="table table-hover table-striped table-bordered" id="tblResult" style="overflow: scroll; height: auto;">
                    <thead id="ihead">
                        <tr>
                            <th style="display: none;">Asset_Selection_ID</th>
                            <th>SR #</th>
                            <th>Branch</th>
                            <th>Asset Category</th>
                            <th>Item Sub Category</th>
                            <th>Item Serial</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="ibody">
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</asp:Content>

