<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="BillingSection.aspx.cs" Inherits="PMS.Modules.Dashboards.BilligSection" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/Tibbit_theme/css/Shortcuts.css" rel="stylesheet" />
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <!-- Loading Spinner -->
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
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-Patient-Billing">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Billing/BillingProcess.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/cash-machine.png" alt="Billing" style="object-fit: contain;" />
                    <h5 class="cocotxt">Patient Billing</h5>
                </a>
            </div>
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-Add-Receipt">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Billing/Receipts.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/order.png" alt="Receipt" style="object-fit: contain;" />
                    <h5 class="cocotxt">Add Receipt</h5>
                </a>
            </div>
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-Add-Advance">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Billing/AddNewAdvance.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/money.png" alt="Add Advance" style="object-fit: contain;" />
                    <h5 class="cocotxt">Add Advance</h5>
                </a>
            </div>
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-Add-Refund">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Dashboards/PharmacySection.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/cashback.png" alt="Refund" style="object-fit: contain;" />
                    <h5 class="cocotxt">Add Refund</h5>
                </a>
            </div>
        </div>
        <!-- Second Row (if needed later, or keep for symmetry) -->
        <!-- You can add more shortcuts here if required -->
    </div>

    <script type="text/javascript">
        $(document).ready(function () {
            loadBillingSectionPermissions();
        });

        function loadBillingSectionPermissions() {
            $.ajax({
                type: "POST",
                url: "BillingSection.aspx/GetUserAllowedMenus",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var allowedMenus = response.d;
                    console.log("User Allowed Menus (Billing):", allowedMenus);

                    var shortcutToMenuMap = {
                        "shortcut-Patient-Billing":   "mnuBilling",
                        "shortcut-Add-Receipt":       "mnushReceipts",
                        "shortcut-Add-Advance":       "mnushAdvance",
                        "shortcut-Add-Refund":        "mnushRefund"
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
                    console.error("Failed to load permissions for Billing Section:", error);
                    console.error("Response:", xhr.responseText);
                    alert("Could not load permissions for Billing Section.");

                    // Optionally hide all shortcuts on error
                    Object.keys(shortcutToMenuMap).forEach(function (id) {
                        $("#" + id).hide();
                    });
                }
            });
        }
    </script>

</asp:Content>