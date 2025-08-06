<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Define_Policy.aspx.cs" Inherits="PMS.Modules.Administrator.Define_Policy" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script type="text/javascript">
        $(document).ready(function () {

            var Policy_ID = '<%= Request.QueryString["Policy_ID"] %>';

            if(Policy_ID && Policy_ID !== "null" && Policy_ID !== "") {
                loadPolicyForEdit(Policy_ID);
                $("#btnSave").val("Update");
            } else {
                $("#btnSave").val("Save");
            }

            $("#btnView").on("click", function () {
                window.location.href = "Define_Policy_View.aspx";
            });

            $("#btnAddNew").on("click", function () {
                window.location.href = "Define_Policy.aspx";
            });

            $("#btnSave").click(function () {
                var policy_id = $("#hdPolicyID").val();
                var policyName = $("#txt_Policy").val();
                var policyDescription = $("#txt_Policy_Description").val();
                var isActive = $("#chkActive").is(":checked");

                if (policyName === "") {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Please enter Policy Name',
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
                    url: "Define_Policy.aspx/SavePolicy",
                    data: JSON.stringify({
                        policy_id: policy_id,
                        policyName: policyName,
                        policyDescription: policyDescription,
                        active: isActive
                    }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
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
                        setTimeout(function () {
                            window.location.reload();
                        }, 2500);
                    },
                    error: function (xhr, status, error) {
                        alert("Error: " + error);
                    }
                });
            });

        });

        function loadPolicyForEdit(id) {
            $.ajax({
                type: "POST",
                url: "Define_Policy.aspx/GetPolicyById",
                data: JSON.stringify({ policy_id: id }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = JSON.parse(response.d);
                    if (data) {
                        $("#hdPolicyID").val(data.Policy_ID);
                        $("#txt_Policy").val(data.Policy_Name);
                        $("#txt_Policy_Description").val(data.Policy_Description);
                        $("#chkActive").prop("checked", data.Active);
                    }
                },
                error: function (xhr, status, error) {
                    alert("Error loading policy: " + error);
                }
            });
        }

    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <input type="hidden" id="hdPolicyID" />
    <div class="row">
        <div class="col-lg-2 col-md-4 col-sm-6">
            <label for="txt_Policy">Policy Name</label>
            <input type="text" id="txt_Policy" class="form-control" />
        </div>
        <div class="col-lg-4 col-md-4 col-sm-6">
            <label for="txt_Policy_Description">Policy Description</label>
            <input type="text" id="txt_Policy_Description" class="form-control" />
        </div>
        <div class="col-lg-1 col-md-4 col-sm-6">
            <label for="chkActive" style="font-size: 16px;">Active</label>
        </div>
        <div class="col-lg-1 col-md-4 col-sm-6">
            <input type="checkbox" style="margin-left:-93% !important" id="chkActive" checked />
        </div>
    </div>
    <div class="row">
        <div class="col-lg-8 col-md-6 col-sm-6">
            <div class="row">
                <div class="col-lg-2 col-md-4 col-sm-6">
                    <input type="button" id="btnSave" class="btn btn-primry" value="Save" />
                </div>
                <div class="col-lg-2 col-md-4 col-sm-6">
                    <input type="button" id="btnView" class="btn btn-primry" value="View" />
                </div>
                <div class="col-lg-2 col-md-4 col-sm-6">
                    <input type="button" id="btnAddNew" class="btn btn-primry" value="New" />
                </div>
            </div>
        </div>
    </div>
</asp:Content>

