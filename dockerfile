# Use a base Python image
FROM python:3.11-slim

# 1. Set Environment Variables for the Proxy (Optionnal)
# These will persist through the entire build process
ENV http_proxy=http://proxy.esl.cisco.com:80
ENV https_proxy=http://proxy.esl.cisco.com:80
ENV HTTP_PROXY=http://proxy.esl.cisco.com:80
ENV HTTPS_PROXY=http://proxy.esl.cisco.com:80

# 2. Configure pip to use the proxy (Optionnal)
RUN pip config set global.proxy http://proxy.esl.cisco.com:80

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