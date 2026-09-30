<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Alinger.aspx.cs" Inherits="PMS.Alinger" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">


    <link href="<%=Page.ResolveUrl("~/wwwroot/THEME_TIBBIT/CustomCSS/PhysiotherapyAssessment.css") %>" rel="stylesheet" />

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

        .grid-scroll {
            max-height: 190px;
            overflow: auto;
            margin-top: 6px;
        }

        .btn-xs {
            font-size: 11px !important;
            padding: 2px 8px !important;
        }

        .dental-chart-card {
            background: #fff;
            border: 1.5px solid #e4e4e4;
            border-radius: 8px;
            padding: 12px;
            margin-bottom: 16px;
            transition: box-shadow 0.25s ease, border-color 0.25s ease;
        }

        .dental-chart-card:hover {
            border-color: #EFA63E;
            box-shadow: 0 4px 16px rgba(239, 166, 62, 0.1);
        }

        .dental-chart-card .bento-title {
            font-size: 14px;
            margin-bottom: 8px;
            padding-bottom: 6px;
        }

        .dental-legend {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 8px;
            margin-bottom: 6px;
        }

        .dental-legend-item {
            font-size: 11px;
            font-weight: 600;
            color: #777;
            display: inline-flex;
            align-items: center;
            gap: 5px;
        }

        .dental-swatch {
            width: 14px;
            height: 14px;
            border-radius: 3px;
            background: #EFA63E;
            display: inline-block;
        }

        .dental-chart-wrap {
            width: 100%;
        }

        #odontogramSvg {
            width: 100%;
            height: auto;
            display: block;
        }

        .gum {
            fill: none;
            stroke: #f0b8b8;
            stroke-width: 20;
            stroke-linecap: round;
        }

        .tooth {
            cursor: pointer;
        }

        .tooth-shape {
            fill: #ffffff;
            stroke: #b0b0b0;
            stroke-width: 2;
            transition: all 0.15s ease;
        }

        .tooth:hover .tooth-shape {
            stroke: #EFA63E;
            fill: #FDF5E6;
        }

        .tooth.selected .tooth-shape {
            fill: #EFA63E;
            stroke: #b8770f;
        }

        .tooth-num {
            font-size: 13px;
            font-weight: 800;
            fill: #777;
            pointer-events: none;
        }

        .tooth.selected .tooth-num {
            fill: #fff;
        }

        .quad-label {
            font-size: 10px;
            font-weight: 700;
            fill: #aaa;
            letter-spacing: 0.4px;
        }

        .tooth-inputs {
            display: none;
        }
    </style>
    <script type="text/javascript">

        $(document).ready(function () {
            LoadPatientCategory();

            <%if (Request.QueryString["ID"] != null)
        {%>
            $('#btnSave').val("Update");
            LoadAlingerFormImages()
            <%}%>
            $('#AddIndirectveneer').on('click', function () {
                var html;
                html += '<tr><td>' + $('#ctl00_MainContent_ddlIndirectveneer').find('option:selected').text() + '</td> <td><a href="#" onclick="Edit_Alinger(this)">Edit</a>|<a href="#" onclick="Delete_Alinger(this)">Delete</a></td></tr>'
                $('#tblveneer tbody').append(html);
            });
            $('#AddCrownBridge').on('click', function () {
                var html;
                html += '<tr><td>' + $('#ctl00_MainContent_ddlCrown_bridge').find('option:selected').text() + '</td> <td><a href="#" onclick="Edit_Alinger(this)">Edit</a>|<a href="#" onclick="Delete_Alinger(this)">Delete</a></td></tr>'
                $('#tblCrown tbody').append(html);
            });
            //$('#AddAlinger').on('click', function () {
            //    var html;
            //    html += '<tr><td>' + $('#ctl00_MainContent_ddlarch').find('option:selected').text() + '</td><td>' + $('#ctl00_MainContent_ddlno_of_alinger').find('option:selected').text() + '</td><td>' + $('#ctl00_MainContent_ddlMaterial').find('option:selected').text() + '</td><td>' + $('#ctl00_MainContent_ddlMargin').find('option:selected').text() + '</td><td>' + $('#ctl00_MainContent_ddlType_of_Alinger').find('option:selected').text() + '</td><td>' + $('#ctl00_MainContent_ddlThicker').find('option:selected').text() + '</td><td> <a href="#" onclick="Edit_Alinger(this)">Edit</a>|<a href="#" onclick="Delete_Alinger(this)">Delete</a></td></tr>'
            //    $('#tblAlinger tbody').append(html);
            //});;
            $('#AddAlinger').on('click', function () {
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
            buildOdontogram();
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
            $($(row).parents('tr')[0]).remove();
        }
        function Delete_veneer(row) {
            $($(row).parents('tr')[0]).remove();
        }
        function Delete_crown(row) {
            $($(row).parents('tr')[0]).remove();
        }
        function Save_CrownBridges() {
            var table = $('#tblCrown');
            var CrownBridgeList = [];
            table.find('tbody tr').each(function (key, value) {
                var date = '<%= DateTime.Now%>'
                CrownBridgeList.push({
                    'Crown_Bridges_Name': $($(value).find('td')[0]).text(),
                });
            });
            var PatientID = $('#hdfPatient_ID').val();
            var Alingerid = $('#<%= txtAlinger_ID.ClientID%>').val();
            if (Alingerid == '(New)' || Alingerid == '')
                Alingerid = 0;
            var SymtomsList = { Alingerid: Alingerid, PatientID: PatientID, CrownBridgeList: CrownBridgeList }

            PageMethods.Save_CrownBridges(JSON.stringify(SymtomsList), function (response) {

            });
        }
        function Save_Indirect_Veneer() {
            var table = $('#tblveneer');
            var IndirectVeneerList = [];
            table.find('tbody tr').each(function (key, value) {
                var date = '<%= DateTime.Now%>'
                IndirectVeneerList.push({
                    'Indirect_Veneers_Name': $($(value).find('td')[0]).text(),
                });
            });
            var PatientID = $('#hdfPatient_ID').val();
            var Alingerid = $('#<%= txtAlinger_ID.ClientID%>').val();
            if (Alingerid == '(New)' || Alingerid == '')
                Alingerid = 0;
            var SymtomsList = { Alingerid: Alingerid, PatientID: PatientID, IndirectVeneerList: IndirectVeneerList }
            PageMethods.Save_Indirect_Veneer(JSON.stringify(SymtomsList), function (response) {
                Save_CrownBridges();
            });
        }
        function Save_Alinger() {
            var table = $('#tblAlinger');
            var AlingerList = [];
            table.find('tbody tr').each(function (key, value) {
                var date = '<%= DateTime.Now%>'
                AlingerList.push({
                    'Arch': $($(value).find('td')[0]).text(), 'No_Of_Alinger': $($(value).find('td')[1]).text(), 'Material': $($(value).find('td')[2]).text(), 'Margin_of_Alinger': $($(value).find('td')[3]).text(), 'Thicker_of_Alinger': $($(value).find('td')[5]).text(), 'Type_of_Alinger': $($(value).find('td')[4]).text(), 'Template_of_Alinger': $($(value).find('td')[6]).text(),

                });
            });
            var PatientID = $('#hdfPatient_ID').val();
            var Alingerid = $('#<%= txtAlinger_ID.ClientID%>').val();
            if (Alingerid == '(New)' || Alingerid == '')
                Alingerid = 0;
            var AlingerDetails = { Alingerid: Alingerid, PatientID: PatientID, AlingerList: AlingerList }

            PageMethods.Save_Alinger(JSON.stringify(AlingerDetails), function (response) {
                Save_Indirect_Veneer();
            });
        }
        function LoadVeneer() {
            var AlingerID = '<%= Request.QueryString["ID"]%>'
            if (AlingerID != '' && AlingerID != '(New)') {
                PageMethods.LoadVeneer(AlingerID, function (res) {
                    var Alignerss = JSON.parse(res);
                    var rows = '';
                    $.each(Alignerss, function (key, value) {
                        rows += '<tr><td> ' + value.Indirect_Veneers_Name + ' </td>><td> <a href="#" onclick="editMedicine(this)"> Edit </a> | <a href="#" onclick="Delete_veneer(this)"> Delete </a>  </td> </tr>';
                    });
                    $('#tblveneer tbody').append(rows);
                });
            }
        }
        function LoadAlinger() {
            var AlingerID = '<%= Request.QueryString["ID"]%>'
            if (AlingerID != '' && AlingerID != '(New)') {
                PageMethods.LoadAlinger(AlingerID, function (res) {
                    var Alignerss = JSON.parse(res);
                    var rows = '';
                    $.each(Alignerss, function (key, value) {
                        rows += '<tr><td> ' + value.Arch + ' </td><td>' + value.No_Of_Alinger + '</td><td> ' + value.Material + ' </td> <td> ' + value.Margin_of_Alinger + ' </td><td> ' + value.Type_of_Alinger + ' </td><td> ' + value.Thicker_of_Alinger + ' </td><td> ' + value.Template + ' </td><td> <a href="#" onclick="Edit_Alinger(this)"> Edit </a> | <a href="#" onclick="Delete_Alinger(this)"> Delete </a>  </td> </tr>';
                    });
                    $('#tblAlinger tbody').append(rows);
                });
            }
        }
        function LoadCrownBrigdes() {
            var AlingerID = '<%= Request.QueryString["ID"]%>'
            if (AlingerID != '' && AlingerID != '(New)') {
                PageMethods.LoadCrownBrigdes(AlingerID, function (res) {
                    var Alignerss = JSON.parse(res);
                    var rows = '';
                    $.each(Alignerss, function (key, value) {
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
        function LoadAlingerFormImages() {
            var Alinger_Id = '<%= Request.QueryString["ID"]%>';

            PageMethods.LoadAlingerImages(Alinger_Id, function (res) {
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
            var ID = imageId;
            var downloadUrl = 'DownloadFile.ashx?ID=' + ID;
            window.location.href = downloadUrl;
        }

        function readIMGsingle(input) {

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

        function setToothClass(g, on) {
            if (!g) return;
            var cls = g.getAttribute('class') || 'tooth';
            var has = (' ' + cls + ' ').indexOf(' selected ') > -1;
            if (on && !has) {
                g.setAttribute('class', cls + ' selected');
            } else if (!on && has) {
                g.setAttribute('class', (' ' + cls + ' ').replace(' selected ', ' ').replace(/\s+/g, ' ').trim());
            }
        }

        function dentalToggle(key) {
            var $cb = $('input[id$="CHK_' + key + '"]');
            if (!$cb.length) return;
            var on = !$cb.prop('checked');
            $cb.prop('checked', on);
            setToothClass(document.querySelector('.tooth[data-key="' + key + '"]'), on);
        }

        function dentalSelectAll(on) {
            var teeth = document.querySelectorAll('.tooth');
            for (var i = 0; i < teeth.length; i++) {
                var key = teeth[i].getAttribute('data-key');
                $('input[id$="CHK_' + key + '"]').prop('checked', on);
                setToothClass(teeth[i], on);
            }
        }

        function buildOdontogram() {
            var svg = document.getElementById('odontogramSvg');
            if (!svg) return;
            var NS = 'http://www.w3.org/2000/svg';
            var upper = ['S1T8', 'S1T7', 'S1T6', 'S1T5', 'S1T4', 'S1T3', 'S1T2', 'S1T1', 'S2T1', 'S2T2', 'S2T3', 'S2T4', 'S2T5', 'S2T6', 'S2T7', 'S2T8'];
            var lower = ['S4T8', 'S4T7', 'S4T6', 'S4T5', 'S4T4', 'S4T3', 'S4T2', 'S4T1', 'S3T1', 'S3T2', 'S3T3', 'S3T4', 'S3T5', 'S3T6', 'S3T7', 'S3T8'];

            function addLabel(x, y, text) {
                var t = document.createElementNS(NS, 'text');
                t.setAttribute('x', x);
                t.setAttribute('y', y);
                t.setAttribute('class', 'quad-label');
                t.setAttribute('text-anchor', 'middle');
                t.textContent = text;
                svg.appendChild(t);
            }

            function toothShape(num) {
                switch (num) {
                    case 1: return { w: 24, h: 38, cusps: 0 };
                    case 2: return { w: 22, h: 36, cusps: 0 };
                    case 3: return { w: 22, h: 38, cusps: 1 };
                    case 4: return { w: 26, h: 33, cusps: 2 };
                    case 5: return { w: 26, h: 32, cusps: 2 };
                    case 6: return { w: 30, h: 30, cusps: 2 };
                    case 7: return { w: 30, h: 29, cusps: 2 };
                    default: return { w: 27, h: 27, cusps: 2 };
                }
            }

            function toothPath(w, h, cusps) {
                var hw = w / 2, hh = h / 2;
                var r = Math.min(hw, 6);
                var d = 'M ' + (-hw + r) + ' ' + (-hh);
                d += ' Q 0 ' + (-hh - 3) + ' ' + (hw - r) + ' ' + (-hh);
                d += ' Q ' + hw + ' ' + (-hh) + ' ' + hw + ' ' + (-hh + r);
                d += ' L ' + (hw * 0.92) + ' ' + (hh - r * 1.2);
                if (cusps === 1) {
                    d += ' Q ' + (hw * 0.55) + ' ' + (hh + 2) + ' 0 ' + (hh + 4);
                    d += ' Q ' + (-hw * 0.55) + ' ' + (hh + 2) + ' ' + (-hw * 0.92) + ' ' + (hh - r * 1.2);
                } else if (cusps === 2) {
                    d += ' Q ' + (hw * 0.5) + ' ' + (hh + 3) + ' ' + (hw * 0.25) + ' ' + (hh + 1);
                    d += ' Q 0 ' + (hh - 2) + ' ' + (-hw * 0.25) + ' ' + (hh + 1);
                    d += ' Q ' + (-hw * 0.5) + ' ' + (hh + 3) + ' ' + (-hw * 0.92) + ' ' + (hh - r * 1.2);
                } else {
                    d += ' L ' + (-hw * 0.92) + ' ' + (hh - r * 1.2);
                }
                d += ' L ' + (-hw) + ' ' + (-hh + r);
                d += ' Q ' + (-hw) + ' ' + (-hh) + ' ' + (-hw + r) + ' ' + (-hh);
                d += ' Z';
                return d;
            }

            function addGum(d) {
                var p = document.createElementNS(NS, 'path');
                p.setAttribute('d', d);
                p.setAttribute('class', 'gum');
                svg.appendChild(p);
            }

            function makeRow(keys, isUpper) {
                keys.forEach(function (key, i) {
                    var t = (i - 7.5) / 7.5;
                    var x = 40 + i * 34;
                    var y = isUpper ? (104 + 52 * (1 - t * t)) : (264 - 52 * (1 - t * t));
                    var rot = t * 16;
                    var cfg = toothShape(parseInt(key.charAt(3), 10));
                    var g = document.createElementNS(NS, 'g');
                    g.setAttribute('class', 'tooth');
                    g.setAttribute('data-key', key);
                    g.setAttribute('transform', 'translate(' + x + ',' + y + ') rotate(' + rot + ')');
                    var path = document.createElementNS(NS, 'path');
                    path.setAttribute('d', toothPath(cfg.w, cfg.h, cfg.cusps));
                    path.setAttribute('class', 'tooth-shape');
                    if (!isUpper) path.setAttribute('transform', 'scale(1,-1)');
                    g.appendChild(path);
                    var txt = document.createElementNS(NS, 'text');
                    txt.setAttribute('class', 'tooth-num');
                    txt.setAttribute('text-anchor', 'middle');
                    txt.setAttribute('dy', '4');
                    txt.textContent = key.charAt(3);
                    g.appendChild(txt);
                    g.addEventListener('click', function () { dentalToggle(key); });
                    svg.appendChild(g);
                });
            }

            addGum('M 30 94 Q 300 192 570 94');
            addGum('M 30 274 Q 300 176 570 274');
            makeRow(upper, true);
            makeRow(lower, false);
            addLabel(80, 64, 'UPPER LEFT (S1)');
            addLabel(520, 64, 'UPPER RIGHT (S2)');
            addLabel(80, 336, 'LOWER LEFT (S4)');
            addLabel(520, 336, 'LOWER RIGHT (S3)');

            var teeth = document.querySelectorAll('.tooth');
            for (var i = 0; i < teeth.length; i++) {
                var key = teeth[i].getAttribute('data-key');
                setToothClass(teeth[i], $('input[id$="CHK_' + key + '"]').prop('checked'));
            }
        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
        <div class="col-lg-7 col-md-7">

            <div class="bento-card">
                <div class="bento-title">Patient Information</div>
                <div class="row">
                    <div class="col-lg-4 col-md-4">
                        <div class="form-group">
                            <label><asp:Label ID="lblPatien_ID" runat="server" Text="MR No"></asp:Label></label>
                            <asp:TextBox ID="txtPatient_ID" runat="server" ReadOnly="True" CssClass="form-control"></asp:TextBox>
                        </div>
                    </div>
                    <div class="col-lg-4 col-md-4">
                        <div class="form-group">
                            <label><asp:Label ID="LblOut_Patient_ID" runat="server" Text="Out Patient ID"></asp:Label></label>
                            <asp:TextBox ID="txtAlinger_ID" runat="server" ReadOnly="True" CssClass="form-control"></asp:TextBox>
                        </div>
                    </div>
                    <div class="col-lg-4 col-md-4">
                        <div class="form-group">
                            <label><asp:Label ID="dlblFollowNo" runat="server" Text="Follow No"></asp:Label></label>
                            <span id="lblFollow" runat="server" class="readonly-text"></span>
                        </div>
                    </div>
                </div>
                <div class="patient-meta">
                    <div class="meta-item"><span class="meta-label">Patient:</span> <asp:Label ID="vlblPatients_Name" runat="server"></asp:Label></div>
                    <div class="meta-item"><span class="meta-label">Age:</span> <asp:Label ID="vLbl_Age" runat="server"></asp:Label></div>
                    <div class="meta-item"><span class="meta-label">Gender:</span> <asp:Label ID="vLbl_Gender" runat="server"></asp:Label></div>
                    <div class="meta-item"><span class="meta-label">Contact:</span> <asp:Label ID="vLbl_Contact" runat="server"></asp:Label></div>
                    <div class="meta-item"><span class="meta-label">Reg. Date:</span> <asp:Label ID="vLbl_RegDate" runat="server"></asp:Label></div>
                    <div class="meta-item"><span class="meta-label">Address:</span> <asp:Label ID="vLbl_Adress" runat="server"></asp:Label></div>
                    <div class="meta-item"><span class="meta-label">Category:</span> <asp:Label ID="vLbl_PatientCategory" runat="server"></asp:Label></div>
                    <div class="meta-item"><span class="meta-label">Department:</span> <asp:Label ID="lblDpt" runat="server" Text=""></asp:Label></div>
                </div>
                <asp:HiddenField ID="hdfPatient_ID" Value="(New)" runat="server" ClientIDMode="Static" />
                <span style="display: none">
                    <asp:Label ID="lblPatient_Name" runat="server" Text="Patient Name :"></asp:Label>
                    <asp:Label ID="lblContactNo" runat="server" Text="Contact No :"></asp:Label>
                    <asp:Label ID="LblReg_Date" runat="server" Text="Reg. Date:"></asp:Label>
                    <asp:Label ID="lblGender" runat="server" Text="Gender :"></asp:Label>
                    <asp:Label ID="lblAge_Years" runat="server" Text="Age Years :"></asp:Label>
                    <asp:Label ID="lblAdress" runat="server" Text="Address :"></asp:Label>
                    <asp:Label ID="LblPatient_Status" runat="server" Text="Patient Category"></asp:Label>
                    <asp:Label ID="dlbldpt" runat="server" Text="Department"></asp:Label>
                </span>
            </div>

            <div class="bento-card">
                <div class="bento-title">Aligner</div>
                <div class="row">
                    <div class="col-lg-3 col-md-3">
                        <div class="form-group">
                            <label>Arch</label>
                            <asp:DropDownList ID="ddlarch" runat="server" AppendDataBoundItems="true" CssClass="form-control"></asp:DropDownList>
                        </div>
                    </div>
                    <div class="col-lg-3 col-md-3">
                        <div class="form-group">
                            <label>No. of Aligner</label>
                            <asp:DropDownList ID="ddlno_of_alinger" runat="server" AppendDataBoundItems="true" CssClass="form-control"></asp:DropDownList>
                        </div>
                    </div>
                    <div class="col-lg-3 col-md-3">
                        <div class="form-group">
                            <label>Material</label>
                            <asp:DropDownList ID="ddlMaterial" runat="server" AppendDataBoundItems="true" CssClass="form-control"></asp:DropDownList>
                        </div>
                    </div>
                    <div class="col-lg-3 col-md-3">
                        <div class="form-group">
                            <label>Margin of Aligner</label>
                            <asp:DropDownList ID="ddlMargin" runat="server" AppendDataBoundItems="true" CssClass="form-control"></asp:DropDownList>
                        </div>
                    </div>
                    <div class="col-lg-3 col-md-3">
                        <div class="form-group">
                            <label>Type of Aligner</label>
                            <asp:DropDownList ID="ddlType_of_Alinger" runat="server" AppendDataBoundItems="true" CssClass="form-control"></asp:DropDownList>
                        </div>
                    </div>
                    <div class="col-lg-3 col-md-3">
                        <div class="form-group">
                            <label>Thicker</label>
                            <asp:DropDownList ID="ddlThicker" runat="server" AppendDataBoundItems="true" CssClass="form-control"></asp:DropDownList>
                        </div>
                    </div>
                    <div class="col-lg-3 col-md-3">
                        <div class="form-group">
                            <label>Template</label>
                            <asp:DropDownList ID="ddlTemplate" runat="server" AppendDataBoundItems="true" CssClass="form-control"></asp:DropDownList>
                        </div>
                    </div>
                    <div class="col-lg-3 col-md-3">
                        <div class="form-group">
                            <label>&nbsp;</label>
                            <input type="button" value="ADD" id="AddAlinger" class="btn btn-primry" style="display: block; width: 100%" />
                        </div>
                    </div>
                </div>
                <div class="grid-scroll">
                    <table class="diag-table" id="tblAlinger">
                        <thead>
                            <tr>
                                <th>Arch</th>
                                <th>No.</th>
                                <th>Material</th>
                                <th>Margin</th>
                                <th>Type</th>
                                <th>Thicker</th>
                                <th>Template</th>
                                <th>Edit</th>
                            </tr>
                        </thead>
                        <tbody>
                        </tbody>
                    </table>
                </div>
            </div>

            <div class="row">
                <div class="col-lg-6 col-md-6">
                    <div class="bento-card">
                        <div class="bento-title">Crown &amp; Bridges</div>
                        <div class="row">
                            <div class="col-lg-9 col-md-9">
                                <div class="form-group">
                                    <label>Type of Crown / Bridge</label>
                                    <asp:DropDownList ID="ddlCrown_bridge" runat="server" AppendDataBoundItems="true" CssClass="form-control"></asp:DropDownList>
                                </div>
                            </div>
                            <div class="col-lg-3 col-md-3">
                                <div class="form-group">
                                    <label>&nbsp;</label>
                                    <input type="button" value="ADD" id="AddCrownBridge" class="btn btn-primry" style="display: block; width: 100%" />
                                </div>
                            </div>
                        </div>
                        <div class="grid-scroll">
                            <table class="diag-table" id="tblCrown">
                                <thead>
                                    <tr>
                                        <th>Type of Crown / Bridge</th>
                                        <th>Edit</th>
                                    </tr>
                                </thead>
                                <tbody>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
                <div class="col-lg-6 col-md-6">
                    <div class="bento-card">
                        <div class="bento-title">Indirect Veneers</div>
                        <div class="row">
                            <div class="col-lg-9 col-md-9">
                                <div class="form-group">
                                    <label>Indirect Veneer</label>
                                    <asp:DropDownList ID="ddlIndirectveneer" runat="server" AppendDataBoundItems="true" CssClass="form-control"></asp:DropDownList>
                                </div>
                            </div>
                            <div class="col-lg-3 col-md-3">
                                <div class="form-group">
                                    <label>&nbsp;</label>
                                    <input type="button" value="ADD" id="AddIndirectveneer" class="btn btn-primry" style="display: block; width: 100%" />
                                </div>
                            </div>
                        </div>
                        <div class="grid-scroll">
                            <table class="diag-table" id="tblveneer">
                                <thead>
                                    <tr>
                                        <th>Indirect Veneer</th>
                                        <th>Edit</th>
                                    </tr>
                                </thead>
                                <tbody>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>

            <div class="bento-card">
                <div class="bento-title">Images</div>
                <div class="row">
                    <div class="col-lg-4 col-md-4" style="text-align: center">
                        <input id="Button_AT" type="button" class="btn btn-primry" onclick="triggerATFileUpload()" value="Upload (AT)" title="Upload Files Only" />
                        <asp:FileUpload ID="fileUpload_CF_AT" runat="server" multiple="multiple" AllowMultiple="true" onchange="readIMGsingle(this)" Style="visibility: hidden;" />
                        <div id="containerAT" style="margin-top: 10px; display: flex; justify-content: center; flex-wrap: wrap; gap: 6px;"></div>
                    </div>
                    <div class="col-lg-4 col-md-4" style="text-align: center">
                        <input id="Button_OP" type="button" class="btn btn-primry" onclick="triggerOPFileUpload()" value="Upload (OP)" title="Upload Files Only" />
                        <asp:FileUpload ID="fileUpload_CF_OP" runat="server" multiple="multiple" AllowMultiple="true" onchange="readIMGsingle(this)" Style="visibility: hidden;" />
                        <div id="containerOP" style="margin-top: 10px; display: flex; justify-content: center; flex-wrap: wrap; gap: 6px;"></div>
                    </div>
                    <div class="col-lg-4 col-md-4" style="text-align: center">
                        <input id="Button_CT" type="button" class="btn btn-primry" onclick="triggerCTFileUpload()" value="Upload (CT)" title="Upload Files Only" />
                        <asp:FileUpload ID="fileUpload_CF_CT" runat="server" multiple="multiple" AllowMultiple="true" onchange="readIMGsingle(this)" Style="visibility: hidden;" />
                        <div id="containerCT" style="margin-top: 10px; display: flex; justify-content: center; flex-wrap: wrap; gap: 6px;"></div>
                    </div>
                </div>
                <div id="ImageContainer" style="min-height: 90px; display: flex; flex-wrap: wrap; gap: 10px; margin-top: 14px; justify-content: center;"></div>
            </div>

            <div class="body-save-row" >
                <asp:Button ID="btnSave" runat="server" CssClass="btn btn-primry" TabIndex="22" Text="Save" OnClientClick="this.disabled = true; Save_Alinger();" UseSubmitBehavior="false" OnClick="btnSave_Click" />
                <input style="display:none" type="button" value="New" class="btn btn-gray" onclick="NewWindow()" />
                <input type="button" id="btnBackList" value="List View" class="btn btn-gray" onclick="BackToList()" />
            </div>
            <asp:Label ID="Label1" runat="server"></asp:Label>
            <asp:ValidationSummary ID="ValidationSummary2" runat="server" ForeColor="Red" HeaderText="Page Errors" ShowSummary="true" DisplayMode="List" />

        </div>
        <div class="col-lg-5 col-md-5">

            <div class="dental-chart-card">
                <div class="bento-title">Dental Chart</div>
                <div class="dental-legend">
                    <span class="dental-legend-item"><span class="dental-swatch"></span> Selected Tooth</span>
                    <span class="dental-quick">
                        <button type="button" class="btn btn-gray btn-xs" onclick="dentalSelectAll(true)">All</button>
                        <button type="button" class="btn btn-gray btn-xs" onclick="dentalSelectAll(false)">None</button>
                    </span>
                </div>
                <div class="dental-chart-wrap">
                    <svg id="odontogramSvg" viewBox="0 0 600 360" preserveAspectRatio="xMidYMid meet"></svg>
                </div>
                <div class="tooth-inputs">
                    <asp:CheckBox ID="CHK_S1T1" runat="server" />
                    <asp:CheckBox ID="CHK_S1T2" runat="server" />
                    <asp:CheckBox ID="CHK_S1T3" runat="server" />
                    <asp:CheckBox ID="CHK_S1T4" runat="server" />
                    <asp:CheckBox ID="CHK_S1T5" runat="server" />
                    <asp:CheckBox ID="CHK_S1T6" runat="server" />
                    <asp:CheckBox ID="CHK_S1T7" runat="server" />
                    <asp:CheckBox ID="CHK_S1T8" runat="server" />
                    <asp:CheckBox ID="CHK_S2T1" runat="server" />
                    <asp:CheckBox ID="CHK_S2T2" runat="server" />
                    <asp:CheckBox ID="CHK_S2T3" runat="server" />
                    <asp:CheckBox ID="CHK_S2T4" runat="server" />
                    <asp:CheckBox ID="CHK_S2T5" runat="server" />
                    <asp:CheckBox ID="CHK_S2T6" runat="server" />
                    <asp:CheckBox ID="CHK_S2T7" runat="server" />
                    <asp:CheckBox ID="CHK_S2T8" runat="server" />
                    <asp:CheckBox ID="CHK_S3T1" runat="server" />
                    <asp:CheckBox ID="CHK_S3T2" runat="server" />
                    <asp:CheckBox ID="CHK_S3T3" runat="server" />
                    <asp:CheckBox ID="CHK_S3T4" runat="server" />
                    <asp:CheckBox ID="CHK_S3T5" runat="server" />
                    <asp:CheckBox ID="CHK_S3T6" runat="server" />
                    <asp:CheckBox ID="CHK_S3T7" runat="server" />
                    <asp:CheckBox ID="CHK_S3T8" runat="server" />
                    <asp:CheckBox ID="CHK_S4T1" runat="server" />
                    <asp:CheckBox ID="CHK_S4T2" runat="server" />
                    <asp:CheckBox ID="CHK_S4T3" runat="server" />
                    <asp:CheckBox ID="CHK_S4T4" runat="server" />
                    <asp:CheckBox ID="CHK_S4T5" runat="server" />
                    <asp:CheckBox ID="CHK_S4T6" runat="server" />
                    <asp:CheckBox ID="CHK_S4T7" runat="server" />
                    <asp:CheckBox ID="CHK_S4T8" runat="server" />
                </div>
            </div>

        </div>
    </div>
</asp:Content>
