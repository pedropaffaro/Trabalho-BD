from pydantic import BaseModel, Field, field_validator, field_serializer
from typing import Optional
from datetime import date, datetime
from decimal import Decimal


class UnidadeCreate(BaseModel):
    cnuc: str = Field(..., min_length=12, max_length=12, examples=["000123456789"])
    nome: Optional[str] = Field(None, max_length=100, example="Parque Nacional do Iguaçu")
    data_criacao: Optional[date] = Field(None, example="31-12-2026")
    bioma: Optional[str] = Field(None, max_length=30, example="Mata Atlântica")

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
                    pass
            raise ValueError("Data deve estar no formato DD-MM-AAAA (ex: 31-12-2026)")
        return v
    
    rodovia: Optional[str] = Field(None, max_length=100, example="BR 469")
    km: Optional[int] = Field(None, ge=0, example=18)
    cidade: Optional[str] = Field(None, max_length=100, example="Foz do Iguaçu")
    uf: Optional[str] = Field(None, max_length=2, example="PR")
    descricao_acesso: Optional[str] = Field(None, max_length=255, example="Acesso pela marginal da rodovia")
    orgao_gestor: Optional[str] = Field(None, max_length=100, example="ICMBio")
    area_total: Optional[Decimal] = Field(default=Decimal("0.00"), ge=0, example="12345.67")


class UnidadeResponse(BaseModel):
    cnuc: str
    nome: Optional[str]
    data_criacao: Optional[date]
    bioma: Optional[str]
    rodovia: Optional[str]
    km: Optional[int]
    cidade: Optional[str]
    uf: Optional[str]
    descricao_acesso: Optional[str]
    orgao_gestor: Optional[str]
    area_total: Optional[Decimal]

    @field_serializer("data_criacao")
    def format_data(self, v: Optional[date]) -> Optional[str]:
        return v.strftime("%d-%m-%Y") if v else None