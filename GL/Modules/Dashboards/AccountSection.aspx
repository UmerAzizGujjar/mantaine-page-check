<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AccountSection.aspx.cs" Inherits="PMS.Modules.Dashboards.AccountSection" %>
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
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Inventory/AddPurchaseInvoice.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/images/dashboard_Icons/PurchaseInvoice.png" alt="Purchase" style="object-fit: contain;" />
                    <h5 class="cocotxt">Purchase Invoice</h5>
                </a>
            </div>
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Inventory/AddPaymentInvoice.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/images/dashboard_Icons/paymentInvoice.png" alt="Payment" style="object-fit: contain;" />
                    <h5 class="cocotxt">Payment Invoice</h5>
                </a>
            </div>
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/GL/Voucher.aspx?VoucherType=CPV" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/images/dashboard_Icons/CPV.png" alt="CPV" style="object-fit: contain;" />
                    <h5 class="cocotxt">CPV</h5>
                </a>
            </div>
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/GL/Voucher.aspx?VoucherType=BPV" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/images/dashboard_Icons/BPV.png" alt="BPV" style="object-fit: contain;" />
                    <h5 class="cocotxt">BPV</h5>
                </a>
            </div>
        </div>
        <br />
        <div class="row text-center">
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/GL/Voucher.aspx?VoucherType=CRV" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/images/dashboard_Icons/CRV.png" alt="CRV" style="object-fit: contain;" />
                    <h5 class="cocotxt">CRV</h5>
                </a>
            </div>
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/GL/Voucher.aspx?VoucherType=BRV" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/images/dashboard_Icons/BRV.png" alt="BRV" style="object-fit: contain;" />
                   <h5 class="cocotxt">BRV</h5>
                </a>
            </div>
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Inventory/AddManualInvoice.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/images/dashboard_Icons/ManualInvoice.png" alt="Manual" style="object-fit: contain;" />
                    <h5 class="cocotxt">Manual Invoice</h5>
                </a>
            </div>
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Inventory/AdvancePayment.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/images/dashboard_Icons/advancePayment.png" alt="Advance" style="object-fit: contain;" />
                    <h5 class="cocotxt">Advance Payment</h5>
                </a>
            </div>
        </div>
                <br />
         <div class="row text-center">
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/GL/Voucher.aspx?VoucherType=JV" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/images/dashboard_Icons/JV.png" alt="JV" style="object-fit: contain;" />
                    <h5 class="cocotxt">JV</h5>
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

