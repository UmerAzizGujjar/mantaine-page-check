<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="BloodBank.aspx.cs" Inherits="PMS.BloodBank" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script type="text/javascript">
        function abc()
        {


            var isTrue = $('#chkCustomer').is(':checked');
            if (isTrue) {

                var fghjh = 'Outdoor';
                $('#token-input-txtPatient_ID').val(fghjh);


                $('#token-input-txtPatient_ID').attr('disabled', true);
                $('#txtName').show();


               

            }
            if (isTrue == false) {
                $('#token-input-txtPatient_ID').val('');
                $('#token-input-txtPatient_ID').attr('disabled', false);
                $('#txtName').hide();


            }
        }

        var isBagFree = false;
        $(document).ready(function () {
            $('#bagrecv_chck').prop('disabled', true);
            $('#bagrecv_chck').on('change', function () {
                var id = $(this).prop('checked');
                if (id == true)
                {
                    isBagFree = true;
                    $('#btnSave').attr('disabled', false)
                }
                else {
                    isBagFree = false;
                     var ID = '<%= Request.QueryString["ID"]%>'
                    if (ID != "")
                    {

                        $('#btnSave').attr('disabled', true)
                    }
                }



            });
            $('#txtName').hide();
            $("#lblComponents").hide();
            $("#ddlComponents").hide();
            fillabotype();
            fillrhtype();
            fillDoantion();



                           <% if (Request.QueryString["ID"] != null)
                              { %>
            var ID = '<%= Request.QueryString["ID"]%>'
            //            fillbagnumber();
            $('#bagrecv_chck').prop('disabled', false);
            LoadBloodData(ID);
            <% } %>

            var ID = '<%= Request.QueryString["ID"]%>'
            if (ID == "") {


                Getnewbloodnum();
            }
            else
            {
                $('#dllbagnum').attr('disabled', true);
                $('#ddlComponents').attr('disabled', true);
                $('#btnSave').attr('disabled', true)

            }


            

            bindControls();
            $('#dllbagnum').on("change", function () {
                getexpirydate();
                getComponents();

            });
            $('#ddlComponents').on('change', function () {

                var id = $(this).val();
                var bagnum = $('#dllbagnum :selected').text();
                getExDateDonor(id, bagnum);

            });

        });


        function bindControls() {

            var hdFile_ID = $("#hdfPatient_ID").val();
            if (hdFile_ID != "(New)" && hdfPatient_ID != null && hdfPatient_ID != "") {

                $('#txtPatient_ID').val();



               

                var Patient_ID = $('#txtPatient_ID').val();

                var tokendata = httpGet("json.aspx?Table=Patients&Record=Edit&q=" + Patient_ID);
                loadtokenInputs(JSON.parse(tokendata));
            }
               
            else {


                loadtokenInputsDefault();
            }


        }
        var Expiry_date = '';
        function getExDateDonor(id, bagno)
        {
            PageMethods.getExpiryDate(id, bagno, function (resp) {
                debugger;
                var data = JSON.parse(resp);

                var Expirydate = '';
                
                if (data.Expiry_Date == null || data.Expiry_Date == 'null')
                {
                    Expirydate = '';
                }
                else
                {
                    Expirydate = new Date(parseInt(data.Expiry_Date.substr(6)));
                    Expirydate = moment(Expirydate).format('L');
                }
                $('#txtExpiry_Date').val(Expirydate);
                Expiry_date = Expirydate;

            });
        }
        function httpGet(theUrl) {
            var xmlHttp = null;
            xmlHttp = new XMLHttpRequest();
            xmlHttp.open("GET", theUrl, false);
            xmlHttp.send(null);
            return xmlHttp.responseText;
        }

        function loadtokenInputsDefault() {


            $('#txtPatient_ID').tokenInput("../../json.aspx?Table=PatientsForDonor",
             {
                 tokenLimit: 1,
             });
        }

        function loadtokenInputs(data) {
            ;
            $("#txtPatient_ID").tokenInput("../../json.aspx?Table=Patients",
                {
                    prePopulate: data,
                    tokenLimit: 1,
                    onAdd: function (item) {
                        $("#hdfPatient_ID").val(item.id);
                    }
                });
        }



        function getbagnumgroupwise() {



            var abotype = $('#ddlBlood_Group').val();
            if (abotype == "Please Select") {
                return false;
            }
            var rhtype = $('#ddlrhtype').val();
            if (rhtype == "Please Select") {
                return false;
            }


            optionsVen = '<option>Please Select</option>';

            PageMethods.getbagnumbygroup(abotype, rhtype, function (resp) {
                var data = JSON.parse(resp);


                $.each(JSON.parse(resp), function (key, value) {
                    debugger;
                    if (value.SumQty == "0") {

                    }
                    else {
                        debugger;
                       
                        optionsVen += '<option value="' + value.D_bagno + '" >' + value.D_bagno + '</option>';
                       
                    }
                });

                $("#dllbagnum").html(optionsVen);

                $("#dllbagnum").select2();



            },
            function (error) {
                alert(error.get_message());
            })
        }




        function getComponents(component) {
            debugger;
            var bagnum = $('#dllbagnum :selected').text();
            PageMethods.getComponents(bagnum, function (resp) {

                var optionsVen = '';
                var wholeBlood = '';
                var data = JSON.parse(resp);
                if (data == null) {
                    wholeBlood = "2";
                }
                else {
                    wholeBlood = data.Whole_Blood;
                }

                if (wholeBlood == "true" || wholeBlood == true) {
                    $("#lblComponents").hide();
                    $("#ddlComponents").hide();
                }
                else if (wholeBlood == "2") {

                    $("#lblComponents").hide();
                    $("#ddlComponents").hide();


                }
                else if (wholeBlood == "false" || wholeBlood == false) {
                        
                    $("#lblComponents").show();
                    $("#ddlComponents").show();

                }
                $.each(data.Components, function (key, value)
                {
                    debugger;
                    for (var i = 1; i <= value.Qty; i++)
                    {
                        debugger;
                        optionsVen += '<option value="' + value.Blood_Platelets_Id + '" >' + value.Blood_Platelets_Name + '</option>';
                    }
                    $("#ddlComponents").html(optionsVen);
                    if (typeof component === 'undefined') {
                        debugger;
                    }
                    else {
                        debugger;
                        $("#ddlComponents").val(component);
                    }

                    var id = $("#ddlComponents").val();
                    var bagnum = $('#dllbagnum :selected').text();
                    getExDateDonor(id, bagnum);

                });


            });

        }
        function getexpirydate() {


            var bagnum = $('#dllbagnum :selected').text();



            PageMethods.getexpiryofblood(bagnum, function (resp) {
                var data = JSON.parse(resp);
                var Expirydate = '';

                if (data.Expiry_Date == null || data.Expiry_Date == 'null') {
                    Expirydate = '';
                }
                else {
                    Expirydate = new Date(parseInt(data.Expiry_Date.substr(6)));
                    Expirydate = moment(Expirydate).format('L');
                }


                var rcvdate = new Date(parseInt(data.D_Date.substr(6)));
                rcvdate = moment(rcvdate).format('L');

                debugger;

                $("#txtExpiry_Date").val(Expirydate);
                $("#txtReceiving_Date").val(rcvdate);
            },
            function (error) {
                alert(error.get_message());
            })
        }


        function fillabotype() {

            var optionsVen = '';

            optionsVen = '<option>Please Select</option>';

            PageMethods.fillabotype(function (Tests) {


                $.each(JSON.parse(Tests), function (key, value) {

                    optionsVen += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                });

                $("#ddlBlood_Group").html(optionsVen);
            });
        }


        function fillrhtype() {

            var optionsVen = '';

            optionsVen = '<option>Please Select</option>';

            PageMethods.fillrhtype(function (Tests) {


                $.each(JSON.parse(Tests), function (key, value) {
                    ;
                    optionsVen += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                });

                $("#ddlrhtype").html(optionsVen);
            });
        }

        function fillDoantion() {

            var optionsVen = '';

            optionsVen = '<option>Please Select</option>';

            PageMethods.fillDoantion(function (Tests) {


                $.each(JSON.parse(Tests), function (key, value) {

                    optionsVen += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                });

                $("#ddldonation").html(optionsVen);
            });
        }




        function getsumofbloodbottle() {



            var abotype = $('#ddlBlood_Group').val();
            if (abotype == "Please Select") {
                return false;
            }
            var rhtype = $('#ddlrhtype').val();
            if (rhtype == "Please Select") {
                return false;
            }
            ;

            PageMethods.getsumofblood(abotype, rhtype, function (resp) {
                var data = JSON.parse(resp);

                if (data == null) data = 0;
                $("#txtAvailableBlood").val(data);

                getbagnumgroupwise();

            },
            function (error) {
                alert(error.get_message());
            })
        }


        var isProceed = true;
        var isExpired = true;
        function SaveAllRecord() {
            debugger;
            isProceed = true;
            isExpired = true;

            var status;
            var btnSave = $('#btnSave').val();
            var txtBlood_ID = $('#txtBlood_ID').val();
            var txtPatient_ID = '';
            var value = $("#chkCustomer").prop('checked');
            var name = $('#txtName').val();
            if (value == true) {
                ;
                txtPatient_ID = 0;
                if (name == "") {
                    isProceed = false;


                }
            }
            else {
                var patientid = $("#txtPatient_ID").val();
                if (patientid != "") {
                    txtPatient_ID = patientid;
                }


            }


            var txtAvailableBlood = $('#txtAvailableBlood').val();
            var ddlBlood_Group = $('#ddlBlood_Group').val();
            var txtBlood_Charges = $('#txtBlood_Charges').val();
            var txtExpiry_Date = $('#txtExpiry_Date').val();
            if (txtExpiry_Date == "") txtExpiry_Date = Expiry_date;
            var dllbagnum = $('#dllbagnum').val();
            var ddlrhtype = $('#ddlrhtype').val();
            var txtReceiving_Date = $('#txtReceiving_Date').val();
            var txtNo_Of_Bags = $('#txtNo_Of_Bags').val();
            var chkCustomer = $("#chkCustomer").prop('checked');
            var bagrecv_chck = $("#bagrecv_chck").prop('checked');
            var components = $('#ddlComponents').val();
            var donation = $('#ddldonation').val();
            if (donation === "Please Select") {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please select Donation value',
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
          
            var dateE = moment(txtExpiry_Date);
            var now = moment();

            if (dateE <= now) {

                isExpired = false;
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Blood Is Expired',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

            } else {
               
            }




            if (typeof components === 'undefined' || components == '') components = 0;
            if ($("#ddlBlood_Group").val().trim() == "Please Select" || $("#ddlrhtype").val().trim() == "Please Select" || $("#dllbagnum").val() == "Please Select" || $("#dllbagnum").val() == null || $("#txtBlood_Charges").val() == "") {
                debugger;
                if ($("#ddlBlood_Group").val().trim() == "Please Select") {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Please select ABO Type',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });
                    return true;
                }

                if ($("#ddlrhtype").val().trim() == "Please Select") {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Please select RH Type',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });
                    return true;
                }

                if ($("#txtBlood_Charges").val() == "") {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Please select Received By',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });
                    return true;
                }

                if ($("#dllbagnum").val() == "Please Select" || $("#dllbagnum").val() == null) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Please select Bag Number',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });
                    return true;
                }
            }
            var Patient_id = $('#txtPatient_ID').val();
            var outdoor = $('#token-input-txtPatient_ID').val();
            if (Patient_id == "" && outdoor != "Outdoor")
            {
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

                return true;

            }

            if (isProceed == true && isExpired == true)
            {
                $('#btnSave').attr('disabled', true);
                var AllItemDetail = { 'txtBlood_ID': txtBlood_ID, 'txtPatient_ID': txtPatient_ID, 'txtAvailableBlood': txtAvailableBlood, 'ddlBlood_Group': ddlBlood_Group, 'txtBlood_Charges': txtBlood_Charges, 'txtExpiry_Date': txtExpiry_Date, 'dllbagnum': dllbagnum, 'ddlrhtype': ddlrhtype, 'txtReceiving_Date': txtReceiving_Date, 'txtNo_Of_Bags': txtNo_Of_Bags, 'chkCustomer': chkCustomer, 'bagrecv_chck': bagrecv_chck, "components": components, "name": name, "donation": donation, "isBagFree": isBagFree };

                PageMethods.savedata(btnSave, JSON.stringify(AllItemDetail), function (res) {



                    if (bagrecv_chck == false || bagrecv_chck == "false" || bagrecv_chck == "False") {
                        Updatebloodbottlesrecord(res);
                    }
                    else
                    {
                        window.location = "BloodBank.aspx";
                    }
                   
                });
            }
            else {
                if (isProceed == false) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Please Provide Name from Outdoor person',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });

                }
                return true;
            }
        }


        function Getnewbloodnum()
        {
            PageMethods.Getnewbloodid(function (resp) {
                $('#txtBlood_ID').val(resp);
            },
            function (error)
            {
                alert(error.get_message());
            });
        }


        function LoadBloodData(ID) {
            debugger;
            PageMethods.loadheaderdata(ID, function (resp) {
                var data = JSON.parse(resp);
                var component = data.Component;
                var Recvdate = new Date(parseInt(data.Receiving_Date.substr(6)));
                Recvdate = moment(Recvdate).format('L');
                var ExpDate=data.Expiry_Date;
                if (ExpDate == null) {
                    ExpDate = '';
                }
                else {
                    ExpDate = new Date(parseInt(data.Expiry_Date.substr(6)));
                    ExpDate = moment(ExpDate).format('L');
                }
                var option = '<option value=' + data.VendorId + '>' + data.Vendor_Name + '</option>';

                $('#txtReceiving_Date').val(Recvdate);
                $('#txtExpiry_Date').val(ExpDate);


                $('#txtBlood_ID').val(data.Blood_ID);

                if (data.Patient_ID == 0) {

                    $('#token-input-txtPatient_ID').val('OutDoor');

                    $('#token-input-txtPatient_ID').attr('disabled', true);
                    $('#txtName').show();
                    $('#txtName').val(data.OutDoor_Person_Name);

                }

                else {


                    $('#txtPatient_ID').tokenInput('clear');
                    var tokenData = httpGet("../../json.aspx?Table=Patients&Record=Edit&q=" + data.Patient_ID);
                    var parsedData = JSON.parse(tokenData);
                    $('#txtPatient_ID').tokenInput("add", { id: JSON.parse(tokenData)[0].id, name: JSON.parse(tokenData)[0].name });
                }

              


                setTimeout(function () {
                    $('#ddlBlood_Group').val(data.Blood_Group).trigger('change');
                }, 1000);

                setTimeout(function () {
                    $('#ddlrhtype').val(data.RH_Type).trigger('change');
                }, 1000);
                setTimeout(function () {
                    $('#ddldonation').val(data.Donation).trigger('change');
                }, 1000);


               
                $('#txtBlood_Charges').val(data.Received_By);
              
                $('#txtNo_Of_Bags').val(data.No_Of_Bags);

                $('#txtAvailableBlood').val(data.Available_Blood);


                var checkwalkin = data.Walk_In_Customer;
                if (checkwalkin == true) {

                    $('#chkCustomer').prop('checked', true)
                }

                var checkrcvbag = data.Received_Bag;
                if (checkrcvbag == true) {

                    $('#bagrecv_chck').prop('checked', true)
                }

               



                setTimeout(function () {
                    debugger;
                   
                    var optionsVen = '<option value="' + data.Bag_No + '" >' + data.Bag_No + '</option>';
                    $("#dllbagnum").html(optionsVen);

                    $("#dllbagnum").select2();
                    getComponents(component);
                }, 3000);
              
                $('#btnSave').val('Update');


            },
            function (error) {
                alert(error.get_message());
            })
        }

        //   Updatebloodbottles

        function Updatebloodbottlesrecord(resp) {




            var bloodid = resp;

            PageMethods.updatebloodbottles(bloodid, function (Tests) {

                var message = JSON.parse(Tests);
                if (message[0].Message != null || message[0].Message != "") {
                    alert(message[0].Message);

                    window.location = "BloodBank.aspx";

                   
                }

            });
        }



    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
        <div class="col-lg-2 col-md-4 col-sm-6">
            <label id="lblBlood_ID">Blood ID </label>
            <input type="text" id="txtBlood_ID" name="txtBlood_ID" readonly="readonly" />
        </div>
        <div class="col-lg-2 col-md-4 col-sm-6">
            <label id="lblPatien_ID">Patient ID </label>
            <input type="text" id="txtPatient_ID" />
            <input type="hidden" id="hdfPatient_ID" value="(New)" />
        </div>
        <div class="col-lg-2 col-md-4 col-sm-6">
            <label id="lblBlood_Group">ABO Type *</label>
            <select id="ddlBlood_Group" onchange="getsumofbloodbottle()"></select>
        </div>
        <div class="col-lg-2 col-md-4 col-sm-6">
            <label id="lblrhtype">RH Type * </label>
            <select id="ddlrhtype" name="ddlrhtype" onchange="getsumofbloodbottle()"></select>
        </div>
        <div class="col-lg-1 col-md-3 col-sm-5">
            <label style="margin-top:20%">(OutDoor)</label>
            </div>
        <div class="col-lg-1 col-md-4 col-sm-6">
            <input type="checkbox" id="chkCustomer" onchange="abc()"  style="margin-left:-40%;margin-top:24%;"/>
        </div>
        <div class="col-lg-2 col-md-3 col-sm-5">
            <label></label>
            <input type="text" id="txtName" />
        </div>
        </div>
    <div class="row">
        <div class="col-lg-2 col-md-4 col-sm-6">
            <label id="lbldonation">Donation * </label>
            <select id="ddldonation" name="ddldonation"></select>
            </div>
        <div class="col-lg-2 col-md-4 col-sm-6">
              <label id="lblNo_Of_Bags">No. Of Bags *</label>
             <input type="text" id="txtNo_Of_Bags" value="1" disabled />
            </div>
        <div class="col-lg-2 col-md-4 col-sm-6">
            <label id="Label1">Received By </label>
            <input type="text" id="txtBlood_Charges" />
            </div>
        <div class="col-lg-2 col-md-4 col-sm-6">
             <label id="lblExpiry_Date">Expiry Date </label>
             <input type="text" id="txtExpiry_Date" readonly="readonly" />
            </div>
        <div class="col-lg-2 col-md-4 col-sm-6">
            <label id="lblReceiving_Date">Receiving Date </label>
            <input type="text" id="txtReceiving_Date" readonly="readonly" />
            </div>
        </div>
    <div class="row">
        <div class="col-lg-2 col-md-4 col-sm-6">
            <label id="lblbagnumber">Bag Number </label>
            <select id="dllbagnum" name="ddlbagnum"></select>
        </div>
        <div class="col-lg-2 col-md-4 col-sm-6">
            <label id="lblbagrecv">(Empty Bag Received)</label>
        </div>
        <div class="col-lg-1 col-md-4 col-sm-6">
            <input type="checkbox" id="bagrecv_chck" style="margin-left:-83% !important" />
            </div>
        <div class="col-lg-2 col-md-4 col-sm-6">
            <label id="lblComponents">Blood Components</label>
            <select id="ddlComponents" name="ddlComponents"></select>
            </div>
        <div class="col-lg-2 col-md-4 col-sm-6">
             <label id="lblavalblood" style="display: none;">Avalaible Blood</label>
            <input type="text" id="txtAvailableBlood" readonly="readonly" value="0" style="display: none;" />
            </div>
    </div>

  
    <div class="row">
        <div class="col-lg-8">
            <div class="row">
                <div class="col-lg-2 col-md-3 col-sm-5">
                    <input type="button" class="btn btn-yellow" value="New" id="btnNew" onclick="window.location = 'BloodBank.aspx'" />
                </div>
                <div class="col-lg-2 col-md-3 col-sm-5">
                    <input type="button" value="Back" class="btn btn-yellow" id="btnBack" onclick="window.location = 'BloodBank.aspx'" />
                </div>
                <div class="col-lg-2 col-md-3 col-sm-5">
                    <input type="button" value="Save" class="btn btn-primry" id="btnSave" onclick="SaveAllRecord()" />
                </div>
                <div class="col-lg-2 col-md-3 col-sm-5">
                    <input type="button" id="btnListView" class="btn btn-primry" name="btnListView" onclick="window.location = 'BloodBankView.aspx'" value="Save List View" />
                </div>
            </div>
        </div>
    </div>
    <div class="row">
        <label id="lblMessage"></label>
    </div>
</asp:Content>
