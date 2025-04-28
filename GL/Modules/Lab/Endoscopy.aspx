<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Endoscopy.aspx.cs" Inherits="PMS.Endoscopy" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

    <script type="text/javascript" src="<%=Page.ResolveUrl("~/Scripts/jquery.tokeninput.js") %>"></script>
    <link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/Styles/jquery.datetimepicker.css") %>" />
    <script src="<%=Page.ResolveUrl("~/Scripts/jquery.datetimepicker.js") %>" type="text/javascript"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.3/css/select2.min.css" rel="stylesheet" />
    <script src="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.3/js/select2.min.js"></script>

    <style type="text/css">
        /* Don't add a check icon to the radio */
        input[type="radio"].styled:checked + label:after {
            font-family: 'FontAwesome';
            content: '';
        }

        textarea {
            width: 200px !important;
        }
    </style>
	
	<style type="text/css">
        fieldset {
            border: 1px groove #ddd !important;
            padding: 0 1.4em 1.4em 1.4em !important;
            margin: 0 0 1.5em 0 !important;
            -webkit-box-shadow: 0px 0px 0px 0px #000;
            box-shadow: 0px 0px 0px 0px #000;
        }

        legend {
            font-size: 1.2em !important;
            font-weight: bold !important;
            text-align: left !important;
            width: auto;
            padding: 0 10px;
            border-bottom: none;
            margin-bottom: 0px;
        }

        .table {
            margin: 1em 0;
            width: 100%;
            overflow: hidden;
            background: #FFF;
            color: #024457;
            border: 1px solid #167F92;
        }

            .table tr {
                border: 1px solid #D9E4E6;
            }

                .table tr:nth-child(even) {
                    background-color: #EAF3F3;
                }

            .table th {
                display: none;
                border: 1px solid #FFF;
                background-color: #438eb9;
                color: #FFF;
                padding: 1em;
            }

            .table thead th {
                display: table-cell;
                text-align: center;
            }

        @media (min-width: 480px) {
            .table th:nth-child(2) span {
                display: block;
            }

            .table th:nth-child(2):after {
                display: none;
            }
        }

        .table td {
            display: block;
            word-wrap: break-word;
            max-width: 7em;
        }

            .table td:first-child {
                display: table-cell;
                text-align: center;
                border-right: 1px solid #D9E4E6;
            }

        @media (min-width: 480px) {
            .table td {
                border: 1px solid #D9E4E6;
            }
        }

        .table th, .table td {
            text-align: center;
            margin: .5em 1em;
        }

        @media (min-width: 480px) {
            .table th, .table td {
                display: table-cell;
                padding: 1em;
            }
        }

        #test_id {
            width: 60px !important;
            text-align: center;
            font-weight: bold;
        }

        .ErrorAlert {
            border: 1px solid red !important;
        }
    </style>

    <script type="text/javascript">
        function New() {
       
            window.location = "Endoscopy.aspx";
           
        }
        $(function () {
            var date = '<%=DateTime.Now.Date.ToString(AppConfig.DateFormat)%>';
            $('#vPerformed').val(date);
            $('#vReported').val(date);

            GetInstruments();
            var id = '<%= Request.QueryString["id"] %>';

            if (id != '') {
                PageMethods.GetEndoscopy(id, function (res) {
                    var r = JSON.parse(res);
                    var e = r.e;
                    $("#hdfPatient_ID").val(e.Patient_ID);
                    $("#ctl00_MainContent_txtPatient_ID").val(e.Patient_ID);
                    $("#ctl00_MainContent_txtEndoscopy_ID").val(e.Endoscopy_ID);
                    $('#vConsultant').val(e.Consultant);
                    $('#vGI_Fellow').val(e.GI_Fellow);
                    var Performed = '';
                    var Reported = '';
                    if (e.Performed != null) {
                        Performed = moment.unix(parseInt(e.Performed.substr(6, 10))).format('MM/DD/YYYY');
                    }
                    if (e.Reported != null) {
                        Reported = moment.unix(parseInt(e.Reported.substr(6, 10))).format('MM/DD/YYYY');
                    }
                    $('#vPerformed').val(Performed);
                    $('#vReported').val(Reported);
                    bindControls();
                    if (e.Type == "Gastro") {
                        $('#tabs').find('a:contains(Gastro)').click();
                        var g = r.g;
                        $('#eMedicine').val(g.Medicine);
                        $('#eQty').val(g.Qty);
                        $('#eBiopsy').val(g.Biopsy);
                        $('#eInstrument').val(g.Instrument);
                        $('#eRemarks').val(g.Remarks);
                        $('#eShort_History').val(g.Short_History);
                        $('#eOesophagus').val(g.Oesophagus);
                        $('#eContents').val(g.Contents);
                        $('#eCardia').val(g.Cardia);
                        $('#eFundus').val(g.Fundus);
                        $('#eBody').val(g.Body);
                        $('#eAntrum').val(g.Antrum);
                        $('#ePylorus').val(g.Pylorus);
                        $('#eD1').val(g.D1);
                        $('#eD2').val(g.D2);
                        $('[name=eRepeat_Procedure][value=' + g.Repeat_Procedure + ']')[0].checked = true;
                        $('#eTherapeutic_Procedure').val(g.Therapeutic_Procedure);
                        $('#eImpression').val(g.Impression);
                        $('#eRecommendation').val(g.Recommendation)
                    } else {
                        $('#tabs').find('a:contains(Colono)').click();
                        var c = r.c;
                        $('#cMedicine').val(c.Medicine);
                        $('#cQty').val(c.Qty);
                        $('#cInstrument').val(c.Instrument);
                        $('#cBiopsy').val(c.Biopsy);
                        $('#cRemarks').val(c.Remarks);
                        $('#cShort_History').val(c.Short_History);
                        $('#cFindings').val(c.Findings);
                        $('#cRectum').val(c.Rectum);
                        $('#cSigmoid').val(c.Sigmoid);
                        $('#cDescending_Colon').val(c.Descending_Colon);
                        $('#cTransverse_Colon').val(c.Transverse_Colon);
                        $('#cAcending_Colon').val(c.Acending_Colon);
                        $('#cIleo_Cecal_Valve').val(c.Ileo_Cecal_Valve);
                        $('#cIleum').val(c.Ileum);
                        $('[name=cRepeat_Procedure][value=' + c.Repeat_Procedure + ']')[0].checked = true;
                        $('#cTherapeutic_Procedure').val(c.Therapeutic_Procedure);
                        $('#cImpression').val(c.Impression);
                        $('#cRecommendation').val(c.Recommendation);
                    }
                });
            } else {
                bindControls();
            }
            

            $("#vPerformed").datepicker({ dateFormat: 'mm/dd/yy' });
            $("#vReported").datepicker({ dateFormat: 'mm/dd/yy' });

            $("#tabs").tabs();
            
            $('#btnSave').click(function () {

                var type = $('#tabs .ui-tabs-active').find('a').text();
                var data = {};
                data['Endoscopy_ID'] = '<%= Request.QueryString["id"] %>';
                data['Patient_ID'] = $("#hdfPatient_ID").val();
                data['Consultant'] = $('#vConsultant').val();
                data['GI_Fellow'] = $('#vGI_Fellow').val();
                data['Performed'] = $('#vPerformed').val();
                data['Reported'] = $('#vReported').val();
                data['Type'] = type;
                if (type == 'Gastro') {
                    data['Gastro'] = { Medicine: $('#eMedicine').val(), Qty: $('#eQty').val(), Instrument: $('#eInstrument').val(), Biopsy: $('#eBiopsy').val(), Remarks: $('#eRemarks').val(), Short_History: $('#eShort_History').val(), Oesophagus: $('#eOesophagus').val(), Contents: $('#eContents').val(), Cardia: $('#eCardia').val(), Fundus: $('#eFundus').val(), Body: $('#eBody').val(), Antrum: $('#eAntrum').val(), Pylorus: $('#ePylorus').val(), D1: $('#eD1').val(), D2: $('#eD2').val(), Therapeutic_Procedure: $('#eTherapeutic_Procedure').val(), Impression: $('#eImpression').val(), Repeat_Procedure: $('[name=eRepeat_Procedure]:checked').val(), Recommendation: $('#eRecommendation').val() };
                } else if (type == 'Colono') {
                    data['Colono'] = { Medicine: $('#cMedicine').val(), Qty: $('#cQty').val(), Instrument: $('#cInstrument').val(), Biopsy: $('#cBiopsy').val(), Remarks: $('#cRemarks').val(), Short_History: $('#cShort_History').val(), Findings: $('#cFindings').val(), Rectum: $('#cRectum').val(), Sigmoid: $('#cSigmoid').val(), Descending_Colon: $('#cDescending_Colon').val(), Transverse_Colon: $('#cTransverse_Colon').val(), Acending_Colon: $('#cAcending_Colon').val(), Ileo_Cecal_Valve: $('#cIleo_Cecal_Valve').val(), Ileum: $('#cIleum').val(), Therapeutic_Procedure: $('#cTherapeutic_Procedure').val(), Impression: $('#cImpression').val(), Repeat_Procedure: $('[name=cRepeat_Procedure]:checked').val(), Recommendation: $('#cRecommendation').val() };
                }
                PageMethods.SaveEndoscopy(JSON.stringify(data), function (res) {
                    location.href = "EndoscopyList.aspx";
                });
            });
        });

        function Print() {
            var type = $('#tabs .ui-tabs-active').find('a').text();
            var eid = '<%= Request.QueryString["ID"] %>';
            if (type == 'Gastro') {
                window.open('ReportViewer.aspx?ReportName=Gastro&ReportTitle=Department Of Endoscopy&Endoscopy_ID=' + eid);
            } else if (type == 'Colono') {
                window.open('ReportViewer.aspx?ReportName=Colono&ReportTitle=Department Of Endoscopy&Endoscopy_ID=' + eid);
            }
            
        }

        function GetInstruments() {
            PageMethods.GetInstruments(function (res) {
                var instruments = JSON.parse(res);
                var options = '<option value="">Select Instrument</option>';
                $.each(instruments, function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '">' + value.DataValue_Description + '</option>';
                });
                $('#eInstrument').html(options);
                $('#cInstrument').html(options);
            });
        }


        function bindControls() {
            var hdFile_ID = $("#hdfPatient_ID").val();
            if (hdFile_ID != "(New)" && hdFile_ID != null && hdFile_ID != "") {
                var Patient_ID = document.getElementById('<%= txtPatient_ID.ClientID%>').value;
                var tokendata = httpGet("json.aspx?Table=Patients&Record=Edit&q=" + Patient_ID);
              
                loadtokenInputs(JSON.parse(tokendata));
            }
            else {
                loadtokenInputsDefault();
            }
        }

        function hide() {
            $('#tr-1').hide();
            $('#tr-2').hide();
            $('#tr-3').hide();
            $('#tr-4').hide();
        }

        function show() {
            $('#tr-1').show();
            $('#tr-2').show();
            $('#tr-3').show();
            $('#tr-4').show();
        }

        function httpGet(theUrl) {
            var xmlHttp = null;
            xmlHttp = new XMLHttpRequest();
            xmlHttp.open("GET", theUrl, false);
            xmlHttp.send(null);
            return xmlHttp.responseText;
        }

        function loadtokenInputsDefault() {
            $('#ctl00_MainContent_txtPatient_ID').tokenInput("json.aspx?Table=Patients",
             {
                 tokenLimit: 1,
                 onAdd: function (item) {
                     try {
                         $("#hdfPatient_ID").val(item.id);

                         loadAjax();
                     }
                     catch (err) {
                         alert(err.message);
                     }

                 }
             });
        }
        function loadAjax() {
            var Patient_ID = $("#<%= hdfPatient_ID.ClientID %>").val();
            //var Patient_ID =  $("#<%= hdfPatient_ID.ClientID %>").val();
            $.ajax({
                type: "POST",
                url: "Endoscopy.aspx/GetDetail",
                data: "{'PatientID':" + Patient_ID + "}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: OnSuccess,
                failure: function (response) {
                    alert(response.d);
                }
            });
        }
        function OnSuccess(data) {
            if (data.d != '') {
              
                var mydate = new Date(Date.parse(data.d.Entry_Date));
              
                $('#vPatient_Name').text(data.d.Name);
                $('#vAge').text(data.d.Age);
                $('#vGender').text(data.d.Gender);
                $('#vAddress>').text(data.d.Address);
                $('#vAdmission_Mode').text(data.d.Mode_Of_Registration);
         
               
            }
        }
        function loadtokenInputs(data) {
         
                $("#ctl00_MainContent_txtPatient_ID").tokenInput("json.aspx?Table=Patients",
                {  
                    prePopulate: data,
                    tokenLimit: 1,
                    onAdd: function (item) {
                        $("#hdfPatient_ID").val(item.id);
                        //loadAjax();
                    }
                });
                loadAjax();
        }
    </script>

    <style type="text/css">
        .mgTab {
            padding-left: 100px;
        }

        .mg {
            padding-left: 30px;
        }

        .header-center {
            text-align: center;
        }

        .dropdownBackgroud {
            background-color: #f5f5f5 !important;
        }

        .dropdownBackgroudWhite {
            background-color: #fff !important;
        }

        .Error {
            color: #f00;
        }

        .Success {
            color: #4800ff;
        }

        .Checking {
            color: #00ff21;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

        <ContentTemplate>
            <table style="padding: 20px; width: 700px; height: 161px;">

                <tr>
                    <td>
                        <asp:Label ID="lblPatien_ID" runat="server" Text="MrNo :*"></asp:Label>
                    </td>
                    <td style="width: 203px">
                        <asp:TextBox ID="txtPatient_ID" runat="server"></asp:TextBox>
                        <asp:HiddenField ID="hdfPatient_ID" runat="server" Value="(New)" ClientIDMode="Static" />
                    </td>
                    <td>
                        <asp:RequiredFieldValidator ID="rfvPatient_ID" runat="server" ControlToValidate="txtPatient_ID" ErrorMessage="Select Patient ID" Text="*"></asp:RequiredFieldValidator>
                    </td>
                    <td class="mg">
                        <asp:Label ID="LblEndoscopy_ID" runat="server" Text="Endoscopy ID"></asp:Label>
                    </td>
                    <td>
                        <asp:TextBox ID="txtEndoscopy_ID" runat="server" Text="(New)" ReadOnly="True"></asp:TextBox>
                    </td>
                </tr>
                <tr id="tr2">
                        <td></td>
                        <td style="width: 100px;"></td>
                        <td></td>
                        <td class="mg">
                            <span>Consultant :</span>
                        </td>
                        <td>
                            <input type="text" id="vConsultant" />
                        </td>
                        <td></td>
                    </tr>
                <tr id="tr-1">
                        <td>
                            <span>Name :</span>
                        </td>
                        <td style="width: 100px;">
                            <span id="vPatient_Name"></span>
                        </td>
                        <td></td>
                        <td class="mg">
                            <span>GI Fellow :</span>
                        </td>
                        <td>
                            <input type="text" id="vGI_Fellow" />
                        </td>
                        <td></td>
                    </tr>
                    <tr id="tr-2">
                        <td>
                            <span>Address :</span>
                        </td>
                        <td style="width: 100px;">
                            <span id ="vAddress"></span>
                        </td>
                        <td></td>
                        <td class="mg">
                        <label>Performed :</label>
                        </td>
                        <td>
                        <input type="text" id="vPerformed" />
                        </td>
                        <td></td>
                    </tr>
                    <tr id="tr1">
                        <td>
                            <span>Gender :</span>
                        </td>
                        <td style="width: 100px;">
                            <span id="vGender"></span>
                        </td>
                        <td></td>
                        <td class="mg">
                            <label>Reported :</label>
                        </td>
                        <td>
                            <input type="text" id="vReported" />
                        </td>
                        <td></td>
                    </tr>
                    <tr id="tr-3">
                        <td>
                            <span>Age :</span>
                        </td>
                        <td style="width: 100px;">
                            <span id="vAge"></span>
                        </td>
                        <td></td>
                        <td class="mg">
                            <span>Mode of Admission :</span>
                        </td>
                        <td>
                            <span id="vAdmission_Mode"></span>
                        </td>
                        <td></td>
                    </tr>

            </table>
            <style>
                .medication-table input {
                    width: 100% !important;
                }
            </style>
            <br />
            <div style="width: 100%">
                <div id="tabs">
                    <ul>
                        <li><a href="#Tab-1">Gastro</a></li>
                        <li><a href="#Tab-2">Colono</a></li>
                    </ul>
                    <div id="Tab-1">
                        <div class="row">
                            <div class="col-md-8">
                                <table class="table medication-table">
                                    <thead>
                                        <tr>
                                            <th colspan="2">Medications</th>
                                            <th>Instruments</th>
                                            <th colspan="2">Biopsy Submitted</th>
                                        </tr>
                                        <tr>
                                            <th>Medicine</th>
                                            <th>Qty</th>
                                            <th>Instrument</th>
                                            <th>Biopsy</th>
                                            <th>Remarks</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr>
                                            <td><input type="text" id="eMedicine" /></td>
                                            <td><input type="text" id="eQty" /></td>
                                            <td><select style="width: 144px !important;" id="eInstrument"></select></td>
                                            <td><input type="text" id="eBiopsy" /></td>
                                            <td><input type="text" id="eRemarks" /></td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                         </div>
                        <div id="OtherDetails" style="width: 70%">
                            <table>
                                <tr>
                                    <td style="width:214px"><label>SHORT HISTORY</label></td>
                                    <td><input type="text" id="eShort_History" /></td>
                                </tr>
                                <tr>
                                    <td><h4>FINDINGS:</h4></td>
                                </tr>
                                <tr>
                                    <td><label>OESOPHAGUS:</label></td>
                                    <td><input type="text" id="eOesophagus" /></td>
                                </tr>
                                <tr>
                                    <td><h4>STOMACH:</h4></td>
                                </tr>
                                <tr>
                                    <td><label>Contents:</label></td>
                                    <td><input type="text" id="eContents" /></td>
                                </tr>
                                <tr>
                                    <td><label>Cardia:</label></td>
                                    <td><input type="text" id="eCardia" /></td>
                                </tr>
                                <tr>
                                    <td><label>Fundus:</label></td>
                                    <td><input type="text" id="eFundus" /></td>
                                </tr>
                                <tr>
                                    <td><label>Body:</label></td>
                                    <td><input type="text" id="eBody" /></td>
                                </tr>
                                <tr>
                                    <td><label>Antrum:</label></td>
                                    <td><input type="text" id="eAntrum" /></td>
                                </tr>
                                <tr>
                                    <td><label>Pylorus:</label></td>
                                    <td><input type="text" id="ePylorus" /></td>
                                </tr>
                                <tr>
                                    <td><h4>DUODENUM:</h4></td>
                                </tr>
                                <tr>
                                    <td><label>D1:</label></td>
                                    <td><input type="text" id="eD1" /></td>
                                </tr>
                                <tr>
                                    <td><label>D2:</label></td>
                                    <td><input type="text" id="eD2" /></td>
                                </tr>
                                <tr>
                                    <td><h4>REMARKS:</h4></td>
                                </tr>
                                <tr>
                                    <td><label>Therapeutic Procedure:</label></td>
                                    <td><input type="text" id="eTherapeutic_Procedure" /></td>
                                </tr>
                                <tr>
                                    <td><label>IMPRESSION:</label></td>
                                    <td><input type="text" id="eImpression" /></td>
                                </tr>
                                <tr>
                                    <td><label>REPEAT PROCEDURE:</label></td>
                                    <td><input type="radio" name="eRepeat_Procedure" value="1" />Yes<input type="radio" name="eRepeat_Procedure" value="0" checked />No</td>
                                </tr>
                                <tr>
                                    <td><h4>RECOMMENDATION:</h4></td>
                                    <td><textarea id="eRecommendation"></textarea></td>
                                </tr>
                            </table>
                        </div>
                    </div>
                    <div id="Tab-2">
                        <div class="row">
                            <div class="col-md-8">
                                <table class="table medication-table">
                                    <thead>
                                        <tr>
                                            <th colspan="2">Medications</th>
                                            <th>Instruments</th>
                                            <th colspan="2">Biopsy Submitted</th>
                                        </tr>
                                        <tr>
                                            <th>Medicine</th>
                                            <th>Qty</th>
                                            <th>Instrument</th>
                                            <th>Biopsy</th>
                                            <th>Remarks</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr>
                                            <td><input type="text" id="cMedicine" /></td>
                                            <td><input type="text" id="cQty" /></td>
                                            <td><select style="width: 144px !important;" id="cInstrument"></select></td>
                                            <td><input type="text" id="cBiopsy"/></td>
                                            <td><input type="text" id="cRemarks"/></td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                         </div>
                        <div id="VitalParameters" style="width: 70%">
                            <table>
                                <tr>
                                    <td style="width:214px"><label>SHORT HISTORY</label></td>
                                    <td><input type="text" id="cShort_History" /></td>
                                </tr>
                                <tr>
                                    <td><h4>FINDINGS:</h4></td>
                                    <td><textarea id="cFindings"></textarea>
                                </tr>
                                <tr>
                                    <td><h4>RECTUM:</h4></td>
                                    <td><input type="text" id="cRectum" /></td>
                                </tr>
                                <tr>
                                    <td><h4>SIGMOID:</h4></td>
                                    <td><input type="text" id="cSigmoid" /></td>
                                </tr>
                                <tr>
                                    <td><h4>DESCENDING COLON:</h4></td>
                                    <td><input type="text" id="cDescending_Colon" /></td>
                                </tr>
                                <tr>
                                    <td><h4>TRANSVERSE COLON:</h4></td>
                                    <td><input type="text" id="cTransverse_Colon" /></td>
                                </tr>
                                <tr>
                                    <td><h4>ACENDING COLON:</h4></td>
                                    <td><input type="text" id="cAcending_Colon" /></td>
                                </tr>
                                <tr>
                                    <td><h4>ILEO-CECAL VALVE:</h4></td>
                                    <td><input type="text" id="cIleo_Cecal_Valve" /></td>
                                </tr>
                                <tr>
                                    <td><h4>ILEUM:</h4></td>
                                    <td><input type="text" id="cIleum" /></td>
                                </tr>
                                <tr>
                                    <td><label>THERAPEUTIC PROCEDURE:</label></td>
                                    <td><input type="text" id="cTherapeutic_Procedure" /></td>
                                </tr>
                                <tr>
                                    <td><label>IMPRESSION:</label></td>
                                    <td><input type="text" id="cImpression" /></td>
                                </tr>
                                <tr>
                                    <td><label>REPEAT PROCEDURE:</label></td>
                                    <td><input type="radio" name="cRepeat_Procedure" value="1" />Yes<input type="radio" name="cRepeat_Procedure" value="0" checked />No</td>
                                </tr>
                                <tr>
                                    <td><h4>RECOMMENDATION:</h4></td>
                                    <td><textarea id="cRecommendation"></textarea></td>
                                </tr>
                            </table>
                        </div>
                    </div>
                </div>

                <div style="padding-left: 70px; padding-top: 20px;">
                    <table>

                        <tr>
                            <td>
                                <input value="List View" style="width: 95px;" type="button" onclick="location.href='EndoscopyList.aspx'" />
                                &nbsp;&nbsp;
                                <input id="btnSave" style="width: 95px;" type="button" value="Save" />
                                &nbsp;&nbsp;
                                <input type="button" id="btnNew" style="width: 95px;" value="New" onclick="New()" />
                                &nbsp;&nbsp;
                                <%  if(Request.QueryString["ID"] != null){ %>
                                <input type="button" style="width: 95px;" value="Print" onclick="Print()" />
                                <%  } %>
                            </td>
                        </tr>
                        <tr>
                            <td>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:Label ID="lblMessage" runat="server"></asp:Label>
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
        </ContentTemplate>

</asp:Content>
