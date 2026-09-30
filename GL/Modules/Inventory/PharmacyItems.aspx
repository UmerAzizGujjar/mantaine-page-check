<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="PharmacyItems.aspx.cs" Inherits="PMS.WebForm2" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script type="text/javascript">
        $(function () {

            Sys.WebForms.PageRequestManager.getInstance().add_pageLoaded(function (evt, args) {
                $("#ctl00_MainContent_txtExpiry_Date").datepicker({ dateFormat: 'mm/dd/yy' });
            });
        }); 
        function ViewPage() {
            window.open = "MedicineView.aspx";
            
           
        }
        function NewPage() {
            window.location = "PharmacyItems.aspx";
            $('#ctl00_MainContent_btnSave').val("Update");

            $('#ctl00_MainContent_txtItem_Code').val("New");
            $('#ctl00_MainContent_hdfItem_Code').val("");
        }
        function Validate() {
           
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
           

            //if (chkpharcy == true) {
                
            //    if (Salt == "0") {
            //        alert('Please Select Salt');
            //        return false;

            //    }
            //    if (Unit == "0") {
            //        alert('Please Select Unit');
            //        return false;
            //    }
            //    if (Purchase_Rate == "") {
            //        alert('Please Select Purchase Rate');
            //        return false;
            //    }
            //}
           
        }
        function EnableField() {
            var check = document.getElementById('ctl00_MainContent_chckPack').checked;
            if (check == true) {
                document.getElementById("ctl00_MainContent_txtQuantity").disabled = false;
                document.getElementById("ctl00_MainContent_ddlPackUnit").disabled = false;
            }
            else {
                document.getElementById("ctl00_MainContent_txtQuantity").disabled = true;
                document.getElementById("ctl00_MainContent_ddlPackUnit").disabled = true;
            }
        }
    </script>
    <style type="text/css">
        /*textarea, select, input[type="text"], input[type="password"] {
            width: 230px !important;
        }*/
        select {
            float: left;
        }

        .ColWidth {
            width: 207px;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <input type="hidden" name="hdnDuplicateCheck" value="0" id="hdnDuplicateCheck" />
   <table style="padding: 20px; width: 950px; height: 210px;min-height: 347px;">
        <tr>
            <td style="width: 230px;">
                <asp:Label Text="Item Code *" runat="server" ID="lblItem_Code" />
            </td>
            <td style="width: 203px;">
                
                <asp:TextBox runat="server" ID="txtItem_Code" disabled="disabled" value="(New)" />
                <asp:HiddenField ID="hdfItem_Code" runat="server" />
            </td>
             <td  style="width: 92px;">
            </td>
            <td style="width: 203px;">
               
            </td>
            <td style="width: 192px;">
               
            </td>
            <td style="width: 133px;">
               
            </td>
           <%-- <td  style="width: 92px;">
                <asp:Label Text="Sales Rate *" runat="server" ID="lblSalesRate" />
            </td>
            <td style="width: 203px;">
                <asp:TextBox runat="server" ID="txtSales_Rate" />
                <asp:RangeValidator ErrorMessage="Enter a valid amount." Text="*" SetFocusOnError="true"
                    Display="Dynamic" Type="Currency" ID="RangeValidator3" ControlToValidate="txtSales_Rate" runat="server" MinimumValue="0" MaximumValue="9999999999" />
            </td>
            <td   style="width: 179px;">
                <asp:Label Text="Purchase Rate *" runat="server" ID="Label1" />
            </td>
            <td>
                <asp:TextBox runat="server" ID="txtPurchase_Rate" />
                <asp:RangeValidator ErrorMessage="Enter a valid amount." Text="*" SetFocusOnError="true"
                    Display="Dynamic" Type="Currency" ID="RangeValidator1" ControlToValidate="txtPurchase_Rate" runat="server" MinimumValue="0" MaximumValue="9999999999" />
                </td>
                
                <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ErrorMessage="Sale Amount is Required"  ControlToValidate="txtSales_Rate"></asp:RequiredFieldValidator>--%>
        </tr>
        <tr>
            <td></td>
            <td></td>
        </tr>
        <tr>
            <td></td>
            <td></td>
        </tr>
        <tr>
            <td>
                <asp:Label Text="Item Name *" runat="server" ID="lblDescription" />
                <asp:RequiredFieldValidator ID="RequiredtxtProduct_Description" runat="server" ErrorMessage="Description is Required" Text="*" ControlToValidate="txtDescription"></asp:RequiredFieldValidator>
            </td>
            <td colspan="3">
                <asp:TextBox runat="server" ID="txtDescription"  Style="width: 527px  !important;" />
                
            </td>
            <td>
                <asp:Label ID="Label4" Text="Genaric Name" runat="server" />
            </td>
            <td>
                <asp:TextBox runat="server" ID="ddlSalt"  Style="width: 168px;" />
              <%--<asp:DropDownList ID="" runat="server" AppendDataBoundItems="true" ></asp:DropDownList>--%>
            </td>
            
        </tr>
       <tr>
            <td  style="width: 92px;">
                <asp:Label Text="Sales Rate *" runat="server" ID="lblSalesRate" />
            </td>
            <td style="width: 203px;">
                <asp:TextBox runat="server" ID="txtSales_Rate" />
                <asp:RangeValidator ErrorMessage="Enter a valid amount." Text="*" SetFocusOnError="true"
                    Display="Dynamic" Type="Currency" ID="RangeValidator3" ControlToValidate="txtSales_Rate" runat="server" MinimumValue="0" MaximumValue="9999999999" />
            </td>
            <td   style="width: 179px;">
                <asp:Label Text="Purchase Rate *" runat="server" ID="Label1" />
            </td>
            <td>
                <asp:TextBox runat="server" ID="txtPurchase_Rate" />
                <asp:RangeValidator ErrorMessage="Enter a valid amount." Text="*" SetFocusOnError="true"
                    Display="Dynamic" Type="Currency" ID="RangeValidator1" ControlToValidate="txtPurchase_Rate" runat="server" MinimumValue="0" MaximumValue="9999999999" />
                </td>
                
                <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ErrorMessage="Sale Amount is Required"  ControlToValidate="txtSales_Rate"></asp:RequiredFieldValidator>
            <td>
                <asp:Label ID="Label2" Text="Item Type *" runat="server" />
            </td>
            <td>
                <asp:DropDownList ID="ddlItem_Type" runat="server" AppendDataBoundItems="true" ></asp:DropDownList>
            </td>
        </tr>
       <tr>
            <td></td>
            <td></td>
        </tr>
        <tr>
            <td></td>
            <td></td>
        </tr>
           <tr>
            <td>
                <asp:Label Text="Item Main Catagory *" runat="server" ID="Label3" />
            </td>
            <td>

               <asp:DropDownList ID="ddlMainCatagory" runat="server" AppendDataBoundItems="true" ></asp:DropDownList>
            </td>
            
            <td>
                <asp:Label ID="Label5" Text="Unit" runat="server" />
            </td>
            <td>
                <asp:DropDownList ID="ddlUnit" runat="server" AppendDataBoundItems="true" ></asp:DropDownList>
            </td>
               <td>
                <asp:Label ID="Label9" Text="Manufacturer" runat="server" />
            </td>
            <td>
                <asp:DropDownList ID="ddlManufacturer" runat="server" AppendDataBoundItems="true" ></asp:DropDownList>
            </td>
        </tr>
       <tr>
            <td></td>
            <td></td>
        </tr>
        <tr>
            <td></td>
            <td></td>
        </tr>
         <tr>
            <td>
                <asp:Label Text="Minimum Stock" runat="server" ID="Label6" />
            </td>
            <td>
                <asp:TextBox runat="server" ID="txtMinimum_Stock"  Style="width: 168px;" />
            </td>
            <td>
                <asp:Label ID="Label7" Text="Maximum Stock" runat="server" />
            </td>
            <td>
                <asp:TextBox runat="server" ID="txtMaximum_Stock"  Style="width: 168px;" />
            </td>
            <td>
                <asp:Label ID="Label8" Text="Reorder Stock" runat="server" />
            </td>
            <td>
                 <asp:TextBox runat="server" ID="txtReorder_Stock"  Style="width: 168px;" />
            </td>
        </tr>
       <tr>
           <td>
                <asp:Label ID="Label12" Text="ATC" runat="server" />
            </td>
            <td>
                 <asp:TextBox runat="server" ID="txtATC"  Style="width: 168px;" />
            </td>
           </tr>
       <tr>
            <td></td>
            <td></td>
        </tr>
        <tr>
            <td></td>
            <td></td>
        </tr>
         <tr>
             <td>Refigrator</td>
            <td>
                <asp:CheckBox ID="chckRefigrator" runat="server" Width="20px" Height="16px"></asp:CheckBox>
            </td>
              <td>Active</td>
            <td>
                <asp:CheckBox ID="chckActive" runat="server"  Width="20px" Height="16px"></asp:CheckBox>
            </td>
             <td>
                <asp:Label ID="lblNotes" Text="Notes" runat="server" />
            </td>
            <td>
                <asp:TextBox runat="server" ID="TxtNotes"  Style="width: 168px;" TextMode="MultiLine" />
            </td>
            
        </tr>
       <tr>
            <td></td>
            <td></td>
        </tr>
        <tr>
            <td></td>
            <td></td>
        </tr>
      <tr>
          <td>Pack</td>
            <td>
                <asp:CheckBox ID="chckPack" runat="server" onclick="EnableField()" Width="20px" Height="16px"></asp:CheckBox>
            </td>
           <td>
                <asp:Label ID="Label10" Text="Pack Quantity" runat="server" />
            </td>
            <td>
                <asp:TextBox runat="server" ID="txtQuantity"  Style="width: 168px;" disabled="disabled" />
            </td>
            <td>
                <asp:Label ID="Label11" Text="Pack Unit" runat="server" />
            </td>
            <td>
                <asp:DropDownList ID="ddlPackUnit" runat="server" AppendDataBoundItems="true" disabled="disabled" ></asp:DropDownList>
            </td>
      </tr>
       <tr>
           <td>

           </td>
           <td>

           </td>
           </tr>


       <tr>
          <td>Infusion Fluid</td>
            <td>
              <asp:CheckBox ID="Checkinfs" runat="server" Width="20px" Height="16px"></asp:CheckBox>
            </td>
          
           <td>
            Additive Dose
            </td>
            <td>
              <asp:CheckBox ID="Checkadd" runat="server" Width="20px" Height="16px"></asp:CheckBox>
            </td>
      
      </tr>


       <tr>
            <td></td>
            <td></td>
        </tr>
        <tr>
            <td></td>
            <td></td>
        </tr>

       
       <tr>
            <td></td>
            <td>
              <input type="button" value="ListView" onclick="window.open('MedicineView.aspx')" style="margin-left: -25px;width: 88px;     margin-top: 16px;" />
            </td>
            <td>
  <asp:Button Text="Save" ID="btnSave" Style="width: 88px; margin-left: -92px;    margin-top: 16px;" runat="server" OnClick="btnSave_Click" onClientClick=" return Validate();"/>
            </td>
            <td>
                <input type="button" value="New" onclick="NewPage()" style="margin-left: -137px;width: 88px;    margin-top: 16px;" />
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
