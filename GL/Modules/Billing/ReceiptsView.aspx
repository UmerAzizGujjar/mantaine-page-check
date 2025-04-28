<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ReceiptsView.aspx.cs" Inherits="PMS.ReceiptsView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/css/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">

        $(document).ready(function () {
            $('#ctl00_lblMessage').hide();
            LoadPage();


        });

        function LoadPage() {
            $("#tblResult").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": ['copy', 'excel', 'pdf'],
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
                    { "data": "Receipt_No", "name": "Receipt_No", "width": "10%" },
                    {
                        "data": "Receipt_Date", "name": "Receipt_Date",
                        "render": function (data, type, full) {
                            debugger;
                            var date = full.Receipt_Date;
                            date = moment(date).format('DD-MMM-YYYY');
                            return date;
                        }, "width": "10%"
                    },
                    { "data": "Remarks", "width": "25%" },
                    { "data": "Receipt_Amount", "width": "8%" },
                    
                    { "data": "mr_no_sequence", "width": "12%" },
                    { "data": "Full_Name", "width": "15%" },            
                    {
                        "data": "Creation_Date", "name": "Creation_Date",
                        "render": function (data, type, full) {
                            debugger;
                            var date = full.Creation_Date;
                            date = moment(date).format('DD-MMM-YYYY');
                            return date;
                        }, "width": "25%"
                    },

                    { "data": "UserName", "width": "15%" },
                    {
                        render: function (data, type, full) {
                            debugger;
                            var res = '<a href="#"  class="editListBtn"  onclick="editOpen(' + full.Receipt_ID + ')" style="border-radius: 4px;color: white; padding: 5px 8px 5px 8px;"><i style="color:white !important;" class="fa fa-pencil"></i></a>'
                            var Del = '<a href="#" style="border-radius: 4px; background-color: #ad170c;margin-left: 4px; color: white; padding: 5px 8px 5px 8px;" onclick=cancelPatient(this)><i class="fa fa-trash" aria-hidden="true"></i></a>';

                            var result;
                            result = res + Del;
                            return result;
                        }, "width": "100%"
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
            <div class="col-lg-2 col-md-3 col-sm-6" style="margin-bottom: 1%;">
                <input type="button" name="name" class="btn btn-primry"  value="Add New" onclick="gotoreceipt();" />
            </div>
       
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
