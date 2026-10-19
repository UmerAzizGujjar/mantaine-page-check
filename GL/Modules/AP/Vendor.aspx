<%@ Page EnableSessionState="ReadOnly" Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Vendor.aspx.cs" Inherits="PMS.Vendor" Theme="Default_Theme" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/vendor.css" rel="stylesheet" />
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/custom-modals.css" rel="stylesheet" />

    <script type="text/javascript">
        var selectedOptions = '';
        $(document).ready(function () {
            $("#ddlPayabl").prop("disabled", true);

            $("#chkmanual").change(function () {
                if (this.checked) {
                    $('#ddlPayabl').prop("disabled", false);
                } else {
                    $('#ddlPayabl').val(0).prop("disabled", true);
                }
            });
            MaskedInput({
                elm: document.getElementById('txtCnic'),
                format: '_____-_______-_',
                separator: '-'
            });
            MaskedInput({
                elm: document.getElementById('txtMobno'),
                format: '+92__________',
                separator: '+92 -'
            });
            $('#ctl00_lbl1').text('Supplier');
            $('select').select2();
            GetNewVendorNo();
            FillDropDownList();
            var VenId = '<%= Request.QueryString["ID"]%>';
            
            if (VenId != "") {
                $('#btnSave').val('Update');
                $('#txtVendorId').val(VenId);
                // Load Payable Code dropdown first, then load vendor data so Account_ID can be selected
                loadPayableCode(function () {
                    LoadVendorDetail(VenId);
                });
            }
            else {
                loadPayableCode();
                loadnewaccountToCreate();
                $("#Active").prop('checked', true);
                setTimeout(function() { $('#Active').trigger('change'); }, 100);
            }
            $('#manufacturerDropdown').on('change', function () {
                var val = $(this).val();
                if (val !== '0' && val !== '') {
                    $(this).prop('disabled', true);
                } else {
                    $(this).prop('disabled', false);
                }
           
            });
            $('#btnGetAllItems').on('click', function () {
                LoadAllitem('');
            });

            $('#searchInput').on('keyup', function () {
                var searchText = $(this).val().trim();
                LoadAllitem(searchText);
            });
            FillCompany();
        })
        var id = '<% =Request.QueryString["ID"] %>';
        function printPerson() {
            var locationInfo = window.location;
            var url = '/ReportViewer.aspx?ReportName=VendorPerson&ReportTitle=Vendor Person&ID=' + id;
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + '../../ReportViewer.aspx?ReportName=VendorPerson&ReportTitle=Vendor Person&ID=' + id;
            }
            window.open(url, '_blank');
        }
        function loadnewaccountToCreate() {

            PageMethods.LoadNewAccountToCreate(function (data) {
                var NewAccountData = JSON.parse(data);

                $("#hdfParent_Code").val(NewAccountData.NewhdfParent_Code);
                $("#hdfAccount_Code").val(NewAccountData.NewhdfAccount_Code);
                $("#hdfAccount_Serial").val(NewAccountData.NewhdfAccount_Serial);
                $("#hdfLevel").val(NewAccountData.NewhdfLevel);
            }
                , function (err) {
                    alert("Error: " + err.get_message());
                });
        }
        function FillCompany() {
            PageMethods.FillCompanys(function (Tests) {
                var optionInv = '<option value="0">Please Select</option>';
                $.each(JSON.parse(Tests), function (key, value) {
                    optionInv += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                });
                $('#manufacturerDropdown').html(optionInv);
                
            });
        }
        function printVendorCompany() {
            var locationInfo = window.location;
            var url = '/ReportViewer.aspx?ReportName=VendorCompany&ReportTitle=Vendor Company&ID=' + id;
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + '../../ReportViewer.aspx?ReportName=VendorCompany&ReportTitle=Vendor Company&ID=' + id;
            }
            window.open(url, '_blank');
        }
        function printvendorGeneralItem() {
            var locationInfo = window.location;
            var url = '/ReportViewer.aspx?ReportName=VendorGeneralItem&ReportTitle=Vendor General Item&ID=' + id;
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + '../../ReportViewer.aspx?ReportName=VendorGeneralItem&ReportTitle=Vendor General Item&ID=' + id;
            }
            window.open(url, '_blank');
        }
        function printPharmacyItem() {
            var locationInfo = window.location;
            var url = '/ReportViewer.aspx?ReportName=PharmacyItem&ReportTitle=Vendor Pharmacy Item&ID=' + id;
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + '../../ReportViewer.aspx?ReportName=PharmacyItem&ReportTitle=Vendor Pharmacy Item&ID=' + id;
            }
            window.open(url, '_blank');
        }
        function LoadVendorDetail(VenId) {
            PageMethods.LoadVendorDetail(VenId, function (resp) {
                var data = JSON.parse(resp);
                $('#btnSave').val();
                if (data.IsActive == true) {
                    $("#Active").prop('checked', true);
                } else {
                    $("#Active").prop('checked', false);
                }
                if (data.Ismanual == true) {
                    $("#chkmanual").prop('checked', true);
                    $("#ddlPayabl").prop("disabled", false);
                }
                else {
                    $("#chkmanual").prop('checked', false);
                    $("#ddlPayabl").prop("disabled", true);
                }
                $('#txtVendorCode').val(data.Vendor_ID);
                $('input[name=txtVendorId]').val(data.Vendor_ID);
                $('#txtVendorName').val(data.Vendor_Name);
                setTimeout(function () {
                    $('#ddlVendorType').val(data.VendorType).trigger('change');;
                }, 1000);
                $('#txtAddress').val(data.Vendor_Address);
                $('#txtcreditDays').val(data.CreditDays);
                $('#txtCountry').val(data.Country);
                setTimeout(function () {
                    $('#ddlRegion').val(data.Region).trigger('change');
                }, 1000);
                $('#txtCity').val(data.City);
                $('#txtMobno').val(data.MobNo);
                $('#txtPhno').val(data.Vendor_Phone1);
                $('#txtDrugLicenceNo').val(data.DrugLicenceNo);
                $('#txtStn').val(data.Vendor_STN);
                $('#txtNtn').val(data.Vendor_NTN);
                $('#txtCnic').val(data.Cnic);
                $('#txtEmail').val(data.Vendor_Email);
                $('#txtFoc').val(data.Contact_Person);
                setTimeout(function () {
                    $('#ddlTax').val(data.TaxPayerTyp).trigger('change');
                }, 1000);
                setTimeout(function () {
                    $('#ddlCom').val(data.CompanyType_Id).trigger('change');
                }, 1000);
             

                if (data.Account_ID != null && data.Account_ID != "0") {
                    PageMethods.LoadGLAccount(parseInt(data.Account_ID), function (glData) {
                        var AccountData = JSON.parse(glData);
                        $("#hdfAccount_Name").val(AccountData.hdfAccount_Name);
                        $("#hdfAccount_Code").val(AccountData.hdfAccount_Code);
                        $("#hdfParent_Code").val(AccountData.hdfParent_Code);
                        $("#hdfAccount_Serial").val(AccountData.hdfAccount_Serial);
                        $("#hdfLevel").val(AccountData.hdfLevel);
                        $("#hdfAccount_ID").val(AccountData.hdfAccount_ID);
                        // Set dropdown AFTER GL data is fully loaded
                        $('#ddlPayabl').val(data.Account_ID).trigger('change');
                    }
                        , function (err) {
                            alert("Error: " + err.get_message());
                        });
                }
                setTimeout(function () {
                    $('#manufacturerDropdown').val(data.manufacture_id).trigger('change');
                }, 1000);
                LoadVendorPerson(VenId);
                LoadVendorGeneralItem(VenId);
                LoadVendorPharmacyItem(VenId);
                LoadVendorCompany(VenId);

                // Sync Active badge after loading vendor data
                $('#Active').trigger('change');
            },
                function (error) {
                    alert(error.get_message());
                })
        }

        function syncVendorMeta() {
            var code = $('#txtVendorCode').val();
            if (code) {
                $('#vendorCodeDisplay').text(code);
            }
        }

        $(document).ready(function () {
            // Watch vendor code input (hidden) to sync meta bar
            var originalVal = $.fn.val;
            $.fn.val = function(value) {
                var res = originalVal.apply(this, arguments);
                if (this.attr('id') === 'txtVendorCode' && arguments.length >= 1) {
                    syncVendorMeta();
                }
                return res;
            };

            $('#Active').change(function () {
                if ($(this).is(':checked')) {
                    $('#vendorActiveBadge').removeClass('badge-inactive').addClass('badge-active');
                    $('#vendorActiveIcon').removeClass('fa-times-circle').addClass('fa-check-circle');
                    $('#vendorActiveText').text('Active');
                } else {
                    $('#vendorActiveBadge').removeClass('badge-active').addClass('badge-inactive');
                    $('#vendorActiveIcon').removeClass('fa-check-circle').addClass('fa-times-circle');
                    $('#vendorActiveText').text('Inactive');
                }
            });
            // Initial sync (handles new vendor default, existing is synced in LoadVendorDetail)
            $('#Active').trigger('change');
        });

        function GetNewVendorNo() {
            PageMethods.GetNewVendorNo(function (resp) {
                $('#txtVendorCode').val(resp);
            },
                function (error) {
                    alert(error.get_message());
                });
        }

        function LoadVendorPerson(VenId) {
            PageMethods.LoadVendorPerson(VenId, function (resp) {
                var data = (JSON.parse(resp));
                var rows = '';
                var rowIndex = parseInt((parseInt($('#tblItemDescription tbody tr').length)));
                $.each(data, function (key, value) {
                    rows += '<tr>' +
                        '<td><input type="text" id="txtPersonName' + (key + 1) + '" name="txtPersonName" value="' + value.Person_Name + '" style="width:130px !important;"/></td>' +
                        '<td><input type="text" name="txtDesign" id="txtDesigsn' + (key + 1) + '"  value="' + value.Designation + '"  style="width:130px !important;font-size:9px;"/></td>' +
                        '<td><input type="text" name="txtphone" id="txtphone' + (key + 1) + '"  value="' + value.Phone_no + '"  style="width:130px !important;font-size:9px;"/></td>' +
                        '<td><input type="text" name="txtExt" id="txtExt' + (key + 1) + '"  value="' + value.Ext_no + '" style="width:130px !important;font-size:9px;"/></td>' +
                        '<td><input type="text" name="txtcell" id="txtcell' + (key + 1) + '"  value="' + value.cell_no + '" style="width:130px !important;font-size:9px;" /></td>' +
                        '<td><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="fa fa-trash" style="width:15px !important;font-size: 13px;color:#f30a0a;position:relative;" i=""></i></a> </td>'
                    '</tr>';
                })
                $('#tblPerson').append(rows);
            })
        }

        function LoadVendorGeneralItem(VenId) {
            PageMethods.LoadVendorGeneralItems(VenId, function (resp) {
                var data = (JSON.parse(resp));
                var rows = '';
                selectedOptions = data;
                var rowIndex = parseInt((parseInt($('#VendorGeneralItemlist tbody tr').length)));
                $.each(data, function (key, value) {
                    if (value.Unit == null)
                        value.Unit = "";
                    rows += '<tr>' +
                        '<td><input type="hidden" id="txtItemCode' + (key + 1) + '" name="txtItemCode" value="' + value.Item_ID + '" style="width:100% !important;"/>' + value.Item_Code + '</td>' +
                        '<td><input type="hidden" name="txtItemname" id="txtItemname' + (key + 1) + '"  value="' + value.Description + '"  style="width:100% !important;font-size:9px;"/>' + value.Description + '</td>' +
                        '<td><input type="hidden" name="txtUom" id="txtUom' + (key + 1) + '"  value="' + value.Unit + '"  style="width:100% !important;font-size:10px;"/>' + value.Unit + '</td>' +
                        '<td><input type="text" name="txtRate" id="txtRate' + (key + 1) + '"  value="' + value.Rate + '" style="width:100% !important;font-size:10px;"/></td>' +
                        '<td><input type="text" name="txtRef" id="txtRef' + (key + 1) + '"  value="' + value.Ref_num + '"  style="width:100% !important;font-size:9px;"/></td>' +
                        '<td><input type="text" name="txtRemarks" id="txtRemarks' + (key + 1) + '"  value="' + value.remarks + '" style="width:100% !important;font-size:9px;" /></td>' +
                        '<td><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="fa fa-trash" style="width:50% !important;font-size: 13px;color:#f30a0a;position:relative;" i=""></i></a></td>'
                    '</tr>';
                })
                $('#myVendorGeneralItem').append(rows);
            })
        }
        function LoadVendorPharmacyItem(VenId) {
            PageMethods.LoadVendorPharmacyItems(VenId, function (resp) {
                var data = (JSON.parse(resp));
                var rows = '';
                selectedOptions = data;
                var rowIndex = parseInt((parseInt($('#VendorPharmacyItemlist tbody tr').length)));
                $.each(data, function (key, value) {
                    if (value.Unit == null)
                        value.Unit = "";
                    rows += '<tr>' +
                        '<td><input type="hidden" id="txtItemCode' + (key + 1) + '" name="txtItemCode" value="' + value.Item_ID + '" style="width:100% !important;"/>' + value.Item_Code + '</td>' +
                        '<td><input type="hidden" name="txtItemname" id="txtItemname' + (key + 1) + '"  value="' + value.Description + '"  style="width:100% !important;font-size:9px;"/>' + value.Description + '</td>' +
                        '<td><input type="hidden" name="txtUom" id="txtUom' + (key + 1) + '"  value="' + value.Unit + '"  style="width:100% !important;font-size:10px;"/>' + value.Unit + '</td>' +
                        '<td><input type="text" name="txtRate" id="txtRate' + (key + 1) + '"  value="' + value.Rate + '" style="width:100% !important;font-size:10px;"/></td>' +
                        '<td><input type="text" name="txtRef" id="txtRef' + (key + 1) + '"  value="' + value.Ref_num + '"  style="width:100% !important;font-size:9px;"/></td>' +
                        '<td><input type="text" name="txtRemarks" id="txtRemarks' + (key + 1) + '"  value="' + value.remarks + '" style="width:100% !important;font-size:9px;" /></td>' +
                        '<td><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="fa fa-trash" style="width:50% !important;font-size: 13px;color:#f30a0a;position:relative;" i=""></i></a></td>'
                    '</tr>';
                })
                $('#myVendorPharmacyItem').append(rows);
            })
        }

        function LoadVendorCompany(VenId) {
            PageMethods.LoadVendorCompanies(VenId, function (resp) {
                var data = (JSON.parse(resp));
                var rows = '';
                selectedOptions = data;
                var rowIndex = parseInt((parseInt($('#VendorCompanieslist tbody tr').length)));
                $.each(data, function (key, value) {
                    if (value.Unit == null)
                        value.Unit = "";
                    rows += '<tr>' +
                        '<td><input type="text" readonly name="txtSrNO" id="txtSrNO' + (key + 1) + '"  value="' + value.SR_No + '"  style="width:100% !important;font-size:10px;"/></td>' +
                        '<td><input type="text" name="txtCompanyName" id="txtCompanyName' + (key + 1) + '"  value="' + value.Company_Name + '" style="width:100% !important;font-size:10px;" /></td>' +
                        '<td><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="fa fa-trash" style="width:50% !important;font-size: 13px;color:#f30a0a;position:relative;" i=""></i></a></td>'
                    '</tr>';
                })
                $('#myVendorCompany').append(rows);
            })
        }

        $(function () {
            $("#tabs").tabs();
        });

        function Addrow() {
            var rows = '';
            var rowlength = tblItemDescription.rows.length;
            rows += '<tr>' +
                '<td><input type="text" id="txtPersonName' + rowlength + '" name="txtPersonName" value="" style=""/></td>' +
                '<td><input type="text" name="txtDesign" id="txtDesigsn' + rowlength + '"  value=""  style=""/></td>' +
                '<td><input type="text" name="txtphone" id="txtphone' + rowlength + '"  value=""  style=""/></td>' +
                '<td><input type="text" name="txtExt" id="txtExt' + rowlength + '"  value="" style=""/></td>' +
                '<td><input type="text" name="txtcell" id="txtcell' + rowlength + '"  value="" style="" /></td>' +
                '<td><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="fa fa-trash" style="width:15px !important;font-size: 13px;color:#f30a0a;position:relative;" i=""></i></a> </td>'
            '</tr>';
            $('#tblPerson').append(rows);
        }

        function AppendvendorGeneralItem() {
            var rows = '';
            var rowlength = VendorGeneralItemlist.rows.length;
            rows += '<tr>' +
                '<td><select class="form-control" id="txtItemCode' + rowlength + '" name="txtItemCode" style="width:100% !important;font-size: 10px !important;" onchange="GetGeneralItemDetail(this)"></select></td>' +
                '<td><input type="text" name="txtItemname" id="txtItemname' + rowlength + '"  value=""  style="width:100% !important;font-size:9px;"/></td>' +
                '<td><input type="text" name="txtUom" id="txtUom' + rowlength + '"  value=""  style="width:100% !important;font-size:10px;"/></td>' +
                '<td><input type="text" name="txtRate" id="txtRate' + rowlength + '"  value="" style="width:100% !important;font-size:10px;"/></td>' +
                '<td><input type="text" name="txtRef" id="txtRef' + rowlength + '"  value=""  style="width:100% !important;font-size:9px;"/></td>' +
                '<td><input type="text" name="txtRemarks" id="txtRemarks' + rowlength + '"  value="" style="width:100% !important;font-size:9px;" /></td>' +
                '<td><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="fa fa-trash" style="width:50% !important;font-size: 13px;color:#f30a0a;position:relative;" i=""></i></a></td>'
            '</tr>';
            $('#myVendorGeneralItem').append(rows);
            loadGeneralItemList(rowlength);
        }
        function AppendvendorPharmacyItem() {
            var rows = '';
            var rowlength = VendorPharmacyItemlist.rows.length;
            rows += '<tr>' +
                '<td><select class="form-control" id="txtItemCode' + rowlength + '" name="txtItemCode" style="width:100% !important;font-size: 10px !important;" onchange="GetPharmacyItemDetail(this)"></select></td>' +
                '<td><input type="text" name="txtItemname" id="txtItemname' + rowlength + '"  value=""  style="width:100% !important;font-size:9px;"/></td>' +
                '<td><input type="text" name="txtUom" id="txtUom' + rowlength + '"  value=""  style="width:100% !important;font-size:10px;"/></td>' +
                '<td><input type="text" name="txtRate" id="txtRate' + rowlength + '"  value="" style="width:100% !important;font-size:10px;"/></td>' +
                '<td><input type="text" name="txtRef" id="txtRef' + rowlength + '"  value=""  style="width:100% !important;font-size:9px;"/></td>' +
                '<td><input type="text" name="txtRemarks" id="txtRemarks' + rowlength + '"  value="" style="width:100% !important;font-size:9px;" /></td>' +
                '<td><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="fa fa-trash" style="width:50% !important;font-size: 13px;color:#f30a0a;position:relative;" i=""></i></a></td>'
            '</tr>';
            $('#myVendorPharmacyItem').append(rows);
            loadPharmacyItemList(rowlength);
        }
        var currentSrNo = 1;
        function AppendvendorCompany() {
            var rows = '';
            var rowlength = VendorCompanieslist.rows.length;
            rows += '<tr>' +
                '<td><input type="text" readonly name="txtSrNO" id="txtSrNO' + rowlength + '"  value="' + currentSrNo + '"  style="width:100% !important;font-size:10px;"/></td>' +
                '<td><input type="text" name="txtCompanyName" id="txtCompanyName' + rowlength + '"  value="" style="width:100% !important;font-size:10px;" /></td>' +
                '<td><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="fa fa-trash" style="width:50% !important;font-size: 13px;color:#f30a0a;position:relative;" i=""></i></a></td>'
            '</tr>';
            $('#myVendorCompany').append(rows);
            currentSrNo++;
        }
        function ExcludeFromPayment(anchor) {
            Swal.fire({
                title: 'Are you sure?',
                text: "You want to delete this record",
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#d33',
                cancelButtonColor: '#6c757d',
                confirmButtonText: 'Yes, delete it!',
                customClass: {
                    popup: 'swal-big-popup',
                    title: 'swal-big-title',
                    htmlContainer: 'swal-big-text'
                }
            }).then(function (result) {
                if (result.isConfirmed) {
                    console.clear();
                    var row = $(anchor).parents('tr')[0];
                    row.remove();
                }
            });
        }
        function loadGeneralItemList(rowlength) {
            var optionsitem = '';
            var length = rowlength;
            PageMethods.loadGeneralItemList(function (resp) {
                optionsitem = '<option value="0">Select</option>';
                $.each(JSON.parse(resp), function (key, value) {
                    optionsitem += '<option value="' + value.Item_ID + '" >' + value.name + '</option>';
                });
                $('#txtItemCode' + length + '').html(optionsitem);
                $('#txtItemCode' + length + '').select2();
            },
                function (error) {
                    alert(error.get_message());
                });
        }

        function loadPharmacyItemList(rowlength) {
            var optionsitem = '';
            var length = rowlength;

            PageMethods.loadPharmacyItemList(function (resp) {
                optionsitem = '<option value="0">Select</option>';
                $.each(JSON.parse(resp), function (key, value) {
                    optionsitem += '<option value="' + value.Item_ID + '" >' + value.name + '</option>';
                });
                $('#txtItemCode' + length + '').html(optionsitem);
                $('#txtItemCode' + length + '').select2({
                    placeholder: "Search items...",
                    allowClear: true
                });
            },
                function (error) {
                    alert(error.get_message());
                });
        }

        function GetPharmacyItemDetail(item) {
            var itemID = item.value;
            $.ajax({
                type: "POST",
                url: "Vendor.aspx/Getitem",
                data: JSON.stringify({
                    "ItemID": itemID,
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var find = false;
                    var parse = JSON.parse(response.d);
                    console.log(parse);
                    var length = $("#myVendorPharmacyItem tr").length;
                    var rows = '';
                    var rowlength = VendorPharmacyItemlist.rows.length - 2;
                    if (parse[0].Unit == null) {
                        parse[0].Unit = "";
                    }
                    $('#myVendorPharmacyItem tr').each(function () {
                        var $item = $(this).find('td:eq(11)').text();
                        if ($item == itemID) {
                            find = true;
                        }
                    });
                    if (find == true) {
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'Item already exists',
                            showConfirmButton: false,
                            timer: 2000,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });

                    }
                    else {
                        rows += '<tr>' +
                            '<td><input type="hidden" id="txtItemCode' + rowlength + '" name="txtItemCode" value="' + parse[0].Item_ID + '" style="width:100% !important;" />' + parse[0].Item_Code + '</td>' +
                            '<td><input type="hidden" name="txtItemname" id="txtItemname' + rowlength + '"  value="' + parse[0].Description + '"  style="width:100% !important;font-size:9px;"/>' + parse[0].Description + '</td>' +
                            '<td><input type="hidden" name="txtUom" id="txtUom ' + rowlength + '"  value="' + parse[0].Unit + '"  style="width:100% !important;font-size:10px;"/>' + parse[0].Unit + '</td>' +
                            '<td><input type="text" name="txtRate" id="txtRate' + rowlength + '"  value="" style="width:100% !important;font-size:10px;"/></td>' +
                            '<td><input type="text" name="txtRef" id="txtRef ' + rowlength + '"  value=""  style="width:100% !important;font-size:9px;"/></td>' +
                            '<td><input type="text" name="txtRemarks" id="txtRemarks' + rowlength + '"  value="" style="width:100% !important;font-size:9px;" /></td>' +
                            '<td><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="fa fa-trash" style="width:50% !important;font-size: 13px;color:#f30a0a;position:relative;" i=""></i></a></td></tr>';
                        $("#VendorPharmacyItemlist").append(rows);

                        for (var i = 0; i < VendorPharmacyItemlist.rows.length; i++) {
                            if ($('#txtItemname' + i + '').val() == '') {
                                VendorPharmacyItemlist.deleteRow(i);
                            }
                        }
                    }
                },
                failure: function (response) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'In failure method',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });

                }
            });
        }
        function GetGeneralItemDetail(item) {
            var itemID = item.value;
            $.ajax({
                type: "POST",
                url: "Vendor.aspx/Getitem",
                data: JSON.stringify({
                    "ItemID": itemID,
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var find = false;
                    var parse = JSON.parse(response.d);
                    var length = $("#myVendorGeneralItem tr").length;
                    var rows = '';
                    var rowlength = VendorGeneralItemlist.rows.length - 2;
                    if (parse[0].Unit == null) {
                        parse[0].Unit = "";
                    }
                    $('#myVendorGeneralItem tr').each(function () {
                        var $item = $(this).find('td:eq(11)').text();
                        if ($item == itemID) {
                            find = true;
                        }
                    });
                    if (find == true) {
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'Item already exists',
                            showConfirmButton: false,
                            timer: 2000,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });

                    }
                    else {
                        rows += '<tr>' +
                            '<td><input type="hidden" id="txtItemCode' + rowlength + '" name="txtItemCode" value="' + parse[0].Item_ID + '" style="width:100% !important;" />' + parse[0].Item_Code + '</td>' +
                            '<td><input type="hidden" name="txtItemname" id="txtItemname' + rowlength + '"  value="' + parse[0].Description + '"  style="width:100% !important;font-size:9px;"/>' + parse[0].Description + '</td>' +
                            '<td><input type="hidden" name="txtUom" id="txtUom ' + rowlength + '"  value="' + parse[0].Unit + '"  style="width:100% !important;font-size:10px;"/>' + parse[0].Unit + '</td>' +
                            '<td><input type="text" name="txtRate" id="txtRate' + rowlength + '"  value="" style="width:100% !important;font-size:10px;"/></td>' +
                            '<td><input type="text" name="txtRef" id="txtRef ' + rowlength + '"  value=""  style="width:100% !important;font-size:9px;"/></td>' +
                            '<td><input type="text" name="txtRemarks" id="txtRemarks' + rowlength + '"  value="" style="width:100% !important;font-size:9px;" /></td>' +
                            '<td><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="fa fa-trash" style="width:50% !important;font-size: 13px;color:#f30a0a;position:relative;" i=""></i></a></td></tr>';
                        $("#VendorGeneralItemlist").append(rows);
                        for (var i = 0; i < VendorGeneralItemlist.rows.length; i++) {
                            if ($('#txtItemname' + i + '').val() == '') {
                                VendorGeneralItemlist.deleteRow(i);
                            }
                        }
                    }
                },
                failure: function (response) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'In failure method',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });

                }
            });
        }
        function SaveAllRecord() {
            var btnSave = $('#btnSave').val();
            var VendorName = $('#txtVendorName').val();
            if (VendorName == '') {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Enter Supplier/Vendor Name',
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
            var VendorType = $('#ddlVendorType').val();
            if (VendorType == 0) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Select Supplier/Vendor Type',
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
            var Address = $('#txtAddress').val();
            var CreditDays = $('#txtcreditDays').val();
            var Country = $('#txtCountry').val();
            var Region = $('#ddlRegion').val();
            var City = $('#txtCity').val();
            var MobNo = $('#txtMobno').val();
            var PhnNo = $('#txtPhno').val();
            var DrugLicenceNo = $('#txtDrugLicenceNo').val();
            var Stn = $('#txtStn').val();
            var Ntn = $('#txtNtn').val();
            var Cnic = $('#txtCnic').val();
            var Email = $('#txtEmail').val();
            var Foc = $('#txtFoc').val();
            var AccountId = $('#ddlPayabl').val();
            var TaxTyp = $('#ddlTax').val();
            var CompanyTyp = $('#ddlCom').val();
            var manufacturerDropdown = $('#manufacturerDropdown').val();
            var active = $('#Active').prop('checked');
            var Chkmanual = $('#chkmanual').prop('checked');
            if (Chkmanual == true && AccountId == 0) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Select Payable Account Code',
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
            var table = $('#tblItemDescription');
            var hdfParent_Code = $('#hdfParent_Code').val();
            var hdfAccount_Serial = $('#hdfAccount_Serial').val();
            var hdfLevel = $('#hdfLevel').val();
            var hdfAccount_Code = $('#hdfAccount_Code').val();
            var tableGeneralItems = $('#VendorGeneralItemlist');
            var tablePharmacyItems = $('#VendorPharmacyItemlist');
            var tableCompany = $('#VendorCompanieslist');
            var hdfAccount_ID = $('#hdfAccount_ID').val();
            var VendorId = $('#txtVendorId').val();
            var VendorCode = $('#txtVendorCode').val();
            var Person_list = [];
            var GeneralItem_list = [];
            var PharmacyItem_list = [];
            var Company_list = [];
            table.find('tr').each(function (key, value) {
                var personname = $(value).find('td input[name=txtPersonName]').val();
                if (personname != undefined) {
                    Person_list.push({ 'PersonName': $(value).find('td input[name=txtPersonName]').val(), 'Designation': $(value).find('td input[name=txtDesign]').val(), 'PhnNo': $(value).find('td input[name=txtphone]').val(), 'ExtNo': $(value).find('td input[name=txtExt]').val(), 'CellNo': $(value).find('td input[name=txtcell]').val(), });
                }
            });
            tableGeneralItems.find('tr').each(function (key, value) {
                var itemId = $(value).find('td input[name=txtItemCode]').val();
                if (itemId != undefined) {
                    GeneralItem_list.push({ 'ItemId': $(value).find('td input[name=txtItemCode]').val(), 'Rate': $(value).find('td input[name=txtRate]').val(), 'RefNo': $(value).find('td input[name=txtRef]').val(), 'Remarks': $(value).find('td input[name=txtRemarks]').val(), });
                }
            });
            tablePharmacyItems.find('tr').each(function (key, value) {
                if ($(this).hasClass('empty-state-row')) {
                    return;
                }
                var itemId = $(value).find('td input[name=txtItemCode]').val();
                if (itemId != undefined && itemId != '' && itemId != '0') {
                    var rate = $(value).find('td input[name=txtRate]').val();
                    if (rate == '' || rate == null || rate == undefined) {
                        rate = '0';
                    }
                    PharmacyItem_list.push({
                        'ItemId': itemId,
                        'Rate': rate,
                        'RefNo': $(value).find('td input[name=txtRef]').val() || '',
                        'Remarks': $(value).find('td input[name=txtRemarks]').val() || ''
                    });
                }
            });
            tableCompany.find('tr').each(function (key, value) {
                var companyname = $(value).find('td input[name=txtCompanyName]').val();
                if (companyname != undefined) {
                    Company_list.push({ 'SRNo': $(value).find('td input[name=txtSrNO]').val(), 'CompanyName': $(value).find('td input[name=txtCompanyName]').val(), });
                }
            });
            $('#btnsave').attr('disabled', true);
            var AllItemDetail = {
                'IsActive': active, 'Ismanual': Chkmanual, 'VendorId': VendorId, 'VendorName': VendorName, 'VendorType': VendorType, 'Address': Address, 'CreditDays': CreditDays, 'Country': Country, 'Region': Region, 'City': City, 'MobNo': MobNo, 'PhnNo': PhnNo, 'DrugLicenceNo': DrugLicenceNo, 'Stn': Stn, 'Ntn': Ntn, 'Cnic': Cnic, 'Email': Email, 'FocalPerson': Foc, 'PayablCode': AccountId, 'TaxTyp': TaxTyp, 'VendorCode': VendorCode, 'CompanyTyp': CompanyTyp, 'manufacturerDropdown': manufacturerDropdown, 'PersonList': Person_list, 'GeneralItemlist': GeneralItem_list, 'PharmacyItemlist': PharmacyItem_list, 'Companylist': Company_list ,'hdfAccount_ID': hdfAccount_ID,'hdfParent_Code': hdfParent_Code,'hdfAccount_Serial': hdfAccount_Serial,'hdfLevel': hdfLevel,'hdfAccount_Code': hdfAccount_Code};
            PageMethods.SaveVendor(btnSave, JSON.stringify(AllItemDetail), function (res) {
                Swal.fire({
                    icon: 'success',
                    title: 'Success!',
                    text: 'Data Save Successfully',
                    showConfirmButton: false,
                    timer: 2500,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                $('#btnSave').val("Update");
                window.location = "Vendor.aspx?ID=" + res;
                $('#btnSave').val("Update");
            });
        }
        function loadPayableCode(callback) {
            var optionsPayabl = '';
            PageMethods.loadPayableCode(function (resp) {
                optionsPayabl = '<option value="0">Please Select</option>';
                $.each(JSON.parse(resp), function (key, value) {
                    optionsPayabl += '<option value="' + value.Account_ID + '" >' + value.name + '</option>';
                });
                $('#ddlPayabl').html(optionsPayabl);
                // Re-init select2 so new options are reflected in the widget
                if ($('#ddlPayabl').data('select2')) {
                    $('#ddlPayabl').select2('destroy').select2();
                } else {
                    $('#ddlPayabl').select2();
                }
                if (callback) callback();
            },
                function (error) {
                    alert(error.get_message());
                });
        }
        function FillDropDownList() {
            var optionRegion = '<option value="0">Please Select</option>';
            var optionTaxTyp = '<option value="0">Please Select</option>';
            var optionVenTyp = '<option value="0">Please Select</option>';
            var optionComTyp = '<option value="0">Please Select</option>';

            PageMethods.getDDLlist(function (Tests) {
                $.each(JSON.parse(Tests), function (key, value) {
                    if (value.Type == "Reg") {
                        optionRegion += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                    }
                    else if (value.Type == "Taxtyp") {
                        optionTaxTyp += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                    }
                    else if (value.Type == "ComTyp") {
                        optionComTyp += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                    }
                    else {
                        optionVenTyp += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                    }
                });
                $('#ddlVendorType').html(optionVenTyp);
                $('#ddlRegion').html(optionRegion);
                $('#ddlTax').html(optionTaxTyp);
                $('#ddlCom').html(optionComTyp);

                // Re-init select2 on all repopulated dropdowns
                var select2Selectors = ['#ddlVendorType', '#ddlRegion', '#ddlTax', '#ddlCom'];
                $.each(select2Selectors, function (i, sel) {
                    if ($(sel).data('select2')) {
                        $(sel).select2('destroy').select2();
                    } else {
                        $(sel).select2();
                    }
                });

            });
        }

        function LoadAllitem(searchText) {
            var manufacturerId = $('#manufacturerDropdown').val() || '0';
            $.ajax({
                type: "POST",
                url: "Vendor.aspx/GetAllitem",
                data: JSON.stringify({
                    searchText: searchText,
                    manufacturerId: manufacturerId
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var items = JSON.parse(response.d);
                    var tableBody = $('#itemsTableBody');
                    tableBody.empty();

                    if (items.length === 0) {
                        tableBody.append('<tr><td colspan="5" class="text-center">No items found</td></tr>');
                    } else {
                        $.each(items, function (index, item) {
                            var row = '<tr>' +
                                '<td style="text-align:center;"><input type="checkbox" class="itemCheckbox" onclick="appendSearchItem(this)"></td>' +
                                '<td style="display:none;">' + item.Item_ID + '</td>' +
                                '<td>' + (item.Item_Code || '') + '</td>' +
                                '<td>' + (item.Description || '') + '</td>' +
                                '<td>' + (item.Unit || '') + '</td>' +
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

        
        function toggleAllItems(selectAllCheckbox) {
            var isChecked = $(selectAllCheckbox).is(':checked');
            $('#itemsTableBody .itemCheckbox').each(function () {
                if ($(this).prop('checked') !== isChecked) {
                    $(this).prop('checked', isChecked);
                    appendSearchItem(this);
                }
            });
        }


        function appendSearchItem(checkbox) {
            var row = $(checkbox).closest('tr');
            var itemId = row.find('td:eq(1)').text().trim();
            var itemCode = row.find('td:eq(2)').text().trim();
            var description = row.find('td:eq(3)').text().trim();
            var uom = row.find('td:eq(4)').text().trim();
            var purchaseRate = row.find('td:eq(5)').text().trim();
            var uomQty = row.find('td:eq(6)').text().trim();

            if ($(checkbox).is(':checked')) {
                var find = false;
                $('#myVendorPharmacyItem tr').each(function () {
                    // Skip empty state row
                    if ($(this).hasClass('empty-state-row')) {
                        return true; // continue
                    }
                    var existingItemId = $(this).find('td input[name=txtItemCode]').val();
                    if (existingItemId == itemId) {
                        find = true;
                        return false;
                    }
                });

                if (find) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Item already exists',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });
                    $(checkbox).prop('checked', false);
                    return;
                }

                // Remove empty state row if it exists
                $('#myVendorPharmacyItem tr.empty-state-row').remove();

                // Get current row count in the table body
                var rowlength = $('#myVendorPharmacyItem tr').length;

                var rows = '';
                rows += '<tr>' +
                    '<td><input type="hidden" id="txtItemCode' + rowlength + '" name="txtItemCode" value="' + itemId + '" style="width:100% !important;" />' + itemCode + '</td>' +
                    '<td><input type="hidden" name="txtItemname" id="txtItemname' + rowlength + '" value="' + description + '" style="width:100% !important;font-size:9px;"/>' + description + '</td>' +
                    '<td><input type="hidden" name="txtUom" id="txtUom' + rowlength + '" value="' + uom + '" style="width:100% !important;font-size:10px;"/>' + uom + '</td>' +
                    '<td><input type="text" name="txtRate" id="txtRate' + rowlength + '" value="" style="width:100% !important;font-size:10px;" placeholder="Enter Rate"/></td>' +
                    '<td><input type="text" name="txtRef" id="txtRef' + rowlength + '" value="" style="width:100% !important;font-size:9px;" placeholder="Ref #"/></td>' +
                    '<td><input type="text" name="txtRemarks" id="txtRemarks' + rowlength + '" value="" style="width:100% !important;font-size:9px;" placeholder="Remarks"/></td>' +
                    '<td><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="fa fa-trash" style="width:50% !important;font-size: 13px;color:#f30a0a;position:relative;" i=""></i></a></td>' +
                    '</tr>';

                $('#myVendorPharmacyItem').append(rows);
                var newRow = $('#myVendorPharmacyItem tr:last');
                newRow.css('background-color', '#d4edda');
                setTimeout(function () {
                    newRow.css('background-color', '');
                }, 1000);

            } else {
                // Remove the item when unchecked
                var itemToRemove = null;
                $('#myVendorPharmacyItem tr').each(function () {
                    if ($(this).hasClass('empty-state-row')) {
                        return true; // continue
                    }
                    var existingItemId = $(this).find('td input[name=txtItemCode]').val();
                    if (existingItemId == itemId) {
                        itemToRemove = $(this);
                        return false;
                    }
                });

                if (itemToRemove) {
                    itemToRemove.css('background-color', '#f8d7da');
                    setTimeout(function () {
                        itemToRemove.remove();
                        if ($('#myVendorPharmacyItem tr').length === 0) {
                            showEmptyState();
                        }
                    }, 300);
                }
            }
        }

        function removePharmacyItem(row) {
            Swal.fire({
                title: 'Are you sure?',
                text: "You want to remove this item",
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#d33',
                cancelButtonColor: '#6c757d',
                confirmButtonText: 'Yes, remove it!',
                customClass: {
                    popup: 'swal-big-popup',
                    title: 'swal-big-title',
                    htmlContainer: 'swal-big-text'
                }
            }).then(function (result) {
                if (result.isConfirmed) {
                    $(row).remove();
                    if ($('#myVendorPharmacyItem tr').length === 0) {
                        showEmptyState();
                    }
                }
            });
        }

        function showEmptyState() {
            var emptyRow = '<tr class="empty-state-row">' +
                '<td colspan="7">' +
                '<span class="empty-state-icon"><i class="fa fa-medkit"></i></span>' +
                '<span class="empty-state-text">No pharmacy items added yet</span>' +
                '</td>' +
                '</tr>';
            $('#myVendorPharmacyItem').append(emptyRow);
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Meta Bar -->
    <div class="pr-meta-bar">
        <div class="meta-left">
            <span class="meta-title"><i class="fa fa-building"></i> Supplier / Vendor</span>
        </div>
        <div class="meta-right">
            <div class="meta-badge">
                <span class="badge-label">Code:</span>
                <span class="badge-value" id="vendorCodeDisplay">---</span>
            </div>
            <div class="meta-badge" id="vendorActiveBadge" style="cursor: pointer;" onclick="$('#Active').click();">
                <i class="fa fa-check-circle" id="vendorActiveIcon"></i> <span id="vendorActiveText">Active</span>
            </div>
            <!-- Hidden inputs to retain logic -->
            <input type="hidden" id="txtVendorCode" name="txtVendorCode" />
            <input type="checkbox" id="Active" name="Active" style="display:none;" />
            <input type="hidden" id="txtVendorId" name="txtVendorId" />
        </div>
    </div>

    <form id="item">
        <div class="row">
            <!-- Left Column: Basic & Legal -->
            <div class="col-lg-6 col-md-12 pr-cards-column">
                <!-- Card 1: Basic Info -->
                <div class="pr-primary-settings">
                    <h5 class="pr-section-title" style="margin-top:0;"><i class="fa fa-info-circle"></i> Basic Information</h5>
                    <div class="row">
                        <div class="col-md-8 col-sm-12">
                            <label id="lblVendorName">Supplier / Vendor Name</label>
                            <div class="input-group">
                                <div class="input-group-prepend"><span class="input-group-text"><i class="fa fa-user"></i></span></div>
                                <input type="text" id="txtVendorName" class="form-control" placeholder="Enter supplier / vendor name" />
                            </div>
                        </div>
                        <div class="col-md-4 col-sm-12">
                            <label id="lblVendorType">Vendor Type</label>
                            <select id="ddlVendorType"></select>
                        </div>
                    </div>
                    <div class="row mt-2">
                        <div class="col-md-4 col-sm-12">
                            <label id="lblCountry">Country</label>
                            <input type="text" id="txtCountry" class="form-control" placeholder="e.g. Pakistan" />
                        </div>
                        <div class="col-md-4 col-sm-12">
                            <label id="lblRegion">Region</label>
                            <select id="ddlRegion"></select>
                        </div>
                        <div class="col-md-4 col-sm-12">
                            <label id="lblCity">City</label>
                            <input type="text" id="txtCity" class="form-control" placeholder="e.g. Lahore" />
                        </div>
                    </div>
                </div>

                <!-- Card 2: Tax & Legal -->
                <div class="pr-primary-settings">
                    <h5 class="pr-section-title" style="margin-top:0;"><i class="fa fa-balance-scale"></i> Tax & Legal</h5>
                    <div class="row">
                        <div class="col-md-4 col-sm-12">
                            <label id="lblCnic">CNIC #</label>
                            <div class="input-group">
                                <div class="input-group-prepend"><span class="input-group-text"><i class="fa fa-credit-card"></i></span></div>
                                <input type="text" id="txtCnic" class="form-control" placeholder="XXXXX-XXXXXXX-X" />
                            </div>
                        </div>
                        <div class="col-md-4 col-sm-12">
                            <label id="lblNtn">NTN</label>
                            <input type="text" id="txtNtn" class="form-control" placeholder="Enter NTN number" />
                        </div>
                        <div class="col-md-4 col-sm-12">
                            <label id="lblStn">STN</label>
                            <input type="text" id="txtStn" class="form-control" placeholder="Enter STN number" />
                        </div>
                    </div>
                    <div class="row mt-2">
                        <div class="col-md-4 col-sm-12">
                            <label id="lblDrugLicenceNo">Drug Licence #</label>
                            <input type="text" id="txtDrugLicenceNo" class="form-control" placeholder="Licence number" />
                        </div>
                        <div class="col-md-4 col-sm-12">
                            <label id="lblTax">Tax Payer Type</label>
                            <select id="ddlTax" class="form-control"></select>
                        </div>
                        <div class="col-md-4 col-sm-12">
                            <label id="lblCom">Company Type</label>
                            <select id="ddlCom" class="form-control"></select>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Right Column: Contact & Financial -->
            <div class="col-lg-6 col-md-12 pr-cards-column">
                <!-- Card 3: Contact Details -->
                <div class="pr-primary-settings">
                    <h5 class="pr-section-title" style="margin-top:0;"><i class="fa fa-address-book"></i> Contact Details</h5>
                    <div class="row">
                        <div class="col-md-12">
                            <label id="lblAddress">Address</label>
                            <div class="input-group">
                                <div class="input-group-prepend"><span class="input-group-text"><i class="fa fa-map-marker"></i></span></div>
                                <input type="text" id="txtAddress" class="form-control" placeholder="Street, area, landmark..." />
                            </div>
                        </div>
                    </div>
                    <div class="row mt-2">
                        <div class="col-md-6 col-sm-12">
                            <label id="lblFoc">Focal Person</label>
                            <input type="text" id="txtFoc" class="form-control" placeholder="Contact person name" />
                        </div>
                        <div class="col-md-6 col-sm-12">
                            <label id="lblMobno">Mobile #</label>
                            <div class="input-group">
                                <div class="input-group-prepend"><span class="input-group-text"><i class="fa fa-mobile"></i></span></div>
                                <input type="text" id="txtMobno" class="form-control" placeholder="+92XXXXXXXXXX" />
                            </div>
                        </div>
                    </div>
                    <div class="row mt-2">
                        <div class="col-md-6 col-sm-12">
                            <label id="lblPhno">Phone #</label>
                            <div class="input-group">
                                <div class="input-group-prepend"><span class="input-group-text"><i class="fa fa-phone"></i></span></div>
                                <input type="text" id="txtPhno" class="form-control" placeholder="Landline number" />
                            </div>
                        </div>
                        <div class="col-md-6 col-sm-12">
                            <label id="lblEmail">Email</label>
                            <div class="input-group">
                                <div class="input-group-prepend"><span class="input-group-text"><i class="fa fa-envelope"></i></span></div>
                                <input type="text" id="txtEmail" class="form-control" placeholder="someone@example.com" />
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Card 4: Financial Settings -->
                <div class="pr-primary-settings">
                    <h5 class="pr-section-title" style="margin-top:0;"><i class="fa fa-money"></i> Financial Settings</h5>
                    <div class="row">
                        <div class="col-md-2 col-sm-4">
                            <label for="chkmanual">Manual</label>
                            <input type="checkbox" id="chkmanual" name="chkmanual" style="display: block; margin: 8px 0 0 0; width: 20px; height: 20px; cursor: pointer;" />
                        </div>
                        <div class="col-md-6 col-sm-4">
                            <label id="lblPayabl">Payable Code</label>
                            <select id="ddlPayabl" class="form-control"></select>
                            <!-- Hidden account fields -->
                            <input type="hidden" id="hdfAccount_Name" name="hdfAccount_Name" />
                            <input type="hidden" id="hdfAccount_Code" name="hdfAccount_Code" />
                            <input type="hidden" id="hdfParent_Code" name="hdfParent_Code" />
                            <input type="hidden" id="hdfAccount_Serial" name="hdfAccount_Serial" />
                            <input type="hidden" id="hdfLevel" name="hdfLevel" />
                            <input type="hidden" id="hdfAccount_ID" name="hdfAccount_ID" />
                            <input type="hidden" id="hdfAccountExists" name="hdfAccountExists" />
                        </div>
                        <div class="col-md-4 col-sm-4">
                            <label id="lblCreditDays">Credit Days</label>
                            <input type="text" id="txtcreditDays" class="form-control" placeholder="e.g. 30" />
                        </div>
                    </div>
                    <div class="vendor-info-callout" style="margin-top: 6px;">
                        <i class="fa fa-info-circle"></i>
                        <span>A GL payable account will be <strong>auto-created</strong> for this vendor. Check <strong>Manual</strong> to select an existing account instead.</span>
                    </div>
                </div>
            </div>
        </div>
    </form>

    <div id="tabs" style="margin-top: 20px;">
        <ul>
            <li><a href="#Tab-1">Persons</a></li>
            <li><a href="#Tab-2">Vendor Companies</a></li>
            <li><a href="#Tab-3">Vendor General Items</a></li>
            <li><a href="#Tab-4">Vendor Pharmacy Items</a></li>
        </ul>
        <div id="Tab-1">
            <div style="margin-bottom: 12px; display: flex; justify-content: flex-end; gap: 8px;">
                <button type="button" class="btn-item-pick" onclick="Addrow()" title="Add Person"><i class="fa fa-plus"></i></button>
                <input style="display: none !important" type="button" class="btn btn-primry" onclick="printPerson()" value="Print" id="PrintPerson" />
            </div>
            <div style="overflow-x: auto; overflow-y: auto; max-height: 250px; border-radius: 4px; border: 1px solid #eee;">
                <table class="table pr-tab-table table-hover table-bordered table-striped" id="tblItemDescription" style="margin: 0; width: 100%;">
                    <thead>
                        <tr>
                            <th style="width: 25%; text-align: left;">Person Name</th>
                            <th style="width: 20%; text-align: left;">Designation</th>
                            <th style="width: 20%; text-align: left;">Phone #</th>
                            <th style="width: 15%; text-align: left;">Ext #</th>
                            <th style="width: 15%; text-align: left;">Cell #</th>
                            <th style="width: 5%; text-align: center;">Action</th>
                        </tr>
                    </thead>
                    <tbody id="tblPerson">
                        <tr class="empty-state-row">
                            <td colspan="6">
                                <span class="empty-state-icon"><i class="fa fa-address-book-o"></i></span>
                                <span class="empty-state-text">No persons added yet</span>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

        <div id="Tab-2">
            <div style="margin-bottom: 12px; display: flex; justify-content: flex-end; gap: 8px;">
                <button type="button" class="btn-item-pick" onclick="AppendvendorCompany()" title="Add Company"><i class="fa fa-plus"></i></button>
                <input style="display: none !important" type="button" class="btn btn-info" onclick="printVendorCompany()" value="Print" id="PrintVendorCompany" />
            </div>
            <div style="overflow-x: auto; overflow-y: auto; max-height: 250px; border-radius: 4px; border: 1px solid #eee;">
                <table class="table pr-tab-table table-hover table-bordered table-striped" id="VendorCompanieslist" style="margin: 0; width: 100%;">
                    <thead>
                        <tr>
                            <th style="width: 10%; text-align: center;">Sr #</th>
                            <th style="width: 80%; text-align: left;">Company Name</th>
                            <th style="text-align: center; width: 10%;">Action</th>
                        </tr>
                    </thead>
                    <tbody id="myVendorCompany">
                        <tr class="empty-state-row">
                            <td colspan="3">
                                <span class="empty-state-icon"><i class="fa fa-building-o"></i></span>
                                <span class="empty-state-text">No companies added yet</span>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

        <div id="Tab-3">
            <div style="margin-bottom: 12px; display: flex; justify-content: flex-end; gap: 8px;">
                <button type="button" class="btn-item-pick" onclick="AppendvendorGeneralItem()" title="Add General Item"><i class="fa fa-plus"></i></button>
                <input style="display: none !important" type="button" class="btn btn-info" onclick="printvendorGeneralItem()" value="Print" id="PrintvendorGeneralItem" />
            </div>
            <div style="overflow-x: auto; overflow-y: auto; max-height: 250px; border-radius: 4px; border: 1px solid #eee;">
                <table class="table pr-tab-table table-hover table-bordered table-striped" id="VendorGeneralItemlist" style="margin: 0; width: 100%;">
                    <thead>
                        <tr>
                            <th style="width: 15%; text-align: left;">Item Code</th>
                            <th style="width: 25%; text-align: left;">Description</th>
                            <th style="text-align: center; width: 8%;">UOM</th>
                            <th style="text-align: right; width: 10%;">Rate</th>
                            <th style="text-align: left; width: 15%;">Ref #</th>
                            <th style="text-align: left; width: 22%;">Remarks</th>
                            <th style="text-align: center; width: 5%;">Action</th>
                        </tr>
                    </thead>
                    <tbody id="myVendorGeneralItem">
                        <tr class="empty-state-row">
                            <td colspan="7">
                                <span class="empty-state-icon"><i class="fa fa-cube"></i></span>
                                <span class="empty-state-text">No general items added yet</span>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

        <div id="Tab-4">
            <div class="row" style="margin-bottom: 12px;">
    <!-- Left column: Manufacturer filter -->
    <div class="col-lg-2">
        <div class="form-inline" style="gap: 8px;">
            <label for="manufacturerDropdown" style="font-weight: bold; white-space: nowrap;">Manufacturer:</label>
            <select id="manufacturerDropdown" class="form-control" style="width: auto; flex: 1;">
                <option value="">All</option>
                <!-- options dynamically populated -->
            </select>
        </div>
    </div>
    <!-- Right column: Buttons -->
    <div class="col-lg-10 text-right">
        <button type="button" class="btn btn-primry" id="btnGetAllItems"><i class="fa fa-search"></i> Items</button>
        <button type="button" class="btn-item-pick" onclick="AppendvendorPharmacyItem()" title="Add Pharmacy Item"><i class="fa fa-plus"></i></button>
        <input style="display: none !important" type="button" class="btn btn-info" onclick="printPharmacyItem()" value="Print" id="PrintPharmacyItem" />
    </div>
</div>
            <div style="overflow-x: auto; overflow-y: auto; max-height: 250px; border-radius: 4px; border: 1px solid #eee;">
                <table class="table pr-tab-table table-hover table-bordered table-striped" id="VendorPharmacyItemlist" style="margin: 0; width: 100%;">
                    <thead>
                        <tr>
                            <th style="width: 15%; text-align: left;">Item Code</th>
                            <th style="width: 25%; text-align: left;">Description</th>
                            <th style="text-align: center; width: 8%;">UOM</th>
                            <th style="text-align: right; width: 10%;">Rate</th>
                            <th style="text-align: left; width: 15%;">Ref #</th>
                            <th style="text-align: left; width: 22%;">Remarks</th>
                            <th style="text-align: center; width: 5%;">Action</th>
                        </tr>
                    </thead>
                    <tbody id="myVendorPharmacyItem">
                        <tr class="empty-state-row">
                            <td colspan="7">
                                <span class="empty-state-icon"><i class="fa fa-medkit"></i></span>
                                <span class="empty-state-text">No pharmacy items added yet</span>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <div class="modal fade" id="itemsModal" tabindex="-1" aria-labelledby="itemsModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg custom-modal-dialog">
        <div class="modal-content custom-modal-content">
            <div class="modal-header custom-modal-header">
                <div class="custom-modal-title-wrap">
                    <span class="custom-modal-icon"><i class="fa fa-cubes"></i></span>
                    <h4 class="modal-title custom-modal-title" id="itemsModalLabel">Item Details</h4>
                </div>
                <button type="button" class="custom-modal-close" data-dismiss="modal" aria-label="Close"><i class="fa fa-times"></i></button>
            </div>
            <div class="modal-body custom-modal-body">
                <div class="custom-modal-search-wrap">
                    <span class="custom-modal-search-icon"><i class="fa fa-search"></i></span>
                    <input type="text" id="searchInput" class="custom-modal-search" placeholder="Search items..." />
                </div>
                <div class="custom-modal-table-wrap">
                    <table class="table custom-modal-table">
                        <thead>
                            <tr>
                                <th style="width: 5%;">
                                    <input type="checkbox" id="selectAllItems" onclick="toggleAllItems(this)" />
                                </th>
                                <th style="display: none;">Item ID</th>
                                <th style="width: 20%;">Item Code</th>
                                <th style="width: 35%;">Description</th>
                                <th style="width: 15%;">Unit</th>
                                <th style="display: none;">Purchase Rate</th>
                                <th style="display: none;">UOM Qty</th>
                            </tr>
                        </thead>
                        <tbody id="itemsTableBody">
                        </tbody>
                    </table>
                </div>
            </div>
            <div class="modal-footer">
                <input type="button" value="Close" class="btn-gray" data-dismiss="modal" />
            </div>
        </div>
    </div>
</div>

    <div class="pr-action-buttons">
        <div class="row">
            <div class="col-lg-2 col-md-4 col-sm-12">
                <input type="button" class="btn btn-primry w-100" onclick="SaveAllRecord()" value="Save" id="btnSave" />
            </div>
            <div class="col-lg-2 col-md-4 col-sm-12">
                <input type="button" class="btn btn-gray w-100" value="List" onclick="window.location = 'VendorView.aspx'" />
            </div>
            <div class="col-lg-2 col-md-4 col-sm-12">
                <input type="button" class="btn btn-yellow w-100" value="New" onclick="window.location = 'Vendor.aspx'" />
            </div>
        </div>
    </div>

</asp:Content>
