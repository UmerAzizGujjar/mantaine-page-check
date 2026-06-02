<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AdminSection.aspx.cs" Inherits="PMS.Modules.Dashboards.AdminSection" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/css/Shortcuts.css" rel="stylesheet" />
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <!-- Loading Animation -->
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

    <!-- Main Content Container -->
    <div class="container">
        <div class="row text-center">
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-Add-User">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Accounts/Register.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/add-user.png" alt="Add User" style="object-fit: contain;" />
                    <h5 class="cocotxt">Add User</h5>
                </a>
            </div>

            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-Add-Role">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Accounts/Roles.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/newrole.png" alt="Add Role" style="object-fit: contain;" />
                    <h5 class="cocotxt">Add New Role</h5>
                </a>
            </div>

            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-Role-Assignment">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Accounts/RoleAssignment.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/coordinate.png" alt="Role Assignment" style="object-fit: contain;" />
                    <h5 class="cocotxt">Role Assignment</h5>
                </a>
            </div>

            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-Change-Password">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Accounts/ChangePassword.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/reset-password.png" alt="Change Password" style="object-fit: contain;" />
                    <h5 class="cocotxt">Change Password</h5>
                </a>
            </div>
        </div>
    </div>

    <!-- JavaScript for Permission Handling -->
    <script type="text/javascript">
        $(document).ready(function () {
            loadAdminSectionPermissions();
        });

        function loadAdminSectionPermissions() {
            $.ajax({
                type: "POST",
                url: "AdminSection.aspx/GetUserAllowedMenus",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var allowedMenus = response.d;
                    console.log("User Allowed Menus (Admin):", allowedMenus);

                    var shortcutToMenuMap = {
                        "shortcut-Add-User":           "mnushaddUsers",
                        "shortcut-Add-Role":           "mnushUserRole",
                        "shortcut-Role-Assignment":    "mnushRoleAssignment",
                        "shortcut-Change-Password":    "mnushChangePassword"
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
                    console.error("Failed to load permissions for Admin Section:", error);
                    console.error("Response:", xhr.responseText);
                    alert("Could not load permissions for Admin Section.");

                    // Hide all shortcuts on error
                    Object.keys(shortcutToMenuMap).forEach(function (id) {
                        $("#" + id).hide();
                    });
                }
            });
        }
    </script>

</asp:Content>