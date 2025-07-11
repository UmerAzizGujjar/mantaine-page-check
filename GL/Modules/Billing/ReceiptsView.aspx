<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ReceiptsView.aspx.cs" Inherits="PMS.ReceiptsView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/Tibbit_theme/css/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">

        $(document).ready(function () {
            $('#ctl00_lblMessage').hide();
            LoadPage();


        });
        function PrintTest(Receipt_ID) {
            var url = '../../ReportViewer.aspx?ReportName=PrinAllReceiptDetail&ReportTitle=Bill Detail (IPD)  ' + '&PatientID=' + Receipt_ID;
            window.open(url, '_blank');

        }

        function LoadPage() {
            $("#tblResult").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": [{ text: 'Add', className: 'dt-button buttons-copy buttons-html5', action: function () { window.location = 'Receipts.aspx'; } }, 'copy', 'excel', 'pdf'],
                "filter": true,
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "ReceiptsView.aspx/ViewList",
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
                    { "data": "Receipt_ID", "visible": false, "width": "0%" },
                    { "data": "Receipt_No", "name": "Receipt_No", "width": "8%", "orderable": true },
                    {
                        "data": "Receipt_Date", "name": "Receipt_Date",
                        "render": function (data, type, full) {
                            debugger;
                            var date = full.Receipt_Date;
                            date = moment(date).format('DD-MMM-YYYY');
                            return date;
                        }, "width": "8%", "orderable": true
                    },
                    { "data": "Remarks", "width": "15%", "orderable": false },
                    { "data": "Receipt_Amount", "width": "8%", "orderable": false },

                    { "data": "mr_no_sequence", "width": "12%", "orderable": false },
                    { "data": "Full_Name", "width": "14%", "orderable": false },            
                    {
                        "data": "Creation_Date", "name": "Creation_Date",
                        "render": function (data, type, full) {
                            debugger;
                            var date = full.Creation_Date;
                            date = moment(date).format('DD-MMM-YYYY');
                            return date;
                        }, "width": "10%", "orderable": false
                    },

                    { "data": "UserName", "width": "10%", "orderable": false },
                    {
                        render: function (data, type, full) {
                            debugger;
                            var res = '<a href="#"  class="editListBtn" onclick="editOpen(' + full.Receipt_ID + ')" style="border-radius: 4px;color: white; padding: 5px 8px 5px 8px;"><i class="fa fa-pencil"></i></a>'

                            var Del = '<a class="delListBtn" href="#" style="border-radius: 4px;margin-left: 4px; color: white; padding: 5px 8px 5px 8px;" onclick=cancelPatient(this)><i class="fa fa-trash" aria-hidden="true"></i></a>';

                            var print = '<a class="printListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="PrintTest(' + full.Receipt_ID + ')" id="btnprint"><i class="fa fa-print"></i></a>';
                            var result;
                            result = res + Del + print;
                            return result;
                        }, "width": "8%", "orderable": false
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
                    } else {
                        console.log("Length dropdown, label, or container not found");
                    }
                }
            });
        }

        function editOpen(id) {

            window.open("Receipts.aspx?Receipt_ID=" + id + "");
        }
        function CancelConfirm(anchorTag) {

            debugger;
            var row = $(anchorTag).parents('tr')[0];
            var Receipt_ID = $($(row).find('td')[0]).text();
            var Receipt_No = $($(row).find('td')[1]).text();

            $("#tblResult tr").find('th:eq(10)').show();
            $("#tblResult tr").find('td:eq(10)').show();
            cell = row.insertCell(-1);
            cell.innerHTML = '<span class="show" style="width:100px;"><input type="text" id="txtCancel" onchange="cancelPatient(this)"/></span>';

        }
        function cancelPatient(anchorTag) {
            debugger;

            var row = $(anchorTag).parents('tr')[0];
            var Receipt_ID = $($(row).find('td')[0]).text();
            var Receipt_No = $($(row).find('td')[1]).text();
            var reason = $(row).find($("input[type=text]")).val();
            if (confirm('Are you sure want to Cancel this Receipt:- ' + Receipt_No)) {
                PageMethods.CancelPatient(Receipt_ID, function (msg) {
                    if (msg == "Allowdlt") {
                        alert('You have no right to Cancel. ')

                    }
                    else if (msg == "success") {

                        row.remove();
                    }
                    else {
                        alert('Error in Cancel Reciept')
                    }

                },

                    OnFail);
            }

            window.location.href = "ReceiptsView.aspx";
        }
        function deleteConfirm(anchorTag) {
            var row = $(anchorTag).parents('tr')[0];
            var ID = $($(row).find('td')[0]).text();
            var No = $($(row).find('td')[1]).text();

            if (confirm('Are you sure want to delete Receipt No:- ' + No)) {
                PageMethods.Delete(ID, function (msg) {
                    row.remove();
                }, OnFail);
            }
        }

        
        function gotoreceipt() {
            window.location.href = "Receipts.aspx";
        }
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div >
            
       
        <div class="row">
            <div class="table-container col-lg-12 col-md-12 col-sm-12 col-xs-12 mt-3">
                <table class="table table-hover table-striped table-bordered" id="tblResult" >
                    <thead id="ihead">
                        <tr>
                            <th style="display: none;">Receipt ID</th>
                            <th>Receipt No</th>
                            <th>Receipt Date</th>
                            <th>Remarks</th>
                            <th>Amount</th>
                            <th>MR No</th>
                            <th>Patient Name</th>
                            <th>Creation Date</th>
                            <th>Operator Name</th>
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
