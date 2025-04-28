<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="WardAllocation.aspx.cs" Inherits="PMS.WardAllocation" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
   
    <script type="text/javascript">
        $(function () {
            bindControls();

            Sys.WebForms.PageRequestManager.getInstance().add_pageLoaded(function (evt, args) {
                $("#ctl00_MainContent_txtTo_TimeDate").datepicker({ dateFormat: 'mm/dd/yy' });
                $("#ctl00_MainContent_txtFrom_TimeDate").datepicker({ dateFormat: 'mm/dd/yy' });

                chkWard();
            });
        });

        function chkBedAvailability() {
            var button = document.getElementById('<%= btnTrigger.ClientID%>');
            $('#<%= lblChk.ClientID %>').text('Please Wait while checking bed availability');
            button.click();
        }
        function chkWard() {

            var ward_val = document.getElementById('<%= ddlWard_ID.ClientID%>').value;

            if (ward_val == 0) {
                $('#ctl00_MainContent_txtBed_No_Assigned').attr("readonly", true);
                $('#ctl00_MainContent_txtBed_No_Assigned').val('');
            }
            else {
                $('#ctl00_MainContent_txtBed_No_Assigned').attr("readonly", false);
            }
        }
        function chkAllocatedWard() {
         
            var pat = document.getElementById('<%= txtPatient_ID.ClientID%>').value;

            if (pat == '') {
                $('#ctl00_MainContent_txtCurrent_Allocated_Ward').val('');
                $('#ctl00_MainContent_txtCurrent_Allocated_Bed').val('');
                $('#<%= vlblCurrent_Allocated_Ward.ClientID %>').text('No Patient Selected');
            }
            else {
                var buttonWardAlcChk = document.getElementById('<%= btnAllocatedWardChkTrigger.ClientID%>');
                $('#<%= vlblCurrent_Allocated_Ward.ClientID %>').text('Please Wait while checking Ward Allocation');
                buttonWardAlcChk.click();
            }
        }
        function bindControls() {
            var hdFile_ID = $("#hdfPatient_ID").val();
            if (hdFile_ID != "(New)") {
                var Patient_ID = document.getElementById('<%= txtPatient_ID.ClientID%>').value;
                var tokendata = httpGet("../../json.aspx?Table=Patients&Record=Edit&q=" + Patient_ID);
                loadtokenInputs(JSON.parse(tokendata));
            }
            else {
                loadtokenInputsDefault();
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
            $('#ctl00_MainContent_txtPatient_ID').tokenInput("../../json.aspx?Table=Patients",
             {
                 tokenLimit: 1,
             });
        }

        function loadtokenInputs(data) {
            $("#ctl00_MainContent_txtPatient_ID").tokenInput("../../json.aspx?Table=Patients",
                {
                    prePopulate: data,
                    tokenLimit: 1,
                    onAdd: function (item) {
                        $("#hdfPatient_ID").val(item.id);
                    }
                });
        }

    </script>
 
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
        <div class="col-lg-3 col-md-6 col-sm-12">
            <asp:Label ID="lblWard_Allocation_ID" runat="server" Text="Ward Allocation ID"></asp:Label>
             <asp:TextBox ID="txtWard_Allocation_ID" runat="server" ReadOnly="true" Text="(New)" />
        </div>  
        <div class="col-lg-3 col-md-6 col-sm-12">
              <asp:Label ID="lblPatient_ID" runat="server" Text="Patient ID *"></asp:Label>
                <asp:TextBox ID="txtPatient_ID" runat="server" OnChange="chkAllocatedWard()" />
                <asp:HiddenField ID="hdfPatient_ID" Value="(New)" runat="server" ClientIDMode="Static" />
             <asp:RequiredFieldValidator ID="rfvPatient_ID" ControlToValidate="txtPatient_ID" runat="server" ErrorMessage="Select patient" Text="*"></asp:RequiredFieldValidator>
        </div>  
        <div class="col-lg-3 col-md-6 col-sm-12">
            <asp:Label ID="lblCurrent_Allocated_Ward" runat="server" Text="Current Ward"></asp:Label>
          
                <asp:UpdatePanel ID="UpdatePanel5" runat="server">
                    <ContentTemplate>
                        <asp:TextBox ID="txtCurrent_Allocated_Ward" runat="server" ReadOnly="true" />
                    </ContentTemplate>
                </asp:UpdatePanel>
        </div>  
        <div class="col-lg-3 col-md-6 col-sm-12">
            <asp:Label ID="lblCurrent_Allocated_Bed" runat="server" Text="Current Bed"></asp:Label>
             <asp:UpdatePanel ID="UpdatePanel7" runat="server">
                    <ContentTemplate>
                        <asp:TextBox ID="txtCurrent_Allocated_Bed" runat="server" ReadOnly="true" />
                    </ContentTemplate>
                </asp:UpdatePanel>
        </div>
    </div>
     <div class="row">
      
          <div class="col-lg-3 col-md-6 col-sm-12">
               <asp:Label ID="lblWard_ID" runat="server" Text="Ward *"></asp:Label>
              <asp:DropDownList ID="ddlWard_ID" runat="server" AutoPostBack="true" AppendDataBoundItems="true" OnSelectedIndexChanged="ddlWard_ID_SelectedIndexChanged"></asp:DropDownList>
                 <asp:RequiredFieldValidator ID="rfvWard_ID" ControlToValidate="ddlWard_ID" runat="server" InitialValue="0" ErrorMessage="Select Ward" Text="*"></asp:RequiredFieldValidator>
         </div>  
         <div class="col-lg-3 col-md-6 col-sm-12">
                <asp:Label ID="lblTotal_Beds" runat="server" Text="Total Beds *"></asp:Label>
                <asp:UpdatePanel ID="UpdatePanel1" runat="server" UpdateMode="Conditional">
                    <Triggers>
                        <asp:AsyncPostBackTrigger ControlID="ddlWard_ID" EventName="SelectedIndexChanged" />
                    </Triggers>
                    <ContentTemplate>
                        <asp:TextBox ID="txtTotal_Beds" ReadOnly="true" runat="server" />
                    </ContentTemplate>
                </asp:UpdatePanel>
         </div>  
           <div class="col-lg-3 col-md-6 col-sm-12">
                <asp:Label ID="lblBed_No_Assigned" runat="server" Text="Bed Assigned *"></asp:Label>
                <asp:UpdatePanel ID="UpdatePanel4" runat="server" UpdateMode="Always">
                    <ContentTemplate>
                        <asp:TextBox ID="txtBed_No_Assigned" runat="server" onChange="return chkBedAvailability();" />
                    </ContentTemplate>
                </asp:UpdatePanel>
                 </div> 
          <div class="col-lg-3 col-md-6 col-sm-12">
               <asp:Label ID="lblDoctor_Assigned" runat="server" Text="Doctor Assigned *"></asp:Label>
                <asp:DropDownList ID="ddlDoctor_Assigned" runat="server" AppendDataBoundItems="true"></asp:DropDownList>
                 <asp:RequiredFieldValidator ID="rfvDoctor_Assigned" ControlToValidate="ddlDoctor_Assigned" InitialValue="0" runat="server" ErrorMessage="Select Doctor" Text="*"></asp:RequiredFieldValidator>
                 </div>
            
    </div>
   
    <div class="row">
         <div class="col-lg-3 col-md-6 col-sm-12">
               <asp:Label ID="lblFrom_TimeDate" runat="server" Text="From *"></asp:Label>
                <asp:TextBox ID="txtFrom_TimeDate" runat="server" />
                   <asp:RequiredFieldValidator ID="rfvFrom_TimeDate" ControlToValidate="txtFrom_TimeDate" runat="server" ErrorMessage="Enter From Date" Text="*"></asp:RequiredFieldValidator>
                 </div>
         <div class="col-lg-3 col-md-6 col-sm-12">
                 <asp:Label ID="lblTo_TimeDate" runat="server" Text="To *"></asp:Label>
                <asp:TextBox ID="txtTo_TimeDate" runat="server" />
                <asp:RequiredFieldValidator ID="rfvTo_TimeDate" ControlToValidate="txtTo_TimeDate" runat="server" ErrorMessage="Enter To Date" Text="*"></asp:RequiredFieldValidator>
                 </div>
        
         <div class="col-lg-3 col-md-6 col-sm-12">
              <asp:Label ID="lblNurse_Assigned" runat="server" Text="Nurse Assigned *"></asp:Label>
                <asp:DropDownList ID="ddlNurse_Assigned" runat="server" AppendDataBoundItems="true"></asp:DropDownList>
                 <asp:RequiredFieldValidator ID="rfvNurse_Assigned" ControlToValidate="ddlNurse_Assigned" InitialValue="0" runat="server" ErrorMessage="Select Nurse" Text="*"></asp:RequiredFieldValidator>
                 </div>  
    
    </div>
    <div class="row">
        <div class="col-lg-9 col-md-9 col-sm-12">
              
                 <asp:Label ID="lblRemarks" runat="server" Text="Remarks"></asp:Label>
                <asp:TextBox ID="txtRemarks" runat="server"  ></asp:TextBox>
             
        </div>
    </div>
      <div class="row">
              <div class="col-lg-3 col-md-6 col-sm-12">
                <asp:UpdatePanel ID="UpdatePanel6" runat="server">
                    <ContentTemplate>
                        <asp:Label ID="vlblCurrent_Allocated_Ward" runat="server" />
                    </ContentTemplate>
                </asp:UpdatePanel>
          </div>
         <div class="col-lg-3 col-md-6 col-sm-12">
              <asp:UpdateProgress ID="UpdateProgress1" runat="server">
                    <ProgressTemplate>
                        <div class="loadingimage">
                            <asp:Image ID="image1" ImageUrl="~/images/loading.gif" runat="server" Width="32px" />
                        </div>
                    </ProgressTemplate>
                </asp:UpdateProgress>
         </div>
         <div class="col-lg-3 col-md-6 col-sm-12">
              <asp:RequiredFieldValidator ID="rfvBed_No_Assigned" ControlToValidate="txtBed_No_Assigned" runat="server" ErrorMessage="Enter Bed No." Text="*"></asp:RequiredFieldValidator>
                <asp:RangeValidator ID="rngBed_No_Assigned" Type="Integer" runat="server" MinimumValue="0" MaximumValue="9999999" ControlToValidate="txtBed_No_Assigned" ErrorMessage="Only Enter Integer Values" Text="*"></asp:RangeValidator>
                <asp:UpdatePanel ID="UpdatePanel2" runat="server" UpdateMode="Conditional">
                    <Triggers>
                        <asp:AsyncPostBackTrigger ControlID="btnTrigger" EventName="Click" />
                    </Triggers>
                    <ContentTemplate>
                        <asp:Label ID="lblChk" runat="server" />
                    </ContentTemplate>
                </asp:UpdatePanel>
                 </div>   
         <div class="col-lg-3 col-md-6 col-sm-12">
                <asp:UpdatePanel ID="UpdatePanel3" runat="server">
                    <ContentTemplate>
                        <asp:Button ID="btnTrigger" Style="display: none;" Text="Chk Bed" runat="server" OnClick="btnTrigger_Click" CausesValidation="false" />
                        <asp:Button ID="btnAllocatedWardChkTrigger" Style="display: none;" Text="Chk Allocated Ward" runat="server" OnClick="btnAllocatedWardChkTrigger_Click" CausesValidation="false" />
                    </ContentTemplate>
                </asp:UpdatePanel>
           
                 </div>     
    
    </div>
     <div class="row">
          <div class="col-lg-8">
            <div class="row">
                        <div class="col-lg-2 col-md-6 col-sm-12">
                <asp:Button Text="Save" CssClass="btn btn-primry"  runat="server" ID="btnSave" OnClick="btnSave_Click" />
                 </div>
                 <div class="col-lg-2 col-md-6 col-sm-12">
                            <asp:Button Text="View"  runat="server"  CssClass="btn btn-gray" ID="Button1" CausesValidation="false" PostBackUrl="~/Modules/WardAndRooms/WardAllocationView.aspx" />
                 </div>
       
               
              
            </div>
        </div>


         <div class="col-lg-3 col-md-6 col-sm-12">
            
        <asp:Label ID="lblMessage" Text="" runat="server" />
            <asp:ValidationSummary ID="ValidationSummary1" runat="server" ForeColor="Red" HeaderText="Page Errors"
                    ShowSummary="true" DisplayMode="List" />
    </div>
</asp:Content>

        