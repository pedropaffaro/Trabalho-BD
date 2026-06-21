import asyncpg
import os
from dotenv import load_dotenv

load_dotenv()  # carrega DB_* do .env

# Pool único compartilhado por toda a aplicação
_pool: asyncpg.Pool | None = None


async def get_env_pool() -> asyncpg.Pool:
    global _pool
    if _pool is None:  # cria só na 1ª chamada; reusa nas seguintes
        # Falha cedo se faltar alguma credencial de conexão.
        if not all(
            os.getenv(var)
            for var in ["DB_HOST", "DB_PORT", "DB_NAME", "DB_USER", "DB_PASSWORD"]
        ):
            raise Exception(
                "Variáveis de ambiente de banco de dados não configuradas corretamente."
            )

        _pool = await asyncpg.create_pool(
            host=os.getenv("DB_HOST"),
            port=int(os.getenv("DB_PORT") if os.getenv("DB_PORT") else ""),
            database=os.getenv("DB_NAME"),
            user=os.getenv("DB_USER"),
            password=os.getenv("DB_PASSWORD"),
        )
    return _pool


async def close_pool():
    global _pool
    if _pool:
        await _pool.close()
        _pool = None

