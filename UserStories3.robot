*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     SeleniumLibrary
Library     OperatingSystem

#Test Teardown       Close Browser

*** Variables ***


${url}          http://localhost:8080/
${browser}      chrome
${upload_button}     input[type='file']

${base_url}     http://localhost:8080
${upload_file_url}      /calculator/uploadLargeFileForInsertionToDatabase
${filepath}   Get File For Streaming Upload     ${CURDIR}${/}test.csv
${file_name}        test.csv
*** Test Cases ***
Uploading csv file
    ${file}=       Get Binary File     ${CURDIR}\\test.csv
    ${header}=          create dictionary       Content-Type=multipart/form-data    accept=*/*
    ${asset}=       Create Dictionary    mldata=${file}
    ${response}=        POST    url=${base_url}${upload_file_url}   files=${asset}     headers=${header}
    log  API for csv is broken, it does not work with valid csv file.

