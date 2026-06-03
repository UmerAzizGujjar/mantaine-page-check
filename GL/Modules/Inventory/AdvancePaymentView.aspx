<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AdvancePaymentView.aspx.cs" Inherits="PMS.Inventory.AdvancePaymentView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">
        function OnFail(exc) {
            alert(exc.get_message());
        }
        function Edit(ID) {
            window.location.href = "AdvancePayment.aspx?Adv_ID=" + ID;
        }
        function isDeleteAllow() {
            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: "AdvancePaymentView.aspx/isDeleteAllow",
                data: "",
                success: function (resp) {
                    debugger;
                    if (resp.d == true) {
                        isDele = true;
                    }
                    else {
                        isDele = false;
                    }
                }, error: function () { }
            })
        }

        function Print(Advance_ID) {
            var locationInfo = window.location;
            var user_name = '<% =AppConfig.Company_Name %>';
            if (user_name == 'As-Siraat Serving Humanity') {
                reportPath = '../../ReportViewer.aspx';
            } else {
                reportPath = 'ReportViewer.aspx'; // same folder
            }
            var url = '/ReportViewer.aspx?ReportName=Advance_Base_Print&ReportTitle=Advance Payment &Adv_ID=' + Advance_ID;
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];

                url = 'http://' + ip + '/' + foldername + '/' + reportPath +  '?ReportName=Advance_Base_Print&ReportTitle=Advance Payment &Adv_ID=' + Advance_ID;
            }
            window.open(url, '_blank');
        }
        function deleteConfirm(anchorTag) {
            debugger;
            var row = $(anchorTag).parents('tr')[0];
            var AdvID = $($(row).find('td')[0]).text();
            if (confirm('Are you sure want to delete this record')) {
                PageMethods.DeleteRecord(AdvID, function (msg) {
                    debugger
                    $(row).remove();
                }, OnFail);
            }
        }

        $(document).ready(function () {
            LoadPage();
        });



        function LoadPage() {
            let savedVisibility = null;

            $.ajax({
                type: "POST",
                url: "AdvancePaymentView.aspx/GetUserColumnPreferences",
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
                "buttons": [{ text: 'Add', className: 'dt-button buttons-copy buttons-html5', action: function () { window.location = 'AdvancePayment.aspx'; } }, 'copy', 'excel', 'pdf',
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
                        url: "AdvancePaymentView.aspx/ViewList",
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
                    { "data": "Advance_ID", "visible": false, "width": "0%" },
                    { "data": "advance_no", "name":"advance_no" },
                    {
                        "data": "date",
                        "render": function (data, type, full) {
                            var date = full.date;
                            date = moment(date).format('D-MMM-YYYY');
                            return date;
                        }
                    },
                    { "data": "refer_no" },
                    { "data": "VendorName" },
                    { "data": "advance_amount" },
                    { "data": "remarks" },
                    { "data": "status" },
                    {
                        "render": function (data, type, full) {
                            var res = '<a href="#" class="editListBtn" onclick="Edit(' + full.Advance_ID + ')" style="border-radius: 4px;margin-right: 4px;  color: white; padding: 5px 8px 5px 8px;"><i class="fa fa-pencil"></i></a>';

                            var print = '<a class="printListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="Print(' + full.Advance_ID + ')" id="btnprint"><i class="fa fa-print" ></i></a>';
                          

                            var result = res + print;
                            return result;
                        }
                    }
                ],
                "rowCallback": function (row, data, index) {
                    if (data.status === "Approved") {
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
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div id="PurchaseRequistiondetails">
        <div class="table-container">
            <table class="table table-hover table-bordered" id="tblResult">
                <thead id="ihead">
                    <tr>
                        <th>Advance ID</th>
                        <th>Advance #</th>
                        <th>Date</th>
                        <th>Refer #</th>
                        <th>Vendor Name</th>
                        <th>Advance Amount</th>
                        <th>Remarks</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody id="ibody">
                </tbody>
            </table>
        </div>
    </div>
</asp:Content>
