FROM python:3.10-slim

RUN pip install --upgrade pip
# Install gunicorn
 
WORKDIR /app
COPY . /app

RUN python -m pip install -r requirements.txt

EXPOSE 5000

 