*** Settings ***
Library     Collections
Library     RequestsLibrary
Test Setup          RequestsLibrary.create session   mysession     ${base_url}
Test Teardown       POST on Session   mysession   ${clear_db_url}

*** Variables ***

${base_url}     http://localhost:8080
${api_url}      /calculator/insertMultiple
${clear_db_url}     /calculator/rakeDatabase
${check_summary}    /calculator/taxReliefSummary

*** Test Cases ***
Missing Natid
    ${body}=            create dictionary       name=super man     gender=m     birthday=01012001       salary=1000     tax=0
    ${header}=          create dictionary       Content-Type=application/json      accept=*/*
    @{body}=            Create List     ${body}
    ${response}=        POST    url=${base_url}${api_url}   json=@{body}      headers=${header}    expected_status=500      msg= Wrong status code

Missing Name
    ${body}=            create dictionary       natid=nid-12345     gender=m     birthday=01012001       salary=1000     tax=0
    ${header}=          create dictionary       Content-Type=application/json      accept=*/*
    @{body}=            Create List     ${body}
    ${response}=        POST    url=${base_url}${api_url}   json=@{body}      headers=${header}    expected_status=500      msg= Wrong status code

Missing Gender
    ${body}=            create dictionary       natid=nid-12345     name=super man     birthday=01012001       salary=1000     tax=0
    ${header}=          create dictionary       Content-Type=application/json      accept=*/*
    @{body}=            Create List     ${body}
    ${response}=        POST    url=${base_url}${api_url}   json=@{body}      headers=${header}    expected_status=500      msg= Wrong status code - Missing Gender

Missing Birthday
    ${body}=            create dictionary       natid=nid-12345     name=super man     gender=m       salary=1000     tax=0
    ${header}=          create dictionary       Content-Type=application/json      accept=*/*
    @{body}=            Create List     ${body}
    ${response}=        POST    url=${base_url}${api_url}   json=@{body}      headers=${header}    expected_status=500      msg= Wrong status code

Missing Salary
    ${body}=            create dictionary       natid=nid-12345     name=super man     gender=m     birthday=01012001     tax=0
    ${header}=          create dictionary       Content-Type=application/json      accept=*/*
    @{body}=            Create List     ${body}
    ${response}=        POST    url=${base_url}${api_url}   json=@{body}      headers=${header}    expected_status=500      msg= Wrong status code

Missing TaxPaid
    ${body}=            create dictionary       natid=nid-12345     name=super man     gender=m     birthday=01012001       salary=1000
    ${header}=          create dictionary       Content-Type=application/json      accept=*/*
    @{body}=            Create List     ${body}
    ${response}=        POST    url=${base_url}${api_url}   json=@{body}      headers=${header}    expected_status=500      msg= Wrong status code


Empty Parameter
    [template]  Adding single hero
    --Empty_Natid     ${None}     super man        m           01012001        100         0           500     ""
    --Empty_Name      nid-12345   ${None}          m           01012001        100         0           500     ""
    --Empty_Gender    nid-12345   super man        ${None}     01012001        100         0           500     "Wrong status code - missing gender should not successful"
    --Empty_Birthday  nid-12345   super man        m           ${None}         100         0           500     ""
    --Empty_Salary    nid-12345   super man        m           01012001        ${None}     0           500     ""
    --Empty_Tax       nid-12345   super man        m           01012001        100         ${None}     500     ""


Natid Limit Test
    [template]  Adding single hero
    --Natid Digit                      1234567         super man       m       01012001        100     0       202     ""
    --Natid Character                  natid           super man       m       01012001        100     0       202     ""
    --Natid Special Character          !@#$%^&*()      super man       m       01012001        100     0       202     ""
    --Natid Less Than 3 Character      ab              super man       m       01012001        100     0       202     ""
    --Natid Mix                        natid-123@123   super man       m       01012001        100     0       202     ""


Name Limit Test
    [template]  Adding single hero
    --Name Digit                       nid-12345       1234562             m       01012001        100     0       500     "wrong status code - Number should not be in name"
    --Name Character                   nid-12345       Super man           m       01012001        100     0       202     ""
    --Name Special Character           nid-12345       @!#$%^&*()          m       01012001        100     0       202     ""
    --Name Less Than 3 Character       nid-12345       Hi                  m       01012001        100     0       202     ""
    --Natid Mix                        nid-12345       Super Man @ Hi      m       01012001        100     0       202     ""


Gender Limit Test
    [template]  Adding single hero
    --Gender Digit                     nid-12345   Super man     1         01012001        100     0       500     "wrong status code - Gender should not be digit"
    --Gender Char Other Than m or f    nid-12345   Super man     a         01012001        100     0       500     "wrong status code - Gender should not be other char than m or f"
    --Gender Special Character         nid-12345   Super man     @         01012001        100     0       500     "wrong status code - Gender should not be special character"
    --Gender Char Capital M            nid-12345   Super man     M         01012001        100     0       202     ""
    --Gender Char Capital F            nid-12345   Super man     F         01012001        100     0       202     ""
    --Gender Character                 nid-12345   Super man     male      01012001        100     0       500     ""

Birthday Limit Test
    [template]  Check Resp Adding hero
    --Birthday Day is 0                                    nid-12345   Super man     m       00012001        100     0       500     "wrong status code"   Invalid value for DayOfMonth (valid values 1 - 28/31)
    --Birthday Day is Higher Than 31                       nid-12345   Super man     m       32012001        100     0       500     "wrong status code"    Invalid value for DayOfMonth (valid values 1 - 28/31)
    --Birthday Month is 0                                  nid-12345   Super man     m       01002001        100     0       500     "wrong status code"    Invalid value for MonthOfYear (valid values 1 - 12)
    --Birthday Month is Higher Than 12                     nid-12345   Super man     m       01132001        100     0       500     "wrong status code"    Invalid value for MonthOfYear (valid values 1 - 12)
    --Birthday Year is 0                                   nid-12345   Super man     m       01010000        100     0       500     "wrong status code"    Invalid value for YearOfEra (valid values 1 - 999999999/1000000000)
    --Birthday Year is Higher Than Current Year            nid-12345   Super man     m       01019999        100     0       500     "wrong status code - should not be born in the future"    Should not exceeed current year
    --Birthday Year is Lower Than Current Year by 150      nid-12345   Super man     m       01011863        100     0       500     "wrong status code - hero life expectancy is too long"    hero age is higher than 150

Salary Limit Test
    [template]  Adding single hero
    --Salary Digit                  nid-12345   Super man     m       01012001        100          0       202     ""
    --Salary Float                  nid-12345   Super man     m       01012001        100.546      0       202     ""
    --Salary Negative Digit         nid-12345   Super man     m       01012001        -100         0       500     "wrong status code - salary should not be negative"
    --Salary Negative Float         nid-12345   Super man     m       01012001        -100.546     0       500     "wrong status code - salary should not be negative"
    --Salary Character              nid-12345   Super man     m       01012001        asdq         0       500     "wrong status code - salary should not contain character"
    --Salary Special Character      nid-12345   Super man     m       01012001        !@#$%^&*()   0       500     "wrong status code - salary should not contain special character"
    --Salary is Zero                nid-12345   Super man     m       01012001        0            0       202     "wrong status code - salary should not be 0"

Tax Limit Test
    [template]  Adding single hero
    --Tax Digit                  nid-12345   Super man     m       01012001        100          100             202     ""
    --Tax Float                  nid-12345   Super man     m       01012001        100.546      100.546         202     ""
    --Tax Negative Digit         nid-12345   Super man     m       01012001        100          -100            500     "wrong status code - tax should not be negative"
    --Tax Negative Float         nid-12345   Super man     m       01012001        100          -100.546        500     "wrong status code - tax should not be negative"
    --Tax Character              nid-12345   Super man     m       01012001        100          asdq            500     "wrong status code - tax should not contain character"
    --Tax Special Character      nid-12345   Super man     m       01012001        100          !@#$%^&*()      500     "wrong status code - tax should not contain special character"
    --Tax is Zero                nid-12345   Super man     m       01012001        100          0               202     ""
    --Tax More Than Salary       nid-12345   Super man     m       01012001        100          200             500     "wrong status code - Tax paid should not be more than salary"



Mixed Valid and Invalid hero
    ${hero1}=           create dictionary       birthday=01012001       gender=m        name=Super man     natid=nid-12345      salary=100     tax=10
    ${hero2}=           create dictionary       birthday=24011993          gender=female       name=super women      natid=nat-9231      salary=421.00     tax=12.0
    ${header}=          create dictionary       Content-Type=application/json      accept=*/*
    @{body}=    Create List     ${hero1}    ${hero2}
    ${response}=        POST    url=${base_url}${api_url}   json=@{body}      headers=${header}     expected_status=500

    ${header}=      create dictionary    accept=*/*
    ${response}=    GET        ${base_url}${check_summary}   headers=${header}
    ${content}=     convert to string       ${response.content}
    should contain  ${content}      "totalWorkingClassHeroes":"0"


Mixed Invalid and valid hero
    ${hero1}=           create dictionary       birthday=01012001       gender=male        name=Super man     natid=nid-12345      salary=100     tax=10
    ${hero2}=           create dictionary       birthday=24011993          gender=f       name=super women      natid=nat-9231      salary=421.00     tax=12.0
    ${header}=          create dictionary       Content-Type=application/json      accept=*/*
    @{body}=    Create List     ${hero1}    ${hero2}
    ${response}=        POST    url=${base_url}${api_url}   json=@{body}      headers=${header}     expected_status=500

    ${header}=      create dictionary    accept=*/*
    ${response}=    GET        ${base_url}${check_summary}   headers=${header}
    ${content}=     convert to string       ${response.content}
    should contain  ${content}      "totalWorkingClassHeroes":"0"

Two Valid Heros
    ${hero1}=           create dictionary       birthday=01012001       gender=m        name=Super man     natid=nid-12345      salary=100     tax=10
    ${hero2}=           create dictionary       birthday=24011993          gender=f       name=super women      natid=nat-9231      salary=421.00     tax=12.0
    ${header}=          create dictionary       Content-Type=application/json      accept=*/*
    @{body}=    Create List     ${hero1}    ${hero2}
    ${response}=        POST    url=${base_url}${api_url}   json=@{body}      headers=${header}     expected_status=202

    ${header}=      create dictionary    accept=*/*
    ${response}=    GET        ${base_url}${check_summary}   headers=${header}
    ${content}=     convert to string       ${response.content}
    should contain  ${content}      "totalWorkingClassHeroes":"2"


*** Keywords ***
Adding single hero
    [Arguments]         ${comment}      ${natid}       ${name}      ${gender}      ${birthday}     ${salary}       ${tax}      ${expected_status_code}     ${message}
    ${hero1}=           create dictionary       birthday=${birthday}       gender=${gender}        name=${name}      natid=${natid}      salary=${salary}     tax=${tax}
    ${hero2}=           create dictionary       birthday=24011993          gender=f       name=super women      natid=nat-9231      salary=421.00     tax=12.0
    ${header}=          create dictionary       Content-Type=application/json      accept=*/*
    @{body}=    Create List     ${hero1}    ${hero2}
    ${response}=        POST    url=${base_url}${api_url}   json=@{body}      headers=${header}     expected_status=${expected_status_code}      msg= ${message}


Check Resp Adding hero
    [Arguments]         ${comment}      ${natid}       ${name}      ${gender}      ${birthday}     ${salary}       ${tax}      ${expected_status_code}     ${message}   ${err_msg}
    ${body}=            create dictionary       birthday=${birthday}       gender=${gender}        name=${name}      natid=${natid}      salary=${salary}     tax=${tax}
    ${header}=          create dictionary       Content-Type=application/json      accept=*/*
    @{body}=    Create List     ${body}
    ${response}=        POST    url=${base_url}${api_url}   json=@{body}     headers=${header}     expected_status=${expected_status_code}      msg= ${message}
    ${content}=    convert to string    ${response.content}
    should contain       ${content}     ${err_msg}



