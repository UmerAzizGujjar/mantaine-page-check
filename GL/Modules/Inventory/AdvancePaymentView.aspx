<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AdvancePaymentView.aspx.cs" Inherits="PMS.Inventory.AdvancePaymentView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

    <link href="../../wwwroot/Tibbit_theme/css/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">
        function OnFail(exc) {
            alert(exc.get_message());
        }
        function Edit(ID) {
            window.location.href = "AdvancePayment.aspx?Adv_ID=" + ID;
        }
        function isDeleteAllow() {
            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: "AdvancePaymentView.aspx/isDeleteAllow",
                data: "",
                success: function (resp) {
                    debugger;
                    if (resp.d == true) {
                        isDele = true;
                    }
                    else {
                        isDele = false;
                    }
                }, error: function () { }
            })
        }
        function PrintVoucher(InvId) {
            window.open('ReportViewer.aspx?ReportName=Voucher&ReportTitle=Advance Payment Voucher&TransID=' + InvId + '&TransType=ADV');
        }
        function deleteConfirm(anchorTag) {
            debugger;
            var row = $(anchorTag).parents('tr')[0];
            var AdvID = $($(row).find('td')[0]).text();
            if (confirm('Are you sure want to delete this record')) {
                PageMethods.DeleteRecord(AdvID, function (msg) {
                    debugger
                    $(row).remove();
                }, OnFail);
            }
        }

        $(document).ready(function () {
            LoadPage();
        });



        function LoadPage() {
            $("#tblResult").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": [{ text: 'Add', className: 'dt-button buttons-copy buttons-html5', action: function () { window.location = 'AdvancePayment.aspx'; } }, 'copy', 'excel', 'pdf'],
                "filter": true,
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "AdvancePaymentView.aspx/ViewList",
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
                    { "data": "Advance_ID", "visible": false, "width": "0%" },
                    { "data": "advance_no", "name":"advance_no" },
                    {
                        "data": "date",
                        "render": function (data, type, full) {
                            var date = full.date;
                            date = moment(date).format('D-MMM-YYYY');
                            return date;
                        }
                    },
                    { "data": "refer_no" },
                    { "data": "VendorName" },
                    { "data": "advance_amount" },
                    { "data": "remarks" },
                    { "data": "status" },
                    {
                        "render": function (data, type, full) {
                            var res = '<a href="#" class="editListBtn" onclick="Edit(' + full.Advance_ID + ')" style="border-radius: 4px;margin-right: 4px;  color: white; padding: 5px 8px 5px 8px;"><i style="color:white !important;" class="fa fa-pencil"></i></a>';
                            var print = '<a style="border-radius: 4px;background-color:#387024;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="PrintVoucher(' + full.Advance_ID + ')" id="btnprint"><i class="fa fa-print" style="color:white !important;"></i></a>';
                          

                            var result = res + print;
                            return result;
                        }
                    }
                ],
                "rowCallback": function (row, data, index) {
                    if (data.status === "Approved") {
                        $(row).css('background-color', '#ABEBC6');
                    }
                },
                "initComplete": function (settings, json) {
                    var lengthDropdown = document.querySelector('#tblResult_length select');
                    var label = document.querySelector('#tblResult_length label');
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
    <div id="PurchaseRequistiondetails">
        <div class="row">
            <div class="col-lg-2 col-md-4 col-sm-12" style="margin-bottom:1%">
                <input type="button" class="btn btn-primry"  id="aadnew" value="Add New" onclick="location.href = 'AdvancePayment.aspx';" />
            </div>
        </div>

        <div class="table-container">
            <table class="table table-hover table-bordered" id="tblResult">
                <thead id="ihead">
                    <tr>
                        <th>Advance ID</th>
                        <th>Advance #</th>
                        <th>Date</th>
                        <th>Refer #</th>
                        <th>Vendor Name</th>
                        <th>Advance Amount</th>
                        <th>Remarks</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody id="ibody">
                </tbody>
            </table>
        </div>
    </div>
</asp:Content>
