# pull official base image
FROM python:3.8.8-slim

# set work directory
WORKDIR /usr/src/app

# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# install dependencies
RUN apt-get update && apt-get install \
ffmpeg -y && \
apt-get autoremove && \
rm -rf /var/lib/apt/lists/* \
&& rm -rf /var/cache/apt/archives
COPY ./requirements.txt \
    /usr/src/app/requirements.txt
RUN pip install -r requirements.txt

# copy project
COPY . /usr/src/app/

# run the app
CMD ["python", "app.py", "run", "-h", "0.0.0.0"]
