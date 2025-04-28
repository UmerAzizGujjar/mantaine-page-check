<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="InvItemsUpload.aspx.cs" Inherits="PMS.InvItemsUpload" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
   
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div id="container">
        <h1 class="text-center">Upload Inventory Items</h1>
        <div class="form-group">
            <label for="FileUpload">Choose a file to upload:</label>
            <asp:FileUpload ID="FileUpload" runat="server" />
        </div>
        <div class="form-group">
            <asp:LinkButton ID="btnUpload" Text="Upload Data" CssClass="btn btn-secondary" OnClick="btnUpload_Click" runat="server" OnClientClick="return confirm('Are you sure you want to Upload Inventory Items?');">
               <i class="fa fa-upload"></i> Upload Data
            </asp:LinkButton>
            <asp:LinkButton ID="btnDownloadSample" Text="Download Sample" CssClass="btn btn-secondary" OnClick="btnDownloadSample_Click" runat="server">
              <i class="fa fa-download"></i> Download Sample
            </asp:LinkButton>
        </div>
    </div>
</asp:Content>
