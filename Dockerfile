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

RUN apk add --no-cache curl wget gcc
RUN curl -s https://api.github.com/repos/snyk/snyk/releases/latest | grep "browser_download_url" | grep alpine | cut -d '"' -f 4 | wget -i - && \
    sha256sum -c snyk-alpine.sha256 && \
    mv snyk-alpine /usr/local/bin/snyk && \
    chmod +x /usr/local/bin/snyk

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
