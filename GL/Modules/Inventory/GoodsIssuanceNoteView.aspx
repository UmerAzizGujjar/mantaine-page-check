<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="GoodsIssuanceNoteView.aspx.cs" Inherits="PMS.GoodsIssuanceNoteView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
     <link href="../../wwwroot/IITH_Theme/css/tablestyle.css" rel="stylesheet" />

    <script type="text/javascript">
        $(document).ready(function () {
            $('#ctl00_lblMessage').hide();
            LoadPage();

        });


        function PrintReport(ID) {
            var locationInfo = window.location;
            var url = '/ReportViewer.aspx?ReportName=StoreIssueBasePrint&ReportTitle=Store Issue Note&SI_ID=' + ID;
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + '/ReportViewer.aspx?ReportName=StoreIssueBasePrint&ReportTitle=Store Issue Note&SI_ID=' + ID;
            }
            window.open(url, '_blank');
        }

        function Edit(ID) {
            window.location.href = "GoodsIssuanceNote.aspx?SI_ID=" + ID;
        }

        function redirecttonew() {
            window.location.href = "GoodsIssuanceNote.aspx";
        }

        function LoadPage() {
            $("#example").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": ['copy', 'excel', 'pdf'],
                "filter": true,
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "GoodsIssuanceNoteView.aspx/ViewList",
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
                    { "data": "Store_Issue_Id", visible: false },
                    { "data": "Store_Issue_No", "name": "Store_Issue_No", "orderable": true },
                    {
                        "data": "Created_Time",
                        "render": function (data, type, full) {
                            var date = full.Created_Time;
                            date = moment(date).format('D-MMM-YYYY');
                            return date;
                        }, "name": "Created_Time", "orderable": true
                    },
                    { "data": "Department", "orderable": false },
                    { "data": "WareHouse", "orderable": false },
                    { "data": "Requester", "orderable": false },
                    { "data": "Issuer", "orderable": false },
                    { "data": "Status", "orderable": false },
                    {
                        "render": function (data, type, full) {
                            var res = '<a href="#"  class="editListBtn" onclick="Edit(' + full.Store_Issue_Id + ')" style="border-radius: 4px;margin-right: 4px; color: white; padding: 5px 8px 5px 8px;"><i style="color:white !important;" class="fa fa-pencil"></i></a>';
                            var print = '<a style="border-radius: 4px;background-color:#387024;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="PrintReport(' + full.Store_Issue_Id + ')" id="btnprint"><i class="fa fa-print" style="color:white !important;"></i></a>';
                            var result;
                            if (full.Status == "Approved") {
                                result = res + print;
                            } else {
                                result = res + print;
                            }
                            return result;
                        }, "orderable": false
                    }
                ],
                "rowCallback": function (row, data, index) {
                    if (data.Status === "Approved") {
                        $(row).css('background-color', '#ABEBC6');
                    }
                },
                "initComplete": function (settings, json) {
                    var lengthContainer = document.querySelector('#example_length');
                    var lengthDropdown = document.querySelector('#example_length select');
                    var label = document.querySelector('#example_length label');

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
        <div class="col-lg-2 col-md-4 col-sm-12">
            <input type="button" onclick="redirecttonew()" value="Add New" class="btn btn-primry" style="text-align: center;margin-bottom: 1% !important" />
        </div>
    </div>
    <div class="table-container">
        <table id="example" class="table table-hover table-bordered" style="width: 100%">
            <thead>
                <tr>
                    <th>Store Issue#</th>
                    <th>Store Issue#</th>
                    <th>Date</th>
                    <th>Department</th>
                    <th>WareHouse</th>
                    <th>Request BY</th>
                    <th>Issue BY</th>
                    <th>Status</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody id="tblbody">
            </tbody>
        </table>
    </div>
</asp:Content>
