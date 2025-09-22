<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="RegisterPatient.aspx.cs" Inherits="PMS.Modules.PatientManagement.RegisterPatient" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/Tibbit_theme/css/CustomCss/Toaster.css" rel="stylesheet" />
    <script src="../../wwwroot/Tibbit_theme/CustomJs/RegPatient.js" type="text/javascript"></script>
    <link href="../../wwwroot/Tibbit_theme/css/RegPat.css" rel="stylesheet" />
   
      <script type="text/javascript">
          $(document).ready(function () {
              var reg_id = '<%= Request.QueryString["Reg_id"] %>'
         if (reg_id != "") {
            
             Get_Pat_Info(reg_id);
             
          
             $('#SavePatient_Data').val('Update');
         }
         else {
             $('#btnPrint').prop('disabled', true);
             fillmrno();
           
             $('#ddl_status').select2();
             $('#ddl_bloodGroup').select2();
             $('#ddlCountry').select2();
             $('#ddlstate').select2();
             $('#txtcity').select2();
             $('#txtarea').select2();
             $('#ddlRelation').select2();
             $('#ddl_name').select2();
             $('#PrefixAge').select2();

              }

                       
          });

          
          
          //Print
          debugger
          function PrintReceipt() {
              debugger;
              var reg_id = '<%= Request.QueryString["Reg_id"] %>'
              var locationInfo = window.location;
              var url = "/ReportViewer.aspx?ReportName=Reg_Patient_Print&Title=Register Patient Print &Patient_ID=" + reg_id;
              if (!locationInfo.origin.includes('localhost')) {
                  var urlInfo = window.location.href.split('/');
                  var ip = urlInfo[2];
                  var foldername = urlInfo[3];
                  url = 'http://' + ip + '/' + foldername + "/ReportViewer.aspx?ReportName=Reg_Patient_Print&Title=Register Patient Print &Patient_ID=" + reg_id;
              }
              window.open(url, '_blank');
          }
      </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Patient Details Section -->
    <div class="row">
        <div class="col-lg-11 col-md-10 col-sm-12">
    <div class="card">
        <input type="hidden" id="hfAntiForgery" runat="server" />
        <input type="hidden" id="hdfPatient_ID" />
        <input type="hidden" id="hdn_regid" />
        <div class="row">
            <div class="col-lg-1 col-md-3 col-sm-6">
                <label for="txt_Mrno">MR No</label>
                <input type="text" id="txt_Mrno"  class="form-control" disabled />
            </div>
            <div class="col-lg-1 col-md-3 col-sm-6">
                <label for="ddl_name">Name<span style="color: red;">*</span></label>
                <select id="ddl_name" tabindex="1" class="form-control">
                    <option value="Mr.">Mr.</option>
                    <option value="Mrs.">Mrs.</option>
                    <option value="Ms.">Ms.</option>
                    <option value="B/O.">B/O.</option>
                </select>
            </div>
            <div class="col-lg-3 col-md-6 col-sm-9">
                <label></label>
                <input name="dob" style="margin-top: 6px" tabindex="2" type="text" id="txt_name" class="form-control" />
                <span id="firstname-error" class="span_txt" style="display: none;">Please Enter First Name</span>
            </div>
            <div class="col-lg-1 col-md-3 col-sm-6">
                <label for="ddlRelation">Relation<span style="color: red;">*</span></label>
                <select id="ddlRelation" tabindex="3" class="form-control">
                    <option value="S/O">S/O</option>
                    <option value="W/O">W/O</option>
                    <option value="D/O">D/O</option>
                </select>
            </div>
            <div class="col-lg-3 col-md-6 col-sm-9">
                <label></label>
                <input type="text" style="margin-top: 6px" tabindex="4" id="txt_relation" class="form-control" />
                <span id="relation-error" class="span_txt" style="display: none;">Please Enter Last Name</span>
            </div>
            <div class="col-lg-1 col-md-3 col-sm-6">
                <label for="PrefixAge">Age/DOB<span style="color: red;">*</span></label>
                <select id="PrefixAge" tabindex="5" class="form-control">
                    <option value="Year">Year</option>
                    <option value="Month">Month</option>
                    <option value="Day">Day</option>
                </select>
            </div>
            <div class="col-lg-1 col-md-3 col-sm-6">
                <label></label>
                <input type="text" style="margin-top: 7px" tabindex="6" id="txt_dob" class="form-control" placeholder="DOB" onchange="CalculateDateOfBirth();" />
            </div>
            <div class="col-lg-1 col-md-3 col-sm-6">
                <label></label>
                <input type="text" id="txtAge_yearss" tabindex="7" style="margin-top: 7px" class="form-control" placeholder="dd mmyy" />
                <span id="age-error" class="span_txt" style="display: none;">Enter Age</span>
            </div>
        </div>
    <div class="row">
        <div class="col-lg-2 col-md-6 col-sm-9">
    <label for="ddl_Gender">Gender</label>
    <select id="ddl_Gender" tabindex="8" >
        <option value="0">Select Gender</option>
    </select>
</div>
  

        <div class="col-lg-2 col-md-4 col-sm-6">
            <label for="ddl_status">Marital Status</label>
            <select id="ddl_status" tabindex="9" class="form-control">
                <option value="0">Select Martial Status</option>
            </select>
        </div>
        <div class="col-lg-2 col-md-4 col-sm-6">
            <label for="txt_mobile">Mobile<span style="color: red;">*</span></label>
            <input type="text" id="txt_mobile" tabindex="10" class="form-control" />
            <span id="mobile-error" class="span_txt" style="display: none;">Please Enter Phone Number</span>
        </div>
        <div class="col-lg-2 col-md-4 col-sm-6">
            <label for="ddl_bloodGroup">Blood Group</label>
            <select id="ddl_bloodGroup" tabindex="11" class="form-control">
                <option value="0">Select Blood Group</option>
            </select>
        </div>
        <div class="col-lg-2 col-md-4 col-sm-6">
            <label for="txt_cnic">CNIC</label>
            <input type="text" id="txt_cnic" tabindex="12" class="form-control" />
        </div>
        <div class="col-lg-2 col-md-4 col-sm-6">
            <label>Country</label>
            <select id="ddlCountry" tabindex="13" class="form-control">
                 <option value="0">Select Country</option>
            </select>
        </div>
    </div>
    <div class="row">
        <div class="col-lg-2 col-md-4 col-sm-6">
            <label for="ddlstate">Province</label>
            <select id="ddlstate" tabindex="14" class="form-control">
                 <option value="0">Select Province</option>
            </select>
        </div>
        <div class="col-lg-2 col-md-4 col-sm-6">
            <label for="txtcity">City</label>
            <select id="txtcity"  tabindex="15" class="form-control">
                <option value="0">Select City</option>
            </select>
        </div>
        <div class="col-lg-2 col-md-4 col-sm-6">
            <label for="txtarea">Area</label>
            <select id="txtarea" tabindex="16" class="form-control">
                <option value="0">Select Area</option>
            </select>
        </div>
        <div class="col-lg-6 col-md-8 col-sm-10">
            <label for="txt_Address">Address<span style="color: red;">*</span></label>
            <input type="text" tabindex="17" id="txt_Address" class="form-control" />
            <span id="address-error" class="span_txt" style="display: none;">Please Enter Address</span>
        </div>
    </div>
    </div>
    </div>
        </div>
        <div class="row">
            <div class=" col-lg-8">
                <div class="row">
                    <div class="col-lg-2 col-md-3 col-sm-3 text-center">
                        <input type="button" id="SavePatient_Data" class="btn-primry" onclick="SavePatient();" value="Save&Print" />
                    </div>
                    <div class="col-lg-2 col-md-2 col-sm-3 text-center">
                        <input type="button" id="btnlist" class="btn-gray" onclick="window.location = 'RegList.aspx'" value="View" />
                    </div>

                    <div class="col-lg-2 col-md-2 col-sm-3">
                        <input type="button" id="btnPrint" class="btn btn-primry" onclick="PrintReceipt()" value="Print" />
                    </div>
                </div>
            </div>
        </div>


</asp:Content>
