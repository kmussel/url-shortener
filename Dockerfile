# syntax = docker/dockerfile:experimental
ARG TARGET_ENV=prod
ARG UI_IMAGE=ui-prod

FROM ruby:2.6.6-slim-stretch as base

RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    curl \
    libpq-dev \
    vim \
    libmagic-dev \
    libsqlite3-dev \
    pkg-config \
    git \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sL https://deb.nodesource.com/setup_10.x |  bash -
RUN apt-get update && apt-get install -y \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

RUN npm install yarn --global


# Set an environment variable where the Rails app is installed to inside of Docker image
ENV RAILS_ROOT ${RAILS_ROOT:-/var/www/urlshortener}
ENV APP_DIR=${RAILS_ROOT}/app

RUN mkdir -p ${APP_DIR}
# Set working directory
WORKDIR $RAILS_ROOT

# Setting env up
ARG RAILS_ENV=${RAILS_ENV:-production}
ENV RAILS_ENV=$RAILS_ENV
ENV RACK_ENV=${RAILS_ENV}

RUN mkdir -p $RAILS_ROOT/vendor/bundle
# Adding gems

### DEV BUNDLER
FROM base as gems-dev

ENV BUNDLE_PATH ${BUNDLE_PATH:-/var/www/vendor}
COPY Gemfile Gemfile.lock ./
RUN mount=type=cache,target=/var/www/vendor/bundle bundle install --jobs 20 --retry 5 

# COPY package.json yarn.lock ./
# RUN mount=type=cache,target=${RAILS_ROOT}/yarn_cache yarn install --check-files --update-checksums --modules-folder /var/www/node_modules

## PROD BUNDLER
FROM base as gems-prod

COPY Gemfile Gemfile.lock ./
RUN mount=type=cache,target=${RAILS_ROOT}/vendor/bundle bundle install --deployment --jobs 20 --retry 5 --without test development

RUN find vendor/bundle/ruby/*/extensions \
        -type f -name "mkmf.log" -o -name "gem_make.out" | xargs rm -f \
    && find vendor/bundle/ruby/*/gems -maxdepth 2 \
        \( -type d -name "spec" -o -name "test" -o -name "docs" \) -o \
        \( -name "*LICENSE*" -o -name "README*" -o -name "CHANGELOG*" \
            -o -name "*.md" -o -name "*.txt" -o -name ".gitignore" -o -name ".travis.yml" \
            -o -name ".rubocop.yml" -o -name ".yardopts" -o -name ".rspec" \
            -o -name "appveyor.yml" -o -name "COPYING" -o -name "SECURITY" \
            -o -name "HISTORY" -o -name "CODE_OF_CONDUCT" -o -name "CONTRIBUTING" \
        \) | xargs rm -rf

RUN yarn config set cache-folder ${RAILS_ROOT}/yarn_cache
COPY package.json yarn.lock ./
RUN mount=type=cache,target=${RAILS_ROOT}/yarn_cache yarn install --check-files --production=true


### ASSETS 

FROM gems-${TARGET_ENV} as assets

## copy over files needed to compile assets
COPY package.json yarn.lock ./
COPY bin bin
COPY Rakefile postcss.config.js babel.config.js ./
COPY config/initializers/assets.rb config/initializers/
COPY config/environments/production.rb  config/environments/
COPY config/locales config/locales
COPY config/application.rb \
     config/application.yml \
     config/boot.rb \
     config/environment.rb \
     config/webpacker.yml \
     config/

COPY config/webpack ./config/webpack

COPY app/assets ${APP_DIR}/assets
COPY app/javascript ${APP_DIR}/javascript
# COPY vendor/assets vendor/assets
RUN mount=type=cache,target=${RAILS_ROOT}/public SECRET_KEY_BASE=1 PRECOMPILE_ASSETS=true bundle exec rake assets:precompile
RUN rm -rf tmp yarn_cache 
#node_modules


### Dev Final Image
FROM gems-dev as final-dev

# COPY . .
EXPOSE 8080
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb", "-p", "8080"]


FROM ${UI_IMAGE} as ui_image


## PROD BUILD
FROM base as final

COPY ./ ./

COPY --from=ui_image /usr/local/bundle /usr/local/bundle
COPY --from=ui_image ${RAILS_ROOT}/vendor/bundle vendor/bundle
COPY --from=ui_image ${RAILS_ROOT}/public/assets public/assets
COPY --from=ui_image ${RAILS_ROOT}/public/packs public/packs


EXPOSE 8080

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]



## used to run linter
FROM final as finaltest
COPY --from=ui_image ${RAILS_ROOT}/node_modules node_modules
