/*=============================================================================
Access Agent in your Teams App
=============================================================================*/


/*
Step 1: Download Teams App, and login with the work/school business trial account you created for this project.
Step 2: In your Teams, Go to Apps and search 'Snowflake Cortex Agents' -> Add App
Step 3: The first user from your organization to interact with the agent will be guided through a 
one-time setup process to connect your Snowflake account for the whole organization.
This user must have administrative permissions in the target Snowflake account to complete the setup.
    a. Upon the first interaction with the agent, you will be prompted to log in with 
    your Microsoft account.
    b. The agent will inform you that no Snowflake account is configured for your organization 
    and will ask for your Snowflake account URL.
    c. Clicking “I’m the Snowflake administrator” action will unveil a simple form, where you can provide your account’s URL.
     -The full URL to enter is your_organization-your_account.snowflakecomputing.com.
    d. If all checks pass, the Snowflake configuration has been successfully added for your organization. 
     All users from your Microsoft tenant can now interact with the agent using this Snowflake account.

Step 4: It will prompt you to Select an agent from any of your configured accounts: *
Step 5: Choose the HR_POLICY_AGENT we created and start asking questions.

 */
--Here is a snapshot of a question I asked 
[docs\teams_conversation.png]

/*=============================================================================
Now you can just start asking questions/prompts to your agent
=============================================================================*/