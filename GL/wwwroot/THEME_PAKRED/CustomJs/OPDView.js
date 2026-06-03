function Print(Patient_ID) {
    window.open('../../ReportViewer.aspx?ReportName=OPD_Patient_Print&Title=OPD Patient Print &OPD_ID=' + Patient_ID);
   // window.open('../../ReportViewer.aspx?ReportName=OPD_Patient_Print_Slip&Title=OPD Patient Print &OPD_ID=' + Patient_ID);
}