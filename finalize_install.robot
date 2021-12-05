*** Settings ***
Library           SeleniumLibrary
Documentation     Creating jenkins-jenkins token
...               Enabling gitea login from Jenkins

*** Tasks ***
Create Jenkins token
    Log into Jenkins as jenkins-jenkins
    Create jenkins-jenkins token
    Click Jenkins Logout Link

Enter Jenkins token in credentials
    Log into Jenkins as netcicd
    Change jenkins-jenkins credentials 
    Click Jenkins Logout Link

Enable Jenkins to log into git
    Login to Gitea as jenkins-git

Close browsers
    Close Browser

*** Variables ***

${BROWSER1}         Firefox
${DELAY}            0
${JENKINS URL}      http://jenkins.tooling.test:8084/
${JENKINS LOGOUT}   http://jenkins.tooling.test:8084/logout 
${GITEA URL}        http://gitea.tooling.test:3000
${GITEA LOGIN}      http://gitea.tooling.test:3000/user/login?redirect_to=%2f

*** Keywords ***
Log into Jenkins as jenkins-jenkins
    Open Browser                ${JENKINS URL}       ${BROWSER1}
    Maximize Browser Window
    Go To                       ${JENKINS URL}
    Set Selenium Speed          ${DELAY}
    Keycloak Page Should Be Open
    Input Text                  username              jenkins-jenkins
    Input Text                  password              ${VALID_PASSWORD}
    Submit Credentials
    Jenkins Page Should Be Open

Create jenkins-jenkins token
    Go To                       http://jenkins.tooling.test:8084/user/jenkins-jenkins/configure
    Click Button                Add new Token
    Click Button                Generate
    ${TOKEN}                    Get Text             class:new-token-value.visible
    Set Suite Variable          ${TOKEN}
    Click Button                Save

Log into Jenkins as netcicd
    Keycloak Page Should Be Open
    Input Text                  username              netcicd
    Input Text                  password              ${VALID_PASSWORD}
    Submit Credentials
    Jenkins Page Should Be Open

Change jenkins-jenkins credentials 
    Go To                       http://jenkins.tooling.test:8084/credentials/store/system/domain/_/credential/jenkins-jenkins/update
    Click Button                Change Password
    Input Text                  class:complex-password-field.hidden-password-field.setting-input               ${TOKEN}
    Click Button                Save

Login to Gitea as jenkins-git
    Go To                       ${GITEA LOGIN}
    Click Image                 class:openidConnect
    Keycloak Page Should Be Open
    Input Text                  username              jenkins-git
    Input Text                  password              ${VALID_PASSWORD}
    Submit Credentials
    Location Should Contain     ${GITEA URL}     
    Input Text                  password              ${VALID_PASSWORD}
    Click Button                Link Account
    Input Text                  password              ${VALID_PASSWORD}
    Input Text                  retype                ${VALID_PASSWORD}
    Click Button                Update Password

Keycloak Page Should Be Open
    Title Should Be    Sign in to Welcome to the Infrastructure Development Toolkit

Jenkins Page Should Be Open
    Location Should Contain     ${JENKINS URL}
    Title Should Be             Dashboard [Jenkins]

Gitea Page Should Be Open
    Location Should Contain     ${GITEA URL}
    Title Should Be             jenkins-git - Dashboard

Click Jenkins Logout Link
    Go To                       ${JENKINS LOGOUT}
    Keycloak Page Should Be Open

Submit Credentials
    Click Button                kc-login
