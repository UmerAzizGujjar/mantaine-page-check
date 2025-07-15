<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="RefundList.aspx.cs" Inherits="PMS.RefundList" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/Tibbit_theme/css/tablestyle.css" rel="stylesheet" />
        <script type="text/javascript">
            $(document).ready(function () {
                $('#ctl00_lblMessage').hide();
                LoadPage();


            });
            function EditAdvance(advId) {
                debugger;
                window.open("Refund.aspx?advID=" + advId);
            }


            function PrintRefund(Refund_ID) {
                debugger;
                var locationInfo = window.location;
                var url = "/ReportViewer.aspx?ReportName=PrintRefundReport&Title=Refund Print &Refund_ID=" + Refund_ID;
                if (!locationInfo.origin.includes('localhost')) {
                    var urlInfo = window.location.href.split('/');
                    var ip = urlInfo[2];
                    var foldername = urlInfo[3];
                    url = 'http://' + ip + '/' + foldername + "/ReportViewer.aspx?ReportName=PrintAdvanceReport&Title=Refund Print &Refund_ID=" + Refund_ID;
                }
                window.open(url, '_blank');
            }

            function deleteConfirm(anchorTag) {
                var table = $('#tblAdvanceView').DataTable();
                var row = $(anchorTag).closest('tr');
                var rowData = table.row(row).data();
                var RefundID = rowData.Refund_ID;

                if (confirm('Are you sure you want to delete this record?')) {
                    PageMethods.DeleteRecord(RefundID, function (result) {
                        if (result) {
                            location.reload();
                        } else {
                            alert("This record is in use and cannot be deleted");
                        }
                    });
                }
            }

           
            function LoadPage() {
                $("#tblAdvanceView").DataTable({
                    "processing": true,
                    "serverSide": true,
                    "dom": 'lBfrtip',
                    "lengthChange": true,
                    "buttons": [{ text: 'Add', className: 'dt-button buttons-copy buttons-html5', action: function () { window.location = 'Refund.aspx'; } }, 'copy', 'excel', 'pdf'],
                    "filter": true,
                    "ajax": function (data, callback, settings) {
                        $.ajax({
                            type: "POST",
                            url: "RefundList.aspx/ViewList",
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
                        { "data": "Refund_ID", "visible": false, "width": "0%" },
                        { "data": "Bill_ID", "name": "Bill_ID", "width": "10%", "orderable": true },
                        { "data": "Bill_No", "width": "10%", "orderable": false },
                        {
                            "data": "Refund_Date", "name": "Refund_Date",
                            "render": function (data, type, full) {
                                debugger;
                                var date = full.Refund_Date;
                                date = moment(date).format('DD-MMM-YYYY');
                                return date;
                            }, "width": "15%", "orderable": true
                        },
                        { "data": "Refund_Amount", "width": "15%", className: "text-right", "orderable": false },
                        { "data": "MrNo", "name": "MrNo", "width": "15%", "orderable": false },
                        { "data": "Remarks", "width": "25%", "orderable": false },


                        {
                            render: function (data, type, full) {
                                debugger;
                                var res = '<a href="#" onclick="EditAdvance(' + full.Refund_ID + ')" class="editListBtn" style="border-radius: 4px;padding: 5px 8px 5px 8px;"><i class="fa fa-pencil"></i></a>'

                                var Del = '<a class="delListBtn" href="#" style="border-radius: 4px;margin-left: 4px;padding: 5px 8px 5px 8px;" onclick=deleteConfirm(this)><i class="fa fa-trash" aria-hidden="true"></i></a>';

                                var print = '<a  class="printListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="PrintRefund(' + full.Refund_ID + ')" id="btnprint"><i class="fa fa-print" ></i></a>';
                                var result;
                                result = res + Del + print;
                                return result;

                            }, "width": "10%", "orderable": false
                        }
                    ],
                    "initComplete": function (settings, json) {
                        var lengthContainer = document.querySelector('#tblAdvanceView_length');
                        var lengthDropdown = document.querySelector('#tblAdvanceView_length select');
                        var label = document.querySelector('#tblAdvanceView_length label');

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
    

    <div>
        <table id="tblAdvanceView" class="table table-hover table-striped table-bordered">
            <thead>
                  <tr>
                     <th>Refund_ID</th>
                     <th>Bill_ID</th>
                     <th>Bill No </th>
                     <th>Refund_Date</th>
                     <th>Refund_Amount</th>
                     <th>Mr No#</th>
                     <th>Remarks</th>
                   <th>Action</th>
                 </tr>
            </thead>
               
             </table>
    </div>

</asp:Content>
           

       