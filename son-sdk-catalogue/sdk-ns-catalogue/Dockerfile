FROM ruby:2.1
RUN mkdir -p /app
WORKDIR /app
COPY Gemfile /app/
COPY . /app
RUN bundle install --quiet
RUN rake yard
ENV PORT 4567
EXPOSE 8808
EXPOSE 4567
WORKDIR /app
CMD ["rake", "start"]