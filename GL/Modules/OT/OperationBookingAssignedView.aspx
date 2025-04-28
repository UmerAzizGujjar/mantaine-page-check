<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="OperationBookingAssignedView.aspx.cs" Inherits="PMS.OperationBookingAssignedView" %>

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

         

        });
        function update_call(detailAry) {
            $.ajax({
                type: "POST",
                url: "OperationBookingAssignedView.aspx/update_call",
                data: JSON.stringify({
                    "detailAry": detailAry
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response.d == "success") {
                        window.location = "OperationBookingView.aspx";
                    }

                }, error: function () {

                }

            });

        }

        var get_row = '';
        function Save(row) {
            debugger;
            get_row = row;
            var fitness_id = $($(row).closest('tr')[0]).find('td:eq(0)').text();
            var Patient_Type = $($(row).closest('tr')[0]).find('td span[name=PatientType]').text();
            $.ajax({
                type: "POST",
                url: "OperationBookingAssignedView.aspx/StatusUpdate",
                data: JSON.stringify({ "fitness_id": fitness_id, "PatientType": Patient_Type }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
                    if (response.d == "Prepared") {
                        $($(row).closest('tr')[0]).find('td input[name="btnSave"]').attr('disabled', true);
                        window.location.reload();
                    }

                }, error: function () {

                    alert("Error !");
                }

            });

        }

        function GetDoctors() {
            $.ajax({
                type: "POST",
                url: "OperationBookingAssignedView.aspx/GetDoctors",
                data: '',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
                    var result = JSON.parse(response.d);
                    optionsList = "<option value=0>Please Select</option>"
                    for (var i = 0; i <= result.length; i++) {

                        optionsList += '<option value=' + result[i].Emp_ID + '>' + result[i].Emp_Name + ' </option>';


                    }

                }, error: function () {


                }

            });

        }
        function get_ot_fitnes_list() {
            var jsonParsedData = '';
            $.ajax
                ({
                    type: "POST",
                    url: "OperationBookingAssignedView.aspx/get_ot_fitnes_list",
                    data: "",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (data) {
                        var row = '';
                        debugger;
                        var parsed_data = JSON.parse(data.d);
                        jsonParsedData = parsed_data;
                        $.each(parsed_data, function (key, index) {
                            var btn = '';
                            if (parsed_data[key].Status == "true") {

                                btn = '<input type="button" value="Prepared" name="btnSave" disabled onclick="Save(this);"/>';
                            }
                            else {
                                btn = '<input type="button" value="Prepared" name="btnSave"  onclick="Save(this);"/>';
                            }
                            debugger;
                            row += '<tr><td style="display:none">' + parsed_data[key].In_Patient_ID + '</td><td style="display:none;"><input type="checkbox" class ="chcktbl" id="chcktbl" name="chkReport" value="false"/></td><td>' + parsed_data[key].Sr_No + '</td><td>' + parsed_data[key].Patient_No + '</td><td>' + parsed_data[key].Full_Name + '</td><td>' + parsed_data[key].Age_years + '</td><td>' + parsed_data[key].Gender + '</td><td>' + parsed_data[key].Bill_No + '</td><td style="text-align: center;"><span name="PatientType">' + parsed_data[key].PatientType + '</span></td><td> <select name="ddltestperfomedBy" id="ddldoc' + key + '" style="width: 124px!important;">' + optionsList + '</select></td><td><input type="text" name="txtrdate" id="txtot' + key + '" style="width: 128px!important;" autocomplete="off" value="' + $.datepicker.formatDate('dd M yy', new Date(parseInt(parsed_data[key].Operation_Date.substring(6, 19)))) + '"/></td><td> ' + parsed_data[key].Package_Name + ' </td><td>' + btn + ' </td></tr>';
                            if (parsed_data[key].Status) {
                                debugger;
                                $(row).find('td input[name="btnSave"]').removeAttr("disabled");
                            }
                            else {

                            }

                        });

                        $('#tblotlist tbody').append(row);
                        $.each(jsonParsedData, function (key, value) {

                            $('#ddldoc' + key + '').val(jsonParsedData[key].Referred_Doctor);

                        });
                    },

                    error: function () {


                    }
                });

        }
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <table style="width: 100%;" id="tblotlist" class="responstable table">
        <thead>
  <tr>
            <th style="display: none;"></th>
            <th style="display: none;">
                <input type="checkbox" id="chckHead" name="chkReport" /></th>
            <th>Sr.No</th>

            <th>MR No</th>
            <th>Patient Name</th>
            <th>Age</th>
            <th>Gender</th>
            <th>Bill No</th>
            <th>Patient Type</th>
            <th style="width: 13%; text-align: center;">Doctor Name</th>
            <th style="width: 13%; text-align: center;">O.T Date</th>
            <th style="width: 17%; text-align: center;">Operation Procedure Name</th>
            <th>Prepare For Operation</th>
        </tr>
        </thead>
    </table>
</asp:Content>
