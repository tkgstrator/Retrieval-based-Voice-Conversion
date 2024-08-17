import uvicorn
from fastapi import FastAPI

from rvc.wrapper.api.endpoints import inference

app = FastAPI()

app.include_router(inference.router)
