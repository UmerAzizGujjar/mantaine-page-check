<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="GoodsIssuanceNote.aspx.cs" Inherits="PMS.Inventory.GoodsIssuanceNote" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/goods-issuance-note.css?v=20261020" rel="stylesheet" />


    <script type="text/javascript">
        var selectedOptions = '';
        var savedBranch = null;

        // ---- opening an existing note (edit mode) ----
        // The header and the items used to be loaded by fixed timers (1s / 2.5s) that raced with the organization / department
        // lists and with the organization 'change' handler, which empties the items table. When the header answered a little late,
        // its programmatic 'change' wiped the items that had just been added. Now: wait for the lookup lists, load header + items
        // together, and keep the table untouched while isLoadingExisting is true.
        var isLoadingExisting = false;
        var pendingEditLoads = 0;
        var editLoadSafetyTimer = null;
        function startEditLoad(SI_ID) {
            var waited = 0;
            (function waitForLists() {
                var ready = $('#ddlInventoryOrg option').length > 1 && $('#ddlDepartment option').length > 1 && typeof warehouseCond !== 'undefined';
                if (!ready && waited < 8000) { waited += 100; setTimeout(waitForLists, 100); return; }
                isLoadingExisting = true;
                pendingEditLoads = 2;
                LoadMaster(SI_ID);
                LoadDetail(SI_ID);
                clearTimeout(editLoadSafetyTimer);
                editLoadSafetyTimer = setTimeout(function () { isLoadingExisting = false; }, 30000); // safety net if one of the two calls never answers
            })();
        }
        function editLoadDone() {
            pendingEditLoads--;
            if (pendingEditLoads <= 0) { isLoadingExisting = false; clearTimeout(editLoadSafetyTimer); }
        }

        function loadUserBranch() {
            PageMethods.GetUserBranch(function (result) {
                if (!result || result === "null") {
                    $('#ddlBranch').empty().append('<option value="0">No Branch Assigned</option>');
                    return;
                }
                var branches = JSON.parse(result);
                $('#ddlBranch').empty();
                branches.forEach(function (branch) {
                    $('#ddlBranch').append('<option value="' + branch.branch_ID + '">' + branch.branch_Name + '</option>');
                });
                if (branches.length === 1) {
                    $('#ddlBranch').val(branches[0].branch_ID);
                } else {
                    $('#ddlBranch').prepend('<option value="0">Please Select</option>').val('0');
                }
                if (savedBranch) {
                    $('#ddlBranch').val(savedBranch).trigger('change');
                }
            });
        }

        $(document).ready(function () { 
            $('#ddlMIR').select2();
            LoadOrganizations();
            GetWareHouseCondition();   
            GetGIRCloseCondition();   
            LoadDepartments();
            $('#ddlBranch').select2();
            loadUserBranch();
            // Move this OUTSIDE the document ready function or ensure it's properly bound
            // Use event delegation or ensure the DOM is ready
            $(document).ready(function () {
                // Your existing document ready code remains here...

                // Add this event handler inside document ready
                $(document).on('click', '#confirmCloseBtn', function () {
                    var remarks = $('#remarks').val().trim();
                    if (remarks === "") {
                        Swal.fire({
                            icon: 'warning',
                            title: 'Warning!',
                            text: 'Please enter remarks before closing.',
                            showConfirmButton: true,
                            timer: 2000
                        });
                        return false;
                    }
                    var GIR = $('#ddlMIR').val();

                    if (!GIR || GIR === "0") {
                        Swal.fire({
                            icon: 'warning',
                            title: 'Warning!',
                            text: 'Please select a GIR first.',
                            showConfirmButton: true,
                            timer: 2000
                        });
                        return false;
                    }

                    $.ajax({
                        type: "POST",
                        url: "GoodsIssuanceNote.aspx/CloseGIR",
                        data: JSON.stringify({ 'GIR': GIR, 'remarks': remarks }),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",

                        beforeSend: function () {
                            $('#confirmCloseBtn').prop('disabled', true).text('Processing...');
                        },

                        success: function (response) {
                            if (response.d == "success") {
                                $('#remarksModal').modal('hide');
                                Swal.fire({
                                    icon: 'success',
                                    title: 'Success!',
                                    text: 'GIR Closed Successfully.',
                                    showConfirmButton: false,
                                    timer: 2000,
                                    customClass: {
                                        popup: 'swal-big-popup',
                                        title: 'swal-big-title',
                                        htmlContainer: 'swal-big-text'
                                    }
                                }).then(function () {
                                    location.reload();
                                });
                            } else {
                                $('#remarksModal').modal('hide');
                                Swal.fire({
                                    icon: 'error',
                                    title: 'Error!',
                                    text: 'There is some issue closing this GIR.',
                                    showConfirmButton: false,
                                    timer: 2000,
                                    customClass: {
                                        popup: 'swal-big-popup',
                                        title: 'swal-big-title',
                                        htmlContainer: 'swal-big-text'
                                    }
                                });
                            }
                        },

                        error: function (xhr, status, error) {
                            console.error("Error closing GIR:", error);
                            console.error("Response:", xhr.responseText);
                            $('#remarksModal').modal('hide');
                            Swal.fire({
                                icon: 'error',
                                title: 'Error!',
                                text: 'Server Error: ' + (xhr.responseText || 'Please try again later.'),
                                showConfirmButton: true
                            });
                        },

                        complete: function () {
                            $('#confirmCloseBtn').prop('disabled', false).text('Confirm Close');
                        }
                    });
                });
            });
            $('#btnGetAllItems').on('click', function () {
                $('#btnAdd').prop('disabled', true);
                LoadAllitem('');
            });
            // Bind the search input keyup
            $('#searchInput').on('keyup', function () {
                var searchText = $(this).val().trim();
                LoadAllitem(searchText);
            });


            $('#ddlDepartment').change(function () {
                if (warehouseCond == '01' && $('#ddlInventoryOrg').val() && $('#ddlInventoryOrg').val() != '0') {
                    getMIR();
                }
            });
            $('#ddlInventoryOrg').change(function () {
                if (isLoadingExisting) { return; } // the organization is being set from the saved note: keep the items being loaded
                $('#tblStoreIssueBote tbody').empty();
                $('#checkHeader').prop('checked', false);
            });
            UserRights();  
            $('#ddlInventoryOrg').change(function () {
                if (warehouseCond == "01") {
                    getMIR();
                    $("#ddlInventoryOrg").attr('disabled', true);
                }
                
            });
            var SI_ID = '<%= Request.QueryString["SI_ID"]%>';
             if (SI_ID != "") {
                

                 startEditLoad(SI_ID);
                 $("#btnSave").val('Update');
                 $("#divSaveandClose").hide();

             }
           
            if (SI_ID == "") {
                initializeMRNoDropdown();
                 $('#btn_Print').hide();
                 $('#btnVoucher').hide();
             }
             else {
                 // called by LoadMaster once the saved status is on the page (was a fixed 2s timer)
                 window.applyEditStatusUi = function () {
                     var status = $('#txtStatus').val();
                     if (status == "Approved") {
                         UserUnApproveButtonRights();
                         $('#btnSave').attr("disabled", 'disabled');
                         $('#btnVoucher').show();
                         $('#isCloseGIR').show();
                     }
                     if (status == "Created" || status == "Pending") {
                         $('#btnVoucher').hide();
                         $('#isCloseGIR').hide();
                         if (SI_ID != "") {
                             CheckGINApprovalRightsAndShowButton(SI_ID);
                         }
                     }
                 };
             }
             $('[id*=checkHeader]').click(function () {
                 var isTrue = $('#checkHeader').is(':checked');
                 if (isTrue) {
                     $('.chktd').prop('checked', true);
                     setTimeout(function () {
                         $("#tblMIRItemstModelTable tr:gt(0) input[type=checkbox]:checked ").each(function (key, value) {
                             var row = $(this);
                             append(row);
                         });
                     }, 1000);
                 }
                 else {
                     $('.chktd').prop('checked', false);
                 }
             });
             $('#btnAdd').on('click', function () {
                 var MIR_id = $("#ddlMIR").val();
                 LoadMIRDetail(MIR_id);
             });
            
            var GIRCloseCond;
            function GetGIRCloseCondition() {
                $.ajax({
                    type: "POST",
                    url: "GoodsIssuanceNote.aspx/GetGIRCloseCondition",
                    data: JSON.stringify({}),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        GIRCloseCond = JSON.parse(response.d);
                        if (GIRCloseCond == '01') {
                            $('#divSaveandClose').show();
                            $('#isCloseGIR').show();
                        }
                        else {
                            $('#divSaveandClose').hide();                          
                             $('#isCloseGIR').hide();                          
                        }
                    },
                    error: function (error) {
                        console.error("Error fetching items", error);
                    }
                });
            }
     
       <%--      $('#btnSave').on('click', function () {
                 var checkstock = false;
                 var status;
                 var btnSave = $('#btnSave').val();
                 var table = $('#tblStoreIssueBote');
                 var comapny_id = '0';
                 var department_id = $('#ddlDepartment').val();
                 var inventory_id = $('#ddlInventoryOrg').val();
                 var store_no = $('#txtStoreissueNo').val();
                 var MRNo = $('#ddlMRNo').val() || 0;
                 var StoreIssue_id = '0';
                 var SI_ID = '<%= Request.QueryString["SI_ID"]%>';
                 if (SI_ID != "") {
                     StoreIssue_id = SI_ID;
                 }
                 else {
                     StoreIssue_id = '0';
                 }
                 var Item_list = [];
                 table.find('tr:gt(0)').each(function (key, value) {
                     var StoreStock = $(value).find('td input[name=txtStoreStock]').val();
                     var IssueQty = $(value).find('td input[name=txtIssueQty]').val();
                     var MIRQty = $(value).find('td input[name=txtmirQty]').val();
                     var Batch = $(value).find('td input[name=txtBatch]').val();
                     var BatchNum = $(value).find('td select[name=ddlBatchNum]').val();
                     var lastIssueDate = $(value).find('td input[name=txtLastIsssueDate]').val();

                     if ((parseFloat(IssueQty) > parseFloat(StoreStock)) && btnSave == "Save") {
                         Swal.fire({
                             icon: 'error',
                             title: 'Error!',
                             text: 'Issue Qty Must Be Less Than Total Stock',
                             showConfirmButton: false,
                             timer: 2000,
                             customClass: {
                                 popup: 'swal-big-popup',
                                 title: 'swal-big-title',
                                 htmlContainer: 'swal-big-text'
                             }
                         });



                          checkstock = true;
                         return false;
                     }
                     if (btnSave == "Update") {
                         var txtSaveTimeStock = $(value).find('td input[name=txtSaveTimeStock]').val();
                         if (parseFloat(IssueQty) > parseFloat(txtSaveTimeStock)) {
                             Swal.fire({
                                 icon: 'error',
                                 title: 'Error!',
                                 text: 'Issue Qty Must Be Less Than Total Stock',
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
                     if (Batch == "true") {
                         if (BatchNum == "0" || BatchNum == "") {
                             status = "errorBatch";
                         }
                     }
                     if ((StoreStock == "" || StoreStock == 0 || StoreStock < 0) && btnSave == "Save") {
                         status = false;
                     }
                     else if (((IssueQty == "" || IssueQty == 0 || IssueQty < 0) || (parseInt(MIRQty) != 0 && parseInt(MIRQty) < parseInt(IssueQty))) && btnSave == "Save") {
                         status = "error";
                     }
                     else {
                         if (btnSave == "Save") {
                             Item_list.push({
                                 'mirDetailId': $(value).find('td:eq(0)').text(), 'mir_id': $(value).find('td:eq(1)').text(), 'ItemId': $(value).find('td input[name=txtItemId]').val(), 'Unit': $(value).find('td:eq(6)').text(), 'StoreStock': $(value).find('td input[name=txtStoreStock]').val(), 'Remarks': $(value).find('input[name=txtRemarks]').val(), 'BatchNum': BatchNum, 'Qty': $(value).find('input[name=txtmirQty]').val(), 'IssueQty': $(value).find('input[name=txtIssueQty]').val(), 'BalanceQty': $(value).find('input[name=txtBlncQty]').val(), 'lastIssueDate': $(value).find('input[name=txtLastIsssueDate]').val(), 'CGS': parseFloat($(value).find('input[name=txtIssueQty]').val() || 0) * parseFloat($(value).find('input[name=txtCGSRate]').val() || 0), 'Department': $(value).find('td:eq(3)').text()
                             });
                         }
                         if (btnSave == "Update") {
                             Item_list.push({
                                 'mirDetailId': $(value).find('td:eq(0)').text(), 'mir_id': $(value).find('td:eq(1)').text(), 'ItemId': $(value).find('td input[name=txtItemId]').val(), 'Unit': $(value).find('td:eq(6)').text(), 'StoreStock': $(value).find('td input[name=txtSaveTimeStock]').val(), 'Remarks': $(value).find('input[name=txtRemarks]').val(), 'BatchNum': BatchNum, 'Qty': $(value).find('input[name=txtmirQty]').val(), 'IssueQty': $(value).find('input[name=txtIssueQty]').val(), 'BalanceQty': $(value).find('input[name=txtBlncQty]').val(), 'lastIssueDate': $(value).find('input[name=txtLastIsssueDate]').val(), 'CGS': $(value).find('input[name=txtCGSAmount]').val(), 'Department': $(value).find('td:eq(3)').text()
                             });
                         }

                     }
                 });
                 if (status == false) {
                     Swal.fire({
                         icon: 'error',
                         title: 'Error!',
                         text: 'Stock store Must Be Greater than 0',
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
                 else if (status == "error") {
                     Swal.fire({
                         icon: 'error',
                         title: 'Error!',
                         text: 'Issue Must Be Greater than 0 OR SIN Qty not greater than MIR Qty',
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
                 else if (status == "errorBatch") {
                     Swal.fire({
                         icon: 'error',
                         title: 'Error!',
                         text: 'Please Enter Batch Number',
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
                 else {
                     if (checkstock == true) {
                         return false;
                     }
                     var AllItemDetail = { 'StoreIssue_id': StoreIssue_id, 'Store_Issue_No': store_no, 'MRNo': MRNo, 'comapny_id': comapny_id, 'department_id': department_id, 'inventory_id': inventory_id, 'ItemList': Item_list };
                     var department_id = $('#ddlDepartment').val();
                     var inventory_id = $('#ddlInventoryOrg').val();
                     var length = $("#tblStoreIssueBote tr:gt(0)").length;
                     if (department_id == '0') $('#ddlDepartment').addClass('ErrorAlert'); else $('#ddlDepartment').removeClass('ErrorAlert');
                     if (inventory_id == '0') $('#ddlInventoryOrg').addClass('ErrorAlert'); else $('#ddlInventoryOrg').removeClass('ErrorAlert');
                     if (length == "0") $('#tblStoreIssueBote').addClass('ErrorAlert'); else $('#tblStoreIssueBote').removeClass('ErrorAlert');
                     if (!$('#ddlDepartment').hasClass('ErrorAlert') && !$('#ddlInventoryOrg').hasClass('ErrorAlert') && !$('#ddlInventoryOrg').hasClass('ErrorAlert') && !$('#tblStoreIssueBote').hasClass('ErrorAlert')) {
                         $(this).attr('disabled', true);
                         PageMethods.Save(btnSave, JSON.stringify(AllItemDetail), function (res) {
                             sendFile(res);
                             Swal.fire({
                                 icon: 'success',
                                 title: 'Success!',
                                 text: 'Data Save Successfully.',
                                 showConfirmButton: false,
                                 timer: 2500,
                                 customClass: {
                                     popup: 'swal-big-popup',
                                     title: 'swal-big-title',
                                     htmlContainer: 'swal-big-text'
                                 }
                             });
                              $('#btnSave').val("Update");
                             window.location = "GoodsIssuanceNote.aspx?SI_ID=" + res;
                             $('#btnSave').val("Update");
                         });
                     }
                 }
             });--%>
        });

        var warehouseCond;
        function GetWareHouseCondition() {
            $.ajax({
                type: "POST",
                url: "GoodsIssuanceNote.aspx/GetWareHouseCondition",
                data: JSON.stringify({}),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    warehouseCond = JSON.parse(response.d);
                    if (warehouseCond == '01') {
                        getMIR();
                    } else if (warehouseCond == '02') {
                        getMIRAll();
                    } else {
                        getMIRAll();
                    }
                },
                error: function (error) {
                    console.error("Error fetching items", error);
                }
            });
        }

        function getMIRAll() {
            $.ajax({
                type: "POST",
                url: "GoodsIssuanceNote.aspx/getMIRAll",
                data: JSON.stringify({}),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var parsed_Date = JSON.parse(response.d);
                    var options = '<option value="0">Select</option>';
                    $(parsed_Date).each(function (key, index) {
                        var mirNo = parsed_Date[key].MIR_No;
                        var deptName = parsed_Date[key].DeptName || '';
                        var displayText = mirNo;
                        if (deptName) {
                            displayText += " (" + deptName + ")";
                        }
                        options += '<option value=' + parsed_Date[key].MIR + '>' + displayText + '</option>';
                    });
                    $("#ddlMIR").html(options);
                    $('#ddlMIR').select2();
                },
                failure: function (response) {
                    alert("In failure method");
                }
            });
        }
        function SaveGIN() {
            var checkstock = false;
            var status;
            var btnSave = $('#btnSave').val();
            var table = $('#tblStoreIssueBote');
            var comapny_id = '0';
            var department_id = $('#ddlDepartment').val();
            var inventory_id = $('#ddlInventoryOrg').val();
            var store_no = $('#txtStoreissueNo').val();
            var MRNo = $('#ddlMRNo').val() || 0;
            var StoreIssue_id = '0';
            var SI_ID = '<%= Request.QueryString["SI_ID"]%>';
            if (SI_ID != "") {
                StoreIssue_id = SI_ID;
            }
            else {
                StoreIssue_id = '0';
            }
            var Item_list = [];
            table.find('tr:gt(0)').each(function (key, value) {
                var StoreStock = $(value).find('td input[name=txtStoreStock]').val();
                var IssueQty = $(value).find('td input[name=txtIssueQty]').val();
                var MIRQty = $(value).find('td input[name=txtmirQty]').val();
                var Batch = $(value).find('td input[name=txtBatch]').val();
                var BatchNum = $(value).find('td select[name=ddlBatchNum]').val();
                var lastIssueDate = $(value).find('td input[name=txtLastIsssueDate]').val();

                if ((parseFloat(IssueQty) > parseFloat(StoreStock)) && btnSave == "Save") {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Issue Qty Must Be Less Than Total Stock',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });



                    checkstock = true;
                    return false;
                }
                if (btnSave == "Update") {
                    var txtSaveTimeStock = $(value).find('td input[name=txtSaveTimeStock]').val();
                    if (parseFloat(IssueQty) > parseFloat(txtSaveTimeStock)) {
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'Issue Qty Must Be Less Than Total Stock',
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
                if (Batch == "true") {
                    if (BatchNum == "0" || BatchNum == "") {
                        status = "errorBatch";
                    }
                }
                if ((StoreStock == "" || StoreStock == 0 || StoreStock < 0) && btnSave == "Save") {
                    status = false;
                }
              
                else if (((IssueQty == "" || IssueQty == 0 || IssueQty < 0) || (parseInt(MIRQty) != 0 && parseInt(MIRQty) < parseInt(IssueQty))) && btnSave == "Save" && isClose == false) {
                    status = "error"; 
                    
                }
                else {
                    if (btnSave == "Save") {
                        Item_list.push({
                            'mirDetailId': $(value).find('td:eq(0)').text(), 'mir_id': $(value).find('td:eq(1)').text(), 'ItemId': $(value).find('td input[name=txtItemId]').val(), 'Unit': $(value).find('td:eq(6)').text(), 'StoreStock': $(value).find('td input[name=txtStoreStock]').val(), 'Remarks': $(value).find('input[name=txtRemarks]').val(), 'BatchNum': BatchNum, 'Qty': $(value).find('input[name=txtmirQty]').val(), 'IssueQty': $(value).find('input[name=txtIssueQty]').val(), 'BalanceQty': $(value).find('input[name=txtBlncQty]').val(), 'lastIssueDate': $(value).find('input[name=txtLastIsssueDate]').val(), 'CGS': parseFloat($(value).find('input[name=txtIssueQty]').val() || 0) * parseFloat($(value).find('input[name=txtCGSRate]').val() || 0), 'Department': $(value).find('td:eq(3)').text()
                        });
                    }
                    if (btnSave == "Update") {
                        Item_list.push({
                            'mirDetailId': $(value).find('td:eq(0)').text(), 'mir_id': $(value).find('td:eq(1)').text(), 'ItemId': $(value).find('td input[name=txtItemId]').val(), 'Unit': $(value).find('td:eq(6)').text(), 'StoreStock': $(value).find('td input[name=txtSaveTimeStock]').val(), 'Remarks': $(value).find('input[name=txtRemarks]').val(), 'BatchNum': BatchNum, 'Qty': $(value).find('input[name=txtmirQty]').val(), 'IssueQty': $(value).find('input[name=txtIssueQty]').val(), 'BalanceQty': $(value).find('input[name=txtBlncQty]').val(), 'lastIssueDate': $(value).find('input[name=txtLastIsssueDate]').val(), 'CGS': $(value).find('input[name=txtCGSAmount]').val(), 'Department': $(value).find('td:eq(3)').text()
                        });
                    }

                }
            });
            if (status == false) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Stock store Must Be Greater than 0',
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
            else if (status == "error") {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Issue Must Be Greater than 0 OR SIN Qty not greater than MIR Qty',
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
            else if (status == "errorBatch") {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Enter Batch Number',
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
            else {
                if (checkstock == true) {
                    return false;
                }
                var Branch = $('#ddlBranch').val();
                var AllItemDetail = { 'StoreIssue_id': StoreIssue_id, 'Store_Issue_No': store_no, 'MRNo': MRNo, 'comapny_id': comapny_id, 'department_id': department_id, 'inventory_id': inventory_id, 'Branch': Branch, 'ItemList': Item_list };
                var department_id = $('#ddlDepartment').val();
                var inventory_id = $('#ddlInventoryOrg').val();
                var length = $("#tblStoreIssueBote tr:gt(0)").length;
                if (department_id == '0') $('#ddlDepartment').addClass('ErrorAlert'); else $('#ddlDepartment').removeClass('ErrorAlert');
                if (inventory_id == '0') $('#ddlInventoryOrg').addClass('ErrorAlert'); else $('#ddlInventoryOrg').removeClass('ErrorAlert');
                if (length == "0") $('#tblStoreIssueBote').addClass('ErrorAlert'); else $('#tblStoreIssueBote').removeClass('ErrorAlert');
                if (!$('#ddlDepartment').hasClass('ErrorAlert') && !$('#ddlInventoryOrg').hasClass('ErrorAlert') && !$('#ddlInventoryOrg').hasClass('ErrorAlert') && !$('#tblStoreIssueBote').hasClass('ErrorAlert')) {
                    $(this).attr('disabled', true);
                    PageMethods.Save(btnSave, JSON.stringify(AllItemDetail), function (res) {
                        sendFile(res, function () {
                            Swal.fire({
                                icon: 'success',
                                title: 'Success!',
                                text: 'Data Save Successfully.',
                                showConfirmButton: false,
                                timer: 2500,
                                customClass: {
                                    popup: 'swal-big-popup',
                                    title: 'swal-big-title',
                                    htmlContainer: 'swal-big-text'
                                }
                            });
                            $('#btnSave').val("Update");
                            window.location = "GoodsIssuanceNote.aspx?SI_ID=" + res;
                            $('#btnSave').val("Update");
                        });
                    });
                }
            }
        }

        function closeGIR() {
            var GIR = $('#ddlMIR').val();
            if (!GIR || GIR === "0") {
                Swal.fire({
                    icon: 'warning',
                    title: 'Warning!',
                    text: 'Please select a GIR first.',
                    showConfirmButton: true,
                    timer: 2000
                });
                return false;
            }
            var remarks = '';
            $.ajax({
                type: "POST",
                url: "GoodsIssuanceNote.aspx/CloseGIR",
                data: JSON.stringify({ 'GIR': GIR, 'remarks': remarks }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response.d == "success") {
                        $('#remarksModal').modal('hide');
                        Swal.fire({
                            icon: 'success',
                            title: 'Success!',
                            text: 'GIR Closed Successfully.',
                            showConfirmButton: false,
                            timer: 2000,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });
                    } else {
                        $('#remarksModal').modal('hide');
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'There is some issue closing this GIR.',
                            showConfirmButton: false,
                            timer: 2000,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });
                    }
                },

                error: function (xhr, status, error) {
                    console.error("Error closing GIR:", error);
                    console.error("Response:", xhr.responseText);
                    $('#remarksModal').modal('hide');
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Server Error: ' + (xhr.responseText || 'Please try again later.'),
                        showConfirmButton: true
                    });
                },
            });
        }
        var isClose = false;
        function SaveAndClose() {

            isClose = true;
            closeGIR();
            SaveGIN();

            
        }
        function UserRights() {
            $.ajax({
                type: "POST",
                url: "GoodsIssuanceNote.aspx/UserEntryRights",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var hasRights = response.d;
                    if (hasRights) {
                        $('#btnSave').show();
                    } else {
                        $('#btnSave').hide();
                    }
                },
                failure: function (response) {
                    alert("Failed to retrieve user rights.");
                }
            });
        }

        function GetNewSINNo() {
            PageMethods.GetNewSINNo(function (resp) {
                $('#txtStoreissueNo').val(resp);
            },
                function (error) {
                    alert(error.get_message());
                })
        }
        function CloseGIRs() {
            // Clear previous remarks
            $('#remarks').val('');

            // Show the modal
            $('#remarksModal').modal('show');
        }

       
        function LoadDepartments() {
            PageMethods.LoadDepartments(function (res) {
                var parsed_Date = JSON.parse(res);
                var option = '<option value="0"> Please Select </option>';
                $(parsed_Date).each(function (key, index) {
                    option += '<option value=' + parsed_Date[key].DataValueName + '>' + parsed_Date[key].DataValueDescription + '</option>'
                });
                $('#ddlDepartment').html(option);
                $('#ddlDepartment').select2();
                $('#ddlDepartment').addClass('readonly');
            });
        }
        function LoadOrganizations() {
            PageMethods.LoadOrganizations(function (res) {
                var parsed_Date = JSON.parse(res);
                var option = '<option value="0"> Please Select </option>';
                $(parsed_Date).each(function (key, index) {
                    option += '<option value=' + parsed_Date[key].DataValueName + '>' + parsed_Date[key].DataValueDescription + '</option>'
                });
                $('#ddlInventoryOrg').html(option);
                $('#ddlInventoryOrg').select2();
                $('#ddlInventoryOrg').addClass('readonly');
            });
        }
        function getbatchsAgainstItem(itemcode, length, onDone) {
            PageMethods.Getbatchs(itemcode, function (data) {
                var parsedData = JSON.parse(data);
                var options = '<option value="0">Please Select</option>';
                var batchCount = 0;
                $.each(parsedData.GRN_Details, function (key, value) {
                    if (value.BatchNum !== '') {
                        options += '<option value="' + value.BatchNum + '">' + value.BatchNum + '</option>';
                        batchCount++;
                    }
                });
                $.each(parsedData.Stock_Adjustment_Details, function (key, value) {
                    if (value.BatchNum !== '') {
                        options += '<option value="' + value.BatchNum + '">' + value.BatchNum + '</option>';
                        batchCount++;
                    }
                });

                if (batchCount === 0) {
                    options += '<option value="">No Batch</option>';
                }
                $('#ddlBatchNum' + length).html(options);
                $('#ddlBatchNum' + length).select2();
                if (onDone) { onDone(); }
            }, function (error) {
                alert(error.get_message());
            });
        }

        function LoadAllitem(searchText) {
            var selectedWarehouse = $('#ddlInventoryOrg').val();

            if (!selectedWarehouse || selectedWarehouse == '0') {
                Swal.fire({
                    icon: 'warning',
                    title: 'Warning!',
                    text: 'Please select a warehouse first',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });
                return;
            }

            $.ajax({
                type: "POST",
                url: "GoodsIssuanceNote.aspx/GetAllitem",
                data: JSON.stringify({
                    searchText: searchText,
                    warehouseId: selectedWarehouse
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var items = JSON.parse(response.d);
                    var tableBody = $('#itemsTableBody');
                    tableBody.empty();

                    if (items.length === 0) {
                        tableBody.append('<tr><td colspan="5" class="text-center">No items found for this warehouse</td></tr>');
                    } else {
                        $.each(items, function (index, item) {
                            var row = '<tr>' +
                                '<td><input type="checkbox" class="itemCheckbox" onclick="appendSearchItem(this)"></td>' +
                                '<td style="display:none;">' + item.Item_ID + '</td>' +
                                '<td>' + item.Item_Code + '</td>' +
                                '<td>' + item.Description + '</td>' +
                                '<td>' + item.Unit + '</td>' +
                                '<td style="display:none;">' + (item.Purchase_Rate || 0) + '</td>' +
                                '<td style="display:none;">' + (item.UOM_Qty || 1) + '</td>' +
                                '</tr>';
                            tableBody.append(row);
                        });
                    }
                    $('#itemsModal').modal('show');
                },
                error: function (error) {
                    console.error("Error fetching items", error);
                    Swal.fire({ icon: 'error', title: 'Error', text: 'Failed to load items.' });
                }
            });
        }

        function appendSearchItem(anchor) {
            var row = $(anchor).closest('tr');
            var item_id = $(row).find('td:eq(1)').text().trim();
            var item_code = $(row).find('td:eq(2)').text().trim();
            var item_name = $(row).find('td:eq(3)').text().trim();
            var unit = $(row).find('td:eq(4)').text().trim();
            var rate = $(row).find('td:eq(5)').text().trim() || '0';
            var uom_qty = $(row).find('td:eq(6)').text().trim() || '1';        
            var isChecked = $(anchor).prop('checked');

            if (!isChecked) {
                $('#tblStoreIssueBote tbody tr').each(function () {
                    if ($(this).find('input[name=txtItemCode]').val() === item_code) {
                        $(this).remove();
                    }
                });
                return;
            }

            var test_array = $('#tblStoreIssueBote').find('input[name=txtItemCode][value=' + item_code + ']');
            if (test_array.length > 0) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'This Item already added',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });
                $(anchor).prop('checked', false);
                return false;
            }

            var length = $("#tblStoreIssueBote tr:gt(0)").length;
            if (length > 0) {
                length = length + 1;
            }
            else {
                length = 1;
            }

            var mir_detail_id = '0';
            var mir_id = '0';
            var department = '';
            var Stock = 0;
            var Qty = 0;
            var balance = 0;
            var CGSRate = 0;
            var IsBatch = 'false';

            if (unit == "null" || unit == null)
                unit = "";
            if (Qty == "null" || Qty == null) {
                Qty = 0;
            }
            if (Stock == null || Stock == 0) {
                Stock = 0;
            }

            getbatchsAgainstItem(item_code, length);
            var rows = '<tr>' +
                '<td style="padding-top: 9px;height: 27px !important;text-align: center;padding-top: 6px !important;">' + mir_detail_id + ' </td>' +
                '<td style="padding-top: 9px;height: 27px !important;text-align: center;padding-top: 6px !important;">' + mir_id + ' </td>' +
                '<td  style="padding-top: 2px;height: 27px !important;"><input type="text" style="  font-size: 10px;width: 75px!important;height: 22px;margin-top: 2px;margin-bottom: 0px;margin-left:4px;" id="txtmirdate' + length + '" name="txtmirdate" value="" disabled/></td>' +
                '<td style="padding-top: 9px;text-align: center;padding-top: 6px !important;"> ' + department + '</td>' +
                '<td  style="padding-top: 9px;text-align: center;padding-top: 6px !important;"> ' + item_code + '<input type="text" name="txtItemCode" value=' + item_code + ' style="display:none;"/></td>' +
                '<td style="padding-top: 9px;text-align: center;padding-top: 6px !important;"> ' + item_name + '</td>' +
                '<td style="padding-top: 9px;text-align: center;padding-top: 6px !important;"> ' + unit + '</td>' +
                '<td><select id="ddlBatchNum' + length + '" name="ddlBatchNum" onChange="CheckBatch(this),GetCGSRate(this)" style="width: 75px !IMPORTANT;" ></select></td>' +
                '<td style="padding-top: 9px;text-align: center;padding-top: 2px !important;"  ><input type="text" id="txtStoreStock' + length + '" name="txtStoreStock" readonly=true value="' + Stock + '" style="height: 22px!important;width: 70px !important;" ></td>' +
                '<td style="padding-top: 2px;"><input type="text" style="font-size: 10px;  width: 64px!important;height: 22px;margin-top: 2px;margin-bottom: 0px;margin-left: 4px;" id="txtmirQty' + length + '" name="txtmirQty" value="' + Qty + '" disabled/></td>' +
                '<td style="paddin g-top: 2px;"><input type="text" style=" font-size: 10px; width: 64px!important;  height: 22px;margin-top: 2px;margin-bottom: 0px;margin-left: 4px;" id="txtIssueQty' + length + '" name="txtIssueQty" value="0"/></td>' +
                '<td style="padding-top: 2px;"> <input disabled type="text" value="0" style=" font-size: 10px;height: 22px;  width: 64px!important;margin-top: 2px;margin-bottom: 0px;margin-left: 4px;" id="txtBlncQty' + length + '" name="txtBlncQty" readonly="readonly"/></td>' +
                '<td style="padding-top: 2px;"> <input disabled type="text" value="" style=" font-size: 10px;height: 22px;  width: 64px!important;margin-top: 2px;margin-bottom: 0px;margin-left: 4px;" id="txtLastIsssueDate' + length + '" name="txtLastIsssueDate" readonly="readonly"/></td>' +
                '<td style="padding-top: 2px;"><input type="text" id="txtRemarks' + length + '" name="txtRemarks" style="width:73px;height: 22px;margin-top: 2px;margin-bottom: 0px;margin-left: 4px;"/> </td>' +
                '<td style="display:none;padding-top: 2px;"><input type="hidden" value=" ' + item_id + '" style=" font-size: 10px;height: 22px;  width: 64px!important;margin-top: 2px;margin-bottom: 0px;margin-left: 4px;" id="txtItemId' + length + '" name="txtItemId"/></td>' +
                '<td style="display:none;padding-top: 2px;"><input type="hidden"  style=" font-size: 10px;height: 22px;  width: 64px!important;margin-top: 2px;margin-bottom: 0px;margin-left: 4px;" id="txtCGSRate' + length + '" name="txtCGSRate" value="' + CGSRate + '"/></td>' +
                '<td style="display:none;padding-top: 2px;"><input type="hidden"  style=" font-size: 10px;height: 22px;  width: 64px!important;margin-top: 2px;margin-bottom: 0px;margin-left: 4px;" id="txtCGSAmount' + length + '" name="txtCGSAmount"/></td>' +
                '<td style="padding-top: 2px;display:none;"><input type="hidden" value="' + IsBatch + '" style=" font-size: 10px;height: 22px;  width: 64px!important;margin-top: 2px;margin-bottom: 0px;margin-left: 4px;" id="txtBatch' + length + '" name="txtBatch"/></td>'
                + '<td style="padding-top: 9px;padding-top: 6px !important;"> <a href="#" onclick="ExcludeFromPayment(this)">Delete</a></td></tr>';
            if ((Qty == 0 || Qty == "0" || Qty == null) &&
                (mir_detail_id && mir_detail_id !== "0")) {
                return false;
            }
            $("#tblStoreIssueBote tbody").append(rows);
            //if ($('#txtBlncQty' + length).val() == 0) {
               // $('#txtIssueQty' + length).prop('disabled', true);
            //}
        }
        function append(anchor) {
            count = 0;
            var rows = '';
            var row = $(anchor).parents('tr')[0];
            var mir_id = $($(row).find('td')[1]).text();
            var item_id = $($(row).find('td')[2]).text();
            var item_name = $($(row).find('td')[3]).text();
            var unit = $($(row).find('td')[6]).text();
            var mir_detail_id = $($(row).find('td')[7]).text();
            var mir_date = $($(row).find('td')[8]).text();
            var txtLastIsssueDate = $($(row).find('td')[14]).text();
            var length = $("#tblStoreIssueBote tr").length;
            var Qty = $($(row).find('td')[4]).text();
            var itemcode = $($(row).find('td')[5]).text();
            var department = $($(row).find('td')[9]).text();
            var IsBatch = $($(row).find('td')[10]).text();
            var Stock = $($(row).find('td')[11]).text();
            var balance = $($(row).find('td')[12]).text();
            var CGSRate = $($(row).find('td')[13]).text();
            var expiryDate = $($(row).find('td')[15]).text();
            if (!expiryDate || expiryDate == "null" || expiryDate === "") {
                expiryDate = '';
            }
            
            else if (expiryDate.indexOf("/Date(") !== -1) {
                expiryDate = $.datepicker.formatDate(
                    'dd M yy',
                    new Date(parseInt(expiryDate.substring(6, 19)))
                );
            }

            if (!txtLastIsssueDate || txtLastIsssueDate == "null") {
                txtLastIsssueDate = '';
            }
            else {
                txtLastIsssueDate = $.datepicker.formatDate(
                    'dd M yy',
                    new Date(parseInt(txtLastIsssueDate.substring(6, 19)))
                );
            }
            

            if (balance == "null" || balance == "") {
                balance = 0
            }
            if (unit == "null")
                unit = "";
            if (Qty == "null") {
                Qty = 0;
            }
            if (Stock == null || Stock == 0) {
                Stock = 0;
            }
            if (IsBatch == "true" || IsBatch == "True") {
                Stock = 0;
            }
            if (IsBatch == "false" || IsBatch == "False") {
              //  $('#ddlBatchNum').attr("disabled", 'disabled');
                //$('#tblStoreIssueBote').find('input[name = ddlBatchNum]').attr("disabled", 'disabled');
            }
            var length = $("#tblStoreIssueBote tr:gt(0)").length;
            if (length > 0) {
                length = length + 1;
            }
            else {
                length = 1;
            }
            var test_array = $('#tblStoreIssueBote').find('input[name=txtItemCode][value=' + itemcode + ']');
            if (test_array.length > 0) {

                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'This Item already added',
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
            else {
                getbatchsAgainstItem(itemcode, length);
                rows = '<tr>' +
                    '<td style="padding-top: 9px;height: 27px !important;text-align: center;padding-top: 6px !important;">' + mir_detail_id + ' </td>' +
                    '<td style="padding-top: 9px;height: 27px !important;text-align: center;padding-top: 6px !important;">' + mir_id + ' </td>' +
                    '<td  style="padding-top: 2px;height: 27px !important;"><input type="text" style="  font-size: 10px;width: 75px!important;height: 22px;margin-top: 2px;margin-bottom: 0px;margin-left:4px;" id="txtmirdate' + length + '" name="txtmirdate" value="' + $.datepicker.formatDate('dd M yy', new Date(parseInt(mir_date.substring(6, 19)))) + '" disabled/></td>' +
                    '<td style="padding-top: 9px;text-align: center;padding-top: 6px !important;"> ' + department + '</td>' +
                    '<td  style="padding-top: 9px;text-align: center;padding-top: 6px !important;"> ' + itemcode + '<input type="text" name="txtItemCode" value=' + itemcode + ' style="display:none;"/></td>' +
                    '<td style="padding-top: 9px;text-align: center;padding-top: 6px !important;"> ' + item_name + '</td>' +
                    '<td style="padding-top: 9px;text-align: center;padding-top: 6px !important;"> ' + unit + '</td>' +
                //'<td><select id="ddlBatchNum' + length + '" name="ddlBatchNum" onChange="CheckBatch(this)" style="width: 75px !IMPORTANT;" ></select></td>' +
                    '<td><select id="ddlBatchNum' + length + '" name="ddlBatchNum" onChange="CheckBatch(this),GetCGSRate(this)" style="width: 75px !IMPORTANT;" ></select></td>' +
                    '<td style="padding-top: 9px;text-align: center;padding-top: 2px !important;"  ><input type="text" id="txtStoreStock' + length + '" name="txtStoreStock" readonly=true value="' + Stock + '" style="height: 22px!important;width: 70px !important;" ></td>' +
                    '<td style="padding-top: 2px;"><input type="text" style="font-size: 10px;  width: 64px!important;height: 22px;margin-top: 2px;margin-bottom: 0px;margin-left: 4px;" id="txtmirQty' + length + '" name="txtmirQty" value="' + Qty + '" disabled/></td>' +
                    '<td style="paddin g-top: 2px;"><input type="text" style=" font-size: 10px; width: 64px!important;                                        height: 22px;margin-top: 2px;margin-bottom: 0px;margin-left: 4px;" id="txtIssueQty' + length + '" name="txtIssueQty" value="0" onkeyup="calculateBalanceQty(this)"/></td>' +
                    '<td style="padding-top: 2px;"> <input type="text" value="' + balance + '" style=" font-size: 10px;height: 22px;  width: 64px!important;margin-top: 2px;margin-bottom: 0px;margin-left: 4px;" id="txtBlncQty' + length + '" name="txtBlncQty" readonly="readonly"/></td>' +
                    '<td style="padding-top: 2px;"> <input type="text" value="' + txtLastIsssueDate + '" style=" font-size: 10px;height: 22px;  width: 64px!important;margin-top: 2px;margin-bottom: 0px;margin-left: 4px;" id="txtLastIsssueDate' + length + '" name="txtLastIsssueDate" readonly="readonly"/></td>' +
                    '<td style="padding-top: 2px;"> <input type="text" value="' + expiryDate + '" style="font-size: 10px;height: 22px; width: 80px!important;margin-top: 2px;margin-bottom: 0px;margin-left: 4px;" id="txtExpiryDate' + length + '" name="txtExpiryDate" readonly="readonly"/></td>' +
                    '<td style="padding-top: 2px;"><input type="text" id="txtRemarks' + length + '" name="txtRemarks" style="width:73px;height: 22px;margin-top: 2px;margin-bottom: 0px;margin-left: 4px;"/> </td>' +
                    
                    '<td style="display:none;padding-top: 2px;"><input type="hidden" value=" ' + item_id + '" style=" font-size: 10px;height: 22px;  width: 64px!important;margin-top: 2px;margin-bottom: 0px;margin-left: 4px;" id="txtItemId' + length + '" name="txtItemId"/></td>' +
                    '<td style="display:none;padding-top: 2px;"><input type="hidden"  style=" font-size: 10px;height: 22px;  width: 64px!important;margin-top: 2px;margin-bottom: 0px;margin-left: 4px;" id="txtCGSRate' + length + '" name="txtCGSRate" value="' + CGSRate +'"/></td>' +
                    '<td style="display:none;padding-top: 2px;"><input type="hidden"  style=" font-size: 10px;height: 22px;  width: 64px!important;margin-top: 2px;margin-bottom: 0px;margin-left: 4px;" id="txtCGSAmount' + length + '" name="txtCGSAmount"/></td>' +
                    '<td style="padding-top: 2px;display:none;"><input type="hidden" value="' + IsBatch + '" style=" font-size: 10px;height: 22px;  width: 64px!important;margin-top: 2px;margin-bottom: 0px;margin-left: 4px;" id="txtBatch' + length + '" name="txtBatch"/></td>'
                    + '<td style="padding-top: 9px;padding-top: 6px !important;"> <a href="#" onclick="ExcludeFromPayment(this)">Delete</a></td></tr>';

                var balanceQty = parseFloat(balance) || 0;
                if (balanceQty <= 0) {
                    return false; 
                }

                $("#tblStoreIssueBote tbody").append(rows);
                //if ($('#txtBlncQty' + length).val() == 0) {
                   // $('#txtIssueQty' + length).prop('disabled', true);
               // }
                length++;
            }
        }
        var departmentid = '';
        var warehouseid = '';
        function LoadMIRDetail(MIR_id) {
            PageMethods.getStoreIssueByID(MIR_id, function (data) {
                var parsed_Date = JSON.parse(data);
                departmentid = parsed_Date[0].Department;
                warehouseid = parsed_Date[0].InventoryOrganization;
                $('#ddlDepartment').val(parsed_Date[0].DepartmentId).trigger('change');
                $('#ddlDepartment').attr('disabled', true);
                $('#ddlInventoryOrg').val(parsed_Date[0].InventoryOrganizationId).trigger('change');
                $("#ddlInventoryOrg").attr('disabled', true);
                $('#tblMIRItemstModelTable tbody tr').remove();
                var rows = "";
                for (var i = 0; i < parsed_Date.length; i++) {
                    var expDate = parsed_Date[i].ExpiryDate ? parsed_Date[i].ExpiryDate : "";
                    rows =
                        '<tr>' +
                        '<td><input class="chktd" id="chktd" name="chktd" type="checkbox" style=" margin-top: -2px; margin-left: 1px;" onclick="append(this)"/></td>' +
                        '<td style="display:none;">' + parsed_Date[i].MaterialRequest_Id + '</td>' +
                        '<td style="display:none;">' + parsed_Date[i].Item_Id + '</td>' +
                        '<td>' + parsed_Date[i].Description + '</td>' +
                        '<td style="display:none;">' + parseFloat(parsed_Date[i].MIRQty).toFixed(2) + '</td>' +
                        '<td style="display:none;">' + parsed_Date[i].Item_Code + '</td>' +
                        '<td style="display:none;">' + parsed_Date[i].Unit + '</td>' +
                        '<td style="display:none;">' + parsed_Date[i].MaterialRequestDetail_Id + '</td>' +
                        '<td style="display:none;">' + parsed_Date[i].MIRDate + '</td>' +
                        '<td style="display:none;">' + parsed_Date[i].Department + '</td>' +
                        '<td style="display:none;">' + parsed_Date[i].IsBatch + '</td>' +
                        '<td style="display:none;">' + parseFloat(parsed_Date[i].Stock).toFixed(2) + '</td>' +
                        '<td style="display:none;">' + parseFloat(parsed_Date[i].Balance).toFixed(2) + '</td>' +
                       /* '<td style="display:none;">' + parseFloat(parsed_Date[i].CGSRate).toFixed(2) + '</td>' +*/
                    '<td style="display:none;">StoreStock</td>' +
                    '<td style="display:none;">' + parsed_Date[i].Last_Issue_date + '</td>' +
                    '<td style="display:none;">' + expDate + '</td>' + 
                        '</tr>';
                    $('#tblMIRItemstModelTable tbody').append(rows);
                }
                $('#POItemsModel').modal({
                    backdrop: 'static'
                });
            });
        }
        function GetCGSRate(anchor) {
            var row = $(anchor).parents('tr')[0];
            var Item_code = $($(row).find('input[name=txtItemCode]')).val();
            var batchNum = $($(row).find('select[name=ddlBatchNum]')).val();
            var invOrg = $('#ddlInventoryOrg').val();
            PageMethods.GetCGSRate(Item_code, batchNum, invOrg, function (res) {
                var parsed_stock = JSON.parse(res);
                if (parsed_stock != "") {
                    $($(row).find('input[name=txtCGSRate]')).val(parseInt(parsed_stock));
                }
                else {
                    $($(row).find('input[name=txtCGSRate]')).val(0);
                }
            });
        }
        function CheckBatch(anchor) {
            var row = $(anchor).parents('tr')[0];
            var Item_code = $($(row).find('input[name=txtItemCode]')).val();
            var batchNum = $($(row).find('select[name=ddlBatchNum]')).val();
            var invOrg = $('#ddlInventoryOrg').val();
            PageMethods.GetStock(Item_code, batchNum, invOrg, function (res) {
                var parsed_stock = JSON.parse(res);
                if (parsed_stock != "") {
                    $($(row).find('input[name=txtStoreStock]')).val(parseInt(parsed_stock));
                }
                else {
                    $($(row).find('input[name=txtStoreStock]')).val(0);
                }
            });
        }
        //function getMIR() {
        //    var warehouse = $("#ddlInventoryOrg").val();
        //    if (warehouse == null || warehouse == undefined) {
        //        warehouse = '0';
        //    }
        //    $.ajax({
        //        type: "POST",
        //        url: "GoodsIssuanceNote.aspx/getMIR",
        //        data: JSON.stringify({ warehouse: warehouse }), // <-- pass parameter here
        //        contentType: "application/json; charset=utf-8",
        //        dataType: "json",
        //        success: function (response) {
        //            var parsed_Date = JSON.parse(response.d);
        //            var options = '<option value="0">Select</option>';
        //            $(parsed_Date).each(function (key, index) {
        //                options += '<option value=' + parsed_Date[key].MIR + '>' + parsed_Date[key].MIR_No + '</option>';
        //            });
        //            $("#ddlMIR").html(options);
        //        },
        //        failure: function (response) {
        //            alert("In failure method");
        //        }
        //    });
        //}

        function getMIR() {
            var warehouse = $("#ddlInventoryOrg").val();
            var department = $("#ddlDepartment").val(); 

            if (warehouse == null || warehouse == undefined) {
                warehouse = '0';
            }
            if (department == null || department == undefined) {
                department = '0';
            }

            $.ajax({
                type: "POST",
                url: "GoodsIssuanceNote.aspx/getMIR",
                data: JSON.stringify({
                    warehouse: warehouse,
                    department: department 
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var parsed_Date = JSON.parse(response.d);
                    var options = '<option value="0">Select</option>';

                    $(parsed_Date).each(function (key, index) {
                        var mirNo = parsed_Date[key].MIR_No;
                        var deptName = parsed_Date[key].DeptName;

                        var displayText = mirNo;
                        if (deptName) {
                            displayText += " (" + deptName + ")";
                        }

                        options += '<option value=' + parsed_Date[key].MIR + '>' + displayText + '</option>';
                    });

                    $("#ddlMIR").html(options);
                    $('#ddlMIR').select2(); 
                },
                failure: function (response) {
                    alert("In failure method");
                }
            });
        }

        function calculateBalanceQty(anchor) {
            var row = $(anchor).parents('tr')[0];
            var Item_qty = $($(row).find('input[name=txtmirQty]')).val();
            var Issue_Qty = $($(row).find('input[name=txtIssueQty]')).val();
            var CGSRate = $($(row).find('input[name=txtCGSRate]')).val();
            var Balance = parseInt(Item_qty) - parseInt(Issue_Qty);
            var cgsAmt = Issue_Qty * CGSRate;
            $($(row).find('input[name=txtBlncQty]')).val(Balance);
            $($(row).find('input[name=txtCGSAmount]')).val(cgsAmt);
        }
        function LoadMaster(SI_ID) {
            PageMethods.LoadMaster(SI_ID, function (res) {
                var result = JSON.parse(res);
                $('#txtStoreissueNo').val(result[0].Store_Issue_No);
                $('#txtStatus').val(result[0].Status);
                savedBranch = result[0].Branch_Id;
                if (savedBranch) {
                    $('#ddlBranch').val(savedBranch).trigger('change');
                }
                var organizationId = result[0].Organization_Id;
                $('#ddlInventoryOrg').val(organizationId).trigger('change');
                $('#ddlInventoryOrg').attr('disabled', 'disabled');
                $('#ddlDepartment').val(result[0].Department_Id).trigger('change');
                $('#ddlDepartment').attr('disabled', 'disabled');



                try {
                    initializeMRNoDropdown(result.query.MR_No);
                    $('#ddlMRNo').val(result.query.MR_No).trigger('change');
                } catch (e) { /* the header result has no 'query' object (as before); this must not stop the loading */ }
                if (window.applyEditStatusUi) { window.applyEditStatusUi(); }
                editLoadDone();
            });
        }
        function ExcludeFromPayment(anchor) {
            var a = confirm("Are you sure You want to delete");
            if (a == true) {
                console.clear();
                var row = $(anchor).parents('tr')[0];
                row.remove();
            }
        }
        function LoadDetail(SI_ID) {
            PageMethods.LoadDetail(SI_ID, function (res) {
                var result = JSON.parse(res);
                selectedOptions = result;
                $(result).each(function (key, value) {

                    

                    if (result[key].BatchNum == null) {
                        result[key].BatchNum = "";
                    }
                    if (result[key].Unit == null) {
                        result[key].Unit = " "
                    }
                    var expiryDate = result[key].ExpiryDate;
                    if (!expiryDate || expiryDate == "null" || expiryDate == "") {
                        expiryDate = '';
                    } else {
                        if (expiryDate.indexOf("/Date(") !== -1) {
                            expiryDate = $.datepicker.formatDate(
                                'dd M yy',
                                new Date(parseInt(expiryDate.substring(6, 19)))
                            );
                        } else {
                            try {
                                var dateObj = new Date(expiryDate);
                                if (!isNaN(dateObj.getTime())) {
                                    expiryDate = $.datepicker.formatDate('dd M yy', dateObj);
                                }
                            } catch (e) {
                                expiryDate = '';
                            }
                        }
                    }
                    var lastissueDate = result[key].Last_issue_date

                    if (!lastissueDate || lastissueDate == "null") {
                        lastissueDate = '';
                    }
                    else {
                        lastissueDate = $.datepicker.formatDate(
                            'dd M yy',
                            new Date(parseInt(lastissueDate.substring(6, 19)))
                        );
                    }
                    $("#mir_id").val(result[key].MIR_Id);

                    var rows = '<tr>' +
                        '<td style="padding-top: 9px;height: 27px !important;text-align: center;padding-top: 6px !important;">' + result[key].MIR_Detail_Id + ' </td>' +
                        '<td style="padding-top: 9px;height: 27px !important;text-align: center;padding-top: 6px !important;">' + result[key].MIR_Id + ' </td>' +
                        '<td  style="padding-top: 2px;height: 27px !important;"><input type="text" style=" font-size: 10px;width: 75px!important;height: 22px;margin-top: 2px;margin-bottom: 0px;margin-left:4px;" id="txtmirdate' + key + '" name="txtmirdate" value="' + result[key].Mir_Date + '" disabled/></td>' +
                        '<td style="padding-top: 9px;text-align: center;padding-top: 6px !important;"> ' + result[key].Department + '</td>' +
                        '<td  style="padding-top: 9px;text-align: center;padding-top: 6px !important;"> ' + result[key].Item_code + '<input type="text" name="txtItemCode" value=' + result[key].Item_code + ' style="display:none;"/></td>' +
                        '<td style="padding-top: 9px;text-align: center;padding-top: 6px !important;"> ' + result[key].Description + '</td>' +
                        '<td style="padding-top: 9px;text-align: center;padding-top: 6px !important;"> ' + result[key].Unit + '</td>' +
                        '<td><select style="width:80px!important;" id="ddlBatchNum' + (key + 1) + '" name="ddlBatchNum" onChange="CheckBatch(this)"></select></td>' +
                        '<td style="text-align: center;padding-top: 0px !important;"  ><input style="width:47px!important;" type="text" id="txtStoreStock' + length + '" name="txtStoreStock" readonly=true value="' + parseFloat(result[key].Store_Stock).toFixed(2) + '"></td>' +
                        '<td style="padding-top: 2px;"><input type="text" style="font-size: 10px;  width: 64px!important;height: 22px;margin-top: 2px;margin-bottom: 0px;margin-left: 4px;" id="txtmirQty' + key + '" name="txtmirQty" value="' + parseFloat(result[key].MIR_Qty).toFixed(2) + '" disabled/></td>' +
                        '<td style="padding-top: 2px;"><input type="text" style="font-size: 10px; width: 64px!important;height: 22px;margin-top: 2px;margin-bottom: 0px;margin-left: 4px;" id="txtIssueQty' + key + '" name="txtIssueQty" value="' + parseFloat(result[key].Issue_Qty).toFixed(2) + '" onkeyup="calculateBalanceQty(this)"/></td>' +
                        '<td style="padding-top: 2px;"> <input type="text" value="' + parseFloat(result[key].Balance_Qty).toFixed(2) + '" style=" font-size: 10px;height: 22px;  width: 64px!important;margin-top: 2px;margin-bottom: 0px;margin-left: 4px;" id="txtBlncQty' + key + '" name="txtBlncQty"/></td>' +
                        '<td style="padding-top: 2px;"> <input type="text" value="' + lastissueDate + '" style=" font-size: 10px;height: 22px;  width: 64px!important;margin-top: 2px;margin-bottom: 0px;margin-left: 4px;" id="txtLastIsssueDate' + key + '" name="txtLastIsssueDate"/></td>' +
                        '<td style="padding-top: 2px;"> <input type="text" value="' + expiryDate + '" style=" font-size: 10px;height: 22px;  width: 80px!important;margin-top: 2px;margin-bottom: 0px;margin-left: 4px;" id="txtExpiryDate' + key + '" name="txtExpiryDate" readonly="readonly"/></td>' +
                        '<td style="padding-top: 2px;"><input type="text" id="txtRemarks' + key + '" style="width:73px;height: 22px;margin-top: 2px;margin-bottom: 0px;margin-left: 4px;" name="txtRemarks" value="' + result[key].Remarks + '"/> </td>' +                     
                        '<td style="display:none;padding-top: 2px;"><input type="hidden" value=" ' + result[key].Item_Id + '" style=" font-size: 10px;height: 22px;  width: 64px!important;margin-top: 2px;margin-bottom: 0px;margin-left: 4px;" id="txtItemId' + length + '" name="txtItemId"/></td>' +
                        '<td style="display:none;padding-top: 2px;"><input type="hidden" value=" ' + result[key].CGS + '" style=" font-size: 10px;height: 22px;  width: 64px!important;margin-top: 2px;margin-bottom: 0px;margin-left: 4px;" id="txtCGSAmount' + length + '" name="txtCGSAmount"/></td>' +
                        '<td style="padding-top: 9px;padding-top: 6px !important;"> <a href="#" onclick="ExcludeFromPayment(this)">Delete</a></td>' +
                        '<td style="display:none;padding-top: 2px;"><input type="hidden" value=" ' + result[key].SaveTimeStock + '" style=" font-size: 10px;height: 22px;  width: 64px!important;margin-top: 2px;margin-bottom: 0px;margin-left: 4px;" id="txtSaveTimeStock' + length + '" name="txtSaveTimeStock"/></td></tr > ';
                    $("#tblStoreIssueBote tbody").append(rows);
                    getbatchsAgainstItem(result[key].Item_code, (key + 1), function () {
                        $('#ddlBatchNum' + (key + 1)).val(result[key].BatchNum).trigger('change');
                    });
                });
                editLoadDone();
            });
        }

       

        function PrintVoucher() {
            var id = '<% =Request.QueryString["SI_ID"] %>';
            var locationInfo = window.location;


            var user_name = '<% =AppConfig.Company_Name %>';
            if (user_name == 'As-Siraat Serving Humanity') {
                reportPath = '../../ReportViewer.aspx';
            } else {
                reportPath = 'ReportViewer.aspx'; // same folder
            }

            var user_name = '<% =AppConfig.Company_Name %>';
            if (user_name == 'National Hospital & Medical Centre') {
                var url = '/ReportViewer.aspx?ReportName=Voucher_GIN&ReportTitle=SIN Voucher&TransID=' + id + '&TransType=SIN';
            } else {
                var url = '/ReportViewer.aspx?ReportName=Voucher&ReportTitle=SIN Voucher&TransID=' + id + '&TransType=SIN';
            }

            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + '/' + reportPath + '?ReportName=Voucher&ReportTitle=SIN Voucher&TransID=' + id + '&TransType=SIN';
            }
            window.open(url, '_blank');
        }
        function btn_Print() {
            var id = '<% =Request.QueryString["SI_ID"] %>';
            var locationInfo = window.location;


            var user_name = '<% =AppConfig.Company_Name %>';
            if (user_name == 'As-Siraat Serving Humanity') {
                reportPath = '../../ReportViewer.aspx';
            } else {
                reportPath = 'ReportViewer.aspx'; // same folder
            }

            var url = '/ReportViewer.aspx?ReportName=StoreIssueBasePrint&ReportTitle=Store Issue Note&SI_ID=' + id;
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + '/' + reportPath +  '?ReportName=StoreIssueBasePrint&ReportTitle=Store Issue Note&SI_ID=' + id;
            }
            window.open(url, '_blank');
        }
        function btn_Print2() {
            var id = '<% =Request.QueryString["SI_ID"] %>';
            var locationInfo = window.location;


            var user_name = '<% =AppConfig.Company_Name %>';
            if (user_name == 'As-Siraat Serving Humanity') {
                reportPath = '../../ReportViewer.aspx';
            } else {
                reportPath = 'ReportViewer.aspx'; // same folder
            }

            var url = '/ReportViewer.aspx?ReportName=StoreIssueBasePrint_Thermal&ReportTitle=Store Issue Note&SI_ID=' + id;
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + '/' + reportPath +  '?ReportName=StoreIssueBasePrint_Thermal&ReportTitle=Store Issue Note&SI_ID=' + id;
            }
            window.open(url, '_blank');
        }
        function sendFile(ID, callback) {
            var fileInput = $('#choseGINfile')[0];
            if (fileInput.files.length > 0) {
                var data = new FormData();
                data.append('file', $('#choseGINfile')[0].files[0]);
                data.append('ID', ID);
                $.ajax({
                    type: 'post',
                    url: '../../upload/UploadGINFiles.ashx',
                    data: data,
                    success: function (status) {
                        if (typeof callback === 'function') callback();
                    },
                    processData: false,
                    contentType: false,
                    error: function () {

                    }
                });
            } else {
                if (typeof callback === 'function') callback();
            }
        }
     

        function UserUnApproveButtonRights() {
            $.ajax({
                type: "POST",
                url: "GoodsIssuanceNote.aspx/UserUnApproveEntryRights",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var hasRights = response.d;
                    if (hasRights) {
                        $('#btnUnApproveToBeHidden').show();
                    } else {
                        $('#btnUnApproveToBeHidden').hide();
                    }
                },
                failure: function (response) {
                    alert("Failed to retrieve User UnApprove Button Rights.");
                }
            });
        }
        function UnApprove() {
            var SINId = '<% =Request.QueryString["SI_ID"] %>';
            PageMethods.UnApproveSIN(SINId, function (Tests) {
                var message = JSON.parse(Tests);
                if (message[0].Column1 != "" || message[0].Column1 != null) {
                    alert(message[0].Column1);
                    location.reload();
                }
            });
        }
        function callPageMethod(methodName, params, successCallback, errorCallback) {
            if (typeof params === 'function') {
                errorCallback = successCallback;
                successCallback = params;
                params = {};
            }
            $.ajax({
                type: "POST",
                url: "GoodsIssuanceNote.aspx/" + methodName,
                data: JSON.stringify(params || {}),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (typeof successCallback === 'function') successCallback(response.d);
                },
                error: function (xhr, status, error) {
                    console.error('Error calling ' + methodName + ':', xhr.status, error);
                    if (typeof errorCallback === 'function') errorCallback(error);
                }
            });
        }
        function CheckGINApprovalRightsAndShowButton(sinId) {
            callPageMethod('CheckGINApprovalRights', function (hasRights) {
                if (hasRights) {
                    callPageMethod('GetGINApprovalInfo', { SINId: sinId }, function (resp) {
                        var info = JSON.parse(resp);
                        if (info.CanApprove) {
                            $('#btnApprove').show();
                        }
                    });
                }
            });
        }
        function ApproveGINFromEdit() {
            var SINId = '<%= Request.QueryString["SI_ID"] %>';
            Swal.fire({
                title: 'Approve GIN?',
                icon: 'question',
                showCancelButton: true,
                confirmButtonText: 'Yes, Approve',
                cancelButtonText: 'Cancel',
                input: 'textarea',
                inputPlaceholder: 'Approval remarks (optional)...',
                customClass: { popup: 'swal-big-popup', title: 'swal-big-title', htmlContainer: 'swal-big-text' }
            }).then((result) => {
                if (result.isConfirmed) {
                    var remarks = result.value || '';
                    callPageMethod('ApproveSingleGIN', { SINId: SINId, approvalRemarks: remarks }, function (resp) {
                        if (resp === "Success") {
                            Swal.fire({ icon: 'success', title: 'Approved!', text: 'GIN has been approved successfully.', showConfirmButton: false, timer: 2000, customClass: { popup: 'swal-big-popup', title: 'swal-big-title', htmlContainer: 'swal-big-text' } }).then(function () { location.reload(); });
                        } else {
                            Swal.fire({ icon: 'error', title: 'Error', text: resp, showConfirmButton: true, customClass: { popup: 'swal-big-popup', title: 'swal-big-title', htmlContainer: 'swal-big-text' } }).then(function () { location.reload(); });
                        }
                    });
                }
            });
        }

        function initializeMRNoDropdown(savedMRNo = null) {
            $('#ddlMRNo').select2({
                placeholder: "Please Select",
                allowClear: true,
                ajax: {
                    url: "GoodsIssuanceNote.aspx/LoadMRNo",
                    type: "POST",
                    contentType: "application/json; charset=utf-8",
                    data: function (params) {
                        return JSON.stringify({
                            savedMRNo: savedMRNo,
                            search: params.term || ""
                        });
                    },
                    processResults: function (response) {
                        const parsedData = JSON.parse(response.d);
                        return {
                            results: parsedData.map(item => ({
                                id: item.mr_no_sequence,
                                text: item.mr_no_sequence
                            }))
                        };
                    },
                    error: function (xhr, status, error) {
                        console.error("Error:", error);
                    }
                }
            });
            if (savedMRNo) {
                const option = new Option(savedMRNo, savedMRNo, true, true);
                $('#ddlMRNo').append(option).trigger('change');
            }
        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="gn-page">

        <!-- Title line: the master page puts the page title in the empty left side; the badges sit on the right -->
        <div class="pr-meta-bar">
            <div class="meta-left"></div>
            <div class="meta-right">
                <div class="gn-badge"><span class="gn-badge-label">Issue No</span><span class="gn-badge-value" id="badgeGinNo">---</span></div>
                <div class="gn-badge"><span class="gn-badge-label">Department</span><span class="gn-badge-value" id="badgeGinDept">---</span></div>
                <div class="gn-badge"><span class="gn-badge-label">Warehouse</span><span class="gn-badge-value" id="badgeGinWarehouse">---</span></div>
                <div class="gn-badge"><span class="gn-badge-label">Status</span><span class="gn-badge-value" id="badgeGinStatus">---</span></div>
            </div>
        </div>

        <div class="gn-layout">

            <!-- Left: issue details + attachment -->
            <div class="gn-col">
                <section class="gn-card">
                    <h5 class="gn-card-title"><i class="fa fa-truck"></i> Issue Details</h5>
                    <input type="hidden" id="hdiemID" />
                    <input type="hidden" id="mir_id" />
                    <div class="gn-grid">
                        <div class="gn-field">
                            <label for="txtStoreissueNo">Store issue no</label>
                            <input type="text" readonly="readonly" id="txtStoreissueNo" class="form-control" name="txtStoreissueNo" value="New" />
                        </div>
                        <div class="gn-field">
                            <label for="ddlDepartment">Department</label>
                            <select id="ddlDepartment" class="form-control">
                            </select>
                        </div>
                        <div class="gn-field">
                            <label for="ddlInventoryOrg">Warehouse</label>
                            <select id="ddlInventoryOrg" class="form-control">
                            </select>
                        </div>
                        <div class="gn-field">
                            <label for="ddlBranch">Branch</label>
                            <select id="ddlBranch" class="form-control"></select>
                        </div>
                        <div class="gn-field">
                            <label for="ddlMRNo">MR #</label>
                            <select id="ddlMRNo" class="form-control">
                            </select>
                        </div>
                        <div class="gn-field">
                            <label for="ddlMIR">GIR#</label>
                            <select id="ddlMIR" class="form-control"></select>
                        </div>
                        <div class="gn-field">
                            <label>&nbsp;</label>
                            <div class="gn-btnrow">
                                <input type="button" value="Add" id="btnAdd" class="btn btn-primry" />
                                <input type="button" value="Items" id="btnGetAllItems" class="btn btn-gray" />
                            </div>
                        </div>
                    </div>
                </section>

                <section class="gn-card">
                    <h5 class="gn-card-title"><i class="fa fa-paperclip"></i> Attachment</h5>
                    <div class="gn-grid">
                        <div class="gn-field gn-span-2">
                            <label for="choseGINfile">Attachment</label>
                            <input type="file" id="choseGINfile" name="choseGINfile" class="form-control" />
                            <asp:HyperLink ID="HyperLink1" runat="server" CssClass="gn-link">Download</asp:HyperLink>
                        </div>
                    </div>
                </section>
            </div>

            <!-- Right: status -->
            <div class="gn-col">
                <section class="gn-card">
                    <h5 class="gn-card-title"><i class="fa fa-check-square-o"></i> Status</h5>
                    <div class="gn-grid" style="grid-template-columns: minmax(0, 1fr);">
                        <div class="gn-field">
                            <label for="txtStatus">Status</label>
                            <input type="text" id="txtStatus" class="form-control" name="txtStatus" readonly="readonly" />
                        </div>
                    </div>
                </section>
            </div>
        </div>

        <!-- Items -->
        <section class="gn-card">
            <h5 class="gn-card-title"><i class="fa fa-list-alt"></i> Items</h5>
            <div class="gn-table-wrap">
                <table class="table table-hover gn-table" id="tblStoreIssueBote">
                    <thead>
                        <tr>
                            <th>Request #</th>
                            <th>GIR #</th>
                            <th>GIR App Date</th>
                            <th>Department</th>
                            <th>Item Code</th>
                            <th>Item Description</th>
                            <th>UOM</th>
                            <th>Batch Num</th>
                            <th>Store Stock</th>
                            <th>GIR Qty</th>
                            <th>Issue Qty</th>
                            <th>Balance Qty</th>
                            <th>Last Issue Date</th>
                            <th>Expiry Date</th>
                            <th>Remarks</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                    </tbody>
                </table>
            </div>
        </section>

        <!-- Actions -->
        <div class="row">
            <div class="col-lg-8">
                <div class="row">
                    <div class="col-lg-2 col-md-4 col-sm-6" id="divSaveandClose">
                        <input type="button" class="btn btn-primry" id="btnSaveClose" value="Save & Close" onclick="SaveAndClose();" />
                        &nbsp;
                    </div>
                    <div class="col-lg-2 col-md-4 col-sm-6">
                        <input type="button" class="btn btn-primry" id="btnSave" value="Save" onclick="SaveGIN();" />
                        &nbsp;
                    </div>
                    <div class="col-lg-2 col-md-4 col-sm-6">
                        <input type="button" name="" value="Print" class="btn btn-primry" onclick="btn_Print()" />
                    </div>
                    <div class="col-lg-2 col-md-4 col-sm-6">
                        <input type="button" name="" value="Print2" class="btn btn-primry" onclick="btn_Print2()" />
                    </div>
                    <div class="col-lg-2 col-md-4 col-sm-6">
                        <input type="button" class="btn-gray" value="List" onclick="window.location = 'GoodsIssuanceNoteView.aspx'" />
                        &nbsp;
                    </div>
                    <div class="col-lg-2 col-md-4 col-sm-6">
                        <input type="button" class="btn btn-yellow" value="New" onclick="window.location = 'GoodsIssuanceNote.aspx'" />
                        &nbsp;
                    </div>
                    <div class="col-lg-2 col-md-4 col-sm-6">
                        <input type="button" class="btn btn-primry" value="Voucher" id="btnVoucher" onclick="PrintVoucher()" />
                    </div>
                    <div class="col-lg-2 col-md-4 col-sm-6">
                        <input type="button" style="display: none;" class="btn btn-primry" value="Approve" id="btnApprove" onclick="ApproveGINFromEdit()" />
                    </div>
                    <div class="col-lg-2 col-md-4 col-sm-6" id="btnUnApproveToBeHidden" style="display: none">
                        <input type="button" class="btn btn-primry" value="UnApprove" id="btnUnApprove" onclick="UnApprove()" />
                    </div>
                    <div class="col-lg-2 col-md-4 col-sm-6" id="isCloseGIR">
                        <input type="button" class="btn btn-primry" value="Close GIR" id="CloseGIR" onclick="CloseGIRs()" />
                    </div>
                </div>
            </div>
        </div>

        <!-- Add MIR items picker -->
        <div id="POItemsModel" class="modal fade gn-modal" role="dialog">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">&times;</button>
                        <h4 class="modal-title">Add MIR Items</h4>
                    </div>
                    <input type="hidden" id="txthiddentr" name="txthidddentr" />
                    <div class="gn-modal-scroll">
                        <table class="table" id="tblMIRItemstModelTable">
                            <thead>
                                <tr>
                                    <th style="width: 32px;">
                                        <input type="checkbox" id="checkHeader" value="false" /></th>
                                    <th style="display: none;">MIR ID </th>
                                    <th style="display: none;">Item ID</th>
                                    <th>Item Name</th>
                                    <th style="display: none;"></th>
                                    <th style="display: none;"></th>
                                    <th style="display: none;"></th>
                                </tr>
                            </thead>
                            <tbody>
                            </tbody>
                        </table>
                    </div>
                    <div class="modal-footer">
                        <input class="btn-gray" type="button" id="PoItem" name="PoItem" value="Done" data-dismiss="modal" style="width: 20% !important; margin-left: 79%" />
                    </div>
                </div>
            </div>
        </div>

        <!-- Item search picker -->
        <div class="modal fade gn-modal" id="itemsModal" tabindex="-1" aria-labelledby="itemsModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                        <h4 class="modal-title" id="itemsModalLabel">Item Details</h4>
                    </div>
                    <div class="modal-body">
                        <div class="gn-modal-search">
                            <i class="fa fa-search"></i>
                            <input type="text" id="searchInput" class="form-control search-input" placeholder="Search items..." autocomplete="off" />
                        </div>
                        <div class="gn-modal-scroll">
                            <table class="table">
                                <thead>
                                    <tr>
                                        <th>Select</th>
                                        <th style="display: none;">Item ID</th>
                                        <th>Item Code</th>
                                        <th>Description</th>
                                        <th>Unit</th>
                                        <th style="display: none;">Rate</th>
                                        <th style="display: none;">UOM Qty</th>
                                    </tr>
                                </thead>
                                <tbody id="itemsTableBody">
                                </tbody>
                            </table>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <div class="col-lg-10 col-md-10 col-sm-10"></div>
                        <div class="col-lg-2 col-md-2 col-sm-2 float-end">
                            <input type="button" value="Close" class="btn-gray" data-dismiss="modal" />
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Close GIR remarks -->
        <div class="modal fade gn-modal" id="remarksModal" tabindex="-1" role="dialog" aria-labelledby="remarksModalLabel" aria-hidden="true">
            <div class="modal-dialog" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                        <h5 class="modal-title" id="remarksModalLabel">Close GIR</h5>
                    </div>
                    <div class="modal-body gn-modal-pad">
                        <div class="form-group">
                            <label for="remarks">Remarks <span class="text-danger">*</span></label>
                            <textarea class="form-control" id="remarks" rows="4" placeholder="Enter closing remarks..."></textarea>
                            <small class="form-text text-muted">Please provide reason for closing this GIR</small>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                        <button type="button" class="btn btn-primary" id="confirmCloseBtn">Confirm Close</button>
                    </div>
                </div>
            </div>
        </div>

    </div>

    <script type="text/javascript">
        // title-line badges follow the form fields (the page script fills them in after loading)
        function ginSelText(sel) { var t = $(sel + ' option:selected').text(); return (t && t.indexOf('Please Select') < 0 && t.indexOf('Select') !== 0) ? t : '---'; }
        function syncGinBadges() {
            $('#badgeGinNo').text($('#txtStoreissueNo').val() || '---');
            $('#badgeGinDept').text(ginSelText('#ddlDepartment'));
            $('#badgeGinWarehouse').text(ginSelText('#ddlInventoryOrg'));
            $('#badgeGinStatus').text($('#txtStatus').val() || '---');
        }
        $(function () {
            syncGinBadges();
            setInterval(syncGinBadges, 600);
        });
    </script>
</asp:Content>
