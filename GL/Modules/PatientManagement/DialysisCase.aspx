<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="DialysisCase.aspx.cs" Inherits="PMS.DialysisCase" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

    <script type="text/javascript">

        $(document).ready(function () {
            bindControls();
            bindDate();
        });

        function bindDate() {
            $("#ctl00_MainContent_txtTreatment_From").datepicker({ dateFormat: 'mm/dd/yy' });
            $("#ctl00_MainContent_txtTreatment_To").datepicker({ dateFormat: 'mm/dd/yy' });
        }

        function bindControls() {

            var hdFile_ID = $("#hdfPatient_ID").val();
            if (hdFile_ID != "(New)") {
                var Patient_ID = document.getElementById('<%= txtPatient_ID.ClientID%>').value;
                var tokendata = httpGet("../../json.aspx?Table=Patients&Record=Edit&q=" + Patient_ID);
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
            $('#ctl00_MainContent_txtPatient_ID').tokenInput("../../json.aspx?Table=Patients",
             {
                 tokenLimit: 1,
             });
        }

        function loadtokenInputs(data) {
            $("#ctl00_MainContent_txtPatient_ID").tokenInput("../../json.aspx?Table=Patients",
                {
                    prePopulate: data,
                    tokenLimit: 1,
                    onAdd: function (item) {
                        $("#hdfPatient_ID").val(item.id);
                    }
                });
        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <table style="padding: 20px; width: 835px;">
        <tr>
            <td style="width: 99px;">
                <asp:Label ID="lblDialysis_Case_ID" runat="server" Text="Case ID"></asp:Label>
            </td>
            <td style="width: 204px;">
                <asp:TextBox ID="txtDialysis_Case_ID" runat="server" ReadOnly="true" Text="(New)" />
            </td>
            <td style="width: 67px;"></td>
            <td style="width: 87px;">
                <asp:Label ID="lblPatient_ID" runat="server" Text="Patient ID *"></asp:Label>
            </td>
            <td style="width: 204px;">
                <asp:TextBox ID="txtPatient_ID" runat="server"></asp:TextBox>
                <asp:HiddenField ID="hdfPatient_ID" Value="(New)" runat="server" ClientIDMode="Static" />
            </td>
            <td>
                <asp:RequiredFieldValidator ID="rfvPatient_ID" runat="server" ControlToValidate="txtPatient_ID" Display="Dynamic" Text="*" ErrorMessage="Patient ID is Required" ></asp:RequiredFieldValidator>
            </td>
        </tr>

        <tr>
            <td>
                <asp:Label ID="lblHeight_Cm" runat="server" Text="Height"></asp:Label>
            </td>
            <td>
                <asp:TextBox ID="txtHeight_Cm" runat="server" />
            </td>
            <td>
               

                <asp:RangeValidator ID="rngHeight_Cm" Type="Double" runat="server" MinimumValue="1" MaximumValue="1000" ControlToValidate="txtHeight_Cm" ErrorMessage="Enter Proper Height" Text="*"></asp:RangeValidator>
            </td>
            <td>
                <asp:Label ID="lblWeight_Kg" runat="server" Text="Weight"></asp:Label>
            </td>
            <td>
                <asp:TextBox ID="txtWeight_Kg" runat="server" />
            </td>
            <td>
               
                <asp:RangeValidator ID="rngWeight_Kg" Type="Double" runat="server" MinimumValue="1" MaximumValue="1000" ControlToValidate="txtWeight_Kg" ErrorMessage="Enter Proper Weight" Text="*"></asp:RangeValidator>
            </td>
        </tr>

        <tr>
            <td>
                <asp:Label ID="lblTreatment_From" runat="server" Text="Treatment From *"></asp:Label>
            </td>
            <td>
                <asp:TextBox ID="txtTreatment_From" runat="server" />
            </td>
            <td>
                <asp:RequiredFieldValidator ID="rfvTreatment_From" ControlToValidate="txtTreatment_From" runat="server" ErrorMessage="Enter Treatment From" Text="*"></asp:RequiredFieldValidator>
            </td>
            <td>
                <asp:Label ID="lblTreatment_To" runat="server" Text="Treatment To *"></asp:Label>
            </td>
            <td>
                <asp:TextBox ID="txtTreatment_To" runat="server" />
            </td>
            <td>
                <asp:RequiredFieldValidator ID="rfvTreatment_To" ControlToValidate="txtTreatment_To" runat="server" ErrorMessage="Enter Treatment To" Text="*"></asp:RequiredFieldValidator>
            </td>
        </tr>

        <tr>
            <td>
                <asp:Label ID="lblVisits_Per_Week" runat="server" Text="Visits/Week *"></asp:Label>
            </td>
            <td>
                <asp:TextBox ID="txtVisits_Per_Week" runat="server" />
            </td>
            <td>
                <asp:RequiredFieldValidator ID="rfvVisits_Per_Week" ControlToValidate="txtVisits_Per_Week" runat="server" ErrorMessage="Enter Visits Per Week" Text="*"></asp:RequiredFieldValidator>
            </td>
            <td>
                <asp:Label ID="lblDialysis_Charges" runat="server" Text="Case Charges *"></asp:Label>
            </td>
            <td>
                <asp:TextBox ID="txtDialysis_Charges" runat="server" />
            </td>
            <td>
                <asp:RequiredFieldValidator ID="rfvDialysis_Charges" ControlToValidate="txtDialysis_Charges" runat="server" ErrorMessage="Enter Case Charges" Text="*"></asp:RequiredFieldValidator>
                <asp:RangeValidator ID="rngDialysis_Charges" Type="Double" runat="server" MinimumValue="0" MaximumValue="99999999" ControlToValidate="txtDialysis_Charges" ErrorMessage="Enter Proper Charges Format" Text="*"></asp:RangeValidator>
            </td>
        </tr>

        <tr>
            <td></td>
            <td>
                <br />
                <asp:Button Text="Back" Width="95px" runat="server" ID="btnBack" CausesValidation="false" PostBackUrl="~/DialysisCaseView.aspx" />
                &nbsp;
                <asp:Button Text="Save" Width="95px" runat="server" ID="btnSave" OnClick="btnSave_Click" />
            </td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
        </tr>

        <tr>
            <td colspan="6">
                <asp:Label ID="lblMessage" Text="" runat="server" />
            </td>
        </tr>

        <tr>
            <td colspan="6">
                <asp:ValidationSummary ID="ValidationSummary1" runat="server" ForeColor="Red" HeaderText="Page Errors"
                    ShowSummary="true" DisplayMode="List" />
            </td>
        </tr>

    </table>
</asp:Content>
