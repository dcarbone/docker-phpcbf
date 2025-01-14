ARG PHP
FROM php:7.4 as builder

# Install build dependencies
RUN set -eux \
	&& DEBIAN_FRONTEND=noninteractive apt-get update -qq \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -qq -y --no-install-recommends --no-install-suggests \
		ca-certificates \
		curl \
		git \
	&& git clone https://github.com/squizlabs/PHP_CodeSniffer

ARG PHPCBF
RUN set -eux \
	&& cd PHP_CodeSniffer \
	&& if [ "${PHPCBF}" = "latest" ]; then \
		VERSION="$( git describe --abbrev=0 --tags )"; \
	else \
		VERSION="$( git tag | grep -E "^v?${PHPCBF}\.[.0-9]+\$" | sort -V | tail -1 )"; \
	fi \
	&& curl -sS -L https://github.com/squizlabs/PHP_CodeSniffer/releases/download/${VERSION}/phpcbf.phar -o /phpcbf.phar \
	&& chmod +x /phpcbf.phar \
	&& mv /phpcbf.phar /usr/bin/phpcbf


FROM php:${PHP} as production
LABEL \
	maintainer="cytopia <cytopia@everythingcli.org>" \
	repo="https://github.com/cytopia/docker-phpcbf"

COPY --from=builder /usr/bin/phpcbf /usr/bin/phpcbf
ENV WORKDIR /data
WORKDIR /data

ENTRYPOINT ["phpcbf"]
CMD ["--version"]
