<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ClinicalFinancial.aspx.cs" Inherits="PMS.Modules.Accounts.ClinicalFinancial" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/ClinicalFinancial.css" rel="stylesheet" />

    <script type="text/javascript">

        $(document).ready(function () {
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

        //tabs 
        $(function () {
            $("#tabs").tabs();
        });

        //SAVE DATA
     function submitData() {
    debugger;
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
        rowsPHARMACY.length === 0 && rowsAdvance.length === 0) {
        isEmptyFound = true;
    }

    // Get all data from existing tables (keep your existing code for other tabs)
    rowsIPD.each(function () {
        let row = $(this);
        let rowDataIPD = {
            financialdepartment: row.find('.financialDepartmentIPD').val(),
            categoryname: row.find('.categorynameIPD').val(),
            cashinhand: row.find('.cashinhandIPD').val(),
            discount: row.find('.discountIPD').val(),
            revenue: row.find('.revenueIPD').val()
        };
        if (rowDataIPD.categoryname == 0 || rowDataIPD.cashinhand == 0 || rowDataIPD.revenue == 0) {
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
        let rowDataOPD = {
            financialdepartment: row.find('.financialDepartmentOPD').val(),
            categoryname: row.find('.categorynameOPD').val(),
            cashinhand: row.find('.cashinhandOPD').val(),
            discount: row.find('.discountOPD').val(),
            revenue: row.find('.revenueOPD').val()
        };
        if (rowDataOPD.categoryname == 0 || rowDataOPD.cashinhand == 0 || rowDataOPD.discount == 0 || rowDataOPD.revenue == 0) {
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
        let rowDataOPDShare = {
            financialdepartment: row.find('.financialDepartmentOPDShare').val(),
            categoryname: row.find('.categorynameOPDShare').val(),
            cashinhand: row.find('.cashinhandOPDShare').val(),
            discount: row.find('.discountOPDShare').val(),
            revenue: row.find('.revenueOPDShare').val()
        };
        if (rowDataOPDShare.categoryname == 0 || rowDataOPDShare.cashinhand == 0 || rowDataOPDShare.revenue == 0) {
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
        let rowDataReg = {
            financialdepartment: row.find('.financialDepartmentReg').val(),
            categoryname: row.find('.categorynameReg').val(),
            cashinhand: row.find('.cashinhandReg').val(),
            discount: row.find('.discountReg').val(),
            revenue: row.find('.revenueReg').val()
        };
        if (rowDataReg.cashinhand == 0 || rowDataReg.revenue == 0) {
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
        let rowDataDiagnostic = {
            financialdepartment: row.find('.financialDepartmentDiagnostic').val(),
            categoryname: row.find('.categorynameDiagnostic').val(),
            cashinhand: row.find('.cashinhandDiagnostic').val(),
            discount: row.find('.discountDiagnostic').val(),
            revenue: row.find('.revenueDiagnostic').val()
        };
        if (rowDataDiagnostic.categoryname == 0 || rowDataDiagnostic.cashinhand == 0 || rowDataDiagnostic.discount == 0 || rowDataDiagnostic.revenue == 0) {
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
        let rowDataDiagnosticShare = {
            financialdepartment: row.find('.financialDepartmentDiagnosticShare').val(),
            categoryname: row.find('.categorynameDiagnosticShare').val(),
            cashinhand: row.find('.cashinhandDiagnosticShare').val(),
            discount: row.find('.discountDiagnosticShare').val(),
            revenue: row.find('.revenueDiagnosticShare').val()
        };
        if (rowDataDiagnosticShare.categoryname == 0 || rowDataDiagnosticShare.cashinhand == 0) {
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
        let rowDataSpecialService = {
            financialdepartment: row.find('.financialDepartmentSpecialServices').val(),
            categoryname: row.find('.categorynameSpecialServices').val(),
            cashinhand: row.find('.cashinhandSpecialServices').val(),
            discount: row.find('.discountSpecialServices').val(),
            revenue: row.find('.revenueSpecialServices').val()
        };
        if (rowDataSpecialService.categoryname == 0 || rowDataSpecialService.cashinhand == 0 || rowDataSpecialService.discount == 0 || rowDataSpecialService.revenue == 0) {
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
        let rowDataProcedure = {
            financialdepartment: row.find('.financialDepartmentProcedure').val(),
            categoryname: row.find('.categorynameProcedure').val(),
            cashinhand: row.find('.cashinhandProcedure').val(),
            discount: row.find('.discountProcedure').val(),
            revenue: row.find('.revenueProcedure').val()
        };
        if (rowDataProcedure.categoryname == 0 || rowDataProcedure.cashinhand == 0 || rowDataProcedure.discount == 0 || rowDataProcedure.revenue == 0) {
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
        let rowDataEMERGENCY = {
            financialdepartment: row.find('.financialDepartmentEMERGENCY').val(),
            categoryname: row.find('.categorynameEMERGENCY').val(),
            cashinhand: row.find('.cashinhandEMERGENCY').val(),
            discount: row.find('.discountEMERGENCY').val(),
            revenue: row.find('.revenueEMERGENCY').val()
        };
        if (rowDataEMERGENCY.categoryname == 0 || rowDataEMERGENCY.cashinhand == 0 || rowDataEMERGENCY.discount == 0 || rowDataEMERGENCY.revenue == 0) {
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
        let rowDataSERVICE = {
            financialdepartment: row.find('.financialDepartmentSERVICE').val(),
            categoryname: row.find('.categorynameSERVICE').val(),
            cashinhand: row.find('.cashinhandSERVICE').val(),
            discount: row.find('.discountSERVICE').val(),
            revenue: row.find('.revenueSERVICE').val()
        };
        if (rowDataSERVICE.categoryname == 0 || rowDataSERVICE.cashinhand == 0 || rowDataSERVICE.discount == 0 || rowDataSERVICE.revenue == 0) {
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
        let rowDataPHARMACY = {
            financialdepartment: row.find('.financialDepartmentPHARMACY').val(),
            categoryname: row.find('.categorynamePHARMACY').val(),
            cashinhand: row.find('.cashinhandPHARMACY').val(),
            discount: row.find('.discountPHARMACY').val(),
            revenue: row.find('.revenuePHARMACY').val()
        };
        if (rowDataPHARMACY.categoryname == 0 || rowDataPHARMACY.cashinhand == 0 || rowDataPHARMACY.discount == 0 || rowDataPHARMACY.revenue == 0) {
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
        
        if ((!hasDr && !hasCr)) {
            Swal.fire({
                icon: 'error',
                title: 'Error!',
                text: 'In Advance tab, please select either Dr OR Cr.',
                showConfirmButton: false,
                timer: 2000
            });
            isEmptyFound = true;
            return false;
        }
        
        
        
        allData.push(rowDataAdvance);
    });

         rowsRefund.each(function () {
             let row = $(this);
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

             if ((!hasDr && !hasCr)) {
                 Swal.fire({
                     icon: 'error',
                     title: 'Error!',
                     text: 'In Refund tab, please select either Dr OR Cr.',
                     showConfirmButton: false,
                     timer: 2000
                 });
                 isEmptyFound = true;
                 return false;
             }

             
             if (categoryNamesRefund.has(rowDataRefund.categoryname)) {
                 duplicateFound = true;
             } else {
                 categoryNamesRefund.add(rowDataRefund.categoryname);
             }

             allData.push(rowDataRefund);
         });
    
    // Check for empty fields
    //if (isEmptyFound) {
      //  Swal.fire({
         //   icon: 'error',
          //  title: 'Error!',
           // text: 'Please fill all required fields in each row before submitting.',
           // showConfirmButton: false,
           // timer: 2000,
           // customClass: {
             //   popup: 'swal-big-popup',
                //title: 'swal-big-title',
               // htmlContainer: 'swal-big-text'
          //  }
       // });
        //return;
    //}
    
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
                console.error("Error:", error);
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'An error occurred while saving data.',
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

                                $('.select2select').select2(); 
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
                    $('.select2select').select2();
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
            $('.select2select').select2();
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
                    $('.select2select').select2();
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
                            $('.select2select').select2();
                        });
                    });
                },
                error: function (xhr, status, error) {
                    console.error("Error loading refund rows:", error);
                }
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
                            $('.select2select').select2();
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

        //                        $('.select2select').select2(); // reinit after DOM update
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

                                $('.select2select').select2(); // reinit after DOM update
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

                                $('.select2select').select2(); // reinit after DOM update
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

                                $('.select2select').select2(); // reinit after DOM update
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

                                $('.select2select').select2(); // reinit after DOM update
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

                                $('.select2select').select2(); // reinit after DOM update
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

                                $('.select2select').select2(); // reinit after DOM update
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

                                $('.select2select').select2(); // reinit after DOM update
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

                            $('.select2select').select2(); // reinit after DOM update
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

                            $('.select2select').select2(); // reinit after DOM update
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

                            savedData.forEach(item => {
                                let row = `
<tr class="data-row">
    <td style="display: none">

                <input type="hidden" class="financialDepartmentPHARMACY" value="${item.financialdepartment}"/>
    </td>
    <td>
        <select class="categorynamePHARMACY" style="background-color: white; height:32px;" disabled>
            <option value="0">Please Select</option>
            <option value="001" selected>Medicene</option>
        </select>
    </td>
    <td>
        <select class="cashinhandPHARMACY select2select" style="background-color: white;" >
            ${setSelected(optionsVen, item.cashinhand)}
        </select>
    </td>
    <td>
        <select class="discountPHARMACY select2select" style="background-color: white;" >
            ${setSelected(optionsVen, item.discount)}
        </select>
    </td>
    <td>
        <select class="revenuePHARMACY select2select" style="background-color: white;">
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

                                $('.financialDepartmentPHARMACY option[value="005"]').prop('selected', true);

                                $('#tablePHARMACY tbody').append(row);
                            });

                            $('.select2select').select2(); // reinit after DOM update
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
        function setSelected(optionsHtml, selectedValue) {
            let parser = new DOMParser();
            let doc = parser.parseFromString('<select>' + optionsHtml + '</select>', 'text/html');
            let select = doc.querySelector('select');

            select.querySelectorAll('option').forEach(option => {
                if (option.value === selectedValue) {
                    option.setAttribute('selected', 'selected');
                } else {
                    option.removeAttribute('selected');
                }
            }); return Array.from(select.options).map(opt => opt.outerHTML).join('');
        }

        //add new rows
        function addNewRowOPD() {
            getClinicalFinancialAcoountsDropdown(function (options) {
                getPatientTypes(function (categoryOptions) {
                    getAccounts(function (optionsVen) {
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
                        $('.select2select').select2(); // initialize Select2
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
                        $('.select2select').select2(); // initialize Select2
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
                        $('.select2select').select2(); // initialize Select2
                    });
                });
            });
        }
        function addNewRowReg() {
            getClinicalFinancialAcoountsDropdown(function (options) {
                debugger;
                getAccounts(function (optionsVen) {
                    debugger;
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
                        $('.select2select').select2(); // initialize Select2
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
                        $('.select2select').select2(); // initialize Select2
                  

                    });
                });
            });
        }
        function addNewRowDiagnostic() {
            getClinicalFinancialAcoountsDropdown(function (options) {
                getMainTestDepartments(function (categoryOptions) {
                    getAccounts(function (optionsVen) {
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
                        <a href="#" onclick="removeRow(this)">
                        <i class="fa fa-trash fa-lg " style="color: black;"></i>
                    </a>

                    </td>
                </tr>
            `;
                        $('#tableDiagnostic tbody').append(newRow);
                        $('.financialDepartmentDiagnostic option[value="002"]').prop('selected', true);
                        $('.select2select').select2(); // initialize Select2
                  

                    });
                });
            });
        }
        function addNewRowSpecialServices() {
            getClinicalFinancialAcoountsDropdown(function (options) {
                getSpecialServices(function (categoryOptions) {
                    getAccounts(function (optionsVen) {
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
                        $('.select2select').select2(); // initialize Select2


                    });
                });
            });
        }
        function addNewRowEMERGENCY() {
            debugger;
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
                        $('.select2select').select2(); // initialize Select2
                    });
                });
            });
        }
        function addNewRowSERVICE() {
            getClinicalFinancialAcoountsDropdown(function (options) {
                getAccounts(function (optionsVen) {
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
                        <a href="#" onclick="removeRow(this)">
                        <i class="fa fa-trash fa-lg " style="color: black;"></i>
                    </a>

                    </td>
                </tr>
            `;
                    $('#tableSERVICE tbody').append(newRow);
                    $('.financialDepartmentSERVICE option[value="004"]').prop('selected', true);
                    $('.select2select').select2(); // initialize Select2
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
                    $('.select2select').select2(); 
                });
            });
        }
        function addNewRowPHARMACY() {
            getClinicalFinancialAcoountsDropdown(function (options) {
                getAccounts(function (optionsVen) {
                    let newRow = `
                <tr class="data-row">
                    <td style="display: none">
    
<input type = "hidden" class="financialDepartmentPHARMACY" value = "005">
                    
                    <td>
                        <select disabled class="categorynamePHARMACY" style="background-color: white; height:32px;">
                            <option value="0">Please Select</option>
                            <option value="001" selected>Medicene</option>
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
                        <a href="#" onclick="removeRow(this)">
                        <i class="fa fa-trash fa-lg " style="color: black;"></i>
                    </a>

                    </td>
                </tr>
            `;
                    $('#tablePHARMACY tbody').append(newRow);
                    $('.financialDepartmentPHARMACY option[value="005"]').prop('selected', true);
                    $('.select2select').select2(); // initialize Select2
                });
            });
        }



        //dropdowns
        function getPatientTypes(callback) {
            $.ajax({
                url: 'ClinicalFinancial.aspx/PatientType',
                type: 'POST',
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                success: function (response) {
                    let options = '<option value="0">Please Select</option>';
                    let data = response.d ? JSON.parse(response.d) : response;
                    $.each(data, function (key, value) {
                        options += `<option value="${value.DataValue_Name}">${value.DataValue_Description}</option>`;
                    });
                    callback(options);
                },
                error: function (xhr, status, error) {
                    console.error('Error fetching patient types:', error);
                    callback('<option value="0">Error</option>');
                }
            });
        }
        function getMainTestDepartments(callback) {
            $.ajax({
                url: 'ClinicalFinancial.aspx/MainTestDepartments',
                type: 'POST',
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                success: function (response) {
                    let options = '<option value="0">Please Select</option>';
                    let data = response.d ? JSON.parse(response.d) : response;
                    $.each(data, function (key, value) {
                        options += `<option value="${value.DataValue_Name}">${value.DataValue_Description}</option>`;
                    });
                    callback(options);
                },
                error: function (xhr, status, error) {
                    console.error('Error fetching patient types:', error);
                    callback('<option value="0">Error</option>');
                }
            });
        }
        function getSpecialServices(callback) {
            $.ajax({
                url: 'ClinicalFinancial.aspx/SpecialServices',
                type: 'POST',
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                success: function (response) {
                    let options = '<option value="0">Please Select</option>';
                    let data = response.d ? JSON.parse(response.d) : response;
                    $.each(data, function (key, value) {
                        options += `<option value="${value.DataValue_Name}">${value.DataValue_Description}</option>`;
                    });
                    callback(options);
                },
                error: function (xhr, status, error) {
                    console.error('Error fetching patient types:', error);
                    callback('<option value="0">Error</option>');
                }
            });
        }
        function getAccounts(callback) {
            $.ajax({
                url: 'ClinicalFinancial.aspx/filldropdowns',
                type: 'POST',
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                success: function (response) {
                    let options = '<option value="0">Please Select</option>';
                    let data = JSON.parse(response.d);
                    $.each(data, function (key, value) {
                        options += `<option value="${value.Account_ID}">${value.Account_Code} - ${value.Account_Name}</option>`;
                    });
                    callback(options);
                },
                error: function (xhr, status, error) {
                    console.error('Error fetching accounts:', error);
                    callback('<option value="0">Error</option>');
                }
            });
        }
        function getClinicalFinancialAcoountsDropdown(callback) {
            var options = '<option value="0">Please Select</option>';

            $.ajax({
                url: 'ClinicalFinancial.aspx/ClinicalFinancialDepartmentDropdown',
                type: 'POST',
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                success: function (response) {
                    var data = response.d ? JSON.parse(response.d) : response;
                    $.each(data, function (key, value) {
                        options += '<option value="' + value.DataValue_Name + '">' + value.DataValue_Description + '</option>';
                    });
                    callback(options);

                    $('#OPD_ClinicalFinancialDepartment').html(options);


                },
                error: function (xhr, status, error) {
                    console.error('Error fetching area data:', error);
                }
            });

            return options;
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
            <li style="display:none;"><a href="#Tab-3">Emergency</a></li>
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
                        <th style="width: 16%;">Category Name         </th>
                        <th style="width: 25%;">Cash in Hand (C.I.H.) </th>
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
                        <th style="width: 16%;">Category Name         </th>
                        <th style="width: 25%;">Cash in Hand (C.I.H.) </th>
                        <th style="width: 25%;">Discount              </th>
                        <th style="width: 25%;">Revenue               </th>
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
                       <th style="width: 16%;">Category Name         </th>
                       <th style="width: 25%;">Cash in Hand (C.I.H.) </th>
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
                        <th style="width: 16%;">Category Name         </th>
                        <th style="width: 25%;">Cash in Hand (C.I.H.) </th>
                        <th style="width: 25%;">Discount              </th>
                        <th style="width: 25%;">Revenue               </th>
                        <th style="width: 9%;">Action                </th>
                    </tr>
                </thead>
                <tbody id="tbodySERVICE">
                </tbody>
            </table>
        </div>

        <div id="Tab-5" >
            <div class="row">

                <div class="col-lg-11 col-md-11 col-sm-11"></div>
                <div class="col-lg-1 col-md-1 col-sm-1" style="text-align: right;">
                    <a href="#" id="btnaddrowPHARMACY" onclick="addNewRowPHARMACY()">
                        <i class="fa fa-plus-circle" style="font-size: 30px;"></i>
                    </a>
                </div>
            </div>
            <table id="tablePHARMACY" class="table table-bordered table-hover table-striped" style="margin-top: 10px;">
                <thead id="theadPHARMACY">
                    <tr>
                        <th style="display: none">Financial Department  </th>
                        <th style="width: 16%;">Category Name         </th>
                        <th style="width: 25%;">Cash in Hand (C.I.H.) </th>
                        <th style="width: 25%;">Discount              </th>
                        <th style="width: 25%;">Revenue               </th>
                        <th style="width: 9%;">Action                </th>
                    </tr>
                </thead>
                <tbody id="tbodyPHARMACY">
                </tbody>
            </table>
        </div>






    </div>
    <input type="button" class="btn btn-primry" style="margin-top: 20px; width: 100px !important" onclick="submitData()" value="Save" />




</asp:Content>
