"""NovaBank public gift-card catalogue API (PoC).
Non-personal data only. Two endpoints: /health and /api/cards.
SAY: "Small on purpose: it proves the platform (scale, logging, database), not business features."
"""
import json
import logging
import os
import time
import uuid

import psycopg
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse

logging.basicConfig(level=logging.INFO, format="%(message)s")
log = logging.getLogger("novabank")
app = FastAPI(title="NovaBank card catalogue (PoC)")

ENV = os.getenv("APP_ENV", "dev")
CACHE_TTL = int(os.getenv("CACHE_TTL_SECONDS", "30"))
_cache = {"at": 0.0, "rows": None}  # in-memory only: no personal data, so no residency concern
_db_ready = False

SEED = [
    ("EVERYDAY", "Everyday Gift Card", "standard", 10, 250, False),
    ("CHRISTMAS-2026", "Christmas Gift Card", "seasonal", 10, 250, False),
    ("BACK-TO-SCHOOL-2026", "Back-to-School Gift Card", "seasonal", 10, 150, False),
    ("FESTIVAL-AMS-LTD", "Festival Night Amsterdam (limited edition)", "limited", 25, 100, True),
]


def dsn() -> str:
    return (
        f"host={os.environ['DB_HOST']} dbname={os.environ['DB_NAME']} "
        f"user={os.environ['DB_USER']} password={os.environ['DB_PASSWORD']} "
        "sslmode=require connect_timeout=5"  # TLS is mandatory
    )


def init_db() -> None:
    """Create the table and seed it once. PoC shortcut; production uses explicit migrations."""
    global _db_ready
    with psycopg.connect(dsn()) as conn:
        conn.execute(
            """CREATE TABLE IF NOT EXISTS cards (
                 code text PRIMARY KEY, name text, category text,
                 min_value_eur int, max_value_eur int, limited_edition boolean)"""
        )
        if conn.execute("SELECT count(*) FROM cards").fetchone()[0] == 0:
            with conn.cursor() as cur:
                cur.executemany("INSERT INTO cards VALUES (%s,%s,%s,%s,%s,%s)", SEED)
    _db_ready = True


@app.middleware("http")
async def structured_logging(request: Request, call_next):
    start = time.time()
    cid = request.headers.get("x-correlation-id", str(uuid.uuid4()))
    response = await call_next(request)
    log.info(json.dumps({
        "msg": "request", "env": ENV, "method": request.method, "path": request.url.path,
        "status": response.status_code, "ms": round((time.time() - start) * 1000, 1),
        "correlation_id": cid,
    }))
    response.headers["x-correlation-id"] = cid
    return response


@app.get("/health")
def health():
    return {"status": "ok", "env": ENV}


@app.get("/api/cards")
def cards():
    now = time.time()
    if _cache["rows"] is not None and now - _cache["at"] < CACHE_TTL:
        return {"source": "cache", "cards": _cache["rows"]}  # protects the DB during a surge
    try:
        if not _db_ready:
            init_db()
        with psycopg.connect(dsn()) as conn:
            rows = conn.execute(
                "SELECT code,name,category,min_value_eur,max_value_eur,limited_edition FROM cards ORDER BY code"
            ).fetchall()
    except Exception as exc:  # keep errors generic for callers; details go to the log
        log.error(json.dumps({"msg": "db_error", "error": type(exc).__name__}))
        return JSONResponse(status_code=503, content={"error": "service temporarily unavailable"})
    data = [dict(zip(["code", "name", "category", "min_value_eur", "max_value_eur", "limited_edition"], r)) for r in rows]
    _cache.update(at=now, rows=data)
    return {"source": "database", "cards": data}
