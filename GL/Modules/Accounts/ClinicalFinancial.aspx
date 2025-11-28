<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ClinicalFinancial.aspx.cs" Inherits="PMS.Modules.Accounts.ClinicalFinancial" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/Tibbit_theme/css/CustomCss/ClinicalFinancial.css" rel="stylesheet" />

    <script type="text/javascript">

        $(document).ready(function () {
            OPDloadSavedRows();
            DiagnosticloadSavedRows();
            EMERGENCYloadSavedRows();
            SERVICEloadSavedRows();
            PHARMACYloadSavedRows();
        });

        //tabs 
        $(function () {
            $("#tabs").tabs();
        });

        //SAVE DATA
        function submitData() {

            let isEmptyFound = false;
            let allData = [];
            let categoryNamesOPD = new Set();
            let categoryNamesDiagnostic = new Set();
            let categoryNamesEMERGENCY = new Set();
            let categoryNamesSERVICE = new Set();
            let categoryNamesPHARMACY = new Set();
            let duplicateFound = false;
            let rowsOPD = $('#tableOPD .data-row');
            let rowsDiagnostic = $('#tableDiagnostic .data-row');
            let rowsEMERGENCY = $('#tableEMERGENCY .data-row');
            let rowsSERVICE = $('#tableSERVICE .data-row');
            let rowsPHARMACY = $('#tablePHARMACY .data-row');

            // Check if any rows exist
            if (rowsOPD.length === 0 && rowsDiagnostic.length === 0 && rowsEMERGENCY.length === 0 && rowsSERVICE.length === 0 && rowsPHARMACY.length === 0) {
                isEmptyFound = true;
            }

            //getAllData
            rowsOPD.each(function () {
                let row = $(this);
                let rowDataOPD = {

                    financialdepartment: row.find('.financialDepartmentOPD').val(),
                    categoryname: row.find('.categorynameOPD').val(),
                    cashinhand: null,
                    discount: row.find('.discountOPD').val(),
                    revenue: row.find('.revenueOPD').val()
                };
                // Check if any value is empty
                if (rowDataOPD.categoryname == 0 || rowDataOPD.discount == 0 || rowDataOPD.revenue == 0) {
                    isEmptyFound = true;
                }
                // Check for duplicate categoryname
                if (categoryNamesOPD.has(rowDataOPD.categoryname)) {
                    duplicateFound = true;
                } else {
                    categoryNamesOPD.add(rowDataOPD.categoryname);
                }
                allData.push(rowDataOPD);
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
                // Check if any value is empty
                if (rowDataDiagnostic.categoryname == 0 || rowDataDiagnostic.cashinhand == 0 || rowDataDiagnostic.discount == 0 || rowDataDiagnostic.revenue == 0) {
                    isEmptyFound = true;
                }
                // Check for duplicate categoryname
                if (categoryNamesDiagnostic.has(rowDataDiagnostic.categoryname)) {
                    duplicateFound = true;
                } else {
                    categoryNamesDiagnostic.add(rowDataDiagnostic.categoryname);
                }
                allData.push(rowDataDiagnostic);
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
                // Check if any value is empty
                if (rowDataEMERGENCY.categoryname == 0 || rowDataEMERGENCY.cashinhand == 0 || rowDataEMERGENCY.discount == 0 || rowDataEMERGENCY.revenue == 0) {
                    isEmptyFound = true;
                }
                // Check for duplicate categoryname
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
                // Check if any value is empty
                if (rowDataSERVICE.categoryname == 0 || rowDataSERVICE.cashinhand == 0 || rowDataSERVICE.discount == 0 || rowDataSERVICE.revenue == 0) {
                    isEmptyFound = true;
                }
                // Check for duplicate categoryname
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
                // Check if any value is empty
                if (rowDataPHARMACY.categoryname == 0 || rowDataPHARMACY.cashinhand == 0 || rowDataPHARMACY.discount == 0 || rowDataPHARMACY.revenue == 0) {
                    isEmptyFound = true;
                }
                // Check for duplicate categoryname
                if (categoryNamesPHARMACY.has(rowDataPHARMACY.categoryname)) {
                    duplicateFound = true;
                } else {
                    categoryNamesPHARMACY.add(rowDataPHARMACY.categoryname);
                }
                allData.push(rowDataPHARMACY);
            });

            //swals
            if (isEmptyFound) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please fill all fields in each row before submitting.',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

            }
            if (duplicateFound) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Categories must be different.',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

            }

            //ajax
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
        <select class="financialDepartmentSERVICE" disabled>
            ${setSelected(options, item.financialdepartment)}
        </select>
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
        <select class="financialDepartmentPHARMACY" disabled>
            ${setSelected(options, item.financialdepartment)}
        </select>
    </td>
    <td>
        <select class="categorynamePHARMACY" style="background-color: white; height:32px;" disabled>
            <option value="0">Please Select</option>
            <option value="001" selected>Medicene</option>
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
        function addNewRowProcedure() {
            getClinicalFinancialAcoountsDropdown(function (options) {
                getSpecialServices(function (categoryOptions) {
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
        function addNewRowPHARMACY() {
            getClinicalFinancialAcoountsDropdown(function (options) {
                getAccounts(function (optionsVen) {
                    let newRow = `
                <tr class="data-row">
                    <td style="display: none">
                        <select class="financialDepartmentPHARMACY">
                            ${options}
                        </select>
                    
                    <td>
                        <select disabled class="categorynamePHARMACY" style="background-color: white; height:32px;">
                            <option value="0">Please Select</option>
                            <option value="001" selected>Medicene</option>
                        </select>
                    </td>
                    <td>
                        <input type = "hidden" class="cashinhandPHARMACY" value = "005">
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
            <li><a href="#Tab-2">Diagnostic</a></li>
            <li><a href="#Tab-3">Emergency</a></li>
            <li><a href="#Tab-4">Service</a></li>
            <li style="display:none;"><a href="#Tab-5">Pharmacy</a></li>

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
                        <th style="width: 25%;">Discount              </th>
                        <th style="width: 25%;">Revenue               </th>
                        <th style="width: 9%;">Action                </th>
                    </tr>
                </thead>
                <tbody id="tbodyOPD">
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
