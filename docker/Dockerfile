
# pull official base image
FROM python:3.8-slim-buster

# set work directory
WORKDIR /usr/src/app

# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# install dependencies and Open CV
COPY ./requirements.txt \
    /usr/src/app/requirements.txt
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
    ffmpeg \
    libsm6 \
    libxext6 && \
    pip install --upgrade pip && \
    pip install -r requirements.txt && \
    apt-get remove -y \
    python-pip \
    curl &&\
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*

# copy project
COPY . /usr/src/app/
