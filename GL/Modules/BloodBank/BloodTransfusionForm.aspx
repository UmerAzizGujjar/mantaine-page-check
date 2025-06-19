<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="BloodTransfusionForm.aspx.cs" Inherits="PMS.BloodTransfusionForm" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/StandardTheme/css/CustomCss/BloodBank.css" rel="stylesheet" />
    <style type="text/css">
      
    </style>
      <script type="text/javascript">
          function redirect() {
              window.location.href = "BloodTransfusionList.aspx";
          }
          function prints() {
              debugger;
              var id = '<%=Request.QueryString["ID"]%>';
              if (id != null) {
                  window.open('ReportViewer.aspx?ReportName=BasePrintBloodTransfusion&ReportTitle=Department Of Pathology&BTR_Id=' + id);
              }
          }

          function prints2() {
              debugger;
              var id = '<%=Request.QueryString["ID"]%>';
              if (id != null) {
                  window.open('ReportViewer.aspx?ReportName=BloodTransfusion&ReportTitle=Department Of Pathology&BTR_Id=' + id);
              }
          }
          function append_ddl() {
              $.ajax({
                  type: "POST",
                  url: "BloodTransfusionForm.aspx/appedddl",
                  data: "",

                  contentType: "application/json; charset=utf-8",
                  dataType: "json",
                  success: function (response) {

                      var parsed_data = JSON.parse(response.d);

                      var row = '<option value="0">Please Select</option>';

                      $.each(parsed_data, function (key, value) {


                          row += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';


                      });


                      $("#ddlComponent").html(row);
                  }

              });
          }
          function getRecords(id) {
              $.ajax({
                  type: "POST",
                  url: "BloodTransfusionForm.aspx/getRecords",
                  data: JSON.stringify({ "id": id }),

                  contentType: "application/json; charset=utf-8",
                  dataType: "json",
                  success: function (response) {
                      var parsed_data = JSON.parse(response.d);
                      var Patient_Id = parsed_data[0].Patient_Id;
                      $("#ywristband").prop('checked', parsed_data[0].BTR_wristY);
                      $("#nwristband").prop('checked', parsed_data[0].BTR_wristN);
                      $("#ybenefits").prop('checked', parsed_data[0].BTR_benefitY);
                      $("#nbenefits").prop('checked', parsed_data[0].BTR_benefitN);
                      $("#ybloodbag").prop('checked', parsed_data[0].BTR_bloodY);
                      $("#nbloodbag").prop('checked', parsed_data[0].BTR_bloodN);
                      $("#yleakage").prop('checked', parsed_data[0].BTR_leakageY);
                      $("#nleakage").prop('checked', parsed_data[0].BTR_leakageN);
                      $("#yexpiry").prop('checked', parsed_data[0].BTR_expY);
                      $("#nexpiry").prop('checked', parsed_data[0].BTR_expN);
                      $("#yinstruction").prop('checked', parsed_data[0].BTR_insY);
                      $("#ninstruction").prop('checked', parsed_data[0].BTR_insN);
                      debugger;
                      $("#yreaction").prop('checked', parsed_data[0].BTR_Transfusion_ReactionY);
                      $("#nreaction").prop('checked', parsed_data[0].BTR_Transfusion_ReactionN);
                      $("#ypregnancy").prop('checked', parsed_data[0].BTR_pregY);
                      $("#npregnancy").prop('checked', parsed_data[0].BTR_pregN);
                      $("#ddlComponent").val(parsed_data[0].BTR_components);
                      $("#manyunits").val(parsed_data[0].BTR_units);
                      $("#txtOnDutyDoctor").val(parsed_data[0].onDutyDoctor);
                      $("#txtPatientGuardian").val(parsed_data[0].PatientGuardian);
                      $("#txtWitnessSignature").val(parsed_data[0].WitnessSignature);
                      $("#txtWitnessCnic").val(parsed_data[0].WitnessCnic);
                      $("#txtWitnessName").val(parsed_data[0].WitnessName);


                      if (parsed_data[0].BTR_what_Date == null || parsed_data[0].BTR_what_Date == "null") {

                      }
                      else {
                          var date = $.datepicker.formatDate('dd M yy', new Date(parseInt(parsed_data[0].BTR_what_Date.substring(6, 19))))


                          $("#reqdate").val(date);

                      }
                      if (parsed_data[0].BTR_what_Time == null || parsed_data[0].BTR_what_Time == "null" || parsed_data[0].BTR_what_Time.includes("ExecuteReader")) {

                      }
                      else {
                          $("#time").val(parsed_data[0].BTR_what_Time);

                      }


                      $("#sdoctor").val(parsed_data[0].BTR_doctor);

                      $("#txtIndication").val(parsed_data[0].BTR_indication);
                      $('#ctl00_MainContent_txtPatient_ID').tokenInput('clear');
                      var tokenData = httpGet("../../json.aspx?Table=Patients&Record=Edit&q=" + Patient_Id);
                      var parsedData = JSON.parse(tokenData);
                      $('#ctl00_MainContent_txtPatient_ID').tokenInput("add", { id: JSON.parse(tokenData)[0].id, name: JSON.parse(tokenData)[0].name });
                      GetTransfusion_Result(id)

                  }

              });
          }
          function getFormattedDate(date) {
              var day = date.getDate();
              var month = date.getMonth() + 1;
              var year = date.getFullYear().toString().slice(2);
              return day + '-' + month + '-' + year;
          }
          function httpGet(theUrl) {
              var xmlHttp = null;
              xmlHttp = new XMLHttpRequest();
              xmlHttp.open("GET", theUrl, false);
              xmlHttp.send(null);
              return xmlHttp.responseText;
          }
          var isProced = true;
          $(document).ready(function () {

              append_ddl();
              var id = '<%=Request.QueryString["ID"]%>';
            if (id != "") {
                $("#btnSave").val('Update');
                getRecords(id);
            }
            $("#reqdate").datepicker({ dateFormat: 'mm/dd/yy' });

            $('#time').ptTimeSelect({});


            assignIds();
            loadtokenInputsDefault();
            $("#btnSave").on('click', function () {
                debugger;
                isProced = true;
                var Patient_id = $("#ctl00_MainContent_txtPatient_ID").val();

                var ybenefits = $("#ybenefits").prop('checked');
                var nbenefits = $("#nbenefits").prop('checked');

                var ywristband = $("#ywristband").prop('checked');
                var nwristband = $("#nwristband").prop('checked');

                var ybloodbag = $("#ybloodbag").prop('checked');
                var nbloodbag = $("#nbloodbag").prop('checked');

                var yleakage = $("#yleakage").prop('checked');
                var nleakage = $("#nleakage").prop('checked');

                var yexpiry = $("#yexpiry").prop('checked');
                var nexpiry = $("#nexpiry").prop('checked');

                var yinstruction = $("#yinstruction").prop('checked');
                var ninstruction = $("#ninstruction").prop('checked');

                var yreaction = $("#yreaction").prop('checked');
                var nreaction = $("#nreaction").prop('checked');

                var ypregnancy = $("#ypregnancy").prop('checked');
                var npregnancy = $("#npregnancy").prop('checked');

                var onDutyDoctor = $('#txtOnDutyDoctor').val();
                var PatientGuardian = $('#txtPatientGuardian').val();
                var WitnessSignature = $('#txtWitnessSignature').val();
                var WitnessCnic = $('#txtWitnessCnic').val();
                var WitnessName = $('#txtWitnessName').val();



                var component = $("#ddlComponent").val();
                var units = $("#manyunits").val();
                var Date = $("#reqdate").val();
                var Time = $("#time").val();
                var sDoc = $("#sdoctor").val();
                var indication = $("#txtIndication").val();
                if (component == "0" || units == "" || Date == "" || Time == "" || sDoc == "" || indication == "") {
                    debugger
                    isProced = false;

                }
                if (yreaction == false && nreaction == false) {
                    debugger
                    isProced = false;

                }
                if (ypregnancy == false && npregnancy == false) {
                    debugger
                    isProced = false;

                }
                var btnSave = $("#btnSave").val();
                if (isProced == true) {
                    var arr = [];
                    debugger;
                    var x = document.getElementById("tblCheckList");

                    for (var i = 1; i < x.rows.length; i++) {
                        debugger;
                        var CheckList1 = {};
                        var CheckList2 = {};
                        var CheckList3 = {};
                        var CheckList4 = {};
                        CheckList1.Header_Text = x.rows[0].cells[1].innerText;
                        console.log(CheckList1);

                        CheckList1.checkList = x.rows[i].cells[0].innerText;

                        CheckList1.value = x.rows[i].cells[1].childNodes[0].value;

                        CheckList1.RowNumber = i;

                        CheckList2.Header_Text = x.rows[0].cells[2].innerText;

                        CheckList2.checkList = x.rows[i].cells[0].innerText;

                        CheckList2.value = x.rows[i].cells[2].childNodes[0].value;

                        CheckList2.RowNumber = i;

                        CheckList3.Header_Text = x.rows[0].cells[3].innerText;

                        CheckList3.checkList = x.rows[i].cells[0].innerText;

                        CheckList3.value = x.rows[i].cells[3].childNodes[0].value;

                        CheckList3.RowNumber = i;

                        CheckList4.Header_Text = x.rows[0].cells[4].innerText;

                        CheckList4.checkList = x.rows[i].cells[0].innerText;

                        CheckList4.value = x.rows[i].cells[4].childNodes[0].value;

                        CheckList4.RowNumber = i;

                        arr.push(CheckList1, CheckList2, CheckList3, CheckList4);

                    }
                    debugger;
                    console.log(arr);
                    var patient_id = $("#ctl00_MainContent_txtPatient_ID").val();
                    if (patient_id == "") return false;
                    var id = '<%=Request.QueryString["ID"]%>';
                    $.ajax({
                        type: "POST",
                        url: "BloodTransfusionForm.aspx/SaveAll",
                        data: JSON.stringify
                            ({
                                "btnSave": btnSave,
                                "Patient_id": Patient_id,
                                "ywristband": ywristband,
                                "nwristband": nwristband,
                                "ybenefits": ybenefits,
                                "nbenefits": nbenefits,
                                "ybloodbag": ybloodbag,
                                "nbloodbag": nbloodbag,
                                "yleakage": yleakage,
                                "nleakage": nleakage,
                                "yexpiry": yexpiry,
                                "nexpiry": nexpiry,
                                "yinstruction": yinstruction,
                                "ninstruction": ninstruction,
                                "yreaction": yreaction,
                                "nreaction": nreaction,
                                "ypregnancy": ypregnancy,
                                "npregnancy": npregnancy,
                                "component": component,
                                "units": units,
                                "Date": Date,
                                "Time": Time,
                                "sDoc": sDoc,
                                "indication": indication,
                                "id": id,
                                "onDutyDoctor": onDutyDoctor,
                                "PatientGuardian": PatientGuardian,
                                "WitnessSignature": WitnessSignature,
                                "WitnessCnic": WitnessCnic,
                                "WitnessName": WitnessName,
                                "checkList": arr,


                            }),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (response) {
                            var master_id = response.d;
                            if (master_id != '-1') {
                                alert("Data has been saved successfully");
                                window.location.href = "BloodTransfusionForm.aspx?ID=" + master_id;
                            }

                        }
                        , error: function () {
                        }
                    });
                }
                else {
                    alert("Please Fill All Mendotary Fields");
                    return true;
                }

            });
        });

          $(function () {
              $("#tabs").tabs();

          });
          function NewWindow() {
              window.location = "BloodTransfusionForm.aspx";
          }
          function GetTransfusion_Result(id) {

              $.ajax({
                  type: "POST",
                  url: "BloodTransfusionForm.aspx/GetTransfusion_Result",
                  data: JSON.stringify({
                      "id": id
                  }),
                  contentType: "application/json; charset=utf-8",
                  dataType: "json",
                  success: function (response) {
                      debugger;
                      var arrData = response.d;

                      for (var i = 0; i < arrData.length; i++) {
                          debugger;

                          var id = arrData[i].Complete_ID;
                          var s = id;

                          $(s).val(arrData[i].Transfusion_CheckList_Value);
                      }
                      $("#btnSave").val('Update');



                  }, error: function () {

                  }
              });

          }

          function loadAjax() {
              var Patient_ID = $("#<%= hdfPatient_ID.ClientID %>").val();
              if (Patient_ID != '(New)') {
                  localStorage.PatientIDforNewForm = Patient_ID;
                  $.ajax({
                      type: "POST",
                      url: "BloodTransfusionForm.aspx/GetDetail",
                      data: "{'PatientID':" + Patient_ID + "}",
                      contentType: "application/json; charset=utf-8",
                      dataType: "json",
                      success: OnSuccess,
                      failure: function (response) {


                      }
                  });
              }
          }
          function assignIds() {
              $('.checklist').each(function (index) {

                  $(this).find('tr:eq(1)').find('td:eq(1)').find('input').attr('id', 'txt_temp_bt' + 0);
                  $(this).find('tr:eq(1)').find('td:eq(2)').find('input').attr('id', 'txt_temp_mt' + 0);
                  $(this).find('tr:eq(1)').find('td:eq(3)').find('input').attr('id', 'txt_temp_ht' + 0);
                  $(this).find('tr:eq(1)').find('td:eq(4)').find('input').attr('id', 'txt_temp_at' + 0);

                  $(this).find('tr:eq(2)').find('td:eq(1)').find('input').attr('id', 'txt_pulse_bt' + 1);
                  $(this).find('tr:eq(2)').find('td:eq(2)').find('input').attr('id', 'txt_pulse_mt' + 1);
                  $(this).find('tr:eq(2)').find('td:eq(3)').find('input').attr('id', 'txt_pulse_ht' + 1);
                  $(this).find('tr:eq(2)').find('td:eq(4)').find('input').attr('id', 'txt_pulse_at' + 1);

                  $(this).find('tr:eq(3)').find('td:eq(1)').find('input').attr('id', 'txt_resp_bt' + 2);
                  $(this).find('tr:eq(3)').find('td:eq(2)').find('input').attr('id', 'txt_resp_mt' + 2);
                  $(this).find('tr:eq(3)').find('td:eq(3)').find('input').attr('id', 'txt_resp_ht' + 2);
                  $(this).find('tr:eq(3)').find('td:eq(4)').find('input').attr('id', 'txt_resp_at' + 2);

                  $(this).find('tr:eq(4)').find('td:eq(1)').find('input').attr('id', 'txt_bp_bt' + 3);
                  $(this).find('tr:eq(4)').find('td:eq(2)').find('input').attr('id', 'txt_bp_mt' + 3);
                  $(this).find('tr:eq(4)').find('td:eq(3)').find('input').attr('id', 'txt_bp_ht' + 3);
                  $(this).find('tr:eq(4)').find('td:eq(4)').find('input').attr('id', 'txt_bp_at' + 3);

                  $(this).find('tr:eq(5)').find('td:eq(1)').find('input').attr('id', 'txt_dyspnia_bt' + 4);
                  $(this).find('tr:eq(5)').find('td:eq(2)').find('input').attr('id', 'txt_dyspnia_mt' + 4);
                  $(this).find('tr:eq(5)').find('td:eq(3)').find('input').attr('id', 'txt_dyspnia_ht' + 4);
                  $(this).find('tr:eq(5)').find('td:eq(4)').find('input').attr('id', 'txt_dyspnia_at' + 4);

                  $(this).find('tr:eq(6)').find('td:eq(1)').find('input').attr('id', 'txt_chills_bt' + 5);
                  $(this).find('tr:eq(6)').find('td:eq(2)').find('input').attr('id', 'txt_chills_mt' + 5);
                  $(this).find('tr:eq(6)').find('td:eq(3)').find('input').attr('id', 'txt_chills_ht' + 5);
                  $(this).find('tr:eq(6)').find('td:eq(4)').find('input').attr('id', 'txt_chills_at' + 5);

                  $(this).find('tr:eq(7)').find('td:eq(1)').find('input').attr('id', 'txt_groins_bt' + 6);
                  $(this).find('tr:eq(7)').find('td:eq(2)').find('input').attr('id', 'txt_groins_mt' + 6);
                  $(this).find('tr:eq(7)').find('td:eq(3)').find('input').attr('id', 'txt_groins_ht' + 6);
                  $(this).find('tr:eq(7)').find('td:eq(4)').find('input').attr('id', 'txt_groins_at' + 6);

                  $(this).find('tr:eq(8)').find('td:eq(1)').find('input').attr('id', 'txt_others_bt' + 7);
                  $(this).find('tr:eq(8)').find('td:eq(2)').find('input').attr('id', 'txt_others_mt' + 7);
                  $(this).find('tr:eq(8)').find('td:eq(3)').find('input').attr('id', 'txt_others_ht' + 7);
                  $(this).find('tr:eq(8)').find('td:eq(4)').find('input').attr('id', 'txt_others_at' + 7);

                  $(this).find('tr:eq(9)').find('td:eq(1)').find('input').attr('id', 'txt_sig_bt' + 8);
                  $(this).find('tr:eq(9)').find('td:eq(2)').find('input').attr('id', 'txt_sig_mt' + 8);
                  $(this).find('tr:eq(9)').find('td:eq(3)').find('input').attr('id', 'txt_sig_ht' + 8);
                  $(this).find('tr:eq(9)').find('td:eq(4)').find('input').attr('id', 'txt_sig_at' + 8);



              });

          }

          function OnSuccess(data) {
              if (data.d != '') {
                  var mydate = new Date(Date.parse(data.d.Entry_Date));
                  var dateR = mydate.toLocaleDateString();
                  $('#<%= vlblPatients_Name.ClientID %>').text(ReplaceNullWith_Space(data.d.Name));
                $('#<%= vLbl_Age.ClientID %>').text(ReplaceNullWith_Space(data.d.Age));
                $('#<%= vLbl_Gender.ClientID %>').text(ReplaceNullWith_Space(data.d.Gender));
                $('#<%= vLbl_RegDate.ClientID %>').text(dateR);
                $('#<%= vLbl_Adress.ClientID %>').text(ReplaceNullWith_Space(data.d.Address));
                $('#<%= vLbl_Contact.ClientID %>').text(ReplaceNullWith_Space(data.d.Mobile));
              <%--  $('#<%= lblDpt.ClientID %>').text(ReplaceNullWith_Space(data.d.department));

                $('#<%= lblPatient_Category.ClientID %>').text(ReplaceNullWith_Space(data.d.Patient_type));--%>
              }
          }
          function ReplaceNullWith_Space(Data) {
              if (Data == "null")
                  return " ";
              else
                  return Data;
          }


          function loadtokenInputsDefault() {
              $('#ctl00_MainContent_txtPatient_ID').tokenInput("../../json.aspx?Table=Patients",
                  {
                      tokenLimit: 1,
                      onAdd: function (item) {
                          try {

                              $("#hdfPatient_ID").val(item.id);
                              localStorage.PatientIDforNewForm = item.id;
                              loadAjax();
                          }
                          catch (err) {
                              alert(err.message);
                          }

                      }
                  });
          }


          function loadtokenInput(data) {
              $("#ctl00_MainContent_txtMRNO").tokenInput("../../json.aspx?Table=Patients",
                  {
                      prePopulate: data,
                      tokenLimit: 1,
                      onAdd: function (item) {
                          $("#ctl00_MainContent_txtMRNO").val(item.id);
                          loadtest();
                      }
                  });


              $('#ctl00_MainContent_ddlDepartment').val(localStorage.DeptID)
          }

      </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    
   
             <div class="row">
    <!-- Left Card -->
    <div class="col-lg-5 col-md-5 col-sm-12">
        <div class="card">
            <div class="card-body">
                <div class="row">
                    <div class="col-lg-4 col-md-5 col-sm-6 text-center">
                        <div class="image-container">
                            <img src="~../../../../wwwroot/StandardTheme/images/dashboard_Icons/Patient.png" alt="Patient Image" class="img-fluid rounded-circle patient-image" />
                        </div>
                    </div>
                    <div class="col-lg-8 col-md-7 col-sm-6">
                        <asp:TextBox ID="txtOut_Patient_ID" runat="server" ReadOnly="True" style="display:none;"></asp:TextBox>

                        <div class="row mb-3">
                            <div class="col-lg-5 col-md-5 col-sm-6 top">
                                <asp:Label ID="lblPatient_Name" runat="server" Text="Patient Name :"></asp:Label>

                            </div>
                            <div class="col-lg-7 col-md-7 col-sm-6 top">
                                  <asp:Label ID="vlblPatients_Name" runat="server"></asp:Label>
                            </div>
                        </div>

                        <div class="row mb-3 mtt">
                            <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                               <asp:Label ID="lblAge_Years" runat="server" Text="Age Years :"></asp:Label>
                            </div>
                            <div class="col-lg-7 col-md-7 col-sm-6 top">
                               <asp:Label ID="vLbl_Age" runat="server"></asp:Label>
                            </div>
                        </div>

                        <div class="row mb-3 mtt">
                            <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                  <asp:Label ID="lblContactNo" runat="server" Text="Contact No :"></asp:Label>
                            </div>
                            <div class="col-lg-7 col-md-7 col-sm-6 top">
                                 <asp:Label ID="vLbl_Contact" runat="server"></asp:Label>
                            </div>
                        </div>

                        <div class="row mb-3 mtt">
                            <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                    <asp:Label ID="lblGender" runat="server" Text="Gender :"></asp:Label>
                            </div>
                            <div class="col-lg-7 col-md-7 col-sm-6 top">
                                       <asp:Label ID="vLbl_Gender" runat="server"></asp:Label>
                            </div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                    <asp:Label ID="lblAdress" runat="server" Text="Address :"></asp:Label>
                            </div>
                            <div class="col-lg-7 col-md-7 col-sm-6 top">
                                         <asp:Label ID="vLbl_Adress" runat="server"></asp:Label>
                            </div>                          
                        </div>
                   
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Right Card -->
    <div class="col-lg-5 col-md-5 col-sm-12">
        <div class="card">
            <div class="card-body">
            
                <div class="row mb-3">
                    <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                        <asp:Label ID="lblPatien_ID" runat="server" Text="Patient No *"></asp:Label>
                    </div>
                    <div class="col-lg-5 col-md-5 col-sm-6">
                           <asp:TextBox ID="txtPatient_ID" runat="server"></asp:TextBox>
                    </div>
                </div>

                <div class="row mb-3">
                    <div class="col-lg-5 col-md-5 col-sm-6">
                          <asp:Label ID="LblReg_Date" runat="server" Text="Reg. Date:"></asp:Label>
                    </div>
                    <div class="col-lg-7 col-md-5 col-sm-6">
                           <asp:Label ID="vLbl_RegDate" runat="server"></asp:Label>
                    </div>
                </div>

                <div class="row mb-3">
                    <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                        <asp:Label ID="dlbldpt" runat="server" Text="Department"></asp:Label>
                    </div>
                    <div class="col-lg-7 col-md-5 col-sm-6 detail">
                        <asp:Label ID="lblDpt" runat="server" Text=""></asp:Label>
                    </div>
                </div> 
                   <div class="row mb-3 mtt">
                            <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                   <asp:Label ID="Label10" runat="server" Text="Patient Category:"></asp:Label>
                            </div>
                            <div class="col-lg-7 col-md-7 col-sm-6 top">
                              <asp:Label ID="lblPatient_Category" runat="server"></asp:Label>
                            </div>
                        </div>

                        

            
            </div>
        </div>
    </div>
</div>
   <div id="tabs">
            <ul>
                  
                <li> <a href="#Tab-1">Blood Request Form</a></li>
                <li> <a href="#Tab-2">Blood Transfusion Form</a></li>
                
            </ul>
  <div id="Tab-1">
           


            <table class="table3">
                <div class="form-container">
                    <div class="row">
                        <div class="col-lg-3 col-md-6 col-sm-6">
                            <label for="ddlComponent">What component needed *</label>
                            <select id="ddlComponent">
                                
                            </select>
                        </div>
                        <div class="col-lg-3 col-md-6 col-sm-6">
                            <label for="manyunits">How many units *</label>
                            <input type="text" name="units" id="manyunits" />
                        </div>

                        <div class="col-lg-3 col-md-6 col-sm-6">
                            <label for="reqdate">On what date required *</label>
                            <input type="text" name="date" id="reqdate" />
                        </div>

                        <div class="col-lg-3 col-md-6 col-sm-6">
                            <label for="time">At what time *</label>
                            <input type="text" name="time" id="time" />
                        </div>
                    </div>
                    <br />
                    <div class="row">
                        <div class="col-lg-3 col-md-6 col-sm-6">
                            <div class="row">
                                <label>Previous Transfusion Reaction *</label>
                            </div>
                            <div class="row">
                                <div class="col-lg-2 col-md-6 col-sm-6">
                                    <label for="yreaction">Yes</label>
                                    <input type="checkbox" name="yreaction" value="yreaction" id="yreaction" />
                                </div>
                                <div class="col-lg-2 col-md-6 col-sm-6">
                                    <label for="nreaction">No</label>
                                    <input type="checkbox" name="nreaction" value="nreaction" id="nreaction" />
                                </div>
                            </div>
                        </div>

                        <div class="col-lg-3 col-md-6 col-sm-6">
                            <div class="row">
                                <label>Previous Pregnancy *</label>
                            </div>
                            <div class="row">
                                <div class="col-lg-2 col-md-6 col-sm-6">
                                    <label for="ypregnancy">Yes</label>
                                    <input type="checkbox" name="ypregnancy" value="ypregnancy" id="ypregnancy" />
                                </div>
                                <div class="col-lg-2 col-md-6 col-sm-6">
                                    <label for="npregnancy">No</label>
                                    <input type="checkbox" name="npregnancy" value="npregnancy" id="npregnancy" />
                                </div>
                            </div>
                        </div>
                        <div class="col-lg-3 col-md-6 col-sm-6">
                            <label for="sdoctor">Name and Signature of Doctor *</label>
                            <input type="text" name="doctor" id="sdoctor" />
                        </div>

                        <div class="col-lg-3 col-md-6 col-sm-6">
                            <label for="txtIndication">Indication *</label>
                            <input type="text" name="txtIndication" id="txtIndication" />
                        </div>
                    </div>
                    <br />
                    <div class="row">
                        <div class="col-lg-1 col-md-2 col-sm-3">
                            <input type="button" value="Print" class="btn btn-yellow" onclick="prints2()" id="Button1" />
                        </div>
                    </div>
            </table>





        </div>
         
            <div id="Tab-2">
                
            <div class="table-container">
                <div class="table-responsive">
                	     <table class="table table-bordered">
                        <thead>
                            <tr>
                                <th>Pre Transfusion Checklist</th>
                                <th>Yes</th>
                                <th>No</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td>Explain Benefits/risks to the patient/attend</td>
                                <td>
                                    <input type="checkbox" name="check1" value="ybenefits" id="ybenefits" /></td>
                                <td>
                                    <input type="checkbox" name="check2" value="nbenefits" id="nbenefits" /></td>
                            </tr>
                            <tr>
                                <td>Checked and matched data on wrist band with compatibility label</td>
                                <td>
                                    <input type="checkbox" name="check3" value="ywristband" id="ywristband" /></td>
                                <td>
                                    <input type="checkbox" name="check4" value="nwristband" id="nwristband" /></td>
                            </tr>
                            <tr>
                                <td>Checked and matched data on compatibility label with blood bag</td>
                                <td>
                                    <input type="checkbox" name="check5" value="ybloodbag" id="ybloodbag" /></td>
                                <td>
                                    <input type="checkbox" name="check6" value="nbloodbag" id="nbloodbag" /></td>
                            </tr>
                            <tr>
                                <td>Checked bag for leakage, clumps or abnormal color</td>
                                <td>
                                    <input type="checkbox" name="check7" value="yleakage" id="yleakage" /></td>
                                <td>
                                    <input type="checkbox" name="check8" value="nleakage" id="nleakage" /></td>
                            </tr>
                            <tr>
                                <td>Checked expiry date on bag</td>
                                <td>
                                    <input type="checkbox" name="check9" value="yexpiry" id="yexpiry" /></td>
                                <td>
                                    <input type="checkbox" name="check10" value="nexpiry" id="nexpiry" /></td>
                            </tr>
                            <tr>
                                <td>Checked any special instruction</td>
                                <td>
                                    <input type="checkbox" name="check11" value="yinstruction" id="yinstruction" /></td>
                                <td>
                                    <input type="checkbox" name="check12" value="ninstruction" id="ninstruction" /></td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>

            <div class="table-container">
                <div class="table-responsive">
                   <table class=" table responstable checklist" id="tblCheckList" name="checklist">
  <tr>
    <th>Tranfusion Checklist</th>
    <th>Before Tranfusion</th>
    <th>15min. After</th>
    <th>1hour After</th>
    <th>After Transfusion</th>
  </tr>
  <tr>
    <td>Temperature</td>
    <td><input type="text" name="tempbefore" /></td>
    <td><input type="text" name="temp15" /> </td>
    <td><input type="text" name="1hourtemp" /></td>
    <td><input type="text" name="tempafter" /></td>

  </tr>
  <tr>
    <td>Pulse</td>
    <td><input type="text" name="pulsebefore" id="pulsebefore" /></td>
    <td><input type="text" name="pulse15" id="pulse15"></td>
    <td><input type="text" name="1hourpulse" id="1hourpulse" ></td>
    <td><input type="text" name="pulseafter" id="pulseafter" ></td>
  </tr>
  <tr>
     <td>Respiratory Rate</td>
    <td><input type="text" name="ratebefore" id="ratebefore"></td>
    <td><input type="text" name="rate15" id="rate15"></td>
    <td><input type="text" name="1hourrate" id="1hourrate"></td>
    <td><input type="text" name="rateafter" id="rateafter"></td>
  </tr>
  <tr>
   <td>Blood Pressure</td>
    <td><input type="text" name="bloodprebefore" id="bloodprebefore"></td>
    <td><input type="text" name="bloodpre15" id="bloodpre15" ></td>
    <td><input type="text" name="1hourbloodpre" id="1hourbloodpre"></td>
    <td><input type="text" name="bloodpreafter" id="bloodpreafter"></td>
  </tr>
  <tr>
  <td>Dyspnea</td>
    <td><input type="text" name="dyspneabefore" id="dyspneabefore"></td>
    <td><input type="text" name="dyspnea15" id="dyspnea15"></td>
    <td><input type="text" name="1hourdyspnea" id="1hourdyspnea"></td>
    <td><input type="text" name="dyspneaafter" id="dyspneaafter"></td>
  </tr>
  <tr>
  <td>Chills/Rigors</td>
    <td><input type="text" name="chillsbefore" id="chillsbefore" ></td>
    <td><input type="text" name="chills15" id="chills15" ></td>
    <td><input type="text" name="1hourchills" id="1hourchills" ></td>
    <td><input type="text" name="chillsafter" id="chillsafter" ></td>
  </tr>
  <tr>
   <td>Pain Groins</td>
    <td><input type="text" name="painbefore" id="painbefore" ></td>
    <td><input type="text" name="pain15" id="pain15" ></td>
    <td><input type="text" name="1hourpain" id="1hourpain" ></td>
    <td><input type="text" name="painafter" id="painafter" ></td>
</tr>

<tr>
     <td>Any Other</td>
    <td><input type="text" name="anyotherbefore" id="anyotherbefore" ></td>
    <td><input type="text" name="anyother15" id="anyother15" ></td>
    <td><input type="text" name="1houranyother" id="1houranyother" ></td>
    <td><input type="text" name="anyotherafter" id="anyotherafter" ></td>
  </tr>

<tr>
    <td>Name & Sig.</td>
    <td><input type="text" name="sigbefore" id="sigbefore"/ ></td>
    <td><input type="text" name="sig15" id="sig15"/></td>
    <td><input type="text" name="1hoursig" id="1hoursig" /></td>
    <td><input type="text" name="sigafter" id="sigafter"/ ></td>
  </tr>



</table>
                </div>
            </div>
            <div class="table-container">
                <div class="table-responsive">
                    <table class="table table-custom">
                        <tbody>
                            <tr>
                                <td></td>
                                <td></td>
                                <td>
                                    <input type="text" id="txtPatientGuardian" class="form-control" /></td>
                                <td>مریض/سرپرست/وارث/شریک حیات</td>
                                <td>
                                    <input type="text" id="txtOnDutyDoctor" class="form-control" /></td>
                                <td>نام ڈاکٹر آن ڈیوٹی</td>
                            </tr>
                            <tr>
                                <td>
                                    <input type="text" id="txtWitnessName" class="form-control" /></td>
                                <td>نام گواہ</td>
                                <td>
                                    <input type="text" id="txtWitnessCnic" class="form-control" /></td>
                                <td>شناختی کارڈ نمبر</td>
                                <td>
                                    <input type="text" id="txtWitnessSignature" class="form-control" /></td>
                                <td>دستخط گواہ</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
            <div class="row">
                    <div class="col-lg-2 col-md-4 col-sm-12">
            <input type="button" value="Print" onclick="prints()" id="btnPrint" />
                </div>
                </div>
        </div>
    </div>

    <div class="row" style="margin-top: 1%">
      <div class="col-lg-8 col-md-8 col-sm-8">
          <div class="row">
                 <div class="col-lg-2 col-md-4 col-sm-12">
                <input type="button" class="btn btn-yellow" value="Save" id="btnSave" />
            </div>
            <div class="col-lg-2 col-md-4 col-sm-12">
                <input type="button" class="btn btn-yellow" value="List View" onclick="redirect()" id="btnRedirect" />
            </div> 
              <div class="col-lg-2 col-md-4 col-sm-12">
                <input type="button" class="btn btn-yellow" value="New" onclick="NewWindow()" id="btnNew" />
            </div>
          </div>
      </div>
         
     
    </div>
    <asp:HiddenField ID="hdfPatient_ID" Value="(New)" runat="server" ClientIDMode="Static" />

</asp:Content>
