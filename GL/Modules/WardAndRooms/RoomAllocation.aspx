<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="RoomAllocation.aspx.cs" Inherits="PMS.RoomAllocation" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
         .btn-yellow {
width: 95px !important;
 }
 #ctl00_MainContent_btnSave{
     width: 95px !important;
 }

    </style>

    <script type="text/javascript" src="../Scripts/jquery.tokeninput.js"></script>
    <script type="text/javascript">

        $(document).ready(function () {
            bindControls();
            bindDate();
        });

        function bindDate() {
            $("#ctl00_MainContent_txtTo_Date").datepicker({ dateFormat: 'mm/dd/yy' });
            $("#ctl00_MainContent_txtFrom_Date").datepicker({ dateFormat: 'mm/dd/yy' });
        }

        function chkAllocatedRoom() {
       
            var pat = document.getElementById('<%= txtPatient_ID.ClientID%>').value;

            if (pat == '') {
                $('#ctl00_MainContent_txtCurrent_Allocated_Room').val('');
                $('#<%= vlblCurrent_Allocated_Room.ClientID %>').text('No Patient Selected');
            }
            else {
                var buttonRoomAlcChk = document.getElementById('<%= btnAllocatedRoomChkTriggerBtn.ClientID%>');
                $('#<%= vlblCurrent_Allocated_Room.ClientID %>').text('Please Wait while checking Room Allocation');
                buttonRoomAlcChk.click();
            }
        }
        function bindControls() {

            var hdFile_ID = $("#hdfPatient_ID").val();
            if (hdFile_ID != "(New)") {
                var Patient_ID = document.getElementById('<%= txtPatient_ID.ClientID%>').value;
                var tokendata = httpGet("../json.aspx?Table=Patients&Record=Edit&q=" + Patient_ID);
                loadtokenInputs(JSON.parse(tokendata));
            }
            else {
                loadtokenInputsDefault();
            }
        }

        function httpGet(theUrl) {
            var xmlHttp = null;
            xmlHttp = new XMLHttpRequest();
            xmlHttp.open("GET", theUrl, false);
            xmlHttp.send(null);
            return xmlHttp.responseText;
        }

        function loadtokenInputsDefault() {
            $('#ctl00_MainContent_txtPatient_ID').tokenInput("../json.aspx?Table=Patients",
             {
                 tokenLimit: 1,
             });
        }

        function loadtokenInputs(data) {
            $("#ctl00_MainContent_txtPatient_ID").tokenInput("../json.aspx?Table=Patients",
                {
                    prePopulate: data,
                    tokenLimit: 1,
                    onAdd: function (item) {
                        $("#hdfPatient_ID").val(item.id);
                    }
                });
        }

    </script>
    <style type="text/css">
        .Error {
            color: #f00;
        }

        .Success {
            color: #4800ff;
        }

        .Checking {
            color: #00ff21;
        }

        .mg {
            padding-left: 53px;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <table style="padding: 20px; width: 695px; height: 204px;">
        <tr>
            <td style="width: 99px;">
                <asp:Label ID="lblRoom_Allocation_ID" runat="server" Text="Allocation ID"></asp:Label>
            </td>
            <td style="width: 203px;">
                <asp:TextBox ID="txtRoom_Allocation_ID" runat="server" Text="(New)" ReadOnly="true"></asp:TextBox>
            </td>
            <td style="width: 1px;"></td>
            <td style="width: 135px;" class="mg">
                <asp:Label ID="lblAssigned_To_Patient" runat="server" Text="Patient ID *"></asp:Label>
            </td>
            <td>
                <asp:TextBox ID="txtPatient_ID" runat="server" OnChange="chkAllocatedRoom()"></asp:TextBox>
                <asp:HiddenField ID="hdfPatient_ID" Value="(New)" runat="server" ClientIDMode="Static" />
            </td>
            <td>
                <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="txtPatient_ID" Display="Dynamic" Text="*" ErrorMessage="Patient ID is Required"></asp:RequiredFieldValidator>
            </td>
        </tr>
        <tr>
            <td>
                <asp:Label ID="lblCurrent_Allocated_Room" runat="server" Text="Allocated Room"></asp:Label>
            </td>
            <td>
                <asp:UpdatePanel ID="UpdatePanel4" runat="server">
                    <ContentTemplate>
                        <asp:TextBox ID="txtCurrent_Allocated_Room" runat="server" ReadOnly="true"></asp:TextBox>
                    </ContentTemplate>
                </asp:UpdatePanel>
            </td>
            <td colspan="4">
                <asp:UpdatePanel ID="UpdatePanel6" runat="server" UpdateMode="Always">
                    <ContentTemplate>
                        <asp:Label ID="vlblCurrent_Allocated_Room" runat="server" />
                    </ContentTemplate>
                </asp:UpdatePanel>
                <asp:UpdatePanel ID="UpdatePanel3" runat="server">
                    <ContentTemplate>
                        <asp:Button ID="btnAllocatedRoomChkTriggerBtn" Style="display: none;" Text="Chk Allocated Room" runat="server" OnClick="btnAllocatedRoomChkTriggerBtn_Click" CausesValidation="false" />
                    </ContentTemplate>
                </asp:UpdatePanel>
            </td>
        </tr>
        <tr>
            <td>
                <asp:Label ID="lblRoom_No" runat="server" Text="Room No. *"></asp:Label>
            </td>
            <td style="width: 205px;">
                <asp:DropDownList ID="ddlRoom_No" runat="server" AutoPostBack="true" AppendDataBoundItems="true" OnSelectedIndexChanged="ddlRoom_No_SelectedIndexChanged"></asp:DropDownList>
            </td>
            <td>
                <asp:RequiredFieldValidator ID="rfvRoom_No" ControlToValidate="ddlRoom_No" runat="server" InitialValue="0" ErrorMessage="Select Room" Text="*"></asp:RequiredFieldValidator>
            </td>
            <td colspan="3">
                <asp:UpdatePanel ID="UpdatePanel2" runat="server" UpdateMode="Conditional">
                    <ContentTemplate>
                        <asp:Label ID="vlblRoom_No" runat="server" />
                    </ContentTemplate>
                </asp:UpdatePanel>
            </td>
        </tr>

        <tr>
            <td>
                <asp:Label ID="lblRoom_Type" runat="server" Text="Room Type"></asp:Label>
            </td>
            <td style="width: 205px;">
                <asp:UpdatePanel ID="UpdatePanel1" runat="server" UpdateMode="Conditional">
                    <Triggers>
                        <asp:AsyncPostBackTrigger ControlID="ddlRoom_No" EventName="SelectedIndexChanged" />
                    </Triggers>
                    <ContentTemplate>
                        <asp:TextBox ID="txtRoom_Type" runat="server" ReadOnly="true"></asp:TextBox>
                    </ContentTemplate>
                </asp:UpdatePanel>
            </td>
            <td></td>
            <td class="mg">
                <asp:Label ID="lblRoom_Charges" runat="server" Text="Charges/Day"></asp:Label>
            </td>
            <td style="width: 205px;">
                <asp:UpdatePanel ID="upCharges" runat="server" UpdateMode="Conditional">
                    <Triggers>
                        <asp:AsyncPostBackTrigger ControlID="ddlRoom_No" EventName="SelectedIndexChanged" />
                    </Triggers>
                    <ContentTemplate>
                        <asp:TextBox ID="txtRoom_Charges" runat="server" ReadOnly="true"></asp:TextBox>
                    </ContentTemplate>
                </asp:UpdatePanel>
            </td>
            <td>
                <asp:UpdateProgress ID="UpdateProgress1" runat="server">
                    <ProgressTemplate>
                        <div class="loadingimage">
                            <asp:Image ID="image1" ImageUrl="~/images/loading.gif" runat="server" Width="32px" />
                        </div>
                    </ProgressTemplate>
                </asp:UpdateProgress>
            </td>
        </tr>
        <tr>
            <td>
                <asp:Label ID="lblFrom_Date" runat="server" Text="From Date *"></asp:Label>
            </td>
            <td style="width: 205px;">
                <asp:TextBox ID="txtFrom_Date" runat="server"></asp:TextBox>
            </td>
            <td>
                <asp:RequiredFieldValidator ID="rfvFrom_Date" runat="server" ControlToValidate="txtFrom_Date" Text="*" Display="Dynamic" ErrorMessage="From Date Required"></asp:RequiredFieldValidator>
            </td>
            <td class="mg">
                <asp:Label ID="lblTo_Date" runat="server" Text="To Date *"></asp:Label>
            </td>
            <td style="width: 205px;">
                <asp:TextBox ID="txtTo_Date" runat="server"></asp:TextBox>
            </td>
            <td>
                <asp:RequiredFieldValidator ID="rfvTo_Date" runat="server" ControlToValidate="txtTo_Date" Text="*" Display="Dynamic" ErrorMessage="To Date Required"></asp:RequiredFieldValidator>
            </td>
        </tr>
        <tr>
            <td>
                <asp:Label ID="lblRemarks" runat="server" Text="Remarks"></asp:Label>
            </td>
            <td colspan="5">
                <asp:TextBox ID="txtRemarks" runat="server" TextMode="MultiLine" Width="93%" Height="87"></asp:TextBox>
            </td>
        </tr>
        <tr>
            <td></td>
            <td colspan="5">
                <br />
                <asp:Button ID="btnBack" Width="95px" runat="server" CssClass="btn-yellow" Text="List View" CausesValidation="false" PostBackUrl="~/RoomAllocationView.aspx" />
                &nbsp;
                <asp:Button ID="btnSave" Width="95px" runat="server" CssClass="btn btn-primry" Text="Save" OnClick="btnSave_Click" />
            </td>
        </tr>
        <tr>
            <td colspan="6">
                <asp:Label ID="lblMessage" Text="" runat="server" />
            </td>
        </tr>
        <tr>
            <td colspan="6">
                <asp:ValidationSummary ID="ValidationSummary1" HeaderText="Page Errors" ShowSummary="true" DisplayMode="List" runat="server" />
            </td>
        </tr>
    </table>
</asp:Content>
