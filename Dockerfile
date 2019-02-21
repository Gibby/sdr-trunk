FROM gibby/base:ubuntu18.04
SHELL ["/bin/bash", "-c"]

ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install packages for trunk-recorder and liquidsoap
RUN apt-get update && apt-get install --no-install-recommends -y \
    ffmpeg \
    lame \
    libboost-log1.65.1 \
    libboost-regex1.65.1 \
    libgnuradio-analog* \
    libgnuradio-blocks* \
    libgnuradio-digital* \
    libgnuradio-filter* \
    libgnuradio-osmosdr* \
    libgnuradio-runtime* \
    libgnuradio-uhd* \
    libuhd0* \
    liquidsoap \
    liquidsoap-plugin-all \
    socat \
    gettext

# Install packages for trunk-player
RUN apt-get install --no-install-recommends -y \
    gcc \
    libpq-dev \
    nginx \
    postgresql-client \
    postgresql-client-common \
    python3-dev \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    redis-server && \
    rm -rf /var/lib/apt/lists/*

# Get and configure trunk-player
WORKDIR /home/radio/trunk-player
RUN git clone https://github.com/ScanOC/trunk-player.git ./ && \
    cp -r audio_files audio_files.orig && \
    pip3 install -r requirements.txt

# Fix locale
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

# Get recorder
COPY --from=gibby/trunk-recorder:latest /home/radio/trunk-player ./

# Setup container
COPY src_files/* ./src_files/
COPY entrypoint.sh ./

ENTRYPOINT ["./entrypoint.sh"]

CMD ["test"]
