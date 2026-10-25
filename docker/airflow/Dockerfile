FROM apache/airflow:slim-3.3.1-python3.12

ARG AIRFLOW_VERSION=3.3.1
ARG PYTHON_VERSION=3.12
ARG PIP_INDEX_URL=https://pypi.org/simple

COPY docker/airflow/requirements.txt /requirements-airflow.txt

RUN --mount=type=cache,target=/home/airflow/.cache/pip \
    pip install --timeout 300 --retries 10 \
    "apache-airflow==${AIRFLOW_VERSION}" \
    --index-url "${PIP_INDEX_URL}" \
    --constraint "https://raw.githubusercontent.com/apache/airflow/constraints-${AIRFLOW_VERSION}/constraints-${PYTHON_VERSION}.txt" \
    && pip install --timeout 300 --retries 10 \
    -r /requirements-airflow.txt \
    --index-url "${PIP_INDEX_URL}"
