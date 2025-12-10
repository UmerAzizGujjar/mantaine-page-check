<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="InversionGatePassView.aspx.cs" Inherits="PMS.Inventory.InversionGatePassView" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
 
    <link href="../../wwwroot/Tibbit_theme/css/tablestyle.css" rel="stylesheet" />
    <style>
        table.dataTable tbody tr.child td > .child-container {
            display: flex;
            gap: 20px;
            padding: 15px;
            background: #f4f7fb;
            border-left: 4px solid #3498db;
            animation: fadeIn .25s ease-in;
        }

        .table-wrapper {
            max-height: 200px; /* adjust height as needed */
            overflow-y: auto; /* vertical scroll */
            overflow-x: auto; /* horizontal scroll if table is wider */
            border: 1px solid #ddd;
            margin-bottom: 10px;
        }

            /* Optional: fixed header style */
            .table-wrapper table {
                width: 100%;
                border-collapse: collapse;
            }

            .table-wrapper th, .table-wrapper td {
                padding: 6px;
                border: 1px solid #ddd;
                font-size: 12px;
                text-align: left;
                white-space: nowrap; /* prevents wrapping */
            }

        .child-col-left {
            background: #ffffff;
            border-radius: 6px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

            .child-col-left p {
                color: #1b48ed;
                font-size: 15px;
            }

                .child-col-left p b {
                    color: black;
                }

        .child-col-right {
            width: 65%;
        }

        h5 {
            font-size: 20px;
            font-weight: 1000;
        }

        .child-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 5px;
            background: #fff;
            border-radius: 6px;
            overflow: hidden;
        }

            .child-table th {
                background: #3498db;
                color: #fff;
                padding: 6px;
                font-size: 13px;
                text-align: left;
            }

            .child-table td {
                padding: 6px;
                border: 1px solid #ddd;
                font-size: 12px;
            }

        .child-loading {
            padding: 15px;
            font-size: 14px;
            font-weight: bold;
        }

        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(-8px);
            }

            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
    </style>
    
    <script type="text/javascript">
        $(document).ready(function () {
            $('#ctl00_lblMessage').hide();
            LoadPage();
        });

        function Edit(ID) {
            window.location.href = "InversionGatePass.aspx?IGP_Id=" + ID;
        }
       

        function PrintInwardGatePassDetail(Igp_Id) {
            debugger;
               var locationInfo = window.location;
            var url = '/ReportViewer.aspx?ReportName=InwardGatePassList&ReportTitle=Inward Gate Pass List&Igpid=' + Igp_Id;
               if (!locationInfo.origin.includes('localhost')) {
                   var urlInfo = window.location.href.split('/');
                   var ip = urlInfo[2];
                   var foldername = urlInfo[3];
                   url = 'http://' + ip + '/' + foldername + '/ReportViewer.aspx?ReportName=InwardGatePassList&ReportTitle=Inward Gate Pass List&Igpid=' + Igp_Id;
               }
               window.open(url, '_blank');
           }

        function AutoGRN(ID) {
            var IgpId = ID;
            PageMethods.AutoGRN(IgpId, function (Tests) {
                debugger
                var message = JSON.parse(Tests);
                if (message[0].Column1 != "" || message[0].Column1 != null) {
                    location.reload();
                }
            });
        }


        function EditGRN(ID) {
            window.location.href = "GRN.aspx?GRN_ID=" + ID;
        }
        function advautogrn(ID) {
            var IgpId = ID;
            PageMethods.AdvAutoGRN(IgpId, function (Tests) {
                debugger
                var message = JSON.parse(Tests);
                if (message[0].Column1 != "" || message[0].Column1 != null) {
                    location.reload();
                }
            });
        }
        function deleteConfirm(anchorTag) {
            debugger;
            var row = $(anchorTag).parents('tr')[0];
            var IgpID = $($(row).find('td')[0]).text();
            if (confirm('Are you sure want to delete this record')) {
                PageMethods.DeleteRecord(IgpID, function (msg) {
                    debugger
                    $(row).remove();
                }, OnFail);
            }
        }



        function LoadPage() {
            var table = $("#tblResult").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": [
                    {
                        text: 'Add',
                        className: 'dt-button buttons-copy buttons-html5',
                        action: function () { window.location = 'InversionGatePass.aspx'; }
                    },
                    'copy', 'excel', 'pdf'
                ],
                "filter": true,
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "InversionGatePassView.aspx/ViewList",
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
                            console.error("AJAX Error:", error);
                            console.log(xhr.responseText);
                        }
                    });
                },
                "columns": [
                    { "data": "Igp_Id", "visible": false },
                    { "data": "Igp_num", "name": "Igp_num", "orderable": true },
                    {
                        "data": "Igp_date",
                        "render": function (data, type, full) {
                            return full.Igp_date ? moment(full.Igp_date).format('D-MMM-YYYY') : '';
                        },
                        "orderable": false
                    },
                    { "data": "VendorName", "orderable": false },
                    { "data": "PONum", "name": "PONum", "orderable": true },
                    { "data": "Remarks", "orderable": false },
                    { "data": "VehicleNum", "orderable": false },  // ← NEW
                    { "data": "CreatedBy", "orderable": false },   // ← NEW
                    {
                        "data": "Creation_Date",
                        "render": function (data, type, full) {
                            return full.Creation_Date ? moment(full.Creation_Date).format('D-MMM-YYYY') : '';
                        },
                        "orderable": false
                    },  // ← NEW
                    { "data": "Updated_By", "orderable": false },  // ← NEW
                    {
                        "data": "Update_Date",
                        "render": function (data, type, full) {
                            return full.Update_Date ? moment(full.Update_Date).format('D-MMM-YYYY') : '';
                        },
                        "orderable": false
                    },  // ← NEW
                    { "data": "Status", "orderable": false },
                    { "data": "Inspec_Status", "orderable": false },
                    {
                        "render": function (data, type, full) {
                            var inspecstatus = full.Inspec_Status != null ? full.Inspec_Status : "";
                            var btnAutoGRNVisible = 'style="display:none;"';
                            if (inspecstatus === "Approved") {
                                if (full.IsAuto != "True") {
                                    btnAutoGRNVisible = '';
                                }
                            }

                            var res = '<a href="#" onclick="Edit(' + full.Igp_Id + ')" class="editListBtn" style="border-radius: 4px;padding: 4px 11px 4px 11px;"><i class="fa fa-pencil"></i></a> ' +
                                '<a class="editListBtn" href="#" onclick="AutoGRN(' + full.Igp_Id + ')" ' + btnAutoGRNVisible + ' style="border-radius: 4px;padding: 4px 11px 4px 11px;" name="btnAutoGRN" id="btnAutoGRN' + full.Igp_Id + '">Auto GRN</a>';

                            var print = '<a class="printListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="PrintInwardGatePassDetail(' + full.Igp_Id + ')" id="btnprint"><i class="fa fa-print"></i></a>';
                            return res + print;
                        },
                        "width": "15%",
                        "orderable": false
                    },
                    {
                        "render": function (data, type, full) {
                            var inspecstatus = full.Inspec_Status != null ? full.Inspec_Status : "";
                            var viewGRNVisible = 'style="display:none;"';
                            if (inspecstatus === "Approved" && full.IsAuto == "True") {
                                viewGRNVisible = '';
                            }
                            return '<a class="editListBtn" href="#" id="viewgrn' + full.Igp_Id + '" ' + viewGRNVisible + ' onclick="EditGRN(' + full.Grn_ID + ')" style="border-radius: 4px;padding: 4px 11px 4px 11px;"><i class="fa fa-pencil"></i></a>';
                        },
                        "orderable": false
                    }
                ],
                "rowCallback": function (row, data, index) {
                    if (data.Status === "Created") {
                        $(row).css('background-color', 'white');
                    } else if (data.Status === "Approved") {
                        $(row).css('background-color', '#ABEBC6');
                    } else if (data.Status === "Cancelled") {
                        $(row).css('background-color', 'rgba(251, 181, 181, 0.87)');
                    }
                },
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

            // Child row (detail) click handler — unchanged
            $('#tblResult tbody').on('click', 'tr', function () {
                var row = table.row(this);
                var data = row.data();
                if (!data) return;

                var id = data.Igp_Id;

                if (row.child.isShown()) {
                    row.child.hide();
                    $(this).removeClass('shown');
                    return;
                }

                row.child('<div class="child-loading">Loading...</div>').show();
                $(this).addClass('shown');

                $.ajax({
                    type: "POST",
                    url: "InversionGatePassView.aspx/GetMasterAndDetail",
                    data: JSON.stringify({ invoiceId: id }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (resp) {
                        var d = resp.d;
                        var html = `
                    <div class="child-container">                            
                        <div class="col-sm-4 col-md-4 col-lg-3 child-col-left">
                            <h5>Master Information</h5>
                            <p><b>Invoice #:</b> ${d.Master.Number}</p>
                            <p><b>Date:</b> ${d.Master.Date ? moment(d.Master.Date).format("DD-MMM-YYYY") : ''}</p>
                            <p><b>Vendor:</b> ${d.Master.VendorName}</p>
                            <p><b>Status:</b> ${d.Master.Status}</p>
                            <p><b>Remarks:</b> ${d.Master.Remarks || ''}</p>
                        </div>                           
                        <div class="col-sm-9 col-md-4 col-lg-9">
                            <h5>Invoice Details</h5>
                            <div class="table-wrapper">
                                <table class="child-table" id="detailTable_${id}">
                                    <thead>
                                        <tr>
                                            <th>Item Code</th>
                                            <th>Item</th>
                                            <th>PO Qty</th>
                                            <th>Blnc Qty</th>
                                            <th>IGP Qty</th>
                                            <th>Inspec Qty</th>
                                        </tr>
                                    </thead>
                                    <tbody></tbody>
                                </table>   
                            </div>
                            <h5 class="mt-3">Audit Information</h5>
                            <table class="child-table" id="otherTable_${id}">
                                <thead>
                                    <tr>
                                        <th>Type</th>
                                        <th>Number</th>
                                        <th>Date</th>
                                        <th>Status</th>
                                        <th>View</th>
                                    </tr>
                                </thead>
                                <tbody></tbody>
                            </table>                           
                        </div>                            
                    </div>`;

                        row.child(html).show();

                        // Populate detail table
                        $.each(d.Detail || [], function (i, item) {
                            $("#detailTable_" + id + " tbody").append(`
                        <tr>
                            <td>${item.Item_Code || ''}</td>
                            <td>${item.Description || ''}</td>
                            <td>${item.POQty || 0}</td>
                            <td>${item.BlncQty || 0}</td>
                            <td>${item.IGPQty || 0}</td>
                            <td>${item.InspecQty || 0}</td>
                        </tr>
                    `);
                        });

                        LoadAuditInfo(id);
                    },
                    error: function (xhr, status, err) {
                        row.child('<div class="text-danger">Failed to load details.</div>').show();
                        console.error("Detail load error:", err);
                    }
                });
            });
        }
        function LoadAuditInfo(id) {

            $.ajax({
                type: "POST",
                url: "InversionGatePassView.aspx/GetAuditInfo",
                data: JSON.stringify({ invoiceId: id }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (resp) {

                    $.each(resp.d, function (i, x) {

                        $("#otherTable_" + id + " tbody").append(`
                  <tr>
                      <td>${x.T_Type}</td>
                      <td>${x.NUmber}</td>
                      <td>${moment(x.Dates).format("DD-MMM-YYYY")}</td>
                      <td>${x.Status}</td>
                      <td>
                         <a class="printListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="ViewPage(${x.ID},'${x.T_Type}')" id="btnview"><i class="fa fa-eye" ></i></a>
                      </td>
                  </tr>
              `);
                    });
                }
            });
        }
        function ViewPage(id, type) {
            debugger;
            var ID = id
            if (type == 'GRN') {
                window.open("GRN.aspx?GRN_ID=" + ID, "_blank");
            }
            else if (type == 'IGP') {
                window.open("InversionGatePass.aspx?IGP_Id=" + ID, "_blank");
            }
            else if (type == 'PO') {
                window.open("../AP/PurchaseOrder.aspx?PO_ID=" + ID, "_blank");
            }
            else if (type == 'PR') {
                window.open("../AP/PurchaseRequistion.aspx?ID=" + ID, "_blank");
            }
            else if (type == 'PUR Inv') {
                window.open("AddPurchaseInvoice.aspx?Inv_ID=" + ID, "_blank");
            }
            else if (type == 'Pay Inv') {
                window.open("AddPaymentInvoice.aspx?Inv_ID=" + ID, "_blank");
            }
        }  

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    
    <div class="table-container">
        <table class="table table-responsive-lg table-hover table-bordered" id="tblResult">
            <thead id="ihead">
                <tr>
                    <th style="display:none">Igp Id</th>
                    <th>Igp #</th>
                    <th>Igp Date</th>
                    <th>Vendor Name</th>
                    <th>PO #</th>
                    <th>Remarks</th>
                    <th>Vehicle #</th>
                    <th>Created By</th>
                    <th>Created Date</th>
                    <th>Updated By</th>
                    <th>Updated Date</th>
                    <th>Status</th>
                    <th>Inspec</th>
                    <th>Actions</th>
                    <th>GRN View</th>
                </tr>
            </thead>
            <tbody id="ibody">
            </tbody>
        </table>
    </div>


</asp:Content>

