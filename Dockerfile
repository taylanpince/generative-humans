FROM python:3.10-slim-bookworm

EXPOSE 8001

# set work directory
WORKDIR /usr/src/generative-humans

# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# install dependencies
RUN pip install --upgrade pip
COPY ./requirements.txt .
RUN pip install -r requirements.txt

# copy project
COPY . .
