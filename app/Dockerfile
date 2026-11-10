FROM python:3.9-slim

WORKDIR /app

# Include wizexercise.txt with name Luca Feudi
RUN echo "Luca Feudi" > wizexercise.txt

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5000
CMD ["python", "app.py"]
