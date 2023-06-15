ARG IMAGE=python:3.12.0b1
# python:slim
# python:3.7-alpine3.8
ARG DISTRO=debian

FROM ${IMAGE} as image


FROM image as pipenv
RUN pip3 install pipenv


FROM pipenv AS parent
WORKDIR /app
COPY Pipfile /app/
COPY Pipfile.lock /app/


FROM parent AS parent-debian
# Install a known vulnerable package
RUN apt-get update && apt-get install -y \
     git \
     && rm -rf /var/lib/apt/lists/


FROM parent AS parent-alpine
# Install a known vulnerable package
RUN apk add --no-cache --update git=2.18.2-r


FROM parent-${DISTRO} AS base
RUN pipenv install --deploy --system
COPY src /app


FROM parent AS dev-base
COPY --from=instrumenta/conftest /conftest /usr/local/bin/conftest
RUN pipenv install --dev
COPY . /app


FROM dev-base AS Test
RUN pipenv run pytest


FROM dev-base as security-debian
COPY --from=snyk/snyk:linux /usr/local/bin/snyk /usr/local/bin/snyk


FROM dev-base as security-alpine
RUN apk add --no-cache libstdc++
COPY --from=snyk/snyk:alpine /usr/local/bin/snyk /usr/local/bin/snyk


FROM security-${DISTRO} AS Security
ARG SNYK_TOKEN
RUN pipenv update
RUN snyk test


FROM dev-base as Policy
RUN conftest test --namespace pytest pytest.ini
RUN conftest test --namespace pipfile --input toml Pipfile
RUN conftest test --namespace docker Dockerfile
RUN conftest test snyky.yaml


FROM ${IMAGE} AS build-env
COPY Pipfile .
COPY Pipfile.lock .
RUN pip install pipenv && pipenv install --system --deploy


FROM gcr.io/distroless/python3 as Distroless
WORKDIR src /app
COPY --from=build-env /usr/local/lib/python3.7/site-packages /site-packages
COPY src/ .
ENV PYTHONPATH=/site-packages
CMD ["run.py", "app:app"]


FROM base AS Shell
CMD ["flask", "shell"] 


FROM base AS release
ENV PORT=5000
CMD ["python", "app.py"]


FROM release AS Dev
ENV FLASK_ENV=development


FROM release AS Prod
CMD ["gunicorn", "app:app"]



