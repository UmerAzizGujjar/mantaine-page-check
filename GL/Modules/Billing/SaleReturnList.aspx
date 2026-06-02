<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="SaleReturnList.aspx.cs" Inherits="PMS.Modules.Billing.SaleReturnList" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/css/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">

        $(document).ready(function () {
            $('#ctl00_lblMessage').hide();
            LoadPage();

        });
      
       
        function PrintInvoice(key) {
            debugger;
            //var BillId = $('#BillId' + key).val();
            window.open('../../ReportViewer.aspx?ReportName=PharmacyReturnSlip&ReportTitle=PharmacySlip&Return_ID=' + key);

        }


        function LoadPage() {
            $("#tbl").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                buttons: [
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
                "filter": true,
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "SaleReturnList.aspx/ViewList",
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
                    { "data": "Return_ID", "visible": false, "width": "0%" },                                                        
                    {
                        "data": "Created_Date", "name": "Created_Date",
                        "render": function (data, type, full) {
                            debugger;
                            var date = full.Created_Date;
                            date = moment(date).format('DD-MMM-YYYY');
                            return date;
                        }, "width": "15%"
                    },
                    { "data": "Seq_InvoiceNo", "width": "10%" }, 
                    { "data": "TotalDisc_Amount", "width": "15%", },
                    { "data": "Net_Amount", "name": "Net_Amount", "width": "10%" },                    
                    { "data": "Total_Amount", "width": "10%", },
                    { "data": "UserName", "width": "10%", },
                    {
                        render: function (data, type, full) {
                            debugger;
                            var res = '<a href="#" onclick="PrintInvoice(' + full.Return_ID + ')" style="border-radius: 4px; background-color: #1f1fe3; color: white; padding: 5px 8px 5px 8px;"><i style="color:white !important;" class="fa fa-upload"></i></a>'
                      
                            var result;
                            result = res;
                            return result;
                        }, "width": "10%"
                    }
                ],
                "initComplete": function (settings, json) {
                    var lengthDropdown = document.querySelector('#tbl_length select');
                    var label = document.querySelector('#tbl_length label');
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
    <div class="row">
        <div class="table-container">
            <table id="tbl" class="table table-bordered table-hover table-striped">
                <thead id="ihead">
                    <tr>
                        <th style="display:none;">Return_ID</th>
                        <th>Return Date</th>
                        <th>Inv No</th>
                        <th>Total Discount</th>
                        <th>Net Amount</th>
                        <th>Total Amount</th>
                        <th>Operator</th>
                        <th>Action</th>                      
                    </tr>
                </thead>
                <tbody id="tbody">
                </tbody>
            </table>
        </div>
    </div>

</asp:Content>
