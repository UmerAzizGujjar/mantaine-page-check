<%@ Page EnableSessionState="ReadOnly" Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="SysParams.aspx.cs" Inherits="PMS.SysParams" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <script type="text/javascript">        

        localStorage.IsError_Found = false;

        function ValidatingControls() {

            localStorage.IsError_Found = false;

            Validate('#ctl00_MainContent_txtGLCashAccount');
            Validate('#ctl00_MainContent_txtLabAndRadiologyCharges_PrivateAccount');
            Validate('#ctl00_MainContent_txtLabAndRadiologyCharges_GeneralAccount');
            Validate('#ctl00_MainContent_txtRadialogyShare');
            Validate('#ctl00_MainContent_txtPhysioShare');
            Validate('#ctl00_MainContent_txtDentalShare');
            Validate('#ctl00_MainContent_txtDermaShare');

            var table = "#tbl_Liabilities";

            for (var i = 0; i <= localStorage.tbl_Liabilities_Length; i++) {

                var Acc = table + '_txtAccountCode_' + i;
                Validate(Acc);
            }

            table = "#tbl_Incomes";

            for (var i = 0; i <= localStorage.tbl_Incomes; i++) {

                var Acc = table + '_txtAccountCode_' + i;
                Validate(Acc);
            }
            return localStorage.IsError_Found;
        }

        function Validate(txtID) {

            var AccountCode = $(txtID).val();

            PageMethods.ValidateAccount(AccountCode, function (resp) {

                if (resp === true) {

                    if (localStorage.IsError_Found === false) {
                        $('#lblmsg').show();
                        $('#lblmsg').text('Accounts are Verified.');
                        $('#lblmsg').css('color', 'green');
                    }
                    $(txtID).css('background-color', 'rgb(168, 208, 168)');
                    $(txtID).css('color', 'white !important');
                }
                else if (resp === false) {

                    $(txtID).css('background-color', 'red');
                    $(txtID).focus();
                    $('#lblmsg').show();
                    $('#lblmsg').text('Accounts Not Verified.');
                    $('#lblmsg').css('color', 'red');
                    localStorage.IsError_Found = true;
                }
            }, function (err) { alert(err.get_message() + '  ' + txtID); });

        }

        function deletesys(AnchorTag) {

            var row = $(AnchorTag).parents('tr')[0];
            row.remove();
        }

        function New() {

            window.location = "SysParams.aspx";
        }

        function AddLiabilityRow() {

            var Libilities = '';
            var PatientTypes = '';
            var Departments = '';

            // Getting Liabilities...

            $.ajax({
                type: "POST",
                url: "SysParams.aspx/GetLiabilities",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {

                    $.each(msg.d, function (key, value) {
                        Libilities += '<option value="' + value.Item_ID + '">' + value.Description + '</option>';
                    });

                    // Getting Deparmtments...                    

                    $.ajax({
                        type: "POST",
                        url: "SysParams.aspx/GetDepartments",
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (data) {

                            $.each(data.d, function (key, value) {
                                Departments += '<option value="' + value.DataValueName + '">' + value.DataValueDescription + '</option>';
                            });

                            //Getting Patient Types...   


                            $.ajax({
                                type: "POST",
                                url: "SysParams.aspx/GetPatientTypes",
                                contentType: "application/json; charset=utf-8",
                                dataType: "json",
                                success: function (data) {

                                    PatientTypes = '';

                                    $.each(JSON.parse(data.d), function (key, value) {
                                        PatientTypes += '<option value="' + value.DataValue_Name + '">' + value.DataValue_Description + '</option>';
                                    });

                                    var table = "tbl_Liabilities";
                                    var tblLength = $('#' + table + ' tbody tr').length;

                                    tblLength = parseInt(tblLength);

                                    var row = '<tr><td><select id=' + table + '_ddlDept_' + tblLength + ' name="ddlDept" style="width: 120px !important;"> ' + Departments + ' </select></td><td><select id=' + table + '_ddlLiability_' + tblLength + ' name="ddlLiability" style="width: 120px !important;"> ' + Libilities + ' </select></td><td> <select id=' + table + '_ddlType_' + tblLength + ' name="ddlType" style="width: 120px !important;"> ' + PatientTypes + ' </select> </td> <td> <input type="text" id=' + table + '_txtAccountCode_' + tblLength + ' name="txtAccountCode" style="width: 120px !important;" /> </td><td><a href="javascript:void(0)" onclick="deletesys(this)"> Delete </a></td> </tr>';

                                    $('#tbl_Liabilities tbody').append(row);
                                    localStorage.tbl_Liabilities_Length = tblLength;
                                },
                                Error: function (x, e) {

                                }
                            });
                        },
                        Error: function (x, e) {

                        }
                    });
                },
                Error: function (x, e) {
                    alert(e);
                }
            });
        }

        function SaveLiabilities() {

            var AccountsList = [];

            var table = "#tbl_Liabilities";

            for (var i = 0; i <= localStorage.tbl_Liabilities_Length; i++) {

                var Dept = $(table + '_ddlDept_' + i).val();
                var Liability = $(table + '_ddlLiability_' + i).val();
                var Type = $(table + '_ddlType_' + i).val();
                var Code = $(table + '_txtAccountCode_' + i).val();
                if (Dept != null)
                    AccountsList.push({ Department: Dept, Name: Liability, Type: Type, Code: Code });
            }

            var data = { AccountsList: AccountsList }

            PageMethods.SaveLiabilities(JSON.stringify(data), function (response) {

            });
        }

        function LoadLiability_Accounts() {

            var Libilities = '';
            var PatientTypes = '';
            var Departments = '';

            // Getting Liabilities...

            $.ajax({
                type: "POST",
                url: "SysParams.aspx/GetLiabilities",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {

                    $.each(msg.d, function (key, value) {
                        Libilities += '<option value="' + value.Item_ID + '">' + value.Description + '</option>';
                    });

                    // Getting Deparmtments...                    

                    $.ajax({
                        type: "POST",
                        url: "SysParams.aspx/GetDepartments",
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (data) {

                            $.each(data.d, function (key, value) {
                                Departments += '<option value="' + value.DataValueName + '">' + value.DataValueDescription + '</option>';
                            });

                            //Getting Patient Types...   


                            $.ajax({
                                type: "POST",
                                url: "SysParams.aspx/GetPatientTypes",
                                contentType: "application/json; charset=utf-8",
                                dataType: "json",
                                success: function (data) {

                                    PatientTypes = '';

                                    $.each(JSON.parse(data.d), function (key, value) {
                                        PatientTypes += '<option value="' + value.DataValue_Name + '">' + value.DataValue_Description + '</option>';
                                    });


                                    $.ajax({
                                        type: "POST",
                                        url: "SysParams.aspx/GetAccounts",
                                        contentType: "application/json; charset=utf-8",
                                        dataType: "json",
                                        data: JSON.stringify({ Type: "Is Liability Account" }),
                                        success: function (response) {

                                            $('#tbl_Liabilities tbody tr').remove();

                                            $.each((response.d), function (key, value) {

                                                var table = "tbl_Liabilities";

                                                var tblLength = $('#' + table + ' tbody tr').length;

                                                var row = '<tr><td><select id=' + table + '_ddlDept_' + tblLength + ' name="ddlDept" style="width: 120px !important;"> ' + Departments + ' </select></td><td><select id=' + table + '_ddlLiability_' + tblLength + ' name="ddlLiability" style="width: 120px !important;"> ' + Libilities + ' </select></td><td> <select id=' + table + '_ddlType_' + tblLength + ' name="ddlType" style="width: 120px !important;"> ' + PatientTypes + ' </select> </td> <td> <input type="text" id=' + table + '_txtAccountCode_' + tblLength + ' name="txtAccountCode" style="width: 120px !important;" /> </td><td><a href="javascript:void(0)" onclick="deletesys(this)"> Delete </a></td> </tr>';

                                                $('#tbl_Liabilities tbody').append(row);

                                                $('#' + table + '_ddlDept_' + key).val(value.Segment1);
                                                $('#' + table + '_ddlLiability_' + key).val(value.Name);
                                                $('#' + table + '_ddlType_' + key).val(value.Segment2);
                                                $('#' + table + '_txtAccountCode_' + key).val(value.Code);

                                                localStorage.tbl_Liabilities_Length = tblLength;
                                            });
                                        },
                                        Error: function (x, e) {

                                        }
                                    });

                                },
                                Error: function (x, e) {

                                }
                            });
                        },
                        Error: function (x, e) {

                        }
                    });
                },
                Error: function (x, e) {
                    alert(e);
                }
            });
        }

        function AddIncomeRow() {

            var PatientTypes = '';
            var Departments = '';

            // Getting Deparmtments...                    

            $.ajax({
                type: "POST",
                url: "SysParams.aspx/GetDepartments",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {

                    $.each(data.d, function (key, value) {
                        Departments += '<option value="' + value.DataValueName + '">' + value.DataValueDescription + '</option>';
                    });

                    //Getting Patient Types...   

                    $.ajax({
                        type: "POST",
                        url: "SysParams.aspx/GetPatientTypes",
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (data) {

                            PatientTypes = '';

                            $.each(JSON.parse(data.d), function (key, value) {
                                PatientTypes += '<option value="' + value.DataValue_Name + '">' + value.DataValue_Description + '</option>';
                            });
                            var table = "tbl_Incomes";
                            var tblLength = $('#' + table + ' tbody tr').length;

                            var row = '<tr><td><select id=' + table + '_ddlDept_' + tblLength + ' name="ddlDept" style="width: 120px !important;"> ' + Departments + ' </select></td><td> <select id=' + table + '_ddlType_' + tblLength + ' name="ddlType" style="width: 120px !important;"> ' + PatientTypes + ' </select> </td> <td> <input type="text" id=' + table + '_txtAccountCode_' + tblLength + ' name="txtAccountCode" style="width: 120px !important;" /> </td><td><a href="javascript:void(0)" onclick="deletesys(this)"> Delete </a></td> </tr>';

                            $('#tbl_Incomes tbody').append(row);
                            localStorage.tbl_Incomes = tblLength;
                        },
                        Error: function (x, e) {

                        }
                    });
                },
                Error: function (x, e) {

                }
            });
        }

        function SaveIncomes() {
            var AccountsList = [];

            var table = "#tbl_Incomes";

            for (var i = 0; i <= localStorage.tbl_Incomes; i++) {

                var Dept = $(table + '_ddlDept_' + i).val();
                var Type = $(table + '_ddlType_' + i).val();
                var Code = $(table + '_txtAccountCode_' + i).val();
                if (Dept != null)
                    AccountsList.push({ Department: Dept, Type: Type, Code: Code });
            }

            var data = { AccountsList: AccountsList }

            PageMethods.SaveIncomes(JSON.stringify(data), function (response) {

            });
        }

        function LoadIncome_Accounts() {

            var PatientTypes = '';
            var Departments = '';

            // Getting Deparmtments...                    

            $.ajax({
                type: "POST",
                url: "SysParams.aspx/GetDepartments",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {

                    $.each(data.d, function (key, value) {
                        Departments += '<option value="' + value.DataValueName + '">' + value.DataValueDescription + '</option>';
                    });

                    //Getting Patient Types...   


                    $.ajax({
                        type: "POST",
                        url: "SysParams.aspx/GetPatientTypes",
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (data) {

                            PatientTypes = '';

                            $.each(JSON.parse(data.d), function (key, value) {
                                PatientTypes += '<option value="' + value.DataValue_Name + '">' + value.DataValue_Description + '</option>';
                            });


                            $.ajax({
                                type: "POST",
                                url: "SysParams.aspx/GetAccounts",
                                contentType: "application/json; charset=utf-8",
                                dataType: "json",
                                data: JSON.stringify({ Type: "Is Income Account" }),
                                success: function (response) {

                                    $('#tbl_Incomes tbody tr').remove();

                                    $.each((response.d), function (key, value) {

                                        var table = "tbl_Incomes";

                                        var tblLength = $('#' + table + ' tbody tr').length;

                                        var row = '<tr><td><select id=' + table + '_ddlDept_' + tblLength + ' name="ddlDept" style="width: 120px !important;"> ' + Departments + ' </select></td><td> <select id=' + table + '_ddlType_' + tblLength + ' name="ddlType" style="width: 120px !important;"> ' + PatientTypes + ' </select> </td> <td> <input type="text" id=' + table + '_txtAccountCode_' + tblLength + ' name="txtAccountCode" style="width: 120px !important;" /> </td><td><a href="javascript:void(0)" onclick="deletesys(this)"> Delete </a></td> </tr>';

                                        $('#tbl_Incomes tbody').append(row);
                                        $('#' + table + '_ddlDept_' + key).val(value.Segment1);
                                        $('#' + table + '_ddlType_' + key).val(value.Segment2);
                                        $('#' + table + '_txtAccountCode_' + key).val(value.Code);

                                        localStorage.tbl_Incomes = tblLength;

                                    });
                                },
                                Error: function (x, e) {

                                }
                            });

                        },
                        Error: function (x, e) {

                        }
                    });
                },
                Error: function (x, e) {

                }
            });
        }

        function SaveRecord(Error) {
            if (Error)
                alert('Error');
            else
                alert('Success');

            return false;
        }
        function Save() {
            //ValidatingControls();
            //setTimeout(function () {
            //    SaveRecord(localStorage.IsError_Found)
            //    , 20000
            //});                                    
            SaveLiabilities();
            SaveIncomes();
        }

        $(document).ready(function () {
            LoadLiability_Accounts();
            LoadIncome_Accounts();
        });

        // set Index of the Current Selected Tab using the select event handler of jQuery UI Tabs

        var selected_tabs = 1;
        $(function () {
            var tabs = $("#tabs").tabs({
                select: function (e, i) {
                    selected_tabs = i.index;
                }
            });
        });

        function tokenInputs(textboxID, tblName, OnAddFun) {
            $('#' + textboxID).tokenInput("json.aspx",
                {
                    tokenLimit: 1,
                    onAdd:
                        function (item) {
                            try {
                                if (tblName == 'GL_Accounts') {

                                    $("#" + textboxID).val(item.id);
                                }
                            }
                            catch (err) {
                                alert(err.message);
                            }
                        }
                });
        }

    </script>

    <asp:HiddenField ID="selected_tabs" runat="server" />

    <div id="tabs">
        <ul>
            <li><a href="#Tab-1">GL Accounts</a></li>
            <li><a href="#Tab-2">Income Accounts</a></li>
            <li><a href="#Tab-3">Libilitiy Accounts</a></li>
            <li><a href="#Tab-4">Fees</a></li>
            <li><a href="#Tab-5" style="display:none;">Digital Invoicing</a></li>
        </ul>
        <div id="Tab-1">
            <h2>GL Accounts</h2>
            <table style="width: 712px;">
                    <tr>
                        <td>GL Cash Account:</td>
                        <td>
                            <asp:TextBox ID="txtGLCashAccount" runat="server"></asp:TextBox>
                        </td>
                        <td>Receivable Account:</td>
                        <td>
                            <asp:TextBox ID="txtReceivableAccount" runat="server"></asp:TextBox>
                        </td>
                    </tr>
                <tr>
                        <td>Miscellenous Income Account:</td>
                        <td>
                            <asp:TextBox ID="txtMiscellenousIncomeAccount" runat="server"></asp:TextBox>
                        </td>
                        <td>Miscellenous Loss Account:</td>
                        <td>
                            <asp:TextBox ID="txtMiscellenousLossAccount" runat="server"></asp:TextBox>
                        </td>
                    </tr>
                </table>
        </div>
        <div id="Tab-2">
            <div id="Accounts">
                <div style="margin-top: 10px;">
                    <h2>Income Accounts</h2>
                    <table style="width: 908px;">
                        <tr>
                            <td>
                                Lab & Radiology Charges General Account:
                            </td>
                            <td> <asp:TextBox ID="txtLabAndRadiologyCharges_GeneralAccount" runat="server"></asp:TextBox> </td>
                            <td>
                                Lab & Radiology Charges Private Account:
                            </td>
                            <td> <asp:TextBox ID="txtLabAndRadiologyCharges_PrivateAccount" runat="server"></asp:TextBox> </td>

                            <td>
                                Patient Card Amount:
                            </td>
                            <td> <asp:TextBox ID="txtPatientCardAmount" runat="server"></asp:TextBox> </td>
                        </tr>
                    </table>
                    <input type="button" name="btnAdd" id="btnAdd" onclick="AddIncomeRow();" value="Add" style="margin-left: 782px !important;" />
                    <input type="hidden" name="txtID" id="txtID" />
                    <div style="width: 916px; overflow: scroll; height: 400px;">
                        <table class="table" style="width: 894px; overflow: scroll;" id="tbl_Incomes">
                            <thead>
                                <tr>
                                    <th style="width: 160px;">Department</th>
                                    <th style="width: 147px;">General / Private </th>
                                    <th style="width: 158px;">GL Code </th>57
                                    <th style="width: 120px;">Action </th>
                                </tr>
                            </thead>
                            <tbody>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
        <div id="Tab-3">

           <div id="Services">
               
                <table style="width: 901px;">
                    
                    <tr>
                        <td>
                            <h2>Liability Accounts</h2>
                        </td>
                    </tr>
                    
                    <tr>
                        <td>Radialogy Share:</td>
                        <td>
                            <asp:TextBox ID="txtRadialogyShare" runat="server"></asp:TextBox>
                        </td>
                        <td>Physio Share:</td>
                        <td>
                            <asp:TextBox ID="txtPhysioShare" runat="server"></asp:TextBox>
                        </td>
                        <td>Dental Share:</td>
                        <td>
                            <asp:TextBox ID="txtDentalShare" runat="server"></asp:TextBox>
                        </td>
                    </tr>

                    <tr>
                        <td>Radialogy Share %:</td>
                        <td>
                            <asp:TextBox ID="txtRadialogySharePercentage" runat="server"></asp:TextBox>
                        </td>
                        <td>Physio Share %:</td>
                        <td>
                            <asp:TextBox ID="txtPhysioSharePercentage" runat="server"></asp:TextBox>
                        </td>
                        <td>Dental Share %:</td>
                        <td>
                            <asp:TextBox ID="txtDentalSharePercentage" runat="server"></asp:TextBox>
                        </td>
                    </tr>
                     <tr>
                        <td>Derma Share:</td>
                        <td>
                            <asp:TextBox ID="txtDermaShare" runat="server"></asp:TextBox>
                        </td>
                        <td>Derma Share %:</td>
                        <td>
                            <asp:TextBox ID="txtDermaSharePercentage" runat="server"></asp:TextBox>
                        </td></tr>
                </table>                

                <div style="margin-top: 10px;">
                    <input type="button" name="btnAdd" id="btnAddLiabilityRow" onclick="AddLiabilityRow();" value="Add" style="margin-left: 782px !important;" />
                    <input type="hidden" name="txtID" id="Hidden1" />
                    <div style="width: 916px; overflow: scroll; height: 273px;">
                        <table class="table" style="width: 894px; overflow: scroll;" id="tbl_Liabilities">
                            <thead>
                                <tr>
                                    <th style="width: 160px;">Department</th>
                                    <th style="width: 160px;">Liability Name</th>
                                    <th style="width: 147px;">General / Private </th>
                                    <th style="width: 158px;">GL Code </th>
                                    <th style="width: 120px;">Action </th>
                                </tr>
                            </thead>
                            <tbody>
                            </tbody>
                        </table>
                    </div>
                </div>


                
            </div>
        </div>
        <div id="Tab-4">
             <td>Out Patient Fee:</td>
                        <td>
                            <asp:TextBox ID="txtopdfee" runat="server"></asp:TextBox>
                        </td>
             <td>In Patient Fee:</td>
                        <td>
                            <asp:TextBox ID="txt_inpatient_fee" runat="server"></asp:TextBox>
                        </td>
             <td>Emergency Patient Fee:</td>
                        <td>
                            <asp:TextBox ID="txt_emergecny_fee" runat="server"></asp:TextBox>
                        </td>
                
                
        </div>
        <div id="Tab-5">
            <h2>FBR Digital Invoicing (DI) Credentials</h2>
            <table style="width: 1000px;">
                <tr>
                    <td>Post URL (Sandbox/Production):</td>
                    <td colspan="3"><asp:TextBox ID="txtDI_PostUrl" runat="server" Width="600px"></asp:TextBox></td>
                </tr>
                <tr>
                    <td>Validate URL:</td>
                    <td colspan="3"><asp:TextBox ID="txtDI_ValidateUrl" runat="server" Width="600px"></asp:TextBox></td>
                </tr>
                <tr>
                    <td>Security Token:</td>
                    <td colspan="3"><asp:TextBox ID="txtDI_Token" runat="server" Width="600px"></asp:TextBox></td>
                </tr>
                <tr>
                    <td>Seller NTN / CNIC:</td>
                    <td><asp:TextBox ID="txtDI_SellerNTN" runat="server" Width="250px"></asp:TextBox></td>
                    <td>Seller Business Name:</td>
                    <td><asp:TextBox ID="txtDI_SellerName" runat="server" Width="250px"></asp:TextBox></td>
                </tr>
                <tr>
                    <td>Seller Province:</td>
                    <td><asp:TextBox ID="txtDI_SellerProvince" runat="server" Width="250px"></asp:TextBox></td>
                    <td>Seller Address:</td>
                    <td><asp:TextBox ID="txtDI_SellerAddress" runat="server" Width="250px"></asp:TextBox></td>
                </tr>
                <tr>
                    <td>Buyer Registration Type:</td>
                    <td><asp:TextBox ID="txtDI_RegistrationType" runat="server" Width="250px"></asp:TextBox></td>
                    <td>Scenario Id (Sandbox):</td>
                    <td><asp:TextBox ID="txtDI_ScenarioId" runat="server" Width="250px"></asp:TextBox></td>
                </tr>
                <tr>
                    <td>Invoice Type:</td>
                    <td><asp:TextBox ID="txtDI_InvoiceType" runat="server" Width="250px"></asp:TextBox></td>
                    <td>Rate:</td>
                    <td><asp:TextBox ID="txtDI_Rate" runat="server" Width="250px"></asp:TextBox></td>
                </tr>
                <tr>
                    <td>Sale Type:</td>
                    <td colspan="3"><asp:TextBox ID="txtDI_SaleType" runat="server" Width="250px"></asp:TextBox></td>
                </tr>
            </table>
        </div>
    </div>
    <div style="padding-left: 0px; padding-top: 20px" class="row">
        <div class="col-lg-8 col-md-8 col-sm-8">
            <div class="col-lg-2 col-md-2 col-sm-3">
                 <asp:Button ID="btnSave"  class="btn btn-primry" runat="server" Text="Save" OnClick="btnSave_Click" OnClientClick="return Save()" />
            </div>
            <div class="col-lg-2 col-md-2 col-sm-3">
                       <input type="button" class="btn btn-yellow" value="New" id="Button1" onclick="New()" />
            </div>
            <div class="col-lg-2 col-md-2 col-sm-3">
                     <input type="button" style="display:none;" value="Test" onclick="Save()" />
            </div>
            <div >
                  <br />
        <label id="lblmsg"></label>
            </div>
        </div>
      
    </div>
     
 
   
      
</asp:Content>
