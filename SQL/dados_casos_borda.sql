-- =====================================================================
-- dados_casos_borda.sql
-- Inserções adicionais cobrindo casos de borda das consultas.
-- Execute APÓS dados.sql.
-- =====================================================================


-- ====================================================================
-- QUERY 1: Biólogos com espécies ameaçadas (CR/EN/VU) observadas por
--          câmera, cujas espécies são estudadas por pesquisa com >= 2
--          pesquisadores.
-- ====================================================================

-- Associa Tapirus terrestris (VU) à pesquisa que já tem 2 pesquisadores
-- (2001, 2002). Isso faz as observações via CÂMERA dessa espécie contarem.
INSERT INTO pesquisa_especie (pesquisa, especie) VALUES
('Monitoramento Populacional de Grandes Felinos', 'Tapirus terrestris');

-- Pesquisa com APENAS 1 pesquisador estudando Myrmecophaga tridactyla (VU).
-- Garante que a observação via CÂMERA do chip 50007 (biólogo 2001)
-- NÃO apareça nos resultados da Query 1.
INSERT INTO pesquisa (titulo, data_inicio, objetivo, inst_responsavel)
VALUES ('Etologia do Tamanduá-Bandeira', '2025-06-01',
        'Estudo comportamental em cativeiro e campo.', 'UnB');

INSERT INTO pesquisa_area_tematica (pesquisa, area_tematica) VALUES
('Etologia do Tamanduá-Bandeira', 'Etologia'),
('Etologia do Tamanduá-Bandeira', 'Mamíferos');

INSERT INTO pesquisa_pesquisador (pesquisa, pesquisador) VALUES
('Etologia do Tamanduá-Bandeira', 3002);

INSERT INTO pesquisa_especie (pesquisa, especie) VALUES
('Etologia do Tamanduá-Bandeira', 'Myrmecophaga tridactyla');

-- Caso de borda: método VISUAL em espécie ameaçada (Tapirus terrestris, VU).
-- Biólogo 3002 NÃO aparece na Query 1 — filtro de método falha.
INSERT INTO observacao (biologo, ser_vivo, data_hora, metodo, descricao, unidade_conservacao, nro_zona)
VALUES (3002, 11002, '2026-05-10 10:00:00', 'VISUAL',
        'Anta observada durante patrulha na zona de preservação.', '000000000003', 1);


-- ====================================================================
-- QUERY 3: Biólogos que NUNCA fizeram observação por câmera à noite.
--          Noite = EXTRACT(HOUR) >= 18 OU <= 5.
-- ====================================================================

-- Observação via CÂMERA exatamente às 18:00 (limite inclusivo do início da noite).
-- Biólogo 5002 NÃO deve aparecer na Query 3.
-- Stenocraniops pampa (EN) só está em pesquisa com 1 pesquisador →
-- 5002 também NÃO aparece na Query 1 (duplo caso de borda).
INSERT INTO observacao (biologo, ser_vivo, data_hora, metodo, descricao, unidade_conservacao, nro_zona)
VALUES (5002, 90001, '2026-06-15 18:00:00', 'CAMERA',
        'Registro de gafanhoto-do-pampa no início da noite.', '000000000011', 2);

-- Observação via CÂMERA exatamente às 05:00 (limite inclusivo da madrugada).
-- Biólogo 7002 NÃO deve aparecer na Query 3.
INSERT INTO observacao (biologo, ser_vivo, data_hora, metodo, descricao, unidade_conservacao, nro_zona)
VALUES (7002, 30001, '2026-06-14 05:00:00', 'CAMERA',
        'Registro de arara no limite do amanhecer.', '000000000008', 2);

-- Observação via CÂMERA às 17:59 (último minuto antes da noite).
-- Biólogo 4002 DEVE aparecer na Query 3 — horário diurno.
INSERT INTO observacao (biologo, ser_vivo, data_hora, metodo, descricao, unidade_conservacao, nro_zona)
VALUES (4002, 20001, '2026-06-15 17:59:00', 'CAMERA',
        'Registro de anta ao entardecer, momentos antes do horário noturno.', '000000000004', 1);


-- ====================================================================
-- QUERY 5: Visitas educativas com guia que é biólogo OU pesquisador
--          cadastrado em pesquisa_pesquisador.
-- ====================================================================

-- Visita EDUCATIVA com guia 1003 (BIÓLOGO).
-- DEVE aparecer na Query 5 — satisfaz o ramo BIOLOGO.
INSERT INTO visita (unidade_conservacao, nro_zona, nro_visita, data_hora, tipo, nro_visitantes, guia)
VALUES ('000000000001', 2, 104, '2026-06-18 10:00:00', 'EDUCATIVA', 2, 1003);

-- Visita TURÍSTICA com o mesmo guia biólogo (1003).
-- NÃO deve aparecer — filtro de tipo falha (tipo != 'EDUCATIVA').
INSERT INTO visita (unidade_conservacao, nro_zona, nro_visita, data_hora, tipo, nro_visitantes, guia)
VALUES ('000000000001', 2, 105, '2026-06-19 09:00:00', 'TURISTICA', 4, 1003);

-- Visita EDUCATIVA com guia 2002 (GUIA + PESQUISADOR + FISCAL),
-- que NÃO é BIÓLOGO mas está em pesquisa_pesquisador.
-- DEVE aparecer — satisfaz o ramo pesquisa_pesquisador.
INSERT INTO visita (unidade_conservacao, nro_zona, nro_visita, data_hora, tipo, nro_visitantes, guia)
VALUES ('000000000002', 2, 204, '2026-06-22 09:00:00', 'EDUCATIVA', 3, 2002);


-- ====================================================================
-- QUERY 7: Pesquisas que estudam TODAS as espécies CR.
--          Espécies CR: Trichechus manatus, Araucaria angustifolia.
-- ====================================================================

-- Pesquisa com 2 pesquisadores que cobre as DUAS espécies CR.
-- DEVE aparecer na Query 7.
INSERT INTO pesquisa (titulo, data_inicio, objetivo, inst_responsavel)
VALUES ('Conservação de Espécies Criticamente Ameaçadas do Brasil', '2025-03-01',
        'Monitorar e proteger todas as espécies classificadas como CR no Brasil.', 'ICMBio');

INSERT INTO pesquisa_area_tematica (pesquisa, area_tematica) VALUES
('Conservação de Espécies Criticamente Ameaçadas do Brasil', 'Conservação'),
('Conservação de Espécies Criticamente Ameaçadas do Brasil', 'Zoologia');

INSERT INTO pesquisa_pesquisador (pesquisa, pesquisador) VALUES
('Conservação de Espécies Criticamente Ameaçadas do Brasil', 3002),
('Conservação de Espécies Criticamente Ameaçadas do Brasil', 4002);

INSERT INTO pesquisa_especie (pesquisa, especie) VALUES
('Conservação de Espécies Criticamente Ameaçadas do Brasil', 'Trichechus manatus'),
('Conservação de Espécies Criticamente Ameaçadas do Brasil', 'Araucaria angustifolia');

-- Pesquisa que cobre APENAS Trichechus manatus (uma das duas espécies CR).
-- NÃO deve aparecer na Query 7 — Araucaria angustifolia fica de fora.
INSERT INTO pesquisa (titulo, data_inicio, objetivo, inst_responsavel)
VALUES ('Proteção do Peixe-boi Marinho', '2026-01-10',
        'Preservar a população de Trichechus manatus no litoral brasileiro.', 'UFPE');

INSERT INTO pesquisa_area_tematica (pesquisa, area_tematica) VALUES
('Proteção do Peixe-boi Marinho', 'Mamíferos Aquáticos');

INSERT INTO pesquisa_pesquisador (pesquisa, pesquisador) VALUES
('Proteção do Peixe-boi Marinho', 9002);

INSERT INTO pesquisa_especie (pesquisa, especie) VALUES
('Proteção do Peixe-boi Marinho', 'Trichechus manatus');


-- ====================================================================
-- QUERY 4 (prevista): Ocorrências por comunidade tradicional,
--          agrupadas por tipo e nível de gravidade.
-- Enriquece a Comunidade Quilombola Kalunga (UC 2, zona 2) com um
-- terceiro tipo de ocorrência, tornando o agrupamento mais variado.
-- A Comunidade Pescadores de Baía Sueste (UC 12, zona 2) permanece
-- SEM ocorrências — caso de borda para LEFT JOIN.
-- ====================================================================
INSERT INTO ocorrencia (unidade_conservacao, nro_zona, data_horario, fiscal,
                        tipo_ocorrencia, nivel_gravidade, area_afetada, descricao)
VALUES ('000000000002', 2, '2026-06-25 16:00:00', 2001,
        'INCENDIO NATURAL', 'BAIXO', 0.50,
        'Pequeno foco natural rapidamente controlado na zona de recuperação.');
