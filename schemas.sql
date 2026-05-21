CREATE TABLE unidade_conservacao (
    cnuc char(12) NOT NULL,
    nome varchar(100),
    data_criacao date,
    bioma varchar(30),
    endereco varchar(255),
    orgao_gestor varchar(100),
    area_total numeric(10, 2), -- Talvez fazer um criar um trigger para fazer o calculo automático

    CONSTRAINT pk_unidade_conservacao 
        PRIMARY KEY (cnuc)
);

CREATE TABLE zona (
    unidade_conservacao char(12) NOT NULL,
    nro_zona smallint NOT NULL,
    nome varchar(100),
    tipo varchar(15),
    area numeric(10, 2),

    CONSTRAINT pk_zona 
        PRIMARY KEY (unidade_conservacao, nro_zona),

    CONSTRAINT fk_zona_unidade_conservacao 
        FOREIGN KEY (unidade_conservacao) REFERENCES unidade_conservacao (cnuc)
        ON DELETE CASCADE,

    CONSTRAINT ck_zona_tipo 
        CHECK (UPPER(tipo) IN ('PRESERVACAO','USO SUSTENTAVEL'))
);

CREATE TABLE funcionario (
    nro_funcional smallint NOT NULL,
    cpf char(11) NOT NULL,
    nome varchar(50),
    data_contratacao date,
    telefone char(11),
    email varchar(100),
    salario numeric(8, 2),
    unidade_conservacao char(12) NOT NULL,

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
    funcionario smallint NOT NULL,
    categoria varchar(30) NOT NULL,

    CONSTRAINT pk_funcionario_categoria
        PRIMARY KEY (funcionario, categoria),

    CONSTRAINT fk_funcionario_categoria_funcionario
        FOREIGN KEY (funcionario) REFERENCES funcionario (nro_funcional)
        ON DELETE CASCADE
);

CREATE TABLE especie (
    nome_cientifico varchar(255) NOT NULL,
    nome_popular varchar(255),
    familia varchar(100),
    reino varchar(100),
    ordem varchar(100),
    classe varchar(100),
    filo varchar(100),
    status_conservacao char(2), 
    descricao text,

    CONSTRAINT pk_especie
        PRIMARY KEY (nome_cientifico),
    
    CONSTRAINT ck_especie_status_conservacao
        CHECK (UPPER(status_conservacao) IN ('DD', 'LC', 'NT', 'VU', 'EN', 'CR', 'EW', 'EX', 'NE')) -- Valores baseados na lista da IUCN
);