<%@ Page EnableSessionState="ReadOnly" Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="SurveyForm.aspx.cs" Inherits="PMS.Modules.Administrator.SurveyForm" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script type="text/javascript">
        $(document).ready(function () {
            var Stu_ID = '<%= Request.QueryString["Stu_ID"]%>'
            console.log(Stu_ID)
            if (Stu_ID != null) {
                LoadSurveyDatas(Stu_ID);
            }
        GetPatientNo();
        $('#ddlpat_no').select2();
    });


        function GetPatientNo() {
            var Getpat = '';
            $.ajax({
                url: 'SurveyForm.aspx/Getpat_no',
                type: 'post',
                contentType: 'application/json;charset=utf-8',
                dataType: 'json',
                success: function (data) {
                    Getpat = '<option value="0">Please Select</option>';
                    $.each(JSON.parse(data.d), function (key, value) {

                        Getpat += '<option value="' + value.pat_id + '" >' + value.pat_no + '</option>';
                    });
                    $('#ddlpat_no').html(Getpat);

                },
            });
        }
        function GetPatientNameByMR() {
            var pat_id = $('#ddlpat_no').val();
            PageMethods.getname(pat_id, function (Tests) {
                var data = JSON.parse(Tests);
                $('#txtname').val(data.Full_Name);
                $('#txtname').attr('disabled', true)

            });
        }


        function SaveFunction() {
            var Survey_Id = $('#Survey_Id').val();
            Survey_Id = '<%= Request.QueryString["ID"]%>'

            if (Survey_Id == '' || Survey_Id == "" || Survey_Id == null || Survey_Id == "null") {
                Survey_Id = 0;
            }

            var btnSave = $('#btnSave').val();
            var CHKQ_1_1 = $('#CHKQ_1_1').prop("checked");
            var CHKQ_1_2 = $('#CHKQ_1_2').prop("checked");
            var CHKQ_1_3 = $('#CHKQ_1_3').prop("checked");
            var CHKQ_1_4 = $('#CHKQ_1_4').prop("checked");
            var CHKQ_1_5 = $('#CHKQ_1_5').prop("checked");
            var CHKQ_2_1 = $('#CHKQ_2_1').prop("checked");
            var CHKQ_2_2 = $('#CHKQ_2_2').prop("checked");
            var CHKQ_2_3 = $('#CHKQ_2_3').prop("checked");
            var CHKQ_2_4 = $('#CHKQ_2_4').prop("checked");
            var CHKQ_2_5 = $('#CHKQ_2_5').prop("checked");
            var CHKQ_3_1 = $('#CHKQ_3_1').prop("checked");
            var CHKQ_3_2 = $('#CHKQ_3_2').prop("checked");
            var CHKQ_3_3 = $('#CHKQ_3_3').prop("checked");
            var CHKQ_3_4 = $('#CHKQ_3_4').prop("checked");
            var CHKQ_3_5 = $('#CHKQ_3_5').prop("checked");
            var CHKQ_4_1 = $('#CHKQ_4_1').prop("checked");
            var CHKQ_4_2 = $('#CHKQ_4_2').prop("checked");
            var CHKQ_4_3 = $('#CHKQ_4_3').prop("checked");
            var CHKQ_4_4 = $('#CHKQ_4_4').prop("checked");
            var CHKQ_4_5 = $('#CHKQ_4_5').prop("checked");
            var CHKQ_5_1 = $('#CHKQ_5_1').prop("checked");
            var CHKQ_5_2 = $('#CHKQ_5_2').prop("checked");
            var CHKQ_5_3 = $('#CHKQ_5_3').prop("checked");
            var CHKQ_5_4 = $('#CHKQ_5_4').prop("checked");
            var CHKQ_5_5 = $('#CHKQ_5_5').prop("checked");
            var CHKQ_6_1 = $('#CHKQ_6_1').prop("checked");
            var CHKQ_6_2 = $('#CHKQ_6_2').prop("checked");
            var CHKQ_6_3 = $('#CHKQ_6_3').prop("checked");
            var CHKQ_6_4 = $('#CHKQ_6_4').prop("checked");
            var CHKQ_6_5 = $('#CHKQ_6_5').prop("checked");
            var CHKQ_7_1 = $('#CHKQ_7_1').prop("checked");
            var CHKQ_7_2 = $('#CHKQ_7_2').prop("checked");
            var CHKQ_7_3 = $('#CHKQ_7_3').prop("checked");
            var CHKQ_7_4 = $('#CHKQ_7_4').prop("checked");
            var CHKQ_7_5 = $('#CHKQ_7_5').prop("checked");
            var CHKQ_8_1 = $('#CHKQ_8_1').prop("checked");
            var CHKQ_8_2 = $('#CHKQ_8_2').prop("checked");
            var CHKQ_8_3 = $('#CHKQ_8_3').prop("checked");
            var CHKQ_8_4 = $('#CHKQ_8_4').prop("checked");
            var CHKQ_8_5 = $('#CHKQ_8_5').prop("checked");
            var CHKQ_9_1 = $('#CHKQ_9_1').prop("checked");
            var CHKQ_9_2 = $('#CHKQ_9_2').prop("checked");
            var CHKQ_9_3 = $('#CHKQ_9_3').prop("checked");
            var CHKQ_9_4 = $('#CHKQ_9_4').prop("checked");
            var CHKQ_9_5 = $('#CHKQ_9_5').prop("checked");
            var CHKQ_10_1 = $('#CHKQ_10_1').prop("checked");
            var CHKQ_10_2 = $('#CHKQ_10_2').prop("checked");
            var CHKQ_10_3 = $('#CHKQ_10_3').prop("checked");
            var CHKQ_10_4 = $('#CHKQ_10_4').prop("checked");
            var CHKQ_10_5 = $('#CHKQ_10_5').prop("checked");
            var CHKQ_11_1 = $('#CHKQ_11_1').prop("checked");
            var CHKQ_11_2 = $('#CHKQ_11_2').prop("checked");
            var CHKQ_11_3 = $('#CHKQ_11_3').prop("checked");
            var CHKQ_11_4 = $('#CHKQ_11_4').prop("checked");
            var CHKQ_11_5 = $('#CHKQ_11_5').prop("checked");
            var CHKQ_12_1 = $('#CHKQ_12_1').prop("checked");
            var CHKQ_12_2 = $('#CHKQ_12_2').prop("checked");
            var CHKQ_12_3 = $('#CHKQ_12_3').prop("checked");
            var CHKQ_12_4 = $('#CHKQ_12_4').prop("checked");
            var CHKQ_12_5 = $('#CHKQ_12_5').prop("checked");
            var CHKQ_13_1 = $('#CHKQ_13_1').prop("checked");
            var CHKQ_13_2 = $('#CHKQ_13_2').prop("checked");
            var CHKQ_13_3 = $('#CHKQ_13_3').prop("checked");
            var CHKQ_13_4 = $('#CHKQ_13_4').prop("checked");
            var CHKQ_13_5 = $('#CHKQ_13_5').prop("checked");
            var CHKQ_14_1 = $('#CHKQ_14_1').prop("checked");
            var CHKQ_14_2 = $('#CHKQ_14_2').prop("checked");
            var CHKQ_14_3 = $('#CHKQ_14_3').prop("checked");
            var CHKQ_14_4 = $('#CHKQ_14_4').prop("checked");
            var CHKQ_14_5 = $('#CHKQ_14_5').prop("checked");
            var CHKQ_15_1 = $('#CHKQ_15_1').prop("checked");
            var CHKQ_15_2 = $('#CHKQ_15_2').prop("checked");
            var CHKQ_15_3 = $('#CHKQ_15_3').prop("checked");
            var CHKQ_15_4 = $('#CHKQ_15_4').prop("checked");
            var CHKQ_15_5 = $('#CHKQ_15_5').prop("checked");
            var CHKQ_16_1 = $('#CHKQ_16_1').prop("checked");
            var CHKQ_16_2 = $('#CHKQ_16_2').prop("checked");
            var CHKQ_16_3 = $('#CHKQ_16_3').prop("checked");
            var CHKQ_16_4 = $('#CHKQ_16_4').prop("checked");
            var CHKQ_16_5 = $('#CHKQ_16_5').prop("checked");
            var CHKQ_17_1 = $('#CHKQ_17_1').prop("checked");
            var CHKQ_17_2 = $('#CHKQ_17_2').prop("checked");
            var CHKQ_17_3 = $('#CHKQ_17_3').prop("checked");
            var CHKQ_17_4 = $('#CHKQ_17_4').prop("checked");
            var CHKQ_17_5 = $('#CHKQ_17_5').prop("checked");
            var CHKQ_18_1 = $('#CHKQ_18_1').prop("checked");
            var CHKQ_18_2 = $('#CHKQ_18_2').prop("checked");
            var CHKQ_18_3 = $('#CHKQ_18_3').prop("checked");
            var CHKQ_18_4 = $('#CHKQ_18_4').prop("checked");
            var CHKQ_18_5 = $('#CHKQ_18_5').prop("checked");
            var CHKQ_19_1 = $('#CHKQ_19_1').prop("checked");
            var CHKQ_19_2 = $('#CHKQ_19_2').prop("checked");
            var CHKQ_19_3 = $('#CHKQ_19_3').prop("checked");
            var CHKQ_19_4 = $('#CHKQ_19_4').prop("checked");
            var CHKQ_19_5 = $('#CHKQ_19_5').prop("checked");
            var Comments = $('#Comments').val();
            var txtname = $('#txtname').val();
            var ddlpat_no = $('#ddlpat_no').val();


            if (ddlpat_no == '0') {
                alert('Please Select Patient')
                return;
            }

            var AllRecords = {
                'CHKQ_1_1': CHKQ_1_1, 'CHKQ_1_2': CHKQ_1_2, 'CHKQ_1_3': CHKQ_1_3, 'CHKQ_1_4': CHKQ_1_4, 'CHKQ_1_5': CHKQ_1_5, 'CHKQ_2_1': CHKQ_2_1, 'CHKQ_2_2': CHKQ_2_2, 'CHKQ_2_3': CHKQ_2_3, 'CHKQ_2_4': CHKQ_2_4, 'CHKQ_2_5': CHKQ_2_5,
                'CHKQ_3_1': CHKQ_3_1, 'CHKQ_3_2': CHKQ_3_2, 'CHKQ_3_3': CHKQ_3_3, 'CHKQ_3_4': CHKQ_3_4, 'CHKQ_3_5': CHKQ_3_5, 'CHKQ_4_1': CHKQ_4_1, 'CHKQ_4_2': CHKQ_4_2, 'CHKQ_4_3': CHKQ_4_3, 'CHKQ_4_4': CHKQ_4_4, 'CHKQ_4_5': CHKQ_4_5, 'CHKQ_5_1': CHKQ_5_1, 'CHKQ_5_3': CHKQ_5_3, 'CHKQ_5_2': CHKQ_5_2, 'CHKQ_5_4': CHKQ_5_4, 'CHKQ_5_5': CHKQ_5_5,
                'CHKQ_6_1': CHKQ_6_1, 'CHKQ_6_2': CHKQ_6_2, 'CHKQ_6_3': CHKQ_6_3, 'CHKQ_6_4': CHKQ_6_4, 'CHKQ_6_5': CHKQ_6_5, 'CHKQ_7_1': CHKQ_7_1, 'CHKQ_7_2': CHKQ_7_2, 'CHKQ_7_3': CHKQ_7_3, 'CHKQ_7_4': CHKQ_7_4, 'CHKQ_7_5': CHKQ_7_5,
                'CHKQ_8_1': CHKQ_8_1, 'CHKQ_8_2': CHKQ_8_2, 'CHKQ_8_3': CHKQ_8_3, 'CHKQ_8_4': CHKQ_8_4, 'CHKQ_8_5': CHKQ_8_5, 'CHKQ_9_1': CHKQ_9_1, 'CHKQ_9_2': CHKQ_9_2, 'CHKQ_9_3': CHKQ_9_3, 'CHKQ_9_4': CHKQ_9_4, 'CHKQ_9_5': CHKQ_9_5,
                'CHKQ_10_1': CHKQ_4_1, 'CHKQ_10_2': CHKQ_10_2, 'CHKQ_10_3': CHKQ_10_3, 'CHKQ_10_4': CHKQ_10_4, 'CHKQ_10_5': CHKQ_10_5, 'CHKQ_11_1': CHKQ_11_1, 'CHKQ_11_2': CHKQ_11_2, 'CHKQ_11_3': CHKQ_11_3, 'CHKQ_11_4': CHKQ_11_4, 'CHKQ_11_5': CHKQ_11_5,
                'CHKQ_12_1': CHKQ_12_1, 'CHKQ_12_2': CHKQ_12_2, 'CHKQ_12_3': CHKQ_12_3, 'CHKQ_12_4': CHKQ_12_4, 'CHKQ_12_5': CHKQ_12_5, 'CHKQ_13_1': CHKQ_13_1, 'CHKQ_13_2': CHKQ_13_2, 'CHKQ_13_3': CHKQ_13_3, 'CHKQ_13_4': CHKQ_13_4, 'CHKQ_13_5': CHKQ_13_5,
                'CHKQ_14_1': CHKQ_14_1, 'CHKQ_14_2': CHKQ_14_2, 'CHKQ_14_3': CHKQ_14_3, 'CHKQ_14_4': CHKQ_14_4, 'CHKQ_14_5': CHKQ_14_5, 'CHKQ_15_1': CHKQ_15_1, 'CHKQ_15_2': CHKQ_15_2, 'CHKQ_15_3': CHKQ_15_3, 'CHKQ_15_4': CHKQ_15_4, 'CHKQ_15_5': CHKQ_15_5,
                'CHKQ_16_1': CHKQ_16_1, 'CHKQ_16_2': CHKQ_16_2, 'CHKQ_16_3': CHKQ_16_3, 'CHKQ_16_4': CHKQ_16_4, 'CHKQ_16_5': CHKQ_16_5, 'CHKQ_17_1': CHKQ_17_1, 'CHKQ_17_2': CHKQ_17_2, 'CHKQ_17_3': CHKQ_17_3, 'CHKQ_17_4': CHKQ_17_4, 'CHKQ_17_5': CHKQ_17_5,
                'CHKQ_18_1': CHKQ_18_1, 'CHKQ_18_2': CHKQ_18_2, 'CHKQ_18_3': CHKQ_18_3, 'CHKQ_18_4': CHKQ_18_4, 'CHKQ_18_5': CHKQ_18_5, 'CHKQ_19_1': CHKQ_19_1, 'CHKQ_19_2': CHKQ_19_2, 'CHKQ_19_3': CHKQ_19_3, 'CHKQ_19_4': CHKQ_19_4, 'CHKQ_19_5': CHKQ_19_5, 'Comments': Comments, 'txtname': txtname, 'ddlpat_no': ddlpat_no
            };

            PageMethods.SaveStudentData(btnSave, JSON.stringify(AllRecords), function (res) {



                alert("Data added Successfully");
                //toasterMessage(false, "Success", "Data added Successfully");
                window.location = "Surveylist.aspx"
            });
        }



        function LoadSurveyDatas(Stu_ID) {
            PageMethods.LoadSurveyData(Stu_ID, function (resp) {
                var studata = JSON.parse(resp);
                $('#CHKQ_1_1').val(studata.CHKQ_1_1); if (studata.CHKQ_1_1 == 1) { $("#CHKQ_1_1").prop('checked', true); }
                $('#CHKQ_1_2').val(studata.CHKQ_1_2); if (studata.CHKQ_1_2 == 1) { $("#CHKQ_1_2").prop('checked', true); }
                $('#CHKQ_1_3').val(studata.CHKQ_1_3); if (studata.CHKQ_1_3 == 1) { $("#CHKQ_1_3").prop('checked', true); }
                $('#CHKQ_1_4').val(studata.CHKQ_1_4); if (studata.CHKQ_1_4 == 1) { $("#CHKQ_1_4").prop('checked', true); }
                $('#CHKQ_1_5').val(studata.CHKQ_1_5); if (studata.CHKQ_1_5 == 1) { $("#CHKQ_1_5").prop('checked', true); }
                $('#CHKQ_2_1').val(studata.CHKQ_2_1); if (studata.CHKQ_2_1 == 1) { $("#CHKQ_2_1").prop('checked', true); }
                $('#CHKQ_2_2').val(studata.CHKQ_2_2); if (studata.CHKQ_2_2 == 1) { $("#CHKQ_2_2").prop('checked', true); }
                $('#CHKQ_2_3').val(studata.CHKQ_2_3); if (studata.CHKQ_2_3 == 1) { $("#CHKQ_2_3").prop('checked', true); }
                $('#CHKQ_2_4').val(studata.CHKQ_2_4); if (studata.CHKQ_2_4 == 1) { $("#CHKQ_2_4").prop('checked', true); }
                $('#CHKQ_2_5').val(studata.CHKQ_2_5); if (studata.CHKQ_2_5 == 1) { $("#CHKQ_2_5").prop('checked', true); }
                $('#CHKQ_3_1').val(studata.CHKQ_3_1); if (studata.CHKQ_3_1 == 1) { $("#CHKQ_3_1").prop('checked', true); }
                $('#CHKQ_3_2').val(studata.CHKQ_3_2); if (studata.CHKQ_3_2 == 1) { $("#CHKQ_3_2").prop('checked', true); }
                $('#CHKQ_3_3').val(studata.CHKQ_3_3); if (studata.CHKQ_3_3 == 1) { $("#CHKQ_3_3").prop('checked', true); }
                $('#CHKQ_3_4').val(studata.CHKQ_3_4); if (studata.CHKQ_3_4 == 1) { $("#CHKQ_3_4").prop('checked', true); }
                $('#CHKQ_3_5').val(studata.CHKQ_3_5); if (studata.CHKQ_3_5 == 1) { $("#CHKQ_3_5").prop('checked', true); }
                $('#CHKQ_4_1').val(studata.CHKQ_4_1); if (studata.CHKQ_4_1 == 1) { $("#CHKQ_4_1").prop('checked', true); }
                $('#CHKQ_4_2').val(studata.CHKQ_4_2); if (studata.CHKQ_4_2 == 1) { $("#CHKQ_4_2").prop('checked', true); }
                $('#CHKQ_4_3').val(studata.CHKQ_4_3); if (studata.CHKQ_4_3 == 1) { $("#CHKQ_4_3").prop('checked', true); }
                $('#CHKQ_4_4').val(studata.CHKQ_4_4); if (studata.CHKQ_4_4 == 1) { $("#CHKQ_4_4").prop('checked', true); }
                $('#CHKQ_4_5').val(studata.CHKQ_4_5); if (studata.CHKQ_4_5 == 1) { $("#CHKQ_4_5").prop('checked', true); }
                $('#CHKQ_5_1').val(studata.CHKQ_5_1); if (studata.CHKQ_5_1 == 1) { $("#CHKQ_5_1").prop('checked', true); }
                $('#CHKQ_5_2').val(studata.CHKQ_5_2); if (studata.CHKQ_5_2 == 1) { $("#CHKQ_5_2").prop('checked', true); }
                $('#CHKQ_5_3').val(studata.CHKQ_5_3); if (studata.CHKQ_5_3 == 1) { $("#CHKQ_5_3").prop('checked', true); }
                $('#CHKQ_5_4').val(studata.CHKQ_5_4); if (studata.CHKQ_5_4 == 1) { $("#CHKQ_5_4").prop('checked', true); }
                $('#CHKQ_5_5').val(studata.CHKQ_5_5); if (studata.CHKQ_5_5 == 1) { $("#CHKQ_5_5").prop('checked', true); }
                $('#CHKQ_6_1').val(studata.CHKQ_6_1); if (studata.CHKQ_6_1 == 1) { $("#CHKQ_6_1").prop('checked', true); }
                $('#CHKQ_6_2').val(studata.CHKQ_6_2); if (studata.CHKQ_6_2 == 1) { $("#CHKQ_6_2").prop('checked', true); }
                $('#CHKQ_6_3').val(studata.CHKQ_6_3); if (studata.CHKQ_6_3 == 1) { $("#CHKQ_6_3").prop('checked', true); }
                $('#CHKQ_6_4').val(studata.CHKQ_6_4); if (studata.CHKQ_6_4 == 1) { $("#CHKQ_6_4").prop('checked', true); }
                $('#CHKQ_6_5').val(studata.CHKQ_6_5); if (studata.CHKQ_6_5 == 1) { $("#CHKQ_6_5").prop('checked', true); }
                $('#CHKQ_7_1').val(studata.CHKQ_7_1); if (studata.CHKQ_7_1 == 1) { $("#CHKQ_7_1").prop('checked', true); }
                $('#CHKQ_7_2').val(studata.CHKQ_7_2); if (studata.CHKQ_7_2 == 1) { $("#CHKQ_7_2").prop('checked', true); }
                $('#CHKQ_7_3').val(studata.CHKQ_7_3); if (studata.CHKQ_7_3 == 1) { $("#CHKQ_7_3").prop('checked', true); }
                $('#CHKQ_7_4').val(studata.CHKQ_7_4); if (studata.CHKQ_7_4 == 1) { $("#CHKQ_7_4").prop('checked', true); }
                $('#CHKQ_7_5').val(studata.CHKQ_7_5); if (studata.CHKQ_7_5 == 1) { $("#CHKQ_7_5").prop('checked', true); }
                $('#CHKQ_8_1').val(studata.CHKQ_8_1); if (studata.CHKQ_8_1 == 1) { $("#CHKQ_8_1").prop('checked', true); }
                $('#CHKQ_8_2').val(studata.CHKQ_8_2); if (studata.CHKQ_8_2 == 1) { $("#CHKQ_8_2").prop('checked', true); }
                $('#CHKQ_8_3').val(studata.CHKQ_8_3); if (studata.CHKQ_8_3 == 1) { $("#CHKQ_8_3").prop('checked', true); }
                $('#CHKQ_8_4').val(studata.CHKQ_8_4); if (studata.CHKQ_8_4 == 1) { $("#CHKQ_8_4").prop('checked', true); }
                $('#CHKQ_8_5').val(studata.CHKQ_8_5); if (studata.CHKQ_8_5 == 1) { $("#CHKQ_8_5").prop('checked', true); }
                $('#CHKQ_9_1').val(studata.CHKQ_9_1); if (studata.CHKQ_9_1 == 1) { $("#CHKQ_9_1").prop('checked', true); }
                $('#CHKQ_9_2').val(studata.CHKQ_9_2); if (studata.CHKQ_9_2 == 1) { $("#CHKQ_9_2").prop('checked', true); }
                $('#CHKQ_9_3').val(studata.CHKQ_9_3); if (studata.CHKQ_9_3 == 1) { $("#CHKQ_9_3").prop('checked', true); }
                $('#CHKQ_9_4').val(studata.CHKQ_9_4); if (studata.CHKQ_9_4 == 1) { $("#CHKQ_9_4").prop('checked', true); }
                $('#CHKQ_9_5').val(studata.CHKQ_9_5); if (studata.CHKQ_9_5 == 1) { $("#CHKQ_9_5").prop('checked', true); }
                $('#CHKQ_10_1').val(studata.CHKQ_10_1); if (studata.CHKQ_10_1 == 1) { $("#CHKQ_10_1").prop('checked', true); }
                $('#CHKQ_10_2').val(studata.CHKQ_10_2); if (studata.CHKQ_10_2 == 1) { $("#CHKQ_10_2").prop('checked', true); }
                $('#CHKQ_10_3').val(studata.CHKQ_10_3); if (studata.CHKQ_10_3 == 1) { $("#CHKQ_10_3").prop('checked', true); }
                $('#CHKQ_10_4').val(studata.CHKQ_10_4); if (studata.CHKQ_10_4 == 1) { $("#CHKQ_10_4").prop('checked', true); }
                $('#CHKQ_10_5').val(studata.CHKQ_10_5); if (studata.CHKQ_10_5 == 1) { $("#CHKQ_10_5").prop('checked', true); }
                $('#CHKQ_11_1').val(studata.CHKQ_11_1); if (studata.CHKQ_11_1 == 1) { $("#CHKQ_11_1").prop('checked', true); }
                $('#CHKQ_11_2').val(studata.CHKQ_11_2); if (studata.CHKQ_11_2 == 1) { $("#CHKQ_11_2").prop('checked', true); }
                $('#CHKQ_11_3').val(studata.CHKQ_11_3); if (studata.CHKQ_11_3 == 1) { $("#CHKQ_11_3").prop('checked', true); }
                $('#CHKQ_11_4').val(studata.CHKQ_11_4); if (studata.CHKQ_11_4 == 1) { $("#CHKQ_11_4").prop('checked', true); }
                $('#CHKQ_11_5').val(studata.CHKQ_11_5); if (studata.CHKQ_11_5 == 1) { $("#CHKQ_11_5").prop('checked', true); }
                $('#CHKQ_12_1').val(studata.CHKQ_12_1); if (studata.CHKQ_12_1 == 1) { $("#CHKQ_12_1").prop('checked', true); }
                $('#CHKQ_12_2').val(studata.CHKQ_12_2); if (studata.CHKQ_12_2 == 1) { $("#CHKQ_12_2").prop('checked', true); }
                $('#CHKQ_12_3').val(studata.CHKQ_12_3); if (studata.CHKQ_12_3 == 1) { $("#CHKQ_12_3").prop('checked', true); }
                $('#CHKQ_12_4').val(studata.CHKQ_12_4); if (studata.CHKQ_12_4 == 1) { $("#CHKQ_12_4").prop('checked', true); }
                $('#CHKQ_12_5').val(studata.CHKQ_12_5); if (studata.CHKQ_12_5 == 1) { $("#CHKQ_12_5").prop('checked', true); }
                $('#CHKQ_13_1').val(studata.CHKQ_13_1); if (studata.CHKQ_13_1 == 1) { $("#CHKQ_13_1").prop('checked', true); }
                $('#CHKQ_13_2').val(studata.CHKQ_13_2); if (studata.CHKQ_13_2 == 1) { $("#CHKQ_13_2").prop('checked', true); }
                $('#CHKQ_13_3').val(studata.CHKQ_13_3); if (studata.CHKQ_13_3 == 1) { $("#CHKQ_13_3").prop('checked', true); }
                $('#CHKQ_13_4').val(studata.CHKQ_13_4); if (studata.CHKQ_13_4 == 1) { $("#CHKQ_13_4").prop('checked', true); }
                $('#CHKQ_13_5').val(studata.CHKQ_13_5); if (studata.CHKQ_13_5 == 1) { $("#CHKQ_13_5").prop('checked', true); }
                $('#CHKQ_14_1').val(studata.CHKQ_14_1); if (studata.CHKQ_14_1 == 1) { $("#CHKQ_14_1").prop('checked', true); }
                $('#CHKQ_14_2').val(studata.CHKQ_14_2); if (studata.CHKQ_14_2 == 1) { $("#CHKQ_14_2").prop('checked', true); }
                $('#CHKQ_14_3').val(studata.CHKQ_14_3); if (studata.CHKQ_14_3 == 1) { $("#CHKQ_14_3").prop('checked', true); }
                $('#CHKQ_14_4').val(studata.CHKQ_14_4); if (studata.CHKQ_14_4 == 1) { $("#CHKQ_14_4").prop('checked', true); }
                $('#CHKQ_14_5').val(studata.CHKQ_14_5); if (studata.CHKQ_14_5 == 1) { $("#CHKQ_14_5").prop('checked', true); }
                $('#CHKQ_15_1').val(studata.CHKQ_15_1); if (studata.CHKQ_15_1 == 1) { $("#CHKQ_15_1").prop('checked', true); }
                $('#CHKQ_15_2').val(studata.CHKQ_15_2); if (studata.CHKQ_15_2 == 1) { $("#CHKQ_15_2").prop('checked', true); }
                $('#CHKQ_15_3').val(studata.CHKQ_15_3); if (studata.CHKQ_15_3 == 1) { $("#CHKQ_15_3").prop('checked', true); }
                $('#CHKQ_15_4').val(studata.CHKQ_15_4); if (studata.CHKQ_15_4 == 1) { $("#CHKQ_15_4").prop('checked', true); }
                $('#CHKQ_15_5').val(studata.CHKQ_15_5); if (studata.CHKQ_15_5 == 1) { $("#CHKQ_15_5").prop('checked', true); }
                $('#CHKQ_16_1').val(studata.CHKQ_16_1); if (studata.CHKQ_16_1 == 1) { $("#CHKQ_16_1").prop('checked', true); }
                $('#CHKQ_16_2').val(studata.CHKQ_16_2); if (studata.CHKQ_16_2 == 1) { $("#CHKQ_16_2").prop('checked', true); }
                $('#CHKQ_16_3').val(studata.CHKQ_16_3); if (studata.CHKQ_16_3 == 1) { $("#CHKQ_16_3").prop('checked', true); }
                $('#CHKQ_16_4').val(studata.CHKQ_16_4); if (studata.CHKQ_16_4 == 1) { $("#CHKQ_16_4").prop('checked', true); }
                $('#CHKQ_16_5').val(studata.CHKQ_16_5); if (studata.CHKQ_16_5 == 1) { $("#CHKQ_16_5").prop('checked', true); }
                $('#CHKQ_17_1').val(studata.CHKQ_17_1); if (studata.CHKQ_17_1 == 1) { $("#CHKQ_17_1").prop('checked', true); }
                $('#CHKQ_17_2').val(studata.CHKQ_17_2); if (studata.CHKQ_17_2 == 1) { $("#CHKQ_17_2").prop('checked', true); }
                $('#CHKQ_17_3').val(studata.CHKQ_17_3); if (studata.CHKQ_17_3 == 1) { $("#CHKQ_17_3").prop('checked', true); }
                $('#CHKQ_17_4').val(studata.CHKQ_17_4); if (studata.CHKQ_17_4 == 1) { $("#CHKQ_17_4").prop('checked', true); }
                $('#CHKQ_17_5').val(studata.CHKQ_17_5); if (studata.CHKQ_17_5 == 1) { $("#CHKQ_17_5").prop('checked', true); }
                $('#CHKQ_18_1').val(studata.CHKQ_18_1); if (studata.CHKQ_18_1 == 1) { $("#CHKQ_18_1").prop('checked', true); }
                $('#CHKQ_18_2').val(studata.CHKQ_18_2); if (studata.CHKQ_18_2 == 1) { $("#CHKQ_18_2").prop('checked', true); }
                $('#CHKQ_18_3').val(studata.CHKQ_18_3); if (studata.CHKQ_18_3 == 1) { $("#CHKQ_18_3").prop('checked', true); }
                $('#CHKQ_18_4').val(studata.CHKQ_18_4); if (studata.CHKQ_18_4 == 1) { $("#CHKQ_18_4").prop('checked', true); }
                $('#CHKQ_18_5').val(studata.CHKQ_18_5); if (studata.CHKQ_18_5 == 1) { $("#CHKQ_18_5").prop('checked', true); }
                $('#CHKQ_19_1').val(studata.CHKQ_19_1); if (studata.CHKQ_19_1 == 1) { $("#CHKQ_19_1").prop('checked', true); }
                $('#CHKQ_19_2').val(studata.CHKQ_19_2); if (studata.CHKQ_19_2 == 1) { $("#CHKQ_19_2").prop('checked', true); }
                $('#CHKQ_19_3').val(studata.CHKQ_19_3); if (studata.CHKQ_19_3 == 1) { $("#CHKQ_19_3").prop('checked', true); }
                $('#CHKQ_19_4').val(studata.CHKQ_19_4); if (studata.CHKQ_19_4 == 1) { $("#CHKQ_19_4").prop('checked', true); }
                $('#CHKQ_19_5').val(studata.CHKQ_19_5); if (studata.CHKQ_19_5 == 1) { $("#CHKQ_19_5").prop('checked', true); }
                $('#Comments').val(studata.Comments);
                $('#txtname').val(studata.Name);
                $('#ddlpat_no').val(studata.pat_no).trigger('change');
            })
        }
        function SurvePrint() {
            var id = '<%= Request.QueryString["Stu_ID"] %>';
            if (id != "") {
                window.open('ReportViewer.aspx?ReportName=SurvePrint&ReportTitle=Surve Format Report&Surve_ID=' + id);
            }
        }
        function SurveFormat() {
            window.open('ReportViewer.aspx?ReportName=SurveFormat&ReportTitle=Surve Format ');
        }
</script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
     <div class="col-lg-2 col-md-2 col-sm-2">
          <label>MR NO</label>
        <select id="ddlpat_no" onchange="GetPatientNameByMR()"></select>
     </div>
         <div class="col-lg-2 col-md-2 col-sm-2">
         <label style="margin-left: 30px !important">Your Name</label>
        <input type="text" id="txtname"  />
     </div>
    </div>
    <div class="row">
          <div class="col-lg-4"></div>
        <div class="col-md-8 col-lg-8 col-sm-8">
          
            <div class="col-lg-2 col-md-2 col-sm-2">
               <input type="button" class="btn btn-yellow" value="Save" onclick="SaveFunction()" id="btnSave" />
            </div>  
            <div class="col-lg-2 col-md-2 col-sm-2">
                   <input type="button" class="btn btn-yellow" id="list" value="List View" onclick="location.href = 'Surveylist.aspx';" />
            </div>     
            <div class="col-lg-2 col-md-2 col-sm-2">
                          
            <input type="button" class="btn btn-yellow" id="btnPrint" value="Print" onclick="SurvePrint()" />
            </div> 
            <div class="col-lg-2 col-md-2 col-sm-2">
                    <input type="button" class="btn btn-yellow" id="btnPrintFormat" value="Print Format" onclick="SurveFormat()" style="width: auto;" visible="false" />
            </div>
        </div>
    </div>
    <div style="width: 900px;">
        <p style="font-size: large">We hope you had a pleasant experience at TibbIT Hospital. Your satisfaction is important to us, and we would appreciate your feedback to help us improve our services.</p>
    </div>
    <div class="main-content" style="width: 1200px; margin-top: 20px;">

        <div class="row" id="row">
            <div class="col-md-6">
                <p style="font-size: medium">
                    Please rate your experience on a scale of 1 to 5, with 5 being the highest score.
                </p>
            </div>
            <div class="col-md-6" id="col">
                <div class="row1">
                    <div class="col-md-2">
                        <img src="~../../../../wwwroot/images/HMIS_Icons/1.png" alt="" /></div>
                    <div class="col-md-2">
                        <img src="~../../../../wwwroot/images/HMIS_Icons/2.PNG" alt="" /></div>
                    <div class="col-md-2">
                        <img src="~../../../../wwwroot/images/HMIS_Icons/3.PNG" alt="" /></div>
                    <div class="col-md-2">
                        <img src="~../../../../wwwroot/images/HMIS_Icons/4.PNG" alt="" /></div>
                    <div class="col-md-2">
                        <img src="~../../../../wwwroot/images/HMIS_Icons/5.PNG" alt="" /></div>
                </div>
            </div>


        </div>
        <div class="row">
            <div class="col-md-6">
            </div>
            <div class="col-md-1" style="margin-left: 21px;">
                <label>1</label>
            </div>
            <div class="col-md-1">
                <label>2</label>
            </div>
            <div class="col-md-1">
                <label>3</label>
            </div>
            <div class="col-md-1">
                <label>4</label>
            </div>
            <div class="col-md-1">
                <label>5</label>
            </div>
        </div>
        <div class="row" id="row41">

            <div class="col-md-6" id="colh1">
                <h4 style="font-size: medium"><span>A.</span>Your satisfaction with our CLINICAL TREATMENT
                </h4>
                <input type="hidden" id="Survey_Id" />
            </div>
        </div>
        <div class="row" id="row1">

            <div class="col-md-6" id="col1">
                <h4 style="font-size: medium"><span>1.</span>How satisfied are you with the outcome of your treatment?
                </h4>
            </div>
            <div class="col-md-6" id="col2">
                <div class="row1" style="margin-top: 30px;">
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_1_1" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_1_2" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_1_3" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_1_4" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_1_5" style="width: 40px; height: 30px;" />
                    </div>
                </div>
            </div>
        </div>
        <div class="row" id="row2">

            <div class="col-md-6" id="col3">
                <h4 style="font-size: medium"><span>2.</span>How satisfied are you with the competence of your doctor?
                </h4>
            </div>
            <div class="col-md-6" id="col4">
                <div class="row1" style="margin-top: 30px;">
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_2_1" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_2_2" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_2_3" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_2_4" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_2_5" style="width: 40px; height: 30px;" />
                    </div>
                </div>
            </div>
        </div>

        <div class="row" id="row3">

            <div class="col-md-6" id="col5">
                <h4 style="font-size: medium"><span>3.</span>How satisfied are you with competence of other treatment staff (Resident doctor, nurses, therapists etc)
                </h4>
            </div>
            <div class="col-md-6" id="col6">
                <div class="row1" style="margin-top: 30px;">
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_3_1" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_3_2" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_3_3" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_3_4" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_3_5" style="width: 40px; height: 30px;" />
                    </div>
                </div>
            </div>
        </div>

        <div class="row" id="rowh4">

            <div class="col-md-6" id="colh4">
                <h4 style="font-size: medium"><span>B.</span>Your satisfaction with our BEHAVIOUR towards you
                </h4>
            </div>

        </div>

        <div class="row" id="row4">

            <div class="col-md-6" id="col7">
                <h4 style="font-size: medium"><span>4.</span>How satisfied are you with the behaviour of doctors toward you?
                </h4>
            </div>
            <div class="col-md-6" id="col8">
                <div class="row1" style="margin-top: 30px;">
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_4_1" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_4_2" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_4_3" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_4_4" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_4_5" style="width: 40px; height: 30px;" />
                    </div>
                </div>
            </div>
        </div>

        <div class="row" id="row5">

            <div class="col-md-6" id="col9">
                <h4 style="font-size: medium"><span>5.</span>How satisfied are you with the behaviour of nurses toward you?
                </h4>
            </div>
            <div class="col-md-6" id="col10">
                <div class="row1" style="margin-top: 30px;">
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_5_1" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_5_2" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_5_3" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_5_4" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_5_5" style="width: 40px; height: 30px;" />
                    </div>
                </div>
            </div>
        </div>

        <div class="row" id="row6">

            <div class="col-md-6" id="col11">
                <h4 style="font-size: medium"><span>6.</span>Behaviour of front office staff and customer care executive?
                </h4>
            </div>
            <div class="col-md-6" id="col12">
                <div class="row1" style="margin-top: 30px;">
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_6_1" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_6_2" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_6_3" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_6_4" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_6_5" style="width: 40px; height: 30px;" />
                    </div>
                </div>
            </div>
        </div>

        <div class="row" id="row7">

            <div class="col-md-6" id="col13">
                <h4 style="font-size: medium"><span>7.</span>Behaviour of other staff such as housekeeping and security?
                </h4>
            </div>
            <div class="col-md-6" id="col14">
                <div class="row1" style="margin-top: 30px;">
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_7_1" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_7_2" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_7_3" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_7_4" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_7_5" style="width: 40px; height: 30px;" />
                    </div>
                </div>
            </div>
        </div>
        <div class="row" id="rowh4">

            <div class="col-md-6" id="colh4">
                <h4 style="font-size: medium"><span>C.</span>Your satisfaction with our PROCESSES
                </h4>
            </div>

        </div>
        <div class="row" id="row8">

            <div class="col-md-6" id="col15">
                <h4 style="font-size: medium"><span>8.</span>How satisfied are you with convenience of our admission process?
                </h4>
            </div>
            <div class="col-md-6" id="col16">
                <div class="row1" style="margin-top: 30px;">
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_8_1" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_8_2" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_8_3" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_8_4" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_8_5" style="width: 40px; height: 30px;" />
                    </div>
                </div>
            </div>
        </div>
        <div class="row" id="row9">

            <div class="col-md-6" id="col17">
                <h4 style="font-size: medium"><span>9.</span>
                How satisfied are you with convenience of our discharge process?
            </div>
            <div class="col-md-6" id="col18">
                <div class="row1" style="margin-top: 30px;">
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_9_1" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_9_2" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_9_3" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_9_4" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_9_5" style="width: 40px; height: 30px;" />
                    </div>
                </div>
            </div>
        </div>
        <div class="row" id="row10">

            <div class="col-md-6" id="col19">
                <h4 style="font-size: medium"><span>10.</span>How satisfied are you with provision of information to you
                </h4>
            </div>
            <div class="col-md-6" id="col20">
                <div class="row1" style="margin-top: 30px;">
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_10_1" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_10_2" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_10_3" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_10_4" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_10_5" style="width: 40px; height: 30px;" />
                    </div>
                </div>
            </div>
        </div>
        <div class="row" id="row11">

            <div class="col-md-6" id="col21">
                <h4 style="font-size: medium"><span>11.</span>How satisfied are you with our patient safety processes
                </h4>
            </div>
            <div class="col-md-6" id="col22">
                <div class="row1" style="margin-top: 30px;">
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_11_1" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_11_2" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_11_3" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_11_4" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_11_5" style="width: 40px; height: 30px;" />
                    </div>
                </div>
            </div>
        </div>

        <div class="row" id="row12">

            <div class="col-md-6" id="col23">
                <h4 style="font-size: medium"><span>12.</span>How satisfied are you with our other policies and process?
                </h4>
            </div>
            <div class="col-md-6" id="col24">
                <div class="row1" style="margin-top: 30px;">
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_12_1" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_12_2" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_12_3" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_12_4" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_12_5" style="width: 40px; height: 30px;" />
                    </div>
                </div>
            </div>
        </div>
        <div class="row" id="rowh1">

            <div class="col-md-6" id="colh4">
                <h4 style="font-size: medium"><span>D.</span>Your satisfaction with our SERVICES & FACILITIES
                </h4>
            </div>

        </div>
        <div class="row" id="row13">

            <div class="col-md-6" id="col25">
                <h4 style="font-size: medium"><span>13.</span>How satisfied are you with the housekeeping and cleanliness?
                </h4>
            </div>
            <div class="col-md-6" id="col26">
                <div class="row1" style="margin-top: 30px;">
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_13_1" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_13_2" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_13_3" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_13_4" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_13_5" style="width: 40px; height: 30px;" />
                    </div>
                </div>
            </div>
        </div>
        <div class="row" id="row14">

            <div class="col-md-6" id="col27">
                <h4 style="font-size: medium"><span>14.</span>How satisfied are you with the maintenance of facilities?
                </h4>
            </div>
            <div class="col-md-6" id="col28">
                <div class="row1" style="margin-top: 30px;">
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_14_1" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_14_2" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_14_3" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_14_4" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_14_5" style="width: 40px; height: 30px;" />
                    </div>
                </div>
            </div>
        </div>
        <div class="row" id="row15">

            <div class="col-md-6" id="col29">
                <h4 style="font-size: medium"><span>15.</span>How satisfied are you with our security services?
                </h4>
            </div>
            <div class="col-md-6" id="col30">
                <div class="row1" style="margin-top: 30px;">
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_15_1" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_15_2" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_15_3" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_15_4" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_15_5" style="width: 40px; height: 30px;" />
                    </div>
                </div>
            </div>
        </div>
        <div class="row" id="row16">

            <div class="col-md-6" id="col31">
                <h4 style="font-size: medium"><span>16.</span>How satisfied are you with the comfort of your stay?
                </h4>
            </div>
            <div class="col-md-6" id="col32">
                <div class="row1" style="margin-top: 30px;">
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_16_1" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_16_2" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_16_3" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_16_4" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_16_5" style="width: 40px; height: 30px;" />
                    </div>
                </div>
            </div>
        </div>
        <div class="row" id="row17">

            <div class="col-md-6" id="col33">
                <h4 style="font-size: medium"><span>17.</span>How satisfied are you with convenience of your visitors?
                </h4>
            </div>
            <div class="col-md-6" id="col34">
                <div class="row1" style="margin-top: 30px;">
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_17_1" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_17_2" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_17_3" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_17_4" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_17_5" style="width: 40px; height: 30px;" />
                    </div>
                </div>
            </div>
        </div>
        <div class="row" id="rowh5">

            <div class="col-md-6" id="colh5">
                <h4 style="font-size: medium"><span>E.</span>Your OVERALL satisfaction
                </h4>
            </div>

        </div>
        <div class="row" id="row18">

            <div class="col-md-6" id="col35">
                <h4 style="font-size: medium"><span>18.</span>Please rate your overall satisfaction with the hospital
                </h4>
            </div>
            <div class="col-md-6" id="col36">
                <div class="row1" style="margin-top: 30px;">
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_18_1" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_18_2" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_18_3" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_18_4" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_18_5" style="width: 40px; height: 30px;" />
                    </div>
                </div>
            </div>
        </div>
        <div class="row" id="row19">

            <div class="col-md-6" id="col37">
                <h4 style="font-size: medium"><span>19.</span>Please indicate how likely are you to recommend our hospital to your friends and relatives for treatment
                </h4>
            </div>
            <div class="col-md-6" id="col38">
                <div class="row1" style="margin-top: 30px;">
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_19_1" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_19_2" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_19_3" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_19_4" style="width: 40px; height: 30px;" />
                    </div>
                    <div class="col-md-2">
                        <input type="checkbox" id="CHKQ_19_5" style="width: 40px; height: 30px;" />
                    </div>
                </div>
            </div>
        </div>
        <div class="row">
            <div class="col-md-12">
                <h4>Please write any other comments/feedback</h4>
                <textarea type="text" id="Comments" style="width: 700px; height: 200px;"></textarea>
            </div>
        </div>

    </div>
</asp:Content>
