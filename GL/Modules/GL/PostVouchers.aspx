<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="PostVouchers.aspx.cs" Inherits="PMS.GL.PostVouchers" Theme="Default_Theme" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <h1>Un-posted Vouchers List</h1>
    <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False" 
        EnableModelValidation="True">
        <Columns>
            <asp:TemplateField>
            <ItemTemplate>
                <asp:CheckBox ID="chkSelect" Text="" runat="server" />
            </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Voucher ID" Visible="False">
                <ItemTemplate>
                    <asp:Label ID="lblVoucher_ID" runat="server" Text='<%# Bind("Voucher_ID") %>'></asp:Label>
                </ItemTemplate>
                <EditItemTemplate>
                    <asp:TextBox ID="txtVoucher_ID" runat="server" Text='<%# Bind("Voucher_ID") %>'></asp:TextBox>
                </EditItemTemplate>
            </asp:TemplateField>
            <asp:BoundField DataField="Voucher_No" HeaderText="Voucher No." />
            <asp:BoundField DataField="Voucher_Type" HeaderText="Voucher Type" />
            <asp:BoundField DataField="Voucher_Date" HeaderText="Voucher Date" DataFormatString="{0: dd MMM yyyy}" />
            <asp:BoundField DataField="Remarks" HeaderText="Remarks"  >
            <ItemStyle Width="550px" />
            </asp:BoundField>
        </Columns>
    </asp:GridView>
    <br />
    <div class="row">
        <div class="col-lg-2 col-md-4 col-sm-12">
    <asp:Button ID="btnApprove" CssClass="btn btn-primry" Text="Approve Selected Vouchers" runat="server" 
       onclick="btnApprove_Click" />
            </div>
        <div class="col-lg-2 col-md-4 col-sm-12">
    <asp:Button ID="btnCancel" CssClass="btn btn-primry" Text="Delete Selected Vouchers" runat="server" 
        onclick="btnCancel_Click" />
            </div>
        </div>
</asp:Content>
