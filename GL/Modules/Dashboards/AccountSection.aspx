<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AccountSection.aspx.cs" Inherits="PMS.Modules.Dashboards.AccountSection" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/lib/sweetalert/Shortcuts.css" rel="stylesheet" />
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
    <div class="row text-center" id="purchase-vouchers-container">
        <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-Purchase-Invoice">
            <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Inventory/AddPurchaseInvoice.aspx" style="width: 60%;">
                <img class="img-fluid" src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/inv_pur.png" alt="Purchase" style="object-fit: contain;" />
                <h5 class="cocotxt">Purchase Invoice</h5>
            </a>
        </div>
        <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-Payment-Invoice">
            <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Inventory/AddPaymentInvoice.aspx" style="width: 60%;">
                <img class="img-fluid" src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/pay_inv.png" alt="Payment" style="object-fit: contain;" />
                <h5 class="cocotxt">Payment Invoice</h5>
            </a>
        </div>
        <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-CPV">
            <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/GL/Voucher.aspx?VoucherType=CPV" style="width: 60%;">
                <img class="img-fluid" src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/CPV_V.png" alt="CPV" style="object-fit: contain;" />
                <h5 class="cocotxt">CPV</h5>
            </a>
        </div>
        <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-BPV">
            <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/GL/Voucher.aspx?VoucherType=BPV" style="width: 60%;">
                <img class="img-fluid" src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/bpv_v.png" alt="BPV" style="object-fit: contain;" />
                <h5 class="cocotxt">BPV</h5>
            </a>
        </div>
        <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-CRV">
            <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/GL/Voucher.aspx?VoucherType=CRV" style="width: 60%;">
                <img class="img-fluid" src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/CRV_v.png" alt="CRV" style="object-fit: contain;" />
                <h5 class="cocotxt">CRV</h5>
            </a>
        </div>
        <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-BRV">
            <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/GL/Voucher.aspx?VoucherType=BRV" style="width: 60%;">
                <img class="img-fluid" src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/bank-note.png" alt="BRV" style="object-fit: contain;" />
                <h5 class="cocotxt">BRV</h5>
            </a>
        </div>
        <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-Manual-Invoice">
            <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Inventory/AddManualInvoice.aspx" style="width: 60%;">
                <img class="img-fluid" src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/manual_inv.png" alt="Manual" style="object-fit: contain;" />
                <h5 class="cocotxt">Manual Invoice</h5>
            </a>
        </div>
        <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-Advance-Payment">
            <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Inventory/AdvancePayment.aspx" style="width: 60%;">
                <img class="img-fluid" src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/payment-method.png" alt="Advance" style="object-fit: contain;" />
                <h5 class="cocotxt">Advance Payment</h5>
            </a>
        </div>
        <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-JV">
            <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/GL/Voucher.aspx?VoucherType=JV" style="width: 60%;">
                <img class="img-fluid" src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/jv_v.png" alt="JV" style="object-fit: contain;" />
                <h5 class="cocotxt">JV</h5>
            </a>
        </div>
    </div>
</div>

    <!-- jQuery and Script -->
    <script type="text/javascript">
        $(document).ready(function () {
            loadAccountSectionPermissions();
        });

        function loadAccountSectionPermissions() {
            $.ajax({
                type: "POST",
                url: "AccountSection.aspx/GetUserAllowedMenus",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var allowedMenus = response.d;
                    console.log("User Allowed Menus (Account):", allowedMenus);

                    var shortcutToMenuMap = {
                        "shortcut-Purchase-Invoice":     "mnushPurchase",
                        "shortcut-Payment-Invoice":       "mnushaddPayment",
                        "shortcut-CPV":                   "mnushVoucherCPV",
                        "shortcut-BPV":                   "mnushVoucherBPV",
                        "shortcut-CRV":                   "mnushVoucherCRV",
                        "shortcut-BRV":                   "mnushVoucherBRV",
                        "shortcut-Manual-Invoice":        "mnushManualInvoice",
                        "shortcut-Advance-Payment":       "mnushAddadv",
                        "shortcut-JV":                    "mnushVoucherJV"
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
                    console.error("Failed to load permissions for Account Section:", error);
                    console.error("Response:", xhr.responseText);
                    alert("Could not load permissions for Account Section.");

                    Object.keys(shortcutToMenuMap).forEach(function (id) {
                        $("#" + id).hide();
                    });
                }
            });
        }
    </script>

</asp:Content>