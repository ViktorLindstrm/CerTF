FROM erlang:alpine

# Set working directory
RUN mkdir /buildroot
WORKDIR /buildroot

# Copy our Erlang test application
COPY certf certf

# And build the release
WORKDIR certf
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

CMD ["/dceertf/bin/certf", "foreground"]
