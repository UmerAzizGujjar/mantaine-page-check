<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ServiceDefinition.aspx.cs" Inherits="PMS.ServiceDefinition" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script type="text/javascript" src="../Scripts/jquery.tokeninput.js"></script>

    <script type="text/javascript">
        $(document).ready(function () {
            setTimeout(function () { bindControls(); }



                , 3000)
            // bindControls();
        });

        function bindControls() {
            var hdFile_ID = $("#hdfAccount_ID").val();
            if (hdFile_ID != "(New)") {
                //var accountId = document.getElementById('<%= txtAccount_ID.ClientID%>').value;
                var accountId = $("#hdfAccount_ID").val();
                var tokendata = httpGet("../json.aspx/?Table=Account&Account_ID=" + accountId);
                loadtokenInputs(JSON.parse(tokendata));
            }
            else {
                loadtokenInputsDefault();
            }
        }

        function httpGet(theUrl) {
            var xmlHttp = null;
            xmlHttp = new XMLHttpRequest();
            xmlHttp.open("GET", theUrl, false);
            xmlHttp.send(null);
            return xmlHttp.responseText;
        }

        function loadtokenInputsDefault() {
            $('#ctl00_MainContent_txtAccount_ID').tokenInput("../json.aspx",
                {
                    tokenLimit: 1,
                });
        }

        function loadtokenInputs(data) {
            $("#ctl00_MainContent_txtAccount_ID").tokenInput("../json.aspx",
                {
                    prePopulate: data,
                    tokenLimit: 1,
                    onAdd: function (item) {
                        $("#hdfAccount_ID").val(item.id);
                    }
                });
        }

    </script>
    <style type="text/css">
    input[type="text"] {
        font-size: 13px;
        border-radius: 5px !important;
    }

    select {
        border-radius:5px !important;
        height:33px !important;
    }
</style>



</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <form>
        <div class="row">
            <div class="col-lg-2 col-md-4 col-sm-6">
                <asp:Label ID="lblService_Definition_ID" runat="server" Text="Service ID"></asp:Label>
                <asp:TextBox runat="server" ID="txtService_Definition_ID" ReadOnly="true" Text="(New)" />
            </div>
            <div class="col-lg-1 col-md-4 col-sm-6">
                </div>            
            <div class="col-lg-2 col-md-4 col-sm-6">
                <asp:Label ID="lblService_Type" runat="server" Text="Service Type *"></asp:Label>
                <asp:DropDownList ID="ddlService_Type" runat="server" AppendDataBoundItems="true"></asp:DropDownList>
                <asp:RequiredFieldValidator ID="rfvService_Type" ControlToValidate="ddlService_Type" InitialValue="0" runat="server" ErrorMessage="Select Service Type" Text="*"></asp:RequiredFieldValidator>
            </div>
            </div>
             <div class="row">
            <div class="col-lg-2 col-md-4 col-sm-6">
                <asp:Label ID="lblService_Name" runat="server" Text="Service Name *"></asp:Label>
                <asp:TextBox ID="txtService_Name" runat="server" />
                <asp:RequiredFieldValidator ID="rfvService_Name" ControlToValidate="txtService_Name" runat="server" ErrorMessage="Enter Service Name" Text="*"></asp:RequiredFieldValidator>
            </div>
                 <div class="col-lg-1 col-md-4 col-sm-6">
                     </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <asp:Label ID="lblService_Charges" runat="server" Text="Service Charges *"></asp:Label>
                <asp:TextBox ID="txtService_Charges" runat="server" />
                <asp:RequiredFieldValidator ID="rfvService_Charges" ControlToValidate="txtService_Charges" runat="server" ErrorMessage="Enter Service Charges" Text="*"></asp:RequiredFieldValidator>
                <asp:RangeValidator ID="rngService_Charges" Type="Double" runat="server" MinimumValue="0" MaximumValue="99999999" ControlToValidate="txtService_Charges" ErrorMessage="Only Enter Integer Values" Text="*"></asp:RangeValidator>
            </div>
             </div>
             <div class="row">             
            <div class="col-lg-2 col-md-4 col-sm-6">
                <asp:Label ID="lblAccount_ID" runat="server" Text="GL Account *"></asp:Label>
                <asp:TextBox ID="txtAccount_ID" runat="server" />
                <asp:HiddenField ID="hdfAccount_ID" Value="(New)" runat="server" ClientIDMode="Static" />
                <asp:RequiredFieldValidator ID="rfvAccount_ID" ControlToValidate="txtAccount_ID" runat="server" ErrorMessage="Select Account" Text="*"></asp:RequiredFieldValidator>
            </div>
            </div>
    </form>

    <table style="padding: 20px; width: 835px;">
        <tr>
            <td></td>
            <td>
                <br />
                <asp:Button Text="List View" Width="95px" runat="server" ID="btnBack" CausesValidation="false" PostBackUrl="~/ServiceDefinitionView.aspx" />
                &nbsp;
                <asp:Button Text="Save" Width="95px" runat="server" ID="btnSave" OnClick="btnSave_Click" />
            </td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
        </tr>

        <tr>
            <td colspan="6">
                <asp:Label ID="lblMessage" Text="" runat="server" />
            </td>
        </tr>

        <tr>
            <td colspan="6">
                <asp:ValidationSummary ID="ValidationSummary1" runat="server" ForeColor="Red" HeaderText="Page Errors"
                    ShowSummary="true" DisplayMode="List" />
            </td>
        </tr>

    </table>
</asp:Content>
