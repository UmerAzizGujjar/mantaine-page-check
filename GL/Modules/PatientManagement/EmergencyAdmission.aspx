<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="EmergencyAdmission.aspx.cs" Inherits="PMS.Modules.PatientManagement.EmergencyAdmission" %>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
        <div class="col-lg-2">
        </div>
        <div class="col-lg-10">
            <div style="display: flex; justify-content: flex-end;">
                <input type="button" class="btn btn-primry" value="WaitingList" onclick="openEmergencyWaitingListModal()" />
                <input type="button" class="btn btn-primry" value="List View" name="name" onclick="window.location = 'OutPatientsView.aspx'" />
            </div>
        </div>

    </div>
      <div class="col-lg-5">
      <!-- Patient Card -->
      <div class="row">
          <div class="col-12">
              <div class="cardd">
                  <div class="card-bodyy">
                      <div class="row">
                          <div class="col-lg-3 col-md-3 col-sm-4 text-center">
                              <div class="row">
                                  <div class="image-container">
                                      <img src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/Patient.png" alt="Patient Image" class="img-fluid patient-image" />
                                  </div>
                              </div>
                              <div class="row">
                              </div>

                          </div>
                          <div class="col-lg-9 col-md-9 col-sm-8">

                              <div class="row mb-3">
                                  <div class="col-md-5 col-sm-6">
                                      <asp:Label ID="lblPatient_Name" CssClass="labels" runat="server" Text="Patient Name:"></asp:Label>
                                  </div>
                                  <div class="col-md-7 col-sm-6">
                                      <asp:Label ID="vlblPatients_Name" CssClass="md" runat="server"></asp:Label>
                                  </div>
                              </div>

                              <div class="row mb-3">
                                  <div class="col-md-5 col-sm-6">
                                      <asp:Label ID="lblPatien_No" CssClass="labels" runat="server" Text="MR No:"></asp:Label>
                                  </div>
                                  <div class="col-md-7 col-sm-6">
                                      <asp:Label ID="Label200" CssClass="md" runat="server"></asp:Label>
                                  </div>
                              </div>

                              <div class="row mb-3">
                                  <div class="col-md-5 col-sm-6">
                                      <asp:Label ID="lblPatien_ID" CssClass="labels" runat="server" Text="Emergency No:"></asp:Label>
                                  </div>
                                  <div class="col-md-7 col-sm-6">
                                      <asp:Label ID="Label1" CssClass="md" runat="server"></asp:Label>
                                  </div>
                              </div>

                              <div class="row mb-3">
                                  <div class="col-md-5 col-sm-6">
                                      <asp:Label ID="lblAge_Years" CssClass="labels" runat="server" Text="Age (Years):"></asp:Label>
                                  </div>
                                  <div class="col-md-7 col-sm-6">
                                      <asp:Label ID="vLbl_Age" CssClass="md" runat="server"></asp:Label>
                                  </div>
                              </div>

                              <div class="row mb-3">
                                  <div class="col-md-5 col-sm-6">
                                      <asp:Label ID="lblContactNo" CssClass="labels" runat="server" Text="Contact No:"></asp:Label>
                                  </div>
                                  <div class="col-md-7 col-sm-6">
                                      <asp:Label ID="vLbl_Contact" CssClass="md" runat="server"></asp:Label>
                                  </div>
                              </div>

                              
                          </div>
                      </div>
                  </div>
              </div>
          </div>
          <hr />
      </div>
          </div>
    <!-- Row 1: Triage Area & Treatment Time -->
    <div class="form-row row">
        <div class="col-md-6 mb-3">
            <asp:Label CssClass="form-label" ID="lblPatientCondition" runat="server" Text="Triage Area"></asp:Label>
            <asp:UpdatePanel ID="UpdatePanel1" TabIndex="6" runat="server">
                <ContentTemplate>
                    <asp:DropDownList ID="ddlPatientCondition" CssClass="form-control-custom" runat="server" AppendDataBoundItems="true" onchange="checkPatientCondition(this)"></asp:DropDownList>
                </ContentTemplate>
            </asp:UpdatePanel>
        </div>
        <div class="col-md-6 mb-3">
            <asp:Label CssClass="form-label" runat="server" ID="lblTreatmentTime" Text="Treatment Time"></asp:Label>
            <asp:TextBox runat="server" CssClass="form-control-custom readonly" ID="txtTreatmentTime" ReadOnly="true"></asp:TextBox>
        </div>
    </div>

    <!-- Row 2: Admission Date & Current Room/Ward -->
    <div class="form-row row">
        <div class="col-md-6 mb-3">
            <asp:Label CssClass="form-label" ID="LblAdmission_Date" runat="server" Text="Admission Date"></asp:Label>
            <asp:TextBox ID="txtAdmission_Date" CssClass="form-control-custom readonly" runat="server" ReadOnly="true"></asp:TextBox>
        </div>
        <div class="col-md-6 mb-3">
            <asp:Label CssClass="form-label" ID="lblfee" runat="server" Text="Admission Fee"></asp:Label>
            <asp:TextBox ID="txtadmissionfee" CssClass="form-control-custom readonly" ReadOnly="true" TabIndex="8" runat="server" Enabled="true"></asp:TextBox>
        </div>
        <div class="col-md-6 mb-3" style="display: none">
            <asp:Label CssClass="form-label" runat="server" Text="Current Room/Ward"></asp:Label>
            <div class="d-flex align-items-center">
                <asp:UpdatePanel ID="UpdatePanel8" runat="server" UpdateMode="Always">
                    <ContentTemplate>
                        <asp:Label ID="vlblCurrent_Allocated_Room_Ward" runat="server" />
                        <span class="status-indicator status-available"></span>
                    </ContentTemplate>
                </asp:UpdatePanel>
                <asp:UpdatePanel ID="UpdatePanel7" runat="server">
                    <ContentTemplate>
                        <asp:Button ID="btnAllocatedRoomWardChkTriggerBtn" CssClass="btn btn-sm btn-outline-secondary ms-2" Text="Check Availability" runat="server" OnClick="btnAllocatedRoomWardChkTriggerBtn_Click" CausesValidation="false" />
                    </ContentTemplate>
                </asp:UpdatePanel>
            </div>
        </div>

    </div>

    <!-- Row 3: Department & Doctor -->
    <div class="form-row row">
        <div class="col-md-6 mb-3">
            <asp:Label CssClass="form-label" ID="LblDepartment" runat="server" Text="Department"></asp:Label>
            <div>
                <asp:DropDownList ID="ddlDepartment" CssClass="form-control-custom" TabIndex="1" runat="server" AppendDataBoundItems="true" onchange="" Enabled="false"></asp:DropDownList>
                <asp:UpdatePanel ID="UpdatePanel12" runat="server" UpdateMode="Always" Style="display: none">
                    <ContentTemplate>
                        <asp:Button ID="btnGet_Doctor" CssClass="btn btn-sm btn-outline-primary mt-2" Text="Get Doctors" runat="server" OnClick="btnGet_Doctor_Click" CausesValidation="false" />
                    </ContentTemplate>
                </asp:UpdatePanel>
            </div>
        </div>
        <div class="col-md-6 mb-3">
            <asp:Label CssClass="form-label" ID="Label26" runat="server" Text="Doctor"></asp:Label>
            <asp:UpdatePanel runat="server" TabIndex="2" ID="UpdatePanel13">
                <Triggers>
                    <asp:AsyncPostBackTrigger ControlID="ddlDepartment" />
                </Triggers>
                <ContentTemplate>
                    <asp:DropDownList ID="ddlDoctor" CssClass="form-control-custom" runat="server" AppendDataBoundItems="true"></asp:DropDownList>
                </ContentTemplate>
            </asp:UpdatePanel>
        </div>
    </div>

    <!-- Row 4: Admit To & Bed No -->
    <div class="form-row row">
        <div class="col-md-6 mb-3">
            <asp:Label ID="lblIssuance_Of" runat="server" Text="Admit To"></asp:Label>&nbsp;&nbsp;<span class="text-danger">*</span>
            <asp:UpdatePanel ID="UpdatePanel9" TabIndex="6" runat="server">
                <ContentTemplate>
                    <asp:DropDownList ID="ddlIssuance_Of" runat="server" AppendDataBoundItems="true" onChange="chkIssuance_Of_Select()" Enabled="false"></asp:DropDownList>
                </ContentTemplate>
            </asp:UpdatePanel>
            <asp:RequiredFieldValidator ID="rfvIssuance_Of" ControlToValidate="ddlIssuance_Of" InitialValue="0" runat="server" ErrorMessage="Select Admit To" Text="*"></asp:RequiredFieldValidator>
        </div>
        <div class="col-md-6 mb-3">
            <asp:Label CssClass="form-label" ID="LblBed_No" runat="server" Text="Bed No"></asp:Label>
            <asp:TextBox ID="txtBed_No" CssClass="form-control-custom" TabIndex="8" runat="server" Enabled="true"></asp:TextBox>
        </div>
    </div>

    <!-- Row 5: Ward & Admission Fee -->
    <div class="form-row row">
        <div class="col-md-6 mb-3">
            <asp:Label CssClass="form-label required" ID="lblWard_No" runat="server" Text="Ward"></asp:Label>
            <asp:UpdatePanel ID="UpdatePanel11" TabIndex="7" runat="server" UpdateMode="Always">
                <ContentTemplate>
                    <asp:DropDownList ID="ddlWard_No" CssClass="form-control-custom" runat="server" AppendDataBoundItems="true" OnChange="FillWardBeds()"></asp:DropDownList>
                </ContentTemplate>
            </asp:UpdatePanel>
        </div>
        <div class="col-md-6 mb-3">
        </div>
    </div>
       <div class="form-row row">
     <input id="btnSave" type="button" class="btn btn-primry" value="Save" onclick="SaveAdmission()" />
             </div>
    <div style="overflow-y: scroll; max-height: 150px;">
        <table id="tblWards" class="table table-responsive" style="float: right;">
            <thead>
                <tr>
                    <th>MR No</th>
                    <th>Bed No</th>
                </tr>
            </thead>
            <tbody>
            </tbody>
        </table>
    </div>
    <div id="EmergencyWaitingListModal" class="modal fade scrollable-modal" data-backdrop="static" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable" role="document">
            <div class="modal-content">
                <div class="modal-body">
                    <div id="EmergencyWaitingList">
                        <div class="row" style="margin-bottom: 15px">

                            <div class="col-lg-3">
                                <input type="text" id="SearchEmergencyWaitingList" />

                                <div class="col-lg-2">
                                    <a onclick="fillEmergencyWaitingList()">
                                        <i class="fa fa-refresh fa-2x"></i>
                                    </a>
                                </div>

                            </div>


                            <div class="table-responsive previewTable">
                                <table class="table table-bordered table-custom" id="tblEmergencyWaitingList">
                                    <thead id="ihead">
                                        <tr>
                                            <th>Emergency No</th>
                                            <th>MR No</th>
                                            <th>Patient Name</th>
                                            <th>Age</th>
                                            <th style="width: 173px;">Created Time</th>
                                            <th>Status</th>
                                            <th>Select</th>
                                        </tr>
                                    </thead>
                                    <tbody id="ibody">
                                    </tbody>
                                </table>

                            </div>
                        </div>


                    </div>
                </div>
                <div class="modal-footer">

                    <button type="button" class="btn btn-gray" data-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>
     <input style="display:none" type="text" id="hiddenPatientID" />
</asp:Content>
