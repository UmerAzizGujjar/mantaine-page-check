<%@ Page Title="Physiotherapy Assessment" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Physiotherapy_Assessment.aspx.cs" Inherits="PMS.Modules.PatientManagement.Physiotherapy_Assessment" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/PhysiotherapyAssessment.css" rel="stylesheet" />

</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="row">
        <div class="col-lg-8 col-md-8">

            <div class="row">
                <div class="col-lg-6 col-md-6">

                    <div class="bento-card">
                        <div class="bento-title">Patient Information</div>
                        <div class="patient-header" id="patientDisplay">MR-2024-001 - John Doe</div>
                        <div class="patient-meta">
                            <div class="meta-item"><span class="meta-label">Age:</span> 35 yrs</div>
                            <div class="meta-item"><span class="meta-label">Gender:</span> Male</div>
                            <div class="meta-item"><span class="meta-label">Contact:</span> 0300-1234567</div>
                            <div class="meta-item">
                                <span class="meta-label">Occupation:</span>
                                <input type="text" class="occ-inline" id="txtOccupation" placeholder="--" />
                            </div>
                        </div>
                    </div>

                    <div class="bento-card">
                        <div class="bento-title">Medical History</div>
                        <div class="form-group">
                            <label>Conditions</label>
                            <div class="chk-grid">
                                <label class="chk-item">
                                    <input type="checkbox" id="chkDM" />
                                    Diabetes</label>
                                <label class="chk-item">
                                    <input type="checkbox" id="chkHTN" />
                                    Hypertension</label>
                                <label class="chk-item">
                                    <input type="checkbox" id="chkCardiac" />
                                    Cardiac</label>
                                <label class="chk-item">
                                    <input type="checkbox" id="chkSurgery" />
                                    Past Surgery</label>
                                <label class="chk-item">
                                    <input type="checkbox" id="chkNeuro" />
                                    Neurological</label>
                                <label class="chk-item">
                                    <input type="checkbox" id="chkResp" />
                                    Respiratory</label>
                                <label class="chk-item">
                                    <input type="checkbox" id="chkThyroid" />
                                    Thyroid</label>
                                <label class="chk-item">
                                    <input type="checkbox" id="chkArthritis" />
                                    Arthritis</label>
                            </div>
                            <div style="margin-top: 2px">
                                <label class="chk-inline">
                                    <input type="checkbox" id="chkOtherCond" />
                                    Other
                                    <input type="text" class="other-input" id="txtOtherCondition" placeholder="Specify" /></label>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-lg-6 col-md-6 col-sm-6">
                                <div class="form-group">
                                    <label>Past Surgical History</label>
                                    <textarea class="form-control" id="txtSurgicalHistory" rows="2" placeholder="Details..."></textarea>
                                </div>
                            </div>
                            <div class="col-lg-6 col-md-6 col-sm-6">
                                <div class="form-group">
                                    <label>Current Medications</label>
                                    <textarea class="form-control" id="txtMedications" rows="2" placeholder="List medications..."></textarea>
                                </div>
                            </div>
                        </div>
                        <div class="form-group">
                            <label>Allergies</label>
                            <textarea class="form-control" id="txtAllergies" rows="2" placeholder="List allergies..."></textarea>
                        </div>
                    </div>

                </div>
                <div class="col-lg-6 col-md-6">

                    <div class="bento-card">
                        <div class="bento-title">Assessment Details</div>
                        <div class="row">
                            <div class="col-lg-6 col-md-6 col-sm-6">
                                <div class="form-group">
                                    <label>Date</label>
                                    <input type="text" class="form-control datepicker" id="txtAssessmentDate" placeholder="DD/MM/YYYY" />
                                </div>
                            </div>
                            <div class="col-lg-6 col-md-6 col-sm-6">
                                <div class="form-group">
                                    <label>Referring Doctor</label>
                                    <span class="readonly-text" id="txtReferredBy">Dr. Smith</span>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-lg-12">
                                <div class="form-group">
                                    <label>Reason for Referral</label>
                                    <span class="readonly-text" id="txtReferralReason">Low back pain with radiculopathy</span>
                                </div>
                            </div>
                        </div>
                        <label style="font-weight: 600; font-size: 14px; color: #555; margin-top: 4px">Vitals</label>
                        <table class="vitals-horizontal">
                            <tr>
                                <td class="v-label">Pulse</td>
                                <td class="v-value">-- bpm</td>
                                <td class="v-label">BP</td>
                                <td class="v-value">-- mmHg</td>
                                <td class="v-label">Temp</td>
                                <td class="v-value">-- °F</td>
                            </tr>
                            <tr>
                                <td class="v-label">Height</td>
                                <td class="v-value">-- cm</td>
                                <td class="v-label">Weight</td>
                                <td class="v-value">-- kg</td>
                                <td class="v-label">Resp</td>
                                <td class="v-value">-- /min</td>
                            </tr>
                        </table>
                    </div>

                    <div class="bento-card">
                        <div class="bento-title">Chief Complaint</div>
                        <div class="form-group">
                            <label>Primary Complaint</label>
                            <textarea class="form-control" id="txtChiefComplaint" rows="3" placeholder="Describe the primary complaint..."></textarea>
                        </div>
                        <div class="row">
                            <div class="col-lg-4 col-md-4 col-sm-4">
                                <div class="form-group">
                                    <label>Duration</label>
                                    <input type="text" class="form-control" id="txtDuration" placeholder="e.g. 2 weeks" />
                                </div>
                            </div>
                            <div class="col-lg-4 col-md-4 col-sm-4">
                                <div class="form-group">
                                    <label>Onset</label>
                                    <select class="form-control" id="ddlOnset">
                                        <option value="">--</option>
                                        <option value="Sudden">Sudden</option>
                                        <option value="Gradual">Gradual</option>
                                    </select>
                                </div>
                            </div>
                            <div class="col-lg-4 col-md-4 col-sm-4">
                                <div class="form-group">
                                    <label>Mode</label>
                                    <select class="form-control" id="ddlMode">
                                        <option value="">--</option>
                                        <option value="Traumatic">Traumatic</option>
                                        <option value="Non-Traumatic">Non-Traumatic</option>
                                        <option value="Repetitive Strain">Repetitive Strain</option>
                                    </select>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="bento-card" style="padding: 10px; margin-top: 16px; margin-bottom: 6px">
                <div class="bento-title">Physical Examination</div>
                <div class="row attached-row">
                    <div class="col-lg-5 col-md-5">
                        <div class="inner-bento">
                            <div class="ib-title">Pain Scale</div>
                            <div class="pain-scale-compact">
                                <div class="pain-circle" data-value="0" style="background: #27ae60">0</div>
                                <div class="pain-circle" data-value="1" style="background: #2ecc71">1</div>
                                <div class="pain-circle" data-value="2" style="background: #7dcea0">2</div>
                                <div class="pain-circle" data-value="3" style="background: #f1c40f">3</div>
                                <div class="pain-circle" data-value="4" style="background: #f39c12">4</div>
                                <div class="pain-circle" data-value="5" style="background: #e67e22">5</div>
                                <div class="pain-circle" data-value="6" style="background: #d35400">6</div>
                                <div class="pain-circle" data-value="7" style="background: #e74c3c">7</div>
                                <div class="pain-circle" data-value="8" style="background: #c0392b">8</div>
                                <div class="pain-circle" data-value="9" style="background: #a93226">9</div>
                                <div class="pain-circle" data-value="10" style="background: #8e281e">10</div>
                            </div>
                            <input type="hidden" id="hdnPainScale" />
                            <div style="margin-top: 2px" class="chk-grid">
                                <label class="chk-item">
                                    <input type="radio" name="painType" id="chkSharp" />
                                    Sharp</label>
                                <label class="chk-item">
                                    <input type="radio" name="painType" id="chkBurning" />
                                    Burning</label>
                                <label class="chk-item">
                                    <input type="radio" name="painType" id="chkThrobbing" />
                                    Throbbing</label>
                                <label class="chk-item">
                                    <input type="radio" name="painType" id="chkDull" />
                                    Dull</label>
                                <label class="chk-item">
                                    <input type="radio" name="painType" id="chkRadiating" />
                                    Radiating</label>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-4 col-md-4">
                        <div class="inner-bento">
                            <div class="ib-title">Posture &amp; Gait</div>
                            <div class="chk-grid">
                                <label class="chk-item">
                                    <input type="checkbox" id="chkPostNormal" />
                                    Normal</label>
                                <label class="chk-item">
                                    <input type="checkbox" id="chkKyphosis" />
                                    Kyphosis</label>
                                <label class="chk-item">
                                    <input type="checkbox" id="chkLordosis" />
                                    Lordosis</label>
                                <label class="chk-item">
                                    <input type="checkbox" id="chkScoliosis" />
                                    Scoliosis</label>
                                <label class="chk-item">
                                    <input type="checkbox" id="chkAntalgic" />
                                    Antalgic Gait</label>
                            </div>
                            <div style="margin-top: 2px">
                                <label class="chk-inline">
                                    <input type="checkbox" id="chkPostOther" />
                                    Other
                                    <input type="text" class="other-input" id="txtPostOther" placeholder="Specify" /></label>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-3 col-md-3">
                        <div class="inner-bento">
                            <div class="ib-title">MMT</div>
                            <div class="mmt-list">
                                <div class="mmt-row"><span class="mmt-name">Right</span><input type="text" class="mmt-input" id="txtMMT_Right" /></div>
                                <div class="mmt-row"><span class="mmt-name">Left</span><input type="text" class="mmt-input" id="txtMMT_Left" /></div>
                                <div class="mmt-row"><span class="mmt-name">Upper Limb</span><input type="text" class="mmt-input" id="txtMMT_UpperLimb" /></div>
                                <div class="mmt-row"><span class="mmt-name">Lower Limb</span><input type="text" class="mmt-input" id="txtMMT_LowerLimb" /></div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row attached-row">
                    <div class="col-lg-5 col-md-5">
                        <div class="inner-bento">
                            <div class="ib-title">Affected Area</div>
                            <div class="chk-grid">
                                <label class="chk-item">
                                    <input type="checkbox" id="chkAreaNeck" />
                                    Neck</label>
                                <label class="chk-item">
                                    <input type="checkbox" id="chkAreaShoulder" />
                                    Shoulder</label>
                                <label class="chk-item">
                                    <input type="checkbox" id="chkAreaElbow" />
                                    Elbow</label>
                                <label class="chk-item">
                                    <input type="checkbox" id="chkAreaWrist" />
                                    Wrist</label>
                                <label class="chk-item">
                                    <input type="checkbox" id="chkAreaBack" />
                                    Back</label>
                                <label class="chk-item">
                                    <input type="checkbox" id="chkAreaHip" />
                                    Hip</label>
                                <label class="chk-item">
                                    <input type="checkbox" id="chkAreaKnee" />
                                    Knee</label>
                                <label class="chk-item">
                                    <input type="checkbox" id="chkAreaAnkle" />
                                    Ankle</label>
                            </div>
                            <div style="margin-top: 2px">
                                <label class="chk-inline">
                                    <input type="checkbox" id="chkAreaOther" />
                                    Other
                                    <input type="text" class="other-input" id="txtAreaOther" placeholder="Specify" /></label>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-4 col-md-4">
                        <div class="inner-bento">
                            <div class="ib-title">Range of Motion</div>
                            <table class="rom-grid">
                                <thead>
                                    <tr>
                                        <th>Movement</th>
                                        <th>L</th>
                                        <th>R</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td>Flexion</td>
                                        <td>
                                            <input type="text" class="form-control" id="txtROM_Flex_L" /></td>
                                        <td>
                                            <input type="text" class="form-control" id="txtROM_Flex_R" /></td>
                                    </tr>
                                    <tr>
                                        <td>Extension</td>
                                        <td>
                                            <input type="text" class="form-control" id="txtROM_Ext_L" /></td>
                                        <td>
                                            <input type="text" class="form-control" id="txtROM_Ext_R" /></td>
                                    </tr>
                                    <tr>
                                        <td>Abduction</td>
                                        <td>
                                            <input type="text" class="form-control" id="txtROM_Abd_L" /></td>
                                        <td>
                                            <input type="text" class="form-control" id="txtROM_Abd_R" /></td>
                                    </tr>
                                    <tr>
                                        <td>Adduction</td>
                                        <td>
                                            <input type="text" class="form-control" id="txtROM_Add_L" /></td>
                                        <td>
                                            <input type="text" class="form-control" id="txtROM_Add_R" /></td>
                                    </tr>
                                    <tr>
                                        <td>Rotation</td>
                                        <td>
                                            <input type="text" class="form-control" id="txtROM_Rot_L" /></td>
                                        <td>
                                            <input type="text" class="form-control" id="txtROM_Rot_R" /></td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                    <div class="col-lg-3 col-md-3">
                        <div class="inner-bento">
                            <div class="ib-title">Aggravating &amp; Relieving</div>
                            <div class="ib-subtitle">Aggravating</div>
                            <textarea class="agg-text" id="txtAggravating" rows="2" placeholder="Aggravating factors..."></textarea>
                            <div class="ib-subtitle" style="margin-top: 2px">Relieving</div>
                            <div class="chk-grid">
                                <label class="chk-item">
                                    <input type="checkbox" id="chkMedication" />
                                    Med</label>
                                <label class="chk-item">
                                    <input type="checkbox" id="chkRest" />
                                    Rest</label>
                                <label class="chk-item">
                                    <input type="checkbox" id="chkExercise" />
                                    Exer</label>
                            </div>
                            <div style="margin-top: 2px">
                                <label class="chk-inline">
                                    <input type="checkbox" id="chkRelOther" />
                                    Other
                                    <input type="text" class="other-input" id="txtRelOther" placeholder="Specify" /></label>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row attached-row">
                    <div class="col-lg-5 col-md-5">
                        <div class="inner-bento">
                            <div class="ib-title">Sensation</div>
                            <div class="chk-grid">
                                <label class="chk-item">
                                    <input type="checkbox" id="chkSensIntact" />
                                    Intact</label>
                                <label class="chk-item">
                                    <input type="checkbox" id="chkSensReduced" />
                                    Reduced</label>
                                <label class="chk-item">
                                    <input type="checkbox" id="chkSensAbsent" />
                                    Absent</label>
                                <label class="chk-item">
                                    <input type="checkbox" id="chkSensHyper" />
                                    Hyperalgesia</label>
                                <label class="chk-item">
                                    <input type="checkbox" id="chkSensAllo" />
                                    Allodynia</label>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-4 col-md-4">
                        <div class="inner-bento">
                            <div class="ib-title">Reflexes</div>
                            <div class="chk-grid">
                                <label class="chk-item">
                                    <input type="checkbox" id="chkRefNormal" />
                                    Normal</label>
                                <label class="chk-item">
                                    <input type="checkbox" id="chkRefDecreased" />
                                    Decreased</label>
                                <label class="chk-item">
                                    <input type="checkbox" id="chkRefIncreased" />
                                    Increased</label>
                                <label class="chk-item">
                                    <input type="checkbox" id="chkRefAbsent" />
                                    Absent</label>
                            </div>
                            <div style="margin-top: 2px">
                                <label class="chk-inline">
                                    <input type="checkbox" id="chkRefOther" />
                                    Other
                                    <input type="text" class="other-input" id="txtRefOther" placeholder="Specify" /></label>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-3 col-md-3">
                        <div class="inner-bento">
                            <div class="ib-title">Special Tests</div>
                            <textarea class="form-control" id="txtSpecialTests" rows="3" placeholder="e.g. SLR, Lachman&#10;Neer's, Hawkins..."></textarea>
                        </div>
                    </div>
                </div>
            </div>









        </div>
        <div class="col-lg-4 col-md-4">

            <div class="body-chart-card">
                <div class="bento-title">Body Pain Chart</div>
                <div class="body-legend">
                    <span class="legend-color active" data-color="#e74c3c" style="background: #e74c3c">Pain</span>
                    <span class="legend-color" data-color="#3498db" style="background: #3498db">Numbness</span>
                    <span class="legend-color" data-color="#f1c40f" style="background: #f1c40f">Stiffness</span>
                    <span class="legend-color" data-color="#2ecc71" style="background: #2ecc71">Other</span>
                </div>
                <div class="legend-other-row" id="legendOtherRow" style="display: none">
                    <input type="text" class="form-control" id="txtOtherPain" placeholder="Specify pain type..." />
                </div>
                <div class="body-chart-container">
                    <div class="body-view">
                        <span class="body-label">Front</span>
                        <div class="body-image-wrap" id="bodyFront" data-side="front">
                            <img src="../../wwwroot/SOURCE_IMAGES/GENERAL_ICONS/FrontPatientModel.png" alt="Front" draggable="false" />
                            <div class="body-markers" id="markersFront"></div>
                        </div>
                    </div>
                    <div class="body-view">
                        <span class="body-label">Back</span>
                        <div class="body-image-wrap" id="bodyBack" data-side="back">
                            <img src="../../wwwroot/SOURCE_IMAGES/GENERAL_ICONS/BackPatientModel.png" alt="Back" draggable="false" />
                            <div class="body-markers" id="markersBack"></div>
                        </div>
                    </div>
                </div>
                <input type="hidden" id="hdnBodyMarkers" />
                <div class="body-save-row">
                    <button type="button" class="btn btn-primry btn-sm" onclick="BodyChart.save()">Save</button>
                    <button type="button" class="btn btn-gray btn-sm" onclick="BodyChart.clear()">Clear All</button>
                </div>
            </div>

            <div class="bento-card" style="padding: 12px; margin-top: 10px">
                <div class="bento-title">On Palpation</div>
                <div class="chk-grid">
                    <label class="chk-item">
                        <input type="checkbox" id="chkPalpWarmth" />
                        Warmth</label>
                    <label class="chk-item">
                        <input type="checkbox" id="chkPalpTenderness" />
                        Tenderness</label>
                    <label class="chk-item">
                        <input type="checkbox" id="chkPalpCrepitus" />
                        Crepitus</label>
                    <label class="chk-item">
                        <input type="checkbox" id="chkPalpSwelling" />
                        Swelling</label>
                    <label class="chk-item">
                        <input type="checkbox" id="chkPalpSpasm" />
                        Spasm</label>
                    <label class="chk-item">
                        <input type="checkbox" id="chkPalpTemperature" />
                        Temperature</label>
                </div>
                <div style="margin-top: 2px">
                    <label class="chk-inline">
                        <input type="checkbox" id="chkPalpOther" />
                        Other
                        <input type="text" class="other-input" id="txtPalpOther" placeholder="Specify" /></label>
                </div>
            </div>

            <div class="bento-card" style="padding: 12px; margin-top: 10px">
                <div class="bento-title">Dermatome / Myotome</div>
                <textarea class="form-control" id="txtDermatomeMyotome" rows="4" placeholder="Findings..."></textarea>
            </div>

            <div class="bento-card" style="padding: 12px; margin-top: 10px">
                <div class="bento-title">Red Flags</div>
                <div class="chk-grid">
                    <label class="chk-item">
                        <input type="checkbox" id="chkRedTENS" />
                        TENS</label>
                    <label class="chk-item">
                        <input type="checkbox" id="chkRedEMS" />
                        EMS</label>
                    <label class="chk-item">
                        <input type="checkbox" id="chkRedUS" />
                        Ultrasound</label>
                    <label class="chk-item">
                        <input type="checkbox" id="chkRedHeat" />
                        Heat</label>
                    <label class="chk-item">
                        <input type="checkbox" id="chkRedCold" />
                        Cold</label>
                    <label class="chk-item">
                        <input type="checkbox" id="chkRedTraction" />
                        Traction</label>
                    <label class="chk-item">
                        <input type="checkbox" id="chkRedMobilization" />
                        Mobilization</label>
                    <label class="chk-item">
                        <input type="checkbox" id="chkRedExercise" />
                        Exercise</label>
                </div>
                <div style="margin-top: 2px">
                    <label class="chk-inline">
                        <input type="checkbox" id="chkRedOther" />
                        Other
                        <input type="text" class="other-input" id="txtRedOther" placeholder="Specify" /></label>
                </div>
            </div>

        </div>
    </div>

    <script type="text/javascript">
        var BodyChart = {
            activeColor: '#e74c3c',
            markers: { front: [], back: [] },
            proximityThreshold: 18,

            init: function () {
                var self = this;

                $('.legend-color').on('click', function () {
                    $('.legend-color').removeClass('active');
                    $(this).addClass('active');
                    self.activeColor = $(this).data('color');
                    if (self.activeColor === '#2ecc71') {
                        $('#legendOtherRow').show();
                    } else {
                        $('#legendOtherRow').hide();
                    }
                });

                $('.body-image-wrap').on('click', function (e) {
                    var side = $(this).data('side');
                    var offset = $(this).offset();
                    var w = $(this).width();
                    var h = $(this).height();
                    var px = e.pageX - offset.left;
                    var py = e.pageY - offset.top;
                    var relX = px / w;
                    var relY = py / h;
                    self.addMarker(side, relX, relY);
                });

                var saved = $('#hdnBodyMarkers').val();
                if (saved) {
                    try {
                        self.markers = JSON.parse(saved);
                        self.renderAll();
                    } catch (e) { }
                }
            },

            addMarker: function (side, relX, relY) {
                var self = this;
                var arr = this.markers[side];

                var dupIdx = -1;
                for (var i = 0; i < arr.length; i++) {
                    if (Math.abs(arr[i].x - relX) < 0.015 && Math.abs(arr[i].y - relY) < 0.015) {
                        dupIdx = i;
                        break;
                    }
                }
                if (dupIdx > -1) {
                    arr.splice(dupIdx, 1);
                    self.renderAll();
                    return;
                }

                var closeIdx = -1;
                for (var i = 0; i < arr.length; i++) {
                    var dx = (arr[i].x - relX) * 100;
                    var dy = (arr[i].y - relY) * 100;
                    var dist = Math.sqrt(dx * dx + dy * dy);
                    if (dist < this.proximityThreshold / 2) {
                        closeIdx = i;
                        break;
                    }
                }
                if (closeIdx > -1) {
                    arr[closeIdx].size = Math.min((arr[closeIdx].size || 8) + 3, 22);
                    self.renderAll();
                    return;
                }

                arr.push({
                    x: relX,
                    y: relY,
                    color: this.activeColor,
                    size: 8
                });

                self.renderAll();
            },

            renderAll: function () {
                var self = this;
                $('.body-markers').empty();

                $.each(['front', 'back'], function (_, side) {
                    var $container = $('#markers' + side.charAt(0).toUpperCase() + side.slice(1));
                    var $wrap = $container.closest('.body-image-wrap');
                    var w = $wrap.width();
                    var h = $wrap.height();

                    self.markers[side].forEach(function (m) {
                        var dotSize = (m.size || 8) * 2;
                        var $dot = $('<div class="body-marker"></div>');
                        $dot.css({
                            left: (m.x * 100) + '%',
                            top: (m.y * 100) + '%',
                            background: m.color,
                            width: dotSize + 'px',
                            height: dotSize + 'px',
                            marginLeft: (-dotSize / 2) + 'px',
                            marginTop: (-dotSize / 2) + 'px'
                        });
                        $container.append($dot);
                    });
                });

                $('#hdnBodyMarkers').val(JSON.stringify(this.markers));
            },

            save: function () {
                this.renderAll();
                Swal.fire({
                    icon: 'success',
                    title: 'Saved',
                    text: 'Body chart markers saved successfully!',
                    timer: 1500,
                    showConfirmButton: false
                });
            },

            clear: function () {
                var self = this;
                Swal.fire({
                    title: 'Clear all markers?',
                    text: 'This will remove all pain points from both views.',
                    icon: 'warning',
                    showCancelButton: true,
                    confirmButtonText: 'Yes, clear all',
                    cancelButtonText: 'Cancel'
                }).then(function (result) {
                    if (result.isConfirmed) {
                        self.markers = { front: [], back: [] };
                        self.renderAll();
                        Swal.fire({
                            icon: 'info',
                            title: 'Cleared',
                            timer: 1000,
                            showConfirmButton: false
                        });
                    }
                });
            }
        };

        $(document).ready(function () {
            $('.datepicker').datepicker({
                changeMonth: true,
                changeYear: true,
                dateFormat: 'dd/mm/yy'
            });

            $('.pain-circle').on('click', function () {
                $('.pain-circle').removeClass('active');
                $(this).addClass('active');
                $('#hdnPainScale').val($(this).data('value'));
            });

            $('.tx-select').on('change', function () {
                var $row = $(this).closest('.tx-row');
                var enabled = $(this).is(':checked');
                $row.find('.tx-input').prop('disabled', !enabled);
                if (!enabled) {
                    $row.find('.tx-input').val('');
                }
            });

            BodyChart.init();
        });
    </script>

</asp:Content>
