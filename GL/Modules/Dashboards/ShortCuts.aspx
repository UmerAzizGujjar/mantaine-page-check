<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ShortCuts.aspx.cs" Inherits="PMS.Modules.Dashboards.ShortCuts" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
   <link href="../../wwwroot/IITH_Theme/css/Shortcuts.css" rel="stylesheet" />
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
              <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Dashboards/BillingSection.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/IITH_Theme/images/dashboard_Icons/cash-machine.png" alt="Billing" />
                    <h5 class="cocotxt">Billing</h5>
                </a>

            </div>
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Dashboards/PatientSection.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/IITH_Theme/images/dashboard_Icons/medical.png" alt="Patients" style="object-fit: contain;" />
                    <h5 class="cocotxt">Patients</h5>
                </a>
            </div>
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Dashboards/LabSection.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/IITH_Theme/images/dashboard_Icons/microscope.png" alt="Lab/Radiology" style="object-fit: contain;" />
                    <h5 class="cocotxt">Lab/Radiology</h5>
                </a>
            </div>
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Dashboards/PharmacySection.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/IITH_Theme/images/dashboard_Icons/pharmacy.png" alt="Pharmacy" style="object-fit: contain;" />
                    <h5 class="cocotxt">Pharmacy</h5>
                </a>
            </div>
        </div>
        <br />
        <div class="row text-center">
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Dashboards/InventorySection.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/IITH_Theme/images/dashboard_Icons/shopping-cart.png" alt="Inventory" style="object-fit: contain;" />
                    <h5 class="cocotxt">Inventory</h5>
                </a>
            </div>
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Dashboards/PurchaseSection.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/IITH_Theme/images/dashboard_Icons/shopping-basket.png" alt="Purchase" style="object-fit: contain;" />
                    <h5 class="cocotxt">Purchase</h5>
                </a>
            </div>
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Dashboards/AccountSection.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/IITH_Theme/images/dashboard_Icons/budget.png" alt="Accounts" style="object-fit: contain;" />
                    <h5 class="cocotxt">Accounts</h5>
                </a>
            </div>
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Dashboards/AdminSection.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/IITH_Theme/images/dashboard_Icons/administrator.png" alt="Administration" style="object-fit: contain;" />
                    <h5 class="cocotxt">Administration</h5>
                </a>
            </div>
        </div>
    </div>

    <%--
    <div class="col-sm-6 col-sm-offset-4" style="margin-top: 47px;">
        <asp:Image ID="imgLogo" runat="server" ImageUrl="~../../../../wwwroot/images/HMIS_Icons/TibbITLogo_2.png"
            Style="height: 245px; width: 408px; border-width: 0px; opacity: 0.5; position: relative; z-index: -1;" />
    </div>--%>
</asp:Content>
