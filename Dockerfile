FROM erlang:alpine

RUN apk update &&\
        apk add git &&\
        apk add openssl

   
# Set working directory
RUN mkdir /buildroot
WORKDIR /buildroot

# Copy our Erlang test application
COPY certf certf

WORKDIR certf/apps/certf/priv
RUN sh setup.sh
RUN sh create_cert.sh
WORKDIR chal4
RUN sh chal4.sh

# And build the release
WORKDIR /buildroot/certf
RUN rebar3 as prod release

# Build stage 1
FROM alpine

# Install some libs
RUN apk add --no-cache openssl && \
    apk add --no-cache ncurses-libs

# Install the released application
COPY --from=0 /buildroot/certf/_build/prod/rel/certf /certf

# Expose relevant ports
EXPOSE 4437

CMD ["/certf/bin/certf", "foreground"]
