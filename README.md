[![License]][LICENSE.txt]
[![Telegram]][Teletram join]

--------------------------------------------------------------------------------

# Tapin

[tapin][Teletram join] is a python-based faucet for Graphene-based blockchains
(e.g.  BitShares).

## Installation

* edit `config.py` and provide private keys and settings
* `python manage.py install`

## Usage

* `python manage.py runserver`

The faucet is then available at URL `http://localhost:5000`

## Deploy on Heroku

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

Remark: Please understand the risks of exposing private keys to heroku!

## Nginx configuration

Run `uwsgi --ini wsgi.ini`

and use a configuration similar tothis

```
user bitshares;
worker_processes  4;

events {
    worker_connections  2048;
}

http {
    include       mime.types;
    default_type  application/octet-stream;
    access_log  /www/logs/access.log;
    error_log  /www/logs/error.log;
    log_not_found off;
    sendfile        on;
    keepalive_timeout  65;
    gzip  on;

    upstream websockets {
      server localhost:9090;
      server localhost:9091;
    }

    server {
        listen       80;
        if ($scheme != "https") {
                return 301 https://$host$request_uri;
        }

        listen       443 ssl;
        server_name  bitshares-wallet.com;
        ssl_certificate      /etc/nginx/ssl/bitshares-wallet.com.crt;
        ssl_certificate_key /etc/nginx/ssl/bitshares-wallet.com.key;
        ssl_session_cache    shared:SSL:1m;
        ssl_session_timeout  5m;
        ssl_ciphers  HIGH:!aNULL:!MD5;
        ssl_prefer_server_ciphers  on;

        location ~ /ws/? {
            access_log on;
            proxy_pass http://websockets;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_next_upstream     error timeout invalid_header http_500;
            proxy_connect_timeout   2;
        }
        location ~ ^/[\w\d\.-]+\.(js|css|dat|png|json)$ {
            root /www/wallet;
            try_files $uri /wallet$uri =404;
        }
        location / {
            root /www/wallet;
        }
        location /api {
                include uwsgi_params;
                uwsgi_pass unix:/tmp/faucet.sock;
        }

    }
}
```
# Use with prebuild Docker images

Create a service directory and navigate to it:
```bash
mkdir faucet && cd faucet
```

Download [Dockerfile-prebuild] and [docker-compose-prebuild.yml] into this
directory by running the command:
```bash
wget https://raw.githubusercontent.com/fincubator/tapin/master/Dockerfile-prebuild \
     https://raw.githubusercontent.com/fincubator/tapin/master/docker-compose-prebuild.yml
```

Create a file `config.yml` in this directory and fill it with the contents of
approximately like in the `config-example.yml` file, where:
* `secret_key` - is your random secret key. Generate it, for example, in your
password manager.
* `mail_host` - server of your SMTP provider.
* `mail_user` and mail_pass - login and password from your SMTP provider.
* `mail_from` - your mail address.
* `admins` - list here the mail addresses of administrators.
* `witness_url` - specify the address of your node.
* `registrar` - specify a registrar account.
* `default_referrer` - specify default_referrer, which will receive the reward.
* `referrer_percent` - specify the percentage of payments to the referral.
* `wif` - specify your private key.
* `balance_mailthreshold` - specify a minimum balance, after which a warning
message will be sent to your mail.
* `core_asset` - specify the tiker at which the fee will be paid.

If you use Gmail, then `mail_host` will be smtp.gmail.com:587, `mail_user` and
`mail_pass` - your login and password from your mailbox, `mail_from` - full
address your mailbox, like faucet-noreply@gmail.com.

Start your service by executing the command:
```bash
sudo docker-compose -f docker-compose-prebuild.yml up --build 
```

[License]: https://img.shields.io/github/license/fincubator/tapin
[LICENSE.txt]: LICENSE.txt
[Telegram]: https://img.shields.io/badge/Telegram-fincubator-blue?logo=telegram
[Teletram join]: https://t.me/fincubator
[Dockerfile-prebuild]: Dockerfile-prebuild
[docker-compose-prebuild.yml]: docker-compose-prebuild.yml
