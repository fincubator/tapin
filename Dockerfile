FROM python:3.8.3-alpine3.11 as shared

RUN apk add --no-cache openssl

FROM shared as builder

RUN apk add --no-cache gcc libc-dev libffi-dev openssl-dev git

WORKDIR /app

COPY requirements.txt ./

RUN pip install --no-cache-dir -r requirements.txt

FROM shared

RUN apk add --no-cache bash

WORKDIR /app

COPY --from=builder /usr/local /usr/local

COPY --from=builder /app/src src

COPY . .

EXPOSE 9090

ENTRYPOINT ["./entrypoint.sh"]

CMD ["uwsgi", "--ini", "wsgi.ini"]
