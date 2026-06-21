import re
from pydantic import BaseModel, Field, field_validator, field_serializer
from typing import Optional
from datetime import date, datetime
from decimal import Decimal

# CNUC: 10 dígitos no formato oficial XXXX.XX.XXXX (12 caracteres com os pontos).
_CNUC_REGEX = re.compile(r"^\d{4}\.\d{2}\.\d{4}$")


class UnidadeCreate(BaseModel):
    # Validação no validator abaixo para garantir mensagem em português e o
    # formato oficial com pontos.
    cnuc: str = Field(..., examples=["0795.50.4329"])
    nome: Optional[str] = Field(
        None, max_length=100, example="Parque Nacional do Iguaçu"
    )
    data_criacao: Optional[date] = Field(None, example="31-12-2026")
    bioma: Optional[str] = Field(None, max_length=30, example="Mata Atlântica")

    @field_validator("cnuc")
    @classmethod
    def valida_cnuc(cls, v):
        if not _CNUC_REGEX.match(v):
            raise ValueError("CNUC deve estar no formato XXXX.XX.XXXX (ex: 0795.50.4329).")
        return v

    # mode="before": roda antes da coerção do Pydantic, aceitando a data em
    # vários formatos (BR e ISO). Tenta cada um; se nenhum casar, erro em PT.
    @field_validator("data_criacao", mode="before")
    @classmethod
    def parse_data(cls, v):
        if v is None or isinstance(v, date):
            return v
        if isinstance(v, str):
            for fmt in ("%d-%m-%Y", "%d/%m/%Y", "%Y-%m-%d", "%Y/%m/%d"):
                try:
                    return datetime.strptime(v, fmt).date()
                except ValueError:
                    pass  # tenta o próximo formato
            raise ValueError("Data deve estar no formato DD-MM-AAAA (ex: 31-12-2026)")
        return v

    rodovia: Optional[str] = Field(None, max_length=100, example="BR 469")
    km: Optional[int] = Field(None, ge=0, example=18)
    cidade: Optional[str] = Field(None, max_length=100, example="Foz do Iguaçu")
    # Sem max_length: validado abaixo para emitir mensagem em português.
    uf: Optional[str] = Field(None, example="PR")

    @field_validator("uf")
    @classmethod
    def valida_uf(cls, v):
        if v is None:
            return v
        if len(v) != 2 or not v.isalpha():
            raise ValueError("UF deve conter exatamente 2 letras (ex: SP).")
        return v.upper()

    descricao_acesso: Optional[str] = Field(
        None, max_length=255, example="Acesso pela marginal da rodovia"
    )
    orgao_gestor: Optional[str] = Field(None, max_length=100, example="ICMBio")
    area_total: Optional[Decimal] = Field(
        default=Decimal("0.00"), ge=0, example="12345.67"
    )


class UnidadeResponse(BaseModel):
    cnuc: str
    nome: Optional[str] = None
    data_criacao: Optional[date] = None
    bioma: Optional[str] = None
    rodovia: Optional[str] = None
    km: Optional[int] = None
    cidade: Optional[str] = None
    uf: Optional[str] = None
    descricao_acesso: Optional[str] = None
    orgao_gestor: Optional[str] = None
    area_total: Optional[Decimal] = None

    # Na saída, devolve a data como string DD-MM-AAAA (formato BR) em vez do ISO.
    @field_serializer("data_criacao")
    def format_data(self, v: Optional[date]) -> Optional[str]:
        return v.strftime("%d-%m-%Y") if v else None
