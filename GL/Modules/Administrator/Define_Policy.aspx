<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Define_Policy.aspx.cs" Inherits="PMS.Modules.Administrator.Define_Policy" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script type="text/javascript">
        $(document).ready(function () {

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
                    },
                    error: function (xhr, status, error) {
                        alert("Error: " + error);
                    }
                });
            });

        });
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
        <div class="col-lg-2 col-md-4 col-sm-6 mt-4">
            <button type="button" id="btnSave" class="btn btn-primry">Save</button>
        </div>
    </div>


</asp:Content>

