<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Report.aspx.cs" Inherits="PMS.Report" Theme="Default_Theme" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <script type="text/javascript">
        $(document).ready(function () {
            $('#ctl00_MainContent_txtFromVoucher_No').css('text-align', 'right');
            $('#ctl00_MainContent_txtToVoucher_No').css('text-align', 'right');
            $('#ctl00_MainContent_txtFromVoucher_No').css('width', '169px');
            $('#ctl00_MainContent_txtToVoucher_No').css('width', '169px');
            loadtokenInputs();

            $("#ctl00_MainContent_txtStart_Date").datepicker({ dateFormat: "dd M yy" }).datepicker("setDate", new Date());
            $("#ctl00_MainContent_txtEnd_Date").datepicker({ dateFormat: "dd M yy" }).datepicker("setDate", new Date());

            $("#ctl00_MainContent_txtComarison_DateFrom").datepicker({ dateFormat: "dd M yy" }).datepicker("setDate", new Date());
            $("#ctl00_MainContent_txtComarison_DateTo").datepicker({ dateFormat: "dd M yy" }).datepicker("setDate", new Date());

            $('#ctl00_MainContent_txtSTime').ptTimeSelect({});
            $('#ctl00_MainContent_txtETime').ptTimeSelect({});
            $('#ctl00_MainContent_ddlCostCenter').select2();
            $('#ctl00_MainContent_ddlDepartment').select2();
            $('#ctl00_MainContent_ddlSalesman').select2();
            $('#ctl00_MainContent_ddlVoucher_Type').select2();
        });
       
        
        function DisableDropDowns() {
            var rbtn = document.getElementById("<%= rbtAll.ClientID%>");
            if (rbtn != null) {
                var Start_Code = document.getElementById("<%= txtStart_Code.ClientID%>");
                var EndCode = document.getElementById("<%= txtEnd_Code.ClientID%>");
                if (rbtn.checked == true) {
                    // alert(Start_Code.value);
                    Start_Code.disabled = true;
                    EndCode.disabled = true;
                }
            }
        }
        function EnableDropDowns() {
            var rbtn = document.getElementById("<%= rbtAccountSelection.ClientID%>");
            if (rbtn != null) {
                var Start_Code = document.getElementById("<%= txtStart_Code.ClientID%>");
                var EndCode = document.getElementById("<%= txtEnd_Code.ClientID%>");
                if (rbtn.checked == true) {
                    // alert(EndCode.value);
                    Start_Code.disabled = false;
                    EndCode.disabled = false;
                }
            }
        }
        function DisableSpecifAccount() {
            var chbAll = document.getElementById("<%= chbAllAccounts.ClientID%>");
            if (chbAll != null) {
                var SpecifAccount = document.getElementById("<%= txtSpecificAccount.ClientID%>");
                if (chbAll.checked == true) {
                    // alert(EndCode.value);
                    SpecifAccount.disabled = true;
                }
                else {
                    SpecifAccount.disabled = false;
                }
            }
        }

        function loadtokenInputs() {

            loadSpecificAccountTokenInput();
            loadAccountCodeForCashBookTokenInput();
            loadAccountCodeTokenInputs();
            loadAccountCodeNameTokenInput();
            loadAccountBankSummaryTokenInput();
            loadStartEndAccountTokenInput();
            loadPurchasedPlotsListTokenInput();
            loadCustomerTokenInput();

        }
        function loadCustomerTokenInput() {
            $("#ctl00_MainContent_txtCustomer").tokenInput("json.aspx?Table=Ar_Customers&Record=New",

                   {
                       tokenLimit: 1
                   });
            $("#ctl00_MainContent_txtCustomerFrom").tokenInput("json.aspx?Table=Ar_Customers&Record=New",

                  {
                      tokenLimit: 1
                  });
            $("#ctl00_MainContent_txtCustomerTo").tokenInput("json.aspx?Table=Ar_Customers&Record=New",

                  {
                      tokenLimit: 1
                  });
        }
        function loadPurchasedPlotsListTokenInput() {

            $("#ctl00_MainContent_txtPlotsList").tokenInput("json.aspx?Table=Plots&Transaction=AllPlots",
             {
                 tokenLimit: 1
             });
        }

        function loadStartEndAccountTokenInput() {
            //$("#ctl00_MainContent_txtSpecificAccount").tokenInput("clear");
            $("#ctl00_MainContent_txtStart_Code").tokenInput("json.aspx", {
                tokenLimit: 1
            });
            $("#ctl00_MainContent_txtEnd_Code").tokenInput("json.aspx", {
                tokenLimit: 1
            });
        }
        function loadSpecificAccountTokenInput() {
            //$("#ctl00_MainContent_txtSpecificAccount").tokenInput("clear");
            $("#ctl00_MainContent_txtSpecificAccount").tokenInput("json.aspx", {
                tokenLimit: 1
            });
        }
        function loadAccountCodeForCashBookTokenInput() {
            $("#ctl00_MainContent_txtAccountCodeForCashBook").tokenInput("json.aspx", {
                tokenLimit: 1
            });
        }
        function loadAccountCodeNameTokenInput() {
            var Account_Code_Name = $("#ctl00_MainContent_txtAccount_Code_Name");
            if (Account_Code_Name != null) {
                $("#ctl00_MainContent_txtAccount_Code_Name").tokenInput("json.aspx?Bank=1",
                   {
                       tokenLimit: 1
                   });
            }
        }
        function loadAccountBankSummaryTokenInput() {
            var Account_Code_Name = $("#ctl00_MainContent_txtAccountBankSummary");
            if (Account_Code_Name != null) {
                $("#ctl00_MainContent_txtAccountBankSummary").tokenInput("json.aspx",
                   {
                       tokenLimit: 1
                   });
            }
        }

        function loadPlotTokenInputs() {
            var Plot_Info = $("#ctl00_MainContent_txtPlot_Info");
            if (Plot_Info != null) {
                $("#ctl00_MainContent_txtPlot_Info").tokenInput("json.aspx?Table=Plots&Transaction=Purchases",
                {
                    tokenLimit: 1
                });
            }
        }
        function loadAccountCodeTokenInputs() {
            $("#ctl00_MainContent_txtAccountCode").tokenInput("json.aspx", {
                tokenLimit: 1
            });
        }

        function GetAccountCodeAndName() {
            var name = '';
            var Account_Code_Name = $("#ctl00_MainContent_txtAccount_Code_Name");
            if (Account_Code_Name != null) {
                $.each($("#ctl00_MainContent_txtAccount_Code_Name").tokenInput('get'), function () {
                    if (name != '') {
                        name += ",";
                    }
                    name += this.id;
                });
                $("#hdfAccount_Name").val(name);
            }
        }

    </script>
    <script type="text/javascript">
        var prm = Sys.WebForms.PageRequestManager.getInstance();

        prm.add_endRequest(function () {
        });
    </script>

    <asp:Panel runat="server" ID="pnlForm" DefaultButton="btnPreview">
         <asp:PlaceHolder ID="plhCustomer" runat="server" visible="false">
            <div class="row" runat="server">
                <div class="col-lg-3 col-md-6 col-sm-12">
                    <asp:Label ID="lblMID" runat="server" Text="Enter MID" CssClass="form-label"></asp:Label>
                    <asp:TextBox runat="server" ID="txtCustomer" onChange="GetRate();" CssClass="form-control"></asp:TextBox>
                </div>
            </div>
        </asp:PlaceHolder>
        &nbsp;&nbsp;
        <asp:PlaceHolder ID="plhCustomerMIDto" runat="server" visible="false">
            <div class="row" runat="server">
                <div class="col-lg-3 col-md-6 col-sm-12">
                    <asp:Label ID="lblMIDTo" runat="server" Text="Enter MID TO" CssClass="form-label"></asp:Label>
                    <asp:TextBox runat="server" ID="txtCustomerFrom" onChange="GetRate();" CssClass="form-control"></asp:TextBox>
                </div>
            </div>
        </asp:PlaceHolder>
        <asp:PlaceHolder ID="plhCustomerMIDFrom" runat="server" visible="false">
            <div class="row" runat="server">
                <div class="col-lg-3 col-md-6 col-sm-12">
                    <asp:Label ID="lblMIDFrom" runat="server" Text="Enter MID FROM" CssClass="form-label"></asp:Label>
                    <asp:TextBox runat="server" ID="txtCustomerTo" onChange="GetRate();" CssClass="form-control"></asp:TextBox>
                </div>
            </div>
        </asp:PlaceHolder>
        &nbsp;&nbsp;
        <div class="row" id="AccountInfoDiv" runat="server" visible="false">
            <div class="col-lg-3 col-md-6 col-sm-12" style="display:inline-flex;align-items: center; width: auto;">
                <asp:RadioButton ID="rbtAll" runat="server" GroupName="a" Checked="true" OnCheckedChanged="rbtAll_CheckedChanged" AutoPostBack="true" />
                <asp:Label Text="All Accounts" runat="server" CssClass="form-label" Style="margin-left:5px;white-space: nowrap;" />
            </div>
            <div class="col-lg-3 col-md-6 col-sm-12" style="display:inline-flex;align-items: center;width: 98px;">
                <asp:RadioButton GroupName="a" ID="rbtAccountSelection" Text="" runat="server" OnCheckedChanged="rbtAccountSelection_CheckedChanged" AutoPostBack="true" />
                <asp:Label Text="Account Selection" runat="server" CssClass="form-label" Style="margin-left:5px;white-space: nowrap;" />
            </div>
        </div>
        &nbsp;&nbsp;
     <div class="row" id="AccountDiv" runat="server" visible="false">
            <div class="col-lg-3 col-md-6 col-sm-12" >
                <asp:Label ID="lblStartAccount_Code" runat="server" Text="Start Account" CssClass="form-label"></asp:Label>
                <asp:TextBox runat="server" ID="txtStart_Code" CssClass="form-control"></asp:TextBox>
            </div>
            <div class="col-lg-3 col-md-6 col-sm-12">
                <asp:Label ID="lblEndAccount_Code" runat="server" Text="End Account" CssClass="form-label"></asp:Label>
                <asp:TextBox runat="server" ID="txtEnd_Code" CssClass="form-control"></asp:TextBox>
            </div>
      </div>
        <asp:PlaceHolder runat="server" ID="phMultiLedger" visible="false">
            <table>
                <tr>
                    <td>
                        <asp:Label Text="Account" runat="server" />
                    </td>
                    <td>
                        <asp:TextBox runat="server" ID="txtAccountCode" />

                    </td>
                    <td>
                        <asp:UpdatePanel runat="server" ID="upAddButton" UpdateMode="Conditional">
                            <ContentTemplate>
                                <asp:Button Text="Add" ID="btnAdd"  CssClass="btn btn-primry" ValidationGroup="account" runat="server" OnClick="btnAdd_Click" />
                            </ContentTemplate>
                            <Triggers>
                                <asp:AsyncPostBackTrigger ControlID="grdAccountsList" EventName="RowCommand" />
                            </Triggers>
                        </asp:UpdatePanel>

                    </td>
                </tr>
                <tr>
                    <td></td>
                    <td colspan="2">
                        <asp:RequiredFieldValidator ErrorMessage="Account must required." ID="rfvAccount" ValidationGroup="account"
                            SetFocusOnError="true" Display="Dynamic" ControlToValidate="txtAccountCode" runat="server" />
                    </td>
                </tr>
                <tr>
                    <td colspan="3">
                        <asp:UpdatePanel runat="server" UpdateMode="Conditional" ID="upAccountList">
                            <ContentTemplate>
                                <asp:Label ID="lblErrorMessage" CssClass="errorMessage" runat="server" />
                                <asp:HiddenField ID="hdfRowIndex" runat="server" />
                                <asp:HiddenField ID="hdfPlotNumber" runat="server" ClientIDMode="Static" />
                                <asp:GridView runat="server" AutoGenerateColumns="False" ID="grdAccountsList" EmptyDataText="No record." OnRowDeleting="grdAccountsList_RowDeleting" OnRowCommand="grdAccountsList_RowCommand" OnRowDataBound="grdAccountsList_RowDataBound">
                                    <Columns>
                                        <asp:TemplateField >
                                            <ItemTemplate>
                                                <asp:Label Text='<%# Eval("Account_ID") %>' ID="lblAccount_ID" runat="server" />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Account Code">
                                            <ItemTemplate>
                                                <asp:Label ID="lblAccount_Code" runat="server" Text='<%# Bind("Account_Code") %>'></asp:Label>
                                            </ItemTemplate>
                                            <HeaderStyle Width="100px" />
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderStyle-Width="208px" HeaderText="Account Name">
                                            <ItemTemplate>
                                                <asp:Label ID="lblAccount_Name" runat="server" Text='<%# Eval("Account_Name") %>' />
                                            </ItemTemplate>
                                            <HeaderStyle Width="208px" />
                                        </asp:TemplateField>
                                        <asp:TemplateField ShowHeader="False">
                                            <ItemTemplate>
                                                <asp:LinkButton ID="LinkButton1" runat="server" CausesValidation="False" CssClass="btn-danger" CommandName="Delete" Text="Delete" OnClientClick="javascript:return confirm('Are you sure, you want to delete this record?');"></asp:LinkButton>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField>
                                            <ItemTemplate>
                                                <asp:LinkButton ID="lbtnEdit" Text="Edit" ToolTip="Edit" CssClass="btn-primary" CausesValidation="false" CommandName="SelectRecord" CommandArgument='<%# Container.DisplayIndex %>' runat="server" />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>
                            </ContentTemplate>
                        </asp:UpdatePanel>
                    </td>
                </tr>
            </table>
                        
        </asp:PlaceHolder>
        <asp:PlaceHolder ID="plhAllAcounts" runat="server" visible="false">
            <table cellspacing="0">
                <tr>
                    <td>
                        <asp:CheckBox runat="server" ID="chbAllAccounts" Checked="true" AutoPostBack="true" OnCheckedChanged="chbAllAccounts_CheckedChanged"></asp:CheckBox>
                    </td>
                    <td>
                        <asp:Label Text="All Accounts" runat="server" ID="lblAllAccount" CssClass="form-label" />
                    </td>
                </tr>
                <div class="row">
                    <div class="col-lg-3 col-md-6 col-sm-12">
                        <asp:Label ID="lblSpecificAccount" runat="server" Text="Specific Account" CssClass="form-label"></asp:Label>
                        <asp:TextBox runat="server" ID="txtSpecificAccount" CssClass="form-control"></asp:TextBox>
                    </div>
                </div>
            </table>
        </asp:PlaceHolder>
         &nbsp;&nbsp;
        <div class="row" id="BankReconsilationDiv" runat="server" visible="false">
            <div class="col-lg-3 col-md-6 col-sm-12">
                <asp:Label ID="lblAccount_Code_Name" runat="server" Text="Account" CssClass="form-label"></asp:Label>
                 <asp:TextBox runat="server" ID="txtAccount_Code_Name" CssClass="form-control" SkinID="UserDefineWidth"></asp:TextBox>
                 <asp:HiddenField ID="hdfAccount_Name" runat="server" ClientIDMode="Static" />
            </div>
        </div>
         &nbsp;&nbsp;
        <div class="row" id="SalesmanDiv" runat="server" visible="false">
            <div class="col-lg-3 col-md-6 col-sm-12">
                <asp:Label ID="lblSaleman" runat="server" Text="Sales man" CssClass="form-label"></asp:Label>
                <asp:DropDownList ID="ddlSalesman" runat="server" AppendDataBoundItems="true" CssClass="form-control"></asp:DropDownList>
            </div>
        </div>
         &nbsp;&nbsp;
         <div class="row" id="DepartmentDiv" runat="server" visible="false">
            <div class="col-lg-3 col-md-6 col-sm-12">
                <asp:Label ID="lblDepartment" runat="server" Text="Department" CssClass="form-label"></asp:Label>
                <asp:DropDownList ID="ddlDepartment" runat="server" AppendDataBoundItems="true" CssClass="form-control"></asp:DropDownList>
            </div>
        </div>
         &nbsp;&nbsp;
        <div class="row" id="CostCenterDiv" runat="server" visible="false">
            <div class="col-lg-3 col-md-6 col-sm-12">
                <asp:Label ID="lblCostCenter" runat="server" Text="Project" CssClass="form-label"></asp:Label>
                <asp:DropDownList ID="ddlCostCenter" runat="server" AppendDataBoundItems="true" CssClass="form-control"></asp:DropDownList>
            </div>
        </div>
         &nbsp;&nbsp;
        <div class="row" id="DateDiv" runat="server" visible="false">
            <div class="col-lg-3 col-md-6 col-sm-12">
                <asp:Label ID="stDate" runat="server" Text="Start Date" CssClass="form-label"></asp:Label>
                <asp:TextBox runat="server" ID="txtStart_Date" CssClass="form-control datepicker"></asp:TextBox>
            </div>
            <div class="col-lg-3 col-md-6 col-sm-12" visible="false">
                <asp:Label ID="enDate" runat="server" Text="End Date" CssClass="form-label"></asp:Label>
                <asp:TextBox runat="server" ID="txtEnd_Date" CssClass="form-control datepicker"></asp:TextBox>
            </div>
        </div>
         &nbsp;&nbsp;
        <div class="row" id="Vendordiv" runat="server" visible="false">
            <div class="col-lg-3 col-md-6 col-sm-12">
                <asp:Label ID="lblVendor" runat="server" Text="Select Vendor" CssClass="form-label"></asp:Label>
                <asp:DropDownList ID="VendorList" runat="server" AppendDataBoundItems="true" CssClass="form-control"></asp:DropDownList>
            </div>
        </div>
         &nbsp;&nbsp;
        <div class="row" id="comparisonDateDiv" runat="server" visible="false">
            <div class="col-lg-3 col-md-6 col-sm-12">
                <asp:Label ID="Comparison_DateFrom" runat="server" Text="Comparison Date From " CssClass="form-label"></asp:Label>
                <asp:TextBox runat="server" ID="txtComarison_DateFrom" CssClass="form-control datepicker"></asp:TextBox>
            </div>
            <div class="col-lg-3 col-md-6 col-sm-12" visible="false">
                <asp:Label ID="Comparison_DateTo" runat="server" Text="Comparison Date To " CssClass="form-label"></asp:Label>
                <asp:TextBox runat="server" ID="txtComarison_DateTo" CssClass="form-control datepicker"></asp:TextBox>
            </div>
        </div>
         &nbsp;&nbsp;
        <div class="row" id="TimeRow" runat="server" visible="false">
            <div class="col-lg-3 col-md-6 col-sm-12">
                <asp:Label ID="stTime" runat="server" Text="Start Time " CssClass="form-label"></asp:Label>
                <asp:TextBox runat="server" ID="txtSTime" CssClass="form-control"></asp:TextBox>
            </div>
            <div class="col-lg-3 col-md-6 col-sm-12">
                <asp:Label ID="enTime" runat="server" Text="End Time " CssClass="form-label"></asp:Label>
                <asp:TextBox runat="server" ID="txtETime" CssClass="form-control"></asp:TextBox>
            </div>
        </div>
     &nbsp;&nbsp;
        <table id="ExportDiv" runat="server" visible="false">
            <tr>
                <td>
                    <asp:CheckBox runat="server" ID="chkExportPDF"></asp:CheckBox>
                </td>
                <td>
                    <asp:Label Text="Export to Excel" runat="server" ID="trExpToPdf" />
                </td>
            </tr>
        </table>
         &nbsp;&nbsp;
        <table id="levelChekBox" runat="server" visible="false">
            <tr>
                <td>
                    <asp:CheckBox runat="server" ID="cbLevel1"></asp:CheckBox>
                </td>
                <td style="padding-right: 8px;">
                    <asp:Label Text="Level 1" runat="server" ID="lblLevel1" />
                </td>

                <td>
                    <asp:CheckBox runat="server" ID="cbLevel2" CssClass="form-check-input"></asp:CheckBox>
                </td>
                <td style="padding-right: 8px;">
                    <asp:Label Text="Level 2" runat="server" ID="lblLevel2" CssClass="form-check-label" />
                </td>

                <td>
                    <asp:CheckBox runat="server" ID="cbLevel3" CssClass="form-check-input"></asp:CheckBox>
                </td>
                <td style="padding-right: 8px;">
                    <asp:Label Text="Level 3" runat="server" ID="lblLevel3" CssClass="form-check-label" />
                </td>

                <td>
                    <asp:CheckBox runat="server" ID="cbLevel4" CssClass="form-check-input"></asp:CheckBox>
                </td>
                <td style="padding-right: 8px;">
                    <asp:Label Text="Level 4" runat="server" ID="lblLevel4" CssClass="form-check-label" />
                </td>
            </tr>
        </table>
         &nbsp;&nbsp;
         <table id="HideZerroBalance" runat="server" visible="false">
            <tr>
                <td>
                    <asp:CheckBox runat="server" ID="cbHideZeroBalance"></asp:CheckBox></td>
                <td>
                    <asp:Label Text="Hide Zero Balance" runat="server" ID="lblHideZeroBalance"/></td>
            </tr> 
        </table>
         &nbsp;&nbsp;
         <div class="row" id="VoucherDiv" runat="server" visible="false">
            <div class="col-lg-3 col-md-6 col-sm-12">
                <asp:Label ID="Label6" runat="server" Text="Voucher Type" CssClass="form-label"></asp:Label>
                 <asp:DropDownList runat="server" ID="ddlVoucher_Type" AppendDataBoundItems="true"  CssClass="form-control" />
            </div>
        </div>
         &nbsp;&nbsp;
         <div class="row">
                <div class="col-lg-2">
                    <asp:Button Text="Preview" CssClass="btn btn-primry" ID="btnPreview" runat="server" OnClick="btnPreview_Click" OnClientClick="GetAccountCodeAndName();" />
                </div>
                <div class="col-lg-2">
                    <asp:Button Text="Cancel" ID="btnCancel" CssClass="btn btn-gray" runat="server" CausesValidation="false" />
                </div>
            </div>
    </asp:Panel>
</asp:Content>
