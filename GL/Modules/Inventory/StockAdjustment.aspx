<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="StockAdjustment.aspx.cs" Inherits="PMS.WebForm5" EnableEventValidation="false" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/Tibbit_theme/css/CustomCss/stockadjustment.css" rel="stylesheet" />

    <script type="text/javascript">
        var Stock_ID = 0;
        $(document).ready(function () {
            $('#ctl00_MainContent_txtBatchNo').on('change keyup', function () {
                DisableDropdownOnTextInput();

                if ($(this).val() != '') {
                    $(this).removeClass('ErrorAlert');
                    $('#ctl00_MainContent_hdbatch').val(0);
                    $('#ctl00_MainContent_hdallowblank').val(0);
                } else {
                    $(this).addClass('ErrorAlert');
                    $('#ctl00_MainContent_hdbatch').val(1);
                    $('#ctl00_MainContent_hdallowblank').val(1);
                }

            });

            $('#ctl00_MainContent_ddlBatchNo').select2({
                width: '100%',
                placeholder: '-- Select Batch --',
                allowClear: true,
                closeOnSelect: true,
                dropdownParent: $('#<%= pnlForm.ClientID %>')
            });

            $('#ctl00_MainContent_ddlBatchNo').on('change select2:close', function () {
                DisableTextOnDropdownChange();
                var $ddl = $(this);
                setTimeout(function () {
                    $ddl.select2('close');
                }, 100);
            });

            $('#ctl00_MainContent_ddlBatchNo').on('change', function () {
                DisableTextOnDropdownChange();
            });

            // Expire date change event
            $('#ctl00_MainContent_txtExpiredate').on('change', function () {
                if ($(this).val() != '') {
                    $(this).removeClass('ErrorAlert');
                    $('#ctl00_MainContent_hdDate').val(0);
                } else {
                    $(this).addClass("ErrorAlert");
                    $('#ctl00_MainContent_hdDate').val(1);
                }
            });

            GetWareHouseCondition();

            $('#ctl00_MainContent_txtItem_Code').tokenInput(function () {
                debugger;

                if (warehouseCond == '01') {
                    var warehouseVal = $('#ctl00_MainContent_ddl_Ware_House').val();
                    debugger;
                    if (!warehouseVal || warehouseVal === "0" || warehouseVal === "") {
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'Please Select Warehouse',
                            showConfirmButton: false,
                            timer: 2000,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });
                        //return false;
                        return "";
                    }

                    return "../../json.aspx?Table=INV_ItemsforStockAdjWareHouse&WarehouseID=" + encodeURIComponent(warehouseVal);
                }
                else {
                    return "../../json.aspx?Table=INV_ItemsforStockAdj"
                }
            },
                {
                    tokenLimit: 1,
                    hintText: "Select a warehouse first...",
                    noResultsText: "No items found.",
                    searchingText: "Searching...",

                    onAdd: function (item) {
                        debugger;
                        LoadBatches(item.id);
                        calculatecurrentstock(item.id);

                        if (item.Type === "True") {
                            $('#ctl00_MainContent_hdbatch').val(1);
                            $('#ctl00_MainContent_hdDate').val(1);
                            $('#ctl00_MainContent_hdallowblank').val(1);

                            $('#ctl00_MainContent_txtBatchNo').addClass("ErrorAlert");
                            $('#ctl00_MainContent_txtExpiredate').addClass("ErrorAlert");

                            $('#ctl00_MainContent_hdbatch').val(1);
                            $('#ctl00_MainContent_hdDate').val(1);
                            $('#ctl00_MainContent_hdallowblank').val(0);
                        }
                    }
                });
            debugger;
               <% if (Request.QueryString["ID"] != null)
        { %>
            Stock_ID = '<%= Request.QueryString["ID"]%>'
               <% } %>
            if (Stock_ID == 0) {
                $('#btnVoucher').hide();

            }
            var status = $('#ctl00_MainContent_txt_status').val();
            if (status == "Approved") {
                $('#ctl00_MainContent_btnSave').attr("disabled", 'disabled');
                $('#btnVoucher').show();
                UserUnApproveButtonRights();
            }
            if (status == "Created") {
                $('#ctl00_MainContent_btnSave').attr("disabled", false);
                $('#btnVoucher').hide();
            }

        });
        function hiddenVal(hiddenDate, hiddenbatch, hiddenallowblank) {
            if (hiddenDate == "1") $('#ctl00_MainContent_txtExpiredate').addClass("ErrorAlert");
            if (hiddenbatch == "1") $('#ctl00_MainContent_txtBatchNo').addClass("ErrorAlert");
        }

        //function loadtokenInputsDefaultPRNo() {
        //    debugger;
        //    var warehouseVal = $('#ctl00_MainContent_ddl_Ware_House').val();

        //    if (warehouseVal === "0" || warehouseVal === null) {
        //        return;
        //    }

        //    try {
        //        $('#ctl00_MainContent_txtItem_Code').tokenInput("clear");
        //        $('#ctl00_MainContent_txtItem_Code').tokenInput("destroy");
        //    } catch (e) { }

        //    $('#ctl00_MainContent_txtItem_Code').tokenInput("../../json.aspx?Table=INV_ItemsforStockAdjWareHouse&WarehouseID=" + encodeURIComponent(warehouseVal), {
        //        tokenLimit: 1,
        //        onAdd: function (item) {
        //            debugger;
        //            calculatecurrentstock(item.id);

        //            if (item.Type === "True") {
        //                $('#ctl00_MainContent_hdbatch').val(1);
        //                $('#ctl00_MainContent_hdDate').val(1);
        //                $('#ctl00_MainContent_hdallowblank').val(1);

        //                $('#ctl00_MainContent_txtBatchNo').addClass("ErrorAlert");
        //                $('#ctl00_MainContent_txtExpiredate').addClass("ErrorAlert");

        //                $('#ctl00_MainContent_hdbatch').val(1);
        //                $('#ctl00_MainContent_hdDate').val(1);
        //                $('#ctl00_MainContent_hdallowblank').val(0);
        //            }
        //        }
        //    });
        //}
        var warehouseCond;
        function GetWareHouseCondition() {

            $.ajax({
                type: "POST",
                url: "StockAdjustment.aspx/GetWareHouseCondition",
                data: JSON.stringify({}),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
                    warehouseCond = JSON.parse(response.d);
                    if (warehouseCond == '01') {
                        $('#divWarehouse').show();
                    }
                    else {
                        //$('#divWarehouse').hide();
                    }
                },
                error: function (error) {
                    console.error("Error fetching items", error);
                }
            });
        }
        function loadtokenInputsForPRNo(elementId, data) {
            if (elementId == "#ctl00_MainContent_txtItem_Code") {
                $(elementId).tokenInput("../../json.aspx?Table=INV_ItemsforStockAdj&q=",
                    {
                        prePopulate: data,
                        tokenLimit: 1,
                    });
            }
        }
        $(document).ready(function () {
            UserRights();
            $('#ctl00_MainContent_txtBatchNo').on('change', function () {
                if ($(this).val() != '') {
                    $('#ctl00_MainContent_txtBatchNo').removeClass('ErrorAlert');
                    $('#ctl00_MainContent_hdbatch').val(0);
                    $('#ctl00_MainContent_hdallowblank').val(0);
                }
                else {
                    $('#ctl00_MainContent_txtBatchNo').addClass('ErrorAlert');
                    $('#ctl00_MainContent_hdbatch').val(1);
                    $('#ctl00_MainContent_hdallowblank').val(1);
                }
            });
            $('#ctl00_MainContent_txtExpiredate').on('change', function () {
                if ($(this).val() != '') {
                    $('#ctl00_MainContent_txtExpiredate').removeClass('ErrorAlert');
                    $('#ctl00_MainContent_hdDate').val(0);
                }
                else {
                    $('#ctl00_MainContent_txtExpiredate').addClass("ErrorAlert");
                    $('#ctl00_MainContent_hdDate').val(1);
                }
            });

            var ad_ID = '<%= Request.QueryString["ID"] %>';
            var $adjustDate = $('#ctl00_MainContent_txtAdustment_date');
            var $expireDate = $('#ctl00_MainContent_txtExpiredate');

            var dateFormat = "dd M yy";

            $adjustDate.datepicker({
                changeMonth: true,
                changeYear: true,
                yearRange: "-50:+50",
                dateFormat: dateFormat
            });

            $expireDate.datepicker({
                changeMonth: true,
                changeYear: true,
                yearRange: "-50:+50",
                dateFormat: dateFormat
            });

            if (ad_ID === "") {
                var currentDate = $.datepicker.formatDate(dateFormat, new Date());
                $adjustDate.val(currentDate);
                $expireDate.val(currentDate);
            }
            window.onunload = refreshParent;
            function refreshParent() {
            }
            debugger;
            var AdjustmentID = $('#<%=txtAdjustment_ID.ClientID%>').val();
            var Item_Code = $("#ctl00_MainContent_txtItem_Code").val();
            var Item_ID = $("#ctl00_MainContent_hdfItem_ID").val();
            var Item_Name = $("#ctl00_MainContent_hdnDescription").val();
            if (AdjustmentID != "(New)") {
                debugger;
                var tokendata = [{ "id": Item_ID, "name": Item_Code + '-' + Item_Name, "Type": "", "Amount": '+0+' }];
                loadtokenInputsForPRNo("#ctl00_MainContent_txtItem_Code", tokendata);
                calculatecurrentstock(Item_ID);
            }
            else {
                //loadtokenInputsDefaultPRNo();
            }
            $('.token-input-list').css('width', '368px');
        });

        function UserRights() {
            debugger;
            $.ajax({
                type: "POST",
                url: "StockAdjustment.aspx/UserEntryRights",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
                    var hasRights = response.d;
                    debugger;
                    if (hasRights) {
                        debugger;
                        $('#ctl00_MainContent_btnSave').show();
                    } else {
                        $('#ctl00_MainContent_btnSave').hide();
                    }
                },
                failure: function (response) {
                    alert("Failed to retrieve user rights.");
                }
            });
        }


        function httpGet(theUrl) {
            var xmlHttp = null;
            xmlHttp = new XMLHttpRequest();
            xmlHttp.open("GET", theUrl, false);
            xmlHttp.send(null);
            return xmlHttp.responseText;
        }
        function onchange() {
            var num1 = parseFloat(document.getElementById('<%= txtQuantity.ClientID %>').value);
            var num2 = parseFloat(document.getElementById('<%= txtRate.ClientID %>').value);
            if (isNaN(num1))
                num1 = 0;
            if (isNaN(num2))
                num2 = 0;
            var totalresult = 0;
            totalresult = num1 * num2;
            document.getElementById('<%= txtAmount.ClientID %>').value = parseFloat(totalresult).toFixed();
        }
        function New() {
            window.location = "StockAdjustment.aspx";
        }
        function Validate() {
            var val = document.getElementById("hdnDuplicateCheck").value;
            var returnVal = false;
            if (val == "0")//no duplicate
            {
                document.getElementById("hdnDuplicateCheck").value = "1";
            }
            else {

                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Processing Please Wait',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });
                 return false;
            }
        }
        <%--function Approve() {
            debugger;
            var user_id = '<% =AppConfig.UserID %>';
            PageMethods.ApproveStock(Stock_ID, function (Tests) {
                debugger
                var message = JSON.parse(Tests);
                if (message[0].Column1 != "") {
                    alert("Approved Successfully");
                    window.location.href = 'StockAdjustment.aspx';
                }
            });
        }
        function UnApprove() {
            debugger;
            PageMethods.UnApproveStock(Stock_ID, function (Tests) {
                debugger
                var message = JSON.parse(Tests);
                if (message[0].Column1 == "1") {
                    alert("Un Approve Done Successfully");
                    location.reload();
                }
            });
        }     --%> 

        function UnApprove() {
            debugger;
            PageMethods.UnApproveStock(Stock_ID, function (Tests) {
                debugger
                var message = JSON.parse(Tests);
                if (message[0].Column1 != "" || message[0].Column1 != null) {
                    alert(message[0].Column1);
                    location.reload();
                }
            });
        }

        debugger;
        function PrintVoucher() {
            debugger;
            var id = '<%= Request.QueryString["ID"]%>';
            var locationInfo = window.location;

            var user_name = '<% =AppConfig.Company_Name %>';
            if (user_name == 'As-Siraat Serving Humanity') {
                reportPath = '../../ReportViewer.aspx';
            } else {
                reportPath = 'ReportViewer.aspx'; // same folder
            }

            var url = '/ReportViewer.aspx?ReportName=Voucher&ReportTitle=Adj Voucher&TransID=' + id + '&TransType=Adj';
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + '/' + reportPath + '?ReportName=Voucher&ReportTitle=Adj Voucher&TransID=' + id + '&TransType=Adj';
            }
            window.open(url, '_blank');
        }
        var amountonedit = 0;
        function calculatecurrentstock(item_id) {
            debugger;
            var itemID = '';
            if (item_id > 0) {
                itemID = item_id;
                var batchitem = item_id;
                checkbatchitem(batchitem);
            }
            else {
                itemID = $('#ctl00_MainContent_txtItem_Code').val();
            }
            var wareHouse = $('#ctl00_MainContent_ddl_Ware_House').val();
            debugger;
            if (itemID > 0 && wareHouse != "0") {
                PageMethods.calculateStock(itemID, wareHouse, function (res) {
                    debugger;
                    $('#ctl00_MainContent_txtcurrentStock').val(res);

                });
            }
        }
        function checkbatchitem(batchitem) {
            debugger;
            PageMethods.checkbatch(batchitem, function (res) {
                debugger;
                var batchcheck = res;
                $('#ctl00_MainContent_hndcheckbatch').val(res);
            });


        }
        function UserUnApproveButtonRights() {
            debugger;
            $.ajax({
                type: "POST",
                url: "StockAdjustment.aspx/UserUnApproveEntryRights",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
                    var hasRights = response.d;
                    debugger;
                    if (hasRights) {
                        debugger;
                        $('#btnUnApprove').show();
                    } else {
                        $('#btnUnApprove').hide();
                    }
                },
                failure: function (response) {
                    alert("Failed to retrieve User UnApprove Button Rights.");
                }
            });
        }
        function showTooltip(input) {
            var tooltip = document.getElementById("tooltipQuantity");
            tooltip.style.display = "inline";
            var rect = input.getBoundingClientRect();
            tooltip.style.left = rect.left + "px";
            tooltip.style.top = (rect.bottom + window.scrollY + 5) + "px";
        }
        function hideTooltip() {
            document.getElementById("tooltipQuantity").style.display = "none";
        }
        function LoadBatches(item_id) {
            debugger;
            if (!item_id || item_id == "") {
                console.log("No item ID provided");
                return;
            }

            console.log("Loading batches for item_id: " + item_id);

            // Enable both fields before loading new batches
            EnableBothFields();

            $.ajax({
                type: "POST",
                url: "StockAdjustment.aspx/Getbatch_grn",
                data: JSON.stringify({ item_id: item_id }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
                    var result = JSON.parse(response.d);

                    // Clear existing options
                    $('#ctl00_MainContent_ddlBatchNo').empty();
                    $('#ctl00_MainContent_ddlBatchNo').append('<option value="0">-- Select Batch --</option>');

                    // Add batches from GRN
                    if (result.GRN_Details && result.GRN_Details.length > 0) {
                        $.each(result.GRN_Details, function (i, batch) {
                            $('#ctl00_MainContent_ddlBatchNo').append('<option value="' + batch.BatchNum + '">' + batch.BatchNum + ' (GRN)</option>');
                        });
                    }

                    // Add batches from Stock Adjustment
                    if (result.Stock_Adjustment_Details && result.Stock_Adjustment_Details.length > 0) {
                        $.each(result.Stock_Adjustment_Details, function (i, batch) {
                            $('#ctl00_MainContent_ddlBatchNo').append('<option value="' + batch.BatchNum + '">' + batch.BatchNum + ' (Adjustment)</option>');
                        });
                    }
                    //$('#ctl00_MainContent_ddlBatchNo').select2();
                },
                error: function (error) {
                    console.log("Error loading batches: " + error);
                }
            });
        }
        function DisableDropdownOnTextInput() {
            var txtBatchNo = $('#ctl00_MainContent_txtBatchNo');
            var ddlBatchNo = $('#ctl00_MainContent_ddlBatchNo');
            var hdnBatch = $('#ctl00_MainContent_hdnSelectedBatchValue');

            if (txtBatchNo.val().trim() !== '') {
                ddlBatchNo.prop('disabled', true);
                ddlBatchNo.val('0');

                hdnBatch.val(txtBatchNo.val().trim());
            } else {
                ddlBatchNo.prop('disabled', false);
                hdnBatch.val('');
            }
        }


        function DisableTextOnDropdownChange() {
            var txtBatchNo = $('#ctl00_MainContent_txtBatchNo');
            var ddlBatchNo = $('#ctl00_MainContent_ddlBatchNo');
            var hdnBatch = $('#ctl00_MainContent_hdnSelectedBatchValue');

            if (ddlBatchNo.val() !== '0' && ddlBatchNo.val() !== null && ddlBatchNo.val() !== '') {
                txtBatchNo.prop('disabled', true);
                txtBatchNo.val('');
                hdnBatch.val(ddlBatchNo.val());

                txtBatchNo.removeClass('ErrorAlert');
                $('#ctl00_MainContent_hdbatch').val(0);
                $('#ctl00_MainContent_hdallowblank').val(0);
            } else {
                txtBatchNo.prop('disabled', false);
                if (txtBatchNo.val() === '') {
                    hdnBatch.val('');
                }
            }
        }

        // Function to enable both fields when clearing
        function EnableBothFields() {
            $('#ctl00_MainContent_txtBatchNo').prop('disabled', false);
            $('#ctl00_MainContent_ddlBatchNo').prop('disabled', false).val('0');
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <asp:HiddenField runat="server" ID="hdnSelectedBatchValue" />
    <form id="item">
        <div class="row">
            <div class="col-lg-2 col-md-3 col-sm-4">
                <asp:Label Text="Transaction ID" runat="server" ID="lblAdjustment_ID" />
                <asp:TextBox runat="server" ID="txtAdjustment_ID" ReadOnly="true" Text="(New)" />
            </div>
            <div class="col-lg-2 col-md-3 col-sm-4">
                <asp:Label Text="Transaction Date" runat="server" ID="lblAdustment_date" />
                <asp:TextBox runat="server" ID="txtAdustment_date" />
                <asp:RequiredFieldValidator ID="rfvAdjustment_date" ErrorMessage="Date is required."
                    ControlToValidate="txtAdustment_date" runat="server" SetFocusOnError="true" Display="Dynamic" />
            </div>
            <div class="col-lg-2 col-md-3 col-sm-4">
                <asp:Label Text="Status" runat="server" ID="lbl_Status" />
                <asp:TextBox runat="server" ID="txt_status" ReadOnly="true" />
            </div>
            <div class="col-lg-2 col-md-3 col-sm-4">
                <asp:Label Text="Batch No" runat="server" ID="Label2" />
                <asp:TextBox runat="server" ID="txtBatchNo" />
                <asp:RequiredFieldValidator ID="RequiredFieldValidator2" ErrorMessage="BatchNo is required."
                    ControlToValidate="txtBatchNo" runat="server" SetFocusOnError="true" Display="Dynamic" InitialValue="0" />
            </div>
            <div class="col-lg-4 col-md-3 col-sm-4">
                <asp:Label Text="Item Code & Description" runat="server" ID="lblItem_Code" />
                <asp:TextBox runat="server" ID="txtItem_Code" />
                <asp:RequiredFieldValidator ErrorMessage="Item Code is required." ID="rfvItemCode"
                    ControlToValidate="txtItem_Code" runat="server" SetFocusOnError="true" Display="Dynamic" />
            </div>
        </div>
        <div class="row">
            <div class="col-lg-2 col-md-3 col-sm-4">
                <asp:Label Text="Expire Date" runat="server" ID="Label1" />
                <asp:TextBox runat="server" ID="txtExpiredate" />
                <asp:RequiredFieldValidator ID="RequiredFieldValidator1" ErrorMessage="Date is required."
                    ControlToValidate="txtExpiredate" runat="server" SetFocusOnError="true"  Display="Dynamic" InitialValue="0" />
            </div>
            <div class="col-lg-2 col-md-3 col-sm-4">
                <asp:Label Text="Quantity" runat="server" ID="Label4" />
                <asp:TextBox runat="server" ID="txtQuantity" onchange="return onchange();" autocomplete="off" onfocus="showTooltip(this);" onblur="hideTooltip(this);" />
                <asp:RequiredFieldValidator ID="rfvQuantity" ErrorMessage="Quantity is required."
                    ControlToValidate="txtQuantity" runat="server" SetFocusOnError="true" Display="Dynamic" />
                     <!-- Tooltip -->
            <span id="tooltipQuantity" class="tooltip-style" style="display:none;">Enter quantity in loose.</span>
            </div>
            <div class="col-lg-2 col-md-3 col-sm-4">
                <asp:Label Text="Rate" runat="server" ID="lblRate" />
                <asp:TextBox runat="server" ID="txtRate" onchange="return onchange();"  />
                <asp:RequiredFieldValidator ID="rfvRate" ErrorMessage="Rate is required."
                    ControlToValidate="txtRate" runat="server" SetFocusOnError="true" Display="Dynamic" />
                 
            </div>
            <div class="col-lg-2 col-md-3 col-sm-4">
                <asp:Label Text="Amount" runat="server" ID="lblAmount" />
                <asp:TextBox runat="server" ID="txtAmount" ReadOnly="True" />
            </div>
            <div class="col-lg-2 col-md-3 col-sm-4" id="divWarehouse">
                <asp:Label ID="Label3" runat="server" Text="WareHouse"></asp:Label>
                <asp:DropDownList runat="server" ID="ddl_Ware_House" AppendDataBoundItems="true" onchange="calculatecurrentstock()">
                </asp:DropDownList>
                <asp:RequiredFieldValidator ID="rfvddl_Ware_House" ErrorMessage="Ware House is required."
                    ControlToValidate="ddl_Ware_House" InitialValue="0" runat="server" SetFocusOnError="true" Display="Dynamic" />
            </div>
            <div class="col-lg-2 col-md-3 col-sm-4">
                <asp:Label ID="lb_currentStock" runat="server" Text="Current Stock"></asp:Label>
                <asp:TextBox runat="server" ID="txtcurrentStock" ReadOnly="True" />               
                <asp:HiddenField ID="hndcheckbatch" runat="server" />                 
            </div>
         
        </div>
        <div class="row">
               <div class="col-lg-2 col-md-3 col-sm-4">
               <asp:Label Text="Batch No" runat="server" ID="Label5" />
               <asp:DropDownList runat="server" ID="ddlBatchNo" Style="width: 100%; height: 35px;" onchange="DisableTextBatch()">
                   <asp:ListItem Text="-- Select Batch --" Value="0" />
               </asp:DropDownList>
           </div>
            <div class="col-lg-4 col-md-3 col-sm-4">
                <asp:Label ID="lbl_Reason_Needed" runat="server" Text="Reason Needed"></asp:Label>
                <asp:DropDownList runat="server" ID="ddlReasonNeeded" Style="height: 35px;" AppendDataBoundItems="true">
                </asp:DropDownList>
            </div>
            <div class="col-lg-4 col-md-3 col-sm-4">
                <asp:Label Text="Remarks" runat="server" ID="lblremarks" />
                <asp:TextBox ID="txtRemarks" runat="server" TextMode="MultiLine" Style="width: 100%; border-radius: 5px; height: 35px !important"></asp:TextBox>
            </div>
        </div>
        <div class="row">
            <div class="col-lg-0 col-md-3 col-sm-4">
                <input type="hidden" name="hdnDuplicateCheck" value="0" id="hdnDuplicateCheck" />            
                <asp:TextBox runat="server" ID="hdfItem_Code" Style="display: none" />
            </div>
        </div>
    </form>

    <asp:Panel runat="server" ID="pnlForm">
        <div class="row">
            <div class="col-lg-8">
                <div class="row">
            <div class="col-lg-2 col-md-4 col-sm-6">               
             <input type="button" class="btn-gray" name="back" value="View" onclick="location.href = 'StockAdjustmentView.aspx'" />
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <asp:Button Text="Save" Class="btn btn-primry" ID="btnSave" runat="server" OnClick="btnSave_Click" OnClientClick="return Validate();" />
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <input type="button" class="btn btn-yellow" value="New" id="btnNew" onclick="New()" />
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <input type="button" class="btn btn-primry"  value="Voucher" id="btnVoucher" onclick="PrintVoucher()" />
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <input type="button" style="display:none" class="btn btn-primry" value="UnApprove" id="btnUnApprove" onclick="UnApprove()" />
                </div>
        </div>
            </div>
        </div>
        <%--&nbsp;<input type="button" style="width: 93px;display:none" value="Approve" id="btnApprove" onclick="Approve()" /> --%>
        <asp:Label ID="lblMessage" runat="server" />
    </asp:Panel>
    <asp:HiddenField runat="server" ID="hdbatch" />
    <asp:HiddenField runat="server" ID="hdDate" />
    <asp:HiddenField runat="server" ID="hdallowblank" />
    <asp:HiddenField runat="server" ID="hdnDescription" />
    <asp:HiddenField runat="server" ID="hdfItem_ID" />
</asp:Content>
