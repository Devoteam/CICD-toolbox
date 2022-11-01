*** Settings ***
Library           SeleniumLibrary
Library           OperatingSystem
Library    XML
Documentation     Setting up Hashicorp Vault

*** Test cases ***
Log in to vault
    Open vault site

Set number of unseal keys   
    Initialize vault

Get unseal keys and token
    Get keys

Sign in to Vault 
    Unseal Vault
    Sign in to vault

Set up PKI
    Enable PKI engine

Set up KV
    Enable Key Value Store

Set up Database
    Enable Database

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

Initialize vault
    Page Should Contain        master keys
    Input Text                 key-shares              1
    Input Text                 key-threshold           1
    Click Button               Initialize

Get keys                                                    
    ${token}                   SeleniumLibrary.Get Element Attribute    xpath:/html/body/div[1]/div/div[2]/div[1]/div/div/div/div[3]/div[1]/div[2]/div/div/div/button[1]    data-clipboard-text                                  
    Set Global Variable        ${token}
    Create File                ${EXECDIR}/vault/token.txt   ${token}
    ${key}                     SeleniumLibrary.Get Element Attribute    xpath:/html/body/div[1]/div/div[2]/div[1]/div/div/div/div[3]/div[1]/div[3]/div/div/div/button[1]    data-clipboard-text
    Set Global Variable        ${key}
    Create File                ${EXECDIR}/vault/key.txt   ${key}
    Click Link                 Continue to Unseal

Unseal Vault 
    Page Should Contain        Unseal Vault 
    Input Text                 key                    ${key}
    Click Element              xpath:/html/body/div[1]/div/div[2]/div[1]/div/div/div/div[3]/form/div[2]/div/div[1]/button

Sign in to vault    
    Page Should Contain        Sign in to Vault 
    Input Text                 token                      ${token}
    Click Button               auth-submit    

Enable PKI engine
    Page Should Contain        Secrets Engines
    Click Element              xpath:/html/body/div[1]/div/div[2]/div[1]/section/div/nav/div/nav/a/span
    Page Should Contain        Enable a Secrets Engine
    Click Element              xpath://*[@id="pki"]
    Sleep                      15
    Click Button               Next
    Page Should Contain        Enable PKI Certificates Secrets Engine
    Click Button               xpath:/html/body/div[1]/div/div[2]/div[1]/section/div/div/form/div[2]/div[1]/button
    Click Link                 secrets

Enable Key Value Store
    Page Should Contain        Secrets Engines
    Click Element              xpath:/html/body/div[1]/div/div[2]/div[1]/section/div/nav/div/nav/a/span
    Page Should Contain        Enable a Secrets Engine
    Click Element              xpath://*[@id="kv"]
    Click Element              xpath://*[@class="columns is-mobile is-variable is-1"]
    Click Button               Next
    Page Should Contain        Enable KV Secrets Engine
    Click Button               xpath:/html/body/div[1]/div/div[2]/div[1]/section/div/div/form/div[2]/div[1]/button
    Click Link                 secrets

Enable Database
    Page Should Contain        Secrets Engines
    Click Element              xpath:/html/body/div[1]/div/div[2]/div[1]/section/div/nav/div/nav/a/span
    Page Should Contain        Enable a Secrets Engine
    Click Element              xpath://*[@id="database"]
    Click Element              xpath://*[@class="columns is-mobile is-variable is-1"]
    Click Button               Next
    Page Should Contain        Enable Databases Secrets Engine
    Click Button               xpath:/html/body/div[1]/div/div[2]/div[1]/section/div/div/form/div[2]/div[1]/button