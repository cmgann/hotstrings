--  COURT SUPPORT CODE PULL SCRIPT --
--  This script will pull the File & Serve configuration for a specific node  --
--  This script includes case categories on filing codes --

USE FILEANDSERVE

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
DECLARE @QUEUE TABLE (ID VARCHAR(100))

--******************************************
--********  UPDATE YOUR NODEID  HERE *******
--******************************************

DECLARE @NODEID INT = ####

              --USE FILEANDSERVE SELECT NodeID, ParentNodeID, OrgChartName from config.orgchart where orgchartname like '%Will%'

-- *** EACH QUEUE MUST HAVE AN INSERT STATEMENT.
INSERT INTO @QUEUE (ID) VALUES ('')



--                                ******************************************
--                                  DO NOT CHANGE ANY THING BELOW THIS LINE.
--                                  MAKE SURE YOU HAVE UPDATE THE NODE ID.
--                                 ******************************************
SELECT ORGCHARTNAME, NODEID FROM CONFIG.ORGCHART WHERE NODEID = @NODEID

--******************************

--******************************

--******************************
SELECT DISTINCT
'CASE CATEGORY (CC)',
NODEID AS 'LOCATIONNODEID', 'YES' AS 'VISIBLE', CODE AS 'CMS CODE', CODEID AS 'CODE ID', DESCRIPTION
FROM CONFIG.VWCASECATEGORYCODE
WHERE NODEID = @NODEID
ORDER BY DESCRIPTION

--******************************
SELECT DISTINCT
'CASE TYPE (CT)',
CT.NODEID AS 'LOCATION NODE ID', 'YES' AS 'VISIBLE', CT.CODE AS 'CMS CODE', CT.CODEID AS 'CODE ID', CT.DESCRIPTION AS 'CASE TYPE DESCRIPTION',
CASE
       WHEN ALLOWINITIALFILINGS = 1 THEN 'YES'
       ELSE 'NO'
END
AS 'ALLOW INITIAL FILINGS'
,CC.DESCRIPTION AS 'CASE CATEGORY DESCRIPTION'
, CASE
  WHEN FC.CODE IS NULL THEN ''
  ELSE FC.CODE
  END
  AS 'FEE SCHEDULE CODE'
, CASE
  WHEN FC.DESCRIPTION IS NULL THEN ''
  ELSE FC.DESCRIPTION
  END
  AS 'FEE SCHEDULE DESCRIPTION'
FROM CONFIG.VWCASETYPE CT
JOIN CONFIG.VWCASECATEGORYCODE CC ON CT.NODEID = CC.NODEID AND CT.CASECATEGORYCODEID = CC.CODEID
LEFT JOIN CONFIG.VWXCASETYPECODEFEESCHEDULECODE CTCF ON CT.NODEID = CTCF.NODEID AND CT.CODEID = CTCF.CASETYPECODEID
LEFT JOIN CONFIG.VWFEESCHEDULECODE FC ON CTCF.NODEID = FC.NODEID AND CTCF.FEESCHEDULECODEID = FC.CODEID
WHERE CT.NODEID = @NODEID
ORDER BY CT.DESCRIPTION
--******************************
SELECT DISTINCT
'FILING CODE (FC)',
FC.NODEID AS 'LOCATION NODE ID', 'YES' AS 'VISIBLE', FC.CODE AS 'CMS CODE', FC.CODEID AS 'CODE ID', FC.DESCRIPTION,
CASE
       WHEN ALLOWINITIAL = 1 THEN 'YES'
       ELSE 'NO'
END
AS 'ALLOW INITIAL',

CASE
       WHEN ALLOWSUBSEQUENT = 1 THEN 'YES'
       ELSE 'NO'
END
AS 'ALLOW SUBSEQUENT',

CASE
       WHEN ISCOURTUSEONLY = 1 THEN 'YES'
       ELSE 'NO'
END
AS 'IS COURT USE ONLY'
, CASE
  WHEN FS.CODE IS NULL THEN ''
  ELSE FS.CODE
  END
  AS 'FEE SCHEDULE CODE'
, CASE
  WHEN FS.DESCRIPTION IS NULL THEN ''
  ELSE FS.DESCRIPTION
  END
  AS 'FEE SCHEDULE DESCRIPTION'
, CC.DESCRIPTION AS 'CASE CATEGORY DESCRIPTION'
FROM CONFIG.VWFILINGCODE FC
LEFT JOIN CONFIG.VWXFILINGCODEFEESCHEDULECODE FCFS ON FC.NODEID = FCFS.NODEID AND FC.CODEID = FCFS.FILINGCODEID
LEFT JOIN CONFIG.VWFEESCHEDULECODE FS ON FCFS.NODEID = FS.NODEID AND FCFS.FEESCHEDULECODEID = FS.CODEID
LEFT JOIN [CONFIG].[VWXCASECATEGORYCODEFILINGCODE] CCFC ON FC.NODEID = CCFC.NODEID AND FC.CODEID = CCFC.FILINGCODEID
LEFT JOIN CONFIG.VWCASECATEGORYCODE CC ON CCFC.NODEID = CC.NODEID AND CCFC.CASECATEGORYCODEID = CC.CODEID
LEFT JOIN [CONFIG].[VWXCASETYPECODEFILINGCODE] CTFC ON FC.NODEID = CTFC.NODEID AND FC.CODEID = CTFC.FILINGCODEID
LEFT JOIN CONFIG.VWCASETYPE CT ON CTFC.NODEID = CT.NODEID AND CTFC.CASETYPECODEID = CT.CODEID
WHERE FC.NODEID = @NODEID
AND FC.CODEID NOT IN (-365) AND FC.CODE NOT IN ('OGFINFO')
ORDER BY FC.DESCRIPTION
--******************************
SELECT                     'FILING FEE (FF)',
NODEID AS 'LOCATIONNODEID', 'YES' AS 'VISIBLE', CODE AS 'CMS CODE', CODEID AS 'CODE ID', DESCRIPTION,
CASE
       WHEN AMOUNT IS NULL THEN ''
       ELSE AMOUNT
END
FROM CONFIG.VWFEESCHEDULECODE
WHERE NODEID = @NODEID
ORDER BY DESCRIPTION

--******************************
SELECT DISTINCT
'PARTY TYPE (PT)',
NODEID AS 'LOCATION NODE ID', 'YES' AS 'VISIBLE', CODE AS 'CMS CODE', CODEID AS 'CODE ID', DESCRIPTION,
CASE
       WHEN ISAVAILABLEFORNEWPARTIES = 1 THEN 'YES'
       ELSE 'NO'
END
AS 'IS AVAILABLE FOR NEW PARTIES'

FROM CONFIG.VWPARTYCONNECTIONTYPECODE
WHERE NODEID = @NODEID
ORDER BY DESCRIPTION
--******************************
SELECT                     'DOCUMENT TYPE (DT)',
NODEID AS 'LOCATION NODE ID', 'YES' AS 'VISIBLE', CODE AS 'CMS CODE', DESCRIPTION
FROM CONFIG.VWDOCUMENTTYPECODE
WHERE NODEID = @NODEID
ORDER BY DESCRIPTION

--******************************
SELECT DISTINCT
'FILING COMPONENT (COM)',
FC.NODEID AS 'LOCATION NODE ID', 'YES' AS 'VISIBLE', FC.CODE AS 'CMS CODE', FC.CODEID AS 'CODE ID', FC.DESCRIPTION AS 'FILING COMPONENT DESCRIPTION'
, CASE
  WHEN FS.CODE IS NULL THEN ''
  ELSE FS.CODE
  END
  AS 'FEE SCHEDULE CODE'
, CASE
  WHEN FS.DESCRIPTION IS NULL THEN ''
  ELSE FS.DESCRIPTION
  END
  AS 'FEE SCHEDULE DESCRIPTION'
FROM CONFIG.VWFILINGCOMPONENTCODE FC
LEFT JOIN CONFIG.VWXFILINGCOMPONENTCODEFEESCHEDULECODE FCCF ON FC.NODEID = FCCF.NODEID AND FC.CODEID = FCCF.FILINGCOMPONENTCODEID
LEFT JOIN CONFIG.VWFEESCHEDULECODE FS ON FS.NODEID = FCCF.NODEID AND FS.CODEID = FCCF.FEESCHEDULECODEID
WHERE FC.NODEID = @NODEID
AND FC.CODEID NOT IN (-364,331,332)
ORDER BY FC.DESCRIPTION
--******************************