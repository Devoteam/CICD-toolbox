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
netcicd is admin user                           netcicd             ${VALID_PASSWORD}       jenkins-admin                                                                       jenkins-user  
jenkins-git cannot login to Jenkins             jenkins-git         ${VALID_PASSWORD}       --                                                                                  --
jenkins-jenkins can login to Jenkins            jenkins-jenkins     ${VALID_PASSWORD}       jenkins-user                                                                        jenkins-admin
netcicd-pipeline cannot login to Jenkins        netcicd-pipeline    ${VALID_PASSWORD}       --                                                                                  --
# IAM: no users
# Office: no users
# Campus: no users
# CAMPUS_OPS
# CAMPUS_OPS_OPER can login to Jenkins                                ${VALID_PASSWORD}       jenkins-user,jenkins-netcicd-run,jenkins-cicdtoolbox-run                            --
# CAMPUS_OPS_SPEC can login to Jenkins                                ${VALID_PASSWORD}       jenkins-user,jenkins-netcicd-run,jenkins-netcicd-dev,jenkins-cicdtoolbox-run        --
# CAMPUS_DEV_LAN_DESIGNER can login to Jenkins                        ${VALID_PASSWORD}       jenkins-user,jenkins-netcicd-run,jenkins-netcicd-dev,jenkins-cicdtoolbox-run        --
# CAMPUS_DEV_WIFI_DESIGNER can login to Jenkins                       ${VALID_PASSWORD}       jenkins-user,jenkins-netcicd-run,jenkins-netcicd-dev,jenkins-cicdtoolbox-run        --
# WAN: no users
# WAN_OPS_OPER can login to Jenkins                                   ${VALID_PASSWORD}       jenkins-user,jenkins-netcicd-run,jenkins-cicdtoolbox-run                            --
# WAN_OPS_SPEC can login to Jenkins                                   ${VALID_PASSWORD}       jenkins-user,jenkins-netcicd-run,jenkins-netcicd-dev,jenkins-cicdtoolbox-run        --
# WAN_DEV
# WAN_DEV_SPEC can login to Jenkins                                   ${VALID_PASSWORD}       jenkins-user,jenkins-netcicd-run,jenkins-netcicd-dev,jenkins-cicdtoolbox-run        --
# DC
# DC_OPS
# DC_OPS_COMP
# DC_OPS_COMP_OPER 
compudude can login to Jenkins                  compudude           ${VALID_PASSWORD}       jenkins-user,jenkins-netcicd-run,jenkins-cicdtoolbox-run                            jenkins-netcicd-dev,jenkins-cicdtoolbox-dev
# DC_OPS_COMP_SPEC  
compuspecialist can login to Jenkins            compuspecialist     ${VALID_PASSWORD}       jenkins-user,jenkins-netcicd-run,jenkins-cicdtoolbox-run                            jenkins-netcicd-dev,jenkins-cicdtoolbox-dev
# DC_OPS_COMP_SPEC
# DC_OPS_NET
# DC_OPS_NET_OPER 
netdude can login to Jenkins                    netdude             ${VALID_PASSWORD}       jenkins-user,jenkins-netcicd-run,jenkins-cicdtoolbox-run                            jenkins-netcicd-dev,jenkins-cicdtoolbox-dev
# DC_OPS_NET_SPEC
netspecialist can login to Jenkins              netspecialist       ${VALID_PASSWORD}       jenkins-user,jenkins-netcicd-run,jenkins-netcicd-dev, jenkins-cicdtoolbox-run       jenkins-cicdtoolbox-dev
# DC_OPS_STOR
# DC_OPS_STOR_OPER 
diskdude can login to Jenkins                   diskdude            ${VALID_PASSWORD}       jenkins-user,jenkins-netcicd-run,jenkins-cicdtoolbox-run                            jenkins-netcicd-dev,jenkins-cicdtoolbox-dev
# DC_OPS_STOR_SPEC
diskspecialist can login to Jenkins             diskspecialist      ${VALID_PASSWORD}       jenkins-user,jenkins-netcicd-run,jenkins-cicdtoolbox-run                            jenkins-netcicd-dev,jenkins-cicdtoolbox-dev
# DC_DEV
compuarchitect can login to Jenkins             compuarchitect      ${VALID_PASSWORD}       jenkins-user,jenkins-netcicd-run,jenkins-cicdtoolbox-run                            jenkins-netcicd-dev,jenkins-cicdtoolbox-dev
diskarchitect can login to Jenkins              diskarchitect       ${VALID_PASSWORD}       jenkins-user,jenkins-netcicd-run,jenkins-cicdtoolbox-run                            jenkins-netcicd-dev,jenkins-cicdtoolbox-dev     
netarchitect can login to Jenkins               netarchitect        ${VALID_PASSWORD}       jenkins-user,jenkins-netcicd-run,jenkins-netcicd-dev,jenkins-cicdtoolbox-run        jenkins-cicdtoolbox-dev
# App
# APP_OPS
# APP_DEV
# TOOL
# TOOL_OPS
# TOOL_OPS_OPER
tooltiger can login to Jenkins                  tooltiger           ${VALID_PASSWORD}       jenkins-user,jenkins-netcicd-run,jenkins-cicdtoolbox-run                            jenkins-netcicd-dev,jenkins-cicdtoolbox-dev
# TOOL_OPS_SPEC
toolmaster can login to Jenkins                 toolmaster          ${VALID_PASSWORD}       jenkins-user,jenkins-netcicd-run,jenkins-cicdtoolbox-run,jenkins-cicdtoolbox-dev    jenkins-netcicd-dev
# TOOL_DEV
blacksmith can login to Jenkins                 blacksmith          ${VALID_PASSWORD}       jenkins-user,jenkins-netcicd-run,jenkins-cicdtoolbox-run,jenkins-cicdtoolbox-dev    jenkins-netcicd-dev
# SEC
# SEC_OPS
# SEC_OPS_OPER
happyhacker can login to jenkins                happyhacker         ${VALID_PASSWORD}       jenkins-user                                                                        jenkins-netcicd-run,jenkins-netcicd-dev,jenkins-cicdtoolbox-run,jenkins-cicdtoolbox-dev
# SEC_OPS_SPEC
whitehat can login to jenkins                   whitehat            ${VALID_PASSWORD}       jenkins-user                                                                        jenkins-netcicd-run,jenkins-netcicd-dev,jenkins-cicdtoolbox-run,jenkins-cicdtoolbox-dev
# SEC_DEV
blackhat can login to jenkins                   blackhat            ${VALID_PASSWORD}       jenkins-user                                                                        jenkins-netcicd-run,jenkins-netcicd-dev,jenkins-cicdtoolbox-run,jenkins-cicdtoolbox-dev
# FS
# FS_ENG
mechanicjoe can login to jenkins                mechanicjoe         ${VALID_PASSWORD}       jenkins-user                                                                        jenkins-netcicd-run,jenkins-netcicd-dev,jenkins-cicdtoolbox-run,jenkins-cicdtoolbox-dev
# FS
# FS_FM
patchhero can login to jenkins                  patchhero           ${VALID_PASSWORD}       jenkins-user                                                                        jenkins-netcicd-run,jenkins-netcicd-dev,jenkins-cicdtoolbox-run,jenkins-cicdtoolbox-dev

*** Variables ***
${JENKINS URL}      http://jenkins.tooling.test:8084/
${JENKINS whoAmI}   http://jenkins.tooling.test:8084/whoAmI
${JENKINS LOGOUT}   http://jenkins.tooling.test:8084/logout 

*** Keywords ***
Login with correct role provides correct authorization
    [Arguments]  ${USERNAME}  ${PASSWORD}  ${OK_ROLES}  ${FAIL_ROLES}
    Set Selenium Speed          ${DELAY}
    Are assigned roles present  ${USERNAME}             ${PASSWORD}                 ${OK_ROLES}               ${FAIL_ROLES}

Are assigned roles present
    [Arguments]  ${USERNAME}  ${PASSWORD}  ${OK_ROLES}  ${FAIL_ROLES}
    Open Browser                ${JENKINS URL}          ${BROWSER1}
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

