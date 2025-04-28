<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Employee.aspx.cs" Inherits="PMS.Employee" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/css/CustomCss/Employee.css" rel="stylesheet" />
 
    <script type="text/javascript">

        var Panels = '';
        $(document).ready(function () {
            debugger;
            $('#ctl00_MainContent_TxtTime_In').ptTimeSelect();
            $("#ctl00_MainContent_TxtTime_Out").ptTimeSelect();
            

            var time = new Date();
            var t = time.toLocaleString('en-US', { hour: 'numeric', minute: 'numeric', hour12: true });


            GetPanels();
            $('#ctl00_MainContent_txtDoctorShare, #ctl00_MainContent_txtHospital_Share').on('keyup', function () {
                var docShare = parseFloat($('#ctl00_MainContent_txtDoctorShare').val()) || 0; // Parse as float and handle NaN
                var hosShare = parseFloat($('#ctl00_MainContent_txtHospital_Share').val()) || 0; // Parse as float and handle NaN
                var conCharges = docShare + hosShare;
                $('#ctl00_MainContent_txtConsultant_Charges').val(conCharges);
            });

            $('#btnSaveH').on('click', function () {
                debugger;
               
                var customers = [];
                $("#tblPanel tr:gt(1)").each(function (key, value) {
                    var listOfDetails = {};
                    debugger;

                    debugger;
                    var Panel = $(value).find('select[name="Panel"]').val();
                    var Rate = $(value).find('input[name="Rate"]').val();

                    listOfDetails.Panel = Panel;
                    listOfDetails.Rate = Rate;

                    customers.push(listOfDetails);

                });
                debugger;


                document.getElementsByName("CustomerJSON")[0].value = JSON.stringify(customers);

                $("[id$='_ctl00_MainContent_btnSave']").click();
                $("[id$='_btnSave']").click();

            });

            var id = '<% =Request.QueryString["ID"] %>';
            if (id != "") {
                debugger;
                LoadPanel();
                $('#btnSaveH').val('Update');

            }
            else {
                $('#ctl00_MainContent_TxtTime_In').val(t);
                $("#ctl00_MainContent_TxtTime_Out").val(t);

            }
        });

        $(function () {
            Sys.WebForms.PageRequestManager.getInstance().add_pageLoaded(function (evt, args) {
                $("#ctl00_MainContent_txtEmployee_Date_of_Birth").datepicker({ dateFormat: 'mm/dd/yy' });
                $("#ctl00_MainContent_txtEmployee_DOJ").datepicker({ dateFormat: 'mm/dd/yy' });
                $("#ctl00_MainContent_txtEmployee_Resign").datepicker({ dateFormat: 'mm/dd/yy' });
             
            });
        });
        function DeleteRate(row) {
            $(row).closest('tr').remove();
        }
        function LoadPanel() {

            debugger;
            var id = '<% =Request.QueryString["ID"] %>';
            $.ajax({
                type: "POST",
                url: "Employee.aspx/LoadPanel",
                data: JSON.stringify({
                    "Id": id
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var parsed_Data = JSON.parse(response.d);
                    debugger;
                    var rows = '';
                    for (var i = 1; i <= parsed_Data.length; i++) {
                        generateRow();
                        debugger;
                        $('#Select' + i + '').val(parsed_Data[i - 1].Patient_Category);
                        $('#Rate' + i + '').val(parsed_Data[i - 1].Test_Rate);
                    }

                },

                error: function () {
                    alert("Error");
                }

            });

        }
       

        function GetPanels() {
            debugger;
            var options = '<option value="0">Select Panel</option>';
            $.ajax({
                type: "post",
                url: "Employee.aspx/GetPanel",
                data: "",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                success: function (response) {
                    debugger;
                    $.each(JSON.parse(response.d), function (key, value) {

                        options += '<option value="' + value.Panel_ID + '">' + value.Company_Name + '</option>';
                    });
                    debugger;
                    Panels = options;
                },
                failure: function (response) {
                    alert("Error!!!");
                }
            });
        }

        function SavePanelRate(id) {
            var tblOPDList = document.getElementById('tblPanel');
            var opdData = new Array();
            for (var i = 1; i < tblOPDList.rows.length; i++) {
                var opdCategory = $('#opdSelect' + i + '').val();
                var opdRate = $('#opdRate' + i + '').val();
                if (opdCategory != null && opdRate != null) {
                    opdData[i] = new Array(opdCategory, opdRate);
                }
            }
            PageMethods.saveData(id, ipdData, onSuccess, onFail);

        }

        function Chk_SubDepartment_Info() {

            var Doctor_Val = document.getElementById('<%= ddlDepartment.ClientID%>').value;

            if (Doctor_Val == 0) {
                $('#ctl00_MainContent_ddl_Sub_Department').val('');
            }
            else {
                var button = document.getElementById('<%= btnGet_SubDepartment.ClientID%>');
                button.click();
            }

        }

        function generateRow() {
            debugger;
            var rowID = document.getElementById('tblPanel').rows.length - 1;
            var html = '<tr id = "Row' + rowID + '">' +
                '<td><select style="width: 145px !important;" name="Panel" id = "Select' + rowID + '">' + Panels + '</select></td>' +
                '<td><input type="text" id="Rate' + rowID + '" name="Rate" style="width: 65px !important;"/></td>' +
                '<td><a href="javascript:void(0)" onclick="DeleteRate(this)">Delete</a>' +
                '</td>' +
                '</tr>';

            $('#tblPanel').append(html);
        }
    </script>
  

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <form id="Items">
        <div class="row">
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label>Employee ID</label>
                <asp:TextBox runat="server" ID="txtEmployeeID" ReadOnly="true" Text="(New)" />
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label>Employee Code **</label>
                <asp:TextBox ID="txtEmployeeCode" runat="server" disabled="disabled" />
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label>Employee Name *</label>
                <asp:TextBox runat="server" ID="txtEmployee_Name" autocomplete="off" />
                <asp:RequiredFieldValidator ErrorMessage="Employee Name is required." ControlToValidate="txtEmployee_Name" CssClass="validation"
                    ID="rfvEmployee_Name" SetFocusOnError="true" runat="server" Display="Dynamic" />
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label>Father Name</label>
                <asp:TextBox runat="server" ID="txtFather_Name" autocomplete="off" />
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label>Date of Birth</label>
                <asp:TextBox runat="server" ID="txtEmployee_Date_of_Birth" />
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label>Panel Rate</label>
                <asp:TextBox ID="txtPanelAmount" runat="server" />
            </div>
        </div>
        <br />
        <div class="row">
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label>Patient type</label>
                <asp:DropDownList ID="ddlPatientType" runat="server">
                </asp:DropDownList>
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label>Department *</label>
                <asp:DropDownList runat="server" ID="ddlDepartment" AppendDataBoundItems="true" onchange="Chk_SubDepartment_Info()">
                </asp:DropDownList>
                <asp:UpdatePanel ID="UpdatePanel12" runat="server" UpdateMode="Always">
                    <ContentTemplate>
                        <asp:Button ID="btnGet_SubDepartment" Style="display: none;" Text="" runat="server" OnClick="btnGet_SubDepartment_Click" CausesValidation="false" />
                    </ContentTemplate>
                </asp:UpdatePanel>
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label>Designation</label>
                <asp:DropDownList runat="server" ID="ddlDesignation" AppendDataBoundItems="true">
                </asp:DropDownList>
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label>Mobile No</label>
                <asp:UpdatePanel runat="server" TabIndex="2" ID="UpdatePanel13">
                    <Triggers>
                        <asp:AsyncPostBackTrigger ControlID="ddlDepartment" />
                    </Triggers>
                </asp:UpdatePanel>
                <asp:TextBox runat="server" ID="txtEmployee_Phone2" MaxLength="11" oninput="this.value = this.value.replace(/[^0-9.]/g, '').replace(/(\..*)\./g, '$1');" autocomplete="off" />
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label>Home Phone</label>
                <asp:TextBox runat="server" ID="txtEmployee_Phone1" oninput="this.value = this.value.replace(/[^0-9.]/g, '').replace(/(\..*)\./g, '$1');" MaxLength="11" autocomplete="off" />
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label>Email</label>
                <asp:TextBox ID="txtEmployee_Email" runat="server" autocomplete="off" />
            </div>
        </div>
        <br />

        <div class="row">
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label>Patient Time</label>
                <asp:TextBox ID="txtPatient_Time" runat="server" />
            </div>
            <div class="col-lg-1 col-md-4 col-sm-6">
                <label>Time In</label>
                <asp:TextBox ID="TxtTime_In" runat="server" />
            </div>
            <div class="col-lg-1 col-md-4 col-sm-6">
                <label>Time Out</label>
                <asp:TextBox ID="TxtTime_Out" runat="server" />

            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label>NTN No.</label>
                <asp:TextBox runat="server" ID="txtEmployee_NTN_No" autocomplete="off" />
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label>Room #</label>
                <asp:DropDownList ID="ddlRoom" runat="server">
                </asp:DropDownList>
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label>Date of Joining</label>
                <asp:TextBox runat="server" ID="txtEmployee_DOJ" />
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label>Resign Date</label>
                <asp:TextBox ID="txtEmployee_Resign" runat="server" autocomplete="off" />
            </div>
        </div>
        <br />
        <div class="row">
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label>Floor #</label>
                <asp:DropDownList ID="ddlFloor" runat="server">
                </asp:DropDownList>
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label>Doctor Share</label>
                <asp:TextBox runat="server" ID="txtDoctorShare" autocomplete="off" />
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label>Hospital Share</label>
                <asp:TextBox runat="server" ID="txtHospital_Share" />
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label>Extension No</label>
                <asp:TextBox ID="Ext_txt" runat="server" />
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label>Gross Pay</label>
                <asp:TextBox ID="txtGrossPay" runat="server" autocomplete="off" />
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label>Consultant Charges</label>
                <asp:TextBox ID="txtConsultant_Charges" ReadOnly="true" runat="server" autocomplete="off" />
            </div>
        </div>
        <br />
        <div class="row">
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label>GL Account</label>
                <asp:TextBox runat="server" ReadOnly="true" ID="txtAccount_Code_Name" />
                <asp:HiddenField runat="server" ID="hdfAccount_Name" />
                <asp:HiddenField ID="hdfAccount_Code" runat="server" />
                <asp:HiddenField ID="hdfParent_Code" runat="server" />
                <asp:HiddenField ID="hdfAccount_Serial" runat="server" />
                <asp:HiddenField ID="hdfLevel" runat="server" />
                <asp:HiddenField ID="hdfAccount_ID" runat="server" />
                <asp:HiddenField ID="hdfAccountExists" runat="server" />
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label>Building</label>
                <asp:DropDownList ID="ddlDoctorBuilding" name="ddlDoctorBuilding" runat="server" AppendDataBoundItems="true"></asp:DropDownList>
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label>Address</label>
                <asp:TextBox runat="server" ID="txtEmployee_Address" TextMode="MultiLine" Style="width: 100%; height: 34px !important; border-radius: 5px !important" />
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label>Remarks</label>
                <asp:TextBox runat="server" ID="txtRemarks" TextMode="MultiLine" Style="width: 100%; height: 34px !important; border-bottom-right-radius: 5px!important" />
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label>Users</label>
                <asp:DropDownList ID="ddluser" name="ddluser" AppendDataBoundItems="true" runat="server"></asp:DropDownList>
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <div class="row">
                    <asp:Label ID="Off_txt" runat="server" Text="Off Days"></asp:Label>
                </div>
                <div class="row">
                    <div class="col-lg-3 col-md-4 col-sm-6">
                        Sun 
                <asp:CheckBox ID="sun" runat="server" />
                    </div>
                    <div class="col-lg-3 col-md-4 col-sm-6">
                        Mon 
                <asp:CheckBox ID="mon" runat="server" />
                    </div>
                    <div class="col-lg-3 col-md-4 col-sm-6">
                        Tue 
                      <asp:CheckBox ID="tue" runat="server" />
                    </div>
                    <div class="col-lg-3 col-md-4 col-sm-6">
                        Wed 
                            <asp:CheckBox ID="wed" runat="server" />
                    </div>
                </div>
                <div class="row">
                    <div class="col-lg-3 col-md-4 col-sm-6">
                        Thur 
                         <asp:CheckBox ID="thur" runat="server" />
                    </div>
                    <div class="col-lg-3 col-md-4 col-sm-6">
                        Fri 
                <asp:CheckBox ID="fri" runat="server" />
                    </div>
                    <div class="col-lg-3 col-md-4 col-sm-6">
                        Sat 
                        <asp:CheckBox ID="sat" runat="server" />
                    </div>
                </div>
            </div>
        </div>
        <div class="row">
        </div>
        <div class="row">
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label>Dependent</label>
                 <asp:TextBox runat="server" ID="txtdependent"   />
            </div>
                  <div class="col-lg-2 col-md-4 col-sm-6 custom-label-checkbox">
                <asp:Label ID="LblIsDoctor" runat="server" Text="Doctor"></asp:Label>
                <asp:CheckBox ID="ChkDoctor" style="width: 58px !important;" runat="server" />
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6 custom-label-checkbox">
                <asp:Label ID="LblIsVisting" runat="server" Text="Visting"></asp:Label>
                <asp:CheckBox ID="ChkVisting" runat="server" />
            </div>


            <div class="col-lg-8 col-md-4 col-sm-6">
            </div>
        </div>

        <div class="row">
             <div class="col-lg-8">
            <div class="row">
                  <div class="col-lg-2 col-md-4 col-sm-6">
                <asp:Button Text="Save" runat="server" ID="btnSave" OnClick="btnSave_Click" UseSubmitBehavior="false" Style="display: none;" />
                <input type="hidden" name="DataJSON" />
                <input type="hidden" name="CustomerJSON" />
                <input type="button" class="btn btn-primry" id="btnSaveH" value="Save" />
            </div>
                 <div class="col-lg-2 col-md-4 col-sm-6">
                <asp:Button Text="View" class="btn-gray" runat="server" ID="btnBack" CausesValidation="false" PostBackUrl="~/Modules/Administrator/EmployeeView.aspx" />
                &nbsp;&nbsp;
            </div>
          
            </div>
        </div>
           
        </div>
        <div class="row">
            <div class="col-lg-0 col-md-4 col-sm-6" style="visibility: hidden">
                <label>Govt.Hospital</label>
                <asp:TextBox ID="txtGovt_Hospital" runat="server" />
            </div>
        </div>
        <asp:RequiredFieldValidator ErrorMessage="Department is required." ControlToValidate="ddlDepartment"
            ID="rfvDepartment" SetFocusOnError="true" InitialValue="0" runat="server" />
    </form>
    <table style="padding: 20px; width: 1130px; height: 210px;">
        <tr>
            <td colspan="6">
                <asp:Label ID="lblMessage" Text="" runat="server" />
            </td>
        </tr>
    </table>
    <asp:HiddenField ID="hdnEmp" runat="server" />
</asp:Content>
