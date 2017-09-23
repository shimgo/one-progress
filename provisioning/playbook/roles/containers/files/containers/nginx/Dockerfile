FROM nginx:1.12.1
ADD nginx.conf /etc/nginx/nginx.conf
RUN touch /var/run/nginx.pid
RUN chown -R nginx:nginx /var/run/nginx.pid
RUN chown -R nginx:nginx /var/cache/nginx
RUN chown -R nginx:nginx /var/log/nginx
ENTRYPOINT ["nginx", "-g", "daemon off;"]
