<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="WardDefinition.aspx.cs" Inherits="PMS.WardDefinition" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/css/CustomCss/swalalert.css" rel="stylesheet" />

    <style type="text/css">
        .card {
            border: 1px solid #ccc;
            transition: all 0.3s ease;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 20px;
            width: 460px;
        }

            .card:hover {
                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
            }

        hr {
            width: 400px;
        }

        .card-body {
            margin-bottom: 10px;
            font-size: 14px;
        }



        input[type="text"],
        input[type="Password"] {
            margin-bottom: 8px !important;
            height: 38px;
        }
    </style>
    <script type="text/javascript">

        $(document).ready(function () {
            filldepartment();
            loadWard();
        });

        function filldepartment() {
            var options = '<option value="0">Please Select</option>';
            PageMethods.GetDepartment(function (data) {
                $.each(JSON.parse(data), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                });
                $('#ddlsubdepartment').html(options);

            });
            return options;
        }



        function saveWardDefinition() {
            var wardID = $('#<%= txtWard_ID.ClientID %>').val();
            var wardType = $('#<%= txtWard_Type.ClientID %>').val();
            var department = $('#ddlsubdepartment').val();
            var noOfBeds = $('#<%= txtNo_Of_Beds.ClientID %>').val();

            if (!department || department === "0") {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please select a Department.',
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

            if (wardType.trim() === "" || department === "0" || noOfBeds.trim() === "") {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please fill all required fields.',
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
                url: "WardDefinition.aspx/SaveWardDefinition",
                data: JSON.stringify({
                    wardID: wardID,
                    wardType: wardType,
                    department: department,
                    noOfBeds: noOfBeds
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var result = response.d;
                    if (result === "Success") {
                        Swal.fire({
                            icon: 'success',
                            title: 'Success!',
                            text: 'Data saved successfully.',
                            showConfirmButton: false,
                            timer: 2500,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });
                        setTimeout(() => window.location.href = "WardDefinitionView.aspx", 1000);
                    } else {
                        $('#lblMessage').text(result).css("color", "red");
                    }
                },
                error: function (xhr, status, error) {
                    $('#lblMessage').text("AJAX Error: " + error).css("color", "red");
                }
            });
        }

        function loadWard() {
            const urlParams = new URLSearchParams(window.location.search);
            const wardID = urlParams.get('ID');

            if (wardID) {
                PageMethods.GetWard(wardID, function (response) {
                    try {
                        const data = JSON.parse(response);
                        $('#<%= txtWard_ID.ClientID %>').val(data.Ward_ID);
                        $('#<%= txtWard_Type.ClientID %>').val(data.Ward_Type);
                        $('#ddlsubdepartment').val(data.Department);
                        $('#<%= txtNo_Of_Beds.ClientID %>').val(data.No_Of_Beds);
                        $('#btnSaveWard').val("Update");
                    } catch (e) {
                        $('#lblMessage').text("Failed to parse ward data.").css("color", "red");
                    }
                }, function (error) {
                    $('#lblMessage').text("AJAX Error: Could not fetch ward data.").css("color", "red");
                });
            }
        }

        function redirecttonew() {
            window.location.href = "WardDefinitionView.aspx";
        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
        <div class="col-lg-4"></div>
        <div class="col-lg-4">
            <div class="card">
                <div class="card-body">
                    <div class="row mt-4" style="width: 90%; margin-left: 10px">

                        <label for="txtWard_ID">Ward No</label>
                        <asp:TextBox runat="server" ID="txtWard_ID" CssClass="form-control" ReadOnly="true" Text="(New)" />


                        <label for="txtWard_Type">Ward Type *</label>
                        <asp:TextBox ID="txtWard_Type" runat="server" CssClass="form-control" />


                        <label for="ddlDepartment">Department *</label>
                        <select style="border-radius: 5px; height: 36px;" class="form-control ddldoc" id="ddlsubdepartment">
                            <option></option>
                        </select>

                        <label for="txtNo_Of_Beds">No. Of Beds *</label>
                        <asp:TextBox ID="txtNo_Of_Beds" runat="server" CssClass="form-control" />
                    </div>

                    <div class="row" style="width: 90%;">
                        <div class="col-lg-4">
                            <input type="button" style="width: 100px !important; margin-left: 10px;" class="btn btn-primry" value="View" onclick="redirecttonew()" />
                        </div>
                        <div class="col-lg-3">
                            <input type="button" style="width: 100px !important" id="btnSaveWard" class="btn btn-primry" value="Save" onclick="saveWardDefinition()" />
                        </div>





                        <span id="lblMessage" style="font-weight: bold;"></span>
                    </div>
                </div>
            </div>
        </div>
    </div>




    <%--<div class="row">
        <div class="col-lg-3 col-md-6 col-sm-12">
              <asp:Label ID="lblWard_ID" runat="server" Text="Ward No"></asp:Label>
                <asp:TextBox runat="server" ID="txtWard_ID" ReadOnly="true" Text="(New)" />
         </div>
        <div class="col-lg-3 col-md-6 col-sm-12">
             <asp:Label ID="lblWard_Type" runat="server" Text="Ward Type. *"></asp:Label>
             <asp:TextBox ID="txtWard_Type" runat="server" />
               <asp:RequiredFieldValidator ID="rfvWard_Type" ControlToValidate="txtWard_Type" runat="server" ErrorMessage="Enter Ward Type." Text="*"></asp:RequiredFieldValidator>
         </div>
        <div class="col-lg-3 col-md-6 col-sm-12">
               <asp:Label ID="lblDepartment" runat="server" Text="Department *"></asp:Label>
                <asp:DropDownList ID="ddlDepartment" runat="server" AppendDataBoundItems="true"  ></asp:DropDownList>
              <asp:RequiredFieldValidator ID="rfvDepartment" ControlToValidate="ddlDepartment" runat="server" InitialValue="0" ErrorMessage="Select Department" Text="*"></asp:RequiredFieldValidator>
         </div>
        <div class="col-lg-3 col-md-6 col-sm-12">
             <asp:Label ID="lblNo_Of_Beds" runat="server" Text="No. Of Beds *"></asp:Label>
             <asp:TextBox ID="txtNo_Of_Beds" runat="server" />
              <asp:RequiredFieldValidator ID="rfvNo_Of_Beds" ControlToValidate="txtNo_Of_Beds" runat="server" ErrorMessage="Enter No. Beds" Text="*"></asp:RequiredFieldValidator>
                <asp:RangeValidator ID="rngNo_Of_Beds" Type="Integer" runat="server" MinimumValue="0" MaximumValue="9999999" ControlToValidate="txtNo_Of_Beds" ErrorMessage="Only Enter Integer Values" Text="*"></asp:RangeValidator>
         </div>
    
    </div>
    <div class="row">
         <div class="col-lg-8">
            <div class="row">
                  <div class="col-lg-2 col-md-6 col-sm-12">
               <asp:Button Text="List" CssClass="btn btn-gray"  runat="server" ID="btnBack" CausesValidation="false" PostBackUrl="~/Modules/WardAndRooms/WardDefinitionView.aspx" />
        </div>
       
          <div class="col-lg-2 col-md-6 col-sm-12">
             <asp:Button Text="Save"  runat="server" CssClass="btn btn-primry" ID="btnSave" OnClick="btnSave_Click" />
                         <asp:Label ID="lblMessage" Text="" runat="server" />
         
        </div>
        <div class="col-lg-1 col-md-6 col-sm-12">
            <asp:ValidationSummary ID="ValidationSummary1" runat="server" ForeColor="Red" HeaderText="Page Errors"
                    ShowSummary="true" DisplayMode="List" />
        </div>
            </div>
        </div>


      
    </div>--%>
</asp:Content>


