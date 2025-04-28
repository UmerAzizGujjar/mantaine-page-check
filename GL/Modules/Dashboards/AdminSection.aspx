<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AdminSection.aspx.cs" Inherits="PMS.Modules.Dashboards.AdminSection" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
     <link href="../../wwwroot/css/Shortcuts.css" rel="stylesheet" />
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
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Accounts/Register.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/images/dashboard_Icons/AddUser.png" alt="Request" style="object-fit: contain;" />
                    <h5 class="cocotxt">Add User</h5>
                </a>
            </div>
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Accounts/Roles.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/images/dashboard_Icons/Role.png" alt="Order" style="object-fit: contain;" />
                    <h5 class="cocotxt">Add New Role</h5>
                </a>
            </div>
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Accounts/RoleAssignment.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/images/dashboard_Icons/roleAssign.png" alt="Request" style="object-fit: contain;" />
                    <h5 class="cocotxt">Role Assignment</h5>
                </a>
            </div>
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4">
                <a class="btn btn-coco radius-4 shortcut" href="~../../../../Modules/Accounts/ChangePassword.aspx" style="width: 60%;">
                    <img class="img-fluid" src="~../../../../wwwroot/images/dashboard_Icons/changepass.png" alt="Statement" style="object-fit: contain;" />
                    <h5 class="cocotxt">Change Password</h5>
                </a>
            </div>
        </div>
        <br />
       
    </div>

    <%--
    <div class="col-sm-6 col-sm-offset-4" style="margin-top: 47px;">
        <asp:Image ID="imgLogo" runat="server" ImageUrl="~../../../../wwwroot/images/HMIS_Icons/TibbITLogo_2.png"
            Style="height: 245px; width: 408px; border-width: 0px; opacity: 0.5; position: relative; z-index: -1;" />
    </div>--%>
</asp:Content>