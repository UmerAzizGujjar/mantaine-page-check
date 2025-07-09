<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ClinicalFinancial.aspx.cs" Inherits="PMS.Modules.Accounts.ClinicalFinancial" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
   
    <script type="text/javascript">
        $(document).ready(function () {
            getClinicalFinancialAcoountsDropdown();

            
           
        });
        $(function () {
            $("#tabs").tabs();

        });
        function submitData() {
            let isEmptyFound = false;
            let allData = [];
            let categoryNames = new Set();
            let duplicateFound = false;
            let rows = $('#tableOPD .data-row');

            // Check if any rows exist
            if (rows.length === 0) {
                isEmptyFound = true;
            }

            rows.each(function () {
                let row = $(this);
                let rowData = {
                    
                    financialdepartment: row.find('.financialDepartment').val(),
                    categoryname: row.find('.categoryname').val(),
                    cashinhand: row.find('.cashinhand').val(),
                    discount: row.find('.discount').val(),
                    revenue: row.find('.revenue').val()
                };
                // Check if any value is empty
                if (rowData.categoryname == 0 || rowData.cashinhand == 0 || rowData.discount == 0 || rowData.revenue == 0)
                {
                    isEmptyFound = true;
                }
                // Check for duplicate categoryname
                if (categoryNames.has(rowData.categoryname)) {
                    duplicateFound = true;
                } else {
                    categoryNames.add(rowData.categoryname);
                }
                allData.push(rowData);
            });

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

            console.log(allData);
            console.log(duplicateFound);
            console.log(isEmptyFound);


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
                    });                },
                error: function (xhr, status, error) {
                    console.error("Error:", error);
                }
            });
            }
        }
        function removeRow(anchor) {
            let row = anchor.closest('tr');
            row.remove();
        }
        function addNewRow() {
            getClinicalFinancialAcoountsDropdown(function (options) {
                getPatientTypes(function (categoryOptions) {
                    getAccounts(function (optionsVen) {
                        let newRow = `
                <tr class="data-row">
                    <td style="display: none">
                        <select class="financialDepartment">
                            ${options}
                        </select>
                    
                    <td>
                        <select class="categoryname select2select" style="background-color: white; height:32px;">
                            ${categoryOptions}
                        </select>
                    </td>
                    <td>
                        <select class="cashinhand select2select" style="background-color: white;">
                            ${optionsVen}
                        </select>
                    </td>
                    <td>
                        <select class="discount select2select" style="background-color: white;">
                            ${optionsVen}
                        </select>
                    </td>
                    <td>
                        <select class="revenue select2select" style="background-color: white;">
                            ${optionsVen}
                        </select>
                    </td>
                    <td>
                        <a href="#" onclick="removeRow(this)">
                            <i class="fa fa-trash fa-2x" style="color: red;"></i>
                        </a>
                    </td>
                </tr>
            `;
                        $('#tableOPD tbody').append(newRow);
                        $('.financialDepartment option[value="001"]').prop('selected', true);
                        $('.select2select').select2(); // initialize Select2
                    });
                });
            });
        }
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
    <style type="text/css">
        #tabs ul li a {
            background-color: #EFA63E   !important;
            color: white;
            background: none;
            border: none;
            padding: 10px;
        }
        #tabs ul li.ui-tabs-active a {
            border-bottom: 1px solid aliceblue !important;
            color: white !important;
        }
        .fa-plus-circle {
            color: #EFA63E  !important;
        }

        .table thead th {
            background-color: #f8f9fa;
        }

        .search-input {
            margin-bottom: 15px;
        }

        .table-striped tbody tr:nth-of-type(odd) {
            background-color: rgba(0, 0, 0, .05);
        }

    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
        <div id="tabs">

            <ul>
                <li><a href="#Tab-1">OPD</a></li>
                <li><a href="#Tab-2">Lab</a></li>
                <li><a href="#Tab-3">X_ray</a></li>
                <li><a href="#Tab-4">Ultra_Sound</a></li>
                <li><a href="#Tab-5">CT_Scan</a></li>
            </ul>

        <div id="Tab-1">
            <div class="row">
                <div class="col-lg-2 col-md-2 col-sm-2">
                    <select style="display:none" id="OPD_ClinicalFinancialDepartment">

                    </select>
                </div>
                <div class="col-lg-9 col-md-9 col-sm-9"></div>
                <div class="col-lg-1 col-md-1 col-sm-1" style="text-align: right;" >
                    <a href="#" id="btnaddrow" onclick="addNewRow()" >
                       <i class="fa fa-plus-circle" style="font-size: 24px;"></i>
                    </a>
                </div>
            </div>
            <table id="tableOPD" class="table table-bordered table-hover table-striped" style="margin-top: 10px;">
          <thead id="theadOPD">
            <tr>
              <th style=" display:none">Financial Department  </th>
              <th style="width: 20%;">Category Name         </th>
              <th style="width: 25%;">Cash in Hand (C.I.H.) </th>
              <th style="width: 25%;">Discount              </th>
              <th style="width: 25%;">Revenue               </th>
              <th style="width: 5% ;">Action                </th>
            </tr>
          </thead>
          <tbody id="tbodyOPD">
          </tbody>
        </table>
        </div>

        <div id="Tab-2">
            <div class="row">
                <div class="col-lg-3 col-md-3 col-sm-3">
                    <label>Department</label>
                    <select id="ddlmaindep" name="ddlmaindep">
                        <option value="0">Select Department</option>
                        <option value="001">Lab Test</option>
                    </select>
                </div>
                <div class="col-lg-3 col-md-3 col-sm-3">
                    <label id="lbllabtestagremnttype">Agrement Type</label>
                    <select id="ddl_labtest_AgrementType" name="ddl_labtest_AgrementType"></select>
                </div>
                <div class="col-lg-3 col-md-3 col-sm-3">
                    <label id="lbllabtestagremntdept">Agrement Department</label>
                    <select id="ddl_labtest_Agrementdept" name="ddl_labtest_Agrementdept"></select>
                </div>
                <div class="col-lg-2 col-md-2 col-sm-2">
                    <label>Doc_share</label>
                    <select id="discount_lab" onchange="ddldiscount_lab();">
                        <option value="0">No</option>
                        <option value="10">10%</option>
                        <option value="20">20%</option>
                        <option value="30">30%</option>
                        <option value="40">40%</option>
                        <option value="50">50%</option>
                        <option value="60">60%</option>
                        <option value="70">70%</option>
                        <option value="80">80%</option>
                        <option value="90">90%</option>
                        <option value="100">100%</option>
                    </select>
                </div>
                
                <div class="col-lg-1 col-md-1 col-sm-1" style="margin-top: 30px;">
    <a href="#" id="btnshowLabModal" >
       <i class="fa fa-plus-circle" style="font-size: 24px;"></i>

    </a>
</div>
            </div>
            <table style="overflow: scroll; height: auto; margin-top: 10px !important" class="table table-bordered table-hover table-striped" id="tblResult">
                <thead id="ihead">
                    <tr>
                        <th>Description</th>
                        <th>Agrement Type</th>
                        <th style="display: none">Agrement Type Id</th>
                        <th>Agrement Dept</th>
                        <th style="display: none">Agrement Dept Id</th>
                        <th>Actual Amount</th>
                        <th>Discount %</th>
                        <th>Net Amount</th>
                        <th>Doc_Share</th>
                        <th>Hos_Share</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody id="ibody">
                </tbody>
            </table>
        </div>

        <div id="Tab-3">
            <div class="row">
                <div class="col-lg-3 col-md-3 col-sm-3">
                    <label>Department</label>
                    <select id="ddlmaindep_xray" name="ddlmaindep_xray">
                        <option value="0">Select Department</option>
                        <option value="003">X-Ray</option>
                    </select>
                </div>
                <div class="col-lg-3 col-md-3 col-sm-6">
                    <label id="lblxrayagremnttype">Agrement Type</label>
                    <select id="ddl_xray_AgrementType" name="ddl_xray_AgrementType"></select>
                </div>
                <div class="col-lg-3 col-md-3 col-sm-6">
                    <label id="lblxrayagremntdept">Agrement Department</label>
                    <select id="ddl_xray_Agrementdept" name="ddl_xray_Agrementdept"></select>
                </div>
                <div class="col-lg-2 col-md-2 col-sm-2">
                    <label>Doc_share</label>
                    <select id="discount_xray" onchange="ddldiscount_xray();">
                        <option value="0">No</option>
                        <option value="10">10%</option>
                        <option value="20">20%</option>
                        <option value="30">30%</option>
                        <option value="40">40%</option>
                        <option value="50">50%</option>
                        <option value="60">60%</option>
                        <option value="70">70%</option>
                        <option value="80">80%</option>
                        <option value="90">90%</option>
                        <option value="100">100%</option>
                    </select>
                </div>
                
                <div class="col-lg-1 col-md-1 col-sm-1" style="margin-top: 30px;">
    <a href="#" id="btnshowxrayModal" >
       <i class="fa fa-plus-circle" style="font-size: 24px;"></i>

    </a>
</div>
            </div>
            <table style="overflow: scroll; height: auto; margin-top: 10px !important" class="table table-bordered table-hover table-striped" id="tblResults">
                <thead id="iheads">
                    <tr>
                        <th>Description</th>
                        <th>Agrement Type</th>
                        <th style="display: none">Agrement Type Id</th>
                        <th>Agrement Dept</th>
                        <th style="display: none">Agrement Dept Id</th>
                        <th>Actual Amount</th>
                        <th>Discount %</th>
                        <th>Net Amount</th>
                        <th>Doc_Share</th>
                        <th>Hos_Share</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody id="ibodys">
                </tbody>
            </table>
        </div>

        <div id="Tab-4">
            <div class="row">
                <div class="col-lg-3 col-md-3 col-sm-3">
                    <label>Department</label>
                    <select id="ddlmaindep_Ultra" name="ddlmaindep_Ultra">
                        <option value="0">Select Department</option>
                        <option value="002">Ultra_Sound</option>
                    </select>
                </div>
                <div class="col-lg-3 col-md-3 col-sm-6">
                    <label id="lblultrasoundsagremnttype">Agrement Type</label>
                    <select id="ddl_ultrasounds_AgrementType" name="ddl_ultrasounds_AgrementType"></select>
                </div>
                <div class="col-lg-3 col-md-3 col-sm-6">
                    <label id="lblultrasoundsagremntdept">Agrement Department</label>
                    <select id="ddl_ultrasounds_Agrementdept" name="ddl_ultrasounds_Agrementdept"></select>
                </div>
                <div class="col-lg-2 col-md-2 col-sm-2">
                    <label>Doc_share</label>
                    <select id="discount_ultra" onchange="ddldiscount_ultra();">
                        <option value="0">No</option>
                        <option value="10">10%</option>
                        <option value="20">20%</option>
                        <option value="30">30%</option>
                        <option value="40">40%</option>
                        <option value="50">50%</option>
                        <option value="60">60%</option>
                        <option value="70">70%</option>
                        <option value="80">80%</option>
                        <option value="90">90%</option>
                        <option value="100">100%</option>
                    </select>
                </div>
               
                <div class="col-lg-1 col-md-1 col-sm-1" style="margin-top: 30px;">
    <a href="#" id="btnshowultrsoundModal" >
       <i class="fa fa-plus-circle" style="font-size: 24px;"></i>

    </a>
</div>

            </div>
            <table style="overflow: scroll; height: auto; margin-top: 10px !important" class="table table-bordered table-hover table-striped" id="tblResult_ultra">
                <thead id="ihead_ultra">
                    <tr>
                        <th>Description</th>
                        <th>Agrement Type</th>
                        <th style="display: none">Agrement Type Id</th>
                        <th>Agrement Dept</th>
                        <th style="display: none">Agrement Dept Id</th>
                        <th>Actual Amount</th>
                        <th>Discount %</th>
                        <th>Net Amount</th>
                        <th>Doc_Share</th>
                        <th>Hos_Share</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody id="ibodys_ultra">
                </tbody>
            </table>
        </div>

        <div id="Tab-5">
            <div class="row">
                <div class="col-lg-3 col-md-3 col-sm-3">
                    <label>Department</label>
                    <select id="ddlmaindep_ctscan" name="ddlmaindep_ct_scan">
                        <option value="0">Select Department</option>
                        <option value="004">CTScan</option>
                    </select>
                </div>
                <div class="col-lg-3 col-md-3 col-sm-6">
                    <label id="lblCTScanagremnttype">Agrement Type</label>
                    <select id="ddl_CTScan_AgrementType" name="ddl_CTScan_AgrementType"></select>
                </div>
                <div class="col-lg-3 col-md-3 col-sm-6">
                    <label id="lblCTScanagremntdept">Agrement Department</label>
                    <select id="ddl_CTScan_Agrementdept" name="ddl_CTScan_Agrementdept"></select>
                </div>
                <div class="col-lg-2 col-md-2 col-sm-2">
                    <label>Doc_share</label>
                    <select id="discount" onchange="ddldiscount();">
                        <option value="0">No</option>
                        <option value="10">10%</option>
                        <option value="20">20%</option>
                        <option value="30">30%</option>
                        <option value="40">40%</option>
                        <option value="50">50%</option>
                        <option value="60">60%</option>
                        <option value="70">70%</option>
                        <option value="80">80%</option>
                        <option value="90">90%</option>
                        <option value="100">100%</option>
                    </select>
                </div>
                
                <div class="col-lg-1 col-md-1 col-sm-1" style="margin-top: 30px;">
    <a href="#" id="btnshowCTScanModal" >
       <i class="fa fa-plus-circle" style="font-size: 24px;"></i>

    </a>
</div>

            </div>
            <table class="table table-bordered table-hover table-striped" style="overflow: scroll; height: auto; margin-top: 10px !important" id="tblResult_ctscan">
                <thead id="ihead_ctscan">
                    <tr>
                        <th>Description</th>
                        <th>Agrement Type</th>
                        <th style="display: none">Agrement Type Id</th>
                        <th>Agrement Dept</th>
                        <th style="display: none">Agrement Dept Id</th>
                        <th>Actual Amount</th>
                        <th>Discount %</th>
                        <th>Net Amount</th>
                        <th>Doc_Share</th>
                        <th>Hos_Share</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody id="ibody_ctscan">
                </tbody>
            </table>
        </div>

       
    </div>
    <input type="button" class="btn btn-primry" style="margin-top: 20px; width:100px !important" onclick="submitData()" value="Save"/>

        
    

</asp:Content>
