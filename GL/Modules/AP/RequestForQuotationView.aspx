<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="RequestForQuotationView.aspx.cs" Inherits="PMS.AP.RequestForQuotationView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
   <link href="../../wwwroot/Tibbit_theme/css/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">
        $(document).ready(function () {
            $('#ctl00_lblMessage').hide();
            LoadPage();
        });

        function Edit(ID) {
            window.location.href = "RequestForQuotation.aspx?RFQ_ID=" + ID;
        }


        function Print(id) {
            debugger;
            if (id != '' && id != null && id != undefined) {
                PageMethods.GetVendorsforReports(id, function (Tests) {
                    debugger
                    var message = JSON.parse(Tests);
                    for (var i = 0; i < message.length; i++) {
                        debugger;
                        var locationInfo = window.location;

                        var user_name = '<% =AppConfig.Company_Name %>';
                        if (user_name == 'As-Siraat Serving Humanity') {
                            reportPath = '../../ReportViewer.aspx';
                        } else {
                            reportPath = 'ReportViewer.aspx'; // same folder
                        }


                        var url = '/ReportViewer.aspx?ReportName=RequestForQuotationList&ReportTitle=Request For Quotation&RFQid=' + id + '&Venderid=' + message[i].VendorId;
                        if (!locationInfo.origin.includes('localhost')) {
                            var urlInfo = window.location.href.split('/');
                            var ip = urlInfo[2];
                            var foldername = urlInfo[3];
                            url = 'http://' + ip + '/' + foldername + '/' + reportPath +  '?ReportName=RequestForQuotationList&ReportTitle=Request For Quotation&RFQid=' + id + '&Venderid=' + message[i].VendorId;
                        }
                        window.open(url, '_blank');
                    }
                })
            }
        }

        function deleteConfirm(RFQID) {
            debugger;
            if (confirm('Are you sure want to delete this record')) {
                PageMethods.DeleteRecord(RFQID, function (msg) {
                    location.reload();
                }, OnFail);
            }
        }

        function redirecttonew() {
            window.location.href = "RequestForQuotation.aspx";
        }



        function LoadPage() {
            let savedVisibility = null;

            $.ajax({
                type: "POST",
                url: "RequestForQuotationView.aspx/GetUserColumnPreferences",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                success: function (response) {
                    if (response.d && response.d !== "") {
                        try {
                            savedVisibility = JSON.parse(response.d);
                        } catch (e) {
                            console.warn("Invalid column visibility JSON");
                        }
                    }
                },
                error: function () {
                    console.error("Failed to load column preferences");
                }
            });
            $("#example").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": [{ text: 'Add', className: 'dt-button buttons-copy buttons-html5', action: function () { window.location = 'RequestForQuotation.aspx'; } }, 'copy', 'excel', 'pdf',
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
                        url: "RequestForQuotationView.aspx/ViewList",
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
                    { "data": "RFQID", "visible": false },
                    { "data": "RFQNo", "name": "RFQNo", "orderable": true },
                    {
                        "data": "Date", "name":"Date",
                        "render": function (data, type, full) {
                            var date = full.Date;
                            date = moment(date).format(' D-MMM-YYYY');
                            return date;
                        }, "orderable": true
                    },
                    { "data": "VendorName", "orderable": false },
                    { "data": "RefNo", "orderable": false },
                    { "data": "Remarks", "orderable": false },
                    { "data": "Status", "orderable": false },
                    {
                        "render": function (data, type, full) {
                            var res = '<a href="#" class="editListBtn" onclick="Edit(' + full.RFQID + ')" style="border-radius: 4px;margin-right: 4px;padding: 5px 8px 5px 8px;"><i class="fa fa-pencil"></i></a>'

                            var print = '<a class="printListBtn" style = "border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href = "#" onclick = "Print(' + full.RFQID + ')" id = "btnprint" ><i class="fa fa-print"></i></a >';
                            var result = res + print;
                            return result;
                        }, "orderable": false
                    }
                ],
                "initComplete": function (settings, json) {
                    const api = this.api();
                    if (savedVisibility && Array.isArray(savedVisibility)) {
                        if (savedVisibility.length === api.columns().count()) {
                            api.columns().every(function (index) {
                                this.visible(savedVisibility[index]);
                            });
                        }
                    }
                    api.on('column-visibility.dt', function (e, settings, column, state) {
                        let currentVis = [];
                        api.columns().every(function () {
                            currentVis.push(this.visible());
                        });
                        PageMethods.SaveUserColumnPreferences(
                            JSON.stringify(currentVis),
                            function () {
                                console.log("Column preferences saved");
                            },
                            function (error) {
                                console.error("Failed to save preferences:", error);
                            }
                        );
                    });

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
                    }
                }
            });
        }
        
        

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

      
            
                <table id="example"  class="table table-bordered table-hover">
                    <thead>
                        <tr>
                            <th style="display: none">RFQ ID</th>
                            <th>RFQ Num</th>
                            <th>RFQ Date</th>
                            <th>Vendor Name</th>
                            <th>Ref No</th>
                            <th>Remarks</th>
                            <th>Status</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody id="tblbody">
                    </tbody>
                </table>
            </div>
        </div>
    


</asp:Content>
