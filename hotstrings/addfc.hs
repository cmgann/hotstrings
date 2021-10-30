/*****************************************************************************************************************************************************************************
	ADD NEW FILING CODE SCRIPT (IN MASS)
******************************************************************************************************************************************************************************
	SUMMARY
--==================================
	This script can be used to mass add filing code(s) to a client's configuration specific case categories.  This script is defaulted to not save changes, unless (@SaveChanges) is set to 'YES'.
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	COMPOSED BY TONY ABADIE
		12/2018		Rewritten from previous development script to allow for the linking of Filing Codes to Fee Schedules
		02/2019		Added capability to link Filing Codes to Document Type Codes
		03/2019		Added instructions, comments for clarification, and specialized Filing Code to Optional Service functionality for incorrectly configured clients
		06/2019		Added ability to tie a CodeEFSP to the new Filing Code
		12/2019		Added validation to make sure codes specified in the insert statements are in fact Filing Codes
		01/2020		Updated the lead document display order
		03/2020		Added capability to link Filing Codes to Case Type Codes

******************************************************************************************************************************************************************************
	INSTRUCTIONS
******************************************************************************************************************************************************************************
	To run this script, you must provide certain pieces of information.
		1.	NODEID(S)
				(@NodeIDString)					--	(Multiple, as String)	--	Provide the specific node(s) you would like to add the Filing Code(s) to.

		2.	CASE CATEGORY DESCRIPTION(S)
				(@CaseCategoryDescString)		--	(Multiple, as String)	--	Provide the descriptions of the case categories you would need code(s) added to.
																				Case Category descriptions cannot include commas, so you will need to use the insert statements from the support query to add those specifically.

		3.	FILING CODE(S)
				(@FilingCodeString)				--	(Multiple, as String)	--	For newly created filing codes, place the code(s) in the claim.
																				For existing filing codes, use the insert statements from the support query.

		4.	FILING CODE ATTRIBUTES
				(@Initial)						--	(YES or NO)				--	Filing code(s) is available for Initial filings.
				(@Subsequent)					--	(YES or NO)				--	Filing code(s) is available for Subsequent filings.
				(@CourtUse)						--	(YES or NO)				--	Filing code(s) is available to court staff only, and will not be displayed to filers.

		5.	OPTIONAL SERVICES
				(@LinkOptionalServices)			--	(YES or NO)				--	Select YES if you want this code(s) linked to all Optional Services that other filing codes in the same case category are linked to.
				(@SpecificOptionalServices)		--	(Multiple, as String)	--	List specific Optional Service Code(s) if you want create specific relationships with your new Filing Code(s).
																			--	(Please note that (@LinkOptionalServices) must be set to YES for specific relationships to be established.)

		6.	FEE SCHEDULE	(OPTIONAL CLAIMS)
				(@FeeScheduleCode)				--	(Single Code)			--	Fee Schedule code you want filing code(s) linked to.
				(@FeeScheduleDescription)		--	(Single Description)	--	Fee Schedule description you want filing code(s) linked to.
				(@FeeScheduleAmount)			--	(Single Amount)			--	Fee Schedule amount you want filing code(s) linked to.

		7.	CASE TYPE CODE(S)	(OPTIONAL CLAIMS)
				(@CaseTypeCodeString)			--	(Multiple, as String)	--	Place any number of Case Type code(s) in the claim.
																				You may also use the insert statements from the support query.

		8.	DOCUMENT TYPES	(OPTIONAL CLAIMS)
				(@DocumentTypeIsDefault)		--	(Single Description)	--	Provide the description for the document type you want the Filing Code(s) defaulted to.
				(@DocumentTypeIsNotDefault)		--	(Multiple, as String)	--	Provide the description(s) for the document type(s) you want the Filing Code(s) to have as addtional options.

		9.	CONDITIONS	(OPTIONAL CLAIMS)
				(@ConditionNameString)			--	(Multiple, as String)	--	Provide the Condition Description(s) you want the new Filing Code(s) linked to.
																			--	(These can be condtions related to OFS and/or CMS Routing Rules.)

		10.	EXCLUSION NODEID(S)		(OPTIONAL CLAIMS)
				(@ExclusionNodeIDString)		--	(Multiple, as String)	--	Provide the specific node(s) you would like to exclude new Filing Code(s) from.

******************************************************************************************************************************************************************************
	SUPPORT QUERIES (PER THE STEPS LISTED ABOVE)
******************************************************************************************************************************************************************************
--==============================================================================================================
1.	FIND NODEIDS
--==============================================================================================================
	This script will help you locate the correct NodeID to insert your code(s).
	----------------------------------------------------------------------------
		Use FileAndServe Declare @County varchar(max)		=	''
		Select Distinct NodeID as 'NODEID', ParentNodeID as 'PARENT NODEID', OrgChartName as 'LOCATION', Visible as 'VISIBLE' from Config.OrgChart where OrgChartName like ('%' + @County + '%') and ParentNodeID is not null and NodeID <> 1

--==============================================================================================================
2.	FIND CASE CATEGORY CODES
--==============================================================================================================
	This script will provide you with the available case categories for a given node.
	----------------------------------------------------------------------------------
		Use FileAndServe Declare @NodeID int				=	6820
		Select NodeID as 'NODEID', CodeID as 'CODEID', Code as 'CODE', Description as 'DESCRIPTION', CodeEFSP as 'CODEEFSP', 'INSERT INTO @CCIDTABLE (NODEID, CCID) VALUES (' + CAST(MAX(cc.NODEID) AS VARCHAR(MAX)) + ', ' + CAST(MAX(cc.CODEID) AS VARCHAR(MAX)) +  ')' as 'INSERT STATEMENT'
		from Config.vwCaseCategoryCode cc where NodeID = @NodeID group by NodeID, CodeID, Code, Description, CodeEFSP order by Code, Description

--==============================================================================================================
3a.	FIND FILING CODES
--==============================================================================================================
	This script will help you find existing filing codes that can be reused at your current node.
	If the code is not currently in the client's configuration, the CASE CATEGORY CODE column will be NULL.
	If you are using an existing filing code, you will need to copy the INSERT STATEMENT to the space below.
	---------------------------------------------------------------------------------------------------------
		Use FileAndServe Declare @NodeID int				=	6820
		Declare @Code varchar(25)							=	'MTTRM'
		Select c.CodeID as 'CODEID', c.Code as 'CODE', c.Description as 'DESCRIPTION', cc.Code as 'CASE CATEGORY CODE', 'INSERT INTO @TEMPFCIDTABLE (FCID) VALUES (' + CAST(MAX(c.CODEID) AS VARCHAR(MAX)) +  ')' as 'INSERT STATEMENT' from Config.Code c left join Config.xCaseCategoryCode_FilingCode ccfc on ccfc.FilingCodeID = c.CodeID left join Config.vwCaseCategory cc on cc.CodeID = ccfc.CaseCategoryCodeID and cc.NodeID = ccfc.NodeID and cc.NodeID = @NodeID where c.CodeTableID = 1 and c.Code = @Code group by c.Code, c.Description, c.CodeID, cc.Code

--==============================================================================================================
3b.	ADD NEW FILING CODES
--==============================================================================================================
	Use this insert statement if you need to create a new filing code.
	-------------------------------------------------------------------
		Use FileAndServe Declare @NodeID int				=	6820
		Declare @Code varchar(50)							=	'MTTRM'
		Declare @Description varchar(max)					=	'Motion to Terminate Wage Withholding'
		Insert Into Config.Code (CodeTableID,Code,Description,IsUserEditable,TimestampCreate,RootNodeID) Values (1,@Code,@Description,1,GETDATE(),@NodeID) Select max(CodeID) as 'CODEID', Code as 'CODE', Description as 'DESCRIPTION' from Config.Code where CodeTableID = 1 and Code = @Code and Description = @Description group by Code, Description

nimble text
Insert Into Config.Code (CodeTableID,Code,Description,IsUserEditable,TimestampCreate,RootNodeID) Values (1,'$0','$1',1,GETDATE(),@NodeID) Select max(CodeID) as 'CODEID', Code as 'CODE', Description as 'DESCRIPTION' from Config.Code where CodeTableID = 1 and Code = '$0' and Description = '$1' group by Code, Description


--==============================================================================================================
6.	FIND FEE SCHEDULE CODES
--==============================================================================================================
	This script will help you locate the correct fee schedule at the client's node.
	You may search by code, amount or without either claim.
	If the fee schedule does not exist, the main script will add it.
	--------------------------------------------------------------------------------
		Use FileAndServe Declare @NodeID int				=	7850
		Declare @Code varchar(50)							=	''
		Declare @Amount varchar(10)							=	''
		If len(@Code) > 0 and len(@Amount) > 0 Begin Select Code + ' | ' + cast(CodeID as varchar) as 'REFERENCE (FS)', Description as 'DESCRIPTION (FS)', Amount as 'AMOUNT' from Config.vwFeeScheduleCode where NodeID = @NodeID and Code = @Code and Amount = @Amount order by Description End Else If len(@Code) > 0 and len(@Amount) = 0 Begin Select Code + ' | ' + cast(CodeID as varchar) as 'REFERENCE (FS)', Description as 'DESCRIPTION (FS)', Amount as 'AMOUNT' from Config.vwFeeScheduleCode where NodeID = @NodeID and Code = @Code order by Description End Else If len(@Code) = 0 and len(@Amount) > 0 Begin Select Code + ' | ' + cast(CodeID as varchar) as 'REFERENCE (FS)', Description as 'DESCRIPTION (FS)', Amount as 'AMOUNT' from Config.vwFeeScheduleCode where NodeID = @NodeID and Amount = @Amount order by Description End Else Begin Select Code + ' | ' + cast(CodeID as varchar) as 'REFERENCE (FS)', Description as 'DESCRIPTION (FS)', Amount as 'AMOUNT' from Config.vwFeeScheduleCode where NodeID = @NodeID order by Description End

--==============================================================================================================
7.	FIND CASE TYPE CODES
--==============================================================================================================
	This script will help you locate the correct case type at the client's node.
	You may search by code if you like, but it is not required.
	---------------------------------------------------------------------------------------------------------
		Use FileAndServe Declare @NodeID int				=	7850
		Declare @Code varchar(25)							=	''
		If len(@Code) > 0 Begin Select ct.Code + ' | ' + cast(ct.CodeID as varchar) as 'REFERENCE (CT)', ct.Description as 'DESCRIPTION (CT)', ct.AllowInitialFilings as 'INITIAL', cc.Code + ' | ' + cast(ct.CaseCategoryCodeID as varchar) as 'REFERENCE (CC)', cc.Description as 'DESCRIPTION (CC)', 'INSERT INTO @TEMPCTIDTABLE (CTID) VALUES (' + cast(ct.CodeID as varchar) +  ')' as 'INSERT STATEMENT' from Config.vwCaseType ct join Config.vwCaseCategoryCode cc on cc.CodeID = ct.CaseCategoryCodeID and cc.NodeID = ct.NodeID where ct.NodeID = @NodeID and ct.Code = @Code order by ct.Description, ct.Code, cc.Code, cc.Description End Else Begin Select ct.Code + ' | ' + cast(ct.CodeID as varchar) as 'REFERENCE (CT)', ct.Description as 'DESCRIPTION (CT)', ct.AllowInitialFilings as 'INITIAL', cc.Code + ' | ' + cast(ct.CaseCategoryCodeID as varchar) as 'REFERENCE (CC)', cc.Description as 'DESCRIPTION (CC)', 'INSERT INTO @TEMPCTIDTABLE (CTID) VALUES (' + cast(ct.CodeID as varchar) +  ')' as 'INSERT STATEMENT' from Config.vwCaseType ct join Config.vwCaseCategoryCode cc on cc.CodeID = ct.CaseCategoryCodeID and cc.NodeID = ct.NodeID where ct.NodeID = @NodeID order by ct.Description, ct.Code, cc.Code, cc.Description End

--==============================================================================================================
8.	FIND DOCUMENT TYPE CODES
--==============================================================================================================
	This script will help you find the descriptions of document type codes.
	Please note that this configuration will allow the filing code to default to a document type, but only if the Document Security Group CMS Capability is turned on.
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------
		Use FileAndServe Declare @NodeID int				=	7850
		Select CodeID as 'CODEID', Code as 'CODE', Description as 'DESCRIPTION' from Config.vwDocumentTypeCode where NodeID = @NodeID order by Description

--==============================================================================================================
9.	FIND CONDITIONS (OFS AND/OR CMS ROUTING)
--==============================================================================================================
	This script will show you which OFS and CMS routing rules are visible at the node specified, as well as all subsequent nodes.
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------
		Use FileAndServe Declare @RootNodeID int			=	7850
		Select xcn.NodeID as 'NODEID', oc.OrgChartName as 'LOCATION', ct.Description as 'CODETABLE', c1.Description as 'ROUTING RULE', c2.Description as 'DESTINATION QUEUE', qrr.ConditionID as 'CONDITIONID', con.Description as 'CONDITION' from Config.xCodeNode xcn join Config.OrgChart oc on oc.NodeID = xcn.NodeID join Config.CodeExt_QueueRoutingRule qrr on qrr.CodeID = xcn.CodeID join Config.Code c1 on c1.CodeID = xcn.CodeID join Config.Code c2 on c2.CodeID = qrr.DestinationQueueID join Config.CodeTable ct on ct.CodeTableID = c1.CodeTableID join Config.Condition con on con.ConditionID = qrr.ConditionID	where xcn.CodeID in(Select CodeID from Config.Code	where CodeTableID = 29) and xcn.NodeID in (Select ChildNodeID from Operations.Report.RootNodeCache where NodeID = @RootNodeID) and xcn.Visible = 1
		Select xcn.NodeID as 'NODEID', oc.OrgChartName as 'LOCATION', ct.Description as 'CODETABLE', c1.Description as 'ROUTING RULE', c2.Description as 'DESTINATION QUEUE', cms.ConditionID as 'CONDITIONID', con.Description as 'CONDITION' from Config.xCodeNode xcn join Config.OrgChart oc on oc.NodeID = xcn.NodeID join Config.CodeExt_CMSRoutingRule cms on cms.CodeID = xcn.CodeID join Config.Code c1 on c1.CodeID = xcn.CodeID join Config.Code c2 on c2.CodeID = cms.CMSDestinationQueueCode join Config.CodeTable ct on ct.CodeTableID = c1.CodeTableID join Config.Condition con on con.ConditionID = cms.ConditionID where xcn.CodeID in (Select CodeID from Config.Code where CodeTableID = 34) and xcn.NodeID in (Select ChildNodeID from Operations.Report.RootNodeCache where NodeID = @RootNodeID) and xcn.Visible = 1 order by xcn.NodeID, ct.Description, c1.Description, con.Description

******************************************************************************************************************************************************************************/
Use FileAndServe
Set Transaction Isolation Level Read Uncommitted
Begin Tran
Declare @CCIDTABLE						table(NODEID int, CCID int)
Declare @TEMPCTIDTABLE					table(NODEID int, CTID int)
Declare @TEMPFCIDTABLE					table(FCID int)
Declare @NodeIDString					varchar(max)
Declare @CaseCategoryDescString			varchar(max)
Declare @CaseTypeCodeString				varchar(max)
Declare @FilingCodeString				varchar(max)
Declare @Initial						varchar(3)
Declare @Subsequent						varchar(3)
Declare @CourtUse						varchar(3)
Declare @LinkOptionalServices			varchar(3)
Declare @SpecificOptionalServices		varchar(max)
Declare @FeeScheduleCode				varchar(15)
Declare @FeeScheduleDescription			varchar(max)
Declare @FeeScheduleAmount				varchar(8)
Declare @CodeEFSP						varchar(50)
Declare @DocumentTypeIsDefault			varchar(max)
Declare @DocumentTypeIsNotDefault		varchar(max)
Declare @ConditionNameString			varchar(max)
Declare @ExclusionNodeIDString			varchar(max)
Declare @SaveChanges					varchar(3)
--==============================================================================================================
--	REQUIRED CLAIMS
--==============================================================================================================
--------------------------------------------------------------
--	SAVE CHANGES
--------------------------------------------------------------
Set @SaveChanges					=	'NO'					--	SAVE CHANGES	-	YES or NO
--------------------------------------------------------------
--	NODEID(S) & CASE CATEGORY CODE DESCRIPTION(S)
--------------------------------------------------------------
Set @NodeIDString					=	'6820'					--	NODEID(S)	-	(AS COMMA DELIMITED STRING)
Set @CaseCategoryDescString			=	'Civil'					--	CASE CATEGORY DESCRIPTION(S)	-	(AS COMMA DELIMITED STRING)
						------------------
						--		OR		--
						------------------
--	(Add Insert Statements to configure existing Case Category Codes.  Both the (@CaseCategoryDescString) and the insert statements can be used together.  This is particularly helpful if the case category description contains commas.)
--	INSERT INTO @CCIDTABLE (NODEID, CCID) VALUES (77510, 8)
--------------------------------------------------------------
--	FILING CODE(S)
--------------------------------------------------------------
Set @FilingCodeString				=	'XXXX'					--	FILING CODE(S)	-	(AS COMMA DELIMITED STRING)
						------------------
						--		OR		--
						------------------
--	(Add Insert Statements to configure existing Filing Codes.  If Insert statements are used, leave the (@FilingCodeString) claim blank.)
--	INSERT INTO @TEMPFCIDTABLE (FCID) VALUES (182447)
--------------------------------------------------------------
--	FILING CODE ATTRIBUTES
--------------------------------------------------------------
Set @Initial						=	'NO'					--	ALLOWS INITIAL FILINGS
Set @Subsequent						=	'YES'					--	ALLOWS SUBSEQUENT FILINGS
Set @CourtUse						=	'NO'					--	IS ONLY AVAILABLE TO COURT STAFF
--------------------------------------------------------------
--	OPTIONAL SERVICES
--------------------------------------------------------------
Set @LinkOptionalServices			=	'YES'					--	LINK OPTIONAL SERVICES TO NEW CODES
Set @SpecificOptionalServices		=	''						--	LINK ONLY THESE SPECIFIC OPTIONAL SERVICES CODES		-	(AS COMMA DELIMITED STRING)

--==============================================================================================================
--	OPTIONAL CLAIMS
--==============================================================================================================
--------------------------------------------------------------
--	FEE SCHEDULE CODE
--------------------------------------------------------------
Set @FeeScheduleCode				=	''						--	FEE SCHEDULE CODE						-	(SINGLE CODE)
Set @FeeScheduleAmount				=	''						--	FEE SCHEDULE AMOUNT						-	(SINGLE AMOUNT)
--	(Enter the Fee Schedule Code Description above if you want the newly created Fee Schedule to have a particular name.)
Set @FeeScheduleDescription			=	''						--	FEE SCHEDULE DESCRIPTION				-	(SINGLE DESCRIPTION)

--------------------------------------------------------------
--	CASE TYPE CODE(S)
--------------------------------------------------------------
Set @CaseTypeCodeString				=	''					--	CASE TYPE CODE(S)			-	(AS COMMA DELIMITED STRING)
						------------------
						--		OR		--
						------------------
--	(Add Insert Statements to configure existing Case Type Codes.  If Insert statements are used, leave the (@CaseTypeCodeString) claim blank.)
--	INSERT INTO @TEMPCTIDTABLE (CTID) VALUES (173197)
--------------------------------------------------------------
--	CODE EFSP
--------------------------------------------------------------
Set @CodeEFSP						=	''						--	CODE EFSP CODE				-	(SINGLE CODE)
--------------------------------------------------------------
--	DOCUMENT TYPE CODE(S)
--------------------------------------------------------------
Set @DocumentTypeIsDefault			=	''						--	DOCUMENT TYPE CODE DESCRIPTION TO DEFAULT	-	(SINGLE DESCRIPTION)
Set @DocumentTypeIsNotDefault		=	''						--	ADDITIONAL DOCUMENT TYPE CODE DESCRIPTION(S) WHICH WILL NOT DEFAULT	-	(AS COMMA DELIMITED STRING)
--------------------------------------------------------------
--	CONDITIONS (FOR OFS OR CMS ROUTING RULES)
--------------------------------------------------------------
Set	@ConditionNameString			=	''						--	LINK CONDITION(S) TO NEW CODES			-	(AS COMMA DELIMITED STRING)
--------------------------------------------------------------
--	EXCLUSION NODEID(S)
--------------------------------------------------------------
Set @ExclusionNodeIDString			=	''						--	EXCLUDE FROM NODEID(S)	-	(AS COMMA DELIMITED STRING)

--============================================================================================================================================================================
--	DO NOT MAKE CHANGES BELOW THIS LINE
--============================================================================================================================================================================

/*-------------------------------------------------------------------------------------------------------------------------------
|	POPULATE VARIABLE TABLES - (NODE ID)																						|
|	----------------------------------------------------------------------------												|
|	This will break your (@NodeIDString) claim into individual NodeID and store them in (@NODEIDTABLE).							|
|	This variable table will be used to map out all the locations for your new code.											|
|	If you have selected any nodes to exclude, your (@ExclusionNodeIDString) claim will be stored in (@EXCLUSIONNODEIDTABLE).	|
-------------------------------------------------------------------------------------------------------------------------------*/
Declare @NodeIDTemp						varchar(max)
Declare @NODEIDTABLE					table(NODEID int)
Declare @EXCLUSIONNODEIDTABLE			table(NODEID int)

While Len(@NodeIDString) > 0
	Begin
		If Patindex('%,%',@NodeIDString) > 0
			Begin
				Set @NodeIDTemp = Substring(@NodeIDString, 0, Patindex('%,%', @NodeIDString))
				Insert Into @NODEIDTABLE (NODEID) Values (@NodeIDTemp)
				Set @NodeIDString = Substring(@NodeIDString, Len(@NodeIDTemp) + 2, Len(@NodeIDString))
			End
		Else
			Begin
				Set @NodeIDTemp = @NodeIDString
				Insert Into @NODEIDTABLE (NODEID) Values (@NodeIDTemp)
				Set @NodeIDString = Null
			End
	End

While Len(@ExclusionNodeIDString) > 0
	Begin
		If Patindex('%,%',@ExclusionNodeIDString) > 0
			Begin
				Set @NodeIDTemp = Substring(@ExclusionNodeIDString, 0, Patindex('%,%', @ExclusionNodeIDString))
				Insert Into @EXCLUSIONNODEIDTABLE (NODEID) Values (@NodeIDTemp)
				Set @ExclusionNodeIDString = Substring(@ExclusionNodeIDString, Len(@NodeIDTemp) + 2, Len(@ExclusionNodeIDString))
			End
		Else
			Begin
				Set @NodeIDTemp = @ExclusionNodeIDString
				Insert Into @EXCLUSIONNODEIDTABLE (NODEID) Values (@NodeIDTemp)
				Set @ExclusionNodeIDString = Null
			End
	End

/*-----------------------------------------------------------------------------------------------------------------------------------------------
|	POPULATE VARIABLE TABLES - (CASE CATEGORY)																									|
|	----------------------------------------------------------------------------																|
|	This will break your (@CaseCategoryDescString) claim into individual Case Category descriptions and store them in (@CCDESCRIPTIONTABLE).	|
|	It will then insert CodeID values into the variable table (@CCIDTABLE) where these descriptions apply per the Nodes in (@NODEIDTABLE).		|
|	Variable table (@CCIDTABLE) stores NodeID and Case Category CodeID information for Filing Code inserts.										|
-----------------------------------------------------------------------------------------------------------------------------------------------*/
Declare @CaseCategoryDescTemp			varchar(max)
Declare @CCDESCRIPTIONTABLE				table(CCDESC varchar(max))

While Len(@CaseCategoryDescString) > 0
	Begin
		If Patindex('%,%',@CaseCategoryDescString) > 0
			Begin
				Set @CaseCategoryDescTemp = Substring(@CaseCategoryDescString, 0, Patindex('%,%', @CaseCategoryDescString))
				Insert Into @CCDESCRIPTIONTABLE (CCDESC) Values (@CaseCategoryDescTemp)
				Set @CaseCategoryDescString = Substring(@CaseCategoryDescString, Len(@CaseCategoryDescTemp) + 2, Len(@CaseCategoryDescString))
			End
		Else
			Begin
				Set @CaseCategoryDescTemp = @CaseCategoryDescString
				Insert Into @CCDESCRIPTIONTABLE (CCDESC) Values (@CaseCategoryDescTemp)
				Set @CaseCategoryDescString = Null
			End
	End

Insert Into @CCIDTABLE (NODEID, CCID)
	Select Distinct NodeID, CodeID
	from Config.vwCaseCategoryCode
	where Description in
		(
		Select Distinct CCDESC
		from @CCDESCRIPTIONTABLE
		)
	and NodeID in
		(
		Select Distinct NODEID
		from @NODEIDTABLE
		)

/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
|	POPULATE VARIABLE TABLES - (CASE TYPE CODE)																															|
|	----------------------------------------------------------------------------																						|
|	This will break your (@CaseTypeCodeString) claim into individual Case Type Codes and store them in (@CTCODETABLE).													|
|	It will then insert the max CodeID values into the variable table (@CTIDTABLE) where these Case Type Codes apply.													|
|	(If you are using the manual insert statements to add existing Case Type Codes to the client's configuration, CodeID's will inserted directly to this table.)		|
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
Declare @CaseTypeCodeTemp				varchar(max)
Declare @CTCODETABLE					table(CTCODE varchar(25))
Declare @CTIDTABLE						table(NODEID int, CTID int)

While Len(@CaseTypeCodeString) > 0
	Begin
		If Patindex('%,%',@CaseTypeCodeString) > 0
			Begin
				Set @CaseTypeCodeTemp = Substring(@CaseTypeCodeString, 0, Patindex('%,%', @CaseTypeCodeString))
				Insert Into @CTCODETABLE (CTCODE) Values (@CaseTypeCodeTemp)
				Set @CaseTypeCodeString = Substring(@CaseTypeCodeString, Len(@CaseTypeCodeTemp) + 2, Len(@CaseTypeCodeString))
			End
		Else
			Begin
				Set @CaseTypeCodeTemp = @CaseTypeCodeString
				Insert Into @CTCODETABLE (CTCODE) Values (@CaseTypeCodeTemp)
				Set @CaseTypeCodeString = Null
			End
	End

Insert Into @TEMPCTIDTABLE (NODEID, CTID)
	Select Distinct NodeID, CodeID
	from Config.vwCaseType
	where NodeID in
		(
		Select Distinct NODEID
		from @NODEIDTABLE
		)
	and Code in
		(
		Select Distinct CTCODE
		from @CTCODETABLE
		)

Insert Into @CTIDTABLE (NODEID, CTID)
	Select Distinct ct.NodeID, ct.CodeID
	from Config.vwCaseType ct
	join @TEMPCTIDTABLE t on t.NODEID = ct.NodeID and t.CTID = ct.CodeID
	where ct.NodeID in
		(
		Select Distinct NODEID
		from @TEMPCTIDTABLE
		)
	and CodeID in
		(
		Select Distinct CTID
		from @TEMPCTIDTABLE
		)

Insert Into @CCIDTABLE (NODEID, CCID)
	Select Distinct ct.NODEID, ct.CaseCategoryCodeID
	from @CTIDTABLE i
	join Config.vwCaseType ct on ct.NodeID = i.NODEID and ct.CodeID = i.CTID
	where ct.NodeID in
		(
		Select Distinct NODEID
		from @NODEIDTABLE
		)
	and ct.CodeID in
		(
		Select Distinct CTID
		from @CTIDTABLE
		)
	and not exists
		(
		Select 1
		from @CCIDTABLE cc
		where cc.NODEID = ct.NodeID and cc.CCID = ct.CaseCategoryCodeID
		)

/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
|	POPULATE VARIABLE TABLES - (FILING CODE)																															|
|	----------------------------------------------------------------------------																						|
|	This will break your (@FilingCodeString) claim into individual Filing Codes and store them in (@FCCODETABLE).														|
|	(This assumes you have added a new Filing Code and are inserting it using this claim.)																				|
|	It will then insert the max CodeID values into the variable table (@FCIDTABLE) where these Filing Codes apply.														|
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
Declare @FilingCodeTemp					varchar(max)
Declare @FCCODETABLE					table(FCCODE varchar(25))
Declare @FCIDTABLE						table(FCID int)

While Len(@FilingCodeString) > 0
	Begin
		If Patindex('%,%',@FilingCodeString) > 0
			Begin
				Set @FilingCodeTemp = Substring(@FilingCodeString, 0, Patindex('%,%', @FilingCodeString))
				Insert Into @FCCODETABLE (FCCODE) Values (@FilingCodeTemp)
				Set @FilingCodeString = Substring(@FilingCodeString, Len(@FilingCodeTemp) + 2, Len(@FilingCodeString))
			End
		Else
			Begin
				Set @FilingCodeTemp = @FilingCodeString
				Insert Into @FCCODETABLE (FCCODE) Values (@FilingCodeTemp)
				Set @FilingCodeString = Null
			End
	End

Insert Into @TEMPFCIDTABLE (FCID)
	Select Distinct Max(CodeID)
	from Config.Code
	where CodeTableID = 1 and Code in
		(
			Select Distinct FCCODE
			from @FCCODETABLE
		)
	group by Code

Insert Into @FCIDTABLE (FCID)
	Select Distinct CodeID
	from Config.Code
	where CodeTableID = 1 and CodeID in
		(
			Select Distinct FCID
			from @TEMPFCIDTABLE
		)

/*-----------------------------------------------------------------------------------------------------------------------------------------------
|	POPULATE VARIABLE TABLES - (FEE SCHEDULE CODE)																								|
|	(Optional Step)																																|
|	----------------------------------------------------------------------------																|
|	The client's configuratoin will be checked for visible Fee Schedule Codes.  These codes will be stored in (@FSIDTABLE).						|
|	Next, this table will be compared against all nodes that were specified.																	|
|	If any are not accounted for a new Fee Schedule Code will be created and stored in (@FSIDMISSINGTABLE).										|
|	These codes will then be inserted back into (@FSIDTABLE).																					|
-----------------------------------------------------------------------------------------------------------------------------------------------*/
Declare @FSIDTABLE					table(NODEID int, FSID int, FSCODE varchar(max), AMT money)
Declare @FSIDMISSINGTABLE			table(NODEID int, FSID int, FSCODE varchar(max))

Insert Into @FSIDTABLE (NODEID, FSID, FSCODE, AMT)
	Select Distinct NodeID, min(CodeID), Code, Amount
	from Config.vwFeeScheduleCode
	where Code = @FeeScheduleCode and Amount = @FeeScheduleAmount
	and NodeID in
		(
		Select Distinct NODEID
		from @NODEIDTABLE
		)
	group by NodeID, Code, Amount

If len(@FeeScheduleCode) > 0
	Begin
		Insert Into @FSIDMISSINGTABLE (NODEID)
			Select Distinct n.NODEID
			from @NODEIDTABLE n
			where not exists
				(
				Select Distinct NODEID
				from @FSIDTABLE f
				where f.NODEID = n.NODEID
				)
	End

If
	(
	Select Distinct count(NODEID)
	from @FSIDMISSINGTABLE
	) > 0
		Begin
			If len(@FeeScheduleDescription) > 0
				Begin
					Insert Into Config.Code (CodeTableID, Code, Description, IsUserEditable, TimestampCreate, RootNodeID)
					Values (5, @FeeScheduleCode, @FeeScheduleDescription, 0, GETDATE(), 0)
				End
			Else If len(@FeeScheduleCode) > 0
				Begin
					If not exists
						(
						Select 1
						from Config.Code
						where CodeTableID = 5 and Code = @FeeScheduleCode and Description = 'Fee Schedule added by Filing Code'
						)
						Begin
							Insert Into Config.Code (CodeTableID, Code, Description, IsUserEditable, TimestampCreate, RootNodeID)
							Values (5, @FeeScheduleCode, 'Fee Schedule added by Filing Code', 0, GETDATE(), 0)
						End
				End

			If len(@FeeScheduleDescription) > 0
				Begin
					Update @FSIDMISSINGTABLE
					Set FSID =
						(
						Select max(CodeID)
						from Config.Code
						where CodeTableID = 5 and Code = @FeeScheduleCode and Description = @FeeScheduleDescription
						group by Code, Description
						),
						FSCODE = @FeeScheduleCode
					where FSID is null
				End
			Else
				Begin
					Update @FSIDMISSINGTABLE
					Set FSID =
						(
						Select max(CodeID)
						from Config.Code
						where CodeTableID = 5 and Code = @FeeScheduleCode and Description = 'Fee Schedule added by Filing Code'
						group by Code, Description
						),
						FSCODE = @FeeScheduleCode
					where FSID is null
				End

			Insert Into @FSIDTABLE (NODEID, FSID, FSCODE, AMT)
				Select Distinct NODEID, FSID, FSCODE, @FeeScheduleAmount
				from @FSIDMISSINGTABLE
		End

/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
|	POPULATE VARIABLE TABLES - (OPTIONAL SERVICES)																														|
|	(Optional Step)																																						|
|	----------------------------------------------------------------------------																						|
|	This will break your (@SpecificOptionalServices) claim into individual Optional Service Codes and store them in (@COMCODETABLE).									|
|	(This is assuming you are wishing to link optional services, but you do not want to link all available optional services for that particular case category.)		|
|	(It would make the most sense to use this configuration if the client had previously linked an optional services to a filing code in the wrong case category.)		|
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
Declare @SpecificOptionalServicesTemp	varchar(max)
Declare @COMCODETABLE					table(COMCODE varchar(25))

While Len(@SpecificOptionalServices) > 0
	Begin
		If Patindex('%,%',@SpecificOptionalServices) > 0
			Begin
				Set @SpecificOptionalServicesTemp = Substring(@SpecificOptionalServices, 0, Patindex('%,%', @SpecificOptionalServices))
				Insert Into @COMCODETABLE (COMCODE) Values (@SpecificOptionalServicesTemp)
				Set @SpecificOptionalServices = Substring(@SpecificOptionalServices, Len(@SpecificOptionalServicesTemp) + 2, Len(@SpecificOptionalServices))
			End
		Else
			Begin
				Set @SpecificOptionalServicesTemp = @SpecificOptionalServices
				Insert Into @COMCODETABLE (COMCODE) Values (@SpecificOptionalServicesTemp)
				Set @SpecificOptionalServices = Null
			End
	End

/*-------------------------------------------------------------------------------------------------------------------------------------------
|	POPULATE VARIABLE TABLES - (CONDITIONS)																									|
|	(Optional Step)																															|
|	----------------------------------------------------------------------------															|
|	This will break your (@ConditionNameString) claim into individual Condition Descriptions and store them in (@CONDITIONNAMETABLE).		|
|	It will then insert ConditionID(s) values into the variable table (@CONDITIONIDTABLE) where these descriptions apply.					|
|	(This configuration should only be used if you are needing new Filing Codes to be added to OFS and/or CMS routing rules.)				|
-------------------------------------------------------------------------------------------------------------------------------------------*/
Declare @ConditionNameStringTemp		varchar(max)
Declare @CONDITIONNAMETABLE				table(CONDITION varchar(100))
Declare @CONDITIONIDTABLE				table(CONID int, CONDITION varchar(100))

While Len(@ConditionNameString) > 0
	Begin
		If Patindex('%,%',@ConditionNameString) > 0
			Begin
				Set @ConditionNameStringTemp = Substring(@ConditionNameString, 0, Patindex('%,%', @ConditionNameString))
				Insert Into @CONDITIONNAMETABLE (CONDITION) Values (@ConditionNameStringTemp)
				Set @ConditionNameString = Substring(@ConditionNameString, Len(@ConditionNameStringTemp) + 2, Len(@ConditionNameString))
			End
		Else
			Begin
				Set @ConditionNameStringTemp = @ConditionNameString
				Insert Into @CONDITIONNAMETABLE (CONDITION) Values (@ConditionNameStringTemp)
				Set @ConditionNameString = Null
			End
	End

Insert Into @CONDITIONIDTABLE (CONID, CONDITION)
	Select Distinct ConditionID, Description
	from Config.Condition
	where Description in
		(
		Select Distinct CONDITION
		from @CONDITIONNAMETABLE
		)

/*================================================================================================================================================
||	ADD FILING CODE(S)																															||
||	----------------------------------------------------------------------------																||
||	This will add your Filing CodeID(s) to the client's configuration.																			||
||	CodeID(s) will be added to the following tables, unless it already exists.																	||
||	(If the CodeID was previously configured, the rows will be updated to the desired attribute settings.										||
================================================================================================================================================*/

/*================================================================================================
||	SET FILING CODE VISIBILITY																	||
||	----------------------------------------------------------------------------				||
||	CONFIG.XCODENODE																			||
================================================================================================*/
/*-------------------------------------------------------------------------------
|	DELETE OLD REFERENCES														|
-------------------------------------------------------------------------------*/
Delete from Config.xCodeNode
where NodeID in
	(
	Select NODEID
	from @NODEIDTABLE
	)
and CodeID in
	(
	Select FCID
	from @FCIDTABLE
	)

Delete from Config.xCodeNode
where NodeID in
	(
	Select Distinct NODEID
	from @EXCLUSIONNODEIDTABLE
	)
and CodeID in
	(
	Select FCID
	from @FCIDTABLE
	)

/*-------------------------------------------------------------------------------
|	INSERT																		|
-------------------------------------------------------------------------------*/
Insert Into Config.xCodeNode (NodeID, CodeID, Visible, IsDefault)
	Select Distinct nd.NODEID, fc.FCID, 1, 0
	from
		(
		Select NODEID
		from @NODEIDTABLE
		) as nd
	cross join
		(
		Select FCID
		from @FCIDTABLE
		) as fc
	where not exists
		(
		Select 1
		from Config.xCodeNode xcn
		where xcn.NodeID = nd.NODEID and xcn.CodeID = fc.FCID
		)

Insert Into Config.xCodeNode (NodeID, CodeID, Visible, IsDefault)
	Select Distinct nd.NODEID, fc.FCID, 0, 0
	from
		(
		Select NODEID
		from @EXCLUSIONNODEIDTABLE
		) as nd
	cross join
		(
		Select FCID
		from @FCIDTABLE
		) as fc
	where not exists
		(
		Select 1
		from Config.xCodeNode xcn
		where xcn.NodeID = nd.NODEID and xcn.CodeID = fc.FCID
		)

/*================================================================================================
||	SET FILING CODE OVERRIDES																	||
||	----------------------------------------------------------------------------				||
||	CONFIG.XCODENODE_FILINGCODE																	||
================================================================================================*/
/*-------------------------------------------------------------------------------
|	DELETE OLD REFERENCES														|
-------------------------------------------------------------------------------*/
Delete from Config.xCodeNode_FilingCode
where NodeID in
	(
	Select Distinct NODEID
	from @NODEIDTABLE
	)
and FilingCodeID in
	(
	Select Distinct FCID
	from @FCIDTABLE
	)

/*-------------------------------------------------------------------------------
|	INSERT																		|
-------------------------------------------------------------------------------*/
Insert Into Config.xCodeNode_FilingCode (NodeID, FilingCodeID, FilingComponentCodeOverride, FeeScheduleCodeOverride)
	Select Distinct nd.NODEID, fc.FCID, 1, 1
	from
		(
		Select NODEID
		from @NODEIDTABLE
		) as nd
	cross join
		(
		Select FCID
		from @FCIDTABLE
		) as fc
	where not exists
		(
		Select 1
		from Config.xCodeNode_FilingCode xfc
		where xfc.NodeID = nd.NODEID and xfc.FilingCodeID = fc.FCID
		)

/*================================================================================================
||	SET FILING CODE ATTRIBUTES																	||
||	----------------------------------------------------------------------------				||
||	CONFIG.CODENODEEXT_FILINGCODE																||
================================================================================================*/
Declare @InitialID		int		=	0
Declare @SubsequentID	int		=	0
Declare @CourtUseID		int		=	0

If @Initial = 'YES'
	Begin
		Set @InitialID = 1
	End
If @Subsequent = 'YES'
	Begin
		Set @SubsequentID = 1
	End
If @CourtUse = 'YES'
	Begin
		Set @CourtUseID = 1
	End

/*-------------------------------------------------------------------------------
|	DELETE OLD REFERENCES														|
-------------------------------------------------------------------------------*/
Delete from Config.CodeNodeExt_FilingCode
where NodeID in
	(
	Select Distinct NODEID
	from @NODEIDTABLE
	)
and CodeID in
	(
	Select Distinct FCID
	from @FCIDTABLE
	)

/*-------------------------------------------------------------------------------
|	INSERT																		|
-------------------------------------------------------------------------------*/
Insert Into Config.CodeNodeExt_FilingCode (NodeID, CodeID, AllowInitial, AllowSubsequent, IsCourtUseOnly, LegalProcessCodeID, SpecialBehaviorTypeCodeID, CMSServiceTypeCode)
	Select Distinct nd.NODEID, fc.FCID, @InitialID, @SubsequentID, @CourtUseID, null, null, null
	from
		(
		Select NODEID
		from @NODEIDTABLE
		) as nd
	cross join
		(
		Select FCID
		from @FCIDTABLE
		) as fc
	where not exists
		(
		Select 1
		from Config.CodeNodeExt_FilingCode efc
		where efc.NodeID = nd.NODEID and efc.CodeID = fc.FCID
		)

/*================================================================================================
||	LINK FILING CODE BY CASE CATEGORY OR CASE TYPE												||
||	----------------------------------------------------------------------------				||
||	CONFIG.XCASECATEGORYCODE_FILINGCODE															||
||	CONFIG.XCASETYPECODE_FILINGCODE																||
================================================================================================*/
/*-------------------------------------------------------------------------------
|	DELETE OLD REFERENCES														|
-------------------------------------------------------------------------------*/
If not exists
	(
	Select 1
	from @CTIDTABLE
	)
	Begin
		Delete from Config.xCaseCategoryCode_FilingCode
			where NodeID in
				(
				Select Distinct NODEID
				from @NODEIDTABLE
				)
			and FilingCodeID in
				(
				Select Distinct FCID
				from @FCIDTABLE
				)
			and CaseCategoryCodeID not in
				(
				Select Distinct CCID
				from @CCIDTABLE
				)
	End
Else
	Begin
		Delete from Config.xCaseTypeCode_FilingCode
		where NodeID in
			(
			Select Distinct NODEID
			from @NODEIDTABLE
			)
		and CaseTypeCodeID in
			(
			Select Distinct CTID
			from @CTIDTABLE
			)
		and FilingCodeID in
			(
			Select Distinct FCID
			from @FCIDTABLE
			)
	End

/*-------------------------------------------------------------------------------
|	INSERT																		|
-------------------------------------------------------------------------------*/
If not exists
	(
	Select 1
	from @CTIDTABLE
	)
	Begin
		Insert Into Config.xCaseCategoryCode_FilingCode (NodeID, CaseCategoryCodeID, FilingCodeID)
			Select Distinct cc.NODEID, cc.CCID, fc.FCID
			from
				(
				Select NODEID, CCID
				from @CCIDTABLE
				) as cc
			cross join
				(
				Select FCID
				from @FCIDTABLE
				) as fc
			where not exists
				(
				Select 1
				from Config.xCaseCategoryCode_FilingCode ccfc
				where ccfc.NodeID = cc.NODEID and ccfc.CaseCategoryCodeID = cc.CCID and ccfc.FilingCodeID = fc.FCID
				)
	End
Else
	Begin
		Insert Into Config.xCaseTypeCode_FilingCode (NodeID, CaseTypeCodeID, FilingCodeID)
			Select Distinct ct.NODEID, ct.CTID, fc.FCID
			from
				(
				Select NODEID, CTID
				from @CTIDTABLE
				) as ct
			cross join
				(
				Select FCID
				from @FCIDTABLE
				) as fc
			where not exists
				(
				Select 1
				from Config.xCaseTypeCode_FilingCode ctfc
				where ctfc.NodeID = ct.NODEID and ctfc.CaseTypeCodeID = ct.CTID and ctfc.FilingCodeID = fc.FCID
				)

		Update x
		Set FilingCodeOverride = 1
		from Config.xCodeNode_CaseType x
		join @CTIDTABLE i on i.NODEID = x.NodeID and i.CTID = x.CaseTypeCodeID
	End

/*================================================================================================
||	SET CODE EFSP																				||
||	(Optional Step)																				||
||	----------------------------------------------------------------------------				||
||	CONFIG.XCODENODE_CODEEFSP																	||
================================================================================================*/
If Len(@CodeEFSP) > 0
	Begin
		/*-------------------------------------------------------------------------------
		|	DELETE OLD REFERENCES														|
		-------------------------------------------------------------------------------*/
		Delete from Config.xCodeNode_CodeEFSP
		where NodeID in
			(
			Select Distinct NODEID
			from @NODEIDTABLE
			)
		and CodeID in
			(
			Select Distinct FCID
			from @FCIDTABLE
			)

		/*-------------------------------------------------------------------------------
		|	INSERT																		|
		-------------------------------------------------------------------------------*/
		Insert Into Config.xCodeNode_CodeEFSP (NodeID, CodeEFSP, CodeID)
			Select Distinct nd.NODEID, @CodeEFSP, fc.FCID
			from
				(
				Select NODEID
				from @NODEIDTABLE
				) as nd
			cross join
				(
				Select FCID
				from @FCIDTABLE
				) as fc
			where not exists
				(
				Select 1
				from Config.xCodeNode_CodeEFSP efsp
				where efsp.NodeID = nd.NODEID and CodeEFSP = @CodeEFSP and efsp.CodeID = fc.FCID
				)
	End

/*================================================================================================
||	LINK FEE SCHEDULE CODE																		||
||	(Optional Step)																				||
||	----------------------------------------------------------------------------				||
||	CONFIG.CODENODEEXT_FEESCHEDULECODE															||
||	CONFIG.XFILINGCODE_FEESCHEDULECODE															||
================================================================================================*/
If exists
	(
	Select 1
	from @FSIDTABLE
	)
	Begin
		/*-------------------------------------------------------------------------------
		|	INSERT FEE SCHEDULES ATTRIBUTES												|
		-------------------------------------------------------------------------------*/
		Insert Into Config.CodeNodeExt_FeeScheduleCode (NodeID, CodeID, Amount)
			Select Distinct f.NODEID, f.FSID, f.AMT
			from @FSIDTABLE f
			where not exists
				(
				Select 1
				from Config.CodeNodeExt_FeeScheduleCode e
				where e.NodeID = f.NODEID and e.CodeID = f.FSID
				)

		/*-------------------------------------------------------------------------------
		|	INSERT FEE SCHEDULE VISIBILITY												|
		-------------------------------------------------------------------------------*/
		Insert Into Config.xCodeNode (NodeID, CodeID, Visible, IsDefault)
			Select Distinct f.NODEID, f.FSID, 1, 0
			from @FSIDTABLE f
			where exists
				(
				Select 1
				from Config.CodeNodeExt_FeeScheduleCode e
				where e.NodeID = f.NODEID and e.CodeID = f.FSID and e.Amount = f.AMT
				)
			and not exists
				(
				Select 1
				from Config.xCodeNode x
				where x.NodeID = f.NODEID and x.CodeID = f.FSID
				)

		/*-------------------------------------------------------------------------------
		|	DELETE OLD REFERENCES														|
		-------------------------------------------------------------------------------*/
		Delete from Config.xFilingCode_FeeScheduleCode
		where NodeID in
			(
			Select NODEID
			from @NODEIDTABLE
			)
		and FilingCodeID in
			(
			Select FCID
			from @FCIDTABLE
			)

		If len(@FeeScheduleCode) > 0
			Begin
				/*-------------------------------------------------------------------------------
				|	INSERT RELATIONSHIP															|
				-------------------------------------------------------------------------------*/
				Insert Into Config.xFilingCode_FeeScheduleCode (NodeID, FilingCodeID, FeeScheduleCodeID)
					Select Distinct fs.NODEID, fc.FCID, fs.FSID
					from
						(
						Select NODEID, FSID
						from @FSIDTABLE
						) as fs
					cross join
						(
						Select FCID
						from @FCIDTABLE
						) as fc
			End
	End

/*================================================================================================================================================
||	LINK STANDARD OPTIONAL SERVICES																												||
||	----------------------------------------------------------------------------																||
||	Adds Lead Document and Attachments to new Filing Codes.																						||
||	(Attachments will only be added if it is visible for the client.)																			||
================================================================================================================================================*/
Insert Into Config.xFilingCode_FilingComponentCode (NodeID, FilingCodeID, FilingComponentCodeID, Required, AllowFile, AllowMultipleFiles, DisplayOrder, IsAdditionalService)
	Select Distinct nd.NODEID, fc.FCID, 332, 1, 1, 0, 0, 0
	from
		(
		Select NODEID
		from @NODEIDTABLE
		) as nd
	cross join
		(
		Select FCID
		from @FCIDTABLE
		) as fc
	where not exists
		(
		Select 1
		from Config.xFilingCode_FilingComponentCode fccom
		where fccom.NodeID = nd.NODEID and fccom.FilingCodeID = fc.FCID and fccom.FilingComponentCodeID = 332
		)

Insert Into Config.xFilingCode_FilingComponentCode (NodeID, FilingCodeID, FilingComponentCodeID, Required, AllowFile, AllowMultipleFiles, DisplayOrder, IsAdditionalService)
	Select Distinct nd.NODEID, fc.FCID, 331, 0, 1, 1, 1, 0
	from
		(
		Select NODEID
		from @NODEIDTABLE
		) as nd
	cross join
		(
		Select FCID
		from @FCIDTABLE
		) as fc
	where not exists
		(
		Select 1
		from Config.xFilingCode_FilingComponentCode fccom
		where fccom.NodeID = nd.NODEID and fccom.FilingCodeID = fc.FCID and fccom.FilingComponentCodeID = 331
		)
	and exists
		(
		Select NodeID, CodeID
		from Config.vwFilingComponentCode com
		where com.NodeID = nd.NODEID and com.CodeID = 331
		)

/*================================================================================================================================================
||	LINK ADDITIONAL OPTIONAL SERVICES																											||
||	(Optional Step)																																||
||	----------------------------------------------------------------------------																||
||	Links all other Optional Services to new Filing Code(s) when user selects "YES" to (@LinkOptionalServices).									||
||	(Optional Services with existing relationships to Filing Codes in the selected Case Category will be linked)								||
||	(Optional Services with existing relationships to Filing Codes in the selected Case Category will be linked)								||
================================================================================================================================================*/

/*---------------------------------------------------------------------------------------------------------------
|	POPULATE VARIABLE TABLES - (FILING COMPONENT CODE)															|
|	----------------------------------------------------------------------------								|
|	This step populates 3 variable tables.  They functions of each are:											|
|		(@ALLFCIDTABLE)		-	Maps all Filing Codes per NodeID.												|
|		(@ALLCOMIDTABLE)	-	Maps all Filing Component Codes per NodeID.										|
|		(@FCCOMIDTABLE)		-	Maps the relationships between Filing Codes and Filing Components per NodeID.	|
---------------------------------------------------------------------------------------------------------------*/
If @LinkOptionalServices = 'YES'
	Begin
		Declare @ALLFCIDTABLE					table(NODEID int, FCID int)
		Declare @ALLCOMIDTABLE					table(NODEID int, COMID int, COMCODE varchar(25))
		Declare @FCCOMIDTABLE					table(NODEID int, FCID int, COMID int, COMCODE varchar(25))

		If exists
			(
			Select 1
			from @CCIDTABLE
			)
			Begin
				Insert Into @ALLFCIDTABLE (NODEID, FCID)
					Select Distinct ccfc.NodeID, fc.CodeID
					from Config.vwxCaseCategoryCodeFilingCode ccfc
					join Config.vwFilingCode fc on fc.NodeID = ccfc.NodeID and fc.CodeID = ccfc.FilingCodeID
					where ccfc.NodeID in
						(
						Select NODEID
						from @NODEIDTABLE
						)
					and CaseCategoryCodeID in
						(
						Select Distinct CCID
						from @CCIDTABLE
						)
					and FilingCodeID not in (-365)

				Insert Into @ALLCOMIDTABLE (NODEID, COMID, COMCODE)
					Select Distinct NodeID, CodeID, Code
					from Config.vwFilingComponentCode
					where NodeID in
						(
						Select NODEID
						from @NODEIDTABLE
						)
					and CodeID not in (-364, 331, 332)

				Insert Into @FCCOMIDTABLE (NODEID, FCID, COMID, COMCODE)
					Select Distinct fc.NODEID, fc.FCID, com.COMID, com.COMCODE
					from
						(
						Select NODEID, FCID
						from @ALLFCIDTABLE
						) as fc
					cross join
						(
						Select COMID, COMCODE
						from @ALLCOMIDTABLE
						) as com
					where exists
						(
						Select 1
						from Config.vwxFilingCodeFilingComponentCode fccom
						where fccom.NodeID = fc.NODEID and fccom.FilingCodeID = fc.FCID and fccom.FilingComponentCodeID = com.COMID
						)
			End

		/*-----------------------------------------------------------------------------------------------------------------------------------------------------------
		|	CONFIG.XFILINGCODE_FILINGCOMPONENTCODE																													|
		|	----------------------------------------------------------------------------																			|
		|	Sets relationships between Filing CodeID's and Filing Component CodeID's per NodeID.																	|
		|	(These entries are based off the client's current configuration.)																						|
		|	(e.g. If the client has CV Filing Components mapped to FAM Filing Codes, the execution of this script will not be as desired.)							|
		|	(If you don't like the desire results, you can list the specific optional service codes you want linked in the (@SpecificOptionalServices) claim.)		|
		-----------------------------------------------------------------------------------------------------------------------------------------------------------*/
		If exists
			(
			Select Top 1 COMCODE
			from @COMCODETABLE
			)
			Begin
				Insert Into Config.xFilingCode_FilingComponentCode (NodeID, FilingCodeID, FilingComponentCodeID, Required, AllowFile, AllowMultipleFiles, DisplayOrder, IsAdditionalService)
				Select Distinct fccom.NODEID, fc.FCID, fccom.COMID, 0, 0, 0, 0, 1
				from
					(
					Select NODEID, COMID, COMCODE
					from @ALLCOMIDTABLE
					) as fccom
				cross join
					(
					Select FCID
					from @FCIDTABLE
					) as fc
				where fccom.COMID not in (331,332,-364)
				and fccom.COMCODE in
					(
					Select Distinct COMCODE
					from @COMCODETABLE
					)
				and not exists
					(
					Select 1
					from Config.xFilingCode_FilingComponentCode fccom2
					where fccom2.NodeID = fccom.NODEID and fccom2.FilingCodeID = fc.FCID and fccom2.FilingComponentCodeID = fccom.COMID
					)
			End
		Else
			Begin
				Insert Into Config.xFilingCode_FilingComponentCode (NodeID, FilingCodeID, FilingComponentCodeID, Required, AllowFile, AllowMultipleFiles, DisplayOrder, IsAdditionalService)
				Select Distinct fccom.NODEID, fc.FCID, fccom.COMID, 0, 0, 0, 0, 1
				from
					(
					Select NODEID, COMID
					from @FCCOMIDTABLE
					) as fccom
				cross join
					(
					Select FCID
					from @FCIDTABLE
					) as fc
				where fccom.COMID not in (331,332,-364)
				and not exists
					(
					Select 1
					from Config.xFilingCode_FilingComponentCode fccom2
					where fccom2.NodeID = fccom.NODEID and fccom2.FilingCodeID = fc.FCID and fccom2.FilingComponentCodeID = fccom.COMID
					)
			End
	End

/*================================================================================================================================================
||	LINK FILING CODE TO DOCUMENT TYPE																											||
||	(Optional Step)																																||
||	----------------------------------------------------------------------------																||
||	Links new Filing Codes to Document Types selected on the (@DocumentTypeIsDefault) and (@DocumentTypeIsNotDefault) user claims				||
||	(Please note that this functionality will only work if the client has Odyssey Document Security Groups enabled in eFile)					||
================================================================================================================================================*/

/*-------------------------------------------------------------------------------------------------------------------------------------------
|	POPULATE VARIABLE TABLES - (DOCUMENT CODE)																								|
|	----------------------------------------------------------------------------															|
|	Mapping Filing Codes to Document Type Codes requires inserts into the NodeID's previously stated and all subsequent NodeID's.			|
|	This step populates 3 variable tables.  They functions of each are:																		|
|		(@ROOTNODETABLE)		-	Creates a map of subsequent NodeID's for previously defined NodeID's.									|
|		(@DTDESCRIPTIONTABLE)	-	Creates a map of Document Type descriptions, and whether or not Filing Codes should default to them.	|
|		(@DTCODETABLE)			-	Creates a map of Document Type CodeID's per the previously defined NodeID's.							|
|		(@DTIDTABLE)			-	Creates the final maps of relationships between Filing Codes and Document Type Codes to insert.			|
-------------------------------------------------------------------------------------------------------------------------------------------*/
Declare @DTIDTABLE			table(NODEID int, DTID int, DTDEFAULT bit)

If Len(@DocumentTypeIsDefault) > 0 or Len(@DocumentTypeIsNotDefault) > 0
	Begin
		Declare @TempDocumentType		varchar(max)
		Declare @ROOTNODETABLE			table(PARENTID int, NODEID int)
		Declare @DTDESCRIPTIONTABLE		table(DTDESC varchar(max), DTDEFAULT bit)
		Declare @DTCODETABLE			table(NODEID int, DTID int, DTCODE varchar(max), DTDESC varchar(max), DTDEFAULT bit)

		/*-------------------------------------------------------
		|	@ROOTNODETABLE										|
		-------------------------------------------------------*/
		Insert Into @ROOTNODETABLE (PARENTID, NODEID)
			Select NodeID, ChildNodeID
			from Operations.Report.RootNodeCache
			where NodeID in
				(
				Select Distinct NODEID
				from @NODEIDTABLE
				)

		/*-------------------------------------------------------
		|	@DTDESCRIPTIONTABLE									|
		-------------------------------------------------------*/
		While Len(@DocumentTypeIsDefault) > 0
			Begin
				If Patindex('%,%', @DocumentTypeIsDefault) > 0
					Begin
						Set @TempDocumentType = Substring(@DocumentTypeIsDefault, 0, Patindex('%,%', @DocumentTypeIsDefault))
						Insert Into @DTDESCRIPTIONTABLE (DTDESC, DTDEFAULT) Values (@TempDocumentType, 1)
						Set @DocumentTypeIsDefault = Substring(@DocumentTypeIsDefault, Len(@TempDocumentType) + 2, Len(@DocumentTypeIsDefault))
					End
				Else
					Begin
						Set @TempDocumentType = @DocumentTypeIsDefault
						Insert Into @DTDESCRIPTIONTABLE (DTDESC, DTDEFAULT) Values (@TempDocumentType, 1)
						Set @DocumentTypeIsDefault = Null
					End
			End

		While Len(@DocumentTypeIsNotDefault) > 0
			Begin
				If Patindex('%,%', @DocumentTypeIsNotDefault) > 0
					Begin
						Set @TempDocumentType = Substring(@DocumentTypeIsNotDefault, 0, Patindex('%,%', @DocumentTypeIsNotDefault))
						Insert Into @DTDESCRIPTIONTABLE (DTDESC, DTDEFAULT) Values (@TempDocumentType, 0)
						Set @DocumentTypeIsNotDefault = Substring(@DocumentTypeIsNotDefault, Len(@TempDocumentType) + 2, Len(@DocumentTypeIsNotDefault))
					End
				Else
					Begin
						Set @TempDocumentType = @DocumentTypeIsNotDefault
						Insert Into @DTDESCRIPTIONTABLE (DTDESC, DTDEFAULT) Values (@TempDocumentType, 0)
						Set @DocumentTypeIsNotDefault = Null
					End
			End

		/*-------------------------------------------------------
		|	@DTCODETABLE										|
		-------------------------------------------------------*/
		Insert Into @DTCODETABLE (NODEID, DTID, DTCODE, DTDESC, DTDEFAULT)
			Select Distinct nd.NODEID, dt.CodeID, dt.Code, dtdesc.DTDESC, dtdesc.DTDEFAULT
			from
				(
				Select CodeID, Code
				from Config.vwDocumentTypeCode
				where NodeID in
					(
					Select Distinct NODEID
					from @NODEIDTABLE
					)
				and Description in
					(
					Select Distinct DTDESC
					from @DTDESCRIPTIONTABLE
					)
				) as dt
			cross join
				(
				Select DTDESC, DTDEFAULT
				from @DTDESCRIPTIONTABLE
				) as dtdesc
			cross join
				(
				Select NODEID
				from @NODEIDTABLE
				) as nd
			where exists
				(
				Select 1
				from Config.vwDocumentTypeCode vdt
				where vdt.NodeID = nd.NODEID and vdt.CodeID = dt.CodeID and vdt.Code = dt.Code and vdt.Description = dtdesc.DTDESC
				)

		/*-------------------------------------------------------
		|	@DTIDTABLE											|
		-------------------------------------------------------*/
		Insert Into @DTIDTABLE (NODEID, DTID, DTDEFAULT)
			Select Distinct rnd.NODEID, dt.DTID, dt.DTDEFAULT
			from
				(
				Select PARENTID, NODEID
				from @ROOTNODETABLE
				) as rnd
			cross join
				(
				Select NODEID, DTID, DTDEFAULT
				from @DTCODETABLE
				) as dt
			where dt.NODEID = rnd.PARENTID

		/*-----------------------------------------------------------------------------------------------
		|	CONFIG.XFILINGCODE_DOCUMENTTYPECODE															|
		|	----------------------------------------------------------------------------				|
		|	Sets relationships between Filing CodeID's and Document Type CodeID's per NodeID.			|
		-----------------------------------------------------------------------------------------------*/
		Insert Into Config.xFilingCode_DocumentTypeCode (NodeID, FilingCodeID, DocumentTypeCodeID, IsDefault, TimestampChecked, TimestampCreate, TimestampChange)
			Select Distinct dt.NODEID, fc.FCID, dt.DTID, dt.DTDEFAULT, getdate(), getdate(), null
			from
				(
				Select FCID
				from @FCIDTABLE
				) as fc
			cross join
				(
				Select NODEID, DTID, DTDEFAULT
				from @DTIDTABLE
				) as dt
			where not exists
				(
				Select 1
				from Config.xFilingCode_DocumentTypeCode fcdt
				where fcdt.NodeID = dt.NODEID and fcdt.FilingCodeID = fc.FCID and fcdt.DocumentTypeCodeID = dt.DTID
				)
	End

/*================================================================================================================================================
||	LINK FILING CODE TO CONDITIONS																												||
||	(Optional Step)																																||
||	----------------------------------------------------------------------------																||
||	Links new Filing Codes to Conditions that apply to OFS and/or CMS routing.																	||
================================================================================================================================================*/
If exists
	(
	Select 1
	from @CONDITIONIDTABLE
	)
	Begin
		Insert Into Config.xCondition_FilingCode (ConditionID, FilingCodeID, IsActive, TimestampCreate, UserIDCreate)
		Select Distinct con.CONID, fc.FCID, 1, getdate(), '00000000-0000-0000-0000-000000000000'
		from
			(
			Select FCID
			from @FCIDTABLE
			) as fc
		cross join
			(
			Select CONID
			from @CONDITIONIDTABLE
			) as con
		where not exists
			(
			Select 1
			from Config.xCondition_FilingCode confc
			where confc.FilingCodeID = fc.FCID and confc.ConditionID = con.CONID
			)

		Update Config.xCondition_FilingCode
		Set IsActive = 1
		where ConditionID in
			(
			Select Distinct CONID
			from @CONDITIONIDTABLE
			)
		and FilingCodeID in
			(
			Select Distinct fc.FCID
			from @FCIDTABLE fc
			)
	End

--============================================================================================================================================================================
--	SCRIPT REPORT
--============================================================================================================================================================================
If (@SaveChanges = 'YES')
	Begin
		Select 'YES' as 'CHANGES SAVED'
	End
Else
	Begin
		Select 'NO' as 'CHANGES SAVED'
	End
---------------------------------------------------------
Select 'FILING CODE (FC)' as 'FILING CODE ADDED', xcn.NodeID as 'NODEID', oc.OrgChartName as 'LOCATION',
Case when xcn.Visible = 1 then 'YES' else 'NO' end as 'VISIBLE',
fc.Code + ' | ' + cast(xcn.CodeID as varchar) as 'REFERENCE', fc.Description as 'DESCRIPTION',
Case when fc.AllowInitial = 1 then 'YES' else 'NO' end as 'INITIAL', Case when fc.AllowSubsequent = 1 then 'YES' else 'NO' end as 'SUBSEQUENT', Case when fc.IsCourtUseOnly = 1 then 'YES' else 'NO' end as 'COURT USE', Case when fc.SendToCMS = 1 then 'YES' else 'NO' end as 'SEND TO CMS', Case when fc.IsProposedOrder = 1 then 'YES' else 'NO' end as 'PROPOSED ORDER',
efsp.CodeEFSP as 'CODE EFSP'
from Config.xCodeNode xcn
left join Config.OrgChart oc on oc.NodeID = xcn.NodeID
left join Config.vwFilingCode fc on fc.CodeID = xcn.CodeID and fc.NodeID = xcn.NodeID
left join Config.xCodeNode_CodeEFSP efsp on efsp.NodeID = xcn.NodeID and efsp.CodeID = fc.CodeID
where xcn.CodeID in
	(
	Select fc.FCID
	from @FCIDTABLE fc
	)
and xcn.NodeID in
	(
	Select NODEID
	from @NODEIDTABLE
	)

Union

Select 'FILING CODE (FC)' as 'FILING CODE ADDED', xcn.NodeID as 'NODEID', oc.OrgChartName as 'LOCATION',
Case when xcn.Visible = 1 then 'YES' else 'NO' end as 'VISIBLE',
c.Code as 'REFERENCE', c.Description as 'DESCRIPTION', 'N/A' as 'INITIAL', 'N/A' as 'SUBSEQUENT', 'N/A' as 'COURT USE', 'N/A' as 'SEND TO CMS', 'N/A' as 'PROPOSED ORDER', 'N/A' as 'CODE EFSP'
from Config.xCodeNode xcn
left join Config.OrgChart oc on oc.NodeID = xcn.NodeID
left join Config.Code c on c.CodeID = xcn.CodeID
where xcn.CodeID in
	(
	Select fc.FCID
	from @FCIDTABLE fc
	)
and xcn.NodeID in
	(
	Select NODEID
	from @EXCLUSIONNODEIDTABLE
	)
order by xcn.NodeID, fc.Description
---------------------------------------------------------
If not exists
	(
	Select 1
	from @CTIDTABLE
	)
	Begin
		Select Distinct 'CASE CATEGORY (CC)' as 'LINKED RELATIONSHIP', ccfc.NodeID as 'NODEID', oc.OrgChartName as 'LOCATION', fc.Code + ' | ' + cast(ccfc.FilingCodeID as varchar) as 'REFERENCE (FC)',
		fc.Description as 'DESCRIPTION (FC)', cc.Code + ' | ' + cast(ccfc.CaseCategoryCodeID as varchar) as 'REFERENCE (CC)', cc.Description as 'DESCRIPTION (CC)'
		from Config.vwxCaseCategoryCodeFilingCode ccfc
		left join Config.OrgChart oc on oc.NodeID = ccfc.NodeID
		left join Config.vwFilingCode fc on fc.CodeID = ccfc.FilingCodeID and fc.NodeID = ccfc.NodeID
		left join Config.vwCaseCategoryCode cc on cc.CodeID = ccfc.CaseCategoryCodeID and cc.NodeID = ccfc.NodeID
		where ccfc.FilingCodeID in
			(
			Select fc.FCID
			from @FCIDTABLE fc
			)
		and ccfc.NodeID in
			(
			Select NODEID
			from @NODEIDTABLE
			)
		order by ccfc.NodeID, fc.Description, cc.Description
	End
---------------------------------------------------------
If exists
	(
	Select 1
	from @CTIDTABLE
	)
	Begin
		Select Distinct 'CASE TYPE (CT)' as 'LINKED RELATIONSHIP', ctfc.NodeID as 'NODEID', oc.OrgChartName as 'LOCATION', fc.Code + ' | ' + cast(ctfc.FilingCodeID as varchar) as 'REFERENCE (FC)',
		fc.Description as 'DESCRIPTION (FC)', ct.Code + ' | ' + cast(ctfc.CaseTypeCodeID as varchar) as 'REFERENCE (CT)', ct.Description as 'DESCRIPTION (CT)'
		from Config.vwxCaseTypeCodeFilingCode ctfc
		left join Config.OrgChart oc on oc.NodeID = ctfc.NodeID
		left join Config.vwFilingCode fc on fc.CodeID = ctfc.FilingCodeID and fc.NodeID = ctfc.NodeID
		left join Config.vwCaseType ct on ct.CodeID = ctfc.CaseTypeCodeID and ct.NodeID = ctfc.NodeID
		where ctfc.FilingCodeID in
			(
			Select fc.FCID
			from @FCIDTABLE fc
			)
		and ctfc.NodeID in
			(
			Select NODEID
			from @NODEIDTABLE
			)
		order by ctfc.NodeID, fc.Description, ct.Description
	End
---------------------------------------------------------
If Len(@CodeEFSP) > 0
	Begin
		Select Distinct 'OGF CONFIG' as 'FILING CODE BEHAVIOR', efsp.NodeID as 'NODEID', oc.OrgChartName as 'LOCATION', fc.Code + ' | ' + cast(efsp.CodeID as varchar) as 'REFERENCE (FC)',
		fc.Description as 'DESCRIPTION (FC)', efsp.CodeEFSP as 'CODE EFSP'
		from Config.xCodeNode_CodeEFSP efsp
		left join Config.OrgChart oc on oc.NodeID = efsp.NodeID
		left join Config.vwFilingCode fc on fc.CodeID = efsp.CodeID and fc.NodeID = efsp.NodeID
		where efsp.CodeID in
			(
			Select fc.FCID
			from @FCIDTABLE fc
			)
		and efsp.NodeID in
			(
			Select NODEID
			from @NODEIDTABLE
			)
		order by efsp.NodeID, fc.Description, efsp.CodeEFSP
	End
---------------------------------------------------------
If Len(@FeeScheduleCode) > 0
	Begin
		Select Distinct 'FEE SCHEDULE (FF)' as 'LINKED RELATIONSHIP', fcff.NodeID as 'NODEID', oc.OrgChartName as 'LOCATION', fc.Code + ' | ' + cast(fcff.FilingCodeID as varchar) as 'REFERENCE (FC)',
		fc.Description as 'DESCRIPTION (FC)', ff.Code + ' | ' + cast(fcff.FeeScheduleCodeID as varchar) as 'REFERENCE (FF)', ff.Description as 'DESCRIPTION (FF)', ff.Amount as 'AMOUNT (FF)'
		from Config.vwxFilingCodeFeeScheduleCode fcff
		left join Config.OrgChart oc on oc.NodeID = fcff.NodeID
		left join Config.vwFilingCode fc on fc.CodeID = fcff.FilingCodeID and fc.NodeID = fcff.NodeID
		left join Config.vwFeeScheduleCode ff on ff.CodeID = fcff.FeeScheduleCodeID and ff.NodeID = fcff.NodeID
		where fcff.FilingCodeID in
			(
			Select fc.FCID
			from @FCIDTABLE fc
			)
		and fcff.NodeID in
			(
			Select NODEID
			from @NODEIDTABLE
			)
		order by fcff.NodeID, fc.Description, ff.Description
	End
---------------------------------------------------------
Select Distinct 'OPTIONAL SERVICES (COM)' as 'LINKED RELATIONSHIP', fccom.NodeID as 'NODEID', oc.OrgChartName as 'LOCATION', fc.Code + ' | ' + cast(fccom.FilingCodeID as varchar) as 'REFERENCE (FC)',
fc.Description as 'DESCRIPTION (FC)', com.Code + ' | ' + cast(fccom.FilingComponentCodeID as varchar) as 'REFERENCE (COM)', com.Description as 'DESCRIPTION (COM)'
from Config.vwxFilingCodeFilingComponentCode fccom
left join Config.OrgChart oc on oc.NodeID = fccom.NodeID
left join Config.vwFilingCode fc on fc.CodeID = fccom.FilingCodeID and fc.NodeID = fccom.NodeID
left join Config.vwFilingComponentCode com on com.CodeID = fccom.FilingComponentCodeID and com.NodeID = fccom.NodeID
where fccom.FilingComponentCodeID not in (-364)
and fccom.FilingCodeID in
	(
	Select fc.FCID
	from @FCIDTABLE fc
	)
and fccom.NodeID in
	(
	Select NODEID
	from @NODEIDTABLE
	)
order by fccom.NodeID, fc.Description, com.Description
---------------------------------------------------------
If exists
	(
	Select Top 1 DTID
	from @DTIDTABLE
	)
	Begin
		Select Distinct 'DOCUMENT TYPES (DT)' as 'LINKED RELATIONSHIP', fcdt.NodeID as 'NODEID', oc.OrgChartName as 'LOCATION', fc.Code + ' | ' + cast(fcdt.FilingCodeID as varchar) as 'REFERENCE (FC)', fc.Description as 'DESCRIPTION (FC)', dt.Code + ' | ' + cast(fcdt.DocumentTypeCodeID as varchar) as 'REFERENCE (DT)', dt.Description as 'DESCRIPTION (DT)', Case When fcdt.IsDefault = 1 Then 'YES' Else 'NO' End as 'IS DEFAULT'
		from Config.xFilingCode_DocumentTypeCode fcdt
		left join Config.OrgChart oc on oc.NodeID = fcdt.NodeID
		left join Config.vwFilingCode fc on fc.CodeID = fcdt.FilingCodeID and fc.NodeID = fcdt.NodeID
		left join Config.vwDocumentTypeCode dt on dt.CodeID = fcdt.DocumentTypeCodeID and dt.NodeID = fcdt.NodeID
		where fcdt.FilingCodeID in
			(
			Select fc.FCID
			from @FCIDTABLE fc
			)
		and fcdt.NodeID in
			(
			Select NODEID
			from @ROOTNODETABLE
			)
		order by fcdt.NodeID, fc.Description, dt.Description
	End
---------------------------------------------------------
If exists
	(
	Select Top 1 CONID
	from @CONDITIONIDTABLE
	)
	Begin
		Select Distinct 'CONDITIONS (CON)' as 'LINKED RELATIONSHIP', confc.ConditionID as 'CONDITIONID', con.Description as 'CONDITION DESCRIPTION', confc.FilingCodeID as 'CODEID (FC)'
		from Config.xCondition_FilingCode confc
		left join Config.Condition con on con.ConditionID = confc.ConditionID
		where confc.FilingCodeID in
			(
			Select fc.FCID
			from @FCIDTABLE fc
			)
		and confc.ConditionID in
			(
			Select CONID
			from @CONDITIONIDTABLE
			)
		order by con.Description, confc.FilingCodeID
	End

--============================================================================================================================================================================
--	SAVE CHANGES
--============================================================================================================================================================================
If (@SaveChanges = 'YES')
	Begin
		Commit
	End
Else
	Begin
		Rollback
	End