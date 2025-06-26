<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="StudentReceiptView.aspx.cs" Inherits="PMS.Modules.StudentAffair.StudentReceiptView" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
     <link href="../../wwwroot/Tibbit_theme/css/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">

        $(document).ready(function () {
            $('#ctl00_lblMessage').hide();
            LoadPage();

        });


        function Edit(ID, StuID) {
            debugger;
            window.location.href = "StudentReceipt.aspx?Stu_RecptID=" + ID + "&Stu_ID=" + StuID;

        }
               
               function LoadPage() {
                 $("#tbl").DataTable({
                     "processing": true,
                     "serverSide": true,
                     "dom": 'lBfrtip',
                     "lengthChange": true,
                     "buttons": ['copy', 'excel', 'pdf'],
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
                         { "data": "Student_ID","name":"Student_ID", "width": "10%", "orderable": true },
                         { "data": "Status", "width": "10%", "orderable": false },
                         { "data": "RollNo", "width": "10%", "orderable": false },
                         { "data": "Balance", "width": "10%", "orderable": false },
                         { "data": "Remarks", "width": "10%", "orderable": false },
                         {
                             render: function (data, type, full) {
                                 debugger;
                                 var res = '<a class="editListBtn" href="#" onclick="Edit(' + full.Student_Receipt_ID + ', ' + full.Student_ID + ')" style="border-radius: 4px;  color: white; padding: 5px 8px; text-decoration: none; display: inline-block;"><i class="fa fa-pencil" style="color:white !important;"></i></a>';
                                 var Del = '<a href="#" style="border-radius: 4px; background-color: #ad170c;margin-left: 4px; color: white; padding: 5px 8px;" onclick="cancelReceipt(' + full.Student_Receipt_ID + ')"><i class="fa fa-trash"></i></a>';

                                 var result;
                                 result = res + Del;
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
                        <th>Student_ID</th>
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
