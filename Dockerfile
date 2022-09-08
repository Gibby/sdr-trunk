FROM gibby/sdr-trunk:0.9

# Setup container
COPY src_files/* ./src_files/
COPY entrypoint.sh ./

ENTRYPOINT ["./entrypoint.sh"]

CMD ["test"]
