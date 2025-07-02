<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="DonorReceivingForm.aspx.cs" Inherits="PMS.DonorReceivingForm" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/Tibbit_theme/css/CustomCss/DonorReceiving.css" rel="stylesheet" />
    
    <script type="text/javascript">
        var wholeBlood = 30;
        function loadtokenInputsDefault() {
            debugger;
            $('#txtDonor').tokenInput("../../json.aspx?Table=Donor",
                {
                    tokenLimit: 1,
                    onAdd: function (item) {
                        try {
                            $('#hdfDonor_Id').val(item.id);
                            loadAjax(item.id);
                        }
                        catch (err) {
                            alert(err.message);
                        }
                    }
                });
        }

        function GetBloodChunks() {
            var options = '<option value="0">Please Select</option>';
            $.each(parsedData, function (key, value) {
                options += '<option value=' + value.Department_ID + '> ' + value.Department_Name + '</option>';
            });
            $('#ctl00_MainContent_ddlDepartment').html(options);
            $('#ctl00_MainContent_ddlDepartment').val(localStorage.DeptID);
        }

        function OnSuccess(data) {
            debugger;
            var response = JSON.parse(data.d);
            var date = '';
            if (response[0].Donor_LastDonation == null || response[0].Donor_LastDonation == 'null') {
                date = '';
            }
            else {
                date = $.datepicker.formatDate('mm/dd/yy', new Date(parseInt(response[0].Donor_LastDonation.substring(6, 19))))
            }
            if (response[0].Donor_Name == null) response[0].Donor_Name = '';
            if (response[0].Donor_relationship == null) response[0].Donor_relationship = '';
            if (response[0].Donor_Address == null) response[0].Donor_Address = '';
            if (response[0].Donor_Age == null) response[0].Donor_Age = '';
            if (response[0].Donor_Occupation == null) response[0].Donor_Occupation = '';
            if (response[0].Donor_StateHealth == null) response[0].Donor_StateHealth = '';
            if (response[0].ABO == null) response[0].ABO = '';
            if (response[0].Rh == null) response[0].Rh = '';
            $('#lblDonorName').text(response[0].Donor_Name);
            $('#lblRelationship').text(response[0].Donor_relationship);
            $('#lblAddress').text(response[0].Donor_Address);
            $('#lblage').text(response[0].Donor_Age);
            $('#lbloccupation').text(response[0].Donor_Occupation);
            $('#lblSOH').text(response[0].Donor_StateHealth);
            $('#lblABO').text(response[0].ABO);
            $('#lblRH').text(response[0].Rh);
            $('#lblDobation').text(date);
            $('#lblCenterDonation').text(response[0].Donor_CenterDonation);
            $('#lblBagNo').text(response[0].D_bagno);
            LoadBloodDOnationId(response[0].Donor_Id);
        }

        function LoadBloodDOnationId(Donor_ID) {
            debugger;
            if (Donor_ID != '') {

                PageMethods.GetDonorDivisionID(Donor_ID, function (res) {
                    debugger;
                   
                    donoresult(res);
                });
            }
        }

        function loadAjax(Donor_ID) {
          
            debugger;
            if (Donor_ID != '') {
                $.ajax({
                    type: "POST",
                    url: "DonorReceivingForm.aspx/GetDetail",
                    data: "{'Donor_ID':" + Donor_ID + "}",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: OnSuccess,
                    failure: function (response) {
                    }
                });
            }
        }
        function donoresult(id) {
            PageMethods.GetPlatelets(id, function (res) {
                debugger;
                var data = JSON.parse(res);
                var rows = '';
                var Div_Exp_Date = 'null';
                for (var i = 0; i < data.length; i++) {
                    var Exp_Date = data[i].Expired_Division_Date;
                    if (Exp_Date == null || Exp_Date == "null") {
                        Div_Exp_Date = "null";
                    }
                    else {
                        Div_Exp_Date = $.datepicker.formatDate('dd M yy', new Date(parseInt(data[i].Expired_Division_Date.substring(6, 19))));
                    }
                    rows += '<tr>' +
                        '<td style="display:none;">' + data[i].Blood_Platelets_Id + '</td>' +
                        '<td>' + data[i].Blood_Platelets_Name + '</td>' +
                        '<td><input type="text" value="' + data[i].Qty + '" name="Qty" style="height: 22px;width: 50px!important;"/></td>' +
                        '<td><input type="text" value="' + $.datepicker.formatDate('dd M yy', new Date(parseInt(data[i].Expiry_Date.substring(6, 19)))) + '" name="txtExpiryDate"  style="height: 22px;"/></td>' +
                        '<td> <input type="checkbox" id="chkIsExpired' + i + '" name="chkIsExpired"/></td>' +
                        '<td><input type="text" id="txtComment" name="txtComment" value="' + data[i].Comment + '" style="height: 22px;"/></td>' +
                        '<td><a href="#" id="linkdelete" onclick="Delete(this)">Delete</a></td>' +
                        '<td style="display:none;"><input type="hidden" id="orgnlQty" name="orgnlQty" value="' + data[i].Original_Qty + '"/> </td>' +
                        '<td style="display:none;"><input type="hidden" id="issueQty" name="issueQty" value="' + data[i].issue_Qty + '"/> </td>' +
                        '<td style="display:none;"><input type="hidden" id="issueDate" name="issueDate" value="' + data[i].Issue_Date + '"/> </td>' +
                        '<td style="display:none;"><input type="hidden" id="ExpiredDate" name="ExpiredDate" value="' + Div_Exp_Date + '"/> </td>' +
                        '</tr>';
                }
                $('#tblBloodChunks').append(rows);
                for (var i = 0; i < data.length; i++) {
                  
                    $('#chkIsExpired' + i + '').prop('checked', data[i].isExpired);
                }
                $("input[name='txtExpiryDate']").datepicker({ dateFormat: 'dd M yy' });


            });




        }
        function CallingList() {
            debugger;
            PageMethods.GetDonorList(function (res) {
                var item = JSON.parse(res);
                var rows = '';
                $.each(item, function (key, value) {
                    if (value.Donor_Name == null) value.Donor_Name = "";
                    if (value.Donor_Age == null) value.Donor_Age = "";
                    if (value.Donor_Occupation == null) value.Donor_Occupation = "";
                    if (value.ABO == null) value.ABO = "";
                    if (value.Rh == null) value.Rh = "";
                    if (value.Donor_No == null || value.Donor_No == "") value.Donor_No = "0";
                    rows += '<tr>' +
                        '<td>' + value.Donor_Id + '</td>' +
                        '<td>' + value.Donor_No + '</td>' +
                        '<td>' + value.D_bagno + '</td>' +
                        '<td>' + value.Donor_Name + '</td>' +
                        '<td>' + value.Donor_Age + '</td>' +
                        '<td>' + value.Donor_Occupation + '</td>' +
                        '<td>' + value.ABO + '</td>' +
                        '<td>' + value.Rh + '</td>' +

                        '<td><a href="#" id="linkdelete" onclick="Select(this)">Select</a></td>' +
                        '</tr>';
                });
                $('#tblDonorInformation').append(rows);
            });
        }

        function Delete(row) {
            $(row).closest('tr').remove();
        }

        var Donor_id = '';
        Date.prototype.toInputFormat = function () {
            var yyyy = this.getFullYear().toString();
            var mm = (this.getMonth() + 1).toString(); 
            var dd = this.getDate().toString();
            return yyyy + "-" + (mm[1] ? mm : "0" + mm[0]) + "-" + (dd[1] ? dd : "0" + dd[0]); // padding
        };

        var whole_Blood = '';
        var Create_Date = '';
        $(document).ready(function () {
            var id = '<%= Request.QueryString["ID"]%>';

            
            $("#txtExpDate").datepicker({ dateFormat: 'dd M yy' });
            var date = new Date();
            
            var days = parseInt(wholeBlood, 10);
            var current_Date_s = '';
            if (!isNaN(date.getTime())) {
                debugger;
                date.setDate(date.getDate() + days);
                current_Date_s = moment(date.toInputFormat()).format('D MMMM YYYY');
                $("#txtExpDate").val(current_Date_s);
                
            } else {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Invalid Date',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

            }

            append_ddl();
            $('#chkW').prop('checked', true);
           
            loadtokenInputsDefault();
           
            var id = '<%= Request.QueryString["ID"]%>';
            if (id != '') {
                $("table#tblDonorInformation").hide();
                $('#btnSave').val('Update');
                PageMethods.GetDonorID(id, function (res) {
                    debugger;
                    var Donor_id = res.split('-')[0];
                    var wholeBlood = res.split('-')[1];
                    whole_Blood = wholeBlood;
                    var Exp_Date = res.split('-')[2];
                    var isExpired = res.split('-')[3];
                    Create_Date = res.split('-')[5];
                    if (isExpired == "True") {
                        isExpired = true
                    }
                    else if (isExpired == "False") {
                        isExpired = false;
                    }
                    var comment = res.split('-')[4];
                    if (wholeBlood == "False") {
                        $('#chkW').prop('checked', false);
                        $("#showHide").show();
                        $("#txtExpDate").hide();
                        $("#lblExpired").hide();
                        $("#lblComment").hide();

                    }
                    else if (wholeBlood == "True") {
                        debugger;
                        $('#chkW').prop('checked', true);
                        $("#showHide").hide();
                        $("#txtExpDate").show();
                        $("#lblExpired").show();
                        $("#lblComment").show();

                        $("#txtExpDate").val(Exp_Date);
                        $("#chkIsExpired").prop('checked', isExpired);
                        $("#txtComment").val(comment);


                    }
                    var tokendata = httpGet("../../json.aspx?Table=Donor&q=" + Donor_id);
                    $('#txtDonor').tokenInput('clear');
                    $('#txtDonor').tokenInput("add", { id: JSON.parse(tokendata)[0].id, name: JSON.parse(tokendata)[0].id });
                });


            }

            if (id === "") {
                debugger;
                CallingList();
            }

            
            $('#chkW').change(function () {
                debugger;
                if (this.checked) {
                    $("#showHide").hide();
                    $("#txtExpDate").show();
                    $("#lblExpired").show();
                    $("#lblComment").show();

                    var date = new Date();
                   
                    var days = parseInt(wholeBlood, 10);
                    var current_Date_s = '';
                    if (!isNaN(date.getTime())) {
                        debugger;
                        date.setDate(date.getDate() + days);
                        current_Date_s = moment(date.toInputFormat()).format('D MMMM YYYY');
                        $("#txtExpDate").val(current_Date_s);
                      
                    } else {
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'Invalid Date',
                            showConfirmButton: false,
                            timer: 2000,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });

                    }

                }
                else {
                    $("#showHide").show();
                    $("#txtExpDate").hide();
                    $("#txtExpDate").val('');
                    $("#lblExpired").hide();
                    $("#lblComment").hide();

                }
            });

            $('#btnAdd').on('click', function () {
                var blood = $("#ddlBlood").val();
                if (blood == 0) return true;
                debugger;
                var isFalse = false;
                var Platelets_name = $('#ddlBlood :selected').text();
                var Platelets_id = $('#ddlBlood').val();
                var Fixed_day = $('#ddlBlood :selected').attr('name');

                $('#tblBloodChunks tbody tr:gt(0)').each(function () {
                    debugger;
                    var Platelets_id_compare = $(this).find('td:eq(0)').text();
                    if (Platelets_id == Platelets_id_compare) {
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: '"Selected value already exist',
                            showConfirmButton: false,
                            timer: 2000,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });
                        isFalse = true;
                        return false;
                    }
                });
                debugger;
                var date = new Date();
                var id = '<%= Request.QueryString["ID"]%>';
                if (id != "") {
                    debugger;
                    if (whole_Blood == "True") {
                        debugger;
                        date = new Date(Create_Date);

                    }

                }

               
                var days = parseInt(Fixed_day, 10);

                if (!isNaN(date.getTime())) {
                    debugger;
                    date.setDate(date.getDate() + days);
                    current_Date = moment(date.toInputFormat()).format('D MMMM YYYY');
                   
                } else {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Invalid Date',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });

                }
                var rows = '';

                rows += '<tr>' +
                    '<td style="display:none;">' + Platelets_id + '</td>' +
                    '<td>' + Platelets_name + '</td>' +
                    '<td><input type="text" value="1" name="Qty" style="height: 22px;width: 50px!important;" onchange="OrgnalQty(this)"/></td>' +
                    '<td style="padding-left: 0.6em;"><input type="text"  name="txtExpiryDate"  style="height: 22px;" value="' + current_Date + '"/>  </td>' +
                    '<td style="padding-left: 2.7em;"><input type="checkbox" id="chkIsExpired" name="chkIsExpired"/></td>' + '<td style="padding-left: 0.69em;"><input type="text" id="txtComment" name="txtComment" style="height: 22px;"/></td>' +
                    '<td><a href="#" id="linkdelete" onclick="Delete(this)">Delete</a></td>' +
                    '<td style="display:none;"><input type="hidden" id="orgnlQty" name="orgnlQty" value="1"/> </td>' +
                    '<td style="display:none;"><input type="hidden" id="issueQty" name="issueQty" value="0"/> </td>' +
                    '<td style="display:none;"><input type="hidden" id="issueDate" name="issueDate" value=""/> </td>' +
                    '<td style="display:none;"><input type="hidden" id="ExpiredDate" name="ExpiredDate" value=""/> </td>' +

                    '</tr>';
                if (isFalse == true) {
                }
                else {
                    $('#tblBloodChunks').append(rows);
                    $("input[name='txtExpiryDate']").datepicker({ dateFormat: 'dd M yy' });

                    isFalse = false;
                }
            });

            var isProceed = true;
            var isDetailExp = true;

            $('#btnSave').on('click', function () {
                debugger;
                $(this).attr("disabled", true);

                isProceed = true;
                isDetailExp = true;

                debugger;
                var btnValue = $("#btnSave").val();
                var donor_id = $('#txtDonor').val();
                var id = '<%= Request.QueryString["ID"]%>'
                if (id == "") id = 0;
                if (donor_id == '') {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Please Enter Donor',
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
                var length = $('#tblBloodChunks tr').length;
                if (length == 1) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Please Add Detail',
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
                var blood_check = false;
                var Expiry_date = $('#txtExpDate').val();
                var isExpiredMain = $('#chkIsExpired').prop('checked');
                var comment = $('#txtComment').val();
                var arr = [];
                if (blood_check == false) {
                    Expiry_date = "";
                    var table = $('#tblBloodChunks');
                    table.find('tbody tr:gt(0)').each(function (key, value) {
                        debugger;
                        var Type_id = $($(value).find('td')[0]).text();
                        var Platelets = $($(value).find('td')[1]).text();
                        var Qty = $(value).find('td input[name=Qty]').val();
                        var Exp_date = $(value).find('td input[name=txtExpiryDate]').val();
                        var IsExpired = $(value).find('td input[name=chkIsExpired]').prop('checked');
                        var Comment = $(value).find('td input[name=txtComment]').val();
                        var OrgnlQty = $(value).find('td input[name=orgnlQty]').val();
                        var issueQty = $(value).find('td input[name=issueQty]').val();
                        var issueDate = $(value).find('td input[name=issueDate]').val();
                        var ExpiredDate = $(value).find('td input[name=ExpiredDate]').val();
                        if (issueQty == null || issueQty == 'null') issueQty = 0;

                        if (Exp_date == "") {
                            isProceed = false;
                            isDetailExp = false;
                        }
                        arr.push({ 'Type_id': Type_id, 'Platelets': Platelets, 'Qty': Qty, 'Exp_date': Exp_date, 'IsExpired': IsExpired, 'Comment': Comment, 'OrgnlQty': OrgnlQty, 'issueQty': issueQty, 'issueDate': issueDate, 'ExpiredDate': ExpiredDate });
                    });
                }
                if (blood_check == true) {
                    if (Expiry_date == "") {
                        isProceed = false;
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'Please Add Expiry Date',
                            showConfirmButton: false,
                            timer: 2000,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });


                    }
                }
                debugger;
                if (isProceed == true) {


                    var data = {
                        'donor_id': donor_id, 'blood_check': blood_check, 'Expiry_date': Expiry_date, 'btnValue': btnValue, 'id': id,
                        'isExpiredMain': isExpiredMain, 'comment': comment, 'arr': arr
                    };
                    PageMethods.Save(JSON.stringify(data), function (res) {
                        var response = res;
                        window.location.href = "DonorReceivingForm.aspx?ID=" + response;
                    });
                }
                else {
                    if (isDetailExp == false) {
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'Please Select Expiry Date From Blood Component',
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
            });
        });     

        function append_ddl() {
            $.ajax({
                type: "POST",
                url: "DonorReceivingForm.aspx/appedddl",
                data: "",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var parsed_data = JSON.parse(response.d);
                    var row = '<option value="0">Please Select</option>';
                    $.each(parsed_data, function (key, value) {
                        row += '<option value="' + value.DataValue_Name + '" name="' + value.Segment1 + '" >' + value.DataValue_Description + '</option>';
                    });
                    $("#ddlBlood").html(row);
                }
            });
        }

        function OrgnalQty(row) {
            var Qty = $(row).val();
            $(row).closest('tr').find('input[name="orgnlQty"]').val(Qty);

        }

        function Select(row) {
            debugger;
            var Donor_ID = $($(row).closest('tr')[0]).find('td:eq(0)').text();
          
            var tokendata = httpGet("../../json.aspx?Table=Donor&q=" + Donor_ID);
            $('#txtDonor').tokenInput('clear');
            $('#txtDonor').tokenInput("add", { id: JSON.parse(tokendata)[0].id, name: JSON.parse(tokendata)[0].id });
           
            $("table#tblDonorInformation tr:gt(0)").remove();
            $("table#tblDonorInformation").hide();

        }

        function httpGet(theUrl) {
            var xmlHttp = null;
            xmlHttp = new XMLHttpRequest();
            xmlHttp.open("GET", theUrl, false);
            xmlHttp.send(null);
            return xmlHttp.responseText;
        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
<!-- Left Card -->
      <div class="col-lg-4 col-md-5 col-sm-12">
          <div class="card">
    <div class="card-body">
        <div class="row">
            <div class="col-lg-4 col-md-5 col-sm-6 text-center">
                <div class="image-container">
                    <img src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/Patient.png" alt="Patient Image" class="img-fluid rounded-circle patient-image" />
                </div>
            </div>
            <div class="col-lg-8 col-md-7 col-sm-6">
                <div class="row mb-3">
                    <div class="col-lg-5 col-md-5 col-sm-6 top">
                        <label>Search</label>

                    </div>
                    <div class="col-lg-7 col-md-7 col-sm-6 top">
                        <input type="text" id="txtDonor" />
                    </div>
                </div>
                <div class="row mb-3 mtt">
                    <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                       <label>Donor Name :</label>
                    </div>
                    <div class="col-lg-7 col-md-7 col-sm-6 top">
                        <label id="lblDonorName"></label>
                    </div>
                </div>
                <div class="row mb-3 mtt">
                    <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                        <label>S/O, D/O, W/Os :</label>
                        </div>
                    <div class="col-lg-7 col-md-7 col-sm-6 top">
                         <label id="lblRelationship"></label>
                    </div>
                </div>
                <div class="row mb-3 mtt">
                    <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                        <label>Address /Phone No:</label>
                    </div>
                    <div class="col-lg-7 col-md-7 col-sm-6 top">
                        <label id="lblAddress"></label>
                    </div>
                </div>
                <div class="row mb-3 mtt">
                    <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                        <label>Age / Sex :</label>
                    </div>
                    <div class="col-lg-7 col-md-7 col-sm-6 top">
                        <label id="lblage"></label>
                    </div>
                </div>
                <div class="row mb-3 mtt">
                    <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                        <label>Occuption :</label>
                    </div>
                    <div class="col-lg-7 col-md-7 col-sm-6 top">
                        <label id="lbloccupation"></label>
                    </div>
                </div>
            </div>
        </div>
    </div>
          </div>
      </div>
          <!-- Right Card -->
    <div class="col-lg-4 col-md-5 col-sm-12">
        <div class="card2">
            <div class="card-body">
                <div class="row mb-3">
                    <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                        <label>State Of Health :</label>
                    </div>
                    <div class="col-lg-5 col-md-5 col-sm-6">
                           <label id="lblSOH"></label>
                    </div>
                </div>

                <div class="row mb-3">
                    <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                          <label>ABO group :</label>
                    </div>
                    <div class="col-lg-7 col-md-5 col-sm-6">
                     <label id="lblABO"></label>
                    </div>
                </div>

                <div class="row mb-3">
                    <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                      <label>Rh Type :</label>
                    </div>
                    <div class="col-lg-7 col-md-5 col-sm-6 detail">
                        <label id="lblRH"></label>
                    </div>
                </div>
                <div class="row mb-3 mtt">
                    <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                        <label>Date Of Last Donation :</label>
                    </div>
                    <div class="col-lg-7 col-md-7 col-sm-6 top">
                      <label id="lblDobation"></label>
                    </div>
                </div>
                <div class="row mb-3 mtt">
                    <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                        <label>Center Of Donation :</label>
                    </div>
                    <div class="col-lg-7 col-md-7 col-sm-6 top">
                        <label id="lblCenterDonation"></label>
                    </div>
                </div>
                <div class="row mb-3 mtt">
                    <div class="col-lg-5 col-md-5 col-sm-6 formrgn1">
                        <label>Bag No :</label>
                    </div>
                    <div class="col-lg-7 col-md-7 col-sm-6 top">
                      <label id="lblBagNo"></label>
                    </div>
                </div>
            </div>
        </div>
    </div>

        <div class="col-lg-4 col-md-5 col-sm-12">
            <div class="table-responsive table-responsive-custom">
                <table id="tblDonorInformation" class="table table-bordered">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Donor #</th>
                            <th>Bag No</th>
                            <th>Name</th>
                            <th>Age</th>
                            <th>Occupation</th>
                            <th>ABO</th>
                            <th>RH Type</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody></tbody>
                </table>
            </div>
        </div>

        <div class="row">
            <div class="col-lg-12 col-md-4 col-sm-6">
                <div id="showHide">
                        <table id="tbldesign" style="width:100%">
                            <tr>
                                <td style="width: 14%;padding-left: 1%;padding-right: 1%;">
                                    <select id="ddlBlood" name="ddlBlood"  ></select></td>
                                <td>
                                    <input type="button" id="btnAdd" name="btnAdd"  value="Add" style="width:10% !important" class="btn btn-yellow" />
                                       </td>
                            </tr>
                        </table>
                    </div>
                </div>
            </div>

        

                    <div class="col-sm-12">
                        <div class="table-responsive">
                            <table id="tblBloodChunks" class="table responstable">
                                <thead>
                                    <tr>
                                        <th>Name</th>
                                        <th style="text-align: center;">Qty</th>
                                        <th style="text-align: center;">Expiry Date</th>
                                        <th style="text-align: center;">IsExpired</th>
                                        <th style="text-align: center;">Comments</th>
                                        <th style="text-align: center;">Actions</th>
                                    </tr>
                                </thead>
                                <tbody></tbody>
                            </table>
                        </div>
                    </div>
                </div>

    <div class="col-sm-6">
        <div class="col-lg-3 col-md-6 col-sm-6">
            <input type="button" name="btnSave" id="btnSave" class="btn btn-primry" value="Save" />
        </div>
        <div class="col-lg-3 col-md-6 col-sm-6">
            <input type="button" name="btnNew" id="btnNew" class="btn btn-yellow" value="New" onclick="window.location = 'DonorReceivingForm.aspx'" />
        </div>
        <div class="col-lg-3 col-md-6 col-sm-6">
            <input type="button" name="btnListView" id="btnListView" class="btn btn-yellow" onclick="window.location = 'DonorReceivingList.aspx'" value="List View" />
        </div>
    </div>

            <div class="col-sm-6">
                <li style="background: #cbe2e6; margin-left: -9px; border-radius: 1em; padding-left: 33px; display: none;">
                    <label for="Blood">
                        <h4 style="font-weight: bold;">Whole Blood</h4>
                    </label>
                    <input id="chkW" type="checkbox" value="test" />
                    <input type="text" id="txtExpDate" name="txtExpDate" />
                    <label for="chkIsExpired" id="lblExpired">
                        Expired
                        <input type="checkbox" id="chkIsExpired" /></label>
                    <label for="txtComment" id="lblComment">Comment<input type="text" id="txtComment" /></label>
                </li>
            </div>
          
            
    <input type="hidden" id="hdfDonor_Id" />
</asp:Content>
