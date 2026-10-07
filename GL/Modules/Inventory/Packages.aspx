<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Packages.aspx.cs" Inherits="PMS.Packages" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        fieldset {
            border: 1px groove #ddd !important;
            padding: 0 1.4em 1.4em 1.4em !important;
            margin: 0 0 1.5em 0 !important;
            -webkit-box-shadow: 0px 0px 0px 0px #000;
            box-shadow: 0px 0px 0px 0px #000;
        }

        legend {
            font-size: 1.2em !important;
            font-weight: bold !important;
            text-align: left !important;
            width: auto;
            padding: 0 10px;
            border-bottom: none;
            margin-bottom: 0px;
        }

        .table {
            margin: 1em 0;
            width: 100%;
            overflow: hidden;
            background: #FFF;
            color: #024457;
            border: 1px solid #167F92;
        }

            .table tr {
                border: 1px solid #D9E4E6;
            }

                .table tr:nth-child(even) {
                    background-color: #EAF3F3;
                }

            .table th {
                display: none;
                border: 1px solid #FFF;
                background-color: #438eb9;
                color: #FFF;
                padding: 1em;
            }

            .table thead th {
                display: table-cell;
                text-align: center;
            }

        @media (min-width: 480px) {
            .table th:nth-child(2) span {
                display: block;
            }

            .table th:nth-child(2):after {
                display: none;
            }
        }

        .table td {
            display: block;
            word-wrap: break-word;
            max-width: 7em;
        }

            .table td:first-child {
                display: table-cell;
                text-align: center;
                border-right: 1px solid #D9E4E6;
            }

        @media (min-width: 480px) {
            .table td {
                border: 1px solid #D9E4E6;
            }
        }

        .table th, .table td {
            text-align: center;
            margin: .5em 1em;
        }

        @media (min-width: 480px) {
            .table th, .table td {
                display: table-cell;
                padding: 1em;
            }
        }

        #test_id {
            width: 60px !important;
            text-align: center;
            font-weight: bold;
        }

        .ErrorAlert {
            border: 1px solid red !important;
        }
       .textarea {
    border: 1px solid red !important;
    border-radius:5px !important;
}
       select {
    border-radius:5px !important;
}
       input[type="text"] {
    border-radius: 5px !important;
}

      

    </style>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.3/css/select2.min.css" rel="stylesheet" />
    <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.3/js/select2.min.js"></script>
    <link href="Styles/jquery.ptTimeSelect.css" rel="stylesheet" />
    <script type="text/javascript" src="Scripts/jquery.ptTimeSelect.js"></script>
    <script type="text/javascript" src="Scripts/jquery.tokeninput.js"></script>
    <script type="text/javascript">


        function Populate() {

            $('#TestModel').modal({
                backdrop: 'static'
            });
        }
        function PopulatePackageDetail(id) {

            PageMethods.GetPackageDetail(id, function (res) {
                var item = JSON.parse(res);
                var rows = '';
                var result;
                $.each(item, function (key, value) {
                    if (value.itemanme == null) {
                        var itemanme = value.GroupName;
                    }
                    else {
                        itemanme = value.itemanme;
                    }

                    var lenght = tblbodyPackage.rows.length + 1;

                    var desc = (value.Item_Type != 'Test') ? value.Item_Code + "-" + value.itemanme : " " + value.itemanme;

                    var rows = '<tr><td>' + lenght + ' </td><td> <input type="hidden" name="txtDes" id="txtDes' + lenght + '" style="width: 189px !important;" value="' + value.Item_Code + '"/>' + itemanme + '</td><td><input type="text" name="txtQTy" id="txtQty' + lenght + '" style="width:  57px !important;    height: 28px;" value="' + value.QTY + '" onkeyup="UpdateAmount(' + lenght + ') "/></td><td><input type="text" name="txPrice" id="txPrice' + lenght + '" value="' + value.Price + '" style="width:  75px !important;    height: 28px;" value="1" onkeyup="UpdateAmount(' + lenght + ')"/></td><td><input type="hidden" name="txAmount" id="txAmount' + lenght + '"/><span id="Amountspan' + lenght + '"></span></td><td><input type="hidden" name="hdnCategory_ID" value="' + value.Category_ID + '" /> <input type="hidden" name="ItemType" id="ItemType' + lenght + '"  value="' + value.Item_Type + '"/> <a href="javascript:void(0)" onclick="value_delete(this)">Delete</a></td></tr>';


                    $('#tblPackage').append(rows);

                    var qty = $('#txtQty' + lenght + '').val();
                    var price = $('#txPrice' + lenght + '').val();
                    var amount = qty * price;
                    $('#Amountspan' + lenght + '').text(amount);
                    $('#txAmount' + lenght + '').val(amount);


                    var tbody = document.getElementById('tblbodyPackage');

                    var rowlenth = tbody.rows.length;

                    var total = 0.00;
                    for (var i = 0; i <= rowlenth; i++) {
                        //var rid = tbody.rows[i].id;

                        var samt;

                        samt = $('#txAmount' + i + '').val();
                        if (samt != '') {
                            var amt = parseFloat(samt);
                            if (isNaN(amt) == false) {
                                total += amt;
                            }
                        }
                    }

                    if (total == 0 || isNaN(total)) {
                        $('#txttotalAMount').text("0");
                        // footerAmount.innerHTML = '0';
                    }
                    else {
                        $('#txttotalAMount').text(total.toFixed(2));
                        //footerAmount.innerHTML = CurrencyFormatted(total.toFixed(2));
                    }

                });
            });
            $('#btnSave').val("Update");
        }
        $(document).ready(function () {
            var Item_Code = $("#hdfItem_Code").val();

            var tokendata = httpGet("../../json.aspx?Table=INV_Items&Item_Code=" + Item_Code);

            loadtokenInputsDefault();

            FillLabTests();
            $('#btnSave').click(function () {
                var btnSave = $('#btnSave').val();
                var PAckID = $('#hdnPackage_ID').val();

                var table = $('#tblbodyPackage');
                var Pkg_list = [];

                var Package = $('#ctl00_MainContent_txtPackage_Name').val();
                var Dpt = $('#ctl00_MainContent_ddlPatient_Main_Category').val();

                var Remarks = $('#ctl00_MainContent_txtRemarks').val();
                var PackageType = $('#ctl00_MainContent_ddlPackageType').val();
                var duration = $('#ctl00_MainContent_txtDuration').val();
                var PerDay_Charges = $('#ctl00_MainContent_txtPerDayCharges').val() == '' ? 0 : $('#ctl00_MainContent_txtPerDayCharges').val();
                table.find('tr').each(function (key, value) {

                    Pkg_list.push({ 'Item': $(value).find('td input[name=txtDes]').val(), 'QTy': $(value).find('td input[name=txtQTy]').val(), 'Price': $(value).find('td input[name=txPrice]').val(), 'Amount': $(value).find('td input[name=txAmount]').val(), 'ItemType': $(value).find('td input[name=ItemType]').val(), 'Category_ID': $(value).find('td input[name=hdnCategory_ID]').val() });
                });
                var PAKg = { 'PKDetail': Pkg_list };
                PageMethods.SavePackage(btnSave, PAckID, Package, Dpt, Remarks, PackageType, duration, JSON.stringify(PAKg), PerDay_Charges, function (res) {
                    $('#btnSave').val("Update");
                    window.location = "Packages.aspx?ID=" + res;
                });
            });
            $('#add-new-testList').click(function () {
                $("#btnXray").removeClass("btn-danger").addClass("btn-info");
                $('#btnultrasound').removeClass('btn-danger').addClass('btn-info');
                $("#btnCTscan").removeClass("btn-danger").addClass("btn-info");

                var Result = 'Result';
                var test = $('#groupsCat').val();
                var date = '<%= DateTime.Now %>';
                var IsRotationShow = $('#divRotation').is(":visible");

                var Rotation_ID = IsRotationShow ? $('#ddlRotation option:selected').val() : "0";
                var Rotation_Name = IsRotationShow ? $('#ddlRotation option:selected').text() : " ";

                $.ajax({
                    type: "POST",
                    url: "Packages.aspx/GetTestMainDepartmentDetails",
                    data: JSON.stringify({ TestID: test }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (data) {
                        var MainDeptName = JSON.parse(data.d);
                        TestMainDepartmentName = MainDeptName[0].TestMainDepartmentName123;
                        var Rate = MainDeptName[0].rate;

                        var lenght = tblbodyPackage.rows.length + 1;
                        if (lenght >= 2) {

                            var tbody = document.getElementById('tblbodyPackage');

                            var rowlenth = tbody.rows.length;

                            var total = 0.00;
                            for (var i = 1; i <= rowlenth; i++) {
                                //var rid = tbody.rows[i].id;

                                var id;

                                id = $('#txtDes' + i + '').val();
                                if (id == test) {
                                    alert("Dublicate Item.. Please Select Another Item");
                                    return false;

                                }

                            }
                        }
                        if (Rate == null || Rate == "")
                            Rate = 0;
                        var row = '<tr><td>' + lenght + '</td><td><input type="hidden" name="txtDes" id="txtDes' + lenght + '" value="' + test + '" /> <input type="hidden" name="txtRotation" value="' + Rotation_ID + '">' + $('#groupsCat').find('option:selected').text() + ', ' + Rotation_Name + '</td><td><input type="text" name="txtQTy" id="txtQty' + lenght + '" style="width:  57px !important;    height: 28px;" value="1" onkeyup="UpdateAmount(' + lenght + ')"/></td><td><input type="text" name="txPrice" id="txPrice' + lenght + '" value="' + Rate + '" style="width:  75px !important;    height: 28px;" value="1" onkeyup="UpdateAmount(' + lenght + ')"/></td></td> <td> <input type="hidden" name="txAmount" id="txAmount' + lenght + '"/><span id="Amountspan' + lenght + '"></span></td><td> <input type="hidden" name="ItemType" id="ItemType' + lenght + '"  value="Test"/><a href="javascript:void(0)" onclick="value_delete(this)">Delete</a></td></tr>';

                        $('#tblPackage').append(row);
                        $('#TestModel').modal('hide');

                        var qty = $('#txtQty' + lenght + '').val();
                        var price = $('#txPrice' + lenght + '').val();
                        var amount = qty * price;
                        $('#Amountspan' + lenght + '').text(amount);
                        $('#txAmount' + lenght + '').val(amount);
                        var tbody = document.getElementById('tblbodyPackage');

                        var rowlenth = tbody.rows.length;

                        var total = 0.00;
                        for (var i = 0; i <= rowlenth; i++) {
                            //var rid = tbody.rows[i].id;
                            var samt;

                            samt = $('#txAmount' + i + '').val();
                            if (samt != '') {
                                var amt = parseFloat(samt);
                                if (isNaN(amt) == false) {
                                    total += amt;
                                }
                            }
                        }

                        if (total == 0 || isNaN(total)) {
                            $('#txttotalAMount').text("0");

                        }
                        else {
                            $('#txttotalAMount').text(total.toFixed(2));

                        }

                    },
                    failure: function (response) {
                        alert(response.d);
                    }
                });
            });


            $('#add-new-testDirect').click(function () {
                var test = $('#ddlLabTest').find('option:selected').text();
                PageMethods.GetLabTestDDLDetails(test, function (res) {
                    console.clear();
                    $.each(JSON.parse(res), function (key, value) {
                        var Result = 'Result';
                        var test = $('#ddlLabTest').val();
                        var date = '<%= DateTime.Now %>';
                        var TestMainDepartmentName;
                        var lenght = tblbodyPackage.rows.length + 1;
                        if (lenght >= 2) {

                            var tbody = document.getElementById('tblbodyPackage');

                            var rowlenth = tbody.rows.length;

                            var total = 0.00;
                            for (var i = 1; i <= rowlenth; i++) {
                                //var rid = tbody.rows[i].id;

                                var id;

                                id = $('#txtDes' + i + '').val();
                                if (id == value.TestID) {
                                    alert("Dublicate Item.. Please Select Another Item");
                                    return false;

                                }

                            }
                        }


                        if (value.Rate == null || value.Rate == "")
                            value.Rate = 0;

                        var row = '<tr><td>' + lenght + '</td>  <td><input type="hidden" name="txtDes" id="txtDes' + lenght + '" value="' + value.Test_ID + '" /> <input type="hidden" name="txtRotation" value="0"> "' + value.Test_Name + '"</td><td><input type="text" name="txtQTy" id="txtQty' + lenght + '" style="width:  57px !important;    height: 28px;" value="1" onkeyup="UpdateAmount(' + lenght + ')"/></td><td><input type="text" name="txPrice" id="txPrice' + lenght + '" value="' + value.Rate + '" style="width:  75px !important;    height: 28px;" value="1" onkeyup="UpdateAmount(' + lenght + ')"/></td></td> <td> <input type="hidden" name="txAmount" id="txAmount' + lenght + '"/><span id="Amountspan' + lenght + '"></span></td><td> <input type="hidden" name="hdnCategory_ID" value="' + value.Group_Category + '" /><input type="hidden" name="ItemType" id="ItemType' + lenght + '"  value="Test"/> <a href="javascript:void(0)" onclick="value_delete(this)">Delete</a></td></tr>';

                        $('#tblPackage').append(row);
                        $('#TestModel').modal('hide');


                        var qty = $('#txtQty' + lenght + '').val();
                        var price = $('#txPrice' + lenght + '').val();
                        var amount = qty * price;
                        $('#Amountspan' + lenght + '').text(amount);
                        $('#txAmount' + lenght + '').val(amount);


                        var tbody = document.getElementById('tblbodyPackage');

                        var rowlenth = tbody.rows.length;

                        var total = 0.00;
                        for (var i = 0; i <= rowlenth; i++) {


                            var samt;

                            samt = $('#txAmount' + i + '').val();




                            if (samt != '') {
                                var amt = parseFloat(samt);
                                if (isNaN(amt) == false) {
                                    total += amt;
                                }
                            }
                        }

                        if (total == 0 || isNaN(total)) {
                            $('#txttotalAMount').text("0");

                        }
                        else {
                            $('#txttotalAMount').text(total.toFixed(2));

                        }

                    });


                }, function (err) { });

            });

        });

        function FillLabTests() {

            var options = '';

            PageMethods.GetLabTests(function (Tests) {
                $.each(JSON.parse(Tests), function (key, value) {
                    options += '<option value="' + value.SerialNo + '" >' + value.TestName + '</option>';
                });
                $('#ddlLabTest').html(options);
                $('#ddlLabTest').select2();
                localStorage.TestForCategoryWiseSelections = options;
            });
        }
        function loadtokenInputsDefault() {
            $('#ctl00_MainContent_txtItem_Code').tokenInput("../../json.aspx?Table=INV_Items",
                {
                    tokenLimit: 1,
                    onAdd: function (item) {
                        $("#hdfItem_Code").val(item.id);
                    }
                });
        }
        function loadtokenInputs(data) {
            $("#ctl00_MainContent_txtItem_Code").tokenInput("../../json.aspx?Table=INV_Items",
                {
                    prePopulate: data,
                    tokenLimit: 1,
                    onAdd: function (item) {
                        $("#hdfItem_Code").val(item.id);

                    }


                });

        }
        function httpGet(theUrl) {
            var xmlHttp = null;

            xmlHttp = new XMLHttpRequest();
            xmlHttp.open("GET", theUrl, false);
            xmlHttp.send(null);
            return xmlHttp.responseText;
        }


        function LoadTokenInputForItems() {

            $('#txtDes').tokenInput('clear');





            var tokenData = httpGet("../../json.aspx?Table=Symtoms&Mode=Edit&q=" + SymtomID);

            var parsedData = JSON.parse(tokenData);

            $('#txtDes').tokenInput("add", { id: JSON.parse(tokenData)[0].id, name: JSON.parse(tokenData)[0].name });
        }
        //}
        function new_value() {


            var discount = $('#ctl00_MainContent_txtDiscount').val();
            var item = $('#ctl00_MainContent_txtItem_Code').val();
            PageMethods.AddItem(item, function (res) {

                var item = JSON.parse(res);
                var rows = '';
                var result;
                $.each(item, function (key, value) {

                    var lenght = tblbodyPackage.rows.length + 1;
                    if (lenght >= 2) {

                        var tbody = document.getElementById('tblbodyPackage');

                        var rowlenth = tbody.rows.length;

                        var total = 0.00;
                        for (var i = 1; i <= rowlenth; i++) {


                            var id;

                            id = $('#txtDes' + i + '').val();
                            if (id == value.Item_ID) {
                                alert("Dublicate Item.. Please Select Another Item");
                                return false;

                            }

                        }
                    }
                    var ItemType;
                    if (value.Services == true)
                        ItemType = "Service";
                    else
                        ItemType = "Item";
                    var rows = '<tr><td>' + lenght + ' </td><td> <input type="hidden" name="txtDes" id="txtDes' + lenght + '" style="width: 189px !important;" value="' + value.Item_ID + '"/>' + value.Description + '</td><td><input type="text" name="txtQTy" id="txtQty' + lenght + '" style="width:  57px !important;    height: 28px;" value="1" onkeyup="UpdateAmount(' + lenght + ')"/></td><td><input type="text" name="txPrice" id="txPrice' + lenght + '" value="' + value.Sale_Rate + '" style="width:  75px !important;    height: 28px;" value="1" onkeyup="UpdateAmount(' + lenght + ')"/></td><td><input type="hidden" name="hdnCategory_ID" value="' + value.Group_Category + '" /><input type="hidden" name="txAmount" id="txAmount' + lenght + '"/><span id="Amountspan' + lenght + '"></span></td><td> <input type="hidden" name="ItemType" id="ItemType' + lenght + '"  value="' + ItemType + '"/><a href="javascript:void(0)" onclick="value_delete(this)">Delete</a></td></tr>';

                    $('#tblPackage').append(rows);

                    var qty = $('#txtQty' + lenght + '').val();
                    var price = $('#txPrice' + lenght + '').val();
                    var amount = qty * price;
                    $('#Amountspan' + lenght + '').text(amount);
                    $('#txAmount' + lenght + '').val(amount);


                    var tbody = document.getElementById('tblbodyPackage');

                    var rowlenth = tbody.rows.length;

                    var total = 0.00;
                    for (var i = 0; i <= rowlenth; i++) {


                        var samt;

                        samt = $('#txAmount' + i + '').val();




                        if (samt != '') {
                            var amt = parseFloat(samt);
                            if (isNaN(amt) == false) {
                                total += amt;
                            }
                        }
                    }

                    if (total == 0 || isNaN(total)) {
                        $('#txttotalAMount').text("0");

                    }
                    else {
                        $('#txttotalAMount').text(total.toFixed(2));

                    }


                    // }
                });
            });
        }

        function value_delete(row) {
            $($(row).parents('tr')[0]).remove();
        }
        function UpdateAmount(lenght) {
            var qty = $('#txtQty' + lenght + '').val();
            var price = $('#txPrice' + lenght + '').val();
            var amount = qty * price;
            $('#Amountspan' + lenght + '').text(amount);
            $('#txAmount' + lenght + '').val(amount);

            var tbody = document.getElementById('tblbodyPackage');
            var rowlenth = tbody.rows.length;
            var total = 0.00;
            for (var i = 0; i <= rowlenth; i++) {

                var samt;

                samt = $('#txAmount' + i + '').val();




                if (samt != '') {
                    var amt = parseFloat(samt);
                    if (isNaN(amt) == false) {
                        total += amt;
                    }
                }
            }

            if (total == 0 || isNaN(total)) {
                $('#txttotalAMount').text("0");
                // footerAmount.innerHTML = '0';
            }
            else {
                $('#txttotalAMount').text(total.toFixed(2));
                //footerAmount.innerHTML = CurrencyFormatted(total.toFixed(2));
            }

        }

        function FillTestsByCategory(CategoryID) {

            var options = '';

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
                    $.each(JSON.parse(GetRotations), function (key, value) {
                        options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
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
                    options = '';
                    $.each(JSON.parse(GetRotations), function (key, value) {
                        options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                    });
                    $('#ddlRotation option').remove()
                    $('#ddlRotation').html(options);
                    $('#ddlRotation').select2();
                });
            }


            PageMethods.FillTestsByCategory(CategoryID, function (Tests) {
                options = '';
                $.each(JSON.parse(Tests), function (key, value) {
                    options += '<option value="' + value.Test_ID + '" >' + value.Test_Name + '</option>';
                });
                $('#groupsCat').html(options);
                $('#groupsCat').select2();
            });
        }



    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

     <form id="Items">
     <div class="row">
         <div class="col-lg-2 col-md-4 col-sm-6">
             <asp:Label ID="LbPackage_Name" runat="server" Text="Package Name"></asp:Label>
             <asp:HiddenField ID="hdfItem_Code" runat="server" ClientIDMode="Static" />
             <asp:TextBox ID="txtPackage_Name" runat="server"></asp:TextBox>
             <asp:HiddenField ID="hdnPackage_ID" runat="server" ClientIDMode="Static" />
         </div>
         <div class="col-lg-3 col-md-4 col-sm-6">
              <asp:Label ID="Label3" runat="server" Text="Package Type"></asp:Label>
             <asp:DropDownList ID="ddlPackageType" runat="server" AppendDataBoundItems="true"></asp:DropDownList>
         </div>
         <div class="col-lg-3 col-md-4 col-sm-6">
         <asp:Label ID="lbDepartment" runat="server" Text="Department"></asp:Label>
               <asp:DropDownList ID="ddlPatient_Main_Category" runat="server" AppendDataBoundItems="true"></asp:DropDownList>
         </div>
          <div class="col-lg-2 col-md-4 col-sm-6">
               <asp:Label ID="Label1" runat="server" Text="Duration"></asp:Label>
                <asp:TextBox ID="txtDuration" runat="server"></asp:TextBox>
         </div>
         <div class="col-lg-2 col-md-4 col-sm-6">
              <asp:Label ID="Label5" runat="server" Text="Per Day Charges"></asp:Label>
              <asp:TextBox ID="txtPerDayCharges" runat="server"></asp:TextBox>
         </div>
         </div>
          <div class="row">
              <div class="col-lg-3 col-md-4 col-sm-6">
                  <asp:Label ID="Label2" runat="server" Text="Items"></asp:Label>
                      <asp:TextBox ID="txtItem_Code" runat="server"></asp:TextBox>
                  </div>
                  <div class="col-lg-1 col-md-4 col-sm-6">
                  <input type="button" value="Add Test" id="add-new-testPopup" onclick="Populate()" style="/*display:none*/margin-top:19px !important" />
              </div>
              <div class="col-lg-3 col-md-4 col-sm-6">
                  <label>Select Department</label>
                  <select id="ddlLabTest">
                      <option value="">Select Department </option>
                  </select>
              </div>
               <div class="col-lg-1 col-md-4 col-sm-6">
                    <input type="button" value="Add Test" id="add-new-testDirect" style="margin-top:23px !important" />
              </div>
               <div class="col-lg-4 col-md-4 col-sm-6">
                   <asp:Label ID="Label4" runat="server" Text="Remarks"></asp:Label>
                   <asp:TextBox ID="txtRemarks" runat="server" TextMode="MultiLine" style="width:470px;height:38px !important;border-radius:5px !important"></asp:TextBox>
              </div>
              </div>
             </form>



    <div id="PatientDetail" style="width: 100%">

                <td colspan="6">
                    <div>

                        <table class="table" id="tblPackage" style="width: 833px;">
                            <thead>
                                <th style="width: 56px">Sr No.</th>
                                <th style="width: 200px">Description</th>
                                <th style="width: 63px;">Qty</th>
                                <th style="width: 57px">Charges</th>
                                <th style="width: 38px">Amount</th>                               
                                <th style="width: 56px">Action</th>
                            </thead>
                            <tbody id="tblbodyPackage"></tbody>
                        </table>
                    </div>
                </td>
        <table>
            <tr>
                <td colspan="3"></td>
                <td>
                    <div style="margin-left: 226px;"><b>Total Amount:</b> &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<span id="txttotalAMount"></span></div>
                </td>          
            </tr>
            <tr>
                <td></td>
               
                <td>
                    <input type="button" style="width: 93px" id="btnSave" value="Save" />
                    <%--&nbsp;--%>
                    <asp:Button Text="New" Width="93px" runat="server" ID="Button1" PostBackUrl="~/Inventory/Packages.aspx" CausesValidation="false" />

                   
                    <asp:Button Text="List View" Width="93px" runat="server" ID="btnBack" PostBackUrl="~/Inventory/PackagesView.aspx" CausesValidation="false" />
                </td>
                 
                <td></td>
                <td></td>
                <td></td>
                <td></td>
            </tr>
            <tr>
                <td colspan="6"></td>
            </tr>
            <tr>
                <td colspan="6">
                    <asp:Label ID="lblMessage" Text="" runat="server" />
                </td>
            </tr>

        </table>
    </div>

</asp:Content>
