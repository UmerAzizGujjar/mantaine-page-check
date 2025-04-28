<%@ Control Language="C#" AutoEventWireup="True" CodeBehind="LookupControl.ascx.cs"
    Inherits="PMS.LookupControl" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>
<link href="Styles/Site.css" rel="stylesheet" type="text/css" />
<asp:UpdatePanel ID="upLookup" runat="server">
    <ContentTemplate>
        <asp:ModalPopupExtender ID="Account_ModalPopupExtender" runat="server" DynamicServicePath=""
            TargetControlID="hdnOk" CancelControlID="hdnCancel" BackgroundCssClass="popupBackground"
            PopupControlID="AccountPanel">
        </asp:ModalPopupExtender>
        <asp:Panel ID="AccountPanel" runat="server" >
            <asp:UpdateProgress ID="UpdateProgress1" runat="server">
                <ProgressTemplate>
                    <img src="images/loading.gif" alt="loading" />
                </ProgressTemplate>
            </asp:UpdateProgress>
            <div style="width: 675px; text-align: center; padding: 1px; height:35px; margin: 10px; background-color:#F7F6F3">
                <div>
                    <div style="width: 637px; float: left; height: 32px;">
                        <table>
                            <tr>
                                <td width="15%">
                                    <asp:Label ID="lblCodeSearch" runat="server" Text="Search Criteria:" /></td>
                                <td>
                                    <asp:TextBox ID="txtCodeSearch" runat="server" Style="width: 170px !important;"></asp:TextBox></td>
                                <td width="12%">
                                    <asp:Label ID="Label2" runat="server" Text="Search On:" /></td>
                                <td>
                                    <asp:DropDownList runat="server" ID="ddlFields" ClientIDMode="Static">
                                    </asp:DropDownList></td>
                                <td>
                                    <asp:Button ID="btnSearch" runat="server" ClientIDMode="Static" Text="Search"
                                        OnClick="btnSearch_Click" /></td>
                                <td></td>
                            </tr>
                        </table>

                    </div>
                    <div style="width: 25px; text-align: right; float: right; height: 21px; padding:3px;">
                        <asp:ImageButton ID="imgbtnCancel" runat="server" Height="20px" ToolTip="close" ImageUrl="~/images/close.jpg"
                            OnClick="imgbtnCancel_Click" />
                    </div>
                </div>

                <div style="width: 670px">
                    <asp:GridView ID="gvLookup" runat="server" EmptyDataText="There are no data records to display."
                        AllowPaging="True" OnRowCreated="gvLookup_RowCreated" OnRowCommand="gvLookup_RowCommand"
                        Width="675px"
                        HeaderStyle-HorizontalAlign="Left" EnableModelValidation="True" HorizontalAlign="Left">
                        <Columns>
                            <asp:CommandField ShowHeader="true" ShowSelectButton="true">
                                <ItemStyle ForeColor="#0000EA" />
                            </asp:CommandField>
                        </Columns>

                        <PagerTemplate>
                            <table>
                                <tr>
                                    <td>
                                        <asp:LinkButton ID="FirstButton" CommandName="First" ToolTip="first" CommandArgument="First" Text="<<"
                                            runat="server" />
                                    </td>
                                    <td>
                                        <asp:LinkButton ID="PrevButton" CommandName="Prev" ToolTip="previous" CommandArgument="Prev" Text="<"
                                            runat="server" />
                                    </td>
                                    <td>
                                        <asp:LinkButton ID="NextButton" CommandName="Next" ToolTip="next" CommandArgument="Next" Text=">"
                                            runat="server" />
                                    </td>
                                    <td>
                                        <asp:LinkButton ID="LastButton" CommandName="Last" ToolTip="last" CommandArgument="Last" Text=">>"
                                            runat="server" />
                                    </td>
                                </tr>
                            </table>
                        </PagerTemplate>
                        <AlternatingRowStyle BackColor="White" ForeColor="#284775" />
                        <EditRowStyle BackColor="#999999" />
                        <FooterStyle BackColor="#5D7B9D" Font-Bold="True" ForeColor="White" />
                        <HeaderStyle BackColor="#5D7B9D" Font-Bold="True" ForeColor="White" />
                        <PagerStyle BackColor="#5D7B9D" HorizontalAlign="Center" CssClass="whitelinks" />
                        <RowStyle BackColor="#F7F6F3" ForeColor="#333333" HorizontalAlign="Left" />
                        <SelectedRowStyle BackColor="#E2DED6" Font-Bold="True" ForeColor="#333333" />
                    </asp:GridView>
                </div>
                <asp:HiddenField ID="hdnOk" runat="server" />
                <asp:HiddenField ID="hdnCancel" runat="server" />
            </div>
        </asp:Panel>
    </ContentTemplate>
        <Triggers>
        <asp:AsyncPostBackTrigger ControlID="btnSearch" EventName="Click" />
    </Triggers>
</asp:UpdatePanel>
