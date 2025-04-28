<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="Customer.aspx.cs" Inherits="PMS.Customer" Theme="Default_Theme" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script type="text/javascript" src="../Scripts/jquery.tokeninput.js"></script>
    <script type="text/javascript">
        $(document).ready(function () {
            var customerId = $('#<%=txtCustomer_ID.ClientID%>').val();

              if (customerId != "(New)") {
                  //var accountId = $("#ctl00_MainContent_txtAccount_Code_Name").val();
                  var accountId = $("#hdfAccount_ID").val();
                  var tokendata = httpGet("../json.aspx/?Table=Account&Account_ID=" + accountId);
                  loadtokenInputs(JSON.parse(tokendata));
              }
              else {
                  loadtokenInputsDefault();
              }

              var chkBox = document.getElementById('<%= chkManually.ClientID %>').checked;
              if (chkBox == false) {
                  $('#ctl00_MainContent_txtAccount_Code_Name').tokenInput("toggleDisabled");
                  return true;
              }
          });


          function enabledisable() {
              var chkBox = document.getElementById('<%= chkManually.ClientID %>');
              $('#ctl00_MainContent_txtAccount_Code_Name').tokenInput("toggleDisabled");
              return true;
          }
          function loadtokenInputsDefault() {
              $('#ctl00_MainContent_txtAccount_Code_Name').tokenInput("../json.aspx",
               {
                   tokenLimit: 1,
                   onAdd: function (item) {
                       $("#hdfAccount_ID").val(item.id);
                   }
               });
          }
          function loadtokenInputs(data) {
              $("#ctl00_MainContent_txtAccount_Code_Name").tokenInput("../json.aspx",
                  {
                      prePopulate: data,
                      tokenLimit: 1,
                      onAdd: function (item) {
                          $("#hdfAccount_ID").val(item.id);
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
          function showval() {
              var hdval = $('#<%=hdfAccount_ID.ClientID %>').val();
              alert("Hidden field value: " + hdval);

              var txtval = $('#<%=txtAccount_Code_Name.ClientID %>').val();
              alert("Text field value: " + txtval);
          }
          function checkGLAccount() {

              var chk = $('#<%=chkManually.ClientID %>').is(':checked');
              var newentry = $('#<%=btnSave.ClientID %>').val();
              var txtval = $('#<%=txtAccount_Code_Name.ClientID %>').val();
              var hdnval = $('#<%=hdfAccount_ID.ClientID %>').val();
              //alert("in js");
              if (newentry == "Save") {
                  if (chk) {

                      if (txtval == "") {
                          alert("Please select GL Account first");
                          return false;
                      }
                  }
              }
              else {
                  if (txtval == "") {
                      alert("Please select GL Account first");
                      return false;

                  }
              }
              hdnval = txtval.val;
          }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <%--  <asp:UpdatePanel runat="server" ID="upForm" UpdateMode="Conditional">
        <ContentTemplate>--%>
    <asp:Panel runat="server" ID="pnlForm">
        <table style="padding: 20px; width: 920px; height: 210px;">
            <tr>
                <td style="width:115px;">
                    <asp:Label Text="Customent ID" runat="server" ID="lblCustomer_ID" />
                </td>
                <td style="width:204px;">
                    <asp:TextBox runat="server" ID="txtCustomer_ID" ReadOnly="true" Text="(New)" />
                </td>
                <td style="width:140px;"></td>
                <td style="width:100px;">
                    <asp:Label Text="CNIC *" runat="server" ID="Label9" />
                </td>
                <td style="width:204px;">
                    <asp:TextBox runat="server" ID="txtCustoemer_CNIC" MaxLength="50" />
                </td>
                <td>
                    <asp:RequiredFieldValidator ID="rfvCustomer_CNIC" ErrorMessage="CNIC is required."
                        ControlToValidate="txtCustoemer_CNIC" runat="server" SetFocusOnError="true" Display="Dynamic" />
                </td>
            </tr>

            <tr>
                <td>
                    <asp:Label Text="Name *" runat="server" ID="lblCustomer_Name" />
                </td>
                <td>
                    <asp:TextBox runat="server" ID="txtCustomer_Name" MaxLength="100" />
                </td>
                <td>
                    <asp:RequiredFieldValidator ID="RequiredFieldValidator1" ErrorMessage="Name is required." ControlToValidate="txtCustomer_Name" runat="server" SetFocusOnError="true" Display="Dynamic" />
                </td>
                <td>
                    <asp:Label Text="Father Name" runat="server" ID="Label2" />
                </td>
                <td>
                    <asp:TextBox runat="server" ID="txtFather_Name" MaxLength="100" />
                </td>
                <td></td>
            </tr>

            <tr valign="top">
                <td>
                    <asp:Label Text="Address" runat="server" ID="Label3" />
                </td>
                <td>
                    <asp:TextBox runat="server" ID="txtCustomer_Address" TextMode="MultiLine" />
                </td>
                <td></td>
                <td>
                    <asp:Label Text="Permanent Address" runat="server" ID="Label4" />
                </td>
                <td>
                    <asp:TextBox runat="server" ID="txtCustomer_Permanent_Address" TextMode="MultiLine" />
                </td>
                <td></td>
            </tr>

            <tr>
                <td>
                    <asp:Label Text="Occupation" runat="server" ID="Label10" />
                </td>
                <td>
                    <asp:TextBox runat="server" ID="txtCustoemer_Occupation" MaxLength="50" />
                </td>
                <td></td>
                <td>
                    <asp:Label Text="Job Title *" runat="server" ID="Label14" />
                </td>
                <td>
                    <asp:TextBox runat="server" ID="txtJob_Title" MaxLength="100" />
                </td>
                <td>
                    <asp:RequiredFieldValidator ID="rfvJob_Title" ErrorMessage="Job Title is required." ControlToValidate="txtJob_Title" runat="server" SetFocusOnError="true" Display="Dynamic" />
                </td>
            </tr>

            <tr>
                <td>
                    <asp:Label Text="Country" runat="server" ID="Label12" />
                </td>
                <td>
                    <asp:DropDownList runat="server" ID="ddlCountry" AppendDataBoundItems="true"></asp:DropDownList>
                </td>
                <td></td>
                <td>
                    <asp:Label Text="City" runat="server" ID="lblCity" />
                </td>
                <td>
                    <asp:DropDownList runat="server" ID="ddlCity" AppendDataBoundItems="true"></asp:DropDownList>
                </td>
                <td></td>
            </tr>

            <tr>
                <td>
                    <asp:Label Text="Resident Number" runat="server" ID="Label5" />
                </td>
                <td>
                    <asp:TextBox runat="server" ID="txtCustoemer_Resident_No" MaxLength="50" />
                </td>
                <td></td>
                <td>
                    <asp:Label Text="Office Number" runat="server" ID="Label6" />
                </td>
                <td>
                    <asp:TextBox runat="server" ID="txtCustoemer_Office_No" MaxLength="50" />
                </td>
                <td></td>
            </tr>

            <tr>
                <td>
                    <asp:Label Text="Mobile Number" runat="server" ID="Label1" />
                </td>
                <td>
                    <asp:TextBox runat="server" ID="txtCustomer_Mobile_No" MaxLength="50" />
                </td>
                <td></td>
                <td>
                    <asp:Label Text="Fax Number" runat="server" ID="Label7" />
                </td>
                <td>
                    <asp:TextBox runat="server" ID="txtCustoemer_Fax_No" MaxLength="50" />
                </td>
                <td></td>
            </tr>

            <tr>
                <td>
                    <asp:Label Text="Email" runat="server" ID="Label8" />
                </td>
                <td>
                    <asp:TextBox runat="server" ID="txtCustoemer_Email" MaxLength="50" />
                </td>
                <td>
                    <asp:RegularExpressionValidator ErrorMessage="Invalid email." ControlToValidate="txtCustoemer_Email" runat="server" CssClass="validation"
                        ID="reCustomer_Email" SetFocusOnError="true" Display="Dynamic" ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" />
                </td>
                <td>
                    <asp:Label Text="Website" runat="server" ID="Label11" />
                </td>
                <td>
                    <asp:TextBox runat="server" ID="txtCustomer_Website" MaxLength="50" />
                </td>
                <td></td>
            </tr>

            <tr>
                <td>
                    <asp:Label Text="Remarks" runat="server" ID="Label13" />
                </td>
                <td>
                    <asp:TextBox runat="server" ID="txtRemarks" TextMode="MultiLine" />

                </td>
                <td></td>
                <td>
                    <asp:Label Text="GL Account" runat="server" ID="lblGLAccount" />
                </td>
                <td>
                    <asp:TextBox runat="server" ID="txtAccount_Code_Name" />
                    <asp:HiddenField runat="server" ID="hdfAccount_Name" />
                    <asp:HiddenField ID="hdfAccount_Code" runat="server" />
                    <asp:HiddenField ID="hdfParent_Code" runat="server" />
                    <asp:HiddenField ID="hdfAccount_Serial" runat="server" />
                    <asp:HiddenField ID="hdfLevel" runat="server" />
                    <asp:HiddenField ID="hdfAccount_ID" runat="server" ClientIDMode="Static" />
                    <asp:HiddenField ID="hdfAccountExists" runat="server" />
                </td>
                <td>
                    <asp:CheckBox Text="Add manually" ID="chkManually" runat="server" onclick="enabledisable();" />
                </td>
            </tr>

            <tr>
                <td></td>
                <td>
                    <asp:Button Text="Back" runat="server" Width="94px" ID="btnBack" CausesValidation="false" PostBackUrl="~/AR/CustomerView.aspx" />
                    &nbsp;&nbsp;
                    <asp:Button Text="Save" runat="server" Width="94px" ID="btnSave" OnClick="btnSave_Click" OnClientClick="return checkGLAccount();" />
                </td>
                <td colspan="4"></td>
            </tr>
            <tr>
                <td colspan="6">
                    <asp:Label ID="lblMessage" runat="server" />
                </td>
            </tr>
            <tr>
                <td colspan="6">
                    <span>*Please leave the GL Account empty for Auto generate GL Account </span>
                </td>
            </tr>
        </table>
    </asp:Panel>
    <%-- </ContentTemplate>
    </asp:UpdatePanel>--%>
</asp:Content>
