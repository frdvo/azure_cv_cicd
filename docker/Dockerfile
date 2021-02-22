
# pull official base image
FROM python:3.8-slim-buster

# set work directory
WORKDIR /usr/src/app

# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# install dependencies
RUN pip install --upgrade pip
COPY ./requirements.txt /usr/src/app/requirements.txt
RUN pip install -r requirements.txt

# Open CV dependencies

RUN apt-get update ##[edited]
RUN apt-get install ffmpeg libsm6 libxext6  -y

# copy project
COPY . /usr/src/app/
