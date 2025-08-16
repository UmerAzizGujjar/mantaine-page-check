<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="NewEMR.aspx.cs" Inherits="PMS.Modules.Dashboards.NewEMR" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style id="sidebar">
        .retractIcon {
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 8px;
            border-radius: 50%;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .sidebarToggleIcon {
            width: 24px;
            height: 24px;
            transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
        }

        .retractIcon:hover {
            background-color: rgba(0, 0, 0, 0.1);
            transform: scale(1.1);
        }

            .retractIcon:hover img {
                filter: brightness(0.8) contrast(1.2);
                transform: rotate(10deg);
            }

        .retractIcon:active {
            transform: scale(0.95);
        }

        #retract {
            transition: all 0.5s ease;
            overflow: hidden;
        }

            #retract.minimized {
                width: 100px !important;
            }

                #retract.minimized span {
                    display: none;
                }

        .sidebarr {
            border-right: 1px solid #dee2e6;
            padding: 0;
        }

        .menu-item {
            cursor: pointer;
            padding: 15px 20px;
            border-bottom: 1px solid #dee2e6;
            transition: background-color 0.3s;
            font-size: 15px
        }



            .menu-item.selected {
                background-color: #EFA63E;
                color: black !important;
            }

                .menu-item.selected img {
                    filter: brightness(0);
                }



        .sidebarIcon {
            width: 30px;
            margin-right: 25px;
        }


        .menu-item:hover {
            background-color: #EFA63E;
            color: black !important;
        }

        .menu-item img {
            filter: sepia(100%) saturate(450%) hue-rotate(330deg) brightness(1);
            transition: all 0.3s ease;
        }

        .menu-item:hover img {
            filter: brightness(0) !important; /* Force black, no blur */
            backface-visibility: hidden;
            transform-style: preserve-3d;
            transition: filter 0.3s ease, transform 0.3s ease; /* Control transitions */
        }

        .menu-title {
            display: flex;
            justify-content: start;
            align-items: center;
        }
    </style>
    <style id="MiscCSS">
        .row-details {
    display: flex;
    
}

    .row-details p {
        margin: 0;
        flex: 1; /* Adjust widths equally if necessary */
         /* Optional: centers text within each item */
    }
        .card3 {
    padding: 20px 0px;
    height:200px !important;
}
        
.profile-info {
    display: flex;
    gap: 40px; /* Adds spacing between image and text */
    align-items: flex-start;
}

.profile-img {
    width: 150px;
    height: 150px;
    object-fit: cover;
    border-radius: 15%; 
   
}

.profile-details {
    line-height: 1.8; /* Adjusts line spacing for text */
}

    .profile-details p {
        margin-bottom: 2px; /* Adds space between rows */
    }

.profile-name {
    display: block;
    font-size: 1.6em;
    font-weight: bold;
    margin-top: 5px;
}
.icons {
    height: 30px;
    width: 30px;
    margin-right:15px;
}
.badge {
    font-size: 1.2em;
    color: white;
    background-color: #EFA63E !important;
    padding: 5px 10px;
    border-radius: 5px;
    height: 26px;
}
.appointmentcard {
    margin-top:40px;
    background-color: #fff;
    border: 1px solid rgba(0, 0, 0, 0.1); /* slightly darker border */
    border-radius: 8px; /* rounded corners */
    box-shadow: 0 6px 18px rgba(0, 0, 0, 0.15); /* more shadow and spread */
    padding: 20px;
    margin-bottom: 20px;
}
.statusCards {
    background-color: #fff;
    border: 1px solid rgba(0, 0, 0, 0.1);
    border-radius: 8px;
    box-shadow: 0 6px 20px rgba(0, 0, 0, 0.25); /* darker + more spread */
    padding: 20px;
    margin-bottom: 15px;
}
.appointment-info {
    display: flex;
    align-items: center;
    margin-bottom: 10px;
}    .labelcolor {
    color: #EFA63E !important;
}.card {
    padding: 20px;
    border: 2px solid #ddd;
    border-radius: 8px;
    background-color: #fff;
    height: 400px !important;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}
        .page-header, #ctl00_sidebar {
            display: none !important;
        }

        .container-fluid {
            padding-left: 0px !important;
            padding-right: 0px !important;
            overflow-x: hidden;
            overflow-y: auto;
        }

        #tibbitFooter {
            display: none !important
        }

        label, span, .table > tbody > tr > td, select {
            font-weight: normal !important
        }

        .main-content {
            padding-bottom: 0px !important
        }

        .mybutton {
            font-size: 19px !important;
            width: fit-content !important;
            background-color: #f0f1f3;
            padding: 3px 12px;
            border-radius: 8px;
            margin: 0;
            color: #EFA63E !important;
            font-weight: bold !important;
            font-size: 16px;
            transition: all 0.3s ease;
            margin-bottom: 5px;
            border: 0px !important;
            margin-left: 5px;
            margin-right: 5px;
        }
    </style>
    <style id="searchBar">
        .search-container {
            position: relative;
            width: 100%;
        }

        .search-input-wrapper {
            position: relative;
            display: flex;
            align-items: center;
        }

        .search-input {
            width: 100% !important;
            padding: 16px 50px 16px 20px !important;
            border: 2px solid rgba(255, 255, 255, 0.3) !important;
            border-radius: 25px !important;
            background: rgba(255, 255, 255, 0.1) !important;
            backdrop-filter: blur(10px) !important;
            color: white !important;
            font-size: 16px !important;
            outline: none !important;
            transition: all 0.3s ease !important;
            placeholder-color: rgba(255, 255, 255, 0.7) !important;
        }

            .search-input::placeholder {
                color: rgba(255, 255, 255, 0.7);
            }

            .search-input:focus {
                border-color: rgba(255, 255, 255, 0.6);
                background: rgba(255, 255, 255, 0.15);
                box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
            }

        .search-icon {
            position: absolute;
            right: 17px;
            margin-bottom: 5px;
            color: rgba(255, 255, 255, 0.7);
            font-size: 18px;
            pointer-events: none;
            transition: color 0.3s ease;
        }

        .search-input:focus + .search-icon {
            color: rgba(255, 255, 255, 0.9);
        }

        .search-results {
            position: absolute;
            top: 100%;
            left: 0;
            right: 0;
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(15px);
            border: 1px solid rgba(255, 255, 255, 0.2);
            border-radius: 15px;
            margin-top: 8px;
            opacity: 0;
            visibility: hidden;
            transform: translateY(-10px);
            transition: all 0.3s ease;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
            z-index: 1000;
        }

            .search-results.active {
                opacity: 1;
                visibility: visible;
                transform: translateY(0);
            }

        .result-item {
    padding: 12px 20px;
    color: #333;  
    cursor: pointer;
    transition: all 0.2s ease;
    border-bottom: 1px solid rgba(0, 0, 0, 0.05);  
    font-size: 15px;
     display: block;  
    line-height: 1.4;
    font-weight:normal
}

 
 
 

            .result-item:last-child {
                border-bottom: none;
                border-radius: 0 0 15px 15px;
            }

            .result-item:first-child {
                border-radius: 15px 15px 0 0;
            }

            .result-item:hover {
                background: rgba(255, 255, 255, 0.1);
            }

        .result-title {
            font-weight: 600;
            margin-bottom: 5px;
            font-size: 14px;
        }

        .result-description {
            font-size: 12px;
            opacity: 0.8;
            line-height: 1.4;
        }

        .no-results {
            padding: 20px;
            text-align: center;
            color: black;
            font-style: italic;
        }

        /* Responsive design */
        @media (max-width: 768px) {
            .col-lg-4 {
                max-width: 100%;
            }
        }
    </style>
    <script type="text/javascript" id="ScriptSidebar">
        function toggleRetract() {
            const retractDiv = document.getElementById('retract');
            retractDiv.classList.toggle('minimized');
        }
        function navigateAction(element) {
            $('.menu-item').removeClass('selected');

            $(element).addClass('selected');

            const allTabs = document.querySelectorAll('.tabs');
            $(allTabs).not('#tab' + element.id).slideUp(300);

            const tabId = 'tab' + element.id;
            const selectedTab = document.getElementById(tabId);
            if (selectedTab) {
                $(selectedTab).slideDown(300);
            }

            const spanText = $(element).find('span').text().trim();
            if (spanText) {
                $('.header').text(spanText);
            }
        }
    </script>
   
     <script type="text/javascript" id="ready">
         function selectPatient(patientNo) {
             $("#hdfReg_ID").val(patientNo);
             fetchPatientInfo();
             hideResults();
          }
         function fetchPatientInfo() {
             debugger;
             var Patient_ID = $("#hdfReg_ID").val();

             $.ajax({
                 type: "POST",
                 url: "NewEMR.aspx/GetBasicInfo",
                 data: JSON.stringify({ Patient_ID: Patient_ID }),
                 contentType: "application/json; charset=utf-8",
                 dataType: "json",
                 success: function (resp) {
                     debugger;
                     var data = JSON.parse(resp.d);

                     $('#patname').text(data.Name);
                     $('#mrno').text(data.Mr_No);
                     $('#txtage').text(data.Age);
                     $('#gender').text(data.Gender);
                     $('#phonenumber').text(data.Mobile);
                     $('#address').text(data.Address);
                     $('#CNIC').text(data.CNIC);


                     fetchAppointment();

                 },
                 error: function (response) {
                     alert("Error: " + response.responseText);
                     console.error("AJAX Error: ", response);
                 }
             });

         }
         function hideResults() {
             searchResults.classList.remove('active');
         }
         document.addEventListener('DOMContentLoaded', function () {
         const searchInput = document.getElementById('searchInput');
         const searchResults = document.getElementById('searchResults');

         let searchTimeout;
         let currentXHR = null;

         searchInput.addEventListener('input', function (e) {
             const query = e.target.value.trim();

              clearTimeout(searchTimeout);

             // Cancel previous AJAX request if still pending
             if (currentXHR && currentXHR.readyState !== 4) {
                 currentXHR.abort();
             }

             // Add small delay for better UX
             searchTimeout = setTimeout(() => {
                 

                  showLoading();

                  searchPatients(query);
             }, 300);
         });

         // Hide results when clicking outside
         document.addEventListener('click', function (e) {
             if (!e.target.closest('.search-container')) {
                 hideResults();
             }
         });
         function searchPatients(searchValue) {
             currentXHR = $.ajax({
                 type: "POST",
                 url: "NewEMR.aspx/GetPatients", // Replace 'YourPage.aspx' with your actual page name
                 data: JSON.stringify({ searchValue: searchValue }),
                 contentType: "application/json; charset=utf-8",
                 dataType: "json",
                 success: function (response) {
                     try {
                         const patients = JSON.parse(response.d);

                         // Check if response contains error
                         if (patients.error) {
                             showError(patients.error);
                         } else {
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
            </div>
        `;
             } else {
                 searchResults.innerHTML = patients.map(patient => {
                     const displayText = `${patient.PatientNo}-${patient.FullName}`;
                     return `
                <div class="result-item" onclick="selectPatient('${patient.PatientNo}')">
                    <div>${highlightText(displayText, query)}</div>
                </div>
            `;
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
        </div>
    `;
             searchResults.classList.add('active');
         }

         function showError(errorMessage) {
             searchResults.innerHTML = `
        <div class="no-results" style="color: #ff6b6b;">
            ⚠️ Error: ${errorMessage}
        </div>
    `;
             searchResults.classList.add('active');
         }

       

         // Listen for patient selection (example usage)
         document.addEventListener('patientSelected', function (e) {
             console.log('Patient Selected Event:', e.detail);
             // You can handle the selected patient here
             // Example: Load patient details, update forms, etc.
         });

         function highlightText(text, query) {
             if (!query) return text;
             const regex = new RegExp(`(${escapeRegExp(query)})`, 'gi');
             return text.replace(regex, '<strong style="background: rgba(102, 126, 234, 0.2); border-radius: 3px; padding: 0 2px;">$1</strong>');
         }

         function escapeRegExp(string) {
             return string.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
         }

         // Show focus effect
         searchInput.addEventListener('focus', function () {
             if (this.value.trim().length >= 2) {
                 const query = this.value.trim();
                 showLoading();
                 searchPatients(query);
             }
         });
         });
     </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <input type="hidden" id="hdfPatient_ID" />
<input type="hidden" id="hdfReg_ID" />
<input type="hidden" id="hdfoutPatID" />
    <div class="row">
        <div id="retract" class="col-lg-2">
            <div class="sidebarr">
                <div class="menu-item no-submenu" id="06" onclick="navigateAction(this)">
                    <div class="menu-title">
                        <img src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/complaints.png" alt="Profile Picture" class="sidebarIcon">
                        <span>OPD</span>
                    </div>
                </div>
                <div class="menu-item no-submenu" id="01" onclick="navigateAction(this)">
                    <div class="menu-title">
                        <img src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/symptoms.png" alt="Profile Picture" class="sidebarIcon">
                        <span>IPD</span>
                    </div>
                </div>
                <div class="menu-item no-submenu" id="02" onclick="navigateAction(this)">
                    <div class="menu-title">
                        <img src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/vitals.png" alt="Profile Picture" class="sidebarIcon">
                        <span>Emergency</span>
                    </div>
                </div>

                <div class="menu-item no-submenu" id="03" onclick="navigateAction(this)">
                    <div class="menu-title">
                        <img src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/history.png" alt="Profile Picture" class="sidebarIcon">
                        <span>Medication</span>
                    </div>
                </div>

                <div class="menu-item no-submenu" id="04" onclick="navigateAction(this)">
                    <div class="menu-title">
                        <img src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/examination.png" alt="Profile Picture" class="sidebarIcon">
                        <span>Investigation</span>
                    </div>
                </div>

                <div class="menu-item no-submenu" id="05" onclick="navigateAction(this)">
                    <div class="menu-title">
                        <img src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/refer.png" alt="Profile Picture" class="sidebarIcon">
                        <span>Diagnostics</span>
                    </div>
                </div>

                <div class="menu-item no-submenu" id="07" onclick="navigateAction(this)">
                    <div class="menu-title">
                        <img src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/primarydiagnosis.png" alt="Profile Picture" class="sidebarIcon">
                        <span>Procedures</span>
                    </div>
                </div>

                <div class="menu-item no-submenu" id="08" onclick="navigateAction(this)">
                    <div class="menu-title">
                        <img src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/finaldiagnosis.png" alt="Profile Picture" class="sidebarIcon">
                        <span>Symptoms</span>
                    </div>
                </div>

                <div class="menu-item no-submenu" id="09" onclick="navigateAction(this)">
                    <div class="menu-title">
                        <img src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/investigation.png" alt="Profile Picture" class="sidebarIcon">
                        <span>Complaints</span>
                    </div>
                </div>

                <div class="menu-item no-submenu" id="10" onclick="navigateAction(this)">
                    <div class="menu-title">
                        <img src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/diagnostics.png" alt="Profile Picture" class="sidebarIcon">
                        <span>Primary Diagnosis</span>
                    </div>
                </div>

                <div class="menu-item no-submenu" id="11" onclick="navigateAction(this)">
                    <div class="menu-title">
                        <img src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/medication.png" alt="Profile Picture" class="sidebarIcon">
                        <span>Final Diagnosis</span>
                    </div>
                </div>

                <div class="menu-item no-submenu" id="12" onclick="navigateAction(this)">
                    <div class="menu-title">
                        <img src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/followup.png" alt="Profile Picture" class="sidebarIcon">
                        <span>Advices</span>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-lg-10">
            <div class="row">
                <div class="col-lg-3">
                    <div onclick="toggleRetract()" style="width: fit-content !important;" class="retractIcon">
                        <img src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/sidebar.png"
                            alt="Sidebar Toggle" class="sidebarToggleIcon" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="search-container">
                        <div class="search-input-wrapper">
                            <input
                                type="text"
                                class="search-input"
                                placeholder="Search for anything..."
                                id="searchInput"
                                autocomplete="off"
                                style="height: 45px; width: 100% !important; padding: 16px 50px 16px 20px !important; border: 1.5px solid #ccc !important; border-radius: 25px !important; background: rgba(255, 255, 255, 0.1) !important; backdrop-filter: blur(10px) !important; color: black !important; font-size: 16px !important; box-shadow: none !important"
                                />
                            <div class="search-icon">🔍</div>
                        </div>
                        <div class="search-results" id="searchResults"></div>
                    </div>
                </div>
                <div class="col-lg-3"></div>
            </div>
            <div class="row">
                <!-- Left Column: Profile Information -->
                <div class="col-lg-5 col-md-5 col-sm-5">
                    <div class="card3">
                        <div class="profile-info">
                            <img src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/cake.png" alt="Profile Picture" class="profile-img">
                            <div class="profile-details">
                                <span class="profile-name" id="patname"></span>
                                <p><strong class="">MR No:</strong> &nbsp; &nbsp; <span style="font-weight: 500 !important" id="mrno"></span>&nbsp; &nbsp; &nbsp; <strong class="">Age:</strong> &nbsp; &nbsp; <span style="font-weight: 500 !important" id="txtage"></span>&nbsp;&nbsp;&nbsp; <strong class="">Gender:</strong> &nbsp; &nbsp; <span style="font-weight: 500 !important" id="gender"></span></p>
                                <p><strong class="">Phone Number:</strong> &nbsp; &nbsp;&nbsp; <span style="font-weight: 500 !important" id="phonenumber"></span></p>
                                <p><strong class="">CNIC:</strong>&nbsp;&nbsp;&nbsp; <span style="font-weight: 500 !important" id="CNIC"></span></p>
                                <p><strong class="">Address:</strong> &nbsp;&nbsp;&nbsp;<span style="font-weight: 500 !important" id="address"></span></p>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Right Column: Appointment Information -->
                <div class="col-lg-6 col-md-6 col-sm-6">
                    <div class="appointmentcard">
                        <div class="appointment-info">
                            <h5 style="margin-right: 45px; font-size: 1.3em">
                                <strong class="">Upcoming Appointment</strong>

                            </h5>
                            <span class="badge" style="cursor: pointer;"><span id="appdate">Appointment Date</span></span>
                            <h5 style="margin-left: 45px"><strong class="">Consultation with &nbsp;<span id="doctorname"></span></strong></h5>
                        </div>

                        <div class="appointment-details">
                            <div class="row-details">
                                <p><strong class="labelcolor">Last Visit:&nbsp;</strong><span id="prv_visit"></span></p>
                                <p><strong class="labelcolor">Doctor Name:&nbsp;</strong><span id="prvDoctor"></span></p>
                                <p><strong class="labelcolor">Department:&nbsp;</strong><span id="Department"></span></p>
                            </div>
                        </div>

                    </div>
                </div>
            </div>

            <h2 class="header mybutton"></h2>
        </div>
    </div>
</asp:Content>
