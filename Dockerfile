FROM python:3.7-alpine3.8 AS base

# Install a known vulnerable package
RUN apk add --no-cache --update git=2.18.1-r0

WORKDIR /app
RUN pip3 install pipenv

COPY Pipfile /app/
COPY Pipfile.lock /app/

RUN pipenv install --deploy --system

COPY src /app


FROM base AS Shell
CMD ["flask", "shell"] 

FROM base AS release
EXPOSE 5000
CMD ["python", "app.py"]

FROM release AS Dev
ENV FLASK_ENV=development

FROM release as Prod
CMD ["gunicorn", "-b", ":5000", "app:app"]
