<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="LabSection.aspx.cs" Inherits="PMS.Modules.Dashboards.LabSection" %>

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

    <br /><br />

   <div class="container">
    <div class="row text-center" id="lab-shortcuts-container">
        <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-Sample-Collection">
            <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Lab/SampleCollectionFrom.aspx" style="width: 60%;">
                <img class="img-fluid" src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/blood-sample.png" alt="Sample Collection" style="object-fit: contain;" />
                <h5 class="cocotxt">Sample Collection</h5>
            </a>
        </div>
        <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-Acknowledgment">
            <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Lab/LaboratoryTest.aspx" style="width: 60%;">
                <img class="img-fluid" src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/blood-test.png" alt="Acknowledgment" style="object-fit: contain;" />
                <h5 class="cocotxt">Acknowledgment</h5>
            </a>
        </div>
        <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-Lab-Report">
            <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Lab/LabReportPreview.aspx" style="width: 60%;">
                <img class="img-fluid" src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/Lab2.png" alt="Lab Report" style="object-fit: contain;" />
                <h5 class="cocotxt">Lab Report</h5>
            </a>
        </div>
        <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-Review-Approval">
            <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Administrator/TestApproval.aspx" style="width: 60%;">
                <img class="img-fluid" src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/search.png" alt="Review Approval" style="object-fit: contain;" />
                <h5 class="cocotxt">Review/Approval</h5>
            </a>
        </div>
        <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-Approved-Tests">
            <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Administrator/TestApproval.aspx" style="width: 60%;">
                <img class="img-fluid" src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/qualitative-research.png" alt="Approved Tests" style="object-fit: contain;" />
                <h5 class="cocotxt">Approved Tests</h5>
            </a>
        </div>
    </div>
</div>

    <script type="text/javascript">
        $(document).ready(function () {
            loadLabSectionPermissions();
        });

        function loadLabSectionPermissions() {
            $.ajax({
                type: "POST",
                url: "LabSection.aspx/GetUserAllowedMenus",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var allowedMenus = response.d;
                    console.log("User Allowed Menus (Lab Section):", allowedMenus);

                    var shortcutToMenuMap = {
                        "shortcut-Sample-Collection":   "mnuAddNewSampleCollection",
                        "shortcut-Acknowledgment":      "mnushAddLabTest",
                        "shortcut-Lab-Report":          "mnuLabReportPreview",
                        "shortcut-Review-Approval":     "mnushTestApproval",
                        "shortcut-Approved-Tests":      "mnushTestApproval"
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
                    console.error("Failed to load permissions for Lab Section:", error);
                    console.error("Response:", xhr.responseText);
                    alert("Could not load permissions for Lab Section.");
                    Object.keys(shortcutToMenuMap).forEach(function (id) {
                        $("#" + id).hide();
                    });
                }
            });
        }
    </script>

</asp:Content>