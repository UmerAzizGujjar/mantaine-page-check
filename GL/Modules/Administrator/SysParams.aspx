<%@ Page EnableSessionState="ReadOnly" Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="SysParams.aspx.cs" Inherits="PMS.SysParams" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        /* System parameters: header, themed tabs, cards with field grids, tidy tables. Uses the theme colours like the other modernised forms. */
        .sp-page { display: flex; flex-direction: column; gap: 16px; width: 100%; margin: 0 0 24px; }
        .sp-head { display: flex; flex-wrap: wrap; align-items: center; justify-content: space-between; gap: 12px 20px; padding: 0 6px; }
        .sp-head h2 { margin: 0; font-size: 22px; font-weight: 800; color: var(--theme-ink, #1b2a41) !important; }
        .sp-head p { margin: 2px 0 0; font-size: 13px; color: #6b7686; }
        .sp-actions { margin-left: auto; display: flex; flex-wrap: wrap; align-items: center; gap: 8px; }
        .sp-actions label { margin: 0 6px 0 0; font-size: 13px; font-weight: 700; }
        .sp-page input.sp-btn {
            display: inline-flex !important; align-items: center; justify-content: center;
            width: auto !important; min-width: 0 !important; height: 34px !important; margin: 0 !important; padding: 0 18px !important;
            float: none !important; font-size: 13px; font-weight: 700; line-height: 1; white-space: nowrap; cursor: pointer;
            border-radius: 6px; border: 1px solid transparent; transition: filter .15s ease;
        }
        .sp-page input.sp-btn:hover { filter: brightness(.95); }
        .sp-btn-primary { color: var(--theme-on-accent, #fff); background: var(--theme-accent, #438eb9); }
        .sp-btn-quiet { color: #4a5568; background: #eef1f5; border-color: #dde3ea !important; }

        /* tabs */
        #tabs { background: #fff; border: 1px solid #e3e8ee; border-top: 3px solid var(--theme-accent, #438eb9); border-radius: 10px; padding: 0; box-shadow: 0 2px 10px rgba(16, 24, 40, .05); }
        #tabs > ul.ui-tabs-nav {
            display: flex; flex-wrap: wrap; gap: 4px; margin: 14px 16px 0; padding: 4px;
            list-style: none; background: #eef1f5; border: 1px solid #dde3ea; border-radius: 8px;
        }
        #tabs > ul.ui-tabs-nav::before, #tabs > ul.ui-tabs-nav::after { display: none; }
        #tabs > ul.ui-tabs-nav li { float: none; margin: 0; padding: 0; border: 0; background: transparent; list-style: none; }
        #tabs > ul li a,
        #tabs > ul li.ui-tabs-active a {
            display: block; padding: 7px 16px !important; font-size: 13px; font-weight: 700; text-decoration: none; cursor: pointer;
            border: 0 !important; border-radius: 6px; background: transparent !important; color: #2d3748 !important;
        }
        #tabs > ul li a:hover { background: rgba(0, 0, 0, .05) !important; }
        #tabs > ul li.ui-tabs-active a {
            background: var(--theme-accent, #438eb9) !important; color: var(--theme-on-accent, #fff) !important;
            box-shadow: 0 1px 3px rgba(16, 24, 40, .18);
        }
        #tabs > div.ui-tabs-panel { display: flex; flex-direction: column; gap: 14px; padding: 16px; background: transparent; border: 0; }
        #tabs > div.ui-tabs-panel[aria-hidden="true"] { display: none; }

        /* cards */
        .sp-card { padding: 14px 16px; background: #f8fafc; border: 1px solid #e3e8ee; border-radius: 8px; }
        .sp-card-head { display: flex; flex-wrap: wrap; align-items: center; justify-content: space-between; gap: 10px; margin-bottom: 10px; }
        .sp-card-title { margin: 0 0 10px; font-size: 14px; font-weight: 800; color: var(--theme-ink, #1b2a41); }
        .sp-card-head .sp-card-title { margin: 0; }
        .sp-card-title.sp-sub { margin-top: 16px; padding-top: 12px; border-top: 1px dashed #dde3ea; }
        .sp-hint { margin-top: 2px; font-size: 12.5px; color: #6b7686; }

        /* field grid */
        .sp-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(230px, 1fr)); gap: 12px 16px; }
        .sp-field { min-width: 0; }
        .sp-field.sp-wide { grid-column: 1 / -1; }
        .sp-field label { display: block; margin: 0 0 4px; font-size: 11.5px; font-weight: 700; letter-spacing: .02em; color: #4a5568; }
        .sp-page input[type="text"] {
            width: 100%; height: 34px; margin: 0; padding: 4px 10px; font-size: 13px; font-weight: 600;
            color: var(--theme-ink, #1b2a41); background: #fff; border: 1px solid #cfd6e0; border-radius: 6px; box-sizing: border-box; box-shadow: none;
        }
        .sp-page input[type="text"]:focus, .sp-page select:focus {
            border-color: var(--theme-accent, #438eb9); box-shadow: 0 0 0 3px var(--theme-accent-ring, rgba(67,142,185,.25)); outline: none;
        }
        .sp-page select {
            width: 100%; height: 34px; padding: 4px 10px; font-size: 13px; font-weight: 600; background: #fff;
            border: 1px solid #cfd6e0; border-radius: 6px; box-sizing: border-box;
        }

        /* tables */
        .sp-table-wrap { overflow: auto; border: 1px solid #e3e8ee; border-radius: 8px; background: #fff; }
        .sp-table-wrap.sp-tall { max-height: 540px; }
        #tabs table.table { width: 100%; margin: 0 !important; border-collapse: separate; border-spacing: 0; }
        #tabs table.table thead th {
            position: sticky; top: 0; z-index: 1; padding: 9px 12px; font-size: 11.5px; letter-spacing: .03em; text-transform: uppercase; white-space: nowrap; vertical-align: middle;
            color: var(--theme-on-accent, #fff); background: var(--theme-accent, #438eb9); border: 0; border-bottom: 2px solid var(--theme-accent-ink, #2b6a90);
        }
        #tabs table.table td { padding: 5px 12px; vertical-align: middle; border: 0; border-bottom: 1px solid #eef1f5; }
        #tabs table.table > tbody > tr:hover td { background: var(--theme-accent-soft, #f4f8fb); }
        #tabs table.table th:last-child, #tabs table.table td:last-child { text-align: center; white-space: nowrap; }
        #tabs table.table td a { font-size: 13px; font-weight: 700; text-decoration: none; cursor: pointer; }
        #tbl_AllParams .sp-col-name { width: 24%; }
        #tbl_AllParams .sp-col-code { width: 16%; }
        #tbl_AllParams .sp-col-sm { width: 9%; }
        #tbl_AllParams .sp-col-act { width: 120px; }
        #tbl_AllParams input[type="text"] { min-width: 110px; }
        #tbl_AllParams input[data-field="Name"] { min-width: 230px; }
        #tbl_AllParams input[data-field="Segment3"] { min-width: 160px; }
        #tbl_AllParams a.sp-del, #tbl_Liabilities a, #tbl_Incomes a { color: #c53030; }
        #tbl_AllParams tr.sp-dirty td { background: #fffbea; }

        /* all-parameters toolbar */
        .sp-toolbar { display: flex; flex-wrap: wrap; align-items: center; gap: 10px 14px; margin-bottom: 10px; }
        .sp-page input.sp-search { width: 300px; max-width: 100%; }
        .sp-count { font-size: 12.5px; color: #6b7686; }
        .sp-toolbar label { margin: 0; font-size: 13px; font-weight: 700; }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <script type="text/javascript">        

        localStorage.IsError_Found = false;

        function ValidatingControls() {

            localStorage.IsError_Found = false;

            Validate('#ctl00_MainContent_txtGLCashAccount');
            Validate('#ctl00_MainContent_txtLabAndRadiologyCharges_PrivateAccount');
            Validate('#ctl00_MainContent_txtLabAndRadiologyCharges_GeneralAccount');
            Validate('#ctl00_MainContent_txtRadialogyShare');
            Validate('#ctl00_MainContent_txtPhysioShare');
            Validate('#ctl00_MainContent_txtDentalShare');
            Validate('#ctl00_MainContent_txtDermaShare');

            var table = "#tbl_Liabilities";

            for (var i = 0; i <= localStorage.tbl_Liabilities_Length; i++) {

                var Acc = table + '_txtAccountCode_' + i;
                Validate(Acc);
            }

            table = "#tbl_Incomes";

            for (var i = 0; i <= localStorage.tbl_Incomes; i++) {

                var Acc = table + '_txtAccountCode_' + i;
                Validate(Acc);
            }
            return localStorage.IsError_Found;
        }

        function Validate(txtID) {

            var AccountCode = $(txtID).val();

            PageMethods.ValidateAccount(AccountCode, function (resp) {

                if (resp === true) {

                    if (localStorage.IsError_Found === false) {
                        $('#lblmsg').show();
                        $('#lblmsg').text('Accounts are Verified.');
                        $('#lblmsg').css('color', 'green');
                    }
                    $(txtID).css('background-color', 'rgb(168, 208, 168)');
                    $(txtID).css('color', 'white !important');
                }
                else if (resp === false) {

                    $(txtID).css('background-color', 'red');
                    $(txtID).focus();
                    $('#lblmsg').show();
                    $('#lblmsg').text('Accounts Not Verified.');
                    $('#lblmsg').css('color', 'red');
                    localStorage.IsError_Found = true;
                }
            }, function (err) { alert(err.get_message() + '  ' + txtID); });

        }

        function deletesys(AnchorTag) {

            var row = $(AnchorTag).parents('tr')[0];
            row.remove();
        }

        function New() {

            window.location = "SysParams.aspx";
        }

        function AddLiabilityRow() {

            var Libilities = '';
            var PatientTypes = '';
            var Departments = '';

            // Getting Liabilities...

            $.ajax({
                type: "POST",
                url: "SysParams.aspx/GetLiabilities",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {

                    $.each(msg.d, function (key, value) {
                        Libilities += '<option value="' + value.Item_ID + '">' + value.Description + '</option>';
                    });

                    // Getting Deparmtments...                    

                    $.ajax({
                        type: "POST",
                        url: "SysParams.aspx/GetDepartments",
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (data) {

                            $.each(data.d, function (key, value) {
                                Departments += '<option value="' + value.DataValueName + '">' + value.DataValueDescription + '</option>';
                            });

                            //Getting Patient Types...   


                            $.ajax({
                                type: "POST",
                                url: "SysParams.aspx/GetPatientTypes",
                                contentType: "application/json; charset=utf-8",
                                dataType: "json",
                                success: function (data) {

                                    PatientTypes = '';

                                    $.each(JSON.parse(data.d), function (key, value) {
                                        PatientTypes += '<option value="' + value.DataValue_Name + '">' + value.DataValue_Description + '</option>';
                                    });

                                    var table = "tbl_Liabilities";
                                    var tblLength = $('#' + table + ' tbody tr').length;

                                    tblLength = parseInt(tblLength);

                                    var row = '<tr><td><select id=' + table + '_ddlDept_' + tblLength + ' name="ddlDept"> ' + Departments + ' </select></td><td><select id=' + table + '_ddlLiability_' + tblLength + ' name="ddlLiability"> ' + Libilities + ' </select></td><td> <select id=' + table + '_ddlType_' + tblLength + ' name="ddlType"> ' + PatientTypes + ' </select> </td> <td> <input type="text" id=' + table + '_txtAccountCode_' + tblLength + ' name="txtAccountCode" /> </td><td><a href="javascript:void(0)" onclick="deletesys(this)"> Delete </a></td> </tr>';

                                    $('#tbl_Liabilities tbody').append(row);
                                    localStorage.tbl_Liabilities_Length = tblLength;
                                },
                                Error: function (x, e) {

                                }
                            });
                        },
                        Error: function (x, e) {

                        }
                    });
                },
                Error: function (x, e) {
                    alert(e);
                }
            });
        }

        function SaveLiabilities() {

            var AccountsList = [];

            var table = "#tbl_Liabilities";

            for (var i = 0; i <= localStorage.tbl_Liabilities_Length; i++) {

                var Dept = $(table + '_ddlDept_' + i).val();
                var Liability = $(table + '_ddlLiability_' + i).val();
                var Type = $(table + '_ddlType_' + i).val();
                var Code = $(table + '_txtAccountCode_' + i).val();
                if (Dept != null)
                    AccountsList.push({ Department: Dept, Name: Liability, Type: Type, Code: Code });
            }

            var data = { AccountsList: AccountsList }

            PageMethods.SaveLiabilities(JSON.stringify(data), function (response) {

            });
        }

        function LoadLiability_Accounts() {

            var Libilities = '';
            var PatientTypes = '';
            var Departments = '';

            // Getting Liabilities...

            $.ajax({
                type: "POST",
                url: "SysParams.aspx/GetLiabilities",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {

                    $.each(msg.d, function (key, value) {
                        Libilities += '<option value="' + value.Item_ID + '">' + value.Description + '</option>';
                    });

                    // Getting Deparmtments...                    

                    $.ajax({
                        type: "POST",
                        url: "SysParams.aspx/GetDepartments",
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (data) {

                            $.each(data.d, function (key, value) {
                                Departments += '<option value="' + value.DataValueName + '">' + value.DataValueDescription + '</option>';
                            });

                            //Getting Patient Types...   


                            $.ajax({
                                type: "POST",
                                url: "SysParams.aspx/GetPatientTypes",
                                contentType: "application/json; charset=utf-8",
                                dataType: "json",
                                success: function (data) {

                                    PatientTypes = '';

                                    $.each(JSON.parse(data.d), function (key, value) {
                                        PatientTypes += '<option value="' + value.DataValue_Name + '">' + value.DataValue_Description + '</option>';
                                    });


                                    $.ajax({
                                        type: "POST",
                                        url: "SysParams.aspx/GetAccounts",
                                        contentType: "application/json; charset=utf-8",
                                        dataType: "json",
                                        data: JSON.stringify({ Type: "Is Liability Account" }),
                                        success: function (response) {

                                            $('#tbl_Liabilities tbody tr').remove();

                                            $.each((response.d), function (key, value) {

                                                var table = "tbl_Liabilities";

                                                var tblLength = $('#' + table + ' tbody tr').length;

                                                var row = '<tr><td><select id=' + table + '_ddlDept_' + tblLength + ' name="ddlDept"> ' + Departments + ' </select></td><td><select id=' + table + '_ddlLiability_' + tblLength + ' name="ddlLiability"> ' + Libilities + ' </select></td><td> <select id=' + table + '_ddlType_' + tblLength + ' name="ddlType"> ' + PatientTypes + ' </select> </td> <td> <input type="text" id=' + table + '_txtAccountCode_' + tblLength + ' name="txtAccountCode" /> </td><td><a href="javascript:void(0)" onclick="deletesys(this)"> Delete </a></td> </tr>';

                                                $('#tbl_Liabilities tbody').append(row);

                                                $('#' + table + '_ddlDept_' + key).val(value.Segment1);
                                                $('#' + table + '_ddlLiability_' + key).val(value.Name);
                                                $('#' + table + '_ddlType_' + key).val(value.Segment2);
                                                $('#' + table + '_txtAccountCode_' + key).val(value.Code);

                                                localStorage.tbl_Liabilities_Length = tblLength;
                                            });
                                        },
                                        Error: function (x, e) {

                                        }
                                    });

                                },
                                Error: function (x, e) {

                                }
                            });
                        },
                        Error: function (x, e) {

                        }
                    });
                },
                Error: function (x, e) {
                    alert(e);
                }
            });
        }

        function AddIncomeRow() {

            var PatientTypes = '';
            var Departments = '';

            // Getting Deparmtments...                    

            $.ajax({
                type: "POST",
                url: "SysParams.aspx/GetDepartments",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {

                    $.each(data.d, function (key, value) {
                        Departments += '<option value="' + value.DataValueName + '">' + value.DataValueDescription + '</option>';
                    });

                    //Getting Patient Types...   

                    $.ajax({
                        type: "POST",
                        url: "SysParams.aspx/GetPatientTypes",
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (data) {

                            PatientTypes = '';

                            $.each(JSON.parse(data.d), function (key, value) {
                                PatientTypes += '<option value="' + value.DataValue_Name + '">' + value.DataValue_Description + '</option>';
                            });
                            var table = "tbl_Incomes";
                            var tblLength = $('#' + table + ' tbody tr').length;

                            var row = '<tr><td><select id=' + table + '_ddlDept_' + tblLength + ' name="ddlDept"> ' + Departments + ' </select></td><td> <select id=' + table + '_ddlType_' + tblLength + ' name="ddlType"> ' + PatientTypes + ' </select> </td> <td> <input type="text" id=' + table + '_txtAccountCode_' + tblLength + ' name="txtAccountCode" /> </td><td><a href="javascript:void(0)" onclick="deletesys(this)"> Delete </a></td> </tr>';

                            $('#tbl_Incomes tbody').append(row);
                            localStorage.tbl_Incomes = tblLength;
                        },
                        Error: function (x, e) {

                        }
                    });
                },
                Error: function (x, e) {

                }
            });
        }

        function SaveIncomes() {
            var AccountsList = [];

            var table = "#tbl_Incomes";

            for (var i = 0; i <= localStorage.tbl_Incomes; i++) {

                var Dept = $(table + '_ddlDept_' + i).val();
                var Type = $(table + '_ddlType_' + i).val();
                var Code = $(table + '_txtAccountCode_' + i).val();
                if (Dept != null)
                    AccountsList.push({ Department: Dept, Type: Type, Code: Code });
            }

            var data = { AccountsList: AccountsList }

            PageMethods.SaveIncomes(JSON.stringify(data), function (response) {

            });
        }

        function LoadIncome_Accounts() {

            var PatientTypes = '';
            var Departments = '';

            // Getting Deparmtments...                    

            $.ajax({
                type: "POST",
                url: "SysParams.aspx/GetDepartments",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {

                    $.each(data.d, function (key, value) {
                        Departments += '<option value="' + value.DataValueName + '">' + value.DataValueDescription + '</option>';
                    });

                    //Getting Patient Types...   


                    $.ajax({
                        type: "POST",
                        url: "SysParams.aspx/GetPatientTypes",
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (data) {

                            PatientTypes = '';

                            $.each(JSON.parse(data.d), function (key, value) {
                                PatientTypes += '<option value="' + value.DataValue_Name + '">' + value.DataValue_Description + '</option>';
                            });


                            $.ajax({
                                type: "POST",
                                url: "SysParams.aspx/GetAccounts",
                                contentType: "application/json; charset=utf-8",
                                dataType: "json",
                                data: JSON.stringify({ Type: "Is Income Account" }),
                                success: function (response) {

                                    $('#tbl_Incomes tbody tr').remove();

                                    $.each((response.d), function (key, value) {

                                        var table = "tbl_Incomes";

                                        var tblLength = $('#' + table + ' tbody tr').length;

                                        var row = '<tr><td><select id=' + table + '_ddlDept_' + tblLength + ' name="ddlDept"> ' + Departments + ' </select></td><td> <select id=' + table + '_ddlType_' + tblLength + ' name="ddlType"> ' + PatientTypes + ' </select> </td> <td> <input type="text" id=' + table + '_txtAccountCode_' + tblLength + ' name="txtAccountCode" /> </td><td><a href="javascript:void(0)" onclick="deletesys(this)"> Delete </a></td> </tr>';

                                        $('#tbl_Incomes tbody').append(row);
                                        $('#' + table + '_ddlDept_' + key).val(value.Segment1);
                                        $('#' + table + '_ddlType_' + key).val(value.Segment2);
                                        $('#' + table + '_txtAccountCode_' + key).val(value.Code);

                                        localStorage.tbl_Incomes = tblLength;

                                    });
                                },
                                Error: function (x, e) {

                                }
                            });

                        },
                        Error: function (x, e) {

                        }
                    });
                },
                Error: function (x, e) {

                }
            });
        }

        // ---- All Parameters tab ----
        function ParamMsg(text, ok) {
            $('#lblParamMsg').text(text).css('color', ok ? 'green' : 'red');
        }

        function BuildParamRow(p) {
            var $tr = $('<tr></tr>').data('id', p.ID || 0);
            $.each(['Name', 'Code', 'Segment1', 'Segment2', 'Segment3', 'Segment4'], function (i, f) {
                var $inp = $('<input type="text" />').attr('data-field', f).val(p[f] == null ? '' : p[f])
                    .on('input', function () { $tr.addClass('sp-dirty'); });
                $('<td></td>').append($inp).appendTo($tr);
            });
            var $save = $('<a href="javascript:void(0)">Save</a>').on('click', function () { SaveParamRow($tr); });
            var $del = $('<a href="javascript:void(0)" class="sp-del" style="margin-left: 12px;">Delete</a>').on('click', function () { DeleteParamRow($tr); });
            $('<td></td>').append($save).append($del).appendTo($tr);
            return $tr;
        }

        function LoadAllParams() {
            PageMethods.GetAllParameters(function (rows) {
                if (!$.isArray(rows)) { ParamMsg('Could not load parameters; reload the page.', false); return; }
                var $tb = $('#tbl_AllParams tbody').empty();
                $.each(rows, function (i, p) { $tb.append(BuildParamRow(p)); });
                FilterParamRows();
            }, function (err) { ParamMsg(err.get_message(), false); });
        }

        function AddParamRow() {
            var $tr = BuildParamRow({ ID: 0 });
            $('#tbl_AllParams tbody').prepend($tr);
            $tr.find('input[data-field="Name"]').focus();
        }

        function ParamField($tr, f) {
            return $tr.find('input[data-field="' + f + '"]').val();
        }

        function SaveParamRow($tr) {
            PageMethods.SaveParameterRow($tr.data('id'), ParamField($tr, 'Name'), ParamField($tr, 'Code'),
                ParamField($tr, 'Segment1'), ParamField($tr, 'Segment2'), ParamField($tr, 'Segment3'), ParamField($tr, 'Segment4'),
                function (res) {
                    if (!res || typeof res !== 'object') { ParamMsg('Save failed; reload the page and try again.', false); return; }
                    if (res.Error) { ParamMsg(res.Error, false); return; }
                    $tr.data('id', res.ID).removeClass('sp-dirty');
                    ParamMsg('Saved "' + ParamField($tr, 'Name') + '".', true);
                }, function (err) { ParamMsg(err.get_message(), false); });
        }

        function DeleteParamRow($tr) {
            var id = $tr.data('id');
            if (!id) { $tr.remove(); return; }
            if (!confirm('Delete parameter "' + ParamField($tr, 'Name') + '"? Code that reads it will get no value.')) return;
            PageMethods.DeleteParameterRow(id, function () {
                ParamMsg('Deleted "' + ParamField($tr, 'Name') + '".', true);
                $tr.remove();
            }, function (err) { ParamMsg(err.get_message(), false); });
        }

        function FilterParamRows() {
            var q = ($('#txtParamSearch').val() || '').toLowerCase();
            var shown = 0, total = 0;
            $('#tbl_AllParams tbody tr').each(function () {
                var hay = (ParamField($(this), 'Name') + ' ' + ParamField($(this), 'Code')).toLowerCase();
                var show = q === '' || hay.indexOf(q) >= 0 || !$(this).data('id');
                $(this).toggle(show);
                total++;
                if (show) shown++;
            });
            $('#lblParamCount').text(shown === total ? total + ' parameters' : shown + ' of ' + total + ' parameters');
        }

        function SaveRecord(Error) {
            if (Error)
                alert('Error');
            else
                alert('Success');

            return false;
        }
        function Save() {
            //ValidatingControls();
            //setTimeout(function () {
            //    SaveRecord(localStorage.IsError_Found)
            //    , 20000
            //});                                    
            SaveLiabilities();
            SaveIncomes();
        }

        $(document).ready(function () {
            LoadLiability_Accounts();
            LoadIncome_Accounts();
            LoadAllParams();
        });

        // set Index of the Current Selected Tab using the select event handler of jQuery UI Tabs

        var selected_tabs = 1;
        $(function () {
            var tabs = $("#tabs").tabs({
                select: function (e, i) {
                    selected_tabs = i.index;
                }
            });
        });

        function tokenInputs(textboxID, tblName, OnAddFun) {
            $('#' + textboxID).tokenInput("json.aspx",
                {
                    tokenLimit: 1,
                    onAdd:
                        function (item) {
                            try {
                                if (tblName == 'GL_Accounts') {

                                    $("#" + textboxID).val(item.id);
                                }
                            }
                            catch (err) {
                                alert(err.message);
                            }
                        }
                });
        }

    </script>

    <div class="sp-page">

        <asp:HiddenField ID="selected_tabs" runat="server" />

        <!-- Page header + actions -->
        <div class="sp-head">
            <div class="sp-actions">
                <label id="lblmsg"></label>
                <asp:Button ID="btnSave" class="sp-btn sp-btn-primary" runat="server" Text="Save" OnClick="btnSave_Click" OnClientClick="return Save()" />
                <input type="button" class="sp-btn sp-btn-quiet" value="New" id="Button1" onclick="New()" />
            </div>
        </div>

        <div id="tabs">
            <ul>
                <li><a href="#Tab-1">GL Accounts</a></li>
                <li><a href="#Tab-2">Income Accounts</a></li>
                <li><a href="#Tab-3">Liability Accounts</a></li>
                <li><a href="#Tab-4">Fees</a></li>
                <li><a href="#Tab-5" style="display: none;">Digital Invoicing</a></li>
                <li><a href="#Tab-6">All Parameters</a></li>
            </ul>

            <!-- GL accounts -->
            <div id="Tab-1">
                <div class="sp-card">
                    <div class="sp-card-title">Core GL accounts</div>
                    <div class="sp-grid">
                        <div class="sp-field"><label>GL Cash Account</label><asp:TextBox ID="txtGLCashAccount" runat="server"></asp:TextBox></div>
                        <div class="sp-field"><label>Receivable Account</label><asp:TextBox ID="txtReceivableAccount" runat="server"></asp:TextBox></div>
                        <div class="sp-field"><label>Miscellaneous Income Account</label><asp:TextBox ID="txtMiscellenousIncomeAccount" runat="server"></asp:TextBox></div>
                        <div class="sp-field"><label>Miscellaneous Loss Account</label><asp:TextBox ID="txtMiscellenousLossAccount" runat="server"></asp:TextBox></div>
                    </div>
                </div>
            </div>

            <!-- Income accounts -->
            <div id="Tab-2">
                <div class="sp-card">
                    <div class="sp-card-title">Default income accounts</div>
                    <div class="sp-grid">
                        <div class="sp-field"><label>Lab &amp; Radiology Charges &ndash; General Account</label><asp:TextBox ID="txtLabAndRadiologyCharges_GeneralAccount" runat="server"></asp:TextBox></div>
                        <div class="sp-field"><label>Lab &amp; Radiology Charges &ndash; Private Account</label><asp:TextBox ID="txtLabAndRadiologyCharges_PrivateAccount" runat="server"></asp:TextBox></div>
                        <div class="sp-field"><label>Patient Card Amount</label><asp:TextBox ID="txtPatientCardAmount" runat="server"></asp:TextBox></div>
                    </div>
                </div>
                <div class="sp-card" id="Accounts">
                    <div class="sp-card-head">
                        <div class="sp-card-title">Income accounts by department</div>
                        <input type="button" name="btnAdd" id="btnAdd" class="sp-btn sp-btn-primary" onclick="AddIncomeRow();" value="+ Add row" />
                    </div>
                    <input type="hidden" name="txtID" id="txtID" />
                    <div class="sp-table-wrap">
                        <table class="table" id="tbl_Incomes">
                            <thead>
                                <tr>
                                    <th>Department</th>
                                    <th>General / Private</th>
                                    <th>GL Code</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Liability accounts -->
            <div id="Tab-3">
                <div class="sp-card" id="Services">
                    <div class="sp-card-title">Department share accounts</div>
                    <div class="sp-grid">
                        <div class="sp-field"><label>Radiology Share</label><asp:TextBox ID="txtRadialogyShare" runat="server"></asp:TextBox></div>
                        <div class="sp-field"><label>Physio Share</label><asp:TextBox ID="txtPhysioShare" runat="server"></asp:TextBox></div>
                        <div class="sp-field"><label>Dental Share</label><asp:TextBox ID="txtDentalShare" runat="server"></asp:TextBox></div>
                        <div class="sp-field"><label>Derma Share</label><asp:TextBox ID="txtDermaShare" runat="server"></asp:TextBox></div>
                    </div>
                    <div class="sp-card-title sp-sub">Share percentages</div>
                    <div class="sp-grid">
                        <div class="sp-field"><label>Radiology Share %</label><asp:TextBox ID="txtRadialogySharePercentage" runat="server"></asp:TextBox></div>
                        <div class="sp-field"><label>Physio Share %</label><asp:TextBox ID="txtPhysioSharePercentage" runat="server"></asp:TextBox></div>
                        <div class="sp-field"><label>Dental Share %</label><asp:TextBox ID="txtDentalSharePercentage" runat="server"></asp:TextBox></div>
                        <div class="sp-field"><label>Derma Share %</label><asp:TextBox ID="txtDermaSharePercentage" runat="server"></asp:TextBox></div>
                    </div>
                </div>
                <div class="sp-card">
                    <div class="sp-card-head">
                        <div class="sp-card-title">Liability accounts by department</div>
                        <input type="button" name="btnAdd" id="btnAddLiabilityRow" class="sp-btn sp-btn-primary" onclick="AddLiabilityRow();" value="+ Add row" />
                    </div>
                    <input type="hidden" name="txtID" id="Hidden1" />
                    <div class="sp-table-wrap">
                        <table class="table" id="tbl_Liabilities">
                            <thead>
                                <tr>
                                    <th>Department</th>
                                    <th>Liability Name</th>
                                    <th>General / Private</th>
                                    <th>GL Code</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Fees -->
            <div id="Tab-4">
                <div class="sp-card">
                    <div class="sp-card-title">Registration fees</div>
                    <div class="sp-grid">
                        <div class="sp-field"><label>Out Patient Fee</label><asp:TextBox ID="txtopdfee" runat="server"></asp:TextBox></div>
                        <div class="sp-field"><label>In Patient Fee</label><asp:TextBox ID="txt_inpatient_fee" runat="server"></asp:TextBox></div>
                        <div class="sp-field"><label>Emergency Patient Fee</label><asp:TextBox ID="txt_emergecny_fee" runat="server"></asp:TextBox></div>
                    </div>
                </div>
            </div>

            <!-- Digital invoicing (tab link hidden) -->
            <div id="Tab-5">
                <div class="sp-card">
                    <div class="sp-card-title">FBR Digital Invoicing (DI) credentials</div>
                    <div class="sp-grid">
                        <div class="sp-field sp-wide"><label>Post URL (Sandbox / Production)</label><asp:TextBox ID="txtDI_PostUrl" runat="server"></asp:TextBox></div>
                        <div class="sp-field sp-wide"><label>Validate URL</label><asp:TextBox ID="txtDI_ValidateUrl" runat="server"></asp:TextBox></div>
                        <div class="sp-field sp-wide"><label>Security Token</label><asp:TextBox ID="txtDI_Token" runat="server"></asp:TextBox></div>
                        <div class="sp-field"><label>Seller NTN / CNIC</label><asp:TextBox ID="txtDI_SellerNTN" runat="server"></asp:TextBox></div>
                        <div class="sp-field"><label>Seller Business Name</label><asp:TextBox ID="txtDI_SellerName" runat="server"></asp:TextBox></div>
                        <div class="sp-field"><label>Seller Province</label><asp:TextBox ID="txtDI_SellerProvince" runat="server"></asp:TextBox></div>
                        <div class="sp-field"><label>Seller Address</label><asp:TextBox ID="txtDI_SellerAddress" runat="server"></asp:TextBox></div>
                        <div class="sp-field"><label>Buyer Registration Type</label><asp:TextBox ID="txtDI_RegistrationType" runat="server"></asp:TextBox></div>
                        <div class="sp-field"><label>Scenario Id (Sandbox)</label><asp:TextBox ID="txtDI_ScenarioId" runat="server"></asp:TextBox></div>
                        <div class="sp-field"><label>Invoice Type</label><asp:TextBox ID="txtDI_InvoiceType" runat="server"></asp:TextBox></div>
                        <div class="sp-field"><label>Rate</label><asp:TextBox ID="txtDI_Rate" runat="server"></asp:TextBox></div>
                        <div class="sp-field"><label>Sale Type</label><asp:TextBox ID="txtDI_SaleType" runat="server"></asp:TextBox></div>
                    </div>
                </div>
            </div>

            <!-- Every sys_Parms row -->
            <div id="Tab-6">
                <div class="sp-card">
                    <div class="sp-card-head">
                        <div>
                            <div class="sp-card-title">All parameters</div>
                            <div class="sp-hint">Every system parameter can be changed here. Each row saves on its own and applies immediately.</div>
                        </div>
                        <input type="button" class="sp-btn sp-btn-primary" value="+ Add parameter" onclick="AddParamRow()" />
                    </div>
                    <div class="sp-toolbar">
                        <input type="text" id="txtParamSearch" class="sp-search" placeholder="Search by name or code..." onkeyup="FilterParamRows()" />
                        <span id="lblParamCount" class="sp-count"></span>
                        <label id="lblParamMsg"></label>
                    </div>
                    <div class="sp-table-wrap sp-tall">
                        <table class="table" id="tbl_AllParams">
                            <thead>
                                <tr>
                                    <th class="sp-col-name">Name</th>
                                    <th class="sp-col-code">Code</th>
                                    <th>Segment 1</th>
                                    <th class="sp-col-sm">Segment 2</th>
                                    <th>Segment 3</th>
                                    <th class="sp-col-sm">Segment 4</th>
                                    <th class="sp-col-act">Action</th>
                                </tr>
                            </thead>
                            <tbody></tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

    </div>
</asp:Content>
