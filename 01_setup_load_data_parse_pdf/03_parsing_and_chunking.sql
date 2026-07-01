/*=============================================================================
 HR POLICIES CHAT AGENT — SETUP SCRIPT
  Extracts raw text from PDFs and then split it up into chunks
=============================================================================*/

USE DATABASE HR_POLICIES_DB;
USE SCHEMA HR_POLICIES_DB.DEV;
USE WAREHOUSE CORTEX_DEMO_WH;

--Using AI_PARSE_DOCUMENT CORTEX Function to parse the pdfs and load in a table in raw format
CREATE OR REPLACE TABLE HR_POLICIES_DB.DEV.RAW_TEXT
AS
SELECT RELATIVE_PATH,
TO_VARCHAR(
    AI_PARSE_DOCUMENT(
        TO_FILE('@HR_POLICIES_DB.DEV.POLICIES_STAGE', RELATIVE_PATH),
        {'mode':'LAYOUT'} ): content 
    )AS EXTRACTED_LAYOUT
FROM
    DIRECTORY ('@HR_POLICIES_DB.DEV.POLICIES_STAGE')
WHERE
    RELATIVE_PATH LIKE '%.pdf';

-- SELECT  * FROM HR_POLICIES_DB.DEV.RAW_TEXT;

--Splitting the document into chunks of maximum size of 2000 character each,
--using the top two markdown header levels as chunk boundaries.

CREATE OR REPLACE TABLE HR_POLICIES_DB.DEV.DOC_CHUNKS
AS
SELECT
RELATIVE_PATH,
BUILD_SCOPED_FILE_URL('@HR_POLICIES_DB.DEV.POLICIES_STAGE', RELATIVE_PATH) AS FILE_URL,
(
    RELATIVE_PATH || ':\n'
    || COALESCE('Header 1: ' ||  c.value['headers']['header_1'] || '\n', '')
    || COALESCE('Header 2: ' ||  c.value['headers']['header_2'] || '\n', '')
    || c.value['chunk']
) as chunk,
    'English' as language
FROM HR_POLICIES_DB.DEV.RAW_TEXT,
LATERAL FLATTEN( SNOWFLAKE.CORTEX.SPLIT_TEXT_MARKDOWN_HEADER(
    EXTRACTED_LAYOUT,
    OBJECT_CONSTRUCT('#','header_1', '##', 'header_2'),
    2000, --chunk size
    300
))c;


-- SELECT  * FROM HR_POLICIES_DB.DEV.DOC_CHUNKS;