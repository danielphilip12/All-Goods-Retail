FROM python:3.12-slim

WORKDIR /app/retail_data_generator

COPY retail_data_generator/requirements.txt ./requirements.txt

RUN pip install --no-cache-dir -r requirements.txt

COPY retail_data_generator/ ./

# CMD ["python", "reqtail_data_generator/generator.py"]

