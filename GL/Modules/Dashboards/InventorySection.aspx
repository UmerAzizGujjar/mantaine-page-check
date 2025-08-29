<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="InventorySection.aspx.cs" Inherits="PMS.Modules.Dashboards.InventorySection" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/Tibbit_theme/css/Shortcuts.css" rel="stylesheet" />
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <br />
    <div class="container">
        <div class="row text-center">
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-GIR">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Inventory/GoodsIssuanceRequest.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/GIR2.png" alt="GIR" style="object-fit: contain;" />
                    <h5 class="cocotxt">GIR</h5>
                </a>
            </div>

            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-GIN">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Inventory/GoodsIssuanceNote.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/Sin.png" alt="GIN" style="object-fit: contain;" />
                    <h5 class="cocotxt">GIN</h5>
                </a>
            </div>

            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-IGP">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Inventory/InversionGatePass.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/border.png" alt="IGP" style="object-fit: contain;" />
                    <h5 class="cocotxt">IGP</h5>
                </a>
            </div>

            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-GRN">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Inventory/GRN.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/receiver.png" alt="GRN" style="object-fit: contain;" />
                    <h5 class="cocotxt">GRN</h5>
                </a>
            </div>
        </div>
        <br />
        <div class="row text-center">
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-Stock-Adjustment">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Inventory/StockAdjustment.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/inventory-management.png" alt="Adjustment" style="object-fit: contain;" />
                    <h5 class="cocotxt">Stock Adjustment</h5>
                </a>
            </div> 

            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-Stock-Transfer">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Inventory/StoreStockTransfer.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/stocktrans.png" alt="Transfer" style="object-fit: contain;" />
                    <h5 class="cocotxt">Stock Transfer</h5>
                </a>
            </div>
        </div>
    </div>
    <script type="text/javascript">
        $(document).ready(function () {
            loadInventorySectionPermissions();
        });

        function loadInventorySectionPermissions() {
            $.ajax({
                type: "POST",
                url: "InventorySection.aspx/GetUserAllowedMenus",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var allowedMenus = response.d;

                    console.log("InventorySection: Allowed Menus =", allowedMenus);

                    var shortcutToMenuMap = {
                        "shortcut-GIR":                 "MnuShAddGIR",
                        "shortcut-GIN":                 "mnuashddGIN",
                        "shortcut-IGP":                 "mnushIgp",
                        "shortcut-GRN":                 "mnushGrn",
                        "shortcut-Stock-Adjustment":    "mnushortaddstcadj",
                        "shortcut-Stock-Transfer":      "mnushStoreStockTransfer"
                    };
                    Object.keys(shortcutToMenuMap).forEach(function (shortcutId) {
                        var requiredMenu = shortcutToMenuMap[shortcutId];

                        if (allowedMenus.includes(requiredMenu)) {
                            $("#" + shortcutId).show();
                        } else {
                            $("#" + shortcutId).hide();
                        }
                    });
                },
                error: function (xhr, status, error) {
                    console.error("Failed to load Inventory permissions:", error);
                 
                    Object.keys(shortcutToMenuMap).forEach(id => $("#" + id).hide());
                }
            });
        }
    </script>
</asp:Content>