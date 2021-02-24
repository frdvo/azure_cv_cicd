FROM python:3.8.8-slim as base

FROM base as builder
RUN mkdir install
WORKDIR /install
COPY scr/requirements.txt /requirements.txt
RUN pip install --prefix /install -r /requirements.txt

FROM base
RUN apt-get update && apt-get install \
ffmpeg -y && \
apt-get autoremove && \
rm -rf /var/lib/apt/lists/* \
&& rm -rf /var/cache/apt/archives
COPY --from=builder /install /usr/local
COPY scr /app
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
WORKDIR /app
CMD ["python", "app.py", "run", "-h", "0.0.0.0"]