<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AssetSelection.aspx.cs" Inherits="PMS.AssetSelection" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../assets/css/bootstrap.min.css" rel="stylesheet" />
    <script src="../assets/js/bootstrap.min.js"></script>
    <link href="../CssJs/select2.min.css" rel="stylesheet" />
    <script src="../CssJs/select2.min.js"></script>
    <script type="text/javascript">
        $(document).ready(function () {
            $('#ddlLocation_ID').select2();
            $('#ddlAsset_Cat').select2();
            $('#ddlAsset_SubCat').select2();
        });
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
        <div class="col-lg-3 col-md-3 col-sm-3">
            <asp:Label ID="lblAsset_Selection_ID" runat="server" Text="Asset Selection ID"></asp:Label>
            <asp:TextBox runat="server" ID="txtAsset_Selection_ID" ReadOnly="true" Text="(New)" />
        </div>
        <div class="col-lg-3 col-md-3 col-sm-3">
            <asp:Label ID="lblCompany_ID" runat="server" Text="Hospital Name"></asp:Label>
            <asp:TextBox runat="server" ID="txtCompany_ID" ReadOnly="true" />
        </div>
        <div class="col-lg-3 col-md-3 col-sm-3">
            <asp:Label ID="lblLocation_ID" runat="server" CssClass="control-label" Text="Branch *"></asp:Label>
            <asp:DropDownList ID="ddlLocation_ID" runat="server" AppendDataBoundItems="true"></asp:DropDownList>
            <asp:RequiredFieldValidator ID="rfvLocation_ID" ControlToValidate="ddlLocation_ID" InitialValue="0" runat="server" ErrorMessage="Select Branch" Text="*"></asp:RequiredFieldValidator>
        </div>
        <div class="col-lg-3 col-md-3 col-sm-3">
            <asp:Label ID="lblAsset_Cat" runat="server" CssClass="control-label" Text="Asset Category *"></asp:Label>
            <asp:DropDownList ID="ddlAsset_Cat" runat="server" AutoPostBack="true" AppendDataBoundItems="true" OnSelectedIndexChanged="ddlAsset_Cat_SelectedIndexChanged"></asp:DropDownList>
            <asp:RequiredFieldValidator ID="rfvAsset_Cat" ControlToValidate="ddlAsset_Cat" InitialValue="0" runat="server" ErrorMessage="Select Asset Category" Text="*"></asp:RequiredFieldValidator>
        </div>
    </div>

    <div class="row">
        <div class="col-lg-3 col-md-3 col-sm-3">
            <asp:Label ID="tblAsset_SubCat" runat="server" CssClass="control-label" Text="Asset Sub-Category"></asp:Label>
            <asp:UpdatePanel ID="UpdatePanel1" runat="server" UpdateMode="Conditional">
                <Triggers>
                    <asp:AsyncPostBackTrigger ControlID="ddlAsset_Cat" EventName="SelectedIndexChanged" />
                </Triggers>
                <ContentTemplate>
                    <asp:DropDownList ID="ddlAsset_SubCat" runat="server" AppendDataBoundItems="true">
                    </asp:DropDownList>
                </ContentTemplate>
            </asp:UpdatePanel>
        </div>

        <div class="col-lg-3 col-md-3 col-sm-3">
            <asp:Label ID="lblItem_Serial" runat="server" Text="Item Serial"></asp:Label>
            <asp:TextBox ID="txtItem_Serial" runat="server" />
        </div>
        <div class="col-lg-3 col-md-3 col-sm-3">
            <asp:UpdateProgress ID="UpdateProgress1" runat="server">
                <ProgressTemplate>
                    <div class="loadingimage">
                        <asp:Image ID="image1" ImageUrl="../../wwwroot/images/loading.gif" runat="server" />
                    </div>
                </ProgressTemplate>
            </asp:UpdateProgress>
        </div>
    </div>
    <br />
    <div class="row">
        <div class="col-lg-1 col-md-1 col-sm-1">
            <asp:Button Text="Back" runat="server" CssClass="btn-primry" ID="btnBack" CausesValidation="false" PostBackUrl="~/Modules/Administrator/AssetSelectionView.aspx" />
        </div>
        <div class="col-lg-1 col-md-1 col-sm-1">
            <asp:Button Text="Save" runat="server" CssClass="btn-primry" ID="btnSave" OnClick="btnSave_Click" />
        </div>
        <div class="col-lg-2 col-md-2 col-sm-2">
            <asp:Label ID="lblMessage" Text="" runat="server" />
            <asp:ValidationSummary ID="ValidationSummary1" runat="server" ForeColor="Red" HeaderText="Page Errors" ShowSummary="true" DisplayMode="List" />
        </div>
    </div>

</asp:Content>
