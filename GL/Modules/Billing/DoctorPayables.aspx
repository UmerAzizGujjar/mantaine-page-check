<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="DoctorPayables.aspx.cs" Inherits="PMS.Modules.Billing.DoctorPayables" %>



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

        .HRlink {
            text-decoration: underline !important;
            color: #EFA63E !important;
            font-weight: 600;
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

        .editListBtn.disabled {
            background-color: #ccc;
            color: #fff !important;
            cursor: not-allowed;
            opacity: 0.6;
            pointer-events: none;
        }
    </style>

    <script type="text/javascript">
        var oTable;
        var _editMode = "";

        $(document).ready(function () {
            $.ajax({
                type: "POST",
                url: "DoctorPayables.aspx/GetEditMode",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                success: function (msg) {
                    _editMode = (msg.d || "");
                },
                error: function () {
                    _editMode = "";
                }
            });
            LoadPage();
            loadDoc();
        });

        function OpenList(id) {
            if (_editMode === "02") {
                window.open("DoctorPayables_Services.aspx?ID=" + id);
            } else if (_editMode === "01") {
                window.open("DoctorPayableService_Standard.aspx?ID=" + id);
            }
        }

        function calculateall() {
            var totalamt = 0;
            $('#Table_1 tbody tr').each(function () {
                var txtamount = $(this).find('td input[name=txtamount]').val();
                totalamt += parseFloat(txtamount) || 0;
            });
            $('#totalamt').text(totalamt.toLocaleString('en'));
        }

        function loadDoc() {
            var optionsDepth = '';
            $.ajax({
                type: "post",
                url: "DoctorPayables.aspx/loadDoctors",
                dataType: 'JSON',
                contentType: "application/json; charset=utf-8",
                async: false,
                success: function (msg) {
                    optionsDepth = '<option value="0">Please Select</option>';
                    var data = JSON.parse(msg.d);
                    $.each(data, function (key, value) {
                        optionsDepth += '<option value="' + value.Emp_ID + '" >' + value.name + '</option>';
                    });
                    $('#ddlDoctor').html(optionsDepth);
                    $('#ddlDoctor').select2();
                },
            });
        }

        function testddlchange() {
            var Statusddl = $('#ddlDoctor').find('option:selected').text();
            if (!oTable) return;
            if (Statusddl == "Please Select") {
                oTable.column(3).search('').draw();
            } else {
                oTable.column(3).search(Statusddl).draw();
            }
            calculateall();
        }

        function LoadPage() {
            $.ajax({
                async: false,
                type: "POST",
                url: "DoctorPayables.aspx/ViewList",
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
                            var bl = data[i].Balance;
                            rows += '<tr>' +
                                '<td style="display:none;"><input type="hidden" value="' + data[i].Doctor_Id + '" name="DocID"></td>' +
                                '<td>' + (i + 1) + '</td>' +
                                '<td style="display:none;"><input type="hidden" value="' + data[i].Balance + '" name="txtamount"></td>' +
                                '<td>' + data[i].Name + '</td>' +
                                '<td style="text-align:right;">' + bl.toLocaleString('en') + '</td>';
                            var editEnabled = (_editMode === "01" || _editMode === "02");
                            if (editEnabled) {
                                rows += '<td style="text-align:center;"><a class="editListBtn" href="#" onclick="OpenList(' + data[i].Doctor_Id + ')"><i class="fa fa-pencil"></i></a></td>';
                            } else {
                                rows += '<td style="text-align:center;"><span class="editListBtn disabled" title="Edit disabled"><i class="fa fa-pencil"></i></span></td>';
                            }
                            rows += '</tr>';
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
                                { "targets": 3, "width": "50%" },
                                { "targets": 4, "width": "25%", "className": "text-right" },
                                { "targets": 5, "width": "8%", "orderable": false, "className": "text-center" }
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
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row" style="margin-bottom:15px;align-items:center;">
        <div class="col-md-3">
            <label style="font-weight:600;font-size:13px;color:#555;">Doctor</label>
            <select id="ddlDoctor" onchange="testddlchange()" style="width:220px;"></select>
        </div>
        <div class="col-md-6"></div>
        <div class="col-md-3 text-right">
            <span class="total-badge">
                Total Payable: <span class="total-amount" id="totalamt">0</span>
            </span>
        </div>
    </div>

    <div class="row">
        <div class="col-lg-12" style="overflow-x:auto;">
            <table id="Table_1" class="table table-hover table-striped table-bordered" style="width:100%;">
                <thead>
                    <tr>
                        <th style="display:none;">DocID</th>
                        <th>Sr No</th>
                        <th style="display:none;">Balance</th>
                        <th>Doctor Name</th>
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
