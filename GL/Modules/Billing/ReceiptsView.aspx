<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ReceiptsView.aspx.cs" Inherits="PMS.ReceiptsView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/Tibbit_theme/css/tablestyle.css" rel="stylesheet" />

    <style type="text/css">
        .cancelled-row {
    background-color: #ff6242 !important; 
    color: #cc0000;
    color:black !important;
}
    </style>

    <script type="text/javascript">

        $(document).ready(function () {
            $('#ctl00_lblMessage').hide();
            LoadPage();


        });
        function PrintTest(Receipt_ID) {


            var url = '/ReportViewer.aspx?ReportName=ReceiptbasePrint&ReportTitle=Cash  Receipt ' + '&Receipt_ID=' + Receipt_ID;
            //var url = '../../ReportViewer.aspx?ReportName=PrinAllReceiptDetail&ReportTitle=Bill Detail (IPD)  ' + '&PatientID=' + Receipt_ID;
            window.open(url, '_blank');

        }

        function LoadPage() {
            $("#tblResult").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                buttons: [
                    {
                        text: 'Add',
                        className: 'dt-button buttons-copy buttons-html5',
                        action: function () {
                            window.location = 'Receipts.aspx';
                        }
                    },
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
                    { "data": "Receipt_No", "name": "Receipt_No", "width": "6%", "orderable": true },
                    {
                        "data": "Receipt_Date", "name": "Receipt_Date",
                        "render": function (data, type, full) {
                            debugger;
                            var date = full.Receipt_Date;
                            date = moment(date).format('DD-MMM-YYYY');
                            return date;
                        }, "width": "8%", "orderable": true
                    },
                    { "data": "Remarks", "width": "17%", "orderable": false },
                    { "data": "Receipt_Amount", "width": "8%", "orderable": false },

                    { "data": "mr_no_sequence", "width": "10%", "orderable": false },
                    { "data": "Full_Name", "width": "12%", "orderable": false },            
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
                        "data": "Cancel_Remarks",
                        "width": "8%",
                        "orderable": false,
                        "render": function (data, type, full) {
                            if (full.isCancel === true || full.isCancel === 1) {
                                if (data && data.trim() !== '') {
                                    return data;
                                }
                                return 'Cancelled';
                            }
                            return data || '';
                        }
                    },
                    { "data": "isCancel", "visible": false, "orderable": false },
                    {
                        render: function (data, type, full) {
                            var res = '<a href="#" class="editListBtn" onclick="editOpen(' + full.Receipt_ID + ')" style="border-radius: 4px;color: white; padding: 5px 8px;"><i class="fa fa-pencil"></i></a>';

                            var Del = '<a class="delListBtn" href="#" style="border-radius: 4px;margin-left: 4px; color: white; padding: 5px 8px;" onclick="cancelPatient(' + full.Receipt_ID + ', \'' + full.Receipt_No + '\')"><i class="fa fa-trash"></i></a>';

                            var print = '<a class="printListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px;" href="#" onclick="PrintTest(' + full.Receipt_ID + ')"><i class="fa fa-print"></i></a>';

                            return res + Del + print;
                        }, "width": "10%", "orderable": false
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
                },
                createdRow: function (row, data, dataIndex) {
                    if (data.isCancel == 1) {
                        $(row).addClass('cancelled-row');
                    } else {
                        $(row).removeClass('cancelled-row');
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
        function cancelPatient(Receipt_ID, Receipt_No) {
            Swal.fire({
                icon: 'warning',
                title: 'Are you sure?',
                text: 'Do you want to cancel this Receipt: ' + Receipt_No + ' ?',
                showCancelButton: true,
                confirmButtonText: 'Yes, Cancel',
                cancelButtonText: 'No',
                customClass: {
                    popup: 'swal-big-popup',
                    title: 'swal-big-title',
                    htmlContainer: 'swal-big-text'
                }
            }).then((result) => {
                if (result.isConfirmed) {

                    Swal.fire({
                        title: 'Enter Reason (optional)',
                        input: 'text',
                        inputPlaceholder: 'Enter reason...',
                        showCancelButton: true,
                        confirmButtonText: 'Submit',
                        cancelButtonText: 'Skip',
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    }).then((reasonResult) => {

                        var reason = reasonResult.isDismissed ? "" : (reasonResult.value || "");

                        PageMethods.CancelPatient(Receipt_ID, reason, function (msg) {
                            if (msg === "Allowdlt") {
                                Swal.fire({
                                    icon: 'error',
                                    title: 'Error!',
                                    text: 'You have no right to Cancel.',
                                    showConfirmButton: false,
                                    timer: 2000,
                                    customClass: {
                                        popup: 'swal-big-popup',
                                        title: 'swal-big-title',
                                        htmlContainer: 'swal-big-text'
                                    }
                                });
                            } else if (msg === "success") {
                                var table = $('#tblResult').DataTable();
                                table.rows(function (idx, data, node) {
                                    return data.Receipt_ID == Receipt_ID;
                                }).remove().draw(false);

                                Swal.fire({
                                    icon: 'success',
                                    title: 'Success!',
                                    text: 'Receipt cancelled successfully.',
                                    showConfirmButton: false,
                                    timer: 2000,
                                    customClass: {
                                        popup: 'swal-big-popup',
                                        title: 'swal-big-title',
                                        htmlContainer: 'swal-big-text'
                                    }
                                });
                            } else {
                                Swal.fire({
                                    icon: 'error',
                                    title: 'Error!',
                                    text: 'Error in Cancel Receipt: ' + msg,
                                    showConfirmButton: false,
                                    timer: 2000,
                                    customClass: {
                                        popup: 'swal-big-popup',
                                        title: 'swal-big-title',
                                        htmlContainer: 'swal-big-text'
                                    }
                                });
                            }
                        }, function (error) {
                            Swal.fire({
                                icon: 'error',
                                title: 'Error!',
                                text: 'An error occurred while canceling the receipt.',
                                showConfirmButton: false,
                                timer: 2000,
                                customClass: {
                                    popup: 'swal-big-popup',
                                    title: 'swal-big-title',
                                    htmlContainer: 'swal-big-text'
                                }
                            });
                        });
                    });
                }
            });
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
        <div class="row">
            <div class="table-container">
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
                            <th>Cancel Remarks</th>
                            <th style="display:none">Cancel</th>
                            <th>Actions</th>                                                      
                        </tr>
                    </thead>
                    <tbody id="ibody">
                    </tbody>
                </table>
            </div>
        </div>
</asp:Content>
