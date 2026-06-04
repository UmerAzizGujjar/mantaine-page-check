<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="PharmacySection.aspx.cs" Inherits="PMS.Modules.Dashboards.PharmacySection" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/lib/sweetalert/Shortcuts.css" rel="stylesheet" />
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <br /><br />
    <div class="container">
    <div class="row text-center" id="pharmacy-shortcuts-container">
        <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-Pharmacy-Sale">
            <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Billing/IssueMedicine.aspx" style="width: 60%;">
                <img class="img-fluid" src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/pharmacy.png" alt="Sale" style="object-fit: contain;" />
                <h5 class="cocotxt">Pharmacy Sale</h5>
            </a>
        </div>

        <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-Issue-Medicine">
            <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Billing/IssueMedicineList.aspx" style="width: 60%;">
                <img class="img-fluid" src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/diagnosis.png" alt="Medicnine" style="object-fit: contain;" />
                <h5 class="cocotxt">Issue Medicine</h5>
            </a>
        </div>

        <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-Pharmacy-User">
            <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Administrator/Pharmacy_Users.aspx" style="width: 60%;">
                <img class="img-fluid" src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/pharmacist.png" alt="User" style="object-fit: contain;" />
                <h5 class="cocotxt">Pharmacy User</h5>
            </a>
        </div>

        <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-Sale-Return">
            <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Billing/IssueMedicine.aspx" style="width: 60%;">
                <img class="img-fluid" src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/sales.png" alt="Return" style="object-fit: contain;" />
                <h5 class="cocotxt">Sale Return</h5>
            </a>
        </div>
        <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-Sale-Report">
            <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Billing/IssueMedicineList.aspx" style="width: 60%;">
                <img class="img-fluid" src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/Report.png" alt="Report" style="object-fit: contain;" />
                <h5 class="cocotxt">Sale Report</h5>
            </a>
        </div>
    </div>
</div>

    <script type="text/javascript">
        $(document).ready(function () {
            loadPharmacySectionPermissions();
        });

        function loadPharmacySectionPermissions() {
            $.ajax({
                type: "POST",
                url: "PharmacySection.aspx/GetUserAllowedMenus",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var allowedMenus = response.d;

                    console.log("PharmacySection: Allowed Menus =", allowedMenus);

                    // 🔁 Map shortcut ID to actual Menu_Name from DB
                    var shortcutToMenuMap = {
                        "shortcut-Pharmacy-Sale":       "mnuissuemdcn",
                        "shortcut-Issue-Medicine":      "mnuissuemdcnList",
                        "shortcut-Pharmacy-User":       "mnunewuserPharma",
                        "shortcut-Sale-Return":         "mnuissuemdcn",
                        "shortcut-Sale-Report":         "mnuissuemdcnList"
                    };

                    // Show/hide based on permissions
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
                    console.error("Failed to load Pharmacy permissions:", error);
                    // Optionally hide all on error
                    Object.keys(shortcutToMenuMap).forEach(id => $("#" + id).hide());
                }
            });
        }
    </script>
</asp:Content>