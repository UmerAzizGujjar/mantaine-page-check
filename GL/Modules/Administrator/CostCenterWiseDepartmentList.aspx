<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="CostCenterWiseDepartmentList.aspx.cs" Inherits="PMS.CostCenterWiseDepartmentList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">
        $(document).ready(function () {
            LoadPage();
        });
        function LoadPage() {
            $('#tblResult').DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": [{ text: 'Add', className: 'dt-button buttons-copy buttons-html5', action: function () { window.location = 'CostCenterWiseDepartment.aspx'; } }, 'copy', 'excel', 'pdf',
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
                        url: "CostCenterWiseDepartmentList.aspx/ViewList",
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
                    { "data": "CostCenter_wise_Department_Id", "name": "CostCenter_wise_Department_Id", visible: false, "width": "0%" },
                    { "data": "CostCenter_name", "name": "CostCenter_name" },
                    {
                        "data": "Created_Time", "name": "Created_Time",
                        "render": function (data, type, full) {
                            if (full.Created_Time == null) return '';
                            return moment(full.Created_Time).format('DD-MMM-YYYY');
                        }, "width": "15%"
                    },
                    {
                        render: function (data, type, full) {
                            var res = '<a href="#" onclick="Edit(\'' + full.CostCenter_wise_Department_Id + '\')" class="editListBtn" style="border-radius: 4px; margin-right: 4px;padding: 5px 8px;"><i class="fa fa-pencil"></i></a>';
                            var Delete = '<a  class="delListBtn" style="border-radius: 4px;margin-left: 4px;padding: 5px 8px 5px 8px;" href="#" data-id="' + full.CostCenter_wise_Department_Id + '" onclick="deleteConfirm(this)"><i class="fa fa-trash"></i></a>';
                            return res + Delete;
                        }, "width": "10%"
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
        function OnFail(exc) {
            alert(exc.get_message());
        }
        function Edit(ID) {
            window.location.href = "CostCenterWiseDepartment.aspx?ID=" + ID;
        }
        function deleteConfirm(anchorTag) {
            var recordId = $(anchorTag).data('id');

            if (confirm('Are you sure you want to delete this record?')) {
                PageMethods.DeleteRecord(recordId, function (msg) {
                    $(anchorTag).closest('tr').remove();
                    window.location.reload();
                }, OnFail);
            }
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div id="PurchaseRequistiondetails" style="margin-top: 15px;">

        <div class="table-container">
            <div class="table-responsive">
                <table class="table table-hover table-striped table-bordered" id="tblResult">
                    <thead id="ihead">
                        <tr>
                            <th>CostCenter_wise_Department_Id</th>
                            <th>Cost Center</th>
                            <th>Date</th>
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
