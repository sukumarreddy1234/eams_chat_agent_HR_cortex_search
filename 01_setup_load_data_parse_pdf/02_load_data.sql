/*=============================================================================
 HR POLICIES CHAT AGENT — SETUP SCRIPT
  Creates snowflake internal stage and loads data
=============================================================================*/

--set context--
USE DATABASE HR_POLICIES_DB;
USE SCHEMA HR_POLICIES_DB.DEV;
USE WAREHOUSE CORTEX_DEMO_WH;

--creating stage to load HR policies pdf files--
CREATE OR REPLACE STAGE HR_POLICIES_DB.DEV.POLICIES_STAGE
DIRECTORY = (ENABLE=TRUE)  
ENCRYPTION = (TYPE ='SNOWFLAKE_SSE')
--The directory and encryption are configured for generating presigned_url for a file

/* 
After creating stage, go ahead and upload all pdfs to the stage you just created 
using snowsight data load feature
*/

snow stage copy /workspace/source_data/HR_policies_data_kaggle/ @HR_POLICIES_DB.DEV.POLICIES_STAGE; --overwrite 2>&1

LS @HR_POLICIES_DB.DEV.POLICIES_STAGE;