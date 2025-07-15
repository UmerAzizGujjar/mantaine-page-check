<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="Company.aspx.cs" Inherits="PMS.Company" Theme="Default_Theme" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <table style="padding: 20px; width: 920px; height: 210px;">
        <tr>
            <td style="width: 120px;">
                <%--Company ID--%>
                Hospital ID
            </td>
            <td style="width:204px;">
                <asp:TextBox ID="txtCompany_ID" runat="server" ReadOnly="True" />
            </td>
            <td style="width:100px;"></td>
            <td style="width:90px;">
                Set Of Book *
            </td>
            <td style="width:204px;">
                <asp:DropDownList runat="server" ID="ddlSetOfBookID" AppendDataBoundItems="true"></asp:DropDownList>
            </td>
            <td>
                <asp:RequiredFieldValidator ID="rfvSetOfBookID" ControlToValidate="ddlSetOfBookID" runat="server" ErrorMessage="Set of book is required." SetFocusOnError="true" InitialValue="0" />
            </td>
        </tr>
        <tr>
            <td>
                <%--Company Name *--%>
                Hospital Name *
            </td>
            <td>
                <asp:TextBox runat="server" ID="txtCompany_Name" />
            </td>
            <td>
                <asp:RequiredFieldValidator ErrorMessage="Name is required." ControlToValidate="txtCompany_Name" CssClass="validation" ID="rfvCompany_Name" SetFocusOnError="true" runat="server" Display="Dynamic" />
            </td>
            <td>
                Email
            </td>
            <td>
                <asp:TextBox ID="txtCompany_Email" runat="server" />
            </td>
            <td>
                <asp:RegularExpressionValidator ErrorMessage="Invalid email." ControlToValidate="txtCompany_Email" runat="server" CssClass="validation" ID="reCompany_Email" SetFocusOnError="true" Display="Dynamic" ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" />
            </td>
        </tr>
        
        <tr>
            <td>
                Phone 1
            </td>
            <td>
                <asp:TextBox runat="server" ID="txtCompany_Phone1" MaxLength="15" />
                
            </td>
            <td></td>
            <td>
                Phone 2
            </td>
            <td>
                <asp:TextBox runat="server" ID="txtCompany_Phone2" MaxLength="15" />
             
            </td>
            <td></td>
        </tr>

        <tr>
            <td>
                User Field 1
            </td>
            <td>
                <asp:TextBox runat="server" ID="txtCompany_UserField1" />
            </td>
            <td></td>
            <td>
                User Field 2
            </td>
            <td>
                <asp:TextBox runat="server" ID="txtCompany_UserField2" />
            </td>
            <td></td>
        </tr>
        <tr>
            <td>
                User Field 3
            </td>
            <td>
                <asp:TextBox runat="server" ID="txtCompany_UserField3" />
            </td>
            <td></td>
            <td>
                Fax
            </td>
            <td>
                <asp:TextBox runat="server" ID="txtCompany_Fax" />
             
            </td>
            <td></td>
        </tr>
        
        <tr>
            <td>
                Sales Tax Reg. No.
            </td>
            <td>
                <asp:TextBox runat="server" ID="txtCompany_SalesTax_No" />
            </td>
            <td></td>
            <td>
                NTN No.
            </td>
            <td>
                <asp:TextBox runat="server" ID="txtCompany_NTN_No" />
            </td>
            <td></td>
        </tr>
        <tr>
            <td>
                Address
            </td>
            <td>
                <asp:TextBox runat="server" ID="txtCompany_Address" TextMode="MultiLine" />
            </td>
            <td></td>
            <td>
                Fiscal Year
            </td>
            <td>
                <asp:TextBox runat="server" ID="txtCompany_Fical_Year" />
            </td>
            <td></td>
        </tr>
        <tr>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td>
                <asp:CheckBox ID="cbAutoPosting" runat="server" Text="Auto Posting" />
            </td>
            <td></td>
        </tr>
        
        <tr>
            <td></td>
            <td>
                <asp:PlaceHolder runat="server" ID="phCompany_Image">
                    <asp:Image runat="server" ID="imgCompany_Image" Width="90" Height="95" />
                </asp:PlaceHolder>
            </td>
            <td colspan="4"></td>
        </tr>
        <tr>

            <td>
                Hospital Image
            </td>
            <td>
                <asp:FileUpload ID="fluImage" runat="server" Width="183px" />
            </td>
            <td colspan="4"></td>
        </tr>
        <tr>
            <td></td>
            <td>
                <br />
                <asp:Button Text="Back" runat="server" Width="95px" ID="btnBack" CausesValidation="false" PostBackUrl="~/CompanyView.aspx" />
                &nbsp;
                 <asp:Button Text="Save" runat="server" Width="95px" ID="btnSave" OnClick="btnSave_Click" />
            </td>
            <td colspan="4"></td>
        </tr>
        <tr>
            <td colspan="6">
                <asp:Label ID="lblMessage" Text="" runat="server" />
            </td>
        </tr>
        <tr>
            <td colspan="6">
                <%--<asp:ValidationSummary ID="ValidationSummary1" runat="server" ForeColor="Red" HeaderText="Page Errors"
                    ShowSummary="true" DisplayMode="List" />--%>
            </td>
        </tr>
    </table>
</asp:Content>
