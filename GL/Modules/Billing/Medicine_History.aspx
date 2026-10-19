<%@ Page EnableSessionState="ReadOnly" Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Medicine_History.aspx.cs" Inherits="PMS.Modules.Billing.Medicine_History" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />

    <script type="text/javascript">

        $(document).ready(function () {
            $('#ctl00_lblMessage').hide();
            LoadPage();

        });

        function LoadPage() {
            let savedVisibility = null;

            $.ajax({
                type: "POST",
                url: "Medicine_History.aspx/GetUserColumnPreferences",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                success: function (response) {
                    if (response.d && response.d !== "") {
                        try {
                            savedVisibility = JSON.parse(response.d);
                        } catch (e) {
                            console.warn("Invalid column visibility JSON");
                        }
                    }
                },
                error: function () {
                    console.error("Failed to load column preferences");
                }
            });
            $("#tbl").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                buttons: [                 
                    'copy',
                    'excel',
                    {
                        extend: 'pdfHtml5',
                        text: 'PDF',
                        orientation: 'Potrait',
                        pageSize: 'A3',
                        exportOptions: {
                            columns: ':not(:last-child)'
                        },
                        customize: function (doc) {
                            doc.defaultStyle.fontSize = 8;
                        }
                    },
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
                        url: "Medicine_History.aspx/ViewList",
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
                    { "data": "Bill_ID", "visible": false, "width": "0%" },
                    {
                        "data": "Invoice_Date", "name": "Invoice_Date",
                        "render": function (data, type, full) {
                            var date = full.Invoice_Date;
                            date = moment(date).format('DD-MMM-YYYY');
                            return date;
                        }, "width": "6%", "orderable": true
                    },
                    { "data": "BillNo", "width": "6%", "orderable": false },
                    { "data": "FBR_Number", "width": "10%", "orderable": false },
                    { "data": "Customer_Name", "width": "8%", "orderable": false },
                    { "data": "Patient_ID", "name": "Patient_ID", "width": "8%", "orderable": true },
                    { "data": "Item_Name", "name": "Item_Name", "width": "12%", "orderable": false },
                    { "data": "Referred_By_value", "width": "8%", "orderable": false },
                    { "data": "Total_Amount", "width": "8%", "orderable": false },
                    { "data": "Discount_Amount", "width": "8%", "orderable": false },
                    { "data": "Balance_Amount", "width": "8%", "orderable": false },
                    {
                        render: function (data, type, full) {
                            var res = '<a href="#" class="editListBtn" onclick="PrintInvoice(' + full.Bill_ID + ')" style="border-radius: 4px;  color: white; padding: 5px 8px 5px 8px;"><i class="fa fa-upload"></i></a>'

                            var print = '<a class="printListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="PrintBill(' + full.Bill_ID + ')" id="btnprint"><i class="fa fa-print" ></i></a>';
                            var result;
                            result = res;
                            return result;
                        }, "width": "6%", "orderable": false
                    }
                ],
                "initComplete": function (settings, json) {
                    const api = this.api();
                    if (savedVisibility && Array.isArray(savedVisibility)) {
                        if (savedVisibility.length === api.columns().count()) {
                            api.columns().every(function (index) {
                                this.visible(savedVisibility[index]);
                            });
                        }
                    }
                    api.on('column-visibility.dt', function (e, settings, column, state) {
                        let currentVis = [];
                        api.columns().every(function () {
                            currentVis.push(this.visible());
                        });
                        PageMethods.SaveUserColumnPreferences(
                            JSON.stringify(currentVis),
                            function () {
                                console.log("Column preferences saved");
                            },
                            function (error) {
                                console.error("Failed to save preferences:", error);
                            }
                        );
                    });

                    var lengthContainer = document.querySelector('#tbl_length');
                    var lengthDropdown = document.querySelector('#tbl_length select');
                    var label = document.querySelector('#tbl_length label');

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

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
        <div class="table-container">
            <table id="tbl" class="table table-bordered table-hover table-striped">
                <thead id="ihead">
                    <tr>
                        <th style="display: none;">Bill_ID</th>
                        <th>Invoice Date</th>
                        <th>Inv No</th>
                        <th>FBR Number</th>
                        <th>Walking Customer</th>
                        <th>MrNo.</th>
                        <th>Medicine</th>
                        <th>ReferBy</th>
                        <th>Total</th>
                        <th>Discount Amount</th>
                        <th>Balance Amount</th>
                        <th>View</th>
                    </tr>
                </thead>
                <tbody id="tbody">
                </tbody>
            </table>
        </div>
    </div>
</asp:Content>
