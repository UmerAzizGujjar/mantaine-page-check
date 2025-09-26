<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="PurchaseSection.aspx.cs" Inherits="PMS.Modules.Dashboards.PurchaseSection" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/Tibbit_theme/css/Shortcuts.css" rel="stylesheet" />
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
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-Purchase-Request">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/AP/PurchaseRequistion.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/request.png" alt="Request" style="object-fit: contain;" />
                    <h5 class="cocotxt">Purchase Request</h5>
                </a>
            </div>

            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-Purchase-Order">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/AP/PurchaseOrder.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/compliant.png" alt="Order" style="object-fit: contain;" />
                    <h5 class="cocotxt">Purchase Order</h5>
                </a>
            </div>

            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-Quotation-Request">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/AP/RequestForQuotation.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/quotations.png" alt="Quotation" style="object-fit: contain;" />
                    <h5 class="cocotxt">Quotation Request</h5>
                </a>
            </div>

            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-Comparative-Statement">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/AP/ComparativeStatementVendor.aspx" style="width: 65%;">
                    <img class="img-fluid" src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/CsState.png" alt="Statement" style="object-fit: contain;" />
                    <h5 class="cocotxt">Compartv Statement</h5>
                </a>
            </div>
        </div>
    </div>

    <script type="text/javascript">
        $(document).ready(function () {
            loadPurchaseSectionPermissions();
        });

        function loadPurchaseSectionPermissions() {
            $.ajax({
                type: "POST",
                url: "PurchaseSection.aspx/GetUserAllowedMenus",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var allowedMenus = response.d;
                    console.log("User Allowed Menus (Purchase):", allowedMenus);

                    var shortcutToMenuMap = {
                        "shortcut-Purchase-Request":        "mnushpurchaserequisition",
                        "shortcut-Purchase-Order":          "mnushPurchaseOrderNew",
                        "shortcut-Quotation-Request":       "menushRFQ",
                        "shortcut-Comparative-Statement":   "menushComparitiveStatement"
                    };

                    Object.keys(shortcutToMenuMap).forEach(function (shortcutId) {
                        var requiredMenu = shortcutToMenuMap[shortcutId];

                        if (allowedMenus.includes(requiredMenu)) {
                            $("#" + shortcutId).show();
                        } else {
                            $("#" + shortcutId).hide();
                            console.log("HIDDEN:", shortcutId, "→ Needs:", requiredMenu);
                        }
                    });
                },
                error: function (xhr, status, error) {
                    console.error("Failed to load permissions for Purchase Section:", error);
                    console.error("Response:", xhr.responseText);
                    alert("Could not load permissions for Purchase Section.");

                    Object.keys(shortcutToMenuMap).forEach(function (id) {
                        $("#" + id).hide();
                    });
                }
            });
        }
    </script>

</asp:Content>