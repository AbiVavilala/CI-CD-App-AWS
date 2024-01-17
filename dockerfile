FROM public.ecr.aws/docker/library/python:3.10-slim

RUN pip install --upgrade pip

WORKDIR /app
COPY . /app

RUN pip install gunicorn
RUN python -m pip install -r requirements.txt

EXPOSE 5000

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]