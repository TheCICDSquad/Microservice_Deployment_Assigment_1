# app/main.py
from fastapi import FastAPI, Request
from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
import httpx
import os

app = FastAPI()

# Mount static files and templates
app.mount("/static", StaticFiles(directory="app/static"), name="static")
templates = Jinja2Templates(directory="app/templates")

# Exchange rate API configuration
API_KEY = os.getenv("EXCHANGE_RATE_API_KEY", "your-api-key")
BASE_URL = "https://api.exchangerate.host"

@app.get("/", response_class=HTMLResponse)
async def read_root(request: Request):
    return templates.TemplateResponse("index.html", {"request": request})

@app.get("/convert")
async def convert_currency(from_currency: str, to_currency: str, amount: float):
    try:
        async with httpx.AsyncClient() as client:
            # Get latest exchange rates
            response = await client.get(
                f"{BASE_URL}/convert",
                params={
                    "from": from_currency,
                    "to": to_currency,
                    "amount": amount,
                    "access_key": API_KEY
                }
            )
            response.raise_for_status()
            data = response.json()
            
            if not data.get("success", False):
                return {"error": data.get("error", {}).get("info", "Conversion failed")}
            
            return {
                "from": from_currency,
                "to": to_currency,
                "amount": amount,
                "result": data["result"],
                "rate": data["info"]["rate"]
            }
    except Exception as e:
        return {"error": str(e)}