# Consultas Implementadas

Neste texto destacamos para cada uma das seis buscas desenvolvidas quais seus objetivos, utilidades e características implementadas.

---

## 1º Consulta:
__Descrição da Consulta:__ Contabiliza o volume de espécies distintas sob ameaça de extinção, que estão classificadas em algum dos graus: Crítico (CR), em Perigo (EN) ou Vulnerável (VU), que foram registradas exclusivamente por uma câmera, sendo a espécie observada parte de um projeto de pesquisa vinculada a no mínimo dois pesquisadores. O resultado agrupa as contagens pelo biólogo responsável pela observação.

__Complexidade:__ Esta consulta utiliza 4 operadores JOIN encadeados para transitar desde a observação física do animal até à equipa de pesquisa associada. Faz uso de filtragem por conjunto (IN), agrupamento de dados (GROUP BY), contagem distinta (COUNT(DISTINCT)) para evitar inflar o indicador caso a mesma espécie seja vista várias vezes, e uma Subconsulta Derivada na cláusula FROM contendo agrupamento e restrição de grupo via HAVING COUNT(pesquisador) >= 2.

__Utilidade:__ Permite à administração avaliar o desempenho de campo dos biólogos focados estritamente na fauna sob maior risco ecológico. Ao cruzar estas observações com pesquisas robustas, o sistema valida a urgência científica e direciona recursos de custeio para as equipas de campo cujas observações alimentam diretamente estudos importantes.


```Sql
SELECT O.biologo, COUNT(DISTINCT E.nome_cientifico) AS nro_especies_observadas
FROM observacao O
JOIN ser_vivo S ON S.chip = O.ser_vivo
JOIN especie E ON E.nome_cientifico = S.especie
JOIN pesquisa_especie PE ON PE.especie = E.nome_cientifico
JOIN (
    SELECT pesquisa
    FROM pesquisa_pesquisador
    GROUP BY pesquisa
    HAVING COUNT(pesquisador) >= 2
) AS pesquisas_validas ON pesquisas_validas.pesquisa = PE.pesquisa
WHERE O.metodo = 'CAMERA' AND E.status_conservacao IN ('CR', 'EN', 'VU')
GROUP BY O.biologo;
```
---

## 2° Consulta:
__Descrição da Consulta:__ Identifica e quantifica os funcionários que possuem mais de uma atribuição funcional ativa no sistema. O resultado entrega o número absoluto dos colaboradores com mais de uma função, distribuindo e agrupando as contagens de acordo com a Unidade de Conservação onde estão alocados.

__Complexidade:__ Soluciona um cenário de especialização com sobreposição de papéis na modelagem relacional. Para garantir a precisão dos dados e evitar que um mesmo funcionário seja contado múltiplas vezes, a lógica de cardinalidade é isolada em uma subconsulta derivada na cláusula FROM. Essa estrutura interna agrupa os registros da tabela associativa e emprega o operador HAVING COUNT(*) > 1 para filtrar apenas os indivíduos multicategóricos. A camada externa realiza a junção interna (JOIN) com a tabela principal e aplica um segundo nível de agrupamento (GROUP BY) para consolidar os totais por Unidade de Conservação.

__Utilidade:__ Serve como um indicador de flexibilidade no gerenciamento de recursos humanos. Para a administração central, mapear quais Unidades de Conservação concentram profissionais capazes de transitar por múltiplas funções facilita o planejamento estratégico de escalas permitindo cobrir ausências ou picos de demanda interna sem a necessidade de novas contratações emergenciais.

```Sql
SELECT F.unidade_conservacao, COUNT(*) AS nro_funcionarios_multicategoricos
FROM funcionario F
JOIN (
    SELECT funcionario
    FROM funcionario_categoria
    GROUP BY funcionario
    HAVING COUNT(*) > 1
) AS funcionarios_validos ON funcionarios_validos.funcionario = F.nro_funcional
GROUP BY F.unidade_conservacao;
```

---
## 3° Consulta:
__Descrição da Consulta:__ Mapeia e lista o identificador funcional e o nome de todos os biólogos do quadro que nunca realizaram um registro de observação faunística utilizando uma câmera durante o período noturno, compreendido entre as 18 horas de um dia e as 5 horas da manhã do dia seguinte.

__Complexidade:__ Esta consulta apresenta sua complexidade ao empregar uma estrutura de negação existencial (NOT EXISTS) vinculada a uma subconsulta correlacionada. O principal desafio reside na modelagem da janela temporal que cruza a meia-noite. Para delimitar o período noturno corretamente, extrai-se a hora do atributo cronológico (via EXTRACT) e aplica-se uma disjunção lógica (OR).

__Utilidade:__ Atua como ferramenta estratégica e operacional para o controle de lacunas no monitoramento ecológico. Animais de hábitos estritamente noturnos dependem quase inteiramente de capturas por fotos operadas no escuro. Identificar quais profissionais ainda não possuem registros nesse intervalo específico permite à gestão do parque redistribuir as escalas de campo de forma eficiente e planejar treinamentos focados no manuseio e posicionamento de equipamentos de visão noturna.

```Sql
SELECT FC.funcionario, F.nome
FROM funcionario_categoria FC
JOIN funcionario F ON F.nro_funcional = FC.funcionario
WHERE FC.categoria = 'BIOLOGO'
  AND NOT EXISTS (
      SELECT 1
      FROM observacao O
      WHERE 
        O.biologo = FC.funcionario 
        AND O.metodo = 'CAMERA' 
        AND (EXTRACT(HOUR FROM O.data_hora) >= 18 OR EXTRACT(HOUR FROM O.data_hora) <= 5)
    );
```

---
## 4° Consulta:
__Descrição da Consulta:__ Recupera todos os registros de visitas classificadas como educativas (tipo = 'EDUCATIVA') que possuem um guia alocado, impondo a condição de que esse profissional seja um biólogo ou pesquisador.

__Utilidade:__ Atua como um controle de qualidade para as atividades de ecoturismo pedagógico. A consulta permite assegurar que as visitas de instituições escolares ou acadêmicas agendadas nas Unidades de Conservação sejam mediadas exclusivamente por profissionais com sólida bagagem técnica.

__Complexidade:__ A complexidade se concentra no uso de dois operadores EXISTS independentes conectados por um (OR). Em vez de realizar junções (JOIN), que multiplicariam as linhas caso um guia acumulasse os dois papéis simultaneamente, as subconsultas funcionam como checagens isoladas. O motor do banco de dados avalia a primeira subquery correlacionada e, se a condição for verdadeira, aplica o mecanismo de short-circuit (curto-circuito), validando a linha da visita imediatamente sem precisar processar a segunda. Isso protege o resultado contra duplicidades.

```Sql
SELECT *
FROM visita V
WHERE
    V.guia IS NOT NULL 
    AND V.tipo = 'EDUCATIVA'
    AND (
        EXISTS (
          SELECT *
          FROM funcionario_categoria FC
          WHERE FC.funcionario = V.guia 
            AND UPPER(FC.categoria) = 'BIOLOGO'
        )

        OR

        EXISTS (
            SELECT * 
            FROM pesquisa_pesquisador PP
            WHERE PP.pesquisador = V.guia 
        )
    );

```

---

## 5° Consulta:
__Descrição da Consulta:__ Identifica as espécies catalogadas na literatura do sistema que estão "desaparecidas" na prática, ou seja, que nunca tiveram nenhum indivíduo real capturado e identificado com chip no registro de seres vivos. A listagem exibe o nome científico, o status de conservação e o volume de projetos de pesquisa que se pautam em estudar essas espécies.

__Complexidade:__ A abordagem reside na existência de uma junção (LEFT JOIN) com um filtro de negação existencial (NOT EXISTS). O LEFT JOIN é aplicado estrategicamente apenas à tabela de pesquisas para garantir que espécimes sem projetos associados permaneçam no resultado com contagem zero. A validação de ausência em campo foi otimizada utilizando um NOT EXISTS. Essa estrutura permite que o banco de dados interrompa a varredura na tabela ser_vivo assim que encontra a primeira correspondência para a espécie avaliada, minimizando o custo de processamento e protegendo a busca da multiplicação indevida de linhas.

__Utilidade:__ Funciona como um indicador de eficiência amostral e direcionamento científico. Se uma espécie possui um status de extinção grave e atrai o interesse de diversas pesquisas, mas nenhum espécime real foi chipado pelo parque, há um forte indício de que ou os métodos de busca estão falhando ou que aquela espécie já não é mais presente na Unidade de Conservação. Isso fornece aos gestores uma visão mais ampla quanto a quais segmentos de pesquisas de espécimes podem ser frutíferas no longo prazo.

```Sql
SELECT E.nome_cientifico, E.status_conservacao, COUNT(PE.pesquisa) AS qte_pesquisas
FROM especie E
LEFT JOIN pesquisa_especie PE ON E.nome_cientifico = PE.especie
WHERE NOT EXISTS (
    SELECT *
    FROM ser_vivo S
    WHERE S.especie = E.nome_cientifico
)
GROUP BY E.nome_cientifico, E.status_conservacao;
```

---

## 6° Consulta:
__Descrição da Consulta:__ Identifica e lista o título das pesquisas científicas que alcançaram cobertura total de amostragem para as espécies mais vulneráveis do ecossistema. O filtro seleciona apenas os projetos que estão estudando, simultaneamente, todas as espécies catalogadas sob o status de conservação 'CR' (Criticamente em Perigo).

__Complexidade:__ Implementa Divisão Relacional através da lógica de dupla negação e diferença de conjuntos. Como o padrão SQL não possui um operador nativo de divisão, a estratégia utiliza o comando EXCEPT aninhado a um NOT EXISTS. O banco de dados isola o universo de espécies críticas e subtrai dele as espécies vinculadas à pesquisa avaliada no momento. O projeto só é selecionado se o resultado dessa subtração for um conjunto completamente vazio, o que prova que nenhuma espécie exigida ficou de fora do escopo da pesquisa.

__Utilidade:__ Funciona como uma ferramenta capaz de identificar e centralizar todos os projetos de pesquisa de uma Unidade que se pautam na proteção de suas espécies sob risco iminente de desaparecimento em sua determinada Unidade de Conservação. Mapear essas iniciativas permite que a administração da Unidade priorize o repasse de verbas de custeio, direcione bolsas científicas e otimize a articulação com fundos de preservação.

```Sql
SELECT P.titulo
FROM pesquisa P
WHERE NOT EXISTS (
    SELECT E.nome_cientifico
    FROM especie E
    WHERE E.status_conservacao = 'CR'

    EXCEPT

    SELECT PE.especie
    FROM pesquisa_especie PE
    WHERE PE.pesquisa = P.titulo
);
```

