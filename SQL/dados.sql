-- Tem que colocar a area_total como soma das áreas zonas 
-- Isso provavelmente em aplicação ou criar um trigger

-- Unidades de Conservação
INSERT INTO unidade_conservacao (cnuc, nome, data_criacao, bioma, endereco, orgao_gestor, area_total)
VALUES 
    ('000000000001', 'Parque Nacional do Iguaçu', '1939-01-10', 'Mata Atlântica', 'BR 469, Km 18, Foz do Iguaçu - PR', 'ICMBio', NULL);

INSERT INTO unidade_conservacao (cnuc, nome, data_criacao, bioma, endereco, orgao_gestor, area_total)
VALUES 
    ('000000000002', 'Parque Nacional da Chapada dos Veadeiros', '1961-01-11', 'Cerrado', 'Rodovia GO 239, Km 36, Alto Paraíso de Goiás - GO', 'ICMBio', NULL);

-- Zonas
INSERT INTO zona (unidade_conservacao, nro_zona, nome, tipo, area)
VALUES 
    ('000000000001', 1, 'Zona Intangível (Proteção Estrita)', 'PRESERVACAO', 150000.00);

INSERT INTO zona (unidade_conservacao, nro_zona, nome, tipo, area)
VALUES 
    ('000000000001', 2, 'Zona de Uso Público (Turismo)', 'USO SUSTENTAVEL', 35262.50);

INSERT INTO zona (unidade_conservacao, nro_zona, nome, tipo, area)
VALUES 
    ('000000000002', 1, 'Zona de Conservação Extrema', 'PRESERVACAO', 200000.00);

INSERT INTO zona (unidade_conservacao, nro_zona, nome, tipo, area)
VALUES 
    ('000000000002', 2, 'Zona de Recuperação e Visitação', 'USO SUSTENTAVEL', 40611.00);

-- Comunidade Tradicional (só inserções corretas em zonas do tipo 'USO SUSTENTAVEL')
INSERT INTO comunidade_tradicional (unidade_conservacao, nro_zona, nome, tamanho, tipo_comunidade)
VALUES 
    ('000000000001', 2, 'Aldeia Guarani Tekoha', 120, 'POVOS INDÍGENAS');

INSERT INTO comunidade_tradicional (unidade_conservacao, nro_zona, nome, tamanho, tipo_comunidade)
VALUES 
    ('000000000002', 2, 'Comunidade Quilombola Kalunga', 350, 'QUILOMBOLAS');

-- Costumes das Comunidades Tradicionais
INSERT INTO comunidade_costume (unidade_conservacao, nro_zona, nome_comunidade, costume)
VALUES 
    ('000000000001', 2, 'Aldeia Guarani Tekoha', 'Produção de artesanato tradicional com fibras naturais e sementes');

INSERT INTO comunidade_costume (unidade_conservacao, nro_zona, nome_comunidade, costume)
VALUES 
    ('000000000002', 2, 'Comunidade Quilombola Kalunga', 'Cultivo agrícola baseado no sistema tradicional de roça de toco');

-- Funcionários
INSERT INTO funcionario (nro_funcional, cpf, nome, data_contratacao, telefone, email, salario, unidade_conservacao)
VALUES 
    (1001, '12345678901', 'Carlos da Silva', '2020-05-15', '45987654321', 'carlos.silva@icmbio.gov.br', 4500.00, '000000000001');

INSERT INTO funcionario (nro_funcional, cpf, nome, data_contratacao, telefone, email, salario, unidade_conservacao)
VALUES    
    (1002, '45612378900', 'João Mendes', '2021-11-20', '45912345678', 'joao.mendes@icmbio.gov.br', 3800.00, '000000000001');

INSERT INTO funcionario (nro_funcional, cpf, nome, data_contratacao, telefone, email, salario, unidade_conservacao)
VALUES 
    (1003, '11122233344', 'Mariana Costa', '2022-03-01', '45988887777', 'mariana.costa@icmbio.gov.br', 4100.00, '000000000001');

INSERT INTO funcionario (nro_funcional, cpf, nome, data_contratacao, telefone, email, salario, unidade_conservacao)
VALUES    
    (2001, '98765432109', 'Ana Batista', '2019-02-10', '61999887766', 'ana.batista@icmbio.gov.br', 5200.50, '000000000002');

INSERT INTO funcionario (nro_funcional, cpf, nome, data_contratacao, telefone, email, salario, unidade_conservacao)
VALUES 
    (2002, '55566677788', 'Roberto Almeida', '2018-08-12', '61977776666', 'roberto.almeida@icmbio.gov.br', 6300.00, '000000000002');

-- Categorias de Funcionário
INSERT INTO funcionario_categoria (funcionario, categoria)
VALUES 
    (1001, 'FISCAL'),
    (1001, 'GESTOR');
    
INSERT INTO funcionario_categoria (funcionario, categoria)
VALUES
    (1002, 'GUIA');

INSERT INTO funcionario_categoria (funcionario, categoria)
VALUES
    (1003, 'BIOLOGO'),
    (1003, 'FISCAL'),
    (1003, 'BRIGADISTA');

INSERT INTO funcionario_categoria (funcionario, categoria)
VALUES 
    (2001, 'BIOLOGO'),
    (2001, 'PESQUISADOR');
    
INSERT INTO funcionario_categoria (funcionario, categoria)
VALUES 
    (2002, 'GUIA'),
    (2002, 'PESQUISADOR');

-- Visitantes
INSERT INTO visitante (cpf, nome, telefone, email)
VALUES 
    ('22233344455', 'Fernanda Lima', '11988887777', 'fernanda.lima@email.com');

INSERT INTO visitante (cpf, nome, telefone, email)
VALUES 
    ('66677788899', 'Rafael Souza', '21977776666', 'rafael.souza@email.com');

INSERT INTO visitante (cpf, nome, telefone, email)
VALUES 
    ('10120230344', 'Camila Barros', '31955554444', 'camila.barros@email.com');


INSERT INTO visitante (cpf, nome, telefone, email)
VALUES
    ('90980870766', 'Diego Martins', '41944443333', 'diego.martins@email.com');
    
INSERT INTO visitante (cpf, nome, telefone, email)
VALUES
    ('50540430322', 'Juliana Peixoto', '81933332222', 'juliana.peixoto@email.com');

-- Visitas
-- Visitas para o Parque Nacional do Iguaçu (UC: '000000000001')
INSERT INTO visita (unidade_conservacao, nro_zona, nro_visita, data_hora, tipo, nro_visitantes, guia)
VALUES
    ('000000000001', 2, 101, '2026-06-15 09:00:00', 'TURISTICA', 0, 1002);

INSERT INTO visita (unidade_conservacao, nro_zona, nro_visita, data_hora, tipo, nro_visitantes, guia)
VALUES
    ('000000000001', 2, 102, '2026-06-15 14:00:00', 'EDUCATIVA', 0, 1002);

INSERT INTO visita (unidade_conservacao, nro_zona, nro_visita, data_hora, tipo, nro_visitantes, guia)
VALUES
    ('000000000001', 2, 103, '2026-06-16 08:30:00', 'CIENTIFICA', 0, NULL);

-- Visitas para a Chapada dos Veadeiros (UC: '000000000002')
INSERT INTO visita (unidade_conservacao, nro_zona, nro_visita, data_hora, tipo, nro_visitantes, guia)
VALUES 
    ('000000000002', 2, 201, '2026-06-20 10:00:00', 'TURISTICA', 0, 2002);

INSERT INTO visita (unidade_conservacao, nro_zona, nro_visita, data_hora, tipo, nro_visitantes, guia)
VALUES
    ('000000000002', 2, 202, '2026-06-21 09:00:00', 'EDUCATIVA', 0, NULL);

INSERT INTO visita (unidade_conservacao, nro_zona, nro_visita, data_hora, tipo, nro_visitantes, guia)
VALUES
    ('000000000002', 2, 203, '2026-06-22 13:00:00', 'CIENTIFICA', 0, 2002);

-- Visitas e Visitantes
-- Agendando a Visita 1 (Parque do Iguaçu - Turística) como um GRUPO de 3 pessoas
INSERT INTO visita_visitante (visita, visitante) 
VALUES
    (1, '22233344455'); -- Fernanda

INSERT INTO visita_visitante (visita, visitante) 
VALUES 
    (1, '66677788899'); -- Rafael

INSERT INTO visita_visitante (visita, visitante) 
VALUES 
    (1, '10120230344'); -- Camila

-- Agendando a Visita 2 (Parque do Iguaçu - Educativa) para 1 pessoa individual
INSERT INTO visita_visitante (visita, visitante) 
VALUES 
    (2, '90980870766'); -- Diego

-- Agendando a Visita 4 (Chapada dos Veadeiros - Turística) para 1 pessoa individual
INSERT INTO visita_visitante (visita, visitante) 
VALUES 
    (4, '50540430322'); -- Juliana

-- Agendando a Visita 5 (Chapada dos Veadeiros - Educativa) para 1 pessoa individual
INSERT INTO visita_visitante (visita, visitante) 
VALUES 
    (5, '22233344455'); -- Fernanda (viajando para outra UC)

-- Espécies
INSERT INTO especie (nome_cientifico, nome_popular, familia, reino, ordem, classe, filo, status_conservacao, descricao)
VALUES 
    ('Panthera onca', 'Onça-pintada', 'Felidae', 'ANIMALIA', 'Carnivora', 'Mammalia', 'Chordata', 'VU', 
     'Maior felino das Américas, com pelagem amarelada e rosetas pretas. Fundamental para o equilíbrio do ecossistema.');

INSERT INTO especie (nome_cientifico, nome_popular, familia, reino, ordem, classe, filo, status_conservacao, descricao)
VALUES 
    ('Anodorhynchus hyacinthinus', 'Arara-azul', 'Psittacidae', 'ANIMALIA', 'Psittaciformes', 'Aves', 'Chordata', 'NT', 
     'Grande ave de plumagem azul-cobalto com detalhes amarelos ao redor dos olhos e mandíbula.');

INSERT INTO especie (nome_cientifico, nome_popular, familia, reino, ordem, classe, filo, status_conservacao, descricao)
VALUES
    ('Handroanthus albus', 'Ipê-amarelo', 'Bignoniaceae', 'PLANTAE', 'Lamiales', 'Magnoliopsida', 'Tracheophyta', 'LC', 
     'Árvore nativa do Brasil conhecida por sua florada amarela espetacular durante o inverno e primavera.');

INSERT INTO especie (nome_cientifico, nome_popular, familia, reino, ordem, classe, filo, status_conservacao, descricao)
VALUES
    ('Tapirus terrestris', 'Anta', 'Tapiridae', 'ANIMALIA', 'Perissodactyla', 'Mammalia', 'Chordata', 'VU', 
     'Maior mamífero terrestre da América do Sul, conhecida como a jardineira das florestas devido ao seu papel dispersor de sementes.');

INSERT INTO especie (nome_cientifico, nome_popular, familia, reino, ordem, classe, filo, status_conservacao, descricao)
VALUES
    ('Agaricus blazei', 'Cogumelo-do-sol', 'Agaricaceae', 'FUNGI', 'Agaricales', 'Agaricomycetes', 'Basidiomycota', 'DD', 
     'Cogumelo nativo do Brasil, amplamente estudado por suas propriedades medicinais e imunoestimulantes.');

-- Espécies em Unidades de Conservação 
-- Espécies registradas no Parque Nacional do Iguaçu
INSERT INTO unidade_conservacao_especie (unidade_conservacao, especie)
VALUES 
    ('000000000001', 'Panthera onca');          

INSERT INTO unidade_conservacao_especie (unidade_conservacao, especie)
VALUES 
    ('000000000001', 'Tapirus terrestris');

INSERT INTO unidade_conservacao_especie (unidade_conservacao, especie)
VALUES
    ('000000000001', 'Handroanthus albus');    

-- Espécies registradas no Parque Nacional da Chapada dos Veadeiros
INSERT INTO unidade_conservacao_especie (unidade_conservacao, especie)
VALUES 
    ('000000000002', 'Panthera onca');

INSERT INTO unidade_conservacao_especie (unidade_conservacao, especie)
VALUES 
    ('000000000002', 'Anodorhynchus hyacinthinus');

INSERT INTO unidade_conservacao_especie (unidade_conservacao, especie)
VALUES 
    ('000000000002', 'Tapirus terrestris');

INSERT INTO unidade_conservacao_especie (unidade_conservacao, especie)
VALUES  
    ('000000000002', 'Agaricus blazei');

-- Pesquisas
INSERT INTO pesquisa (titulo, data_inicio, data_termino, objetivo, inst_responsavel)
VALUES 
    ('Monitoramento Populacional de Grandes Felinos', '2021-01-10', '2025-12-20', 
     'Avaliar a densidade populacional e a saúde genética das onças-pintadas na Mata Atlântica.', 
     'Instituto Chico Mendes de Conservação da Biodiversidade (ICMBio)');

INSERT INTO pesquisa (titulo, data_inicio, data_termino, objetivo, inst_responsavel)
VALUES 
    ('Impacto do Turismo na Avifauna Local', '2024-03-15', NULL, 
     'Analisar se o fluxo de visitantes nas trilhas altera o comportamento de nidificação de aves nativas.', 
     'Universidade Federal do Paraná (UFPR)');

INSERT INTO pesquisa (titulo, data_termino, objetivo, inst_responsavel)
VALUES 
    ('Mapeamento de Fungos Medicinais do Cerrado', '2028-06-01', 
     'Identificar novas propriedades bioativas no Agaricus blazei e outros fungos locais.', 
     'Universidade de São Paulo (USP)');

INSERT INTO pesquisa (titulo, data_inicio, data_termino, objetivo, inst_responsavel)
VALUES 
    ('Inventário Rápido da Flora Arbórea - Primavera 2025', '2025-10-10', '2025-10-10', 
     'Catalogar a floração simultânea de ipês-amarelos durante um evento específico.', 
     'Instituto Botânico de São Paulo');

-- Área Temática das Pesquisas
-- Áreas temáticas para a pesquisa de Grandes Felinos
INSERT INTO pesquisa_area_tematica (pesquisa, area_tematica)
VALUES 
    ('Monitoramento Populacional de Grandes Felinos', 'Zoologia');

INSERT INTO pesquisa_area_tematica (pesquisa, area_tematica)
VALUES 
    ('Monitoramento Populacional de Grandes Felinos', 'Genética de Populações');

INSERT INTO pesquisa_area_tematica (pesquisa, area_tematica)
VALUES 
    ('Impacto do Turismo na Avifauna Local', 'Ecologia');

INSERT INTO pesquisa_area_tematica (pesquisa, area_tematica)
VALUES 
    ('Impacto do Turismo na Avifauna Local', 'Uso Público');

INSERT INTO pesquisa_area_tematica (pesquisa, area_tematica)
VALUES 
    ('Mapeamento de Fungos Medicinais do Cerrado', 'Micologia');

INSERT INTO pesquisa_area_tematica (pesquisa, area_tematica)
VALUES 
    ('Inventário Rápido da Flora Arbórea - Primavera 2025', 'Botânica');

-- Pesquisador-Pesquisa
INSERT INTO pesquisa_pesquisador (pesquisa, pesquisador)
VALUES 
    ('Monitoramento Populacional de Grandes Felinos', 2001);

INSERT INTO pesquisa_pesquisador (pesquisa, pesquisador)
VALUES  
    ('Monitoramento Populacional de Grandes Felinos', 2002);

INSERT INTO pesquisa_pesquisador (pesquisa, pesquisador)
VALUES 
    ('Impacto do Turismo na Avifauna Local', 2001);

INSERT INTO pesquisa_pesquisador (pesquisa, pesquisador)
VALUES 
    ('Mapeamento de Fungos Medicinais do Cerrado', 2002);

-- Pesquisa-Espécie
INSERT INTO pesquisa_especie (pesquisa, especie)
VALUES 
    ('Monitoramento Populacional de Grandes Felinos', 'Panthera onca');

INSERT INTO pesquisa_especie (pesquisa, especie)
VALUES 
    ('Mapeamento de Fungos Medicinais do Cerrado', 'Agaricus blazei');

-- Pesquisa-Comunidade Tradicional
INSERT INTO pesquisa_comunidade_tradicional (unidade_conservacao, nro_zona, nome_comunidade, pesquisa)
VALUES 
    ('000000000002', 2, 'Comunidade Quilombola Kalunga', 'Mapeamento de Fungos Medicinais do Cerrado');

INSERT INTO pesquisa_comunidade_tradicional (unidade_conservacao, nro_zona, nome_comunidade, pesquisa)
VALUES 
    ('000000000002', 2, 'Comunidade Quilombola Kalunga', 'Monitoramento Populacional de Grandes Felinos');

-- Ser-Vivo
INSERT INTO ser_vivo (chip, apelido, situacao, especie)
VALUES 
    (10001, 'Trovão', 'VIVO', 'Panthera onca');

INSERT INTO ser_vivo (chip, apelido, situacao, especie)
VALUES 
    (10002, 'Juma', 'VIVO', 'Panthera onca');

INSERT INTO ser_vivo (chip, apelido, situacao, especie)
VALUES 
    (20001, 'Amiga', 'EM REABILITACAO', 'Tapirus terrestris');

INSERT INTO ser_vivo (chip, apelido, situacao, especie)
VALUES 
    (30001, 'Blue', 'DESAPARECIDO', 'Anodorhynchus hyacinthinus');

INSERT INTO ser_vivo (chip, apelido, especie)
VALUES 
    (10003, 'Gatão', 'Panthera onca');

INSERT INTO ser_vivo (chip, apelido, situacao, especie)
VALUES 
    (30002, 'Rachel', 'VIVO', 'Anodorhynchus hyacinthinus');

INSERT INTO ser_vivo (chip, apelido, situacao, especie)
VALUES 
    (20002, 'Valente', 'LIBERADO', 'Tapirus terrestris');

INSERT INTO ser_vivo (chip, apelido, situacao, especie)
VALUES 
    (10004, 'Sombra', 'CAPTURADO', 'Panthera onca');

INSERT INTO ser_vivo (chip, apelido, situacao, especie)
VALUES 
    (10005, 'Velho', 'MORTO', 'Panthera onca');

INSERT INTO ser_vivo (chip, apelido, especie)
VALUES 
    (30003, 'Sky', 'Anodorhynchus hyacinthinus');

-- Observações
INSERT INTO observacao (biologo, ser_vivo, data_hora, metodo, descricao, unidade_conservacao, nro_zona)
VALUES 
    (1003, 10001, '2026-06-10 23:15:00', 'CAMERA', 
     'Registro noturno através de armadilha fotográfica. Animal apresenta excelente score corporal e comportamento territorial ativo.', 
     '000000000001', 2);

INSERT INTO observacao (biologo, ser_vivo, data_hora, metodo, descricao, unidade_conservacao, nro_zona)
VALUES 
    (1003, 10001, '2026-06-12 08:30:00', 'SINAIS BIOLOGICOS', 
     'Identificadas pegadas frescas do espécime próximas ao corpo d''água. Moldagem em gesso realizada para arquivo.', 
     '000000000001', 2);

INSERT INTO observacao (biologo, ser_vivo, data_hora, metodo, descricao, unidade_conservacao, nro_zona)
VALUES 
    (2001, 30002, '2026-06-15 07:45:00', 'BINOCULO', 
     'Avistamento do indivíduo em atividade de forrageamento no topo de uma palmeira (indaiá). Foram identificados outros 2 indivíduos não chipados na mesma copa.', 
     '000000000002', 2);

INSERT INTO observacao (biologo, ser_vivo, data_hora, metodo, descricao, unidade_conservacao, nro_zona)
VALUES 
    (2001, 10002, '2026-06-16 16:20:00', 'VISUAL', 
     'Avistamento direto durante patrulha preventiva. O animal cruzou a estrada de serviço e adentrou a mata densa sem demonstrar sinais de estresse.', 
     '000000000002', 2);

-- Ocorrências
INSERT INTO ocorrencia (unidade_conservacao, nro_zona, data_horario, fiscal, tipo_ocorrencia, nivel_gravidade, area_afetada, descricao)
VALUES 
    ('000000000001', 2, '2026-06-15 10:00:00', 1001, 'INCENDIO CRIMINOSO', 'ALTISSIMO', 15.50, 
     'Foco de incêndio detectado em área de vegetação nativa próximo à borda da zona de uso público.');

INSERT INTO ocorrencia (unidade_conservacao, nro_zona, data_horario, fiscal, tipo_ocorrencia, nivel_gravidade, area_afetada, descricao)
VALUES 
    ('000000000001', 2, '2026-06-16 14:30:00', 1003, 'DESMATAMENTO', 'ALTO', 2.00, 
     'Supressão ilegal de vegetação para abertura de trilha não autorizada.');

INSERT INTO ocorrencia (unidade_conservacao, nro_zona, data_horario, fiscal, tipo_ocorrencia, nivel_gravidade, area_afetada, descricao)
VALUES 
    ('000000000001', 2, '2026-06-17 09:15:00', 1001, 'INVASAO DE ZONA', 'BAIXO', 0.00, 
     'Turistas identificados fora da trilha demarcada na Zona 2.');

INSERT INTO ocorrencia (unidade_conservacao, nro_zona, data_horario, fiscal, tipo_ocorrencia, nivel_gravidade, area_afetada, descricao)
VALUES 
    ('000000000001', 2, '2026-06-17 17:45:00', 1003, 'CACA', 'MEDIO', 0.00, 
     'Apreensão de armadilhas de caça tipo alçapão montadas na mata.');