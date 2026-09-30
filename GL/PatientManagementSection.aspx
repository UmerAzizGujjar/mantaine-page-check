<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="PatientManagementSection.aspx.cs" Inherits="PMS.PatientManagementSection" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <script runat="server">
    
        [System.Web.Services.WebMethod]
        public static string RunHRMS()
        {
            string fileName = @"\\192.168.1.15\Debug\GUIManager.exe";
            System.Diagnostics.ProcessStartInfo startInfo = new System.Diagnostics.ProcessStartInfo();
            startInfo.FileName = fileName;
            startInfo.Arguments = fileName;
            System.Diagnostics.Process.Start(startInfo);
            return "Done";
        }                    
        
    </script>

    <script type="text/javascript">

        function GetDashBoardDetails() {

            PageMethods.GetDashBoardDetails(function (resp) {
                $.each(JSON.parse(resp), function (key, value) {
                    var url = value.URL.replace('~', '');
                    url = url.replace('/', '');
                    var find = $("a[href='" + url + "']").parent();
                    if (find.length != 0) {
                        find.show();
                    }
                });
            }, function (error) { alert(error.get_message()); });
        }

        $(document).ready(function () {
            GetDashBoardDetails();
        });
    </script>

    <div class="container">
        <div class="row">
            <div class="col-sm-2 cc" style="display: none;">
                <a class="btn btn-coco radius-4" href="Patients.aspx">
                    <img class="center-block" src="wwwroot/images/HMIS_Icons/Patient.jpg" width="80px" alt="" />
                    <h5 class="cocotxt">Initial Registration</h5>
                </a>
            </div>
            <div class="col-sm-2 cc" style="display: none;">
                <a class="btn btn-coco radius-4" href="Patients.aspx">
                    <img class="center-block" src="wwwroot/images/HMIS_Icons/Patient.jpg" width="80px" alt="" />
                    <h5 class="cocotxt">Revisit Patients</h5>
                </a>
            </div>
            <div class="col-sm-2 cc" style="display: none;">
                <a class="btn btn-coco radius-4" href="Appointment.aspx">
                    <img class="center-block" src="wwwroot/images/Appointment logo.jpg" width="100px" height="90px" alt="" />
                    <h5 class="cocotxt">Doctors Appointment</h5>
                </a>
            </div>
            <div class="col-sm-2 cc" style="display: none;">
                <a class="btn btn-coco radius-4" href="InPatientsCase.aspx">
                    <img class="center-block" src="wwwroot/images/HMIS_Icons/In-patient.jpg" width="80px" alt="" />
                    <h5 class="cocotxt">In-Patient</h5>
                </a>
            </div>
            <div class="col-sm-2 cc" style="display: none;">
                <a class="btn btn-coco radius-4" href="OutPatients.aspx">
                    <img class="center-block" src="wwwroot/images/HMIS_Icons/Out_Patient.jpg" width="80px" alt="" />
                    <h5 class="cocotxt">Out Patient</h5>
                </a>
            </div>

            <div class="col-sm-2 cc" style="display: none;">
                <a class="btn btn-coco radius-4" href="InPatientMonitoring.aspx">
                    <img class="center-block" src="wwwroot/images/HMIS_Icons/Nurse_Patient_Monitoring.jpg" width="80px" alt="" />
                    <h5 class="cocotxt">InPatient Monitoring</h5>
                </a>
            </div>

        </div>
        <div class="row">
          
            <div class="col-sm-2 cc" style="display: none;">
                <a class="btn btn-coco radius-4" href="BloodBank.aspx">
                    <img class="center-block" src="wwwroot/images/HMIS_Icons/Blood_Bank.jpg" width="80px" alt="" />
                    <h5 class="cocotxt">Blood Bank</h5>
                </a>
            </div>
        
            <div class="col-sm-2 cc" style="display: none;">
                <a class="btn btn-coco radius-4" href="BloodDonor.aspx">
                    <img class="center-block" src="wwwroot/images/HMIS_Icons/Blood_Donation.jpg" width="80px" alt="" />
                    <h5 class="cocotxt">Blood Donation</h5>
                </a>
            </div>
            <div class="col-sm-2 cc" style="display: none;">
                <a class="btn btn-coco radius-4" href="LaboratoryTest.aspx">
                    <img class="center-block" src="wwwroot/images/HMIS_Icons/Lab_Test.jpg" width="80px" alt="" />
                    <h5 class="cocotxt">Laboratory Test</h5>
                </a>
            </div>
            <div class="col-sm-2 cc" style="display: none;">
                <a class="btn btn-coco radius-4" href="TestDefination.aspx.aspx">
                    <img class="center-block" src="wwwroot/images/HMIS_Icons/Lab_Test.jpg" width="80px" alt="" />
                    <h5 class="cocotxt">Test Defination</h5>
                </a>
            </div>
            <div class="col-sm-2 cc" style="display: none;">
                <a class="btn btn-coco radius-4" href="LabTestResult.aspx">
                    <img class="center-block" src="wwwroot/images/HMIS_Icons/Purchase_Invoice.jpg" width="80px" alt="" />
                    <h5 class="cocotxt">Test Result</h5>
                </a>
            </div>
            <div class="col-sm-2 cc" style="display: none;">
                <a class="btn btn-coco radius-4" href="BillingProcess.aspx">
                    <img class="center-block" src="wwwroot/images/HMIS_Icons/BillingLogo.png" width="80px" alt="" />
                    <h5 class="cocotxt">Billing</h5>
                </a>
            </div>
            <div class="col-sm-2 cc" style="display: none;">
                <a class="btn btn-coco radius-4" href="InPatientsAdmission.aspx">
                    <img class="center-block" src="wwwroot/images/HMIS_Icons/Inpatients_Admission.png" width="80px" alt="" />
                    <h5 class="cocotxt">In-Patient Admission</h5>
                </a>
            </div>
            
        </div>
        <div class="row">
            <div class="col-sm-2 cc" style="display: none;">
                <a class="btn btn-coco radius-4" href="InPatientsDischarge.aspx">
                    <img class="center-block" src="wwwroot/images/HMIS_Icons/Inpatients_Discharge.png" width="80px" style="height: 82px;" alt="" />
                    <h5 class="cocotxt">In-Patient Discharge</h5>
                </a>
            </div>
        </div>

        <div class="col-sm-6 col-sm-offset-4" style="margin-top: 47px;">
            <asp:Image ID="imgLogo" runat="server" ImageUrl="~/wwwroot/images/HMIS_Icons/TibbITLogo_2.png" Width="300px" Height="300px" />
        </div>
    </div>
</asp:Content>
