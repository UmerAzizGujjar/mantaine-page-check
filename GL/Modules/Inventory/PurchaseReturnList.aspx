<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="PurchaseReturnList.aspx.cs" Inherits="PMS.Inventory.PurchaseReturnList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/Tibbit_theme/css/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">

        function PrintReport(Purchase_Return_ID) {
            debugger;
            var locationInfo = window.location;
            var user_name = '<% =AppConfig.Company_Name %>';
            if (user_name == 'As-Siraat Serving Humanity') {
                reportPath = '../../ReportViewer.aspx';
            } else {
                reportPath = 'ReportViewer.aspx'; // same folder
            }
            var url = '/ReportViewer.aspx?ReportName=PurchaseReturnList&ReportTitle=Purchase Return List&POid=' + Purchase_Return_ID;
            if (!locationInfo.origin.includes('localhost') || locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'https://' + ip + '/' + foldername + '/' + reportPath +  '?ReportName=PurchaseReturnList&ReportTitle=Purchase Return List&POid=' + Purchase_Return_ID;
            }
            window.open(url, '_blank');
        }

        
        function Edit(ID) {
            window.location.href = "AddPurchaseReturn.aspx?ID=" + ID;
        }
        function deleteConfirm(ID) {
            debugger;
            var ReturnID = ID;
            if (confirm('Are you sure want to delete this record')) {
                PageMethods.DeleteRecord(ReturnID, function (msg) {
                    debugger
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
            $("#example").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": [{ text: 'Add', className: 'dt-button buttons-copy buttons-html5', action: function () { window.location = 'AddPurchaseReturn.aspx'; } }, 'copy', 'excel', 'pdf'],
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
                            result = res  + print;
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
                    var lengthDropdown = document.querySelector('#example_length select');
                    var label = document.querySelector('#example_length label');
                    if (lengthDropdown && label) {
                        label.innerHTML = 'Show entries ';
                        label.appendChild(lengthDropdown);
                    } else {
                        console.log("Length dropdown or label not found");
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
