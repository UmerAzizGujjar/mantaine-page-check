<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ShortCuts.aspx.cs" Inherits="PMS.Modules.Dashboards.ShortCuts" %>

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
            <!-- Hardcoded shortcuts with IDs -->
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-Billing-Section">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Dashboards/BillingSection.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/cash-machine.png" alt="Billing" />
                    <h5 class="cocotxt">Billing</h5>
                </a>
            </div>

            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-Patient-Section">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Dashboards/PatientSection.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/medical.png" alt="Patients" style="object-fit: contain;" />
                    <h5 class="cocotxt">Patients</h5>
                </a>
            </div>

            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-Lab-Section">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Dashboards/LabSection.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/microscope.png" alt="Lab/Radiology" style="object-fit: contain;" />
                    <h5 class="cocotxt">Lab/Radiology</h5>
                </a>
            </div>

            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-Pharmacy-Section">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Dashboards/PharmacySection.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/pharmacy.png" alt="Pharmacy" style="object-fit: contain;" />
                    <h5 class="cocotxt">Pharmacy</h5>
                </a>
            </div>
        </div>
        <br />
        <div class="row text-center">
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-Inventory-Section">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Dashboards/InventorySection.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/shopping-cart.png" alt="Inventory" style="object-fit: contain;" />
                    <h5 class="cocotxt">Inventory</h5>
                </a>
            </div>

            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-Purchase-Section">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Dashboards/PurchaseSection.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/shopping-basket.png" alt="Purchase" style="object-fit: contain;" />
                    <h5 class="cocotxt">Purchase</h5>
                </a>
            </div>

            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-Account-Section">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Dashboards/AccountSection.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/budget.png" alt="Accounts" style="object-fit: contain;" />
                    <h5 class="cocotxt">Accounts</h5>
                </a>
            </div>

            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-Admin-Section">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Dashboards/AdminSection.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/administrator.png" alt="Administration" style="object-fit: contain;" />
                    <h5 class="cocotxt">Administration</h5>
                </a>
            </div>
        </div>
    </div>

    
 <script type="text/javascript">
     $(document).ready(function () {
         loadShortcutPermissions();
     });

     function loadShortcutPermissions() {
         $.ajax({
             type: "POST",
             url: "ShortCuts.aspx/GetUserAllowedMenus",
             data: "{}",
             contentType: "application/json; charset=utf-8",
             dataType: "json",
             success: function (response) {
                 var allowedMenus = response.d; // e.g., ["Patient Management", "Billing", "Lab"]
                 debugger;
                 console.log("User has access to menus:", allowedMenus);
                 debugger;
                 // 🔁 Map each shortcut to the ACTUAL menu name used in role permissions
                 var shortcutToMenuMap = {
                     
                     "shortcut-Billing-Section": "mnuBilling",               // Must match Menu_Description
                     "shortcut-Patient-Section": "mnushMaintenance",
                     "shortcut-Lab-Section": "mnuTransaction",
                     "shortcut-Pharmacy-Section": "ShmnuPharmacy",
                     "shortcut-Inventory-Section": "mnushInventory",
                     "shortcut-Purchase-Section": "mnutoaddPR",
                     "shortcut-Account-Section": "mnushAccounts",
                     "shortcut-Admin-Section": "mnushAdministration"
                 };
                 debugger;
                 // Loop through each shortcut and show/hide based on permission
                 Object.keys(shortcutToMenuMap).forEach(function (shortcutId) {
                     debugger;
                     var requiredMenuName = shortcutToMenuMap[shortcutId];

                     if (allowedMenus.includes(requiredMenuName)) {
                         debugger;
                         $("#" + shortcutId).show();
                     } else {
                         debugger;
                         $("#" + shortcutId).hide();
                         console.log("Hiding:", shortcutId, "→ Needs:", requiredMenuName);
                     }
                 });
             },
             error: function (xhr, status, error) {
                 console.error("Failed to load permissions:", error);
                 console.error("Response:", xhr.responseText);
                 alert("Could not load permissions. Contact admin.");
                 // Hide all shortcuts on error
                 Object.keys({
                     "shortcut-Billing-Section": "",
                     "shortcut-Patient-Section": "",
                     // ... all others
                 }).forEach(id => $("#" + id).hide());
             }
         });
     }
</script>
</asp:Content>