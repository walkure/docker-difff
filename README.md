# docker-difff

The dockerized [difff](https://github.com/meso-cacase/difff/).

## run

```:sh
docker run -p 8080:8080 --rm --name cdif -it ghcr.io/walkure/docker-difff:latest
```

## for debug

### build locally

```:sh
docker build -t diffff .
```

### exec as nonroot

```:sh
docker exec -it cdif sh
```

### exec as root

```:sh
docker exec -u root -it cdif sh
```

## Author

walkure <walkure at 3pf.jp>

## License

MIT.
