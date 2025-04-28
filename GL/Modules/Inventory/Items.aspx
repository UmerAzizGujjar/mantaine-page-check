<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Items.aspx.cs" Inherits="PMS.Items" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

    <script type="text/javascript">
        $(function () {
            $("#tabs").tabs();
            //            CheckAccountExistance();
            FillAccountCategory();

            Sys.WebForms.PageRequestManager.getInstance().add_pageLoaded(function (evt, args) {
                $("#ctl00_MainContent_txtExpiry_Date").datepicker({ dateFormat: 'mm/dd/yy' });
            });
        });
        function NewPage() {
            window.location = "Items.aspx";
            $('#ctl00_MainContent_btnSave').val("Update");

            $('#ctl00_MainContent_txtItem_Code').val("New");
            $('#ctl00_MainContent_hdfItem_Code').val("");
        }


        function CheckAccountExistance() {

            debugger;
            var getaccount_ID = $('#ddlfiance_integration').val();
            if (getaccount_ID > 0) {
                var ID = getaccount_ID;
                PageMethods.CheckAccount(ID, function (Tests) {
                    debugger
                    var message = JSON.parse(Tests);
                    //if (message[0].Column1 != null || message[0].Column1 != "" || message[0].Column1 != "1") {
                    if (message[0].Column1 != "1") {

                        alert(message[0].Column1);
                        $('#ddlfiance_integration').val(0).trigger('change');
                    }

                });
            }
        }

        function FillAccountCategory() {
            debugger;
            var optionsAccCategory = '<option value="0">Please Select</option>';

            PageMethods.getAccountCategory(function (Tests) {
                debugger
                $.each(JSON.parse(Tests), function (key, value) {
                    debugger;
                    optionsAccCategory += '<option value="' + value.Account_Category_Id + '" >' + value.CategoryName + '</option>';
                });
                $('#ddlfiance_integration').html(optionsAccCategory);
            });
        }



        function SaveBroughtByInformation() {


            var val = document.getElementById("hdnDuplicateCheck").value;
            var returnVal = false;
            if (val == "0")//no duplicate
            {
                document.getElementById("hdnDuplicateCheck").value = "1";
            }
            else {
                alert("Processing Please Wait");
                returnVal = false;
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
    <table style="padding: 20px; width: 850px; height: 210px;">
        <tr>
            <td style="width: 160px;">
                <asp:Label Text="Item Code *" runat="server" ID="lblItem_Code" />
            </td>
            <td style="width: 203px;">
                <asp:TextBox runat="server" ID="txtItem_Code" disabled="disabled" value="(New)" />
                <asp:HiddenField ID="hdfItem_Code" runat="server" />
            </td>
            <td>
                <asp:Label Text="Sales Rate" runat="server" ID="lblSalesRate" />
            </td>
            <td>
                <asp:TextBox runat="server" ID="txtSales_Rate" />
                <asp:RangeValidator ErrorMessage="Enter a valid amount." Text="*" SetFocusOnError="true"
                    Display="Dynamic" Type="Currency" ID="RangeValidator3" ControlToValidate="txtSales_Rate" runat="server" MinimumValue="0" MaximumValue="9999999999" />
            </td>

            <td>
                <asp:Label Text="Procedure Types" runat="server" ID="lblProcedureTypes" Style="font-size: 20px;" /></td>
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
                <asp:Label Text="Description " runat="server" ID="lblDescription" />
            </td>
            <td>
                <asp:TextBox runat="server" ID="txtDescription" TextMode="MultiLine" Style="width: 168px;" />
                <asp:RequiredFieldValidator ID="RequiredtxtProduct_Description" runat="server" ErrorMessage="Description is Required" Text="*" ControlToValidate="txtDescription"></asp:RequiredFieldValidator>
            </td>
            <td>
                <asp:Label ID="lblNotes" Text="Notes" runat="server" />
            </td>
            <td>
                <asp:TextBox runat="server" ID="TxtNotes" TextMode="MultiLine" Style="width: 168px;" />
            </td>
            <td></td>
        </tr>
        <tr>
            <td>Services Item </td>
            <td>
                <asp:CheckBox ID="chkPallor" runat="server"></asp:CheckBox>
            </td>
            <td>Liability Item </td>
            <td>
                <asp:CheckBox ID="chkLiabilityItem" runat="server"></asp:CheckBox>
            </td>
        </tr>
        <tr>
            <td>Lab/Radiology Charges</td>
            <td>
                <asp:CheckBox ID="chkLaborRadiologyCharges" runat="server"></asp:CheckBox>
            </td>
            <td>Physio Item</td>
            <td>
                <asp:CheckBox ID="chkPhysioItem" runat="server"></asp:CheckBox>
            </td>
        </tr>
        <tr>
            <td>Dental Item</td>
            <td>
                <asp:CheckBox ID="chkDentalItem" runat="server"></asp:CheckBox>
            </td>
            <td>Derma Item</td>
            <td>
                <asp:CheckBox ID="chkDermaItem" runat="server"></asp:CheckBox>
            </td>
        </tr>
        <tr>
            <td>Hospital Services</td>
            <td>
                <asp:CheckBox ID="chkHospital_services" runat="server"></asp:CheckBox>
            </td>
            <td>Active</td>
            <td>
                <asp:CheckBox ID="ChkBillingItem" runat="server"></asp:CheckBox>
            </td>
        </tr>
        <tr>
            <td>
                <asp:Label Text="Manufacture Part No." runat="server" ID="lblManufacture_Part_No" Visible="false" />
            </td>
            <td>
                <asp:TextBox runat="server" ID="txtManufacture_Part_No" Visible="false" />
            </td>
            <td colspan="4"></td>
        </tr>
        <tr>
            <td style="width: 84px;">
                <label for="chkOTProcedure">OT Procedure</label>
            </td>
            <td>

                <asp:CheckBox ID="chkOTProcedure" runat="server"></asp:CheckBox>
            </td>
            <td style="width: 84px;">
                <label for="chkPayment">Payment</label>
            </td>
            <td>

                <asp:CheckBox ID="chkPayment" runat="server"></asp:CheckBox>
            </td>
            <td style="width: 144px;">
                <label for="chkExpensiveMedicine">Expensive Medicine</label>
            </td>
            <td>

                <asp:CheckBox ID="chkExpensiveMedicine" runat="server"></asp:CheckBox>
            </td>

        </tr>
        <tr>
            <td style="width: 84px;">
                <label for="chkInfusion_Fluid">Infusion Fluid</label>
            </td>
            <td>

                <asp:CheckBox ID="chkInfusion_Fluid" runat="server"></asp:CheckBox>
            </td>
            <td style="width: 84px;">
                <label for="chkAdditive_Dose">Additive Dose</label>
            </td>
            <td>

                <asp:CheckBox ID="chkAdditive_Dose" runat="server"></asp:CheckBox>
            </td>
        </tr>
        <tr>
            <td style="width: 84px;">
                <label for="chkInfusion_Fluid">Special Test</label>
            </td>
            <td>

                <asp:CheckBox ID="chkSpecialTest" runat="server"></asp:CheckBox>
            </td>


            <td>
                <label id="Lblfiance_integration">Account Category</label>

            </td>
            <td>
                <asp:DropDownList ID="ddlfiance_integration" runat="server" AppendDataBoundItems="true"></asp:DropDownList>
                <asp:RequiredFieldValidator ID="ddlfiance_integrationdrpdown" runat="server" ErrorMessage="Account Category is Required" Text="*" ControlToValidate="ddlfiance_integration"></asp:RequiredFieldValidator>
            </td>

        </tr>

        <tr>
            <td>UOM</td>
            <td>
                <asp:DropDownList ID="ddlpack_unit" runat="server" AppendDataBoundItems="true"></asp:DropDownList>

            </td>
            <td>UOM Quantity</td>
            <td>
                <asp:TextBox runat="server" ID="txt_UOMQty" />
                <asp:RequiredFieldValidator ID="txt_UOMQtyvalidate" runat="server" ErrorMessage="UOM Quantity is Required" Text="*" ControlToValidate="txt_UOMQty"></asp:RequiredFieldValidator>

            </td>
        </tr>


        <tr>

            <td>Generic Name</td>
            <td>
                <asp:TextBox runat="server" ID="GenericName" />

            </td>

            <td>Batch</td>
            <td>
                <asp:CheckBox ID="IsBatch" runat="server"></asp:CheckBox>
            </td>

        </tr>
        <tr>
            <td>Narcotics</td>
            <td>
                <asp:CheckBox ID="Narcotics" runat="server"></asp:CheckBox>
            </td>
            <td>Refregrator</td>
            <td>
                <asp:CheckBox ID="Refregrator" runat="server"></asp:CheckBox></td>

        </tr>
        <tr>
            <td>Controller Drug</td>
            <td>
                <asp:CheckBox ID="controller_drug" runat="server"></asp:CheckBox>
            </td>
            <td>Pharmacy Item</td>
            <td>
                <asp:CheckBox ID="CheckPharmacy" runat="server"></asp:CheckBox>
            </td>
        </tr>

        <tr>
            <td>ATC</td>
            <td>
                <%--<label></label>--%>
                <asp:TextBox runat="server" ID="ATC" />
            </td>
            <td>Manufacturer</td>
            <td>
                <%--<label id="Lblmanufacturer" style="position: relative; width: 82px;">Manufacturer</label>--%>
                <asp:DropDownList ID="ddlmanu" runat="server" AppendDataBoundItems="true"></asp:DropDownList>
                <%-- <select id="ddlmanu" style="position: relative;">
                    <option>Please Select</option>
                </select>--%>
            </td>

        </tr>

        <tr>
            <td>Minimum Stock</td>
            <td>
                <asp:TextBox runat="server" ID="Minimum_Stock" />
            </td>
            <td>Reorder Stock</td>
            <td>
                <asp:TextBox runat="server" ID="Reorder_Stock" />
            </td>
           
        </tr>

        <tr>
              <td>Maximum Stock</td>
            <td>
                <asp:TextBox runat="server" ID="Maximum_Stock" />
            </td>
        </tr>


        <tr>
            <td></td>
            <td>
                <asp:Button Text="List View" runat="server" Width="94px" ID="btnBack" CausesValidation="false" NavigateUrl="~/Inventory/ItemsView.aspx" OnClick="btnBack_Click" />
            </td>
            <td>
                <asp:Button Text="Save" ID="btnSave" Style="width: 94px; margin-left: -92px;" runat="server" OnClick="btnSave_Click" OnClientClick=" return SaveBroughtByInformation();" />
            </td>
            <td>
                <asp:Button Text="New" ID="ButtonNew" Style="margin-left: -65px;" runat="server" PostBackUrl="~/Inventory/Items.aspx" CausesValidation="false" OnClick="btnNew_Click" />
                <%--<input type="button" value="New" onclick="NewPage()" style="margin-left: -73px;" />--%>
            </td>

             <td>
                <asp:Button Text="Pharmacy Items" runat="server" Width="134px" ID="Button1" style="margin-left: -183px;" CausesValidation="false" NavigateUrl="~/PharmacyItemsView.aspx" OnClick="btnPharmacy_Click" />
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


    <div id="procedureTypes" style="border: 1px solid black; position: absolute; width: 322px; height: 60px; margin-left: 661px; margin-top: -168px;">
        <table>
            <tr>
                <td>
                    <asp:Label Text="Level 1" runat="server" Style="margin-left: 14px;"></asp:Label></td>
                <td>
                    <asp:DropDownList ID="ddlProcedureTypes" runat="server" AppendDataBoundItems="true" Style="margin-top: 10px; margin-right: 474px;"></asp:DropDownList>
                </td>
            </tr>
        </table>
    </div>


</asp:Content>
