<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AddStudent.aspx.cs" Inherits="PMS.AddStudent" %>


<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/Student.css" rel="stylesheet" />

    <script src="../../wwwroot/THEME_TIBBIT/CustomJs/Student.js"></script>

    <script type="text/javascript">
        $(document).ready(function () {
            <% if (Request.QueryString["ID"] != null)
        { %>
            var Stu_ID = '<%= Request.QueryString["ID"]%>'
            LoadStudentData(Stu_ID);
            <% } %>
            var studentid = '<%= Request.QueryString["ID"]%>'
            if (studentid == '') {
                loadnewaccountToCreate();
            }
            var date = '<%= DateTime.Now%>';
            $("#txt_Date").datepicker({ dateFormat: 'mm/dd/yy', changeMonth: true, changeYear: true, yearRange: "-50:+50" }).attr('readonly', 'readonly');
            date = moment(date).format('L');
            $("#txt_Date").val(date);

            $("#txtadmDate").datepicker({ dateFormat: 'mm/dd/yy', changeMonth: true, changeYear: true, yearRange: "-50:+50" }).attr('readonly', 'readonly');
            $("#txtadmDate").val(date);
            

        });
        function sendFile(ID) {
            debugger;
            var data = new FormData();
            data.append('file', $('#fileupload')[0].files[0]);
            data.append('ID', ID);
            $.ajax({
                type: 'post',
                url: 'upload/UploadStudImg.ashx',
                data: data,
                success: function (status) {
                    console.log("Upload Successful:", status);
                },
                processData: false,
                contentType: false,
                error: function (xhr, status, error) {
                    alert("Error: " + status + " - " + error);
                    console.log("Response Text:", xhr.responseText);
                    console.log("Status:", xhr.status);
                    console.log("Error:", error);
                }

            });

        }
    
        function SaveStudent() {
            debugger;
            var Student_Id = $('#Student_Id').val();
            Student_Id = '<%= Request.QueryString["ID"]%>'

            if (Student_Id == '' || Student_Id == "" || Student_Id == null || Student_Id == "null") {
                Student_Id = 0;
            }

            var btnsave = $('#btnSave').val();
            var Rollnum = $('#Rollnum').val();
            var admission = $('#admission').val();
            var fullname = $('#fullname').val();
            var Father_Name = $('#Father_Name').val();
            var Guard_Name = $('#Guard_Name').val();
            var Cust_Address = $('#Cust_Address').val();
            var StdCntct_No = $('#StdCntct_No').val();
            var Fcntc_No = $('#Fcntc_No').val();
            var Per_Address = $('#Per_Address').val();
            var EmailAdrr = $('#EmailAdrr').val();
            var txt_Date = $('#txt_Date').val();

            var txtadmDate = $('#txtadmDate').val();

            var St_CNIC = $('#St_CNIC').val();
            var Bld_group = $('#Bld_group').val();
            var Domicile = $('#Domicile').val();
            var Ft_CNIC = $('#Ft_CNIC').val();
            var txtDisease_alergy = $('#txtDisease_alergy').val();
            var Std_Status = $('#Std_Status').val();
            var ddlProgram = $('#ddlProgram').val();
            var ddlBatch = $('#ddlBatch').val();
            var ddlGroup = $('#ddlGroup').val();
            var txt_WholeClass = $('#txt_WholeClass').prop("checked");
            var ddlClass = $('#ddlClass').val();
            var txtSession = $('#txtSession').val();
            var Gl_code = $('#ddlGlAccount').val();
            var Is_Active = $('#Is_Active').prop("checked");
            var newSelect = $('#nslct').val();

            var hdfAccount_ID = $('#hdfAccount_ID').val();
            var hdfParent_Code = $('#hdfParent_Code').val();
            var hdfAccount_Serial = $('#hdfAccount_Serial').val();
            var hdfLevel = $('#hdfLevel').val();
            var hdfAccount_Code = $('#hdfAccount_Code').val();
         
            debugger;

            if (newSelect == "0" && fullname == "") {

                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Enter FullName',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                $('#btnSave').attr('disabled', false);
                return;
            }
            if (newSelect == "0" && Rollnum == "") { 
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Enter RollNumber',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                $('#btnSave').attr('disabled', false);
                return;
            }


            if (newSelect == "0" && ddlProgram == "0") {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Select Program',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                $('#btnSave').attr('disabled', false);
                return;
            }
            if (newSelect == "0" && StdCntct_No == "+92 ___ _______") {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Enter Contact Number',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                $('#btnSave').attr('disabled', false);
                return;
            }

            if (newSelect == "0" && ddlClass == "0") {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Select Class',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                $('#btnSave').attr('disabled', false);
                return;
            }

            var AllRecords = { 'Student_Id': Student_Id, 'Rollnum': Rollnum, 'admission': admission, 'fullname': fullname, 'Father_Name': Father_Name, 'Guard_Name': Guard_Name, 'Cust_Address': Cust_Address, 'StdCntct_No': StdCntct_No, 'Fcntc_No': Fcntc_No, 'Per_Address': Per_Address, 'EmailAdrr': EmailAdrr, 'txt_Date': txt_Date, 'txtadmDate': txtadmDate, 'St_CNIC': St_CNIC, 'Bld_group': Bld_group, 'Domicile': Domicile, 'Ft_CNIC': Ft_CNIC, 'txtDisease_alergy': txtDisease_alergy, 'Std_Status': Std_Status, 'ddlProgram': ddlProgram, 'ddlBatch': ddlBatch, 'ddlGroup': ddlGroup, 'txt_WholeClass': txt_WholeClass, 'ddlClass': ddlClass, 'txtSession': txtSession, 'Gl_code': Gl_code, 'Is_Active': Is_Active, 'hdfAccount_ID': hdfAccount_ID, 'hdfParent_Code': hdfParent_Code, 'hdfAccount_Serial': hdfAccount_Serial, 'hdfLevel': hdfLevel, 'hdfAccount_Code': hdfAccount_Code };
            
            PageMethods.SaveStudentData(btnsave, JSON.stringify(AllRecords), function (res) {
                debugger;
               
                sendFile(res);

                Swal.fire({
                    icon: 'success',
                    title: 'Success!',
                    text: 'Data Save Successfully',
                    showConfirmButton: false,
                    timer: 2500,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });
               
                window.location = "StudentsList.aspx"
                
            });
        }
    


        function Print() {
            var Student_Id = '<%= Request.QueryString["ID"]%>'

            window.open('ReportViewer.aspx?ReportName=StudentReport&ReportTitle=StudentReport' + '&StudentId=' + Student_Id );


        }
    </script>

</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server" enctype="multipart/form-data">
  <form id="apply-form">
  
        <div class="row">
            <div class="col-lg-8 col-md-12 col-sm-12 card">
                <!-- Row 1 -->
                <div class="row" id="row1">
                    <div class="col-lg-4 col-md-4 col-sm-12">
                        <label>Roll No <span style="color:red;">*</span></label>
                    </div>
                    <div class="col-lg-4 col-md-4 col-sm-12">
                        <label>Admission</label>
                    </div>
                    <div class="col-lg-4 col-md-4 col-sm-12">
                        <label>FullName <span style="color:red;">*</span></label>
                    </div>
                </div>

                <!-- Row 2 -->
                <div class="row" id="row2">
                    <div class="col-lg-4 col-md-4 col-sm-12">
                        <input type="text" id="Student_Id" style="display:none;" />
                        <input type="text" id="Rollnum" class="impo fcux" />
                    </div>
                    <div class="col-lg-4 col-md-4 col-sm-12">
                        <input type="text" id="admission" />
                    </div>
                    <div class="col-lg-4 col-md-4 col-sm-12">
                        <input type="text" id="fullname" name="fname" class="impo fcux" />
                    </div>
                </div>

                <!-- Row 3 -->
                <div class="row" id="row3">
                    <div class="col-lg-4 col-md-4 col-sm-12">
                        <label>Father Name</label>
                    </div>
                    <div class="col-lg-4 col-md-4 col-sm-12">
                        <label>Guardian Name</label>
                    </div>
                    <div class="col-lg-4 col-md-4 col-sm-12">
                        <label>Current Address</label>
                    </div>
                </div>

                <!-- Row 4 -->
                <div class="row" id="row4">
                    <div class="col-lg-4 col-md-4 col-sm-12">
                        <input type="text" id="Father_Name" />
                    </div>
                    <div class="col-lg-4 col-md-4 col-sm-12">
                        <input type="text" id="Guard_Name" />
                    </div>
                    <div class="col-lg-4 col-md-4 col-sm-12">
                        <input type="text" id="Cust_Address" />
                    </div>
                </div>

                <!-- Row 5 -->
                <div class="row" id="row5">
                    <div class="col-lg-4 col-md-4 col-sm-12">
                        <label>Student Contact No <span style="color:red;">*</span></label>
                    </div>
                    <div class="col-lg-4 col-md-4 col-sm-12">
                        <label>Father Contact No</label>
                    </div>
                    <div class="col-lg-4 col-md-4 col-sm-12">
                        <label>Permanent Address</label>
                    </div>
                </div>

                <!-- Row 6 -->
                <div class="row" id="row6">
                    <div class="col-lg-4 col-md-4 col-sm-12">
                        <input type="text" id="StdCntct_No" class="impo fcux" />
                    </div>
                    <div class="col-lg-4 col-md-4 col-sm-12">
                        <input type="text" id="Fcntc_No" />
                    </div>
                    <div class="col-lg-4 col-md-4 col-sm-12">
                        <input type="text" id="Per_Address" />
                    </div>
                </div>

                <!-- Row 7 -->
                <div class="row" id="row7">
                    <div class="col-lg-4 col-md-4 col-sm-12">
                        <label>E-mail Address</label>
                    </div>
                    <div class="col-lg-4 col-md-4 col-sm-12">
                        <label>Date Of Birth</label>
                    </div>
                    <div class="col-lg-4 col-md-4 col-sm-12">
                        <label>Student CNIC</label>
                    </div>
                </div>

                <!-- Row 8 -->
                <div class="row" id="row8">
                    <div class="col-lg-4 col-md-4 col-sm-12">
                        <input type="text" id="EmailAdrr" />
                    </div>
                    <div class="col-lg-4 col-md-4 col-sm-12">
                        <input type="text" id="txt_Date" />
                    </div>
                    <div class="col-lg-4 col-md-4 col-sm-12">
                        <input type="text" id="St_CNIC" />
                    </div>
                </div>

                <!-- Row 9 -->
                <div class="row" id="row9">
                    <div class="col-lg-4 col-md-4 col-sm-12">
                        <label>Blood Group</label>
                    </div>
                    <div class="col-lg-4 col-md-4 col-sm-12">
                        <label>Domicile</label>
                    </div>
                    <div class="col-lg-4 col-md-4 col-sm-12">
                        <label>Father CNIC</label>
                    </div>
                </div>

                <!-- Row 10 -->
                <div class="row" id="row10">
                    <div class="col-lg-4 col-md-4 col-sm-12">
                        <select id="Bld_group"></select>
                    </div>
                    <div class="col-lg-4 col-md-4 col-sm-12">
                        <input type="text" id="Domicile" />
                    </div>
                    <div class="col-lg-4 col-md-4 col-sm-12">
                        <input type="text" id="Ft_CNIC" />
                    </div>
                </div>

                <!-- Row 11 -->
                <div class="row" id="row11">
                    <div class="col-lg-4 col-md-4 col-sm-12">
                        <label>Chronic Disease Allergy</label>
                    </div>
                    <div class="col-lg-4 col-md-4 col-sm-12">
                        <label>Studies Status</label>
                    </div>
                    <div class="col-lg-4 col-md-4 col-sm-12">
                        <label>Program <span style="color:red;">*</span></label>
                    </div>
                </div>

                <!-- Row 12 -->
                <div class="row" id="row12">
                    <div class="col-lg-4 col-md-4 col-sm-12">
                        <input type="text" id="txtDisease_alergy" />
                    </div>
                    <div class="col-lg-4 col-md-4 col-sm-12">
                        <select id="Std_Status" disabled ></select>
                        <input type="hidden" value="0" id="nslct" />
                    </div>
                    <div class="col-lg-4 col-md-4 col-sm-12">
                        <select id="ddlProgram" onchange="Selectfunc()" class="impo fcux"></select>
                    </div>
                </div>

                <!-- Row 13 -->
               <div class="row" id="row13">
                    <div class="col-lg-2 col-md-2 col-sm-4">
                        <label>Batch</label>
                    </div>
                    <div class="col-lg-2 col-md-3 col-sm-8">
                        <label>Group</label>
                    </div>
                    <div class="col-lg-2 col-md-2 col-sm-4">
                        <label style="font-size: 12px;">W.H Class</label> <!-- Updated this column -->
                    </div>
                    <div class="col-lg-2 col-md-3 col-sm-8">
                        <label>Class <span style="color:red;">*</span></label>
                    </div>
                    <div class="col-lg-2 col-md-2 col-sm-4">
                        <label>Session</label>
                    </div>
                </div>
                <div class="row" id="row14">
                    <div class="col-lg-2 col-md-2 col-sm-4">
                        <select id="ddlBatch"></select>
                    </div>
                    <div class="col-lg-2 col-md-3 col-sm-8">
                        <select id="ddlGroup"></select>
                    </div>
                    <div class="col-lg-1 col-md-2 col-sm-4">
                        <input type="checkbox" id="txt_WholeClass" />
                    </div>
                      <div class="col-lg-1 col-md-2 col-sm-4"></div>
                    <div class="col-lg-2 col-md-3 col-sm-8">
                        <select id="ddlClass" class="impo fcux"></select>
                    </div>
                    <div class="col-lg-4 col-md-2 col-sm-4">
                        <input type="text" id="txtSession" />
                    </div>
                </div>
                 <div class="row" id="row16">
                    <div class="col-lg-2 col-md-2 col-sm-4">
                        <label>GL</label>
                    </div>
                   
                </div>
                <div class="row">
                    <div class="col-lg-4 col-md-2 col-sm-4">
                        <%--<select id="ddlGlAccount"></select>--%>
                         <input type="text" id="txtAccount_Code_Name" name="txtAccount_Code_Name" readonly />
                        <input type="hidden" id="hdfAccount_Name" name="hdfAccount_Name" />
                        <input type="hidden" id="hdfAccount_Code" name="hdfAccount_Code" />
                        <input type="hidden" id="hdfParent_Code" name="hdfParent_Code" />
                        <input type="hidden" id="hdfAccount_Serial" name="hdfAccount_Serial" />
                        <input type="hidden" id="hdfLevel" name="hdfLevel" />
                        <input type="hidden" id="hdfAccount_ID" name="hdfAccount_ID" />
                        <input type="hidden" id="hdfAccountExists" name="hdfAccountExists" />
                    </div>
                </div>
            </div>
              <div class="col-lg-1 col-md-1 col-sm-12"></div>
               <div class="col-lg-3 col-md-3 col-sm-12 card">

                         <div class="row">
                              <div class="col-lg-1 col-md-1 col-sm-12" style="margin-left: 70px;">
                            <label style="margin-left: -9px;">AdmissionDate</label>
                                  </div>
                             <div class="col-lg-8 col-md-8 col-sm-12" style="margin-left: 60px;">
                                 <input type="text" id="txtadmDate"/>
                             </div>
                            <div class="profile-images-card">
                                <div class="profile-images">
                                    <img src="~../../../../wwwroot/THEME_TIBBIT/images/\HMIS_Icons/dummy.jpg" id="upload-img">
                                </div>
                                <div class="custom-file">                             
                                    <input type="file" id="fileupload" />
                                    <label id="image-holder"></label>
                             
                                </div>
                            </div>
                        </div>
                       <div style="margin-left: 41px !important; display: flex; align-items: center;">
                            <label for="Is_Active" style="margin-right: 10px;">IsActive</label>
                            <input type="checkbox" id="Is_Active" />
                        </div>

              
            </div>


        </div>
    
         <div class="row mtop">
              <div class =" col-lg-8">
                  <div class="row">
                   <div class="col-lg-2 col-md-1 col-sm-3">
                        <input type="button" class="btn-primry"  onclick="SaveStudent()"  id="btnSave"" value="Save"  />
                   </div> 
             <div class="col-lg-2 col-md-1 col-sm-3">
                  <input type="button" onclick="listopen()" class="btn btn-gray" id="List"" value="ListView"  />
                   </div>   
             <div class="col-lg-2 col-md-1 col-sm-3">
                      <input type="button" onclick="FormOpen()" class="btn btn-yellow" id="NewForm"  value="New" />
                   </div>  
             <div class="col-lg-2 col-md-1 col-sm-3">
                        <input type="button" class="btn-primry" value="Print" name="name" onclick="Print();" />
                   </div>
                </div> 
             </div>
            </div>
</form>

              
</asp:Content>



