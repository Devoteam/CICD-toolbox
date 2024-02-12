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

Test Setup       Open Browser   ${JENKINS URL}      ${BROWSER1}       remote_url=http://seleniumgchost.internal.provider.test:4444    options=add_argument("--ignore-certificate-errors")
Test Teardown    Close Browser

Test Template    Login with correct role provides correct authorization

*** Test Cases ***                                      USERNAME            PASSWORD                ROLES                                                                               NOT_ROLES
baduser cannot login                                    baduser             wrongpassword           --                                                                                  --
toolbox_admin group can login                           netcicd             ${VALID_PASSWORD}       jenkins-admin                                                                       jenkins-user 
git_from_jenkins group can login                        jenkins-git         ${VALID_PASSWORD}       --                                                                                  --
cicd_agents group can login                             jenkins-jenkins     ${VALID_PASSWORD}       jenkins-user                                                                        jenkins-admin
# IAM: no users
# Office: no users
# CAMPUS
# CAMPUS_OPS
campus_ops_oper group can login                         campusoper          ${VALID_PASSWORD}       jenkins-user,jenkins-netcicd-run,jenkins-cicdtoolbox-run                            --
campus_ops_spec group can login                         campusspec          ${VALID_PASSWORD}       jenkins-user,jenkins-netcicd-run,jenkins-netcicd-dev,jenkins-cicdtoolbox-run        --
# CAMPUS_DEV
campus_dev_lan group can login                          campuslandev        ${VALID_PASSWORD}       jenkins-user,jenkins-netcicd-run,jenkins-netcicd-dev,jenkins-cicdtoolbox-run        --
campus_dev_wifi group can login                         campuswifidev       ${VALID_PASSWORD}       jenkins-user,jenkins-netcicd-run,jenkins-netcicd-dev,jenkins-cicdtoolbox-run        --
# WAN
wan_ops_oper group can login                            wanoper             ${VALID_PASSWORD}       jenkins-user,jenkins-netcicd-run,jenkins-netcicd-dev,jenkins-cicdtoolbox-run        --
wan_ops_spec group can login                            wanspec             ${VALID_PASSWORD}       jenkins-user,jenkins-netcicd-run,jenkins-netcicd-dev,jenkins-cicdtoolbox-run        --
# WAN_DEV
wan_dev_design group can login                          corearchitect       ${VALID_PASSWORD}       jenkins-user,jenkins-netcicd-run,jenkins-netcicd-dev,jenkins-cicdtoolbox-run        --
# DC
# DC_OPS
# DC_OPS_COMP
dc_ops_compute_oper group can login                     compudude           ${VALID_PASSWORD}       jenkins-user,jenkins-netcicd-run,jenkins-cicdtoolbox-run                            jenkins-netcicd-dev,jenkins-cicdtoolbox-dev
dc_ops_compute_spec group can login                     compuspecialist     ${VALID_PASSWORD}       jenkins-user,jenkins-netcicd-run,jenkins-cicdtoolbox-run                            jenkins-netcicd-dev,jenkins-cicdtoolbox-dev
# DC_OPS_NET
dc_ops_network_oper group can login                     netdude             ${VALID_PASSWORD}       jenkins-user,jenkins-netcicd-run,jenkins-cicdtoolbox-run                            jenkins-netcicd-dev,jenkins-cicdtoolbox-dev
dc_ops_network_spec group can login                     netspecialist       ${VALID_PASSWORD}       jenkins-user,jenkins-netcicd-run,jenkins-netcicd-dev, jenkins-cicdtoolbox-run       jenkins-cicdtoolbox-dev
# DC_OPS_STOR
dc_ops_storage_oper group can login                     diskdude            ${VALID_PASSWORD}       jenkins-user,jenkins-netcicd-run,jenkins-cicdtoolbox-run                            jenkins-netcicd-dev,jenkins-cicdtoolbox-dev
dc_ops_storage_spec group can login                     diskspecialist      ${VALID_PASSWORD}       jenkins-user,jenkins-netcicd-run,jenkins-cicdtoolbox-run                            jenkins-netcicd-dev,jenkins-cicdtoolbox-dev
# DC_DEV
dc_dev_compute group can login                          compuarchitect      ${VALID_PASSWORD}       jenkins-user,jenkins-netcicd-run,jenkins-cicdtoolbox-run                            jenkins-netcicd-dev,jenkins-cicdtoolbox-dev
dc_dev_network group can login                          netarchitect        ${VALID_PASSWORD}       jenkins-user,jenkins-netcicd-run,jenkins-cicdtoolbox-run                            jenkins-netcicd-dev,jenkins-cicdtoolbox-dev
dc_dev_storage group can login                          diskarchitect       ${VALID_PASSWORD}       jenkins-user,jenkins-netcicd-run,jenkins-netcicd-dev, jenkins-cicdtoolbox-run       jenkins-cicdtoolbox-dev
# App
# APP_OPS
# APP_DEV
# TOOL
# TOOL_OPS
tooling_ops_oper group can login                        tooltiger           ${VALID_PASSWORD}       jenkins-user,jenkins-netcicd-run,jenkins-cicdtoolbox-run                            jenkins-netcicd-dev,jenkins-cicdtoolbox-dev
tooling_ops_spec group can login                        toolmaster          ${VALID_PASSWORD}       jenkins-user,jenkins-netcicd-run,jenkins-cicdtoolbox-run,jenkins-cicdtoolbox-dev    jenkins-netcicd-dev
# TOOL_DEV
tooling_dev_design group can login                      blacksmith          ${VALID_PASSWORD}       jenkins-user,jenkins-netcicd-run,jenkins-cicdtoolbox-run,jenkins-cicdtoolbox-dev    jenkins-netcicd-dev
# SEC
# SEC_OPS
security_ops_oper group can login                       happyhacker         ${VALID_PASSWORD}       jenkins-user                                                                        jenkins-netcicd-run,jenkins-netcicd-dev,jenkins-cicdtoolbox-run,jenkins-cicdtoolbox-dev
security_ops_spec group can login                       whitehat            ${VALID_PASSWORD}       jenkins-user                                                                        jenkins-netcicd-run,jenkins-netcicd-dev,jenkins-cicdtoolbox-run,jenkins-cicdtoolbox-dev
# SEC_DEV
security_dev_design group can login                     blackhat            ${VALID_PASSWORD}       jenkins-user                                                                        jenkins-netcicd-run,jenkins-netcicd-dev,jenkins-cicdtoolbox-run,jenkins-cicdtoolbox-dev
# FS 
field_services_eng group can login                      mechanicjoe         ${VALID_PASSWORD}       jenkins-user                                                                        jenkins-netcicd-run,jenkins-netcicd-dev,jenkins-cicdtoolbox-run,jenkins-cicdtoolbox-dev
field_services_floor_management group can login         patchhero           ${VALID_PASSWORD}       jenkins-user                                                                        jenkins-netcicd-run,jenkins-netcicd-dev,jenkins-cicdtoolbox-run,jenkins-cicdtoolbox-dev

*** Variables ***
${JENKINS URL}      https://jenkins.tooling.provider.test:8084/
${JENKINS whoAmI}   https://jenkins.tooling.provider.test:8084/whoAmI
${JENKINS LOGOUT}   https://jenkins.tooling.provider.test:8084/logout 

*** Keywords ***
Login with correct role provides correct authorization
    [Arguments]  ${USERNAME}  ${PASSWORD}  ${OK_ROLES}  ${FAIL_ROLES}
    Set Selenium Speed          ${DELAY}
    Are assigned roles present  ${USERNAME}             ${PASSWORD}                 ${OK_ROLES}               ${FAIL_ROLES}

Are assigned roles present
    [Arguments]  ${USERNAME}  ${PASSWORD}  ${OK_ROLES}  ${FAIL_ROLES}
    Set Window Size             2560                    1920
    Log into Jenkins as user    ${USERNAME}             ${PASSWORD}
    Test given roles            ${USERNAME}             ${OK_ROLES}                 ${FAIL_ROLES}
    Close Browser

Log into Jenkins as user
    [Arguments]  ${USERNAME}  ${PASSWORD}
    Keycloak Page Should Be Open
    Input Text                  username                ${USERNAME}
    Input Text                  password                ${PASSWORD}
    Submit Credentials


Test given roles
    [Arguments]     ${USERNAME}     ${OK_ROLES}     ${FAIL_ROLES}
    ${user_unknown}=        Run Keyword And Return Status    Page Should Contain        Invalid username or password.

    IF  ${user_unknown} 
        # User does not exist in Keycloak or password incorrect
        Log to Console      ${USERNAME} cannot log in

    ELSE
        # User exists in Keycloak and password is correct
        Go To                       ${JENKINS whoAmI}
        Location Should Contain     ${JENKINS URL}
        Log to Console              ${USERNAME} can login
        ${read_permission}=         Run Keyword And Return Status    Page Should Contain        missing the Overall/Read permission

        IF  ${read_permission}
            # None of the roles in the JWT is known in Jenkins, but the user exists in Keycloak
            Log to Console              ${USERNAME} can log in but has no rights
        ELSE
            # Role which the user has in the JWT is known in Jenkins
            Go To                       ${JENKINS whoAmI}
            Location Should Contain     ${JENKINS URL}

            @{MY_ROLES}=    Split String    ${OK_ROLES}     ,

            FOR  ${ROLE}  IN   @{MY_ROLES}
                ${role_exists}=              Run Keyword And Return Status    Page Should Contain           "${ROLE}"
                IF  ${role_exists}
                    Log to Console      ${USERNAME} can log in with permitted role ${ROLE}
                END
            END

            @{NO_ROLES}=    Split String    ${FAIL_ROLES}   ,
            FOR  ${ROLE}  IN   @{NO_ROLES}
                ${role_does_not_exist}=              Run Keyword And Return Status    Page Should Not Contain       "${ROLE}"
                IF  ${role_does_not_exist}
                    Log to Console      ${USERNAME} cannot log in with disallowed role ${ROLE}
                END
            END

            # We cannot test the roles on the page if they are in permitted and thus not find any additional roles!
        END
    END

