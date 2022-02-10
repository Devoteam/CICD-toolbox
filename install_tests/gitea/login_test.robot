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

*** Test Cases ***                                      USERNAME            PASSWORD                ROLES                                                                               NOT_ROLES
baduser cannot login                                    baduser             wrongpassword           --                                                                                  --
toolbox_admin group can login                           netcicd             ${VALID_PASSWORD}       administrator                                                                       --  
git_from_jenkins group can login                        jenkins-git         ${VALID_PASSWORD}       --                                                                                  --
cicd_agents group can login                             jenkins-jenkins     ${VALID_PASSWORD}       --                                                                                  --
# IAM: no users
# Office: no users
# CAMPUS
# CAMPUS_OPS
campus_ops_oper group can login                         campusoper          ${VALID_PASSWORD}       gitea-netcicd-read                                                                   --
campus_ops_spec group can login                         campusspec          ${VALID_PASSWORD}       gitea-netcicd-write                                                                  --
# CAMPUS_DEV
campus_dev_lan group can login                          campuslandev        ${VALID_PASSWORD}       gitea-netcicd-write                                                                  --
campus_dev_wifi group can login                         campuswifidev       ${VALID_PASSWORD}       gitea-netcicd-write                                                                  --
# WAN
wan_ops_oper group can login                            wanoper             ${VALID_PASSWORD}       gitea-netcicd-read                                                                   --
wan_ops_spec group can login                            wanspec             ${VALID_PASSWORD}       gitea-netcicd-write                                                                  --
# WAN_DEV
wan_dev_design group can login                          corearchitect       ${VALID_PASSWORD}       gitea-netcicd-write                                                                  --
# DC
# DC_OPS
# DC_OPS_COMP
dc_ops_compute_oper group can login                     compudude           ${VALID_PASSWORD}       gitea-netcicd-read                                                                   --
dc_ops_compute_spec group can login                     compuspecialist     ${VALID_PASSWORD}       gitea-netcicd-read                                                                   --
# DC_OPS_NET
dc_ops_network_oper group can login                     netdude             ${VALID_PASSWORD}       gitea-netcicd-read                                                                   --
dc_ops_network_spec group can login                     netspecialist       ${VALID_PASSWORD}       gitea-netcicd-read                                                                   --
# DC_OPS_STOR
dc_ops_storage_oper group can login                     diskdude            ${VALID_PASSWORD}       gitea-netcicd-read                                                                   --
dc_ops_storage_spec group can login                     diskspecialist      ${VALID_PASSWORD}       gitea-netcicd-read                                                                   --
# DC_DEV
dc_dev_compute group can login                          compuarchitect      ${VALID_PASSWORD}       gitea-netcicd-read                                                                   --
dc_dev_network group can login                          netarchitect        ${VALID_PASSWORD}       gitea-netcicd-read                                                                   --
dc_dev_storage group can login                          diskarchitect       ${VALID_PASSWORD}       gitea-netcicd-read                                                                   --
# App
# APP_OPS
# APP_DEV
# TOOL
# TOOL_OPS
tooling_ops_oper group can login                        tooltiger           ${VALID_PASSWORD}       gitea-netcicd-read                                                                   --
tooling_ops_spec group can login                        toolmaster          ${VALID_PASSWORD}       gitea-netcicd-read                                                                   --
# TOOL_DEV
tooling_dev_design group can login                      blacksmith          ${VALID_PASSWORD}       gitea-netcicd-read                                                                   --
# SEC
# SEC_OPS
security_ops_oper group can login                       happyhacker         ${VALID_PASSWORD}       gitea-netcicd-read                                                                   --
security_ops_spec group can login                       whitehat            ${VALID_PASSWORD}       gitea-netcicd-read                                                                   --
# SEC_DEV
security_dev_design group can login                     blackhat            ${VALID_PASSWORD}       gitea-netcicd-read                                                                   --
# FS 
field_services_eng group can login                      mechanicjoe         ${VALID_PASSWORD}       gitea-netcicd-read                                                                   --
field_services_floor_management group can login         patchhero           ${VALID_PASSWORD}       gitea-netcicd-read                                                                   --

*** Variables ***
${GITEA URL}      https://gitea.tooling.test:3000/
${GITEA LOGIN}    https://gitea.tooling.test:3000/user/login?redirect_to=%2f

*** Keywords ***
Login with correct role provides correct authorization
    [Arguments]  ${USERNAME}  ${PASSWORD}  ${OK_ROLES}  ${FAIL_ROLES}
    Set Selenium Speed          ${DELAY}
    Are assigned roles present  ${USERNAME}             ${PASSWORD}                 ${OK_ROLES}               ${FAIL_ROLES}

Are assigned roles present
    [Arguments]  ${USERNAME}  ${PASSWORD}  ${OK_ROLES}  ${FAIL_ROLES}
    Open Browser                ${GITEA URL}            ${BROWSER1}
    Log in as user              ${USERNAME}             ${PASSWORD}
    Test given roles            ${USERNAME}             ${PASSWORD}             ${OK_ROLES}                 ${FAIL_ROLES}
    Close Browser

Log in as user
    [Arguments]  ${USERNAME}  ${PASSWORD}
    Go To                       https://gitea.tooling.test:3000/user/oauth2/keycloak
    Keycloak Page Should Be Open
    Input Text                  username                ${USERNAME}
    Input Text                  password                ${PASSWORD}
    Submit Credentials

Create user in Gitea
    [Arguments]  ${USERNAME}  ${PASSWORD}
    ${user_not_created}=        Run Keyword And Return Status    Page Should Contain        Complete Account
    IF  ${user_not_created}
        Click Button                Complete Account
        Go To                       https://gitea.tooling.test:3000/user/oauth2/keycloak
        Gitea Page Should Be Open   ${USERNAME}
        Log To Console              User created
    ELSE
        Log To Console              User existed already
    END

Gitea Page Should Be Open
    [Arguments]  ${USERNAME}
    Location Should Contain     ${GITEA URL}
    Title Should Be             ${USERNAME} - Dashboard - Our single source of truth

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
#                Fail
            END
        END

        @{NO_ROLES}=    Split String    ${FAIL_ROLES}   ,
        FOR  ${ROLE}  IN   @{NO_ROLES}
            ${role_does_not_exist}=              Run Keyword And Return Status    Page Should Not Contain       "${ROLE}"
            IF  ${role_does_not_exist}
                Log to Console      ${USERNAME} is not member of the team ${ROLE} as intended
            ELSE
                Log to Console      ${USERNAME} is member of the team ${ROLE}, which is wrong
#                Fail
            END
        END
    END

