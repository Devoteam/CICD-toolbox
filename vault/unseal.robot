*** Settings ***
Library           SeleniumLibrary
Library           OperatingSystem
Library    XML
Documentation     Unseal Hashicorp Vault

*** Test cases ***
Log in to vault
    Open vault site

Sign in to Vault 
    Unseal Vault

Close browsers
    Close Browser
*** Variables ***

${BROWSER1}         headlessfirefox
${DELAY}            0
${URL}              http://vault.internal.provider.test:8200

*** Keywords ***
Open vault site
    Open Browser              ${URL}                  ${BROWSER1}
    Maximize Browser Window
    Sleep                     2

Unseal Vault 
    Page Should Contain        Unseal Vault 
    Input Text                 key                    ${key}
    Click Element              xpath:/html/body/div[1]/div/div[2]/div[1]/div/div/div/div[3]/form/div[2]/div/div[1]/button
