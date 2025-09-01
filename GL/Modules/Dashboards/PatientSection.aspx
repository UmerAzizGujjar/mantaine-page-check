<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="PatientSection.aspx.cs" Inherits="PMS.PatientSection" %>

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
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-Reg-Patient">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/PatientManagement/RegisterPatient.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/add.png" alt="Patient" style="object-fit: contain;" />
                    <h5 class="cocotxt">Reg Patient</h5>
                </a>
            </div>
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-Appointment">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Appointment/Appointment.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/medical-appointment.png" alt="Appointment" style="object-fit: contain;" />
                    <h5 class="cocotxt">Appointment</h5>
                </a>
            </div>
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-OPD">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/PatientManagement/OPD.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/opd.png" alt="OPD" style="object-fit: contain;" />
                    <h5 class="cocotxt">OPD</h5>
                </a>
            </div>
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-OPD-Prescription">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/PatientManagement/NewOutPatient.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/medical-record.png" alt="Prescription" style="object-fit: contain;" />
                    <h5 class="cocotxt">OPD Prescription</h5>
                </a>
            </div>
        </div>
        <br />
        <div class="row text-center">
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-Emergency">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/PatientManagement/EmergencyCase.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/first-aid-box.png" alt="Emergency" style="object-fit: contain;" />
                    <h5 class="cocotxt">Emergency</h5>
                </a>
            </div>
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-IPD-Admission">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/PatientManagement/InPatientsAdmission.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/inpatienta.png" alt="Purchase" style="object-fit: contain;" />
                    <h5 class="cocotxt">IPD Admission</h5>
                </a>
            </div>
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-Admitted-Patient">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/PatientManagement/InPatientsCase.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/inpatient.png" alt="Accounts" style="object-fit: contain;" />
                    <h5 class="cocotxt">Admitted Patient</h5>
                </a>
            </div>
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-Nursing">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/PatientManagement/InPatientMonitoring.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/nurse.png" alt="Administration" style="object-fit: contain;" />
                    <h5 class="cocotxt">Nursing</h5>
                </a>
            </div>
        </div>
    </div>

    <script type="text/javascript">
        $(document).ready(function () {
            // Ensure jQuery is loaded
            if (typeof $ === 'undefined') {
                console.error("jQuery not loaded!");
                return;
            }

            // Show loading spinner
            $("#loading").show();

            loadPatientSectionPermissions();
        });

        function loadPatientSectionPermissions() {
            $.ajax({
                type: "POST",
                url: "PatientSection.aspx/GetUserAllowedMenus",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    // Hide spinner
                    $("#loading").fadeOut();

                    var allowedMenus = response.d || [];
                    console.log("✅ Allowed Menus from Server:", allowedMenus);

                    // 🔑 Map shortcut div IDs to exact Menu_Name from DB
                    var shortcutToMenuMap = {
                        "shortcut-Reg-Patient": "mnurgPatient",
                        "shortcut-Appointment": "mnushAppointment",
                        "shortcut-OPD": "mnushopd",
                        "shortcut-OPD-Prescription": "mnuoutshpatient",
                        "shortcut-Emergency": "mnuEmergencyCase",
                        "shortcut-IPD-Admission": "mnuInPatientsAdmissionDetail",
                        "shortcut-Admitted-Patient": "mnuInPatientCase",
                        "shortcut-Nursing": "mnushInPatientCase"
                    };

                    // Apply visibility
                    Object.keys(shortcutToMenuMap).forEach(function (shortcutId) {
                        var requiredMenu = shortcutToMenuMap[shortcutId];

                        if (allowedMenus.includes(requiredMenu)) {
                            $("#" + shortcutId).show();
                            console.log("✅ SHOWN:", shortcutId, "(needs:", requiredMenu + ")");
                        } else {
                            $("#" + shortcutId).hide();
                            console.log("❌ HIDDEN:", shortcutId, "(needs:", requiredMenu + ")");
                        }
                    });
                },
                error: function (xhr, status, error) {
                    $("#loading").fadeOut();
                    console.error("❌ AJAX Error:", error);
                    console.error("Response Text:", xhr.responseText);

                    alert("Failed to load permissions. Contact admin.");

                    // Hide all shortcuts on error
                    $(".shortcut").parent().hide();
                }
            });
        }
    </script>
</asp:Content>