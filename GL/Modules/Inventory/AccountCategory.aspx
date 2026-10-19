<%@ Page EnableSessionState="ReadOnly" Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AccountCategory.aspx.cs" Inherits="PMS.Inventory.AccountCategory" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

    <style type="text/css">
        .select2-selection__rendered
        {
            line-height: 18px !important;
        }
        /* read-only rows show plain dropdowns until Edit is clicked: make them look like the Select2 ones */
        #tblItemDescriptionDetail select:not(.select2-hidden-accessible)
        {
            width: 100%;
            height: 22px !important;
            padding: 0 4px;
            font-size: 10px !important;
            border: 1px solid #aaa;
            border-radius: 4px;
            background-color: #eee;
        }
        .main input 
        {
            margin-bottom: 0px !important;
        }
        .select2-container .select2-selection--single 
        {
            height: 20px !important;
        }
        .select2-selection__arrow 
        {
            height: 20px !important;
        }
        input[type="text"] 
        {
            height: 20px !important;
        }
        #ctl00_MainContent_Label2 
        {
            position: relative;
            left: 7px;
        }
        li.token-input-token p 
        {
            margin: -3px !important;
        }
        input[type="number"] 
        {
            height: 20px !important;
        }
        textarea 
        {
            font-size: 10px !important;
        }
        select 
        {
            height: 20px !important;
            
        }
        ul.token-input-list 
        {
            height: 23px !important;
            width: 692px !important;
        }
        div.token-input-dropdown 
        {
            overflow: auto;
            max-height: 150px;
        }
        ul.token-input-list 
        {
            width: 168px;
        }
        .table
        {
            margin: 1em 0;
            width: 100%;
            overflow: hidden;
            background: #FFF;
            color: #024457;
        }
        .table tr 
        {
            border: 1px solid #D9E4E6;
        }
        .table tr:nth-child(even) 
        {
            background-color: #EAF3F3;
        }
        .table th 
        {
            display: none;
            border: 1px solid #FFF;
            background-color: #438eb9;
            color: #FFF;
            padding: 1em;
        }
        .table thead th 
        {
            display: table-cell;
            text-align: center;
        }
        @media (min-width: 480px) 
        {
        .table th:nth-child(2) span
        {
            display: block;
        }
        .table th:nth-child(2):after 
        {
            display: none;
        }
        }
        .table td 
        {
            display: block;
            word-wrap: break-word;
            max-width: 7em;
        }
        .table td:first-child 
        {
            display: table-cell;
            text-align: center;
            border-right: 1px solid #D9E4E6;
        }
        @media (min-width: 480px) 
        {
        .table td 
        {
            border: 1px solid #D9E4E6;
        }
        }
        .table th, .table td 
        {
         text-align: center;
         margin: .5em 1em;
        }
        @media (min-width: 480px) 
        {
        .table th, .table td 
        {
          display: table-cell;
          padding: 1em;
        }
        }
        select option 
        {
         background: #f5f5f5;
         font-weight: bold;
         color: #000000;
         font-size: 10px !important;
        }
        .responstable td 
        {
            height: 0px !important;
            padding: 0 !important;
        }
        .labelIGP 
        {
            font-size: 11px !important;
        }
        .select2
        {
            width:123px !important;
        }

        .hide-id-column {
        display: none !important;
        }

        .hide-id-column {
            position: absolute;
            left: -9999px;
            width: 1px;
            height: 1px;
            overflow: hidden;
        }

    </style>
    <script type="text/javascript">
        function Addrow() {
            var rows = '';
            var rowlength = tblItemDescription.rows.length;
            rows += '<tr>' +
                '<td style="display:none;">' + rowlength + '</td>' +
                '<td><input type=text class="form-control" id="AcId' + rowlength + '" name="AcId" style="font-size: 10px !important;height:20px!important;"  value=' + rowlength + ' readonly=readonly /></td>' +
                '<td><input type=text class="form-control" id="AccountCategoryName' + rowlength + '" name="AccountCategoryName" style="font-size: 10px !important;height:20px!important;"  /></td>' +
                '<td><select class="form-control" id="txtAccountCode' + rowlength + '" name="txtAccountCode" style="font-size: 10px !important;height:10px!important;"></select></td>' +
                '<td><select class="form-control" id="txtConsumptionAccount' + rowlength + '" name="txtConsumptionAccount" style="font-size: 10px !important;height:10px!important;"></select></td>' +
                '<td><select class="form-control" id="txtsalAccount' + rowlength + '" name="txtsalAccount" style="font-size: 10px !important;height:10px!important;"></select></td>' +
                '<td><select class="form-control" id="txtCgsAccount' + rowlength + '" name="txtCgsAccount" style="font-size: 10px !important;height:10px!important;"></select></td>' +
                '<td><select class="form-control" id="txtworkProgress' + rowlength + '" name="txtworkProgress" style="font-size: 10px !important;height:10px!important;"></select></td>' +
                '<td><select class="form-control" id="txtCapitalConsumption' + rowlength + '" name="txtCapitalConsumption" style="font-size: 10px !important;height:10px!important;"></select></td>' +
                '<td style="text-align:center;"><a href="javascript:void(0)" title="Delete" onclick="ExcludeFromPayment(this)"><i class="fa fa-trash-o" style="font-size:16px;color:#f30a0a !important;"></i></a></td>' +
            '</tr>';
            $('#tblItemDescriptionDetail').append(rows);
            loadItemList(rowlength);
        }
        $(document).ready(function () {
            $('select').select2();
            LoadAccount();
            $('#btnSave').attr('disabled', true);

            $('#searchCategoryName').on('input', function () {
                var searchTerm = $(this).val().toLowerCase();

                $('#tblItemDescriptionDetail tr').each(function () {
                    var categoryName = $(this).find('td:nth-child(3) input[name=AccountCategoryName]').val().toLowerCase(); 
                    if (categoryName.includes(searchTerm)) {
                        $(this).show(); 
                    } else {
                        $(this).hide();
                    }
                });
            });
        });
        // The six account dropdowns of a row, in the same order as the columns.
        var accountSelectIds = ['txtAccountCode', 'txtConsumptionAccount', 'txtsalAccount', 'txtCgsAccount', 'txtworkProgress', 'txtCapitalConsumption'];

        // The level-4 account list is loaded ONCE and shared by every row (it used to be requested again for each row,
        // and every dropdown of every row was filled with the whole list).
        var accountOptionsHtml = '';      // '<option>Please Select</option>' + one <option> per account
        var accountNames = {};            // Account_ID -> "code-name"
        var accountsLoaded = false;
        var accountWaiters = [];

        function escapeHtml(s) {
            return String(s == null ? '' : s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
        }

        function withAccountList(callback) {
            if (accountsLoaded) { callback(); return; }
            accountWaiters.push(callback);
            if (accountWaiters.length > 1) { return; }      // a request is already running
            PageMethods.loadAccountList(function (resp) {
                var html = ['<option value="0">Please Select</option>'];
                $.each(resp ? JSON.parse(resp) : [], function (key, value) {
                    accountNames[value.Account_ID] = value.name;
                    html.push('<option value="' + value.Account_ID + '">' + escapeHtml(value.name) + '</option>');
                });
                accountOptionsHtml = html.join('');
                accountsLoaded = true;
                var waiting = accountWaiters;
                accountWaiters = [];
                $.each(waiting, function (i, fn) { fn(); });
            },
                function (error) {
                    accountWaiters = [];
                    alert(error.get_message());
                });
        }

        // Fill ONE dropdown with just its saved account. The full list is only added when the row is edited
        // (EditRow) or created (Addrow), so a page with many categories no longer builds thousands of options per row.
        function showSavedAccount(selectEl, savedId) {
            var html = '';
            if (savedId === 0 || savedId === '0') {
                html = '<option value="0">Please Select</option>';
            } else if (savedId !== null && savedId !== undefined && savedId !== '') {
                html = '<option value="' + savedId + '">' + escapeHtml(accountNames[savedId] || savedId) + '</option>';
            }
            $(selectEl).html(html).val(savedId === null || savedId === undefined ? null : String(savedId));
        }

        // Put the whole account list into one dropdown, keeping whatever is currently selected.
        function fillAllAccounts(selectEl) {
            var current = $(selectEl).val();
            $(selectEl).html(accountOptionsHtml).val(current === null ? null : current);
        }

        // New (empty) row: every dropdown gets the full list with "Please Select" chosen.
        function loadItemList(rowlength) {
            var length = rowlength;
            $.each(accountSelectIds, function (i, id) { $('#' + id + length).select2(); });
            withAccountList(function () {
                $.each(accountSelectIds, function (i, id) { $('#' + id + length).html(accountOptionsHtml); });
            });
        }
        function SaveAllRecord() {
            var btnSave = 'Update';
            var tableItems = $('#tblItemDescription');
            var Account_list = [];
            tableItems.find('tr:gt(0)').each(function (key, value) {

                var cataName = $(value).find('td input[name=AccountCategoryName]').val();
                var assetAccount = $(value).find('td select[name=txtAccountCode]').val();
                var consumptionAccount = $(value).find('td select[name=txtConsumptionAccount]').val();
                var salAccount = $(value).find('td select[name=txtsalAccount]').val();
                var cgsAccount = $(value).find('td select[name=txtCgsAccount]').val();
                var workProgressAccount = $(value).find('td select[name=txtworkProgress]').val();
                var capitalConsumptionAccount = $(value).find('td select[name=txtCapitalConsumption]').val();

                if ((assetAccount !== '0' || consumptionAccount !== '0' || salAccount !== '0' || cgsAccount !== '0' || workProgressAccount !== '0' || capitalConsumptionAccount !== '0') && cataName) {
                    Account_list.push({
                        'Account_Category_Id': $(value).find('td input[name=AccountId]').val(), 'CategoryName': $(value).find('td input[name=AccountCategoryName]').val(), 'AssetAccount': $(value).find('td select[name=txtAccountCode]').val(), 'ConsumptionAccount': $(value).find('td select[name=txtConsumptionAccount]').val(), 'SalAccount': $(value).find('td select[name=txtsalAccount]').val(), 'CgsAccount': $(value).find('td select[name=txtCgsAccount]').val(), 'WorkProgressAccount': $(value).find('td select[name=txtworkProgress]').val(), 'CapitalConsumptionAccount': $(value).find('td select[name=txtCapitalConsumption]').val(),
                    });              
                }
            });
            var AllItemDetail = { 'btnSave': btnSave, 'AccountList': Account_list };
            PageMethods.SaveAccount(btnSave, JSON.stringify(AllItemDetail), function (res) {
                Swal.fire({
                    icon: 'success',
                    title: 'Success!',
                    text: 'Data Save Successfully',
                    showConfirmButton: false,
                    timer: 2500,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                $('#btnSave').val("Update");
                location.reload();
            });
        }
        function LoadAccount() {
            var rows = '';
            PageMethods.LoadAccount(function (resp) {
                var data = (JSON.parse(resp));
                selectedOptions = data;
                var rowIndex = parseInt((parseInt($('#tblItemDescriptionDetail tbody tr').length)));
                $.each(data, function (key, value) {
                    rows += '<tr>' +
                        '<td ><input type=text class="form-control" id="AccountId' + (key + 1) + '" name="AccountId" style="font-size: 10px !important;height:20px!important;"  value=' + data[key].Account_Category_Id + ' readonly=readonly /></td>' +
                        '<td class="hide-id-column"><input type=text class="form-control" id="Id' + (key + 1) + '" name="Id" style="font-size: 10px !important;height:20px!important;"  value=' + (key + 1) + ' readonly=readonly /></td>' +
                        '<td><input type=text class="form-control" id="AccountCategoryName' + (key + 1) + '" name="AccountCategoryName" style="font-size: 10px !important;height:20px!important;"  value="' + value.CategoryName + '" readonly=readonly /></td>' +
                        '<td><select class="form-control" id="txtAccountCode' + (key + 1) + '" name="txtAccountCode" style="font-size: 10px !important;height:22px!important;" readonly=readonly ></select></td>' +
                        '<td><select class="form-control" id="txtConsumptionAccount' + (key + 1) + '" name="txtConsumptionAccount" style="font-size: 10px !important;height:22px!important;" readonly=readonly ></select></td>' +
                        '<td><select class="form-control" id="txtsalAccount' + (key + 1) + '" name="txtsalAccount" style="font-size: 10px !important;height:22px!important;" readonly=readonly ></select></td>' +
                        '<td><select class="form-control" id="txtCgsAccount' + (key + 1) + '" name="txtCgsAccount" style="font-size: 10px !important;height:22px!important;" readonly=readonly ></select></td>' +
                        '<td><select class="form-control" id="txtworkProgress' + (key + 1) + '" name="txtworkProgress" style="font-size: 10px !important;height:22px!important;" readonly=readonly ></select></td>' +
                        '<td><select class="form-control" id="txtCapitalConsumption' + (key + 1) + '" name="txtCapitalConsumption" style="font-size: 10px !important;height:22px!important;" readonly=readonly ></select></td>' +
                        '<td style="text-align:center;"><a href="javascript:void(0)" title="Edit" onclick="EditRow(' + (key + 1) + ')"><i class="fa fa-pencil-square-o" style="font-size:16px;color:var(--theme-accent, #EFA63E) !important;"></i></a></td>' +
                        '</tr>';
                });
                $('#tblItemDescriptionDetail').append(rows);
                // once the account list has arrived, show each row's saved accounts (read-only until Edit is clicked)
                withAccountList(function () {
                    $.each(selectedOptions, function (key, value) {
                        var saved = [value.Asset_Account, value.Consumption_Account, value.Sal_Account, value.CgsAccount, value.Work_Progress_Account, value.Capital_Consumption_Account];
                        $.each(accountSelectIds, function (i, id) {
                            var el = $('#' + id + (key + 1));
                            showSavedAccount(el, saved[i]);
                            // read-only rows stay plain dropdowns (a Select2 widget per dropdown was the slow part);
                            // EditRow turns a row's dropdowns into Select2 when the user edits it
                            el.prop('disabled', true);
                        });
                    });
                    $('#btnSave').attr('disabled', false);
                });

            });
        }
        function ExcludeFromPayment(anchor) {
            var a = confirm("Are you sure You want to delete");
            if (a == true) {
                console.clear();
                var row = $(anchor).parents('tr')[0];
                row.remove();
            }
        }
        function EditRow(rowlength) {
            var length = rowlength;
            $('#AccountCategoryName' + length).attr("readonly", false);
            // this row is being edited: now give its dropdowns the full account list (the saved account stays selected)
            withAccountList(function () {
                $.each(accountSelectIds, function (i, id) {
                    var el = $('#' + id + length);
                    fillAllAccounts(el);
                    if (!el.hasClass('select2-hidden-accessible')) { el.select2(); }
                    el.prop("disabled", false).trigger('change');
                });
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
        <div class="col-lg-1 col-md-4 col-sm-6">
     <input type="button" class="btn-primry" onclick="Addrow()" value="+" id="AddAccount" />
 </div>
        <div class="col-lg-9 col-md-4 col-sm-6"></div>
        <div class="col-lg-2 col-md-12 col-sm-12" style="margin-bottom: 10px;">
        <input type="text" id="searchCategoryName" class="form-control" placeholder="Search by Category Name" style="height: 40px !important;" />
    </div>
        </div>
    <div class="row">
        <div class="col-lg-12 col-md-12- col-sm-12" style="overflow-x:scroll;height:600px">
        <table class="table" id="tblItemDescription" style="margin-top: 13px; font-size: 10px!important;">
            <thead >
                <tr>
                    <th style="text-align: center; font-size: 10px;" >Account Category Id</th>
                    <th class="hide-id-column" style="text-align: center; font-size: 10px;display:none">Id</th>
                    <th style="text-align: center; font-size: 10px;">Category Name</th>
                    <th style="text-align: center; font-size: 10px;">Asset Account</th>
                    <th style="text-align: center;">Consumption Account</th>
                    <th style="text-align: center;">Sale Account</th>
                    <th style="text-align: center;">Cost of Sale</th>
                    <th style="text-align: center;">Work in Process</th>
                    <th style="text-align: center;">Capital Consumption</th>
                    <th style="text-align: center;" id="thaction">Action</th>
                </tr>
               
            </thead>
            <tbody id="tblItemDescriptionDetail">
            </tbody>
        </table>
        </div>
        </div>
    <div class="purchaseOrderSubmitForm" style=" margin-top: 21px;">
      <div class="row">
            <div class="col-lg-1 col-md-4 col-sm-12">
                            <input type="button" class="btn-primry" onclick="SaveAllRecord()" value="Save" id="btnSave" />
                        </div>
      </div>
                      
              
    </div>
</asp:Content>
