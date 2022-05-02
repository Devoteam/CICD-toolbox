*** Settings ***
Library           SeleniumLibrary
Library           Screenshot
Library           String
Library           Collections

*** Variables ***
${BROWSER1}         Firefox
${DELAY}            0

*** Keywords ***
Keycloak Page Should Be Open
    Sleep                       1
    Title Should Be    Sign in to Welcome to your Development Toolkit

Submit Credentials
    Click Button                kc-login
