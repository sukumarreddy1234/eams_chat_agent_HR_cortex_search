/*=============================================================================
This is a crucial step and needs to be done carefully

Setting up Teams Authentication with Snowflake and providing access to Agent
=============================================================================*/

/*=============================================================================
Step 1: Create Microsoft Teams Business Standard Trial Account
=============================================================================*/

--https://www.microsoft.com/en-in/microsoft-365/business/microsoft-365-business-standard-one-month-trial

/* Signup for a Work/School Trial Account to get access to Snowflake Agents

Since this if for an organization, it will ask for organization name, details etc..
Here are some basic things you need to make sure to enter:

- Create a new account and not use your existing email id.
- NAME- <YOUR_NAME>
- Organization Name- snowflakeagentdemo --can pick anything you want
- No. of users/person -1
- Address: Put your exact address
- Card Details: Use Monthly Billing and enter your card details --you get 1 month free trial, can cancel anytime before that
- If asked for tax registration or PAN- use your Pan card number
--If prompted that you address is invalid- choose use this address anyways.
- Finish the setup and sign in to your account.
 */

/*=============================================================================
Step 2: Setup Security Integration and Give Permission To the APP
=============================================================================*/
/*
###PRE-REQUISITES
1. Make note of your email id which got created for your microsoft work account.
eg: deepti@snowflakeagentdemo.onmicrosoft.com

2. Go to https://entra.microsoft.com/, login with your work account you created, and note the Tenant id,
 which can be found on the home page itself.
eg:  TENANT_ID = 32556f75-fb5a-4c90-4545-57e2e6b60de1  (Note what's yours)
 */

--CREATE SECURITY INTEGRATION
USE ROLE ACCOUNTADMIN;

--*** Replace <TENANT-ID> with your account tenant_id and execute ***
CREATE OR REPLACE SECURITY INTEGRATION entra_id_cortex_agents_integration 
TYPE = EXTERNAL_OAUTH 
ENABLED = TRUE 
EXTERNAL_OAUTH_TYPE = AZURE 
EXTERNAL_OAUTH_ISSUER = 'https://login.microsoftonline.com/<TENANT-ID>/v2.0'
EXTERNAL_OAUTH_JWS_KEYS_URL = 'https://login.microsoftonline.com/<TENANT-ID>/discovery/v2.0/keys'
EXTERNAL_OAUTH_AUDIENCE_LIST = ('5a840489-78db-4a42-8772-47be9d833efe') EXTERNAL_OAUTH_TOKEN_USER_MAPPING_CLAIM = ('email', 'upn')
EXTERNAL_OAUTH_SNOWFLAKE_USER_MAPPING_ATTRIBUTE = 'email_address' 
EXTERNAL_OAUTH_ANY_ROLE_MODE = 'ENABLE'
EXTERNAL_OAUTH_ALLOWED_ROLES_LIST = ('SECURITYADMIN');

/*=============================================================================
Step 3: Tenant-wide Entra ID configuration

To enable secure authentication for Cortex Agents, 
a Microsoft Azure administrator must grant consent for two applications hosted in Snowflake’s tenant,
creating a service principal for each application within your Entra ID tenant. 
The two applications are:

1. Cortex Agents Bot OAuth Resource:
Represents the protected Snowflake API and defines the access permissions (scopes) for client applications.
2. Cortex Agents Bot Snowflake OAuth Client:
 Represents the client application, in this case the Teams application back end service, that calls the Snowflake API after requesting an access token.
=============================================================================*/

--### A Global Administrator for your Microsoft Entra ID tenant must use the two links below to grant the necessary permissions for the applications.

--**** 1. GRANTING CONSENT FOR OAUTH RESOURCE PRINCIPAL
/* 
In your browser, navigate to https://login.microsoftonline.com/<tenant-id>/adminconsent?client_id=5a840489-78db-4a42-8772-47be9d833efe, 
where tenant-id is your organization’s Microsoft tenant ID.
*/

--**** 2. GRANTING CONSENT FOR OAUTH CLIENT PRINCIPAL 
/*
In your browser, navigate to https://login.microsoftonline.com/<tenant-id>/adminconsent?client_id=bfdfa2a2-bce5-4aee-ad3d-41ef70eb5086,
 where tenant-id is your organization’s Microsoft tenant ID.
 */

/*=============================================================================
Step 4: CREATE ROLE AND PROVIDE ACCESS
=============================================================================*/

USE ROLE ACCOUNTADMIN;

CREATE OR REPLACE ROLE TEAMS_CORTEX_AGENT_USER_ROLE;

GRANT USAGE ON AGENT HR_POLICIES_DB.DEV.HR_POLICY_AGENT
  TO ROLE TEAMS_CORTEX_AGENT_USER_ROLE;
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_AGENT_USER
  TO ROLE TEAMS_CORTEX_AGENT_USER_ROLE;
GRANT USAGE ON DATABASE HR_POLICIES_DB TO ROLE TEAMS_CORTEX_AGENT_USER_ROLE;
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_AGENT_USER TO ROLE TEAMS_CORTEX_AGENT_USER_ROLE;
GRANT USAGE ON ALL SCHEMAS IN DATABASE HR_POLICIES_DB TO ROLE TEAMS_CORTEX_AGENT_USER_ROLE;
GRANT USAGE ON CORTEX SEARCH SERVICE HR_POLICIES_DB.DEV.POLICY_SEARCH TO ROLE TEAMS_CORTEX_AGENT_USER_ROLE;
GRANT USAGE ON WAREHOUSE CORTEX_DEMO_WH TO ROLE TEAMS_CORTEX_AGENT_USER_ROLE;

/*=============================================================================
Step 5: CREATE USER AND PROVIDE ACCESS
=============================================================================*/
CREATE OR REPLACE USER TEAMS_DEEPTI
  LOGIN_NAME = 'deepti@snowflakeagentdemo.onmicrosoft.com' --this should be exactly same as your microsoft account user
  EMAIL = 'deepti@snowflakeagentdemo.onmicrosoft.com' --this should be exactly same as your microsoft account email
  DEFAULT_ROLE = TEAMS_CORTEX_AGENT_USER_ROLE
  DEFAULT_WAREHOUSE = CORTEX_DEMO_WH
  MUST_CHANGE_PASSWORD = FALSE;

GRANT ROLE TEAMS_CORTEX_AGENT_USER_ROLE
  TO USER TEAMS_DEEPTI;

/*=============================================================================
Step 6: GIVE SECURITYADMIN ROLE TO THE USER TO SETUP THE AGENT AS AN ADMIN IN TEAMS
=============================================================================*/
GRANT ROLE SECURITYADMIN TO USER TEAMS_DEEPTI;

ALTER USER TEAMS_DEEPTI
  SET DEFAULT_ROLE = SECURITYADMIN;

/*=============================================================================
Step 6: REMOVED ANY BLOCKED LIST EXTERNAL OAUTH PRIVILEGED ROLE FOR THE ACCOUNT
=============================================================================*/

USE ROLE ACCOUNTADMIN;
ALTER ACCOUNT
SET EXTERNAL_OAUTH_ADD_PRIVILEGED_ROLES_TO_BLOCKED_LIST = FALSE;


/*=============================================================================
All these steps need to be executed sequentially and we have configured the tenant id setup for our microsoft account.
Next step would be to download Teams App and start talking to your agent.

If you get stuck any where in the above steps: 
Please refer to https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-agents-teams-integration
Go to next setup sheet to configure agent in teams app.
=============================================================================*/