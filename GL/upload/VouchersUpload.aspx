<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="VouchersUpload.aspx.cs" Inherits="PMS.VouchersUpload" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
   
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div id="container">
        <h1 class="text-center">Upload Vouchers</h1>
        <div class="form-group">
            <label for="FileUpload">Choose a file to upload:</label>
            <asp:FileUpload ID="FileUpload" runat="server" />
        </div>
        <div class="form-group">
            <div class="btn-container">
                <asp:LinkButton ID="btnUpload" Text="Upload Data" CssClass="btn btn-secondary" OnClick="btnUpload_Click" runat="server" OnClientClick="return confirm('Are you sure you want to Upload Vocuhers?');">
                <i class="fa fa-upload"></i> Upload Data
                </asp:LinkButton>
                <asp:LinkButton ID="btnRefresh" Text="Refresh" CssClass="btn btn-Refresh" OnClick="btnRefresh_Click" runat="server">
                 <i class="fa fa-refresh"></i> Refresh
                </asp:LinkButton>
                <asp:LinkButton ID="LinkButton1" Text="Download Sample" CssClass="btn btn-secondary" OnClick="btnDownloadSample_Click" runat="server">
                <i class="fa fa-download"></i> Download Sample
                </asp:LinkButton>
            </div>
        </div>
    </div>
</asp:Content>
