*** Settings ***
Library     Collections
Library     RequestsLibrary

Test Setup          RequestsLibrary.create session   mysession     ${base_url}
Test Teardown       POST on Session   mysession   ${clear_db_url}

*** Variables ***
${base_url}     http://localhost:8080
${api_url}      /calculator/insertMultiple
${single_url}      /calculator/insert
${tax_url}      /calculator/taxRelief
${clear_db_url}     /calculator/rakeDatabase


${age18}=   01012005
${age19}=   01012004
${age35}=   01011988
${age36}=   01011987
${age50}=   01011973
${age51}=   01011972
${age75}=   01011948
${age78}=   01011945


*** Test Cases ***
Check Endpoint Returns list of natid, Tax relief and name
    ${hero1}=           Create Dictionary       birthday=01012001       gender=m        name=Super man     natid=1234      salary=100     tax=10
    ${hero2}=           Create Dictionary       birthday=24011993          gender=f       name=super women      natid=9231      salary=421.00     tax=12.0
    ${header}=          Create Dictionary       Content-Type=application/json      accept=*/*
    @{body}=    Create List     ${hero1}    ${hero2}
    ${response}=        POST    url=${base_url}${api_url}   json=@{body}      headers=${header}     expected_status=202
    ${status_code}=     Convert To String       ${response.status_code}
    Should Be Equal    ${status_code}      202
    ${header}=      Create Dictionary    accept=*/*
    ${responses}=    GET        ${base_url}${tax_url}   headers=${header}
    ${status_code}=     Convert To String       ${response.status_code}
    Should Be Equal     ${status_code}      202
    ${contents}=    Evaluate    json.loads('''${responses.content}''')    json
    FOR     ${content}      IN  @{contents}
        log     ${content}[natid]
        log     ${content}[name]
        log     ${content}[relief]
    END

Check Mask of 5th Character onwards
    ${hero1}=           Create Dictionary       birthday=01012001       gender=m        name=Super man     natid=1234567      salary=100     tax=10
    ${hero2}=           Create Dictionary       birthday=24011993          gender=f       name=super women      natid=9231123      salary=421.00     tax=12.0
    ${header}=          Create Dictionary       Content-Type=application/json      accept=*/*
    @{body}=    Create List     ${hero1}    ${hero2}
    ${response}=        POST    url=${base_url}${api_url}   json=@{body}      headers=${header}     expected_status=202
    ${status_code}=     Convert To String       ${response.status_code}
    Should Be Equal    ${status_code}      202
    ${header}=      Create Dictionary    accept=*/*
    ${responses}=    GET        ${base_url}${tax_url}   headers=${header}
    ${status_code}=     Convert To String       ${response.status_code}
    Should Be Equal     ${status_code}      202
    ${contents}=    Evaluate    json.loads('''${responses.content}''')    json
    ${content}=     Copy Dictionary     ${contents}[0]
     should be equal     ${content}[natid]       1234$$$
    ${content}=     Copy Dictionary     ${contents}[1]
     should be equal     ${content}[natid]       9231$$$

Check Tax Relief
    [template]      Check relief
    --Age 18 Male       m       ${age18}        2000     10.45     1990.00      Rounding Up Error
    --Age 19 Male       m       ${age19}        2000     10.45     1592.00      Rounding Up Error
    --Age 35 Male       m       ${age35}        2000     10.45     1592.00      Rounding Up Error
    --Age 36 Male       m       ${age36}        2000     10.45     995.00       Rounding Up Error
    --Age 50 Male       m       ${age50}        2000     10.45     995.00       Rounding Up Error
    --Age 51 Male       m       ${age51}        2000     10.45     730.00       ${NULL}
    --Age 75 Male       m       ${age75}        2000     10.45     730.00       ${NULL}
    --Age 78 Male       m       ${age78}        2000     10.45     99.00        ${NULL}
    --Age 18 Female       f       ${age18}        2000     10.45     2490.00      Rounding Up Error
    --Age 19 Female       f       ${age19}        2000     10.45     2092.00      Rounding Up Error
    --Age 35 Female       f       ${age35}        2000     10.45     2092.00     Rounding Up Error
    --Age 36 Female       f       ${age36}        2000     10.45     1495.00       Rounding Up Error
    --Age 50 Female       f       ${age50}        2000     10.45     1495.00       Rounding Up Error
    --Age 51 Female       f       ${age51}        2000     10.45     1230.00       ${NULL}
    --Age 75 Female       f       ${age75}        2000     10.45     1230.00      ${NULL}
    --Age 78 Female       f       ${age78}        2000     10.45     599.00        ${NULL}

Rounding Up Rule
     [template]      Check rounding
    --Age 18 Male       m       ${age18}        2000     10.45     1990.00      Rounding Up Error


Rounding Down Rule
    [template]      Check rounding
    --Age 51 Male       m       ${age51}        2000     10.45     730.00       ${NULL}

Checking Of Tax Relief Range 0 to 50
    [template]      Check relief
    --Relief is 0       m       01012020        100         100         0           Error Relief is 0 but the final is 25.00
    --Relief Is 1.3     m       01012020        100         98.7        50.00       ${NULL}
    --Relief Is 48.6    m       01012020        100         51.4        50.00       ${NULL}
    --Relief Is 50      m       01012020        100         50          50.00       ${NULL}
    --Relief Is 51      m       01012020        100         49          51.00       ${NULL}

Checking Truncating with lower rounding
    [template]      Check relief
    --Relief Is 1979.495     m       01012005        2000         20.505        1979.00      ${NULL}

Checking Truncating with upper rounding
    [template]      Check relief
        --Relief Is 1979.595     m       01012005        2000         20.405        1980.00     Truncating is working but rounding up is not


*** Keywords ***
Check relief
    [Arguments]         ${comment}        ${gender}      ${birthday}     ${salary}       ${tax}      ${expected_relief}     ${msg}
    ${body}=            create dictionary       birthday=${birthday}       gender=${gender}        name=super man    natid=12345     salary=${salary}     tax=${tax}
    ${header}=          create dictionary       Content-Type=application/json      accept=*/*
    ${response}=        POST    url=${base_url}${single_url}   json=${body}      headers=${header}     expected_status=202
    ${response}=        GET     ${base_url}${tax_url}   headers=${header}
    ${status_code}=     Convert To String       ${response.status_code}
    Should Be Equal     ${status_code}      200
    ${contents}=    Evaluate    json.loads('''${response.content}''')    json
    ${content}=     Copy Dictionary     ${contents}[0]
    Run Keyword And Warn On Failure  should be equal     ${content}[relief]      ${expected_relief}     name=${msg}-${comment}
    POST on Session   mysession   ${clear_db_url}

Check rounding
    [Arguments]         ${comment}        ${gender}      ${birthday}     ${salary}       ${tax}      ${expected_relief}     ${msg}
    ${body}=            create dictionary       birthday=${birthday}       gender=${gender}        name=super man    natid=12345     salary=${salary}     tax=${tax}
    ${header}=          create dictionary       Content-Type=application/json      accept=*/*
    ${response}=        POST    url=${base_url}${single_url}   json=${body}      headers=${header}     expected_status=202
    ${response}=        GET     ${base_url}${tax_url}   headers=${header}
    ${status_code}=     Convert To String       ${response.status_code}
    Should Be Equal     ${status_code}      200
    ${contents}=    Evaluate    json.loads('''${response.content}''')    json
    ${content}=     Copy Dictionary     ${contents}[0]
    should be equal     ${content}[relief]      ${expected_relief}     name=${msg}-${comment}


