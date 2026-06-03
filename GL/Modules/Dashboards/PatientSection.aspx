<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="PatientSection.aspx.cs" Inherits="PMS.PatientSection" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/Shortcuts.css" rel="stylesheet" />
        <style>

        .modern-loading-overlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(245, 245, 245, 0.95); 
    z-index: 9999;
    display: flex;
    align-items: center;
    justify-content: center;
    opacity: 0;
    animation: fadeIn 0.4s ease forwards;
}
.modern-table tbody td {
    white-space: normal !important;
    word-wrap: break-word; 
    word-break: break-word; 
    vertical-align: top; 
}
.loading-content {
    background: rgba(255, 255, 255, 0.85); 
    backdrop-filter: blur(20px);
    border: 1px solid rgba(239, 166, 62, 0.4); 
    padding: 40px;
    border-radius: 20px;
    text-align: center;
    color: #333;
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
    border: 3px solid rgba(239, 166, 62, 0.1); 
    border-top: 3px solid #EFA63E; 
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
        width: 95%;
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
    color: rgba(0, 0, 0, 0.7); 
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

.particle {
    position: absolute;
    width: 4px;
    height: 4px;
    background: rgba(239, 166, 62, 0.5);
    border-radius: 50%;
    animation: float 3s ease-in-out infinite;
}
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
    <script>
      
        document.addEventListener('DOMContentLoaded', function () {
            const searchInput = document.getElementById('searchInput');
            const searchResults = document.getElementById('searchResults');

            let searchTimeout;
            let currentXHR = null;
            let highlightedIndex = -1; // Track which result is highlighted

            searchInput.addEventListener('input', function (e) {
                const query = e.target.value.trim();
                clearTimeout(searchTimeout);

                if (currentXHR && currentXHR.readyState !== 4) {
                    currentXHR.abort();
                }

                searchTimeout = setTimeout(() => {
                    showLoading();
                    searchPatients(query);
                }, 300);
            });
            function hideResults() {
                searchResults.classList.remove('active');
            }
            // Handle keyboard navigation
            searchInput.addEventListener('keydown', function (e) {
                const items = searchResults.querySelectorAll('.result-item');
                if (items.length === 0) return;

                if (e.key === 'ArrowDown') {
                    e.preventDefault();
                    highlightedIndex = (highlightedIndex + 1) % items.length;
                    updateHighlight(items);
                } else if (e.key === 'ArrowUp') {
                    e.preventDefault();
                    highlightedIndex = (highlightedIndex - 1 + items.length) % items.length;
                    updateHighlight(items);
                } else if (e.key === 'Enter') {
                    e.preventDefault();
                    if (highlightedIndex >= 0) {
                        const selectedItem = items[highlightedIndex];
                        selectedItem.click(); // trigger selection
                    } else if (items.length > 0) {
                        items[0].click(); // default: first item
                    }
                    hideResults();
                }
            });

            function updateHighlight(items) {
                items.forEach(item => item.classList.remove('highlighted'));
                if (highlightedIndex >= 0) {
                    items[highlightedIndex].classList.add('highlighted');
                    items[highlightedIndex].scrollIntoView({ block: "nearest" });
                }
            }

            function searchPatients(searchValue) {
                currentXHR = $.ajax({
                    type: "POST",
                    url: "PatientSection.aspx/GetPatients",
                    data: JSON.stringify({ searchValue: searchValue }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        try {
                            const patients = JSON.parse(response.d);
                            if (patients.error) {
                                showError(patients.error);
                            } else {
                                highlightedIndex = -1; // reset highlight
                                showResults(patients, searchValue);
                            }
                        } catch (e) {
                            showError('Error parsing response: ' + e.message);
                        }
                    },
                    error: function (xhr, status, error) {
                        showError('Server error: ' + error);
                    }
                });
            }

            function showResults(patients, query) {
                if (!patients || patients.length === 0) {
                    searchResults.innerHTML = `
    <div class="no-results">
        No patients found for "${query}"
    </div>`;
                } else {
                    searchResults.innerHTML = patients.map(patient => {
                        const displayText = `${patient.PatientNo}-${patient.FullName}`;
                        return `
        <div class="result-item" onclick="selectPatient('${patient.RegID}')">
            <div>${highlightText(displayText, query)}</div>
        </div>`;
                    }).join('');
                }
                searchResults.classList.add('active');
            }

            function showLoading() {
                searchResults.innerHTML = `
<div class="no-results">
    <div style="display: flex; align-items: center; justify-content: center; gap: 10px;">
        <div class="loading-spinner"></div>
        Searching patients...
    </div>
</div>`;
                searchResults.classList.add('active');
            }

            function showError(errorMessage) {
                searchResults.innerHTML = `
<div class="no-results" style="color: #ff6b6b;">
    ⚠️ Error: ${errorMessage}
</div>`;
                searchResults.classList.add('active');
            }

            function highlightText(text, query) {
                if (!query) return text;
                const regex = new RegExp(`(${escapeRegExp(query)})`, 'gi');
                return text.replace(regex, '<strong style="background: rgba(102, 126, 234, 0.2); border-radius: 3px; padding: 0 2px;">$1</strong>');
            }

            function escapeRegExp(string) {
                return string.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
            }

            searchInput.addEventListener('focus', function () {
                if (this.value.trim().length >= 2) {
                    const query = this.value.trim();
                    showLoading();
                    searchPatients(query);
                }
            });
        });
        function selectPatient(RegID) {
            var url = "NewEMR.aspx?RegID=" + RegID;

             window.location.href = url;

           
        }
    </script>
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
            <div class="row">     <div class="col-lg-4"></div>    <div class="col-lg-4">
    <div class="search-container">
        <div class="search-input-wrapper">
            <input
                type="text"
                class="search-input"
                placeholder="Search for anything..."
                id="searchInput"
                autocomplete="off"
                style="height: 45px; width: 100% !important; padding: 16px 50px 16px 20px !important; border: 1.5px solid #ccc !important; border-radius: 25px !important; background: rgba(255, 255, 255, 0.1) !important; backdrop-filter: blur(10px) !important; color: black !important; font-size: 16px !important; box-shadow: none !important" />
            <div class="search-icon">🔍</div>
        </div>
        <div class="search-results" id="searchResults"></div>
    </div>
</div></div>
    <div class="container">
        
         
    <div class="row text-center" id="patient-shortcuts-container">
        <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-Reg-Patient">
            <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/PatientManagement/RegisterPatient.aspx" style="width: 95%;">
                <img class="img-fluid" src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/add.png" alt="Patient" style="object-fit: contain;" />
                <h3 class="cocotxt1">Register Patient</h3>
                <h5 style="color:white">Enter Patient Details</h5>
            </a>
        </div>
        <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-Appointment">
            <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Appointment/Appointment.aspx" style="width: 95%;">
                <img class="img-fluid" src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/medical-appointment.png" alt="Appointment" style="object-fit: contain;" />
                <h3 class="cocotxt1">Appointment</h3><h5 style="color:white">Enter Patient Details</h5>
            </a>
        </div>
        <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-OPD">
            <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/PatientManagement/OPD.aspx" style="width: 95%;">
                <img class="img-fluid" src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/opd.png" alt="OPD" style="object-fit: contain;" />
                <h3 class="cocotxt1">OPD</h3><h5 style="color:white">Enter Patient Details</h5>
            </a>
        </div>
        <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-OPD-Prescription">
            <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/PatientManagement/NewOutPatient.aspx" style="width: 95%;">
                <img class="img-fluid" src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/medical-record.png" alt="Prescription" style="object-fit: contain;" />
                <h3 class="cocotxt1">OPD Prescription</h3><h5 style="color:white">Enter Patient Details</h5>
            </a>
        </div>

        <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-Emergency">
            <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/PatientManagement/EmergencyCase.aspx" style="width: 95%;">
                <img class="img-fluid" src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/first-aid-box.png" alt="Emergency" style="object-fit: contain;" />
                <h3 class="cocotxt1">Emergency</h3><h5 style="color:white">Enter Patient Details</h5>
            </a>
        </div>
        <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-IPD-Admission">
            <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/PatientManagement/InPatientsAdmission.aspx" style="width: 95%;">
                <img class="img-fluid" src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/inpatienta.png" alt="Purchase" style="object-fit: contain;" />
                <h3 class="cocotxt1">IPD Admission</h3><h5 style="color:white">Enter Patient Details</h5>
            </a>
        </div>
        <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-Admitted-Patient">
            <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/PatientManagement/InPatientsCase.aspx" style="width: 95%;">
                <img class="img-fluid" src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/inpatient.png" alt="Accounts" style="object-fit: contain;" />
                <h3 class="cocotxt1">Admitted Patient</h3><h5 style="color:white">Enter Patient Details</h5>
            </a>
        </div>
        <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4" id="shortcut-Nursing">
            <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/PatientManagement/InPatientMonitoring.aspx" style="width: 95%;">
                <img class="img-fluid" src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/nurse.png" alt="Administration" style="object-fit: contain;" />
                <h3  class="cocotxt1">Nursing</h3><h5 style="color:white">Enter Patient Details</h5>
            </a>
        </div>
    </div>
</div>

    <script type="text/javascript">
        $(document).ready(function () {
            if (typeof $ === 'undefined') {
                console.error("jQuery not loaded!");
                return;
            }

            $("#loading").show();

            loadPatientSectionPermissions();
        });
        function showLoading() {
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
                }, 500); 
            }
        }
        function loadPatientSectionPermissions() {
            $.ajax({
                type: "POST",
                url: "PatientSection.aspx/GetUserAllowedMenus",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    showLoading();

                    var allowedMenus = response.d || [];
                    console.log("✅ Allowed Menus from Server:", allowedMenus);

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
                    hideLoading();
                },
                error: function (xhr, status, error) {
                    $("#loading").fadeOut();
                    console.error("❌ AJAX Error:", error);
                    console.error("Response Text:", xhr.responseText);

                    alert("Failed to load permissions. Contact admin.");

                    $(".shortcut").parent().hide();
                }
            });
        }
    </script>
</asp:Content>