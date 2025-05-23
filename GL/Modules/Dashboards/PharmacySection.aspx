<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="PharmacySection.aspx.cs" Inherits="PMS.Modules.Dashboards.PharmacySection" %>

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
    <br />
    <div class="container">
        <div class="row text-center">
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Billing/IssueMedicine.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/IITH_Theme/images/dashboard_Icons/pharmacy.png" alt="Sale" style="object-fit: contain;" />
                    <h5 class="cocotxt">Pharmacy Sale</h5>
                </a>
            </div>
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Billing/IssueMedicineList.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/IITH_Theme/images/dashboard_Icons/diagnosis.png" alt="Medicnine" style="object-fit: contain;" />
                    <h5 class="cocotxt">Issue Medicnine</h5>
                </a>
            </div>
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Administrator/Pharmacy_Users.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/IITH_Theme/images/dashboard_Icons/pharmacist.png" alt="User" style="object-fit: contain;" />
                    <h5 class="cocotxt">Pharmacy User</h5>
                </a>
            </div>
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Billing/IssueMedicine.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/IITH_Theme/images/dashboard_Icons/sales.png" alt="Return" style="object-fit: contain;" />
                    <h5 class="cocotxt">Sale Return</h5>
                </a>
            </div>
        </div>
        <br />
        <div class="row text-center">
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Billing/IssueMedicineList.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/IITH_Theme/images/dashboard_Icons/Report.png" alt="Report" style="object-fit: contain;" />
                    <h5 class="cocotxt">Sale Report</h5>
                </a>
            </div>
    </div>

    <%--
    <div class="col-sm-6 col-sm-offset-4" style="margin-top: 47px;">
        <asp:Image ID="imgLogo" runat="server" ImageUrl="~../../../../wwwroot/images/HMIS_Icons/TibbITLogo_2.png"
            Style="height: 245px; width: 408px; border-width: 0px; opacity: 0.5; position: relative; z-index: -1;" />
    </div>--%>
</asp:Content>
