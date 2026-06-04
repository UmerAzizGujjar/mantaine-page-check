<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="BillingProcessView.aspx.cs" Inherits="PMS.BillingProcessView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/lib/sweetalert/tablestyle.css" rel="stylesheet" />
    <script src="https://cdn.datatables.net/buttons/2.4.2/js/buttons.colVis.min.js"></script>
    <style>
        .detail-container {
            padding: 15px;
        }

        .clickable-row {
            cursor: pointer;
        }

            .clickable-row:hover {
                background-color: #f0f8ff;
            }
    </style>
    <script type="text/javascript">
        $(document).ready(function () {
            debugger;
            $('#ctl00_lblMessage').hide();
            LoadPage();


        });


        function PrintBilling(Bill_ID) {
            var locationInfo = window.location;
            var user_name = '<%= AppConfig.Company_Name %>';
            var reportPath;  // ✅ declared properly

            if (user_name == 'As-Siraat Serving Humanity') {
                reportPath = '../../ReportViewer.aspx';
            } else {
                reportPath = 'ReportViewer.aspx';
            }

            var url;

            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + '/' + reportPath +
                    '?ReportName=BillingBaseReport&ReportTitle=Billing Base Report&Bill_ID=' + Bill_ID;  // ✅ was using undefined `id`
            } else {
                url = '/' + reportPath +
                    '?ReportName=BillingBaseReport&ReportTitle=Billing Base Report&Bill_ID=' + Bill_ID;  // ✅ fixed localhost URL + uses reportPath
            }

            window.open(url, '_blank');
        }
        function PrintBilling1(Bill_ID) {
            var locationInfo = window.location;
            var user_name = '<%= AppConfig.Company_Name %>';
            var reportPath;  // ✅ declared properly

            if (user_name == 'As-Siraat Serving Humanity') {
                reportPath = '../../ReportViewer.aspx';
            } else {
                reportPath = 'ReportViewer.aspx';
            }

            var url;

            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + '/' + reportPath +
                    '?ReportName=BillingBaseReport_Thermal&ReportTitle=Billing Base Report&Bill_ID=' + Bill_ID;  // ✅ was using undefined `id`
            } else {
                url = '/' + reportPath +
                    '?ReportName=BillingBaseReport_Thermal&ReportTitle=Billing Base Report&Bill_ID=' + Bill_ID;  // ✅ fixed localhost URL + uses reportPath
            }

            window.open(url, '_blank');
        }

        ////////function PrintBilling2(Bill_ID) {
        ////////    var locationInfo = window.location;
        //////////////    //var user_name = '<%= AppConfig.Company_Name %>';
        //////    //var reportPath;  // ✅ declared properly

        //////    //var locationInfo = window.location;

        //////////////  //  var user_name = '<% =AppConfig.Company_Name %>';
        ////////    var reportPath;
        ////////    if (user_name == 'As-Siraat Serving Humanity') {
        ////////        reportPath = '../../ReportViewer.aspx';
        ////////    } else {
        ////////        reportPath = 'ReportViewer.aspx';
        ////////    }

        ////////    // Build URL — different report name based on whether doctorId is passed
        ////////    function buildUrl(doctorId) {
        ////////        var base;
        ////////        if (!locationInfo.origin.includes('localhost')) {
        ////////            var urlInfo = window.location.href.split('/');
        ////////            var ip = urlInfo[2];
        ////////            var foldername = urlInfo[3];
        ////////            base = 'http://' + ip + '/' + foldername + '/' + reportPath;
        ////////        } else {
        ////////            base = '/ReportViewer.aspx';
        ////////        }

        ////////        var reportName, reportTitle;

        ////////        if (doctorId != null) {
        ////////            // Doctor rows  → Consultant report
        ////////            reportName = 'BillingBaseReport_Consultant';
        ////////            reportTitle = 'Consultant%20Billing%20Report';
        ////////        } else {
        ////////            // No-doctor rows → Hospital Services report
        ////////            reportName = 'BillingBaseReport_Hospital_Services';
        ////////            reportTitle = 'Hospital%20Services%20Billing%20Report';
        ////////        }

        ////////        var url = base + '?ReportName=' + reportName
        ////////            + '&ReportTitle=' + reportTitle
        ////////            + '&Bill_ID=' + id;

        ////////        if (doctorId != null) {
        ////////            url += '&Doctor_ID=' + doctorId;
        ////////        }

        ////////        return url;

        ////////    }
        ////////    $.ajax({
        ////////        type: "POST",
        ////////        url: "BillingProcessView.aspx/GetDistinctDoctorsByBillId",
        ////////        data: JSON.stringify({ 'Bill_Id': id }),
        ////////        contentType: "application/json; charset=utf-8",
        ////////        dataType: "json",
        ////////        success: function (response) {
        ////////            debugger;
        ////////            var doctorIds = JSON.parse(response.d);

        ////////            // Step 2: Open Hospital Services report (no doctor = NULL/0 rows)
        ////////            setTimeout(function () {
        ////////                window.open(buildUrl(null), '_blank');
        ////////            }, 0);

        ////////            // Step 3: Open one Consultant report per distinct doctor
        ////////            $.each(doctorIds, function (index, item) {
        ////////                setTimeout(function () {
        ////////                    window.open(buildUrl(item.Doctor_ID), '_blank');
        ////////                }, (index + 1) * 700);
        ////////            });
        ////////        },
        ////////        error: function (err) {
        ////////            console.error("Failed to fetch doctor IDs", err);
        ////////            alert("Could not load doctor information for this bill.");
        ////////        }
        ////////    });
        ////////}
      
        function LoadPage() {
            let savedVisibility = null;

            $.ajax({
                type: "POST",
                url: "BillingProcessView.aspx/GetUserColumnPreferences",
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
            var table = $("#tbloutPatients").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                buttons: [
                    {
                        text: 'Add',
                        className: 'dt-button buttons-copy buttons-html5',
                        action: function () {
                            window.location = 'BillingProcess.aspx';
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
                        url: "BillingProcessView.aspx/ViewList",
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
                    { "data": "Bill_ID", "visible": false, "width": "0%" },
                    { "data": "Bill_No", "name": "Bill_No", "width": "5%", "orderable": true },
                    {
                        "data": "Bill_Date", "name": "Bill_Date",
                        "render": function (data, type, full) {
                            debugger;
                            var date = full.Bill_Date;
                            date = moment(date).format('DD-MMM-YYYY');
                            return date;
                        }, "width": "7%", "orderable": true
                    },
                    { "data": "MrNo", "name": "MrNo", "width": "8%", "orderable": true },
                    { "data": "Full_Name", "width": "13%", "orderable": false },
                    { "data": "Total_Amount", "width": "7%", "orderable": false },
                    { "data": "Discount_Percentage", "width": "8%", "orderable": false },
                    { "data": "Discount_Amount", "width": "8%", "orderable": false },
                    { "data": "Net_Amount", "width": "8%", "orderable": false },
                    { "data": "Received_Amount", "name": "Received_Amount", "width": "8%", "orderable": false },
                    { "data": "Balance_Amount", "width": "8%", "orderable": false },
                    { "data": "Operator", "width": "9%", "orderable": false },

                    {
                        render: function (data, type, full) {
                            debugger;
                            var res = '<a href="#" class="editListBtn" onclick="editOpen(' + full.Bill_ID + ')" style="border-radius: 4px;color: white; padding: 5px 8px 5px 8px;"><i class="fa fa-pencil"></i></a>'

                            var Del = '<a class="delListBtn" href="#" style="border-radius: 4px;margin-left: 4px; color: white; padding: 5px 8px 5px 8px;" onclick=cancelPatient(this)><i class="fa fa-trash" aria-hidden="true"></i></a>';

                            var print = '<a class="printListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="PrintBilling(' + full.Bill_ID + ')" id="btnprint"><i class="fa fa-print"></i></a>';
                            var print1 = '<a class="printListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="PrintBilling1(' + full.Bill_ID + ')" id="btnprint1"><i class="fa fa-print"></i></a>';
                            //var print2 = '<a class="printListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="PrintBilling2(' + full.Bill_ID + ')" id="btnprint2"><i class="fa fa-print"></i></a>';
                            var result;
                            result = res + Del + print + print1;
                            return result;
                            ;
                        }, "width": "23%", "orderable": false
                    }

                ],
                "createdRow": function (row, data, dataIndex) {
                    $(row).addClass('clickable-row');
                    $(row).attr('data-bill-id', data.Bill_ID);
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

                    var lengthContainer = document.querySelector('#tbloutPatients_length');
                    var lengthDropdown = document.querySelector('#tbloutPatients_length select');
                    var label = document.querySelector('#tbloutPatients_length label');

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

            $('#tbloutPatients tbody').on('click', 'tr.clickable-row', function (e) {
                if ($(e.target).closest('a,button,input').length > 0) {
                    return;
                }

                var tr = $(this);
                var row = table.row(tr);
                var billId = tr.attr('data-bill-id');

                if (row.child.isShown()) {
                    row.child.hide();
                    tr.removeClass('shown');
                } else {
                    table.rows().every(function () {
                        if (this.child.isShown()) {
                            this.child.hide();
                            $(this.node()).removeClass('shown');
                        }
                    });

                    row.child('<div style="padding:20px;text-align:center;">Loading...</div>').show();
                    tr.addClass('shown');
                    LoadBillDetails(billId, row);
                }
            });
        }

        function LoadBillDetails(billId, row) {
            $.ajax({
                type: "POST",
                url: "BillingProcessView.aspx/GetBillDetails",
                data: JSON.stringify({ billId: billId }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response.d) {
                        var details = JSON.parse(response.d);
                        var html = BuildDetailsHTML(details);
                        row.child(html).show();
                    }
                },
                error: function (xhr, status, error) {
                    row.child('<div style="padding:20px;color:red;">Error loading details</div>').show();
                    console.log(xhr.responseText);
                }
            });
        }

        function BuildDetailsHTML(details) {
            var html = '<div class="detail-container">';
            var categories = {
                'Services': [],
                'Lab Tests': [],
                'Radiology': [],
                'Pharmacy': [],
                'Consultation': [],
                'Other': []
            };

            details.forEach(function (item) {
                var category = 'Other';
                var itemType = (item.Item_Type || '').toLowerCase();

                if (itemType === 'service' || itemType === 'services') {
                    category = 'Services';
                } else if (itemType === 'test') {
                    if (item.Test_Main_Department === '001') {
                        category = 'Lab Tests';
                    } else {
                        category = 'Radiology';
                    }
                } else if (itemType === 'pharmacy') {
                    category = 'Pharmacy';
                } else if (itemType === 'consultation') {
                    category = 'Consultation';
                }

                categories[category].push(item);
            });

            html += '<table class="details-table" style="width: 100%; border-collapse: collapse; text-align: left; font-family: sans-serif;">';
            html += '<thead>';
            html += '<tr style="background-color: #f4f4f4; border-bottom: 2px solid #ddd;">';
            html += '<th style="padding: 10px; width: 70%;">Item Name</th>';
            html += '<th style="padding: 10px; width: 10%;">Amount</th>';
            html += '<th style="padding: 10px; width: 10%;">Discount</th>';
            html += '<th style="padding: 10px; width: 10%;">Net Amount</th>';
            html += '</tr>';
            html += '</thead>';
            html += '<tbody>';

            for (var cat in categories) {
                if (categories[cat].length > 0) {
                    html += '<tr style="background-color: #e9ecef;">';
                    html += '<td colspan="4" style="padding: 8px 10px; font-weight: bold;">' + cat + '</td>';
                    html += '</tr>';

                    categories[cat].forEach(function (item) {
                        var itemName = item.Item_Name || item.Description || 'N/A';
                        var amount = (item.Amount || 0).toFixed(2);
                        var discount = (item.Discount_Amount || 0).toFixed(2);
                        var net = (item.Net_Amount || 0).toFixed(2);

                        html += '<tr style="border-bottom: 1px solid #eee;">';
                        html += '<td style="padding: 10px;">' + itemName + '</td>';
                        html += '<td style="padding: 10px;">' + amount + '</td>';
                        html += '<td style="padding: 10px;">' + discount + '</td>';
                        html += '<td style="padding: 10px;">' + net + '</td>';
                        html += '</tr>';
                    });
                }
            }

            html += '</tbody>';
            html += '</table>';
            html += '</div>';
            return html;
        }


        function editOpen(id) {
            window.open("BillingProcess.aspx?Bill_ID=" + id + "");
        }
        function CancelConfirm(anchorTag) {

            debugger;

            var row = $(anchorTag).parents('tr')[0];
            var Bill_ID = $($(row).find('td')[0]).text();
            var BillNo = $($(row).find('td')[1]).text();

            $("#tbloutPatients tr").find('th:eq(14)').show();
            $("#tbloutPatients tr").find('td:eq(14)').show();
            cell = row.insertCell(-1);
            cell.innerHTML = '<span class="show" style="width:100px;"><input type="text" id="txtCancel" onchange="cancelPatient(this)"/></span>';

        }
        function cancelPatient(anchorTag) {
            debugger;

            var row = $(anchorTag).parents('tr')[0];
            var Bill_No = $($(row).find('td')[0]).text();
            if (confirm('Are you sure want to Cancel this Bill:- ' + Bill_No)) {
                PageMethods.CancelPatient(Bill_No, function (msg) {
                    if (msg == "Allowdlt") {
                        alert('You have no right to Cancel. ')

                    }
                    else if (msg == "success") {

                        row.remove();
                    }
                    else {
                        alert('Unable to Cancel this patient, because this patient has uncanceled Reciept ')
                    }

                },

                );
            }

            window.location.href = "BillingProcessView.aspx";
        }

        function deleteConfirm(anchorTag) {

            var row = $(anchorTag).parents('tr')[0];

            var Bill_ID = $($(row).find('td')[0]).text();

            if (confirm('Are you sure want to delete this record')) {
                PageMethods.DeleteRecord(Bill_ID, function (msg) {
                    if (msg == '')
                        row.remove();
                    else
                        alert(msg);
                }, OnFail);
            }
        }


    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
        <div class="table-container">
            <table class="table table-hover table-striped table-bordered" id="tbloutPatients">
                <thead id="ihead">
                    <tr>
                        <th class="hide">Bill ID</th>
                        <th>Bill No</th>
                        <th>Bill Date</th>
                        <th>MR No</th>
                        <th>Name</th>
                        <th>Total Amount</th>
                        <th>Discount Percentage</th>
                        <th>Discount Amount</th>
                        <th>Net Amount</th>
                        <th>Received Amount</th>
                        <th>Balance Amount</th>
                        <th>Operator</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody id="ibody">
                </tbody>
            </table>
        </div>
    </div>
</asp:Content>
