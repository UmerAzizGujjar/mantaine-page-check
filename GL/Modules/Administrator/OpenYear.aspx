<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="OpenYear.aspx.cs" Inherits="PMS.OpenYear" %>


<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <asp:UpdatePanel runat="server" ID="upFome">
        <ContentTemplate>
            <asp:Panel runat="server" ID="pnlForm" DefaultButton="btnOpenYear">
                <div class="row">
                    <div class="col-lg-1 col-md-4 col-sm-12">
                    <asp:TextBox runat="server" ReadOnly="false" ID="txtYear" />
 <asp:RequiredFieldValidator ID="RequiredFieldValidator1" ErrorMessage="Year is required." Display="Dynamic" ControlToValidate="txtYear" runat="server" />
               </div>
                        </div>
                <div class="row">
                    <div class="col-lg-1 col-md-4 col-sm-12">
                        <asp:Button Text="Open Year" CssClass="btn-primry" ID="btnOpenYear" runat="server" OnClick="btnOpenYear_Click" />
                    </div>
                    <div class="col-lg-1 col-md-4 col-sm-12">
                        <asp:Button Text="Reload" ID="btnReload" CssClass="btn-primry" runat="server" OnClick="btnReload_Click" />
</div><asp:Label ID="lblMessage" Text="" runat="server" />
                </div>
             


          
            </asp:Panel>

        </ContentTemplate>
    </asp:UpdatePanel>

</asp:Content>
