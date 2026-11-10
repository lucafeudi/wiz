FROM alpine:3.18

# Add metadata labels to simulate engineering ownership ########
LABEL maintainer="luca.feudi@gmail.com"
LABEL application="wiz-demo-target"

# Create the specific validation text file as requested by the exercise
RUN echo "Luca Feudi" > /wizexercise.txt

# Install packages required for standard operations and troubleshooting
RUN apk update && apk add --no-cache curl mongodb-tools bash coreutils

# Copy a dummy executable shell app to keep container running and responsive to connections
COPY <<-"EOF" /app.sh
#!/bin/bash
echo "Starting Wiz Technical Exercise Target App..."
echo "Metadata File contents (/wizexercise.txt):"
cat /wizexercise.txt

while true; do
  # Respond with HTML for the load balancer health checks on port 80
  { echo -ne "HTTP/1.0 200 OK\r\nContent-Length: 42\r\n\r\nWelcome to Wiz Exercise - Target Container"; } | nc -l -p 80
done
EOF

RUN chmod +x /app.sh

EXPOSE 80

ENTRYPOINT ["/bin/bash", "/app.sh"]
