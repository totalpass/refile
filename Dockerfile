# Use uma imagem base com Ruby que suporta ARM64
FROM ruby:3.0

# Instale dependências do sistema
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    wget \
    gnupg \
    libxi6 \
    libgconf-2-4 \
    libnss3 \
    libx11-xcb1 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    libxss1 \
    libxtst6 \
    libgtk-3-0 \
    libatspi2.0-0 \
    libnspr4 \
    libgbm1 \
    libasound2 \
    && rm -rf /var/lib/apt/lists/*

# Adicione o repositório do Chromium e instale o Chromium
RUN apt-get update && apt-get install -y \
    chromium \
    && rm -rf /var/lib/apt/lists/*

# Instale o ChromeDriver
RUN CHROMEDRIVER_VERSION=$(curl -sSL https://chromedriver.storage.googleapis.com/LATEST_RELEASE) \
    && curl -sSL https://chromedriver.storage.googleapis.com/$CHROMEDRIVER_VERSION/chromedriver_linux64.zip -o chromedriver.zip \
    && unzip chromedriver.zip \
    && mv chromedriver /usr/local/bin/ \
    && chmod +x /usr/local/bin/chromedriver \
    && rm chromedriver.zip

# Defina o diretório de trabalho
WORKDIR /app

# Copie o restante da aplicação
COPY . /app

ENV BUNDLE_GEMFILE=./gemfiles/Gemfile_Rails_6_1

# Instale as gems
RUN bundle install

# Comando padrão para rodar os testes
CMD ["bundle", "exec", "rake", "test"]
