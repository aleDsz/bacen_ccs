# Bacen CCS

[![test](https://github.com/aleDsz/bacen_ccs/actions/workflows/test.yml/badge.svg?branch=main&event=push)](https://github.com/aleDsz/bacen_ccs/actions/workflows/test.yml)
[![Hex pm](http://img.shields.io/hexpm/v/bacen_ccs.svg?style=flat)](https://hex.pm/packages/bacen_ccs)
[![codecov](https://codecov.io/gh/aleDsz/bacen_ccs/branch/main/graph/badge.svg?token=FAX3D7YTUT)](https://codecov.io/gh/aleDsz/bacen_ccs)

Biblioteca responsável por centralizar e simplificar a comunicação entre
uma aplicação Elixir e o sistema [CCS](https://www.bcb.gov.br/acessoinformacao/cadastroclientes) do Bacen.

### Manual

Para acessar o Manual do CCS, utilize este [link](https://www.bcb.gov.br/content/acessoinformacao/ccs_docs/ccs_manual.pdf)

Para acessar o Manual Técnico do CCS, utilize este [link](https://www.bcb.gov.br/content/acessoinformacao/ccs_docs/CCS%20Orienta%C3%A7%C3%A3o%20T%C3%A9cnica.pdf)

Para acessar os Leiautes dos arquivos do sistema CCS, utilize este [link](https://www.bcb.gov.br/content/acessoinformacao/ccs_docs/CCS_Leiautes_Arquivos_Mensagens.pdf)

### Instalação

Para instalar, utilize as seguintes opções:

```elixir
# Direto do github
def deps do
  [
    # ...
    {:bacen_ccs, github: "aleDsz/bacen_ccs"}
  ]
end

# Direto do hex
def deps do
  [
    # ...
    {:bacen_ccs, "~> 0.1.0"}
  ]
end
```

Após isso, altere a função privada `application/0` para utilizar a biblioteca `xmerl` como aplicação extra:

```elixir
def application do
  [
    mod: {MyApp.Application, []},
    extra_applications: [:logger, :runtime_tools, :xmerl]
  ]
end
```

### O que é o CCS?

O Cadastro de Clientes do Sistema Financeiro Nacional (CCS) é um sistema
informatizado que permite indicar onde os clientes de instituições financeiras
mantêm contas de depósitos à vista, depósitos de poupança, depósitos a prazo
e outros bens, direitos e valores, diretamente ou por intermédio de seus
representantes legais e procuradores.

O principal objetivo do CCS é auxiliar nas investigações financeiras conduzidas
pelas autoridades competentes, mediante requisição de informações pelo
Poder Judiciário (ofício eletrônico), ou por outras autoridades,
quando devidamente legitimadas.

O Cadastro não contém dados de valor, de movimentação financeira ou de saldos
de contas/aplicações e visa dar cumprimento ao art. 3º da Lei n. 10.701/2003,
que incluiu dispositivo na Lei de Lavagem de Dinheiro
(Lei n. 9.613/1998, art. 10-A), determinando que o Banco Central
"manterá registro centralizado formando o cadastro geral de correntistas
e clientes de instituições financeiras, bem como de seus procuradores".

### Licença

Esse projeto utiliza a licença MIT, visite o arquivo [LICENSE](./LICENSE) para
mais informações.
