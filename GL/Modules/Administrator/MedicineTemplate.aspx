<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="MedicineTemplate.aspx.cs" Inherits="PMS.MedicineTemplate" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/CustomCSS/MEdTemplate.css" rel="stylesheet" />

    <script type="text/javascript">
        var searchSeq = 0;
        $(document).ready(function () {

            FillRoutes();
            FillDosageQty();
            FillDosage();
            FillFrequency();
            FillRoutes();
            FillOtherInstruction();
            debugger;
            var id = '<%=Request.QueryString["ID"]%>';
            if (id != "") {
                Appendintable();
               
            }

            $('#btnAddMedicine').on("click", function () {

                debugger;
                $("#btnSaveMedicine").val('Save');
                $('#MedicationModel').modal({
                    backdrop: 'static'

                });
                $('#txtMedicen').hide();
                $("#txtMedicineName").hide();
                $("#lblMed").hide();

                $('#txtRecomended_Dosage').val('');
                $('#txtDosage').val('');
                $('#Routes').find('option:nth-child(1)')[0].selected = true;
                $('#txtInjection').val('');
                $('#AttendingParamedicalStaff').val('');
                $('#ddlDosage_From').val('');





            });
            $('#btnSaveMedicine').on("click", function () {
                debugger;



                if ($('#txtPharmacyItem').find('option:selected').text().trim() == 'Reassurance') {
                    $('#txtDosage').val("0");
                    $('#txtInjection').val("0");
                    $('#AttendingParamedicalStaff').val("0");

                }

                if ($('#txtPharmacyItem').val() == 'Select Medicine' || $('#txtPharmacyItem').val() == null) {
                    $('#txtPharmacyItem').val('');
                }


                if ($('#txtPharmacyItem').val() == '') {
                    alert("Please Eneter Name")
                    return false;
                }
                var UnListedMed = $('#txtMedicen').val();

                if ($('#txtPharmacyItem').val() != '')
                    var pharmacyITem = $('#txtPharmacyItem').find('option:selected').text()
                else {
                    var pharmacyITem = $('#txtMedicen').val()
                }


                var Dose = $('#txtDosage').val();
                if (Dose == "") {
                    alert("Please Select Dose ")
                    return false;
                }
                var Frequency = $('#txtRecomended_Dosage').val();
                if (Frequency == "" || Frequency == "0" || Frequency == null) {
                    alert("Please Select Frequency ")
                    return false;
                }
                var DosageFrom = $('#ddlDosage_From').val();
                if (DosageFrom == 'Select') { DosageFrom = ''; }

                var Route = $('#Routes').val();
                if (Route == "Select Routes") { Route = ''; }
                if (Route == "" || Route == "0") {

                }
                var Duration = $('#txtInjection').val();
                if (Duration == "") {
                    alert("Please Select Duration ")
                    return false;
                }
                var datetime = '<%= DateTime.Now.ToString("dd/MM/yyyy  h:m:s A")%>';

                var datetimeValue = '<%= DateTime.Now%>';
                var dosage_from = $('#ddlDosage_From').find('option:selected').text().trim() == 'Select' ? '' : $('#ddlDosage_From').find('option:selected').text();
                var dosage_Qty = $('#ddlDosage_Qty').find('option:selected').text().trim() == 'Select' ? '' : $('#ddlDosage_Qty').find('option:selected').text();
                var routes = $('#Routes').find('option:selected').text().trim() == 'Select Routes' ? '' : $('#Routes').find('option:selected').text();
                var other_Instruction = $('#ddlOther_Instruction').find('option:selected').text().trim() == 'Select' ? '' : $('#ddlOther_Instruction').find('option:selected').text();

                if ($(this).val() == 'Save') {
                    debugger;
                    var medicine = ''//$('#txtMedicineName').val();
                    var pharmacyItem = $('#txtPharmacyItem').val();
                    var itemCode = $('#txtPharmacyItem').find('option:selected').val();
                    if (medicine == '') {
                        debugger;
                        var row = '<tr> <td> <input type="hidden" name="testDate" value="' + datetimeValue + '">' + datetime + ' </td><td><input type="hidden" name="hdnItemCode" value="0"> ' + pharmacyITem + '</td> <td> ' + $('#txtRecomended_Dosage').find('option:selected').text() + ' </td> <td> ' + routes + ' </td> <td> ' + $('#txtInjection').val() + '<td> ' + $('#AttendingParamedicalStaff').val() + '</td><td> ' + dosage_from + '</td><td> ' + dosage_Qty + '</td><td> ' + other_Instruction + ' </td>' + '<td> <a href="#" onclick="editMedicine(this)"> Edit </a> | <a href="#" onclick="deleteMedicine(this)"> Delete </a> <input type="hidden" name="uurowid" value=' + uuid() + ' />  </td><td style="display:none;">' + itemCode + '</td></tr>';
                    }
                    else {
                        debugger;
                        var row = '<tr> <td> <input type="hidden" name="testDate" value="' + datetimeValue + '">' + datetime + ' </td><td> <input type="hidden" name="hdnItemCode" value="' + pharmacyItem + '"> ' + pharmacyITem + '</td> <td> ' + $('#txtRecomended_Dosage').find('option:selected').text() + ' </td> <td> ' + '</td><td> ' + routes + ' </td> <td> ' + $('#txtInjection').val() + '<td> ' + $('#AttendingParamedicalStaff').val() + '</td><td> ' + dosage_from + '</td><td> ' + dosage_Qty + '</td><td> ' + other_Instruction + ' </td>' + '<td> <a href="#" onclick="editMedicine(this)"> Edit </a> | <a href="#" onclick="deleteMedicine(this)"> Delete </a> <input type="hidden" name="uurowid" value=' + uuid() + ' />  </td> <td style="display:none;">' + itemCode + '</td></tr>';
                    }

                    var table = $('#tblMedicinesList tbody');

                    table.append(row);

                }
                else if ($(this).val() == 'Update') {
                    debugger;

                    var tid = $('#MedicationModel input[name=uurowid]').val();

                    var row = $('#tblMedicinesList tbody tr').find('input[value=' + tid + ']').parents('tr')[0];

                    $(row).find('td')[1].innerText = $('#txtPharmacyItem').find('option:selected').text().trim();
                    $(row).find('td')[2].innerText = $('#txtRecomended_Dosage').find('option:selected').text();

                    $(row).find('td')[3].innerText = $('#MedicationModel select[name=Routes]').find('option:selected').text();
                    $(row).find('td')[4].innerText = $('#MedicationModel input[name=txtInjection]').val();
                    $(row).find('td')[5].innerText = $('#MedicationModel input[name=AttendingParamedicalStaff]').val();
                    $(row).find('td')[7].innerText = $('#ddlDosage_Qty').find('option:selected').text().trim();
                    $(row).find('td')[8].innerText = $('#ddlOther_Instruction').find('option:selected').text().trim();
                    var medicine_id = $(row).find('td')[10].innerText;
                    if (medicine_id == '') {
                        $(row).find('td')[1].innerText = $('#txtMedicen').val();
                    }

                    $(row).find('td')[10].innerText = $('#txtPharmacyItem').val();

                    '<a href="#" onclick="editMedicine(this)"> Edit </a> | <a href="#" onclick="deleteMedicine(this)"> Delete </a>'
                }

                $('#txtMedicen').hide();
                $('#txtMedicen').val('');
                $('#txtMedicineName').val('');
                $('#txtRecomended_Dosage').val('');
                $('#txtDosage').val('');
                $('#Routes').find('option:nth-child(1)')[0].selected = true;
                $('#txtInjection').val('');
                $('#AttendingParamedicalStaff').val('');
                $('#txtMedicineName').focus();
                $('#ddlDosage_From').val('');
                $('#ddlDosage_Qty').val('');
                $('#ddlOther_Instruction').val('');
                $('#txtPharmacyItem').val('0').trigger('change');
            });

            FillPharmacyItem();


            $(document).on('input', '.select2-search__field', function () {
                var searchString = $(this).val();
                var $select = $('#txtPharmacyItem');

                if (searchString.length < 2) {
                    $select.empty();
                    $select.append('<option value="0">Please Select</option><option disabled style="color:#999;">Please type 2 or more characters to search</option>');
                    $select.val('0').trigger('change');
                    return;
                }

                searchSeq++;
                var seq = searchSeq;

                $.ajax({
                    url: 'MedicineTemplate.aspx/getpharmacyitems',
                    method: 'POST',
                    contentType: 'application/json',
                    data: JSON.stringify({ searchString: searchString }),
                    success: function (response) {
                        if (seq !== searchSeq) return;

                        try {
                            var pharmacyItems = JSON.parse(response.d);
                            var $select = $('#txtPharmacyItem');

                            var currentVal = $select.val();
                            $select.empty();
                            $.each(pharmacyItems, function (key, value) {
                                $select.append('<option value="' + value.Item_ID + '">' + value.Description + '</option>');
                            });
                            if ($select.find('option[value="' + currentVal + '"]').length > 0)
                                $select.val(currentVal);
                            $select.trigger('change');

                        } catch (error) {
                            console.error('Error parsing response:', error);
                        }
                    },
                    error: function (xhr, status, error) {
                        console.error('Error fetching data:', error);
                    }
                });
            });


            $(document).on('keydown', '.select2-search__field', function (event) {

                if (event.keyCode === 13) {

                    $('#txtPharmacyItem').select2('close');
                }
            });

        });
        function FillPharmacyItem() {
            $('#txtPharmacyItem').html('<option value="0">Please Select</option><option disabled style="color:#999;">Please type 2 or more characters to search</option>');
            $('#txtPharmacyItem').select2({
                width: '100%',
                dropdownAutoWidth: false,
                minimumResultsForSearch: 0,
                dropdownParent: $('#MedicationModel'),
                placeholder: 'Select Medicine',
                allowClear: true
            });
            $('#txtPharmacyItem').val('0').trigger('change');
        }

        function uuid() {
            var uuid = "", i, random;
            for (i = 0; i < 32; i++) {
                random = Math.random() * 16 | 0;

                if (i == 8 || i == 12 || i == 16 || i == 20) {
                    uuid += "-"
                }
                uuid += (i == 12 ? 4 : (i == 16 ? (random & 3 | 8) : random)).toString(16);
            }
            return uuid;
        }
        function FillDosageQty() {
            PageMethods.FillDosageQty(function (Dosage) {
                var options = '<option value=""> Select</option>'
                $.each(JSON.parse(Dosage), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '"> ' + value.DataValue_Description + ' </option>';
                });
                $('#ddlDosage_Qty').html(options);
            });
        }
        function FillDosage() {
            PageMethods.FillDosageDropDown(function (Dosage) {
                var options = '<option value=""> Select</option>'
                $.each(JSON.parse(Dosage), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '"> ' + value.DataValue_Description + ' </option>';
                });
                $('#ddlDosage_From').html(options);
            });
        }
        function FillOtherInstruction() {
            PageMethods.FillOtherInstruction(function (Dosage) {
                var options = '<option value="0"> Select</option>'
                $.each(JSON.parse(Dosage), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '"> ' + value.DataValue_Description + ' </option>';
                });
                $('#ddlOther_Instruction').html(options);
            });
        }

        function FillFrequency() {
            FillPharmacyItem
            PageMethods.FillFrequencyDropDown(function (Frequency) {
                var options = '<option value="0"> Select Frequency  </option>'
                $.each(JSON.parse(Frequency), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '"> ' + value.DataValue_Description + "-" + value.Segment1 + ' </option>';
                });
                $('#txtRecomended_Dosage').html(options);

            });
        }

        function FillRoutes() {
            PageMethods.FillRoutesDropDown(function (Routes) {
                var options = '<option value="0"> Select Routes </option>'
                $.each(JSON.parse(Routes), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '"> ' + value.DataValue_Description + ' </option>';
                });
                $('#Routes').html(options);

            });
        }
        function editMedicine(AnchorTag) {
            debugger;
            $('#MedicationModel').modal({
                backdrop: 'static'
            });

            $('#txtMedicineName').val('');
            $('#txtDosage').val('');
            $('#txtRecomended_Dosage').val('');
            $('#txtOral').val('');
            $('#txtInjection').val('');

            $('#btnSaveMedicine').val('Update');
            var row = $(AnchorTag).parents('tr')[0];
            var Medicine_Id = $($(row).find('td')[10]).text();
            var dosage_qty = $($(row).find('td')[7]).text().trim();
            var dosage_form = $($(row).find('td')[6]).text().trim();
            var frequency = $($(row).find('td')[2]).text().trim();
            var routes = $($(row).find('td')[3]).text().trim();
            var duration = $($(row).find('td')[4]).text().trim();
            var special_instruction = $($(row).find('td')[5]).text().trim();
            var other_instruction = $($(row).find('td')[8]).text().trim();
            $('#txtPharmacyItem').val(Medicine_Id).trigger('change');
            $("#ddlDosage_Qty").find('option:contains(' + dosage_qty + ')')[0].selected = true;
            $("#ddlDosage_From").find('option:contains(' + dosage_form + ')')[0].selected = true;
            $("#txtRecomended_Dosage").find('option:contains(' + frequency + ')')[0].selected = true;
            $("#Routes").find('option:contains(' + routes + ')')[0].selected = true;
            $('#ddlOther_Instruction').find('option:contains(' + other_instruction + ')')[0].selected = true;
            $('#txtMedicineName').val($($(row).find('td')[1]).text());
            if (Medicine_Id == '') {
                $('#txtMedicen').show();
                $('#txtMedicen').val($($(row).find('td')[1]).text());

            }
            else {
                $('#txtMedicen').hide();
                $('#txtMedicen').val('');

            }


            $('#txtInjection').val(duration);
            $('#AttendingParamedicalStaff').val(special_instruction);
            $('#MedicationModel input[name=uurowid]').val($(row).find('input[name=uurowid]').val());


        }
        function deleteMedicine(AnchorTag) {

            var row = $(AnchorTag).parents('tr')[0];
            row.remove();
        }

        function SaveMedicine() {
            debugger;
            var Medicine_Id = '<%=Request.QueryString["ID"]%>';
            var table = $('#tblMedicinesList');
            var MedicinesList = [];
            var itemCodes = [];

            table.find('tbody tr').each(function (key, value) {
                var itemCode = $($(value).find('td')[10]).text();
                itemCodes.push(itemCode);

                MedicinesList.push({
                    'Medicine_Date': $(value).find('td input[name=testDate]').val(),
                    'Medicine_Name': $($(value).find('td')[1]).text(),
                    'Frequency': $($(value).find('td')[2]).text(),
                    'Oral': $($(value).find('td')[3]).text(),
                    'Injection': $($(value).find('td')[4]).text(),
                    'AttendingParamedical_Staff': $($(value).find('td')[5]).text(),
                    'Dosage_From': $($(value).find('td')[6]).text(),
                    'Dosage_Qty': $($(value).find('td')[7]).text(),
                    'Other_Instruction': $($(value).find('td')[8]).text(),
                    'ItemCode': itemCode,
                });
            });

            var MedicineDetails = { Medicine_Id: Medicine_Id, MedicineList: MedicinesList };

            // Function to check if an item code exists
            var checkItemCodeExists = function (itemCode, callback) {
                debugger;
                PageMethods.CheckMedicineTemplateExists(itemCode, function (result) {
                    debugger;
                    var exists = JSON.parse(result);
                    callback(exists);
                }, function (error) {
                    console.error("Error checking item code:", error);
                    callback(false);
                });
            };

            var itemCodeExists = false;

            
            var checkAllItemCodes = function (index) {
                if (index >= itemCodes.length) {
                    if (itemCodeExists) {
                        alert('One or more medicine templates already exist!');
                        return;
                    }

                    
                    PageMethods.SaveMedicines(JSON.stringify(MedicineDetails), function (response) {
                        alert('Data Saved Successfully');
                        window.location = "MedicineTemplate.aspx";
                    }, function (error) {
                        console.error("Error saving medicines:", error);
                        alert('Failed to save medicines.');
                    });
                } else {
                    checkItemCodeExists(itemCodes[index], function (exists) {
                        if (exists) {
                            itemCodeExists = true;
                        }
                        checkAllItemCodes(index + 1);
                    });
                }
            };

            
            if (Medicine_Id != "0") {
                PageMethods.SaveMedicines(JSON.stringify(MedicineDetails), function (response) {
                    alert('Data Saved Successfully');
                    window.location = "MedicineTemplate.aspx";
                }, function (error) {
                    console.error("Error saving medicines:", error);
                    alert('Failed to save medicines.');
                });
            } else {

                checkAllItemCodes(0);
            }
        }


        function NewWindow() {
            window.location = "MedicineTemplate.aspx";
        }
        function gotolist() {
            window.location = "TemplateList.aspx";
        }
        function Appendintable() {
            var temp_id = '<%=Request.QueryString["ID"]%>';
            if (temp_id != "") {
                PageMethods.loadtemplate(temp_id, function (res) {
                    var Medicines = JSON.parse(res);
                    var rows = '';
                    $.each(Medicines, function (key, value) {
                        var timeStamp = parseInt(value.Medicine_Date.substr(6, 10));
                        var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');
                        var datearray = date.split("/");

                        var newdate = datearray[1] + '/' + datearray[0] + '/' + datearray[2];
                        if (value.Oral.trim() == "Select Routes") value.Oral = '';
                        if (value.Dosage_Qty.trim() == "Select") value.Dosage_Qty = '';
                        if (value.Dosage_From.trim() == "Select") value.Dosage_From = '';
                        if (value.Other_Instruction.trim() == "Select") value.Other_Instruction = '';

                        rows += '<tr> <td> <input type="hidden" name="testDate" value="' + date + '">' + newdate + ' </td><td> ' + value.Medicine_Name + ' </td><td>' + value.Frequency + '</td><td> ' + value.Oral + ' </td> <td> ' + value.Injections + ' </td><td> ' + value.AttendingParamedical_Staff + ' </td><td> ' + value.Dosage_From + ' </td><td> ' + value.Dosage_Qty + ' </td><td> ' + value.Other_Instruction + ' </td> <td> <a href="#" onclick="editMedicine(this)"> Edit </a> | <a href="#" onclick="deleteMedicine(this)"> Delete </a> <input type="hidden" name="uurowid" value=' + uuid() + ' />  </td> <td style="display:none;">' + value.Item_Code + '</td> </tr>';
                    });
                    $('#tblMedicinesList tbody').html(rows);
                });
            }
        }

    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">


   <div id="MedicationModel" class="modal fade" role="dialog">
    <div class="modal-dialog modal-lg">
        <!-- Modal content -->
        <div class="modal-content">
            <div class="modal-header" style="background-color: #438eb9 ; color: white;">
                <button type="button" class="close" data-dismiss="modal">&times;</button>
                <h4 class="modal-title">Add Medicine</h4>
            </div>
            <div class="modal-body">
                <fieldset>
                    <legend>Medication Details</legend>
                    <div class="table-responsive">
                        <table id="tblMedicines" class="table table-bordered">
                            <tr>
                                <td>
                                    <span id="pitem">Medicine Name</span><span class="RedStar">*</span>
                                </td>
                                <td>
                                    <select id="txtPharmacyItem" name="txtPharmacyItem" onclick="getTemplate()" class="js-example-basic-single form-control"></select>
                                </td>
                                <td id="MedicineName">
                                    <select id="txtMedicineName" name="txtMedicineName" class="js-example-responsive form-control" onchange="CleardrpdwnItem()"></select>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <span>Dose</span>
                                </td>
                                <td>
                                    <select id="ddlDosage_Qty" name="DosageQty" class="form-control"></select>
                                </td>
                                <td>
                                    <select id="ddlDosage_From" name="DosageFrom" class="form-control" style="width: 40%;"></select>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <span>Frequency</span><span class="RedStar">*</span>
                                </td>
                                <td>
                                    <select id="txtRecomended_Dosage" name="RecomendedDosage" class="form-control"></select>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <span>Route</span>
                                </td>
                                <td>
                                    <select id="Routes" name="Routes" class="form-control"></select>
                                </td>
                                <td>
                                    <span>Other Instructions</span>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <span>Duration (Days/Hours)</span><span class="RedStar">*</span>
                                </td>
                                <td>
                                    <input type="text" id="txtInjection" name="txtInjection" placeholder="Duration" class="form-control" />
                                </td>
                                <td>
                                    <select id="ddlOther_Instruction" name="OtherInstruction" class="form-control"></select>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <span>Special Instructions</span>
                                </td>
                                <td>
                                    <input type="text" name="AttendingParamedicalStaff" id="AttendingParamedicalStaff" class="form-control" />
                                </td>
                                <td>
                                    <input type="text" id="txtMedicen" class="form-control" style="display: none;" />
                                    <span id="lblMed">Medicine Name</span>
                                </td>
                            </tr>
                        </table>
                    </div>
                    <div class="row">
                        <div class="col-lg-10 col-md-8 col-sm-6"></div>
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <input type="button" class="btn btn-primry btn-block" id="btnSaveMedicine" name="btnSaveMedicine" value="Save" />
                        </div>
                    </div>
                    <div class="row mt-3">
                        <div class="col-lg-12 text-right">
                            <input type="button" id="Add_Unlisted_Medicine" value="Add Unlisted Medicine" onclick="NewMedicine()" style="display: none;" class="btn btn-gray" />
                        </div>
                    </div>
                </fieldset>
                <input type="hidden" name="uurowid" value="" />
            </div>
            <div class="modal-footer">
                <div class="row">
                    <div class="col-lg-10 col-md-8 col-sm-6"></div>
                    <div class="col-lg-2 col-md-4 col-sm-6">
                        <input type="button" class="btn btn-gray btn-block" value="Close" data-dismiss="modal" />
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>



    <div id="mdcntable">

        <div class="table-container">
            <div class="row mb-3">
            <div class="col-lg-8">
                <div class="row">
                        <div class="col-lg-2 col-md-2">
                    <input type="button" class="btn-primry" value="Add Medicine" id="btnAddMedicine"/>
                    <label style="font-size: 23px; display: none;">No Medicine</label>
                    <asp:CheckBox ID="chkNo_Medicine" Style="display: none;" runat="server"></asp:CheckBox>
                </div>
                </div>
            </div>
            </div>

            <div class="row">
                <div class="col-12">
                    <div class="table-container">
                        <table class="table table-striped table-bordered " id="tblMedicinesList">
                            <thead>
                                <tr>
                                    <th>Date </th>
                                    <th>Medicine Name </th>
                                    <th>Frequency  </th>
                                    <th>Routes </th>
                                    <th>Duration </th>
                                    <th>Special Instructions </th>
                                    <th>Dosage From </th>
                                    <th>Dosage Qty </th>
                                    <th>Other Instruction</th>
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

    </div>
    <div class="row">
        <div class="col-lg-8">
            <div class="row">
                        <div class="col-lg-2 col-md-3 col-sm-4">
            <input type="button" class="btn btn-primry" id="btnSave" value="Save" onclick="SaveMedicine()" />
        </div>
        <div class="col-lg-2 col-md-3 col-sm-4">
            <input type="button" id="btnnew" class="btn btn-yellow" value="New" onclick="NewWindow()" />
        </div>
        <div class="col-lg-2 col-md-3 col-sm-4">
            <input type="button" class="btn btn-gray" id="btnlist" value="List View" onclick="gotolist()" />
        </div>

            </div>
        </div>
    </div>



</asp:Content>
