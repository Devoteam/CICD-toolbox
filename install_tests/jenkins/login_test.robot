*** Settings ***
Library           SeleniumLibrary
Library           String
Library           Collections

Documentation       Validating login for each LDAP group
...                 Each LDAP group has a predefined user
...                 When this user logs in, the associated rights must be assigned.
...                 There are three tests required:
...                 - Are assigned roles present
...                 - Are present roles assigned
...                 - Are explicitly disallowed roles not secretly present

Test Template    Login with correct role provides correct authorization

*** Test Cases ***                          USERNAME            PASSWORD                ROLES                                                                               NOT_ROLES
netcicd is admin user                       netcicd             ${VALID_PASSWORD}       jenkins-admin                                                                       jenkins-user  
jenkins-git cannot login to jenkins         jenkins-git         ${VALID_PASSWORD}       --                                                                                  --
jenkins-jenkins can login to jenkins        jenkins-jenkins     ${VALID_PASSWORD}       jenkins-user                                                                        jenkins-admin
netcicd-pipeline cannot login to jenkins    netcicd-pipeline    ${VALID_PASSWORD}       --                                                                                  --
# # IAM: no users
# # Office: no users
# # Campus: no users
# # WAN: no users
# # DC
# # DC_OPS
# # DC_OPS_COMP
# # DC_OPS_COMP_OPER 
# compudude can login to jenkins              compudude           ${VALID_PASSWORD}       [jenkins-user, jenkins-netcicd-run, jenkins-cicdtoolbox-run]                        []
# # DC_OPS_COMP_SPEC
# compuspecialist can login to jenkins        compuspecialist     ${VALID_PASSWORD}       [jenkins-user, jenkins-netcicd-run, jenkins-cicdtoolbox-run]                        []
# # DC_OPS_NET
# # DC_OPS_NET_OPER 
# netdude can login to jenkins                netdude             ${VALID_PASSWORD}       [jenkins-user, jenkins-netcicd-run, jenkins-cicdtoolbox-run]                        []
# # DC_OPS_NET_SPEC
# netspecialist can login to jenkins          netspecialist       ${VALID_PASSWORD}       [jenkins-user, jenkins-netcicd-run, jenkins-netcicd-dev, jenkins-cicdtoolbox-run]   []
# # DC_OPS_STOR
# # DC_OPS_STOR_OPER 
# diskdude can login to jenkins               diskdude            ${VALID_PASSWORD}       [jenkins-user, jenkins-netcicd-run, jenkins-cicdtoolbox-run]                        []
# # DC_OPS_STOR_SPEC
# diskspecialist can login to jenkins         diskspecialist      ${VALID_PASSWORD}       [jenkins-user, jenkins-netcicd-run, jenkins-cicdtoolbox-run]                        []
# # DC_DEV
# compuarchitect can login to jenkins         compuarchitect      ${VALID_PASSWORD}       [jenkins-user, jenkins-netcicd-run, jenkins-cicdtoolbox-run]                        [jenkins-netcicd-dev]
# diskarchitect can login to jenkins          diskarchitect       ${VALID_PASSWORD}       [jenkins-user, jenkins-netcicd-run, jenkins-cicdtoolbox-run]                        [jenkins-netcicd-dev]       
# netarchitect can login to jenkins           netarchitect        ${VALID_PASSWORD}       [jenkins-user, jenkins-netcicd-run, jenkins-netcicd-dev, jenkins-cicdtoolbox-run]   []
# # App
# # APP_OPS
# # APP_DEV
# # TOOL
# # TOOL_OPS
# # TOOL_OPS_OPER
# tooltiger can login to jenkins              tooltiger           ${VALID_PASSWORD}       [jenkins-user, jenkins-netcicd-run, jenkins-cicdtoolbox-run]                        []
# # TOOL_OPS_SPEC
# toolmaster can login to jenkins             toolmaster          ${VALID_PASSWORD}       [jenkins-user, jenkins-netcicd-run, jenkins-cicdtoolbox-dev]                        []
# # TOOL_DEV
# blacksmith can login to jenkins             blacksmith          ${VALID_PASSWORD}       [jenkins-user, jenkins-netcicd-run, jenkins-cicdtoolbox-dev]                        []
# # SEC
# # SEC_OPS
# # SEC_OPS_OPER
# happyhacker can login to jenkins            happyhacker         ${VALID_PASSWORD}       [jenkins-user]                                                                      [jenkins-netcicd-run, jenkins-netcicd-dev, jenkins-cicdtoolbox-run, jenkins-cicdtoolbox-dev]
# # SEC_OPS_SPEC
# whitehat can login to jenkins               whitehat            ${VALID_PASSWORD}       [jenkins-user]                                                                      [jenkins-netcicd-run, jenkins-netcicd-dev, jenkins-cicdtoolbox-run, jenkins-cicdtoolbox-dev]
# # SEC_DEV
# blackhat can login to jenkins               blackhat            ${VALID_PASSWORD}       [jenkins-user]                                                                      [jenkins-netcicd-run, jenkins-netcicd-dev, jenkins-cicdtoolbox-run, jenkins-cicdtoolbox-dev]
# # FS
# # FS_ENG
# mechanicjoe can login to jenkins            mechanicjoe         ${VALID_PASSWORD}       [jenkins-user]                                                                      [jenkins-netcicd-run, jenkins-netcicd-dev, jenkins-cicdtoolbox-run, jenkins-cicdtoolbox-dev]
# # FS
# # FS_FM
# patchhero can login to jenkins              patchhero           ${VALID_PASSWORD}       [jenkins-user]                                                                      [jenkins-netcicd-run, jenkins-netcicd-dev, jenkins-cicdtoolbox-run, jenkins-cicdtoolbox-dev]

*** Variables ***
${JENKINS URL}      http://jenkins.tooling.test:8084/
${JENKINS whoAmI}   http://jenkins.tooling.test:8084/whoAmI
${JENKINS LOGOUT}   http://jenkins.tooling.test:8084/logout 
${BROWSER1}         Firefox
${DELAY}            0

*** Keywords ***
Login with correct role provides correct authorization
    [Arguments]  ${USERNAME}  ${PASSWORD}  ${OK_ROLES}  ${FAIL_ROLES}
    Set Selenium Speed          ${DELAY}
    Are assigned roles present  ${USERNAME}             ${PASSWORD}                 ${OK_ROLES}

Are assigned roles present
    [Arguments]  ${USERNAME}  ${PASSWORD}  ${OK_ROLES}
    Open Browser                ${JENKINS URL}          ${BROWSER1}
    Log into Jenkins as user    ${USERNAME}             ${PASSWORD}
    Test given roles            ${USERNAME}             ${OK_ROLES}
    Close Browser

Log into Jenkins as user
    [Arguments]  ${USERNAME}  ${PASSWORD}
    Keycloak Page Should Be Open
    Input Text                  username                ${USERNAME}
    Input Text                  password                ${PASSWORD}
    Submit Credentials
    Location Should Contain     ${JENKINS URL}

Test given roles
    [Arguments]     ${USERNAME}     ${OK_ROLES}
    Go To           ${JENKINS whoAmI}
    @{MY_ROLES}=    Split String                        ${OK_ROLES}                 ,
    FOR  ${ROLE}  IN   @{MY_ROLES}
        ${Status}=     Run Keyword And Return Status    Page Should Contain         "${ROLE}"
        IF  ${Status}
            Log to Console      ${ROLE} can log in
        ELSE
            ${read_permission}=     Run Keyword And Return Status    Page Should Contain    "missing the Overall/Read permission"
            IF  ${read_permission}
                Log to Console      ${USERNAME} cannot log in
            ELSE
                Log to Console      ${USERNAME} can login but has no rights
            END
        END
    END


Keycloak Page Should Be Open
    Title Should Be    Sign in to Welcome to the Infrastructure Development Toolkit

Submit Credentials
    Click Button                kc-login
