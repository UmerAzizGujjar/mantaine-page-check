<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="VendorsUpload.aspx.cs" Inherits="PMS.VendorsUpload" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .vu-help { background: #f7f9fb; border: 1px solid #e1e6eb; border-radius: 4px; padding: 10px 14px; margin-bottom: 14px; }
        .vu-help ul { margin: 6px 0 0 18px; padding: 0; }
        .vu-summary { margin: 12px 0; font-size: 14px; }
        .vu-summary .label { font-size: 13px; margin-right: 6px; }
        .vu-grid th { background: #f0f3f6; white-space: nowrap; }
        .vu-grid td { vertical-align: middle !important; }
        .vu-ok { background: #e8f6ec !important; }
        .vu-skip { background: #fdf6e3 !important; }
        .vu-err { background: #fbeaea !important; }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div id="container">
        <h1 class="text-center">Upload Vendors</h1>

        <div class="vu-help">
            <b>How it works</b>
            <ul>
                <li>Click <b>Download Sample</b>, fill one vendor per row on the <b>Vendors</b> sheet (drop-downs come from the <b>Lookups</b> sheet), save as .xlsx and upload.</li>
                <li><b>Vendor Name</b> and <b>Vendor Type</b> are required. Leave <b>Payable Account Code</b> blank to auto-create the vendor's GL account under Trade &amp; Other Payables, or enter an existing level-4 account code.</li>
                <li>Vendors whose name already exists are skipped. If any row has an error, nothing is saved; fix the rows marked in red and upload again.</li>
            </ul>
        </div>

        <div class="form-group">
            <label for="<%= FileUpload.ClientID %>">Choose a file to upload (.xlsx, .xls or .csv):</label>
            <asp:FileUpload ID="FileUpload" runat="server" accept=".xlsx,.xls,.csv" />
        </div>
        <div class="form-group">
            <asp:LinkButton ID="btnUpload" CssClass="btn btn-secondary" OnClick="btnUpload_Click" runat="server" OnClientClick="return confirm('Are you sure you want to upload Vendors?');">
                <i class="fa fa-upload"></i> Upload Vendors
            </asp:LinkButton>
            <asp:LinkButton ID="btnDownloadSample" CssClass="btn btn-secondary" OnClick="btnDownloadSample_Click" runat="server">
                <i class="fa fa-download"></i> Download Sample
            </asp:LinkButton>
            <asp:HyperLink ID="lnkVendorList" CssClass="btn btn-gray" NavigateUrl="~/Modules/AP/VendorView.aspx" runat="server">
                <i class="fa fa-list"></i> Vendor List
            </asp:HyperLink>
        </div>

        <asp:Panel ID="pnlResult" runat="server" Visible="false">
            <div class="vu-summary">
                <asp:Literal ID="litSummary" runat="server" />
            </div>
            <div class="table-responsive">
                <asp:GridView ID="gvResult" runat="server" AutoGenerateColumns="true" CssClass="table table-bordered table-condensed vu-grid"
                    OnRowDataBound="gvResult_RowDataBound" />
            </div>
        </asp:Panel>
    </div>
</asp:Content>
