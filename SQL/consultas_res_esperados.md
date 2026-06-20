# Resultados Esperados das Consultas

Dataset completo = `dados.sql` + `dados_casos_borda.sql`.

---

## Query 1 — Biólogos com espécies ameaçadas observadas por câmera em pesquisas com ≥ 2 pesquisadores

```sql
SELECT O.biologo, COUNT(DISTINCT E.nome_cientifico) AS nro_especies_observadas
FROM observacao O
JOIN ser_vivo S ON S.chip = O.ser_vivo
JOIN especie E ON E.nome_cientifico = S.especie
JOIN pesquisa_especie PE ON PE.especie = E.nome_cientifico
JOIN (
    SELECT pesquisa FROM pesquisa_pesquisador
    GROUP BY pesquisa HAVING COUNT(pesquisador) >= 2
) AS pesquisas_validas ON pesquisas_validas.pesquisa = PE.pesquisa
WHERE O.metodo = 'CAMERA' AND E.status_conservacao IN ('CR', 'EN', 'VU')
GROUP BY O.biologo;
```
### Resultado esperado

| biologo | nro_especies_observadas |
|---|---|
| 2001 | 1 |
| 4002 | 1 |

---

## Query 2 — Funcionários com mais de uma categoria por unidade de conservação

```sql
SELECT F.unidade_conservacao, COUNT(*) AS nro_funcionarios_multicategoricos
FROM funcionario F
JOIN (
    SELECT funcionario FROM funcionario_categoria
    GROUP BY funcionario HAVING COUNT(*) > 1
) AS funcionarios_validos ON funcionarios_validos.funcionario = F.nro_funcional
GROUP BY F.unidade_conservacao;
```

### Resultado esperado

| unidade_conservacao | nro_funcionarios_multicategoricos |
|---|---|
| 000000000001 | 2 |
| 000000000002 | 2 |
| 000000000003 | 2 |
| 000000000004 | 2 |
| 000000000012 | 1 |

---

## Query 3 — Biólogos que nunca fizeram observação por câmera à noite

```sql
SELECT FC.funcionario, F.nome
FROM funcionario_categoria FC
JOIN funcionario F ON F.nro_funcional = FC.funcionario
WHERE FC.categoria = 'BIOLOGO'
  AND NOT EXISTS (
      SELECT 1 FROM observacao O
      WHERE O.biologo = FC.funcionario
        AND O.metodo = 'CAMERA'
        AND (EXTRACT(HOUR FROM O.data_hora) >= 18 OR EXTRACT(HOUR FROM O.data_hora) <= 5)
  );
```


### Resultado esperado

| funcionario | nome |
|---|---|
| 2001 | Ana Batista |
| 3002 | Luciana Alves |
| 4002 | Patricia Lima |
| 9003 | Douglas Silva |

---

## Query 4 — Ocorrências por comunidade tradicional (consulta prevista, não implementada)

Esqueleto esperado da consulta:

```sql
SELECT CT.nome AS comunidade, O.tipo_ocorrencia, O.nivel_gravidade,
       COUNT(*) AS qtd_ocorrencias, AVG(O.area_afetada) AS media_area_afetada
FROM comunidade_tradicional CT
LEFT JOIN ocorrencia O
       ON CT.unidade_conservacao = O.unidade_conservacao
      AND CT.nro_zona = O.nro_zona
GROUP BY CT.nome, O.tipo_ocorrencia, O.nivel_gravidade
ORDER BY CT.nome, O.tipo_ocorrencia;
```
TODO: VERIFICAR MELHOR

### Resultado parcial esperado (com LEFT JOIN)

| comunidade | tipo_ocorrencia | nivel_gravidade | qtd_ocorrencias | media_area_afetada |
|---|---|---|---|---|
| Aldeia Guarani Tekoha | CACA | MEDIO | 1 | 0.00 |
| Aldeia Guarani Tekoha | DESMATAMENTO | ALTO | 1 | 2.00 |
| Aldeia Guarani Tekoha | INCENDIO CRIMINOSO | ALTISSIMO | 1 | 15.50 |
| Aldeia Guarani Tekoha | INVASAO DE ZONA | BAIXO | 1 | 0.00 |
| Comunidade Chico Mendes | INVASAO DE ZONA | ALTO | 1 | 25.00 |
| Comunidade Quilombola Kalunga | CACA | MEDIO | 1 | 10.00 |
| Comunidade Quilombola Kalunga | DESMATAMENTO | ALTO | 1 | 3.00 |
| Comunidade Quilombola Kalunga | INCENDIO NATURAL | BAIXO | 1 | 0.50 |
| Pescadores de Baía Sueste | NULL | NULL | NULL | NULL |
| Povoadores do Campo Seco | GARIMPO | ALTISSIMO | 1 | 50.00 |
| ... | ... | ... | ... | ... |

---

## Query 5 — Visitas educativas com guia qualificado

```sql
SELECT * FROM visita V
WHERE V.guia IS NOT NULL
  AND V.tipo = 'EDUCATIVA'
  AND (
      EXISTS (SELECT * FROM funcionario_categoria FC
              WHERE FC.funcionario = V.guia AND UPPER(FC.categoria) = 'BIOLOGO')
      OR
      EXISTS (SELECT * FROM pesquisa_pesquisador PP
              WHERE PP.pesquisador = V.guia)
  );
```

### Resultado esperado

| cod_visita | unidade_conservacao | nro_zona | nro_visita | data_hora | tipo | nro_visitantes | guia |
|---|---|---|---|---|---|---|---|
| 11 | 000000000001 | 2 | 104 | 2026-06-18 10:00:00 | EDUCATIVA | 2 | 1003 |
| 13 | 000000000002 | 2 | 204 | 2026-06-22 09:00:00 | EDUCATIVA | 3 | 2002 |

---

## Query 6 — Espécies sem nenhum ser vivo registrado

```sql
SELECT E.nome_cientifico, E.status_conservacao, COUNT(PE.pesquisa) AS qte_pesquisas
FROM especie E
LEFT JOIN pesquisa_especie PE ON E.nome_cientifico = PE.especie
WHERE NOT EXISTS (
    SELECT * FROM ser_vivo S WHERE S.especie = E.nome_cientifico
)
GROUP BY E.nome_cientifico, E.status_conservacao;
```

### Resultado esperado

| nome_cientifico | status_conservacao | qte_pesquisas |
|---|---|---|
| Agaricus blazei | DD | 0 |
| Araucaria angustifolia | CR | 1 |
| Caryocar brasiliense | LC | 1 |
| Handroanthus albus | LC | 0 |
| Hevea brasiliensis | LC | 1 |

---

## Query 7 — Pesquisas que estudam TODAS as espécies CR

```sql
SELECT P.titulo
FROM pesquisa P
WHERE NOT EXISTS (
    SELECT E.nome_cientifico FROM especie E
    WHERE E.status_conservacao = 'CR'
    EXCEPT
    SELECT PE.especie FROM pesquisa_especie PE
    WHERE PE.pesquisa = P.titulo
);
```

### Resultado esperado

| titulo |
|---|
| Conservação de Espécies Criticamente Ameaçadas do Brasil |

---
