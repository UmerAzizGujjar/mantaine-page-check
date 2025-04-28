<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Sales.aspx.cs" Inherits="PMS.Sales" Theme="Default_Theme" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <script type="text/javascript" src="Scripts/jquery.tokeninput.js"></script>
    <script type="text/javascript">
        $(document).ready(function () {
            bindcontrols();

            if ($("#ctl00_MainContent_cbDelivered").is(':checked')) {
                $("#ctl00_MainContent_txtFileNo").attr('disabled', false);
            }
            else {
                $("#ctl00_MainContent_txtFileNo").attr('disabled', true);
            }
            $("#ctl00_MainContent_cbDelivered").on("click", function () {
                $("#ctl00_MainContent_txtFileNo").attr('disabled', !this.checked);
            });
        });
        function bindcontrols() {
            // $("#ctl00_MainContent_txtDate_Received").val($.datepicker.formatDate('dd.mm.yy', new Date()));
            $("#ctl00_MainContent_txtInstallment_Date").val($.datepicker.formatDate('dd M yy', new Date()));
            //$("#ctl00_MainContent_txtSales_Date").val($.datepicker.formatDate('dd M yy', new Date()));

            //attach calender to datetime picker
            Sys.WebForms.PageRequestManager.getInstance().add_pageLoaded(function (evt, args) {
                $("#ctl00_MainContent_txtInstallment_Date").datepicker({ dateFormat: 'dd M yy' });
                $("#ctl00_MainContent_txtSales_Date").datepicker({ dateFormat: 'dd M yy' });
            });
            $("#ctl00_MainContent_txtPlot_Number").tokenInput("json.aspx?Table=Plots&Transaction=Sales",
             {
                 tokenLimit: 1
             });
            var sales_ID;
            sales_ID = $("#hdfSales_ID").val();
            //  alert(sales_ID);
            if (sales_ID != "(New)") {
                var tokendata;
                tokendata = httpGet("json.aspx/?Table=Customer&SaleID=" + sales_ID);
                loadtokenInputs("#ctl00_MainContent_txtCustomer", JSON.parse(tokendata));
            }
            else {
                loadtokenInputsDefault();
            }
        }
        function loadtokenInputs(elementId, data) {
            if (elementId == "#ctl00_MainContent_txtCustomer") {
                $(elementId).tokenInput("json.aspx?Table=Customer",
                    {
                        prePopulate: data,
                        tokenLimit: 1
                    });
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
            $("#ctl00_MainContent_txtCustomer").tokenInput("json.aspx?Table=Customer",
               {
                   tokenLimit: 1
               });
        }
        function GetAccountCodeAndName() {
            var name = '';
            $.each($("#ctl00_MainContent_txtPlot_Number").tokenInput('get'), function () {
                if (name != '') {
                    name += ",";
                }
                name += this.name;
            });
            $("#hdfPlotNumber").val(name);
        }
    </script>
    <table>
        <tr valign="top">
            <td width="45%">
                <asp:Panel runat="server" ID="pnlForm" DefaultButton="btnSave">
                    <table cellspacing="7">

                        <tr>
                            <td>
                                <asp:Label Text="Invoice No" runat="server" ID="lblSales_ID" />
                            </td>
                            <td>
                                <asp:TextBox runat="server" ID="txtInvoiceNo" Width="125" ReadOnly="true" />
                                <asp:HiddenField ID="hdfSales_ID" runat="server" ClientIDMode="Static" Value="(New)" />
                                <asp:TextBox runat="server" ID="txtSales_ID" Width="125" ReadOnly="true" Text="(New)" Visible="false" />
                            </td>
                            <%--  <td>
                    <asp:Label Text="Re-Prosess Installment" runat="server" ID="lblReProcess_Installment" />
                </td>
                <td>
                    <asp:TextBox runat="server" ID="txtReProcess_Installment" Width="125" />
                </td>--%>
                        </tr>
                        <tr>
                            <td>
                                <asp:Label Text="Status" runat="server" ID="Label2" />
                            </td>
                            <td>
                                <asp:TextBox runat="server" ID="txtStatus" Width="125" ReadOnly="true" Text="Created" />
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:Label Text="Customer" runat="server" ID="lblCustomer" />
                            </td>
                            <td>
                                <asp:TextBox runat="server" ID="txtCustomer" />
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator1" ErrorMessage="Customer is required." ControlToValidate="txtCustomer"
                                    Display="Dynamic" SetFocusOnError="true" runat="server" />
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:Label Text="Sales Date" runat="server" ID="lblSales_Date" />
                            </td>
                            <td>
                                <asp:TextBox runat="server" ID="txtSales_Date" onFocus="blur()" Width="125" />
                            </td>
                        </tr>
                        <tr>
                            <td></td>
                            <td>
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator2" ErrorMessage="Sales date is required." ControlToValidate="txtSales_Date"  Display="Dynamic" SetFocusOnError="true" runat="server" />
                            </td>
                        </tr>
        </tr>
        <tr>
            <td>
                <asp:Label Text="Salesman" ID="Label3" runat="server" />
            </td>
            <td>
                <asp:DropDownList ID="ddlSalesman" runat="server" AppendDataBoundItems="true"></asp:DropDownList>
            </td>
        </tr>
        <tr>
            <td></td>
            <td>
                <asp:RequiredFieldValidator ID="RequiredFieldValidator6" ErrorMessage="Salesman is required." ControlToValidate="ddlSalesman"
                    Display="Dynamic" InitialValue="0" SetFocusOnError="true" runat="server" />
            </td>
        </tr>
        <tr>
            <td>
                <asp:Label Text="Cost Center" ID="lblCostCenter" runat="server" />
            </td>
            <td>
                <asp:DropDownList ID="ddlCostCenter" runat="server" AppendDataBoundItems="true"></asp:DropDownList>
            </td>
        </tr>
        <tr>
            <td></td>
            <td>
                <asp:RequiredFieldValidator ID="RequiredFieldValidator5" ErrorMessage="Cost center is required." ControlToValidate="ddlCostCenter"
                    Display="Dynamic" InitialValue="0" SetFocusOnError="true" runat="server" />
            </td>
        </tr>
        <%--    <tr>
                            <td>
                                <asp:Label Text="Installment Date" runat="server" ID="lblInstallment_Date" />
                            </td>
                            <td>
                                <asp:TextBox runat="server" ID="txtInstallment_Date" onFocus="blur()" Width="125" />
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:Label Text="Due Instal. After Months" runat="server" ID="lblDue_Installment_After_Months" />
                            </td>
                            <td>
                                <asp:DropDownList runat="server" ID="ddlDue_Installment_After_months" Width="130">
                                    <asp:ListItem Text="Please Select" Value="0" />
                                    <asp:ListItem Text="1" Value="1" />
                                    <asp:ListItem Text="2" Value="2" />
                                    <asp:ListItem Text="3" Value="3" />
                                    <asp:ListItem Text="4" Value="4" />
                                    <asp:ListItem Text="5" Value="5" />
                                    <asp:ListItem Text="6" Value="6" />
                                    <asp:ListItem Text="7" Value="7" />
                                    <asp:ListItem Text="8" Value="8" />
                                    <asp:ListItem Text="9" Value="9" />
                                    <asp:ListItem Text="10" Value="10" />
                                    <asp:ListItem Text="11" Value="11" />
                                    <asp:ListItem Text="12" Value="12" />
                                </asp:DropDownList>
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator2" ErrorMessage="Due installment after months is required." ControlToValidate="ddlDue_Installment_After_months"
                                    InitialValue="0" SetFocusOnError="true" Display="Dynamic" runat="server" />
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:Label Text="Monthly Installment" runat="server" ID="lblMonthly_Installment" />
                            </td>
                            <td>
                                <asp:TextBox runat="server" ID="txtMonthly_Installment" Width="125" MaxLength="10" />
                                <asp:RangeValidator ErrorMessage="Please enter only numeric value." SetFocusOnError="true"
                                    Display="Dynamic" Type="Currency" ID="test" MinimumValue="0" MaximumValue="9999999999" ControlToValidate="txtMonthly_Installment" runat="server" />
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:Label Text="Total Installments" runat="server" ID="lblTotal_Installment" />
                            </td>
                            <td>
                                <asp:TextBox runat="server" ID="txtTotal_Installment" Width="125" MaxLength="10" />
                                <asp:RangeValidator ErrorMessage="Please enter only numeric value." SetFocusOnError="true"
                                    Display="Dynamic" Type="Currency" ID="RangeValidator1" ControlToValidate="txtTotal_Installment" runat="server" MinimumValue="0" MaximumValue="9999999999" />
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:Label Text="Cost of Land" runat="server" ID="lblCost_OF_Land" />
                            </td>
                            <td>
                                <asp:TextBox runat="server" ID="txtCost_OF_Land" Width="125" MaxLength="10" />
                                <asp:RangeValidator ErrorMessage="Please enter only numeric value." SetFocusOnError="true"
                                    Display="Dynamic" Type="Currency" ID="RangeValidator2" ControlToValidate="txtCost_OF_Land" runat="server" MinimumValue="0" MaximumValue="9999999999" />

                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:Label Text="Development Charges" runat="server" ID="lblDevelopment_Charges" />
                            </td>
                            <td>
                                <asp:TextBox runat="server" ID="txtDevelopment_Charges" Width="125" MaxLength="10" />
                                <asp:RangeValidator ErrorMessage="Please enter only numeric value." SetFocusOnError="true"
                                    Display="Dynamic" Type="Currency" ID="RangeValidator3" ControlToValidate="txtDevelopment_Charges" runat="server" MinimumValue="0" MaximumValue="9999999999" />

                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:Label Text="Other" runat="server" ID="lblOther" />
                            </td>
                            <td>
                                <asp:TextBox runat="server" ID="txtOther" Width="125" MaxLength="10" />
                                <asp:RangeValidator ErrorMessage="Please enter only numeric value." SetFocusOnError="true"
                                    Display="Dynamic" Type="Currency" ID="RangeValidator4" ControlToValidate="txtOther" runat="server" MinimumValue="0" MaximumValue="9999999999" />

                            </td>
                        </tr>--%>
        <%-- <tr>
                            <td>
                                <asp:Label Text="Sales Amount" runat="server" ID="lblSales_Amount" />
                            </td>
                            <td>
                                <asp:TextBox runat="server" ID="txtSales_Amount" Width="125" MaxLength="10" />
                                <asp:RangeValidator ErrorMessage="Please enter only numeric value." SetFocusOnError="true"
                                    Display="Dynamic" Type="Currency" ID="RangeValidator5" ControlToValidate="txtSales_Amount" runat="server" MinimumValue="0" MaximumValue="9999999999" />

                            </td>
                        </tr>--%>
        <%--    <tr>

                            <td>
                                <asp:Label Text="Discount" runat="server" ID="lblDiscount" />
                            </td>
                            <td>
                                <asp:TextBox runat="server" ID="txtDiscount" Width="125" MaxLength="10" />
                                <asp:RangeValidator ErrorMessage="Please enter only numeric value." SetFocusOnError="true"
                                    Display="Dynamic" Type="Currency" ID="RangeValidator6" ControlToValidate="txtDiscount" runat="server" MinimumValue="0" MaximumValue="9999999999" />
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:Label Text="Net Value" runat="server" ID="lblNet_Value" />
                            </td>
                            <td>
                                <asp:TextBox runat="server" ID="txtNet_Value" Width="125" MaxLength="10" />
                                <asp:RangeValidator ErrorMessage="Please enter only numeric value." SetFocusOnError="true"
                                    Display="Dynamic" Type="Currency" ID="RangeValidator7" ControlToValidate="txtNet_Value" runat="server" MinimumValue="0" MaximumValue="9999999999" />

                            </td>
                        </tr>--%>
        <tr>
            <td>
                <asp:Label Text="File No" runat="server" ID="lblDelivered" />
            </td>
            <td>
                <asp:CheckBox ID="cbDelivered" runat="server" Text="Delivered" /><br />
                <asp:TextBox ID="txtFileNo" runat="server"></asp:TextBox>
            </td>
        </tr>
        <tr>
            <td>
                <asp:Label Text="Remarks" runat="server" ID="Label1" />
            </td>
            <td>
                <asp:TextBox runat="server" TextMode="MultiLine" ID="txtRemarks" />
            </td>
        </tr>
        <tr>
            <td colspan="2">
                <asp:Button Text="Back" ID="btnCancel" runat="server" CausesValidation="false" PostBackUrl="~/SalesView.aspx" />
                &nbsp;<asp:Button Text="Save" runat="server" ID="btnSave" OnClick="btnSave_Click" />
                &nbsp;
                                <asp:Button ID="btnVoucherPreview" runat="server" CausesValidation="false" OnClick="btnVoucherPreview_Click" Visible="false" Text="Voucher" />
                &nbsp;
                                <asp:Button Text="Un Approve" runat="server" CausesValidation="false" ID="btnUnApprove" OnClick="btnUnApprove_Click" Visible="false" />
            </td>
        </tr>
        <tr>
            <td></td>
            <td>
                <asp:Label ID="lblMessage" runat="server" />
            </td>
        </tr>
    </table>
    </asp:Panel>
            </td>
            <td width="55%">
                <fieldset style="margin: 0.5em 0;">
                    <table width="100%">
                        <tr valign="top">
                            <td>
                                <asp:Label Text="Plot" ID="lblPlot" runat="server" />
                            </td>
                            <td>
                                <asp:TextBox runat="server" ID="txtPlot_Number" />
                                <%--   <asp:DropDownList runat="server" ID="ddlPlotID" AppendDataBoundItems="true" EnableTheming="false">
                                            </asp:DropDownList>--%>
                            </td>
                            <td>
                                <asp:Label Text="Value" runat="server" ID="lblRates" />
                            </td>
                            <td>
                                <asp:UpdatePanel runat="server" ID="upRate" UpdateMode="Conditional">
                                    <Triggers>
                                        <asp:AsyncPostBackTrigger ControlID="grdPlotsList" EventName="RowCommand" />
                                        <asp:AsyncPostBackTrigger ControlID="btnAdd" EventName="Click" />
                                        <asp:AsyncPostBackTrigger ControlID="btnCancelPlot" EventName="Click" />
                                    </Triggers>
                                    <ContentTemplate>
                                        <asp:TextBox runat="server" ID="txtRates" EnableTheming="false" Width="100" />
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                            </td>
                            <td>
                                <asp:UpdatePanel runat="server" ID="upButton" UpdateMode="Conditional">
                                    <ContentTemplate>
                                        <asp:Button Text="Add" runat="server" Width="75" ID="btnAdd" OnClick="btnAdd_Click" OnClientClick="GetAccountCodeAndName()" ValidationGroup="pi" />
                                    </ContentTemplate>
                                    <Triggers>
                                        <asp:AsyncPostBackTrigger ControlID="grdPlotsList" EventName="RowCommand" />
                                        <asp:AsyncPostBackTrigger ControlID="btnCancelPlot" EventName="Click" />
                                    </Triggers>
                                </asp:UpdatePanel>
                                <br />
                                <asp:UpdatePanel runat="server" ID="UpdatePanel3" UpdateMode="Always">
                                    <ContentTemplate>
                                        <asp:Button Text="Cancel" runat="server" Width="75" CausesValidation="false" ID="btnCancelPlot" OnClick="btnCancelPlot_Click" />
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                            </td>
                        </tr>
                        <tr>

                            <td colspan="2">
                                <asp:UpdatePanel runat="server" ID="uprfvPlotNumber" UpdateMode="Always">
                                    <ContentTemplate>
                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator3" ErrorMessage="Plot number is required." ControlToValidate="txtPlot_Number"
                                            Display="Static" ValidationGroup="pi" SetFocusOnError="true" runat="server" />
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                            </td>

                            <td colspan="3">
                                <asp:UpdatePanel runat="server" ID="UpdatePanel1" UpdateMode="Always">
                                    <ContentTemplate>
                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator4" ErrorMessage="Value is required." ControlToValidate="txtRates"
                                            Display="Dynamic" ValidationGroup="pi" SetFocusOnError="true" runat="server" />
                                        <asp:RangeValidator ErrorMessage="Enter a valid amount." SetFocusOnError="true"
                                            Display="Dynamic" ValidationGroup="pi" Type="Currency" ID="RangeValidator8" ControlToValidate="txtRates" runat="server" MinimumValue="0" MaximumValue="9999999999" />
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="5">
                                <asp:UpdatePanel runat="server" UpdateMode="Conditional" ID="upForm">
                                    <Triggers>
                                        <asp:AsyncPostBackTrigger ControlID="btnAdd" EventName="Click" />
                                    </Triggers>
                                    <ContentTemplate>
                                        <asp:Label ID="lblErrorMessage" CssClass="errorMessage" runat="server" />
                                        <asp:HiddenField ID="hdfRowIndex" runat="server" />
                                        <asp:HiddenField ID="hdfPlotNumber" runat="server" ClientIDMode="Static" />
                                        <asp:GridView runat="server" AutoGenerateColumns="False" ID="grdPlotsList" EmptyDataText="No record." OnRowDeleting="grdPlotsList_RowDeleting" OnRowCommand="grdPlotsList_RowCommand">
                                            <Columns>
                                                <asp:TemplateField Visible="false">
                                                    <ItemTemplate>
                                                        <asp:Label Text='<%# Eval("ID") %>' ID="lblID" Visible="false" runat="server" />
                                                        <asp:Label Text='<%# Eval("Plot_ID") %>' runat="server" ID="lblPlotID" />
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                                <asp:TemplateField HeaderText="Plot Information">
                                                    <ItemTemplate>
                                                        <asp:Label ID="lblPlotNumber" runat="server" Text='<%# Bind("Plot_Number") %>'></asp:Label>
                                                    </ItemTemplate>
                                                    <HeaderStyle Width="250px" />
                                                </asp:TemplateField>
                                                <asp:TemplateField HeaderStyle-Width="150px" HeaderText="Value">
                                                    <ItemTemplate>
                                                        <asp:Label ID="lblRate" runat="server" Text='<%# Eval("Rate","{0:n2}") %>' />
                                                    </ItemTemplate>
                                                    <HeaderStyle Width="150px" />
                                                </asp:TemplateField>
                                                <asp:TemplateField ShowHeader="False">
                                                    <ItemTemplate>
                                                        <asp:LinkButton ID="LinkButton1" runat="server" CausesValidation="False" CommandName="Delete" Text="Delete" OnClientClick="javascript:return confirm('Are you sure, you want to delete this record?');"></asp:LinkButton>
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                                <asp:TemplateField>
                                                    <ItemTemplate>
                                                        <asp:LinkButton ID="lbtnEdit" Text="Edit" ToolTip="Edit" CausesValidation="false" CommandName="SelectRecord" CommandArgument='<%# Container.DisplayIndex %>' runat="server" />
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                            </Columns>
                                        </asp:GridView>
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                            </td>
                        </tr>
                    </table>
                </fieldset>
            </td>
    </tr>
    </table>
</asp:Content>
