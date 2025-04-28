<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="BankReconsilation.aspx.cs" Inherits="PMS.BankReconsilation" Theme="Default_Theme" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

    <script type="text/javascript" src="Scripts/jquery.tokeninput.js"></script>
    <script type="text/javascript">
        $(document).ready(function () {
            loadtokenInputs();
            $("#ctl00_MainContent_txtFrom_Date").val($.datepicker.formatDate('dd M yy', new Date()));
            $("#ctl00_MainContent_txtTo_Date").val($.datepicker.formatDate('dd M yy', new Date()));
            $("#ctl00_MainContent_txtRealization_Date").val($.datepicker.formatDate('dd M yy', new Date()));
            Sys.WebForms.PageRequestManager.getInstance().add_pageLoaded(function (evt, args) {
                $("#ctl00_MainContent_txtFrom_Date").datepicker({ dateFormat: 'dd M yy' });
                $("#ctl00_MainContent_txtTo_Date").datepicker({ dateFormat: 'dd M yy' });
                $("#ctl00_MainContent_txtRealization_Date").datepicker({ dateFormat: 'dd M yy' });
            });
        });

        function loadtokenInputs() {
            $("#ctl00_MainContent_txtAccount_Code_Name").tokenInput("json.aspx?Bank=1",
               {
                   tokenLimit: 1
               });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <fieldset>
        <table style="width: 70%;">
            <tr>
                <td>
                    <asp:Label Text="Account Code & Name *" runat="server" ID="lblAccount_Code_Name" />
                </td>
                <td>
                    <asp:TextBox ID="txtAccount_Code_Name" runat="server" Width="200px" SkinID="UserDefineWidth" />
                </td>
                <td>
                    <asp:Label Text="Amount" runat="server" ID="lblAmount" />
                </td>
                <td>
                    <asp:TextBox runat="server" ID="txtAmount" EnableTheming="false" />

                </td>
                <td></td>
            </tr>
            <tr>
                <td></td>
                <td>
                    <asp:RequiredFieldValidator ID="rfvAccount_Code" ErrorMessage="Account code is required" ControlToValidate="txtAccount_Code_Name" runat="server" Display="Static" SetFocusOnError="true" />

                </td>
                <td></td>
                <td>
                    <asp:RangeValidator ErrorMessage="Enter valid amount." SetFocusOnError="true"
                        Display="Static" Type="Currency" ID="test" MinimumValue="0" MaximumValue="9999999999" ControlToValidate="txtAmount" runat="server" />

                </td>
            </tr>
            <tr>
                <td style="padding-left: 20px; width: 152px;">
                    <asp:Label Text="From Date" runat="server" ID="Label1" />
                </td>
                <td>
                    <asp:TextBox runat="server" ID="txtFrom_Date" onFocus="blur();" EnableTheming="false" />
                </td>
                <td>
                    <asp:Label Text="To Date" runat="server" ID="Label2" />
                </td>
                <td>
                    <asp:TextBox runat="server" ID="txtTo_Date" onFocus="blur();" EnableTheming="false" />
                </td>
                <td>
                    <asp:Button Text="Submit" ID="btnSubmit" OnClick="btnSubmit_Click" runat="server" />
                </td>
            </tr>
        </table>
    </fieldset>
    <asp:UpdatePanel runat="server" ID="upList" UpdateMode="Conditional">
        <Triggers>
            <asp:AsyncPostBackTrigger EventName="Click" ControlID="btnSubmit" />
            <asp:AsyncPostBackTrigger EventName="Click" ControlID="btnSubmit" />
        </Triggers>
        <ContentTemplate>
            <asp:GridView ID="gvReconsilationList" runat="server" AutoGenerateColumns="False"
                Width="100%" GridLines="Both">
                <Columns>
                    <asp:TemplateField>
                        <ItemTemplate>
                            <asp:CheckBox ID="chkSelect" Text="" runat="server" />
                            <asp:Label ID="lblVoucher_Account_ID" runat="server" Text='<%# Bind("Voucher_Account_ID") %>' Visible="false"></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="Voucher_Date" HeaderText="Date" DataFormatString="{0: dd MMM yyyy}" />
                    <asp:BoundField DataField="Voucher_No" HeaderText="Voucher No." />
                    <asp:BoundField DataField="Narration" HeaderText="Narration" />
                    <asp:BoundField DataField="Serial_No" HeaderText="Reference No." />
                    <asp:BoundField DataField="DR" HeaderText="Debit" />
                    <asp:BoundField DataField="CR" HeaderText="Credit" />
                </Columns>
            </asp:GridView>
        </ContentTemplate>
    </asp:UpdatePanel>
    <br />
    <table style="width: 50%;">
        <tr>
            <td style="padding-left: 20px; width: 152px;">
                <asp:Label Text="Realization Date" runat="server" />
            </td>
            <td>
                <asp:TextBox runat="server" ID="txtRealization_Date" EnableTheming="false" onFoucs="blur();" />
                <asp:Button Text="Assign Date" ID="Assign_Date" OnClick="Assign_Date_Click" runat="server" />
            </td>
            <td>
            </td>
        </tr>
        <tr>
            <td colspan="3">
                <asp:Label ID="lblMessage" runat="server" />
            </td>
        </tr>
    </table>
</asp:Content>
