# Lightning Stream Docker

This project provides a **Dockerfile** for **Lightning Stream** [lightningstream](https://github.com/PowerDNS/lightningstream/) project.

Images are available on Dockerhub for `arm64` and `amd64`.

## Examples

Default

    docker run -it -d \
      --name lightningstream \
      -p 8500:8500/tcp \
      -v ./lightningstream.yaml:/app/lightningstream.yaml:ro \
      -e PUID=953 \
      -e PORT=8500 \
      mschirrmeister/powerdns-lightstream:latest

If you want to modify some start parameters, specify everything how you want to run it

    docker run -it -d \
      --name lightningstream \
      -p 8500:8500/tcp \
      -v ./lightningstream.yaml:/app/lightningstream.yaml:ro \
      -e PUID=953 \
      -e PORT=8500 \
      mschirrmeister/powerdns-lightstream:latest /app/lightningstream --config /app/lightningstream.yaml --minimum-pid 50 --debug receive

If you need some more logic before starting the daemon, then mount a script into the container and specify everything in the script. See notes below.

    docker run -it -d \
      --name lightningstream \
      -p 8500:8500/tcp \
      -v ./lightningstream.yaml:/app/lightningstream.yaml:ro \
      -v ./start.sh:/app/start.sh \
      -e PUID=953 \
      -e PORT=8500 \
      -e PDNS_LSTREAM_SLEEP=xxx \
      -e PDNS_LSTREAM_DNS_SERVER=xxx \
      -e PDNS_LSTREAM_DOMAIN=xxx \
      mschirrmeister/powerdns-lightstream:latest start.sh

## Notes

I noticed, if the lightingstream container starts right away after or with the **pdns auth** container, the **pdns auth** server hangs, if you send a dns query to it or run the `pdnsutil` tool. Maybe some locking or whatever in the LMDB database? There is nothing in the pdns logs, a query just hangs.

First I thought it is a timing issue, but just starting the **lightningstream** container some n time later, does not help. A query to pdns still hangs.

Then I thought it is related to the _PID clashing_ that is mentioned in the docs and that playing around with the `--minimum-pid` option might help. But it did not. DNS queries or `pdnsutil` was still hanging no matter what the minimum pid was.

The _workaround_ at this point is, to send **one** dns query for a domain that **exists** after the **pdns auth** container is started and then start the **lightningstream** container. Whatever is internally happening, it runs at least stable and nothing hangs, if the **lightningstream** container is **first** started, after there was a valid DNS query to the **pdns auth** server.
