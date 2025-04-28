<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="VoucherEditList.aspx.cs" Inherits="PMS.VoucherEditList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script type="text/javascript">
        $(document).ready(function () {
            $("#ctl00_MainContent_txtStartDate").datepicker({ dateFormat: "dd M yy" }).datepicker("setDate", new Date());            $("#ctl00_MainContent_txtEndDate").datepicker({ dateFormat: "dd M yy" }).datepicker("setDate", new Date());
        });
    </script>
    <style>
        input{
            width:auto !important;
        }
        .row {
            margin-left: 100px !important;
            margin-right: 500px !important;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
         <asp:Label Text="Voucher Type:" runat="server" />
    </div>
    <div class="row" style="padding-left:30px;">
            <asp:CheckBoxList runat="server" ID="lstVoucherType"></asp:CheckBoxList>
    </div>
    <br />
    <div class="row">
        <div class="col-lg-3 col-md-6 col-sm-12">
            <asp:Label ID="stDate" runat="server" Text="Start Date" CssClass="form-label"></asp:Label>
            <asp:TextBox runat="server" ID="txtStartDate" CssClass="form-control datepicker"></asp:TextBox>
        </div>
        <div class="col-lg-3 col-md-6 col-sm-12">
            <asp:Label ID="enDate" runat="server" Text="End Date" CssClass="form-label"></asp:Label>
            <asp:TextBox runat="server" ID="txtEndDate" CssClass="form-control datepicker"></asp:TextBox>
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
</asp:Content>
