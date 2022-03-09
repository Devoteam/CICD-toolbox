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
toolbox_admin group can login                           netcicd             ${VALID_PASSWORD}       NetCICD_reports                                                                     Nexus-user    
git_from_jenkins group can login                        jenkins-git         ${VALID_PASSWORD}       --                                                                                  --
cicd_agents group can login                             jenkins-jenkins     ${VALID_PASSWORD}       Nexus-user                                                                          Nexus-admin
# IAM: no users
# Office: no users
# CAMPUS
# CAMPUS_OPS
campus_ops_oper group can login                         campusoper          ${VALID_PASSWORD}       docker,docker-proxy,NetCICD_reports                                                 --
campus_ops_spec group can login                         campusspec          ${VALID_PASSWORD}       docker,docker-proxy,NetCICD_reports                                                 --
# CAMPUS_DEV
campus_dev_lan group can login                          campuslandev        ${VALID_PASSWORD}       docker,docker-proxy,NetCICD_reports                                                 --
campus_dev_wifi group can login                         campuswifidev       ${VALID_PASSWORD}       docker,docker-proxy,NetCICD_reports                                                 --
# WAN
wan_ops_oper group can login                            wanoper             ${VALID_PASSWORD}       docker,docker-proxy,NetCICD_reports                                                 --
wan_ops_spec group can login                            wanspec             ${VALID_PASSWORD}       docker,docker-proxy,NetCICD_reports                                                 --
# WAN_DEV
wan_dev_design group can login                          corearchitect       ${VALID_PASSWORD}       docker,docker-proxy,NetCICD_reports                                                 --
# DC
# DC_OPS
# DC_OPS_COMP
dc_ops_compute_oper group can login                     compudude           ${VALID_PASSWORD}       docker,docker-proxy                                                                 --
dc_ops_compute_spec group can login                     compuspecialist     ${VALID_PASSWORD}       docker,docker-proxy                                                                 --
# DC_OPS_NET
dc_ops_network_oper group can login                     netdude             ${VALID_PASSWORD}       docker,docker-proxy,NetCICD_reports                                                 --
dc_ops_network_spec group can login                     netspecialist       ${VALID_PASSWORD}       docker,docker-proxy,NetCICD_reports                                                 --
# DC_OPS_STOR
dc_ops_storage_oper group can login                     diskdude            ${VALID_PASSWORD}       docker,docker-proxy                                                                 --
dc_ops_storage_spec group can login                     diskspecialist      ${VALID_PASSWORD}       docker,docker-proxy                                                                 --
# DC_DEV
dc_dev_compute group can login                          compuarchitect      ${VALID_PASSWORD}       docker,docker-proxy                                                                 --
dc_dev_network group can login                          netarchitect        ${VALID_PASSWORD}       docker,docker-proxy,NetCICD_reports                                                 --
dc_dev_storage group can login                          diskarchitect       ${VALID_PASSWORD}       docker,docker-proxy                                                                 --
# App
# APP_OPS
# APP_DEV
# TOOL
# TOOL_OPS
tooling_ops_oper group can login                        tooltiger           ${VALID_PASSWORD}       docker,docker-proxy                                                                 --
tooling_ops_spec group can login                        toolmaster          ${VALID_PASSWORD}       docker,docker-proxy                                                                 --
# TOOL_DEV
tooling_dev_design group can login                      blacksmith          ${VALID_PASSWORD}       docker,docker-proxy                                                                 --
# SEC
# SEC_OPS
security_ops_oper group can login                       happyhacker         ${VALID_PASSWORD}       docker,docker-proxy,NetCICD_reports                                                 --
security_ops_spec group can login                       whitehat            ${VALID_PASSWORD}       docker,docker-proxy,NetCICD_reports                                                 --
# SEC_DEV
security_dev_design group can login                     blackhat            ${VALID_PASSWORD}       docker,docker-proxy,NetCICD_reports                                                 --
# FS 
field_services_eng group can login                      mechanicjoe         ${VALID_PASSWORD}       docker,docker-proxy                                                                 --
field_services_floor_management group can login         patchhero           ${VALID_PASSWORD}       docker,docker-proxy                                                                 --

*** Variables ***
${Nexus URL}      https://nexus.tooling.test:8443
${Nexus browse}   https://nexus.tooling.test:8443/#browse/browse

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
    Wait Until Element Is Not Visible   loading-mask 
    Click Link                          Sign in
    Input Text                          username                ${USERNAME}
    Input Text                          password                ${PASSWORD}
    Click Element                       ext-element-1
    Click Element                       xpath=//*[@class='x-btn-inner x-btn-inner-nx-primary-small' and contains(text(),'Sign in')]

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

