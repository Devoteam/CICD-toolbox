*** Settings ***
Library           SeleniumLibrary
Documentation     Creating jenkins-jenkins token
...               Enabling gitea login from Jenkins

*** Test cases ***
Create Jenkins token
    Log into Jenkins as jenkins-jenkins
    Create jenkins-jenkins token
    Click Jenkins Logout Link

Enter Jenkins token in credentials
    Log into Jenkins as netcicd
    Change jenkins-jenkins credentials 
    Click Jenkins Logout Link

Enable Jenkins to log into git
    Login to Gitea as service-account-jenkins
    Create service-account-jenkins token in Gitea
    Enter service-account-jenkins token in Jenkins credentials

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
    Log to Console              Successfully logged in to Jenkins as jenkins-jenkins

Create jenkins-jenkins token
    Go To                       http://jenkins.tooling.test:8084/user/jenkins-jenkins/configure
    Click Button                Add new Token
    Click Button                Generate
    ${TOKEN}                    Get Text             class:new-token-value.visible
    Set Suite Variable          ${TOKEN}
    Click Button                Save
    Log to Console              Token created

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
    Log to Console              jenkins-jenkins credentials changed in Jenkins

Login to Gitea as service-account-jenkins
    Go To                       http://gitea.tooling.test:3000/user/login?redirect_to=%2f
    Input Text                  user_name             service-account-jenkins
    Input Text                  password              ${VALID_PASSWORD}
    Click Button                Sign In
    Input Text                  password              ${VALID_PASSWORD}
    Input Text                  retype                ${VALID_PASSWORD}
    Click Button                Update Password
    Log to Console              service-account-jenkins changed password to token

Create service-account-jenkins token in Gitea
    Go To                       http://gitea.tooling.test:3000/user/settings/applications
    Input Text                  name                    Jenkins
    Click Button                Generate Token
    ${SA_TOKEN_text}            Get Text                xpath:/html/body/div/div[2]/div[2]/div[2]/p
    Set Global Variable         ${SA_TOKEN_text}
    Log to Console              service-account-jenkins token created in Gitea

    Go To                       http://gitea.tooling.test:3000/user/settings/account
    Input Text                  old_password            netcicd
    Input Text                  password                ${SA_TOKEN_text}
    Input Text                  retype                  ${SA_TOKEN_text}
    Click Button                Update Password
    Log to Console              service-account-jenkins password set to token

Enter service-account-jenkins token in Jenkins credentials
    Go To                       ${JENKINS URL}
    Log into Jenkins as netcicd
    Go To                       http://jenkins.tooling.test:8084/credentials/store/system/domain/_/credential/jenkins-git/update
    Click Button                Change Password
    Input Text                  class:complex-password-field.hidden-password-field.setting-input               ${SA_TOKEN_text}
    Click Button                Save
    Log to Console              jenkins-git changed credentials to login to Gitea

Keycloak Page Should Be Open
    Title Should Be    Sign in to Welcome to your Development Toolkit

Jenkins Page Should Be Open
    Location Should Contain     ${JENKINS URL}
    Title Should Be             Dashboard [Jenkins]

Click Jenkins Logout Link
    Go To                       ${JENKINS LOGOUT}
    Keycloak Page Should Be Open

Submit Credentials
    Click Button                kc-login
