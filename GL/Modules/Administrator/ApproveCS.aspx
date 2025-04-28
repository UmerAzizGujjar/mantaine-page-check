<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ApproveCS.aspx.cs" Inherits="PMS.ApproveCS" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
     
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="table-container" style="overflow: scroll; height: 400px;">
        <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False" EnableModelValidation="True" PageSize="15" AllowPaging="true" OnPageIndexChanging="GridView1_PageIndexChanging">
            <Columns>
                <asp:TemplateField>
                    <ItemTemplate>
                        <asp:CheckBox ID="chkSelect" Text="" runat="server" />
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="CS ID" Visible="False">
                    <ItemTemplate>
                        <asp:Label ID="lblCS_Ven_Master_ID" runat="server" Text='<%# Bind("CS_Ven_Master_ID") %>'></asp:Label>
                    </ItemTemplate>
                    <EditItemTemplate>
                        <asp:TextBox ID="txtCS_Ven_Master_ID" runat="server" Text='<%# Bind("CS_Ven_Master_ID") %>'></asp:TextBox>
                    </EditItemTemplate>
                </asp:TemplateField>
                <asp:BoundField DataField="CS_Ven_No" HeaderText="CS No." ItemStyle-HorizontalAlign="Center" ItemStyle-Width="70px" />
                <asp:BoundField DataField="CS_Date" HeaderText="CS Date" ItemStyle-HorizontalAlign="Center" DataFormatString="{0:d}" ItemStyle-Width="100px" />
                <asp:BoundField DataField="Department" HeaderText="Department" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="150px" />
                <asp:BoundField DataField="Creator" HeaderText="Creator" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="120px" />

                <asp:TemplateField HeaderText="CS Remarks">
                    <ItemTemplate>
                        <asp:Label ID="lblRemarks" runat="server" Text='<%# Eval("Remarks") %>' CssClass="remarks-label"></asp:Label>
                    </ItemTemplate>
                    <ItemStyle Width="500px" />
                </asp:TemplateField>
                <asp:BoundField DataField="Status" HeaderText="Status" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="100px" />
                <asp:TemplateField HeaderText="Approve By">
                    <ItemTemplate>
                        <div style="white-space: nowrap; overflow: auto; max-width: 180px;">
                            <asp:Label ID="lblApproveBy" runat="server" Text='<%# Eval("Approve_By") %>'></asp:Label>
                        </div>
                    </ItemTemplate>
                    <ItemStyle Width="180px" />
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Decision Remarks">
                    <ItemTemplate>
                        <asp:TextBox ID="txtApproval_RejectionRemarks" runat="server" Width="250px" TextMode="MultiLine" CssClass="approval-remarks-textbox"></asp:TextBox>
                    </ItemTemplate>
                    <ItemStyle Width="300px" />
                </asp:TemplateField>



                <asp:TemplateField>
                    <HeaderTemplate>
                        <div style="width: 100px; text-align: center;">
                            Actions
                        </div>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <asp:HyperLink ToolTip="Edit" ID="LinkButton3" runat="server" NavigateUrl='<%# "../AP/ComparativeStatementVendor.aspx?CM_ID="+ Eval("CS_Ven_Master_ID")%>' Text="Preview" Target="_blank" Style="display: block; width: 100%; text-align: center;" />
                    </ItemTemplate>
                    <HeaderStyle CssClass="header-center-align" />
                </asp:TemplateField>
            </Columns>
            <PagerSettings Mode="NumericFirstLast" FirstPageText="First" LastPageText="Last" />
            <PagerStyle HorizontalAlign="Right" CssClass="pager-style" />
            <HeaderStyle BackColor="#438eb9 " Font-Bold="true" ForeColor="White" Font-Size="14px" />
            <RowStyle CssClass="gridview-row" />
            <AlternatingRowStyle CssClass="gridview-alt-row" />
        </asp:GridView>
    </div>
    <div class="row">
        <div class="col-lg-8">
            <div class="row">
                <div class="col-lg-3 col-md-3 col-sm-4">

                    <asp:Button ID="btnApprove" CssClass="btn btn-primry" Text="Approve Selected CS" runat="server" SkinID="btnAutoWidth" OnClick="btnApprove_Click" />
                </div>
                <div class="col-lg-3 col-md-3 col-sm-4">
                    <asp:Button ID="btnCancel" CssClass="btn btn-primry" Text="Reject Selected CS" runat="server" SkinID="btnAutoWidth" OnClick="btnCancel_Click" />
                </div>
            </div>
        </div>
        </div>
</asp:Content>
