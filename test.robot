*** Settings ***
Documentation       Documentação da API do GitHub: https://developer.github.com/v3/
Library             RequestsLibrary
Library             Collections
Resource            ./variables/dados.robot

*** Variables ***
${baseUrl}          https://api.github.com
${ISSUES_URI}       /repos/mayribeirofernandes/myudemyrobotframeworkcourse/issues

*** Test Cases ***
Fazendo autenticação básica
    Conectar com autenticação por token na API do GitHub
    Solicitar os dados do meu usuário

Get issues com parâmetros
    Conectar na API do GitHub sem autenticação
    Pesquisar issues com o state "open" e com o label "bug"

Post usando headers
    Conectar com autenticação por token na API do GitHub
    Enviar a reação "+1" para a issue "8"

*** Keywords ***
#### Não é mais possível se autenticar na API do GitHub com a autenticação básica (user + pass), agora é necessário um token
# Conectar com autenticação básica na API do GitHub
#     ${myAuth}          Create List            ${user}              ${pass}
#     Create Session     alias=githubApiTest    url=${baseUrl}       auth=${myAuth}             disable_warnings=True

Conectar com autenticação por token na API do GitHub
    ${myHeader}         Create Dictionary       Authorization=Bearer ${personalToken}
    Create Session      alias=githubApiTest     url=${baseUrl}          headers=${myHeader}     disable_warnings=True

Solicitar os dados do meu usuário
    ${myUser}           Get On Session          alias=githubApiTest     url=/user
    Log                 Meus dados: ${myUser.json()}
    Confere sucesso na requisição   ${myUser}
    Confere meu login               ${myUser}

Conectar na API do GitHub sem autenticação
    Create Session      alias=mygithub          url=${baseUrl}          disable_warnings=True

Pesquisar issues com o state "${STATE}" e com o label "${LABEL}"
    &{myParams}         Create Dictionary       state=${STATE}          labels=${LABEL}
    ${MY_ISSUES}        Get On Session          alias=mygithub          url=${ISSUES_URI}       params=${myParams}
    Log                 Lista de Issues: ${MY_ISSUES.json()}
    Confere sucesso na requisição   ${MY_ISSUES}

Enviar a reação "${REACTION}" para a issue "${ISSUE_NUMBER}"
    ${myHeader}         Create Dictionary       Accept=application/vnd.github.squirrel-girl-preview+json
    ${MY_REACTION}      Post On Session         alias=githubApiTest    url=${ISSUES_URI}/${ISSUE_NUMBER}/reactions
    ...                                         data={"content": "${REACTION}"}                 headers=${myHeader}
    Log                 Meus dados: ${MY_REACTION.json()}
    Confere sucesso na requisição   ${MY_REACTION}

Confere sucesso na requisição
    [Arguments]         ${response}
    Should Be True      '${response.status_code}'=='200' or '${response.status_code}'=='201'        msg=Erro na requisição! Verifique: ${response}

Confere meu login
    [Arguments]         ${response}
    Should Be True      '${response.json()["login"]}'=='juniortruppel'                             #msg=Nome do usuário diferente do esperado