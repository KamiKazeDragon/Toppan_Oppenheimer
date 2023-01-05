*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     SeleniumLibrary


Test Teardown       Close Browser

*** Variables ***
${url}          http://localhost:8080/
${browser}      chrome
${dispense-buttton}     css:.btn.btn-danger.btn-block
${display-msg}      css:.display-4.font-weight-bold

*** Test Cases ***
Find button check is red-colored and text is Dispense Now
    Open Browser    browser=${browser}      url=${url}
    Wait Until Element Is Visible           ${dispense-buttton}
    ${elemets}=  Get WebElements  ${dispense-buttton}
    FOR     ${elemet}   IN      @{elemets}
        should be equal    ${elemet.text}   Dispense Now
    END

After clicking on the button
    Open Browser    browser=${browser}      url=${url}
    Wait Until Element Is Visible           ${dispense-buttton}
    Click Element    ${dispense-buttton}
    Wait Until Element Is Visible       ${display-msg}
    ${elemets}=  Get WebElements  ${display-msg}
    FOR     ${elemet}   IN      @{elemets}
        should be equal    ${elemet.text}   Cash dispensed
    END

