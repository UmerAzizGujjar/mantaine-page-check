<%@ Page EnableSessionState="ReadOnly" Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ApprovalTempelates.aspx.cs" Inherits="PMS.GL.ApprovalTempelates" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/lib/sweetalert/swalalert.css" rel="stylesheet" />
    <script type="text/javascript">   
        $(document).ready(function () {
            $('select').select2();

            var id = '<% =Request.QueryString["ID"] %>';
            if (id != "") {
                $('#btnSave').val('Update');
                LoadMasterData(id);
                LoadFormIds(id);
                setTimeout(function () {
                    LoadStageId(id);
                }, 2000);
            }
            $('#btnNew').on('click', function () {
                window.location.href = "ApprovalTempelates.aspx";
            });
            $('#btnList').on('click', function () {
                window.location.href = "ApprovalTempelatesView.aspx";
            });
            $('#btnSave').on('click', function () {
                var id = $('#txtTempelateID').val();
                if (id == "") {
                    id = "";
                }
                var btnValue = $("#btnSave").val();
                var txttempelateName = $("#txtTempName").val();
                var txttempelateDescription = $("#txtTempelateDescription").val();
                var chkIsActive = $("#chkIsActive").prop('checked');
                if (txttempelateName == "") {

                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Please Enter Tempelate Name',
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
                var checkedPurchasesFormIDs = [];
                var checkedPurchasesCheckBoxIDs = [];
                $("#<%=chkPurchases.ClientID%> input[type='checkbox']:checked").each(function () {
                    var checkboxID = $(this).attr('id');
                    var index = checkboxID.split('_').pop();
                    var formID = $("#ctl00_MainContent_PurchasehidFormID_" + index).val();
                    checkedPurchasesFormIDs.push(formID);
                    checkedPurchasesCheckBoxIDs.push(checkboxID);
                });

                var checkedInventoryFormIDs = [];
                var checkedInventoryCheckBoxIDs = [];
                $("#<%=chkInventory.ClientID%> input[type='checkbox']:checked").each(function () {
                    var checkboxID = $(this).attr('id');
                    var index = checkboxID.split('_').pop();
                    var formID = $("#ctl00_MainContent_InventoryhidFormID_" + index).val();
                    checkedInventoryFormIDs.push(formID);
                    checkedInventoryCheckBoxIDs.push(checkboxID);
                });

                var checkedAccountPayableFormIDs = [];
                var checkedAccountPayableCheckBoxIDs = [];
                $("#<%=chkAccountPayable.ClientID%> input[type='checkbox']:checked").each(function () {
                    var checkboxID = $(this).attr('id');
                    var index = checkboxID.split('_').pop();
                    var formID = $("#ctl00_MainContent_AccountPayablehidFormID_" + index).val();
                    checkedAccountPayableFormIDs.push(formID);
                    checkedAccountPayableCheckBoxIDs.push(checkboxID);
                });

                var StageList = new Array();
                var list = document.getElementById('Stageslist');
                if (list.rows.length <= 1) {

                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Please add Stage',
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
                var stagetable = $('#appStagess');
                stagetable.find('tr').each(function (key, value) {
                    var ddlstages = $("#tblddlStage" + (key + 1) + " option:selected").val();
                    if (ddlstages == "") {

                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'Please Select Stage',
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
                    StageList[key + 1] = new Array(ddlstages);
                });
                $.ajax({
                    type: "POST",
                    url: "ApprovalTempelates.aspx/Save",
                    data: JSON.stringify({
                        "btnValue": btnValue,
                        "id": id,
                        "txttempelateName": txttempelateName,
                        "txttempelateDescription": txttempelateDescription,
                        "chkIsActive": chkIsActive,
                        "CheckedPurchasesFormIDs": checkedPurchasesFormIDs,
                        "CheckedPurchasesCheckBoxIDs": checkedPurchasesCheckBoxIDs,
                        "CheckedInventoryFormIDs": checkedInventoryFormIDs,
                        "CheckedInventoryCheckBoxIDs": checkedInventoryCheckBoxIDs,
                        "CheckedAccountPayableFormIDs": checkedAccountPayableFormIDs,
                        "CheckedAccountPayableCheckBoxIDs": checkedAccountPayableCheckBoxIDs,
                        "StageDetail": StageList
                    }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        var data = response.d;
                        Swal.fire({
                            icon: 'success',
                            title: 'Success!',
                            text: 'Data has been saved successfully.',
                            showConfirmButton: false,
                            timer: 2500,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });
                        window.location.href = "ApprovalTempelates.aspx?ID=" + data;
                    }, error: function () { }
                });
            });
        });
        $(function () {
            $("#tabs").tabs();
        });
        function LoadMasterData(id) {
            $.ajax({
                type: "POST",
                url: "ApprovalTempelates.aspx/LoadMasterData",
                data: JSON.stringify({
                    "id": id
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var parsed_Data = JSON.parse(response.d);
                    $("#txtTempelateID").val(parsed_Data.Tempelate_ID);
                    $("#txtTempName").val(parsed_Data.Tempelate_Name);
                    $("#txtTempelateDescription").val(parsed_Data.Tempelate_Description);
                    if (parsed_Data.IsActive == true) {
                        $("#chkIsActive").prop('checked', true);
                    }
                }, error: function () { }
            });
        }

        function LoadFormIds(id) {
            var rows = '';
            PageMethods.LoadFormIds(id, function (resp) {
                var data = JSON.parse(resp);
                console.log(data);
                data.forEach(function (checkboxId) {
                    console.log(checkboxId);
                    $('#' + checkboxId).prop('checked', true);
                });
            });
        }

        function LoadStageId(id) {
            var rows = '';
            PageMethods.LoadStageId(id, function (resp) {
                var data = JSON.parse(resp);
                var rowIndex = $('#appStagess tbody tr').length;
                $.each(data, function (key, value) {
                    rows += '<tr>' +
                        '<td><select class="form-control ddlStage" id="tblddlStage' + (key + 1) + '" name="tblddlStage" style="width:100% !important"></select></td>' +
                        '<td><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="glyphicon glyphicon-trash" style="width:15px !important;font-size: 13px;color:#f30a0a;position:relative;"></i></a>' +
                        '</td>' +
                        '</tr>';
                });
                $('#appStagess').append(rows);
                loadStItemList(data);
            });
        }
        function loadStItemList(selectedValue) {
            console.log(selectedValue);
            var optionsStage = '';
            var ddlPromises = [];
            $('.ddlStage').each(function (index) {
                var ddlstage = $(this);
                ddlstage.select2();
                var ddlPromise = new Promise(function (resolve, reject) {
                    PageMethods.loadSatges(function (resp) {
                        optionsStage = '<option value="0">Please Select</option>';
                        $.each(JSON.parse(resp), function (key, value) {
                            optionsStage += '<option value="' + value.Stage_ID + '" >' + value.Stage_Name + '</option>';
                        });
                        ddlstage.html(optionsStage);
                        resolve();
                    }, function (error) {
                        reject(error);
                    });
                });
                ddlPromises.push(ddlPromise);
            });
            Promise.all(ddlPromises).then(function () {
                $('.ddlStage').each(function (index) {
                    console.log('Index');
                    console.log(index);
                    var selval = selectedValue[index];
                    console.log(selval);
                    if (selval) {
                        selval = parseInt(selval);
                        $('#tblddlStage' + (index + 1)).val(selval);
                        $('#tblddlStage' + (index + 1)).trigger('change');
                    }
                });
            }).catch(function (error) {
                console.error('Error loading dropdowns:', error);
            });
        }

        function AppendStages() {
            var NoStageselect = false;
            $('#appStagess select').each(function () {
                if ($(this).val() === "0") {
                    NoStageselect = true;
                    return false;
                }
            });
            if (NoStageselect) {

                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please select Stage.',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

            } else {
                var rows = '';
                var rowlength = Stageslist.rows.length;
                rows = '<tr>' +
                    '<td>' +
                    '<select name="tblddlStage" style="width:100% !important" id="tblddlStage' + rowlength + '">' +
                    '</select>' +
                    '</td>' +
                    '<td><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="glyphicon glyphicon-trash" style="width:15px !important;font-size: 13px;color:#f30a0a;position:relative;" i=""></i></a>' +
                    '</td>' +
                    '</tr>'
                $('#appStagess').append(rows);
                loadStagesItemList(rowlength);
            }
        }
        function loadStagesItemList(rowlength) {
            var optionsStage = '';
            var length = rowlength;
            $('#tblddlStage' + length + '').select2();
            PageMethods.loadSatges(function (resp) {
                optionsStage = '<option value="0">Please Select</option>';
                $.each(JSON.parse(resp), function (key, value) {
                    optionsStage += '<option value="' + value.Stage_ID + '" >' + value.Stage_Name + '</option>';
                });
                $('#tblddlStage' + length + '').html(optionsStage);
            },
                function (error) {
                    alert(error.get_message());
                });
        }
        function ExcludeFromPayment(anchor) {
            Swal.fire({
                icon: 'warning',
                title: 'Are you sure?',
                text: 'This action will delete',
                showCancelButton: true,
                confirmButtonColor: '#d33',
                cancelButtonColor: '#3085d6',
                confirmButtonText: 'Yes, delete it!',
                cancelButtonText: 'Cancel',
                customClass: {
                    popup: 'swal-big-popup',
                    title: 'swal-big-title',
                    htmlContainer: 'swal-big-text'
                }
            }).then((result) => {
                if (result.isConfirmed) {
                    var row = $(anchor).parents('tr')[0];
                    row.remove();
                }
            });

        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <input type="hidden" id="txtTempelateID" name="txtTempelateID" />
    <div class="row">
        <div class="col-lg-3 col-md-5 col-sm-12">

            <label for="txtTempName">Tempelate Name</label>
            <input type="text" name="txtTempName" class="form-control" id="txtTempName" placeholder="Enter Tempelate Name" />

        </div>
        <div class="col-lg-3 col-md-5 col-sm-12">
            <label for="txtTempelateDescription">Tempelate Description</label>
            <input type="text" name="txtTempelateDescription" class="form-control" id="txtTempelateDescription" placeholder="Enter Tempelate Description" />
        </div>
        <div class="col-lg-1 col-md-2 col-sm-12" style="margin-top: 30px; width: 40px !important;">

            <input type="checkbox" id="chkIsActive" name="chkIsActive" />

        </div>
        <div class="col-lg-1 col-md-2 col-sm-12" style="margin-top: 30px;">
            <label id="lblchkIsActive">Active</label>

        </div>
    </div>

    <div class="col-lg-7">
        <div id="tabs">
            <ul>
                <li><a href="#Tab-2">Documents / Forms</a></li>
                <li><a href="#Tab-3">Stages</a></li>
            </ul>

            <div id="Tab-2">

                <div class="row">
                    <div class="col-lg-3">
                        <div class="checkbox-list-container">
                            <label class="double-underline" style="font-size: 20px">Purchase:</label>
                            <asp:CheckBoxList ID="chkPurchases" runat="server" CssClass="checkbox-item"></asp:CheckBoxList>
                            <div id="PurchasehiddenFieldsContainer" runat="server"></div>
                        </div>
                    </div>
                    <div class="col-lg-3">
                        <div class="checkbox-list-container">
                            <label class="double-underline" style="font-size: 20px">Inventory:</label>
                            <asp:CheckBoxList ID="chkInventory" runat="server" CssClass="checkbox-item"></asp:CheckBoxList>
                            <div id="InventoryhiddenFieldsContainer" runat="server"></div>
                        </div>
                    </div>
                    <div class="col-lg-3">
                        <div class="checkbox-list-container">
                            <label class="double-underline" style="font-size: 20px">Account Payable:</label>
                            <asp:CheckBoxList ID="chkAccountPayable" runat="server" CssClass="checkbox-item"></asp:CheckBoxList>
                            <div id="AccountPayablehiddenFieldsContainer" runat="server"></div>
                        </div>
                    </div>
                </div>
            </div>

            <div id="Tab-3" style="width: 526px;">
                <div class="table-container">
                    <table class="table table-bordered" id="Stageslist" style="font-size: 10px!important; overflow: unset;">
                        <thead>
                            <tr>
                                <th style="width: 90%;">Stage Name</th>
                                <th style="text-align: center; width: 10%;">Action</th>
                            </tr>
                        </thead>
                        <div class="col-lg-10"></div>
                        <div class="col-lg-2">
                            <input type="button" class="btn-primry" style="margin-left: 12px;"
                                onclick="AppendStages()" value="+" id="AddStages" />
                        </div>
                        <tbody id="appStagess">
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
    <br />
    <div class="row ">
        <div class="col-lg-8">
            <div class="row " style="margin-top: 10px;">
                <div class="col-lg-2 col-md-4 col-sm-6">
                    <input type="button" class="btn btn-primry" id="btnSave" value="Save" />
                </div>
                <div class="col-lg-2 col-md-4 col-sm-6">
                    <input type="button" class="btn btn-yellow" id="btnNew" value="New" />
                </div>
                <div class="col-lg-2 col-md-4 col-sm-6">
                    <input type="button" class="btn btn-gray" id="btnList" value="View" />
                </div>
            </div>
        </div>
    </div>

</asp:Content>
