<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="RadiologyAcknolgment.aspx.cs" Inherits="PMS.RadiologyAcknolgment" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">     
    <link href="../../wwwroot/Tibbit_theme/css/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">
        $(document).ready(function () {
            loadRadiologyAcknowledgment();
        });
        function loadRadiologyAcknowledgment() {

            var table = $("#tblradilogy").DataTable({
                "processing": true,
                "serverSide": true,
                "destroy": true, 
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": [{
                    text: 'Save',
                    className: 'dt-button buttons-copy buttons-html5',
                    action: function () {
                        SaveData();
                    }
                }, 'copy', 'excel', 'pdf'],
                "ajax": function (data, callback, settings) {

                    $.ajax({
                        type: "POST",
                        url: "RadiologyAcknolgment.aspx/GetRadiologyAcknowledgment",
                        data: JSON.stringify({
                            draw: data.draw,
                            start: data.start,
                            length: data.length,
                            sortColumn: data.columns[data.order[0].column].name,
                            sortDirection: data.order[0].dir,
                            searchValue: data.search.value
                        }),
                        contentType: "application/json; charset=utf-8",
                        success: function (response) {

                            callback({
                                draw: response.d.draw,
                                recordsTotal: response.d.recordsTotal,
                                recordsFiltered: response.d.recordsFiltered,
                                data: response.d.data
                            });
                        },
                        error: function (xhr) {
                            console.log(xhr.responseText);
                        }
                    });
                },

                "columns": [
                    {
                        "data": "Bill_ID",
                        "orderable": false,
                        "render": function (data) {
                            return `<input type="checkbox" class="rowSelect" value="${data}">`;
                        }
                    },
                    {
                        "data": "Bill_Date", "name": "Bill_Date",
                        "render": function (data) {
                            return moment(data).format("DD-MMM-YYYY hh:mm A");
                        }
                    },
                    { "data": "Bill_No", "name": "Bill_No" },
                    { "data": "Full_Name" },
                    { "data": "Item_Name" },
                    { "data": "Department" },
                    {
                        "data": null,
                        "render": function () {
                            return `
                        <select class="form-control" name="status">
                            <option value="Low">Low</option>
                            <option value="Medium">Medium</option>
                            <option value="High">High</option>
                        </select>
                    `;
                        }
                    },
                    { "data": "Lab_Test_Detail_ID", "name": "Lab_Test_Detail_ID","visible": false }
                ]
            });

        }
        function SaveData() {
            debugger;
            var tableDT = $("#tblradilogy").DataTable();
            var Testlist = [];
            var isChkZero = true;

            $('#tblradilogy tbody input.rowSelect:checked').each(function () {

                isChkZero = false;

                var row = $(this).closest('tr');
                var rowData = tableDT.row(row).data();

                var status = row.find('select[name=status]').val();
                var Lab_Test_Detail_ID = rowData.Lab_Test_Detail_ID;

                Testlist.push({
                    'status': status,
                    'Lab_Test_Detail_ID': Lab_Test_Detail_ID
                });
            });

            if (isChkZero) {
                alert("Select Checkbox Which Test Do You Want To Acknowledge");
                return;
            }

            $.ajax({
                type: "POST",
                url: "RadiologyAcknolgment.aspx/SaveRecord",
                data: JSON.stringify({ "Testlist": Testlist }),
                contentType: "application/json; charset=utf-8",
                success: function () {
                    location.reload();
                }
            });
        }


    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
        <div class="row">
         <div class="col-lg-12 col-md-12 col-sm-12">
    <table style="width: 100%;">
        <tr>
            <td>
                <div id="POdetails" style="margin-top: 15px;">
                    <div>
                        <table class="table table-hover table-striped table-bordered" id="tblradilogy" style="overflow: scroll; height: auto;">
                            <thead id="ihead">
                                <tr>
                                    <th>Check</th>
                                    <th>Bill Date</th>
                                    <th>Bill No</th>
                                    <th>Name</th>
                                    <th>Test Name</th>
                                    <th>Department</th>
                                    <th>Priority</th>
                                    <th style='display: none;'>Lab Test Detail Id</th>

                                </tr>
                            </thead>
                            <tbody id="tbl_tbody_radiology">
                            </tbody>
                        </table>
                    </div>
                </div>
            </td>
        </tr>
    </table>
        </div>
        </div>
</asp:Content>
