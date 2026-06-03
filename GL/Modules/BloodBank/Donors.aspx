<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Donors.aspx.cs" Inherits="PMS.Donors" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/Donor.css" rel="stylesheet" />

    <script type="text/javascript">

        function abc() {

            debugger;
            var isTrue = $('#checkoutdoor').is(':checked');
            if (isTrue) {
                var fghjh = 'Outdoor';
                $('#token-input-ctl00_MainContent_txtPatient_ID').val(fghjh);


                $('#token-input-ctl00_MainContent_txtPatient_ID').attr('disabled', true);



            }
            if (isTrue == false) {
                $('#token-input-ctl00_MainContent_txtPatient_ID').val('');
                $('#token-input-ctl00_MainContent_txtPatient_ID').attr('disabled', false);


            }
        }
        function toTitleCase(str) {
            return str.replace(/(?:^|\s)\w/g, function (match) {
                return match.toUpperCase();
            });
        }
        function Result() {
            debugger;
            var hbs = $("#ddlhbs").val();
            var hcv = $("#ddlHCV").val();
            var hiv = $("#ddlHiV").val();
            var vdrl = $("#ddlvdrl").val();
            var mp = $("#ddlmp").val();
            if (hbs == "01" || hcv == "01" || hiv == "01" || vdrl == "01" || mp == "01") {
                $("#yfit").css("width", "15%");
                $("#yfit").prop('disabled', true);
                $("#nunfit").prop('checked', true);
                $("#yfit").prop('checked', false);
                //$("#yfit").css('width', '16px;');
            }
            else {
                $("#yfit").prop('disabled', false);
                $("#yfit").prop('checked', true);
                $("#nunfit").prop('checked', false);
            }

        }
        function CheckDuplicateDonor(donr_no) {


            $.ajax({
                type: "POST",
                url: "Donors.aspx/CheckDuplicateDonor",
                data: JSON.stringify
                    ({
                        "donr_no": donr_no,

                    }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {

                    var Check = response.d;
                    if (Check == false) {
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'Provided Donor No Already Exists Select Other Number',
                            showConfirmButton: false,
                            timer: 2000,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });

                        $("#ctl00_MainContent_txtDonorno").val('');
                        return true;

                    }
                }
            });
        }
        function CheckBloodBagDuplicate(bgno) {

            $.ajax({
                type: "POST",
                url: "Donors.aspx/CheckDuplicate",
                data: JSON.stringify
                    ({
                        "Bag_No": bgno,

                    }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {


                    var Check = response.d;
                    if (Check == false) {
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'Provided Bag No Already Exists Select Other name',
                            showConfirmButton: false,
                            timer: 2000,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });

                        $("#txtbgno").val('');
                        return true;

                    }
                    else {
                        
                    }
                },

            });

        }
        var isProceed = true;
        $(document).ready(function () {
            $("table.responstable tbody tr td:odd input[type='checkbox']:nth-child(2)").prop('checked', true);
          
            $('#nfood').prop("checked", false);
            $('#yfood').prop("checked", true);



            $('#ctl00_MainContent_txtDateDonation').on('change', function () {
                debugger;
                $('#ctl00_MainContent_chkFirstTime').css('pointer-events', 'none');
            });
            $('#ctl00_MainContent_chkFirstTime').on('change', function () {
                debugger;
                if (this.checked) {
                    $('#ctl00_MainContent_txtDateDonation').prop('disabled', true);
                }
                else {
                    $('#ctl00_MainContent_txtDateDonation').prop('disabled', false);
                }
            });

            var isBagDuplicate = true;
            var isDonorDuplicate = true;
            $('#txtbgno').on('change', function () {
                var bagno = $(this).val();
                CheckBloodBagDuplicate(bagno);

            });
            $('#ctl00_MainContent_txtDonorno').on('change', function () {

                var donr_no = $(this).val();
                CheckDuplicateDonor(donr_no)

            });
            $('#btnSaveTabFirst').on('click', function () {
                //tab1
               
                SaveDonorHistory();

            });
            $('#btnSaveSecondTab').on('click', function () {
                //tab2
                SaveDonationRecord();




            });
            $('#nunfit').on('change', function () {
                var id = $(this).prop('checked');
                if (id == true) {
                    $('#txtbgno').val('');
                    $('#txtbgno').attr('disabled', true);
                }



            });
            $('#yfit').on('change', function () {
                var id = $(this).prop('checked');
                if (id == true) {
                    $('#txtbgno').attr('disabled', false);
                }


            });

            MaskedInput({
                elm: document.getElementById('ctl00_MainContent_txtCNIC'), // select only by id
                format: '_____-_______-_',
                separator: '-'
            });

            ///
            $('input[name="check1"]').change(function () {

                if (this.checked) {
                    $('input[name="check1"]').not(this).prop('checked', false);
                }
            });
            $('input[name="check5"]').change(function () {

                if (this.checked) {
                    $('input[name="check5"]').not(this).prop('checked', false);
                }
            });
            $('input[name="check7"]').change(function () {

                if (this.checked) {
                    $('input[name="check7"]').not(this).prop('checked', false);
                }
            });
            $('input[name="check9"]').change(function () {

                if (this.checked) {
                    $('input[name="check9"]').not(this).prop('checked', false);
                }
            });
            $('input[name="check11"]').change(function () {

                if (this.checked) {
                    $('input[name="check11"]').not(this).prop('checked', false);
                }
            });
            $('input[name="check13"]').change(function () {

                if (this.checked) {
                    $('input[name="check13"]').not(this).prop('checked', false);
                }
            });
            $('input[name="check15"]').change(function () {

                if (this.checked) {
                    $('input[name="check15"]').not(this).prop('checked', false);
                }
            });
            $('input[name="check17"]').change(function () {

                if (this.checked) {
                    $('input[name="check17"]').not(this).prop('checked', false);
                }
            });
            $('input[name="check19"]').change(function () {

                if (this.checked) {
                    $('input[name="check19"]').not(this).prop('checked', false);
                }
            });
            $('input[name="check21"]').change(function () {

                if (this.checked) {
                    $('input[name="check21"]').not(this).prop('checked', false);
                }
            });
            $('input[name="check23"]').change(function () {

                if (this.checked) {
                    $('input[name="check23"]').not(this).prop('checked', false);
                }
            });
            $('input[name="check25"]').change(function () {

                if (this.checked) {
                    $('input[name="check25"]').not(this).prop('checked', false);
                }
            });
            $('input[name="check1"]').change(function () {

                if (this.checked) {
                    $('input[name="check1"]').not(this).prop('checked', false);
                }
            });
            $('input[name="check27"]').change(function () {

                if (this.checked) {
                    $('input[name="check27"]').not(this).prop('checked', false);
                }
            });
            $('input[name="check29"]').change(function () {

                if (this.checked) {
                    $('input[name="check29"]').not(this).prop('checked', false);
                }
            });
            $('input[name="check31"]').change(function () {

                if (this.checked) {
                    $('input[name="check31"]').not(this).prop('checked', false);
                }
            });
            $('input[name="check33"]').change(function () {

                if (this.checked) {
                    $('input[name="check33"]').not(this).prop('checked', false);
                }
            });
            $('input[name="check35"]').change(function () {

                if (this.checked) {
                    $('input[name="check35"]').not(this).prop('checked', false);
                }
            });
            $('input[name="check37"]').change(function () {

                if (this.checked) {
                    $('input[name="check37"]').not(this).prop('checked', false);
                }
            });
            $('input[name="check39"]').change(function () {

                if (this.checked) {
                    $('input[name="check39"]').not(this).prop('checked', false);
                }
            });
            $('input[name="check41"]').change(function () {

                if (this.checked) {
                    $('input[name="check41"]').not(this).prop('checked', false);
                }
            });
            $('input[name="check43"]').change(function () {

                if (this.checked) {
                    $('input[name="check43"]').not(this).prop('checked', false);
                }
            });
            $('input[name="check45"]').change(function () {

                if (this.checked) {
                    $('input[name="check45"]').not(this).prop('checked', false);
                }
            }); $('input[name="check47"]').change(function () {

                if (this.checked) {
                    $('input[name="check47"]').not(this).prop('checked', false);
                }
            });
            $('input[name="check49"]').change(function () {

                if (this.checked) {
                    $('input[name="check49"]').not(this).prop('checked', false);
                }
            });
            $('input[name="checkf"]').change(function () {

                if (this.checked) {
                    $('input[name="checkf"]').not(this).prop('checked', false);
                }
            });
            ///
            append_ddl();
            $("#txtdate").datepicker({ dateFormat: 'dd M yy' });

           

            $("#ctl00_MainContent_txtDateDonation").datepicker({ dateFormat: 'dd M yy' }).attr('readonly', 'readonly');
            var id = '<%=Request.QueryString["ID"]%>';
            if (id != "") {
               
                $("#btnSaveTabFirst").val('Update');
                $("#btnSaveSecondTab").val('Update');

                donor_Saved = 1;
                $('#hdnUpdateVal').prop('value', id);
                getRecords(id);
            }

            loadtokenInputsDefault();


        });

        function redirect() {
            window.location = 'DonorList.aspx';
        }

        function prints() {
            debugger;
            var id = '<%=Request.QueryString["ID"]%>';
            if (id != null) {
                window.open('ReportViewer.aspx?ReportName=BasePrintDonor&ReportTitle=Department Of Pathology&Donor_ID=' + id);
            }
        }

        function append_ddl() {
            $.ajax({
                type: "POST",
                url: "Donors.aspx/appedddl",
                data: "",

                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {

                    var parsed_data = JSON.parse(response.d);

                    var HBS = '<option value="0">Please Select</option>';
                    var HCV = '<option value="0">Please Select</option>';
                    var HIV = '<option value="0">Please Select</option>';
                    var VDRL = '<option value="0">Please Select</option>';
                    var MP = '<option value="0">Please Select</option>';
                    var ABO = '<option value="0">Please Select</option>';
                    var RH = '<option value="0">Please Select</option>';
                    $.each(parsed_data, function (key, value) {

                        if (value.ValueSet_Description == "HBS") {
                            HBS += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                        }
                        else if (value.ValueSet_Description == "HCV") {
                            HCV += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                        }
                        else if (value.ValueSet_Description == "HIV") {
                            HIV += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                        }
                        else if (value.ValueSet_Description == "VDRL") {
                            VDRL += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                        }
                        else if (value.ValueSet_Description == "MP") {
                            MP += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                        }
                        else if (value.ValueSet_Description == "ABO group") {
                            ABO += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                        }
                        else if (value.ValueSet_Description == "Rh Type") {
                            RH += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                        }


                    });

                    $("#ddlhbs").html(HBS);
                    $("#ddlHCV").html(HCV);
                    $("#ddlHiV").html(HIV);
                    $("#ddlvdrl").html(VDRL);
                    $("#ddlmp").html(MP);

                    $("#ddlabgroup").html(ABO);
                    $("#ddlrhtype").html(RH);
                }

            });
        }
        debugger;
        function getRecords(id) {

            debugger;
            $.ajax({
                type: "POST",
                url: "Donors.aspx/getRecords",
                data: JSON.stringify({ "id": id }),

                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var parsed_data = JSON.parse(response.d);
                    var Patient_Id = parsed_data[0].Patient_Id;

                    $("#yheartdis").prop('checked', parsed_data[0].D_yheartdis);
                    $("#nheartdis").prop('checked', parsed_data[0].D_nheartdis);
                    $("#ytattoo").prop('checked', parsed_data[0].D_ytattoo);
                    $("#ntattoo").prop('checked', parsed_data[0].D_ntattoo);
                    $("#yimprison").prop('checked', parsed_data[0].D_yimprison);
                    $("#nimprison").prop('checked', parsed_data[0].D_nimprison);
                    $("#yepi").prop('checked', parsed_data[0].D_yepi);
                    $("#nepi").prop('checked', parsed_data[0].D_nepi);

                    $("#yacu").prop('checked', parsed_data[0].D_yacu);
                    $("#nacu").prop('checked', parsed_data[0].D_nacu);

                    debugger;

                    $("#ymal").prop('checked', parsed_data[0].D_ymal);
                    $("#nmal").prop('checked', parsed_data[0].D_nmal);

                    $("#yhyper").prop('checked', parsed_data[0].D_yhyper);
                    $("#nhyper").prop('checked', parsed_data[0].D_nhyper);

                    $("#yenp").prop('checked', parsed_data[0].D_yenp);
                    $("#nenp").prop('checked', parsed_data[0].D_nenp);


                    $("#ytuber").prop('checked', parsed_data[0].D_ytuber);
                    $("#ntuber").prop('checked', parsed_data[0].D_ntuber);

                    $("#ysyn").prop('checked', parsed_data[0].D_ysyn);
                    $("#nsyn").prop('checked', parsed_data[0].D_nsyn);


                    $("#yrh").prop('checked', parsed_data[0].D_yrh);
                    $("#nrh").prop('checked', parsed_data[0].D_nrh);


                    $("#ydiabetes").prop('checked', parsed_data[0].D_ydiabetes);
                    $("#ndiabetes").prop('checked', parsed_data[0].D_ndiabetes);


                    $("#yjaun").prop('checked', parsed_data[0].D_yjaund);
                    $("#njaun").prop('checked', parsed_data[0].D_njaund);

                    $("#yvisit").prop('checked', parsed_data[0].D_yvisit);
                    $("#nvisit").prop('checked', parsed_data[0].D_nvisit);

                    $("#ybleed").prop('checked', parsed_data[0].D_ybleed);
                    $("#nbleed").prop('checked', parsed_data[0].D_nbleed);

                    $("#yprevious").prop('checked', parsed_data[0].D_yprevious);
                    $("#nprevious").prop('checked', parsed_data[0].D_nprevious);
                    $("#yaddi").prop('checked', parsed_data[0].D_yaddi);
                    $("#naddi").prop('checked', parsed_data[0].D_naddi);
                    $("#yasthma").prop('checked', parsed_data[0].D_yasthma);
                    $("#nasthma").prop('checked', parsed_data[0].D_nasthma);


                    $("#yrs").prop('checked', parsed_data[0].D_yrsurgery);
                    $("#nrs").prop('checked', parsed_data[0].D_nrsurgery);


                    $("#yusp").prop('checked', parsed_data[0].D_yusp);
                    $("#nusp").prop('checked', parsed_data[0].D_nusp);

                    $("#yimmu").prop('checked', parsed_data[0].D_yimmu);
                    $("#nimmu").prop('checked', parsed_data[0].D_nimmu);


                    $("#ytooth").prop('checked', parsed_data[0].D_ytooth);
                    $("#ntooth").prop('checked', parsed_data[0].D_ntooth);


                    $("#yfood").prop('checked', parsed_data[0].D_yfood);
                    $("#nfood").prop('checked', parsed_data[0].D_nfood);

                    $("#yallergies").prop('checked', parsed_data[0].D_yallergies);
                    $("#nallergies").prop('checked', parsed_data[0].D_nallergies);

                    $("#txtpulse").val(parsed_data[0].D_pulse);
                    $("#txtbp").val(parsed_data[0].D_bp);

                    $("#txttemp").val(parsed_data[0].D_temp);
                    $("#txthb").val(parsed_data[0].D_hb);

                    $("#ddlhbs").val(parsed_data[0].D_hbsAG);
                    $("#ctl00_MainContent_chkFirstTime").prop('checked', parsed_data[0].Donating_First_Time);
                    $("#ddlHCV").val(parsed_data[0].D_HCV);
                    $("#ddlHiV").val(parsed_data[0].D_HIV);
                    $("#ddlvdrl").val(parsed_data[0].D_VDRL);

                    $("#ddlmp").val(parsed_data[0].D_MP);
                    $("#txtothers").val(parsed_data[0].D_Others);

                    $("#txtfoodtime").val(parsed_data[0].D_foodtime);
                    $("#yfit").prop('checked', parsed_data[0].D_fit);
                    $("#nunfit").prop('checked', parsed_data[0].D_unfit);
                    $("#ddlabgroup").val(parsed_data[0].ABO);
                    $("#ddlrhtype").val(parsed_data[0].Rh_Type);
                    $("#ctl00_MainContent_txtDonorno").val(parsed_data[0].Donor_No);

                    $("#txtblood").val(parsed_data[0].D_Blood);
                    $("#txtsign").val(parsed_data[0].D_Signature);
                    $("#txtcell").val(parsed_data[0].D_Cell);
                    $("#txtsignature").val(parsed_data[0].D_sign);
                    $("#ctl00_MainContent_txtCNIC").val(parsed_data[0].CNIC);
                    if (parsed_data[0].D_Date == null || parsed_data[0].D_Date == "null") {

                    }
                    else {
                        var date = $.datepicker.formatDate('dd M yy', new Date(parseInt(parsed_data[0].D_Date.substring(6, 19))))
                        $("#txtdate").val(date);
                    }

                   


                    $("#txt_bagsqty").val(parsed_data[0].Bag_Qty);

                    $("#txtbdrawn").val(parsed_data[0].D_blooddrawn);
                    $("#txtbgno").val(parsed_data[0].D_bagno);
                    $("#txtsignbto").val(parsed_data[0].D_signbto);
                    //
                    $("#ctl00_MainContent_txtDonorName").val(parsed_data[0].Donor_Name);
                    $("#ctl00_MainContent_txtRelation").val(parsed_data[0].Donor_relationship);
                    $("#ctl00_MainContent_txtAdressNo").val(parsed_data[0].Donor_Address);
                    $("#ctl00_MainContent_txtAgeSex").val(parsed_data[0].Donor_Age);
                    $("#ctl00_MainContent_txtOccuption").val(parsed_data[0].Donor_Occupation);
                    $("#ctl00_MainContent_txtStateHealth").val(parsed_data[0].Donor_StateHealth);
                    Result();
                    if (parsed_data[0].Donor_LastDonation == null || parsed_data[0].Donor_LastDonation == "null") {
                        $('#ctl00_MainContent_txtDateDonation').prop('disabled', true);
                      
                    }
                    else {
                        var date_Donation = $.datepicker.formatDate('dd M yy', new Date(parseInt(parsed_data[0].Donor_LastDonation.substring(6, 19))))
                        $("#ctl00_MainContent_txtDateDonation").val(date_Donation);
                        $('#ctl00_MainContent_chkFirstTime').css('pointer-events', 'none');
                    }

                    $("#ctl00_MainContent_txtCenterDuration").val(parsed_data[0].Donor_CenterDonation);

                    debugger;

                    if (Patient_Id == 0) {

                        $('#checkoutdoor').prop('checked', true)

                     

                        $('#token-input-ctl00_maincontent_txtpatient_id').val('outdoor');

                        $('#token-input-ctl00_maincontent_txtpatient_id').attr('disabled', true);



                    }
                    else {

                        debugger;
                        $('#ctl00_MainContent_txtPatient_ID').tokenInput('clear');
                        var tokenData = httpGet("../../json.aspx?Table=Patients&Record=Edit&q=" + Patient_Id);
                        var parsedData = JSON.parse(tokenData);
                        $('#ctl00_MainContent_txtPatient_ID').tokenInput("add", { id: JSON.parse(tokenData)[0].id, name: JSON.parse(tokenData)[0].name });

                    }




                }

            });
        }

        var isProceed = true;
        var isRepeated = true;
        var isDonorRepeated = true;

        function SaveDonorHistory() {
            debugger;
            if (validateSaveTabFirst()) {
                debugger;
                setTimeout(function () {
                    var Patient_id = $("#ctl00_MainContent_txtPatient_ID").val();
                    var bgno = $("#txtbgno").val();
                    var donr_no = $("#ctl00_MainContent_txtDonorno").val();

                    var yheartdis = $("#yheartdis").prop('checked');
                    var nheartdis = $("#nheartdis").prop('checked');

                    var ytattoo = $("#ytattoo").prop('checked');
                    var ntattoo = $("#ntattoo").prop('checked');

                    var yimprison = $("#yimprison").prop('checked');
                    var nimprison = $("#nimprison").prop('checked');

                    var yepi = $("#yepi").prop('checked');
                    var nepi = $("#nepi").prop('checked');

                    var yacu = $("#yacu").prop('checked');
                    var nacu = $("#nacu").prop('checked');

                    var ymal = $("#ymal").prop('checked');
                    var nmal = $("#nmal").prop('checked');

                    var yhyper = $("#yhyper").prop('checked');
                    var nhyper = $("#nhyper").prop('checked');

                    var yenp = $("#yenp").prop('checked');
                    var nenp = $("#nenp").prop('checked');


                    var ytuber = $("#ytuber").prop('checked');
                    var ntuber = $("#ntuber").prop('checked');


                    var ysyn = $("#ysyn").prop('checked');
                    var nsyn = $("#nsyn").prop('checked');

                    var yrh = $("#yrh").prop('checked');
                    var nrh = $("#nrh").prop('checked');

                    var ydiabetes = $("#ydiabetes").prop('checked');
                    var ndiabetes = $("#ndiabetes").prop('checked');

                    var yjaun = $("#yjaun").prop('checked');
                    var njaun = $("#njaun").prop('checked');

                    var yvisit = $("#yvisit").prop('checked');
                    var nvisit = $("#nvisit").prop('checked');

                    var ybleed = $("#ybleed").prop('checked');
                    var nbleed = $("#nbleed").prop('checked');

                    var yprevious = $("#yprevious").prop('checked');
                    var nprevious = $("#nprevious").prop('checked');

                    var yaddi = $("#yaddi").prop('checked');
                    var naddi = $("#naddi").prop('checked');

                    var yasthma = $("#yasthma").prop('checked');
                    var nasthma = $("#nasthma").prop('checked');

                    var yrs = $("#yrs").prop('checked');
                    var nrs = $("#nrs").prop('checked');


                    var yusp = $("#yusp").prop('checked');
                    var nusp = $("#nusp").prop('checked');

                    var yimmu = $("#yimmu").prop('checked');
                    var nimmu = $("#nimmu").prop('checked');


                    var ytooth = $("#ytooth").prop('checked');
                    var ntooth = $("#ntooth").prop('checked');

                    var yfood = $("#yfood").prop('checked');
                    var nfood = $("#nfood").prop('checked');

                    var yallergies = $("#yallergies").prop('checked');
                    var nallergies = $("#nallergies").prop('checked');

                    var donor_name = toTitleCase($("#ctl00_MainContent_txtDonorName").val());
                    var cnic = $('#ctl00_MainContent_txtCNIC').val();
                    //cnic validation
                    if (!(/^[0-9]{5}-[0-9]{7}-[0-9]{1}/).test(cnic))  //cnic validation
                        $("#ctl00_MainContent_txtCNIC").val("");
                    var relation = toTitleCase($("#ctl00_MainContent_txtRelation").val());
                    var address = toTitleCase($("#ctl00_MainContent_txtAdressNo").val());
                    var age = toTitleCase($("#ctl00_MainContent_txtAgeSex").val());
                    var occupation = toTitleCase($("#ctl00_MainContent_txtOccuption").val());
                    var statehealth = toTitleCase($("#ctl00_MainContent_txtStateHealth").val());
                    var datedonation = $("#ctl00_MainContent_txtDateDonation").val();
                    var center = toTitleCase($("#ctl00_MainContent_txtCenterDuration").val());
                    var bagqty = $('#txt_bagsqty').val();
                    var others = toTitleCase($("#txtothers").val());
                    var cell = $("#txtcell").val();
                    var sign = toTitleCase($("#txtsignature").val());
                    var isUpdateValue = $('#hdnUpdateVal').val();
                    var outdoor = $('#token-input-ctl00_MainContent_txtPatient_ID').val();
                    var first_time_Blood = $('#ctl00_MainContent_chkFirstTime').prop('checked');
                    if (isUpdateValue == "(New)") isUpdateValue = 0;
                    debugger
                    var end = new Date().toLocaleDateString();
                    var start = new Date(datedonation).toLocaleDateString();
                    const monthDifference = moment(new Date(end)).diff(new Date(start), 'days', true);
                    var days = Math.floor(monthDifference);
                    if (days < 90) {
                        debugger;
                        //alert("Last date of donation is less then 3 months")

                    }
                    var id = '<%=Request.QueryString["ID"]%>';

                    if (isProceed == true) {
                        $.ajax({
                            type: "POST",
                            url: "Donors.aspx/SaveFirstTab",
                            data: JSON.stringify
                                ({

                                    "Patient_id": Patient_id,
                                    "yheartdis": yheartdis,
                                    "nheartdis": nheartdis,
                                    "ytattoo": ytattoo,
                                    "ntattoo": ntattoo,
                                    "yimprison": yimprison,
                                    "nimprison": nimprison,
                                    "yepi": yepi,
                                    "nepi": nepi,
                                    "yacu": yacu,
                                    "nacu": nacu,
                                    "ymal": ymal,
                                    "nmal": nmal,
                                    "yhyper": yhyper,
                                    "nhyper": nhyper,
                                    "yenp": yenp,
                                    "nenp": nenp,
                                    "ytuber": ytuber,
                                    "ntuber": ntuber,
                                    "ysyn": ysyn,
                                    "nsyn": nsyn,
                                    "yrh": yrh,
                                    "nrh": nrh,
                                    "ydiabetes": ydiabetes,
                                    "ndiabetes": ndiabetes,
                                    "yjaun": yjaun,
                                    "njaun": njaun,
                                    "yvisit": yvisit,
                                    "nvisit": nvisit,
                                    "ybleed": ybleed,
                                    "nbleed": nbleed,
                                    "yprevious": yprevious,
                                    "nprevious": nprevious,
                                    "yaddi": yaddi,
                                    "naddi": naddi,
                                    "yasthma": yasthma,
                                    "nasthma": nasthma,
                                    "yrs": yrs,
                                    "nrs": nrs,
                                    "yusp": yusp,
                                    "nusp": nusp,
                                    "yimmu": yimmu,
                                    "nimmu": nimmu,
                                    "ytooth": ytooth,
                                    "ntooth": ntooth,
                                    "yfood": yfood,
                                    "nfood": nfood,
                                    "yallergies": yallergies,
                                    "nallergies": nallergies,
                                    "others": others,
                                    "sign": sign,
                                    "cell": cell,
                                    "id": id,
                                    "donor_name": donor_name,
                                    "relation": relation,
                                    "address": address,
                                    "age": age,
                                    "occupation": occupation,
                                    "statehealth": statehealth,
                                    "datedonation": datedonation,
                                    "center": center,
                                    "donr_no": donr_no,
                                    "bagqty": bagqty,
                                    "cnic": cnic,
                                    "isUpdateValue": isUpdateValue,
                                    "first_time_Blood": first_time_Blood

                                }),
                            contentType: "application/json; charset=utf-8",
                            dataType: "json",
                            success: function (response) {
                                var master_id = response.d;
                                if (master_id != '-1') {
                                    Swal.fire({
                                        icon: 'success',
                                        title: 'Success!',
                                        text: 'Data has been saved successfully',
                                        showConfirmButton: false,
                                        timer: 2500,
                                        customClass: {
                                            popup: 'swal-big-popup',
                                            title: 'swal-big-title',
                                            htmlContainer: 'swal-big-text'
                                        }
                                    });

                                    window.location.href = "Donors.aspx?ID=" + master_id;
                                    $('#hdnUpdateVal').prop('value', master_id);
                                    $('#btnSaveTabFirst').val('Update');
                                    donor_Saved = 1;
                                    var value = $('#btnSaveSecondTab').val();
                                    if (value == "Update") {
                                        window.location.href = "Donors.aspx?ID=" + master_id;
                                    }
                                }

                            }
                            , error: function () {
                            }
                        });
                    }
                    else {
                        

                    }
                }
                    , 100);
            }
        }

        function CheckExitsBag(id) {
            debugger;
            $.ajax({
                type: "POST",
                url: "Donors.aspx/CheckExitsBag",
                data: JSON.stringify
                    ({
                        "id": id
                    }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
                    var Check = response.d;
                    if (Check == true) {

                    }
                    else {

                        var bagno = $('#txtbgno').val();
                        CheckBloodBagDuplicate(bagno, id);

                    }
                }
            });
        }
        function CheckExitsDonor(id) {
            $.ajax({
                type: "POST",
                url: "Donors.aspx/CheckExitsDonor",
                data: JSON.stringify
                    ({
                        "id": id
                    }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
                    var Check = response.d;
                    if (Check == true) {


                    }
                    else {
                        var donor = $('#ctl00_MainContent_txtDonorno').val();
                        CheckDuplicateDonor(donor, id);
                    }
                }
            });
        }

        function validateSaveTabSecond() {
            //
            isProceed = true;
            isRepeated = true;
            isDonorRepeated = true;
            var Patient_id = $("#ctl00_MainContent_txtPatient_ID").val();
            var id = $("#nunfit").prop('checked');
            if (id == true) {
                isProceed = true;
            }
            var bgno = $("#txtbgno").val();
            var donr_no = $("#ctl00_MainContent_txtDonorno").val();

            var id = '<%=Request.QueryString["ID"]%>';
            

            debugger;

            var pulse = $("#txtpulse").val();
            var bp = $("#txtbp").val();

            var emp = $("#txttemp").val();
            var hb = $("#txthb").val();

            var hbs = $("#ddlhbs").val();

            var hcv = $("#ddlHCV").val();
            var hiv = $("#ddlHiV").val();
            var drl = $("#ddlvdrl").val();

            var mp = $("#ddlmp").val();


            var fit = $("#yfit").prop('checked');
            var unfit = $("#nunfit").prop('checked');
            if (fit == false && unfit == false) {
                debugger
                isProceed = false;

            }


            var id = $("#yfit").prop('checked');
            var bgno = $('#txtbgno').val();
            if (id == true) {
                debugger;
                if (bgno == "") {
                    debugger;
                   
                }
            }
            var txtfoodtime = $("#txtfoodtime").val();
            var txtBlood = $("#txtblood").val();
            var signature = $("#txtsign").val();


            var date = $("#txtdate").val();

            var bdrawn = $("#txtbdrawn").val();

            var signbto = $("#txtsignbto").val();


            var abo = $("#ddlabgroup").val();
            var rh = $("#ddlrhtype").val();


            var patient_id = $("#ctl00_MainContent_txtPatient_ID").val();

            var outdoor = $('#token-input-ctl00_MainContent_txtPatient_ID').val();
            var isUpdateValue = $('#hdnUpdateVal').val();
            if (isUpdateValue == "(New)") isUpdateValue = 0;

            if (signature == "" || abo == "0" || rh == "0" ||
                pulse == "" || bp == "" || emp == "" || hb == "" || hbs == "0" || hcv == "0" || hiv == "0" || drl == "0" ||
                mp == "0" || txtfoodtime == "" || txtBlood == "") {
                isProceed = false;
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Provide All Mendatory Fields',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

            }

            if (Patient_id == "" && outdoor != "Outdoor") {
                isProceed = false;
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Choose Either Mr No Or OutDoor',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

            }




            return isProceed;
        }
        function validateSaveTabFirst() {//
            debugger;
            isProceed = true;
            isDonorRepeated = true;
            var Patient_id = $("#ctl00_MainContent_txtPatient_ID").val();
            var bgno = $("#txtbgno").val();
            var donr_no = $("#ctl00_MainContent_txtDonorno").val();
            var id = '<%=Request.QueryString["ID"]%>';
            
            var yheartdis = $("#yheartdis").prop('checked');
            var nheartdis = $("#nheartdis").prop('checked');
            if (yheartdis == false && nheartdis == false) {

                isProceed = false;

            }
            var ytattoo = $("#ytattoo").prop('checked');
            var ntattoo = $("#ntattoo").prop('checked');
            if (ytattoo == false && ntattoo == false) {

                isProceed = false;

            }
            var yimprison = $("#yimprison").prop('checked');
            var nimprison = $("#nimprison").prop('checked');
            if (yimprison == false && nimprison == false) {

                isProceed = false;

            }
            var yepi = $("#yepi").prop('checked');
            var nepi = $("#nepi").prop('checked');
            if (yepi == false && nepi == false) {

                isProceed = false;

            }
            var yacu = $("#yacu").prop('checked');
            var nacu = $("#nacu").prop('checked');
            if (yacu == false && nacu == false) {

                isProceed = false;

            }
            var ymal = $("#ymal").prop('checked');
            var nmal = $("#nmal").prop('checked');
            if (ymal == false && nmal == false) {

                isProceed = false;

            }
            var yhyper = $("#yhyper").prop('checked');
            var nhyper = $("#nhyper").prop('checked');
            if (yhyper == false && nhyper == false) {

                isProceed = false;

            }
            var yenp = $("#yenp").prop('checked');
            var nenp = $("#nenp").prop('checked');
            if (yenp == false && nenp == false) {

                isProceed = false;

            }

            var ytuber = $("#ytuber").prop('checked');
            var ntuber = $("#ntuber").prop('checked');
            if (ytuber == false && ntuber == false) {

                isProceed = false;

            }

            var ysyn = $("#ysyn").prop('checked');
            var nsyn = $("#nsyn").prop('checked');
            if (ysyn == false && nsyn == false) {

                isProceed = false;

            }

            var yrh = $("#yrh").prop('checked');
            var nrh = $("#nrh").prop('checked');
            if (yrh == false && nrh == false) {

                isProceed = false;

            }

            var ydiabetes = $("#ydiabetes").prop('checked');
            var ndiabetes = $("#ndiabetes").prop('checked');

            if (ydiabetes == false && ndiabetes == false) {

                isProceed = false;

            }
            var yjaun = $("#yjaun").prop('checked');
            var njaun = $("#njaun").prop('checked');
            if (yjaun == false && njaun == false) {

                isProceed = false;

            }
            var yvisit = $("#yvisit").prop('checked');
            var nvisit = $("#nvisit").prop('checked');
            if (yvisit == false && nvisit == false) {

                isProceed = false;

            }
            var ybleed = $("#ybleed").prop('checked');
            var nbleed = $("#nbleed").prop('checked');
            if (ybleed == false && nbleed == false) {

                isProceed = false;

            }
            var yprevious = $("#yprevious").prop('checked');
            var nprevious = $("#nprevious").prop('checked');
            if (yprevious == false && nprevious == false) {

                isProceed = false;

            }
            var yaddi = $("#yaddi").prop('checked');
            var naddi = $("#naddi").prop('checked');
            if (yaddi == false && naddi == false) {

                isProceed = false;

            }
            var yasthma = $("#yasthma").prop('checked');
            var nasthma = $("#nasthma").prop('checked');
            if (yasthma == false && nasthma == false) {

                isProceed = false;

            }

            var yrs = $("#yrs").prop('checked');
            var nrs = $("#nrs").prop('checked');

            if (yrs == false && nrs == false) {

                isProceed = false;

            }
            var yusp = $("#yusp").prop('checked');
            var nusp = $("#nusp").prop('checked');
            if (yusp == false && nusp == false) {

                isProceed = false;

            }
            var yimmu = $("#yimmu").prop('checked');
            var nimmu = $("#nimmu").prop('checked');
            if (yimmu == false && nimmu == false) {

                isProceed = false;

            }

            var ytooth = $("#ytooth").prop('checked');
            var ntooth = $("#ntooth").prop('checked');
            if (ytooth == false && ntooth == false) {

                isProceed = false;

            }

            var yfood = $("#yfood").prop('checked');
            var nfood = $("#nfood").prop('checked');
            if (yfood == false && nfood == false) {

                isProceed = false;

            }
            var yallergies = $("#yallergies").prop('checked');
            var nallergies = $("#nallergies").prop('checked');
            if (yallergies == false && nallergies == false) {

                isProceed = false;

            }
            var donor_name = $("#ctl00_MainContent_txtDonorName").val();
            var cnic = $('#ctl00_MainContent_txtCNIC').val();
            //cnic validation
            if (!(/^[0-9]{5}-[0-9]{7}-[0-9]{1}/).test(cnic))  //cnic validation
                $("#ctl00_MainContent_txtCNIC").val("");
            var relation = $("#ctl00_MainContent_txtRelation").val();
            var address = $("#ctl00_MainContent_txtAdressNo").val();
            var age = $("#ctl00_MainContent_txtAgeSex").val();
            var occupation = $("#ctl00_MainContent_txtOccuption").val();
            var statehealth = $("#ctl00_MainContent_txtStateHealth").val();
            var datedonation = $("#ctl00_MainContent_txtDateDonation").val();
            var center = $("#ctl00_MainContent_txtCenterDuration").val();
            var bagqty = $('#txt_bagsqty').val();
            var others = $("#txtothers").val();
            var cell = $("#txtcell").val();
            var sign = $("#txtsignature").val();
            var isUpdateValue = $('#hdnUpdateVal').val();
            var first_time_Blood = $('#ctl00_MainContent_chkFirstTime').prop('checked');
            var outdoor = $('#token-input-ctl00_MainContent_txtPatient_ID').val();


            if (isUpdateValue == "(New)") isUpdateValue = 0;
            debugger
            var end = new Date().toLocaleDateString();
            var start = new Date(datedonation).toLocaleDateString();
            const monthDifference = moment(new Date(end)).diff(new Date(start), 'days', true);
            var days = Math.floor(monthDifference);
            if (days < 90) {
                debugger;
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Last date of donation is less then 3 months',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

            }
            if (cell == "" || sign == "" || donor_name == "" || relation == "" || address == "" || age == "" || occupation == ""
                || statehealth == "" || (datedonation == "" && first_time_Blood == false) || center == "" ||
                bagqty == "" || others == "" || cnic == "") {

                isProceed = false;
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Provide All Mendatory Fields',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

            }
            if (Patient_id == "" && outdoor != "Outdoor") {
                isProceed = false;
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Choose Either Mr No Or OutDoor',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

            }
            return isProceed;
        }
        //tab-2
        var donor_Saved = 0;
        function SaveDonationRecord() {
            if (validateSaveTabSecond()) {
                debugger;
                setTimeout(function () {
                    debugger;
                    var Patient_id = $("#ctl00_MainContent_txtPatient_ID").val();
                    var bgno = $("#txtbgno").val();
                    var donr_no = $("#ctl00_MainContent_txtDonorno").val();
                    var id = '<%=Request.QueryString["ID"]%>';

                    var pulse = $("#txtpulse").val();
                    var bp = $("#txtbp").val();

                    var emp = $("#txttemp").val();
                    var hb = $("#txthb").val();

                    var hbs = $("#ddlhbs").val();

                    var hcv = $("#ddlHCV").val();
                    var hiv = $("#ddlHiV").val();
                    var drl = $("#ddlvdrl").val();

                    var mp = $("#ddlmp").val();


                    var fit = $("#yfit").prop('checked');
                    var unfit = $("#nunfit").prop('checked');

                    

                    var bgno = $('#txtbgno').val();

                    var txtfoodtime = $("#txtfoodtime").val();
                    var txtBlood = $("#txtblood").val();
                    var signature = $("#txtsign").val();


                    var date = $("#txtdate").val();

                    var bdrawn = $("#txtbdrawn").val();

                    var signbto = $("#txtsignbto").val();


                    var abo = $("#ddlabgroup").val();
                    var rh = $("#ddlrhtype").val();


                    var patient_id = $("#ctl00_MainContent_txtPatient_ID").val();

                    var outdoor = $('#token-input-ctl00_MainContent_txtPatient_ID').val();
                    var isUpdateValue = $('#hdnUpdateVal').val();
                    if (isUpdateValue == "(New)") isUpdateValue = 0;

                    if (isProceed == true) {
                        $.ajax({
                            type: "POST",
                            url: "Donors.aspx/SaveTabSecond",
                            data: JSON.stringify
                                ({
                                    "Patient_id": Patient_id,
                                    "pulse": pulse,
                                    "bp": bp,
                                    "emp": emp,
                                    "hb": hb,
                                    "hcv": hcv,
                                    "hbs": hbs,
                                    "hiv": hiv,
                                    "drl": drl,
                                    "mp": mp,
                                    "date": date,
                                    "txtfoodtime": txtfoodtime,
                                    "txtBlood": txtBlood,
                                    "fit": fit,
                                    "unfit": unfit,
                                    "bdrawn": bdrawn,
                                    "signature": signature,
                                    "bgno": bgno,
                                    "signbto": signbto,
                                    "id": id,
                                    "abo": abo,
                                    "rh": rh,
                                    "donr_no": donr_no,
                                    "isUpdateValue": isUpdateValue
                                }),
                            contentType: "application/json; charset=utf-8",
                            dataType: "json",
                            success: function (response) {
                                var master_id = response.d;
                                if (master_id != '-1') {
                                    Swal.fire({
                                        icon: 'success',
                                        title: 'Success!',
                                        text: 'Data has been saved successfully',
                                        showConfirmButton: false,
                                        timer: 2500,
                                        customClass: {
                                            popup: 'swal-big-popup',
                                            title: 'swal-big-title',
                                            htmlContainer: 'swal-big-text'
                                        }
                                    });

                                    window.location.href = "Donors.aspx?ID=" + master_id;
                                    $('#hdnUpdateVal').prop('value', master_id);
                                    $('#btnSaveSecondTab').val('Update');
                                    donor_Saved = 1;
                                    var value = $('#btnSaveTabFirst').val();
                                    if (value == "Update") {
                                        window.location.href = "Donors.aspx?ID=" + master_id;
                                    }
                                }

                            }
                            , error: function () {

                            }
                        });
                    }
                    else {
                       

                    }
                }
                    , 100);
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
            debugger;
            $('#ctl00_MainContent_txtPatient_ID').tokenInput("../../json.aspx?Table=PatientsForDonor",
                {

                    tokenLimit: 1,
                    onAdd: function (item) {
                        try {
                            $("#hdfPatient_ID").val(item.id);

                            loadAjax();
                            //loadReferenceInformation();
                        }
                        catch (err) {
                            alert(err.message);
                        }

                    }
                });
        }
        function ReplaceNullWith_Space(Data) {
            if (Data == "null")
                return " ";
            else
                return Data;
        }
        $(function () {
            $("#tabs").tabs();
        });
        function OnSuccess(data) {
            if (data.d != '') {
                var mydate = new Date(Date.parse(data.d.Entry_Date));
                var dateR = mydate.toLocaleDateString();

                $('#<%= vLbl_RegDate.ClientID %>').text(dateR);
                $('#<%= vlblPatients_Name.ClientID %>').text(data.d.Name);


            }
        }
        function loadAjax() {
            var Patient_ID = $("#<%= hdfPatient_ID.ClientID %>").val();
            console.log(Patient_ID);
                $.ajax({
                    type: "POST",
                    url: "Donors.aspx/GetDetail",
                    data: "{'PatientID':" + Patient_ID + "}",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: OnSuccess,
                    failure: function (response) {


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
        <div class="col-lg-2 col-md-4 cl-sm-6">
            <asp:Label ID="lblPatien_ID" runat="server" Text="MR No *"></asp:Label>
            <asp:TextBox ID="txtPatient_ID" runat="server"></asp:TextBox>
            <asp:RequiredFieldValidator ID="rfvPatient_ID" runat="server" ErrorMessage="Enter Patient ID" Text="*" ControlToValidate="txtPatient_ID" ForeColor="Red"></asp:RequiredFieldValidator>
        </div>
        <div class="col-lg-2 col-md-4 col-sm-6">
            <asp:Label ID="Label1" runat="server" Text="Donor ID:"></asp:Label>
            <asp:TextBox ID="txtDonorno" runat="server"></asp:TextBox>
        </div>
        <div class="col-lg-1 col-md-4 col-sm-6">
            <asp:Label ID="lblPatient_Name" runat="server" Text="Patient Name :"></asp:Label>
            </div>
        <div class="col-lg-1 col-md-4 col-sm-6">
            <asp:Label ID="vlblPatients_Name" runat="server"></asp:Label>
        </div>
        <div class="col-lg-1 col-md-4 col-sm-6">
            <asp:Label ID="LblReg_Date" runat="server" Text="Reg. Date:"></asp:Label>
            </div>
        <div class="col-lg-1 col-md-4 col-sm-6">
        <asp:Label ID="vLbl_RegDate" runat="server"></asp:Label>
            </div>
        <div class="col-lg-1 col-md-4 col-sm-6">
            <label id="lblcheckboxoutdoor" style="margin-top:19px" name="lblcheckboxoutdoor">(OutDoor)</label>
        </div>
        <div class="col-lg-1 col-md-4 col-sm-6">
            <label></label>
            <input type="checkbox" id="checkoutdoor" name="checkoutdoor" onclick="abc()" />
        </div>
    </div>

   
    <div style="width: 100%">
        <div id="tabs">
            <ul>
                <li><a href="#Tab-1">First</a></li>
                <li><a href="#Tab-2">Second</a></li>
            </ul>


            <div id="Tab-1">
                <div class="table-container">
                    <div class="row">
                        <div class="col-lg-2 col-md-6 col-sm-6">
                            <asp:Label ID="lblDonorName" runat="server" Text="Donor Name : *"></asp:Label>
                            <asp:TextBox ID="txtDonorName" runat="server"></asp:TextBox>
                        </div>
                        <div class="col-lg-2 col-md-6 col-sm-6">
                            <asp:Label ID="lblRelation" runat="server" Text="S/O,D/O,W/Os *"></asp:Label>
                            <asp:TextBox ID="txtRelation" runat="server"></asp:TextBox>
                        </div>
                        <div class="col-lg-2 col-md-6 col-sm-6">
                            <asp:Label ID="lblAdress" runat="server" Text="Address/Phn No. : *"></asp:Label>
                            <asp:TextBox ID="txtAdressNo" runat="server"></asp:TextBox>
                        </div>
                        <div class="col-lg-2 col-md-6 col-sm-6">
                            <asp:Label ID="lblAgeSex" runat="server" Text="Age/Sex *"></asp:Label>
                            <asp:TextBox ID="txtAgeSex" runat="server"></asp:TextBox>
                        </div>
                        <div class="col-lg-2 col-md-6 col-sm-6">
                            <asp:Label ID="lblOccuption" runat="server" Text="Occuption *"></asp:Label>
                            <asp:TextBox ID="txtOccuption" runat="server" Text=""></asp:TextBox>
                        </div>
                        <div class="col-lg-2 col-md-6 col-sm-6">
                            <asp:Label ID="lblStateHealth" runat="server" Text="State Of Health *"></asp:Label>
                            <asp:TextBox ID="txtStateHealth" runat="server" Text=""></asp:TextBox>
                        </div>
                    </div>
                    <br />
                    <div class="row">
                        <div class="col-lg-2 col-md-6 col-sm-6">
                            <asp:Label ID="lblDateDonation" runat="server" Text="Date Of Last Donation *"></asp:Label>
                            <asp:TextBox ID="txtDateDonation" runat="server"></asp:TextBox>
                            <asp:CheckBox ID="chkFirstTime" runat="server" />
                        </div>
                        <div class="col-lg-2 col-md-6 col-sm-6">
                            <asp:Label ID="lblCenterDuration" runat="server" Text="Center Of Donation *"></asp:Label>
                            <asp:TextBox ID="txtCenterDuration" runat="server"></asp:TextBox>
                        </div>
                        <div class="col-lg-2 col-md-6 col-sm-6">
                            <asp:Label runat="server" Text="CNIC *"></asp:Label>
                            <asp:TextBox ID="txtCNIC" runat="server"></asp:TextBox>
                        </div>
                        <div class="col-lg-2 col-md-6 col-sm-6">
                            <asp:Label runat="server" Text="No of Bags"></asp:Label>
                            <input type="text" name="txt_bagsqty" id="txt_bagsqty" value="1" />
                        </div>
                        <div class="col-lg-2 col-md-6 col-sm-6">
                            <asp:Label runat="server" Text="WEIGHT"></asp:Label>
                            <input type="text" name="others" id="txtothers" />
                        </div>
                    </div>

                    
                </div>
                <div class="table-container">
                    <h2>Donor Medical History</h2>
                    <div class="table-responsive">
                        <table class="table table-striped table-hover responstable">
                            <tbody>
                                <tr>
                                    <td>Heart Disease: *</td>
                                    <td>Yes
                                     <input type="checkbox" name="check1" id="yheartdis" style="position: relative; top: -16px;" />
                                        No
                                        <input type="checkbox" name="check1" id="nheartdis" style="position: relative; top: -16px;" />
                                    </td>
                                    <td>Tattooing: *</td>
                                    <td>Yes
                                        <input type="checkbox" name="check5" id="ytattoo" style="position: relative; top: -16px;" />
                                        No
                                        <input type="checkbox" name="check5" id="ntattoo" style="position: relative; top: -16px;" />
                                    </td>
                                    <td>Imprisonment: *</td>
                                    <td>Yes
                                        <input type="checkbox" name="check7" id="yimprison" style="position: relative; top: -16px;" />
                                        No
                                        <input type="checkbox" name="check7" id="nimprison" style="position: relative; top: -16px;" />
                                    </td>
                                </tr>

                                <tr>
                                    <td>Epilepsy: *</td>
                                    <td>Yes
                                        <input type="checkbox" name="check9" id="yepi" style="position: relative; top: -16px;" />
                                        No
                                        <input type="checkbox" name="check9" id="nepi" style="position: relative; top: -16px;" />
                                    </td>
                                    <td>Acupuncture: *</td>
                                    <td>Yes
                                        <input type="checkbox" name="check11" id="yacu" style="position: relative; top: -16px;" />
                                        No
                                        <input type="checkbox" name="check11" id="nacu" style="position: relative; top: -16px;" />
                                    </td>
                                    <td>Malaria: *</td>
                                    <td>Yes
                                        <input type="checkbox" name="check13" id="ymal" style="position: relative; top: -16px;" />
                                        No
                                        <input type="checkbox" name="check13" id="nmal" style="position: relative; top: -16px;" />
                                    </td>
                                </tr>

                                <tr>
                                    <td>Hypertension: *</td>
                                    <td>Yes
                                        <input type="checkbox" name="check15" id="yhyper" style="position: relative; top: -16px;" />
                                        No
                                        <input type="checkbox" name="check15" id="nhyper" style="position: relative; top: -16px;" />
                                    </td>
                                    <td>Ear & Nose Piercing: *</td>
                                    <td>Yes
                                        <input type="checkbox" name="check17" id="yenp" style="position: relative; top: -16px;" />
                                        No
                                        <input type="checkbox" name="check17" id="nenp" style="position: relative; top: -16px;" />
                                    </td>
                                    <td>Tuberculosis: *</td>
                                    <td>Yes
                                        <input type="checkbox" name="check19" id="ytuber" style="position: relative; top: -16px;" />
                                        No
                                        <input type="checkbox" name="check19" id="ntuber" style="position: relative; top: -16px;" />
                                    </td>
                                </tr>

                                <tr>
                                    <td>Syncopal Attack: *</td>
                                    <td>Yes
                                        <input type="checkbox" name="check21" id="ysyn" style="position: relative; top: -16px;" />
                                        No
                                        <input type="checkbox" name="check21" id="nsyn" style="position: relative; top: -16px;" />
                                    </td>
                                    <td>Recent Hospitalization: *</td>
                                    <td>Yes
                                        <input type="checkbox" name="check23" id="yrh" style="position: relative; top: -16px;" />
                                        No
                                        <input type="checkbox" name="check23" id="nrh" style="position: relative; top: -16px;" />
                                    </td>
                                    <td>Diabetes: *</td>
                                    <td>Yes
                                        <input type="checkbox" name="check25" id="ydiabetes" style="position: relative; top: -16px;" />
                                        No
                                        <input type="checkbox" name="check25" id="ndiabetes" style="position: relative; top: -16px;" />
                                    </td>
                                </tr>

                                <tr>
                                    <td>Jaundice: *</td>
                                    <td>Yes
                                        <input type="checkbox" name="check27" id="yjaun" style="position: relative; top: -16px;" />
                                        No
                                        <input type="checkbox" name="check27" id="njaun" style="position: relative; top: -16px;" />
                                    </td>
                                    <td>Visit Abroad: *</td>
                                    <td>Yes
                                        <input type="checkbox" name="check29" id="yvisit" style="position: relative; top: -16px;" />
                                        No
                                        <input type="checkbox" name="check29" id="nvisit" style="position: relative; top: -16px;" />
                                    </td>
                                    <td>Bleeding Disorder: *</td>
                                    <td>Yes
                                        <input type="checkbox" name="check31" id="ybleed" style="position: relative; top: -16px;" />
                                        No
                                        <input type="checkbox" name="check31" id="nbleed" style="position: relative; top: -16px;" />
                                    </td>
                                </tr>

                                <tr>
                                    <td>Previous Transfusion: *</td>
                                    <td>Yes
                                        <input type="checkbox" name="check33" id="yprevious" style="position: relative; top: -16px;" />
                                        No
                                        <input type="checkbox" name="check33" id="nprevious" style="position: relative; top: -16px;" />
                                    </td>
                                    <td>Addiction: *</td>
                                    <td>Yes
                                        <input type="checkbox" name="check35" id="yaddi" style="position: relative; top: -16px;" />
                                        No
                                        <input type="checkbox" name="check35" id="naddi" style="position: relative; top: -16px;" />
                                    </td>
                                    <td>Asthma: *</td>
                                    <td>Yes
                                        <input type="checkbox" name="check37" id="yasthma" style="position: relative; top: -16px;" />
                                        No
                                        <input type="checkbox" name="check37" id="nasthma" style="position: relative; top: -16px;" />
                                    </td>
                                </tr>

                                <tr>
                                    <td>Recent Surgery: *</td>
                                    <td>Yes
                                        <input type="checkbox" name="check39" id="yrs" style="position: relative; top: -16px;" />
                                        No
                                        <input type="checkbox" name="check39" id="nrs" style="position: relative; top: -16px;" />
                                    </td>
                                    <td>Unusual Sexual Practice: *</td>
                                    <td>Yes
                                        <input type="checkbox" name="check41" id="yusp" style="position: relative; top: -16px;" />
                                        No
                                        <input type="checkbox" name="check41" id="nusp" style="position: relative; top: -16px;" />
                                    </td>
                                    <td>Recent Immunization: *</td>
                                    <td>Yes
                                        <input type="checkbox" name="check43" id="yimmu" style="position: relative; top: -16px;" />
                                        No
                                        <input type="checkbox" name="check43" id="nimmu" style="position: relative; top: -16px;" />
                                    </td>
                                </tr>

                                <tr>
                                    <td>Tooth Extraction: *</td>
                                    <td>Yes
                                        <input type="checkbox" name="check45" id="ytooth" style="position: relative; top: -16px;" />
                                        No
                                        <input type="checkbox" name="check45" id="ntooth" style="position: relative; top: -16px;" />
                                    </td>
                                    <td>Food Taken: *</td>
                                    <td>Yes
                                        <input type="checkbox" name="check47" id="yfood" style="position: relative; top: -16px;" />
                                        No
                                        <input type="checkbox" name="check47" id="nfood" style="position: relative; top: -16px;" />
                                    </td>
                                    <td>Allergies: *</td>
                                    <td>Yes
                                        <input type="checkbox" name="check49" id="yallergies" style="position: relative; top: -16px;" />
                                        No
                                        <input type="checkbox" name="check49" id="nallergies" style="position: relative; top: -16px;" />
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
                <h2>Donor Consent:</h2>
                <p>
                    I have been informed with all related information of blood donation. I here by grant my permission
            <br/>
                    to the staff of this blood bank to withdraw my Blood/Single Donor Platelets suggested by the blood
            <br/>
                    Tranfusion Officer:
                </p>

                <div class="table-container">
                    <!-- Responsive Table -->
                        <div class="row">
                            <div class="col-lg-2 col-md-4 col-sm-6">
                                <label>Cell: *</label>
                                <input type="text" name="cell" id="txtcell" class="form-control" />
                            </div>
                            <div class="col-lg-8 col-md-4 col-sm-6"></div>
                            <div class="col-lg-2 col-md-4 col-sm-6">
                                <label>Signature of Donor: *</label>
                                <input type="text" name="signature" id="txtsignature" class="form-control" />
                            </div>
                        </div>
                </div>
                <div class="row">
                    <div class="col-lg-8 col-md-8 col-sm-8">
                        <div class="row">
                            <div class="col-lg-2 col-md-4 col-sm-12">
                                <input type="button" class="btn btn-yellow" id="btnSaveTabFirst" value="Save" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div id="Tab-2">
                <div class="row">
                    <div class="col-lg-2 col-md-4 col-sm-6">
                        <label>ABO group *</label>
                        <select name="abgroup" id="ddlabgroup" class="form-control"></select>
                    </div>
                    <div class="col-lg-2 col-md-4 col-sm-6">
                        <label>Rh Type *</label>
                        <select name="rhtype" id="ddlrhtype" class="form-control"></select>
                    </div>
                    <div class="col-lg-2 col-md-4 col-sm-6">
                        <label>Pulse *</label>
                        <input type="text" name="pulse" id="txtpulse" class="form-control"/>
                        </div>
                    <div class="col-lg-2 col-md-4 col-sm-6">
                        <label>BP *</label>
                        <input type="text" name="bp" id="txtbp" class="form-control"/>
                        </div>
                     <div class="col-lg-2 col-md-4 col-sm-6">
                         <label>Temp *</label>
                         <input type="text" name="temp" id="txttemp" class="form-control"/>
                         </div>
                    <div class="col-lg-2 col-md-4 col-sm-6">
                        <label>HB/HCT *</label>
                        <input type="text" name="hb" id="txthb" class="form-control"/>
                        </div>
                </div>

                <div class="row">
                    <div class="col-lg-2 col-md-4 col-sm-6">
                        <label>HBS AG *</label>
                        <select id="ddlhbs" name="ddlhbs" class="form-control" onchange="Result();"></select>
                    </div>
                    <div class="col-lg-2 col-md-4 col-sm-6">
                        <label>HCV (AB) *</label>
                         <select id="ddlHCV" name="ddlHCV" class="form-control" onchange="Result();"></select>
                        </div>
                    <div class="col-lg-2 col-md-4 col-sm-6">
                        <label>HIV 1/2 *</label>
                         <select id="ddlHiV" name="ddlHiV" class="form-control" onchange="Result();"></select>
                        </div>
                    <div class="col-lg-2 col-md-4 col-sm-6">
                        <label>VDRL *</label>
                        <select id="ddlvdrl" name="ddlvdrl" class="form-control" onchange="Result();"></select>
                    </div>
                    <div class="col-lg-2 col-md-4 col-sm-6">
                        <label>MP *</label>
                        <select id="ddlmp" name="ddlmp" class="form-control" onchange="Result();"></select>
                        </div>
                    <div class="col-lg-2 col-md-4 col-sm-6">
                        <label>Time & Type of Food Last Taken *</label>
                        <input type="text" name="foodtime" id="txtfoodtime" class="form-control"/>
                    </div>
                    </div>
                <div class="row">
                    <div class="col-lg-2 col-md-4 col-sm-6">
                       <label> Amount of Blood to be Drawn *</label>
                        <input type="text" name="blood" id="txtblood" class="form-control"/>
                    </div>
                    <div class="col-lg-2 col-md-4 col-sm-6">
                        <label>Signature of Blood Transfusion Officer *</label>
                         <input type="text" name="sign" id="txtsign" class="form-control"/>
                        </div>
                    <div class="col-lg-2 col-md-4 col-sm-6">
                        <label>Remarks *</label>
                        <label style="margin-left:16%">
                            <input type="checkbox" name="checkf" id="yfit" />
                            FIT</label>
                        <label>
                            <input type="checkbox" name="checkf" id="nunfit" />
                            UNFIT</label>
                    </div>
                    </div>
                </div>
               
            <div class="row mrgn">
                <div class="col-lg-2 col-md-4 col-sm-6">
                <h2>Donation Record</h2>
                </div>
                </div>
            <div class="row mrgn">
                <div class="col-lg-2 col-md-4 col-sm-6">
                    <label>DATE *</label>
                    <input type="text" name="date" id="txtdate" />
                </div>
                <div class="col-lg-2 col-md-4 col-sm-6">
                    <label>BLOOD DRAWN *</label>
                    <input type="text" name="blooddrawn" id="txtbdrawn" />
                </div>
                <div class="col-lg-2 col-md-4 col-sm-6">
                    <label>BAG NO. *</label>
                    <input type="text" name="bagno" id="txtbgno" />
                </div>
                <div class="col-lg-2 col-md-4 col-sm-6">
                    <label>SIGNATURE BTO *</label>
                    <input type="text" name="signbto" id="txtsignbto" />
                </div>
            </div>
            <div class="row">
                <div class="col-lg-8 col-md-4 col-sm-6">
                    <div class="row mrgn">
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <input type="button" id="btnSaveSecondTab" class="btn btn-yellow" value="Save" />
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <br />
        <div class="row">
            <div class="col-lg-8 col-md-4 col-sm-6">
                <div class="row">
                    <div class="col-lg-2 col-md-4 col-sm-12">
                        <input type="button" value="View" class="btn btn-yellow" onclick="redirect()" id="btnRedirect" />
                    </div>
                    <div class="col-lg-2 col-md-4 col-sm-12">
                        <input type="button" value="Print" class="btn btn-yellow" onclick="prints()" id="btnPrint" />
                    </div>
                </div>
            </div>
        </div>
    <asp:HiddenField ID="hdfPatient_ID" Value="(New)" runat="server" ClientIDMode="Static" />
    <asp:HiddenField ID="hdnUpdateVal" Value="(New)" runat="server" ClientIDMode="Static" />
</asp:Content>
