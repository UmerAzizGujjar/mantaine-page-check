<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="CTScanHistory.aspx.cs" Inherits="PMS.Modules.Lab.CTScanHistory" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/lib/sweetalert/swalalert.css" rel="stylesheet" />
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/vendor.css" rel="stylesheet" />
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/Datavalue.css" rel="stylesheet" />
    <link href="../../wwwroot/lib/theme/pharmacy-form.css?v=6" rel="stylesheet" />
    <script type="text/javascript">
        // ===== state =====
        var ctId = 0;          // Lab_CT_History.CT_ID, given by the server on first save
        var patientId = 0;
        var YN = [['1', 'Yes'], ['0', 'No']];

        // ===== field layout (rendered into #formBody) =====
        // t: text | area | date | num | staff (Emp_ID) | doctor (doctor name) | pills (o: values or [value, label]) | chk (checkbox) | rel (checkbox + age)
        var LAYOUT = [
            { g: 'General', i: 'fa-user', f: [
                { c: 'Referring_Doctor', l: 'Referring Dr.', t: 'doctor', w: 2 },
                { c: 'Is_Pregnant', l: 'Any chance, you are pregnant?', t: 'pills', o: YN },
                { c: 'LMP', l: 'LMP', t: 'date' }] },
            { g: 'Clinical History', i: 'fa-stethoscope', f: [
                { c: 'Chief_Complaint', l: 'Chief Complaint', t: 'area', rows: 3, w: 2 },
                { c: 'Prior_Radiological_Study', l: 'Prior Radiological Study', t: 'area', rows: 3, w: 2 },
                { c: 'Surgical_History', l: 'Surgical History', t: 'area', rows: 3, w: 2 },
                { c: 'Medications', l: 'Medications you are taking', t: 'area', rows: 3, w: 2 }] },
            { g: 'Cancer History', i: 'fa-heartbeat', f: [
                { c: 'Had_Cancer', l: 'Do you have or have you ever had cancer?', t: 'pills', o: YN, w: 2 },
                { c: 'Tx_Chemotherapy', l: 'Chemotherapy', t: 'chk' },
                { c: 'Tx_Operation', l: 'Operation', t: 'chk' },
                { c: 'Tx_Radiation', l: 'Radiation Therapy', t: 'chk' },
                { c: 'Treatment_Finished', l: 'Are you finished with treatment?', t: 'pills', o: YN }] },
            { g: 'Electronic Medical Device', i: 'fa-microchip', f: [
                { c: 'Has_Electronic_Device', l: 'Do you have any electronic medical device?', t: 'pills', o: YN, w: 2 },
                { c: 'Electronic_Devices', l: 'If yes, enlist them', t: 'text', w: 2, ph: 'Pacemaker, Defibrillator, Neuro-stimulator, Retinal implant, Drug infusion pump, Insulin pump, Cochlear implant, etc.' }] },
            { g: 'Asthma, Allergies & Smoking', i: 'fa-medkit', f: [
                { c: 'Has_Asthma', l: 'Do you have asthma?', t: 'pills', o: YN },
                { c: 'Has_Allergies', l: 'Do you have allergies?', t: 'pills', o: YN },
                { c: 'Is_Smoker', l: 'Smoke?', t: 'pills', o: YN },
                { c: 'Smoke_Details', l: 'If yes, details', t: 'text', w: 2 }] },
            { g: 'Patient Sign-off', i: 'fa-pencil', f: [
                { c: 'Patient_Sign_Name', l: 'Name (patient / attendant)', t: 'text', w: 2 },
                { c: 'Exam_Date', l: 'Date', t: 'date', r: 1 }] },
            { g: 'Radiologist (Consultant use only)', i: 'fa-user-md', f: [
                { c: 'Radiologist_Notes', l: 'Additional Notes', t: 'area', rows: 3, span: 1 },
                { c: 'Radiologist_ID', l: 'Radiologist', t: 'staff' },
                { c: 'Radiologist_Date', l: 'Date / Time', t: 'datetime' },
                { c: 'Report_Correlation', l: 'Report correlates to clinical diagnosis', t: 'pills', o: [['Concordant', 'Yes / Concordant'], ['Discordant', 'No / Discordant']], w: 2 }] }
        ];

        // ===== helpers =====
        function esc(s) { return $('<div>').text(s == null ? '' : s).html(); }
        function warn(text) { Swal.fire({ icon: 'warning', title: 'Warning!', text: text, timer: 2200, showConfirmButton: false }); }
        function todayStr() { var d = new Date(); return d.getFullYear() + '-' + ('0' + (d.getMonth() + 1)).slice(-2) + '-' + ('0' + d.getDate()).slice(-2); }
        function call(method, args, cb) {
            $.ajax({
                type: 'POST', url: 'CTScanHistory.aspx/' + method, data: JSON.stringify(args || {}),
                contentType: 'application/json; charset=utf-8', dataType: 'json',
                success: function (r) { var o = JSON.parse(r.d); cb(o); },
                error: function (xhr) { cb({ ok: false, msg: 'Server error (' + xhr.status + ')' }); }
            });
        }

        // ===== rendering =====
        function fieldHtml(f) {
            var id = 'f_' + f.c, cls = 'ph-field dialysis-field' + (f.span ? ' dl-span-all' : '') + (f.w == 2 ? ' dl-span-2' : '');
            var req = f.r ? '<span class="required">*</span>' : '';
            var base = 'id="' + id + '" data-col="' + f.c + '"' + (f.r ? ' data-req="1"' : '');
            if (f.t === 'chk') {
                return '<div class="' + cls + '"><label class="mg-check"><input type="checkbox" ' + base + ' /> ' + f.l + '</label></div>';
            }
            if (f.t === 'rel') {
                return '<div class="' + cls + '"><div class="mg-rel"><label class="mg-check"><input type="checkbox" ' + base + ' /> ' + f.l + '</label>' +
                    '<input type="text" class="form-control mg-age" id="f_' + f.c + '_Age" data-col="' + f.c + '_Age" placeholder="At what age?" maxlength="20" /></div></div>';
            }
            var lab = '<label for="' + id + '">' + f.l + req + '</label>', ctl = '';
            switch (f.t) {
                case 'text': ctl = '<input type="text" class="form-control" ' + base + (f.ph ? ' placeholder="' + f.ph + '"' : '') + ' maxlength="300" />'; break;
                case 'datetime': ctl = '<input type="datetime-local" class="form-control" ' + base + ' />'; break;
                case 'num': ctl = '<input type="number" min="0" step="1" class="form-control" ' + base + ' />'; break;
                case 'date': ctl = '<input type="date" class="form-control" ' + base + ' />'; break;
                case 'area': ctl = '<textarea class="form-control" rows="' + (f.rows || 2) + '" ' + base + (f.ph ? ' placeholder="' + f.ph + '"' : '') + '></textarea>'; break;
                case 'staff': ctl = '<select class="form-control mg-staff" ' + base + '><option value="">Select</option></select>'; break;
                case 'doctor': ctl = '<select class="form-control mg-doctor" ' + base + '><option value="">Select</option></select>'; break;
                case 'pills':
                    ctl = '<div class="an-pills" data-for="' + id + '">' + f.o.map(function (o) {
                        var v = $.isArray(o) ? o[0] : o, l = $.isArray(o) ? o[1] : o;
                        return '<button type="button" class="an-pill" data-val="' + v + '">' + l + '</button>';
                    }).join('') + '</div><input type="hidden" ' + base + ' />'; break;
            }
            return '<div class="' + cls + '">' + lab + ctl + '</div>';
        }

        function renderForm() {
            var html = '';
            $.each(LAYOUT, function (gi, g) {
                html += '<h6 class="dl-group"><i class="fa ' + g.i + '"></i> ' + g.g + '</h6>';
                html += '<div class="ph-grid dl-grid">' + g.f.map(fieldHtml).join('') + '</div>';
            });
            $('#formBody').html(html);
        }

        // ===== reading / writing field values =====
        function collect() {
            var o = {};
            $('#formWrap [data-col]').each(function () {
                var $e = $(this);
                o[$e.data('col')] = $e.is(':checkbox') ? ($e.prop('checked') ? '1' : '0') : $e.val();
            });
            return o;
        }
        function fillValues(obj) {
            if (!obj) return;
            $('#formWrap [data-col]').each(function () {
                var $e = $(this), k = $e.data('col');
                if (!(k in obj) || obj[k] == null) return;
                var v = String(obj[k]);
                if ($e.is(':checkbox')) { $e.prop('checked', v === 'true' || v === '1'); return; }
                if ($e.is('input[type=hidden]')) v = v === 'true' ? '1' : (v === 'false' ? '0' : v);   // Yes/No pills keep 1/0
                // a saved doctor who has since left is no longer in the list; keep showing the name
                if ($e.is('select.mg-doctor') && v && !$e.find('option').filter(function () { return this.value === v; }).length) $e.append($('<option>').val(v).text(v));
                $e.val(v);
                if ($e.is('select')) $e.trigger('change');
                if ($e.is('input[type=hidden]')) syncPills($e);
            });
        }
        function syncPills($hidden) {
            $('.an-pills[data-for="' + $hidden.attr('id') + '"] .an-pill').each(function () { $(this).toggleClass('on', String($(this).data('val')) === $hidden.val()); });
        }
        function checkRequired() {
            var bad = [];
            $('#formWrap [data-req="1"]').each(function () {
                var $e = $(this), empty = !$e.val(), $vis = $e.is('select') ? $e.next('.select2-container').find('.select2-selection') : $e;
                $vis.toggleClass('is-invalid', empty);
                if (empty) bad.push($e.closest('.ph-field').find('label').first().text().replace('*', '').trim());
            });
            return bad;
        }
        function resetForm() {
            $('#formWrap [data-col]').each(function () {
                var $e = $(this);
                if ($e.is(':checkbox')) { $e.prop('checked', false); return; }
                $e.val(''); if ($e.is('select')) $e.trigger('change'); if ($e.is('input[type=hidden]')) syncPills($e);
            });
            setRecordId(0);
            $('#f_Exam_Date').val(todayStr());
        }
        function setRecordId(id) { ctId = id || 0; $('#infoRecordId').text(ctId ? ctId : 'assigned on first save'); $('.mg-print').toggle(!!ctId); }

        // ===== save =====
        function saveRecord() {
            if (!patientId) { warn('Please select a patient first'); return; }
            var bad = checkRequired();
            if (bad.length) { warn('Please fill: ' + bad.join(', ')); return; }
            var data = collect(); data.CtId = ctId; data.PatientId = patientId;
            $('#btnSave').prop('disabled', true);
            call('SaveRecord', { data: JSON.stringify(data) }, function (r) {
                $('#btnSave').prop('disabled', false);
                if (!r.ok) { Swal.fire({ icon: 'error', title: 'Error!', text: r.msg, showConfirmButton: true }); return; }
                setRecordId(r.data.CtId);
                $('#dlMode').html('<i class="fa fa-pencil"></i> Editing record');
                Swal.fire({ icon: 'success', title: 'Success!', text: 'CT history ' + (r.msg === 'updated' ? 'updated' : 'saved') + ' successfully', timer: 1800, showConfirmButton: false });
            });
        }

        // ===== patient =====
        function showPatient(p) {
            patientId = p.PatientId;
            $('#infoPatientName').text(p.Name); $('#infoMrNo').text(p.MRNo); $('#infoAge').text(p.Age);
            $('#infoGender').text(p.Gender); $('#infoContact').text(p.Contact);
            if (!$('#f_Contact_Phone').val()) $('#f_Contact_Phone').val(p.Contact);
            $('#patientBar').show(); $('#emptyState').hide(); $('#formWrap').show();
        }
        function pickPatient(p) {
            if (patientId && ctId && !confirm('Start a new CT history for this patient? The current one stays saved.')) return;
            resetForm(); $('#dlMode').html('<i class="fa fa-plus-circle"></i> New record');
            showPatient(p); $('#PatientsSearchModel').modal('hide');
        }
        function searchPatients(text) {
            call('SearchPatients', { searchText: text }, function (r) {
                var $b = $('#iPatientsBody').empty();
                if (!r.ok || !r.data.length) { $b.append('<tr><td colspan="6" class="text-center">No patients found</td></tr>'); return; }
                $.each(r.data, function (i, p) {
                    var $tr = $('<tr>').append($('<td>').text(p.MRNo), $('<td>').text(p.Name), $('<td>').text(p.Father), $('<td>').text(p.NIC), $('<td>').text(p.Contact));
                    var $btn = $('<button type="button" class="btn btn-sm btn-primary"><i class="fa fa-plus"></i></button>').on('click', function () {
                        call('GetPatient', { patientId: p.PatientId }, function (g) { if (g.ok) pickPatient(g.data); });
                    });
                    $b.append($tr.append($('<td>').append($btn)));
                });
            });
        }

        // ===== edit mode =====
        function loadRecord(id) {
            call('GetRecord', { ctId: parseInt(id, 10) }, function (r) {
                if (!r.ok) { Swal.fire({ icon: 'error', title: 'Error!', text: r.msg }); return; }
                $('#dlMode').html('<i class="fa fa-pencil"></i> Editing record');
                showPatient(r.data.Patient);
                fillValues(r.data.Record);
                setRecordId(r.data.CtId);
            });
        }

        // ===== init =====
        $(document).ready(function () {
            renderForm();
            $('#f_Exam_Date').val(todayStr());

            $(document).on('click', '.an-pill', function () {
                var $p = $(this), $h = $('#' + $p.closest('.an-pills').data('for')), v = String($p.data('val'));
                $h.val($h.val() === v ? '' : v); syncPills($h);
            });
            // typing an age ticks the relative
            $(document).on('input', '.mg-age', function () { if ($(this).val()) $(this).closest('.mg-rel').find(':checkbox').prop('checked', true); });
            $(document).on('input change', '#formWrap .is-invalid', function () { $(this).removeClass('is-invalid'); });

            $('#btnSave').on('click', saveRecord);
            $('#btnSelectPatient').on('click', function () { $('#txtPatientSearch').val(''); $('#PatientsSearchModel').modal({ backdrop: 'static' }); searchPatients(''); setTimeout(function () { $('#txtPatientSearch').focus(); }, 400); });
            var t; $('#txtPatientSearch').on('input', function () { var v = $(this).val(); clearTimeout(t); t = setTimeout(function () { searchPatients(v); }, 300); });
            $('.mg-newform').on('click', function () { window.location.href = 'CTScanHistory.aspx'; });
            $('.mg-list').on('click', function () { window.location.href = 'CTScanHistoryView.aspx'; });
            $('.mg-printbtn').on('click', function () { if (ctId) window.open('CTScanHistoryPrint.aspx?ID=' + ctId, '_blank'); });

            call('GetLookups', {}, function (r) {
                if (r.ok) {
                    $('select.mg-doctor').append(r.data.doctors.map(function (n) { return '<option value="' + esc(n) + '">' + esc(n) + '</option>'; }).join(''));
                    $('select.mg-staff').append(r.data.staff.map(function (x) { return '<option value="' + x.id + '">' + esc(x.name) + '</option>'; }).join(''));
                }
                $('#formWrap select').select2({ width: '100%' });
                var id = new URLSearchParams(window.location.search).get('ID');
                if (id) loadRecord(id);
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
        .dl-btn-primary { color: var(--theme-on-accent, #fff); background: var(--theme-accent, #438eb9); }
        .dl-btn-quiet { color: #4a5568; background: #eef1f5; border-color: #dde3ea !important; }

        .dl-page .dl-patientbar { display: flex; align-items: center; padding: 16px; }
        .dl-patient { display: flex; align-items: center; gap: 14px; min-width: 0; }
        .dl-avatar { flex: 0 0 auto; display: flex; align-items: center; justify-content: center; width: 64px; height: 64px; overflow: hidden; border-radius: 50%; background: var(--theme-accent-soft, #e8f1f8); }
        .dl-avatar img { width: 42px; height: auto; }
        .dl-patient-name { font-size: 17px; font-weight: 800; color: var(--theme-ink, #1b2a41); overflow-wrap: anywhere; }
        .dl-chips { display: flex; flex-wrap: wrap; gap: 6px 8px; margin-top: 6px; }
        .dl-chip { display: inline-flex; align-items: center; gap: 6px; padding: 3px 11px; font-size: 12px; font-weight: 600; color: #2d3748; background: #eef1f5; border-radius: 999px; }
        .dl-chip b { font-weight: 700; color: #6b7686; }

        .dl-group { display: flex; align-items: center; gap: 8px; margin: 22px 0 12px; padding-bottom: 6px; font-size: 12px; font-weight: 800; letter-spacing: .06em; text-transform: uppercase; color: var(--theme-accent-ink, #2b6a90); border-bottom: 1px solid #e3e8ee; }
        .dl-group:first-of-type { margin-top: 4px; }
        .dl-group i { font-size: 13px; opacity: .85; }
        .dl-grid { grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); align-items: end; }
        .dl-span-all { grid-column: 1 / -1; }
        .dl-span-2 { grid-column: span 2; }
        @media (max-width: 520px) { .dl-span-2 { grid-column: 1 / -1; } }
        .dl-page .required { margin-left: 2px; color: #c0392b; }
        .dl-page .ph-card textarea.form-control { display: block; width: 100%; min-height: 64px; padding: 8px 10px; font-size: 13px; font-weight: 600; resize: vertical; color: var(--theme-ink, #1b2a41); background: #fff; border: 1px solid #cfd6e0; border-radius: 6px; box-shadow: none; box-sizing: border-box; }
        .dl-page .ph-card input[type="date"].form-control, .dl-page .ph-card input[type="number"].form-control { padding-right: 8px !important; }
        .dl-page .is-invalid { border-color: #c0392b !important; box-shadow: 0 0 0 3px rgba(192, 57, 43, .15) !important; }
        .dl-page .select2-container { width: 100% !important; }
        .an-empty { padding: 48px 16px; text-align: center; color: #6b7686; }
        .an-empty i { display: block; margin-bottom: 10px; font-size: 40px; color: var(--theme-accent, #438eb9); opacity: .7; }
        .an-empty h4 { margin: 0 0 4px; font-weight: 800; color: var(--theme-ink, #1b2a41); }

        /* Yes/No and option pills */
        .an-pills { display: flex; flex-wrap: wrap; gap: 6px; padding: 2px 0; }
        /* the theme makes buttons in form fields full-width blocks; keep pills side by side */
        .dl-page .an-pills .an-pill { display: inline-flex; align-items: center; justify-content: center; flex: 0 0 auto; width: auto; margin: 0; }
        .an-pill { min-width: 52px; height: 34px; padding: 0 14px; font-size: 13px; font-weight: 700; color: #4a5568; background: #eef1f5; border: 1px solid #dde3ea; border-radius: 999px; cursor: pointer; transition: background .15s, color .15s; }
        .an-pill:hover { background: #e2e8f0; }
        .an-pill.on { color: var(--theme-on-accent, #fff); background: var(--theme-accent, #438eb9); border-color: var(--theme-accent, #438eb9); }

        /* checkboxes and relative + age cards */
        .dl-page .mg-check { display: flex; align-items: center; gap: 8px; margin: 0; padding: 8px 10px; font-size: 13px; font-weight: 700; color: #2d3748; background: #fafbfc; border: 1px solid #e3e8ee; border-radius: 8px; cursor: pointer; }
        .dl-page .mg-check input { width: 16px; height: 16px; margin: 0; cursor: pointer; }
        .mg-rel { display: flex; flex-direction: column; gap: 6px; }
        .mg-rel .mg-check { border: 0; padding: 0; background: none; }
        .mg-rel { padding: 8px; border: 1px solid #e3e8ee; border-radius: 8px; background: #fafbfc; }

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
        html[data-theme="dark"] .dl-head p { color: var(--dk-muted, #9aa6b8); }
        html[data-theme="dark"] .dl-chip, html[data-theme="dark"] .dl-btn-quiet, html[data-theme="dark"] .an-pill { background: var(--dk-surface-3, #232d3d); color: var(--dk-text, #e6e9ef); border-color: var(--dk-border, #2d3748) !important; }
        html[data-theme="dark"] .an-pill.on { background: var(--theme-accent, #438eb9); color: #fff; }
        html[data-theme="dark"] .dl-page .mg-check, html[data-theme="dark"] .mg-rel { background: var(--dk-surface-3, #232d3d); color: var(--dk-text, #e6e9ef); border-color: var(--dk-border, #2d3748); }
        html[data-theme="dark"] .dl-group, html[data-theme="dark"] #tblPatientsResult td { border-color: var(--dk-border, #2d3748); }
        html[data-theme="dark"] .dl-page .ph-card textarea.form-control { background: var(--dk-surface-3, #232d3d); color: var(--dk-text, #e6e9ef); border-color: var(--dk-border, #2d3748); }
        html[data-theme="dark"] .dl-page .modal-content { background: var(--dk-surface-2, #1c2431); color: var(--dk-text, #e6e9ef); }
        html[data-theme="dark"] .dl-page .modal-footer { background: var(--dk-surface-3, #232d3d); border-color: var(--dk-border, #2d3748); }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="dl-page">
        <div class="dl-head">
            <div>
                <h2><i class="fa fa-desktop"></i>CT Patient History <span class="dl-badge" id="dlMode"><i class="fa fa-plus-circle"></i> New record</span></h2>
                <p>Patient history taken before the CT scan; the last section is for the radiologist.</p>
            </div>
            <div class="dl-actions">
                <button type="button" class="dl-btn dl-btn-primary" id="btnSelectPatient"><i class="fa fa-search"></i> Select Patient</button>
                <button type="button" class="dl-btn dl-btn-quiet mg-list"><i class="fa fa-eye"></i> View</button>
            </div>
        </div>

        <section class="ph-card dl-patientbar" id="patientBar" style="display: none;">
            <div class="dl-patient">
                <div class="dl-avatar"><img src="../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/Patient.png" alt="Patient" /></div>
                <div>
                    <div class="dl-patient-name" id="infoPatientName">-</div>
                    <div class="dl-chips">
                        <span class="dl-chip"><b>Medical Record #</b> <span id="infoMrNo">-</span></span>
                        <span class="dl-chip"><b>Age</b> <span id="infoAge">-</span></span>
                        <span class="dl-chip"><b>Gender</b> <span id="infoGender">-</span></span>
                        <span class="dl-chip"><b>Contact</b> <span id="infoContact">-</span></span>
                        <span class="dl-chip"><b>Record</b> <span id="infoRecordId">assigned on first save</span></span>
                    </div>
                </div>
            </div>
        </section>

        <section class="ph-card an-empty" id="emptyState">
            <i class="fa fa-desktop"></i>
            <h4>Select a patient to begin</h4>
            <p>Click <b>Select Patient</b>, then fill the history form.</p>
        </section>

        <div id="formWrap" style="display: none;">
            <section class="ph-card">
                <h5 class="ph-card-title"><i class="fa fa-file-text-o"></i> CT Patient History Form</h5>
                <div id="formBody"></div>
            </section>
            <div class="row">
                <div class="col-lg-10">
                    <div class="row mtop2">
                        <div class="col-lg-2 col-md-3 col-sm-4">
                            <input type="button" class="btn-primry" id="btnSave" value="Save" />
                        </div>
                        <div class="col-lg-2 col-md-4 col-sm-4">
                            <input type="button" class="btn btn-yellow mg-newform" value="New" />
                        </div>
                        <div class="col-lg-2 col-md-3 col-sm-4">
                            <input type="button" class="btn btn-gray mg-list" value="View" />
                        </div>
                        <div class="col-lg-2 col-md-3 col-sm-4 mg-print" style="display:none">
                            <input type="button" class="btn-primry mg-printbtn" value="Print" />
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div id="PatientsSearchModel" class="modal fade dl-modal" data-backdrop="static" tabindex="-1" role="dialog">
            <div class="modal-dialog modal-lg modal-dialog-centered" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">Select Patient</h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                    </div>
                    <div class="modal-body">
                        <div class="dl-search-bar">
                            <label for="txtPatientSearch">Search Patient</label>
                            <input type="text" id="txtPatientSearch" class="form-control" autocomplete="off" placeholder="Search by name, MR No., CNIC or mobile" />
                        </div>
                        <div class="dl-table-scroll">
                            <table class="table" id="tblPatientsResult">
                                <thead><tr><th>MR No</th><th>Patient Name</th><th>Father Name</th><th>CNIC</th><th>Contact No</th><th>Select</th></tr></thead>
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
