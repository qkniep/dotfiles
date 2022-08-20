FROM manjarolinux/base
COPY . .
ENTRYPOINT [ "bash", "bootstrap.sh" ]
