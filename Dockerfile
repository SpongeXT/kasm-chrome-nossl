FROM kasmweb/chrome:1.17.0
USER root
# Altare's Go proxy connects upstream over plain HTTP and sends no
# credentials, so KasmVNC must accept plain HTTP *and* no auth:
#  - replace -sslOnly with -disableBasicAuth on the vncserver line(s)
#    in /dockerstartup/vnc_startup.sh. -disableBasicAuth is an Xvnc
#    flag; vncserver passes extra CLI args through to Xvnc. Kasm's
#    maintainer confirms this is the way to disable BasicAuth
#    (kasmtech/KasmVNC#259). The startup script still generates
#    ~/.kasmpasswd via kasmvncpasswd, which KasmVNC requires to
#    exist even with BasicAuth disabled.
#  - Fail the build if -sslOnly remains or -disableBasicAuth is missing.
RUN sed -i.bak 's/-sslOnly/-disableBasicAuth/g' /dockerstartup/vnc_startup.sh \
 && if grep -q '\-sslOnly' /dockerstartup/vnc_startup.sh; then echo "sslOnly still present" >&2; exit 1; fi \
 && if ! grep -q '\-disableBasicAuth' /dockerstartup/vnc_startup.sh; then echo "disableBasicAuth missing" >&2; exit 1; fi \
 && echo "sslOnly -> disableBasicAuth OK" \
 && grep -n "vncserver " /dockerstartup/vnc_startup.sh || true
# Belt and braces: KasmVNC also reads /etc/kasmvnc/kasmvnc.yaml.
# Default require_ssl is true; set it false so plain HTTP is allowed
# even if the command-line flag ever comes back.
RUN mkdir -p /etc/kasmvnc \
 && printf 'network:\n  ssl:\n    require_ssl: false\n' > /etc/kasmvnc/kasmvnc.yaml \
 && cat /etc/kasmvnc/kasmvnc.yaml
USER 1000
