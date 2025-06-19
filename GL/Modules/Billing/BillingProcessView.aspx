<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="BillingProcessView.aspx.cs" Inherits="PMS.BillingProcessView" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/StandardTheme/css/tablestyle.css" rel="stylesheet" />

    <script type="text/javascript">
        $(document).ready(function () {
            debugger;
            $('#ctl00_lblMessage').hide();
            LoadPage();


        });


        function LoadPage() {
            $("#tbloutPatients").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": ['copy', 'excel', 'pdf'],
                "filter": true,
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "BillingProcessView.aspx/ViewList",
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
                    { "data": "Bill_No", "name": "Bill_No", "width": "5%", "orderable": true },
                    {
                        "data": "Bill_Date", "name": "Bill_Date",
                        "render": function (data, type, full) {
                            debugger;
                            var date = full.Bill_Date;
                            date = moment(date).format('DD-MMM-YYYY');
                            return date;
                        }, "width": "7%", "orderable": true
                    },
                    { "data": "MrNo", "name": "MrNo", "width": "8%", "orderable": true },
                    { "data": "Full_Name", "width": "13%", "orderable": false },
                    { "data": "Total_Amount", "width": "7%", "orderable": false },
                    { "data": "Discount_Percentage", "width": "10%", "orderable": false },
                    { "data": "Discount_Amount", "width": "9%", "orderable": false },
                    { "data": "Net_Amount", "width": "8%", "orderable": false  },
                    { "data": "Received_Amount", "name": "Received_Amount", "width": "10%", "orderable": false },
                    { "data": "Balance_Amount", "width": "8%", "orderable": false },
                    { "data": "Operator", "width": "9%", "orderable": false },
                    
                    {
                        render: function (data, type, full) {
                            debugger;
                            var res = '<a href="#" class="editListBtn" onclick="editOpen(' + full.Bill_ID + ')" style="border-radius: 4px;color: white; padding: 5px 8px 5px 8px;"><i style="color:white !important;" class="fa fa-pencil"></i></a>'
                            var Del = '<a href="#" style="border-radius: 4px; background-color: #ad170c;margin-left: 4px; color: white; padding: 5px 8px 5px 8px;" onclick=cancelPatient(this)><i class="fa fa-trash" aria-hidden="true"></i></a>';

                            var result;
                            result = res + Del;
                            return result;
                        }, "width": "18%", "orderable": false
                    }

                ],
                "initComplete": function (settings, json) {
                    var lengthContainer = document.querySelector('#tbloutPatients_length');
                    var lengthDropdown = document.querySelector('#tbloutPatients_length select');
                    var label = document.querySelector('#tbloutPatients_length label');

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
            window.open("BillingProcess.aspx?Bill_ID=" + id + "");
        }
        function CancelConfirm(anchorTag) {

            debugger;

            var row = $(anchorTag).parents('tr')[0];
            var Bill_ID = $($(row).find('td')[0]).text();
            var BillNo = $($(row).find('td')[1]).text();

            $("#tbloutPatients tr").find('th:eq(14)').show();
            $("#tbloutPatients tr").find('td:eq(14)').show();
            cell = row.insertCell(-1);
            cell.innerHTML = '<span class="show" style="width:100px;"><input type="text" id="txtCancel" onchange="cancelPatient(this)"/></span>';

        }
        function cancelPatient(anchorTag) {
            debugger;

            var row = $(anchorTag).parents('tr')[0];
            var Bill_No = $($(row).find('td')[0]).text();
            if (confirm('Are you sure want to Cancel this Bill:- ' + Bill_No)) {
                PageMethods.CancelPatient(Bill_No,  function (msg) {
                    if (msg == "Allowdlt") {
                        alert('You have no right to Cancel. ')

                    }
                    else if (msg == "success") {

                        row.remove();
                    }
                    else {
                        alert('Unable to Cancel this patient, because this patient has uncanceled Reciept ')
                    }

                },

                    );
            }

            window.location.href = "BillingProcessView.aspx";
        }

        function deleteConfirm(anchorTag) {

            var row = $(anchorTag).parents('tr')[0];

            var Bill_ID = $($(row).find('td')[0]).text();

            if (confirm('Are you sure want to delete this record')) {
                PageMethods.DeleteRecord(Bill_ID, function (msg) {
                    if (msg == '')
                        row.remove();
                    else
                        alert(msg);
                }, OnFail);
            }
        }


    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="row">
        <div class="col-lg-2 col-md-12 col-sm-12">
            <input type="button" name="name" class="btn btn-primry" value="Add New" onclick="window.location ='BillingProcess.aspx'" />
        </div>
    </div>
    <br />
    <div class="row">
        <div class="table-container">
            <table class="table table-hover table-striped table-bordered" id="tbloutPatients">
                <thead id="ihead">
                    <tr>
                        <th class="hide">Bill ID</th>
                        <th>Bill No</th>
                        <th>Bill Date</th>
                        <th>MR No</th>
                        <th>Name</th>
                        <th>Total Amount</th>
                        <th>Discount Percentage</th>
                        <th>Discount Amount</th>
                        <th>Net Amount</th>
                        <th>Received Amount</th>
                        <th>Balance Amount</th>
                        <th>Operator</th>
                        <th style="width: 68px;">Actions</th>
                    </tr>
                </thead>
                <tbody id="ibody">
                </tbody>
            </table>
        </div>
    </div>
   
</asp:Content>
