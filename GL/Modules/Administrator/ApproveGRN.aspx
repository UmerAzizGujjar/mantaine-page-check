<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ApproveGRN.aspx.cs" Inherits="PMS.ApproveGRN" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        .pager-style {
            margin-top: 10px;
        }

            .pager-style a,
            .pager-style span {
                display: inline-block;
                margin-left: 5px;
                padding: 5px 10px;
                border: 1px solid #ccc;
                border-radius: 5px;
                background-color: #f0f0f0;
                color: #333;
                margin-top: 5px;
                margin-bottom: 5px;
                text-decoration: none;
            }

                .pager-style a:hover {
                    background-color: #e0e0e0;
                }

        .gridview-row {
            background-color: #f9f9f9;
        }

        .gridview-alt-row {
            background-color: #e0e0e0;
        }

            .gridview-row td,
            .gridview-alt-row td {
                padding: 10px;
                font-size: 14px;
            }

        .gridview-header {
            background-color: #449777;
            color: white;
            font-weight: bold;
            padding: 10px;
        }

        .remarks-label {
            display: block;
            white-space: normal;
            word-wrap: break-word;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False" EnableModelValidation="True" PageSize="15" AllowPaging="true" OnPageIndexChanging="GridView1_PageIndexChanging">
        <Columns>
            <asp:TemplateField>
                <ItemTemplate>
                    <asp:CheckBox ID="chkSelect" Text="" runat="server" />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="GRN ID" Visible="False">
                <ItemTemplate>
                    <asp:Label ID="lblGRN_ID" runat="server" Text='<%# Bind("GRN_ID") %>'></asp:Label>
                </ItemTemplate>
                <EditItemTemplate>
                    <asp:TextBox ID="txtGRN_ID" runat="server" Text='<%# Bind("GRN_ID") %>'></asp:TextBox>
                </EditItemTemplate>
            </asp:TemplateField>
            <asp:BoundField DataField="GRN_Num" HeaderText="GRN No." ItemStyle-HorizontalAlign="Center" ItemStyle-Width="70px" />
            <asp:BoundField DataField="GRN_Date" HeaderText="GRN Date" ItemStyle-HorizontalAlign="Center" DataFormatString="{0:d}" ItemStyle-Width="100px" />
            <asp:BoundField DataField="Creator" HeaderText="Creator" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="120px" />
            <asp:TemplateField HeaderText="Remarks">
                <ItemTemplate>
                    <asp:Label ID="lblRemarks" runat="server" Text='<%# Eval("Remarks") %>' CssClass="remarks-label"></asp:Label>
                </ItemTemplate>
                <ItemStyle Width="550px" />
            </asp:TemplateField>
            <asp:BoundField DataField="Status" HeaderText="Status" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="100px" />
            <asp:BoundField DataField="Approve_By" HeaderText="Approve By" ItemStyle-Width="180px" />
            <asp:TemplateField>
                <HeaderTemplate>
                    <div style="width: 100px; text-align: center;">
                        Actions
                    </div>
                </HeaderTemplate>
                <ItemTemplate>
                    <asp:HyperLink ToolTip="Edit" ID="LinkButton3" runat="server" NavigateUrl='<%# "../Inventory/GRN.aspx?GRN_ID="+ Eval("GRN_ID")%>' Text="Preview" Target="_blank" Style="display: block; width: 100%; text-align: center;" />
                </ItemTemplate>
                <HeaderStyle CssClass="header-center-align" />
            </asp:TemplateField>
        </Columns>
        <PagerSettings Mode="NumericFirstLast" FirstPageText="First" LastPageText="Last" />
        <PagerStyle HorizontalAlign="Right" CssClass="pager-style" />
        <HeaderStyle BackColor="#449777" ForeColor="White" Font-Size="14px" />
        <RowStyle CssClass="gridview-row" />
        <AlternatingRowStyle CssClass="gridview-alt-row" />
    </asp:GridView>
    <br />
    <asp:Button ID="btnApprove" Width="200" Text="Approve Selected GRN" runat="server" SkinID="btnAutoWidth" OnClick="btnApprove_Click" />
    <asp:Button ID="btnCancel" Width="180" Text="Reject Selected GRN" runat="server" SkinID="btnAutoWidth" OnClick="btnCancel_Click" />
</asp:Content>
