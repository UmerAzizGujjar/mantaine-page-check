<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Ledger.aspx.cs" Inherits="PMS.Ledger" Theme="Default_Theme" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <script type="text/javascript" src="wwwroot/Scripts/jquery.tokeninput.js"></script>

    <script type="text/javascript">

        $(function () {
            $("#ctl00_MainContent_txtStart_Date").datepicker({ dateFormat: "dd M yy" }).datepicker("setDate", new Date());
            $("#ctl00_MainContent_txtEnd_Date").datepicker({ dateFormat: "dd M yy" }).datepicker("setDate", new Date());

        });

        $(document).ready(function () {
            loadtokenInputsByAccount_ID();
        });
        function loadtokenInputsByAccount_ID() {
            $("#ctl00_MainContent_txtAccount_ID").tokenInput("../../json.aspx", {
                tokenLimit: 1
            });
            $("#ctl00_MainContent_txtAccount_IDlvl3").tokenInput("../../json.aspx", {
                tokenLimit: 1
            });
        }
    </script>
    <style>
        .row{
            margin-left: 50px !important;
            margin-right: 150px !important;
        }
    </style>
    <div class="container mt-4">
        <div class="row mb-3">
            <div class="col-lg-3 col-md-4 col-sm-12" id="accountDiv" runat="server">
                 <asp:Label Text="Account" runat="server" ID="lblAccount" CssClass="form-label"></asp:Label>
                 <asp:TextBox  runat="server" ID="txtAccount_ID" CssClass="form-control"  />
                    <asp:RequiredFieldValidator ID="rfvAccount_ID" ErrorMessage="Account is required."
                        SetFocusOnError="true" Display="Dynamic" ControlToValidate="txtAccount_ID" runat="server" />
            </div>
             <div class="col-lg-3 col-md-4 col-sm-12" id="vendorDiv" runat="server">
                 <asp:Label ID="lblVendor" runat="server" Text="Vendor" CssClass="form-label"></asp:Label>
                 <asp:DropDownList ID="ddlVendor" runat="server" CssClass="form-control"></asp:DropDownList>
            </div>
    <div class="col-lg-3 col-md-4 col-sm-12" id="vendorTypeDiv" runat="server" >
    <asp:Label ID="lblVendorType" runat="server" Text="Vendor Type" CssClass="form-label"></asp:Label>
    <asp:DropDownList ID="ddlVendorType" runat="server" CssClass="form-control"></asp:DropDownList>
</div>

            <div class="col-lg-3 col-md-4 col-sm-12" id="stockDiv" runat="server">
                 <asp:Label ID="lblStock" runat="server" Text="Stock" CssClass="form-label"></asp:Label>
                 <asp:DropDownList ID="ddlStock" runat="server" CssClass="form-control">
                        <asp:ListItem Value="All" Text="All"></asp:ListItem>
                        <asp:ListItem Value="0" Text="Zero"></asp:ListItem>
                        <asp:ListItem Value="1" Text="Greater Than Zero"></asp:ListItem>
                    </asp:DropDownList>
            </div>
        </div>
        <div class="row" id="DateDiv" runat="server">
                <div class="col-lg-3 col-md-3 col-sm-12">
                    <asp:Label ID="sttDate" runat="server" Text="Start Date" CssClass="form-label"></asp:Label>
                    <asp:TextBox runat="server" ID="txtStart_Date" CssClass="form-control datepicker"></asp:TextBox>
                </div>
                <div class="col-lg-3 col-md-3 col-sm-12">
                    <asp:Label ID="endDate" runat="server" Text="End Date" CssClass="form-label"></asp:Label>
                    <asp:TextBox runat="server" ID="txtEnd_Date" CssClass="form-control datepicker"></asp:TextBox>
                </div>
            </div>

        <div class="row">
            <div class="col-lg-2">
                <asp:Button Text="Preview" CssClass="btn btn-primry" ID="btnPreview" runat="server" OnClick="btnPreview_Click" />
            </div>
            <div class="col-lg-2">
                <asp:Button Text="Cancel" ID="btnCancel" CssClass="btn btn-gray" runat="server" CausesValidation="false" />
            </div>
        </div>
    </div>
</asp:Content>


