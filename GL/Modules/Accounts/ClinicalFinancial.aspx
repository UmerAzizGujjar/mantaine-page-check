<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ClinicalFinancial.aspx.cs" Inherits="PMS.Modules.Accounts.ClinicalFinancial" EnableSessionState="ReadOnly" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/ClinicalFinancial.css" rel="stylesheet" />

    <script type="text/javascript">

        $(document).ready(function () {
            loadCommonDropdowns(function () {
                OPDloadSavedRows();
                IPDloadSavedRows();
                OPDShareloadSavedRows();
                RegloadSavedRows();
                DiagnosticloadSavedRows();
                DiagnosticShareloadSavedRows();
                SpecialServicesloadSavedRows();
                EMERGENCYloadSavedRows();
                SERVICEloadSavedRows();
                ProcedureloadSavedRows();
                PHARMACYloadSavedRows();
                AdvanceloadSavedRows();
                RefundloadSavedRows();
            });
        });

        //tabs 
        $(function () {
            $("#tabs").tabs();
        });

        // ===== Dropdown caching: fetch each dataset once, reuse everywhere =====
        var dropdownCache = {
            clinicalDept: '',
            patientTypes: '',
            mainTestDepts: '',
            specialServices: '',
            accounts: '',
            costCenters: ''
        };
        // Account dropdowns start with only "Please Select" (plus the saved value); the full
        // account list is filled in the first time the dropdown is opened (see select2:opening).
        var LAZY_ACCOUNT_OPTIONS = '<option value="0" data-lazy="1">Please Select</option>';
        var dropdownCacheLoaded = false;
        var dropdownCacheLoading = false;
        var pendingDropdownCallbacks = [];

        function fetchDropdown(method) {
            return $.ajax({
                url: 'ClinicalFinancial.aspx/' + method,
                type: 'POST',
                contentType: 'application/json; charset=utf-8',
                dataType: 'json'
            }).then(function (response) {
                return response.d ? JSON.parse(response.d) : response;
            });
        }

        function buildOptions(data, isAccounts) {
            var options = '<option value="0">Please Select</option>';
            $.each(data, function (key, value) {
                if (isAccounts) {
                    options += '<option value="' + value.Account_ID + '">' + value.Account_Code + ' - ' + value.Account_Name + '</option>';
                } else {
                    options += '<option value="' + value.DataValue_Name + '">' + value.DataValue_Description + '</option>';
                }
            });
            return options;
        }

        // account code/name by id, used to show the saved account without the full list
        function buildAccountText(data) {
            var text = {};
            $.each(data, function (key, value) {
                text[String(value.Account_ID)] = value.Account_Code + ' - ' + value.Account_Name;
            });
            return text;
        }

        function loadCommonDropdowns(callback) {
            if (dropdownCacheLoaded) {
                if (callback) callback();
                return;
            }
            if (dropdownCacheLoading) {
                if (callback) pendingDropdownCallbacks.push(callback);
                return;
            }
            dropdownCacheLoading = true;
            $.when(
                fetchDropdown('ClinicalFinancialDepartmentDropdown').then(function (d) { dropdownCache.clinicalDept = buildOptions(d, false); }),
                fetchDropdown('PatientType').then(function (d) { dropdownCache.patientTypes = buildOptions(d, false); }),
                fetchDropdown('MainTestDepartments').then(function (d) { dropdownCache.mainTestDepts = buildOptions(d, false); }),
                fetchDropdown('SpecialServices').then(function (d) { dropdownCache.specialServices = buildOptions(d, false); }),
                fetchDropdown('filldropdowns').then(function (d) {
                    dropdownCache.accounts = buildOptions(d, true);
                    dropdownCache.accountText = buildAccountText(d);
                }),
                fetchDropdown('CostCenterDropdown').then(function (d) { dropdownCache.costCenters = buildOptions(d, false); })
            ).done(function () {
                dropdownCacheLoaded = true;
                dropdownCacheLoading = false;
                $('#OPD_ClinicalFinancialDepartment').html(dropdownCache.clinicalDept);
                flushDropdownCallbacks(callback);
            }).fail(function () {
                dropdownCacheLoaded = true;
                dropdownCacheLoading = false;
                flushDropdownCallbacks(callback);
            });
        }

        function flushDropdownCallbacks(immediate) {
            if (immediate) immediate();
            while (pendingDropdownCallbacks.length) {
                (pendingDropdownCallbacks.shift())();
            }
        }

        // First time an account dropdown is opened, fill in the full account list and keep the saved value.
        $(document).on('select2:opening', 'select', function () {
            var $s = $(this);
            if (!$s.children('option[data-lazy]').length || !dropdownCache.accounts) { return; }

            var cur = $s.val();
            $s.html(dropdownCache.accounts);
            if (cur && cur !== '0' && $s.children('option').filter(function () { return this.value === cur; }).length === 0) {
                var label = (dropdownCache.accountText && dropdownCache.accountText[cur]) || cur;
                $s.append($('<option></option>').attr('value', cur).text(label));
            }
            if (cur) { $s.val(cur); }
        });

        // Initialize select2 only on elements not already done, so repeated calls
        // after each table load / add-row never rebuild existing widgets.
        function initSelect2(scope) {
            $(scope || document).find('.select2select:not(.s2-inited)').each(function () {
                $(this).addClass('s2-inited').select2();
            });
        }

        //SAVE DATA
     function submitData() {
    let isEmptyFound = false;
    let allData = [];
    let categoryNamesIPD = new Set();
    let categoryNamesOPD = new Set();
    let categoryNamesOPDShare = new Set();
    let categoryNamesReg = new Set();
    let categoryNamesDiagnostic = new Set();
    let categoryNamesDiagnosticShare = new Set();
    let categoryNamesEMERGENCY = new Set();
    let categoryNamesSERVICE = new Set();
    let categoryNamesPHARMACY = new Set();
    let categoryNamesProcedure = new Set();
    let categoryNamesSpecialService = new Set();
    let categoryNamesRefund = new Set();
    let duplicateFound = false;
    
    let rowsOPD = $('#tableOPD .data-row');
    let rowsIPD = $('#tableIPD .data-row');
    let rowsOPDShare = $('#tableOPDShare .data-row');
    let rowsReg = $('#tableReg .data-row');
    let rowsDiagnostic = $('#tableDiagnostic .data-row');
    let rowsDiagnosticShare = $('#tableDiagnosticShare .data-row');
    let rowsSpecialService = $('#tableSpecialServices .data-row');
    let rowsProcedure = $('#tableProcedure .data-row');
    let rowsEMERGENCY = $('#tableEMERGENCY .data-row');
    let rowsSERVICE = $('#tableSERVICE .data-row');
    let rowsPHARMACY = $('#tablePHARMACY .data-row');
    let rowsAdvance = $('#tableAdvance .data-row');
    let rowsRefund = $('#tableRefund .data-row');
   

    // Check if any rows exist
    if (rowsOPD.length === 0 && rowsIPD.length === 0 && rowsOPDShare.length === 0 && rowsReg.length === 0 && 
        rowsSpecialService.length === 0 && rowsProcedure.length === 0 && rowsDiagnostic.length === 0 && 
        rowsDiagnosticShare.length === 0 && rowsEMERGENCY.length === 0 && rowsSERVICE.length === 0 && 
        rowsPHARMACY.length === 0 && rowsAdvance.length === 0 && rowsRefund.length === 0) {
        isEmptyFound = true;
    }

    // Get all data from existing tables (keep your existing code for other tabs)
    rowsIPD.each(function () {
        let row = $(this);
        let editableIPD = row.find('select:not(:disabled)').length > 0;
        let rowDataIPD = {
            financialdepartment: row.find('.financialDepartmentIPD').val(),
            categoryname: row.find('.categorynameIPD').val(),
            cashinhand: row.find('.cashinhandIPD').val(),
            discount: row.find('.discountIPD').val(),
            revenue: row.find('.revenueIPD').val()
        };
        if (editableIPD && (rowDataIPD.categoryname == 0 || rowDataIPD.cashinhand == 0)) {
            isEmptyFound = true;
        }
        if (categoryNamesIPD.has(rowDataIPD.categoryname)) {
            duplicateFound = true;
        } else {
            categoryNamesIPD.add(rowDataIPD.categoryname);
        }
        allData.push(rowDataIPD);
    });
    
    rowsOPD.each(function () {
        let row = $(this);
        let editableOPD = row.find('select:not(:disabled)').length > 0;
        let rowDataOPD = {
            financialdepartment: row.find('.financialDepartmentOPD').val(),
            categoryname: row.find('.categorynameOPD').val(),
            costcenter: row.find('.costcenterOPD').val(),
            cashinhand: row.find('.cashinhandOPD').val(),
            discount: row.find('.discountOPD').val(),
            revenue: row.find('.revenueOPD').val()
        };
        if (editableOPD && (rowDataOPD.categoryname == 0 || rowDataOPD.cashinhand == 0 || rowDataOPD.discount == 0)) {
            isEmptyFound = true;
        }
        if (categoryNamesOPD.has(rowDataOPD.categoryname)) {
            duplicateFound = true;
        } else {
            categoryNamesOPD.add(rowDataOPD.categoryname);
        }
        allData.push(rowDataOPD);
    });
    
    rowsOPDShare.each(function () {
        let row = $(this);
        let editableOPDShare = row.find('select:not(:disabled)').length > 0;
        let rowDataOPDShare = {
            financialdepartment: row.find('.financialDepartmentOPDShare').val(),
            categoryname: row.find('.categorynameOPDShare').val(),
            cashinhand: row.find('.cashinhandOPDShare').val(),
            discount: row.find('.discountOPDShare').val(),
            revenue: row.find('.revenueOPDShare').val()
        };
        if (editableOPDShare && (rowDataOPDShare.categoryname == 0 || rowDataOPDShare.cashinhand == 0)) {
            isEmptyFound = true;
        }
        if (categoryNamesOPDShare.has(rowDataOPDShare.categoryname)) {
            duplicateFound = true;
        } else {
            categoryNamesOPDShare.add(rowDataOPDShare.categoryname);
        }
        allData.push(rowDataOPDShare);
    });
    
    rowsReg.each(function () {
        let row = $(this);
        let editableReg = row.find('select:not(:disabled)').length > 0;
        let rowDataReg = {
            financialdepartment: row.find('.financialDepartmentReg').val(),
            categoryname: row.find('.categorynameReg').val(),
            cashinhand: row.find('.cashinhandReg').val(),
            discount: row.find('.discountReg').val(),
            revenue: row.find('.revenueReg').val()
        };
        if (editableReg && (rowDataReg.cashinhand == 0)) {
            isEmptyFound = true;
        }
        if (categoryNamesReg.has(rowDataReg.categoryname)) {
            duplicateFound = true;
        } else {
            categoryNamesReg.add(rowDataReg.categoryname);
        }
        allData.push(rowDataReg);
    });
    
    rowsDiagnostic.each(function () {
        let row = $(this);
        let editableDiagnostic = row.find('select:not(:disabled)').length > 0;
        let rowDataDiagnostic = {
            financialdepartment: row.find('.financialDepartmentDiagnostic').val(),
            categoryname: row.find('.categorynameDiagnostic').val(),
            costcenter: row.find('.costcenterDiagnostic').val(),
            cashinhand: row.find('.cashinhandDiagnostic').val(),
            discount: row.find('.discountDiagnostic').val(),
            revenue: row.find('.revenueDiagnostic').val(),
            expense: row.find('.expenseDiagnostic').val()
        };
        if (editableDiagnostic && (rowDataDiagnostic.categoryname == 0 || rowDataDiagnostic.cashinhand == 0 || rowDataDiagnostic.discount == 0 || rowDataDiagnostic.expense == 0)) {
            isEmptyFound = true;
        }
        if (categoryNamesDiagnostic.has(rowDataDiagnostic.categoryname)) {
            duplicateFound = true;
        } else {
            categoryNamesDiagnostic.add(rowDataDiagnostic.categoryname);
        }
        allData.push(rowDataDiagnostic);
    });
    
    rowsDiagnosticShare.each(function () {
        let row = $(this);
        let editableDiagnosticShare = row.find('select:not(:disabled)').length > 0;
        let rowDataDiagnosticShare = {
            financialdepartment: row.find('.financialDepartmentDiagnosticShare').val(),
            categoryname: row.find('.categorynameDiagnosticShare').val(),
            cashinhand: row.find('.cashinhandDiagnosticShare').val(),
            discount: row.find('.discountDiagnosticShare').val(),
            revenue: row.find('.revenueDiagnosticShare').val()
        };
        if (editableDiagnosticShare && (rowDataDiagnosticShare.categoryname == 0 || rowDataDiagnosticShare.cashinhand == 0)) {
            isEmptyFound = true;
        }
        if (categoryNamesDiagnosticShare.has(rowDataDiagnosticShare.categoryname)) {
            duplicateFound = true;
        } else {
            categoryNamesDiagnosticShare.add(rowDataDiagnosticShare.categoryname);
        }
        allData.push(rowDataDiagnosticShare);
    });
    
    rowsSpecialService.each(function () {
        let row = $(this);
        let editableSpecialService = row.find('select:not(:disabled)').length > 0;
        let rowDataSpecialService = {
            financialdepartment: row.find('.financialDepartmentSpecialServices').val(),
            categoryname: row.find('.categorynameSpecialServices').val(),
            costcenter: row.find('.costcenterSpecialServices').val(),
            cashinhand: row.find('.cashinhandSpecialServices').val(),
            discount: row.find('.discountSpecialServices').val(),
            revenue: row.find('.revenueSpecialServices').val()
        };
        if (editableSpecialService && (rowDataSpecialService.categoryname == 0 || rowDataSpecialService.cashinhand == 0 || rowDataSpecialService.discount == 0 )) {
            isEmptyFound = true;
        }
        if (categoryNamesSpecialService.has(rowDataSpecialService.categoryname)) {
            duplicateFound = true;
        } else {
            categoryNamesSpecialService.add(rowDataSpecialService.categoryname);
        }
        allData.push(rowDataSpecialService);
    });
    
    rowsProcedure.each(function () {
        let row = $(this);
        let editableProcedure = row.find('select:not(:disabled)').length > 0;
        let rowDataProcedure = {
            financialdepartment: row.find('.financialDepartmentProcedure').val(),
            categoryname: row.find('.categorynameProcedure').val(),
            cashinhand: row.find('.cashinhandProcedure').val(),
            discount: row.find('.discountProcedure').val(),
            revenue: row.find('.revenueProcedure').val()
        };
        if (editableProcedure && (rowDataProcedure.categoryname == 0 || rowDataProcedure.cashinhand == 0 || rowDataProcedure.discount == 0)) {
            isEmptyFound = true;
        }
        if (categoryNamesProcedure.has(rowDataProcedure.categoryname)) {
            duplicateFound = true;
        } else {
            categoryNamesProcedure.add(rowDataProcedure.categoryname);
        }
        allData.push(rowDataProcedure);
    });
    
    rowsEMERGENCY.each(function () {
        let row = $(this);
        let editableEMERGENCY = row.find('select:not(:disabled)').length > 0;
        let rowDataEMERGENCY = {
            financialdepartment: row.find('.financialDepartmentEMERGENCY').val(),
            categoryname: row.find('.categorynameEMERGENCY').val(),
            cashinhand: row.find('.cashinhandEMERGENCY').val(),
            discount: row.find('.discountEMERGENCY').val(),
            revenue: row.find('.revenueEMERGENCY').val()
        };
        if (editableEMERGENCY && (rowDataEMERGENCY.categoryname == 0 || rowDataEMERGENCY.cashinhand == 0 || rowDataEMERGENCY.discount == 0)) {
            isEmptyFound = true;
        }
        if (categoryNamesEMERGENCY.has(rowDataEMERGENCY.categoryname)) {
            duplicateFound = true;
        } else {
            categoryNamesEMERGENCY.add(rowDataEMERGENCY.categoryname);
        }
        allData.push(rowDataEMERGENCY);
    });
    
    rowsSERVICE.each(function () {
        let row = $(this);
        let editableSERVICE = row.find('select:not(:disabled)').length > 0;
        let rowDataSERVICE = {
            financialdepartment: row.find('.financialDepartmentSERVICE').val(),
            categoryname: row.find('.categorynameSERVICE').val(),
            costcenter: row.find('.costcenterSERVICE').val(),
            cashinhand: row.find('.cashinhandSERVICE').val(),
            discount: row.find('.discountSERVICE').val(),
            revenue: row.find('.revenueSERVICE').val(),
            expense: row.find('.expenseSERVICE').val()
        };
        if (editableSERVICE && (rowDataSERVICE.categoryname == 0 || rowDataSERVICE.cashinhand == 0 || rowDataSERVICE.discount == 0 || rowDataSERVICE.expense == 0)) {
            isEmptyFound = true;
        }
        if (categoryNamesSERVICE.has(rowDataSERVICE.categoryname)) {
            duplicateFound = true;
        } else {
            categoryNamesSERVICE.add(rowDataSERVICE.categoryname);
        }
        allData.push(rowDataSERVICE);
    });
    
         rowsPHARMACY.each(function () {
             let row = $(this);
             let editablePHARMACY = row.find('select:not(:disabled)').length > 0;
             let rowDataPHARMACY = {
                 financialdepartment: row.find('.financialDepartmentPHARMACY').val(),
                 categoryname: row.find('.categorynamePHARMACY').val(),
                 costcenter: row.find('.costcenterPHARMACY').val(),
                 cashinhand: row.find('.cashinhandPHARMACY').val(),
                 discount: row.find('.discountPHARMACY').val(),
                 revenue: row.find('.revenuePHARMACY').val(),
                 cgs: row.find('.cgsPHARMACY').val(),
                 balanceaccount: row.find('.balanceaccountPHARMACY').val(),
                itemaccount: row.find('.itemaccountPHARMACY').val()
             };
             if (editablePHARMACY && (rowDataPHARMACY.categoryname == 0 || rowDataPHARMACY.cashinhand == 0 || rowDataPHARMACY.discount == 0)) {
                 isEmptyFound = true;
             }
             if (categoryNamesPHARMACY.has(rowDataPHARMACY.categoryname)) {
                 duplicateFound = true;
             } else {
                 categoryNamesPHARMACY.add(rowDataPHARMACY.categoryname);
             }
             allData.push(rowDataPHARMACY);
         });
    
    // Handle Advance tab data - Hard-coded category name "Advance" with value "01"
    rowsAdvance.each(function () {
        let row = $(this);
        let editableAdvance = row.find('select:not(:disabled)').length > 0;
        let drValue = row.find('.drAdvance').val();
        let crValue = row.find('.crAdvance').val();
        
        let rowDataAdvance = {
            financialdepartment: row.find('.financialDepartmentAdvance').val(),
            categoryname: "01",  // Hard-coded value "01" for Advance
            cashinhand: drValue && drValue !== '0' ? drValue : '0',  // Dr dropdown value goes to CashInHand
            discount: '0',  // No discount for advance
            revenue: crValue && crValue !== '0' ? crValue : '0'      // Cr dropdown value goes to Revenue
        };
        
        // Check if either Dr or Cr is selected (but not both)
        let hasDr = drValue && drValue !== '0';
        let hasCr = crValue && crValue !== '0';
        
        if (editableAdvance && (!hasDr && !hasCr)) {
            Swal.fire({
                icon: 'error',
                title: 'Error!',
                text: 'In Advance tab, please select either Dr OR Cr.',
                showConfirmButton: false,
                timer: 2000
            });
            isEmptyFound = true;
            return;
        }
        
        allData.push(rowDataAdvance);
    });

         // In the submitData function, find the Refund section and replace it with this:

         rowsRefund.each(function () {
             let row = $(this);
             let editableRefund = row.find('select:not(:disabled)').length > 0;
             let drValue = row.find('.drRefund').val();
             let crValue = row.find('.crRefund').val();

             let rowDataRefund = {
                 financialdepartment: row.find('.financialDepartmentRefund').val(),
                 categoryname: "02",
                 cashinhand: drValue && drValue !== '0' ? drValue : '0',
                 discount: '0',
                 revenue: crValue && crValue !== '0' ? crValue : '0'
             };

             let hasDr = drValue && drValue !== '0';
             let hasCr = crValue && crValue !== '0';

             if (editableRefund && (!hasDr && !hasCr)) {
                 Swal.fire({
                     icon: 'error',
                     title: 'Error!',
                     text: 'In Refund tab, please select either Dr OR Cr.',
                     showConfirmButton: false,
                     timer: 2000
                 });
                 isEmptyFound = true;
                 return;
             }

             allData.push(rowDataRefund);
         });
    
    // Check for empty fields
    if (isEmptyFound) {
        Swal.fire({
            icon: 'error',
            title: 'Error!',
            text: 'Please fill all required fields in each row before submitting.',
            showConfirmButton: false,
            timer: 2000,
            customClass: {
                popup: 'swal-big-popup',
                title: 'swal-big-title',
                htmlContainer: 'swal-big-text'
            }
        });
        return;
    }
    
    if (duplicateFound) {
        Swal.fire({
            icon: 'error',
            title: 'Error!',
            text: 'Categories must be different within each section.',
            showConfirmButton: false,
            timer: 2000,
            customClass: {
                popup: 'swal-big-popup',
                title: 'swal-big-title',
                htmlContainer: 'swal-big-text'
            }
        });
        return;
    }
    
    // AJAX call to save all data
    if (!isEmptyFound && !duplicateFound) {
        $.ajax({
            type: "POST",
            url: "ClinicalFinancial.aspx/InsertData",
            data: JSON.stringify({ rows: allData }),
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (response) {
                Swal.fire({
                    icon: 'success',
                    title: 'Success!',
                    text: 'Data Inserted Successfully!',
                    showConfirmButton: false,
                    timer: 2500,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });
                setTimeout(function () {
                    location.reload();
                }, 2500);
            },
            error: function (xhr, status, error) {
                console.error("Error:", xhr.responseText || error);
                let msg = 'An error occurred while saving data.';
                try {
                    const resp = JSON.parse(xhr.responseText);
                    if (resp && resp.Message) msg = resp.Message;
                } catch (e) { }
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: msg,
                    showConfirmButton: true
                });
            }
        });
    }
}
        //load data from db
        function OPDloadSavedRows() {
            $.ajax({
                type: "POST",
                url: "ClinicalFinancial.aspx/loadSavedRowsOPD",
                data: '{}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    const savedData = response.d;
                    console.log(savedData);
                    getClinicalFinancialAcoountsDropdown(function (options) {
                        getPatientTypes(function (categoryOptions) {
                            getAccounts(function (optionsVen) {
                                var costCenterOptions = '';
                                getCostCenters(function (c) { costCenterOptions = c; });

                                savedData.forEach(item => {
                                    let row = `
                                        <tr class="data-row">
                                            <td style="display: none">
                                        
                                                <input type="hidden" class="financialDepartmentOPD" value="${item.financialdepartment}"/>
                                            </td>
                                            <td>
                                                <select class="categorynameOPD select2select" style="background-color: white; height:32px;" disabled>
                                                    ${setSelected(categoryOptions, item.categoryname)}
                                                </select>
                                            </td>
                                            <td>
                                                <select class="costcenterOPD select2select" style="background-color: white;" disabled>
                                                    ${setSelected(costCenterOptions, item.costcenter)}
                                                </select>
                                            </td>
                                            <td>
                                              <select class="cashinhandOPD select2select" style="background-color: white;" disabled>
                                                  ${setSelected(optionsVen, item.cashinhand)}
                                              </select>
                                            </td>
                                            <td>
                                                <select class="discountOPD select2select" style="background-color: white;" disabled>
                                                    ${setSelected(optionsVen, item.discount)}
                                                </select>
                                            </td>
                                            <td>
                                                <select class="revenueOPD select2select" style="background-color: white;" disabled>
                                                    ${setSelected(optionsVen, item.revenue)}
                                                </select>
                                            </td>
                                            <td>
                                                <a href="#" onclick="removeRow(this)">
                                                    <i class="fa fa-trash fa-lg " style="color: black;"></i>
                                                </a>
                                                <a href="#" onclick="enableSelectsInRow(this)" style="margin-left:20px">
                                                    <i class="fa fa-pencil fa-lg " style="color: black;"></i>
                                                </a>
                                            </td>
                                        </tr>`;

                                    $('.financialDepartmentOPD option[value="001"]').prop('selected', true);

                                    $('#tableOPD tbody').append(row);
                                });

                                initSelect2(); 
                            });
                        });
                    });
                }
            });
        }
  
function AdvanceloadSavedRows() {
    $.ajax({
        type: "POST",
        url: "ClinicalFinancial.aspx/loadSavedRowsAdvance",
        data: '{}',
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (response) {
            const savedData = response.d;
            console.log(savedData);
            getClinicalFinancialAcoountsDropdown(function (options) {
                getAccounts(function (optionsVen) {
                    savedData.forEach(item => {
                        let row = `
                            <tr class="data-row">
                                <td style="display: none">
                                    <input type="hidden" class="financialDepartmentAdvance" value="${item.financialdepartment}"/>
                                 </td>
                                 <td>
                                    <input type="text" class="categorynameAdvance form-control" value="Advance" disabled style="background-color: #f0f0f0;" />
                                    <input type="hidden" class="categorynameAdvanceHidden" value="01" />
                                 </td>
                                 <td>
                                    <select class="drAdvance select2select" style="background-color: white;" disabled>
                                        ${setSelected(optionsVen, item.dr)}
                                    </select>
                                 </td>
                                 <td>
                                    <select class="crAdvance select2select" style="background-color: white;" disabled>
                                        ${setSelected(optionsVen, item.cr)}
                                    </select>
                                 </td>
                                 <td>
                                    <a href="#" onclick="removeRow(this)">
                                        <i class="fa fa-trash fa-lg" style="color: black;"></i>
                                    </a>
                                    <a href="#" onclick="enableSelectsInRow(this)" style="margin-left:20px">
                                        <i class="fa fa-pencil fa-lg" style="color: black;"></i>
                                    </a>
                                 </td>
                             </tr>`;

                        $('#tableAdvance tbody').append(row);
                    });
                    initSelect2();
                });
            });
        },
        error: function (xhr, status, error) {
            console.error("Error loading advance rows:", error);
        }
    });
}
function addNewRowAdvance() {
    getClinicalFinancialAcoountsDropdown(function (options) {
        getAccounts(function (optionsVen) {
            let newRow = `
                <tr class="data-row">
                    <td style="display: none">
                        <input type="hidden" class="financialDepartmentAdvance" value="013">
                    </td>
                    <td>
                        <input type="text" class="categorynameAdvance form-control" value="Advance" readonly style="background-color: #f0f0f0;" />
                        <input type="hidden" class="categorynameAdvanceHidden" value="01" />
                    </td>
                    <td>
                        <select class="drAdvance select2select" style="background-color: white;">
                            ${optionsVen}
                        </select>
                    </td>
                    <td>
                        <select class="crAdvance select2select" style="background-color: white;">
                            ${optionsVen}
                        </select>
                    </td>
                    <td>
                        <a href="#" onclick="removeRow(this)">
                            <i class="fa fa-trash fa-lg" style="color: black;"></i>
                        </a>
                    </td>
                </tr>
            `;
            $('#tableAdvance tbody').append(newRow);
            $('.financialDepartmentAdvance option[value="013"]').prop('selected', true);
            initSelect2();
        });
    });
        }

        function addNewRowRefund() {
            getClinicalFinancialAcoountsDropdown(function (options) {
                getAccounts(function (optionsVen) {
                    let newRow = `
                <tr class="data-row">
                    <td style="display: none">
                        <input type="hidden" class="financialDepartmentRefund" value="014">
                    </td>
                    <td>
                        <input type="text" class="categorynameRefund form-control" value="Refund" readonly style="background-color: #f0f0f0;" />
                        <input type="hidden" class="categorynameRefundHidden" value="02" />
                    </td>
                    <td>
                        <select class="drRefund select2select" style="background-color: white;">
                            ${optionsVen}
                        </select>
                    </td>
                    <td>
                        <select class="crRefund select2select" style="background-color: white;">
                            ${optionsVen}
                        </select>
                    </td>
                    <td>
                        <a href="#" onclick="removeRow(this)">
                            <i class="fa fa-trash fa-lg" style="color: black;"></i>
                        </a>
                    </td>
                </tr>
            `;
                    $('#tableRefund tbody').append(newRow);
                    $('.financialDepartmentRefund option[value="014"]').prop('selected', true);
                    initSelect2();
                });
            });
        }

        function RefundloadSavedRows() {
            $.ajax({
                type: "POST",
                url: "ClinicalFinancial.aspx/loadSavedRowsRefund",
                data: '{}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    const savedData = response.d;
                    console.log(savedData);
                    getClinicalFinancialAcoountsDropdown(function (options) {
                        getAccounts(function (optionsVen) {
                            savedData.forEach(item => {
                                let row = `
                            <tr class="data-row">
                                <td style="display: none">
                                    <input type="hidden" class="financialDepartmentRefund" value="${item.financialdepartment}"/>
                                 </td>
                                 <td>
                                    <input type="text" class="categorynameRefund form-control" value="Refund" disabled style="background-color: #f0f0f0;" />
                                    <input type="hidden" class="categorynameRefundHidden" value="02" />
                                 </td>
                                 <td>
                                    <select class="drRefund select2select" style="background-color: white;" disabled>
                                        ${setSelected(optionsVen, item.dr)}
                                    </select>
                                 </td>
                                 <td>
                                    <select class="crRefund select2select" style="background-color: white;" disabled>
                                        ${setSelected(optionsVen, item.cr)}
                                    </select>
                                 </td>
                                 <td>
                                    <a href="#" onclick="removeRow(this)">
                                        <i class="fa fa-trash fa-lg" style="color: black;"></i>
                                    </a>
                                    <a href="#" onclick="enableSelectsInRow(this)" style="margin-left:20px">
                                        <i class="fa fa-pencil fa-lg" style="color: black;"></i>
                                    </a>
                                 </td>
                             </tr>`;

                                $('#tableRefund tbody').append(row);
                            });
                            initSelect2();
                        });
                    });
                },
                error: function (xhr, status, error) {
                    console.error("Error loading refund rows:", error);
                }
            });
        }


        //function IPDShareloadSavedRows() {
        //    $.ajax({
        //        type: "POST",
        //        url: "ClinicalFinancial.aspx/loadSavedRowsIPDShare",
        //        data: '{}',
        //        contentType: "application/json; charset=utf-8",
        //        dataType: "json",
        //        success: function (response) {
        //            const savedData = response.d;
        //            console.log(savedData);
        //            getClinicalFinancialAcoountsDropdown(function (options) {
        //                getPatientTypes(function (categoryOptions) {
        //                    getAccounts(function (optionsVen) {

        //                        savedData.forEach(item => {
        //                            let row = `
        //                        <tr class="data-row">
        //                            <td style="display: none">
                                
        //                                <input type="hidden" class="financialDepartmentIPDShare" value="${item.financialdepartment}"/>
        //                            </td>
        //                            <td>
        //                                <select class="categorynameIPDShare select2select" style="background-color: white; height:32px;" disabled>
        //                                    ${setSelected(categoryOptions, item.categoryname)}
        //                                </select>
        //                            </td>
        //                            <td>
        //                              <select class="cashinhandIPDShare select2select" style="background-color: white;" disabled>
        //                                  ${setSelected(optionsVen, item.cashinhand)}
        //                              </select>
        //                            </td>
        //                            <td>
        //                                <select class="discountIPDShare select2select" style="background-color: white;" disabled>
        //                                    ${setSelected(optionsVen, item.discount)}
        //                                </select>
        //                            </td>
        //                            <td>
        //                                <select class="revenueIPDShare select2select" style="background-color: white;" disabled>
        //                                    ${setSelected(optionsVen, item.revenue)}
        //                                </select>
        //                            </td>
        //                            <td>
        //                                <a href="#" onclick="removeRow(this)">
        //                                    <i class="fa fa-trash fa-lg " style="color: black;"></i>
        //                                </a>
        //                                <a href="#" onclick="enableSelectsInRow(this)" style="margin-left:20px">
        //                                    <i class="fa fa-pencil fa-lg " style="color: black;"></i>
        //                                </a>
        //                            </td>
        //                        </tr>`;

        //                            $('.financialDepartmentIPDShare option[value="012"]').prop('selected', true);

        //                            $('#tableIPDShare tbody').append(row);
        //                        });

        //                        initSelect2();
        //                    });
        //                });
        //            });
        //        }
        //    });
        //}
        function IPDloadSavedRows() {
            $.ajax({
                type: "POST",
                url: "ClinicalFinancial.aspx/loadSavedRowsIPD",
                data: '{}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    const savedData = response.d;
                    console.log(savedData);
                    getClinicalFinancialAcoountsDropdown(function (options) {
                       // getPatientTypes(function (categoryOptions) {
                            getAccounts(function (optionsVen) {

                                savedData.forEach(item => {
                                    let row = `
                                <tr class="data-row">
                                    <td style="display: none">
                                
                                        <input type="hidden" class="financialDepartmentIPD" value="${item.financialdepartment}"/>
                                    </td>
                                    <td>
               
                                             <select class="categorynameIPD" disabled style="background-color: white; height:32px;">
                                                 <option value="0">Please Select</option>
                                                 <option value="03" selected >IPD</option>
                                             </select>

                                    </td>
                                    <td>
                                      <select class="cashinhandIPD select2select" style="background-color: white;" disabled>
                                          ${setSelected(optionsVen, item.cashinhand)}
                                      </select>
                                    </td>
                                    <td>
                                        <select class="discountIPD select2select" style="background-color: white;" disabled>
                                            ${setSelected(optionsVen, item.discount)}
                                        </select>
                                    </td>
                                    <td>
                                        <select class="revenueIPD select2select" style="background-color: white;" disabled>
                                            ${setSelected(optionsVen, item.revenue)}
                                        </select>
                                    </td>
                                    <td>
                                        <a href="#" onclick="removeRow(this)">
                                            <i class="fa fa-trash fa-lg " style="color: black;"></i>
                                        </a>
                                        <a href="#" onclick="enableSelectsInRow(this)" style="margin-left:20px">
                                            <i class="fa fa-pencil fa-lg " style="color: black;"></i>
                                        </a>
                                    </td>
                                </tr>`;

                                    $('.financialDepartmentIPD option[value="011"]').prop('selected', true);

                                    $('#tableIPD tbody').append(row);
                                });

                                initSelect2();
                            });
                       // });
                    });
                }
            });
        }
        function OPDShareloadSavedRows() {
            $.ajax({
                type: "POST",
                url: "ClinicalFinancial.aspx/loadSavedRowsOPDShare",
                data: '{}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    const savedData = response.d;
                    console.log(savedData);
                    getClinicalFinancialAcoountsDropdown(function (options) {
                        getPatientTypes(function (categoryOptions) {
                            getAccounts(function (optionsVen) {

                                savedData.forEach(item => {
                                    let row = `
                                        <tr class="data-row">
                                            <td style="display: none">
                                        
                                                <input type="hidden" class="financialDepartmentOPDShare" value="${item.financialdepartment}"/>
                                            </td>
                                            <td>
                                                <select class="categorynameOPDShare select2select" style="background-color: white; height:32px;" disabled>
                                                    ${setSelected(categoryOptions, item.categoryname)}
                                                </select>
                                            </td>
                                                                  <td>
                                                                  <select class="cashinhandOPDShare select2select" style="background-color: white;" disabled>
                                                                      ${setSelected(optionsVen, item.cashinhand)}
                                                                  </select>
                                                              </td>
                                            <td>
                                                <select class="discountOPDShare select2select" style="background-color: white;" disabled>
                                                    ${setSelected(optionsVen, item.discount)}
                                                </select>
                                            </td>
                                            <td>
                                                <select class="revenueOPDShare select2select" style="background-color: white;" disabled>
                                                    ${setSelected(optionsVen, item.revenue)}
                                                </select>
                                            </td>
                                            <td>
                                                <a href="#" onclick="removeRow(this)">
                                                    <i class="fa fa-trash fa-lg " style="color: black;"></i>
                                                </a>
                                                <a href="#" onclick="enableSelectsInRow(this)" style="margin-left:20px">
                                                    <i class="fa fa-pencil fa-lg " style="color: black;"></i>
                                                </a>
                                            </td>
                                        </tr>`;

                                    $('.financialDepartmentOPDShare option[value="010"]').prop('selected', true);

                                    $('#tableOPDShare tbody').append(row);
                                });

                                initSelect2();
                            });
                        });
                    });
                }
            });
        }
        function RegloadSavedRows() {
            $.ajax({
                type: "POST",
                url: "ClinicalFinancial.aspx/loadSavedRowsReg",
                data: '{}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    const savedData = response.d;
                    console.log(savedData);
                    getClinicalFinancialAcoountsDropdown(function (options) {
                        getPatientTypes(function (categoryOptions) {
                            getAccounts(function (optionsVen) {

                                savedData.forEach(item => {
                                    let row = `
                                            <tr class="data-row">
                                                <td style="display: none">
                                            
                                                    <input type="hidden" class="financialDepartmentReg" value="${item.financialdepartment}"/>
                                                </td>
                                                <td>
                                                    <select class="categorynameReg select2select" style="background-color: white; height:32px;" disabled>
                                                        ${setSelected(categoryOptions, item.categoryname)}
                                                    </select>
                                                </td>
                                                                      <td>
                                                                      <select class="cashinhandReg select2select" style="background-color: white;" disabled>
                                                                          ${setSelected(optionsVen, item.cashinhand)}
                                                                      </select>
                                                                  </td>
                                                <td>
                                                    <select class="discountReg select2select" style="background-color: white;" disabled>
                                                        ${setSelected(optionsVen, item.discount)}
                                                    </select>
                                                </td>
                                                <td>
                                                    <select class="revenueReg select2select" style="background-color: white;" disabled>
                                                        ${setSelected(optionsVen, item.revenue)}
                                                    </select>
                                                </td>
                                                <td>
                                                    <a href="#" onclick="removeRow(this)">
                                                        <i class="fa fa-trash fa-lg " style="color: black;"></i>
                                                    </a>
                                                    <a href="#" onclick="enableSelectsInRow(this)" style="margin-left:20px">
                                                        <i class="fa fa-pencil fa-lg " style="color: black;"></i>
                                                    </a>
                                                </td>
                                            </tr>`;

                                    $('.financialDepartmentReg option[value="009"]').prop('selected', true);

                                    $('#tableReg tbody').append(row);
                                });

                                initSelect2();
                            });
                        });
                    });
                }
            });
        }
        function DiagnosticloadSavedRows() {
            $.ajax({
                type: "POST",
                url: "ClinicalFinancial.aspx/loadSavedRowsDiagnostic",
                data: '{}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    const savedData = response.d;
                    console.log(savedData);
                    getClinicalFinancialAcoountsDropdown(function (options) {
                        getMainTestDepartments(function (categoryOptions) {
                            getAccounts(function (optionsVen) {
                                var costCenterOptions = '';
                                getCostCenters(function (c) { costCenterOptions = c; });

                                savedData.forEach(item => {
                                    let row = `
                                        <tr class="data-row">
                                            <td style="display: none">
                                                <input type="hidden" class="financialDepartmentDiagnostic" value="${item.financialdepartment}"/>
                                            </td>
                                            <td>
                                                <select class="categorynameDiagnostic select2select" style="background-color: white; height:32px;" disabled>
                                                    ${setSelected(categoryOptions, item.categoryname)}
                                                </select>
                                            </td>
                                            <td>
                                                <select class="costcenterDiagnostic select2select" style="background-color: white;" disabled>
                                                    ${setSelected(costCenterOptions, item.costcenter)}
                                                </select>
                                            </td>
                                            <td>
                                                <select class="cashinhandDiagnostic select2select" style="background-color: white;" disabled>
                                                    ${setSelected(optionsVen, item.cashinhand)}
                                                </select>
                                            </td>
                                            <td>
                                                <select class="discountDiagnostic select2select" style="background-color: white;" disabled>
                                                    ${setSelected(optionsVen, item.discount)}
                                                </select>
                                            </td>
                                            <td>
                                                <select class="revenueDiagnostic select2select" style="background-color: white;" disabled>
                                                    ${setSelected(optionsVen, item.revenue)}
                                                </select>
                                            </td>
                                            <td>
                                                <select class="expenseDiagnostic select2select" style="background-color: white;" disabled>
                                                    ${setSelected(optionsVen, item.expense)}
                                                </select>
                                            </td>
                                            <td>
                                                <a href="#" onclick="removeRow(this)">
                                                    <i class="fa fa-trash fa-lg " style="color: black;"></i>
                                                </a>
                                                <a href="#" onclick="enableSelectsInRow(this)" style="margin-left:20px">
                                                    <i class="fa fa-pencil fa-lg " style="color: black;"></i>
                                                </a>
                                            </td>
                                        </tr>`;

                                    $('.financialDepartmentDiagnostic option[value="002"]').prop('selected', true);

                                    $('#tableDiagnostic tbody').append(row);
                                });

                                initSelect2();
                            });
                        });
                    });
                }
            });
        }

        function DiagnosticShareloadSavedRows() {
            $.ajax({
                type: "POST",
                url: "ClinicalFinancial.aspx/loadSavedRowsDiagnosticShare",
                data: '{}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    const savedData = response.d;
                    console.log(savedData);
                    getClinicalFinancialAcoountsDropdown(function (options) {
                        getMainTestDepartments(function (categoryOptions) {
                            getAccounts(function (optionsVen) {

                                savedData.forEach(item => {
                                    let row = `
                                <tr class="data-row">
                                    <td style="display: none">
                                        <input type="hidden" class="financialDepartmentDiagnosticShare" value="${item.financialdepartment}"/>
                                    </td>
                                    <td>
                                        <select class="categorynameDiagnosticShare select2select" style="background-color: white; height:32px;" disabled>
                                            ${setSelected(categoryOptions, item.categoryname)}
                                        </select>
                                    </td>
                                    <td>
                                        <select class="cashinhandDiagnosticShare select2select" style="background-color: white;" disabled>
                                            ${setSelected(optionsVen, item.cashinhand)}
                                        </select>
                                    </td>
                                    <td>
                                        <select class="discountDiagnosticShare select2select" style="background-color: white;" disabled>
                                            ${setSelected(optionsVen, item.discount)}
                                        </select>
                                    </td>
                                    <td>
                                        <select class="revenueDiagnosticShare select2select" style="background-color: white;" disabled>
                                            ${setSelected(optionsVen, item.revenue)}
                                        </select>
                                    </td>
                                    <td>
                                        <a href="#" onclick="removeRow(this)">
                                            <i class="fa fa-trash fa-lg " style="color: black;"></i>
                                        </a>
                                        <a href="#" onclick="enableSelectsInRow(this)" style="margin-left:20px">
                                            <i class="fa fa-pencil fa-lg " style="color: black;"></i>
                                        </a>
                                    </td>
                                </tr>`;

                                    $('.financialDepartmentDiagnosticShare option[value="008"]').prop('selected', true);

                                    $('#tableDiagnosticShare tbody').append(row);
                                });

                                initSelect2();
                            });
                        });
                    });
                }
            });
        }
        function SpecialServicesloadSavedRows() {
            $.ajax({
                type: "POST",
                url: "ClinicalFinancial.aspx/loadSavedRowsSpecialService",
                data: '{}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    const savedData = response.d;
                    console.log(savedData);
                    getClinicalFinancialAcoountsDropdown(function (options) {
                        getMainTestDepartments(function (categoryOptions) {
                            getAccounts(function (optionsVen) {
                                var costCenterOptions = '';
                                getCostCenters(function (c) { costCenterOptions = c; });

                                savedData.forEach(item => {
                                    let row = `
                                        <tr class="data-row">
                                            <td style="display: none">
                                                <input type="hidden" class="financialDepartmentSpecialServices" value="${item.financialdepartment}"/>
                                            </td>
                                            <td>
                                                <select class="categorynameSpecialServices select2select" style="background-color: white; height:32px;" disabled>
                                                    ${setSelected(categoryOptions, item.categoryname)}
                                                </select>
                                            </td>
                                            <td>
                                                <select class="costcenterSpecialServices select2select" style="background-color: white;" disabled>
                                                    ${setSelected(costCenterOptions, item.costcenter)}
                                                </select>
                                            </td>
                                            <td>
                                                <select class="cashinhandSpecialServices select2select" style="background-color: white;" disabled>
                                                    ${setSelected(optionsVen, item.cashinhand)}
                                                </select>
                                            </td>
                                            <td>
                                                <select class="discountSpecialServices select2select" style="background-color: white;" disabled>
                                                    ${setSelected(optionsVen, item.discount)}
                                                </select>
                                            </td>
                                            <td>
                                                <select class="revenueSpecialServices select2select" style="background-color: white;" disabled>
                                                    ${setSelected(optionsVen, item.revenue)}
                                                </select>
                                            </td>
                                            <td>
                                                <a href="#" onclick="removeRow(this)">
                                                    <i class="fa fa-trash fa-lg " style="color: black;"></i>
                                                </a>
                                                <a href="#" onclick="enableSelectsInRow(this)" style="margin-left:20px">
                                                    <i class="fa fa-pencil fa-lg " style="color: black;"></i>
                                                </a>
                                            </td>
                                        </tr>`;

                                    $('.financialDepartmentSpecialServices option[value="006"]').prop('selected', true);

                                    $('#tableSpecialServices tbody').append(row);
                                });

                                initSelect2();
                            });
                        });
                    });
                }
            });
        }
        function EMERGENCYloadSavedRows() {
            $.ajax({
                type: "POST",
                url: "ClinicalFinancial.aspx/loadSavedRowsEMERGENCY",
                data: '{}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    const savedData = response.d;
                    console.log(savedData);
                    getClinicalFinancialAcoountsDropdown(function (options) {
                        getPatientTypes(function (categoryOptions) {
                            getAccounts(function (optionsVen) {

                                savedData.forEach(item => {
                                    let row = `
                                    <tr class="data-row">
                                        <td style="display: none">
                                    
                                           <input type="hidden" class="financialDepartmentEMERGENCY" value="${item.financialdepartment}"/>
                                        </td>
                                        <td>
                                            <select class="categorynameEMERGENCY select2select" style="background-color: white; height:32px;" disabled>
                                                ${setSelected(categoryOptions, item.categoryname)}
                                            </select>
                                        </td>
                                        <td>
                                            <select class="cashinhandEMERGENCY select2select" style="background-color: white;" disabled>
                                                ${setSelected(optionsVen, item.cashinhand)}
                                            </select>
                                        </td>
                                        <td>
                                            <select class="discountEMERGENCY select2select" style="background-color: white;" disabled>
                                                ${setSelected(optionsVen, item.discount)}
                                            </select>
                                        </td>
                                        <td>
                                            <select class="revenueEMERGENCY select2select" style="background-color: white;" disabled>
                                                ${setSelected(optionsVen, item.revenue)}
                                            </select>
                                        </td>
                                        <td>
                                            <a href="#" onclick="removeRow(this)">
                                                <i class="fa fa-trash fa-lg " style="color: black;"></i>
                                            </a>
                                            <a href="#" onclick="enableSelectsInRow(this)" style="margin-left:20px">
                                                <i class="fa fa-pencil fa-lg " style="color: black;"></i>
                                            </a>
                                        </td>
                                    </tr>`;

                                    $('.financialDepartmentEMERGENCY option[value="003"]').prop('selected', true);

                                    $('#tableEMERGENCY tbody').append(row);
                                });

                                initSelect2();
                            });
                        });
                    });
                }
            });
        }
        function ProcedureloadSavedRows() {
            $.ajax({
                type: "POST",
                url: "ClinicalFinancial.aspx/loadSavedRowsProcedure",
                data: '{}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    const savedData = response.d;
                    console.log(savedData);
                    getClinicalFinancialAcoountsDropdown(function (options) {
                        getAccounts(function (optionsVen) {

                            savedData.forEach(item => {
                                let row = `
                                    <tr class="data-row">
                                        <td style="display: none">                                    
                                            <input type="hidden" class="financialDepartmentProcedure" value="${item.financialdepartment}"/>
                                        </td>
                                        <td>
                                            <select class="categorynameProcedure" style="background-color: white; height:32px;" disabled>
                                                <option value="0">Please Select</option>
                                                <option value="001" selected>Procedure</option>
                                            </select>
                                        </td>
                                        <td>
                                            <select class="cashinhandProcedure select2select" style="background-color: white;" disabled>
                                                ${setSelected(optionsVen, item.cashinhand)}
                                            </select>
                                        </td>
                                        <td>
                                            <select class="discountProcedure select2select" style="background-color: white;" disabled>
                                                ${setSelected(optionsVen, item.discount)}
                                            </select>
                                        </td>
                                        <td>
                                            <select class="revenueProcedure select2select" style="background-color: white;" disabled>
                                                ${setSelected(optionsVen, item.revenue)}
                                            </select>
                                        </td>
                                        <td>
                                            <a href="#" onclick="removeRow(this)">
                                                <i class="fa fa-trash fa-lg " style="color: black;"></i>
                                            </a>
                                            <a href="#" onclick="enableSelectsInRow(this)" style="margin-left:20px">
                                                <i class="fa fa-pencil fa-lg " style="color: black;"></i>
                                            </a>
                                        </td>
                                    </tr>`;

                                $('.financialDepartmentProcedure option[value="007"]').prop('selected', true);

                                $('#tableProcedure tbody').append(row);
                            });

                            initSelect2();
                        });
                    });
                }
            });
        }
        function SERVICEloadSavedRows() {
            $.ajax({
                type: "POST",
                url: "ClinicalFinancial.aspx/loadSavedRowsSERVICE",
                data: '{}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    const savedData = response.d;
                    console.log(savedData);
                    getClinicalFinancialAcoountsDropdown(function (options) {
                        getAccounts(function (optionsVen) {
                            var costCenterOptions = '';
                            getCostCenters(function (c) { costCenterOptions = c; });

                            savedData.forEach(item => {
                                let row = `
<tr class="data-row">
    <td style="display: none">

        <input type="hidden" class="financialDepartmentSERVICE" value="${item.financialdepartment}"/>
    </td>
    <td>
        <select class="categorynameSERVICE" style="background-color: white; height:32px;" disabled>
            <option value="0">Please Select</option>
            <option value="001" selected>Service</option>
        </select>
    </td>
    <td>
        <select class="costcenterSERVICE select2select" style="background-color: white;" disabled>
            ${setSelected(costCenterOptions, item.costcenter)}
        </select>
    </td>
    <td>
        <select class="cashinhandSERVICE select2select" style="background-color: white;" disabled>
            ${setSelected(optionsVen, item.cashinhand)}
        </select>
    </td>
    <td>
        <select class="discountSERVICE select2select" style="background-color: white;" disabled>
            ${setSelected(optionsVen, item.discount)}
        </select>
    </td>
    <td>
        <select class="revenueSERVICE select2select" style="background-color: white;" disabled>
            ${setSelected(optionsVen, item.revenue)}
        </select>
    </td>
    <td>
        <select class="expenseSERVICE select2select" style="background-color: white;" disabled>
            ${setSelected(optionsVen, item.expense)}
        </select>
    </td>
    <td>
        <a href="#" onclick="removeRow(this)">
            <i class="fa fa-trash fa-lg " style="color: black;"></i>
        </a>
        <a href="#" onclick="enableSelectsInRow(this)" style="margin-left:20px">
            <i class="fa fa-pencil fa-lg " style="color: black;"></i>
        </a>
    </td>
</tr>`;

                                $('.financialDepartmentSERVICE option[value="004"]').prop('selected', true);

                                $('#tableSERVICE tbody').append(row);
                            });

                            initSelect2();
                        });
                    });
                }
            });
        }
        function PHARMACYloadSavedRows() {
            $.ajax({
                type: "POST",
                url: "ClinicalFinancial.aspx/loadSavedRowsPHARMACY",
                data: '{}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    const savedData = response.d;
                    console.log(savedData);
                    getClinicalFinancialAcoountsDropdown(function (options) {
                        getAccounts(function (optionsVen) {
                            var costCenterOptions = '';
                            getCostCenters(function (c) { costCenterOptions = c; });

                            savedData.forEach(item => {
                                let row = `
                        <tr class="data-row">
                            <td style="display: none">
                                <input type="hidden" class="financialDepartmentPHARMACY" value="${item.financialdepartment}"/>
                            </td>
                            <td>
                                <select class="categorynamePHARMACY" style="background-color: white; height:32px;" disabled>
                                    <option value="0">Please Select</option>
                                    <option value="001" ${item.categoryname === "001" ? "selected" : ""}>Medicene</option>
                                </select>
                            </td>
                            <td>
                                <select class="costcenterPHARMACY select2select" style="background-color: white;" disabled>
                                    ${setSelected(costCenterOptions, item.costcenter)}
                                </select>
                            </td>
                            <td>
                                <select class="cashinhandPHARMACY select2select" style="background-color: white;" disabled>
                                    ${setSelected(optionsVen, item.cashinhand)}
                                </select>
                            </td>
                            <td>
                                <select class="discountPHARMACY select2select" style="background-color: white;" disabled>
                                    ${setSelected(optionsVen, item.discount)}
                                </select>
                            </td>
                            <td>
                                <select class="revenuePHARMACY select2select" style="background-color: white;" disabled>
                                    ${setSelected(optionsVen, item.revenue)}
                                </select>
                            </td>
                            <td>
                                <select class="cgsPHARMACY select2select" style="background-color: white;" disabled>
                                    ${setSelected(optionsVen, item.cgs)}
                                </select>
                            </td>
                            <td>
                                <select class="balanceaccountPHARMACY select2select" style="background-color: white;" disabled>
                                    ${setSelected(optionsVen, item.balanceaccount)}
                                </select>
                            </td>
                            <td>
                                <select class="itemaccountPHARMACY select2select" style="background-color: white;" disabled>
                                    ${setSelected(optionsVen, item.itemaccount)}
                                </select>
                            </td>
                            <td>
                                <a href="#" onclick="removeRow(this)">
                                    <i class="fa fa-trash fa-lg" style="color: black;"></i>
                                </a>
                                <a href="#" onclick="enableSelectsInRow(this)" style="margin-left:20px">
                                    <i class="fa fa-pencil fa-lg" style="color: black;"></i>
                                </a>
                            </td>
                        </tr>`;

                                $('.financialDepartmentPHARMACY option[value="005"]').prop('selected', true);
                                $('#tablePHARMACY tbody').append(row);
                            });
                            initSelect2();
                        });
                    });
                }
            });
        }


        //helper functions
        function removeRow(anchor) {
            let row = anchor.closest('tr');
            row.remove();
        }
        function enableSelectsInRow(anchor) {
            let row = anchor.closest('tr');
            let selects = row.querySelectorAll('select');
            selects.forEach(select => select.disabled = false);
        }
        var parsedOptionsCache = {};

        function setSelected(optionsHtml, selectedValue) {
            // account dropdown: only the placeholder and the saved account (the full list loads on open)
            if (optionsHtml === LAZY_ACCOUNT_OPTIONS) {
                var v = selectedValue === null || selectedValue === undefined ? '' : String(selectedValue);
                if (v === '' || v === '0' || v === 'null') { return LAZY_ACCOUNT_OPTIONS; }
                var label = String((dropdownCache.accountText && dropdownCache.accountText[v]) || v)
                    .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
                return LAZY_ACCOUNT_OPTIONS + '<option value="' + v + '" selected>' + label + '</option>';
            }
            let select = parsedOptionsCache[optionsHtml];
            if (!select) {
                let doc = new DOMParser().parseFromString('<select>' + optionsHtml + '</select>', 'text/html');
                select = doc.querySelector('select');
                parsedOptionsCache[optionsHtml] = select;
            }

            select.querySelectorAll('option').forEach(option => {
                if (option.value === selectedValue) {
                    option.setAttribute('selected', 'selected');
                } else {
                    option.removeAttribute('selected');
                }
            });
            return Array.from(select.options).map(opt => opt.outerHTML).join('');
        }

        //add new rows
        function addNewRowOPD() {
            getClinicalFinancialAcoountsDropdown(function (options) {
                getPatientTypes(function (categoryOptions) {
                    getAccounts(function (optionsVen) {
                        var costCenterOptions = '';
                        getCostCenters(function (c) { costCenterOptions = c; });
                        let newRow = `
                                  <tr class="data-row">
                                      <td style="display: none">
                                           <input type = "hidden" class="financialDepartmentOPD" value = "001">                   
                                      <td>
                                          <select class="categorynameOPD select2select" style="background-color: white; height:32px;">
                                              ${categoryOptions}
                                          </select>
                                      </td>
                                      <td>
                                          <select class="costcenterOPD select2select" style="background-color: white;">
                                              ${costCenterOptions}
                                          </select>
                                      </td>
                                      <td>
                                          <select class="cashinhandOPD select2select" style="background-color: white;">
                                              ${optionsVen}
                                          </select>
                                      </td>
                                      <td>
                                          <select class="discountOPD select2select" style="background-color: white;">
                                              ${optionsVen}
                                          </select>
                                      </td>
                                      <td>
                                          <select class="revenueOPD select2select" style="background-color: white;">
                                              ${optionsVen}
                                          </select>
                                      </td>
                                      <td>
                                          <a href="#" onclick="removeRow(this)">
                                              <i class="fa fa-trash fa-lg " style="color: black;"></i>
                                          </a>

                                      </td>
                                  </tr>
                              `;
                        $('#tableOPD tbody').append(newRow);
                        $('.financialDepartmentOPD option[value="001"]').prop('selected', true);
                        initSelect2();
                    });
                });
            });
        }
        function addNewRowIPD() {
            getClinicalFinancialAcoountsDropdown(function (options) {
          
                    getAccounts(function (optionsVen) {
                        let newRow = `
                                <tr class="data-row">
                                    <td style="display: none">
                                         <input type = "hidden" class="financialDepartmentIPD" value = "011">                   
                                    <td>
                                        <select class="categorynameIPD" disabled style="background-color: white; height:32px;">
                                            <option value="0">Please Select</option>
                                            <option value="03" selected >IPD</option>
                                        </select>
                                    </td>
                                    <td>
                                        <select class="cashinhandIPD select2select" style="background-color: white;">
                                            ${optionsVen}
                                        </select>
                                    </td>
                                    <td>
                                        <select class="discountIPD select2select" style="background-color: white;">
                                            ${optionsVen}
                                        </select>
                                    </td>
                                    <td>
                                        <select class="revenueIPD select2select" style="background-color: white;">
                                            ${optionsVen}
                                        </select>
                                    </td>
                                    <td>
                                        <a href="#" onclick="removeRow(this)">
                                            <i class="fa fa-trash fa-lg " style="color: black;"></i>
                                        </a>

                                    </td>
                                </tr>
                            `;
                        $('#tableIPD tbody').append(newRow);
                        $('.financialDepartmentIPD option[value="011"]').prop('selected', true);
                        initSelect2();
                    });

            });
        }
        function addNewRowOPDShare() {
            getClinicalFinancialAcoountsDropdown(function (options) {
                getPatientTypes(function (categoryOptions) {
                    getAccounts(function (optionsVen) {
                        let newRow = `
                <tr class="data-row">
                    <td style="display: none">
                         <input type = "hidden" class="financialDepartmentOPDShare" value = "010">                   
                    <td>
                        <select class="categorynameOPDShare select2select" style="background-color: white; height:32px;">
                            ${categoryOptions}
                        </select>
                    </td>
                    <td>
                        <select class="cashinhandOPDShare select2select" style="background-color: white;">
                            ${optionsVen}
                        </select>
                    </td>
                    <td>
                        <select class="discountOPDShare select2select" style="background-color: white;">
                            ${optionsVen}
                        </select>
                    </td>
                    <td>
                        <select class="revenueOPDShare select2select" style="background-color: white;">
                            ${optionsVen}
                        </select>
                    </td>
                    <td>
                        <a href="#" onclick="removeRow(this)">
                            <i class="fa fa-trash fa-lg " style="color: black;"></i>
                        </a>

                    </td>
                </tr>
            `;
                        $('#tableOPDShare tbody').append(newRow);
                        $('.financialDepartmentOPDShare option[value="010"]').prop('selected', true);
                        initSelect2();
                    });
                });
            });
        }
        function addNewRowReg() {
            getClinicalFinancialAcoountsDropdown(function (options) {
                getAccounts(function (optionsVen) {
                        let newRow = `
                <tr class="data-row">
                    <td style="display: none">
                         <input type = "hidden" class="financialDepartmentReg" value = "009">                   
                   
                     <td>
                         <select class="categorynameReg" disabled style="background-color: white; height:32px;">
                             <option value="0">Please Select</option>
                             <option value="001" selected >Patient Reg</option>
                         </select>
                     </td>
                     <td>
    <select class="cashinhandReg select2select" style="background-color: white;">
        ${optionsVen}
    </select>
</td>
                    <td>
                        <select class="discountReg select2select" style="background-color: white;">
                            ${optionsVen}
                        </select>
                    </td>
                    <td>
                        <select class="revenueReg select2select" style="background-color: white;">
                            ${optionsVen}
                        </select>
                    </td>
                    <td>
                        <a href="#" onclick="removeRow(this)">
    <i class="fa fa-trash fa-lg " style="color: black;"></i>
</a>

                    </td>
                </tr>
            `;
                        $('#tableReg tbody').append(newRow);
                        $('.financialDepartmentReg option[value="009"]').prop('selected', true);
                        initSelect2();
                    });
            });
        }
        function addNewRowDiagnosticShare() {
            getClinicalFinancialAcoountsDropdown(function (options) {
                getMainTestDepartments(function (categoryOptions) {
                    getAccounts(function (optionsVen) {
                        let newRow = `
                <tr class="data-row">
                    <td style="display: none">
                         <input type = "hidden" class="financialDepartmentDiagnosticShare" value = "008">                   
                    <td>
                        <select class="categorynameDiagnosticShare select2select" style="background-color: white; height:32px;">
                            ${categoryOptions}
                        </select>
                    </td>
                    <td>
                        <select class="cashinhandDiagnosticShare select2select" style="background-color: white;">
                            ${optionsVen}
                        </select>
                    </td>
                    <td>
                        <select class="discountDiagnosticShare select2select" style="background-color: white;">
                            ${optionsVen}
                        </select>
                    </td>
                    <td>
                        <select class="revenueDiagnosticShare select2select" style="background-color: white;">
                            ${optionsVen}
                        </select>
                    </td>
                    <td>
                        <a href="#" onclick="removeRow(this)">
                        <i class="fa fa-trash fa-lg " style="color: black;"></i>
                    </a>

                    </td>
                </tr>
            `;
                        $('#tableDiagnosticShare tbody').append(newRow);
                        $('.financialDepartmentDiagnosticShare option[value="008"]').prop('selected', true);
                        initSelect2();
                  

                    });
                });
            });
        }
        function addNewRowDiagnostic() {
            getClinicalFinancialAcoountsDropdown(function (options) {
                getMainTestDepartments(function (categoryOptions) {
                    getAccounts(function (optionsVen) {
                        var costCenterOptions = '';
                        getCostCenters(function (c) { costCenterOptions = c; });
                        let newRow = `
                <tr class="data-row">
                    <td style="display: none">
                         <input type = "hidden" class="financialDepartmentDiagnostic" value = "002">                   
                    <td>
                        <select class="categorynameDiagnostic select2select" style="background-color: white; height:32px;">
                            ${categoryOptions}
                        </select>
                    </td>
                    <td>
                        <select class="costcenterDiagnostic select2select" style="background-color: white;">
                            ${costCenterOptions}
                        </select>
                    </td>
                    <td>
                        <select class="cashinhandDiagnostic select2select" style="background-color: white;">
                            ${optionsVen}
                        </select>
                    </td>
                    <td>
                        <select class="discountDiagnostic select2select" style="background-color: white;">
                            ${optionsVen}
                        </select>
                    </td>
                    <td>
                        <select class="revenueDiagnostic select2select" style="background-color: white;">
                            ${optionsVen}
                        </select>
                    </td>
                    <td>
                        <select class="expenseDiagnostic select2select" style="background-color: white;">
                            ${optionsVen}
                        </select>
                    </td>
                    <td>
                        <a href="#" onclick="removeRow(this)">
                        <i class="fa fa-trash fa-lg " style="color: black;"></i>
                    </a>

                    </td>
                </tr>
            `;
                        $('#tableDiagnostic tbody').append(newRow);
                        $('.financialDepartmentDiagnostic option[value="002"]').prop('selected', true);
                        initSelect2();
                  

                    });
                });
            });
        }
        function addNewRowSpecialServices() {
            getClinicalFinancialAcoountsDropdown(function (options) {
                getSpecialServices(function (categoryOptions) {
                    getAccounts(function (optionsVen) {
                        var costCenterOptions = '';
                        getCostCenters(function (c) { costCenterOptions = c; });
                        let newRow = `
                <tr class="data-row">
                    <td style="display: none">
                         <input type = "hidden" class="financialDepartmentSpecialServices" value = "006">
                    <td>
                        <select class="categorynameSpecialServices select2select" style="background-color: white; height:32px;">
                            ${categoryOptions}
                        </select>
                    </td>
                    <td>
                        <select class="costcenterSpecialServices select2select" style="background-color: white;">
                            ${costCenterOptions}
                        </select>
                    </td>
                    <td>
                        <select class="cashinhandSpecialServices select2select" style="background-color: white;">
                            ${optionsVen}
                        </select>
                    </td>
                    <td>
                        <select class="discountSpecialServices select2select" style="background-color: white;">
                            ${optionsVen}
                        </select>
                    </td>
                    <td>
                        <select class="revenueSpecialServices select2select" style="background-color: white;">
                            ${optionsVen}
                        </select>
                    </td>
                    <td>
                        <a href="#" onclick="removeRow(this)">
                            <i class="fa fa-trash fa-lg " style="color: black;"></i>
                        </a>

                    </td>
                </tr>
            `;
                        $('#tableSpecialServices tbody').append(newRow);
                        $('.financialDepartmentSpecialServices option[value="006"]').prop('selected', true);
                        initSelect2();


                    });
                });
            });
        }
        function addNewRowEMERGENCY() {
            getClinicalFinancialAcoountsDropdown(function (options) {
                getPatientTypes(function (categoryOptions) {
                    getAccounts(function (optionsVen) {
                        let newRow = `
                <tr class="data-row">
                    <td style="display: none">                
                        <input type = "hidden" class="financialDepartmentEMERGENCY" value = "003">                  
                    <td>
                        <select class="categorynameEMERGENCY select2select" style="background-color: white; height:32px;">
                            ${categoryOptions}
                        </select>
                    </td>
                    <td>
                        <select class="cashinhandEMERGENCY select2select" style="background-color: white;">
                            ${optionsVen}
                        </select>
                    </td>
                    <td>
                        <select class="discountEMERGENCY select2select" style="background-color: white;">
                            ${optionsVen}
                        </select>
                    </td>
                    <td>
                        <select class="revenueEMERGENCY select2select" style="background-color: white;">
                            ${optionsVen}
                        </select>
                    </td>
                    <td>
                        <a href="#" onclick="removeRow(this)">
                        <i class="fa fa-trash fa-lg " style="color: black;"></i>
                    </a>

                    </td>
                </tr>
            `;
                        $('#tableEMERGENCY tbody').append(newRow);
                        $('.financialDepartmentEMERGENCY option[value="003"]').prop('selected', true);
                        initSelect2();
                    });
                });
            });
        }
        function addNewRowSERVICE() {
            getClinicalFinancialAcoountsDropdown(function (options) {
                getAccounts(function (optionsVen) {
                    var costCenterOptions = '';
                    getCostCenters(function (c) { costCenterOptions = c; });
                    let newRow = `
                <tr class="data-row">
                    <td style="display: none">
                     <input type = "hidden" class="financialDepartmentSERVICE" value = "004">     
                    <td>
                        <select class="categorynameSERVICE" disabled style="background-color: white; height:32px;">
                            <option value="0">Please Select</option>
                            <option value="001" selected >Service</option>
                        </select>
                    </td>
                    <td>
                        <select class="costcenterSERVICE select2select" style="background-color: white;">
                            ${costCenterOptions}
                        </select>
                    </td>
                    <td>
                        <select class="cashinhandSERVICE select2select" style="background-color: white;">
                            ${optionsVen}
                        </select>
                    </td>
                    <td>
                        <select class="discountSERVICE select2select" style="background-color: white;">
                            ${optionsVen}
                        </select>
                    </td>
                    <td>
                        <select class="revenueSERVICE select2select" style="background-color: white;">
                            ${optionsVen}
                        </select>
                    </td>
                    <td>
                        <select class="expenseSERVICE select2select" style="background-color: white;">
                            ${optionsVen}
                        </select>
                    </td>
                    <td>
                        <a href="#" onclick="removeRow(this)">
                        <i class="fa fa-trash fa-lg " style="color: black;"></i>
                    </a>

                    </td>
                </tr>
            `;
                    $('#tableSERVICE tbody').append(newRow);
                    $('.financialDepartmentSERVICE option[value="004"]').prop('selected', true);
                    initSelect2();
                });
            });
        }
        function addNewRowProcedure() {
            getClinicalFinancialAcoountsDropdown(function (options) {
                getAccounts(function (optionsVen) {
                    let newRow = `
                <tr class="data-row">
                    <td style="display: none">
                     <input type = "hidden" class="financialDepartmentProcedure" value = "007">
                    <td>
                        <select class="categorynameProcedure" disabled style="background-color: white; height:32px;">
                            <option value="0">Please Select</option>
                            <option value="001" selected >Procedure</option>
                        </select>
                    </td>
                    <td>
                        <select class="cashinhandProcedure select2select" style="background-color: white;">
                            ${optionsVen}
                        </select>
                    </td>
                    <td>
                        <select class="discountProcedure select2select" style="background-color: white;">
                            ${optionsVen}
                        </select>
                    </td>
                    <td>
                        <select class="revenueProcedure select2select" style="background-color: white;">
                            ${optionsVen}
                        </select>
                    </td>
                    <td>
                        <a href="#" onclick="removeRow(this)">
                        <i class="fa fa-trash fa-lg " style="color: black;"></i>
                        </a>
                    </td>
                </tr>
            `;
                    $('#tableProcedure tbody').append(newRow);
                    $('.financialDepartmentProcedure option[value="007"]').prop('selected', true);
                    initSelect2(); 
                });
            });
        }
        function addNewRowPHARMACY() {
            getClinicalFinancialAcoountsDropdown(function (options) {
                getAccounts(function (optionsVen) {
                    var costCenterOptions = '';
                    getCostCenters(function (c) { costCenterOptions = c; });
                    let newRow = `
            <tr class="data-row">
                <td style="display: none">
                    <input type="hidden" class="financialDepartmentPHARMACY" value="005">
                </td>
                <td>
                    <select disabled class="categorynamePHARMACY" style="background-color: white; height:32px;">
                        <option value="0">Please Select</option>
                        <option value="001" selected>Medicene</option>
                    </select>
                </td>
                <td>
                    <select class="costcenterPHARMACY select2select" style="background-color: white;">
                        ${costCenterOptions}
                    </select>
                </td>
                <td>
                    <select class="cashinhandPHARMACY select2select" style="background-color: white;">
                        ${optionsVen}
                    </select>
                </td>
                <td>
                    <select class="discountPHARMACY select2select" style="background-color: white;">
                        ${optionsVen}
                    </select>
                </td>
                <td>
                    <select class="revenuePHARMACY select2select" style="background-color: white;">
                        ${optionsVen}
                    </select>
                </td>
                <td>
                    <select class="cgsPHARMACY select2select" style="background-color: white;">
                        ${optionsVen}
                    </select>
                </td>
                <td>
                    <select class="balanceaccountPHARMACY select2select" style="background-color: white;">
                        ${optionsVen}
                    </select>
                </td>
                <td>
                    <select class="itemaccountPHARMACY select2select" style="background-color: white;">
                        ${optionsVen}
                    </select>
                </td>
                <td>
                    <a href="#" onclick="removeRow(this)">
                        <i class="fa fa-trash fa-lg" style="color: black;"></i>
                    </a>
                </td>
            </tr>`;
                    $('#tablePHARMACY tbody').append(newRow);
                    $('.financialDepartmentPHARMACY option[value="005"]').prop('selected', true);
                    initSelect2();
                });
            });
        }



        //dropdowns
        function getPatientTypes(callback) {
            if (dropdownCache.patientTypes) { callback(dropdownCache.patientTypes); return; }
            loadCommonDropdowns(function () {
                callback(dropdownCache.patientTypes || '<option value="0">Please Select</option>');
            });
        }
        function getMainTestDepartments(callback) {
            if (dropdownCache.mainTestDepts) { callback(dropdownCache.mainTestDepts); return; }
            loadCommonDropdowns(function () {
                callback(dropdownCache.mainTestDepts || '<option value="0">Please Select</option>');
            });
        }
        function getSpecialServices(callback) {
            if (dropdownCache.specialServices) { callback(dropdownCache.specialServices); return; }
            loadCommonDropdowns(function () {
                callback(dropdownCache.specialServices || '<option value="0">Please Select</option>');
            });
        }
        function getAccounts(callback) {
            if (dropdownCache.accounts) { callback(LAZY_ACCOUNT_OPTIONS); return; }
            loadCommonDropdowns(function () {
                callback(LAZY_ACCOUNT_OPTIONS);
            });
        }
        function getCostCenters(callback) {
            if (dropdownCache.costCenters) { callback(dropdownCache.costCenters); return; }
            loadCommonDropdowns(function () {
                callback(dropdownCache.costCenters || '<option value="0">Please Select</option>');
            });
        }
        function getClinicalFinancialAcoountsDropdown(callback) {
            if (dropdownCache.clinicalDept) {
                $('#OPD_ClinicalFinancialDepartment').html(dropdownCache.clinicalDept);
                if (callback) callback(dropdownCache.clinicalDept);
                return dropdownCache.clinicalDept;
            }
            loadCommonDropdowns(function () {
                $('#OPD_ClinicalFinancialDepartment').html(dropdownCache.clinicalDept || '');
                if (callback) callback(dropdownCache.clinicalDept || '<option value="0">Please Select</option>');
            });
            return '<option value="0">Please Select</option>';
        }

    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div id="tabs">

        <ul>
            <li><a href="#Tab-1">OPD</a></li>
            <li><a href="#Tab-10">OPD Sharing</a></li>
            <li><a href="#Tab-9">Patient Reg</a></li>
            <li><a href="#Tab-2">Diagnostic</a></li>
            <li><a href="#Tab-3">Emergency</a></li>
            <li><a href="#Tab-4">Service</a></li>
            <li><a href="#Tab-6">SpecialServices</a></li>           
            <li ><a href="#Tab-5">Pharmacy</a></li>
            <li><a href="#Tab-7">Procedure</a></li>
            <li><a href="#Tab-8">Diagnostic Share</a></li>
            <li><a href="#Tab-11">IPD</a></li>
            <li><a href="#Tab-12">Advance</a></li>
            <li><a href="#Tab-13">Refund</a></li>

        </ul>

        <div id="Tab-1">
            <div class="row">

                <div class="col-lg-11 col-md-11 col-sm-11"></div>
                <div class="col-lg-1 col-md-1 col-sm-1" style="text-align: right;">
                    <a href="#" id="btnaddrowOPD" onclick="addNewRowOPD()">
                        <i class="fa fa-plus-circle" style="font-size: 30px;"></i>
                    </a>
                </div>
            </div>
            <table id="tableOPD" class="table table-bordered table-hover table-striped" style="margin-top: 10px;">
                <thead id="theadOPD">
                    <tr>
                        <th style="display: none">Financial Department  </th>
                        <th style="width: 14%;">Category Name         </th>
                        <th style="width: 14%;">Cost Center           </th>
                        <th style="width: 22%;">Cash in Hand (C.I.H.) </th>
                        <th style="width: 25%;">Discount              </th>
                        <th style="width: 25%;">Revenue               </th>
                        <th style="width: 9%;">Action                </th>
                    </tr>
                </thead>
                <tbody id="tbodyOPD">
                </tbody>
            </table>
        </div>

        <div id="Tab-11">
            <div class="row">

                <div class="col-lg-11 col-md-11 col-sm-11"></div>
                <div class="col-lg-1 col-md-1 col-sm-1" style="text-align: right;">
                    <a href="#" id="btnaddrowIPD" onclick="addNewRowIPD()">
                        <i class="fa fa-plus-circle" style="font-size: 30px;"></i>
                    </a>
                </div>
            </div>
            <table id="tableIPD" class="table table-bordered table-hover table-striped" style="margin-top: 10px;">
                <thead id="theadIPD">
                    <tr>
                        <th style="display: none">Financial Department  </th>
                        <th style="width: 16%;">Category Name         </th>
                        <th style="width: 25%;">Cash in Hand (C.I.H.) </th>
                        <th style="width: 25%;">Discount              </th>
                        <th style="width: 25%;">Revenue               </th>
                        <th style="width: 9%;">Action                </th>
                    </tr>
                </thead>
                <tbody id="tbodyIPD">
                </tbody>
            </table>
        </div>
 <div id="Tab-12">
    <div class="row">
        <div class="col-lg-11 col-md-11 col-sm-11"></div>
        <div class="col-lg-1 col-md-1 col-sm-1" style="text-align: right;">
            <a href="#" id="btnaddrowAdvance" onclick="addNewRowAdvance()">
                <i class="fa fa-plus-circle" style="font-size: 30px;"></i>
            </a>
        </div>
    </div>
    <table id="tableAdvance" class="table table-bordered table-hover table-striped" style="margin-top: 10px;">
        <thead id="theadAdvance">
            <tr>
                <th style="display: none">Financial Department</th>
                <th style="width: 30%;">Category Name</th>
                <th style="width: 30%;">Dr (Debit) - Cash in Hand</th>
                <th style="width: 30%;">Cr (Credit) - Revenue</th>
                <th style="width: 10%;">Action</th>
            </tr>
        </thead>
        <tbody id="tbodyAdvance">
        </tbody>
    </table>
</div>
        <div id="Tab-13">
            <div class="row">
                <div class="col-lg-11 col-md-11 col-sm-11"></div>
                <div class="col-lg-1 col-md-1 col-sm-1" style="text-align: right;">
                    <a href="#" id="btnaddrowRefund" onclick="addNewRowRefund()">
                        <i class="fa fa-plus-circle" style="font-size: 30px;"></i>
                    </a>
                </div>
            </div>
            <table id="tableRefund" class="table table-bordered table-hover table-striped" style="margin-top: 10px;">
                <thead id="theadRefund">
                    <tr>
                        <th style="display: none">Financial Department</th>
                        <th style="width: 30%;">Category Name</th>
                        <th style="width: 30%;">Dr (Debit) - Cash in Hand</th>
                        <th style="width: 30%;">Cr (Credit) - Revenue</th>
                        <th style="width: 10%;">Action</th>
                    </tr>
                </thead>
                <tbody id="tbodyRefund">
                </tbody>
            </table>
        </div>
        <div id="Tab-10">
            <div class="row">

                <div class="col-lg-11 col-md-11 col-sm-11"></div>
                <div class="col-lg-1 col-md-1 col-sm-1" style="text-align: right;">
                    <a href="#" id="btnaddrowOPDShare" onclick="addNewRowOPDShare()">
                        <i class="fa fa-plus-circle" style="font-size: 30px;"></i>
                    </a>
                </div>
            </div>
            <table id="tableOPDShare" class="table table-bordered table-hover table-striped" style="margin-top: 10px;">
                <thead id="theadOPDShare">
                    <tr>
                        <th style="display: none">Financial Department  </th>
                        <th style="width: 16%;">Category Name         </th>
                        <th style="width: 25%;">Cash in Hand (C.I.H.) </th>
                        <th style="width: 25%;">Discount              </th>
                        <th style="width: 25%;">Revenue               </th>
                        <th style="width: 9%;">Action                </th>
                    </tr>
                </thead>
                <tbody id="tbodyOPDShare">
                </tbody>
            </table>
        </div>

        <div id="Tab-9">
            <div class="row">

                <div class="col-lg-11 col-md-11 col-sm-11"></div>
                <div class="col-lg-1 col-md-1 col-sm-1" style="text-align: right;">
                    <a href="#" id="btnaddrowReg" onclick="addNewRowReg()">
                        <i class="fa fa-plus-circle" style="font-size: 30px;"></i>
                    </a>
                </div>
            </div>
            <table id="tableReg" class="table table-bordered table-hover table-striped" style="margin-top: 10px;">
                <thead id="theadReg">
                    <tr>
                        <th style="display: none">Financial Department  </th>
                        <th style="width: 16%;">Category Name         </th>
                        <th style="width: 25%;">Cash in Hand (C.I.H.) </th>
                        <th style="width: 25%;">Discount              </th>
                        <th style="width: 25%;">Revenue               </th>
                        <th style="width: 9%;">Action                </th>
                    </tr>
                </thead>
                <tbody id="tbodyReg">
                </tbody>
            </table>
        </div>

        <div id="Tab-2">
            <div class="row">

                <div class="col-lg-11 col-md-11 col-sm-11"></div>
                <div class="col-lg-1 col-md-1 col-sm-1" style="text-align: right;">
                    <a href="#" id="btnaddrowDiagnostic" onclick="addNewRowDiagnostic()">
                        <i class="fa fa-plus-circle" style="font-size: 30px;"></i>
                    </a>
                </div>
            </div>
            <table id="tableDiagnostic" class="table table-bordered table-hover table-striped" style="margin-top: 10px;">
                <thead id="theadDiagnostic">
                    <tr>
                        <th style="display: none">Financial Department  </th>
                        <th style="width: 14%;">Category Name         </th>
                        <th style="width: 14%;">Cost Center           </th>
                        <th style="width: 22%;">Cash in Hand (C.I.H.) </th>
                        <th style="width: 25%;">Discount              </th>
                        <th style="width: 25%;">Revenue               </th>
                        <th style="width: 25%;">Expense               </th>
                        <th style="width: 9%;">Action                </th>
                    </tr>
                </thead>
                <tbody id="tbodyDiagnostic">
                </tbody>
            </table>
        </div>

        <div id="Tab-8">
            <div class="row">

                <div class="col-lg-11 col-md-11 col-sm-11"></div>
                <div class="col-lg-1 col-md-1 col-sm-1" style="text-align: right;">
                    <a href="#" id="btnaddrowDiagnosticShare" onclick="addNewRowDiagnosticShare()">
                        <i class="fa fa-plus-circle" style="font-size: 30px;"></i>
                    </a>
                </div>
            </div>
            <table id="tableDiagnosticShare" class="table table-bordered table-hover table-striped" style="margin-top: 10px;">
                <thead id="theadDiagnosticShare">
                    <tr>
                        <th style="display: none">Financial Department  </th>
                        <th style="width: 16%;">Category Name         </th>
                        <th style="width: 25%;">Cash in Hand (C.I.H.) </th>
                        <th style="width: 25%;">Discount              </th>
                        <th style="width: 25%;">Revenue               </th>
                        <th style="width: 9%;">Action                </th>
                    </tr>
                </thead>
                <tbody id="tbodyDiagnosticShare">
                </tbody>
            </table>
        </div>
               <div id="Tab-6">
           <div class="row">

               <div class="col-lg-11 col-md-11 col-sm-11"></div>
               <div class="col-lg-1 col-md-1 col-sm-1" style="text-align: right;">
                   <a href="#" id="addNewRowSpecialServices" onclick="addNewRowSpecialServices()">
                       <i class="fa fa-plus-circle" style="font-size: 30px;"></i>
                   </a>
               </div>
           </div>
           <table id="tableSpecialServices" class="table table-bordered table-hover table-striped" style="margin-top: 10px;">
               <thead id="theadSpecialServices">
                   <tr>
                       <th style="display: none">Financial Department  </th>
                       <th style="width: 14%;">Category Name         </th>
                       <th style="width: 14%;">Cost Center           </th>
                       <th style="width: 22%;">Cash in Hand (C.I.H.) </th>
                       <th style="width: 25%;">Discount              </th>
                       <th style="width: 25%;">Revenue               </th>
                       <th style="width: 9%;">Action                </th>
                   </tr>
               </thead>
               <tbody id="tbodySpecialServices">
               </tbody>
           </table>
       </div>
               <div id="Tab-7">
           <div class="row">

               <div class="col-lg-11 col-md-11 col-sm-11"></div>
               <div class="col-lg-1 col-md-1 col-sm-1" style="text-align: right;">
                   <a href="#" id="addNewRowProcedure" onclick="addNewRowProcedure()">
                       <i class="fa fa-plus-circle" style="font-size: 30px;"></i>
                   </a>
               </div>
           </div>
           <table id="tableProcedure" class="table table-bordered table-hover table-striped" style="margin-top: 10px;">
               <thead id="theadProcedure">
                   <tr>
                       <th style="display: none">Financial Department  </th>
                       <th style="width: 16%;">Category Name         </th>
                       <th style="width: 25%;">Cash in Hand (C.I.H.) </th>
                       <th style="width: 25%;">Discount              </th>
                       <th style="width: 25%;">Revenue               </th>
                       <th style="width: 9%;">Action                </th>
                   </tr>
               </thead>
               <tbody id="tbodyProcedure">
               </tbody>
           </table>
       </div>
        <div id="Tab-3">
            <div class="row">

                <div class="col-lg-11 col-md-11 col-sm-11"></div>
                <div class="col-lg-1 col-md-1 col-sm-1" style="text-align: right;">
                    <a href="#" id="btnaddrowEMERGENCY" onclick="addNewRowEMERGENCY()">
                        <i class="fa fa-plus-circle" style="font-size: 30px;"></i>
                    </a>
                </div>
            </div>
            <table id="tableEMERGENCY" class="table table-bordered table-hover table-striped" style="margin-top: 10px;">
                <thead id="theadEMERGENCY">
                    <tr>
                        <th style="display: none">Financial Department  </th>
                        <th style="width: 16%;">Category Name         </th>
                        <th style="width: 25%;">Cash in Hand (C.I.H.) </th>
                        <th style="width: 25%;">Discount              </th>
                        <th style="width: 25%;">Revenue               </th>
                        <th style="width: 9%;">Action                </th>
                    </tr>
                </thead>
                <tbody id="tbodyEMERGENCY">
                </tbody>
            </table>
        </div>

        <div id="Tab-4">
            <div class="row">

                <div class="col-lg-11 col-md-11 col-sm-11"></div>
                <div class="col-lg-1 col-md-1 col-sm-1" style="text-align: right;">
                    <a href="#" id="btnaddrowSERVICE" onclick="addNewRowSERVICE()">
                        <i class="fa fa-plus-circle" style="font-size: 30px;"></i>
                    </a>
                </div>
            </div>
            <table id="tableSERVICE" class="table table-bordered table-hover table-striped" style="margin-top: 10px;">
                <thead id="theadSERVICE">
                    <tr>
                        <th style="display: none">Financial Department  </th>
                        <th style="width: 14%;">Category Name         </th>
                        <th style="width: 14%;">Cost Center           </th>
                        <th style="width: 22%;">Cash in Hand (C.I.H.) </th>
                        <th style="width: 25%;">Discount              </th>
                        <th style="width: 25%;">Revenue               </th>
                        <th style="width: 25%;">Expense               </th>
                        <th style="width: 9%;">Action                </th>
                    </tr>
                </thead>
                <tbody id="tbodySERVICE">
                </tbody>
            </table>
        </div>

        <div id="Tab-5">
            <div class="row">
                <div class="col-lg-10 col-md-10 col-sm-10"></div>
                <div class="col-lg-2 col-md-2 col-sm-2" style="text-align: right;">
                    <a href="#" id="btnaddrowPHARMACY" onclick="addNewRowPHARMACY()">
                        <i class="fa fa-plus-circle" style="font-size: 30px;"></i>
                    </a>
                </div>
            </div>
            <table id="tablePHARMACY" class="table table-bordered table-hover table-striped" style="margin-top: 10px;">
                <thead id="theadPHARMACY">
                    <tr>
                        <th style="display: none">Financial Department</th>
                        <th style="width: 10%;">Category Name</th>
                        <th style="width: 10%;">Cost Center</th>
                        <th style="width: 14%;">Cash in Hand (C.I.H.)</th>
                        <th style="width: 13%;">Discount</th>
                        <th style="width: 13%;">Revenue</th>
                        <th style="width: 12%;">CGS</th>
                        <th style="width: 13%;">Balance Account</th>
                        <th style="width: 14%;">Item Account</th>
                        <th style="width: 1%;">Action</th>
                    </tr>
                </thead>
                <tbody id="tbodyPHARMACY">
                </tbody>
            </table>
        </div>






    </div>
    <input type="button" class="btn btn-primry" style="margin-top: 20px; width: 100px !important" onclick="submitData()" value="Save" />




</asp:Content>
