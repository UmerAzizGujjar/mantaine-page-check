<%@ Page Title="Chart of Accounts" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="True"
    CodeBehind="ChartofAccounts.aspx.cs" Inherits="Salon.GL.ChartofAccounts" Theme="Default_Theme" %>

<%@ Register Assembly="Telerik.Web.UI" Namespace="Telerik.Web.UI" TagPrefix="telerik" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    
   <script type="text/javascript">
       window.skipDevToolsCheck = true;
    </script>
    <style type="text/css">
        .buttonDisabled {
            opacity: 0.65;
            width: 201px !important;
            height: 40px;
            border-radius: 10px;
            margin-left: 3px;
        }

            .buttonDisabled:hover {
                cursor: not-allowed;
            }

        .Wdth {
            width: 150px !important;
            margin-left: 19px;
        }

        .radio-group {
            display: flex;
            align-items: center;
            gap: 20px;
        }

        .custom-radio {
            margin-right: 10px;
        }
    </style>

    <script type="text/javascript">
        var treeView;
        $(function () {
            Sys.WebForms.PageRequestManager.getInstance().add_pageLoaded(function (evt, args) {
                // Any logic after partial postback
            });
        });

        function enableAllNodes() {
            var treeView = $find("<%= RadTreeView1.ClientID %>");
            var allNodes = treeView.get_allNodes();
            for (var i = 0; i < allNodes.length; i++) {
                allNodes[i].enable();
            }
            return false;
        }

        function disableAllNodes() {
            var treeView = $find("<%= RadTreeView1.ClientID %>");
            var allNodes = treeView.get_allNodes();
            for (var i = 0; i < allNodes.length; i++) {
                allNodes[i].disable();
            }
            return false;
        }
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <script type="text/javascript">
        var xPos, yPos;
        var prm = Sys.WebForms.PageRequestManager.getInstance();

        function BeginRequestHandler(sender, args) {
            var panel = $get('<%= Panel1.ClientID %>');
            if (panel) {
                xPos = panel.scrollLeft;
                yPos = panel.scrollTop;
            }
        }

        function EndRequestHandler(sender, args) {
            var panel = $get('<%= Panel1.ClientID %>');
            if (panel) {
                panel.scrollLeft = xPos;
                panel.scrollTop = yPos;
            }
        }

        prm.add_beginRequest(BeginRequestHandler);
        prm.add_endRequest(EndRequestHandler);
    </script>

    <asp:UpdatePanel runat="server" ID="UpChartofAccounts" UpdateMode="Conditional">
        <ContentTemplate>
            <div style="height: 30px;">
                <asp:UpdateProgress ID="UpdateProgress1" runat="server">
                    <ProgressTemplate>
                        <img src="~../../../../wwwroot/images/loading.gif" height="30px" width="30px" alt="loading" />
                    </ProgressTemplate>
                </asp:UpdateProgress>
            </div>
            <div>
                <div style="width: 387px; float: left;">
                    <asp:UpdatePanel runat="server" UpdateMode="Conditional" ID="upRadTreeview" style="width: 365px;">
                        <ContentTemplate>
                            <fieldset>
                                <legend>
                                    <asp:Label ID="Label5" runat="server" Text="Charts Of Accounts" />
                                </legend>

                                <asp:Panel runat="server" ID="Panel1" Width="380px" Height="550px" ScrollBars="Auto">
                                    <telerik:RadTreeView ID="RadTreeView1" ShowLineImages="false" runat="server" AllowNodeEditing="True"
                                        OnNodeEdit="RadTreeView1_NodeEdit" OnNodeExpand="RadTreeView1_NodeExpand" OnNodeClick="RadTreeView1_NodeClick" ForeColor="#034af3">
                                    </telerik:RadTreeView>
                                </asp:Panel>
                            </fieldset>
                        </ContentTemplate>
                        <Triggers>
                            <asp:AsyncPostBackTrigger ControlID="btnEditSave" EventName="Click" />
                            <asp:AsyncPostBackTrigger ControlID="btnDelete" EventName="Click" />
                            <asp:AsyncPostBackTrigger ControlID="btnCancel" EventName="Click" />
                        </Triggers>
                    </asp:UpdatePanel>
                </div>
                <div style="width: 700px; float: left">
                    <asp:UpdatePanel ID="UpAccountInformation" runat="server" UpdateMode="Conditional">
                        <ContentTemplate>
                            <fieldset>
                                <legend>
                                    <asp:Label ID="Label2" runat="server" Text="Account Information" />
                                </legend>
                                <div class="contentsWraper">
                                    <table cellspacing="5">
                                        <tr>
                                            <td colspan="2">
                                                <asp:Label ID="lblHeading1" runat="server" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="insertCol1">
                                                <asp:Label ID="Label1" runat="server" Text="Account Code:" />
                                            </td>
                                            <td class="insertCol2">
                                                <asp:TextBox ID="txtParent_Code" CssClass="Wdth" runat="server" ReadOnly="True" />
                                                -
                                                <asp:TextBox ID="txtAccount_Code" CssClass="Wdth" runat="server" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="insertCol1">
                                                <asp:Label ID="Label4" runat="server" Text="Account Name:" />
                                            </td>
                                            <td class="insertCol2">
                                                <asp:TextBox ID="txtAccount_Name" EnableTheming="false" runat="server" Style="margin-left:19px;Width:332px !important" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td></td>
                                            <td class="radio-group">
                                                <asp:RadioButton Text="Bank" runat="server" GroupName="a" ID="rbtnBank" Visible="false" />
                                                &nbsp;
                                                <asp:RadioButton Text="Cash" runat="server" GroupName="a" ID="rbtnCash" Visible="false" />
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                                <div>
                                    <asp:Button ID="btnEditSave" Style="width:100px !important;" runat="server" CssClass="btn btn-primry" Text="Update" OnClick="btnEditSave_Click" />&nbsp;
                                    <asp:Button ID="btnEditCancel" runat="server" Visible="false" Text="Cancel" CssClass="popupButton"
                                        OnClick="btnEditCancel_Click" OnClientClick="return enableAllNodes()" ClientIDMode="Static" />
                                    <br />
                                    <asp:Label Text="" ID="lblMessage" runat="server" CssClass="errorMessage" />
                                    <asp:HiddenField ID="hdnEditOk" runat="server" />
                                    <asp:HiddenField ID="hdnEditCancel" runat="server" />
                                    <asp:HiddenField ID="hdnAddOrEdit" runat="server" />
                                    <asp:HiddenField ID="hdnParentId" runat="server" />
                                    <asp:HiddenField ID="hdnAccountId" runat="server" />
                                    <asp:HiddenField ID="hdnLevel" runat="server" />
                                </div>
                            </fieldset>
                        </ContentTemplate>
                        <Triggers>
                            <asp:AsyncPostBackTrigger ControlID="RadTreeView1" EventName="NodeClick" />
                            <asp:AsyncPostBackTrigger ControlID="btnAdd" EventName="Click" />
                            <asp:AsyncPostBackTrigger ControlID="btnAddChild" EventName="Click" />
                            <asp:AsyncPostBackTrigger ControlID="btnCancel" EventName="Click" />
                            <asp:AsyncPostBackTrigger ControlID="btnDelete" EventName="Click" />
                        </Triggers>
                    </asp:UpdatePanel>
                    <br />
                    <asp:UpdatePanel runat="server" ID="upOptions" UpdateMode="Conditional">
                        <ContentTemplate>
                            <div style="margin-top:-20px;">
                                <fieldset>
                                    <legend>Options</legend>
                                    <div class="contentsWraper">
                                        <table>
                                            <tr>
                                                <td colspan="5">
                                                    <asp:Label ID="lblHeading" runat="server" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:Button ID="btnAdd" CssClass="btn btn-primry" Style="width:100px !important" runat="server" Text="Add Sibling" OnClick="btnAdd_Click" ClientIDMode="Static" OnClientClick="disableAllNodes();" />
                                                </td>
                                                <td>
                                                    <asp:Button ID="btnAddChild" CssClass="btn btn-primry" runat="server" Style="width:100px !important" Text="Add Child" OnClick="btnAddChild_Click" ClientIDMode="Static" OnClientClick="disableAllNodes();" />
                                                </td>
                                                <td style="display: none;">
                                                    <asp:Button ID="btnEditAccount" CssClass="btn btn-primry" runat="server" Text="Edit" OnClick="btnEditAccount_Click" />
                                                </td>
                                                <td>
                                                    <asp:Button ID="btnDelete" CssClass="btn btn-primry" Style="width:100px !important" runat="server" Text="Delete" OnClick="btnDelete_Click" OnClientClick="javascript:return confirm('Are you sure, You want to delete this account?');" />
                                                </td>
                                                <td>
                                                    <asp:Button ID="btnCancel" CssClass="btn btn-primry" Style="margin-left:5px" runat="server" Text="Cancel" SkinID="btnAutoWidth" OnClick="btnCancel_Click" />
                                                </td>
                                            </tr>
                                        </table>
                                    </div>
                                </fieldset>
                            </div>
                        </ContentTemplate>
                        <Triggers>
                            <asp:AsyncPostBackTrigger ControlID="RadTreeView1" EventName="NodeClick" />
                        </Triggers>
                    </asp:UpdatePanel>
                </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>