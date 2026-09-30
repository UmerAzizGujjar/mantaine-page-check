<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="OperationBookingView.aspx.cs" Inherits="PMS.OperationBookingView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script type="text/javascript">
        var optionsList = '';
        $(document).ready(function () {
            GetDoctors();
            get_ot_fitnes_list();
            $('[id*=chckHead]').click(function () {
                var isTrue = $('#chckHead').is(':checked');
                if (isTrue) {
                    $('.chcktbl').prop('checked', true);
                }
                else {
                    $('.chcktbl').prop('checked', false);
                }
            });

            $("#btnSave").on('click', function () {
                var detailAry = [];
                var doc_id = '';
                var op_date = '';

                $("#tblotlist tr:gt(0) input[type=checkbox]:checked ").each(function (key, value) {
                    var In_Patient_ID = $(this).closest('tr').find('td:eq(0)').text();
                    doc_id = $(this).closest('tr').find('td select[name=ddltestperfomedBy]').val();
                    op_date = $(this).closest('tr').find('td input[name=txtrdate]').val();
                    var patientType = $(this).closest('tr').find('td span[name=PatientType]').text();
                    if (op_date == "") {
                        alert("Provide Operation Date");
                        return false;
                    }

                    if (doc_id == "0") {
                        alert("Please Select Doctor"); return false;
                    }
                    else {

                    }
                    details = {};
                    details.In_Patient_ID = In_Patient_ID;
                    details.doc_id = doc_id;
                    details.op_date = op_date;
                    details.patientType = patientType;
                    detailAry.push(details);
                    
                });
                console.log(detailAry);
                if (op_date !== "" && doc_id !== "0") {
                    update_call(detailAry);
                }

            });


        });    

        function update_call(detailAry) {
            $.ajax({
                type: "POST",
                url: "OperationBookingView.aspx/update_call",
                data: JSON.stringify({
                    "detailAry": detailAry
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response.d == "success") {
                        alert('data has been updated successfully');
                        setTimeout(function () {
                            window.location = "OperationBookingView.aspx";
                        }, 2000);
                    }

                }, error: function () {


                }

            });

        }
        function GetDoctors() {
            $.ajax({
                type: "POST",
                url: "OperationBookingView.aspx/GetDoctors",
                data: '',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var result = JSON.parse(response.d);
                    optionsList = "<option value=0>Please Select</option>"
                    for (var i = 0; i <= result.length; i++) {

                        optionsList += '<option value=' + result[i].Emp_ID + '>' + result[i].Emp_Name + ' </option>';


                    }


                }, error: function () {


                }

            });

        }
        $(function () {
            GetDoctors();
        });
        function get_ot_fitnes_list() {
            var jsonParsedData = '';
            $.ajax
                ({
                    type: "POST",
                    url: "OperationBookingView.aspx/get_ot_fitnes_list",
                    data: "",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (data) {
                        var row = '';
                        var parsed_data = JSON.parse(data.d);
                        jsonParsedData = parsed_data;
                        $.each(parsed_data, function (key, index) {
                            row += '<tr>' +
                               ' <td style="display:none">' + parsed_data[key].In_Patient_ID + '</td> ' +
                               ' <td><input type="checkbox" class ="chcktbl" id="chcktbl" name="chkReport" value="false"/></td> ' +
                               ' <td>' + (key + 1) + '</td> ' +
                               ' <td>' + parsed_data[key].Full_Name + '</td>' +
                               ' <td>' + parsed_data[key].Age_years + '</td>' +
                               ' <td>' + parsed_data[key].Gender + '</td>' +
                               ' <td><span name="PatientType">' + parsed_data[key].PatientType + '</span></td>' +
                               ' <td>' + parsed_data[key].Patient_No + '</td>' +

                      '<td><input type="text" name="txtrdate" id="txtot' + key + '" style="width: 89px!important;" autocomplete="off"/></td>' +
                             '<td>' + parsed_data[key].Bill_No + '</td>' +
                             '<td>' + parsed_data[key].Package_Name + '</td>' +
                             '<td> <select name="ddltestperfomedBy" id="ddldoc' + key + '" style="width: 124px!important;"></select></td>' +

                                               

                              '</tr>';
                        });
                       
                        $('#tblotlist tbody').append(row);
                        setTimeout(function () {
                            $('select[name="ddltestperfomedBy"]').append(optionsList);
                        }, 1000);

                        $('input[name="txtrdate"]').datepicker({ dateFormat: 'dd M yy' });
                        $.each(jsonParsedData, function (key, value) {

                            var emp_id = jsonParsedData[key].Referred_Doctor;
                            if (emp_id == null) { }

                            else { $('#ddldoc' + key + '').val(jsonParsedData[key].Referred_Doctor); }

                        });
                    },

                    error: function () {
                    }
                });

        }
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
        <div class="col-lg-2 col-md-4 col-sm-6">
        <input type="button"  value="Save" id="btnSave" />
    </div>
        </div>
    <div class="row">
        <div class="col-md-12" style="overflow: scroll; height: 400px;">
            <table id="tblotlist" class="table">
                <thead>
                     <tr>
                    <th style="display: none;"></th>
                    <th>
                        <input type="checkbox" id="chckHead" name="chkReport" /></th>
                    <th>Sr #</th>
                    <th>Patient Name</th>
                    <th>Age</th>
                    <th>Gender</th>
                    <th>Patient Type</th>
                    <th>MR No</th>
                    <th>O.T Date</th>
                    <th>Bill #</th>
                    <th style="width: 17%; text-align: center;">Operation Procedure Name</th>
                    <th>Doctor Name</th>                
                </tr>
                </thead>
               
            </table>
        </div>
    </div>


</asp:Content>
