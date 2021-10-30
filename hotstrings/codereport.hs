/*****************************************************************************************************************************************************************************
	REPORT	-	LOCATION OF CLIENT'S CONFIGURATION
******************************************************************************************************************************************************************************
	SUMMARY
--==================================
	This script provides a report of the number of case types configured at various nodes in the database.  Running this script will help team members determine where a
		client's configuration lives.  This script is not 100% foolproof, but should be fairly accurate.
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	COMPOSED BY EVAN ACOSTA & TONY ABADIE
		08/2018		Initial script created by Tony and edited by Evan

******************************************************************************************************************************************************************************/
Use FileAndServe
Set Transaction Isolation Level Read Uncommitted
Declare @OrderByType			varchar(8)

Set @OrderByType			=	'LOCATION'		--	NODEID, LOCATION	--	Orders Report by either OrgChart Name or NodeID

--============================================================================================================================================================================
--	DO NOT MAKE CHANGES BELOW THIS LINE
--============================================================================================================================================================================
If @OrderByType = 'LOCATION'
	Begin
		Select 'CASE CATEGORY / FILING CODE (CC_FC)' as 'RELATIONSHIP TYPE', x.NodeID as 'NODEID', x.OrgChartName as 'LOCATION', Count(x.FilingCodeID) as 'CODE COUNT'
		from
			(
				Select Distinct ccfc.NodeID, oc.OrgChartName, ccfc.FilingCodeID
				from Config.xCaseCategoryCode_FilingCode ccfc
				join Config.OrgChart oc on oc.NodeID = ccfc.NodeID
			) x
		group by NodeID, OrgChartName
		order by OrgChartName, NodeID

		Select 'CASE TYPE / FILING CODE (CT_FC)' as 'RELATIONSHIP TYPE', x.NodeID as 'NODEID', x.OrgChartName as 'LOCATION', Count(x.FilingCodeID) as 'CODE COUNT'
		from
			(
				Select Distinct ctfc.NodeID, oc.OrgChartName, ctfc.FilingCodeID
				from Config.xCaseTypeCode_FilingCode ctfc
				join Config.OrgChart oc on oc.NodeID = ctfc.NodeID
			) x
		group by NodeID, OrgChartName
		order by OrgChartName, NodeID

	End
Else
	Begin
		Select 'CASE CATEGORY / FILING CODE (CC_FC)' as 'RELATIONSHIP TYPE', x.NodeID as 'NODEID', x.OrgChartName as 'LOCATION', Count(x.FilingCodeID) as 'CODE COUNT'
		from
			(
				Select Distinct ccfc.NodeID, oc.OrgChartName, ccfc.FilingCodeID
				from Config.xCaseCategoryCode_FilingCode ccfc
				join Config.OrgChart oc on oc.NodeID = ccfc.NodeID
			) x
		group by NodeID, OrgChartName
		order by NodeID

		Select 'CASE TYPE / FILING CODE (CT_FC)' as 'RELATIONSHIP TYPE', x.NodeID as 'NODEID', x.OrgChartName as 'LOCATION', Count(x.FilingCodeID) as 'CODE COUNT'
		from
			(
				Select Distinct ctfc.NodeID, oc.OrgChartName, ctfc.FilingCodeID
				from Config.xCaseTypeCode_FilingCode ctfc
				join Config.OrgChart oc on oc.NodeID = ctfc.NodeID
			) x
		group by NodeID, OrgChartName
		order by NodeID
	End