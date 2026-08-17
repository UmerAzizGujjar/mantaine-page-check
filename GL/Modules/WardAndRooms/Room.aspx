<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Room.aspx.cs" Inherits="PMS.Room" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/vendor.css" rel="stylesheet" />
    <style type="text/css">
        .mg {
            padding-left: 53px;
        }
        .btn-yellow {
            width: 95px !important;
        }
        #ctl00_MainContent_btnSave {
            width: 95px !important;
        }
        /* Style the rendered <span> from <asp:Label> the same as native <label> in vendor.css */
        .pr-primary-settings .pr-asp-label {
            font-size: 11px;
            font-weight: 700;
            color: #555;
            text-transform: uppercase;
            letter-spacing: 0.04em;
            margin-bottom: 4px;
            display: block;
        }
    </style>

    <script type="text/javascript">
        function goToListView() {
            window.location.href = '<%= ResolveUrl("~/Modules/WardAndRooms/RoomView.aspx") %>';
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <!-- Meta Bar (title only — no Active badge since the form has no Active toggle) -->
    <div class="pr-meta-bar">
        <div class="meta-left">
            <span class="meta-title"><i class="fa fa-bed"></i> Room</span>
        </div>
        <div class="meta-right">
            <div class="meta-badge">
                <span class="badge-label">ID:</span>
                <span class="badge-value"><asp:Label ID="lblRoom_ID" runat="server" Text="(New)"></asp:Label></span>
            </div>
            <!-- Hidden Room ID preserved (referenced from code-behind) -->
            <asp:TextBox ID="txtRoom_ID" runat="server" ReadOnly="true" Visible="false"></asp:TextBox>
        </div>
    </div>

    <div class="row">
        <!-- Left Column: Identification & Building -->
        <div class="col-lg-6 col-md-12 pr-cards-column">
            <!-- Card 1: Room Identification -->
            <div class="pr-primary-settings">
                <h5 class="pr-section-title" style="margin-top:0;"><i class="fa fa-info-circle"></i> Room Identification</h5>
                <div class="row">
                    <div class="col-md-6 col-sm-12">
                        <asp:Label ID="lblRoom_No" runat="server" Text="Room No. *" CssClass="pr-asp-label"></asp:Label>
                        <div class="input-group">
                            <div class="input-group-prepend"><span class="input-group-text"><i class="fa fa-hashtag"></i></span></div>
                            <asp:TextBox ID="txtRoom_No" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>
                        <asp:RequiredFieldValidator ID="rfvRoom_No" runat="server" ControlToValidate="txtRoom_No" Display="Dynamic" Text="*" ErrorMessage="Room No. is Required"></asp:RequiredFieldValidator>
                        <asp:RangeValidator ID="rngRoom_No" runat="server" MinimumValue="0" MaximumValue="99999999999999999999" Display="Dynamic" ControlToValidate="txtRoom_No" Text="*" ErrorMessage="Only Enter Integer Value"></asp:RangeValidator>
                    </div>
                    <div class="col-md-6 col-sm-12">
                        <asp:Label ID="lblName" runat="server" Text="Room Name" CssClass="pr-asp-label"></asp:Label>
                        <div class="input-group">
                            <div class="input-group-prepend"><span class="input-group-text"><i class="fa fa-tag"></i></span></div>
                            <asp:TextBox ID="txtName" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Card 2: Building & Floor -->
            <div class="pr-primary-settings">
                <h5 class="pr-section-title" style="margin-top:0;"><i class="fa fa-building"></i> Building &amp; Floor</h5>
                <div class="row">
                    <div class="col-md-6 col-sm-12">
                        <asp:Label ID="lblBuilding_Type" runat="server" Text="Building Type" CssClass="pr-asp-label"></asp:Label>
                        <asp:DropDownList ID="ddlBuildingType" runat="server" AppendDataBoundItems="true" CssClass="form-control">
                        </asp:DropDownList>
                    </div>
                    <div class="col-md-6 col-sm-12">
                        <asp:Label ID="lblFloor_No" runat="server" Text="Floor No. *" CssClass="pr-asp-label"></asp:Label>
                        <div class="input-group">
                            <div class="input-group-prepend"><span class="input-group-text"><i class="fa fa-sort-numeric-up"></i></span></div>
                            <asp:TextBox ID="txtFloorNo" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>
                        <asp:RequiredFieldValidator ID="rfvFloor_No" runat="server" ControlToValidate="txtFloorNo" Text="*" Display="Dynamic" ErrorMessage="Floor No. Required"></asp:RequiredFieldValidator>
                        <asp:RangeValidator ID="rngFloor_No" runat="server" MinimumValue="0" MaximumValue="999999999999999999999999" Display="Dynamic" ControlToValidate="txtFloorNo" Text="*" ErrorMessage="Only Enter Integer Value"></asp:RangeValidator>
                    </div>
                </div>
            </div>
        </div>

        <!-- Right Column: Configuration & Location -->
        <div class="col-lg-6 col-md-12 pr-cards-column">
            <!-- Card 3: Room Configuration -->
            <div class="pr-primary-settings">
                <h5 class="pr-section-title" style="margin-top:0;"><i class="fa fa-cogs"></i> Room Configuration</h5>
                <div class="row">
                    <div class="col-md-6 col-sm-12">
                        <asp:Label ID="lblRoom_Type" runat="server" Text="Room Type *" CssClass="pr-asp-label"></asp:Label>
                        <asp:DropDownList ID="ddlRoomType" runat="server" AppendDataBoundItems="true" AutoPostBack="true" OnSelectedIndexChanged="ddlRoomType_SelectedIndexChanged" CssClass="form-control">
                        </asp:DropDownList>
                        <asp:RequiredFieldValidator ID="rfvRoomType" runat="server" ControlToValidate="ddlRoomType" Display="Dynamic" InitialValue="0" Text="*" ErrorMessage="Select Room Type"></asp:RequiredFieldValidator>
                    </div>
                    <div class="col-md-6 col-sm-12">
                        <asp:Label ID="LblRoom_Charges" runat="server" Text="Charges/Day *" CssClass="pr-asp-label"></asp:Label>
                        <asp:UpdatePanel ID="upCharges" runat="server" UpdateMode="Conditional">
                            <Triggers>
                                <asp:AsyncPostBackTrigger ControlID="ddlRoomType" EventName="SelectedIndexChanged" />
                            </Triggers>
                            <ContentTemplate>
                                <asp:TextBox ID="txtRoom_Charges" runat="server" CssClass="form-control"></asp:TextBox>
                            </ContentTemplate>
                        </asp:UpdatePanel>
                        <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="txtRoom_Charges" ErrorMessage="Enter Charges" Text="*"></asp:RequiredFieldValidator>
                        <asp:RangeValidator ID="rvRoom_Charges" runat="server" ControlToValidate="txtRoom_Charges" MinimumValue="0" MaximumValue="999999999" ErrorMessage="Only enter integer values." Text="*"></asp:RangeValidator>
                        <asp:UpdateProgress ID="UpdateProgress1" runat="server">
                            <ProgressTemplate>
                                <div class="loadingimage">
                                    <asp:Image ID="image1" ImageUrl="~/images/loading.gif" runat="server" Width="32px" /></div>
                            </ProgressTemplate>
                        </asp:UpdateProgress>
                    </div>
                </div>
            </div>

            <!-- Card 4: Location & Warden -->
            <div class="pr-primary-settings">
                <h5 class="pr-section-title" style="margin-top:0;"><i class="fa fa-map-marker"></i> Location &amp; Warden</h5>
                <div class="row">
                    <div class="col-md-6 col-sm-12">
                        <asp:Label ID="lblLocation" runat="server" Text="Location" CssClass="pr-asp-label"></asp:Label>
                        <div class="input-group">
                            <div class="input-group-prepend"><span class="input-group-text"><i class="fa fa-map-marker"></i></span></div>
                            <asp:TextBox ID="txtLocation" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>
                    </div>
                    <div class="col-md-6 col-sm-12">
                        <asp:Label ID="lblWarden" runat="server" Text="Warden *" CssClass="pr-asp-label"></asp:Label>
                        <asp:DropDownList ID="ddlWarden" runat="server" AppendDataBoundItems="true" CssClass="form-control">
                        </asp:DropDownList>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="pr-action-buttons">
        <div class="row">
            <div class="col-lg-2 col-md-4 col-sm-12">
                <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="btn btn-primry w-100" OnClick="btnSave_Click" />
            </div>
            <div class="col-lg-2 col-md-4 col-sm-12">
                <input type="button" value="List View" class="btn-yellow" onclick="goToListView()" />
            </div>
        </div>
        <div class="row" style="margin-top:15px;">
            <div class="col-lg-12">
                <asp:ValidationSummary ID="ValidationSummary1" HeaderText="Page Errors" ShowSummary="true" DisplayMode="List" runat="server" />
            </div>
        </div>
    </div>

</asp:Content>
