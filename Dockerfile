# Base image
FROM python:3.9-slim

# Set the working directory
WORKDIR /src

# Install Poetry
RUN pip install poetry

# Copy Poetry files first for caching
COPY pyproject.toml poetry.lock /src/

# Install dependencies in a virtual environment managed by Poetry
RUN poetry config virtualenvs.create false && poetry install --no-dev

# Copy application files
COPY src/api.py /src/

# Expose the application's port
EXPOSE 5000

# Command to run the application
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "api:app"]
