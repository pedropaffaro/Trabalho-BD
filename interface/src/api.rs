//! Camada de acesso à API REST de Unidades de Conservação.
//!
//! Cada função pública faz uma chamada HTTP bloqueante (`reqwest::blocking`)
//! ao backend FastAPI e devolve `Result<_, String>`, onde o `Err` já carrega
//! uma mensagem pronta para exibição na TUI (ver [`extract_error`]).

use serde::{Deserialize, Serialize};
use std::time::Duration;

/// Endereço base do backend FastAPI.
const BASE_URL: &str = "http://localhost:8000";
/// Tempo máximo de espera por resposta antes de abortar a requisição.
const TIMEOUT: Duration = Duration::from_secs(10);

/// Unidade de Conservação retornada pela API (corpo de resposta).
#[derive(Debug, Clone, Deserialize)]
pub struct Unidade {
    pub cnuc: String,
    pub nome: Option<String>,
    pub data_criacao: Option<String>,
    pub bioma: Option<String>,
    pub rodovia: Option<String>,
    pub km: Option<i32>,
    pub cidade: Option<String>,
    pub uf: Option<String>,
    pub descricao_acesso: Option<String>,
    pub orgao_gestor: Option<String>,
    // Pydantic v2 may serialize Decimal as string or number; accept both
    pub area_total: Option<serde_json::Value>,
}

impl Unidade {
    /// Normaliza `area_total` (string ou número, conforme serialização do
    /// Decimal pelo Pydantic) em texto exibível; `-` quando ausente.
    pub fn area_total_str(&self) -> String {
        match &self.area_total {
            None => "-".into(),
            Some(serde_json::Value::String(s)) => s.clone(),
            Some(serde_json::Value::Number(n)) => n.to_string(),
            Some(v) => v.to_string(),
        }
    }
}

/// Corpo enviado em POST/PUT. Campos opcionais nulos são omitidos do JSON
/// (`skip_serializing_if`) para deixar o backend aplicar seus defaults.
#[derive(Debug, Serialize)]
pub struct CreateUnidade {
    pub cnuc: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub nome: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub data_criacao: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub bioma: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub rodovia: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub km: Option<i32>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub cidade: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub uf: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub descricao_acesso: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub orgao_gestor: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub area_total: Option<f64>,
}

/// Filtros opcionais do GET `/unidades`. Cada campo vira um query param;
/// o valor literal `"null"` instrui o backend a buscar colunas vazias.
#[derive(Debug, Default, Clone)]
pub struct FilterParams {
    pub cnuc: Option<String>,
    pub nome: Option<String>,
    pub bioma: Option<String>,
    pub orgao_gestor: Option<String>,
    pub data_criacao: Option<String>,
    pub rodovia: Option<String>,
    pub cidade: Option<String>,
    pub uf: Option<String>,
    pub km: Option<String>,
}

/// Extrai UMA mensagem de erro descritiva do corpo JSON da resposta.
///
/// O backend devolve `detail` em dois formatos:
/// - **string**: erros tratados (`HTTPException`), ex. constraints do banco
///   ("Já existe uma unidade com este CNUC.") — usada como veio.
/// - **array**: erros de validação do Pydantic/FastAPI, cada item no formato
///   `{"loc": [...], "msg": "..."}`. Pegamos o primeiro, usamos o último
///   segmento de `loc` como nome do campo e `msg` como mensagem, produzindo
///   algo como `data_criacao: Data deve estar no formato DD-MM-AAAA`.
///
/// Retorna sempre um único erro para não sobrecarregar a barra de status.
fn extract_error(body: &str) -> String {
    /// Item de erro de validação do FastAPI/Pydantic.
    #[derive(Deserialize)]
    struct ValidationItem {
        #[serde(default)]
        loc: Vec<serde_json::Value>,
        msg: String,
    }

    #[derive(Deserialize)]
    struct ApiError {
        detail: Option<serde_json::Value>,
    }

    match serde_json::from_str::<ApiError>(body).ok().and_then(|e| e.detail) {
        // HTTPException(detail="...") — mensagem já pronta do backend.
        Some(serde_json::Value::String(s)) => s,
        // Erros de validação do Pydantic — lista de {loc, msg}.
        Some(serde_json::Value::Array(items)) => {
            serde_json::from_value::<Vec<ValidationItem>>(serde_json::Value::Array(items))
                .ok()
                .and_then(|list| list.into_iter().next())
                .map(|item| {
                    let campo = item
                        .loc
                        .last()
                        .and_then(|v| v.as_str())
                        .unwrap_or("campo");
                    // Pydantic prefixa erros de validador custom com "Value error, ".
                    let msg = item.msg.trim_start_matches("Value error, ");
                    format!("{campo}: {msg}")
                })
                .unwrap_or_else(|| "Erro de validação".into())
        }
        Some(v) => v.to_string(),
        None => body.to_string(),
    }
}

/// PUT `/unidades/{cnuc}` — atualiza uma unidade existente.
pub fn update_unidade(cnuc: &str, payload: &CreateUnidade) -> Result<Unidade, String> {
    let client = reqwest::blocking::Client::new();
    let resp = client
        .put(format!("{BASE_URL}/unidades/{cnuc}"))
        .json(payload)
        .timeout(TIMEOUT)
        .send()
        .map_err(|e| format!("Falha na conexão: {e}"))?;

    if !resp.status().is_success() {
        return Err(extract_error(&resp.text().unwrap_or_default()));
    }
    resp.json::<Unidade>()
        .map_err(|e| format!("Erro ao parsear resposta: {e}"))
}

/// DELETE `/unidades/{cnuc}` — remove a unidade e retorna o registro excluído.
pub fn delete_unidade(cnuc: &str) -> Result<Unidade, String> {
    let client = reqwest::blocking::Client::new();
    let resp = client
        .delete(format!("{BASE_URL}/unidades/{cnuc}"))
        .timeout(TIMEOUT)
        .send()
        .map_err(|e| format!("Falha na conexão: {e}"))?;

    if !resp.status().is_success() {
        return Err(extract_error(&resp.text().unwrap_or_default()));
    }
    resp.json::<Unidade>()
        .map_err(|e| format!("Erro ao parsear resposta: {e}"))
}

/// GET `/unidades` — lista unidades aplicando os filtros informados.
/// Trata 404 (nenhum resultado) como lista vazia, não como erro.
pub fn list_unidades(filters: &FilterParams) -> Result<Vec<Unidade>, String> {
    let client = reqwest::blocking::Client::new();
    let mut req = client.get(format!("{BASE_URL}/unidades")).timeout(TIMEOUT);

    let field_params: &[(&str, &Option<String>)] = &[
        ("cnuc", &filters.cnuc),
        ("nome", &filters.nome),
        ("bioma", &filters.bioma),
        ("orgao_gestor", &filters.orgao_gestor),
        ("data_criacao", &filters.data_criacao),
        ("rodovia", &filters.rodovia),
        ("cidade", &filters.cidade),
        ("uf", &filters.uf),
        ("km", &filters.km),
    ];
    for (key, val) in field_params {
        if let Some(v) = val {
            if !v.is_empty() {
                req = req.query(&[(key, v.as_str())]);
            }
        }
    }

    let resp = req.send().map_err(|e| format!("Falha na conexão: {e}"))?;

    // 404 means no results, not an error
    if resp.status().as_u16() == 404 {
        return Ok(vec![]);
    }

    if !resp.status().is_success() {
        let _status = resp.status();
        let body = resp.text().unwrap_or_default();

        return Err(extract_error(&body));
    }

    resp.json::<Vec<Unidade>>()
        .map_err(|e| format!("Erro ao parsear resposta: {e}"))
}

/// POST `/unidades` — cadastra uma nova unidade de conservação.
pub fn create_unidade(payload: &CreateUnidade) -> Result<Unidade, String> {
    let client = reqwest::blocking::Client::new();
    let resp = client
        .post(format!("{BASE_URL}/unidades"))
        .json(payload)
        .timeout(TIMEOUT)
        .send()
        .map_err(|e| format!("Falha na conexão: {e}"))?;

    if !resp.status().is_success() {
        let _status = resp.status();
        let body = resp.text().unwrap_or_default();

        return Err(extract_error(&body));
    }

    resp.json::<Unidade>()
        .map_err(|e| format!("Erro ao parsear resposta: {e}"))
}
