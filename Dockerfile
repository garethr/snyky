#FROM python:3.7.5 AS pipenv
FROM python:slim AS pipenv
#FROM python:3.7-alpine3.8 as pipenv
RUN pip3 install pipenv


FROM pipenv AS parent
WORKDIR /app
COPY Pipfile /app/
COPY Pipfile.lock /app/
# Install a known vulnerable package
#RUN apk add --no-cache --update git=2.18.2-r
RUN apt-get update && apt-get install -y \
     git \
     && rm -rf /var/lib/apt/lists/


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
#RUN apk add --no-cache libstdc++
#COPY --from=snyk/snyk:alpine /usr/local/bin/snyk /usr/local/bin/snyk
COPY --from=snyk/snyk:linux /usr/local/bin/snyk /usr/local/bin/snyk
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
ENV PORT=5000
CMD ["python", "app.py"]


FROM release AS Dev
ENV FLASK_ENV=development


FROM release AS Prod
CMD gunicorn --capture-output --access-logfile=- --log-file=- --workers=2 --threads=4 --worker-class=gthread --worker-tmp-dir /dev/shm -b :${PORT} "app:app"
