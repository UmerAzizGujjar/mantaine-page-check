<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="CloseYear.aspx.cs" Inherits="PMS.CloseYear" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <asp:UpdatePanel runat="server" ID="upFome">
        <ContentTemplate></ContentTemplate>
    </asp:UpdatePanel>
    <asp:Panel runat="server" ID="pnlForm" DefaultButton="btnCloseYear">
        <div class="row">
            <div class="col-lg-1 col-md-6 col-sm-12">
                 <asp:TextBox runat="server" ReadOnly="false" ID="txtYear" />
 <asp:RequiredFieldValidator ErrorMessage="Year is required." Display="Dynamic" ControlToValidate="txtYear" runat="server" />
            </div>
            <div class="col-lg-1 col-md-4 col-sm-12">
                 <asp:Button Text="Close Year" CssClass="btn btn-primry" ID="btnCloseYear" runat="server" OnClick="btnCloseYear_Click" />
                  <asp:Label ID="lblMessage" Text="" runat="server" />
            </div>

        </div>

   
    </asp:Panel>
</asp:Content>
