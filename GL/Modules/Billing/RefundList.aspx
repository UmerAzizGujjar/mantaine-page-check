<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="RefundList.aspx.cs" Inherits="PMS.RefundList" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/css/tablestyle.css" rel="stylesheet" />
        <script type="text/javascript">
            $(document).ready(function () {
                $('#ctl00_lblMessage').hide();
                LoadPage();


            });
            function EditAdvance(advId) {
                debugger;
                window.open("Refund.aspx?advID=" + advId);
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
                    "buttons": ['copy', 'excel', 'pdf'],
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
                                var res = '<a href="#" onclick="EditAdvance(' + full.Refund_ID + ')" class="editListBtn" style="border-radius: 4px; color: white; padding: 5px 8px 5px 8px;"><i style="color:white !important;" class="fa fa-pencil"></i></a>'
                                var Del = '<a href="#" style="border-radius: 4px; background-color: #ad170c;margin-left: 4px; color: white; padding: 5px 8px 5px 8px;" onclick=deleteConfirm(this)><i class="fa fa-trash" aria-hidden="true"></i></a>';

                                var result;
                                result = res + Del;
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
    <div class="row">
    <div class="col-lg-2 col-md-4 col-sm-6" style="margin-bottom:1%">
        <input type="button" value="Add New" class="btn btn-primry"  onclick=" window.location.href = 'Refund.aspx'"  />
    </div>
    </div>

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
           

       