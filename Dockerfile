FROM ruby:3.1.2

ENV LANG C.UTF-8

ENV RAILS_ENV=development

ENV BUNDLER_VERSION 2.3.14

RUN apt-get update -qq \
    && apt-get install build-essential \
                       gosu \
                    -y vim-gtk \
    && rm -rf /var/lib/apt/lists/* \
    && curl -fsSL https://bun.sh/install | bash \
    && export BUN_INSTALL="$HOME/.bun" \
    && export PATH="$BUN_INSTALL/bin:$PATH" \
    && bun --version \
    && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash \
    && export NVM_DIR="$HOME/.nvm" \
    && \. "$NVM_DIR/nvm.sh" \
    && nvm install 24 \
    && node -v \
    && corepack enable yarn \
    && yarn -v

RUN mkdir /sample_app
WORKDIR /sample_app

RUN gem install bundler -v $BUNDLER_VERSION
RUN bundle -v

COPY Gemfile Gemfile.lock /sample_app/
RUN bundle install --jobs=4

COPY . /sample_app

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
