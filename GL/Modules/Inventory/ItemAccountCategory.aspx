<%@ Page EnableSessionState="ReadOnly" Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ItemAccountCategory.aspx.cs" Inherits="PMS.ItemAccountCategory" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script type="text/javascript" src="../Scripts/jquery.tokeninput.js"></script>

    <script type="text/javascript">

        function Save() {

            var table = $('#tbl');
            var AccountsList = [];
            table.find('tbody tr').each(function (key, value) {
                var Dept = $('#ddlDepts' + parseInt(parseInt(key) + 1) + '').val();
                var Type = $('#ddlType' + parseInt(parseInt(key) + 1) + '').val();
                var Code = $('#txtAccountCode' + parseInt(parseInt(key) + 1) + '').val();
                AccountsList.push({ 'Dept': Dept, 'Type': Type, 'Code': Code });
            });

            var CatID = $('#ctl00_MainContent_txtItem_ID').val();
            var CatName = $('#ctl00_MainContent_txtItem_Name').val();
            if (CatID == '(New)' || CatID == '')
                CatID = 0;
            var data= { CatID: CatID,CatName:CatName, AccountsList: AccountsList }

            PageMethods.SaveData(JSON.stringify(data), function (response) { });

        }

        function GetDepartments() {
            PageMethods.GetDepartments(function (resp) {
                var res = JSON.parse(resp);
                console.clear();
               
            });
        }

        function GetAccountsByDepartments() {
            PageMethods.GetAccountsByDepartments(69841, function (resp) {
                var res = JSON.parse(resp);
              
               
            });
        }

        $(document).ready(function () {
            
            localStorage.RowId = 0;


            var txtItem_ID;
            txtItem_ID = $("#ctl00_MainContent_txtItem_ID").val();
            if (txtItem_ID != "(New)") {
                var tokendata;
                tokendata = httpGet("../json.aspx/?Table=GL_Accounts&AccountType=Stock_Account&Item_ID=" + txtItem_ID);
                LoadStock_AccountByItem("#ctl00_MainContent_txtStock_Account", JSON.parse(tokendata));

                var tokendata1 = httpGet("../json.aspx/?Table=GL_Accounts&AccountType=Sales_Account&Item_ID=" + txtItem_ID);
                LoadSales_AccountByItem("#ctl00_MainContent_txtSales_Account", JSON.parse(tokendata1));

                var tokendata2 = httpGet("../json.aspx/?Table=GL_Accounts&AccountType=Cost_Of_Sales_Account&Item_ID=" + txtItem_ID);
                LoadCost_Of_Sales_AccountByItem("#ctl00_MainContent_txtCost_Of_Sales_Account", JSON.parse(tokendata2));
            }
            else {
                LoadStock_Account();
                LoadSales_Account();
                LoadCost_Of_Sales_Account();
            }
        });
        function LoadStock_AccountByItem(elementId, data) {
            if (elementId == "#ctl00_MainContent_txtStock_Account") {
                $(elementId).tokenInput("../json.aspx",
                    {
                        prePopulate: data,
                        tokenLimit: 1
                    });
            }
        }
        function LoadSales_AccountByItem(elementId, data) {
            if (elementId == "#ctl00_MainContent_txtSales_Account") {
                $(elementId).tokenInput("../json.aspx",
                    {
                        prePopulate: data,
                        tokenLimit: 1
                    });
            }
        }
        function LoadCost_Of_Sales_AccountByItem(elementId, data) {
            if (elementId == "#ctl00_MainContent_txtCost_Of_Sales_Account") {
                $(elementId).tokenInput("../json.aspx",
                    {
                        prePopulate: data,
                        tokenLimit: 1
                    });
            }
        }
        function httpGet(theUrl) {
            var xmlHttp = null;
            xmlHttp = new XMLHttpRequest();
            xmlHttp.open("GET", theUrl, false);
            xmlHttp.send(null);
            return xmlHttp.responseText;
        }
        function LoadStock_Account() {
            $("#ctl00_MainContent_txtStock_Account").tokenInput("../json.aspx", {
                tokenLimit: 1
            });
        }
        function LoadSales_Account() {
            $("#ctl00_MainContent_txtSales_Account").tokenInput("../json.aspx", {
                tokenLimit: 1
            });
        }
        function LoadCost_Of_Sales_Account() {
            $("#ctl00_MainContent_txtCost_Of_Sales_Account").tokenInput("../json.aspx", {
                tokenLimit: 1
            });
        }
        function AddRow() {
           
            var options = '';
            PageMethods.GetDepartments(function (resp) {

                $.each(JSON.parse(resp), function (key, value) {
                    options += '<option value="' + value.Account_ID + '">' + value.Account_Name + '</option>';
                });
                var randomNo = Math.random();
                var row = '<tr><td> <select id="ddlDepts' + parseInt(parseInt(localStorage.RowId) + 1) + '"> ' + options + ' </select>  </td> <td> <select id="ddlType' + parseInt(parseInt(localStorage.RowId) + 1) + '" style="width: 143px !important;"> <option value="Public">Public</option> <option value="Private">Private</option> </select> </td> <td> <input type="text" id="txtAccountCode' + parseInt(parseInt(localStorage.RowId) + 1) + '" style="width: 150px !important;" /> </td> </tr>';
                $('#tbl tbody').append(row);

                localStorage.RowId=parseInt(parseInt(localStorage.RowId) + 1);

            });
        }

    </script>

    <style>
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
    </style>

</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">


    <asp:Panel runat="server" ID="pnlForm">
        <table style="padding: 20px; width: 570px; height: 200px;">
            <tr>
                <td style="width: 150px;">
                    <asp:Label Text="ID" runat="server" ID="lblID" />
                </td>
                <td>
                    <asp:TextBox runat="server" ID="txtItem_ID" ReadOnly="true" Text="(New)" />
                </td>
                <td></td>
                <td></td>
            </tr>
            <tr>
                <td>
                    <asp:Label Text="Category Name *" runat="server" ID="lblItem_Name" />
                </td>
                <td>
                    <asp:TextBox runat="server" ID="txtItem_Name" Width="200" MaxLength="150" />
                </td>
                <td>
                    <asp:RequiredFieldValidator ErrorMessage="Category name is required." ID="rfvItemName"
                        ControlToValidate="txtItem_Name" runat="server" SetFocusOnError="true" Display="Dynamic" />
                </td>
                <td></td>
            </tr>

            <tr>
                <td></td>
                <td>
                    <br />
                    <asp:Button Text="Back" Width="95px" runat="server" ID="btnBack" CausesValidation="false" OnClientClick="javascript:history.back(); return false;" />
                    &nbsp;&nbsp;<asp:Button Text="Save" Width="95px" ID="btnSave" runat="server" OnClick="btnSave_Click" OnClientClick="Save()" />

                            &nbsp;&nbsp;
                        <asp:Button ID="btnNew" Width="95px" runat="server" Text="New" CausesValidation="false" OnClick="btnNew_Click" />
                </td>
            </tr>
            <tr>
                <td></td>
                <td>
                    <asp:Label ID="lblMessage" runat="server" />
                </td>
                <td></td>
            </tr>
            <tr>
                <td colspan="4">
                    <input type="button" name="btnAdd" id="btnAdd" onclick="AddRow();" value="Add" style="margin-left: 497px !important;" />
                    <table class="table" style="width: 608px;" id="tbl">
                        <thead>
                            <tr>
                                <th>Department Name </th>
                                <th>Public / Private </th>
                                <th>Account Code </th>
                            </tr>
                        </thead>
                        <tbody>
                        </tbody>
                    </table>
                </td>
            </tr>
        </table>
    </asp:Panel>
</asp:Content>
