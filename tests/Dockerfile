
# Use Amazon Linux 2 as the base image
FROM xridge/fio

# Update package index and install jq and bc
RUN apk add --no-cache coreutils
RUN apk update && apk add --no-cache jq bc

# Copy the benchmark script to the container
COPY benchmark.sh /benchmark.sh

RUN chmod +x /benchmark.sh

CMD ["sleep", "36500"]

