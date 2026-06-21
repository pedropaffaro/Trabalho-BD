from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.exceptions import RequestValidationError
from database import get_env_pool, close_pool
from routers import unidades


# Ciclo de vida da app: abre o pool de conexões na subida (antes do yield)
# e o fecha no shutdown (depois do yield).
@asynccontextmanager
async def lifespan(app: FastAPI):
    await get_env_pool()   # cria o pool uma única vez
    yield                  # app no ar atendendo requisições
    await close_pool()     # libera as conexões ao desligar

app = FastAPI(
    title="Unidades de Conservação",
    version="1.0.0",
    lifespan=lifespan
)

app.include_router(unidades.router)