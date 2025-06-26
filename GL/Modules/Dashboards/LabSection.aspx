<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="LabSection.aspx.cs" Inherits="PMS.Modules.Dashboards.LabSection" %>


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
    <br />
    <div class="container">
        <div class="row text-center">
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Lab/SampleCollectionFrom.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/blood-sample.png" alt="Collection" style="object-fit: contain;" />
                    <h5 class="cocotxt">Sample Collection</h5>
                </a>
            </div>
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Lab/LaboratoryTest.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/blood-test.png" alt="Aknowledgment" style="object-fit: contain;" />
                    <h5 class="cocotxt">Aknowledgment</h5>
                </a>
            </div>
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Lab/LabReportPreview.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/Lab2.png" alt="Report" style="object-fit: contain;" />
                    <h5 class="cocotxt">Lab Report</h5>
                </a>
            </div>
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Administrator/TestApproval.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/search.png" alt="Approval" style="object-fit: contain;" />
                    <h5 class="cocotxt">Review/Approval</h5>
                </a>
            </div>
        </div>
        <br />
        <div class="row text-center">
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Administrator/TestApproval.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/qualitative-research.png" alt="Aopproved" style="object-fit: contain;" />
                    <h5 class="cocotxt">Aopproved Test</h5>
                </a>
            </div>
    </div>

    <%--
    <div class="col-sm-6 col-sm-offset-4" style="margin-top: 47px;">
        <asp:Image ID="imgLogo" runat="server" ImageUrl="~../../../../wwwroot/images/HMIS_Icons/TibbITLogo_2.png"
            Style="height: 245px; width: 408px; border-width: 0px; opacity: 0.5; position: relative; z-index: -1;" />
    </div>--%>
</asp:Content>

