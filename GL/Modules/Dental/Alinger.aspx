<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Alinger.aspx.cs" Inherits="PMS.Alinger" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

    <script type="text/javascript" src="Scripts/jquery.tokeninput.js"></script>
    <script type="text/javascript" src="<%=Page.ResolveUrl("~/Scripts/jquery.tokeninput.js") %>"></script>
    <link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/Styles/jquery.datetimepicker.css") %>" />
    <link href="Styles/jquery.ptTimeSelect.css" rel="stylesheet" />
    <script src="Scripts/jquery.ptTimeSelect.js" type="text/javascript"></script>
    <link href="css/report.css" rel="stylesheet" />
    <script src="<%=Page.ResolveUrl("~/Scripts/jquery.datetimepicker.js") %>" type="text/javascript"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.3/css/select2.min.css" rel="stylesheet" />
    <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.3/js/select2.min.js"></script>

    <style type="text/css">
        .textComment {
            margin-left: 20px;
            padding-left: 20px;
        }

        #ctl00_MainContent_Label13 {
            width: 20px;
        }

        .widthtbl {
            width: 400px;
        }

        .dreProct {
            width: 200px;
        }

        .widthtbl tr td {
            padding: 2px;
        }

        #btnSave:focus {
            background-color: green !important;
        }

        div.token-input-dropdown {
            overflow: auto;
            max-height: 150px;
        }

        @media (min-width: 768px) {
            .modal-dialog {
                width: 1060px;
                margin: 30px auto;
            }
        }

        #tblCheckboxex tr td {
            width: 200px !important;
        }

        #ptTimeSelectCntr {
            z-index: 9999 !important;
        }

        #tblHistory tr td {
            width: 200px;
        }

        gf .table {
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
            background-color: #ff7979;
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

        #vitalparams tr td {
            padding-left: 5px;
        }
    </style>
    <script type="text/javascript">

        $(document).ready(function () {
            LoadPatientCategory();
            $('#<%= txtAlinger_ID.ClientID%>').change(function () {
                loadAjax();
                $('#<%= txtPatient_ID.ClientID%>').val($('#<%= hdfPatient_ID.ClientID%>').val());
            });

            <%if (Request.QueryString["ID"] != null)
        {%>
            $('#btnSave').val("Update");
            LoadAlingerFormImages()
            <%}%>
            $('#AddIndirectveneer').on('click', function () {
                debugger;
                var html;
                html += '<tr><td>' + $('#ctl00_MainContent_ddlIndirectveneer').find('option:selected').text() + '</td> <td><a href="#" onclick="Edit_Alinger(this)">Edit</a>|<a href="#" onclick="Delete_Alinger(this)">Delete</a></td></tr>'
                $('#tblveneer tbody').append(html);
            });
            $('#AddCrownBridge').on('click', function () {
                debugger;
                var html;
                html += '<tr><td>' + $('#ctl00_MainContent_ddlCrown_bridge').find('option:selected').text() + '</td> <td><a href="#" onclick="Edit_Alinger(this)">Edit</a>|<a href="#" onclick="Delete_Alinger(this)">Delete</a></td></tr>'
                $('#tblCrown tbody').append(html);
            });
            debugger;
            //$('#AddAlinger').on('click', function () {
            //    debugger;
            //    var html;
            //    html += '<tr><td>' + $('#ctl00_MainContent_ddlarch').find('option:selected').text() + '</td><td>' + $('#ctl00_MainContent_ddlno_of_alinger').find('option:selected').text() + '</td><td>' + $('#ctl00_MainContent_ddlMaterial').find('option:selected').text() + '</td><td>' + $('#ctl00_MainContent_ddlMargin').find('option:selected').text() + '</td><td>' + $('#ctl00_MainContent_ddlType_of_Alinger').find('option:selected').text() + '</td><td>' + $('#ctl00_MainContent_ddlThicker').find('option:selected').text() + '</td><td> <a href="#" onclick="Edit_Alinger(this)">Edit</a>|<a href="#" onclick="Delete_Alinger(this)">Delete</a></td></tr>'
            //    $('#tblAlinger tbody').append(html);
            //});;
            $('#AddAlinger').on('click', function () {
                debugger;
                var numberOfRows = parseInt($('#ctl00_MainContent_ddlno_of_alinger').find('option:selected').text(), 10);
                if (isNaN(numberOfRows) || numberOfRows <= 0) {
                    alert("Please select a valid number of aligners.");
                    return;
                }

                var arch = $('#ctl00_MainContent_ddlarch').find('option:selected').text();
                var material = $('#ctl00_MainContent_ddlMaterial').find('option:selected').text();
                var margin = $('#ctl00_MainContent_ddlMargin').find('option:selected').text();
                var typeOfAligner = $('#ctl00_MainContent_ddlType_of_Alinger').find('option:selected').text();
                var thicker = $('#ctl00_MainContent_ddlThicker').find('option:selected').text();
                var Template = $('#ctl00_MainContent_ddlTemplate').find('option:selected').text();

                var html = '';

                for (var i = 1; i <= numberOfRows; i++) {
                    html += '<tr>' +
                        '<td>' + arch + '</td>' +
                        '<td>' + i + '</td>' +
                        '<td>' + material + '</td>' +
                        '<td>' + margin + '</td>' +
                        '<td>' + typeOfAligner + '</td>' +
                        '<td>' + thicker + '</td>' +
                        '<td>' + Template + '</td>' +
                        '<td><a href="#" onclick="Edit_Alinger(this)">Edit</a> | <a href="#" onclick="Delete_Alinger(this)">Delete</a></td>' +
                        '</tr>';
                }
                $('#tblAlinger tbody').append(html);
            });
            LoadCrownBrigdes();
            LoadVeneer();
            LoadAlinger();
            bindControls();
            ;
            debugger;
           // var Out_Patient_id = '<%= Request.QueryString["ID"]%>'
            var Out_Patient_id = $('#ctl00_MainContent_txtAlinger_ID').val()
            if (Out_Patient_id != null) {
                debugger;
            }
            if (Out_Patient_id != "") {
                setTimeout(function () {
                    $("#tabs").tabs("option", "active", 1);
                }, 8000);
            }
            else {
                setTimeout(function () {
                    $("#ctl00_MainContent_ddlDepartment").val(0);
                    $("#tabs").tabs("option", "active", 0);
                    $('#ui-id-20').hide();
                    $('#ui-id-21').hide();
                    $('#ui-id-19').hide();
                }, 3000);
            }
        });
        $(function () {
            $("#tabs").tabs();
        });

        function Edit_Alinger(AnchorTag) {
            var row = $(AnchorTag).parents('tr')[0];
            $('#ctl00_MainContent_ddlarch').find('option:contains(' + $(row).find('td')[0].innerText + ')')[0].selected = true;
            $('#ctl00_MainContent_ddlMaterial').find('option:contains(' + $(row).find('td')[2].innerText + ')')[0].selected = true;
            $('#ctl00_MainContent_ddlMargin').find('option:contains(' + $(row).find('td')[3].innerText + ')')[0].selected = true;
            $('#ctl00_MainContent_ddlType_of_Alinger').find('option:contains(' + $(row).find('td')[4].innerText + ')')[0].selected = true;
            $('#ctl00_MainContent_ddlThicker').find('option:contains(' + $(row).find('td')[5].innerText + ')')[0].selected = true;
            $('#ctl00_MainContent_ddlTemplate').find('option:contains(' + $(row).find('td')[6].innerText + ')')[0].selected = true;
        }
       
        function Delete_Alinger(row) {
            debugger;
            $($(row).parents('tr')[0]).remove();
        }
        debugger;
        function Delete_veneer(row) {
            debugger;
            $($(row).parents('tr')[0]).remove();
        }
        debugger;
        function Delete_crown(row) {
            debugger;
            $($(row).parents('tr')[0]).remove();
        }
        debugger;
        function Save_CrownBridges() {
            debugger;
            var table = $('#tblCrown');
            var CrownBridgeList = [];
            table.find('tbody tr').each(function (key, value) {
                var date = '<%= DateTime.Now%>'
                CrownBridgeList.push({
                    'Crown_Bridges_Name': $($(value).find('td')[0]).text(),
                });
            });
            var PatientID = $('#<%= txtPatient_ID.ClientID%>').val();
            var Alingerid = $('#<%= txtAlinger_ID.ClientID%>').val();
            if (Alingerid == '(New)' || Alingerid == '')
                Alingerid = 0;
            var SymtomsList = { Alingerid: Alingerid, PatientID: PatientID, CrownBridgeList: CrownBridgeList }

            PageMethods.Save_CrownBridges(JSON.stringify(SymtomsList), function (response) {

            });
        }
        debugger;
        function Save_Indirect_Veneer() {
            debugger;
            var table = $('#tblveneer');
            var IndirectVeneerList = [];
            table.find('tbody tr').each(function (key, value) {
                var date = '<%= DateTime.Now%>'
                IndirectVeneerList.push({
                    'Indirect_Veneers_Name': $($(value).find('td')[0]).text(),
                });
            });
            var PatientID = $('#<%= txtPatient_ID.ClientID%>').val();
            var Alingerid = $('#<%= txtAlinger_ID.ClientID%>').val();
            if (Alingerid == '(New)' || Alingerid == '')
                Alingerid = 0;
            var SymtomsList = { Alingerid: Alingerid, PatientID: PatientID, IndirectVeneerList: IndirectVeneerList }
            PageMethods.Save_Indirect_Veneer(JSON.stringify(SymtomsList), function (response) {
                Save_CrownBridges();
            });
        }
        debugger;
        function Save_Alinger() {
            debugger;
            var table = $('#tblAlinger');
            var AlingerList = [];
            table.find('tbody tr').each(function (key, value) {
                var date = '<%= DateTime.Now%>'
                AlingerList.push({
                    'Arch': $($(value).find('td')[0]).text(), 'No_Of_Alinger': $($(value).find('td')[1]).text(), 'Material': $($(value).find('td')[2]).text(), 'Margin_of_Alinger': $($(value).find('td')[3]).text(), 'Thicker_of_Alinger': $($(value).find('td')[5]).text(), 'Type_of_Alinger': $($(value).find('td')[4]).text(), 'Template_of_Alinger': $($(value).find('td')[6]).text(),

                });
            });
            var PatientID = $('#<%= txtPatient_ID.ClientID%>').val();
            var Alingerid = $('#<%= txtAlinger_ID.ClientID%>').val();
            if (Alingerid == '(New)' || Alingerid == '')
                Alingerid = 0;
            var AlingerDetails = { Alingerid: Alingerid, PatientID: PatientID, AlingerList: AlingerList }

            PageMethods.Save_Alinger(JSON.stringify(AlingerDetails), function (response) {
                Save_Indirect_Veneer();
            });
        }
        debugger;
        function LoadVeneer() {
            debugger;
            var AlingerID = '<%= Request.QueryString["ID"]%>'
            if (AlingerID != '(New)') {
                PageMethods.LoadVeneer(AlingerID, function (res) {
                    var Alignerss = JSON.parse(res);
                    debugger;
                    var rows = '';
                    $.each(Alignerss, function (key, value) {
                        debugger;
                        rows += '<tr><td> ' + value.Indirect_Veneers_Name + ' </td>><td> <a href="#" onclick="editMedicine(this)"> Edit </a> | <a href="#" onclick="Delete_veneer(this)"> Delete </a>  </td> </tr>';
                    });
                    $('#tblveneer tbody').append(rows);
                });
            }
        }
        debugger;
        function LoadAlinger() {
            debugger;
            var AlingerID = '<%= Request.QueryString["ID"]%>'
            if (AlingerID != '(New)') {
                PageMethods.LoadAlinger(AlingerID, function (res) {
                    var Alignerss = JSON.parse(res);
                    debugger;
                    var rows = '';
                    $.each(Alignerss, function (key, value) {
                        debugger;
                        rows += '<tr><td> ' + value.Arch + ' </td><td>' + value.No_Of_Alinger + '</td><td> ' + value.Material + ' </td> <td> ' + value.Margin_of_Alinger + ' </td><td> ' + value.Type_of_Alinger + ' </td><td> ' + value.Thicker_of_Alinger + ' </td><td> ' + value.Template + ' </td><td> <a href="#" onclick="Edit_Alinger(this)"> Edit </a> | <a href="#" onclick="Delete_Alinger(this)"> Delete </a>  </td> </tr>';
                    });
                    $('#tblAlinger tbody').append(rows);
                });
            }
        }
        debugger;
        function LoadCrownBrigdes() {
            debugger;
            var AlingerID = '<%= Request.QueryString["ID"]%>'
            if (AlingerID != '(New)') {
                PageMethods.LoadCrownBrigdes(AlingerID, function (res) {
                    var Alignerss = JSON.parse(res);
                    debugger;
                    var rows = '';
                    $.each(Alignerss, function (key, value) {
                        debugger;
                        rows += '<tr><td> ' + value.Crown_Bridges_Name + ' </td>><td> <a href="#" onclick="editMedicine(this)"> Edit </a> | <a href="#" onclick="Delete_crown(this)"> Delete </a>  </td> </tr>';
                    });
                    $('#tblCrown tbody').append(rows);
                });
            }
        }

        function NewWindow() {
            window.location = "Alinger.aspx";
        }
        function BackToList() {
            window.location = "AlingerList.aspx";
        }
        function httpGet(theUrl) {
            var xmlHttp = null;
            xmlHttp = new XMLHttpRequest();
            xmlHttp.open("GET", theUrl, false);
            xmlHttp.send(null);
            return xmlHttp.responseText;
        }
        function LoadPatientCategory() {
            var Patient_ID = $("#<%= hdfPatient_ID.ClientID %>").val();
            if (Patient_ID != '(New)') {
                PageMethods.GetPatient_CategoryByPat(Patient_ID, function (resp) {
                    var options = '';
                    PageMethods.GetPatient_Category(function (Patient_Category) {
                        $.each(JSON.parse(Patient_Category), function (key, value) {
                            options += '<option value="' + value.DataValue_Name + '" ' + (JSON.parse(resp)[0].Patient_Type == value.DataValue_Name ? 'selected' : '') + ' >' + value.DataValue_Description + '</option>';
                        });
                        $('#ddlPatient_Category').html(options);
                    });
                }, function (e) { });
            }
        }
        function bindControls() {
            var hdFile_ID = $("#hdfPatient_ID").val();
            if (hdFile_ID != "(New)") {
                var Patient_ID = $("#hdfPatient_ID").val();
                var tokendata = httpGet("json.aspx?Table=Patients&Record=Edit&q=" + Patient_ID);
                loadtokenInputs(JSON.parse(tokendata));
            }
            else {
                loadtokenInputsDefault();
            }
        };
        function loadtokenInputs(data) {
            debugger;
            $("#ctl00_MainContent_txtPatient_ID").tokenInput("/json.aspx?Table=Patients",
                {
                    prePopulate: data,
                    tokenLimit: 1,
                    onAdd: function (item) {
                        $("#hdfPatient_ID").val(item.id);
                        debugger;
                        loadAjax();
                    }
                });
        }
        function loadtokenInputsDefault() {
            $('#ctl00_MainContent_txtPatient_ID').tokenInput("json.aspx?Table=Patients",
                {
                    tokenLimit: 1,
                    onAdd: function (item) {
                        try {

                            $("#hdfPatient_ID").val(item.id);
                            localStorage.PatientIDforNewForm = item.id;
                            loadAjax();
                        }
                        catch (err) {
                            alert(err.message);
                        }
                    }
                });
        }
        debugger;
        function loadAjax() {
            debugger;
            var Patient_ID = $("#<%= hdfPatient_ID.ClientID %>").val();
            if (Patient_ID != '(New)') {
                localStorage.PatientIDforNewForm = Patient_ID;
                $.ajax({
                    type: "POST",
                    url: "Alinger.aspx/GetDetail",
                    data: "{'PatientID':" + Patient_ID + "}",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: OnSuccess,
                    failure: function (response) {
                    }
                });
            }
        }
        function OnSuccess(data) {
            if (data.d != '') {
                var mydate = new Date(Date.parse(data.d.Entry_Date));
                var dateR = mydate.toLocaleDateString();
                $('#<%= vlblPatients_Name.ClientID %>').text(ReplaceNullWith_Space(data.d.Name));
                $('#<%= vLbl_Age.ClientID %>').text(ReplaceNullWith_Space(data.d.Age));
                $('#<%= vLbl_Gender.ClientID %>').text(ReplaceNullWith_Space(data.d.Gender));
                $('#<%= vLbl_RegDate.ClientID %>').text(dateR);
                $('#<%= vLbl_Adress.ClientID %>').text(ReplaceNullWith_Space(data.d.Address));
                $('#<%= vLbl_Contact.ClientID %>').text(ReplaceNullWith_Space(data.d.Mobile));
                $('#<%= lblDpt.ClientID %>').text(ReplaceNullWith_Space(data.d.department));
                $('#<%= vLbl_PatientCategory.ClientID %>').text(ReplaceNullWith_Space(data.d.Patient_Type));
                $('#<%= lblFollow.ClientID %>').text(ReplaceNullWith_Space(data.d.Follow));
            }
        }
        function ReplaceNullWith_Space(Data) {
            if (Data == "null")
                return " ";
            else
                return Data;
        }


        function LoadAlingerFormImages() {
            debugger;
            var Alinger_Id = '<%= Request.QueryString["ID"]%>';

            PageMethods.LoadAlingerImages(Alinger_Id, function (res) {
                debugger;
                var container = $('#ImageContainer');
                if (res == null || res == "[]" || res == "undefined") {
                    $("#errorMsg").show();
                    container.html('');
                } else {
                    $("#errorMsg").hide();
                    var images = JSON.parse(res);
                    loadImagesFromDatabase(images, container);
                }
            });
        }

        function loadImagesFromDatabase(images, container) {
            debugger;
            images.forEach(function (image) {
                let img = $(`
            <div>
                <img onclick="window.open(this.src)" style="height:80px;width:80px; display:flex; margin-right:10px;" src="" />
                <a href="#" onclick="downloadImage(${image.Image_ID})">Download</a>
            </div>
        `);

                let imagePath = `AlingerImages/${image.Image_path}`;
                img.find("img").attr("src", imagePath).attr("data-id", image.Image_ID);

                container.append(img);
            });
        }
        function downloadImage(imageId) {
            debugger;
            var ID = imageId;
            var downloadUrl = 'DownloadFile.ashx?ID=' + ID;
            window.location.href = downloadUrl;
        }

        function readIMGsingle(input) {
            debugger;

            var container = ($(input)[0].id == "ctl00_MainContent_fileUpload_CF_OP") ? "#containerOP" : ($(input)[0].id == "ctl00_MainContent_fileUpload_CF_AT") ? "#containerAT" : "#containerCT";
            var CF_Type = ($(input)[0].id == "ctl00_MainContent_fileUpload_CF_OP") ? "op" : ($(input)[0].id == "ctl00_MainContent_fileUpload_CF_AT") ? "at" : "ct";

            $(container).html('');

            var countFiles = $(input)[0].files.length;

            if (CF_Type == "op") {
                OpCount = countFiles;
                console.log(OpCount)
            }

            if (CF_Type == "at") {
                ATCount = countFiles;
                console.log(ATCount)
            }

            if (CF_Type == "ct") {
                CTCount = countFiles;
                console.log(CTCount)
            }

            var imgPath = $(input)[0].value;
            var extn = imgPath.substring(imgPath.lastIndexOf('.') + 1).toLowerCase();
            if (extn == "gif" || extn == "png" || extn == "jpg" || extn == "jpeg") {
                if (typeof (FileReader) != "undefined") {
                    for (var i = 0; i < countFiles; i++) {
                        (function (i) {
                            var reader = new FileReader();
                            reader.onload = function (e) {
                                var img = $('<img />').attr({
                                    'id': 'myImage' + i + "_" + CF_Type,
                                    'src': e.target.result,
                                    'alt': 'JSFiddle logo',
                                    'title': 'JSFiddle logo',
                                    'width': '80 px',
                                    'height': '80 px',
                                    'margin-left': '90px',
                                    'onclick': 'viewLargeImage(this.id)'
                                }).appendTo(container);
                            }
                            reader.readAsDataURL($(input)[0].files[i]);
                        })(i);
                    }
                } else {
                    alert("This browser does not support FileReader.");
                }
            } else {
                alert("Please select only images !");
            }
        }

        function viewLargeImage(id) {
            debugger;
            var newTab = window.open();
            var path = $("#" + id + "").attr("src");
            newTab.document.body.innerHTML = '<img src="' + path + '" width="1101px" height="881px">';
        }

        function triggerCTFileUpload() {
            document.getElementById("<%=fileUpload_CF_CT.ClientID%>").click();
        }
        function triggerOPFileUpload() {

            document.getElementById("<%=fileUpload_CF_OP.ClientID%>").click();
        }
        function triggerATFileUpload() {

            document.getElementById("<%=fileUpload_CF_AT.ClientID%>").click();
        }


    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div style="width: 100%">
        <div style="width: 100%">
            <table style="padding: 20px; width: 700px; height: 161px;">
                <%--<load main content>--%>

                <tr>
                    <td>
                        <asp:Label ID="lblPatien_ID" runat="server" Text="MR No *"></asp:Label>
                    </td>
                    <td style="width: 203px;">
                        <asp:TextBox ID="txtPatient_ID" runat="server"></asp:TextBox>
                    </td>
                    <td>
                        <asp:RequiredFieldValidator ID="rfvPatient_ID" runat="server" ErrorMessage="Enter Patient ID" Text="*" ControlToValidate="txtPatient_ID" ForeColor="Red"></asp:RequiredFieldValidator>
                    </td>
                    <td class="mg">
                        <asp:Label ID="LblOut_Patient_ID" runat="server" Text="Out Patient ID"></asp:Label>

                    </td>
                    <td>
                        <asp:TextBox ID="txtAlinger_ID" runat="server" ReadOnly="True"></asp:TextBox>
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:Label ID="lblPatient_Name" runat="server" Text="Patient Name :"></asp:Label>
                    </td>
                    <td style="width: 203px">
                        <asp:Label ID="vlblPatients_Name" runat="server"></asp:Label>
                    </td>
                    <td></td>
                    <td class="mg">
                        <asp:Label ID="lblContactNo" runat="server" Text="Contact No :"></asp:Label>
                    </td>
                    <td>
                        <asp:Label ID="vLbl_Contact" runat="server"></asp:Label>
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:Label ID="LblReg_Date" runat="server" Text="Reg. Date:"></asp:Label>
                    </td>
                    <td style="width: 203px">
                        <asp:Label ID="vLbl_RegDate" runat="server"></asp:Label>
                    </td>
                    <td></td>
                    <td class="mg">
                        <asp:Label ID="lblGender" runat="server" Text="Gender :"></asp:Label>
                    </td>
                    <td>
                        <asp:Label ID="vLbl_Gender" runat="server"></asp:Label>
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:Label ID="lblAge_Years" runat="server" Text="Age Years :"></asp:Label>
                    </td>
                    <td style="width: 203px">
                        <asp:Label ID="vLbl_Age" runat="server"></asp:Label>

                    </td>
                    <td></td>
                    <td class="mg">
                        <asp:Label ID="lblAdress" runat="server" Text="Address :"></asp:Label>
                    </td>
                    <td>
                        <asp:Label ID="vLbl_Adress" runat="server"></asp:Label>
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:Label ID="LblPatient_Status" runat="server" Text="Patient Category"></asp:Label>
                    </td>
                    <td style="width: 203px;">
                        <asp:Label ID="vLbl_PatientCategory" runat="server"></asp:Label>

                    </td>
                    <td></td>
                    <td class="mg">
                        <asp:Label ID="dlbldpt" runat="server" Text="Department"></asp:Label></td>
                    <td>
                        <asp:Label ID="lblDpt" runat="server" Text=""></asp:Label></td>
                </tr>
                <tr>
                    <td>
                        <asp:Label ID="dlblFollowNo" runat="server" Text="Follow No"></asp:Label>
                    </td>
                    <td>
                        <span id="lblFollow" runat="server"></span>
                    </td>
                </tr>
            </table>

        </div>
        <br />
    </div>
    <style>
        .profile-images-card {
            margin: auto;
            /* display: table;*/
            background: #fff;
            padding: 30px 50px;
        }

        .profile-images {
            width: 190px;
            height: 180px;
            background: #fff;
            overflow: hidden;
        }

            .profile-images img {
                width: 100%;
                height: 100%;
                object-fit: cover;
            }

        .custom-file label {
            cursor: pointer;
            color: #000;
            text-align: center;
            display: table;
            margin: auto;
            margin-top: 15px;
        }

        #alinger {
            width: 100%;
            height: 100%;
            border: 1px solid grey;
            border-radius: 3px 4px;
        }

        .alinger1 {
            margin-left: 40px;
            /*  border-bottom: 1px solid grey;
                border-radius:3px 4px;*/
        }

            .alinger1 h1 {
                font-size: 25px !important;
                font-weight: 900 !important;
            }

        img {
            width: 120px;
            height: 120px;
            /*margin-left:90px;*/
        }

        .checkboxR {
            float: right;
            width: 20px;
            height: 20px;
        }

        .checkboxL {
            width: 20px;
            height: 20px;
        }

        #containerAT {
            /*max-width: 500px;*/
            padding: 10px;
            overflow: auto;
        }
    </style>
    <div style="width: 100%">

        <div id="tabs">
            <ul>
                <li><a href="#Tab-4">Images</a></li>
                <li><a href="#Tab-1">Alinger</a></li>
                <li><a href="#Tab-2">Crown and Bridges</a></li>
                <li><a href="#Tab-3">Indirect Veneers</a></li>

            </ul>
            <div id="Tab-1">
                <div class="alinger1">
                    <h1>Alinger:</h1>
                    <div class="Alingerdetail" style="width: 100%;">
                        <div class="col-sm-4">
                            <div class="Row1">
                                <label>Arch</label>

                            </div>
                            <div class="Row2">

                                <asp:DropDownList ID="ddlarch" runat="server" AppendDataBoundItems="true" TabIndex="3"></asp:DropDownList>
                            </div>
                        </div>
                        <div class="col-sm-4">
                            <div class="Row1">
                                <label>No.of Alinger</label>

                            </div>
                            <div class="Row2">

                                <asp:DropDownList ID="ddlno_of_alinger" runat="server" AppendDataBoundItems="true" TabIndex="3"></asp:DropDownList>
                            </div>
                        </div>
                        <div class="col-sm-4">
                            <div class="Row1">
                                <label>Material</label>
                            </div>
                            <div class="Row2">

                                <asp:DropDownList ID="ddlMaterial" runat="server" AppendDataBoundItems="true" TabIndex="3"></asp:DropDownList>
                            </div>
                        </div>
                    </div>
                    <div class="Alingerdetail" style="width: 100%">

                        <div class="col-sm-4">
                            <div class="Row1">
                                <label>
                                    Margin of Alinger
                                </label>

                            </div>
                            <div class="Row2">
                                <asp:DropDownList ID="ddlMargin" runat="server" AppendDataBoundItems="true" TabIndex="3"></asp:DropDownList>
                            </div>
                        </div>
                        <div class="col-sm-4">
                            <div class="Row1">
                                <label>Type of Alinger</label>
                            </div>
                            <div class="Row2">
                                <asp:DropDownList ID="ddlType_of_Alinger" runat="server" AppendDataBoundItems="true" TabIndex="3"></asp:DropDownList>
                            </div>
                        </div>
                        <div class="col-sm-4">
                            <div class="Row1">
                                <label>Thicker</label>
                            </div>
                            <div class="Row2">
                                <asp:DropDownList ID="ddlThicker" runat="server" AppendDataBoundItems="true" TabIndex="3"></asp:DropDownList>
                            </div>
                        </div>
                        <%-- --%>
                    </div>
                      <div class="Alingerdetail" style="width: 100%;">
                          <div class="col-sm-4">
                        <div class="Row1">
                            <label>Template</label>
                        </div>
                        <div class="Row2">
                            <asp:DropDownList ID="ddlTemplate" runat="server" AppendDataBoundItems="true" TabIndex="3"></asp:DropDownList>
                        </div>
                    </div>
                          </div>
                    <div class="Alingerdetail" style="width: 100%">
                        <div class="col-sm-4" style="margin-left: 385px;">
                            <div class="Row1" style="margin-top: 23px;">
                                <input type="button" value="ADD" id="AddAlinger" />
                            </div>
                        </div>
                    </div>
                    <div class="row" style="width: 1040px; margin-left: 40px;">
                        <div id="dvtblAlinger" style="margin-left: -55px; margin-top: 230px; width: 1000px; height: 184px; overflow: scroll;">

                            <table class="table" style="height: 30px; overflow: scroll; margin-left: 7px;" id="tblAlinger">
                                <thead>
                                    <th style="display: none;">Row ID</th>
                                    <th style="display: none;">Symtom ID</th>
                                    <th style="width: 100px !important;">Arch </th>
                                    <th style="width: 25px !important;">No.of Alinger </th>
                                    <th style="width: 100px !important;">Material</th>
                                    <th style="width: 100px !important;">Margin of Alinger</th>
                                    <th style="width: 100px !important;">Type of Alinger</th>
                                    <th style="width: 100px !important;">Thicker of Alinger</th>
                                    <th style="width: 100px !important;">Template of Alinger</th>
                                    <th style="width: 50px !important;">Edit</th>
                                </thead>
                                <tbody>
                                </tbody>
                            </table>

                        </div>





                    </div>
                    <%--<div class="row" style="margin-top:25px;margin-left:400px"><input type="button" id="btnSaveAlinger" value="Save" onclick="Saver_Alinger()" /></div>--%>
                </div>
            </div>
            <div id="Tab-2">
                <div class="alinger1">
                    <h1>Crown Bridge</h1>
                    <div class="row" style="width: 100%">
                        <div class="col-sm-4">
                            <div class="Row1">
                                <label>Types Of Crown Bridge</label>

                            </div>
                            <div class="Row2">
                                <asp:DropDownList ID="ddlCrown_bridge" runat="server" AppendDataBoundItems="true" TabIndex="3"></asp:DropDownList>
                            </div>
                        </div>
                        <div class="col-sm-2">
                            <div class="Row1" style="margin-top: 23px; margin-left: -185px;">
                                <input type="button" value="ADD" id="AddCrownBridge" />
                            </div>
                        </div>
                        <div id="dvtblCrown" class="col-sm-6" style="margin-left: 105px; margin-top: -10px; height: 125px; width: 390px; overflow: scroll;">

                            <table class="table" style="width: 490px; height: 30px; overflow: scroll; margin-left: 7px;" id="tblCrown">
                                <thead>
                                    <th style="display: none;">Row ID</th>
                                    <th style="display: none;">Symtom ID</th>
                                    <th style="width: 100px !important;">Types Of Crown Bridge</th>

                                    <th style="width: 50px !important;">Edit</th>
                                </thead>
                                <tbody>
                                </tbody>
                            </table>

                        </div>
                    </div>

                    <div class="row">

                        <div style="/*border: 1px solid; */ width: 400px; height: 250px; margin-top: 140px; margin-left: 250px;">
                            <div class="check-box1" style="border-right: 1px  solid; width: 200px; height: 100px;">
                                <div>
                                    <h4>Upper left Alinger</h4>
                                </div>
                                <div>
                                    <asp:Label ID="lblT1" runat="server" Text=" T1"></asp:Label><asp:CheckBox ID="CHK_S1T1" runat="server"></asp:CheckBox>
                                    <asp:Label ID="lblT2" runat="server" Text=",T2"></asp:Label><asp:CheckBox ID="CHK_S1T2" runat="server"></asp:CheckBox>
                                    <asp:Label ID="lblT3" runat="server" Text=",T3"></asp:Label><asp:CheckBox ID="CHK_S1T3" runat="server"></asp:CheckBox>
                                    <asp:Label ID="lblT4" runat="server" Text=",T4"></asp:Label><asp:CheckBox ID="CHK_S1T4" runat="server"></asp:CheckBox>
                                </div>
                                <div>
                                    <asp:Label ID="lblT5" runat="server" Text=" T5"></asp:Label><asp:CheckBox ID="CHK_S1T5" runat="server"></asp:CheckBox>
                                    <asp:Label ID="lblT6" runat="server" Text=",T6"></asp:Label><asp:CheckBox ID="CHK_S1T6" runat="server"></asp:CheckBox>
                                    <asp:Label ID="lblT7" runat="server" Text=",T7"></asp:Label><asp:CheckBox ID="CHK_S1T7" runat="server"></asp:CheckBox>
                                    <asp:Label ID="lblT8" runat="server" Text=",T8"></asp:Label><asp:CheckBox ID="CHK_S1T8" runat="server"></asp:CheckBox>
                                </div>
                            </div>
                            <div class="check-box4" style="border-top: 1px  solid; width: 200px; height: 100px;">
                                <div style="margin-left: 2px;">
                                    <h4 style="margin-top: 1px">Lower Left Alinger</h4>

                                </div>
                                <div style="margin-left: 2px;">
                                    <asp:Label ID="lblT9" runat="server" Text=" T1"></asp:Label><asp:CheckBox ID="CHK_S4T1" runat="server"></asp:CheckBox>
                                    <asp:Label ID="lblT10" runat="server" Text=",T2"></asp:Label><asp:CheckBox ID="CHK_S4T2" runat="server"></asp:CheckBox>
                                    <asp:Label ID="lblT11" runat="server" Text=",T3"></asp:Label><asp:CheckBox ID="CHK_S4T3" runat="server"></asp:CheckBox>
                                    <asp:Label ID="lblT12" runat="server" Text=",T4"></asp:Label><asp:CheckBox ID="CHK_S4T4" runat="server"></asp:CheckBox>
                                </div>
                                <div style="margin-left: 2px;">
                                    <asp:Label ID="lblT13" runat="server" Text=" T5"></asp:Label><asp:CheckBox ID="CHK_S4T5" runat="server"></asp:CheckBox>
                                    <asp:Label ID="lblT14" runat="server" Text=",T6"></asp:Label><asp:CheckBox ID="CHK_S4T6" runat="server"></asp:CheckBox>
                                    <asp:Label ID="lblT15" runat="server" Text=",T7"></asp:Label><asp:CheckBox ID="CHK_S4T7" runat="server"></asp:CheckBox>
                                    <asp:Label ID="lblT16" runat="server" Text=",T8"></asp:Label><asp:CheckBox ID="CHK_S4T8" runat="server"></asp:CheckBox>
                                </div>
                            </div>
                            <div class="check-box2" style="border-bottom: 1px  solid; width: 200px; height: 100px; margin-left: 200px; margin-top: -209px">
                                <div style="margin-left: 5px;">
                                    <h4>Upper Right Alinger</h4>
                                </div>
                                <div style="margin-left: 5px;">
                                    <asp:Label ID="lblT17" runat="server" Text=" T1"></asp:Label><asp:CheckBox ID="CHK_S2T1" runat="server"></asp:CheckBox>
                                    <asp:Label ID="lblT18" runat="server" Text=",T2"></asp:Label><asp:CheckBox ID="CHK_S2T2" runat="server"></asp:CheckBox>
                                    <asp:Label ID="lblT19" runat="server" Text=",T3"></asp:Label><asp:CheckBox ID="CHK_S2T3" runat="server"></asp:CheckBox>
                                    <asp:Label ID="lblT20" runat="server" Text=",T4"></asp:Label><asp:CheckBox ID="CHK_S2T4" runat="server"></asp:CheckBox>
                                </div>
                                <div style="margin-left: 2px;">
                                    <asp:Label ID="lblT21" runat="server" Text=" T5"></asp:Label><asp:CheckBox ID="CHK_S2T5" runat="server"></asp:CheckBox>
                                    <asp:Label ID="lblT22" runat="server" Text=",T6"></asp:Label><asp:CheckBox ID="CHK_S2T6" runat="server"></asp:CheckBox>
                                    <asp:Label ID="lblT23" runat="server" Text=",T7"></asp:Label><asp:CheckBox ID="CHK_S2T7" runat="server"></asp:CheckBox>
                                    <asp:Label ID="lblT24" runat="server" Text=",T8"></asp:Label><asp:CheckBox ID="CHK_S2T8" runat="server"></asp:CheckBox>
                                </div>
                            </div>
                            <div class="check-box3" style="border-left: 1px solid; width: 200px; height: 100px; margin-left: 199px; margin-top: -10px">
                                <div style="margin-left: 5px;">
                                    <h4>Lower Right Alinger</h4>
                                </div>
                                <div style="margin-left: 5px;">
                                    <asp:Label ID="lblT25" runat="server" Text=" T1"></asp:Label><asp:CheckBox ID="CHK_S3T1" runat="server"></asp:CheckBox>
                                    <asp:Label ID="lblT26" runat="server" Text=",T2"></asp:Label><asp:CheckBox ID="CHK_S3T2" runat="server"></asp:CheckBox>
                                    <asp:Label ID="lblT27" runat="server" Text=",T3"></asp:Label><asp:CheckBox ID="CHK_S3T3" runat="server"></asp:CheckBox>
                                    <asp:Label ID="lblT28" runat="server" Text=",T4"></asp:Label><asp:CheckBox ID="CHK_S3T4" runat="server"></asp:CheckBox>
                                </div>
                                <div style="margin-left: 5px;">
                                    <asp:Label ID="lblT29" runat="server" Text=" T5"></asp:Label><asp:CheckBox ID="CHK_S3T5" runat="server"></asp:CheckBox>
                                    <asp:Label ID="lblT30" runat="server" Text=",T6"></asp:Label><asp:CheckBox ID="CHK_S3T6" runat="server"></asp:CheckBox>
                                    <asp:Label ID="lblT31" runat="server" Text=",T7"></asp:Label><asp:CheckBox ID="CHK_S3T7" runat="server"></asp:CheckBox>
                                    <asp:Label ID="lblT32" runat="server" Text=",T8"></asp:Label><asp:CheckBox ID="CHK_S3T8" runat="server"></asp:CheckBox>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div id="Tab-3">
                <div class="alinger1">
                    <h1>Indirect Veneers:</h1>
                    <div class="row" style="width: 100%">
                        <div class="col-sm-4">
                            <div class="Row1">
                                <label>Indirect Veneers</label>

                            </div>
                            <div class="Row2">
                                <asp:DropDownList ID="ddlIndirectveneer" runat="server" AppendDataBoundItems="true" TabIndex="3"></asp:DropDownList>
                            </div>
                        </div>
                        <div class="col-sm-2">
                            <div class="Row1" style="margin-top: 23px; margin-left: -155px;">
                                <input type="button" value="ADD" id="AddIndirectveneer" />
                            </div>
                        </div>
                        <div id="dvtblveneer" class="col-sm-6" style="margin-left: 105px; margin-top: -10px; height: 125px; width: 390px; overflow: scroll;">

                            <table class="table" style="width: 490px; height: 25px; overflow: scroll; margin-left: 7px;" id="tblveneer">
                                <thead>
                                    <th style="display: none;">Row ID</th>
                                    <th style="display: none;">Symtom ID</th>
                                    <th style="width: 100px !important;">Indirect Veneers</th>

                                    <th style="width: 50px !important;">Edit</th>
                                </thead>
                                <tbody>
                                </tbody>
                            </table>

                        </div>
                    </div>
                </div>
            </div>
            <div id="Tab-4">

                <div class="row" style="margin-top: 25px; text-align: center;">
                    <div class="col-lg-4" style="padding-top: 25px;">
                        <input
                            id="Button_AT"
                            type="button"
                            onclick="triggerATFileUpload()"
                            value="Upload Images"
                            title="Upload Files Only" />
                        <asp:FileUpload
                            ID="fileUpload_CF_AT"
                            runat="server"
                            multiple="multiple"
                            AllowMultiple="true"
                            onchange="readIMGsingle(this)"
                            Style="visibility: hidden;" />
                        <div id="containerAT" style="margin-top: 15px; display: flex; padding-left: 105px;"></div>
                    </div>

                    <div class="col-lg-4" style="padding-top: 25px; text-align: center;">
                        <input
                            id="Button_OP"
                            type="button"
                            onclick="triggerOPFileUpload()"
                            value="Upload Images"
                            title="Upload Files Only" />
                        <asp:FileUpload
                            ID="fileUpload_CF_OP"
                            runat="server"
                            multiple="multiple"
                            AllowMultiple="true"
                            onchange="readIMGsingle(this)"
                            Style="visibility: hidden;" />
                        <div id="containerOP" style="margin-top: 15px; display: flex; padding-left: 105px;"></div>
                    </div>

                    <div class="col-lg-4" style="padding-top: 25px; text-align: center;">
                        <input
                            id="Button_CT"
                            type="button"
                            onclick="triggerCTFileUpload()"
                            value="Upload Images"
                            title="Upload Files Only" />
                        <asp:FileUpload
                            ID="fileUpload_CF_CT"
                            runat="server"
                            multiple="multiple"
                            AllowMultiple="true"
                            onchange="readIMGsingle(this)"
                            Style="visibility: hidden;" />
                        <div id="containerCT" style="margin-top: 15px; display: flex; padding-left: 105px;"></div>
                    </div>
                </div>

                <div class="row">
                    <div id="ImageContainer" style="height: 200px; display: flex; margin-top: 30px;"></div>
                </div>


            </div>

        </div>
        <div style="padding-left: 40px; padding-top: 20px; margin-left: 45px;">
            <table style="padding: 20px; width: 471px; height: 100px;">
                <tr>

                    <asp:HiddenField ID="hdfPatient_ID" Value="(New)" runat="server" ClientIDMode="Static" />

                </tr>
                <tr>
                    <td>
                        <asp:Button ID="btnSave" runat="server" TabIndex="22" Text="Save" OnClientClick="this.disabled = true; Save_Alinger();" UseSubmitBehavior="false" OnClick="btnSave_Click" />
                        &nbsp;
                 <input type="button" value="Clear" name="name" onclick="ClearAll();" style="display: none;" />
                        &nbsp;
                <input type="button" value="New" name="btnName" onclick="NewWindow()" />
                        <input type="button" value="Print" name="name" onclick="PrintInpatientReceipt();" style="width: 100px;" />
                        &nbsp;
                 <input type="button" id="btnBackList" value="List View" onclick="BackToList()" />
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:Label ID="Label1" runat="server"></asp:Label>
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:ValidationSummary ID="ValidationSummary2" runat="server"
                            ForeColor="Red" HeaderText="Page Errors"
                            ShowSummary="true" DisplayMode="List" />
                    </td>
                </tr>
            </table>
        </div>
    </div>

</asp:Content>
