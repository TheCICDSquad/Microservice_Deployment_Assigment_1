# Dockerfile
FROM python:3.9-slim

WORKDIR /app

# Create a non-root user
RUN useradd -m appuser && chown -R appuser /app
USER appuser

# Install dependencies
COPY --chown=appuser requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY --chown=appuser . .

ENV PYTHONPATH=/app
ENV PORT=8000
EXPOSE $PORT

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]