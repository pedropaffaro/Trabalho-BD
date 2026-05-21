CREATE TABLE unidade_conservacao (
    cnuc            char(12) NOT NULL,
    nome            varchar(100),
    data_criacao    date,
    bioma           varchar(30),
    endereco        varchar(255),
    orgao_gestor    varchar(100),
    area_total      numeric(10, 2), -- Talvez criar um trigger para fazer o calculo automático

    CONSTRAINT pk_unidade_conservacao 
        PRIMARY KEY (cnuc)
);

CREATE TABLE zona (
    unidade_conservacao char(12) NOT NULL,
    nro_zona            smallint NOT NULL,
    nome                varchar(100),
    tipo                varchar(15),
    area                numeric(10, 2),

    CONSTRAINT pk_zona 
        PRIMARY KEY (unidade_conservacao, nro_zona),

    CONSTRAINT fk_zona_unidade_conservacao 
        FOREIGN KEY (unidade_conservacao) REFERENCES unidade_conservacao (cnuc)
        ON DELETE CASCADE,

    CONSTRAINT ck_zona_tipo 
        CHECK (UPPER(tipo) IN ('PRESERVACAO','USO SUSTENTAVEL'))
);

CREATE TABLE funcionario (
    nro_funcional       smallint        NOT NULL,
    cpf                 char(11)        NOT NULL,
    nome                varchar(50),
    data_contratacao    date,
    telefone            char(11),
    email               varchar(100),
    salario             numeric(8, 2),
    unidade_conservacao char(12)        NOT NULL,

    CONSTRAINT pk_funcionario
        PRIMARY KEY (nro_funcional),

    CONSTRAINT uc_funcionario
        UNIQUE (cpf),

    CONSTRAINT fk_funcionario_unidade_conservacao
        FOREIGN KEY (unidade_conservacao) REFERENCES unidade_conservacao (cnuc)
        ON DELETE RESTRICT, -- Impede que a unidade seja apagada se houver funcionários

    CONSTRAINT ck_funcionario_salario
        CHECK (salario > 0)
);

CREATE TABLE funcionario_categoria (
    funcionario smallint    NOT NULL,
    categoria   varchar(30) NOT NULL,

    CONSTRAINT pk_funcionario_categoria
        PRIMARY KEY (funcionario, categoria),

    CONSTRAINT fk_funcionario_categoria_funcionario
        FOREIGN KEY (funcionario) REFERENCES funcionario (nro_funcional)
        ON DELETE CASCADE
);

CREATE TABLE especie (
    nome_cientifico     varchar(255) NOT NULL,
    nome_popular        varchar(255),
    familia             varchar(100),
    reino               varchar(100),
    ordem               varchar(100),
    classe              varchar(100),
    filo                varchar(100),
    status_conservacao  char(2), 
    descricao           text,

    CONSTRAINT pk_especie
        PRIMARY KEY (nome_cientifico),
    
    CONSTRAINT ck_especie_status_conservacao
        CHECK (UPPER(status_conservacao) IN ('DD', 'LC', 'NT', 'VU', 'EN', 'CR', 'EW', 'EX', 'NE')) -- Valores baseados na lista da IUCN
);

CREATE TABLE unidade_conservacao_especie (
    unidade_conservacao char(12)        NOT NULL,
    especie             varchar(255)    NOT NULL,

    CONSTRAINT pk_unidade_conservacao_especie
        PRIMARY KEY (unidade_conservacao, especie),

    CONSTRAINT fk_unidade_conservacao_especie_unidade_conservacao
        FOREIGN KEY (unidade_conservacao) REFERENCES unidade_conservacao (cnuc)
        ON DELETE CASCADE,

    CONSTRAINT fk_unidade_conservacao_especie_especie
        FOREIGN KEY (especie) REFERENCES especie (nome_cientifico)
        ON DELETE CASCADE
        ON UPDATE CASCADE -- Como o nome científico pode ser atualizado, é válido colocar o ON UPDATE CASCADE aqui
);

CREATE TABLE pesquisa (
    titulo              varchar(255) NOT NULL,
    data_inicio         date,
    data_termino        date,
    objetivo            text,
    inst_responsavel    varchar(255),

    CONSTRAINT pk_pesquisa
        PRIMARY KEY (titulo),

    CONSTRAINT ck_pesquisa_data
        CHECK (data_termino >= data_inicio)
);

CREATE TABLE pesquisa_area_tematica (
    pesquisa        varchar(255) NOT NULL,
    area_tematica   varchar(255) NOT NULL,

    CONSTRAINT pk_pesquisa_area_tematica
        PRIMARY KEY (pesquisa, area_tematica),
    
    CONSTRAINT fk_pesquisa_area_tematica_pesquisa
        FOREIGN KEY (pesquisa) REFERENCES pesquisa (titulo)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE pesquisa_pesquisador (
    pesquisa    varchar(255)    NOT NULL,
    pesquisador smallint        NOT NULL,

    CONSTRAINT pk_pesquisa_pesquisador
        PRIMARY KEY (pesquisa, pesquisador),

    CONSTRAINT fk_pesquisa_pesquisador_pesquisa
        FOREIGN KEY (pesquisa) REFERENCES pesquisa (titulo)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_pesquisa_pesquisador_pesquisador
        FOREIGN KEY (pesquisador) REFERENCES funcionario (nro_funcional)
        ON DELETE RESTRICT 

    -- Talvez fazer um trigger para verificar que o funcionário é do tipo 'PESQUISADOR'
);

CREATE TABLE pesquisa_especie (
    pesquisa    varchar(255) NOT NULL,
    especie     varchar(255) NOT NULL,

    CONSTRAINT pk_pesquisa_especie
        PRIMARY KEY (pesquisa, especie),

    CONSTRAINT fk_pesquisa_especie_pesquisa
        FOREIGN KEY (pesquisa) REFERENCES pesquisa (titulo)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_pesquisa_especie_especie
        FOREIGN KEY (especie) REFERENCES especie (nome_cientifico)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE ser_vivo (
    chip        integer         NOT NULL,
    apelido     varchar(100),
    situacao    varchar(20),
    especie     varchar(255)    NOT NULL,

    CONSTRAINT pk_ser_vivo 
        PRIMARY KEY (chip),
    
    CONSTRAINT fk_ser_vivo_especie 
        FOREIGN KEY (especie) REFERENCES especie (nome_cientifico)
        ON DELETE RESTRICT -- Bloqueia a remoção de uma espécie se existir um ser vivo associado a espécie
        ON UPDATE CASCADE -- Como o nome científico pode ser atualizado, é válido colocar o ON UPDATE CASCADE aqui
);

CREATE TABLE observacao (
    biologo             smallint        NOT NULL,
    ser_vivo            integer         NOT NULL,
    data_hora           timestamp       NOT NULL,
    metodo              varchar(255),
    descricao           text,
    unidade_conservacao char(12)        NOT NULL,
    nro_zona            smallint        NOT NULL,

    CONSTRAINT pk_observacao
        PRIMARY KEY (biologo, ser_vivo, data_hora),

    CONSTRAINT fk_observacao_biologo
        FOREIGN KEY (biologo) REFERENCES funcionario (nro_funcional)
        ON DELETE RESTRICT,
    
    CONSTRAINT fk_observacao_ser_vivo
        FOREIGN KEY (ser_vivo) REFERENCES ser_vivo (chip)
        ON DELETE CASCADE,

    CONSTRAINT fk_observacao_zona
        FOREIGN KEY (unidade_conservacao, nro_zona) REFERENCES zona (unidade_conservacao, nro_zona)
        ON DELETE CASCADE

    -- Talvez fazer um trigger para verificar que o funcionário é do tipo 'BIOLOGO'
);