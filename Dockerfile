FROM python:3.7-alpine3.8 AS parent

WORKDIR /app
RUN pip3 install pipenv


FROM parent AS base

# Install a known vulnerable package
RUN apk add --no-cache --update git=2.18.1-r0

COPY Pipfile /app/
COPY Pipfile.lock /app/

RUN pipenv install --deploy --system

COPY src /app


FROM parent as Security
ARG SNYK_TOKEN

COPY --from=garethr/snyk-alpine:latest /usr/local/bin/snyk /usr/local/bin/snyk

RUN apk add --no-cache libstdc++

COPY Pipfile /app/
COPY Pipfile.lock /app/

RUN pipenv install

COPY src /app

RUN /usr/local/bin/snyk test


FROM base AS Shell
CMD ["flask", "shell"] 

FROM base AS release
EXPOSE 5000
CMD ["python", "app.py"]

FROM release AS Dev
ENV FLASK_ENV=development

FROM release as Prod
CMD ["gunicorn", "-b", ":5000", "app:app"]
