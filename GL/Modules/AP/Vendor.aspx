<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Vendor.aspx.cs" Inherits="PMS.Vendor" Theme="Default_Theme" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/Tibbit_theme/css/CustomCss/vendor.css" rel="stylesheet" />

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
            loadPayableCode();
            FillDropDownList();
           <% if (Request.QueryString["ID"] != null)
        { %>
            $('#btnSave').val('Update');
            var VenId = '<%= Request.QueryString["ID"]%>';
            $('#txtVendorId').val(VenId);
            LoadVendorDetail(VenId);
           <% }
         %>
        })
        var id = '<% =Request.QueryString["ID"] %>';
        function printPerson() {
            debugger;
            var locationInfo = window.location;
            var url = '/ReportViewer.aspx?ReportName=VendorPerson&ReportTitle=Vendor Person&ID=' + id;
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + '/ReportViewer.aspx?ReportName=VendorPerson&ReportTitle=Vendor Person&ID=' + id;
            }
            window.open(url, '_blank');
        }
        function printVendorCompany() {
            debugger;
            var locationInfo = window.location;
            var url = '/ReportViewer.aspx?ReportName=VendorCompany&ReportTitle=Vendor Company&ID=' + id;
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + '/ReportViewer.aspx?ReportName=VendorCompany&ReportTitle=Vendor Company&ID=' + id;
            }
            window.open(url, '_blank');
        }
        function printvendorGeneralItem() {
            debugger;
            var locationInfo = window.location;
            var url = '/ReportViewer.aspx?ReportName=VendorGeneralItem&ReportTitle=Vendor General Item&ID=' + id;
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + '/ReportViewer.aspx?ReportName=VendorGeneralItem&ReportTitle=Vendor General Item&ID=' + id;
            }
            window.open(url, '_blank');
        }
        function printPharmacyItem() {
            debugger;
            var locationInfo = window.location;
            var url = '/ReportViewer.aspx?ReportName=PharmacyItem&ReportTitle=Vendor Pharmacy Item&ID=' + id;
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + '/ReportViewer.aspx?ReportName=PharmacyItem&ReportTitle=Vendor Pharmacy Item&ID=' + id;
            }
            window.open(url, '_blank');
        }
        function LoadVendorDetail(VenId) {
            PageMethods.LoadVendorDetail(VenId, function (resp) {
                debugger;
                var data = JSON.parse(resp);
                debugger;
                $('#btnSave').val();
                if (data.IsActive == true) {
                    $("#Active").prop('checked', true);
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
                    $('#ddlPayabl').val(data.Account_ID).trigger('change');
                }, 1000);
                setTimeout(function () {
                    $('#ddlTax').val(data.TaxPayerTyp).trigger('change');
                }, 1000);
                setTimeout(function () {
                    $('#ddlCom').val(data.CompanyType_Id).trigger('change');
                }, 1000);
                LoadVendorPerson(VenId);
                LoadVendorGeneralItem(VenId);
                LoadVendorPharmacyItem(VenId);
                LoadVendorCompany(VenId);
            },
                function (error) {
                    alert(error.get_message());
                })
        }

        function GetNewVendorNo() {
            PageMethods.GetNewVendorNo(function (resp) {
                $('#txtVendorCode').val(resp);
            },
                function (error) {
                    alert(error.get_message());
                });
        }

        function LoadVendorPerson(VenId) {
            debugger
            PageMethods.LoadVendorPerson(VenId, function (resp) {
                debugger;
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
                        '<td><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="glyphicon glyphicon-trash" style="width:15px !important;font-size: 13px;color:#f30a0a;position:relative;" i=""></i></a> </td>'
                    '</tr>';
                })
                $('#tblPerson').append(rows);
            })
        }

        function LoadVendorGeneralItem(VenId) {
            debugger
            PageMethods.LoadVendorGeneralItems(VenId, function (resp) {
                debugger;
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
                        '<td><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="glyphicon glyphicon-trash" style="width:50% !important;font-size: 13px;color:#f30a0a;position:relative;" i=""></i></a></td>'
                    '</tr>';
                })
                $('#myVendorGeneralItem').append(rows);
            })
        }
        function LoadVendorPharmacyItem(VenId) {
            debugger
            PageMethods.LoadVendorPharmacyItems(VenId, function (resp) {
                debugger;
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
                        '<td><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="glyphicon glyphicon-trash" style="width:50% !important;font-size: 13px;color:#f30a0a;position:relative;" i=""></i></a></td>'
                    '</tr>';
                })
                $('#myVendorPharmacyItem').append(rows);
            })
        }

        function LoadVendorCompany(VenId) {
            debugger
            PageMethods.LoadVendorCompanies(VenId, function (resp) {
                debugger;
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
                        '<td><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="glyphicon glyphicon-trash" style="width:50% !important;font-size: 13px;color:#f30a0a;position:relative;" i=""></i></a></td>'
                    '</tr>';
                })
                $('#myVendorCompany').append(rows);
            })
        }

        $(function () {
            $("#tabs").tabs();
        });

        function Addrow() {
            debugger;
            var rows = '';
            var rowlength = tblItemDescription.rows.length;
            rows += '<tr>' +
                '<td><input type="text" id="txtPersonName' + rowlength + '" name="txtPersonName" value="" style=""/></td>' +
                '<td><input type="text" name="txtDesign" id="txtDesigsn' + rowlength + '"  value=""  style=""/></td>' +
                '<td><input type="text" name="txtphone" id="txtphone' + rowlength + '"  value=""  style=""/></td>' +
                '<td><input type="text" name="txtExt" id="txtExt' + rowlength + '"  value="" style=""/></td>' +
                '<td><input type="text" name="txtcell" id="txtcell' + rowlength + '"  value="" style="" /></td>' +
                '<td><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="glyphicon glyphicon-trash" style="width:15px !important;font-size: 13px;color:#f30a0a;position:relative;" i=""></i></a> </td>'
            '</tr>';
            $('#tblPerson').append(rows);
        }

        function AppendvendorGeneralItem() {
            debugger;
            var rows = '';
            var rowlength = VendorGeneralItemlist.rows.length;
            rows += '<tr>' +
                '<td><select class="form-control" id="txtItemCode' + rowlength + '" name="txtItemCode" style="width:100% !important;font-size: 10px !important;" onchange="GetGeneralItemDetail(this)"></select></td>' +
                '<td><input type="text" name="txtItemname" id="txtItemname' + rowlength + '"  value=""  style="width:100% !important;font-size:9px;"/></td>' +
                '<td><input type="text" name="txtUom" id="txtUom' + rowlength + '"  value=""  style="width:100% !important;font-size:10px;"/></td>' +
                '<td><input type="text" name="txtRate" id="txtRate' + rowlength + '"  value="" style="width:100% !important;font-size:10px;"/></td>' +
                '<td><input type="text" name="txtRef" id="txtRef' + rowlength + '"  value=""  style="width:100% !important;font-size:9px;"/></td>' +
                '<td><input type="text" name="txtRemarks" id="txtRemarks' + rowlength + '"  value="" style="width:100% !important;font-size:9px;" /></td>' +
                '<td><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="glyphicon glyphicon-trash" style="width:50% !important;font-size: 13px;color:#f30a0a;position:relative;" i=""></i></a></td>'
            '</tr>';
            $('#myVendorGeneralItem').append(rows);
            loadGeneralItemList(rowlength);
        }
        function AppendvendorPharmacyItem() {
            debugger;
            var rows = '';
            var rowlength = VendorPharmacyItemlist.rows.length;
            rows += '<tr>' +
                '<td><select class="form-control" id="txtItemCode' + rowlength + '" name="txtItemCode" style="width:100% !important;font-size: 10px !important;" onchange="GetPharmacyItemDetail(this)"></select></td>' +
                '<td><input type="text" name="txtItemname" id="txtItemname' + rowlength + '"  value=""  style="width:100% !important;font-size:9px;"/></td>' +
                '<td><input type="text" name="txtUom" id="txtUom' + rowlength + '"  value=""  style="width:100% !important;font-size:10px;"/></td>' +
                '<td><input type="text" name="txtRate" id="txtRate' + rowlength + '"  value="" style="width:100% !important;font-size:10px;"/></td>' +
                '<td><input type="text" name="txtRef" id="txtRef' + rowlength + '"  value=""  style="width:100% !important;font-size:9px;"/></td>' +
                '<td><input type="text" name="txtRemarks" id="txtRemarks' + rowlength + '"  value="" style="width:100% !important;font-size:9px;" /></td>' +
                '<td><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="glyphicon glyphicon-trash" style="width:50% !important;font-size: 13px;color:#f30a0a;position:relative;" i=""></i></a></td>'
            '</tr>';
            $('#myVendorPharmacyItem').append(rows);
            loadPharmacyItemList(rowlength);
        }
        var currentSrNo = 1;
        function AppendvendorCompany() {
            debugger;
            var rows = '';
            var rowlength = VendorCompanieslist.rows.length;
            rows += '<tr>' +
                '<td><input type="text" readonly name="txtSrNO" id="txtSrNO' + rowlength + '"  value="' + currentSrNo + '"  style="width:100% !important;font-size:10px;"/></td>' +
                '<td><input type="text" name="txtCompanyName" id="txtCompanyName' + rowlength + '"  value="" style="width:100% !important;font-size:10px;" /></td>' +
                '<td><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="glyphicon glyphicon-trash" style="width:50% !important;font-size: 13px;color:#f30a0a;position:relative;" i=""></i></a></td>'
            '</tr>';
            $('#myVendorCompany').append(rows);
            currentSrNo++;
        }
        function ExcludeFromPayment(anchor) {
            debugger;
            var a = confirm("Are you sure You want to delete");
            if (a == true) {
                console.clear();
                var row = $(anchor).parents('tr')[0];
                row.remove();
            }
        }
        function loadGeneralItemList(rowlength) {
            debugger;
            var optionsitem = '';
            var length = rowlength;
            PageMethods.loadGeneralItemList(function (resp) {
                debugger;
                optionsitem = '<option value="0">Select</option>';
                $.each(JSON.parse(resp), function (key, value) {
                    debugger;
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
            debugger;
            var optionsitem = '';
            var length = rowlength;
            PageMethods.loadPharmacyItemList(function (resp) {
                debugger;
                optionsitem = '<option value="0">Select</option>';
                $.each(JSON.parse(resp), function (key, value) {
                    debugger;
                    optionsitem += '<option value="' + value.Item_ID + '" >' + value.name + '</option>';
                });
                $('#txtItemCode' + length + '').html(optionsitem);
                $('#txtItemCode' + length + '').select2();
            },
                function (error) {
                    alert(error.get_message());
                });
        }

        function GetPharmacyItemDetail(item) {
            debugger;
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
                            '<td><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="glyphicon glyphicon-trash" style="width:50% !important;font-size: 13px;color:#f30a0a;position:relative;" i=""></i></a></td></tr>';
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
            debugger;
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
                            '<td><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="glyphicon glyphicon-trash" style="width:50% !important;font-size: 13px;color:#f30a0a;position:relative;" i=""></i></a></td></tr>';
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
            debugger;
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

            var tableGeneralItems = $('#VendorGeneralItemlist');
            var tablePharmacyItems = $('#VendorPharmacyItemlist');
            var tableCompany = $('#VendorCompanieslist');
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
                var itemId = $(value).find('td input[name=txtItemCode]').val();
                if (itemId != undefined) {
                    PharmacyItem_list.push({ 'ItemId': $(value).find('td input[name=txtItemCode]').val(), 'Rate': $(value).find('td input[name=txtRate]').val(), 'RefNo': $(value).find('td input[name=txtRef]').val(), 'Remarks': $(value).find('td input[name=txtRemarks]').val(), });
                }
            });
            tableCompany.find('tr').each(function (key, value) {
                var companyname = $(value).find('td input[name=txtCompanyName]').val();
                if (companyname != undefined) {
                    Company_list.push({ 'SRNo': $(value).find('td input[name=txtSrNO]').val(), 'CompanyName': $(value).find('td input[name=txtCompanyName]').val(), });
                }
            });
            $('#btnsave').attr('disabled', true);
            var AllItemDetail = { 'IsActive': active, 'Ismanual': Chkmanual, 'VendorId': VendorId, 'VendorName': VendorName, 'VendorType': VendorType, 'Address': Address, 'CreditDays': CreditDays, 'Country': Country, 'Region': Region, 'City': City, 'MobNo': MobNo, 'PhnNo': PhnNo, 'DrugLicenceNo': DrugLicenceNo, 'Stn': Stn, 'Ntn': Ntn, 'Cnic': Cnic, 'Email': Email, 'FocalPerson': Foc, 'PayablCode': AccountId, 'TaxTyp': TaxTyp, 'VendorCode': VendorCode, 'CompanyTyp': CompanyTyp, 'PersonList': Person_list, 'GeneralItemlist': GeneralItem_list, 'PharmacyItemlist': PharmacyItem_list, 'Companylist': Company_list };
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
        function loadPayableCode() {
            var optionsPayabl = '';
            PageMethods.loadPayableCode(function (resp) {
                optionsPayabl = '<option value="0">Please Select</option>';
                $.each(JSON.parse(resp), function (key, value) {
                    optionsPayabl += '<option value="' + value.Account_ID + '" >' + value.name + '</option>';
                });
                $('#ddlPayabl').html(optionsPayabl);
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

            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <form id="item">
        <div class="row">
            <div class="col-lg-3 col-md-6 col-sm-12">
                <label id="lblVendorCode" class="">Code</label>
                <input type="text" id="txtVendorCode" class="form-control" readonly="readonly" />
            </div>
            <div class="col-lg-3 col-md-6 col-sm-12">
                <label id="lblVendorName" class="">Supplier / Vendor Name </label>
                <input type="text" id="txtVendorName" class="form-control" />
            </div>
            <div class="col-lg-3 col-md-6 col-sm-12">
                <label id="lblVendorType">Supplier / Vendor Type </label>
                <select id="ddlVendorType"></select>
            </div>
            <div class="col-lg-3 col-md-6 col-sm-12">
                <label id="lblAddress">
                    Address
                </label>
                <input type="text" id="txtAddress" class="form-control" />
            </div>
        </div>
        <div class="row">
            <div class="col-lg-3 col-md-6 col-sm-12">
                <label id="lblCountry" class="">
                    Country
                </label>
                <input type="text" id="txtCountry" class="form-control" />
            </div>
            <div class="col-lg-3 col-md-6 col-sm-12">
                <label id="lblRegion">
                    Region
                </label>
                <select id="ddlRegion">
                </select>
            </div>

            <div class="col-lg-3 col-md-6 col-sm-12">
                <label id="lblMobno" class="">
                    Mobile #
                </label>
                <input type="text" id="txtMobno" class="form-control" />
                <input type="hidden" id="txtVendorId" name="txtVendorId" />
            </div>
            <div class="col-lg-3 col-md-6 col-sm-12">
                <label id="lblCity">
                    City
                </label>
                <input type="text" id="txtCity" class="form-control" />
            </div>
        </div>
        <div class="row">
            <div class="col-lg-3 col-md-6 col-sm-12">
                <label id="lblFoc">
                    Focal Person
                </label>
                <input type="text" id="txtFoc" class="form-control" />
            </div>
            <div class="col-lg-3 col-md-6 col-sm-12">
                <label id="lblPhno">
                    Phone #
                </label>
                <input type="text" id="txtPhno" class="form-control" />
            </div>
            <div class="col-lg-3 col-md-6 col-sm-12">
                <label id="lblCnic">
                    CNIC #
                </label>
                <input type="text" id="txtCnic" class="form-control" />
            </div>
            <div class="col-lg-3 col-md-6 col-sm-12">
                <label id="lblEmail" class="">
                    Email
                </label>
                <input type="text" id="txtEmail" class="form-control" />
            </div>
        </div>
        <div class="row">
            <div class="col-lg-3 col-md-6 col-sm-12">
                <label id="lblPayabl" class="">
                    Payable code
                </label>
                <select id="ddlPayabl" class="form-control">
                </select>
            </div>

            <div class="col-lg-3 col-md-6 col-sm-12">
                <label id="lblNtn">
                    NTN
                </label>
                <input type="text" id="txtNtn" class="form-control" />
            </div>
            <div class="col-lg-3 col-md-6 col-sm-12">
                <label id="lblStn" class="">
                    STN
                </label>
                <input type="text" id="txtStn" class="form-control" />
            </div>
            <div class="col-lg-3 col-md-6 col-sm-12">
                <label id="lblDrugLicenceNo">
                    Drug Licence #
                </label>
                <input type="text" id="txtDrugLicenceNo" class="form-control" />
            </div>
            <div class="col-lg-3 col-md-6 col-sm-12">
                <label id="lblTax">
                    Tax Payer Type
                </label>
                <select id="ddlTax" class="form-control">
                </select>
            </div>
            <div class="col-lg-3 col-md-6 col-sm-12">
                <label id="lblCom">
                    Company Type
                </label>
                <select id="ddlCom" class="form-control">
                </select>
            </div>

            <div class="col-lg-1 col-md-6 col-sm-6" style="margin-top: 2%; width: 40px">
                <div class="form-check">
                    <input type="checkbox" class="form-check-input" id="chkmanual" name="chkmanual" />
                </div>
            </div>
            <div class="col-lg-1 col-md-6 col-sm-6" style="margin-top: 2%">
                <label class="form-check-label" id="lblmanual">Manual</label>
            </div>
            <div class="col-lg-1 col-md-6 col-sm-6" style="margin-top: 2%; width: 40px">
                <div class="form-check">
                    <input type="checkbox" id="Active" class="form-check-input" name="Active" />
                </div>
            </div>
            <div class="col-lg-1 col-md-6 col-sm-6" style="margin-top: 2%">
                <label id="lblActive">Active</label>
            </div>

        </div>
    </form>

    <div id="tabs">
        <ul>
            <li><a href="#Tab-1">Persons</a></li>
            <li><a href="#Tab-2">Vendor Companies</a></li>
            <li><a href="#Tab-3">Vendor General Items</a></li>
            <li><a href="#Tab-4">Vendor Pharmacy Items</a></li>
        </ul>
        <div id="Tab-1">
            <div style="overflow-x: auto; overflow-y: auto; height: 200px;">
                <div>
                    <div class="col-lg-1 col-md-4 col-sm-12">
                        <input type="button" onclick="Addrow()" value="+" id="AddPerson" class="btn btn-primry" />
                    </div>
                    <div class="col-lg-1 col-md-4 col-sm-12">
                        <input style="display: none !important" type="button" class="btn btn-primry" onclick="printPerson()" value="Print" id="PrintPerson" />
                    </div>
                </div>
                <table class="table table-hover table-striped table-bordered" id="tblItemDescription">
                    <thead>
                        <tr>
                            <th style="width: 30px; text-align: center;">Person Name</th>
                            <th style="width: 30px; text-align: center;">Designation</th>
                            <th style="width: 40px; text-align: center; font-size: 10px;">Phone #</th>
                            <th style="width: 45px; text-align: center;">Ext #</th>
                            <th style="width: 35px; text-align: center;">Cell #</th>
                            <th style="width: 6%; text-align: center;">Action</th>
                        </tr>
                    </thead>
                    <tbody id="tblPerson">
                    </tbody>
                </table>
            </div>
        </div>

        <div id="Tab-2">
            <div style="overflow-x: auto; overflow-y: auto; height: 200px;">
                <div>
                    <div class="col-lg-1 col-md-4 col-sm-12">
                        <input type="button" class="btn btn-primry" onclick="AppendvendorCompany()" value="+" id="AddvendorCompany" />
                    </div>
                    <div class="col-lg-1 col-md-4 col-sm-12">
                        <input style="display: none !important" type="button" class="btn btn-info" onclick="printVendorCompany()" value="Print" id="PrintVendorCompany" />
                    </div>
                </div>
                <table class="table responstable" id="VendorCompanieslist" style="margin-top: 13px; font-size: 10px!important; width: 95% !important; overflow: unset;">
                    <thead>
                        <tr>
                            <th style="width: 10%;">Sr #</th>
                            <th style="width: 80%;">Company Name</th>
                            <th style="text-align: center; width: 10%;">Action</th>
                        </tr>
                    </thead>
                    <tbody id="myVendorCompany">
                    </tbody>
                </table>
            </div>
        </div>

        <div id="Tab-3">
            <div style="overflow-x: auto; overflow-y: auto; height: 200px;">
                <div>
                    <div class="col-lg-1 col-md-4 col-sm-12">
                        <input type="button" class="btn btn-primry" onclick="AppendvendorGeneralItem()" value="+" id="AddvendorGeneralItem" />
                    </div>
                    <div class="col-lg-1 col-md-4 col-sm-12">
                        <input style="display: none !important" type="button" class="btn btn-info" onclick="printvendorGeneralItem()" value="Print" id="PrintvendorGeneralItem" />
                    </div>
                </div>
                <table class="table responstable" id="VendorGeneralItemlist" style="margin-top: 13px; font-size: 10px!important; width: 95% !important; overflow: unset;">
                    <thead>
                        <tr>
                            <th style="width: 15%;">Item Code</th>
                            <th style="width: 25%;">Description</th>
                            <th style="text-align: center; width: 8%;">UOM</th>
                            <th style="text-align: center; width: 7%;">Rate</th>
                            <th style="text-align: center; width: 20%;">Ref #</th>
                            <th style="text-align: center; width: 30%;">Remarks</th>
                            <th style="text-align: center; width: 5%;">Action</th>
                        </tr>
                    </thead>
                    <tbody id="myVendorGeneralItem">
                    </tbody>
                </table>

            </div>
        </div>

        <div id="Tab-4">
            <div style="overflow-x: auto; overflow-y: auto; height: 200px;">
                <div>
                    <div class="col-lg-1 col-md-4 col-sm-6">
                        <input type="button" class="btn btn-primry" onclick="AppendvendorPharmacyItem()" value="+" id="AddvendorPharmacyItem" />
                    </div>
                    <div class="col-lg-1 col-md-4 col-sm-6">
                        <input style="display: none !important" type="button" class="btn btn-info" onclick="printPharmacyItem()" value="Print" id="PrintPharmacyItem" />
                    </div>
                </div>
                <table class="table responstable" id="VendorPharmacyItemlist" style="margin-top: 13px; font-size: 10px!important; width: 95% !important; overflow: unset;">
                    <thead>
                        <tr>
                            <th style="width: 15%;">Item Code</th>
                            <th style="width: 25%;">Description</th>
                            <th style="text-align: center; width: 8%;">UOM</th>
                            <th style="text-align: center; width: 7%;">Rate</th>
                            <th style="text-align: center; width: 20%;">Ref #</th>
                            <th style="text-align: center; width: 30%;">Remarks</th>
                            <th style="text-align: center; width: 5%;">Action</th>
                        </tr>
                    </thead>
                    <tbody id="myVendorPharmacyItem">
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <div style="margin-top: 21px;">
        <div class="row">
            <div class="col-lg-1 col-md-4 col-sm-12">
                <input type="button" class="btn btn-primry" onclick="SaveAllRecord()" value="Save" id="btnSave" />
            </div>
            <div class="col-lg-1 col-md-4 col-sm-12">
                <input type="button" class="btn-gray" value="List" onclick="window.location = 'VendorView.aspx'" />
            </div>
            <div class="col-lg-1 col-md-4 col-sm-12">
                <input type="button" class="btn btn-yellow" value="New" onclick="window.location = 'Vendor.aspx'" />
            </div>
        </div>
    </div>

</asp:Content>

