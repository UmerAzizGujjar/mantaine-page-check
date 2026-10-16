<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AnesthesiaForm.aspx.cs" Inherits="PMS.Modules.PatientManagement.AnesthesiaForm" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/lib/sweetalert/swalalert.css" rel="stylesheet" />
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/vendor.css" rel="stylesheet" />
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/Datavalue.css" rel="stylesheet" />
    <link href="../../wwwroot/lib/theme/pharmacy-form.css?v=6" rel="stylesheet" />
    <script type="text/javascript">
        // ===== state =====
        var caseId = '';          // ANE-yyyyMMdd-0001, given by the server when Step 1 is first saved
        var patientId = 0;
        var isEditMode = false;
        var flags = { 1: false, 2: false, 3: false };      // which steps are saved
        var lookups = { doctors: [], staff: [] };
        var HISTORY_ITEMS = ['Previous Anesthesia', 'HTN', 'IHD', 'Asthma', 'COPD', 'Hepatic', 'Neurological', 'Renal', 'Epilepsy', 'Other', 'Allergic', 'Physical Activity / APD'];
        var P = { s1: 's1_', s2: 's2_', s3: 's3_' };

        // ===== field layout (one array per step; rendered into the cards below) =====
        // t: text | area | date | time | num | doctor | staff | pills | blood | list(datalist id in .list)
        var LAYOUT = {
            s1: [
                { g: 'Procedure & Vitals', i: 'fa-user-md', f: [
                    { c: 'Procedure_Date', l: 'Date of Procedure', t: 'date', r: 1 },
                    { c: 'Procedure_Name', l: 'Procedure', t: 'text', r: 1, w: 2 },
                    { c: 'Anaesthetist_ID', l: 'Anaesthetist', t: 'doctor', r: 1 },
                    { c: 'Weight_Kg', l: 'Weight (kg)', t: 'num' },
                    { c: 'Height_Cm', l: 'Height (cm)', t: 'num' },
                    { c: 'Pulse', l: 'Pulse (bpm)', t: 'num' },
                    { c: 'SpO2', l: 'SpO2 (%)', t: 'num' },
                    { c: 'BP', l: 'B.P (mmHg)', t: 'text', ph: '120/80' },
                    { c: 'Temp_F', l: 'Temp (&deg;F)', t: 'num' },
                    { c: 'Resp_Rate', l: 'R/R (per min)', t: 'num' }] },
                { g: 'History', i: 'fa-history', custom: 'history', f: [
                    { c: 'Family_History', l: 'Family History', t: 'area', span: 1 }] },
                { g: 'Examination', i: 'fa-stethoscope', f: [
                    { c: 'Phys_Exam', l: 'Phys Exam', t: 'area' },
                    { c: 'Resp_Exam', l: 'Resp', t: 'area' },
                    { c: 'CVS_Exam', l: 'CVS', t: 'area' },
                    { c: 'Other_Exam', l: 'Other', t: 'area' }] },
                { g: 'Airway Assessment', i: 'fa-heartbeat', f: [
                    { c: 'Mallampati_Grade', l: 'Mallampati Grade', t: 'pills', o: ['I', 'II', 'III', 'IV'] },
                    { c: 'Mandibular_Protrusion', l: 'Mandibular Protrusion', t: 'pills', o: ['A', 'B', 'C'] },
                    { c: 'Atlantooccipital_Ext', l: 'Atlantooccipital Ext.', t: 'text' },
                    { c: 'Neck_Circumference', l: 'Neck Circumference', t: 'text' },
                    { c: 'Thyromental_Distance', l: 'Thyromental Distance', t: 'text' },
                    { c: 'Teeth', l: 'Teeth', t: 'text' },
                    { c: 'Airway_Others', l: 'Others', t: 'text', w: 2 }] },
                { g: 'Medication & Advice', i: 'fa-medkit', f: [
                    { c: 'Routine_Medication', l: 'Routine Medication (if any)', t: 'area', span: 1 },
                    { c: 'Advised_Rx_Night', l: 'Advised Rx: Night before Surgery', t: 'area' },
                    { c: 'Advised_Rx_Morning', l: 'Advised Rx: on Morning of Surgery', t: 'area' },
                    { c: 'Pre_Medication', l: 'Pre-medication', t: 'text', span: 1 }] },
                { g: 'Investigations', i: 'fa-flask', f: [
                    { c: 'Blood_Group', l: 'Blood Group', t: 'blood' },
                    { c: 'Hb', l: 'Hb', t: 'text' }, { c: 'PLT', l: 'PLT', t: 'text' }, { c: 'WBC', l: 'WBC', t: 'text' },
                    { c: 'BSL', l: 'BSL', t: 'text' }, { c: 'RETS', l: 'RETS', t: 'text' },
                    { c: 'CXR', l: 'CXR', t: 'text' }, { c: 'ECG', l: 'ECG', t: 'text' },
                    { c: 'Investigations_Others', l: 'Others', t: 'area', span: 1 }] },
                { g: 'ASA Status, Plan & Sign-off', i: 'fa-clipboard', f: [
                    { c: 'ASA_Status', l: 'ASA Status', t: 'pills', o: ['I', 'II', 'III', 'IV', 'V', 'E'], r: 1, span: 1 },
                    { c: 'Anticipated_Problems', l: 'Anticipated Problems', t: 'area', span: 1 },
                    { c: 'Consultant_Advice', l: 'Consultant Advice', t: 'area', span: 1 },
                    { c: 'Anesthetic_Plan', l: 'Anesthetic Plan', t: 'area', span: 1 },
                    { c: 'Assessed_By_ID', l: "Doctor's Name", t: 'doctor', r: 1 },
                    { c: 'Assessment_Date', l: 'Date of Assessment', t: 'date', r: 1 }] }
            ],
            s2: [
                { g: 'Case Details', i: 'fa-file-text-o', f: [
                    { c: 'Op_Date', l: 'Date', t: 'date' },
                    { c: 'Operation', l: 'Operation', t: 'text', w: 2 },
                    { c: 'Diagnosis', l: 'Diagnosis', t: 'text', w: 2 },
                    { c: 'Anaesthetist_ID', l: 'Anesthetist', t: 'doctor' },
                    { c: 'Surgeon_ID', l: 'Surgeon', t: 'doctor', r: 1 },
                    { c: 'Hemoglobin', l: 'Hemoglobin', t: 'text' },
                    { c: 'Age_Weight', l: 'Age / Wt.', t: 'text' },
                    { c: 'Bed_No', l: 'Bed No.', t: 'text' },
                    { c: 'Room_Ward', l: 'Room / Ward', t: 'text' },
                    { c: 'Blood_No', l: 'Blood No.', t: 'text' },
                    { c: 'Blood_Pressure', l: 'Blood Pressure', t: 'text' },
                    { c: 'Premedication', l: 'Premedication', t: 'text' },
                    { c: 'Time_Given', l: 'Time Given', t: 'time' },
                    { c: 'Id_Verified_By', l: 'Pt. I.D Verified By', t: 'text' }] },
                { g: 'Pre-induction Re-evaluation of Patient', i: 'fa-search', f: [
                    { c: 'Type_Of_Anesthesia', l: 'Type of Anesthesia', t: 'list', list: 'dlAnesType', r: 1 },
                    { c: 'Preop_Condition', l: 'Preoperative Condition', t: 'text', w: 2 },
                    { c: 'Drugs', l: 'Drugs', t: 'text', span: 1 },
                    { c: 'ASA_Status', l: 'ASA', t: 'pills', o: ['I', 'II', 'III', 'IV', 'V', 'E'], span: 1 }] },
                { g: 'Induction', i: 'fa-tint', f: [
                    { c: 'Induction_Notes', l: 'Induction', t: 'area', span: 1 },
                    { c: 'Inhalation_Agent', l: 'Halo / Iso / Ent / Sevo', t: 'pills', o: ['Halo', 'Iso', 'Ent', 'Sevo'] },
                    { c: 'IV_Drugs', l: 'I.V.', t: 'area', w: 2 }] },
                { g: 'Airway', i: 'fa-stethoscope', f: [
                    { c: 'Airway_Mask', l: 'Mask', t: 'text' }, { c: 'Airway_LMA', l: 'LMA', t: 'text' },
                    { c: 'Airway_Tube', l: 'Tube', t: 'text' },
                    { c: 'Airway_Route', l: 'Oral / Nasal', t: 'pills', o: ['Oral', 'Nasal'] },
                    { c: 'Airway_Size', l: 'Size', t: 'text' }, { c: 'Airway_Cuff_Pack', l: 'Cuff / Pack', t: 'text' },
                    { c: 'Airway_Position', l: 'Position', t: 'text' }] },
                { g: 'Maintenance', i: 'fa-cogs', f: [
                    { c: 'Maintenance_Mode', l: 'Mode', t: 'pills', o: ['Spontaneous', 'Controlled'] },
                    { c: 'Maint_O2', l: 'O&#8322;', t: 'text' }, { c: 'Maint_N2O', l: 'N&#8322;O', t: 'text' },
                    { c: 'Maint_VI', l: 'VI', t: 'text' }, { c: 'Maint_RR', l: 'RR', t: 'text' },
                    { c: 'Airway_Pressure', l: 'Airway Pressure', t: 'text' }] },
                { g: 'Monitoring Chart', i: 'fa-line-chart', custom: 'vitals', f: [
                    { c: 'Total_Blood_Loss', l: 'Blood Loss', t: 'text' },
                    { c: 'Total_Urine_Output', l: 'Urine Output', t: 'text' }] },
                { g: 'Recovery & Handover', i: 'fa-ambulance', f: [
                    { c: 'Recovery_Notes', l: 'Recovery from anesthesia while shifting from O.T. to Recovery Room', t: 'area', span: 1 },
                    { c: 'Comments_OT_To_RR', l: 'Comments while shifting from O.T. to Recovery Room', t: 'area', span: 1 },
                    { c: 'Notes_RR_To_Room', l: 'Notes on shifting from R.R. to Patient Room', t: 'area', span: 1 },
                    { c: 'Anesthetist_Sign', l: 'Name & Sign of Anesthetist', t: 'text', w: 2 },
                    { c: 'Sign_Time', l: 'Time', t: 'time' }] }
            ],
            s3: [
                { g: 'Operation Details', i: 'fa-hospital-o', f: [
                    { c: 'Bed_Room_No', l: 'Bed / Room No.', t: 'text' },
                    { c: 'Op_Date', l: 'Date of Operation', t: 'date', r: 1 },
                    { c: 'Op_Time', l: 'Time', t: 'time' },
                    { c: 'PreOp_Dx', l: 'Pre-op Diagnosis', t: 'text', w: 2 },
                    { c: 'PostOp_Dx', l: 'Post-op Diagnosis', t: 'text', w: 2 },
                    { c: 'Surgeon_ID', l: 'Surgeon Name', t: 'doctor', r: 1 },
                    { c: 'Assistants', l: 'Assistants', t: 'text' },
                    { c: 'Anaesthetist_ID', l: 'Anaesthetist Name', t: 'doctor', r: 1 },
                    { c: 'Type_Of_Anaesthesia', l: 'Type of Anaesthesia', t: 'list', list: 'dlAnesType' },
                    { c: 'Procedure_Name', l: 'Name of Procedure', t: 'text', r: 1, w: 2 },
                    { c: 'Duration', l: 'Duration of Procedure', t: 'text' }] },
                { g: 'Threads Used', i: 'fa-random', f: [
                    { c: 'Thread_Catgut', l: '1 - Catgut', t: 'text' }, { c: 'Thread_Vicryl', l: '2 - Vicryl', t: 'text' },
                    { c: 'Thread_Proline', l: '3 - Proline', t: 'text' }, { c: 'Thread_Silk', l: '4 - Silk', t: 'text' }] },
                { g: 'Procedure Notes', i: 'fa-pencil-square-o', f: [
                    { c: 'Procedure_Notes', l: 'Procedure Notes', t: 'area', span: 1, tall: 1 }] },
                { g: 'Scrub Nurse Notes', i: 'fa-user-md', f: [
                    { c: 'Blood_Loss', l: 'Blood Loss', t: 'text' },
                    { c: 'IV_Fluids', l: 'Intra-operative I.V Fluids', t: 'text' },
                    { c: 'Blood_Transfused', l: 'Blood Transfused', t: 'text' },
                    { c: 'Urine_Output', l: 'Intra-operative Urine Output', t: 'text' },
                    { c: 'Swab_Instrument_Count', l: 'Swab / Instrument Counting', t: 'list', list: 'dlCount' },
                    { c: 'Scrub_Nurse_ID', l: 'Scrub Nurse Name & Sign', t: 'staff' }] }
            ]
        };

        // ===== helpers =====
        function esc(s) { return $('<div>').text(s == null ? '' : s).html(); }
        function warn(text) { Swal.fire({ icon: 'warning', title: 'Warning!', text: text, timer: 2200, showConfirmButton: false }); }
        function todayStr() { var d = new Date(); return d.getFullYear() + '-' + ('0' + (d.getMonth() + 1)).slice(-2) + '-' + ('0' + d.getDate()).slice(-2); }
        function nowTime() { var d = new Date(); return ('0' + d.getHours()).slice(-2) + ':' + ('0' + d.getMinutes()).slice(-2); }
        function call(method, args, cb) {
            $.ajax({
                type: 'POST', url: 'AnesthesiaForm.aspx/' + method, data: JSON.stringify(args || {}),
                contentType: 'application/json; charset=utf-8', dataType: 'json',
                success: function (r) { var o = JSON.parse(r.d); cb(o); },
                error: function (xhr) { cb({ ok: false, msg: 'Server error (' + xhr.status + ')' }); }
            });
        }

        // ===== rendering =====
        function fieldHtml(step, f) {
            var id = P[step] + f.c, cls = 'ph-field dialysis-field' + (f.span ? ' dl-span-all' : '') + (f.w == 2 ? ' dl-span-2' : '');
            var req = f.r ? '<span class="required">*</span>' : '';
            var lab = '<label for="' + id + '">' + f.l + req + '</label>', ctl = '';
            var base = 'id="' + id + '" data-col="' + f.c + '"' + (f.r ? ' data-req="1"' : '');
            switch (f.t) {
                case 'text': ctl = '<input type="text" class="form-control" ' + base + (f.ph ? ' placeholder="' + f.ph + '"' : '') + ' maxlength="500" />'; break;
                case 'num': ctl = '<input type="number" step="0.1" class="form-control" ' + base + ' />'; break;
                case 'date': ctl = '<input type="date" class="form-control" ' + base + ' />'; break;
                case 'time': ctl = '<input type="time" class="form-control" ' + base + ' />'; break;
                case 'area': ctl = '<textarea class="form-control' + (f.tall ? ' an-tall' : '') + '" rows="' + (f.tall ? 10 : 2) + '" ' + base + '></textarea>'; break;
                case 'doctor': ctl = '<select class="form-control an-doctor" ' + base + '><option value="">Select</option></select>'; break;
                case 'staff': ctl = '<select class="form-control an-staff" ' + base + '><option value="">Select</option></select>'; break;
                case 'blood':
                    ctl = '<select class="form-control" ' + base + '><option value="">Select</option>' +
                        ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'].map(function (b) { return '<option>' + b + '</option>'; }).join('') + '</select>'; break;
                case 'list': ctl = '<input type="text" class="form-control" list="' + f.list + '" ' + base + ' maxlength="100" />'; break;
                case 'pills':
                    ctl = '<div class="an-pills" data-for="' + id + '">' + f.o.map(function (o) { return '<button type="button" class="an-pill" data-val="' + o + '">' + o + '</button>'; }).join('') +
                        '</div><input type="hidden" ' + base + ' />'; break;
            }
            return '<div class="' + cls + '">' + lab + ctl + '</div>';
        }

        function renderStep(step) {
            var html = '';
            $.each(LAYOUT[step], function (gi, g) {
                html += '<h6 class="dl-group"><i class="fa ' + g.i + '"></i> ' + g.g + '</h6>';
                if (g.custom === 'history') html += '<div class="an-history" id="historyGrid"></div>';
                if (g.custom === 'vitals') html += vitalsHtml();
                html += '<div class="ph-grid dl-grid">' + g.f.map(function (f) { return fieldHtml(step, f); }).join('') + '</div>';
            });
            $('#' + step + 'Body').html(html);
        }

        function renderHistory() {
            $('#historyGrid').html(HISTORY_ITEMS.map(function (name, i) {
                return '<div class="an-hx" data-item="' + esc(name) + '">' +
                    '<button type="button" class="an-hx-toggle" aria-pressed="false"><i class="fa fa-square-o"></i> ' + esc(name) + '</button>' +
                    '<input type="text" class="form-control an-hx-note" placeholder="Details" maxlength="300" /></div>';
            }).join(''));
        }

        function vitalsHtml() {
            return '<div class="dl-toolbar"><h6>Record readings through the operation. The chart below follows the table.</h6>' +
                '<div class="dl-actions"><button type="button" class="dl-btn dl-btn-outline" id="btnNowRow"><i class="fa fa-clock-o"></i> Add Reading Now</button>' +
                '<button type="button" class="dl-btn dl-btn-primary" id="btnAddVital"><i class="fa fa-plus"></i> Add Row</button></div></div>' +
                '<div class="dl-table-wrap"><table id="tblVitals"><thead><tr><th>Time</th><th>BP-Sys</th><th>BP-Dias</th><th>Pulse</th><th>SpO2 %</th><th>RR</th><th>Drug / Event</th><th>Action</th></tr></thead>' +
                '<tbody id="vitalBody"></tbody></table>' +
                '<div class="dl-state" id="vitalEmpty" style="display:block;"><i class="fa fa-heartbeat"></i> No readings yet. Use <b>Add Row</b> or <b>Add Reading Now</b>.</div></div>' +
                '<div class="an-chart-wrap"><div class="an-legend"><span class="lg lg-sys"></span>Systolic <span class="lg lg-dia"></span>Diastolic <span class="lg lg-pul"></span>Pulse</div><svg id="vitalChart" viewBox="0 0 800 270" preserveAspectRatio="none"></svg></div>';
        }

        function addVitalRow(v) {
            v = v || {};
            var row = '<tr>' +
                '<td><input type="time" class="form-control vt-time" value="' + (v.Chart_Time || '') + '" /></td>' +
                '<td><input type="number" class="form-control vt-sys" value="' + (v.BP_Sys == null ? '' : v.BP_Sys) + '" /></td>' +
                '<td><input type="number" class="form-control vt-dia" value="' + (v.BP_Dias == null ? '' : v.BP_Dias) + '" /></td>' +
                '<td><input type="number" class="form-control vt-pul" value="' + (v.Pulse == null ? '' : v.Pulse) + '" /></td>' +
                '<td><input type="number" class="form-control vt-spo" value="' + (v.SpO2 == null ? '' : v.SpO2) + '" /></td>' +
                '<td><input type="number" class="form-control vt-rr" value="' + (v.Resp_Rate == null ? '' : v.Resp_Rate) + '" /></td>' +
                '<td><input type="text" class="form-control vt-note" maxlength="200" value="' + esc(v.Drug_Event || '') + '" /></td>' +
                '<td><button type="button" class="btn btn-sm btn-danger vt-del"><i class="fa fa-trash"></i></button></td></tr>';
            $('#vitalBody').append(row);
            vitalsChanged();
        }

        function getVitals() {
            var rows = [];
            $('#vitalBody tr').each(function () {
                var $r = $(this);
                rows.push({ Chart_Time: $r.find('.vt-time').val(), BP_Sys: $r.find('.vt-sys').val(), BP_Dias: $r.find('.vt-dia').val(),
                    Pulse: $r.find('.vt-pul').val(), SpO2: $r.find('.vt-spo').val(), Resp_Rate: $r.find('.vt-rr').val(), Drug_Event: $r.find('.vt-note').val() });
            });
            rows.sort(function (a, b) { return (a.Chart_Time || '99:99') < (b.Chart_Time || '99:99') ? -1 : 1; });
            return rows;
        }

        function vitalsChanged() {
            $('#vitalEmpty').toggle($('#vitalBody tr').length === 0);
            drawChart();
        }

        // Plain SVG chart on the 10-190 scale of the paper sheet.
        function drawChart() {
            var rows = getVitals(), W = 800, H = 270, L = 38, R = 12, T = 10, B = 24, svg = '';
            function y(v) { return T + (H - T - B) * (1 - (v - 10) / 180); }
            for (var g = 10; g <= 190; g += 20) {
                svg += '<line x1="' + L + '" x2="' + (W - R) + '" y1="' + y(g) + '" y2="' + y(g) + '" class="an-grid"/><text x="' + (L - 6) + '" y="' + (y(g) + 3) + '" class="an-axis" text-anchor="end">' + g + '</text>';
            }
            var n = rows.length;
            function x(i) { return n <= 1 ? (L + W - R) / 2 : L + 20 + (W - L - R - 40) * i / (n - 1); }
            function series(key, cls, shape) {
                var pts = [], marks = '';
                rows.forEach(function (r, i) {
                    var v = parseFloat(r[key]); if (isNaN(v)) return;
                    v = Math.max(10, Math.min(190, v)); var px = x(i), py = y(v);
                    pts.push(px + ',' + py);
                    marks += shape === 'dn' ? '<path d="M' + (px - 5) + ',' + (py - 5) + ' L' + (px + 5) + ',' + (py - 5) + ' L' + px + ',' + (py + 5) + ' Z" class="' + cls + ' fill"/>'
                        : shape === 'up' ? '<path d="M' + (px - 5) + ',' + (py + 5) + ' L' + (px + 5) + ',' + (py + 5) + ' L' + px + ',' + (py - 5) + ' Z" class="' + cls + ' fill"/>'
                        : '<circle cx="' + px + '" cy="' + py + '" r="4" class="' + cls + ' fill"/>';
                });
                return (pts.length > 1 ? '<polyline points="' + pts.join(' ') + '" class="' + cls + ' line"/>' : '') + marks;
            }
            svg += series('BP_Sys', 'sys', 'dn') + series('BP_Dias', 'dia', 'up') + series('Pulse', 'pul', 'dot');
            rows.forEach(function (r, i) { if (r.Chart_Time) svg += '<text x="' + x(i) + '" y="' + (H - 8) + '" class="an-axis" text-anchor="middle">' + r.Chart_Time + '</text>'; });
            $('#vitalChart').html(svg);
        }

        // ===== reading / writing field values =====
        function collect(sel) {
            var o = {};
            $(sel).find('[data-col]').each(function () { o[$(this).data('col')] = $(this).val(); });
            return o;
        }
        function fillValues(sel, obj, onlyEmpty) {
            if (!obj) return;
            $(sel).find('[data-col]').each(function () {
                var $e = $(this), k = $e.data('col');
                if (!(k in obj) || obj[k] == null) return;
                if (onlyEmpty && $e.val()) return;
                setVal($e, String(obj[k]));
            });
        }
        function setVal($e, v) {
            $e.val(v);
            if ($e.is('select')) $e.trigger('change');
            if ($e.is('input[type=hidden]')) syncPills($e);
        }
        function syncPills($hidden) {
            var wrap = $('.an-pills[data-for="' + $hidden.attr('id') + '"]');
            wrap.find('.an-pill').each(function () { $(this).toggleClass('on', $(this).data('val') == $hidden.val()); });
        }
        function checkRequired(sel) {
            var bad = [];
            $(sel).find('[data-req="1"]').each(function () {
                var $e = $(this), empty = !$e.val(), $vis = $e.is('select') ? $e.next('.select2-container').find('.select2-selection') : ($e.is('input[type=hidden]') ? $('.an-pills[data-for="' + $e.attr('id') + '"]') : $e);
                $vis.toggleClass('is-invalid', empty);
                if (empty) bad.push($e.closest('.ph-field').find('label').first().text().replace('*', '').trim());
            });
            return bad;
        }

        // ===== steps =====
        function goStep(n, silent) {
            for (var k = 1; k < n; k++) {
                if (!flags[k]) { if (!silent) warn('Please save Step ' + k + ' first'); return; }
            }
            if (n === 2 && !flags[2]) prefillStep2();
            if (n === 3 && !flags[3]) prefillStep3();
            $('.form-section').removeClass('active'); $('.step-item').removeClass('active');
            $('#section' + n).addClass('active'); $('#step' + n + 'Nav').addClass('active');
            $('html, body').animate({ scrollTop: 0 }, 150);
        }
        function markSaved(n) {
            flags[n] = true;
            $('#step' + n + 'Nav').addClass('completed');
            if (n < 3) $('#step' + (n + 1) + 'Nav').removeClass('disabled');
        }
        function setCaseId(id) { caseId = id; $('#infoCaseId').text(id || 'assigned on first save'); $('.an-print').toggle(!!id); }

        function docVal(sel) { return $(sel).val() || ''; }
        function prefillStep2() {
            var pre = collect('#section1'), age = $('#infoAge').text();
            fillValues('#section2', {
                Op_Date: pre.Procedure_Date, Operation: pre.Procedure_Name, Anaesthetist_ID: pre.Anaesthetist_ID, Hemoglobin: pre.Hb,
                Blood_Pressure: pre.BP, Premedication: pre.Pre_Medication, ASA_Status: pre.ASA_Status,
                Age_Weight: (age || '') + (pre.Weight_Kg ? ' / ' + pre.Weight_Kg + ' kg' : '')
            }, true);
        }
        function prefillStep3() {
            var s2 = collect('#section2');
            fillValues('#section3', {
                Op_Date: s2.Op_Date, PreOp_Dx: s2.Diagnosis, Surgeon_ID: s2.Surgeon_ID, Anaesthetist_ID: s2.Anaesthetist_ID,
                Type_Of_Anaesthesia: s2.Type_Of_Anesthesia, Procedure_Name: s2.Operation,
                Bed_Room_No: [s2.Bed_No, s2.Room_Ward].filter(function (x) { return x; }).join(' / '),
                Urine_Output: s2.Total_Urine_Output, Blood_Loss: s2.Total_Blood_Loss
            }, true);
        }

        function done(r, step, btn, extra) {
            $(btn).prop('disabled', false);
            if (!r.ok) { Swal.fire({ icon: 'error', title: 'Error!', text: r.msg, showConfirmButton: true }); return false; }
            Swal.fire({ icon: 'success', title: 'Success!', text: (extra || ('Step ' + step)) + (r.msg === 'updated' ? ' updated successfully' : ' saved successfully'), timer: 1800, showConfirmButton: false });
            return true;
        }

        function saveStep1() {
            if (!patientId) { warn('Please select a patient first'); return; }
            var bad = checkRequired('#section1');
            if (bad.length) { warn('Please fill: ' + bad.join(', ')); return; }
            var data = collect('#section1'); data.AnesthesiaId = caseId; data.PatientId = patientId;
            data.History = $('#historyGrid .an-hx').map(function () {
                return { Item: $(this).data('item'), Present: $(this).find('.an-hx-toggle').attr('aria-pressed') === 'true', Notes: $(this).find('.an-hx-note').val() };
            }).get();
            $('#btnSaveStep1').prop('disabled', true);
            call('SavePreOp', { data: JSON.stringify(data) }, function (r) {
                if (!done(r, 1, '#btnSaveStep1')) return;
                setCaseId(r.data.AnesthesiaId); markSaved(1); goStep(2);
            });
        }
        function saveStep2() {
            var bad = checkRequired('#section2');
            if (bad.length) { warn('Please fill: ' + bad.join(', ')); return; }
            var vit = getVitals().filter(function (v) { return v.Chart_Time; });
            if (!vit.length) { warn('Please add at least one monitoring reading with a time'); return; }
            var data = collect('#section2'); data.AnesthesiaId = caseId; data.Vitals = vit;
            $('#btnSaveStep2').prop('disabled', true);
            call('SaveIntraOp', { data: JSON.stringify(data) }, function (r) {
                if (!done(r, 2, '#btnSaveStep2')) return;
                markSaved(2); goStep(3);
            });
        }
        function saveStep3() {
            var bad = checkRequired('#section3');
            if (bad.length) { warn('Please fill: ' + bad.join(', ')); return; }
            var data = collect('#section3'); data.AnesthesiaId = caseId;
            $('#btnSaveStep3').prop('disabled', true);
            call('SaveOpNotes', { data: JSON.stringify(data) }, function (r) {
                if (!done(r, 3, '#btnSaveStep3', 'Anesthesia record')) return;
                markSaved(3);
                $('#dlMode').html('<i class="fa fa-check-circle"></i> Record complete');
            });
        }

        // ===== patient =====
        function showPatient(p) {
            patientId = p.PatientId;
            $('#infoPatientName').text(p.Name); $('#infoMrNo').text(p.MRNo); $('#infoAge').text(p.Age);
            $('#infoGender').text(p.Gender); $('#infoContact').text(p.Contact);
            $('#patientBar').show(); $('#emptyState').hide(); $('#stepsWrap').show();
        }
        function resetForm() {
            $('#stepsWrap [data-col]').each(function () { var $e = $(this); $e.val(''); if ($e.is('select')) $e.trigger('change'); if ($e.is('input[type=hidden]')) syncPills($e); });
            $('.an-hx-toggle').attr('aria-pressed', 'false').find('i').attr('class', 'fa fa-square-o'); $('.an-hx').removeClass('on'); $('.an-hx-note').val('');
            $('#vitalBody').empty(); vitalsChanged();
            flags = { 1: false, 2: false, 3: false }; setCaseId('');
            $('.step-item').removeClass('active completed').addClass('disabled'); $('#step1Nav').removeClass('disabled');
            $('#s1_Assessment_Date').val(todayStr()); $('#s1_Procedure_Date').val(todayStr());
        }
        function pickPatient(p) {
            if (patientId && caseId && !confirm('Start a new anesthesia record for this patient? The current one stays saved.')) return;
            resetForm(); showPatient(p); goStep(1, true); $('#PatientsSearchModel').modal('hide');
        }
        function searchPatients(text) {
            call('SearchPatients', { searchText: text }, function (r) {
                var $b = $('#iPatientsBody').empty();
                if (!r.ok || !r.data.length) { $b.append('<tr><td colspan="6" class="text-center">No admitted patients found</td></tr>'); return; }
                $.each(r.data, function (i, p) {
                    var $tr = $('<tr>').append($('<td>').text(p.MRNo), $('<td>').text(p.Name), $('<td>').text(p.Father), $('<td>').text(p.Contact), $('<td>').text(p.AdmittedOn));
                    var $btn = $('<button type="button" class="btn btn-sm btn-primary"><i class="fa fa-plus"></i></button>').on('click', function () {
                        call('GetPatient', { patientId: p.PatientId }, function (g) { if (g.ok) pickPatient(g.data); });
                    });
                    $b.append($tr.append($('<td>').append($btn)));
                });
            });
        }

        // ===== edit mode =====
        function loadCase(id) {
            call('GetCase', { anesthesiaId: id }, function (r) {
                if (!r.ok) { Swal.fire({ icon: 'error', title: 'Error!', text: r.msg }); $('#emptyState').show(); return; }
                var c = r.data; isEditMode = true;
                $('#dlMode').html('<i class="fa fa-pencil"></i> Editing record');
                setCaseId(c.AnesthesiaId); showPatient(c.Patient);
                fillValues('#section1', c.PreOp);
                $.each(c.History || [], function (i, h) {
                    var $row = $('#historyGrid .an-hx').filter(function () { return $(this).data('item') === h.Item; });
                    if (h.Present) setHx($row, true);
                    $row.find('.an-hx-note').val(h.Notes || '');
                });
                markSaved(1);
                if (c.IntraOp) { fillValues('#section2', c.IntraOp); markSaved(2); }
                $.each(c.Vitals || [], function (i, v) { addVitalRow(v); });
                if (c.OpNotes) { fillValues('#section3', c.OpNotes); markSaved(3); }
                goStep(1, true);
            });
        }
        function setHx($row, on) {
            $row.toggleClass('on', on);
            $row.find('.an-hx-toggle').attr('aria-pressed', on ? 'true' : 'false').find('i').attr('class', on ? 'fa fa-check-square' : 'fa fa-square-o');
        }

        // ===== init =====
        $(document).ready(function () {
            renderStep('s1'); renderStep('s2'); renderStep('s3'); renderHistory(); vitalsChanged();
            $('#s1_Assessment_Date').val(todayStr()); $('#s1_Procedure_Date').val(todayStr());

            $(document).on('click', '.an-pill', function () {
                var $p = $(this), $h = $('#' + $p.closest('.an-pills').data('for'));
                $h.val($h.val() == $p.data('val') ? '' : $p.data('val')); syncPills($h); $p.closest('.an-pills').removeClass('is-invalid');
            });
            $(document).on('click', '.an-hx-toggle', function () { var $r = $(this).closest('.an-hx'); setHx($r, $(this).attr('aria-pressed') !== 'true'); });
            $(document).on('input', '.an-hx-note', function () { if ($(this).val()) setHx($(this).closest('.an-hx'), true); });
            $(document).on('click', '.vt-del', function () { $(this).closest('tr').remove(); vitalsChanged(); });
            $(document).on('input change', '#vitalBody input', drawChart);
            $(document).on('click', '#btnAddVital', function () { addVitalRow(); });
            $(document).on('click', '#btnNowRow', function () { addVitalRow({ Chart_Time: nowTime() }); });
            $(document).on('input change', '#stepsWrap .is-invalid', function () { $(this).removeClass('is-invalid'); });

            $('#btnSaveStep1').on('click', saveStep1); $('#btnSaveStep2').on('click', saveStep2); $('#btnSaveStep3').on('click', saveStep3);
            $('#btnBack2').on('click', function () { goStep(1); }); $('#btnBack3').on('click', function () { goStep(2); });
            $('.step-item').on('click', function () { goStep(parseInt($(this).data('step'), 10)); });
            $('#btnSelectPatient').on('click', function () { $('#txtPatientSearch').val(''); $('#PatientsSearchModel').modal({ backdrop: 'static' }); searchPatients(''); setTimeout(function () { $('#txtPatientSearch').focus(); }, 400); });
            var t; $('#txtPatientSearch').on('input', function () { var v = $(this).val(); clearTimeout(t); t = setTimeout(function () { searchPatients(v); }, 300); });
            $('.an-newform').on('click', function () { window.location.href = 'AnesthesiaForm.aspx'; });
            $('.an-list').on('click', function () { window.location.href = 'AnesthesiaView.aspx'; });
            $('.an-printbtn').on('click', function () { if (caseId) window.open('AnesthesiaPrint.aspx?ID=' + encodeURIComponent(caseId), '_blank'); });

            call('GetLookups', {}, function (r) {
                if (r.ok) {
                    lookups = r.data;
                    var opts = function (a) { return a.map(function (x) { return '<option value="' + x.id + '">' + esc(x.name) + '</option>'; }).join(''); };
                    $('select.an-doctor').append(opts(lookups.doctors)); $('select.an-staff').append(opts(lookups.staff));
                }
                $('#stepsWrap select').select2({ width: '100%' });
                var id = new URLSearchParams(window.location.search).get('ID');
                if (id) loadCase(id);
            });
        });
    </script>
    <style>
        .dl-page { display: flex; flex-direction: column; gap: 16px; width: 100%; margin: 0 0 24px; }
        .dl-head { display: flex; flex-wrap: wrap; align-items: center; justify-content: space-between; gap: 12px 20px; padding: 0 6px; }
        .dl-head h2 { margin: 0; font-size: 22px; font-weight: 800; color: var(--theme-ink, #1b2a41) !important; }
        .dl-head h2 > i { margin-right: 6px; color: var(--theme-accent, #438eb9); }
        .dl-head p { margin: 2px 0 0; font-size: 13px; color: #6b7686; }
        .dl-badge { display: inline-flex; align-items: center; gap: 6px; margin-left: 10px; padding: 3px 10px; font-size: 12px; font-weight: 700; vertical-align: middle; border-radius: 999px; color: var(--theme-accent-ink, #2b6a90); background: var(--theme-accent-soft, #e8f1f8); }
        .dl-actions { display: flex; flex-wrap: wrap; gap: 8px; }
        .dl-page .dl-btn { display: inline-flex; align-items: center; justify-content: center; gap: 7px; width: auto; min-width: 0; height: 36px; margin: 0; padding: 0 18px; font-size: 13px; font-weight: 700; line-height: 1; white-space: nowrap; cursor: pointer; border-radius: 6px; border: 1px solid transparent; transition: filter .15s ease; }
        .dl-page .dl-btn:hover { filter: brightness(.95); }
        .dl-page .dl-btn:disabled { opacity: .6; cursor: not-allowed; }
        .dl-btn-primary { color: var(--theme-on-accent, #fff); background: var(--theme-accent, #438eb9); }
        .dl-btn-success { color: #fff; background: #2e9e5b; }
        .dl-btn-outline { color: var(--theme-accent-ink, #2b6a90); background: #fff; border-color: var(--theme-accent, #438eb9) !important; }
        .dl-btn-quiet { color: #4a5568; background: #eef1f5; border-color: #dde3ea !important; }

        .dl-page .dl-patientbar { display: grid; grid-template-columns: minmax(0, 1fr) minmax(0, 1.1fr); gap: 20px 28px; align-items: center; padding: 16px; }
        @media (max-width: 991px) { .dl-page .dl-patientbar { grid-template-columns: minmax(0, 1fr); } }
        .dl-patient { display: flex; align-items: center; gap: 14px; min-width: 0; }
        .dl-avatar { flex: 0 0 auto; display: flex; align-items: center; justify-content: center; width: 64px; height: 64px; overflow: hidden; border-radius: 50%; background: var(--theme-accent-soft, #e8f1f8); }
        .dl-avatar img { width: 42px; height: auto; }
        .dl-patient-name { font-size: 17px; font-weight: 800; color: var(--theme-ink, #1b2a41); overflow-wrap: anywhere; }
        .dl-chips { display: flex; flex-wrap: wrap; gap: 6px 8px; margin-top: 6px; }
        .dl-chip { display: inline-flex; align-items: center; gap: 6px; padding: 3px 11px; font-size: 12px; font-weight: 600; color: #2d3748; background: #eef1f5; border-radius: 999px; }
        .dl-chip b { font-weight: 700; color: #6b7686; }
        .dl-steps { display: flex; align-items: flex-start; justify-content: center; padding: 4px 0; }
        .step-item { position: relative; flex: 0 0 auto; display: flex; flex-direction: column; align-items: center; gap: 6px; width: 110px; cursor: pointer; }
        .step-item.disabled { cursor: not-allowed; opacity: .55; }
        .step-icon { display: flex; align-items: center; justify-content: center; width: 44px; height: 44px; font-size: 18px; color: #6b7686; background: #e6eaf0; border-radius: 50%; transition: background .2s ease, box-shadow .2s ease; }
        .step-item.active .step-icon { color: var(--theme-on-accent, #fff); background: var(--theme-accent, #438eb9); box-shadow: 0 0 0 4px var(--theme-accent-ring, rgba(67, 142, 185, .25)); }
        .step-item.completed .step-icon { color: #fff; background: #2e9e5b; }
        .step-item.completed .step-icon i { display: none; }
        .step-item.completed .step-icon::after { content: "\f00c"; font-family: FontAwesome; font-size: 18px; }
        .step-label { font-size: 12px; font-weight: 700; color: #6b7686; text-align: center; }
        .step-item.active .step-label { color: var(--theme-accent-ink, #2b6a90); }
        .step-arrow { flex: 1 1 36px; max-width: 90px; height: 2px; margin-top: 21px; background: #d5dbe3; border-radius: 2px; }
        .step-item.completed + .step-arrow { background: #2e9e5b; }

        .form-section { display: none; }
        .form-section.active { display: flex; flex-direction: column; gap: 16px; animation: dlFade .25s ease; }
        @keyframes dlFade { from { opacity: 0; transform: translateY(6px); } to { opacity: 1; transform: none; } }
        .dl-group { display: flex; align-items: center; gap: 8px; margin: 22px 0 12px; padding-bottom: 6px; font-size: 12px; font-weight: 800; letter-spacing: .06em; text-transform: uppercase; color: var(--theme-accent-ink, #2b6a90); border-bottom: 1px solid #e3e8ee; }
        .dl-group:first-of-type { margin-top: 4px; }
        .dl-group i { font-size: 13px; opacity: .85; }
        .dl-grid { grid-template-columns: repeat(auto-fill, minmax(190px, 1fr)); }
        .dl-span-all { grid-column: 1 / -1; }
        .dl-span-2 { grid-column: span 2; }
        @media (max-width: 520px) { .dl-span-2 { grid-column: 1 / -1; } }
        .dl-page .required { margin-left: 2px; color: #c0392b; }
        .dl-page .ph-card textarea.form-control { display: block; width: 100%; min-height: 64px; padding: 8px 10px; font-size: 13px; font-weight: 600; resize: vertical; color: var(--theme-ink, #1b2a41); background: #fff; border: 1px solid #cfd6e0; border-radius: 6px; box-shadow: none; box-sizing: border-box; }
        .dl-page .ph-card textarea.an-tall { min-height: 220px; }
        .dl-page .ph-card textarea.form-control:focus { border-color: var(--theme-accent, #438eb9); box-shadow: 0 0 0 3px var(--theme-accent-ring, rgba(67, 142, 185, .25)); outline: none; }
        .dl-page .ph-card input[type="time"].form-control, .dl-page .ph-card input[type="date"].form-control, .dl-page .ph-card input[type="number"].form-control { padding-right: 8px !important; }
        .dl-page .is-invalid { border-color: #c0392b !important; box-shadow: 0 0 0 3px rgba(192, 57, 43, .15) !important; }
        .dl-page .select2-container { width: 100% !important; }
        .dl-actionbar { display: flex; flex-wrap: wrap; align-items: center; justify-content: flex-end; gap: 8px; }
        .dl-actionbar .dl-btn-back { margin-right: auto; }
        .an-empty { padding: 48px 16px; text-align: center; color: #6b7686; }
        .an-empty i { display: block; margin-bottom: 10px; font-size: 40px; color: var(--theme-accent, #438eb9); opacity: .7; }
        .an-empty h4 { margin: 0 0 4px; font-weight: 800; color: var(--theme-ink, #1b2a41); }

        /* pills (A/B/C, I-VI, Oral/Nasal ...) */
        .an-pills { display: flex; flex-wrap: wrap; gap: 6px; padding: 2px 0; border-radius: 8px; }
        .an-pill { min-width: 44px; height: 34px; padding: 0 14px; font-size: 13px; font-weight: 700; color: #4a5568; background: #eef1f5; border: 1px solid #dde3ea; border-radius: 999px; cursor: pointer; transition: background .15s, color .15s; }
        .an-pill:hover { background: #e2e8f0; }
        .an-pill.on { color: var(--theme-on-accent, #fff); background: var(--theme-accent, #438eb9); border-color: var(--theme-accent, #438eb9); }

        /* history toggles */
        .an-history { display: grid; grid-template-columns: repeat(auto-fill, minmax(240px, 1fr)); gap: 8px 12px; margin-bottom: 12px; }
        .an-hx { display: flex; flex-direction: column; gap: 6px; padding: 8px; border: 1px solid #e3e8ee; border-radius: 8px; background: #fafbfc; transition: border-color .15s, background .15s; }
        .an-hx.on { border-color: var(--theme-accent, #438eb9); background: var(--theme-accent-soft, #eef5fb); }
        .an-hx-toggle { display: flex; align-items: center; gap: 8px; padding: 0; font-size: 13px; font-weight: 700; text-align: left; color: #2d3748; background: none; border: 0; cursor: pointer; }
        .an-hx.on .an-hx-toggle { color: var(--theme-accent-ink, #2b6a90); }
        .an-hx-note { display: block; height: 30px; font-size: 12px; font-weight: 600; }
        .an-hx:not(.on) .an-hx-note { opacity: .75; }

        /* monitoring table + chart */
        .dl-toolbar { display: flex; flex-wrap: wrap; align-items: center; justify-content: space-between; gap: 10px; margin-bottom: 12px; }
        .dl-toolbar h6 { margin: 0; font-size: 13px; font-weight: 700; color: #4a5568; }
        .dl-table-wrap { margin: 0 -16px; overflow-x: auto; border-top: 1px solid #e3e8ee; }
        #tblVitals { width: 100%; margin: 0; border-collapse: separate; border-spacing: 0; }
        #tblVitals thead th { padding: 9px 10px; font-size: 11.5px; letter-spacing: .03em; text-transform: uppercase; white-space: nowrap; color: var(--theme-on-accent, #fff); background: var(--theme-accent, #438eb9); border: 0; border-bottom: 2px solid var(--theme-accent-ink, #2b6a90); }
        #tblVitals td { padding: 6px 8px; vertical-align: middle; border: 0; border-bottom: 1px solid #eef1f5; }
        #tblVitals td:last-child, #tblVitals th:last-child { width: 64px; text-align: center; }
        #vitalBody input.form-control { min-width: 76px; }
        #vitalBody input.vt-note { min-width: 180px; }
        #vitalBody .btn-danger { display: inline-flex; align-items: center; justify-content: center; width: 32px; height: 32px; padding: 0; color: #c0392b; background: #fdecea; border: 0; border-radius: 6px; }
        .dl-state { display: none; padding: 22px 16px; text-align: center; font-size: 13px; color: #8a94a6; }
        .dl-state i { display: block; margin-bottom: 6px; font-size: 26px; opacity: .6; }
        .an-chart-wrap { margin: 12px 0 6px; padding: 10px 12px; border: 1px solid #e3e8ee; border-radius: 8px; background: #fff; }
        #vitalChart { display: block; width: 100%; height: 270px; }
        .an-legend { display: flex; gap: 14px; align-items: center; font-size: 12px; font-weight: 700; color: #4a5568; margin-bottom: 4px; }
        .an-legend .lg { display: inline-block; width: 10px; height: 10px; border-radius: 50%; margin-right: 4px; }
        .lg-sys { background: #d64545; } .lg-dia { background: #2b6a90; } .lg-pul { background: #2e9e5b; }
        .an-grid { stroke: #e3e8ee; stroke-width: 1; } .an-axis { font-size: 11px; fill: #8a94a6; }
        #vitalChart .line { fill: none; stroke-width: 2; } #vitalChart .fill { stroke: none; }
        #vitalChart .sys { stroke: #d64545; fill: #d64545; } #vitalChart .dia { stroke: #2b6a90; fill: #2b6a90; } #vitalChart .pul { stroke: #2e9e5b; fill: #2e9e5b; }
        #vitalChart .line.sys, #vitalChart .line.dia, #vitalChart .line.pul { fill: none; }

        /* modal */
        .dl-page .modal-content { overflow: hidden; border: 0; border-radius: 10px; box-shadow: 0 20px 50px rgba(16, 24, 40, .3); }
        .dl-page .modal-header { display: flex; align-items: center; justify-content: space-between; padding: 12px 18px; color: var(--theme-on-accent, #fff); background: var(--theme-accent, #438eb9) !important; }
        .dl-page .modal-header::before, .dl-page .modal-header::after { display: none; }
        .dl-page .modal-title { margin: 0; font-size: 15px; font-weight: 800; letter-spacing: .03em; text-transform: uppercase; }
        .dl-page .modal-header .close { float: none; margin: 0 !important; padding: 0; line-height: 1; font-size: 26px; color: inherit; opacity: .9; text-shadow: none; }
        .dl-page .modal-body { max-height: 68vh; padding: 16px 18px; overflow-y: auto; }
        .dl-page .modal-footer { display: flex; justify-content: flex-end; gap: 8px; padding: 12px 18px; background: #f8fafc; border-top: 1px solid #e3e8ee; }
        .dl-modal label { display: block; margin: 0 0 4px; font-size: 11.5px; font-weight: 700; color: #4a5568; }
        .dl-modal input.form-control { width: 100%; height: 34px; padding: 4px 10px; font-size: 13px; font-weight: 600; border: 1px solid #cfd6e0; border-radius: 6px; box-shadow: none; box-sizing: border-box; }
        .dl-search-bar { margin-bottom: 12px; }
        .dl-table-scroll { max-height: 52vh; overflow: auto; border: 1px solid #e3e8ee; border-radius: 8px; }
        #tblPatientsResult { width: 100%; margin: 0; border-collapse: separate; border-spacing: 0; }
        #tblPatientsResult thead th { position: sticky; top: 0; z-index: 1; padding: 9px 12px; font-size: 11.5px; text-transform: uppercase; white-space: nowrap; color: var(--theme-on-accent, #fff); background: var(--theme-accent, #438eb9); border: 0; }
        #tblPatientsResult td { padding: 8px 12px; vertical-align: middle; border: 0; border-bottom: 1px solid #eef1f5; }
        #tblPatientsResult tbody tr:hover td { background: var(--theme-accent-soft, #f4f8fb); }
        #tblPatientsResult .btn-primary { display: inline-flex; align-items: center; justify-content: center; width: 32px; height: 32px; padding: 0; color: var(--theme-on-accent, #fff); background: var(--theme-accent, #438eb9); border: 0; border-radius: 6px; }

        html[data-theme="dark"] .dl-head h2, html[data-theme="dark"] .dl-patient-name, html[data-theme="dark"] .an-empty h4 { color: var(--dk-text, #e6e9ef) !important; }
        html[data-theme="dark"] .dl-head p, html[data-theme="dark"] .step-label { color: var(--dk-muted, #9aa6b8); }
        html[data-theme="dark"] .dl-chip, html[data-theme="dark"] .dl-btn-quiet, html[data-theme="dark"] .dl-btn-outline, html[data-theme="dark"] .an-pill { background: var(--dk-surface-3, #232d3d); color: var(--dk-text, #e6e9ef); border-color: var(--dk-border, #2d3748) !important; }
        html[data-theme="dark"] .an-pill.on { background: var(--theme-accent, #438eb9); color: #fff; }
        html[data-theme="dark"] .an-hx, html[data-theme="dark"] .an-chart-wrap { background: var(--dk-surface-3, #232d3d); border-color: var(--dk-border, #2d3748); }
        html[data-theme="dark"] .an-hx-toggle, html[data-theme="dark"] .an-legend { color: var(--dk-text, #e6e9ef); }
        html[data-theme="dark"] .step-icon { background: var(--dk-surface-3, #232d3d); color: var(--dk-muted, #9aa6b8); }
        html[data-theme="dark"] .dl-group, html[data-theme="dark"] .dl-table-wrap, html[data-theme="dark"] #tblVitals td, html[data-theme="dark"] #tblPatientsResult td { border-color: var(--dk-border, #2d3748); }
        html[data-theme="dark"] .dl-page .ph-card textarea.form-control { background: var(--dk-surface-3, #232d3d); color: var(--dk-text, #e6e9ef); border-color: var(--dk-border, #2d3748); }
        html[data-theme="dark"] .dl-page .modal-content { background: var(--dk-surface-2, #1c2431); color: var(--dk-text, #e6e9ef); }
        html[data-theme="dark"] .dl-page .modal-footer { background: var(--dk-surface-3, #232d3d); border-color: var(--dk-border, #2d3748); }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="dl-page">
        <div class="dl-head">
            <div>
                <h2><i class="fa fa-medkit"></i>Anesthesia Record <span class="dl-badge" id="dlMode"><i class="fa fa-plus-circle"></i> New record</span></h2>
                <p>Pre-op assessment, intra-operative sheet and operation notes. Each step opens only after the one before it is saved.</p>
            </div>
            <div class="dl-actions">
                <button type="button" class="dl-btn dl-btn-primary" id="btnSelectPatient"><i class="fa fa-search"></i> Select Patient</button>
                <button type="button" class="dl-btn dl-btn-quiet an-list"><i class="fa fa-eye"></i> View</button>
            </div>
        </div>

        <section class="ph-card dl-patientbar" id="patientBar" style="display: none;">
            <div class="dl-patient">
                <div class="dl-avatar"><img src="../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/Patient.png" alt="Patient" /></div>
                <div>
                    <div class="dl-patient-name" id="infoPatientName">-</div>
                    <div class="dl-chips">
                        <span class="dl-chip"><b>MR No</b> <span id="infoMrNo">-</span></span>
                        <span class="dl-chip"><b>Age</b> <span id="infoAge">-</span></span>
                        <span class="dl-chip"><b>Gender</b> <span id="infoGender">-</span></span>
                        <span class="dl-chip"><b>Contact</b> <span id="infoContact">-</span></span>
                        <span class="dl-chip"><b>Record</b> <span id="infoCaseId">assigned on first save</span></span>
                    </div>
                </div>
            </div>
            <div class="dl-steps">
                <div class="step-item active" id="step1Nav" data-step="1"><div class="step-icon"><i class="fa fa-clipboard"></i></div><div class="step-label">1. Pre-Op</div></div>
                <div class="step-arrow"></div>
                <div class="step-item disabled" id="step2Nav" data-step="2"><div class="step-icon"><i class="fa fa-heartbeat"></i></div><div class="step-label">2. Intra-Op</div></div>
                <div class="step-arrow"></div>
                <div class="step-item disabled" id="step3Nav" data-step="3"><div class="step-icon"><i class="fa fa-pencil-square-o"></i></div><div class="step-label">3. Operation Notes</div></div>
            </div>
        </section>

        <section class="ph-card an-empty" id="emptyState">
            <i class="fa fa-user-md"></i>
            <h4>Select a patient to begin</h4>
            <p>Click <b>Select Patient</b>, then fill the three steps in order.</p>
        </section>

        <div id="stepsWrap" style="display: none;">
            <datalist id="dlAnesType">
                <option value="General" /><option value="Spinal" /><option value="Epidural" /><option value="Regional Block" /><option value="Local" /><option value="Sedation" />
            </datalist>
            <datalist id="dlCount"><option value="Correct" /><option value="Incorrect" /></datalist>

            <div class="form-section active" id="section1">
                <section class="ph-card">
                    <h5 class="ph-card-title"><i class="fa fa-clipboard"></i> Pre-op Assessment</h5>
                    <div id="s1Body"></div>
                </section>
                <div class="row">
                <div class="col-lg-10">
                    <div class="row mtop2">
                        <div class="col-lg-2 col-md-3 col-sm-4">
                            <input type="button" class="btn-primry" id="btnSaveStep1" value="Save &amp; Next" />
                        </div>
                        <div class="col-lg-2 col-md-4 col-sm-4">
                            <input type="button" class="btn btn-yellow an-newform" value="New" />
                        </div>
                        <div class="col-lg-2 col-md-3 col-sm-4">
                            <input type="button" class="btn btn-gray an-list" value="View" />
                        </div>
                        <div class="col-lg-2 col-md-3 col-sm-4 an-print" style="display:none">
                            <input type="button" class="btn-primry an-printbtn" value="Print" />
                        </div>
                    </div>
                </div>
            </div>
            </div>

            <div class="form-section" id="section2">
                <section class="ph-card">
                    <h5 class="ph-card-title"><i class="fa fa-heartbeat"></i> Intra-operative Anesthesia Sheet</h5>
                    <div id="s2Body"></div>
                </section>
                <div class="row">
                <div class="col-lg-10">
                    <div class="row mtop2">
                        <div class="col-lg-2 col-md-3 col-sm-4">
                            <input type="button" class="btn-primry" id="btnSaveStep2" value="Save &amp; Next" />
                        </div>
                        <div class="col-lg-2 col-md-4 col-sm-4">
                            <input type="button" class="btn btn-yellow an-newform" value="New" />
                        </div>
                        <div class="col-lg-2 col-md-3 col-sm-4">
                            <input type="button" class="btn btn-gray an-list" value="View" />
                        </div>
                        <div class="col-lg-2 col-md-3 col-sm-4 an-print" style="display:none">
                            <input type="button" class="btn-primry an-printbtn" value="Print" />
                        </div>
                        <div class="col-lg-2 col-md-3 col-sm-4">
                            <input type="button" class="btn btn-gray" id="btnBack2" value="Back" />
                        </div>
                    </div>
                </div>
            </div>
            </div>

            <div class="form-section" id="section3">
                <section class="ph-card">
                    <h5 class="ph-card-title"><i class="fa fa-pencil-square-o"></i> Operation Notes</h5>
                    <div id="s3Body"></div>
                </section>
                <div class="row">
                <div class="col-lg-10">
                    <div class="row mtop2">
                        <div class="col-lg-2 col-md-3 col-sm-4">
                            <input type="button" class="btn-primry" id="btnSaveStep3" value="Save" />
                        </div>
                        <div class="col-lg-2 col-md-4 col-sm-4">
                            <input type="button" class="btn btn-yellow an-newform" value="New" />
                        </div>
                        <div class="col-lg-2 col-md-3 col-sm-4">
                            <input type="button" class="btn btn-gray an-list" value="View" />
                        </div>
                        <div class="col-lg-2 col-md-3 col-sm-4 an-print" style="display:none">
                            <input type="button" class="btn-primry an-printbtn" value="Print" />
                        </div>
                        <div class="col-lg-2 col-md-3 col-sm-4">
                            <input type="button" class="btn btn-gray" id="btnBack3" value="Back" />
                        </div>
                    </div>
                </div>
            </div>
            </div>
        </div>

        <div id="PatientsSearchModel" class="modal fade dl-modal" data-backdrop="static" tabindex="-1" role="dialog">
            <div class="modal-dialog modal-lg modal-dialog-centered" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">Select Admitted Patient</h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                    </div>
                    <div class="modal-body">
                        <div class="dl-search-bar">
                            <label for="txtPatientSearch">Search Patient</label>
                            <input type="text" id="txtPatientSearch" class="form-control" autocomplete="off" placeholder="Search admitted patients by name, MR No., CNIC or mobile" />
                        </div>
                        <div class="dl-table-scroll">
                            <table class="table" id="tblPatientsResult">
                                <thead><tr><th>MR No</th><th>Patient Name</th><th>Father Name</th><th>Contact No</th><th>Admitted On</th><th>Select</th></tr></thead>
                                <tbody id="iPatientsBody"></tbody>
                            </table>
                        </div>
                    </div>
                    <div class="modal-footer"><button type="button" class="dl-btn dl-btn-quiet" data-dismiss="modal">Close</button></div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
