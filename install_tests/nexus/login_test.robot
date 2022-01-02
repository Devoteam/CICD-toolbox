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
netcicd is admin user                           netcicd             ${VALID_PASSWORD}       NetCICD-reports                                                                     Nexus-user  
Nexus-git cannot login to Nexus                 jenkins-git         ${VALID_PASSWORD}       --                                                                                  --
jenkins-jenkins can login to Nexus              jenkins-jenkins     ${VALID_PASSWORD}       Nexus-user                                                                          Nexus-admin
netcicd-pipeline cannot login to Nexus          netcicd-pipeline    ${VALID_PASSWORD}       --                                                                                  --
# IAM: no users
# Office: no users
# Campus: no users
# CAMPUS_OPS
# CAMPUS_OPS_OPER can login to Nexus                                  ${VALID_PASSWORD}       docker,docker-proxy                                                      NetCICD-reports
# CAMPUS_OPS_SPEC can login to Nexus                                  ${VALID_PASSWORD}       docker,docker-proxy                                                      --
# CAMPUS_DEV_LAN_DESIGNER can login to Nexus                          ${VALID_PASSWORD}       docker,docker-proxy                                                      --
# CAMPUS_DEV_WIFI_DESIGNER can login to Nexus                         ${VALID_PASSWORD}       docker,docker-proxy                                                      --
# WAN: no users
# WAN_OPS_OPER can login to Nexus                                     ${VALID_PASSWORD}       docker,docker-proxy                                                      --
# WAN_OPS_SPEC can login to Nexus                                     ${VALID_PASSWORD}       docker,docker-proxy                                                      --
# WAN_DEV
# WAN_DEV_SPEC can login to Nexus                                     ${VALID_PASSWORD}       docker,docker-proxy                                                      --
# DC
# DC_OPS
# DC_OPS_COMP
# DC_OPS_COMP_OPER 
compudude can login to Nexus                    compudude           ${VALID_PASSWORD}       docker,docker-proxy                                                      --
# DC_OPS_COMP_SPEC  
compuspecialist can login to Nexus              compuspecialist     ${VALID_PASSWORD}       docker,docker-proxy                                                      --
# DC_OPS_COMP_SPEC
# DC_OPS_NET
# DC_OPS_NET_OPER 
netdude can login to Nexus                      netdude             ${VALID_PASSWORD}       docker,docker-proxy                                                      --
# DC_OPS_NET_SPEC
netspecialist can login to Nexus                netspecialist       ${VALID_PASSWORD}       docker,docker-proxy                                                      --
# DC_OPS_STOR
# DC_OPS_STOR_OPER 
diskdude can login to Nexus                     diskdude            ${VALID_PASSWORD}       docker,docker-proxy                                                      --
# DC_OPS_STOR_SPEC
diskspecialist can login to Nexus               diskspecialist      ${VALID_PASSWORD}       docker,docker-proxy                                                      --
# DC_DEV
compuarchitect can login to Nexus               compuarchitect      ${VALID_PASSWORD}       docker,docker-proxy                                                      --
diskarchitect can login to Nexus                diskarchitect       ${VALID_PASSWORD}       docker,docker-proxy                                                      --     
netarchitect can login to Nexus                 netarchitect        ${VALID_PASSWORD}       docker,docker-proxy                                                      --
# App
# APP_OPS
# APP_DEV
# TOOL
# TOOL_OPS
# TOOL_OPS_OPER
tooltiger can login to Nexus                    tooltiger           ${VALID_PASSWORD}       docker,docker-proxy                                                      --
# TOOL_OPS_SPEC
toolmaster can login to Nexus                   toolmaster          ${VALID_PASSWORD}       docker,docker-proxy                                                      --
# TOOL_DEV
blacksmith can login to Nexus                   blacksmith          ${VALID_PASSWORD}       docker,docker-proxy                                                      --
# SEC
# SEC_OPS
# SEC_OPS_OPER
happyhacker can login to Nexus                  happyhacker         ${VALID_PASSWORD}       docker,docker-proxy                                                      --
# SEC_OPS_SPEC
whitehat can login to Nexus                     whitehat            ${VALID_PASSWORD}       docker,docker-proxy                                                      --
# SEC_DEV
blackhat can login to Nexus                     blackhat            ${VALID_PASSWORD}       docker,docker-proxy                                                      --
# FS
# FS_ENG
mechanicjoe can login to Nexus                  mechanicjoe         ${VALID_PASSWORD}       docker,docker-proxy                                                      --
# FS
# FS_FM
patchhero can login to Nexus                    patchhero           ${VALID_PASSWORD}       docker,docker-proxy                                                      --

*** Variables ***
${Nexus URL}      http://nexus.tooling.test:8081/
${Nexus browse}   http://nexus.tooling.test:8081/#browse/browse

*** Keywords ***
Login with correct role provides correct authorization
    [Arguments]  ${USERNAME}  ${PASSWORD}  ${OK_ROLES}  ${FAIL_ROLES}
    Set Selenium Speed          ${DELAY}
    Are assigned roles present  ${USERNAME}             ${PASSWORD}                 ${OK_ROLES}               ${FAIL_ROLES}

Are assigned roles present
    [Arguments]  ${USERNAME}  ${PASSWORD}  ${OK_ROLES}  ${FAIL_ROLES}
    Open Browser                ${Nexus URL}            ${BROWSER1}
    Log into Nexus as user      ${USERNAME}             ${PASSWORD}
    Test given roles            ${USERNAME}             ${OK_ROLES}                 ${FAIL_ROLES}
    Close Browser

Log into Nexus as user
    [Arguments]  ${USERNAME}  ${PASSWORD}
    Sleep                       2s
    Click Link                  Sign in
    Input Text                  username                ${USERNAME}
    Input Text                  password                ${PASSWORD}
    Sleep                       2s
    Click Element               xpath=//*[@class='x-btn-inner x-btn-inner-nx-primary-small' and contains(text(),'Sign in')]

Test given roles
    [Arguments]     ${USERNAME}     ${OK_ROLES}     ${FAIL_ROLES}
    ${user_unknown}=        Run Keyword And Return Status    Page Should Contain        Incorrect username or password, or no permission to use the application.

    IF  ${user_unknown} 
        # User does not exist in Keycloak or password incorrect
        Log to Console      ${USERNAME} cannot log in

    ELSE
        # User exists in Keycloak and password is correct
        Log to Console              ${USERNAME} can login      
        Go To                       ${Nexus browse}
        ${no_repo}=         Run Keyword And Return Status    Page Should Contain        Path "browse/browse" not found

        IF  ${no_repo}
            # None of the roles in the JWT is known in Nexus, but the user exists in Keycloak
            Log to Console              ${USERNAME} can log in but has no rights
        ELSE
            # The user exists in Keycloak AND has roles assigned in Nexus
            Log to Console              ${USERNAME} can log in and has rights
            @{MY_ROLES}=    Split String    ${OK_ROLES}     ,
            FOR  ${ROLE}  IN   @{MY_ROLES}
                ${role_exists}=              Run Keyword And Return Status    Page Should Contain           ${ROLE}
                IF  ${role_exists}
                    Log to Console      ${USERNAME} can see the repo ${ROLE}
                ELSE
                    Log to Console      ${USERNAME} cannot see the repo ${ROLE}
                    Fail
                END
            END

            @{NO_ROLES}=    Split String    ${FAIL_ROLES}   ,
            FOR  ${ROLE}  IN   @{NO_ROLES}
                ${role_does_not_exist}=              Run Keyword And Return Status    Page Should Not Contain       "${ROLE}"
                IF  ${role_does_not_exist}
                    Log to Console      ${USERNAME} can not see the repo ${ROLE} as intended
                ELSE
                    Log to Console      ${USERNAME} can see the repo ${ROLE}, which is wrong
                    Fail
                END
            END
        END
    END

