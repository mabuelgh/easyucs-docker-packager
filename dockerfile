# Use a base Python image
FROM python:3.11-slim

# 1. Optional proxy settings
# Pass via: --build-arg PROXY_URL=http://your-proxy:port
# Leave empty (default) for direct internet access — used by CI/CD
ARG PROXY_URL=""
ENV http_proxy=${PROXY_URL}
ENV https_proxy=${PROXY_URL}
ENV HTTP_PROXY=${PROXY_URL}
ENV HTTPS_PROXY=${PROXY_URL}

# 2. Configure pip to use the proxy only if one is provided
RUN if [ -n "$http_proxy" ]; then pip config set global.proxy "$http_proxy"; fi

# 3. Install git
# We combine update and install to ensure it works in one layer
RUN apt-get update && apt-get install -y git

# 4. Set the working directory
WORKDIR /app

# 5. Clone the repository
RUN git clone https://github.com/vesposito/easyucs.git /app/easyucs

# 6. Modify the code for external access
RUN sed -i "s/run_simple('localhost'/run_simple('0.0.0.0'/g" /app/easyucs/easyucs_api.py

# 7. Install Python libraries
RUN pip install --no-cache-dir -r /app/easyucs/requirements.txt

# 8. Set final execution details
EXPOSE 5001
WORKDIR /app/easyucs
CMD ["python", "easyucs_api.py"]