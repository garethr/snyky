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
RUN pipenv install --deploy --system --dev
COPY src /app


FROM dev-base AS Test
RUN pytest


FROM dev-base AS Security
ARG SNYK_TOKEN
RUN apk add --no-cache libstdc+
COPY --from=snyk/snyk:alpine /usr/local/bin/snyk /usr/local/bin/sny
RUN pipenv update
RUN /usr/local/bin/snyk test


FROM base AS Shell
CMD ["flask", "shell"] 


FROM base AS release
EXPOSE 5000
CMD ["python", "app.py"]


FROM release AS Dev
ENV FLASK_ENV=development


FROM release AS Prod
CMD ["gunicorn", "-b", ":5000", "app:create_app()"]
