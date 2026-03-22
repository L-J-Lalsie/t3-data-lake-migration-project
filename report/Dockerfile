# We want to use the version of Python that works in Lambda
FROM public.ecr.aws/lambda/python:3.9

# Set the working directory
WORKDIR ${LAMBDA_TASK_ROOT}

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY report.py .

CMD ["report.handler"]