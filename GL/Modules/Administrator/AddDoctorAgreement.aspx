<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AddDoctorAgreement.aspx.cs" Inherits="PMS.Inventory.AddDoctorAgreement" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/Tibbit_theme/css/CustomCss/DoctorAgrement.css" rel="stylesheet" />
    <script type="text/javascript">
        var id = '<% =Request.QueryString["ID"] %>';
        $(document).ready(function () {
              <% if (Request.QueryString["doc_id"] != null)
        { %>
            var doc_ids = '<%= Request.QueryString["doc_id"]%>'
            debugger
            EditMasterForm(doc_ids);
            $('#btnValue').val('Update');
             <% }%>
            GetDoctors();
            FillAgrementTypes();
            FillAgrementdepts();

            $('#ddlitem_type').attr('disabled', true);
            $('#Active').prop('checked', true)
            $('#ddl_Doctor').select2();
            $('#ddl_AgrementType').select2();
            $('#ddl_Agrementdept').select2();
            debugger;
            if (id != "") {
                $("#btnValue").val('Update');
                $("#btnValue").hide();
            }
            $('select').select2();

        });
        $(function () {
            $("#tabs").tabs();

        });
        function GetDoctors() {
            debugger;
            var optionsVen = '<option value="0">Please Select</option>';
            PageMethods.GetDoctorName(function (Tests) {
                debugger
                $.each(JSON.parse(Tests), function (key, value) {
                    debugger;
                    optionsVen += '<option value="' + value.Emp_ID + '" >' + value.Emp_Name + '</option>';
                });
                $('#ddl_Doctor').html(optionsVen);
            });
        }
        function NewPage() {
            window.location = "AddDoctorAgreement.aspx";
        }

        function ListView() {
            window.location = "DoctorAgreementView.aspx";
        }


        function ddldiscount() {
            debugger;
            var ddlsDisc = parseFloat($('#discount').val()) || 0;
            var rows = $('table#tblResult_ctscan tbody tr');
            if (rows.length === 0) {
                return; // Exit the function if no rows
            }

            rows.each(function () {
                debugger;
                var test_rate_ctscan = parseFloat($(this).find('input[name="txtrate"]').val()) || 0;
                var disc_test_ctscan = parseFloat($(this).find('input[name="txtdiscount"]').val()) || 0;
                var Dis_amt = Math.round((test_rate_ctscan * disc_test_ctscan) / 100);
                var amt = test_rate_ctscan - Dis_amt;
                var calc_test_rate_ct_doc = Math.round((amt * ddlsDisc) / 100);
                var calc_test_rate_ct_hos = amt - calc_test_rate_ct_doc;
                $(this).find('input[name="txtnetamount"]').val(amt.toFixed(2));
                $(this).find('input[name="Txtdocshare"]').val(calc_test_rate_ct_doc.toFixed(2));
                $(this).find('input[name="Txthocshare"]').val(calc_test_rate_ct_hos.toFixed(2));
            });
        }

        function ddldiscount_Opd() {
            debugger;
            var ddlsDisc = parseFloat($('#discount_Opd').val()) || 0;

            var rows = $('table#tblResult_Opd tbody tr');
            if (rows.length === 0) {
                return; // Exit the function if no rows
            }
            rows.each(function () {
                debugger;
                var test_rate_opd = parseFloat($(this).find('input[name="txtrate"]').val()) || 0;
                var disc_test_opd = parseFloat($(this).find('input[name="txtdiscount"]').val()) || 0;
                var Dis_amt = Math.round((test_rate_opd * disc_test_opd) / 100);
                var amt = test_rate_opd - Dis_amt;
                var calc_test_rate_opd_doc = Math.round((amt * ddlsDisc) / 100);
                var calc_test_rate_opd_hos = amt - calc_test_rate_opd_doc;
                $(this).find('input[name="txtnetamount"]').val(amt.toFixed(2));
                $(this).find('input[name="Txtdocshare"]').val(calc_test_rate_opd_doc.toFixed(2));
                $(this).find('input[name="Txthocshare"]').val(calc_test_rate_opd_hos.toFixed(2));
            });
        }


        function ddldiscount_lab() {
            debugger;
            var ddlsDisc_lab = parseFloat($('#discount_lab').val()) || 0;

            var rows = $('table#tblResult tbody tr');
            if (rows.length === 0) {
                return; // Exit the function if no rows
            }
            rows.each(function () {
                debugger;
                var test_rate = parseFloat($(this).find('input[name="txtrate"]').val()) || 0;
                var disc_test = parseFloat($(this).find('input[name="txtdiscount"]').val()) || 0;
                var Dis_amt = Math.round((test_rate * disc_test) / 100);
                var amt = test_rate - Dis_amt;

                var doc_per_amt = Math.round((amt * ddlsDisc_lab) / 100);
                var cal_hos = amt - doc_per_amt;
                $(this).find('input[name="txtnetamount"]').val(amt.toFixed(2));
                $(this).find('input[name="Txtdocshare"]').val(doc_per_amt.toFixed(2));
                $(this).find('input[name="Txthocshare"]').val(cal_hos.toFixed(2));
            });
        }

        function ddldiscount_xray() {
            debugger;
            var ddlsDisc_xray = parseFloat($('#discount_xray').val()) || 0;

            var rows = $('table#tblResults tbody tr');
            if (rows.length === 0) {
                return;
            }
            rows.each(function () {
                debugger;
                var test_rate = parseFloat($(this).find('input[name="txtrate"]').val()) || 0;
                var calc_test_rate_doc = Math.round((test_rate * ddlsDisc_xray) / 100);
                var total_amt_test_hos = test_rate - calc_test_rate_doc;
                $(this).find('input[name="txtnetamount"]').val(test_rate.toFixed(2));
                $(this).find('input[name="Txtdocshare"]').val(calc_test_rate_doc.toFixed(2));
                $(this).find('input[name="Txthocshare"]').val(total_amt_test_hos.toFixed(2));
            });
        }


        function ddldiscount_ultra() {
            debugger;
            var ddlsDiscs = parseFloat($('#discount_ultra').val()) || 0;

            var rows = $('table#tblResult_ultra tbody tr');
            if (rows.length === 0) {
                return; // Exit the function if no rows
            }
            rows.each(function () {
                debugger;
                var test_rate_ultra_hos = parseFloat($(this).find('input[name="txtrate"]').val()) || 0;
                var disc_test_utlra = parseFloat($(this).find('input[name="txtdiscount"]').val()) || 0;
                var Dis_amt = Math.round((test_rate_ultra_hos * disc_test_utlra) / 100);
                var amt = test_rate_ultra_hos - Dis_amt;

                var calc_test_rate_ultra_doc = Math.round((amt * ddlsDiscs) / 100);
                var calc_test_rate_ultra_hos = amt - calc_test_rate_ultra_doc;
                $(this).find('input[name="txtnetamount"]').val(amt.toFixed(2));
                $(this).find('input[name="Txtdocshare"]').val(calc_test_rate_ultra_doc.toFixed(2));
                $(this).find('input[name="Txthocshare"]').val(calc_test_rate_ultra_hos.toFixed(2));
            });
        }

        function ddldiscount_mir() {
            debugger;
            var ddlsDiscs = $('#discount_mir').val() || 0;

            debugger;
            var rows = $('table#tblResult_mri tbody tr');
            if (rows.length === 0) {
                return; // Exit the function if no rows
            }
            rows.each(function () {
                var test_rate_mir_hos = parseFloat($(this).find('input[name="txtrate"]').val()) || 0;
                var disc_test_utlra = parseFloat($(this).find('input[name="txtdiscount"]').val()) || 0;
                var Dis_amt = Math.round((test_rate_mir_hos * disc_test_utlra) / 100);
                var amt = test_rate_mir_hos - Dis_amt;

                var calc_test_rate_mir_doc = Math.round((amt * ddlsDiscs) / 100);
                var calc_test_rate_mir_hos = amt - calc_test_rate_mir_doc;
                $(this).find('input[name="txtnetamount"]').val(amt.toFixed(2));
                $(this).find('input[name="Txtdocshare"]').val(calc_test_rate_mir_doc.toFixed(2));
                $(this).find('input[name="Txthocshare"]').val(calc_test_rate_mir_hos.toFixed(2));
            });
        }


        function ddldiscount_blood() {
            debugger;
            var ddlsDisc_blood = parseFloat($('#discount_blood').val()) || 0;

            var rows = $('table#tblResult_bloodbank tbody tr');
            if (rows.length === 0) {
                return; // Exit the function if no rows
            }
            rows.each(function () {
                debugger;
                var test_rate_bld = parseFloat($(this).find('input[name="txtrate"]').val()) || 0;
                var disc_test = parseFloat($(this).find('input[name="txtdiscount"]').val()) || 0;
                var Dis_amt = Math.round((test_rate_bld * disc_test) / 100);
                var amt = test_rate_bld - Dis_amt;

                var calc_test_rate_doc = Math.round((amt * ddlsDisc_blood) / 100);
                var calc_test_rate_hos = amt - calc_test_rate_doc;
                $(this).find('input[name="txtnetamount"]').val(amt.toFixed(2));
                $(this).find('input[name="Txtdocshare"]').val(calc_test_rate_doc.toFixed(2));
                $(this).find('input[name="Txthocshare"]').val(calc_test_rate_hos.toFixed(2));
            });
        }

        function ddldiscount_service() {
            debugger;
            var ddlsDisc_service = parseFloat($('#discount_service').val()) || 0;

            var rows = $('table#tblResult_services tbody tr');
            if (rows.length === 0) {
                return; // Exit the function if no rows
            }
            rows.each(function () {
                debugger;
                var test_rate_ser = parseFloat($(this).find('input[name="txtrate"]').val()) || 0;
                var disc_test = parseFloat($(this).find('input[name="txtdiscount"]').val()) || 0;

                var Dis_amt = Math.round((test_rate_ser * disc_test) / 100);
                var amt = test_rate_ser - Dis_amt;

                var calc_ser_doc = Math.round((amt * ddlsDisc_service) / 100);
                var calc_ser_hos = amt - calc_ser_doc;
                $(this).find('input[name="txtnetamount"]').val(amt.toFixed(2));
                $(this).find('input[name="Txtdocshare"]').val(calc_ser_doc.toFixed(2));
                $(this).find('input[name="Txthocshare"]').val(calc_ser_hos.toFixed(2));
            });
        }

        //validation for persentage
        function GetSumOfDiscount() {
            debugger;
            var doctor_share = $('#txtDocShare').val();
            var hospital_Share = $('#txtHospitalShare').val();
            if (doctor_share == "") doctor_share = 0;
            if (hospital_Share == "") hospital_Share = 0;
            if (doctor_share)
                var sum_of_share = parseInt(doctor_share) + parseInt(hospital_Share);
            if (sum_of_share == 100) {
            }
            else {
                debugger;
                alert('Sum of Share Should Be 100 %');
                if (doctor_share > 100) {
                    if (sum_of_share > 100) {
                        $('#txtDocShare').val('0');
                    }
                }
                if (hospital_Share > 100) {
                    if (sum_of_share > 100) {
                        $('#txtDocShare').val('0');
                    }
                }
                if (doctor_share > 100 || hospital_Share > 100 || sum_of_share > 100) {
                    if (doctor_share > 100) {
                        $('#txtDocShare').val('0');
                    }
                    else if (hospital_Share > 100) {
                        $('#txtHospitalShare').val('0');
                    }
                    else if (sum_of_share > 100) {
                        if (doctor_share < 100) {
                            $('#txtDocShare').val('0');
                        }
                        else if (hospital_Share < 100) {
                            $('#txtHospitalShare').val('0');
                        }
                        else if (doctor_share == hospital_Share) {
                            $('#txtDocShare').val('0');
                            $('#txtHospitalShare').val('0');
                        }
                    }
                }
                else if (doctor_share < 100 || hospital_Share < 100 || sum_of_share < 100) {

                    if (doctor_share == hospital_Share) {
                        $('#txtDocShare').val('0');
                        $('#txtHospitalShare').val('0');
                    }
                }
            }
        }

        function FillAgrementTypes() {
            var optionsType = '';
            PageMethods.FillAgrementType(function (Tests) {
                optionsType = '<option value="0">Please Select</option>';
                $.each(JSON.parse(Tests), function (key, value) {
                    optionsType += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                });
                $('#ddl_Opd_AgrementType').html(optionsType);
                $('#ddl_CTScan_AgrementType').html(optionsType);
                $('#ddl_bloodbank_AgrementType').html(optionsType);
                $('#ddl_labtest_AgrementType').html(optionsType);
                $('#ddl_xray_AgrementType').html(optionsType);
                $('#ddl_ultrasounds_AgrementType').html(optionsType);
                $('#ddl_mri_AgrementType').html(optionsType);
                $('#ddl_services_AgrementType').html(optionsType);
            });
        }
        function FillAgrementdepts() {
            var optionsDept = '';
            PageMethods.FillAgrementdept(function (Tests) {
                optionsDept = '<option value="0">Please Select</option>';
                $.each(JSON.parse(Tests), function (key, value) {
                    optionsDept += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                });
                $('#ddl_Opd_Agrementdept').html(optionsDept);
                $('#ddl_CTScan_Agrementdept').html(optionsDept);
                $('#ddl_bloodbank_Agrementdept').html(optionsDept);
                $('#ddl_labtest_Agrementdept').html(optionsDept);
                $('#ddl_xray_Agrementdept').html(optionsDept);
                $('#ddl_ultrasounds_Agrementdept').html(optionsDept);
                $('#ddl_mri_Agrementdept').html(optionsDept);
                $('#ddl_services_Agrementdept').html(optionsDept);
            });
        }

        debugger;
        function EditMasterForm(doc_ids) {
            PageMethods.editMaster(doc_ids, function (resp) {
                var doc_data = JSON.parse(resp);
                debugger;
                $('#doc_id').val(doc_data.Doc_agreemnt_id);
                setTimeout(function () {
                    $('#ddl_Doctor').val(doc_data.Doctor).trigger('change');
                }, 1500);
                $('#txtdocamount').val(doc_data.Doc_account);                
            });
            debugger;
            setTimeout(function () {
                editDetail(doc_ids);
            }, 4500);
        }
        function editDetail(doc_ids) {
            $("#btnSave").attr('disabled', true);
            debugger;
            $.ajax({
                type: "post",
                url: "AddDoctorAgreement.aspx/EditDetail",
                data: JSON.stringify({
                    "doc_ids": doc_ids
                }),
                contentType: "application/json; charset=utf-8",
                datatype: "json",
                success: function (response) {
                    debugger;
                    var doctor_data = JSON.parse(response.d);
                    var mdTable = $('#tblResult');
                    var mdTablexray = $('#tblResults');
                    var mdTableOpd = $('#tblResult_Opd');
                    var mdTable_ultra = $('#tblResult_ultra');
                    var mdTable_CTScan = $('#tblResult_ctscan');
                    var mdTable_bloodbank = $('#tblResult_bloodbank');
                    var mdTable_mri = $('#tblResult_mri');
                    var mdTable_service = $('#tblResult_services');
                    debugger;
                    $(doctor_data).each(function (index, md) {

                        if (md.Department == "OPD") {
                            $('#ddlmaindep_Opd').val('004').trigger('change');
                         
                            $('#ddlmaindep_Opd').attr('disabled', true);
                            $('#ddl_Opd_AgrementType').val(md.AgrementTypeId).trigger('change');
                            $('#ddl_Opd_Agrementdept').val(md.AgrementDepartmentId).trigger('change');
                            mdTableOpd.append('<tr><td style="display:none;"><input type="hidden" name="txtestid" id="txtestid" value="' + md.test_id + '" /></td><td style="display:none;"><input type="hidden" name="txtdoc_id" id="txtdoc_id" value="' + md.Doc_agreement_id + '" /></td><td style="display:none;"><input type="hidden" name="txtestid" id="txtestid" value="' + md.item_id + '" /></td><td style="display:none;"><input type="hidden" name="txtdep" id="txtdep" value="' + md.Department + '" /></td><td><input type="text" readonly name="txtname" id="txtname" value="' + md.test_description + '" /></td><td style="display:none;"><input type="hidden" readonly id="agremntTypeId" name="agremntTypeId" value="' + md.AgrementTypeId + '" /></td><td><input type="text" readonly name="agremntType" id="agremntType" value="' + md.AgrementType + '" /></td><td style="display:none;"><input type="hidden"readonly id="agremntDeptId" name="agremntDeptId" value="' + md.AgrementDepartmentId + '" /></td><td><input type="text" readonly name="agremntDept" id="agremntDept" value="' + md.AgrementDepartment + '" /></td><td><input type="text" readonly name="txtrate" id="txtrate"  value="' + md.Actual_amount + '" /></td><td><input type="text"  name="txtdiscount" id="txtdiscount" onchange="calculatedisc(this);" value="' + md.dicount + '" /></td><td><input type="text" readonly name="txtnetamount" id="txtnetamount" value="' + md.Net_amount + '" /></td><td><input type="text"  name="Txtdocshare" id="Txtdocshare" onchange="hosp_doc(this);" value="' + md.doc_share + '" /></td><td><input type="text" readonly name="Txthocshare" id="Txthocshare" value="' + md.hos_share + '" /></td><td><a href="#" class="btn-primry delete-row-opd" style="border-radius: 50%; display: inline-block; width: 27px; height: 24px; text-align: center"><i class="fa fa-trash" style="color: white;"></i></a></td></tr>');
                        }

                        if (md.Department == "001") {
                            $('#ddlmaindep').val('001').trigger('change');
                            $('#ddlmaindep').attr('disabled', true);
                            $('#ddl_labtest_AgrementType').val(md.AgrementTypeId).trigger('change');
                            $('#ddl_labtest_Agrementdept').val(md.AgrementDepartmentId).trigger('change');
                            mdTable.append('<tr><td style="display:none;"><input type="hidden" name="txtestid" id="txtestid" value="' + md.test_id + '" /></td><td style="display:none;"><input type="hidden" name="txtdoc_id" id="txtdoc_id" value="' + md.Doc_agreement_id + '" /></td><td style="display:none;"><input type="hidden" name="txtestid" id="txtestid" value="' + md.item_id + '" /></td><td style="display:none;"><input type="hidden" name="txtdep" id="txtdep" value="' + md.Department + '" /></td><td><input type="text" readonly name="txtname" id="txtname" value="' + md.test_description + '" /></td><td style="display:none;"><input type="hidden" readonly id="agremntTypeId" name="agremntTypeId" value="' + md.AgrementTypeId + '" /></td><td><input type="text" readonly name="agremntType" id="agremntType" value="' + md.AgrementType + '" /></td><td style="display:none;"><input type="hidden"readonly id="agremntDeptId" name="agremntDeptId" value="' + md.AgrementDepartmentId + '" /></td><td><input type="text" readonly name="agremntDept" id="agremntDept" value="' + md.AgrementDepartment + '" /></td><td><input type="text" readonly name="txtrate" id="txtrate" value="' + md.Actual_amount + '" /></td><td><input type="text"  name="txtdiscount" id="txtdiscount" onchange="calculatedisc(this);" value="' + md.dicount + '" /></td><td><input type="text" readonly name="txtnetamount" id="txtnetamount" value="' + md.Net_amount + '" /></td><td><input type="text"  name="Txtdocshare" id="Txtdocshare" onchange="hosp_doc(this);" value="' + md.doc_share + '" /></td><td><input type="text" readonly name="Txthocshare" id="Txthocshare" value="' + md.hos_share + '" /></td><td><a href="#" class="btn-primry delete-row-lab" style="border-radius: 50%; display: inline-block; width: 27px; height: 24px; text-align: center"><i class="fa fa-trash" style="color: white;"></i></a></td></tr>');
                        }
                        debugger;
                        if (md.Department == "003") {
                            $('#ddlmaindep_xray').val('003').trigger('change');
                            $('#ddlmaindep_xray').attr('disabled', true);
                            $('#ddl_xray_AgrementType').val(md.AgrementTypeId).trigger('change');
                            $('#ddl_xray_Agrementdept').val(md.AgrementDepartmentId).trigger('change');
                             mdTablexray.append('<tr><td style="display:none;"><input type="hidden" name="txtestid" id="txtestid" value="' + md.test_id + '" /></td><td style="display:none;"><input type="hidden" name="txtestid" id="txtestid" value="' + md.item_id + '" /></td><td style="display:none;"><input type="hidden" name="txtdep" id="txtdep" value="' + md.Department + '" /></td><td><input type="text" readonly name="txtname" id="txtname" value="' + md.test_description + '" /></td><td style="display:none;"><input type="hidden" readonly id="agremntTypeId" name="agremntTypeId" value="' + md.AgrementTypeId + '" /></td><td><input type="text" readonly name="agremntType" id="agremntType" value="' + md.AgrementType + '" /></td><td style="display:none;"><input type="hidden"readonly id="agremntDeptId" name="agremntDeptId" value="' + md.AgrementDepartmentId + '" /></td><td><input type="text" readonly name="agremntDept" id="agremntDept" value="' + md.AgrementDepartment + '" /></td><td><input type="text" readonly name="txtrate" id="txtrate" value="' + md.Actual_amount + '" /></td><td><input type="text"  name="txtdiscount" id="txtdiscount" onchange="calculatedisc(this);" value="' + md.dicount + '" /></td><td><input type="text" readonly name="txtnetamount" id="txtnetamount" value="' + md.Net_amount + '" /></td><td><input type="text"  name="Txtdocshare" id="Txtdocshare" onchange="hosp_doc(this);" value="' + md.doc_share + '" /></td><td><input type="text" readonly name="Txthocshare" id="Txthocshare" value="' + md.hos_share + '" /></td><td><a href="#" class="btn-primry delete-row-xray" style="border-radius: 50%; display: inline-block; width: 27px; height: 24px; text-align: center"><i class="fa fa-trash" style="color: white;"></i></a></td></tr>');

                        }
                        if (md.Department == "002") {
                            $('#ddlmaindep_Ultra').val('002').trigger('change');
                            $('#ddlmaindep_Ultra').attr('disabled', true);
                            $('#ddl_ultrasounds_AgrementType').val(md.AgrementTypeId).trigger('change');
                            $('#ddl_ultrasounds_Agrementdept').val(md.AgrementDepartmentId).trigger('change');
                            mdTable_ultra.append('<tr><td style="display:none;"><input type="hidden" name="txtestid" id="txtestid" value="' + md.test_id + '" /></td><td style="display:none;"><input type="hidden" name="txtestid" id="txtestid" value="' + md.item_id + '" /></td><td style="display:none;"><input type="hidden" name="txtdep" id="txtdep" value="' + md.Department + '" /></td><td><input type="text" readonly name="txtname" id="txtname" value="' + md.test_description + '" /></td><td style="display:none;"><input type="hidden" readonly id="agremntTypeId" name="agremntTypeId" value="' + md.AgrementTypeId + '" /></td><td><input type="text" readonly name="agremntType" id="agremntType" value="' + md.AgrementType + '" /></td><td style="display:none;"><input type="hidden"readonly id="agremntDeptId" name="agremntDeptId" value="' + md.AgrementDepartmentId + '" /></td><td><input type="text" readonly name="agremntDept" id="agremntDept" value="' + md.AgrementDepartment + '" /></td><td><input type="text" readonly name="txtrate" id="txtrate" value="' + md.Actual_amount + '" /></td><td><input type="text"  name="txtdiscount" id="txtdiscount" onchange="calculatedisc(this);" value="' + md.dicount + '" /></td><td><input type="text" readonly name="txtnetamount" id="txtnetamount" value="' + md.Net_amount + '" /></td><td><input type="text"  name="Txtdocshare" id="Txtdocshare" onchange="hosp_doc(this);" value="' + md.doc_share + '" /></td><td><input type="text" readonly name="Txthocshare" id="Txthocshare" value="' + md.hos_share + '" /></td><td><a href="#" class="btn-primry delete-row-ultrasound" style="border-radius: 50%; display: inline-block; width: 27px; height: 24px; text-align: center"><i class="fa fa-trash" style="color: white;"></i></a></td></tr>');
                        }
                        if (md.Department == "004") {
                            $('#ddlmaindep_ct_scan').val('004').trigger('change');
                            $('#ddlmaindep_ct_scan').attr('disabled', true);
                            $('#ddl_CTScan_AgrementType').val(md.AgrementTypeId).trigger('change');
                            $('#ddl_CTScan_Agrementdept').val(md.AgrementDepartmentId).trigger('change');
                            mdTable_CTScan.append('<tr><td style="display:none;"><input type="hidden" name="txtestid" id="txtestid" value="' + md.test_id + '" /></td><td style="display:none;"><input type="hidden" name="txtestid" id="txtestid" value="' + md.item_id + '" /></td><td style="display:none;"><input type="hidden" name="txtdep" id="txtdep" value="' + md.Department + '" /></td><td><input type="text" readonly name="txtname" id="txtname" value="' + md.test_description + '" /></td><td style="display:none;"><input type="hidden" readonly id="agremntTypeId" name="agremntTypeId" value="' + md.AgrementTypeId + '" /></td><td><input type="text" readonly name="agremntType" id="agremntType" value="' + md.AgrementType + '" /></td><td style="display:none;"><input type="hidden"readonly id="agremntDeptId" name="agremntDeptId" value="' + md.AgrementDepartmentId + '" /></td><td><input type="text" readonly name="agremntDept" id="agremntDept" value="' + md.AgrementDepartment + '" /></td><td><input type="text" readonly name="txtrate" id="txtrate" value="' + md.Actual_amount + '" /></td><td><input type="text"  name="txtdiscount" id="txtdiscount" onchange="calculatedisc(this);" value="' + md.dicount + '" /></td><td><input type="text" readonly name="txtnetamount" id="txtnetamount" value="' + md.Net_amount + '" /></td><td><input type="text"  name="Txtdocshare" id="Txtdocshare" onchange="hosp_doc(this);" value="' + md.doc_share + '" /></td><td><input type="text" readonly name="Txthocshare" id="Txthocshare" value="' + md.hos_share + '" /></td><td><a href="#" class="btn-primry delete-row-ctscan" style="border-radius: 50%; display: inline-block; width: 27px; height: 24px; text-align: center"><i class="fa fa-trash" style="color: white;"></i></a></td></tr>');
                        }
                        if (md.Department == "005") {
                            $('#ddlmaindep_bloodbank').val('005').trigger('change');
                            $('#ddlmaindep_bloodbank').attr('disabled', true);
                            $('#ddl_bloodbank_AgrementType').val(md.AgrementTypeId).trigger('change');
                            $('#ddl_bloodbank_Agrementdept').val(md.AgrementDepartmentId).trigger('change');
                            mdTable_bloodbank.append('<tr><td style="display:none;"><input type="hidden" name="txtestid" id="txtestid" value="' + md.test_id + '" /></td><td style="display:none;"><input type="hidden" name="txtestid" id="txtestid" value="' + md.item_id + '" /></td><td style="display:none;"><input type="hidden" name="txtdep" id="txtdep" value="' + md.Department + '" /></td><td><input type="text" readonly name="txtname" id="txtname" value="' + md.test_description + '" /></td><td style="display:none;"><input type="hidden" readonly id="agremntTypeId" name="agremntTypeId" value="' + md.AgrementTypeId + '" /></td><td><input type="text" readonly name="agremntType" id="agremntType" value="' + md.AgrementType + '" /></td><td style="display:none;"><input type="hidden"readonly id="agremntDeptId" name="agremntDeptId" value="' + md.AgrementDepartmentId + '" /></td><td><input type="text" readonly name="agremntDept" id="agremntDept" value="' + md.AgrementDepartment + '" /></td><td><input type="text" readonly name="txtrate" id="txtrate" value="' + md.Actual_amount + '" /></td><td><input type="text"  name="txtdiscount" id="txtdiscount" onchange="calculatedisc(this);" value="' + md.dicount + '" /></td><td><input type="text" readonly name="txtnetamount" id="txtnetamount" value="' + md.Net_amount + '" /></td><td><input type="text"  name="Txtdocshare" id="Txtdocshare" onchange="hosp_doc(this);" value="' + md.doc_share + '" /></td><td><input type="text" readonly name="Txthocshare" id="Txthocshare" value="' + md.hos_share + '" /></td><td><a href="#" class="btn-primry delete-row-bloodbank" style="border-radius: 50%; display: inline-block; width: 27px; height: 24px; text-align: center"><i class="fa fa-trash" style="color: white;"></i></a></td></tr>');
                        }

                        if (md.Department == "006") {
                            $('#ddlmaindep_MRI').val('006').trigger('change');
                            $('#ddlmaindep_MRI').attr('disabled', true);
                            $('#ddl_mri_AgrementType').val(md.AgrementTypeId).trigger('change');
                            $('#ddl_mri_Agrementdept').val(md.AgrementDepartmentId).trigger('change');
                            mdTable_mri.append('<tr><td style="display:none;"><input type="hidden" name="txtestid" id="txtestid" value="' + md.test_id + '" /></td><td style="display:none;"><input type="hidden" name="txtestid" id="txtestid" value="' + md.item_id + '" /></td><td style="display:none;"><input type="hidden" name="txtdep" id="txtdep" value="' + md.Department + '" /></td><td><input type="text" readonly name="txtname" id="txtname" value="' + md.test_description + '" /></td><td style="display:none;"><input type="hidden" readonly id="agremntTypeId" name="agremntTypeId" value="' + md.AgrementTypeId + '" /></td><td><input type="text" readonly name="agremntType" id="agremntType" value="' + md.AgrementType + '" /></td><td style="display:none;"><input type="hidden"readonly id="agremntDeptId" name="agremntDeptId" value="' + md.AgrementDepartmentId + '" /></td><td><input type="text" readonly name="agremntDept" id="agremntDept" value="' + md.AgrementDepartment + '" /></td><td><input type="text" readonly name="txtrate" id="txtrate" value="' + md.Actual_amount + '" /></td><td><input type="text"  name="txtdiscount" id="txtdiscount" onchange="calculatedisc(this);" value="' + md.dicount + '" /></td><td><input type="text" readonly name="txtnetamount" id="txtnetamount" value="' + md.Net_amount + '" /></td><td><input type="text"  name="Txtdocshare" id="Txtdocshare" onchange="hosp_doc(this);" value="' + md.doc_share + '" /></td><td><input type="text" readonly name="Txthocshare" id="Txthocshare" value="' + md.hos_share + '" /></td><td><a href="#" class="btn-primry delete-row-MRI" style="border-radius: 50%; display: inline-block; width: 27px; height: 24px; text-align: center"><i class="fa fa-trash" style="color: white;"></i></a></td></tr>');
                        }
                        debugger;
                        if (md.services == "002") {
                            $('#ddlmaindep_Services').val('002').trigger('change');
                            $('#ddlmaindep_Services').attr('disabled', true);
                            $('#ddl_services_AgrementType').val(md.AgrementTypeId).trigger('change');
                            $('#ddl_services_Agrementdept').val(md.AgrementDepartmentId).trigger('change');
                            mdTable_service.append('<tr><td style="display:none;"><input type="hidden" name="txtestid" id="txtestid" value="' + md.item_id + '" /></td><td style="display:none;"><input type="hidden" name="txtservices" id="txtservices" value="' + md.services + '" /></td><td><input type="text" readonly name="txtname" id="txtname" value="' + md.service_description + '" /></td><td style="display:none;"><input type="hidden" readonly id="agremntTypeId" name="agremntTypeId" value="' + md.AgrementTypeId + '" /></td><td><input type="text" readonly name="agremntType" id="agremntType" value="' + md.AgrementType + '" /></td><td style="display:none;"><input type="hidden"readonly id="agremntDeptId" name="agremntDeptId" value="' + md.AgrementDepartmentId + '" /></td><td><input type="text" readonly name="agremntDept" id="agremntDept" value="' + md.AgrementDepartment + '" /></td><td><input type="text" readonly name="txtrate" id="txtrate" value="' + md.Actual_amount + '" /></td><td><input type="text"  name="txtdiscount" id="txtdiscount" onchange="calculatedisc(this);" value="' + md.dicount + '" /></td><td><input type="text" readonly name="txtnetamount" id="txtnetamount" value="' + md.Net_amount + '" /></td><td><input type="text"  name="Txtdocshare" id="Txtdocshare" onchange="hosp_doc(this);" value="' + md.doc_share + '" /></td><td><input type="text" readonly name="Txthocshare" id="Txthocshare" value="' + md.hos_share + '" /></td> <td><a href="#" class="btn-primry delete-row-services" style="border-radius: 50%; display: inline-block; width: 27px; height: 24px; text-align: center"><i class="fa fa-trash" style="color: white;"></i></a></td></tr>');
                        }
                    });

                }
            });
        }
        function toasterMessage(isError = false, title, message) {
            debugger;
            toastr.options = {
                "closeButton": true,
                "debug": false,
                "preventDuplicates": false,
                "positionClass": "toast-top-right",
                "onclick": null,
                "showDuration": "400",
                "hideDuration": "1000",
                "timeOut": "4000",
                "extendedTimeOut": "1000",
                "showEasing": "swing",
                "hideEasing": "linear",
                "showMethod": "fadeIn",
                "hideMethod": "fadeOut",
                onclick: function () {
                    $('#right-sidebar').toggleClass('sidebar-open');
                }
            };
            if (isError)
                toastr.error(message, title);
            else
                toastr.success(message, title);
        }
        function loaddoctordata() {
            var doctor_id = $('#ddl_Doctor').val();
            PageMethods.LoaddoctorInfo(doctor_id, function (Tests) {
                debugger;
                var data = JSON.parse(Tests);
                var abc = data.accountname;
                var def = data.Account_ID;
                var kfg = def + '__' + abc;
                $('#txtdocamount').val(kfg);
            });
        }
        debugger;
        var doc_idss;
        function saveLabtest() {
            debugger;
             $("#btnValue").prop("disabled", true);
            var btnsaves = $('#btnValue').val();
            debugger;
            if (btnsaves == "Update") {
                debugger;
                doc_idss = $('#doc_id').val();
            }
            else {
                doc_idss = 0;
            }
            var ddlDoctor = $('#ddl_Doctor').val();
            var doc_account = $('#txtdocamount').val();           
            var ddllabtest = $('#ddlmaindep').val();
            var ddl_xray = $('#ddlmaindep_xray').val();
            var ddl_opd = $('#ddlmaindep_Opd').val();
            var ddl_ultrasound = $('#ddlmaindep_Ultra').val();
            var ddl_CTScan = $('#ddlmaindep_ctscan').val();
            var ddl_bloodbank = $('#ddlmaindep_bloodbank').val();
            var ddl_Service = $('#ddlmaindep_Services').val();
            var ddl_mir = $('#ddlmaindep_MRI').val();
            var Is_Active = $('#Active').prop("checked");
            var Save_list = [];
            var save_opd = [];
            var save_xray = [];
            var save_ultra = [];
            var save_Ct_Scan = [];
            var save_blood_bank = [];
            var save_Services = [];
            var save_mri = [];
            debugger;
            //multiple loops here
            if ($('#tblResult_Opd tbody tr').length > 0) {
            $.each($('#tblResult_Opd tbody tr'), function (key, value) {
                debugger;
                var hdn_test_id = $($(value).find('td input[name=txtestid]')[0]).val();
                var txtdep = $($(value).find('td input[name=txtdep]')[0]).val();
                var Description = $($(value).find('td input[name=txtname]')[0]).val();
                var hdn_agremntTypeId = $($(value).find('td input[name=agremntTypeId]')[0]).val();
                var hdn_agremntDeptId = $($(value).find('td input[name=agremntDeptId]')[0]).val();
                var test_Rate = $($(value).find('td input[name=txtrate]')[0]).val();
                var Discount = $($(value).find('td input[name=txtdiscount]')[0]).val();
                var Net_amount = $($(value).find('td input[name=txtnetamount]')[0]).val();
                var txt_Doc_share = $($(value).find('td input[name=Txtdocshare]')[0]).val();
                var txt_hos_share = $($(value).find('td input[name=Txthocshare]')[0]).val();
                save_opd.push({
                    hdn_test_id: hdn_test_id, txtdep: txtdep, Description: Description, hdn_agremntTypeId: hdn_agremntTypeId, hdn_agremntDeptId: hdn_agremntDeptId, test_Rate: test_Rate, Discount: Discount, Net_amount: Net_amount, txt_Doc_share: txt_Doc_share, txt_hos_share: txt_hos_share
                });
            });
            }

             if ($('#tblResult tbody tr').length > 0) {
            $.each($('#tblResult tbody tr'), function (key, value) {
                debugger;
                var hdn_test_id = $($(value).find('td input[name=txtestid]')[0]).val();
                var txtdep = $($(value).find('td input[name=txtdep]')[0]).val();
                var Description = $($(value).find('td input[name=txtname]')[0]).val();
                var hdn_agremntTypeId = $($(value).find('td input[name=agremntTypeId]')[0]).val();
                var hdn_agremntDeptId = $($(value).find('td input[name=agremntDeptId]')[0]).val();
                var test_Rate = $($(value).find('td input[name=txtrate]')[0]).val();
                var Discount = $($(value).find('td input[name=txtdiscount]')[0]).val();
                var Net_amount = $($(value).find('td input[name=txtnetamount]')[0]).val();
                var txt_Doc_share = $($(value).find('td input[name=Txtdocshare]')[0]).val();
                var txt_hos_share = $($(value).find('td input[name=Txthocshare]')[0]).val();
                Save_list.push({
                    hdn_test_id: hdn_test_id, txtdep: txtdep, Description: Description, hdn_agremntTypeId: hdn_agremntTypeId, hdn_agremntDeptId: hdn_agremntDeptId, test_Rate: test_Rate, Discount: Discount, Net_amount: Net_amount, txt_Doc_share: txt_Doc_share, txt_hos_share: txt_hos_share
                });
            });
            }

              if ($('#tblResults tbody tr').length > 0) {
            $.each($('#tblResults tbody tr'), function (key, value) {
                debugger;
                var hdn_test_id = $($(value).find('td input[name=txtestid]')[0]).val();
                var txtdep_xray = $($(value).find('td input[name=txtdep]')[0]).val();
                var Description = $($(value).find('td input[name=txtname]')[0]).val();
                var hdn_agremntTypeId = $($(value).find('td input[name=agremntTypeId]')[0]).val();
                var hdn_agremntDeptId = $($(value).find('td input[name=agremntDeptId]')[0]).val();
                var test_Rate = $($(value).find('td input[name=txtrate]')[0]).val();
                var Discount = $($(value).find('td input[name=txtdiscount]')[0]).val();
                var Net_amount = $($(value).find('td input[name=txtnetamount]')[0]).val();
                var txt_Doc_share = $($(value).find('td input[name=Txtdocshare]')[0]).val();
                var txt_hos_share = $($(value).find('td input[name=Txthocshare]')[0]).val();
                save_xray.push({
                    hdn_test_id: hdn_test_id, txtdep_xray: txtdep_xray, Description: Description, hdn_agremntTypeId: hdn_agremntTypeId, hdn_agremntDeptId: hdn_agremntDeptId, test_Rate: test_Rate, Discount: Discount, Net_amount: Net_amount, txt_Doc_share: txt_Doc_share, txt_hos_share: txt_hos_share
                });
            });
            }

            if ($('#tblResult_ultra tbody tr').length > 0) {
            $.each($('#tblResult_ultra tbody tr'), function (key, value) {
                debugger;
                var hdn_test_id = $($(value).find('td input[name=txtestid]')[0]).val();
                var txtdep_ultra = $($(value).find('td input[name=txtdep]')[0]).val();
                var Description = $($(value).find('td input[name=txtname]')[0]).val();
                var hdn_agremntTypeId = $($(value).find('td input[name=agremntTypeId]')[0]).val();
                var hdn_agremntDeptId = $($(value).find('td input[name=agremntDeptId]')[0]).val();
                var test_Rate = $($(value).find('td input[name=txtrate]')[0]).val();
                var Discount = $($(value).find('td input[name=txtdiscount]')[0]).val();
                var Net_amount = $($(value).find('td input[name=txtnetamount]')[0]).val();
                var txt_Doc_share = $($(value).find('td input[name=Txtdocshare]')[0]).val();
                var txt_hos_share = $($(value).find('td input[name=Txthocshare]')[0]).val();
                save_ultra.push({
                    hdn_test_id: hdn_test_id, txtdep_ultra: txtdep_ultra, Description: Description, hdn_agremntTypeId: hdn_agremntTypeId, hdn_agremntDeptId: hdn_agremntDeptId, test_Rate: test_Rate, Discount: Discount, Net_amount: Net_amount, txt_Doc_share: txt_Doc_share, txt_hos_share: txt_hos_share
                });
            });
            }

               if ($('#tblResult_ctscan tbody tr').length > 0) {
            $.each($('#tblResult_ctscan tbody tr'), function (key, value) {
                debugger;
                var hdn_test_id = $($(value).find('td input[name=txtestid]')[0]).val();
                var txtdep_ctscan = $($(value).find('td input[name=txtdep]')[0]).val();
                var Description = $($(value).find('td input[name=txtname]')[0]).val();
                var hdn_agremntTypeId = $($(value).find('td input[name=agremntTypeId]')[0]).val();
                var hdn_agremntDeptId = $($(value).find('td input[name=agremntDeptId]')[0]).val();
                var test_Rate = $($(value).find('td input[name=txtrate]')[0]).val();
                var Discount = $($(value).find('td input[name=txtdiscount]')[0]).val();
                var Net_amount = $($(value).find('td input[name=txtnetamount]')[0]).val();
                var txt_Doc_share = $($(value).find('td input[name=Txtdocshare]')[0]).val();
                var txt_hos_share = $($(value).find('td input[name=Txthocshare]')[0]).val();
                save_Ct_Scan.push({
                    hdn_test_id: hdn_test_id, txtdep_ctscan: txtdep_ctscan, Description: Description, hdn_agremntTypeId: hdn_agremntTypeId, hdn_agremntDeptId: hdn_agremntDeptId, test_Rate: test_Rate, Discount: Discount, Net_amount: Net_amount, txt_Doc_share: txt_Doc_share, txt_hos_share: txt_hos_share
                });
            });
            }

              if ($('#tblResult_bloodbank tbody tr').length > 0) {
            $.each($('#tblResult_bloodbank tbody tr'), function (key, value) {
                debugger;
                var hdn_test_id = $($(value).find('td input[name=txtestid]')[0]).val();
                var txtdep_bloodbank = $($(value).find('td input[name=txtdep]')[0]).val();
                var Description = $($(value).find('td input[name=txtname]')[0]).val();
                var hdn_agremntTypeId = $($(value).find('td input[name=agremntTypeId]')[0]).val();
                var hdn_agremntDeptId = $($(value).find('td input[name=agremntDeptId]')[0]).val();
                var test_Rate = $($(value).find('td input[name=txtrate]')[0]).val();
                var Discount = $($(value).find('td input[name=txtdiscount]')[0]).val();
                var Net_amount = $($(value).find('td input[name=txtnetamount]')[0]).val();
                var txt_Doc_share = $($(value).find('td input[name=Txtdocshare]')[0]).val();
                var txt_hos_share = $($(value).find('td input[name=Txthocshare]')[0]).val();
                save_blood_bank.push({
                    hdn_test_id: hdn_test_id, txtdep_bloodbank: txtdep_bloodbank, Description: Description, hdn_agremntTypeId: hdn_agremntTypeId, hdn_agremntDeptId: hdn_agremntDeptId, test_Rate: test_Rate, Discount: Discount, Net_amount: Net_amount, txt_Doc_share: txt_Doc_share, txt_hos_share: txt_hos_share
                });
            });
            }

             if ($('#tblResult_mri tbody tr').length > 0) {             
            $.each($('#tblResult_mri tbody tr'), function (key, value) {
                debugger;
                var hdn_test_id = $($(value).find('td input[name=txtestid]')[0]).val();
                var txtdep_mir = $($(value).find('td input[name=txtdep]')[0]).val();
                var Description = $($(value).find('td input[name=txtname]')[0]).val();
                var hdn_agremntTypeId = $($(value).find('td input[name=agremntTypeId]')[0]).val();
                var hdn_agremntDeptId = $($(value).find('td input[name=agremntDeptId]')[0]).val();
                var test_Rate = $($(value).find('td input[name=txtrate]')[0]).val();
                var Discount = $($(value).find('td input[name=txtdiscount]')[0]).val();
                var Net_amount = $($(value).find('td input[name=txtnetamount]')[0]).val();
                var txt_Doc_share = $($(value).find('td input[name=Txtdocshare]')[0]).val();
                var txt_hos_share = $($(value).find('td input[name=Txthocshare]')[0]).val();
                save_mri.push({
                    hdn_test_id: hdn_test_id, txtdep_mir: txtdep_mir, Description: Description, hdn_agremntTypeId: hdn_agremntTypeId, hdn_agremntDeptId: hdn_agremntDeptId, test_Rate: test_Rate, Discount: Discount, Net_amount: Net_amount, txt_Doc_share: txt_Doc_share, txt_hos_share: txt_hos_share
                });
            });
            }
             if ($('#tblResult_services tbody tr').length > 0) {          
            $.each($('#tblResult_services tbody tr'), function (key, value) {
                debugger;
                var hdn_test_id = $($(value).find('td input[name=txtestid]')[0]).val();
                var hdn_services = $($(value).find('td input[name=txtservices]')[0]).val();
                var txtdep_bloodbank = $($(value).find('td input[name=txtdep]')[0]).val();
                var Description = $($(value).find('td input[name=txtname]')[0]).val();
                var hdn_agremntTypeId = $($(value).find('td input[name=agremntTypeId]')[0]).val();
                var hdn_agremntDeptId = $($(value).find('td input[name=agremntDeptId]')[0]).val();
                var test_Rate = $($(value).find('td input[name=txtrate]')[0]).val();
                var Discount = $($(value).find('td input[name=txtdiscount]')[0]).val();
                var Net_amount = $($(value).find('td input[name=txtnetamount]')[0]).val();
                var txt_Doc_share = $($(value).find('td input[name=Txtdocshare]')[0]).val();
                var txt_hos_share = $($(value).find('td input[name=Txthocshare]')[0]).val();
                save_Services.push({
                    hdn_test_id: hdn_test_id, hdn_services: hdn_services, txtdep_bloodbank: txtdep_bloodbank, Description: Description, hdn_agremntTypeId: hdn_agremntTypeId, hdn_agremntDeptId: hdn_agremntDeptId, test_Rate: test_Rate, Discount: Discount, Net_amount: Net_amount, txt_Doc_share: txt_Doc_share, txt_hos_share: txt_hos_share
                });
            });
            }
            var AllRecords = { 'ddlDoctor': ddlDoctor, 'doc_account': doc_account, 'Is_Active': Is_Active, 'ddllabtest': ddllabtest, 'ddl_xray': ddl_xray, 'ddl_ultrasound': ddl_ultrasound, 'ddlmaindep_Opd': ddlmaindep_Opd, 'ddl_CTScan': ddl_CTScan, 'ddl_bloodbank': ddl_bloodbank, 'ddl_Service': ddl_Service, 'ddl_mir': ddl_mir, 'save_opd': save_opd, 'Save_list': Save_list, 'save_xray': save_xray, 'save_ultra': save_ultra, 'save_Ct_Scan': save_Ct_Scan, 'save_blood_bank': save_blood_bank, 'save_Services': save_Services, 'save_mri': save_mri, 'doc_idss': doc_idss };
            PageMethods.SaveDocagreement(JSON.stringify(AllRecords), btnsaves, function () {
                toasterMessage(false, "Success", "Data added Successfully");
                window.location.href = "AddDoctorAgreement.aspx";
               $("#btnValue").prop("disabled", false);
            });
        }

        debugger;
        function calculatedisc(row) {
            debugger;
            var discamount = $(row).closest('tr').find('td input[name=txtdiscount]').val() || 0;
            var test_rate = $(row).closest('tr').find('td input[name=txtrate]').val() || 0;
            var percent = (test_rate * discamount) / 100;
            var totalnet = test_rate - percent;
            $(row).closest('tr').find('td input[name=txtnetamount]').val(totalnet);

            var ddlsDiscdiscount = parseFloat($('#discount').val()) || 0;
            if (ddlsDiscdiscount > 0) {
                ddldiscount();
            }
            var discount_Opd = parseFloat($('#discount_Opd').val()) || 0;
            if (discount_Opd > 0) {
                ddldiscount_Opd();
            }

            var ddlsDisc_lab = parseFloat($('#discount_lab').val()) || 0;
            if (ddlsDisc_lab > 0) {
                ddldiscount_lab();
            }
            var ddlsDisc_xray = parseFloat($('#discount_xray').val()) || 0;
            if (ddlsDisc_xray > 0) {
                ddldiscount_xray();
            }
            var ddlsDiscs = parseFloat($('#discount_ultra').val()) || 0;
            if (ddlsDiscs > 0) {
                ddldiscount_ultra();
            }
            var ddlsDiscsmir = $('#discount_mir').val() || 0;
            if (ddlsDiscsmir > 0) {
                ddldiscount_mir();

            }
            var ddlsDisc_blood = parseFloat($('#discount_blood').val()) || 0;
            if (ddlsDisc_blood > 0) {
                ddldiscount_blood();

            }
            var ddlsDisc_service = parseFloat($('#discount_service').val()) || 0;
            if (ddlsDisc_service > 0) {
                ddldiscount_service();
            }

        }
        debugger;
        function hosp_doc(row) {
            debugger;
            var doc_share = $(row).closest('tr').find('td input[name=Txtdocshare]').val();
            var hos_share = $(row).closest('tr').find('td input[name=Txthocshare]').val();
            var txtnetamount = $(row).closest('tr').find('td input[name=txtnetamount]').val();
            var dfltamount = txtnetamount - doc_share;
            $(row).closest('tr').find('td input[name=Txthocshare]').val(dfltamount);
        }

        $(document).ready(function () {

            //***********************************************Services Modal***********************************************
            $('#btnshowservicesModal').click(function () {
                let mainDep = $('#ddlmaindep_Services').val() || 0;
                let agrementType = $('#ddl_services_AgrementType').val() || 0;
                let agrementDept = $('#ddl_services_Agrementdept').val() || 0;
                if (mainDep === "0") {
                    alert("Please select valid value for Department.");
                    return false;
                }
                if (agrementType === "0") {
                    alert("Please select valid value for Agreement Type.");
                    return false;
                }
                if (agrementDept === "0") {
                    alert("Please select valid value for Agreement Department.");
                    return false;
                }
                $.ajax({
                    type: "POST",
                    url: "AddDoctorAgreement.aspx/Load_services",
                    data: '{}',
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        let parsedData = JSON.parse(response.d);
                        let rows = '';
                        debugger
                        $.each(parsedData, function (key, item) {
                            var sale_rat = item.Sale_Rate;
                            if (sale_rat == null || sale_rat == 'null') {
                                sale_rat = 0;
                            }
                            rows += `<tr>
                                    <td><input type="checkbox" class="select-row"></td>
                                    <td style="display:none;"><input type="hidden" name="txtestid" class="txtestid" readonly value="${item.Item_ID}" ></td>
                                    <td style="display:none;"><input type="hidden" name="txtservices" class="txtservices" readonly value="${item.Item_Type}" ></td>
                                    <td ><input type="text" name="txtname" class="txtname" readonly value="${item.Description}"></td>
                                    <td><input type="text" name="actual-amount" readonly class="actual-amount" value="${sale_rat}"></td>                                
                                </tr>`;
                        });
                        $('#modalBodyservicesTable tbody').html(rows);
                        $('#modalservices').modal('show');
                        $('#selectAllservicesRows').on('change', function () {
                            let isChecked = $(this).is(':checked');
                            $('.select-row').prop('checked', isChecked);
                        });
                        $('#servicessearchDescription').on('keyup', function () {
                            let searchValue = $(this).val().toLowerCase();
                            $('#modalBodyservicesTable tbody tr').filter(function () {
                                $(this).toggle($(this).find('.txtname').val().toLowerCase().indexOf(searchValue) > -1);
                            });
                        });
                    },
                    failure: function () {
                        alert("Failed to load data.");
                    }
                });
            });

            // Append Selected Rows to Services Table
            $('#btnservicesModalOk').click(function () {
                let newRowsAdded = false;
                $('#modalBodyservicesTable tbody input.select-row:checked').each(function () {
                    debugger
                    let row = $(this).closest('tr');
                    let name = row.find('input[name="txtname"]').val();
                    let agremntType = $('#ddl_services_AgrementType option:selected').text();
                    let agremntDept = $('#ddl_services_Agrementdept option:selected').text();
                    let duplicateExists = false;
                    $('#tblResult_services tbody tr').each(function () {
                        let existingName = $(this).find('input[name="txtname"]').val();
                        let existingAgType = $(this).find('input[name="agremntType"]').val();
                        let existingAgDept = $(this).find('input[name="agremntDept"]').val();
                        if (existingName === name && existingAgType === agremntType && existingAgDept === agremntDept) {
                            duplicateExists = true;
                            return false;
                        }
                    });
                    if (duplicateExists) {
                        return;
                    }
                    let txtestid = row.find('input[name="txtestid"]').val();
                    let services = row.find('input[name="txtservices"]').val();
                    let rate = row.find('input[name="actual-amount"]').val() || 0;
                    let discount = 0;
                    let netAmount = rate;
                    let docShare = 0;
                    let hosShare = 0;
                    let agremntTypeId = $('#ddl_services_AgrementType option:selected').val();
                    let agremntDeptId = $('#ddl_services_Agrementdept option:selected').val();
                    let newRow = `<tr>
                                 <td style="display:none;"><input type="hidden" id="txtestid" value="${txtestid}" name="txtestid" /></td>
                                 <td style="display:none;"><input type="hidden" id="txtservices" name="txtservices" value="${services}" /></td>                  
                                 <td><input type="text" readonly id="txtname" name="txtname" value="${name}" /></td>
                                 <td style="display:none;"><input type="hidden" readonly id="agremntTypeId" name="agremntTypeId" value="${agremntTypeId}" /></td>
                                 <td><input type="text" readonly name="agremntType" id="agremntType" value="${agremntType}" /></td>
                                 <td style="display:none;"><input type="hidden"readonly id="agremntDeptId" name="agremntDeptId" value="${agremntDeptId}" /></td>
                                 <td><input type="text" readonly name="agremntDept" id="agremntDept" value="${agremntDept}" /></td>
                                 <td><input type="text" name="txtrate" readonly onchange="calculatedisc(this);" value="${rate}" /></td>
                                 <td><input type="text" id="txtdiscount" name="txtdiscount" onchange="calculatedisc(this);" value="${discount}" /></td>
                                 <td><input type="text" id="txtnetamount" name="txtnetamount" readonly value="${netAmount}" /></td>
                                 <td><input type="text" id="Txtdocshare" name="Txtdocshare" onchange="hosp_doc(this);" value="${docShare}" /></td>
                                 <td><input type="text" id="Txthocshare" name="Txthocshare" value="${hosShare}" readonly /></td>
                                 <td><a href="#" class="btn-primry delete-row-services" style="border-radius: 50%; display: inline-block; width: 27px; height: 24px; text-align: center"><i class="fa fa-trash" style="color: white;"></i></a></td>
                                 </tr>`;
                    $('#tblResult_services tbody').append(newRow);
                    newRowsAdded = true;
                });
                if (newRowsAdded) {
                    $('#ddlmaindep_Services').attr('disabled', true);
                }
                $('#modalservices').modal('hide');
            });
            // Delete Row from Services Table
            $(document).on('click', '.delete-row-services', function () {
                $(this).closest('tr').remove();
            });

            //***********************************************MRI Modal***********************************************
            $('#btnshowmirModal').click(function () {
                let mainDep = $('#ddlmaindep_MRI').val() || 0;
                let agrementType = $('#ddl_mri_AgrementType').val() || 0;
                let agrementDept = $('#ddl_mri_Agrementdept').val() || 0;
                if (mainDep === "0") {
                    alert("Please select valid value for Department.");
                    return false;
                }
                if (agrementType === "0") {
                    alert("Please select valid value for Agreement Type.");
                    return false;
                }
                if (agrementDept === "0") {
                    alert("Please select valid value for Agreement Department.");
                    return false;
                }
                $.ajax({
                    type: "POST",
                    url: "AddDoctorAgreement.aspx/Load_MRI",
                    data: '{}',
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        let parsedData = JSON.parse(response.d);
                        let rows = '';
                        debugger
                        $.each(parsedData, function (key, item) {
                            rows += `<tr>
                        <td><input type="checkbox" class="select-row"></td>
                        <td style="display:none;"><input type="hidden" name="txtestid" class="txtestid" readonly value="${item.Test_ID}" ></td>
                        <td style="display:none;"><input type="hidden" name="txtdep" class="txtdep" readonly value="${item.Main_Department}" ></td>
                        <td ><input type="text" name="txtname" class="txtname" readonly value="${item.Test_Name}"></td>
                        <td><input type="text" name="actual-amount" readonly class="actual-amount" value="${item.Rate}"></td>                                
                       </tr>`;
                        });
                        $('#modalBodyMRITable tbody').html(rows);
                        $('#modalMRI').modal('show');
                        $('#selectAllMRIRows').on('change', function () {
                            let isChecked = $(this).is(':checked');
                            $('.select-row').prop('checked', isChecked);
                        });
                        $('#MRIsearchDescription').on('keyup', function () {
                            let searchValue = $(this).val().toLowerCase();
                            $('#modalBodyMRITable tbody tr').filter(function () {
                                $(this).toggle($(this).find('.txtname').val().toLowerCase().indexOf(searchValue) > -1);
                            });
                        });
                    },
                    failure: function () {
                        alert("Failed to load data.");
                    }
                });
            });

            // Append Selected Rows to MRI Table
            $('#btnMRIModalOk').click(function () {
                let newRowsAdded = false;
                $('#modalBodyMRITable tbody input.select-row:checked').each(function () {
                    debugger
                    let row = $(this).closest('tr');
                    let name = row.find('input[name="txtname"]').val();
                    let agremntType = $('#ddl_mri_AgrementType option:selected').text();
                    let agremntDept = $('#ddl_mri_Agrementdept option:selected').text();
                    let duplicateExists = false;
                    $('#tblResult_mri tbody tr').each(function () {
                        let existingName = $(this).find('input[name="txtname"]').val();
                        let existingAgType = $(this).find('input[name="agremntType"]').val();
                        let existingAgDept = $(this).find('input[name="agremntDept"]').val();
                        if (existingName === name && existingAgType === agremntType && existingAgDept === agremntDept) {
                            duplicateExists = true;
                            return false;
                        }
                    });
                    if (duplicateExists) {
                        //console.log("Duplicate MRI TAB entry skipped:", name, agremntType, agremntDept);
                        //alert("This entry already exists in the table.");
                        return;
                    }
                    let txtestid = row.find('input[name="txtestid"]').val();
                    let dep = row.find('input[name="txtdep"]').val();
                    let rate = row.find('input[name="actual-amount"]').val() || 0;
                    let discount = 0;
                    let netAmount = rate;
                    let docShare = 0;
                    let hosShare = 0;
                    let agremntTypeId = $('#ddl_mri_AgrementType option:selected').val();
                    let agremntDeptId = $('#ddl_mri_Agrementdept option:selected').val();
                    let newRow = `<tr>
                    <td style="display:none;"><input type="hidden" id="txtestid" value="${txtestid}" name="txtestid" /></td>
                    <td style="display:none;"><input type="hidden" id="txtdep" name="txtdep" value="${dep}" /></td>                  
                    <td><input type="text" readonly id="txtname" name="txtname" value="${name}" /></td>
                    <td style="display:none;"><input type="hidden" readonly id="agremntTypeId" name="agremntTypeId" value="${agremntTypeId}" /></td>
                    <td><input type="text" readonly name="agremntType" id="agremntType" value="${agremntType}" /></td>
                    <td style="display:none;"><input type="hidden"readonly id="agremntDeptId" name="agremntDeptId" value="${agremntDeptId}" /></td>
                    <td><input type="text" readonly name="agremntDept" id="agremntDept" value="${agremntDept}" /></td>
                    <td><input type="text" name="txtrate" readonly onchange="calculatedisc(this);" value="${rate}" /></td>
                    <td><input type="text" id="txtdiscount" name="txtdiscount" onchange="calculatedisc(this);" value="${discount}" /></td>
                    <td><input type="text" id="txtnetamount" name="txtnetamount" readonly value="${netAmount}" /></td>
                    <td><input type="text" id="Txtdocshare" name="Txtdocshare" onchange="hosp_doc(this);" value="${docShare}" /></td>
                    <td><input type="text" id="Txthocshare" name="Txthocshare" value="${hosShare}" readonly /></td>
                    <td><a href="#" class="btn-primry delete-row-MRI" style="border-radius: 50%; display: inline-block; width: 27px; height: 24px; text-align: center"><i class="fa fa-trash" style="color: white;"></i></a></td>
             </tr>`;
                    $('#tblResult_mri tbody').append(newRow);
                    newRowsAdded = true;
                });
                if (newRowsAdded) {
                    $('#ddlmaindep_MRI').attr('disabled', true);
                }
                $('#modalMRI').modal('hide');
            });
            // Delete Row from MRI Table
            $(document).on('click', '.delete-row-MRI', function () {
                $(this).closest('tr').remove();
            });

            //***********************************************Blood Bank Modal***********************************************
            $('#btnshowbloodbankModal').click(function () {
                let mainDep = $('#ddlmaindep_bloodbank').val() || 0;
                let agrementType = $('#ddl_bloodbank_AgrementType').val() || 0;
                let agrementDept = $('#ddl_bloodbank_Agrementdept').val() || 0;
                if (mainDep === "0") {
                    alert("Please select valid value for Department.");
                    return false;
                }
                if (agrementType === "0") {
                    alert("Please select valid value for Agreement Type.");
                    return false;
                }
                if (agrementDept === "0") {
                    alert("Please select valid value for Agreement Department.");
                    return false;
                }
                $.ajax({
                    type: "POST",
                    url: "AddDoctorAgreement.aspx/Load_Bloodbank",
                    data: '{}',
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        let parsedData = JSON.parse(response.d);
                        let rows = '';
                        debugger
                        $.each(parsedData, function (key, item) {
                            rows += `<tr>
                                    <td><input type="checkbox" class="select-row"></td>
                                    <td style="display:none;"><input type="hidden" name="txtestid" class="txtestid" readonly value="${item.Test_ID}" ></td>
                                    <td style="display:none;"><input type="hidden" name="txtdep" class="txtdep" readonly value="${item.Main_Department}" ></td>
                                    <td ><input type="text" name="txtname" class="txtname" readonly value="${item.Test_Name}"></td>
                                    <td><input type="text" name="actual-amount" readonly class="actual-amount" value="${item.Rate}"></td>                                
                                   </tr>`;
                        });
                        $('#modalBodyBloodbankTable tbody').html(rows);
                        $('#modalBloodbank').modal('show');
                        $('#selectAllBloodbankRows').on('change', function () {
                            let isChecked = $(this).is(':checked');
                            $('.select-row').prop('checked', isChecked);
                        });
                        $('#BloodbanksearchDescription').on('keyup', function () {
                            let searchValue = $(this).val().toLowerCase();
                            $('#modalBodyBloodbankTable tbody tr').filter(function () {
                                $(this).toggle($(this).find('.txtname').val().toLowerCase().indexOf(searchValue) > -1);
                            });
                        });
                    },
                    failure: function () {
                        alert("Failed to load data.");
                    }
                });
            });

            // Append Selected Rows to Blood Bank Table
            $('#btnBloodbankModalOk').click(function () {
                let newRowsAdded = false;
                $('#modalBodyBloodbankTable tbody input.select-row:checked').each(function () {
                    debugger
                    let row = $(this).closest('tr');
                    let name = row.find('input[name="txtname"]').val();
                    let agremntType = $('#ddl_bloodbank_AgrementType option:selected').text();
                    let agremntDept = $('#ddl_bloodbank_Agrementdept option:selected').text();
                    let duplicateExists = false;
                    $('#tblResult_bloodbank tbody tr').each(function () {
                        let existingName = $(this).find('input[name="txtname"]').val();
                        let existingAgType = $(this).find('input[name="agremntType"]').val();
                        let existingAgDept = $(this).find('input[name="agremntDept"]').val();
                        if (existingName === name && existingAgType === agremntType && existingAgDept === agremntDept) {
                            duplicateExists = true;
                            return false;
                        }
                    });
                    if (duplicateExists) {
                        //console.log("Duplicate Blood Bank TAB entry skipped:", name, agremntType, agremntDept);
                        //alert("This entry already exists in the table.");
                        return;
                    }
                    let txtestid = row.find('input[name="txtestid"]').val();
                    let dep = row.find('input[name="txtdep"]').val();
                    let rate = row.find('input[name="actual-amount"]').val() || 0;
                    let discount = 0;
                    let netAmount = rate;
                    let docShare = 0;
                    let hosShare = 0;
                    let agremntTypeId = $('#ddl_bloodbank_AgrementType option:selected').val();
                    let agremntDeptId = $('#ddl_bloodbank_Agrementdept option:selected').val();
                    let newRow = `<tr>
                                <td style="display:none;"><input type="hidden" id="txtestid" value="${txtestid}" name="txtestid" /></td>
                                <td style="display:none;"><input type="hidden" id="txtdep" name="txtdep" value="${dep}" /></td>                  
                                <td><input type="text" readonly id="txtname" name="txtname" value="${name}" /></td>
                                <td style="display:none;"><input type="hidden" readonly id="agremntTypeId" name="agremntTypeId" value="${agremntTypeId}" /></td>
                                <td><input type="text" readonly name="agremntType" id="agremntType" value="${agremntType}" /></td>
                                <td style="display:none;"><input type="hidden"readonly id="agremntDeptId" name="agremntDeptId" value="${agremntDeptId}" /></td>
                                <td><input type="text" readonly name="agremntDept" id="agremntDept" value="${agremntDept}" /></td>
                                <td><input type="text" name="txtrate" readonly onchange="calculatedisc(this);" value="${rate}" /></td>
                                <td><input type="text" id="txtdiscount" name="txtdiscount" onchange="calculatedisc(this);" value="${discount}" /></td>
                                <td><input type="text" id="txtnetamount" name="txtnetamount" readonly value="${netAmount}" /></td>
                                <td><input type="text" id="Txtdocshare" name="Txtdocshare" onchange="hosp_doc(this);" value="${docShare}" /></td>
                                <td><input type="text" id="Txthocshare" name="Txthocshare" value="${hosShare}" readonly /></td>
                                <td><a href="#" class="btn-primry delete-row-bloodbank" style="border-radius: 50%; display: inline-block; width: 27px; height: 24px; text-align: center"><i class="fa fa-trash" style="color: white;"></i></a></td>
                         </tr>`;
                    $('#tblResult_bloodbank tbody').append(newRow);
                    newRowsAdded = true;
                });
                if (newRowsAdded) {
                    $('#ddlmaindep_bloodbank').attr('disabled', true);
                }
                $('#modalBloodbank').modal('hide');
            });
            // Delete Row from Blood Bank Table
            $(document).on('click', '.delete-row-bloodbank', function () {
                $(this).closest('tr').remove();
            });

            //***********************************************CT Scan Modal***********************************************
            $('#btnshowCTScanModal').click(function () {
                let mainDep = $('#ddlmaindep_ctscan').val() || 0;
                let agrementType = $('#ddl_CTScan_AgrementType').val() || 0;
                let agrementDept = $('#ddl_CTScan_Agrementdept').val() || 0;
                if (mainDep === "0") {
                    alert("Please select valid value for Department.");
                    return false;
                }
                if (agrementType === "0") {
                    alert("Please select valid value for Agreement Type.");
                    return false;
                }
                if (agrementDept === "0") {
                    alert("Please select valid value for Agreement Department.");
                    return false;
                }
                $.ajax({
                    type: "POST",
                    url: "AddDoctorAgreement.aspx/Load_CTScan",
                    data: '{}',
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        let parsedData = JSON.parse(response.d);
                        let rows = '';
                        debugger
                        $.each(parsedData, function (key, item) {
                            rows += `<tr>
                        <td><input type="checkbox" class="select-row"></td>
                        <td style="display:none;"><input type="hidden" name="txtestid" class="txtestid" readonly value="${item.Test_ID}" ></td>
                        <td style="display:none;"><input type="hidden" name="txtdep" class="txtdep" readonly value="${item.Main_Department}" ></td>
                        <td ><input type="text" name="txtname" class="txtname" readonly value="${item.Test_Name}"></td>
                        <td><input type="text" name="actual-amount" readonly class="actual-amount" value="${item.Rate}"></td>                                
                     </tr>`;
                        });
                        $('#modalBodyctscanTable tbody').html(rows);
                        $('#modalctscan').modal('show');
                        $('#selectAllctscanRows').on('change', function () {
                            let isChecked = $(this).is(':checked');
                            $('.select-row').prop('checked', isChecked);
                        });
                        $('#ctscansearchDescription').on('keyup', function () {
                            let searchValue = $(this).val().toLowerCase();
                            $('#modalBodyctscanTable tbody tr').filter(function () {
                                $(this).toggle($(this).find('.txtname').val().toLowerCase().indexOf(searchValue) > -1);
                            });
                        });
                    },
                    failure: function () {
                        alert("Failed to load data.");
                    }
                });
            });

            // Append Selected Rows to ctscan Table
            $('#btnctscanModalOk').click(function () {
                let newRowsAdded = false;
                $('#modalBodyctscanTable tbody input.select-row:checked').each(function () {
                    debugger
                    let row = $(this).closest('tr');
                    let name = row.find('input[name="txtname"]').val();
                    let agremntType = $('#ddl_CTScan_AgrementType option:selected').text();
                    let agremntDept = $('#ddl_CTScan_Agrementdept option:selected').text();
                    let duplicateExists = false;
                    $('#tblResult_ctscan tbody tr').each(function () {
                        let existingName = $(this).find('input[name="txtname"]').val();
                        let existingAgType = $(this).find('input[name="agremntType"]').val();
                        let existingAgDept = $(this).find('input[name="agremntDept"]').val();
                        if (existingName === name && existingAgType === agremntType && existingAgDept === agremntDept) {
                            duplicateExists = true;
                            return false;
                        }
                    });
                    if (duplicateExists) {
                        //console.log("Duplicate ctscan TAB entry skipped:", name, agremntType, agremntDept);
                        //alert("This entry already exists in the table.");
                        return;
                    }
                    let txtestid = row.find('input[name="txtestid"]').val();
                    let dep = row.find('input[name="txtdep"]').val();
                    let rate = row.find('input[name="actual-amount"]').val() || 0;
                    let discount = 0;
                    let netAmount = rate;
                    let docShare = 0;
                    let hosShare = 0;
                    let agremntTypeId = $('#ddl_CTScan_AgrementType option:selected').val();
                    let agremntDeptId = $('#ddl_CTScan_Agrementdept option:selected').val();
                    let newRow = `<tr>
                         <td style="display:none;"><input type="hidden" id="txtestid" value="${txtestid}" name="txtestid" /></td>
                         <td style="display:none;"><input type="hidden" id="txtdep" name="txtdep" value="${dep}" /></td>                  
                         <td><input type="text" readonly id="txtname" name="txtname" value="${name}" /></td>
                         <td style="display:none;"><input type="hidden" readonly id="agremntTypeId" name="agremntTypeId" value="${agremntTypeId}" /></td>
                         <td><input type="text" readonly name="agremntType" id="agremntType" value="${agremntType}" /></td>
                         <td style="display:none;"><input type="hidden"readonly id="agremntDeptId" name="agremntDeptId" value="${agremntDeptId}" /></td>
                         <td><input type="text" readonly name="agremntDept" id="agremntDept" value="${agremntDept}" /></td>
                         <td><input type="text" name="txtrate" readonly onchange="calculatedisc(this);" value="${rate}" /></td>
                         <td><input type="text" id="txtdiscount" name="txtdiscount" onchange="calculatedisc(this);" value="${discount}" /></td>
                         <td><input type="text" id="txtnetamount" name="txtnetamount" readonly value="${netAmount}" /></td>
                         <td><input type="text" id="Txtdocshare" name="Txtdocshare" onchange="hosp_doc(this);" value="${docShare}" /></td>
                         <td><input type="text" id="Txthocshare" name="Txthocshare" value="${hosShare}" readonly /></td>
                         <td><a href="#" class="btn-primry delete-row-ctscan" style="border-radius: 50%; display: inline-block; width: 27px; height: 24px; text-align: center"><i class="fa fa-trash" style="color: white;"></i></a></td>
                           </tr>`;
                    $('#tblResult_ctscan tbody').append(newRow);
                    newRowsAdded = true;
                });
                if (newRowsAdded) {
                    $('#ddlmaindep_ctscan').attr('disabled', true);
                }
                $('#modalctscan').modal('hide');
            });
            // Delete Row from ctscan Table
            $(document).on('click', '.delete-row-ctscan', function () {
                $(this).closest('tr').remove();
            });

            //***********************************************Ultra Sound Modal***********************************************
            $('#btnshowultrsoundModal').click(function () {
                let mainDep = $('#ddlmaindep_Ultra').val() || 0;
                let agrementType = $('#ddl_ultrasounds_AgrementType').val() || 0;
                let agrementDept = $('#ddl_ultrasounds_Agrementdept').val() || 0;
                if (mainDep === "0") {
                    alert("Please select valid value for Department.");
                    return false;
                }
                if (agrementType === "0") {
                    alert("Please select valid value for Agreement Type.");
                    return false;
                }
                if (agrementDept === "0") {
                    alert("Please select valid value for Agreement Department.");
                    return false;
                }
                $.ajax({
                    type: "POST",
                    url: "AddDoctorAgreement.aspx/Load_ultrasound",
                    data: '{}',
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        let parsedData = JSON.parse(response.d);
                        let rows = '';
                        debugger
                        $.each(parsedData, function (key, item) {
                            rows += `<tr>
                                    <td><input type="checkbox" class="select-row"></td>
                                    <td style="display:none;"><input type="hidden" name="txtestid" class="txtestid" readonly value="${item.Test_ID}" ></td>
                                    <td style="display:none;"><input type="hidden" name="txtdep" class="txtdep" readonly value="${item.Main_Department}" ></td>
                                    <td ><input type="text" name="txtname" class="txtname" readonly value="${item.Test_Name}"></td>
                                    <td><input type="text" name="actual-amount" readonly class="actual-amount" value="${item.Rate}"></td>                                
                                 </tr>`;
                        });
                        $('#modalBodyultrasoundTable tbody').html(rows);
                        $('#modalultrasound').modal('show');
                        $('#selectAllultrasoundRows').on('change', function () {
                            let isChecked = $(this).is(':checked');
                            $('.select-row').prop('checked', isChecked);
                        });
                        $('#ultrasoundsearchDescription').on('keyup', function () {
                            let searchValue = $(this).val().toLowerCase();
                            $('#modalBodyultrasoundTable tbody tr').filter(function () {
                                $(this).toggle($(this).find('.txtname').val().toLowerCase().indexOf(searchValue) > -1);
                            });
                        });
                    },
                    failure: function () {
                        alert("Failed to load data.");
                    }
                });
            });

            // Append Selected Rows to Ultra Sound Table
            $('#btnultrasoundModalOk').click(function () {
                let newRowsAdded = false;
                $('#modalBodyultrasoundTable tbody input.select-row:checked').each(function () {
                    debugger
                    let row = $(this).closest('tr');
                    let name = row.find('input[name="txtname"]').val();
                    let agremntType = $('#ddl_ultrasounds_AgrementType option:selected').text();
                    let agremntDept = $('#ddl_ultrasounds_Agrementdept option:selected').text();
                    let duplicateExists = false;
                    $('#tblResult_ultra tbody tr').each(function () {
                        let existingName = $(this).find('input[name="txtname"]').val();
                        let existingAgType = $(this).find('input[name="agremntType"]').val();
                        let existingAgDept = $(this).find('input[name="agremntDept"]').val();
                        if (existingName === name && existingAgType === agremntType && existingAgDept === agremntDept) {
                            duplicateExists = true;
                            return false;
                        }
                    });
                    if (duplicateExists) {
                        //console.log("Duplicate Ultra Sound TAB entry skipped:", name, agremntType, agremntDept);
                        //alert("This entry already exists in the table.");
                        return;
                    }
                    let txtestid = row.find('input[name="txtestid"]').val();
                    let dep = row.find('input[name="txtdep"]').val();
                    let rate = row.find('input[name="actual-amount"]').val() || 0;
                    let discount = 0;
                    let netAmount = rate;
                    let docShare = 0;
                    let hosShare = 0;
                    let agremntTypeId = $('#ddl_ultrasounds_AgrementType option:selected').val();
                    let agremntDeptId = $('#ddl_ultrasounds_Agrementdept option:selected').val();
                    let newRow = `<tr>
                    <td style="display:none;"><input type="hidden" id="txtestid" value="${txtestid}" name="txtestid" /></td>
                    <td style="display:none;"><input type="hidden" id="txtdep" name="txtdep" value="${dep}" /></td>                  
                    <td><input type="text" readonly id="txtname" name="txtname" value="${name}" /></td>
                    <td style="display:none;"><input type="hidden" readonly id="agremntTypeId" name="agremntTypeId" value="${agremntTypeId}" /></td>
                    <td><input type="text" readonly name="agremntType" id="agremntType" value="${agremntType}" /></td>
                    <td style="display:none;"><input type="hidden"readonly id="agremntDeptId" name="agremntDeptId" value="${agremntDeptId}" /></td>
                    <td><input type="text" readonly name="agremntDept" id="agremntDept" value="${agremntDept}" /></td>
                    <td><input type="text" name="txtrate" readonly onchange="calculatedisc(this);" value="${rate}" /></td>
                    <td><input type="text" id="txtdiscount" name="txtdiscount" onchange="calculatedisc(this);" value="${discount}" /></td>
                    <td><input type="text" id="txtnetamount" name="txtnetamount" readonly value="${netAmount}" /></td>
                    <td><input type="text" id="Txtdocshare" name="Txtdocshare" onchange="hosp_doc(this);" value="${docShare}" /></td>
                    <td><input type="text" id="Txthocshare" name="Txthocshare" value="${hosShare}" readonly /></td>
                    <td><a href="#" class="btn-primry delete-row-ultrasound" style="border-radius: 50%; display: inline-block; width: 27px; height: 24px; text-align: center"><i class="fa fa-trash" style="color: white;"></i></a></td>
                      </tr>`;
                    $('#tblResult_ultra tbody').append(newRow);
                    newRowsAdded = true;
                });
                if (newRowsAdded) {
                    $('#ddlmaindep_Ultra').attr('disabled', true);
                }
                $('#modalultrasound').modal('hide');
            });
            // Delete Row from Ultra Sound Table
            $(document).on('click', '.delete-row-ultrasound', function () {
                $(this).closest('tr').remove();
            });


            //***********************************************X-RAY Modal***********************************************
            $('#btnshowxrayModal').click(function () {
                let mainDep = $('#ddlmaindep_xray').val() || 0;
                let agrementType = $('#ddl_xray_AgrementType').val() || 0;
                let agrementDept = $('#ddl_xray_Agrementdept').val() || 0;
                if (mainDep === "0") {
                    alert("Please select valid value for Department.");
                    return false;
                }
                if (agrementType === "0") {
                    alert("Please select valid value for Agreement Type.");
                    return false;
                }
                if (agrementDept === "0") {
                    alert("Please select valid value for Agreement Department.");
                    return false;
                }
                $.ajax({
                    type: "POST",
                    url: "AddDoctorAgreement.aspx/LoadLabTests_xray",
                    data: '{}',
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        let parsedData = JSON.parse(response.d);
                        let rows = '';
                        debugger
                        $.each(parsedData, function (key, item) {
                            rows += `<tr>
                        <td><input type="checkbox" class="select-row"></td>
                        <td style="display:none;"><input type="hidden" name="txtestid" class="txtestid" readonly value="${item.Test_ID}" ></td>
                        <td style="display:none;"><input type="hidden" name="txtdep" class="txtdep" readonly value="${item.Main_Department}" ></td>
                        <td ><input type="text" name="txtname" class="txtname" readonly value="${item.Test_Name}"></td>
                        <td><input type="text" name="actual-amount" readonly class="actual-amount" value="${item.Rate}"></td>                                
                      </tr>`;
                        });
                        $('#modalBodyxrayTable tbody').html(rows);
                        $('#modalxray').modal('show');
                        $('#selectAllxrayRows').on('change', function () {
                            let isChecked = $(this).is(':checked');
                            $('.select-row').prop('checked', isChecked);
                        });
                        $('#xraysearchDescription').on('keyup', function () {
                            let searchValue = $(this).val().toLowerCase();
                            $('#modalBodyxrayTable tbody tr').filter(function () {
                                $(this).toggle($(this).find('.txtname').val().toLowerCase().indexOf(searchValue) > -1);
                            });
                        });
                    },
                    failure: function () {
                        alert("Failed to load data.");
                    }
                });
            });

            // Append Selected Rows to X-RAY Table
            $('#btnxrayModalOk').click(function () {
                let newRowsAdded = false;
                $('#modalBodyxrayTable tbody input.select-row:checked').each(function () {
                    debugger
                    let row = $(this).closest('tr');
                    let name = row.find('input[name="txtname"]').val();
                    let agremntType = $('#ddl_xray_AgrementType option:selected').text();
                    let agremntDept = $('#ddl_xray_Agrementdept option:selected').text();
                    let duplicateExists = false;
                    $('#tblResults tbody tr').each(function () {
                        let existingName = $(this).find('input[name="txtname"]').val();
                        let existingAgType = $(this).find('input[name="agremntType"]').val();
                        let existingAgDept = $(this).find('input[name="agremntDept"]').val();
                        if (existingName === name && existingAgType === agremntType && existingAgDept === agremntDept) {
                            duplicateExists = true;
                            return false;
                        }
                    });
                    if (duplicateExists) {
                        //console.log("Duplicate X Ray TAB entry skipped:", name, agremntType, agremntDept);
                        //alert("This entry already exists in the table.");
                        return;
                    }
                    let txtestid = row.find('input[name="txtestid"]').val();
                    let dep = row.find('input[name="txtdep"]').val();
                    let rate = row.find('input[name="actual-amount"]').val() || 0;
                    let discount = 0;
                    let netAmount = rate;
                    let docShare = 0;
                    let hosShare = 0;
                    let agremntTypeId = $('#ddl_xray_AgrementType option:selected').val();
                    let agremntDeptId = $('#ddl_xray_Agrementdept option:selected').val();
                    let newRow = `<tr>
                                <td style="display:none;"><input type="hidden" id="txtestid" value="${txtestid}" name="txtestid" /></td>
                                <td style="display:none;"><input type="hidden" id="txtdep" name="txtdep" value="${dep}" /></td>                  
                                <td><input type="text" readonly id="txtname" name="txtname" value="${name}" /></td>
                                <td style="display:none;"><input type="hidden" readonly id="agremntTypeId" name="agremntTypeId" value="${agremntTypeId}" /></td>
                                <td><input type="text" readonly name="agremntType" id="agremntType" value="${agremntType}" /></td>
                                <td style="display:none;"><input type="hidden"readonly id="agremntDeptId" name="agremntDeptId" value="${agremntDeptId}" /></td>
                                <td><input type="text" readonly name="agremntDept" id="agremntDept" value="${agremntDept}" /></td>
                                <td><input type="text" name="txtrate" readonly onchange="calculatedisc(this);" value="${rate}" /></td>
                                <td><input type="text" id="txtdiscount" readonly name="txtdiscount" onchange="calculatedisc(this);" value="${discount}" /></td>
                                <td><input type="text" id="txtnetamount" name="txtnetamount" readonly value="${netAmount}" /></td>
                                <td><input type="text" id="Txtdocshare" name="Txtdocshare" onchange="hosp_doc(this);" value="${docShare}" /></td>
                                <td><input type="text" id="Txthocshare" name="Txthocshare" value="${hosShare}" readonly /></td>
                                <td><a href="#" class="btn-primry delete-row-xray" style="border-radius: 50%; display: inline-block; width: 27px; height: 24px; text-align: center"><i class="fa fa-trash" style="color: white;"></i></a></td>
                                  </tr>`;
                    $('#tblResults tbody').append(newRow);
                    newRowsAdded = true;
                });
                if (newRowsAdded) {
                    $('#ddlmaindep_xray').attr('disabled', true);
                }
                $('#modalxray').modal('hide');
            });
            // Delete Row from X-RAY Table
            $(document).on('click', '.delete-row-xray', function () {
                $(this).closest('tr').remove();
            });


            //***********************************************Lab Test Modal***********************************************
            $('#btnshowLabModal').click(function () {
                let mainDep = $('#ddlmaindep').val() || 0;
                let agrementType = $('#ddl_labtest_AgrementType').val() || 0;
                let agrementDept = $('#ddl_labtest_Agrementdept').val() || 0;
                if (mainDep === "0") {
                    alert("Please select valid value for Department.");
                    return false;
                }
                if (agrementType === "0") {
                    alert("Please select valid value for Agreement Type.");
                    return false;
                }
                if (agrementDept === "0") {
                    alert("Please select valid value for Agreement Department.");
                    return false;
                }
                $.ajax({
                    type: "POST",
                    url: "AddDoctorAgreement.aspx/LoadLabTests",
                    data: '{}',
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        let parsedData = JSON.parse(response.d);
                        let rows = '';
                        debugger
                        $.each(parsedData, function (key, item) {
                            rows += `<tr>
                                    <td><input type="checkbox" class="select-row"></td>
                                    <td style="display:none;"><input type="hidden" name="txtestid" class="txtestid" readonly value="${item.Test_ID}" ></td>
                                    <td style="display:none;"><input type="hidden" name="txtdep" class="txtdep" readonly value="${item.Main_Department}" ></td>
                                    <td ><input type="text" name="txtname" class="txtname" readonly value="${item.Test_Name}"></td>
                                    <td><input type="text" name="actual-amount" readonly class="actual-amount" value="${item.Rate}"></td>                                
                                  </tr>`;
                        });
                        $('#modalBodyLabTable tbody').html(rows);
                        $('#modalLab').modal('show');
                        // Select All functionality in Modal
                        $('#selectAllLabRows').on('change', function () {
                            let isChecked = $(this).is(':checked');
                            $('.select-row').prop('checked', isChecked);
                        });
                        // Search functionality in Modal
                        $('#LabsearchDescription').on('keyup', function () {
                            let searchValue = $(this).val().toLowerCase();
                            $('#modalBodyLabTable tbody tr').filter(function () {
                                $(this).toggle($(this).find('.txtname').val().toLowerCase().indexOf(searchValue) > -1);
                            });
                        });
                    },
                    failure: function () {
                        alert("Failed to load data.");
                    }
                });
            });

            // Append Selected Rows to Lab Test Table
            $('#btnLabModalOk').click(function () {
                let newRowsAdded = false;
                $('#modalBodyLabTable tbody input.select-row:checked').each(function () {
                    debugger
                    let row = $(this).closest('tr');
                    let name = row.find('input[name="txtname"]').val();
                    let agremntType = $('#ddl_labtest_AgrementType option:selected').text();
                    let agremntDept = $('#ddl_labtest_Agrementdept option:selected').text();
                    let duplicateExists = false;
                    $('#tblResult tbody tr').each(function () {
                        let existingName = $(this).find('input[name="txtname"]').val();
                        let existingAgType = $(this).find('input[name="agremntType"]').val();
                        let existingAgDept = $(this).find('input[name="agremntDept"]').val();
                        if (existingName === name && existingAgType === agremntType && existingAgDept === agremntDept) {
                            duplicateExists = true;
                            return false;
                        }
                    });
                    if (duplicateExists) {
                        //console.log("Duplicate LAB TAB entry skipped:", name, agremntType, agremntDept);
                        //alert("This entry already exists in the table.");
                        return;
                    }
                    let txtestid = row.find('input[name="txtestid"]').val();
                    let dep = row.find('input[name="txtdep"]').val();
                    let rate = row.find('input[name="actual-amount"]').val() || 0;
                    let discount = 0;
                    let netAmount = rate;
                    let docShare = 0;
                    let hosShare = 0;
                    let agremntTypeId = $('#ddl_labtest_AgrementType option:selected').val();
                    let agremntDeptId = $('#ddl_labtest_Agrementdept option:selected').val();
                    let newRow = `<tr>
                    <td style="display:none;"><input type="hidden" id="txtestid" value="${txtestid}" name="txtestid" /></td>
                    <td style="display:none;"><input type="hidden" id="txtdep" name="txtdep" value="${dep}" /></td>                  
                    <td><input type="text" readonly id="txtname" name="txtname" value="${name}" /></td>
                    <td style="display:none;"><input type="hidden" readonly id="agremntTypeId" name="agremntTypeId" value="${agremntTypeId}" /></td>
                    <td><input type="text" readonly name="agremntType" id="agremntType" value="${agremntType}" /></td>
                    <td style="display:none;"><input type="hidden"readonly id="agremntDeptId" name="agremntDeptId" value="${agremntDeptId}" /></td>
                    <td><input type="text" readonly name="agremntDept" id="agremntDept" value="${agremntDept}" /></td>
                    <td><input type="text" name="txtrate" readonly onchange="calculatedisc(this);" value="${rate}" /></td>
                    <td><input type="text" id="txtdiscount" name="txtdiscount" onchange="calculatedisc(this);" value="${discount}" /></td>
                    <td><input type="text" id="txtnetamount" name="txtnetamount" readonly value="${netAmount}" /></td>
                    <td><input type="text" id="Txtdocshare" name="Txtdocshare" onchange="hosp_doc(this);" value="${docShare}" /></td>
                    <td><input type="text" id="Txthocshare" name="Txthocshare" value="${hosShare}" readonly /></td>
                    <td><a href="#" class="btn-primry delete-row-lab" style="border-radius: 50%; display: inline-block; width: 27px; height: 24px; text-align: center"><i class="fa fa-trash" style="color: white;"></i></a></td>
                      </tr>`;
                    $('#tblResult tbody').append(newRow);
                    newRowsAdded = true;
                });
                if (newRowsAdded) {
                    $('#ddlmaindep').attr('disabled', true);
                }
                $('#modalLab').modal('hide');
            });
            // Delete Row from Lab Table
            $(document).on('click', '.delete-row-lab', function () {
                $(this).closest('tr').remove();
            });


            //***********************************************Opd Item Modal***********************************************
            $('#btnshowopdModal').click(function () {
                let mainDep = $('#ddlmaindep_Opd').val() || 0;
                let agrementType = $('#ddl_Opd_AgrementType').val() || 0;
                let agrementDept = $('#ddl_Opd_Agrementdept').val() || 0;
                if (mainDep === "0") {
                    alert("Please select valid value for Department.");
                    return false;
                }
                if (agrementType === "0") {
                    alert("Please select valid value for Agreement Type.");
                    return false;
                }
                if (agrementDept === "0") {
                    alert("Please select valid value for Agreement Department.");
                    return false;
                }

                $.ajax({
                    type: "POST",
                    url: "AddDoctorAgreement.aspx/load_Opd",
                    data: '{}',
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        let parsedData = JSON.parse(response.d);
                        let rows = '';
                        $.each(parsedData, function (key, item) {
                            rows += `<tr>
                                <td><input type="checkbox" class="select-row"></td>
                                <td style="display:none;"><input type="hidden" name="txtestid" class="txtestid" readonly value="0"></td>
                                <td style="display:none;"><input type="hidden" name="txtdep" class="txtdep" readonly value="${item.DataValue_Description}" ></td>
                                <td ><input type="text" name="txtname" class="txtname" readonly value="${item.DataValue_Description}" ></td>
                                <td><input type="text" name="actual-amount" class="actual-amount" value="0"></td>                                
                            </tr>`;
                        });
                        $('#modalBodyOPDTable tbody').html(rows);
                        $('#modalOpd').modal('show');
                        // Select All functionality
                        $('#selectAllOpdRows').on('change', function () {
                            let isChecked = $(this).is(':checked');
                            $('.select-row').prop('checked', isChecked);
                        });
                        // Search functionality
                        $('#OpdsearchDescription').on('keyup', function () {
                            let searchValue = $(this).val().toLowerCase();
                            $('#modalBodyOPDTable tbody tr').filter(function () {
                                $(this).toggle($(this).find('.txtname').val().toLowerCase().indexOf(searchValue) > -1);
                            });
                        });
                    },
                    failure: function () {
                        alert("Failed to load data.");
                    }
                });
            });

            // Append Selected Rows to OPD Table
            $('#btnOpdModalOk').click(function () {
                let newRowsAdded = false;
                $('#modalBodyOPDTable tbody input.select-row:checked').each(function () {
                    let row = $(this).closest('tr');
                    let name = row.find('input[name="txtname"]').val();
                    let agremntType = $('#ddl_Opd_AgrementType option:selected').text();
                    let agremntDept = $('#ddl_Opd_Agrementdept option:selected').text();
                    let duplicateExists = false;
                    $('#tblResult_Opd tbody tr').each(function () {
                        let existingName = $(this).find('input[name="txtname"]').val();
                        let existingAgType = $(this).find('input[name="agremntType"]').val();
                        let existingAgDept = $(this).find('input[name="agremntDept"]').val();
                        if (existingName === name && existingAgType === agremntType && existingAgDept === agremntDept) {
                            duplicateExists = true;
                            return false;
                        }
                    });

                    if (duplicateExists) {
                        //console.log("Duplicate OPD TAB entry skipped:", name, agremntType, agremntDept);
                        //alert("This entry already exists in the table.");
                        return;
                    }
                    let txtestid = row.find('input[name="txtestid"]').val();
                    let dep = row.find('input[name="txtdep"]').val();
                    let rate = row.find('input[name="actual-amount"]').val() || 0;
                    let discount = 0;
                    let netAmount = rate;
                    let docShare = 0;
                    let hosShare = 0;
                    let agremntTypeId = $('#ddl_Opd_AgrementType option:selected').val();
                    let agremntDeptId = $('#ddl_Opd_Agrementdept option:selected').val();
                    let newRow = `<tr>
                    <td style="display:none;"><input type="hidden" id="txtestid" value="${txtestid}" name="txtestid" /></td>
                    <td style="display:none;"><input type="hidden" id="txtdep" name="txtdep" value="${dep}" /></td>
                    <td><input type="text" readonly id="txtname" name="txtname" value="${name}" /></td>
                    <td style="display:none;"><input type="hidden" readonly id="agremntTypeId" name="agremntTypeId" value="${agremntTypeId}" /></td>
                    <td><input type="text" readonly name="agremntType" id="agremntType" value="${agremntType}" /></td>
                    <td style="display:none;"><input type="hidden"readonly id="agremntDeptId" name="agremntDeptId" value="${agremntDeptId}" /></td>
                    <td><input type="text" readonly name="agremntDept" id="agremntDept" value="${agremntDept}" /></td>
                    <td><input type="text" name="txtrate" onchange="calculatedisc(this);" value="${rate}" /></td>
                    <td><input type="text" id="txtdiscount" name="txtdiscount" onchange="calculatedisc(this);" value="${discount}" /></td>
                    <td><input type="text" id="txtnetamount" readonly name="txtnetamount" value="${netAmount}" /></td>
                    <td><input type="text" id="Txtdocshare" name="Txtdocshare" onchange="hosp_doc(this);" value="${docShare}" /></td>
                    <td><input type="text" id="Txthocshare" name="Txthocshare" value="${hosShare}" readonly /></td>
                    <td><a href="#" class="btn-primry delete-row-opd" style="border-radius: 50%; display: inline-block; width: 27px; height: 24px; text-align: center"><i class="fa fa-trash" style="color: white;"></i></a></td>
                </tr>`;

                    $('#tblResult_Opd tbody').append(newRow);
                    newRowsAdded = true;
                });
                if (newRowsAdded) {
                    $('#ddlmaindep_Opd').attr('disabled', true);
                }
                $('#modalOpd').modal('hide');
            });
            // Delete Row from Opd Table
            $(document).on('click', '.delete-row-opd', function () {
                $(this).closest('tr').remove();
            });

        });

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="row">
        <div class="col-lg-3 col-md-3 col-sm-6">
            <label id="Lblitem_code">Doctors</label>
            <select id="ddl_Doctor" name="ddl_Doctor" onchange="loaddoctordata()"></select>
            <input type="hidden" id="doc_id" />
        </div>
        <div class="col-lg-3 col-md-3 col-sm-6">
            <label id="LblDescription">Doctor Account</label>
            <input type="text" id="txtdocamount" name="txtdocamount" autocomplete="off" readonly="readonly" />
        </div>
        <div class="col-lg-1 col-md-1 col-sm-1">
            <label id="LblActive">Active</label>
            <input type="checkbox" id="Active" name="Active" />
        </div>
    </div>

    <div class="row" style="margin-top: 10px !important">
        <div class="col-lg-1 col-md-1 col-sm-1">
            <input type="button" value="Save" id="btnValue" class="btn-primry" onclick="saveLabtest()" />
        </div>
        <div class="col-lg-1 col-md-1 col-sm-1">
            <input type="button" value="List View" class="btn-primry" id="btnBack" onclick="window.location = 'DoctorAgreementView.aspx'" />
        </div>

        <div class="col-lg-1 col-md-1 col-sm-1">
            <input type="button" value="New" class="btn-primry" onclick="NewPage()" />
        </div>
    </div>


    <div id="tabs">
        <ul>
            <li><a href="#Tab-1">OPD</a></li>
            <li><a href="#Tab-2">Lab</a></li>
            <li><a href="#Tab-3">X_ray</a></li>
            <li><a href="#Tab-4">Ultra_Sound</a></li>
            <li><a href="#Tab-5">CT_Scan</a></li>
            <li><a href="#Tab-6">BloodBank</a></li>
            <li><a href="#Tab-7">MRI</a></li>
            <li><a href="#Tab-8">Services</a></li>
        </ul>

        <div id="Tab-1">
            <div class="row">
                <div class="col-lg-3 col-md-3 col-sm-3">
                    <label>Department</label>
                    <select id="ddlmaindep_Opd" name="ddlmaindep_Opd">
                        <option value="0">Select Department</option>
                        <option value="004">OPD</option>
                    </select>
                </div>
                <div class="col-lg-3 col-md-3 col-sm-6">
                    <label id="lblOpdagremnttype">Agrement Type</label>
                    <select id="ddl_Opd_AgrementType" name="ddl_Opd_AgrementType"></select>
                </div>
                <div class="col-lg-3 col-md-3 col-sm-6">
                    <label id="lblOpdagremntdept">Agrement Department</label>
                    <select id="ddl_Opd_Agrementdept" name="ddl_Opd_Agrementdept"></select>
                </div>
                <div class="col-lg-2 col-md-2 col-sm-2">
                    <label>Doc_share</label>
                    <select id="discount_Opd" onchange="ddldiscount_Opd();">
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
                <div class="col-lg-1 col-md-1 col-sm-1">
                    <a href="#" id="btnshowopdModal" style="margin-top: 10px;">
                        <i class="fa fa-plus-circle" ></i>
                    </a>
                </div>
            </div>
            <table class="table table-bordered table-hover table-striped" style="overflow: scroll; height: auto; margin-top: 10px !important" id="tblResult_Opd">
                <thead id="ihead_Opd">
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
                <tbody id="ibody_Opd">
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
                <div class="col-lg-1 col-md-1 col-sm-1">
                    <a href="#" id="btnshowLabModal" style="margin-top: 10px;">
                        <i class="fa fa-plus-circle"></i>
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
                <div class="col-lg-1 col-md-1 col-sm-1">
                    <a href="#" id="btnshowxrayModal" style="margin-top: 10px;">
                        <i class="fa fa-plus-circle" ></i>
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
                <div class="col-lg-1 col-md-1 col-sm-1">
                    <a href="#" id="btnshowultrsoundModal" style="margin-top: 10px;">
                        <i class="fa fa-plus-circle" ></i>
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
                <div class="col-lg-1 col-md-1 col-sm-1">
                    <a href="#" id="btnshowCTScanModal" style="margin-top: 10px;">
                        <i class="fa fa-plus-circle" ></i>
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

        <div id="Tab-6">
            <div class="row">
                <div class="col-lg-3 col-md-3 col-sm-3">
                    <label>Department</label>
                    <select id="ddlmaindep_bloodbank" name="ddlmaindep_bloodbank">
                        <option value="0">Select Department</option>
                        <option value="005">Bloodbank</option>
                    </select>
                </div>
                <div class="col-lg-3 col-md-3 col-sm-6">
                    <label id="lblbloodbankagremnttype">Agrement Type</label>
                    <select id="ddl_bloodbank_AgrementType" name="ddl_bloodbank_AgrementType"></select>
                </div>
                <div class="col-lg-3 col-md-3 col-sm-6">
                    <label id="lblbloodbankagremntdept">Agrement Department</label>
                    <select id="ddl_bloodbank_Agrementdept" name="ddl_bloodbank_Agrementdept"></select>
                </div>
                <div class="col-lg-2 col-md-2 col-sm-2">
                    <label>Doc_share</label>
                    <select id="discount_blood" onchange="ddldiscount_blood();">
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
                <div class="col-lg-1 col-md-1 col-sm-1">
                    <a href="#" id="btnshowbloodbankModal" style="margin-top: 10px;">
                        <i class="fa fa-plus-circle"></i>
                    </a>
                </div>
            </div>
            <table style="overflow: scroll; height: auto; margin-top: 10px !important" class="table table-bordered table-hover table-striped" id="tblResult_bloodbank">
                <thead id="ihead_bloodbank">
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
                <tbody id="ibody_bloodbank">
                </tbody>
            </table>
        </div>

        <div id="Tab-7">
            <div class="row">
                <div class="col-lg-3 col-md-3 col-sm-3">
                    <label>Department</label>
                    <select id="ddlmaindep_MRI" name="ddlmaindep_MRI">
                        <option value="0">Select Department</option>
                        <option value="006">MRI</option>
                    </select>
                </div>
                <div class="col-lg-3 col-md-3 col-sm-6">
                    <label id="lblmriagremnttype">Agrement Type</label>
                    <select id="ddl_mri_AgrementType" name="ddl_mri_AgrementType"></select>
                </div>
                <div class="col-lg-3 col-md-3 col-sm-6">
                    <label id="lblmriagremntdept">Agrement Department</label>
                    <select id="ddl_mri_Agrementdept" name="ddl_mri_Agrementdept"></select>
                </div>
                <div class="col-lg-2 col-md-2 col-sm-2">
                    <label>Doc_share</label>
                    <select id="discount_mir" onchange="ddldiscount_mir();">
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
                <div class="col-lg-1 col-md-1 col-sm-1">
                    <a href="#" id="btnshowmirModal" style="margin-top: 10px;">
                        <i class="fa fa-plus-circle" ></i>
                    </a>
                </div>
            </div>
            <table style="overflow: scroll; height: auto; margin-top: 10px !important" class="table table-bordered table-hover table-striped" id="tblResult_mri">
                <thead id="ihead_mri">
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
                <tbody id="ibody_mir">
                </tbody>
            </table>
        </div>

        <div id="Tab-8">
            <div class="row">
                <div class="col-lg-3 col-md-3 col-sm-3">
                    <label>Department</label>
                    <select id="ddlmaindep_Services" name="ddlmaindep_Services">
                        <option value="0">Select Department</option>
                        <option value="002">Services</option>
                    </select>
                </div>
                <div class="col-lg-3 col-md-3 col-sm-6">
                    <label id="lblservicesagremnttype">Agrement Type</label>
                    <select id="ddl_services_AgrementType" name="ddl_services_AgrementType"></select>
                </div>
                <div class="col-lg-3 col-md-3 col-sm-6">
                    <label id="lblservicesagremntdept">Agrement Department</label>
                    <select id="ddl_services_Agrementdept" name="ddl_services_Agrementdept"></select>
                </div>
                <div class="col-lg-2 col-md-2 col-sm-2">
                    <label>Doc_share</label>
                    <select id="discount_service" onchange="ddldiscount_service();">
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
                <div class="col-lg-1 col-md-1 col-sm-1">
                    <a href="#" id="btnshowservicesModal" style="margin-top: 10px;">
                        <i class="fa fa-plus-circle" ></i>
                    </a>
                </div>
            </div>
            <table style="overflow: scroll; height: auto; margin-top: 10px !important" class="table table-bordered table-hover table-striped" id="tblResult_services">
                <thead id="ihead_services">
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
                <tbody id="ibodys_services">
                </tbody>
            </table>
        </div>
    </div>

    <!-- Modal For OPD -->
    <div class="modal fade" id="modalOpd" tabindex="-1" role="dialog" aria-labelledby="exampleOpdModalLabel" aria-hidden="true">
        <div class="modal-dialog custom-modal-width" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="exampleOpdModalLabel">Select OPD Data</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <input type="text" id="OpdsearchDescription" class="form-control" placeholder="Search by Description...">
                    </div>
                    <table class="table table-bordered table-responsive-lg table-responsive-md" id="modalBodyOPDTable">
                        <thead>
                            <tr>
                                <th>
                                    <input type="checkbox" id="selectAllOpdRows"></th>
                                <th>Description</th>
                                <th>Actual Amount</th>
                            </tr>
                        </thead>
                        <tbody>
                        </tbody>
                    </table>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-primry" data-dismiss="modal">Close</button>
                    <button type="button" id="btnOpdModalOk" class="btn-primry">OK</button>
                </div>
            </div>
        </div>
    </div>


    <!-- Modal For Lab -->
    <div class="modal fade" id="modalLab" tabindex="-1" role="dialog" aria-labelledby="exampleLabModalLabel" aria-hidden="true">
        <div class="modal-dialog custom-modal-width" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="exampleLabModalLabel">Select LAB Data</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <input type="text" id="LabsearchDescription" class="form-control" placeholder="Search by Description...">
                    </div>
                    <table class="table table-bordered table-responsive-lg table-responsive-md" id="modalBodyLabTable">
                        <thead>
                            <tr>
                                <th>
                                    <input type="checkbox" id="selectAllLabRows"></th>
                                <th>Description</th>
                                <th>Actual Amount</th>
                            </tr>
                        </thead>
                        <tbody>
                        </tbody>
                    </table>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-primry" data-dismiss="modal">Close</button>
                    <button type="button" id="btnLabModalOk" class="btn-primry">OK</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal For X-RAY -->
    <div class="modal fade" id="modalxray" tabindex="-1" role="dialog" aria-labelledby="examplexrayModalLabel" aria-hidden="true">
        <div class="modal-dialog custom-modal-width" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="examplexrayModalLabel">Select X-RAY Data</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <input type="text" id="xraysearchDescription" class="form-control" placeholder="Search by Description...">
                    </div>
                    <table class="table table-bordered table-responsive-lg table-responsive-md" id="modalBodyxrayTable">
                        <thead>
                            <tr>
                                <th>
                                    <input type="checkbox" id="selectAllxrayRows"></th>
                                <th>Description</th>
                                <th>Actual Amount</th>
                            </tr>
                        </thead>
                        <tbody>
                        </tbody>
                    </table>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-primry" data-dismiss="modal">Close</button>
                    <button type="button" id="btnxrayModalOk" class="btn-primry">OK</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal For Ultra Sound -->
    <div class="modal fade" id="modalultrasound" tabindex="-1" role="dialog" aria-labelledby="exampleultrasoundModalLabel" aria-hidden="true">
        <div class="modal-dialog custom-modal-width" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="exampleultrasoundModalLabel">Select Ultra Sound Data</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <input type="text" id="ultrasoundsearchDescription" class="form-control" placeholder="Search by Description...">
                    </div>
                    <table class="table table-bordered table-responsive-lg table-responsive-md" id="modalBodyultrasoundTable">
                        <thead>
                            <tr>
                                <th>
                                    <input type="checkbox" id="selectAllultrasoundRows"></th>
                                <th>Description</th>
                                <th>Actual Amount</th>
                            </tr>
                        </thead>
                        <tbody>
                        </tbody>
                    </table>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-primry" data-dismiss="modal">Close</button>
                    <button type="button" id="btnultrasoundModalOk" class="btn-primry">OK</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal For CT Scan -->
    <div class="modal fade" id="modalctscan" tabindex="-1" role="dialog" aria-labelledby="examplectscanModalLabel" aria-hidden="true">
        <div class="modal-dialog custom-modal-width" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="examplectscanModalLabel">Select CT Scan Data</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <input type="text" id="ctscansearchDescription" class="form-control" placeholder="Search by Description...">
                    </div>
                    <table class="table table-bordered table-responsive-lg table-responsive-md" id="modalBodyctscanTable">
                        <thead>
                            <tr>
                                <th>
                                    <input type="checkbox" id="selectAllctscanRows"></th>
                                <th>Description</th>
                                <th>Actual Amount</th>
                            </tr>
                        </thead>
                        <tbody>
                        </tbody>
                    </table>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-primry" data-dismiss="modal">Close</button>
                    <button type="button" id="btnctscanModalOk" class="btn-primry">OK</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal For Blood Bank -->
    <div class="modal fade" id="modalBloodbank" tabindex="-1" role="dialog" aria-labelledby="exampleBloodbankModalLabel" aria-hidden="true">
        <div class="modal-dialog custom-modal-width" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="exampleBloodbankModalLabel">Select Blood Bank Data</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <input type="text" id="BloodbanksearchDescription" class="form-control" placeholder="Search by Description...">
                    </div>
                    <table class="table table-bordered table-responsive-lg table-responsive-md" id="modalBodyBloodbankTable">
                        <thead>
                            <tr>
                                <th>
                                    <input type="checkbox" id="selectAllBloodbankRows"></th>
                                <th>Description</th>
                                <th>Actual Amount</th>
                            </tr>
                        </thead>
                        <tbody>
                        </tbody>
                    </table>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-primry" data-dismiss="modal">Close</button>
                    <button type="button" id="btnBloodbankModalOk" class="btn-primry">OK</button>
                </div>
            </div>
        </div>
    </div>


    <!-- Modal For MRI -->
    <div class="modal fade" id="modalMRI" tabindex="-1" role="dialog" aria-labelledby="exampleMRIModalLabel" aria-hidden="true">
        <div class="modal-dialog custom-modal-width" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="exampleMRIModalLabel">Select MRI Data</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <input type="text" id="MRIsearchDescription" class="form-control" placeholder="Search by Description...">
                    </div>
                    <table class="table table-bordered table-responsive-lg table-responsive-md" id="modalBodyMRITable">
                        <thead>
                            <tr>
                                <th>
                                    <input type="checkbox" id="selectAllMRIRows"></th>
                                <th>Description</th>
                                <th>Actual Amount</th>
                            </tr>
                        </thead>
                        <tbody>
                        </tbody>
                    </table>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-primry" data-dismiss="modal">Close</button>
                    <button type="button" id="btnMRIModalOk" class="btn-primry">OK</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal For Services -->
    <div class="modal fade" id="modalservices" tabindex="-1" role="dialog" aria-labelledby="exampleservicesModalLabel" aria-hidden="true">
        <div class="modal-dialog custom-modal-width" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="exampleservicesModalLabel">Select Services Data</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <input type="text" id="servicessearchDescription" class="form-control" placeholder="Search by Description...">
                    </div>
                    <table class="table table-bordered table-responsive-lg table-responsive-md" id="modalBodyservicesTable">
                        <thead>
                            <tr>
                                <th>
                                    <input type="checkbox" id="selectAllservicesRows"></th>
                                <th>Description</th>
                                <th>Actual Amount</th>
                            </tr>
                        </thead>
                        <tbody>
                        </tbody>
                    </table>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-primry" data-dismiss="modal">Close</button>
                    <button type="button" id="btnservicesModalOk" class="btn-primry">OK</button>
                </div>
            </div>
        </div>
    </div>

</asp:Content>
