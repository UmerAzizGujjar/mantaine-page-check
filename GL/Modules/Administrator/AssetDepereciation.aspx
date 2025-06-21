<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AssetDepereciation.aspx.cs" Inherits="PMS.Modules.Administrator.AssetDepereciation" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script type="text/javascript">
        $(document).ready(function () {
            /*$("#btn_Approve").hide();*/
            $('#txtstartdate').datepicker({ dateFormat: 'dd M yy' });
            $('#txtenddate').datepicker({ dateFormat: 'dd M yy' });
            var date = '<%= DateTime.Now%>';
            date = moment(date).format('LL');
            $("#txtDate").val(date);
            $("#ddl_year").hide();
            $("#ddl_month").hide();
            LoadTransType();
            LoadYears();
            LoadMonth();
            CheckPolicy();
            var id = '<%=Request.QueryString["ID"]%>';
            if (id != "") {
                $("#btnSave").val('Update');
                $('#ddl_transType').attr('disabled', true);
                $('#ddlMonth').attr('disabled', true);
                $('#txtReg_no').attr('disabled', true);
                $('#txtRemarks').attr('disabled', true);
                $('#btn_save').attr('disabled', true);


                getRecords(id);
            }
            else {
                $('#ddl_transType').select2();
                $('#ddlYears').select2();
                $('#ddlMonth').select2();
            }
        });
        function getRecords(id) {
            $.ajax({
                type: "POST",
                url: "AssetDepereciation.aspx/getRecords",
                data: JSON.stringify({ "id": id }),

                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var parsed_data = JSON.parse(response.d);
                    console.log(parsed_data);
                    debugger;
                    $("#ddl_transType").val(parsed_data[0].Trans_type);
                    $("#transactionno").val(parsed_data[0].Trans_type);
                    $("#txtRemarks").val(parsed_data[0].Trans_type);


                    $("#txtReg_no").val(parsed_data[0].Register_No);
                    $("#txtRemarks").val(parsed_data[0].Remarks);


                    var isApproved = parsed_data[0].is_Approved;

                    if (isApproved == 1) {
                        $("#approve-div").hide();
                        $("#unapprove-div").show();
                    } else {
                        $("#unapprove-div").hide();
                        $("#approve-div").show();
                    }



                   
                    var Reg_Date = parsed_data[0].Date;

                    if (Reg_Date == null || Reg_Date == "null" || Reg_Date == "" || Reg_Date == '') {
                    }
                    else {
                        var date = parsed_data[0].Date;
                        date = moment(date).format('DD-MMM-YYYY');
                    }
                    

                    setTimeout(function () {
                        GetDepereciation_Result(id)

                        /*$("#btn_Approve").show();*/
                    }, 2000)




                }

            });
        }
        function GetDepereciation_Result(id) {
            $.ajax({
                type: "POST",
                url: "AssetDepereciation.aspx/GetDepreciation_Result",
                data: JSON.stringify({ "id": id }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
                    var tbody = $('#tblDepreciation tbody');
                    tbody.empty(); // Clear existing rows if needed

                    var arrData = JSON.parse(response.d);
                    $.each(arrData, function (i, item) {

                        console.log(arrData);
                        var row = '<tr>' +
                            '<td>' +
                            '<a href="javascript:void(0);" onclick="showPopup(' + item.Asset_Def_ID + ')" style="cursor:pointer; border-radius: 4px; background-color: #d88c2c; color: white; padding: 5px 8px;">' +
                            '<i class="fa fa-eye text-white" style="margin-top:10px;"></i>' +
                            '</a>' +
                            '</td>' +
                            '<td><input type="text" id="assetId_' + i + '" name="assetId" class="form-control" value="' + item.Asset_Def_ID + '" readonly /></td>' +
                            '<td><input type="text" id="desc_' + i + '" name="desc" class="form-control" value="' + item.Asset_description + '" readonly /></td>' +
                            '<td><input type="text" id="nodays_' + i + '" name="nodays" class="form-control" value="' + item.no_of_days + '" readonly /></td>' +
                            '<td><input type="text" id="Depr_Cost_' + i + '" name="Depr_Cost" class="form-control" value="' + item.Dep_Cost + '" readonly /></td>' +
                            '<td><input type="text" id="Depreciation' + i + '" name="Depreciation" class="form-control" value="' + item.Depreciation_perc + '" readonly /></td>' +
                            '<td><input type="text" id="DepAmount_' + i + '" name="DepAmount" class="form-control" value="' + item.Depereciation_Amount_charge + '" readonly /></td>'
                            + '<td style="display:none"><input type="text" id="Accumulated_acc_' + i + '" name="Accumulated_acc" class="form-control" value="' + item.Credit_Account_id + '" readonly /></td>'
                            + '<td style="display:none"><input type="text" id="Depreciation_Acc_' + i + '" name="Depreciation_Acc" class="form-control" value="' + item.debit_account_id + '" readonly /></td>' +
                            '<td>' +
                            '<td style="display:none"><input type="text" id="Asset_Dep_Detai_Id_' + i + '" name="Asset_Dep_Detai_Id" class="form-control" value="' + item.Asset_Dep_Detai_Id + '" readonly /></td>' +
                            '<td>' +
                            '<a href="javascript:void(0);" onclick="deleteRow(this)" style="cursor:pointer; border-radius: 4px; background-color: #d91212; color: white; padding: 5px 8px;">' +
                            '<i class="fa fa-trash" style="color:white;margin-top:10px;"></i>' +
                            '</a>' +
                            '</td>' +
                            '</tr>';

                        tbody.append(row);
                    });

                    $("#btn_save").val('Update');
                },
                error: function () {
                    console.error("Error retrieving depreciation data.");
                }
            });
        }
        function SaveRecord_Depreciation() {
            var btnSave = $("#btn_save").val();
            var Trans_Type = $("#ddl_transType").val();

            if (Trans_Type == 0 || Trans_Type == "0" || Trans_Type == '0' || Trans_Type == "") {
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
                console.error("Error: Trans_Type is required.");
                return;
            }

            var ddlMonth = $("#ddlMonth").val();
            var ddlMonth_text = $("#ddlMonth").find('option:selected').text();
            var ddlYears = $("#ddlYears").find('option:selected').text();
            var Date = $("#txtDate").val();
            var Reg_No = $("#txtReg_no").val();
            var id = '<%=Request.QueryString["ID"]%>';
            console.log(id);

            var table = $('#tblDepreciation');
            var list = [];

            table.find('tr:gt(0)').each(function (key, value) {
                var assetId = $(value).find('input[name="assetId"]').val();
                var desc = $(value).find('input[name="desc"]').val();
                var nodays = $(value).find('input[name="nodays"]').val();
                var Depr_Cost = $(value).find('input[name="Depr_Cost"]').val();
                var DepAmount = $(value).find('input[name="DepAmount"]').val();
                var Depreciation = $(value).find('input[name="Depreciation"]').val();
                var Accumulated_acc = $(value).find('input[name="Accumulated_acc"]').val();
                var Depreciation_Acc = $(value).find('input[name="Depreciation_Acc"]').val();
                var array = {
                    assetId: assetId,
                    desc: desc,
                    nodays: nodays,
                    Depr_Cost: Depr_Cost,
                    DepAmount: DepAmount,
                    Depreciation: Depreciation,
                    Accumulated_acc: Accumulated_acc,
                    Depreciation_Acc: Depreciation_Acc,
                };

                list.push(array);
            });

            try {
                PageMethods.SaveRecord(
                    Trans_Type,
                    ddlMonth,
                    ddlMonth_text,
                    Reg_No,
                    Date,
                    btnSave,
                    ddlYears,
                    id,
                    list,
                    function (response) {
                        if (response.startsWith("DUPLICATE:")) {
                            var message = response.replace("DUPLICATE:", "");
                            Swal.fire({
                                icon: 'error',
                                title: 'Error!',
                                text: message,
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

                        if (response !== '-1') {
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
                             window.location.href = "AssetDepereciation.aspx";
                        }
                    }
                );
            } catch (error) {
                console.error("Error while saving record:", error);
            }
        }

        function LoadTransType() {
            $.ajax({
                type: "POST",
                url: "AssetDepereciation.aspx/LoadTransType",
                data: "",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    var options = '<option value="0" >Please Select</option>';
                    var values = JSON.parse(data.d);
                    $.each(values, function (key, value) {
                        options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                    });
                    $('#ddl_transType').html(options);

                },
                failure: function (response) {
                    alert(response.d);
                }
            });

        }
        function deleteRow(elem) {
            $(elem).closest('tr').remove();
        }
        function showPopup(assetId) {
            console.log("Asset ID:", assetId);
            $('#DeperciationModel').modal('show');
            FillDepreciation(assetId);
        }
        function FillDepreciation(assetId) {
            $.ajax({
                type: "POST",
                url: "AssetDepereciation.aspx/getDepereciationResults",
                data: JSON.stringify({ assetId: assetId }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    var result = JSON.parse(data.d);
                    var tbody = $('#tblDepreciationResult tbody');
                    tbody.empty();

                    if (result.length === 0) {
                        tbody.append('<tr><td colspan="5">No data found for selected asset.</td></tr>');
                    } else {
                        $.each(result, function (i, item) {
                            var row = '<tr>' +
                                '<td>' + item.Asset_description + '</td>' +
                                '<td>' + item.Dep_Cost + '</td>' +
                                '<td>' + item.no_of_days + '</td>' +
                                '<td>' + item.Depreciation_perc + '</td>' +
                                '<td>' + item.Depereciation_Amount_charge + '</td>' +
                                '<td>' + item.created_dep_Date + '</td>' +
                                '</tr>';
                            tbody.append(row);
                        });
                    }

                    // Show the modal only after data is populated
                    $('#DeperciationModel').modal('show');
                },
                error: function (xhr, status, error) {
                    console.error("Error:", error);
                }
            });
        }

        function LoadYears() {
            $.ajax({
                type: "POST",
                url: "AssetDepereciation.aspx/getyears",
                data: "",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    var options = '<option value="0" >Please Select</option>';
                    var values = JSON.parse(data.d);
                    $.each(values, function (key, value) {
                        options += '<option value="' + value.Period_ID + '" >' + value.Year + '</option>';
                    });
                    $('#ddlYears').html(options)

                },
                failure: function (response) {
                    alert(response.d);
                }
            });

        }
        function LoadMonth() {
            $.ajax({
                type: "POST",
                url: "AssetDepereciation.aspx/getMonth",
                data: "",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    var options = '<option value="0" >Please Select</option>';
                    var values = JSON.parse(data.d);
                    $.each(values, function (key, value) {
                        options += '<option value="' + value.Period_ID + '" >' + value.Period_Description + '</option>';
                    });
                    $('#ddlMonth').html(options)

                },
                failure: function (response) {
                    alert(response.d);
                }
            });

        }

        var getAmount;
        function loadData() {
            var Month = $('#ddlMonth option:selected').text();
            var ddlyears = $('#ddlYears').val();
            var Years = $('#ddlYears option:selected').text();

            if (ddlyears != "0") {

                function getDaysInYear(year) {
                    return ((year % 4 === 0 && year % 100 !== 0) || (year % 400 === 0)) ? 366 : 365;
                }

                $.ajax({
                    type: "POST",
                    url: "AssetDepereciation.aspx/getDepereciationDataYearly",
                    data: JSON.stringify({ Years: Years }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (data) {
                        let result = [];

                        try {
                            result = JSON.parse(data.d);
                        } catch (e) {
                            console.error("Failed to parse result", e);
                        }

                        const tbody = $('#tblDepreciation tbody');
                        tbody.empty();

                        if (!result || result.length === 0) {
                            tbody.append('<tr><td colspan="5">No data found for selected dates.</td></tr>');
                            return;
                        }



                        $.each(result, function (i, item) {
                            var totalDaysInYear = getDaysInYear(Years);

                            var Deprec_perc = item.Depreciation;
                            var roundedCost = Math.round(item.Capitilization_Cost);
                            var dep_perc_amount = Math.round(Math.round(roundedCost * Deprec_perc) / 100);
                            var days_count = item.DaysCount;

                            if (days_count < totalDaysInYear) {
                                getAmount = Math.round((dep_perc_amount / 365) * days_count);
                            }
                            if (days_count == totalDaysInYear) {
                                var dep_perc_amount = Math.round(Math.round(roundedCost * Deprec_perc) / 100);

                                getAmount = Math.round(dep_perc_amount);
                            }
                            var capitalizationDate = new Date(item.Capitilization_Date);
                            var today = new Date();
                            var diffInTime = today - capitalizationDate;
                            var diffInDays = Math.floor(diffInTime / (1000 * 3600 * 24));
                                var assetLifeDays = item.Asset_lifeDays;
                                if (diffInDays >= assetLifeDays) {
                                    return true;
                                }

                            var row = '<tr>' +
                                '<td>' +
                                '<a href="javascript:void(0);" onclick="showPopup(' + item.Asset_Definition_Id + ')" style="cursor:pointer; border-radius: 4px; background-color: #d88c2c; color: white; padding: 5px 8px;">' +
                                '<i class="fa fa-eye text-white" style="margin-top:10px;"></i>' +
                                '</a>' +
                                '</td>' +
                                '<td><input type="text" id="assetId_' + i + '" name="assetId" class="form-control" value="' + item.Asset_Definition_Id + '" readonly /></td>' +
                                '<td><input type="text" id="desc_' + i + '" name="desc" class="form-control" value="' + item.Item_Description + '" readonly /></td>' +
                                '<td><input type="text" id="nodays_' + i + '" name="nodays" class="form-control" value="' + item.DaysCount + '" readonly /></td>' +
                                '<td style="display:none;"><input type="hidden" id="catId_' + i + '" name="catId" value="' + item.Asset_Cat_id + '" readonly /></td>' +
                                '<td><input type="text" id="Depr_Cost_' + i + '" name="Depr_Cost" class="form-control" value="' + item.Capitilization_Cost + '" readonly /></td>' +
                                '<td><input type="text" id="Depreciation' + i + '" name="Depreciation" class="form-control" value="' + item.Depreciation + '" readonly /></td>' +
                                '<td style="display:none;"><input type="text" id="Accumulated_acc_' + i + '" name="Accumulated_acc" class="form-control" value="' + item.Acc_Depreciation_Acc + '" readonly /></td>' +
                                '<td style="display:none;"><input type="text" id="Depreciation_Acc_' + i + '" name="Depreciation_Acc" class="form-control" value="' + item.Depreciation_Acc + '" readonly /></td>' +
                                '<td><input type="text" id="DepAmount_' + i + '" name="DepAmount" class="form-control" value="' + getAmount + '" readonly /></td>' +
                                '<td>' +
                                '<a href="javascript:void(0);" onclick="deleteRow(this)" style="cursor:pointer; border-radius: 4px; background-color: #d91212; color: white; padding: 5px 8px;">' +
                                '<i class="fa fa-trash" style="color:white;margin-top:10px;"></i>' +
                                '</a>' +
                                '</td>' +
                                '</tr>';
                            tbody.append(row);
                        });
                    },
                    error: function (xhr, status, error) {
                        console.error("AJAX error:", error);
                        alert("Something went wrong. Please check console.");
                    }
                });
            }

            if (Month != "Please Select") {
                var Month = $('#ddlMonth option:selected').text();
                var parts = Month.split('-');
                var monthShort = parts[0];
                var year = parseInt(parts[1], 10);

                var monthMap = {
                    Jan: 0, Feb: 1, Mar: 2, Apr: 3, May: 4, Jun: 5,
                    Jul: 6, Aug: 7, Sep: 8, Oct: 9, Nov: 10, Dec: 11
                };

                $.ajax({
                    type: "POST",
                    url: "AssetDepereciation.aspx/getDepereciationData",
                    data: JSON.stringify({ Month: Month }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (data) {
                        var result = JSON.parse(data.d);
                        var tbody = $('#tblDepreciation tbody');
                        tbody.empty();

                        if (result.length === 0) {
                            tbody.append('<tr><td colspan="5">No data found for selected dates.</td></tr>');
                        } else {
                            $.each(result, function (i, item) {

                                var monthIndex = monthMap[monthShort];
                                var totalDaysInMonth = new Date(year, monthIndex + 1, 0).getDate();
                                var days_count = item.DaysCount;
                                var Deprec_perc = item.Depreciation;
                                var roundedCost = Math.round(item.Capitilization_Cost);
                                var dep_perc_amount = Math.round(Math.round(roundedCost * Deprec_perc) / 100);

                                if (days_count < totalDaysInMonth) {
                                    getAmount = Math.round((dep_perc_amount / totalDaysInMonth) * days_count);
                                }
                                if (days_count == totalDaysInMonth) {
                                    var dep_perc_amount = Math.round(Math.round(roundedCost * Deprec_perc) / 100);

                                    getAmount = Math.round(dep_perc_amount);
                                }
                                var capitalizationDate = new Date(item.Capitilization_Date);
                                var today = new Date();
                                var diffInTime = today - capitalizationDate;
                                var diffInDays = Math.floor(diffInTime / (1000 * 3600 * 24));
                                    var assetLifeDays = item.Asset_lifeDays;
                                    if (diffInDays >= assetLifeDays) {
                                        return true;
                                    }
                                var row = '<tr>' +
                                    '<td>' +
                                    '<a href="javascript:void(0);" onclick="showPopup(' + item.Asset_Definition_Id + ')" style="cursor:pointer; border-radius: 4px; background-color: #d88c2c; color: white; padding: 5px 8px;">' +
                                    '<i class="fa fa-eye text-white" style="margin-top:10px;"></i>' +
                                    '</a>' +
                                    '</td>' +
                                    '<td><input type="text" id="assetId_' + i + '" name="assetId" class="form-control" value="' + item.Asset_Definition_Id + '" readonly /></td>' +
                                    '<td><input type="text" id="desc_' + i + '" name="desc" class="form-control" value="' + item.Item_Description + '" readonly /></td>' +
                                    '<td><input type="text" id="nodays_' + i + '" name="nodays" class="form-control" value="' + item.DaysCount + '" readonly /></td>' +
                                    '<td style="display:none;"><input type="hidden" id="catId_' + i + '" name="catId" value="' + item.Asset_Cat_id + '" readonly /></td>' +
                                    '<td><input type="text" id="Depr_Cost_' + i + '" name="Depr_Cost" class="form-control" value="' + item.Capitilization_Cost + '" readonly /></td>' +
                                    '<td><input type="text" id="Depreciation_per' + i + '" name="Depreciation" class="form-control" value="' + item.Depreciation + '" readonly /></td>' +
                                    '<td style="display:none;"><input type="text" id="Accumulated_acc_' + i + '" name="Accumulated_acc" class="form-control" value="' + item.Acc_Depreciation_Acc + '" readonly /></td>' +
                                    '<td style="display:none;"><input type="text" id="Depreciation_Acc_' + i + '" name="Depreciation_Acc" class="form-control" value="' + item.Depreciation_Acc + '" readonly /></td>' +
                                    '<td><input type="text" id="DepAmount_' + i + '" name="DepAmount" class="form-control" value="' + getAmount + '" readonly /></td>' +
                                    '<td>' +
                                    '<a href="javascript:void(0);" onclick="deleteRow(this)" style="cursor:pointer; border-radius: 4px; background-color: #d91212; color: white; padding: 5px 8px;">' +
                                    '<i class="fa fa-trash" style="color:white;margin-top:10px;"></i>' +
                                    '</a>' +
                                    '</td>' +
                                    '</tr>';
                                tbody.append(row);
                            });
                        }
                    },
                    failure: function (response) {
                        alert("Error: " + response.d);
                    }

                });
            }



        }
        var monthlyPolicy;
        var yearlyPolicy;
        function CheckPolicy() {
            debugger;
            $.ajax({
                type: "POST",
                url: "AssetDepereciation.aspx/Check_DepPolicy",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
                    var policies = response.d;
                    debugger;
                    monthlyPolicy = policies.Monthly;
                    yearlyPolicy = policies.Yearly;

                    if (monthlyPolicy) {
                        $("#ddl_month").show();
                        $("#ddl_year").hide();

                    } else if (yearlyPolicy) {
                        $("#ddl_year").show();
                        $("#ddl_month").hide();
                    }
                },
                failure: function (response) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Failed to retrieve depreciation policies',
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


        function ApproveDepreciation() {
            $('#tblDepreciation tbody tr').each(function (key, value) {
                var assetDetailId = $(value).find('td input[name="Asset_Dep_Detai_Id"]').val();
                console.log(assetDetailId);

                PageMethods.approveAssetDep(assetDetailId, function (response) {
                    var data = response;
                    if (data == "Success") {
                        Swal.fire({
                            icon: 'success',
                            title: 'Success!',
                            text: 'Approve Depereciation Successfully.',
                            showConfirmButton: false,
                            timer: 2500,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });
                     }
                });
            });

            window.location.href = 'AssetDepreciationView.aspx';
        }
        function UnApproveDepreciation() {
            $('#tblDepreciation tbody tr').each(function (key, value) {
                var assetDetailId = $(value).find('td input[name="Asset_Dep_Detai_Id"]').val();
                console.log(assetDetailId);

                PageMethods.UnapproveAssetDep(assetDetailId, function (response) {
                    var data = response;
                    if (data == "Success") {
                        Swal.fire({
                            icon: 'success',
                            title: 'Success!',
                            text: 'Approve Depereciation Successfully.',
                            showConfirmButton: false,
                            timer: 2500,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });
                    }
                });
            });

            window.location.href = 'AssetDepreciationView.aspx';
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <input type="hidden" />
    <div class="row">
        <div class="col-lg-3 col-md-3 col-sm-4">
            <label>Trans Type:</label>
            <select id="ddl_transType"></select>
        </div>
        <div class="col-lg-3 col-md-3 col-sm-4" id="ddl_year">
            <label>Year:</label>
            <select id="ddlYears"></select>
        </div>
        <div class="col-lg-3 col-md-3 col-sm-4" id="ddl_month">
            <label>Month:</label>
            <select id="ddlMonth"></select>
        </div>
        <div class="col-lg-3 col-md-3 col-sm-4">
            <label>Date</label>
            <input type="text" name="Date" disabled id="txtDate" />
        </div>
        <div class="col-lg-3 col-md-3 col-sm-4">
            <label>Registration No</label>
            <input type="text" name="txtReg_no" id="txtReg_no" />
        </div>


    </div>
    <div class="row" style="display: none;">
        <div class="col-lg-3 col-md-3 col-sm-4">
            <label>Start Date:</label>
            <input type="text" name="txtstartdate" id="txtstartdate" />
        </div>
        <div class="col-lg-3 col-md-3 col-sm-4">
            <label>End Date:</label>
            <input type="text" name="txtenddate" id="txtenddate" />
        </div>
    </div>
    <div class="row">

        <div class="col-lg-6 col-md-3 col-sm-4">
            <label>Remarks</label>
            <input type="text" id="txtRemarks" />
        </div>

        <div class="col-lg-2 col-md-2 col-sm-2">
            <label></label>
            <input type="button" value="Load" class="btn btn-primry" id="btnload" onclick="loadData()" />
        </div>


    </div>

    <table class="table" id="tblDepreciation">
        <thead>
            <tr>
                <th>Check</th>
                <th>Code</th>
                <th>Description</th>
                <th>No Of Days</th>
                <th>Cost Amount</th>
                <th>Depereciation %</th>
                <th>Depereciation Amount</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody>
        </tbody>
    </table>

    <div class="row">
        <div class="col-lg-8 col-md-8 col-sm-8">
            <div class="col-lg-2 col-md-2  col-sm-3">
                <input type="button" id="btn_save" class="btn btn-yellow" value="Save" onclick="SaveRecord_Depreciation()" />
            </div>
            <div class="col-lg-2 col-md-2  col-sm-3">
                <input type="button" id="btn-new" onclick="window.location = 'AssetDepereciation.aspx'" class="btn btn-yellow" value="New" />
            </div>
            <div class="col-lg-2 col-md-2 col-sm-3">
                <input type="button" id="btn_back" class="btn btn-yellow" onclick="window.location = 'AssetDepreciationView.aspx'" value="View" />
            </div>
            <div class="col-lg-2 col-md-2 col-sm-3" id="approve-div" style="display:none">
                <input type="button" id="btn_Approve"  class="btn btn-yellow" value="Approve" onclick="ApproveDepreciation()" />
            </div>  
            <div class="col-lg-2 col-md-2 col-sm-3" id="unapprove-div" style="display:none">
                <input type="button" id="btn_UnApprove"  class="btn btn-yellow" value="UnApprove" onclick="UnApproveDepreciation()" />
            </div>
        </div>
    </div>
    <!-- Modal -->
    <div id="DeperciationModel" class="modal fade" data-backdrop="static" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable" role="document">
            <div class="modal-content">
                <div class="modal-body">
                    <fieldset class="form-group">
                        <div class="form-row">
                            <div class="col-md-6">
                                <h5>Depreciation List</h5>

                            </div>
                        </div>
                    </fieldset>
                    <div class="table-responsive" id="">
                        <table class="table table-hover table-striped table-bordered" id="tblDepreciationResult">
                            <thead>
                                <tr>
                                    <th>Description</th>
                                    <th>Depreciation Cost</th>
                                    <th>Deperciation Days</th>
                                    <th>Deperciation Percentage</th>
                                    <th>Amount Charge</th>
                                    <th>Date</th>
                                </tr>
                            </thead>
                            <tbody id="iDepreciationBody">
                            </tbody>
                        </table>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-gray" data-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>

</asp:Content>
