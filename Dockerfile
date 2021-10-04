FROM python:3.9-alpine AS builder
RUN	apk --update --no-cache add build-base && \
	python -m pip install --cache-dir=/tmp/ \
		click==8.0.1 \
		CoAPthon3==1.0.1 \
		Flask==2.0.1 \
		itsdangerous==2.0.1 \
		Jinja2==3.0.1 \
		MarkupSafe==2.0.1 \
		prometheus-client==0.11.0 \
		py-air-control==2.3.0 \
		py-air-control-exporter==0.3.1 \
		pycryptodomex==3.10.1 \
		Werkzeug==2.0.1 && \
	mkdir /wheels/ && \
        find /tmp/wheels -type f -name '*.whl' | xargs -I{} cp -v {} /wheels/

FROM python:3.9-alpine

ARG BUILD_DATE

LABEL org.opencontainers.image.title="contain-air"
LABEL org.opencontainers.image.description="Exports Prometheus metrics from Philips smart air purifier devices."
LABEL org.opencontainers.image.version="0.1.1"
LABEL org.opencontainers.image.url="https://github.com/hundehausen/contain.air"
LABEL org.opencontainers.image.authors="hundehausen"
LABEL org.opencontainers.image.created="${BUILD_DATE}"
LABEL org.opencontainers.image.source="https://github.com/hundehausen/contain-air"

COPY --from=builder /wheels /packages

RUN	python -m pip install --no-cache-dir --no-index --find-links=packages/ \
		CoAPthon3==1.0.1 \
		MarkupSafe==2.0.1 \
		pycryptodomex==3.10.1 && \
	python -m pip install --no-cache-dir \
        click==8.0.1 \
		Werkzeug==2.0.1 \
		Jinja2==3.0.1 \
        Flask==2.0.1 \
        itsdangerous==2.0.1 \
        py-air-control==2.3.0 \
		py-air-control-exporter==0.3.1 && \
        rm -rf /packages && \
		adduser -s /bin/false -S -D python

EXPOSE 9896
USER python
WORKDIR /home/python
ENTRYPOINT ["py-air-control-exporter"]
CMD ["--host", "0.0.0.0"]
