<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AddStudentChallan.aspx.cs" Inherits="PMS.Modules.StudentAffair.AddStudentChallan" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

    <script type="text/javascript">


        $(document).ready(function () {

            $('#btnChallan').hide();


            var checkeditmode = '<%= Request.QueryString["Challan_ID"]%>'


        if (checkeditmode == '') {



            $('#btnChallan').hide();

            GetHiddenChallanNo();
            GetNewChallanNo();

        }

        GetStudentRollNo();





        $("#txt_issueDate").datepicker({ dateFormat: 'mm/dd/yy' });
        $("#txt_issueDate").val($.datepicker.formatDate('mm/dd/yy', new Date()));

        $("#txt_dueDate").datepicker({ dateFormat: 'mm/dd/yy' });
        $("#txt_dueDate").val($.datepicker.formatDate('mm/dd/yy', new Date()));

        $('select').select2();



                    <% if (Request.QueryString["Challan_ID"] != null)
        { %>
        var CH_ID = '<%= Request.QueryString["Challan_ID"]%>'

        $('#btnChallan').show();

        LoadStudentChallan(CH_ID);
            <% } %>


        var CH_ID = '<%= Request.QueryString["Challan_ID"]%>'




    });


        var checkedstudent = false;


        function checkstudentexist() {


            checkedstudent = false;

            var Student_ID = $('#ddl_rollno').val();
            if (Student_ID == 0) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Select Roll No Before Save',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });


                return false;
            }




            PageMethods.CheckStudentExist(Student_ID, function (res) {

                if (parseInt(res) <= 0) {

                    checkedstudent = true;
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'First create receviable against that student',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });


                    checkedstudent = true;
                    SaveAllRecord();


                }

                else {

                    //   SaveAllRecord();
                    checktotalamount_Receivable();

                }


            });


        }


        function checktotalamount_Receivable() {


            var Student_ID = $('#ddl_rollno').val();
            if (Student_ID == 0) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Select Roll No Before Save',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                return false;
            }

            var Admission_Fee1 = $('#Admission_Fee').val();
            var Tuition_Fee1 = $('#Tuition_Fee').val();
            var Library_Magazine_Fund1 = $('#Library_Magazine_Fund').val();
            var Reg_Fee1 = $('#Reg_Fee').val();
            var Degree_Fee1 = $('#Degree_Fee').val();
            var Security_Fee1 = $('#Security_Fee').val();
            var Hostel_Fee1 = $('#Hostel_Fee').val();
            var Examination_Fee1 = $('#Examination_Fee').val();
            var Remaining_Tuition_Fee1 = $('#Remaining_Tuition_Fee').val();
            var Other_Fee1 = $('#Other_Fee').val();
            var Student_Card_Fee1 = $('#Student_Card_Fee').val();
            var Remaining_Hostel_Fee1 = $('#Remaining_Hostel_Fee').val();
            var Prospectus_Fee1 = $('#Prospectus_Fee').val();
            var Test_Fee1 = $('#Test_Fee').val();
            var Misc_Fee1 = $('#Misc_Fee').val();

            var totalamount = 0;


            if (Test_Fee1 == "") {

                Test_Fee1 = 0;
            }
            if (Misc_Fee1 == "") {

                Misc_Fee1 = 0;
            }
            if (Admission_Fee1 == "") {

                Admission_Fee1 = 0;
            }
            if (Tuition_Fee1 == "") {

                Tuition_Fee1 = 0;
            }
            if (Library_Magazine_Fund1 == "") {

                Library_Magazine_Fund1 = 0;
            }
            if (Reg_Fee1 == "") {

                Reg_Fee1 = 0;
            }
            if (Degree_Fee1 == "") {

                Degree_Fee1 = 0;
            }
            if (Security_Fee1 == "") {

                Security_Fee1 = 0;
            }
            if (Hostel_Fee1 == "") {

                Hostel_Fee1 = 0;
            }
            if (Examination_Fee1 == "") {

                Examination_Fee1 = 0;
            }
            if (Remaining_Tuition_Fee1 == "") {

                Remaining_Tuition_Fee1 = 0;
            }
            if (Other_Fee1 == "") {

                Other_Fee1 = 0;
            }
            if (Student_Card_Fee1 == "") {

                Student_Card_Fee1 = 0;
            }
            if (Remaining_Hostel_Fee1 == "") {

                Remaining_Hostel_Fee1 = 0;
            }
            if (Prospectus_Fee1 == "") {

                Prospectus_Fee1 = 0;
            }



            totalamount = parseFloat(Admission_Fee1) + parseFloat(Tuition_Fee1) + parseFloat(Library_Magazine_Fund1) + parseFloat(Reg_Fee1) + parseFloat(Degree_Fee1) + parseFloat(Security_Fee1) + parseFloat(Hostel_Fee1) + parseFloat(Examination_Fee1) + parseFloat(Remaining_Tuition_Fee1) + parseFloat(Other_Fee1) + parseFloat(Student_Card_Fee1) + parseFloat(Remaining_Hostel_Fee1) + parseFloat(Test_Fee1) + parseFloat(Misc_Fee1) + parseFloat(Prospectus_Fee1);


            PageMethods.checkrecvablefee(Student_ID, function (res) {

                if (parseInt(totalamount) > parseFloat(res)) {

                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Challan amount cannot be greater than receivable amount' + res,
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });


                   // alert('Challan amount cannot be greater than receivable amount ' + res);

                    checkedstudent = true;
                    SaveAllRecord();

                }

                else {

                    SaveAllRecord();
                }


            });
        }






        function SaveAllRecord() {



            if (checkedstudent == true) {

                return false;
            }

            var Student_ID = $('#ddl_rollno').val();
            if (Student_ID == 0) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Select Roll No Before Save',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                return false;
            }




            var btnsave = $('#btn_Save').val();
            var txt_issueDate = $('#txt_issueDate').val();
            var txt_dueDate = $('#txt_dueDate').val();
            var txt_challanNo = $('#txt_challanNo').val();

            var txthiddenchallanno = $('#txt_hiddenChallanNo').val();

            var Admission_Fee = $('#Admission_Fee').val();
            var Tuition_Fee = $('#Tuition_Fee').val();
            var Library_Magazine_Fund = $('#Library_Magazine_Fund').val();
            var Reg_Fee = $('#Reg_Fee').val();
            var Degree_Fee = $('#Degree_Fee').val();
            var Security_Fee = $('#Security_Fee').val();
            var Hostel_Fee = $('#Hostel_Fee').val();
            var Examination_Fee = $('#Examination_Fee').val();
            var Remaining_Tuition_Fee = $('#Remaining_Tuition_Fee').val();
            var Other_Fee = $('#Other_Fee').val();
            var Student_Card_Fee = $('#Student_Card_Fee').val();
            var Remaining_Hostel_Fee = $('#Remaining_Hostel_Fee').val();
            var Prospectus_Fee = $('#Prospectus_Fee').val();
            var Test_Fee = $('#Test_Fee').val();
            var Misc_Fee = $('#Misc_Fee').val();



            var Challan_ID = '<% =Request.QueryString["Challan_ID"] %>';


            var AllItemDetail = { 'Student_ID': Student_ID, 'txthiddenchallanno': txthiddenchallanno, 'Challan_ID': Challan_ID, 'txt_issueDate': txt_issueDate, 'txt_dueDate': txt_dueDate, 'txt_challanNo': txt_challanNo, 'Admission_Fee': Admission_Fee, 'Tuition_Fee': Tuition_Fee, 'Library_Magazine_Fund': Library_Magazine_Fund, 'Reg_Fee': Reg_Fee, 'Degree_Fee': Degree_Fee, 'Security_Fee': Security_Fee, 'Hostel_Fee': Hostel_Fee, 'Examination_Fee': Examination_Fee, 'Remaining_Tuition_Fee': Remaining_Tuition_Fee, 'Other_Fee': Other_Fee, 'Student_Card_Fee': Student_Card_Fee, 'Remaining_Hostel_Fee': Remaining_Hostel_Fee, 'Prospectus_Fee': Prospectus_Fee, 'Test_Fee': Test_Fee, 'Misc_Fee': Misc_Fee };
            PageMethods.SaveChallanAmount(btnsave, JSON.stringify(AllItemDetail), function (res) {

                Swal.fire({
                    icon: 'success',
                    title: 'Success!',
                    text: 'Challan Amounts Saved Successfully',
                    showConfirmButton: false,
                    timer: 2500,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                window.location = "AddStudentChallan.aspx?Challan_ID=" + res;


            });



        }


        function PrintChallan() {
            var id = '<%= Request.QueryString["Challan_ID"]%>';
            var locationInfo = window.location;
            var url = '/ReportViewer.aspx?ReportName=ChallanPrint&ReportTitle=Student Challan Print&TransID=' + id + '';
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + '/ReportViewer.aspx?ReportName=ChallanPrint&ReportTitle=Student Challan Print&TransID=' + id + '';
            }
            window.open(url, '_blank');
        }


        function LoadStudentChallan(ChallanID) {

            $('#btn_Save').val("Update");


            PageMethods.LoadChallan(ChallanID, function (resp) {
                var data = JSON.parse(resp);
                var DueDatesss = new Date(parseInt(data.DueDate.substr(6)));
                DueDatesss = moment(DueDatesss).format('L');


                var IssueDatess = new Date(parseInt(data.IssueDate.substr(6)));
                IssueDatess = moment(IssueDatess).format('L');


                setTimeout(function () {

                    $('#ddl_rollno').val(data.Student_ID).trigger('change');
                }, 1000);




                $('#txt_issueDate').val(IssueDatess);
                $('#txt_dueDate').val(DueDatesss);
                $('#txt_challanNo').val(data.Seq_Challan_No);
                $('#txt_hiddenChallanNo').val(data.Challan_No);

                $('#Admission_Fee').val(data.Admission_Fee);
                $('#Tuition_Fee').val(data.Tuition_Fee);
                $('#Library_Magazine_Fund').val(data.Library_Magazine_Fund);
                $('#Reg_Fee').val(data.Reg_Fee);
                $('#Degree_Fee').val(data.Degree_Fee);
                $('#Security_Fee').val(data.Security_Fee);
                $('#Hostel_Fee').val(data.Hostel_Fee);
                $('#Examination_Fee').val(data.Examination_Fee);
                $('#Remaining_Tuition_Fee').val(data.Remaining_Tuition_Fee);
                $('#Other_Fee').val(data.Other_Fee);
                $('#Student_Card_Fee').val(data.Student_Card_Fee);
                $('#Remaining_Hostel_Fee').val(data.Remaining_Hostel_Fee);
                $('#Prospectus_Fee').val(data.Prospectus_Fee);
                $('#Test_Fee').val(data.Test_Fee);
                $('#Misc_Fee').val(data.Misc_Fee);





            },
                function (error) {
                    alert(error.get_message());
                })
        }




        function redirecttolist() {


            window.location.href = "StudentChallanView.aspx";

        }



        function redirecttonew() {


            window.location.href = "AddStudentChallan.aspx";

        }


        function GetNewChallanNo() {
            PageMethods.NewChallanNo(function (resp) {
                $('#txt_challanNo').val(resp);
            },
                function (error) {
                    alert(error.get_message());
                })
        }



        function GetStudentRollNo() {

            var optionsVen = '<option value="0">Please Select</option>';

            PageMethods.GetStudentRollNos(function (Tests) {

                $.each(JSON.parse(Tests), function (key, value) {
                    optionsVen += '<option value="' + value.Student_Id + '" >' + value.Roll_No + '</option>';
                });
                $('#ddl_rollno').html(optionsVen);
            });
        }



        function GetHiddenChallanNo() {
            PageMethods.GetHiddenChallanNos(function (resp) {
                $('#txt_hiddenChallanNo').val(resp);
            },
                function (error) {
                    alert(error.get_message());
                })
        }





    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
        <div class="col-lg-3 col-md-3 col-sm-6">
            <label id="lbl_ChallanNo">Challan No</label>
            <input type="text" id="txt_challanNo" name="txt_challanNo" readonly="readonly" />
            <input type="hidden" id="txt_hiddenChallanNo" name="txt_hiddenChallanNo" />
        </div>
        <div class="col-lg-3 col-md-3 col-sm-6">
            <label id="lbl_student_rollno">Student Roll No <span style="color: red;">*</span></label>
            <select id="ddl_rollno" name="ddl_rollno"></select>
        </div>
        <div class="col-lg-3 col-md-3 col-sm-6">
            <label id="lbl_issueDate">Issue Date</label>
            <input type="text" id="txt_issueDate" name="txt_issueDate" readonly="readonly" />
        </div>
        <div class="col-lg-3 col-md-3 col-sm-6">
            <label id="lbl_dueDate">Due Date</label>
            <input type="text" id="txt_dueDate" name="txt_dueDate" readonly="readonly" />

        </div>
    </div>
    <div class="row">
        <div class="col-lg-3 col-md-3 col-sm-6">
            <label>Admission_Fee </label>
            <input type="text" id="Admission_Fee" name="Admission_Fee" />
        </div>
        <div class="col-lg-3 col-md-3 col-sm-6">
            <label>Tuition_Fee </label>
            <input type="text" id="Tuition_Fee" name="Tuition_Fee" />
        </div>
        <div class="col-lg-3 col-md-3 col-sm-6">
            <label>Misc_Fee </label>
            <input type="text" id="Misc_Fee" name="Misc_Fee" />
        </div>
        <div class="col-lg-3 col-md-3 col-sm-6">
            <label>Library_Magazine_Fund </label>
            <input type="text" id="Library_Magazine_Fund" name="Library_Magazine_Fund" />
        </div>

    </div>
    <div class="row">
        <div class="col-lg-3 col-md-3 col-sm-6">
            <label>Reg_Fee </label>
            <input type="text" id="Reg_Fee" name="Reg_Fee" />
        </div>
        <div class="col-lg-3 col-md-3 col-sm-6">
            <label>Degree_Fee </label>
            <input type="text" id="Degree_Fee" name="Degree_Fee" />
        </div>
        <div class="col-lg-3 col-md-3 col-sm-6">
            <label>Security_Fee </label>
            <input type="text" id="Security_Fee" name="Security_Fee" />
        </div>
        <div class="col-lg-3 col-md-3 col-sm-6">
            <label>Hostel_Fee </label>
            <input type="text" id="Hostel_Fee" name="Hostel_Fee" />

        </div>
    </div>
    <div class="row">
        <div class="col-lg-3 col-md-3 col-sm-6">
            <label>Examination_Fee </label>
            <input type="text" id="Examination_Fee" name="Examination_Fee" />
        </div>
        <div class="col-lg-3 col-md-3 col-sm-6">
            <label>Remaining_Tuition_Fee </label>
            <input type="text" id="Remaining_Tuition_Fee" name="Remaining_Tuition_Fee" />
        </div>
        <div class="col-lg-3 col-md-3 col-sm-6">
            <label>Other_Fee </label>
            <input type="text" id="Other_Fee" name="Other_Fee" />
        </div>
        <div class="col-lg-3 col-md-3 col-sm-6">
            <label>Student_Card_Fee </label>
            <input type="text" id="Student_Card_Fee" name="Student_Card_Fee" />


        </div>
    </div>
    <div class="row">
        <div class="col-lg-3 col-md-3 col-sm-6">
            <label>Tax Charges </label>
            <input type="text" id="Remaining_Hostel_Fee" name="Remaining_Hostel_Fee" />
        </div>
        <div class="col-lg-3 col-md-3 col-sm-6">
            <label>Prospectus_Fee </label>
            <input type="text" id="Prospectus_Fee" name="Prospectus_Fee" />
        </div>
        <div class="col-lg-3 col-md-3 col-sm-6">
            <label>Test_Fee </label>
            <input type="text" id="Test_Fee" name="Test_Fee" />

        </div>

    </div>
    <div class="row" style="margin-top: 15px;">
        <div class="col-lg-8 col-md-8 col-sm-8">
            <div class="col-lg-2 col-md-2 col-sm-3">
                <input type="button" name="btn_Save" id="btn_Save" class="btn btn-primry" value="Save" onclick="checkstudentexist()" />
            </div>
            <div class="col-lg-2 col-md-2 col-sm-3">
                <input type="button" name="btnNew" id="btnNew" value="New" class="btn btn-yellow" onclick="redirecttonew()" />
            </div>
            <div class="col-lg-2 col-md-2 col-sm-3">
                <input type="button" name="btnlist" id="btnlist" value="View List" class="btn btn-gray" onclick="redirecttolist()" />
            </div>
            <div class="col-lg-2 col-md-2 col-sm-3">
                <input type="button" style="width: 93px" value="Print Challan" class="btn btn-primry" id="btnChallan" onclick="PrintChallan()" />
            </div>
        </div>
    </div>
</asp:Content>
