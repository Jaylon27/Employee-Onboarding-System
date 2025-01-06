# Use an official Python runtime as a parent image
FROM python:3.11-slim

# Install required packages
RUN apt-get update && apt-get install -y \
    unixodbc \
    unixodbc-dev \
    unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install the ODBC Driver for SQL Server
RUN apt-get update && apt-get install -y \
    curl \
    gnupg2 \
    && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y msodbcsql18 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy the application code
COPY . /app

# Install Python dependencies
RUN pip install -r requirements.txt

# Command to run the application
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "80"]
