FROM python:3.14.5-alpine3.23

LABEL maintainer="Yahya Alshalabi"
LABEL maintainer.email="yahya.alshalabi.eng@gmail.com"

ENV PYTHONUNBUFFERED=1

COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt

COPY ./app /app

WORKDIR /app

EXPOSE 8000

ARG DEV=false

RUN python -m venv /py && \
    /py/bin/pip install --no-cache-dir --upgrade pip && \
    apk add --no-cache --update postgresql-client && \
    apk add --no-cache --update --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev && \
    /py/bin/pip install --no-cache-dir -r /tmp/requirements.txt && \
    if [ "$DEV" = "true" ]; \
        then /py/bin/pip install --no-cache-dir -r /tmp/requirements.dev.txt; \
    fi && \
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
    adduser \
        --disabled-password \
        --no-create-home \
        --home /app \
        django-user

ENV PATH="/py/bin:$PATH"

USER django-user