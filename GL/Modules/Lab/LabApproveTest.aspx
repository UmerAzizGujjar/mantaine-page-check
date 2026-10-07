<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="LabApproveTest.aspx.cs" Inherits="PMS.Modules.Lab.LabApproveTest" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

        <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />
    <style>
        .approved-table-container {
            margin-top: 20px;
            padding: 15px;
            background: #fff;
            border-radius: 5px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        .filter-section {
            margin-bottom: 20px;
            padding: 15px;
            background: #f9f9f9;
            border-radius: 5px;
        }
        .filter-section label {
            margin-right: 10px;
            font-weight: bold;
        }
        h2 {
            color: #333;
            border-left: 4px solid var(--theme-accent, #EFA63E);
            padding-left: 15px;
            margin-bottom: 20px;
        }
        .btn-preview {
            /* theme colours (theme-colors.css), not a fixed blue */
            background-color: var(--theme-accent, #EFA63E);
            color: var(--theme-on-accent, #fff);
            border: none;
            padding: 5px 12px;
            border-radius: 3px;
            cursor: pointer;
        }
        .btn-preview:hover {
            background-color: var(--theme-accent-ink, #8a4b00);
            color: #fff;
        }
        .dataTables_wrapper .dt-buttons {
            margin-bottom: 10px;
        }
    </style>
    <script type="text/javascript">
$(document).ready(function() {
    var date = new Date();
    var today = moment(date).format('MM/DD/YYYY');
    var firstDayOfMonth = moment(date).startOf('month').format('MM/DD/YYYY');

    $("#sdate").val(firstDayOfMonth);
    $("#edate").val(today);

    LoadDoctors();
    LoadPage();

    $('#btnSearch').click(function() {
        $('#tblLabApprovedTests').DataTable().ajax.reload();
    });
});

function LoadDoctors() {
    $.ajax({
        type: "POST",
        url: "LabApproveTest.aspx/GetDoctors",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function(response) {
            var data = typeof response.d === 'string' ? JSON.parse(response.d) : response.d;
            var options = '<option value="0">All Doctors</option>';

            if (data && data.length > 0) {
                $.each(data, function(key, value) {
                    options += '<option value="' + value.id + '">' + value.text + '</option>';
                });
            }
            $("#ddlDoctor").html(options);
            if ($("#ddlDoctor").data('select2')) {
                $("#ddlDoctor").select2('destroy');
            }
            $("#ddlDoctor").select2();
            if (data && data.length === 1) {
                $("#ddlDoctor").val(data[0].id).trigger('change');
            } else {
                $("#ddlDoctor").val("0").trigger('change');
            }
        },
        error: function(xhr, status, error) {
            console.error("Error loading doctors", error);
        }
    });
}

function LoadPage() {
    $("#tblLabApprovedTests").DataTable({
        "processing": true,
        "serverSide": true,
        "dom": 'lBfrtip',
        "lengthChange": true,
        "pageLength": 50,
        "lengthMenu": [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]],
        "buttons": [
            {
                text: 'Refresh',
                className: 'dt-button buttons-copy buttons-html5',
                action: function() {
                    $('#tblLabApprovedTests').DataTable().ajax.reload();
                }
            },
            'copy',
            'excel',
            'pdf'
        ],
        "filter": true,
        "ajax": function(data, callback, settings) {
            var startdate = $('#sdate').val();
            var endtdate = $('#edate').val();
            var doctorId = $('#ddlDoctor').val();
            var searchText = data.search.value;

            var lengthParam = data.length;
            if (lengthParam === -1) {
                lengthParam = 1000000;
            }

            $.ajax({
                type: "POST",
                url: "LabApproveTest.aspx/ViewList",
                data: JSON.stringify({
                    draw: data.draw,
                    start: data.start,
                    length: lengthParam,
                    length: data.length,
                    sortColumn: data.columns[data.order[0].column].name,
                    sortColumnDirection: data.order[0].dir,
                    searchValue: searchText,
                    startdate: startdate,
                    endtdate: endtdate,
                    doctorId: doctorId
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function(response) {
                    callback({
                        draw: response.d.draw,
                        recordsTotal: response.d.recordsTotal,
                        recordsFiltered: response.d.recordsFiltered,
                        data: response.d.data
                    });
                },
                error: function(xhr, status, error) {
                    console.log(xhr.responseText);
                }
            });
        },
        "columns": [
            { "data": null, "width": "4%", "orderable": false, "render": (data, type, full, meta) => meta.settings._iDisplayStart + meta.row + 1 },
            { "data": "Bill_No", "name": "Bill_No", "width": "5%", "orderable": true },
            {
                "data": "Is_Refunded", "name": "Is_Refunded", "width": "5%", "orderable": true,
                "render": function(data) {
                    return data == 1 ? '<span style="color:#c00;font-weight:bold;">Refunded</span>' : '<span style="color:#080;">Active</span>';
                }
            },
            {
                "data": "Bill_Date", "name": "Bill_Date",
                "render": function(data, type, full) {
                    var date = full.Bill_Date;
                    date = moment(date).format('DD-MMM-YYYY');
                    return date;
                }, "width": "5%", "orderable": true
            },
            { "data": "mr_no_sequence", "name": "mr_no_sequence", "width": "6%", "orderable": true },
            { "data": "Full_Name", "name": "Full_Name", "width": "12%", "orderable": true },
            { "data": "Mobile1", "name": "Mobile1", "width": "4%", "orderable": true },
            { "data": "Test_Name", "name": "Test_Name", "width": "15%", "orderable": true },
            { "data": "Test_Main_Department", "name": "Test_Main_Department", "width": "9%", "orderable": true },
            { "data": "Doctor_Name", "name": "Doctor_Name", "width": "10%", "orderable": true },
            { "data": "Net_Amount", "name": "Net_Amount", "width": "8%", "orderable": true },
            { "data": "Approved_By_Name", "name": "Approved_By_Name", "width": "10%", "orderable": true },
            {
                "data": "Approved_Time", "name": "Approved_Time",
                "render": (data, type, full) => moment(full.Approved_Time).format('DD-MMM-YYYY HH:mm'),
                "width": "12%"
            },
            {
                "render": (data, type, full) => {
                    return `<button type="button" class="btn-preview" onclick="PreviewReport(${full.Lab_Test_Detail_ID}, ${full.Lab_Test_ID}, ${full.pat_id}, '${full.Report_Colum}', ${full.Bill_Details_ID}, ${full.Test_ID})">Preview Report</button>`;
                },
                "width": "10%",
                "orderable": false
            }
        ],
        "initComplete": function(settings, json) {
            var lengthContainer = document.querySelector('#tblLabApprovedTests_length');
            var lengthDropdown = document.querySelector('#tblLabApprovedTests_length select');
            var label = document.querySelector('#tblLabApprovedTests_length label');

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

//function PreviewReport(Lab_Test_Detail_ID, Lab_Test_ID, pat_id, Report_Colum, Bill_Details_ID, Test_ID) {
//    window.open('../../ReportViewer.aspx?ReportName=TestResultQ' +
//        '&ReportTitle=Department Of Pathology' +
//        '&Test_IDs=' + Test_ID +
//        '&test_wise_ids=' + pat_id +
//        '&TransID=' + Lab_Test_ID +
//        '&labTDetailsID=' + Lab_Test_Detail_ID +
//        '&BillDetailID=' + Bill_Details_ID +
//        '&ReportColumn=' + Report_Colum +
//        '&PatientID=' + pat_id);  // Added pat_id explicitly
//}

// Build URL with all parameters visible in the address bar
function PreviewReport(Lab_Test_Detail_ID, Lab_Test_ID, pat_id, Report_Colum, Bill_Details_ID, Test_ID) {
    console.log('PreviewReport Params:', { Lab_Test_Detail_ID, Lab_Test_ID, pat_id, Report_Colum, Bill_Details_ID, Test_ID });

    var params = new URLSearchParams({
        Lab_Test_Detail_ID: Lab_Test_Detail_ID,
        Lab_Test_ID: Lab_Test_ID,
        pat_id: pat_id,
        Report_Colum: Report_Colum,
        Bill_Details_ID: Bill_Details_ID,
        Test_ID: Test_ID
    });

    var reportWindow = window.open('?' + params.toString(), '_blank');
    reportWindow.document.write(`
        <!DOCTYPE html><html><head><title>Loading...</title>
        <style>
            body { font-family: Arial, sans-serif; display: flex; justify-content: center; 
                   align-items: center; height: 100vh; margin: 0; background: #f5f5f5; }
            .loader { text-align: center; }
            .spinner { border: 4px solid #f3f3f3; border-top: 4px solid #3498db; 
                       border-radius: 50%; width: 50px; height: 50px; 
                       animation: spin 1s linear infinite; margin: 0 auto 20px; }
            @keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
        </style></head>
        <body><div class="loader">
            <div class="spinner"></div>
            <p style="color:#555; font-size:16px;">Loading Report, Please Wait...</p>
            <p style="color:#888; font-size:12px;">
                Test_ID: ${Test_ID} | Lab_Test_ID: ${Lab_Test_ID} | 
                pat_id: ${pat_id} | Bill_Details_ID: ${Bill_Details_ID} |
                Lab_Test_Detail_ID: ${Lab_Test_Detail_ID}
            </p>
        </div></body></html>
    `);

    $.ajax({
        type: "POST",
        url: "LabApproveTest.aspx/GetDynamicReportHTML",
        data: JSON.stringify({
            Test_IDs: String(Test_ID),
            Trans_IDs: String(Lab_Test_ID),
            Patient_ID: parseInt(pat_id) || 0,
            Bill_Details_IDs: String(Bill_Details_ID)
        }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function(response) {
            var data;
            try {
                data = typeof response.d === 'string' ? JSON.parse(response.d) : response.d;
            } catch (e) {
                reportWindow.document.open();
                reportWindow.document.write('<html><body style="color:red;padding:40px;">Error parsing response: ' + e.message + '</body></html>');
                reportWindow.document.close();
                return;
            }

            if (data.error) {
                reportWindow.document.open();
                reportWindow.document.write('<html><body style="color:red;font-family:Arial;padding:40px;"><h3>Error Loading Report</h3><p>' + data.error + '</p></body></html>');
                reportWindow.document.close();
                return;
            }

            var logoHtml = '';
            if (data.Company_Logo_Path && data.Company_Logo_Path !== '') {
                logoHtml = '<img src="' + data.Company_Logo_Path + '" alt="Logo" style="max-height:80px; max-width:150px; object-fit:contain;" onerror="this.style.display=\'none\'" />';
            }

            function formatDate(val) {
                if (!val) return '';
                try {
                    var match = /\/Date\((\d+)\)\//.exec(val);
                    var d = match ? new Date(parseInt(match[1])) : new Date(val);
                    if (isNaN(d.getTime())) return val || '';

                    var months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                    var dd = String(d.getDate()).padStart(2, '0');
                    var mmm = months[d.getMonth()];
                    var yyyy = d.getFullYear();
                    var hh = String(d.getHours()).padStart(2, '0');
                    var min = String(d.getMinutes()).padStart(2, '0');
                    var ss = String(d.getSeconds()).padStart(2, '0');

                    return dd + '-' + mmm + '-' + yyyy + ' ' + hh + ':' + min + ':' + ss;
                } catch (e) { return val || ''; }
            }


            var html = `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Report - ${data.Patient_No || ''}</title>
    <style>
        @page { size: A4; margin: 15mm 20mm; }
        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: Arial, sans-serif;
            font-size: 11px;
            color: #000;
            background: #fff;
            line-height: 1.4;
        }

        .page-wrapper {
            width: 210mm;
            min-height: 297mm;
            margin: 0 auto;
            padding: 10mm 15mm;
            background: #fff;
        }

        /* ── HEADER ── */
        .report-header {
            display: flex;
            align-items: center;
            gap: 15px;
            padding-bottom: 10px;
            border-bottom: 2.5px solid #000;
            margin-bottom: 12px;
        }
        .logo-wrap {
            flex-shrink: 0;
            width: 100px;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .hospital-info {
            flex: 1;
            text-align: center;
        }
        .hospital-info .name {
            font-size: 17px;
            font-weight: bold;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .hospital-info .address {
            font-size: 9px;
            color: #333;
            margin-top: 3px;
        }

        /* ── PATIENT INFO ── */
        .patient-section {
            display: flex;
            gap: 20px;
            margin-bottom: 12px;
            padding-bottom: 8px;
            border-bottom: 1px solid #ccc;
        }
        .patient-col { flex: 1; }
        .patient-col .patient-title {
            font-size: 13px;
            font-weight: bold;
            border-bottom: 1px solid #000;
            margin-bottom: 6px;
            padding-bottom: 3px;
        }
        .info-row {
            display: flex;
            margin-bottom: 4px;
            font-size: 10.5px;
            gap: 5px;
        }
        .info-label {
            font-weight: bold;
            min-width: 115px;
            flex-shrink: 0;
        }
        .info-val {
            flex: 1;
            border-bottom: 1px dotted #bbb;
            padding-bottom: 1px;
            min-height: 14px;
        }

        /* ── TEST NAME BANNER ── */
        .test-banner {
            text-align: center;
            border-top: 2px solid #000;
            border-bottom: 2px solid #000;
            padding: 7px 0;
            margin-bottom: 15px;
        }
        .test-banner .test-title {
            font-size: 14px;
            font-weight: bold;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        
        /* ── REPORT CONTENT ── */
        .report-content {
            min-height: 350px;
            font-size: 11px;
            line-height: 1.7;
            margin-bottom: 20px;
            text-align: justify;
        }
        .report-content p { margin-bottom: 6px; }
        .report-content table { width: 100%; border-collapse: collapse; margin-bottom: 8px; }
        .report-content table td,
        .report-content table th { border: 1px solid #ccc; padding: 4px 6px; font-size: 10.5px; }

        ///* ── SIGNATURES ── */
        //.signatures {
        //    display: flex;
        //    justify-content: space-between;
        //    margin-top: 30px;
        //    padding-top: 10px;
        //    border-top: 1px solid #000;
        //    page-break-inside: avoid;
        //}
        //.sig-block { width: 45%; }
        //.sig-block.right { text-align: right; }
        //.sig-name { font-weight: bold; font-size: 11px; }
        //.sig-qual { font-size: 9.5px; margin-top: 2px; color: #333; }
        //.sig-date { font-size: 9.5px; margin-top: 2px; }
        //.sig-note { font-style: italic; font-size: 8.5px; margin-top: 5px; color: #555; }
        //.sig-line {
        //    border-top: 1px solid #000;
        //    margin-top: 35px;
        //    padding-top: 5px;
        //}


        
            /* ── ADDENDUM SECTION ── */
        .addendum-section {
            margin-top: 15px;
            margin-bottom: 15px;
            page-break-inside: avoid;
        }
        .addendum-heading {
            font-family: "Times New Roman", Times, serif;
            font-size: 13px;
            font-weight: bold;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-bottom: 8px;
            color: #000;
        }

            <!-- SIGNATURES -->
    <div class="signatures">

        <!-- Left: Performing Doctor -->
        <div class="sig-block">
            <div class="sig-name">${data.Test_Performed_By_Doctor_name || ''}</div>
            <div class="sig-qual">${data.Test_Performed_By_Doctor_qualification || ''}</div>
            <div class="sig-date">Date &amp; Time: ${data.Test_Ready_On || ''}</div>
            <div class="sig-note">No Signature(s) required, Electronically Verified</div>
        </div>

        <!-- Right: Approving Doctor — fixed margin -->
        <div class="sig-block right">
            <div class="sig-line" style="margin-top:0; border-top:1px solid #000; 
                 padding-top:5px; display:inline-block; min-width:200px; text-align:right;">
                <div class="sig-name">
                    ${data.Test_Approved_By_Doctor_name
                    ? data.Test_Approved_By_Doctor_name
                    : '&nbsp;'}
                </div>
                <div class="sig-qual">
                    ${data.Test_Approved_By_Doctor_qualification || ''}
                </div>
            </div>
        </div>

    </div>



        /* ── PAGE FOOTER ── */
        .page-footer {
            display: flex;
            justify-content: space-between;
            gap: 10px;
            margin-top: 25px;
            padding-top: 8px;
            border-top: 1.5px double #000;
            font-size: 9px;
            color: #444;
            page-break-inside: avoid;
        }
        .footer-col { flex: 1; }
        .footer-col.right { text-align: right; }

        /* ── PRINT BUTTON ── */
        .print-btn {
            position: fixed;
            bottom: 25px;
            right: 25px;
            background: #1a1a2e;
            color: #fff;
            border: none;
            padding: 12px 28px;
            border-radius: 6px;
            font-size: 14px;
            cursor: pointer;
            box-shadow: 0 4px 12px rgba(0,0,0,0.3);
            z-index: 9999;
        }
        .print-btn:hover { background: #16213e; }

        // Replace your @media print section with this:

@media print {
    /* Hide browser's default print header/footer */
    @page {
        size: A4;
        margin: 15mm 20mm;
        /* This removes the default header/footer in most browsers */
        margin-top: 0;
        margin-bottom: 0;
    }
    
    /* Add back your own margins on body */
    body {
        margin: 15mm 20mm !important;
        padding: 0 !important;
    }
    
    .print-btn { 
        display: none !important; 
    }
    
    html, body {
        height: auto !important;
        overflow: visible !important;
    }
    
    * {
        -webkit-print-color-adjust: exact !important;
        print-color-adjust: exact !important;
        color-adjust: exact !important;
    }

}
    </style>
    <script>
function cleanPrint() {
    var btn = document.querySelector('.print-btn');
    if (btn) btn.style.display = 'none';
    
    var style = document.createElement('style');
    style.innerHTML = '@page { margin: 15mm 20mm; }';
    document.head.appendChild(style);
    
    window.print();
    
    setTimeout(function() {
        if (btn) btn.style.display = 'block';
    }, 1000);
}
<\/script>
</head>
<body>
<div class="page-wrapper">

    <!-- HEADER -->
    <div class="report-header">
        <div class="logo-wrap">${logoHtml}</div>
        <div class="hospital-info">
            <div class="name">${data.Company_Name || 'NATIONAL TESTing HOSPITAL & MEDICAL CENTRE'}</div>
            <div class="address">${data.Company_Address || ''}</div>
        </div>
    </div>

    <!-- PATIENT INFO - TWO COLUMNS -->
    <div class="patient-section">

        <!-- LEFT COLUMN -->
        <div class="patient-col">
            <div class="patient-title">${data.Full_Name || ''} &nbsp; ${data.Age_years || ''}, &nbsp; ${data.Gender || ''}</div>
            <div class="info-row">
                <span class="info-label">Contact :</span>
                <span class="info-val">${data.Mobile1 || ''}</span>
            </div>
            <div class="info-row">
                <span class="info-label">Patient Type :</span>
                <span class="info-val">${data.Patient_Type || ''}</span>
            </div>
            <div class="info-row">
                <span class="info-label">CNIC :</span>
                <span class="info-val">${data.NIC || ''}</span>
            </div>
            <div class="info-row">
                <span class="info-label">Referring Doctor :</span>
                <span class="info-val">${data.ReferredByDoctor || ''}</span>
            </div>
            <div class="info-row">
                <span class="info-label">Approved By :</span>
                <span class="info-val">${data.Test_Approved_By_Doctor_name || ''}</span>
            </div>
        </div>

        <!-- RIGHT COLUMN -->
        <div class="patient-col">
            <div class="patient-title">MRN# &nbsp; ${data.Patient_No || ''}</div>
            <div class="info-row">
                <span class="info-label">Reg Date :</span>
                <span class="info-val">${formatDate(data.REg_Date)}</span>
            </div>
            <div class="info-row">
                <span class="info-label">Department :</span>
                <span class="info-val">${data.Department || ''}</span>
            </div>
            <div class="info-row">
                <span class="info-label">Created At :</span>
                <span class="info-val">${formatDate(data.Billing_Date) || ''}</span>
            </div>
            <div class="info-row">
                <span class="info-label">Reported At :</span>
                <span class="info-val">${formatDate(data.Approved_Time) || ''}</span>
            </div>
            <div class="info-row">
                <span class="info-label">Accession # :</span>
                <span class="info-val">${data.Lab_Test_Detail_Id || ''}</span>
            </div>
        </div>

    </div>

    <!-- TEST NAME BANNER -->
    <div class="test-banner">
        <div class="test-title">${data.Test_Name || ''}</div>
    </div>

    <!-- REPORT CONTENT (Fixed_Value from CKEditor) -->
    <div class="report-content">
        ${data.Fixed_Value || '<p style="color:#999; text-align:center;">No report content available.</p>'}
    </div>

    <!-- ADDENDUM SECTION (Only visible if Addendum_Template has data) -->
    ${data.Addendum_Template ? `
    <div class="addendum-section">
        <div class="addendum-heading">ADDENDUM:</div>
        <div class="addendum-content">
            ${data.Addendum_Template}
        </div>
    </div>
     ` : ''}

<!-- SIGNATURES -->
<div class="signatures">
    <div class="sig-block">
        <div class="sig-name">${data.Test_Performed_By_Doctor_name || ''}</div>
        <div class="sig-qual">${data.Test_Performed_By_Doctor_qualification || ''}</div>
    </div>
    <div class="sig-block right">
        <div class="sig-line">
        </div>
    </div>
</div>

<!-- REPORT FOOTER (from DB — shown between signatures and page footer) -->
<div class="page-footer" style="margin-top:10px; border-top: 1px solid #ccc; padding-top:6px;">
    <div class="footer-col">${data.Report_Footer1 || ''}</div>
    <div class="footer-col right">${data.Report_Footer_tow1 || ''}</div>
</div>

<!-- PAGE FOOTER -->
<div class="page-footer">
    <div class="footer-col">${data.Report_Footer || ''}</div>
    <div class="footer-col right">${data.Report_Footer_tow || ''}</div>
        <div class="sig-note">No Signature(s) required, Electronically Verified</div>
</div>

<button class="print-btn" onclick="cleanPrint()">🖨 Print Report</button>



</body>
</html>`;

            reportWindow.document.open();
            reportWindow.document.write(html);
            reportWindow.document.close();

        },
        error: function(xhr, status, error) {
            reportWindow.document.open();
            reportWindow.document.write('<html><body style="font-family:Arial;color:red;padding:40px;"><h3>AJAX Error</h3><p>' + (xhr.responseText || error) + '</p></body></html>');
            reportWindow.document.close();
        }
    });
}

    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    
        <!-- Filter Section -->
        <div class="filter-section">
            <div class="row">
                <div class="col-lg-2">
                    <label>Start Date:</label>
                    <input type="text" id="sdate" class="form-control datepicker" />
                </div>
                <div class="col-lg-2">
                    <label>End Date:</label>
                    <input type="text" id="edate" class="form-control datepicker" />
                </div>
                <div class="col-lg-3">
                    <label>Doctor:</label>
                    <select id="ddlDoctor" class="form-control">
                        <option value="0">Loading...</option>
                    </select>
                </div>
                <div class="col-lg-2" style="margin-top: 24px;">
                    <input type="button" id="btnSearch" class="btn btn-primary" value="Search" />
                </div>
            </div>
        </div>
        
        <!-- Approved Tests Table -->
        <div class="approved-table-container">
            <div style="overflow-x: auto;">
                <table class="table table-hover table-striped table-bordered" id="tblLabApprovedTests" style="width: 100%;">
                    <thead>
                        <tr>
                            <th>Sr#</th>
                            <th>Bill No</th>
                            <th>Status</th>
                            <th>Bill Date</th>
                            <th>MR No</th>
                            <th>Patient Name</th>
                            <th>Phone #</th>
                            <th>Test Name</th>
                            <th>Department</th>
                            <th>Doctor</th>
                            <th>Net Amount</th>
                            <th>Approved By</th>
                            <th>Approved Date/Time</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                    </tbody>
                </table>
            </div>
        </div>
  
    
    <script type="text/javascript">
        $(function () {
            $(".datepicker").datepicker({
                dateFormat: 'mm/dd/yy',
                changeMonth: true,
                changeYear: true
            });
        });
    </script>
</asp:Content>
