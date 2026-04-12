FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
	&& apt-get install -y acl \
	&& rm -rf /var/lib/apt/lists/*

COPY setup.sh /root/setup.sh
RUN chmod +x /root/setup.sh && /root/setup.sh

CMD ["cat", "/root/report.txt"]
