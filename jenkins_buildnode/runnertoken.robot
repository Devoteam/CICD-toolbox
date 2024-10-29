*** Settings ***
Library           SeleniumLibrary
Library           OperatingSystem
Documentation     Creating gitea runner   

Suite Setup       Open Browser   ${GITEA URL}      ${BROWSER1}       remote_url=http://seleniumgchost.internal.provider.test:4444    options=add_argument("--ignore-certificate-errors")
Suite Teardown    Close Browser

*** Tasks ***
Create Gitea Runner tokens
    Login to Gitea as netcicd
    Create runner token    ${environment}

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

Create runner token
    [Arguments]                 ${env}
    Go To                       https://gitea.tooling.provider.test:3000/admin/actions/runners
    Wait Until Page Contains    Create new Runner
    Click Button                Create new Runner                        
    Wait Until Element Is Visible                                        xpath:/html/body/div[2]/div/div/div[2]/div/div/h4/div/div/div/div[4]/input
    ${token}                    SeleniumLibrary.Get Element Attribute    xpath:/html/body/div[2]/div/div/div[2]/div/div/h4/div/div/div/div[4]/input    value
    Log to Console              ${env} token created
    Create File                 ${EXECDIR}/jenkins_buildnode/${env}_runner_token   ${token}
