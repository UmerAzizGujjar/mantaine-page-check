<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ComparativeStatementVendorView.aspx.cs" Inherits="PMS.AP.ComparativeStatementVendorView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
 <link href="../../wwwroot/Tibbit_theme/css/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">    
        $(document).ready(function () {
            LoadPage();
        });

        function Edit(ID) {
            window.location.href = "ComparativeStatementVendor.aspx?CM_ID=" + ID + "";
        }
        function AutoPO(ID) {
            debugger
            var CSID = ID;
            PageMethods.AutoPO(CSID, function (Tests) {
                debugger
                var message = JSON.parse(Tests);
                if (message[0].Column1 != "" || message[0].Column1 != null) {
                    location.reload();
                }
            });
        }
        function PrintTest(id) {
            window.open('ReportViewer.aspx?ReportName=TestDefination&ReportTitle= Test Defination&Test_IDs=' + id);
        }



        function LoadPage() {
            $("#tblResult").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": [{ text: 'Add', className: 'dt-button buttons-copy buttons-html5', action: function () { window.location = 'ComparativeStatementVendor.aspx'; } }, 'copy', 'excel', 'pdf'],
                "filter": true,
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "ComparativeStatementVendorView.aspx/ViewList",
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
                    { "data": "CSVENID", "visible": false },
                    { "data": "CSVENNO", "name": "CSVENNO", "orderable": true },
                    {
                        "data": "CSVENDATE",
                        "render": function (data, type, row) {
                            return moment(data).format('D-MMM-YYYY'); 
                        },
                        "width": "11%", "name": "CSVENDATE", "orderable": true
                    },
                    { "data": "CSVENVALIDITY", width: "10%", "orderable": false },
                    { "data": "CSVENREMARKS", "orderable": false },
                    { "data": "PoStatus", "orderable": false },
                    {
                        "render": function (data, type, row) {
                            debugger;
                            var btnPoVisible = '';
                            var res = '<a class="editListBtn" href="#" onclick="Edit(' + row.CSVENID + ')" ' + 'style="border-radius: 4px; margin-right: 4px;padding: 5px 8px;"><i ' + ' class="fa fa-pencil"></i></a>';
                            if (row.CSVENSTATUS == "Created") {
                                btnPoVisible = 'style="display:none;"';
                            }
                           
                            if (row.CSVENSTATUS == "Approved" && row.IsAuto == true) {
                                btnPoVisible = 'style="display:none;"';
                            }
                            if (row.CSVENSTATUS == "Cancelled") {
                                btnPoVisible = 'style="display:none;"';
                            }
                            var create = '<a href="#" class="editListBtn" onclick="AutoPO(' + row.CSVENID + ')" ' + btnPoVisible + ' style = "border-radius: 4px;width:100%;padding: 4px 11px 4px 11px;" id = "btnPo' + (row + 1) + '" > Create PO</a >';

                            var print = '<a class="printListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="PrintTest(' + row.CSVENID + ')" id="btnprint"><i class="fa fa-print"></i></a>';
                            var result;
                            result = res + create + print;
                            return result;
                        }, width: "14%", "orderable": false
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

     
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
      
    <div class="row">
    <div class="table-container">
                <table class="table table-responsive table-hover table-bordered" id="tblResult">
                    <thead>
                        <tr>
                            <th>CSID</th>
                            <th>CS#</th>
                            <th>CS Date</th>
                            <th>CS Validity</th>
                            <th>Remarks</th>
                            <th>Status</th>
                            <th>Action</th>                    
                        </tr>
                    </thead>
                    <tbody>
                    </tbody>
                </table>
    </div>
        </div>
</asp:Content>
