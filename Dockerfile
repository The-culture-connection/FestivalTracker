# FestMap Flutter web — build + static SPA server for Railway
# https://docs.railway.com/guides/static-hosting

FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app/festmap
COPY festmap/pubspec.yaml festmap/pubspec.lock ./
RUN flutter pub get

COPY festmap/ ./
RUN flutter build web --release

FROM node:20-alpine AS runtime

RUN npm install -g serve@14.2.4

WORKDIR /site
COPY --from=build /app/festmap/build/web .

ENV HOST=0.0.0.0
ENV PORT=8080
EXPOSE 8080

# SPA fallback (Flutter web client-side routes)
CMD ["sh", "-c", "exec serve -s . -l tcp://0.0.0.0:${PORT}"]
