FROM alpine:3.4
MAINTAINER Jon Jagger <jon@jaggersoft.com>

# The rails app runs docker run/exec commands as the cyber-dojo user
# (the --user=nobody is the user *inside* the run/exec container)
#
# Practice session files are stored in katas/...
# and the rails app writes to katas/...
#
# 1. if katas is accessed via a folder on host (eg volumes: in the docker-compose yml file)
#    then the rails app on the inside needs to match uid with the cyber-dojo user
#    that owns the katas on the host on the outside
#    eg on Docker-Quickstart-Terminal (Windows/OSX)
#       $ docker-machine ssh default
#       $ sudo adduser -D -H -u 19661 cyber-dojo
#       $ sudo chown -R cyber-dojo /var/www/cyber-dojo/katas
#
# 2. if katas is a data-container (eg volumes_from: in the docker-compose.yml file)
#    then the rails app on the inside needs to match uid with the cyber-dojo user
#    that owns the katas inside the data-container (no dependencies to the host)
#    So both web and katas images use this as their FROM image.

USER root
# -D=no password, -H=no home directory
RUN adduser -D -H -u 19661 cyber-dojo

# git is needed inside commands that build collection volumes from URLs
# eg ./cyber-dojo volume create --name=VOL --git=URL
#RUN apk add --update --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ git
RUN apk add --update git
