<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="StudentFeeDefinition.aspx.cs" Inherits="PMS.Modules.StudentAffair.StudentFeeDefinition" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script type="text/javascript">




        $(document).ready(function () {
            $('#ApproveDate').hide();
            $('#appr_DAte').hide();


            var date = '<%= DateTime.Now%>';
            $("#txt_feedate").datepicker({ dateFormat: 'mm/dd/yy' }).attr('readonly', 'readonly');

            date = moment(date).format('L');


            $("#txt_feedate").val(date);



            var date = '<%= DateTime.Now%>';
            $("#ApproveDate").datepicker({ dateFormat: 'mm/dd/yy' }).attr('readonly', 'readonly');

            date = moment(date).format('L');


            $("#ApproveDate").val(date);




            $('#btnVoucher').hide();
            $('#btnChallan').hide();
            var studentid = '<%= Request.QueryString["Fee_ID"]%>'



            if (studentid == '') {

                $('#btnUnApprove').hide();
                $('#btnApprove').hide();

                GetNewFeeNo();

                LoadAutoChildDataaa();
            }

            else {

                LoadStudentData(studentid);
                $('#btnChallan').show();



            }

            GetStudentRollNo();
            GetStudentClasses();

            $('#ddl_rollno').select2();
            $('#ddlstu_class').select2();



        });






        function GetStudentRollNo() {
            debugger;

            var optionsVen = '<option value="0">Please Select</option>';

            PageMethods.GetStudentRollNos(function (Tests) {
                debugger

                $.each(JSON.parse(Tests), function (key, value) {
                    debugger;
                    optionsVen += '<option value="' + value.Student_Id + '" >' + value.Roll_No + '</option>';
                });
                $('#ddl_rollno').html(optionsVen);
            });
        }



        function LoadStudentData(Fee_ID) {
            debugger;
            PageMethods.LoadStudentData(Fee_ID, function (resp) {
                var studata = JSON.parse(resp);
                debugger;

                $('#savebtn').val('Update');
                $('#txt_feecode').val(studata.Fee_No);
                $('#txt_studentname').val(studata.Student_Name);
                $('#txt_fname').val(studata.Father_Name);
                $('#txt_Total_amount').val(studata.Total_Amount);

                $('#txt_session').val(studata.session);

                var FeeDate = new Date(parseInt(studata.Date.substr(6)));
                FeeDate = moment(FeeDate).format('L');
                $('#txt_feedate').val(FeeDate);

                $('#txt_status').val(studata.Status);

                var status = $('#txt_status').val();
                if (status == "Approved") {
                    debugger;
                    $('#savebtn').attr("disabled", 'disabled');
                    $('#btnApprove').attr("disabled", 'disabled');
                    $('#btnApprove').hide();
                    $('#btnUnApprove').attr("disabled", false);

                    $('#btnVoucher').show();

                }
                if (status == "Created") {
                    debugger;
                    $('#btnApprove').attr("disabled", false);
                    $('#btnUnApprove').attr("disabled", 'disabled');
                    $('#btnUnApprove').hide();

                    $('#btnVoucher').hide();

                }



                $('#txt_st_gl_Acc').val(studata.Student_Account_ID);

                setTimeout(function () {

                    $('#ddl_rollno').val(studata.Roll_No).trigger('change');


                }, 3000);


                setTimeout(function () {

                    $('#ddlstu_class').val(studata.Student_Class).trigger('change');


                }, 3000);






            });

            LoadChildDataaa(Fee_ID);



        }





        function LoadChildDataaa(Fee_ID) {
            var rows = '';

            var rowlength = tblItemDescription.rows.length;


            PageMethods.LoadChildData(Fee_ID, function (resp) {
                debugger;

                var data = (JSON.parse(resp));

                selectedOptions = data;
                var rowIndex = parseInt((parseInt($('#tblItemDescription tbody tr').length)));

                $.each(data, function (key, value) {
                    debugger;
                    rows += '<tr>' +

                        '<td ><input type=text id="txt_id" name="txt_id"  value="' + (key + 1) + '" readonly="readonly" /></td>' +

                        '<td style="display:none;"><input type="text" readonly="readonly" id="accruedincome_ID' + (key + 1) + '" name="accruedincome_ID" value="' + value.Accrued_Income_Acc_ID + '"></td>' +

                        '<td style="display:none;"><input type="text" readonly="readonly" id="netincome_ID' + (key + 1) + '" name="netincome_ID" value="' + value.NetIncome_Acc_ID + '"></td>' +

                        '<td><input type="text" style="width: 83% !important;" readonly="readonly" id="ddl_payablecode' + (key + 1) + '" name="ddl_payablecode" value="' + value.NetIncomeAccName + '"></td>' +

                        '<td><input type="text" id="ddl_feetype' + (key + 1) + '" name="ddl_feetype" onchange="loadfeedetail(this)" readonly="readonly" value="' + value.Fee_Type + '"></td>' +

                        '<td><input type=text id="txt_fee' + (key + 1) + '" name="txt_fee"  value="' + value.Payable_Fee + '" onkeyup="calculatetotalamount()" /></td>' +


                      /*  '<td><a href="javascript:void(0)" onclick="EditRow(' + (key + 1) + ')"><i class="glyphicon glyphicon-edit" style="width:15px !important;font-size: 13px;color:#f30a0a;position:relative;" i="">'*/
                    '</td>' +


                        '</tr>';

                    rowlength++;
                });
                debugger;
                $('#tblItemDescriptionDetail').append(rows);

                calculatetotalamount();





            });


        }



        function EditRow(rowlength) {
            debugger;
            var length = rowlength;
            console.log(length);

            $('#ddl_payablecode' + length).prop("disabled", false).trigger('change');

            $('#ddl_feetype' + length).prop("disabled", false).trigger('change');

        }







        function GetFeeType() {
            debugger;
            var optionsDepth = '';

            PageMethods.GetFeeTypes(function (Tests) {
                debugger
                optionsDepth = '<option value="0">Please Select</option>';

                $.each(JSON.parse(Tests), function (key, value) {
                    debugger;

                    optionsDepth += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                });

                _gloabal_feetype = optionsDepth;



             <% if (Request.QueryString["Fee_ID"] != null)
        { %>
                LoadStudentData(Fee_ID);


            <% } %>

            });
        }



        function GetStudentClasses() {
            debugger;
            var optionsDepth = '';

            PageMethods.GetStudentClass(function (Tests) {
                debugger
                optionsDepth = '<option value="0">Please Select</option>';

                $.each(JSON.parse(Tests), function (key, value) {
                    debugger;

                    optionsDepth += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                });
                $('#ddlstu_class').html(optionsDepth);
            });
        }






        function GetNewFeeNo() {
            PageMethods.Getnewfeeno(function (resp) {
                $('#txt_feecode').val(resp);
            },
                function (error) {
                    alert(error.get_message());
                })
        }





        function SaveAllRecord() {
            debugger;
            var status;

            var btnSave = $('#savebtn').val();
            var txt_feecode = $('#txt_feecode').val();
            var ddl_rollno = $('#ddl_rollno').val();
            var txt_studentname = $('#txt_studentname').val();
            var txt_fname = $('#txt_fname').val();
            var ddlstu_class = $('#ddlstu_class').val();

            var txt_Total_amount = $('#txt_Total_amount').val();
            var txt_status = $('#txt_status').val();
            var txt_st_gl_Acc = $('#txt_st_gl_Acc').val();

            var txt_feedate = $('#txt_feedate').val();



            if (ddl_rollno == '0') {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Select Roll No',
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

            if (ddlstu_class == '0') {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Select Student Class',
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




            var tableItems = $('#tblItemDescription');
            var ItemList = [];

            tableItems.find('tr:gt(0)').each(function (key, value) {

                debugger;
                ItemList.push({


                    'netincome_ID': $(value).find('td input[name=netincome_ID]').val(),

                    'accruedincome_ID': $(value).find('td input[name=accruedincome_ID]').val(),

                    'ddl_payablecode': $(value).find('td input[name=ddl_payablecode]').val(),

                    'ddl_feetype': $(value).find('td input[name=ddl_feetype]').val(),

                    'txt_fee': $(value).find('td input[name=txt_fee]').val(),


                });

            });


            debugger;
            $('#savebtn').attr('disabled', true);
            var AllItemDetail = { 'txt_feecode': txt_feecode, 'txt_feedate': txt_feedate, 'ddl_rollno': ddl_rollno, 'txt_studentname': txt_studentname, 'txt_fname': txt_fname, 'ddlstu_class': ddlstu_class, 'txt_Total_amount': txt_Total_amount, 'txt_status': txt_status, 'txt_st_gl_Acc': txt_st_gl_Acc, 'ItemList': ItemList };
            PageMethods.SaveStudentFee(btnSave, JSON.stringify(AllItemDetail), function (res) {
                debugger;
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

                window.location = "StudentFeeDefinition.aspx?Fee_ID=" + res;
                $('#savebtn').val("Update");


            });

        }
        function loadstudentinfo() {


            var ID = $('#ddl_rollno').val();

            debugger;
            PageMethods.loadstudentinfoss(ID, function (Tests) {
                debugger;

                var data = JSON.parse(Tests);
                $('#txt_studentname').val(data.Full_Name);
                $('#txt_fname').val(data.Father_Name);
                $('#txt_st_gl_Acc').val(data.Account_id);
                $('#txt_session').val(data.session);

            });
        }






        function calculatetotalamount() {

            debugger;

            var TotalAmount = 0;

            $.each($('#tblItemDescription tbody tr'), function (key, value) {

                var txtfee = $($(value).find('td input[name=txt_fee]')[0]).val();

                if (txtfee == "") {

                    txtfee = 0;
                }

                TotalAmount += parseFloat(txtfee);

            });

            $('#txt_Total_amount').val(TotalAmount.toFixed());

        }

        function Approve() {
            debugger;
            var FeeID = '<% =Request.QueryString["Fee_ID"] %>';
            var FeeDate = $('#txt_feedate').val();
            PageMethods.ApproveStudent(FeeID, FeeDate, function (Tests) {
                debugger;
                var message = JSON.parse(Tests);
                if (message[0].Message != null || message[0].Message != "") {
                    alert(message[0].Message);
                    location.reload();
                }

            });
        }

        function UnApprove() {
            debugger;
            var FeeID = '<% =Request.QueryString["Fee_ID"] %>';
            PageMethods.UnApproveStudent(FeeID, function (Tests) {
                debugger
                var message = JSON.parse(Tests);
                if (message[0].Column1 != "" || message[0].Column1 != null) {
                    alert(message[0].Column1);
                    location.reload();

                }
            });

        }

        function PrintVoucher() {
            debugger
            var id = '<%= Request.QueryString["Fee_ID"]%>';
            var locationInfo = window.location;
            var url = '/ReportViewer.aspx?ReportName=Voucher&ReportTitle=SFV Voucher&TransID=' + id + '&TransType=SFV';
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + '/ReportViewer.aspx?ReportName=Voucher&ReportTitle=SFV Voucher&TransID=' + id + '&TransType=SFV';
            }
            window.open(url, '_blank');
        }

        function PrintChallan() {
            debugger
            var id = '<%= Request.QueryString["Fee_ID"]%>';
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








        function LoadAutoChildDataaa() {
            var rows = '';

            var rowlength = tblItemDescription.rows.length;

            PageMethods.LoadAutoChildData(function (resp) {
                debugger;

                var data = (JSON.parse(resp));

                selectedOptions = data;
                var rowIndex = parseInt((parseInt($('#tblItemDescription tbody tr').length)));

                $.each(data, function (key, value) {
                    debugger;
                    rows += '<tr>' +


                        '<td ><input type=text id="txt_id" name="txt_id"  value="' + (key + 1) + '" readonly="readonly" /></td>' +

                        '<td style="display:none;"><input type="text" readonly="readonly" id="accruedincome_ID' + (key + 1) + '" name="accruedincome_ID" value="' + value.Accrued_Income + '"></td>' +

                        '<td style="display:none;"><input type="text" readonly="readonly" id="netincome_ID' + (key + 1) + '" name="netincome_ID" value="' + value.Net_Income + '"></td>' +

                        '<td><input type="text" style="width: 83% !important;" readonly="readonly" id="ddl_payablecode' + (key + 1) + '" name="ddl_payablecode" value="' + value.NetIncomeAccName + '"></td>' +

                        '<td><input type="text" id="ddl_feetype' + (key + 1) + '" name="ddl_feetype" onchange="loadfeedetail(this)" readonly="readonly" value="' + value.Category_Name + '"></td>' +

                        '<td><input type=text id="txt_fee' + (key + 1) + '" name="txt_fee"  value="' + value.Receivable_Fee + '" onkeyup="calculatetotalamount()" /></td>' +


                    /*    '<td><a href="javascript:void(0)" onclick="EditRow(' + (key + 1) + ')"><i class="glyphicon glyphicon-edit" style="width:15px !important;font-size: 13px;color:#f30a0a;position:relative;" i="">'*/
                    '</td>' +
                        '</tr>';

                    rowlength++;
                });
                debugger;
                $('#tblItemDescriptionDetail').append(rows);

                calculatetotalamount();

            });


        }



        function AddChallanAmounts() {
            debugger;

            $('#tblPOItemstModelTable tbody tr').remove();
            var rows = "";

            debugger;

            rows =


                '<tr style="display:none;"><td style="display:none;"><label> Student_ID </label></td>' +
                '<td style="display:none;"><input type=text id="Student_ID" name="Student_ID" /></td></tr>' +

                '<tr><td><label> Admission_Fee </label></td>' +
                '<td><input type=text id="Admission_Fee" name="Admission_Fee" /></td>' +

                '<td><label> Tuition_Fee </label></td>' +
                '<td><input type=text id="Tuition_Fee" name="Tuition_Fee" /></td></tr>' +

                '<tr><td><label> Misc_Fee </label></td>' +
                '<td><input type=text id="Misc_Fee" name="Misc_Fee" /></td>' +

                '<td><label> Library_Magazine_Fund </label></td>' +
                '<td><input type=text id="Library_Magazine_Fund" name="Library_Magazine_Fund" /></td></tr>' +

                '<tr><td><label> Reg_Fee </label></td>' +
                '<td><input type=text id="Reg_Fee" name="Reg_Fee" /></td>' +

                '<td><label> Degree_Fee </label></td>' +
                '<td><input type=text id="Degree_Fee" name="Degree_Fee" /></td></tr>' +

                '<tr><td><label> Security_Fee </label></td>' +
                '<td><input type=text id="Security_Fee" name="Security_Fee" /></td>' +

                '<td><label> Hostel_Fee </label></td>' +
                '<td><input type=text id="Hostel_Fee" name="Hostel_Fee" /></td></tr>' +

                '<tr><td><label> Examination_Fee </label></td>' +
                '<td><input type=text id="Examination_Fee" name="Examination_Fee" /></td>' +

                '<td><label> Remaining_Tuition_Fee </label></td>' +
                '<td><input type=text id="Remaining_Tuition_Fee" name="Remaining_Tuition_Fee" /></td></tr>' +

                '<tr><td><label> Other_Fee </label></td>' +
                '<td><input type=text id="Other_Fee" name="Other_Fee" /></td>' +

                '<td><label> Student_Card_Fee </label></td>' +
                '<td><input type=text id="Student_Card_Fee" name="Student_Card_Fee" /></td></tr>' +

                '<tr><td><label> Remaining_Hostel_Fee </label></td>' +
                '<td><input type=text id="Remaining_Hostel_Fee" name="Remaining_Hostel_Fee" /></td>' +

                '<td><label> Prospectus_Fee </label></td>' +
                '<td><input type=text id="Prospectus_Fee" name="Prospectus_Fee" /></td></tr>' +

                '<tr><td><label> Test_Fee </label></td>' +
                '<td><input type=text id="Test_Fee" name="Test_Fee" /></td></tr>';



            $('#tblPOItemstModelTable tbody').append(rows);

            $('#POItemsModel').modal({
                backdrop: 'static'
            });


        }





    </script>





</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="row">
        <div class="col-md-3 col-lg-3">
            <label for="txt_feecode">Fee No</label>
            <input type="text" id="txt_feecode" name="txt_feecode" class="form-control" readonly />
        </div>

        <div class="col-md-3 col-lg-3">
            <label for="ddl_rollno">Student Roll No <span class="text-danger">*</span></label>
            <select id="ddl_rollno" name="ddl_rollno" class="form-select" onchange="loadstudentinfo()"></select>
        </div>

        <div class="col-md-3 col-lg-3">
            <label for="txt_studentname">Student Name</label>
            <input type="text" id="txt_studentname" name="txt_studentname" class="form-control" readonly />
            <input type="hidden" id="txt_st_gl_Acc" name="txt_st_gl_Acc" />
        </div>

        <div class="col-md-3 col-lg-3">
            <label for="txt_fname">Father Name</label>
            <input type="text" id="txt_fname" name="txt_fname" class="form-control" readonly />
        </div>

    </div>
    <div class="row">
        <div class="col-md-3 col-lg-3">
            <label for="ddlstu_class">Student Class <span class="text-danger">*</span></label>
            <select id="ddlstu_class" name="ddlstu_class" class="form-select"></select>
        </div>

        <div class="col-md-3 col-lg-3">
            <label for="txt_status">Status</label>
            <input type="text" id="txt_status" name="txt_status" value="Created" class="form-control" readonly />
        </div>

        <div class="col-md-3 col-lg-3">
            <label for="txt_session">Session</label>
            <input type="text" id="txt_session" name="txt_session" class="form-control" readonly />
        </div>

        <div class="col-md-3 col-lg-3">
            <label for="txt_feedate">Date</label>
            <input type="text" id="txt_feedate" name="txt_feedate" class="form-control" readonly />
        </div>
    </div>
    <div class="row">
        <div class="col-md-3 col-lg-3" style="display:none">
            <label for="ApproveDate">Approve Date</label>
            <input type="text" id="ApproveDate" name="ApproveDates" class="form-control" readonly />
        </div>
    </div>

    <div class="row">
        <div class="table-responsive mt-3">
            <table class="table table-bordered" id="tblItemDescription">
                <thead class="table-dark">
                    <tr>
                        <th>Id</th>
                        <th>Receivable Code</th>
                        <th>Description</th>
                        <th>Receivable Fee</th>
                       
                    </tr>
                </thead>
                <tbody id="tblItemDescriptionDetail"></tbody>
            </table>
        </div>
    </div>

              
                
                
    <div class="row">
            <div class="col-lg-8 col-md-8">
                <div class="col-md-2 col-lg-2 col-sm-3">
                     <input type="button" class="btn btn-primry" id="savebtn" value="Save" onclick="SaveAllRecord()" />
                </div> 
                <div class="col-md-2 col-lg-2 col-sm-3">
                          <input type="button" class="btn btn-gray" value="View List" onclick="window.location = 'StudentFeeList.aspx'" />
                </div> 
                <div class="col-md-2 col-lg-2 col-sm-3">
                       <input type="button" class="btn btn-yellow" value="New" onclick="window.location = 'StudentFeeDefinition.aspx'" />
                </div>  
                <div class="col-md-2 col-lg-2 col-sm-3">
                       <input type="button" class="btn btn-warning" id="btnApprove" value="Approve" onclick="Approve()" />
                </div>  
                <div class="col-md-2 col-lg-2 col-sm-3">
                      <input type="button" class="btn btn-danger" id="btnUnApprove" value="UnApprove" onclick="UnApprove()" />
                </div> 
                <div class="col-md-2 col-lg-2 col-sm-3">
                     <input type="button" class="btn btn-info" id="btnVoucher" value="Voucher" onclick="PrintVoucher()" />
                </div>
            </div>
          
        </div>
        <div class="row">
            <div class="col-lg-9">

            </div>
            <div class="col-lg-3">
              
                <label for="txt_Total_amount" class="me-2">Total Amount</label>
                <input type="text" id="txt_Total_amount" name="txt_Total_amount" class="form-control d-inline w-auto" readonly />
           
            </div>
              
        </div>



</asp:Content>
