<%@ Page EnableSessionState="ReadOnly" Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="OPDDischarge.aspx.cs" Inherits="PMS.Modules.PatientManagement.OPDDischarge" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/responsive-pages.css?v=<%= ((PMS.SiteMaster)Master).Ver("~/wwwroot/THEME_TIBBIT/CustomCSS/responsive-pages.css") %>" rel="stylesheet" />


    <script type="text/javascript">

        $(document).ready(function () {
            LoadPage();
            GetFilterClinic();
            GetDoctors();

            $('#txtSearch').change(function () {
                var sea = $("#txtSearch").val();
                var filter = $("#ddlFilter").val();
                var doctor = $("#ddlDoctor").val();
                filter = '0';
                doctor = '0';
                LoadPage(sea, filter, doctor);

            });
            $('#ddlDoctor').change(function () {
                var sea = $("#txtSearch").val();
                var filter = $("#ddlFilter").val();
                var doctor = $("#ddlDoctor").val();
                sea = '';
                filter = '0';
                LoadPage(sea, filter, doctor);

            });
            $('#ddlFilter').change(function () {
                var sea = $("#txtSearch").val();
                var filter = $("#ddlFilter").val();
                var doctor = $("#ddlDoctor").val();
                sea = '';
                doctor = '0';
                LoadPage(sea, filter, doctor);

            });

        });
        function GetFilterClinic() {
            $.ajax({
                type: "POST",
                url: "OPDDischarge.aspx/LoadFilterClinic",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                success: function (response) {
                    var options = '<option value="0">Please Select </option>';
                    var Parsed_Data = JSON.parse(response.d);
                    $.each(Parsed_Data, function (key, value) {

                        options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                    });
                    $('#ddlFilter').html(options);
                    $("#ddlFilter").select2();
                },
                failure: function (response) {
                    alert(response.d);
                }
            });
        }
        function GetDoctors() {
            $.ajax({
                type: "POST",
                url: "OPDDischarge.aspx/LoadDoctor",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                success: function (response) {
                    var options = '<option value="0">Please Select </option>';
                    var Parsed_Data = JSON.parse(response.d);
                    $.each(Parsed_Data, function (key, value) {

                        options += '<option value="' + value.Emp_ID + '" >' + value.Emp_Name + '</option>';
                    });
                    $('#ddlDoctor').html(options);
                    $("#ddlDoctor").select2();
                },
                failure: function (response) {
                    alert(response.d);
                }
            });
        }
        function LoadPage(sea, filter, doctor) {
            var search = sea;
            var fil_clinic = filter;
            var Doc_id = doctor;

            if (search == undefined) {
                search = '';
            }
            if (fil_clinic == undefined) {
                fil_clinic = '0';
            }
            if (Doc_id == undefined) {
                Doc_id = '0';
            }

            PageMethods.ViewList(search, fil_clinic, Doc_id, function (res) {
                var lsit = JSON.parse(res);
                var rows = '';
                $.each(lsit, function (key, value) {
                    var newdate = parseInt(value.Created_Time.substr(6, 10));
                    var date = moment.unix(newdate).format('M/D/YYYY h:m:s A');
                    rows += '<tr>';
                    rows += '<td><input type="checkbox" class="Discharge-checkbox" data-id="' + value.Out_Patient_ID + '" /></td>';
                    rows += '<td style="display:none">' + value.Out_Patient_ID + '</td>';
                    rows += '<td>' + date + '</td>';
                    rows += '<td>' + value.Patient_no + '</td>';
                    rows += '<td>' + value.Full_Name + '</td>';
                    rows += '<td>' + value.Father_Name + '</td>';
                    rows += '<td>' + value.Mobile1 + '</td>';
                    rows += '<td>' + value.Patient_Main_Category + '</td>';
                    rows += '<td>' + value.Doc_Name + '</td>';
                    rows += '<td>' + value.Filter_Clinic + '</td>';
                    rows += '</tr>';
                })
                $('#tblOpdDischarge tbody').html(rows);
                $('#select-all-checkbox').change(function () {
                    var isChecked = $(this).prop('checked');
                    $('.Discharge-checkbox').prop('checked', isChecked);
                });
            });
        }

        function DischargePatient() {
            var selectedPatients = [];

            $('.Discharge-checkbox:checked').each(function () {
                selectedPatients.push($(this).data('id'));
            });

            if (selectedPatients.length > 0) {
                PageMethods.DischargePatients(selectedPatients, function (result) {
                    if (result) {
                        alert('Selected patients have been discharged.');
                        location.reload();
                    } else {
                        alert('Failed to discharge the patients.');
                    }
                });
            } else {
                alert('Please select at least one patient to discharge.');
            }

        }

    </script>

</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="row">
        <div class="col-lg-2">
            <label >Search Your Patients: </label>
            <input type="text" id="txtSearch" />
        </div>

        <div class="col-lg-2">
            <label >Filter Clinic: </label>
            <select type="text" id="ddlFilter" > </select>
        </div>

        <div class="col-lg-2">
            <label >Doctor: </label>
            <select type="text" id="ddlDoctor"  ></select>
        </div>
        <div class="col-lg-2">
            <label ></label>
               <input type="button" value="Discharge Patients" class="btn btn-primry" id="dis_patients" onclick="DischargePatient()" />
        </div>
    </div>

    <div class="row" style="overflow: scroll; height: 600px;">
        <table class="table table-bordered" id="tblOpdDischarge">
            <thead>
                <tr>
                    <th>
                        <input type="checkbox" id="select-all-checkbox" /></th>
                    <th style="display:none">OPDid </th>
                    <th >Date </th>
                    <th>Mr No</th>
                    <th >Name </th>
                    <th >Father/Husband Name </th>                  
                    <th>Contact No  </th>
                    <th>Department </th>
                    <th>Doctor Name </th>
                    <th>Filter Clinic  </th>
                </tr>
            </thead>
            <tbody>
            </tbody>
        </table>      
    </div>
 
</asp:Content>
