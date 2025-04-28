<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Quotation.aspx.cs" Inherits="PMS.WebForm7" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script type="text/javascript" src="../Scripts/jquery.tokeninput.js"></script>

    <script type="text/javascript">
        $(document).ready(function () {
            $("#ctl00_MainContent_txtQuotation_Date").datepicker({ dateFormat: 'mm/dd/yy' });
            //numberWithCommas();
            window.onunload = refreshParent;
            function refreshParent() {
                //window.opener.location.reload();
            }

            // var AdjustmentID = $('#<%=txtQuotation_No.ClientID%>').val();

               //if (AdjustmentID != "(New)") {
               //var accountId = $("#ctl00_MainContent_txtAccount_Code_Name").val();
               //  var Item_Code = $("#hdfItem_Code").val();

               //var tokendata = httpGet("../json.aspx?Table=INV_Items&Item_Code=" + Item_Code);
               //oadtokenInputs(JSON.parse(tokendata));
               //}
               //else {
               loadtokenInputsDefault();
               //}


           });


           function loadtokenInputsDefault() {
               $('#ctl00_MainContent_txtItem_Description').tokenInput("../json.aspx?Table=INV_Items",
                {
                    tokenLimit: 1,
                    onAdd: function (item) {
                        $("#hdfItem_ID").val(item.id);
                        $("#hdfItem_Description").val(item.name);
                    }
                });
           }
           function loadtokenInputs(data) {
               $("#ctl00_MainContent_txtItem_Description").tokenInput("../json.aspx?Table=INV_Items",
                   {
                       prePopulate: data,
                       tokenLimit: 1,
                       onAdd: function (item) {
                           $("#hdfItem_ID").val(item.id);
                           $("#hdfItem_Description").val(item.name);
                       }


                   });

           }
           function httpGet(theUrl) {
               var xmlHttp = null;

               xmlHttp = new XMLHttpRequest();
               xmlHttp.open("GET", theUrl, false);
               xmlHttp.send(null);
               return xmlHttp.responseText;
           }


           function GetAccountCodeAndName() {
               //if(ValidateCheckDate()==false)
               //    return false;
              
               var name = '';
               $.each($("#ctl00_MainContent_txtItem_Description").tokenInput('get'), function () {
                   if (name != '') {
                       name += ",";
                   }
                   name += this.name;
               });
               $("#hdfitem_name").val(name);
               
           }

           function callTotal() {

               var num1 = parseInt(document.getElementById('<%= txtQty.ClientID %>').value);
               var num2 = parseInt(document.getElementById('<%= txtRate.ClientID %>').value);
               if (isNaN(num1))
                   num1 = 0;
               if (isNaN(num2))
                   num2 = 0;

               document.getElementById('<%= txtAmount.ClientID %>').value = Math.round(num1 * num2, 2);
           }

        function NetAmount() {

            var Sub_total = parseInt(document.getElementById('<%= txtSub_Total.ClientID %>').value);
            var Discount = parseInt(document.getElementById('<%= txtDiscount.ClientID %>').value);
            var Import = parseInt(document.getElementById('<%= txtImport_Frieght_Charges.ClientID %>').value);
            var Export = parseInt(document.getElementById('<%= txtExport_Frieght_Charges.ClientID %>').value);
            var Del = parseInt(document.getElementById('<%= txtDel_Charges.ClientID %>').value);
            var Bank = parseInt(document.getElementById('<%= txtBank_TT_Charges.ClientID %>').value);
            var Doc = parseInt(document.getElementById('<%= txtCutom_DOC_Charges.ClientID %>').value);

            if (isNaN(Discount))
                Discount = 0;

            if (isNaN(Import))
                Import = 0;

            if (isNaN(Export))
                Export = 0;
            if (isNaN(Del))
                Del = 0;
            if (isNaN(Bank))
                Bank = 0;
            if (isNaN(Doc))
                Doc = 0;
            

               document.getElementById('<%= TxtQuotation_Amount.ClientID %>').value = Math.round((Sub_total + Import + Export + Del + Bank + Doc) - Discount, 2);
           }


    </script>
    <style type="text/css">
        
        .auto-style7 {
            width: 133px;
            height: 17px;
        }

        .auto-style8 {
            height: 17px;
            width: 83px;
        }

        .auto-style9 {
            width: 83px;
        }

        .auto-style10 {
            width: 133px;
        }

        .auto-style11 {
            width: 153px;
            height: 17px;
        }

        .auto-style12 {
            width: 153px;
        }

        .auto-style16 {
            width: 132px;
        }

        .auto-style19 {
            width: 119px;
            height: 17px;
        }

        .auto-style20 {
            width: 119px;
        }

        .auto-style21 {
            width: 147px;
            height: 17px;
        }

        .auto-style22 {
            width: 147px;
        }

        .auto-style23 {
            height: 17px;
            width: 82px;
        }

        .auto-style24 {
            width: 82px;
        }
        .auto-style25 {
            width: 444px;
        }
    </style>


</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <asp:UpdatePanel ID="UpdatePanel1" runat="server" UpdateMode="Conditional">
        <ContentTemplate>

            <asp:Label ID="lblSaveThroughKey" runat="server" AccessKey="V" AssociatedControlID="btnSave">
            </asp:Label>
            <asp:Label ID="lblNewThroughKey" runat="server" AccessKey="N" AssociatedControlID="btnNew">
            </asp:Label>
            <asp:Label ID="lblAddThroughKey" runat="server" AccessKey="A" AssociatedControlID="btnAdd">
            </asp:Label>
            <div style="float: right">
                <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="vocherButton" OnClick="btnSave_Click" />
                <asp:Button ID="btnPrint" runat="server" Text="Print" CssClass="vocherButton" />
                <asp:Button Text="Un Approve" runat="server" ID="btnUnApprove" Visible="false" />
                <asp:Button ID="btnCancel" runat="server" Text="Back" CssClass="vocherButton" CausesValidation="false" />
                <asp:Button ID="btnNew" runat="server" Text="New" CausesValidation="false" CssClass="vocherButton" />
                <hr />
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    <br />
    <div style="width: 900px; float: left">
        <div style="width: 650px; float: left">
            <asp:UpdatePanel runat="server" ID="upForm" UpdateMode="Conditional">
                <Triggers>
                    <asp:AsyncPostBackTrigger EventName="Click" ControlID="btnNew" />
                    <asp:AsyncPostBackTrigger EventName="Click" ControlID="btnSave" />
                </Triggers>
                <ContentTemplate>
                    <table>
                        <tr>
                            <td class="auto-style19"></td>
                            <td class="auto-style11">
                                
                            </td>
                            <td class="auto-style21"></td>
                            <td class="auto-style7">mm/dd/yyyy</td>
                            <td class="auto-style8">
                                <asp:Label ID="LblQuotation_Status" runat="server" Text="Quote Status"></asp:Label>
                            </td>
                            <td class="auto-style23">
                                <asp:TextBox ID="TxtQuotation_Status" runat="server" SkinID="UserDefineWidth" ReadOnly="true"></asp:TextBox>

                            </td>
                        </tr>
                        <tr>
                            <td class="auto-style20">
                                <asp:Label ID="LblQuotation" Text="Quote No." runat="server" />
                            </td>
                            <td class="auto-style12">

                                <asp:TextBox ID="txtQuotation_No" runat="server" SkinID="UserDefineWidth" ReadOnly="true" />
                            </td>
                            <td class="auto-style22">
                                <asp:Label ID="LblQuotation_Date" Text="Quotation Date:" runat="server" />
                            </td>
                            <td class="auto-style10">
                                <asp:TextBox ID="txtQuotation_Date" runat="server" SkinID="UserDefineWidth" />
                                <asp:RequiredFieldValidator ID="rfvQuotation_Date" runat="server" ErrorMessage="please Select Date" ControlToValidate="txtQuotation_Date"></asp:RequiredFieldValidator>
                            </td>
                            <td class="auto-style9">
                                <asp:Label ID="lblRef_No" runat="server" Text="Ref. No"></asp:Label>
                            </td>
                            <td class="auto-style24">
                                <asp:TextBox ID="txtRef_No" runat="server" SkinID="UserDefineWidth" />

                            </td>
                        </tr>
                        <tr>
                            <td class="auto-style20">
                                <asp:Label ID="lblCustomer" Text="Customer" runat="server" />
                            </td>
                            <td class="auto-style12">

                                <asp:DropDownList ID="ddlCustomer" runat="server" Width="150px" AppendDataBoundItems="true"></asp:DropDownList>
                                <asp:RequiredFieldValidator ID="rfvddlCustomer" runat="server" ErrorMessage="Please Select Customer"
                                   InitialValue="0" ControlToValidate="ddlCustomer" ></asp:RequiredFieldValidator>
                            </td>
                            <td class="auto-style22">
                                <asp:Label ID="lblTerm_and_Condition" runat="server"  Text="Term and Condition" >

                                </asp:Label>
                            </td>
                            <td>
                                 <asp:DropDownList ID="ddlTerm_and_Condition" runat="server" Width="150px" AppendDataBoundItems="true"></asp:DropDownList>
                                 <asp:RequiredFieldValidator ID="rfvddlTerm_and_Condition" runat="server" ErrorMessage="Please Select A Term" InitialValue="0"
                                     ControlToValidate="ddlTerm_and_Condition"></asp:RequiredFieldValidator>
                            </td>
                            <td class="auto-style16">
                                <asp:Label ID="lblRemarks" runat="server" Text="Remarks:" />
                            </td>
                            <td class="auto-style24">
                                <asp:TextBox ID="txtRemarks" runat="server" Rows="2" TextMode="MultiLine" SkinID="UserDefineWidth"
                                    Width="250px" />

                            </td>

                        </tr>

                    </table>
                    <br />
                </ContentTemplate>
            </asp:UpdatePanel>

        </div>

    </div>
    <br />
    <br />
    <div style="float: left;">
        <table>
            <tr>

                <td>
                    <asp:UpdatePanel runat="server" ID="upQuotationForm" UpdateMode="Conditional">
                        <Triggers>
                            <asp:AsyncPostBackTrigger EventName="Click" ControlID="btnNew" />
                        </Triggers>
                        <ContentTemplate>
                            <table>
                                <tr>

                                    <td>
                                        <asp:Label ID="lblItem_Description" runat="server" Text="Item Name"></asp:Label>
                                    </td>
                                    <td>
                                        <asp:Label ID="lblStock_Status" runat="server" Text="Stock Status"></asp:Label>
                                    </td>
                                    <td>
                                        <asp:Label ID="LblQuoted_Qty" runat="server" Text=" Qty"></asp:Label>
                                    </td>
                                    <td>
                                        <asp:Label ID="lblRate" runat="server" Text="Rate"></asp:Label></td>
                                    <td></td>

                                    <td>
                                        <asp:Label ID="lblTotal" runat="server" Text="Total"></asp:Label>
                                    </td>
                                </tr>
                                <tr>

                                    <td>
                                        <asp:TextBox ID="txtItem_Description" runat="server" SkinID="UserDefineWidth" Width="170px"></asp:TextBox>
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtStock_Status" runat="server" SkinID="UserDefineWidth" Width="90px"></asp:TextBox></td>
                                    <td>
                                        <asp:TextBox ID="txtQty" runat="server" SkinID="UserDefineWidth" Width="90px" onchange="return callTotal();"></asp:TextBox>
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtRate" runat="server" SkinID="UserDefineWidth" Width="90px" onchange="return callTotal();"></asp:TextBox>

                                    </td>
                                    <td></td>
                                    <td>
                                        <asp:TextBox ID="txtAmount" runat="server" ReadOnly="true" SkinID="UserDefineWidth" Width="90px"></asp:TextBox>

                                    </td>

                                    <td>
                                        <div>
                                            <asp:Button ID="btnAdd" runat="server" ClientIDMode="Static" Text="Add" Width="60px" OnClick="btnAdd_Click"
                                                OnClientClick="GetAccountCodeAndName()" CausesValidation="False" />
                                            &nbsp;
                                                    <asp:Button ID="BtnDelete" runat="server" Text="Delete" Width="60px" OnClick="BtnDelete_Click" CausesValidation="False" />
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="6">
                                        <asp:Label Text="" runat="server" ID="lblValidation" CssClass="errorMessage" /></td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:HiddenField ID="hdfItem_ID" runat="server" ClientIDMode="Static" />
                                        <asp:HiddenField ID="hdfItem_Description" runat="server" ClientIDMode="Static" />
                                    </td>
                                </tr>


                            </table>
                        </ContentTemplate>
                    </asp:UpdatePanel>

                </td>
            </tr>

            <tr>
                <td colspan="2">
                    <div style="width: 900px; float: left">
                        <div>
                            <asp:UpdatePanel runat="server" ID="upGridList" UpdateMode="Conditional">
                                <Triggers>
                                    <asp:AsyncPostBackTrigger ControlID="btnAdd" EventName="Click" />
                                    <asp:AsyncPostBackTrigger ControlID="BtnDelete" EventName="Click" />
                                    <asp:AsyncPostBackTrigger EventName="Click" ControlID="btnNew" />
                                </Triggers>
                                <ContentTemplate>

                                    <asp:GridView ID="GRD" runat="server" BorderStyle="None" AutoGenerateColumns="False"
                                        CellPadding="3" OnRowDataBound="GRD_RowDataBound"
                                        ShowFooter="True" OnSelectedIndexChanging="GRD_SelectedIndexChanging" Style="z-index: -1">
                                        <Columns>
                                            <asp:TemplateField HeaderText="Index" Visible="false">
                                                <ItemTemplate>
                                                    <asp:Label ID="lblIndex" runat="server" Text='<%# Bind("Index") %>'></asp:Label>
                                                </ItemTemplate>
                                                <EditItemTemplate>
                                                    <asp:TextBox ID="TextBox1" runat="server"></asp:TextBox>
                                                </EditItemTemplate>
                                            </asp:TemplateField>


                                            <asp:TemplateField>
                                                <ItemTemplate>
                                                    <asp:LinkButton ID="imgedit" CommandName="select" runat="server">edit</asp:LinkButton>
                                                </ItemTemplate>
                                                <ItemStyle HorizontalAlign="Center" Width="50px" />
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Item ID" Visible="false">
                                                <ItemStyle Width="200px" />
                                                <HeaderStyle Width="200px" />
                                                <ItemTemplate>
                                                    <asp:Label ID="lblItem_ID" runat="server" Text='<%# Bind("Item_ID") %>'></asp:Label>
                                                </ItemTemplate>

                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Item Name">
                                                <ItemStyle Width="260px" />
                                                <HeaderStyle Width="260px" />
                                                <ItemTemplate>
                                                    <asp:Label ID="lblItem_Description" runat="server" Text='<%# Bind("Item_Description") %>'></asp:Label>
                                                </ItemTemplate>

                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Stock Status">
                                                <ItemStyle Width="100px" />
                                                <HeaderStyle Width="100px" />
                                                <ItemTemplate>
                                                    <asp:Label ID="lblStock_Status" runat="server" Text='<%# Bind("Stock_Status") %>'></asp:Label>
                                                </ItemTemplate>

                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Qty">
                                                <ItemStyle Width="100px" />
                                                <HeaderStyle Width="100px" />
                                                <ItemTemplate>
                                                    <asp:Label ID="lblQty" runat="server" Text='<%# Bind("Qty") %>'></asp:Label>
                                                </ItemTemplate>

                                            </asp:TemplateField>

                                            <asp:TemplateField HeaderText="Rate">
                                                <ItemStyle Width="100px" />
                                                <HeaderStyle Width="100px" />
                                                <ItemTemplate>
                                                    <asp:Label ID="lblRate" runat="server" Text='<%# Bind("Rate") %>'></asp:Label>
                                                </ItemTemplate>
                                            </asp:TemplateField>

                                            <asp:TemplateField HeaderText="Total">
                                                <ItemStyle Width="100px" />
                                                <HeaderStyle Width="100px" />
                                                <ItemTemplate>
                                                    <asp:Label ID="lblTotal" runat="server" Text='<%# Bind("Amount") %>'></asp:Label>
                                                </ItemTemplate>

                                            </asp:TemplateField>

                                        </Columns>
                                    </asp:GridView>
                                       <br />
                                    <div>
                                           <table>
            <tr>
                <td class="auto-style25"></td>
                <td></td>
                <td></td>
                <td></td>
                 <td>
                         <asp:Label ID="LblSub_total" Text="Sub Total:" runat="server" />

                     </td>
                                   <td> 
                                       <asp:TextBox runat="server" ID="txtSub_Total" ReadOnly="true" onchange="return NetAmount();" style="text-align:right"  />
                                   </td>
            </tr>
             <tr>
                <td class="auto-style25"></td>
                <td></td>
                <td></td>
                <td></td>
                 <td>
                         <asp:Label ID="LblDiscount" Text="Discount:" runat="server" />

                     </td>
                                   <td> 
                                       <asp:TextBox runat="server" ID="txtDiscount" onchange="return NetAmount();" style="text-align:right" />
                                   </td>
            </tr>
              <tr>
                <td class="auto-style25"></td>
                <td></td>
                <td></td>
                <td></td>
                 <td>
                         <asp:Label ID="LblImport_Frieght_Charges" Text="Import Frieght Charges:" runat="server" />

                     </td>
                                   <td> 
                                       <asp:TextBox runat="server" ID="txtImport_Frieght_Charges" onchange="return NetAmount();" style="text-align:right"/>
                                   </td>
            </tr>
                    <tr>
                <td class="auto-style25"></td>
                <td></td>
                <td></td>
                <td></td>
                 <td>
                         <asp:Label ID="lblExport_Frieght" Text="Export Frieght Charges:" runat="server" />

                     </td>
                                   <td> 
                                       <asp:TextBox runat="server" ID="txtExport_Frieght_Charges" onchange="return NetAmount();" style="text-align:right" />
                                   </td>
            </tr>

              
                    <tr>
                <td class="auto-style25"></td>
                <td></td>
                <td></td>
                <td></td>
                 <td>
                         <asp:Label ID="LblDel_Charges" Text="Del Charges:" runat="server" />

                     </td>
                                   <td> 
                                       <asp:TextBox runat="server" ID="txtDel_Charges" onchange="return NetAmount();" style="text-align:right" />
                                   </td>
            </tr>
                    <tr>
                <td class="auto-style25"></td>
                <td></td>
                <td></td>
                <td></td>
                 <td>
                         <asp:Label ID="LblBank_TT_Charges" Text="Bank TT Charges:" runat="server" />

                     </td>
                                   <td> 
                                       <asp:TextBox runat="server" ID="txtBank_TT_Charges" onchange="return NetAmount();" style="text-align:right" />
                                   </td>
            </tr>
                     <tr>
                <td class="auto-style25"></td>
                <td></td>
                <td></td>
                <td></td>
                 <td>
                         <asp:Label ID="LblCutom_DOC_Charges" Text="Cutom DOC Charges:" runat="server" />

                     </td>
                                   <td> 
                                       <asp:TextBox runat="server" ID="txtCutom_DOC_Charges" onchange="return NetAmount();" style="text-align:right" />
                                   </td>
            </tr>
             <tr>
                    <td class="auto-style25"></td>
                <td></td>
                <td></td>
                <td></td>
                 <td>
                         <asp:Label ID="LblNet_Amount" Text="Net Amount" runat="server" />

                     </td>
                                   <td> 
                                       <asp:TextBox runat="server" ID="TxtQuotation_Amount" ReadOnly="true" style="text-align:right" />
                                   </td>
            </tr>
        </table>
                                    </div>

                                </ContentTemplate>
                            </asp:UpdatePanel>
                        </div>
                       
                        <div>
                            <asp:UpdatePanel runat="server" ID="upMessage" UpdateMode="Always">
                                <ContentTemplate>
                                    <asp:Label ID="lblMessage" runat="server" CssClass="errorMessage" />
                                </ContentTemplate>
                            </asp:UpdatePanel>
                        </div>
                    </div>
                </td>
            </tr>
            
        </table>
       
      

    </div>

</asp:Content>
