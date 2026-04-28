<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="panelagreement.aspx.cs" Inherits="PMS.panelagreement" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

     <link href="../../wwwroot/Tibbit_theme/css/CustomCss/swalalert.css" rel="stylesheet" />
    <script type="text/javascript">

        $(document).ready(function () {
            loadItemList();
            FillMainTestDepartment();
            loadGlAccounts();
            $('#ddlGlAccount').select2();
            var id = '<% =Request.QueryString["ID"] %>';
            if (id != "") {
                $('#btnSave').val('Update');
                LoadPanelData(id);
                $('#tblItemDescriptionDetail').html('<tr><td colspan="3">Loading services...</td></tr>');
                ajaxCall("panelagreement.aspx/loadData", JSON.stringify({ "panelID": id }), getResponseData);
            }
            $('#btnNew').on('click', function () {

                window.location.href = "panelagreement.aspx";
            });
            $('#btnList').on('click', function () {

                window.location.href = "PanelView.aspx";
            })
            $('#btnSave').on('click', function () {
                debugger;
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
                else if (Glcode == 0) {
                    valid = false;
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Please Enter GL Account.',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });


                }
                if ($(cmp_nameV).val() == '') $(cmp_nameV).addClass('ErrorAlert'); else $(cmp_nameV).removeClass('ErrorAlert');
                if ($(no_of_empV).val() == '') $(no_of_empV).addClass('ErrorAlert'); else $(no_of_empV).removeClass('ErrorAlert');
                if ($(emailV).val() == '') $(emailV).addClass('ErrorAlert'); else $(emailV).removeClass('ErrorAlert');
                if ($(addressV).val() == '') $(addressV).addClass('ErrorAlert'); else $(addressV).removeClass('ErrorAlert');      
                if ($(emailV).val() == '') $(emailV).addClass('ErrorAlert'); else $(emailV).removeClass('ErrorAlert');
                if ($(contact_noV).val() == '') $(contact_noV).addClass('ErrorAlert'); else $(contact_noV).removeClass('ErrorAlert');
                if (!$("#txtCompanyName").hasClass('ErrorAlert') && !$("#txtEmail").hasClass('ErrorAlert') && !$("#txtAddress").hasClass('ErrorAlert') && !$("#txtContactNo").hasClass('ErrorAlert') && !$("#txtDiscount").hasClass('ErrorAlert') && !$("#txtEmpNo").hasClass('ErrorAlert')) {



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
                                alert("Data has been saved successfully");
                                window.location.href = "panelagreement.aspx?ID=" + data;
                            }, error: function () { }
                        });
                    }

                }
            })

        });
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
                '<input type="text" name="tbltxt_ServicesName" id="tbltxt_ServicesName" value="' + itemName + '"/>' +
                '</td>' +
                '<td>' +
                '<input type="text" name="tbltxt_Rate" id="tbltxt_Description" value="' + Rate + '"/>' +
                '</td>' +
                '<td style="Display:None">' +
                '<input type="text"  value="' + testGroupCatVal + '"/>' +
                '</td>' +
                '<td style="Display:None">' +
                '<input type="text"  value="' + getTestID + '"/>' +
                '</td>' +

                '<td><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="glyphicon glyphicon-trash" style="width:15px !important;font-size: 13px;color:#f30a0a;position:relative;" i=""></i></a>' +
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
        function AddTestRow() {
            debugger;
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
                        '<td><input type="text" name="tbltxt_ServicesName" value="' + (item.Description || '') + '" readonly/></td>' +
                        '<td><input type="text" name="tbltxt_Rate" value="' + (item.Rate || '0') + '"/></td>' +
                        '<td style="display:none"><input type="text" value="' + (item.GroupCategory || '') + '"/></td>' +
                        '<td style="display:none"><input type="text" value="' + (item.TestID || '') + '"/></td>' +
                        '<td><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)">' +
                        '<i class="glyphicon glyphicon-trash" style="width:15px !important;font-size: 13px;color:#f30a0a;position:relative;"></i>' +
                        '</a></td>' +
                        '</tr>';
                }
                $('#tblItemDescriptionDetail').html(allRows);
            } catch (e) {
                console.error("Error loading service rows:", e);
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
    <div class="row">
        <div class="col-lg-3 col-md-6 col-sm-12">
            <label>Company Name</label>
            <input type="text" name="txtCompanyName" class="input_width form-control" id="txtCompanyName" />
        </div>
        <div class="col-lg-3 col-md-6 col-sm-12">
            <label>No of Employee</label>
            <input type="text" name="txtEmpNo" class="form-control" id="txtEmpNo" />
        </div>

        <div class="col-lg-3 col-md-6 col-sm-12">
            <label>Email</label>
            <input type="text" name="txtEmail" class="input_width form-control" id="txtEmail" />
        </div>

        <div class="col-lg-2 col-md-6 col-sm-12">
            <label>Rate OPD</label>
            <input type="text" name="txtrate" class="input_width form-control" id="txtpanelrate" />
        </div>
        <div class="col-lg-1 col-md-6 col-sm-12">
            <label>Rate Emergency</label>
            <input type="text" name="txtrate" class="input_width form-control" id="txtpanelrateEmergency" />
        </div>
    </div>

    <div class="row">
        <div class="col-lg-3 col-md-6 col-sm-12">
            <label>Contact No</label>
            <input type="text" name="txtContactNo" class="form-control" id="txtContactNo" />
        </div>

        <div class="col-lg-3 col-md-6 col-sm-12">
            <label>Address</label>
            <input type="text" name="txtAddress" class="input_width form-control" id="txtAddress" />
        </div>

        <div class="col-lg-3 col-md-6 col-sm-12">
            <label>Discount</label>
            <input type="text" name="txtDiscount" class="form-control" id="txtDiscount" />
        </div>

        <div class="col-lg-3 col-md-6 col-sm-12">
            <label>Gl Account</label>
            <select id="ddlGlAccount"></select>
        </div>
    </div>

    <div class="row">
        <div class="col-lg-2 col-md-3 col-sm-4">
            <label id="lb_services">Services</label>
            <select id="ddltble_Services" name="ddltble_Services" onchange="onSelection()"></select>

        </div>
        <div class="col-lg-1 col-md-3 col-sm-4">
            <label></label>
            <input type="button" onclick="Addrow()" class="btn btn-primry" value="Add" id="AddAccount" />
        </div>
        <div class="col-lg-2 col-md-3 col-sm-4">
            <label></label>
            <input type="button" onclick="AddAllrow()" class="btn btn-primry" value="Add All Services" id="AddallAccount" />
        </div>
        <div class="col-lg-2 col-md-3 col-sm-4">
            <label>Test Department</label>
            <select id="ddlMainTestDepartment" onchange="LoadTestByDepartment()">
                <option value="">Select Department</option>
            </select>

        </div>
        <div class="col-lg-2 col-md-3 col-sm-4">
            <label id="test">Test</label>
            <select id="ddlTestList">
            </select>
        </div>
        <div class="col-lg-1 col-md-3 col-sm-4">
            <label></label>
            <input type="button" onclick="AddTestRow()" class="btn btn-primry" value="Add Test" id="AddTests" />
        </div>
        <div class="col-lg-2 col-md-3 col-sm-4">
            <label></label>
            <input type="button" onclick="AddallTest()" class="btn btn-primry" value="Add All Test" id="AddallTests" />
        </div>
    </div>
    <div class="row">
        <div class="col-xs-12 col-sm-12 col-lg-12 col-md-12" style="overflow: scroll; width: 100%;">


            <table class="table table-bordered" id="tblItemDescription">
                <thead>
                    <tr>
                        <th style="width: 15%;">Services Name</th>
                        <th style="width: 26%;">Rate</th>
                        <th style="width: 15%">Action</th>
                    </tr>
                </thead>
                <tbody id="tblItemDescriptionDetail">
                </tbody>
            </table>
        </div>
    </div>

    <div class="row">
        <div class="col-lg-1 col-md-4 col-sm-6">
            <input type="button" class="btn btn-primry" id="btnSave" value="Save" />
        </div>
        <div class="col-lg-1 col-md-4 col-sm-6">
            <input type="button" class="btn btn-yellow" id="btnNew" value="New" />
        </div>
        <div class="col-lg-1 col-md-4 col-sm-6">
            <input type="button" class="btn-gray" id="btnList" value="view" />
        </div>
    </div>






</asp:Content>
