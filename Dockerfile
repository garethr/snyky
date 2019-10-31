FROM python:3.7-alpine3.8 AS pipenv
RUN pip3 install pipenv


FROM pipenv AS parent
WORKDIR /app
COPY Pipfile /app/
COPY Pipfile.lock /app/
# Install a known vulnerable package
RUN apk add --no-cache --update git=2.18.1-r0


FROM parent AS base
RUN pipenv install --deploy --system
COPY src /app


FROM parent AS dev-base
COPY --from=instrumenta/conftest /conftest /usr/local/bin/conftest
RUN pipenv install --dev
COPY . /app


FROM dev-base AS Test
RUN pipenv run pytest


FROM dev-base AS Security
ARG SNYK_TOKEN
RUN apk add --no-cache libstdc++
COPY --from=snyk/snyk:alpine /usr/local/bin/snyk /usr/local/bin/snyk
RUN pipenv update
RUN snyk test


FROM dev-base as Policy
RUN conftest test --namespace pytest pytest.ini
RUN conftest test --namespace pipfile --input toml Pipfile
RUN conftest test --namespace docker Dockerfile
RUN conftest test snyky.yaml


FROM base AS Shell
CMD ["flask", "shell"] 


FROM base AS release
EXPOSE 5000
CMD ["python", "app.py"]


FROM release AS Dev
ENV FLASK_ENV=development


FROM release AS Prod
CMD ["gunicorn", "-b", ":5000", "app:create_app()"]
