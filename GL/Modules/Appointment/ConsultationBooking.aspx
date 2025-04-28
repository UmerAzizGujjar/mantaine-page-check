<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ConsultationBooking.aspx.cs" Inherits="PMS.ConsultationBooking" %>

<%--<%@ Register Assembly="Infragistics4.Web.v12.1, Version=12.1.20121.2236, Culture=neutral, PublicKeyToken=7dd5c3163f2cd0cb" Namespace="Infragistics.Web.UI.LayoutControls" TagPrefix="ig" %>
<%@ Register Assembly="Infragistics4.Web.v12.1, Version=12.1.20121.2236, Culture=neutral, PublicKeyToken=7dd5c3163f2cd0cb" Namespace="Infragistics.Web.UI.LayoutControls" TagPrefix="ig" %>--%>


<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script type="text/javascript" src="Scripts/jquery.tokeninput.js"></script>


    <script type="text/javascript">

        $(function () {
            $("#tabs").tabs();
        });

        $(document).ready(function () {
            bindControls();
            bindDate();
        });
        function bindDate() {
            $("#ctl00_MainContent_txtDate").datepicker({ dateFormat: 'mm/dd/yy' });
        }


        function bindControls() {
            var hdFile_ID = $("#hdfPatient").val();
          
            if (hdFile_ID != "(New)") {
                var Patient_ID = document.getElementById('<%= txtPatient_ID.ClientID%>').value;
                var tokendata = httpGet("../json.aspx?Table=Patients&Record=Edit&q=" + Patient_ID);
                loadtokenInputs(JSON.parse(tokendata));

            }
            else {
                loadtokenInputsDefault();
            }
        }

        function loadtokenInputsDefault() {
            $('#ctl00_MainContent_txtPatient_ID').tokenInput("../json.aspx?Table=Patients&Record=New",
             {
                 tokenLimit: 1,
                 onAdd: function (item) {
                     try {
                         $("#hdfPatient").val(item.id);

                         loadAjax();
                     }
                     catch (err) {
                         alert(err.message);
                     }

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


        function loadAjax() {
            var Patient_ID = $("#<%= hdfPatient.ClientID %>").val();
            //var Patient_ID =  $("#<%= hdfPatient_ID.ClientID %>").val();
            $.ajax({
                type: "POST",
                url: "ConsultationBooking.aspx/GetDetail",
                data: "{'PatientID':" + Patient_ID + "}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: OnSuccess,
                failure: function (response) {
                    alert(response.d);
                }
            });
        }

        function OnSuccess(data) {
            if (data.d != '') {
                var mydate = new Date(Date.parse(data.d.Entry_Date));
                var dateR = mydate.toLocaleDateString();

                $('#<%= lblPatients_Name.ClientID %>').text(data.d.Name);
                $('#<%= lbl_Age.ClientID %>').text(data.d.Age);
                $('#<%= lbl_Gender.ClientID %>').text(data.d.Gender);
                $('#<%= lblReg_Date.ClientID %>').text(dateR);
                $('#<%= lbl_Adress.ClientID %>').text(data.d.Address);
                $('#<%= lbl_Contact.ClientID %>').text(data.d.Mobile);
            }
        }

        function loadtokenInputs(data) {
            $("#ctl00_MainContent_txtPatient_ID").tokenInput("../json.aspx?Table=Patients",
                {
                    prePopulate: data,
                    tokenLimit: 1,
                    onAdd: function (item) {
                        $("#hdfPatient_ID").val(item.id);


                    }
                });

        }

        //////////// End With  Two Hidden Field  Value Search TextBox ///////////////////////




    </script>
    <style type="text/css">
        .mg {
            padding-left: 63px;
        }

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
            <table style="padding: 20px; width: 657px; height: 161px;">

                <tr>
                    <td>
                        <asp:Label ID="Label1" runat="server" Text="Patient No :*"></asp:Label>
                    </td>
                    <td>
                        <asp:TextBox ID="txtPatient_ID" runat="server"></asp:TextBox>
                        <%--<asp:TextBox ID="txtPatient_ID" runat="server" OnTextChanged="txtPatient_ID_TextChanged"  ></asp:TextBox>--%>
                        
                    </td>
                    <td>
                        <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" Text="*" ErrorMessage="Select Patient No." ControlToValidate="txtPatient_ID" Display="Dynamic"></asp:RequiredFieldValidator>
                    </td>
                    <td class="mg">
                        <asp:Label ID="lblConsultation_B_ID" runat="server" Text="Consult. ID :"></asp:Label>
                    </td>
                    <td>
                        <asp:TextBox ID="txtConsultation_B_ID" runat="server" ReadOnly="True"></asp:TextBox>
                    </td>

                </tr>
                <tr>
                    <td>
                        <asp:Label ID="Label4" runat="server" Text="Patient Name :"></asp:Label>

                    </td>
                    <td>
                        <asp:Label ID="lblPatients_Name" runat="server"></asp:Label>


                    </td>
                    <td></td>

                    <td class="mg">
                        <asp:Label ID="Label5" runat="server" Text="Contact No :"></asp:Label>
                    </td>
                    <td>
                        <asp:Label ID="lbl_Contact" runat="server"></asp:Label>

                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:Label ID="Label6" runat="server" Text="Address :"></asp:Label>
                    </td>
                    <td>
                        <asp:Label ID="lbl_Adress" runat="server"></asp:Label>

                    </td>
                    <td></td>
                    <td class="mg">
                        <asp:Label ID="Label7" runat="server" Text="Gender :"></asp:Label>
                    </td>
                    <td>
                        <asp:Label ID="lbl_Gender" runat="server"></asp:Label>

                    </td>
                </tr>
                <tr>

                    <td>
                        <asp:Label ID="Label8" runat="server" Text="Age Years :"></asp:Label>
                    </td>
                    <td>
                        <asp:Label ID="lbl_Age" runat="server"></asp:Label>

                    </td>
                    <td></td>
                    <td class="mg">
                        <asp:Label ID="Label2" runat="server" Text="Reg. Date :"></asp:Label>
                    </td>
                    <td>
                        <asp:Label ID="lblReg_Date" runat="server"></asp:Label>
                    </td>
                </tr>

                <tr>
                    <td>
                        <asp:HiddenField ID="hdfPatient_ID" Value="(New)" runat="server" ClientIDMode="Static" />

                    </td>
                    <td>
                        <asp:HiddenField ID="hdfPatient" Value="(New)" runat="server" ClientIDMode="Static" />
                    </td>
                    <td></td>
                    <td>
                        <%--<asp:HiddenField ID="hdfPatient_No" runat="server" ClientIDMode="Static" />--%>
                    </td>
                </tr>

            </table>
        </ContentTemplate>
    </asp:UpdatePanel>
    <br />
    <div style="width: 100%">
        <div id="tabs">
            <ul>
                <li><a href="#Tab-1">Test Details</a></li>
                <li><a href="#Tab-2">Add Lab Test</a></li>
                <li><a href="#Tab-3">Patient History and Presenting Complaints</a></li>
                <li><a href="#Tab-4">Prescribed Medicine</a></li>
                <li><a href="#Tab-5">Doctor's Comment</a></li>
            </ul>
            <div id="Tab-1">

                <div id="TestDetails" style="width: 90%">

                    <table style="height: 103px; width: 721px">
                        <tr>
                            <td colspan="6">
                                <h2>Test Details : </h2>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:Label ID="Label9" runat="server" Text="Recommended Test *"></asp:Label>
                            </td>
                            <td>
                                <asp:DropDownList ID="ddlRecommendedTest" runat="server" AppendDataBoundItems="true">
                                </asp:DropDownList>
                            </td>
                            <td>
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" InitialValue="0" Text="*" ErrorMessage="Select Recommended Test" ControlToValidate="ddlRecommendedTest" Display="Dynamic"></asp:RequiredFieldValidator>
                            </td>
                            <td class="mg">
                                <asp:Label ID="Label10" runat="server" Text="Date"></asp:Label>
                            </td>
                            <td>
                                <asp:TextBox ID="txtDate" runat="server"></asp:TextBox>
                            </td>
                            <td></td>
                        </tr>

                        <tr>
                            <td>

                                <asp:Label ID="Label3" runat="server" Text="Consultation Charges *"></asp:Label>

                            </td>
                            <td>

                                <asp:TextBox ID="txtConsultationCharges" runat="server"></asp:TextBox>



                            </td>
                            <td>
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server" Text="*" ErrorMessage="Enter Consultation Charges" Display="Dynamic" ControlToValidate="txtConsultationCharges"></asp:RequiredFieldValidator>
                            </td>
                            <td class="mg">

                                <asp:Label ID="Label11" runat="server" Text="Doctor Name *"></asp:Label>

                            </td>
                            <td>

                                <asp:DropDownList ID="ddlDoctorName" runat="server" AppendDataBoundItems="true" Width="167px">
                                </asp:DropDownList>


                            </td>
                            <td>
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" InitialValue="0" Text="*" ErrorMessage="Select Doctor Name" ControlToValidate="ddlDoctorName" Display="Dynamic"></asp:RequiredFieldValidator>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:Label ID="Label12" Text="Consultation Type" runat="server"></asp:Label>
                            </td>
                            <td colspan="5">
                                <asp:DropDownList ID="ddlConsultationType" runat="server" AppendDataBoundItems="true" Width="167px">
                                </asp:DropDownList>
                            </td>

                        </tr>
                    </table>
                </div>
            </div>

            <div id="Tab-2">
                <div id="AddLabTest" style="width: 90%">
                    <%--//////////////////////////////////////////////////////////////////////////////////--%>

                    <table>
                        <tr>
                            <td>
                                <h2>Lab Test : </h2>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:UpdatePanel runat="server" ID="upTestForm" UpdateMode="Conditional">
                                    <Triggers>
                                        <asp:AsyncPostBackTrigger EventName="Click" ControlID="btnNew" />
                                        <%--<asp:AsyncPostBackTrigger ControlID="GRD" EventName="RowCommand" />--%>
                                        <asp:AsyncPostBackTrigger ControlID="btnSaveTest" EventName="Click" />
                                        <asp:AsyncPostBackTrigger ControlID="BtnDelete" EventName="Click" />
                                    </Triggers>
                                    <ContentTemplate>
                                        <table style="width: 689px">
                                            <tr>
                                                <td style="position: relative; top: -13px;">
                                                    <asp:Label ID="Label19" runat="server" Text="Test Name"></asp:Label>
                                                </td>
                                                <td>
                                                    <asp:DropDownList ID="ddlMedical_Test" runat="server" Width="167px" AppendDataBoundItems="true"></asp:DropDownList>
                                                    &nbsp;</td>
                                                <td style="position: relative; top: -10px;">
                                                    <asp:Button ID="btnSaveTest" runat="server" Text="Add Test" CausesValidation="false" OnClick="btnSaveTest_Click" />
                                                    &nbsp;
                                                    <asp:Button ID="BtnDelete" runat="server" Text="Delete" Width="107px" CausesValidation="false" OnClick="BtnDelete_Click" />
                                                    &nbsp;
                                                    <asp:Button ID="btnClear" CausesValidation="false" Width="107px" runat="server" Text="Clear" OnClick="btnClear_Click" />
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
                                                <asp:AsyncPostBackTrigger ControlID="btnSaveTest" EventName="Click" />
                                                <asp:AsyncPostBackTrigger ControlID="BtnDelete" EventName="Click" />
                                                <asp:AsyncPostBackTrigger EventName="Click" ControlID="btnNew" />
                                            </Triggers>
                                            <ContentTemplate>
                                                <asp:GridView ID="GRD" runat="server" BorderStyle="None" AutoGenerateColumns="False"
                                                    CellPadding="5" ShowFooter="True" OnSelectedIndexChanging="GRD_SelectedIndexChanging" Style="z-index: -1" CellSpacing="1" Height="160px" Width="450px">
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
                                                                <asp:TextBox ID="TextBox1" runat="server"></asp:TextBox>
                                                            </EditItemTemplate>
                                                        </asp:TemplateField>

                                                        <asp:BoundField DataField="Test_Name" Visible="false" HeaderText="Test Name">
                                                            <ItemStyle Width="200px" />
                                                        </asp:BoundField>
                                                        <asp:BoundField DataField="BloodTest_Name" HeaderStyle-CssClass="header-center" HeaderText="Test Name">
                                                            <ItemStyle Width="200px" HorizontalAlign="Center" />
                                                        </asp:BoundField>
                                                    </Columns>
                                                </asp:GridView>
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                    </div>
                                    <div>
                                        <asp:UpdatePanel runat="server" ID="UpdatePanel3" UpdateMode="Conditional">
                                            <ContentTemplate>
                                                <asp:Label ID="Label21" runat="server" CssClass="errorMessage" />
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                    </div>
                                </div>
                            </td>
                        </tr>
                    </table>

                    <%--/////////////////////////////////////////////////////////////////////////////////////--%>
                </div>
            </div>

            <div id="Tab-3">

                <div id="PatientHistory" style="width: 90%">
                    <table style="height: 103px; width: 475px">
                        <tr>
                            <td colspan="2">
                                <h2>Patient History & Presenting Complaints : </h2>
                            </td>
                        </tr>
                        <tr>
                            <td style="width:100px;">
                                <asp:Label ID="Label13" Text="Patient History" runat="server"></asp:Label>
                            </td>
                            <td>
                                <asp:TextBox ID="txtPatientHistory" runat="server" Height="60px" Width="501px" TextMode="MultiLine"></asp:TextBox>
                            </td>
                        </tr>
                    </table>
                </div>

            </div>

            <div id="Tab-4">
                <div id="PrescribedMedicine" style="width: 90%">
                    <%--//////////////////////////////////////////////////////////////////////////--%>
                    <table>
                        <tr>
                            <td>
                                <h2>Prescribed Medicine : </h2>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:UpdatePanel runat="server" ID="upMdcnForm" UpdateMode="Conditional">
                                    <Triggers>
                                        <asp:AsyncPostBackTrigger EventName="Click" ControlID="btnNew" />
                                        <%--<asp:AsyncPostBackTrigger ControlID="GRD" EventName="RowCommand" />--%>
                                        <asp:AsyncPostBackTrigger ControlID="btnAdd" EventName="Click" />
                                        <asp:AsyncPostBackTrigger ControlID="btnMdcnDelete" EventName="Click" />
                                    </Triggers>
                                    <ContentTemplate>
                                        <table style="width: 673px">
                                            <tr>
                                                <td>

                                                    <asp:Label ID="Label14" runat="server" Text="Medicine Name"></asp:Label>

                                                </td>
                                                <td>

                                                    <asp:TextBox ID="txtMedincineName" runat="server" Width="189px"></asp:TextBox>

                                                </td>
                                                <td class="mg">

                                                    <asp:Label ID="Label16" runat="server" Text="No. Of Doses"></asp:Label>

                                                </td>
                                                <td>

                                                    <asp:TextBox ID="txtNoOfDoses" runat="server" Width="189px"></asp:TextBox>

                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:Label ID="Label18" Text="Precaution" runat="server"></asp:Label>
                                                </td>
                                                <td>

                                                    <asp:TextBox ID="txtPrecaution" runat="server" Height="38px" Width="189px"></asp:TextBox>

                                                </td>
                                                <td class="mg">
                                                    <asp:Label ID="Label15" Text="Charges" runat="server"></asp:Label>
                                                </td>
                                                <td>

                                                    <asp:TextBox ID="txtCharges" runat="server" Width="189px"></asp:TextBox>

                                                </td>

                                            </tr>

                                            <tr>
                                                <td></td>
                                                <td colspan="3">
                                                    <asp:Button ID="btnAdd" runat="server" Text="Add" CausesValidation="false" OnClick="btnAdd_Click" />
                                                    &nbsp;
                                                    <asp:Button ID="btnMdcnDelete" runat="server" Text="Delete" Width="107px" CausesValidation="false" OnClick="btnMdcnDelete_Click" />
                                                    &nbsp;
                                                    <asp:Button ID="btnMdcnClear" CausesValidation="false" Width="107px" runat="server" Text="Clear" OnClick="btnMdcnClear_Click" />
                                                </td>
                                            </tr>
                                        </table>
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:Label ID="lblValidation1" Text="" runat="server" CssClass="errorMessage" />
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div style="width: 900px; float: left">
                                    <div>
                                        <asp:UpdatePanel runat="server" ID="UpdatePanel4" UpdateMode="Always">
                                            <Triggers>
                                                <asp:AsyncPostBackTrigger ControlID="btnAdd" EventName="Click" />
                                                <asp:AsyncPostBackTrigger ControlID="btnMdcnDelete" EventName="Click" />
                                                <asp:AsyncPostBackTrigger ControlID="btnNew" EventName="Click" />
                                            </Triggers>
                                            <ContentTemplate>
                                                <asp:GridView ID="GRD_2" runat="server" BorderStyle="None" AutoGenerateColumns="False"
                                                    CellPadding="3" ShowFooter="True" OnSelectedIndexChanging="GRD_2_SelectedIndexChanging" Style="z-index: -1">
                                                    <Columns>
                                                        <asp:TemplateField>
                                                            <ItemTemplate>
                                                                <asp:LinkButton ID="imgedit" CausesValidation="false" CommandName="select" runat="server">edit</asp:LinkButton>
                                                            </ItemTemplate>
                                                            <ItemStyle HorizontalAlign="Center" Width="100px" />
                                                        </asp:TemplateField>
                                                        <asp:TemplateField HeaderText="Index1" Visible="false">
                                                            <ItemTemplate>
                                                                <asp:Label ID="lblIndex1" runat="server" Text='<%# Bind("Index1") %>'></asp:Label>
                                                            </ItemTemplate>
                                                            <EditItemTemplate>
                                                                <asp:TextBox ID="TextBox2" runat="server"></asp:TextBox>
                                                            </EditItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:BoundField DataField="Medicine_Name" HeaderStyle-CssClass="header-center" HeaderText="Medicine Name">
                                                            <ItemStyle Width="200px" HorizontalAlign="Center" />
                                                        </asp:BoundField>
                                                        <asp:BoundField DataField="No_of_Doses" HeaderStyle-CssClass="header-center" HeaderText="No of Doses">
                                                            <ItemStyle Width="200px" HorizontalAlign="Center" />
                                                        </asp:BoundField>
                                                        <asp:BoundField DataField="Precaution" HeaderStyle-CssClass="header-center" HeaderText="Precaution">
                                                            <ItemStyle Width="200px" HorizontalAlign="Center" />
                                                        </asp:BoundField>
                                                        <asp:BoundField DataField="Charges" HeaderStyle-CssClass="header-center" HeaderText="Charges">
                                                            <ItemStyle Width="200px" HorizontalAlign="Center" />
                                                        </asp:BoundField>

                                                    </Columns>
                                                </asp:GridView>
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                    </div>
                                    <div>
                                        <asp:UpdatePanel runat="server" ID="UpdatePanel5" UpdateMode="Always">
                                            <ContentTemplate>
                                                <asp:Label ID="Label23" runat="server" CssClass="errorMessage" />
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                    </div>
                                </div>
                            </td>
                        </tr>
                    </table>

                    <%--////////////////////////////////////////////////////////////////////////////////--%>
                </div>
            </div>

            <div id="Tab-5">

                <div id="DoctorComment" style="width: 90%">

                    <table style="height: 103px; width: 450px">
                        <tr>
                            <td colspan="2">
                                <h2>Doctor's Comment : </h2>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:Label ID="Label17" Text="Doctor's Comment" runat="server"></asp:Label>
                            </td>
                            <td>
                                <asp:TextBox ID="txtDoctorComment" runat="server" Height="60px" Width="501px" TextMode="MultiLine"></asp:TextBox>
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
        </div>

        <div style="padding-left: 40px; padding-top: 20px">
            <table>
            </table>
        </div>
    </div>

    <div>
        <table>
            <tr>
                <td></td>
                <td>
                    <asp:Button Text="Back" runat="server" ID="btnBack" CausesValidation="false" PostBackUrl="~/ConsultationBookingView.aspx" />
                    &nbsp;&nbsp;
                        <asp:Button ID="btnNew" runat="server" Text="New" CausesValidation="false" CssClass="vocherButton" OnClick="btnNew_Click" />
                    &nbsp;&nbsp;
                    <asp:Button ID="btnSave" runat="server" Text="Save" OnClick="btnSave_Click" />
                </td>
            </tr>
            <tr>
                <td>
                    <asp:Label ID="lblMessage" runat="server" ForeColor="#CC0000"></asp:Label>

                </td>
            </tr>
            <tr>
                <td>
                    <asp:ValidationSummary ID="ValidationSummary1" runat="server"
                        ForeColor="Red" HeaderText="Page Errors"
                        ShowSummary="true" DisplayMode="List" />
                </td>
            </tr>
        </table>
    </div>



</asp:Content>
