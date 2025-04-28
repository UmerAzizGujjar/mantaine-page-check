<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ChildBirth.aspx.cs" Inherits="PMS.ChildBirth" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="Styles/jquery.ptTimeSelect.css" rel="stylesheet" />
    <script type="text/javascript" src="Scripts/jquery.ptTimeSelect.js"></script>
    <script type="text/javascript" src="../Scripts/jquery.tokeninput.js"></script>
    <script type="text/javascript">
        $(function () {
            Sys.WebForms.PageRequestManager.getInstance().add_pageLoaded(function (evt, args) {
                $("#ctl00_MainContent_txtDOB").datepicker({ dateFormat: 'mm/dd/yy' });
                $("#ctl00_MainContent_txtDischarged_On").datepicker({ dateFormat: 'mm/dd/yy' });
                $("#ctl00_MainContent_txtTOB").ptTimeSelect({});

                bindControls();
                enabledisable();
            });
        });

        function bindControls() {
            enabledisable();
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

        function hide() {
          
            $('#child2a').hide();
            $('#child2b').hide();
            $('#child2c').hide();
            $('#child3a').hide();
            $('#child3b').hide();
            $('#child3c').hide();

            var baby2Validation = document.getElementById('<%= rfvBaby2_Gender.ClientID %>');
            ValidatorEnable(baby2Validation, false);

            var baby3Validation = document.getElementById('<%= rfvBaby3_Gender.ClientID %>');
            ValidatorEnable(baby3Validation, false);
        }

        function show2() {
            $('#child2a').show();
            $('#child2b').show();
            $('#child2c').show();

            $('#child3a').hide();
            $('#child3b').hide();
            $('#child3c').hide();

            var baby2Validation = document.getElementById('<%= rfvBaby2_Gender.ClientID %>');
            ValidatorEnable(baby2Validation, true);

            var baby3Validation = document.getElementById('<%= rfvBaby3_Gender.ClientID %>');
            ValidatorEnable(baby3Validation, false);
        }

        function show3() {
            $('#child2a').show();
            $('#child2b').show();
            $('#child2c').show();
            $('#child3a').show();
            $('#child3b').show();
            $('#child3c').show();

            var baby2Validation = document.getElementById('<%= rfvBaby2_Gender.ClientID %>');
            ValidatorEnable(baby2Validation, true);

            var baby3Validation = document.getElementById('<%= rfvBaby3_Gender.ClientID %>');
            ValidatorEnable(baby3Validation, true);
        }

        function enabledisable() {
          
            var baby_qty = document.getElementById('<%= ddlNo_Of_Babies.ClientID %>').value;
            
            //$('#ctl00_MainContent_txtPatient_ID').tokenInput("toggleDisabled");

            if (baby_qty == 001) {
                hide();
            }
            else if (baby_qty == 002) {
                show2();
            }
            else {
                show3();
            }

            return true;
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
        .mg {
            padding-left:67px;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <table style="padding: 20px; width: 835px; height: 210px;">

        <tr>
            <td style="width:103px;">
                <asp:Label ID="lblEnrollment_ID" runat="server" Text="Birth ID"></asp:Label>
            </td>
            <td style="width:205px;">
                <asp:TextBox runat="server" ID="txtEnrollment_ID" ReadOnly="true" Text="(New)" />
            </td>
            <td></td>
            <td class="mg">
                <asp:Label ID="lblPatient_ID" runat="server" Text="Mother Name * (Patient ID)"></asp:Label>
            </td>
            <td style="width:205px;">
                <asp:TextBox ID="txtPatient_ID" runat="server" />
                <asp:HiddenField ID="hdfPatient_ID" Value="(New)" runat="server" ClientIDMode="Static" />
            </td>
            <td>
                <asp:RequiredFieldValidator ID="rfvPatient_ID" ControlToValidate="txtPatient_ID" runat="server" ErrorMessage="Select Mother Name" Text="*"></asp:RequiredFieldValidator>
            </td>
        </tr>

        <tr>
            <td>
                <asp:Label ID="lblFather_Name" runat="server" Text="Father Name *"></asp:Label>
            </td>
            <td>
                <asp:TextBox ID="txtFather_Name" runat="server" />
            </td>
            <td>
                <asp:RequiredFieldValidator ID="rfvFather_Name" ControlToValidate="txtFather_Name" runat="server" ErrorMessage="Enter Father Name" Text="*"></asp:RequiredFieldValidator>
            </td>
            <td class="mg">
                <asp:Label ID="lblNo_Of_Babies" runat="server" Text="No. Of Babies"></asp:Label>
            </td>
            <td>
                <asp:DropDownList ID="ddlNo_Of_Babies" runat="server" AppendDataBoundItems="true" onChange="enabledisable();" ></asp:DropDownList>
            </td>
            <td></td>
            <%--<td class="mg">
                <asp:Label ID="lblBaby_Name" runat="server" Text="Baby Name"></asp:Label>
            </td>
            <td style="width:205px;">
                <asp:TextBox ID="txtBaby_Name" runat="server" />
            </td>
            <td></td>--%>
        </tr>

        <tr>
            <td>
                <asp:Label ID="lblBaby1_Gender" runat="server" Text="Baby 1 Gender *"></asp:Label>
            </td>
            <td>
                <asp:DropDownList ID="ddlBaby1_Gender" runat="server" AppendDataBoundItems="true"  ></asp:DropDownList>
            </td>
            <td>
                <asp:RequiredFieldValidator ID="rfvBaby1_Gender" ControlToValidate="ddlBaby1_Gender" runat="server" InitialValue="0" ErrorMessage="Select Baby 1 Gender" Text="*"></asp:RequiredFieldValidator>
            </td>
            <td class="mg" id="child2a">
                <asp:Label ID="lblBaby2_Gender" runat="server" Text="Baby 2 Gender *"></asp:Label>
            </td>
            <td id="child2b">
                <asp:DropDownList ID="ddlBaby2_Gender" runat="server" AppendDataBoundItems="true"  ></asp:DropDownList>
            </td>
            <td id="child2c">
                <asp:RequiredFieldValidator ID="rfvBaby2_Gender" ControlToValidate="ddlBaby2_Gender" runat="server" InitialValue="0" ErrorMessage="Select Baby 2 Gender" Text="*"></asp:RequiredFieldValidator>
            </td>
        </tr>

        <tr>
            <td id="child3a">
                <asp:Label ID="lblBaby3_Gender" runat="server" Text="Baby 3 Gender *"></asp:Label>
            </td>
            <td id="child3b">
                <asp:DropDownList ID="ddlBaby3_Gender" runat="server" AppendDataBoundItems="true"  ></asp:DropDownList>
            </td>
            <td  id="child3c" colspan="4">
                <asp:RequiredFieldValidator ID="rfvBaby3_Gender" ControlToValidate="ddlBaby3_Gender" runat="server" InitialValue="0" ErrorMessage="Select Baby 3 Gender" Text="*"></asp:RequiredFieldValidator>
            </td>
        </tr>

        <tr>
            <td>
                <asp:Label ID="lblDOB" runat="server" Text="Date of Birth"></asp:Label>
            </td>
            <td>
                <asp:TextBox ID="txtDOB" runat="server" />
            </td>
            <td></td>
            <td class="mg">
                <asp:Label ID="lblTOB" runat="server" Text="Time of Birth"></asp:Label>
            </td>
            <td>
                <asp:TextBox ID="txtTOB" runat="server" />
            </td>
            <td></td>
        </tr>

        <tr>
            <td>
                <asp:Label ID="lblBirth_Condition" runat="server" Text="Birth Condition"></asp:Label>
            </td>
            <td>
                <asp:DropDownList ID="ddlBirth_Condition" runat="server" AppendDataBoundItems="true"  ></asp:DropDownList>
            </td>
            <td></td>
            <td class="mg">
                <asp:Label ID="lblPhysical_Condition" runat="server" Text="Physical Condition"></asp:Label>
            </td>
            <td>
                <asp:DropDownList ID="ddlPhysical_Condition" runat="server" AppendDataBoundItems="true" ></asp:DropDownList>
            </td>
            <td></td>
        </tr>

        <tr>
            <td>
                <asp:Label ID="lblOperated_By" runat="server" Text="Operated By"></asp:Label>
            </td>
            <td>
                <asp:DropDownList ID="ddlOperated_By" runat="server" AppendDataBoundItems="true" ></asp:DropDownList>
            </td>
            <td></td>
            <td class="mg">
                <asp:Label ID="lblDischarged_On" runat="server" Text="Discharged On"></asp:Label>
            </td>
            <td>
                <asp:TextBox ID="txtDischarged_On" runat="server" />
            </td>
            <td></td>
        </tr>

        <tr>
            <td>
                <asp:Label ID="lblDelivery_Type" runat="server" Text="Delivery Type *"></asp:Label>
            </td>
            <td>
                <asp:DropDownList ID="ddlDelivery_Type" runat="server" AppendDataBoundItems="true" ></asp:DropDownList>
            </td>
            <td>
                <asp:RequiredFieldValidator ID="rfvDelivery_Type" ControlToValidate="ddlDelivery_Type" InitialValue="0" runat="server" ErrorMessage="Select Delivery Type" Text="*"></asp:RequiredFieldValidator>
            </td>
            <td class="mg">
                <asp:Label ID="lblDelivery_Charges" runat="server" Text="Delivery Charges *"></asp:Label>
            </td>
            <td>
                <asp:TextBox ID="txtDelivery_Charges" runat="server" />
            </td>
            <td>
                <asp:RequiredFieldValidator ID="rfvDelivery_Charges" ControlToValidate="txtDelivery_Charges" runat="server" ErrorMessage="Enter Charges" Text="*"></asp:RequiredFieldValidator>
                <asp:RangeValidator ID="rngDelivery_Charges" Type="Double" runat="server" MinimumValue="0" MaximumValue="9999999999999999999999" ControlToValidate="txtDelivery_Charges" ErrorMessage="Only Enter Integer Values" Text="*"></asp:RangeValidator>
            </td>
        </tr>

        <tr>
            <td></td>
            <td>
                <br />
                <asp:Button Text="Back" Width="95px" runat="server" ID="btnBack" CausesValidation="false" PostBackUrl="~/ChildBirthView.aspx" />
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
