<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Student.aspx.cs" Inherits="PMS.Modules.StudentAffair.Student" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

    <script type="text/javascript">
        $(document).ready(function () {


            var date = '<%= DateTime.Now%>';
            $("#txt_Date").datepicker({ dateFormat: 'mm/dd/yy' }).attr('readonly', 'readonly');
            date = moment(date).format('L');
            $("#txt_Date").val(date);



            GetSessions();
            $('#ddl_session').select2();

        <% if (Request.QueryString["Stu_ID"] != null)
        { %>
            var Stu_ID = '<%= Request.QueryString["Stu_ID"]%>'
            LoadStudentData(Stu_ID);

            <% } %>


             var studentid = '<%= Request.QueryString["Stu_ID"]%>'
            if (studentid == '') {

                Getnewstudentcode();
            }


           loadtokenInputsByAccount_ID();
            GetAdmissionCategories();
            $('#ddladmsn_category').select2();

        });

        function httpGet(theUrl) {
            var xmlHttp = null;
            xmlHttp = new XMLHttpRequest();
            xmlHttp.open("GET", theUrl, false);
            xmlHttp.send(null);
            return xmlHttp.responseText;
        }


        function GetSessions() {
            var optionsDepth = '';

            PageMethods.GetSession(function (Tests) {
                optionsDepth = '<option value="0">Please Select</option>';

                $.each(JSON.parse(Tests), function (key, value) {

                    optionsDepth += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                });
                $('#ddl_session').html(optionsDepth);
            });
        }




        function LoadStudentData(Stu_ID) {
            PageMethods.LoadStudentData(Stu_ID, function (resp) {
                var studata = JSON.parse(resp);
                $('#savebtn').val('Update');

                var stDate = '';

                if (studata.Date != null) {

                    stDate = new Date(parseInt(studata.Date.substr(6)));
                    stDate = moment(stDate).format('L');
                }
   
                $('#txt_Date').val(stDate);
                $('#txt_StudentCode').val(studata.Student_Code);
                $('#txt_studentname').val(studata.Student_Name);
                $('#txt_rollno').val(studata.Roll_No);
                $('#txt_fname').val(studata.Father_Name);
                $('#txt_phone').val(studata.Phone);
                $('#txt_email').val(studata.Email);
                $('#txt_totalfee').val(studata.Total_Fee);
                $('#txt_address').val(studata.Address);
                $('#hdAccountid').val(studata.Account_ID);
                $('#txt_glaccount').tokenInput('clear');

                setTimeout(function () {  
                    $('#ddladmsn_category').val(studata.Admission_Category).trigger('change');
                }, 1000);



                setTimeout(function () {

                    $('#ddl_session').val(studata.Session).trigger('change');


                }, 1000);


                var tokendata = httpGet("json.aspx?Table=Account&Account_ID=" + studata.Account_ID);

                $('#txt_glaccount').tokenInput("add", { id: JSON.parse(tokendata)[0].id, name: JSON.parse(tokendata)[0].name });

            })
        }


        function loadtokenInputsByAccount_ID() {
            var tokendata;
            try {
                $("#txt_glaccount").tokenInput("json.aspx",
                   {
                       tokenLimit: 1,
                       onAdd: function (item) {
                           try {

                               var account_id = item.id;
                               $("#hdAccountid").val(account_id);
                           } catch (exp) {
                               alert(exp.message);
                           }
                       },
                   });


            } catch (e) {
                alert(e.message);
            }
        }



   

        function GetAdmissionCategories() {
            var optionsDepth = '';

            PageMethods.GetAdmisionCategory(function (Tests) {
                optionsDepth = '<option value="0">Please Select</option>';

                $.each(JSON.parse(Tests), function (key, value) {

                    optionsDepth += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                });
                $('#ddladmsn_category').html(optionsDepth);
            });
        }
       
        function Getnewstudentcode() {
            PageMethods.Getnewstudentno(function (resp) {
                $('#txt_StudentCode').val(resp);
            },
            function (error) {
                alert(error.get_message());
            })
        }



        function SaveAllRecord() {
            var status;
            var btnSave = $('#savebtn').val();
            var txt_StudentCode = $('#txt_StudentCode').val();
            var txt_studentname = $('#txt_studentname').val();
            var txt_rollno = $('#txt_rollno').val();
            var txt_fname = $('#txt_fname').val();
            var txt_phone = $('#txt_phone').val();
            var txt_email = $('#txt_email').val();
        
            var ddladmsn_category = $('#ddladmsn_category').val();
            var ddl_session = $('#ddl_session').val();

            var txt_totalfee = $('#txt_totalfee').val();
            var txt_glaccount = $('#hdAccountid').val();


            var txt_address = $('#txt_address').val();


            var txt_Date = $('#txt_Date').val();

            $('#btnSave').attr('disabled', true);
            var AllItemDetail = { 'txt_StudentCode': txt_StudentCode, 'txt_Date': txt_Date, 'txt_studentname': txt_studentname, 'txt_rollno': txt_rollno, 'txt_fname': txt_fname, 'txt_phone': txt_phone, 'txt_email': txt_email, 'ddladmsn_category': ddladmsn_category, 'txt_address': txt_address, 'ddl_session': ddl_session, 'txt_glaccount': txt_glaccount };



            PageMethods.SaveInvoice(btnSave, JSON.stringify(AllItemDetail), function (res) {
                alert('Data Save Successfully');
                window.location = "Student.aspx?Stu_ID=" + res;
                $('#savebtn').val("Update");


            });


        }




    </script>


</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
        <div class="outer_div_for_new_form">
        <div class="container">
            <div class="col-md-4 col-lg-4">
                <label id="lbl_studentcode">Student Code</label>
                <input type="text" id="txt_StudentCode" name="txt_StudentCode" readonly="readonly" />
            </div>
            <div class="col-md-4 col-lg-4">
                <label id="lbl_stuname">Student Name</label>
                <input type="text" id="txt_studentname" name="txt_studentname" style="margin-left: 33px;" /> 
            </div>
             <div class="col-md-4 col-lg-4">
                <label id="lbl_fname">Father Name</label>
                <input type="text" id="txt_fname" name="txt_fname" />
            </div>

            <div class="col-md-4 col-lg-4">
                <label id="lbl_student_rollno">Student Roll No</label>
                <input type="text" id="txt_rollno" name="txt_rollno"  /> 
            </div>
            <div class="col-md-4 col-lg-4">
                <label id="lbl_phone">Phone</label>
                <input type="text" id="txt_phone" name="txt_phone" style="
   margin-left: 83px;
"/> 
            </div>
            <div class="col-md-4 col-lg-4">
                <label id="lbl_email">Email</label>
                <input type="text" id="txt_email" name="txt_email" style="
   margin-left: 64px;
" /> 
            </div>


                        <div class="col-md-4 col-lg-4">
                <label id="lbl_admsnCategory">Admission Category</label>
                <select id="ddladmsn_category" name="ddladmsn_category"></select>

            </div>

                        <div class="col-md-4 col-lg-4">
                <label id="lbl_session">Student Session <span style="color:red;">*</span></label>
                <select id="ddl_session" name="ddl_session"></select>
            </div>

            <div class="col-md-4 col-lg-4">
                <label id="lbl_glaccount">GL Account</label>
                <input type="text" id="txt_glaccount" name="txt_glaccount" />
               <input type="hidden" id="hdAccountid" name="hdAccountid"/>

            </div>

            <div class="col-md-4 col-lg-4">
                <label id="lbl_address" style="position: relative;top: -38px;}">Address</label>
 <textarea cols="4" rows="1" style="width: 172px;height: 61px;margin-left: 73px;" id="txt_address" name="txt_address"></textarea> 
            </div>

            <div class="col-md-4 col-lg-4">
                <label id="lbl_Date" style="position: relative;top: -38px;}">Date</label>
                <input type="text" id="txt_Date" name="txt_Date" style="margin-left: 83px;"/> 
            </div>

            <div class="col-md-12 col-lg-12">
                <a   href="StudentList.aspx">  <input type="button" value="View List"  id="btnList" /> </a>
                <a   href="Student.aspx">  <input type="button" value="New"  id="btnNew" /> </a>

                <input type="button" id="savebtn" name="savebtn" value="Save" onclick="SaveAllRecord()" />
            </div>
        </div>
    </div>
</asp:Content>
