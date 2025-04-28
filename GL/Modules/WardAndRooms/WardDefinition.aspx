<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="WardDefinition.aspx.cs" Inherits="PMS.WardDefinition" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
        <div class="col-lg-3 col-md-6 col-sm-12">
              <asp:Label ID="lblWard_ID" runat="server" Text="Ward No"></asp:Label>
                <asp:TextBox runat="server" ID="txtWard_ID" ReadOnly="true" Text="(New)" />
         </div>
        <div class="col-lg-3 col-md-6 col-sm-12">
             <asp:Label ID="lblWard_Type" runat="server" Text="Ward Type. *"></asp:Label>
             <asp:TextBox ID="txtWard_Type" runat="server" />
               <asp:RequiredFieldValidator ID="rfvWard_Type" ControlToValidate="txtWard_Type" runat="server" ErrorMessage="Enter Ward Type." Text="*"></asp:RequiredFieldValidator>
         </div>
        <div class="col-lg-3 col-md-6 col-sm-12">
               <asp:Label ID="lblDepartment" runat="server" Text="Department *"></asp:Label>
                <asp:DropDownList ID="ddlDepartment" runat="server" AppendDataBoundItems="true"  ></asp:DropDownList>
              <asp:RequiredFieldValidator ID="rfvDepartment" ControlToValidate="ddlDepartment" runat="server" InitialValue="0" ErrorMessage="Select Department" Text="*"></asp:RequiredFieldValidator>
         </div>
        <div class="col-lg-3 col-md-6 col-sm-12">
             <asp:Label ID="lblNo_Of_Beds" runat="server" Text="No. Of Beds *"></asp:Label>
             <asp:TextBox ID="txtNo_Of_Beds" runat="server" />
              <asp:RequiredFieldValidator ID="rfvNo_Of_Beds" ControlToValidate="txtNo_Of_Beds" runat="server" ErrorMessage="Enter No. Beds" Text="*"></asp:RequiredFieldValidator>
                <asp:RangeValidator ID="rngNo_Of_Beds" Type="Integer" runat="server" MinimumValue="0" MaximumValue="9999999" ControlToValidate="txtNo_Of_Beds" ErrorMessage="Only Enter Integer Values" Text="*"></asp:RangeValidator>
         </div>
    
    </div>
    <div class="row">
         <div class="col-lg-8">
            <div class="row">
                  <div class="col-lg-2 col-md-6 col-sm-12">
               <asp:Button Text="List" CssClass="btn btn-gray"  runat="server" ID="btnBack" CausesValidation="false" PostBackUrl="~/Modules/WardAndRooms/WardDefinitionView.aspx" />
        </div>
       
          <div class="col-lg-2 col-md-6 col-sm-12">
             <asp:Button Text="Save"  runat="server" CssClass="btn btn-primry" ID="btnSave" OnClick="btnSave_Click" />
                         <asp:Label ID="lblMessage" Text="" runat="server" />
         
        </div>
        <div class="col-lg-1 col-md-6 col-sm-12">
            <asp:ValidationSummary ID="ValidationSummary1" runat="server" ForeColor="Red" HeaderText="Page Errors"
                    ShowSummary="true" DisplayMode="List" />
        </div>
            </div>
        </div>


      
    </div>
    </asp:Content>

                
        