<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="InventorySection.aspx.cs" Inherits="PMS.Modules.Dashboards.InventorySection" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/Tibbit_theme/css/Shortcuts.css" rel="stylesheet" />
        <style>
        .modern-loading-overlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(245, 245, 245, 0.95); /* Whitish semi-transparent */
    z-index: 9999;
    display: flex;
    align-items: center;
    justify-content: center;
    opacity: 0;
    animation: fadeIn 0.4s ease forwards;
}
.modern-table tbody td {
    white-space: normal !important; /* allow text wrapping */
    word-wrap: break-word; /* wrap long words */
    word-break: break-word; /* force breaking if needed */
    vertical-align: top; /* keep text aligned to top */
}
.loading-content {
    background: rgba(255, 255, 255, 0.85); /* Solid whitish */
    backdrop-filter: blur(20px);
    border: 1px solid rgba(239, 166, 62, 0.4); /* Subtle orange border */
    padding: 40px;
    border-radius: 20px;
    text-align: center;
    color: #333; /* Dark text for contrast */
    box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15);
    transform: scale(0.8);
    animation: scaleIn 0.4s ease 0.2s forwards;
    min-width: 200px;
}

.loading-spinner {
    width: 60px;
    height: 60px;
    margin: 0 auto 20px;
    position: relative;
}

.spinner-ring {
    position: absolute;
    width: 100%;
    height: 100%;
    border: 3px solid rgba(239, 166, 62, 0.1); /* Very subtle orange */
    border-top: 3px solid #EFA63E; /* Bright orange */
    border-radius: 50%;
    animation: spin 1s linear infinite;
}

    .spinner-ring:nth-child(2) {
        border-top-color: rgba(239, 166, 62, 0.7);
        animation-duration: 1.5s;
        animation-direction: reverse;
        width: 80%;
        height: 80%;
        top: 10%;
        left: 10%;
    }

    .spinner-ring:nth-child(3) {
        border-top-color: rgba(239, 166, 62, 0.4);
        animation-duration: 2s;
        width: 60%;
        height: 60%;
        top: 20%;
        left: 20%;
    }

.loading-text {
    font-size: 18px;
    font-weight: 600;
    margin-bottom: 10px;
    background: linear-gradient(45deg, #EFA63E, #d18d2f, #EFA63E);
    background-size: 200% 200%;
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
    animation: gradientShift 3s ease infinite;
}

.loading-subtext {
    font-size: 14px;
    color: rgba(0, 0, 0, 0.7); /* Darker subtext */
    margin-bottom: 20px;
}

.progress-bar {
    width: 100%;
    height: 4px;
    background: rgba(0, 0, 0, 0.1);
    border-radius: 2px;
    overflow: hidden;
    position: relative;
}

.progress-fill {
    height: 100%;
    background: linear-gradient(90deg, transparent, #EFA63E, transparent);
    border-radius: 2px;
    animation: progressMove 2s ease-in-out infinite;
}

/* Floating particles - adjusted for light background */
.particle {
    position: absolute;
    width: 4px;
    height: 4px;
    background: rgba(239, 166, 62, 0.5);
    border-radius: 50%;
    animation: float 3s ease-in-out infinite;
}

    /* Keep original particle positions */
    .particle:nth-child(1) {
        top: 20%;
        left: 20%;
        animation-delay: 0s;
    }

    .particle:nth-child(2) {
        top: 80%;
        left: 80%;
        animation-delay: 1s;
    }

    .particle:nth-child(3) {
        top: 60%;
        left: 10%;
        animation-delay: 2s;
    }

    .particle:nth-child(4) {
        top: 30%;
        left: 90%;
        animation-delay: 1.5s;
    }

/* Animations remain unchanged */
@keyframes fadeIn {
    to {
        opacity: 1;
    }
}

@keyframes scaleIn {
    to {
        transform: scale(1);
    }
}

@keyframes spin {
    to {
        transform: rotate(360deg);
    }
}

@keyframes gradientShift {
    0%, 100% {
        background-position: 0% 50%;
    }

    50% {
        background-position: 100% 50%;
    }
}

@keyframes progressMove {
    0% {
        transform: translateX(-100%);
    }

    100% {
        transform: translateX(200%);
    }
}

@keyframes float {
    0%, 100% {
        transform: translateY(0px) rotate(0deg);
        opacity: 0.6;
    }

    50% {
        transform: translateY(-20px) rotate(180deg);
        opacity: 1;
    }
}

.fade-out {
    animation: fadeOut 0.4s ease forwards;
}

@keyframes fadeOut {
    to {
        opacity: 0;
        transform: scale(0.95);
    }
}

    </style>
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
        function showLoading() {
            // Add your loading indicator here
            $('body').append(`
    <div class="modern-loading-overlay">
        <div class="loading-content">
            <div class="loading-spinner">
                <div class="spinner-ring"></div>
                <div class="spinner-ring"></div>
                <div class="spinner-ring"></div>
            </div>
            <div class="loading-text">Loading</div>
            <div class="loading-subtext">Please wait while we prepare your content...</div>
            <div class="progress-bar">
                <div class="progress-fill"></div>
            </div>
        </div>
        <div class="particle"></div>
        <div class="particle"></div>
        <div class="particle"></div>
        <div class="particle"></div>
    </div>
`);
        }
        function hideLoading() {
            const overlay = document.querySelector('.modern-loading-overlay');
            if (overlay) {
                overlay.classList.add('fade-out');
                setTimeout(() => {
                    if (overlay && overlay.parentNode) {
                        overlay.parentNode.removeChild(overlay);
                    }
                }, 500); // Match this duration with your CSS transition time
            }
        }
        function loadInventorySectionPermissions() {
            $.ajax({
                type: "POST",
                url: "InventorySection.aspx/GetUserAllowedMenus",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    showLoading();
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
                    hideLoading();
                },
                error: function (xhr, status, error) {
                    console.error("Failed to load Inventory permissions:", error);
                 
                    Object.keys(shortcutToMenuMap).forEach(id => $("#" + id).hide());
                }
            });
        }
    </script>
</asp:Content>