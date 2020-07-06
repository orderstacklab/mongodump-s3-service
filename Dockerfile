FROM alpine

# set working directory
WORKDIR /usr/files

COPY awesomescript.sh /usr/local/bin/myawesomescript
COPY setcron.sh /usr/local/bin/setcron
COPY instant.sh /usr/local/bin/instant

RUN chmod +x /usr/local/bin/instant

RUN apk add bash

RUN echo "Install System dependencies" && \
    apk add --update

RUN echo "Install MongoDB dependencies" && \
    apk add \
    mongodb-tools

RUN echo "Install aws-cli" && \
    apk add \ 
    --update py-pip groff less mailcap \
    && pip install awscli

RUN rm /var/cache/apk/*

RUN chmod +x /usr/local/bin/myawesomescript

RUN cat /usr/local/bin/myawesomescript

CMD /bin/bash /usr/local/bin/setcron -- crond -l 2 -f