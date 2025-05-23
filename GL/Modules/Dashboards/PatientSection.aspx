<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="PatientSection.aspx.cs" Inherits="PMS.PatientSection" %>


<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
   <link href="../../wwwroot/Tibbit_theme/css/Shortcuts.css" rel="stylesheet" />
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
        <div class="row text-center">
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/PatientManagement/RegisterPatient.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/add.png" alt="Patient" style="object-fit: contain;" />
                    <h5 class="cocotxt">Reg Patient</h5>
                </a>
            </div>
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Appointment/Appointment.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/medical-appointment.png" alt="Appointment" style="object-fit: contain;" />
                    <h5 class="cocotxt">Appointment</h5>
                </a>
            </div>
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/PatientManagement/OPD.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/opd.png" alt="OPD" style="object-fit: contain;" />
                    <h5 class="cocotxt">OPD</h5>
                </a>
            </div>
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/PatientManagement/OutPatients.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/medical-record.png" alt="Prescription" style="object-fit: contain;" />
                    <h5 class="cocotxt">OPD Prescription</h5>
                </a>
            </div>
        </div>
        <br />
        <div class="row text-center">
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/PatientManagement/EmergencyCase.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/first-aid-box.png" alt="Emergency" style="object-fit: contain;" />
                    <h5 class="cocotxt">Emergency</h5>
                </a>
            </div>
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/PatientManagement/InPatientsAdmission.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/inpatienta.png" alt="Purchase" style="object-fit: contain;" />
                    <h5 class="cocotxt">IPD Admission</h5>
                </a>
            </div>
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/PatientManagement/InPatientsCase.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/inpatient.png" alt="Accounts" style="object-fit: contain;" />
                    <h5 class="cocotxt">Admitted Patient</h5>
                </a>
            </div>
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/PatientManagement/InPatientMonitoring.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/nurse.png" alt="Administration" style="object-fit: contain;" />
                    <h5 class="cocotxt">Nursing</h5>
                </a>
            </div>
        </div>
    </div>
</asp:Content>

