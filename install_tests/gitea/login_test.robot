*** Settings ***
Resource          ../install_test.resource

Documentation       Validating login for each LDAP group
...                 Each LDAP group has a predefined user
...                 When this user logs in, the associated rights must be assigned.
...                 There are three tests required:
...                 - Are assigned roles present
...                 - Are present roles assigned
...                 - Are explicitly disallowed roles not secretly present
...                 - Are any other roles not secretly present

Test Template    Login with correct role provides correct authorization

*** Test Cases ***                              USERNAME            PASSWORD                ROLES                                                                               NOT_ROLES
baduser is not a user                           baduser             wrongpassword           --                                                                                  --
netcicd is admin user                           netcicd             ${VALID_PASSWORD}       administrator                                                                       --  
jenkins-git can login to Gitea                  jenkins-git         ${VALID_PASSWORD}       --                                                                                  --
jenkins-jenkins cannot login to Gitea           jenkins-jenkins     ${VALID_PASSWORD}       --                                                                                  --
netcicd-pipeline can login to Gitea             netcicd-pipeline    ${VALID_PASSWORD}       --                                                                                  --
# IAM: no users
# Office: no users
# Campus: no users
# CAMPUS_OPS
# CAMPUS_OPS_OPER can login to Gitea                                  ${VALID_PASSWORD}       gitea-netcicd-read                                                                   --
# CAMPUS_OPS_SPEC can login to Gitea                                  ${VALID_PASSWORD}       gitea-netcicd-write                                                                  --
# CAMPUS_DEV_LAN_DESIGNER can login to Gitea                          ${VALID_PASSWORD}       gitea-netcicd-write                                                                  --
# CAMPUS_DEV_WIFI_DESIGNER can login to Gitea                         ${VALID_PASSWORD}       gitea-netcicd-write                                                                  --
# WAN: no users
# WAN_OPS_OPER can login to Gitea                                     ${VALID_PASSWORD}       gitea-netcicd-read                                                                   --
# WAN_OPS_SPEC can login to Gitea                                     ${VALID_PASSWORD}       gitea-netcicd-read                                                                   --
# WAN_DEV
# WAN_DEV_SPEC can login to Gitea                                     ${VALID_PASSWORD}       gitea-netcicd-write                                                                  --
# DC
# DC_OPS
# DC_OPS_COMP
# DC_OPS_COMP_OPER 
compudude can login to Gitea                    compudude           ${VALID_PASSWORD}       gitea-netcicd-read                                                                 --
# DC_OPS_COMP_SPEC  
compuspecialist can login to Gitea              compuspecialist     ${VALID_PASSWORD}       gitea-netcicd-read                                                                 --
# DC_OPS_COMP_SPEC
# DC_OPS_NET
# DC_OPS_NET_OPER 
netdude can login to Gitea                      netdude             ${VALID_PASSWORD}       gitea-netcicd-read                                                                 --
# DC_OPS_NET_SPEC
netspecialist can login to Gitea                netspecialist       ${VALID_PASSWORD}       gitea-netcicd-read                                                                 --
# DC_OPS_STOR
# DC_OPS_STOR_OPER 
diskdude can login to Gitea                     diskdude            ${VALID_PASSWORD}       gitea-netcicd-read                                                                 --
# DC_OPS_STOR_SPEC
diskspecialist can login to Gitea               diskspecialist      ${VALID_PASSWORD}       gitea-netcicd-read                                                                 --
# DC_DEV
compuarchitect can login to Gitea               compuarchitect      ${VALID_PASSWORD}       gitea-netcicd-read                                                                 --
diskarchitect can login to Gitea                diskarchitect       ${VALID_PASSWORD}       gitea-netcicd-read                                                                 --  
netarchitect can login to Gitea                 netarchitect        ${VALID_PASSWORD}       gitea-netcicd-read                                                                 --
# App
# APP_OPS
# APP_DEV
# TOOL
# TOOL_OPS
# TOOL_OPS_OPER
tooltiger can login to Gitea                    tooltiger           ${VALID_PASSWORD}       gitea-netcicd-read                                                                 --
# TOOL_OPS_SPEC
toolmaster can login to Gitea                   toolmaster          ${VALID_PASSWORD}       gitea-netcicd-read                                                                 --
# TOOL_DEV
blacksmith can login to Gitea                   blacksmith          ${VALID_PASSWORD}       gitea-netcicd-read                                                                 --
# SEC
# SEC_OPS
# SEC_OPS_OPER
happyhacker can login to Gitea                  happyhacker         ${VALID_PASSWORD}       gitea-netcicd-read                                                                 --
# SEC_OPS_SPEC
whitehat can login to Gitea                     whitehat            ${VALID_PASSWORD}       gitea-netcicd-read                                                                 --
# SEC_DEV
blackhat can login to Gitea                     blackhat            ${VALID_PASSWORD}       gitea-netcicd-read                                                                 --
# FS 
# FS_ENG
mechanicjoe can login to Gitea                  mechanicjoe         ${VALID_PASSWORD}       gitea-netcicd-read                                                                 --
# FS
# FS_FM
patchhero can login to Gitea                    patchhero           ${VALID_PASSWORD}       gitea-netcicd-read                                                                 --

*** Variables ***
${GITEA URL}      http://gitea.tooling.test:3000/
${GITEA LOGIN}    http://gitea.tooling.test:3000/user/login?redirect_to=%2f

*** Keywords ***
Login with correct role provides correct authorization
    [Arguments]  ${USERNAME}  ${PASSWORD}  ${OK_ROLES}  ${FAIL_ROLES}
    Set Selenium Speed          ${DELAY}
    Are assigned roles present  ${USERNAME}             ${PASSWORD}                 ${OK_ROLES}               ${FAIL_ROLES}

Are assigned roles present
    [Arguments]  ${USERNAME}  ${PASSWORD}  ${OK_ROLES}  ${FAIL_ROLES}
    Open Browser                ${GITEA URL}          ${BROWSER1}
    Log into Gitea as user      ${USERNAME}             ${PASSWORD}
    Test given roles            ${USERNAME}             ${PASSWORD}             ${OK_ROLES}                 ${FAIL_ROLES}
    Close Browsers

Log into Gitea as user
    [Arguments]  ${USERNAME}  ${PASSWORD}
    Go To                       ${GITEA LOGIN}
    Click Image                 class:openidConnect
    Keycloak Page Should Be Open
    Input Text                  username                ${USERNAME}
    Input Text                  password                ${PASSWORD}
    Submit Credentials

Create user in Gitea
    [Arguments]  ${USERNAME}  ${PASSWORD}
    ${user_not_created}=        Run Keyword And Return Status    Page Should Contain        Complete Account
    IF  ${user_not_created}
        Click Button                Complete Account
        Click Image                 class:openidConnect
        Gitea Page Should Be Open   ${USERNAME}
        Log To Console              User created
    ELSE
        Log To Console              User existed already
    END

Gitea Page Should Be Open
    [Arguments]  ${USERNAME}
    Location Should Contain     ${GITEA URL}
    Title Should Be             ${USERNAME} - Dashboard - Gitea: Git with a cup of tea

Test given roles
    [Arguments]     ${USERNAME}        ${PASSWORD}     ${OK_ROLES}     ${FAIL_ROLES}
    ${user_unknown}=        Run Keyword And Return Status    Page Should Contain        Invalid username or password.

    IF  ${user_unknown} 
        # User does not exist in Keycloak or password incorrect
        Log to Console      ${USERNAME} cannot log in

    ELSE
        # User exists in Keycloak and password is correct
        Log to Console              ${USERNAME} can login      
        Create user in Gitea        ${USERNAME}             ${PASSWORD}

        @{MY_ROLES}=    Split String    ${OK_ROLES}     ,
        FOR  ${ROLE}  IN   @{MY_ROLES}
            ${role_exists}=              Run Keyword And Return Status    Page Should Contain           "${ROLE}"
            IF  ${role_exists}
                Log to Console      ${USERNAME} is member of the team ${ROLE}
            ELSE
                Log to Console      ${USERNAME} is not member of the team ${ROLE}
                Fail
            END
        END

        @{NO_ROLES}=    Split String    ${FAIL_ROLES}   ,
        FOR  ${ROLE}  IN   @{NO_ROLES}
            ${role_does_not_exist}=              Run Keyword And Return Status    Page Should Not Contain       "${ROLE}"
            IF  ${role_does_not_exist}
                Log to Console      ${USERNAME} is not member of the team ${ROLE} as intended
            ELSE
                Log to Console      ${USERNAME} is member of the team ${ROLE}, which is wrong
                Fail
            END
        END
    END

