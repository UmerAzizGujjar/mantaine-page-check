<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="StudentReceipt.aspx.cs" Inherits="PMS.Modules.StudentAffair.StudentReceipt" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/studentReceipt.css" rel="stylesheet" />
    <script type="text/javascript">

        $(document).ready(function () {
            GetStudentRollNos();


            $('#ddl_challan_nos').select2();
            $('#ddlStu_roll_no').select2();
            $('#ddlClass').select2();

            FillBank();
            $('#btnVoucher').hide();

            $('#ddl_bankCash').select2();
            $("#txtReceiptDate").datepicker({ dateFormat: 'mm/dd/yy' });
            $("#txtReceiptDate").val($.datepicker.formatDate('dd M yy', new Date()));
            //FillTokenInputForMRNo();


            var id = '<%= Request.QueryString["Stu_RecptID"]%>';

                if (id == "") {


                    $('#btnUnApprove').hide();
                    $('#btnApprove').hide();

                }

                if (id != "") {


                    var getstudentID = '<%= Request.QueryString["Stu_ID"]%>';

                    var Student_ID = getstudentID;
                }

                if (id != "") {
                    LoadMasterData(id);

                }

            });
        function httpGet(theUrl) {
            var xmlHttp = null;
            xmlHttp = new XMLHttpRequest();
            xmlHttp.open("GET", theUrl, false);
            xmlHttp.send(null);
            return xmlHttp.responseText;
        }
        function LoadStudentDetails(selectedClassID = null) {
            var StudentID = $('#ddlStu_roll_no').val();
            PageMethods.GetStudentDetails(StudentID, function (resp) {
                var data = JSON.parse(resp);
                $('#lblStudentName').text(data.Full_Name);
                $('#lblStuClass').text(data.StuClass);
                $('#lblFatherName').text(data.Father_Name);
                $('#lblAdmCategory').text(data.Program);
                $('#lblContactNo').text(data.Student_Contact_No);
                $('#lblSession').text(data.Sesion);

                PageMethods.GetStudentClasses(StudentID, function (classesResp) {
                    var classes = JSON.parse(classesResp);
                    var classOptions = '<option value="">Select Class</option>';
                    $.each(classes, function (index, cls) {
                        classOptions += '<option value="' + cls.ClassID + '">' + cls.ClassName + '</option>';
                    });
                    $('#ddlClass').html(classOptions);
                    if (selectedClassID) {
                        $('#ddlClass').val(selectedClassID);
                    }
                }, function (error) {
                    alert('Error loading classes: ' + error.get_message());
                });

                var checkid = '<%= Request.QueryString["Stu_RecptID"]%>';

                if (checkid == '') {
                    $('#tblDetails tbody').html('');
                }
            }, function (error) {
                alert(error.get_message());
            });
        }





        function FillBank() {

            var optionsBnk = '';

            PageMethods.GetBank(function (Tests) {

                optionsBnk = '<option value="0">Please Select</option>';
                $.each(JSON.parse(Tests), function (key, value) {

                    optionsBnk += '<option value="' + value.Account_ID + '" >' + value.name + '</option>';
                });
                $('#ddl_bankCash').html(optionsBnk);
            });
        }

        function FillChallanNos(stu_ID) {
            var challans = '';

            PageMethods.FillChallanNo(stu_ID, function (Tests) {
                challans = '<option value="0">Please Select</option>';
                $.each(JSON.parse(Tests), function (key, value) {
                    challans += '<option value="' + value.Seq_Challan_No + '" >' + value.Seq_Challan_No + '</option>';
                });
                $('#ddl_challan_nos').html(challans);
            });
        }


        function LoadStudentChild() {
            var StudentID = $('#ddlStu_roll_no').val();
            var ClassID = $('#ddlClass').val();

            if (!ClassID) {
                $('#tblDetails tbody').html('');
                return;
            }


            PageMethods.LoadStudentChilds(StudentID, ClassID, function (resp) {
                var data = (JSON.parse(resp));
                var rows = '';
                var rowIndex = 0; 
                selectedOptions = data;
                $.each(data, function (key, value) {
                    rowIndex = rowIndex + 1;
                    rows += '<tr>' +
                        '<td style="display:none;"><input type="hidden" style="width:100% !important;" readonly="readonly" name="stu_fee_childID" id="stu_fee_childID' + (key + 1) + '"  value="' + value.Student_Fee_Detail_ID + '" /></td>' +
                        '<td style="display:none;"><input type="text" readonly="readonly" id="txt_StudentID' + (key + 1) + '" name="txt_StudentID" value="' + value.Student_ID + '" /></td>' +
                        '<td style="display:none;"><input type="text" readonly="readonly" id="txt_AccountID' + (key + 1) + '" name="txt_AccountID" value="' + value.NetIncome_Acc_ID + '" /></td>' +
                        '<td>' + rowIndex + '</td>' +
                        '<td><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="glyphicon glyphicon-trash" style="font-size: 13px;margin-left: 40px; color: #f30a0a;position:relative;left: -33px;" i=""></i></a></td>' +
                        '<td><input type="text" style="width:100% !important;" readonly="readonly" name="txtfeeno" id="txtfeeno' + (key + 1) + '"  value="' + value.Fee_No + '" /></td>' +
                        '<td style="display:none;"><input type="text" style="width:100% !important;" readonly="readonly" name="feetypeid" id="feetypeid' + (key + 1) + '"  value="' + value.Fee_Type + '" /></td>' +
                        '<td><input type="text" style="width:100% !important;" readonly="readonly" name="txtfeetype" id="txtfeetype' + (key + 1) + '"  value="' + value.Fee_Type + '" /></td>' +
                        '<td><input type="text" style="width:100% !important;" readonly="readonly" name="txtamount" id="txtamount' + (key + 1) + '"  value="' + value.TotalAmount + '" /></td>' +
                        '<td style="display:none;"><input type="text" onkeyup="calculatetotal(this)" style="width:100% !important;" name="txtdiscamount" id="txtdiscamount' + (key + 1) + '" value="' + 0 + '" /></td>' +
                        '<td><input type="text" style="width:100% !important;" readonly="readonly" name="txtnetamount" id="txtnetamount' + (key + 1) + '" value="' + value.Payable_Fee + '" /></td>' +
                        '<td><input type="text" style="width:100% !important;" onkeyup="calculatetotal(this)" style="width:100% !important;" id="txtrecamount' + (key + 1) + '" name="txtrecamount" /></td>' +
                        '<td><input type="text" readonly="readonly" style="width:100% !important;" id="txtbal_amount' + (key + 1) + '" name="txtbal_amount" /></td>' +
                        '</tr>';
                });
                $('#tblDetails tbody').html(rows);

                $('#tblDetails tbody tr').each(function () {
                    var txtrecamountInput = $(this).find('input[name="txtrecamount"]');
                    if (txtrecamountInput.length) {
                        calculatetotal(txtrecamountInput[0]);
                    }
                });
            }, function (error) {
                alert(error.get_message());
            });
        }



        function ExcludeFromPayment(anchor) {
            var a = confirm("Are you sure You want to delete");
            if (a == true) {
                console.clear();
                var row = $(anchor).parents('tr')[0];
                row.remove();
            }
        }



        function calculatetotal(row) {


            var netamount = 0;
            var balanceamount = 0;
            var total_bal_amount = 0;

            var total_txtnet_amount = 0;

            var extradiscount = 0;

            var netpayable = 0;

            var total_disc_amount = 0;

            var total_rec_amount = 0;


            var extradiscountperc = 0;

            var txtamount = $(row).closest('tr').find('td input[name=txtamount]').val();

            if (txtamount == "") {

                txtamount = 0;
            }

            var txtdiscamount = $(row).closest('tr').find('td input[name=txtdiscamount]').val();

            if (txtdiscamount == "") {

                txtdiscamount = 0;
            }


            var txtrecamount = $(row).closest('tr').find('td input[name=txtrecamount]').val();

            if (txtrecamount == "") {

                txtrecamount = 0;
            }

            netamount = parseFloat(txtamount) - parseFloat(txtdiscamount);

            $(row).closest('tr').find('td:eq(6)').val(netamount);

            var txtnetamount = $(row).closest('tr').find('td input[name=txtnetamount]').val();

            balanceamount = parseFloat(txtnetamount) - parseFloat(txtrecamount);

            $(row).closest('tr').find('td input[name=txtbal_amount]').val(balanceamount);


            $.each($('#tblDetails tbody tr'), function (key, value) {
                var txtamount = $($(value).find('td input[name=txtamount]')[0]).val();

                var txtdiscamount = $($(value).find('td input[name=txtdiscamount]')[0]).val();

                var txtrecamount2 = $($(value).find('td input[name=txtrecamount]')[0]).val();


                var txtnetamount = $($(value).find('td input[name=txtnetamount]')[0]).val();


                if (txtnetamount == "") {

                    txtnetamount = 0;
                }

                if (txtdiscamount == "") {

                    txtdiscamount = 0;
                }

                if (txtrecamount2 == "") {

                    txtrecamount2 = 0;
                }


                total_bal_amount += parseFloat(txtamount);

                total_disc_amount += parseFloat(txtdiscamount);

                total_rec_amount += parseFloat(txtrecamount2);

                total_txtnet_amount += parseFloat(txtnetamount);





            });

            $('#txtTotalPayable').val(total_bal_amount.toFixed());

            $('#txtNetPayable').val(total_txtnet_amount.toFixed());

            $('#txtDisAmt').val(total_disc_amount.toFixed());
            $('#txtAmountReceived').val(total_rec_amount.toFixed());

            calculatetotal2();



        }

        function Voucher() {
            var id = '<%= Request.QueryString["Stu_RecptID"]%>';
            var locationInfo = window.location;
            var url = '/ReportViewer.aspx?ReportName=Voucher&ReportTitle=ACV Voucher&TransID=' + id + '&TransType=ACV';
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + '/ReportViewer.aspx?ReportName=Voucher&ReportTitle=ACV Voucher&TransID=' + id + '&TransType=ACV';
            }

            window.open(url, '_blank');
        }


        function calculatetotal2() {


            var netpayable = 0;

            var finalbalance = 0;

            var extradiscountperc = 0;


            var txtTotalPayable = $('#txtTotalPayable').val();

            var txtDisPer = $('#txtDisPer').val();

            var txtDisAmt = $('#txtDisAmt').val();

            extradiscountperc = txtDisAmt / txtTotalPayable * 100;

            $('#txtDisPer').val(extradiscountperc.toFixed(2));

            var txtDisAmt2 = $('#txtDisAmt').val();

            netpayable = parseFloat(txtTotalPayable) - parseFloat(txtDisAmt2);
            $('#txtBalances').val(netpayable.toFixed());

            var txtNetPayable = $('#txtNetPayable').val();

            var txtAmountReceived = $('#txtAmountReceived').val();

            if (txtAmountReceived == "") {

                txtAmountReceived = 0;
            }

            finalbalance = parseFloat(txtNetPayable) - parseFloat(txtAmountReceived);

            $('#txtBalances').val(finalbalance);
        }


        var ItemList = [];
        function SaveAllRecord() {

            var checkbankcash = $("#ddl_bankCash").val();


            if (checkbankcash == 0) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Select Cash/Bank',
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


            var status;
            var btnSave = $('#btnSave').val();
            var studentid = $("#ddlStu_roll_no").val();
            var Stu_recptNo = $('#txtReceiptNo').val();
            var txtTotalPayable = $('#txtTotalPayable').val();
            var txtDisPer = $('#txtDisPer').val();
            var txtDisAmt = $('#txtDisAmt').val();
            var txtNetPayable = $('#txtNetPayable').val();
            var txtAmountReceived = $('#txtAmountReceived').val();
            var txtBalances = $('#txtBalances').val();
            var txtReceiptDate = $('#txtReceiptDate').val();
            var txtRemarks = $('#txtRemarks').val();
            var ddl_bankCash = $('#ddl_bankCash').val();
            var txtStatus = $('#txtStatus').val();
            var txt_DocNo = $('#txt_DocNo').val();
            var Class = $('#ddlClass').val();

            var table = $('#tblDetailsbody');

            table.find('tr').each(function (key, value) {
                ItemList.push({
                    'txtamount': $(value).find('td input[name=txtamount]').val(), 'txtdiscamount': $(value).find('td input[name=txtdiscamount]').val(), 'txtnetamount': $(value).find('td input[name=txtnetamount]').val(), 'txtrecamount': $(value).find('td input[name=txtrecamount]').val(), 'txtbal_amount': $(value).find('td input[name=txtbal_amount]').val(), 'feetypeid': $(value).find('td input[name=feetypeid]').val(), 'txt_AccountID': $(value).find('td input[name=txt_AccountID]').val(), 'txtfeeno': $(value).find('td input[name=txtfeeno]').val(), 'stu_fee_childID': $(value).find('td input[name=stu_fee_childID]').val(),



                });
            });

            var AllItemDetail = { 'studentid': studentid, 'txt_DocNo': txt_DocNo, 'Class': Class, 'txtStatus': txtStatus, 'Stu_recptNo': Stu_recptNo, 'ddl_bankCash': ddl_bankCash, 'txtReceiptDate': txtReceiptDate, 'txtRemarks': txtRemarks, 'txtTotalPayable': txtTotalPayable, 'txtDisPer': txtDisPer, 'txtDisAmt': txtDisAmt, 'txtNetPayable': txtNetPayable, 'txtAmountReceived': txtAmountReceived, 'txtBalances': txtBalances, 'ItemList': ItemList };

            PageMethods.SaveStudentReceipt(btnSave, JSON.stringify(AllItemDetail), function (res) {

                Swal.fire({
                    icon: 'success',
                    title: 'Success!',
                    text: 'Data Saved Successfully',
                    showConfirmButton: false,
                    timer: 2500,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });


                var studentidfor_res = $("#ddlStu_roll_no").val();
                window.location = "StudentReceiptView.aspx";
                $('#btnSave').val("Update");



            });
        }

        function LoadMasterData(RecptID) {

            PageMethods.LoadHeaderData(RecptID, function (resp) {
                var data = JSON.parse(resp);
                var RecpDate = new Date(parseInt(data.Student_Receipt_Date.substr(6)));
                RecpDate = moment(RecpDate).format('L');

                $('#lblStudentName').text(data.Full_Name);
                $('#lblStuClass').text(data.StuClass);
                $('#lblFatherName').text(data.Father_Name);
                $('#lblAdmCategory').text(data.Program);
                $('#lblContactNo').text(data.Phone);
                $('#lblSession').text(data.Sesion);
                $('#lblStuClass').text(data.StuClass);

          
       



                setTimeout(function () {

                    $('#ddlStu_roll_no').val(data.Student_ID).trigger('change');


                }, 1000);

                setTimeout(function () {
                    $('#ddlStu_roll_no').val(data.Student_ID);
                    LoadStudentDetails(data.Class); 
                }, 1000);

                $('#txtReceiptNo').val(data.Student_Receipt_No);
                $('#txt_DocNo').val(data.Doc_No);
                $('#txtRemarks').val(data.Remarks);
                $('#txtReceiptDate').val(RecpDate);


                $('#txtStatus').val(data.Status);

                var status = $('#txtStatus').val();
                if (status == "Approved") {
                    $('#btnSave').attr("disabled", 'disabled');
                    $('#btnApprove').attr("disabled", 'disabled');
                    $('#btnApprove').hide();
                    $('#btnSave').hide();
                    $('#btnVoucher').show();

                    $('#btnUnApprove').attr("disabled", false);
                }
                if (status == "Created") {
                    $('#btnApprove').attr("disabled", false);
                    $('#btnUnApprove').attr("disabled", 'disabled');
                    $('#btnUnApprove').hide();

                    $('#btnVoucher').hide();


                }
                $('#ddl_bankCash').html(
                    $('<option>', {
                        value: data.Account_ID,
                        text: data.Accountid_text
                    })
                );
                $('#txtTotalPayable').val(data.Total_Payable);
                $('#txtDisPer').val(data.Disc_Perc);
                $('#txtDisAmt').val(data.Disc_Amount);
                $('#txtNetPayable').val(data.Net_Payable);
                $('#txtAmountReceived').val(data.Amount_Received);
                $('#txtBalances').val(data.Balance);

                LoadStudentChildEditMode(RecptID);

            },
                function (error) {
                    alert(error.get_message());
                })



        }







        function LoadStudentChildEditMode(RecptID) {

            PageMethods.LoadStudentChildDataEditMode(RecptID, function (resp) {
                var data = (JSON.parse(resp));
                var rows = '';
                var rowIndex = parseInt((parseInt($('#tblDetails tbody tr').length)));
                selectedOptions = data;
                $.each(data, function (key, value) {

                    rowIndex = rowIndex + 1;
                    rows += '<tr>' +

                        '<td style="display:none;"><input type="hidden" style="width:100% !important;" readonly="readonly" name="stu_fee_childID" id="stu_fee_childID' + (key + 1) + '"  value="' + value.Student_Fee_Detail_ID + '" /></td>' +



                        '<td style="display:none;"><input type="text" readonly="readonly" id="txt_StudentID' + (key + 1) + '" name="txt_StudentID" /></td>' +

                        '<td style="display:none;"><input type="text" readonly="readonly" id="txt_AccountID' + (key + 1) + '" name="txt_AccountID" value="' + value.Account_ID + '" /></td>' +


                        '<td>' + rowIndex + '</td>' +

                        '<td><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="glyphicon glyphicon-trash" style="font-size: 13px;margin-left: 40px; color: #f30a0a;position:relative;left: -33px;" i=""></i></a></td>' +



                        '<td><input type="text" style="width:100% !important;" readonly="readonly" name="txtfeeno" id="txtfeeno' + (key + 1) + '"  value="' + value.Fee_No + '" /></td>' +



                        '<td style="display:none;"><input type="text" style="width:100% !important;" readonly="readonly" name="feetypeid" id="feetypeid' + (key + 1) + '"  value="' + value.Fee_Type + '" /></td>' +



                        '<td><input type="text" style="width:100% !important;" readonly="readonly" name="txtfeetype" id="txtfeetype' + (key + 1) + '"  value="' + value.Fee_Type + '" /></td>' +


                        '<td><input type="text" style="width:100% !important;" readonly="readonly" name="txtamount" id="txtamount' + (key + 1) + '"  value="' + value.Amount + '" /></td>' +


                        '<td style="display:none;"><input type="text" onkeyup="calculatetotal(this)" style="width:100% !important;" name="txtdiscamount" id="txtdiscamount' + (key + 1) + '" value="' + 0 + '" /></td>' +

                        '<td><input type="text" style="width:100% !important;" readonly="readonly" name="txtnetamount" id="txtnetamount' + (key + 1) + '" value="' + value.Net_Amount + '" /></td>' +

                        '<td><input type="text" style="width:100% !important;" onkeyup="calculatetotal(this)" style="width:100% !important;" id="txtrecamount' + (key + 1) + '" name="txtrecamount" value="' + value.Rec_Amount + '" ></input></td>' +

                        '<td><input type="text" readonly="readonly" style="width:100% !important;" id="txtbal_amount' + (key + 1) + '" name="txtbal_amount" value="' + value.Balance_Amount + '" ></input></td>' +

                        '</tr>';
                });
                $('#tblDetails tbody').html(rows);
                $('#btnSave').val("Update");
            },
                function (error) {
                    alert(error.get_message());
                })

        }


        function Approve() {
            var RecptID = '<% =Request.QueryString["Stu_RecptID"] %>';
            PageMethods.ApproveReceipt(RecptID, function (Tests) {
                var message = JSON.parse(Tests);
                if (message[0].Message != null || message[0].Message != "") {
                    alert(message[0].Message);
                    location.reload();
                }

            });

        }



        function UnApprove() {
            var RecptID = '<% =Request.QueryString["Stu_RecptID"] %>';
            PageMethods.UnApproveReceipt(RecptID, function (Tests) {
                var message = JSON.parse(Tests);
                if (message[0].Column1 != "" || message[0].Column1 != null) {
                    alert(message[0].Column1);
                    location.reload();

                }
            });


        }
        function GetStudentRollNos() {

            var optionsVen = '<option value="0">Please Select</option>';

            PageMethods.GetStud_RollNos(function (Tests) {


                $.each(JSON.parse(Tests), function (key, value) {

                    optionsVen += '<option value="' + value.Student_Id + '" >' + value.Roll_No + '</option>';
                });
                $('#ddlStu_roll_no').html(optionsVen);
            });
        }



        function PrintVoucher() {
            var id = '<%= Request.QueryString["Stu_RecptID"]%>';
            var locationInfo = window.location;
            var url = '/ReportViewer.aspx?ReportName=Voucher&ReportTitle=SRV Voucher&TransID=' + id + '&TransType=SRV';
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + '/ReportViewer.aspx?ReportName=Voucher&ReportTitle=SRV Voucher&TransID=' + id + '&TransType=SRV';
            }
            //  window.location.href = url;
            window.open(url, '_blank');

        }



    </script>


</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <asp:HiddenField runat="server" ClientIDMode="Static" />
    <input type="hidden" name="hdnDuplicateCheck" value="0" id="hdnDuplicateCheck" />
    <div id="header">
        <div class="row">
            <div class="col-lg-6 col-md-5 col-sm-12">
                <div class="card">
                    <div class="card-body">
                        <div class="row">
                            <div class="col-lg-4 col-md-5 col-sm-6 text-center">
                                <div class="image-container">
                                    <img src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/Addrecepit.png" alt="Patient Image" class="img-fluid rounded-circle patient-image">
                                </div>
                            </div>
                            <div class="col-lg-8 col-md-7 col-sm-6">
                                <div class="row mb-3 mtt">
                                    <div class="col-lg-5 col-md-5 col-sm-6">
                                        <label>Roll No *:</label>
                                    </div>
                                    <div class="col-lg-7 col-md-7 col-sm-6">
                                        <select id="ddlStu_roll_no" name="ddlStu_roll_no" onchange="LoadStudentDetails()"></select>
                                    </div>
                                </div>
                                <div class="row mb-3 mtt">
                                    <div class="col-lg-5 col-md-5 col-sm-6">
                                        <label>Class:</label>
                                    </div>
                                    <div class="col-lg-7 col-md-7 col-sm-6">
                                        <select id="ddlClass" name="ddlStu_roll_no" onchange="LoadStudentChild()"></select>
                                    </div>
                                </div>
                                <div class="row mb-3 mtt">
                                    <div class="col-lg-5 col-md-5 col-sm-6 ">
                                        <label>Receipt No:</label>
                                    </div>
                                    <div class="col-lg-7 col-md-7 col-sm-6 ">
                                        <input type="text" id="txtReceiptNo" readonly="readonly" value="New" />
                                    </div>
                                </div>
                                <div class="row mb-3 mtt">
                                    <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                        <label>Student Name :</label>
                                    </div>
                                    <div class="col-lg-7 col-md-7 col-sm-6 top">
                                        <label id="lblStudentName"></label>
                                    </div>
                                </div>
                                <%-- <div class="row mb-3 mtt">
                        <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                           <label>Student Class :</label>
                        </div>
                        <div class="col-lg-7 col-md-7 col-sm-6 top">
                           <label id="lblStuClass"></label>
                        </div>
                    </div>--%>
                                <div class="row mb-3 mtt">
                                    <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                        <label>Father Name :	</label>
                                    </div>
                                    <div class="col-lg-7 col-md-7 col-sm-6 top">
                                        <label id="lblFatherName"></label>
                                    </div>
                                </div>
                                <div class="row mb-3 mtt">
                                    <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                        <label>Admission Category  :</label>
                                    </div>
                                    <div class="col-lg-7 col-md-7 col-sm-6 top">
                                        <label id="lblAdmCategory"></label>
                                    </div>
                                </div>
                                <div class="row mb-3 mtt">
                                    <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                        <label>Doc No :	</label>
                                    </div>
                                    <div class="col-lg-7 col-md-7 col-sm-6 top">
                                        <input type="text" id="txt_DocNo" />
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <!-- Right Card -->
            <div class="col-lg-6 col-md-7 col-sm-12">
                <div class="card">
                    <div class="card-body">
                        <div class="row mb-3">
                            <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                <label>Contact No :	</label>
                            </div>
                            <div class="col-lg-4 col-md-5 col-sm-6">
                                <label id="lblContactNo"></label>
                            </div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                <label>Session :	</label>
                            </div>
                            <div class="col-lg-7 col-md-5 col-sm-6 top">
                                <label id="lblSession"></label>
                            </div>
                        </div>
                    </div>
                    <div class="row mb-3">
                        <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                            <label>Receipt Date :</label>
                        </div>
                        <div class="col-lg-7 col-md-5 col-sm-6 top">
                            <input type="text" id="txtReceiptDate" />
                        </div>
                    </div>
                    <div class="row mb-3">
                        <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                            <label>Remarks:</label>
                        </div>
                        <div class="col-lg-7 col-md-5 col-sm-6 top">
                            <textarea id="txtRemarks" style="width: 100%; height: 36px;"></textarea>
                        </div>
                    </div>
                    <div class="row mb-3">
                        <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                            Cash/Bank : <span style="color: red;">*</span>
                        </div>
                        <div class="col-lg-7 col-md-5 col-sm-6 top">
                            <select id="ddl_bankCash" class="w235 fleft">
                                <option>Please Select</option>
                            </select>
                        </div>
                    </div>
                    <div class="row mb-3">
                        <div class="col-lg-5 col-md-5 col-sm-6 top2">
                            <label>Status :	</label>
                        </div>
                        <div class="col-lg-7 col-md-5 col-sm-6 top2">
                            <input type="text" id="txtStatus" disabled="disabled" value="Created" />
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div>
        </div>

        <table>
            <tr style="display: none;">
                <td>
                    <label>Date From :	</label>
                </td>
                <td>
                    <input type="text" id="txtDateFrom" />
                </td>
                <td>
                    <label>Date To :	</label>
                </td>
                <td>
                    <input type="text" id="txtDateTo" />
                </td>
            </tr>
        </table>

        <div id="details" style="margin-top: 20px;">
            <div>
                <table class="table" id="tblDetails">
                    <thead>
                        <tr>
                            <th style="width: 50px; text-align: left;">Sr. </th>
                            <th style="width: 53px; text-align: left;" class="th_action">Action </th>
                            <th style="width: 53px; text-align: left;">Fee No </th>
                            <th style="text-align: left; width: 352px;">Description </th>
                            <th style="text-align: left; width: 252px;">Total Amount</th>
                            <th style="width: 95px; text-align: left;">Receivable Amt</th>
                            <th style="width: 100px; text-align: left;">Rec. Amount</th>
                            <th style="width: 100px; text-align: left;">Bal. Amount</th>
                        </tr>
                    </thead>
                    <tbody id="tblDetailsbody">
                    </tbody>
                </table>
            </div>

            <div class="row">
                <div class="col-lg-9 col-md-4 col-sm-6"></div>
                <div class="col-lg-3 col-md-6 col-sm-8" id="dvSummary">
                    <table style="width: 100%">
                        <tr>
                            <td>Total Receivable:  </td>
                            <td>
                                <input type="text" id="txtTotalPayable" style="width: 116px !important; height: 30px; margin-left: 16px; text-align: right; font-size: 22px;"
                                    disabled="disabled" />
                            </td>
                        </tr>
                        <tr style="display: none !important;">
                            <td>Discount :  </td>
                            <td>
                                <input type="hidden" id="txtDisPer" readonly="readonly" style="width: 116px !important; height: 30px; margin-left: -129px; text-align: right; font-size: 22px;" onkeyup="calculatetotal2()" />
                                <input type="hidden" id="hdntxtDisPer" value="0" />


                                &nbsp; % &nbsp;
                            <input type="hidden" id="txtDisAmt" readonly="readonly" style="width: 116px !important; height: 30px; text-align: right; font-size: 22px;" onkeyup="calculatetotal2()" />
                            </td>
                        </tr>
                        <tr>

                            <td>Net Receivable:  </td>
                            <td>
                                <input type="text" id="txtNetPayable" style="width: 116px !important; height: 30px; margin-left: 16px; text-align: right; font-size: 22px; color: red; margin-left: 17px; color: red !important;" disabled="disabled" />

                            </td>
                        </tr>

                        <tr>
                            <td>Amount Received:  </td>
                            <td>
                                <input type="text" id="txtAmountReceived" readonly="readonly" style="width: 116px !important; height: 24px; margin-left: 17px; text-align: right; font-size: 22px;"
                                    onkeyup="calculatetotal2()" />
                            </td>
                        </tr>
                        <tr>
                            <td>Balance:  </td>
                            <td>
                                <input type="text" id="txtBalances" style="width: 116px !important; height: 30px; margin-left: 35px; text-align: right; font-size: 22px; color: red; margin-left: 18px;" disabled="disabled" />
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
        </div>
        <div>

            <div class="row" id="footer">
                <div class="col-lg-8">
                    <div class="row">
                        <div class="col-lg-2 co-md-4 col-sm-6">
                            <input type="button" class="bnt btn-primry" value="Save" onclick="SaveAllRecord()" id="btnSave" />
                        </div>
                        <div class="col-lg-2 co-md-4 col-sm-6">
                            <input type="button" value="New" class="btn btn-yellow" onclick="window.location = 'StudentReceipt.aspx'" />
                        </div>
                        <div class="col-lg-2 co-md-4 col-sm-6">
                            <input type="button" value="List View" class="btn btn-gray" onclick="window.open('StudentReceiptView.aspx')" />
                        </div>
                        <div class="col-lg-2 co-md-4 col-sm-6">
                            <input type="button" class="btn btn-primry" value="Approve" id="btnApprove" onclick="Approve()" />
                        </div>

                        <div class="col-lg-2 co-md-4 col-sm-6">
                            <input type="button" value="UnApprove" id="btnUnApprove" class="btn btn-primry" onclick="UnApprove()" />
                        </div>

                        <div class="col-lg-2 co-md-4 col-sm-6">
                            <input type="button" class="btn btn-primry" value="Voucher" id="btnVoucher" onclick="PrintVoucher()" />
                        </div>

                        <div class="col-lg-2 co-md-4 col-sm-6">
                            <input type="button" class="btn btn-primry" value="VoucherACV" id="btnVoucherACV" onclick="Voucher()" />
                        </div>
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <asp:UpdatePanel ID="updatepnlPrint" runat="server" UpdateMode="Conditional"
                                ChildrenAsTriggers="true">
                                <ContentTemplate>
                                </ContentTemplate>
                                <Triggers>
                                </Triggers>
                            </asp:UpdatePanel>

                        </div>
                    </div>
                </div>
            </div>


        </div>
        <div id="dvDetails">

            <div style="top: 182px; position: absolute; margin-left: 803px;">
                <label id="lblTotalBillsmsg"></label>
                <label id="lblTotalBillsAmt"></label>
            </div>
        </div>

        <div id="TestModel" class="modal fade" role="dialog">
            <div class="modal-dialog">
                <!-- Modal content-->
                <div class="modal-content" style="width: 1000px; margin-left: -270px; height: 505px;">
                    <div class="modal-header">
                        <button type="button" style="width: auto;" class="close" data-dismiss="modal">&times;</button>
                        <h4 class="modal-title">Add Test</h4>
                    </div>
                    <table style="margin-left: 60px;">
                        <tr>
                            <td>
                                <div style="margin-top: 2px;">
                                    <h2>Main Tests Department : </h2>
                                </div>
                            </td>
                        </tr>
                    </table>
                    <table style="margin-left: 60px;">
                        <tr>

                            <td style="width: 308px;">
                                <select id="ddlMainTestDepartment" tabindex="" onchange="LoadTestByDepartment()" autofocus="autofocus" style="width: 180px !important;">
                                    <option value="">Select Department</option>
                                </select>
                            </td>

                            <td style="width: 205px;">
                                <span class="paper_help_note" tabindex="1" onfocus="document.querySelector('.autofocus2').focus()"></span>
                                <select id="ddlTestList" class="paper_update autofocus1" tabindex="1">
                                </select>
                                <div id="divRotation">
                                    <select id="ddlRotation" style="display: none; width: 100px">
                                    </select>
                                </div>
                                <div id="divX_Ray">
                                    <select id="ddlXRayLF" style="display: none; width: 73px !important; margin-left: 101px; margin-top: -28px; height: 28px;">
                                        <option value="0"></option>
                                        <option value="L">Left</option>
                                        <option value="R">Right</option>
                                    </select>
                                </div>
                            </td>

                            <td>

                                <input type="button" style="border: 3px solid white !important; height: 32px !important;" value="Add Test" tabindex="2" class="paper_update autofocus2 Faddbtn" id="btnAddAllTest" onclick="AddAllTest()" />
                                <span class="paper_help_note" tabindex="2" onfocus="document.querySelector('.autofocus1').focus()"></span>
                            </td>


                        </tr>
                        <tr>
                            <td>Remarks:

                            <input type="text" id="Remarks" tabindex="3" />
                            </td>
                        </tr>
                    </table>
                    <div style="width: 742px; overflow: scroll; height: 250px !important; height: auto; margin-left: 60px; margin-top: 20px;">
                        <table class="table" style="width: 724px; height: 146px !important; height: auto; overflow: scroll;" id="tbltestModelTable">
                            <thead>
                                <tr>
                                    <th style="width: 50px; text-align: left;">Sr. </th>
                                    <th style="width: 53px; text-align: left;" class="th_action">Action </th>
                                    <th style="text-align: left; width: 352px;">Description </th>
                                    <th style="text-align: left; width: 352px;">Remarks </th>
                                    <th style="width: 65px; text-align: left;">Qty </th>
                                    <th style="width: 60px; text-align: left;">Amount </th>
                                </tr>
                            </thead>
                            <tbody>
                            </tbody>
                        </table>
                    </div>
                    <div class="modal-footer">
                        <input type="button" id="Button1" name="saveENT" value="Save" data-dismiss="modal" />
                    </div>
                </div>
            </div>
        </div>
</asp:Content>
