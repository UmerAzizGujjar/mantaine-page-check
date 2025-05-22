<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="UserView.aspx.cs" Inherits="PMS.Account.UserView" Theme="Default_Theme" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/StandardTheme/css/CustomCss/Userview.css" rel="stylesheet" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
        <div class="col-lg-2 col-md-4 col-sm-6">
            <asp:TextBox runat="server" ID="txtSearch" PlaceHolder="Search Users By Name" AutoPostBack="True" OnTextChanged="txtSearch_TextChanged"></asp:TextBox>
        </div>
        <div class="col-lg-2 col-md-4 col-sm-6">
            <asp:CheckBox runat="server" ID="chkExactSearching" Text="Exact Searching" AutoPostBack="true" OnCheckedChanged="chkExactSearching_CheckedChanged" />
        </div>
    </div>

    <asp:UpdatePanel runat="server" ID="upForm" UpdateMode="Conditional">
        <ContentTemplate>
            <div>
                <br />
                <div class="col-lg-1 col-md-4 col-sm-6">
                    <asp:Button Text="New"  runat="server" ID="btnCreate" PostBackUrl="~/Modules/Accounts/Register.aspx" SkinID="btnAutoWidth" CssClass="btn btn-primry" />
                </div>
                <br />
                <asp:GridView runat="server" ID="gvUsers" AllowPaging="True" OnRowCommand="gvUsers_RowCommand" DataKeyNames="UserID"
                    SortedAscendingHeaderStyle-CssClass="sortasc-header" SortedDescendingHeaderStyle-CssClass="sortdesc-header"
                    SortedAscendingCellStyle-CssClass="sortasc-row" SortedDescendingCellStyle-CssClass="sortdesc-row" AutoGenerateColumns="False"
                    OnRowEditing="gvUsers_RowEditing" OnRowUpdating="gvUsers_RowUpdating" OnRowCancelingEdit="gvUsers_RowCancelingEdit"
                    OnReset="gvUsers_RestPass" OnPageIndexChanging="gvUsers_PageIndexChanging" Width="100%"
                    HeaderStyle-CssClass="header-red">
                    <Columns>
                        <asp:TemplateField HeaderText="Operations">
                            <EditItemTemplate>
                                <asp:LinkButton ID="LinkButton3" runat="server" CausesValidation="True" CommandName="Update" Text="Update"></asp:LinkButton>
                                &nbsp;<asp:LinkButton ID="LinkButton2" runat="server" CausesValidation="False" CommandName="Cancel" Text="Cancel"></asp:LinkButton>
                            </EditItemTemplate>
                            <ItemTemplate>
                                <asp:LinkButton ID="LinkButton3" runat="server" CausesValidation="False" CommandArgument='<%# Eval("UserID") %>' CommandName="Edit" Text="Edit"></asp:LinkButton>
                                &nbsp;
                                <asp:LinkButton ID="LinkButton2" runat="server" CausesValidation="false" CommandArgument='<%# Eval("UserName") %>' CommandName="Remove" OnClientClick="javascript:return confirm('Are you sure, you want to delete this record?');" Text="Delete"></asp:LinkButton>
                                &nbsp;
                                <asp:LinkButton ID="LinkButton5" runat="server" CausesValidation="false" CommandArgument='<%# Eval("UserName") %>' CommandName="Reset" OnClientClick="javascript:return confirm('Are you sure, you want to Rest Password of this record?');" Text="Reset Password"></asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="User ID" Visible="false">
                            <EditItemTemplate>
                                <asp:Label ID="lblUserID" runat="server" Text='<%# Bind("UserId") %>'></asp:Label>
                            </EditItemTemplate>
                            <ItemTemplate>
                                <asp:Label ID="lblUserID" runat="server" Text='<%# Bind("UserId") %>'></asp:Label>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="User Name">
                            <EditItemTemplate>
                                <asp:TextBox ID="txtUserName" runat="server" Text='<%# Bind("UserName") %>'></asp:TextBox>
                                <asp:RequiredFieldValidator ErrorMessage="Enter Email" ControlToValidate="txtUserName"
                                    runat="server" SetFocusOnError="true" Display="Dynamic" ID="rfvUserName" />
                            </EditItemTemplate>
                            <ItemTemplate>
                                <asp:Label ID="Label2" runat="server" Text='<%# Bind("UserName") %>'></asp:Label>
                            </ItemTemplate>
                        </asp:TemplateField>                      
                        <asp:TemplateField HeaderText="Mobile Number">
                            <EditItemTemplate>
                                <asp:TextBox ID="txtMobile" runat="server" CssClass="mobileInput" Text='<%# Bind("mobileno") %>'></asp:TextBox>
                                <asp:RegularExpressionValidator
                                    ErrorMessage="Invalid Mobile Number (must be a numeric value and not greater than 11 digits)"
                                    ControlToValidate="txtMobile"
                                    runat="server"
                                    SetFocusOnError="true"
                                    Display="Dynamic"
                                    ID="revMobile"
                                    ValidationExpression="^\d{1,11}$" />
                                <asp:RequiredFieldValidator
                                    ErrorMessage="Enter Mobile Number"
                                    ControlToValidate="txtMobile"
                                    runat="server"
                                    SetFocusOnError="true"
                                    Display="Dynamic"
                                    ID="rfvMobile" />
                            </EditItemTemplate>
                            <ItemTemplate>
                                <asp:Label ID="lblMobile" runat="server" Text='<%# Bind("mobileno") %>'></asp:Label>
                            </ItemTemplate>
                        </asp:TemplateField>


                        <asp:TemplateField HeaderText="Voucher Approval">
                            <EditItemTemplate>
                                <asp:CheckBox ID="cbApprvVoucher" runat="server" Checked='<%# Bind("AllowUnapproveVoucher") %>' />
                            </EditItemTemplate>
                            <ItemTemplate>
                                <asp:CheckBox ID="cbApprvVoucher" runat="server" Checked='<%# Bind("AllowUnapproveVoucher") %>' Enabled="false" />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Allow Patient Edit">
                            <EditItemTemplate>
                                <asp:CheckBox ID="cbApprovePatientEdit" runat="server" Checked='<%# Bind("AllowPatientEdit") %>' />
                            </EditItemTemplate>
                            <ItemTemplate>
                                <asp:CheckBox ID="cbApprovePatientEdit" runat="server" Checked='<%# Bind("AllowPatientEdit") %>' Enabled="false" />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Allow Patient Delete">
                            <EditItemTemplate>
                                <asp:CheckBox ID="cbApprovePatientDelete" runat="server" Checked='<%# Bind("AllowPatientDelete") %>' />
                            </EditItemTemplate>
                            <ItemTemplate>
                                <asp:CheckBox ID="cbApprovePatientDelete" runat="server" Checked='<%# Bind("AllowPatientDelete") %>' Enabled="false" />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="OTP User">
                            <EditItemTemplate>
                                <asp:CheckBox ID="cbOTPUser" runat="server" Checked='<%# Bind("OTPUsers") %>' />
                            </EditItemTemplate>
                            <ItemTemplate>
                                <asp:CheckBox ID="cbOTPUser" runat="server" Checked='<%# Bind("OTPUsers") %>' Enabled="false" />
                            </ItemTemplate>
                        </asp:TemplateField>


                        <%--new BIll Check--%>


                        <asp:TemplateField HeaderText="Allow Bill Delete">
                            <EditItemTemplate>
                                <asp:CheckBox ID="cbApproveBillDelete" runat="server" Checked='<%# Bind("AllowBillDelete") %>' />
                            </EditItemTemplate>
                            <ItemTemplate>
                                <asp:CheckBox ID="cbApproveBillDelete" runat="server" Checked='<%# Bind("AllowBillDelete") %>' Enabled="false" />
                            </ItemTemplate>
                        </asp:TemplateField>



                        <asp:TemplateField HeaderText="All Patient Records">
                            <EditItemTemplate>
                                <asp:CheckBox ID="cbAllPatientRecords" runat="server" Checked='<%# Bind("AllPatientRecords") %>' />
                            </EditItemTemplate>
                            <ItemTemplate>
                                <asp:CheckBox ID="cbAllPatientRecords" runat="server" Checked='<%# Bind("AllPatientRecords") %>' Enabled="false" />
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Rate Box">
                            <EditItemTemplate>
                                <asp:CheckBox ID="cbtestrate" runat="server" Checked='<%# Bind("Allowtestbox") %>' />
                            </EditItemTemplate>
                            <ItemTemplate>
                                <asp:CheckBox ID="cbtestrate" runat="server" Checked='<%# Bind("Allowtestbox") %>' Enabled="false" Style="width: 50px !important;" />
                            </ItemTemplate>
                        </asp:TemplateField>


                        <asp:TemplateField HeaderText="Emp Code" Visible="true">
                            <EditItemTemplate>
                                <asp:TextBox ID="txtEmpCode" runat="server" Text='<%# Bind("Emp_Code") %>'></asp:TextBox>
                            </EditItemTemplate>
                            <ItemTemplate>
                                <asp:Label ID="lblEmpCode" runat="server" Text='<%# Bind("Emp_Code") %>'></asp:Label>
                            </ItemTemplate>
                        </asp:TemplateField>


                        <asp:TemplateField HeaderText="Allow Test Rate">
                            <EditItemTemplate>
                                <asp:CheckBox ID="cbAllowTestRate" runat="server" Checked='<%# Bind("AllowTestRate") %>' />
                            </EditItemTemplate>
                            <ItemTemplate>
                                <asp:CheckBox ID="cbAllowTestRate" runat="server" Checked='<%# Bind("AllowTestRate") %>' Enabled="false" />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Allow OPD">
                            <EditItemTemplate>
                                <asp:CheckBox ID="cbAllowOPD" runat="server" Checked='<%# Bind("OpdAllow") %>' />
                            </EditItemTemplate>
                            <ItemTemplate>
                                <asp:CheckBox ID="cbAllowOPD" runat="server" Checked='<%# Bind("OpdAllow") %>' Enabled="false" />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Allow lab">
                            <EditItemTemplate>
                                <asp:CheckBox ID="cbAllowlab" runat="server" Checked='<%# Bind("allow_lab") %>' />
                            </EditItemTemplate>
                            <ItemTemplate>
                                <asp:CheckBox ID="cbAllowlab" runat="server" Checked='<%# Bind("allow_lab") %>' Enabled="false" />
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Allow ultra">
                            <EditItemTemplate>
                                <asp:CheckBox ID="cbAllowultra" runat="server" Checked='<%# Bind("allow_ultra") %>' />
                            </EditItemTemplate>
                            <ItemTemplate>
                                <asp:CheckBox ID="cbAllowultra" runat="server" Checked='<%# Bind("allow_ultra") %>' Enabled="false" />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Allow Ctscan">
                            <EditItemTemplate>
                                <asp:CheckBox ID="cbAllowctscan" runat="server" Checked='<%# Bind("allow_ctscan") %>' />
                            </EditItemTemplate>
                            <ItemTemplate>
                                <asp:CheckBox ID="cbAllowctscan" runat="server" Checked='<%# Bind("allow_ctscan") %>' Enabled="false" />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Allow Xray">
                            <EditItemTemplate>
                                <asp:CheckBox ID="cbAllowxray" runat="server" Checked='<%# Bind("allow_xray") %>' />
                            </EditItemTemplate>
                            <ItemTemplate>
                                <asp:CheckBox ID="cbAllowxray" runat="server" Checked='<%# Bind("allow_xray") %>' Enabled="false" />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Allow B_Bank">
                            <EditItemTemplate>
                                <asp:CheckBox ID="cbAllowBloodbank" runat="server" Checked='<%# Bind("allow_b_bank") %>' />
                            </EditItemTemplate>
                            <ItemTemplate>
                                <asp:CheckBox ID="cbAllowBloodbank" runat="server" Checked='<%# Bind("allow_b_bank") %>' Enabled="false" />
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Block User">
                            <EditItemTemplate>
                                <asp:CheckBox ID="cbBlockUser" runat="server" Checked='<%# Bind("BlockUser") %>' />
                            </EditItemTemplate>
                            <ItemTemplate>
                                <asp:CheckBox ID="cbBlockUser" runat="server" Checked='<%# Bind("BlockUser") %>' Enabled="false" />
                            </ItemTemplate>
                        </asp:TemplateField>

                        <%-- Pharmacy Rights --%>
                        <asp:TemplateField HeaderText="Allow Pharmacy">
                            <EditItemTemplate>
                                <asp:CheckBox ID="cbAllowPharmacy" runat="server" Checked='<%# Bind("AllowPharmacy") %>' />
                            </EditItemTemplate>
                            <ItemTemplate>
                                <asp:CheckBox ID="cbAllowPharmacy" runat="server" Checked='<%# Bind("AllowPharmacy") %>' Enabled="false" />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="General Items">
                            <EditItemTemplate>
                                <asp:CheckBox ID="cbAllowGeneralItems" runat="server" Checked='<%# Bind("AllowGeneralItems") %>' />
                            </EditItemTemplate>
                            <ItemTemplate>
                                <asp:CheckBox ID="cbAllowGeneralItems" runat="server" Checked='<%# Bind("AllowGeneralItems") %>' Enabled="false" />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Show Budget Btn">
                            <EditItemTemplate>
                                <asp:CheckBox ID="cbIsShowBudget" runat="server" Checked='<%# Bind("IsShowBudget") %>' />
                            </EditItemTemplate>
                            <ItemTemplate>
                                <asp:CheckBox ID="cbIsShowBudget" runat="server" Checked='<%# Bind("IsShowBudget") %>' Enabled="false" />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <%--  Show Budget View Button Rights on PR and PO  --%>
                        <%-- Show UnApprove Button on Inventory --%>
                        <asp:TemplateField HeaderText="Inventory UnApprove">
                            <EditItemTemplate>
                                <asp:CheckBox ID="cbIsInventoryUnApprove" runat="server" Checked='<%# Bind("IsInventoryUnApprove") %>' />
                            </EditItemTemplate>
                            <ItemTemplate>
                                <asp:CheckBox ID="cbIsInventoryUnApprove" runat="server" Checked='<%# Bind("IsInventoryUnApprove") %>' Enabled="false" />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <%--  Show UnApprove Button on Inventory  --%>
                        <%-- Show After PRF Approval Notfication Show to Creator --%>
                        <asp:TemplateField HeaderText="PRFs Notifications">
                            <EditItemTemplate>
                                <asp:CheckBox ID="cbIsNotificationViewed" runat="server" Checked='<%# Bind("IsNotificationViewed") %>' />
                            </EditItemTemplate>
                            <ItemTemplate>
                                <asp:CheckBox ID="cbIsNotificationViewed" runat="server" Checked='<%# Bind("IsNotificationViewed") %>' Enabled="false" />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <%--  Show UnApprove Button on Inventory  --%>
                    </Columns>                  
                   <SortedAscendingCellStyle CssClass="sortasc-row"></SortedAscendingCellStyle>
                    <SortedAscendingHeaderStyle CssClass="sortasc-header"></SortedAscendingHeaderStyle>
                    <SortedDescendingCellStyle CssClass="sortdesc-row"></SortedDescendingCellStyle>
                    <SortedDescendingHeaderStyle CssClass="sortdesc-header"></SortedDescendingHeaderStyle>
                </asp:GridView>
                <asp:Label ID="lblMessage" runat="server" />
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
