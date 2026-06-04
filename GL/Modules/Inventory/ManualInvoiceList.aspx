<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ManualInvoiceList.aspx.cs" Inherits="PMS.Inventory.ManualInvoiceList" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">

        function PrintReport(id) {
            var locationInfo = window.location;

            var user_name = '<% =AppConfig.Company_Name %>';
            if (user_name == 'As-Siraat Serving Humanity') {
                reportPath = '../../ReportViewer.aspx';
            } else {
                reportPath = 'ReportViewer.aspx'; // same folder
            }

            var url = '../../ReportViewer.aspx?ReportName=Voucher&ReportTitle=MIN Voucher&TransID=' + id + '&TransType=MIN';
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];

                url = 'http://' + ip + '/' + foldername + '/' + reportPath +  '?ReportName=Voucher&ReportTitle=MIN Voucher&TransID=' + id + '&TransType=MIN';
            }
            window.open(url, '_blank');
        }
        function Edit(ID) {
            window.location.href = "AddManualInvoice.aspx?Inv_ID=" + ID;
        }
        function deleteConfirm(ID) {
            debugger;
            var ManID = ID;
            if (confirm('Are you sure want to delete this record')) {
                PageMethods.DeleteRecord(ManID, function (msg) {
                    debugger
                    window.location.reload();
                });
            }
        }
        function redirecttonew() {
            window.location.href = "AddManualInvoice.aspx";
        }

        $(document).ready(function () {                 
            LoadPage();
        });

        function LoadPage() {
            let savedVisibility = null;

            $.ajax({
                type: "POST",
                url: "ManualInvoiceList.aspx/GetUserColumnPreferences",
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
            $("#example").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": [{ text: 'Add', className: 'dt-button buttons-copy buttons-html5', action: function () { window.location = 'AddManualInvoice.aspx'; } }, 'copy', 'excel', 'pdf',
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
                        url: "ManualInvoiceList.aspx/ViewList",
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
                    { "data": "ManualInvoiceId", visible: false, width:"0%" },
                    { "data": "ManualInvoiceNum", "name": "ManualInvoiceNum", width: "11%" },
                    { "data": "VendorName", width: "15%" },
                    { "data": "RefInvoiceNum", width:"10%" },
                    { "data": "Remarks" },
                    {
                        "data": "ManualInvoiceDate",
                        "render": function (data, type, full) {
                            var date = moment(full.ManualInvoiceDate).format('D-MMM-YYYY');
                            return date;
                        }, width:"10%"
                    },
                    { "data": "TotalAmount", width: "10%" },
                    { "data": "Status", width:"10%" },
                    
                    {
                        "data": null,
                        "render": function (data, type, full) {
                            var Edit = '<a class="editListBtn" href="#" onclick="Edit(' + full.ManualInvoiceId + ')" style="border-radius: 4px;margin-right: 4px;padding: 5px 8px 5px 8px;"><i class="fa fa-pencil"></i></a>'

                            var Del = '<a href="#" class="delListBtn"  onclick="deleteConfirm(' + full.ManualInvoiceId + ')" id="btnDel" name="btnDel" style="border-radius: 4px;margin-right: 4px;padding: 5px 8px 5px 8px;"><i class="fa fa-trash"></i></a>'

                            var Print = '<a href="#" class="printListBtn" onclick="PrintReport(' + full.ManualInvoiceId + ')" id="btnprint"  name="btnprint" style="border-radius: 4px;margin-right: 4px;color: white; padding: 5px 8px 5px 8px;"><i  class="fa fa-print"></i></a>'
                            var result;
                            result = Edit + Del + Print ;
                            return result;
                        }, width:"12%"
                    }
                ],
                "rowCallback": function (row, data, index) {
                    if (data.Status === "Approved") {
                        $(row).css('background-color', '#ABEBC6');
                    }
                },
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
                    }
                }
            });
        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="table-container">
        <table id="example" class="table table-hover table-bordered">
            <thead>
                <tr>
                    <th>ManualInvoiceId</th>
                    <th>Invoice Num</th>
                    <th>Vendor</th>
                    <th>Ref Invoice Num</th>
                    <th>Remarks</th>
                    <th>Invoice Date</th>
                    <th>Total Amount</th>
                    <th>Status</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody id="tblbody">
            </tbody>
        </table>
    </div>

</asp:Content>
