<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="OPDApproval.aspx.cs" Inherits="PMS.Modules.PatientManagement.OPDApproval" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script type="text/javascript">
        $(document).ready(function () {
            FillPatientType();


            setTimeout(function () {
                GetOPDToApproveList();
            }, 1000)


            $('[id*="Getrow"]').on('click', function () {
                 var isTrue = $('#Getrow').is(':checked');
                if (isTrue) {
                     $('.chckrow').prop('checked', true);
                } else {
                     $('.chckrow').prop('checked', false);
                }
            });

            $('#btnApproved').on('click', function () {

                $.each($('#tbloutPatients tbody tr'), function (key, value) {
                    var chck = $($(value).find('td input[name=Getrow]')[0]).prop("checked");
                    var patid = $($(value).find('td input[name=pat_id]')[0]).val();
                    var Pat_Category = $($(value).find('td input[name=pat_type]')[0]).val();

                    if (chck == "true" || chck == true) {
                        PageMethods.ApproveOPD(patid, Pat_Category, function (response) {
                            var data = response;
                            if (data == "Success") {
                                // alert("Bill has been approved successfully");

                            }



                        });

                    }
                    else {

                    }





                });
                window.location.href = 'OPDApproval.aspx';
            });


        });

        function GetOPDToApproveList() {
            var pat_type = $('#ddlpatientType').val();
            var search = $('#txtsearch').val();

            $.ajax({
                url: 'OPDApproval.aspx/LoadPatientsToApprove',
                type: 'post',
                contentType: 'application/json;charset=utf-8',
                dataType: 'json',
                data: JSON.stringify({ "pat_type": pat_type, "search": search }),
                success: function (_data) {
                    _data = JSON.parse(_data.d);
                    console.log(_data);
                    var mdTable = $('#tbloutPatients');
                    $('#tbl tr:gt(0)').remove();
                    table = $('#ibody');
                    table.empty();
                    $.each(_data, function (key, value) {


                        $("#ibody").append('<tr><td style="display:none;"><input id="pat_id" name="pat_id" class="pat_id" type="hidden" value="' + value.Patient_ID + '" /></td><td style="display:none;"><input id="pat_type" name="pat_type" class="pat_type" type="hidden" value="' + value.Patient_Type + '" /></td><td><input id="Getrow" name="Getrow" class="chckrow" type="checkbox" /></td><td>' + value.mr_no_sequence + '</td><td>' + value.Opd_No + '</td><td>' + value.Full_Name + '</td><td>' + value.Pat_type + '</td><td>' + value.DeptName + '</td><td>' + value.Status + '</td></tr>');
                        length++;


                        return true;
                    });
                },
                error: function () {
                    alert("Get Error");
                }
            });
        }

        function FillPatientType() {
            var options = '<option value="0">Please Select</option>';

            $.ajax({
                url: 'OPDApproval.aspx/PatientType',
                type: 'POST',
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                success: function (response) {
                    var data = response.d ? JSON.parse(response.d) : response;
                    $.each(data, function (key, value) {
                        options += '<option value="' + value.DataValue_Name + '">' + value.DataValue_Description + '</option>';
                    });
                    $('#ddlpatientType').html(options);


                },
                error: function (xhr, status, error) {
                    console.error('Error fetching area data:', error);
                }
            });

            return options;
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="row">
        <div class="col-lg-2 col-md-2 col-sm-4">
                <label>Patient Type</label>
    <select id="ddlpatientType" onchange="GetOPDToApproveList()">
 
    </select>
        </div>
        <div class="col-lg-2 col-md-2 col-sm-4">
             <label>Search</label>
   <input type="text"  id="txtsearch" onkeyup ="GetOPDToApproveList()"  />
        </div>
        <div class="col-lg-2 col-md-2 col-sm-4">
            <label></label>
             <input type="button" value="Approve Selected Patients" class="btn btn-primry" id="btnApproved" />
        </div>
    </div>


   
    <div class="row">
        <table class="table table-hover table-striped table-bordered" id="tbloutPatients" style="overflow: scroll; height: auto;">
            <thead id="ihead">
                <tr>
                    <th style="width: 8%;">
                        <input id="Getrow" class="chckrow" type="checkbox" /></th>
                    <th class="hide">Pat ID</th>
                    <th>MR No</th>
                    <th>OPD No</th>
                    <th>Patient Name</th>
                    <th>PatientType</th>
                    <th style="width: 8%;">Department</th>
                    <th style="width: 8%;">Bill Status</th>


                </tr>
            </thead>
            <tbody id="ibody">
            </tbody>
        </table>
    </div>


</asp:Content>
