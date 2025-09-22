<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="StudentReceiptView.aspx.cs" Inherits="PMS.Modules.StudentAffair.StudentReceiptView" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
     <link href="../../wwwroot/Tibbit_theme/css/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">

        $(document).ready(function () {
            $('#ctl00_lblMessage').hide();
            LoadPage();

        });
        function PrintTest(id) {
            window.open('ReportViewer.aspx?ReportName=TestDefination&ReportTitle= Test Defination&Test_IDs=' + id);
        }

        function Edit(ID, StuID) {
            debugger;
            window.location.href = "StudentReceipt.aspx?Stu_RecptID=" + ID + "&Stu_ID=" + StuID;

        }

        function PrintVoucher(Student_Receipt_ID) {
            debugger
            var locationInfo = window.location;
            var url = '/ReportViewer.aspx?ReportName=Voucher&ReportTitle=SRV Voucher&TransID=' + Student_Receipt_ID + '&TransType=SRV';
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + '/ReportViewer.aspx?ReportName=Voucher&ReportTitle=SRV Voucher&TransID=' + Student_Receipt_ID + '&TransType=SRV';
            }
            //  window.location.href = url;
            window.open(url, '_blank');

        }
               
               function LoadPage() {
                 $("#tbl").DataTable({
                     "processing": true,
                     "serverSide": true,
                     "dom": 'lBfrtip',
                     "lengthChange": true,
                     "buttons": [{ text: 'Add', className: 'dt-button buttons-copy buttons-html5', action: function () { window.location = 'StudentReceipt.aspx'; } }, 'copy', 'excel', 'pdf'],
                     "filter": true,
                     "ajax": function (data, callback, settings) {
                         $.ajax({
                             type: "POST",
                             url: "StudentReceiptView.aspx/ViewList",
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
                         { "data": "Student_Receipt_ID", "visible": false, "width": "0%" },
                         { "data": "Student_Receipt_No", "name":"Student_Receipt_No", "width": "10%", "orderable": true },
                         {
                             "data": "Student_Receipt_Date", "name": "Student_Receipt_Date",
                             "render": function (data, type, full) {
                                 debugger;
                                 var date = full.Student_Receipt_Date;
                                 date = moment(date).format('DD-MMM-YYYY');
                                 return date;
                             }, "width": "15%", "orderable": false
                         },
                         { "data": "Full_Name", "name":"Full_Name", "width": "10%", "orderable": true },
                         { "data": "Class", "name":"Class", "width": "10%", },
                         { "data": "Status", "width": "10%", "orderable": false },
                         { "data": "RollNo", "width": "10%", "orderable": false },
                         { "data": "Balance", "width": "10%", "orderable": false },
                         { "data": "Remarks", "width": "10%", "orderable": false },
                         {
                             render: function (data, type, full) {
                                 debugger;
                                 var res = '<a class="editListBtn" href="#" onclick="Edit(' + full.Student_Receipt_ID + ', ' + full.Student_ID + ')" style="border-radius: 4px;  color: white; padding: 5px 8px; text-decoration: none; display: inline-block;"><i class="fa fa-pencil" style="color:white !important;"></i></a>';
                                 var Del = '<a href="#" style="border-radius: 4px; background-color: #ad170c;margin-left: 4px; color: white; padding: 5px 8px;" onclick="cancelReceipt(' + full.Student_Receipt_ID + ')"><i class="fa fa-trash"></i></a>';
                                 var print = '<a style="border-radius: 4px;background-color:#387024;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="PrintVoucher(' + full.Student_Receipt_ID + ')" id="btnprint"><i class="fa fa-print" style="color:white !important;"></i></a>';
                                 var result;
                                 result = res + Del + print;
                                 return result;
                             }, "width": "10%", "orderable": false
                         }
                     ],
                     "initComplete": function (settings, json) {
                         var lengthContainer = document.querySelector('#tbl_length');
                         var lengthDropdown = document.querySelector('#tbl_length select');
                         var label = document.querySelector('#tbl_length label');

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


        function cancelReceipt(ReceiptId) {
            debugger;
            if (confirm("Are you sure you want to cancel this Receipt?")) {
                $.ajax({
                    type: "POST",
                    url: "StudentReceiptView.aspx/CancelReceipt",
                    data: JSON.stringify({ ReceiptId: ReceiptId }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        if (response.d) {
                            alert("Receipt cancelled successfully!");
                            $('#tbl').DataTable().ajax.reload();
                        } else {
                            alert("Failed to cancel the Receipt.");
                        }
                    },
                    error: function (xhr, status, error) {
                        console.log(xhr.responseText);
                    }
                });
            }
        }


    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
        <div class="table-container">
            <table id="tbl" class="table table-bordered table-hover table-striped">
                <thead id="ihead">
                    <tr>
                        <th style="display: none;">Student_Receipt_ID</th>
                        <th>Receipt No</th>
                        <th>Receipt Date</th>
                        <th>Student Name</th>
                        <th>Class</th>
                        <th>Status</th>
                        <th>Roll No</th>
                        <th>Balance</th>
                        <th>Remarks</th>
                        <th>View</th>
                    </tr>
                </thead>
                <tbody id="tbody">
                </tbody>
            </table>
        </div>
    </div>


</asp:Content>
