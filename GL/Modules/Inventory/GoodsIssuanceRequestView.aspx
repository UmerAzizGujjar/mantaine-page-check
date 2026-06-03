<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="GoodsIssuanceRequestView.aspx.cs" Inherits="PMS.Inventory.GoodsIssuanceRequestView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <script type="text/javascript">
        $(document).ready(function () {
            $('#ctl00_lblMessage').hide();
            LoadPage();

        });


        function Print(id) {
            debugger;
            var locationInfo = window.location;


            var user_name = '<% =AppConfig.Company_Name %>';
            if (user_name == 'As-Siraat Serving Humanity') {
                reportPath = '../../ReportViewer.aspx';
            } else {
                reportPath = 'ReportViewer.aspx'; // same folder
            }

            var url = '/ReportViewer.aspx?ReportName=MaterialIssueRequestList&ReportTitle=Material IssueRequest List&MIRId=' + id;
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];

                url = 'http://' + ip + '/' + foldername + '/' + reportPath +  '?ReportName=MaterialIssueRequestList&ReportTitle=Material IssueRequest List&MIRId=' + id;
            }
            window.open(url, '_blank');
        }

        function Edit(ID) {
            window.location.href = "GoodsIssuanceRequest.aspx?ID=" + ID;

        }

        function LoadPage() {
            let savedVisibility = null;

            $.ajax({
                type: "POST",
                url: "GoodsIssuanceRequestView.aspx/GetUserColumnPreferences",
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


            $("#tblResult").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": [{ text: 'Add', className: 'dt-button buttons-copy buttons-html5', action: function () { window.location = 'GoodsIssuanceRequest.aspx'; } }, 'copy', 'excel', 'pdf',
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
                        url: "GoodsIssuanceRequestView.aspx/ViewList",
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
                    { "data": "MaterialRequest_Id", "visible": false, },
                    { "data": "Request_No", "name": "Request_No", "orderable": true },
                    {
                        "data": "Priority",
                        "render": function (data, type, full) {
                            var Priority = full.Priority;
                            if (Priority == 1) {
                                Priority = "High";
                            } else {
                                Priority = "Low";
                            }
                            return Priority;
                        }, "orderable": true
                    },
                    { "data": "Department", "orderable": false },
                    { "data": "Remarks", "orderable": false },
                    { "data": "Closing_Remarks", "orderable": false },
                    {
                        "data": "CreatedBY",
                        "createdCell": function (td, cellData, rowData, row, col) {
                            $(td).css('text-align', 'left');
                        }, "orderable": false
                    },
                    { "data": "Status", "orderable": false },
                    {
                        "data": "Creation_Date", "name": "Creation_Date",
                        "render": (data, type, full) => moment(full.Creation_Date).format('DD-MMM-YYYY hh:mm A'),
                        "width": "12%"
                    },
                    {
                        "data": "Approved_Time", "name": "Approved_Time",
                        "render": (data, type, full) => full.Approved_Time ? moment(full.Approved_Time).format('DD-MMM-YYYY hh:mm A') : '',
                        "width": "12%"
                    },
                    {
                        "render": function (data, type, full) {
                            var res = ' <a href="#"  class="editListBtn" onclick="Edit(' + full.MaterialRequest_Id + ')" style="border-radius: 4px;margin-right: 4px; color: white; padding: 5px 8px 5px 8px;"><i class="fa fa-pencil"></i>';
                            var print = '<a class="printListBtn" style ="border-radius: 4px;margin-left: 4px;padding: 5px 8px 5px 8px;" href = "#" onclick = "Print(' + full.MaterialRequest_Id + ')" id = "btnprint" ><i class="fa fa-print"></i></a >';

                            var result = res + print;
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
                    }
                }
            });
        }



    </script>

         
        <div class="table-container">
            <table class="table  table-hover table-bordered" style="width: 100%" id="tblResult">
                <thead id="ihead">
                    <tr>
                        <th>MaterialRequest_Id</th>
                        <th>Request_No</th>
                        <th>Pirority</th>
                        <th>Department</th>
                        <th>Remarks</th>
                        <th>Closing Remarks</th>
                        <th>Request BY</th>
                        <th>Status</th>
                        <th>Creation Date</th>
                        <th>Approved Date</th>
                        <th>Actions</th>
                    </tr>

                </thead>

                <tbody id="ibody">
                </tbody>
            </table>
        </div>
   

</asp:Content>
