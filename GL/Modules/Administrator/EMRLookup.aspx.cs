using System;
using System.Collections.Generic;
using System.Data;
using System.Web.Services;

namespace PMS.Modules.Administrator
{
    public partial class EMRLookup : System.Web.UI.Page
    {
        private const string ConnectionName = "ClientOracleConnectionString";

        // Client Oracle (EMR) - Patient Information
        private const string PatientSql = @"
SELECT P.PATIENT_STATUS_ID,
       P.MASTER_PATIENT_ID AS PATIENT_ID,
       G.DESCRIPTION AS GENDER,
       USR.NAME AS PRIMARY_PHYSICIAN_NAME,
       NVL(P.OLD_MRNO,' ') AS OLD_MRNO,
       P.FULL_NAME,
       T.DESCRIPTION AS TYPE,
       L.DESCRIPTION AS LOCATION,
       PS.DESCRIPTION AS PATIENT_STATUS,
       P.OPD_VISIT_ALLOW,
       P.VERIFICATION_STATUS,
       P.PRIMARY_PHYSICIAN_ID,
       ROUND(MONTHS_BETWEEN(TRUNC(SYSDATE),P.DOB)/12) AS AGE_YEARS,
       TRUNC(MONTHS_BETWEEN(SYSDATE,DOB)/12)||' (Y) '||
       TRUNC(MONTHS_BETWEEN(SYSDATE,DOB)-(TRUNC(MONTHS_BETWEEN(SYSDATE,DOB)/12)*12))||' (M) '||
       (TRUNC(SYSDATE)-ADD_MONTHS(DOB,TRUNC(MONTHS_BETWEEN(SYSDATE,DOB))))||' (D) ' AS AGE,
       REPLACE(NVL(P.CNIC,' '),'-','') AS CNIC,
       P.MLC, P.CONFIDENTIAL,
       P.CLIENT_ID, P.CONTACT_NO,
       CLT.DESCRIPTION AS CLIENT_NAME,
       REL.DESCRIPTION AS RELATION,
       P.CARD_STATUS, CLT.TRANSACTION_TYPE,
       NVL(CCR.DESCRIPTION,'N') AS CNIC_REQUIRED,
       NVL(CSI.DESCRIPTION,'N') AS SELECT_IT,
       NVL(CPR.DESCRIPTION,'N') AS CLT_PERFORMING_REQ,
       NVL(COV.DESCRIPTION,'N') AS OE_ONLY_OPD_VISIT,
       NVL(CIR.DESCRIPTION,'N') AS APP_INV_REQ,
       PG.ID AS CATEGORY_ID, PG.DESCRIPTION AS CATEGORY_NAME,
       P.CITY_ID,
       INFO_UPDATED, P.BLOOD_GROUP_ID,
       NVL(P.OTHER_INFO,' ') AS OTHER_INFO, P.GENDER_ID,
       NVL(RCS.DESCRIPTION,'N') AS CLIENT_RESTRICTED_STATUS,
       BLG.DESCRIPTION AS BLOOD_GROUP,
       P.RELATION_ID, P.ADMISSION_NO,
       WRD.DESCRIPTION AS WARD, WRD.ID AS WARD_ID, CTY.DESCRIPTION AS CITY,
       TO_CHAR(NVL(PAD.ADMITTED_DATE,TRUNC(SYSDATE)),'DD-MON-YY') AS ADMITTED_DATE,
       APN.NAME AS ADMITTED_PHYSICIAN,
       APN.USER_NAME AS ADMITTED_PHYSICIAN_ID,
       NVL(REL.ADDITIONAL_INFO,' ') AS RELATION_ALIAS
FROM EMR.PATIENT P,
     EMR.DEFINITION_TYPE_DETAIL T,
     EMR.DEFINITION_TYPE_DETAIL PS,
     EMR.DEFINITION_TYPE_DETAIL PG,
     EMR.DEFINITION_TYPE_DETAIL BLG,
     EMR.DEFINITION_TYPE_DETAIL REL,
     EMR.SETUP_COLUMN_DETAIL RCS,
     EMR.LOCATION L,
     EMR.WARD WRD,
     EMR.CITY CTY,
     EMR.PATIENT_ADMISSION_HISTORY PAD,
     EMR.USERS APN,
     EMR.CLIENT CLT,
     EMR.SETUP_COLUMN_DETAIL CCR,
     EMR.SETUP_COLUMN_DETAIL CSI,
     EMR.SETUP_COLUMN_DETAIL CPR,
     EMR.SETUP_COLUMN_DETAIL COV,
     EMR.SETUP_COLUMN_DETAIL CIR,
     EMR.DEFINITION_TYPE_DETAIL G,
     EMR.USERS USR
WHERE P.PATIENT_ID = :patid
  AND P.ACTIVE = 'Y'
  AND P.PATIENT_TYPE_ID = T.ID
  AND CCR.TABLE_ROW_ID = P.CLIENT_ID
  AND CCR.TABLE_COLUMN_ID = 159
  AND CSI.TABLE_ROW_ID = P.CLIENT_ID
  AND CSI.TABLE_COLUMN_ID = 150
  AND CPR.TABLE_ROW_ID = P.CLIENT_ID
  AND CPR.TABLE_COLUMN_ID = 160
  AND COV.TABLE_ROW_ID = P.CLIENT_ID
  AND COV.TABLE_COLUMN_ID = 158
  AND CIR.TABLE_ROW_ID = P.CLIENT_ID
  AND CIR.TABLE_COLUMN_ID = 161
  AND P.CATEGORY_ID = PG.ID
  AND P.RELATION_ID = REL.ID
  AND P.ADMISSION_NO = PAD.ID
  AND PAD.WARD_ID = WRD.ID
  AND PAD.PRIMARY_PHYSICIAN_ID = APN.USER_NAME
  AND P.BLOOD_GROUP_ID = BLG.ID
  AND P.CLIENT_ID = CLT.ID
  AND P.CITY_ID = CTY.ID
  AND P.PATIENT_STATUS_ID = PS.ID
  AND P.LOCATION_ID = L.ID
  AND NVL(P.PRIMARY_PHYSICIAN_ID,'GENERAL') = USR.USER_NAME
  AND P.GENDER_ID = G.ID
  AND RCS.TABLE_ROW_ID = P.CLIENT_ID
  AND RCS.TABLE_COLUMN_ID = 168
  AND P.PATIENT_ID NOT IN ('001000000000')";

        // Client Oracle (EMR) - Patient Services
        private const string ServicesSql = @"
SELECT PAT.PATIENT_ID                                           AS PATIENT_ID,
       PAT.FULL_NAME                                            AS NAME,
       NVL(PAT.OTHER_INFO,' ')                                  AS OTHER_INFO,
       PAT.CONTACT_NO,
       GEN.DESCRIPTION                                          AS GENDER,
       SAT.DESCRIPTION                                          AS STATUS,
       ROUND(MONTHS_BETWEEN(NVL(OD.REPORT_DATE,SYSDATE),PAT.DOB)/12) AS AGE,
       CPT.CPT_ID                                               AS CPT_ID,
       NVL(OD.REPORT_NAME,0)                                    AS REPORT_NAME,
       OD.DEPARTMENT_ID                                         AS DEPT_ID,
       OD.ORDER_STATUS_ID,
       IMS.ORG_ID,
       LOC.DESCRIPTION                                          AS LOCATION,
       OD.USER_ID                                               AS ORDER_BY,
       OD.SECTION_ID                                            AS SECTION,
       OD.PRICE                                                 AS CPT_PRICE,
       PAT.MLC,
       CPT.DESCRIPTION                                          AS CPT,
       CLT.DESCRIPTION                                          AS CLIENT_NAME,
       NVL(STR.DESCRIPTION,'1')                                 AS STORE_ID,
       CDR.DESCRIPTION                                          AS DISPLAY_REPORT,
       OD.COMPLETE_ORDER_NO,
       OD.ORDER_DETAIL_ID,
       NVL(IVD.REPORTING_TIME, TO_CHAR((OD.TRN_DATE+2),'DD-MON-YY')||' 7:00 PM') AS REPORTING_TIME,
       NVL(TO_CHAR(OD.TRN_DATE,'DD-MON-YY HH24:MI:SS'),'DATE')  AS ORDER_DATE,
       NVL(IMS.BALANCE_AMOUNT,0)                                AS BALANCE_AMOUNT,
       NVL(IMS.RECEIVED_AMOUNT,0)                               AS RECEIVED_AMOUNT,
       NVL(IMS.REFUND_AMOUNT,0)                                 AS REFUND_AMOUNT,
       NVL(IMS.TOTAL_AMOUNT,0)                                  AS TOTAL_AMOUNT,
       NVL(OD.PDF_REPORT_PATH,' ')                              AS PDF_REPORT,
       NVL(IMS.PAYABLE_AMOUNT,0)                                AS PAYABLE_AMOUNT,
       NVL(IMS.NET_DISCOUNT,0)                                  AS NET_DISCOUNT,
       IMS.REPORT_PENDING_AMOUNT                                AS REPORT_PENDING_AMOUNT,
       IMS.INVOICE_NO                                           AS INVOICE_NO,
       IMS.INVOICE_BY                                           AS INVOICE_BY,
       TO_CHAR(IMS.INVOICE_DATE,'DD-MON-YY HH24:MI')            AS INVOICE_DATE,
       OD.CONFIDENTIAL                                          AS REPORT_CONFIDENTIAL,
       PAT.CONFIDENTIAL                                         AS PATIENT_CONFIDENTIAL,
       NVL(MEDICAL_HISTORY,' ')                                 AS MEDICAL_HISTORY,
       NVL(PAT.ALLERGIES,' ')                                   AS ALLERGIES,
       NVL(PAT.MAJOR_PROCEDURES,' ')                            AS MAJOR_PROCEDURES,
       IMS.PAYMENT_MODE_ID,
       DEP.DESCRIPTION                                          AS DEPARTMENT
FROM EMR.ORDER_DETAIL OD
JOIN EMR.PATIENT PAT
  ON PAT.PATIENT_ID = OD.PATIENT_ID
JOIN EMR.INVOICE_MASTER IMS
  ON IMS.PATIENT_ID = OD.PATIENT_ID
JOIN EMR.INVOICE_DETAIL IVD
  ON IVD.COMPLETE_ORDER_NO = OD.COMPLETE_ORDER_NO
 AND IVD.DEPARTMENT_ID     = OD.DEPARTMENT_ID
 AND IVD.ORDER_DETAIL_ID   = OD.ORDER_DETAIL_ID
 AND IVD.INVOICE_NO        = IMS.INVOICE_NO
JOIN EMR.DEFINITION_TYPE_DETAIL GEN
  ON GEN.ID = PAT.GENDER_ID
JOIN EMR.DEFINITION_TYPE_DETAIL SAT
  ON SAT.ID = OD.ORDER_STATUS_ID
JOIN EMR.DEFINITION_TYPE_DETAIL DEP
  ON DEP.ID = OD.DEPARTMENT_ID
JOIN EMR.CPT CPT
  ON CPT.CPT_ID = OD.CPT_ID
JOIN EMR.LOCATION LOC
  ON LOC.ID = IMS.LOCATION_ID
JOIN EMR.CLIENT CLT
  ON CLT.ID = IMS.CLIENT_ID
JOIN EMR.SETUP_COLUMN_DETAIL STR
  ON STR.TABLE_ROW_ID    = OD.CPT_ID
 AND STR.TABLE_COLUMN_ID = 35
 AND STR.ORG_ID          = 332
JOIN EMR.SETUP_COLUMN_DETAIL REQ
  ON REQ.TABLE_ROW_ID    = OD.CPT_ID
 AND REQ.TABLE_COLUMN_ID = 1
 AND REQ.ORG_ID          = 332
JOIN EMR.SETUP_COLUMN_DETAIL CDR
  ON CDR.TABLE_ROW_ID    = CLT.ID
 AND CDR.TABLE_COLUMN_ID = 156
WHERE OD.PATIENT_ID IN (
        SELECT :patid FROM DUAL
        UNION ALL
        SELECT MERGE_PATIENT_ID FROM EMR.MERGE_PATIENT WHERE PATIENT_ID = :patid
      )
  AND NOT EXISTS (
        SELECT 1
        FROM EMR.USER_ACCESS_RIGHTS UAR
        WHERE UAR.USER_ID             = 'SITEADMIN'
          AND UAR.ACTION_ID           = -42
          AND UAR.USER_ACCESS_RIGHT_ID = OD.CPT_ID
      )
ORDER BY IMS.INVOICE_DATE DESC";

        // Imaging result for one complete order number (client query; order detail 1, bound as :orderno)
        private const string ImagingSql = @"
SELECT IR.RTH,IR.TEXT_RESULT,IR.STUDY_INTEGRATED,
IR.IMAGING_NO, IR.PROCEDURE_INFORMATION,
NVL(IR.CLINICAL_INFORMATION,' ') INFORMATION,
NVL(IR.STUDY_PROTOCOL,' ') STUDY_PROTOCOL,
USR.NAME VERIFY_BY, IR.DS,
TO_CHAR(IR.RESULT_DATE,'DD-MON-YY') VERIFIED_DATE,
NVL(IR.CONCLUSION, ' ') CONCLUSION
FROM EMR.IMAGING_RESULTS IR,
     EMR.USERS USR
WHERE IR.COMPLETE_ORDER_NO = :orderno
  AND IR.ORDER_DETAIL_ID = 1
  AND NVL(IR.VERIFIED_BY, 'GENERAL') = USR.USER_NAME";

        [WebMethod]
        public static List<Dictionary<string, string>> GetImagingResult(string orderNo)
        {
            if (string.IsNullOrWhiteSpace(orderNo))
            {
                return new List<Dictionary<string, string>>();
            }

            DataTable dt = EMRDb.GetDataTable(ConnectionName, ImagingSql,
                new EMRDb.DbParam("orderno", orderNo.Trim()));
            return EMRDb.ToRows(dt);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
        }

        [WebMethod]
        public static string TestConnection()
        {
            try
            {
                EMRDb.GetDataTable(ConnectionName, "SELECT 1 AS OK FROM DUAL");
                return "success";
            }
            catch (Exception ex)
            {
                return "Failed: " + ex.Message;
            }
        }

        public sealed class PatientLookupResult
        {
            public List<Dictionary<string, string>> Patient { get; set; }
            public List<Dictionary<string, string>> Services { get; set; }
            public string ServicesError { get; set; }
        }

        [WebMethod]
        public static PatientLookupResult GetPatientLookup(string key)
        {
            PatientLookupResult result = new PatientLookupResult
            {
                Patient = new List<Dictionary<string, string>>(),
                Services = new List<Dictionary<string, string>>()
            };

            if (string.IsNullOrWhiteSpace(key))
            {
                return result;
            }

            key = key.Trim();

            DataTable dt = EMRDb.GetDataTable(ConnectionName, PatientSql,
                new EMRDb.DbParam("patid", key));
            result.Patient = EMRDb.ToRows(dt);

            try
            {
                DataTable services = EMRDb.GetDataTable(ConnectionName, ServicesSql,
                    new EMRDb.DbParam("patid", key));
                result.Services = EMRDb.ToRows(services);
            }
            catch (Exception ex)
            {
                result.ServicesError = ex.Message;
            }

            return result;
        }
    }
}
