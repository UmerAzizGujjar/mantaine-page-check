<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ChangeAccount.aspx.cs" Inherits="PMS.ChangeAccount" Theme="Default_Theme" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script type="text/javascript" src="Scripts/jquery.tokeninput.js"></script>
    <script type="text/javascript">
        $(document).ready(function () {
          
            loadtokenInputs();
        });

        function loadtokenInputs() {
            $("#ctl00_MainContent_txtOldAccount_ID").tokenInput("json.aspx", {
                tokenLimit: 1
            });
            $("#ctl00_MainContent_txtNewAccount_ID").tokenInput("json.aspx", {
                tokenLimit: 1
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <script type="text/javascript">
        Sys.WebForms.PageRequestManager.getInstance().add_endRequest(loadtokenInputs);
    </script>
    <asp:UpdatePanel runat="server" UpdateMode="Conditional" ID="UpForm" ChildrenAsTriggers="true">
        <ContentTemplate>

            <table cellspacing="7">
                <tr>
                    <td>
                        <asp:Label ID="Label1" Text="Old Account" runat="server" /></td>
                    <td style="padding-left:12px;width:78% !important;">
                        <asp:TextBox runat="server" ID="txtOldAccount_ID" Width="350" />
                        <asp:RequiredFieldValidator ID="RequiredFieldValidator1" ErrorMessage="Select old account." Display="Dynamic" SetFocusOnError="true" ControlToValidate="txtOldAccount_ID" runat="server" />
                    </td>
                </tr>

                <tr>
                    <td>
                        <asp:Label Text="New Account" ID="lblNewAccount" runat="server" />
                    </td>
                    <td style="padding-left:12px">
                        <asp:TextBox runat="server" ID="txtNewAccount_ID" Width="350" />

                        <asp:RequiredFieldValidator ID="RequiredFieldValidator2" ErrorMessage="Select new account." SetFocusOnError="true" Display="Dynamic" ControlToValidate="txtNewAccount_ID" runat="server" />
                        <asp:CompareValidator ID="CompareValidator1" Type="String" ControlToCompare="txtOldAccount_ID" Operator="NotEqual" ErrorMessage="select other then old account." SetFocusOnError="true" Display="Dynamic" ControlToValidate="txtNewAccount_ID" runat="server" />
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <asp:Label ID="lblMessage" runat="server" />
                    </td>
                </tr>
                <tr>

                </tr>
            </table>
            <div class="row">
                <div class="col-lg-5" style="margin-left:91px;margin-top:10px">
                    <div class="row">
                        <div class="col-lg-2">
                            <asp:Button Text="Update" CssClass="btn btn-primry" runat="server" ID="btnUpdate" OnClick="btnUpdate_Click" />
                        </div>
                        <div class="col-lg-2">
                            <asp:Button Text="Cancel" CssClass="btn btn-primry" runat="server" ID="btnCancel" OnClick="btnCancel_Click" CausesValidation="false" />
                        </div>
                    </div>
                </div>
            </div>
        </ContentTemplate>
        <Triggers>
            <asp:AsyncPostBackTrigger ControlID="btnUpdate"  EventName="Click" />
            <asp:AsyncPostBackTrigger ControlID="btnCancel" EventName="Click" />

        </Triggers>
    </asp:UpdatePanel>
</asp:Content>
