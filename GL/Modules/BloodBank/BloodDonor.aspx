<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="BloodDonor.aspx.cs" Inherits="PMS.BloodDonor" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script type="text/javascript">
        $(function () {
            Sys.WebForms.PageRequestManager.getInstance().add_pageLoaded(function (evt, args) {
                $("#ctl00_MainContent_txtDonation_Date").datepicker({ dateFormat: 'mm/dd/yy' });
                $("#ctl00_MainContent_txtDOB").datepicker({ dateFormat: 'mm/dd/yy' });
                $("#ctl00_MainContent_txtExpiryDate").datepicker({ dateFormat: 'mm/dd/yy' });
                $("#ctl00_MainContent_txtDateOfLastDonation").datepicker({ dateFormat: 'mm/dd/yy' });
            });
        });

    </script>


    <script type="text/javascript">

        function httpGet(theUrl) {
            var xmlHttp = null;
            xmlHttp = new XMLHttpRequest();
            xmlHttp.open("GET", theUrl, false);
            xmlHttp.send(null);
            return xmlHttp.responseText;
        }
        function bindControls() {

            var hdFile_ID = $("#hdnDonee_ID").val();

            if (hdFile_ID != "(New)") {

                var Patient_ID = $("#hdnDonee_ID").val();
                var tokendata = httpGet("json.aspx?Table=Patients&Record=Edit&q=" + Patient_ID);
                loadtokenInputs(JSON.parse(tokendata));

            }
            else {
                loadtokenInputsDefault();
            }
        }
        function loadtokenInputsDefault() {
            $('#ctl00_MainContent_txtDonee_Name').tokenInput("json.aspx?Table=Patients",
             {
                 tokenLimit: 1,
                 onAdd: function (item) {
                     try {
                         $("#hdnDonee_ID").val(item.id);
                     }
                     catch (err) {
                         alert(err.message);
                     }

                 }
             });
        }
        function loadtokenInputs(data) {
            $("#ctl00_MainContent_txtDonee_Name").tokenInput("../json.aspx?Table=Patients",
                {
                    prePopulate: data,
                    tokenLimit: 1,
                    onAdd: function (item) {
                        $("#hdnDonee_ID").val(item.id);
                    }
                });
        }

        $(document).ready(function () {
            bindControls();
            $('#ctl00_MainContent_txtDonee_Name').on("change", function () {
                if ($(this).val()=="")
                {
                    $("#hdnDonee_ID").val('');
                }
            });
        });

        function PrintReport() {

            PageMethods.PrintReport('Test',function (data) {
                console.log(data);
            });

        }


    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <table style="padding: 20px; width: 1150px; height: 200px;">

        <tr>
            <td style="width: 150px;">
                <asp:Label ID="lblBlood_Donor_ID" runat="server" Text="Donation ID"></asp:Label>
            </td>
            <td style="width: 203px;">
                <asp:TextBox ID="txtBlood_Donor_ID" runat="server" ReadOnly="true" Text="(New)" />
            </td>
            <td></td>
            <td class="mg">
                <asp:Label ID="lblDonor_Name" runat="server" Text="Donor Name"></asp:Label>
            </td>
            <td style="width: 203px;">
                <asp:TextBox ID="txtDonor_Name" runat="server" />
            </td>
            <td class="mg">
                <asp:Label ID="Label2" runat="server" Text="S.O,D/O,W/O"></asp:Label>
            </td>
            <td style="width: 203px;">
                <asp:TextBox ID="txtFatherName" runat="server" />
            </td>
        </tr>

        <tr>
            <td>
                <asp:Label ID="lblBlood_Group" runat="server" Text="Blood Group *"></asp:Label>
            </td>
            <td style="width: 203px;">
                <asp:DropDownList ID="ddlBlood_Group" runat="server" AppendDataBoundItems="true">
                </asp:DropDownList>
            </td>
            <td>
                <asp:RequiredFieldValidator ID="rfvBlood_Group" ControlToValidate="ddlBlood_Group" InitialValue="0" runat="server" ErrorMessage="Select Blood Group" Text="*"></asp:RequiredFieldValidator>
            </td>
            <td class="mg">
                <asp:Label ID="lblNo_Of_Bags" runat="server" Text="No. Of Bags *"></asp:Label>
            </td>
            <td style="width: 203px;">
                <asp:TextBox ID="txtNo_Of_Bags" runat="server"></asp:TextBox>
                 <asp:RequiredFieldValidator ID="rfvNo_Of_Bags" ControlToValidate="txtNo_Of_Bags" runat="server" ErrorMessage="Enter No. of Bags" Text="*"></asp:RequiredFieldValidator>
            <asp:RangeValidator ID="RangeValidator1" runat="server" MinimumValue="0" MaximumValue="999999999999999999999999999999999999" ControlToValidate="txtNo_Of_Bags" ErrorMessage="Only Enter Integer Values"></asp:RangeValidator>
            </td>

           
            <td class="mg">
                <asp:Label ID="Label3" runat="server" Text="C.N.I.C No"></asp:Label>
            </td>
            <td style="width: 203px;">
                <asp:TextBox ID="txtCNIC" runat="server" />
            </td>
        </tr>

        <tr>
            <td>
                <asp:Label ID="lblDonation_Date" runat="server" Text="Donation Date"></asp:Label>
            </td>
            <td style="width: 203px;">
                <asp:TextBox ID="txtDonation_Date" runat="server"></asp:TextBox>
            </td>
            <td></td>
            <td class="mg">
                <asp:Label ID="lblExpiryDate" runat="server" Text="Expiry Date"></asp:Label>
            </td>
            <td style="width: 203px;">
                <asp:TextBox ID="txtExpiryDate" runat="server"></asp:TextBox>
            </td>

            <td class="mg">
                <asp:Label ID="Label4" runat="server" Text="Occupation"></asp:Label>
            </td>
            <td style="width: 203px;">
                <asp:TextBox ID="txtOccupation" runat="server" />
            </td>
        </tr>

        <tr>
            <td>
                <asp:Label ID="lblAddress" runat="server" Text="Address"></asp:Label>
            </td>
            <td style="width: 203px;">
                <asp:TextBox ID="txtAddress" runat="server"></asp:TextBox>
            </td>
            <td></td>
            <td class="mg">
                <asp:Label ID="lblMobile" runat="server" Text="Mobile"></asp:Label>
            </td>
            <td style="width: 203px;">
                <asp:TextBox ID="txtMobile" runat="server"></asp:TextBox>
            </td>
            <td class="mg">
                <asp:Label ID="Label5" runat="server" Text="State Of Health"></asp:Label>
            </td>
            <td style="width: 203px;">
                <asp:TextBox ID="txtStateOfHealth" runat="server" />
            </td>
        </tr>

        <tr>
            <td>
                <asp:Label ID="lblGender" runat="server" Text="Gender *"></asp:Label>
            </td>
            <td style="width: 203px;">
                <asp:DropDownList ID="ddlGender" runat="server" AppendDataBoundItems="true">
                </asp:DropDownList>
            </td>
            <td>
                <asp:RequiredFieldValidator ID="rfvGender" ControlToValidate="ddlGender" InitialValue="0" runat="server" ErrorMessage="Select Gender" Text="*"></asp:RequiredFieldValidator>
            </td>
            <td class="mg">
                <asp:Label ID="lblDOB" runat="server" Text="DOB"></asp:Label>
            </td>
            <td style="width: 203px;">
                <asp:TextBox ID="txtDOB" runat="server"></asp:TextBox>
            </td>
            <td class="mg">
                <asp:Label ID="Label6" runat="server" Text="Center Of Donation"></asp:Label>
            </td>
            <td style="width: 203px;">
                <asp:TextBox ID="txtCenterOfDonation" runat="server" />
            </td>
        </tr>

        <tr>
            <td>
                <asp:Label ID="lblDonee_Name" runat="server" Text="Donee Name"></asp:Label>
            </td>
            <td style="width: 203px;">
                <asp:TextBox ID="txtDonee_Name" runat="server"></asp:TextBox>
                <asp:HiddenField ID="hdnDonee_ID" runat="server" ClientIDMode="Static" Value="(New)" />
            </td>
            <td></td>
            <td class="mg">
                <asp:Label ID="Label1" runat="server" Text="Email"></asp:Label>
            </td>
            <td style="width: 203px;">
                <asp:TextBox ID="txtEmail" runat="server"></asp:TextBox>
                 <asp:RegularExpressionValidator ID="RegularExpressionValidator1"
                runat="server" ErrorMessage="Enter Valid Format"
                ControlToValidate="txtEmail" ForeColor="Red"
                ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*"
                Text="*"> </asp:RegularExpressionValidator>
            </td>

           
            <td class="mg">
                <asp:Label ID="Label7" runat="server" Text="Date Of Last Donation"></asp:Label>
            </td>
            <td style="width: 203px;">
                <asp:TextBox ID="txtDateOfLastDonation" runat="server" />
            </td>
        </tr>

        <tr>
            <td>
                <asp:Label ID="lblRemarks" runat="server" Text="Remarks"></asp:Label>
            </td>
            <td style="width: 203px;">
                <asp:TextBox ID="txtRemarks" runat="server" TextMode="MultiLine" Width="200" Height="60"></asp:TextBox>
            </td>
            <td></td>
            <td class="mg">
                <asp:Label ID="lblBlood_Condition" runat="server" Text="Blood Condition"></asp:Label>
            </td>
            <td style="width: 203px;">
                <asp:TextBox ID="txtBlood_Condition" runat="server" TextMode="MultiLine" Width="200" Height="60"></asp:TextBox>
            </td>

        </tr>

        <tr>
            <td>
                <asp:Label ID="lblBlood_Pre_Sceening" runat="server" Text="Blood Pre-Sceened"></asp:Label>
            </td>
            <td style="width: 203px;">
                <asp:CheckBox ID="ChkBlood_Pre_Sceening" runat="server" />
            </td>
            <td></td>
            <td class="mg">
                <asp:Label ID="Label8" runat="server" Text="Age"></asp:Label>
            </td>
            <td style="width: 203px;">
                <asp:TextBox ID="txtAge" runat="server" TextMode="SingleLine"></asp:TextBox>
                 <asp:RangeValidator ID="RangeValidator2" runat="server" MinimumValue="0" MaximumValue="999999999999999999999999999999999999" ControlToValidate="txtAge" ErrorMessage="Only Enter Integer Values"></asp:RangeValidator>
            </td>
        </tr>

        <tr>
            <td></td>
            <td colspan="6">
                <br />
                <div class="col-lg-2 col-md-6 col-sm-6">
                <asp:Button Text="New" CssClass="btn btn-yellow" runat="server" ID="btnNew" CausesValidation="false" OnClick="btnNew_Click" />
                &nbsp;
                    </div>
                <div class="col-lg-2 col-md-6 col-sm-6">
                <asp:Button Text="Back" CssClass="btn btn-yellow" runat="server" ID="btnBack" CausesValidation="false" PostBackUrl="~/Modules/BloodBank/BloodDonorView.aspx" />
                &nbsp;
                    </div>
                <div class="col-lg-2 col-md-6 col-sm-6">
                 <asp:Button Text="Save" CssClass="btn btn-primry" runat="server" ID="btnSave" OnClick="btnSave_Click" />
                &nbsp;                   
                &nbsp;
                    </div>
                 <div class="col-lg-2 col-md-6 col-sm-6">
                 <asp:Button Text="Print" CssClass="btn btn-primry" runat="server" ID="btnPrint" CausesValidation="false" OnClick="btnPrint_Click" />
                &nbsp;
                     </div>
                <div class="col-lg-3 col-md-6 col-sm-6">
                 <asp:Button Text="Compatibility Report" CssClass="btn btn-primry"  runat="server" ID="btnCompatibilityReport" CausesValidation="false" OnClick="btnCompatibilityReport_Click" />
                    </div>
            </td>

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

    <div style="width: 100%; border: 1px solid red; display:none; " id="dvReport">
        <div id="Header">
            <div id="Logo">
                <image src="images/HMIS_Icons/CPHLogoLatest.png" width="80px" height="80px"></image>
            </div>
            <h6 style="margin-left: 110px; margin-top: -65px; font-size: 18px; font-weight: bold">CENTRAL PARK TEACHING HOSPITAL LAHORE</h6>
            <h6 style="margin-left: 217px; margin-top: -37px; font-size: 16px;">DONOR HISTORY CARD</h6>
            <span style="font-size: 14px;">Registration No </span>  <h4 style="margin-left: 94px; margin-top: -21px; font-size: 14px;border-bottom: 1px dotted #000; width:100px; text-align:center;"> <span id="regno">1240</span></h4>
            <h4 style=" margin-top: -35px; font-size: 14px; margin-left:450px;">Date</h4>
             <h4 style=" margin-top: -39px; font-size: 14px;border-bottom: 1px dotted #000; margin-left:482px; width:180px; text-align:center;"> <span id="Span1"> '8/12/2016 12:00:00 AM' </span></h4>
           <b> <hr /></b>
        </div>
        

        

       

    </div>

</asp:Content>
