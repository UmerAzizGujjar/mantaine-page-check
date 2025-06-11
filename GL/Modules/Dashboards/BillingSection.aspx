<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="BillingSection.aspx.cs" Inherits="PMS.Modules.Dashboards.BilligSection" %>


<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/StandardTheme/css/Shortcuts.css" rel="stylesheet" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div id="loading">
        <div id="loading-center">
            <div id="loading-center-absolute">
                <div class="object" id="object_one"></div>
                <div class="object" id="object_two"></div>
                <div class="object" id="object_three"></div>
                <div class="object" id="object_four"></div>
                <div class="object" id="object_five"></div>
                <div class="object" id="object_six"></div>
                <div class="object" id="object_seven"></div>
                <div class="object" id="object_eight"></div>
                <div class="object" id="object_big"></div>
            </div>
        </div>
    </div>
    <br />
    <div class="container">
    <div class="row text-center">
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Billing/BillingProcess.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/StandardTheme/images/dashboard_Icons/cash-machine.png" alt="Billing" style="object-fit: contain;" />
                    <h5 class="cocotxt">Patient Billing</h5>
                </a>
            </div>
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Billing/Receipts.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/StandardTheme/images/dashboard_Icons/order.png" alt="Receipt" style="object-fit: contain;" />
                    <h5 class="cocotxt">Add Receipt</h5>
                </a>
            </div>
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Billing/AddNewAdvance.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/StandardTheme/images/dashboard_Icons/money.png" alt="Add Advance" style="object-fit: contain;" />
                    <h5 class="cocotxt">Add Advance</h5>
                </a>
            </div>
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Dashboards/PharmacySection.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/StandardTheme/images/dashboard_Icons/cashback.png" alt="Refund" style="object-fit: contain;" />
                    <h5 class="cocotxt">Add Refund</h5>
                </a>
            </div>
        </div>

    </div>
   



</asp:Content>
