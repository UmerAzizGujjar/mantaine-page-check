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
                            <div class="meta-item"><span class="meta-label">Age:</span> <span id="lblAge">35 yrs</span></div>
                            <div class="meta-item"><span class="meta-label">Gender:</span> <span id="lblGender">Male</span></div>
                            <div class="meta-item"><span class="meta-label">Contact:</span> <span id="lblContact">0300-1234567</span></div>
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
                                    <label>Referring Department</label>
                                    <span class="readonly-text" id="txtReferredBy">Orthopedics</span>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-lg-12">
                                <div class="form-group">
                                    <label>Reason for Referral</label>
                                    <input type="text" class="form-control" id="txtReferralReason" placeholder="Enter referral reason" />
                                </div>
                            </div>
                        </div>
                        <label style="font-weight: 600; font-size: 14px; color: #555; margin-top: 4px">Vitals</label>
                        <table class="vitals-horizontal">
                            <tr>
                                <td class="v-label">Pulse</td>
                                <td class="v-value"><span id="spnPulse">--</span> bpm</td>
                                <td class="v-label">BP</td>
                                <td class="v-value"><span id="spnBP">--</span> mmHg</td>
                                <td class="v-label">Temp</td>
                                <td class="v-value"><span id="spnTemp">--</span> °F</td>
                            </tr>
                            <tr>
                                <td class="v-label">Height</td>
                                <td class="v-value"><span id="spnHeight">--</span> cm</td>
                                <td class="v-label">Weight</td>
                                <td class="v-value"><span id="spnWeight">--</span> kg</td>
                                <td class="v-label">Resp</td>
                                <td class="v-value"><span id="spnResp">--</span> /min</td>
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
                                    </select>
                                </div>
                            </div>
                            <div class="col-lg-4 col-md-4 col-sm-4">
                                <div class="form-group">
                                    <label>Mode</label>
                                    <select class="form-control" id="ddlMode">
                                        <option value="">--</option>
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
                    <span class="legend-eraser" id="eraserBtn" title="Eraser"><i class="fa fa-eraser"></i></span>
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

                <div class="grades-wrap">
                    <div class="grades-title">Muscle Power Grades</div>
                    <table class="grades-table">
                        <thead>
                            <tr><th>Grades</th><th>0</th><th>1</th><th>2</th><th>3</th><th>4</th><th>5</th></tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td>Upper Limb</td>
                                <td><input type="checkbox" id="chkUL_0" /></td>
                                <td><input type="checkbox" id="chkUL_1" /></td>
                                <td><input type="checkbox" id="chkUL_2" /></td>
                                <td><input type="checkbox" id="chkUL_3" /></td>
                                <td><input type="checkbox" id="chkUL_4" /></td>
                                <td><input type="checkbox" id="chkUL_5" /></td>
                            </tr>
                            <tr>
                                <td>Lower Limb</td>
                                <td><input type="checkbox" id="chkLL_0" /></td>
                                <td><input type="checkbox" id="chkLL_1" /></td>
                                <td><input type="checkbox" id="chkLL_2" /></td>
                                <td><input type="checkbox" id="chkLL_3" /></td>
                                <td><input type="checkbox" id="chkLL_4" /></td>
                                <td><input type="checkbox" id="chkLL_5" /></td>
                            </tr>
                        </tbody>
                    </table>
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

    <div class="row" style="margin-top: 10px">
        <div class="col-lg-3 col-md-3">
            <div class="bento-card" style="padding: 12px">
                <div class="bento-title">Diagnosis</div>
                <textarea class="form-control" id="txtDiagnosis" rows="3" placeholder="Diagnosis..."></textarea>
            </div>
        </div>
        <div class="col-lg-9 col-md-9">
            <div class="bento-card" style="padding: 12px">
                <div class="bento-title">Diagnostic Tests</div>
                <table class="diag-table">
                    <thead>
                        <tr>
                            <th>Cervical</th>
                            <th>Thoracic</th>
                            <th>Lumbar</th>
                            <th>Shoulder</th>
                            <th>Elbow</th>
                            <th>Wrist</th>
                            <th>Hip</th>
                            <th>Knee</th>
                            <th>Ankle</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td><select class="form-control" id="ddlTestCervical"><option value="">--</option><option>X-Ray</option><option>EMG/NCS</option><option>CT Scan</option><option>MRI</option><option>Ultrasound</option></select></td>
                            <td><select class="form-control" id="ddlTestThoracic"><option value="">--</option><option>X-Ray</option><option>EMG/NCS</option><option>CT Scan</option><option>MRI</option><option>Ultrasound</option></select></td>
                            <td><select class="form-control" id="ddlTestLumbar"><option value="">--</option><option>X-Ray</option><option>EMG/NCS</option><option>CT Scan</option><option>MRI</option><option>Ultrasound</option></select></td>
                            <td><select class="form-control" id="ddlTestShoulder"><option value="">--</option><option>X-Ray</option><option>EMG/NCS</option><option>CT Scan</option><option>MRI</option><option>Ultrasound</option></select></td>
                            <td><select class="form-control" id="ddlTestElbow"><option value="">--</option><option>X-Ray</option><option>EMG/NCS</option><option>CT Scan</option><option>MRI</option><option>Ultrasound</option></select></td>
                            <td><select class="form-control" id="ddlTestWrist"><option value="">--</option><option>X-Ray</option><option>EMG/NCS</option><option>CT Scan</option><option>MRI</option><option>Ultrasound</option></select></td>
                            <td><select class="form-control" id="ddlTestHip"><option value="">--</option><option>X-Ray</option><option>EMG/NCS</option><option>CT Scan</option><option>MRI</option><option>Ultrasound</option></select></td>
                            <td><select class="form-control" id="ddlTestKnee"><option value="">--</option><option>X-Ray</option><option>EMG/NCS</option><option>CT Scan</option><option>MRI</option><option>Ultrasound</option></select></td>
                            <td><select class="form-control" id="ddlTestAnkle"><option value="">--</option><option>X-Ray</option><option>EMG/NCS</option><option>CT Scan</option><option>MRI</option><option>Ultrasound</option></select></td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <div class="row" style="margin-top: 10px">
        <div class="col-lg-8 col-md-8">
            <div class="bento-card" style="padding: 12px">
                <div class="bento-title">Physical Therapy Treatment Plan</div>
                <table class="diag-table" style="margin-top: 4px">
                    <thead>
                        <tr>
                            <th style="width: 5%">Sel</th>
                            <th style="width: 18%">Treatment Modality</th>
                            <th style="width: 22%">Details</th>
                            <th style="width: 11%">Duration</th>
                            <th style="width: 11%">Frequency</th>
                            <th style="width: 11%">Intensity</th>
                            <th style="width: 11%">Start Date</th>
                            <th style="width: 11%">End Date</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr class="tx-row">
                            <td><input type="checkbox" class="tx-select" id="txSelEx" /></td>
                            <td class="tx-label" style="text-align: left">Therapeutic Exercise</td>
                            <td><input type="text" class="form-control tx-input" id="txExDetails" disabled /></td>
                            <td><input type="text" class="form-control tx-input" id="txExDuration" disabled placeholder="e.g. 30 min" /></td>
                            <td><input type="text" class="form-control tx-input" id="txExFreq" disabled placeholder="e.g. 3x/week" /></td>
                            <td><input type="text" class="form-control tx-input" id="txExIntensity" disabled placeholder="e.g. Low/Med" /></td>
                            <td><input type="text" class="form-control datepicker tx-input" id="txExStart" disabled placeholder="dd/mm/yy" /></td>
                            <td><input type="text" class="form-control datepicker tx-input" id="txExEnd" disabled placeholder="dd/mm/yy" /></td>
                        </tr>
                        <tr class="tx-row">
                            <td><input type="checkbox" class="tx-select" id="txSelEl" /></td>
                            <td class="tx-label" style="text-align: left">Electrotherapy</td>
                            <td><input type="text" class="form-control tx-input" id="txElDetails" disabled /></td>
                            <td><input type="text" class="form-control tx-input" id="txElDuration" disabled placeholder="e.g. 30 min" /></td>
                            <td><input type="text" class="form-control tx-input" id="txElFreq" disabled placeholder="e.g. 3x/week" /></td>
                            <td><input type="text" class="form-control tx-input" id="txElIntensity" disabled placeholder="e.g. Low/Med" /></td>
                            <td><input type="text" class="form-control datepicker tx-input" id="txElStart" disabled placeholder="dd/mm/yy" /></td>
                            <td><input type="text" class="form-control datepicker tx-input" id="txElEnd" disabled placeholder="dd/mm/yy" /></td>
                        </tr>
                        <tr class="tx-row">
                            <td><input type="checkbox" class="tx-select" id="txSelMan" /></td>
                            <td class="tx-label" style="text-align: left">Manual Therapy</td>
                            <td><input type="text" class="form-control tx-input" id="txManDetails" disabled /></td>
                            <td><input type="text" class="form-control tx-input" id="txManDuration" disabled placeholder="e.g. 30 min" /></td>
                            <td><input type="text" class="form-control tx-input" id="txManFreq" disabled placeholder="e.g. 3x/week" /></td>
                            <td><input type="text" class="form-control tx-input" id="txManIntensity" disabled placeholder="e.g. Low/Med" /></td>
                            <td><input type="text" class="form-control datepicker tx-input" id="txManStart" disabled placeholder="dd/mm/yy" /></td>
                            <td><input type="text" class="form-control datepicker tx-input" id="txManEnd" disabled placeholder="dd/mm/yy" /></td>
                        </tr>
                        <tr class="tx-row">
                            <td><input type="checkbox" class="tx-select" id="txSelOth" /></td>
                            <td class="tx-label" style="text-align: left">Other Modalities</td>
                            <td><input type="text" class="form-control tx-input" id="txOthDetails" disabled placeholder="Specify modality..." /></td>
                            <td><input type="text" class="form-control tx-input" id="txOthDuration" disabled placeholder="e.g. 30 min" /></td>
                            <td><input type="text" class="form-control tx-input" id="txOthFreq" disabled placeholder="e.g. 3x/week" /></td>
                            <td><input type="text" class="form-control tx-input" id="txOthIntensity" disabled placeholder="e.g. Low/Med" /></td>
                            <td><input type="text" class="form-control datepicker tx-input" id="txOthStart" disabled placeholder="dd/mm/yy" /></td>
                            <td><input type="text" class="form-control datepicker tx-input" id="txOthEnd" disabled placeholder="dd/mm/yy" /></td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
        <div class="col-lg-4 col-md-4">
            <div class="row">
                <div class="col-lg-6 col-md-6">
                    <div class="bento-card" style="padding: 12px">
                        <div class="bento-title">Goals</div>
                        <div class="ib-subtitle">Short-term</div>
                        <textarea class="form-control" id="txtShortTermGoals" rows="2" placeholder="Short-term goals..."></textarea>
                        <div class="ib-subtitle" style="margin-top: 6px">Long-term</div>
                        <textarea class="form-control" id="txtLongTermGoals" rows="2" placeholder="Long-term goals..."></textarea>
                    </div>
                </div>
                <div class="col-lg-6 col-md-6">
                    <div class="bento-card" style="padding: 12px">
                        <div class="bento-title">Home Plan</div>
                        <div class="ib-subtitle">Home Exercise Program</div>
                        <textarea class="form-control" id="txtHomeExercise" rows="2" placeholder="HEP instructions..."></textarea>
                        <div class="ib-subtitle" style="margin-top: 6px">Patient Education</div>
                        <textarea class="form-control" id="txtPatientEducation" rows="2" placeholder="Education &amp; precautions..."></textarea>
                    </div>
                </div>
                <div class="col-lg-12 col-md-12">
                    <div class="bento-card" style="padding: 12px">
                        <div class="bento-title">Follow-up</div>
                        <div class="ib-subtitle">Next Review Date</div>
                        <input type="text" class="form-control datepicker" id="txtReviewDate" placeholder="dd/mm/yy" style="margin-bottom: 6px" />
                        <div class="ib-subtitle">Reviewed By</div>
                        <select class="form-control" id="ddlReviewedBy" style="margin-bottom: 6px">
                            <option value="">-- Select --</option>
                        </select>
                        <div class="ib-subtitle">Notes</div>
                        <textarea class="form-control" id="txtReviewNotes" rows="2" placeholder="Notes..."></textarea>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <input type="hidden" id="hdnOutPatientId" value="<%=Request.QueryString["ID"] ?? "" %>" />
    <input type="hidden" id="hdnRegPatId" value="0" />

    <div class="body-save-row" style="padding: 0 15px 15px">
        <button type="button" class="btn btn-primry" id="btnSaveAssessment" onclick="saveAssessment()">Save Assessment</button>
        <button type="button" class="btn btn-gray" onclick="BodyChart.clear()">Clear Chart</button>
    </div>

    <script type="text/javascript">
        function populatePatient(d) {
            $('#hdnRegPatId').val(d.regPatId || 0);
            document.getElementById('patientDisplay').innerText = d.display;
            document.getElementById('lblAge').innerText = d.age;
            document.getElementById('lblGender').innerText = d.gender;
            document.getElementById('lblContact').innerText = d.contact;
            var refEl = document.getElementById('txtReferredBy');
            if (refEl) refEl.innerText = d.referredBy;
            document.getElementById('spnPulse').innerText = d.pulse;
            document.getElementById('spnBP').innerText = d.bp;
            document.getElementById('spnTemp').innerText = d.temp;
            document.getElementById('spnResp').innerText = d.resp;
            document.getElementById('spnHeight').innerText = d.height;
            document.getElementById('spnWeight').innerText = d.weight;
        }

        function gatherFormData() {
            function v(id) { return $('#' + id).val(); }
            function ck(id) { return $('#' + id).is(':checked') ? true : null; }
            function rv(name) { return $('input[name="' + name + '"]:checked').val() || null; }

            return {
                assessmentDate: v('txtAssessmentDate'),
                occupation: v('txtOccupation'),
                reasonForReferral: v('txtReferralReason'),
                chiefComplaint: v('txtChiefComplaint'),
                duration: v('txtDuration'),
                onset: v('ddlOnset'),
                mode: v('ddlMode'),
                condDiabetes: ck('chkDM'), condHypertension: ck('chkHTN'),
                condCardiac: ck('chkCardiac'), condSurgery: ck('chkSurgery'),
                condNeuro: ck('chkNeuro'), condResp: ck('chkResp'),
                condThyroid: ck('chkThyroid'), condArthritis: ck('chkArthritis'),
                condOther: ck('chkOtherCond'), condOtherSpec: v('txtOtherCondition'),
                surgicalHistory: v('txtSurgicalHistory'),
                currentMedications: v('txtMedications'),
                allergies: v('txtAllergies'),
                painScale: parseInt($('#hdnPainScale').val()) || null,
                painType: rv('painType'),
                bodyChartJson: v('hdnBodyMarkers'),
                postNormal: ck('chkPostNormal'), postKyphosis: ck('chkKyphosis'),
                postLordosis: ck('chkLordosis'), postScoliosis: ck('chkScoliosis'),
                postAntalgic: ck('chkAntalgic'), postOther: ck('chkPostOther'),
                postOtherSpec: v('txtPostOther'),
                mmtRight: v('txtMMT_Right'), mmtLeft: v('txtMMT_Left'),
                mmtUpperLimb: v('txtMMT_UpperLimb'), mmtLowerLimb: v('txtMMT_LowerLimb'),
                areaNeck: ck('chkAreaNeck'), areaShoulder: ck('chkAreaShoulder'),
                areaElbow: ck('chkAreaElbow'), areaWrist: ck('chkAreaWrist'),
                areaBack: ck('chkAreaBack'), areaHip: ck('chkAreaHip'),
                areaKnee: ck('chkAreaKnee'), areaAnkle: ck('chkAreaAnkle'),
                areaOther: ck('chkAreaOther'), areaOtherSpec: v('txtAreaOther'),
                aggravatingFactors: v('txtAggravating'),
                relMedication: ck('chkMedication'), relRest: ck('chkRest'),
                relExercise: ck('chkExercise'), relOther: ck('chkRelOther'),
                relOtherSpec: v('txtRelOther'),
                sensIntact: ck('chkSensIntact'), sensReduced: ck('chkSensReduced'),
                sensAbsent: ck('chkSensAbsent'), sensHyperalgesia: ck('chkSensHyper'),
                sensAllodynia: ck('chkSensAllo'),
                refNormal: ck('chkRefNormal'), refDecreased: ck('chkRefDecreased'),
                refIncreased: ck('chkRefIncreased'), refAbsent: ck('chkRefAbsent'),
                refOther: ck('chkRefOther'), refOtherSpec: v('txtRefOther'),
                specialTests: v('txtSpecialTests'),
                palpWarmth: ck('chkPalpWarmth'), palpTenderness: ck('chkPalpTenderness'),
                palpCrepitus: ck('chkPalpCrepitus'), palpSwelling: ck('chkPalpSwelling'),
                palpSpasm: ck('chkPalpSpasm'), palpTemperature: ck('chkPalpTemperature'),
                palpOther: ck('chkPalpOther'), palpOtherSpec: v('txtPalpOther'),
                dermatomeMyotome: v('txtDermatomeMyotome'),
                redTENS: ck('chkRedTENS'), redEMS: ck('chkRedEMS'),
                redUS: ck('chkRedUS'), redHeat: ck('chkRedHeat'),
                redCold: ck('chkRedCold'), redTraction: ck('chkRedTraction'),
                redMobilization: ck('chkRedMobilization'), redExercise: ck('chkRedExercise'),
                redOther: ck('chkRedOther'), redOtherSpec: v('txtRedOther'),
                diagnosis: v('txtDiagnosis'),
                diagCervical: v('ddlTestCervical'), diagThoracic: v('ddlTestThoracic'),
                diagLumbar: v('ddlTestLumbar'), diagShoulder: v('ddlTestShoulder'),
                diagElbow: v('ddlTestElbow'), diagWrist: v('ddlTestWrist'),
                diagHip: v('ddlTestHip'), diagKnee: v('ddlTestKnee'),
                diagAnkle: v('ddlTestAnkle'),
                shortTermGoals: v('txtShortTermGoals'),
                longTermGoals: v('txtLongTermGoals'),
                homeExerciseProgram: v('txtHomeExercise'),
                patientEducation: v('txtPatientEducation'),
                txExSel: ck('txSelEx'), txExDetails: v('txExDetails'),
                txExDuration: v('txExDuration'), txExFreq: v('txExFreq'),
                txExIntensity: v('txExIntensity'), txExStart: v('txExStart'), txExEnd: v('txExEnd'),
                txElSel: ck('txSelEl'), txElDetails: v('txElDetails'),
                txElDuration: v('txElDuration'), txElFreq: v('txElFreq'),
                txElIntensity: v('txElIntensity'), txElStart: v('txElStart'), txElEnd: v('txElEnd'),
                txManSel: ck('txSelMan'), txManDetails: v('txManDetails'),
                txManDuration: v('txManDuration'), txManFreq: v('txManFreq'),
                txManIntensity: v('txManIntensity'), txManStart: v('txManStart'), txManEnd: v('txManEnd'),
                txOthSel: ck('txSelOth'), txOthDetails: v('txOthDetails'),
                txOthDuration: v('txOthDuration'), txOthFreq: v('txOthFreq'),
                txOthIntensity: v('txOthIntensity'), txOthStart: v('txOthStart'), txOthEnd: v('txOthEnd'),
                nextReviewDate: v('txtReviewDate'),
                reviewedBy: parseInt(v('ddlReviewedBy')) || null,
                reviewNotes: v('txtReviewNotes')
            };
        }

        function saveAssessment() {
            var opId = parseInt($('#hdnOutPatientId').val());
            var regPatId = parseInt($('#hdnRegPatId').val());
            if (!opId) { Swal.fire({ icon: 'error', title: 'Error', text: 'No patient ID found!' }); return; }

            var data = gatherFormData();
            $('#btnSaveAssessment').prop('disabled', true).text('Saving...');

            PageMethods.SaveAssessment(opId, regPatId, JSON.stringify(data), function (r) {
                if (r.success) {
                    Swal.fire({ icon: 'success', title: r.isNew ? 'Saved' : 'Updated', text: 'Assessment ' + (r.isNew ? 'saved' : 'updated') + ' successfully!', timer: 1500, showConfirmButton: false });
                    setTimeout(function () { location.reload(); }, 1600);
                } else {
                    Swal.fire({ icon: 'error', title: 'Error', text: 'Failed to save assessment.' });
                    $('#btnSaveAssessment').prop('disabled', false).text('Save Assessment');
                }
            }, function () {
                Swal.fire({ icon: 'error', title: 'Error', text: 'Server error occurred.' });
                $('#btnSaveAssessment').prop('disabled', false).text('Save Assessment');
            });
        }

        function populateAssessment(d) {
            if (!d) return;
            function setVal(id, val) { if (val !== null && val !== undefined) $('#' + id).val(val).trigger('change'); }
            function setCk(id, val) { $('#' + id).prop('checked', val === true); }
            function setRd(name, val) { if (val) $('input[name="' + name + '"][value="' + val + '"]').prop('checked', true); }

            setVal('txtOccupation', d.occupation);
            setVal('txtReferralReason', d.reasonForReferral);
            setVal('txtChiefComplaint', d.chiefComplaint);
            setVal('txtDuration', d.duration);
            setVal('ddlOnset', d.onset);
            setVal('ddlMode', d.mode);
            setCk('chkDM', d.condDiabetes); setCk('chkHTN', d.condHypertension);
            setCk('chkCardiac', d.condCardiac); setCk('chkSurgery', d.condSurgery);
            setCk('chkNeuro', d.condNeuro); setCk('chkResp', d.condResp);
            setCk('chkThyroid', d.condThyroid); setCk('chkArthritis', d.condArthritis);
            setCk('chkOtherCond', d.condOther); setVal('txtOtherCondition', d.condOtherSpec);
            setVal('txtSurgicalHistory', d.surgicalHistory);
            setVal('txtMedications', d.currentMedications);
            setVal('txtAllergies', d.allergies);
            if (d.painScale !== null && d.painScale !== undefined) {
                $('.pain-circle[data-value="' + d.painScale + '"]').click();
            }
            setRd('painType', d.painType);
            if (d.bodyChartJson) {
                try { BodyChart.markers = JSON.parse(d.bodyChartJson); BodyChart.renderAll(); $('#hdnBodyMarkers').val(d.bodyChartJson); } catch (e) { }
            }
            setCk('chkPostNormal', d.postNormal); setCk('chkKyphosis', d.postKyphosis);
            setCk('chkLordosis', d.postLordosis); setCk('chkScoliosis', d.postScoliosis);
            setCk('chkAntalgic', d.postAntalgic); setCk('chkPostOther', d.postOther);
            setVal('txtPostOther', d.postOtherSpec);
            setVal('txtMMT_Right', d.mmtRight); setVal('txtMMT_Left', d.mmtLeft);
            setVal('txtMMT_UpperLimb', d.mmtUpperLimb); setVal('txtMMT_LowerLimb', d.mmtLowerLimb);
            setCk('chkAreaNeck', d.areaNeck); setCk('chkAreaShoulder', d.areaShoulder);
            setCk('chkAreaElbow', d.areaElbow); setCk('chkAreaWrist', d.areaWrist);
            setCk('chkAreaBack', d.areaBack); setCk('chkAreaHip', d.areaHip);
            setCk('chkAreaKnee', d.areaKnee); setCk('chkAreaAnkle', d.areaAnkle);
            setCk('chkAreaOther', d.areaOther); setVal('txtAreaOther', d.areaOtherSpec);
            setVal('txtAggravating', d.aggravatingFactors);
            setCk('chkMedication', d.relMedication); setCk('chkRest', d.relRest);
            setCk('chkExercise', d.relExercise); setCk('chkRelOther', d.relOther);
            setVal('txtRelOther', d.relOtherSpec);
            setCk('chkSensIntact', d.sensIntact); setCk('chkSensReduced', d.sensReduced);
            setCk('chkSensAbsent', d.sensAbsent); setCk('chkSensHyper', d.sensHyperalgesia);
            setCk('chkSensAllo', d.sensAllodynia);
            setCk('chkRefNormal', d.refNormal); setCk('chkRefDecreased', d.refDecreased);
            setCk('chkRefIncreased', d.refIncreased); setCk('chkRefAbsent', d.refAbsent);
            setCk('chkRefOther', d.refOther); setVal('txtRefOther', d.refOtherSpec);
            setVal('txtSpecialTests', d.specialTests);
            setCk('chkPalpWarmth', d.palpWarmth); setCk('chkPalpTenderness', d.palpTenderness);
            setCk('chkPalpCrepitus', d.palpCrepitus); setCk('chkPalpSwelling', d.palpSwelling);
            setCk('chkPalpSpasm', d.palpSpasm); setCk('chkPalpTemperature', d.palpTemperature);
            setCk('chkPalpOther', d.palpOther); setVal('txtPalpOther', d.palpOtherSpec);
            setVal('txtDermatomeMyotome', d.dermatomeMyotome);
            setCk('chkRedTENS', d.redTENS); setCk('chkRedEMS', d.redEMS);
            setCk('chkRedUS', d.redUS); setCk('chkRedHeat', d.redHeat);
            setCk('chkRedCold', d.redCold); setCk('chkRedTraction', d.redTraction);
            setCk('chkRedMobilization', d.redMobilization); setCk('chkRedExercise', d.redExercise);
            setCk('chkRedOther', d.redOther); setVal('txtRedOther', d.redOtherSpec);
            setVal('txtDiagnosis', d.diagnosis);
            setVal('ddlTestCervical', d.diagCervical); setVal('ddlTestThoracic', d.diagThoracic);
            setVal('ddlTestLumbar', d.diagLumbar); setVal('ddlTestShoulder', d.diagShoulder);
            setVal('ddlTestElbow', d.diagElbow); setVal('ddlTestWrist', d.diagWrist);
            setVal('ddlTestHip', d.diagHip); setVal('ddlTestKnee', d.diagKnee);
            setVal('ddlTestAnkle', d.diagAnkle);
            setVal('txtShortTermGoals', d.shortTermGoals);
            setVal('txtLongTermGoals', d.longTermGoals);
            setVal('txtHomeExercise', d.homeExerciseProgram);
            setVal('txtPatientEducation', d.patientEducation);
            setVal('txtReviewDate', d.nextReviewDate);
            if (d.reviewedBy) { $('#ddlReviewedBy').val(d.reviewedBy).trigger('change'); }
            setVal('txtReviewNotes', d.reviewNotes);

            function txPop(id, val) {
                setVal(id, val);
                var $el = $('#' + id);
                if (val !== null && val !== undefined && val !== '') {
                    var $row = $el.closest('.tx-row');
                    var $sel = $row.find('.tx-select');
                    $sel.prop('checked', true);
                    $row.find('.tx-input').prop('disabled', false);
                }
            }
            txPop('txExDetails', d.txExDetails); txPop('txExDuration', d.txExDuration);
            txPop('txExFreq', d.txExFreq); txPop('txExIntensity', d.txExIntensity);
            txPop('txExStart', d.txExStart); txPop('txExEnd', d.txExEnd);
            txPop('txElDetails', d.txElDetails); txPop('txElDuration', d.txElDuration);
            txPop('txElFreq', d.txElFreq); txPop('txElIntensity', d.txElIntensity);
            txPop('txElStart', d.txElStart); txPop('txElEnd', d.txElEnd);
            txPop('txManDetails', d.txManDetails); txPop('txManDuration', d.txManDuration);
            txPop('txManFreq', d.txManFreq); txPop('txManIntensity', d.txManIntensity);
            txPop('txManStart', d.txManStart); txPop('txManEnd', d.txManEnd);
            txPop('txOthDetails', d.txOthDetails); txPop('txOthDuration', d.txOthDuration);
            txPop('txOthFreq', d.txOthFreq); txPop('txOthIntensity', d.txOthIntensity);
            txPop('txOthStart', d.txOthStart); txPop('txOthEnd', d.txOthEnd);

            $('#btnSaveAssessment').text('Update Assessment');
        }

        var BodyChart = {
            activeColor: '#e74c3c',
            markers: { front: [], back: [] },
            proximityThreshold: 6,
            erasing: false,

            init: function () {
                var self = this;

                $('.legend-color').on('click', function () {
                    $('.legend-color').removeClass('active');
                    $('#eraserBtn').removeClass('active');
                    self.erasing = false;
                    $(this).addClass('active');
                    self.activeColor = $(this).data('color');
                    if (self.activeColor === '#2ecc71') {
                        $('#legendOtherRow').show();
                    } else {
                        $('#legendOtherRow').hide();
                    }
                });

                $('#eraserBtn').on('click', function () {
                    $(this).toggleClass('active');
                    self.erasing = $(this).hasClass('active');
                    if (self.erasing) {
                        $('.legend-color').removeClass('active');
                        $('#legendOtherRow').hide();
                    }
                });

                $('.body-image-wrap').on('mousedown', function (e) {
                    if (e.target.tagName !== 'IMG') return;
                    var side = $(this).data('side');
                    var offset = $(this).offset();
                    var w = $(this).width();
                    var h = $(this).height();
                    var px = e.pageX - offset.left;
                    var py = e.pageY - offset.top;
                    var relX = px / w;
                    var relY = py / h;

                    if (self.erasing) {
                        self.eraseNear(side, relX, relY);
                        return;
                    }

                    self.addMarker(side, relX, relY);
                    self._drawSide = side;
                    self._drawing = true;
                    self._lastX = relX;
                    self._lastY = relY;
                });

                $('.body-image-wrap').on('mousemove', function (e) {
                    if (!self._drawing) return;
                    var offset = $(this).offset();
                    var w = $(this).width();
                    var h = $(this).height();
                    var px = e.pageX - offset.left;
                    var py = e.pageY - offset.top;
                    var relX = px / w;
                    var relY = py / h;
                    var dx = relX - self._lastX;
                    var dy = relY - self._lastY;
                    if (Math.sqrt(dx*dx + dy*dy) > 0.02) {
                        self.addMarker(self._drawSide, relX, relY);
                        self._lastX = relX;
                        self._lastY = relY;
                    }
                });

                $(document).on('mouseup', function () {
                    self._drawing = false;
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
            },

            eraseNear: function (side, relX, relY) {
                var arr = this.markers[side];
                var closest = -1;
                var minDist = 999;
                for (var i = 0; i < arr.length; i++) {
                    var dx = (arr[i].x - relX) * 100;
                    var dy = (arr[i].y - relY) * 100;
                    var dist = Math.sqrt(dx * dx + dy * dy);
                    if (dist < minDist) {
                        minDist = dist;
                        closest = i;
                    }
                }
                if (closest > -1 && minDist < 15) {
                    arr.splice(closest, 1);
                    this.renderAll();
                }
            }
        };

        function loadDoctors() {
            PageMethods.LoadDoctors(function (res) {
                var opts = '<option value="">-- Select --</option>';
                $.each(res, function (_, d) {
                    opts += '<option value="' + d.Emp_ID + '">' + d.Emp_Name + '</option>';
                });
                $('#ddlReviewedBy').html(opts).select2();
            });
        }

        function loadDropdown(id, valueSetName) {
            PageMethods.LoadDataValues(valueSetName, function (res) {
                var opts = '<option value="">--</option>';
                $.each(res, function (_, it) {
                    opts += '<option value="' + it.DataValue_Name + '">' + it.DataValue_Description + '</option>';
                });
                $(id).html(opts);
            });
        }

        $(document).ready(function () {
            var now = new Date();
            var dd = ('0' + now.getDate()).slice(-2);
            var mm = ('0' + (now.getMonth() + 1)).slice(-2);
            var yyyy = now.getFullYear();
            $('#txtAssessmentDate').val(dd + '/' + mm + '/' + yyyy);

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
                $row.find('.tx-input').prop('disabled', !enabled).val('');
            });

            loadDoctors();
            loadDropdown('#ddlOnset', 'Onset');
            loadDropdown('#ddlMode', 'Mode');

            BodyChart.init();
        });
    </script>

</asp:Content>
