FROM python:3.12-alpine

# Essa variável de ambiente é usada para controlar se o Python deve 
# gravar arquivos de bytecode (.pyc) no disco. 1 = Não, 0 = Sim
ENV PYTHONDONTWRITEBYTECODE 1

# Define que a saída do Python será exibida imediatamente no console ou em 
# outros dispositivos de saída, sem ser armazenada em buffer.
# Em resumo, você verá os outputs do Python em tempo real.
ENV PYTHONUNBUFFERED 1

# Copia a pasta do projeto e "scripts" para dentro do container.
COPY . /app
COPY ./scripts /app/scripts

# Entrar na pasta do projeto dentro do container.
WORKDIR /app

# A porta 8000 estará disponível para conexões externas ao container
# É a porta que vamos usar para o Django.
EXPOSE 8000

# RUN executa comandos em um shell dentro do container para construir a imagem. 
# O resultado da execução do comando é armazenado no sistema de arquivos da 
# imagem como uma nova camada.
# Agrupar os comandos em um único RUN pode reduzir a quantidade de camadas da 
# imagem e torná-la mais eficiente.
RUN apk add --no-cache dos2unix && \
    dos2unix /app/scripts/commands.sh && \
    apk add --no-cache python3 py3-pip py3-virtualenv && \
    python -m venv venv && \
    ./venv/bin/python -m ensurepip && \
    ./venv/bin/python -m pip install --upgrade pip && \
    ./venv/bin/python -m pip install -r requirements.txt && \
    adduser -D duser && \
    mkdir -p /app/data/web/static && \
    mkdir -p /app/data/web/media && \
    chown -R duser:duser venv && \
    chown -R duser:duser /app/data/web/static && \
    chown -R duser:duser /app/data/web/media && \
    chmod -R 755 /app/data/web/static && \
    chmod -R 755 /app/data/web/media && \
    chmod +x /app/scripts/commands.sh

# Adiciona a pasta scripts e venv/bin 
# no $PATH do container.
ENV PATH="/app/venv/bin:/app/scripts:${PATH}"

# Muda o usuário para duser
USER duser

# Executa o arquivo scripts/commands.sh
CMD ["sh", "/app/scripts/commands.sh"]