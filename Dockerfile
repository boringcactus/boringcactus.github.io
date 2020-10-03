FROM jekyll/jekyll AS build
COPY . /srv/jekyll
RUN jekyll build && cp -r /srv/jekyll/_site /var/jekyll_site

FROM nginx
COPY --from=build /var/jekyll_site /usr/share/nginx/html
