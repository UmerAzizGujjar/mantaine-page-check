<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="PaymentForm.aspx.cs" Inherits="PMS.PaymentForm" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
     <link href="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.3/css/select2.min.css" rel="stylesheet" />
    <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.3/js/select2.min.js"></script>
    <link href="Styles/jquery.ptTimeSelect.css" rel="stylesheet" />
    <script type="text/javascript" src="Scripts/jquery.ptTimeSelect.js"></script>
    <script type="text/javascript" src="Scripts/jquery.tokeninput.js"></script>
    <script type="text/javascript">
        function BackToPrint() {

            Transaction_ID = '<%= Request.QueryString["ID"]%>'

             window.open('ReportViewer.aspx?ReportName=PaymentBasePrint&ReportTitle=Payment Print' + '&Transaction_ID=' + Transaction_ID);

         }

        function OpenRecord() {

                var ID = '<%= Request.QueryString["ID"]%>';

                if (ID.length > 0) {
                    LoadTransaction(ID);

                }
        }
        function LoadTransaction(ID) {

            PageMethods.LoadTransactionHeader(ID, function (resp) {
                var data = JSON.parse(resp);

                var TrnsDate = new Date(parseInt(data[0].PaymentForm_Date.substr(6)));
                TrnsDate = moment(TrnsDate).format('DD-MMM-YYYY');

                $('#hdfPatient_ID').val(data[0].Patient_ID);
                $('#txtBillNo').val(data[0].PaymentForm_No);
                $("#txtTransactionDate").val(TrnsDate);
                $('#txtRemarks').val(data[0].Remarks);
                $('#txtTotalPayable').val(data[0].Total_Amount);
         
             
               
                $('#txtNetPayable').val(data[0].Net_Amount);
                $('#txtAmountReceived').val(data[0].Received_Amount);
                $('#txtBalances').val(data[0].Balance_Amount);
              
                FillTokenInputForMRNo();

                LoadTransactionDetails(ID);
             

                // calculateDoctorShare();
     
            },
            function (error) {
                alert(error.get_message());
            })
        }

        function LoadTransactionDetails(Bill_ID) {
            PageMethods.LoadTransactionDetails(Bill_ID, function (resp) {
                var data = (JSON.parse(resp));
                var rows = '';
                var rowIndex = parseInt((parseInt($('#tblDetails tbody tr').length)));
                var Description = '';
                $.each(data, function (key, value) {

                    rows = '<tr><td style="text-align:left;">' + parseInt(parseInt(rowIndex) + 1) + '</td><td> <a href="javascript:void(0)" onclick="ExcludeFromPayment(this)">Delete</a> </td><td style="text-align:left;"> <input type="hidden" name="hdnParentTrans_ID" value="' + value.ParentTrans_ID + '" /> <input type="hidden" name="hdnParentTrans_Name" value="' + value.ParentTrans_Name + '" /> <input type="hidden" name="hdnParentTrans_Type" value="' + value.ParentTrans_Type + '" /> <input type="hidden" name="hdnItemID" value="' + value.Item_ID + '" /> <input type="hidden" name="hdnCategory_ID" value="' + value.Category_ID + '" /> <input type="hidden" name="hdnItemName" value="' + value.Item_Name + '" /> <input type="hidden" name="hdnItemType" value="' + value.Item_Type + '" /><input type="hidden" name="hdnDisPer" value=' + value.Discount_Percentage + '><input type="hidden" name="hdnDisAmount" value=' + value.Discount_Amount + '><input type="hidden" name="hdnNet_Amount" value=' + value.Net_Amount + '><input type="hidden" name="hdnRecommendedByDoctor" value="' + true + '" />' + value.Item_Name + '</td><td style="display:none;">' + value.Remarks + '</td><td><input type="text" name="txtQty" value="' + value.Qty + '" style="width: 45px !important;" onkeyup="CulculateAmonutWithQty(this)"/><input type="hidden" name="txtActualAmount" value="' + value.Amount + '" /></td><td style="text-align:Right;" contenteditable> ' + value.Amount + ' </td><td style="display:none;"> <input type="text" name="DisPer" value="' + value.Discount_Percentage + '"style="width: 37px !important;" onkeyup="CalculateSummarieDiscountPerWise(' + rowIndex + ')"/> </td><td style="display:none;"> <input type="text" name="DisAmount" value="' + value.Discount_Amount + '" style="width: 75px !important;" onkeyup="CalculateSummarieDiscountAmountWise(' + rowIndex + ')"/> </td> <td style="text-align:Right;display:none;"> ' + value.Net_Amount + ' </td><td style="display:none;"> <input type="text" id = "ds' + key + '" name="Docshare" value="0" style="width: 75px !important;" onkeyup="calculateDoctorShare(' + rowIndex + ')"/> </td></tr>'



                    $('#tblDetails tbody').append(rows);
                  
                    //CalculateSummarieDiscountPerWise(rowIndex);
                    rowIndex++;
                });
                $('#btnSave').val('Update');
            },
            function (error) {
                alert(error.get_message());
            })
        }
          function SaveRecord()
            {
             
                    var val = document.getElementById("hdnDuplicateCheck").value;
                    var returnVal = false;

                    if (val == "0")//no duplicate
                    {
                        $('#btnSave').attr('disabled', 'disabled');
                        document.getElementById("hdnDuplicateCheck").value = "1";

                        var Transaction_ID = '';
                        var Transaction = '';
                        Transaction_ID = '<%= Request.QueryString["ID"]%>'
                     
                        if (Transaction_ID == '')
                            Transaction_ID = 0

                        var Details = [];
                    
                        var Patient_ID = $('#txtMRNo').val();
                        var Transaction_Date = $('#txtTransactionDate').val();
                        var Remarks = $('#txtRemarks').val();
                        var TotalPayable = $('#txtTotalPayable').val();
                        var Discount_Percentage = $('#txtDisPer').val();
                        Discount_Percentage = $('#hdntxtDisPer').val();
                        //Discount_Percentage = parseFloat(Discount_Percentage);

                        var Discount_Amount = 0;
                        var Net_Amount = $('#txtNetPayable').val();
                        var Received_Amount = $('#txtAmountReceived').val();
                        var Balance_Amount = $('#txtBalances').val();

                        if (Balance_Amount < 0)
                        {
                            alert("please Enter Valid Discount Amount ");
                            $('#btnSave').removeAttr("disabled");
                            return;
                        }
                        var ChargePolicy = 0;
                        //var Doctor_ID = ddlDoctor.value;
                        //doctor table data save code 

                       

                        //end
                        var isAmountZero = false;
                        $.each($('#tblDetails tbody tr'), function (key, value)
                        {
                            var ParentTrans_ID = $(value).find('input[name="hdnParentTrans_ID"]').val();

                            var ParentTrans_Name = $(value).find('input[name="hdnParentTrans_Name"]').val();

                            var ParentTrans_Type = $(value).find('input[name="hdnParentTrans_Type"]').val();
                            var ItemID = $(value).find('input[name="hdnItemID"]').val();
                            var Remarks = "";//$(value).find('input[name="Remarks"]').val();
                            var Qty = $(value).find('input[name="txtQty"]').val();
                            var Category_ID = $(value).find('input[name="hdnCategory_ID"]').val();
                            var ItemName = $(value).find('input[name="hdnItemName"]').val();
                            var ItemType = $(value).find('input[name="hdnItemType"]').val();
                            var DocShare = $(value).find('input[name="DocShare"]').val();
                            var Amount = $($(value).find('td')[5]).text();
                            if (Amount.trim() == 0)
                            {
                                isAmountZero = true;
                            }
                            var RecommendedByDoctor = $(value).find('input[name="hdnRecommendedByDoctor"]').val();
                            var ExcludedFromPayment = false;
                            var DisPer = $(value).find('input[name="hdnDisPer"]').val();
                            var DisAmt = $(value).find('input[name="hdnDisAmount"]').val();
                            var MainDepartment = $(value).find('input[name="Main_Department"]').val();

                            
                            //var Net_Amount = $($(value).find('td')[7]).text();

                            var Net_Amount = $(value).find('input[name="hdnNet_Amount"]').val();
                            Net_Amount = Amount - DisAmt;
                            Details.push({ ParentTrans_ID: ParentTrans_ID, ParentTrans_Name: ParentTrans_Name, ParentTrans_Type: ParentTrans_Type, ItemID: ItemID, CategoryID: Category_ID, ItemName: ItemName, ItemType: ItemType, Amount: Amount, RecommendedByDoctor: RecommendedByDoctor, ExcludedFromPayment: ExcludedFromPayment, DisPer: DisPer, DisAmt: DisAmt, Net_Amount: Net_Amount, Qty: Qty, Remarks: Remarks, DocShare: DocShare, MainDepartment: MainDepartment });
                        });
                     
                        if (isAmountZero == true) {
                            alert("Amount Should not be zero");
                            return true;
                        }
                    
                        var Parameters = { Transaction_ID: Transaction_ID, Patient_ID: Patient_ID, Transaction_Date: Transaction_Date, Remarks: Remarks, TotalPayable: TotalPayable, Discount_Percentage: Discount_Percentage, Discount_Amount: Discount_Amount, Net_Amount: Net_Amount, Received_Amount: Received_Amount, Balance_Amount: Balance_Amount, ChargePolicy: ChargePolicy, Details: Details };

                        var rcptAmt = $('#txtAmountReceived').val();

                        if (Patient_ID == '')
                        {
                            alert('Select Patient.');
                            //return;
                        }
                      
                                PageMethods.SaveRecord(JSON.stringify(Parameters), function (resp) {

                                    alert('Data Successfully Save');
                                    window.location.href = 'PaymentForm.aspx?ID=' + JSON.parse(resp);
                                    // }
                                   // DeleteExcludedItems();
                                }, function (error) {
                                    alert(error.get_message());
                                });
                         

                       
                    }
                    else {
                        alert("Processing Please Wait");
                        returnVal = false;
                    }
               
          }
        function CountBalance() {

            var AmtReceived = $('#txtAmountReceived').val();

            if ($('#txtTotalPayable').val() != '') {
                if (AmtReceived != '') {
                    $('#txtBalances').val((Math.round(parseFloat($('#txtNetPayable').val()) - parseFloat(AmtReceived))).toFixed(0));
                }
                else
                    $('#txtBalances').val(parseFloat($('#txtNetPayable').val()).toFixed(0));
            }
            else {
                $('#txtBalances').val(parseFloat($('#txtNetPayable').val()).toFixed(0));
            }
        }
        $(document).ready(function ()
        {
            $("#txtTransactionDate").val($.datepicker.formatDate('dd M yy', new Date()));
            FillMainTestDepartment();
            FillTokenInputForMRNo();
            tokenInputs('txtAddService', 'INV_ItemsPayment');
            OpenRecord();
        });
        function httpGet(theUrl) {
            var xmlHttp = null;
            xmlHttp = new XMLHttpRequest();
            xmlHttp.open("GET", theUrl, false);
            xmlHttp.send(null);
            return xmlHttp.responseText;
        }
        function CulculateAmonutWithQty(anchor) {
            var row = $(anchor).parents('tr')[0];
            var CalAmount = $($(row).find('td input[name=txtActualAmount]')[0]).val();
            var Qty = $($(row).find('td input[name=txtQty]')[0]).val();
            var totalamount = (CalAmount) * (Qty)
            $($(row).find('td')[5]).text(totalamount);
            $($(row).find('td')[8]).text(totalamount);
            CalculateSummarieDiscountPerWise(row);
        }
        function LoadPatientDetails() {

            var Patient_ID = $('#hdfPatient_ID').val();

            $.ajax({
                type: "POST",
                url: "PaymentForm.aspx/GetPatientDetails",
                data: "{'PatientID':" + Patient_ID + "}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: OnSuccess,
                failure: function (response) {
                    alert(response.d);
                }
            });
        }
        function AssignValue(ControlID, value) {

            if (ControlID.value == '')
                ControlID.value = value;
        }
        function ReplaceNullWith_Space(Data) {
            if (Data == "null")
                return " ";
            else
                return Data;
        }
        function OnSuccess(data) {
            var roomward = "";
            if (data.d != '') {

                if (data.d.Ward_Name != null) {
                    roomward = data.d.Ward_Name + ',  ' + data.d.Bed_No
                }
                else if (data.d.Room_Name != null) {
                    roomward = data.d.Room_Name + ',  ' + data.d.Room_No
                }
                else {
                    $('#lblWardRoom').hide(); // Replace the correct ID of Label.
                }


                if (data.d.Patient_Discount_Type == null)
                    data.d.Patient_Discount_Type = "";

                var mydate = new Date(Date.parse(data.d.Entry_Date));
                var dateR = mydate.toLocaleDateString();
               var isDisharge = ReplaceNullWith_Space(data.d.Discharge);
                var isInpatient = ReplaceNullWith_Space(data.d.isInpatient);
                is_Patient_Temp = isInpatient;
                $('#lblPatienName').text(ReplaceNullWith_Space(data.d.Name));
                $('#lblAgeYears').text(ReplaceNullWith_Space(data.d.Age));
                $('#lblGender').text(ReplaceNullWith_Space(data.d.Gender));
                $('#lblRegDate').text(dateR);
                $('#lblAddress').text(ReplaceNullWith_Space(data.d.Address));
                $('#lblContactNo').text(ReplaceNullWith_Space(data.d.Mobile));
                $('#lblDepartment').text(ReplaceNullWith_Space(data.d.department));
                $('#lblPatientCategory').text(ReplaceNullWith_Space(data.d.Patient_Type));
                //if (data.d.OPD_Panel_Name == null || data.d.OPD_Panel_Name == "null" || data.d.OPD_Panel_Name == "There is no row at position 0.") data.d.OPD_Panel_Name = "";
                //$('#lblOPDpnl').text(ReplaceNullWith_Space(data.d.OPD_Panel_Name));
                //if (data.d.IPD_Panel_Name == null || data.d.IPD_Panel_Name == "null" || data.d.IPD_Panel_Name == "There is no row at position 0.") data.d.IPD_Panel_Name = "";
                //$('#lblIPDpnl').text(ReplaceNullWith_Space(data.d.IPD_Panel_Name));
                //localStorage.IPD_PAnel_ID = ReplaceNullWith_Space(data.d.IPD_Panel_ID);
                //localStorage.OPD_Panel_ID = ReplaceNullWith_Space(data.d.OPD_Panel_ID);
                patient_id_old = ReplaceNullWith_Space(data.d.Previous_inpatient)
                $('#lblWardRoom').text(roomward);
                $('#txtAdmission').val(ReplaceNullWith_Space(data.d.Admission_type));
                $('#txtSehatCardNo').val(ReplaceNullWith_Space(data.d.Sehat_Card_No));
                $('#txtVisitCard').val(ReplaceNullWith_Space(data.d.Visit_Id));
                if (isInpatient == true) {
                    if (isDisharge == false) {
                        $('#lblPatientDiscountType').text(ReplaceNullWith_Space(data.d.Patient_Discount_Type));
                    }
                }
                else {
                    patient_id_old = ReplaceNullWith_Space(data.d.Previous_inpatient)
                    $('#lblPatientDiscountType').text(ReplaceNullWith_Space(data.d.Patient_Discount_Type));
                }

                //checkIsExistinOutPatient();
            }
        }
        function ExcludeFromPayment(anchor) {
            console.clear();

            var row = $(anchor).parents('tr')[0];
            row.remove();

            //var ItemID = $(row).find('input[name="hdnItemID"]').val();
            //var ParentTrans_Type = $(row).find('input[name="hdnParentTrans_Type"]').val();
            //if (ParentTrans_Type != "Test Group Category")
            //    ExcludedItem_List.push({ ItemID: ItemID, ItemType: "Test" });

            CalculateTotals();
        }
        function CalculateTotals() {
            var Amount = 0;
            var DisAmt = 0;
            var NetAmount = 0;

            $.each($('#tblDetails tbody tr'), function (key, value) {
                //Amount += parseFloat($($(value).find('td')[4]).text());
                Amount += parseFloat($(this).closest("tr").find("td:eq(5)").text());
                DisAmt += parseFloat($(value).find('input[name="DisAmount"]').val());
                NetAmount = Amount - DisAmt;
            });

            Math.round($('#txtTotalPayable').val(Amount), 2);

            $('#txtDisAmt').val(parseInt(Math.round(DisAmt)));

            $('#txtNetPayable').val(Math.round(NetAmount));

            var AmtReceived = $('#txtAmountReceived').val();

            if ($('#txtTotalPayable').val() != '') {
                if (AmtReceived != '') {
                    $('#txtBalances').val(Math.round(parseFloat(NetAmount) - parseFloat(AmtReceived)));
                }
                else
                    $('#txtBalances').val(Math.round(parseFloat(NetAmount)));
            }
            else {
                $('#txtBalances').val(Math.round(parseFloat(NetAmount)));
            }

        }
          function AddServiceOrItem()
            {
               
                    var Type = '';
                    var Item_Id = $('#txtAddService').val();
                    if (is_Patient_Temp == true)
                    {
                        Type = "IPD"
                    }
                    else
                    {
                        Type = "OPD";
                    }
                                   var remarks = $("#ctl00_MainContent_ddlpro_dis").val();
               // '</td><td> ' + remarks + '
                setTimeout(function () {
                    if ($('#txtAddService').val() == "")
                        return false;
                    var rowIndex = parseInt((parseInt($('#tblDetails tbody tr').length)));
                    //CheckInPatientObject = true;
                    if (CheckInPatientObject == true)
                    {

                        // localStorage.DocShare
                        var rows = '<tr><td style="text-align:left;">' + parseInt(parseInt(rowIndex) + 1) + '</td><td> <a href="javascript:void(0)" onclick="ExcludeFromPayment(this)">Delete</a> </td><td style="text-align:left;"> <input type="hidden" name="hdnParentTrans_ID" value="0" /> <input type="hidden" name="hdnParentTrans_Name" value="InPatient" /> <input type="hidden" name="hdnParentTrans_Type" value="" /> <input type="hidden" name="hdnItemID" value="' + localStorage.SelectedItemID + '" /> <input type="hidden" name="hdnItemName" value="' + localStorage.SelectedItemName + '" /> <input type="hidden" name="hdnDisPer" value="0"/><input type="hidden" name="hdnDisAmount" value="0.00"/><input type="hidden" name="hdnNet_Amount" value=' + localStorage.SelectedItemAmount + '/><input type="hidden" name="hdnItemType" value="' + localStorage.SelectedItemType + '" /><input type="hidden" name="hdnRecommendedByDoctor" value="' + false + '" />' + localStorage.SelectedItemName + '</td><td style="display:none;"> 0</td><td><input type="text" name="txtQty" value="1" style="width: 45px !important;" onkeyup="CulculateAmonutWithQty(this)"/><input type="hidden" name="txtActualAmount" value="' + localStorage.SelectedItemAmount + '"  /></td><td style="text-align:Right;" contenteditable onkeyup="CalculateSummarieDiscountPerWise(' + rowIndex + ')"> ' + localStorage.SelectedItemAmount + '</td><td style="display:none;"> <input type="text" name="DisPer" value="0"style="width: 37px !important;" onkeyup="CalculateSummarieDiscountPerWise(' + rowIndex + ')"/> </td><td style="display:none;"> <input type="text" name="DisAmount" value="" style="width: 75px !important;" onkeyup="CalculateSummarieDiscountAmountWise(' + rowIndex + ')"/> </td> <td style="text-align:Right;display:none;">' + localStorage.SelectedItemAmount + '</td><td style="display:none;"><input type="number" id="ds' + rowIndex + '" name="DocShare" value="' + 0 + '"  style="width: 75px !important;" onkeyup="calculateDoctorShare()"/></td> </tr>'
                    }
                    else
                    {

                        var rows = '<tr><td style="text-align:left;">' + parseInt(parseInt(rowIndex) + 1) + '</td><td> <a href="javascript:void(0)" onclick="ExcludeFromPayment(this)">Delete</a> </td><td style="text-align:left;"> <input type="hidden" name="hdnParentTrans_ID" value="0" /> <input type="hidden" name="hdnParentTrans_Name" value="" /> <input type="hidden" name="hdnParentTrans_Type" value="" /> <input type="hidden" name="hdnItemID" value="' + localStorage.SelectedItemID + '" /> <input type="hidden" name="hdnItemName" value="' + localStorage.SelectedItemName + '" /> <input type="hidden" name="hdnDisPer" value="0"/><input type="hidden" name="hdnDisAmount" value="0.00"/><input type="hidden" name="hdnNet_Amount" value=' + localStorage.SelectedItemAmount + '/><input type="hidden" name="hdnItemType" value="' + localStorage.SelectedItemType + '" /><input type="hidden" name="hdnRecommendedByDoctor" value="' + false + '" />' + localStorage.SelectedItemName + '</td><td style="display:none;"> ' + remarks + '</td><td><input type="text" name="txtQty" value="1" style="width: 45px !important;" onkeyup="CulculateAmonutWithQty(this)"/><input type="hidden" name="txtActualAmount" value="' + localStorage.SelectedItemAmount + '"  /></td><td contenteditable style="text-align:Right;"onkeyup="CalculateSummarieDiscountPerWise(' + rowIndex + ')"> ' + localStorage.SelectedItemAmount + ' </td><td style="display:none;"> <input type="text" name="DisPer" value="0"style="width: 37px !important;" onkeyup="CalculateSummarieDiscountPerWise(' + rowIndex + ')"/> </td><td style="display:none;"> <input type="text" name="DisAmount" value="" style="width: 75px !important;" onkeyup="CalculateSummarieDiscountAmountWise(' + rowIndex + ')"/> </td> <td style="text-align:Right;display:none;">' + localStorage.SelectedItemAmount + '</td><td style="display:none;"><input type="number" id="ds' + rowIndex + '" name="DocShare" value="' + 0 + '"  style="width: 75px !important;"  onkeyup="calculateDoctorShare()"/></td> </tr>'
                    }

                    $('#tblDetails tbody').append(rows);
                   
                  
                    CalculateSummarieDiscountPerWise(rowIndex);
                    //editable some Items
                   
                    var user_name = '<% =AppConfig.UserName %>';
                    // Ali.Tariq
                    if (user_name == "Ali.tariq") {
                        $('input[name="DisPer"]').attr('disabled', false);
                        $('input[name="DisAmount"]').attr('disabled', false)
                    }
                    else {
                        $('input[name="DisPer"]').attr('disabled', true);
                        $('input[name="DisAmount"]').attr('disabled', true)
                    }
                   

                }, 300);
             
            }
        function CalculateSummarieDiscountPerWise(rowIndex) {
            AssignValue(txtDisPer, 0);
            AssignValue(txtDisAmt, 0);
            AssignValue(txtAmountReceived, 0);

            var Amount = 0;
            var DisPer = 0;
            var DisAmt = 0;
            var NetAmount = 0;
            var TotalAmount = 0;
            var TotalDiscountAmount = 0;
            var TotalNetAmount = 0;

            $.each($('#tblDetails tbody tr'), function (key, value) {

                if (rowIndex == parseInt(key)) {
                    Amount = $($(value).find('td')[5]).text();
                    DisPer = $(value).find('input[name="DisPer"]').val();
                    $(value).find('input[name="hdnDisPer"]').val(DisPer);
                    DisAmt = Amount * DisPer / 100;
                    $(value).find('input[name="DisAmount"]').val(DisAmt.toFixed(2));

                    $(value).find('input[name="hdnDisAmount"]').val(DisAmt.toFixed(6));
                    NetAmount = Amount - DisAmt;
                    $($(value).find('td')[8]).text(NetAmount.toFixed(0));
                    $(value).find('input[name="hdnNet_Amount"]').val(NetAmount.toFixed(6));
                }
                Amount = $($(value).find('td')[5]).text();
                TotalAmount += parseFloat(Amount);
                DisAmt = $(value).find('input[name="DisAmount"]').val();
                // DisAmt = $(value).find('input[name="hdnDisAmount"]').val(DisAmt.toFixed(6));
                TotalDiscountAmount += parseFloat(DisAmt);
                NetAmount = Amount - DisAmt;
                TotalNetAmount += NetAmount;
            });

            $('#txtTotalPayable').val(TotalAmount.toFixed());

            $('#txtDisAmt').val(TotalDiscountAmount.toFixed());

            $('#txtNetPayable').val(TotalNetAmount.toFixed());

            var AmtReceived = $('#txtAmountReceived').val();

            if ($('#txtTotalPayable').val() != '') {
                if (AmtReceived != '') {
                    $('#txtBalances').val((TotalNetAmount - AmtReceived).toFixed());
                }
                else
                    $('#txtBalances').val(TotalNetAmount.toFixed());
            }
            else {
                $('#txtBalances').val(TotalNetAmount.toFixed());
            }
        }
        function tokenInputs(textboxID, tblName, OnAddFun) {
            $('#' + textboxID).tokenInput("json.aspx?Table=" + tblName,
             {
                 tokenLimit: 1,
                 onAdd:
                     function (item) {
                         try {

                             if (tblName == 'Patients') {

                                 $("#hdfPatient_ID").val(item.id);
                               LoadPatientDetails();
                             }

                             else if (tblName == 'INV_ItemsPayment') {

                                 localStorage.SelectedItemID = item.id;
                                 localStorage.SelectedItemType = item.Type;
                                 localStorage.SelectedItemName = item.name;
                                 localStorage.SelectedItemAmount = (item.Amount.length == 0 ? 0 : item.Amount);

                             }
                             else if (tblName == 'Inv_Items_Panel' || tblName.includes('Inv_Items_Panel')) {

                                 localStorage.SelectedItemID = item.id;
                                 localStorage.SelectedItemType = item.Type;
                                 localStorage.SelectedItemName = item.name;
                                 localStorage.SelectedItemAmount = (item.Amount.length == 0 ? 0 : item.Amount);

                             }
                             else if (tblName == 'PacakgesForBilling') {
                                 localStorage.SelectedPackageID = item.id;
                                 localStorage.SelectedPackageType = item.Type;
                                 localStorage.SelectedPackageName = item.name;
                             }
                         }
                         catch (err) {
                             alert(err.message);
                         }

                     }
             });
        }
        function FillTokenInputForMRNo()
        {

            var PatientID = $('#hdfPatient_ID').val();

            if (PatientID == '') {
                tokenInputs('txtMRNo', 'Patients');

            }
            else {

                var tokendata = httpGet("json.aspx?Table=PatientsFetchByID&q=" + PatientID);

                $('#txtMRNo').tokenInput("add", { id: JSON.parse(tokendata)[0].id, name: JSON.parse(tokendata)[0].name, readonly: true });

             LoadPatientDetails();
            }
        }
        function Populate() {

            $('#TestModel').modal({
                backdrop: 'static'
            });
            $('#tbltestModelTable tbody tr').remove();
        }
        function FillMainTestDepartment() {

            var options = '<option value="0" >Select Main Department</option>';

            PageMethods.FillTestMainDepartment(function (Tests) {
                $.each(JSON.parse(Tests), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                });
                $('#ddlMainTestDepartment').html(options);
                // $('#ddlMainTestDepartment').select2();
                ///localStorage.TestForCategoryWiseSelections = options;
            });
        }
        function FillLabTests() {

            var options = '<option value="0" >Please Select</option>';

            PageMethods.GetLabTests(function (Tests) {
                $.each(JSON.parse(Tests), function (key, value) {
                    options += '<option value="' + value.SerialNo + '" >' + value.TestName + '</option>';
                });
                $('#ddlTestList').html(options);
                $('#ddlTestList').select2();
                localStorage.TestForCategoryWiseSelections = options;
            });
        }
        function FillTestsByCategory(CategoryID) {

            var options = '<option value="0" >Please Select</option>';

            if (CategoryID == '002') {
                $("#btnultrasound").removeClass("btn-info").addClass("btn-danger");
                $('#btnXray').removeClass('btn-danger').addClass('btn-info');
                $("#btnCTscan").removeClass("btn-danger").addClass("btn-info");
                $('#divRotation').hide();
            }
            else if (CategoryID == '003') {
                $("#btnXray").removeClass("btn-info").addClass("btn-danger");
                $('#btnultrasound').removeClass('btn-danger').addClass('btn-info');
                $("#btnCTscan").removeClass("btn-danger").addClass("btn-info");
                $('#divRotation').show();

                PageMethods.GetRotationsCategoryWise('Test XRay Rotations', function (GetRotations) {
                    var options = '<option value="0" >Select</option>';
                    $.each(JSON.parse(GetRotations), function (key, value) {
                        options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                    });
                    $('#ddlRotation option').remove()
                    $('#ddlRotation').html(options);
                    $('#ddlRotation').select2();
                });
            }
            else if (CategoryID == '004') {
                $("#btnCTscan").removeClass("btn-info").addClass("btn-danger");
                $('#btnultrasound').removeClass('btn-danger').addClass('btn-info');
                $('#btnXray').removeClass('btn-danger').addClass('btn-info');

                $('#divRotation').show();

                PageMethods.GetRotationsCategoryWise('Test CT Scan Rotations', function (GetRotations) {
                    var options = '<option value="0" >Select</option>';
                    $.each(JSON.parse(GetRotations), function (key, value) {
                        options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                    });
                    $('#ddlRotation option').remove();
                    $('#ddlRotation').html(options);
                    $('#ddlRotation').select2();
                });
            }


            PageMethods.FillTestsByCategory(CategoryID, function (Tests) {
                var options = '<option value="0" >Please Select</option>';
                $.each(JSON.parse(Tests), function (key, value) {
                    options += '<option value="' + value.Test_ID + '" >' + value.Test_Name + '</option>';

                    // options += '<option value="' + value.Test_ID + "-" + value.Test_Name + '" >/option>';
                });
                $('#ddlTestList').html(options);
                $('#ddlTestList').select2();
            });
        }
        function FillProcedure(deptID) {

            var options = '<option value="0" >Please Select</option>';

            PageMethods.GetProcedure(deptID, function (item) {
                $.each(JSON.parse(item), function (key, value) {

                    options += '<option value="' + value.TestID + '" >' + value.TestName + '</option>';
                });
                //alert(options)
                $('#ddlTestList').html(options);
                $('#ddlTestList').select2();

            });
        }
        var temp_Patient = 0;
        function AddAllTest() {
            var maindpt = $('#ddlMainTestDepartment').val();
            var CheckTest = $('#ddlTestList').val();

            var patient_ID = $('#hdfPatient_ID').val();
            var test_Name = $('#ddlTestList').find('option:selected').text();
            // var Test_ID = $('#ddlTestList').val();     
            var patient_category_description = $('#lblPatientCategory').text();
            var inpatientCat = $('#lblPatientDiscountType').text();
            if (inpatientCat != "") {
                patient_category_description = inpatientCat;
            }
            if (patient_id_old != 0 || patient_id_old == null) {
                patient_ID = patient_id_old;
            }

            if (CheckTest != 0 || CheckTest != null) {
                //bilal
                $.ajax({
                    type: "post",
                    url: "PaymentForm.aspx/GetTestRate",
                    data: JSON.stringify({
                        "Patient_ID": patient_ID,
                        "Test_Name": test_Name,
                        "Patient_Category_Description": patient_category_description
                    }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        if (response.d != 0) {
                            //Test_Rate = response.d;
                            globalTestRate = response.d;

                        }
                        else {
                            globalTestRate = 0;
                        }

                        if (maindpt == "001") {
                            AddLabTest(maindpt);
                        }
                        else if (maindpt == "002") {
                            AddRadialogyTest();
                        }
                        else if (maindpt == "003") {
                            AddRadialogyTest();
                        }
                        else if (maindpt == "004") {
                            AddRadialogyTest();
                        }
                        else {
                            //AddProcedureTest();
                            AddLabTest(maindpt);
                        }
                        //update
                        //var pat_type = $("#lblPatientCategory").text();
                        //if (pat_type == "Private") {
                        //    $("#tblDetails tr").each(function () {
                        //        $(this).find("td:eq(5)").attr('contenteditable', 'True');


                        //    });
                        //}
                    },
                    failure: function (response) { }
                });

            }

        }
         function AddLabTest(maindpt)
            {
                var remarks = $("#Remarks").val();
                var test = $('#ddlTestList').find('option:selected').text();
                PageMethods.GetLabTestDDLDetails(test,maindpt, function (res) {
                    $.each(JSON.parse(res), function (key, value) {
                        var Result = 'Result';
                        var test = $('#ddlTestList').val();
                        var date = '<%= DateTime.Now %>';
                        var TestMainDepartmentName;
                        var ParentTransType = '';
                        if (JSON.parse(res).length > 1)
                            ParentTransType = 'Test Group Category';

                        var rowIndex = parseInt((parseInt($('#tblDetails tbody tr').length)));

                        //var Rate = value.Rate;
                        //if (value.Rate == null || value.Rate == "")
                        //    value.Rate = 0;

                        var ParentTransID = 0;
                        if (ParentTransID == '' || ParentTransID == null)
                            ParentTransID = '0';

                        var ParentTransName = value.GroupName;
                        if (ParentTransName == '')
                            ParentTransName = ' ';

                        //var Rate = (Test_Rate != 0) ? Test_Rate : Rate;
                        var Rate = value.Rate;

                        if (Rate == null || Rate == "")
                            Rate = 0;
                        if (globalTestRate == 0 || globalTestRate == "" || globalTestRate == null) {
                            globalTestRate = Rate;
                        }
                        if (value.Test_ID != 0) {
                            value.Group_Category == "0";

                          
                            var rows = '<tr><td style="text-align:left;">' + parseInt(parseInt(rowIndex) + 1) + '</td><td> <a href="javascript:void(0)" onclick="ExcludeFromPayment(this)">Delete</a> </td><td style="text-align:left;"> <input type="hidden" name="hdnParentTrans_ID" value="' + ParentTransID + '" /> <input type="hidden" name="hdnParentTrans_Name" value="' + (CheckInPatientObject == true ? 'InPatient' : '') + '" /> <input type="hidden" name="hdnParentTrans_Type" value="' + ParentTransType + '" /> <input type="hidden" name="hdnItemID" value="' + value.Test_ID + '" /> <input type="hidden" name="hdnItemName" value="' + value.Test_Name + '" /> <input type="hidden" name="hdnItemType" value="Test" /> <input type="hidden" name="hdnCategory_ID" value="' + value.Group_Category + '" /><input type="hidden" name="hdnDisPer" value="0"/><input type="hidden" name="hdnDisAmount" value="0.00"/><input type="hidden" name="hdnNet_Amount" value=' + globalTestRate + '/> <input type="hidden" name="hdnRecommendedByDoctor" value="' + false + '" />' + value.Test_Name + '</td><td style="display:none;"><input type="hidden" name="txtActualAmount" value="' + globalTestRate + '" /></td><td contenteditable><input type="text" name="txtQty" value="1" style="width: 45px !important;" onkeyup="CulculateAmonutWithQty(this)"/><input type="hidden" name="txtActualAmount" value="' + globalTestRate + '" /></td><td contenteditable style="text-align:Right;" onkeyup="CalculateSummarieDiscountPerWise(' + rowIndex + ')"> ' + globalTestRate + ' </td><td style="display:none;"> <input type="text" name="DisPer" value="0"style="width: 37px !important;" onkeyup="CalculateSummarieDiscountPerWise(' + rowIndex + ')"/> </td><td style="display:none;"> <input type="text" name="DisAmount" value="" style="width: 75px !important;" onkeyup="CalculateSummarieDiscountAmountWise(' + rowIndex + ')"/> </td> <td style="text-align:Right;display:none;"><td style="display:none;"> <input type="text" name="DocShare" id="ds' + rowIndex + '"  value="' + 0 + '"  style="width: 75px !important;"onkeyup="calculateDoctorShare()"/><input type="hidden" name="Main_Department" value="' + maindpt + '" /></td></tr>'

                            var rowstbl = '<tr><td style="text-align:left;">' + parseInt(parseInt(rowIndex) + 1) + '</td><td> <a href="javascript:void(0)" onclick="ExcludeFromPayment(this)">Delete</a> </td><td style="text-align:left;"> <input type="hidden" name="hdnParentTrans_ID" value="' + ParentTransID + '" /> <input type="hidden" name="hdnParentTrans_Name"  value="' + (CheckInPatientObject == true ? 'InPatient' : '') + '" /> <input type="hidden" name="hdnParentTrans_Type" value="' + ParentTransType + '" /> <input type="hidden" name="hdnItemID" value="' + value.Test_ID + '" /> <input type="hidden" name="hdnItemName" value="' + value.Test_Name + '" /> <input type="hidden" name="hdnItemType" value="Test" /> <input type="hidden" name="hdnCategory_ID" value="' + value.Group_Category + '" /> <input type="hidden" name="hdnRecommendedByDoctor" value="' + false + '" />' + value.Test_Name + '</td><td>' + remarks + '</td><td><input type="text" name="txtQty disabled=disabled" value="1" style="width: 45px !important;" onkeyup="CulculateAmonutWithQty(this)"/><input type="hidden" name="txtActualAmount" value="' + globalTestRate + '" /><input type="hidden" name="Main_Department" value="' + maindpt +'" /></td><td>' + globalTestRate + '</td></tr>'
                        }
                        else {
                            ParentTransType = 'Test Group Category';
                            var rows = '<tr><td style="text-align:left;">' + parseInt(parseInt(rowIndex) + 1) + '</td><td> <a href="javascript:void(0)" onclick="ExcludeFromPayment(this)">Delete</a> </td><td style="text-align:left;"> <input type="hidden" name="hdnParentTrans_ID" value="' + ParentTransID + '" /> <input type="hidden" name="hdnParentTrans_Name"  value="' + (CheckInPatientObject == true ? 'InPatient' : '') + '" /> <input type="hidden" name="hdnParentTrans_Type" value="' + ParentTransType + '" /> <input type="hidden" name="hdnItemID" value="' + value.Test_ID + '" /> <input type="hidden" name="hdnItemName" value="' + value.Test_Name + '" /> <input type="hidden" name="hdnItemType" value="Test" /> <input type="hidden" name="hdnCategory_ID" value="' + value.Group_Category + '" /> <input type="hidden" name="hdnDisPer" value="0"/><input type="hidden" name="hdnDisAmount" value="0.00"/><input type="hidden" name="hdnNet_Amount" value=' + globalTestRate + '/><input type="hidden" name="hdnRecommendedByDoctor" value="' + false + '" />' + value.Test_Name + '</td><td style="display:none;"> ' + remarks + '</td><td  contenteditable><input type="text" name="txtQty" disabled=disabled value="1" style="width: 45px !important;" onkeyup="CulculateAmonutWithQty(this)"/><input type="hidden" name="txtActualAmount" value="' + globalTestRate + '" /></td><td style="text-align:Right;" contenteditable onkeyup="CalculateSummarieDiscountPerWise(' + rowIndex + ')"> ' + globalTestRate + ' </td><td style="display:none;"> <input type="text" name="DisPer" value="0"style="width: 37px !important;" onkeyup="CalculateSummarieDiscountPerWise(' + rowIndex + ')"/> </td><td style="display:none;"> <input type="text" name="DisAmount" value="" style="width: 75px !important;" onkeyup="CalculateSummarieDiscountAmountWise(' + rowIndex + ')"/> </td> <td style="text-align:Right;display:none;">  </td><td style="display:none;"><input type="text" id="ds' + rowIndex + '" name="DocShare" value="' + 0 + '"  style="width: 75px !important;" onkeyup="calculateDoctorShare()"/><input type="hidden" name="Main_Department" value="' + maindpt + '" /></td> </tr>'

                            var rowstbl = '<tr><td style="text-align:left;">' + parseInt(parseInt(rowIndex) + 1) + '</td><td> <a href="javascript:void(0)" onclick="ExcludeFromPayment(this)">Delete</a> </td><td style="text-align:left;"> <input type="hidden" name="hdnParentTrans_ID" value="' + ParentTransID + '" /> <input type="hidden" name="hdnParentTrans_Name"  value="' + (CheckInPatientObject == true ? 'InPatient' : '') + '"  /> <input type="hidden" name="hdnParentTrans_Type" value="' + ParentTransType + '" /> <input type="hidden" name="hdnItemID" value="' + value.Test_ID + '" /> <input type="hidden" name="hdnItemName" value="' + value.Test_Name + '" /> <input type="hidden" name="hdnItemType" value="Test" /> <input type="hidden" name="hdnCategory_ID" value="' + value.Group_Category + '" /> <input type="hidden" name="hdnRecommendedByDoctor" value="' + false + '" />' + value.Test_Name + '</td><td>' + remarks + '</td><td>' + '<input type="text" name="txtQty" disabled=disabled value="1" style="width: 45px !important;" onkeyup="CulculateAmonutWithQty(this)"/><input type="hidden" name="txtActualAmount" value="' + globalTestRate + '" /><input type="hidden" name="Main_Department" value="' + maindpt + '" /></td></td><td>' + globalTestRate + '</td></tr>'
                        }
                        var test_array = $('#tblDetails').find('input[name=hdnItemID][value="' + value.TestID + '"]');
                        if (test_array.length > 0) {
                            alert('This test already added!');
                            return false;
                        }
                        else {
                            $('#tblDetails tbody').append(rows);
                            $('input[name="DisPer"]').attr('disabled', true);
                            $('input[name="DisAmount"]').attr('disabled', true)

                            CalculateSummarieDiscountPerWise(rowIndex);

                            $('#tbltestModelTable tbody').append(rowstbl);
                            //$('#TestModel').modal('hide');
                        }
                    });

                }, function (err) { });

         }
        var Test_Rate = 0;
         function AddRadialogyTest() {
                var remarks = $('#Remarks').val();
           $("#btnXray").removeClass("btn-danger").addClass("btn-info");
           $('#btnultrasound').removeClass('btn-danger').addClass('btn-info');
           $("#btnCTscan").removeClass("btn-danger").addClass("btn-info");

           var Result = 'Result';
           var test = $('#ddlTestList').val();
           var date = '<%= DateTime.Now %>';
                    var IsRotationShow = $('#divRotation').is(":visible");

                    var Rotation_ID = IsRotationShow ? $('#ddlRotation option:selected').val() : "0";
                    var Rotation_Name = IsRotationShow ? $('#ddlRotation option:selected').text() : " ";
                    var rowIndex = parseInt((parseInt($('#tblDetails tbody tr').length)));

                    $.ajax({
                        type: "POST",
                        url: "PaymentForm.aspx/GetTestMainDepartmentDetails",
                        data: JSON.stringify({ TestID: test }),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (data) {
                            var data = JSON.parse(data.d);
                            TestMainDepartmentName = data[0].MainDepartment;
                            var Rate = data[0].Rate;
                            var TestName = data[0].Test_Name;
                            var Category_ID = data[0].Category_ID;
                            
                            var rotation = $('#ddlRotation').val;

                            Rate = (Test_Rate != 0) ? Test_Rate : Rate;

                            if (Rate == null || Rate == "")
                                Rate = 0;
                            if (globalTestRate == 0 || globalTestRate == "" || globalTestRate == null)
                            {
                                globalTestRate = Rate;
                            }

                            var rows = '<tr><td style="text-align:left;">' + parseInt(parseInt(rowIndex) + 1) + '</td><td> <a href="javascript:void(0)" onclick="ExcludeFromPayment(this)">Delete</a> </td><td style="text-align:left;"> <input type="hidden" name="hdnParentTrans_ID" value="0" /> <input type="hidden" name="hdnParentTrans_Name" value="' + (CheckInPatientObject == true ? 'InPatient' : '') + '" /> <input type="hidden" name="hdnParentTrans_Type" value="" /> <input type="hidden" name="hdnItemID" value="' + test + '" /> <input type="hidden" name="hdnItemName" value="' + TestName + '" /> <input type="hidden" name="hdnItemType" value="Test" /> <input type="hidden" name="hdnCategory_ID" value="' + Category_ID + '" /> <input type="hidden" name="hdnDisPer"value="0" /><input type="hidden" name="hdnDisAmount" value="0.00"/><input type="hidden" name="hdnNet_Amount" value=' + globalTestRate + '/><input type="hidden" name="hdnRecommendedByDoctor" value="' + false + '" />' + TestName + ',' + Rotation_Name + '</td><td style="display:none;">' + remarks + '</td><td><input type="text" name="txtQty" value="1" style="width: 45px !important;"  onkeyup="CulculateAmonutWithQty(this)"/><input type="hidden" name="txtActualAmount" value="' + globalTestRate + '" /></td><td contenteditable style="text-align:Right;" onkeyup="CalculateSummarieDiscountPerWise(' + rowIndex + ')"> ' + globalTestRate + ' </td><td style="display:none;"> <input type="text" name="DisPer" value="0"style="width: 37px !important;" onkeyup="CalculateSummarieDiscountPerWise(' + rowIndex + ')"/> </td><td style="display:none;"> <input type="text" name="DisAmount" value="" style="width: 75px !important;" onkeyup="CalculateSummarieDiscountAmountWise(' + rowIndex + ')"/> </td> <td style="text-align:Right;display:none;">  </td><input type="text" name="DocShare" value="' + 0 + '"  style="width: 75px !important;"/></td><td style="display:none;"><input type="number" id="ds' + rowIndex + '" name="DocShare" value="' + 0 + '"  style="width: 75px !important;" onkeyup="calculateDoctorShare()"/><input type="hidden" name="Main_Department" value="002" /></td> </tr>'

                            var rowstbl = '<tr><td style="text-align:left;">' + parseInt(parseInt(rowIndex) + 1) + '</td><td> <a href="javascript:void(0)" onclick="ExcludeFromPayment(this)">Delete</a> </td><td style="text-align:left;"> <input type="hidden" name="hdnParentTrans_ID" value="0" /> <input type="hidden" name="hdnParentTrans_Name" value="' + (CheckInPatientObject == true ? 'InPatient' : '') + '" /> <input type="hidden" name="hdnParentTrans_Type" value="" /> <input type="hidden" name="hdnItemID" value="' + test + '" /> <input type="hidden" name="hdnItemName" value="' + TestName + '" /> <input type="hidden" name="hdnItemType" value="Test" /> <input type="hidden" name="hdnCategory_ID" value="' + Category_ID + '" /> <input type="hidden" name="hdnRecommendedByDoctor" value="' + false + '" />' + TestName + '.' + Rotation_Name + '</td><td>' + remarks + '</td><td><input type="text" name="txtQty" value="1" style="width: 45px !important;" disabled=disabled onkeyup="CulculateAmonutWithQty(this)"/><input type="hidden" name="txtActualAmount" value="' + globalTestRate + '" /></td><td>' + globalTestRate + '</td><input type="text" id="ds' + rowIndex + '" name="DocShare" value="' + 0 + '"  style="width: 75px !important;" onkeyup="calculateDoctorShare()"/><input type="hidden" name="Main_Department" value="002" /></td></tr>'

                            //var test_array = $('#tblDetails').find('input[name=hdnItemID][value="' + test + '"]');
                            //if (test_array.length > 0) {
                            //    alert('This test already added!');
                            //    return false;
                            //}
                            //else {

                                $('#tblDetails tbody').append(rows);
                                $('#tbltestModelTable tbody').append(rowstbl);
                                $('input[name="DisPer"]').attr('disabled', true);
                                $('input[name="DisAmount"]').attr('disabled', true)
                                CalculateSummarieDiscountPerWise(rowIndex);
                                //$('#TestModel').modal('hide');
                            //}

                        },
                        failure: function (response) {
                            alert(response.d);
                        }
                    });
            
            
         }
        var patient_id_old = 0;
        var CheckInPatientObject = true;
            function AddProcedureTest() {
                var remarks = $('#Remarks').val();
                var Result = 'Result';
                var test = $('#ddlTestList').val();
                var TestName = $('#ddlProcedure').find('option:selected').text();
                var testgg = '<%= DateTime.Now.ToString("dd/MM/yyyy  h:m:s A") %>';
                    var dateValue = '<%= DateTime.Now%>';
                var rowIndex = parseInt((parseInt($('#tblDetails tbody tr').length)));
                $.ajax({
                    type: "POST",
                    url: "PaymentForm.aspx/GetTestMainDepartmentDetails",
                    data: JSON.stringify({ TestID: test }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (data) {
                      
                        var data = JSON.parse(data.d);
                        TestMainDepartmentName = data[0].MainDepartment;
                        var Rate = data[0].Rate;
                        var TestName = data[0].Test_Name;
                        var Category_ID = data[0].Category_ID;

                        Rate = (Test_Rate != 0) ? Test_Rate : Rate;

                        if (Rate == null || Rate == "")
                            Rate = 0;
                        
                        var rows = '<tr><td style="text-align:left;">' + parseInt(parseInt(rowIndex) + 1) + '</td><td> <a href="javascript:void(0)" onclick="ExcludeFromPayment(this)">Delete</a> </td><td style="text-align:left;"> <input type="hidden" name="hdnParentTrans_ID" value="0" /> <input type="hidden" name="hdnParentTrans_Name" value="' + (CheckInPatientObject == true ? 'InPatient' : '') + '" /> <input type="hidden" name="hdnParentTrans_Type" value="" /> <input type="hidden" name="hdnItemID" value="' + test + '" /> <input type="hidden" name="hdnItemName" value="' + TestName + '" /> <input type="hidden" name="hdnItemType" value="Test" /> <input type="hidden" name="hdnCategory_ID" value="' + Category_ID + '" /> <input type="hidden" name="hdnDisPer" value="0"/><input type="hidden" name="hdnDisAmount" / value="0.00" ><input type="hidden" name="hdnNet_Amount" value=' + Rate + ' /><input type="hidden" name="hdnRecommendedByDoctor" value="' + false + '" />' + TestName + '</td><td style="display:none;">' + remarks + '</td><td><input type="text" name="txtQty" value="1" style="width: 45px !important;" onkeyup="CulculateAmonutWithQty(this)"/><input type="hidden" name="txtActualAmount" value="' + Rate + '" /></td><td contenteditable style="text-align:Right;"> ' + Rate + ' </td><td style="display:none;"> <input type="text" name="DisPer" value="0"style="width: 37px !important;" onkeyup="CalculateSummarieDiscountPerWise(' + rowIndex + ')"/> </td><td style="display:none;"> <input type="text" name="DisAmount" value="" style="width: 75px !important;" onkeyup="CalculateSummarieDiscountAmountWise(' + rowIndex + ')"/> </td> <td style="display:none;"><input type="number" id="ds' + rowIndex + '" name="DocShare" value="' + 0 + '"  style="width: 75px !important;" onkeyup="calculateDoctorShare()"/></td> </tr>'

                        var rowstbl = '<tr><td style="text-align:left;">' + parseInt(parseInt(rowIndex) + 1) + '</td><td> <a href="javascript:void(0)" onclick="ExcludeFromPayment(this)">Delete</a> </td><td style="text-align:left;"> <input type="hidden" name="hdnParentTrans_ID" value="0" /> <input type="hidden" name="hdnParentTrans_Name" value="' + (CheckInPatientObject == true ? 'InPatient' : '') + '" /> <input type="hidden" name="hdnParentTrans_Type" value="" /> <input type="hidden" name="hdnItemID" value="' + test + '" /> <input type="hidden" name="hdnItemName" value="' + TestName + '" /> <input type="hidden" name="hdnItemType" value="Test" /> <input type="hidden" name="hdnCategory_ID" value="' + Category_ID + '" /> <input type="hidden" name="hdnRecommendedByDoctor" value="' + false + '" />' + TestName + '</td><td>' + Rate + '</td><td><input type="number" id="ds' + rowIndex + '" name="DocShare" value="' + 0 + '"  style="width: 75px !important;" onkeyup="calculateDoctorShare()"/></td></tr>'

                        var test_array = $('#tblDetails').find('input[name=hdnItemID][value="' + test + '"]');
                        if (test_array.length > 0) {
                            alert('This test already added!');
                            return false;
                        }
                        else {

                            $('#tblDetails tbody').append(rows);
                            $('#tbltestModelTable tbody').append(rowstbl);
                            $('input[name="DisPer"]').attr('disabled', true);
                            $('input[name="DisAmount"]').attr('disabled', true)
                            CalculateSummarieDiscountPerWise(rowIndex);
                           // $('#TestModel').modal('hide');
                        }

                    },
                    failure: function (response) {
                        alert(response.d);
                    }
                });
            }
        function LoadTestByDepartment() {
            var maindpt = $('#ddlMainTestDepartment').val();
            if (maindpt == "0") {
                $('#ddlTestList').val("");
                $('#ddlTestList').text("");
                $('#divRotation').hide();
            }
            if (maindpt == "001") {
                FillLabTests();
                $('#divRotation').hide();
            }
            else if (maindpt == "002") {
                FillTestsByCategory('002');
            }
            else if (maindpt == "003") {
                FillTestsByCategory('003');
            }
            else if (maindpt == "004") {
                FillTestsByCategory('004');

            }
            else if (maindpt == "005") {

                FillProcedure("005");
                $('#divRotation').hide();
            }
            else if (maindpt == "006") {

                FillProcedure("006");
                $('#divRotation').hide();
            }
            else if (maindpt == "007") {

                FillProcedure("007");
                $('#divRotation').hide();
            }
        }
    </script>
  <style type="text/css">

    </style>


</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
      <asp:HiddenField runat="server" ID="hdfPatient_ID" ClientIDMode="Static" />
         <input type="hidden" name="hdnDuplicateCheck" value="0" id="hdnDuplicateCheck" />
        <div id="header">
            <table style="width: 819px; height: 231px;">
                <tr style="display: none;">
                    <td>

                        <label>Date From :	</label>
                    </td>
                    <td>
                        <input type="text" id="txtDateFrom" />
                    </td>
                    <td>
                        <label>Date To :	</label>
                    </td>
                    <td>
                        <input type="text" id="txtDateTo" />
                    </td>
                </tr>
                <tr>
                    <td>
                        <label>
                            MR No *:
                        </label>
                    </td>
                    <td>
                        <input type="text" id="txtMRNo"  />

                    </td>
                    <td>
                        <label>
                            Transaction ID:
                        </label>
                    </td>
                    <td>
                        <input type="text" id="txtBillNo" disabled="disabled" value="New" />
                    </td>
                </tr>
                <tr>
                    <td>
                        <label>Patient Name :	</label>
                    </td>
                    <td>
                        <label id="lblPatienName"></label>
                    </td>
                    <td>
                        <label>Contact No :	</label>
                    </td>
                    <td>
                        <label id="lblContactNo"></label>
                    </td>
                </tr>
                <tr>
                    <td>
                        <label>Reg. Date :	</label>
                    </td>
                    <td>
                        <label id="lblRegDate"></label>
                    </td>
                    <td>
                        <label>Gender  :	</label>
                    </td>
                    <td>
                        <label id="lblGender"></label>
                    </td>
                </tr>
                <tr>
                    <td>
                        <label>Age Years :	</label>
                    </td>
                    <td>
                        <label id="lblAgeYears"></label>
                    </td>
                    <td>
                        <label>Address   :	</label>
                    </td>
                    <td>
                        <label id="lblAddress"></label>
                    </td>
                </tr>
                <tr>
                    <td>
                        <label>Patient Category :	</label>
                    </td>
                    <td>
                        <label id="lblPatientCategory"></label>
                    </td>
                    <td>
                        <label>Department  :	</label>
                    </td>
                    <td>
                        <label id="lblDepartment"></label>
                    </td>
                </tr>
               <%-- <tr>
                    <td>
                    <label> OPD Panel Company :</label>
                        </td>
                    <td>
                        <label id="lblOPDpnl"></label>
                    </td>

                </tr>--%>
                <tr>
                     <td>
                        <label>InPatient Admit Catagory :</label>
                    </td>
                    <td>
                        <label id="lblPatientDiscountType" style="background-color:silver;"></label>
                    </td>
                    <td>
                        <label>Ward / Room :</label>
                    </td>
                    <td>
                        <label id="lblWardRoom" style="background-color:silver;"></label>
                    </td>
                </tr>
              <%--  <tr>
                     <td>
                    <label> IPD Panel Company :</label>
                        </td>
                    <td>
                          <label id="lblIPDpnl"></label>
                    </td>
                </tr>--%>
                <tr>

                    <td>
                        <label>Transaction Date :	</label>
                    </td>
                    <td>
                        <input type="text" id="txtTransactionDate" disabled="disabled" />
                    </td>
                    <td colspan="1">
                        <label>Remarks:</label>
                    </td>
                    <td>
                        <textarea id="txtRemarks" style="width: 168px; height: 57px;"></textarea>
                    </td>
                </tr>
                <tr>
                    <td> <label>Admission Type:</label></td>
                  <td>  <input type="text" id="txtAdmission" disabled="disabled" style="color: black!important;
    background: none!important;
    border: none;
"/></td>
                    <td><label>Sehat Card No:</label></td>
                      <td> <input type="text" id="txtSehatCardNo" disabled="disabled" style="color: black!important;
    background: none!important;
    border: none;
"/></td>
                </tr>
                <tr>
                    <td><label>Visit ID:</label></td>
                     <td> <input type="text" id="txtVisitCard" disabled="disabled" style="color: black!important;
    background: none!important;
    border: none;
"/></td>
                </tr>
              <%--  <tr>
                     <td>Charge policy: *
                    </td>
                    <td>
                        <select  id="ddlChargePolicy"></select>
                    </td>
                    <%--<td>Doctor:
                    </td>--%>
                   <%-- <td>
                        <select  id="ddlDoctor"></select>
                    </td>
                </tr>--%>
            </table>
        </div>
       <div id="details" style="margin-top: 20px;">
            <table id="addNewItems" style="width: 516px !important;">
                <tr>
                    <td>
                        <input type="text" id="txtAddService" />
                    </td>
                    <td>
                        <input type="button" value="Add Srvc / Itm" id="btnAddServiceOrItem" onclick="AddServiceOrItem()" />
                    </td>
                    <td>
                        <%--<input type="text" id="txtAddPackage" />--%>
                    </td>
                    <td>
                        <%--<input type="button" value="Add Package" onclick="AddPackage()" id="btnAddPackage"/>--%>
                        <input type="button" value="Add Test" onclick="Populate()" id="btnAddTestAll"/>
                    </td>
                </tr>
              <%--  <tr>
                    <td>Procedure discription:</td>

                    <td>
                        <%--<input type="text" id="ddlpro_dis"/>--%>
                    <%--   <asp:DropDownList ID="ddlpro_dis" style="width:166px !important" runat="server" AppendDataBoundItems="true"></asp:DropDownList>
                    </td>

                  
                        
                </tr>--%>

            </table>
            <div style="width: 742px; overflow: scroll; height: 250px !important; height: auto;">
                <table class="table" style="width: 724px; height: 146px !important; height: auto; overflow: scroll;" id="tblDetails">
                    <thead>
                        <tr>
                            <th style="width: 50px; text-align: left;">Sr. </th>
                            <th style="width: 53px; text-align: left;">Action </th>
                            <th style="text-align: left;width: 352px;">Description </th>
                            <th style="text-align: left;width: 352px;display:none;">Remarks </th>
                             <th style="width: 65px; text-align: left;">Qty </th>
                            <th style="width: 60px; text-align: left;">Amount </th>
                            <th style="width: 70px; text-align: left;display:none;">Dis % </th>
                            <th style="width: 95px; text-align: left;display:none;">Dis Amount </th>
                            <th style="width: 100px; text-align: left;display:none;">Net Amount </th>
                            <th style="width: 100px; text-align: left;display:none;">Doc Share </th>
                        </tr>
                    </thead>
                    <tbody>
                    </tbody>
                </table>
            </div>

            <div style="margin-left: 368px; margin-top: 4px; width: 497px !important;"
                id="dvSummary">
                <table style="width: inherit;">
                    <tr style="display:none;"> 
                        <td>Total Doctor Share</td>
                        <td>

                            <input type="text" id="txtTotalDoctorShare" style="width: 116px !important; height: 30px; margin-left: 16px; text-align: right; font-size: 22px;"
                                disabled="disabled" />

                        </td>
                 <%--   <td style="position: absolute;margin-left: 86px;margin-top: 26px;">Doctors Total Distribution</td>--%>
        <%--            <td><input type="text" id="txtDoctorTotalDistribution" style="    position: absolute; margin-left: 269px;"  disabled="disabled"/></td>--%>
                        </tr>

                        <tr>
                        <td>Total Payable:  </td>
                        <td>

               <input type="text" id="txtTotalPayable" style="width: 116px !important; height: 30px; margin-left: 16px; text-align: right; font-size: 22px;"
                                disabled="disabled" />

                        </td>

             
                    </tr>
                    <tr style="display:none;">
                        <td>Discount :  </td>
                        <td>
                   <input type="text" id="txtDisPer" style="width: 116px !important; height: 30px; margin-left: -129px; text-align: right; font-size: 22px;" onkeyup="CalculateSummariesMaster(false)" />
                       <input type="hidden"  id="hdntxtDisPer" value="0"/>

                            &nbsp; % &nbsp;
                            <input type="text" id="txtDisAmt" style="width: 116px !important; height: 30px; text-align: right; font-size: 22px;" onkeyup="CalculateSummariesMaster(true)" />
                        </td>
                    </tr>
                    <tr>
                        <td>Net Payable:  </td>
                        <td>
                            <input type="text" id="txtNetPayable" style="width: 116px !important; height: 30px; margin-left: 16px; text-align: right; font-size: 22px; color: red; margin-left: 17px; color: red !important;" disabled="disabled" />

                        </td>
                    </tr>
                    <tr>
                        <td>Amount Paid:  </td>
                        <td>
           <input type="text" id="txtAmountReceived"  style="width: 116px !important; height: 24px; margin-left: 17px; text-align: right; font-size: 22px;"
                                onkeyup="CountBalance()" />
                        </td>
                    </tr>
                    <tr>
                        <td>Balance:  </td>
                        <td>
                       <input type="text" id="txtBalances" style="width: 116px !important; height: 30px; margin-left: 35px; text-align: right; font-size: 22px; color: red; margin-left: 18px;" disabled="disabled" />
                        </td>
                    </tr>
                </table>
            </div>
        </div>  
     <div id="TestModel" class="modal fade" role="dialog">
        <div class="modal-dialog">
            <!-- Modal content-->
            <div class="modal-content" style="width: 1000px; margin-left: -270px; height: 505px;">
                <div class="modal-header">
                    <button type="button" style="width: auto;" class="close" data-dismiss="modal">&times;</button>
                    <h4 class="modal-title">Add Test</h4>
                </div>
                <table style="margin-left: 60px;">
                    <tr>
                        <td>
                             <div style="margin-top: 2px;">
                    <h2>Main Tests Department : </h2>
                </div>
                        </td>
                    </tr>
                    </table>
                <table  style="margin-left: 60px;">
                    <tr>

                        <td style="width: 308px;">
                            <select id="ddlMainTestDepartment" tabindex="" onchange="LoadTestByDepartment()" autofocus="autofocus" style="width: 180px !important;">
                                    <option value="">Select Department</option>
                                </select>
                        </td>

                         <td style="width: 205px;">
                             <span class="paper_help_note" tabindex="1" onFocus="document.querySelector('.autofocus2').focus()"></span>
                            <select id="ddlTestList" class="paper_update autofocus1" tabindex="1" >
                                    
                                </select>
                             <div id="divRotation">
                                    <select id="ddlRotation" style="display: none; width: 100px">
                                    </select>
                                </div>
                                <div id="divX_Ray">
                                    <select id="ddlXRayLF" style="display: none;width: 73px !important;margin-left: 101px;margin-top: -28px;height: 28px;">
                                      <option value="0"></option>
                                        <option value="L">Left</option>
                                        <option value="R">Right</option>
                                    </select>
                                </div>
                        </td>
                      
                         <td>
                             
                                <input type="button" style="border: 3px solid white !important;height: 32px !important;" value="Add Test" tabindex="2" class="paper_update autofocus2 Faddbtn" id="btnAddAllTest" onclick="AddAllTest()"/>
                             <span class="paper_help_note" tabindex="2" onFocus="document.querySelector('.autofocus1').focus()"></span>
                            </td>
                        

                    </tr>
                    <tr>
                    <td>Remarks:

                            <input type="text" id="Remarks" tabindex="3" />
                            </td>
                        </tr>
                </table>
               <%-- <table style="margin-left: 60px;">
                    <tr>
                        <td>
                             <div style="margin-top: 2px;">
                    <h2>Main Tests Department : </h2>
                </div>
                        </td>
                    </tr>
                    <tr>

                        <td style="width: 308px;">
                            <select id="ddlMainTestDepartment" tabindex="0" onchange="LoadTestByDepartment()" autofocus="autofocus" style="width: 180px !important;">
                                    <option value="">Select Department</option>
                                </select>
                        </td>

                         <td style="width: 205px;">
                            <select id="ddlTestList">
                                    
                                </select>
                             <div id="divRotation">
                                    <select id="ddlRotation" style="display: none; width: 100px">
                                    </select>
                                </div>
                                <div id="divX_Ray">
                                    <select id="ddlXRayLF" style="display: none;width: 73px !important;margin-left: 101px;margin-top: -28px;height: 28px;">
                                      <option value="0"></option>
                                        <option value="L">Left</option>
                                        <option value="R">Right</option>
                                    </select>
                                </div>
                        </td>
                      
                         <td>
                            
                                
                           
                                <input type="button" tabindex="2" onfocus="this.className='focused'" value="Add Test" id="btnAddAllTest" onclick="AddAllTest()"/>
                            </td>
                        

                    </tr>
                    <tr>
                    <td>Remarks:

                            <input type="text" id="Remarks" />
                            </td>
                        </tr>
                </table>--%>
                 <div style="width: 742px; overflow: scroll; height: 250px !important; height: auto;margin-left: 60px;margin-top: 20px;">
                <table class="table" style="width: 724px; height: 146px !important; height: auto; overflow: scroll;" id="tbltestModelTable">
                    <thead>
                        <tr>
                            <th style="width: 50px; text-align: left;">Sr. </th>
                            <th style="width: 53px; text-align: left;">Action </th>
                            <th style="text-align: left;width: 352px;">Description </th>
                            <th style="text-align: left;width: 352px;">Remarks </th>
                             <th style="width: 65px; text-align: left;">Qty </th>
                            <th style="width: 60px; text-align: left;">Amount </th>
                            <%--<th style="width: 70px; text-align: left;">Dis % </th>
                            <th style="width: 95px; text-align: left;">Dis Amount </th>
                            <th style="width: 100px; text-align: left;">Net Amount </th>--%>
                        </tr>
                    </thead>
                    <tbody>
                    </tbody>
                </table>
            </div>
             <div class="modal-footer">
                    <input type="button" id="Button1" name="saveENT" value="Save" data-dismiss="modal" />
                  
                </div>
                
                

            </div>

        </div>

    </div>
    <div>
           <input type="button" value="Save" onclick="SaveRecord()" id="btnSave" />
         <input type="button" value="New" onclick="window.location = 'PaymentForm.aspx'" />
                        <input type="button" value="Print" name="name" onclick="BackToPrint();" style="width: 100px;" />
                        <input type="button" value="List View" onclick="window.open('PaymentFormList.aspx')" />
    </div>
</asp:Content>
