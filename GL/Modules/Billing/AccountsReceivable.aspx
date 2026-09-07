<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AccountsReceivable.aspx.cs" Inherits="PMS.Modules.Billing.AccountsReceivable" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />
    <style type="text/css">
        .no-skin .nav-list > li .submenu > li > a {
            font-size: 14px !important;
        }

        #Table_1 { width: 100% !important; }

        #Table_1_wrapper .dataTables_filter label::before {
            content: none !important;
        }

        .total-badge {
            background-color: #EFA63E;
            color: #fff;
            padding: 8px 20px;
            border-radius: 6px;
            font-weight: 700;
            font-size: 16px;
            display: inline-block;
        }

        .total-badge .total-amount {
            font-weight: 800;
            font-size: 18px;
        }

        .editListBtn {
            background-color: #EFA63E;
            color: #fff !important;
            padding: 4px 10px;
            border-radius: 4px;
            font-size: 13px;
            text-decoration: none;
            display: inline-block;
        }

        .editListBtn:hover {
            background-color: #333;
            color: #fff !important;
            text-decoration: none;
        }
    </style>

    <script type="text/javascript">
        var oTable;

        $(document).ready(function () {
            LoadPage();
        });

        function OpenList(type, name) {
            window.open("AccountsReceivableDetail.aspx?Type=" + type + "&Name=" + encodeURIComponent(name));
        }

        function calculateall() {
            var totalamt = 0;
            $('#Table_1 tbody tr').each(function () {
                var amt = $(this).find('input[name=txtamount]').val();
                totalamt += parseFloat(amt) || 0;
            });
            $('#totalamt').text(totalamt.toLocaleString('en'));
        }

        function LoadPage() {
            $.ajax({
                async: false,
                type: "POST",
                url: "AccountsReceivable.aspx/ViewList",
                data: JSON.stringify({}),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    if (data != '') {
                        var data = JSON.parse(data.d);

                        if (oTable) {
                            oTable.destroy();
                            $('#Table_1 tbody').empty();
                        }

                        var rows = '';
                        $.each(data, function (i, item) {
                            var bl = parseFloat(item.Balance) || 0;
                            rows += '<tr>' +
                                '<td style="display:none;"><input type="hidden" value="' + item.Type_Code + '" name="TypeID"></td>' +
                                '<td>' + (i + 1) + '</td>' +
                                '<td style="display:none;"><input type="hidden" value="' + bl + '" name="txtamount"></td>' +
                                '<td>' + item.Name + '</td>' +
                                '<td>' + (item.Row_Count || 0) + '</td>' +
                                '<td style="text-align:right;">' + bl.toLocaleString('en') + '</td>' +
                                '<td style="text-align:center;"><a class="editListBtn" href="#" onclick="OpenList(\'' + item.Type_Code + '\',\'' + item.Name.replace(/'/g, "\\'") + '\')"><i class="fa fa-eye"></i> Detail</a></td>' +
                                '</tr>';
                        });
                        $('#Table_1 #tblbody').append(rows);

                        oTable = $('#Table_1').DataTable({
                            "dom": 'lBfrtip',
                            "buttons": [
                                'copy', 'excel', 'pdf',
                                {
                                    extend: 'colvis',
                                    text: '<i class="fa fa-columns"></i> Columns',
                                    className: 'dt-button buttons-colvis',
                                    collectionLayout: 'fixed two-column',
                                    postfixButtons: ['colvisRestore']
                                }
                            ],
                            "columnDefs": [
                                { "targets": 0, "visible": false, "searchable": false },
                                { "targets": 1, "width": "8%", "className": "text-center" },
                                { "targets": 2, "visible": false, "searchable": false },
                                { "targets": 3, "width": "35%" },
                                { "targets": 4, "width": "12%", "className": "text-center" },
                                { "targets": 5, "width": "25%", "className": "text-right" },
                                { "targets": 6, "width": "12%", "orderable": false, "className": "text-center" }
                            ],
                            "paging": true,
                            "pageLength": 25,
                            "ordering": true,
                            "order": [[3, 'asc']],
                            "language": {
                                "search": "",
                                "searchPlaceholder": "Search..."
                            },
                            "initComplete": function (settings, json) {
                                var lengthContainer = document.querySelector('#Table_1_length');
                                var lengthDropdown = document.querySelector('#Table_1_length select');
                                var label = document.querySelector('#Table_1_length label');
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
                            },
                            "drawCallback": function () {
                                calculateall();
                            }
                        });

                        calculateall();
                    }
                }
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row" style="margin-bottom:15px;align-items:center;">
        <div class="col-md-3">
            <label style="font-weight:600;font-size:16px;color:#555;">OPD Hospital Share Receivable</label>
        </div>
        <div class="col-md-6"></div>
        <div class="col-md-3 text-right">
            <span class="total-badge">
                Total Receivable: <span class="total-amount" id="totalamt">0</span>
            </span>
        </div>
    </div>

    <div class="row">
        <div class="col-lg-12" style="overflow-x:auto;">
            <table id="Table_1" class="table table-hover table-striped table-bordered" style="width:100%;">
                <thead>
                    <tr>
                        <th style="display:none;">TypeID</th>
                        <th>Sr No</th>
                        <th style="display:none;">Balance</th>
                        <th>Receivable Type</th>
                        <th>Slips</th>
                        <th>Amount</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody id="tblbody">
                </tbody>
            </table>
        </div>
    </div>
</asp:Content>
