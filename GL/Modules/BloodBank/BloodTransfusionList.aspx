<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="BloodTransfusionList.aspx.cs" Inherits="PMS.BloodTransfusionList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/Tibbit_theme/css/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">

        $(document).ready(function () {
            debugger;
            $('#ctl00_lblMessage').hide();
            LoadPage();


        });

        function Edit(ID) {
            window.location.href = "BloodTransfusionForm.aspx?ID=" + ID;
        }

        function LoadPage() {
            $("#tblBloodTransfusionList").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": ['copy', 'excel', 'pdf'],
                "filter": true,
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "BloodTransfusionList.aspx/ViewList",
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
                    { "data": "BTR_Id", "visible": false, "width": "0%", "orderable": false },
                    { "data": "Mr_No", "name": "Mr_No", "width": "10%", "orderable": true },
                    { "data": "Name", "name": "Name", "width": "10%", "orderable": false },
                    { "data": "Age", "name": "Age", "width": "10%", "orderable": false },
                    {
                        render: function (data, type, full) {
                            debugger;
                            var res = '<a href="#" onclick="Edit(' + full.BTR_Id + ')" style="border-radius: 4px; background-color: #1f1fe3; color: white; padding: 5px 8px 5px 8px;"><i style="color:white !important;" class="fa fa-pencil"></i></a>'
                            

                            var result;
                            result = res;
                            return result;
                        }, "width": "10%", "orderable": false
                    }
                ],
                "initComplete": function (settings, json) {
                    var lengthContainer = document.querySelector('#tblBloodTransfusionList_length');
                    var lengthDropdown = document.querySelector('#tblBloodTransfusionList_length select');
                    var label = document.querySelector('#tblBloodTransfusionList_length label');

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
    <form>
        <div class="table-container">
            <div class="table-responsive">
                <table id="tblBloodTransfusionList" class="table table-hover table-striped table-bordered">
                    <thead>
                        <tr>
                            <th style="display:none">Blood Transfusion #</th>
                            <th>MR No</th>
                            <th>Patient Name</th>
                            <th>Age</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                </table>
            </div>
        </div>
    </form>
</asp:Content>
