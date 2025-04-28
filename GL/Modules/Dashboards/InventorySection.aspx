<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="InventorySection.aspx.cs" Inherits="PMS.Modules.Dashboards.InventorySection" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/css/Shortcuts.css" rel="stylesheet" />
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
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Inventory/GoodsIssuanceRequest.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/images/dashboard_Icons/GIR.png" alt="GIR" style="object-fit: contain;" />
                    <h5 class="cocotxt">GIR</h5>
                </a>
            </div>
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Inventory/GoodsIssuanceNote.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/images/dashboard_Icons/GIN.png" alt="GIN" style="object-fit: contain;" />
                    <h5 class="cocotxt">GIN</h5>
                </a>
            </div>
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Inventory/InversionGatePass.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/images/dashboard_Icons/IGP.png" alt="IGP" style="object-fit: contain;" />
                    <h5 class="cocotxt">IGP</h5>
                </a>
            </div>
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Inventory/GoodRecevied.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/images/dashboard_Icons/ReturnSale.png" alt="GRN" style="object-fit: contain;" />
                    <h5 class="cocotxt">GRN</h5>
                </a>
            </div>
        </div>
        <br />
        <div class="row text-center">
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Inventory/StockAdjustment.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/images/dashboard_Icons/Stock_Adj.png" alt="Adjustment" style="object-fit: contain;" />
                    <h5 class="cocotxt">Stock Adjustment</h5>
                </a>
            </div> 
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Inventory/StoreStockTransfer.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/images/dashboard_Icons/StockTransfer.png" alt="Transfer" style="object-fit: contain;" />
                    <h5 class="cocotxt">Stock Transfer</h5>
                </a>
            </div>
    </div>

    <%--
    <div class="col-sm-6 col-sm-offset-4" style="margin-top: 47px;">
        <asp:Image ID="imgLogo" runat="server" ImageUrl="~../../../../wwwroot/images/HMIS_Icons/TibbITLogo_2.png"
            Style="height: 245px; width: 408px; border-width: 0px; opacity: 0.5; position: relative; z-index: -1;" />
    </div>--%>
</asp:Content>

