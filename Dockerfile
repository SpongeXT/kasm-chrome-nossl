FROM kasmweb/chrome:1.17.0
USER root
RUN sed -i.bak 's/-sslOnly//g' /dockerstartup/vnc_startup.sh && if grep -q '\-sslOnly' /dockerstartup/vnc_startup.sh; then echo "sslOnly still present" >&2; exit 1; fi && echo "sslOnly removed OK" && grep -n "vncserver " /dockerstartup/vnc_startup.sh || true
RUN mkdir -p /etc/kasmvnc && printf 'network:\n  ssl:\n    require_ssl: false\n' > /etc/kasmvnc/kasmvnc.yaml && cat /etc/kasmvnc/kasmvnc.yaml
USER 1000
