<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Share_Distribution_List.aspx.cs" Inherits="PMS.Modules.Billing.Share_Distribution_List" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
        <link href="../../wwwroot/Tibbit_theme/css/tablestyle.css" rel="stylesheet" />

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
                "buttons": [{ text: 'Add', className: 'dt-button buttons-copy buttons-html5', action: function () { window.location = 'BillingProcess.aspx'; } }, 'copy', 'excel', 'pdf'],
                "filter": true,
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "Share_Distribution_List.aspx/ViewList",
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
                    { "data": "Status", "width": "7%", "orderable": false },
                    { "data": "Remarks", "width": "9%", "orderable": false },
                    
                    {
                        render: function (data, type, full) {
                            debugger;
                            var res = '<a href="#" class="editListBtn" onclick="editOpen(' + full.Bill_ID + ')" style="border-radius: 4px;color: white; padding: 5px 8px 5px 8px;"><i class="fa fa-pencil"></i></a>'

                            var Del = '<a class="delListBtn" href="#" style="border-radius: 4px;margin-left: 4px; color: white; padding: 5px 8px 5px 8px;" onclick=cancelPatient(this)><i class="fa fa-trash" aria-hidden="true"></i></a>';

                          //  var print = '<a class="printListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="PrintBilling(' + full.Bill_ID + ')" id="btnprint"><i class="fa fa-print"></i></a>';
                            var result;
                            result = res + Del;//+ print;
                            return result;
;
                        }, "width": "23%", "orderable": false
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
             <div class="table-container">
                 <table class="table table-hover table-striped table-bordered" id="tbloutPatients">
                     <thead id="ihead">
                         <tr>
                             <th class="hide">Bill ID</th>
                             <th>Bill No</th>
                             <th>Distribution Date</th>
                             <th>MR No</th>
                             <th>Name</th>
                             <th>Total Amount</th>
                             <th>Status</th>
                             <th>Remarks</th>

                             <th>Actions</th>
                         </tr>
                     </thead>
                     <tbody id="ibody">
                     </tbody>
                 </table>
             </div>
         </div>
</asp:Content>
