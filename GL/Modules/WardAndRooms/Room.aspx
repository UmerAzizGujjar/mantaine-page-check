<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Room.aspx.cs" Inherits="PMS.Room" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/room-form.css" rel="stylesheet" />

    <script type="text/javascript">
        function goToListView() {
            window.location.href = '<%= ResolveUrl("~/Modules/WardAndRooms/RoomView.aspx") %>';
        }
        function toggleBeds(cb) {
            var div = document.getElementById('divNoOfBeds');
            if (div) div.style.display = cb.checked ? 'block' : 'none';
        }
        $(document).ready(function () {
            var cb = document.getElementById('<%= chkMultipleBeds.ClientID %>');
            if (cb) toggleBeds(cb);
        });
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="rm-page">

        <!-- Title line: the master page puts the page title in the empty left side; the badge sits on the right -->
        <div class="pr-meta-bar">
            <div class="meta-left"></div>
            <div class="meta-right">
                <div class="rm-badge">
                    <span class="rm-badge-label">Room ID</span>
                    <span class="rm-badge-value"><asp:Label ID="lblRoom_ID" runat="server" Text="(New)"></asp:Label></span>
                </div>
                <!-- Hidden Room ID preserved (referenced from code-behind) -->
                <asp:TextBox ID="txtRoom_ID" runat="server" ReadOnly="true" Visible="false"></asp:TextBox>
            </div>
        </div>

        <div class="rm-layout2">
            <section class="rm-card">
                <h5 class="rm-card-title"><i class="fa fa-info-circle"></i> Room Details</h5>
                <div class="rm-grid">
                    <div class="rm-field">
                        <asp:Label ID="lblRoom_No" runat="server" Text="Room No. *" CssClass="rm-lbl"></asp:Label>
                        <asp:TextBox ID="txtRoom_No" runat="server" CssClass="rm-input"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvRoom_No" runat="server" ControlToValidate="txtRoom_No" Display="Dynamic" Text="*" ErrorMessage="Room No. is Required"></asp:RequiredFieldValidator>
                        <asp:RangeValidator ID="rngRoom_No" runat="server" MinimumValue="0" MaximumValue="99999999999999999999" Display="Dynamic" ControlToValidate="txtRoom_No" Text="*" ErrorMessage="Only Enter Integer Value"></asp:RangeValidator>
                    </div>
                    <div class="rm-field">
                        <asp:Label ID="lblName" runat="server" Text="Room Name" CssClass="rm-lbl"></asp:Label>
                        <asp:TextBox ID="txtName" runat="server" CssClass="rm-input"></asp:TextBox>
                    </div>
                    <div class="rm-field">
                        <asp:Label ID="lblBuilding_Type" runat="server" Text="Building Type" CssClass="rm-lbl"></asp:Label>
                        <asp:DropDownList ID="ddlBuildingType" runat="server" AppendDataBoundItems="true" CssClass="rm-input">
                        </asp:DropDownList>
                    </div>
                    <div class="rm-field">
                        <asp:Label ID="lblFloor_No" runat="server" Text="Floor No. *" CssClass="rm-lbl"></asp:Label>
                        <asp:TextBox ID="txtFloorNo" runat="server" CssClass="rm-input"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvFloor_No" runat="server" ControlToValidate="txtFloorNo" Text="*" Display="Dynamic" ErrorMessage="Floor No. Required"></asp:RequiredFieldValidator>
                        <asp:RangeValidator ID="rngFloor_No" runat="server" MinimumValue="0" MaximumValue="999999999999999999999999" Display="Dynamic" ControlToValidate="txtFloorNo" Text="*" ErrorMessage="Only Enter Integer Value"></asp:RangeValidator>
                    </div>
                    <div class="rm-field">
                        <asp:Label ID="lblLocation" runat="server" Text="Location" CssClass="rm-lbl"></asp:Label>
                        <asp:TextBox ID="txtLocation" runat="server" CssClass="rm-input"></asp:TextBox>
                    </div>
                    <div class="rm-field">
                        <asp:Label ID="lblWarden" runat="server" Text="Warden *" CssClass="rm-lbl"></asp:Label>
                        <asp:DropDownList ID="ddlWarden" runat="server" AppendDataBoundItems="true" CssClass="rm-input">
                        </asp:DropDownList>
                    </div>
                </div>
            </section>

            <section class="rm-card">
                <h5 class="rm-card-title"><i class="fa fa-cogs"></i> Room Configuration</h5>
                <div class="rm-grid">
                    <div class="rm-field">
                        <asp:Label ID="lblRoom_Type" runat="server" Text="Room Type *" CssClass="rm-lbl"></asp:Label>
                        <asp:DropDownList ID="ddlRoomType" runat="server" AppendDataBoundItems="true" AutoPostBack="true" OnSelectedIndexChanged="ddlRoomType_SelectedIndexChanged" CssClass="rm-input">
                        </asp:DropDownList>
                        <asp:RequiredFieldValidator ID="rfvRoomType" runat="server" ControlToValidate="ddlRoomType" Display="Dynamic" InitialValue="0" Text="*" ErrorMessage="Select Room Type"></asp:RequiredFieldValidator>
                    </div>
                    <div class="rm-field">
                        <asp:Label ID="LblRoom_Charges" runat="server" Text="Charges/Day *" CssClass="rm-lbl"></asp:Label>
                        <asp:UpdatePanel ID="upCharges" runat="server" UpdateMode="Conditional">
                            <Triggers>
                                <asp:AsyncPostBackTrigger ControlID="ddlRoomType" EventName="SelectedIndexChanged" />
                            </Triggers>
                            <ContentTemplate>
                                <asp:TextBox ID="txtRoom_Charges" runat="server" CssClass="rm-input"></asp:TextBox>
                                <div class="rm-help">Per-bed charge (auto): <asp:Label ID="lblPerBedCharge" runat="server" Text="-"></asp:Label></div>
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
                    <div class="rm-field">
                        <label class="rm-check">
                            <asp:CheckBox ID="chkMultipleBeds" runat="server" onclick="toggleBeds(this);" /> Multiple Beds
                        </label>
                        <div class="rm-help">Tick to allocate this room bed-wise (each bed separately).</div>
                    </div>
                    <div class="rm-field" id="divNoOfBeds" style="display:none;">
                        <asp:Label ID="lblNoOfBeds" runat="server" Text="No. of Beds *" CssClass="rm-lbl"></asp:Label>
                        <asp:TextBox ID="txtNoOfBeds" runat="server" CssClass="rm-input"></asp:TextBox>
                        <div class="rm-help">e.g. 2 for a twin-sharing room.</div>
                    </div>
                </div>
            </section>
        </div>

        <div class="rm-actions">
            <div>
                <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="btn btn-primry w-100" OnClick="btnSave_Click" />
            </div>
            <div>
                <input type="button" value="List View" class="btn-yellow" onclick="goToListView()" />
            </div>
        </div>
        <asp:ValidationSummary ID="ValidationSummary1" HeaderText="Page Errors" ShowSummary="true" DisplayMode="List" runat="server" />

    </div>

</asp:Content>
