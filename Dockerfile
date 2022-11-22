# docker pull nginx
FROM nginx 

# who is creating this
LABEL MAINTAINER=osman

# create create index.html - copy to container

# copy to default locatuon /usr/share/nginx/html/
COPY index.html /usr/share/nginx/html/
# commit and push to docker hub

# docker run 80:80 name

# port number
EXPOSE 80 

# launch the server
CMD ["nginx", "-g", "daemon off;"]