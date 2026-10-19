<%@ Page EnableSessionState="ReadOnly" Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="panelagreement.aspx.cs" Inherits="PMS.panelagreement" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

    <link href="../../wwwroot/lib/sweetalert/swalalert.css" rel="stylesheet" />
    <link href="../../wwwroot/lib/theme/pharmacy-form.css?v=6" rel="stylesheet" />
    <style type="text/css">
        /* Panel agreement - built on the shared .ph-card / .ph-grid styles of the pharmacy form */
        .pa-page { display: flex; flex-direction: column; gap: 16px; width: 100%; margin: 0 0 24px; padding: 0; }

        .pa-head { display: flex; flex-wrap: wrap; align-items: center; justify-content: space-between; gap: 12px 20px; padding: 0 6px; }
        .pa-head h2 { margin: 0; font-size: 22px; font-weight: 800; color: var(--theme-ink, #1b2a41) !important; }
        .pa-head p { margin: 2px 0 0; font-size: 13px; color: #6b7686; }
        .pa-badge {
            display: inline-flex; align-items: center; gap: 6px; margin-left: 10px; padding: 3px 10px;
            font-size: 12px; font-weight: 700; vertical-align: middle; border-radius: 999px;
            color: var(--theme-accent-ink, #2b6a90); background: var(--theme-accent-soft, #e8f1f8);
        }
        .pa-actions { display: flex; flex-wrap: wrap; gap: 8px; }

        .pa-btn {
            display: inline-flex; align-items: center; justify-content: center; gap: 6px;
            height: 34px; padding: 0 14px; font-size: 13px; font-weight: 700; line-height: 1;
            white-space: nowrap; cursor: pointer; border-radius: 6px; border: 1px solid transparent;
            transition: filter .15s ease, box-shadow .15s ease;
        }
        /* the global input[type=button] styles are wide/stacked; keep these as compact buttons */
        .pa-page input.pa-btn { display: inline-flex !important; width: auto !important; min-width: 0 !important; margin: 0 !important; height: 34px !important; padding: 0 16px !important; float: none !important; }
        .pa-btn:hover { filter: brightness(.95); }
        .pa-btn:disabled { opacity: .6; cursor: not-allowed; }
        .pa-btn-primary { color: var(--theme-on-accent, #fff); background: var(--theme-accent, #438eb9); }
        .pa-btn-outline { color: var(--theme-accent-ink, #2b6a90); background: #fff; border-color: var(--theme-accent, #438eb9); }
        .pa-btn-quiet { color: #4a5568; background: #eef1f5; border-color: #dde3ea; }

        .pa-top { display: grid; grid-template-columns: minmax(0, 2fr) minmax(0, 1fr); gap: 16px; align-items: stretch; }
        @media (max-width: 1099px) { .pa-top { grid-template-columns: minmax(0, 1fr); } }
        .pa-grid-3 { grid-template-columns: repeat(3, minmax(0, 1fr)); }
        @media (max-width: 699px) { .pa-grid-3 { grid-template-columns: minmax(0, 1fr); } }
        .pa-req { color: #c0392b; }

        .pa-tools { display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 14px; }
        @media (max-width: 1099px) { .pa-tools { grid-template-columns: minmax(0, 1fr); } }
        .pa-tool { display: flex; flex-direction: column; gap: 10px; padding: 12px; background: #f8fafc; border: 1px solid #e3e8ee; border-radius: 8px; min-width: 0; }
        .pa-tool h6 { display: flex; align-items: center; gap: 6px; margin: 0; font-size: 12px; font-weight: 800; letter-spacing: .05em; text-transform: uppercase; color: var(--theme-accent-ink, #2b6a90); }
        .pa-row { display: grid; grid-template-columns: minmax(0, 1fr) auto; gap: 8px; align-items: end; }
        .pa-row-2 { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 8px; }
        .pa-btns { display: flex; flex-wrap: wrap; gap: 8px; }
        .pa-note { margin: 0; font-size: 11.5px; color: #8a94a6; }

        .pa-filter { display: flex; flex-wrap: wrap; align-items: center; justify-content: space-between; gap: 10px 16px; margin-bottom: 12px; }
        .pa-filter .pa-search { position: relative; flex: 1 1 260px; max-width: 420px; }
        .pa-filter .pa-search i { position: absolute; left: 11px; top: 11px; font-size: 13px; color: #8a94a6; pointer-events: none; }
        .pa-filter .pa-search input.form-control { padding-left: 32px !important; }
        .pa-count { font-size: 12.5px; font-weight: 700; color: #4a5568; }
        .pa-state { display: none; padding: 26px 16px; text-align: center; font-size: 13px; color: #8a94a6; }
        .pa-state i { display: block; margin-bottom: 6px; font-size: 26px; opacity: .6; }

        .pa-table-wrap { max-height: 62vh; overflow: auto; margin: 0 -16px; border-top: 1px solid #e3e8ee; }
        #tblItemDescription { width: 100%; margin: 0; border-collapse: separate; border-spacing: 0; }
        #tblItemDescription thead th {
            position: sticky; top: 0; z-index: 2; padding: 9px 16px;
            font-size: 11.5px; letter-spacing: .03em; text-transform: uppercase; white-space: nowrap;
            color: var(--theme-on-accent, #fff); background: var(--theme-accent, #438eb9);
            border-bottom: 2px solid var(--theme-accent-ink, #2b6a90);
        }
        #tblItemDescription thead th.pa-col-rate { width: 200px; text-align: right; }
        #tblItemDescription thead th.pa-col-act { width: 90px; text-align: center; }
        #tblItemDescription td { padding: 5px 16px; vertical-align: middle; border-bottom: 1px solid #eef1f5; }
        #tblItemDescription tbody tr:hover td { background: var(--theme-accent-soft, #f4f8fb); }
        /* td 1 is the hidden id cell; 2 = name, 3 = rate, 6 = action */
        #tblItemDescription td:nth-child(6) { text-align: center; }
        #tblItemDescription input[name="tbltxt_ServicesName"] {
            border: 0 !important; background: transparent !important; box-shadow: none !important;
            padding-left: 0 !important; font-weight: 600; cursor: default;
        }
        #tblItemDescription input[name="tbltxt_Rate"] { max-width: 168px; margin-left: auto !important; text-align: right; }
        #tblItemDescription td:nth-child(3) { text-align: right; }
        #tblItemDescription .pa-del { display: inline-flex; align-items: center; justify-content: center; width: 30px; height: 30px; border-radius: 6px; color: #c0392b; text-decoration: none; }
        #tblItemDescription .pa-del:hover { background: #fdecea; }

        html[data-theme="dark"] .pa-head h2 { color: var(--dk-text, #e6e9ef); }
        html[data-theme="dark"] .pa-head p, html[data-theme="dark"] .pa-note, html[data-theme="dark"] .pa-count { color: var(--dk-muted, #9aa6b8); }
        html[data-theme="dark"] .pa-badge { background: var(--dk-surface-3, #232d3d); color: var(--dk-text, #e6e9ef); }
        html[data-theme="dark"] .pa-tool { background: var(--dk-surface-3, #232d3d); border-color: var(--dk-border, #2d3748); }
        html[data-theme="dark"] .pa-btn-outline, html[data-theme="dark"] .pa-btn-quiet { background: var(--dk-surface-3, #232d3d); color: var(--dk-text, #e6e9ef); border-color: var(--dk-border, #2d3748); }
        html[data-theme="dark"] .pa-table-wrap, html[data-theme="dark"] #tblItemDescription td { border-color: var(--dk-border, #2d3748); }
        html[data-theme="dark"] #tblItemDescription thead th { background: var(--dk-surface-3, #232d3d); color: var(--dk-text, #e6e9ef); }
        html[data-theme="dark"] #tblItemDescription tbody tr:hover td { background: var(--dk-surface-3, #232d3d); }
    </style>
    <script type="text/javascript">

        $(document).ready(function () {
            loadItemList();
            initMedicineSearch();
            FillMainTestDepartment();
            loadGlAccounts();
            $('#ddlGlAccount').select2();
            var id = '<% =Request.QueryString["ID"] %>';
            if (id != "") {
                $('#btnSave').val('Update');
                $('#btnReplicate').show();
                $('#paMode').html('<i class="fa fa-pencil"></i> Editing');
                $('#paTitle').text('Panel Agreement');
                LoadPanelData(id);
                $('#paLoading').show();
                ajaxCall("panelagreement.aspx/loadData", JSON.stringify({ "panelID": id }), getResponseData);
            }
            $('#txtFilterRates').on('input', filterRates);
            var rateBody = document.getElementById('tblItemDescriptionDetail');
            if (rateBody && window.MutationObserver) {
                new MutationObserver(filterRates).observe(rateBody, { childList: true });
            }
            filterRates();
            $('#btnNew').on('click', function () {

                window.location.href = "panelagreement.aspx";
            });
            $('#btnList').on('click', function () {

                window.location.href = "PanelView.aspx";
            })
            $('#btnSave').on('click', function () {
                var id = '<% =Request.QueryString["ID"] %>';
                if (id != "") {

                }
                else {
                    id = "";
                }
                var valid = true;
                var btnValue = $("#btnSave").val();
                var cmp_name = $("#txtCompanyName").val();
                var no_of_emp = $("#txtEmpNo").val() || 0;
                var email = $("#txtEmail").val();
                var contact_no = $("#txtContactNo").val();
                var address = $("#txtAddress").val() ;
                var discount = $("#txtDiscount").val() || 0;

                var cmp_nameV = $("#txtCompanyName");
                var panelrate = $("#txtpanelrate").val() || 0;
                var panelrateEmergency = $("#txtpanelrateEmergency").val() || 0;
                var no_of_empV = $("#txtEmpNo") || 0;
                var emailV = $("#txtEmail");
                var Glcode = $("#ddlGlAccount").val();
                var contact_noV = $("#txtContactNo");
                var addressV = $("#txtAddress");
                var discountV = $("#txtDiscount") || 0;

                if (cmp_name == "") {
                    valid = false;
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Please Enter Company Name.',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });

                }
                if (true) {



                    var servicesList = new Array();
                    var list = document.getElementById('tblItemDescription');
                    for (var i = 1; i < list.rows.length; i++) {
                        var row = list.rows[i];
                        var serviceID = $(row).find('td').eq(0).find('input').val();
                        var serviceRate = $(row).find('td').eq(2).find('input').val();
                        if (serviceRate == "") {
                            alert("Please Enter Rate");
                            return false;
                        }
                        var groupCategory = $(row).find('td').eq(3).find('input').val();
                        var testID = $(row).find('td').eq(4).find('input').val();
                        servicesList[i] = new Array(serviceID, serviceRate, groupCategory, testID);
                    }

                    if (valid) {
                        setSaving(true);
                        $.ajax({
                            type: "POST",
                            url: "panelagreement.aspx/Save",
                            data: JSON.stringify({
                                'cmp_name': cmp_name,
                                'no_of_emp': no_of_emp,
                                'email': email,
                                'contact_no': contact_no,
                                'address': address,
                                'discount': discount,
                                'panelrate': panelrate,
                                'panelrateEmergency': panelrateEmergency,
                                "btnValue": btnValue,
                                "Glcode": Glcode,
                                "id": id,
                                "rateDetail": servicesList
                            }),
                            contentType: "application/json; charset=utf-8",
                            dataType: "json",
                            success: function (response) {
                                var data = response.d;
                                showSavedAndGo("panelagreement.aspx?ID=" + data);
                            }, error: function (xhr) { setSaving(false); showSaveError(xhr); }
                        });
                    }

                }
            })

        });
        // disable the save buttons while a save is running (no double submit)
        function setSaving(on) {
            $('#btnSave, #btnReplicate').prop('disabled', on);
        }
        function showSavedAndGo(url) {
            Swal.fire({
                icon: 'success',
                title: 'Saved',
                text: 'Panel agreement saved successfully.',
                showConfirmButton: false,
                timer: 1200
            });
            setTimeout(function () { window.location.href = url; }, 1300);
        }
        // filter the agreed-rates table by name and keep the item count / empty state up to date
        function filterRates() {
            var q = $.trim($('#txtFilterRates').val()).toLowerCase();
            var rows = $('#tblItemDescriptionDetail tr');
            var shown = 0;
            rows.each(function () {
                var name = ($(this).find('input[name="tbltxt_ServicesName"]').val() || '').toLowerCase();
                var show = !q || name.indexOf(q) > -1;
                this.style.display = show ? '' : 'none';
                if (show) shown++;
            });
            var total = rows.length;
            $('#lblRateCount').text(q ? shown + ' of ' + total + ' items' : total + (total == 1 ? ' item' : ' items'));
            $('#paEmpty').toggle(total == 0 && !$('#paLoading').is(':visible'));
            $('#paNoMatch').toggle(total > 0 && shown == 0);
        }
        function showSaveError(xhr) {
            var msg = 'Data could not be saved.';
            try {
                var r = JSON.parse(xhr.responseText);
                if (r && r.Message) msg += '\n' + r.Message;
            } catch (e) { }
            alert(msg);
        }
        function ReplicatePanel() {
            var valid = true;
            var cmp_name = $("#txtCompanyName").val();
            var no_of_emp = $("#txtEmpNo").val() || 0;
            var email = $("#txtEmail").val();
            var contact_no = $("#txtContactNo").val();
            var address = $("#txtAddress").val();
            var discount = $("#txtDiscount").val() || 0;

            var panelrate = $("#txtpanelrate").val() || 0;
            var panelrateEmergency = $("#txtpanelrateEmergency").val() || 0;
            var Glcode = $("#ddlGlAccount").val();

            if (cmp_name == "") {
                valid = false;
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Enter Company Name.',
                    showConfirmButton: false,
                    timer: 2000
                });
            }

            if (true) {

                var servicesList = new Array();
                var list = document.getElementById('tblItemDescription');
                for (var i = 1; i < list.rows.length; i++) {
                    var row = list.rows[i];
                    var serviceID = $(row).find('td').eq(0).find('input').val();
                    var serviceRate = $(row).find('td').eq(2).find('input').val();
                    if (serviceRate == "") {
                        alert("Please Enter Rate");
                        return false;
                    }
                    var groupCategory = $(row).find('td').eq(3).find('input').val();
                    var testID = $(row).find('td').eq(4).find('input').val();
                    servicesList[i] = new Array(serviceID, serviceRate, groupCategory, testID);
                }

                if (valid) {
                    setSaving(true);
                    $.ajax({
                        type: "POST",
                        url: "panelagreement.aspx/Save",
                        data: JSON.stringify({
                            'cmp_name': cmp_name,
                            'no_of_emp': no_of_emp,
                            'email': email,
                            'contact_no': contact_no,
                            'address': address,
                            'discount': discount,
                            'panelrate': panelrate,
                            'panelrateEmergency': panelrateEmergency,
                            "btnValue": "Replicate",
                            "Glcode": Glcode,
                            "id": "",
                            "rateDetail": servicesList
                        }),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (response) {
                            var data = response.d;
                            showSavedAndGo("PanelView.aspx");
                        }, error: function (xhr) { setSaving(false); showSaveError(xhr); }
                    });
                }
            }
        }
        function loadGlAccounts() {
            var options = '<option value="0">Please Select Account</option>';

            $.ajax({
                url: 'PanelAgreement.aspx/GetGLAccounts',
                type: 'POST',
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                success: function (response) {
                    var data = response.d ? JSON.parse(response.d) : response;
                    $.each(data, function (key, value) {
                        options += '<option value="' + value.Account_ID + '">' + value.Account_Name + '</option>';
                    });
                    $('#ddlGlAccount').html(options);
                    $('#ddlGlAccount').select2();


                },
                error: function (xhr, status, error) {
                    console.error('Error fetching area data:', error);
                }
            });

            return options;
        }

        function ajaxCall(url, data, getResposeParam) {

            var call = '';
            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: url,
                data: data,
                async: true,
                success: function (resp) {

                    //call = resp.d;
                    getResposeParam(resp.d);
                },
                error: function (data) {
                    $('#paLoading').hide();
                    filterRates();
                    alert("Error");
                }
            });
        }

        function LoadPanelData(id) {
            $.ajax({
                type: "POST",
                url: "panelagreement.aspx/LoadPanelData",
                data: JSON.stringify({ "id": id }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var parsed_Data = JSON.parse(response.d);
                    if (parsed_Data) {
                        $("#txtCompanyName").val(parsed_Data.Company_Name || '');
                        if (parsed_Data.Company_Name) $('#paTitle').text(parsed_Data.Company_Name);
                        $("#txtEmpNo").val(parsed_Data.No_Of_Employees || '');
                        $("#txtEmail").val(parsed_Data.Email || '');
                        $("#txtContactNo").val(parsed_Data.Contact_No || '');
                        $("#txtAddress").val(parsed_Data.Address || '');
                        $("#txtDiscount").val(parsed_Data.Discount || '');
                        $("#txtpanelrate").val(parsed_Data.Panel_Rate || '');
                        $("#txtpanelrateEmergency").val(parsed_Data.Panel_Rate_Emergency || '');
                        setTimeout(() => {
                            $('#ddlGlAccount').val(parsed_Data.gl_account || '0').trigger('change');
                        }, 1000);
                    }
                },
                error: function () {
                    console.error("Failed to load master panel data");
                }
            });
        }

        function loadItemList() {

            var optionsitem = '';
            $('#ddltble_Services').select2();

            PageMethods.loadItemtList(function (resp) {

                optionsitem = '<option value="0">Please Select</option>';
                $.each(JSON.parse(resp), function (key, value) {

                    optionsitem += '<option value="' + value.Item_ID + '" >' + value.name + '</option>';
                });

                $('#ddltble_Services').html(optionsitem);

            },
                function (error) {
                    alert(error.get_message());
                });
        }
        function appendRowHtml(itemID, itemName, Rate, testGroupCatVal, getTestID) {
            var rows = '<tr>' +
                '<td style="display:none"><input type="hidden" name="tbltxt_ServicesId" id="tbltxt_ServicesId" value="' + itemID + '"/></td>' +
                '<td>' +
                '<input type="text" name="tbltxt_ServicesName" id="tbltxt_ServicesName" value="' + itemName + '" readonly/>' +
                '</td>' +
                '<td>' +
                '<input type="text" name="tbltxt_Rate" id="tbltxt_Description" value="' + Rate + '" inputmode="decimal"/>' +
                '</td>' +
                '<td style="Display:None">' +
                '<input type="text"  value="' + testGroupCatVal + '"/>' +
                '</td>' +
                '<td style="Display:None">' +
                '<input type="text"  value="' + getTestID + '"/>' +
                '</td>' +

                '<td><a href="javascript:void(0)" class="pa-del" title="Remove" onclick="ExcludeFromPayment(this)"><i class="fa fa-trash-o" style="font-size:16px"></i></a>' +
                '</td>' +
                '</tr>'
            $('#tblItemDescriptionDetail').append(rows);
        }
        function Addrow() {


            var rows = '';
            var ItemId = $('#ddltble_Services').val();
            var Item = $('#ddltble_Services option:selected').text();
            var itemName1 = Item.split("-")[1];
            var itemName2 = Item.split("-")[2];
            var concat = itemName1 + '-' + itemName2;
            if (typeof itemName2 === 'undefined') {
                concat = itemName1;
            }


            var Rate = 0;
            if (ItemId == 0) {
                alert("Please Select Service");
                return false;
            }
            else {
                appendRowHtml(ItemId, concat, Rate);
            }
        }
        function initMedicineSearch() {
            $('#ddlMedicine').select2({
                placeholder: 'Search medicine',
                allowClear: true,
                minimumInputLength: 2,
                width: '100%',
                ajax: {
                    transport: function (params, success, failure) {
                        PageMethods.SearchMedicines(
                            params.data.term || '',
                            function (result) {
                                success({ results: JSON.parse(result) });
                            },
                            failure
                        );
                    }
                }
            });
        }
        function AddMedicineRow() {
            var data = $('#ddlMedicine').select2('data');
            if (!data || data.length == 0 || !data[0].id) {
                alert("Please Select Medicine");
                return false;
            }
            var itemID = data[0].id;
            var duplicate = false;
            $('#tblItemDescriptionDetail input[name="tbltxt_ServicesId"]').each(function () {
                if ($(this).val() == itemID) { duplicate = true; return false; }
            });
            if (duplicate) {
                alert("This medicine is already added");
                return false;
            }
            var name = data[0].description || data[0].text;
            appendRowHtml(itemID, $('<div>').text(name).html().replace(/"/g, '&quot;'), 0, '', '');
            $('#ddlMedicine').val(null).trigger('change');
        }
        function AddTestRow() {
            var maindpt = $('#ddlMainTestDepartment').val();
            var testGroupCatVal = $("#ddlTestList option:selected").attr('groupCat');

            var getTestID = $("#ddlTestList option:selected").attr('testID');
            var CheckTest = $('#ddlTestList option:selected').text();
            var Rate = 0;
            if (maindpt == 0) {
                alert("Please Select Main Department");
                return false;
            }
            else if (CheckTest == "" || CheckTest == "Please Select") {
                alert("Please Select Test");
                return false;
            }
            appendRowHtml(0, CheckTest, Rate, testGroupCatVal, getTestID);
        }

        function getResponseData(x) {
            try {
                var d = JSON.parse(x);
                var allRows = '';
                for (var i = 0; i < d.length; i++) {
                    var item = d[i];
                    allRows +=
                        '<tr>' +
                        '<td style="display:none"><input type="hidden" name="tbltxt_ServicesId" value="' + (item.ItemID || '') + '"/></td>' +
                        '<td><input type="text" name="tbltxt_ServicesName" value="' + $('<div>').text(item.Description || '').html().replace(/"/g, '&quot;') + '" readonly/></td>' +
                        '<td><input type="text" name="tbltxt_Rate" value="' + (item.Rate || '0') + '" inputmode="decimal"/></td>' +
                        '<td style="display:none"><input type="text" value="' + (item.GroupCategory || '') + '"/></td>' +
                        '<td style="display:none"><input type="text" value="' + (item.TestID || '') + '"/></td>' +
                        '<td><a href="javascript:void(0)" class="pa-del" title="Remove" onclick="ExcludeFromPayment(this)">' +
                        '<i class="fa fa-trash-o" style="font-size:16px"></i>' +
                        '</a></td>' +
                        '</tr>';
                }
                $('#tblItemDescriptionDetail').html(allRows);
            } catch (e) {
                console.error("Error loading service rows:", e);
            } finally {
                $('#paLoading').hide();
                filterRates();
            }
        }
        function ExcludeFromPayment(anchor) {

            var a = confirm("Are you sure You want to delete");
            if (a == true) {
                console.clear();
                var row = $(anchor).parents('tr')[0];
                row.remove();
            }
        }
        function FillLabTests() {
            var options = '<option value="0" >Please Select</option>';
            PageMethods.GetLabTests(function (Tests) {
                $.each(JSON.parse(Tests), function (key, value) {
                    options += '<option testID="' + value.TestID + '" groupCat="' + value.GroupCategory + '">' + value.TestName + '</option>';
                });
                $('#ddlTestList').html(options);
                $('#ddlTestList').select2();
                localStorage.TestForCategoryWiseSelections = options;
            });
        }
        function FillMainTestDepartment() {

            var options = '<option value="0" >Select Main Department</option>';
            PageMethods.FillTestMainDepartment(function (Tests) {
                $.each(JSON.parse(Tests), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                });
                $('#ddlMainTestDepartment').html(options);
            });
        }
        function LoadTestByDepartment() {


            var maindpt = $('#ddlMainTestDepartment').val();
            if (maindpt == "0") {
                $('#ddlTestList').val("");
                $('#ddlTestList').text("");
                $('#divRotation').hide();
            }
            if (maindpt == "001") {
                FillLabTests();
                $('#divRotation').hide();
            }
            else if (maindpt == "002") {
                FillTestsByCategory('002');
            }
            else if (maindpt == "003") {
                FillTestsByCategory('003');
            }
            else if (maindpt == "004") {
                FillTestsByCategory('004');
            }
            else if (maindpt == "005") {
                FillProcedure("005");
                $('#divRotation').hide();
            }
            else if (maindpt == "006") {

                FillProcedure("006");
                $('#divRotation').hide();
            }
            else if (maindpt == "007") {
                FillProcedure("007");
                $('#divRotation').hide();
            }
        }
        function FillTestsByCategory(CategoryID) {

            var options = '<option value="0" >Please Select</option>';
            if (CategoryID == '002') {
                $("#btnultrasound").removeClass("btn-info").addClass("btn-danger");
                $('#btnXray').removeClass('btn-danger').addClass('btn-info');
                $("#btnCTscan").removeClass("btn-danger").addClass("btn-info");
                $('#divRotation').hide();
            }
            else if (CategoryID == '003') {
                $("#btnXray").removeClass("btn-info").addClass("btn-danger");
                $('#btnultrasound').removeClass('btn-danger').addClass('btn-info');
                $("#btnCTscan").removeClass("btn-danger").addClass("btn-info");
                $('#divRotation').show();
                PageMethods.GetRotationsCategoryWise('Test XRay Rotations', function (GetRotations) {
                    var options = '<option value="0" >Select</option>';
                    $.each(JSON.parse(GetRotations), function (key, value) {
                        options += '<option groupCat="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                    });
                    $('#ddlRotation option').remove()
                    $('#ddlRotation').html(options);
                    $('#ddlRotation').select2();
                });
            }
            else if (CategoryID == '004') {
                $("#btnCTscan").removeClass("btn-info").addClass("btn-danger");
                $('#btnultrasound').removeClass('btn-danger').addClass('btn-info');
                $('#btnXray').removeClass('btn-danger').addClass('btn-info');

                $('#divRotation').show();

                PageMethods.GetRotationsCategoryWise('Test CT Scan Rotations', function (GetRotations) {
                    var options = '<option value="0" >Select</option>';
                    $.each(JSON.parse(GetRotations), function (key, value) {
                        options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                    });
                    $('#ddlRotation option').remove();
                    $('#ddlRotation').html(options);
                    $('#ddlRotation').select2();
                });
            }
            PageMethods.FillTestsByCategory(CategoryID, function (Tests) {

                var options = '<option value="0" >Please Select</option>';
                $.each(JSON.parse(Tests), function (key, value) {
                    options += '<option  testID="' + value.Test_ID + '" groupCat="' + value.Group_Category + '">' + value.Test_Name + '</option>';
                });
                $('#ddlTestList').html(options);
                $('#ddlTestList').select2();
            });
        }
        function onSelection() {


        }


        function AddAllrow() {
            PageMethods.loadItemtList(function (resp) {
                var parsedData = JSON.parse(resp);
                $.each(parsedData, function (key, index) {
                    var itemID = parsedData[key].Item_ID;
                    var itemName = parsedData[key].name;
                    var Rate = parsedData[key].Rate || "0";
                    appendRowHtml(itemID, itemName, Rate);
                });
            },
                function (error) {
                    alert(error.get_message());
                });
        }
        function AddallTest() {
            var maindpt = $('#ddlMainTestDepartment').val();

            if (maindpt == "0" || maindpt == "") {
                Swal.fire({
                    icon: 'warning',
                    title: 'Warning!',
                    text: 'Please Select a Department First.',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });
                return false;
            }

            if (maindpt == "001") {
                loadlabtest();
            }
            else if (maindpt == "002") {
                loadUltrasound('002');
            }
            else if (maindpt == "003") {
                loadUltrasound('003');
            }
            else if (maindpt == "004") {
                loadUltrasound('004');
            }
            else if (maindpt == "005") {
                loadProc("005");
            }
            else if (maindpt == "006") {
                loadProc("006");
            }
            else if (maindpt == "007") {
                loadProc("007");
            }
        }

        function loadlabtest() {
            PageMethods.GetLabTests(function (resp) {
                var parsedData = JSON.parse(resp);
                $.each(parsedData, function (key, index) {
                    var testID = parsedData[key].TestID;
                    var testName = parsedData[key].TestName;
                    var groupCat = parsedData[key].GroupCategory || "";
                    var Rate = parsedData[key].Rate || "0";
                    appendRowHtml(0, testName, Rate, groupCat, testID);
                });
            },
                function (error) {
                    alert(error.get_message());
                });
        }

        function loadUltrasound(CategoryID) {
            PageMethods.FillTestsByCategory(CategoryID, function (resp) {
                var parsedData = JSON.parse(resp);
                $.each(parsedData, function (key, index) {
                    var testID = parsedData[key].Test_ID;
                    var testName = parsedData[key].Test_Name;
                    var groupCat = parsedData[key].Group_Category || "";
                    var Rate = parsedData[key].Rate || "0";
                    appendRowHtml(0, testName, Rate, groupCat, testID);
                });
            },
                function (error) {
                    alert(error.get_message());
                });
        }

        function loadProc(deptID) {
            PageMethods.GetProcedure(deptID, function (resp) {
                var parsedData = JSON.parse(resp);
                $.each(parsedData, function (key, index) {
                    var testID = parsedData[key].TestID;
                    var testName = parsedData[key].TestName;
                    var Rate = parsedData[key].Rate || "0";
                    appendRowHtml(testID, testName, Rate, "", 0);
                });
            },
                function (error) {
                    alert(error.get_message());
                });
        }

    </script>
    <script type="text/javascript">
        $(document).ready(function () {
            $('#ddltble_Services').select2();
        });
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="pa-page">

        <!-- Page header + actions -->
        <div class="pa-head">
            <div>
                <h2><span id="paTitle">New Panel Agreement</span> <span class="pa-badge" id="paMode"><i class="fa fa-plus-circle"></i> New</span></h2>
                <p>Agreed rates for services, medicines and tests of a panel company.</p>
            </div>
            <div class="pa-actions">
                <input type="button" class="pa-btn pa-btn-primary" id="btnSave" value="Save" />
                <input type="button" class="pa-btn pa-btn-outline" id="btnReplicate" value="Replicate" style="display: none;" onclick="ReplicatePanel()" />
                <input type="button" class="pa-btn pa-btn-quiet" id="btnNew" value="New" />
                <input type="button" class="pa-btn pa-btn-quiet" id="btnList" value="View List" />
            </div>
        </div>

        <!-- Company + rates -->
        <div class="pa-top">
            <section class="ph-card">
                <h5 class="ph-card-title"><i class="fa fa-building-o"></i> Company Details</h5>
                <div class="ph-grid ph-grid-4">
                    <div class="ph-field ph-span-2">
                        <label for="txtCompanyName">Company Name <span class="pa-req">*</span></label>
                        <input type="text" name="txtCompanyName" class="form-control" id="txtCompanyName" placeholder="Panel company name" autocomplete="off" />
                    </div>
                    <div class="ph-field">
                        <label for="txtEmpNo">No of Employees</label>
                        <input type="text" name="txtEmpNo" class="form-control" id="txtEmpNo" inputmode="numeric" autocomplete="off" />
                    </div>
                    <div class="ph-field">
                        <label for="ddlGlAccount">GL Account</label>
                        <select id="ddlGlAccount" class="form-control"></select>
                    </div>
                    <div class="ph-field">
                        <label for="txtContactNo">Contact No</label>
                        <input type="text" name="txtContactNo" class="form-control" id="txtContactNo" inputmode="tel" autocomplete="off" />
                    </div>
                    <div class="ph-field">
                        <label for="txtEmail">Email</label>
                        <input type="text" name="txtEmail" class="form-control" id="txtEmail" placeholder="name@company.com" autocomplete="off" />
                    </div>
                    <div class="ph-field ph-span-2">
                        <label for="txtAddress">Address</label>
                        <input type="text" name="txtAddress" class="form-control" id="txtAddress" autocomplete="off" />
                    </div>
                </div>
            </section>

            <section class="ph-card">
                <h5 class="ph-card-title"><i class="fa fa-percent"></i> Rates &amp; Discount</h5>
                <div class="ph-grid pa-grid-3">
                    <div class="ph-field">
                        <label for="txtpanelrate">Rate OPD</label>
                        <input type="text" name="txtrate" class="form-control" id="txtpanelrate" inputmode="decimal" autocomplete="off" />
                    </div>
                    <div class="ph-field">
                        <label for="txtpanelrateEmergency">Rate Emergency</label>
                        <input type="text" name="txtrate" class="form-control" id="txtpanelrateEmergency" inputmode="decimal" autocomplete="off" />
                    </div>
                    <div class="ph-field">
                        <label for="txtDiscount">Discount</label>
                        <input type="text" name="txtDiscount" class="form-control" id="txtDiscount" inputmode="decimal" autocomplete="off" />
                    </div>
                </div>
            </section>
        </div>

        <!-- Add items to the agreement -->
        <section class="ph-card">
            <h5 class="ph-card-title"><i class="fa fa-plus-square-o"></i> Add to Agreement</h5>
            <div class="pa-tools">

                <div class="pa-tool">
                    <h6><i class="fa fa-stethoscope"></i> <span id="lb_services">Services</span></h6>
                    <div class="ph-field">
                        <select id="ddltble_Services" name="ddltble_Services" class="form-control" onchange="onSelection()"></select>
                    </div>
                    <div class="pa-btns">
                        <input type="button" onclick="Addrow()" class="pa-btn pa-btn-primary" value="Add" id="AddAccount" />
                        <input type="button" onclick="AddAllrow()" class="pa-btn pa-btn-outline" value="Add All Services" id="AddallAccount" />
                    </div>
                </div>

                <div class="pa-tool">
                    <h6><i class="fa fa-medkit"></i> <span id="lb_medicine">Medicines</span></h6>
                    <div class="ph-field">
                        <select id="ddlMedicine" name="ddlMedicine" class="form-control"></select>
                    </div>
                    <div class="pa-btns">
                        <input type="button" onclick="AddMedicineRow()" class="pa-btn pa-btn-primary" value="Add Medicine" id="AddMedicine" />
                    </div>
                    <p class="pa-note">Type 2 or more letters of the name or code.</p>
                </div>

                <div class="pa-tool">
                    <h6><i class="fa fa-flask"></i> Tests &amp; Procedures</h6>
                    <div class="pa-row-2">
                        <div class="ph-field">
                            <select id="ddlMainTestDepartment" class="form-control" onchange="LoadTestByDepartment()">
                                <option value="">Select Department</option>
                            </select>
                        </div>
                        <div class="ph-field">
                            <select id="ddlTestList" class="form-control"></select>
                        </div>
                    </div>
                    <div class="pa-btns">
                        <input type="button" onclick="AddTestRow()" class="pa-btn pa-btn-primary" value="Add Test" id="AddTests" />
                        <input type="button" onclick="AddallTest()" class="pa-btn pa-btn-outline" value="Add All Tests" id="AddallTests" />
                    </div>
                </div>

            </div>
        </section>

        <!-- Agreed rates -->
        <section class="ph-card">
            <h5 class="ph-card-title"><i class="fa fa-list"></i> Agreed Rates</h5>
            <div class="pa-filter">
                <div class="pa-search">
                    <i class="fa fa-search"></i>
                    <input type="text" id="txtFilterRates" class="form-control" placeholder="Filter by name" autocomplete="off" />
                </div>
                <span class="pa-count" id="lblRateCount">0 items</span>
            </div>
            <div class="pa-table-wrap">
                <table id="tblItemDescription">
                    <thead>
                        <tr>
                            <th>Name</th>
                            <th class="pa-col-rate">Rate</th>
                            <th class="pa-col-act">Action</th>
                        </tr>
                    </thead>
                    <tbody id="tblItemDescriptionDetail">
                    </tbody>
                </table>
                <div class="pa-state" id="paLoading"><i class="fa fa-spinner fa-spin"></i> Loading agreed rates...</div>
                <div class="pa-state" id="paEmpty" style="display: block;"><i class="fa fa-inbox"></i> No items yet. Add services, medicines or tests above.</div>
                <div class="pa-state" id="paNoMatch"><i class="fa fa-search"></i> No item matches the filter.</div>
            </div>
        </section>

    </div>
</asp:Content>
