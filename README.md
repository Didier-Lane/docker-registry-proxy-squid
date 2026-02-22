# Docker Registry Proxy Squid

> A Cache Proxy to any Docker registries based on [Squid](https://www.squid-cache.org/)

## About

This project provides a cache reverse proxy to prevent pull rate limiting and speed up the kick-off a local Kubernetes cluster such as [Kind](https://kind.sigs.k8s.io/), [VIND](https://github.com/loft-sh/vind) or any other "In Docker" equivalents

It relies on Squid [SslPeekAndSplice](https://wiki.squid-cache.org/Features/SslPeekAndSplice) feature to cache docker images

> Operations are organized as abstract make recipes, just run `make` to see the list of available targets

## Requirements
- Docker
- Docker Compose
- OpenSSL for [generating a self-signed CA certificate](#generate-a-self-signed-ca-certificate-with-openssl)
- Make

## Generate a self-signed CA certificate with openssl

This example demonstrates how to generate a self-signed ECDSA CA certificate with openssl

Create the private key

```shell
openssl ecparam -genkey -name secp384r1 -out CA.key
```

Create the certificate configuration file

```shell
cat <<-EOF > CA.cnf
[ req ]
default_bits       = 4096
prompt             = no
default_md         = SHA384
distinguished_name = dn
[ dn ]
countryName  = FR
stateOrProvinceName = Paris
localityName  = Paris
organizationName  = Example
organizationalUnitName = IT
commonName = Example Certification Authority
[ v3_req ]
basicConstraints = critical,CA:TRUE
keyUsage = critical, digitalSignature, cRLSign, keyCertSign
subjectKeyIdentifier = hash
EOF
```

Create the CA certificate signing request

```shell
openssl req -new -SHA384 -nodes -out CA.csr -key CA.key -config CA.cnf
```

Create the CA certificate

```shell
openssl x509 -req -SHA384 -days 3650 -in CA.csr -signkey CA.key -extfile CA.cnf -extensions v3_req -out CA.crt
```

Finally concat the CA key and cert for later use with squid

```shell
cat CA.key CA.crt > CA-key-and-cert.pem
```

## Usage

Run `make` to generate the `.env` file, you can override any of the below listed [environment variables](#environment-variables) by passing them to `make` when generating the `.env` file

For example, to set the path to the self-signed CA certificate and key in pem format

```shell
make TLS_CA_CERT_AND_KEY=/path/to/CA-key-and-cert.pem
```

## Build image

Run `make build` to build the Docker image

## Configure Docker to use the Proxy

Create the file `/etc/systemd/system/docker.service.d/http-proxy.conf` with the following content

```shell
[Service]
Environment="HTTPS_PROXY=http://127.0.0.1:3128/"
```

Then run

```shell
sudo systemctl daemon-reload
sudo systemctl restart docker.service
```

## Run

Run `make up` to start the Registry Proxy

## Environment variables

| Name                  |     Description               | Default value
|--                     |--                             |--
| VERBOSE               | Enable verbose output of make recipes | `false`
| DOCKER                | Name of the docker cli, or equivalent (eg podman) | `docker`
| COMPOSE_PROJECT_NAME  | Name of the Docker Compose project | `registry-proxy`
| BUILDKIT_PROGRESS     | Sets the type of the [BuildKit progress output](https://docs.docker.com/build/building/variables/#buildkit_progress) | `auto`
| ALPINE_VERSION        | Version of The [Alpine Image](https://hub.docker.com/_/alpine) to use for building | `3.23.3`
| SQUID_VERSION         | [Squid Release version](https://github.com/squid-cache/squid/releases) used for building | `7_4`
| IMAGE_REPOSITORY      | Name of the Docker image built | uses `COMPOSE_PROJECT_NAME`
| IMAGE_TAG             | Tag of the Docker image built, defaults to the `SQUID_VERSION` with a string substitution of `_` with `.` ( eg : `7_4` to `7.4` ) | `7.4`
| TLS_CA_CERT_AND_KEY   | Path to the self-signed CA cert and key in PEM format | null
| RESTART_POLICY        | Defines the [restart policy](https://docs.docker.com/reference/compose-file/services/#restart) of the registry proxy container | `unless-stopped`
