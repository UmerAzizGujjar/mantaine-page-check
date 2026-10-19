<%@ Page EnableSessionState="ReadOnly" Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AddAssetSelection.aspx.cs" Inherits="PMS.AddAssetSelection" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        .checkbox-align {
            display: flex;
            align-items: center;
            gap: 8px; /* space between label and checkbox */
        }

            .checkbox-align label {
                margin-bottom: 0; /* removes any bottom spacing */
            }
    </style>

    <script type="text/javascript">
        function getRecords(id) {
            $.ajax({
                type: "POST",
                url: "AddAssetSelection.aspx/getRecords",
                data: JSON.stringify({ "id": id }),

                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var parsed_data = JSON.parse(response.d);
                    console.log(parsed_data);

                    $("#txt_asi").val(parsed_data[0].Asset_Definition_Id);
                    $("#txt_iserial").val(parsed_data[0].Item_Serial);
                    $("#chk_moveable").prop('checked', parsed_data[0].Moveable);
                    $("#chk_active").prop('checked', parsed_data[0].isactive);

                    $("#chk_active").prop('checked', parsed_data[0].active);
                    $("#txt_idesp").val(parsed_data[0].Item_Description);
                    $("#acq_cost").val(parsed_data[0].Acq_Cost);
                    $("#txtCapitilization_cost").val(parsed_data[0].Capitilization_Cost);
                    var acq_daye = parsed_data[0].Acq_Date;
                    var capt_daye = parsed_data[0].Capitilization_Date;
                    if (acq_daye == null || acq_daye == "null" || acq_daye == "" || acq_daye == '') {
                    }
                    else {
                        acq_daye = $.datepicker.formatDate('dd M yy', new Date(parseInt(parsed_data[0].Acq_Date.substring(6, 19))))
                        $("#acq_date").val(acq_daye);
                    }
                    if (capt_daye == null || capt_daye == "null" || capt_daye == "" || capt_daye == '') {
                    }
                    else {
                        capt_daye = $.datepicker.formatDate('dd M yy', new Date(parseInt(parsed_data[0].Capitilization_Date.substring(6, 19))))
                        $("#txtCapitilization_date").val(capt_daye);
                    }

                    $("#mfactur").val(parsed_data[0].Manyfacturer);
                    $("#ast_life").val(parsed_data[0].Asset_lifeDays);


                    var Transfer_Date = parsed_data[0].Transfer_Date;
                    if (Transfer_Date == null || Transfer_Date == "null" || Transfer_Date == "" || Transfer_Date == '') {

                    }
                    else {
                        var Transfer_Date = $.datepicker.formatDate('dd M yy', new Date(parseInt(parsed_data[0].Transfer_Date.substring(6, 19))))
                        $("#tdate").val(parsed_data[0].Transfer_Date);
                    }

                    $("#dprctin").val(parsed_data[0].Depreciation);
                    $("#slct_dprctin").val(parsed_data[0].Depreciation_type);
                    $("#slvg_value").val(parsed_data[0].Salvage_Value);
                    $("#txt_Cap").val(parsed_data[0].Fur_Capacity);
                    $("#txt_Conv").val(parsed_data[0].Convertable);
                    $("#txt_usage").val(parsed_data[0].Usage);
                    $("#txt_Length").val(parsed_data[0].Lenght);
                    $("#txt_Width").val(parsed_data[0].Width);
                    $("#ddlLocation_ID").val(parsed_data[0].Location_ID);


                    $("#ddlassetaccount").val(parsed_data[0].assetAccount);
                    $("#ddlaccumlate_acc").val(parsed_data[0].assetAccount);
                    $("#ddldep_Account").val(parsed_data[0].assetAccount);


                    $("#txt_land_area").val(parsed_data[0].Land_Area);
                    $("#txt_ld_acq_frm").val(parsed_data[0].Land_Acq_from);
                    $("#txt_lnd_ksra").val(parsed_data[0].Land_Kesra_No);
                    $("#txt_lnd_ktoni").val(parsed_data[0].Land_Katoni_No);
                    $("#txt_lnd_khwt").val(parsed_data[0].Land_Khawet_No);
                    $("#txt_bld_rms").val(parsed_data[0].Builing_No_Rooms);
                    $("#txt_bld_cvr").val(parsed_data[0].Building_COvered_Are);
                    $("#txt_plot_no").val(parsed_data[0].Plot_No);
                    $("#txt_capacty").val(parsed_data[0].Capacity);
                    $("#txt_model").val(parsed_data[0].M_Model);
                    $("#txt_chse_no").val(parsed_data[0].Chasis_No);
                    $("#txt_per_kva").val(parsed_data[0].KVA);
                    $("#txt_convrsin_rate").val(parsed_data[0].Conversion_Rate);
                    $("#txt_srl_no").val(parsed_data[0].Serial_No);
                    $("#txt_make").val(parsed_data[0].Make);
                    $("#txt_curncy").val(parsed_data[0].Currency);
                    $("#txt_pwr_hp").val(parsed_data[0].HP);
                    $("#txt_mchn_cost").val(parsed_data[0].FC);
                    $("#slct_plnt_typ").val(parsed_data[0].Plant_Type);
                    $("#txt_reg_no").val(parsed_data[0].Registeraion_no);
                    var Reg_Date = parsed_data[0].Reg_Date;
                    if (Reg_Date == null || Reg_Date == "null" || Reg_Date == "" || Reg_Date == '') {
                    }
                    else {
                        var Reg_Date = $.datepicker.formatDate('dd M yy', new Date(parseInt(parsed_data[0].Reg_Date.substring(6, 19))))
                        $("#txt_reg_date").val(parsed_data[0].Reg_Date);
                    }
                    $("#txt_vmodel").val(parsed_data[0].Model);
                    $("#txt_eng_no").val(parsed_data[0].Engine_No);
                    $("#slct_vtype").val(parsed_data[0].Vehicle_Type);
                    $("#txt_vcolor").val(parsed_data[0].Color);
                    $("#txt_vmake").val(parsed_data[0].Make);
                    $("#txt_cd").val(parsed_data[0].CD);
                    $("#txt_board").val(parsed_data[0].Board);
                    $("#txt_ram").val(parsed_data[0].Ram);
                    $("#txt_procser").val(parsed_data[0].Processor);
                    $("#txt_disk").val(parsed_data[0].Hard_Disk);
                    $("#txt_comp_name").val(parsed_data[0].Name);

                    setTimeout(function () {
                        $("#ast_ctgry").val(parsed_data[0].Asset_Cat_id);
                        $("#act_ctgry").val(parsed_data[0].Acc_Categ_id);
                        $("#slct_vendor").val(parsed_data[0].Vendor_id);
                        $("#asst_type").val(parsed_data[0].Asset_Type);
                        loadSub();
                        if (parsed_data[0].Asset_Cat_id == "0") {
                            $('.table_land').hide();
                            $('.table_build').hide();
                            $('.table_vehicles').hide();
                            $('.table_computer').hide();
                            $('.table_machine').hide();
                            $('.table_furniture').hide();
                        }
                        var text = $("#ast_ctgry").find('option:selected').text();
                        if (text == "Land") {
                            $('.table_land').show();
                            $('.table_build').hide();
                            $('.table_vehicles').hide();
                            $('.table_computer').hide();
                            $('.table_machine').hide();
                            $('.table_furniture').hide();
                        }
                        else if (text == "Building") {
                            $('.table_land').hide();
                            $('.table_build').show();
                            $('.table_vehicles').hide();
                            $('.table_computer').hide();
                            $('.table_machine').hide();
                            $('.table_furniture').hide();
                        }
                        else if (text == "Machinery") {
                            $('.table_land').hide();
                            $('.table_build').hide();
                            $('.table_vehicles').hide();
                            $('.table_computer').hide();
                            $('.table_machine').show();
                            $('.table_furniture').hide();
                        }
                        else if (text == "Vehicles") {
                            $('.table_land').hide();
                            $('.table_build').hide();
                            $('.table_vehicles').show();
                            $('.table_computer').hide();
                            $('.table_machine').hide();
                            $('.table_furniture').hide();
                        }
                        else if (text == "Computers") {
                            $('.table_land').hide();
                            $('.table_build').hide();
                            $('.table_vehicles').hide();
                            $('.table_computer').show();
                            $('.table_machine').hide();
                            $('.table_furniture').hide();
                        }
                        else if (text == "Furniture") {
                            $('.table_land').hide();
                            $('.table_build').hide();
                            $('.table_vehicles').hide();
                            $('.table_furniture').show();
                            $('.table_machine').hide();
                            $('.table_machine').hide();
                        }
                    }, 4000)
                    setTimeout(function () {
                        $("#sub_ctgry").val(parsed_data[0].Asset_SubCat_Id);
                        $("#slct_dept").val(parsed_data[0].Departmet_id);
                        $("#ddlassetaccount").val(parsed_data[0].Asset_Account);
                        $("#ddlaccumlate_acc").val(parsed_data[0].Acc_Depreciation_Acc);
                        $("#ddldep_Account").val(parsed_data[0].Depreciation_Acc);


                    }, 5000)

                    GetDefination_Result(id)

                }

            });
        }
        function GetDefination_Result(id) {

            $.ajax({
                type: "POST",
                url: "AddAssetSelection.aspx/GetDefination_Result",
                data: JSON.stringify({
                    "id": id
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var rows = '';
                    var arrData = JSON.parse(response.d);
                    $.each(arrData, function (key, value) {
                        var Definition_Date = $.datepicker.formatDate('dd M yy', new Date(parseInt(arrData[key].Definition_Date.substring(6, 19))))
                        var grn_date = $.datepicker.formatDate('dd M yy', new Date(parseInt(arrData[key].Grn_Date.substring(6, 19))))
                        var mir_date = $.datepicker.formatDate('dd M yy', new Date(parseInt(arrData[key].Mir_Date.substring(6, 19))))
                        rows += '<tr>' +
                            '<td ><input type="text" id="Date' + (key + 1) + '" name="Date"  value="' + Definition_Date + '" style="width:122px!important;" /></td>' +
                            '<td><input type="text" id="refnce' + (key + 1) + '" name="refnce" value="' + arrData[key].Ref_No + '" style="width:122px!important;"/></td>' +
                            '<td><input type="text" id="amount' + (key + 1) + '" name="amount" style="text-align: right;width:122px!important;" value="' + arrData[key].Amount + '"/></td>' +
                            '<td><input type="text" id="grn_no' + (key + 1) + '" name="grn_no"  style="width:122px!important;" value="' + arrData[key].Grn_no + '"/></td>' +
                            '<td><input type="text" id="grn_date' + (key + 1) + '" name="grn_date" value="' + grn_date + '" style="width:122px!important;" /></td>' +
                            '<td><input type="text" id="mir_no' + (key + 1) + '" name="mir_no"  style="width:122px!important;" value="' + arrData[key].Mir_No + '"/></td>' +
                            '<td><input type="text" id="mir_date' + (key + 1) + '" name="mir_date"  value="' + mir_date + '"  style="width:122px!important;" /></td>' +
                            '<td><a href="javascript:void(0)" onclick="Delete(this)"><i class="fa fa-trash"  style="border-radius: 4px;background-color:#ad170c;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" >'
                        '</td>' +
                            '</tr>';
                    });
                    $('.table_cst').append(rows);
                    $.each(arrData, function (key, value) {
                        $('#Date' + (key + 1)).datepicker({ dateFormat: 'dd M yy' });
                        $('#grn_date' + (key + 1)).datepicker({ dateFormat: 'dd M yy' });
                        $('#mir_date' + (key + 1)).datepicker({ dateFormat: 'dd M yy' });
                    });
                    $("#btn_save").val('Update');
                }, error: function () {
                }
            });
        }

        $(document).ready(function () {

            $('#acq_date').datepicker({ dateFormat: 'dd M yy' });
            $('#txtCapitilization_date').datepicker({ dateFormat: 'dd M yy' });
            $('#tdate').datepicker({ dateFormat: 'dd M yy' });
            $('#txt_reg_date').datepicker({ dateFormat: 'dd M yy' });
            GetassetDefinition();
            LoadAssetCategory();
            LoadVendors();
            LoadDepartments();
            LoadAsssetType();
            LoadAcctCategory();
            LoadDepreciation();
            load_location();

            load_AccumlateAccount();
            load_Asset();
            load_DepreciationAccount();
            $("#btn_save").on('click', function () {
                var btnSave = $(this).val();
                var department_id = $("#slct_dept").val();
                var location = $('#ddlLocation_ID').val();

                if (location == 0 || location == "0" || location == '0' || location == "") {

                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Fill mandatory fields',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });


                    console.error("Error: Location is required.");
                    return;
                }

                var slct_vendor = $("#slct_vendor").val();
                var ast_ctgry = $("#ast_ctgry").val();

                if (ast_ctgry == 0 || ast_ctgry == "0" || ast_ctgry == '0' || ast_ctgry == "") {

                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Fill mandatory fields',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });


                     console.error("Error: Asset category is required.");
                    return;
                }

                var sub_ctgry = $("#sub_ctgry").val();

                if (sub_ctgry == 0 || sub_ctgry == "0" || sub_ctgry == '0' || sub_ctgry == "") {

                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Fill mandatory fields',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });


                     console.error("Error: Sub-category is required.");
                    return;
                }

                var act_ctgry = $("#act_ctgry").val();
                var txt_iserial = $("#txt_iserial").val();
                var moveable = $("#chk_moveable").prop('checked');
                var active = $("#chk_active").prop('checked');
                var txt_idesp = $("#txt_idesp").val();

                if (txt_idesp == "" || txt_idesp == null) {

                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Failed to select Patient',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });


                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Fill mandatory fields',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });


                     console.error("Error: Description is required.");
                    return;
                }

                var acq_cost = $("#acq_cost").val();
                var Capt_cost = $("#txtCapitilization_cost").val();
                var acq_date = $("#acq_date").val();

                if (!acq_date) {
                    acq_date = "1900-01-01"; // assign a default value if empty
                }

                console.log("acq_date date:", acq_date);
                var capt_date = $("#txtCapitilization_date").val();
                if (!capt_date) {
                    capt_date = "1900-01-01"; // assign a default value if empty
                }
                console.log("capitalization date:", capt_date);

                var Asset_Acc = $('#ddlassetaccount').val();
                var Depreciation_Acc = $('#ddldep_Account').val();
                var Accumulate_Acc = $('#ddlaccumlate_acc').val();
                var mfactur = $("#mfactur").val();
                var ast_life = $("#ast_life").val();
                var tdate = $("#tdate").val();
                var dprctin = $("#dprctin").val();
                var slct_dprctin = $("#slct_dprctin").val();
                var slvg_value = $("#slvg_value").val();
                var asst_type = $("#asst_type").val();
                var Fur_capacity = $("#txt_Cap").val();
                var txt_convertable = $("#txt_Conv").val();
                var txt_usage = $("#txt_usage").val();
                var txt_lenght = $("#txt_Length").val();
                var txt_width = $("#txt_Width").val();
                var txt_land_area = $("#txt_land_area").val();
                var txt_ld_acq_frm = $("#txt_ld_acq_frm").val();
                var txt_lnd_ksra = $("#txt_lnd_ksra").val();
                var txt_lnd_ktoni = $("#txt_lnd_ktoni").val();
                var txt_lnd_khwt = $("#txt_lnd_khwt").val();
                var txt_bld_rms = $("#txt_bld_rms").val();
                var txt_bld_cvr = $("#txt_bld_cvr").val();
                var txt_plot_no = $("#txt_plot_no").val();
                var txt_capacty = $("#txt_capacty").val();
                var txt_model = $("#txt_model").val();
                var txt_chse_no = $("#txt_chse_no").val();
                var txt_per_kva = $("#txt_per_kva").val();
                var txt_convrsin_rate = $("#txt_convrsin_rate").val();

                if (txt_convrsin_rate == "") txt_convrsin_rate = 0;

                var txt_srl_no = $("#txt_srl_no").val();
                var txt_make = $("#txt_make").val();
                var txt_curncy = $("#txt_curncy").val();
                var txt_pwr_hp = $("#txt_pwr_hp").val();
                var txt_mchn_cost = $("#txt_mchn_cost").val();
                var slct_plnt_typ = $("#slct_plnt_typ").val();
                var txt_reg_no = $("#txt_reg_no").val();
                var txt_reg_date = $("#txt_reg_date").val();
                var txt_vmodel = $("#txt_vmodel").val();
                var txt_eng_no = $("#txt_eng_no").val();
                var slct_vtype = $("#slct_vtype").val();
                var txt_vcolor = $("#txt_vcolor").val();
                var txt_vmake = $("#txt_vmake").val();
                var txt_cd = $("#txt_cd").val();
                var txt_board = $("#txt_board").val();
                var txt_ram = $("#txt_ram").val();
                var txt_procser = $("#txt_procser").val();
                var txt_disk = $("#txt_disk").val();
                var txt_comp_name = $("#txt_comp_name").val();
                var id = '<%=Request.QueryString["ID"]%>';

                var table = $('.table_cst');
                var list = [];

                table.find('tr:gt(0)').each(function (key, value) {
                    var Date = $(value).find('input[name="Date"]').val();
                    var refnce = $(value).find('input[name="refnce"]').val();
                    var amount = $(value).find('input[name="amount"]').val();
                    var grn_no = $(value).find('input[name="grn_no"]').val();
                    var grn_date = $(value).find('input[name="grn_date"]').val();
                    var mir_no = $(value).find('input[name="mir_no"]').val();
                    var mir_date = $(value).find('input[name="mir_date"]').val();

                    var array = {
                        Date: Date,
                        refnce: refnce,
                        amount: amount,
                        grn_no: grn_no,
                        grn_date: grn_date,
                        mir_no: mir_no,
                        mir_date: mir_date
                    };

                    list.push(array);
                });

                try {
                    PageMethods.SaveRecord(
                        department_id, slct_vendor, ast_ctgry, sub_ctgry, act_ctgry, txt_iserial, moveable, active, txt_idesp, acq_cost, acq_date, capt_date, Capt_cost, mfactur, ast_life, tdate, location, dprctin, slct_dprctin, slvg_value, txt_land_area, txt_ld_acq_frm, txt_lnd_ksra, txt_lnd_ktoni, Asset_Acc, Accumulate_Acc, Depreciation_Acc, txt_lnd_khwt, txt_bld_rms, txt_bld_cvr, txt_plot_no, txt_capacty, txt_model, txt_per_kva, txt_convrsin_rate, txt_srl_no, txt_make, txt_curncy, txt_pwr_hp, txt_mchn_cost, slct_plnt_typ, txt_reg_no, txt_reg_date, txt_vmodel, txt_eng_no, slct_vtype, txt_vcolor, txt_vmake, Fur_capacity, txt_convertable, txt_usage, txt_lenght, txt_width, txt_cd, txt_board, txt_ram, txt_procser,
                        txt_disk, txt_comp_name, txt_chse_no, asst_type, btnSave, id, list,
                        function (response) {
                            var master_id = response;
                            if (master_id != '-1') {
                                Swal.fire({
                                    icon: 'success',
                                    title: 'Success!',
                                    text: 'Data has been saved successfully.',
                                    showConfirmButton: false,
                                    timer: 2500,
                                    customClass: {
                                        popup: 'swal-big-popup',
                                        title: 'swal-big-title',
                                        htmlContainer: 'swal-big-text'
                                    }
                                });
                                 window.location.href = "AddAssetSelection.aspx";
                            }
                        }
                    );
                } catch (error) {
                    console.error("Error while saving record:", error);
                }
            });


            $("#ast_ctgry").on('change', function () {
                loadSub();
            });
            var id = '<%=Request.QueryString["ID"]%>';
            if (id != "") {
                $("#btn_save").val('Update');
                getRecords(id);
            }
            else {
                $('#slct_vendor').select2();
                $('#slct_dept').select2();
                $('#ast_ctgry').select2();
                $('#sub_ctgry').select2();
                $('#act_ctgry').select2();
                $('#ddlLocation_ID').select2();
                $('#ddlassetaccount').select2();
                $('#ddlaccumlate_acc').select2();
                $('#ddldep_Account').select2();
                $('#asst_type').select2();
            }
        });
        function loadSub() {
            var asset_sub = $("#ast_ctgry").val();
            var asset_subs = $("#ast_ctgry").find('option:selected').val();
            console.log(asset_sub);
            console.log(asset_subs);
            var text = $("#ast_ctgry").find('option:selected').text();
            console.log(text);
            if (asset_sub == "0") {
                $('.table_land').hide();
                $('.table_build').hide();
                $('.table_vehicles').hide();
                $('.table_computer').hide();
                $('.table_machine').hide();
                $('.table_furniture').hide();
            }
            if (text == "Land") {
                $('.table_land').show();
                $('.table_build').hide();
                $('.table_vehicles').hide();
                $('.table_computer').hide();
                $('.table_machine').hide();
                $('.table_furniture').hide();
            }
            else if (text == "Building") {
                $('.table_land').hide();
                $('.table_build').show();
                $('.table_vehicles').hide();
                $('.table_computer').hide();
                $('.table_machine').hide();
                $('.table_furniture').hide();
            }
            else if (text == "Machinery") {
                $('.table_land').hide();
                $('.table_build').hide();
                $('.table_vehicles').hide();
                $('.table_computer').hide();
                $('.table_machine').show();
                $('.table_furniture').hide();
            }
            else if (text == "Vehicles") {
                $('.table_land').hide();
                $('.table_build').hide();
                $('.table_vehicles').show();
                $('.table_computer').hide();
                $('.table_machine').hide();
                $('.table_furniture').hide();
            }
            else if (text == "Computers") {
                $('.table_land').hide();
                $('.table_build').hide();
                $('.table_vehicles').hide();
                $('.table_computer').show();
                $('.table_machine').hide();
                $('.table_furniture').hide();
            }
            else if (text == "Furniture") {
                $('.table_land').hide();
                $('.table_build').hide();
                $('.table_vehicles').hide();
                $('.table_computer').hide();
                $('.table_machine').hide();
                $('.table_furniture').show();
            }
            else {
                $('.table_land').hide();
                $('.table_build').hide();
                $('.table_vehicles').hide();
                $('.table_computer').hide();
                $('.table_machine').hide();
                $('.table_furniture').hide();

            }
            $.ajax({
                type: "POST",
                url: "AddAssetSelection.aspx/LoadAssetSubCategory",
                data: JSON.stringify({
                    "asset_sub": asset_sub
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    var options = '<option value="0" >Please Select</option>';

                    var values = JSON.parse(data.d);
                    $.each(values, function (key, value) {
                        options += '<option value="' + value.Asset_SubCat_ID + '" >' + value.Asset_SubCat_Name + '</option>';
                    });

                    $('#sub_ctgry').html(options);
                },
                failure: function (response) {

                    alert(response.d);
                }
            });
        }

        function load_Asset() {
            var LoadAsset = '';
            $.ajax({
                type: "post",
                url: "AddAssetSelection.aspx/LoadAssetAccounts",
                dataType: 'JSON',
                contentType: "application/json; charset=utf-8",
                async: false,
                success: function (msg) {
                    LoadAsset = '<option value="0">Please Select</option>';
                    var data = JSON.parse(msg.d);
                    $.each(data, function (key, value) {
                        LoadAsset += '<option value="' + value.Account_ID + '" >' + value.Account_Name + '</option>';
                    });
                    $('#ddlassetaccount').html(LoadAsset);
                },
            });
        }
        function load_AccumlateAccount() {
            var LoadAccumlate = '';
            $.ajax({
                type: "post",
                url: "AddAssetSelection.aspx/Load_Accumlate_Acc",
                dataType: 'JSON',
                contentType: "application/json; charset=utf-8",
                async: false,
                success: function (msg) {
                    LoadAccumlate = '<option value="0">Please Select</option>';
                    var data = JSON.parse(msg.d);
                    $.each(data, function (key, value) {
                        LoadAccumlate += '<option value="' + value.Account_ID + '" >' + value.Account_Name + '</option>';
                    });
                    $('#ddlaccumlate_acc').html(LoadAccumlate);
                },
            });
        }
        function load_DepreciationAccount() {
            var LoadDepreciation = '';
            $.ajax({
                type: "post",
                url: "AddAssetSelection.aspx/Load_Depreciation_Acc",
                dataType: 'JSON',
                contentType: "application/json; charset=utf-8",
                async: false,
                success: function (msg) {
                    LoadDepreciation = '<option value="0">Please Select</option>';
                    var data = JSON.parse(msg.d);
                    $.each(data, function (key, value) {
                        LoadDepreciation += '<option value="' + value.Account_ID + '" >' + value.Account_Name + '</option>';
                    });
                    $('#ddldep_Account').html(LoadDepreciation);
                },
            });
        }
        function load_location() {
            var LoadLocation = '';
            $.ajax({
                type: "post",
                url: "AddAssetSelection.aspx/Load_Location",
                dataType: 'JSON',
                contentType: "application/json; charset=utf-8",
                async: false,
                success: function (msg) {
                    LoadLocation = '<option value="0">Please Select</option>';
                    var data = JSON.parse(msg.d);
                    $.each(data, function (key, value) {
                        LoadLocation += '<option value="' + value.Location_ID + '" >' + value.Location_Description + '</option>';
                    });
                    $('#ddlLocation_ID').html(LoadLocation);
                },
            });
        }
        function LoadAssetCategory() {
            var optionsDepth = '';
            $.ajax({
                type: "POST",
                url: "AddAssetSelection.aspx/LoadAssetCategory",
                data: "",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    var options = '<option value="0" >Please Select</option>';
                    var values = JSON.parse(data.d);
                    $.each(values, function (key, value) {
                        options += '<option value="' + value.Asset_Category_Id + '" >' + value.Asset_Cat_Name + '</option>';
                    });
                    $('#ast_ctgry').html(options);
                    var id = $("#ast_ctgry").val();
                    var text = $("#ast_ctgry").find('option:selected').text();
                    if (id == "0") {
                        $('.table_land').hide();
                        $('.table_build').hide();
                        $('.table_vehicles').hide();
                        $('.table_computer').hide();
                        $('.table_machine').hide();
                        $('.table_furniture').hide();

                    }
                    if (text == "Land") {
                        $('.table_land').show();
                        $('.table_build').hide();
                        $('.table_vehicles').hide();
                        $('.table_computer').hide();
                        $('.table_machine').hide();
                        $('.table_furniture').hide();
                    }
                    else if (text == "Building") {
                        $('.table_land').hide();
                        $('.table_build').show();
                        $('.table_vehicles').hide();
                        $('.table_computer').hide();
                        $('.table_machine').hide();
                        $('.table_furniture').hide();
                    }
                    else if (text == "Machinery") {
                        $('.table_land').hide();
                        $('.table_build').hide();
                        $('.table_vehicles').hide();
                        $('.table_computer').hide();
                        $('.table_machine').show();
                        $('.table_furniture').hide();
                    }
                    else if (text == "Vehicles") {
                        $('.table_land').hide();
                        $('.table_build').hide();
                        $('.table_vehicles').show();
                        $('.table_computer').hide();
                        $('.table_machine').hide();
                        $('.table_furniture').hide();
                    }
                    else if (text == "Computers") {
                        $('.table_land').hide();
                        $('.table_build').hide();
                        $('.table_vehicles').hide();
                        $('.table_computer').show();
                        $('.table_machine').hide();
                        $('.table_furniture').hide();
                    }
                    else if (text == "Furniture") {
                        $('.table_land').hide();
                        $('.table_build').hide();
                        $('.table_vehicles').hide();
                        $('.table_computer').hide();
                        $('.table_machine').hide();
                        $('.table_furniture').show();
                    }
                    else {
                        $('.table_land').hide();
                        $('.table_build').hide();
                        $('.table_vehicles').hide();
                        $('.table_computer').hide();
                        $('.table_machine').hide();
                        $('.table_furniture').hide();

                    }
                },
                failure: function (response) {

                    alert(response.d);
                }
            });
        }
        function GetassetDefinition() {
            $.ajax({
                type: "post",
                url: "AddAssetSelection.aspx/GetassetDefinition",
                data: '',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {

                    var id = response.d;
                    $("#txt_asi").val(id);
                },
                failure: function (response) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'In failure method',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });
                 }
            });
        }
        var rowlength = '';
        function Addrow() {
            var rows = '';
            var rowIndex = parseInt((parseInt($('#table_cost tbody tr:gt(0)').length)));
            rows += '<tr>' +
                '<td ><input type="text" id="Date' + (rowIndex + 1) + '" name="Date"  value="" style="width:122px!important;" /></td>' +
                '<td><input type="text" id="refnce' + (rowIndex + 1) + '" name="refnce" style="width:122px!important;"/></td>' +
                '<td><input type="text" id="amount' + (rowIndex + 1) + '" name="amount" style="text-align: right;width:122px!important;"/></td>' +
                '<td><input type="text" id="grn_no' + (rowIndex + 1) + '" name="grn_no"  style="width:122px!important;"/></td>' +
                '<td><input type="text" id="grn_date' + (rowIndex + 1) + '" name="grn_date" style="width:122px!important;" /></td>' +
                '<td><input type="text" id="mir_no' + (rowIndex + 1) + '" name="mir_no"  style="width:122px!important;"/></td>' +
                '<td><input type="text" id="mir_date' + (rowIndex + 1) + '" name="mir_date"  style="width:122px!important;" /></td>' +
                '<td><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="glyphicon glyphicon-trash" style="width:15px !important;font-size: 16px;color:#f30a0a;position:relative; margin-left: 24px;" i=""></i></a></td>'
            '</tr>';
            $('.table_cst').append(rows);
            $('#Date' + (rowIndex + 1)).datepicker({ dateFormat: 'dd M yy' });
            $('#grn_date' + (rowIndex + 1)).datepicker({ dateFormat: 'dd M yy' });
            $('#mir_date' + (rowIndex + 1)).datepicker({ dateFormat: 'dd M yy' });
            rowlength++;
        }
        function ExcludeFromPayment(anchor) {
            var a = confirm("Are you sure You want to delete");
            if (a == true) {
                console.clear();
                var row = $(anchor).parents('tr')[0];
                row.remove();
            }
        }

        function LoadVendors() {
            $.ajax({
                type: "POST",
                url: "AddAssetSelection.aspx/LoadVendors",
                data: "",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    var options = '<option value="0" >Please Select</option>';
                    var values = JSON.parse(data.d);
                    $.each(values, function (key, value) {
                        options += '<option value="' + value.Vendor_ID + '" >' + value.Vendor_Name + '</option>';
                    });
                    $('#slct_vendor').html(options);
                },
                failure: function (response) {
                    alert(response.d);
                }
            });
        }
        function LoadAsssetType() {
            $.ajax({
                type: "POST",
                url: "AddAssetSelection.aspx/LoadAsssetType",
                data: "",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    var options = '<option value="0" >Please Select</option>';
                    var values = JSON.parse(data.d);
                    $.each(values, function (key, value) {
                        options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                    });
                    $('#asst_type').html(options);
                },
                failure: function (response) {
                    alert(response.d);
                }
            });

        }
        function LoadDepartments() {

            $.ajax({
                type: "POST",
                url: "AddAssetSelection.aspx/LoadDepartments",
                data: "",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    var options = '<option value="0" >Please Select</option>';
                    var values = JSON.parse(data.d);
                    $.each(values, function (key, value) {
                        options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                    });
                    $('#slct_dept').html(options);
                },
                failure: function (response) {

                    alert(response.d);
                }
            });
        }
        function LoadDepreciation() {

            $.ajax({
                type: "POST",
                url: "AddAssetSelection.aspx/LoadDepreciation",
                data: "",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    var options = '<option value="0" >Please Select</option>';
                    var values = JSON.parse(data.d);
                    $.each(values, function (key, value) {
                        options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                    });
                    $('#slct_dprctin').html(options);
                },
                failure: function (response) {

                    alert(response.d);
                }
            });
        }
        function LoadAcctCategory() {
            var optionsDepth = '';
            $.ajax({
                type: "POST",
                url: "AddAssetSelection.aspx/LoadAcctCategory",
                data: "",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    var options = '<option value="0" >Please Select</option>';
                    var values = JSON.parse(data.d);
                    $.each(values, function (key, value) {
                        options += '<option value="' + value.Account_Category_Id + '" >' + value.CategoryName + '</option>';
                    });
                    $('#act_ctgry').html(options);
                },
                failure: function (response) {
                    alert(response.d);
                }
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <form>

        <div class="row">
            <div class="col-lg-3 col-md-3 col-sm-4">
                <label>Asset Selection ID:</label>
                <input type="text" disabled name="Asset" id="txt_asi" />
            </div>
            <div class="col-lg-3 col-md-3 col-sm-4">
                <label>Department:</label>
                <select id="slct_dept"></select>
            </div>
            <div class="col-lg-3 col-md-3 col-sm-4">
                <label>Vendor:</label>
                <select id="slct_vendor"></select>
            </div>
            <div class="col-lg-3 col-md-3 col-sm-4">
                <label>Asset Category *:</label>
                <select id="ast_ctgry"></select>
            </div>
        </div>

        <div class="row">

            <div class="col-lg-3 col-md-3 col-sm-4">
                <label>Asset Sub-Category *:</label>
                <select id="sub_ctgry">
                    <option value="0">Please Select</option>
                </select>
            </div>
            <div class="col-lg-3 col-md-3 col-sm-4">
                <label>Account Category:</label>
                <select id="act_ctgry"></select>
            </div>
            <div class="col-lg-3 col-md-3 col-sm-4">
                <label>Item Serial:</label>
                <input type="text" name="iserial" id="txt_iserial" />
            </div>
            <div class="col-lg-3 col-md-3 col-sm-4">
                <label>Location *:</label>
                <select id="ddlLocation_ID"></select>
            </div>
        </div>

        <div class="row">
            <div class="col-lg-3 col-md-3 col-sm-4">
                <label>Item Description *:</label>
                <input type="text" name="Description" id="txt_idesp" />
            </div>
            <div class="col-lg-3 col-md-3 col-sm-4">
                <label>Acquisition Cost:</label>
                <input type="text" name="Acquistion cost" id="acq_cost" />
            </div>
            <div class="col-lg-3 col-md-3 col-sm-4">
                <label>Acquisition Date:</label>
                <input type="text" name="Acquistion Date" id="acq_date" />
            </div>
            <div class="col-lg-3 col-md-3 col-sm-4">
                <label>Manufacture:</label>
                <input type="text" name="Manufacture" id="mfactur" />
            </div>
        </div>


        <div class="row">
            <div class="col-lg-3 col-md-3 col-sm-4">
                <label>Asset Life (Days):</label>
                <input type="text" name="Asset Life" id="ast_life" />
            </div>
            <div class="col-lg-3 col-md-3 col-sm-4">
                <label>Capitilization Cost:</label>
                <input type="text" name="txtCapitilization_cost" id="txtCapitilization_cost" />
            </div>

            <div class="col-lg-3 col-md-3 col-sm-4">
                <label>Capitilization Date:</label>
                <input type="text" name="txtCapitilization_dates" id="txtCapitilization_date" />
            </div>
            <div class="col-lg-3 col-md-3 col-sm-4">
                <label>Transfer Date:</label>
                <input type="text" name="Transfer Date" id="tdate" />
            </div>
        </div>

        <div class="row">
            <div class="col-lg-3 col-md-3 col-sm-4">
                <label>Depreciation %:</label>
                <input type="text" name="Depreciation" id="dprctin">
            </div>
            <div class="col-lg-3 col-md-3 col-sm-4">
                <label>Depreciation Type:</label>
                <select id="slct_dprctin"></select>
            </div>
            <div class="col-lg-3 col-md-3 col-sm-4">
                <label>Salvage Value:</label>
                <input type="text" name="Salvage Value" id="slvg_value" />
            </div>
            <div class="col-lg-3 col-md-3 col-sm-4">
                <label>Asset Type:</label>
                <select id="asst_type"></select>
            </div>

        </div>
        <div class="row">
            <div class="col-lg-3 col-md-3 col-sm-4">
                <label>Asset Account:</label>
                <select id="ddlassetaccount"></select>
            </div>
            <div class="col-lg-3 col-md-3 col-sm-4">
                <label>Accumlated Dep Account:</label>
                <select id="ddlaccumlate_acc"></select>
            </div>
            <div class="col-lg-3 col-md-3 col-sm-4">
                <label>Depereciation Account:</label>
                <select id="ddldep_Account"></select>
            </div>
        </div>
        <div class="row" style="margin-top: 20px;">
            <div class="col-lg-3 col-md-3 col-sm-4 checkbox-align">
                <label for="chk_moveable">Moveable:</label>
                <input type="checkbox" name="Moveable" id="chk_moveable" />
            </div>

            <div class="col-lg-3 col-md-3 col-sm-4 checkbox-align">
                <label for="chk_active">Active:</label>
                <input type="checkbox" id="chk_active" />
            </div>

        </div>
        <h3>COST</h3>
        <div class="row">
            <div class="col-lg-1 col-md-1 col-sm-2">
                <input type="button" id="btn_fill" class="btn btn-primry col-lg-2" onclick="Addrow();" value="Fill" />
            </div>
        </div>

        <table class="table_cst table" id="table_cost">



            <tr>
                <th style="text-align: center;">Date
                </th>
                <th style="text-align: center;">Ref.#
                </th>
                <th style="text-align: center;">Amount
                </th>
                <th style="text-align: center;">GRN No.
                </th>
                <th style="text-align: center;">GRN Date
                </th>
                <th style="text-align: center;">MIR No.
                </th>
                <th style="text-align: center;">MIR Date
                </th>

                <th style="text-align: center;">Action
                </th>
            </tr>
        </table>
        <div class="row table_land container-fluid" id="table_land">
            <div class="col-lg-12">
                <h3>Land</h3>
            </div>
            <div class="row">

                <div class="col-lg-3 col-md-3">
                    <label>Land Area:</label>
                    <input type="text" name="land area" id="txt_land_area" class="form-control" />
                </div>
                <div class="col-lg-3 col-md-3">
                    <label>Land Acquire From:</label>
                    <input type="text" name="land acq frm" id="txt_ld_acq_frm" class="form-control" />
                </div>
                <div class="col-lg-3 col-md-3">
                    <label>Land Kasra No:</label>
                    <input type="text" name="land kasra" id="txt_lnd_ksra" class="form-control" />
                </div>
                <div class="col-lg-3 col-md-3">
                    <label>Land Katoni No:</label>
                    <input type="text" name="land katoni" id="txt_lnd_ktoni" class="form-control" />
                </div>
            </div>
            <div class="row">
                <div class="col-lg-3 col-md-3">
                    <label>Land Khawet No:</label>
                    <input type="text" name="land khawet" id="txt_lnd_khwt" class="form-control" />

                </div>
            </div>

        </div>



        <div class="row table_build container-fluid" id="table_build">
            <div class="col-lg-12">
                <h3>Building</h3>
            </div>
            <div class="row">
                <div class="col-lg-3 col-md-3">
                    <label>Building No of Rooms:</label>
                    <input type="text" name="build room" id="txt_bld_rms" class="form-control" />
                </div>
                <div class="col-lg-3 col-md-3">
                    <label>Building Cover Area:</label>
                    <input type="text" name="build cover" id="txt_bld_cvr" class="form-control" />
                </div>
            </div>
        </div>

        <div class="row table_machine container-fluid" id="table_machine">
            <div class="col-lg-12">
                <h3>Machinery</h3>
            </div>
            <div class="row">
                <div class="col-lg-3 col-md-3">
                    <label>Plot No:</label>
                    <input type="text" name="plot no" id="txt_plot_no" class="form-control" />
                </div>
                <div class="col-lg-3 col-md-3">
                    <label>Capacity:</label>
                    <input type="text" name="Capacity" id="txt_capacty" class="form-control" />
                </div>
                <div class="col-lg-3 col-md-3">
                    <label>Model:</label>
                    <input type="text" name="Model" id="txt_model" class="form-control" />
                </div>
                <div class="col-lg-3 col-md-3">
                    <label>Power KVA:</label>
                    <input type="text" name="Power KVA" id="txt_per_kva" class="form-control" />
                </div>
            </div>
            <div class="row mt-3">
                <div class="col-lg-3 col-md-3">
                    <label>Conversion Rate:</label>
                    <input type="number" name="Conversion Rate" id="txt_convrsin_rate" class="form-control" />
                </div>
                <div class="col-lg-3 col-md-3">
                    <label>Serial No:</label>
                    <input type="text" name="Serial no" id="txt_srl_no" class="form-control" />
                </div>
                <div class="col-lg-3 col-md-3">
                    <label>Make:</label>
                    <input type="text" name="make" id="txt_make" class="form-control" />
                </div>
                <div class="col-lg-3 col-md-3">
                    <label>Currency:</label>
                    <input type="text" name="Currency" id="txt_curncy" class="form-control" />
                </div>
            </div>
            <div class="row mt-3">
                <div class="col-lg-3 col-md-3">
                    <label>Power Hp:</label>
                    <input type="text" name="Power hp" id="txt_pwr_hp" class="form-control" />
                </div>
                <div class="col-lg-3 col-md-3">
                    <label>Machinery Cost FC:</label>
                    <input type="text" name="machine cost" id="txt_mchn_cost" class="form-control" />
                </div>
                <div class="col-lg-3 col-md-3">
                    <label>Plant Type:</label>
                    <select id="slct_plnt_typ" class="form-control">
                        <option>Please Select</option>
                        <option>Local</option>
                        <option>Imported</option>
                    </select>
                </div>
            </div>
        </div>

        <div class="row table_vehicles" id="table_vehicles">
            <div class="col-lg-12">
                <h3>Vehicles</h3>
            </div>
            <div class="row">
                <div class="col-lg-4 col-md-4">
                    <label>Registration No:</label>
                    <input type="text" name="Registration no" id="txt_reg_no" class="form-control" />
                </div>
                <div class="col-lg-4 col-md-4">
                    <label>Registration Date:</label>
                    <input type="text" name="Registration date" id="txt_reg_date" class="form-control" />
                </div>
                <div class="col-lg-4 col-md-4">
                    <label>Model:</label>
                    <input type="text" name="vmodel" id="txt_vmodel" class="form-control" />
                </div>
            </div>
            <div class="row mt-3">
                <div class="col-lg-4 col-md-4">
                    <label>Engine No:</label>
                    <input type="text" name="Engine no" id="txt_eng_no" class="form-control" />
                </div>
                <div class="col-lg-4 col-md-4">
                    <label>Chassis No:</label>
                    <input type="text" name="Chassis no" id="txt_chse_no" class="form-control" />
                </div>
                <div class="col-lg-4 col-md-4">
                    <label>Vehicle Type:</label>
                    <select id="slct_vtype" class="form-control">
                        <option>Please Select</option>
                        <option>Commercial</option>
                        <option>Non-Commercial</option>
                    </select>
                </div>
            </div>
            <div class="row mt-3">
                <div class="col-lg-4 col-md-4">
                    <label>Color:</label>
                    <input type="text" name="Color" id="txt_vcolor" class="form-control" />
                </div>
                <div class="col-lg-4 col-md-4">
                    <label>Make:</label>
                    <input type="text" name="make" id="txt_vmake" class="form-control" />
                </div>
                <div class="col-lg-4 col-md-4">
                    <label>CD:</label>
                    <input type="text" name="cd" id="txt_cd" class="form-control" />
                </div>
            </div>
        </div>

        <div class="row table_computer" id="table_computer">
            <div class="col-lg-12">
                <h3>Computers</h3>
            </div>
            <div class="row">
                <div class="col-lg-6 col-md-6">
                    <label>Board:</label>
                    <input type="text" name="Board" id="txt_board" class="form-control" />
                </div>
                <div class="col-lg-6 col-md-6">
                    <label>Ram:</label>
                    <input type="text" name="Ram" id="txt_ram" class="form-control" />
                </div>
            </div>
            <div class="row mt-3">
                <div class="col-lg-6 col-md-6">
                    <label>Processor:</label>
                    <input type="text" name="Processor" id="txt_procser" class="form-control" />
                </div>
                <div class="col-lg-6 col-md-6">
                    <label>Hard Disk:</label>
                    <input type="text" name="Hard Disk" id="txt_disk" class="form-control" />
                </div>
            </div>
            <div class="row mt-3">
                <div class="col-lg-12">
                    <label>Name:</label>
                    <input type="text" name="comp_name" id="txt_comp_name" class="form-control" />
                </div>
            </div>
        </div>

        <div class="row table_furniture" id="table_furniture">
            <div class="col-lg-12">
                <h3>Furniture</h3>
            </div>
            <div class="row">
                <div class="col-lg-6 col-md-6">
                    <label>Capacity:</label>
                    <input type="text" name="capacity" id="txt_Cap" class="form-control" />
                </div>
                <div class="col-lg-6 col-md-6">
                    <label>Convertible:</label>
                    <input type="text" name="convert" id="txt_Conv" class="form-control" />
                </div>
            </div>
            <div class="row mt-3">
                <div class="col-lg-6 col-md-6">
                    <label>Usage:</label>
                    <input type="text" name="usage" id="txt_usage" class="form-control" />
                </div>
                <div class="col-lg-6 col-md-6">
                    <label>Length:</label>
                    <input type="text" name="Length" id="txt_Length" class="form-control" />
                </div>
            </div>
            <div class="row mt-3">
                <div class="col-lg-6 col-md-6">
                    <label>Width:</label>
                    <input type="text" name="Width" id="txt_Width" class="form-control" />
                </div>
            </div>
        </div>



        <div class="row">
            <div class="col-lg-8 col-md-8 col-sm-8">
                <div class="col-lg-2 col-md-2  col-sm-3">
                    <input type="button" id="btn_save" class="btn btn-primry" value="Save" />
                </div>
                <div class="col-lg-2 col-md-2  col-sm-3">
                    <input type="button" id="btn-new" onclick="window.location = 'AddAssetSelection.aspx'" class="btn btn-yellow" value="New" />
                </div>
                <div class="col-lg-2 col-md-2 col-sm-3">
                    <input type="button" id="btn_back" class="btn btn-yellow" onclick="window.location = 'AssetDefinitionList.aspx'" value="View" />
                </div>
            </div>
        </div>
        <input type="hidden" id="hditemID" />
    </form>
</asp:Content>


