<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Patients.aspx.cs" Inherits="PMS.WebForm9" %>

<%@ Register Assembly="CrystalDecisions.Web, Version=13.0.2000.0, Culture=neutral, PublicKeyToken=692fbea5521e1304" Namespace="CrystalDecisions.Web" TagPrefix="CR" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script type="text/javascript">
        function loaddoctor() {
            var Type = $('#ctl00_MainContent_ddlPatient_Type').val();
            if (Type == '02') {
                var dpt = $('#ctl00_MainContent_ddlPatient_Main_Category').val();
                PageMethods.LoadDoctor(dpt, function (res) {
                    var doctor = JSON.parse(res);
                    var options;
                    var rowsText = '';
                    var options = '<Option value=""> Please Select </Option>';
                    $.each(doctor, function (key, value) {

                        options += '<option value="' + value.Emp_ID + '" >' + value.Emp_Name + '</option>';
                    });

                    $('#ctl00_MainContent_ddlDoctorName').html(options)
                });
            }

        }
        debugger;

        function loadRegistrationFee() {
            debugger;
            loadDepartmentByDoctor();

            var res = '';
            var Doc = $('#ctl00_MainContent_ddlDoctorName').val();
            PageMethods.loadRegistrationFees(Doc, function (res) {
                debugger;
                var fee = JSON.parse(res);
                if (fee == null) {
                    res = '';
                }
                else {
                    res = fee.Amount;
                }
                if (res != '') {

                    $('#ctl00_MainContent_txtRegistration_Fee').val(parseInt(res));
                    $('#ctl00_MainContent_hdnregisterfee').val(parseInt(res));
                    $('#hdnregisterfee').val(parseInt(res));

                }


            });

        }
        function loadDepartmentByDoctor() {
            debugger;
            var Type = $('#ctl00_MainContent_ddlPatient_Type').val();
            if (Type == '02') {
                var doc = $('#ctl00_MainContent_ddlDoctorName').val();
                PageMethods.loadDpt(doc, function (res) {
                    var dep = JSON.parse(res);
                    debugger;
                    var opt;



                    $('#ctl00_MainContent_ddlPatient_Main_Category').val(dep.Department);

                });
            }
        }








        function BackToPrint() {

            window.open('PrintReciept.aspx?Patient_ID=' + document.getElementById('<%=hdnPatientID.ClientID%>').value + ' ', '_blank');
        }
        $(document).ready(function () {
            $("#tabs").on('click', 'li', function () {
                debugger;
                var activeTab = $(this).find('a').html();
                if (activeTab == "Contact Information") $("#ctl00_MainContent_txtTemporary_Address").focus();

            });
            $('#next').focus();
            BindDDl('Patient Main Category', 'ddlReferedTo', BindDDl); 

            DisableCardParint();

            $('#ctl00_MainContent_ddlMode_Of_Registration').on('change', function () {

                if ($('#ctl00_MainContent_ddlMode_Of_Registration').val() == "Emergency") {

                    $('#ctl00_MainContent_ddlPatient_Type').val("01");
                }
                else {
                    $('[id=ctl00_MainContent_ddlPatient_Type] option').filter(function () {
                        return ($(this).val() == '0'); 
                    }).prop('selected', true);

                }

            });


            var action = '<%=(Request.QueryString != null)?Request.QueryString["action"]:""%>'
            debugger;
            if (action == "print") {
                var id = document.getElementById('<%=hdnPatientID.ClientID%>').value;
                window.open('/ReportViewer.aspx?ReportName=PatientSlip&ReportTitle=OPD Slip&Patient_ID=' + id, '_blank');
            }
        });
        function BindDDl(ValueSet_Name, ddl_ID, callback) {
            PageMethods.GetDefinitions(ValueSet_Name, function (resp) {
                var options = '<Option value=""> Select an Option </Option>'; ctl00_MainContent_txtFull_Name
                $.each(JSON.parse(resp), function (key, value) {
                    options += '<Option value="' + value.DataValue_Name + '"> ' + value.DataValue_Description + ' </Option>';
                });
                $('#' + ddl_ID).html(options);

                if (ddl_ID == 'ddlReferedTo') {
                    callback('Emergency Brought By', 'ddlBroughtBy', BindDDl);
                }
                if (ddl_ID == 'ddlBroughtBy') {
                    callback('Shifted To', 'ddlShiftedTo', LoadBroughtByInformation);
                }
                if (ddl_ID == 'ddlShiftedTo') {
                    callback();
                }
            });
        }

        debugger;
        function SaveBroughtByInformation() {
            debugger;


            var pno = $("#ctl00_MainContent_txtMobile1").val();
            if (pno == "+92__________")
                $("#ctl00_MainContent_txtMobile1").val("");



            var val = document.getElementById("hdnDuplicateCheck").value;
            var returnVal = false;
            if (val == "0") {
                document.getElementById("hdnDuplicateCheck").value = "1";
                var Type = document.getElementById('ctl00_MainContent_ddlPatient_Type').value;




                if (Type == "04") {
                    var rollno = $('#ctl00_MainContent_txtRoll_No').val();
                    var classname = $('#ctl00_MainContent_txtClassName').val();
                    if (rollno == "") {
                        alert("Please Enter Roll no");
                    }
                    if (classname == "") {
                        alert("Please Enter Class Name");
                    }
                }

                else if (Type == "05") {
                    var comapny = $('#ctl00_MainContent_ddlComapnyName').val();
                    var empcode = $('#ctl00_MainContent_txtEmpCode').val();
                    if (comapny == "") {
                        alert("Please Enter Company Name");
                    }
                    if (empcode == "") {
                        alert("Please Enter Employee Code");
                    }
                }
                else if (Type == "03") {
                    var empid = $('#ctl00_MainContent_txtEmpCode').val();
                    var empreletion = $('#ctl00_MainContent_txtEmpRelation').val();
                    if (empid == "") {
                        alert("Please Enter Employee Code");
                    }
                    if (empreletion == "") {
                        alert("Please Enter Employee Relation");
                    }
                }
                else {
                    $('#ctl00_MainContent_lblCompany').hide();
                    $('#ctl00_MainContent_ddlComapnyName').hide();
                    $('#ctl00_MainContent_txtEmpCode').hide();
                    $('#ctl00_MainContent_lblEmpCOde').hide();
                    $('#ctl00_MainContent_lblRoll_No').hide();
                    $('#ctl00_MainContent_txtRoll_No').hide();
                    $('#ctl00_MainContent_lblClassName').hide();
                    $('#ctl00_MainContent_txtClassName').hide();
                    $('#ctl00_MainContent_txtEmpRelation').hide();
                    $('#ctl00_MainContent_lblEmpRelation').hide();

                    $('#ctl00_MainContent_txtRoll_No').val("");
                    $('#ctl00_MainContent_txtClassName').val("");
                    $('#ctl00_MainContent_ddlComapnyName').val("");
                    $('#ctl00_MainContent_txtEmpCode').val("");
                    $('#ctl00_MainContent_txtEmpRelation').val("");
                }

                $.ajax({
                    url: "Patients.aspx/SaveBroughtByInformation",
                    type: "POST",
                    data: JSON.stringify({
                        "BroughtBy": $('#ddlBroughtBy').find('option:selected')[0].value,
                        "ShiftedTo": $('#ddlShiftedTo').find('option:selected')[0].value,
                        "ReferedTo": $('#ddlReferedTo option:selected')[0].value,
                        "Discharge": $('#chkDischarge:checked').val() == 'on' ? '1' : '0',
                        "BroughtName": $('#txtBroughtName').val(),
                        "BroughtCNIC": $('#txtBroughtCNIC').val(),
                        "BroughtRelation": $('#txtBroughtRelation').val(),
                        "BroughtMobile": $('#txtBroughtMobile').val(),
                        "BroughtAddress": $('#txtBroughtAddress').val(),
                        "BroughtOccupation": $('#txtBroughtOccupation').val(),
                        "BroughtVehicleNo": $('#txtBroughtVehicleNo').val(),
                        "PatientID": $('#<%= txtPatient_ID.ClientID%>').val()
                    }),
                    DataType: "json",
                    contentType: "application/json; charset=utf-8;",
                    Success: function (resp) {
                        alert(resp.d.Patient_ID);
                    },
                    Error: function (x, e) {
                        alert(e);
                    }
                });
                GetMaxPatNo();
                returnVal = true;
            }
            else {
                alert("Processing Please Wait");
                returnVal = false;
            }

            return returnVal;


        }

        function LoadBroughtByInformation() {

            var ID = '<%= Request.QueryString["ID"] %>'
            if (ID != "") {
                PageMethods.LoadBroughtByInformation(ID, function (resp) {

                    $('#ddlBroughtBy').val(resp.Brought_By);
                    $('#ddlShiftedTo').val(resp.ShiftedTo);
                    $('#ddlReferedTo').val(resp.ReferedTo);
                    $('#txtBroughtName').val(resp.BroughtPerson_Name);
                    $('#txtBroughtCNIC').val(resp.BroughtPerson_CNIC);
                    $('#txtBroughtRelation').val(resp.BroughtPerson_Relation);
                    $('#txtBroughtMobile').val(resp.BroughtPerson_Mobile);
                    $('#txtBroughtAddress').val(resp.BroughtPerson_Address);
                    $('#txtBroughtOccupation').val(resp.BroughtPerson_Occupation);
                    $('#txtBroughtVehicleNo').val(resp.BroughtPerson_VehicleNo);

                });
            }
        }

        function FillDoctoreByDepartment() {
            var Type = $('#ctl00_MainContent_ddlPatient_Type').val();
            if (Type == "02") {
                var dept = $('#ctl00_MainContent_ddlPatient_Main_Category').val();
                PageMethods.FillDoctoreByDepartment(dept, function (data) {
                    options = '';
                    $.each(JSON.parse(data), function (key, value) {
                        options += '<option value="' + value.Emp_ID + '" >' + value.Emp_Name + '</option>';
                    });
                    $('#ctl00_MainContent_ddlDoctorName option').remove()
                    $('#ctl00_MainContent_ddlDoctorName').html(options);

                });
            }
        }
        debugger;
        function LoadData() {
            debugger;
            var Type = document.getElementById('ctl00_MainContent_ddlPatient_Type').value;
            debugger;
            if (Type == "04") {

                $('#ctl00_MainContent_txtRoll_No').show();
                $('#ctl00_MainContent_lblClassName').show();
                $('#ctl00_MainContent_txtClassName').show();
                $('#ctl00_MainContent_lblCompany').hide();
                $('#ctl00_MainContent_ddlComapnyName').hide();
                $('#ctl00_MainContent_txtEmpCode').hide();
                $('#ctl00_MainContent_lblEmpCOde').hide();
                $('#ctl00_MainContent_txtEmpRelation').hide();
                $('#ctl00_MainContent_lblEmpRelation').hide();


                $('#ctl00_MainContent_ddlComapnyName').val("");
                $('#ctl00_MainContent_txtEmpCode').val("");
                $('#ctl00_MainContent_txtEmpRelation').val("");
                $('#ctl00_MainContent_lblPanelCompany').hide();
                $('#ctl00_MainContent_ddlPanelCompany').hide();
            }
            else if (Type == "05") {

                $('#ctl00_MainContent_ddlComapnyName').show();
                $('#ctl00_MainContent_txtEmpCode').show();
                $('#ctl00_MainContent_lblEmpCOde').show();
                $('#ctl00_MainContent_lblRoll_No').hide();
                $('#ctl00_MainContent_txtRoll_No').hide();
                $('#ctl00_MainContent_lblClassName').hide();
                $('#ctl00_MainContent_txtClassName').hide();
                $('#ctl00_MainContent_txtEmpRelation').hide();
                $('#ctl00_MainContent_lblEmpRelation').hide();

                $('#ctl00_MainContent_txtRoll_No').val("");
                $('#ctl00_MainContent_txtEmpRelation').val("");
                $('#ctl00_MainContent_lblPanelCompany').hide();
                $('#ctl00_MainContent_ddlPanelCompany').hide();
            }
            else if (Type == "03") {
                $('#ctl00_MainContent_ddlDoctorName').hide();
                $('#ctl00_MainContent_lblDOctorName').hide();
                $('#ctl00_MainContent_ddlComapnyName').hide();
                $('#ctl00_MainContent_txtEmpCode').show();
                $('#ctl00_MainContent_lblEmpCOde').show();
                $('#ctl00_MainContent_txtEmpRelation').show();
                $('#ctl00_MainContent_lblEmpRelation').show();
                $('#ctl00_MainContent_lblRoll_No').hide();
                $('#ctl00_MainContent_txtRoll_No').hide();
                $('#ctl00_MainContent_lblClassName').hide();
                $('#ctl00_MainContent_txtClassName').hide();

                $('#ctl00_MainContent_lblDOctorName').show();

                $('#ctl00_MainContent_txtRoll_No').val("");
                $('#ctl00_MainContent_txtClassName').val("");
                $('#ctl00_MainContent_ddlComapnyName').val("");
                $('#ctl00_MainContent_lblPanelCompany').hide();
                $('#ctl00_MainContent_ddlPanelCompany').hide();
            }
            else if (Type == "02") {
                $('#ctl00_MainContent_ddlDoctorName').attr('disabled', false);
                $('#ctl00_MainContent_ddlFilterClininc').attr('disabled', true);
                $('#ctl00_MainContent_ddlFilterClininc').val('0');
                $('#ctl00_MainContent_ddlPatient_Main_Category').attr('disabled', false);

                $('#ctl00_MainContent_lblDOctorName').show();
                $('#ctl00_MainContent_lblCompany').hide();
                $('#ctl00_MainContent_ddlComapnyName').hide();
                $('#ctl00_MainContent_txtEmpCode').hide();
                $('#ctl00_MainContent_lblEmpCOde').hide();
                $('#ctl00_MainContent_txtEmpRelation').hide();
                $('#ctl00_MainContent_lblEmpRelation').hide();
                $('#ctl00_MainContent_lblRoll_No').hide();
                $('#ctl00_MainContent_txtRoll_No').hide();
                $('#ctl00_MainContent_lblClassName').hide();
                $('#ctl00_MainContent_txtClassName').hide();


                $('#ctl00_MainContent_txtEmpCode').val("");
                $('#ctl00_MainContent_txtEmpRelation').val("");
                $('#ctl00_MainContent_txtRoll_No').val("");
                $('#ctl00_MainContent_txtClassName').val("");
                $('#ctl00_MainContent_ddlComapnyName').val("");
                $('#ctl00_MainContent_lblPanelCompany').hide();
                $('#ctl00_MainContent_ddlPanelCompany').hide();
            }
            else if (Type == "10") {
                $('#ctl00_MainContent_ddlDoctorName').hide();
                $('#ctl00_MainContent_lblDOctorName').hide();
                $('#ctl00_MainContent_lblCompany').hide();
                $('#ctl00_MainContent_ddlComapnyName').hide();
                $('#ctl00_MainContent_txtEmpCode').hide();
                $('#ctl00_MainContent_lblEmpCOde').hide();
                $('#ctl00_MainContent_txtEmpRelation').hide();
                $('#ctl00_MainContent_lblEmpRelation').hide();
                $('#ctl00_MainContent_lblRoll_No').hide();
                $('#ctl00_MainContent_txtRoll_No').hide();
                $('#ctl00_MainContent_lblClassName').hide();
                $('#ctl00_MainContent_txtClassName').hide();
                $('#ctl00_MainContent_txtEmpCode').val("");
                $('#ctl00_MainContent_txtEmpRelation').val("");
                $('#ctl00_MainContent_txtRoll_No').val("");
                $('#ctl00_MainContent_txtClassName').val("");
                $('#ctl00_MainContent_ddlComapnyName').val("");
                $('#ctl00_MainContent_lblPanelCompany').show();
                $('#ctl00_MainContent_ddlPanelCompany').show();
            }
            else {

                $('#ctl00_MainContent_ddlDoctorName').attr('disabled', true);
                $('#ctl00_MainContent_ddlDoctorName').val('0');
                $('#ctl00_MainContent_ddlPatient_Main_Category').attr('disabled', true);
                $('#ctl00_MainContent_ddlPatient_Main_Category').val('0');
                $('#ctl00_MainContent_ddlFilterClininc').attr('disabled', false);
                $('#ctl00_MainContent_txtRegistration_Fee').val('100');
                $('#ctl00_MainContent_lblDOctorName').hide();
                $('#ctl00_MainContent_ddlComapnyName').hide();
                $('#ctl00_MainContent_txtEmpCode').hide();
                $('#ctl00_MainContent_lblEmpCOde').hide();
                $('#ctl00_MainContent_lblRoll_No').hide();
                $('#ctl00_MainContent_txtRoll_No').hide();
                $('#ctl00_MainContent_lblClassName').hide();
                $('#ctl00_MainContent_txtClassName').hide();
                $('#ctl00_MainContent_txtEmpRelation').hide();
                $('#ctl00_MainContent_lblEmpRelation').hide();

                $('#ctl00_MainContent_lblDOctorName').show();

                $('#ctl00_MainContent_txtRoll_No').val("");
                $('#ctl00_MainContent_txtClassName').val("");
                $('#ctl00_MainContent_ddlComapnyName').val("");
                $('#ctl00_MainContent_txtEmpCode').val("");
                $('#ctl00_MainContent_txtEmpRelation').val("");
                $('#ctl00_MainContent_lblEmpRelation').val("");
                $('#ctl00_MainContent_lblPanelCompany').hide();
                $('#ctl00_MainContent_ddlPanelCompany').hide();
            }
        }

        $(document).ready(function () {
            MaskedInput({
                elm: document.getElementById('txt_mobile'),
                format: '+92__________',
                separator: '+92 -'
            });

           
            MaskedInput({
                elm: document.getElementById('ctl00_MainContent_txtMobile1'),
                format: '+92__________',
                separator: '+92 -'

            });
        });

        function GetMaxPatNo() {
            PageMethods.GetMaxPatNo(function (resp) {
                $('#<%= txtPatient_ID.ClientID%>').val(JSON.parse(resp));
                $('#<%= btnNewPat.ClientID%>').val(JSON.parse(resp));
            });
        }
        function OpenAppointment() {
            var ID = localStorage.getItem('Appointment_ID');
            window.location.href = "Appointment.aspx?ID=" + ID;
        }




        function Print() {
            var contents = $("#dvReport").html();
            var frame1 = $('<iframe />');
            frame1[0].name = "frame1";
            frame1.css({ "position": "absolute", "top": "-1000000px" });
            $("body").append(frame1);
            var frameDoc = frame1[0].contentWindow;
            frameDoc.document.open();
            frameDoc.document.write('<html>');
            frameDoc.document.write('<body>');

            frameDoc.document.write(contents);
            frameDoc.document.write('</body></html>');
            frameDoc.document.close();
            setTimeout(function () {
                window.frames["frame1"].focus();
                window.frames["frame1"].print();
                frame1.remove();
            }, 500);

        }

        function SearchPop() {
            debugger;
            $('#SearchModel').modal({
                backdrop: 'static'
            });

            $('#PatientsSearchModel').hide();
            FillList();
        }


        function FillList() {
            debugger;
            $('#tblResult tbody').empty();
            debugger;
            var SearchString = '';

            PageMethods.Search(SearchString, OnFilter, OnFail);
        }


        function OnFilter(data) {

            ClearResults();

            for (var i = 0; i < data.length; i++) {
                AddResult(data[i].Appointment_ID, data[i].Appointment_No, data[i].Patient_Name, data[i].Emp_name, data[i].Age, data[i].Phone, data[i].pat_id);
            }
        }
        var reg_id;
        function AddResult(Appointment_ID, Appointment_No, Patient_Name, Emp_name, Age, Phone, pat_id) {
            debugger;
            reg_id = pat_id;
            $('#hdnAptId').val(Appointment_ID);
            tblLength = tblResult.rows.length;

            var row = ibody.insertRow(-1);
            var cell;

            cell = row.insertCell(-1);
            cell.innerHTML = '<span spnPatID' + tblLength + '>' + Appointment_ID + '</span>';
            cell.className = "hide";

            cell = row.insertCell(-1);
            cell.innerHTML = '<span class="HRcontent">' + Appointment_No + '</span>';
            cell = row.insertCell(-1);
            cell.innerHTML = '<span class="HRcontent">' + Patient_Name + '</span>';
            cell = row.insertCell(-1);
            cell.innerHTML = '<span class="HRcontent">' + Emp_name + '</span>';
            cell = row.insertCell(-1);
            cell.innerHTML = '<span class="HRcontent">' + Age + '</span>';
            cell = row.insertCell(-1);

            cell.innerHTML = '<span class="HRcontent">' + Phone + '</span>';
            cell = row.insertCell(-1);


            var actions = ''

            actions += '<a class="HRlink" href="#"  onclick=AddDetail(' + Appointment_ID + ',' + reg_id + ')>Add</a>';
            cell.innerHTML = actions;
        }
        function OnFail(exc) {
            alert(exc.get_message());
        }
        function ClearResults() {
            while (tblResult.rows.length > 1) {
                tblResult.deleteRow(1);
            }
        }
        function PrintReceiptReport() {

            $.ajax({
                type: "POST",
                url: "Patients.aspx/PrintReceipt",
                data: "{ PatientID: '" + document.getElementById('<%=hdnPatientID.ClientID%>').value + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    document.getElementById('<%=lblReceiptNor.ClientID%>').innerText = msg.d.ReceiptNo;
                    document.getElementById('<%=lblPatientNamer.ClientID%>').innerText = msg.d.PatientName;
                    document.getElementById('<%=lblFather_Namer.ClientID%>').innerText = msg.d.FatherName;
                    document.getElementById('<%=lblMaritalStatus.ClientID%>').innerText = msg.d.Marital_Status;
                    document.getElementById('<%=lblDater.ClientID%>').innerText = msg.d.ReceiptDate;
                    document.getElementById('<%=lblRupeesr.ClientID%>').innerText = msg.d.ReceiptCharges;
                    document.getElementById('<%=lblOperator.ClientID%>').innerText = msg.d.Operator;
                    document.getElementById('<%=lblDepartment.ClientID%>').innerText = msg.d.Department;
                    if (document.getElementById('<%=lblOperator.ClientID%>').innerText == "")
                        document.getElementById('<%=lblOperator.ClientID%>').innerHTML = msg.d.Created_By;
                    if (document.getElementById('<%=lblOperator.ClientID%>').innerText == "")
                        document.getElementById('<%=lblOperator.ClientID%>').innerText = "Operator Deleted.";
                    document.getElementById('<%=lblNICrpt.ClientID%>').innerHTML = msg.d.NIC;
                    document.getElementById('<%=lblTokenNo.ClientID%>').innerHTML = msg.d.TokenNo;

                    document.getElementById('<%=lblAgeYearsrpt.ClientID%>').innerHTML = msg.d.Age_years;


                    Print();

                },
                Error: function (x, e) {
                    alert(e)
                }
            });

        }


        function getcardAmount() {
            var Pat_feeforCard = $('#ctl00_MainContent_chckPatientCard').prop('checked');
            if (Pat_feeforCard == true) {
                var Pat_idforCard = '<% =Request.QueryString["ID"] %>';
                PageMethods.CardFee(Pat_idforCard, function (Tests) {
                    debugger;
                    alert('Card Has Been Issued');
                });
            }
            else {
                alert('Please Select Issue Card CheckBox')
            }
            setTimeout(function () {
                PrintPatientCard();
            }, 1500)

        }
        function PrintPatientCard() {

            $('#ctl00_MainContent_chckPatientCard').attr('disabled', true);

            ID = $('#ctl00_MainContent_txtPatient_ID').val();

            $.ajax({
                type: "POST",
                url: "Patients.aspx/SetPatientCardIssuance",
                data: JSON.stringify({
                    'PatID': ID
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {

                    if (msg.d == "success")
                        var url = "ReportViewer.aspx?ReportName=PrintPatientCard&ReportTitle=Patient Registration Card&MrNo=" + $("#ctl00_MainContent_txtPatient_ID").val();
                    window.open(url);
                },
                Error: function (x, e) {
                    alert(e)
                }
            });
        }
        function PrintPatientBackCard() {

            $('#ctl00_MainContent_chckPatientCard').attr('disabled', true);

            Patient_ID = document.getElementById('<%=hdnPatientID.ClientID%>').value            var url = "ReportViewer.aspx?ReportName=PrintPatientBackCard&ReportTitle=Patient Registration Card&MrNo=" + Patient_ID;            window.open(url);
        }
        debugger;

        $(document).ready(function () {
            debugger;
            fillgender();
            fillmartial();
            fillCity();
            fillArea();
            fill_OPD_No();
            getTotalCountPatient();
            fillCountry();
            fillProvince();



            debugger;

            $("#txtSearch").keypress(function (event) {
                debugger;
                var SearchString = $('#txtSearch').val();
                if (event.which == 13) {
                    {

                        event.preventDefault();

                        if (SearchString != '') {

                            PageMethods.SearchPatients((Number(SearchString) ? parseInt(SearchString).toString() : SearchString), OnFilterPatients, OnFailPatients);
                        }
                    }
                    if (SearchString === '') {
                        FillPatientsList();
                    }
                }

            });

            $("#txtSearchmodal").keypress(function (event) {
                debugger;
                var SearchString = $('#txtSearchmodal').val();
                if (event.which == 13) {
                    {

                        event.preventDefault();

                        if (SearchString != '') {

                            PageMethods.Search((Number(SearchString) ? parseInt(SearchString).toString() : SearchString), OnFilter, OnFail);
                        }
                    }
                    if (SearchString === '') {
                        FillList();
                    }
                }

            });
            $("#txtSearch_rff").keypress(function (event) {
                debugger;
                var SearchString = $('#txtSearch_rff').val();
                if (event.which == 13) {
                    {

                        event.preventDefault();

                        if (SearchString != '') {

                            PageMethods.SearchPatients_Rff((Number(SearchString) ? parseInt(SearchString).toString() : SearchString), OnFilterRefPatients, OnFailPatients);
                        }
                    }
                    if (SearchString === '') {
                        fillrefferedpat();
                    }
                }

            });



            setTimeout(function () {

                loadRegistrationFee();

            }, 1500)
            $("#txtSearch").keyup(function (event) {

                var SearchString = $('#txtSearch').val();
                event.preventDefault();
                if (SearchString === '')
                    FillPatientsList();
            });
            var ids = '<%=Request.QueryString["ID"]%>';
            if (ids == '' || ids == "") {
                debugger;


                $('#btnsearchpatlist').click(function () {
                    $("#PatientsSearchModel").modal('show');
                    /*fillrefferedpat();*/
                });
                $('#btnrefferedPatient').click(function () {
                    $("#PatientRefferedmodal").modal('show');
                });


                fillrefferedpat();
                FillPatientsList();
                $('#srchpat').text("Search Here");

                jQuery(function ($) {


                    var phoneInput = document.getElementById('txtSearch');
                    var cursorPosition = 3;
                    phoneInput.setSelectionRange(cursorPosition, cursorPosition);


                });


            }


            $("#ctl00_MainContent_txtBirth_Date").datepicker({
                dateFormat: 'mm/dd/yy'
            });
            LoadData();
            $("#Tab-5").hide();
            $("#Tab-8").hide();
            $("#Tab-9").hide();
            $('#ctl00_MainContent_ddlGeneral_Category').hide();
        });


        var selected_tabs = 1;
        $(function () {
            var tabs = $("#tabs").tabs({
                select: function (e, i) {
                    selected_tabs = i.index;
                }
            });
        });
        debugger;
        function getTotalCountPatient() {
            debugger;
            $.ajax({
                type: "POST",
                url: "Patients.aspx/GetCount",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    debugger;
                    var dataaa = JSON.parse(data.d);
                    debugger;
                    $('#lblTotalPatients').text(dataaa.TotalPatients);
                    $('#lblFilterClinic1').text(dataaa.Filter1);
                    $('#lblFilterClinic2').text(dataaa.Filter2);
                    $('#lblFilterClinic3').text(dataaa.Filter3);


                },
                error: function (x, e) {
                    alert(e);
                }
            });
        }


        function PrintReceipt() {

            debugger;            Patient_ID = document.getElementById('<%=hdnPatientID.ClientID%>').value            var url = "ReportViewer.aspx?ReportName=PatientSlip&Title=OPD Slip&Patient_ID=" + Patient_ID;            window.open(url);

        }
        function SearchPatients() {
            debugger;
            $('#PatientsSearchModel').modal({
                backdrop: 'static'

            });
            FillPatientsList();
            $('#addNewbtn').hide();
            $('#srchpat').text("Search Your Patients:");
            $('#txtSearch').unmask();
            $('#ClosePatientsSearchModel').show();


        }

        debugger;
        function FillPatientsList() {
            debugger;
            $('#tblPatientsResult tbody').empty();

            var SearchString = '';

            PageMethods.SearchPatients(SearchString, OnFilterPatients, OnFailPatients);
        }


        function fillrefferedpat() {
            debugger;
            $('#tblPatientsReffered tbody').empty();

            var SearchString = '';

            PageMethods.SearchPatients_Rff(SearchString, OnFilterRefPatients, OnFailPatients);
        }
        function OnFilterPatients(data) {

            ClearPatientResults();

            for (var i = 0; i < data.length; i++) {
                AddPatientsResult(data[i].Reg_Patient_ID, data[i].Patient_No, data[i].Full_Name, data[i].NIC, data[i].Mobile1, data[i].Father_Name);
            }
        }
        function OnFilterRefPatients(data) {

            ClearPatient_RffResults();

            for (var i = 0; i < data.length; i++) {
                AddPatientsRFFResult(data[i].Reg_Patient_ID, data[i].Patient_No, data[i].Full_Name, data[i].NIC, data[i].Mobile1, data[i].Father_Name, data[i].OPDID);
            }
        }

        function ClearPatientResults() {
            while (tblPatientsResult.rows.length > 1) {
                tblPatientsResult.deleteRow(1);
            }
        }
        function ClearPatient_RffResults() {
            while (tblPatientsReffered.rows.length > 1) {
                tblPatientsReffered.deleteRow(1);
            }
        }
        function clearPatient() {

            $('#txt_name').val("");
            $('#txt_relation').val("");
           // $('#txt_mobile').val("");
            $('#txt_dob').val("");
            $('#txt_cnic').val("");
            $('#txt_Address').val('');

            $('#updatePatient_Data').hide();
            $('#RevistPat').hide();
        }
        function OnFailPatients(exc) {
            alert(exc.get_message());
        }

        var isAdd = false;
        function AddPatientDetail(Reg_Patient_ID) {
            debugger;
            try {
                isAdd = true;
                var apt_id = appointment_id;
                window.location.href = "Patients.aspx?ID=" + Reg_Patient_ID + "&isAdd=" + isAdd + "&apt_id=" + apt_id;

            } catch (err) {
                alert(err.message);
            }

        }

        function get_pat_initial_info(ini_patientID) {
            debugger;
            try {
                isAdd = true;
                window.location.href = "Patients.aspx?ID=" + ini_patientID + "&isAdd=" + isAdd;

            } catch (err) {
                alert(err.message);
            }

        }
        function AddPatientsRFFResult(Reg_Patient_ID, Patient_No, Full_Name, NIC, Mobile1, Father_Name, OPD_ID) {
            debugger;
            tblLength = tblPatientsReffered.rows.length;

            var row = iPatients_rffBody.insertRow(-1);
            var cell;

            cell = row.insertCell(-1);
            cell.innerHTML = '<span spnPatID' + tblLength + '>' + Reg_Patient_ID + '</span>';
            cell.className = "hide";

            cell = row.insertCell(-1);
            cell.innerHTML = '<span spnopdID' + tblLength + '>' + OPD_ID + '</span>';
            cell.className = "hide";
            cell = row.insertCell(-1);
            cell.innerHTML = '<span class="HRcontent">' + Patient_No + '</span>';
            cell = row.insertCell(-1);
            cell.innerHTML = '<span class="HRcontent">' + Full_Name + '</span>';
            cell = row.insertCell(-1);
            cell.innerHTML = '<span class="HRcontent">' + Father_Name + '</span>';
            cell = row.insertCell(-1);
            cell.innerHTML = '<span class="HRcontent">' + NIC + '</span>';
            cell = row.insertCell(-1);
            cell.innerHTML = '<span class="HRcontent">' + Mobile1 + '</span>';
            cell = row.insertCell(-1);
            var actions = ''
            actions += '<a class="HRlink" href="#"  onclick=AddDetail_Rff(' + OPD_ID + ',' + Reg_Patient_ID + ')>Add</a>';
            cell.innerHTML = actions;
        }
        function AddPatientsResult(Reg_Patient_ID, Patient_No, Full_Name, NIC, Mobile1, Father_Name) {
            debugger;
            tblLength = tblPatientsResult.rows.length;

            var row = iPatientsBody.insertRow(-1);
            var cell;

            cell = row.insertCell(-1);
            cell.innerHTML = '<span spnPatID' + tblLength + '>' + Reg_Patient_ID + '</span>';
            cell.className = "hide";

            cell = row.insertCell(-1);
            cell.innerHTML = '<span class="HRcontent">' + Patient_No + '</span>';
            cell = row.insertCell(-1);
            cell.innerHTML = '<span class="HRcontent">' + Full_Name + '</span>';
            cell = row.insertCell(-1);
            cell.innerHTML = '<span class="HRcontent">' + Father_Name + '</span>';
            cell = row.insertCell(-1);
            cell.innerHTML = '<span class="HRcontent">' + NIC + '</span>';
            cell = row.insertCell(-1);
            cell.innerHTML = '<span class="HRcontent">' + Mobile1 + '</span>';
            cell = row.insertCell(-1);
            var actions = ''
            actions += '<a style="color:#15ab02db;font-size:16px;" class="fa fa-plus" href="#" onclick=AddPatientDetail(' + Reg_Patient_ID + ')></a>&nbsp;|&nbsp;&nbsp;<a style="color:#0a32a0db;font-size:16px;" class="fa fa-pencil" href="#" onclick=EditPatientDetail(' + Reg_Patient_ID + ')></a>';
            cell.innerHTML = actions;
        }
        debugger;
        function EditPatientDetail(id) {

            var Patient_ID = $('#hdfPatient_ID').val();
            $('#CloseSearchModel').click(function () {
                window.location.href = "Patients.aspx";
            });
            $('#CloseSearchModels').click();
            $("#SavePatient_Data").hide();
            $("#PatientsSearchModel").hide();
            $('#updatePatient_Data').show();
            $("#SavePatient_Data").hide();
            $('#RevistPat').show();
            $('#updatePatient_Data').show();
            $('#PatientModel').modal({
                backdrop: 'static'
            });

            var ajaxFn = function () {
                $.ajax({
                    type: "POST",
                    url: "patients.aspx/GetEditPatientDetails",
                    data: "{'Reg_Patient_ID':" + id + "}",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: OnSuccessEdit,
                    failure: function (response) {
                        alert(response.d);
                    }
                });

            }
            setTimeout(ajaxFn, 3000);



        }

        var inPatientID;
        var Discharged;
        debugger;
        function OnSuccessEdit(data) {
            debugger;
            if (data.d != '') {
                debugger;

                inPatientID = data.d.Inpat;
                Discharged = data.d.Discharged;
                $("#txt_Mrno").val(data.d.Mr_No);
                $("#txt_name").val(data.d.Name);
                $("#ddl_Gender").val(data.d.Gender).change();
                var newValue = data.d.Age.replace('Y', '');

                $("#txt_dob").val(newValue);
                $("#ddl_status").val(data.d.MaritalStatus);
                $("#ddl_ctgry").val(data.d.Patient_Type).change();
                $("#ddl_Doc").val(data.d.DocID).change();
                $('#ddl_pnl_cpy').hide();

                if (data.d.DOB != null) {
                    stDate = new Date(parseInt(data.d.DOB.substr(6)));
                    stDate = moment(stDate).format('L');
                }
                $('#txtAge_yearss').val(stDate);

                $("#ddltest_main_dpt").val(data.d.department).change();
                $('#ddlRelation').val(data.d.Relation).trigger('change');
                $('#ddl_name').val(data.d.Title).trigger('change');
                $("#txt_relation").val(data.d.FatherName);
                $("#txt_mobile").val(data.d.Mobile);
                $("#txt_cnic").val(data.d.CNIC);
                $("#txt_Address").val(data.d.Address);
                $("#ddl_bld_grp").val(data.d.Blood_Group).change();
                $("#ddlRhFactor").val(data.d.Rh_Factor);
                if (data.d.Patient_Type == "02") {

                    $("#ddl_pnl_cpy").val(data.d.PanelComany).change();
                    $("#txt_Emp").val(data.d.TxtEmp);
                    $("#txt_Ref").val(data.d.TxtRef);

                }
                $('#hdfPatient_ID').val(data.d.Reg_PatientID);
                $('#txt_house').val(data.d.houseno);
                $('#txtstrm').val(data.d.strno);
                $('#txtarea').val(data.d.area);
                $('#txtcity').val(data.d.city);
                $('#txtarea').val(data.d.val_area).trigger('change');
                $('#txtcity').val(data.d.val_city).trigger('change');

            }

        }
        debugger;
        function SavePatient() {
            debugger;
            $('#SavePatient_Data').attr('disabled', true);
            var Prefix_PatientName = $('#ddl_name').val();
            var PatientName = $('#txt_name').val();
            var PatientID = $('#hdfPatient_ID').val();

            var Full_Name = Prefix_PatientName + PatientName;
            debugger;
            var RelationType = $('#ddlRelation').val();
            var Relation = $('#txt_relation').val();
            var Gender = $('#ddl_Gender').val();

            var Mobile = $('#txt_mobile').val();
            var PreFix_DOB = $('#ddl_dob').val();

            var Age = $('#txt_dob').val();
            var Date_Of_Birth = $('#txtAge_yearss').val();

            var CNIC = $('#txt_cnic').val();
            var Address = $('#txt_Address').val();
            var houseno = $('#txt_house').val();
            var stno = $('#txtstrm').val();
            var city = $('#txtcity :selected').text();
            var area = $('#txtarea :selected').text();
            var Country = $('#ddlCountry :selected').val();
            var Province = $('#ddl_Province :selected').val();

            var city_val = $('#txtcity').val();
            var area_val = $('#txtarea').val();
            var martail_status = $('#ddl_status').val();
            if ((PatientName == "" || Mobile == "" || Age == "" || martail_status == "0" || Gender == "0" || Relation == "" || CNIC == "_____-_______-_" || houseno == "" || city_val == "0" || area_val == "0")) {


                alert("Please Enter compulsory Fields");
                $('#SavePatient_Data').attr('disabled', false);
                return;
               
            }

            var data = JSON.stringify({
                "Full_Name": Full_Name,
                "RelationType": RelationType,
                "Relation": Relation,
                "Gender": Gender,
                "Mobile": Mobile,
                "Date_Of_Birth": Date_Of_Birth,
                "CNIC": CNIC,
                "Address": Address,
                "houseno": houseno,
                "stno": stno,
                "city": city,
                "city_val": city_val,
                "area_val": area_val,
                "area": area,
                "PatientID": PatientID,
                "martail_status": martail_status,
                "Age": Age,
                "Country": Country,
                "Province": Province,

            });
            $.ajax({
                type: "POST",
                url: "patients.aspx/SavePatientDetail",
                data: data,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    debugger;
                    var ini_patientID = data.d;

                    alert('Your Record Save and Load Successfully');
                    $('#PatientModel').modal('hide');

                    get_pat_initial_info(ini_patientID);



                },
                error: function (response) {
                    alert("Error");
                }
            });
        }
        function get_pat_initial_info(ini_patientID) {
            debugger;
            try {
                isAdd = true;
                window.location.href = "Patients.aspx?ID=" + ini_patientID + "&isAdd=" + isAdd;

            } catch (err) {
                alert(err.message);
            }

        }
        function AptPatientData(appointment_id) {

            var ID = appointment_id;

            debugger;
            $.ajax({
                type: "POST",
                url: "Patients.aspx/AptPatient",
                data: JSON.stringify({
                    'app_id': ID

                }),

                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    debugger;
                    var dataaa = JSON.parse(data.d);
                    $('#ctl00_MainContent_txtFull_Name').val(dataaa.Patient_Name);
                    $('#ctl00_MainContent_txtAge_years').val(dataaa.Age);
                    $('#ctl00_MainContent_txtMobile1').val(dataaa.Phone);

                    $('#ddlDoctorName').val(dataaa.Consultant_ID).trigger("change");



                },
                error: function (x, e) {
                    alert(e)
                }
            });

        }
        var appointment_id;
        var reg_ids;
        function AddDetail(id, reg_id) {
            debugger;
            alert('Patient Proceed');
            appointment_id = id;
            reg_ids = reg_id;
            $('#CloseSearchModel_apt').click();
            $('#CloseSearchModel_apt').hide();
            $('#modal-backdrop in').hide();
            $('#ctl00_MainContent_hdnAptId').attr('value', id);
            debugger;
            AddPatientDetail_apt();


        }

        var isAdds = false;
        function AddPatientDetail_apt() {
            debugger;
            try {
                isAdds = true;
                var apt_id = appointment_id;
                window.location.href = "Patients.aspx?ID=" + reg_ids + "&isAdd=" + isAdds + "&apt_id=" + apt_id;

            } catch (err) {
                alert(err.message);
            }

        }
        var rff_id;
        var register_ids;
        var isReffered = false;
        function AddDetail_Rff(OPD_ID, Reg_Patient_ID) {
            debugger;
            alert('Patient Proceed');
            rff_id = OPD_ID;
            register_ids = Reg_Patient_ID;

            isReffered = true;
            var opd_id = rff_id;
            window.location.href = "Patients.aspx?ID=" + register_ids + "&isAdd=" + isReffered + "&opd_id=" + opd_id;
            $('#ctl00_MainContent_hdnRffId').attr('value', OPD_ID);

        }

        function addfunc() {
            debugger;
            var maskedValue = $('#txtSearch').val();
            var unmaskedValue = maskedValue.replace(/_/g, '');
            var Ph_sNOs = unmaskedValue.length;



            $('#addNewbtn').attr("disabled", false);
            AddNewPatient();




            debugger;

            $('#ClosePatientsSearchModel').click();
            fillmrno();
            //setTimeout(function () {
            //    $('#txt_mobile').val(unmaskedValue);
            //}, 100);
            //$('#txt_name').focus();
        }

        function fillmrno() {
            var data = {};

            $.ajax({
                type: "POST",
                url: "patients.aspx/Getmr",
                data: data,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    debugger;
                    var max_mr = data.d;
                    $('#txt_Mrno').val('New');
                },
                error: function (xhr, status, error) {
                    console.error("AJAX request failed:", status, error);
                }
            });
        }
        function fill_OPD_No() {
            var data = {};

            $.ajax({
                type: "POST",
                url: "patients.aspx/GetOPDNo",
                data: data,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    debugger;
                    var max_mr = data.d;
                    $('#ctl00_MainContent_txt_opd_no').val(max_mr);
                },
                error: function (xhr, status, error) {
                    console.error("AJAX request failed:", status, error);
                }
            });
        }

        function AddNewPatient() {
            debugger;
            $('#ddl_pnl_cpy').next(".select2-container").hide();

            clearPatient();
            $('#hdfPatient_ID').val('(New)');

            $('#PatientModel').modal({
                backdrop: 'static'
            });
            $("#ddl_name").focus();
            MaskedInput({
                elm: document.getElementById('txt_cnic'), 
                format: '_____-_______-_',
                separator: '-'

            });
        }

        function fillmartial() {
            var options = '<option value="0">Please Select</option>';
            PageMethods.GetMartailStatus(function (data) {
                $.each(JSON.parse(data), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                });
                $('#ddl_status').html(options);

            });
            return options;
        }

        function fillCountry() {
            var options = '<option value="0">Please Select</option>';
            PageMethods.GetCountry(function (data) {
                $.each(JSON.parse(data), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                });
                $('#ddlCountry').html(options);

            });
            return options;
        }
        function fillProvince() {
            var options = '<option value="0">Please Select</option>';
            PageMethods.GetProvince(function (data) {
                $.each(JSON.parse(data), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                });
                $('#ddl_Province').html(options);

            });
            return options;
        }
        function fillCity() {
            var options = '<option value="0">Please Select</option>';
            PageMethods.GetCity(function (data) {
                $.each(JSON.parse(data), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                });
                $('#txtcity').html(options);

            });
            return options;
        }
        function fillArea() {
            var options = '<option value="0">Please Select</option>';
            PageMethods.GetArea(function (data) {
                $.each(JSON.parse(data), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                });
                $('#txtarea').html(options);

            });
            return options;
        }
        function fillgender() {
            var options = '<option value="0">Please Select</option>';
            PageMethods.GetGender(function (data) {
                $.each(JSON.parse(data), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                });
                $('#ddl_Gender').html(options);

            });
            return options;
        }
        function DisablePatinettype() {

            var chkStatus = document.getElementById('<%=chckPatientCard.ClientID%>');
            if (chkStatus.checked) {
                $('#ddlPatient_Type').attr('disabled', false);

            }
            else {
                $('#btnPrintCard').attr('disabled', true);
                $('#btnPrintBackCard').attr('disabled', true);
            }
        }

        function DisableCardParint() {

            var chkStatus = document.getElementById('<%=chckPatientCard.ClientID%>');
            if (chkStatus.checked) {
                $('#btnPrintCard').attr('disabled', false);
                $('#btnPrintBackCard').attr('disabled', false);

            }
            else {
                $('#btnPrintCard').attr('disabled', true);
                $('#btnPrintBackCard').attr('disabled', true);
            }
        }
        debugger;
        function CalculateDateOfBirth() {
            debugger;
            var now = moment();
            var year = $('#txt_dob').val();
            var calcualteDate = now.subtract('years', year);
            var finalDate = calcualteDate.format("M/D/YYYY");
            var $datepicker = $('#txtAge_yearss');
            $datepicker.datepicker();
            $('#txtAge_yearss').unmask("99/99/9999");
            $datepicker.datepicker('setDate', finalDate);
            $('#txtAge_yearss').unmask("99/99/9999");
            $("#txtAge_yearss").mask("99/99/9999");

        }
        function DisablingValidation() {

            var chkStatus = document.getElementById('<%=chkValidation.ClientID%>');
            if (chkStatus.checked) {
                document.getElementById('<%=txtPatient_NIC.ClientID%>').value = "UnKnown";
                document.getElementById('<%=txtFull_Name.ClientID%>').value = "UnKnown";
                document.getElementById('<%=txtFather_Name.ClientID%>').value = "UnKnown";
                document.getElementById('<%=txtEmail_ID.ClientID%>').value = null;

            }
            else {
                document.getElementById('<%=txtPatient_NIC.ClientID%>').value = "";
                document.getElementById('<%=txtFull_Name.ClientID%>').value = "";
                document.getElementById('<%=txtFather_Name.ClientID%>').value = "";
                document.getElementById('<%=txtEmail_ID.ClientID%>').value = null;
            }
        }

        function ClearControls() {
            $('#tabs').find('input:text').each(function () {
                $('select option:nth-child(1)').attr('selected', 'selected')
                $(':text, textarea').val('');
                $('input:checkbox').removeAttr('checked');
            });
        }
        function setFocus() {
            document.getElementById("txtSearch").focus();
            $("#txtSearch").focus();
        }

        document.addEventListener("DOMContentLoaded", setFocus);

    </script>



</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <asp:HiddenField runat="server" ID="hdfPatient_ID" ClientIDMode="Static" />
    <asp:HiddenField ID="selected_tabs" runat="server" />
    <asp:HiddenField ID="hdnVoucherID" runat="server" />
    <asp:HiddenField ID="hdnAptId" runat="server" />
    <asp:HiddenField ID="hdnRffId" runat="server" />

    <input type="hidden" name="hdnDuplicateCheck" value="0" id="hdnDuplicateCheck" />
    <div>
        <div>
            <table style="padding: 20px; display: none;">
                <tr>
                    <td>
                        <b>Search Patients</b>
                    </td>
                    <td>
                        <asp:TextBox ID="txtSearchPatient" runat="server"></asp:TextBox>

                    </td>
                    <td style="margin-right: 10px;"></td>
                    <td></td>
                </tr>
            </table>
            <br />
        </div>
    </div>


    <div>
        <table style="width: 28%;">
            <tr>
                <td>Total Patient <span style="margin-left: 5px !important; font-weight: bold;" id="lblTotalPatients"></span></td>

                <td>G31<span style="margin-left: 5px !important; font-weight: bold;" id="lblFilterClinic1"></span></td>
                <td></td>
                <td></td>

                <td>G30<span style="margin-left: 5px !important; font-weight: bold;" id="lblFilterClinic2"></span></td>
                <td></td>

                <td>G29<span style="margin-left: 5px !important; font-weight: bold;" id="lblFilterClinic3"></span></td>
                <td></td>
            </tr>
        </table>
    </div>
    <div class="row">
        <div class="col-lg-2 col-md-3 col-sm-6">
            <input type="button" id="addNewbtn" onclick="addfunc()" value="Add New" />
        </div>
        <div class="col-lg-2 col-md-3 col-sm-6">
            <input type="button" value="Repeated Patient" id="btnsearchpatlist"  />
        </div>
        <div class="col-lg-2 col-md-3 col-sm-6">
            <input type="button" value="Reffered Patient" id="btnrefferedPatient" />
        </div>
        <div class="col-lg-2 col-md-3 col-sm-6">
            <input type="button" value="Appointment" id="btnSearchPatient" onclick="SearchPop()" />
        </div>
        <div class="col-lg-2 col-md-3 col-sm-6">
            <span style="font-size: 15px;">Recent Visit</span> <span style="margin-left: 5px !important; font-weight: bold; font-size: 24px;" id="lblNoOfDays" class="blink" runat="server"></span>
        </div>
        <div class="col-lg-2 col-md-3 col-sm-6">
            <span style="font-size: 15px;">Previous Visit </span><span style="margin-left: 5px !important; font-weight: bold; font-size: 24px;" id="lblNoOfDays2" class="blink" runat="server"></span>
        </div>
    </div>



    <div id="tabs">
        <ul>
            <li><a href="#Tab-1">Patient Details(Mandatory)</a></li>

        </ul>
        <div id="Tab-1">
            <div id="Patientdetail" style="width: auto;">
                <asp:TextBox ID="txt_reg_patno" Style="display: none" runat="server"></asp:TextBox>
                <form>
                    <div class="row">
                        <div class="col-lg-2 col-md-6 col-sm-6">
                            <label>Registration Fee</label>
                            <asp:TextBox ID="txtRegistration_Fee" runat="server" ReadOnly="true"></asp:TextBox>
                            <asp:HiddenField ID="hdnregisterfee" runat="server" />
                        </div>
                        <div class="col-lg-2 col-md-6 col-sm-6">
                            <asp:Label ID="LblPatient_ID" runat="server" Text="Patient ID" Style="display: none;"></asp:Label>

                            <label>MR No</label>
                            <asp:TextBox ID="txtPatient_ID" runat="server" ReadOnly="true" Style="display: none;"></asp:TextBox>
                            <asp:TextBox ID="txtPatientNo" value="New" runat="server" ReadOnly="true"></asp:TextBox>
                            <asp:HiddenField ID="hdnPatientID" runat="server" />
                        </div>
                        <div class="col-lg-2 col-md-6 col-sm-6">
                            <label>OpdNo *</label>

                            <asp:TextBox ID="txt_opd_no" runat="server" ReadOnly="true"></asp:TextBox>
                        </div>
                        <div class="col-lg-2 col-md-6 col-sm-6">

                            <label>Mode Of Presentation</label>
                            <asp:DropDownList ID="ddlMode_Of_Registration" CssClass="custom-dropdown" runat="server" AppendDataBoundItems="true" TabIndex="8" ReadOnly="true" disabled></asp:DropDownList>
                        </div>
                        <div class="col-lg-2 col-md-6 col-sm-6">

                            <label>Patient Category *</label>
                            <asp:DropDownList ID="ddlPatient_Type" CssClass="custom-dropdown" runat="server" AppendDataBoundItems="true" AutoPostBack="false" OnSelectedIndexChanged="ddlPatient_Type_SelectedIndexChanged" TabIndex="10" onchange="LoadData();"></asp:DropDownList>
                            <asp:RequiredFieldValidator ID="requiredfieldvalidator6" runat="server" ErrorMessage="please select patient Category" Text="*" ForeColor="red" InitialValue="0" ControlToValidate="ddlPatient_Type"></asp:RequiredFieldValidator>
                        </div>
                    </div>
                    <br />

                    <div class="row">
                        <div class="col-lg-2 col-md-6 col-sm-6">

                            <label>Name *</label>
                            <asp:TextBox ID="txtFull_Name" runat="server" TabIndex="2" ReadOnly="true"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" Display="Dynamic" ErrorMessage="Please Enter Full Name" Text="*" ControlToValidate="txtFull_Name" ForeColor="Red"></asp:RequiredFieldValidator>
                        </div>
                        <div class="col-lg-2 col-md-6 col-sm-6">

                            <label>Father Name</label>
                            <asp:TextBox ID="txtFather_Name" runat="server" TabIndex="2" ReadOnly="true"></asp:TextBox>
                        </div>
                        <div class="col-lg-2 col-md-6 col-sm-6">

                            <label>Age *</label>
                            <asp:TextBox ID="txtAge_years" runat="server" TabIndex="6" ReadOnly="true"></asp:TextBox>
                            <asp:TextBox ID="txtBirth_Date" Style="display: none;" runat="server" TabIndex="6" placeholder="mm/dd/yy"></asp:TextBox>
                        </div>
                        <div class="col-lg-2 col-md-6 col-sm-6">

                            <label>Gender *</label>
                            <asp:DropDownList ID="ddlGender" CssClass="custom-dropdown" runat="server" AppendDataBoundItems="true" TabIndex="6">
                            </asp:DropDownList>
                            <asp:RequiredFieldValidator ID="rfvGender" runat="server" ErrorMessage="Please Select Gender" Text="*" ForeColor="Red" InitialValue="0" ControlToValidate="ddlGender"></asp:RequiredFieldValidator>
                        </div>
                        <div class="col-lg-2 col-md-6 col-sm-6">
                            <label>Patient CNIC</label>

                            <asp:TextBox ID="txtPatient_NIC" ReadOnly="true" runat="server" TabIndex="2"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator14" ControlToValidate="txtPatient_NIC" ErrorMessage="Plz enter Patient NIC." Text="*" Display="Dynamic" runat="server"></asp:RequiredFieldValidator>
                        </div>
                    </div>
                    <br />

                    <div class="row">
                        <div class="col-lg-2 col-md-6 col-sm-6">

                            <label>Mobile 1 *</label>
                            <asp:TextBox ID="txtMobile1" runat="server" TabIndex="17"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvMobileNo1" ControlToValidate="txtMobile1" ErrorMessage="Plz enter Mobile No 1." Text="*" Display="Dynamic" runat="server"></asp:RequiredFieldValidator>
                        </div>
                        <div class="col-lg-2 col-md-6 col-sm-6">

                            <label>Marital Status *</label>
                            <asp:DropDownList ID="ddlMarital_Status" CssClass="custom-dropdown" runat="server" AppendDataBoundItems="true" TabIndex="5"></asp:DropDownList>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator8" runat="server" ErrorMessage="Please Select Marital Status " Text="*" ForeColor="Red" InitialValue="0" ControlToValidate="ddlMarital_Status"></asp:RequiredFieldValidator>
                        </div>
                        <div class="col-lg-2 col-md-6 col-sm-6">

                            <label>Department *</label>
                            <asp:DropDownList ID="ddlPatient_Main_Category" CssClass="custom-dropdown" runat="server" AppendDataBoundItems="true" TabIndex="11" onchange="loaddoctor();"></asp:DropDownList>
                        </div>

                        <div class="col-lg-2 col-md-6 col-sm-6">

                            <label>Doctor</label>
                            <asp:DropDownList ID="ddlDoctorName" CssClass="custom-dropdown" runat="server" AppendDataBoundItems="true" onchange="loadRegistrationFee()" TabIndex="12"></asp:DropDownList>
                        </div>
                        <div class="col-lg-2 col-md-6 col-sm-6">

                            <label>Filter Clinic *</label>
                            <asp:DropDownList ID="ddlFilterClininc" CssClass="custom-dropdown" runat="server" AppendDataBoundItems="true" TabIndex="11" onchange=""></asp:DropDownList>
                        </div>
                    </div>
                    <br />
                    <div class="row">
                        <div class="col-lg-2 col-md-6 col-sm-6">

                            <label>Discount</label>
                            <asp:TextBox ID="txtdiscount" onchange="discount();" runat="server" TabIndex="17"></asp:TextBox>
                        </div>
                        <div class="col-lg-8 col-md-6 col-sm-6">
                            <label>Address *</label>
                            <asp:TextBox ID="txtPermanent_Address" Style="width: 100%" TextMode="SingleLine" runat="server" TabIndex="13"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvPermanentAddress" ControlToValidate="txtPermanent_Address" ErrorMessage="Plz enter Permanent Address" Text="*" Display="Dynamic" runat="server"></asp:RequiredFieldValidator>
                        </div>
                    </div>
                    <br />
                    <div class="row">
                        <div class="col-lg-2 col-md-6 col-sm-6">

                            <label>Cashier</label>
                            <asp:DropDownList ID="ddlcaher" CssClass="custom-dropdown" runat="server" AppendDataBoundItems="true" TabIndex="17" onchange=""></asp:DropDownList>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ErrorMessage="Please Select Casher " Text="*" ForeColor="Red" InitialValue="0" ControlToValidate="ddlcaher"></asp:RequiredFieldValidator>

                        </div>
                        <div class="col-lg-2 col-md-6 col-sm-6" style="">

                            <label style="margin-top: 26px; margin-left: 7px;">Issue Patient Card</label>
                            <asp:CheckBox ID="chckPatientCard" runat="server" Checked="false" TabIndex="16" CssClass="styled" onclick="DisableCardParint()" />
                        </div>
                        <div class="col-lg-2 col-md-6 col-sm-6" style="">

                            <label style="margin-top: 26px; margin-left: 7px;">Free Check Up</label>
                            <asp:CheckBox ID="chckfreecheckup" runat="server" Checked="false" TabIndex="16" CssClass="styled" />
                        </div>
                    </div>
                    <br />
                    
                    <div class="row">

                        <div class="col-lg-0 col-md-6 col-sm-6" style="display: none">

                            <label>Fees</label>
                            <asp:TextBox ID="txt_doc_fee" runat="server"></asp:TextBox>
                        </div>
                        <div class="col-lg-0 col-md-6 col-sm-6" style="display: none">

                            <label>District *</label>
                            <asp:DropDownList ID="ddlDistrict" CssClass="custom-dropdown" runat="server" AppendDataBoundItems="true" TabIndex="16"></asp:DropDownList>
                        </div>

                        <div class="col-lg-4 col-md-6 col-sm-6">
                            <asp:Label ID="Label15" runat="server" Style="display: none" Text="Follow Up No"></asp:Label><span style="display: none;" id="lblFollowNo" runat="server"></span>
                            <asp:Label ID="LblUnknown" Style="display: none;" runat="server" Text="Disaster"></asp:Label>
                            <asp:CheckBox ID="chkValidation" runat="server" Style="display: none;" Checked="false" CssClass="styled" onchange="DisablingValidation();" />
                        </div>

                    </div>


                    <div class="row">
                        <div class="col-lg-2 col-md-6 col-sm-6" id="trGeneral" runat="server">
                            <asp:DropDownList ID="ddlGeneral_Category" runat="server" AppendDataBoundItems="true" AutoPostBack="True" OnSelectedIndexChanged="ddlGeneral_Category_SelectedIndexChanged"></asp:DropDownList>
                        </div>
                        <div class="col-lg-2 col-md-6 col-sm-6">
                            <asp:Label ID="lblPanelCompany" runat="server">Panel Companies</asp:Label>
                            <asp:DropDownList ID="ddlPanelCompany" runat="server" AppendDataBoundItems="true"></asp:DropDownList>
                        </div>
                    </div>
                </form>
            </div>

            <div id="Tab-2" style="display: none">
                <div id="Contact Information" style="width: 90%">

                    <table style="padding: 20px;">
                        <tr>
                            <td colspan="4">
                                <h2>Contact Information : </h2>
                            </td>
                        </tr>
                        <tr>
                        </tr>
                        <tr>

                            <td class="mg">

                                <asp:Label ID="Label8" runat="server" Text="Mobile 2"></asp:Label>

                            </td>
                            <td>
                                <asp:TextBox ID="txtMobile2" runat="server" TabIndex="24"></asp:TextBox>
                            </td>

                        </tr>
                        <tr>

                            <td class="mg">
                                <asp:Label ID="lblPhone" runat="server" Text="Land Line "></asp:Label>

                            </td>
                            <td>
                                <asp:TextBox ID="txtPhone" runat="server" TabIndex="25"></asp:TextBox>
                            </td>
                        </tr>
                        <tr>

                            <td class="mg">
                                <asp:Label ID="Label11" runat="server" Text="Email"></asp:Label>
                            </td>
                            <td class="auto-style1">
                                <asp:TextBox ID="txtEmail_ID" runat="server" TabIndex="26"></asp:TextBox>
                                <asp:RegularExpressionValidator ID="RegularExpressionValidator1"
                                    runat="server" ErrorMessage="Invalid Email Format"
                                    ControlToValidate="txtEmail_ID" ForeColor="Red"
                                    ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*"
                                    Text="*"> </asp:RegularExpressionValidator>
                            </td>
                        </tr>

                        <tr>
                        </tr>
                    </table>
                </div>
            </div>

        </div>
        <div class="row">
            <div class="col-lg-2 col-md-3 col-sm-6">
                <asp:HiddenField ID="selected_tab" runat="server" />
                <asp:Button ID="btnNew" runat="server" CausesValidation="false" Text="New" OnClick="btnNew_Click"></asp:Button>
            </div>
            <div class="col-lg-2 col-md-3 col-sm-6">
                <asp:Button ID="btnSave" runat="server" Text="Save & Print" OnClick="btnSave_Click" OnClientClick="return SaveBroughtByInformation();" />
            </div>
            <div class="col-lg-2 col-md-3 col-sm-6">
                <input type="button" name="name" value="Re Print" onclick="PrintReceipt();" />
            </div>
            <div class="col-lg-2 col-md-3 col-sm-6">

                <input type="button" name="btnPrintCard" id="btnPrintCard" onclick="getcardAmount()" disabled="disabled" value="Front Card" />
            </div>
            <div class="col-lg-2 col-md-3 col-sm-6">
                <input type="button" name="btnPrintBackCard" id="btnPrintBackCard" onclick="PrintPatientBackCard()" disabled="disabled" value="Back Card" />

            </div>
            <div class="col-lg-2 col-md-3 col-sm-6">
                <asp:Button Text="List View" runat="server" ID="btnBack" CausesValidation="false" PostBackUrl="~/Modules/PatientManagement/PatientsView.aspx" />

            </div>
        </div>
        <div class="row">
            <div class="col-lg-2 col-md-3 col-sm-6">
                <asp:Button ID="btnSaveAndPrint" Width="100px" TabIndex="27" runat="server" Text="Save & Print" Style="display: none" OnClick="btnSaveAndPrint_Click" OnClientClick="return SaveBroughtByInformation();"></asp:Button>
            </div>
            <div class="col-lg-2 col-md-3 col-sm-6">
                <input type="button" style="display: none" value="OPD Form" name="name" onclick="BackToPrint();" style="width: 122px !important;" />
                <asp:Button ID="btnNewPat" runat="server" Text="" ClientIDMode="Static" Style="display: none;" />
            </div>
            <div class="col-lg-2 col-md-3 col-sm-6">
                <asp:Label ID="lblMessage" runat="server"></asp:Label>
                <asp:ValidationSummary ID="ValidationSummary1" runat="server"
                    ForeColor="Red" HeaderText="Page Errors"
                    ShowSummary="true" DisplayMode="List" />
            </div>

        </div>
    </div>

    <div id="PatientsSearchModel" style="" data-backdrop="static" class="modal fade-in" role="dialog">
        <div class="modal-dialog">
            <div class="modal-content" style="width: 1140px !important; margin-top: 116px; margin-left: -306px; height: 604px; position: relative;">
                <fieldset style="padding-top: 20px; padding-left: 14px;">

                    <label id="srchpat">Search Your Patients: </label>
                    <input type="text" id="txtSearch" style="margin-left: 2px;" autocomplete="off" />

                </fieldset>
                <div style="overflow: scroll; height: 460px; padding: 10px;">
                    <table class="table table-hover table-striped table-bordered" id="tblPatientsResult" style="overflow: scroll; height: auto;">
                        <thead id="Thead1">
                            <tr>
                                <th style="display: none;">Patient ID</th>
                                <th>MR No</th>
                                <th>Patient Name</th>
                                <th>Father Name</th>
                                <th>CNIC</th>
                                <th>Contact No</th>
                                <th>Actions</th>
                            </tr>
                        </thead>

                        <tbody id="iPatientsBody">
                        </tbody>
                    </table>
                </div>
                <div class="modal-footer">
                    <input type="button" class="col-lg-2 col-md-4 col-sm-6" id="ClosePatientsSearchModel" name="saveENT" value="Close" data-dismiss="modal" />
                </div>

            </div>

        </div>

    </div>


    <div id="PatientRefferedmodal" style="display: none" data-backdrop="static" class="modal fade-in" role="dialog">
        <div class="modal-dialog">
            <div class="modal-content" style="width: 1140px !important; margin-top: 116px; margin-left: -306px; height: 604px; position: relative;">
                <fieldset style="padding-top: 20px; padding-left: 14px;">

                    <label id="">Search Your Patients: </label>
                    <input type="text" id="txtSearch_rff" style="margin-left: 2px;" autocomplete="off" />

                </fieldset>
                <div style="overflow: scroll; height: 460px; padding: 10px;">
                    <table class="table table-hover table-striped table-bordered" id="tblPatientsReffered" style="overflow: scroll; height: auto;">
                        <thead id="Thead2">
                            <tr>
                                <th style="display: none;">Patient ID</th>
                                <th>MR No</th>
                                <th>Patient Name</th>
                                <th>Father Name</th>
                                <th>CNIC</th>
                                <th>Doctor</th>
                                <th>Actions</th>
                            </tr>
                        </thead>

                        <tbody id="iPatients_rffBody">
                        </tbody>
                    </table>
                </div>
                <div class="modal-footer">
                    <input type="button" class="col-lg-2 col-md-4 col-sm-6" id="ClosePatientsRffModel" name="saveENT" value="Close" data-dismiss="modal" />
                </div>

            </div>

        </div>

    </div>


   <div id="PatientModel" class="modal fade" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Patient Details</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <form>
                <div class="modal-body">
                    <div class=" row">
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <label for="txt_Mrno">MR No</label>
                            <input type="text" id="txt_Mrno" class="form-control" disabled />
                        </div>
                        <div class="col-lg-1 col-md-4 col-sm-6">
                            <label for="ddl_name">Name<span style="color: red;">*</span></label>
                            <select id="ddl_name" class="form-control">
                                <option value="Mr.">Mr.</option>
                                <option value="Mrs.">Mrs.</option>
                                <option value="Ms.">Ms.</option>
                                <option value="B/O.">B/O.</option>
                            </select>
                        </div>
                        <div class="col-lg-3 col-md-4 col-sm-6" style="margin-top:5px">
                            <label></label>
                            <input name="dob" type="text" id="txt_name" class="form-control" />
                        </div>
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <label for="ddlRelation">Relation<span style="color: red;">*</span></label>
                            <select id="ddlRelation" class="form-control">
                                <option value="S/O">S/O</option>
                                <option value="W/O">W/O</option>
                                <option value="D/O">D/O</option>
                            </select>
                        </div>
                        <div class="col-lg-3 col-md-4 col-sm-6" style="margin-top: 5px">
                            <label></label>
                            <input type="text" id="txt_relation" class="form-control" />
                        </div>                     
                        </div>
                        <br />
                    <div class="row">
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <label for="PrefixAge">Age/DOB<span style="color: red;">*</span></label>
                            <select id="PrefixAge" class="form-control">
                                <option value="Year">Year</option>
                                <option value="Month">Month</option>
                                <option value="Day">Day</option>
                            </select>
                        </div>
                        <div class="col-lg-1 col-md-4 col-sm-6" style="margin-top:5px;">
                            <label></label>
                            <input type="text" id="txt_dob" class="form-control" placeholder="DOB" onchange="CalculateDateOfBirth();" />
                        </div>
                        <div class="col-lg-3 col-md-4 col-sm-6" style="margin-top:5px;">
                            <label></label>
                            <input type="text" id="txtAge_yearss" class="form-control" placeholder="mm ddyy" />
                        </div>
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <label for="ddl_Gender">Gender<span style="color: red;">*</span></label>
                            <select id="ddl_Gender" class="form-control"></select>
                        </div>
                        <div class="col-lg-3 col-md-4 col-sm-6">
                            <label for="txt_cnic">CNIC<span style="color: red;">*</span></label>
                            <input type="text" id="txt_cnic" class="form-control" />
                        </div>
                        </div>
                        <br />
                    <div class="row">
                        <div class="col-lg-3 col-md-4 col-sm-6">
                            <label for="txt_mobile">Mobile<span style="color: red;">*</span></label>
                            <input type="text" id="txt_mobile" class="form-control" />
                        </div>
                        <div class="col-lg-3 col-md-4 col-sm-6">
                            <label for="ddl_status">Marital Status<span style="color: red;">*</span></label>
                            <select id="ddl_status" class="form-control"></select>
                        </div>   
                        <div class="col-lg-2 colmd-4 col-sm-6">
                            <label>Country</label>
                            <select id="ddlCountry" class="form-control"></select>
                        </div>
                        <div class="col-lg-3 colmd-4 col-sm-6">
                            <label>Province</label>
                            <select id="ddl_Province" class="form-control"></select>
                        </div>
                        </div>
                    <br />
                    <div class="row">
                        <div class="col-lg-3 colmd-4 col-sm-6">
                            <label for="txtcity">City</label>
                            <select id="txtcity" class="form-control"></select>
                        </div>
                        <div class="col-lg-3 col-md-4 col-sm-6">
                            <label for="txtarea">Area</label>
                            <select id="txtarea" class="form-control"></select>
                        </div>
                        <div class="col-lg-5 col-md-4 col-sm-6">
                            <label for="txt_house">Address</label>
                            <input type="text" id="txt_house" class="form-control" />
                        </div>
                    </div>
                    <br/>                  

                                       
                    <div class="form-group row" style="display: none;">
                        <label for="txt_Address" class="col-sm-3 col-form-label">Address<span style="color: red;">*</span></label>
                        <div class="col-sm-9">
                            <input type="text" id="txt_Address" class="form-control" />
                        </div>
                        <div class="col-lg-6 col-md-4 col-sm-6" style="display: none">
                            <label for="txtstrm">St#/Mh#/Rd#/<span style="color: red;">*</span></label>
                            <input type="text" id="txtstrm" class="form-control" />
                        </div>
                    </div>
                </div>

                <div class="modal-footer">
                    <button type="button" class="btn btn-primary" id="SavePatient_Data" onclick="SavePatient();">Save</button>
                    <button type="button" class="btn btn-secondary" id="updatePatient_Data" onclick="SavePatient();">Update</button>
                    <button type="button" class="btn btn-danger" data-dismiss="modal">Close</button>
                </div>
            </form>
        </div>
    </div>
</div>


    <div id="SearchModel" class="modal fade-in" role="dialog">
        <div class="modal-dialog">
            <div class="modal-content" style="width: 1105px; margin-left: -311px; margin-top: 140px; height: 505px;">
                <fieldset style="padding-top: 20px;">

                    <label>Search Your Patients: </label>
                    <input type="text" id="txtSearchmodal" style="margin-left: 2px;" autocomplete="off" />
                </fieldset>
                <div style="overflow: scroll; height: auto;">
                    <table class="table table-hover table-striped table-bordered" id="tblResult" style="overflow: scroll; height: auto;">
                        <thead id="ihead">
                            <tr>
                                <th style="display: none;">Patient ID</th>
                                <th>Appointment No</th>
                                <th>Patient Name</th>
                                <th>Doctor Name</th>
                                <th>Age</th>
                                <th>Mobile</th>
                                <th>Action</th>
                            </tr>
                        </thead>

                        <tbody id="ibody">
                        </tbody>
                    </table>
                </div>
                <div class="modal-footer">
                    <input type="button" class="col-lg-2 col-md-4 col-sm-6" id="CloseSearchModel_apt" name="saveENT" value="Close" data-dismiss="modal" />
                </div>
            </div>
        </div>
    </div>


    <div id="dvReport" style="width: 288px!important; display: none;">

        <h2 style="font-weight: bold; text-align: center; margin-bottom: 0px; padding-bottom: 0px; font-size: 20px; margin-top: 5px;">Arif Memorial Teaching Hospital</h2>
        <h4 style="text-align: center; margin-bottom: 0px; padding-bottom: 0px; font-size: 13px; margin-top: 5px;">Arif Memorial Hospital, Gulverah Stop, 35KM Ferozepur Rd Lahore</h4>
        <h4 align="center" style="margin-bottom: 0px; padding-bottom: 0px; margin-top: 1px; padding-top: 0px; font-size: 13px;">Tel: +92-492 451091-9</h4>
        <div style="margin-left: 10px; margin-top: -40px;">
        </div>
        <h4 style="text-align: center; margin-bottom: 0px; padding-bottom: 0px; padding-top: 0px; margin-top: -20px; font-size: 14px;"></h4>
        <h2 style="text-align: center; margin-bottom: 0px; padding-bottom: 0px; font-size: 18px; font-weight: bold; margin-top: 13px;">RECEIPT</h2>

        <table cellpadding="0" cellspacing="0" width="100%" style="width: 100%!important;">
            <tr>
                <td>
                    <h4 style="margin-left: 20px; float: left; font-size: 16px;">MR No </h4>
                    <h4 style="float: left; border-bottom: 1px dotted; text-align: center; margin-left: 70px; width: 300px; font-size: 16px">
                        <asp:Label runat="server" ID="lblReceiptNor"></asp:Label></h4>
                </td>
                <td align="right">
                    <h4 style="float: right; margin-left: 0px; border-bottom: 1px dotted; font-size: 16px; width: 180px; text-align: center;">
                        <asp:Label runat="server" ID="lblDater"></asp:Label></h4>
                    <h4 style="float: right; font-size: 16px;">Date &nbsp;&nbsp; </h4>
                </td>
            </tr>
            <tr>
                <td>
                    <h4 style="float: left; margin-left: 20px; margin-top: 0px; font-size: 16px;">Patient Name</h4>
                    <h4 style="margin-top: 0px; border-bottom: 1px dotted; width: 300px; text-align: center; font-size: 16px; margin-left: 140px;">
                        <asp:Label runat="server" ID="lblPatientNamer"></asp:Label></h4>
                </td>
                <td align="right">
                    <h4 style="float: right; margin-left: 0px; font-size: 16px; width: 150px; text-align: center;">
                        <asp:Label runat="server" ID="lblTokenNo" Text="1501"></asp:Label></h4>
                    <h4 style="float: right; font-size: 16px;">Token No &nbsp;&nbsp; </h4>
                </td>
            </tr>
            <tr>
                <td>
                    <h4 style="float: left; margin-left: 20px; margin-top: 0px; font-size: 16px;">Father Name</h4>
                    <h4 style="margin-top: 0px; border-bottom: 1px dotted; width: 300px; text-align: center; font-size: 16px; margin-left: 140px;">
                        <asp:Label runat="server" ID="lblFather_Namer"></asp:Label></h4>
                </td>


            </tr>
            <tr>
                <td>
                    <h4 style="float: left; font-size: 16px; margin-left: 20px; margin-top: 0px;">Marital Status</h4>
                </td>
                <td>
                    <h4 style="margin-top: 0px; border-bottom: 1px dotted; width: 300px; text-align: center; font-size: 16px; margin-left: -340px;">
                        <asp:Label runat="server" ID="lblMaritalStatus"></asp:Label></h4>
                </td>
            </tr>
            <tr>
                <td>
                    <h4 style="float: left; font-size: 16px; margin-left: 20px; margin-top: 0px;">Department</h4>
                </td>
                <td>
                    <h4 style="margin-top: 0px; border-bottom: 1px dotted; width: 300px; text-align: center; font-size: 16px; margin-left: -340px;">
                        <asp:Label runat="server" ID="lblDepartment"></asp:Label></h4>
                </td>
            </tr>
            <tr>
                <td>
                    <h4 style="float: left; font-size: 16px; margin-left: 20px; margin-top: 0px;">CNIC</h4>
                </td>
                <td>
                    <h4 style="margin-top: 0px; border-bottom: 1px dotted; width: 300px; text-align: center; font-size: 16px; margin-left: -340px;">
                        <asp:Label runat="server" ID="lblNICrpt"></asp:Label></h4>
                </td>
            </tr>
            <tr>
                <td>
                    <h4 style="float: left; font-size: 16px; margin-left: 20px; margin-top: 0px; padding: 2px;">Age Years</h4>
                </td>
                <td>
                    <h4 style="margin-top: 0px; border-bottom: 1px dotted; width: 300px; text-align: center; font-size: 16px; margin-left: -340px;">
                        <asp:Label runat="server" ID="lblAgeYearsrpt"></asp:Label></h4>
                </td>
            </tr>
            <tr>
                <td colspan="2">
                    <h4 style="float: left; margin-left: 20px; font-size: 16px; margin-top: 0px;">Amount</h4>
                    <h4 style="width: 300px; border-bottom: 1px dotted; text-align: center; font-size: 16px; margin-top: 0px; margin-left: 140px;">
                        <asp:Label runat="server" ID="lblRupeesr"></asp:Label></h4>
                </td>
            </tr>
            <tr>
                <td colspan="2">
                    <h4 style="float: left; margin-left: 20px; font-size: 16px; margin-top: 0px;">Operator</h4>
                    <h4 style="width: 300px; border-bottom: 1px dotted; text-align: center; font-size: 16px; margin-top: 0px; margin-left: 140px;">
                        <asp:Label runat="server" ID="lblOperator"></asp:Label></h4>
                </td>
            </tr>
        </table>
        <h3 align="center" style="font-size: 16px; margin-top: 10px;">Please keep in safe place. This will be required at the time of final settlement of bill</h3>
        <h3 align="center" dir="rtl" style="font-size: 16px; margin-top: 5px;">براۓ مہربانی اس رسید کو سنبھال کر رکھیں۔ بل کی ادائیگی کے وقت کیشئرکو دکھائیں۔ (شکریہ)</h3>
        <span style="font-size: 14px;">Not Valid for Court</span>
    </div>
    <div id="dvPatientCard" style="display: none;">
        <div style="width: 800px; margin: 0 auto; margin-left: -120px">
            <div style="float: left; width: 319px; height: 213px; margin-left: 154px;">

                <div style="width: 306px; margin: 0 auto; padding-top: 62px; font-family: Arial, Helvetica, sans-serif; font-size: 11px; margin-top: -213px; position: relative; z-index: 10;">
                    <div style="border-bottom: solid 1px #eee; float: left; padding-bottom: 2px; margin-bottom: 4px;">
                        <div style="float: left; width: 50px;">MR No :</div>
                        <div style="float: left; width: 100px;">
                            <label id="lblPatCardMr_No"></label>
                        </div>
                        <div style="float: left; width: 50px;">Name :</div>
                        <div style="float: left; width: 106px;">
                            <label id="lblPatCardName"></label>
                        </div>
                    </div>
                    <div style="border-bottom: solid 1px #eee; float: left; padding-bottom: 2px; margin-bottom: 4px;">

                        <div style="float: left; width: 50px;">Gender :</div>
                        <div style="float: left; width: 100px;">
                            <label id="lblPatCardGender"></label>
                        </div>
                        <div style="float: left; width: 50px;">CNIC # :</div>
                        <div style="float: left; width: 106px;">
                            <label id="lblPatCardCNIC"></label>
                        </div>
                    </div>
                    <div style="border-bottom: solid 1px #eee; float: left; padding-bottom: 2px; margin-bottom: 4px;">
                        <div style="float: left; width: 50px;">DOB:</div>
                        <div style="float: left; width: 100px;">
                            <label id="lblPatCardDOB"></label>
                        </div>
                        <div style="float: left; width: 50px;">Phone #:</div>
                        <div style="float: left; width: 100px;">
                            <label id="lblPatCardPhone"></label>
                        </div>
                    </div>
                    <div style="border-bottom: solid 1px #eee; float: left; padding-bottom: 2px; margin-bottom: 4px;">
                        <div style="float: left; width: 50px;">Address</div>
                        <div style="float: left; width: 256px;">
                            <label id="lblPatCardAddress"></label>
                        </div>
                    </div>
                    <div style="border-bottom: solid 1px #eee; float: left; padding-bottom: 2px; margin-bottom: 4px;">
                        <div style="float: left; width: 306px;">&nbsp;</div>
                    </div>
                </div>
            </div>
            <div style="float: right; width: 319px; height: 213px">

                <div style="width: 306px; margin: 0 auto; padding-top: 144px; font-family: Arial, Helvetica, sans-serif; font-size: 10px; margin-top: -213px; position: relative; z-index: 10;">
                    <div style="float: left; padding-bottom: 2px; margin-bottom: 2px;">
                        <div style="float: left; width: 78px;">Printed By :</div>
                        <div style="float: left; width: 106px; overflow: hidden;">
                            <b>
                                <label id="lblPatCardPrintedBy"></label>
                            </b>
                        </div>
                    </div>
                    <div style="float: left; padding-bottom: 2px; margin-bottom: 2px;">
                        <div style="float: left; width: 78px;">Print Date/Time:</div>

                        <div style="float: left; width: 130px; overflow: hidden;">
                            <b>
                                <label id="lblDAte"></label>
                            </b>
                        </div>
                    </div>
                    <div style="float: left; padding-bottom: 2px; margin-bottom: 2px;">
                        <div style="float: left; width: 130px; overflow: hidden;">
                            <b></b>
                        </div>
                    </div>
                    <div style="color: #fff; float: right; margin-top: 21px;">Print Location: Private Clinic</div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
