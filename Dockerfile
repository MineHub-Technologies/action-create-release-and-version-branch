FROM public.ecr.aws/n2m5y1h2/alpine:3.16.2

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
