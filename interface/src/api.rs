use serde::{Deserialize, Serialize};
use std::time::Duration;

const BASE_URL: &str = "http://localhost:8000";
const TIMEOUT: Duration = Duration::from_secs(10);

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
    pub fn area_total_str(&self) -> String {
        match &self.area_total {
            None => "-".into(),
            Some(serde_json::Value::String(s)) => s.clone(),
            Some(serde_json::Value::Number(n)) => n.to_string(),
            Some(v) => v.to_string(),
        }
    }
}

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

fn extract_error(body: &str) -> String {
    #[derive(Deserialize)]
    struct ApiErrorDetail {
        campo: String,
        mensagem: String,
    }

    #[derive(Deserialize)]
    struct ApiError {
        detail: Option<serde_json::Value>,
    }

    serde_json::from_str::<ApiError>(body)
        .ok()
        .and_then(|e| e.detail)
        .map(|detail| match detail {
            serde_json::Value::String(s) => s,
            serde_json::Value::Array(_) => serde_json::from_value::<Vec<ApiErrorDetail>>(detail)
                .ok()
                .and_then(|list| list.into_iter().next())
                .map(|err| format!("{}: {}", err.campo, err.mensagem))
                .unwrap_or_else(|| "Erro de validação".into()),
            v => v.to_string(),
        })
        .unwrap_or_else(|| body.to_string())
}

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
    resp.json::<Unidade>().map_err(|e| format!("Erro ao parsear resposta: {e}"))
}

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
    resp.json::<Unidade>().map_err(|e| format!("Erro ao parsear resposta: {e}"))
}

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
