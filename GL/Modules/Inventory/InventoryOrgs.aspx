<%@ Page Language="C#" AutoEventWireup="true" MasterPageFile="~/Site.Master" CodeBehind="InventoryOrgs.aspx.cs" Inherits="PMS.InventoryOrgs" %>


<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script type="text/javascript">
        function NewPage() {
            window.location = "InventoryOrgs.aspx";
        }
        function Validate() {
            debugger;

            var val = document.getElementById("hdnDuplicateCheck").value;
            var returnVal = false;
            if (val == "0")//no duplicate
            {
                document.getElementById("hdnDuplicateCheck").value = "1";
            }
            else {

                alert("Processing Please Wait");
                return false;
            }

        }
  </script>
    </asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <input type="hidden" name="hdnDuplicateCheck" value="0" id="hdnDuplicateCheck" />
   <table style="padding: 20px; width: 633px; height: 210px;min-height: 252px;">
        <tr>
            <td style="width: 230px;">
                <asp:Label Text="Org Code" runat="server" ID="lblItem_Code" />
            </td>
            <td style="width: 203px;">
                
                <asp:TextBox runat="server" ID="txtItem_Code" disabled="disabled" value="(New)" />
                <asp:HiddenField ID="hdfItem_Code" runat="server" />
            </td>
        </tr>
 
        <tr>
            <td>
                <asp:Label Text="Orgs Name *" runat="server" ID="lblname" />
                <asp:RequiredFieldValidator ID="RequiredtxtProduct_Description" runat="server" ErrorMessage="Name is Required" Text="*" ControlToValidate="txtOrg_Name"></asp:RequiredFieldValidator>
            </td>
            <td colspan="3">
                <asp:TextBox runat="server" ID="txtOrg_Name"  Style="width: 527px  !important;" />
                
            </td>
            
        </tr>
     <tr>
            <td></td>
           
            <td>
  <asp:Button Text="Save" ID="btnSave" Style="width: 88px; margin-left: -92px;" runat="server" OnClick="btnSave_Click" onClientClick=" return Validate();"/>
            </td>
            <td>
                <input type="button" value="New" onclick="NewPage()" style="margin-left: -137px;width: 88px;" />
            </td>
        </tr>
        <tr>
            <td colspan="6">
                <asp:ValidationSummary ID="ValidationSummary1" runat="server" ForeColor="Red" HeaderText="Page Errors"
                    ShowSummary="true" DisplayMode="List" />
            </td>
        </tr>
        <tr>
            <td colspan="6">
                <asp:Label ID="lblMessage" runat="server" />
            </td>
        </tr>
    </table>
</asp:Content>