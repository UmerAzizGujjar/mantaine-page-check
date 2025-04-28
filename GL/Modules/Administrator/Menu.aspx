<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Menu.aspx.cs" Inherits="PMS.Menu" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

       <script type="text/javascript">
$(document).ready(function () {
    $('#ddlParent_Menu').select2();
    $('#ctl00_MainContent_ddlParent_Menu').select2();
});
       </script>
  

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
        <div class="col-lg-2 col-md-6 col-sm-6">
            <asp:Label ID="lblMenu_Name" runat="server" Text="Menu Name *"></asp:Label>
            <asp:TextBox ID="txtMenu_Name" runat="server" CssClass="form-control"></asp:TextBox>
            <asp:RequiredFieldValidator ID="rfvMenuName" runat="server" ControlToValidate="txtMenu_Name" ErrorMessage="Name is required." Display="Dynamic"></asp:RequiredFieldValidator>
        </div>
        <div class="col-lg-2 col-md-6 col-sm-6">
            <asp:Label ID="lblMenu_Discription" runat="server" Text="Menu Description *"></asp:Label>
            <asp:TextBox ID="txtMenu_Discription" runat="server" CssClass="form-control"></asp:TextBox>
            <asp:RequiredFieldValidator ID="rfvMenuDiscription" runat="server" ControlToValidate="txtMenu_Discription" ErrorMessage="Description is required." Display="Dynamic"></asp:RequiredFieldValidator>
        </div>
        <div class="col-lg-2 col-md-6 col-sm-6">
            <asp:Label ID="lblMenu_Url" runat="server" Text="URL *"></asp:Label>
            <asp:TextBox ID="txtMenu_Url" runat="server" CssClass="form-control"></asp:TextBox>
            <asp:RequiredFieldValidator ID="rfvMenuUrl" runat="server" ControlToValidate="txtMenu_Url" ErrorMessage="URL is required." Display="Dynamic"></asp:RequiredFieldValidator>
        </div>
        <div class="col-lg-2 col-md-6 col-sm-6">
            <asp:Label ID="lblParent_Menu" runat="server" Text="Parent Menu *"></asp:Label>
            <asp:DropDownList ID="ddlParent_Menu" runat="server" CssClass="form-control"></asp:DropDownList>
            <asp:RequiredFieldValidator ID="rfvParentMenu" runat="server" InitialValue="0" ControlToValidate="ddlParent_Menu" ErrorMessage="Parent Menu is required." Display="Dynamic"></asp:RequiredFieldValidator>
        </div>
          <div class="col-lg-2 col-md-6 col-sm-6">
            <asp:Label ID="lblOrder_By" runat="server" Text="Order By *"></asp:Label>
            <asp:TextBox ID="txtOrder_By" runat="server" CssClass="form-control"></asp:TextBox>
            <asp:RequiredFieldValidator ID="rfvOrderBy" runat="server" ControlToValidate="txtOrder_By" ErrorMessage="Order By is required." Display="Dynamic"></asp:RequiredFieldValidator>
        </div>
        <div class="col-lg-2 col-md-6 col-sm-6">
                     <label for="chckfreecheck" class="ml-2 wdth">Free Check</label>
            <asp:CheckBox  ID="cbActive" runat="server" CssClass="form-check-input custom-checkbox " />
        </div>
       
    </div>
    <div class="row">
        <div class="col-lg-8">
            <div class="row">
                 <div class="col-lg-2 col-md-4 col-sm-6">
            <asp:Button Text="Back" runat="server" Class="btn-gray" ID="btnBack" CausesValidation="false" PostBackUrl="~/Modules/Administrator/MenuView.aspx" />
        </div>
        <div class="col-lg-2 col-md-4 col-sm-6">
            <asp:Button Text="Save" runat="server" Class="btn btn-primry" ID="btnSave" OnClick="btnSave_Click" />
            <asp:Label ID="lblMessage" Text="" runat="server" CssClass="form-text" />
        </div>
            </div>
        </div>


        
    </div>
</asp:Content>
