*** Settings ***
Library           SeleniumLibrary
Library           OperatingSystem
Documentation     Validate gitea runner

Suite Setup       Open Browser   ${GITEA URL}      ${BROWSER1}       remote_url=http://seleniumgchost.internal.provider.test:4444    options=add_argument("--ignore-certificate-errors")
Suite Teardown    Close Browser

*** Tasks ***
Validate runner operation
    Login to Gitea as netcicd
    Open Runner page and check status              ${ENVIRONMENT}    ${NAME}      ${SEQ_NR} 

*** Variables ***

${BROWSER1}         chrome
${DELAY}            0
${GITEA URL}        https://gitea.tooling.provider.test:3000
${GITEA LOGIN}      https://gitea.tooling.provider.test:3000/user/login?redirect_to=%2f

*** Keywords ***   

Keycloak Page Should Be Open
    Sleep                       1
    Title Should Be    Sign in to Welcome to your Development Toolkit

Submit Credentials
    Click Button                kc-login

Login to Gitea as netcicd
    Set Selenium Speed          ${DELAY}
    Set Window Size             2560                 1920 
    Go To                       https://gitea.tooling.provider.test:3000/user/oauth2/keycloak
    Keycloak Page Should Be Open
    Input Text                  username              netcicd
    Input Text                  password              ${VALID_PASSWORD}
    Submit Credentials

Open Runner page and check status    
    [Arguments]  ${ENVIRONMENT}    ${NAME}    ${SEQ_NR} 
    Go To                       ${GITEA URL}/admin/actions/runners/${SEQ_NR}
    Page Should Contain         ${NAME}
    Page Should Not Contain     Offline
    Page Should Contain         Idle

