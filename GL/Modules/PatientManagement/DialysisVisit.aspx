<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="DialysisVisit.aspx.cs" Inherits="PMS.DialysisVisit" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script type="text/javascript">

        $(document).ready(function () {
            Combination();
        });

        function Combination() {
            TabFunction();
            bindDate();
            chkService_Select();
        }

        function bindDate() {
            $("#ctl00_MainContent_txtVisit_Date").datepicker({ dateFormat: 'mm/dd/yy' });
        }

        function chkService_Select() {
            var Service_Val = document.getElementById('<%= ddlService.ClientID%>').value;

            if (Service_Val == 0) {
                $("#ctl00_MainContent_btnAddService").attr('disabled', true);
            }
            else {
                $('#ctl00_MainContent_btnAddService').prop("disabled", false);
            }
        }
        
        function TabFunction() {
            $("#tabs").tabs();
        };

    </script>
     <style type="text/css">
        .header-center {
            text-align: center;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <asp:UpdatePanel runat="server" ID="UpdatePanel6" UpdateMode="Conditional">
        <Triggers>
            <asp:AsyncPostBackTrigger EventName="Click" ControlID="btnNew" />
            <asp:AsyncPostBackTrigger EventName="Click" ControlID="btnSave" />
        </Triggers>
        <ContentTemplate>
            <div style="width: 100%">
                <div id="tabs">
                    <ul>
                        <li><a href="#Tab-1">Visit Details</a></li>
                        <li><a href="#Tab-2">Services</a></li>
                    </ul>

                    <div id="Tab-1">
                        <div id="VisitDetails" style="width: 90%">
                            <table style="padding: 20px; width: 835px;">

                                <tr>
                                    <td colspan="6">
                                        <h2>Visit Details : </h2>
                                    </td>
                                </tr>

                                <tr>
                                    <td style="width: 99px;">
                                        <asp:Label ID="lblDialysis_Visit_ID" runat="server" Text="Visit ID"></asp:Label>
                                    </td>
                                    <td style="width: 204px;">
                                        <asp:TextBox ID="txtDialysis_Visit_ID" runat="server" ReadOnly="true" Text="(New)" />
                                    </td>
                                    <td style="width: 67px;"></td>
                                    <td style="width: 99px;">
                                        <asp:Label ID="lblDialysis_Case" runat="server" Text="Dialysis Case *"></asp:Label>
                                    </td>
                                    <td style="width: 204px;">
                                        <asp:DropDownList ID="ddlDialysis_Case" runat="server" AppendDataBoundItems="true"></asp:DropDownList>
                                    </td>
                                    <td>
                                        <asp:RequiredFieldValidator ID="rfvDialysis_Case" ControlToValidate="ddlDialysis_Case" runat="server" InitialValue="0" ErrorMessage="Select Dialysis Case" Text="*"></asp:RequiredFieldValidator>
                                    </td>
                                </tr>

                                <tr>
                                    <td>
                                        <asp:Label ID="lblDoctor" runat="server" Text="Doctor *"></asp:Label>
                                    </td>
                                    <td>
                                        <asp:DropDownList ID="ddlDoctor" runat="server" AppendDataBoundItems="true"></asp:DropDownList>
                                    </td>
                                    <td>
                                        <asp:RequiredFieldValidator ID="rfvDoctor" ControlToValidate="ddlDoctor" runat="server" InitialValue="0" ErrorMessage="Select Doctor" Text="*"></asp:RequiredFieldValidator>
                                    </td>
                                    <td>
                                        <asp:Label ID="lblDialysis_Type" runat="server" Text="Dialysis Type *"></asp:Label>
                                    </td>
                                    <td>
                                        <asp:DropDownList ID="ddlDialysis_Type" runat="server" AppendDataBoundItems="true"></asp:DropDownList>
                                    </td>
                                    <td>
                                        <asp:RequiredFieldValidator ID="rfvDialysis_Type" ControlToValidate="ddlDialysis_Type" runat="server" InitialValue="0" ErrorMessage="Select Dialysis Type" Text="*"></asp:RequiredFieldValidator>
                                    </td>
                                </tr>

                                <tr>
                                    <td>
                                        <asp:Label ID="lblPhosphataemia_mg_dl" runat="server" Text="Phosphataemia"></asp:Label>
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtPhosphataemia_mg_dl" runat="server" />
                                    </td>
                                    <td>
                                        <asp:RangeValidator ID="rngPhosphataemia_mg_dl" Type="Double" runat="server" MinimumValue="-99999" MaximumValue="99999" ControlToValidate="txtPhosphataemia_mg_dl" ErrorMessage="Enter Proper Phosphataemia Value" Text="*"></asp:RangeValidator>
                                    </td>
                                    <td>
                                        <asp:Label ID="lblCalcaemia_mg_dl" runat="server" Text="Calcaemia"></asp:Label>
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtCalcaemia_mg_dl" runat="server" />
                                    </td>
                                    <td>
                                        <asp:RangeValidator ID="rngCalcaemia_mg_dl" Type="Double" runat="server" MinimumValue="-99999" MaximumValue="99999" ControlToValidate="txtCalcaemia_mg_dl" ErrorMessage="Enter Proper Calcaemia Value" Text="*"></asp:RangeValidator>
                                    </td>
                                </tr>

                                <tr>
                                    <td>
                                        <asp:Label ID="lblDialyzer" runat="server" Text="Dialyzer"></asp:Label>
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtDialyzer" runat="server" />
                                    </td>
                                    <td></td>
                                    <td>
                                        <asp:Label ID="lblBlood_Pressure_mmHg" runat="server" Text="Blood Pressure"></asp:Label>
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtBlood_Pressure_mmHg" runat="server" />
                                    </td>
                                    <td>
                                        <asp:RangeValidator ID="rngBlood_Pressure_mmHg" Type="Double" runat="server" MinimumValue="-99999" MaximumValue="99999" ControlToValidate="txtBlood_Pressure_mmHg" ErrorMessage="Enter Proper Blood Pressure Value" Text="*"></asp:RangeValidator>
                                    </td>
                                </tr>

                                <tr>
                                    <td>
                                        <asp:Label ID="lblAllergies" runat="server" Text="Allergies"></asp:Label>
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtAllergies" runat="server" TextMode="MultiLine" Height="99" />
                                    </td>
                                    <td></td>
                                    <td>
                                        <asp:Label ID="lblIntradialytic_Problems" runat="server" Text="Intradialytic Problems"></asp:Label>
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtIntradialytic_Problems" runat="server" TextMode="MultiLine" Height="99" />
                                    </td>
                                    <td></td>
                                </tr>

                                <tr>
                                    <td>
                                        <asp:Label ID="lblSpecial_Needs" runat="server" Text="Special Needs"></asp:Label>
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtSpecial_Needs" runat="server" TextMode="MultiLine" Height="99" />
                                    </td>
                                    <td></td>
                                    <td>
                                        <asp:Label ID="lblVisit_Date" runat="server" Text="Visit Date *"></asp:Label>
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtVisit_Date" runat="server" />
                                    </td>
                                    <td>
                                        <asp:RequiredFieldValidator ID="rfvtxtVisit_Date" ControlToValidate="txtVisit_Date" runat="server" ErrorMessage="Enter Visit Date" Text="*"></asp:RequiredFieldValidator>
                                        <%--<asp:RangeValidator ID="rngVisit_Date" Type="Date" runat="server" ControlToValidate="txtVisit_Date" ErrorMessage="Enter proper date" Text="*"></asp:RangeValidator>--%>
                                    </td>
                                </tr>

                            </table>
                        </div>
                    </div>
                    
                    <div id="Tab-2">
                        <div id="Services" style="width: 90%">
                            <table>

                                <tr>
                                    <td>
                                        <h2>Services : </h2>
                                        <br />
                                    </td>
                                </tr>

                                <tr>
                                    <td>
                                        <asp:UpdatePanel runat="server" ID="upServiceForm" UpdateMode="Conditional">
                                            <Triggers>
                                                <asp:AsyncPostBackTrigger ControlID="btnNew" EventName="Click" />
                                                <asp:AsyncPostBackTrigger ControlID="btnAddService" EventName="Click" />
                                                <asp:AsyncPostBackTrigger ControlID="BtnDeleteService" EventName="Click" />
                                            </Triggers>
                                            <ContentTemplate>
                                                <table style="width: 689px">
                                                    <tr>
                                                        <td style="position: relative; top: -13px;">
                                                            <asp:Label ID="lblSrvcName" runat="server" Text="Service Name"></asp:Label>
                                                        </td>
                                                        <td>
                                                            <asp:DropDownList ID="ddlService" runat="server" Width="167px" AppendDataBoundItems="true" onChange="chkService_Select()"></asp:DropDownList>
                                                            <%--<asp:DropDownList ID="ddlService" runat="server" Width="167px" AppendDataBoundItems="true" onChange="chkService_Select($(this).val())"></asp:DropDownList>--%>
                                                            &nbsp;</td>
                                                        <td style="position: relative; top: -10px;">
                                                            <asp:Button ID="btnAddService" runat="server" Text="Add Service" Width="107" CausesValidation="false" OnClick="btnAddService_Click" />
                                                            &nbsp;
                                                            <asp:Button ID="BtnDeleteService" runat="server" Text="Delete" Width="107px" CausesValidation="false" OnClick="BtnDeleteService_Click" />
                                                            &nbsp;
                                                            <asp:Button ID="btnClearService" CausesValidation="false" Width="107px" runat="server" Text="Clear" OnClick="btnClearService_Click" />
                                                        </td>
                                                    </tr>
                                                </table>
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                    </td>
                                </tr>
                                
                                <tr>
                                    <td>
                                        <asp:Label ID="lblValidation" Text="" runat="server" CssClass="errorMessage" />
                                    </td>
                                </tr>
                                
                                <tr>
                                    <td>
                                        <div style="width: 600px; float: left">
                                            <div>
                                                <asp:UpdateProgress ID="UpdateProgress1" runat="server" DisplayAfter="1000" DynamicLayout="False">
                                                    <ProgressTemplate>
                                                        <div class="loadingimage">
                                                            <asp:Image ID="image1" ImageUrl="~/images/loading.gif" runat="server" Width="32px" />
                                                        </div>
                                                    </ProgressTemplate>
                                                </asp:UpdateProgress>
                                                <asp:UpdatePanel runat="server" ChildrenAsTriggers="False" ID="UpdatePanel2" UpdateMode="Conditional">
                                                    <Triggers>
                                                        <asp:AsyncPostBackTrigger ControlID="btnAddService" EventName="Click" />
                                                        <asp:AsyncPostBackTrigger ControlID="BtnDeleteService" EventName="Click" />
                                                        <asp:AsyncPostBackTrigger ControlID="btnNew" EventName="Click" />
                                                    </Triggers>
                                                    <ContentTemplate>
                                                        <asp:GridView ID="GRD_SRVC" runat="server" BorderStyle="None" AutoGenerateColumns="False"
                                                            CellPadding="5" ShowFooter="True" OnSelectedIndexChanging="GRD_SRVC_SelectedIndexChanging" Style="z-index: -1" CellSpacing="1" Height="160px" Width="450px">
                                                            <Columns>
                                                                <asp:TemplateField>
                                                                    <ItemTemplate>
                                                                        <asp:LinkButton ID="imgedit" CausesValidation="false" CommandName="select" runat="server">edit</asp:LinkButton>
                                                                    </ItemTemplate>
                                                                    <ItemStyle HorizontalAlign="Center" Width="100px" />
                                                                </asp:TemplateField>
                                                                <asp:TemplateField HeaderText="Index" Visible="false">
                                                                    <ItemTemplate>
                                                                        <asp:Label ID="lblIndex" runat="server" Text='<%# Bind("Index") %>'></asp:Label>
                                                                    </ItemTemplate>
                                                                    <EditItemTemplate>
                                                                        <asp:TextBox ID="txtSrvc_Index" runat="server"></asp:TextBox>
                                                                    </EditItemTemplate>
                                                                </asp:TemplateField>
                                                                <asp:BoundField DataField="Service_Name" Visible="false" HeaderText="Service Name">
                                                                    <ItemStyle Width="200px" />
                                                                </asp:BoundField>
                                                                <asp:BoundField DataField="Svc_Name" HeaderStyle-CssClass="header-center" HeaderText="Service Name">
                                                                    <ItemStyle Width="200px" HorizontalAlign="Center" />
                                                                </asp:BoundField>
                                                            </Columns>
                                                        </asp:GridView>
                                                    </ContentTemplate>
                                                </asp:UpdatePanel>
                                            </div>
                                        </div>
                                    </td>
                                </tr>

                            </table>
                        </div>
                    </div>
                </div>

                <div style="padding-left: 70px; padding-top: 20px;">
                    <table>

                        <tr>
                            <td>
                                <asp:Button Text="Back" Width="95px" runat="server" ID="btnBack" CausesValidation="false" PostBackUrl="~/DialysisVisitView.aspx" />
                                &nbsp;&nbsp;
                                <asp:Button Text="Save" Width="95px" runat="server" ID="btnSave" OnClick="btnSave_Click" />
                                &nbsp;&nbsp;
                                <asp:Button ID="btnNew" Width="95px" runat="server" Text="New" CausesValidation="false" OnClick="btnNew_Click" />
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:ValidationSummary ID="ValidationSummary1" runat="server" ForeColor="Red" HeaderText="Page Errors" ShowSummary="true" DisplayMode="List" />
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:Label ID="lblMessage" Text="" runat="server" />
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
