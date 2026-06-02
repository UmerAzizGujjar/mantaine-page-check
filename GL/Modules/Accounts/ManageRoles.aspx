<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ManageRoles.aspx.cs" Inherits="PMS.Account.ManageRoles" Theme="Default_Theme" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/css/CustomCss/swalalert.css" rel="stylesheet" />
    <style type="text/css">
    #ctl00_MainContent_ddlCompany{
        width:200px !important;
    }
        input[type="checkbox"] {
            width: 20% !important;
        }

        input[type="text"] {
            width: 300px !important;
            margin-left: 10px;
        }

        select {
            width: 300px !important;
            margin-left: 10px;
        }

        #ctl00_MainContent_cbRolesList {
            width: 250px !important;
        }

        #ctl00_MainContent_btnSave, #ctl00_MainContent_btnBack {
            width: 100px !important;
            margin-top: 10px;
        }

        .card {
            border: 1px solid #ccc;
            transition: all 0.3s ease;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 20px;
            width: 460px;
        }

            .card:hover {
                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
            }
    </style>
       <script type="text/javascript">
           $(document).ready(function () {
               //fillDepts();
               $('#ctl00_MainContent_btnSave').removeAttr('style');
               


           });
           
       </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
        <div class="col-lg-3"></div>
        <div class="col-lg-5">
            <div class="card">
    <div class="card-body">
        <asp:UpdatePanel runat="server" ID="upForm" UpdateMode="Conditional">
            <ContentTemplate>
                <asp:Panel runat="server" ID="pnlForm" DefaultButton="btnSave">
                    <div class="row">
                        <div class="col-lg-2" style="margin-top: 8px;">
                            <asp:Label Text="User" ID="lblUser" runat="server" />
                        </div>
                        <div class="col-lg-10">
                            <asp:DropDownList runat="server" AppendDataBoundItems="true" AutoPostBack="true" ID="ddlUsers">
                            </asp:DropDownList>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator1" ErrorMessage="User is required." InitialValue="0" SetFocusOnError="true" Display="Dynamic" ControlToValidate="ddlUsers" runat="server" />
                        </div>
                    </div>


                    <div class="row" style="margin-top: 8px;">
                        <div class="col-lg-4">
                            <asp:Label Text="Roles" runat="server" />

                        </div>
                        <div class="col-lg-8" style="margin-top: 8px;">
                            <asp:CheckBoxList ID="cbRolesList" runat="server">
                            </asp:CheckBoxList>
                        </div>

                    </div>

                    <div class="row" style="margin-top: 16px;">
                       
                        <div class="col-lg-4" style="margin-top: 10px;">
                            <asp:CheckBox Text="All Company" ID="cbAllCompany" runat="server" AutoPostBack="true" OnCheckedChanged="cbAllCompany_CheckedChanged" />
                        </div>
                        <div class="col-lg-6" style="margin-top: 8px;">
                            <asp:DropDownList runat="server" AppendDataBoundItems="true" ID="ddlCompany" Enabled="false">
                            </asp:DropDownList>
                            <asp:RequiredFieldValidator ID="rfvCompany" ErrorMessage="Company is required." InitialValue="0"
                                SetFocusOnError="true" Display="Dynamic" ControlToValidate="ddlCompany" runat="server" Enabled="false" />
                        </div>
                    </div>














                    <div class="row">
                        <div class="col-lg-3">
                          
                                    <asp:Button ID="btnBack" Text="View" CssClass="btn btn-gray" runat="server" CausesValidation="false" PostBackUrl="~/Modules/Accounts/RoleAssignment.aspx" />
                                </div>
                                <div class="col-lg-3 col-md-4 col-sm-6">
                                    
                                    <asp:Button Text="Save" ID="btnSave" CssClass="btn-primry" runat="server"  OnClick="btnSave_Click"/>
                                </div>
                            </div>
                        </div>
                    </div>

                    <asp:Label ID="lblMessage" runat="server" />

                </asp:Panel>
            </ContentTemplate>
        </asp:UpdatePanel>

    </div>
</div>
        </div>
    </div>
    

</asp:Content>
