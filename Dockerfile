FROM jekyll/jekyll AS build
COPY . /srv/jekyll
RUN jekyll build

FROM nginx
COPY --from=build /srv/jekyll/_site /usr/share/nginx/html
