<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="PurchaseReturnList.aspx.cs" Inherits="PMS.Inventory.PurchaseReturnList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">

        function PrintReport(Purchase_Return_ID) {
            var id = Purchase_Return_ID;
            var locationInfo = window.location;
            var user_name = '<% =AppConfig.Company_Name %>';
            if (user_name == 'As-Siraat Serving Humanity') {
                reportPath = '../../ReportViewer.aspx';
            } else {
                reportPath = 'ReportViewer.aspx'; // same folder
            }

            var url = '/ReportViewer.aspx?ReportName=PurchaseReturnBasePrint&ReportTitle=Purchase Return Print&PurchaseReturnID=' + id;
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];

                url = 'http://' + ip + '/' + foldername + '/' + reportPath + '?ReportName=PurchaseReturnBasePrint&ReportTitle=Purchase Return Print&PurchaseReturnID=' + id;
            }
            window.open(url, '_blank');
        }

        
        function Edit(ID) {
            window.location.href = "AddPurchaseReturn.aspx?ID=" + ID;
        }
        function deleteConfirm(ID) {
            var ReturnID = ID;
            if (confirm('Are you sure want to delete this record')) {
                PageMethods.DeleteRecord(ReturnID, function (msg) {
                    window.location.reload();
                });
            }
        }
        function redirecttonew() {
            window.location.href = "AddPurchaseReturn.aspx";
        }

        $(document).ready(function () {
            LoadPage();
        });

    
        function LoadPage() {
            let savedVisibility = null;

            $.ajax({
                type: "POST",
                url: "PurchaseReturnList.aspx/GetUserColumnPreferences",
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
                "buttons": [{ text: 'Add', className: 'dt-button buttons-copy buttons-html5', action: function () { window.location = 'AddPurchaseReturn.aspx'; } }, 'copy', 'excel', 'pdf',
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
                        url: "PurchaseReturnList.aspx/ViewList",
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
                    { "data": "Purchase_Return_ID", visible: false, },
                    { "data": "Purchase_Return_No", "name": "Purchase_Return_No", width: "9%" },
                    {
                        "data": "Purchase_Return_Date",
                        "render": function (data, type, full) {
                            var date = full.Purchase_Return_Date;
                            date = moment(date).format('D-MMM-YYYY');
                            return date;
                        }, width: "11%"
                    },  
                    { "data": "Remarks", width: "11%" },
                    { "data": "Status", "name": "Status", width: "11%" },
                                     
                    {
                        "render": function (data, type, full) {
                            var res = '<a href="#" class="editListBtn" onclick="Edit(' + full.Purchase_Return_ID + ')" style="border-radius: 4px;margin-right: 4px;padding: 5px 8px 5px 8px;"><i class="fa fa-pencil"></i></a>';

                            var print = '<a class="printListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="PrintReport(' + full.Purchase_Return_ID + ')" id="btnprint"><i class="fa fa-print" ></i></a>';
                            var result;
                            result = res + print;
                            return result;
                        }, width: "8%"
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
                    <th>Purchase_Return_ID</th>
                    <th>Return Num</th>
                    <th>Return Date</th>
                    <th>Remarks</th>
                    <th>Status</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody id="tblbody">
            </tbody>
        </table>
    </div>

</asp:Content>
