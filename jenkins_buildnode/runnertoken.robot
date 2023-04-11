*** Settings ***
Library           SeleniumLibrary
Library           OperatingSystem
Documentation     Creating gitea runner

*** Test cases ***
Create Gitea Runner tokens
    Login to Gitea as netcicd
    Create runner token    ${environment}
    
Close browsers
    Close Browser

*** Variables ***

${BROWSER1}         headlessfirefox
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
    Open Browser                ${GITEA URL}       ${BROWSER1}
    Set Selenium Speed          ${DELAY}
    Set Window Size             2560                 1920 
    Go To                       https://gitea.tooling.provider.test:3000/user/oauth2/keycloak
    Keycloak Page Should Be Open
    Input Text                  username              netcicd
    Input Text                  password              ${VALID_PASSWORD}
    Submit Credentials

Create runner token
    [Arguments]                 ${env}
    Go To                       https://gitea.tooling.provider.test:3000/admin/runners
    Click Button                Create new Runner
    ${token}                    SeleniumLibrary.Get Element Attribute    xpath:/html/body/div/div[2]/div[2]/div/h4/div/div/div/div[4]/div    data-clipboard-text
    Log to Console              ${env} token created
    Create File                 ${EXECDIR}/jenkins_buildnode/${env}_runner_token   ${token}
