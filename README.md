# Sistema de Gestão de Unidades de Conservação (UC)

Este projeto foi desenvolvido no contexto da disciplina SCC0240 - Bases de Dados, ministrada pela Profª. Drª. Elaine Parros Machado de Sousa e acompanhada pelo monitor PAE Anderson Henrique Giacomini.

## Autoria

| Discente | NUSP |
| -- | -- |
| Henrique Vieira Lima | 15459372 |
| João Gabriel Pieroli da Silva | 15678578 |
| Luysa de Souza Gonçalves | 15474077 |
| Pedro Augusto Ferraro Paffaro | 15483380 |
| Pedro Lunkes Villela | 1548428 |


## Dependências
* **User Interface:** [Rust](https://rust-lang.org/pt-BR/tools/install/) (v1.96)
* **Linguagem Principal:** [Python](https://www.python.org/downloads/) (v3.11+)
* **Framework Web:** [FastAPI](https://fastapi.tiangolo.com/) (Desenvolvimento de APIs rápidas e assíncronas)
* **Driver de Banco de Dados:** [asyncpg](https://github.com/MagicStack/asyncpg) (Cliente PostgreSQL assíncrono de alta performance)
* **Validação de Dados:** [Pydantic](https://docs.pydantic.dev/) (Modelagem e tipagem de dados)
* **Banco de Dados:** [PostgreSQL](https://www.postgresql.org/) (v15)
* **Ambiente:** [Docker](https://www.docker.com/) & [Docker Compose](https://docs.docker.com/compose/) (Orquestração de contêineres)

## Estrutura 

```text
Trabalho-BD/
├── backend/
│   ├── src/
│   │   ├── routers/          # Definição das rotas/endpoints da API
|   │   │   └── unidades.py    # CRUD de unidades de conservação (GET/POST/PUT/DELETE)
│   │   ├── schemas.py        # Modelos Pydantic para validação de entrada/saída
│   │   ├── database.py       # Configuração e gerenciamento do pool de conexão com o banco
│   │   └── main.py           # Instancia o FastAPI e registra os routers
│   ├── .env.example          # Modelo de configuração das variáveis de ambiente
│   ├── Dockerfile            # Configuração da imagem Docker do backend
│   └── requirements.txt      # Dependências Python do projeto
├── SQL/
|   ├── consultas.sql         # Arquivo com as 5 consultas
|   ├── dados.sql             # Ingestão de dados
│   └── esquema.sql           # Script DDL com a criação das tabelas com suas respectivas constraints
├── interface/                # TUI em Rust (ratatui + reqwest) que consome a API
|   ├── src/
|   │   ├── main.rs           # Setup do terminal e loop de eventos
|   │   ├── app.rs            # Estado da aplicação e lógica de teclado
|   │   ├── api.rs            # Cliente HTTP da API e extração de mensagens de erro
|   │   └── ui.rs             # Renderização das telas (tabela, formulários, status)
|   └── Cargo.toml            # Dependências Rust do projeto
├── .dockerignore             # Arquivo para evitar o envio de lixo local para o Docker
├── docker-compose.yml        # Conecta os contêineres da aplicação
└── Makefile                  # Diretivas de comandos
```

## Como Inicializar o Projeto

### 1. Configurar as Variáveis de Ambiente

Antes de subir os serviços, cria um arquivo `.env` dentro do diretório `./backend` e insira as credenciais de acesso conforme o exemplo `.env.example`:

```env
DB_HOST=db
DB_PORT=5432
DB_NAME=trabalho_bd
DB_USER=pessoa
DB_PASSWORD=bdehdaora
```

### 2. Executar o Ambiente pela Primeira Vez

Para construir a imagem do backend e inicializar as tabelas automaticamente (caso necessário) por meio do `esquema.sql`, basta executar na raiz do projeto:

```bash
docker compose -p trabalho_bd --env-file ./backend/.env up -d --build
```

> É preferível utilizar o comando `make build` caso o `Makefile` esteja instalado.

Caso queira derrubar os containeres, utilize:

```bash
docker compose -p trabalho_bd down
```

> É preferível utilizar o comando `make down` caso o `Makefile` esteja instalado.

Você também pode reinicilizar a aplicação (quando fizer mudanças no código, por exemplo), a partir de:

```bash
docker compose -p trabalho_bd down
docker compose -p trabalho_bd --env-file ./backend/.env up -d --build
```

> É preferível utilizar o comando `make restart` caso o `Makefile` esteja instalado.

### 3. Validar a Inicialização e Logs

Para garantir que a base de dados aplicou o script de estrutura sem falhar e que a API iniciou com sucesso, é interessante verificar os logs:

```bash
# Acompanhar a inicialização do banco de dados e as operações realizadas
docker compose -p trabalho_bd logs -f db
```

> É preferível utilizar o comando `make logs-db`, que executa esse trecho mais facilmente.

```bash
# Acompanhar as requisições recebidas pela API
docker compose -p trabalho_bd logs -f backend
```

> É preferível utilizar o comando `make logs-backend`, que executa esse trecho mais facilmente.

### 4. Popular o Banco com Dados de Teste

Para inserir os dados de teste e popular o banco de dados execute o comando:

```bash
# Insere os registros nas tabelas do banco
docker compose -p trabalho_bd exec -T db sh -c 'psql -U pessoa -d trabalho_bd' < SQL/dados.sql
```

> É preferível utilizar o comando `make ingest`, que executa esse trecho mais facilmente.

### 5. Acessar o banco

Para acessar o banco, você pode dar o comando:

```bash
docker compose -p trabalho_bd exec db sh -c 'psql -U pessoa -d trabalho_bd'
```

> É preferível utilizar o comando `make psql`, que executa esse trecho mais facilmente. 

## Como Iniciar a Interface via Terminal

A TUI consome a API em `http://localhost:8000`, portanto **o backend precisa estar no ar** (passos anteriores) antes de abrir a interface.

Navegue até o diretório interno _/interface_ contido na raiz do projeto:

```bash
cd interface
```

Dentro dele, execute os dois comandos:
```bash
# baixa as dependências e compila o projeto
cargo build

# executa o projeto
cargo run
```

Para finalizar, utilize _Ctrl + C_ ou a tecla `q` na tela de listagem.

### Atalhos de Teclado

| Tela | Tecla | Ação |
|------|-------|------|
| Lista | `j` / `k` ou `↓` / `↑` | Navegar entre unidades |
| Lista | `n` | Nova unidade |
| Lista | `e` | Editar unidade selecionada |
| Lista | `d` | Excluir unidade selecionada |
| Lista | `/` | Abrir filtros de busca |
| Lista | `r` | Recarregar lista |
| Lista | `Esc` | Limpar filtros |
| Lista | `q` | Sair |
| Formulários | `Tab` / `Shift+Tab` | Navegar entre campos |
| Formulários | `Enter` | Confirmar (criar/salvar/buscar) |
| Formulários | `Esc` | Cancelar |

> Nos filtros, digite `null` em um campo para buscar unidades com aquele dado vazio.

## Exemplos de Uso e Testes

Com o backend no ar, é possível exercitar a API diretamente via `curl` (útil para testes rápidos sem a TUI):

```bash
# Criar uma unidade
curl -X POST http://localhost:8000/unidades \
  -H "Content-Type: application/json" \
  -d '{"cnuc":"000123456789","nome":"Parque Nacional do Iguaçu","data_criacao":"10-01-1939","uf":"PR","area_total":185262.20}'

# Listar todas as unidades
curl http://localhost:8000/unidades

# Listar com filtros (parcial no nome + bioma)
curl "http://localhost:8000/unidades?nome=Iguaçu&bioma=Mata"

# Buscar unidades sem bioma cadastrado
curl "http://localhost:8000/unidades?bioma=null"

# Atualizar uma unidade
curl -X PUT http://localhost:8000/unidades/000123456789 \
  -H "Content-Type: application/json" \
  -d '{"nome":"PARNA do Iguaçu","uf":"PR"}'

# Excluir uma unidade
curl -X DELETE http://localhost:8000/unidades/000123456789
```

Para validar os erros descritivos (ex: data ou CNUC inválidos), basta enviar valores fora do formato esperado:

```bash
# Data inválida → 422 com mensagem do campo data_criacao
curl -X POST http://localhost:8000/unidades \
  -H "Content-Type: application/json" \
  -d '{"cnuc":"000123456789","data_criacao":"32-13-2026"}'
```

## Como Usar a API

### Documentação Interativa (Swagger UI)

A API dispõe de uma interface gráfica nativa para a simulação de rotas e validações.

👉 **http://localhost:8000/docs**

Lá podes testar os endpoints clicando em **"Try it out"**, preenchendo os corpos das requisições e carregando em **"Execute"**.

---

### 2. Endpoints Principais — Módulo: Unidades de Conservação

#### A. Criar Nova Unidade

Submete uma nova UC para validação e armazenamento.

| Campo | Valor |
|-------|-------|
| **Método** | `POST` |
| **Rota** | `/unidades` |

**Campos do corpo (JSON):**

| Campo | Tipo | Obrigatório | Restrições |
|-------|------|:-----------:|-----------|
| `cnuc` | string | ✅ | Exatamente 12 dígitos numéricos |
| `nome` | string | — | Até 100 caracteres |
| `data_criacao` | string | — | `DD-MM-AAAA` (também aceita `AAAA-MM-DD`) |
| `bioma` | string | — | Até 30 caracteres |
| `rodovia` | string | — | Até 6 caracteres (ex: `BR 469`) |
| `km` | inteiro | — | Entre 0 e 9999 |
| `cidade` | string | — | Até 50 caracteres |
| `uf` | string | — | Sigla de estado brasileiro (2 letras) |
| `descricao_acesso` | string | — | Até 255 caracteres |
| `orgao_gestor` | string | — | Até 100 caracteres |
| `area_total` | número | — | `>= 0` (default `0.00`) |

**Exemplo de corpo da requisição:**

```json
{
  "cnuc": "000123456789",
  "nome": "Parque Nacional do Iguaçu",
  "data_criacao": "10-01-1939",
  "bioma": "Mata Atlântica",
  "rodovia": "BR 469",
  "km": 18,
  "cidade": "Foz do Iguaçu",
  "uf": "PR",
  "descricao_acesso": "Acesso pela marginal da rodovia",
  "orgao_gestor": "ICMBio",
  "area_total": 185262.20
}
```

**Retornos mapeados:**

| Código | Descrição |
|--------|-----------|
| `201 Created` | Sucesso. Retorna o JSON do registro inserido. |
| `409 Conflict` | O `cnuc` fornecido já existe no sistema. |
| `422 Unprocessable Entity` | Falha de validação (ex: CNUC fora do formato, data inválida, `km`/`area_total` fora do intervalo, UF inválida). |

---

#### B. Listar Unidades com Filtros Dinâmicos

Pesquisa por unidades de conservação com filtros parametrizados combinados pelo operador lógico `AND` — o registro deve atender a todos os critérios informados.

| Campo | Valor |
|-------|-------|
| **Método** | `GET` |
| **Rota** | `/unidades` |

**Parâmetros de busca (query string):**

| Parâmetro | Tipo | Correspondência | Formato |
|-----------|------|-----------------|---------|
| `cnuc` | string | exata | 12 dígitos |
| `nome` | string | parcial (`ILIKE`) | — |
| `bioma` | string | parcial (`ILIKE`) | — |
| `orgao_gestor` | string | parcial (`ILIKE`) | — |
| `data_criacao` | string | exata | `DD-MM-AAAA` (também aceita `AAAA-MM-DD`) |
| `rodovia` | string | parcial (`ILIKE`) | — |
| `cidade` | string | parcial (`ILIKE`) | — |
| `uf` | string | exata | 2 letras |
| `km` | inteiro | exata | 0 a 9999 |

> Todos os parâmetros são opcionais: sem nenhum filtro, retorna todas as unidades cadastradas. O valor literal `null` em qualquer parâmetro busca registros cuja coluna correspondente esteja vazia (`IS NULL`).

**Retornos mapeados:**

| Código | Descrição |
|--------|-----------|
| `200 OK` | Retorna a lista de unidades correspondentes aos critérios. |
| `400 Bad Request` | `data_criacao` ou `km` em formato inválido. |
| `404 Not Found` | Nenhum registro atende aos filtros aplicados. |

---

#### C. Atualizar Unidade

Atualiza todos os campos de uma unidade existente, identificada pelo `cnuc` na URL. O próprio `cnuc` também pode ser alterado: o `cnuc` da rota identifica o registro atual e o `cnuc` do corpo define o novo valor (a troca da PK é propagada via `ON UPDATE CASCADE`).

| Campo | Valor |
|-------|-------|
| **Método** | `PUT` |
| **Rota** | `/unidades/{cnuc}` |

O corpo segue o mesmo schema do `POST`.

**Retornos mapeados:**

| Código | Descrição |
|--------|-----------|
| `200 OK` | Sucesso. Retorna o JSON do registro atualizado. |
| `404 Not Found` | Não existe unidade com o `cnuc` informado. |
| `409 Conflict` | O novo `cnuc` já pertence a outra unidade. |
| `422 Unprocessable Entity` | Falha de validação dos campos enviados. |

---

#### D. Excluir Unidade

Remove a unidade identificada pelo `cnuc`.

| Campo | Valor |
|-------|-------|
| **Método** | `DELETE` |
| **Rota** | `/unidades/{cnuc}` |

**Retornos mapeados:**

| Código | Descrição |
|--------|-----------|
| `200 OK` | Sucesso. Retorna o JSON do registro excluído. |
| `404 Not Found` | Não existe unidade com o `cnuc` informado. |
| `422 Unprocessable Entity` | Existem registros vinculados em outras tabelas (violação de chave estrangeira). |
