FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY retail_data_generator/ ./retail_data_generator/
COPY etl/ ./etl/

# CMD ["python", "reqtail_data_generator/generator.py"]

