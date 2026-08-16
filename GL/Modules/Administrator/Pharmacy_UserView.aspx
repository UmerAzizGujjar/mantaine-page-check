<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Pharmacy_UserView.aspx.cs" Inherits="PMS.Pharmacy_UserView" %>



<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />

    <script type="text/javascript">
        $(document).ready(function () {
            LoadPage();
        });

        function Edit(ID) {
            window.location.href = "Pharmacy_Users.aspx?ID=" + ID;
        }

        function LoadPage() {
            $.ajax({
                type: "POST",
                url: "Pharmacy_UserView.aspx/ViewList",
                data: JSON.stringify({}),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    var tableData = [];
                    if (data != '' && data.d) {
                        try {
                            tableData = JSON.parse(data.d) || [];
                        } catch (e) {
                            tableData = [];
                        }
                    }
                    initPharmacyUserTable(tableData);
                }
            });
        }

        function initPharmacyUserTable(tableData) {
            $("#tblResult").DataTable({
                "data": tableData,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "destroy": true,
                "buttons": [
                    {
                        text: 'Add',
                        className: 'dt-button buttons-copy buttons-html5',
                        action: function () {
                            window.location = 'Pharmacy_Users.aspx';
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
                "columns": [
                    {
                        "data": null, "orderable": false,
                        "render": (data, type, full, meta) => meta.row + 1
                    },
                    { "data": "User_Code", "name": "User_Code", "orderable": true },
                    { "data": "UserName", "name": "UserName", "orderable": true },
                    {
                        "data": null, "orderable": false,
                        "render": (data, type, full) => {
                            return `<a href="#" onclick="Edit(${full.UserID})" class="editListBtn" style="border-radius: 4px;padding: 5px 8px;"><i class="fa fa-pencil"></i></a>`;
                        }
                    }
                ],
                "initComplete": function () {
                    var lengthDropdown = document.querySelector('#tblResult_length select');
                    var label = document.querySelector('#tblResult_length label');

                    if (lengthDropdown && label) {
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

    <div id="POdetails" style="margin-top: 15px;">
        <div class="row">
            <div class="table-container col-lg-12 col-md-12 col-sm-10">
                <table class="table table-hover table-striped table-bordered" id="tblResult" style="overflow: scroll; height: auto;">
                    <thead id="ihead">
                        <tr>
                            <th style="width: 5% !important;">Sr#</th>
                            <th style="width: 25%;">User Code</th>
                            <th>User Name</th>
                            <th style="text-align: center; width: 15% !important;">Actions</th>
                        </tr>
                    </thead>
                    <tbody id="ibody">
                    </tbody>
                </table>
            </div>
        </div>
    </div>

</asp:Content>
