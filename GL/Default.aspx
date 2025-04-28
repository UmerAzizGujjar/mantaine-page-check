<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="PMS.Default" Theme="Default_Theme" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
    .billing-section {
    border: 2px solid #ffc000; 
    border-radius: 7px;
    transition: border-color 0.3s ease;
}

.billing-section:hover {
    border-color: #438eb9 ; 
}
    </style>
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

    <br />
    <div class="container">
       <%-- <div class="row text-center">
           <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4">
             <a class="btn btn-coco radius-4 billing-section" href="~../../Modules/Dashboards/BillingSection.aspx" style="width: 60%;" >
            <img class="img-fluid" src="~../../wwwroot/images/HMIS_Icons/Billing.jpg" alt="Billing" style="height: 100px; object-fit: contain;" />
          <h5 class="cocotxt">Billing</h5>
              </a>
        </div>
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4">
                <a class="btn btn-coco radius-4 billing-section" href="~../../Modules/Dashboards/PatientSection.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../wwwroot/images/HMIS_Icons/Patient.jpg" alt="Patients" style="height: 100px; object-fit: contain;" />
                    <h5 class="cocotxt">Patients</h5>
                </a>
            </div>
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4">
                <a class="btn btn-coco radius-4 billing-section" href="~../../Modules/Dashboards/LabSection.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../wwwroot/images/HMIS_Icons/Lab_Test.jpg" alt="Lab/Radiology" style="height: 100px; object-fit: contain;" />
                    <h5 class="cocotxt">Lab/Radiology</h5>
                </a>
            </div>
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4">
                <a class="btn btn-coco radius-4 billing-section" href="~../../Modules/Dashboards/PharmacySection.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../wwwroot/images/HMIS_Icons/pharma.png" alt="Pharmacy" style="height: 100px; object-fit: contain;" />
                    <h5 class="cocotxt">Pharmacy</h5>
                </a>
            </div>
        </div>
        <br />
        <br />
        <div class="row text-center">
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4">
                <a class="btn btn-coco radius-4 billing-section" href="~../../Modules/Dashboards/InventorySection.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../wwwroot/images/HMIS_Icons/Inventory.png" alt="Inventory" style="height: 100px; object-fit: contain;" />
                    <h5 class="cocotxt">Inventory</h5>
                </a>
            </div>
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4">
                <a class="btn btn-coco radius-4 billing-section" href="~../../Modules/Dashboards/PurchaseSection.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../wwwroot/images/HMIS_Icons/Purchase.png" alt="Purchase" style="height: 100px; object-fit: contain;" />
                    <h5 class="cocotxt">Purchase</h5>
                </a>
            </div>
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4">
                <a class="btn btn-coco radius-4 billing-section" href="~../../Modules/Dashboards/AccountSection.aspx" style="width: 60%;" >
                    <img class="img-fluid" src="~../../wwwroot/images/HMIS_Icons/Chart_Of_Accounts.jpg" alt="Accounts" style="height: 100px; object-fit: contain;" />
                    <h5 class="cocotxt">Accounts</h5>
                </a>
            </div>
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4">
                <a class="btn btn-coco radius-4 billing-section" href="~../../Modules/Dashboards/AdminSection.aspx" style="width: 60%;" >
                    <img class="img-fluid" src="~../../wwwroot/images/HMIS_Icons/adminn.jpg" alt="Administration" style="height: 100px; object-fit: contain;" />
                    <h5 class="cocotxt">Administration</h5>
                </a>
            </div>
        </div>
    </div>--%>


    <div class="col-sm-6 col-sm-offset-4" style="margin-top: 47px;">
        <asp:Image ID="imgLogo" runat="server" ImageUrl="~../../wwwroot/images/HMIS_Icons/TibbITLogo_2.png" Style="height: 245px; width: 408px; border-width: 0px;" />

    </div>

</asp:Content>
